import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

const CATCH_URLS = ['m.ctrip.com/', 'm.ctrip.com/html5/', 'm.ctrip.com/html5'];
class WebView extends StatefulWidget {
  final String url; // url
  final String statusBarColor; // TabBar颜色
  final String title;// 标题
  final bool hideAppBar;// true 隐藏TabBar
  final bool backForbid;// true 禁止返回

  const WebView(
      {Key key,
      this.url,
      this.statusBarColor,
      this.title,
      this.hideAppBar,
      this.backForbid = false})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  final webViewReference = new FlutterWebviewPlugin();// WebView的引用
  StreamSubscription<String> _onUrlChanged;// 监听URL变化
  StreamSubscription<WebViewStateChanged> _onStateChanged; // 监听
  StreamSubscription<WebViewHttpError> _onHttpError;//
  bool exiting = false;

  @override
  void initState() {
    super.initState();
    webViewReference.close(); // 防止重新打开
    // 当URL发生变化通过这个方法监听
    _onUrlChanged = webViewReference.onUrlChanged.listen((String url) {});

    _onStateChanged = webViewReference.onStateChanged.listen((WebViewStateChanged state) {
      switch(state.type) {
        case WebViewState.startLoad:// 开始加载的时候
          if(_isToMain(state.url) && !exiting) {// 主页URL
            if(widget.backForbid) { // 禁止返回
              webViewReference.launch(widget.url); // 从新打开当前页面
            } else {
              Navigator.pop(context); // 返回上一页
              exiting = true; // 防止重复返回
            }
          }
          break;
        default:
          break;
      }
    });
    _onHttpError = webViewReference.onHttpError.listen((WebViewHttpError e) {
      print(e);
    });
  }

  _isToMain(String url){
    bool contain = false;
    for(final value in CATCH_URLS) {
      if(url?.endsWith(value) ?? false) { // ? 符号当url存在的情况下调用 startWith 否则 false
        contain = true;
        break;
      }
    }
    return contain;
  }

  @override
  void dispose() {// 注销工作
    _onUrlChanged.cancel();
    _onStateChanged.cancel();
    _onHttpError.cancel();
    webViewReference.dispose();// 关掉webview需要在super方法之前
    super.dispose(); //
  }

  @override
  Widget build(BuildContext context) {
    String statusBarColorStr = widget.statusBarColor ?? 'ffffff';
    Color backButtonColor;
    if (statusBarColorStr == 'ffffff') {
      backButtonColor = Colors.black;
    } else {
      backButtonColor = Colors.white;
    }
    return Scaffold(
      body: Column(
        children: <Widget>[
          _appBar(Color(int.parse('0xff' + statusBarColorStr)), backButtonColor), // AppBar String 转int
          
          Expanded(child: WebviewScaffold(url: widget.url,
          withZoom: true, // 支持缩放
            withLocalStorage: true, // 本地存储
            hidden: true,// 默认隐藏, 显示初始化加载布局
            initialChild: Container(
              color: Colors.white,
              child: Center(
                child: Text('Waiting...'),
              ),
            ), // 加载圈
          ),
          )
        ]
      ),
    );
  }
  _appBar(Color backgroundColor, Color backButtonColor) {
    if(widget.hideAppBar ?? false) { // 隐藏状态的视图
      return Container(
        color: backgroundColor,
        height: 30,
      );
    }

    return Container(
      color: backButtonColor,
      padding: EdgeInsets.fromLTRB(0, 40, 0, 10), // 优化：webview 顶部返回按钮位置靠上
      child: FractionallySizedBox(// Widget 撑满底部宽度
        widthFactor: 1,// 宽度撑满
        child: Stack(
          children: <Widget>[
            GestureDetector(
              onTap: (){
                Navigator.pop(context); // 返回上一层
              },
              child: Container(
                margin: EdgeInsets.only(left: 10),
                child: Icon(
                  Icons.close,
                  color: backgroundColor,
                  size: 26,
                ),
              ),
            ),
            Positioned(// 绝对定位
              left: 0,
              right: 0,
              child: Center(// 标题居中
                child: Text(widget.title??'',
                style: TextStyle(color: backgroundColor, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

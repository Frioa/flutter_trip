import 'package:flutter/material.dart';
import 'package:flutter_trip/model/common_model.dart';
import 'package:flutter_trip/model/grid_nav_model.dart';
import 'package:flutter_trip/widget/webview.dart';

class SubNav extends StatelessWidget {// 1. 继承Widget
  final List<CommonModel> subNavList;// 必须是final 因为是继承 StatelessWidget, 父类使用了@immutable

  // 2.定义构造方法 @required 参数是必须的
  const SubNav({Key key, @required this.subNavList}) : super(key: key);

  // 3. build 方法
  @override
  Widget build(BuildContext context) {
    return Container( // 方便定义宽高
      decoration: BoxDecoration(// 装饰器
        color: Colors.white,
        borderRadius: BorderRadius.circular(6)
      ),
      child: Padding(padding: EdgeInsets.all(7),
        child: _items(context),
      ),
    );
  }


  _items(BuildContext context) {
    if(subNavList == null) return null;
    List<Widget> items = [];
    subNavList.forEach((model) {
      items.add(_item(context, model));
    });
    // 计算每一行显示的数据
    int separate = (subNavList.length / 2 + 0.5).toInt();
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: items.sublist(0, separate),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: items.sublist(separate, subNavList.length),
          ),
        )
      ],
    );
  }

  Widget _item(BuildContext context, CommonModel model) {
    return Expanded(
      flex: 1,
      child: GestureDetector( // 为组件添加点击事件
        onTap: (){
          Navigator.push(context,
              MaterialPageRoute(builder: (context) =>
                  WebView(url: model.url, statusBarColor: model.statusBarColor,
                    hideAppBar: model.hideAppBar,)
              )
          );
        },
        child: Column(
          children: <Widget>[
            Image.network(
              model.icon,
              height: 18,
              width: 18,
            ),
            Padding(
              padding: EdgeInsets.only(top: 3),
              child:  Text(
                model.title,
                style: TextStyle(fontSize: 12),
              ),
            )
          ],
        ),
      ),
    );
  }
}

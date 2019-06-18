import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_trip/dao/home_dao.dart';
import 'package:flutter_trip/model/common_model.dart';
import 'package:flutter_trip/model/grid_nav_model.dart';

import 'package:flutter_trip/model/home_model.dart';
import 'package:flutter_trip/model/sales_box_model.dart';
import 'package:flutter_trip/widget/grid_nav.dart';
import 'package:flutter_trip/widget/local_nav.dart';
import 'package:flutter_trip/widget/loding_container.dart';
import 'package:flutter_trip/widget/sales_box_nav.dart';
import 'package:flutter_trip/widget/sub_nav.dart';
import 'package:flutter_trip/widget/webview.dart';

const APPBAR_SCROLL_OFFSET = 110;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  var appBarAlpha = 0.0;
  String resultString = "";
  List<CommonModel> localNavList = [] ;
  List<CommonModel> bannerList = [] ;
  List<CommonModel> subNavList = [] ;
  GridNavModel gridNavModel  ;
  SalesBoxModel salesBoxModel;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _handleRefresh();
  }

  _onScroll(offset) {
    var alpha = offset / APPBAR_SCROLL_OFFSET;
    if (alpha < 0) {
      // alpha 值的保护
      alpha = 0;
    } else if (alpha > 1) {
      alpha = 1;
    }
    setState(() {
      appBarAlpha = alpha;
    });
    print(appBarAlpha);
  }


  Future<Null> _handleRefresh() async {
    try {
      HomeModel mode = await HomeDao.fetch();
      setState(() {
        localNavList = mode.localNavList;
        subNavList = mode.subNavList;
        gridNavModel = mode.gridNav;
        salesBoxModel = mode.salesBox;
        bannerList = mode.bannerList;
        _loading = false;
      });
    }catch (e){
      print(e);
      _loading = false;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff2f2f2),
        body: LoadingContainer(isLoading: _loading,
            child: Stack(
          children: <Widget>[
            MediaQuery.removePadding(
              // 去掉顶部屏幕适配
              removeTop: true,
              context: context,
              child: RefreshIndicator(
                  child: NotificationListener(
                onNotification: (scrollNotification) {
                  if (scrollNotification is ScrollUpdateNotification &&
                      scrollNotification.depth == 0) {
                    // 优化, 防止scrollNotification=0的时候也监听，只有在ScrollUpdateNotification更新的时候才监听并且只监听ListView的滚动滚动且是列表滚动的时候
                    _onScroll(scrollNotification.metrics.pixels);
                  }
                },
                child: _listView,
              ),
                  onRefresh: _handleRefresh),
            ),
            _appBar,
          ],
        )
        )
    );
  }
  Widget get _listView {
    return ListView(
      children: <Widget>[
        _banner,
        Padding(
          padding: EdgeInsets.fromLTRB(7, 4, 7, 4), // 四周的Padding
          child:  LocalNav(localNavList: localNavList,),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(7, 0, 7, 4), // 四周的Padding
          child:  GridNav(gridNavModel: gridNavModel,),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(7, 0, 7, 4), // 四周的Padding
          child:  SubNav(subNavList: subNavList,),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(7, 0, 7, 4), // 四周的Padding
          child:  SalesBox(salesBox: salesBoxModel,),
        ),
        Container(
          height: 800,
          child: ListTile(
            title: Text(resultString),
          ),
        )
      ],
    );
  }
  Widget get _appBar {
    return Opacity(
      // 透明度设置
      opacity: appBarAlpha,
      child: Container(
        height: 80,
        decoration: BoxDecoration(color: Colors.white), // 长方形的盒子
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: 25), // 顶部的padding
            child: Text('首页'),
          ),
        ),
      ),
    );
  }
  Widget get _banner{
    return Container(
      height: 160,
      child: Swiper(
        itemCount: bannerList.length,
        autoplay: true,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  CommonModel model = bannerList[index];
                  return WebView(
                    url: model.url,
                    title: model.title,
                    hideAppBar: model.hideAppBar,
                  );
                }),
              );
            },
            child: Image.network(
                bannerList[index].icon,
                fit: BoxFit.fill
            ),
          );
        },
        pagination: SwiperPagination(), // 指示器
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_trip/dao/home_dao.dart';
import 'package:flutter_trip/model/common_model.dart';

import 'package:flutter_trip/model/home_model.dart';
import 'package:flutter_trip/widget/local_nav.dart';

const APPBAR_SCROLL_OFFSET = 110;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List _imageUrls = [
    'http://pages.ctrip.com/commerce/promote/20180718/yxzy/img/640sygd.jpg',
    'https://dimg04.c-ctrip.com/images/700u0r000000gxvb93E54_810_235_85.jpg',
    'https://dimg04.c-ctrip.com/images/700c10000000pdili7D8B_780_235_57.jpg'
  ];
  var appBarAlpha = 0.0;
  String resultString = "";
  List<CommonModel> localNavList = [] ;

  @override
  void initState() {
    super.initState();
    loadData();
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

  loadData() async {
    try {
      HomeModel mode = await HomeDao.fetch();
      setState(() {
        localNavList = mode.localNavList;
      });
    }catch (e){
      print(e);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff2f2f2),
        body: Stack(
      children: <Widget>[
        MediaQuery.removePadding(
          // 去掉顶部屏幕适配
          removeTop: true,
          context: context,
          child: NotificationListener(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollUpdateNotification &&
                  scrollNotification.depth == 0) {
                // 优化, 防止scrollNotification=0的时候也监听，只有在ScrollUpdateNotification更新的时候才监听并且只监听ListView的滚动滚动且是列表滚动的时候
                _onScroll(scrollNotification.metrics.pixels);
              }
            },
            child: ListView(
              children: <Widget>[
                Container(
                  height: 160,
                  child: Swiper(
                    itemCount: _imageUrls.length,
                    autoplay: true,
                    itemBuilder: (BuildContext context, int index) {
                      return Image.network(_imageUrls[index], fit: BoxFit.fill);
                    },
                    pagination: SwiperPagination(), // 指示器
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(7, 4, 7, 4), // 四周的Padding
                  child:  LocalNav(localNavList: localNavList,),
                ),

                Container(
                  height: 800,
                  child: ListTile(
                    title: Text(resultString),
                  ),
                )
              ],
            ),
          ),
        ),
        Opacity(
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
        )
      ],
    ));
  }
}

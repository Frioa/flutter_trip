import 'package:flutter/material.dart';
import 'package:flutter_trip/dao/travel_tab_dao.dart';
import 'package:flutter_trip/model/travel_tab_model.dart';

class TravelPage extends StatefulWidget {
  @override
  _TravelPageState createState() => _TravelPageState();
}

class _TravelPageState extends State<TravelPage>
    with SingleTickerProviderStateMixin {
  TabController _controller;
  List<TravelTab> tabs = [];
  TravelTabModel travelTabModel;

  @override
  void initState() {
    _controller = TabController(length: tabs.length, vsync: this);// 由于网上获取数据，从新初始化
    TravelTabDao.fetch().then((TravelTabModel model) {
      _controller =
          TabController(length: model.tabs.length, vsync: this); // 修复Tab空白的问题
      setState(() {
        tabs = model.tabs;
        travelTabModel = model;
      });
    }).catchError((e) {
      print(e);
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: <Widget>[
        Container(
          color: Colors.white,
          padding: EdgeInsets.only(top: 30),
          child: TabBar(
            controller: _controller,
            isScrollable: true,
            labelColor: Colors.black,
            labelPadding: EdgeInsets.fromLTRB(20, 0, 10, 5),
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                color: Color(0xff2fcfbb),
                width: 3,
              ),
              insets: EdgeInsets.fromLTRB(0, 0, 0, 10),
            ),
            tabs: tabs.map<Tab>((TravelTab tab) {
              return Tab(
                text: tab.labelName,
              );
            }).toList(),
          ),
        ),
        Flexible(// 解决TabBarView布局约束宽度与高度丢失的问题。
          child: TabBarView(
              controller: _controller,
              children: tabs.map((TravelTab tab) {
                return Text(tab.groupChannelCode);
              }).toList(),
        ),
        )
      ],
    ));
  }
}

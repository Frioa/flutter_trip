import 'package:flutter/material.dart';
import 'package:flutter_trip/model/grid_nav_model.dart';

class GridNav extends StatefulWidget {// 1. 继承Widget
  final GridNavModel gridNavModel;// 必须是final 因为是继承 StatelessWidget, 父类使用了@immutable
  final String name;

  // 2.定义构造方法 @required 参数是必须的
  const GridNav({Key key, @required this.gridNavModel, this.name = 'name'}) : super(key: key);

  // 3. build 方法
  @override
  Widget build(BuildContext context) {
    return Text('GridNav');
  }

  @override
  State<StatefulWidget> createState() {
    return _GridNavState();
  }

}

class _GridNavState extends State<GridNav> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  Text('GridNav');
  }

}
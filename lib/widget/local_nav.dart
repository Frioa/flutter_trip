import 'package:flutter/material.dart';
import 'package:flutter_trip/model/common_model.dart';
import 'package:flutter_trip/model/grid_nav_model.dart';

class LocalNav extends StatelessWidget {// 1. 继承Widget
  final List<CommonModel> localNavList;// 必须是final 因为是继承 StatelessWidget, 父类使用了@immutable

  // 2.定义构造方法 @required 参数是必须的
  const LocalNav({Key key, @required this.localNavList}) : super(key: key);

  // 3. build 方法
  @override
  Widget build(BuildContext context) {
    return Container( // 方便定义宽高
       height: 64,
      decoration: BoxDecoration(// 装饰器
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(6)), // 圆角
      ),
      child: Padding(padding: EdgeInsets.all(7),
        child: _items(context),
      ),
    );
  }


  _items(BuildContext context) {
    if(localNavList == null) return null;
    List<Widget> items = [];
    localNavList.forEach((model) {
      items.add(_item(context, model));
    });
    return Row( // 行排列
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items,
    );
  }

  Widget _item(BuildContext context, CommonModel model) {
    return GestureDetector( // 为组件添加点击事件
      onTap: (){

      },
      child: Column(
        children: <Widget>[
          Image.network(
            model.icon,
            height: 32,
            width: 32,
          ),
          Text(
            model.title,
            style: TextStyle(fontSize: 12),
          )
        ],
      ),
    );
  }
}

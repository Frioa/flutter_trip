import 'package:flutter/material.dart';
import 'package:flutter_trip/model/common_model.dart';
import 'package:flutter_trip/model/grid_nav_model.dart';
import 'package:flutter_trip/widget/webview.dart';

// 网格卡片
class GridNav extends StatelessWidget {
  // 1. 继承Widget
  final GridNavModel
      gridNavModel; // 必须是final 因为是继承 StatelessWidget, 父类使用了@immutable
  final String name;

  // 2.定义构造方法 @required 参数是必须的
  const GridNav({Key key, @required this.gridNavModel, this.name = 'name'})
      : super(key: key);

  // 3. build 方法
  @override
  Widget build(BuildContext context) {

    return PhysicalModel(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(6),// 圆角
      clipBehavior: Clip.antiAlias, // 裁切
      child: Column(
        children: _gridNavItems(context),
      ),
    );
  }

  _gridNavItems(BuildContext context) {
    List<Widget> items = [];
    if (gridNavModel == null) return items;
    if (gridNavModel.hotel != null) {
      // 上
      items.add(_gridNavItem(context, gridNavModel.hotel, true));
    }
    if (gridNavModel.flight != null) {
      // 中
      items.add(_gridNavItem(context, gridNavModel.flight, false));
    }
    if (gridNavModel.travel != null) {
      // 下
      items.add(_gridNavItem(context, gridNavModel.travel, false));
    }
    return items;
  }

  _gridNavItem(BuildContext context, GridNavItem gridNavItem, bool first) {
    List<Widget> items = [];
    items.add(_mainItem(context, gridNavItem.mainItem));
    items.add(_doubleItem(
      context,
      gridNavItem.item1,
      gridNavItem.item2,
    ));
    items.add(_doubleItem(
      context,
      gridNavItem.item3,
      gridNavItem.item4,
    ));
    List<Widget> expandItems = [];
    items.forEach((item) {
      expandItems.add(Expanded(child: item, flex: 1));
    });
    Color startColor = Color(int.parse('0xff' + gridNavItem.startColor));
    Color endColor = Color(int.parse('0xff' + gridNavItem.endColor));

    return Container(
      height: 88,
      margin: first ? null : EdgeInsets.only(top: 3),
      decoration: BoxDecoration(
          // 线性渐变
          gradient: LinearGradient(colors: [startColor, endColor])),
      child: Row(
        children: expandItems,
      ),
    );
  }

  _mainItem(BuildContext context, CommonModel model) {
    return _wrapGesture(
        context,
        Stack(
          alignment: AlignmentDirectional.topCenter,// 顶部居中
          children: <Widget>[
            Image.network(
              model.icon,
              fit: BoxFit.contain,
              height: 90, width: 121,
              alignment: AlignmentDirectional.bottomEnd, // 居中方式
            ),
            Container(
              margin: EdgeInsets.only(top: 12),
              child:  Text(
                model.title,
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            )

          ],
        ),
        model);
  }

  _doubleItem(
      BuildContext context, CommonModel topItem, CommonModel bottomItem) {
    return Column(
      children: <Widget>[
        Expanded(
          //
          child: _item(context, topItem, true),
        ),
        Expanded(
          child: _item(context, bottomItem, false),
        )
      ],
    );
  }

  _item(BuildContext context, CommonModel item, bool first) {
    BorderSide borderSize = BorderSide(width: 0.8, color: Colors.white);
    return FractionallySizedBox(
      // 撑满父布局宽度
      widthFactor: 1,
      child: Container(
        decoration: BoxDecoration(
            border: Border(
                left: borderSize,
                bottom: first ? borderSize : BorderSide.none)),
        child: _wrapGesture(
            context,
            Center(
              child: Text(
                item.title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            item),
      ),
    );
  }

  _wrapGesture(BuildContext context, Widget widget, CommonModel model) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WebView(
                      url: model.url,
                      statusBarColor: model.statusBarColor,
                      title: model.title,
                      hideAppBar: model.hideAppBar,
                    )));
      },
      child: widget,
    );
  }
}

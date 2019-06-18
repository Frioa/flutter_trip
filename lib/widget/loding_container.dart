import 'package:flutter/material.dart';


// 加载进度条组件
class LoadingContainer extends StatelessWidget {
  final Widget child; // 进度条后呈现的内容
  final bool isLoading; // 组件的状态，true 显示进度条
  final bool cover;

  const LoadingContainer(
      {Key key,
      @required this.isLoading,
      this.cover = false,
      @required this.child})
      : super(key: key); // 是否覆盖整个页面

  @override
  Widget build(BuildContext context) {
    return !cover
        ? isLoading ? _loadingView : child
        : Stack(
            children: <Widget>[child, isLoading ? _loadingView : null],
          );
  }

  Widget get _loadingView {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}

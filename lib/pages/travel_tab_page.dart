import 'package:flutter/material.dart';
import 'package:flutter_trip/dao/travel_dao.dart';
import 'package:flutter_trip/model/travel_model.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_trip/widget/cached_image.dart';
import 'package:flutter_trip/widget/loding_container.dart';
import 'package:flutter_trip/widget/webview.dart';


const PAGE_SIZE = 10;
const _TRAVEL_URL =
    'https://m.ctrip.com/restapi/soa2/16189/json/searchTripShootListForHomePageV2?_fxpcqlniredt=09031010211161114530&__gw_appid=99999999&__gw_ver=1.0&__gw_from=10650013707&__gw_platform=H5';

class TravelTabPage extends StatefulWidget {
  final String travelUrl;
  final String groupChannelCode;

  const TravelTabPage({Key key, this.travelUrl, this.groupChannelCode})
      : super(key: key); // 初始化父类构造方法

  @override
  _TravelTabPageState createState() => _TravelTabPageState();
}

class _TravelTabPageState extends State<TravelTabPage>
    with AutomaticKeepAliveClientMixin {
  List<TravelItem> travelItems;
  int pageIndex = 1;
  bool _loading = true;
  ScrollController _scrollController = ScrollController();// 下载加载控制器


  @override
  bool get wantKeepAlive => true;// 为了让tab一直保存在内存中，不被销毁

  @override
  void initState() {
    _loadData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadData(loadMore: true);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: LoadingContainer(
            // Loading
            isLoading: _loading,
            child: RefreshIndicator(
                // 下拉刷新
                child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: StaggeredGridView.countBuilder(
                      controller: _scrollController,
                      // 配置下拉加载更多
                      crossAxisCount: 2, // 横轴子元素的数量。此属性值确定后子元素在横轴的长度就确定了,即ViewPort横轴长度/crossAxisCount。
                      itemCount: travelItems?.length ?? 0,
                      itemBuilder: (BuildContext context, int index) =>
                          _TravelItem(index: index, item: travelItems[index]),
                      //  // 该属性可以控制当前 Cell 占用的空间大小, 用来实现瀑布的感觉
                      staggeredTileBuilder: (int index) =>
                          new StaggeredTile.fit(1),
                    )
                ),
                onRefresh: _handleRefresh
            )
        )
    );
  }

  void _loadData({loadMore = false}) {
    if (loadMore) {
      pageIndex++;
    } else {
      pageIndex = 1;
    }

    TravelDao.fetch(widget.travelUrl ?? _TRAVEL_URL, widget.groupChannelCode,
            pageIndex, PAGE_SIZE)
        .then((TravelItemModel model) {
      _loading = false;
      setState(() {
        List<TravelItem> items = _filterItems(model.resultList);
        if (travelItems != null) {
          travelItems.addAll(items);
        } else {
          travelItems = items;
        }

      });
    }).catchError((e) {
      _loading = false;
      print(e);
    });
  }

  List<TravelItem> _filterItems(List<TravelItem> resultList) {
    if (resultList == null) {
      return [];
    }
    List<TravelItem> filterItems = [];
    resultList.forEach((item) {
      if (item.article != null) {
        filterItems.add(item); // 移除article 为空的模型
      }
    });
    return filterItems;
  }

  Future<Null> _handleRefresh() async {
    _loadData();
    return null;
  } // 当前页面缓存
}

class _TravelItem extends StatelessWidget {
  final TravelItem item;
  final int index;

  const _TravelItem({Key key, this.item, this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (item.article.urls != null && item.article.urls.length > 0) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WebView(
                        url: item.article.urls[0].h5Url,
                        title: '详情',
                      )));
        }
      },
      child: Card(
        child: PhysicalModel(
          color: Colors.transparent,
          clipBehavior: Clip.antiAliasWithSaveLayer, // 裁切行为：使用锯齿裁切
          borderRadius: BorderRadius.circular(5),// 圆角
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 文字居左显示
            children: <Widget>[
              _itemImage(),
              Container(
                padding: EdgeInsets.all(5),
                child: Text(
                  item.article.articleTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,// 文字溢出
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              _infoText(),
            ],
          ),
        ),
      ),
    );
  }

  _itemImage() {
    return Stack(
      children: <Widget>[
        CachedImage(
          imageUrl: item.article.images[0]?.dynamicUrl,
          inSizedBox: true,
        ),
        Positioned(
          bottom: 8,
          left: 8,
          child: Container(
            padding: EdgeInsets.fromLTRB(5, 1, 5, 1),
            decoration: BoxDecoration(
                color: Colors.black54, borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 3),
                  child: Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
                LimitedBox(
                  maxWidth: 130,
                  child: Text(
                    _poiName(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis, // 文字最后的省略号
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  String _poiName() {
    return item.article.pois == null || item.article.pois.length == 0
        ? '未知'
        : item.article.pois[0]?.poiName ?? '未知';
  }

  _infoText() {
    return Container(
      padding: EdgeInsets.fromLTRB(6, 0, 6, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              PhysicalModel(
                color: Colors.transparent,
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item.article.author?.coverImage?.dynamicUrl,
                  width: 24,
                  height: 24,
                ),
              ),
              Container(
                padding: EdgeInsets.all(5),
                width: 90,
                child: Text(
                  item.article.author?.nickName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Icon(
                Icons.thumb_up,
                size: 14,
                color: Colors.grey,
              ),
              Padding(
                padding: EdgeInsets.only(left: 3),
                child: Text(
                  item.article.likeCount.toString(),
                  style: TextStyle(fontSize: 10),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

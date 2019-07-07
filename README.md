# flutter_trip

感谢[Flutter从入门到进阶 实战携程网App](https://coding.imooc.com/class/321.html?mc_marking=a7b3119105f0cbb234506fc15f6bfbc4&mc_channel=syb8)这门课程让我入门了Flutter
## 目录
- 效果展示
- 首页实现
- 搜索页面实现
- 语音页面
- 旅拍页面
- DAO层设计
- 启动屏
- Widget
- 自定义Widget
- 第三方Widget
## 效果展示
![功能展示.png](https://upload-images.jianshu.io/upload_images/14297357-7c02d83bffefbd47.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
##首页实现
>根布局使用`Scaffold`，这个是[material](https://github.com/flutterchina/flutter-in-action/blob/master/docs/chapter5/material_scaffold.md)包下的组件，它是一个路由页的骨架，可以非常容易的拼装出一个完整的页面。
>
>**1. AppBar滚动渐变**
>当滑动ListView的时候，顶部的AppBar随着滚动改变布局样式。
>
>- **NotificationListener：**监听列表滚动通过`onNotification()` 方法回调，检查`child`元素滚动情况。
>
>- 检测到滚动调用`_onScroll(pixels)`，得到滚动的`pixels`与`APPBAR_SCROLL_OFFSET`**(滚动超过这个值，控件不透明)**的比值 `alpha`，如果alpha<0设置`alpha = 0`，alpha>1设置`alpha = 1`，通过`setState`重新`build()`
>>**小结**
>>`1.setState()：`改方法只会对`StatefulWidget`类有用，并且重`Build()`，这个过程不会整个视图diss掉再从新绘制。而是调用了build方法，绘制只是绘制不一样的地方。
>>
>>`2.NotificationListener优化点：`除了判断检查child控件是滚动的情况之外，加载判断滚动的深度`depth=0`优化，防止检测到child中控件滚动情况，造成ListView卡顿现象。
>>`3. Opacity：`为首页AppBar的控制透明度控件，decoration为BoxDecoration(), child为Container，设置Padding防止与系统栏冲突。
>
## 搜索页面
 >顶部是搜索Widget搜索页面，底部是ListView的。
>- **Item中的图片：**定义了常量，用于判断加载ListView那些图片（图片类型固定，服务器只下发图片类型）。
>- **ListView数据动态更新**：监听输入文本的变化，更新ListView的数据。
>- **富文本**通过RichText与textSpan，将字符串按照keyword分割成数组，再将不同TestStyle的文本加入textSpan。
>- 使用Expande控件，ListView需要设置Padding
>>**小结**
>>`1. ListView.builder`利用IndexedWidgetBuilder来按需构造。这个构造函数适合于具有大量（或无限）子视图的列表视图，因为构建器只对那些实际可见的子视图调用。
>>`2. ListView加载数据的优化：`提交网络请求时保存一个`keyWord(关键字)`，当网络成功时候回调，与当前的`keyWord`比较如果一样则`setState()`。减少数据加载的次数，同时解决列表显示与keyWord无关的数据。
>## 语音页面
> Flutter现在还没有相关的SDK，所以利用Flutter与Native端的通信，Native集成了百度语音的SDK，实现语音识别。
>- Dart端通过 `MethodChannel`的方法调用`Native`端
>- Native端自定义了Flutter的Plugin，专门集成百度SDK使用。
>- SpeakPage使用了动画，继承自`AnimatedWidget`，构建一个圆形的图形设置动画相关的参数，初始化一个监听，监听动画执行完毕反向执行，动画回到初始位置重新开始动画。
- ##旅拍页面
>顶部的TabBar，下方是瀑布流照片墙。
>**1. TabBar的实现：**TabBar的_controller，控制Tab显示的Item数量，这里_controller需要初始化两次，initState一次，网络数据获取成功一次，防止null的异常。with `SingleTickerProviderStateMixin`实现Tab动画切换效果
>**2. TabBarView：**与TabBar配合使用，切换Tab的时候会重新生成TabBarView达到切换的效果，with `AutomaticKeepAliveClientMixin `实现缓存功能，提高用户体验。上拉加载与下拉刷新控件的使用。采用cacheImage加载图片，实现图片缓存。
>
>
## DAO层的设计
>####1. Dao设计
> **1.1 get请求**
> 请求流程：http库**异步**发起Get请求，判断状态码200并处理乱码，将得到的内容序列化`Dart`实体。
> **1.2 POST请求**`TODO`
> 请求流程：post请求需要携带请求参数`Params`，通过构造方法改变请求参数的内容。
> **1.3 首页调用**
> 使用async方法await关键字，发起异步请求并捕捉异常，或者通过.then()的方式，并捕捉异常。
>####2. Model设计
>**2.1 简单Model实现**
> 添加成员变量，声明Dart可变构造函数，创建一个`factory` 的fromJson()方法转化为实体。
>**2.2 复杂Model实现**
> 复杂Model的实现，在于成员变量是`List<Model>`，在fromJson()方法需要通过`map((i) => CommonModel.fromJson(i)).toList()`转化为List即可。
>>**小结**
>>`1. 乱码处理:`Utf8Decoder utf8decoder  = Utf8Decoder();修复中文乱码问题。
>> `2.factory 关键字:`我们在实现一个构造函数时使用`factory`关键字时，这个构造函数不会总是创建其类的新实例
>> `3.toJson() :`当需要打印实体信息的时候需要写toJson()方法，将`Model转化成Map`对象即可。
>> `4.async与await:`当遇到有需要延迟的运算（async）时，将其放入到延迟运算的队列（await）中去，把不需要延迟运算的部分先执行掉，最后再来处理延迟运算的部分。
## 启动屏
> 由于启动App的时候会加载FlutterSDK等会造成App有短暂的白屏时间，所以需要制作一个启动屏幕来掩盖白屏。
> - 通过runOnUiThread方法加载Dialog显示启动屏，最后通知主线程更新
>- 防止Activity内存泄漏使用软引用持有activty。
>- 在onCreat()方法中调用显示启动屏
>- 在Native中通过实现`MethodCallHandler`，在Flutter中关闭启动屏。
##Widget
Opacity
> Opacity控件能调整子控件的不透明度，使子控件部分透明，不透明度的量从0.0到1.0之间，0.0表示完全透明，1.0表示完全不透明。
##自定义Widget
WebView
>**1. 防止用户多次点击WebView造成重复打开**
>- 在`initState()`中，获得WebView的引用用来关闭，
>
>**2. 监听WebView State状态判断是否是主页**
>- 当State发生改变的时候判断URL是否是白名单中URL的结尾。如果是主页那么返回APP的上一层。
>- 需要设置**exiting bool变量**防止重复返回。（防止用户多次按返回键直接退出应用） 
>
> **3. dispose() 导致WebView中的Back键失效**
> 需要在，`super.dipose()` 之前关闭各个监听
>
> **4. appBar加载策略**
> - 判断hideAppBar，判断是否隐藏AppBar
>- 添加Padding，解决**AppBar在系统栏**。
>- Stack布局包裹
>- AppBar的颜色，判断是否有背景颜色，无背景颜色设置为黑色。
>
> **5. WebView布局加载**
>- Expanded Wiget控件将WebView控件撑满剩下的空间。
>- `initialChild`属性显示加载页面
>
- SearchBar
>SearchBar 有三种状态，首页状态，正常状态。
> - 首页状态，有地区并且滑动时候改变背景颜色，根据不同的状态加载不同的布局。
>- 获得`TextEditingController`用来得到语音搜索的结果，更新TextEdit。
>- 对点击事件做了封装，`_warp(widget,callback)` 点击事件由外部传入，方便进入语音页面或者搜索页面。

- grid_nav网格卡片布局
>一个无状态的`StatelessWidget`
> - PhysicalModel，设置圆角并设置线性渐变。
> - 整个grid分成三块，每一块中再次分为三块，依次是主item，两个次item
- localNav首页求需入口
>- UI不需要更新，继承自StatelessWidget
>- 成员变量必须是`final`
>- BoxDecoration装饰器设置四周圆角，child使用了Row Widget设置`mainAxisAlignment`排列方式
>>**小结**
>>1. `为什么成员变量必须是final`：继承自Widget，Widget使用了@immutable注解，成员变量必须是final类型的
- subNav
> - 首先计算每一行显示多少个item
> - Row 排列 `mainAxisAlignment: MainAxisAlignment.spaceBetween,`
> - 点击事件调用WebView
- salesBox底部卡片布局
>- 计算图片的大小，获得屏幕的宽/2-10(padding)，高值写死。
- loadingNav
>- 类中传递一个Widget，bool值判断是否显示loading
>- 在首页的setState中改变bool，控制显示隐藏loading页面

## 第三方Widget
>Banner
> `package:flutter_swiper/flutter_swiper.dart`
> - 使用高度为160的Container包裹Widget
>
> **如何设计Banner**
>- 最外层FrameLayout，里面一个`ViewPager`和`LinearLayout`（indicator）
>- ViewPager与pagerAdapter配合使用
>- ViewPager的中Banner数目，应该是总数+2
>- 图片需要异步加载
>- 需要一个Hander通知自动换页。
>- 指示器与ViewPager交互

## 打包
> - 开启混淆，减小APK大小
> - 选择App支持的架构
>```
>  ndk {
>            abiFilters "arm64-v8a", "x86_64", "x86" // 只打包flutter所支持的架构
>            //abiFilters "armeabi-v7a"// release
>        }
>```

## 参考资料
- [Flutter原理与美团的实践](https://blog.csdn.net/MeituanTech/article/details/81567238)
- [Flutter之BoxDecoration用法详解](https://www.jianshu.com/p/9012bc9e2feb)
- [flutter实战5：异步async、await和Future的使用技巧](https://juejin.im/post/5ad33bcaf265da238d512840)
- [线性布局Row和Column](https://github.com/flutterchina/flutter-in-action/blob/master/docs/chapter4/row_and_column.md)
- [flutter widget： ListView](https://www.jianshu.com/p/9830b1a6ae1f)
- [flutter控件Flexible和 Expanded的区别](https://blog.csdn.net/chunchun1230/article/details/82460257)
- [深入理解Flutter Platform Channel](https://juejin.im/post/5b84ff6a6fb9a019f47d1cc9)



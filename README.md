# Gankee

[![CI Status](http://img.shields.io/travis/Wildog/Gankee.svg?style=flat)](https://travis-ci.org/Wildog/Gankee)
[![Tag](https://img.shields.io/github/tag/Wildog/Gankee.svg?style=flat)](https://github.com/Wildog/Gankee)
[![App Store](https://img.shields.io/badge/app_store-v1.0.2-orange.svg?style=flat)](https://itunes.apple.com/cn/app/gankee-gan-huo-ji-zhong-ying/id1201113401?mt=8)
[![Language](https://img.shields.io/badge/language-objc-blue.svg?style=flat)](https://github.com/Wildog/Gankee)
[![License](https://img.shields.io/github/license/Wildog/Gankee.svg?style=flat)](https://github.com/Wildog/Gankee/blob/master/LICENSE)

可能是 iOS 上最好用的 Gank.io 客户端，已上架 [App Store](https://itunes.apple.com/cn/app/gankee-gan-huo-ji-zhong-ying/id1201113401?mt=8)

<img src="https://github.com/Wildog/Gankee/raw/master/screenshots/news.jpg" width="25%">
<img src="https://github.com/Wildog/Gankee/raw/master/screenshots/category.PNG" width="25%">
<img src="https://github.com/Wildog/Gankee/raw/master/screenshots/favorite.PNG" width="25%">
<img src="https://github.com/Wildog/Gankee/raw/master/screenshots/search.PNG" width="25%">
<img src="https://github.com/Wildog/Gankee/raw/master/screenshots/share-extension.jpg" width="25%">
<img src="https://github.com/Wildog/Gankee/raw/master/screenshots/spotlight.jpg" width="25%">

## Features

- 每日干货支持日期选择，想看哪天点哪天
- 随机推荐轮播，不满意？随时下拉换一批
- 支持分类查看和分类搜索，找干货不再是痛
- 支持本地收藏并同步至 iCloud，收藏还支持应用内搜索和 Spotlight 搜索，再也不怕错过干货
- 全面支持 3D Touch，任意条目均可在预览时上拉进行快速收藏和分享，主屏幕图标重压可直达各个板块
- 支持提交干货，应用内提交或者更方便的 Share Sheet 提交任你选择
- 使用 SFSafariViewController 阅读干货，方便添加书签和使用自带的阅读器模式

觉得好用？支付宝给个打赏：

![](http://7xqhhm.com1.z0.glb.clouddn.com/donate.jpg)

## Details

纯 OC 项目，轻量化设计，大部分使用 MVVM 模式开发，重度依赖 ReactiveObjC，自己写了加载动画和分页控件，轮播基于 SDCycleScrollView 修改，创建了 SFSafariViewController 的子类用来展示网页并加入自定义的 3D Touch Preview Actions 和用于收藏/取消收藏的 UIActivity，数据存储方面使用 Core Data 和 iCloud 集成，依赖 MagicalRecord，Spotlight 索引用的是 WACoreDataSpotlight。

App 还待完善，欢迎提交各种 PR。

## Requirements

- Xcode 8+
- iOS 9.0+

## TODO

- [ ] 夜间模式/主题切换
- [ ] Today Widget
- [x] ~~Spotlight 搜索加入缩略图~~
- [x] ~~加入手动重建 Spotlight 索引选项~~
- [ ] UI Testing

## Changelog

### v1.1.0
1. Spotlight 索引和收藏夹列表加入缩略图显示
2. 收藏过的干货会在列表上显示标记了
3. 支持从 Chrome 中直接分享干货了

### v1.0.2

1. 添加手动重建 Spotlight 索引选项
2. 分页控件标题跟随滑动渐变

### v1.0.1

1. 修复通过 iCloud 同步过来的收藏不会自动建立 Spotlight 索引的问题
2. 改善日期显示

## Credit

[Gank.io API](http://gank.io/api) by [daimajia](https://github.com/daimajia)

## Author

Wildog, i@wil.dog

## License

Gankee is available under the BSD 3-clause Clear License. See the LICENSE file for more info.

Any modified version of Gankee CANNOT be uploaded to App Store. If you are eager to make contributions, please send pull requests instead.

import 'package:flutter/material.dart';

import 'FirstRightEdgeAlignScrollPhysics.dart';


/// date: 2019-12-24 10:08
/// author: bruce.zhang
/// description: 自定义banner效果
/// 一屏展示两个banner,最后一个靠右，其余都靠左
///
/// 使用方式：
/// Swiper(
///   pageSnapping: false,
///   physics: FirstRightEdgeAlignScrollPhysics(viewportFraction: 0.8, itemCount: 5),
///
///   loop: false,
///   scale:1.0,
///   fade:0.8,
///   viewportFraction: 0.8,
///   itemBuilder: (c, i) {
///     return Padding(child: Container(
///       color: Colors.grey,
///       child: Text("$i"),
///     ), padding: const EdgeInsets.only(left: 5, right: 5));
///   },
///   itemCount: 5,
///   pagination: new SwiperPagination(),
///   ),
///
/// modification history:
class LeftAlignScrollPhysics extends FirstRightEdgeAlignScrollPhysics {

  // 上一个item可见宽度
  final double lastItemVisibleWidth;

  LeftAlignScrollPhysics({this.lastItemVisibleWidth = 0, viewportFraction = 1.0, itemCount = 0, ScrollPhysics parent})
      : super(viewportFraction: viewportFraction, itemCount: itemCount, parent: parent);

  @override
  LeftAlignScrollPhysics applyTo(ScrollPhysics ancestor) {
    return LeftAlignScrollPhysics(lastItemVisibleWidth: lastItemVisibleWidth, viewportFraction: viewportFraction,
        itemCount: itemCount, parent: buildParent(ancestor));
  }

  @override
  double getPixels(ScrollPosition position, double page, double portion) {
    if (page < 1) {
      return portion;
    } else if (page == itemCount - 1) {
      return (page * getItemWidth(position)) - portion;
    } else {
      return (page * getItemWidth(position)) + portion - lastItemVisibleWidth;
    }
  }

}
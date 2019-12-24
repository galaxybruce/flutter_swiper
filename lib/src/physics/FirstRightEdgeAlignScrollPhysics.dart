import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'dart:math' as math;

/// date: 2019-12-24 10:14
/// author: bruce.zhang
/// description: 自定义banner效果
/// 一屏展示两个banner,第一个靠左，最后一个靠右，其余居中
///
/// modification history:
class FirstRightEdgeAlignScrollPhysics extends BouncingScrollPhysics {
  final double viewportFraction;
  final int itemCount;

  FirstRightEdgeAlignScrollPhysics({this.viewportFraction = 1.0, this.itemCount = 0, ScrollPhysics parent})
      : super(parent: parent);

  @override
  FirstRightEdgeAlignScrollPhysics applyTo(ScrollPhysics ancestor) {
    return FirstRightEdgeAlignScrollPhysics(viewportFraction: viewportFraction,
        itemCount: itemCount, parent: buildParent(ancestor));
  }

  double getPage(ScrollPosition position, double portion) {
    // 这里的position.pixels不能增加portion或者减小portion，不然翻页边界会受到影响
    return (position.pixels) / getItemWidth(position);
  }

  double getPixels(ScrollPosition position, double page, double portion) {
    if(page < 1) {
      return portion;
    } else if(page == itemCount - 1) {
      return (page * getItemWidth(position)) - portion;
    } else {
      return (page * getItemWidth(position));
    }
  }

  double getItemWidth(ScrollPosition position) {
    return position.viewportDimension * viewportFraction;
  }

  double _getTargetPixels(ScrollPosition position,
      Tolerance tolerance,
      double velocity,
      double portion,) {
    double page = getPage(position, portion);
    if (velocity < -tolerance.velocity) {
      page -= 0.5;
    } else if (velocity > tolerance.velocity) {
      page += 0.5;
    }
    double target = getPixels(position, page.roundToDouble(), portion);
    target = math.min(math.max(portion, target), position.maxScrollExtent - portion);
    return target;
  }

  @override
  Simulation createBallisticSimulation(ScrollMetrics position,
      double velocity) {
    final portion = (position.viewportDimension - getItemWidth(position)) / 2;
    final Tolerance tolerance = this.tolerance;
    final double target = _getTargetPixels(position, tolerance, velocity, portion);

    // If we're out of range and not headed back in range, defer to the parent
    // ballistics, which should put us back in range at a page boundary.
//    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
//        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
////      return super.createBallisticSimulation(position1, velocity);
//      return SpringSimulation(spring, position.pixels, target, velocity,
//          tolerance: tolerance);
//    }

    if (target != position.pixels)
      return ScrollSpringSimulation(spring, position.pixels, target, velocity,
          tolerance: tolerance);
    return null;
  }



  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    assert(offset != 0.0);
    assert(position.minScrollExtent <= position.maxScrollExtent);

    final double itemWidth = getItemWidth(position);
    final portion = (position.viewportDimension - itemWidth) / 2;

    if (position.pixels > position.minScrollExtent + portion && position.pixels < position.maxScrollExtent - portion)
      return offset;

    final double overscrollPastStart = math.max(position.minScrollExtent - position.pixels + portion, 0.0);
    final double overscrollPastEnd = math.max(position.pixels - position.maxScrollExtent - portion, 0.0);
    final double overscrollPast = math.max(overscrollPastStart, overscrollPastEnd);
    final bool easing = (overscrollPastStart > 0.0 && offset < 0.0)
        || (overscrollPastEnd > 0.0 && offset > 0.0);

    final double friction = easing
    // Apply less resistance when easing the overscroll vs tensioning.
        ? frictionFactor((overscrollPast - offset.abs()) / itemWidth)
        : frictionFactor(overscrollPast / itemWidth);
    final double direction = offset.sign;

    return direction * _applyFriction(overscrollPast, offset.abs(), friction);
  }

  static double _applyFriction(double extentOutside, double absDelta, double gamma) {
    assert(absDelta > 0);
    double total = 0.0;
    if (extentOutside > 0) {
      final double deltaToLimit = extentOutside / gamma;
      if (absDelta < deltaToLimit)
        return absDelta * gamma;
      total += extentOutside;
      absDelta -= deltaToLimit;
    }
    return total + absDelta;
  }
}
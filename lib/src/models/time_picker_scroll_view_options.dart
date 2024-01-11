import 'package:flutter/material.dart';

class TimePickerScrollViewOptions {
  const TimePickerScrollViewOptions({
    this.hour = const ScrollViewDetailOptions(margin: EdgeInsets.all(4)),
    this.minute = const ScrollViewDetailOptions(margin: EdgeInsets.all(4)),
    this.second = const ScrollViewDetailOptions(margin: EdgeInsets.all(4)),
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  final ScrollViewDetailOptions hour;
  final ScrollViewDetailOptions minute;
  final ScrollViewDetailOptions second;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  // Applies the given [ScrollViewDetailOptions] to all three options ie. year, month and day.
  static TimePickerScrollViewOptions all(ScrollViewDetailOptions value) {
    return TimePickerScrollViewOptions(
      hour: value,
      minute: value,
      second: value,
    );
  }
}

class ScrollViewDetailOptions {
  const ScrollViewDetailOptions({
    this.label = '',
    this.alignment = Alignment.centerLeft,
    this.margin,
    this.selectedTextStyle =
    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    this.textStyle =
    const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
  });

  /// The text printed next to the year, month, and day.
  final String label;

  /// The year, month, and day text alignment method.
  final Alignment alignment;

  /// The amount of space that can be added to the year, month, and day.
  final EdgeInsets? margin;

  /// An immutable style describing how to format and paint text.
  final TextStyle textStyle;

  /// An invariant style that specifies the selected text format and explains how to draw it.
  final TextStyle selectedTextStyle;
}
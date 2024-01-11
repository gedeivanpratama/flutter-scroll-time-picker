import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/time_picker_options.dart';
import '../models/time_picker_scroll_view_options.dart';

class TimeScrollView extends StatelessWidget {
  const TimeScrollView({
    Key? key,
    required this.onChanged,
    required this.times,
    required this.controller,
    required this.options,
    required this.scrollViewOptions,
    required this.selectedIndex,
  }) : super(key: key);

  /// A controller for scroll views whose items have the same size.
  final FixedExtentScrollController controller;

  /// On optional listener that's called when the centered item changes.
  final ValueChanged<int> onChanged;

  /// This is a list of dates.
  final List times;

  /// A set that allows you to specify options related to ListWheelScrollView.
  final TimePickerOptions options;

  /// A set that allows you to specify options related to ScrollView.
  final ScrollViewDetailOptions scrollViewOptions;

  /// The currently selected date index.
  final int selectedIndex;

  double _getScrollViewWidth(BuildContext context) {
    String _longestText = '';
    List _times = times;
    for (var text in _times) {
      if ('$text'.length > _longestText.length) {
        _longestText = '$text'.padLeft(2, '0');
      }
    }
    _longestText += scrollViewOptions.label;
    final TextPainter _painter = TextPainter(
      text: TextSpan(
        style: scrollViewOptions.selectedTextStyle,
        text: _longestText,
      ),
      textDirection: Directionality.of(context),
    );
    _painter.layout();
    return _painter.size.width + 8.0;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int _maximumCount = constraints.maxHeight ~/ options.itemExtent;
        return Container(
          margin: scrollViewOptions.margin,
          width: _getScrollViewWidth(context),
          child: ListWheelScrollView.useDelegate(
            itemExtent: options.itemExtent,
            diameterRatio: options.diameterRatio,
            controller: controller,
            physics: const FixedExtentScrollPhysics(),
            perspective: options.perspective,
            onSelectedItemChanged: onChanged,
            childDelegate: options.isLoop && times.length > _maximumCount
                ? ListWheelChildLoopingListDelegate(
              children: List<Widget>.generate(
                times.length,
                    (index) => _buildDateView(index: index),
              ),
            )
                : ListWheelChildListDelegate(
              children: List<Widget>.generate(
                times.length,
                    (index) => _buildDateView(index: index),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateView({required int index}) {
    return Container(
      alignment: scrollViewOptions.alignment,
      child: Text(
        '${times[index]}${scrollViewOptions.label}',
        style: selectedIndex == index
            ? scrollViewOptions.selectedTextStyle
            : scrollViewOptions.textStyle,
      ),
    );
  }
}
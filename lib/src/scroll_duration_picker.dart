import 'package:flutter/material.dart';
import 'package:scroll_time_picker/src/widgets/time_scroll_view.dart';

import 'models/time_picker_options.dart';
import 'models/time_picker_scroll_view_options.dart';

class ScrollDurationPicker extends StatefulWidget {
  const ScrollDurationPicker({
    Key? key,
    required this.selectedTime,
    required this.onDateTimeChanged,
    this.options = const TimePickerOptions(),
    this.viewType = const [
      DurationPickerViewType.hour,
      DurationPickerViewType.minute,
    ],
    this.scrollViewOptions = const TimePickerScrollViewOptions(),
    this.indicator,
    this.divider,
    this.is12hFormat = false,
  }) : super(key: key);

  /// A list that allows you to specify the type of date view.
  /// And also the order of the viewType in list is the order of the date view.
  /// If this list is null, the default order of locale is set.
  final List<DurationPickerViewType> viewType;

  /// Currently selected time.
  final DateTime selectedTime;

  /// On optional listener that's called when the centered item changes.
  final ValueChanged<DateTime> onDateTimeChanged;

  /// A set that allows you to specify options related to ListWheelScrollView.
  final TimePickerOptions options;

  /// A set that allows you to specify options related to ScrollView.
  final TimePickerScrollViewOptions scrollViewOptions;

  /// Indicator displayed in the center of the ScrollDatePicker
  final Widget? indicator;

  /// Whether to use 12 hour format.
  final bool is12hFormat;

  /// add divider between hour and minutes
  final Widget? divider;

  @override
  State<ScrollDurationPicker> createState() => _ScrollDurationPickerState();
}

class _ScrollDurationPickerState extends State<ScrollDurationPicker> {
  /// This widget's hour selection and animation state.
  late FixedExtentScrollController _hourController;

  /// This widget's minute selection and animation state.
  late FixedExtentScrollController _minuteController;

  late Widget _hourScrollView;
  late Widget _minuteScrollView;

  late DateTime _selectedTime;
  bool isHourScrollable = true;
  bool isMinuteScrollable = true;
  bool isSecondScrollable = true;
  List<int> _hours = [];
  List<int> _minutes = [];

  int get _contains12hFormat {
    if (_selectedTime.hour > 12) {
      return _selectedTime.hour - 12;
    } else if (_selectedTime.hour == 0) {
      return 12;
    } else {
      return _selectedTime.hour;
    }
  }

  int get selectedHourIndex => !_hours.contains(
          widget.is12hFormat ? _contains12hFormat : _selectedTime.hour)
      ? 0
      : _hours.indexOf(
          widget.is12hFormat ? _contains12hFormat : _selectedTime.hour);

  int get selectedMinuteIndex => !_minutes.contains(_selectedTime.minute)
      ? 0
      : _minutes.indexOf(_selectedTime.minute);

  int get selectedHour => _hours[_hourController.selectedItem % _hours.length];

  int get selectedMinute =>
      _minutes[_minuteController.selectedItem % _minutes.length];

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.selectedTime;

    _hours = [for (int i = 1; i < 100; i++) i];
    _minutes = [for (int i = 0; i < 60; i++) i];

    _hourController = FixedExtentScrollController(
      initialItem: selectedHourIndex,
    );
    _minuteController = FixedExtentScrollController(
      initialItem: selectedMinuteIndex,
    );
  }

  @override
  void didUpdateWidget(covariant ScrollDurationPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedTime != widget.selectedTime) {
      _selectedTime = widget.selectedTime;
      isMinuteScrollable = false;
      isSecondScrollable = false;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          _hourController.animateToItem(
            selectedHourIndex,
            curve: Curves.ease,
            duration: const Duration(microseconds: 500),
          );
          _minuteController.animateToItem(
            selectedMinuteIndex,
            curve: Curves.ease,
            duration: const Duration(microseconds: 500),
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  void _initTimeScrollView() {
    _hourScrollView = TimeScrollView(
        key: const Key('hour'),
        times: _hours.map((hour) => hour.toString().padLeft(2, '0')).toList(),
        controller: _hourController,
        options: widget.options,
        scrollViewOptions: widget.scrollViewOptions.hour,
        selectedIndex: selectedHourIndex,
        onChanged: (_) {
          _onDateTimeChanged();
          isHourScrollable = true;
        });
    _minuteScrollView = TimeScrollView(
        key: const Key('minute'),
        times: _minutes
            .map((minute) => minute.toString().padLeft(2, '0'))
            .toList(),
        controller: _minuteController,
        options: widget.options,
        scrollViewOptions: widget.scrollViewOptions.minute,
        selectedIndex: selectedMinuteIndex,
        onChanged: (_) {
          _onDateTimeChanged();
          isMinuteScrollable = true;
        });
  }

  void _onDateTimeChanged() {
    int selectedHour = _selectedTime.hour;
    int selectedMinute = _selectedTime.minute;
    int selectedSecond = _selectedTime.second;

    if (widget.viewType.contains(DurationPickerViewType.hour)) {
      selectedHour = selectedHour;
    }
    if (widget.viewType.contains(DurationPickerViewType.minute)) {
      selectedMinute = selectedMinute;
    }

    _selectedTime = DateTime(
      _selectedTime.year,
      _selectedTime.month,
      _selectedTime.day,
      selectedHour,
      selectedMinute,
      selectedSecond,
    );

    widget.onDateTimeChanged(_selectedTime);
  }

  List<Widget> _getScrollDurationPicker() {
    _initTimeScrollView();
    final viewList = <Widget>[];

    for (final viewType in widget.viewType) {
      switch (viewType) {
        case DurationPickerViewType.hour:
          viewList.add(_hourScrollView);
          break;
        case DurationPickerViewType.minute:
          viewList.add(_minuteScrollView);
          break;
      }
    }

    if (widget.divider != null) {
      viewList.insert(1, widget.divider!);
    }

    return viewList;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          mainAxisAlignment: widget.scrollViewOptions.mainAxisAlignment,
          crossAxisAlignment: widget.scrollViewOptions.crossAxisAlignment,
          children: _getScrollDurationPicker(),
        ),
        // Time Picker Indicator
        IgnorePointer(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        widget.options.backgroundColor,
                        widget.options.backgroundColor.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
              widget.indicator ??
                  Container(
                    height: widget.options.itemExtent,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.15),
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        widget.options.backgroundColor.withOpacity(0.7),
                        widget.options.backgroundColor,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum DurationPickerViewType { hour, minute }

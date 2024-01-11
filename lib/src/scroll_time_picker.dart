import 'package:flutter/material.dart';
import 'package:scroll_time_picker/src/widgets/time_scroll_view.dart';

import 'models/time_picker_options.dart';
import 'models/time_picker_scroll_view_options.dart';

class ScrollTimePicker extends StatefulWidget {
  const ScrollTimePicker({
    Key? key,
    required this.selectedTime,
    required this.onDateTimeChanged,
    this.options = const TimePickerOptions(),
    this.viewType,
    this.scrollViewOptions = const TimePickerScrollViewOptions(),
    this.indicator,
  }) : super(key: key);

  /// A list that allows you to specify the type of date view.
  /// And also the order of the viewType in list is the order of the date view.
  /// If this list is null, the default order of locale is set.
  final List<TimePickerViewType>? viewType;

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

  /// TODO("Aziz Anwar"): Add support for 12h format.
  // bool is24hFormat;

  @override
  State<ScrollTimePicker> createState() => _ScrollTimePickerState();
}

class _ScrollTimePickerState extends State<ScrollTimePicker> {
  /// This widget's hour selection and animation state.
  late FixedExtentScrollController _hourController;

  /// This widget's minute selection and animation state.
  late FixedExtentScrollController _minuteController;

  /// This widget's second selection and animation state.
  late FixedExtentScrollController _secondController;

  late Widget _hourScrollView;
  late Widget _minuteScrollView;
  late Widget _secondScrollView;

  late DateTime _selectedTime;
  bool isHourScrollable = true;
  bool isMinuteScrollable = true;
  bool isSecondScrollable = true;
  List<int> _hours = [];
  List<int> _minutes = [];
  List<int> _seconds = [];

  int get selectedHourIndex => !_hours.contains(_selectedTime.hour)
      ? 0
      : _hours.indexOf(_selectedTime.hour);

  int get selectedMinuteIndex => !_minutes.contains(_selectedTime.minute)
      ? 0
      : _minutes.indexOf(_selectedTime.minute);

  int get selectedSecondIndex => !_seconds.contains(_selectedTime.second)
      ? 0
      : _seconds.indexOf(_selectedTime.second);

  int get selectedHour => _hours[selectedHourIndex % _hours.length];

  int get selectedMinute => _minutes[selectedMinuteIndex % _minutes.length];

  int get selectedSecond => _seconds[selectedSecondIndex % _seconds.length];

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.selectedTime;

    _hours = [for (int i = 0; i < 24; i++) i];
    _minutes = [for (int i = 0; i < 60; i++) i];
    _seconds = [for (int i = 0; i < 60; i++) i];

    _hourController =
        FixedExtentScrollController(initialItem: selectedHourIndex);
    _minuteController =
        FixedExtentScrollController(initialItem: selectedMinuteIndex);
    _secondController =
        FixedExtentScrollController(initialItem: selectedSecondIndex);
  }

  @override
  void didUpdateWidget(covariant ScrollTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedTime != widget.selectedTime) {
      _selectedTime = widget.selectedTime;
      isMinuteScrollable = false;
      isSecondScrollable = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _hourController.animateToItem(selectedHourIndex,
            curve: Curves.ease, duration: const Duration(microseconds: 500));
        _minuteController.animateToItem(selectedMinuteIndex,
            curve: Curves.ease, duration: const Duration(microseconds: 500));
        _secondController.animateToItem(selectedSecondIndex,
            curve: Curves.ease, duration: const Duration(microseconds: 500));
      });
    }
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _secondController.dispose();
    super.dispose();
  }

  void _initTimeScrollView() {
    _hourScrollView = TimeScrollView(
        key: const Key('hour'),
        times: _hours,
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
        times: _minutes,
        controller: _minuteController,
        options: widget.options,
        scrollViewOptions: widget.scrollViewOptions.minute,
        selectedIndex: selectedMinuteIndex,
        onChanged: (_) {
          _onDateTimeChanged();
          isMinuteScrollable = true;
        });
    _secondScrollView = TimeScrollView(
        key: const Key('second'),
        times: _seconds,
        controller: _secondController,
        options: widget.options,
        scrollViewOptions: widget.scrollViewOptions.second,
        selectedIndex: selectedSecondIndex,
        onChanged: (_) {
          _onDateTimeChanged();
          isSecondScrollable = true;
        });
  }

  void _onDateTimeChanged() {
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

  List<Widget> _getScrollTimePicker() {
    _initTimeScrollView();

    if (widget.viewType?.isNotEmpty ?? false) {
      final viewList = <Widget>[];

      for (final viewType in widget.viewType!) {
        switch (viewType) {
          case TimePickerViewType.hour:
            viewList.add(_hourScrollView);
            break;
          case TimePickerViewType.minute:
            viewList.add(_minuteScrollView);
            break;
          case TimePickerViewType.second:
            viewList.add(_secondScrollView);
            break;
        }
      }
      return viewList;
    }

    return [_hourScrollView, _minuteScrollView, _secondScrollView];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          mainAxisAlignment: widget.scrollViewOptions.mainAxisAlignment,
          crossAxisAlignment: widget.scrollViewOptions.crossAxisAlignment,
          children: _getScrollTimePicker(),
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

enum TimePickerViewType { hour, minute, second }

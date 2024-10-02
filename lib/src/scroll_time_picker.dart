import 'package:flutter/material.dart';
import 'package:scroll_time_picker/src/widgets/time_scroll_view.dart';

import 'constants.dart';
import 'models/time_picker_options.dart';
import 'models/time_picker_scroll_view_options.dart';

class ScrollTimePicker extends StatefulWidget {
  const ScrollTimePicker({
    Key? key,
    required this.selectedTime,
    required this.onDateTimeChanged,
    this.options = const TimePickerOptions(),
    this.viewType = const [TimePickerViewType.hour, TimePickerViewType.minute],
    this.scrollViewOptions = const TimePickerScrollViewOptions(),
    this.indicator,
    this.divider,
    this.is12hFormat = false,
  }) : super(key: key);

  /// A list that allows you to specify the type of date view.
  /// And also the order of the viewType in list is the order of the date view.
  /// If this list is null, the default order of locale is set.
  final List<TimePickerViewType> viewType;

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
  State<ScrollTimePicker> createState() => _ScrollTimePickerState();
}

class _ScrollTimePickerState extends State<ScrollTimePicker> {
  /// This widget's hour selection and animation state.
  late FixedExtentScrollController _hourController;

  /// This widget's minute selection and animation state.
  late FixedExtentScrollController _minuteController;

  /// This widget's second selection and animation state.
  late FixedExtentScrollController _secondController;

  /// This widget's 24h format selection and animation state.
  // ignore: non_constant_identifier_names
  late FixedExtentScrollController _12hFormatController;

  late Widget _hourScrollView;
  late Widget _minuteScrollView;
  late Widget _secondScrollView;
  // ignore: non_constant_identifier_names
  late Widget _12hFormatScrollView;

  late DateTime _selectedTime;
  late String _selected12hFormat;
  bool isHourScrollable = true;
  bool isMinuteScrollable = true;
  bool isSecondScrollable = true;
  bool is12hFormatScrollable = true;
  List<int> _hours = [];
  List<int> _minutes = [];
  List<int> _seconds = [];
  // ignore: non_constant_identifier_names
  List<String> _12hFormat = [];

  int get _contains12hFormat {
    if (_selectedTime.hour > 12) {
      return _selectedTime.hour - 12;
    } else if (_selectedTime.hour == 0) {
      return 12;
    } else {
      return _selectedTime.hour;
    }
  }

  // ignore: non_constant_identifier_names
  int get _24hourFormat {
    if (_selected12hFormat == 'AM') {
      return selectedHour == 12 ? 0 : selectedHour;
    } else if (_selected12hFormat == 'PM') {
      return selectedHour == 12 ? 12 : selectedHour + 12;
    } else {
      throw 'Invalid 12h format.';
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

  int get selectedSecondIndex => !_seconds.contains(_selectedTime.second)
      ? 0
      : _seconds.indexOf(_selectedTime.second);

  int get selected12hFormatIndex => !_12hFormat.contains(_selected12hFormat)
      ? 0
      : _12hFormat.indexOf(_selected12hFormat);

  int get selectedHour => _hours[_hourController.selectedItem % _hours.length];

  int get selectedMinute =>
      _minutes[_minuteController.selectedItem % _minutes.length];

  int get selectedSecond =>
      _seconds[_secondController.selectedItem % _seconds.length];

  String get selected12hFormat =>
      _12hFormat[_12hFormatController.selectedItem % _12hFormat.length];

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.selectedTime;

    _init12hFormat();

    _hours = widget.is12hFormat
        ? [for (int i = 1; i <= 12; i++) i]
        : [for (int i = 0; i < 24; i++) i];
    _minutes = [for (int i = 0; i < 60; i++) i];
    _seconds = [for (int i = 0; i < 60; i++) i];
    _12hFormat = time12HourFormat;

    _hourController =
        FixedExtentScrollController(initialItem: selectedHourIndex);
    _minuteController =
        FixedExtentScrollController(initialItem: selectedMinuteIndex);
    _secondController =
        FixedExtentScrollController(initialItem: selectedSecondIndex);
    _12hFormatController =
        FixedExtentScrollController(initialItem: selected12hFormatIndex);
  }

  void _init12hFormat() {
    _selected12hFormat = _selectedTime.hour >= 12 ? 'PM' : 'AM';
  }

  @override
  void didUpdateWidget(covariant ScrollTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedTime != widget.selectedTime) {
      _selectedTime = widget.selectedTime;
      isMinuteScrollable = false;
      isSecondScrollable = false;
      is12hFormatScrollable = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _hourController.animateToItem(selectedHourIndex,
            curve: Curves.ease, duration: const Duration(microseconds: 500));
        _minuteController.animateToItem(selectedMinuteIndex,
            curve: Curves.ease, duration: const Duration(microseconds: 500));
        _secondController.animateToItem(selectedSecondIndex,
            curve: Curves.ease, duration: const Duration(microseconds: 500));
        _12hFormatController.animateToItem(selected12hFormatIndex,
            curve: Curves.ease, duration: const Duration(microseconds: 500));
      });
    }
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _secondController.dispose();
    _12hFormatController.dispose();
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
    _12hFormatScrollView = TimeScrollView(
        key: const Key('f12h'),
        times: _12hFormat,
        controller: _12hFormatController,
        options: widget.options,
        scrollViewOptions: widget.scrollViewOptions.f12h,
        selectedIndex: selected12hFormatIndex,
        onChanged: (_) {
          _onDateTimeChanged();
          is12hFormatScrollable = true;
        });
  }

  void _onDateTimeChanged() {
    int _selectedHour = _selectedTime.hour;
    int _selectedMinute = _selectedTime.minute;
    int _selectedSecond = _selectedTime.second;
    String _selected12h = _selected12hFormat;

    if (widget.viewType.contains(TimePickerViewType.hour)) {
      _selectedHour = selectedHour;
    }
    if (widget.viewType.contains(TimePickerViewType.minute)) {
      _selectedMinute = selectedMinute;
    }
    if (widget.viewType.contains(TimePickerViewType.second)) {
      _selectedSecond = selectedSecond;
    }
    if (widget.is12hFormat) {
      _selected12h = selected12hFormat;
    }

    _selected12hFormat = _selected12h;
    _selectedTime = DateTime(
      _selectedTime.year,
      _selectedTime.month,
      _selectedTime.day,
      widget.is12hFormat ? _24hourFormat : _selectedHour,
      _selectedMinute,
      _selectedSecond,
    );

    // print("Selected Time: $_selectedTime");
    // print("Selected 12h Format: $_selected12hFormat");
    // print("Selected Hour: $_selectedHour");
    widget.onDateTimeChanged(_selectedTime);
  }

  List<Widget> _getScrollTimePicker() {
    _initTimeScrollView();
    final viewList = <Widget>[];

    for (final viewType in widget.viewType) {
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

    if (widget.is12hFormat) {
      viewList.add(_12hFormatScrollView);
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

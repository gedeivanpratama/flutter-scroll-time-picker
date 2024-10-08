import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:scroll_time_picker/scroll_time_picker.dart';

void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DateTime _selectedTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scroll Time Picker Example"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            height: 100,
            alignment: Alignment.center,
            child: Text(
              "$_selectedTime",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 48),
            child: TextButton(
              onPressed: () {
                setState(() {
                  _selectedTime = DateTime.now();
                });
              },
              child: const Text(
                "TODAY",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
          // SizedBox(
          //   height: 250,
          //   width: 300,
          //   child: ScrollDurationPicker(
          //     selectedTime: DateTime(2024),
          //     onDateTimeChanged: (DateTime value) {
          //       log("Selected Time: ${value.hour}:${value.minute}");
          //     },
          //   ),
          // ),
          SizedBox(
            height: 250,
            width: 300,
            child: ScrollTimePicker(
              selectedTime: _selectedTime,
              divider: Text("-"),
              indicator: Container(
                height: 30,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(),
                    bottom: BorderSide(),
                  ),
                ),
              ),
              options: TimePickerOptions(backgroundColor: Colors.white),
              scrollViewOptions: TimePickerScrollViewOptions(
                hour: ScrollViewDetailOptions(alignment: Alignment.center),
                minute: ScrollViewDetailOptions(alignment: Alignment.center),
              ),
              is12hFormat: true,
              onDateTimeChanged: (DateTime value) {
                setState(() {
                  _selectedTime = value;
                });
                log('Selected Time: ${value}');
              },
            ),
          ),
        ],
      ),
    );
  }
}

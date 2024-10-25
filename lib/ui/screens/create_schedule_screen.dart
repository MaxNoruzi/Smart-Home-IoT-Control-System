import 'dart:developer';

import 'package:day_picker/day_picker.dart';

import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:iot_project/model/device_model.dart';
import 'package:iot_project/model/schedule_model.dart';

class CreateScheduleScreen extends StatefulWidget {
  CreateScheduleScreen({
    super.key,
    required this.keyNumber,
    required this.device,
    ScheduleModel? newModel,
  }) {
    model =
        ScheduleModel.fromJson(newModel?.toJson() ?? {"nodeID": device.nodeID});
    for (var i = 0; i < _days.length; i++) {
      if (model.weekDays.contains(_days[i].dayKey)) {
        _days[i].isSelected = true;
      }
    }
  }
  int keyNumber;
  Device device;
  late ScheduleModel model;
  final List<DayInWeek> _days = [
    DayInWeek("sat", dayKey: "saturday"),
    DayInWeek(
      "sun",
      dayKey: "sunday",
    ),
    DayInWeek("mon", dayKey: "monday"),
    DayInWeek("tue", dayKey: "tuesday"),
    DayInWeek("wed", dayKey: "wednesday"),
    DayInWeek("thu", dayKey: "thursday"),
    DayInWeek("fri", dayKey: "friday"),
  ];
  @override
  State<CreateScheduleScreen> createState() => _CreateScheduleScreenState();
}

class _CreateScheduleScreenState extends State<CreateScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Schedule"),
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios_rounded)),
        centerTitle: true,
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(widget.model);
              },
              child: Text(
                "Save",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: Colors.white),
              ))
        ],
      ),
      body: Column(
        children: [
          Tooltip(
            message:
                "After choosing the days that you need and selecting the right command the device will be triggred on the right time.",
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                // margin: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TimePickerSpinner(
                  alignment: Alignment.center,
                  isShowSeconds: false,
                  is24HourMode: false,
                  normalTextStyle:
                      TextStyle(fontSize: 24, color: Colors.grey.shade600),
                  highlightedTextStyle:
                      const TextStyle(fontSize: 24, color: Colors.black),
                  spacing: 50,
                  itemHeight: 80,
                  itemWidth: 60,
                  isForce2Digits: true,
                  onTimeChange: (time) {
                    widget.model.time = time;
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Material(
              elevation: 8,
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Select desired days",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SelectWeekDays(
                      // key: customWidgetKey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      unSelectedDayTextColor: Colors.black,
                      days: widget._days,
                      border: false,
                      padding: 16,
                      width: MediaQuery.of(context).size.width,
                      boxDecoration: BoxDecoration(
                        // color: Colors.red,
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      onSelect: (values) {
                        log(values.toString());
                        widget.model.weekDays.clear();
                        // List<DayInWeek> sample = widget._days.where(
                        //     (element) => values.contains(element.dayKey)).toList();
                        widget.model.weekDays.addAll(widget._days
                            .where((element) => values.contains(element.dayKey))
                            .map((e) => widget._days.indexOf(e)));
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Switch ${widget.keyNumber + 1}",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Switch(
                              value: widget.model.state,
                              onChanged: (value) {
                                setState(() {
                                  widget.model.state = value;
                                });
                              })
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

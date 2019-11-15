import 'package:flutter/material.dart';

class TimeOfDayUtils {
  static TimeOfDay add(TimeOfDay timeOfDay, Duration duration) {
    DateTime data = new DateTime(2020, 1, 1, timeOfDay.hour, timeOfDay.minute);
    return TimeOfDay.fromDateTime(data.add(duration));
  }

  static TimeOfDay subtract(TimeOfDay timeOfDay, Duration duration) {
    DateTime data = new DateTime(2020, 1, 1, timeOfDay.hour, timeOfDay.minute);
    return TimeOfDay.fromDateTime(data.subtract(duration));
  }

  static Duration duration(TimeOfDay timeOfDay) {
    return Duration(hours: timeOfDay.hour, minutes: timeOfDay.minute);
  }

  static DateTime toDateTime(TimeOfDay timeOfDay) {
    return new DateTime(2020, 1, 1, timeOfDay.hour, timeOfDay.minute);
  }
}

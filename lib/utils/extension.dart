import 'dart:convert';
import 'package:flutter/material.dart';

extension StringHelper on String {
  String capitalize() {
    return split(" ")
        .map((String s) => s[0].toUpperCase() + s.substring(1).toLowerCase())
        .join(" ");
  }

  String utcToLocalDate() {
    if (this != '') {
      DateTime utcDate = DateTime.parse(this);
      DateTime localDate = utcDate.toLocal();
      return '${localDate.day}, ${localDate.month.intToMonth()} ${localDate.year}';
    } else {
      return 'No Date provided';
    }
  }

  String ageFromDob() {
    DateTime currentDate = DateTime.now();
    DateTime utcDob = DateTime.parse(this);
    DateTime localDob = utcDob.toLocal();
    int yearDiff = currentDate.year - localDob.year;
    int monthDiff = currentDate.month - localDob.month;
    int dayDiff = currentDate.day - localDob.day;
    int year = (monthDiff < 0 || dayDiff < 0) && yearDiff > 0
        ? yearDiff - 1
        : yearDiff;
    int month = dayDiff < 0 && monthDiff > 0 ? monthDiff : monthDiff + 12;
    return '${year == 0 ? '' : year == 1 ? '$year Year' : '$year Years'} ${month == 0 ? '' : month == 1 ? ', $month Month' : ', $month Months'}';
  }

  // String ageFromDob() {
  //   DateTime currentDate = DateTime.now();
  //   DateTime utcDob = DateTime.parse(this);
  //   DateTime localDob = utcDob.toLocal();
  //   int yearDiff = currentDate.year - localDob.year;
  //   int monthDiff = currentDate.month - localDob.month;
  //   int dayDiff = currentDate.day - localDob.day;
  //   int age = (monthDiff < 0 || dayDiff < 0) && yearDiff > 0 ? yearDiff - 1 : yearDiff;
  //   return '$age';
  // }

  String insertName(String name) {
    final data =
        replaceAll('@client_name', name).replaceAll('@parent_name', name);

    return data;
  }

  String toBeauty() {
    if (contains("{")) {
      final Map<String, dynamic> data = jsonDecode(this);
      final note = List.generate(
              data.length,
              (i) =>
                  "${data.keys.elementAt(i).replaceAll("_", " ").capitalize()} : ${data.values.elementAt(i)}")
          .join('\n');

      return note;
    }
    return this;
  }
}

extension IntHelper on int {
  String intToMonth() {
    List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[this - 1];
  }
}

extension DateTimeHelper on DateTime {
  String toDDMMYYYY() {
    return '$day/$month/$year';
  }

  String toMMYYYY() {
    return '${month < 10 ? '0$month' : month}/$year';
  }

  String toSlashDate() {
    return '${day < 10 ? '0$day' : day}/${month < 10 ? '0$month' : month}/$year';
  }

  String toDate() {
    return '${day < 10 ? '0$day' : day}-${month < 10 ? '0$month' : month}-$year';
  }

  String toDateTime() {
    return '${day < 10 ? '0$day' : day}-${month < 10 ? '0$month' : month}-$year, ${toTime()}';
  }

  String toYYYYMMDD() {
    return '$year/$month/$day';
  }

  String toMMDDYYYY() {
    return '${month < 10 ? '0$month' : month}/${day < 10 ? '0$day' : day}/$year';
  }

  String toTime() {
    int hour0 = hour > 12 ? hour - 12 : hour;
    return '${hour0 < 10 ? '0$hour0' : hour0}:${minute < 10 ? '0$minute' : minute} ${hour < 12 ? 'AM' : 'PM'}';
  }

  String toStandard() {
    return '${day < 10 ? '0$day' : day}, ${month.intToMonth()} $year';
  }

  String toStandardDtTime() {
    // Convert UTC to local (IST in your case)
    DateTime localDateTime = toLocal();

    // Extract date and time components
    int hour = localDateTime.hour;
    int minute = localDateTime.minute;
    int day = localDateTime.day;
    int month = localDateTime.month;
    int year = localDateTime.year;

    // Convert to 12-hour format
    int hour0 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    // Format the date and time
    return '${day < 10 ? '0$day' : day}, ${month.intToMonth()} $year, '
        '${hour0 < 10 ? '0$hour0' : hour0}:${minute < 10 ? '0$minute' : minute} '
        '${hour < 12 ? 'AM' : 'PM'}';
  }
}

extension TimeHelper on TimeOfDay {
  String toTime() {
    int hour0 = hour > 12 ? hour - 12 : hour;
    return '${hour0 < 10 ? '0$hour0' : hour0}:${minute < 10 ? '0$minute' : minute} ${hour < 12 ? 'AM' : 'PM'}';
  }
}

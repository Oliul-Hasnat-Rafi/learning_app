import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';

extension DateTimeExtensions on DateTime {
  String get custom_MMMM => DateFormat('MMMM').format(toLocal());
  String get custom_MMM => DateFormat('MMM').format(toLocal());
  String get custom_MMMM_yy => DateFormat('MMMM yy').format(toLocal());
  String get custom_hh_mm_a => DateFormat('hh:mm a').format(toLocal());
  String get custom_hh_mm => DateFormat('hh:mm ss').format(toLocal());

  String get custom_d_MMM_EEE => DateFormat('d MMM : EEE').format(toLocal());
  String get custom_d_MMM_yyyy => DateFormat('d MMM yyyy').format(toLocal());
  String get custom_EEEE_MMM_d_yyyy => DateFormat('EEEE, MMMM d, yyyy').format(toLocal());
    String get custom_d_MMM => DateFormat('d MMM').format(toLocal());
  String get customConvertToDateTimeDateString => DateFormat('dd-MMM-yy').format(toLocal());



  DateTime get customGetMinTime => DateTime(year, month, day);

  DateTime get customGetMaxTime => DateTime(year, month, day + 1).subtract(Duration(microseconds: 1));

  bool customIsSameDay({DateTime? otherDate}) {
    DateTime today = otherDate ?? DateTime.now();
    return today.year == year && today.month == month && today.day == day;
  }

  bool customIsSameMonth({DateTime? otherDate}) {
    DateTime today = otherDate ?? DateTime.now();
    return today.year == year && today.month == month;
  }


  List<DateTime> customRange({DateTime? startingTime, DateRange dateRange = DateRange.day}) {
    DateTime start = startingTime ?? DateTime.now();

    List<DateTime> dateList = [];
    for (DateTime date = start; date.isBefore(this) || date.isAtSameMomentAs(this); date = _add(date, dateRange)) {
      dateList.add(date);
    }

    return dateList;
  }


List<DateTime> customGetMonthList({Duration? duration}) {
  duration = duration ?? Duration(days: 365);
  DateTime nd = subtract(duration).subtract(Duration(days: 1));
  DateTime startDate = DateTime(year, month, day);
  var months = <DateTime>[];

  while (startDate.isAfter(nd)) {
    months.add(startDate);
    int newMonth = startDate.month - 1;
    int newYear = startDate.year;
    if (newMonth == 0) {
      newMonth = 12;
      newYear -= 1;
    }
    int newDay = startDate.day;
    int daysInNewMonth = DateTime(newYear, newMonth + 1, 0).day;
    if (newDay > daysInNewMonth) {
      newDay = daysInNewMonth;
    }
    startDate = DateTime(newYear, newMonth, newDay, startDate.hour, startDate.minute, startDate.second, startDate.millisecond, startDate.microsecond);
  }

  print("---------------------------- months : )) ${months.reversed.toList()}");
  return months.toList();
}

  bool customInBetweenDay({required DateTime startTime, DateTime? endTime}) {
    if (customIsSameDay(otherDate: startTime)) return true;
    if (endTime == null) return isAfter(startTime);

    if (customIsSameDay(otherDate: endTime)) return true;
    return isAfter(startTime) && isBefore(endTime);
  }

  bool customInBetweenHour({required DateTime startTime, DateTime? endTime}) {
    if (year == startTime.year && month == startTime.month && day == startTime.day && hour == startTime.hour) return true;
    if (endTime == null) return isAfter(startTime);

    if (year == endTime.year && month == endTime.month && day == endTime.day && hour == endTime.hour) return true;
    return isAfter(startTime) && isBefore(endTime);
  }

  DateTime get customConvertToDateTimeHour => DateTime(year, month, day, hour);
  DateTime get customConvertToDateTimeDate => DateTime(year, month, day);
  DateTime get customConvertToDateTimeMonth => DateTime(year, month);

  String get customToAPI {
    // String r = toIso8601String();
    String r = toUtc().toIso8601String();


    // String r = toLocal().toIso8601String();
    // print("---------------------------- )) ${r}");

    return r;
  }

  String get customUtcToAPI {
  DateTime utcDate = toUtc();
  DateTime adjustedDate = DateTime.utc(utcDate.year, utcDate.month, utcDate.day + 1);
  
  String result = adjustedDate.toIso8601String();
  // print("---------------------------- )) $result");
  
  return result;
}

  String get customTodayTomorrowYesterday {
    DateTime n = DateTime.now();
    DateTime d = customConvertToDateTimeDate;
    if (d == n.customConvertToDateTimeDate) return 'Today';
    if (d == n.add(Duration(days: 1)).customConvertToDateTimeDate) return 'Tomorrow';
    if (d == n.subtract(Duration(days: 1)).customConvertToDateTimeDate) return 'Yesterday';

    return custom_d_MMM_EEE;
  }

  /// Quick value text, Date Starting Time, Date Ending Time
  List<Tuple3<String, DateTime, DateTime>> get customQuickSelectionDate {
    List<Tuple3<String, DateTime, DateTime>> res = [];

    res.add(Tuple3("Today", customGetMinTime, customGetMaxTime)); // Today
    res.add(Tuple3("Last 7 days", customGetMinTime.subtract(Duration(days: 7)), customGetMaxTime)); // Last 7 days
    res.add(Tuple3("Last 30 days", customGetMinTime.subtract(Duration(days: 30)), customGetMaxTime)); // Last 30 days
    res.add(Tuple3("This month", DateTime(year, month, 1).customGetMinTime, DateTime(year, month + 1, 0).customGetMaxTime)); // This month
    res.add(Tuple3("Last month", DateTime(year, month - 1, 1).customGetMinTime, DateTime(year, month, 0).customGetMaxTime)); // Last month
    res.add(Tuple3("Last 3 months", DateTime(year, month - 3, 1).customGetMinTime, DateTime(year, month, 0).customGetMaxTime)); // Last 3 months
    res.add(Tuple3("Last 6 months", DateTime(year, month - 6, 1).customGetMinTime, DateTime(year, month, 0).customGetMaxTime)); // Last 6 months
    res.add(Tuple3("Last 1 year", DateTime(year - 1, 1, 0).customGetMinTime, DateTime(year, 0, 0).customGetMaxTime)); // Last 1 year
    res.add(Tuple3("Last 5 years", DateTime(year - 5, 1, 0).customGetMinTime, DateTime(year, 0, 0).customGetMaxTime)); // Last 5 years
    res.add(Tuple3("This year", DateTime(year, 1, 1).customGetMinTime, DateTime(year + 1, 0, 0).customGetMaxTime)); // This year
    res.add(Tuple3("Previous year", DateTime(year - 1, 1).customGetMinTime, DateTime(year, 0, 0).customGetMaxTime)); // Previous year

    // print("A---- $customGetMinTime   $customGetMaxTime");
    // print("A---- ${customGetMinTime.customToAPI}   ${customGetMaxTime.customToAPI}");

    return res;
  }
}

const Map<int, String> _weekDay = {
  DateTime.saturday: "saturday",
  DateTime.sunday: "sunday",
  DateTime.monday: "monday",
  DateTime.tuesday: "tuesday",
  DateTime.wednesday: "wednesday",
  DateTime.thursday: "thursday",
  DateTime.friday: "friday",
};

enum DateRange {
  year,
  month,
  day,
  hour,
  minute,
  second,
  milliseconds,
  microsecond,
}

DateTime _add(DateTime currentTime, DateRange dateRange) {
  DateTime res;
  if (dateRange == DateRange.day || dateRange == DateRange.hour || dateRange == DateRange.minute) {
    res = currentTime.add(Duration(
      days: dateRange == DateRange.day ? 1 : 0,
      hours: dateRange == DateRange.hour ? 1 : 0,
      minutes: dateRange == DateRange.minute ? 1 : 0,
      seconds: dateRange == DateRange.second ? 1 : 0,
      milliseconds: dateRange == DateRange.milliseconds ? 1 : 0,
      microseconds: dateRange == DateRange.microsecond ? 1 : 0,
    ));
  } else {
    res = currentTime.copyWith(
      year: dateRange == DateRange.year ? currentTime.year + 1 : currentTime.year,
      month: dateRange == DateRange.month ? currentTime.month + 1 : currentTime.month,
    );
  }

  return res;
}



// 2024-03-27T03:00:25.617Z - 2024-03-27T12:00:44.088Z
// 2024-03-27T09:00:25.617Z - 2024-03-27T18:00:44.088Z
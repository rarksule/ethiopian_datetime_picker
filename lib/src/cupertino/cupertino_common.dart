import 'package:ethiopian_datetime/ethiopian_datetime.dart';
import 'package:flutter/cupertino.dart';

import '../calander_common.dart';
import '../string_text.dart';

/// Generates a medium format date string based on the current locale and input date.
/// Handles the formatting of weekdays, months, and days in different scenarios.
/// Returns a formatted date string suitable for display purposes.
String datePickerMediumDate(ETDateTime date, BuildContext context) {
  if (globalLocale != null) {
    final String weekday = ETDateUtils.getShortWeekDayNames(
        globalLocale)[date.weekday - ETDateTime.segno];
    final String month = ETDateUtils.getShortMonthNames(
        globalLocale)[date.month - ETDateTime.meskerem];
    return '$weekday ' '$month ' '${date.day.toString().padRight(2)}';
  } else if (date.month == 13) {
    const String month = 'pag';
    return '${CupertinoLocalizations.of(context).datePickerDayOfMonth(date.day, date.weekday - ETDateTime.segno).replaceAll(date.day.toString(), '')} '
        '$month '
        '${date.day.toString().padRight(2)}';
  }
  return CupertinoLocalizations.of(context).datePickerMediumDate(date);
}

/// Returns a formatted date string for the provided [dayIndex], potentially including the weekday name.
/// Handles different scenarios based on the global locale and optional weekday information.
/// Returns a formatted date string suitable for display purposes.
String datePickerDayOfMonth(int dayIndex, BuildContext context,
    [int? weekDay]) {
  if (globalLocale != null) {
    if (weekDay != null) {
      return ' ${ETDateUtils.getShortMonthNames(globalLocale)[weekDay - ETDateTime.segno]} $dayIndex ';
    }
    return dayIndex.toString();
  }
  return CupertinoLocalizations.of(context)
      .datePickerDayOfMonth(dayIndex, weekDay);
}

/// Returns the name of the month for the provided [monthIndex] based on the current locale.
/// Handles different scenarios based on the global locale and the provided month index.
/// Returns the name of the month suitable for display purposes.
String datePickerMonth(int monthIndex, BuildContext context) {
  if (globalLocale != null) {
    final String month = ETDateUtils.getMonthNames(
        globalLocale)[monthIndex - ETDateTime.meskerem];
    return month;
  } else if (monthIndex == 13) {
    const String month = 'pagume';
    return month;
  }
  return CupertinoLocalizations.of(context).datePickerMonth(monthIndex);
}

/// Returns the standalone name of the month for the provided [monthIndex] based on the current locale.
/// Handles different scenarios based on the global locale and the provided month index.
/// Returns the standalone name of the month suitable for display purposes.
String datePickerStandaloneMonth(int monthIndex, BuildContext context) {
  if (globalLocale != null) {
    final String month = ETDateUtils.getMonthNames(
        globalLocale)[monthIndex - ETDateTime.meskerem];
    return month;
  } else if (monthIndex == 13) {
    const String month = 'pagume';
    return month;
  }
  return CupertinoLocalizations.of(context).datePickerMonth(monthIndex);
}

/// Returns the abbreviation for ante meridiem based on the current locale and optional hour information.
/// Handles different scenarios based on the global locale and the provided hour.
/// Returns the abbreviation for ante meridiem suitable for display purposes.
String anteMeridiemAbbreviation(BuildContext context, [int? hour]) {
  if (globalLocale != null) {
    int index = (hour ?? 0) < 5 || (hour ?? 0) == 12 ? 2 : 0;
    return ETDateUtils.getTimeOfDayNames(globalLocale)[index];
  }
  return CupertinoLocalizations.of(context).anteMeridiemAbbreviation;
}

/// Returns the abbreviation for post meridiem based on the current locale and optional hour information.
/// Handles different scenarios based on the global locale and the provided hour.
/// Returns the abbreviation for post meridiem suitable for display purposes.
String postMeridiemAbbreviation(BuildContext context, [int? hour]) {
  if (globalLocale != null) {
    int index = (hour ?? 0) > 17 ? 3 : 1;
    return ETDateUtils.getTimeOfDayNames(globalLocale)[index];
  }
  return CupertinoLocalizations.of(context).postMeridiemAbbreviation;
}

/// Retrieves the localized label for "Today" based on the provided [context].
/// Returns the localized label for the current date, typically used for indicating today's date.
String todayLabel(BuildContext context) {
  Localized localized = Localized(context);
  return localized.currentDateLabel;
}

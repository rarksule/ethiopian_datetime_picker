import 'package:ethiopian_datetime/ethiopian_datetime.dart';
import 'package:flutter/material.dart';

import 'calander_common.dart';

/// Returns a locale-appropriate string to describe the start of a date range.
///
/// If `startDate` is null, then it defaults to 'Start Date', otherwise if it
/// is in the same year as the `endDate` then it will use the short month
/// day format (i.e. 'Jan 21'). Otherwise it will return the short date format
/// (i.e. 'Jan 21, 2020').
String formatRangeStartETDate(
    ETDateTime? startDate, ETDateTime? endDate, BuildContext context) {
  final Localized localized = Localized(context);
  return startDate == null
      ? localized.dateRangeStartLabel
      : (endDate == null || startDate.year == endDate.year)
          ? localized.formatShortMonthDay(startDate)
          : localized.formatShortDate(startDate);
}

/// Returns an locale-appropriate string to describe the end of a date range.
///
/// If `endDate` is null, then it defaults to 'End Date', otherwise if it
/// is in the same year as the `startDate` and the `currentDate` then it will
/// just use the short month day format (i.e. 'Jan 21'), otherwise it will
/// include the year (i.e. 'Jan 21, 2020').
String formatRangeEndETDate(ETDateTime? startDate, ETDateTime? endDate,
    ETDateTime currentDate, BuildContext context) {
  final Localized localized = Localized(context);
  return endDate == null
      ? localized.dateRangeEndLabel
      : (startDate != null &&
              startDate.year == endDate.year &&
              startDate.year == currentDate.year)
          ? localized.formatShortMonthDay(endDate)
          : localized.formatShortDate(endDate);
}

ETDateTime? parseCompactDate(String? inputString) {
  if (inputString == null) {
    return null;
  }

  // Assumes US mm/dd/yyyy format
  final List<String> inputParts = inputString.split('/');
  if (inputParts.length != 3) {
    return null;
  }

  final int? year = int.tryParse(inputParts[2], radix: 10);
  if (year == null || year < 1) {
    return null;
  }

  final int? month = int.tryParse(inputParts[0], radix: 10);
  if (month == null || month < 1 || month > 12) {
    return null;
  }

  final int? day = int.tryParse(inputParts[1], radix: 10);
  if (day == null || day < 1 || day > ETDateUtils.getDaysInMonth(year, month)) {
    return null;
  }

  try {
    return ETDateTime(year, month, day);
  } on ArgumentError {
    return null;
  }
}

class Localized {
  final BuildContext context;
  Localized(this.context);
  String timePickerMinuteModeAnnouncement() {
    return '';
  }

  String formatMonthYear(ETDateTime date) {
    if (globalLocale != null) {
      return '${ETDateUtils.getMonthNames(globalLocale)[date.month - 1]} ${date.year}';
    } else if (date.month == 13) {
      return 'Pagume ${date.year}';
    }
    return MaterialLocalizations.of(context).formatMonthYear(date);
  }

  String formatFullDate(ETDateTime date) {
    if (globalLocale != null) {
      final String month = ETDateUtils.getMonthNames(
          globalLocale)[date.month - ETDateTime.meskerem];
      return '${ETDateUtils.getWeekDayNames(globalLocale)[date.weekday - ETDateTime.segno]}, $month ${date.day}, ${date.year}';
    } else if (date.month == 13) {
      const String month = 'pagume';
      return '${MaterialLocalizations.of(context).narrowWeekdays[date.weekday - ETDateTime.segno]}, $month ${date.day}, ${date.year}';
    }
    return MaterialLocalizations.of(context).formatFullDate(date);
  }

  String formatMediumDate(ETDateTime date) {
    bool isAmharic =
        false; //Localizations.localeOf(context).languageCode != 'am';

    if (globalLocale != null || isAmharic) {
      final String day = ETDateUtils.getShortWeekDayNames(
          globalLocale)[date.weekday - ETDateTime.segno];
      final String month = ETDateUtils.getMonthNames(
          globalLocale)[date.month - ETDateTime.meskerem];
      return '$day, $month ${date.day}';
    } else if (date.month == 13) {
      const String month = 'pagume';
      return '${MaterialLocalizations.of(context).narrowWeekdays[date.weekday - ETDateTime.segno]}, $month ${date.day}';
    }
    return MaterialLocalizations.of(context).formatMediumDate(date);
  }

  String formatShortMonthDay(ETDateTime date) {
    if (globalLocale != null) {
      final String month = ETDateUtils.getShortMonthNames(
          globalLocale)[date.month - ETDateTime.meskerem];
      return '$month ${date.day}';
    } else if (date.month == 13) {
      const String month = 'pag';
      return '$month ${date.day}';
    }
    return MaterialLocalizations.of(context).formatShortMonthDay(date);
  }

  String formatShortDate(ETDateTime date) {
    if (globalLocale != null) {
      final String month = ETDateUtils.getShortMonthNames(
          globalLocale)[date.month - ETDateTime.meskerem];
      return '$month ${date.day}, ${date.year}';
    } else if (date.month == 13) {
      const String month = 'pag';
      return '$month ${date.day}, ${date.year}';
    }
    return MaterialLocalizations.of(context).formatShortDate(date);
  }

  String formatYear(ETDateTime selectedDate) {
    MaterialLocalizations localization = MaterialLocalizations.of(context);
    return localization.formatYear(selectedDate);
  }

  String formatCompactDate(ETDateTime date) {
    MaterialLocalizations localization = MaterialLocalizations.of(context);
    return localization.formatCompactDate(date);
  }

  String formatDecimal(int value) {
    MaterialLocalizations localization = MaterialLocalizations.of(context);
    return localization.formatDecimal(value);
  }

  String dateRangeStartDateSemanticLabel(String label) {
    MaterialLocalizations localization = MaterialLocalizations.of(context);
    return localization.dateRangeStartDateSemanticLabel(label);
  }

  String dateRangeEndDateSemanticLabel(String label) {
    MaterialLocalizations localization = MaterialLocalizations.of(context);
    return localization.dateRangeStartDateSemanticLabel(label);
  }

  String get unspecifiedDateRange {
    MaterialLocalizations localization = MaterialLocalizations.of(context);
    return localization.unspecifiedDateRange;
  }

  String get dateHelpText {
    MaterialLocalizations localization = MaterialLocalizations.of(context);

    switch (globalLocale) {
      case 'om':
        return OromiffaTexts.dateHelpText;
      case 'so':
        return AfsomaliTexts.dateHelpText;
      case 'ti':
        return TigrayTexts.dateHelpText;
    }
    return localization.dateHelpText;
  }

  String get dateRangeStartLabel {
    MaterialLocalizations localization = MaterialLocalizations.of(context);
    switch (globalLocale) {
      case 'om':
        return OromiffaTexts.dateRangeStartLabel;
      case 'so':
        return AfsomaliTexts.dateRangeStartLabel;
      case 'ti':
        return TigrayTexts.dateRangeStartLabel;
    }
    return localization.dateRangeStartLabel;
  }

  String get dateRangeEndLabel {
    MaterialLocalizations localization = MaterialLocalizations.of(context);
    switch (globalLocale) {
      case 'om':
        return OromiffaTexts.dateRangeEndLabel;
      case 'so':
        return AfsomaliTexts.dateRangeEndLabel;
      case 'ti':
        return TigrayTexts.dateRangeEndLabel;
    }
    return localization.dateRangeEndLabel;
  }

  String get dateRangePickerHelpText {
    MaterialLocalizations localization = MaterialLocalizations.of(context);
    switch (globalLocale) {
      case 'om':
        return OromiffaTexts.dateRangePickerHelpText;
      case 'so':
        return AfsomaliTexts.dateRangePickerHelpText;
      case 'ti':
        return TigrayTexts.dateRangePickerHelpText;
    }
    return localization.dateRangePickerHelpText;
  }

  String get dateInputLabel {
    MaterialLocalizations localization = MaterialLocalizations.of(context);
    switch (globalLocale) {
      case 'om':
        return OromiffaTexts.dateInputLabel;
      case 'so':
        return AfsomaliTexts.dateInputLabel;
      case 'ti':
        return TigrayTexts.dateInputLabel;
    }
    return localization.dateInputLabel;
  }

  String get saveButtonLabel {
    MaterialLocalizations localization = MaterialLocalizations.of(context);
    switch (globalLocale) {
      case 'om':
        return OromiffaTexts.saveButtonLabel;
      case 'so':
        return AfsomaliTexts.saveButtonLabel;
      case 'ti':
        return TigrayTexts.saveButtonLabel;
    }
    return localization.saveButtonLabel;
  }

  String get previousMonthTooltip {
    MaterialLocalizations localization = MaterialLocalizations.of(context);
    switch (globalLocale) {
      case 'om':
        return OromiffaTexts.previousMonthTooltip;
      case 'so':
        return AfsomaliTexts.previousMonthTooltip;
      case 'ti':
        return TigrayTexts.previousMonthTooltip;
    }
    return localization.previousMonthTooltip;
  }

  String get nextMonthTooltip {
    MaterialLocalizations localization = MaterialLocalizations.of(context);
    switch (globalLocale) {
      case 'om':
        return OromiffaTexts.nextMonthTooltip;
      case 'so':
        return AfsomaliTexts.nextMonthTooltip;
      case 'ti':
        return TigrayTexts.nextMonthTooltip;
    }
    return localization.nextMonthTooltip;
  }

  String get cancelButtonLabel {
    MaterialLocalizations localization = MaterialLocalizations.of(context);
    switch (globalLocale) {
      case 'om':
        return OromiffaTexts.cancelButtonLabel;
      case 'so':
        return AfsomaliTexts.cancelButtonLabel;
      case 'ti':
      case 'am':
        return TigrayTexts.cancelButtonLabel;
    }
    return localization.cancelButtonLabel;
  }

  String get okButtonLabel {
    MaterialLocalizations localization = MaterialLocalizations.of(context);
    switch (globalLocale) {
      case 'om':
        return OromiffaTexts.okButtonLabel;
      case 'so':
        return AfsomaliTexts.okButtonLabel;
      case 'ti':
      case 'am':
        return TigrayTexts.okButtonLabel;
    }
    return localization.okButtonLabel;
  }

  String get inputDateModeButtonLabel {
    MaterialLocalizations localization = MaterialLocalizations.of(context);
    switch (globalLocale) {
      case 'om':
        return OromiffaTexts.inputDateModeButtonLabel;
      case 'so':
        return AfsomaliTexts.inputDateModeButtonLabel;
      case 'ti':
        return TigrayTexts.inputDateModeButtonLabel;
    }
    return localization.inputDateModeButtonLabel;
  }

  String get calendarModeButtonLabel {
    MaterialLocalizations localization = MaterialLocalizations.of(context);
    switch (globalLocale) {
      case 'om':
        return OromiffaTexts.calendarModeButtonLabel;
      case 'so':
        return AfsomaliTexts.calendarModeButtonLabel;
      case 'ti':
        return TigrayTexts.calendarModeButtonLabel;
    }
    return localization.calendarModeButtonLabel;
  }

  String get datePickerHelpText {
    MaterialLocalizations localization = MaterialLocalizations.of(context);
    switch (globalLocale) {
      case 'om':
        return OromiffaTexts.datePickerHelpText;
      case 'so':
        return AfsomaliTexts.datePickerHelpText;
      case 'ti':
        return TigrayTexts.datePickerHelpText;
    }
    return localization.datePickerHelpText;
  }

  String get currentDateLabel {
    MaterialLocalizations localization = MaterialLocalizations.of(context);
    switch (globalLocale) {
      case 'om':
        return OromiffaTexts.currentDateLabel;
      case 'so':
        return AfsomaliTexts.currentDateLabel;
      case 'ti':
        return TigrayTexts.currentDateLabel;
      case 'am':
        return AmharicTexts.currentDateLabel;
    }
    return localization.currentDateLabel;
  }

  String get timePickerDialHelpText {
    MaterialLocalizations localization = MaterialLocalizations.of(context);
    switch (globalLocale) {
      case 'om':
        return OromiffaTexts.timePickerDialHelpText;
      case 'so':
        return AfsomaliTexts.timePickerDialHelpText;
      case 'ti':
        return TigrayTexts.timePickerDialHelpText;
      case 'am':
        return AmharicTexts.timePickerDialHelpText;
    }
    return localization.timePickerDialHelpText;
  }

  String get timePickerInputHelpText {
    MaterialLocalizations localization = MaterialLocalizations.of(context);
    switch (globalLocale) {
      case 'om':
        return OromiffaTexts.timePickerInputHelpText;
      case 'so':
        return AfsomaliTexts.timePickerInputHelpText;
      case 'ti':
        return TigrayTexts.timePickerInputHelpText;
      case 'am':
        return AmharicTexts.timePickerInputHelpText;
    }
    return localization.timePickerInputHelpText;
  }

  String get timePickerHourLabel {
    MaterialLocalizations localization = MaterialLocalizations.of(context);
    switch (globalLocale) {
      case 'om':
        return OromiffaTexts.timePickerHourLabel;
      case 'so':
        return AfsomaliTexts.timePickerHourLabel;
      case 'ti':
        return TigrayTexts.timePickerHourLabel;
      case 'am':
        return AmharicTexts.timePickerHourLabel;
    }
    return localization.timePickerHourLabel;
  }

  String get timePickerMinuteLabel {
    MaterialLocalizations localization = MaterialLocalizations.of(context);
    switch (globalLocale) {
      case 'om':
        return OromiffaTexts.timePickerMinuteLabel;
      case 'so':
        return AfsomaliTexts.timePickerMinuteLabel;
      case 'ti':
        return TigrayTexts.timePickerMinuteLabel;
      case 'am':
        return AmharicTexts.timePickerMinuteLabel;
    }
    return localization.timePickerMinuteLabel;
  }

  String get inputTimeModeButtonLabel {
    MaterialLocalizations localization = MaterialLocalizations.of(context);
    switch (globalLocale) {
      case 'om':
        return OromiffaTexts.inputTimeModeButtonLabel;
      case 'so':
        return AfsomaliTexts.inputTimeModeButtonLabel;
      case 'ti':
        return TigrayTexts.inputTimeModeButtonLabel;
      case 'am':
        return AmharicTexts.inputTimeModeButtonLabel;
    }
    return localization.inputTimeModeButtonLabel;
  }

  String get dialModeButtonLabel {
    MaterialLocalizations localization = MaterialLocalizations.of(context);
    switch (globalLocale) {
      case 'om':
        return OromiffaTexts.dialModeButtonLabel;
      case 'so':
        return AfsomaliTexts.dialModeButtonLabel;
      case 'ti':
        return TigrayTexts.dialModeButtonLabel;
      case 'am':
        return AmharicTexts.dialModeButtonLabel;
    }
    return localization.dialModeButtonLabel;
  }

  List<String> get narrowWeekdays {
    if (globalLocale != null) {
      return ETDateUtils.getNarrowWeekDayNames(globalLocale);
    }
    return MaterialLocalizations.of(context).narrowWeekdays;
  }
}

class OromiffaTexts {
  static String get dateHelpText => 'gg/jj/wwww';
  static String get dateRangeStartLabel => 'Guyyaa Jalqabaa';
  static String get dateRangeEndLabel => 'Guyyaa Xumuraa';
  static String get dateRangePickerHelpText => 'Daangaa filadhu';
  static String get dateInputLabel => 'Guyyaa galchi';
  static String get saveButtonLabel => 'kaa\'i';
  static String get previousMonthTooltip => 'ji\'a darbe';
  static String get nextMonthTooltip => 'ji\'a itti aanu';
  static String get cancelButtonLabel => 'Dhisii';
  static String get okButtonLabel => 'Hayyee';
  static String get inputDateModeButtonLabel => 'Gara galtee jijjiiri';
  static String get calendarModeButtonLabel => 'Gara filannootti jijjiiri';
  static String get datePickerHelpText => 'Guyyaa Filadhu';
  static String get currentDateLabel => 'har\'a';
  static String get timePickerDialHelpText => 'yeroo filadhu';
  static String get timePickerInputHelpText => 'Yeroo galchi';
  static String get timePickerMinuteLabel => 'daqiiqaa';
  static String get timePickerHourLabel => "sa'a";
  static String get dialModeButtonLabel => 'Gara haalata filannoo jijjiiri';
  static String get inputTimeModeButtonLabel =>
      'Gara haalata galtee barruutti jijjiiri';
}

class AmharicTexts {
  static String get currentDateLabel => 'ዛሬ';
  static String get timePickerDialHelpText => 'ጊዜ ምረጥ';
  static String get timePickerInputHelpText => 'ጊዜ ጻፍ';
  static String get timePickerMinuteLabel => 'ደቂቃ';
  static String get timePickerHourLabel => 'ሰአት';
  static String get dialModeButtonLabel => 'ወደ መራጭ ሁነታ ቀይር';
  static String get inputTimeModeButtonLabel => 'ወደ የጽሑፍ ሁነታ ቀይር';
}

class AfsomaliTexts {
  static String get dateHelpText => 'mm/bb/ssss';
  static String get dateRangeStartLabel => 'Taariikhda Bilawga';
  static String get dateRangeEndLabel => 'Taariikhda dhamaadka';
  static String get dateRangePickerHelpText => 'Dooro kala duwan';
  static String get dateInputLabel => 'Gali Taariikhda';
  static String get saveButtonLabel => 'kaydinta';
  static String get previousMonthTooltip => 'bishii hore';
  static String get nextMonthTooltip => 'bisha soo socota';
  static String get cancelButtonLabel => 'Jooji';
  static String get okButtonLabel => 'OK';
  static String get inputDateModeButtonLabel => 'U beddel gelinta';
  static String get calendarModeButtonLabel => 'U beddelo kalandarka';
  static String get datePickerHelpText => 'Taariikhda dooro';
  static String get currentDateLabel => 'Maanta';
  static String get timePickerDialHelpText => 'waqti dooro';
  static String get timePickerInputHelpText => 'Gali wakhtiga';
  static String get timePickerMinuteLabel => 'daqiiqo';
  static String get timePickerHourLabel => 'saac';
  static String get dialModeButtonLabel => 'U beddel qaabka';
  static String get inputTimeModeButtonLabel =>
      'U beddel habka gelinta qoraalka';
}

class TigrayTexts {
  static String get dateHelpText => 'ዕዕ/ወወ/ዓዓዓዓ';
  static String get dateRangeStartLabel => 'ዕለት ምጅማር';
  static String get dateRangeEndLabel => 'መወዳእታ ዕለት';
  static String get dateRangePickerHelpText => 'ደረጃ ምረጽ';
  static String get dateInputLabel => 'ዕለት ኣእትዉ';
  static String get saveButtonLabel => 'ዕቅብ';
  static String get previousMonthTooltip => 'ዝሓለፈ ወርሒ';
  static String get nextMonthTooltip => 'ዝመጽእ ወርሒ';
  static String get cancelButtonLabel => 'ሰርዝ';
  static String get okButtonLabel => 'እሺ';
  static String get inputDateModeButtonLabel => 'ናብ ምእታው ምቕያር';
  static String get calendarModeButtonLabel => 'ናብ ካላንደር ቀይር';
  static String get datePickerHelpText => 'ዕለት ምረጽ';
  static String get currentDateLabel => 'ሎምዓንቲ';
  static String get timePickerDialHelpText => 'ግዜ ምረጽ';
  static String get timePickerInputHelpText => 'ግዜ ኣእቱ';
  static String get timePickerMinuteLabel => 'ደቒቓ';
  static String get timePickerHourLabel => 'ሰአት';
  static String get dialModeButtonLabel => 'ናብ ምምራጽ ቀይር';
  static String get inputTimeModeButtonLabel => 'ናብ ናይ ጽሑፍ ምእታው ቀይር';
}

import "package:ethiopian_datetime/ethiopian_datetime.dart";
import "package:ethiopian_datetime_picker/src/calander_common.dart";
import "package:flutter/material.dart";

/// Returns a locale-appropriate string to describe the start of a date range.
///
/// If `startDate` is null, then it defaults to 'Start Date', otherwise if it
/// is in the same year as the `endDate` then it will use the short month
/// day format (i.e. 'Jan 21'). Otherwise it will return the short date format
/// (i.e. 'Jan 21, 2020').
String formatRangeStartETDate(
  ETDateTime? startDate,
  ETDateTime? endDate,
  BuildContext context,
) {
  final localized = Localized(context);
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
String formatRangeEndETDate(
  ETDateTime? startDate,
  ETDateTime? endDate,
  ETDateTime currentDate,
  BuildContext context,
) {
  final localized = Localized(context);
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
  final inputParts = inputString.split("/");
  if (inputParts.length != 3) {
    return null;
  }

  final year = int.tryParse(inputParts[2], radix: 10);
  if (year == null || year < 1) {
    return null;
  }

  final month = int.tryParse(inputParts[0], radix: 10);
  if (month == null || month < 1 || month > 12) {
    return null;
  }

  final day = int.tryParse(inputParts[1], radix: 10);
  if (day == null || day < 1 || day > ETDateUtils.getDaysInMonth(year, month)) {
    return null;
  }

  try {
    return ETDateTime(year, month, day);
    // ignore: avoid_catching_errors
  } on ArgumentError {
    return null;
  }
}

///
class Localized {
  ///
  Localized(this.context);

  ///
  final BuildContext context;

  ///
  String timePickerMinuteModeAnnouncement() => "";

  ///
  String formatMonthYear(ETDateTime date) {
    if (globalLocale != null) {
      return "${ETDateUtils.getMonthNames(globalLocale)[date.month - 1]} ${date.year}";
    } else if (date.month == 13) {
      return "Pagume ${date.year}";
    }
    return MaterialLocalizations.of(context).formatMonthYear(date);
  }

  String formatFullDate(ETDateTime date) {
    if (globalLocale != null) {
      final month = ETDateUtils.getMonthNames(
        globalLocale,
      )[date.month - ETDateTime.meskerem];
      return "${ETDateUtils.getWeekDayNames(globalLocale)[date.weekday - ETDateTime.segno]}, $month ${date.day}, ${date.year}";
    } else if (date.month == 13) {
      const month = "pagume";
      return "${MaterialLocalizations.of(context).narrowWeekdays[date.weekday - ETDateTime.segno]}, $month ${date.day}, ${date.year}";
    }
    return MaterialLocalizations.of(context).formatFullDate(date);
  }

  String formatMediumDate(ETDateTime date) {
    if (globalLocale != null) {
      final day = ETDateUtils.getShortWeekDayNames(
        globalLocale,
      )[date.weekday - ETDateTime.segno];
      final month = ETDateUtils.getMonthNames(
        globalLocale,
      )[date.month - ETDateTime.meskerem];
      return "$day, $month ${date.day}";
    } else if (date.month == 13) {
      const month = "pagume";
      return "${MaterialLocalizations.of(context).narrowWeekdays[date.weekday - ETDateTime.segno]}, $month ${date.day}";
    }
    return MaterialLocalizations.of(context).formatMediumDate(date);
  }

  String formatShortMonthDay(ETDateTime date) {
    if (globalLocale != null) {
      final month = ETDateUtils.getShortMonthNames(
        globalLocale,
      )[date.month - ETDateTime.meskerem];
      return "$month ${date.day}";
    } else if (date.month == 13) {
      const month = "pag";
      return "$month ${date.day}";
    }
    return MaterialLocalizations.of(context).formatShortMonthDay(date);
  }

  String formatShortDate(ETDateTime date) {
    if (globalLocale != null) {
      final month = ETDateUtils.getShortMonthNames(
        globalLocale,
      )[date.month - ETDateTime.meskerem];
      return "$month ${date.day}, ${date.year}";
    } else if (date.month == 13) {
      const month = "pag";
      return "$month ${date.day}, ${date.year}";
    }
    return MaterialLocalizations.of(context).formatShortDate(date);
  }

  String formatYear(ETDateTime selectedDate) =>
      MaterialLocalizations.of(context).formatYear(selectedDate);

  String formatCompactDate(ETDateTime date) =>
      MaterialLocalizations.of(context).formatCompactDate(date);

  String formatDecimal(int value) =>
      MaterialLocalizations.of(context).formatDecimal(value);

  String dateRangeStartDateSemanticLabel(String label) =>
      MaterialLocalizations.of(context).dateRangeStartDateSemanticLabel(label);

  String dateRangeEndDateSemanticLabel(String label) =>
      MaterialLocalizations.of(context).dateRangeStartDateSemanticLabel(label);

  String get unspecifiedDateRange =>
      MaterialLocalizations.of(context).unspecifiedDateRange;

  String get dateHelpText {
    switch (globalLocale) {
      case "om":
        return OromiffaTexts.dateHelpText;
      case "so":
        return AfsomaliTexts.dateHelpText;
      case "ti":
        return TigrayTexts.dateHelpText;
    }
    return MaterialLocalizations.of(context).dateHelpText;
  }

  String get dateRangeStartLabel {
    switch (globalLocale) {
      case "om":
        return OromiffaTexts.dateRangeStartLabel;
      case "so":
        return AfsomaliTexts.dateRangeStartLabel;
      case "ti":
        return TigrayTexts.dateRangeStartLabel;
    }
    return MaterialLocalizations.of(context).dateRangeStartLabel;
  }

  String get dateRangeEndLabel {
    switch (globalLocale) {
      case "om":
        return OromiffaTexts.dateRangeEndLabel;
      case "so":
        return AfsomaliTexts.dateRangeEndLabel;
      case "ti":
        return TigrayTexts.dateRangeEndLabel;
    }
    return MaterialLocalizations.of(context).dateRangeEndLabel;
  }

  String get dateRangePickerHelpText {
    switch (globalLocale) {
      case "om":
        return OromiffaTexts.dateRangePickerHelpText;
      case "so":
        return AfsomaliTexts.dateRangePickerHelpText;
      case "ti":
        return TigrayTexts.dateRangePickerHelpText;
    }
    return MaterialLocalizations.of(context).dateRangePickerHelpText;
  }

  String get dateInputLabel {
    switch (globalLocale) {
      case "om":
        return OromiffaTexts.dateInputLabel;
      case "so":
        return AfsomaliTexts.dateInputLabel;
      case "ti":
        return TigrayTexts.dateInputLabel;
    }
    return MaterialLocalizations.of(context).dateInputLabel;
  }

  String get saveButtonLabel {
    switch (globalLocale) {
      case "om":
        return OromiffaTexts.saveButtonLabel;
      case "so":
        return AfsomaliTexts.saveButtonLabel;
      case "ti":
        return TigrayTexts.saveButtonLabel;
    }
    return MaterialLocalizations.of(context).saveButtonLabel;
  }

  String get previousMonthTooltip {
    switch (globalLocale) {
      case "om":
        return OromiffaTexts.previousMonthTooltip;
      case "so":
        return AfsomaliTexts.previousMonthTooltip;
      case "ti":
        return TigrayTexts.previousMonthTooltip;
    }
    return MaterialLocalizations.of(context).previousMonthTooltip;
  }

  String get nextMonthTooltip {
    switch (globalLocale) {
      case "om":
        return OromiffaTexts.nextMonthTooltip;
      case "so":
        return AfsomaliTexts.nextMonthTooltip;
      case "ti":
        return TigrayTexts.nextMonthTooltip;
    }
    return MaterialLocalizations.of(context).nextMonthTooltip;
  }

  String get cancelButtonLabel {
    switch (globalLocale) {
      case "om":
        return OromiffaTexts.cancelButtonLabel;
      case "so":
        return AfsomaliTexts.cancelButtonLabel;
      case "ti":
      case "am":
        return TigrayTexts.cancelButtonLabel;
    }
    return MaterialLocalizations.of(context).cancelButtonLabel;
  }

  String get okButtonLabel {
    switch (globalLocale) {
      case "om":
        return OromiffaTexts.okButtonLabel;
      case "so":
        return AfsomaliTexts.okButtonLabel;
      case "ti":
      case "am":
        return TigrayTexts.okButtonLabel;
    }
    return MaterialLocalizations.of(context).okButtonLabel;
  }

  String get inputDateModeButtonLabel {
    switch (globalLocale) {
      case "om":
        return OromiffaTexts.inputDateModeButtonLabel;
      case "so":
        return AfsomaliTexts.inputDateModeButtonLabel;
      case "ti":
        return TigrayTexts.inputDateModeButtonLabel;
    }
    return MaterialLocalizations.of(context).inputDateModeButtonLabel;
  }

  String get calendarModeButtonLabel {
    switch (globalLocale) {
      case "om":
        return OromiffaTexts.calendarModeButtonLabel;
      case "so":
        return AfsomaliTexts.calendarModeButtonLabel;
      case "ti":
        return TigrayTexts.calendarModeButtonLabel;
    }
    return MaterialLocalizations.of(context).calendarModeButtonLabel;
  }

  String get datePickerHelpText {
    switch (globalLocale) {
      case "om":
        return OromiffaTexts.datePickerHelpText;
      case "so":
        return AfsomaliTexts.datePickerHelpText;
      case "ti":
        return TigrayTexts.datePickerHelpText;
    }
    return MaterialLocalizations.of(context).datePickerHelpText;
  }

  String get currentDateLabel {
    switch (globalLocale) {
      case "om":
        return OromiffaTexts.currentDateLabel;
      case "so":
        return AfsomaliTexts.currentDateLabel;
      case "ti":
        return TigrayTexts.currentDateLabel;
      case "am":
        return AmharicTexts.currentDateLabel;
    }
    return MaterialLocalizations.of(context).currentDateLabel;
  }

  String get timePickerDialHelpText {
    switch (globalLocale) {
      case "om":
        return OromiffaTexts.timePickerDialHelpText;
      case "so":
        return AfsomaliTexts.timePickerDialHelpText;
      case "ti":
        return TigrayTexts.timePickerDialHelpText;
      case "am":
        return AmharicTexts.timePickerDialHelpText;
    }
    return MaterialLocalizations.of(context).timePickerDialHelpText;
  }

  String get timePickerInputHelpText {
    switch (globalLocale) {
      case "om":
        return OromiffaTexts.timePickerInputHelpText;
      case "so":
        return AfsomaliTexts.timePickerInputHelpText;
      case "ti":
        return TigrayTexts.timePickerInputHelpText;
      case "am":
        return AmharicTexts.timePickerInputHelpText;
    }
    return MaterialLocalizations.of(context).timePickerInputHelpText;
  }

  String get timePickerHourLabel {
    switch (globalLocale) {
      case "om":
        return OromiffaTexts.timePickerHourLabel;
      case "so":
        return AfsomaliTexts.timePickerHourLabel;
      case "ti":
        return TigrayTexts.timePickerHourLabel;
      case "am":
        return AmharicTexts.timePickerHourLabel;
    }
    return MaterialLocalizations.of(context).timePickerHourLabel;
  }

  String get timePickerMinuteLabel {
    switch (globalLocale) {
      case "om":
        return OromiffaTexts.timePickerMinuteLabel;
      case "so":
        return AfsomaliTexts.timePickerMinuteLabel;
      case "ti":
        return TigrayTexts.timePickerMinuteLabel;
      case "am":
        return AmharicTexts.timePickerMinuteLabel;
    }
    return MaterialLocalizations.of(context).timePickerMinuteLabel;
  }

  String get inputTimeModeButtonLabel {
    switch (globalLocale) {
      case "om":
        return OromiffaTexts.inputTimeModeButtonLabel;
      case "so":
        return AfsomaliTexts.inputTimeModeButtonLabel;
      case "ti":
        return TigrayTexts.inputTimeModeButtonLabel;
      case "am":
        return AmharicTexts.inputTimeModeButtonLabel;
    }
    return MaterialLocalizations.of(context).inputTimeModeButtonLabel;
  }

  String get dialModeButtonLabel {
    switch (globalLocale) {
      case "om":
        return OromiffaTexts.dialModeButtonLabel;
      case "so":
        return AfsomaliTexts.dialModeButtonLabel;
      case "ti":
        return TigrayTexts.dialModeButtonLabel;
      case "am":
        return AmharicTexts.dialModeButtonLabel;
    }
    return MaterialLocalizations.of(context).dialModeButtonLabel;
  }

  List<String> get narrowWeekdays {
    if (globalLocale != null) {
      return ETDateUtils.getNarrowWeekDayNames(globalLocale);
    }
    return MaterialLocalizations.of(context).narrowWeekdays;
  }
}

// ignore: avoid_classes_with_only_static_members
class OromiffaTexts {
  static String get dateHelpText => "gg/jj/wwww";
  static String get dateRangeStartLabel => "Guyyaa Jalqabaa";
  static String get dateRangeEndLabel => "Guyyaa Xumuraa";
  static String get dateRangePickerHelpText => "Daangaa filadhu";
  static String get dateInputLabel => "Guyyaa galchi";
  static String get saveButtonLabel => "kaa'i";
  static String get previousMonthTooltip => "ji'a darbe";
  static String get nextMonthTooltip => "ji'a itti aanu";
  static String get cancelButtonLabel => "Dhisii";
  static String get okButtonLabel => "Hayyee";
  static String get inputDateModeButtonLabel => "Gara galtee jijjiiri";
  static String get calendarModeButtonLabel => "Gara filannootti jijjiiri";
  static String get datePickerHelpText => "Guyyaa Filadhu";
  static String get currentDateLabel => "har'a";
  static String get timePickerDialHelpText => "yeroo filadhu";
  static String get timePickerInputHelpText => "Yeroo galchi";
  static String get timePickerMinuteLabel => "daqiiqaa";
  static String get timePickerHourLabel => "sa'a";
  static String get dialModeButtonLabel => "Gara haalata filannoo jijjiiri";
  static String get inputTimeModeButtonLabel =>
      "Gara haalata galtee barruutti jijjiiri";
}

// ignore: avoid_classes_with_only_static_members
class AmharicTexts {
  static String get currentDateLabel => "ዛሬ";
  static String get timePickerDialHelpText => "ጊዜ ምረጥ";
  static String get timePickerInputHelpText => "ጊዜ ጻፍ";
  static String get timePickerMinuteLabel => "ደቂቃ";
  static String get timePickerHourLabel => "ሰአት";
  static String get dialModeButtonLabel => "ወደ መራጭ ሁነታ ቀይር";
  static String get inputTimeModeButtonLabel => "ወደ የጽሑፍ ሁነታ ቀይር";
}

// ignore: avoid_classes_with_only_static_members
class AfsomaliTexts {
  static String get dateHelpText => "mm/bb/ssss";
  static String get dateRangeStartLabel => "Taariikhda Bilawga";
  static String get dateRangeEndLabel => "Taariikhda dhamaadka";
  static String get dateRangePickerHelpText => "Dooro kala duwan";
  static String get dateInputLabel => "Gali Taariikhda";
  static String get saveButtonLabel => "kaydinta";
  static String get previousMonthTooltip => "bishii hore";
  static String get nextMonthTooltip => "bisha soo socota";
  static String get cancelButtonLabel => "Jooji";
  static String get okButtonLabel => "OK";
  static String get inputDateModeButtonLabel => "U beddel gelinta";
  static String get calendarModeButtonLabel => "U beddelo kalandarka";
  static String get datePickerHelpText => "Taariikhda dooro";
  static String get currentDateLabel => "Maanta";
  static String get timePickerDialHelpText => "waqti dooro";
  static String get timePickerInputHelpText => "Gali wakhtiga";
  static String get timePickerMinuteLabel => "daqiiqo";
  static String get timePickerHourLabel => "saac";
  static String get dialModeButtonLabel => "U beddel qaabka";
  static String get inputTimeModeButtonLabel =>
      "U beddel habka gelinta qoraalka";
}

// ignore: avoid_classes_with_only_static_members
class TigrayTexts {
  static String get dateHelpText => "ዕዕ/ወወ/ዓዓዓዓ";
  static String get dateRangeStartLabel => "ዕለት ምጅማር";
  static String get dateRangeEndLabel => "መወዳእታ ዕለት";
  static String get dateRangePickerHelpText => "ደረጃ ምረጽ";
  static String get dateInputLabel => "ዕለት ኣእትዉ";
  static String get saveButtonLabel => "ዕቅብ";
  static String get previousMonthTooltip => "ዝሓለፈ ወርሒ";
  static String get nextMonthTooltip => "ዝመጽእ ወርሒ";
  static String get cancelButtonLabel => "ሰርዝ";
  static String get okButtonLabel => "እሺ";
  static String get inputDateModeButtonLabel => "ናብ ምእታው ምቕያር";
  static String get calendarModeButtonLabel => "ናብ ካላንደር ቀይር";
  static String get datePickerHelpText => "ዕለት ምረጽ";
  static String get currentDateLabel => "ሎምዓንቲ";
  static String get timePickerDialHelpText => "ግዜ ምረጽ";
  static String get timePickerInputHelpText => "ግዜ ኣእቱ";
  static String get timePickerMinuteLabel => "ደቒቓ";
  static String get timePickerHourLabel => "ሰአት";
  static String get dialModeButtonLabel => "ናብ ምምራጽ ቀይር";
  static String get inputTimeModeButtonLabel => "ናብ ናይ ጽሑፍ ምእታው ቀይር";
}

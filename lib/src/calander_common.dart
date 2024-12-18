import "package:ethiopian_datetime/ethiopian_datetime.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

/// List of supported Ethiopian language codes for localization.
const List<String> supportedETLanguageCodes = <String>[
  "om",
  "so",
  "ti",
  "am",
  "en",
];

///List of locales that are not supported by global Material Localization delege
const List<String> unsupportedMaterialCodes = <String>["om", "so", "ti"];

/// variable to manage the global locale setting for Ethiopian languages.
String? _locale;
set setLocale(String? value) {
  _locale = supportedETLanguageCodes.contains(value) ? value : null;
}

/// Getter to retrieve the global locale set for Ethiopian languages.
String? get globalLocale => _locale;

// A restorable [DatePickerEntryMode] value.
//
// This serializes each entry as a unique `int` value.
class ETRestorableDatePickerEntryMode
    extends RestorableValue<DatePickerEntryMode> {
  ETRestorableDatePickerEntryMode(
    DatePickerEntryMode defaultValue,
  ) : _defaultValue = defaultValue;

  final DatePickerEntryMode _defaultValue;

  @override
  DatePickerEntryMode createDefaultValue() => _defaultValue;

  @override
  void didUpdateValue(DatePickerEntryMode? oldValue) {
    assert(debugIsSerializableForRestoration(value.index));
    notifyListeners();
  }

  @override
  DatePickerEntryMode fromPrimitives(Object? data) =>
      DatePickerEntryMode.values[data! as int];

  @override
  Object? toPrimitives() => value.index;
}

// A restorable [AutovalidateMode] value.
//
// This serializes each entry as a unique `int` value.
class ETRestorableAutovalidateMode extends RestorableValue<AutovalidateMode> {
  ETRestorableAutovalidateMode(
    AutovalidateMode defaultValue,
  ) : _defaultValue = defaultValue;

  final AutovalidateMode _defaultValue;

  @override
  AutovalidateMode createDefaultValue() => _defaultValue;

  @override
  void didUpdateValue(AutovalidateMode? oldValue) {
    assert(debugIsSerializableForRestoration(value.index));
    notifyListeners();
  }

  @override
  AutovalidateMode fromPrimitives(Object? data) =>
      AutovalidateMode.values[data! as int];

  @override
  Object? toPrimitives() => value.index;
}

/// A [RestorableValue] that knows how to save and restore [ETDateTime] that is
/// nullable.
///
/// {@macro flutter.widgets.RestorableNum}.
class RestorableETDateTimeN extends RestorableValue<ETDateTime?> {
  /// Creates a [RestorableDateTime].
  ///
  /// {@macro flutter.widgets.RestorableNum.constructor}
  RestorableETDateTimeN(ETDateTime? defaultValue)
      : _defaultValue = defaultValue;

  final ETDateTime? _defaultValue;

  @override
  ETDateTime? createDefaultValue() => _defaultValue;

  @override
  void didUpdateValue(ETDateTime? oldValue) {
    assert(debugIsSerializableForRestoration(value?.millisecondsSinceEpoch));
    notifyListeners();
  }

  @override
  ETDateTime? fromPrimitives(Object? data) => data != null
      ? DateTime.fromMillisecondsSinceEpoch(data as int).convertToEthiopian()
      : null;

  @override
  Object? toPrimitives() => value?.millisecondsSinceEpoch;
}

/// InheritedWidget indicating what the current focused date is for its children.
///
/// This is used by the (MonthPicker) to let its children (DayPicker)s know
/// what the currently focused date (if any) should be.
class ETFocusedDate extends InheritedWidget {
  const ETFocusedDate({
    required super.child,
    super.key,
    this.date,
    this.scrollDirection,
  });

  final ETDateTime? date;
  final TraversalDirection? scrollDirection;

  @override
  bool updateShouldNotify(ETFocusedDate oldWidget) =>
      !ETDateUtils.isSameDay(date, oldWidget.date) ||
      scrollDirection != oldWidget.scrollDirection;

  static ETFocusedDate? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ETFocusedDate>();
}

// TimeOfDayFormat timeOfDayFormat(BuildContext context,
//     [bool alwaysUse24HourFormat = false,]) {
//   return alwaysUse24HourFormat
//       ? TimeOfDayFormat.HH_colon_mm
//       : TimeOfDayFormat.h_colon_mm_space_a;
// }

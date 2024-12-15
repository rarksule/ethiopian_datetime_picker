// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import "dart:math" as math;

import "package:ethiopian_datetime/ethiopian_datetime.dart";
import "package:ethiopian_datetime_picker/src/calander_common.dart";
import "package:ethiopian_datetime_picker/src/calendar_etdate_picker.dart";
import "package:ethiopian_datetime_picker/src/etdate_picker_header.dart";
import "package:ethiopian_datetime_picker/src/input_etdate_picker_form_field.dart";
import "package:ethiopian_datetime_picker/src/string_text.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_localizations/flutter_localizations.dart";

// The M3 sizes are coming from the tokens, but are hand coded,
// as the current token DB does not contain landscape versions.
const Size _calendarPortraitDialogSizeM2 = Size(330, 518);
const Size _calendarPortraitDialogSizeM3 = Size(328, 512);
const Size _calendarLandscapeDialogSize = Size(496, 346);
const Size _inputPortraitDialogSizeM2 = Size(330, 270);
const Size _inputPortraitDialogSizeM3 = Size(328, 270);
const Size _inputLandscapeDialogSize = Size(496, 160);
const Duration _dialogSizeAnimationDuration = Duration(milliseconds: 200);
const double _inputFormPortraitHeight = 98;
const double _inputFormLandscapeHeight = 108;
const double _kMaxTextScaleFactor = 1.3;

/// Shows a dialog containing a Material Design date picker.
///
/// The returned [Future] resolves to the date selected by the user when the
/// user confirms the dialog. If the user cancels the dialog, null is returned.
///
/// When the date picker is first displayed, if [initialDate] is not null, it
/// will show the month of [initialDate], with [initialDate] selected. Otherwise
/// it will show the [currentDate]'s month.
///
/// The [firstDate] is the earliest allowable date. The [lastDate] is the latest
/// allowable date. If [initialDate] is not null, it must either fall between
/// these dates, or be equal to one of them. For each of these [ETDateTime]
/// parameters, only their dates are considered. Their time fields are ignored.
/// They must all be non-null.
///
/// The [currentDate] represents the current day (i.e. today). This
/// date will be highlighted in the day grid. If null, the date of
/// [ETDateTime.now] will be used.
///
/// An optional [initialEntryMode] argument can be used to display the date
/// picker in the [DatePickerEntryMode.calendar] (a calendar month grid)
/// or [DatePickerEntryMode.input] (a text input field) mode.
/// It defaults to [DatePickerEntryMode.calendar].
///
/// {@template flutter.material.date_picker.switchToInputEntryModeIcon}
/// An optional [switchToInputEntryModeIcon] argument can be used to
/// display a custom Icon in the corner of the dialog
/// when [DatePickerEntryMode] is [DatePickerEntryMode.calendar]. Clicking on
/// icon changes the [DatePickerEntryMode] to [DatePickerEntryMode.input].
/// If null, `Icon(useMaterial3 ? Icons.edit_outlined : Icons.edit)` is used.
/// {@endtemplate}
///
/// {@template flutter.material.date_picker.switchToCalendarEntryModeIcon}
/// An optional [switchToCalendarEntryModeIcon] argument can be used to
/// display a custom Icon in the corner of the dialog
/// when [DatePickerEntryMode] is [DatePickerEntryMode.input]. Clicking on
/// icon changes the [DatePickerEntryMode] to [DatePickerEntryMode.calendar].
/// If null, `Icon(Icons.calendar_today)` is used.
/// {@endtemplate}
///
/// An optional [selectableDayPredicate] function can be passed in to only allow
/// certain days for selection. If provided, only the days that
/// [selectableDayPredicate] returns true for will be selectable. For example,
/// this can be used to only allow weekdays for selection. If provided, it must
/// return true for [initialDate].
///
/// The following optional string parameters allow you to override the default
/// text used for various parts of the dialog:
///
///   * [helpText], label displayed at the top of the dialog.
///   * [cancelText], label on the cancel button.
///   * [confirmText], label on the ok button.
///   * [errorFormatText], message used when the input text isn't in a proper date format.
///   * [errorInvalidText], message used when the input text isn't a selectable date.
///   * [fieldHintText], text used to prompt the user when no text has been entered in the field.
///   * [fieldLabelText], label for the date text input field.
///
/// An optional [locale] argument can be used to set the locale for the date
/// picker. It defaults to the ambient locale provided by [Localizations].
///
/// An optional [textDirection] argument can be used to set the text direction
/// ([TextDirection.ltr] or [TextDirection.rtl]) for the date picker. It
/// defaults to the ambient text direction provided by [Directionality]. If both
/// [locale] and [textDirection] are non-null, [textDirection] overrides the
/// direction chosen for the [locale].
///
/// The [context], [barrierDismissible], [barrierColor], [barrierLabel],
/// [useRootNavigator] and [routeSettings] arguments are passed to [showDialog],
/// the documentation for which discusses how it is used.
///
/// The [builder] parameter can be used to wrap the dialog widget
/// to add inherited widgets like [Theme].
///
/// An optional [initialDatePickerMode] argument can be used to have the
/// calendar date picker initially appear in the [DatePickerMode.year] or
/// [DatePickerMode.day] mode. It defaults to [DatePickerMode.day].
///
/// {@macro flutter.widgets.RawDialogRoute}
///
/// ### State Restoration
///
/// Using this method will not enable state restoration for the date picker.
/// In order to enable state restoration for a date picker, use
/// [Navigator.restorablePush] or [Navigator.restorablePushNamed] with
/// [ETDatePickerDialog].
///
/// For more information about state restoration, see [RestorationManager].
///
/// {@macro flutter.widgets.RestorationManager}
///
/// {@tool dartpad}
/// This sample demonstrates how to create a restorable Material date picker.
/// This is accomplished by enabling state restoration by specifying
/// [MaterialApp.restorationScopeId] and using [Navigator.restorablePush] to
/// push [ETDatePickerDialog] when the button is tapped.
///
/// ** See code in examples/api/lib/material/date_picker/show_date_picker.0.dart **
/// {@end-tool}
///
/// See also:
///
///  * [showDateRangePicker], which shows a Material Design date range picker
///    used to select a range of dates.
///  * [CalendarDatePicker], which provides the calendar grid used by the date picker dialog.
///  * [InputDatePickerFormField], which provides a text input field for entering dates.
///  * [DisplayFeatureSubScreen], which documents the specifics of how
///    (DisplayFeature)s can split the screen into sub-screens.
///  * [showTimePicker], which shows a dialog that contains a Material Design time picker.
Future<ETDateTime?> showETDatePicker({
  required BuildContext context,
  required ETDateTime firstDate,
  required ETDateTime lastDate,
  ETDateTime? initialDate,
  ETDateTime? currentDate,
  DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
  SelectableDayPredicate? selectableDayPredicate,
  String? helpText,
  String? cancelText,
  String? confirmText,
  Locale? locale,
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  TextDirection? textDirection,
  TransitionBuilder? builder,
  DatePickerMode initialDatePickerMode = DatePickerMode.day,
  String? errorFormatText,
  String? errorInvalidText,
  String? fieldHintText,
  String? fieldLabelText,
  TextInputType? keyboardType,
  Offset? anchorPoint,
  ValueChanged<DatePickerEntryMode>? onDatePickerModeChange,
  Icon? switchToInputEntryModeIcon,
  Icon? switchToCalendarEntryModeIcon,
}) async {
  initialDate = initialDate == null ? null : ETDateUtils.dateOnly(initialDate);
  firstDate = ETDateUtils.dateOnly(firstDate);
  lastDate = ETDateUtils.dateOnly(lastDate);
  assert(
    !lastDate.isBefore(firstDate),
    "lastDate $lastDate must be on or after firstDate $firstDate.",
  );
  assert(
    initialDate == null || !initialDate.isBefore(firstDate),
    "initialDate $initialDate must be on or after firstDate $firstDate.",
  );
  assert(
    initialDate == null || !initialDate.isAfter(lastDate),
    "initialDate $initialDate must be on or before lastDate $lastDate.",
  );
  assert(
    selectableDayPredicate == null ||
        initialDate == null ||
        selectableDayPredicate(initialDate),
    "Provided initialDate $initialDate must satisfy provided selectableDayPredicate.",
  );
  assert(debugCheckHasMaterialLocalizations(context));

  Widget dialog = ETDatePickerDialog(
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    currentDate: currentDate,
    initialEntryMode: initialEntryMode,
    selectableDayPredicate: selectableDayPredicate,
    helpText: helpText,
    cancelText: cancelText,
    confirmText: confirmText,
    initialCalendarMode: initialDatePickerMode,
    errorFormatText: errorFormatText,
    errorInvalidText: errorInvalidText,
    fieldHintText: fieldHintText,
    fieldLabelText: fieldLabelText,
    keyboardType: keyboardType,
    onDatePickerModeChange: onDatePickerModeChange,
    switchToInputEntryModeIcon: switchToInputEntryModeIcon,
    switchToCalendarEntryModeIcon: switchToCalendarEntryModeIcon,
  );

  if (textDirection != null) {
    dialog = Directionality(
      textDirection: textDirection,
      child: dialog,
    );
  }
  setLocale =
      locale?.languageCode ?? Localizations.localeOf(context).languageCode;
  if (locale != null) {
    dialog = Localizations.override(
      context: context,

      // ignore: strict_raw_type
      delegates: const <LocalizationsDelegate>[
        GlobalMaterialLocalizations.delegate,
      ],
      locale: Locale(
        unsupportedMaterialCodes.contains(globalLocale)
            ? "en"
            : globalLocale ?? locale.languageCode,
      ),
      child: dialog,
    );
  }

  return showDialog<ETDateTime>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    barrierLabel: barrierLabel,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    builder: (context) =>
        builder == null ? dialog : builder(context, dialog),
    anchorPoint: anchorPoint,
  );
}

/// A Material-style date picker dialog.
///
/// It is used internally by [showDatePicker] or can be directly pushed
/// onto the [Navigator] stack to enable state restoration. See
/// [showDatePicker] for a state restoration app example.
///
/// See also:
///
///  * [showDatePicker], which is a way to display the date picker.
class ETDatePickerDialog extends StatefulWidget {
  /// A Material-style date picker dialog.
  ETDatePickerDialog({
    required ETDateTime firstDate,
    required ETDateTime lastDate,
    super.key,
    ETDateTime? initialDate,
    ETDateTime? currentDate,
    this.initialEntryMode = DatePickerEntryMode.calendar,
    this.selectableDayPredicate,
    this.cancelText,
    this.confirmText,
    this.helpText,
    this.initialCalendarMode = DatePickerMode.day,
    this.errorFormatText,
    this.errorInvalidText,
    this.fieldHintText,
    this.fieldLabelText,
    this.keyboardType,
    this.restorationId,
    this.onDatePickerModeChange,
    this.switchToInputEntryModeIcon,
    this.switchToCalendarEntryModeIcon,
  })  : initialDate =
            initialDate == null ? null : ETDateUtils.dateOnly(initialDate),
        firstDate = ETDateUtils.dateOnly(firstDate),
        lastDate = ETDateUtils.dateOnly(lastDate),
        currentDate = ETDateUtils.dateOnly(currentDate ?? ETDateTime.now()) {
    assert(
      !this.lastDate.isBefore(this.firstDate),
      "lastDate ${this.lastDate} must be on or after firstDate ${this.firstDate}.",
    );
    assert(
      initialDate == null || !this.initialDate!.isBefore(this.firstDate),
      "initialDate ${this.initialDate} must be on or after firstDate ${this.firstDate}.",
    );
    assert(
      initialDate == null || !this.initialDate!.isAfter(this.lastDate),
      "initialDate ${this.initialDate} must be on or before lastDate ${this.lastDate}.",
    );
    assert(
      selectableDayPredicate == null ||
          initialDate == null ||
          selectableDayPredicate!(this.initialDate!),
      "Provided initialDate ${this.initialDate} must satisfy provided selectableDayPredicate",
    );
  }

  /// The initially selected [ETDateTime] that the picker should display.
  ///
  /// If this is null, there is no selected date. A date must be selected to
  /// submit the dialog.
  final ETDateTime? initialDate;

  /// The earliest allowable [ETDateTime] that the user can select.
  final ETDateTime firstDate;

  /// The latest allowable [ETDateTime] that the user can select.
  final ETDateTime lastDate;

  /// The [ETDateTime] representing today. It will be highlighted in the day grid.
  final ETDateTime currentDate;

  /// The initial mode of date entry method for the date picker dialog.
  ///
  /// See [DatePickerEntryMode] for more details on the different data entry
  /// modes available.
  final DatePickerEntryMode initialEntryMode;

  /// Function to provide full control over which [ETDateTime] can be selected.
  final SelectableDayPredicate? selectableDayPredicate;

  /// The text that is displayed on the cancel button.
  final String? cancelText;

  /// The text that is displayed on the confirm button.
  final String? confirmText;

  /// The text that is displayed at the top of the header.
  ///
  /// This is used to indicate to the user what they are selecting a date for.
  final String? helpText;

  /// The initial display of the calendar picker.
  final DatePickerMode initialCalendarMode;

  /// The error text displayed if the entered date is not in the correct format.
  final String? errorFormatText;

  /// The error text displayed if the date is not valid.
  ///
  /// A date is not valid if it is earlier than [firstDate], later than
  /// [lastDate], or doesn't pass the [selectableDayPredicate].
  final String? errorInvalidText;

  /// The hint text displayed in the [TextField].
  ///
  /// If this is null, it will default to the date format string. For example,
  /// 'mm/dd/yyyy' for en_US.
  final String? fieldHintText;

  /// The label text displayed in the [TextField].
  ///
  /// If this is null, it will default to the words representing the date format
  /// string. For example, 'Month, Day, Year' for en_US.
  final String? fieldLabelText;

  /// {@template flutter.material.datePickerDialog}
  /// The keyboard type of the [TextField].
  ///
  /// If this is null, it will default to [TextInputType.datetime]
  /// {@endtemplate}
  final TextInputType? keyboardType;

  /// Restoration ID to save and restore the state of the [ETDatePickerDialog].
  ///
  /// If it is non-null, the date picker will persist and restore the
  /// date selected on the dialog.
  ///
  /// The state of this widget is persisted in a [RestorationBucket] claimed
  /// from the surrounding [RestorationScope] using the provided restoration ID.
  ///
  /// See also:
  ///
  ///  * [RestorationManager], which explains how state restoration works in
  ///    Flutter.
  final String? restorationId;

  /// Called when the [ETDatePickerDialog] is toggled between
  /// [DatePickerEntryMode.calendar],[DatePickerEntryMode.input].
  ///
  /// An example of how this callback might be used is an app that saves the
  /// user's preferred entry mode and uses it to initialize the
  /// `initialEntryMode` parameter the next time the date picker is shown.
  final ValueChanged<DatePickerEntryMode>? onDatePickerModeChange;

  /// {@macro flutter.material.date_picker.switchToInputEntryModeIcon}
  final Icon? switchToInputEntryModeIcon;

  /// {@macro flutter.material.date_picker.switchToCalendarEntryModeIcon}
  final Icon? switchToCalendarEntryModeIcon;

  @override
  State<ETDatePickerDialog> createState() => _ETDatePickerDialogState();
}

class _ETDatePickerDialogState extends State<ETDatePickerDialog>
    with RestorationMixin {
  late final RestorableETDateTimeN _selectedDate =
      RestorableETDateTimeN(widget.initialDate);
  late final ETRestorableDatePickerEntryMode _entryMode =
      ETRestorableDatePickerEntryMode(widget.initialEntryMode);
  final ETRestorableAutovalidateMode _autovalidateMode =
      ETRestorableAutovalidateMode(AutovalidateMode.disabled);

  @override
  void dispose() {
    _selectedDate.dispose();
    _entryMode.dispose();
    _autovalidateMode.dispose();
    super.dispose();
  }

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedDate, "selected_date");
    registerForRestoration(_autovalidateMode, "autovalidateMode");
    registerForRestoration(_entryMode, "calendar_entry_mode");
  }

  final GlobalKey _calendarPickerKey = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _handleOk() {
    if (_entryMode.value == DatePickerEntryMode.input ||
        _entryMode.value == DatePickerEntryMode.inputOnly) {
      final form = _formKey.currentState!;
      if (!form.validate()) {
        setState(() => _autovalidateMode.value = AutovalidateMode.always);
        return;
      }
      form.save();
    }
    Navigator.pop(context, _selectedDate.value);
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  void _handleOnDatePickerModeChange() {
    widget.onDatePickerModeChange?.call(_entryMode.value);
  }

  void _handleEntryModeToggle() {
    setState(() {
      switch (_entryMode.value) {
        case DatePickerEntryMode.calendar:
          _autovalidateMode.value = AutovalidateMode.disabled;
          _entryMode.value = DatePickerEntryMode.input;
          _handleOnDatePickerModeChange();
        case DatePickerEntryMode.input:
          _formKey.currentState!.save();
          _entryMode.value = DatePickerEntryMode.calendar;
          _handleOnDatePickerModeChange();
        case DatePickerEntryMode.calendarOnly:
        case DatePickerEntryMode.inputOnly:
          assert(false, "Can not change entry mode from ${_entryMode.value}");
      }
    });
  }

  void _handleDateChanged(ETDateTime date) {
    setState(() {
      _selectedDate.value = date;
    });
  }

  Size _dialogSize(BuildContext context) {
    final useMaterial3 = Theme.of(context).useMaterial3;
    final orientation = MediaQuery.orientationOf(context);

    switch (_entryMode.value) {
      case DatePickerEntryMode.calendar:
      case DatePickerEntryMode.calendarOnly:
        switch (orientation) {
          case Orientation.portrait:
            return useMaterial3
                ? _calendarPortraitDialogSizeM3
                : _calendarPortraitDialogSizeM2;
          case Orientation.landscape:
            return _calendarLandscapeDialogSize;
        }
      case DatePickerEntryMode.input:
      case DatePickerEntryMode.inputOnly:
        switch (orientation) {
          case Orientation.portrait:
            return useMaterial3
                ? _inputPortraitDialogSizeM3
                : _inputPortraitDialogSizeM2;
          case Orientation.landscape:
            return _inputLandscapeDialogSize;
        }
    }
  }

  static const Map<ShortcutActivator, Intent> _formShortcutMap =
      <ShortcutActivator, Intent>{
    // Pressing enter on the field will move focus to the next field or control.
    SingleActivator(LogicalKeyboardKey.enter): NextFocusIntent(),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final useMaterial3 = theme.useMaterial3;
    final localized = Localized(context);
    final orientation = MediaQuery.orientationOf(context);
    final datePickerTheme = DatePickerTheme.of(context);
    final defaults = DatePickerTheme.defaults(context);
    final textTheme = theme.textTheme;

    // There's no M3 spec for a landscape layout input (not calendar)
    // date picker. To ensure that the date displayed in the input
    // date picker's header fits in landscape mode, we override the M3
    // default here.
    TextStyle? headlineStyle;
    if (useMaterial3) {
      headlineStyle =
          datePickerTheme.headerHeadlineStyle ?? defaults.headerHeadlineStyle;
      switch (_entryMode.value) {
        case DatePickerEntryMode.input:
        case DatePickerEntryMode.inputOnly:
          if (orientation == Orientation.landscape) {
            headlineStyle = textTheme.headlineSmall;
          }
        case DatePickerEntryMode.calendar:
        case DatePickerEntryMode.calendarOnly:
        // M3 default is OK.
      }
    } else {
      headlineStyle = orientation == Orientation.landscape
          ? textTheme.headlineSmall
          : textTheme.headlineMedium;
    }
    final headerForegroundColor =
        datePickerTheme.headerForegroundColor ?? defaults.headerForegroundColor;
    headlineStyle = headlineStyle?.copyWith(color: headerForegroundColor);

    final Widget actions = Container(
      alignment: AlignmentDirectional.centerEnd,
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: OverflowBar(
        spacing: 8,
        children: <Widget>[
          TextButton(
            style:
                datePickerTheme.cancelButtonStyle ?? defaults.cancelButtonStyle,
            onPressed: _handleCancel,
            child: Text(
              widget.cancelText ??
                  (useMaterial3
                      ? localized.cancelButtonLabel
                      : localized.cancelButtonLabel.toUpperCase()),
            ),
          ),
          TextButton(
            style: datePickerTheme.confirmButtonStyle ??
                defaults.confirmButtonStyle,
            onPressed: _handleOk,
            child: Text(widget.confirmText ?? localized.okButtonLabel),
          ),
        ],
      ),
    );

    ETCalendarDatePicker calendarDatePicker() => ETCalendarDatePicker(
          key: _calendarPickerKey,
          initialDate: _selectedDate.value,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          currentDate: widget.currentDate,
          onDateChanged: _handleDateChanged,
          selectableDayPredicate: widget.selectableDayPredicate,
          initialCalendarMode: widget.initialCalendarMode,
        );

    Form inputDatePicker() => Form(
          key: _formKey,
          autovalidateMode: _autovalidateMode.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            height: orientation == Orientation.portrait
                ? _inputFormPortraitHeight
                : _inputFormLandscapeHeight,
            child: Shortcuts(
              shortcuts: _formShortcutMap,
              child: Column(
                children: <Widget>[
                  const Spacer(),
                  InputETDatePickerFormField(
                    initialDate: _selectedDate.value,
                    firstDate: widget.firstDate,
                    lastDate: widget.lastDate,
                    onDateSubmitted: _handleDateChanged,
                    onDateSaved: _handleDateChanged,
                    selectableDayPredicate: widget.selectableDayPredicate,
                    errorFormatText: widget.errorFormatText,
                    errorInvalidText: widget.errorInvalidText,
                    fieldHintText: widget.fieldHintText,
                    fieldLabelText: widget.fieldLabelText,
                    keyboardType: widget.keyboardType,
                    autofocus: true,
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        );

    final Widget picker;
    final Widget? entryModeButton;
    switch (_entryMode.value) {
      case DatePickerEntryMode.calendar:
        picker = calendarDatePicker();
        entryModeButton = IconButton(
          icon: widget.switchToInputEntryModeIcon ??
              Icon(useMaterial3 ? Icons.edit_outlined : Icons.edit),
          color: headerForegroundColor,
          tooltip: localized.inputDateModeButtonLabel,
          onPressed: _handleEntryModeToggle,
        );
      case DatePickerEntryMode.calendarOnly:
        picker = calendarDatePicker();
        entryModeButton = null;
      case DatePickerEntryMode.input:
        picker = inputDatePicker();
        entryModeButton = IconButton(
          icon: widget.switchToCalendarEntryModeIcon ??
              const Icon(Icons.calendar_today),
          color: headerForegroundColor,
          tooltip: localized.calendarModeButtonLabel,
          onPressed: _handleEntryModeToggle,
        );
      case DatePickerEntryMode.inputOnly:
        picker = inputDatePicker();
        entryModeButton = null;
    }

    final Widget header = ETDatePickerHeader(
      helpText: widget.helpText ??
          (useMaterial3
              ? localized.datePickerHelpText
              : localized.datePickerHelpText.toUpperCase()),
      titleText: _selectedDate.value == null
          ? ""
          : localized.formatMediumDate(_selectedDate.value!),
      titleStyle: headlineStyle,
      orientation: orientation,
      isShort: orientation == Orientation.landscape,
      entryModeButton: entryModeButton,
    );

    // Constrain the textScaleFactor to the largest supported value to prevent
    // layout issues.
    final textScaleFactor = MediaQuery.textScalerOf(context)
        .clamp(maxScaleFactor: _kMaxTextScaleFactor)
        .scale(1);

    final dialogSize = _dialogSize(context) * textScaleFactor;
    final dialogTheme = theme.dialogTheme;
    return Dialog(
      backgroundColor:
          datePickerTheme.backgroundColor ?? defaults.backgroundColor,
      elevation: useMaterial3
          ? datePickerTheme.elevation ?? defaults.elevation!
          : datePickerTheme.elevation ?? dialogTheme.elevation ?? 24,
      shadowColor: datePickerTheme.shadowColor ?? defaults.shadowColor,
      surfaceTintColor:
          datePickerTheme.surfaceTintColor ?? defaults.surfaceTintColor,
      shape: useMaterial3
          ? datePickerTheme.shape ?? defaults.shape
          : datePickerTheme.shape ?? dialogTheme.shape ?? defaults.shape,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: AnimatedContainer(
        width: dialogSize.width,
        height: dialogSize.height,
        duration: _dialogSizeAnimationDuration,
        curve: Curves.easeIn,
        child: MediaQuery.withClampedTextScaling(
          // Constrain the textScaleFactor to the largest supported value to prevent
          // layout issues.
          maxScaleFactor: _kMaxTextScaleFactor,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final portraitDialogSize = useMaterial3
                  ? _inputPortraitDialogSizeM3
                  : _inputPortraitDialogSizeM2;
              // Make sure the portrait dialog can fit the contents comfortably when
              // resized from the landscape dialog.
              final isFullyPortrait = constraints.maxHeight >=
                  math.min(dialogSize.height, portraitDialogSize.height);

              switch (orientation) {
                case Orientation.portrait:
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      header,
                      if (useMaterial3)
                        Divider(height: 0, color: datePickerTheme.dividerColor),
                      if (isFullyPortrait) ...<Widget>[
                        Expanded(child: picker),
                        actions,
                      ],
                    ],
                  );
                case Orientation.landscape:
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      header,
                      if (useMaterial3)
                        VerticalDivider(
                          width: 0,
                          color: datePickerTheme.dividerColor,
                        ),
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Expanded(child: picker),
                            actions,
                          ],
                        ),
                      ),
                    ],
                  );
              }
            },
          ),
        ),
      ),
    );
  }
}

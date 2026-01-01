import "package:ethiopian_datetime/ethiopian_datetime.dart";
import "package:ethiopian_datetime_picker/src/calander_common.dart";
import "package:ethiopian_datetime_picker/src/calander_etdate_range_picker.dart";
import "package:ethiopian_datetime_picker/src/input_etdate_range_picker.dart";
import "package:ethiopian_datetime_picker/src/string_text.dart";
import "package:flutter/material.dart";
import "package:flutter_localizations/flutter_localizations.dart";

const double _inputFormPortraitHeight = 98;
const double _inputFormLandscapeHeight = 108;
const Size _inputPortraitDialogSizeM2 = Size(330, 270);
const Size _inputPortraitDialogSizeM3 = Size(328, 270);
const Size _inputRangeLandscapeDialogSize = Size(496, 164);
const Duration _dialogSizeAnimationDuration = Duration(milliseconds: 200);
const double _kMaxTextScaleFactor = 1.3;

/// Shows a full screen modal dialog containing a Material Design date range
/// picker.
///
/// The returned [Future] resolves to the [ETDateTimeRange] selected by the user
/// when the user saves their selection. If the user cancels the dialog, null is
/// returned.
///
/// If [initialDateRange] is non-null, then it will be used as the initially
/// selected date range. If it is provided, `initialDateRange.start` must be
/// before or on `initialDateRange.end`.
///
/// The [firstDate] is the earliest allowable date. The [lastDate] is the latest
/// allowable date.
///
/// If an initial date range is provided, `initialDateRange.start`
/// and `initialDateRange.end` must both fall between or on [firstDate] and
/// [lastDate]. For all of these [ETDateTime] values, only their dates are
/// considered. Their time fields are ignored.
///
/// The [currentDate] represents the current day (i.e. today). This
/// date will be highlighted in the day grid. If null, the date of
/// `ETDateTime.now()` will be used.
///
/// An optional [initialEntryMode] argument can be used to display the date
/// picker in the [DatePickerEntryMode.calendar] (a scrollable calendar month
/// grid) or [DatePickerEntryMode.input] (two text input fields) mode.
/// It defaults to [DatePickerEntryMode.calendar].
///
/// {@macro flutter.material.date_picker.switchToInputEntryModeIcon}
///
/// {@macro flutter.material.date_picker.switchToCalendarEntryModeIcon}
///
/// The following optional string parameters allow you to override the default
/// text used for various parts of the dialog:
///
///   * [helpText], the label displayed at the top of the dialog.
///   * [cancelText], the label on the cancel button for the text input mode.
///   * [confirmText],the label on the ok button for the text input mode.
///   * [saveText], the label on the save button for the fullscreen calendar
///     mode.
///   * [errorFormatText], the message used when an input text isn't in a proper
///     date format.
///   * [errorInvalidText], the message used when an input text isn't a
///     selectable date.
///   * [errorInvalidRangeText], the message used when the date range is
///     invalid (e.g. start date is after end date).
///   * [fieldStartHintText], the text used to prompt the user when no text has
///     been entered in the start field.
///   * [fieldEndHintText], the text used to prompt the user when no text has
///     been entered in the end field.
///   * [fieldStartLabelText], the label for the start date text input field.
///   * [fieldEndLabelText], the label for the end date text input field.
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
/// {@macro flutter.widgets.RawDialogRoute}
///
/// ### State Restoration
///
/// Using this method will not enable state restoration for the date range picker.
/// In order to enable state restoration for a date range picker, use
/// [Navigator.restorablePush] or [Navigator.restorablePushNamed] with
/// [ETDateRangePickerDialog].
///
/// For more information about state restoration, see (RestorationManager).
///
/// {@macro flutter.widgets.RestorationManager}
///
/// {@tool sample}
/// This sample demonstrates how to create a restorable Material date range picker.
/// This is accomplished by enabling state restoration by specifying
/// [MaterialApp.restorationScopeId] and using [Navigator.restorablePush] to
/// push [ETDateRangePickerDialog] when the button is tapped.
///
/// ** See code in examples/api/lib/material/date_picker/show_date_range_picker.0.dart **
/// {@end-tool}
///
/// See also:
///
///  * [showDatePicker], which shows a Material Design date picker used to
///    select a single date.
///  * [ETDateTimeRange], which is used to describe a date range.
///  * [DisplayFeatureSubScreen], which documents the specifics of how
///    (DisplayFeature)s can split the screen into sub-screens.
Future<ETDateTimeRange?> showETDateRangePicker({
  required BuildContext context,
  required ETDateTime firstDate,
  required ETDateTime lastDate,
  ETDateTimeRange? initialDateRange,
  ETDateTime? currentDate,
  DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
  String? helpText,
  String? cancelText,
  String? confirmText,
  String? saveText,
  String? errorFormatText,
  String? errorInvalidText,
  String? errorInvalidRangeText,
  String? fieldStartHintText,
  String? fieldEndHintText,
  String? fieldStartLabelText,
  String? fieldEndLabelText,
  Locale? locale,
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  TextDirection? textDirection,
  TransitionBuilder? builder,
  Offset? anchorPoint,
  TextInputType keyboardType = TextInputType.datetime,
  Icon? switchToInputEntryModeIcon,
  Icon? switchToCalendarEntryModeIcon,
}) async {
  assert(
    initialDateRange == null ||
        !initialDateRange.start.isAfter(initialDateRange.end),
    "initialDateRange's start date must not be after it's end date.",
  );
  initialDateRange =
      initialDateRange == null ? null : Utils.datesOnly(initialDateRange);
  firstDate = ETDateUtils.dateOnly(firstDate);
  lastDate = ETDateUtils.dateOnly(lastDate);
  assert(
    !lastDate.isBefore(firstDate),
    "lastDate $lastDate must be on or after firstDate $firstDate.",
  );
  assert(
    initialDateRange == null || !initialDateRange.start.isBefore(firstDate),
    "initialDateRange's start date must be on or after firstDate $firstDate.",
  );
  assert(
    initialDateRange == null || !initialDateRange.end.isBefore(firstDate),
    "initialDateRange's end date must be on or after firstDate $firstDate.",
  );
  assert(
    initialDateRange == null || !initialDateRange.start.isAfter(lastDate),
    "initialDateRange's start date must be on or before lastDate $lastDate.",
  );
  assert(
    initialDateRange == null || !initialDateRange.end.isAfter(lastDate),
    "initialDateRange's end date must be on or before lastDate $lastDate.",
  );
  currentDate = ETDateUtils.dateOnly(currentDate ?? ETDateTime.now());
  assert(debugCheckHasMaterialLocalizations(context));

  Widget dialog = ETDateRangePickerDialog(
    initialDateRange: initialDateRange,
    firstDate: firstDate,
    lastDate: lastDate,
    currentDate: currentDate,
    initialEntryMode: initialEntryMode,
    helpText: helpText,
    cancelText: cancelText,
    confirmText: confirmText,
    saveText: saveText,
    errorFormatText: errorFormatText,
    errorInvalidText: errorInvalidText,
    errorInvalidRangeText: errorInvalidRangeText,
    fieldStartHintText: fieldStartHintText,
    fieldEndHintText: fieldEndHintText,
    fieldStartLabelText: fieldStartLabelText,
    fieldEndLabelText: fieldEndLabelText,
    keyboardType: keyboardType,
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
      delegates: const [
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

  return showDialog<ETDateTimeRange>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    barrierLabel: barrierLabel,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    useSafeArea: false,
    builder: (context) => builder == null ? dialog : builder(context, dialog),
    anchorPoint: anchorPoint,
  );
}

/// A Material-style date range picker dialog.
///
/// It is used internally by [showDateRangePicker] or can be directly pushed
/// onto the [Navigator] stack to enable state restoration. See
/// [showDateRangePicker] for a state restoration app example.
///
/// See also:
///
///  * [showDateRangePicker], which is a way to display the date picker.
class ETDateRangePickerDialog extends StatefulWidget {
  /// A Material-style date range picker dialog.
  const ETDateRangePickerDialog({
    required this.firstDate,
    required this.lastDate,
    super.key,
    this.initialDateRange,
    this.currentDate,
    this.initialEntryMode = DatePickerEntryMode.calendar,
    this.helpText,
    this.cancelText,
    this.confirmText,
    this.saveText,
    this.errorInvalidRangeText,
    this.errorFormatText,
    this.errorInvalidText,
    this.fieldStartHintText,
    this.fieldEndHintText,
    this.fieldStartLabelText,
    this.fieldEndLabelText,
    this.keyboardType = TextInputType.datetime,
    this.restorationId,
    this.switchToInputEntryModeIcon,
    this.switchToCalendarEntryModeIcon,
  });

  /// The date range that the date range picker starts with when it opens.
  ///
  /// If an initial date range is provided, `initialDateRange.start`
  /// and `initialDateRange.end` must both fall between or on [firstDate] and
  /// [lastDate]. For all of these [ETDateTime] values, only their dates are
  /// considered. Their time fields are ignored.
  ///
  /// If [initialDateRange] is non-null, then it will be used as the initially
  /// selected date range. If it is provided, `initialDateRange.start` must be
  /// before or on `initialDateRange.end`.
  final ETDateTimeRange? initialDateRange;

  /// The earliest allowable date on the date range.
  final ETDateTime firstDate;

  /// The latest allowable date on the date range.
  final ETDateTime lastDate;

  /// The [currentDate] represents the current day (i.e. today).
  ///
  /// This date will be highlighted in the day grid.
  ///
  /// If `null`, the date of `ETDateTime.now()` will be used.
  final ETDateTime? currentDate;

  /// The initial date range picker entry mode.
  ///
  /// The date range has two main modes: [DatePickerEntryMode.calendar] (a
  /// scrollable calendar month grid) or [DatePickerEntryMode.input] (two text
  /// input fields) mode.
  ///
  /// It defaults to [DatePickerEntryMode.calendar].
  final DatePickerEntryMode initialEntryMode;

  /// The label on the cancel button for the text input mode.
  ///
  /// If null, the localized value of
  /// [MaterialLocalizations.cancelButtonLabel] is used.
  final String? cancelText;

  /// The label on the "OK" button for the text input mode.
  ///
  /// If null, the localized value of
  /// [MaterialLocalizations.okButtonLabel] is used.
  final String? confirmText;

  /// The label on the save button for the fullscreen calendar mode.
  ///
  /// If null, the localized value of
  /// [MaterialLocalizations.saveButtonLabel] is used.
  final String? saveText;

  /// The label displayed at the top of the dialog.
  ///
  /// If null, the localized value of
  /// [MaterialLocalizations.dateRangePickerHelpText] is used.
  final String? helpText;

  /// The message used when the date range is invalid (e.g. start date is after
  /// end date).
  ///
  /// If null, the localized value of
  /// [MaterialLocalizations.invalidDateRangeLabel] is used.
  final String? errorInvalidRangeText;

  /// The message used when an input text isn't in a proper date format.
  ///
  /// If null, the localized value of
  /// [MaterialLocalizations.invalidDateFormatLabel] is used.
  final String? errorFormatText;

  /// The message used when an input text isn't a selectable date.
  ///
  /// If null, the localized value of
  /// [MaterialLocalizations.dateOutOfRangeLabel] is used.
  final String? errorInvalidText;

  /// The text used to prompt the user when no text has been entered in the
  /// start field.
  ///
  /// If null, the localized value of
  /// [MaterialLocalizations.dateHelpText] is used.
  final String? fieldStartHintText;

  /// The text used to prompt the user when no text has been entered in the
  /// end field.
  ///
  /// If null, the localized value of [MaterialLocalizations.dateHelpText] is
  /// used.
  final String? fieldEndHintText;

  /// The label for the start date text input field.
  ///
  /// If null, the localized value of [MaterialLocalizations.dateRangeStartLabel]
  /// is used.
  final String? fieldStartLabelText;

  /// The label for the end date text input field.
  ///
  /// If null, the localized value of [MaterialLocalizations.dateRangeEndLabel]
  /// is used.
  final String? fieldEndLabelText;

  /// {@macro flutter.material.datePickerDialog}
  final TextInputType keyboardType;

  /// Restoration ID to save and restore the state of the [ETDateRangePickerDialog].
  ///
  /// If it is non-null, the date range picker will persist and restore the
  /// date range selected on the dialog.
  ///
  /// The state of this widget is persisted in a [RestorationBucket] claimed
  /// from the surrounding [RestorationScope] using the provided restoration ID.
  ///
  /// See also:
  ///
  ///  * (RestorationManager), which explains how state restoration works in
  ///    Flutter.
  final String? restorationId;

  /// {@macro flutter.material.date_picker.switchToInputEntryModeIcon}
  final Icon? switchToInputEntryModeIcon;

  /// {@macro flutter.material.date_picker.switchToCalendarEntryModeIcon}
  final Icon? switchToCalendarEntryModeIcon;

  @override
  State<ETDateRangePickerDialog> createState() => _DateRangePickerDialogState();
}

class _DateRangePickerDialogState extends State<ETDateRangePickerDialog>
    with RestorationMixin {
  late final ETRestorableDatePickerEntryMode _entryMode =
      ETRestorableDatePickerEntryMode(widget.initialEntryMode);
  late final RestorableETDateTimeN _selectedStart =
      RestorableETDateTimeN(widget.initialDateRange?.start);
  late final RestorableETDateTimeN _selectedEnd =
      RestorableETDateTimeN(widget.initialDateRange?.end);
  final RestorableBool _autoValidate = RestorableBool(false);
  final GlobalKey _calendarPickerKey = GlobalKey();
  final GlobalKey<InputETDateRangePickerState> _inputPickerKey =
      GlobalKey<InputETDateRangePickerState>();

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_entryMode, "entry_mode");
    registerForRestoration(_selectedStart, "selected_start");
    registerForRestoration(_selectedEnd, "selected_end");
    registerForRestoration(_autoValidate, "autovalidate");
  }

  @override
  void dispose() {
    _entryMode.dispose();
    _selectedStart.dispose();
    _selectedEnd.dispose();
    _autoValidate.dispose();
    super.dispose();
  }

  void _handleOk() {
    if (_entryMode.value == DatePickerEntryMode.input ||
        _entryMode.value == DatePickerEntryMode.inputOnly) {
      final picker = _inputPickerKey.currentState!;
      if (!picker.validate()) {
        setState(() {
          _autoValidate.value = true;
        });
        return;
      }
    }
    final selectedRange = _hasSelectedDateRange
        ? ETDateTimeRange(
            start: _selectedStart.value!,
            end: _selectedEnd.value!,
          )
        : null;

    Navigator.pop(context, selectedRange);
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  void _handleEntryModeToggle() {
    setState(() {
      switch (_entryMode.value) {
        case DatePickerEntryMode.calendar:
          _autoValidate.value = false;
          _entryMode.value = DatePickerEntryMode.input;

        case DatePickerEntryMode.input:
          // Validate the range dates
          if (_selectedStart.value != null &&
              (_selectedStart.value!.isBefore(widget.firstDate) ||
                  _selectedStart.value!.isAfter(widget.lastDate))) {
            _selectedStart.value = null;
            // With no valid start date, having an end date makes no sense for the UI.
            _selectedEnd.value = null;
          }
          if (_selectedEnd.value != null &&
              (_selectedEnd.value!.isBefore(widget.firstDate) ||
                  _selectedEnd.value!.isAfter(widget.lastDate))) {
            _selectedEnd.value = null;
          }
          // If invalid range (start after end), then just use the start date
          if (_selectedStart.value != null &&
              _selectedEnd.value != null &&
              _selectedStart.value!.isAfter(_selectedEnd.value!)) {
            _selectedEnd.value = null;
          }
          _entryMode.value = DatePickerEntryMode.calendar;

        case DatePickerEntryMode.calendarOnly:
        case DatePickerEntryMode.inputOnly:
          assert(false, "Can not change entry mode from $_entryMode");
      }
    });
  }

  void _handleStartDateChanged(ETDateTime? date) {
    setState(() => _selectedStart.value = date);
  }

  void _handleEndDateChanged(ETDateTime? date) {
    setState(() => _selectedEnd.value = date);
  }

  bool get _hasSelectedDateRange =>
      _selectedStart.value != null && _selectedEnd.value != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final useMaterial3 = theme.useMaterial3;
    final localized = Localized(context);
    final orientation = MediaQuery.orientationOf(context);
    final datePickerTheme = DatePickerTheme.of(context);
    final defaults = DatePickerTheme.defaults(context);

    final Widget contents;
    final Size size;
    final double? elevation;
    final Color? shadowColor;
    final Color? surfaceTintColor;
    final ShapeBorder? shape;
    final EdgeInsets insetPadding;
    final showEntryModeButton =
        _entryMode.value == DatePickerEntryMode.calendar ||
            _entryMode.value == DatePickerEntryMode.input;
    switch (_entryMode.value) {
      case DatePickerEntryMode.calendar:
      case DatePickerEntryMode.calendarOnly:
        contents = _CalendarRangePickerDialog(
          key: _calendarPickerKey,
          selectedStartDate: _selectedStart.value,
          selectedEndDate: _selectedEnd.value,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          currentDate: widget.currentDate,
          onStartDateChanged: _handleStartDateChanged,
          onEndDateChanged: _handleEndDateChanged,
          onConfirm: _hasSelectedDateRange ? _handleOk : null,
          onCancel: _handleCancel,
          entryModeButton: showEntryModeButton
              ? IconButton(
                  icon: widget.switchToInputEntryModeIcon ??
                      Icon(useMaterial3 ? Icons.edit_outlined : Icons.edit),
                  padding: EdgeInsets.zero,
                  tooltip: localized.inputDateModeButtonLabel,
                  onPressed: _handleEntryModeToggle,
                )
              : null,
          confirmText: widget.saveText ??
              (useMaterial3
                  ? localized.saveButtonLabel
                  : localized.saveButtonLabel.toUpperCase()),
          helpText: widget.helpText ??
              (useMaterial3
                  ? localized.dateRangePickerHelpText
                  : localized.dateRangePickerHelpText.toUpperCase()),
        );
        size = MediaQuery.sizeOf(context);
        insetPadding = EdgeInsets.zero;
        elevation = datePickerTheme.rangePickerElevation ??
            defaults.rangePickerElevation!;
        shadowColor = datePickerTheme.rangePickerShadowColor ??
            defaults.rangePickerShadowColor!;
        surfaceTintColor = datePickerTheme.rangePickerSurfaceTintColor ??
            defaults.rangePickerSurfaceTintColor!;
        shape = datePickerTheme.rangePickerShape ?? defaults.rangePickerShape;

      case DatePickerEntryMode.input:
      case DatePickerEntryMode.inputOnly:
        contents = InputETDateRangePickerDialog(
          selectedStartDate: _selectedStart.value,
          selectedEndDate: _selectedEnd.value,
          currentDate: widget.currentDate,
          picker: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            height: orientation == Orientation.portrait
                ? _inputFormPortraitHeight
                : _inputFormLandscapeHeight,
            child: Column(
              children: <Widget>[
                const Spacer(),
                InputETDateRangePicker(
                  key: _inputPickerKey,
                  initialStartDate: _selectedStart.value,
                  initialEndDate: _selectedEnd.value,
                  firstDate: widget.firstDate,
                  lastDate: widget.lastDate,
                  onStartDateChanged: _handleStartDateChanged,
                  onEndDateChanged: _handleEndDateChanged,
                  autofocus: true,
                  autovalidate: _autoValidate.value,
                  helpText: widget.helpText,
                  errorInvalidRangeText: widget.errorInvalidRangeText,
                  errorFormatText: widget.errorFormatText,
                  errorInvalidText: widget.errorInvalidText,
                  fieldStartHintText: widget.fieldStartHintText,
                  fieldEndHintText: widget.fieldEndHintText,
                  fieldStartLabelText: widget.fieldStartLabelText,
                  fieldEndLabelText: widget.fieldEndLabelText,
                  keyboardType: widget.keyboardType,
                ),
                const Spacer(),
              ],
            ),
          ),
          onConfirm: _handleOk,
          onCancel: _handleCancel,
          entryModeButton: showEntryModeButton
              ? IconButton(
                  icon: widget.switchToCalendarEntryModeIcon ??
                      const Icon(Icons.calendar_today),
                  padding: EdgeInsets.zero,
                  tooltip: localized.calendarModeButtonLabel,
                  onPressed: _handleEntryModeToggle,
                )
              : null,
          confirmText: widget.confirmText ?? localized.okButtonLabel,
          cancelText: widget.cancelText ??
              (useMaterial3
                  ? localized.cancelButtonLabel
                  : localized.cancelButtonLabel.toUpperCase()),
          helpText: widget.helpText ??
              (useMaterial3
                  ? localized.dateRangePickerHelpText
                  : localized.dateRangePickerHelpText.toUpperCase()),
        );
        final dialogTheme = theme.dialogTheme;
        size = orientation == Orientation.portrait
            ? (useMaterial3
                ? _inputPortraitDialogSizeM3
                : _inputPortraitDialogSizeM2)
            : _inputRangeLandscapeDialogSize;
        elevation = useMaterial3
            ? datePickerTheme.elevation ?? defaults.elevation!
            : datePickerTheme.elevation ?? dialogTheme.elevation ?? 24;
        shadowColor = datePickerTheme.shadowColor ?? defaults.shadowColor;
        surfaceTintColor =
            datePickerTheme.surfaceTintColor ?? defaults.surfaceTintColor;
        shape = useMaterial3
            ? datePickerTheme.shape ?? defaults.shape
            : datePickerTheme.shape ?? dialogTheme.shape ?? defaults.shape;

        insetPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 24);
    }

    return Dialog(
      insetPadding: insetPadding,
      backgroundColor:
          datePickerTheme.backgroundColor ?? defaults.backgroundColor,
      elevation: elevation,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: AnimatedContainer(
        width: size.width,
        height: size.height,
        duration: _dialogSizeAnimationDuration,
        curve: Curves.easeIn,
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: _kMaxTextScaleFactor,
          child: Builder(
            builder: (context) => contents,
          ),
        ),
      ),
    );
  }
}

class _CalendarRangePickerDialog extends StatelessWidget {
  const _CalendarRangePickerDialog({
    required this.selectedStartDate,
    required this.selectedEndDate,
    required this.firstDate,
    required this.lastDate,
    required this.currentDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onConfirm,
    required this.onCancel,
    required this.confirmText,
    required this.helpText,
    super.key,
    this.entryModeButton,
  });

  final ETDateTime? selectedStartDate;
  final ETDateTime? selectedEndDate;
  final ETDateTime firstDate;
  final ETDateTime lastDate;
  final ETDateTime? currentDate;
  final ValueChanged<ETDateTime> onStartDateChanged;
  final ValueChanged<ETDateTime?> onEndDateChanged;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final String confirmText;
  final String helpText;
  final Widget? entryModeButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final useMaterial3 = theme.useMaterial3;
    final orientation = MediaQuery.orientationOf(context);
    final themeData = DatePickerTheme.of(context);
    final defaults = DatePickerTheme.defaults(context);
    final dialogBackground = themeData.rangePickerBackgroundColor ??
        defaults.rangePickerBackgroundColor;
    final headerBackground = themeData.rangePickerHeaderBackgroundColor ??
        defaults.rangePickerHeaderBackgroundColor;
    final headerForeground = themeData.rangePickerHeaderForegroundColor ??
        defaults.rangePickerHeaderForegroundColor;
    final headerDisabledForeground = headerForeground?.withAlpha(97);
    final headlineStyle = themeData.rangePickerHeaderHeadlineStyle ??
        defaults.rangePickerHeaderHeadlineStyle;
    final headlineHelpStyle = (themeData.rangePickerHeaderHelpStyle ??
            defaults.rangePickerHeaderHelpStyle)
        ?.apply(color: headerForeground);
    final startDateText =
        formatRangeStartETDate(selectedStartDate, selectedEndDate, context);
    final endDateText = formatRangeEndETDate(
      selectedStartDate,
      selectedEndDate,
      ETDateTime.now(),
      context,
    );
    final startDateStyle = headlineStyle?.apply(
      color: selectedStartDate != null
          ? headerForeground
          : headerDisabledForeground,
    );
    final endDateStyle = headlineStyle?.apply(
      color:
          selectedEndDate != null ? headerForeground : headerDisabledForeground,
    );
    final buttonStyle = TextButton.styleFrom(
      foregroundColor: headerForeground,
      disabledForegroundColor: headerDisabledForeground,
    );
    final iconTheme = IconThemeData(color: headerForeground);

    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: iconTheme,
          actionsIconTheme: iconTheme,
          elevation: useMaterial3 ? 0 : null,
          scrolledUnderElevation: useMaterial3 ? 0 : null,
          backgroundColor: useMaterial3 ? headerBackground : null,
          leading: CloseButton(
            onPressed: onCancel,
          ),
          actions: <Widget>[
            if (orientation == Orientation.landscape && entryModeButton != null)
              entryModeButton!,
            TextButton(
              style: buttonStyle,
              onPressed: onConfirm,
              child: Text(confirmText),
            ),
            const SizedBox(width: 8),
          ],
          bottom: PreferredSize(
            preferredSize: const Size(double.infinity, 64),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: MediaQuery.sizeOf(context).width < 360 ? 42 : 72,
                ),
                Expanded(
                  child: Semantics(
                    label: "$helpText $startDateText to $endDateText",
                    excludeSemantics: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(helpText, style: headlineHelpStyle),
                        const SizedBox(height: 8),
                        Row(
                          children: <Widget>[
                            Text(
                              startDateText,
                              style: startDateStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              " – ",
                              style: startDateStyle,
                            ),
                            Flexible(
                              child: Text(
                                endDateText,
                                style: endDateStyle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                if (orientation == Orientation.portrait &&
                    entryModeButton != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: IconTheme(
                      data: iconTheme,
                      child: entryModeButton!,
                    ),
                  ),
              ],
            ),
          ),
        ),
        backgroundColor: dialogBackground,
        body: CalendarETDateRangePicker(
          initialStartDate: selectedStartDate,
          initialEndDate: selectedEndDate,
          firstDate: firstDate,
          lastDate: lastDate,
          currentDate: currentDate,
          onStartDateChanged: onStartDateChanged,
          onEndDateChanged: onEndDateChanged,
        ),
      ),
    );
  }
}

/// Encapsulates a start and end [ETDateTime] that represent the range of dates.
///
/// The range includes the [start] and [end] dates. The [start] and [end] dates
/// may be equal to indicate a date range of a single day. The [start] date must
/// not be after the [end] date.
///
/// See also:
///  * [showDateRangePicker], which displays a dialog that allows the user to
///    select a date range.
@immutable
class ETDateTimeRange {
  /// Creates a date range for the given start and end [ETDateTime].
  ETDateTimeRange({
    required this.start,
    required this.end,
  }) : assert(!start.isAfter(end));

  /// The start of the range of dates.
  final ETDateTime start;

  /// The end of the range of dates.
  final ETDateTime end;

  /// Returns a [Duration] of the time between [start] and [end].
  ///
  /// See [ETDateTime.difference] for more details.
  Duration get duration => end.difference(start);

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is DateTimeRange && other.start == start && other.end == end;
  }

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => "$start - $end";
}

// ignore: avoid_classes_with_only_static_members
class Utils {
  /// Returns a [ETDateTimeRange] with the dates of the original, but with times
  /// set to midnight.
  ///
  /// See also:
  ///  * (dateOnly), which does the same thing for a single date.
  static ETDateTimeRange datesOnly(ETDateTimeRange range) => ETDateTimeRange(
        start: ETDateUtils.dateOnly(range.start),
        end: ETDateUtils.dateOnly(range.end),
      );
}

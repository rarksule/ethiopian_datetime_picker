import "package:ethiopian_datetime_picker/src/calander_common.dart";
import "package:ethiopian_datetime_picker/src/ettime_picker.dart";
import "package:ethiopian_datetime_picker/src/ettime_picker_theme.dart";
import "package:ethiopian_datetime_picker/src/string_text.dart";
import "package:flutter/material.dart";
import "package:flutter_localizations/flutter_localizations.dart";

const Duration _kDialogSizeAnimationDuration = Duration(milliseconds: 200);

/// Shows a dialog containing a Material Design time picker.
///
/// The returned Future resolves to the time selected by the user when the user
/// closes the dialog. If the user cancels the dialog, null is returned.
///
/// {@tool snippet} Show a dialog with [initialTime] equal to the current time.
///
/// ```dart
/// Future<TimeOfDay?> selectedTime = showTimePicker(
///   initialTime: TimeOfDay.now(),
///   context: context,
/// );
/// ```
/// {@end-tool}
///
/// The [context], [barrierDismissible], [barrierColor], [barrierLabel],
/// [useRootNavigator] and [routeSettings] arguments are passed to [showDialog],
/// the documentation for which discusses how it is used.
///
/// The [builder] parameter can be used to wrap the dialog widget to add
/// inherited widgets like [Localizations.override], [Directionality], or
/// [MediaQuery].
///
/// The `initialEntryMode` parameter can be used to determine the initial time
/// entry selection of the picker (either a clock dial or text input).
///
/// Optional strings for the [helpText], [cancelText], [errorInvalidText],
/// [hourLabelText], [minuteLabelText] and [confirmText] can be provided to
/// override the default values.
///
/// The optional [orientation] parameter sets the [Orientation] to use when
/// displaying the dialog. By default, the orientation is derived from the
/// [MediaQueryData.size] of the ambient [MediaQuery]: wide sizes use the
/// landscape orientation, and tall sizes use the portrait orientation. Use this
/// parameter to override the default and force the dialog to appear in either
/// portrait or landscape mode.
///
/// {@macro flutter.widgets.RawDialogRoute}
///
/// By default, the time picker gets its colors from the overall theme's
/// [ColorScheme]. The time picker can be further customized by providing a
/// [TimePickerThemeData] to the overall theme.
///
/// {@tool snippet} Show a dialog with the text direction overridden to be
/// [TextDirection.rtl].
///
/// ```dart
/// Future<TimeOfDay?> selectedTimeRTL = showTimePicker(
///   context: context,
///   initialTime: TimeOfDay.now(),
///   builder: (BuildContext context, Widget? child) {
///     return Directionality(
///       textDirection: TextDirection.rtl,
///       child: child!,
///     );
///   },
/// );
/// ```
/// {@end-tool}
///
/// {@tool snippet} Show a dialog with time unconditionally displayed in 24 hour
/// format.
///
/// ```dart
/// Future<TimeOfDay?> selectedTime24Hour = showTimePicker(
///   context: context,
///   initialTime: const TimeOfDay(hour: 10, minute: 47),
///   builder: (BuildContext context, Widget? child) {
///     return MediaQuery(
///       data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
///       child: child!,
///     );
///   },
/// );
/// ```
/// {@end-tool}
///
/// {@tool dartpad}
/// This example illustrates how to open a time picker, and allows exploring
/// some of the variations in the types of time pickers that may be shown.
///
/// ** See code in examples/api/lib/material/time_picker/show_time_picker.0.dart **
/// {@end-tool}
///
/// See also:
///
/// * [showDatePicker], which shows a dialog that contains a Material Design
///   date picker.
/// * [TimePickerThemeData], which allows you to customize the colors,
///   typography, and shape of the time picker.
/// * [DisplayFeatureSubScreen], which documents the specifics of how
///   (DisplayFeature)s can split the screen into sub-screens.
Future<TimeOfDay?> showETTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
  TransitionBuilder? builder,
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
  Locale? locale,
  bool use24HourFormat = false,
  bool useRootNavigator = true,
  TimePickerEntryMode initialEntryMode = TimePickerEntryMode.dial,
  String? cancelText,
  String? confirmText,
  String? helpText,
  String? errorInvalidText,
  String? hourLabelText,
  String? minuteLabelText,
  RouteSettings? routeSettings,
  EntryModeChangeCallback? onEntryModeChanged,
  Offset? anchorPoint,
  Orientation? orientation,
}) async {
  assert(debugCheckHasMaterialLocalizations(context));

  Widget dialog = MediaQuery(
    data:
        MediaQuery.of(context).copyWith(alwaysUse24HourFormat: use24HourFormat),
    child: ETTimePickerDialog(
      initialTime: initialTime,
      initialEntryMode: initialEntryMode,
      cancelText: cancelText,
      confirmText: confirmText,
      helpText: helpText,
      errorInvalidText: errorInvalidText,
      hourLabelText: hourLabelText,
      minuteLabelText: minuteLabelText,
      orientation: orientation,
      onEntryModeChanged: onEntryModeChanged,
    ),
  );

  locale = locale ?? Localizations.localeOf(context);
  setLocale = locale.languageCode;

  dialog = Localizations.override(
    context: context,
    delegates: const [
      GlobalMaterialLocalizations.delegate,
    ],
    locale: Locale(globalLocale != null ? "en" : locale.languageCode),
    child: dialog,
  );

  return showDialog<TimeOfDay>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    barrierLabel: barrierLabel,
    useRootNavigator: useRootNavigator,
    builder: (context) => builder == null ? dialog : builder(context, dialog),
    routeSettings: routeSettings,
    anchorPoint: anchorPoint,
  );
}

/// A Material Design time picker designed to appear inside a popup dialog.
///
/// Pass this widget to [showDialog]. The value returned by [showDialog] is the
/// selected [TimeOfDay] if the user taps the "OK" button, or null if the user
/// taps the "CANCEL" button. The selected time is reported by calling
/// [Navigator.pop].
///
/// Use [showTimePicker] to show a dialog already containing a [ETTimePickerDialog].
class ETTimePickerDialog extends StatefulWidget {
  /// Creates a Material Design time picker.
  const ETTimePickerDialog({
    required this.initialTime,
    super.key,
    this.cancelText,
    this.confirmText,
    this.helpText,
    this.errorInvalidText,
    this.hourLabelText,
    this.minuteLabelText,
    this.restorationId,
    this.initialEntryMode = TimePickerEntryMode.dial,
    this.orientation,
    this.onEntryModeChanged,
  });

  /// The time initially selected when the dialog is shown.
  final TimeOfDay initialTime;

  /// Optionally provide your own text for the cancel button.
  ///
  /// If null, the button uses [MaterialLocalizations.cancelButtonLabel].
  final String? cancelText;

  /// Optionally provide your own text for the confirm button.
  ///
  /// If null, the button uses [MaterialLocalizations.okButtonLabel].
  final String? confirmText;

  /// Optionally provide your own help text to the header of the time picker.
  final String? helpText;

  /// Optionally provide your own validation error text.
  final String? errorInvalidText;

  /// Optionally provide your own hour label text.
  final String? hourLabelText;

  /// Optionally provide your own minute label text.
  final String? minuteLabelText;

  /// Restoration ID to save and restore the state of the [ETTimePickerDialog].
  ///
  /// If it is non-null, the time picker will persist and restore the
  /// dialog's state.
  ///
  /// The state of this widget is persisted in a [RestorationBucket] claimed
  /// from the surrounding [RestorationScope] using the provided restoration ID.
  ///
  /// See also:
  ///
  ///  * RestorationManager, which explains how state restoration works in
  ///    Flutter.
  final String? restorationId;

  /// The entry mode for the picker. Whether it's text input or a dial.
  final TimePickerEntryMode initialEntryMode;

  /// The optional [orientation] parameter sets the [Orientation] to use when
  /// displaying the dialog.
  ///
  /// By default, the orientation is derived from the [MediaQueryData.size] of
  /// the ambient [MediaQuery]. If the aspect of the size is tall, then
  /// [Orientation.portrait] is used, if the size is wide, then
  /// [Orientation.landscape] is used.
  ///
  /// Use this parameter to override the default and force the dialog to appear
  /// in either portrait or landscape mode regardless of the aspect of the
  /// [MediaQueryData.size].
  final Orientation? orientation;

  /// Callback called when the selected entry mode is changed.
  final EntryModeChangeCallback? onEntryModeChanged;

  @override
  State<ETTimePickerDialog> createState() => _ETTimePickerDialogState();
}

class _ETTimePickerDialogState extends State<ETTimePickerDialog>
    with RestorationMixin {
  late final RestorableEnum<TimePickerEntryMode> _entryMode =
      RestorableEnum<TimePickerEntryMode>(
    widget.initialEntryMode,
    values: TimePickerEntryMode.values,
  );
  late final RestorableTimeOfDay _selectedTime =
      RestorableTimeOfDay(widget.initialTime);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final RestorableEnum<AutovalidateMode> _autovalidateMode =
      RestorableEnum<AutovalidateMode>(
    AutovalidateMode.disabled,
    values: AutovalidateMode.values,
  );
  late final RestorableEnumN<Orientation> _orientation =
      RestorableEnumN<Orientation>(
    widget.orientation,
    values: Orientation.values,
  );

  // Base sizes
  static const Size _kTimePickerPortraitSize = Size(310, 468);
  static const Size _kTimePickerLandscapeSize = Size(524, 342);
  static const Size _kTimePickerLandscapeSizeM2 = Size(508, 300);
  static const Size _kTimePickerInputSize = Size(312, 216);

  // Absolute minimum dialog sizes, which is the point at which it begins
  // scrolling to fit everything in.
  static const Size _kTimePickerMinPortraitSize = Size(238, 326);
  static const Size _kTimePickerMinLandscapeSize = Size(416, 248);
  static const Size _kTimePickerMinInputSize = Size(312, 196);

  @override
  void dispose() {
    _selectedTime.dispose();
    _entryMode.dispose();
    _autovalidateMode.dispose();
    _orientation.dispose();
    super.dispose();
  }

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedTime, "selected_time");
    registerForRestoration(_entryMode, "entry_mode");
    registerForRestoration(_autovalidateMode, "autovalidate_mode");
    registerForRestoration(_orientation, "orientation");
  }

  void _handleTimeChanged(TimeOfDay value) {
    if (value != _selectedTime.value) {
      setState(() {
        _selectedTime.value = value;
      });
    }
  }

  void _handleEntryModeChanged(TimePickerEntryMode value) {
    if (value != _entryMode.value) {
      setState(() {
        switch (_entryMode.value) {
          case TimePickerEntryMode.dial:
            _autovalidateMode.value = AutovalidateMode.disabled;
          case TimePickerEntryMode.input:
            _formKey.currentState!.save();
          case TimePickerEntryMode.dialOnly:
            break;
          case TimePickerEntryMode.inputOnly:
            break;
        }
        _entryMode.value = value;
        widget.onEntryModeChanged?.call(value);
      });
    }
  }

  void _toggleEntryMode() {
    switch (_entryMode.value) {
      case TimePickerEntryMode.dial:
        _handleEntryModeChanged(TimePickerEntryMode.input);
      case TimePickerEntryMode.input:
        _handleEntryModeChanged(TimePickerEntryMode.dial);
      case TimePickerEntryMode.dialOnly:
      case TimePickerEntryMode.inputOnly:
        FlutterError("Can not change entry mode from $_entryMode");
    }
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  void _handleOk() {
    if (_entryMode.value == TimePickerEntryMode.input ||
        _entryMode.value == TimePickerEntryMode.inputOnly) {
      final form = _formKey.currentState!;
      if (!form.validate()) {
        setState(() {
          _autovalidateMode.value = AutovalidateMode.always;
        });
        return;
      }
      form.save();
    }
    Navigator.pop(context, _selectedTime.value);
  }

  Size _minDialogSize(BuildContext context, {required bool useMaterial3}) {
    final orientation = _orientation.value ?? MediaQuery.orientationOf(context);

    switch (_entryMode.value) {
      case TimePickerEntryMode.dial:
      case TimePickerEntryMode.dialOnly:
        switch (orientation) {
          case Orientation.portrait:
            return _kTimePickerMinPortraitSize;
          case Orientation.landscape:
            return _kTimePickerMinLandscapeSize;
        }
      case TimePickerEntryMode.input:
      case TimePickerEntryMode.inputOnly:
        final localizations = MaterialLocalizations.of(context);
        final timeOfDayFormat = localizations.timeOfDayFormat(
          alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
        );
        final double timePickerWidth;
        switch (timeOfDayFormat) {
          case TimeOfDayFormat.HH_colon_mm:
          case TimeOfDayFormat.HH_dot_mm:
          case TimeOfDayFormat.frenchCanadian:
          case TimeOfDayFormat.H_colon_mm:
            final defaultTheme = useMaterial3
                ? ETTimePickerDefaultsM3(context)
                : ETTimePickerDefaultsM2(context);
            timePickerWidth = _kTimePickerMinInputSize.width -
                defaultTheme.dayPeriodPortraitSize.width -
                12;
          case TimeOfDayFormat.a_space_h_colon_mm:
          case TimeOfDayFormat.h_colon_mm_space_a:
            timePickerWidth =
                _kTimePickerMinInputSize.width - (useMaterial3 ? 32 : 0);
        }
        return Size(timePickerWidth, _kTimePickerMinInputSize.height);
    }
  }

  Size _dialogSize(BuildContext context, {required bool useMaterial3}) {
    final orientation = _orientation.value ?? MediaQuery.orientationOf(context);
    // Constrain the textScaleFactor to prevent layout issues. Since only some
    // parts of the time picker scale up with textScaleFactor, we cap the factor
    // to 1.1 as that provides enough space to reasonably fit all the content.
    final textScaleFactor =
        MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.1).scale(1);

    final Size timePickerSize;
    switch (_entryMode.value) {
      case TimePickerEntryMode.dial:
      case TimePickerEntryMode.dialOnly:
        switch (orientation) {
          case Orientation.portrait:
            timePickerSize = _kTimePickerPortraitSize;
          case Orientation.landscape:
            timePickerSize = Size(
              _kTimePickerLandscapeSize.width * textScaleFactor,
              useMaterial3
                  ? _kTimePickerLandscapeSize.height
                  : _kTimePickerLandscapeSizeM2.height,
            );
        }
      case TimePickerEntryMode.input:
      case TimePickerEntryMode.inputOnly:
        final localizations = MaterialLocalizations.of(context);
        final timeOfDayFormat = localizations.timeOfDayFormat(
          alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
        );
        final double timePickerWidth;
        switch (timeOfDayFormat) {
          case TimeOfDayFormat.HH_colon_mm:
          case TimeOfDayFormat.HH_dot_mm:
          case TimeOfDayFormat.frenchCanadian:
          case TimeOfDayFormat.H_colon_mm:
            final defaultTheme = useMaterial3
                ? ETTimePickerDefaultsM3(context)
                : ETTimePickerDefaultsM2(context);
            timePickerWidth = _kTimePickerInputSize.width -
                defaultTheme.dayPeriodPortraitSize.width -
                12;
          case TimeOfDayFormat.a_space_h_colon_mm:
          case TimeOfDayFormat.h_colon_mm_space_a:
            timePickerWidth =
                _kTimePickerInputSize.width - (useMaterial3 ? 32 : 0);
        }
        timePickerSize = Size(timePickerWidth, _kTimePickerInputSize.height);
    }
    return Size(timePickerSize.width, timePickerSize.height * textScaleFactor);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final theme = Theme.of(context);
    final pickerTheme = TimePickerTheme.of(context);
    final defaultTheme = theme.useMaterial3
        ? ETTimePickerDefaultsM3(context)
        : ETTimePickerDefaultsM2(context);
    final shape = pickerTheme.shape ?? defaultTheme.shape;
    final entryModeIconColor =
        pickerTheme.entryModeIconColor ?? defaultTheme.entryModeIconColor;
    final localized = Localized(context);

    final Widget actions = Padding(
      padding: EdgeInsetsDirectional.only(start: theme.useMaterial3 ? 0 : 4),
      child: Row(
        children: <Widget>[
          if (_entryMode.value == TimePickerEntryMode.dial ||
              _entryMode.value == TimePickerEntryMode.input)
            IconButton(
              // In material3 mode, we want to use the color as part of the
              // button style which applies its own opacity. In material2 mode,
              // we want to use the color as the color, which already includes
              // the opacity.
              color: theme.useMaterial3 ? null : entryModeIconColor,
              style: theme.useMaterial3
                  ? IconButton.styleFrom(foregroundColor: entryModeIconColor)
                  : null,
              onPressed: _toggleEntryMode,
              icon: Icon(
                _entryMode.value == TimePickerEntryMode.dial
                    ? Icons.keyboard_outlined
                    : Icons.access_time,
              ),
              tooltip: _entryMode.value == TimePickerEntryMode.dial
                  ? localized.inputTimeModeButtonLabel
                  : localized.dialModeButtonLabel,
            ),
          Expanded(
            child: Container(
              alignment: AlignmentDirectional.centerEnd,
              constraints: const BoxConstraints(minHeight: 36),
              child: OverflowBar(
                spacing: 8,
                overflowAlignment: OverflowBarAlignment.end,
                children: <Widget>[
                  TextButton(
                    style: pickerTheme.cancelButtonStyle ??
                        defaultTheme.cancelButtonStyle,
                    onPressed: _handleCancel,
                    child: Text(
                      widget.cancelText ??
                          (theme.useMaterial3
                              ? localized.cancelButtonLabel
                              : localized.cancelButtonLabel.toUpperCase()),
                    ),
                  ),
                  TextButton(
                    style: pickerTheme.confirmButtonStyle ??
                        defaultTheme.confirmButtonStyle,
                    onPressed: _handleOk,
                    child: Text(widget.confirmText ?? localized.okButtonLabel),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    final Offset tapTargetSizeOffset;
    switch (theme.materialTapTargetSize) {
      case MaterialTapTargetSize.padded:
        tapTargetSizeOffset = Offset.zero;
      case MaterialTapTargetSize.shrinkWrap:
        // _dialogSize returns "padded" sizes.
        tapTargetSizeOffset = const Offset(0, -12);
    }
    final dialogSize = _dialogSize(context, useMaterial3: theme.useMaterial3) +
        tapTargetSizeOffset;
    final minDialogSize =
        _minDialogSize(context, useMaterial3: theme.useMaterial3) +
            tapTargetSizeOffset;
    return Dialog(
      shape: shape,
      elevation: pickerTheme.elevation ?? defaultTheme.elevation,
      backgroundColor:
          pickerTheme.backgroundColor ?? defaultTheme.backgroundColor,
      insetPadding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: (_entryMode.value == TimePickerEntryMode.input ||
                _entryMode.value == TimePickerEntryMode.inputOnly)
            ? 0
            : 24,
      ),
      child: Padding(
        padding: pickerTheme.padding ?? defaultTheme.padding,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final constrainedSize = constraints.constrain(dialogSize);
            final allowedSize = Size(
              constrainedSize.width < minDialogSize.width
                  ? minDialogSize.width
                  : constrainedSize.width,
              constrainedSize.height < minDialogSize.height
                  ? minDialogSize.height
                  : constrainedSize.height,
            );
            return SingleChildScrollView(
              restorationId: "time_picker_scroll_view_horizontal",
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                restorationId: "time_picker_scroll_view_vertical",
                child: AnimatedContainer(
                  width: allowedSize.width,
                  height: allowedSize.height,
                  duration: _kDialogSizeAnimationDuration,
                  curve: Curves.easeIn,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Form(
                          key: _formKey,
                          autovalidateMode: _autovalidateMode.value,
                          child: ETTimePicker(
                            time: widget.initialTime,
                            onTimeChanged: _handleTimeChanged,
                            helpText: widget.helpText,
                            cancelText: widget.cancelText,
                            confirmText: widget.confirmText,
                            errorInvalidText: widget.errorInvalidText,
                            hourLabelText: widget.hourLabelText,
                            minuteLabelText: widget.minuteLabelText,
                            restorationId: "time_picker",
                            entryMode: _entryMode.value,
                            orientation: widget.orientation,
                            onEntryModeChanged: _handleEntryModeChanged,
                          ),
                        ),
                      ),
                      actions,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

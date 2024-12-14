import 'package:ethiopian_datetime/ethiopian_datetime.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'etdate_picker_header.dart';
import 'string_text.dart';

const double _kMaxTextScaleFactor = 1.3;
const Size _inputPortraitDialogSizeM2 = Size(330.0, 270.0);
const Size _inputPortraitDialogSizeM3 = Size(328.0, 270.0);

/// Provides a pair of text fields that allow the user to enter the start and
/// end dates that represent a range of dates.
class InputETDateRangePicker extends StatefulWidget {
  /// Creates a row with two text fields configured to accept the start and end dates
  /// of a date range.
  InputETDateRangePicker({
    super.key,
    ETDateTime? initialStartDate,
    ETDateTime? initialEndDate,
    required ETDateTime firstDate,
    required ETDateTime lastDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    this.helpText,
    this.errorFormatText,
    this.errorInvalidText,
    this.errorInvalidRangeText,
    this.fieldStartHintText,
    this.fieldEndHintText,
    this.fieldStartLabelText,
    this.fieldEndLabelText,
    this.autofocus = false,
    this.autovalidate = false,
    this.keyboardType = TextInputType.datetime,
  })  : initialStartDate = initialStartDate == null
            ? null
            : ETDateUtils.dateOnly(initialStartDate),
        initialEndDate = initialEndDate == null
            ? null
            : ETDateUtils.dateOnly(initialEndDate),
        firstDate = ETDateUtils.dateOnly(firstDate),
        lastDate = ETDateUtils.dateOnly(lastDate);

  /// The [ETDateTime] that represents the start of the initial date range selection.
  final ETDateTime? initialStartDate;

  /// The [ETDateTime] that represents the end of the initial date range selection.
  final ETDateTime? initialEndDate;

  /// The earliest allowable [ETDateTime] that the user can select.
  final ETDateTime firstDate;

  /// The latest allowable [ETDateTime] that the user can select.
  final ETDateTime lastDate;

  /// Called when the user changes the start date of the selected range.
  final ValueChanged<ETDateTime?>? onStartDateChanged;

  /// Called when the user changes the end date of the selected range.
  final ValueChanged<ETDateTime?>? onEndDateChanged;

  /// The text that is displayed at the top of the header.
  ///
  /// This is used to indicate to the user what they are selecting a date for.
  final String? helpText;

  /// Error text used to indicate the text in a field is not a valid date.
  final String? errorFormatText;

  /// Error text used to indicate the date in a field is not in the valid range
  /// of [firstDate] - [lastDate].
  final String? errorInvalidText;

  /// Error text used to indicate the dates given don't form a valid date
  /// range (i.e. the start date is after the end date).
  final String? errorInvalidRangeText;

  /// Hint text shown when the start date field is empty.
  final String? fieldStartHintText;

  /// Hint text shown when the end date field is empty.
  final String? fieldEndHintText;

  /// Label used for the start date field.
  final String? fieldStartLabelText;

  /// Label used for the end date field.
  final String? fieldEndLabelText;

  /// {@macro flutter.widgets.editableText.autofocus}
  final bool autofocus;

  /// If true, the date fields will validate and update their error text
  /// immediately after every change. Otherwise, you must call
  /// [_InputDateRangePickerState.validate] to validate.
  final bool autovalidate;

  /// {@macro flutter.material.datePickerDialog}
  final TextInputType keyboardType;

  @override
  State<InputETDateRangePicker> createState() => InputETDateRangePickerState();
}

/// The current state of an [InputETDateRangePicker]. Can be used to
/// [validate] the date field entries.
class InputETDateRangePickerState extends State<InputETDateRangePicker> {
  late String _startInputText;
  late String _endInputText;
  ETDateTime? _startDate;
  ETDateTime? _endDate;
  late TextEditingController _startController;
  late TextEditingController _endController;
  String? _startErrorText;
  String? _endErrorText;
  bool _autoSelected = false;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _startController = TextEditingController();
    _endDate = widget.initialEndDate;
    _endController = TextEditingController();
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Localized localized = Localized(context);
    if (_startDate != null) {
      _startInputText = localized.formatCompactDate(_startDate!);
      final bool selectText = widget.autofocus && !_autoSelected;
      _updateController(_startController, _startInputText, selectText);
      _autoSelected = selectText;
    }

    if (_endDate != null) {
      _endInputText = localized.formatCompactDate(_endDate!);
      _updateController(_endController, _endInputText, false);
    }
  }

  /// Validates that the text in the start and end fields represent a valid
  /// date range.
  ///
  /// Will return true if the range is valid. If not, it will
  /// return false and display an appropriate error message under one of the
  /// text fields.
  bool validate() {
    String? startError = _validateDate(_startDate);
    final String? endError = _validateDate(_endDate);
    if (startError == null && endError == null) {
      if (_startDate!.isAfter(_endDate!)) {
        startError = widget.errorInvalidRangeText ??
            MaterialLocalizations.of(context).invalidDateRangeLabel;
      }
    }
    setState(() {
      _startErrorText = startError;
      _endErrorText = endError;
    });
    return startError == null && endError == null;
  }

  ETDateTime? _parseDate(String? text) {
    return parseCompactDate(text);
  }

  String? _validateDate(ETDateTime? date) {
    if (date == null) {
      return widget.errorFormatText ??
          MaterialLocalizations.of(context).invalidDateFormatLabel;
    } else if (date.isBefore(widget.firstDate) ||
        date.isAfter(widget.lastDate)) {
      return widget.errorInvalidText ??
          MaterialLocalizations.of(context).dateOutOfRangeLabel;
    }
    return null;
  }

  void _updateController(
      TextEditingController controller, String text, bool selectText) {
    TextEditingValue textEditingValue = controller.value.copyWith(text: text);
    if (selectText) {
      textEditingValue = textEditingValue.copyWith(
          selection: TextSelection(
        baseOffset: 0,
        extentOffset: text.length,
      ));
    }
    controller.value = textEditingValue;
  }

  void _handleStartChanged(String text) {
    setState(() {
      _startInputText = text;
      _startDate = _parseDate(text);
      widget.onStartDateChanged?.call(_startDate);
    });
    if (widget.autovalidate) {
      validate();
    }
  }

  void _handleEndChanged(String text) {
    setState(() {
      _endInputText = text;
      _endDate = _parseDate(text);
      widget.onEndDateChanged?.call(_endDate);
    });
    if (widget.autovalidate) {
      validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool useMaterial3 = theme.useMaterial3;
    final Localized localized = Localized(context);
    final InputDecorationTheme inputTheme = theme.inputDecorationTheme;
    final InputBorder inputBorder = inputTheme.border ??
        (useMaterial3
            ? const OutlineInputBorder()
            : const UnderlineInputBorder());

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: TextField(
            controller: _startController,
            decoration: InputDecoration(
              border: inputBorder,
              filled: inputTheme.filled,
              hintText: widget.fieldStartHintText ?? localized.dateHelpText,
              labelText:
                  widget.fieldStartLabelText ?? localized.dateRangeStartLabel,
              errorText: _startErrorText,
            ),
            keyboardType: widget.keyboardType,
            onChanged: _handleStartChanged,
            autofocus: widget.autofocus,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _endController,
            decoration: InputDecoration(
              border: inputBorder,
              filled: inputTheme.filled,
              hintText: widget.fieldEndHintText ?? localized.dateHelpText,
              labelText:
                  widget.fieldEndLabelText ?? localized.dateRangeEndLabel,
              errorText: _endErrorText,
            ),
            keyboardType: widget.keyboardType,
            onChanged: _handleEndChanged,
          ),
        ),
      ],
    );
  }
}

class InputETDateRangePickerDialog extends StatelessWidget {
  const InputETDateRangePickerDialog({
    super.key,
    required this.selectedStartDate,
    required this.selectedEndDate,
    required this.currentDate,
    required this.picker,
    required this.onConfirm,
    required this.onCancel,
    required this.confirmText,
    required this.cancelText,
    required this.helpText,
    required this.entryModeButton,
  });

  final ETDateTime? selectedStartDate;
  final ETDateTime? selectedEndDate;
  final ETDateTime? currentDate;
  final Widget picker;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final String? confirmText;
  final String? cancelText;
  final String? helpText;
  final Widget? entryModeButton;

  String _formatDateRange(BuildContext context, ETDateTime? start,
      ETDateTime? end, ETDateTime now) {
    Localized localized = Localized(context);
    final String startText = formatRangeStartETDate(start, end, context);
    final String endText = formatRangeEndETDate(start, end, now, context);
    if (start == null || end == null) {
      return localized.unspecifiedDateRange;
    }
    if (Directionality.of(context) == TextDirection.ltr) {
      return '$startText – $endText';
    } else {
      return '$endText – $startText';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool useMaterial3 = Theme.of(context).useMaterial3;
    final Localized localized = Localized(context);
    final Orientation orientation = MediaQuery.orientationOf(context);
    final DatePickerThemeData datePickerTheme = DatePickerTheme.of(context);
    final DatePickerThemeData defaults = DatePickerTheme.defaults(context);

    // There's no M3 spec for a landscape layout input (not calendar)
    // date range picker. To ensure that the date range displayed in the
    // input date range picker's header fits in landscape mode, we override
    // the M3 default here.
    TextStyle? headlineStyle = (orientation == Orientation.portrait)
        ? datePickerTheme.headerHeadlineStyle ?? defaults.headerHeadlineStyle
        : Theme.of(context).textTheme.headlineSmall;

    final Color? headerForegroundColor =
        datePickerTheme.headerForegroundColor ?? defaults.headerForegroundColor;
    headlineStyle = headlineStyle?.copyWith(color: headerForegroundColor);

    final String dateText = _formatDateRange(
        context, selectedStartDate, selectedEndDate, currentDate!);
    final String semanticDateText = selectedStartDate != null &&
            selectedEndDate != null
        ? '${localized.formatMediumDate(selectedStartDate!)} – ${localized.formatMediumDate(selectedEndDate!)}'
        : '';

    final Widget header = ETDatePickerHeader(
      helpText: helpText ??
          (useMaterial3
              ? localized.dateRangePickerHelpText
              : localized.dateRangePickerHelpText.toUpperCase()),
      titleText: dateText,
      titleSemanticsLabel: semanticDateText,
      titleStyle: headlineStyle,
      orientation: orientation,
      isShort: orientation == Orientation.landscape,
      entryModeButton: entryModeButton,
    );

    final Widget actions = Container(
      alignment: AlignmentDirectional.centerEnd,
      constraints: const BoxConstraints(minHeight: 52.0),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: OverflowBar(
        spacing: 8,
        children: <Widget>[
          TextButton(
            onPressed: onCancel,
            child: Text(cancelText ??
                (useMaterial3
                    ? localized.cancelButtonLabel
                    : localized.cancelButtonLabel.toUpperCase())),
          ),
          TextButton(
            onPressed: onConfirm,
            child: Text(confirmText ?? localized.okButtonLabel),
          ),
        ],
      ),
    );

    final double textScaleFactor = MediaQuery.textScalerOf(context)
        .clamp(maxScaleFactor: _kMaxTextScaleFactor)
        .scale(1);
    final Size dialogSize = (useMaterial3
            ? _inputPortraitDialogSizeM3
            : _inputPortraitDialogSizeM2) *
        textScaleFactor;
    switch (orientation) {
      case Orientation.portrait:
        return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          final Size portraitDialogSize = useMaterial3
              ? _inputPortraitDialogSizeM3
              : _inputPortraitDialogSizeM2;
          // Make sure the portrait dialog can fit the contents comfortably when
          // resized from the landscape dialog.
          final bool isFullyPortrait = constraints.maxHeight >=
              math.min(dialogSize.height, portraitDialogSize.height);

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              header,
              if (isFullyPortrait) ...<Widget>[
                Expanded(child: picker),
                actions,
              ],
            ],
          );
        });

      case Orientation.landscape:
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            header,
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
  }
}

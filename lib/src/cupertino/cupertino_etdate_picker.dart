import 'dart:math' as math;

import 'package:ethiopian_datetime/ethiopian_datetime.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';

import '../calander_common.dart';
import 'cupertino_common.dart';
import 'picker.dart';

// Different types of column in CupertinoETDatePicker.
enum _PickerColumnType {
  // Day of month column in date mode.
  dayOfMonth,
  // Month column in date mode.
  month,
  // Year column in date mode.
  year,
  // Medium date column in dateAndTime mode.
  date,
  // Hour column in time and dateAndTime mode.
  hour,
  // minute column in time and dateAndTime mode.
  minute,
  // AM/PM column in time and dateAndTime mode.
  dayPeriod,
}

// Values derived from https://developer.apple.com/design/resources/ and on iOS
// simulators with "Debug View Hierarchy".
const double _kItemExtent = 32.0;
// From the picker's intrinsic content size constraint.
const double _kPickerWidth = 320.0;
const bool _kUseMagnifier = true;
const double _kMagnification = 2.35 / 2.1;
const double _kDatePickerPadSize = 12.0;
// The density of a date picker is different from a generic picker.
// Eyeballed from iOS.
const double _kSqueeze = 1.25;

const TextStyle _kDefaultPickerTextStyle = TextStyle(
  letterSpacing: -0.83,
);

/// Retrieves the theme text style for the date picker based on the provided [context].
/// Adjusts the text style color based on the validity status indicated by [isValid].
/// Returns the modified text style with color adjustments.
TextStyle _themeTextStyle(BuildContext context, {bool isValid = true}) {
  final TextStyle style =
      CupertinoTheme.of(context).textTheme.dateTimePickerTextStyle;
  return isValid
      ? style.copyWith(
          color: CupertinoDynamicColor.maybeResolve(style.color, context))
      : style.copyWith(
          color: CupertinoDynamicColor.resolve(
              CupertinoColors.inactiveGray, context));
}

/// Animates a fixed extent scroll controller to scroll to the specified [targetItem].
/// Uses easing animation with a duration of 200 milliseconds for a smooth scroll effect.
void _animateColumnControllerToItem(
    FixedExtentScrollController controller, int targetItem) {
  controller.animateToItem(
    targetItem,
    curve: Curves.easeInOut,
    duration: const Duration(milliseconds: 200),
  );
}

const Widget _startSelectionOverlay =
    CupertinoPickerDefaultSelectionOverlay(capEndEdge: false);
const Widget _centerSelectionOverlay = CupertinoPickerDefaultSelectionOverlay(
    capStartEdge: false, capEndEdge: false);
const Widget _endSelectionOverlay =
    CupertinoPickerDefaultSelectionOverlay(capStartEdge: false);

// Lays out the date picker based on how much space each single column needs.
//
// Each column is a child of this delegate, indexed from 0 to number of columns - 1.
// Each column will be padded horizontally by 12.0 both left and right.
//
// The picker will be placed in the center, and the leftmost and rightmost
// column will be extended equally to the remaining width.
class _DatePickerLayoutDelegate extends MultiChildLayoutDelegate {
  _DatePickerLayoutDelegate({
    required this.columnWidths,
    required this.textDirectionFactor,
    required this.maxWidth,
  });

  // The list containing widths of all columns.
  final List<double> columnWidths;

  // textDirectionFactor is 1 if text is written left to right, and -1 if right to left.
  final int textDirectionFactor;

  // The max width the children should reach to avoid bending outwards.
  final double maxWidth;

  @override
  void performLayout(Size size) {
    double remainingWidth = maxWidth < size.width ? maxWidth : size.width;

    double currentHorizontalOffset = (size.width - remainingWidth) / 2;

    for (int i = 0; i < columnWidths.length; i++) {
      remainingWidth -= columnWidths[i] + _kDatePickerPadSize * 2;
    }

    for (int i = 0; i < columnWidths.length; i++) {
      final int index =
          textDirectionFactor == 1 ? i : columnWidths.length - i - 1;

      double childWidth = columnWidths[index] + _kDatePickerPadSize * 2;
      if (index == 0 || index == columnWidths.length - 1) {
        childWidth += remainingWidth / 2;
      }

      // We can't actually assert here because it would break things badly for
      // semantics, which will expect that we laid things out here.
      assert(() {
        if (childWidth < 0) {
          FlutterError.reportError(
            FlutterErrorDetails(
              exception: FlutterError(
                'Insufficient horizontal space to render the '
                'CupertinoETDatePicker because the parent is too narrow at '
                '${size.width}px.\n'
                'An additional ${-remainingWidth}px is needed to avoid '
                'overlapping columns.',
              ),
            ),
          );
        }
        return true;
      }());
      layoutChild(index,
          BoxConstraints.tight(Size(math.max(0.0, childWidth), size.height)));
      positionChild(index, Offset(currentHorizontalOffset, 0.0));

      currentHorizontalOffset += childWidth;
    }
  }

  @override
  bool shouldRelayout(_DatePickerLayoutDelegate oldDelegate) {
    return columnWidths != oldDelegate.columnWidths ||
        textDirectionFactor != oldDelegate.textDirectionFactor;
  }
}

/// A date picker widget in iOS style. For Ethiopian Calander.
/// documentation for flutter cupertino will be applicable for this.
///
/// There are several modes of the date picker listed in [CupertinoDatePickerMode].
///
/// The class will display its children as consecutive columns. Its children
/// order is based on internationalization, or the [dateOrder] property if specified.
///
/// Example of the picker in date mode:
///
///  * US-English: `| Meske | 13 | 2012 |`
///
/// Can be used with [showCupertinoModalPopup] to display the picker modally at
/// the bottom of the screen.
///
/// Sizes itself to its parent and may not render correctly if not given the
/// full screen width. Content texts are shown with
/// [CupertinoTextThemeData.dateTimePickerTextStyle].
///
/// {@tool dartpad}
/// This sample shows how to implement CupertinoETDatePicker with different picker modes.
/// We can provide initial dateTime value for the picker to display. When user changes
/// the drag the date or time wheels, the picker will call onDateTimeChanged callback.
///
/// CupertinoETDatePicker can be displayed directly on a screen or in a popup.
///
/// ** See code in examples/api/lib/cupertino/date_picker/cupertino_date_picker.0.dart **
/// {@end-tool}
///
/// See also:
///
///  * [CupertinoTimerPicker], the class that implements the iOS-style timer picker.
///  * [CupertinoPicker], the class that implements a content agnostic spinner UI.
///  * <https://developer.apple.com/design/human-interface-guidelines/ios/controls/pickers/>
class CupertinoETDatePicker extends StatefulWidget {
  /// Constructs an iOS style date picker.
  ///
  /// [mode] is one of the mode listed in [CupertinoDatePickerMode] and defaults
  /// to [CupertinoDatePickerMode.dateAndTime].
  ///
  /// [onDateTimeChanged] is the callback called when the selected date or time
  /// changes. When in [CupertinoDatePickerMode.time] mode, the year, month and
  /// day will be the same as [initialDateTime]. When in
  /// [CupertinoDatePickerMode.date] mode, this callback will always report the
  /// start time of the currently selected day. When in
  /// [CupertinoDatePickerMode.monthYear] mode, the day and time will be the
  /// start time of the first day of the month.
  ///
  /// [initialDateTime] is the initial date time of the picker. Defaults to the
  /// present date and time. The present must conform to the intervals set in
  /// [minimumDate], [maximumDate], [minimumYear], and [maximumYear].
  ///
  /// [minimumDate] is the minimum selectable [ETDateTime] of the picker. When set
  /// to null, the picker does not limit the minimum [ETDateTime] the user can pick.
  /// In [CupertinoDatePickerMode.time] mode, [minimumDate] should typically be
  /// on the same date as [initialDateTime], as the picker will not limit the
  /// minimum time the user can pick if it's set to a date earlier than that.
  ///
  /// [maximumDate] is the maximum selectable [ETDateTime] of the picker. When set
  /// to null, the picker does not limit the maximum [ETDateTime] the user can pick.
  /// In [CupertinoDatePickerMode.time] mode, [maximumDate] should typically be
  /// on the same date as [initialDateTime], as the picker will not limit the
  /// maximum time the user can pick if it's set to a date later than that.
  ///
  /// [minimumYear] is the minimum year that the picker can be scrolled to in
  /// [CupertinoDatePickerMode.date] mode. Defaults to 1.
  ///
  /// [maximumYear] is the maximum year that the picker can be scrolled to in
  /// [CupertinoDatePickerMode.date] mode. Null if there's no limit.
  ///
  /// [minuteInterval] is the granularity of the minute spinner. Must be a
  /// positive integer factor of 60.
  ///
  /// [use24hFormat] decides whether 24 hour format is used. Defaults to false.
  ///
  /// [dateOrder] determines the order of the columns inside [CupertinoETDatePicker]
  /// in [CupertinoDatePickerMode.date] and [CupertinoDatePickerMode.monthYear]
  /// mode. When using monthYear mode, both [DatePickerDateOrder.dmy] and
  /// [DatePickerDateOrder.mdy] will result in the month|year order.
  /// Defaults to the locale's default date format/order.
  CupertinoETDatePicker({
    super.key,
    this.mode = CupertinoDatePickerMode.dateAndTime,
    this.locale,
    required this.onDateTimeChanged,
    ETDateTime? initialDateTime,
    this.minimumDate,
    this.maximumDate,
    this.minimumYear = 1,
    this.maximumYear,
    this.minuteInterval = 1,
    this.use24hFormat = false,
    this.dateOrder,
    this.backgroundColor,
    this.showDayOfWeek = false,
    this.itemExtent = _kItemExtent,
  })  : initialDateTime = initialDateTime ?? ETDateTime.now(),
        assert(
          itemExtent > 0,
          'item extent should be greater than 0',
        ),
        assert(
          minuteInterval > 0 && 60 % minuteInterval == 0,
          'minute interval is not a positive integer factor of 60',
        ) {
    assert(
      mode != CupertinoDatePickerMode.dateAndTime ||
          minimumDate == null ||
          !this.initialDateTime.isBefore(minimumDate!),
      'initial date is before minimum date',
    );
    assert(
      mode != CupertinoDatePickerMode.dateAndTime ||
          maximumDate == null ||
          !this.initialDateTime.isAfter(maximumDate!),
      'initial date is after maximum date',
    );
    assert(
      (mode != CupertinoDatePickerMode.date &&
              mode != CupertinoDatePickerMode.monthYear) ||
          (minimumYear >= 1 && this.initialDateTime.year >= minimumYear),
      'initial year is not greater than minimum year, or minimum year is not positive',
    );
    assert(
      (mode != CupertinoDatePickerMode.date &&
              mode != CupertinoDatePickerMode.monthYear) ||
          maximumYear == null ||
          this.initialDateTime.year <= maximumYear!,
      'initial year is not smaller than maximum year',
    );
    assert(
      (mode != CupertinoDatePickerMode.date &&
              mode != CupertinoDatePickerMode.monthYear) ||
          minimumDate == null ||
          !minimumDate!.isAfter(this.initialDateTime),
      'initial date ${this.initialDateTime} is not greater than or equal to minimumDate $minimumDate',
    );
    assert(
      (mode != CupertinoDatePickerMode.date &&
              mode != CupertinoDatePickerMode.monthYear) ||
          maximumDate == null ||
          !maximumDate!.isBefore(this.initialDateTime),
      'initial date ${this.initialDateTime} is not less than or equal to maximumDate $maximumDate',
    );
    assert(
      this.initialDateTime.minute % minuteInterval == 0,
      'initial minute is not divisible by minute interval',
    );
  }

  /// The mode of the date picker as one of [CupertinoDatePickerMode]. Defaults
  /// to [CupertinoDatePickerMode.dateAndTime]. Value cannot change after
  /// initial build.
  final CupertinoDatePickerMode mode;

  /// The initial date and/or time of the picker. Defaults to the present date
  /// and time. The present must conform to the intervals set in [minimumDate],
  /// [maximumDate], [minimumYear], and [maximumYear].
  ///
  /// Changing this value after the initial build will not affect the currently
  /// selected date time.
  final ETDateTime initialDateTime;

  final Locale? locale;

  /// The minimum selectable date that the picker can settle on.
  ///
  /// When non-null, the user can still scroll the picker to [ETDateTime]s earlier
  /// than [minimumDate], but the [onDateTimeChanged] will not be called on
  /// these [ETDateTime]s. Once let go, the picker will scroll back to [minimumDate].
  ///
  /// In [CupertinoDatePickerMode.time] mode, a time becomes unselectable if the
  /// [ETDateTime] produced by combining that particular time and the date part of
  /// [initialDateTime] is earlier than [minimumDate]. So typically [minimumDate]
  /// needs to be set to a [ETDateTime] that is on the same date as [initialDateTime].
  ///
  /// Defaults to null. When set to null, the picker does not impose a limit on
  /// the earliest [ETDateTime] the user can select.
  final ETDateTime? minimumDate;

  /// The maximum selectable date that the picker can settle on.
  ///
  /// When non-null, the user can still scroll the picker to [ETDateTime]s later
  /// than [maximumDate], but the [onDateTimeChanged] will not be called on
  /// these [ETDateTime]s. Once let go, the picker will scroll back to [maximumDate].
  ///
  /// In [CupertinoDatePickerMode.time] mode, a time becomes unselectable if the
  /// [ETDateTime] produced by combining that particular time and the date part of
  /// [initialDateTime] is later than [maximumDate]. So typically [maximumDate]
  /// needs to be set to a [ETDateTime] that is on the same date as [initialDateTime].
  ///
  /// Defaults to null. When set to null, the picker does not impose a limit on
  /// the latest [ETDateTime] the user can select.
  final ETDateTime? maximumDate;

  /// Minimum year that the picker can be scrolled to in
  /// [CupertinoDatePickerMode.date] mode. Defaults to 1.
  final int minimumYear;

  /// Maximum year that the picker can be scrolled to in
  /// [CupertinoDatePickerMode.date] mode. Null if there's no limit.
  final int? maximumYear;

  /// The granularity of the minutes spinner, if it is shown in the current mode.
  /// Must be an integer factor of 60.
  final int minuteInterval;

  /// Whether to use 24 hour format. Defaults to false.
  final bool use24hFormat;

  /// Determines the order of the columns inside [CupertinoETDatePicker] in
  /// [CupertinoDatePickerMode.date] and [CupertinoDatePickerMode.monthYear]
  /// mode. When using monthYear mode, both [DatePickerDateOrder.dmy] and
  /// [DatePickerDateOrder.mdy] will result in the month|year order.
  /// Defaults to the locale's default date format/order.
  final DatePickerDateOrder? dateOrder;

  /// Callback called when the selected date and/or time changes. If the new
  /// selected [ETDateTime] is not valid, or is not in the [minimumDate] through
  /// [maximumDate] range, this callback will not be called.
  final ValueChanged<ETDateTime> onDateTimeChanged;

  /// Background color of date picker.
  ///
  /// Defaults to null, which disables background painting entirely.
  final Color? backgroundColor;

  /// Whether to to show day of week alongside day. Defaults to false.
  final bool showDayOfWeek;

  /// {@macro flutter.cupertino.picker.itemExtent}
  ///
  /// Defaults to a value that matches the default iOS date picker wheel.
  final double itemExtent;

  @override
  // ignore: no_logic_in_create_state,https://github.com/flutter/flutter/issues/70499
  State<StatefulWidget> createState() {
    // The `time` mode and `dateAndTime` mode of the picker share the time
    // columns, so they are placed together to one state.
    // The `date` mode has different children and is implemented in a different
    // state.
    switch (mode) {
      case CupertinoDatePickerMode.time:
      case CupertinoDatePickerMode.dateAndTime:
        return _CupertinoDatePickerDateTimeState();
      case CupertinoDatePickerMode.date:
        return _CupertinoDatePickerDateState(dateOrder: dateOrder);
      case CupertinoDatePickerMode.monthYear:
        return _CupertinoDatePickerMonthYearState(dateOrder: dateOrder);
    }
  }

  // Estimate the minimum width that each column needs to layout its content.
  static double _getColumnWidth(
    _PickerColumnType columnType,
    CupertinoLocalizations localizations,
    BuildContext context,
    bool showDayOfWeek, {
    bool standaloneMonth = false,
  }) {
    String longestText = '';

    switch (columnType) {
      case _PickerColumnType.date:
        // Measuring the length of all possible date is impossible, so here
        // just some dates are measured.
        for (int i = 1; i <= 13; i++) {
          // An arbitrary date.
          final String date =
              datePickerMediumDate(ETDateTime(2018, i, 25), context);
          if (longestText.length < date.length) {
            longestText = date;
          }
        }
      case _PickerColumnType.hour:
        for (int i = 0; i < 24; i++) {
          final String hour = localizations.datePickerHour(i);
          if (longestText.length < hour.length) {
            longestText = hour;
          }
        }
      case _PickerColumnType.minute:
        for (int i = 0; i < 60; i++) {
          final String minute = localizations.datePickerMinute(i);
          if (longestText.length < minute.length) {
            longestText = minute;
          }
        }
      case _PickerColumnType.dayPeriod:
        longestText = anteMeridiemAbbreviation(context).length >
                postMeridiemAbbreviation(context).length
            ? anteMeridiemAbbreviation(context)
            : postMeridiemAbbreviation(context);
      case _PickerColumnType.dayOfMonth:
        int longestDayOfMonth = 1;
        for (int i = 1; i <= 31; i++) {
          final String dayOfMonth = localizations.datePickerDayOfMonth(i);
          if (longestText.length < dayOfMonth.length) {
            longestText = dayOfMonth;
            longestDayOfMonth = i;
          }
        }
        if (showDayOfWeek) {
          for (int wd = 1; wd < ETDateTime.daysPerWeek; wd++) {
            final String dayOfMonth =
                datePickerDayOfMonth(longestDayOfMonth, context, wd);
            if (longestText.length < dayOfMonth.length) {
              longestText = dayOfMonth;
            }
          }
        }
      case _PickerColumnType.month:
        for (int i = 1; i <= 12; i++) {
          final String month = standaloneMonth
              ? datePickerStandaloneMonth(i, context)
              : datePickerMonth(i, context);
          if (longestText.length < month.length) {
            longestText = month;
          }
        }
      case _PickerColumnType.year:
        longestText = localizations.datePickerYear(2018);
    }

    assert(longestText != '', 'column type is not appropriate');

    return TextPainter.computeMaxIntrinsicWidth(
      text: TextSpan(
        style: _themeTextStyle(context),
        text: longestText,
      ),
      textDirection: Directionality.of(context),
    );
  }
}

typedef _ColumnBuilder = Widget Function(double offAxisFraction,
    TransitionBuilder itemPositioningBuilder, Widget selectionOverlay);

class _CupertinoDatePickerDateTimeState extends State<CupertinoETDatePicker> {
  // Fraction of the farthest column's vanishing point vs its width. Eyeballed
  // vs iOS.
  static const double _kMaximumOffAxisFraction = 0.45;

  late int textDirectionFactor;
  late CupertinoLocalizations localizations;

  // Alignment based on text direction. The variable name is self descriptive,
  // however, when text direction is rtl, alignment is reversed.
  late Alignment alignCenterLeft;
  late Alignment alignCenterRight;

  // Read this out when the state is initially created. Changes in initialDateTime
  // in the widget after first build is ignored.
  late ETDateTime initialDateTime;

  // The difference in days between the initial date and the currently selected date.
  // 0 if the current mode does not involve a date.
  int get selectedDayFromInitial {
    switch (widget.mode) {
      case CupertinoDatePickerMode.dateAndTime:
        return dateController.hasClients ? dateController.selectedItem : 0;
      case CupertinoDatePickerMode.time:
        return 0;
      case CupertinoDatePickerMode.date:
      case CupertinoDatePickerMode.monthYear:
        break;
    }
    assert(
      false,
      '$runtimeType is only meant for dateAndTime mode or time mode',
    );
    return 0;
  }

  // The controller of the date column.
  late FixedExtentScrollController dateController;

  // The current selection of the hour picker. Values range from 0 to 23.
  int get selectedHour => _selectedHour(selectedAmPm, _selectedHourIndex);
  int get _selectedHourIndex => hourController.hasClients
      ? hourController.selectedItem % 24
      : initialDateTime.hour;
  // Calculates the selected hour given the selected indices of the hour picker
  // and the meridiem picker.
  int _selectedHour(int selectedAmPm, int selectedHour) {
    return _isHourRegionFlipped(selectedAmPm)
        ? (selectedHour + 12) % 24
        : selectedHour;
  }

  // The controller of the hour column.
  late FixedExtentScrollController hourController;

  // The current selection of the minute picker. Values range from 0 to 59.
  int get selectedMinute {
    return minuteController.hasClients
        ? minuteController.selectedItem * widget.minuteInterval % 60
        : initialDateTime.minute;
  }

  // The controller of the minute column.
  late FixedExtentScrollController minuteController;

  // Whether the current meridiem selection is AM or PM.
  //
  // We can't use the selectedItem of meridiemController as the source of truth
  // because the meridiem picker can be scrolled **animatedly** by the hour picker
  // (e.g. if you scroll from 12 to 1 in 12h format), but the meridiem change
  // should take effect immediately, **before** the animation finishes.
  late int selectedAmPm;
  // Whether the physical-region-to-meridiem mapping is flipped.
  bool get isHourRegionFlipped => _isHourRegionFlipped(selectedAmPm);
  bool _isHourRegionFlipped(int selectedAmPm) => selectedAmPm != meridiemRegion;
  // The index of the 12-hour region the hour picker is currently in.
  //
  // Used to determine whether the meridiemController should start animating.
  // Valid values are 0 and 1.
  //
  // The AM/PM correspondence of the two regions flips when the meridiem picker
  // scrolls. This variable is to keep track of the selected "physical"
  // (meridiem picker invariant) region of the hour picker. The "physical" region
  // of an item of index `i` is `i ~/ 12`.
  late int meridiemRegion;
  // The current selection of the AM/PM picker.
  //
  // - 0 means AM
  // - 1 means PM
  late FixedExtentScrollController meridiemController;

  bool isDatePickerScrolling = false;
  bool isHourPickerScrolling = false;
  bool isMinutePickerScrolling = false;
  bool isMeridiemPickerScrolling = false;

  bool get isScrolling {
    return isDatePickerScrolling ||
        isHourPickerScrolling ||
        isMinutePickerScrolling ||
        isMeridiemPickerScrolling;
  }

  // The estimated width of columns.
  final Map<int, double> estimatedColumnWidths = <int, double>{};

  @override
  void initState() {
    super.initState();
    initialDateTime = widget.initialDateTime;

    // Initially each of the "physical" regions is mapped to the meridiem region
    // with the same number, e.g., the first 12 items are mapped to the first 12
    // hours of a day. Such mapping is flipped when the meridiem picker is scrolled
    // by the user, the first 12 items are mapped to the last 12 hours of a day.
    if (initialDateTime.timeofday == 'TEWAT' ||
        initialDateTime.timeofday == 'QEN') {
      selectedAmPm = 0;
    } else {
      selectedAmPm = 1;
    }

    meridiemRegion = selectedAmPm;

    meridiemController = FixedExtentScrollController(initialItem: selectedAmPm);
    hourController =
        FixedExtentScrollController(initialItem: initialDateTime.hour);
    minuteController = FixedExtentScrollController(
        initialItem: initialDateTime.minute ~/ widget.minuteInterval);
    dateController = FixedExtentScrollController();

    PaintingBinding.instance.systemFonts.addListener(_handleSystemFontsChange);
  }

  void _handleSystemFontsChange() {
    setState(() {
      // System fonts change might cause the text layout width to change.
      // Clears cached width to ensure that they get recalculated with the
      // new system fonts.
      estimatedColumnWidths.clear();
    });
  }

  @override
  void dispose() {
    dateController.dispose();
    hourController.dispose();
    minuteController.dispose();
    meridiemController.dispose();

    PaintingBinding.instance.systemFonts
        .removeListener(_handleSystemFontsChange);
    super.dispose();
  }

  @override
  void didUpdateWidget(CupertinoETDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    assert(
      oldWidget.mode == widget.mode,
      "The $runtimeType's mode cannot change once it's built.",
    );

    if (!widget.use24hFormat && oldWidget.use24hFormat) {
      // Thanks to the physical and meridiem region mapping, the only thing we
      // need to update is the meridiem controller, if it's not previously attached.
      meridiemController.dispose();
      meridiemController =
          FixedExtentScrollController(initialItem: selectedAmPm);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    textDirectionFactor =
        Directionality.of(context) == TextDirection.ltr ? 1 : -1;
    localizations = CupertinoLocalizations.of(context);
    GlobalLocale.locale = widget.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;
    alignCenterLeft =
        textDirectionFactor == 1 ? Alignment.centerLeft : Alignment.centerRight;
    alignCenterRight =
        textDirectionFactor == 1 ? Alignment.centerRight : Alignment.centerLeft;

    estimatedColumnWidths.clear();
  }

  // Lazily calculate the column width of the column being displayed only.
  double _getEstimatedColumnWidth(_PickerColumnType columnType) {
    if (estimatedColumnWidths[columnType.index] == null) {
      estimatedColumnWidths[columnType.index] =
          CupertinoETDatePicker._getColumnWidth(
              columnType, localizations, context, widget.showDayOfWeek);
    }

    return estimatedColumnWidths[columnType.index]!;
  }

  // Gets the current date time of the picker.
  ETDateTime get selectedDateTime {
    return ETDateTime(
      initialDateTime.year,
      initialDateTime.month,
      initialDateTime.day + selectedDayFromInitial,
      selectedHour,
      selectedMinute,
    );
  }

  // Only reports datetime change when the date time is valid.
  void _onSelectedItemChange(int index) {
    final ETDateTime selected = selectedDateTime;

    final bool isDateInvalid =
        (widget.minimumDate?.isAfter(selected) ?? false) ||
            (widget.maximumDate?.isBefore(selected) ?? false);

    if (isDateInvalid) {
      return;
    }

    widget.onDateTimeChanged(selected);
  }

  // Builds the date column. The date is displayed in medium date format (e.g. Fri Aug 31).
  Widget _buildMediumDatePicker(double offAxisFraction,
      TransitionBuilder itemPositioningBuilder, Widget selectionOverlay) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollStartNotification) {
          isDatePickerScrolling = true;
        } else if (notification is ScrollEndNotification) {
          isDatePickerScrolling = false;
          _pickerDidStopScrolling();
        }

        return false;
      },
      child: CupertinoETPicker.builder(
        scrollController: dateController,
        offAxisFraction: offAxisFraction,
        itemExtent: widget.itemExtent,
        useMagnifier: _kUseMagnifier,
        magnification: _kMagnification,
        backgroundColor: widget.backgroundColor,
        squeeze: _kSqueeze,
        onSelectedItemChanged: (int index) {
          _onSelectedItemChange(index);
        },
        itemBuilder: (BuildContext context, int index) {
          final ETDateTime rangeStart = ETDateTime(
            initialDateTime.year,
            initialDateTime.month,
            initialDateTime.day + index,
          );

          // Exclusive.
          final ETDateTime rangeEnd = ETDateTime(
            initialDateTime.year,
            initialDateTime.month,
            initialDateTime.day + index + 1,
          );

          final ETDateTime now = ETDateTime.now();

          if (widget.minimumDate?.isBefore(rangeEnd) == false) {
            return null;
          }
          if (widget.maximumDate?.isAfter(rangeStart) == false) {
            return null;
          }

          final String dateText =
              rangeStart == ETDateTime(now.year, now.month, now.day)
                  ? todayLabel(context)
                  : datePickerMediumDate(rangeStart, context);

          return itemPositioningBuilder(
            context,
            Text(dateText, style: _themeTextStyle(context)),
          );
        },
        selectionOverlay: selectionOverlay,
      ),
    );
  }

  // With the meridiem picker set to `meridiemIndex`, and the hour picker set to
  // `hourIndex`, is it possible to change the value of the minute picker, so
  // that the resulting date stays in the valid range.
  bool _isValidHour(int meridiemIndex, int hourIndex) {
    final ETDateTime rangeStart = ETDateTime(
      initialDateTime.year,
      initialDateTime.month,
      initialDateTime.day + selectedDayFromInitial,
      _selectedHour(meridiemIndex, hourIndex),
    );

    // The end value of the range is exclusive, i.e. [rangeStart, rangeEnd).
    final ETDateTime rangeEnd = rangeStart.add(const Duration(hours: 1));

    return (widget.minimumDate?.isBefore(rangeEnd) ?? true) &&
        !(widget.maximumDate?.isBefore(rangeStart) ?? false);
  }

  Widget _buildHourPicker(double offAxisFraction,
      TransitionBuilder itemPositioningBuilder, Widget selectionOverlay) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollStartNotification) {
          isHourPickerScrolling = true;
        } else if (notification is ScrollEndNotification) {
          isHourPickerScrolling = false;
          _pickerDidStopScrolling();
        }

        return false;
      },
      child: CupertinoETPicker(
        scrollController: hourController,
        offAxisFraction: offAxisFraction,
        itemExtent: widget.itemExtent,
        useMagnifier: _kUseMagnifier,
        magnification: _kMagnification,
        backgroundColor: widget.backgroundColor,
        squeeze: _kSqueeze,
        onSelectedItemChanged: (int index) {
          final bool regionChanged = meridiemRegion != index ~/ 12;
          final bool debugIsFlipped = isHourRegionFlipped;

          if (regionChanged) {
            meridiemRegion = index ~/ 12;
            selectedAmPm = 1 - selectedAmPm;
          }

          if (!widget.use24hFormat && regionChanged) {
            // Scroll the meridiem column to adjust AM/PM.
            //
            // _onSelectedItemChanged will be called when the animation finishes.
            //
            // Animation values obtained by comparing with iOS version.
            meridiemController.animateToItem(
              selectedAmPm,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          } else {
            _onSelectedItemChange(index);
          }

          assert(debugIsFlipped == isHourRegionFlipped);
        },
        looping: true,
        selectionOverlay: selectionOverlay,
        children: List<Widget>.generate(24, (int index) {
          final int hour = isHourRegionFlipped ? (index + 12) % 24 : index;
          final int displayHour =
              widget.use24hFormat ? hour : (hour + 11) % 12 + 1;

          return itemPositioningBuilder(
            context,
            Text(
              localizations.datePickerHour(displayHour),
              semanticsLabel:
                  localizations.datePickerHourSemanticsLabel(displayHour),
              style: _themeTextStyle(context,
                  isValid: _isValidHour(selectedAmPm, index)),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMinutePicker(double offAxisFraction,
      TransitionBuilder itemPositioningBuilder, Widget selectionOverlay) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollStartNotification) {
          isMinutePickerScrolling = true;
        } else if (notification is ScrollEndNotification) {
          isMinutePickerScrolling = false;
          _pickerDidStopScrolling();
        }

        return false;
      },
      child: CupertinoETPicker(
        scrollController: minuteController,
        offAxisFraction: offAxisFraction,
        itemExtent: widget.itemExtent,
        useMagnifier: _kUseMagnifier,
        magnification: _kMagnification,
        backgroundColor: widget.backgroundColor,
        squeeze: _kSqueeze,
        onSelectedItemChanged: _onSelectedItemChange,
        looping: true,
        selectionOverlay: selectionOverlay,
        children:
            List<Widget>.generate(60 ~/ widget.minuteInterval, (int index) {
          final int minute = index * widget.minuteInterval;

          final ETDateTime date = ETDateTime(
            initialDateTime.year,
            initialDateTime.month,
            initialDateTime.day + selectedDayFromInitial,
            selectedHour,
            minute,
          );

          final bool isInvalidMinute =
              (widget.minimumDate?.isAfter(date) ?? false) ||
                  (widget.maximumDate?.isBefore(date) ?? false);

          return itemPositioningBuilder(
            context,
            Text(
              localizations.datePickerMinute(minute),
              semanticsLabel:
                  localizations.datePickerMinuteSemanticsLabel(minute),
              style: _themeTextStyle(context, isValid: !isInvalidMinute),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAmPmPicker(double offAxisFraction,
      TransitionBuilder itemPositioningBuilder, Widget selectionOverlay) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollStartNotification) {
          isMeridiemPickerScrolling = true;
        } else if (notification is ScrollEndNotification) {
          isMeridiemPickerScrolling = false;
          _pickerDidStopScrolling();
        }

        return false;
      },
      child: CupertinoETPicker(
        scrollController: meridiemController,
        offAxisFraction: offAxisFraction,
        itemExtent: widget.itemExtent,
        useMagnifier: _kUseMagnifier,
        magnification: _kMagnification,
        backgroundColor: widget.backgroundColor,
        squeeze: _kSqueeze,
        onSelectedItemChanged: (int index) {
          selectedAmPm = index;
          assert(selectedAmPm == 1 || selectedAmPm == 0);
          _onSelectedItemChange(index);
        },
        selectionOverlay: selectionOverlay,
        children: List<Widget>.generate(2, (int index) {
          return itemPositioningBuilder(
            context,
            Text(
              index == 0
                  ? anteMeridiemAbbreviation(context, _selectedHourIndex)
                  : postMeridiemAbbreviation(context, _selectedHourIndex),
              style: _themeTextStyle(context,
                  isValid: _isValidHour(index, _selectedHourIndex)),
            ),
          );
        }),
      ),
    );
  }

  // One or more pickers have just stopped scrolling.
  void _pickerDidStopScrolling() {
    // Call setState to update the greyed out date/hour/minute/meridiem.
    setState(() {});

    if (isScrolling) {
      return;
    }

    // Whenever scrolling lands on an invalid entry, the picker
    // automatically scrolls to a valid one.
    final ETDateTime selectedDate = selectedDateTime;

    final bool minCheck = widget.minimumDate?.isAfter(selectedDate) ?? false;
    final bool maxCheck = widget.maximumDate?.isBefore(selectedDate) ?? false;

    if (minCheck || maxCheck) {
      // We have minCheck === !maxCheck.
      final ETDateTime targetDate =
          minCheck ? widget.minimumDate! : widget.maximumDate!;
      _scrollToDate(targetDate, selectedDate, minCheck);
    }
  }

  void _scrollToDate(ETDateTime newDate, ETDateTime fromDate, bool minCheck) {
    SchedulerBinding.instance.addPostFrameCallback((Duration timestamp) {
      if (fromDate.year != newDate.year ||
          fromDate.month != newDate.month ||
          fromDate.day != newDate.day) {
        _animateColumnControllerToItem(dateController, selectedDayFromInitial);
      }

      if (fromDate.hour != newDate.hour) {
        final bool needsMeridiemChange =
            !widget.use24hFormat && fromDate.hour ~/ 12 != newDate.hour ~/ 12;
        // In AM/PM mode, the pickers should not scroll all the way to the other hour region.
        if (needsMeridiemChange) {
          _animateColumnControllerToItem(
              meridiemController, 1 - meridiemController.selectedItem);

          // Keep the target item index in the current 12-h region.
          final int newItem = (hourController.selectedItem ~/ 12) * 12 +
              (hourController.selectedItem + newDate.hour - fromDate.hour) % 12;
          _animateColumnControllerToItem(hourController, newItem);
        } else {
          _animateColumnControllerToItem(
            hourController,
            hourController.selectedItem + newDate.hour - fromDate.hour,
          );
        }
      }

      if (fromDate.minute != newDate.minute) {
        final double positionDouble = newDate.minute / widget.minuteInterval;
        final int position =
            minCheck ? positionDouble.ceil() : positionDouble.floor();
        _animateColumnControllerToItem(minuteController, position);
      }
    }, debugLabel: 'DatePicker.scrollToDate');
  }

  @override
  Widget build(BuildContext context) {
    // Widths of the columns in this picker, ordered from left to right.
    final List<double> columnWidths = <double>[
      _getEstimatedColumnWidth(_PickerColumnType.hour),
      _getEstimatedColumnWidth(_PickerColumnType.minute),
    ];

    // Swap the hours and minutes if RTL to ensure they are in the correct position.
    final List<_ColumnBuilder> pickerBuilders =
        Directionality.of(context) == TextDirection.rtl
            ? <_ColumnBuilder>[_buildMinutePicker, _buildHourPicker]
            : <_ColumnBuilder>[_buildHourPicker, _buildMinutePicker];

    // Adds am/pm column if the picker is not using 24h format.
    if (!widget.use24hFormat) {
      if (localizations.datePickerDateTimeOrder ==
              DatePickerDateTimeOrder.date_time_dayPeriod ||
          localizations.datePickerDateTimeOrder ==
              DatePickerDateTimeOrder.time_dayPeriod_date) {
        pickerBuilders.add(_buildAmPmPicker);
        columnWidths.add(_getEstimatedColumnWidth(_PickerColumnType.dayPeriod));
      } else {
        pickerBuilders.insert(0, _buildAmPmPicker);
        columnWidths.insert(
            0, _getEstimatedColumnWidth(_PickerColumnType.dayPeriod));
      }
    }

    // Adds medium date column if the picker's mode is date and time.
    if (widget.mode == CupertinoDatePickerMode.dateAndTime) {
      if (localizations.datePickerDateTimeOrder ==
              DatePickerDateTimeOrder.time_dayPeriod_date ||
          localizations.datePickerDateTimeOrder ==
              DatePickerDateTimeOrder.dayPeriod_time_date) {
        pickerBuilders.add(_buildMediumDatePicker);
        columnWidths.add(_getEstimatedColumnWidth(_PickerColumnType.date));
      } else {
        pickerBuilders.insert(0, _buildMediumDatePicker);
        columnWidths.insert(
            0, _getEstimatedColumnWidth(_PickerColumnType.date));
      }
    }

    final List<Widget> pickers = <Widget>[];
    double totalColumnWidths = 4 * _kDatePickerPadSize;

    for (int i = 0; i < columnWidths.length; i++) {
      double offAxisFraction = 0.0;
      Widget selectionOverlay = _centerSelectionOverlay;
      if (i == 0) {
        offAxisFraction = -_kMaximumOffAxisFraction * textDirectionFactor;
        selectionOverlay = _startSelectionOverlay;
      } else if (i >= 2 || columnWidths.length == 2) {
        offAxisFraction = _kMaximumOffAxisFraction * textDirectionFactor;
      }

      EdgeInsets padding = const EdgeInsets.only(right: _kDatePickerPadSize);
      if (i == columnWidths.length - 1) {
        padding = padding.flipped;
        selectionOverlay = _endSelectionOverlay;
      }
      if (textDirectionFactor == -1) {
        padding = padding.flipped;
      }

      totalColumnWidths += columnWidths[i] + (2 * _kDatePickerPadSize);

      pickers.add(LayoutId(
        id: i,
        child: pickerBuilders[i](
          offAxisFraction,
          (BuildContext context, Widget? child) {
            return Container(
              alignment: i == columnWidths.length - 1
                  ? alignCenterLeft
                  : alignCenterRight,
              padding: padding,
              child: Container(
                alignment: i == columnWidths.length - 1
                    ? alignCenterLeft
                    : alignCenterRight,
                width: i == 0 || i == columnWidths.length - 1
                    ? null
                    : columnWidths[i] + _kDatePickerPadSize,
                child: child,
              ),
            );
          },
          selectionOverlay,
        ),
      ));
    }

    final double maxPickerWidth =
        totalColumnWidths > _kPickerWidth ? totalColumnWidths : _kPickerWidth;

    return MediaQuery.withNoTextScaling(
      child: DefaultTextStyle.merge(
        style: _kDefaultPickerTextStyle,
        child: CustomMultiChildLayout(
          delegate: _DatePickerLayoutDelegate(
            columnWidths: columnWidths,
            textDirectionFactor: textDirectionFactor,
            maxWidth: maxPickerWidth,
          ),
          children: pickers,
        ),
      ),
    );
  }
}

class _CupertinoDatePickerDateState extends State<CupertinoETDatePicker> {
  _CupertinoDatePickerDateState({
    required this.dateOrder,
  });

  final DatePickerDateOrder? dateOrder;

  late int textDirectionFactor;
  late CupertinoLocalizations localizations;

  // Alignment based on text direction. The variable name is self descriptive,
  // however, when text direction is rtl, alignment is reversed.
  late Alignment alignCenterLeft;
  late Alignment alignCenterRight;

  // The currently selected values of the picker.
  late int selectedDay;
  late int selectedMonth;
  late int selectedYear;

  // The controller of the day picker. There are cases where the selected value
  // of the picker is invalid (e.g. February 30th 2018), and this dayController
  // is responsible for jumping to a valid value.
  late FixedExtentScrollController dayController;
  late FixedExtentScrollController monthController;
  late FixedExtentScrollController yearController;

  bool isDayPickerScrolling = false;
  bool isMonthPickerScrolling = false;
  bool isYearPickerScrolling = false;

  bool get isScrolling =>
      isDayPickerScrolling || isMonthPickerScrolling || isYearPickerScrolling;

  // Estimated width of columns.
  Map<int, double> estimatedColumnWidths = <int, double>{};

  @override
  void initState() {
    super.initState();
    selectedDay = widget.initialDateTime.day;
    selectedMonth = widget.initialDateTime.month;
    selectedYear = widget.initialDateTime.year;

    dayController = FixedExtentScrollController(initialItem: selectedDay - 1);
    monthController =
        FixedExtentScrollController(initialItem: selectedMonth - 1);
    yearController = FixedExtentScrollController(initialItem: selectedYear);

    PaintingBinding.instance.systemFonts.addListener(_handleSystemFontsChange);
  }

  void _handleSystemFontsChange() {
    setState(() {
      // System fonts change might cause the text layout width to change.
      _refreshEstimatedColumnWidths();
    });
  }

  @override
  void dispose() {
    dayController.dispose();
    monthController.dispose();
    yearController.dispose();

    PaintingBinding.instance.systemFonts
        .removeListener(_handleSystemFontsChange);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    textDirectionFactor =
        Directionality.of(context) == TextDirection.ltr ? 1 : -1;
    localizations = CupertinoLocalizations.of(context);

    GlobalLocale.locale = widget.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;
    alignCenterLeft =
        textDirectionFactor == 1 ? Alignment.centerLeft : Alignment.centerRight;
    alignCenterRight =
        textDirectionFactor == 1 ? Alignment.centerRight : Alignment.centerLeft;

    _refreshEstimatedColumnWidths();
  }

  void _refreshEstimatedColumnWidths() {
    estimatedColumnWidths[_PickerColumnType.dayOfMonth.index] =
        CupertinoETDatePicker._getColumnWidth(_PickerColumnType.dayOfMonth,
            localizations, context, widget.showDayOfWeek);
    estimatedColumnWidths[_PickerColumnType.month.index] =
        CupertinoETDatePicker._getColumnWidth(_PickerColumnType.month,
            localizations, context, widget.showDayOfWeek);
    estimatedColumnWidths[_PickerColumnType.year.index] =
        CupertinoETDatePicker._getColumnWidth(_PickerColumnType.year,
            localizations, context, widget.showDayOfWeek);
  }

  // The ETDateTime of the last day of a given month in a given year.
  // Let `ETDateTime` handle the year/month overflow.
  ETDateTime _lastDayInMonth(int year, int month) =>
      ETDateTime(year, month + 1, 0);

  Widget _buildDayPicker(double offAxisFraction,
      TransitionBuilder itemPositioningBuilder, Widget selectionOverlay) {
    final int daysInCurrentMonth =
        _lastDayInMonth(selectedYear, selectedMonth).day;
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollStartNotification) {
          isDayPickerScrolling = true;
        } else if (notification is ScrollEndNotification) {
          isDayPickerScrolling = false;
          _pickerDidStopScrolling();
        }

        return false;
      },
      child: CupertinoETPicker(
        scrollController: dayController,
        offAxisFraction: offAxisFraction,
        itemExtent: widget.itemExtent,
        useMagnifier: _kUseMagnifier,
        magnification: _kMagnification,
        backgroundColor: widget.backgroundColor,
        squeeze: _kSqueeze,
        onSelectedItemChanged: (int index) {
          selectedDay = index + 1;
          if (_isCurrentDateValid) {
            widget.onDateTimeChanged(
                ETDateTime(selectedYear, selectedMonth, selectedDay));
          }
        },
        looping: true,
        selectionOverlay: selectionOverlay,
        children: List<Widget>.generate(31, (int index) {
          final int day = index + 1;
          final int? dayOfWeek = widget.showDayOfWeek
              ? ETDateTime(selectedYear, selectedMonth, day).weekday
              : null;
          return itemPositioningBuilder(
            context,
            Text(
              datePickerDayOfMonth(day, context, dayOfWeek),
              style:
                  _themeTextStyle(context, isValid: day <= daysInCurrentMonth),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMonthPicker(double offAxisFraction,
      TransitionBuilder itemPositioningBuilder, Widget selectionOverlay) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollStartNotification) {
          isMonthPickerScrolling = true;
        } else if (notification is ScrollEndNotification) {
          isMonthPickerScrolling = false;
          _pickerDidStopScrolling();
        }

        return false;
      },
      child: CupertinoETPicker(
        scrollController: monthController,
        offAxisFraction: offAxisFraction,
        itemExtent: widget.itemExtent,
        useMagnifier: _kUseMagnifier,
        magnification: _kMagnification,
        backgroundColor: widget.backgroundColor,
        squeeze: _kSqueeze,
        onSelectedItemChanged: (int index) {
          selectedMonth = index + 1;
          if (_isCurrentDateValid) {
            widget.onDateTimeChanged(
                ETDateTime(selectedYear, selectedMonth, selectedDay));
          }
        },
        looping: true,
        selectionOverlay: selectionOverlay,
        children: List<Widget>.generate(12, (int index) {
          final int month = index + 1;
          final bool isInvalidMonth =
              (widget.minimumDate?.year == selectedYear &&
                      widget.minimumDate!.month > month) ||
                  (widget.maximumDate?.year == selectedYear &&
                      widget.maximumDate!.month < month);
          final String monthName =
              (widget.mode == CupertinoDatePickerMode.monthYear)
                  ? datePickerStandaloneMonth(month, context)
                  : datePickerMonth(month, context);

          return itemPositioningBuilder(
            context,
            Text(
              monthName,
              style: _themeTextStyle(context, isValid: !isInvalidMonth),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildYearPicker(double offAxisFraction,
      TransitionBuilder itemPositioningBuilder, Widget selectionOverlay) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollStartNotification) {
          isYearPickerScrolling = true;
        } else if (notification is ScrollEndNotification) {
          isYearPickerScrolling = false;
          _pickerDidStopScrolling();
        }

        return false;
      },
      child: CupertinoETPicker.builder(
        scrollController: yearController,
        itemExtent: widget.itemExtent,
        offAxisFraction: offAxisFraction,
        useMagnifier: _kUseMagnifier,
        magnification: _kMagnification,
        backgroundColor: widget.backgroundColor,
        onSelectedItemChanged: (int index) {
          selectedYear = index;
          if (_isCurrentDateValid) {
            widget.onDateTimeChanged(
                ETDateTime(selectedYear, selectedMonth, selectedDay));
          }
        },
        itemBuilder: (BuildContext context, int year) {
          if (year < widget.minimumYear) {
            return null;
          }

          if (widget.maximumYear != null && year > widget.maximumYear!) {
            return null;
          }

          final bool isValidYear = (widget.minimumDate == null ||
                  widget.minimumDate!.year <= year) &&
              (widget.maximumDate == null || widget.maximumDate!.year >= year);

          return itemPositioningBuilder(
            context,
            Text(
              localizations.datePickerYear(year),
              style: _themeTextStyle(context, isValid: isValidYear),
            ),
          );
        },
        selectionOverlay: selectionOverlay,
      ),
    );
  }

  bool get _isCurrentDateValid {
    // The current date selection represents a range [minSelectedData, maxSelectDate].
    final ETDateTime minSelectedDate =
        ETDateTime(selectedYear, selectedMonth, selectedDay);
    final ETDateTime maxSelectedDate =
        ETDateTime(selectedYear, selectedMonth, selectedDay + 1);

    final bool minCheck = widget.minimumDate?.isBefore(maxSelectedDate) ?? true;
    final bool maxCheck =
        widget.maximumDate?.isBefore(minSelectedDate) ?? false;

    return minCheck && !maxCheck && minSelectedDate.day == selectedDay;
  }

  // One or more pickers have just stopped scrolling.
  void _pickerDidStopScrolling() {
    // Call setState to update the greyed out days/months/years, as the currently
    // selected year/month may have changed.
    setState(() {});

    if (isScrolling) {
      return;
    }

    // Whenever scrolling lands on an invalid entry, the picker
    // automatically scrolls to a valid one.
    final ETDateTime minSelectDate =
        ETDateTime(selectedYear, selectedMonth, selectedDay);
    final ETDateTime maxSelectDate =
        ETDateTime(selectedYear, selectedMonth, selectedDay + 1);

    final bool minCheck = widget.minimumDate?.isBefore(maxSelectDate) ?? true;
    final bool maxCheck = widget.maximumDate?.isBefore(minSelectDate) ?? false;

    if (!minCheck || maxCheck) {
      // We have minCheck === !maxCheck.
      final ETDateTime targetDate =
          minCheck ? widget.maximumDate! : widget.minimumDate!;
      _scrollToDate(targetDate);
      return;
    }

    // Some months have less days (e.g. February). Go to the last day of that month
    // if the selectedDay exceeds the maximum.
    if (minSelectDate.day != selectedDay) {
      final ETDateTime lastDay = _lastDayInMonth(selectedYear, selectedMonth);
      _scrollToDate(lastDay);
    }
  }

  void _scrollToDate(ETDateTime newDate) {
    SchedulerBinding.instance.addPostFrameCallback((Duration timestamp) {
      if (selectedYear != newDate.year) {
        _animateColumnControllerToItem(yearController, newDate.year);
      }

      if (selectedMonth != newDate.month) {
        _animateColumnControllerToItem(monthController, newDate.month - 1);
      }

      if (selectedDay != newDate.day) {
        _animateColumnControllerToItem(dayController, newDate.day - 1);
      }
    }, debugLabel: 'DatePicker.scrollToDate');
  }

  @override
  Widget build(BuildContext context) {
    List<_ColumnBuilder> pickerBuilders = <_ColumnBuilder>[];
    List<double> columnWidths = <double>[];

    final DatePickerDateOrder datePickerDateOrder =
        dateOrder ?? localizations.datePickerDateOrder;

    switch (datePickerDateOrder) {
      case DatePickerDateOrder.mdy:
        pickerBuilders = <_ColumnBuilder>[
          _buildMonthPicker,
          _buildDayPicker,
          _buildYearPicker
        ];
        columnWidths = <double>[
          estimatedColumnWidths[_PickerColumnType.month.index]!,
          estimatedColumnWidths[_PickerColumnType.dayOfMonth.index]!,
          estimatedColumnWidths[_PickerColumnType.year.index]!,
        ];
      case DatePickerDateOrder.dmy:
        pickerBuilders = <_ColumnBuilder>[
          _buildDayPicker,
          _buildMonthPicker,
          _buildYearPicker
        ];
        columnWidths = <double>[
          estimatedColumnWidths[_PickerColumnType.dayOfMonth.index]!,
          estimatedColumnWidths[_PickerColumnType.month.index]!,
          estimatedColumnWidths[_PickerColumnType.year.index]!,
        ];
      case DatePickerDateOrder.ymd:
        pickerBuilders = <_ColumnBuilder>[
          _buildYearPicker,
          _buildMonthPicker,
          _buildDayPicker
        ];
        columnWidths = <double>[
          estimatedColumnWidths[_PickerColumnType.year.index]!,
          estimatedColumnWidths[_PickerColumnType.month.index]!,
          estimatedColumnWidths[_PickerColumnType.dayOfMonth.index]!,
        ];
      case DatePickerDateOrder.ydm:
        pickerBuilders = <_ColumnBuilder>[
          _buildYearPicker,
          _buildDayPicker,
          _buildMonthPicker
        ];
        columnWidths = <double>[
          estimatedColumnWidths[_PickerColumnType.year.index]!,
          estimatedColumnWidths[_PickerColumnType.dayOfMonth.index]!,
          estimatedColumnWidths[_PickerColumnType.month.index]!,
        ];
    }

    final List<Widget> pickers = <Widget>[];
    double totalColumnWidths = 4 * _kDatePickerPadSize;

    for (int i = 0; i < columnWidths.length; i++) {
      final double offAxisFraction = (i - 1) * 0.3 * textDirectionFactor;

      EdgeInsets padding = const EdgeInsets.only(right: _kDatePickerPadSize);
      if (textDirectionFactor == -1) {
        padding = const EdgeInsets.only(left: _kDatePickerPadSize);
      }

      Widget selectionOverlay = _centerSelectionOverlay;
      if (i == 0) {
        selectionOverlay = _startSelectionOverlay;
      } else if (i == columnWidths.length - 1) {
        selectionOverlay = _endSelectionOverlay;
      }

      totalColumnWidths += columnWidths[i] + (2 * _kDatePickerPadSize);

      pickers.add(LayoutId(
        id: i,
        child: pickerBuilders[i](
          offAxisFraction,
          (BuildContext context, Widget? child) {
            return Container(
              alignment: i == columnWidths.length - 1
                  ? alignCenterLeft
                  : alignCenterRight,
              padding: i == 0 ? null : padding,
              child: Container(
                alignment: i == 0 ? alignCenterLeft : alignCenterRight,
                width: columnWidths[i] + _kDatePickerPadSize,
                child: child,
              ),
            );
          },
          selectionOverlay,
        ),
      ));
    }

    final double maxPickerWidth =
        totalColumnWidths > _kPickerWidth ? totalColumnWidths : _kPickerWidth;

    return MediaQuery.withNoTextScaling(
      child: DefaultTextStyle.merge(
        style: _kDefaultPickerTextStyle,
        child: CustomMultiChildLayout(
          delegate: _DatePickerLayoutDelegate(
            columnWidths: columnWidths,
            textDirectionFactor: textDirectionFactor,
            maxWidth: maxPickerWidth,
          ),
          children: pickers,
        ),
      ),
    );
  }
}

class _CupertinoDatePickerMonthYearState extends State<CupertinoETDatePicker> {
  _CupertinoDatePickerMonthYearState({
    required this.dateOrder,
  });

  final DatePickerDateOrder? dateOrder;

  late int textDirectionFactor;
  late CupertinoLocalizations localizations;

  // Alignment based on text direction. The variable name is self descriptive,
  // however, when text direction is rtl, alignment is reversed.
  late Alignment alignCenterLeft;
  late Alignment alignCenterRight;

  // The currently selected values of the picker.
  late int selectedYear;
  late int selectedMonth;

  // The controller of the day picker. There are cases where the selected value
  // of the picker is invalid (e.g. February 30th 2018), and this monthController
  // is responsible for jumping to a valid value.
  late FixedExtentScrollController monthController;
  late FixedExtentScrollController yearController;

  bool isMonthPickerScrolling = false;
  bool isYearPickerScrolling = false;

  bool get isScrolling => isMonthPickerScrolling || isYearPickerScrolling;

  // Estimated width of columns.
  Map<int, double> estimatedColumnWidths = <int, double>{};

  @override
  void initState() {
    super.initState();
    selectedMonth = widget.initialDateTime.month;
    selectedYear = widget.initialDateTime.year;
    monthController =
        FixedExtentScrollController(initialItem: selectedMonth - 1);
    yearController = FixedExtentScrollController(initialItem: selectedYear);

    PaintingBinding.instance.systemFonts.addListener(_handleSystemFontsChange);
  }

  void _handleSystemFontsChange() {
    setState(() {
      // System fonts change might cause the text layout width to change.
      _refreshEstimatedColumnWidths();
    });
  }

  @override
  void dispose() {
    monthController.dispose();
    yearController.dispose();

    PaintingBinding.instance.systemFonts
        .removeListener(_handleSystemFontsChange);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    textDirectionFactor =
        Directionality.of(context) == TextDirection.ltr ? 1 : -1;
    localizations = CupertinoLocalizations.of(context);
    GlobalLocale.locale = widget.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;
    alignCenterLeft =
        textDirectionFactor == 1 ? Alignment.centerLeft : Alignment.centerRight;
    alignCenterRight =
        textDirectionFactor == 1 ? Alignment.centerRight : Alignment.centerLeft;

    _refreshEstimatedColumnWidths();
  }

  void _refreshEstimatedColumnWidths() {
    estimatedColumnWidths[_PickerColumnType.month.index] =
        CupertinoETDatePicker._getColumnWidth(
            _PickerColumnType.month, localizations, context, false,
            standaloneMonth: widget.mode == CupertinoDatePickerMode.monthYear);
    estimatedColumnWidths[_PickerColumnType.year.index] =
        CupertinoETDatePicker._getColumnWidth(
            _PickerColumnType.year, localizations, context, false);
  }

  Widget _buildMonthPicker(double offAxisFraction,
      TransitionBuilder itemPositioningBuilder, Widget selectionOverlay) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollStartNotification) {
          isMonthPickerScrolling = true;
        } else if (notification is ScrollEndNotification) {
          isMonthPickerScrolling = false;
          _pickerDidStopScrolling();
        }

        return false;
      },
      child: CupertinoETPicker(
        scrollController: monthController,
        offAxisFraction: offAxisFraction,
        itemExtent: _kItemExtent,
        useMagnifier: _kUseMagnifier,
        magnification: _kMagnification,
        backgroundColor: widget.backgroundColor,
        squeeze: _kSqueeze,
        onSelectedItemChanged: (int index) {
          selectedMonth = index + 1;
          if (_isCurrentDateValid) {
            widget.onDateTimeChanged(ETDateTime(selectedYear, selectedMonth));
          }
        },
        looping: true,
        selectionOverlay: selectionOverlay,
        children: List<Widget>.generate(12, (int index) {
          final int month = index + 1;
          final bool isInvalidMonth =
              (widget.minimumDate?.year == selectedYear &&
                      widget.minimumDate!.month > month) ||
                  (widget.maximumDate?.year == selectedYear &&
                      widget.maximumDate!.month < month);
          final String monthName =
              (widget.mode == CupertinoDatePickerMode.monthYear)
                  ? datePickerStandaloneMonth(month, context)
                  : datePickerMonth(month, context);

          return itemPositioningBuilder(
            context,
            Text(
              monthName,
              style: _themeTextStyle(context, isValid: !isInvalidMonth),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildYearPicker(double offAxisFraction,
      TransitionBuilder itemPositioningBuilder, Widget selectionOverlay) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollStartNotification) {
          isYearPickerScrolling = true;
        } else if (notification is ScrollEndNotification) {
          isYearPickerScrolling = false;
          _pickerDidStopScrolling();
        }

        return false;
      },
      child: CupertinoETPicker.builder(
        scrollController: yearController,
        itemExtent: _kItemExtent,
        offAxisFraction: offAxisFraction,
        useMagnifier: _kUseMagnifier,
        magnification: _kMagnification,
        backgroundColor: widget.backgroundColor,
        onSelectedItemChanged: (int index) {
          selectedYear = index;
          if (_isCurrentDateValid) {
            widget.onDateTimeChanged(ETDateTime(selectedYear, selectedMonth));
          }
        },
        itemBuilder: (BuildContext context, int year) {
          if (year < widget.minimumYear) {
            return null;
          }

          if (widget.maximumYear != null && year > widget.maximumYear!) {
            return null;
          }

          final bool isValidYear = (widget.minimumDate == null ||
                  widget.minimumDate!.year <= year) &&
              (widget.maximumDate == null || widget.maximumDate!.year >= year);

          return itemPositioningBuilder(
            context,
            Text(
              localizations.datePickerYear(year),
              style: _themeTextStyle(context, isValid: isValidYear),
            ),
          );
        },
        selectionOverlay: selectionOverlay,
      ),
    );
  }

  bool get _isCurrentDateValid {
    // The current date selection represents a range [minSelectedData, maxSelectDate].
    final ETDateTime minSelectedDate = ETDateTime(selectedYear, selectedMonth);
    final ETDateTime maxSelectedDate =
        ETDateTime(selectedYear, selectedMonth, widget.initialDateTime.day + 1);

    final bool minCheck = widget.minimumDate?.isBefore(maxSelectedDate) ?? true;
    final bool maxCheck =
        widget.maximumDate?.isBefore(minSelectedDate) ?? false;

    return minCheck && !maxCheck;
  }

  // One or more pickers have just stopped scrolling.
  void _pickerDidStopScrolling() {
    // Call setState to update the greyed out days/months/years, as the currently
    // selected year/month may have changed.
    setState(() {});

    if (isScrolling) {
      return;
    }

    // Whenever scrolling lands on an invalid entry, the picker
    // automatically scrolls to a valid one.
    final ETDateTime minSelectDate = ETDateTime(selectedYear, selectedMonth);
    final ETDateTime maxSelectDate =
        ETDateTime(selectedYear, selectedMonth, widget.initialDateTime.day + 1);

    final bool minCheck = widget.minimumDate?.isBefore(maxSelectDate) ?? true;
    final bool maxCheck = widget.maximumDate?.isBefore(minSelectDate) ?? false;

    if (!minCheck || maxCheck) {
      // We have minCheck === !maxCheck.
      final ETDateTime targetDate =
          minCheck ? widget.maximumDate! : widget.minimumDate!;
      _scrollToDate(targetDate);
      return;
    }
  }

  void _scrollToDate(ETDateTime newDate) {
    SchedulerBinding.instance.addPostFrameCallback((Duration timestamp) {
      if (selectedYear != newDate.year) {
        _animateColumnControllerToItem(yearController, newDate.year);
      }

      if (selectedMonth != newDate.month) {
        _animateColumnControllerToItem(monthController, newDate.month - 1);
      }
    }, debugLabel: 'DatePicker.scrollToDate');
  }

  @override
  Widget build(BuildContext context) {
    List<_ColumnBuilder> pickerBuilders = <_ColumnBuilder>[];
    List<double> columnWidths = <double>[];

    final DatePickerDateOrder datePickerDateOrder =
        dateOrder ?? localizations.datePickerDateOrder;

    switch (datePickerDateOrder) {
      case DatePickerDateOrder.mdy:
      case DatePickerDateOrder.dmy:
        pickerBuilders = <_ColumnBuilder>[_buildMonthPicker, _buildYearPicker];
        columnWidths = <double>[
          estimatedColumnWidths[_PickerColumnType.month.index]!,
          estimatedColumnWidths[_PickerColumnType.year.index]!,
        ];
      case DatePickerDateOrder.ymd:
      case DatePickerDateOrder.ydm:
        pickerBuilders = <_ColumnBuilder>[_buildYearPicker, _buildMonthPicker];
        columnWidths = <double>[
          estimatedColumnWidths[_PickerColumnType.year.index]!,
          estimatedColumnWidths[_PickerColumnType.month.index]!,
        ];
    }

    final List<Widget> pickers = <Widget>[];
    double totalColumnWidths = 3 * _kDatePickerPadSize;

    for (int i = 0; i < columnWidths.length; i++) {
      late final double offAxisFraction;
      switch (i) {
        case 0:
          offAxisFraction = -0.3 * textDirectionFactor;
        default:
          offAxisFraction = 0.5 * textDirectionFactor;
      }

      EdgeInsets padding = const EdgeInsets.only(right: _kDatePickerPadSize);
      if (textDirectionFactor == -1) {
        padding = const EdgeInsets.only(left: _kDatePickerPadSize);
      }

      Widget selectionOverlay = _centerSelectionOverlay;
      if (i == 0) {
        selectionOverlay = _startSelectionOverlay;
      } else if (i == columnWidths.length - 1) {
        selectionOverlay = _endSelectionOverlay;
      }

      totalColumnWidths += columnWidths[i] + (2 * _kDatePickerPadSize);

      pickers.add(LayoutId(
        id: i,
        child: pickerBuilders[i](
          offAxisFraction,
          (BuildContext context, Widget? child) {
            return Container(
              alignment: i == columnWidths.length - 1
                  ? alignCenterLeft
                  : alignCenterRight,
              padding: i == 0 ? null : padding,
              child: Container(
                alignment: i == 0 ? alignCenterLeft : alignCenterRight,
                width: columnWidths[i] + _kDatePickerPadSize,
                child: child,
              ),
            );
          },
          selectionOverlay,
        ),
      ));
    }

    final double maxPickerWidth =
        totalColumnWidths > _kPickerWidth ? totalColumnWidths : _kPickerWidth;

    return MediaQuery.withNoTextScaling(
      child: DefaultTextStyle.merge(
        style: _kDefaultPickerTextStyle,
        child: CustomMultiChildLayout(
          delegate: _DatePickerLayoutDelegate(
            columnWidths: columnWidths,
            textDirectionFactor: textDirectionFactor,
            maxWidth: maxPickerWidth,
          ),
          children: pickers,
        ),
      ),
    );
  }
}

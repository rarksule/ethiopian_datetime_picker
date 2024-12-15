// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import "dart:math" as math;

import "package:ethiopian_datetime/ethiopian_datetime.dart";
import "package:ethiopian_datetime_picker/src/calander_common.dart";
import "package:ethiopian_datetime_picker/src/etdate_picker_header.dart";
import "package:ethiopian_datetime_picker/src/string_text.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "package:flutter/services.dart";

const Duration _monthScrollDuration = Duration(milliseconds: 200);

const double _dayPickerRowHeight = 42;
const int _maxDayPickerRowCount = 6; // A 31 day month that starts on Saturday.
// One extra row for the day-of-week header.
const double _maxDayPickerHeight =
    _dayPickerRowHeight * (_maxDayPickerRowCount + 1);
const double _monthPickerHorizontalPadding = 8;

const int _yearPickerColumnCount = 3;
const double _yearPickerPadding = 16;
const double _yearPickerRowHeight = 52;
const double _yearPickerRowSpacing = 8;

const double _subHeaderHeight = 52;
const double _monthNavButtonsWidth = 108;

/// Displays a grid of days for a given month and allows the user to select a
/// date.
///
/// Days are arranged in a rectangular grid with one column for each day of the
/// week. Controls are provided to change the year and month that the grid is
/// showing.
///
/// The calendar picker widget is rarely used directly. Instead, consider using
/// [showDatePicker], which will create a dialog that uses this as well as
/// provides a text entry option.
///
/// See also:
///
///  * [showDatePicker], which creates a Dialog that contains a
///    [ETCalendarDatePicker] and provides an optional compact view where the
///    user can enter a date as a line of text.
///  * [showTimePicker], which shows a dialog that contains a Material Design
///    time picker.
///
class ETCalendarDatePicker extends StatefulWidget {
  /// Creates a calendar date picker.
  ///
  /// It will display a grid of days for the [initialDate]'s month, or, if that
  /// is null, the [currentDate]'s month. The day indicated by [initialDate] will
  /// be selected if it is not null.
  ///
  /// The optional [onDisplayedMonthChanged] callback can be used to track
  /// the currently displayed month.
  ///
  /// The user interface provides a way to change the year of the month being
  /// displayed. By default it will show the day grid, but this can be changed
  /// to start in the year selection interface with [initialCalendarMode] set
  /// to [DatePickerMode.year].
  ///
  /// The [lastDate] must be after or equal to [firstDate].
  ///
  /// The [initialDate], if provided, must be between [firstDate] and [lastDate]
  /// or equal to one of them.
  ///
  /// The [currentDate] represents the current day (i.e. today). This
  /// date will be highlighted in the day grid. If null, the date of
  /// `ETDateTime.now()` will be used.
  ///
  /// If [selectableDayPredicate] and [initialDate] are both non-null,
  /// [selectableDayPredicate] must return `true` for the [initialDate].
  ETCalendarDatePicker({
    required ETDateTime? initialDate,
    required ETDateTime firstDate,
    required ETDateTime lastDate,
    required this.onDateChanged,
    super.key,
    ETDateTime? currentDate,
    this.onDisplayedMonthChanged,
    this.initialCalendarMode = DatePickerMode.day,
    this.selectableDayPredicate,
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
      this.initialDate == null || !this.initialDate!.isBefore(this.firstDate),
      "initialDate ${this.initialDate} must be on or after firstDate ${this.firstDate}.",
    );
    assert(
      this.initialDate == null || !this.initialDate!.isAfter(this.lastDate),
      "initialDate ${this.initialDate} must be on or before lastDate ${this.lastDate}.",
    );
    assert(
      selectableDayPredicate == null ||
          this.initialDate == null ||
          selectableDayPredicate!(this.initialDate!),
      "Provided initialDate ${this.initialDate} must satisfy provided selectableDayPredicate.",
    );
  }

  /// The initially selected [ETDateTime] that the picker should display.
  ///
  /// Subsequently changing this has no effect. To change the selected date,
  /// change the [key] to create a new instance of the [ETCalendarDatePicker], and
  /// provide that widget the new [initialDate]. This will reset the widget's
  /// interactive state.
  final ETDateTime? initialDate;

  /// The earliest allowable [ETDateTime] that the user can select.
  final ETDateTime firstDate;

  /// The latest allowable [ETDateTime] that the user can select.
  final ETDateTime lastDate;

  /// The [ETDateTime] representing today. It will be highlighted in the day grid.
  final ETDateTime currentDate;

  /// Called when the user selects a date in the picker.
  final ValueChanged<ETDateTime> onDateChanged;

  /// Called when the user navigates to a new month/year in the picker.
  final ValueChanged<ETDateTime>? onDisplayedMonthChanged;

  /// The initial display of the calendar picker.
  ///
  /// Subsequently changing this has no effect. To change the calendar mode,
  /// change the [key] to create a new instance of the [ETCalendarDatePicker], and
  /// provide that widget a new [initialCalendarMode]. This will reset the
  /// widget's interactive state.
  final DatePickerMode initialCalendarMode;

  /// Function to provide full control over which dates in the calendar can be selected.
  final SelectableDayPredicate? selectableDayPredicate;

  @override
  State<ETCalendarDatePicker> createState() => _ETCalendarDatePickerState();
}

class _ETCalendarDatePickerState extends State<ETCalendarDatePicker> {
  bool _announcedInitialDate = false;
  late DatePickerMode _mode;
  late ETDateTime _currentDisplayedMonthDate;
  ETDateTime? _selectedDate;
  final GlobalKey _monthPickerKey = GlobalKey();
  final GlobalKey _yearPickerKey = GlobalKey();
  late Localized localized;
  late TextDirection _textDirection;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialCalendarMode;
    final currentDisplayedDate = widget.initialDate ?? widget.currentDate;
    _currentDisplayedMonthDate =
        ETDateTime(currentDisplayedDate.year, currentDisplayedDate.month);
    if (widget.initialDate != null) {
      _selectedDate = widget.initialDate;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    assert(debugCheckHasMaterial(context));
    assert(debugCheckHasMaterialLocalizations(context));
    assert(debugCheckHasDirectionality(context));
    localized = Localized(context);
    _textDirection = Directionality.of(context);
    if (!_announcedInitialDate && widget.initialDate != null) {
      assert(_selectedDate != null);
      _announcedInitialDate = true;
      final isToday = ETDateUtils.isSameDay(widget.currentDate, _selectedDate);
      final semanticLabelSuffix =
          isToday ? ", ${localized.currentDateLabel}" : "";
      SemanticsService.announce(
        "${localized.formatFullDate(_selectedDate!)}$semanticLabelSuffix",
        _textDirection,
      );
    }
  }

  void _vibrate() {
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        HapticFeedback.vibrate();
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        break;
    }
  }

  void _handleModeChanged(DatePickerMode mode) {
    _vibrate();
    setState(() {
      _mode = mode;
      if (_selectedDate != null) {
        if (_mode == DatePickerMode.day) {
          SemanticsService.announce(
            localized.formatMonthYear(_selectedDate!),
            _textDirection,
          );
        } else {
          SemanticsService.announce(
            localized.formatYear(_selectedDate!),
            _textDirection,
          );
        }
      }
    });
  }

  void _handleMonthChanged(ETDateTime date) {
    setState(() {
      if (_currentDisplayedMonthDate.year != date.year ||
          _currentDisplayedMonthDate.month != date.month) {
        _currentDisplayedMonthDate = ETDateTime(date.year, date.month);
        widget.onDisplayedMonthChanged?.call(_currentDisplayedMonthDate);
      }
    });
  }

  void _handleYearChanged(ETDateTime value) {
    _vibrate();

    final daysInMonth = ETDateUtils.getDaysInMonth(value.year, value.month);
    final int preferredDay = math.min(_selectedDate?.day ?? 1, daysInMonth);
    var newYear = value;
    newYear = value.copyWith(day: preferredDay).asETDateTime;

    if (value.isBefore(widget.firstDate)) {
      newYear = widget.firstDate;
    } else if (value.isAfter(widget.lastDate)) {
      newYear = widget.lastDate;
    }

    setState(() {
      _mode = DatePickerMode.day;
      _handleMonthChanged(newYear);

      if (_isSelectable(newYear)) {
        _selectedDate = newYear;
        widget.onDateChanged(_selectedDate!);
      }
    });
  }

  void _handleDayChanged(ETDateTime value) {
    _vibrate();
    setState(() {
      _selectedDate = value;
      widget.onDateChanged(_selectedDate!);
    });
  }

  bool _isSelectable(ETDateTime date) =>
      widget.selectableDayPredicate == null ||
      widget.selectableDayPredicate!.call(date);

  Widget _buildPicker() {
    switch (_mode) {
      case DatePickerMode.day:
        return _MonthPicker(
          key: _monthPickerKey,
          initialMonth: _currentDisplayedMonthDate,
          currentDate: widget.currentDate,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          selectedDate: _selectedDate,
          onChanged: _handleDayChanged,
          onDisplayedMonthChanged: _handleMonthChanged,
          selectableDayPredicate: widget.selectableDayPredicate,
        );
      case DatePickerMode.year:
        return Padding(
          padding: const EdgeInsets.only(top: _subHeaderHeight),
          child: YearPicker(
            key: _yearPickerKey,
            currentDate: widget.currentDate,
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
            selectedDate: _currentDisplayedMonthDate,
            onChanged: _handleYearChanged,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    assert(debugCheckHasMaterialLocalizations(context));
    assert(debugCheckHasDirectionality(context));
    return Stack(
      children: <Widget>[
        SizedBox(
          height: _subHeaderHeight + _maxDayPickerHeight,
          child: _buildPicker(),
        ),
        // Put the mode toggle button on top so that it won't be covered up by the _MonthPicker
        _DatePickerModeToggleButton(
          mode: _mode,
          title: localized.formatMonthYear(_currentDisplayedMonthDate),
          onTitlePressed: () {
            // Toggle the day/year mode.
            _handleModeChanged(
              _mode == DatePickerMode.day
                  ? DatePickerMode.year
                  : DatePickerMode.day,
            );
          },
        ),
      ],
    );
  }
}

/// A button that used to toggle the [DatePickerMode] for a date picker.
///
/// This appears above the calendar grid and allows the user to toggle the
/// [DatePickerMode] to display either the calendar view or the year list.
class _DatePickerModeToggleButton extends StatefulWidget {
  const _DatePickerModeToggleButton({
    required this.mode,
    required this.title,
    required this.onTitlePressed,
  });

  /// The current display of the calendar picker.
  final DatePickerMode mode;

  /// The text that displays the current month/year being viewed.
  final String title;

  /// The callback when the title is pressed.
  final VoidCallback onTitlePressed;

  @override
  _DatePickerModeToggleButtonState createState() =>
      _DatePickerModeToggleButtonState();
}

class _DatePickerModeToggleButtonState
    extends State<_DatePickerModeToggleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: widget.mode == DatePickerMode.year ? 0.5 : 0,
      upperBound: 0.5,
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(_DatePickerModeToggleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode == widget.mode) {
      return;
    }

    if (widget.mode == DatePickerMode.year) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final controlColor = colorScheme.onSurface.withOpacity(0.60);

    return Container(
      padding: const EdgeInsetsDirectional.only(start: 16, end: 4),
      height: _subHeaderHeight,
      child: Row(
        children: <Widget>[
          Flexible(
            child: Semantics(
              label: MaterialLocalizations.of(context).selectYearSemanticsLabel,
              excludeSemantics: true,
              button: true,
              child: SizedBox(
                height: _subHeaderHeight,
                child: InkWell(
                  onTap: widget.onTitlePressed,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            widget.title,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleSmall?.copyWith(
                              color: controlColor,
                            ),
                          ),
                        ),
                        RotationTransition(
                          turns: _controller,
                          child: Icon(
                            Icons.arrow_drop_down,
                            color: controlColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (widget.mode == DatePickerMode.day)
            // Give space for the prev/next month buttons that are underneath this row
            const SizedBox(width: _monthNavButtonsWidth),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _MonthPicker extends StatefulWidget {
  /// Creates a month picker.
  _MonthPicker({
    required this.initialMonth,
    required this.currentDate,
    required this.firstDate,
    required this.lastDate,
    required this.selectedDate,
    required this.onChanged,
    required this.onDisplayedMonthChanged,
    super.key,
    this.selectableDayPredicate,
  })  : assert(!firstDate.isAfter(lastDate)),
        assert(selectedDate == null || !selectedDate.isBefore(firstDate)),
        assert(selectedDate == null || !selectedDate.isAfter(lastDate));

  /// The initial month to display.
  ///
  /// Subsequently changing this has no effect. To change the selected month,
  /// change the [key] to create a new instance of the [_MonthPicker], and
  /// provide that widget the new [initialMonth]. This will reset the widget's
  /// interactive state.
  final ETDateTime initialMonth;

  /// The current date.
  ///
  /// This date is subtly highlighted in the picker.
  final ETDateTime currentDate;

  /// The earliest date the user is permitted to pick.
  ///
  /// This date must be on or before the [lastDate].
  final ETDateTime firstDate;

  /// The latest date the user is permitted to pick.
  ///
  /// This date must be on or after the [firstDate].
  final ETDateTime lastDate;

  /// The currently selected date.
  ///
  /// This date is highlighted in the picker.
  final ETDateTime? selectedDate;

  /// Called when the user picks a day.
  final ValueChanged<ETDateTime> onChanged;

  /// Called when the user navigates to a new month.
  final ValueChanged<ETDateTime> onDisplayedMonthChanged;

  /// Optional user supplied predicate function to customize selectable days.
  final SelectableDayPredicate? selectableDayPredicate;

  @override
  _MonthPickerState createState() => _MonthPickerState();
}

class _MonthPickerState extends State<_MonthPicker> {
  final GlobalKey _pageViewKey = GlobalKey();
  late ETDateTime _currentMonth;
  late PageController _pageController;
  late TextDirection _textDirection;
  Map<ShortcutActivator, Intent>? _shortcutMap;
  Map<Type, Action<Intent>>? _actionMap;
  late FocusNode _dayGridFocus;
  ETDateTime? _focusedDay;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.initialMonth;
    _pageController = PageController(
      initialPage: ETDateUtils.monthDelta(widget.firstDate, _currentMonth),
    );
    _shortcutMap = const <ShortcutActivator, Intent>{
      SingleActivator(LogicalKeyboardKey.arrowLeft):
          DirectionalFocusIntent(TraversalDirection.left),
      SingleActivator(LogicalKeyboardKey.arrowRight):
          DirectionalFocusIntent(TraversalDirection.right),
      SingleActivator(LogicalKeyboardKey.arrowDown):
          DirectionalFocusIntent(TraversalDirection.down),
      SingleActivator(LogicalKeyboardKey.arrowUp):
          DirectionalFocusIntent(TraversalDirection.up),
    };
    _actionMap = <Type, Action<Intent>>{
      NextFocusIntent:
          CallbackAction<NextFocusIntent>(onInvoke: _handleGridNextFocus),
      PreviousFocusIntent: CallbackAction<PreviousFocusIntent>(
        onInvoke: _handleGridPreviousFocus,
      ),
      DirectionalFocusIntent: CallbackAction<DirectionalFocusIntent>(
        onInvoke: _handleDirectionFocus,
      ),
    };
    _dayGridFocus = FocusNode(debugLabel: "Day Grid");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _textDirection = Directionality.of(context);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _dayGridFocus.dispose();
    super.dispose();
  }

  void _handleDateSelected(ETDateTime selectedDate) {
    _focusedDay = selectedDate;
    widget.onChanged(selectedDate);
  }

  void _handleMonthPageChanged(int monthPage) {
    final localized = Localized(context);
    setState(() {
      final monthDate =
          ETDateUtils.addMonthsToMonthDate(widget.firstDate, monthPage);
      if (!ETDateUtils.isSameMonth(_currentMonth, monthDate)) {
        _currentMonth = ETDateTime(monthDate.year, monthDate.month);
        widget.onDisplayedMonthChanged(_currentMonth);
        if (_focusedDay != null &&
            !ETDateUtils.isSameMonth(_focusedDay, _currentMonth)) {
          // We have navigated to a new month with the grid focused, but the
          // focused day is not in this month. Choose a new one trying to keep
          // the same day of the month.
          _focusedDay = _focusableDayForMonth(_currentMonth, _focusedDay!.day);
        }
        SemanticsService.announce(
          localized.formatMonthYear(_currentMonth),
          _textDirection,
        );
      }
    });
  }

  /// Returns a focusable date for the given month.
  ///
  /// If the preferredDay is available in the month it will be returned,
  /// otherwise the first selectable day in the month will be returned. If
  /// no dates are selectable in the month, then it will return null.
  ETDateTime? _focusableDayForMonth(ETDateTime month, int preferredDay) {
    final daysInMonth = ETDateUtils.getDaysInMonth(month.year, month.month);

    // Can we use the preferred day in this month?
    if (preferredDay <= daysInMonth) {
      final newFocus = ETDateTime(month.year, month.month, preferredDay);
      if (_isSelectable(newFocus)) {
        return newFocus;
      }
    }

    // Start at the 1st and take the first selectable date.
    for (var day = 1; day <= daysInMonth; day++) {
      final newFocus = ETDateTime(month.year, month.month, day);
      if (_isSelectable(newFocus)) {
        return newFocus;
      }
    }
    return null;
  }

  /// Navigate to the next month.
  void _handleNextMonth() {
    if (!_isDisplayingLastMonth) {
      _pageController.nextPage(
        duration: _monthScrollDuration,
        curve: Curves.ease,
      );
    }
  }

  /// Navigate to the previous month.
  void _handlePreviousMonth() {
    if (!_isDisplayingFirstMonth) {
      _pageController.previousPage(
        duration: _monthScrollDuration,
        curve: Curves.ease,
      );
    }
  }

  /// Navigate to the given month.
  void _showMonth(ETDateTime month, {bool jump = false}) {
    final monthPage = ETDateUtils.monthDelta(widget.firstDate, month);
    if (jump) {
      _pageController.jumpToPage(monthPage);
    } else {
      _pageController.animateToPage(
        monthPage,
        duration: _monthScrollDuration,
        curve: Curves.ease,
      );
    }
  }

  /// True if the earliest allowable month is displayed.
  bool get _isDisplayingFirstMonth => !_currentMonth.isAfter(
        ETDateTime(widget.firstDate.year, widget.firstDate.month),
      );

  /// True if the latest allowable month is displayed.
  bool get _isDisplayingLastMonth => !_currentMonth.isBefore(
        ETDateTime(widget.lastDate.year, widget.lastDate.month),
      );

  /// Handler for when the overall day grid obtains or loses focus.
  void _handleGridFocusChange(bool focused) {
    setState(() {
      if (focused && _focusedDay == null) {
        if (ETDateUtils.isSameMonth(widget.selectedDate, _currentMonth)) {
          _focusedDay = widget.selectedDate;
        } else if (ETDateUtils.isSameMonth(widget.currentDate, _currentMonth)) {
          _focusedDay =
              _focusableDayForMonth(_currentMonth, widget.currentDate.day);
        } else {
          _focusedDay = _focusableDayForMonth(_currentMonth, 1);
        }
      }
    });
  }

  /// Move focus to the next element after the day grid.
  void _handleGridNextFocus(NextFocusIntent intent) {
    _dayGridFocus
      ..requestFocus()
      ..nextFocus();
  }

  /// Move focus to the previous element before the day grid.
  void _handleGridPreviousFocus(PreviousFocusIntent intent) {
    _dayGridFocus
      ..requestFocus()
      ..previousFocus();
  }

  /// Move the internal focus date in the direction of the given intent.
  ///
  /// This will attempt to move the focused day to the next selectable day in
  /// the given direction. If the new date is not in the current month, then
  /// the page view will be scrolled to show the new date's month.
  ///
  /// For horizontal directions, it will move forward or backward a day (depending
  /// on the current [TextDirection]). For vertical directions it will move up and
  /// down a week at a time.
  void _handleDirectionFocus(DirectionalFocusIntent intent) {
    assert(_focusedDay != null);
    setState(() {
      final nextDate = _nextDateInDirection(_focusedDay!, intent.direction);
      if (nextDate != null) {
        _focusedDay = nextDate;
        if (!ETDateUtils.isSameMonth(_focusedDay, _currentMonth)) {
          _showMonth(_focusedDay!);
        }
      }
    });
  }

  static const Map<TraversalDirection, int> _directionOffset =
      <TraversalDirection, int>{
    TraversalDirection.up: -ETDateTime.daysPerWeek,
    TraversalDirection.right: 1,
    TraversalDirection.down: ETDateTime.daysPerWeek,
    TraversalDirection.left: -1,
  };

  int _dayDirectionOffset(
    TraversalDirection traversalDirection,
    TextDirection textDirection,
  ) {
    var traversalDirec = traversalDirection;
    // Swap left and right if the text direction if RTL
    if (textDirection == TextDirection.rtl) {
      if (traversalDirection == TraversalDirection.left) {
        traversalDirec = TraversalDirection.right;
      } else if (traversalDirection == TraversalDirection.right) {
        traversalDirec = TraversalDirection.left;
      }
    }
    return _directionOffset[traversalDirec]!;
  }

  ETDateTime? _nextDateInDirection(
    ETDateTime date,
    TraversalDirection direction,
  ) {
    final textDirection = Directionality.of(context);
    var nextDate = ETDateUtils.addDaysToDate(
      date,
      _dayDirectionOffset(direction, textDirection),
    );
    while (!nextDate.isBefore(widget.firstDate) &&
        !nextDate.isAfter(widget.lastDate)) {
      if (_isSelectable(nextDate)) {
        return nextDate;
      }
      nextDate = ETDateUtils.addDaysToDate(
        nextDate,
        _dayDirectionOffset(direction, textDirection),
      );
    }
    return null;
  }

  bool _isSelectable(ETDateTime date) =>
      widget.selectableDayPredicate == null ||
      widget.selectableDayPredicate!.call(date);

  Widget _buildItems(BuildContext context, int index) {
    final month = ETDateUtils.addMonthsToMonthDate(widget.firstDate, index);
    return _DayPicker(
      key: ValueKey<ETDateTime>(month),
      selectedDate: widget.selectedDate,
      currentDate: widget.currentDate,
      onChanged: _handleDateSelected,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      displayedMonth: month,
      selectableDayPredicate: widget.selectableDayPredicate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controlColor =
        Theme.of(context).colorScheme.onSurface.withOpacity(0.60);
    final localized = Localized(context);
    return Semantics(
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsetsDirectional.only(start: 16, end: 4),
            height: _subHeaderHeight,
            child: Row(
              children: <Widget>[
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  color: controlColor,
                  tooltip: _isDisplayingFirstMonth
                      ? null
                      : localized.previousMonthTooltip,
                  onPressed:
                      _isDisplayingFirstMonth ? null : _handlePreviousMonth,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  color: controlColor,
                  tooltip: _isDisplayingLastMonth
                      ? null
                      : localized.nextMonthTooltip,
                  onPressed: _isDisplayingLastMonth ? null : _handleNextMonth,
                ),
              ],
            ),
          ),
          Expanded(
            child: FocusableActionDetector(
              shortcuts: _shortcutMap,
              actions: _actionMap,
              focusNode: _dayGridFocus,
              onFocusChange: _handleGridFocusChange,
              child: ETFocusedDate(
                date: _dayGridFocus.hasFocus ? _focusedDay : null,
                child: PageView.builder(
                  key: _pageViewKey,
                  controller: _pageController,
                  itemBuilder: _buildItems,
                  itemCount: ETDateUtils.monthDelta(
                        widget.firstDate,
                        widget.lastDate,
                      ) +
                      1,
                  onPageChanged: _handleMonthPageChanged,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Displays the days of a given month and allows choosing a day.
///
/// The days are arranged in a rectangular grid with one column for each day of
/// the week.
class _DayPicker extends StatefulWidget {
  /// Creates a day picker.
  _DayPicker({
    required this.currentDate,
    required this.displayedMonth,
    required this.firstDate,
    required this.lastDate,
    required this.selectedDate,
    required this.onChanged,
    super.key,
    this.selectableDayPredicate,
  })  : assert(!firstDate.isAfter(lastDate)),
        assert(selectedDate == null || !selectedDate.isBefore(firstDate)),
        assert(selectedDate == null || !selectedDate.isAfter(lastDate));

  /// The currently selected date.
  ///
  /// This date is highlighted in the picker.
  final ETDateTime? selectedDate;

  /// The current date at the time the picker is displayed.
  final ETDateTime currentDate;

  /// Called when the user picks a day.
  final ValueChanged<ETDateTime> onChanged;

  /// The earliest date the user is permitted to pick.
  ///
  /// This date must be on or before the [lastDate].
  final ETDateTime firstDate;

  /// The latest date the user is permitted to pick.
  ///
  /// This date must be on or after the [firstDate].
  final ETDateTime lastDate;

  /// The month whose days are displayed by this picker.
  final ETDateTime displayedMonth;

  /// Optional user supplied predicate function to customize selectable days.
  final SelectableDayPredicate? selectableDayPredicate;

  @override
  _DayPickerState createState() => _DayPickerState();
}

class _DayPickerState extends State<_DayPicker> {
  /// List of [FocusNode]s, one for each day of the month.
  late List<FocusNode> _dayFocusNodes;

  @override
  void initState() {
    super.initState();
    final daysInMonth = ETDateUtils.getDaysInMonth(
      widget.displayedMonth.year,
      widget.displayedMonth.month,
    );
    _dayFocusNodes = List<FocusNode>.generate(
      daysInMonth,
      (index) => FocusNode(skipTraversal: true, debugLabel: "Day ${index + 1}"),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check to see if the focused date is in this month, if so focus it.
    final focusedDate = ETFocusedDate.maybeOf(context)?.date;
    if (focusedDate != null &&
        ETDateUtils.isSameMonth(widget.displayedMonth, focusedDate)) {
      _dayFocusNodes[focusedDate.day - 1].requestFocus();
    }
  }

  @override
  void dispose() {
    for (final node in _dayFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final datePickerTheme = DatePickerTheme.of(context);
    final defaults = DatePickerTheme.defaults(context);
    final weekdayStyle = datePickerTheme.weekdayStyle ?? defaults.weekdayStyle;

    final year = widget.displayedMonth.year;
    final month = widget.displayedMonth.month;

    final daysInMonth = ETDateUtils.getDaysInMonth(year, month);
    final dayOffset =
        ETDateTime(year, month).weekday - (globalLocale == null ? 0 : 1);
    final localized = Localized(context);
    final dayItems = getDayHeaders(weekdayStyle, localized);
    // 1-based day of month, e.g. 1-31 for January, and 1-29 for February on
    // a leap year.
    var day = -dayOffset;
    while (day < daysInMonth) {
      day++;
      if (day < 1) {
        dayItems.add(Container());
      } else {
        final dayToBuild = ETDateTime(year, month, day);
        final isDisabled = dayToBuild.isAfter(widget.lastDate) ||
            dayToBuild.isBefore(widget.firstDate) ||
            (widget.selectableDayPredicate != null &&
                !widget.selectableDayPredicate!(dayToBuild));
        final isSelectedDay =
            ETDateUtils.isSameDay(widget.selectedDate, dayToBuild);
        final isToday = ETDateUtils.isSameDay(widget.currentDate, dayToBuild);

        dayItems.add(
          _Day(
            dayToBuild,
            key: ValueKey<ETDateTime>(dayToBuild),
            isDisabled: isDisabled,
            isSelectedDay: isSelectedDay,
            isToday: isToday,
            onChanged: widget.onChanged,
            focusNode: _dayFocusNodes[day - 1],
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _monthPickerHorizontalPadding,
      ),
      child: GridView.custom(
        physics: const ClampingScrollPhysics(),
        gridDelegate: _dayPickerGridDelegate,
        childrenDelegate: SliverChildListDelegate(
          dayItems,
          addRepaintBoundaries: false,
        ),
      ),
    );
  }
}

class _Day extends StatefulWidget {
  const _Day(
    this.day, {
    required this.isDisabled,
    required this.isSelectedDay,
    required this.isToday,
    required this.onChanged,
    required this.focusNode,
    super.key,
  });

  final ETDateTime day;
  final bool isDisabled;
  final bool isSelectedDay;
  final bool isToday;
  final ValueChanged<ETDateTime> onChanged;
  final FocusNode? focusNode;

  @override
  State<_Day> createState() => _DayState();
}

class _DayState extends State<_Day> {
  final MaterialStatesController _statesController = MaterialStatesController();

  @override
  Widget build(BuildContext context) {
    final defaults = DatePickerTheme.defaults(context);
    final datePickerTheme = DatePickerTheme.of(context);
    final dayStyle = datePickerTheme.dayStyle ?? defaults.dayStyle;
    T? effectiveValue<T>(T? Function(DatePickerThemeData? theme) getProperty) =>
        getProperty(datePickerTheme) ?? getProperty(defaults);

    T? resolve<T>(
      MaterialStateProperty<T>? Function(DatePickerThemeData? theme)
          getProperty,
      Set<MaterialState> states,
    ) =>
        effectiveValue(
          (theme) => getProperty(theme)?.resolve(states),
        );

    final localized = Localized(context);
    final semanticLabelSuffix =
        widget.isToday ? ", ${localized.currentDateLabel}" : "";

    final states = <MaterialState>{
      if (widget.isDisabled) MaterialState.disabled,
      if (widget.isSelectedDay) MaterialState.selected,
    };

    _statesController.value = states;

    final dayForegroundColor = resolve<Color?>(
      (theme) => widget.isToday
          ? theme?.todayForegroundColor
          : theme?.dayForegroundColor,
      states,
    );
    final dayBackgroundColor = resolve<Color?>(
      (theme) => widget.isToday
          ? theme?.todayBackgroundColor
          : theme?.dayBackgroundColor,
      states,
    );
    final dayOverlayColor = MaterialStateProperty.resolveWith<Color?>(
      (states) => effectiveValue(
        (theme) => theme?.dayOverlayColor?.resolve(states),
      ),
    );
    final decoration = widget.isToday
        ? BoxDecoration(
            color: dayBackgroundColor,
            border: Border.fromBorderSide(
              (datePickerTheme.todayBorder ?? defaults.todayBorder!)
                  .copyWith(color: dayForegroundColor),
            ),
            shape: BoxShape.circle,
          )
        : BoxDecoration(
            color: dayBackgroundColor,
            shape: BoxShape.circle,
          );
    // ignore: use_decorated_box
    Widget dayWidget = Container(
      decoration: decoration,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Text(
              localized.formatDecimal(widget.day.convertToGregorian().day),
              style: const TextStyle(fontSize: 8)
                  .copyWith(color: dayForegroundColor),
            ),
          ),
          Center(
            child: Text(
              localized.formatDecimal(widget.day.day),
              style: dayStyle?.apply(color: dayForegroundColor),
            ),
          ),
        ],
      ),
    );

    if (widget.isDisabled) {
      dayWidget = ExcludeSemantics(
        child: dayWidget,
      );
    } else {
      dayWidget = InkResponse(
        focusNode: widget.focusNode,
        onTap: () => widget.onChanged(widget.day),
        radius: _dayPickerRowHeight / 2 + 4,
        statesController: _statesController,
        overlayColor: dayOverlayColor,
        child: Semantics(
          // We want the day of month to be spoken first irrespective of the
          // locale-specific preferences or TextDirection. This is because
          // an accessibility user is more likely to be interested in the
          // day of month before the rest of the date, as they are looking
          // for the day of month. To do that we prepend day of month to the
          // formatted full date.
          label:
              "${localized.formatDecimal(widget.day.day)}, ${localized.formatFullDate(widget.day)}$semanticLabelSuffix",
          // Set button to true to make the date selectable.
          button: true,
          selected: widget.isSelectedDay,
          excludeSemantics: true,
          child: dayWidget,
        ),
      );
    }

    return dayWidget;
  }

  @override
  void dispose() {
    _statesController.dispose();
    super.dispose();
  }
}

class _DayPickerGridDelegate extends SliverGridDelegate {
  const _DayPickerGridDelegate();

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    const columnCount = ETDateTime.daysPerWeek;
    final tileWidth = constraints.crossAxisExtent / columnCount;
    final double tileHeight = math.min(
      _dayPickerRowHeight,
      constraints.viewportMainAxisExtent / (_maxDayPickerRowCount + 1),
    );
    return SliverGridRegularTileLayout(
      childCrossAxisExtent: tileWidth,
      childMainAxisExtent: tileHeight,
      crossAxisCount: columnCount,
      crossAxisStride: tileWidth,
      mainAxisStride: tileHeight,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(_DayPickerGridDelegate oldDelegate) => false;
}

const _DayPickerGridDelegate _dayPickerGridDelegate = _DayPickerGridDelegate();

/// A scrollable grid of years to allow picking a year.
///
/// The year picker widget is rarely used directly. Instead, consider using
/// [ETCalendarDatePicker], or [showDatePicker] which create full date pickers.
///
/// See also:
///
///  * [ETCalendarDatePicker], which provides a Material Design date picker
///    interface.
///
///  * [showDatePicker], which shows a dialog containing a Material Design
///    date picker.
///
class YearPicker extends StatefulWidget {
  /// Creates a year picker.
  ///
  /// The [lastDate] must be after the [firstDate].
  YearPicker({
    required this.firstDate,
    required this.lastDate,
    required this.selectedDate,
    required this.onChanged,
    super.key,
    ETDateTime? currentDate,
    @Deprecated(
        "This parameter has no effect and can be removed. Previously it controlled "
        'the month that was used in "onChanged" when a new year was selected, but '
        'now that role is filled by "selectedDate" instead. '
        "This feature was deprecated after v3.13.0-0.3.pre.")
    ETDateTime? initialDate,
    this.dragStartBehavior = DragStartBehavior.start,
  })  : assert(!firstDate.isAfter(lastDate)),
        currentDate = ETDateUtils.dateOnly(currentDate ?? ETDateTime.now());

  /// The current date.
  ///
  /// This date is subtly highlighted in the picker.
  final ETDateTime currentDate;

  /// The earliest date the user is permitted to pick.
  final ETDateTime firstDate;

  /// The latest date the user is permitted to pick.
  final ETDateTime lastDate;

  /// The currently selected date.
  ///
  /// This date is highlighted in the picker.
  final ETDateTime? selectedDate;

  /// Called when the user picks a year.
  final ValueChanged<ETDateTime> onChanged;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  @override
  State<YearPicker> createState() => _YearPickerState();
}

class _YearPickerState extends State<YearPicker> {
  ScrollController? _scrollController;
  final MaterialStatesController _statesController = MaterialStatesController();

  // The approximate number of years necessary to fill the available space.
  static const int minYears = 18;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset:
          _scrollOffsetForYear(widget.selectedDate ?? widget.firstDate),
    );
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    _statesController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(YearPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate &&
        widget.selectedDate != null) {
      _scrollController!.jumpTo(_scrollOffsetForYear(widget.selectedDate!));
    }
  }

  double _scrollOffsetForYear(ETDateTime date) {
    final initialYearIndex = date.year - widget.firstDate.year;
    final initialYearRow = initialYearIndex ~/ _yearPickerColumnCount;
    // Move the offset down by 2 rows to approximately center it.
    final centeredYearRow = initialYearRow - 2;
    return _itemCount < minYears ? 0 : centeredYearRow * _yearPickerRowHeight;
  }

  Widget _buildYearItem(BuildContext context, int index) {
    final datePickerTheme = DatePickerTheme.of(context);
    final defaults = DatePickerTheme.defaults(context);

    T? effectiveValue<T>(T? Function(DatePickerThemeData? theme) getProperty) =>
        getProperty(datePickerTheme) ?? getProperty(defaults);

    T? resolve<T>(
      MaterialStateProperty<T>? Function(DatePickerThemeData? theme)
          getProperty,
      Set<MaterialState> states,
    ) =>
        effectiveValue(
          (theme) => getProperty(theme)?.resolve(states),
        );

    // Backfill the _YearPicker with disabled years if necessary.
    final offset = _itemCount < minYears ? (minYears - _itemCount) ~/ 2 : 0;
    final year = widget.firstDate.year + index - offset;
    final isSelected = year == widget.selectedDate?.year;
    final isCurrentYear = year == widget.currentDate.year;
    final isDisabled =
        year < widget.firstDate.year || year > widget.lastDate.year;
    const decorationHeight = 36.0;
    const decorationWidth = 72.0;

    final states = <MaterialState>{
      if (isDisabled) MaterialState.disabled,
      if (isSelected) MaterialState.selected,
    };

    final textColor = resolve<Color?>(
      (theme) => isCurrentYear
          ? theme?.todayForegroundColor
          : theme?.yearForegroundColor,
      states,
    );
    final background = resolve<Color?>(
      (theme) => isCurrentYear
          ? theme?.todayBackgroundColor
          : theme?.yearBackgroundColor,
      states,
    );
    final overlayColor = MaterialStateProperty.resolveWith<Color?>(
      (states) => effectiveValue(
        (theme) => theme?.yearOverlayColor?.resolve(states),
      ),
    );

    BoxBorder? border;
    if (isCurrentYear) {
      final todayBorder = datePickerTheme.todayBorder ?? defaults.todayBorder;
      if (todayBorder != null) {
        border = Border.fromBorderSide(todayBorder.copyWith(color: textColor));
      }
    }
    final decoration = BoxDecoration(
      border: border,
      color: background,
      borderRadius: BorderRadius.circular(decorationHeight / 2),
    );

    final itemStyle = (datePickerTheme.yearStyle ?? defaults.yearStyle)
        ?.apply(color: textColor);
    Widget yearItem = Center(
      child: Container(
        decoration: decoration,
        height: decorationHeight,
        width: decorationWidth,
        child: Center(
          child: Semantics(
            selected: isSelected,
            button: true,
            child: Text(year.toString(), style: itemStyle),
          ),
        ),
      ),
    );

    if (isDisabled) {
      yearItem = ExcludeSemantics(
        child: yearItem,
      );
    } else {
      var date =
          ETDateTime(year, widget.selectedDate?.month ?? ETDateTime.meskerem);
      if (date.isBefore(
        ETDateTime(widget.firstDate.year, widget.firstDate.month),
      )) {
        // Ignore firstDate.day because we're just working in years and months here.
        assert(date.year == widget.firstDate.year);
        date = ETDateTime(year, widget.firstDate.month);
      } else if (date.isAfter(widget.lastDate)) {
        // No need to ignore the day here because it can only be bigger than what we care about.
        assert(date.year == widget.lastDate.year);
        date = ETDateTime(year, widget.lastDate.month);
      }
      _statesController.value = states;
      yearItem = InkWell(
        key: ValueKey<int>(year),
        onTap: () => widget.onChanged(date),
        statesController: _statesController,
        overlayColor: overlayColor,
        child: yearItem,
      );
    }

    return yearItem;
  }

  int get _itemCount => widget.lastDate.year - widget.firstDate.year + 1;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    return Column(
      children: <Widget>[
        const Divider(),
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            dragStartBehavior: widget.dragStartBehavior,
            gridDelegate: _yearPickerGridDelegate,
            itemBuilder: _buildYearItem,
            itemCount: math.max(_itemCount, minYears),
            padding: const EdgeInsets.symmetric(horizontal: _yearPickerPadding),
          ),
        ),
        const Divider(),
      ],
    );
  }
}

class _YearPickerGridDelegate extends SliverGridDelegate {
  const _YearPickerGridDelegate();

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final tileWidth = (constraints.crossAxisExtent -
            (_yearPickerColumnCount - 1) * _yearPickerRowSpacing) /
        _yearPickerColumnCount;
    return SliverGridRegularTileLayout(
      childCrossAxisExtent: tileWidth,
      childMainAxisExtent: _yearPickerRowHeight,
      crossAxisCount: _yearPickerColumnCount,
      crossAxisStride: tileWidth + _yearPickerRowSpacing,
      mainAxisStride: _yearPickerRowHeight,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(_YearPickerGridDelegate oldDelegate) => false;
}

const _YearPickerGridDelegate _yearPickerGridDelegate =
    _YearPickerGridDelegate();

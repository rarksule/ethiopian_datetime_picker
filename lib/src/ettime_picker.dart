// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import "dart:async";
import "dart:math" as math;
import "dart:ui";

import "package:ethiopian_datetime_picker/src/cupertino/cupertino_common.dart";
import "package:ethiopian_datetime_picker/src/ettime_picker_theme.dart";
import "package:ethiopian_datetime_picker/src/string_text.dart";
import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "package:flutter/services.dart";

// Examples can assume:
// late BuildContext context;

const Duration _kDialAnimateDuration = Duration(milliseconds: 200);
const double _kTwoPi = 2 * math.pi;
const Duration _kVibrateCommitDelay = Duration(milliseconds: 100);

const double _kTimePickerHeaderLandscapeWidth = 216;
const double _kTimePickerInnerDialOffset = 28;
const double _kTimePickerDialMinRadius = 50;
const double _kTimePickerDialPadding = 28;

// Whether the dial-mode time picker is currently selecting the hour or the
// minute.
enum _HourMinuteMode { hour, minute }

// Aspects of _TimePickerModel that can be depended upon.
enum _TimePickerAspect {
  use24HourFormat,
  useMaterial3,
  entryMode,
  hourMinuteMode,
  onHourMinuteModeChanged,
  onHourDoubleTapped,
  onMinuteDoubleTapped,
  hourDialType,
  selectedTime,
  onSelectedTimeChanged,
  orientation,
  theme,
  defaultTheme,
}

class _TimePickerModel extends InheritedModel<_TimePickerAspect> {
  const _TimePickerModel({
    required this.entryMode,
    required this.hourMinuteMode,
    required this.onHourMinuteModeChanged,
    required this.onHourDoubleTapped,
    required this.onMinuteDoubleTapped,
    required this.selectedTime,
    required this.onSelectedTimeChanged,
    required this.use24HourFormat,
    required this.useMaterial3,
    required this.hourDialType,
    required this.orientation,
    required this.theme,
    required this.defaultTheme,
    required super.child,
  });

  final TimePickerEntryMode entryMode;
  final _HourMinuteMode hourMinuteMode;
  final ValueChanged<_HourMinuteMode> onHourMinuteModeChanged;
  final GestureTapCallback onHourDoubleTapped;
  final GestureTapCallback onMinuteDoubleTapped;
  final TimeOfDay selectedTime;
  final ValueChanged<TimeOfDay> onSelectedTimeChanged;
  final bool use24HourFormat;
  final bool useMaterial3;
  final _HourDialType hourDialType;
  final Orientation orientation;
  final TimePickerThemeData theme;
  final ETTimePickerDefaults defaultTheme;

  static _TimePickerModel of(
    BuildContext context, [
    _TimePickerAspect? aspect,
  ]) =>
      InheritedModel.inheritFrom<_TimePickerModel>(context, aspect: aspect)!;
  static TimePickerEntryMode entryModeOf(BuildContext context) =>
      of(context, _TimePickerAspect.entryMode).entryMode;
  static _HourMinuteMode hourMinuteModeOf(BuildContext context) =>
      of(context, _TimePickerAspect.hourMinuteMode).hourMinuteMode;
  static TimeOfDay selectedTimeOf(BuildContext context) =>
      of(context, _TimePickerAspect.selectedTime).selectedTime;
  static bool use24HourFormatOf(BuildContext context) =>
      of(context, _TimePickerAspect.use24HourFormat).use24HourFormat;
  static bool useMaterial3Of(BuildContext context) =>
      of(context, _TimePickerAspect.useMaterial3).useMaterial3;
  static _HourDialType hourDialTypeOf(BuildContext context) =>
      of(context, _TimePickerAspect.hourDialType).hourDialType;
  static Orientation orientationOf(BuildContext context) =>
      of(context, _TimePickerAspect.orientation).orientation;
  static TimePickerThemeData themeOf(BuildContext context) =>
      of(context, _TimePickerAspect.theme).theme;
  static ETTimePickerDefaults defaultThemeOf(BuildContext context) =>
      of(context, _TimePickerAspect.defaultTheme).defaultTheme;

  static void setSelectedTime(BuildContext context, TimeOfDay value) =>
      of(context, _TimePickerAspect.onSelectedTimeChanged)
          .onSelectedTimeChanged(value);
  static void setHourMinuteMode(BuildContext context, _HourMinuteMode value) =>
      of(context, _TimePickerAspect.onHourMinuteModeChanged)
          .onHourMinuteModeChanged(value);

  @override
  bool updateShouldNotifyDependent(
    _TimePickerModel oldWidget,
    Set<_TimePickerAspect> dependencies,
  ) {
    if (use24HourFormat != oldWidget.use24HourFormat &&
        dependencies.contains(_TimePickerAspect.use24HourFormat)) {
      return true;
    }
    if (useMaterial3 != oldWidget.useMaterial3 &&
        dependencies.contains(_TimePickerAspect.useMaterial3)) {
      return true;
    }
    if (entryMode != oldWidget.entryMode &&
        dependencies.contains(_TimePickerAspect.entryMode)) {
      return true;
    }
    if (hourMinuteMode != oldWidget.hourMinuteMode &&
        dependencies.contains(_TimePickerAspect.hourMinuteMode)) {
      return true;
    }
    if (onHourMinuteModeChanged != oldWidget.onHourMinuteModeChanged &&
        dependencies.contains(_TimePickerAspect.onHourMinuteModeChanged)) {
      return true;
    }
    if (onHourMinuteModeChanged != oldWidget.onHourDoubleTapped &&
        dependencies.contains(_TimePickerAspect.onHourDoubleTapped)) {
      return true;
    }
    if (onHourMinuteModeChanged != oldWidget.onMinuteDoubleTapped &&
        dependencies.contains(_TimePickerAspect.onMinuteDoubleTapped)) {
      return true;
    }
    if (hourDialType != oldWidget.hourDialType &&
        dependencies.contains(_TimePickerAspect.hourDialType)) {
      return true;
    }
    if (selectedTime != oldWidget.selectedTime &&
        dependencies.contains(_TimePickerAspect.selectedTime)) {
      return true;
    }
    if (onSelectedTimeChanged != oldWidget.onSelectedTimeChanged &&
        dependencies.contains(_TimePickerAspect.onSelectedTimeChanged)) {
      return true;
    }
    if (orientation != oldWidget.orientation &&
        dependencies.contains(_TimePickerAspect.orientation)) {
      return true;
    }
    if (theme != oldWidget.theme &&
        dependencies.contains(_TimePickerAspect.theme)) {
      return true;
    }
    if (defaultTheme != oldWidget.defaultTheme &&
        dependencies.contains(_TimePickerAspect.defaultTheme)) {
      return true;
    }
    return false;
  }

  @override
  bool updateShouldNotify(_TimePickerModel oldWidget) =>
      use24HourFormat != oldWidget.use24HourFormat ||
      useMaterial3 != oldWidget.useMaterial3 ||
      entryMode != oldWidget.entryMode ||
      hourMinuteMode != oldWidget.hourMinuteMode ||
      onHourMinuteModeChanged != oldWidget.onHourMinuteModeChanged ||
      onHourDoubleTapped != oldWidget.onHourDoubleTapped ||
      onMinuteDoubleTapped != oldWidget.onMinuteDoubleTapped ||
      hourDialType != oldWidget.hourDialType ||
      selectedTime != oldWidget.selectedTime ||
      onSelectedTimeChanged != oldWidget.onSelectedTimeChanged ||
      orientation != oldWidget.orientation ||
      theme != oldWidget.theme ||
      defaultTheme != oldWidget.defaultTheme;
}

class _TimePickerHeader extends StatelessWidget {
  const _TimePickerHeader({required this.helpText});

  final String helpText;

  @override
  Widget build(BuildContext context) {
    final timeOfDayFormat = MaterialLocalizations.of(context).timeOfDayFormat(
      alwaysUse24HourFormat: _TimePickerModel.use24HourFormatOf(context),
    );

    final hourDialType = _TimePickerModel.hourDialTypeOf(context);
    switch (_TimePickerModel.orientationOf(context)) {
      case Orientation.portrait:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsetsDirectional.only(
                bottom: _TimePickerModel.useMaterial3Of(context) ? 20 : 24,
              ),
              child: Text(
                helpText,
                style: _TimePickerModel.themeOf(context).helpTextStyle ??
                    _TimePickerModel.defaultThemeOf(context).helpTextStyle,
              ),
            ),
            Row(
              children: <Widget>[
                if (hourDialType == _HourDialType.twelveHour &&
                    timeOfDayFormat == TimeOfDayFormat.a_space_h_colon_mm)
                  const _DayPeriodControl(),
                Expanded(
                  child: Row(
                    // Hour/minutes should not change positions in RTL locales.
                    textDirection: TextDirection.ltr,
                    children: <Widget>[
                      const Expanded(child: _HourControl()),
                      _StringFragment(timeOfDayFormat: timeOfDayFormat),
                      const Expanded(child: _MinuteControl()),
                    ],
                  ),
                ),
                if (hourDialType == _HourDialType.twelveHour &&
                    timeOfDayFormat !=
                        TimeOfDayFormat.a_space_h_colon_mm) ...<Widget>[
                  const SizedBox(width: 12),
                  const _DayPeriodControl(),
                ],
              ],
            ),
          ],
        );
      case Orientation.landscape:
        return SizedBox(
          width: _kTimePickerHeaderLandscapeWidth,
          child: Stack(
            children: <Widget>[
              Text(
                helpText,
                style: _TimePickerModel.themeOf(context).helpTextStyle ??
                    _TimePickerModel.defaultThemeOf(context).helpTextStyle,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (hourDialType == _HourDialType.twelveHour &&
                      timeOfDayFormat == TimeOfDayFormat.a_space_h_colon_mm)
                    const _DayPeriodControl(),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: hourDialType == _HourDialType.twelveHour ? 12 : 0,
                    ),
                    child: Row(
                      // Hour/minutes should not change positions in RTL locales.
                      textDirection: TextDirection.ltr,
                      children: <Widget>[
                        const Expanded(child: _HourControl()),
                        _StringFragment(timeOfDayFormat: timeOfDayFormat),
                        const Expanded(child: _MinuteControl()),
                      ],
                    ),
                  ),
                  if (hourDialType == _HourDialType.twelveHour &&
                      timeOfDayFormat != TimeOfDayFormat.a_space_h_colon_mm)
                    const _DayPeriodControl(),
                ],
              ),
            ],
          ),
        );
    }
  }
}

class _HourMinuteControl extends StatelessWidget {
  const _HourMinuteControl({
    required this.text,
    required this.onTap,
    required this.onDoubleTap,
    required this.isSelected,
  });

  final String text;
  final GestureTapCallback onTap;
  final GestureTapCallback onDoubleTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final timePickerTheme = _TimePickerModel.themeOf(context);
    final defaultTheme = _TimePickerModel.defaultThemeOf(context);
    final backgroundColor =
        timePickerTheme.hourMinuteColor ?? defaultTheme.hourMinuteColor;
    final shape =
        timePickerTheme.hourMinuteShape ?? defaultTheme.hourMinuteShape;

    final states = <MaterialState>{
      if (isSelected) MaterialState.selected,
    };
    final effectiveTextColor = MaterialStateProperty.resolveAs<Color>(
      _TimePickerModel.themeOf(context).hourMinuteTextColor ??
          _TimePickerModel.defaultThemeOf(context).hourMinuteTextColor,
      states,
    );
    final effectiveStyle = MaterialStateProperty.resolveAs<TextStyle>(
      timePickerTheme.hourMinuteTextStyle ?? defaultTheme.hourMinuteTextStyle,
      states,
    ).copyWith(color: effectiveTextColor);

    final double height;
    switch (_TimePickerModel.entryModeOf(context)) {
      case TimePickerEntryMode.dial:
      case TimePickerEntryMode.dialOnly:
        height = defaultTheme.hourMinuteSize.height;
      case TimePickerEntryMode.input:
      case TimePickerEntryMode.inputOnly:
        height = defaultTheme.hourMinuteInputSize.height;
    }

    return SizedBox(
      height: height,
      child: Material(
        color: MaterialStateProperty.resolveAs(backgroundColor, states),
        clipBehavior: Clip.antiAlias,
        shape: shape,
        child: InkWell(
          onTap: onTap,
          onDoubleTap: isSelected ? onDoubleTap : null,
          child: Center(
            child: Text(
              text,
              style: effectiveStyle,
              textScaler: TextScaler.noScaling,
            ),
          ),
        ),
      ),
    );
  }
}

/// Displays the hour fragment.
///
/// When tapped changes time picker dial mode to [_HourMinuteMode.hour].
class _HourControl extends StatelessWidget {
  const _HourControl();

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final alwaysUse24HourFormat = MediaQuery.alwaysUse24HourFormatOf(context);
    final selectedTime = _TimePickerModel.selectedTimeOf(context);
    final localizations = MaterialLocalizations.of(context);
    final formattedHour = localizations.formatHour(
      selectedTime,
      alwaysUse24HourFormat: _TimePickerModel.use24HourFormatOf(context),
    );

    TimeOfDay hoursFromSelected(int hoursToAdd) {
      switch (_TimePickerModel.hourDialTypeOf(context)) {
        case _HourDialType.twentyFourHour:
        case _HourDialType.twentyFourHourDoubleRing:
          final selectedHour = selectedTime.hour;
          return selectedTime.replacing(
            hour: (selectedHour + hoursToAdd) % TimeOfDay.hoursPerDay,
          );
        case _HourDialType.twelveHour:
          // Cycle 1 through 12 without changing day period.
          final periodOffset = selectedTime.periodOffset;
          final hours = selectedTime.hourOfPeriod;
          return selectedTime.replacing(
            hour:
                periodOffset + (hours + hoursToAdd) % TimeOfDay.hoursPerPeriod,
          );
      }
    }

    final nextHour = hoursFromSelected(1);
    final formattedNextHour = localizations.formatHour(
      nextHour,
      alwaysUse24HourFormat: alwaysUse24HourFormat,
    );
    final previousHour = hoursFromSelected(-1);
    final formattedPreviousHour = localizations.formatHour(
      previousHour,
      alwaysUse24HourFormat: alwaysUse24HourFormat,
    );

    return Semantics(
      value: "${localizations.timePickerHourModeAnnouncement} $formattedHour",
      excludeSemantics: true,
      increasedValue: formattedNextHour,
      onIncrease: () {
        _TimePickerModel.setSelectedTime(context, nextHour);
      },
      decreasedValue: formattedPreviousHour,
      onDecrease: () {
        _TimePickerModel.setSelectedTime(context, previousHour);
      },
      child: _HourMinuteControl(
        isSelected:
            _TimePickerModel.hourMinuteModeOf(context) == _HourMinuteMode.hour,
        text: formattedHour,
        onTap: Feedback.wrapForTap(
          () => _TimePickerModel.setHourMinuteMode(
            context,
            _HourMinuteMode.hour,
          ),
          context,
        )!,
        onDoubleTap:
            _TimePickerModel.of(context, _TimePickerAspect.onHourDoubleTapped)
                .onHourDoubleTapped,
      ),
    );
  }
}

/// A passive fragment showing a string value.
///
/// Used to display the appropriate separator between the input fields.
class _StringFragment extends StatelessWidget {
  const _StringFragment({required this.timeOfDayFormat});

  final TimeOfDayFormat timeOfDayFormat;

  String _stringFragmentValue(TimeOfDayFormat timeOfDayFormat) {
    switch (timeOfDayFormat) {
      case TimeOfDayFormat.h_colon_mm_space_a:
      case TimeOfDayFormat.a_space_h_colon_mm:
      case TimeOfDayFormat.H_colon_mm:
      case TimeOfDayFormat.HH_colon_mm:
        return ":";
      case TimeOfDayFormat.HH_dot_mm:
        return ".";
      case TimeOfDayFormat.frenchCanadian:
        return "h";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timePickerTheme = TimePickerTheme.of(context);
    final defaultTheme = theme.useMaterial3
        ? ETTimePickerDefaultsM3(context)
        : ETTimePickerDefaultsM2(context);
    final states = <MaterialState>{};

    final effectiveTextColor = MaterialStateProperty.resolveAs<Color>(
      timePickerTheme.hourMinuteTextColor ?? defaultTheme.hourMinuteTextColor,
      states,
    );
    final effectiveStyle = MaterialStateProperty.resolveAs<TextStyle>(
      timePickerTheme.hourMinuteTextStyle ?? defaultTheme.hourMinuteTextStyle,
      states,
    ).copyWith(color: effectiveTextColor);

    final double height;
    switch (_TimePickerModel.entryModeOf(context)) {
      case TimePickerEntryMode.dial:
      case TimePickerEntryMode.dialOnly:
        height = defaultTheme.hourMinuteSize.height;
      case TimePickerEntryMode.input:
      case TimePickerEntryMode.inputOnly:
        height = defaultTheme.hourMinuteInputSize.height;
    }

    return ExcludeSemantics(
      child: SizedBox(
        width: timeOfDayFormat == TimeOfDayFormat.frenchCanadian ? 36 : 24,
        height: height,
        child: Text(
          _stringFragmentValue(timeOfDayFormat),
          style: effectiveStyle,
          textScaler: TextScaler.noScaling,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// Displays the minute fragment.
///
/// When tapped changes time picker dial mode to [_HourMinuteMode.minute].
class _MinuteControl extends StatelessWidget {
  const _MinuteControl();

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final selectedTime = _TimePickerModel.selectedTimeOf(context);
    final formattedMinute = localizations.formatMinute(selectedTime);
    final nextMinute = selectedTime.replacing(
      minute: (selectedTime.minute + 1) % TimeOfDay.minutesPerHour,
    );
    final formattedNextMinute = localizations.formatMinute(nextMinute);
    final previousMinute = selectedTime.replacing(
      minute: (selectedTime.minute - 1) % TimeOfDay.minutesPerHour,
    );
    final formattedPreviousMinute = localizations.formatMinute(previousMinute);

    return Semantics(
      excludeSemantics: true,
      value:
          "${localizations.timePickerMinuteModeAnnouncement} $formattedMinute",
      increasedValue: formattedNextMinute,
      onIncrease: () {
        _TimePickerModel.setSelectedTime(context, nextMinute);
      },
      decreasedValue: formattedPreviousMinute,
      onDecrease: () {
        _TimePickerModel.setSelectedTime(context, previousMinute);
      },
      child: _HourMinuteControl(
        isSelected: _TimePickerModel.hourMinuteModeOf(context) ==
            _HourMinuteMode.minute,
        text: formattedMinute,
        onTap: Feedback.wrapForTap(
          () => _TimePickerModel.setHourMinuteMode(
            context,
            _HourMinuteMode.minute,
          ),
          context,
        )!,
        onDoubleTap:
            _TimePickerModel.of(context, _TimePickerAspect.onMinuteDoubleTapped)
                .onMinuteDoubleTapped,
      ),
    );
  }
}

/// Displays the am/pm fragment and provides controls for switching between am
/// and pm.
class _DayPeriodControl extends StatelessWidget {
  const _DayPeriodControl({this.onPeriodChanged});

  final ValueChanged<TimeOfDay>? onPeriodChanged;

  void _togglePeriod(BuildContext context) {
    final selectedTime = _TimePickerModel.selectedTimeOf(context);
    final newHour =
        (selectedTime.hour + TimeOfDay.hoursPerPeriod) % TimeOfDay.hoursPerDay;
    final newTime = selectedTime.replacing(hour: newHour);
    if (onPeriodChanged != null) {
      onPeriodChanged!.call(newTime);
    } else {
      _TimePickerModel.setSelectedTime(context, newTime);
    }
  }

  void _setAm(BuildContext context) {
    final selectedTime = _TimePickerModel.selectedTimeOf(context);
    if (selectedTime.period == DayPeriod.am) {
      return;
    }
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        _announceToAccessibility(
          context,
          MaterialLocalizations.of(context).anteMeridiemAbbreviation,
        );
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        break;
    }
    _togglePeriod(context);
  }

  void _setPm(BuildContext context) {
    final selectedTime = _TimePickerModel.selectedTimeOf(context);
    if (selectedTime.period == DayPeriod.pm) {
      return;
    }
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        _announceToAccessibility(
          context,
          MaterialLocalizations.of(context).postMeridiemAbbreviation,
        );
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        break;
    }
    _togglePeriod(context);
  }

  @override
  Widget build(BuildContext context) {
    final timePickerTheme = _TimePickerModel.themeOf(context);
    final defaultTheme = _TimePickerModel.defaultThemeOf(context);
    final selectedTime = _TimePickerModel.selectedTimeOf(context);
    final amSelected = selectedTime.period == DayPeriod.am;
    final pmSelected = !amSelected;
    final resolvedSide =
        timePickerTheme.dayPeriodBorderSide ?? defaultTheme.dayPeriodBorderSide;
    final resolvedShape =
        (timePickerTheme.dayPeriodShape ?? defaultTheme.dayPeriodShape)
            .copyWith(side: resolvedSide);

    final Widget amButton = _AmPmButton(
      selected: amSelected,
      onPressed: () => _setAm(context),
      label: anteMeridiemAbbreviation(context, selectedTime.hour),
    );

    final Widget pmButton = _AmPmButton(
      selected: pmSelected,
      onPressed: () => _setPm(context),
      label: postMeridiemAbbreviation(context, selectedTime.hour),
    );

    Size dayPeriodSize;
    final Orientation orientation;
    switch (_TimePickerModel.entryModeOf(context)) {
      case TimePickerEntryMode.dial:
      case TimePickerEntryMode.dialOnly:
        orientation = _TimePickerModel.orientationOf(context);
        switch (orientation) {
          case Orientation.portrait:
            dayPeriodSize = defaultTheme.dayPeriodPortraitSize;
          case Orientation.landscape:
            dayPeriodSize = defaultTheme.dayPeriodLandscapeSize;
        }
      case TimePickerEntryMode.input:
      case TimePickerEntryMode.inputOnly:
        orientation = Orientation.portrait;
        dayPeriodSize = defaultTheme.dayPeriodInputSize;
    }

    final Widget result;
    switch (orientation) {
      case Orientation.portrait:
        result = _DayPeriodInputPadding(
          minSize: dayPeriodSize,
          orientation: orientation,
          child: SizedBox.fromSize(
            size: dayPeriodSize,
            child: Material(
              clipBehavior: Clip.antiAlias,
              color: Colors.transparent,
              shape: resolvedShape,
              child: Column(
                children: <Widget>[
                  Expanded(child: amButton),
                  Container(
                    decoration:
                        BoxDecoration(border: Border(top: resolvedSide)),
                    height: 1,
                  ),
                  Expanded(child: pmButton),
                ],
              ),
            ),
          ),
        );
      case Orientation.landscape:
        result = _DayPeriodInputPadding(
          minSize: dayPeriodSize,
          orientation: orientation,
          child: SizedBox(
            height: dayPeriodSize.height,
            child: Material(
              clipBehavior: Clip.antiAlias,
              color: Colors.transparent,
              shape: resolvedShape,
              child: Row(
                children: <Widget>[
                  Expanded(child: amButton),
                  Container(
                    decoration:
                        BoxDecoration(border: Border(left: resolvedSide)),
                    width: 1,
                  ),
                  Expanded(child: pmButton),
                ],
              ),
            ),
          ),
        );
    }
    return result;
  }
}

class _AmPmButton extends StatelessWidget {
  const _AmPmButton({
    required this.onPressed,
    required this.selected,
    required this.label,
  });

  final bool selected;
  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    final states = <MaterialState>{
      if (selected) MaterialState.selected,
    };
    final timePickerTheme = _TimePickerModel.themeOf(context);
    final defaultTheme = _TimePickerModel.defaultThemeOf(context);
    final resolvedBackgroundColor = MaterialStateProperty.resolveAs<Color>(
      timePickerTheme.dayPeriodColor ?? defaultTheme.dayPeriodColor,
      states,
    );
    final resolvedTextColor = MaterialStateProperty.resolveAs<Color>(
      timePickerTheme.dayPeriodTextColor ?? defaultTheme.dayPeriodTextColor,
      states,
    );
    final resolvedTextStyle = MaterialStateProperty.resolveAs<TextStyle?>(
      timePickerTheme.dayPeriodTextStyle ?? defaultTheme.dayPeriodTextStyle,
      states,
    )?.copyWith(
      color: resolvedTextColor,
      overflow: TextOverflow.ellipsis,
    );
    final buttonTextScaler =
        MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 2);

    return Material(
      color: resolvedBackgroundColor,
      child: InkWell(
        onTap: Feedback.wrapForTap(onPressed, context),
        child: Semantics(
          checked: selected,
          inMutuallyExclusiveGroup: true,
          button: true,
          child: Center(
            child: Text(
              label,
              style: resolvedTextStyle,
              textScaler: buttonTextScaler,
            ),
          ),
        ),
      ),
    );
  }
}

/// A widget to pad the area around the [_DayPeriodControl]'s inner [Material].
class _DayPeriodInputPadding extends SingleChildRenderObjectWidget {
  const _DayPeriodInputPadding({
    required Widget super.child,
    required this.minSize,
    required this.orientation,
  });

  final Size minSize;
  final Orientation orientation;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderInputPadding(minSize, orientation);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderInputPadding renderObject,
  ) {
    renderObject
      ..minSize = minSize
      ..orientation = orientation;
  }
}

class _RenderInputPadding extends RenderShiftedBox {
  _RenderInputPadding(this._minSize, this._orientation, [RenderBox? child])
      : super(child);

  Size get minSize => _minSize;
  Size _minSize;
  set minSize(Size value) {
    if (_minSize == value) {
      return;
    }
    _minSize = value;
    markNeedsLayout();
  }

  Orientation get orientation => _orientation;
  Orientation _orientation;
  set orientation(Orientation value) {
    if (_orientation == value) {
      return;
    }
    _orientation = value;
    markNeedsLayout();
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    if (child != null) {
      return math.max(child!.getMinIntrinsicWidth(height), minSize.width);
    }
    return 0;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    if (child != null) {
      return math.max(child!.getMinIntrinsicHeight(width), minSize.height);
    }
    return 0;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    if (child != null) {
      return math.max(child!.getMaxIntrinsicWidth(height), minSize.width);
    }
    return 0;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    if (child != null) {
      return math.max(child!.getMaxIntrinsicHeight(width), minSize.height);
    }
    return 0;
  }

  Size _computeSize({
    required BoxConstraints constraints,
    required ChildLayouter layoutChild,
  }) {
    if (child != null) {
      final childSize = layoutChild(child!, constraints);
      final double width = math.max(childSize.width, minSize.width);
      final double height = math.max(childSize.height, minSize.height);
      return constraints.constrain(Size(width, height));
    }
    return Size.zero;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) => _computeSize(
        constraints: constraints,
        layoutChild: ChildLayoutHelper.dryLayoutChild,
      );

  @override
  void performLayout() {
    size = _computeSize(
      constraints: constraints,
      layoutChild: ChildLayoutHelper.layoutChild,
    );
    if (child != null) {
      final childParentData = child!.parentData! as BoxParentData;
      // ignore: cascade_invocations
      childParentData.offset =
          Alignment.center.alongOffset(size - child!.size as Offset);
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (super.hitTest(result, position: position)) {
      return true;
    }

    if (position.dx < 0 ||
        position.dx > math.max(child!.size.width, minSize.width) ||
        position.dy < 0 ||
        position.dy > math.max(child!.size.height, minSize.height)) {
      return false;
    }

    var newPosition = child!.size.center(Offset.zero);
    switch (orientation) {
      case Orientation.portrait:
        if (position.dy > newPosition.dy) {
          newPosition += const Offset(0, 1);
        } else {
          newPosition += const Offset(0, -1);
        }
      case Orientation.landscape:
        if (position.dx > newPosition.dx) {
          newPosition += const Offset(1, 0);
        } else {
          newPosition += const Offset(-1, 0);
        }
    }

    return result.addWithRawTransform(
      transform: MatrixUtils.forceToPoint(newPosition),
      position: newPosition,
      hitTest: (result, position) {
        assert(position == newPosition);
        return child!.hitTest(result, position: newPosition);
      },
    );
  }
}

class _TappableLabel {
  _TappableLabel({
    required this.value,
    required this.inner,
    required this.painter,
    required this.onTap,
  });

  /// The value this label is displaying.
  final int value;

  /// This value is part of the "inner" ring of values on the dial, used for 24
  /// hour input.
  final bool inner;

  /// Paints the text of the label.
  final TextPainter painter;

  /// Called when a tap gesture is detected on the label.
  final VoidCallback onTap;
}

class _DialPainter extends CustomPainter {
  _DialPainter({
    required this.primaryLabels,
    required this.selectedLabels,
    required this.backgroundColor,
    required this.handColor,
    required this.handWidth,
    required this.dotColor,
    required this.dotRadius,
    required this.centerRadius,
    required this.theta,
    required this.radius,
    required this.textDirection,
    required this.selectedValue,
  }) : super(repaint: PaintingBinding.instance.systemFonts);

  final List<_TappableLabel> primaryLabels;
  final List<_TappableLabel> selectedLabels;
  final Color backgroundColor;
  final Color handColor;
  final double handWidth;
  final Color dotColor;
  final double dotRadius;
  final double centerRadius;
  final double theta;
  final double radius;
  final TextDirection textDirection;
  final int selectedValue;

  void dispose() {
    for (final label in primaryLabels) {
      label.painter.dispose();
    }
    for (final label in selectedLabels) {
      label.painter.dispose();
    }
    primaryLabels.clear();
    selectedLabels.clear();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final dialRadius = clampDouble(
      size.shortestSide / 2,
      _kTimePickerDialMinRadius + dotRadius,
      double.infinity,
    );
    final labelRadius = clampDouble(
      dialRadius - _kTimePickerDialPadding,
      _kTimePickerDialMinRadius,
      double.infinity,
    );
    final innerLabelRadius = clampDouble(
      labelRadius - _kTimePickerInnerDialOffset,
      0,
      double.infinity,
    );
    final handleRadius = clampDouble(
      labelRadius - (radius < 0.5 ? 1 : 0) * (labelRadius - innerLabelRadius),
      _kTimePickerDialMinRadius,
      double.infinity,
    );
    final center = Offset(size.width / 2, size.height / 2);
    final centerPoint = center;
    canvas.drawCircle(
      centerPoint,
      dialRadius,
      Paint()..color = backgroundColor,
    );

    Offset getOffsetForTheta(double theta, double radius) =>
        center + Offset(radius * math.cos(theta), -radius * math.sin(theta));

    void paintLabels(List<_TappableLabel> labels, double radius) {
      if (labels.isEmpty) {
        return;
      }
      final labelThetaIncrement = -_kTwoPi / labels.length;
      var labelTheta = math.pi / 2;

      for (final label in labels) {
        final labelPainter = label.painter;
        final labelOffset =
            Offset(-labelPainter.width / 2, -labelPainter.height / 2);
        labelPainter.paint(
          canvas,
          getOffsetForTheta(labelTheta, radius) + labelOffset,
        );
        labelTheta += labelThetaIncrement;
      }
    }

    void paintInnerOuterLabels(List<_TappableLabel>? labels) {
      if (labels == null) {
        return;
      }

      paintLabels(
        labels.where((label) => !label.inner).toList(),
        labelRadius,
      );
      paintLabels(
        labels.where((label) => label.inner).toList(),
        innerLabelRadius,
      );
    }

    paintInnerOuterLabels(primaryLabels);

    final selectorPaint = Paint()..color = handColor;
    final focusedPoint = getOffsetForTheta(theta, handleRadius);
    canvas
      ..drawCircle(centerPoint, centerRadius, selectorPaint)
      ..drawCircle(focusedPoint, dotRadius, selectorPaint);
    selectorPaint.strokeWidth = handWidth;
    canvas.drawLine(centerPoint, focusedPoint, selectorPaint);

    // Add a dot inside the selector but only when it isn't over the labels.
    // This checks that the selector's theta is between two labels. A remainder
    // between 0.1 and 0.45 indicates that the selector is roughly not above any
    // labels. The values were derived by manually testing the dial.
    final labelThetaIncrement = -_kTwoPi / primaryLabels.length;
    if (theta % labelThetaIncrement > 0.1 &&
        theta % labelThetaIncrement < 0.45) {
      canvas.drawCircle(focusedPoint, 2, selectorPaint..color = dotColor);
    }

    final focusedRect = Rect.fromCircle(
      center: focusedPoint,
      radius: dotRadius,
    );
    canvas
      ..save()
      ..clipPath(Path()..addOval(focusedRect));
    paintInnerOuterLabels(selectedLabels);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_DialPainter oldPainter) =>
      oldPainter.primaryLabels != primaryLabels ||
      oldPainter.selectedLabels != selectedLabels ||
      oldPainter.backgroundColor != backgroundColor ||
      oldPainter.handColor != handColor ||
      oldPainter.theta != theta;
}

// Which kind of hour dial being presented.
enum _HourDialType {
  twentyFourHour,
  twentyFourHourDoubleRing,
  twelveHour,
}

class _Dial extends StatefulWidget {
  const _Dial({
    required this.selectedTime,
    required this.hourMinuteMode,
    required this.hourDialType,
    required this.onChanged,
    required this.onHourSelected,
  });

  final TimeOfDay selectedTime;
  final _HourMinuteMode hourMinuteMode;
  final _HourDialType hourDialType;
  final ValueChanged<TimeOfDay>? onChanged;
  final VoidCallback? onHourSelected;

  @override
  _DialState createState() => _DialState();
}

class _DialState extends State<_Dial> with SingleTickerProviderStateMixin {
  late ThemeData themeData;
  late MaterialLocalizations localizations;
  _DialPainter? painter;
  late AnimationController _animationController;
  late Tween<double> _thetaTween;
  late Animation<double> _theta;
  late Tween<double> _radiusTween;
  late Animation<double> _radius;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: _kDialAnimateDuration,
      vsync: this,
    );
    _thetaTween = Tween<double>(begin: _getThetaForTime(widget.selectedTime));
    _radiusTween = Tween<double>(begin: _getRadiusForTime(widget.selectedTime));
    _theta = _animationController
        .drive(CurveTween(curve: standardEasing))
        .drive(_thetaTween)
      ..addListener(() => setState(() {/* _theta.value has changed */}));
    _radius = _animationController
        .drive(CurveTween(curve: standardEasing))
        .drive(_radiusTween)
      ..addListener(() => setState(() {/* _radius.value has changed */}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    assert(debugCheckHasMediaQuery(context));
    themeData = Theme.of(context);
    localizations = MaterialLocalizations.of(context);
  }

  @override
  void didUpdateWidget(_Dial oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hourMinuteMode != oldWidget.hourMinuteMode ||
        widget.selectedTime != oldWidget.selectedTime) {
      if (!_dragging) {
        _animateTo(
          _getThetaForTime(widget.selectedTime),
          _getRadiusForTime(widget.selectedTime),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    painter?.dispose();
    super.dispose();
  }

  static double _nearest(double target, double a, double b) =>
      ((target - a).abs() < (target - b).abs()) ? a : b;

  void _animateTo(double targetTheta, double targetRadius) {
    void animateToValue({
      required double target,
      required Animation<double> animation,
      required Tween<double> tween,
      required AnimationController controller,
      required double min,
      required double max,
    }) {
      var beginValue = _nearest(target, animation.value, max);
      beginValue = _nearest(target, beginValue, min);
      tween
        ..begin = beginValue
        ..end = target;
      controller
        ..value = 0
        ..forward();
    }

    animateToValue(
      target: targetTheta,
      animation: _theta,
      tween: _thetaTween,
      controller: _animationController,
      min: _theta.value - _kTwoPi,
      max: _theta.value + _kTwoPi,
    );
    animateToValue(
      target: targetRadius,
      animation: _radius,
      tween: _radiusTween,
      controller: _animationController,
      min: 0,
      max: 1,
    );
  }

  double _getRadiusForTime(TimeOfDay time) {
    switch (widget.hourMinuteMode) {
      case _HourMinuteMode.hour:
        switch (widget.hourDialType) {
          case _HourDialType.twentyFourHourDoubleRing:
            return time.hour >= 12 ? 0 : 1;
          case _HourDialType.twentyFourHour:
          case _HourDialType.twelveHour:
            return 1;
        }
      case _HourMinuteMode.minute:
        return 1;
    }
  }

  double _getThetaForTime(TimeOfDay time) {
    final int hoursFactor;
    switch (widget.hourDialType) {
      case _HourDialType.twentyFourHour:
        hoursFactor = TimeOfDay.hoursPerDay;
      case _HourDialType.twentyFourHourDoubleRing:
        hoursFactor = TimeOfDay.hoursPerPeriod;
      case _HourDialType.twelveHour:
        hoursFactor = TimeOfDay.hoursPerPeriod;
    }
    final double fraction;
    switch (widget.hourMinuteMode) {
      case _HourMinuteMode.hour:
        fraction = (time.hour / hoursFactor) % hoursFactor;
      case _HourMinuteMode.minute:
        fraction =
            (time.minute / TimeOfDay.minutesPerHour) % TimeOfDay.minutesPerHour;
    }
    return (math.pi / 2 - fraction * _kTwoPi) % _kTwoPi;
  }

  TimeOfDay _getTimeForTheta(
    double theta, {
    required double radius,
    bool roundMinutes = false,
  }) {
    final fraction = (0.25 - (theta % _kTwoPi) / _kTwoPi) % 1;
    switch (widget.hourMinuteMode) {
      case _HourMinuteMode.hour:
        int newHour;
        switch (widget.hourDialType) {
          case _HourDialType.twentyFourHour:
            newHour = (fraction * TimeOfDay.hoursPerDay).round() %
                TimeOfDay.hoursPerDay;
          case _HourDialType.twentyFourHourDoubleRing:
            newHour = (fraction * TimeOfDay.hoursPerPeriod).round() %
                TimeOfDay.hoursPerPeriod;
            if (radius < 0.5) {
              newHour = newHour + TimeOfDay.hoursPerPeriod;
            }
          case _HourDialType.twelveHour:
            newHour = (fraction * TimeOfDay.hoursPerPeriod).round() %
                TimeOfDay.hoursPerPeriod;
            newHour = newHour + widget.selectedTime.periodOffset;
        }
        return widget.selectedTime.replacing(hour: newHour);
      case _HourMinuteMode.minute:
        var minute = (fraction * TimeOfDay.minutesPerHour).round() %
            TimeOfDay.minutesPerHour;
        if (roundMinutes) {
          // Round the minutes to nearest 5 minute interval.
          minute = ((minute + 2) ~/ 5) * 5 % TimeOfDay.minutesPerHour;
        }
        return widget.selectedTime.replacing(minute: minute);
    }
  }

  TimeOfDay _notifyOnChangedIfNeeded({bool roundMinutes = false}) {
    final current = _getTimeForTheta(
      _theta.value,
      roundMinutes: roundMinutes,
      radius: _radius.value,
    );
    if (widget.onChanged == null) {
      return current;
    }
    if (current != widget.selectedTime) {
      widget.onChanged!(current);
    }
    return current;
  }

  void _updateThetaForPan({bool roundMinutes = false}) {
    setState(() {
      final offset = _position! - _center!;
      final labelRadius = _dialSize!.shortestSide / 2 - _kTimePickerDialPadding;
      final innerRadius = labelRadius - _kTimePickerInnerDialOffset;
      var angle = (math.atan2(offset.dx, offset.dy) - math.pi / 2) % _kTwoPi;
      final radius = clampDouble(
        (offset.distance - innerRadius) / _kTimePickerInnerDialOffset,
        0,
        1,
      );
      if (roundMinutes) {
        angle = _getThetaForTime(
          _getTimeForTheta(
            angle,
            roundMinutes: roundMinutes,
            radius: radius,
          ),
        );
      }
      // The controller doesn't animate during the pan gesture.
      _thetaTween
        ..begin = angle
        ..end = angle;
      _radiusTween
        ..begin = radius
        ..end = radius;
    });
  }

  Offset? _position;
  Offset? _center;
  Size? _dialSize;

  void _handlePanStart(DragStartDetails details) {
    assert(!_dragging);
    _dragging = true;
    final box = context.findRenderObject()! as RenderBox;
    _position = box.globalToLocal(details.globalPosition);
    _dialSize = box.size;
    _center = _dialSize!.center(Offset.zero);
    _updateThetaForPan();
    _notifyOnChangedIfNeeded();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    _position = _position! + details.delta;
    _updateThetaForPan();
    _notifyOnChangedIfNeeded();
  }

  void _handlePanEnd(DragEndDetails details) {
    assert(_dragging);
    _dragging = false;
    _position = null;
    _center = null;
    _dialSize = null;
    _animateTo(
      _getThetaForTime(widget.selectedTime),
      _getRadiusForTime(widget.selectedTime),
    );
    if (widget.hourMinuteMode == _HourMinuteMode.hour) {
      widget.onHourSelected?.call();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final box = context.findRenderObject()! as RenderBox;
    _position = box.globalToLocal(details.globalPosition);
    _center = box.size.center(Offset.zero);
    _dialSize = box.size;
    _updateThetaForPan(roundMinutes: true);
    final newTime = _notifyOnChangedIfNeeded(roundMinutes: true);
    if (widget.hourMinuteMode == _HourMinuteMode.hour) {
      switch (widget.hourDialType) {
        case _HourDialType.twentyFourHour:
        case _HourDialType.twentyFourHourDoubleRing:
          _announceToAccessibility(
            context,
            localizations.formatDecimal(newTime.hour),
          );
        case _HourDialType.twelveHour:
          _announceToAccessibility(
            context,
            localizations.formatDecimal(newTime.hourOfPeriod),
          );
      }
      widget.onHourSelected?.call();
    } else {
      _announceToAccessibility(
        context,
        localizations.formatDecimal(newTime.minute),
      );
    }
    final time = _getTimeForTheta(
      _theta.value,
      roundMinutes: true,
      radius: _radius.value,
    );
    _animateTo(_getThetaForTime(time), _getRadiusForTime(time));
    _dragging = false;
    _position = null;
    _center = null;
    _dialSize = null;
  }

  void _selectHour(int hour) {
    _announceToAccessibility(context, localizations.formatDecimal(hour));
    final TimeOfDay time;

    TimeOfDay getAmPmTime() {
      switch (widget.selectedTime.period) {
        case DayPeriod.am:
          return TimeOfDay(hour: hour, minute: widget.selectedTime.minute);
        case DayPeriod.pm:
          return TimeOfDay(
            hour: hour + TimeOfDay.hoursPerPeriod,
            minute: widget.selectedTime.minute,
          );
      }
    }

    switch (widget.hourMinuteMode) {
      case _HourMinuteMode.hour:
        switch (widget.hourDialType) {
          case _HourDialType.twentyFourHour:
          case _HourDialType.twentyFourHourDoubleRing:
            time = TimeOfDay(hour: hour, minute: widget.selectedTime.minute);
          case _HourDialType.twelveHour:
            time = getAmPmTime();
        }
      case _HourMinuteMode.minute:
        time = getAmPmTime();
    }
    final angle = _getThetaForTime(time);
    _thetaTween
      ..begin = angle
      ..end = angle;
    _notifyOnChangedIfNeeded();
  }

  void _selectMinute(int minute) {
    _announceToAccessibility(context, localizations.formatDecimal(minute));
    final time = TimeOfDay(
      hour: widget.selectedTime.hour,
      minute: minute,
    );
    final angle = _getThetaForTime(time);
    _thetaTween
      ..begin = angle
      ..end = angle;
    _notifyOnChangedIfNeeded();
  }

  static const List<TimeOfDay> _amHours = <TimeOfDay>[
    TimeOfDay(hour: 12, minute: 0),
    TimeOfDay(hour: 1, minute: 0),
    TimeOfDay(hour: 2, minute: 0),
    TimeOfDay(hour: 3, minute: 0),
    TimeOfDay(hour: 4, minute: 0),
    TimeOfDay(hour: 5, minute: 0),
    TimeOfDay(hour: 6, minute: 0),
    TimeOfDay(hour: 7, minute: 0),
    TimeOfDay(hour: 8, minute: 0),
    TimeOfDay(hour: 9, minute: 0),
    TimeOfDay(hour: 10, minute: 0),
    TimeOfDay(hour: 11, minute: 0),
  ];

  // On M2, there's no inner ring of numbers.
  static const List<TimeOfDay> _twentyFourHoursM2 = <TimeOfDay>[
    TimeOfDay(hour: 0, minute: 0),
    TimeOfDay(hour: 2, minute: 0),
    TimeOfDay(hour: 4, minute: 0),
    TimeOfDay(hour: 6, minute: 0),
    TimeOfDay(hour: 8, minute: 0),
    TimeOfDay(hour: 10, minute: 0),
    TimeOfDay(hour: 12, minute: 0),
    TimeOfDay(hour: 14, minute: 0),
    TimeOfDay(hour: 16, minute: 0),
    TimeOfDay(hour: 18, minute: 0),
    TimeOfDay(hour: 20, minute: 0),
    TimeOfDay(hour: 22, minute: 0),
  ];

  static const List<TimeOfDay> _twentyFourHours = <TimeOfDay>[
    TimeOfDay(hour: 0, minute: 0),
    TimeOfDay(hour: 1, minute: 0),
    TimeOfDay(hour: 2, minute: 0),
    TimeOfDay(hour: 3, minute: 0),
    TimeOfDay(hour: 4, minute: 0),
    TimeOfDay(hour: 5, minute: 0),
    TimeOfDay(hour: 6, minute: 0),
    TimeOfDay(hour: 7, minute: 0),
    TimeOfDay(hour: 8, minute: 0),
    TimeOfDay(hour: 9, minute: 0),
    TimeOfDay(hour: 10, minute: 0),
    TimeOfDay(hour: 11, minute: 0),
    TimeOfDay(hour: 12, minute: 0),
    TimeOfDay(hour: 13, minute: 0),
    TimeOfDay(hour: 14, minute: 0),
    TimeOfDay(hour: 15, minute: 0),
    TimeOfDay(hour: 16, minute: 0),
    TimeOfDay(hour: 17, minute: 0),
    TimeOfDay(hour: 18, minute: 0),
    TimeOfDay(hour: 19, minute: 0),
    TimeOfDay(hour: 20, minute: 0),
    TimeOfDay(hour: 21, minute: 0),
    TimeOfDay(hour: 22, minute: 0),
    TimeOfDay(hour: 23, minute: 0),
  ];

  _TappableLabel _buildTappableLabel({
    required TextStyle? textStyle,
    required int selectedValue,
    required int value,
    required bool inner,
    required String label,
    required VoidCallback onTap,
  }) =>
      _TappableLabel(
        value: value,
        inner: inner,
        painter: TextPainter(
          text: TextSpan(style: textStyle, text: label),
          textDirection: TextDirection.ltr,
          textScaler: MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 2),
        )..layout(),
        onTap: onTap,
      );

  List<_TappableLabel> _build24HourRing({
    required TextStyle? textStyle,
    required int selectedValue,
  }) =>
      <_TappableLabel>[
        if (themeData.useMaterial3)
          for (final TimeOfDay timeOfDay in _twentyFourHours)
            _buildTappableLabel(
              textStyle: textStyle,
              selectedValue: selectedValue,
              inner: timeOfDay.hour >= 12,
              value: timeOfDay.hour,
              label: timeOfDay.hour != 0
                  ? "${timeOfDay.hour}"
                  : localizations.formatHour(
                      timeOfDay,
                      alwaysUse24HourFormat: true,
                    ),
              onTap: () {
                _selectHour(timeOfDay.hour);
              },
            ),
        if (!themeData.useMaterial3)
          for (final TimeOfDay timeOfDay in _twentyFourHoursM2)
            _buildTappableLabel(
              textStyle: textStyle,
              selectedValue: selectedValue,
              inner: false,
              value: timeOfDay.hour,
              label: localizations.formatHour(
                timeOfDay,
                alwaysUse24HourFormat: true,
              ),
              onTap: () {
                _selectHour(timeOfDay.hour);
              },
            ),
      ];

  List<_TappableLabel> _build12HourRing({
    required TextStyle? textStyle,
    required int selectedValue,
  }) =>
      <_TappableLabel>[
        for (final TimeOfDay timeOfDay in _amHours)
          _buildTappableLabel(
            textStyle: textStyle,
            selectedValue: selectedValue,
            inner: false,
            value: timeOfDay.hour,
            label: localizations.formatHour(
              timeOfDay,
              alwaysUse24HourFormat:
                  MediaQuery.alwaysUse24HourFormatOf(context),
            ),
            onTap: () {
              _selectHour(timeOfDay.hour);
            },
          ),
      ];

  List<_TappableLabel> _buildMinutes({
    required TextStyle? textStyle,
    required int selectedValue,
  }) {
    const minuteMarkerValues = <TimeOfDay>[
      TimeOfDay(hour: 0, minute: 0),
      TimeOfDay(hour: 0, minute: 5),
      TimeOfDay(hour: 0, minute: 10),
      TimeOfDay(hour: 0, minute: 15),
      TimeOfDay(hour: 0, minute: 20),
      TimeOfDay(hour: 0, minute: 25),
      TimeOfDay(hour: 0, minute: 30),
      TimeOfDay(hour: 0, minute: 35),
      TimeOfDay(hour: 0, minute: 40),
      TimeOfDay(hour: 0, minute: 45),
      TimeOfDay(hour: 0, minute: 50),
      TimeOfDay(hour: 0, minute: 55),
    ];

    return <_TappableLabel>[
      for (final TimeOfDay timeOfDay in minuteMarkerValues)
        _buildTappableLabel(
          textStyle: textStyle,
          selectedValue: selectedValue,
          inner: false,
          value: timeOfDay.minute,
          label: localizations.formatMinute(timeOfDay),
          onTap: () {
            _selectMinute(timeOfDay.minute);
          },
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timePickerTheme = TimePickerTheme.of(context);
    final defaultTheme = theme.useMaterial3
        ? ETTimePickerDefaultsM3(context)
        : ETTimePickerDefaultsM2(context);
    final backgroundColor =
        timePickerTheme.dialBackgroundColor ?? defaultTheme.dialBackgroundColor;
    final dialHandColor =
        timePickerTheme.dialHandColor ?? defaultTheme.dialHandColor;
    final labelStyle =
        timePickerTheme.dialTextStyle ?? defaultTheme.dialTextStyle;
    final dialTextUnselectedColor = MaterialStateProperty.resolveAs<Color>(
      timePickerTheme.dialTextColor ?? defaultTheme.dialTextColor,
      <MaterialState>{},
    );
    final dialTextSelectedColor = MaterialStateProperty.resolveAs<Color>(
      timePickerTheme.dialTextColor ?? defaultTheme.dialTextColor,
      <MaterialState>{MaterialState.selected},
    );
    final resolvedUnselectedLabelStyle =
        labelStyle.copyWith(color: dialTextUnselectedColor);
    final resolvedSelectedLabelStyle =
        labelStyle.copyWith(color: dialTextSelectedColor);
    final dotColor = dialTextSelectedColor;

    List<_TappableLabel> primaryLabels;
    List<_TappableLabel> selectedLabels;
    final int selectedDialValue;
    final double radiusValue;
    switch (widget.hourMinuteMode) {
      case _HourMinuteMode.hour:
        switch (widget.hourDialType) {
          case _HourDialType.twentyFourHour:
          case _HourDialType.twentyFourHourDoubleRing:
            selectedDialValue = widget.selectedTime.hour;
            primaryLabels = _build24HourRing(
              textStyle: resolvedUnselectedLabelStyle,
              selectedValue: selectedDialValue,
            );
            selectedLabels = _build24HourRing(
              textStyle: resolvedSelectedLabelStyle,
              selectedValue: selectedDialValue,
            );
            radiusValue = theme.useMaterial3 ? _radius.value : 1;
          case _HourDialType.twelveHour:
            selectedDialValue = widget.selectedTime.hourOfPeriod;
            primaryLabels = _build12HourRing(
              textStyle: resolvedUnselectedLabelStyle,
              selectedValue: selectedDialValue,
            );
            selectedLabels = _build12HourRing(
              textStyle: resolvedSelectedLabelStyle,
              selectedValue: selectedDialValue,
            );
            radiusValue = 1;
        }
      case _HourMinuteMode.minute:
        selectedDialValue = widget.selectedTime.minute;
        primaryLabels = _buildMinutes(
          textStyle: resolvedUnselectedLabelStyle,
          selectedValue: selectedDialValue,
        );
        selectedLabels = _buildMinutes(
          textStyle: resolvedSelectedLabelStyle,
          selectedValue: selectedDialValue,
        );
        radiusValue = 1;
    }
    painter?.dispose();
    painter = _DialPainter(
      selectedValue: selectedDialValue,
      primaryLabels: primaryLabels,
      selectedLabels: selectedLabels,
      backgroundColor: backgroundColor,
      handColor: dialHandColor,
      handWidth: defaultTheme.handWidth,
      dotColor: dotColor,
      dotRadius: defaultTheme.dotRadius,
      centerRadius: defaultTheme.centerRadius,
      theta: _theta.value,
      radius: radiusValue,
      textDirection: Directionality.of(context),
    );

    return GestureDetector(
      excludeFromSemantics: true,
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      onTapUp: _handleTapUp,
      child: CustomPaint(
        key: const ValueKey<String>("time-picker-dial"),
        painter: painter,
      ),
    );
  }
}

class _TimePickerInput extends StatefulWidget {
  const _TimePickerInput({
    required this.initialSelectedTime,
    required this.errorInvalidText,
    required this.hourLabelText,
    required this.minuteLabelText,
    required this.helpText,
    required this.autofocusHour,
    required this.autofocusMinute,
    this.restorationId,
  });

  /// The time initially selected when the dialog is shown.
  final TimeOfDay initialSelectedTime;

  /// Optionally provide your own validation error text.
  final String? errorInvalidText;

  /// Optionally provide your own hour label text.
  final String? hourLabelText;

  /// Optionally provide your own minute label text.
  final String? minuteLabelText;

  final String helpText;

  final bool? autofocusHour;

  final bool? autofocusMinute;

  /// Restoration ID to save and restore the state of the time picker input
  /// widget.
  ///
  /// If it is non-null, the widget will persist and restore its state
  ///
  /// The state of this widget is persisted in a [RestorationBucket] claimed
  /// from the surrounding [RestorationScope] using the provided restoration ID.
  final String? restorationId;

  @override
  _TimePickerInputState createState() => _TimePickerInputState();
}

class _TimePickerInputState extends State<_TimePickerInput>
    with RestorationMixin {
  late final RestorableTimeOfDay _selectedTime =
      RestorableTimeOfDay(widget.initialSelectedTime);
  final RestorableBool hourHasError = RestorableBool(false);
  final RestorableBool minuteHasError = RestorableBool(false);

  @override
  void dispose() {
    _selectedTime.dispose();
    hourHasError.dispose();
    minuteHasError.dispose();
    super.dispose();
  }

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedTime, "selected_time");
    registerForRestoration(hourHasError, "hour_has_error");
    registerForRestoration(minuteHasError, "minute_has_error");
  }

  int? _parseHour(String? value) {
    if (value == null) {
      return null;
    }

    var newHour = int.tryParse(value);
    if (newHour == null) {
      return null;
    }

    if (MediaQuery.alwaysUse24HourFormatOf(context)) {
      if (newHour >= 0 && newHour < 24) {
        return newHour;
      }
    } else {
      if (newHour > 0 && newHour < 13) {
        if ((_selectedTime.value.period == DayPeriod.pm && newHour != 12) ||
            (_selectedTime.value.period == DayPeriod.am && newHour == 12)) {
          newHour =
              (newHour + TimeOfDay.hoursPerPeriod) % TimeOfDay.hoursPerDay;
        }
        return newHour;
      }
    }
    return null;
  }

  int? _parseMinute(String? value) {
    if (value == null) {
      return null;
    }

    final newMinute = int.tryParse(value);
    if (newMinute == null) {
      return null;
    }

    if (newMinute >= 0 && newMinute < 60) {
      return newMinute;
    }
    return null;
  }

  void _handleHourSavedSubmitted(String? value) {
    final newHour = _parseHour(value);
    if (newHour != null) {
      _selectedTime.value =
          TimeOfDay(hour: newHour, minute: _selectedTime.value.minute);
      _TimePickerModel.setSelectedTime(context, _selectedTime.value);

      FocusScope.of(context).requestFocus();
    }
  }

  void _handleHourChanged(String value) {
    final newHour = _parseHour(value);
    if (newHour != null && value.length == 2) {
      // If a valid hour is typed, move focus to the minute TextField.
      FocusScope.of(context).nextFocus();
    }
  }

  void _handleMinuteSavedSubmitted(String? value) {
    final newMinute = _parseMinute(value);
    if (newMinute != null) {
      _selectedTime.value =
          TimeOfDay(hour: _selectedTime.value.hour, minute: int.parse(value!));
      _TimePickerModel.setSelectedTime(context, _selectedTime.value);
      FocusScope.of(context).unfocus();
    }
  }

  void _handleDayPeriodChanged(TimeOfDay value) {
    _selectedTime.value = value;
    _TimePickerModel.setSelectedTime(context, _selectedTime.value);
  }

  String? _validateHour(String? value) {
    final newHour = _parseHour(value);
    setState(() {
      hourHasError.value = newHour == null;
    });
    // This is used as the validator for the [TextFormField].
    // Returning an empty string allows the field to go into an error state.
    // Returning null means no error in the validation of the entered text.
    return newHour == null ? "" : null;
  }

  String? _validateMinute(String? value) {
    final newMinute = _parseMinute(value);
    setState(() {
      minuteHasError.value = newMinute == null;
    });
    // This is used as the validator for the [TextFormField].
    // Returning an empty string allows the field to go into an error state.
    // Returning null means no error in the validation of the entered text.
    return newMinute == null ? "" : null;
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final timeOfDayFormat = MaterialLocalizations.of(context).timeOfDayFormat(
      alwaysUse24HourFormat: _TimePickerModel.use24HourFormatOf(context),
    );
    final use24HourDials = hourFormat(of: timeOfDayFormat) != HourFormat.h;
    final theme = Theme.of(context);
    final timePickerTheme = _TimePickerModel.themeOf(context);
    final defaultTheme = _TimePickerModel.defaultThemeOf(context);
    final localized = Localized(context);
    final hourMinuteStyle =
        timePickerTheme.hourMinuteTextStyle ?? defaultTheme.hourMinuteTextStyle;

    return Padding(
      padding: _TimePickerModel.useMaterial3Of(context)
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsetsDirectional.only(
              bottom: _TimePickerModel.useMaterial3Of(context) ? 20 : 24,
            ),
            child: Text(
              widget.helpText,
              style: _TimePickerModel.themeOf(context).helpTextStyle ??
                  _TimePickerModel.defaultThemeOf(context).helpTextStyle,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (!use24HourDials &&
                  timeOfDayFormat ==
                      TimeOfDayFormat.a_space_h_colon_mm) ...<Widget>[
                Expanded(
                  // child: Padding(
                  //   padding: const EdgeInsetsDirectional.only(end: 12),
                  child: _DayPeriodControl(
                    onPeriodChanged: _handleDayPeriodChanged,
                  ),
                  // ),
                ),
              ],
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // Hour/minutes should not change positions in RTL locales.
                  textDirection: TextDirection.ltr,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _HourTextField(
                              restorationId: "hour_text_field",
                              selectedTime: _selectedTime.value,
                              style: hourMinuteStyle,
                              autofocus: widget.autofocusHour,
                              inputAction: TextInputAction.next,
                              validator: _validateHour,
                              onSavedSubmitted: _handleHourSavedSubmitted,
                              onChanged: _handleHourChanged,
                              hourLabelText: widget.hourLabelText,
                            ),
                          ),
                          if (!hourHasError.value && !minuteHasError.value)
                            ExcludeSemantics(
                              child: Text(
                                widget.hourLabelText ??
                                    localized.timePickerHourLabel,
                                style: theme.textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                    _StringFragment(timeOfDayFormat: timeOfDayFormat),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _MinuteTextField(
                              restorationId: "minute_text_field",
                              selectedTime: _selectedTime.value,
                              style: hourMinuteStyle,
                              autofocus: widget.autofocusMinute,
                              inputAction: TextInputAction.done,
                              validator: _validateMinute,
                              onSavedSubmitted: _handleMinuteSavedSubmitted,
                              minuteLabelText: widget.minuteLabelText,
                            ),
                          ),
                          if (!hourHasError.value && !minuteHasError.value)
                            ExcludeSemantics(
                              child: Text(
                                widget.minuteLabelText ??
                                    localized.timePickerMinuteLabel,
                                style: theme.textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!use24HourDials &&
                  timeOfDayFormat !=
                      TimeOfDayFormat.a_space_h_colon_mm) ...<Widget>[
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 12),
                  child: _DayPeriodControl(
                    onPeriodChanged: _handleDayPeriodChanged,
                  ),
                ),
              ],
            ],
          ),
          if (hourHasError.value || minuteHasError.value)
            Text(
              widget.errorInvalidText ??
                  MaterialLocalizations.of(context).invalidTimeLabel,
              style: theme.textTheme.bodyMedium!
                  .copyWith(color: theme.colorScheme.error),
            )
          else
            const SizedBox(height: 2),
        ],
      ),
    );
  }
}

class _HourTextField extends StatelessWidget {
  const _HourTextField({
    required this.selectedTime,
    required this.style,
    required this.autofocus,
    required this.inputAction,
    required this.validator,
    required this.onSavedSubmitted,
    required this.onChanged,
    required this.hourLabelText,
    this.restorationId,
  });

  final TimeOfDay selectedTime;
  final TextStyle style;
  final bool? autofocus;
  final TextInputAction inputAction;
  final FormFieldValidator<String> validator;
  final ValueChanged<String?> onSavedSubmitted;
  final ValueChanged<String> onChanged;
  final String? hourLabelText;
  final String? restorationId;

  @override
  Widget build(BuildContext context) => _HourMinuteTextField(
        restorationId: restorationId,
        selectedTime: selectedTime,
        isHour: true,
        autofocus: autofocus,
        inputAction: inputAction,
        style: style,
        semanticHintText: hourLabelText ??
            MaterialLocalizations.of(context).timePickerHourLabel,
        validator: validator,
        onSavedSubmitted: onSavedSubmitted,
        onChanged: onChanged,
      );
}

class _MinuteTextField extends StatelessWidget {
  const _MinuteTextField({
    required this.selectedTime,
    required this.style,
    required this.autofocus,
    required this.inputAction,
    required this.validator,
    required this.onSavedSubmitted,
    required this.minuteLabelText,
    this.restorationId,
  });

  final TimeOfDay selectedTime;
  final TextStyle style;
  final bool? autofocus;
  final TextInputAction inputAction;
  final FormFieldValidator<String> validator;
  final ValueChanged<String?> onSavedSubmitted;
  final String? minuteLabelText;
  final String? restorationId;

  @override
  Widget build(BuildContext context) => _HourMinuteTextField(
        restorationId: restorationId,
        selectedTime: selectedTime,
        isHour: false,
        autofocus: autofocus,
        inputAction: inputAction,
        style: style,
        semanticHintText: minuteLabelText ??
            MaterialLocalizations.of(context).timePickerMinuteLabel,
        validator: validator,
        onSavedSubmitted: onSavedSubmitted,
      );
}

class _HourMinuteTextField extends StatefulWidget {
  const _HourMinuteTextField({
    required this.selectedTime,
    required this.isHour,
    required this.autofocus,
    required this.inputAction,
    required this.style,
    required this.semanticHintText,
    required this.validator,
    required this.onSavedSubmitted,
    this.restorationId,
    this.onChanged,
  });

  final TimeOfDay selectedTime;
  final bool isHour;
  final bool? autofocus;
  final TextInputAction inputAction;
  final TextStyle style;
  final String semanticHintText;
  final FormFieldValidator<String> validator;
  final ValueChanged<String?> onSavedSubmitted;
  final ValueChanged<String>? onChanged;
  final String? restorationId;

  @override
  _HourMinuteTextFieldState createState() => _HourMinuteTextFieldState();
}

class _HourMinuteTextFieldState extends State<_HourMinuteTextField>
    with RestorationMixin {
  final RestorableTextEditingController controller =
      RestorableTextEditingController();
  final RestorableBool controllerHasBeenSet = RestorableBool(false);
  late FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode()
      ..addListener(() {
        setState(() {
          // Rebuild when focus changes.
        });
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only set the text value if it has not been populated with a localized
    // version yet.
    if (!controllerHasBeenSet.value) {
      controllerHasBeenSet.value = true;
      controller.value.text = _formattedValue;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    controllerHasBeenSet.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(controller, "text_editing_controller");
    registerForRestoration(controllerHasBeenSet, "has_controller_been_set");
  }

  String get _formattedValue {
    final alwaysUse24HourFormat = MediaQuery.alwaysUse24HourFormatOf(context);
    final localizations = MaterialLocalizations.of(context);
    return !widget.isHour
        ? localizations.formatMinute(widget.selectedTime)
        : localizations.formatHour(
            widget.selectedTime,
            alwaysUse24HourFormat: alwaysUse24HourFormat,
          );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timePickerTheme = TimePickerTheme.of(context);
    final defaultTheme = theme.useMaterial3
        ? ETTimePickerDefaultsM3(context)
        : ETTimePickerDefaultsM2(context);
    final alwaysUse24HourFormat = MediaQuery.alwaysUse24HourFormatOf(context);

    // final inputDecorationTheme = timePickerTheme.inputDecorationTheme ??
    //     defaultTheme.inputDecorationTheme;
    final effectiveInputTheme = timePickerTheme.inputDecorationTheme ??
        defaultTheme.inputDecorationTheme;
    var inputDecoration = (const InputDecoration())
        .applyDefaults(effectiveInputTheme ?? const InputDecorationThemeData());
    // Remove the hint text when focused because the centered cursor
    // appears odd above the hint text.
    final hintText = focusNode.hasFocus ? null : _formattedValue;

    // Because the fill color is specified in both the inputDecorationTheme and
    // the TimePickerTheme, if there's one in the user's input decoration theme,
    // use that. If not, but there's one in the user's
    // timePickerTheme.hourMinuteColor, use that, and otherwise use the default.
    // We ignore the value in the fillColor of the input decoration in the
    // default theme here, but it's the same as the hourMinuteColor.
    final startingFillColor = timePickerTheme.inputDecorationTheme?.fillColor ??
        timePickerTheme.hourMinuteColor ??
        defaultTheme.hourMinuteColor;
    final Color fillColor;
    if (theme.useMaterial3) {
      fillColor = MaterialStateProperty.resolveAs<Color>(
        startingFillColor,
        <MaterialState>{
          if (focusNode.hasFocus) MaterialState.focused,
          if (focusNode.hasFocus) MaterialState.selected,
        },
      );
    } else {
      fillColor = focusNode.hasFocus ? Colors.transparent : startingFillColor;
    }

    inputDecoration = inputDecoration.copyWith(
      hintText: hintText,
      fillColor: fillColor,
    );

    final states = <MaterialState>{
      if (focusNode.hasFocus) MaterialState.focused,
      if (focusNode.hasFocus) MaterialState.selected,
    };
    final effectiveTextColor = MaterialStateProperty.resolveAs<Color>(
      timePickerTheme.hourMinuteTextColor ?? defaultTheme.hourMinuteTextColor,
      states,
    );
    final effectiveStyle =
        MaterialStateProperty.resolveAs<TextStyle>(widget.style, states)
            .copyWith(color: effectiveTextColor);

    return SizedBox.fromSize(
      size: alwaysUse24HourFormat
          ? defaultTheme.hourMinuteInputSize24Hour
          : defaultTheme.hourMinuteInputSize,
      child: MediaQuery.withNoTextScaling(
        child: UnmanagedRestorationScope(
          bucket: bucket,
          child: Semantics(
            label: widget.semanticHintText,
            child: TextFormField(
              restorationId: "hour_minute_text_form_field",
              autofocus: widget.autofocus ?? false,
              expands: true,
              maxLines: null,
              inputFormatters: <TextInputFormatter>[
                LengthLimitingTextInputFormatter(2),
              ],
              focusNode: focusNode,
              textAlign: TextAlign.center,
              textInputAction: widget.inputAction,
              keyboardType: TextInputType.number,
              style: effectiveStyle,
              controller: controller.value,
              decoration: inputDecoration,
              validator: widget.validator,
              onEditingComplete: () =>
                  widget.onSavedSubmitted(controller.value.text),
              onSaved: widget.onSavedSubmitted,
              onFieldSubmitted: widget.onSavedSubmitted,
              onChanged: widget.onChanged,
            ),
          ),
        ),
      ),
    );
  }
}

// The ETTimePicker widget is constructed so that in the future we could expose
// this as a public API for embedding time pickers into other non-dialog
// widgets, once we're sure we want to support that.

/// A Time Picker widget that can be embedded into another widget.
class ETTimePicker extends StatefulWidget {
  /// Creates a const Material Design time picker.
  const ETTimePicker({
    required this.time,
    required this.onTimeChanged,
    super.key,
    this.helpText,
    this.cancelText,
    this.confirmText,
    this.errorInvalidText,
    this.hourLabelText,
    this.minuteLabelText,
    this.restorationId,
    this.entryMode = TimePickerEntryMode.dial,
    this.orientation,
    this.onEntryModeChanged,
  });

  /// Optionally provide your own text for the help text at the top of the
  /// control.
  ///
  /// If null, the widget uses [MaterialLocalizations.timePickerDialHelpText]
  /// when the [entryMode] is [TimePickerEntryMode.dial], and
  /// [MaterialLocalizations.timePickerInputHelpText] when the [entryMode] is
  /// [TimePickerEntryMode.input].
  final String? helpText;

  /// Optionally provide your own text for the cancel button.
  ///
  /// If null, the button uses [MaterialLocalizations.cancelButtonLabel].
  final String? cancelText;

  /// Optionally provide your own text for the confirm button.
  ///
  /// If null, the button uses [MaterialLocalizations.okButtonLabel].
  final String? confirmText;

  /// Optionally provide your own validation error text.
  final String? errorInvalidText;

  /// Optionally provide your own hour label text.
  final String? hourLabelText;

  /// Optionally provide your own minute label text.
  final String? minuteLabelText;

  /// Restoration ID to save and restore the state of the (ETTimePickerDialog).
  ///
  /// If it is non-null, the time picker will persist and restore the
  /// dialog's state.
  ///
  /// The state of this widget is persisted in a [RestorationBucket] claimed
  /// from the surrounding [RestorationScope] using the provided restoration ID.
  ///
  /// See also:
  ///
  ///  * [RestorationManager], which explains how state restoration works in
  ///    Flutter.
  final String? restorationId;

  /// The initial entry mode for the picker. Whether it's text input or a dial.
  final TimePickerEntryMode entryMode;

  /// The currently selected time of day.
  final TimeOfDay time;

  final ValueChanged<TimeOfDay>? onTimeChanged;

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
  State<ETTimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<ETTimePicker> with RestorationMixin {
  Timer? _vibrateTimer;
  late MaterialLocalizations localizations;
  late Localized localized;
  final RestorableEnum<_HourMinuteMode> _hourMinuteMode =
      RestorableEnum<_HourMinuteMode>(
    _HourMinuteMode.hour,
    values: _HourMinuteMode.values,
  );
  final RestorableEnumN<_HourMinuteMode> _lastModeAnnounced =
      RestorableEnumN<_HourMinuteMode>(null, values: _HourMinuteMode.values);
  final RestorableBoolN _autofocusHour = RestorableBoolN(null);
  final RestorableBoolN _autofocusMinute = RestorableBoolN(null);
  final RestorableBool _announcedInitialTime = RestorableBool(false);
  late final RestorableEnumN<Orientation> _orientation =
      RestorableEnumN<Orientation>(
    widget.orientation,
    values: Orientation.values,
  );
  RestorableTimeOfDay get selectedTime => _selectedTime;
  late final RestorableTimeOfDay _selectedTime =
      RestorableTimeOfDay(widget.time);

  @override
  void dispose() {
    _vibrateTimer?.cancel();
    _vibrateTimer = null;
    _orientation.dispose();
    _selectedTime.dispose();
    _hourMinuteMode.dispose();
    _lastModeAnnounced.dispose();
    _autofocusHour.dispose();
    _autofocusMinute.dispose();
    _announcedInitialTime.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations = MaterialLocalizations.of(context);
    localized = Localized(context);
    _announceInitialTimeOnce();
    _announceModeOnce();
  }

  @override
  void didUpdateWidget(ETTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orientation != widget.orientation) {
      _orientation.value = widget.orientation;
    }
    if (oldWidget.time != widget.time) {
      _selectedTime.value = widget.time;
    }
  }

  void _setEntryMode(TimePickerEntryMode mode) {
    widget.onEntryModeChanged?.call(mode);
  }

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_hourMinuteMode, "hour_minute_mode");
    registerForRestoration(_lastModeAnnounced, "last_mode_announced");
    registerForRestoration(_autofocusHour, "autofocus_hour");
    registerForRestoration(_autofocusMinute, "autofocus_minute");
    registerForRestoration(_announcedInitialTime, "announced_initial_time");
    registerForRestoration(_selectedTime, "selected_time");
    registerForRestoration(_orientation, "orientation");
  }

  void _vibrate() {
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        _vibrateTimer?.cancel();
        _vibrateTimer = Timer(_kVibrateCommitDelay, () {
          HapticFeedback.vibrate();
          _vibrateTimer = null;
        });
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        break;
    }
  }

  void _handleHourMinuteModeChanged(_HourMinuteMode mode) {
    _vibrate();
    setState(() {
      _hourMinuteMode.value = mode;
      _announceModeOnce();
    });
  }

  void _handleEntryModeToggle() {
    setState(() {
      var newMode = widget.entryMode;
      switch (widget.entryMode) {
        case TimePickerEntryMode.dial:
          newMode = TimePickerEntryMode.input;
        case TimePickerEntryMode.input:
          _autofocusHour.value = false;
          _autofocusMinute.value = false;
          newMode = TimePickerEntryMode.dial;
        case TimePickerEntryMode.dialOnly:
        case TimePickerEntryMode.inputOnly:
          FlutterError("Can not change entry mode from ${widget.entryMode}");
      }
      _setEntryMode(newMode);
    });
  }

  void _announceModeOnce() {
    if (_lastModeAnnounced.value == _hourMinuteMode.value) {
      // Already announced it.
      return;
    }

    switch (_hourMinuteMode.value) {
      case _HourMinuteMode.hour:
        _announceToAccessibility(
          context,
          localizations.timePickerHourModeAnnouncement,
        );
      case _HourMinuteMode.minute:
        _announceToAccessibility(
          context,
          localizations.timePickerMinuteModeAnnouncement,
        );
    }
    _lastModeAnnounced.value = _hourMinuteMode.value;
  }

  void _announceInitialTimeOnce() {
    if (_announcedInitialTime.value) {
      return;
    }

    final localizations = MaterialLocalizations.of(context);
    _announceToAccessibility(
      context,
      localizations.formatTimeOfDay(
        _selectedTime.value,
        alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
      ),
    );
    _announcedInitialTime.value = true;
  }

  void _handleTimeChanged(TimeOfDay value) {
    _vibrate();
    setState(() {
      _selectedTime.value = value;
      widget.onTimeChanged?.call(value);
    });
  }

  void _handleHourDoubleTapped() {
    _autofocusHour.value = true;
    _handleEntryModeToggle();
  }

  void _handleMinuteDoubleTapped() {
    _autofocusMinute.value = true;
    _handleEntryModeToggle();
  }

  void _handleHourSelected() {
    setState(() {
      _hourMinuteMode.value = _HourMinuteMode.minute;
    });
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final timeOfDayFormat = localizations.timeOfDayFormat(
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
    final theme = Theme.of(context);
    final defaultTheme = theme.useMaterial3
        ? ETTimePickerDefaultsM3(context)
        : ETTimePickerDefaultsM2(context);
    final orientation = _orientation.value ?? MediaQuery.orientationOf(context);
    final timeOfDayHour = hourFormat(of: timeOfDayFormat);
    final _HourDialType hourMode;
    switch (timeOfDayHour) {
      case HourFormat.HH:
      case HourFormat.H:
        hourMode = theme.useMaterial3
            ? _HourDialType.twentyFourHourDoubleRing
            : _HourDialType.twentyFourHour;
      case HourFormat.h:
        hourMode = _HourDialType.twelveHour;
    }

    final String helpText;
    final Widget picker;
    switch (widget.entryMode) {
      case TimePickerEntryMode.dial:
      case TimePickerEntryMode.dialOnly:
        helpText = widget.helpText ??
            (theme.useMaterial3
                ? localized.timePickerDialHelpText
                : localized.timePickerDialHelpText.toUpperCase());

        final EdgeInsetsGeometry dialPadding;
        switch (orientation) {
          case Orientation.portrait:
            dialPadding = const EdgeInsets.only(left: 12, right: 12, top: 36);
          case Orientation.landscape:
            switch (theme.materialTapTargetSize) {
              case MaterialTapTargetSize.padded:
                dialPadding = const EdgeInsetsDirectional.only(start: 64);
              case MaterialTapTargetSize.shrinkWrap:
                dialPadding = const EdgeInsetsDirectional.only(start: 64);
            }
        }
        final Widget dial = Padding(
          padding: dialPadding,
          child: ExcludeSemantics(
            child: SizedBox.fromSize(
              size: defaultTheme.dialSize,
              child: AspectRatio(
                aspectRatio: 1,
                child: _Dial(
                  hourMinuteMode: _hourMinuteMode.value,
                  hourDialType: hourMode,
                  selectedTime: _selectedTime.value,
                  onChanged: _handleTimeChanged,
                  onHourSelected: _handleHourSelected,
                ),
              ),
            ),
          ),
        );

        switch (orientation) {
          case Orientation.portrait:
            picker = Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: theme.useMaterial3 ? 0 : 16,
                  ),
                  child: _TimePickerHeader(helpText: helpText),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Dial grows and shrinks with the available space.
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: theme.useMaterial3 ? 0 : 16,
                          ),
                          child: dial,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          case Orientation.landscape:
            picker = Column(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: theme.useMaterial3 ? 0 : 16,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _TimePickerHeader(helpText: helpText),
                        Expanded(child: dial),
                      ],
                    ),
                  ),
                ),
              ],
            );
        }
      case TimePickerEntryMode.input:
      case TimePickerEntryMode.inputOnly:
        final helpText = widget.helpText ??
            (theme.useMaterial3
                ? localized.timePickerInputHelpText
                : localized.timePickerInputHelpText.toUpperCase());

        picker = Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _TimePickerInput(
              initialSelectedTime: _selectedTime.value,
              errorInvalidText: widget.errorInvalidText,
              hourLabelText: widget.hourLabelText,
              minuteLabelText: widget.minuteLabelText,
              helpText: helpText,
              autofocusHour: _autofocusHour.value,
              autofocusMinute: _autofocusMinute.value,
              restorationId: "time_picker_input",
            ),
          ],
        );
    }
    return _TimePickerModel(
      entryMode: widget.entryMode,
      selectedTime: _selectedTime.value,
      hourMinuteMode: _hourMinuteMode.value,
      orientation: orientation,
      onHourMinuteModeChanged: _handleHourMinuteModeChanged,
      onHourDoubleTapped: _handleHourDoubleTapped,
      onMinuteDoubleTapped: _handleMinuteDoubleTapped,
      hourDialType: hourMode,
      onSelectedTimeChanged: _handleTimeChanged,
      useMaterial3: theme.useMaterial3,
      use24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
      theme: TimePickerTheme.of(context),
      defaultTheme: defaultTheme,
      child: picker,
    );
  }
}

void _announceToAccessibility(BuildContext context, String message) {
  SemanticsService.announce(message, Directionality.of(context));
}

// END GENERATED TOKEN PROPERTIES - TimePicker

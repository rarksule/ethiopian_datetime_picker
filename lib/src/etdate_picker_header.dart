import "package:ethiopian_datetime/ethiopian_datetime.dart";
import "package:ethiopian_datetime_picker/src/string_text.dart";
import "package:flutter/material.dart";

/// Re-usable widget that displays the selected date (in large font) and the
/// help text above it.
///
/// These types include:
///
/// * Single Date picker with calendar mode.
/// * Single Date picker with text input mode.
/// * Date Range picker with text input mode.
///
/// [helpText], [orientation], (icon), (onIconPressed) are required and must be
/// non-null.
class ETDatePickerHeader extends StatelessWidget {
  /// Creates a header for use in a date picker dialog.
  const ETDatePickerHeader({
    required this.helpText,
    required this.titleText,
    required this.titleStyle,
    required this.orientation,
    super.key,
    this.titleSemanticsLabel,
    this.isShort = false,
    this.entryModeButton,
  });

  static const double _datePickerHeaderLandscapeWidth = 152;
  static const double _datePickerHeaderPortraitHeight = 120;
  static const double _headerPaddingLandscape = 16;

  /// The text that is displayed at the top of the header.
  ///
  /// This is used to indicate to the user what they are selecting a date for.
  final String helpText;

  /// The text that is displayed at the center of the header.
  final String titleText;

  /// The semantic label associated with the [titleText].
  final String? titleSemanticsLabel;

  /// The [TextStyle] that the title text is displayed with.
  final TextStyle? titleStyle;

  /// The orientation is used to decide how to layout its children.
  final Orientation orientation;

  /// Indicates the header is being displayed in a shorter/narrower context.
  ///
  /// This will be used to tighten up the space between the help text and date
  /// text if `true`. Additionally, it will use a smaller typography style if
  /// `true`.
  ///
  /// This is necessary for displaying the manual input mode in
  /// landscape orientation, in order to account for the keyboard height.
  final bool isShort;

  final Widget? entryModeButton;

  @override
  Widget build(BuildContext context) {
    final themeData = DatePickerTheme.of(context);
    final defaults = DatePickerTheme.defaults(context);
    final backgroundColor =
        themeData.headerBackgroundColor ?? defaults.headerBackgroundColor;
    final foregroundColor =
        themeData.headerForegroundColor ?? defaults.headerForegroundColor;
    final helpStyle =
        (themeData.headerHelpStyle ?? defaults.headerHelpStyle)?.copyWith(
      color: foregroundColor,
    );

    final help = Text(
      helpText,
      style: helpStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    final title = Text(
      titleText,
      semanticsLabel: titleSemanticsLabel ?? titleText,
      style: titleStyle,
      maxLines: orientation == Orientation.portrait ? 1 : 2,
      overflow: TextOverflow.ellipsis,
    );

    switch (orientation) {
      case Orientation.portrait:
        return SizedBox(
          height: _datePickerHeaderPortraitHeight,
          child: Material(
            color: backgroundColor,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(
                start: 24,
                end: 12,
                bottom: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 16),
                  help,
                  const Flexible(child: SizedBox(height: 38)),
                  Row(
                    children: <Widget>[
                      Expanded(child: title),
                      if (entryModeButton != null) entryModeButton!,
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      case Orientation.landscape:
        return SizedBox(
          width: _datePickerHeaderLandscapeWidth,
          child: Material(
            color: backgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _headerPaddingLandscape,
                  ),
                  child: help,
                ),
                SizedBox(height: isShort ? 16 : 56),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _headerPaddingLandscape,
                    ),
                    child: title,
                  ),
                ),
                if (entryModeButton != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: entryModeButton,
                  ),
              ],
            ),
          ),
        );
    }
  }
}

/// Builds widgets showing abbreviated days of week. The first widget in the
/// returned list corresponds to the first day of week for the current locale.
///
/// Examples:
///
///     ┌ Sunday is the first day of week in the US (en_US)
///     |
///     S M T W T F S  ← the returned list contains these widgets
///     _ _ _ _ _ 1 2
///     3 4 5 6 7 8 9
///
///     ┌ But it's Monday in the UK (en_GB)
///     |
///     M T W T F S S  ← the returned list contains these widgets
///     _ _ _ _ 1 2 3
///     4 5 6 7 8 9 10
///
List<Widget> getDayHeaders(TextStyle? headerStyle, Localized localized) {
  final result = <Widget>[];
  for (var i = 0;
      result.length < ETDateTime.daysPerWeek;
      i = (i + 1) % ETDateTime.daysPerWeek) {
    final weekday = localized.narrowWeekdays[i];
    result.add(
      ExcludeSemantics(
        child: Center(child: Text(weekday, style: headerStyle)),
      ),
    );
  }
  return result;
}

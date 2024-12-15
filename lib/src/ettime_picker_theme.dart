// An abstract base class for the M2 and M3 defaults below, so that their return
// types can be non-nullable.
import "package:flutter/material.dart";

abstract class ETTimePickerDefaults extends TimePickerThemeData {
  @override
  Color get backgroundColor;

  @override
  ButtonStyle get cancelButtonStyle;

  @override
  ButtonStyle get confirmButtonStyle;

  @override
  BorderSide get dayPeriodBorderSide;

  @override
  Color get dayPeriodColor;

  @override
  OutlinedBorder get dayPeriodShape;

  Size get dayPeriodInputSize;
  Size get dayPeriodLandscapeSize;
  Size get dayPeriodPortraitSize;

  @override
  Color get dayPeriodTextColor;

  @override
  TextStyle get dayPeriodTextStyle;

  @override
  Color get dialBackgroundColor;

  @override
  Color get dialHandColor;

  // Sizes that are generated from the tokens, but these aren't ones we're ready
  // to expose in the theme.
  Size get dialSize;
  double get handWidth;
  double get dotRadius;
  double get centerRadius;

  @override
  Color get dialTextColor;

  @override
  TextStyle get dialTextStyle;

  @override
  double get elevation;

  @override
  Color get entryModeIconColor;

  @override
  TextStyle get helpTextStyle;

  @override
  Color get hourMinuteColor;

  @override
  ShapeBorder get hourMinuteShape;

  Size get hourMinuteSize;
  Size get hourMinuteSize24Hour;
  Size get hourMinuteInputSize;
  Size get hourMinuteInputSize24Hour;

  @override
  Color get hourMinuteTextColor;

  @override
  TextStyle get hourMinuteTextStyle;

  @override
  InputDecorationTheme get inputDecorationTheme;

  @override
  EdgeInsetsGeometry get padding;

  @override
  ShapeBorder get shape;
}

// These theme defaults are not auto-generated: they match the values for the
// Material 2 spec, which are not expected to change.
class ETTimePickerDefaultsM2 extends ETTimePickerDefaults {
  ETTimePickerDefaultsM2(this.context) : super();

  final BuildContext context;

  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;
  static const OutlinedBorder _kDefaultShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(4)),
  );

  @override
  Color get backgroundColor => _colors.surface;

  @override
  ButtonStyle get cancelButtonStyle => TextButton.styleFrom();

  @override
  ButtonStyle get confirmButtonStyle => TextButton.styleFrom();

  @override
  BorderSide get dayPeriodBorderSide => BorderSide(
        color: Color.alphaBlend(
          _colors.onSurface.withOpacity(0.38),
          _colors.surface,
        ),
      );

  @override
  Color get dayPeriodColor =>
      MaterialStateColor.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return _colors.primary
              .withOpacity(_colors.brightness == Brightness.dark ? 0.24 : 0.12);
        }
        // The unselected day period should match the overall picker dialog color.
        // Making it transparent enables that without being redundant and allows
        // the optional elevation overlay for dark mode to be visible.
        return Colors.transparent;
      });

  @override
  OutlinedBorder get dayPeriodShape => _kDefaultShape;

  @override
  Size get dayPeriodPortraitSize => const Size(52, 80);

  @override
  Size get dayPeriodLandscapeSize => const Size(0, 40);

  @override
  Size get dayPeriodInputSize => const Size(52, 70);

  @override
  Color get dayPeriodTextColor => MaterialStateColor.resolveWith(
        (states) => states.contains(MaterialState.selected)
            ? _colors.primary
            : _colors.onSurface.withOpacity(0.60),
      );

  @override
  TextStyle get dayPeriodTextStyle =>
      _textTheme.titleMedium!.copyWith(color: dayPeriodTextColor);

  @override
  Color get dialBackgroundColor => _colors.onSurface
      .withOpacity(_colors.brightness == Brightness.dark ? 0.12 : 0.08);

  @override
  Color get dialHandColor => _colors.primary;

  @override
  Size get dialSize => const Size.square(280);

  @override
  double get handWidth => 2;

  @override
  double get dotRadius => 22;

  @override
  double get centerRadius => 4;

  @override
  Color get dialTextColor =>
      MaterialStateColor.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return _colors.surface;
        }
        return _colors.onSurface;
      });

  @override
  TextStyle get dialTextStyle => _textTheme.bodyLarge!;

  @override
  double get elevation => 6;

  @override
  Color get entryModeIconColor => _colors.onSurface
      .withOpacity(_colors.brightness == Brightness.dark ? 1.0 : 0.6);

  @override
  TextStyle get helpTextStyle => _textTheme.labelSmall!;

  @override
  Color get hourMinuteColor => MaterialStateColor.resolveWith(
        (states) => states.contains(MaterialState.selected)
            ? _colors.primary.withOpacity(
                _colors.brightness == Brightness.dark ? 0.24 : 0.12,
              )
            : _colors.onSurface.withOpacity(0.12),
      );

  @override
  ShapeBorder get hourMinuteShape => _kDefaultShape;

  @override
  Size get hourMinuteSize => const Size(96, 80);

  @override
  Size get hourMinuteSize24Hour => const Size(114, 80);

  @override
  Size get hourMinuteInputSize => const Size(96, 70);

  @override
  Size get hourMinuteInputSize24Hour => const Size(114, 70);

  @override
  Color get hourMinuteTextColor => MaterialStateColor.resolveWith(
        (states) => states.contains(MaterialState.selected)
            ? _colors.primary
            : _colors.onSurface,
      );

  @override
  TextStyle get hourMinuteTextStyle => _textTheme.displayMedium!;

  Color get _hourMinuteInputColor => MaterialStateColor.resolveWith(
        (states) => states.contains(MaterialState.selected)
            ? Colors.transparent
            : _colors.onSurface.withOpacity(0.12),
      );

  @override
  InputDecorationTheme get inputDecorationTheme => InputDecorationTheme(
        contentPadding: EdgeInsets.zero,
        filled: true,
        fillColor: _hourMinuteInputColor,
        focusColor: Colors.transparent,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _colors.error, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _colors.primary, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _colors.error, width: 2),
        ),
        hintStyle: hourMinuteTextStyle.copyWith(
          color: _colors.onSurface.withOpacity(0.36),
        ),
        errorStyle: const TextStyle(fontSize: 0, height: 0),
      );

  @override
  EdgeInsetsGeometry get padding => const EdgeInsets.fromLTRB(8, 18, 8, 8);

  @override
  ShapeBorder get shape => _kDefaultShape;
}

// BEGIN GENERATED TOKEN PROPERTIES - TimePicker

// Do not edit by hand. The code between the "BEGIN GENERATED" and
// "END GENERATED" comments are generated from data in the Material
// Design token database by the script:
//   dev/tools/gen_defaults/bin/gen_defaults.dart.

class ETTimePickerDefaultsM3 extends ETTimePickerDefaults {
  ETTimePickerDefaultsM3(this.context);

  final BuildContext context;

  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  Color get backgroundColor => _colors.surface;

  @override
  ButtonStyle get cancelButtonStyle => TextButton.styleFrom();

  @override
  ButtonStyle get confirmButtonStyle => TextButton.styleFrom();

  @override
  BorderSide get dayPeriodBorderSide => BorderSide(color: _colors.outline);

  @override
  Color get dayPeriodColor =>
      MaterialStateColor.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return _colors.tertiaryContainer;
        }
        // The unselected day period should match the overall picker dialog color.
        // Making it transparent enables that without being redundant and allows
        // the optional elevation overlay for dark mode to be visible.
        return Colors.transparent;
      });

  @override
  OutlinedBorder get dayPeriodShape => const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ).copyWith(side: dayPeriodBorderSide);

  @override
  Size get dayPeriodPortraitSize => const Size(52, 80);

  @override
  Size get dayPeriodLandscapeSize => const Size(216, 38);

  @override
  // Input size is eight pixels smaller than the portrait size in the spec,
  // but there's not token for it yet.
  Size get dayPeriodInputSize =>
      Size(dayPeriodPortraitSize.width, dayPeriodPortraitSize.height - 8);

  @override
  Color get dayPeriodTextColor =>
      MaterialStateColor.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          if (states.contains(MaterialState.focused)) {
            return _colors.onTertiaryContainer;
          }
          if (states.contains(MaterialState.hovered)) {
            return _colors.onTertiaryContainer;
          }
          if (states.contains(MaterialState.pressed)) {
            return _colors.onTertiaryContainer;
          }
          return _colors.onTertiaryContainer;
        }
        if (states.contains(MaterialState.focused)) {
          return _colors.onSurfaceVariant;
        }
        if (states.contains(MaterialState.hovered)) {
          return _colors.onSurfaceVariant;
        }
        if (states.contains(MaterialState.pressed)) {
          return _colors.onSurfaceVariant;
        }
        return _colors.onSurfaceVariant;
      });

  @override
  TextStyle get dayPeriodTextStyle =>
      _textTheme.titleMedium!.copyWith(color: dayPeriodTextColor);

  @override
  Color get dialBackgroundColor => _colors.surfaceVariant;

  @override
  Color get dialHandColor => _colors.primary;

  @override
  Size get dialSize => const Size.square(256);

  @override
  double get handWidth => const Size(2, double.infinity).width;

  @override
  double get dotRadius => const Size.square(48).width / 2;

  @override
  double get centerRadius => const Size.square(8).width / 2;

  @override
  Color get dialTextColor =>
      MaterialStateColor.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return _colors.onPrimary;
        }
        return _colors.onSurface;
      });

  @override
  TextStyle get dialTextStyle => _textTheme.bodyLarge!;

  @override
  double get elevation => 6;

  @override
  Color get entryModeIconColor => _colors.onSurface;

  @override
  TextStyle get helpTextStyle =>
      MaterialStateTextStyle.resolveWith((states) {
        final textStyle = _textTheme.labelMedium!;
        return textStyle.copyWith(color: _colors.onSurfaceVariant);
      });

  @override
  EdgeInsetsGeometry get padding => const EdgeInsets.all(24);

  @override
  Color get hourMinuteColor =>
      MaterialStateColor.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          var overlayColor = _colors.primaryContainer;
          if (states.contains(MaterialState.pressed)) {
            overlayColor = _colors.onPrimaryContainer;
          } else if (states.contains(MaterialState.hovered)) {
            const hoverOpacity = 0.08;
            overlayColor = _colors.onPrimaryContainer.withOpacity(hoverOpacity);
          } else if (states.contains(MaterialState.focused)) {
            const focusOpacity = 0.12;
            overlayColor = _colors.onPrimaryContainer.withOpacity(focusOpacity);
          }
          return Color.alphaBlend(overlayColor, _colors.primaryContainer);
        } else {
          var overlayColor = _colors.surfaceVariant;
          if (states.contains(MaterialState.pressed)) {
            overlayColor = _colors.onSurface;
          } else if (states.contains(MaterialState.hovered)) {
            const hoverOpacity = 0.08;
            overlayColor = _colors.onSurface.withOpacity(hoverOpacity);
          } else if (states.contains(MaterialState.focused)) {
            const focusOpacity = 0.12;
            overlayColor = _colors.onSurface.withOpacity(focusOpacity);
          }
          return Color.alphaBlend(overlayColor, _colors.surfaceVariant);
        }
      });

  @override
  ShapeBorder get hourMinuteShape => const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      );

  @override
  Size get hourMinuteSize => const Size(96, 80);

  @override
  Size get hourMinuteSize24Hour =>
      Size(const Size(114, double.infinity).width, hourMinuteSize.height);

  @override
  // Input size is eight pixels smaller than the regular size in the spec, but
  // there's not token for it yet.
  Size get hourMinuteInputSize =>
      Size(hourMinuteSize.width, hourMinuteSize.height - 8);

  @override
  // Input size is eight pixels smaller than the regular size in the spec, but
  // there's not token for it yet.
  Size get hourMinuteInputSize24Hour =>
      Size(hourMinuteSize24Hour.width, hourMinuteSize24Hour.height - 8);

  @override
  Color get hourMinuteTextColor => MaterialStateColor.resolveWith(
        (states) => _hourMinuteTextColor.resolve(states),
      );

  MaterialStateProperty<Color> get _hourMinuteTextColor =>
      MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          if (states.contains(MaterialState.pressed)) {
            return _colors.onPrimaryContainer;
          }
          if (states.contains(MaterialState.hovered)) {
            return _colors.onPrimaryContainer;
          }
          if (states.contains(MaterialState.focused)) {
            return _colors.onPrimaryContainer;
          }
          return _colors.onPrimaryContainer;
        } else {
          // unselected
          if (states.contains(MaterialState.pressed)) {
            return _colors.onSurface;
          }
          if (states.contains(MaterialState.hovered)) {
            return _colors.onSurface;
          }
          if (states.contains(MaterialState.focused)) {
            return _colors.onSurface;
          }
          return _colors.onSurface;
        }
      });

  @override
  TextStyle get hourMinuteTextStyle => MaterialStateTextStyle.resolveWith(
        (states) => _textTheme.displayMedium!
            .copyWith(color: _hourMinuteTextColor.resolve(states)),
      );

  @override
  InputDecorationTheme get inputDecorationTheme {
    // This is NOT correct, but there's no token for
    // 'time-input.container.shape', so this is using the radius from the shape
    // for the hour/minute selector. It's a BorderRadiusGeometry, so we have to
    // resolve it before we can use it.
    final selectorRadius = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ).borderRadius.resolve(Directionality.of(context));
    return InputDecorationTheme(
      contentPadding: EdgeInsets.zero,
      filled: true,
      // This should be derived from a token, but there isn't one for 'time-input'.
      fillColor: hourMinuteColor,
      // This should be derived from a token, but there isn't one for 'time-input'.
      focusColor: _colors.primaryContainer,
      enabledBorder: OutlineInputBorder(
        borderRadius: selectorRadius,
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: selectorRadius,
        borderSide: BorderSide(color: _colors.error, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: selectorRadius,
        borderSide: BorderSide(color: _colors.primary, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: selectorRadius,
        borderSide: BorderSide(color: _colors.error, width: 2),
      ),
      hintStyle: hourMinuteTextStyle.copyWith(
        color: _colors.onSurface.withOpacity(0.36),
      ),
      errorStyle: const TextStyle(fontSize: 0, height: 0),
    );
  }

  @override
  ShapeBorder get shape => const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(28)),
      );
}

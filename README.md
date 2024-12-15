# <img src="https://github.com/rarksule/ethiopian_datetime_picker/raw/main/assets/logo.png" width="36px"> Ethiopian (Amharic,Somali,Oromiffa,Tigrigna) Date & Time Picker for Flutter

[![pub package](https://img.shields.io/pub/v/ethiopian_datetime_picker.svg?color=%23e67e22&label=pub&logo=ethiopian_datetime_picker)](https://pub.dartlang.org/packages/ethiopian_datetime_picker)
[![APK](https://img.shields.io/badge/APK-Demo-brightgreen.svg)](/sample.apk)

![Ethiopian DateTime Picker Banner](https://github.com/rarksule/ethiopian_datetime_picker/raw/main/assets/banner.png)

## <img src="https://github.com/rarksule/ethiopian_datetime_picker/raw/main/assets/Telescope.webp" width="36px"> Overview

A Ethiopian Date & Time picker inspired by Material Design's DateTime picker, built on the [ethiopian_datetime](https://pub.dev/packages/ethiopian_datetime) library. It offers full support for the Ethiopian calendar and is highly customizable, including compatibility with Material 3.

Additionally, it supports multiple languages, including Amharic,Oromiffa,Afsomali,tigrigna and custom locales, all while ensuring seamless integration with Flutter and maintaining Material Design standards.

## <img src="https://github.com/rarksule/ethiopian_datetime_picker/raw/main/assets/Rocket.png" width="36px">️ Features

- 🌟 Fully supports Ethiopian calendar
- 🛠 Highly customizable
- 💻 Supports Material 3
- 🌎 Multi-language support: Amharic,Oromiffa,Afsomai,Tigrigna and custom locales
- 📱 Compatible with Material Design standards
- Easy Documentation similar to Flutters Documentation

## <img src="https://github.com/rarksule/ethiopian_datetime_picker/raw/main/assets/Fire.png" width="36px">️ Getting Started

To use the Ethiopian DateTime Picker, add the package to your `pubspec.yaml`:

```yaml
dependencies:
  ethiopian_datetime_picker: <latest_version>
```

Then, import it in your Dart code:

```dart
import 'package:ethiopian_datetime_picker/ethiopian_datetime_picker.dart';
```

## <img src="https://github.com/rarksule/ethiopian_datetime_picker/raw/main/assets/Comet.png" width="36px">️ Usage Examples

### 1. Ethiopian Date Picker

<p align="center">
  <img src="https://github.com/rarksule/ethiopian_datetime_picker/raw/main/assets/screenshots/date_picker.png" alt="Screenshot 1" width="150" />
</p>

```dart
ETDateTime? picked = await showETDatePicker(
  context: context,
  initialDate: ETDateTime.now(),
  firstDate: ETDateTime(2010),
  lastDate: ETDateTime(2030),
  initialEntryMode:DatePickerEntryMode.calendarOnly,
  initialDatePickerMode: DatePickerMode.year,
);
var label = picked.formatFullDate();
```
for more on [ETDateTime] check ethiopian_datetime_picker package

### 2. Ethiopian Time Picker

<p align="center">
  <img src="https://github.com/rarksule/ethiopian_datetime_picker/raw/main/assets/screenshots/time_picker.png" alt="Screenshot 1" width="200" />
  <img src="https://github.com/rarksule/ethiopian_datetime_picker/raw/main/assets/screenshots/input_time_picker.png" alt="Screenshot 2" width="200" />
</p>

```dart
var picked = await showTimePicker(
  context: context,
  initialTime: TimeOfDay.fromDateTime(ETDateTime.now()),
  initialEntryMode: TimePickerEntryMode.input,
);
if (picked != null) String label = picked.toString();
```

### 3. Modal Bottom Sheet with Ethiopian Cupertino Date Picker

<p align="center">
  <img src="https://github.com/rarksule/ethiopian_datetime_picker/raw/main/assets/screenshots/cupertino_date_picker.png" alt="Screenshot 1" width="200" />
</p>

```dart
ETdateTime? pickedDate = await showModalBottomSheet<ETdateTime>(
  context: context,
  builder: (context) {
    ETdateTime? tempPickedDate;
    return Container(
      height: 250,
      child: Column(
        children: <Widget>[
          Container(
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: <Widget>[
                CupertinoButton(
                  child: Text(
                    'ሰርዝ',
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                CupertinoButton(
                  child: Text(
                    'እሺ',
                  ),
                  onPressed: () {
                    print(tempPickedDate)፤
                    Navigator.of(context).pop(
                        tempPickedDate ?? ETdateTime.now());
                  },
                ),
              ],
            ),
          ),
          Divider(
            height: 0,
            thickness: 1,
          ),
          Expanded(
            child: Container(
              child: CupertinoETDatePicker(
                initialDateTime: ETdateTime.now(),
                mode:
                    CupertinoDatePickerMode.time,
                onDateTimeChanged: (ETdateTime dateTime) {
                  tempPickedDate = dateTime;
                },
              ),
            ),
          ),
        ],
      ),
    );
  },

if (pickedDate != null) {
   String label = '${pickedDate.toJalaliDateTime()}';
}
```

### 4. Ethiopian Date Range Picker

<p align="center">
  <img src="https://github.com/rarksule/ethiopian_datetime_picker/raw/main/assets/screenshots/range_picker.png" alt="Screenshot 1" width="200" />
  <img src="https://github.com/rarksule/ethiopian_datetime_picker/raw/main/assets/screenshots/input_range_picker.png" alt="Screenshot 2" width="200" />
</p>

```dart
var picked = await showETDateRangePicker(
  context: context,
  initialDateRange: DateTimeRange(
    start: ETdateTime(2018, 1, 2),
    end: ETdateTime(2018, 1, 10),
  ),
  firstDate: ETdateTime(2000, 8),
  lastDate: ETdateTime(2040, 9),
  initialDate: ETdateTime.now(),
);
String  label =
      "${picked?.start? ?? ""} ${picked?.end? ?? ""}";
```

### 5. Customizing Date Picker Styles

You can customize the styles of the `DateETTimePicker` and `CupertinoETDatePicker` using the `DatePickerTheme` within your app's `ThemeData`. Additionally, you can apply specific styles by wrapping the date picker with `Theme` in the builder.

#### Example for Ethiopian Date Picker

Add the `DatePickerTheme` to your `ThemeData`:

```dart
return MaterialApp(
  theme: ThemeData(
    // Other theme properties...
    datePickerTheme: DatePickerTheme(
      backgroundColor: Colors.white, // Background color of the date picker
      primaryColor: Colors.teal, // Primary color for the date picker
      textColor: Colors.black, // Text color
      // Customize more properties as needed
    ),
  ),
  // ...
);
```

#### Customizing Ethiopian Date Picker with Theme in Builder

You can also customize the Ethiopian date picker on a per-instance basis by wrapping it with a `Theme` in the builder:

```dart
ETdateTime? picked = await showETDatePicker(
  context: context,
  initialDate: ETdateTime.now(),
  firstDate: ETdateTime(2000, 8),
  lastDate: ETdateTime(2030, 9),
  builder: (context, child) {
    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: Colors.teal, // Override primary color
        accentColor: Colors.amber, // Override accent color
        // Add more customization here
      ),
      child: child!,
    );
  },
);
```

#### Example for Ethiopian Cupertino Date Picker

To customize the `CupertinoETDatePicker`, you can similarly apply a `CupertinoTheme` and you can add aditional locale:

```dart
showCupertinoModalPopup(
  context: context,
  builder: (context) {
    return CupertinoTheme(
      data: CupertinoThemeData(
        textTheme: CupertinoTextThemeData(
          dateTimePickerTextStyle: TextStyle(color: Colors.white),
        ),
        // Add more customization here
      ),
      child: Container(
        height: 300,
        child: CupertinoETDatePicker(
          locale: Locale('am')
          mode: CupertinoETDatePickerMode.dateAndTime,
          onDateTimeChanged: (ETdateTime dateTime) {
            // Handle date change
          },
        ),
      ),
    );
  },
);
```

#### Customization Note
All customization options for the `ETDateTimePicker` and `CupertinoETDatePicker` are similar to those of the native Flutter date pickers. You can easily apply styles using `ThemeData`, `DatePickerTheme`, or by wrapping the pickers with `Theme` in the builder, just like you would with native Flutter widgets.

### 6. Using Material 2 Instead of Material 3

If you prefer to use Material 2 instead of Material 3 for your application, you can do so by setting the `useMaterial3` parameter to `false` in the `MaterialApp` widget. This ensures that the application uses the Material 2 design principles.

#### Example

Here’s how to set up your `MaterialApp` to use Material 2:

```dart
return MaterialApp(
  title: 'Ethiopian DateTime Picker',
  theme: ThemeData(
    useMaterial3: false, // Set to false to use Material 2
    datePickerTheme: DatePickerTheme(
      backgroundColor: Colors.white,
      primaryColor: Colors.teal,
      textColor: Colors.black,
      // Additional customizations
    ),
  ),
  home: MyHomePage(),
);
```

## <img src="https://github.com/rarksule/ethiopian_datetime_picker/raw/main/assets/Star.png" width="36px">️ Support Us

Feel free to check it out and give it a <img src="https://github.com/rarksule/ethiopian_datetime_picker/raw/main/assets/Star.png" width="24px">️ if you love it.
Follow me for more updates and projects!

## <img src="https://github.com/rarksule/ethiopian_datetime_picker/raw/main/assets/Folded Hands Medium Skin Tone.png" width="36px">️ Contributions and Feedback

Pull requests and feedback are always welcome!  
Feel free to reach out at [rarsule30@gmail.com](mailto:rarksule30@gmail.com) or connect with me on [LinkedIn](https://www.linkedin.com/in/suleyman-asrar-43101133a/).

_Banner designed and whole package idea inspired by  [mohammad-amir-mohammadi](https://www.linkedin.com/in/mohammad-amir-mohammadi)_

### <img src="https://github.com/rarksule/ethiopian_datetime_picker/raw/main/assets/Eyes.png" width="36px">️ Project License:

This project is licensed under the [BSD 3-Clause License](LICENSE).


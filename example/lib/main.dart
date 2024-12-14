import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ethiopian_datetime_picker/ethiopian_datetime_picker.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('am')],
      locale: const Locale('am'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),

      debugShowCheckedModeBanner: false,
      // theme: androidTheme,
      home: const MyHomePage(title: 'Sample Demonstaration App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String label = 'Ethiopian DateTIme Picker';

  String selectedDate = ETDateTime.now().toString();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.title,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [Colors.white, Color(0xffE4F5F9)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          physics: const BouncingScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    ImageBu(
                      onTap: () async {
                        ETDateTime? picked = await showETDatePicker(
                          context: context,
                          // initialDate: ETDateTime.now(),
                          firstDate: ETDateTime(2000, 8),
                          lastDate: ETDateTime(2040, 9),
                          locale: const Locale('om'),
                          initialEntryMode: DatePickerEntryMode.calendarOnly,
                          initialDatePickerMode: DatePickerMode.year,
                        );
                        if (picked != null) {
                          setState(() {
                            label = picked.toString();
                          });
                        }
                      },
                      image: '01',
                    ),
                    ImageBu(
                      onTap: () async {
                        ETDateTime? pickedDate =
                            await showModalBottomSheet<ETDateTime>(
                          context: context,
                          builder: (context) {
                            ETDateTime? tempPickedDate;
                            return SizedBox(
                              height: 250,
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      CupertinoButton(
                                        child: const Text(
                                          'ሰርዝ',
                                          style: TextStyle(),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      CupertinoButton(
                                        child: const Text(
                                          'እሺ',
                                          style: TextStyle(),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop(
                                              tempPickedDate ??
                                                  ETDateTime.now());
                                        },
                                      ),
                                    ],
                                  ),
                                  const Divider(
                                    height: 0,
                                    thickness: 1,
                                  ),
                                  Expanded(
                                    child: CupertinoETDatePicker(
                                      locale: const Locale('am'),
                                      mode:
                                          CupertinoDatePickerMode.dateAndTime,
                                      onDateTimeChanged:
                                          (ETDateTime dateTime) {
                                        tempPickedDate = dateTime;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );

                        if (pickedDate != null) {
                          setState(() {
                            label = '$pickedDate';
                          });
                        }
                      },
                      image: '04',
                    ),
                    ImageBu(
                      onTap: () async {
                        var picked = await showETTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(ETDateTime.now()),
                          initialEntryMode: TimePickerEntryMode.input,
                        );
                        setState(() {
                          if (picked != null) {
                            label = picked.toString();
                          }
                        });
                      },
                      image: '03',
                    ),
                    ImageBu(
                      onTap: () async {
                        ETDateTime? pickedDate =
                            await showModalBottomSheet<ETDateTime>(
                          context: context,
                          builder: (context) {
                            ETDateTime? tempPickedDate;
                            return SizedBox(
                              height: 250,
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      CupertinoButton(
                                        child: const Text(
                                          'cancel',
                                          style: TextStyle(),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      CupertinoButton(
                                        child: const Text(
                                          'Ok',
                                          style: TextStyle(),
                                        ),
                                        onPressed: () {
                                          // ignore: avoid_print
                                          print(tempPickedDate ??
                                              ETDateTime.now());
                                  
                                          Navigator.of(context).pop(
                                              tempPickedDate ??
                                                  ETDateTime.now());
                                        },
                                      ),
                                    ],
                                  ),
                                  const Divider(
                                    height: 0,
                                    thickness: 1,
                                  ),
                                  Expanded(
                                    child: CupertinoETDatePicker(
                                      locale: const Locale('om'),
                                      mode: CupertinoDatePickerMode.time,
                                      onDateTimeChanged:
                                          (ETDateTime dateTime) {
                                        tempPickedDate = dateTime;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );

                        if (pickedDate != null) {
                          setState(() {
                            label = pickedDate.toString();
                          });
                        }
                      },
                      image: '02',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    ImageBu(
                      onTap: () async {
                        var picked = await showETDateRangePicker(
                          context: context,
                          initialDateRange: ETDateTimeRange(
                            start: ETDateTime(2017, 1, 2),
                            end: ETDateTime(2017, 1, 10),
                          ),
                          locale: const Locale('am'),
                          firstDate: ETDateTime(2010),
                          lastDate: ETDateTime(2030),
                        );
                        setState(() {
                          label = "${picked?.start} ${picked?.end}";
                        });
                      },
                      image: '05',
                    ),
                    ImageBu(
                      onTap: () async {
                        var picked = await showETTimePicker(
                          locale: const Locale('en'),
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(ETDateTime.now()),
                        );
                        setState(() {
                          if (picked != null) {
                            label = picked.toString();
                          }
                        });
                      },
                      image: '06',
                    ),
                    ImageBu(
                      onTap: () async {
                        var picked = await showETDateRangePicker(
                          context: context,
                          initialEntryMode: DatePickerEntryMode.input,
                          initialDateRange: ETDateTimeRange(
                            start: ETDateTime(2017, 1, 2),
                            end: ETDateTime(2017, 1, 10),
                          ),
                          locale: const Locale('so'),
                          firstDate: ETDateTime(2010, 8),
                          lastDate: ETDateTime(2030, 9),
                        );
                        setState(() {
                          label = "${picked?.start} ${picked?.end}";
                        });
                      },
                      image: '07',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 70,
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            blurRadius: 3,
            spreadRadius: 0,
            offset: const Offset(0, 4),
            color: const Color(0xff000000).withOpacity(0.3),
          ),
        ], color: Colors.white),
        child: Center(
          child: Text(
            label.contains('null') ? 'Ethiopian DateTIme Picker' : label,
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .copyWith(color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class ImageBu extends StatelessWidget {
  const ImageBu({super.key, required this.onTap, required this.image});
  final Function onTap;
  final String image;

  @override
  Widget build(BuildContext context) {
    return ScaleGesture(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 3,
                spreadRadius: 0,
                offset: const Offset(0, 4),
                color: const Color(0xff000000).withOpacity(0.3),
              ),
            ],
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: Image.asset(
          'assets/$image.png',
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }
}

class ScaleGesture extends StatefulWidget {
  final Widget child;
  final double scale;
  final Function onTap;

  const ScaleGesture({
    super.key,
    required this.child,
    this.scale = 1.1,
    required this.onTap,
  });

  @override
  State<ScaleGesture> createState() => _ScaleGestureState();
}

class _ScaleGestureState extends State<ScaleGesture> {
  late double scale;

  @override
  void initState() {
    scale = 1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (detail) {
        setState(() {
          scale = widget.scale;
        });
      },
      onTapCancel: () {
        setState(() {
          scale = 1;
        });
      },
      onTapUp: (datail) {
        setState(() {
          scale = 1;
        });
        widget.onTap();
      },
      child: Transform.scale(
        scale: scale,
        child: widget.child,
      ),
    );
  }
}

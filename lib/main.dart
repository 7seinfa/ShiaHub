import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'adhan.dart';
import 'contact.dart';
import 'marja.dart';
import 'quran.dart';
import 'package:background_fetch/background_fetch.dart';
import 'theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dua.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
  BackgroundFetch.registerHeadlessTask(setNotifcations);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: child!
        );
      },
      title: 'ShiaHub',
      theme: ThemeData(
          scaffoldBackgroundColor: MyColors.background(),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: AppBarTheme(
            iconTheme: IconThemeData(
              color: MyColors.text()
            )
          ),
          iconTheme: IconThemeData(
            color: darkModeOn()?MyColors.text():Colors.black
          ),
          textTheme: TextTheme(
              headlineSmall: TextStyle(
                color: MyColors.text(),
              ),
              titleLarge: TextStyle(
                color: MyColors.text(),
              )), colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(background: MyColors.text())),
      home: MyHomePage(title: 'ShiaHub'),
      routes: <String, WidgetBuilder>{
        "/quran/": (BuildContext context) => JuzOrSurah(),
        "/quran/juz/": (BuildContext context) => Juz(),
        "/quran/surah/": (BuildContext context) => Surah(),
        "/duas/": (BuildContext context) => const DuaList(
              json: "duas.json",
              title: "Duas",
            ),
        "/munajat/": (BuildContext context) => const DuaList(
              json: "munajat.json",
              title: "Munajat",
            ),
        "/sahifa/": (BuildContext context) => const DuaList(
              json: "sahifa.json",
              title: "Sahifa Sajadiyyah",
            ),
        "/taaqibat/": (BuildContext context) => const DuaList(
              json: "taaqibat.json",
              title: "Taaqibat",
            ),
        "/ziyarat/": (BuildContext context) => const DuaList(
              json: "ziyarat.json",
              title: "Ziyarat",
            ),
        "/marja/": (BuildContext context) => Marja(),
        "/contact/": (BuildContext context) => Contact(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title=''}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<DateTime> salahTimes = [DateTime.now().subtract(const Duration(days:1)),DateTime.now().subtract(const Duration(days:1)),DateTime.now().subtract(const Duration(days:1)),DateTime.now().subtract(const Duration(days:1)),DateTime.now().subtract(const Duration(days:1)),DateTime.now().subtract(const Duration(days:1)),DateTime.now().subtract(const Duration(days:1))];
  SharedPreferences? prefs;
  bool fajrOn = true, dhuhrOn = true, maghribOn = true, highLat = false;
  double fajrOffset = 0, dhuhrOffset = 0, maghribOffset = 0;
  bool isSettings = false;
  int calcMethod = 0, midnightMethod = 0, adhanReciter = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _locationText = TextEditingController();
  String loc = '';

  @override
  void initState() {
    loadPrayerTimes();
    super.initState();
  }

  loadPrayerTimes() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs!.containsKey("dark")) {
      dark = prefs!.getBool("dark")!;
    } else {
      dark = true;
      prefs!.setBool("dark", true);
    }
    main();
    try {
      print(prefs!.getString("lastFetch"));
    } catch (e) {
      print("$e error");
    }
    try {
      print(prefs!.getInt("numOfFetches"));
    } catch (e) {
      print(e.toString());
    }

    LocationPermission curPerm = await Geolocator.checkPermission();
    if (curPerm != LocationPermission.whileInUse
      && curPerm != LocationPermission.always && curPerm != LocationPermission.deniedForever){
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text('Welcome! Location permission will be requested for prayer times calculation, and notification permission will be requested to send notifications.'
                        ,style: TextStyle(color: MyColors.text()),),
                actions: [
                  TextButton(
                    onPressed: () async {
                    await Geolocator.requestPermission();
                    
                    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
                    FlutterLocalNotificationsPlugin();
                    const AndroidInitializationSettings
                                              initializationSettingsAndroid =
                                              AndroidInitializationSettings('ic_launcher');
                    flutterLocalNotificationsPlugin.initialize(
                                              const InitializationSettings(
                                                  android: initializationSettingsAndroid));
                    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
                    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestExactAlarmsPermission();
                    Navigator.of(context).pop();
                    salahTimes = await prayerTimes();
                    setState(() {});
                  }, 
                  child: Text("Okay", style: TextStyle(color: MyColors.text()),)
                  )
                ],
                backgroundColor: MyColors.color1()[200],
                shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20.0)),
              );
            },
          );
        });
      }
    BackgroundFetch.configure(
        BackgroundFetchConfig(
          minimumFetchInterval: 15,
          forceAlarmManager: false,
          stopOnTerminate: false,
          enableHeadless: true,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresStorageNotLow: false,
          requiresDeviceIdle: false,
          requiredNetworkType: NetworkType.NONE,
          startOnBoot: true,
        ),
        setNotifcations, (String taskId) async {
      // <-- Task timeout handler.
      // This task has exceeded its allowed running-time.  You must stop what you're doing and immediately .finish(taskId)
      print("[BackgroundFetch] TASK TIMEOUT taskId: $taskId");
      BackgroundFetch.finish(taskId);
    });

    if (prefs!.containsKey("fajrOn")) {
      fajrOn = prefs!.getBool("fajrOn")!;
      dhuhrOn = prefs!.getBool("dhuhrOn")!;
      maghribOn = prefs!.getBool("maghribOn")!;
      fajrOffset = prefs!.getInt("fajrOffset")!.toDouble();
      dhuhrOffset = prefs!.getInt("dhuhrOffset")!.toDouble();
      maghribOffset = prefs!.getInt("maghribOffset")!.toDouble();
      calcMethod = prefs!.getInt("calcMethod")!;
      midnightMethod = prefs!.getInt("midnightMethod")!;
      adhanReciter = prefs!.getInt("adhanRecitor")!;
      highLat = prefs!.getBool("highLat")!;       
      salahTimes = await prayerTimes();
    } else {
      prefs!.setBool("fajrOn", true);
      prefs!.setBool("dhuhrOn", true);
      prefs!.setBool("maghribOn", true);
      prefs!.setInt("fajrOffset", 0);
      prefs!.setInt("dhuhrOffset", 0);
      prefs!.setInt("maghribOffset", 0);
      prefs!.setInt("calcMethod", 0);
      prefs!.setInt("midnightMethod", 0);
      prefs!.setInt('adhanRecitor', 0);
      prefs!.setBool("highLat", false);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget settings() {
      return Scaffold(
          key: _scaffoldKey,
          backgroundColor: MyColors.background(),
          body: PopScope(
            canPop: false,
            child: CustomScrollView(slivers: [
              SliverAppBar(
                  toolbarHeight: toolbarSize(context),
                  backgroundColor: MyColors.appBar(),
                  leading: Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.015),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () async {
                        isSettings = false;
                        await loadPrayerTimes();
                        setState(() {});
                      },
                    ),
                  ),
                  title: Padding(
                    padding: EdgeInsets.fromLTRB(
                        0, MediaQuery.of(context).size.height * 0.015, 0, 0),
                    child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FittedBox(
                            fit: BoxFit.contain,
                            child: Text("Settings",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(fontSize: titleSize(context)))
                          ),
                        ]),
                  ),
                  actions: [
                    Container(
                      width: 56,
                    )
                  ],
                  centerTitle: false,
                  shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(30))),
                  bottom: PreferredSize(
                      // Add this code
                      preferredSize: Size(
                          double.infinity,
                          MediaQuery.of(context).size.height *
                              0.02), // Add this code
                      child: const Text(""))),
              SliverList(
                  delegate: SliverChildListDelegate([
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Adhan Notifications",
                        style: TextStyle(color: MyColors.text()),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Fajr",
                            style: TextStyle(color: MyColors.text()),
                          ),
                          Switch(
                            value: fajrOn,
                            onChanged: (d) async {
                              prefs!.setBool("fajrOn", d);
                              fajrOn = d;
                              setState(() {});
                            },
                            activeColor: MyColors.sliderInactive(),
                            activeTrackColor: MyColors.sliderActive(),
                            inactiveThumbColor: MyColors.sliderActive(),
                            inactiveTrackColor: MyColors.sliderInactive(),
                          ),
                          Text(
                            "Dhuhr",
                            style: TextStyle(color: MyColors.text()),
                          ),
                          Switch(
                            value: dhuhrOn,
                            onChanged: (d) async {
                              prefs!.setBool("dhuhrOn", d);
                              dhuhrOn = d;
                              setState(() {});
                            },
                            activeColor: MyColors.sliderInactive(),
                            activeTrackColor: MyColors.sliderActive(),
                            inactiveThumbColor: MyColors.sliderActive(),
                            inactiveTrackColor: MyColors.sliderInactive(),
                          ),
                          Text(
                            "Maghrib",
                            style: TextStyle(color: MyColors.text()),
                          ),
                          Switch(
                            value: maghribOn,
                            onChanged: (d) async {
                              prefs!.setBool("maghribOn", d);
                              maghribOn = d;
                              setState(() {});
                            },
                            activeColor: MyColors.sliderInactive(),
                            activeTrackColor: MyColors.sliderActive(),
                            inactiveThumbColor: MyColors.sliderActive(),
                            inactiveTrackColor: MyColors.sliderInactive(),
                          ),
                        ],
                      ),
                      Text(
                        "Calculation Method",
                        style: TextStyle(color: MyColors.text()),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 5, left: 10, right: 10, bottom: 10),
                        child: Container(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: MyColors.sliderActive(),
                                ),
                                child: DropdownButton(
                                  isExpanded: true,
                                  style: TextStyle(
                                    color: MyColors.background(),
                                  ),
                                  dropdownColor: MyColors.sliderActive(),
                                  underline: Container(),
                                  iconEnabledColor: MyColors.text(),
                                  items: [
                                    DropdownMenuItem(
                                      value: 0,
                                      child: LayoutBuilder(builder:
                                          (BuildContext context,
                                              BoxConstraints constraints) {
                                        return Container(
                                            width: constraints.maxWidth,
                                            child: Text(
                                              "Leva Research Institute, Qom",
                                              overflow: TextOverflow.clip,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: MyColors.text()),
                                            ));
                                      }),
                                    ),
                                    DropdownMenuItem(
                                      value: 1,
                                      child: LayoutBuilder(builder:
                                          (BuildContext context,
                                              BoxConstraints constraints) {
                                        return Container(
                                            width: constraints.maxWidth,
                                            child: Text(
                                              "Institute of Geophysics, Tehran",
                                              overflow: TextOverflow.clip,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: MyColors.text()),
                                            ));
                                      }),
                                    ),
                                  ],
                                  onChanged: (value) async {
                                    calcMethod = value!;
                                    prefs!.setInt("calcMethod", value);
                                    await loadPrayerTimes();
                                    setState(() {});
                                  },
                                  value: calcMethod,
                                ),
                              )
                            ])),
                      ),
                      Text(
                        "Higher Latitude Adjustment for Fajr (Angle Based)",
                        style: TextStyle(color: MyColors.text()),
                      ),
                      Switch(
                            value: highLat,
                            onChanged: (d) async {
                              prefs!.setBool("highLat", d);
                              highLat = d;
                              await loadPrayerTimes();
                              setState(() {});
                            },
                            activeColor: MyColors.sliderInactive(),
                            activeTrackColor: MyColors.sliderActive(),
                            inactiveThumbColor: MyColors.sliderActive(),
                            inactiveTrackColor: MyColors.sliderInactive(),
                          ),
                      Text(
                        "Midnight Method",
                        style: TextStyle(color: MyColors.text()),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
                        child: Container(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: MyColors.sliderActive(),
                                ),
                                child: DropdownButton(
                                  isExpanded: true,
                                  style: TextStyle(
                                    color: MyColors.background(),
                                  ),
                                  dropdownColor: MyColors.sliderActive(),
                                  underline: Container(),
                                  iconEnabledColor: MyColors.text(),
                                  items: [
                                    DropdownMenuItem(
                                      value: 0,
                                      child: LayoutBuilder(builder:
                                          (BuildContext context,
                                              BoxConstraints constraints) {
                                        return Container(
                                            width: constraints.maxWidth,
                                            child: Text(
                                              "Sunset to Fajr (Sistani, Khamenei, Fadlallah)",
                                              overflow: TextOverflow.clip,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: MyColors.text()),
                                            ));
                                      }),
                                    ),
                                    DropdownMenuItem(
                                      value: 1,
                                      child: LayoutBuilder(builder:
                                          (BuildContext context,
                                              BoxConstraints constraints) {
                                        return Container(
                                            width: constraints.maxWidth,
                                            child: Text(
                                              "Sunset to Sunrise (Khoei)",
                                              overflow: TextOverflow.clip,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: MyColors.text()),
                                            ));
                                      }),
                                    ),
                                  ],
                                  onChanged: (value) async {
                                    midnightMethod = value!;
                                    prefs!.setInt("midnightMethod", value);
                                    await loadPrayerTimes();
                                    setState(() {});
                                  },
                                  value: midnightMethod,
                                ),
                              )
                            ])),
                      ),
                      const Padding(padding: EdgeInsets.only(top: 15)),
                      Text(
                        "Adhan Offsets",
                        style: TextStyle(color: MyColors.text()),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Flexible(
                            flex: 4,
                            fit: FlexFit.tight,
                            child: Text(
                              "Fajr",
                              style: TextStyle(color: MyColors.text()),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Flexible(
                              flex: 14,
                              child: Slider(
                                value: fajrOffset,
                                inactiveColor: MyColors.sliderActive(),
                                activeColor: MyColors.sliderInactive(),
                                min: -20,
                                max: 20,
                                divisions: 40,
                                onChangeEnd: (d) {
                                  prefs!.setInt("fajrOffset", d.toInt());
                                },
                                onChanged: (d) async {
                                  fajrOffset = d;
                                  setState(() {});
                                },
                              )),
                          Flexible(
                            flex: 2,
                            fit: FlexFit.tight,
                            child: Text(fajrOffset.toInt().toString(),
                                style: TextStyle(color: MyColors.text())),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Flexible(
                            flex: 4,
                            fit: FlexFit.tight,
                            child: Text(
                              "Dhuhr",
                              style: TextStyle(color: MyColors.text()),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Flexible(
                              flex: 14,
                              child: Slider(
                                value: dhuhrOffset,
                                inactiveColor: MyColors.sliderActive(),
                                activeColor: MyColors.sliderInactive(),
                                min: -20,
                                max: 20,
                                divisions: 40,
                                onChangeEnd: (d) {
                                  prefs!.setInt("dhuhrOffset", d.toInt());
                                },
                                onChanged: (d) async {
                                  dhuhrOffset = d;
                                  setState(() {});
                                },
                              )),
                          Flexible(
                            flex: 2,
                            fit: FlexFit.tight,
                            child: Text(
                              dhuhrOffset.toInt().toString(),
                              style: TextStyle(color: MyColors.text()),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Flexible(
                            flex: 4,
                            fit: FlexFit.tight,
                            child: Text(
                              "Maghrib",
                              style: TextStyle(color: MyColors.text()),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Flexible(
                              flex: 14,
                              child: Slider(
                                value: maghribOffset,
                                inactiveColor: MyColors.sliderActive(),
                                activeColor: MyColors.sliderInactive(),
                                min: -20,
                                max: 20,
                                divisions: 40,
                                onChangeEnd: (d) {
                                  prefs!.setInt("maghribOffset", d.toInt());
                                },
                                onChanged: (d) async {
                                  maghribOffset = d;
                                  setState(() {});
                                },
                              )),
                          Flexible(
                            flex: 2,
                            fit: FlexFit.tight,
                            child: Text(
                              maghribOffset.toInt().toString(),
                              style: TextStyle(color: MyColors.text()),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "Adhan Voice",
                        style: TextStyle(color: MyColors.text()),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
                          child: Container(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                Container(
                                    child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: MyColors.sliderActive(),
                                  ),
                                  child: DropdownButton(
                                    isExpanded: true,
                                    style: TextStyle(
                                      color: MyColors.background(),
                                    ),
                                    dropdownColor: MyColors.sliderActive(),
                                    underline: Container(),
                                    iconEnabledColor: MyColors.text(),
                                    items: [
                                      DropdownMenuItem(
                                        value: 0,
                                        child: LayoutBuilder(builder:
                                            (BuildContext context,
                                                BoxConstraints constraints) {
                                          return Container(
                                              width: constraints.maxWidth,
                                              child: Text(
                                                "Hajj Mohammad Rammal",
                                                overflow: TextOverflow.clip,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: MyColors.text()),
                                              ));
                                        }),
                                      ),
                                      DropdownMenuItem(
                                        value: 1,
                                        child: LayoutBuilder(builder:
                                            (BuildContext context,
                                                BoxConstraints constraints) {
                                          return Container(
                                              width: constraints.maxWidth,
                                              child: Text(
                                                "Nizar Al Qatari",
                                                overflow: TextOverflow.clip,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: MyColors.text()),
                                              ));
                                        }),
                                      ),
                                      DropdownMenuItem(
                                        value: 2,
                                        child: LayoutBuilder(builder:
                                            (BuildContext context,
                                                BoxConstraints constraints) {
                                          return Container(
                                              width: constraints.maxWidth,
                                              child: Text(
                                                "Ahmad Al Dabbagh",
                                                overflow: TextOverflow.clip,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: MyColors.text()),
                                              ));
                                        }),
                                      ),
                                      DropdownMenuItem(
                                        value: 3,
                                        child: LayoutBuilder(builder:
                                            (BuildContext context,
                                                BoxConstraints constraints) {
                                          return Container(
                                              width: constraints.maxWidth,
                                              child: Text(
                                                "Hussein Ali Qasem Tlees",
                                                overflow: TextOverflow.clip,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: MyColors.text()),
                                              ));
                                        }),
                                      ),
                                      DropdownMenuItem(
                                        value: 4,
                                        child: LayoutBuilder(builder:
                                            (BuildContext context,
                                                BoxConstraints constraints) {
                                          return Container(
                                              width: constraints.maxWidth,
                                              child: Text(
                                                "Vibrate",
                                                overflow: TextOverflow.clip,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: MyColors.text()),
                                              ));
                                        }),
                                      ),
                                    ],
                                    onChanged: (value) async {
                                      await prefs!.setInt('adhanRecitor', value!);
                                      adhanReciter = value;
                                      setState(() {});
                                    },
                                    value: adhanReciter,
                                  ),
                                ))
                              ]))),
                      const Padding(padding: EdgeInsets.only(top: 15)),
                      InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: MyColors.sliderActive(),
                          ),
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.width * 0.04),
                          child: Text(
                            "Test Adhan",
                            style: TextStyle(
                              color: MyColors.text(),
                            ),
                          ),
                        ),
                        onTap: () async {
                          NotificationDetails rammal = const NotificationDetails(
                              android: AndroidNotificationDetails(
                                  'adhanChannelRammal', 'Adhan', 
                                  sound: RawResourceAndroidNotificationSound(
                                      'rammal'),
                                  playSound: true,
                                  priority: Priority.max,
                                  importance: Importance.max));
                          NotificationDetails qatari = const NotificationDetails(
                              android: AndroidNotificationDetails(
                                  'adhanChannelQatari', 'Adhan', 
                                  sound: RawResourceAndroidNotificationSound(
                                      'qatari'),
                                  playSound: true,
                                  priority: Priority.max,
                                  importance: Importance.max,
                                  enableVibration: true));
                          NotificationDetails dabbagh = const NotificationDetails(
                              android: AndroidNotificationDetails(
                                  'adhanChannelDabbagh', 'Adhan', 
                                  sound: RawResourceAndroidNotificationSound(
                                      'dabbagh'),
                                  playSound: true,
                                  priority: Priority.max,
                                  importance: Importance.max,
                                  enableVibration: true));
                          NotificationDetails tlees = const NotificationDetails(
                              android: AndroidNotificationDetails(
                                  'adhanChannelTlees', 'Adhan',
                                  sound: RawResourceAndroidNotificationSound(
                                      'tlees'),
                                  playSound: true,
                                  priority: Priority.max,
                                  importance: Importance.max,
                                  enableVibration: true));
                          NotificationDetails vibrate = const NotificationDetails(
                              android: AndroidNotificationDetails(
                                  'adhanChannelTlees', 'Adhan', 
                                  playSound: false,
                                  priority: Priority.max,
                                  importance: Importance.max,
                                  enableVibration: true));
                                  
                          NotificationDetails notifcationdetails = rammal;
                          flutterLocalNotificationsPlugin =
                              FlutterLocalNotificationsPlugin();
                          // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
                          const AndroidInitializationSettings
                              initializationSettingsAndroid =
                              AndroidInitializationSettings('ic_launcher');
                          /*final IOSInitializationSettings
                              initializationSettingsIOS =
                              IOSInitializationSettings(
                                  onDidReceiveLocalNotification:
                                      (a, b, c, d) async {});*/
                          flutterLocalNotificationsPlugin.initialize(
                              const InitializationSettings(
                                  android: initializationSettingsAndroid));
                          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

                          switch (adhanReciter) {
                            case 0:
                              notifcationdetails = rammal;
                              break;
                            case 1:
                              notifcationdetails = qatari;
                              break;
                            case 2:
                              notifcationdetails = dabbagh;
                              break;
                            case 3:
                              notifcationdetails = tlees;
                              break;
                            case 4:
                              notifcationdetails = vibrate;
                              break;
                          }
                          flutterLocalNotificationsPlugin.show(3, "Test Adhan",
                              "Test Adhan", notifcationdetails);
                          var path = await getApplicationDocumentsDirectory();
                          print(await Directory(
                                  (await path.parent.list().toList())[0].path)
                              .list()
                              .toList());
                        },
                      ),
                      const Padding(padding: EdgeInsets.only(top: 15)),
                      Text(
                        "Location",
                        style: TextStyle(color: MyColors.text()),
                      ),
                      const Padding(padding: EdgeInsets.only(top: 5)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: MyColors.sliderActive(),
                              ),
                              padding: EdgeInsets.all(
                                  MediaQuery.of(context).size.width * 0.04),
                              child: Text(
                                "Find Location by GPS",
                                style: TextStyle(
                                  color: MyColors.text(),
                                ),
                              ),
                            ),
                            onTap: () async {
                              Position position = await determinePosition();
                              if (position.longitude==0 && position.latitude==0) {
                                var snackBar = const SnackBar(
                                  content: Text('Unable to Retrieve Location'),
                                );
                                ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(snackBar);
                              } else {
                                
                                prefs!.setDouble('latitude', position.latitude);
                                prefs!.setDouble(
                                    'longitude', position.longitude);
                                prefs!.setDouble('altitude', position.altitude);
                                salahTimes = await prayerTimes();
                                var snackBar = const SnackBar(
                                  content: Text('Location Set!'),
                                );
                                ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(snackBar);
                              }
                            },
                          ),
                          InkWell(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: MyColors.sliderActive(),
                              ),
                              padding: EdgeInsets.all(
                                  MediaQuery.of(context).size.width * 0.04),
                              child: Text(
                                "Set Location Manually",
                                style: TextStyle(
                                  color: MyColors.text(),
                                ),
                              ),
                            ),
                            onTap: () async {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                      "Location",
                                      style: TextStyle(color: MyColors.text()),
                                    ),
                                    content: SingleChildScrollView(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          color: MyColors.color1()[100],
                                        ),
                                        padding: EdgeInsets.only(
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.02,
                                            right: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.02),
                                        child: TextField(
                                            controller: _locationText,
                                            style: TextStyle(
                                                color: MyColors.text()),
                                            enabled: true,
                                            maxLines: 2,
                                            decoration: InputDecoration(
                                                hintStyle: TextStyle(
                                                    color:
                                                        MyColors.hint()[100]),
                                                hintText:
                                                    'Please enter a location (address, city, etc)',
                                                border: InputBorder.none),
                                            onChanged: (String e) {
                                              loc = e;
                                              setState(() {});
                                            }),
                                      ),
                                    ),
                                    actions: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          TextButton(
                                            child: Text("Set",
                                                style: TextStyle(
                                                    color: MyColors.text())),
                                            onPressed: () async {
                                              if (loc != '') {
                                                List<Location> geo =
                                                    await locationFromAddress(
                                                        loc);
                                                if (geo.isNotEmpty) {
                                                  Location geoCo = geo[0];
                                                  prefs!.setDouble('latitude',
                                                      geoCo.latitude);
                                                  prefs!.setDouble('longitude',
                                                      geoCo.longitude);
                                                  prefs!.setDouble(
                                                      'altitude', 0);
                                                  salahTimes =
                                                      await prayerTimes();
                                                  var snackBar = const SnackBar(
                                                    content: Text(
                                                        'Location Found and Set!'),
                                                  );
                                                  ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(snackBar);
                                                  Navigator.pop(context);
                                                } else {
                                                  var snackBar = const SnackBar(
                                                    content: Text(
                                                        'Location Not Found!'),
                                                  );
                                                  ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(snackBar);
                                                }
                                              } else {
                                                var snackBar = const SnackBar(
                                                  content: Text(
                                                      'No Location Entered!'),
                                                );
                                                ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(snackBar);
                                                Navigator.of(context).pop();
                                              }
                                            },
                                          ),
                                          TextButton(
                                            child: Text("Back",
                                                style: TextStyle(
                                                    color: MyColors.text())),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          )
                                        ],
                                      )
                                    ],
                                    backgroundColor: MyColors.color1()[200],
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0)),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      /*const Padding(padding: EdgeInsets.only(top: 5)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "Light Mode",
                            style: TextStyle(color: MyColors.text()),
                          ),
                          Switch(
                            value: dark,
                            onChanged: (d) async {
                              prefs!.setBool("dark", d);
                              dark = d;
                              fajrOn = d;
                              setState(() {});
                              main();
                            },
                            activeColor: MyColors.sliderInactive(),
                            activeTrackColor: MyColors.sliderActive(),
                            inactiveThumbColor: MyColors.sliderActive(),
                            inactiveTrackColor: MyColors.sliderInactive(),
                          ),
                          Text(
                            "Dark Mode",
                            style: TextStyle(color: MyColors.text()),
                          ),
                        ],
                      )*/
                    ]),
              ])),
            ]),
            onPopInvoked: (bool didPop) async {
              if (didPop) {
                return;
              }
              isSettings = false;
              await loadPrayerTimes();
              setState(() {});
              return Future.value(false);
            },
          ));
    }

    return isSettings
        ? settings()
        : Scaffold(
            /*appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))
        ),
      ),*/
            body: HomeCardList(
                appbar: SliverAppBar(
                    toolbarHeight: toolbarSize(context),
                    leading: IconButton(icon: Container(), onPressed: () {}),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.width * 0.03),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                    "Prayer Times",
                                    style: TextStyle(
                                        color: MyColors.text(),
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.06),
                                    textAlign: TextAlign.center,
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Imsak:",
                                              style: TextStyle(
                                                  color: MyColors.text(),
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.05),
                                            ),
                                            Text(
                                              "${hourIn24(salahTimes[0]
                                                              .hour)}:${lessThan10(salahTimes[0]
                                                              .minute)}${salahTimes[0].hour >= 12
                                                          ? " PM"
                                                          : " AM"}",
                                              style: TextStyle(
                                                  color: MyColors.text(),
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.05),
                                            )
                                          ]),
                                      const Padding(
                                          padding: EdgeInsets.only(bottom: 5)),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Fajr:",
                                              style: TextStyle(
                                                  color: MyColors.text(),
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.05),
                                            ),
                                            Text(
                                             "${hourIn24(salahTimes[1]
                                                              .hour)}:${lessThan10(salahTimes[1]
                                                              .minute)}${salahTimes[1].hour >= 12
                                                          ? " PM"
                                                          : " AM"}",
                                              style: TextStyle(
                                                  color: MyColors.text(),
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.05),
                                            )
                                          ]),
                                      const Padding(
                                          padding: EdgeInsets.only(bottom: 5)),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Sunrise:",
                                              style: TextStyle(
                                                  color: MyColors.text(),
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.05),
                                            ),
                                            Text(
                                              "${hourIn24(salahTimes[2]
                                                              .hour)}:${lessThan10(salahTimes[2]
                                                              .minute)}${salahTimes[2].hour >= 12
                                                          ? " PM"
                                                          : " AM"}",
                                              style: TextStyle(
                                                  color: MyColors.text(),
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.05),
                                            )
                                          ]),
                                      const Padding(
                                          padding: EdgeInsets.only(bottom: 5)),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Dhuhr:",
                                              style: TextStyle(
                                                  color: MyColors.text(),
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.05),
                                            ),
                                            Text(
                                              "${hourIn24(salahTimes[3]
                                                              .hour)}:${lessThan10(salahTimes[3]
                                                              .minute)}${salahTimes[3].hour >= 12
                                                          ? " PM"
                                                          : " AM"}",
                                              style: TextStyle(
                                                  color: MyColors.text(),
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.05),
                                            )
                                          ]),
                                      const Padding(
                                          padding: EdgeInsets.only(bottom: 5)),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Sunset:",
                                              style: TextStyle(
                                                  color: MyColors.text(),
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.05),
                                            ),
                                            Text(
                                              "${hourIn24(salahTimes[4]
                                                              .hour)}:${lessThan10(salahTimes[4]
                                                              .minute)}${salahTimes[4].hour >= 12
                                                          ? " PM"
                                                          : " AM"}",
                                              style: TextStyle(
                                                  color: MyColors.text(),
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.05),
                                            )
                                          ]),
                                      const Padding(
                                          padding: EdgeInsets.only(bottom: 5)),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Maghrib:",
                                              style: TextStyle(
                                                  color: MyColors.text(),
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.05),
                                            ),
                                            Text(
                                              "${hourIn24(salahTimes[5]
                                                              .hour)}:${lessThan10(salahTimes[5]
                                                              .minute)}${salahTimes[5].hour >= 12
                                                          ? " PM"
                                                          : " AM"}",
                                              style: TextStyle(
                                                  color: MyColors.text(),
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.05),
                                            )
                                          ]),
                                      const Padding(
                                          padding: EdgeInsets.only(bottom: 5)),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Midnight:",
                                              style: TextStyle(
                                                  color: MyColors.text(),
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.05),
                                            ),
                                            Text(
                                              "${hourIn24(salahTimes[6]
                                                              .hour)}:${lessThan10(salahTimes[6]
                                                              .minute)}${salahTimes[6].hour >= 12
                                                          ? " PM"
                                                          : " AM"}",
                                              style: TextStyle(
                                                  color: MyColors.text(),
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.05),
                                            )
                                          ]),
                                    ],
                                  ),
                                  backgroundColor: MyColors.color1()[200],
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(20.0)),
                                );
                              });
                          setState(() {});
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings),
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.width * 0.03),
                        onPressed: () {
                          isSettings = true;
                          setState(() {});
                        },
                      )
                    ],
                    backgroundColor: MyColors.appBar(),
                    title: Padding(
                      padding: EdgeInsets.fromLTRB(
                          0, MediaQuery.of(context).size.height * 0.015, 0, 0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(widget.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(fontSize: titleSize(context))
                                ),
                          ]),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: 
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              MyColors.appBarNew()[-200]!,
                              MyColors.appBarNew()[0]!,
                            ],
                          ),
                          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))
                        ),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(0,
                              MediaQuery.of(context).size.height * 0.105, 0, 0),
                          child: Column(
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.005,
                                          top: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.005),
                                      child: Text(
                                        HijriCalendar.now().fullDate(),
                                        style: TextStyle(
                                          fontSize: MediaQuery.of(context).size.height*0.028,
                                          color: MyColors.text()
                                        ),
                                      ),
                                    ),
                                  ]),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Container(
                                        //padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height*0.015, 0, 0),
                                        child: Column(children: [
                                      Text(
                                        'Fajr',
                                        style: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.02,
                                            color: MyColors.text()),
                                            
                                      ),
                                      Text(
                                        "${hourIn24(salahTimes[1].hour)}:${lessThan10(
                                                    salahTimes[1].minute)}${salahTimes[1].hour >= 12
                                                    ? " PM"
                                                    : " AM"}",
                                        style: TextStyle(
                                            fontSize:MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.035,
                                            color: MyColors.text()),
                                            
                                      )
                                    ])),
                                  ),
                                  Expanded(
                                    child: Container(
                                        //padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height*0.015, 0, 0),
                                        child: Column(children: [
                                      Text(
                                        'Dhuhr',
                                        style: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.02,
                                            color: MyColors.text()),
                                            
                                      ),
                                      Text(
                                        "${hourIn24(salahTimes[3].hour)}:${lessThan10(
                                                    salahTimes[3].minute)}${salahTimes[3].hour >= 12
                                                    ? " PM"
                                                    : " AM"}",
                                        style: TextStyle(
                                            fontSize:MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.035,
                                            color: MyColors.text()),
                                            
                                      )
                                    ])),
                                  ),
                                  Expanded(
                                    child: Container(
                                        //padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height*0.015, 0, 0),
                                        child: Column(children: [
                                      Text(
                                        'Maghrib',
                                        style: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.02,
                                            color: MyColors.text()),
                                            
                                      ),
                                      Text(
                                        "${hourIn24(salahTimes[5].hour)}:${lessThan10(
                                                    salahTimes[5].minute)}${salahTimes[5].hour >= 12
                                                    ? " PM"
                                                    : " AM"}",
                                        style: TextStyle(
                                            fontSize:MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.035,
                                            color: MyColors.text()),
                                            
                                      )
                                    ])),
                                  ),
                                ],
                              ),
                            ],
                          )),
                      ),
                      centerTitle: true,
                    ),
                    centerTitle: true,
                    pinned: true,
                    expandedHeight: MediaQuery.of(context).size.height * 0.20,
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(30))),
                    bottom: PreferredSize(
                        // Add this code
                        preferredSize: Size(
                            double.infinity,
                            MediaQuery.of(context).size.height *
                                0.02), // Add this code
                        child: const Text(""))),
                cards: [
                HomeCard(
                  title: "Quran",
                  description: "The Holy Book\nby Surah or Juz'",
                  gradient: LinearGradient(colors: [
                    MyColors.color1()[-200]!,
                    MyColors.color1()[200]!
                  ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  icon: const AssetImage("assets/icons/quran.png"),
                  iconBackground: Colors.transparent,
                  route: () {
                    Navigator.of(context).pushNamed("/quran/");
                  },
                ),
                HomeCard(
                  title: "Duas",
                  description: "Varius prayers from\nthe Masumeen (as)",
                  gradient: LinearGradient(
                    colors: [
                      MyColors.color2()[-200]!,
                      MyColors.color2()[200]!
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight
                  ),
                  icon: const AssetImage("assets/icons/dua.png"),
                  iconBackground: Colors.transparent,
                  route: () {
                    Navigator.of(context).pushNamed("/duas/");
                  },
                ),
                HomeCard(
                  title: "Munajat",
                  description: "Silent supplications",
                  gradient: LinearGradient(
                    colors: [
                      MyColors.color3()[-200]!,
                      MyColors.color3()[200]!
                    ],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
                  icon: const AssetImage("assets/icons/munajaat.png"),
                  iconBackground: Colors.transparent,
                  route: () {
                    Navigator.of(context).pushNamed("/munajat/");
                  },
                ),
                HomeCard(
                  title: "Sahifa Sajadiyyah",
                  description: "Supplications from\nthe Fourth Imam (as)",
                  gradient: LinearGradient(
                    colors: [
                      MyColors.color4()[-200]!,
                      MyColors.color4()[200]!
                    ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  icon: const AssetImage("assets/icons/sahifa.png"),
                  iconBackground: Colors.transparent,
                  route: () {
                    Navigator.of(context).pushNamed("/sahifa/");
                  },
                ),
                HomeCard(
                  title: "Taaqibat",
                  description: "Supplications after\neach prayer",
                  gradient: LinearGradient(
                    colors: [
                      MyColors.color5()[-200]!,
                      MyColors.color5()[200]!
                    ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  icon: const AssetImage("assets/icons/taaqibat.png"),
                  iconBackground: Colors.transparent,
                  route: () {
                    Navigator.of(context).pushNamed("/taaqibat/");
                  },
                ),
                HomeCard(
                  title: "Ziyarat",
                  description: "Visitation of the\nMasumeen (as)",
                  gradient: LinearGradient(
                    colors: [
                      MyColors.color6()[-200]!,
                      MyColors.color6()[200]!
                    ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  icon: const AssetImage("assets/icons/ziyara.png"),
                  iconBackground: Colors.transparent,
                  route: () {
                    Navigator.of(context).pushNamed("/ziyarat/");
                  },
                ),
                /*HomeCard(
                  title: "Marja Books",
                  description: "A collection of books\nfrom our Maraje",
                  gradient: LinearGradient(
                      colors: [MyColors.emerald()[0]!, MyColors.emerald()[100]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  icon: const AssetImage("assets/icons/books.png"),
                  iconBackground: Colors.transparent,
                  route: () {
                    Navigator.of(context).pushNamed("/marja/");
                  },
                ),*/
                HomeCard(
                  title: "Contact Us",
                  description: "Feedback, inquiries,\nand support",
                  gradient: LinearGradient( 
                    colors: [
                      MyColors.color7()[-200]!,
                      MyColors.color7()[200]!
                    ],
                     begin: Alignment.topLeft, end: Alignment.bottomRight),
                  icon: const AssetImage("assets/icons/email.png"),
                  iconBackground: Colors.transparent,
                  route: () {
                    Navigator.of(context).pushNamed("/contact/");
                  },
                ),
              ]));
  }
}

int hourIn24(int hour) {
  if (hour <= 12 && hour >= 1) {
    return hour;
  } else if (hour == 0){
    return 12;
  }else{
    return hour - 12;
  }
}

String lessThan10(int i) {
  if (i < 10){
    return '0$i';
  } else{
    return '$i';
  }
}

import 'package:background_fetch/background_fetch.dart';
import 'package:prayers_times/prayers_times.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:lat_lng_to_timezone/lat_lng_to_timezone.dart' as tzmap;


Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
    //permission = await Geolocator.requestPermission();
    //if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale 
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
    return Position(longitude: 0, latitude: 0,
    timestamp: DateTime.now(), accuracy: 0, altitude: 0,
    altitudeAccuracy: 0, heading: 0, headingAccuracy: 0, speed: 0, speedAccuracy: 0);
  }

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the 
    // App to enable the location services.
    return Position(longitude: 0, latitude: 0,
    timestamp: DateTime.now(), accuracy: 0, altitude: 0,
    altitudeAccuracy: 0, heading: 0, headingAccuracy: 0, speed: 0, speedAccuracy: 0);
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  print("end of here");
  return await Geolocator.getCurrentPosition();
}

Future<List<DateTime>> prayerTimes() async {
  SharedPreferences prefs;
  prefs = await SharedPreferences.getInstance();
  Position geo;
  bool highLat;


  if (prefs.getDouble('latitude') != null &&
      prefs.getDouble('longitude') != null &&
      prefs.getDouble('altitude') != null) {
    geo = Position(longitude: prefs.getDouble('longitude')!, latitude: prefs.getDouble('latitude')!,
    timestamp: DateTime.now(), accuracy: 0, altitude: prefs.getDouble('altitude')!,
    altitudeAccuracy: 0, heading: 0, headingAccuracy: 0, speed: 0, speedAccuracy: 0);
  } else {
    geo = await determinePosition();
    prefs.setDouble('latitude', geo.latitude);
    prefs.setDouble('longitude', geo.longitude);
    prefs.setDouble('altitude', geo.altitude);
  }

  if (prefs.getBool('highLat') != null) {
    highLat = prefs.getBool('highLat')!;
  } else {
    highLat = false;
  }
  
  PrayerTimes prayers = PrayerTimes(coordinates: Coordinates(geo.longitude, geo.latitude),
  calculationParameters: PrayerCalculationMethod.tehran(), locationName: tzmap.latLngToTimezoneString(geo.latitude, geo.longitude));
  DateTime midnight = DateTime(0);

  if (prefs.getInt('fajrOffset') == null) prefs.setInt('fajrOffset', 0);
  if (prefs.getInt('dhuhrOffset') == null) prefs.setInt('dhuhrOffset', 0);
  if (prefs.getInt('maghribOffset') == null) prefs.setInt('maghribOffset', 0);

  int fajrOffset = prefs.getInt('fajrOffset')!;
  int dhuhrOffset = prefs.getInt('dhuhrOffset')!;
  int maghribOffset = prefs.getInt('maghribOffset')!;
  //currentDate.add(Duration(days: 30));

  if (prefs.getInt('calcMethod') != null) {
    switch (prefs.getInt('calcMethod')) {
      case 0:
        prayers = PrayerTimes(
            coordinates: Coordinates(geo.latitude, geo.longitude),
            calculationParameters: PrayerCalculationParameters
              ('qom', 16, 14, maghribAngle: 4),
            locationName: tzmap.latLngToTimezoneString(geo.latitude, geo.longitude)
            );
        break;
      case 1:
        prayers = PrayerTimes(
            coordinates: Coordinates(geo.latitude, geo.longitude),
            calculationParameters: PrayerCalculationMethod.tehran(),
            locationName: tzmap.latLngToTimezoneString(geo.latitude, geo.longitude)
            );
        break;
    }
  } else {
    prayers = PrayerTimes(
      coordinates: Coordinates(geo.latitude, geo.longitude),
      calculationParameters: PrayerCalculationParameters
        ('qom', 16, 14, maghribAngle: 4),
      locationName: tzmap.latLngToTimezoneString(geo.latitude, geo.longitude)
      );
    prefs.setInt('calcMethod', 0);
  }
  DateTime sunset = PrayerTimes(coordinates: Coordinates(geo.latitude, geo.longitude), calculationParameters: PrayerCalculationMethod.other(), locationName: tzmap.latLngToTimezoneString(geo.latitude, geo.longitude)).maghribStartTime!;
  if (prefs.getInt('midnightMethod') != null) {
    switch (prefs.getInt('midnightMethod')) {
      case 0:
        midnight = sunset.add(Duration(
            minutes: (-sunset
                    .difference(prayers.fajrStartTime!.add(Duration(minutes:fajrOffset)).add(const Duration(days: 1)))
                    .inMinutes) ~/
                2));
        break;
      case 1:
        midnight = sunset.add(Duration(
            minutes: (-sunset
                    .difference(prayers.sunrise!.add(const Duration(days: 1)))
                    .inMinutes) ~/
                2));
        break;
    }
  } else {
    midnight = sunset.add(Duration(
      minutes: (-sunset
              .difference(prayers.fajrStartTime!.add(Duration(minutes:fajrOffset)).add(const Duration(days: 1)))
              .inMinutes) ~/
          2));
    prefs.setInt('midnightMethod', 0);
  }
  List<DateTime> salahTimes = [
    prayers.fajrStartTime!.add(Duration(minutes: -20 + fajrOffset)),
    highLat?prayers.sunrise!.add(Duration(minutes: fajrOffset- (prayers.calculationParameters.fajrAngle!/60*(prayers.sunrise!.add(const Duration(days: 1))
                    .difference(sunset!)
                    .inMinutes)).toInt())):
      prayers.fajrStartTime!.add(Duration(minutes: fajrOffset)),
    prayers.sunrise!,
    prayers.dhuhrStartTime!.add(Duration(minutes: dhuhrOffset)),
    sunset,
    prayers.maghribStartTime!.add(Duration(minutes: maghribOffset)),
    midnight
  ];
  print("end of here 2");
  return salahTimes;
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

setNotifcations(String taskId) async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  //flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
  //    AndroidFlutterLocalNotificationsPlugin>()!.requestNotificationsPermission();
  SharedPreferences prefs;
  prefs = await SharedPreferences.getInstance();
  
  List<DateTime> prayersTimes = await prayerTimes();
  bool fajrOn, dhuhrOn, maghribOn;
  if (prefs.getBool('fajrOn') == null) {
    await prefs.setBool('fajrOn', true);
    fajrOn = true;
  } else {
    fajrOn = prefs.getBool('fajrOn')!;
  }
  if (prefs.getBool('dhuhrOn') == null) {
    await prefs.setBool('dhuhrOn', true);
    dhuhrOn = true;
  } else {
    dhuhrOn = prefs.getBool('dhuhrOn')!;
  }
  if (prefs.getBool('maghribOn') == null) {
    await prefs.setBool('maghribOn', true);
    maghribOn = true;
  } else {
    maghribOn = prefs.getBool('maghribOn')!;
  }

    
  
  NotificationDetails rammal = const NotificationDetails(
      android: AndroidNotificationDetails(
          'adhanChannelRammal', 'Adhan', 
          sound: RawResourceAndroidNotificationSound('rammal'),
          playSound: true,
          priority: Priority.max,
          importance: Importance.max,
          enableVibration: true,));
  NotificationDetails qatari = const NotificationDetails(
      android: AndroidNotificationDetails(
          'adhanChannelQatari', 'Adhan', 
          sound: RawResourceAndroidNotificationSound('qatari'),
          playSound: true,
          priority: Priority.max,
          importance: Importance.max,
          enableVibration: true));
  NotificationDetails dabbagh = const NotificationDetails(
      android: AndroidNotificationDetails(
          'adhanChannelDabbagh', 'Adhan', 
          sound: RawResourceAndroidNotificationSound('dabbagh'),
          playSound: true,
          priority: Priority.max,
          importance: Importance.max,
          enableVibration: true));
  NotificationDetails tlees = const NotificationDetails(
      android: AndroidNotificationDetails('adhanChannelTlees', 'Adhan', 
          sound: RawResourceAndroidNotificationSound('tlees'),
          playSound: true,
          priority: Priority.max,
          importance: Importance.max,
          enableVibration: true));
  NotificationDetails vibrate = const NotificationDetails(
      android: AndroidNotificationDetails('adhanChannelTlees', 'Adhan', 
          playSound: false,
          priority: Priority.max,
          importance: Importance.max,
          enableVibration: true));

  NotificationDetails notifcationdetails = rammal;
  // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_launcher');
  /*final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
          onDidReceiveLocalNotification: (a, b, c, d) async {});*/
  flutterLocalNotificationsPlugin.initialize(const InitializationSettings(
      android: initializationSettingsAndroid));
  tz.initializeTimeZones();
  if (prefs.getInt('adhanRecitor') != null) {
    switch (prefs.getInt('adhanRecitor')) {
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
  } else {
    prefs.setInt('adhanRecitor', 0);
    notifcationdetails = rammal;
  }

  if (fajrOn && prayersTimes[1].isAfter(DateTime.now())) {
    flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        "Time to pray!",
        "Time to pray Fajr!",
        tz.TZDateTime.from(prayersTimes[1], tz.local),
        notifcationdetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
  }
  if (dhuhrOn && prayersTimes[3].isAfter(DateTime.now())) {
    flutterLocalNotificationsPlugin.zonedSchedule(
        1,
        "Time to pray!",
        "Time to pray Dhuhr!",
        tz.TZDateTime.from(prayersTimes[3], tz.local),
        notifcationdetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
  }
  if (maghribOn && prayersTimes[5].isAfter(DateTime.now())) {
    flutterLocalNotificationsPlugin.zonedSchedule(
        2,
        "Time to pray!",
        "Time to pray Maghrib!",
        tz.TZDateTime.from(prayersTimes[5], tz.local),
        notifcationdetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
  }
  prefs.setString("lastFetch", DateTime.now().toString());
  print(DateTime.now().toString());
  var i = 0;
  try {
    if (prefs.containsKey('numOfFetches')) i = prefs.getInt("numOfFetches")!;
  } catch (e) {
    i = 0;
  }
  prefs.setInt('numOfFetches', i + 1);
  print("end of here 3");
  BackgroundFetch.finish(taskId);
}

import 'package:audiopoli_mobile/controllers/app_controller.dart';
import 'dart:async';
import 'dart:math';
import 'package:audiopoli_mobile/map_container.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'custom_marker_provider.dart';
import 'firebase_options.dart';
import 'incident_data.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'controllers/app_controller.dart';
import 'package:get/get.dart';

IncidentData sampledata = IncidentData(date: "2024-02-08", time: "01:08:41", latitude: 37.505486, longitude: 126.958511, sound: "대충 base64", category: 6, detail: 15, isCrime: -1, id: 256, departureTime: "00:00:00", caseEndTime: "11:11:11");


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.notification != null) {
    print("백그라운드 메시지 처리 ... ${message.notification!.body}");
  } else {
    print("백그라운드 메시지 처리 ... 메시지에 알림이 포함되어 있지 않습니다.");
  }
}

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await MarkerProvider().loadCustomMarker();
  final fcmToken = await FirebaseMessaging.instance.getToken();
  FirebaseDatabase.instance.ref('/users').update({"token": fcmToken});


  // const AndroidNotificationChannel androidNotificationChannel = AndroidNotificationChannel( 'high_importance_channel', 'High Importance Notifications', importance: Importance.max,);
  //
  // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  // await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(androidNotificationChannel);



  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler); //백그라운드 메시징 처리
  // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //   print('포그라운드 메시지 처리 ... ${message.notification!.body}');
  //
  //   if (message.notification != null) {
  //     print('포그라운드 메시지 처리 ... ${message.notification}');
  //   }

  // });
  runApp(MyApp());
  // loadData();
  // updateCaseEndTime(sampledata, "13:12:12");

}

class MyApp extends StatefulWidget {

  MyApp({super.key});

  final AppController c = Get.put(AppController());
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var logMap = new Map<String, dynamic>();

  final StreamController<Map<String, dynamic>> _logMapController = StreamController.broadcast();

  @override
  void initState() {
    super.initState();
    loadData();
  }


  void sendDataToDB() {
    final now = DateTime.now();
    final dateFormatter = DateFormat('yyyy-MM-dd');
    final timeFormatter = DateFormat('HH:mm:ss');
    final date = dateFormatter.format(now);
    final time = timeFormatter.format(now);
    final latitude = double.parse(
        (Random().nextDouble() * (37.506700 - 37.504241) + 37.504241)
            .toStringAsFixed(6));
    final longitude = double.parse(
        (Random().nextDouble() * (126.959567 - 126.951557) + 126.951557)
            .toStringAsFixed(6));
    final detail = Random().nextInt(14) + 1;
    Map<int, int> detailToCategory = {
      1: 1, 2: 1, 3: 1, 4: 1,
      5: 2, 6: 2, 7: 2, 8: 2, 9: 2,
      10: 4, 11: 4,
      12: 3, 13: 3,
      14: 5,
      15: 6, 16: 6,
    };
    final category = detailToCategory[detail]!;

    IncidentData sampleData = IncidentData(
        date: date,
        time: time,
        latitude: latitude,
        longitude: longitude,
        sound: "대충 base64",
        category: category,
        detail: detail,
        isCrime: -1,
        id: Random().nextInt(10000),
        departureTime: "99:99:99",
        caseEndTime: "99:99:99"
    );

    final ref = FirebaseDatabase.instance.ref('/crime');
    final Map<String, Map> updates = {};
    updates[sampleData.id.toString()] = sampleData.toMap();
    ref.update(updates)
        .then((_) {
      if (kDebugMode) {
        print('success!');
      }
      // Data saved successfully!
    })
        .catchError((error) {
      if (kDebugMode) {
        print(error);
      }
      // The write failed…
    });
  }

  void loadData() {
    final ref = FirebaseDatabase.instance.ref("/");

    ref.onValue.listen((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      if(snapshot.exists)
      {
        var data = snapshot.value;
        Map<String, IncidentData> newLogMap = {};
        if(data is Map) {
          data.forEach((key, value) {
            IncidentData incident = IncidentData(
                date: value['date'],
                time: value['time'],
                latitude: value['latitude'],
                longitude: value['longitude'],
                sound: value['sound'],
                category: value['category'],
                detail: value['detail'],
                id: value['id'],
                isCrime: value['isCrime'],
                departureTime: value['departureTime'],
                caseEndTime: value['caseEndTime']
            );
            newLogMap[key] = incident;
          });
        }
        setState(() {
          logMap = newLogMap;
        });
        _logMapController.add(logMap);
      }
    });
  }

  void updateDepartureTime(IncidentData data, String time)
  {
    final ref = FirebaseDatabase.instance.ref("/${data.id.toString()}");

    ref.update({"departureTime": time})
        .then((_) {
      print('success!');
    })
        .catchError((error) {
      print(error);
    });
  }

  void updateCaseEndTime(IncidentData data, String time)
  {
    final ref = FirebaseDatabase.instance.ref("/${data.id.toString()}");

    ref.update({"caseEndTime": time})
        .then((_) {
      print('success!');
    })
        .catchError((error) {
      print(error);
    });
  }

  late GoogleMapController mapController;
  final LatLng _center = const LatLng(37.5058, 126.956);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void dispose() {
    _logMapController.close();
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("AudioPoli APP")),
        body: StreamBuilder<Map<String, dynamic>>(
          stream: _logMapController.stream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final updatedMap = snapshot.data!;
              return MapContainer(logMap: updatedMap);
            } else {
              return  Container(
                  child: CircularProgressIndicator(),
              );
            }
          },),
        floatingActionButton: FloatingActionButton(onPressed: sendDataToDB),
      ),
    );
  }
}


void loadData() {
  final ref = FirebaseDatabase.instance.ref("/crime");
  var logMap = new Map<String, dynamic>();

  ref.onValue.listen((DatabaseEvent event) {
    DataSnapshot snapshot = event.snapshot;
    if(snapshot.exists)
    {
      var data = snapshot.value;
      if(data is Map) {
        data.forEach((key, value) {
          IncidentData incident = IncidentData(
              date: value['date'],
              time: value['time'],
              latitude: value['latitude'],
              longitude: value['longitude'],
              sound: value['sound'],
              category: value['category'],
              detail: value['detail'],
              id: value['id'],
              isCrime: value['isCrime'],
              departureTime: value['departureTime'],
              caseEndTime: value['caseEndTime']
          );
          logMap[key] = incident;
          print(logMap);
        });
      }
    }
  });
}

void updateDepartureTime(IncidentData data, String time)
{
  final ref = FirebaseDatabase.instance.ref("/crime/${data.id.toString()}");

  ref.update({"departureTime": time})
      .then((_) {
    print('success!');
  })
      .catchError((error) {
    print(error);
  });
}

void updateCaseEndTime(IncidentData data, String time)
{
  final ref = FirebaseDatabase.instance.ref("/crime/${data.id.toString()}");

  ref.update({"caseEndTime": time})
      .then((_) {
    print('success!');
  })
      .catchError((error) {
    print(error);
  });
}

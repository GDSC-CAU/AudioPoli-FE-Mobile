import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'incidentData.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

IncidentData sampledata = IncidentData(date: "2024-02-08", time: "01:08:41", latitude: 37.505486, longitude: 126.958511, sound: "대충 base64", category: 6, detail: 15, isCrime: false, id: 256, departureTime: "00:00:00", caseEndTime: "11:11:11");


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
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final fcmToken = await FirebaseMessaging.instance.getToken();
  print(fcmToken);
  runApp(const MyApp());
  // loadData();
  // updateCaseEndTime(sampledata, "13:12:12");

}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("AudioPoli APP")),
        body: Container(
          child: Center(child: Text("For test"),),
        ),
      ),
    );
  }
}


void loadData() {
  final ref = FirebaseDatabase.instance.ref("/");
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
Future<IncidentData> fetchIncidentData() async {
  IncidentData sampleData = IncidentData(
    date: "2012-01-26",
    time: "13:51:50",
    latitude: 37.5058,
    longitude: 126.956,
    sound: "대충 base64",
    category: 5,
    detail: 3,
    isCrime: 1,
    id: 1,
    departureTime: "",
    caseEndTime: "",
  );
  return sampleData;
}

class IncidentData {
  final String date;
  final String time;
  final double latitude;
  final double longitude;
  final String sound;
  final int category;
  final int detail;
  final int id;
  late final int isCrime;
  late final String departureTime;
  late final String caseEndTime;


  IncidentData({
    required this.date,
    required this.time,
    required this.latitude,
    required this.longitude,
    required this.sound,
    required this.category,
    required this.detail,
    required this.isCrime,
    required this.id,
    required this.departureTime,
    required this.caseEndTime
  });

  factory IncidentData.fromJson(Map<String, dynamic> json) {
    return IncidentData(
        date: json['date'],
        time: json['time'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        sound: json['sound'],
        category: json['category'],
        detail: json['detail'],
        isCrime: json['isCrime'],
        id: json['id'],
        departureTime: json['departureTime'],
        caseEndTime: json['caseEndTime']
    );
  }

  Map<dynamic, dynamic> toMap() {
    return {
      "date": date,
      "time": time,
      "latitude": latitude,
      "longitude": longitude,
      "sound": sound,
      "category": category,
      "detail": detail,
      "isCrime": isCrime,
      "id": id,
      "departureTime": departureTime,
      "caseEndTime": caseEndTime
    };
  }
}
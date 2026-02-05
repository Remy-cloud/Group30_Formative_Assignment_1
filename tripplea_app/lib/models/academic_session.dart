import 'dart:convert';

enum SessionType { classSession, masterySession, studyGroup, pslMeeting }

class AcademicSession {
  final String id;
  String title;
  DateTime date;
  DateTime startTime;
  DateTime endTime;
  String? location;
  SessionType sessionType;
  bool? attended; // null = not recorded, true = present, false = absent

  AcademicSession({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.location,
    required this.sessionType,
    this.attended,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'location': location,
      'sessionType': sessionType.index,
      'attended': attended,
    };
  }

  factory AcademicSession.fromJson(Map<String, dynamic> json) {
    return AcademicSession(
      id: json['id'],
      title: json['title'],
      date: DateTime.parse(json['date']),
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      location: json['location'],
      sessionType: SessionType.values[json['sessionType']],
      attended: json['attended'],
    );
  }

  static String encodeList(List<AcademicSession> sessions) {
    return jsonEncode(sessions.map((s) => s.toJson()).toList());
  }

  static List<AcademicSession> decodeList(String jsonString) {
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => AcademicSession.fromJson(json)).toList();
  }

  AcademicSession copyWith({
    String? id,
    String? title,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    SessionType? sessionType,
    bool? attended,
  }) {
    return AcademicSession(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      sessionType: sessionType ?? this.sessionType,
      attended: attended ?? this.attended,
    );
  }

  String get sessionTypeDisplayName {
    switch (sessionType) {
      case SessionType.classSession:
        return 'Class';
      case SessionType.masterySession:
        return 'Mastery Session';
      case SessionType.studyGroup:
        return 'Study Group';
      case SessionType.pslMeeting:
        return 'PSL Meeting';
    }
  }
}
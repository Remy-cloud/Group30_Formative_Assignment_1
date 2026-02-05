import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/assignment.dart';
import '../models/academic_session.dart';

/// This provider manages all app data: assignments, sessions, and attendance
/// Data is saved to device storage using shared_preferences
class DataProvider extends ChangeNotifier {
  // Keys for storing data
  static const String _assignmentsKey = 'assignments';
  static const String _sessionsKey = 'sessions';

  // Lists to store our data
  List<Assignment> _assignments = [];
  List<AcademicSession> _sessions = [];

  // Constructor - load saved data when created
  DataProvider() {
    loadData();
  }

  /// Load data from device storage
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load assignments
    final assignmentsJson = prefs.getString(_assignmentsKey);
    if (assignmentsJson != null && assignmentsJson.isNotEmpty) {
      _assignments = Assignment.decodeList(assignmentsJson);
    }

    // Load sessions
    final sessionsJson = prefs.getString(_sessionsKey);
    if (sessionsJson != null && sessionsJson.isNotEmpty) {
      _sessions = AcademicSession.decodeList(sessionsJson);
    }

    notifyListeners();
  }

  /// Save data to device storage
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    // Save assignments
    await prefs.setString(_assignmentsKey, Assignment.encodeList(_assignments));

    // Save sessions
    await prefs.setString(_sessionsKey, AcademicSession.encodeList(_sessions));
  }

  // Getters to access data
  List<Assignment> get assignments => _assignments;
  List<AcademicSession> get sessions => _sessions;

  // Get assignments sorted by due date
  List<Assignment> get assignmentsByDueDate {
    final sorted = List<Assignment>.from(_assignments);
    sorted.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return sorted;
  }

  // Get pending (incomplete) assignments
  List<Assignment> get pendingAssignments {
    return _assignments.where((a) => !a.isCompleted).toList();
  }

  // Get assignments due within next 7 days
  List<Assignment> get assignmentsDueInSevenDays {
    final now = DateTime.now();
    final sevenDaysLater = now.add(const Duration(days: 7));
    return assignmentsByDueDate.where((a) {
      return !a.isCompleted &&
          a.dueDate.isAfter(now.subtract(const Duration(days: 1))) &&
          a.dueDate.isBefore(sevenDaysLater);
    }).toList();
  }

  // Get today's sessions
  List<AcademicSession> get todaySessions {
    final now = DateTime.now();
    return _sessions.where((s) {
      return s.date.year == now.year &&
          s.date.month == now.month &&
          s.date.day == now.day;
    }).toList();
  }

  // Get sessions for a specific week
  List<AcademicSession> getSessionsForWeek(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 7));
    return _sessions.where((s) {
      return s.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          s.date.isBefore(weekEnd);
    }).toList();
  }

  // Calculate attendance percentage
  double get attendancePercentage {
    final sessionsWithAttendance =
        _sessions.where((s) => s.attended != null).toList();
    if (sessionsWithAttendance.isEmpty) return 100.0;

    final presentCount =
        sessionsWithAttendance.where((s) => s.attended == true).length;
    return (presentCount / sessionsWithAttendance.length) * 100;
  }

  // Check if attendance is below 75%
  bool get isAttendanceLow => attendancePercentage < 75;

  // Calculate current academic week (assuming term started Jan 6, 2026)
  int get currentAcademicWeek {
    final termStart = DateTime(2026, 1, 6); // Adjust this date as needed
    final now = DateTime.now();
    final difference = now.difference(termStart).inDays;
    return (difference ~/ 7) + 1;
  }

  // ===== ASSIGNMENT OPERATIONS =====

  void addAssignment(Assignment assignment) {
    _assignments.add(assignment);
    _saveData(); // Save to device
    notifyListeners();
  }

  void updateAssignment(Assignment updated) {
    final index = _assignments.indexWhere((a) => a.id == updated.id);
    if (index != -1) {
      _assignments[index] = updated;
      _saveData(); // Save to device
      notifyListeners();
    }
  }

  void deleteAssignment(String id) {
    _assignments.removeWhere((a) => a.id == id);
    _saveData(); // Save to device
    notifyListeners();
  }

  void toggleAssignmentComplete(String id) {
    final index = _assignments.indexWhere((a) => a.id == id);
    if (index != -1) {
      _assignments[index].isCompleted = !_assignments[index].isCompleted;
      _saveData(); // Save to device
      notifyListeners();
    }
  }

  // SESSION OPERATIONS

  void addSession(AcademicSession session) {
    _sessions.add(session);
    _saveData(); 
    notifyListeners();
  }

  void updateSession(AcademicSession updated) {
    final index = _sessions.indexWhere((s) => s.id == updated.id);
    if (index != -1) {
      _sessions[index] = updated;
      _saveData(); 
      notifyListeners();
    }
  }

  void deleteSession(String id) {
    _sessions.removeWhere((s) => s.id == id);
    _saveData(); // Save to device
    notifyListeners();
  }

  void recordAttendance(String id, bool present) {
    final index = _sessions.indexWhere((s) => s.id == id);
    if (index != -1) {
      _sessions[index].attended = present;
      _saveData(); // Save to device
      notifyListeners();
    }
  }
}
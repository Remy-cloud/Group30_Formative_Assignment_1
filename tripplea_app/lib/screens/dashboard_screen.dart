import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../datastorage/data_provider.dart';
import '../models/assignment.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DataProvider>(context);
    final now = DateTime.now();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date and Week Card
              _buildDateCard(now, provider.currentAcademicWeek),
              const SizedBox(height: 16),

              // Attendance Card with Warning
              _buildAttendanceCard(provider),
              const SizedBox(height: 16),

              // Today's Sessions
              _buildSectionTitle('Today\'s Sessions'),
              _buildTodaySessions(provider),
              const SizedBox(height: 16),

              // Upcoming Assignments (Due in 7 days)
              _buildSectionTitle('Assignments Due Soon'),
              _buildUpcomingAssignments(provider),
              const SizedBox(height: 16),

              // Summary Stats
              _buildSummaryCard(provider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateCard(DateTime now, int week) {
    return Card(
      color: AppColors.primaryBlue,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE').format(now),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                Text(
                  DateFormat('MMMM d, yyyy').format(now),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryOrange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Week $week',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceCard(DataProvider provider) {
    final percentage = provider.attendancePercentage;
    final isLow = provider.isAttendanceLow;

    return Card(
      color: isLow ? AppColors.error.withOpacity(0.1) : AppColors.lightGrey,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isLow ? Icons.warning_rounded : Icons.check_circle,
              color: isLow ? AppColors.error : AppColors.success,
              size: 40,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Attendance',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isLow ? AppColors.error : AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            if (isLow)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Below 75%!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildTodaySessions(DataProvider provider) {
    final sessions = provider.todaySessions;

    if (sessions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No sessions scheduled for today'),
        ),
      );
    }

    return Column(
      children: sessions.map((session) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.event, color: AppColors.primaryOrange),
            title: Text(session.title),
            subtitle: Text(
              '${DateFormat('HH:mm').format(session.startTime)} - ${DateFormat('HH:mm').format(session.endTime)}',
            ),
            trailing: Text(
              session.sessionTypeDisplayName,
              style: const TextStyle(color: AppColors.lightBlue),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUpcomingAssignments(DataProvider provider) {
    final assignments = provider.assignmentsDueInSevenDays;

    if (assignments.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No assignments due in the next 7 days'),
        ),
      );
    }

    return Column(
      children: assignments.take(5).map((assignment) {
        final daysUntilDue =
            assignment.dueDate.difference(DateTime.now()).inDays;
        return Card(
          child: ListTile(
            leading: Icon(
              Icons.assignment,
              color: assignment.priority == Priority.high
                  ? AppColors.error
                  : AppColors.primaryOrange,
            ),
            title: Text(assignment.title),
            subtitle: Text(assignment.courseName),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: daysUntilDue <= 1 ? AppColors.error : AppColors.lightBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                daysUntilDue == 0
                    ? 'Today'
                    : daysUntilDue == 1
                        ? 'Tomorrow'
                        : '$daysUntilDue days',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSummaryCard(DataProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStat(
              'Pending',
              provider.pendingAssignments.length.toString(),
              Icons.pending_actions,
            ),
            _buildStat(
              'Today\'s Sessions',
              provider.todaySessions.length.toString(),
              Icons.today,
            ),
            _buildStat(
              'Due Soon',
              provider.assignmentsDueInSevenDays.length.toString(),
              Icons.alarm,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryOrange, size: 30),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}

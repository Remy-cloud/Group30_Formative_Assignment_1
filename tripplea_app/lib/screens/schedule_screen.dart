import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../datastorage/data_provider.dart';
import '../models/academic_session.dart';
import '../theme/app_theme.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late DateTime _selectedWeekStart;

  @override
  void initState() {
    super.initState();
    // Get the start of current week (Monday)
    final now = DateTime.now();
    _selectedWeekStart = now.subtract(Duration(days: now.weekday - 1));
  }

  void _previousWeek() {
    setState(() {
      _selectedWeekStart = _selectedWeekStart.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _selectedWeekStart = _selectedWeekStart.add(const Duration(days: 7));
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DataProvider>(context);
    final weekSessions = provider.getSessionsForWeek(_selectedWeekStart);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom header
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Schedule',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
            
            // Week navigation
            _buildWeekNavigator(),

            // Week days header
            _buildWeekDaysHeader(),

            // Sessions list
            Expanded(
              child: weekSessions.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy,
                              size: 80, color: AppColors.grey),
                          SizedBox(height: 16),
                          Text('No sessions this week',
                              style:
                                  TextStyle(fontSize: 18, color: AppColors.grey)),
                          Text('Tap + to schedule a session'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: weekSessions.length,
                      itemBuilder: (context, index) {
                        return _buildSessionCard(context, weekSessions[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWeekNavigator() {
    final weekEnd = _selectedWeekStart.add(const Duration(days: 6));
    return Container(
      color: AppColors.primaryBlue,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _previousWeek,
            icon: const Icon(Icons.chevron_left, color: Colors.white),
          ),
          Text(
            '${DateFormat('MMM d').format(_selectedWeekStart)} - ${DateFormat('MMM d, yyyy').format(weekEnd)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: _nextWeek,
            icon: const Icon(Icons.chevron_right, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDaysHeader() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final today = DateTime.now();

    return Container(
      color: AppColors.lightGrey,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final dayDate = _selectedWeekStart.add(Duration(days: index));
          final isToday = dayDate.year == today.year &&
              dayDate.month == today.month &&
              dayDate.day == today.day;

          return Column(
            children: [
              Text(
                days[index],
                style: TextStyle(
                  color: isToday ? AppColors.primaryOrange : AppColors.grey,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isToday ? AppColors.primaryOrange : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    dayDate.day.toString(),
                    style: TextStyle(
                      color: isToday ? Colors.white : AppColors.darkGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, AcademicSession session) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildSessionTypeIcon(session.sessionType),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      Text(
                        session.sessionTypeDisplayName,
                        style: const TextStyle(color: AppColors.lightBlue),
                      ),
                    ],
                  ),
                ),
                // Attendance toggle
                _buildAttendanceToggle(context, session),
              ],
            ),
            const Divider(),
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 16, color: AppColors.grey),
                const SizedBox(width: 4),
                Text(DateFormat('EEE, MMM d').format(session.date)),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16, color: AppColors.grey),
                const SizedBox(width: 4),
                Text(
                    '${DateFormat('HH:mm').format(session.startTime)} - ${DateFormat('HH:mm').format(session.endTime)}'),
              ],
            ),
            if (session.location != null && session.location!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on,
                      size: 16, color: AppColors.grey),
                  const SizedBox(width: 4),
                  Text(session.location!),
                ],
              ),
            ],
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showAddEditDialog(context, session),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: () => _confirmDelete(context, session),
                  icon: const Icon(Icons.delete,
                      size: 18, color: AppColors.error),
                  label: const Text('Delete',
                      style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionTypeIcon(SessionType type) {
    IconData icon;
    Color color;

    switch (type) {
      case SessionType.classSession:
        icon = Icons.school;
        color = AppColors.primaryBlue;
        break;
      case SessionType.masterySession:
        icon = Icons.psychology;
        color = AppColors.primaryOrange;
        break;
      case SessionType.studyGroup:
        icon = Icons.group;
        color = AppColors.lightBlue;
        break;
      case SessionType.pslMeeting:
        icon = Icons.handshake;
        color = AppColors.success;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildAttendanceToggle(BuildContext context, AcademicSession session) {
    return Column(
      children: [
        const Text('Attendance', style: TextStyle(fontSize: 10)),
        const SizedBox(height: 4),
        ToggleButtons(
          isSelected: [
            session.attended == true,
            session.attended == false,
          ],
          onPressed: (index) {
            Provider.of<DataProvider>(context, listen: false)
                .recordAttendance(session.id, index == 0);
          },
          borderRadius: BorderRadius.circular(8),
          selectedColor: Colors.white,
          fillColor:
              session.attended == true ? AppColors.success : AppColors.error,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 30),
          children: const [
            Icon(Icons.check, size: 18),
            Icon(Icons.close, size: 18),
          ],
        ),
      ],
    );
  }

  void _showAddEditDialog(BuildContext context, [AcademicSession? session]) {
    showDialog(
      context: context,
      builder: (context) => SessionFormDialog(session: session),
    );
  }

  void _confirmDelete(BuildContext context, AcademicSession session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Session'),
        content: Text('Are you sure you want to delete "${session.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<DataProvider>(context, listen: false)
                  .deleteSession(session.id);
              Navigator.pop(context);
            },
            child:
                const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// Form dialog for adding/editing sessions
class SessionFormDialog extends StatefulWidget {
  final AcademicSession? session;

  const SessionFormDialog({super.key, this.session});

  @override
  State<SessionFormDialog> createState() => _SessionFormDialogState();
}

class _SessionFormDialogState extends State<SessionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late DateTime _date;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late SessionType _sessionType;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.session?.title ?? '');
    _locationController =
        TextEditingController(text: widget.session?.location ?? '');
    _date = widget.session?.date ?? DateTime.now();
    _startTime = widget.session != null
        ? TimeOfDay.fromDateTime(widget.session!.startTime)
        : const TimeOfDay(hour: 9, minute: 0);
    _endTime = widget.session != null
        ? TimeOfDay.fromDateTime(widget.session!.endTime)
        : const TimeOfDay(hour: 10, minute: 0);
    _sessionType = widget.session?.sessionType ?? SessionType.classSession;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.session != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Session' : 'New Session'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Session Title *',
                  hintText: 'e.g., Data Structures Lecture',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Session type dropdown
              DropdownButtonFormField<SessionType>(
                value: _sessionType,
                decoration: const InputDecoration(labelText: 'Session Type'),
                items: SessionType.values.map((type) {
                  String label;
                  switch (type) {
                    case SessionType.classSession:
                      label = 'Class';
                      break;
                    case SessionType.masterySession:
                      label = 'Mastery Session';
                      break;
                    case SessionType.studyGroup:
                      label = 'Study Group';
                      break;
                    case SessionType.pslMeeting:
                      label = 'PSL Meeting';
                      break;
                  }
                  return DropdownMenuItem(value: type, child: Text(label));
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _sessionType = value);
                },
              ),
              const SizedBox(height: 16),

              // Date picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Text(DateFormat('EEE, MMM d, yyyy').format(_date)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() => _date = picked);
                  }
                },
              ),

              // Time pickers
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Start'),
                      subtitle: Text(_startTime.format(context)),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _startTime,
                        );
                        if (picked != null) {
                          setState(() => _startTime = picked);
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('End'),
                      subtitle: Text(_endTime.format(context)),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _endTime,
                        );
                        if (picked != null) {
                          setState(() => _endTime = picked);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Location field (optional)
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location (optional)',
                  hintText: 'e.g., Room 101',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveSession,
          child: Text(isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  void _saveSession() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<DataProvider>(context, listen: false);

      // Convert TimeOfDay to DateTime
      final startDateTime = DateTime(
        _date.year,
        _date.month,
        _date.day,
        _startTime.hour,
        _startTime.minute,
      );
      final endDateTime = DateTime(
        _date.year,
        _date.month,
        _date.day,
        _endTime.hour,
        _endTime.minute,
      );

      if (widget.session != null) {
        // Update existing
        provider.updateSession(
          widget.session!.copyWith(
            title: _titleController.text,
            date: _date,
            startTime: startDateTime,
            endTime: endDateTime,
            location: _locationController.text.isEmpty
                ? null
                : _locationController.text,
            sessionType: _sessionType,
          ),
        );
      } else {
        // Add new
        provider.addSession(
          AcademicSession(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: _titleController.text,
            date: _date,
            startTime: startDateTime,
            endTime: endDateTime,
            location: _locationController.text.isEmpty
                ? null
                : _locationController.text,
            sessionType: _sessionType,
          ),
        );
      }

      Navigator.pop(context);
    }
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../datastorage/data_provider.dart';
import '../models/assignment.dart';
import '../theme/app_theme.dart';

class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DataProvider>(context);
    final assignments = provider.assignmentsByDueDate;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom header
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Assignments',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
            // Content
            Expanded(
              child: assignments.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assignment_outlined,
                              size: 80, color: AppColors.grey),
                          SizedBox(height: 16),
                          Text('No assignments yet',
                              style: TextStyle(fontSize: 18, color: AppColors.grey)),
                          Text('Tap + to add your first assignment'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: assignments.length,
                      itemBuilder: (context, index) {
                        return _buildAssignmentCard(context, assignments[index]);
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

  Widget _buildAssignmentCard(BuildContext context, Assignment assignment) {
    final daysUntilDue = assignment.dueDate.difference(DateTime.now()).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Checkbox to mark complete
                Checkbox(
                  value: assignment.isCompleted,
                  onChanged: (value) {
                    Provider.of<DataProvider>(context, listen: false)
                        .toggleAssignmentComplete(assignment.id);
                  },
                  activeColor: AppColors.success,
                ),
                Expanded(
                  child: Text(
                    assignment.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration: assignment.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: assignment.isCompleted
                          ? AppColors.grey
                          : AppColors.primaryBlue,
                    ),
                  ),
                ),
                // Priority badge
                _buildPriorityBadge(assignment.priority),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assignment.courseName,
                    style: const TextStyle(color: AppColors.grey),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 16, color: AppColors.lightBlue),
                      const SizedBox(width: 4),
                      Text(
                        'Due: ${DateFormat('MMM d, yyyy').format(assignment.dueDate)}',
                        style: TextStyle(
                          color: daysUntilDue < 0
                              ? AppColors.error
                              : daysUntilDue <= 2
                                  ? AppColors.warning
                                  : AppColors.lightBlue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showAddEditDialog(context, assignment),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: () => _confirmDelete(context, assignment),
                  icon:
                      const Icon(Icons.delete, size: 18, color: AppColors.error),
                  label:
                      const Text('Delete', style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(Priority priority) {
    Color color;
    String label;

    switch (priority) {
      case Priority.high:
        color = AppColors.error;
        label = 'High';
        break;
      case Priority.medium:
        color = AppColors.warning;
        label = 'Medium';
        break;
      case Priority.low:
        color = AppColors.success;
        label = 'Low';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, [Assignment? assignment]) {
    showDialog(
      context: context,
      builder: (context) => AssignmentFormDialog(assignment: assignment),
    );
  }

  void _confirmDelete(BuildContext context, Assignment assignment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Assignment'),
        content: Text('Are you sure you want to delete "${assignment.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<DataProvider>(context, listen: false)
                  .deleteAssignment(assignment.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// Form dialog for adding/editing assignments
class AssignmentFormDialog extends StatefulWidget {
  final Assignment? assignment;

  const AssignmentFormDialog({super.key, this.assignment});

  @override
  State<AssignmentFormDialog> createState() => _AssignmentFormDialogState();
}

class _AssignmentFormDialogState extends State<AssignmentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _courseController;
  late DateTime _dueDate;
  late Priority _priority;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.assignment?.title ?? '');
    _courseController =
        TextEditingController(text: widget.assignment?.courseName ?? '');
    _dueDate = widget.assignment?.dueDate ?? DateTime.now().add(const Duration(days: 7));
    _priority = widget.assignment?.priority ?? Priority.medium;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.assignment != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Assignment' : 'New Assignment'),
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
                  labelText: 'Title *',
                  hintText: 'Assignment title',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Course field
              TextFormField(
                controller: _courseController,
                decoration: const InputDecoration(
                  labelText: 'Course Name *',
                  hintText: 'e.g., Data Structures',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a course name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Due date picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Due Date'),
                subtitle: Text(DateFormat('MMM d, yyyy').format(_dueDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() => _dueDate = picked);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Priority dropdown
              DropdownButtonFormField<Priority>(
                value: _priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: Priority.values.map((p) {
                  return DropdownMenuItem(
                    value: p,
                    child: Text(p.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _priority = value);
                },
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
          onPressed: _saveAssignment,
          child: Text(isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  void _saveAssignment() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<DataProvider>(context, listen: false);

      if (widget.assignment != null) {
        // Update existing
        provider.updateAssignment(
          widget.assignment!.copyWith(
            title: _titleController.text,
            courseName: _courseController.text,
            dueDate: _dueDate,
            priority: _priority,
          ),
        );
      } else {
        // Add new
        provider.addAssignment(
          Assignment(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: _titleController.text,
            courseName: _courseController.text,
            dueDate: _dueDate,
            priority: _priority,
          ),
        );
      }

      Navigator.pop(context);
    }
  }
}
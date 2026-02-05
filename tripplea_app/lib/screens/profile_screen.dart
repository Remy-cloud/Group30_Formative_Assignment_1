import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import 'signup_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = '';
  String _email = '';
  String _program = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('user_name') ?? 'Student';
      _email = prefs.getString('user_email') ?? 'email@alustudent.com';
      _program = prefs.getString('user_program') ?? 'Not set';
      _isLoading = false;
    });
  }

  Future<void> _editProfile() async {
    final nameController = TextEditingController(text: _name);
    final emailController = TextEditingController(text: _email);
    final programController = TextEditingController(text: _program);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: programController,
                decoration: const InputDecoration(labelText: 'Program'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('user_name', nameController.text);
              await prefs.setString('user_email', emailController.text);
              await prefs.setString('user_program', programController.text);
              
              Navigator.pop(context);
              _loadProfile(); // Reload profile
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout? Your data will be cleared.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clear all data
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignupScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Profile Avatar
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primaryBlue,
                child: Text(
                  _name.isNotEmpty ? _name[0].toUpperCase() : 'S',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Name
              Text(
                _name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              
              Text(
                _email,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.grey,
                ),
              ),
              
              const SizedBox(height: 24),

              // Profile Info Cards
              _buildInfoCard(Icons.school, 'Program', _program),
              
              const SizedBox(height: 24),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _editProfile,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: const Text('Logout', style: TextStyle(color: AppColors.error)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // App Info
              const Text(
                'Study Partner',
                style: TextStyle(
                  color: AppColors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Version 1.0.0',
                style: TextStyle(color: AppColors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryOrange),
        ),
        title: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
      ),
    );
  }
}
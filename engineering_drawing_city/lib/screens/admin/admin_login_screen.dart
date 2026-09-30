import 'package:flutter/material.dart';

import 'package:engineering_drawing_city/models/app_settings_model.dart';
import 'package:engineering_drawing_city/models/course_model.dart';
import 'package:engineering_drawing_city/models/payment_model.dart';
import 'package:engineering_drawing_city/models/video_model.dart';
import 'package:engineering_drawing_city/services/firebase_service.dart';
import 'package:engineering_drawing_city/theme/app_theme.dart';

class AdminLoginScreen extends StatefulWidget {
  static const String routeName = '/admin-login';
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAdminLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.signInWithEmailPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (user.role == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin-dashboard');
      } else {
        setState(() {
          _errorMessage = 'Access denied. This account does not possess administrator credentials.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              color: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1E293B),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings,
                            size: 38,
                            color: AppTheme.accentGold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Administrator Portal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkNavy,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Course, Video & Payment Verification Console',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      ),
                      const SizedBox(height: 24),

                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Admin Email',
                          prefixIcon: Icon(Icons.security, color: AppTheme.primaryBlue),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Please enter email' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Master Password',
                          prefixIcon: Icon(Icons.lock_outline, color: AppTheme.primaryBlue),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Please enter password' : null,
                      ),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: AppTheme.errorRed, fontSize: 12),
                        ),
                      ],

                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E293B),
                          foregroundColor: AppTheme.accentGold,
                        ),
                        onPressed: _isLoading ? null : _handleAdminLogin,
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(color: AppTheme.accentGold),
                              )
                            : const Text('Enter Admin Console'),
                      ),
                      const SizedBox(height: 14),
                      TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                        child: const Text('Return to Student Login'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AdminDashboardScreen extends StatefulWidget {
  static const String routeName = '/admin-dashboard';
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings, color: AppTheme.accentGold),
            SizedBox(width: 10),
            Text('Admin Management Console'),
          ],
        ),
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: AppTheme.accentCyan),
            icon: const Icon(Icons.school, size: 18),
            label: const Text('Student View'),
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentGold,
          labelColor: AppTheme.accentGold,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_outlined), text: 'Overview'),
            Tab(icon: Icon(Icons.payments_outlined), text: 'Pending Payments'),
            Tab(icon: Icon(Icons.auto_stories_outlined), text: 'Manage Courses'),
            Tab(icon: Icon(Icons.settings_outlined), text: 'App Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildPaymentsTab(),
          _buildCoursesTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final courses = _firestoreService.getCoursesSync();
    final videos = _firestoreService.getVideosSync();
    final payments = _firestoreService.getAllPaymentsSync();
    final pendingCount = payments.where((p) => p.status == 'pending').length;
    final approvedCount = payments.where((p) => p.status == 'approved').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Portal Metrics & Performance',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.darkNavy),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildStatCard('Active Courses', '${courses.length}', Icons.menu_book, AppTheme.primaryBlue),
                  _buildStatCard('Video Lessons', '${videos.length}', Icons.ondemand_video, AppTheme.accentCyan),
                  _buildStatCard('Pending Payments', '$pendingCount', Icons.pending_actions, Colors.orange),
                  _buildStatCard('Approved Passes', '$approvedCount', Icons.verified, AppTheme.successGreen),
                ],
              ),
              const SizedBox(height: 32),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Admin Actions',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
                            icon: const Icon(Icons.add_circle_outline),
                            label: const Text('Add New Course'),
                            onPressed: () => _showAddCourseDialog(),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentCyan),
                            icon: const Icon(Icons.video_call),
                            label: const Text('Add Video Lesson'),
                            onPressed: () => _showAddVideoDialog(),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successGreen),
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Review Payments'),
                            onPressed: () => _tabController.animateTo(1),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              Icon(icon, color: color, size: 22),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsTab() {
    final payments = _firestoreService.getAllPaymentsSync();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 950),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Student Subscription Payments',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.darkNavy),
              ),
              const SizedBox(height: 6),
              const Text(
                'Approve submitted Mobile Money & bank transaction IDs to activate 30-day student passes.',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 20),
              if (payments.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: Text('No payment submissions recorded yet.')),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: payments.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final p = payments[index];
                    final isPending = p.status == 'pending';

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isPending
                                    ? Colors.orange.withOpacity(0.12)
                                    : AppTheme.successGreen.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isPending ? Icons.hourglass_top : Icons.check,
                                color: isPending ? Colors.orange : AppTheme.successGreen,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '\$${p.amount.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.darkNavy,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isPending ? Colors.orange : AppTheme.successGreen,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          p.status.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Ref: ${p.paymentReference} • Student: ${p.userId}',
                                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                                  ),
                                  Text(
                                    'Submitted: ${p.submittedAt.toLocal().toString().substring(0, 16)}',
                                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            if (isPending) ...[
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successGreen),
                                onPressed: () async {
                                  await _firestoreService.approvePayment(p.id);
                                  setState(() {});
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Payment ${p.paymentReference} approved! Subscription activated.')),
                                  );
                                },
                                child: const Text('Approve Pass'),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(foregroundColor: AppTheme.errorRed),
                                onPressed: () async {
                                  await _firestoreService.rejectPayment(p.id);
                                  setState(() {});
                                },
                                child: const Text('Reject'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoursesTab() {
    final courses = _firestoreService.getCoursesSync();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 950),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Engineering Curriculum Modules',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.darkNavy),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Course'),
                    onPressed: () => _showAddCourseDialog(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: courses.length,
                separatorBuilder: (c, i) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final c = courses[index];
                  final videos = _firestoreService.getVideosByCourseSync(c.id);

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryBlue,
                        child: Text('${c.order}', style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text(c.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${c.description}\n(${videos.length} videos linked)'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.video_call, color: AppTheme.primaryBlue),
                            tooltip: 'Add video to this course',
                            onPressed: () => _showAddVideoDialog(preselectedCourseId: c.id),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppTheme.errorRed),
                            tooltip: 'Delete Course',
                            onPressed: () async {
                              await _firestoreService.deleteCourse(c.id);
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTab() {
    final settings = _firestoreService.getAppSettingsSync();
    final nameCtrl = TextEditingController(text: settings.appName);
    final msgCtrl = TextEditingController(text: settings.welcomeMessage);
    final phoneCtrl = TextEditingController(text: settings.paymentNumber);
    final priceCtrl = TextEditingController(text: settings.subscriptionPrice.toString());
    final instrCtrl = TextEditingController(text: settings.paymentInstructions);
    bool aiActive = settings.aiEnabled;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 750),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Application & Payment Parameters',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Portal Name'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: msgCtrl,
                    decoration: const InputDecoration(labelText: 'Welcome Banner Header'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneCtrl,
                    decoration: const InputDecoration(labelText: 'Payment Mobile Number (e.g. 0772184445)'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceCtrl,
                    decoration: const InputDecoration(labelText: '30-Day Subscription Price (\$)'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: instrCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Payment Instructions'),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Enable AI Drawing Assistant for Students'),
                    value: aiActive,
                    onChanged: (v) => setState(() => aiActive = v),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
                    onPressed: () async {
                      final updated = AppSettingsModel(
                        appName: nameCtrl.text.trim(),
                        logo: settings.logo,
                        welcomeMessage: msgCtrl.text.trim(),
                        paymentNumber: phoneCtrl.text.trim(),
                        subscriptionPrice: double.tryParse(priceCtrl.text.trim()) ?? 10.0,
                        subscriptionDuration: settings.subscriptionDuration,
                        paymentInstructions: instrCtrl.text.trim(),
                        aiEnabled: aiActive,
                        contactInformation: settings.contactInformation,
                        maintenanceMode: settings.maintenanceMode,
                      );
                      await _firestoreService.updateAppSettings(updated);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Portal settings updated successfully!'),
                          backgroundColor: AppTheme.successGreen,
                        ),
                      );
                    },
                    child: const Text('Save Configuration'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddCourseDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final orderCtrl = TextEditingController(text: '${_firestoreService.getCoursesSync().length + 1}');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Create Engineering Course'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Course Title')),
            const SizedBox(height: 12),
            TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Description')),
            const SizedBox(height: 12),
            TextField(controller: orderCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Order Index')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.trim().isNotEmpty) {
                final course = CourseModel(
                  id: 'course_${DateTime.now().millisecondsSinceEpoch}',
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  imageUrl: '',
                  order: int.tryParse(orderCtrl.text.trim()) ?? 1,
                  isPublished: true,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                await _firestoreService.saveCourse(course);
                setState(() {});
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save Course'),
          ),
        ],
      ),
    );
  }

  void _showAddVideoDialog({String? preselectedCourseId}) {
    final courses = _firestoreService.getCoursesSync();
    if (courses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please create a course before adding video lessons.')),
      );
      return;
    }

    String selectedCourse = preselectedCourseId ?? courses.first.id;
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final ytCtrl = TextEditingController(text: 'dQw4w9WgXcQ');
    final orderCtrl = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add Video Lesson'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedCourse,
                  decoration: const InputDecoration(labelText: 'Assign to Course'),
                  items: courses.map((c) {
                    return DropdownMenuItem(value: c.id, child: Text(c.title));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedCourse = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Lesson Title')),
                const SizedBox(height: 12),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Lesson Description')),
                const SizedBox(height: 12),
                TextField(controller: ytCtrl, decoration: const InputDecoration(labelText: 'YouTube Video ID (e.g. WkL3SfvWz1U)')),
                const SizedBox(height: 12),
                TextField(controller: orderCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Lesson Order')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.trim().isNotEmpty) {
                  final video = VideoModel(
                    id: 'vid_${DateTime.now().millisecondsSinceEpoch}',
                    title: titleCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    youtubeVideoId: ytCtrl.text.trim(),
                    thumbnailUrl: '',
                    courseId: selectedCourse,
                    order: int.tryParse(orderCtrl.text.trim()) ?? 1,
                    isPublished: true,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  await _firestoreService.saveVideo(video);
                  setState(() {});
                }
                Navigator.pop(ctx);
              },
              child: const Text('Save Lesson'),
            ),
          ],
        ),
      ),
    );
  }
}
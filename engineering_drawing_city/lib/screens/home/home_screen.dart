import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:engineering_drawing_city/models/app_settings_model.dart';
import 'package:engineering_drawing_city/models/course_model.dart';
import 'package:engineering_drawing_city/models/payment_model.dart';
import 'package:engineering_drawing_city/models/subscription_model.dart';
import 'package:engineering_drawing_city/models/video_model.dart';
import 'package:engineering_drawing_city/services/firebase_service.dart';
import 'package:engineering_drawing_city/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.accentCyan.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.architecture, color: AppTheme.accentCyan, size: 22),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Engineering Drawing City',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Technical Drafting Portal',
                  style: TextStyle(fontSize: 11, color: AppTheme.accentCyan),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (_authService.isAdmin)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: AppTheme.accentGold.withOpacity(0.2),
                  foregroundColor: AppTheme.accentGold,
                ),
                icon: const Icon(Icons.admin_panel_settings, size: 18),
                label: const Text('Admin Panel', style: TextStyle(fontSize: 12)),
                onPressed: () => Navigator.pushNamed(context, '/admin-dashboard'),
              ),
            ),
          IconButton(
            tooltip: 'My Profile',
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.accentCyan,
              child: Text(
                (user?.name.isNotEmpty == true ? user!.name[0] : 'S').toUpperCase(),
                style: const TextStyle(
                  color: AppTheme.darkNavy,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/courses');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/ai-assistant');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/profile');
          } else {
            setState(() => _currentIndex = index);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppTheme.primaryBlue),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: AppTheme.primaryBlue),
            label: 'Courses',
          ),
          NavigationDestination(
            icon: Icon(Icons.psychology_outlined),
            selectedIcon: Icon(Icons.psychology, color: AppTheme.primaryBlue),
            label: 'AI Tutor',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppTheme.primaryBlue),
            label: 'Profile',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroBanner(),
                const SizedBox(height: 28),
                _buildFeaturedLessonsSection(),
                const SizedBox(height: 32),
                _buildCoursesSection(),
                const SizedBox(height: 32),
                _buildAITutorCallout(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    final user = _authService.currentUser;
    final userId = user?.uid ?? 'student_01';
    final sub = _firestoreService.getSubscriptionSync(userId);
    final isSubscribed = sub != null && sub.status == 'active';
    final appSettings = _firestoreService.getAppSettingsSync();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.darkNavy, AppTheme.secondaryNavy],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkNavy.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSubscribed
                            ? AppTheme.successGreen.withOpacity(0.2)
                            : AppTheme.accentGold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSubscribed ? AppTheme.successGreen : AppTheme.accentGold,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSubscribed ? Icons.verified : Icons.lock_clock,
                            size: 14,
                            color: isSubscribed ? AppTheme.successGreen : AppTheme.accentGold,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isSubscribed ? 'FULL PASS ACTIVE' : 'FREE PREVIEW MODE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isSubscribed ? AppTheme.successGreen : AppTheme.accentGold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Welcome back, ${user?.name ?? "Engineering Student"}!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      appSettings.welcomeMessage,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentCyan,
                  foregroundColor: AppTheme.darkNavy,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                icon: const Icon(Icons.play_circle_fill, size: 20),
                label: const Text('Continue Learning', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () => Navigator.pushNamed(context, '/courses'),
              ),
              if (!isSubscribed)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.accentGold,
                    side: const BorderSide(color: AppTheme.accentGold),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  icon: const Icon(Icons.star, size: 18),
                  label: const Text('Unlock All Modules (\$10)'),
                  onPressed: () => _showSubscriptionModal(context),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.event_available, color: Colors.white70, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Pass valid for 30 days',
                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedLessonsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Featured Video Lessons',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkNavy,
                  ),
                ),
                Text(
                  'Core curriculum videos with worked engineering problems',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
              ],
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/courses'),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<VideoModel>>(
          stream: _firestoreService.getVideos(),
          builder: (context, snapshot) {
            final videos = snapshot.data ?? _firestoreService.getVideosSync();
            if (videos.isEmpty) {
              return const Center(child: Text('No videos available'));
            }

            return SizedBox(
              height: 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: videos.length > 6 ? 6 : videos.length,
                itemBuilder: (context, index) {
                  final video = videos[index];
                  return _buildVideoCard(video);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildVideoCard(VideoModel video) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 18, bottom: 6),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/video-player',
              arguments: video,
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Video Thumbnail Area
              Container(
                height: 125,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryBlue, AppTheme.darkNavy],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.12,
                        child: CustomPaint(painter: GridPainter()),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        size: 32,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.ondemand_video, size: 10, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'HD VIDEO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Card Details
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkNavy,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      video.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoursesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Engineering Drawing Courses',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkNavy,
                  ),
                ),
                Text(
                  'Structured step-by-step drafting series',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
              ],
            ),
            TextButton.icon(
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Open All'),
              onPressed: () => Navigator.pushNamed(context, '/courses'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        StreamBuilder<List<CourseModel>>(
          stream: _firestoreService.getCourses(),
          builder: (context, snapshot) {
            final courses = snapshot.data ?? _firestoreService.getCoursesSync();

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: courses.length,
              separatorBuilder: (context, i) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final course = courses[index];
                final videos = _firestoreService.getVideosByCourseSync(course.id);

                return Card(
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      Navigator.pushNamed(context, '/courses');
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppTheme.accentCyanLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                '#0${course.order}',
                                style: const TextStyle(
                                  color: AppTheme.primaryBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  course.title,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.darkNavy,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  course.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.ondemand_video, size: 14, color: AppTheme.primaryBlue),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${videos.length} Video Lessons',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.primaryBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAITutorCallout() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.accentCyan.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology, size: 36, color: AppTheme.primaryBlue),
          ),
          const SizedBox(width: 18),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Have Questions on Projections or GD&T?',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkNavy,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Ask our AI Drawing Tutor for instant guidance on standards, symbols, and drafting rules.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: () => Navigator.pushNamed(context, '/ai-assistant'),
            child: const Text('Open AI Tutor', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _showSubscriptionModal(BuildContext context) {
    final settings = _firestoreService.getAppSettingsSync();
    final paymentController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.workspace_premium, color: AppTheme.accentGold, size: 28),
              SizedBox(width: 10),
              Text('Unlock All Video Modules', style: TextStyle(fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '\$${settings.subscriptionPrice.toStringAsFixed(2)} / ${settings.subscriptionDuration}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Full unrestricted access to all 5 courses & 14+ video lessons',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Payment Instructions:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  settings.paymentInstructions,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Send to: ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    SelectableText(
                      settings.paymentNumber,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 18, color: AppTheme.primaryBlue),
                      tooltip: 'Copy Number',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: settings.paymentNumber));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Payment number copied to clipboard!')),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: paymentController,
                  decoration: const InputDecoration(
                    labelText: 'Transaction Reference ID',
                    hintText: 'e.g. MM-TXN-991283',
                    prefixIcon: Icon(Icons.receipt_long),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successGreen),
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final ref = paymentController.text.trim().isEmpty
                          ? 'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'
                          : paymentController.text.trim();
                      setModalState(() => isSubmitting = true);

                      final user = _authService.currentUser;
                      final payment = PaymentModel(
                        id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
                        userId: user?.uid ?? 'student_01',
                        amount: settings.subscriptionPrice,
                        paymentReference: ref,
                        status: 'pending',
                        submittedAt: DateTime.now(),
                      );
                      await _firestoreService.savePayment(payment);

                      // Also activate instant test pass for user testing
                      await _firestoreService.activateSubscription(
                        userId: user?.uid ?? 'student_01',
                        paymentReference: ref,
                      );

                      if (!mounted) return;
                      Navigator.pop(ctx);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Payment submitted & Full Access Pass activated!'),
                          backgroundColor: AppTheme.successGreen,
                        ),
                      );
                    },
              child: const Text('Submit & Activate Pass'),
            ),
          ],
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0;

    const step = 20.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
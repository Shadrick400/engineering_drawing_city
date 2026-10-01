import 'package:flutter/material.dart';

import 'package:engineering_drawing_city/models/course_model.dart';
import 'package:engineering_drawing_city/models/video_model.dart';
import 'package:engineering_drawing_city/services/firebase_service.dart';
import 'package:engineering_drawing_city/theme/app_theme.dart';

class VideoPlayerScreen extends StatefulWidget {
  final VideoModel video;
  final CourseModel? course;

  const VideoPlayerScreen({
    super.key,
    required this.video,
    this.course,
  });

  static const String routeName = '/video-player';

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoModel _currentVideo;
  late CourseModel? _currentCourse;
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  bool _isPlaying = true;
  bool _isCompleted = false;
  double _playbackSpeed = 1.0;
  final Set<String> _completedLessonIds = {};

  @override
  void initState() {
    super.initState();
    _currentVideo = widget.video;
    _currentCourse = widget.course ??
        _firestoreService.getCoursesSync().firstWhere(
              (c) => c.id == widget.video.courseId,
              orElse: () => _firestoreService.getCoursesSync().first,
            );
  }

  bool _checkSubscription() {
    final user = _authService.currentUser;
    final userId = user?.uid ?? 'student_01';
    final sub = _firestoreService.getSubscriptionSync(userId);
    return sub != null && sub.status == 'active';
  }

  void _switchVideo(VideoModel newVideo) {
    setState(() {
      _currentVideo = newVideo;
      _isPlaying = true;
      _isCompleted = _completedLessonIds.contains(newVideo.id);
    });
  }

  void _navigateToPrevious() {
    final playlist = _firestoreService.getVideosByCourseSync(_currentVideo.courseId);
    final currentIndex = playlist.indexWhere((v) => v.id == _currentVideo.id);
    if (currentIndex > 0) {
      _switchVideo(playlist[currentIndex - 1]);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This is the first lesson in this module.')),
      );
    }
  }

  void _navigateToNext() {
    final playlist = _firestoreService.getVideosByCourseSync(_currentVideo.courseId);
    final currentIndex = playlist.indexWhere((v) => v.id == _currentVideo.id);
    if (currentIndex >= 0 && currentIndex < playlist.length - 1) {
      _switchVideo(playlist[currentIndex + 1]);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Congratulations! You completed all lessons in this module.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubscribed = _checkSubscription();
    final playlist = _firestoreService.getVideosByCourseSync(_currentVideo.courseId);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentVideo.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              _currentCourse?.title ?? 'Engineering Drawing Course',
              style: const TextStyle(fontSize: 11, color: AppTheme.accentCyan),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Course Curriculum',
            icon: const Icon(Icons.playlist_play),
            onPressed: () => _showPlaylistDrawer(context, playlist),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1050),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Video Screen Area
                _buildVideoPlayerFrame(isSubscribed),
                const SizedBox(height: 18),

                // Controls and Navigation Bar
                _buildNavigationRow(playlist),
                const SizedBox(height: 20),

                // Lesson Information & Metadata
                _buildLessonDetailsCard(),
                const SizedBox(height: 24),

                // Course Playlist Module
                _buildCoursePlaylistSection(playlist),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayerFrame(bool isSubscribed) {
    if (!isSubscribed) {
      return Container(
        height: 380,
        decoration: BoxDecoration(
          color: AppTheme.darkNavy,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_outline, size: 48, color: AppTheme.accentGold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Premium Video Lesson',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Subscribe to unlock full access to all step-by-step engineering drawing lessons.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGold,
                    foregroundColor: AppTheme.darkNavy,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                  icon: const Icon(Icons.workspace_premium),
                  label: const Text('Unlock with \$10 Pass', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => _showSubscriptionDialog(),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      height: 420,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Drafting Grid Background for Player
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: CustomPaint(painter: GridPainter()),
              ),
            ),

            // Video Center Preview
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.accentCyan.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentCyan.withOpacity(0.5),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                  child: IconButton(
                    iconSize: 48,
                    color: AppTheme.darkNavy,
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: () => setState(() => _isPlaying = !_isPlaying),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.accentCyan.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _isPlaying ? AppTheme.successGreen : Colors.amber,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isPlaying ? 'NOW STREAMING (HD 1080p)' : 'PAUSED',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'YouTube Ref ID: ${_currentVideo.youtubeVideoId}',
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),

            // Bottom Player Overlay Controls
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
                      onPressed: () => setState(() => _isPlaying = !_isPlaying),
                    ),
                    const Text('12:45 / 24:10', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        ),
                        child: Slider(
                          value: 0.52,
                          activeColor: AppTheme.accentCyan,
                          inactiveColor: Colors.white24,
                          onChanged: (v) {},
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    PopupMenuButton<double>(
                      tooltip: 'Playback Speed',
                      initialValue: _playbackSpeed,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${_playbackSpeed}x',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      onSelected: (speed) => setState(() => _playbackSpeed = speed),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 0.75, child: Text('0.75x')),
                        const PopupMenuItem(value: 1.0, child: Text('1.0x Normal')),
                        const PopupMenuItem(value: 1.25, child: Text('1.25x')),
                        const PopupMenuItem(value: 1.5, child: Text('1.5x')),
                        const PopupMenuItem(value: 2.0, child: Text('2.0x')),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.fullscreen, color: Colors.white),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Fullscreen mode toggled.')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationRow(List<VideoModel> playlist) {
    final currentIndex = playlist.indexWhere((v) => v.id == _currentVideo.id);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 550;

        final prevButton = OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          ),
          icon: const Icon(Icons.arrow_back, size: 16),
          label: const Text('Previous', style: TextStyle(fontSize: 12)),
          onPressed: currentIndex > 0 ? _navigateToPrevious : null,
        );

        final nextButton = OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          ),
          icon: const Icon(Icons.arrow_forward, size: 16),
          label: const Text('Next Lesson', style: TextStyle(fontSize: 12)),
          onPressed: currentIndex < playlist.length - 1 ? _navigateToNext : null,
        );

        final markDoneButton = ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _isCompleted ? AppTheme.successGreen : AppTheme.primaryBlue,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          icon: Icon(
            _isCompleted ? Icons.check_circle : Icons.check_circle_outline,
            size: 18,
          ),
          label: Text(
            _isCompleted ? 'Completed' : 'Mark Done',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            setState(() {
              _isCompleted = !_isCompleted;
              if (_isCompleted) {
                _completedLessonIds.add(_currentVideo.id);
              } else {
                _completedLessonIds.remove(_currentVideo.id);
              }
            });
          },
        );

        if (isNarrow) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: prevButton),
                  const SizedBox(width: 10),
                  Expanded(child: nextButton),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: markDoneButton,
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: prevButton),
            const SizedBox(width: 12),
            markDoneButton,
            const SizedBox(width: 12),
            Expanded(child: nextButton),
          ],
        );
      },
    );
  }

  Widget _buildLessonDetailsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_outlined, size: 14, color: AppTheme.errorRed),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      '🔒 In-App Streaming Only • Downloads Disabled',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.errorRed),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'MODULE #${_currentVideo.order}',
                    style: const TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _currentCourse?.title ?? '',
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _currentVideo.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkNavy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentVideo.description,
              style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursePlaylistSection(List<VideoModel> playlist) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Course Lessons (${playlist.length})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkNavy,
              ),
            ),
            Text(
              '${_completedLessonIds.length}/${playlist.length} Completed',
              style: const TextStyle(fontSize: 12, color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: playlist.length,
            separatorBuilder: (c, i) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = playlist[index];
              final isCurrent = item.id == _currentVideo.id;
              final isDone = _completedLessonIds.contains(item.id);

              return ListTile(
                tileColor: isCurrent ? AppTheme.accentCyanLight.withOpacity(0.5) : null,
                leading: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? AppTheme.primaryBlue
                        : isDone
                            ? AppTheme.successGreen
                            : Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      isDone
                          ? Icons.check
                          : isCurrent
                              ? Icons.play_arrow
                              : Icons.ondemand_video,
                      size: 16,
                      color: isCurrent || isDone ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ),
                title: Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                    color: isCurrent ? AppTheme.primaryBlue : AppTheme.darkNavy,
                  ),
                ),
                subtitle: Text(
                  item.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
                trailing: isCurrent
                    ? const Text(
                        'PLAYING',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      )
                    : null,
                onTap: () => _switchVideo(item),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showPlaylistDrawer(BuildContext context, List<VideoModel> playlist) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Lesson to Watch',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: playlist.length,
                separatorBuilder: (c, i) => const Divider(height: 1),
                itemBuilder: (c, i) {
                  final item = playlist[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryBlue,
                      child: Text('${item.order}', style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text(item.title),
                    onTap: () {
                      Navigator.pop(ctx);
                      _switchVideo(item);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSubscriptionDialog() {
    final settings = _firestoreService.getAppSettingsSync();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Unlock Premium Lessons'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Access all video modules for \$${settings.subscriptionPrice.toStringAsFixed(2)} / month.'),
            const SizedBox(height: 14),
            Text('Mobile Money Payment: ${settings.paymentNumber}'),
            const SizedBox(height: 14),
            const Text(
              'Click below to instantly activate 30 days of full access in demo mode.',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successGreen),
            onPressed: () async {
              final user = _authService.currentUser;
              await _firestoreService.activateSubscription(
                userId: user?.uid ?? 'student_01',
                paymentReference: 'DEMO-TXN-PASS',
              );
              Navigator.pop(ctx);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Full access activated! Enjoy learning.'),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            child: const Text('Activate Pass Now'),
          ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1.0;

    const step = 24.0;
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
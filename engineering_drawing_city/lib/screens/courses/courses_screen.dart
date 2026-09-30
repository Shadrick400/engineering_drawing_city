import 'package:flutter/material.dart';

import 'package:engineering_drawing_city/models/course_model.dart';
import 'package:engineering_drawing_city/models/video_model.dart';
import 'package:engineering_drawing_city/services/firebase_service.dart';
import 'package:engineering_drawing_city/theme/app_theme.dart';

class CoursesScreen extends StatefulWidget {
  static const String routeName = '/courses';
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _searchQuery = '';
  String? _selectedCourseId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Engineering Drawing Curriculum'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 950),
          child: Column(
            children: [
              // Search & Header
              Container(
                padding: const EdgeInsets.all(18),
                color: Colors.white,
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search courses, projections, GD&T, CAD, scales...',
                        prefixIcon: const Icon(Icons.search, color: AppTheme.primaryBlue),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => setState(() => _searchQuery = ''),
                              )
                            : null,
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                    ),
                  ],
                ),
              ),

              // Courses List
              Expanded(
                child: StreamBuilder<List<CourseModel>>(
                  stream: _firestoreService.getCourses(),
                  builder: (context, snapshot) {
                    final allCourses = snapshot.data ?? _firestoreService.getCoursesSync();
                    final filtered = allCourses.where((c) {
                      if (_searchQuery.isEmpty) return true;
                      return c.title.toLowerCase().contains(_searchQuery) ||
                          c.description.toLowerCase().contains(_searchQuery);
                    }).toList();

                    if (filtered.isEmpty) {
                      return const Center(
                        child: Text(
                          'No courses matched your search',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final course = filtered[index];
                        final videos = _firestoreService.getVideosByCourseSync(course.id);
                        final isExpanded = _selectedCourseId == course.id;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isExpanded ? AppTheme.primaryBlue : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  setState(() {
                                    _selectedCourseId = isExpanded ? null : course.id;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryBlue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '0${course.order}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primaryBlue,
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
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.darkNavy,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              course.description,
                                              style: const TextStyle(
                                                color: AppTheme.textMuted,
                                                fontSize: 13,
                                                height: 1.35,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.play_circle_outline,
                                                  size: 16,
                                                  color: AppTheme.primaryBlue,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  '${videos.length} Video Lessons',
                                                  style: const TextStyle(
                                                    color: AppTheme.primaryBlue,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  isExpanded ? 'Hide Lessons' : 'View Lessons',
                                                  style: const TextStyle(
                                                    color: AppTheme.primaryBlue,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Icon(
                                                  isExpanded
                                                      ? Icons.keyboard_arrow_up
                                                      : Icons.keyboard_arrow_down,
                                                  color: AppTheme.primaryBlue,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Expanded Lessons Accordion
                              if (isExpanded)
                                Container(
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.vertical(
                                      bottom: Radius.circular(16),
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Divider(height: 1),
                                      const SizedBox(height: 12),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                                        child: Text(
                                          'CURRICULUM LESSONS:',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textMuted,
                                            letterSpacing: 0.6,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      if (videos.isEmpty)
                                        const Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Text('No lessons uploaded yet for this course.'),
                                        )
                                      else
                                        ListView.separated(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: videos.length,
                                          separatorBuilder: (c, i) => const Divider(height: 12),
                                          itemBuilder: (ctx, vIndex) {
                                            final video = videos[vIndex];
                                            return ListTile(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(horizontal: 4),
                                              leading: Container(
                                                width: 36,
                                                height: 36,
                                                decoration: BoxDecoration(
                                                  color: AppTheme.primaryBlue,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Icon(
                                                  Icons.play_arrow,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                              title: Text(
                                                video.title,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.darkNavy,
                                                ),
                                              ),
                                              subtitle: Text(
                                                video.description,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: AppTheme.textMuted,
                                                ),
                                              ),
                                              trailing: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppTheme.primaryBlue,
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 8,
                                                  ),
                                                  textStyle: const TextStyle(fontSize: 12),
                                                ),
                                                onPressed: () {
                                                  Navigator.pushNamed(
                                                    context,
                                                    '/video-player',
                                                    arguments: {
                                                      'video': video,
                                                      'course': course,
                                                    },
                                                  );
                                                },
                                                child: const Text('Play'),
                                              ),
                                            );
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
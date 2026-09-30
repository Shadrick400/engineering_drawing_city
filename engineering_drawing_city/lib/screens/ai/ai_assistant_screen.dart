import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:engineering_drawing_city/models/app_settings_model.dart';
import 'package:engineering_drawing_city/services/firebase_service.dart';
import 'package:engineering_drawing_city/theme/app_theme.dart';

class AIAssistantScreen extends StatefulWidget {
  static const String routeName = '/ai-assistant';
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _aiEnabled = true;
  AppSettingsModel? _appSettings;

  final List<String> _quickPrompts = [
    '1st vs 3rd Angle Projections',
    'How to draw an Isometric Ellipse?',
    'What are GD&T Datum Symbols?',
    'Hole vs Shaft Basis (Limits & Fits)',
    'Sectional Hatching Angle & Rules',
    'Standard Drawing Sheet Sizes (A0-A4)',
  ];

  @override
  void initState() {
    super.initState();
    _loadAppSettings();
    _messages.add(
      ChatMessage(
        id: 'welcome_msg',
        text:
            'Hello! I am your Engineering Drawing & CAD AI Tutor. Ask me any question on orthographic projections, isometric views, dimensioning standards, GD&T, or mechanical drafting!',
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> _loadAppSettings() async {
    _appSettings = await _firestoreService.getAppSettings();
    if (!mounted) return;
    setState(() => _aiEnabled = _appSettings?.aiEnabled ?? true);
  }

  void _sendMessage([String? presetText]) {
    final text = (presetText ?? _messageController.text).trim();
    if (text.isEmpty) return;

    if (!_aiEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI Assistant is currently disabled in system settings.')),
      );
      return;
    }

    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        sender: MessageSender.user,
        timestamp: DateTime.now(),
      ));
      if (presetText == null) _messageController.clear();
      _isLoading = true;
    });

    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      final answer = _generateKnowledgeResponse(text);
      setState(() {
        _messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: answer,
          sender: MessageSender.ai,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
      _scrollToBottom();
    });
  }

  String _generateKnowledgeResponse(String query) {
    final q = query.toLowerCase();

    if (q.contains('1st') || q.contains('first angle') || q.contains('third angle') || q.contains('3rd')) {
      return '**First Angle vs Third Angle Projection:**\n\n'
          '• **First Angle Projection (ISO European standard):** The object is placed between the observer and the plane of projection (1st quadrant). Therefore:\n'
          '  - Top View is drawn **below** the Front View.\n'
          '  - Left Side View is drawn on the **right** of Front View.\n\n'
          '• **Third Angle Projection (ASME American standard):** The projection plane is placed between the observer and the object (3rd quadrant). Therefore:\n'
          '  - Top View is drawn **above** the Front View.\n'
          '  - Left Side View is drawn on the **left** of Front View.\n\n'
          'Standard projection symbols on the title block show a truncated cone to identify which system is used.';
    }

    if (q.contains('ellipse') || q.contains('isometric circle') || q.contains('four-centre') || q.contains('4 center')) {
      return '**Drawing Isometric Ellipses using the Four-Centre Method:**\n\n'
          '1. Draw an isometric rhombus with sides equal to the circle diameter (axes inclined at 30°).\n'
          '2. Locate the midpoints of all four sides of the rhombus.\n'
          '3. From the obtuse angle corners (120° vertices), draw lines to the opposite midpoints.\n'
          '4. The intersections of these lines provide 2 small arc centers (R1).\n'
          '5. The obtuse corners themselves serve as the 2 large arc centers (R2).\n'
          '6. Strike four tangent arcs to form a continuous isometric ellipse.';
    }

    if (q.contains('gd&t') || q.contains('datum') || q.contains('tolerance') || q.contains('feature control')) {
      return '**Geometric Dimensioning and Tolerancing (GD&T):**\n\n'
          '• **Feature Control Frame:** A rectangular box containing:\n'
          '  [ Geometric Symbol | Tolerance Value (e.g. ⌀0.05) | Datum References (A | B | C) ]\n\n'
          '• **Key Categories:**\n'
          '  - Form: Flatness (⏥), Straightness (—), Circularity (○), Cylindricity (⌭)\n'
          '  - Orientation: Perpendicularity (⟂), Parallelism (∥), Angularity (∠)\n'
          '  - Location: True Position (⌖), Concentricity (◎), Symmetry (⌯)\n'
          '  - Runout: Circular Runout (↗), Total Runout (⇗)\n\n'
          'Datums represent mathematically ideal reference planes or axes.';
    }

    if (q.contains('limits') || q.contains('fits') || q.contains('hole') || q.contains('shaft')) {
      return '**Limits and Fits in Mechanical Drafting:**\n\n'
          '• **Hole Basis System (Preferred):** Basic size is the minimum hole size (tolerance zone H, where lower deviation is zero).\n'
          '• **Shaft Basis System:** Basic size is the maximum shaft size (tolerance zone h, upper deviation is zero).\n\n'
          '• **Three Types of Fits:**\n'
          '  1. **Clearance Fit:** Hole is always larger than shaft (e.g., H7/g6, loose running/sliding).\n'
          '  2. **Transition Fit:** Tolerance zones overlap; may be tight or loose (e.g., H7/k6, location fit).\n'
          '  3. **Interference Fit:** Shaft is always larger than hole; requires press or heat (e.g., H7/p6, permanent press fit).';
    }

    if (q.contains('hatching') || q.contains('section') || q.contains('cutting plane')) {
      return '**Sectional Views & Hatching Conventions (ISO 128):**\n\n'
          '• Hatching lines are drawn as continuous thin lines (type B) inclined at **45°** to the principal outlines or centerlines.\n'
          '• Spacing between lines should be uniform (1.5mm to 3mm depending on drawing size).\n'
          '• Adjacent parts in an assembly must be hatched in opposite directions (45° left vs 45° right) or staggered pitches.\n'
          '• **Parts NEVER sectioned longitudinally:** Shafts, bolts, nuts, rivets, keys, pins, ribs/webs, and ball bearings.';
    }

    if (q.contains('sheet') || q.contains('a0') || q.contains('a1') || q.contains('a2') || q.contains('a3') || q.contains('a4')) {
      return '**Standard ISO 216 Drawing Sheet Sizes:**\n\n'
          '• **A0:** 841 × 1189 mm (Area = 1 m², aspect ratio 1:√2)\n'
          '• **A1:** 594 × 841 mm\n'
          '• **A2:** 420 × 594 mm\n'
          '• **A3:** 297 × 420 mm (Common student manual drafting size)\n'
          '• **A4:** 210 × 297 mm (Standard project reports & CAD printouts)\n\n'
          'Title blocks are conventionally located at the bottom-right corner of the sheet (max width 170mm).';
    }

    return 'Thank you for your question on "$query".\n\n'
        'In technical engineering drawing:\n'
        '• Always adhere to ISO 128 drafting standards for line weight, text height (3.5mm for notes, 5mm for titles), and unidirectional dimensioning.\n'
        '• Ensure projection planes (Horizontal Plane, Vertical Plane, Profile Plane) remain aligned with proper folding line references (X-Y datum).\n'
        '• Check out Course #02 ("Orthographic Projections") and Course #05 ("Machine Drawing & GD&T") in our curriculum for comprehensive worked video examples!';
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.psychology, color: AppTheme.accentCyan),
            SizedBox(width: 10),
            Text('AI Engineering Drawing Tutor'),
          ],
        ),
        actions: [
          Row(
            children: [
              Text(
                _aiEnabled ? 'AI Active' : 'AI Off',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
              Switch(
                value: _aiEnabled,
                activeColor: AppTheme.accentCyan,
                onChanged: (val) {
                  setState(() => _aiEnabled = val);
                  if (_appSettings != null) {
                    final updated = AppSettingsModel(
                      appName: _appSettings!.appName,
                      logo: _appSettings!.logo,
                      welcomeMessage: _appSettings!.welcomeMessage,
                      paymentNumber: _appSettings!.paymentNumber,
                      subscriptionPrice: _appSettings!.subscriptionPrice,
                      subscriptionDuration: _appSettings!.subscriptionDuration,
                      paymentInstructions: _appSettings!.paymentInstructions,
                      aiEnabled: val,
                      contactInformation: _appSettings!.contactInformation,
                      maintenanceMode: _appSettings!.maintenanceMode,
                    );
                    _firestoreService.updateAppSettings(updated);
                  }
                },
              ),
            ],
          ),
          IconButton(
            tooltip: 'Clear Chat',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add(
                  ChatMessage(
                    id: 'welcome_msg_reset',
                    text: 'Chat history cleared. How can I assist you with technical drawing today?',
                    sender: MessageSender.ai,
                    timestamp: DateTime.now(),
                  ),
                );
              });
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Column(
            children: [
              // Quick Prompt Suggestion Chips
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'POPULAR TOPICS (TAP TO ASK):',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _quickPrompts.map((p) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ActionChip(
                              backgroundColor: AppTheme.accentCyanLight.withOpacity(0.6),
                              side: const BorderSide(color: Color(0xFFB2EBF2)),
                              label: Text(
                                p,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.primaryBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onPressed: () => _sendMessage(p),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Chat Messages List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return _buildMessageBubble(msg);
                  },
                ),
              ),

              if (_isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'AI Tutor is typing...',
                              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Input Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Ask about orthographic views, GD&T, scales, ellipse...',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _sendMessage(),
                      child: const Icon(Icons.send, color: Colors.white),
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

  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.sender == MessageSender.user;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              margin: const EdgeInsets.only(right: 10, top: 4),
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primaryBlue,
                child: Icon(Icons.psychology, color: Colors.white, size: 18),
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isUser ? AppTheme.primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
                  bottomLeft: !isUser ? const Radius.circular(0) : const Radius.circular(16),
                ),
                border: isUser ? null : Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    msg.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : AppTheme.darkNavy,
                      fontSize: 13.5,
                      height: 1.45,
                    ),
                  ),
                  if (!isUser) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: msg.text));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Response copied to clipboard')),
                            );
                          },
                          child: const Row(
                            children: [
                              Icon(Icons.copy, size: 12, color: AppTheme.textMuted),
                              SizedBox(width: 4),
                              Text('Copy', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isUser)
            Container(
              margin: const EdgeInsets.only(left: 10, top: 4),
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.accentCyan,
                child: Icon(Icons.person, color: AppTheme.darkNavy, size: 18),
              ),
            ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
  });
}

enum MessageSender { user, ai }
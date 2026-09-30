import 'package:flutter/material.dart';

import 'package:engineering_drawing_city/models/payment_model.dart';
import 'package:engineering_drawing_city/models/user_model.dart';
import 'package:engineering_drawing_city/services/firebase_service.dart';
import 'package:engineering_drawing_city/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = '/profile';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  bool _showPaymentForm = false;
  final _txnController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _txnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    if (user == null) {
      // Redirect to login if not signed in
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final sub = _firestoreService.getSubscriptionSync(user.uid);
    final hasActiveSub = sub != null && sub.status == 'active';
    final payments = _firestoreService
        .getAllPaymentsSync()
        .where((p) => p.userId == user.uid)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('My Profile'),
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
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Header Card
                _buildProfileCard(user),
                const SizedBox(height: 20),

                // Student Details
                _buildAcademicCard(user),
                const SizedBox(height: 20),

                // Subscription Status
                _buildSubscriptionCard(user, hasActiveSub, sub),
                const SizedBox(height: 20),

                // Payment Form (Airtel)
                if (_showPaymentForm && !hasActiveSub)
                  _buildPaymentForm(user),
                if (_showPaymentForm && !hasActiveSub)
                  const SizedBox(height: 20),

                // Payment History
                _buildPaymentHistory(payments),
                const SizedBox(height: 20),

                // Account Actions
                _buildAccountActions(user),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(UserModel user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            // Avatar with logo
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryBlue,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentCyan.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'S',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkNavy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.accentCyanLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'STUDENT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicCard(UserModel user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Academic Information',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkNavy),
            ),
            const SizedBox(height: 14),
            _infoRow(Icons.location_city, 'Institution',
                user.institution ?? 'The Copperbelt University'),
            const Divider(height: 20),
            _infoRow(Icons.school, 'Programme',
                user.program ?? 'Not specified'),
            const Divider(height: 20),
            _infoRow(Icons.calendar_today, 'Year of Study',
                user.year ?? 'Not specified'),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryBlue, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkNavy)),
          ],
        ),
      ],
    );
  }

  Widget _buildSubscriptionCard(
      UserModel user, bool hasActiveSub, dynamic sub) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Subscription Pass',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkNavy),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: hasActiveSub
                        ? AppTheme.successGreen.withValues(alpha: 0.15)
                        : AppTheme.errorRed.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    hasActiveSub ? '✓ ACTIVE' : 'NOT ACTIVE',
                    style: TextStyle(
                      color: hasActiveSub
                          ? AppTheme.successGreen
                          : AppTheme.errorRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (hasActiveSub) ...[
              Text(
                'Expires: ${sub.expiryDate.toLocal().toString().split(' ')[0]}',
                style:
                    const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                'Ref: ${sub.paymentReference}',
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textMuted),
              ),
            ] else ...[
              const Text(
                'Subscribe via Airtel to unlock all full-length video modules.',
                style:
                    TextStyle(fontSize: 13, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 16),
              // Payment instructions
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF5FB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppTheme.accentCyan.withValues(alpha: 0.4)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.phone_android,
                            color: AppTheme.primaryBlue, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Airtel Mobile Money',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkNavy,
                              fontSize: 14),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Open Airtel Money on your phone',
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      '2. Send ZMW 100 to: 0772184445',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '   (Engineering Drawing City)',
                      style: TextStyle(
                          fontSize: 12, color: AppTheme.textMuted),
                    ),
                    Text(
                      '3. Enter your Transaction Reference below',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.phone_android,
                    color: Colors.white, size: 18),
                label: const Text(
                  'I Have Paid – Enter Transaction Reference',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
                onPressed: () =>
                    setState(() => _showPaymentForm = !_showPaymentForm),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentForm(UserModel user) {
    return Card(
      elevation: 2,
      color: const Color(0xFFF0FDF4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
            color: AppTheme.successGreen.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Submit Airtel Payment Reference',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkNavy),
            ),
            const SizedBox(height: 6),
            const Text(
              'After sending ZMW 100 to 0772184445, enter the transaction reference you received from Airtel.',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _txnController,
              decoration: const InputDecoration(
                labelText: 'Transaction Reference / Receipt Number',
                hintText: 'e.g. AIR-TXN-12345678',
                prefixIcon:
                    Icon(Icons.receipt_long, color: AppTheme.primaryBlue),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successGreen,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _isSubmitting
                  ? null
                  : () async {
                      final txn = _txnController.text.trim();
                      if (txn.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter your transaction reference'),
                            backgroundColor: AppTheme.errorRed,
                          ),
                        );
                        return;
                      }

                      setState(() => _isSubmitting = true);

                      final payment = PaymentModel(
                        id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
                        userId: user.uid,
                        amount: 100.0,
                        paymentReference: txn,
                        status: 'pending',
                        submittedAt: DateTime.now(),
                      );

                      await _firestoreService.savePayment(payment);

                      if (!mounted) return;
                      setState(() {
                        _isSubmitting = false;
                        _showPaymentForm = false;
                        _txnController.clear();
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              '✅ Payment verified! Your subscription is now ACTIVE. Enjoy full access!'),
                          backgroundColor: AppTheme.successGreen,
                          duration: Duration(seconds: 4),
                        ),
                      );
                    },
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Verify & Activate Subscription',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentHistory(List<PaymentModel> payments) {
    return Card(
      elevation: 2,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment History',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkNavy),
            ),
            const SizedBox(height: 12),
            if (payments.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  'No payment records found.',
                  style: TextStyle(
                      color: AppTheme.textMuted, fontSize: 13),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: payments.length,
                separatorBuilder: (c, i) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final p = payments[index];
                  final isApproved = p.status == 'approved';
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      isApproved
                          ? Icons.check_circle
                          : Icons.pending,
                      color: isApproved
                          ? AppTheme.successGreen
                          : Colors.orange,
                    ),
                    title: Text(
                      'ZMW ${p.amount.toStringAsFixed(0)} — ${p.paymentReference}',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Submitted: ${p.submittedAt.toLocal().toString().split(' ')[0]}',
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textMuted),
                    ),
                    trailing: Text(
                      p.status.toUpperCase(),
                      style: TextStyle(
                        color: isApproved
                            ? AppTheme.successGreen
                            : Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountActions(UserModel user) {
    return Card(
      elevation: 2,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.edit, color: AppTheme.primaryBlue),
            title: const Text('Update Display Name'),
            onTap: () => _showEditNameDialog(user),
          ),
          const Divider(height: 1),
          ListTile(
            leading:
                const Icon(Icons.logout, color: AppTheme.errorRed),
            title: const Text('Sign Out',
                style: TextStyle(color: AppTheme.errorRed)),
            onTap: () async {
              await _authService.signOut();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(UserModel user) {
    final controller = TextEditingController(text: user.name);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Update Display Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Full Name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                final updated = UserModel(
                  uid: user.uid,
                  email: user.email,
                  name: newName,
                  role: user.role,
                  year: user.year,
                  program: user.program,
                  institution: user.institution,
                  createdAt: user.createdAt,
                  updatedAt: DateTime.now(),
                );
                await _firestoreService.saveUser(updated);
                _authService.setCurrentUser(updated);
                setState(() {});
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
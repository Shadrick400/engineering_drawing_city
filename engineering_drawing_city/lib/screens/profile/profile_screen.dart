import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

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

  static const String _airtelNumber = '0772184445';
  static const double _subscriptionAmount = 100.0;

  @override
  void dispose() {
    _txnController.dispose();
    super.dispose();
  }

  /// Launch Airtel USSD dial on mobile
  Future<void> _dialUSSD() async {
    // Airtel Money Zambia USSD: *778#
    const ussdCode = '*778%23'; // %23 is URL-encoded #
    final uri = Uri.parse('tel:$ussdCode');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch USSD. Dial *778# manually on your phone.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    if (user == null) {
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
                // Suspension Banner
                if (user.isSuspended)
                  _buildSuspensionBanner(),

                // Profile Header Card
                _buildProfileCard(user),
                const SizedBox(height: 20),

                // Student Details (editable)
                _buildAcademicCard(user),
                const SizedBox(height: 20),

                // Subscription Status
                _buildSubscriptionCard(user, hasActiveSub, sub),
                const SizedBox(height: 20),

                // Payment Form
                if (_showPaymentForm && !hasActiveSub)
                  _buildPaymentForm(user),
                if (_showPaymentForm && !hasActiveSub)
                  const SizedBox(height: 20),

                // Payment History
                _buildPaymentHistory(payments),
                const SizedBox(height: 20),

                // Account Actions
                _buildAccountActions(user),
                const SizedBox(height: 20),

                // Terms & Conditions
                _buildTermsCard(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuspensionBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.errorRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.errorRed.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.block, color: AppTheme.errorRed, size: 22),
              SizedBox(width: 10),
              Text(
                'Account Suspended',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.errorRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Your account was suspended because a login was detected from a different device. '
            'This is to protect your account from unauthorized access.',
            style: TextStyle(fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.phone, color: Colors.white, size: 18),
            label: const Text('Contact Customer Care',
                style: TextStyle(color: Colors.white, fontSize: 13)),
            onPressed: () async {
              final uri = Uri.parse('tel:+260772184445');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
          ),
        ],
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
                  if (user.phoneNumber != null &&
                      user.phoneNumber!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone_android,
                            size: 14, color: AppTheme.primaryBlue),
                        const SizedBox(width: 4),
                        Text(
                          user.phoneNumber!,
                          style: const TextStyle(
                              fontSize: 13, color: AppTheme.primaryBlue),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.accentCyanLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      user.role.toUpperCase(),
                      style: const TextStyle(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Academic Information',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkNavy),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Update'),
                  onPressed: () => _showEditAcademicDialog(user),
                ),
              ],
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

  Widget _buildSubscriptionCard(UserModel user, bool hasActiveSub, dynamic sub) {
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
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                'Ref: ${sub.paymentReference}',
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
            ] else ...[
              const Text(
                'Subscribe via Airtel to unlock all videos, AI Tutor, and full premium content.',
                style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 16),

              // Payment instructions card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF5FB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppTheme.accentCyan.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
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
                    const SizedBox(height: 10),
                    const Text('1. Press "Pay Now" below to open the Airtel USSD menu',
                        style: TextStyle(fontSize: 12)),
                    const Text('2. Select "Send Money" → Enter number: $_airtelNumber',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const Text('   (Engineering Drawing City)',
                        style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                    const Text('3. Send ZMW 100 and note your Transaction Reference',
                        style: TextStyle(fontSize: 12)),
                    const Text('4. Enter the reference below to activate your account',
                        style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // PAY NOW button — triggers USSD
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successGreen,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.phone_in_talk,
                          color: Colors.white, size: 20),
                      label: const Text(
                        'Pay Now (Dial *778#)',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        // Copy number to clipboard for convenience
                        Clipboard.setData(
                            const ClipboardData(text: _airtelNumber));
                        await _dialUSSD();
                        // After dialing, show the form
                        setState(() => _showPaymentForm = true);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Enter reference button
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: AppTheme.primaryBlue.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.receipt_long,
                    color: AppTheme.primaryBlue, size: 18),
                label: const Text(
                  'I Have Paid – Enter Transaction Reference',
                  style: TextStyle(color: AppTheme.primaryBlue, fontSize: 13),
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
                            content: Text(
                                'Please enter your transaction reference'),
                            backgroundColor: AppTheme.errorRed,
                          ),
                        );
                        return;
                      }

                      setState(() => _isSubmitting = true);

                      final payment = PaymentModel(
                        id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
                        userId: user.uid,
                        amount: _subscriptionAmount,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
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
                      isApproved ? Icons.check_circle : Icons.pending,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.edit, color: AppTheme.primaryBlue),
            title: const Text('Update Display Name'),
            onTap: () => _showEditNameDialog(user),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.phone_android, color: AppTheme.primaryBlue),
            title: const Text('Update Phone Number'),
            subtitle: Text(
              user.phoneNumber?.isNotEmpty == true
                  ? user.phoneNumber!
                  : 'Not set',
              style: const TextStyle(fontSize: 12),
            ),
            onTap: () => _showEditPhoneDialog(user),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.school, color: AppTheme.primaryBlue),
            title: const Text('Update Year & Programme'),
            onTap: () => _showEditAcademicDialog(user),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.errorRed),
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

  Widget _buildTermsCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.gavel, color: AppTheme.primaryBlue, size: 20),
                SizedBox(width: 10),
                Text(
                  'Terms & Conditions',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkNavy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'By using Engineering Drawing City, you agree to the following:',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 8),
            _termsPoint('Account is personal and non-transferable.'),
            _termsPoint(
                'Account is bound to one device. Login from a new device will suspend the account.'),
            _termsPoint('Subscription fees are non-refundable.'),
            _termsPoint('No active subscription = No AI Tutor access.'),
            _termsPoint(
                'Content is for personal educational use only. Redistribution is prohibited.'),
            _termsPoint('Contact +260 772 184445 for account reactivation.'),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.primaryBlue.withOpacity(0.4)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.open_in_new,
                  size: 16, color: AppTheme.primaryBlue),
              label: const Text('Read Full T&C',
                  style: TextStyle(color: AppTheme.primaryBlue, fontSize: 13)),
              onPressed: () => _showFullTermsDialog(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _termsPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(color: AppTheme.primaryBlue, fontSize: 13)),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 12, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  void _showFullTermsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.gavel, color: AppTheme.primaryBlue),
            SizedBox(width: 10),
            Text('Terms & Conditions'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('1. Account & Access',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              SizedBox(height: 4),
              Text(
                  'Your account is personal and non-transferable. Sharing credentials is prohibited and will result in suspension.',
                  style: TextStyle(fontSize: 13)),
              SizedBox(height: 12),
              Text('2. Device Lock Policy',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              SizedBox(height: 4),
              Text(
                  'Each account is bound to a single device. Logging in from a different device will trigger automatic account suspension. Contact +260 772 184445 for reactivation.',
                  style: TextStyle(fontSize: 13)),
              SizedBox(height: 12),
              Text('3. Subscription & Payments',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              SizedBox(height: 4),
              Text(
                  'Subscription fees are non-refundable. Access to AI features and premium content requires an active subscription. No payments = No AI access.',
                  style: TextStyle(fontSize: 13)),
              SizedBox(height: 12),
              Text('4. Content Use',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              SizedBox(height: 4),
              Text(
                  'All content is for personal educational use only. Redistribution, copying, or commercial use is strictly prohibited.',
                  style: TextStyle(fontSize: 13)),
              SizedBox(height: 12),
              Text('5. Intellectual Property',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              SizedBox(height: 4),
              Text(
                  'All content is the property of Engineering Drawing City. Unauthorized reproduction may result in legal action.',
                  style: TextStyle(fontSize: 13)),
              SizedBox(height: 12),
              Text('6. Privacy',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              SizedBox(height: 4),
              Text(
                  'Your phone number and email are used only for payment verification and account recovery. We do not share your data with third parties.',
                  style: TextStyle(fontSize: 13)),
              SizedBox(height: 12),
              Text('7. Amendments',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              SizedBox(height: 4),
              Text(
                  'Engineering Drawing City reserves the right to modify these terms at any time. Continued use of the app constitutes acceptance of any revised terms.',
                  style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── DIALOGS ──

  void _showEditNameDialog(UserModel user) {
    final controller = TextEditingController(text: user.name);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                final updated = user.copyWith(
                  name: newName,
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

  void _showEditPhoneDialog(UserModel user) {
    final controller =
        TextEditingController(text: user.phoneNumber ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Update Phone Number'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: 'Mobile Number',
            hintText: 'e.g. 0972123456',
            prefixIcon:
                Icon(Icons.phone_android, color: AppTheme.primaryBlue),
            helperText: 'Used for Airtel Money payment prompts',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final phone = controller.text.trim();
              if (phone.isNotEmpty) {
                final updated = user.copyWith(
                  phoneNumber: phone,
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

  void _showEditAcademicDialog(UserModel user) {
    String? selectedYear = user.year;
    String? selectedProgram = user.program;

    const years = ['Year 1', 'Year 2'];
    const programs = [
      'Bachelor of Engineering II (BEng II)',
      'Mining Engineering',
      'Chemical engineering',
      'Metallurgical Engineering',
      'Geometics engineering',
      'Other',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Update Year & Programme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedYear,
                decoration: const InputDecoration(
                  labelText: 'Year of Study',
                  prefixIcon: Icon(Icons.calendar_today,
                      color: AppTheme.primaryBlue),
                ),
                items: years
                    .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                    .toList(),
                onChanged: (v) =>
                    setDialogState(() => selectedYear = v),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: selectedProgram,
                decoration: const InputDecoration(
                  labelText: 'Programme / Course',
                  prefixIcon:
                      Icon(Icons.school, color: AppTheme.primaryBlue),
                ),
                items: programs
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) =>
                    setDialogState(() => selectedProgram = v),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final updated = user.copyWith(
                  year: selectedYear,
                  program: selectedProgram,
                  updatedAt: DateTime.now(),
                );
                await _firestoreService.saveUser(updated);
                _authService.setCurrentUser(updated);
                setState(() {});
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
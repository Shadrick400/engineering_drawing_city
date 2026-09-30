class SubscriptionModel {
  final String id;
  final String userId;
  final String status; // 'active', 'expired', 'pending'
  final DateTime startDate;
  final DateTime expiryDate;
  final double amount;
  final String paymentReference;
  final String? approvedBy;
  final DateTime createdAt;

  SubscriptionModel({
    required this.id,
    required this.userId,
    required this.status,
    required this.startDate,
    required this.expiryDate,
    required this.amount,
    required this.paymentReference,
    this.approvedBy,
    required this.createdAt,
  });

  factory SubscriptionModel.fromMap(String id, Map<String, dynamic> data) {
    return SubscriptionModel(
      id: id,
      userId: data['userId'] ?? '',
      status: data['status'] ?? 'pending',
      startDate: data['startDate'] != null
          ? DateTime.parse(data['startDate'])
          : DateTime.now(),
      expiryDate: data['expiryDate'] != null
          ? DateTime.parse(data['expiryDate'])
          : DateTime.now().add(const Duration(days: 30)),
      amount: (data['amount'] ?? 0.0).toDouble(),
      paymentReference: data['paymentReference'] ?? '',
      approvedBy: data['approvedBy'],
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'status': status,
      'startDate': startDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'amount': amount,
      'paymentReference': paymentReference,
      'approvedBy': approvedBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
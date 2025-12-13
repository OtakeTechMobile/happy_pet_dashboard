import 'package:equatable/equatable.dart';

import '../enums/app_enums.dart';

/// Payment model representing financial transactions
class PaymentModel extends Equatable {
  final String id;
  final String invoiceId;
  final String tutorId;
  final double amount;
  final PaymentMethod paymentMethod;
  final DateTime paymentDate;
  final String? stripePaymentIntentId;
  final String? stripeChargeId;
  final String? pixQrCode;
  final String? boletoUrl;
  final PaymentStatus status;
  final String? notes;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PaymentModel({
    required this.id,
    required this.invoiceId,
    required this.tutorId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentDate,
    this.stripePaymentIntentId,
    this.stripeChargeId,
    this.pixQrCode,
    this.boletoUrl,
    required this.status,
    this.notes,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isCompleted => status == PaymentStatus.completed;
  bool get isPending => status == PaymentStatus.pending;
  bool get isFailed => status == PaymentStatus.failed;
  bool get isRefunded => status == PaymentStatus.refunded;

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      invoiceId: json['invoice_id'] as String,
      tutorId: json['tutor_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: PaymentMethod.fromString(json['payment_method'] as String),
      paymentDate: DateTime.parse(json['payment_date'] as String),
      stripePaymentIntentId: json['stripe_payment_intent_id'] as String?,
      stripeChargeId: json['stripe_charge_id'] as String?,
      pixQrCode: json['pix_qr_code'] as String?,
      boletoUrl: json['boleto_url'] as String?,
      status: PaymentStatus.fromString(json['status'] as String),
      notes: json['notes'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'tutor_id': tutorId,
      'amount': amount,
      'payment_method': paymentMethod.name,
      'payment_date': paymentDate.toIso8601String(),
      'stripe_payment_intent_id': stripePaymentIntentId,
      'stripe_charge_id': stripeChargeId,
      'pix_qr_code': pixQrCode,
      'boleto_url': boletoUrl,
      'status': status.name,
      'notes': notes,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  PaymentModel copyWith({
    String? id,
    String? invoiceId,
    String? tutorId,
    double? amount,
    PaymentMethod? paymentMethod,
    DateTime? paymentDate,
    String? stripePaymentIntentId,
    String? stripeChargeId,
    String? pixQrCode,
    String? boletoUrl,
    PaymentStatus? status,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      tutorId: tutorId ?? this.tutorId,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentDate: paymentDate ?? this.paymentDate,
      stripePaymentIntentId: stripePaymentIntentId ?? this.stripePaymentIntentId,
      stripeChargeId: stripeChargeId ?? this.stripeChargeId,
      pixQrCode: pixQrCode ?? this.pixQrCode,
      boletoUrl: boletoUrl ?? this.boletoUrl,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        invoiceId,
        tutorId,
        amount,
        paymentMethod,
        paymentDate,
        stripePaymentIntentId,
        stripeChargeId,
        pixQrCode,
        boletoUrl,
        status,
        notes,
        createdBy,
        createdAt,
        updatedAt,
      ];
}

/// Payment status enum
enum PaymentStatus {
  pending,
  completed,
  failed,
  refunded;

  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (status) => status.name == value.toLowerCase(),
      orElse: () => PaymentStatus.pending,
    );
  }
}

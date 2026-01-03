import 'package:equatable/equatable.dart';

import '../enums/app_enums.dart';

/// Invoice model representing billing documents
class InvoiceModel extends Equatable {
  final String id;
  final String? stayId;
  final String tutorId;
  final String hotelId;
  final String invoiceNumber;
  final InvoiceStatus status;
  final DateTime issueDate;
  final DateTime dueDate;
  final List<InvoiceLineItem> lineItems;
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double totalAmount;
  final String? notes;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InvoiceModel({
    required this.id,
    this.stayId,
    required this.tutorId,
    required this.hotelId,
    required this.invoiceNumber,
    required this.status,
    required this.issueDate,
    required this.dueDate,
    required this.lineItems,
    required this.subtotal,
    this.discountAmount = 0,
    this.taxAmount = 0,
    required this.totalAmount,
    this.notes,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPaid => status == InvoiceStatus.paid;
  bool get isOverdue => status == InvoiceStatus.overdue;
  bool get isPending => status == InvoiceStatus.pending;

  int get daysUntilDue {
    final now = DateTime.now();
    return dueDate.difference(now).inDays;
  }

  bool get isDueSoon => daysUntilDue <= 3 && daysUntilDue > 0;

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] ?? '',
      stayId: json['stay_id'] ?? '',
      tutorId: json['tutor_id'] ?? '',
      hotelId: json['hotel_id'] ?? '',
      invoiceNumber: json['invoice_number'] ?? '',
      status: InvoiceStatus.fromString(json['status'] ?? ''),
      issueDate: DateTime.parse(json['issue_date'] ?? ''),
      dueDate: DateTime.parse(json['due_date'] ?? ''),
      lineItems:
          (json['line_items'] ?? [])?.map((item) => InvoiceLineItem.fromJson(item as Map<String, dynamic>)).toList() ??
          const [],
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      discountAmount: (json['discount_amount'] ?? 0).toDouble(),
      taxAmount: (json['tax_amount'] ?? 0).toDouble(),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      notes: json['notes'] ?? '',
      createdBy: json['created_by'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? ''),
      updatedAt: DateTime.parse(json['updated_at'] ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stay_id': stayId,
      'tutor_id': tutorId,
      'hotel_id': hotelId,
      'invoice_number': invoiceNumber,
      'status': status.name,
      'issue_date': issueDate.toIso8601String().split('T')[0],
      'due_date': dueDate.toIso8601String().split('T')[0],
      'line_items': lineItems.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'discount_amount': discountAmount,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
      'notes': notes,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  InvoiceModel copyWith({
    String? id,
    String? stayId,
    String? tutorId,
    String? hotelId,
    String? invoiceNumber,
    InvoiceStatus? status,
    DateTime? issueDate,
    DateTime? dueDate,
    List<InvoiceLineItem>? lineItems,
    double? subtotal,
    double? discountAmount,
    double? taxAmount,
    double? totalAmount,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      stayId: stayId ?? this.stayId,
      tutorId: tutorId ?? this.tutorId,
      hotelId: hotelId ?? this.hotelId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      status: status ?? this.status,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      lineItems: lineItems ?? this.lineItems,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    stayId,
    tutorId,
    hotelId,
    invoiceNumber,
    status,
    issueDate,
    dueDate,
    lineItems,
    subtotal,
    discountAmount,
    taxAmount,
    totalAmount,
    notes,
    createdBy,
    createdAt,
    updatedAt,
  ];
}

/// Invoice line item embedded in invoice
class InvoiceLineItem extends Equatable {
  final String description;
  final int quantity;
  final double unitPrice;
  final double total;

  const InvoiceLineItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  factory InvoiceLineItem.fromJson(Map<String, dynamic> json) {
    return InvoiceLineItem(
      description: json['description'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'description': description, 'quantity': quantity, 'unit_price': unitPrice, 'total': total};
  }

  @override
  List<Object?> get props => [description, quantity, unitPrice, total];
}

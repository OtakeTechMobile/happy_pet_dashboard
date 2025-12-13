import '../../domain/enums/app_enums.dart';
import '../../domain/models/invoice_model.dart';
import '../../domain/models/payment_model.dart';
import '../../domain/models/pricing_model.dart';
import 'base_repository.dart';

/// Repository for financial operations (invoices, payments, pricing)
class FinancialRepository extends BaseRepository {
  // ==================== INVOICES ====================

  /// Get all invoices with filters
  Future<List<InvoiceModel>> getInvoices({
    String? tutorId,
    String? hotelId,
    InvoiceStatus? status,
    DateTime? issueDateFrom,
    DateTime? issueDateTo,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      dynamic query = from('invoices').select();

      if (tutorId != null) {
        query = query.eq('tutor_id', tutorId);
      }

      if (hotelId != null) {
        query = query.eq('hotel_id', hotelId);
      }

      if (status != null) {
        query = query.eq('status', status.name);
      }

      if (issueDateFrom != null) {
        query = query.gte('issue_date', issueDateFrom.toIso8601String().split('T')[0]);
      }

      if (issueDateTo != null) {
        query = query.lte('issue_date', issueDateTo.toIso8601String().split('T')[0]);
      }

      // Apply ordering and range AFTER all filters
      query = query.order('issue_date', ascending: false).range(offset, offset + limit - 1);

      final response = await query;
      return (response as List).map((json) => InvoiceModel.fromJson(json)).toList();
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Get invoice by ID
  Future<InvoiceModel?> getInvoiceById(String id) async {
    try {
      final response = await from('invoices').select().eq('id', id).maybeSingle();
      return response != null ? InvoiceModel.fromJson(response) : null;
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Get overdue invoices
  Future<List<InvoiceModel>> getOverdueInvoices({String? hotelId}) async {
    return getInvoices(status: InvoiceStatus.overdue, hotelId: hotelId);
  }

  /// Create invoice
  Future<InvoiceModel> createInvoice(InvoiceModel invoice) async {
    try {
      final response = await from('invoices').insert(invoice.toJson()).select().single();
      return InvoiceModel.fromJson(response);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Update invoice
  Future<InvoiceModel> updateInvoice(InvoiceModel invoice) async {
    try {
      final response = await from('invoices').update(invoice.toJson()).eq('id', invoice.id).select().single();
      return InvoiceModel.fromJson(response);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Mark invoice as paid
  Future<InvoiceModel> markInvoiceAsPaid(String invoiceId) async {
    try {
      final response = await from('invoices')
          .update({'status': 'paid', 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', invoiceId)
          .select()
          .single();
      return InvoiceModel.fromJson(response);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Cancel invoice
  Future<InvoiceModel> cancelInvoice(String invoiceId) async {
    try {
      final response = await from('invoices')
          .update({'status': 'cancelled', 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', invoiceId)
          .select()
          .single();
      return InvoiceModel.fromJson(response);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  // ==================== PAYMENTS ====================

  /// Get all payments
  Future<List<PaymentModel>> getPayments({
    String? invoiceId,
    String? tutorId,
    PaymentStatus? status,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      dynamic query = from('payments').select();

      if (invoiceId != null) {
        query = query.eq('invoice_id', invoiceId);
      }

      if (tutorId != null) {
        query = query.eq('tutor_id', tutorId);
      }

      if (status != null) {
        query = query.eq('status', status.name);
      }

      // Apply ordering and range AFTER all filters
      query = query.order('payment_date', ascending: false).range(offset, offset + limit - 1);

      final response = await query;
      return (response as List).map((json) => PaymentModel.fromJson(json)).toList();
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Get payment by ID
  Future<PaymentModel?> getPaymentById(String id) async {
    try {
      final response = await from('payments').select().eq('id', id).maybeSingle();
      return response != null ? PaymentModel.fromJson(response) : null;
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Create payment
  Future<PaymentModel> createPayment(PaymentModel payment) async {
    try {
      final response = await from('payments').insert(payment.toJson()).select().single();
      return PaymentModel.fromJson(response);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Update payment
  Future<PaymentModel> updatePayment(PaymentModel payment) async {
    try {
      final response = await from('payments').update(payment.toJson()).eq('id', payment.id).select().single();
      return PaymentModel.fromJson(response);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Mark payment as completed
  Future<PaymentModel> completePayment(String paymentId) async {
    try {
      final response = await from('payments')
          .update({'status': 'completed', 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', paymentId)
          .select()
          .single();
      return PaymentModel.fromJson(response);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  // ==================== PRICING ====================

  /// Get all pricing packages for a hotel
  Future<List<PricingPackageModel>> getPricingPackages(String hotelId, {bool? isActive}) async {
    try {
      dynamic query = from('pricing_packages').select().eq('hotel_id', hotelId);

      if (isActive != null) {
        query = query.eq('is_active', isActive);
      }

      query = query.order('type');

      final response = await query;
      return (response as List).map((json) => PricingPackageModel.fromJson(json)).toList();
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Get pricing package by ID
  Future<PricingPackageModel?> getPricingPackageById(String id) async {
    try {
      final response = await from('pricing_packages').select().eq('id', id).maybeSingle();
      return response != null ? PricingPackageModel.fromJson(response) : null;
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Create pricing package
  Future<PricingPackageModel> createPricingPackage(PricingPackageModel package) async {
    try {
      final response = await from('pricing_packages').insert(package.toJson()).select().single();
      return PricingPackageModel.fromJson(response);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Update pricing package
  Future<PricingPackageModel> updatePricingPackage(PricingPackageModel package) async {
    try {
      final response = await from('pricing_packages').update(package.toJson()).eq('id', package.id).select().single();
      return PricingPackageModel.fromJson(response);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Delete pricing package (soft delete)
  Future<void> deletePricingPackage(String id) async {
    try {
      await from('pricing_packages').update({'is_active': false}).eq('id', id);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Get additional services for a hotel
  Future<List<AdditionalServiceModel>> getAdditionalServices(String hotelId, {bool? isActive}) async {
    try {
      dynamic query = from('additional_services').select().eq('hotel_id', hotelId);

      if (isActive != null) {
        query = query.eq('is_active', isActive);
      }

      query = query.order('name');

      final response = await query;
      return (response as List).map((json) => AdditionalServiceModel.fromJson(json)).toList();
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Create additional service
  Future<AdditionalServiceModel> createAdditionalService(AdditionalServiceModel service) async {
    try {
      final response = await from('additional_services').insert(service.toJson()).select().single();
      return AdditionalServiceModel.fromJson(response);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Update additional service
  Future<AdditionalServiceModel> updateAdditionalService(AdditionalServiceModel service) async {
    try {
      final response = await from(
        'additional_services',
      ).update(service.toJson()).eq('id', service.id).select().single();
      return AdditionalServiceModel.fromJson(response);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  // ==================== REPORTS ====================

  /// Get total revenue for a period
  Future<double> getTotalRevenue({
    required String hotelId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final invoices = await getInvoices(
        hotelId: hotelId,
        status: InvoiceStatus.paid,
        issueDateFrom: startDate,
        issueDateTo: endDate,
      );

      return invoices.fold<double>(0.0, (sum, invoice) => sum + invoice.totalAmount);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

  /// Get accounts receivable (pending + overdue)
  Future<double> getAccountsReceivable({String? hotelId}) async {
    try {
      final pendingInvoices = await getInvoices(status: InvoiceStatus.pending, hotelId: hotelId);
      final overdueInvoices = await getInvoices(status: InvoiceStatus.overdue, hotelId: hotelId);

      final allInvoices = [...pendingInvoices, ...overdueInvoices];
      return allInvoices.fold<double>(0.0, (sum, invoice) => sum + invoice.totalAmount);
    } on Exception catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }
}

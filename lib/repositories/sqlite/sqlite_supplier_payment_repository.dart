import 'package:crizavoise/database/supplier_payment_service.dart';
import 'package:crizavoise/models/purchase_bill.dart';
import 'package:crizavoise/models/supplier_payment.dart';
import 'package:crizavoise/repositories/supplier_payment_repository.dart';

class SqliteSupplierPaymentRepository implements SupplierPaymentRepository {
  @override
  Future<SupplierPayment> addPayment({
    required PurchaseBill bill,
    required double amountPaid,
    required DateTime datePaid,
    String? paymentMethod,
    String? notes,
  }) =>
      SupplierPaymentService.addPayment(
        bill: bill,
        amountPaid: amountPaid,
        datePaid: datePaid,
        paymentMethod: paymentMethod,
        notes: notes,
      );
  @override
  Future<List<SupplierPayment>> getPaymentsForBill(String billId) =>
      SupplierPaymentService.getPaymentsForBill(billId);
  @override
  Future<double> getTotalPaidForBill(String billId) => SupplierPaymentService.getTotalPaidForBill(billId);
  @override
  Future<Map<String, double>> getTotalPaidBatch(List<String> billIds) =>
      SupplierPaymentService.getTotalPaidBatch(billIds);
  @override
  Future<void> deletePayment(String paymentId) => SupplierPaymentService.deletePayment(paymentId);
}

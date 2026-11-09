import 'package:crizavoise/database/invoice_item_service.dart';
import 'package:crizavoise/models/invoice_item.dart';
import 'package:crizavoise/repositories/invoice_item_repository.dart';

class SqliteInvoiceItemRepository implements InvoiceItemRepository
{
  @override
  Future<List<InvoiceItem>> getInvoiceItemsByInvoiceId(String invoiceId) {
    return InvoiceItemService.getInvoiceItemsByInvoiceId(invoiceId);
  }

  @override
  Future<void> insertInvoiceItems(String invId, InvoiceItem item) {
    return InvoiceItemService.insertInvoiceItems(invId, item);
  }

  @override
  Future<void> markProductSaved(String invoiceId, String productId)
  {
    return InvoiceItemService.markProductSaved(invoiceId, productId);
  }
}
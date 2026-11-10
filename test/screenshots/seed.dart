// Demo data for screenshots: a small Indian shop with customers, products
// and a few months of invoices (some paid, some due).
import 'package:crizavoise/database/company_info_service.dart';
import 'package:crizavoise/database/customer_service.dart';
import 'package:crizavoise/database/invoice_service.dart';
import 'package:crizavoise/database/payment_service.dart';
import 'package:crizavoise/database/product_service.dart';
import 'package:crizavoise/models/company_info.dart';
import 'package:crizavoise/models/customer.dart';
import 'package:crizavoise/models/invoice.dart';
import 'package:crizavoise/models/invoice_item.dart';
import 'package:crizavoise/models/product.dart';

Future<void> seedDemoData() async {
  await CompanyInfoService.insertCompanyInfo(CompanyInfo(
    name: 'Sharma General Store',
    address: '12 MG Road, Ahmedabad, Gujarat 380009',
    phone: '98250 12345',
    email: 'sharma.store@example.com',
    website: '',
    gstin: '24ABCDE1234F1Z5',
  ));

  final customers = [
    Customer(id: 'c1', name: 'Patel Traders', email: '', phone: '98765 43210', address: 'Navrangpura, Ahmedabad', gstin: '24AAACP1234A1Z1'),
    Customer(id: 'c2', name: 'Mehta Kirana', email: '', phone: '99098 11223', address: 'Maninagar, Ahmedabad', gstin: ''),
    Customer(id: 'c3', name: 'Ravi Kumar', email: '', phone: '90990 55667', address: 'Satellite, Ahmedabad', gstin: ''),
    Customer(id: 'c4', name: 'Shree Ganesh Hardware', email: '', phone: '97277 88990', address: 'Vastrapur, Ahmedabad', gstin: '24AAGCS5678B1Z2'),
    Customer(id: 'c5', name: 'Anjali Desai', email: '', phone: '98980 33445', address: 'Bopal, Ahmedabad', gstin: ''),
  ];
  for (final c in customers) {
    await CustomerService.insertCustomer(c);
  }

  final products = [
    Product(id: 'p1', name: 'Basmati Rice 5 kg', description: '', price: 545, stock: 40, hsncode: '1006', tax_rate: 5),
    Product(id: 'p2', name: 'Sunflower Oil 1 L', description: '', price: 165, stock: 60, hsncode: '1512', tax_rate: 5),
    Product(id: 'p3', name: 'Toor Dal 1 kg', description: '', price: 148, stock: 8, hsncode: '0713', tax_rate: 5),
    Product(id: 'p4', name: 'Detergent Powder 2 kg', description: '', price: 230, stock: 25, hsncode: '3402', tax_rate: 18),
    Product(id: 'p5', name: 'Tea 500 g', description: '', price: 260, stock: 5, hsncode: '0902', tax_rate: 5),
    Product(id: 'p6', name: 'Sugar 5 kg', description: '', price: 245, stock: 30, hsncode: '1701', tax_rate: 5),
  ];
  for (final p in products) {
    await ProductService.insertProduct(p);
  }

  final now = DateTime.now();
  final lines = [
    [(0, 2), (1, 3)],
    [(2, 4), (4, 1)],
    [(3, 2), (5, 1), (1, 1)],
    [(0, 1)],
    [(4, 2), (2, 2)],
    [(5, 3), (3, 1)],
    [(1, 6)],
    [(0, 3), (2, 2), (4, 1)],
  ];
  for (var i = 0; i < lines.length; i++) {
    final inv = Invoice(
      id: 'inv$i',
      invoiceNumber: '${1001 + i}',
      customer: customers[i % customers.length],
      items: [for (final (p, q) in lines[i]) InvoiceItem(product: products[p], quantity: q.toDouble())],
      date: now.subtract(Duration(days: 3 + i * 9)),
      dueDate: now.subtract(Duration(days: 3 + i * 9 - 15)),
      type: 'Invoice',
      taxRate: 5,
    );
    await InvoiceService.insertInvoice(inv);
    if (i.isEven) {
      final saved = (await InvoiceService.getInvoiceById(inv.id))!;
      await PaymentService.addPayment(
          invoice: saved, amountPaid: saved.total, datePaid: inv.date, paymentMethod: 'UPI');
    }
  }
}

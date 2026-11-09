import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crizavoise/providers/repositories.dart';
import 'package:crizavoise/models/supplier.dart';

class SupplierNotifier extends AsyncNotifier<List<Supplier>> {
  @override
  Future<List<Supplier>> build() async {
    return ref.read(supplierRepositoryProvider).getAllSuppliers();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(supplierRepositoryProvider).getAllSuppliers());
  }
}

final suppliersProvider =
    AsyncNotifierProvider<SupplierNotifier, List<Supplier>>(SupplierNotifier.new);

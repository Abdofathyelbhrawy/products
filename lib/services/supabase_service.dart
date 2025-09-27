import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/constants/database_constants.dart';
import 'package:flutter_application_1/models/product.dart';
import 'package:flutter_application_1/models/invoice.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  final supabase = Supabase.instance.client;

  // ============ Authentication Methods ============

  Future<AuthResponse> signUp(String email, String password) async {
    return await supabase.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  Session? getCurrentSession() {
    return supabase.auth.currentSession;
  }

  // ============ Products CRUD Methods ============

  Future<List<Product>> getProducts() async {
    try {
      final response = await supabase
          .from(DatabaseConstants.productsTable)
          .select();

      return response.map<Product>((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  Future<Product?> getProductById(String id) async {
    try {
      final response = await supabase
          .from(DatabaseConstants.productsTable)
          .select()
          .eq(DatabaseConstants.idColumn, id)
          .single();

      return Product.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    try {
      final response = await supabase
          .from(DatabaseConstants.productsTable)
          .select()
          .eq(DatabaseConstants.barcodeColumn, barcode)
          .single();

      return Product.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<Product> createProduct(Product product) async {
    try {
      final response = await supabase
          .from(DatabaseConstants.productsTable)
          .insert(product.toJson())
          .select()
          .single();

      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  Future<Product> updateProduct(String id, Product product) async {
    try {
      final response = await supabase
          .from(DatabaseConstants.productsTable)
          .update(product.toJson())
          .eq(DatabaseConstants.idColumn, id)
          .select()
          .single();

      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await supabase
          .from(DatabaseConstants.productsTable)
          .delete()
          .eq(DatabaseConstants.idColumn, id);
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // ============ Invoices CRUD Methods ============

  Future<List<Invoice>> getInvoices() async {
    try {
      final response = await supabase
          .from(DatabaseConstants.invoicesTable)
          .select('''
            *,
            ${DatabaseConstants.invoiceItemsTable}(
              *,
              ${DatabaseConstants.productsTable}(*)
            )
          ''');

      return response.map<Invoice>((json) => Invoice.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch invoices: $e');
    }
  }

  Future<Invoice?> getInvoiceById(String id) async {
    try {
      final response = await supabase
          .from(DatabaseConstants.invoicesTable)
          .select('''
            *,
            ${DatabaseConstants.invoiceItemsTable}(
              *,
              ${DatabaseConstants.productsTable}(*)
            )
          ''')
          .eq(DatabaseConstants.idColumn, id)
          .single();

      return Invoice.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<Invoice> createInvoice(Invoice invoice) async {
    try {
      final response = await supabase
          .from(DatabaseConstants.invoicesTable)
          .insert(invoice.toJson())
          .select()
          .single();

      return Invoice.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create invoice: $e');
    }
  }

  Future<void> deleteInvoice(String id) async {
    try {
      await supabase
          .from(DatabaseConstants.invoicesTable)
          .delete()
          .eq(DatabaseConstants.idColumn, id);
    } catch (e) {
      throw Exception('Failed to delete invoice: $e');
    }
  }

  // ============ Search Methods ============

  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await supabase
          .from(DatabaseConstants.productsTable)
          .select()
          .or(
            '${DatabaseConstants.nameColumn}.ilike.%$query%,${DatabaseConstants.barcodeColumn}.ilike.%$query%',
          );

      return response.map<Product>((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }
}

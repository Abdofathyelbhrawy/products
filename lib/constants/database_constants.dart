class DatabaseConstants {
  // Supabase Configuration
  static const String supabaseUrl = 'https://ymdqcflcnczsjdadhulj.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InltZHFjZmxjbmN6c2pkYWRodWxqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg5MDgzNDksImV4cCI6MjA3NDQ4NDM0OX0.HitJNTnF70cnOVgP5rYJyEhrPNnoYU9_1tJHLDMuxlE';

  // Database Connection String (for reference - not used directly in Flutter)
  static const String databaseUrl =
      'postgresql://postgres:[YOUR-PASSWORD]@db.ymdqcflcnczsjdadhulj.supabase.co:5432/postgres';

  // Table Names
  static const String productsTable = 'products';
  static const String invoicesTable = 'invoices';
  static const String invoiceItemsTable = 'invoice_items';
  static const String usersTable = 'users';

  // Column Names
  static const String idColumn = 'id';
  static const String nameColumn = 'name';
  static const String priceColumn = 'price';
  static const String barcodeColumn = 'barcode';
  static const String descriptionColumn = 'description';
  static const String categoryColumn = 'category';
  static const String stockColumn = 'stock';
  static const String createdAtColumn = 'created_at';
  static const String updatedAtColumn = 'updated_at';
  static const String userIdColumn = 'user_id';
  static const String totalColumn = 'total';
  static const String invoiceIdColumn = 'invoice_id';
  static const String productIdColumn = 'product_id';
  static const String quantityColumn = 'quantity';
  static const String subtotalColumn = 'subtotal';
}

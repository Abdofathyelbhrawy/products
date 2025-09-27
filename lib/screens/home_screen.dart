import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/invoice_screen.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/services/supabase_service.dart';
import 'package:flutter_application_1/services/storage_service.dart';
import 'package:flutter_application_1/models/product.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MobileScannerController? controller;
  final _supabaseService = SupabaseService();
  final _storageService = StorageService();
  bool _isScanning = true;

  Future<void> _logout() async {
    try {
      // تسجيل الخروج من Supabase
      await _supabaseService.supabase.auth.signOut();

      // حذف حالة الدخول المحفوظة محلياً
      await _storageService.logout();

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      // حتى لو فشل تسجيل الخروج من Supabase، احذف البيانات المحلية
      await _storageService.logout();

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نظام السوبر ماركت'),
        actions: [
          IconButton(
            icon: Icon(_isScanning ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              setState(() {
                _isScanning = !_isScanning;
                if (_isScanning) {
                  controller?.start();
                } else {
                  controller?.stop();
                }
              });
            },
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: MobileScanner(controller: controller, onDetect: _onDetect),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                _isScanning ? 'امسح الباركود' : 'المسح متوقف',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const InvoiceScreen()),
          );
        },
        child: const Icon(Icons.receipt),
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _handleScannedBarcode(barcode.rawValue!);
        break; // توقف بعد أول باركود
      }
    }
  }

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
  }

  Future<void> _handleScannedBarcode(String barcode) async {
    try {
      // البحث عن المنتج باستخدام الباركود
      final product = await _supabaseService.getProductByBarcode(barcode);

      if (product != null) {
        if (!mounted) return;
        _showProductDialog(product);
      } else {
        if (!mounted) return;
        _showAddProductDialog(barcode);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في البحث عن المنتج: $e')));
    }
  }

  void _showProductDialog(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('السعر: ${product.price} ريال'),
            if (product.description != null)
              Text('الوصف: ${product.description}'),
            if (product.category != null) Text('الفئة: ${product.category}'),
            if (product.stock != null) Text('المخزون: ${product.stock}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // يمكن إضافة المنتج للسلة هنا
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم إضافة ${product.name} للسلة')),
              );
            },
            child: const Text('إضافة للسلة'),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog(String barcode) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();
    final categoryController = TextEditingController();
    final stockController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة منتج جديد'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'اسم المنتج'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'السعر'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'الوصف'),
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'الفئة'),
              ),
              TextField(
                controller: stockController,
                decoration: const InputDecoration(labelText: 'المخزون'),
                keyboardType: TextInputType.number,
              ),
              Text('الباركود: $barcode'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  priceController.text.isNotEmpty) {
                try {
                  final product = Product(
                    id: '', // سيتم إنشاؤه تلقائياً في قاعدة البيانات
                    name: nameController.text,
                    price: double.parse(priceController.text),
                    barcode: barcode,
                    description: descriptionController.text.isNotEmpty
                        ? descriptionController.text
                        : null,
                    category: categoryController.text.isNotEmpty
                        ? categoryController.text
                        : null,
                    stock: stockController.text.isNotEmpty
                        ? int.parse(stockController.text)
                        : null,
                  );

                  await _supabaseService.createProduct(product);

                  if (!mounted) return;
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم إضافة المنتج بنجاح')),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('خطأ في إضافة المنتج: $e')),
                  );
                }
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

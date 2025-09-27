import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/services/storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // انتظار حتى يتم بناء الويدجت بالكامل
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    try {
      // التحقق من حالة الدخول المحفوظة محلياً
      final isLoggedIn = await _storageService.isLoggedIn();

      // التحقق من جلسة Supabase
      final session = Supabase.instance.client.auth.currentSession;

      if (isLoggedIn && session != null) {
        // المستخدم مسجل دخول والجلسة صالحة
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // المستخدم غير مسجل دخول أو الجلسة منتهية الصلاحية
        if (isLoggedIn && session == null) {
          // حالة الدخول محفوظة محلياً لكن الجلسة منتهية الصلاحية
          await _storageService.logout();
        }

        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      // في حالة حدوث خطأ، انتقل إلى شاشة تسجيل الدخول
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

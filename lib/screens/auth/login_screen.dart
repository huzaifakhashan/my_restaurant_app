import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../services/auth_service.dart';
import '../../services/seed_service.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool seeding = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
  final success = await AuthService.login(
    email: emailController.text.trim(),
    password: passwordController.text,
  );

  if (!mounted) return;

  if (success) {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.home,
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('البريد الإلكتروني أو كلمة المرور غير صحيحة'),
      ),
    );
  }
}

  Future<void> seedDemoData() async {
    setState(() => seeding = true);

    String message;
    try {
      await SeedService.seed();
      message = 'تمت إضافة البيانات التجريبية بنجاح';
    } catch (e) {
      message = 'فشل إضافة البيانات التجريبية: $e';
    }

    if (!mounted) return;
    setState(() => seeding = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.volunteer_activism,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(height: 20),

              const Text(
                'زاد الخير',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'شارك الخير، واصنع الفرق',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 40),

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: Icon(Icons.email),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: login,
                child: const Text(
                  'تسجيل الدخول',
                  style: TextStyle(fontSize: 17),
                ),
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.register);
                },
                child: const Text('إنشاء حساب جديد'),
              ),

              const SizedBox(height: 24),

              const Text(
                'حسابات تجريبية (كلمة المرور: 123456):\n'
                'restaurant@test.com — مطعم\n'
                'user@test.com — مستفيد\n'
                'volunteer@test.com — متطوع\n'
                'donor@test.com — متبرع فردي',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),

              if (kDebugMode) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: seeding ? null : seedDemoData,
                  icon: seeding
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.dataset),
                  label: const Text('إضافة بيانات تجريبية'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../screens/reservations/qr_scanner_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    return PopScope(
      // بعد تسجيل الدخول، ما بدنا نسمح بالرجوع لشاشة الدخول عبر زر
      // الرجوع (خصوصاً على الويب، وين متصفح Chrome بيحتفظ بسجل تصفح
      // منفصل عن سجل الـ Navigator الداخلي بفلاتر).
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('زاد الخير'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.notifications);
              },
              icon: const Icon(Icons.notifications),
            ),
            IconButton(
              onPressed: () async {
                await AuthService.logout();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),

        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'مرحباً بك 👋',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                'ماذا تريد أن تفعل اليوم؟',
                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 30),

              if (user?.role == UserRole.restaurant) ...[
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.addMeal);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة وجبة'),
                ),

                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.myMeals);
                  },
                  icon: const Icon(Icons.list),
                  label: const Text('وجباتي'),
                ),

                _HomeButton(
                  icon: Icons.bookmark,
                  title: 'الحجوزات',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.reservations);
                  },
                ),
              ] else if (user?.role == UserRole.beneficiary) ...[
                _HomeButton(
                  icon: Icons.restaurant,
                  title: 'الوجبات المتاحة',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.meals);
                  },
                ),

                _HomeButton(
                  icon: Icons.bookmark,
                  title: 'حجوزاتي',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.reservations);
                  },
                ),

                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.donations);
                  },
                  icon: const Icon(Icons.volunteer_activism),
                  label: const Text('التبرعات المتاحة'),
                ),

                _HomeButton(
                  icon: Icons.inventory,
                  title: 'طلباتي',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.myDonationRequests);
                  },
                ),
              ] else if (user?.role == UserRole.donor) ...[
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.addDonation);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة تبرع'),
                ),

                _HomeButton(
                  icon: Icons.list,
                  title: 'تبرعاتي',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.myDonations);
                  },
                ),
              ] else if (user?.role == UserRole.volunteer) ...[
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.volunteer);
                  },
                  icon: const Icon(Icons.volunteer_activism),
                  label: const Text('فرص التطوع'),
                ),

                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.tasks);
                  },
                  icon: const Icon(Icons.assignment),
                  label: const Text('مهامي'),
                ),
                _HomeButton(
                  icon: Icons.check_circle,
                  title: 'المهام المكتملة',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.completedTasks);
                  },
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.verifyReservation);
                  },
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('التحقق من الحجز'),
                ),
                // mobile_scanner ما بيدعم الويندوز، والتحقق اليدوي بالكود متاح بشاشة التحقق.
                if (defaultTargetPlatform != TargetPlatform.windows)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const QrScannerScreen(),
                        ),
                      );
                    },

                    icon: const Icon(Icons.qr_code_scanner),

                    label: const Text('مسح QR'),
                  ),
              ],
            ],
          ),
        ),

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          onTap: (index) {
            switch (index) {
              case 0:
                return;
              case 1:
                Navigator.pushNamed(context, _exploreRoute(user?.role));
                return;
              case 2:
                Navigator.pushNamed(context, AppRoutes.profile);
                return;
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'استكشف'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
          ],
        ),
      ),
    );
  }

  /// الشاشة الرئيسية للتصفح حسب دور المستخدم، لتبويبة "استكشف".
  String _exploreRoute(UserRole? role) {
    switch (role) {
      case UserRole.restaurant:
        return AppRoutes.myMeals;
      case UserRole.beneficiary:
        return AppRoutes.meals;
      case UserRole.donor:
        return AppRoutes.myDonations;
      case UserRole.volunteer:
        return AppRoutes.volunteer;
      case null:
        return AppRoutes.home;
    }
  }
}

class _HomeButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _HomeButton({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}

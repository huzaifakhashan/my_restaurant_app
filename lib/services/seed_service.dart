import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/donation.dart';
import '../models/donation_request.dart';
import '../models/meal.dart';
import '../models/reservation.dart';
import '../models/user.dart';
import '../models/volunteer_task.dart';

/// يعبّي قاعدة البيانات ببيانات تجريبية (حسابات + وجبات + تبرعات + حجوزات + مهام).
/// المستندات لها معرّفات ثابتة (seed_...) فإعادة التشغيل تحدّثها بدل ما تكررها.
class SeedService {
  static const String password = '123456';

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// يسجّل دخول الحساب إذا موجود، أو ينشئه إذا مش موجود، ويكتب ملفه بـ users.
  static Future<String> _ensureUser({
    required String name,
    required String email,
    required UserRole role,
  }) async {
    UserCredential credential;
    try {
      credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException {
      credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    }

    final uid = credential.user!.uid;
    await _db.collection('users').doc(uid).set(
          AppUser(id: uid, name: name, email: email, role: role).toMap(),
        );
    return uid;
  }

  static Future<void> seed() async {
    // ---------- المطعم + وجباته ----------
    final restaurantId = await _ensureUser(
      name: 'مطعم الأصالة',
      email: 'restaurant@test.com',
      role: UserRole.restaurant,
    );

    final meals = [
      Meal(
        id: 'seed_meal_1',
        restaurantId: restaurantId,
        name: 'كبسة دجاج',
        quantity: 12,
        pickupTime: 'اليوم 8:00 م - 10:00 م',
        location: 'دمشق - المزة، شارع الجلاء',
        notes: 'وجبات طازجة من عشاء اليوم، يرجى إحضار أكياس',
      ),
      Meal(
        id: 'seed_meal_2',
        restaurantId: restaurantId,
        name: 'مقلوبة باذنجان',
        quantity: 8,
        pickupTime: 'اليوم 9:00 م - 11:00 م',
        location: 'دمشق - المزة، شارع الجلاء',
        notes: 'نباتية بالكامل',
      ),
      Meal(
        id: 'seed_meal_3',
        restaurantId: restaurantId,
        name: 'شاورما عربي',
        quantity: 20,
        pickupTime: 'غداً 1:00 م - 3:00 م',
        location: 'دمشق - المزة، شارع الجلاء',
        notes: 'مع بطاطا ومخلل',
      ),
      Meal(
        id: 'seed_meal_4',
        restaurantId: restaurantId,
        name: 'فتة حمص',
        quantity: 5,
        pickupTime: 'غداً 7:00 ص - 9:00 ص',
        location: 'دمشق - المزة، شارع الجلاء',
        notes: 'فطور، تُستهلك خلال ساعتين',
      ),
      Meal(
        id: 'seed_meal_5',
        restaurantId: restaurantId,
        name: 'أرز بالخضار',
        quantity: 0,
        pickupTime: 'أمس 8:00 م',
        location: 'دمشق - المزة، شارع الجلاء',
        notes: 'تم حجزها بالكامل',
        status: MealStatus.reserved,
      ),
    ];

    final mealsRef = _db.collection('meals');
    for (final meal in meals) {
      await mealsRef.doc(meal.id).set(meal.toMap());
    }

    // ---------- المتبرع + تبرعاته ----------
    final donorId = await _ensureUser(
      name: 'أحمد المتبرع',
      email: 'donor@test.com',
      role: UserRole.donor,
    );

    final donations = [
      Donation(
        id: 'seed_donation_1',
        donorId: donorId,
        title: 'سلة مواد غذائية',
        type: DonationType.packagedFood,
        quantity: 10,
        location: 'دمشق - ركن الدين',
        pickupTime: 'يومياً 4:00 م - 7:00 م',
        description: 'رز، سكر، زيت، عدس، معكرونة',
      ),
      Donation(
        id: 'seed_donation_2',
        donorId: donorId,
        title: 'ملابس شتوية للأطفال',
        type: DonationType.clothes,
        quantity: 15,
        location: 'دمشق - ركن الدين',
        pickupTime: 'الجمعة 10:00 ص - 1:00 م',
        description: 'جواكيت وكنزات بحالة ممتازة، أعمار 3-10 سنوات',
      ),
      Donation(
        id: 'seed_donation_3',
        donorId: donorId,
        title: 'كتب مدرسية',
        type: DonationType.books,
        quantity: 25,
        location: 'دمشق - ركن الدين',
        pickupTime: 'السبت 9:00 ص - 12:00 م',
        description: 'منهاج الصف السابع والثامن',
      ),
      Donation(
        id: 'seed_donation_4',
        donorId: donorId,
        title: 'طقم أواني طبخ',
        type: DonationType.kitchenItems,
        quantity: 2,
        location: 'دمشق - ركن الدين',
        pickupTime: 'أي يوم بعد 5:00 م',
        description: 'طنجرة ضغط + طقم مقالي',
      ),
      Donation(
        id: 'seed_donation_5',
        donorId: donorId,
        title: 'ألعاب أطفال',
        type: DonationType.toys,
        quantity: 0,
        location: 'دمشق - ركن الدين',
        pickupTime: 'تم التسليم',
        description: 'ألعاب تركيب ودمى',
        status: DonationStatus.completed,
      ),
    ];

    final donationsRef = _db.collection('donations');
    for (final donation in donations) {
      await donationsRef.doc(donation.id).set(donation.toMap());
    }

    // ---------- المتطوع + المهام ----------
    final volunteerId = await _ensureUser(
      name: 'سارة المتطوعة',
      email: 'volunteer@test.com',
      role: UserRole.volunteer,
    );

    final tasks = [
      VolunteerTask(
        id: 'seed_task_1',
        title: 'توصيل وجبات كبسة',
        pickupLocation: 'مطعم الأصالة - المزة',
        deliveryLocation: 'دار رعاية المسنين - كفرسوسة',
        pickupTime: 'اليوم 8:30 م',
        quantity: 10,
        notes: 'يفضّل وجود سيارة',
      ),
      VolunteerTask(
        id: 'seed_task_2',
        title: 'نقل سلال غذائية',
        pickupLocation: 'ركن الدين',
        deliveryLocation: 'جمعية البر - الميدان',
        pickupTime: 'غداً 5:00 م',
        quantity: 6,
        notes: 'السلال ثقيلة نوعاً ما',
      ),
      VolunteerTask(
        id: 'seed_task_3',
        title: 'توزيع ملابس شتوية',
        pickupLocation: 'ركن الدين',
        deliveryLocation: 'مدرسة الأمل - جرمانا',
        pickupTime: 'الجمعة 11:00 ص',
        quantity: 15,
        notes: '',
      ),
      VolunteerTask(
        id: 'seed_task_4',
        volunteerId: volunteerId,
        title: 'توصيل شاورما',
        pickupLocation: 'مطعم الأصالة - المزة',
        deliveryLocation: 'مخيم اليرموك',
        pickupTime: 'غداً 1:30 م',
        quantity: 20,
        notes: 'تواصل مع أبو محمد عند الوصول',
        status: VolunteerTaskStatus.accepted,
      ),
      VolunteerTask(
        id: 'seed_task_5',
        volunteerId: volunteerId,
        title: 'توصيل كتب مدرسية',
        pickupLocation: 'ركن الدين',
        deliveryLocation: 'مدرسة الأمل - جرمانا',
        pickupTime: 'الأسبوع الماضي',
        quantity: 25,
        notes: '',
        status: VolunteerTaskStatus.completed,
      ),
    ];

    final tasksRef = _db.collection('volunteerTasks');
    for (final task in tasks) {
      await tasksRef.doc(task.id).set(task.toMap());
    }

    // ---------- المستفيد + حجوزاته وطلباته ----------
    final beneficiaryId = await _ensureUser(
      name: 'محمد المستفيد',
      email: 'user@test.com',
      role: UserRole.beneficiary,
    );

    final reservations = [
      Reservation(
        id: 'seed_reservation_1',
        mealId: 'seed_meal_5',
        restaurantId: restaurantId,
        requesterId: beneficiaryId,
        mealName: 'أرز بالخضار',
        mealLocation: 'دمشق - المزة، شارع الجلاء',
        mealPickupTime: 'أمس 8:00 م',
        quantity: 4,
        code: 'ZAD10001',
        status: ReservationStatus.completed,
      ),
      Reservation(
        id: 'seed_reservation_2',
        mealId: 'seed_meal_1',
        restaurantId: restaurantId,
        requesterId: beneficiaryId,
        mealName: 'كبسة دجاج',
        mealLocation: 'دمشق - المزة، شارع الجلاء',
        mealPickupTime: 'اليوم 8:00 م - 10:00 م',
        quantity: 3,
        code: 'ZAD10002',
        status: ReservationStatus.confirmed,
      ),
    ];

    final reservationsRef = _db.collection('reservations');
    for (final reservation in reservations) {
      await reservationsRef.doc(reservation.id).set(reservation.toMap());
    }

    final requests = [
      DonationRequest(
        id: 'seed_request_1',
        donationId: 'seed_donation_1',
        donorId: donorId,
        requesterId: beneficiaryId,
        donationTitle: 'سلة مواد غذائية',
        donationLocation: 'دمشق - ركن الدين',
        donationPickupTime: 'يومياً 4:00 م - 7:00 م',
        quantity: 2,
        code: 'DON20001',
        status: DonationRequestStatus.confirmed,
      ),
      DonationRequest(
        id: 'seed_request_2',
        donationId: 'seed_donation_5',
        donorId: donorId,
        requesterId: beneficiaryId,
        donationTitle: 'ألعاب أطفال',
        donationLocation: 'دمشق - ركن الدين',
        donationPickupTime: 'تم التسليم',
        quantity: 3,
        code: 'DON20002',
        status: DonationRequestStatus.completed,
      ),
    ];

    final requestsRef = _db.collection('donationRequests');
    for (final request in requests) {
      await requestsRef.doc(request.id).set(request.toMap());
    }

    await _auth.signOut();
  }
}

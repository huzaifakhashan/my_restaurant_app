import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/meal.dart';
import '../models/reservation.dart';

class ReservationService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final CollectionReference<Map<String, dynamic>> _mealsRef =
      _db.collection('meals');
  static final CollectionReference<Map<String, dynamic>> _reservationsRef =
      _db.collection('reservations');

  /// يحجز كمية من وجبة داخل معاملة (transaction) حتى ما يصير تعارض إذا
  /// أكتر من مستخدم حجز بنفس اللحظة. يرجع null إذا الكمية غير متوفرة.
  static Future<Reservation?> reserveMeal({
    required Meal meal,
    required int quantity,
    required String requesterId,
  }) async {
    if (quantity <= 0) return null;

    final reservationDoc = _reservationsRef.doc();
    final code = 'ZAD${DateTime.now().millisecondsSinceEpoch % 100000}';

    return _db.runTransaction<Reservation?>((transaction) async {
      final mealSnapshot = await transaction.get(_mealsRef.doc(meal.id));
      final currentQuantity = mealSnapshot.data()?['quantity'] as int? ?? 0;

      if (quantity > currentQuantity) {
        return null;
      }

      final remaining = currentQuantity - quantity;
      transaction.update(_mealsRef.doc(meal.id), {
        'quantity': remaining,
        if (remaining == 0) 'status': MealStatus.reserved.name,
      });

      final reservation = Reservation(
        id: reservationDoc.id,
        mealId: meal.id,
        restaurantId: meal.restaurantId,
        requesterId: requesterId,
        mealName: meal.name,
        mealLocation: meal.location,
        mealPickupTime: meal.pickupTime,
        quantity: quantity,
        code: code,
        status: ReservationStatus.confirmed,
      );

      transaction.set(reservationDoc, reservation.toMap());

      return reservation;
    });
  }

  static Stream<List<Reservation>> streamMyReservations(String requesterId) {
    return _reservationsRef
        .where('requesterId', isEqualTo: requesterId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Reservation.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  static Stream<List<Reservation>> streamRestaurantReservations(
    String restaurantId,
  ) {
    return _reservationsRef
        .where('restaurantId', isEqualTo: restaurantId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Reservation.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  static Future<Reservation?> findByCode(String code) async {
    final snapshot = await _reservationsRef
        .where('code', isEqualTo: code)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return Reservation.fromMap(snapshot.docs.first.id, snapshot.docs.first.data());
  }

  static Future<bool> completeReservation(Reservation reservation) async {
    if (reservation.status != ReservationStatus.confirmed) {
      return false;
    }

    await _reservationsRef.doc(reservation.id).update({
      'status': ReservationStatus.completed.name,
    });

    return true;
  }
}

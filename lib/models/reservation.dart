enum ReservationStatus {
  pending,
  confirmed,
  completed,
  cancelled,
}

ReservationStatus reservationStatusFromString(String value) {
  return ReservationStatus.values.firstWhere(
    (status) => status.name == value,
    orElse: () => ReservationStatus.pending,
  );
}

class Reservation {
  final String id;
  final String mealId;
  final String restaurantId;
  final String requesterId;

  final String mealName;
  final String mealLocation;
  final String mealPickupTime;

  final int quantity;
  final String code;
  ReservationStatus status;

  Reservation({
    required this.id,
    required this.mealId,
    required this.restaurantId,
    required this.requesterId,
    required this.mealName,
    required this.mealLocation,
    required this.mealPickupTime,
    required this.quantity,
    required this.code,
    required this.status,
  });

  factory Reservation.fromMap(String id, Map<String, dynamic> map) {
    return Reservation(
      id: id,
      mealId: map['mealId'] as String,
      restaurantId: map['restaurantId'] as String,
      requesterId: map['requesterId'] as String,
      mealName: map['mealName'] as String,
      mealLocation: map['mealLocation'] as String,
      mealPickupTime: map['mealPickupTime'] as String,
      quantity: map['quantity'] as int,
      code: map['code'] as String,
      status: reservationStatusFromString(map['status'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mealId': mealId,
      'restaurantId': restaurantId,
      'requesterId': requesterId,
      'mealName': mealName,
      'mealLocation': mealLocation,
      'mealPickupTime': mealPickupTime,
      'quantity': quantity,
      'code': code,
      'status': status.name,
    };
  }
}

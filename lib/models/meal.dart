enum MealStatus {
  available,
  reserved,
  completed,
  cancelled,
}

MealStatus mealStatusFromString(String value) {
  return MealStatus.values.firstWhere(
    (status) => status.name == value,
    orElse: () => MealStatus.available,
  );
}

class Meal {
  final String id;
  final String restaurantId;
  final String name;
  int quantity;
  final String pickupTime;
  final String location;
  final String notes;
  MealStatus status;

  Meal({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.quantity,
    required this.pickupTime,
    required this.location,
    required this.notes,
    this.status = MealStatus.available,
  });

  factory Meal.fromMap(String id, Map<String, dynamic> map) {
    return Meal(
      id: id,
      restaurantId: map['restaurantId'] as String,
      name: map['name'] as String,
      quantity: map['quantity'] as int,
      pickupTime: map['pickupTime'] as String,
      location: map['location'] as String,
      notes: map['notes'] as String,
      status: mealStatusFromString(map['status'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'restaurantId': restaurantId,
      'name': name,
      'quantity': quantity,
      'pickupTime': pickupTime,
      'location': location,
      'notes': notes,
      'status': status.name,
    };
  }
}

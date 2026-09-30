enum VolunteerTaskStatus {
  available,
  accepted,
  pickedUp,
  delivered,
  completed,
  cancelled,
}

VolunteerTaskStatus volunteerTaskStatusFromString(String value) {
  return VolunteerTaskStatus.values.firstWhere(
    (status) => status.name == value,
    orElse: () => VolunteerTaskStatus.available,
  );
}

class VolunteerTask {
  final String id;
  final String? volunteerId;

  final String title;
  final String pickupLocation;
  final String deliveryLocation;

  final String pickupTime;
  final int quantity;
  final String notes;

  VolunteerTaskStatus status;

  VolunteerTask({
    required this.id,
    this.volunteerId,
    required this.title,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.pickupTime,
    required this.quantity,
    required this.notes,
    this.status = VolunteerTaskStatus.available,
  });

  factory VolunteerTask.fromMap(String id, Map<String, dynamic> map) {
    return VolunteerTask(
      id: id,
      volunteerId: map['volunteerId'] as String?,
      title: map['title'] as String,
      pickupLocation: map['pickupLocation'] as String,
      deliveryLocation: map['deliveryLocation'] as String,
      pickupTime: map['pickupTime'] as String,
      quantity: map['quantity'] as int,
      notes: map['notes'] as String,
      status: volunteerTaskStatusFromString(map['status'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'volunteerId': volunteerId,
      'title': title,
      'pickupLocation': pickupLocation,
      'deliveryLocation': deliveryLocation,
      'pickupTime': pickupTime,
      'quantity': quantity,
      'notes': notes,
      'status': status.name,
    };
  }
}

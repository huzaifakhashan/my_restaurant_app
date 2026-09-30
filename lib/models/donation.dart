enum DonationType {
  packagedFood,
  freshFood,
  clothes,
  books,
  toys,
  householdItems,
  kitchenItems,
  furniture,
  other,
}

extension DonationTypeLabel on DonationType {
  String get label {
    switch (this) {
      case DonationType.packagedFood:
        return 'أغذية معلبة';
      case DonationType.freshFood:
        return 'مواد غذائية طازجة';
      case DonationType.clothes:
        return 'ملابس';
      case DonationType.books:
        return 'كتب';
      case DonationType.toys:
        return 'ألعاب';
      case DonationType.householdItems:
        return 'أدوات منزلية';
      case DonationType.kitchenItems:
        return 'أدوات مطبخ';
      case DonationType.furniture:
        return 'أثاث';
      case DonationType.other:
        return 'أخرى';
    }
  }
}

DonationType donationTypeFromString(String value) {
  return DonationType.values.firstWhere(
    (type) => type.name == value,
    orElse: () => DonationType.other,
  );
}

enum DonationStatus {
  available,
  reserved,
  completed,
  cancelled,
}

DonationStatus donationStatusFromString(String value) {
  return DonationStatus.values.firstWhere(
    (status) => status.name == value,
    orElse: () => DonationStatus.available,
  );
}

class Donation {
  final String id;
  final String donorId;
  final String title;
  final DonationType type;
  int quantity;
  final String location;
  final String pickupTime;
  final String description;

  DonationStatus status;

  Donation({
    required this.id,
    required this.donorId,
    required this.title,
    required this.type,
    required this.quantity,
    required this.location,
    required this.pickupTime,
    required this.description,
    this.status = DonationStatus.available,
  });

  factory Donation.fromMap(String id, Map<String, dynamic> map) {
    return Donation(
      id: id,
      donorId: map['donorId'] as String,
      title: map['title'] as String,
      type: donationTypeFromString(map['type'] as String),
      quantity: map['quantity'] as int,
      location: map['location'] as String,
      pickupTime: map['pickupTime'] as String,
      description: map['description'] as String,
      status: donationStatusFromString(map['status'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'donorId': donorId,
      'title': title,
      'type': type.name,
      'quantity': quantity,
      'location': location,
      'pickupTime': pickupTime,
      'description': description,
      'status': status.name,
    };
  }
}

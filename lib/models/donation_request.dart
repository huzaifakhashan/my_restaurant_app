enum DonationRequestStatus {
  pending,
  confirmed,
  completed,
  cancelled,
}

DonationRequestStatus donationRequestStatusFromString(String value) {
  return DonationRequestStatus.values.firstWhere(
    (status) => status.name == value,
    orElse: () => DonationRequestStatus.pending,
  );
}

class DonationRequest {
  final String id;
  final String donationId;
  final String donorId;
  final String requesterId;

  final String donationTitle;
  final String donationLocation;
  final String donationPickupTime;

  final int quantity;
  final String code;

  DonationRequestStatus status;

  DonationRequest({
    required this.id,
    required this.donationId,
    required this.donorId,
    required this.requesterId,
    required this.donationTitle,
    required this.donationLocation,
    required this.donationPickupTime,
    required this.quantity,
    required this.code,
    required this.status,
  });

  factory DonationRequest.fromMap(String id, Map<String, dynamic> map) {
    return DonationRequest(
      id: id,
      donationId: map['donationId'] as String,
      donorId: map['donorId'] as String,
      requesterId: map['requesterId'] as String,
      donationTitle: map['donationTitle'] as String,
      donationLocation: map['donationLocation'] as String,
      donationPickupTime: map['donationPickupTime'] as String,
      quantity: map['quantity'] as int,
      code: map['code'] as String,
      status: donationRequestStatusFromString(map['status'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'donationId': donationId,
      'donorId': donorId,
      'requesterId': requesterId,
      'donationTitle': donationTitle,
      'donationLocation': donationLocation,
      'donationPickupTime': donationPickupTime,
      'quantity': quantity,
      'code': code,
      'status': status.name,
    };
  }
}

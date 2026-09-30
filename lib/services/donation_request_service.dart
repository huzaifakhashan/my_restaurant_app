import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/donation.dart';
import '../models/donation_request.dart';

class DonationRequestService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final CollectionReference<Map<String, dynamic>> _donationsRef =
      _db.collection('donations');
  static final CollectionReference<Map<String, dynamic>> _requestsRef =
      _db.collection('donationRequests');

  static Future<DonationRequest?> requestDonation({
    required Donation donation,
    required int quantity,
    required String requesterId,
  }) async {
    if (quantity <= 0) return null;

    final requestDoc = _requestsRef.doc();
    final code = 'DON${DateTime.now().millisecondsSinceEpoch % 100000}';

    return _db.runTransaction<DonationRequest?>((transaction) async {
      final donationSnapshot = await transaction.get(
        _donationsRef.doc(donation.id),
      );
      final currentQuantity =
          donationSnapshot.data()?['quantity'] as int? ?? 0;

      if (quantity > currentQuantity) {
        return null;
      }

      final remaining = currentQuantity - quantity;
      transaction.update(_donationsRef.doc(donation.id), {
        'quantity': remaining,
        if (remaining == 0) 'status': DonationStatus.reserved.name,
      });

      final request = DonationRequest(
        id: requestDoc.id,
        donationId: donation.id,
        donorId: donation.donorId,
        requesterId: requesterId,
        donationTitle: donation.title,
        donationLocation: donation.location,
        donationPickupTime: donation.pickupTime,
        quantity: quantity,
        code: code,
        status: DonationRequestStatus.confirmed,
      );

      transaction.set(requestDoc, request.toMap());

      return request;
    });
  }

  static Stream<List<DonationRequest>> streamMyRequests(String requesterId) {
    return _requestsRef
        .where('requesterId', isEqualTo: requesterId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => DonationRequest.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  static Stream<List<DonationRequest>> streamRequestsForDonor(String donorId) {
    return _requestsRef
        .where('donorId', isEqualTo: donorId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => DonationRequest.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  static Future<void> completeRequestsForDonation(String donationId) async {
    final snapshot = await _requestsRef
        .where('donationId', isEqualTo: donationId)
        .get();

    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      if (doc.data()['status'] != DonationRequestStatus.completed.name) {
        batch.update(doc.reference, {
          'status': DonationRequestStatus.completed.name,
        });
      }
    }
    await batch.commit();
  }
}

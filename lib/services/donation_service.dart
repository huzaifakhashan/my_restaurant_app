import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/donation.dart';

class DonationService {
  static final CollectionReference<Map<String, dynamic>> _donationsRef =
      FirebaseFirestore.instance.collection('donations');

  static Stream<List<Donation>> streamAvailableDonations() {
    return _donationsRef
        .where('status', isEqualTo: DonationStatus.available.name)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Donation.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  static Stream<List<Donation>> streamMyDonations(String donorId) {
    return _donationsRef
        .where('donorId', isEqualTo: donorId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Donation.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  static Future<void> addDonation(Donation donation) {
    return _donationsRef.add(donation.toMap());
  }

  static Future<void> markCompleted(Donation donation) {
    return _donationsRef.doc(donation.id).update({
      'status': DonationStatus.completed.name,
    });
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user.dart';

class AuthService {
  static AppUser? currentUser;

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final CollectionReference<Map<String, dynamic>> _usersRef =
      FirebaseFirestore.instance.collection('users');

  static Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = credential.user?.uid;
      if (uid == null) return false;

      final doc = await _usersRef.doc(uid).get();
      if (!doc.exists) return false;

      currentUser = AppUser.fromMap(uid, doc.data()!);
      return true;
    } on FirebaseAuthException {
      return false;
    }
  }

  /// يسجّل حساباً جديداً ويعيد null عند النجاح، أو رسالة الخطأ عند الفشل.
  static Future<String?> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    if (name.trim().isEmpty) {
      return 'يرجى تعبئة جميع الحقول';
    }

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = credential.user!.uid;
      final user = AppUser(
        id: uid,
        name: name.trim(),
        email: email.trim(),
        role: role,
      );

      await _usersRef.doc(uid).set(user.toMap());
      currentUser = user;

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'يوجد حساب مسجل بهذا البريد الإلكتروني مسبقاً';
        case 'invalid-email':
          return 'يرجى إدخال بريد إلكتروني صحيح';
        case 'weak-password':
          return 'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل';
        default:
          return e.message ?? 'حدث خطأ أثناء إنشاء الحساب';
      }
    }
  }

  static Future<void> logout() async {
    await _auth.signOut();
    currentUser = null;
  }
}

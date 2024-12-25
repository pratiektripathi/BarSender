import 'package:cloud_firestore/cloud_firestore.dart';

class FireService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addUser(String userId,String email, String password, String role) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'userId': userId,
        'email':email,
        'password': password,
        'role': role,
      });
    } catch (e) {
      print(e);
    }
  }

  Future<DocumentSnapshot> readUser(String userId) async {
    try {
      return await _firestore.collection('users').doc(userId).get();
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<String?> getUserId(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      return doc.exists ? doc['userId'] : null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<String?> getPassword(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      return doc.exists ? doc['password'] : null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<String?> getRole(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      return doc.exists ? doc['role'] : null;
    } catch (e) {
      print(e);
      return null;
    }
  }
}


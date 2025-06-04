import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/app/models/user_model.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'users';

  Future<bool> createUser(UserModel user) async {
    try {
      if (user.uid == null) {
        return false;
      }
      await _db.collection(_collection).doc(user.uid).set(user.toMap());
      return true;
    } catch (e) {
      print("Error writing document: $e");
      return false;
    }
  }

  Future<UserModel?> getUserById(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
          await _db.collection(_collection).doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc);
      }
      return null;
    } catch (e) {
      print("Error getting user by id: $e");
      return null;
    }
  }

  Stream<UserModel?> getUserStream(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .snapshots()
        .map(
          (snapshot) => snapshot.exists ? UserModel.fromMap(snapshot) : null,
        );
  }

  Future<bool> updateUser(String uid, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _db.collection(_collection).doc(uid).update(updates);
      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  // update user sbg satu object
  Future<bool> updateUserModel(String uid, UserModel user) async {
    try {
      await _db.collection(_collection).doc(uid).update(user.toMap());
      return true;
    } catch (e) {
      print("Error updating user model: $e");
      return false;
    }
  }

  Future<bool> deleteUser(String uid) async {
    try {
      await _db.collection(_collection).doc(uid).delete();
      return true;
    } catch (e) {
      print("Error deleting user: $e");
      return false;
    }
  }
}

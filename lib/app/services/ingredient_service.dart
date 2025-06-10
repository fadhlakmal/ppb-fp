import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/app/models/user_ingredient_model.dart';


class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? getCurrentUserId() {
    return "tGXVkWmrjhhfI65su4jLzohkzT72";
  }

  // --- CREATE ---
  Future<void> addIngredient(Ingredient ingredient) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception("Pengguna tidak login atau ID pengguna tidak ditemukan.");
    }
    try {
      // Membuat objek baru dengan userId dan timestamp yang sudah diisi
      final newIngredient = Ingredient(
        name: ingredient.name,
        quantity: ingredient.quantity,
        unit: ingredient.unit,
        userId: userId, // Pastikan userId terisi
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );
      await _db.collection('ingredients').add(newIngredient.toFirestore());
    } catch (e) {
      print("Error adding ingredient: $e");
      // Pertimbangkan untuk menggunakan sistem logging yang lebih baik di produksi
      rethrow; // Lempar kembali error agar UI bisa menanganinya
    }
  }

  // --- READ ---
  // Mendapatkan stream semua bahan makanan milik pengguna saat ini
  Stream<List<Ingredient>> getIngredientsStream() {
    final userId = getCurrentUserId();
    if (userId == null) {
      // Kembalikan stream kosong jika tidak ada user atau ID pengguna tidak ditemukan
      return Stream.value([]);
    }
    return _db
        .collection('ingredients')
        .where('userId', isEqualTo: userId) // Filter berdasarkan userId
        .orderBy('createdAt', descending: true) // Urutkan berdasarkan waktu pembuatan terbaru
        .snapshots() // Dapatkan stream dari snapshot query
        .map((snapshot) {
      // Konversi setiap DocumentSnapshot menjadi objek Ingredient
      return snapshot.docs
          .map((doc) => Ingredient.fromFirestore(doc, null))
          .toList();
    });
  }

  // --- UPDATE ---
  Future<void> updateIngredient(Ingredient ingredient) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception("Pengguna tidak login atau ID pengguna tidak ditemukan.");
    }
    if (ingredient.id == null) {
      throw Exception("ID bahan makanan tidak boleh null untuk update.");
    }
    try {
      // Membuat objek baru dengan userId dan timestamp updatedAt yang sudah diisi
      final updatedIngredient = Ingredient(
        id: ingredient.id, // id tetap sama
        name: ingredient.name,
        quantity: ingredient.quantity,
        unit: ingredient.unit,
        userId: userId, // Pastikan userId terisi dan sesuai
        createdAt: ingredient.createdAt, // createdAt tidak berubah saat update
        updatedAt: Timestamp.now(), // Perbarui updatedAt
      );
      await _db
          .collection('ingredients')
          .doc(ingredient.id)
          .update(updatedIngredient.toFirestore());
    } catch (e) {
      print("Error updating ingredient: $e");
      rethrow;
    }
  }

  // --- DELETE ---
  Future<void> deleteIngredient(String ingredientId) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception("Pengguna tidak login atau ID pengguna tidak ditemukan.");
    }
    try {
      // Anda mungkin ingin menambahkan validasi tambahan di sini,
      // misalnya memastikan bahwa bahan yang akan dihapus benar-benar milik pengguna saat ini.
      // Namun, karena query `getIngredientsStream` sudah difilter berdasarkan `userId`,
      // kemungkinan pengguna menghapus bahan milik orang lain dari UI sangat kecil
      // jika UI hanya menampilkan bahan milik pengguna tersebut.
      await _db.collection('ingredients').doc(ingredientId).delete();
    } catch (e) {
      print("Error deleting ingredient: $e");
      rethrow;
    }
  }
}
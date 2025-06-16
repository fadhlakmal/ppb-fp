import 'package:flutter/material.dart';
import 'package:myapp/app/models/user_ingredient_model.dart';
import 'package:myapp/app/services/firestore_service.dart';

class AddIngredientScreen extends StatefulWidget {
  const AddIngredientScreen({super.key});

  @override
  State<AddIngredientScreen> createState() => _AddIngredientScreenState();
}

class _AddIngredientScreenState extends State<AddIngredientScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  // Fungsi untuk menampilkan dialog form (untuk menambah atau mengedit)
  void _showIngredientFormDialog(BuildContext context, {Ingredient? ingredient}) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: ingredient?.name ?? '');
    final _quantityController = TextEditingController(
      text: ingredient != null
          ? ingredient.quantity.toStringAsFixed(
          ingredient.quantity.truncateToDouble() == ingredient.quantity ? 0 : 2)
          : '',
    );
    final _unitController = TextEditingController(text: ingredient?.unit ?? '');
    final bool isEditing = ingredient != null;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Ingredient' : 'Add Ingredient'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Ingredient Name',
                      border: OutlineInputBorder(),
                      hintText: 'Contoh: Kecap Asin',
                      prefixIcon: Icon(Icons.restaurant_menu),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama bahan tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                      hintText: 'Contoh: 10 atau 0.5',
                      prefixIcon: Icon(Icons.format_list_numbered),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Jumlah tidak boleh kosong';
                      }
                      try {
                        if (double.parse(value.trim()) <= 0) {
                          return 'Jumlah harus lebih dari 0';
                        }
                      } catch (e) {
                        return 'Format jumlah tidak valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _unitController,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(),
                      hintText: 'Contoh: kg, gram, butir, buah',
                      prefixIcon: Icon(Icons.square_foot_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Unit tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton.icon(
              icon: Icon(isEditing ? Icons.save : Icons.add),
              label: Text(isEditing ? 'Update' : 'Simpan'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Panggil fungsi untuk proses data
                  _addOrUpdateIngredient(
                    context: context,
                    dialogContext: dialogContext,
                    name: _nameController.text,
                    quantity: _quantityController.text,
                    unit: _unitController.text,
                    ingredientToUpdate: ingredient,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Fungsi terpusat untuk menambah atau mengupdate data ke Firestore
  void _addOrUpdateIngredient({
    required BuildContext context,
    required BuildContext dialogContext,
    required String name,
    required String quantity,
    required String unit,
    Ingredient? ingredientToUpdate,
  }) async {
    final userId = _firestoreService.getCurrentUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Pengguna tidak ditemukan. Silakan login kembali.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final newQuantity = double.parse(quantity.trim());

      if (ingredientToUpdate == null) { // Mode Tambah
        final newIngredient = Ingredient(
          name: name.trim(),
          quantity: newQuantity,
          unit: unit.trim(),
          userId: userId,
        );
        await _firestoreService.addIngredient(newIngredient);
        Navigator.of(context).pop(); // Tutup loading
        Navigator.of(dialogContext).pop(); // Tutup dialog form
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bahan berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
      } else { // Mode Update
        final updatedIngredient = Ingredient(
          id: ingredientToUpdate.id,
          name: name.trim(),
          quantity: newQuantity,
          unit: unit.trim(),
          userId: userId,
          createdAt: ingredientToUpdate.createdAt,
        );
        await _firestoreService.updateIngredient(updatedIngredient);
        Navigator.of(context).pop(); // Tutup loading
        Navigator.of(dialogContext).pop(); // Tutup dialog form
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bahan berhasil diupdate'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Tutup loading jika terjadi error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  //--DELET--
  void _deleteIngredient(String ingredientId) async {
    // 1. Tampilkan dialog konfirmasi sebelum menghapus
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus bahan ini?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(false), // Tutup dialog & kembalikan nilai false
            ),
            TextButton(
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true), // Tutup dialog & kembalikan nilai true
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      // Tampilkan indikator loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
        const Center(child: CircularProgressIndicator()),
      );

      try {
        await _firestoreService.deleteIngredient(ingredientId);

        Navigator.of(context).pop(); // Tutup indikator loading

        // Tampilkan notifikasi sukses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bahan berhasil dihapus'),
            backgroundColor: Colors.orange, // Warna oranye untuk aksi hapus
          ),
        );
      } catch (e) {
        Navigator.of(context).pop(); // Tutup indikator loading jika terjadi error

        // Tampilkan notifikasi error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus bahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Bahan Saya'),
      ),
      // --- FLOATING ACTION BUTTON UNTUK MENAMBAH BAHAN ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showIngredientFormDialog(context),
        label: const Text('Tambah Bahan'),
        icon: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- STREAMBUILDER UNTUK MENAMPILKAN DAFTAR BAHAN ---
            StreamBuilder<List<Ingredient>>(
              stream: _firestoreService.getIngredientsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 50.0),
                      child: Text(
                        'Anda belum punya bahan. Yuk, tambahkan sekarang!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  );
                }

                final ingredients = snapshot.data!;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: ingredients.length,
                  itemBuilder: (context, index) {
                    final ingredient = ingredients[index];
                    return Card(
                      // Memberi bentuk rounded corner pada Card
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 4.0,
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- BAGIAN GAMBAR ---
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12.0),
                            ),
                            // Container ini bertindak sebagai bingkai untuk gambar
                            child: Container(
                              height: 140,
                              width: double.infinity,
                              // Latar belakang untuk mengisi ruang kosong di sekitar gambar
                              color: Colors.grey[200],
                              child: Image.network(
                                "https://www.themealdb.com/images/ingredients/${ingredient.name.replaceAll(' ', '%20')}.png",
                                // --- PERUBAHAN UTAMA DI SINI ---
                                fit: BoxFit.contain, // Memastikan seluruh gambar muat tanpa terpotong

                                // Fallback jika gambar gagal dimuat
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200], // Samakan warna latar belakang
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey[600],
                                      size: 40,
                                    ),
                                  );
                                },
                                // Loading indicator saat gambar sedang dimuat
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: Colors.grey[200], // Samakan warna latar belakang
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          // --- BAGIAN TEKS DAN TOMBOL ---
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Kolom untuk Teks (Nama dan Kuantitas)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ingredient.name,
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${ingredient.quantity.toStringAsFixed(ingredient.quantity.truncateToDouble() == ingredient.quantity ? 0 : 2)} ${ingredient.unit}',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Baris untuk Tombol Aksi (Edit dan Hapus)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      tooltip: 'Edit',
                                      onPressed: () => _showIngredientFormDialog(
                                        context,
                                        ingredient: ingredient,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      tooltip: 'Delete',
                                      onPressed: () {
                                        if (ingredient.id != null) {
                                          _deleteIngredient(ingredient.id!);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

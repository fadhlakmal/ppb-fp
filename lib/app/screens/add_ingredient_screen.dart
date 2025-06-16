import 'package:flutter/material.dart';
import 'package:myapp/app/models/user_ingredient_model.dart';
import 'package:myapp/app/services/firestore_service.dart';
import 'package:dropdown_search/dropdown_search.dart';

class AddIngredientScreen extends StatefulWidget {
  const AddIngredientScreen({super.key});

  @override
  State<AddIngredientScreen> createState() => _AddIngredientScreenState();
}

class _AddIngredientScreenState extends State<AddIngredientScreen> {
  // Instance untuk berinteraksi dengan Firestore
  final FirestoreService _firestoreService = FirestoreService();

  // State untuk menyimpan daftar label bahan dari Firestore
  List<String> _ingredientLabels = [];
  bool _isLoadingLabels = true;

  // Ambil data label saat widget pertama kali dibuka
  @override
  void initState() {
    super.initState();
    _fetchIngredientLabels();
  }

  Future<void> _fetchIngredientLabels() async {
    final labels = await _firestoreService.getIngredientLabels();
    if (mounted) {
      setState(() {
        _ingredientLabels = labels;
        _isLoadingLabels = false;
      });
    }
  }

  // --- FUNGSI UNTUK MENAMPILKAN DIALOG FORM ---
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
          title: Text(isEditing ? 'Edit Bahan' : 'Tambah Bahan'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // --- KODE DROPDOWNSEARCH UNTUK VERSI 5.0.6 ---
                  DropdownSearch<String>(
                    // Properti pop-up
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          hintText: "Cari nama bahan...",
                        ),
                      ),
                      menuProps: MenuProps(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      title: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text('Pilih Bahan',
                            style: Theme.of(context).textTheme.titleLarge),
                      ),
                    ),

                    items: _ingredientLabels,
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: 'Nama Bahan',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.restaurant_menu),
                      ),
                    ),

                    // onChanged, selectedItem, dan validator
                    onChanged: (String? newValue) {
                      _nameController.text = newValue ?? '';
                    },
                    selectedItem: ingredient?.name,
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Nama bahan harus dipilih' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Jumlah',
                      border: OutlineInputBorder(),
                      hintText: 'Contoh: 10 atau 0.5',
                      prefixIcon: Icon(Icons.format_list_numbered),
                    ),
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
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
                      return null; },
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
                      return null; },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton.icon(
              icon: Icon(isEditing ? Icons.save : Icons.add),
              label: Text(isEditing ? 'Update' : 'Simpan'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
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

  // --- FUNGSI UNTUK MENAMBAH ATAU UPDATE DATA KE FIRESTORE ---
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

      if (ingredientToUpdate == null) {
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
      } else {
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

  // --- FUNGSI UNTUK MENGHAPUS BAHAN ---
  void _deleteIngredient(String ingredientId) async {
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
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child:
              const Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
        const Center(child: CircularProgressIndicator()),
      );

      try {
        await _firestoreService.deleteIngredient(ingredientId);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bahan berhasil dihapus'),
            backgroundColor: Colors.orange,
          ),
        );
      } catch (e) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus bahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- UI UTAMA DARI LAYAR ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Bahan Saya'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:
        _isLoadingLabels ? null : () => _showIngredientFormDialog(context),
        backgroundColor: _isLoadingLabels
            ? const Color(0xFFEADDFF) : const Color(0xFFEADDFF),
        foregroundColor: const Color(0xFF4F378B),
        label: Text(_isLoadingLabels ? 'Memuat...' : 'Tambah Bahan'),
        icon: _isLoadingLabels
            ? Container(
          width: 24,
          height: 24,
          padding: const EdgeInsets.all(2.0),
          child:
          const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
        )
            : const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Ingredient>>(
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
                padding: EdgeInsets.symmetric(vertical: 50.0, horizontal: 20.0),
                child: Text(
                  'Anda belum punya bahan. Yuk, tambahkan sekarang dengan menekan tombol di kanan bawah!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          }

          final ingredients = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: ingredients.length,
            itemBuilder: (context, index) {
              final ingredient = ingredients[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 4.0,
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bagian Gambar
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12.0),
                      ),
                      child: Container(
                        height: 140,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: Image.network(
                          "https://www.themealdb.com/images/ingredients/${ingredient.name.replaceAll(' ', '%20')}.png",
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey[600],
                                size: 40,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                                child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                        null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                        : null));
                          },
                        ),
                      ),
                    ),
                    // Bagian Teks dan Tombol
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ingredient.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${ingredient.quantity.toStringAsFixed(ingredient.quantity.truncateToDouble() == ingredient.quantity ? 0 : 2)} ${ingredient.unit}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                const Icon(Icons.edit, color: Colors.blue),
                                tooltip: 'Edit',
                                onPressed: () => _showIngredientFormDialog(
                                  context,
                                  ingredient: ingredient,
                                ),
                              ),
                              IconButton(
                                icon:
                                const Icon(Icons.delete, color: Colors.red),
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
    );
  }
}
// lib/Add_new.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory/database/database_helper.dart';
import 'package:inventory/models/product.dart';

class AddNew extends StatefulWidget {
  final Product? product;
  const AddNew({super.key, this.product});

  @override
  State<AddNew> createState() => _AddNewState();
}

class _AddNewState extends State<AddNew> {
  final _db = DatabaseHelper();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Edit
    if (widget.product != null) {
      final p = widget.product!;
      _nameController.text = p.name;
      _categoryController.text = p.category;
      _quantityController.text = p.quantity.toString();
      _priceController.text = p.price.toStringAsFixed(0);
      _descriptionController.text = p.description;
      if (p.imagePath != null && p.imagePath!.isNotEmpty) {
        final f = File(p.imagePath!);
        if (f.existsSync()) _imageFile = f;
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _showImageOptions() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(ctx, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(ctx, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(ctx, null),
            ),
          ],
        ),
      ),
    );

    if (choice == 'gallery') {
      await _pickImageFromGallery();
    } else if (choice == 'camera') {
      await _pickImageFromCamera();
    }
  }

  Future<void> _saveItem() async {
    final name = _nameController.text.trim();
    final category = _categoryController.text.trim();
    final qty = int.tryParse(_quantityController.text.trim()) ?? 0;
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final desc = _descriptionController.text.trim();

    if (name.isEmpty || category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill name and category')),
      );
      return;
    }

    final product = Product(
      id: widget.product?.id,
      name: name,
      category: category,
      quantity: qty,
      price: price,
      description: desc,
      imagePath: _imageFile?.path ?? widget.product?.imagePath ?? '',
    );

    if (widget.product == null) {
      await _db.insertProduct(product);
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Item added')));
    } else {
      await _db.updateProduct(product);
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Item updated')));
    }

    // return true so caller can refresh
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      width: double.infinity,
      height: maxLines == 1 ? 45 : null,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(.3),
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(border: InputBorder.none, hintText: hint),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue,
        title: Text(
          isEditing ? 'Edit Item' : 'Add an Item',
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(_nameController, 'Item Name'),
                const SizedBox(height: 16),
                _buildTextField(_categoryController, 'Item Category'),
                const SizedBox(height: 16),
                _buildTextField(_quantityController, 'Item Quantity'),
                const SizedBox(height: 16),
                _buildTextField(_priceController, 'Item Price (Naira)'),
                const SizedBox(height: 16),
                _buildTextField(
                  _descriptionController,
                  'Item Description',
                  maxLines: 4,
                ),
                const SizedBox(height: 16),

                // Image upload box
                GestureDetector(
                  onTap: _showImageOptions,
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    width: double.infinity,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(.3),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: _imageFile == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.upload, size: 50),
                              const SizedBox(height: 6),
                              Text(
                                (widget.product != null &&
                                        widget.product!.imagePath != null &&
                                        widget.product!.imagePath!.isNotEmpty)
                                    ? 'Tap to change item image'
                                    : 'Upload an item Image',
                              ),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.file(
                              _imageFile!,
                              width: double.infinity,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _saveItem,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    width: double.infinity,
                    height: 45,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: Colors.grey.withOpacity(.3)),
                      color: Colors.blue,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 5),
                        Text(
                          isEditing ? 'Update Item' : 'Add Item',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

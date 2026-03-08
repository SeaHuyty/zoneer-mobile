import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zoneer_mobile/core/utils/app_colors.dart';
import 'package:zoneer_mobile/features/property/models/property_model.dart';
import 'package:zoneer_mobile/features/property/viewmodels/upload_property_viewmodel.dart';

class UploadPropertyScreen extends ConsumerStatefulWidget {
  /// If non-null, we are editing an existing property.
  final PropertyModel? existingProperty;

  const UploadPropertyScreen({super.key, this.existingProperty});

  @override
  ConsumerState<UploadPropertyScreen> createState() =>
      _UploadPropertyScreenState();
}

class _UploadPropertyScreenState extends ConsumerState<UploadPropertyScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _addressController;
  late final TextEditingController _priceController;
  late final TextEditingController _bedroomController;
  late final TextEditingController _bathroomController;
  late final TextEditingController _areaController;
  late final TextEditingController _locationUrlController;
  late final TextEditingController _descriptionController;

  Uint8List? _thumbnailBytes;
  String? _thumbnailExt;
  String? _existingThumbnailUrl;

  bool get _isEditing => widget.existingProperty != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existingProperty;
    _addressController = TextEditingController(text: p?.address ?? '');
    _priceController =
        TextEditingController(text: p != null ? p.price.toString() : '');
    _bedroomController =
        TextEditingController(text: p != null ? p.bedroom.toString() : '');
    _bathroomController =
        TextEditingController(text: p != null ? p.bathroom.toString() : '');
    _areaController =
        TextEditingController(text: p != null ? p.squareArea.toString() : '');
    _locationUrlController = TextEditingController(text: p?.locationUrl ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _existingThumbnailUrl = p?.thumbnail;
  }

  @override
  void dispose() {
    _addressController.dispose();
    _priceController.dispose();
    _bedroomController.dispose();
    _bathroomController.dispose();
    _areaController.dispose();
    _locationUrlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickThumbnail() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 1200,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _thumbnailBytes = bytes;
        _thumbnailExt = image.path.split('.').last;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_thumbnailBytes == null && _existingThumbnailUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a thumbnail image.')),
      );
      return;
    }

    try {
      await ref.read(uploadPropertyViewModelProvider.notifier).submit(
            thumbnailBytes: _thumbnailBytes,
            thumbnailExt: _thumbnailExt,
            existingThumbnailUrl: _existingThumbnailUrl,
            existingProperty: widget.existingProperty,
            price: double.parse(_priceController.text.trim()),
            bedroom: int.parse(_bedroomController.text.trim()),
            bathroom: int.parse(_bathroomController.text.trim()),
            squareArea: double.parse(_areaController.text.trim()),
            address: _addressController.text.trim(),
            locationUrl: _locationUrlController.text.trim(),
            description: _descriptionController.text.trim(),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Property updated successfully.'
                  : 'Property uploaded successfully.',
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(uploadPropertyViewModelProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Edit Property' : 'Upload Property',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Thumbnail picker
              GestureDetector(
                onTap: _pickThumbnail,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _thumbnailBytes != null
                      ? Image.memory(_thumbnailBytes!, fit: BoxFit.cover)
                      : _existingThumbnailUrl != null
                          ? Image.network(
                              _existingThumbnailUrl!,
                              fit: BoxFit.cover,
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 48,
                                  color: AppColors.primary,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Tap to select thumbnail',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                ),
              ),
              if (_thumbnailBytes != null || _existingThumbnailUrl != null)
                TextButton.icon(
                  onPressed: _pickThumbnail,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Change thumbnail'),
                ),

              const SizedBox(height: 16),

              _buildCard(
                title: 'Location',
                children: [
                  _buildField(
                    controller: _addressController,
                    label: 'Address',
                    hint: 'e.g. 12 Street, Phnom Penh',
                    icon: Icons.location_on_outlined,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    controller: _locationUrlController,
                    label: 'Google Maps URL',
                    hint: 'https://maps.google.com/...',
                    icon: Icons.map_outlined,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              _buildCard(
                title: 'Details',
                children: [
                  _buildField(
                    controller: _priceController,
                    label: 'Price per month (\$)',
                    hint: '300',
                    icon: Icons.attach_money,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}$'),
                      ),
                    ],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (double.tryParse(v.trim()) == null) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _buildField(
                          controller: _bedroomController,
                          label: 'Bedrooms',
                          hint: '2',
                          icon: Icons.bed_outlined,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            if (int.tryParse(v.trim()) == null) {
                              return 'Integer only';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildField(
                          controller: _bathroomController,
                          label: 'Bathrooms',
                          hint: '1',
                          icon: Icons.bathtub_outlined,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            if (int.tryParse(v.trim()) == null) {
                              return 'Integer only';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    controller: _areaController,
                    label: 'Square Area (m²)',
                    hint: '50',
                    icon: Icons.square_foot_outlined,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (double.tryParse(v.trim()) == null) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(height: 14),

              _buildCard(
                title: 'Description',
                children: [
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Describe your property...',
                      hintStyle: const TextStyle(
                        color: Colors.black38,
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: isSaving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _isEditing ? 'Save Changes' : 'Upload Property',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
        prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
    );
  }
}

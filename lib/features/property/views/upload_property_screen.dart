import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zoneer_mobile/core/utils/app_config.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:zoneer_mobile/core/utils/app_colors.dart';
import 'package:zoneer_mobile/features/property/models/property_model.dart';
import 'package:zoneer_mobile/features/property/viewmodels/upload_property_viewmodel.dart';
import 'package:zoneer_mobile/features/property/views/location_picker_screen.dart';

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
  late final TextEditingController _descriptionController;

  LatLng? _selectedLocation;
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
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _existingThumbnailUrl = p?.thumbnail;
    if (p?.latitude != null && p?.longitude != null) {
      _selectedLocation = LatLng(p!.latitude!, p.longitude!);
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _priceController.dispose();
    _bedroomController.dispose();
    _bathroomController.dispose();
    _areaController.dispose();
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

  void _deleteThumbnail() {
    setState(() {
      _thumbnailBytes = null;
      _thumbnailExt = null;
      _existingThumbnailUrl = null;
    });
  }

  Future<void> _openLocationPicker() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(initialLocation: _selectedLocation),
      ),
    );
    if (result != null) {
      setState(() => _selectedLocation = result);
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

    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a location on the map.')),
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
            latitude: _selectedLocation!.latitude,
            longitude: _selectedLocation!.longitude,
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
                  child: Stack(
                    children: [
                      // Image display
                      if (_thumbnailBytes != null)
                        SizedBox.expand(
                          child: Image.memory(_thumbnailBytes!, fit: BoxFit.cover),
                        )
                      else if (_existingThumbnailUrl != null)
                        SizedBox.expand(
                          child: Image.network(
                            _existingThumbnailUrl!,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
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
                      
                      // Delete button (only show when image exists)
                      if (_thumbnailBytes != null || _existingThumbnailUrl != null)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: _deleteThumbnail,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.9),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
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
                  // Map location picker
                  if (_selectedLocation != null) ...
                    [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          height: 150,
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: _selectedLocation!,
                              initialZoom: 15,
                              interactionOptions: const InteractionOptions(
                                flags: InteractiveFlag.none,
                              ),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: AppConfig.mapboxTileUrl,
                                userAgentPackageName: 'com.zoneer.mobile',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: _selectedLocation!,
                                    width: 32,
                                    height: 32,
                                    child: const Icon(
                                      Icons.location_pin,
                                      color: AppColors.primary,
                                      size: 32,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppColors.primary,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${_selectedLocation!.latitude.toStringAsFixed(5)}, '
                              '${_selectedLocation!.longitude.toStringAsFixed(5)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _openLocationPicker,
                            icon: const Icon(Icons.edit_outlined, size: 14),
                            label: const Text('Change'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ),
                    ]
                  else
                    GestureDetector(
                      onTap: _openLocationPicker,
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_location_alt_outlined,
                              color: AppColors.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Tap to pick location on map',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
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

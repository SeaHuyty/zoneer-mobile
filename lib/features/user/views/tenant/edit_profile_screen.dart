import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zoneer_mobile/core/utils/app_colors.dart';
import 'package:zoneer_mobile/features/user/models/user_model.dart';
import 'package:zoneer_mobile/features/user/viewmodels/user_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  UserModel? user;
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final authUser = Supabase.instance.client.auth.currentUser!;
    user = ref.read(userByIdProvider(authUser.id)).value;

    _nameController = TextEditingController(text: user?.fullname ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;

      String? imageUrl;
      if (_selectedImage != null) {
        await _deleteOldProfileImages(userId);
        imageUrl = await _uploadProfileImage(userId);
      }

      await Supabase.instance.client
          .from('users')
          .update({
            'fullname': _nameController.text.trim(),
            'phone_number': _phoneController.text.trim(),
            if (imageUrl != null) 'image_profile_url': imageUrl,
          })
          .eq('id', userId);

      // Clear Flutter's image cache so the new photo shows immediately
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      // ignore: unused_result
      await ref.refresh(userByIdProvider(userId).future);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 1024,
      maxWidth: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImage = image;
        _selectedImageBytes = bytes;
      });
    }
  }

  Future<void> _deleteOldProfileImages(String userId) async {
    try {
      final files = await Supabase.instance.client.storage
          .from('profiles')
          .list(path: userId);
      if (files.isNotEmpty) {
        final paths = files.map((f) => '$userId/${f.name}').toList();
        await Supabase.instance.client.storage
            .from('profiles')
            .remove(paths);
      }
    } catch (_) {
      // No existing files — nothing to delete
    }
  }

  Future<String?> _uploadProfileImage(String userId) async {
    if (_selectedImage == null) return null;

    final bytes = await _selectedImage!.readAsBytes();
    final mimeType = _selectedImage!.mimeType ?? 'image/jpeg';
    final extension = mimeType.split('/').last;
    final fileName = '$userId/profile.$extension';

    await Supabase.instance.client.storage
        .from('profiles')
        .uploadBinary(
          fileName,
          bytes,
          fileOptions: FileOptions(upsert: true, contentType: mimeType),
        );

    final publicUrl = Supabase.instance.client.storage
        .from('profiles')
        .getPublicUrl(fileName);
    return '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),

              // Avatar picker
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 58,
                        backgroundColor: AppColors.surface,
                        backgroundImage: _selectedImageBytes != null
                            ? MemoryImage(_selectedImageBytes!)
                            : (user?.profileUrl != null
                                ? NetworkImage(user!.profileUrl!)
                                : null) as ImageProvider?,
                        child: (user?.profileUrl == null && _selectedImageBytes == null)
                            ? Icon(Icons.person, size: 52, color: AppColors.grey)
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              Text(
                "Tap to change photo",
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 32),

              // Fields card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "Full Name",
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                        prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? "Name is required" : null,
                    ),
                    Divider(
                      height: 1,
                      color: AppColors.grey.withValues(alpha: 0.2),
                    ),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Phone Number",
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                        prefixIcon: Icon(Icons.phone_outlined, color: AppColors.primary),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          "Save Changes",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:io';

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
  File? _selectedImage;

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

      ref.invalidate(userByIdProvider(userId));

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
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<String?> _uploadProfileImage(String userId) async {
    if (_selectedImage == null) return null;

    final extension = _selectedImage!.path.split('.').last;
    final fileName = '$userId/profile.$extension';

    await Supabase.instance.client.storage
        .from('profiles')
        .upload(
          fileName,
          _selectedImage!,
          fileOptions: const FileOptions(upsert: true),
        );

    return Supabase.instance.client.storage
        .from('profiles')
        .getPublicUrl(fileName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : (user?.profileUrl != null
                                    ? NetworkImage(user!.profileUrl!)
                                    : null)
                                as ImageProvider?,
                      child:
                          (user?.profileUrl == null && _selectedImage == null)
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Name is required" : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Phone Number"),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Save Changes"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

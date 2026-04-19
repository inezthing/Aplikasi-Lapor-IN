// lib/widgets/image_picker_widget.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/constants.dart';

class ImagePickerWidget extends StatelessWidget {
  final File? selectedImage;
  final Function(File) onImageSelected;
  final double height;
  final String hint;

  const ImagePickerWidget({
    required this.onImageSelected,
    this.selectedImage,
    this.height = 180,
    this.hint = 'Tambah Foto',
    Key? key,
  }) : super(key: key);

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1280,
    );
    if (picked != null) {
      onImageSelected(File(picked.path));
    }
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pilih Sumber Foto',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBg,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      color: AppColors.primary, size: 22),
                ),
                title: const Text('Kamera',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Ambil foto langsung',
                    style: TextStyle(fontSize: 12)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBg,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(Icons.photo_library_rounded,
                      color: AppColors.primary, size: 22),
                ),
                title: const Text('Galeri',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Pilih dari galeri foto',
                    style: TextStyle(fontSize: 12)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(context, ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showOptions(context),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primaryBg,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: selectedImage != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Image.file(selectedImage!, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _showOptions(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.edit_rounded,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_photo_alternate_outlined,
                      color: AppColors.primary, size: 36),
                  const SizedBox(height: 8),
                  Text(
                    hint,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Kamera atau Galeri',
                    style:
                        TextStyle(color: AppColors.textHint, fontSize: 12),
                  ),
                ],
              ),
      ),
    );
  }
}

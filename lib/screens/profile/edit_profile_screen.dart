import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  String? _photoPath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final driver = ref.read(authProvider).driver;
    _nameController = TextEditingController(text: driver?.name ?? '');
    _emailController = TextEditingController(text: driver?.email ?? '');
    _photoPath = driver?.photoPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final scheme = Theme.of(context).colorScheme;
    // Show source picker sheet
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Choose photo',
              style: AppTypography.heading(color: scheme.onSurface),
            ),
            const SizedBox(height: 16),
            _SourceTile(
              icon: Icons.camera_alt_outlined,
              label: 'Take a photo',
              scheme: scheme,
              onTap: () async {
                Navigator.pop(ctx);
                await _pickFrom(ImageSource.camera);
              },
            ),
            const SizedBox(height: 8),
            _SourceTile(
              icon: Icons.photo_library_outlined,
              label: 'Choose from gallery',
              scheme: scheme,
              onTap: () async {
                Navigator.pop(ctx);
                await _pickFrom(ImageSource.gallery);
              },
            ),
            if (_photoPath != null) ...[
              const SizedBox(height: 8),
              _SourceTile(
                icon: Icons.delete_outline_rounded,
                label: 'Remove photo',
                scheme: scheme,
                isDestructive: true,
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _photoPath = null);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickFrom(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (picked != null) {
        setState(() => _photoPath = picked.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(
            content: Text('Could not pick photo: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _isSaving = true);

    final driver = ref.read(authProvider).driver;
    if (driver == null) return;

    final updated = driver.copyWith(
      name: _nameController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      photoPath: _photoPath,
    );

    await ref.read(authProvider.notifier).updateDriver(updated);

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: const Text('Profile updated successfully'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final driver = ref.watch(authProvider).driver;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit profile',
          style: AppTypography.heading(color: scheme.onSurface),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Profile photo ──
              Center(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: _pickPhoto,
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: scheme.primary.withValues(alpha: 0.12),
                          border: Border.all(
                            color: scheme.primary.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: _photoPath != null
                            ? ClipOval(
                                child: Image.file(
                                  File(_photoPath!),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Center(
                                child: Text(
                                  driver != null && driver.name.isNotEmpty
                                      ? driver.name[0].toUpperCase()
                                      : 'D',
                                  style: AppTypography.display(
                                    color: scheme.primary,
                                    size: 32,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    // Camera badge
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickPhoto,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF0B0E14)
                                  : Colors.white,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            size: 15,
                            color: isDark ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: _pickPhoto,
                  child: Text(
                    'Change photo',
                    style: AppTypography.caption(
                      color: scheme.primary,
                      size: 13,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Read-only info ──
              _SectionLabel('Account info', scheme: scheme),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _ReadOnlyTile(
                      icon: Icons.phone_outlined,
                      label: 'Phone number',
                      value: driver?.phoneNumber ?? '—',
                      scheme: scheme,
                    ),
                    _ReadOnlyTile(
                      icon: Icons.credit_card_outlined,
                      label: 'License number',
                      value: driver?.licenseNumber ?? '—',
                      scheme: scheme,
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  'Phone and license number can only be changed by your school admin.',
                  style: AppTypography.caption(
                    color: scheme.onSurface.withValues(alpha: 0.4),
                    size: 11,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Editable fields ──
              _SectionLabel('Edit details', scheme: scheme),
              const SizedBox(height: 10),

              // Full name
              Text(
                'Full name',
                style: AppTypography.caption(
                  color: scheme.onSurface.withValues(alpha: 0.7),
                  size: 12,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                style: AppTypography.body(color: scheme.onSurface),
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'e.g. Ram Bahadur Thapa',
                  prefixIcon: Icon(
                    Icons.person_outline,
                    size: 18,
                    color: scheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Name cannot be empty';
                  }
                  if (v.trim().length < 3) {
                    return 'Name must be at least 3 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Email
              Text(
                'Email address',
                style: AppTypography.caption(
                  color: scheme.onSurface.withValues(alpha: 0.7),
                  size: 12,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _emailController,
                style: AppTypography.body(color: scheme.onSurface),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'e.g. ram@example.com (optional)',
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    size: 18,
                    color: scheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                validator: (v) {
                  if (v != null && v.trim().isNotEmpty) {
                    if (!v.contains('@') || !v.contains('.')) {
                      return 'Enter a valid email address';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 36),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveChanges,
                  child: _isSaving
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: isDark ? Colors.black : Colors.white,
                          ),
                        )
                      : Text(
                          'Save changes',
                          style: AppTypography.heading(
                            color: isDark ? Colors.black : Colors.white,
                            size: 15,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final ColorScheme scheme;
  const _SectionLabel(this.text, {required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.caption(
        color: scheme.onSurface.withValues(alpha: 0.5),
        size: 12,
      ),
    );
  }
}

class _ReadOnlyTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorScheme scheme;
  final bool isLast;

  const _ReadOnlyTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.scheme,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: scheme.outline.withValues(alpha: 0.1),
                ),
              ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: scheme.onSurface.withValues(alpha: 0.4)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.caption(
                    color: scheme.onSurface.withValues(alpha: 0.4),
                    size: 11,
                  ),
                ),
                Text(value, style: AppTypography.body(color: scheme.onSurface)),
              ],
            ),
          ),
          Icon(
            Icons.lock_outline,
            size: 14,
            color: scheme.onSurface.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme scheme;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SourceTile({
    required this.icon,
    required this.label,
    required this.scheme,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? scheme.error : scheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: scheme.onSurface.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color.withValues(alpha: 0.7)),
            const SizedBox(width: 14),
            Text(label, style: AppTypography.body(color: color)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_typography.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 800));
    // Real: PUT /drivers/change-password with currentPassword + newPassword
    setState(() => _isSaving = false);

    if (!mounted) return;

    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: const Text('Password changed successfully'),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Change password',
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
              // Info banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: scheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your password must be at least 8 characters and include a number.',
                        style: AppTypography.caption(
                          color: scheme.primary,
                          size: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Current password
              Text(
                'Current password',
                style: AppTypography.caption(
                  color: scheme.onSurface.withValues(alpha: 0.7),
                  size: 12,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _currentController,
                obscureText: _obscureCurrent,
                style: AppTypography.body(color: scheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Enter current password',
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    size: 18,
                    color: scheme.onSurface.withValues(alpha: 0.4),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCurrent
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 18,
                      color: scheme.onSurface.withValues(alpha: 0.4),
                    ),
                    onPressed: () =>
                        setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Enter your current password';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // New password
              Text(
                'New password',
                style: AppTypography.caption(
                  color: scheme.onSurface.withValues(alpha: 0.7),
                  size: 12,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _newController,
                obscureText: _obscureNew,
                style: AppTypography.body(color: scheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Enter new password',
                  prefixIcon: Icon(
                    Icons.lock_reset_outlined,
                    size: 18,
                    color: scheme.onSurface.withValues(alpha: 0.4),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 18,
                      color: scheme.onSurface.withValues(alpha: 0.4),
                    ),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter a new password';
                  if (v.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  if (!v.contains(RegExp(r'[0-9]'))) {
                    return 'Include at least one number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Confirm new password
              Text(
                'Confirm new password',
                style: AppTypography.caption(
                  color: scheme.onSurface.withValues(alpha: 0.7),
                  size: 12,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                style: AppTypography.body(color: scheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Re-enter new password',
                  prefixIcon: Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: scheme.onSurface.withValues(alpha: 0.4),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 18,
                      color: scheme.onSurface.withValues(alpha: 0.4),
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (v != _newController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
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
                          'Update password',
                          style: AppTypography.heading(
                            color: isDark ? Colors.black : Colors.white,
                            size: 15,
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

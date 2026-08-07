import 'package:driver_app_saferide/core/theme/app_typography.dart';
import 'package:driver_app_saferide/core/theme/theme_provider.dart';
import 'package:driver_app_saferide/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _showOtpStep = false;
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    for (final c in _otpControllers) c.dispose();
    for (final f in _otpFocusNodes) f.dispose();
    super.dispose();
  }
// Replace _onLogin with a two-step flow:
  void _onRequestOtp() async {
    FocusScope.of(context).unfocus();
    if (_phoneController.text.trim().length < 10) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _isLoading = false;
      _showOtpStep = true; // advance to OTP step
    });
  }

  void _onVerifyOtp() async {
    FocusScope.of(context).unfocus();
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length < 6) return;

    setState(() => _isLoading = true);

    await ref
        .read(authProvider.notifier)
        .login(phoneNumber: _phoneController.text.trim(), password: otp);

    if (!mounted) return;
    setState(() => _isLoading = false);

    final authState = ref.read(authProvider);
    if (authState.errorMessage != null) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text(authState.errorMessage!),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
  // Future<void> _onLogin() async {
  //   FocusScope.of(context).unfocus();
  //   if (!_formKey.currentState!.validate()) return;

  //   setState(() => _isLoading = true);
  //   await ref
  //       .read(authProvider.notifier)
  //       .login(
  //         phoneNumber: _phoneController.text.trim(),
  //         password: _passwordController.text.trim(),
  //       );

  //   if (!mounted) return;
  //   setState(() => _isLoading = false);

  //   final scheme = Theme.of(context).colorScheme;
  //   final authState = ref.read(authProvider);
  //   if (authState.errorMessage != null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(authState.errorMessage!),
  //         backgroundColor: scheme.error,
  //         behavior: SnackBarBehavior.floating,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //       ),
  //     );
  //   } else {
  //     if (!mounted) return;
  //     context.go('/home');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Inside Form widget, replace the fields section with:
if (!_showOtpStep) ...[
  // ── Step 1: Phone number entry ──
  Text(
    'STEP 1 OF 2',
    style: AppTypography.mono(
      color: scheme.onSurface.withValues(alpha: 0.3),
      size: 10,
    ),
  ),
  const SizedBox(height: 16),
  Text(
    'Phone number',
    style: AppTypography.caption(
      color: scheme.onSurface.withValues(alpha: 0.7),
      size: 12,
    ),
  ),
  const SizedBox(height: 6),
  TextFormField(
    controller: _phoneController,
    keyboardType: TextInputType.phone,
    style: AppTypography.body(color: scheme.onSurface),
    decoration: InputDecoration(
      hintText: '98XXXXXXXX',
      prefixIcon: Icon(
        Icons.phone_outlined,
        size: 18,
        color: scheme.onSurface.withValues(alpha: 0.4),
      ),
    ),
    validator: (v) {
      if (v == null || v.trim().isEmpty) return 'Enter your phone number';
      if (v.trim().length < 10) return 'Enter a valid 10-digit number';
      return null;
    },
  ),
  const SizedBox(height: 32),
  SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: _isLoading ? null : _onRequestOtp,
      child: _isLoading
          ? SizedBox(
              height: 20, width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: isDark ? Colors.black : Colors.white,
              ),
            )
          : Text(
              'Send verification code',
              style: AppTypography.heading(
                color: isDark ? Colors.black : Colors.white,
                size: 15,
              ),
            ),
    ),
  ),
] else ...[
  // ── Step 2: OTP entry ──
  // Back button
  GestureDetector(
    onTap: () => setState(() => _showOtpStep = false),
    child: Row(
      children: [
        Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 14,
          color: scheme.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 6),
        Text(
          'Change number',
          style: AppTypography.caption(
            color: scheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    ),
  ),
  const SizedBox(height: 20),
  Text(
    'STEP 2 OF 2',
    style: AppTypography.mono(
      color: scheme.onSurface.withValues(alpha: 0.3),
      size: 10,
    ),
  ),
  const SizedBox(height: 8),
  Text(
    'Enter the 6-digit code sent to ${_phoneController.text.trim()}',
    style: AppTypography.caption(
      color: scheme.onSurface.withValues(alpha: 0.5),
      size: 12,
    ),
  ),
  const SizedBox(height: 6),
  Text(
    '(Demo: enter any 6 digits)',
    style: AppTypography.mono(
      color: scheme.primary.withValues(alpha: 0.6),
      size: 10,
    ),
  ),
  const SizedBox(height: 24),

  // 6 OTP boxes
  Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: List.generate(6, (i) {
      return SizedBox(
        width: 44,
        height: 52,
        child: TextFormField(
          controller: _otpControllers[i],
          focusNode: _otpFocusNodes[i],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: AppTypography.display(
            color: scheme.onSurface,
            size: 20,
          ),
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: scheme.outline.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: scheme.primary,
                width: 1.5,
              ),
            ),
            filled: true,
            fillColor: scheme.surface,
          ),
          onChanged: (val) {
            if (val.isNotEmpty && i < 5) {
              // Auto-advance to next box
              _otpFocusNodes[i + 1].requestFocus();
            }
            if (val.isEmpty && i > 0) {
              // Auto-back to previous box on delete
              _otpFocusNodes[i - 1].requestFocus();
            }
          },
        ),
      );
    }),
  ),

  const SizedBox(height: 32),
  SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: _isLoading ? null : _onVerifyOtp,
      child: _isLoading
          ? SizedBox(
              height: 20, width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: isDark ? Colors.black : Colors.white,
              ),
            )
          : Text(
              'Verify & sign in',
              style: AppTypography.heading(
                color: isDark ? Colors.black : Colors.white,
                size: 15,
              ),
            ),
    ),
  ),

  const SizedBox(height: 16),
  Center(
    child: TextButton(
      onPressed: () {
        // Resend — just shows the same mock flow
        setState(() {});
      },
      child: Text(
        'Resend code',
        style: AppTypography.caption(
          color: scheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
    ),
  ),
],
                // SizedBox(height: 52),
                // Container(
                //   height: 56,
                //   width: 56,
                //   decoration: BoxDecoration(
                //     color: scheme.primary.withValues(alpha: 0.15),
                //     borderRadius: BorderRadius.circular(16),
                //     border: Border.all(
                //       color: scheme.primary.withValues(alpha: 0.3),
                //       width: 1,
                //     ),
                //   ),
                //   child: Icon(Icons.directions_bus_filled_outlined, size: 28),
                // ),
                // SizedBox(height: 28),
                // Text(
                //   'SAFERIDE NEPAL',
                //   style: AppTypography.mono(color: scheme.primary, size: 14),
                // ),
                // SizedBox(height: 6),
                // Text(
                //   'Driver login',
                //   style: AppTypography.display(
                //     color: scheme.onSurface,
                //     size: 30,
                //   ),
                // ),
                // SizedBox(height: 6),
                // Text(
                //   'Sign with your school-issued credentials',
                //   style: AppTypography.caption(
                //     color: scheme.onSurface.withValues(alpha: 0.5),
                //     size: 13,
                //   ),
                // ),
                // SizedBox(height: 40),
                // Text(
                //   'Phone number',
                //   style: AppTypography.caption(
                //     color: scheme.onSurface.withValues(alpha: 0.7),
                //     size: 12,
                //   ),
                // ),
                // const SizedBox(height: 6),
                // SizedBox(height: 7),
                // TextFormField(
                //   controller: _phoneController,
                //   keyboardType: TextInputType.phone,
                //   style: AppTypography.body(
                //     color: scheme.onSurface.withValues(alpha: 0.4),
                //   ),
                //   validator: (value) {
                //     if (value == null || value.trim().isEmpty) {
                //       return 'Enter your phone number';
                //     }
                //     if (value.trim().length < 10) {
                //       return 'Please Enter valid 10-digit number';
                //     }
                //     return null;
                //   },
                //   decoration: InputDecoration(
                //     hintText: '98XXXXXXXX',
                //     prefixIcon: Icon(
                //       Icons.phone_outlined,
                //       size: 18,
                //       color: Colors.amber,
                //     ),
                //   ),
                // ),
                // SizedBox(height: 16),
                // Text(
                //   'Password',
                //   style: AppTypography.caption(
                //     color: scheme.onSurface.withValues(alpha: 0.7),
                //     size: 12,
                //   ),
                // ),
                // SizedBox(height: 8),
                // TextFormField(
                //   controller: _passwordController,
                //   obscureText: _obscurePassword,
                //   style: AppTypography.caption(
                //     color: scheme.onSurface.withValues(alpha: 0.4),
                //   ),
                //   decoration: InputDecoration(
                //     hintText: 'password',
                //     prefixIcon: Icon(
                //       Icons.lock_outline,
                //       size: 18,
                //       color: scheme.onSurface.withValues(alpha: 0.4),
                //     ),
                //     suffixIcon: IconButton(
                //       onPressed: () =>
                //           setState(() => _obscurePassword = !_obscurePassword),
                //       icon: Icon(
                //         _obscurePassword
                //             ? Icons.visibility_outlined
                //             : Icons.visibility_off_outlined,
                //         size: 18,
                //         color: scheme.onSurface.withValues(alpha: 0.4),
                //       ),
                //     ),
                //   ),
                //   validator: (value) {
                //     if (value == null || value.trim().isEmpty) {
                //       return 'Please enter your password';
                //     }
                //     if (value.trim().length < 6) {
                //       return 'At least 6 characters ';
                //     }
                //     return null;
                //   },
                // ),
                // SizedBox(height: 32),
                // SizedBox(
                //   width: double.infinity,
                //   child: ElevatedButton(
                //     onPressed: _isLoading ? null : _onLogin,
                //     child: _isLoading
                //         ? SizedBox(
                //             height: 20,
                //             width: 20,
                //             child: CircularProgressIndicator(
                //               strokeWidth: 2.5,
                //               color: isDark ? Colors.black : Colors.white,
                //             ),
                //           )
                //         : Text(
                //             'Sign in',
                //             style: AppTypography.heading(
                //               color: isDark ? Colors.black : Colors.white,
                //               size: 15,
                //             ),
                //           ),
                //   ),
                // ),
                // SizedBox(height: 24),
                // Center(
                //   child: TextButton.icon(
                //     onPressed: () {
                //       ref
                //           .read(themeProvider.notifier)
                //           .setTheme(isDark ? ThemeMode.light : ThemeMode.dark);
                //     },
                //     label: Text(
                //       isDark ? 'Switch to light mode' : 'Switch to dark mode',
                //       style: AppTypography.caption(
                //         color: scheme.onSurface.withValues(alpha: 0.5),
                //       ),
                //     ),
                //     icon: Icon(
                //       isDark
                //           ? Icons.light_mode_outlined
                //           : Icons.dark_mode_outlined,
                //       size: 16,
                //       color: scheme.onSurface.withValues(alpha: 0.5),
                //     ),
                //   ),
                // ),
                // SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

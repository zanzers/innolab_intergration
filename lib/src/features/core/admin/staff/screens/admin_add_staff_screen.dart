import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:innolab/src/common/loader/app_loader.dart';
import 'package:innolab/src/features/auth/controllers/auth_controller.dart';

/// Admin-only form to create Firebase Auth + Firestore records for staff (level 2).
class AdminAddStaffScreen extends StatefulWidget {
  const AdminAddStaffScreen({super.key});

  @override
  State<AdminAddStaffScreen> createState() => _AdminAddStaffScreenState();
}

class _AdminAddStaffScreenState extends State<AdminAddStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  String? _emailErrorMsg;

  static const _indigo = Color(0xFF4F46E5);

  String? get _emailError => _emailErrorMsg;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _emailErrorMsg = null; // reset error
    });

    try {
      await AAppLoading.showWhile(context, () async {
        await AAuthController.instance.registerStaffByAdmin(
          fullName: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
        );
      }, message: 'Saving account...');

      if (mounted) {
        final pwd = AAuthController.staffDefaultTempPassword;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Account created'),
            content: Text(
              'Temporary password:\n\n$pwd\n\n'
              'Ask the staff member to change it after first sign-in.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );

        _formKey.currentState!.reset();
        _nameCtrl.clear();
        _emailCtrl.clear();
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          if (e.code == 'email-already-in-use') {
            _emailErrorMsg = 'This email is already registered';
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      color: const Color(0xFFF4F6FB),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _indigo.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Iconsax.user_add,
                          color: _indigo,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add staff',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Create a login for a new staff member. They use this email and password to sign in.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _nameCtrl,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(color: Colors.black), 
                    decoration: _fieldDecoration('Full name'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Enter a name';
                      }
                      if (v.trim().split(' ').length < 2) {
                        return 'Enter full name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    style: const TextStyle(color: Colors.black), 
                    autofillHints: const [AutofillHints.email],
                    onFieldSubmitted: (_) {
                      if (!_loading) _submit();
                    },
                    decoration: _fieldDecoration(
                      'Work email',
                    ).copyWith(errorText: _emailError),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Enter an email';
                      }
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      if (!emailRegex.hasMatch(v.trim())) {
                        return 'Enter a valid email';
                      }
                      if (!v.contains('@')) return 'Enter a valid email';

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '* Staff password default: ${AAuthController.staffDefaultTempPassword}. '
                    'Remind them to change it after first login.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _loading ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: _indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Create staff account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _indigo, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

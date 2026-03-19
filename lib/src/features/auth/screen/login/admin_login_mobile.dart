import 'package:flutter/material.dart';

// const _adminEmail = 'admin@gmail.com';
// const _adminPassword = 'admin12345678';


class AdminLoginMobile extends StatelessWidget {
  const AdminLoginMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}


// class AdminLoginMobile extends StatelessWidget {
//   const AdminLoginMobile({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: _MobileBody(),
//       ),
//     );
//   }
// }

// class _MobileBody extends StatefulWidget {
//   const _MobileBody();

//   @override
//   State<_MobileBody> createState() => _MobileBodyState();
// }

// class _MobileBodyState extends State<_MobileBody> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _obscurePassword = true;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   void _onLogin() {
//     if (!(_formKey.currentState?.validate() ?? false)) return;

//     final email = _emailController.text.trim();
//     final password = _passwordController.text;

//     final isValid =
//         email.toLowerCase() == _adminEmail.toLowerCase() &&
//         password == _adminPassword;

//     final messenger = ScaffoldMessenger.of(context);

//     if (isValid) {
//       messenger.showSnackBar(
//         const SnackBar(
//           content: Text('Admin login successful'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } else {
//       messenger.showSnackBar(
//         const SnackBar(
//           content: Text('Invalid admin credentials'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }

//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return SingleChildScrollView(
//       padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           // ── Top bar ──────────────────────────────────────────────
//           Row(
//             children: [
//               Container(width: 3, height: 20, color: Colors.redAccent),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Text(
//                   'ADVANCED MANUFACTURING\nCenter MIMAROPA',
//                   style: theme.textTheme.labelSmall?.copyWith(
//                     fontWeight: FontWeight.w600,
//                     letterSpacing: 2,
//                     color: Colors.black87,
//                     height: 1.5,
//                   ),
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 40),

//           // ── Logo + heading ────────────────────────────────────────
//           Center(
//             child: Column(
//               children: [
//                 Container(
//                   width: 80,
//                   height: 80,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(color: Colors.grey.shade200, width: 2),
//                   ),
//                   child: ClipOval(
//                     child: Image.asset(
//                       'assets/logos/admin_logo.png',
//                       fit: BoxFit.contain,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Admin Sign In',
//                   style: theme.textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.w700,
//                     color: Colors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   'Sign in to your admin account',
//                   style: theme.textTheme.bodySmall?.copyWith(
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 36),

//           // ── Social sign-in ────────────────────────────────────────
//           Row(
//             children: [
//               Expanded(
//                 child: _SocialLoginButton(
//                   icon: Icons.g_mobiledata,
//                   label: 'Google',
//                   onTap: () {},
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _SocialLoginButton(
//                   icon: Icons.facebook,
//                   label: 'Facebook',
//                   onTap: () {},
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 28),

//           // ── Divider ───────────────────────────────────────────────
//           Row(
//             children: [
//               Expanded(child: Divider(color: Colors.grey.shade300)),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 14),
//                 child: Text(
//                   'or continue with email',
//                   style: theme.textTheme.labelSmall?.copyWith(
//                     color: Colors.grey.shade500,
//                   ),
//                 ),
//               ),
//               Expanded(child: Divider(color: Colors.grey.shade300)),
//             ],
//           ),

//           const SizedBox(height: 28),

//           // ── Form ──────────────────────────────────────────────────
//           Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // Email field
//                 TextFormField(
//                   controller: _emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   style: const TextStyle(color: Colors.black, fontSize: 14),
//                   cursorColor: Colors.blue,
//                   decoration: InputDecoration(
//                     labelText: 'Email or phone',
//                     labelStyle: TextStyle(
//                       color: Colors.grey.shade600,
//                       fontSize: 14,
//                     ),
//                     prefixIcon: Icon(
//                       Icons.mail_outline_rounded,
//                       size: 20,
//                       color: Colors.grey.shade500,
//                     ),
//                     filled: true,
//                     fillColor: Colors.grey.shade50,
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 16,
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14),
//                       borderSide: BorderSide(color: Colors.grey.shade300),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14),
//                       borderSide: BorderSide(color: Colors.grey.shade300),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14),
//                       borderSide:
//                           const BorderSide(color: Colors.blue, width: 1.5),
//                     ),
//                     errorBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14),
//                       borderSide: const BorderSide(color: Colors.redAccent),
//                     ),
//                     focusedErrorBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14),
//                       borderSide:
//                           const BorderSide(color: Colors.redAccent, width: 1.5),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) {
//                       return 'Please enter your email or phone';
//                     }
//                     return null;
//                   },
//                 ),

//                 const SizedBox(height: 16),

//                 // Password field
//                 TextFormField(
//                   controller: _passwordController,
//                   obscureText: _obscurePassword,
//                   style: const TextStyle(color: Colors.black, fontSize: 14),
//                   cursorColor: Colors.blue,
//                   decoration: InputDecoration(
//                     labelText: 'Password',
//                     labelStyle: TextStyle(
//                       color: Colors.grey.shade600,
//                       fontSize: 14,
//                     ),
//                     prefixIcon: Icon(
//                       Icons.lock_outline_rounded,
//                       size: 20,
//                       color: Colors.grey.shade500,
//                     ),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _obscurePassword
//                             ? Icons.visibility_off_outlined
//                             : Icons.visibility_outlined,
//                         color: Colors.grey.shade500,
//                         size: 20,
//                       ),
//                       onPressed: () =>
//                           setState(() => _obscurePassword = !_obscurePassword),
//                     ),
//                     filled: true,
//                     fillColor: Colors.grey.shade50,
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 16,
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14),
//                       borderSide: BorderSide(color: Colors.grey.shade300),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14),
//                       borderSide: BorderSide(color: Colors.grey.shade300),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14),
//                       borderSide:
//                           const BorderSide(color: Colors.blue, width: 1.5),
//                     ),
//                     errorBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14),
//                       borderSide: const BorderSide(color: Colors.redAccent),
//                     ),
//                     focusedErrorBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14),
//                       borderSide:
//                           const BorderSide(color: Colors.redAccent, width: 1.5),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your password';
//                     }
//                     return null;
//                   },
//                 ),

//                 const SizedBox(height: 10),

//                 // Forgot password
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: TextButton(
//                     onPressed: () {},
//                     style: TextButton.styleFrom(
//                       padding: EdgeInsets.zero,
//                       minimumSize: const Size(0, 0),
//                       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                     ),
//                     child: Text(
//                       'Forgot password?',
//                       style: theme.textTheme.bodySmall?.copyWith(
//                         color: Colors.blue,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 24),

//                 // Login button
//                 SizedBox(
//                   height: 52,
//                   child: ElevatedButton(
//                     onPressed: _onLogin,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue,
//                       foregroundColor: Colors.white,
//                       elevation: 0,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                     ),
//                     child: const Text(
//                       'Log in',
//                       style: TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.w600,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 32),

//           // ── Footer ────────────────────────────────────────────────
//           Center(
//             child: Text(
//               '© Advanced Manufacturing Center MIMAROPA',
//               style: theme.textTheme.labelSmall?.copyWith(
//                 color: Colors.grey.shade400,
//                 letterSpacing: 0.5,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),

//           const SizedBox(height: 16),
//         ],
//       ),
//     );
//   }
// }

// // ── Social login button ────────────────────────────────────────────────────────

// class _SocialLoginButton extends StatelessWidget {
//   const _SocialLoginButton({
//     required this.icon,
//     required this.label,
//     required this.onTap,
//   });

//   final IconData icon;
//   final String label;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(12),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: onTap,
//         child: Container(
//           height: 48,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.grey.shade300),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, size: 22, color: Colors.black87),
//               const SizedBox(width: 8),
//               Text(
//                 label,
//                 style: const TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black87,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
// import 'package:innolab/src/common/widget/social_btn.dart';


class LeftPanel extends StatelessWidget {
  const LeftPanel({super.key, required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 96,
          height: 96,
          child: Image.asset(
            'assets/logos/admin_logo.png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Sign in',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'sign in using google account',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey.shade500)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Or',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey.shade500)),
          ],
        ),
        const SizedBox(height: 24),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //       SocialButton(icon: Icons.g_mobiledata, label: 'G'),
        //     const SizedBox(width: 24),
        //       SocialButton(icon: Icons.facebook, label: 'f'),
        //   ],
        // ),
      ],
    );
  }
}




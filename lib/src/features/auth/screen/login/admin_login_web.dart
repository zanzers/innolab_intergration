import 'package:flutter/material.dart';
import 'package:innolab/src/features/auth/screen/login/login_widget/leftPanel.dart';
import 'package:innolab/src/features/auth/screen/login/login_widget/rightpanel.dart';

class AdminLoginWeb extends StatelessWidget {
  const AdminLoginWeb({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              child: Row(
                children: [
                  Text(
                    'ADVANCED MANUFACTURING Center MIMAROPA',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      letterSpacing: 4,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 1000,
                      minHeight: 420,
                    ),
                    child: Material(
                      color: Colors.white,
                      shape: BeveledRectangleBorder(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(64),
                        ),
                        side: BorderSide(
                          color: Colors.grey.shade500,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: LeftPanel(theme: theme),
                            ),
                            SizedBox(
                              height: 320,
                              child: VerticalDivider(
                                width: 64,
                                thickness: 1,
                                color: Colors.grey.shade300,
                              ),
                            ),
                            const Expanded(
                              flex: 3,
                              child: RightPanel(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



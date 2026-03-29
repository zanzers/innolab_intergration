import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:innolab/src/features/core/staff/staffController/staff_controller.dart';
import 'package:innolab/src/features/home/widgets/staff_sidebar.dart';
import 'package:innolab/src/features/core/staff/home/screens/staff_home_tab.dart';
import 'package:innolab/src/features/core/staff/machine/screens/staff_machine_tab.dart';
import 'package:innolab/src/features/core/staff/received/screens/staff_received_screen.dart';
import 'package:innolab/src/features/core/staff/message/screens/staff_message_screen.dart';
import 'package:innolab/src/features/core/staff/schedule/screens/staff_schedule_screen.dart';

class StaffHomeWeb extends StatefulWidget {
  const StaffHomeWeb({super.key});

  @override
  State<StaffHomeWeb> createState() => _StaffHomeWebState();
}

class _StaffHomeWebState extends State<StaffHomeWeb> {
  StaffNavItem _selectedItem = StaffNavItem.home;

  final String? userAvatarUrl = null;

  /// Extract initials from full name (e.g., "Fewell Saavedra" -> "FS")
  String _getInitials(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Top bar ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  // Search bar — wider
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          Icon(
                            Iconsax.search_normal,
                            size: 18,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Search something...',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Bell icon
                  Icon(
                    Iconsax.notification,
                    size: 22,
                    color: Colors.grey.shade700,
                  ),

                  const SizedBox(width: 20),

                  // Avatar + Welcome back + name
                  Row(
                    children: [
                      Obx(() {
                        final staffName =
                            StaffController.instance.fullName.isNotEmpty
                            ? StaffController.instance.fullName
                            : 'Staff';
                        final initials = _getInitials(staffName);
                        return CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.teal.shade100,
                          backgroundImage: userAvatarUrl != null
                              ? NetworkImage(userAvatarUrl!)
                              : null,
                          child: userAvatarUrl == null
                              ? Text(
                                  initials,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.teal.shade700,
                                  ),
                                )
                              : null,
                        );
                      }),
                      const SizedBox(width: 10),
                      Obx(() {
                        final staffName =
                            StaffController.instance.fullName.isNotEmpty
                            ? StaffController.instance.fullName
                            : 'Staff';
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Welcome back',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.grey.shade500,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              staffName,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),

            // ── Sidebar + content ────────────────────────────────────
            Expanded(
              child: Row(
                children: [
                  Obx(() {
                    final staffRole =
                        StaffController.instance.roleDisplay.isNotEmpty
                        ? StaffController.instance.roleDisplay
                        : 'Staff';
                    return StaffSidebar(
                      selectedItem: _selectedItem,
                      onItemSelected: (item) =>
                          setState(() => _selectedItem = item),
                      userName: staffRole,
                      userAvatarUrl: null,
                      onLogout: () async {
                        try {
                          await FirebaseAuth.instance.signOut();
                          StaffController.instance.clearUser();
                          print('Staff signed out successfully');
                        } catch (e) {
                          print('Error signing out: $e');
                        }
                      },
                    );
                  }),
                  Expanded(child: _buildContent()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedItem) {
      case StaffNavItem.home:
        return StaffHomeTab();
      case StaffNavItem.machine:
        return StaffMachineTab();
      case StaffNavItem.received:
        return StaffReceivedScreen();
      case StaffNavItem.message:
        return StaffMessageScreen();
      case StaffNavItem.schedule:
        return StaffScheduleScreen();
    }
  }
}

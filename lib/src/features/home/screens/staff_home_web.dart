import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:innolab/src/features/core/staff/home/screens/staff_home_tab.dart';
import 'package:innolab/src/features/core/staff/machine/screens/staff_machine_screen.dart';
import 'package:innolab/src/features/core/staff/message/screens/staff_message_screen.dart';
import 'package:innolab/src/features/core/staff/received/screens/staff_received_screen.dart';
import 'package:innolab/src/features/core/staff/schedule/screens/staff_schedule_screen.dart';
import 'package:innolab/src/features/home/widgets/staff_sidebar.dart';


class StaffHomeWeb extends StatefulWidget {
  const StaffHomeWeb({super.key});
 
  @override
  State<StaffHomeWeb> createState() => _StaffHomeWebState();
}
 
class _StaffHomeWebState extends State<StaffHomeWeb> {
  StaffNavItem _selectedItem = StaffNavItem.home;
 
  // TODO: Replace with actual staff data from auth
  final String userName = 'Staff Name';
  final String? userAvatarUrl = null;
 
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
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
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
                          Icon(Iconsax.search_normal,
                              size: 18, color: Colors.grey.shade400),
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
                  Icon(Iconsax.notification,
                      size: 22, color: Colors.grey.shade700),
 
                  const SizedBox(width: 20),
 
                  // Avatar + Welcome back + name
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.teal.shade100,
                        backgroundImage: userAvatarUrl != null
                            ? NetworkImage(userAvatarUrl!)
                            : null,
                        child: userAvatarUrl == null
                            ? Icon(Iconsax.user,
                                size: 20, color: Colors.teal.shade700)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Column(
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
                            userName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
 
            // ── Sidebar + content ────────────────────────────────────
            Expanded(
              child: Row(
                children: [
                  StaffSidebar(
                    selectedItem: _selectedItem,
                    onItemSelected: (item) =>
                        setState(() => _selectedItem = item),
                    userName: 'Staff Name',
                    userAvatarUrl: null,
                    onLogout: () {
                      // TODO: Implement logout
                      // Navigator.pushReplacement(context,
                      //   MaterialPageRoute(builder: (_) => const StaffLoginScreen()));
                    },
                  ),
                  Expanded(
                    child: _buildContent(),
                  ),
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
        return const StaffHomeTab();
      case StaffNavItem.machine:
        return const StaffMachineScreen();
      case StaffNavItem.received:
        return const StaffReceivedScreen();
      case StaffNavItem.message:
        return const StaffMessageScreen();
      case StaffNavItem.schedule:
        return const StaffScheduleScreen();
    }
  }
}
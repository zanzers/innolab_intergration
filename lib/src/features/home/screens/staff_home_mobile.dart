import 'package:flutter/material.dart';
import 'package:innolab/src/features/core/staff/home/screens/staff_home_tab.dart';
import 'package:innolab/src/features/core/staff/machine/screens/staff_machine_screen.dart';
import 'package:innolab/src/features/core/staff/message/screens/staff_message_screen.dart';
import 'package:innolab/src/features/core/staff/received/screens/staff_received_screen.dart';
import 'package:innolab/src/features/core/staff/schedule/screens/staff_schedule_screen.dart';
import 'package:innolab/src/features/home/widgets/staff_sidebar.dart';

class StaffHomeMobile extends StatefulWidget {
  const StaffHomeMobile({super.key});

  @override
  State<StaffHomeMobile> createState() => _StaffHomeMobileState();
}

class _StaffHomeMobileState extends State<StaffHomeMobile> {
  StaffNavItem _selectedItem = StaffNavItem.home;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,

      // ── Drawer (sidebar on mobile) ─────────────────────────────
      drawer: Drawer(
        width: 220,
        backgroundColor: Colors.white,
        child: SafeArea(
          child: StaffSidebar(
            selectedItem: _selectedItem,
            onItemSelected: (item) {
              setState(() => _selectedItem = item);
              Navigator.pop(context);
            },
            userName: 'Staff Name',
            userAvatarUrl: null,
            onLogout: () {
              Navigator.pop(context);
              // TODO: Implement logout logic
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => const StaffLoginScreen(),
              //   ),
              // );
            },
          ),
        ),
      ),

      // ── App bar ────────────────────────────────────────────────
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        // Menu button
                        IconButton(
                          icon: const Icon(Icons.menu_rounded,
                              color: Colors.black87, size: 22),
                          onPressed: () =>
                              _scaffoldKey.currentState?.openDrawer(),
                        ),

                        // Search bar
                        Expanded(
                          child: Container(
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(24),
                              border:
                                  Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 10),
                                Icon(Icons.search,
                                    size: 16,
                                    color: Colors.grey.shade400),
                                const SizedBox(width: 6),
                                Text(
                                  'Search something..',
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: Colors.grey.shade400,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Bell
                        IconButton(
                          icon: Icon(Icons.notifications_none_outlined,
                              size: 22, color: Colors.grey.shade700),
                          onPressed: () {},
                        ),

                        // Avatar + welcome
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.teal.shade100,
                              child: Icon(Icons.person,
                                  size: 18,
                                  color: Colors.teal.shade700),
                            ),
                            const SizedBox(width: 6),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Welcome back',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                Text(
                                  'Staff Name',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 4),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(height: 1, color: Colors.grey.shade200),
              ],
            ),
          ),
        ),
      ),

      // ── Body ───────────────────────────────────────────────────
      body: _buildContent(),
    );
  }

  String _navItemLabel(StaffNavItem item) {
    switch (item) {
      case StaffNavItem.home:
        return 'Home';
      case StaffNavItem.machine:
        return 'Machine';
      case StaffNavItem.received:
        return 'Received';
      case StaffNavItem.message:
        return 'Message';
      case StaffNavItem.schedule:
        return 'Schedule';
    }
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
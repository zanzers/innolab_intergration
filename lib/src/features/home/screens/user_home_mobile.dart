import 'package:flutter/material.dart';
import 'package:innolab/src/features/core/client/home/screens/user_home_tab.dart';
import 'package:innolab/src/features/core/client/message/screens/user_message_screen.dart';
import 'package:innolab/src/features/core/client/quote/screens/user_quote_screen.dart';
import 'package:innolab/src/features/core/client/request/screens/user_request_screen.dart';
import 'package:innolab/src/features/core/client/schedule/screens/user_schedule_screen.dart';
import 'package:innolab/src/features/home/widgets/user_sidebar.dart';

class UserHomeMobile extends StatefulWidget {
  const UserHomeMobile({super.key});

  @override
  State<UserHomeMobile> createState() => _UserHomeMobileState();
}

class _UserHomeMobileState extends State<UserHomeMobile> {
  UserNavItem _selectedItem = UserNavItem.home;
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
          child: UserSidebar(
            selectedItem: _selectedItem,
            onItemSelected: (item) {
              setState(() => _selectedItem = item);
              Navigator.pop(context);
            },
            userName: 'Marcelo',
            userAvatarUrl: null,
            onLogout: () {
              Navigator.pop(context);
              // TODO: Implement logout logic
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => const UserLoginScreen(),
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
                              backgroundColor: Colors.indigo.shade100,
                              child: Icon(Icons.person,
                                  size: 18,
                                  color: Colors.indigo.shade700),
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
                                  'Marcelo',
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

  String _navItemLabel(UserNavItem item) {
    switch (item) {
      case UserNavItem.home:
        return 'Home';
      case UserNavItem.quote:
        return 'Quote';
      case UserNavItem.receipt:
        return 'Request';
      case UserNavItem.message:
        return 'Message';
      case UserNavItem.schedule:
        return 'Schedule';
      case UserNavItem.request:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  Widget _buildContent() {
    switch (_selectedItem) {
      case UserNavItem.home:
        return const UserHomeTab();
      case UserNavItem.quote:
        return const UserQuoteScreen();
      case UserNavItem.receipt:
        return const UserRequestScreen();
      case UserNavItem.message:
        return const UserMessageScreen();
      case UserNavItem.schedule:
        return const UserScheduleScreen();
      case UserNavItem.request:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}
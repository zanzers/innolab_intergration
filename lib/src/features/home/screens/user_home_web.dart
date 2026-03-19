import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:innolab/src/features/core/client/home/screens/user_home_tab.dart';
import 'package:innolab/src/features/core/client/message/screens/user_message_screen.dart';
import 'package:innolab/src/features/core/client/quote/screens/user_quote_screen.dart';
import 'package:innolab/src/features/core/client/request/screens/user_request_screen.dart';
import 'package:innolab/src/features/core/client/schedule/screens/user_schedule_screen.dart';
import 'package:innolab/src/features/home/widgets/user_sidebar.dart';

class UserHomeWeb extends StatefulWidget {
  const UserHomeWeb({super.key});
 
  @override
  State<UserHomeWeb> createState() => _UserHomeWebState();
}
 
class _UserHomeWebState extends State<UserHomeWeb> {
  UserNavItem _selectedItem = UserNavItem.home;
 
  final String userName = 'Marcelo';
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
                  // Search bar — wider, takes up center space
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
                        backgroundColor: Colors.indigo.shade100,
                        backgroundImage: userAvatarUrl != null
                            ? NetworkImage(userAvatarUrl!)
                            : null,
                        child: userAvatarUrl == null
                            ? Icon(Iconsax.user,
                                size: 20, color: Colors.indigo.shade700)
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
                  UserSidebar(
                    selectedItem: _selectedItem,
                    onItemSelected: (item) =>
                        setState(() => _selectedItem = item),
                    userName: 'Marcelo',
                    userAvatarUrl: null,
                    onLogout: () {
                      // TODO: Implement logout
                      // Navigator.pushReplacement(context,
                      //   MaterialPageRoute(builder: (_) => const UserLoginScreen()));
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
      case UserNavItem.receipt:
        // TODO: Handle this case.
        throw UnimplementedError();
      case UserNavItem.request:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}
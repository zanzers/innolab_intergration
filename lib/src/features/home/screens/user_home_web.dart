import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:iconsax/iconsax.dart';
import 'package:innolab/src/features/core/controller/profileController/profile_controller.dart';
import 'package:innolab/src/features/home/widgets/user_sidebar.dart';
import 'package:innolab/src/features/core/client/home/screens/user_home_tab.dart';
import 'package:innolab/src/features/core/client/quote/screens/user_quote_screen.dart';
import 'package:innolab/src/features/core/client/request/screens/user_request_screen.dart';
import 'package:innolab/src/features/core/client/message/screens/user_message_screen.dart';
import 'package:innolab/src/features/core/client/schedule/screens/user_schedule_screen.dart';

class UserHomeWeb extends StatefulWidget {
  const UserHomeWeb({super.key});

  @override
  State<UserHomeWeb> createState() => _UserHomeWebState();
}

class _UserHomeWebState extends State<UserHomeWeb> {
  UserNavItem _selectedItem = UserNavItem.home;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = Get.find<ProfileController>();

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
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  // Search bar
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

                  // ── Message icon ──────────────────────────────────
                  IconButton(
                    icon: Icon(Iconsax.message,
                        size: 22, color: Colors.grey.shade700),
                    onPressed: () =>
                        setState(() => _selectedItem = UserNavItem.message),
                  ),

                  // ── Settings icon ─────────────────────────────────
                  IconButton(
                    icon: Icon(Iconsax.setting_2,
                        size: 22, color: Colors.grey.shade700),
                    onPressed: () {
                      // TODO: Navigate to settings
                    },
                  ),

                  const SizedBox(width: 8),

                  // Avatar + welcome + name + role
                  Row(
                    children: [
                      Obx(() {
                        final u = profile.user;
                        final name = u?.fullName.trim() ?? '';
                        final initial = name.isNotEmpty
                            ? name[0].toUpperCase()
                            : '?';
                        return CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.indigo.shade100,
                          child: Text(
                            initial,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.indigo.shade700,
                            ),
                          ),
                        );
                      }),
                      const SizedBox(width: 10),
                      Obx(() {
                        final u = profile.user;
                        if (u == null) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Loading...',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.grey.shade500,
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                'Please wait',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                  
                            Text(
                              u.fullName,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                                fontSize: 12,
                              ),
                            ),
                            if (profile.roleDisplay.isNotEmpty)
                              Text(
                                profile.roleDisplay,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.grey.shade600,
                                  fontSize: 9,
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
              child: Obx(() {
                final u = profile.user;
                return Row(
                  children: [
                    UserSidebar(
                      selectedItem: _selectedItem,
                      onItemSelected: (item) =>
                          setState(() => _selectedItem = item),
                      userName: u?.fullName ?? '',
                      userAvatarUrl: null,
                      onLogout: () async {
                        await FirebaseAuth.instance.signOut();
                      },
                    ),
                    Expanded(
                      child: _buildContent(),
                    ),
                  ],
                );
              }),
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
      case UserNavItem.request:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}
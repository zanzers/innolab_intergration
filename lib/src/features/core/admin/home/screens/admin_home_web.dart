import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:innolab/src/features/core/admin/adminContorller/adminController.dart';
import 'package:innolab/src/features/core/admin/home/screens/home_tab_screen.dart';
import 'package:innolab/src/features/core/admin/inventory/screens/inventory_screen.dart';
import 'package:innolab/src/features/core/admin/maintenance/screens/maintenance_screen.dart';
import 'package:innolab/src/features/core/admin/message/screens/message_screen.dart';
import 'package:innolab/src/features/core/admin/request/screens/request_screen.dart';
import 'package:innolab/src/features/core/admin/schedule/screens/schedule_screen.dart';
import 'package:innolab/src/features/core/admin/staff/screens/admin_add_staff_screen.dart';
import 'package:innolab/src/features/core/admin/staff/screens/staff_screen.dart';
import 'package:innolab/src/features/core/admin/user/screens/user_screen.dart';

enum AdminSection {
  home,
  maintenance,
  schedule,
  request,
  message,
  staff,
  staffAddUser,
  user,
  inventory,
}

class AdminHomeWeb extends StatefulWidget {
  const AdminHomeWeb({super.key});

  @override
  State<AdminHomeWeb> createState() => _AdminHomeWebState();
}

class _AdminHomeWebState extends State<AdminHomeWeb> {
  AdminSection _selectedSection = AdminSection.home;
  final AdminController _adminController = const AdminController();
  late final Future<AdminHeaderData> _adminHeaderFuture;

  @override
  void initState() {
    super.initState();
    _adminHeaderFuture = _adminController.fetchAdminHeaderData();
  }

  void _onSectionSelected(AdminSection section) {
    setState(() => _selectedSection = section);
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

                  const SizedBox(width: 16),

                  _HeaderActionButton(
                    icon: Iconsax.user_add,
                    label: 'Add User',
                    isSelected: _selectedSection == AdminSection.staffAddUser,
                    onTap: () =>
                        _onSectionSelected(AdminSection.staffAddUser),
                  ),
                  const SizedBox(width: 8),
                  _HeaderActionButton(
                    icon: Iconsax.calendar_1,
                    label: 'Schedule',
                    isSelected: _selectedSection == AdminSection.schedule,
                    onTap: () => _onSectionSelected(AdminSection.schedule),
                  ),
                  const SizedBox(width: 8),
                  _HeaderActionButton(
                    icon: Iconsax.box,
                    label: 'Inventory',
                    isSelected: _selectedSection == AdminSection.inventory,
                    onTap: () => _onSectionSelected(AdminSection.inventory),
                  ),

                  const SizedBox(width: 12),

                  // Message icon
                  IconButton(
                    icon: Icon(Iconsax.message,
                        size: 22, color: Colors.grey.shade700),
                    onPressed: () =>
                        setState(() => _selectedSection = AdminSection.message),
                  ),

                  // Settings icon
                  IconButton(
                    icon: Icon(Iconsax.setting_2,
                        size: 22, color: Colors.grey.shade700),
                    onPressed: () {
                      // TODO: Navigate to settings
                    },
                  ),

                  const SizedBox(width: 8),

                  // Avatar + user details
                  FutureBuilder<AdminHeaderData>(
                    future: _adminHeaderFuture,
                    builder: (context, snapshot) {
                      
                      final AdminHeaderData header;
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        header = const AdminHeaderData(
                          username: 'Loading...',
                          role: 'Loading...',
                        );
                      } else {
                        header = snapshot.data ??
                            const AdminHeaderData(
                              username: 'Loading...',
                              role: 'Loading...',
                            );
                      }

                      return Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.indigo.shade100,
                            child: Icon(Iconsax.user,
                                size: 20, color: Colors.indigo.shade700),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                header.username,
                                style: theme.textTheme.bodySmall?.copyWith(
                                   color: Colors.black87,
                                  
                                ),
                              ),
                              Text(
                                header.role,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade500,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            // ── Sidebar + content ────────────────────────────────────
            Expanded(
              child: Row(
                children: [
                  _AdminSidebar(
                    selected: _selectedSection,
                    onSelect: _onSectionSelected,
                  ),
                  Expanded(
                    child: _SectionContent(section: _selectedSection),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sidebar ────────────────────────────────────────────────────────────────────

class _AdminSidebar extends StatelessWidget {
  const _AdminSidebar({required this.selected, required this.onSelect});

  final AdminSection selected;
  final ValueChanged<AdminSection> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Logo ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 50, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/logos/admin_logo.png',
                  height: 65,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                  child: Text(
                    'AMCen Admin',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Menu label ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Menu',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Nav items ─────────────────────────────────────────────
          _NavItem(
            icon: Iconsax.home_2,
            activeIcon: Iconsax.home_25,
            label: 'Home',
            isSelected: selected == AdminSection.home,
            onTap: () => onSelect(AdminSection.home),
          ),
          _NavItem(
            icon: Iconsax.setting,
            activeIcon: Iconsax.setting5,
            label: 'Maintenance',
            isSelected: selected == AdminSection.maintenance,
            onTap: () => onSelect(AdminSection.maintenance),
          ),
          _NavItem(
            icon: Iconsax.document_download,
            activeIcon: Iconsax.document_download5,
            label: 'Request',
            isSelected: selected == AdminSection.request,
            onTap: () => onSelect(AdminSection.request),
          ),
          _NavItem(
            icon: Iconsax.people,
            activeIcon: Iconsax.people5,
            label: 'Staff',
            isSelected: selected == AdminSection.staff,
            onTap: () => onSelect(AdminSection.staff),
          ),
          _NavItem(
            icon: Iconsax.user,
            activeIcon: Iconsax.user5,
            label: 'User',
            isSelected: selected == AdminSection.user,
            onTap: () => onSelect(AdminSection.user),
          ),

          const Spacer(),

          // ── Logout ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
            child: InkWell(
              onTap: () async {
                await FirebaseAuth.instance.signOut();
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Icon(Iconsax.logout,
                        size: 18, color: Colors.grey.shade600),
                    const SizedBox(width: 12),
                    Text(
                      'Logout',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Nav Item ──────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.indigo : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey.shade500,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.indigo : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? Colors.indigo : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section Content ────────────────────────────────────────────────────────────

class _SectionContent extends StatelessWidget {
  const _SectionContent({required this.section});

  final AdminSection section;

  Widget _buildContent() {
    switch (section) {
      case AdminSection.home:
        return AdminHomeDashboard();
      case AdminSection.maintenance:
        return const MaintenanceScreen();
      case AdminSection.request:
        return const RequestScreen();
      case AdminSection.message:
        return const MessageScreen();
      case AdminSection.staff:
        return const StaffScreen();
      case AdminSection.staffAddUser:
        return const AdminAddStaffScreen();
      case AdminSection.user:
        return const UserScreen();
      case AdminSection.schedule:
        return ScheduleScreen();
      case AdminSection.inventory:
        return const InventoryScreen();
    }
  }

  @override
  Widget build(BuildContext context) => _buildContent();
}
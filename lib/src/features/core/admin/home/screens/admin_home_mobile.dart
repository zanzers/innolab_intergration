import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
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

class AdminHomeMobile extends StatefulWidget {
  const AdminHomeMobile({super.key});

  @override
  State<AdminHomeMobile> createState() => _AdminHomeMobileState();
}

class _AdminHomeMobileState extends State<AdminHomeMobile> {
  AdminSection _selectedSection = AdminSection.home;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Bottom nav shows 4 primary items; the rest live in the drawer
  static const _bottomItems = [
    AdminSection.home,
    AdminSection.request,
    AdminSection.inventory,
    AdminSection.maintenance,
  ];

  int get _bottomIndex {
    final idx = _bottomItems.indexOf(_selectedSection);
    return idx < 0 ? 0 : idx;
  }

  void _select(AdminSection section) {
    setState(() => _selectedSection = section);
    if (_scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,

      // ── Drawer ────────────────────────────────────────────────────
      drawer: Drawer(
        width: 220,
        backgroundColor: Colors.white,
        child: SafeArea(
          child: _AdminDrawerContent(
            selected: _selectedSection,
            onSelect: _select,
          ),
        ),
      ),

      // ── App bar ───────────────────────────────────────────────────
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(108),
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
                        // Hamburger
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

                        // Message icon
                        IconButton(
                          icon: Icon(Iconsax.message,
                              size: 20, color: Colors.grey.shade700),
                          onPressed: () =>
                              _select(AdminSection.message),
                        ),

                        // Settings icon
                        IconButton(
                          icon: Icon(Iconsax.setting_2,
                              size: 20, color: Colors.grey.shade700),
                          onPressed: () {
                            // TODO: Navigate to settings
                          },
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
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Welcome back',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                const Text(
                                  'Marcelo',
                                  style: TextStyle(
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _HeaderActionButton(
                          icon: Iconsax.user_add,
                          label: 'Add User',
                          isSelected:
                              _selectedSection == AdminSection.staffAddUser,
                          onTap: () => _select(AdminSection.staffAddUser),
                        ),
                        const SizedBox(width: 8),
                        _HeaderActionButton(
                          icon: Iconsax.calendar_1,
                          label: 'Schedule',
                          isSelected:
                              _selectedSection == AdminSection.schedule,
                          onTap: () => _select(AdminSection.schedule),
                        ),
                        const SizedBox(width: 8),
                        _HeaderActionButton(
                          icon: Iconsax.box,
                          label: 'Inventory',
                          isSelected:
                              _selectedSection == AdminSection.inventory,
                          onTap: () => _select(AdminSection.inventory),
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

      // ── Body ──────────────────────────────────────────────────────
      body: _SectionContent(section: _selectedSection),

      // ── Bottom nav ────────────────────────────────────────────────
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _bottomIndex,
          onTap: (i) => setState(() => _selectedSection = _bottomItems[i]),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: Colors.indigo,
          unselectedItemColor: Colors.grey.shade500,
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment),
              label: 'Request',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2),
              label: 'Inventory',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.build_outlined),
              activeIcon: Icon(Icons.build),
              label: 'Maintenance',
            ),
          ],
        ),
      ),
    );
  }
}

// ── Drawer Content ────────────────────────────────────────────────────────────

class _AdminDrawerContent extends StatelessWidget {
  const _AdminDrawerContent({
    required this.selected,
    required this.onSelect,
  });

  final AdminSection selected;
  final ValueChanged<AdminSection> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Logo ───────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 36, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/logos/admin_logo.png',
                height: 55,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 16, 10, 0),
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

        const SizedBox(height: 12),

        // ── Menu label ─────────────────────────────────────────────
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

        // ── Nav items ──────────────────────────────────────────────
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

        // ── Logout ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
              // TODO: implement logout
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
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
                  color:
                      isSelected ? Colors.white : Colors.grey.shade600,
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
          height: 34,
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
                size: 15,
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
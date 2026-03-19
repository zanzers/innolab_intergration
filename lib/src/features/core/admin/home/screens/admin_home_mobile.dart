import 'package:flutter/material.dart';
import 'package:innolab/src/features/core/admin/home/screens/home_tab_screen.dart';
import 'package:innolab/src/features/core/admin/inventory/screens/inventory_screen.dart';
import 'package:innolab/src/features/core/admin/maintenance/screens/maintenance_screen.dart';
import 'package:innolab/src/features/core/admin/message/screens/message_screen.dart';
import 'package:innolab/src/features/core/admin/request/screens/request_screen.dart';
import 'package:innolab/src/features/core/admin/schedule/screens/schedule_screen.dart';
import 'package:innolab/src/features/core/admin/staff/screens/staff_screen.dart';
import 'package:innolab/src/features/core/admin/user/screens/user_screen.dart';



enum AdminSection {
  home,
  maintenance,
  schedule,
  request,
  message,
  staff,
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

  // Bottom nav only shows 4 primary items; the rest live in the drawer.
  static const _bottomItems = [
    AdminSection.home,
    AdminSection.request,
    AdminSection.message,
    AdminSection.maintenance,
  ];

  int get _bottomIndex {
    final idx = _bottomItems.indexOf(_selectedSection);
    return idx < 0 ? 0 : idx; // fallback to 0 when a drawer item is active
  }

  void _select(AdminSection section) {
    setState(() => _selectedSection = section);
    // Close the drawer if it was open
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,

      // ── App bar ──────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                'AMC MIMAROPA',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(width: 2, height: 18, color: Colors.redAccent),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black87),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),

      // ── Drawer (all 8 sections) ───────────────────────────────────
      drawer: _MobileDrawer(
        selected: _selectedSection,
        onSelect: _select,
      ),

      // ── Body (active section) ────────────────────────────────────
      body: _SectionContent(section: _selectedSection),

      // ── Bottom nav (4 primary sections) ─────────────────────────
      bottomNavigationBar: _MobileBottomNav(
        selectedIndex: _bottomIndex,
        onTap: (i) => setState(() => _selectedSection = _bottomItems[i]),
      ),
    );
  }
}

// ── Drawer ─────────────────────────────────────────────────────────────────────

class _MobileDrawer extends StatelessWidget {
  const _MobileDrawer({required this.selected, required this.onSelect});

  final AdminSection selected;
  final ValueChanged<AdminSection> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: Image.asset(
                      'assets/logos/admin_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AMCent',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Admin Panel',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GENERAL',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.grey.shade500,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Divider(height: 1, color: Colors.grey.shade200),
                ],
              ),
            ),

            // Nav items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _DrawerItem(
                    icon: Icons.home_filled,
                    label: 'Home',
                    selected: selected == AdminSection.home,
                    onTap: () => onSelect(AdminSection.home),
                  ),
                  _DrawerItem(
                    icon: Icons.build_outlined,
                    label: 'Maintenance',
                    selected: selected == AdminSection.maintenance,
                    onTap: () => onSelect(AdminSection.maintenance),
                  ),
                  _DrawerItem(
                    icon: Icons.inventory_2_outlined,
                    label: 'Inventory',
                    selected: selected == AdminSection.inventory,
                    onTap: () => onSelect(AdminSection.inventory),
                  ),
                  _DrawerItem(
                    icon: Icons.assignment_outlined,
                    label: 'Request',
                    selected: selected == AdminSection.request,
                    onTap: () => onSelect(AdminSection.request),
                  ),
                  _DrawerItem(
                    icon: Icons.mail_outline,
                    label: 'Message',
                    selected: selected == AdminSection.message,
                    onTap: () => onSelect(AdminSection.message),
                  ),
                  _DrawerItem(
                    icon: Icons.people_outline,
                    label: 'Staff',
                    selected: selected == AdminSection.staff,
                    onTap: () => onSelect(AdminSection.staff),
                  ),
                  _DrawerItem(
                    icon: Icons.person_outline,
                    label: 'User',
                    selected: selected == AdminSection.user,
                    onTap: () => onSelect(AdminSection.user),
                  ),
                  _DrawerItem(
                    icon: Icons.schedule_outlined,
                    label: 'Schedule',
                    selected: selected == AdminSection.schedule,
                    onTap: () => onSelect(AdminSection.schedule),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Profile row
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFF6C5CE7),
                    child: Icon(Icons.person, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Marcelo',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Administrator',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, size: 20, color: Colors.black54),
                    tooltip: 'Logout',
                    onPressed: () => Navigator.of(context).pop(),
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

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE7EBFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? Colors.indigo : Colors.grey.shade600,
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: selected ? Colors.indigo : Colors.grey.shade800,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom Navigation Bar ──────────────────────────────────────────────────────

class _MobileBottomNav extends StatelessWidget {
  const _MobileBottomNav({
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onTap,
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
            icon: Icon(Icons.mail_outline),
            activeIcon: Icon(Icons.mail),
            label: 'Message',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build_outlined),
            activeIcon: Icon(Icons.build),
            label: 'Maintenance',
          ),
        ],
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
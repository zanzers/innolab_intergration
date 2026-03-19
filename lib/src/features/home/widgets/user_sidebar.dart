import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

enum UserNavItem { home, quote, receipt, message, schedule, request }

class UserSidebar extends StatelessWidget {
  const UserSidebar({
    super.key,
    required this.selectedItem,
    required this.onItemSelected,
    required this.userName,
    required this.userAvatarUrl,
    required this.onLogout,
  });

  final UserNavItem selectedItem;
  final ValueChanged<UserNavItem> onItemSelected;
  final String userName;
  final String? userAvatarUrl;
  final VoidCallback onLogout;

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
                'assets/logos/amcen_logo.png',
                height: 65,
                fit: BoxFit.contain,
            ),
            const SizedBox(height: 4),
            Row(
            children: [
                Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 0), 
                child: Text(
                    'AMCen app name',
                    style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    ),
                ),
               ),
              ],
            ),
          ],
         ),
       ),

          const SizedBox(height: 16),

          // ── Menu section label ────────────────────────────────────
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
            isSelected: selectedItem == UserNavItem.home,
            onTap: () => onItemSelected(UserNavItem.home),
          ),
          _NavItem(
            icon: Iconsax.receipt_item,
            activeIcon: Iconsax.receipt_item5,
            label: 'Quote',
            isSelected: selectedItem == UserNavItem.quote,
            onTap: () => onItemSelected(UserNavItem.quote),
          ),
          _NavItem(
            icon: Iconsax.receipt,
            activeIcon: Iconsax.receipt5,
            label: 'Receipt',
            isSelected: selectedItem == UserNavItem.receipt,
            onTap: () => onItemSelected(UserNavItem.receipt),
          ),
          _NavItem(
            icon: Iconsax.message,
            activeIcon: Iconsax.message5,
            label: 'Message',
            isSelected: selectedItem == UserNavItem.message,
            onTap: () => onItemSelected(UserNavItem.message),
          ),
          _NavItem(
            icon: Iconsax.calendar_1,
            activeIcon: Iconsax.calendar_15,
            label: 'Schedule',
            isSelected: selectedItem == UserNavItem.schedule,
            onTap: () => onItemSelected(UserNavItem.schedule),
          ),

          const Spacer(),

          // ── Setting section label ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Setting',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Setting item ──────────────────────────────────────────
          _NavItem(
            icon: Iconsax.setting_2,
            activeIcon: Iconsax.setting_25,
            label: 'Setting',
            isSelected: false,
            onTap: () {
              // TODO: Navigate to settings
            },
          ),

          // ── Logout ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
            child: InkWell(
              onTap: onLogout,
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
                      'logout',
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
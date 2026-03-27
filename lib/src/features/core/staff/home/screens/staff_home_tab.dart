import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mock data matching the rest of the app
// ─────────────────────────────────────────────────────────────────────────────

const String _staffName = 'Staff Name';

class _RequestItem {
  final String id;
  final String user;
  final String file;
  final String material;
  final double total;
  final String timeAgo;
  final Color color;

  const _RequestItem({
    required this.id,
    required this.user,
    required this.file,
    required this.material,
    required this.total,
    required this.timeAgo,
    required this.color,
  });
}

class _ScheduleItem {
  final String title;
  final String time;
  final String? user;
  final Color color;

  const _ScheduleItem({
    required this.title,
    required this.time,
    this.user,
    required this.color,
  });
}

class _HistoryItem {
  final String id;
  final String user;
  final String file;
  final double total;
  final String completedAt;
  final String status;
  final Color statusColor;

  const _HistoryItem({
    required this.id,
    required this.user,
    required this.file,
    required this.total,
    required this.completedAt,
    required this.status,
    required this.statusColor,
  });
}

const List<_RequestItem> _pendingRequests = [
  _RequestItem(
    id: 'REQ-2024-002',
    user: 'Ana Rivera',
    file: 'phone_stand.obj',
    material: 'PETG – Transparent',
    total: 580.00,
    timeAgo: '30m ago',
    color: Color(0xFFF59E0B),
  ),
  _RequestItem(
    id: 'REQ-2024-005',
    user: 'Mario Reyes',
    file: 'helmet_v1.stl',
    material: 'PLA Standard – Black',
    total: 920.50,
    timeAgo: '1h ago',
    color: Color(0xFF3B82F6),
  ),
  _RequestItem(
    id: 'REQ-2024-006',
    user: 'Clara Tan',
    file: 'base_plate.3mf',
    material: 'ABS – White',
    total: 440.00,
    timeAgo: '2h ago',
    color: Color(0xFF8B5CF6),
  ),
];

const List<_ScheduleItem> _todaySchedule = [
  _ScheduleItem(
    title: 'Pickup – bracket_v2.stl',
    time: '9:00 AM',
    user: 'Marcelo Santos',
    color: Color(0xFF10B981),
  ),
  _ScheduleItem(
    title: 'Consultation – 3D model review',
    time: '11:00 AM',
    user: 'Ana Rivera',
    color: Color(0xFF3B82F6),
  ),
  _ScheduleItem(
    title: 'Printer Maintenance',
    time: '2:00 PM',
    color: Color(0xFFF59E0B),
  ),
];

const List<_HistoryItem> _recentHistory = [
  _HistoryItem(
    id: 'REQ-2024-001',
    user: 'Marcelo Santos',
    file: 'bracket_v2.stl',
    total: 350.00,
    completedAt: 'Today, 8:45 AM',
    status: 'Completed',
    statusColor: Color(0xFF10B981),
  ),
  _HistoryItem(
    id: 'REQ-2024-003',
    user: 'Luis Garcia',
    file: 'keycap_set.stl',
    total: 1200.00,
    completedAt: 'Yesterday, 4:10 PM',
    status: 'Picked Up',
    statusColor: Color(0xFF3B82F6),
  ),
  _HistoryItem(
    id: 'REQ-2024-004',
    user: 'Sofia Lim',
    file: 'miniature_v3.obj',
    total: 275.50,
    completedAt: 'Yesterday, 1:30 PM',
    status: 'Completed',
    statusColor: Color(0xFF10B981),
  ),
  _HistoryItem(
    id: 'REQ-2024-000',
    user: 'Javier Cruz',
    file: 'enclosure_top.3mf',
    total: 860.00,
    completedAt: 'Mar 20, 11:00 AM',
    status: 'Picked Up',
    statusColor: Color(0xFF3B82F6),
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Main widget
// ─────────────────────────────────────────────────────────────────────────────

class StaffHomeTab extends StatelessWidget {
  const StaffHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 800;
        return isWide ? const _WebLayout() : const _MobileLayout();
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Web layout — two columns
// ─────────────────────────────────────────────────────────────────────────────

class _WebLayout extends StatelessWidget {
  const _WebLayout();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Greeting ───────────────────────────────────────────
          const _Greeting(),
          const SizedBox(height: 24),

          // ── Stat cards ─────────────────────────────────────────
          const _StatRow(),
          const SizedBox(height: 24),

          // ── Two column body ────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left — pending requests + recent history
              const Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _PendingRequestsCard(),
                    SizedBox(height: 20),
                    _RecentHistoryCard(),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Right — today's schedule + machine status
              Expanded(
                flex: 2,
                child: Column(
                  children: const [
                    _TodayScheduleCard(),
                    SizedBox(height: 20),
                    _MachineStatusCard(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mobile layout — single column
// ─────────────────────────────────────────────────────────────────────────────

class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _Greeting(),
          SizedBox(height: 20),
          _StatRow(),
          SizedBox(height: 20),
          _PendingRequestsCard(),
          SizedBox(height: 20),
          _TodayScheduleCard(),
          SizedBox(height: 20),
          _MachineStatusCard(),
          SizedBox(height: 20),
          _RecentHistoryCard(),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Greeting
// ─────────────────────────────────────────────────────────────────────────────

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, $_staffName 👋',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Here's what's happening today.",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
        // Date badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(Iconsax.calendar_1, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 6),
              Text(
                _formatToday(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatToday() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat row — 4 cards
// ─────────────────────────────────────────────────────────────────────────────

class _StatRow extends StatelessWidget {
  const _StatRow();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, c) {
      if (c.maxWidth < 500) {
        return Column(
          children: [
            Row(children: [
              Expanded(child: _StatCard(icon: Iconsax.cpu, label: 'Machines Active', value: '2', sub: 'of 5 total', color: Colors.teal)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(icon: Iconsax.document_download, label: 'Pending', value: '${_pendingRequests.length}', sub: 'requests', color: const Color(0xFFF59E0B))),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _StatCard(icon: Iconsax.calendar_1, label: "Today's Schedules", value: '${_todaySchedule.length}', sub: 'appointments', color: const Color(0xFF3B82F6))),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(icon: Iconsax.tick_circle, label: 'Completed', value: '${_recentHistory.length}', sub: 'recent jobs', color: const Color(0xFF10B981))),
            ]),
          ],
        );
      }
      return Row(
        children: [
          Expanded(child: _StatCard(icon: Iconsax.cpu, label: 'Machines Active', value: '2', sub: 'of 5 total', color: Colors.teal)),
          const SizedBox(width: 14),
          Expanded(child: _StatCard(icon: Iconsax.document_download, label: 'Pending', value: '${_pendingRequests.length}', sub: 'requests', color: const Color(0xFFF59E0B))),
          const SizedBox(width: 14),
          Expanded(child: _StatCard(icon: Iconsax.calendar_1, label: "Today's Schedules", value: '${_todaySchedule.length}', sub: 'appointments', color: const Color(0xFF3B82F6))),
          const SizedBox(width: 14),
          Expanded(child: _StatCard(icon: Iconsax.tick_circle, label: 'Completed', value: '${_recentHistory.length}', sub: 'recent jobs', color: const Color(0xFF10B981))),
        ],
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final String sub;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111111),
                    height: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  sub,
                  style: TextStyle(
                    fontSize: 10,
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pending Requests card
// ─────────────────────────────────────────────────────────────────────────────

class _PendingRequestsCard extends StatelessWidget {
  const _PendingRequestsCard();

  @override
  Widget build(BuildContext context) {
    return _DashCard(
      title: 'Pending Requests',
      icon: Iconsax.document_download,
      count: _pendingRequests.length,
      child: Column(
        children: [
          ..._pendingRequests.map((r) => _RequestRow(request: r)),
        ],
      ),
    );
  }
}

class _RequestRow extends StatelessWidget {
  const _RequestRow({required this.request});
  final _RequestItem request;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // File extension badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: request.color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Iconsax.document_text, size: 20, color: request.color),
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                    decoration: BoxDecoration(
                      color: request.color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      request.file.split('.').last.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 6,
                          fontWeight: FontWeight.w800,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.id,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: request.color,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  request.file,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111111),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${request.user}  ·  ${request.material}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₱${request.total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                request.timeAgo,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Today's Schedule card
// ─────────────────────────────────────────────────────────────────────────────

class _TodayScheduleCard extends StatelessWidget {
  const _TodayScheduleCard();

  @override
  Widget build(BuildContext context) {
    return _DashCard(
      title: "Today's Schedule",
      icon: Iconsax.calendar_1,
      count: _todaySchedule.length,
      child: Column(
        children: _todaySchedule
            .map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 44,
                        decoration: BoxDecoration(
                          color: s.color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.title,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111111),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(children: [
                              Icon(Iconsax.clock,
                                  size: 10, color: Colors.grey.shade400),
                              const SizedBox(width: 4),
                              Text(s.time,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500)),
                              if (s.user != null) ...[
                                Text('  ·  ',
                                    style: TextStyle(
                                        color: Colors.grey.shade400)),
                                Expanded(
                                  child: Text(s.user!,
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade500),
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Machine status card
// ─────────────────────────────────────────────────────────────────────────────

class _MachineStatusCard extends StatelessWidget {
  const _MachineStatusCard();

  static const _items = [
    (name: 'Ender-3 V3 SE',     status: 'In Use',      color: Color(0xFF3B82F6)),
    (name: 'Saturn 3 Ultra',     status: 'Available',   color: Color(0xFF22C55E)),
    (name: 'Wash & Cure 3 Plus', status: 'Maintenance', color: Color(0xFFF59E0B)),
    (name: 'X1 Carbon',          status: 'Available',   color: Color(0xFF22C55E)),
    (name: 'Einstar Scanner',    status: 'Available',   color: Color(0xFF22C55E)),
  ];

  @override
  Widget build(BuildContext context) {
    return _DashCard(
      title: 'Machine Status',
      icon: Iconsax.cpu,
      child: Column(
        children: _items
            .map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: m.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          m.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF111111),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: m.color.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          m.status,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: m.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recent History card
// ─────────────────────────────────────────────────────────────────────────────

class _RecentHistoryCard extends StatelessWidget {
  const _RecentHistoryCard();

  @override
  Widget build(BuildContext context) {
    return _DashCard(
      title: 'Recent History',
      icon: Iconsax.clock,
      count: _recentHistory.length,
      child: Column(
        children: _recentHistory.map((h) => _HistoryRow(item: h)).toList(),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.item});
  final _HistoryItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Avatar circle with initials
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.statusColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                item.user.split(' ').map((e) => e[0]).take(2).join(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: item.statusColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.id,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: item.statusColor,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  item.file,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111111),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${item.user}  ·  ${item.completedAt}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₱${item.total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: item.statusColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: item.statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared card container
// ─────────────────────────────────────────────────────────────────────────────

class _DashCard extends StatelessWidget {
  const _DashCard({
    required this.title,
    required this.icon,
    required this.child,
    this.count,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Row(
            children: [
              Icon(icon, size: 15, color: Colors.grey.shade500),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111111),
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: Colors.grey.shade100),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
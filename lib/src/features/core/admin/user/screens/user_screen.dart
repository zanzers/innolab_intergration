import 'package:flutter/material.dart';

part 'user_screen_web.dart';
part 'user_screen_mobile.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────
class _UC {
  static const bg           = Color(0xFFF4F6FB);
  static const surface      = Colors.white;
  static const border       = Color(0xFFE8ECF4);
  static const indigo       = Color(0xFF4F46E5);
  static const indigoLight  = Color(0xFFEEF2FF);
  static const emerald      = Color(0xFF10B981);
  static const emeraldLight = Color(0xFFD1FAE5);
  static const rose         = Color(0xFFF43F5E);
  static const roseLight    = Color(0xFFFFE4E6);
  static const amber        = Color(0xFFF59E0B);
  static const amberLight   = Color(0xFFFEF3C7);
  static const violet       = Color(0xFF8B5CF6);
  static const violetLight  = Color(0xFFEDE9FE);
  static const sky          = Color(0xFF0EA5E9);
  static const skyLight     = Color(0xFFE0F2FE);
  static const slate        = Color(0xFF64748B);
  static const slateLight   = Color(0xFFF1F5F9);
  static const textPrimary  = Color(0xFF0F172A);
  static const textSecondary= Color(0xFF64748B);
  static const textMuted    = Color(0xFF94A3B8);
}

// ─────────────────────────────────────────────
//  ENUMS & MODELS
// ─────────────────────────────────────────────
enum UserAccountStatus { active, suspended, inactive }

class PrintRequest {
  final String id;
  final String fileName;
  final String material;
  final String color;
  final String status;
  final DateTime submittedAt;
  final String? assignedStaff;
  final double? estimatedCost;

  const PrintRequest({
    required this.id,
    required this.fileName,
    required this.material,
    required this.color,
    required this.status,
    required this.submittedAt,
    this.assignedStaff,
    this.estimatedCost,
  });
}

class AppUser {
  final String id;
  final String name;
  final String email;
  final String type;
  final UserAccountStatus accountStatus;
  final DateTime joinedAt;
  final DateTime lastActivity;
  final int totalRequests;
  final int completedPrints;
  final int pendingRequests;
  final double totalSpent;
  final List<PrintRequest> recentRequests;
  final Color avatarColor;
  // Monthly print counts Jan–Jun (for activity chart)
  final List<int> monthlyPrints;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.type,
    required this.accountStatus,
    required this.joinedAt,
    required this.lastActivity,
    required this.totalRequests,
    required this.completedPrints,
    required this.pendingRequests,
    required this.totalSpent,
    required this.recentRequests,
    required this.avatarColor,
    required this.monthlyPrints,
  });

  bool get isActive => accountStatus == UserAccountStatus.active;

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return name[0];
  }

  // Top 3 materials from recent requests
  List<String> get topMaterials {
    final counts = <String, int>{};
    for (final r in recentRequests) {
      counts[r.material] = (counts[r.material] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).map((e) => e.key).toList();
  }

  AppUser copyWith({UserAccountStatus? accountStatus}) => AppUser(
    id: id, name: name, email: email, type: type,
    accountStatus: accountStatus ?? this.accountStatus,
    joinedAt: joinedAt, lastActivity: lastActivity,
    totalRequests: totalRequests, completedPrints: completedPrints,
    pendingRequests: pendingRequests, totalSpent: totalSpent,
    recentRequests: recentRequests, avatarColor: avatarColor,
    monthlyPrints: monthlyPrints,
  );
}

// ─────────────────────────────────────────────
//  SAMPLE DATA
// ─────────────────────────────────────────────
final _now = DateTime.now();

List<AppUser> _buildSampleUsers() => [
  AppUser(
    id: 'USR-001', name: 'John Doe', email: 'john.doe@company.com',
    type: 'Client', accountStatus: UserAccountStatus.active,
    joinedAt: DateTime(2023, 3, 14),
    lastActivity: _now.subtract(const Duration(hours: 2)),
    totalRequests: 38, completedPrints: 34, pendingRequests: 2, totalSpent: 420.50,
    avatarColor: _UC.indigo, monthlyPrints: [4, 6, 8, 5, 9, 6],
    recentRequests: [
      PrintRequest(id: 'REQ-001', fileName: 'mounting_bracket_v4.stl', material: 'PLA', color: 'Black', status: 'Pending', submittedAt: _now.subtract(const Duration(hours: 2)), assignedStaff: 'Mike Johnson', estimatedCost: 14.50),
      PrintRequest(id: 'REQ-009', fileName: 'enclosure_lid.stl', material: 'PETG', color: 'Clear', status: 'Completed', submittedAt: _now.subtract(const Duration(days: 2)), assignedStaff: 'Sarah Wilson', estimatedCost: 22.00),
      PrintRequest(id: 'REQ-017', fileName: 'gear_prototype.stl', material: 'ABS', color: 'Grey', status: 'Completed', submittedAt: _now.subtract(const Duration(days: 5)), assignedStaff: 'Mike Johnson', estimatedCost: 18.75),
    ],
  ),
  AppUser(
    id: 'USR-002', name: 'Jane Smith', email: 'jane.smith@company.com',
    type: 'Student', accountStatus: UserAccountStatus.active,
    joinedAt: DateTime(2022, 11, 2),
    lastActivity: _now.subtract(const Duration(hours: 5)),
    totalRequests: 72, completedPrints: 69, pendingRequests: 1, totalSpent: 1240.00,
    avatarColor: _UC.violet, monthlyPrints: [10, 14, 12, 16, 11, 9],
    recentRequests: [
      PrintRequest(id: 'REQ-002', fileName: 'phone_case_prototype.stl', material: 'TPU', color: 'Blue', status: 'Printing', submittedAt: _now.subtract(const Duration(hours: 5)), assignedStaff: 'Sarah Wilson', estimatedCost: 9.90),
      PrintRequest(id: 'REQ-011', fileName: 'product_mockup_v2.stl', material: 'PLA', color: 'White', status: 'Completed', submittedAt: _now.subtract(const Duration(days: 1)), assignedStaff: 'Nina Patel', estimatedCost: 31.00),
      PrintRequest(id: 'REQ-021', fileName: 'handle_ergonomic.stl', material: 'PETG', color: 'Black', status: 'Completed', submittedAt: _now.subtract(const Duration(days: 3)), assignedStaff: 'Mike Johnson', estimatedCost: 16.25),
    ],
  ),
  AppUser(
    id: 'USR-003', name: 'Robert Brown', email: 'r.brown@company.com',
    type: 'Businessman', accountStatus: UserAccountStatus.suspended,
    joinedAt: DateTime(2024, 1, 20),
    lastActivity: _now.subtract(const Duration(days: 8)),
    totalRequests: 14, completedPrints: 11, pendingRequests: 0, totalSpent: 175.25,
    avatarColor: _UC.sky, monthlyPrints: [2, 3, 1, 4, 2, 2],
    recentRequests: [
      PrintRequest(id: 'REQ-003', fileName: 'sensor_housing.stl', material: 'ABS', color: 'Grey', status: 'Rejected', submittedAt: _now.subtract(const Duration(hours: 8)), assignedStaff: 'Mike Johnson', estimatedCost: null),
      PrintRequest(id: 'REQ-014', fileName: 'test_rig_base.stl', material: 'PLA', color: 'Red', status: 'Completed', submittedAt: _now.subtract(const Duration(days: 4)), assignedStaff: 'David Chen', estimatedCost: 27.50),
    ],
  ),
  AppUser(
    id: 'USR-004', name: 'Emily Davis', email: 'emily.d@company.com',
    type: 'Marketing', accountStatus: UserAccountStatus.active,
    joinedAt: DateTime(2023, 7, 8),
    lastActivity: _now.subtract(const Duration(hours: 12)),
    totalRequests: 9, completedPrints: 7, pendingRequests: 1, totalSpent: 98.00,
    avatarColor: _UC.emerald, monthlyPrints: [1, 2, 1, 1, 2, 2],
    recentRequests: [
      PrintRequest(id: 'REQ-004', fileName: 'display_stand_logo.stl', material: 'PLA', color: 'White', status: 'Pending', submittedAt: _now.subtract(const Duration(hours: 12)), assignedStaff: 'Unassigned', estimatedCost: 11.00),
      PrintRequest(id: 'REQ-019', fileName: 'promo_figurine.stl', material: 'PLA', color: 'Blue', status: 'Completed', submittedAt: _now.subtract(const Duration(days: 6)), assignedStaff: 'Lisa Garcia', estimatedCost: 19.50),
    ],
  ),
  AppUser(
    id: 'USR-005', name: 'Michael Lee', email: 'mlee@company.com',
    type: 'Engineering', accountStatus: UserAccountStatus.active,
    joinedAt: DateTime(2022, 5, 30),
    lastActivity: _now.subtract(const Duration(days: 1)),
    totalRequests: 55, completedPrints: 52, pendingRequests: 0, totalSpent: 860.75,
    avatarColor: _UC.amber, monthlyPrints: [8, 10, 9, 11, 8, 9],
    recentRequests: [
      PrintRequest(id: 'REQ-005', fileName: 'drone_frame_v7.stl', material: 'Carbon PLA', color: 'Black', status: 'Completed', submittedAt: _now.subtract(const Duration(days: 1)), assignedStaff: 'Sarah Wilson', estimatedCost: 48.00),
      PrintRequest(id: 'REQ-023', fileName: 'motor_mount.stl', material: 'ABS', color: 'Grey', status: 'Completed', submittedAt: _now.subtract(const Duration(days: 3)), assignedStaff: 'Nina Patel', estimatedCost: 22.50),
    ],
  ),
  AppUser(
    id: 'USR-006', name: 'Clara Nguyen', email: 'clara.n@company.com',
    type: 'Architecture', accountStatus: UserAccountStatus.inactive,
    joinedAt: DateTime(2023, 2, 11),
    lastActivity: _now.subtract(const Duration(days: 30)),
    totalRequests: 41, completedPrints: 40, pendingRequests: 0, totalSpent: 990.00,
    avatarColor: _UC.rose, monthlyPrints: [7, 8, 6, 9, 5, 5],
    recentRequests: [
      PrintRequest(id: 'REQ-033', fileName: 'scale_model_wing_A.stl', material: 'PLA', color: 'White', status: 'Completed', submittedAt: _now.subtract(const Duration(days: 14)), assignedStaff: 'Mike Johnson', estimatedCost: 56.00),
    ],
  ),
];

// ─────────────────────────────────────────────
//  RESPONSIVE ENTRY POINT
// ─────────────────────────────────────────────
class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, c) {
      if (c.maxWidth >= 768) return const _WebUserView();
      return const _MobileUserView();
    });
  }
}

// ─────────────────────────────────────────────
//  SHARED STATE MIXIN
// ─────────────────────────────────────────────
mixin _UserStateMixin<T extends StatefulWidget> on State<T> {
  late List<AppUser> users;
  String searchQuery  = '';
  String statusFilter = 'All';
  AppUser? selectedUser;

  static const statusFilters = ['All', 'Active', 'Suspended', 'Inactive'];

  @override
  void initState() {
    super.initState();
    users = _buildSampleUsers();
  }

  List<AppUser> get filteredUsers => users.where((u) {
    final q = searchQuery.toLowerCase();
    final matchSearch = q.isEmpty ||
        u.name.toLowerCase().contains(q) ||
        u.email.toLowerCase().contains(q) ||
        u.type.toLowerCase().contains(q) ||
        u.id.toLowerCase().contains(q);
    final matchStatus = statusFilter == 'All' ||
        (statusFilter == 'Active'    && u.accountStatus == UserAccountStatus.active)    ||
        (statusFilter == 'Suspended' && u.accountStatus == UserAccountStatus.suspended) ||
        (statusFilter == 'Inactive'  && u.accountStatus == UserAccountStatus.inactive);
    return matchSearch && matchStatus;
  }).toList();

  // ── Aggregated stats ──
  int get activeCount    => users.where((u) => u.accountStatus == UserAccountStatus.active).length;
  int get suspendedCount => users.where((u) => u.accountStatus == UserAccountStatus.suspended).length;
  int get totalRequests  => users.fold(0, (s, u) => s + u.totalRequests);
  int get totalPending   => users.fold(0, (s, u) => s + u.pendingRequests);
  double get totalRevenue => users.fold(0.0, (s, u) => s + u.totalSpent);

  // ── Actions ──
  void suspendUser(String id) {
    setState(() {
      users = users.map((u) => u.id == id
          ? u.copyWith(accountStatus: UserAccountStatus.suspended) : u).toList();
      if (selectedUser?.id == id) selectedUser = users.firstWhere((u) => u.id == id);
    });
  }

  void reactivateUser(String id) {
    setState(() {
      users = users.map((u) => u.id == id
          ? u.copyWith(accountStatus: UserAccountStatus.active) : u).toList();
      if (selectedUser?.id == id) selectedUser = users.firstWhere((u) => u.id == id);
    });
  }
}

// ─────────────────────────────────────────────
//  SHARED: USER DETAIL CONTENT
// ─────────────────────────────────────────────
class _SharedUserDetail extends StatelessWidget {
  final AppUser user;
  final VoidCallback? onClose;
  final VoidCallback onSuspend;
  final VoidCallback onReactivate;

  const _SharedUserDetail({
    required this.user,
    this.onClose,
    required this.onSuspend,
    required this.onReactivate,
  });

  @override
  Widget build(BuildContext context) {
    final sm = _accountStatusMeta(user.accountStatus);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Header ──
        Row(children: [
          const Text('User Detail',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _UC.textPrimary)),
          const Spacer(),
          if (onClose != null)
            GestureDetector(onTap: onClose, child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: _UC.bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: _UC.border)),
              child: const Icon(Icons.close_rounded, size: 16, color: _UC.textSecondary))),
        ]),
        const SizedBox(height: 20),

        // ── Avatar + name ──
        Center(child: Column(children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: user.isActive ? user.avatarColor.withOpacity(0.15) : _UC.slateLight,
            child: Text(user.initials, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                color: user.isActive ? user.avatarColor : _UC.textMuted)),
          ),
          const SizedBox(height: 12),
          Text(user.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _UC.textPrimary)),
          const SizedBox(height: 4),
          Text(user.email, style: const TextStyle(fontSize: 12, color: _UC.textMuted)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: sm.light, borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 6, height: 6, decoration: BoxDecoration(color: sm.color, shape: BoxShape.circle)),
              const SizedBox(width: 5),
              Text(sm.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: sm.color)),
            ]),
          ),
        ])),
        const SizedBox(height: 20),
        const Divider(height: 1, color: _UC.border),
        const SizedBox(height: 16),

        // ── Info rows ──
        _DetailRow(icon: Icons.business_center_rounded, label: 'Type',        value: user.type),
        _DetailRow(icon: Icons.badge_rounded,            label: 'User ID',     value: user.id, mono: true),
        _DetailRow(icon: Icons.calendar_today_rounded,   label: 'Member since',value: _fmtDate(user.joinedAt)),
        _DetailRow(icon: Icons.access_time_rounded,      label: 'Last Active', value: _timeAgo(user.lastActivity),
            valueColor: _lastActivityColor(user.lastActivity)),
        const SizedBox(height: 16),
        const Divider(height: 1, color: _UC.border),
        const SizedBox(height: 16),

        // ── Print Statistics ──
        const _SectionTitle('Print Statistics'),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _StatBox(label: 'Total',     value: user.totalRequests.toString(),  color: _UC.indigo)),
          const SizedBox(width: 10),
          Expanded(child: _StatBox(label: 'Completed', value: user.completedPrints.toString(), color: _UC.emerald)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _StatBox(label: 'Pending',    value: user.pendingRequests.toString(),           color: _UC.amber)),
          const SizedBox(width: 10),
          Expanded(child: _StatBox(label: 'Total Spent',value: '₱${user.totalSpent.toStringAsFixed(0)}', color: _UC.violet)),
        ]),
        const SizedBox(height: 16),
        const Divider(height: 1, color: _UC.border),
        const SizedBox(height: 16),

        // ── Top Materials ──
        const _SectionTitle('Top Materials Used'),
        const SizedBox(height: 10),
        _TopMaterialsWidget(materials: user.topMaterials),
        const SizedBox(height: 16),
        const Divider(height: 1, color: _UC.border),
        const SizedBox(height: 16),

        // ── Print Activity Chart ──
        const _SectionTitle('Print Activity (Jan–Jun)'),
        const SizedBox(height: 12),
        _PrintActivityChart(monthlyPrints: user.monthlyPrints),
        const SizedBox(height: 16),
        const Divider(height: 1, color: _UC.border),
        const SizedBox(height: 16),

        // ── Recent Requests ──
        const _SectionTitle('Recent Requests'),
        const SizedBox(height: 10),
        ...user.recentRequests.map((r) => _RequestCard(request: r)),
        const SizedBox(height: 16),
        const Divider(height: 1, color: _UC.border),
        const SizedBox(height: 16),

        // ── Download Report ──
        const _SectionTitle('User Report'),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _DownloadBtn(label: 'Export PDF', icon: Icons.picture_as_pdf_rounded, color: _UC.rose)),
          const SizedBox(width: 8),
          Expanded(child: _DownloadBtn(label: 'Export CSV', icon: Icons.table_chart_rounded, color: _UC.emerald)),
        ]),
        const SizedBox(height: 16),
        const Divider(height: 1, color: _UC.border),
        const SizedBox(height: 16),

        // ── Suspend / Reactivate ──
        const _SectionTitle('Account Actions'),
        const SizedBox(height: 10),
        if (user.accountStatus != UserAccountStatus.suspended)
          SizedBox(width: double.infinity, child: OutlinedButton.icon(
            onPressed: onSuspend,
            icon: const Icon(Icons.block_rounded, size: 16),
            label: const Text('Suspend User'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _UC.rose, side: const BorderSide(color: _UC.rose),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          ))
        else
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: onReactivate,
            icon: const Icon(Icons.check_circle_rounded, size: 16),
            label: const Text('Reactivate User'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _UC.emerald, foregroundColor: Colors.white, elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          )),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED: TOP MATERIALS
// ─────────────────────────────────────────────
class _TopMaterialsWidget extends StatelessWidget {
  final List<String> materials;
  const _TopMaterialsWidget({required this.materials});

  @override
  Widget build(BuildContext context) {
    if (materials.isEmpty) {
      return const Text('No data', style: TextStyle(fontSize: 12, color: _UC.textMuted));
    }
    final colors = [_UC.indigo, _UC.emerald, _UC.amber];
    return Row(
      children: materials.asMap().entries.map((e) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
              color: colors[e.key % 3].withOpacity(0.08),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: colors[e.key % 3].withOpacity(0.2))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 8, height: 8, margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(color: colors[e.key % 3], shape: BoxShape.circle)),
            Text(e.value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                color: colors[e.key % 3])),
          ]),
        ),
      )).toList(),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED: PRINT ACTIVITY CHART (bar)
// ─────────────────────────────────────────────
class _PrintActivityChart extends StatelessWidget {
  final List<int> monthlyPrints;
  const _PrintActivityChart({required this.monthlyPrints});

  @override
  Widget build(BuildContext context) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    final maxVal = monthlyPrints.fold(0, (m, v) => v > m ? v : m).toDouble();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: _UC.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _UC.border)),
      child: Column(
        children: monthlyPrints.asMap().entries.map((e) {
          final frac = maxVal > 0 ? e.value / maxVal : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              SizedBox(width: 32, child: Text(months[e.key],
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _UC.textSecondary))),
              const SizedBox(width: 8),
              Expanded(
                child: LayoutBuilder(builder: (_, c) => Stack(children: [
                  Container(height: 18, width: c.maxWidth,
                      decoration: BoxDecoration(color: _UC.border, borderRadius: BorderRadius.circular(4))),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                    height: 18,
                    width: c.maxWidth * frac,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [_UC.indigo, _UC.violet]),
                        borderRadius: BorderRadius.circular(4)),
                  ),
                ])),
              ),
              const SizedBox(width: 8),
              SizedBox(width: 20, child: Text('${e.value}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _UC.textPrimary))),
            ]),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED: REQUEST CARD
// ─────────────────────────────────────────────
class _RequestCard extends StatelessWidget {
  final PrintRequest request;
  const _RequestCard({required this.request});

  static ({Color color, Color light, IconData icon}) _meta(String s) => switch (s) {
    'Approved'  => (color: _UC.emerald, light: _UC.emeraldLight, icon: Icons.check_circle_rounded),
    'Rejected'  => (color: _UC.rose,    light: _UC.roseLight,    icon: Icons.cancel_rounded),
    'Pending'   => (color: _UC.amber,   light: _UC.amberLight,   icon: Icons.hourglass_top_rounded),
    'Printing'  => (color: _UC.indigo,  light: _UC.indigoLight,  icon: Icons.print_rounded),
    'Completed' => (color: _UC.sky,     light: _UC.skyLight,     icon: Icons.task_alt_rounded),
    _           => (color: _UC.textMuted, light: _UC.bg,         icon: Icons.help_rounded),
  };

  @override
  Widget build(BuildContext context) {
    final m = _meta(request.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: _UC.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _UC.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(color: m.light, borderRadius: BorderRadius.circular(6)),
              child: Icon(m.icon, size: 13, color: m.color)),
          const SizedBox(width: 8),
          Expanded(child: Text(request.fileName,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _UC.textPrimary, fontFamily: 'monospace'),
              overflow: TextOverflow.ellipsis)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(color: m.light, borderRadius: BorderRadius.circular(6)),
            child: Text(request.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: m.color))),
        ]),
        const SizedBox(height: 7),
        Row(children: [
          _MiniTag(label: request.material, icon: Icons.layers_rounded),
          const SizedBox(width: 6),
          _MiniTag(label: request.color, icon: Icons.circle, iconColor: _colorFromName(request.color)),
          const Expanded(child: SizedBox()),
          if (request.estimatedCost != null)
            Text('₱${request.estimatedCost!.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _UC.violet, fontFamily: 'monospace')),
        ]),
        const SizedBox(height: 5),
        Row(children: [
          const Icon(Icons.access_time_rounded, size: 10, color: _UC.textMuted),
          const SizedBox(width: 4),
          Text(_timeAgo(request.submittedAt), style: const TextStyle(fontSize: 10, color: _UC.textMuted)),
          if (request.assignedStaff != null && request.assignedStaff != 'Unassigned') ...[
            const SizedBox(width: 8),
            const Icon(Icons.person_outline_rounded, size: 10, color: _UC.textMuted),
            const SizedBox(width: 3),
            Text(request.assignedStaff!, style: const TextStyle(fontSize: 10, color: _UC.textMuted)),
          ],
        ]),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED SMALL WIDGETS
// ─────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _UC.textPrimary));
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final bool mono;
  final Color? valueColor;
  const _DetailRow({required this.icon, required this.label, required this.value, this.mono = false, this.valueColor});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Icon(icon, size: 14, color: _UC.textMuted),
      const SizedBox(width: 8),
      Text(label, style: const TextStyle(fontSize: 12, color: _UC.textSecondary, fontWeight: FontWeight.w500)),
      const Expanded(child: SizedBox()),
      Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
          color: valueColor ?? _UC.textPrimary, fontFamily: mono ? 'monospace' : null)),
    ]),
  );
}

class _StatBox extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatBox({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(color: color.withOpacity(0.07), borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.15))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color, letterSpacing: -0.5)),
      Text(label, style: const TextStyle(fontSize: 11, color: _UC.textMuted)),
    ]),
  );
}

class _MiniTag extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? iconColor;
  const _MiniTag({required this.label, required this.icon, this.iconColor});
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 10, color: iconColor ?? _UC.textMuted),
    const SizedBox(width: 3),
    Text(label, style: const TextStyle(fontSize: 10, color: _UC.textSecondary)),
  ]);
}

class _DownloadBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _DownloadBtn({required this.label, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {},
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
          color: color.withOpacity(0.07), borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2))),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 7),
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
      ]),
    ),
  );
}

class _SummaryCard extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _SummaryCard({required this.label, required this.value, required this.color, required this.icon});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _UC.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))]),
    child: Row(children: [
      Container(padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 15, color: color)),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: color, letterSpacing: -0.4)),
        Text(label, style: const TextStyle(fontSize: 11, color: _UC.textMuted)),
      ]),
    ]),
  ));
}

// ─────────────────────────────────────────────
//  META / HELPERS
// ─────────────────────────────────────────────
({Color color, Color light, String label}) _accountStatusMeta(UserAccountStatus s) => switch (s) {
  UserAccountStatus.active    => (color: _UC.emerald, light: _UC.emeraldLight, label: 'Active'),
  UserAccountStatus.suspended => (color: _UC.rose,    light: _UC.roseLight,    label: 'Suspended'),
  UserAccountStatus.inactive  => (color: _UC.textMuted, light: _UC.slateLight, label: 'Inactive'),
};

Color _lastActivityColor(DateTime dt) {
  final days = DateTime.now().difference(dt).inDays;
  if (days == 0) return _UC.emerald;
  if (days <= 3) return _UC.amber;
  return _UC.rose;
}

Color _colorFromName(String name) => switch (name.toLowerCase()) {
  'black' => Colors.black87,
  'white' => Colors.grey.shade300,
  'red'   => Colors.red,
  'blue'  => Colors.blue,
  'grey'  => Colors.grey,
  'clear' => Colors.cyan.shade200,
  _       => _UC.textMuted,
};

String _fmtDate(DateTime dt) {
  const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  return '${m[dt.month - 1]} ${dt.day}, ${dt.year}';
}

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours   < 24) return '${diff.inHours}h ago';
  if (diff.inDays    < 30) return '${diff.inDays}d ago';
  return '${(diff.inDays / 30).floor()}mo ago';
}
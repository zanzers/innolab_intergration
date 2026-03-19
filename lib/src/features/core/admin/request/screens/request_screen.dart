import 'dart:async';
import 'package:flutter/material.dart';

part 'request_screen_web.dart';
part 'request_screen_mobile.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────
class _RC {
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
  static const teal         = Color(0xFF14B8A6);
  static const tealLight    = Color(0xFFCCFBF1);
  static const slate        = Color(0xFF64748B);
  static const slateLight   = Color(0xFFF1F5F9);
  static const textPrimary  = Color(0xFF0F172A);
  static const textSecondary= Color(0xFF64748B);
  static const textMuted    = Color(0xFF94A3B8);
}

// ─────────────────────────────────────────────
//  ENUMS
// ─────────────────────────────────────────────
enum RequestType { machineUsage, maintenance, machineRepair, training, materialAccess }
enum RequestStatus {
  pendingStaff,      // waiting for staff review
  staffRejected,     // staff rejected → closed
  staffApproved,     // staff approved → system check next
  systemChecking,    // running conflict / availability check
  conflict,          // conflict detected → needs admin
  adminPending,      // awaiting admin decision (with countdown)
  autoApproved,      // system auto-approved → scheduled
  adminApproved,     // admin manually approved → scheduled
  adminRejected,     // admin rejected → closed
  scheduled,         // fully approved + added to schedule
}
enum ConflictType { machineReserved, maintenanceScheduled, staffUnavailable }
enum AdminNotifType { conflict, machineFailure, maintenanceRequest, overdueApproval }

// ─────────────────────────────────────────────
//  APPROVAL RULES
//  machineUsage → auto approve if no conflict
//  maintenance / machineRepair → always admin
//  training / materialAccess → auto approve if no conflict
// ─────────────────────────────────────────────
bool _requiresAdminByType(RequestType t) =>
    t == RequestType.maintenance || t == RequestType.machineRepair;

// ─────────────────────────────────────────────
//  MODELS
// ─────────────────────────────────────────────
class RequestConflict {
  final ConflictType type;
  final String detail;
  const RequestConflict({required this.type, required this.detail});
}

class MachineRequest {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final RequestType type;
  final String machineName;
  final String machineId;
  final DateTime requestedStart;
  final DateTime requestedEnd;
  final String notes;
  final String? staffName;        // who reviewed at staff level
  final DateTime submittedAt;
  final DateTime? staffReviewedAt;
  final DateTime? adminPendingAt; // when it entered adminPending state
  final List<RequestConflict> conflicts;
  final String? rejectionReason;
  RequestStatus status;

  MachineRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.type,
    required this.machineName,
    required this.machineId,
    required this.requestedStart,
    required this.requestedEnd,
    required this.notes,
    required this.submittedAt,
    required this.status,
    this.staffName,
    this.staffReviewedAt,
    this.adminPendingAt,
    this.conflicts = const [],
    this.rejectionReason,
  });

  Duration get duration => requestedEnd.difference(requestedStart);

  /// Minutes since this request entered adminPending state.
  int get minutesPendingAdmin {
    if (adminPendingAt == null) return 0;
    return DateTime.now().difference(adminPendingAt!).inMinutes;
  }

  /// Auto-approve fires after 10 min admin inactivity (demo: 2 min).
  static const autoApproveAfterMinutes = 10;

  bool get isAutoApprovable =>
      !_requiresAdminByType(type) && conflicts.isEmpty;

  MachineRequest copyWith({
    RequestStatus? status,
    String? staffName,
    DateTime? staffReviewedAt,
    DateTime? adminPendingAt,
    List<RequestConflict>? conflicts,
    String? rejectionReason,
  }) => MachineRequest(
    id: id, userId: userId, userName: userName, userEmail: userEmail,
    type: type, machineName: machineName, machineId: machineId,
    requestedStart: requestedStart, requestedEnd: requestedEnd,
    notes: notes, submittedAt: submittedAt,
    status: status ?? this.status,
    staffName: staffName ?? this.staffName,
    staffReviewedAt: staffReviewedAt ?? this.staffReviewedAt,
    adminPendingAt: adminPendingAt ?? this.adminPendingAt,
    conflicts: conflicts ?? this.conflicts,
    rejectionReason: rejectionReason ?? this.rejectionReason,
  );
}

class AdminNotification {
  final String id;
  final AdminNotifType type;
  final String title;
  final String body;
  final String? requestId;
  final DateTime createdAt;
  bool isRead;

  AdminNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.requestId,
    required this.createdAt,
    this.isRead = false,
  });
}

// ─────────────────────────────────────────────
//  SAMPLE DATA
// ─────────────────────────────────────────────
final _now = DateTime.now();

List<MachineRequest> _buildSampleRequests() => [
  // Auto-approved (machine usage, no conflict)
  MachineRequest(
    id: 'REQ-001', userId: 'USR-042', userName: 'John Doe',
    userEmail: 'john.doe@innolab.ph',
    type: RequestType.machineUsage, machineName: 'Bambu X1 Carbon',
    machineId: 'MCH-001',
    requestedStart: DateTime(_now.year, _now.month, _now.day, 10, 0),
    requestedEnd:   DateTime(_now.year, _now.month, _now.day, 12, 0),
    notes: 'Print PLA bracket for robotics club prototype.',
    submittedAt: _now.subtract(const Duration(hours: 2)),
    staffName: 'Mike Johnson',
    staffReviewedAt: _now.subtract(const Duration(hours: 1, minutes: 45)),
    status: RequestStatus.autoApproved,
  ),
  // Admin-pending (maintenance request, admin overdue ~15 min)
  MachineRequest(
    id: 'REQ-002', userId: 'USR-018', userName: 'Emily Davis',
    userEmail: 'emily.davis@innolab.ph',
    type: RequestType.maintenance, machineName: 'Creality K1 Max',
    machineId: 'MCH-003',
    requestedStart: _now.add(const Duration(days: 2)),
    requestedEnd:   _now.add(const Duration(days: 2, hours: 3)),
    notes: 'Extruder needs full inspection and nozzle replacement.',
    submittedAt: _now.subtract(const Duration(minutes: 25)),
    staffName: 'Sarah Wilson',
    staffReviewedAt: _now.subtract(const Duration(minutes: 18)),
    adminPendingAt: _now.subtract(const Duration(minutes: 15)),
    status: RequestStatus.adminPending,
  ),
  // Conflict detected → needs admin
  MachineRequest(
    id: 'REQ-003', userId: 'USR-055', userName: 'Michael Lee',
    userEmail: 'michael.lee@innolab.ph',
    type: RequestType.machineUsage, machineName: 'Voron 2.4 R2',
    machineId: 'MCH-004',
    requestedStart: DateTime(_now.year, _now.month, _now.day + 1, 9, 0),
    requestedEnd:   DateTime(_now.year, _now.month, _now.day + 1, 13, 0),
    notes: 'Need Voron for drone frame carbon PLA print — 4h session.',
    submittedAt: _now.subtract(const Duration(hours: 1)),
    staffName: 'Nina Patel',
    staffReviewedAt: _now.subtract(const Duration(minutes: 50)),
    adminPendingAt: _now.subtract(const Duration(minutes: 48)),
    status: RequestStatus.conflict,
    conflicts: const [
      RequestConflict(type: ConflictType.machineReserved,
          detail: 'Voron 2.4 R2 already reserved 9AM–1PM by Sarah Wilson (JOB-880)'),
      RequestConflict(type: ConflictType.maintenanceScheduled,
          detail: 'Preventive maintenance scheduled for +9 days (SCH-001)'),
    ],
  ),
  // Pending staff review
  MachineRequest(
    id: 'REQ-004', userId: 'USR-031', userName: 'Jane Smith',
    userEmail: 'jane.smith@innolab.ph',
    type: RequestType.machineUsage, machineName: 'Elegoo Saturn 4',
    machineId: 'MCH-005',
    requestedStart: DateTime(_now.year, _now.month, _now.day + 1, 14, 0),
    requestedEnd:   DateTime(_now.year, _now.month, _now.day + 1, 16, 0),
    notes: 'Resin miniature print for design class presentation.',
    submittedAt: _now.subtract(const Duration(minutes: 10)),
    status: RequestStatus.pendingStaff,
  ),
  // Admin manually approved (machine repair)
  MachineRequest(
    id: 'REQ-005', userId: 'USR-007', userName: 'Robert Brown',
    userEmail: 'robert.brown@innolab.ph',
    type: RequestType.machineRepair, machineName: 'Sinterit Lisa Pro',
    machineId: 'MCH-006',
    requestedStart: _now.add(const Duration(days: 1, hours: 8)),
    requestedEnd:   _now.add(const Duration(days: 1, hours: 14)),
    notes: 'Laser module replacement. Parts already in storage.',
    submittedAt: _now.subtract(const Duration(hours: 5)),
    staffName: 'David Chen',
    staffReviewedAt: _now.subtract(const Duration(hours: 4)),
    adminPendingAt: _now.subtract(const Duration(hours: 3, minutes: 55)),
    status: RequestStatus.adminApproved,
  ),
  // Staff rejected
  MachineRequest(
    id: 'REQ-006', userId: 'USR-088', userName: 'Alex Turner',
    userEmail: 'alex.turner@innolab.ph',
    type: RequestType.machineUsage, machineName: 'xTool D1 Pro',
    machineId: 'MCH-007',
    requestedStart: DateTime(_now.year, _now.month, _now.day, 8, 0),
    requestedEnd:   DateTime(_now.year, _now.month, _now.day, 9, 0),
    notes: 'Laser cut acrylic panel for personal project.',
    submittedAt: _now.subtract(const Duration(hours: 3)),
    staffName: 'Lisa Garcia',
    staffReviewedAt: _now.subtract(const Duration(hours: 2, minutes: 45)),
    status: RequestStatus.staffRejected,
    rejectionReason: 'Machine already booked for lab use. Please rebook tomorrow.',
  ),
  // Auto-approved earlier today
  MachineRequest(
    id: 'REQ-007', userId: 'USR-023', userName: 'Nina Cruz',
    userEmail: 'nina.cruz@innolab.ph',
    type: RequestType.materialAccess, machineName: 'Bambu P1S',
    machineId: 'MCH-008',
    requestedStart: DateTime(_now.year, _now.month, _now.day, 13, 0),
    requestedEnd:   DateTime(_now.year, _now.month, _now.day, 15, 30),
    notes: 'PETG enclosure print for electronics housing.',
    submittedAt: _now.subtract(const Duration(hours: 4)),
    staffName: 'Mike Johnson',
    staffReviewedAt: _now.subtract(const Duration(hours: 3, minutes: 30)),
    status: RequestStatus.autoApproved,
  ),
  // Pending admin — maintenance (admin pending 3 min — still has time)
  MachineRequest(
    id: 'REQ-008', userId: 'USR-061', userName: 'David Reyes',
    userEmail: 'david.reyes@innolab.ph',
    type: RequestType.maintenance, machineName: 'Prusa MK4',
    machineId: 'MCH-002',
    requestedStart: _now.add(const Duration(days: 3)),
    requestedEnd:   _now.add(const Duration(days: 3, minutes: 45)),
    notes: 'PEI plate worn out again. Need replacement + recalibration.',
    submittedAt: _now.subtract(const Duration(minutes: 8)),
    staffName: 'Sarah Wilson',
    staffReviewedAt: _now.subtract(const Duration(minutes: 5)),
    adminPendingAt: _now.subtract(const Duration(minutes: 3)),
    status: RequestStatus.adminPending,
  ),
  // Admin rejected
  MachineRequest(
    id: 'REQ-009', userId: 'USR-044', userName: 'Chloe Tan',
    userEmail: 'chloe.tan@innolab.ph',
    type: RequestType.machineRepair, machineName: 'Elegoo Saturn 4',
    machineId: 'MCH-005',
    requestedStart: _now.add(const Duration(days: 1)),
    requestedEnd:   _now.add(const Duration(days: 1, hours: 2)),
    notes: 'FEP film replacement request.',
    submittedAt: _now.subtract(const Duration(hours: 6)),
    staffName: 'Lisa Garcia',
    staffReviewedAt: _now.subtract(const Duration(hours: 5, minutes: 30)),
    adminPendingAt: _now.subtract(const Duration(hours: 5, minutes: 25)),
    status: RequestStatus.adminRejected,
    rejectionReason: 'FEP replacement already scheduled for this week (LOG-006). No additional repair needed.',
  ),
  // Scheduled (auto-approved + added to calendar)
  MachineRequest(
    id: 'REQ-010', userId: 'USR-019', userName: 'James Park',
    userEmail: 'james.park@innolab.ph',
    type: RequestType.machineUsage, machineName: 'Bambu X1 Carbon',
    machineId: 'MCH-001',
    requestedStart: DateTime(_now.year, _now.month, _now.day + 2, 9, 0),
    requestedEnd:   DateTime(_now.year, _now.month, _now.day + 2, 11, 0),
    notes: 'Carbon PLA phone stand batch — 12 units.',
    submittedAt: _now.subtract(const Duration(hours: 8)),
    staffName: 'Mike Johnson',
    staffReviewedAt: _now.subtract(const Duration(hours: 7, minutes: 50)),
    status: RequestStatus.scheduled,
  ),
];

List<AdminNotification> _buildSampleNotifs() => [
  AdminNotification(
    id: 'NOTIF-001', type: AdminNotifType.conflict,
    title: 'Schedule Conflict Detected',
    body: 'REQ-003 (Michael Lee) conflicts with existing Voron 2.4 R2 reservation. Admin review required.',
    requestId: 'REQ-003',
    createdAt: _now.subtract(const Duration(minutes: 48)),
  ),
  AdminNotification(
    id: 'NOTIF-002', type: AdminNotifType.maintenanceRequest,
    title: 'Maintenance Request Awaiting Approval',
    body: 'REQ-002 Creality K1 Max maintenance has been pending for 15 minutes.',
    requestId: 'REQ-002',
    createdAt: _now.subtract(const Duration(minutes: 15)),
  ),
  AdminNotification(
    id: 'NOTIF-003', type: AdminNotifType.overdueApproval,
    title: 'Overdue Admin Approval',
    body: 'REQ-002 will be auto-approved in ${MachineRequest.autoApproveAfterMinutes - 15} minutes if no action is taken.',
    requestId: 'REQ-002',
    createdAt: _now.subtract(const Duration(minutes: 5)),
  ),
  AdminNotification(
    id: 'NOTIF-004', type: AdminNotifType.machineFailure,
    title: 'Machine Failure Reported',
    body: 'Sinterit Lisa Pro reported broken. REQ-005 repair request submitted by staff.',
    requestId: 'REQ-005',
    createdAt: _now.subtract(const Duration(hours: 3, minutes: 55)),
    isRead: true,
  ),
];

// ─────────────────────────────────────────────
//  RESPONSIVE ENTRY POINT
// ─────────────────────────────────────────────
class RequestScreen extends StatelessWidget {
  const RequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth >= 768) return const _WebRequestView();
      return const _MobileRequestView();
    });
  }
}

// ─────────────────────────────────────────────
//  SHARED STATE MIXIN
// ─────────────────────────────────────────────
mixin _RequestStateMixin<T extends StatefulWidget> on State<T> {
  late List<MachineRequest> requests;
  late List<AdminNotification> notifs;
  Timer? _autoApproveTimer;
  Timer? _ticker; // 1-second ticker to update countdown displays

  // filters
  RequestStatus? statusFilter;
  RequestType?   typeFilter;
  String         searchQuery = '';

  @override
  void initState() {
    super.initState();
    requests = _buildSampleRequests();
    notifs   = _buildSampleNotifs();
    _startAutoApproveTimer();
    _startTicker();
  }

  @override
  void dispose() {
    _autoApproveTimer?.cancel();
    _ticker?.cancel();
    super.dispose();
  }

  void _startTicker() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  void _startAutoApproveTimer() {
    _autoApproveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      bool changed = false;
      final updated = requests.map((r) {
        if (r.status == RequestStatus.adminPending &&
            r.isAutoApprovable &&
            r.minutesPendingAdmin >= MachineRequest.autoApproveAfterMinutes) {
          changed = true;
          _addNotif(AdminNotification(
            id: 'NOTIF-${DateTime.now().millisecondsSinceEpoch}',
            type: AdminNotifType.overdueApproval,
            title: 'Auto-Approved (Admin Timeout)',
            body: '${r.id} (${r.userName}) for ${r.machineName} was auto-approved after ${MachineRequest.autoApproveAfterMinutes} min.',
            requestId: r.id,
            createdAt: DateTime.now(),
          ));
          return r.copyWith(status: RequestStatus.autoApproved);
        }
        return r;
      }).toList();
      if (changed) setState(() => requests = updated);
    });
  }

  void _addNotif(AdminNotification n) {
    notifs = [n, ...notifs];
  }

  // ── ANALYTICS ──────────────────────────────
  int get totalToday {
    final cutoff = DateTime(_now.year, _now.month, _now.day);
    return requests.where((r) => r.submittedAt.isAfter(cutoff)).length;
  }
  int get autoApprovedCount =>
      requests.where((r) => r.status == RequestStatus.autoApproved || r.status == RequestStatus.scheduled).length;
  int get staffRejectedCount =>
      requests.where((r) => r.status == RequestStatus.staffRejected).length;
  int get adminApprovedCount =>
      requests.where((r) => r.status == RequestStatus.adminApproved).length;
  int get adminPendingCount =>
      requests.where((r) => r.status == RequestStatus.adminPending || r.status == RequestStatus.conflict).length;
  int get unreadNotifCount => notifs.where((n) => !n.isRead).length;

  List<MachineRequest> get filteredRequests {
    var list = List<MachineRequest>.from(requests);
    if (statusFilter != null) list = list.where((r) => r.status == statusFilter).toList();
    if (typeFilter != null)   list = list.where((r) => r.type   == typeFilter).toList();
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where((r) =>
        r.userName.toLowerCase().contains(q) ||
        r.machineName.toLowerCase().contains(q) ||
        r.id.toLowerCase().contains(q)).toList();
    }
    list.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    return list;
  }

  List<MachineRequest> get pendingAdminList =>
      requests.where((r) => r.status == RequestStatus.adminPending || r.status == RequestStatus.conflict)
          .toList()..sort((a, b) => a.submittedAt.compareTo(b.submittedAt));

  // ── ACTIONS ────────────────────────────────
  void adminApprove(String id) {
    setState(() {
      requests = requests.map((r) => r.id == id ? r.copyWith(status: RequestStatus.adminApproved) : r).toList();
    });
  }

  void adminReject(String id, String reason) {
    setState(() {
      requests = requests.map((r) => r.id == id
          ? r.copyWith(status: RequestStatus.adminRejected, rejectionReason: reason)
          : r).toList();
    });
  }

  void markNotifRead(String id) {
    setState(() {
      notifs = notifs.map((n) => n.id == id ? (n..isRead = true) : n).toList();
    });
  }

  void markAllNotifsRead() {
    setState(() {
      for (final n in notifs) { n.isRead = true; }
    });
  }

  void clearFilters() => setState(() { statusFilter = null; typeFilter = null; searchQuery = ''; });
}

// ─────────────────────────────────────────────
//  SHARED: REQUEST DETAIL CONTENT
// ─────────────────────────────────────────────
class _SharedRequestDetail extends StatefulWidget {
  final MachineRequest request;
  final VoidCallback? onClose;
  final void Function(String id) onApprove;
  final void Function(String id, String reason) onReject;

  const _SharedRequestDetail({
    required this.request,
    this.onClose,
    required this.onApprove,
    required this.onReject,
  });

  @override
  State<_SharedRequestDetail> createState() => _SharedRequestDetailState();
}

class _SharedRequestDetailState extends State<_SharedRequestDetail> {
  final _rejectCtrl = TextEditingController();
  bool _showRejectField = false;

  @override
  void dispose() { _rejectCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    final sm = _statusMeta(r.status);
    final tm = _typeMeta(r.type);
    final canAct = r.status == RequestStatus.adminPending || r.status == RequestStatus.conflict;
    final minsLeft = MachineRequest.autoApproveAfterMinutes - r.minutesPendingAdmin;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Header ──
        Row(children: [
          const Text('Request Detail',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _RC.textPrimary)),
          const Spacer(),
          if (widget.onClose != null)
            GestureDetector(
              onTap: widget.onClose,
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: _RC.bg, borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _RC.border)),
                child: const Icon(Icons.close_rounded, size: 16, color: _RC.textSecondary)),
            ),
        ]),
        const SizedBox(height: 16),

        // ── Flow Stepper ──
        _FlowStepper(request: r),
        const SizedBox(height: 16),

        // ── Status + type badges ──
        Wrap(spacing: 8, runSpacing: 6, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(color: sm.light, borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(sm.icon, size: 12, color: sm.color),
              const SizedBox(width: 5),
              Text(sm.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: sm.color)),
            ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(color: tm.light, borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(tm.icon, size: 12, color: tm.color),
              const SizedBox(width: 5),
              Text(tm.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: tm.color)),
            ])),
          if (_requiresAdminByType(r.type))
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(color: _RC.roseLight, borderRadius: BorderRadius.circular(8)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.shield_rounded, size: 12, color: _RC.rose),
                SizedBox(width: 5),
                Text('Admin Required', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _RC.rose)),
              ])),
        ]),
        const SizedBox(height: 14),

        // ── Request info ──
        _ReqRow(icon: Icons.badge_rounded, label: 'Request ID', value: r.id, mono: true),
        _ReqRow(icon: Icons.person_rounded, label: 'Requested by', value: r.userName),
        _ReqRow(icon: Icons.email_rounded, label: 'Email', value: r.userEmail),
        _ReqRow(icon: Icons.precision_manufacturing_rounded, label: 'Machine', value: r.machineName),
        _ReqRow(icon: Icons.calendar_today_rounded, label: 'Date', value: _fmtDate(r.requestedStart)),
        _ReqRow(icon: Icons.access_time_rounded, label: 'Time',
            value: '${_fmtTime(r.requestedStart)} – ${_fmtTime(r.requestedEnd)}'),
        _ReqRow(icon: Icons.timelapse_rounded, label: 'Duration', value: _fmtDuration(r.duration)),
        if (r.notes.isNotEmpty) ...[
          const SizedBox(height: 2),
          _ReqRow(icon: Icons.notes_rounded, label: 'Notes', value: r.notes),
        ],
        if (r.staffName != null)
          _ReqRow(icon: Icons.how_to_reg_rounded, label: 'Staff Reviewer', value: r.staffName!,
              valueColor: _RC.emerald),
        if (r.rejectionReason != null)
          _ReqRow(icon: Icons.cancel_rounded, label: 'Rejection Reason',
              value: r.rejectionReason!, valueColor: _RC.rose),

        // ── Auto-approve countdown ──
        if (r.status == RequestStatus.adminPending && r.isAutoApprovable) ...[
          const SizedBox(height: 12),
          _AutoApproveCountdown(minutesLeft: minsLeft),
        ],

        // ── Conflicts ──
        if (r.conflicts.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Divider(height: 1, color: _RC.border),
          const SizedBox(height: 12),
          const Text('Conflicts Detected',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _RC.textPrimary)),
          const SizedBox(height: 8),
          ...r.conflicts.map((c) => _ConflictTile(conflict: c)),
        ],

        // ── Approval rule explanation ──
        if (canAct) ...[
          const SizedBox(height: 12),
          const Divider(height: 1, color: _RC.border),
          const SizedBox(height: 12),
          _ApprovalRuleBox(request: r),
        ],

        // ── Admin actions ──
        if (canAct) ...[
          const SizedBox(height: 16),
          if (!_showRejectField)
            Row(children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => widget.onApprove(r.id),
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _RC.emerald, foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _showRejectField = true),
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _RC.rose, side: const BorderSide(color: _RC.rose),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                ),
              ),
            ])
          else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: _RC.roseLight.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10), border: Border.all(color: _RC.rose.withOpacity(0.3))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Rejection Reason',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _RC.textPrimary)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(color: Colors.white,
                      borderRadius: BorderRadius.circular(8), border: Border.all(color: _RC.border)),
                  child: TextField(
                    controller: _rejectCtrl,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 13, color: _RC.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Explain why this request is rejected…',
                      hintStyle: TextStyle(fontSize: 13, color: _RC.textMuted),
                      border: InputBorder.none, contentPadding: EdgeInsets.all(10)),
                  ),
                ),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: ElevatedButton(
                    onPressed: () {
                      if (_rejectCtrl.text.trim().isEmpty) return;
                      widget.onReject(r.id, _rejectCtrl.text.trim());
                      setState(() => _showRejectField = false);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: _RC.rose,
                        foregroundColor: Colors.white, elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: const Text('Confirm Reject'),
                  )),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => setState(() => _showRejectField = false),
                    child: const Text('Cancel', style: TextStyle(color: _RC.textSecondary)),
                  ),
                ]),
              ]),
            ),
          ],
        ],
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED: FLOW STEPPER
// ─────────────────────────────────────────────
class _FlowStepper extends StatelessWidget {
  final MachineRequest request;
  const _FlowStepper({required this.request});

  @override
  Widget build(BuildContext context) {
    final steps = [
      _StepData(label: 'User\nSubmit', icon: Icons.person_rounded,
          done: true, active: false),
      _StepData(label: 'Staff\nReview', icon: Icons.how_to_reg_rounded,
          done: _staffDone(request.status),
          active: request.status == RequestStatus.pendingStaff,
          failed: request.status == RequestStatus.staffRejected),
      _StepData(label: 'System\nCheck', icon: Icons.fact_check_rounded,
          done: _systemDone(request.status),
          active: request.status == RequestStatus.systemChecking,
          warning: request.status == RequestStatus.conflict),
      _StepData(label: 'Approval', icon: Icons.verified_rounded,
          done: _approvalDone(request.status),
          active: request.status == RequestStatus.adminPending,
          failed: request.status == RequestStatus.adminRejected),
      _StepData(label: 'Scheduled', icon: Icons.event_available_rounded,
          done: request.status == RequestStatus.scheduled ||
                request.status == RequestStatus.autoApproved ||
                request.status == RequestStatus.adminApproved),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(color: _RC.bg, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _RC.border)),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final prevDone = steps[i ~/ 2].done;
            return Expanded(child: Container(height: 2,
                color: prevDone ? _RC.indigo : _RC.border));
          }
          final s = steps[i ~/ 2];
          Color bg = _RC.slateLight, ic = _RC.textMuted;
          if (s.failed)   { bg = _RC.roseLight;    ic = _RC.rose; }
          else if (s.warning) { bg = _RC.amberLight;   ic = _RC.amber; }
          else if (s.done)    { bg = _RC.indigoLight;  ic = _RC.indigo; }
          else if (s.active)  { bg = _RC.amberLight;   ic = _RC.amber; }
          return Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 32, height: 32,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(s.icon, size: 15, color: ic)),
            const SizedBox(height: 4),
            Text(s.label, textAlign: TextAlign.center,
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: ic)),
          ]);
        }),
      ),
    );
  }

  bool _staffDone(RequestStatus s) => [
    RequestStatus.staffApproved, RequestStatus.systemChecking,
    RequestStatus.conflict, RequestStatus.adminPending,
    RequestStatus.autoApproved, RequestStatus.adminApproved,
    RequestStatus.adminRejected, RequestStatus.scheduled,
  ].contains(s);

  bool _systemDone(RequestStatus s) => [
    RequestStatus.adminPending, RequestStatus.autoApproved,
    RequestStatus.adminApproved, RequestStatus.adminRejected,
    RequestStatus.scheduled, RequestStatus.conflict,
  ].contains(s);

  bool _approvalDone(RequestStatus s) => [
    RequestStatus.autoApproved, RequestStatus.adminApproved,
    RequestStatus.scheduled,
  ].contains(s);
}

class _StepData {
  final String label;
  final IconData icon;
  final bool done, active, failed, warning;
  const _StepData({
    required this.label, required this.icon,
    this.done = false, this.active = false,
    this.failed = false, this.warning = false,
  });
}

// ─────────────────────────────────────────────
//  SHARED: AUTO-APPROVE COUNTDOWN
// ─────────────────────────────────────────────
class _AutoApproveCountdown extends StatelessWidget {
  final int minutesLeft;
  const _AutoApproveCountdown({required this.minutesLeft});

  @override
  Widget build(BuildContext context) {
    final isUrgent = minutesLeft <= 3;
    final color = isUrgent ? _RC.rose : _RC.amber;
    final light = isUrgent ? _RC.roseLight : _RC.amberLight;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: light.withOpacity(0.6),
          borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.3))),
      child: Row(children: [
        Icon(Icons.timer_rounded, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Auto-approve in ${minutesLeft.clamp(0, 99)} min',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
          Text('System will auto-approve if no action taken.',
              style: TextStyle(fontSize: 11, color: color.withOpacity(0.8))),
        ])),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED: CONFLICT TILE
// ─────────────────────────────────────────────
class _ConflictTile extends StatelessWidget {
  final RequestConflict conflict;
  const _ConflictTile({required this.conflict});

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    switch (conflict.type) {
      case ConflictType.machineReserved:     icon = Icons.event_busy_rounded; break;
      case ConflictType.maintenanceScheduled:icon = Icons.build_rounded; break;
      case ConflictType.staffUnavailable:    icon = Icons.person_off_rounded; break;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: _RC.roseLight.withOpacity(0.4),
          borderRadius: BorderRadius.circular(9), border: Border.all(color: _RC.rose.withOpacity(0.25))),
      child: Row(children: [
        Icon(icon, size: 14, color: _RC.rose),
        const SizedBox(width: 8),
        Expanded(child: Text(conflict.detail,
            style: const TextStyle(fontSize: 12, color: _RC.textPrimary, height: 1.4))),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED: APPROVAL RULE BOX
// ─────────────────────────────────────────────
class _ApprovalRuleBox extends StatelessWidget {
  final MachineRequest request;
  const _ApprovalRuleBox({required this.request});

  @override
  Widget build(BuildContext context) {
    final isAdminRequired = _requiresAdminByType(request.type);
    final hasConflict = request.conflicts.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: _RC.indigoLight.withOpacity(0.6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _RC.indigo.withOpacity(0.2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.rule_rounded, size: 13, color: _RC.indigo),
          SizedBox(width: 5),
          Text('Approval Rule',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _RC.indigo)),
        ]),
        const SizedBox(height: 7),
        _RuleRow(
            icon: Icons.precision_manufacturing_rounded,
            label: 'Request type',
            value: _typeMeta(request.type).label,
            ok: true),
        _RuleRow(
            icon: Icons.shield_rounded,
            label: 'Admin required by type',
            value: isAdminRequired ? 'Yes — always admin' : 'No — can auto',
            ok: !isAdminRequired),
        _RuleRow(
            icon: Icons.event_available_rounded,
            label: 'Schedule conflict',
            value: hasConflict ? '${request.conflicts.length} conflict(s) found' : 'None detected',
            ok: !hasConflict),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
              color: isAdminRequired || hasConflict ? _RC.amberLight : _RC.emeraldLight,
              borderRadius: BorderRadius.circular(7)),
          child: Text(
            isAdminRequired || hasConflict
                ? '⚠ Admin decision required'
                : '✓ Eligible for auto-approval — currently in queue',
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700,
                color: isAdminRequired || hasConflict ? _RC.amber : _RC.emerald)),
        ),
      ]),
    );
  }
}

class _RuleRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final bool ok;
  const _RuleRow({required this.icon, required this.label, required this.value, required this.ok});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Row(children: [
      Icon(icon, size: 11, color: _RC.textMuted),
      const SizedBox(width: 5),
      Expanded(child: Text(label, style: const TextStyle(fontSize: 11, color: _RC.textSecondary))),
      Icon(ok ? Icons.check_circle_rounded : Icons.cancel_rounded, size: 13,
          color: ok ? _RC.emerald : _RC.rose),
      const SizedBox(width: 4),
      Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
          color: ok ? _RC.emerald : _RC.rose)),
    ]),
  );
}

// ─────────────────────────────────────────────
//  SHARED: REQUEST CARD  (for list views)
// ─────────────────────────────────────────────
class _RequestCard extends StatelessWidget {
  final MachineRequest request;
  final VoidCallback onTap;
  final bool isSelected;
  final void Function(String) onApprove;
  final void Function(String, String) onReject;

  const _RequestCard({
    required this.request, required this.onTap, required this.onApprove,
    required this.onReject, this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final sm = _statusMeta(request.status);
    final tm = _typeMeta(request.type);
    final canAct = request.status == RequestStatus.adminPending ||
        request.status == RequestStatus.conflict;
    final minsLeft = MachineRequest.autoApproveAfterMinutes - request.minutesPendingAdmin;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isSelected ? _RC.indigoLight : Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: isSelected
                ? _RC.indigo.withOpacity(0.4)
                : request.status == RequestStatus.conflict
                    ? _RC.rose.withOpacity(0.3)
                    : _RC.border,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Row 1: ID + status + type
                Row(children: [
                  Text(request.id, style: const TextStyle(fontSize: 11, color: _RC.textMuted, fontFamily: 'monospace')),
                  const SizedBox(width: 8),
                  _SmBadge(label: tm.label, color: tm.color, light: tm.light),
                  const Spacer(),
                  _SmBadge(label: sm.label, color: sm.color, light: sm.light, icon: sm.icon),
                ]),
                const SizedBox(height: 7),
                // Row 2: user name + machine
                Row(children: [
                  _Avatar(name: request.userName, size: 26, color: _RC.indigo),
                  const SizedBox(width: 8),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(request.userName,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _RC.textPrimary)),
                    Row(children: [
                      const Icon(Icons.precision_manufacturing_rounded, size: 11, color: _RC.textMuted),
                      const SizedBox(width: 3),
                      Text(request.machineName, style: const TextStyle(fontSize: 11, color: _RC.textSecondary)),
                    ]),
                  ])),
                  // time
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(_fmtTime(request.requestedStart), style: const TextStyle(fontSize: 11, color: _RC.textSecondary)),
                    Text(_fmtDate(request.requestedStart), style: const TextStyle(fontSize: 10, color: _RC.textMuted)),
                  ]),
                ]),

                // Conflict tags
                if (request.conflicts.isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Row(children: [
                    const Icon(Icons.warning_rounded, size: 12, color: _RC.rose),
                    const SizedBox(width: 5),
                    Text('${request.conflicts.length} conflict(s) detected',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _RC.rose)),
                  ]),
                ],

                // Auto-approve countdown
                if (request.status == RequestStatus.adminPending && request.isAutoApprovable) ...[
                  const SizedBox(height: 7),
                  Row(children: [
                    Icon(Icons.timer_rounded, size: 12, color: minsLeft <= 3 ? _RC.rose : _RC.amber),
                    const SizedBox(width: 5),
                    Text('Auto-approves in ${minsLeft.clamp(0, 99)} min',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                            color: minsLeft <= 3 ? _RC.rose : _RC.amber)),
                  ]),
                ],

                // Quick action buttons
                if (canAct) ...[
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: GestureDetector(
                      onTap: () => onApprove(request.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(color: _RC.emeraldLight, borderRadius: BorderRadius.circular(8)),
                        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.check_rounded, size: 14, color: _RC.emerald),
                          SizedBox(width: 5),
                          Text('Approve', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _RC.emerald)),
                        ])),
                    )),
                    const SizedBox(width: 8),
                    Expanded(child: GestureDetector(
                      onTap: () => _showQuickRejectSheet(context, request.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(color: _RC.roseLight, borderRadius: BorderRadius.circular(8)),
                        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.close_rounded, size: 14, color: _RC.rose),
                          SizedBox(width: 5),
                          Text('Reject', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _RC.rose)),
                        ])),
                    )),
                  ]),
                ],
              ]),
          ),
        ),
      ),
    );
  }

  void _showQuickRejectSheet(BuildContext context, String id) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Reject Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _RC.textPrimary)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(color: _RC.bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: _RC.border)),
              child: TextField(
                controller: ctrl, maxLines: 3, autofocus: true,
                style: const TextStyle(fontSize: 13, color: _RC.textPrimary),
                decoration: const InputDecoration(hintText: 'Reason for rejection…',
                    hintStyle: TextStyle(fontSize: 13, color: _RC.textMuted),
                    border: InputBorder.none, contentPadding: EdgeInsets.all(12)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: () {
                if (ctrl.text.trim().isEmpty) return;
                onReject(id, ctrl.text.trim());
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: _RC.rose, foregroundColor: Colors.white,
                  elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              child: const Text('Confirm Reject'),
            )),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED: ANALYTICS STRIP
// ─────────────────────────────────────────────
class _SharedAnalyticsStrip extends StatelessWidget {
  final int todayCount, autoApproved, staffRejected, adminApproved, adminPending;
  const _SharedAnalyticsStrip({
    required this.todayCount, required this.autoApproved, required this.staffRejected,
    required this.adminApproved, required this.adminPending,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _KpiCard(label: 'Requests Today', value: todayCount.toString(), color: _RC.indigo, icon: Icons.inbox_rounded),
      const SizedBox(width: 10),
      _KpiCard(label: 'Auto Approved', value: autoApproved.toString(), color: _RC.emerald, icon: Icons.auto_awesome_rounded),
      const SizedBox(width: 10),
      _KpiCard(label: 'Staff Rejected', value: staffRejected.toString(), color: _RC.rose, icon: Icons.person_off_rounded),
      const SizedBox(width: 10),
      _KpiCard(label: 'Admin Approved', value: adminApproved.toString(), color: _RC.violet, icon: Icons.verified_rounded),
      const SizedBox(width: 10),
      _KpiCard(label: 'Needs Admin', value: adminPending.toString(), color: _RC.amber, icon: Icons.pending_actions_rounded),
    ]);
  }
}

// ─────────────────────────────────────────────
//  SHARED: NOTIFICATION PANEL
// ─────────────────────────────────────────────
class _SharedNotifPanel extends StatelessWidget {
  final List<AdminNotification> notifs;
  final ValueChanged<String> onMarkRead;
  final VoidCallback onMarkAll;

  const _SharedNotifPanel({required this.notifs, required this.onMarkRead, required this.onMarkAll});

  @override
  Widget build(BuildContext context) {
    final unread = notifs.where((n) => !n.isRead).toList();
    final read   = notifs.where((n) => n.isRead).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _RC.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
          child: Row(children: [
            const Icon(Icons.notifications_active_rounded, size: 16, color: _RC.indigo),
            const SizedBox(width: 7),
            const Text('Admin Notifications',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _RC.textPrimary)),
            const Spacer(),
            if (unread.isNotEmpty)
              TextButton(onPressed: onMarkAll,
                  child: const Text('Mark all read', style: TextStyle(fontSize: 11, color: _RC.indigo))),
          ]),
        ),
        const Divider(height: 1, color: _RC.border),
        if (unread.isNotEmpty) ...[
          Padding(padding: const EdgeInsets.fromLTRB(16, 10, 0, 4),
              child: Text('New (${unread.length})',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _RC.textMuted, letterSpacing: 0.5))),
          ...unread.map((n) => _NotifTile(notif: n, onMarkRead: onMarkRead)),
        ],
        if (read.isNotEmpty) ...[
          Padding(padding: const EdgeInsets.fromLTRB(16, 8, 0, 4),
              child: const Text('Earlier',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _RC.textMuted, letterSpacing: 0.5))),
          ...read.take(3).map((n) => _NotifTile(notif: n, onMarkRead: onMarkRead)),
        ],
      ]),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final AdminNotification notif;
  final ValueChanged<String> onMarkRead;
  const _NotifTile({required this.notif, required this.onMarkRead});

  @override
  Widget build(BuildContext context) {
    final (color, light, icon) = _notifMeta(notif.type);
    return GestureDetector(
      onTap: () => onMarkRead(notif.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
            color: notif.isRead ? Colors.transparent : color.withOpacity(0.04),
            border: const Border(bottom: BorderSide(color: _RC.border, width: 0.5))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(color: light, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 14, color: color)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(notif.title,
                  style: TextStyle(fontSize: 12, fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.w700, color: _RC.textPrimary))),
              if (!notif.isRead)
                Container(width: 7, height: 7, decoration: const BoxDecoration(color: _RC.indigo, shape: BoxShape.circle)),
            ]),
            const SizedBox(height: 2),
            Text(notif.body, style: const TextStyle(fontSize: 11, color: _RC.textSecondary, height: 1.4)),
            const SizedBox(height: 3),
            Text(_timeAgo(notif.createdAt), style: const TextStyle(fontSize: 10, color: _RC.textMuted)),
          ])),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED SMALL WIDGETS
// ─────────────────────────────────────────────
class _KpiCard extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _KpiCard({required this.label, required this.value, required this.color, required this.icon});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _RC.border),
    ),
    child: Row(children: [
      Container(padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 15, color: color)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color, letterSpacing: -0.5)),
        Text(label, style: const TextStyle(fontSize: 10, color: _RC.textMuted)),
      ])),
    ]),
  ));
}

class _SmBadge extends StatelessWidget {
  final String label;
  final Color color, light;
  final IconData? icon;
  const _SmBadge({required this.label, required this.color, required this.light, this.icon});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(color: light, borderRadius: BorderRadius.circular(6)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      if (icon != null) ...[Icon(icon!, size: 10, color: color), const SizedBox(width: 3)],
      Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    ]),
  );
}

class _ReqRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final bool mono;
  final Color? valueColor;
  const _ReqRow({required this.icon, required this.label, required this.value, this.mono = false, this.valueColor});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      Icon(icon, size: 13, color: _RC.textMuted),
      const SizedBox(width: 8),
      Text(label, style: const TextStyle(fontSize: 12, color: _RC.textSecondary)),
      const Spacer(),
      Flexible(child: Text(value, textAlign: TextAlign.right,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
              color: valueColor ?? _RC.textPrimary, fontFamily: mono ? 'monospace' : null))),
    ]),
  );
}

class _Avatar extends StatelessWidget {
  final String name;
  final double size;
  final Color color;
  const _Avatar({required this.name, required this.size, required this.color});
  @override
  Widget build(BuildContext context) {
    final initials = name.split(' ').take(2).map((p) => p.isNotEmpty ? p[0] : '').join();
    return CircleAvatar(radius: size / 2, backgroundColor: color.withOpacity(0.15),
        child: Text(initials, style: TextStyle(fontSize: size * 0.35, fontWeight: FontWeight.w800, color: color)));
  }
}

// ─────────────────────────────────────────────
//  META HELPERS
// ─────────────────────────────────────────────
({Color color, Color light, String label, IconData icon}) _statusMeta(RequestStatus s) => switch (s) {
  RequestStatus.pendingStaff   => (color: _RC.sky,    light: _RC.skyLight,    label: 'Pending Staff',    icon: Icons.hourglass_top_rounded),
  RequestStatus.staffRejected  => (color: _RC.rose,   light: _RC.roseLight,   label: 'Staff Rejected',   icon: Icons.cancel_rounded),
  RequestStatus.staffApproved  => (color: _RC.teal,   light: _RC.tealLight,   label: 'Staff Approved',   icon: Icons.how_to_reg_rounded),
  RequestStatus.systemChecking => (color: _RC.violet, light: _RC.violetLight, label: 'Checking…',        icon: Icons.fact_check_rounded),
  RequestStatus.conflict       => (color: _RC.rose,   light: _RC.roseLight,   label: 'Conflict',         icon: Icons.warning_rounded),
  RequestStatus.adminPending   => (color: _RC.amber,  light: _RC.amberLight,  label: 'Admin Pending',    icon: Icons.pending_actions_rounded),
  RequestStatus.autoApproved   => (color: _RC.emerald,light: _RC.emeraldLight,label: 'Auto Approved',    icon: Icons.auto_awesome_rounded),
  RequestStatus.adminApproved  => (color: _RC.emerald,light: _RC.emeraldLight,label: 'Admin Approved',   icon: Icons.verified_rounded),
  RequestStatus.adminRejected  => (color: _RC.rose,   light: _RC.roseLight,   label: 'Admin Rejected',   icon: Icons.block_rounded),
  RequestStatus.scheduled      => (color: _RC.indigo, light: _RC.indigoLight, label: 'Scheduled',        icon: Icons.event_available_rounded),
};

({Color color, Color light, String label, IconData icon}) _typeMeta(RequestType t) => switch (t) {
  RequestType.machineUsage   => (color: _RC.indigo, light: _RC.indigoLight, label: 'Machine Use',   icon: Icons.precision_manufacturing_rounded),
  RequestType.maintenance    => (color: _RC.amber,  light: _RC.amberLight,  label: 'Maintenance',   icon: Icons.build_rounded),
  RequestType.machineRepair  => (color: _RC.rose,   light: _RC.roseLight,   label: 'Repair',        icon: Icons.handyman_rounded),
  RequestType.training       => (color: _RC.violet, light: _RC.violetLight, label: 'Training',      icon: Icons.school_rounded),
  RequestType.materialAccess => (color: _RC.teal,   light: _RC.tealLight,   label: 'Material',      icon: Icons.inventory_2_rounded),
};

(Color, Color, IconData) _notifMeta(AdminNotifType t) => switch (t) {
  AdminNotifType.conflict          => (_RC.rose,   _RC.roseLight,   Icons.warning_rounded),
  AdminNotifType.machineFailure    => (_RC.rose,   _RC.roseLight,   Icons.error_rounded),
  AdminNotifType.maintenanceRequest=> (_RC.amber,  _RC.amberLight,  Icons.build_rounded),
  AdminNotifType.overdueApproval   => (_RC.amber,  _RC.amberLight,  Icons.timer_off_rounded),
};

// ─────────────────────────────────────────────
//  STRING HELPERS
// ─────────────────────────────────────────────
String _fmtDate(DateTime dt) {
  const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  return '${m[dt.month - 1]} ${dt.day}, ${dt.year}';
}

String _fmtTime(DateTime dt) {
  final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m ${dt.hour < 12 ? 'AM' : 'PM'}';
}

String _fmtDuration(Duration d) {
  if (d.inHours == 0) return '${d.inMinutes}min';
  final m = d.inMinutes % 60;
  return m == 0 ? '${d.inHours}h' : '${d.inHours}h ${m}m';
}

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inSeconds < 60) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours   < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}
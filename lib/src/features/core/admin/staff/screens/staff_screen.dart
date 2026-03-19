import 'package:flutter/material.dart';

part 'staff_screen_web.dart';
part 'staff_screen_mobile.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────
class _SC {
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
// "Busy" replaced with "onTravel"
enum StaffStatus { online, printing, onBreak, onTravel, offline }

enum JobStatus { printing, completed, pending, failed }

// High‑level staff activity types used to derive
// "Completed / Approved / Rejected" metrics.
enum LogType {
  completed,
  approved,
  rejected,
  printer,
}

// ─────────────────────────────────────────────
//  MODELS
// ─────────────────────────────────────────────
class PrintJob {
  final String jobId;
  final String fileName;
  final String material;
  final JobStatus status;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String printer;
  final String requestedBy;
  final String? failureReason;

  const PrintJob({
    required this.jobId,
    required this.fileName,
    required this.material,
    required this.status,
    required this.startedAt,
    this.completedAt,
    required this.printer,
    required this.requestedBy,
    this.failureReason,
  });
}

class StaffLog {
  final LogType type;
  final String message;
  final DateTime time;

  const StaffLog({
    required this.type,
    required this.message,
    required this.time,
  });
}

class StaffMember {
  final String id;
  final String name;
  final String role;
  final StaffStatus status;
  final String assignedPrinter;
  final PrintJob? activeJob;
  final List<PrintJob> todayJobs;   // full today's job log
  // Stats (derived from logs)
  final int pendingRequests;
  // Meta
  final String lastActivity;
  final String avatarInitials;
  final Color avatarColor;
  final String shiftStart;
  final String shiftEnd;
  final List<StaffLog> recentLog;

  const StaffMember({
    required this.id,
    required this.name,
    required this.role,
    required this.status,
    required this.assignedPrinter,
    this.activeJob,
    this.todayJobs = const [],
    required this.pendingRequests,
    required this.lastActivity,
    required this.avatarInitials,
    required this.avatarColor,
    required this.shiftStart,
    required this.shiftEnd,
    required this.recentLog,
  });

  // ── Derived metrics from logs ──
  int get completedToday =>
      recentLog.where((l) => l.type == LogType.completed).length;

  int get approved =>
      recentLog.where((l) => l.type == LogType.approved).length;

  int get rejected =>
      recentLog.where((l) => l.type == LogType.rejected).length;
}

class ActivityEvent {
  final String staffName;
  final String action;
  final String time;
  final IconData icon;
  final Color color;

  const ActivityEvent({
    required this.staffName,
    required this.action,
    required this.time,
    required this.icon,
    required this.color,
  });
}

// ─────────────────────────────────────────────
//  SAMPLE DATA
// ─────────────────────────────────────────────
final _now = DateTime.now();

final List<StaffMember> kStaff = [
  StaffMember(
    id: 'STF-001', name: 'Mike Johnson', role: 'Senior Operator',
    status: StaffStatus.printing, assignedPrinter: 'Bambu X1',
    activeJob: PrintJob(
      jobId: 'JOB-884', fileName: 'bracket_v3_final.stl',
      material: 'PLA · Black', status: JobStatus.printing,
      startedAt: DateTime(_now.year, _now.month, _now.day, 10, 25),
      printer: 'Bambu X1', requestedBy: 'Juan dela Cruz',
    ),
    todayJobs: [
      PrintJob(jobId: 'JOB-884', fileName: 'bracket_v3_final.stl',
        material: 'PLA · Black', status: JobStatus.printing,
        startedAt: DateTime(_now.year, _now.month, _now.day, 10, 25),
        printer: 'Bambu X1', requestedBy: 'Juan dela Cruz'),
      PrintJob(jobId: 'JOB-881', fileName: 'enclosure_base.stl',
        material: 'PLA · Black', status: JobStatus.completed,
        startedAt: DateTime(_now.year, _now.month, _now.day, 8, 30),
        completedAt: DateTime(_now.year, _now.month, _now.day, 10, 0),
        printer: 'Bambu X1', requestedBy: 'Anna Reyes'),
      PrintJob(jobId: 'JOB-877', fileName: 'gear_prototype.stl',
        material: 'PETG · White', status: JobStatus.completed,
        startedAt: DateTime(_now.year, _now.month, _now.day, 7, 0),
        completedAt: DateTime(_now.year, _now.month, _now.day, 8, 15),
        printer: 'Bambu X1', requestedBy: 'Leo Manalo'),
    ],
    pendingRequests: 2,
    lastActivity: '3 min ago', avatarInitials: 'MJ', avatarColor: _SC.indigo,
    shiftStart: '8:00 AM', shiftEnd: '5:00 PM',
    recentLog: [
      StaffLog(
        type: LogType.approved,
        message: 'Approved JOB-883 · PLA enclosure print',
        time: _now.subtract(const Duration(minutes: 6)),
      ),
      StaffLog(
        type: LogType.printer,
        message: 'Started print on Bambu X1',
        time: _now.subtract(const Duration(minutes: 3)),
      ),
      StaffLog(
        type: LogType.rejected,
        message: 'Rejected JOB-879 · file corrupted',
        time: _now.subtract(const Duration(minutes: 12)),
      ),
    ],
  ),
  StaffMember(
    id: 'STF-002', name: 'Sarah Wilson', role: 'Print Technician',
    status: StaffStatus.online, assignedPrinter: 'Prusa MK4',
    activeJob: PrintJob(
      jobId: 'JOB-891', fileName: 'phone_stand_v2.stl',
      material: 'PETG · Clear', status: JobStatus.printing,
      startedAt: DateTime(_now.year, _now.month, _now.day, 11, 10),
      printer: 'Prusa MK4', requestedBy: 'Maria Santos',
    ),
    todayJobs: [
      PrintJob(jobId: 'JOB-891', fileName: 'phone_stand_v2.stl',
        material: 'PETG · Clear', status: JobStatus.printing,
        startedAt: DateTime(_now.year, _now.month, _now.day, 11, 10),
        printer: 'Prusa MK4', requestedBy: 'Maria Santos'),
      PrintJob(jobId: 'JOB-887', fileName: 'drone_arm.stl',
        material: 'Carbon PLA', status: JobStatus.completed,
        startedAt: DateTime(_now.year, _now.month, _now.day, 9, 0),
        completedAt: DateTime(_now.year, _now.month, _now.day, 11, 0),
        printer: 'Prusa MK4', requestedBy: 'Bong Cruz'),
      PrintJob(jobId: 'JOB-882', fileName: 'wall_mount.stl',
        material: 'PLA · White', status: JobStatus.completed,
        startedAt: DateTime(_now.year, _now.month, _now.day, 7, 30),
        completedAt: DateTime(_now.year, _now.month, _now.day, 8, 50),
        printer: 'Prusa MK4', requestedBy: 'Rosa Lim'),
    ],
    pendingRequests: 1,
    lastActivity: '1 min ago', avatarInitials: 'SW', avatarColor: _SC.violet,
    shiftStart: '8:00 AM', shiftEnd: '5:00 PM',
    recentLog: [
      StaffLog(
        type: LogType.approved,
        message: 'Approved JOB-891 · phone stand print',
        time: _now.subtract(const Duration(minutes: 1)),
      ),
      StaffLog(
        type: LogType.printer,
        message: 'Loaded PETG filament on Prusa MK4',
        time: _now.subtract(const Duration(minutes: 4)),
      ),
      StaffLog(
        type: LogType.completed,
        message: 'Completed JOB-887 · drone arm',
        time: _now.subtract(const Duration(minutes: 20)),
      ),
    ],
  ),
  StaffMember(
    id: 'STF-003', name: 'David Chen', role: 'Quality Inspector',
    status: StaffStatus.online, assignedPrinter: 'Creality K1',
    activeJob: null,
    todayJobs: [
      PrintJob(jobId: 'JOB-880', fileName: 'vent_cover.stl',
        material: 'PLA · Grey', status: JobStatus.failed,
        startedAt: DateTime(_now.year, _now.month, _now.day, 9, 15),
        completedAt: DateTime(_now.year, _now.month, _now.day, 10, 30),
        printer: 'Creality K1', requestedBy: 'Dan Soriano',
        failureReason: 'Warping detected near corners'),
      PrintJob(jobId: 'JOB-878', fileName: 'cable_clip.stl',
        material: 'TPU · Black', status: JobStatus.completed,
        startedAt: DateTime(_now.year, _now.month, _now.day, 8, 0),
        completedAt: DateTime(_now.year, _now.month, _now.day, 9, 10),
        printer: 'Creality K1', requestedBy: 'Nino Garcia'),
    ],
    pendingRequests: 0,
    lastActivity: '12 min ago', avatarInitials: 'DC', avatarColor: _SC.sky,
    shiftStart: '9:00 AM', shiftEnd: '6:00 PM',
    recentLog: [
      StaffLog(
        type: LogType.printer,
        message: 'Flagged JOB-880 for re-print · warping',
        time: _now.subtract(const Duration(minutes: 12)),
      ),
      StaffLog(
        type: LogType.approved,
        message: 'Approved JOB-878 · passed QC',
        time: _now.subtract(const Duration(minutes: 30)),
      ),
      StaffLog(
        type: LogType.printer,
        message: 'Idle — waiting for next job',
        time: _now.subtract(const Duration(hours: 1)),
      ),
    ],
  ),
  StaffMember(
    id: 'STF-004', name: 'Lisa Garcia', role: 'Print Technician',
    status: StaffStatus.onBreak, assignedPrinter: 'Bambu P1S',
    activeJob: null,
    todayJobs: [
      PrintJob(jobId: 'JOB-872', fileName: 'cosplay_helmet_part.stl',
        material: 'PLA · White', status: JobStatus.completed,
        startedAt: DateTime(_now.year, _now.month, _now.day, 8, 0),
        completedAt: DateTime(_now.year, _now.month, _now.day, 10, 45),
        printer: 'Bambu P1S', requestedBy: 'Carlo Bautista'),
      PrintJob(jobId: 'JOB-869', fileName: 'mini_figurine.stl',
        material: 'Resin · Clear', status: JobStatus.completed,
        startedAt: DateTime(_now.year, _now.month, _now.day, 7, 10),
        completedAt: DateTime(_now.year, _now.month, _now.day, 7, 55),
        printer: 'Bambu P1S', requestedBy: 'Trisha Dela Cruz'),
    ],
    pendingRequests: 1,
    lastActivity: '28 min ago', avatarInitials: 'LG', avatarColor: _SC.emerald,
    shiftStart: '8:00 AM', shiftEnd: '5:00 PM',
    recentLog: [
      StaffLog(
        type: LogType.printer,
        message: 'On break',
        time: _now.subtract(const Duration(minutes: 28)),
      ),
      StaffLog(
        type: LogType.completed,
        message: 'Completed JOB-872 · cosplay helmet part',
        time: _now.subtract(const Duration(hours: 1)),
      ),
      StaffLog(
        type: LogType.printer,
        message: 'Swapped filament on Bambu P1S · PLA White',
        time: _now.subtract(const Duration(hours: 2)),
      ),
    ],
  ),
  StaffMember(
    id: 'STF-005', name: 'Alex Turner', role: 'Junior Operator',
    status: StaffStatus.onTravel, assignedPrinter: 'Voron 2.4 R2',
    activeJob: null,
    todayJobs: [
      PrintJob(jobId: 'JOB-865', fileName: 'hinge_bracket.stl',
        material: 'ABS · Black', status: JobStatus.completed,
        startedAt: DateTime(_now.year, _now.month, _now.day, 8, 0),
        completedAt: DateTime(_now.year, _now.month, _now.day, 9, 30),
        printer: 'Voron 2.4 R2', requestedBy: 'Jonah Reyes'),
    ],
    pendingRequests: 0,
    lastActivity: '1 hr ago', avatarInitials: 'AT', avatarColor: _SC.amber,
    shiftStart: '10:00 AM', shiftEnd: '7:00 PM',
    recentLog: [
      StaffLog(
        type: LogType.printer,
        message: 'Left for parts delivery',
        time: _now.subtract(const Duration(hours: 1)),
      ),
      StaffLog(
        type: LogType.completed,
        message: 'Completed JOB-865 · hinge bracket',
        time: _now.subtract(const Duration(hours: 2)),
      ),
    ],
  ),
  StaffMember(
    id: 'STF-006', name: 'Nina Patel', role: 'Senior Operator',
    status: StaffStatus.printing, assignedPrinter: 'Voron 2.4 R2',
    activeJob: PrintJob(
      jobId: 'JOB-895', fileName: 'industrial_clamp.stl',
      material: 'ABS · Grey', status: JobStatus.printing,
      startedAt: DateTime(_now.year, _now.month, _now.day, 9, 40),
      printer: 'Voron 2.4 R2', requestedBy: 'Carlos Reyes',
    ),
    todayJobs: [
      PrintJob(jobId: 'JOB-895', fileName: 'industrial_clamp.stl',
        material: 'ABS · Grey', status: JobStatus.printing,
        startedAt: DateTime(_now.year, _now.month, _now.day, 9, 40),
        printer: 'Voron 2.4 R2', requestedBy: 'Carlos Reyes'),
      PrintJob(jobId: 'JOB-892', fileName: 'custom_bracket.stl',
        material: 'PLA · Black', status: JobStatus.completed,
        startedAt: DateTime(_now.year, _now.month, _now.day, 8, 5),
        completedAt: DateTime(_now.year, _now.month, _now.day, 9, 30),
        printer: 'Voron 2.4 R2', requestedBy: 'Joseph Tan'),
      PrintJob(jobId: 'JOB-888', fileName: 'housing_v4.stl',
        material: 'PETG · Grey', status: JobStatus.completed,
        startedAt: DateTime(_now.year, _now.month, _now.day, 7, 0),
        completedAt: DateTime(_now.year, _now.month, _now.day, 8, 0),
        printer: 'Voron 2.4 R2', requestedBy: 'Mia Basco'),
      PrintJob(jobId: 'JOB-883', fileName: 'abs_enclosure.stl',
        material: 'ABS · White', status: JobStatus.completed,
        startedAt: DateTime(_now.year, _now.month, _now.day, 7, 0),
        completedAt: DateTime(_now.year, _now.month, _now.day, 7, 0),
        printer: 'Voron 2.4 R2', requestedBy: 'Rina Cruz'),
    ],
    pendingRequests: 3,
    lastActivity: 'Just now', avatarInitials: 'NP', avatarColor: _SC.rose,
    shiftStart: '7:00 AM', shiftEnd: '4:00 PM',
    recentLog: [
      StaffLog(
        type: LogType.printer,
        message: 'Printing industrial_clamp.stl on Voron 2.4 R2',
        time: _now,
      ),
      StaffLog(
        type: LogType.approved,
        message: 'Approved JOB-894 · ABS enclosure',
        time: _now.subtract(const Duration(minutes: 10)),
      ),
      StaffLog(
        type: LogType.approved,
        message: 'Approved JOB-892 · custom bracket',
        time: _now.subtract(const Duration(minutes: 25)),
      ),
    ],
  ),
  StaffMember(
    id: 'STF-007', name: 'James Park', role: 'Print Technician',
    status: StaffStatus.offline, assignedPrinter: 'Unassigned',
    activeJob: null,
    todayJobs: const [],
    pendingRequests: 0,
    lastActivity: '4 hrs ago', avatarInitials: 'JP', avatarColor: _SC.teal,
    shiftStart: '—', shiftEnd: '—',
    recentLog: [
      StaffLog(
        type: LogType.printer,
        message: 'Completed shift',
        time: _now.subtract(const Duration(hours: 4)),
      ),
      StaffLog(
        type: LogType.printer,
        message: 'Logged out',
        time: _now.subtract(const Duration(hours: 4, minutes: 5)),
      ),
    ],
  ),
];

final List<ActivityEvent> kActivityFeed = [
  ActivityEvent(staffName: 'Nina Patel',    action: 'Started printing industrial_clamp.stl',   time: 'just now', icon: Icons.print_rounded,       color: _SC.indigo),
  ActivityEvent(staffName: 'Sarah Wilson',  action: 'Loaded PETG filament on Prusa MK4',       time: '1m ago',   icon: Icons.cable_rounded,        color: _SC.sky),
  ActivityEvent(staffName: 'Mike Johnson',  action: 'Approved request REQ-884',                 time: '3m ago',   icon: Icons.check_circle_rounded, color: _SC.emerald),
  ActivityEvent(staffName: 'David Chen',    action: 'Flagged JOB-880 — warping detected',       time: '12m ago',  icon: Icons.flag_rounded,         color: _SC.amber),
  ActivityEvent(staffName: 'Lisa Garcia',   action: 'Went on break',                            time: '28m ago',  icon: Icons.coffee_rounded,       color: _SC.textMuted),
  ActivityEvent(staffName: 'Alex Turner',   action: 'Left for parts delivery',                  time: '1h ago',   icon: Icons.directions_car_rounded,color: _SC.violet),
  ActivityEvent(staffName: 'Mike Johnson',  action: 'Rejected REQ-879 — corrupted file',        time: '34m ago',  icon: Icons.cancel_rounded,       color: _SC.rose),
  ActivityEvent(staffName: 'Sarah Wilson',  action: 'Completed JOB-887 — drone arm',            time: '41m ago',  icon: Icons.task_alt_rounded,     color: _SC.emerald),
  ActivityEvent(staffName: 'Nina Patel',    action: 'Approved JOB-892 — custom bracket',        time: '55m ago',  icon: Icons.check_circle_rounded, color: _SC.emerald),
];

// ─────────────────────────────────────────────
//  RESPONSIVE ENTRY POINT
// ─────────────────────────────────────────────
class StaffScreen extends StatelessWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, c) {
      if (c.maxWidth >= 768) return const _WebStaffView();
      return const _MobileStaffView();
    });
  }
}

// ─────────────────────────────────────────────
//  SHARED STATE MIXIN
// ─────────────────────────────────────────────
mixin _StaffStateMixin<T extends StatefulWidget> on State<T> {
  String searchQuery = '';
  String statusFilter = 'All';
  StaffMember? selectedStaff;

  static const filters = ['All', 'Online', 'Printing', 'On Break', 'On Travel', 'Offline'];

  List<StaffMember> get filteredStaff => kStaff.where((s) {
    final matchFilter = statusFilter == 'All' ||
        (statusFilter == 'Online'    && s.status == StaffStatus.online)    ||
        (statusFilter == 'Printing'  && s.status == StaffStatus.printing)  ||
        (statusFilter == 'On Break'  && s.status == StaffStatus.onBreak)   ||
        (statusFilter == 'On Travel' && s.status == StaffStatus.onTravel)  ||
        (statusFilter == 'Offline'   && s.status == StaffStatus.offline);
    final q = searchQuery.toLowerCase();
    final matchSearch = q.isEmpty ||
        s.name.toLowerCase().contains(q) ||
        s.role.toLowerCase().contains(q);
    return matchFilter && matchSearch;
  }).toList();

  // ── Aggregated stats ──
  int get onlineCount    => kStaff.where((s) => s.status == StaffStatus.online).length;
  int get printingCount  => kStaff.where((s) => s.status == StaffStatus.printing).length;
  int get onBreakCount   => kStaff.where((s) => s.status == StaffStatus.onBreak).length;
  int get onTravelCount  => kStaff.where((s) => s.status == StaffStatus.onTravel).length;
  int get offlineCount   => kStaff.where((s) => s.status == StaffStatus.offline).length;
  int get completedToday => kStaff.fold(0, (s, m) => s + m.completedToday);
  int get activeJobsCount=> kStaff.where((s) => s.activeJob != null).length;
  int get pendingCount   => kStaff.fold(0, (s, m) => s + m.pendingRequests);
}

// ─────────────────────────────────────────────
//  SHARED: STAFF DETAIL CONTENT
// ─────────────────────────────────────────────
class _SharedStaffDetailContent extends StatelessWidget {
  final StaffMember member;
  final VoidCallback? onClose;
  final VoidCallback onMarkComplete;
  final VoidCallback onReportIssue;

  const _SharedStaffDetailContent({
    required this.member,
    this.onClose,
    required this.onMarkComplete,
    required this.onReportIssue,
  });

  @override
  Widget build(BuildContext context) {
    final sm = _statusMeta(member.status);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Panel header ──
        Row(children: [
          const Text('Staff Details',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _SC.textPrimary)),
          const Spacer(),
          if (onClose != null)
            GestureDetector(onTap: onClose, child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(color: _SC.bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: _SC.border)),
              child: const Icon(Icons.close_rounded, size: 16, color: _SC.textSecondary))),
        ]),
        const SizedBox(height: 18),

        // ── Active Job Card (if any) ──
        if (member.activeJob != null) ...[
          _ActiveJobDetailCard(job: member.activeJob!),
          const SizedBox(height: 18),
        ],

        // ── Staff Info ──
        _SectionTitle('Staff Info'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: _SC.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _SC.border)),
          child: Column(children: [
            _DetailRow(icon: Icons.person_rounded,            label: 'Name',    value: member.name),
            _DetailRow(icon: Icons.circle,                    label: 'Status',  value: sm.label,
                valueColor: sm.color, iconColor: sm.color),
            _DetailRow(icon: Icons.precision_manufacturing_rounded, label: 'Printer', value: member.assignedPrinter),
            _DetailRow(icon: Icons.schedule_rounded,          label: 'Shift',
                value: member.shiftStart == '—' ? 'No shift today' : '${member.shiftStart} – ${member.shiftEnd}'),
            _DetailRow(icon: Icons.access_time_rounded,       label: 'Last Activity', value: member.lastActivity, isLast: true),
          ]),
        ),
        const SizedBox(height: 16),

        // ── Current Job (extra info) ──
        if (member.activeJob != null) ...[
          _SectionTitle('Current Job'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: _SC.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _SC.border)),
            child: Column(children: [
              _DetailRow(icon: Icons.insert_drive_file_rounded, label: 'File',        value: member.activeJob!.fileName),
              _DetailRow(icon: Icons.layers_rounded,            label: 'Material',    value: member.activeJob!.material),
              _DetailRow(icon: Icons.person_outline_rounded,    label: 'Requested by',value: member.activeJob!.requestedBy, isLast: true),
            ]),
          ),
          const SizedBox(height: 16),
        ],

        // ── Today's Activity ──
        _SectionTitle("Today's Activity"),
        const SizedBox(height: 10),
        Row(children: [
          _ActivityKpi(label: 'Completed', value: member.completedToday.toString(), color: _SC.emerald, icon: Icons.task_alt_rounded),
          const SizedBox(width: 8),
          _ActivityKpi(label: 'Approved',  value: member.approved.toString(),       color: _SC.indigo,  icon: Icons.check_rounded),
          const SizedBox(width: 8),
          _ActivityKpi(label: 'Rejected',  value: member.rejected.toString(),       color: _SC.rose,    icon: Icons.close_rounded),
        ]),
        const SizedBox(height: 16),

        // ── Recent Log ──
        if (member.recentLog.isNotEmpty) ...[
          _SectionTitle('Recent Log'),
          const SizedBox(height: 10),
          ...member.recentLog.asMap().entries.map((e) {
            final log = e.value;
            final isPrimary = e.key == 0;
            return Container(
              margin: const EdgeInsets.only(bottom: 7),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: _SC.border)),
              child: Row(children: [
                Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                        color: isPrimary ? _SC.indigo : _SC.textMuted,
                        shape: BoxShape.circle)),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(log.message,
                            style: const TextStyle(
                                fontSize: 12,
                                color: _SC.textSecondary,
                                height: 1.4)),
                        const SizedBox(height: 2),
                        Text(
                          _timeAgo(log.time),
                          style: const TextStyle(
                              fontSize: 11, color: _SC.textMuted),
                        ),
                      ]),
                ),
              ]),
            );
          }),
          const SizedBox(height: 16),
        ],

        // ── Action Buttons ──
        if (member.activeJob != null)
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: onMarkComplete,
            icon: const Icon(Icons.task_alt_rounded, size: 16),
            label: const Text('Mark Complete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _SC.emerald, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0,
              textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          )),
        if (member.activeJob != null) const SizedBox(height: 8),
        SizedBox(width: double.infinity, child: OutlinedButton.icon(
          onPressed: onReportIssue,
          icon: const Icon(Icons.flag_rounded, size: 16),
          label: const Text('Report Issue'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _SC.rose, side: const BorderSide(color: _SC.rose),
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        )),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED: ACTIVE JOB DETAIL CARD
// ─────────────────────────────────────────────
class _ActiveJobDetailCard extends StatelessWidget {
  final PrintJob job;
  const _ActiveJobDetailCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final isComplete = job.status == JobStatus.completed;
    final color = isComplete ? _SC.emerald : _SC.indigo;
    final light = isComplete ? _SC.emeraldLight : _SC.indigoLight;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: light.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Status badge + filename row
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(7)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(isComplete ? Icons.check_circle_rounded : Icons.print_rounded, size: 11, color: Colors.white),
              const SizedBox(width: 4),
              Text(isComplete ? 'Completed' : 'Printing',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
            ]),
          ),
        ]),
        const SizedBox(height: 10),
        Text(job.fileName,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _SC.textPrimary, fontFamily: 'monospace')),
        const SizedBox(height: 4),
        Text(job.material, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.access_time_rounded, size: 13, color: _SC.textMuted),
          const SizedBox(width: 5),
          Text(
            isComplete
                ? 'Completed printing at ${_fmtTime(job.completedAt ?? job.startedAt)}'
                : 'Started printing at ${_fmtTime(job.startedAt)}',
            style: const TextStyle(fontSize: 12, color: _SC.textSecondary)),
        ]),
        const SizedBox(height: 4),
        Row(children: [
          const Icon(Icons.precision_manufacturing_rounded, size: 13, color: _SC.textMuted),
          const SizedBox(width: 5),
          Text('Printer: ${job.printer}', style: const TextStyle(fontSize: 12, color: _SC.textSecondary)),
        ]),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED: STAFF CARD  (shows full today's job log)
// ─────────────────────────────────────────────
class _SharedStaffCard extends StatelessWidget {
  final StaffMember member;
  final bool isSelected;
  final VoidCallback onTap;

  const _SharedStaffCard({required this.member, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sm = _statusMeta(member.status);
    final isOffline = member.status == StaffStatus.offline;
    final jobs = member.todayJobs ?? [];

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        // Fixed card height — log scrolls inside
        height: 340,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? _SC.indigo : _SC.border, width: isSelected ? 2 : 1),
          boxShadow: [BoxShadow(
            color: isSelected ? _SC.indigo.withOpacity(0.1) : Colors.black.withOpacity(0.04),
            blurRadius: isSelected ? 20 : 10, offset: const Offset(0, 3))],
        ),
        // Use a real Column with Expanded so footer is pinned to bottom
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Avatar + name + status ──
          Row(children: [
            Stack(children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: isOffline ? _SC.slateLight : member.avatarColor.withOpacity(0.15),
                child: Text(member.avatarInitials, style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w800,
                    color: isOffline ? _SC.textMuted : member.avatarColor)),
              ),
              Positioned(right: 0, bottom: 0, child: Container(
                width: 11, height: 11,
                decoration: BoxDecoration(color: sm.color, shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2)))),
            ]),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(member.name,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _SC.textPrimary),
                  overflow: TextOverflow.ellipsis),
              Text(member.role,
                  style: const TextStyle(fontSize: 11, color: _SC.textSecondary)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(color: sm.light, borderRadius: BorderRadius.circular(7)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(sm.icon, size: 10, color: sm.color),
                const SizedBox(width: 4),
                Text(sm.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: sm.color)),
              ]),
            ),
          ]),
          const SizedBox(height: 8),

          // ── Printer row ──
          Row(children: [
            const Icon(Icons.precision_manufacturing_rounded, size: 12, color: _SC.textMuted),
            const SizedBox(width: 5),
            Expanded(child: Text(member.assignedPrinter,
                style: const TextStyle(fontSize: 11, color: _SC.textSecondary),
                overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 8),

          // ── Today's Log label ──
          if (jobs.isNotEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: Text("Today's Log",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                      color: _SC.textMuted, letterSpacing: 0.4)),
            ),

          // ── Scrollable job list (fills remaining space) ──
          Expanded(
            child: jobs.isEmpty
                ? (member.activeJob != null
                    // If we have an active job but no explicit log,
                    // show the current job so it matches the detail panel.
                    ? ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          _TodayJobRow(job: member.activeJob!),
                        ],
                      )
                    : Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                            color: _SC.bg,
                            borderRadius: BorderRadius.circular(8)),
                        child: Row(children: [
                          Icon(
                              isOffline
                                  ? Icons.power_off_rounded
                                  : member.status == StaffStatus.onBreak
                                      ? Icons.coffee_rounded
                                      : member.status == StaffStatus.onTravel
                                          ? Icons.directions_car_rounded
                                          : Icons.hourglass_empty_rounded,
                              size: 12,
                              color: _SC.textMuted),
                          const SizedBox(width: 6),
                          Text(
                              isOffline
                                  ? 'Not available'
                                  : member.status == StaffStatus.onBreak
                                      ? 'On break'
                                      : member.status == StaffStatus.onTravel
                                          ? 'On travel'
                                          : 'Idle — no jobs yet',
                              style: const TextStyle(
                                  fontSize: 11, color: _SC.textMuted)),
                        ]),
                      ))
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: jobs.length,
                    itemBuilder: (_, i) => _TodayJobRow(job: jobs[i]),
                  ),
          ),

          const SizedBox(height: 10),

          // ── Footer stats + recent log preview (always visible at bottom) ──
          Row(children: [
            _MicroStat(value: member.completedToday.toString(), label: 'Completed', color: _SC.emerald),
            const SizedBox(width: 8),
            _MicroStat(value: member.approved.toString(), label: 'Approved', color: _SC.indigo),
            const SizedBox(width: 8),
            _MicroStat(value: member.rejected.toString(), label: 'Rejected', color: _SC.rose),
            const Expanded(child: SizedBox()),
            const Icon(Icons.access_time_rounded, size: 10, color: _SC.textMuted),
            const SizedBox(width: 3),
            Text(member.lastActivity, style: const TextStyle(fontSize: 10, color: _SC.textMuted)),
          ]),
          if (member.recentLog.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.history_rounded,
                    size: 10, color: _SC.textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    member.recentLog.first.message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 10, color: _SC.textSecondary),
                  ),
                ),
              ],
            ),
          ],
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TODAY JOB ROW  (single entry in today's log)
// ─────────────────────────────────────────────
class _TodayJobRow extends StatelessWidget {
  final PrintJob job;
  const _TodayJobRow({required this.job});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (job.status) {
      JobStatus.printing  => (_SC.indigo,  'Printing'),
      JobStatus.completed => (_SC.emerald, 'Finish'),
      JobStatus.failed    => (_SC.rose,    'Failed'),
      JobStatus.pending   => (_SC.amber,   'Pending'),
    };

    final timeText = job.status == JobStatus.printing
        ? 'Start printing at ${_fmtTime(job.startedAt)}'
        : job.status == JobStatus.completed
            ? 'Finish printing at ${_fmtTime(job.completedAt ?? job.startedAt)}'
            : job.status == JobStatus.failed
                ? 'Failed at ${_fmtTime(job.completedAt ?? job.startedAt)}'
                : 'Pending';

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) {
            final isPrinting = job.status == JobStatus.printing;
            final isCompleted = job.status == JobStatus.completed;
            final isFailed = job.status == JobStatus.failed;
            final statusColor = isCompleted
                ? _SC.emerald
                : isFailed
                    ? _SC.rose
                    : _SC.indigo;
            final statusLabel = isCompleted
                ? 'PRINT SUCCESS'
                : isFailed
                    ? 'PRINT FAILED'
                    : 'PRINTING';

            final timeLine = isPrinting
                ? 'Started at ${_fmtTime(job.startedAt)}'
                : isCompleted
                    ? 'Finished at ${_fmtTime(job.completedAt ?? job.startedAt)}'
                    : isFailed
                        ? 'Failed at ${_fmtTime(job.completedAt ?? job.startedAt)}'
                        : timeText;

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              contentPadding:
                  const EdgeInsets.fromLTRB(18, 18, 18, 12),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // File header row with "3D" badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: _SC.bg,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(Icons.insert_drive_file_rounded,
                            size: 16, color: _SC.textSecondary),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.fileName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: _SC.textPrimary,
                                letterSpacing: -0.2,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _SC.skyLight,
                                borderRadius:
                                    BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '3D',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: _SC.sky),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Simple visual preview area (admin can quickly see the part)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _SC.bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _SC.border),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Icon(
                          Icons.view_in_ar_rounded,
                          color: _SC.textSecondary.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Material
                  Row(
                    children: [
                      const Icon(Icons.layers_rounded,
                          size: 14, color: _SC.textMuted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Material: ${job.material}',
                          style: const TextStyle(
                              fontSize: 13,
                              color: _SC.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Printer
                  Row(
                    children: [
                      const Icon(Icons.precision_manufacturing_rounded,
                          size: 14, color: _SC.textMuted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Printer: ${job.printer}',
                          style: const TextStyle(
                              fontSize: 13,
                              color: _SC.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Time
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 14, color: _SC.textMuted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          timeLine,
                          style: const TextStyle(
                              fontSize: 13,
                              color: _SC.textSecondary),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Status pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isFailed
                              ? Icons.error_outline_rounded
                              : Icons.check_circle_rounded,
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (isFailed && job.failureReason != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      job.failureReason!,
                      style: const TextStyle(
                          fontSize: 12,
                          color: _SC.textSecondary,
                          height: 1.4),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Actions row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: color.withOpacity(0.15))),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status badge + filename
              Row(children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                      color: color, borderRadius: BorderRadius.circular(5)),
                  child: Text(label,
                      style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
                const SizedBox(width: 7),
                Expanded(
                    child: Text(job.fileName,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _SC.textPrimary,
                            fontFamily: 'monospace'),
                        overflow: TextOverflow.ellipsis)),
              ]),
              const SizedBox(height: 5),
              Row(children: [
                const Icon(Icons.layers_rounded,
                    size: 10, color: _SC.textMuted),
                const SizedBox(width: 4),
                Text(
                  job.material,
                  style: const TextStyle(
                      fontSize: 10, color: _SC.textSecondary),
                ),
              ]),
              const SizedBox(height: 2),
              Row(children: [
                const Icon(Icons.person_outline_rounded,
                    size: 10, color: _SC.textMuted),
                const SizedBox(width: 4),
                Text(
                  'Requested by ${job.requestedBy}',
                  style: const TextStyle(
                      fontSize: 10, color: _SC.textSecondary),
                ),
              ]),
              const SizedBox(height: 2),
              Row(children: [
                const Icon(Icons.access_time_rounded,
                    size: 10, color: _SC.textMuted),
                const SizedBox(width: 4),
                Text(
                  timeText,
                  style: const TextStyle(
                      fontSize: 10, color: _SC.textSecondary),
                ),
              ]),
            ]),
      ),
    );
  }
}


// ─────────────────────────────────────────────
//  SHARED: STATS STRIP  (top bar)
// ─────────────────────────────────────────────
class _SharedStatsStrip extends StatelessWidget {
  final int online, printing, onBreak, onTravel, offline, completedToday, activeJobs, pending;
  const _SharedStatsStrip({
    required this.online, required this.printing, required this.onBreak,
    required this.onTravel, required this.offline, required this.completedToday,
    required this.activeJobs, required this.pending,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        _StatChip(label: 'Online',    value: online.toString(),         color: _SC.emerald, icon: Icons.wifi_rounded),
        const SizedBox(width: 10),
        _StatChip(label: 'Printing',  value: printing.toString(),       color: _SC.indigo,  icon: Icons.print_rounded),
        const SizedBox(width: 10),
        _StatChip(label: 'On Break',  value: onBreak.toString(),        color: _SC.amber,   icon: Icons.coffee_rounded),
        const SizedBox(width: 10),
        _StatChip(label: 'On Travel', value: onTravel.toString(),       color: _SC.violet,  icon: Icons.directions_car_rounded),
        const SizedBox(width: 10),
        _StatChip(label: 'Offline',   value: offline.toString(),        color: _SC.textMuted,icon: Icons.wifi_off_rounded),
        const SizedBox(width: 10),
        _StatChip(label: 'Completed Today', value: completedToday.toString(), color: _SC.teal, icon: Icons.task_alt_rounded),
        const SizedBox(width: 10),
        _StatChip(label: 'Active Jobs',     value: activeJobs.toString(),     color: _SC.sky,  icon: Icons.layers_rounded),
        const SizedBox(width: 10),
        _StatChip(label: 'Pending',         value: pending.toString(),        color: _SC.rose, icon: Icons.pending_actions_rounded),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED: ACTIVITY FEED CONTENT
// ─────────────────────────────────────────────
class _SharedActivityFeed extends StatelessWidget {
  const _SharedActivityFeed();

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
        child: Row(children: [
          const Text('Live Activity',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _SC.textPrimary)),
          const SizedBox(width: 8),
          Container(width: 8, height: 8, decoration: const BoxDecoration(color: _SC.emerald, shape: BoxShape.circle)),
        ]),
      ),
      const Divider(height: 1, color: _SC.border),
      Expanded(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 6),
          itemCount: kActivityFeed.length,
          separatorBuilder: (_, __) => const Divider(height: 1, color: _SC.border, indent: 20, endIndent: 20),
          itemBuilder: (_, i) {
            final ev = kActivityFeed[i];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(color: ev.color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                    child: Icon(ev.icon, size: 14, color: ev.color)),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(ev.staffName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _SC.textPrimary)),
                  const SizedBox(height: 2),
                  Text(ev.action, style: const TextStyle(fontSize: 12, color: _SC.textSecondary, height: 1.4)),
                  const SizedBox(height: 4),
                  Text(ev.time, style: const TextStyle(fontSize: 11, color: _SC.textMuted)),
                ])),
              ]),
            );
          },
        ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────
//  SHARED SMALL WIDGETS
// ─────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _StatChip({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11),
        border: Border.all(color: _SC.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))]),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(7)),
          child: Icon(icon, size: 14, color: color)),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: color, letterSpacing: -0.4)),
        Text(label, style: const TextStyle(fontSize: 11, color: _SC.textMuted)),
      ]),
    ]),
  );
}

class _MicroStat extends StatelessWidget {
  final String value, label;
  final Color color;
  const _MicroStat({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Row(children: [
    Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
    const SizedBox(width: 3),
    Text(label, style: const TextStyle(fontSize: 10, color: _SC.textMuted)),
  ]);
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _SC.textPrimary));
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color? valueColor;
  final Color? iconColor;
  final bool isLast;
  const _DetailRow({required this.icon, required this.label, required this.value,
      this.valueColor, this.iconColor, this.isLast = false});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: isLast ? 0 : 9),
    child: Row(children: [
      Icon(icon, size: 13, color: iconColor ?? _SC.textMuted),
      const SizedBox(width: 8),
      Text(label, style: const TextStyle(fontSize: 12, color: _SC.textSecondary)),
      const Spacer(),
      Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
          color: valueColor ?? _SC.textPrimary)),
    ]),
  );
}

class _ActivityKpi extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _ActivityKpi({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
    decoration: BoxDecoration(color: color.withOpacity(0.07), borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.15))),
    child: Column(children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(height: 5),
      Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
      Text(label, style: const TextStyle(fontSize: 10, color: _SC.textMuted)),
    ]),
  ));
}

// ─────────────────────────────────────────────
//  META HELPERS
// ─────────────────────────────────────────────
({Color color, Color light, String label, IconData icon}) _statusMeta(StaffStatus s) =>
    switch (s) {
      StaffStatus.online   => (color: _SC.emerald, light: _SC.emeraldLight, label: 'Online',    icon: Icons.wifi_rounded),
      StaffStatus.printing => (color: _SC.indigo,  light: _SC.indigoLight,  label: 'Printing',  icon: Icons.print_rounded),
      StaffStatus.onBreak  => (color: _SC.amber,   light: _SC.amberLight,   label: 'On Break',  icon: Icons.coffee_rounded),
      StaffStatus.onTravel => (color: _SC.violet,  light: _SC.violetLight,  label: 'On Travel', icon: Icons.directions_car_rounded),
      StaffStatus.offline  => (color: _SC.textMuted, light: _SC.slateLight, label: 'Offline',   icon: Icons.wifi_off_rounded),
    };

// ─────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────
String _fmtTime(DateTime dt) {
  final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final m = dt.minute.toString().padLeft(2, '0');
  final p = dt.hour < 12 ? 'AM' : 'PM';
  return '$h:$m $p';
}

String _timeAgo(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} hr${diff.inHours > 1 ? 's' : ''} ago';
  final days = diff.inDays;
  return '$days day${days > 1 ? 's' : ''} ago';
}
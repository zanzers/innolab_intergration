import 'package:flutter/material.dart';
import 'package:innolab/src/features/core/admin/user/screens/App_schedule_store.dart';

part 'maintenance_screen_web.dart';
part 'maintenance_screen_mobile.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────
class _C {
  static const bg = Color(0xFFF4F6FB);
  static const surface = Colors.white;
  static const border = Color(0xFFE8ECF4);
  static const indigo = Color(0xFF4F46E5);
  static const indigoLight = Color(0xFFEEF2FF);
  static const emerald = Color(0xFF10B981);
  static const emeraldLight = Color(0xFFD1FAE5);
  static const rose = Color(0xFFF43F5E);
  static const roseLight = Color(0xFFFFE4E6);
  static const amber = Color(0xFFF59E0B);
  static const amberLight = Color(0xFFFEF3C7);
  static const violet = Color(0xFF8B5CF6);
  static const violetLight = Color(0xFFEDE9FE);
  static const sky = Color(0xFF0EA5E9);
  static const skyLight = Color(0xFFE0F2FE);
  static const slate = Color(0xFF64748B);
  static const slateLight = Color(0xFFF1F5F9);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textMuted = Color(0xFF94A3B8);
}

// ─────────────────────────────────────────────
//  ENUMS
// ─────────────────────────────────────────────
enum MachineStatus { operational, idle, underMaintenance, broken }
enum MachineType { printer3D, laserCutter, cnc, resinPrinter, slsPrinter, postProcessing }
enum IssuePriority { critical, high, medium, low }
enum IssueStatus { pending, inProgress, fixed }
enum ScheduleStatus { upcoming, inProgress, completed, overdue }

// ─────────────────────────────────────────────
//  MODELS
// ─────────────────────────────────────────────
class Machine {
  final String id, name, model, location;
  final MachineType type;
  final MachineStatus status;
  final DateTime lastMaintenance;
  final DateTime nextMaintenance;
  final String assignedTech;
  final double uptimePercent;
  final int totalJobs;
  final String? currentJob;
  final String? currentOperator; // person currently using it
  final String? reservedBy;      // person who has it booked next

  const Machine({
    required this.id, required this.name, required this.model,
    required this.location, required this.type, required this.status,
    required this.lastMaintenance, required this.nextMaintenance,
    required this.assignedTech, required this.uptimePercent,
    required this.totalJobs, this.currentJob,
    this.currentOperator, this.reservedBy,
  });
}

class UsageSession {
  final String id, machineId, machineName, staffName;
  final DateTime start, end;
  final String? jobId;

  const UsageSession({
    required this.id, required this.machineId, required this.machineName,
    required this.staffName, required this.start, required this.end,
    this.jobId,
  });

  Duration get duration => end.difference(start);

  bool get isThisWeek =>
      start.isAfter(DateTime.now().subtract(const Duration(days: 7)));
}

class MaintenanceLog {
  final String id, machineId, machineName, issue, workDone, technician;
  final DateTime date;
  final List<String> partsUsed;
  final Duration downtime;
  final double cost;
  const MaintenanceLog({
    required this.id, required this.machineId, required this.machineName,
    required this.issue, required this.workDone, required this.technician,
    required this.date, required this.partsUsed,
    required this.downtime, required this.cost,
  });
}

class ScheduledTask {
  final String id, machineId, machineName, taskName, assignedTo, notes;
  final DateTime scheduledDate;
  final ScheduleStatus status;
  final Duration estimatedDuration;
  const ScheduledTask({
    required this.id, required this.machineId, required this.machineName,
    required this.taskName, required this.assignedTo,
    required this.scheduledDate, required this.status,
    required this.estimatedDuration, required this.notes,
  });
}

class ReportedIssue {
  final String id, machineId, machineName, description, reportedBy;
  final IssuePriority priority;
  final IssueStatus status;
  final DateTime reportedAt;
  final String? assignedTo;
  const ReportedIssue({
    required this.id, required this.machineId, required this.machineName,
    required this.description, required this.reportedBy,
    required this.priority, required this.status,
    required this.reportedAt, this.assignedTo,
  });
}

// ─────────────────────────────────────────────
//  SAMPLE DATA
// ─────────────────────────────────────────────
final _n = DateTime.now();

final List<Machine> _machines = [
  Machine(id: 'MCH-001', name: 'Bambu X1 Carbon', model: 'Bambu Lab X1C',
    location: 'Bay A1', type: MachineType.printer3D, status: MachineStatus.operational,
    lastMaintenance: _n.subtract(const Duration(days: 14)),
    nextMaintenance: _n.add(const Duration(days: 16)),
    assignedTech: 'Mike Johnson', uptimePercent: 96.2, totalJobs: 312,
    currentJob: 'JOB-895', currentOperator: 'Nina Patel'),
  Machine(id: 'MCH-002', name: 'Prusa MK4', model: 'Prusa Research MK4',
    location: 'Bay A2', type: MachineType.printer3D, status: MachineStatus.idle,
    lastMaintenance: _n.subtract(const Duration(days: 7)),
    nextMaintenance: _n.add(const Duration(days: 23)),
    assignedTech: 'Sarah Wilson', uptimePercent: 91.5, totalJobs: 248,
    reservedBy: 'Alex Turner'),
  Machine(id: 'MCH-003', name: 'Creality K1 Max', model: 'Creality K1 Max',
    location: 'Bay A3', type: MachineType.printer3D, status: MachineStatus.underMaintenance,
    lastMaintenance: _n.subtract(const Duration(days: 1)),
    nextMaintenance: _n.add(const Duration(days: 29)),
    assignedTech: 'David Chen', uptimePercent: 78.4, totalJobs: 189,
    currentOperator: 'David Chen'),
  Machine(id: 'MCH-004', name: 'Voron 2.4 R2', model: 'Voron Design 2.4',
    location: 'Bay B1', type: MachineType.printer3D, status: MachineStatus.operational,
    lastMaintenance: _n.subtract(const Duration(days: 21)),
    nextMaintenance: _n.add(const Duration(days: 9)),
    assignedTech: 'Nina Patel', uptimePercent: 94.1, totalJobs: 276,
    currentJob: 'JOB-891', currentOperator: 'Sarah Wilson'),
  Machine(id: 'MCH-005', name: 'Elegoo Saturn 4', model: 'Elegoo Saturn 4 Ultra',
    location: 'Bay C1', type: MachineType.resinPrinter, status: MachineStatus.idle,
    lastMaintenance: _n.subtract(const Duration(days: 5)),
    nextMaintenance: _n.add(const Duration(days: 25)),
    assignedTech: 'Lisa Garcia', uptimePercent: 88.7, totalJobs: 145),
  Machine(id: 'MCH-006', name: 'Sinterit Lisa Pro', model: 'Sinterit Lisa Pro SLS',
    location: 'Vault C2', type: MachineType.slsPrinter, status: MachineStatus.broken,
    lastMaintenance: _n.subtract(const Duration(days: 3)),
    nextMaintenance: _n.subtract(const Duration(days: 1)),
    assignedTech: 'David Chen', uptimePercent: 62.0, totalJobs: 88),
  Machine(id: 'MCH-007', name: 'xTool D1 Pro', model: 'xTool D1 Pro 20W',
    location: 'Bay D1', type: MachineType.laserCutter, status: MachineStatus.operational,
    lastMaintenance: _n.subtract(const Duration(days: 10)),
    nextMaintenance: _n.add(const Duration(days: 20)),
    assignedTech: 'Mike Johnson', uptimePercent: 97.3, totalJobs: 203),
  Machine(id: 'MCH-008', name: 'Bambu P1S', model: 'Bambu Lab P1S',
    location: 'Bay A4', type: MachineType.printer3D, status: MachineStatus.operational,
    lastMaintenance: _n.subtract(const Duration(days: 18)),
    nextMaintenance: _n.add(const Duration(days: 12)),
    assignedTech: 'Sarah Wilson', uptimePercent: 93.8, totalJobs: 198,
    currentJob: 'JOB-884', currentOperator: 'Mike Johnson'),
];

// Usage sessions — designed so weekly total adds to 100%:
// MCH-001 = 10h (50%), MCH-004 = 6h (30%), MCH-008 = 4h (20%), others = 0h (0%)
// Grand total = 20h
final List<UsageSession> _usageSessions = [
  // ── MCH-001 Bambu X1 Carbon — 10h this week ──
  UsageSession(id: 'USE-001', machineId: 'MCH-001', machineName: 'Bambu X1 Carbon',
    staffName: 'Nina Patel', jobId: 'JOB-888',
    start: _n.subtract(const Duration(hours: 3)),
    end: _n.subtract(const Duration(hours: 1))),       // 2h
  UsageSession(id: 'USE-002', machineId: 'MCH-001', machineName: 'Bambu X1 Carbon',
    staffName: 'Mike Johnson', jobId: 'JOB-877',
    start: _n.subtract(const Duration(hours: 28)),
    end: _n.subtract(const Duration(hours: 24))),       // 4h
  UsageSession(id: 'USE-003', machineId: 'MCH-001', machineName: 'Bambu X1 Carbon',
    staffName: 'Sarah Wilson', jobId: 'JOB-869',
    start: _n.subtract(const Duration(hours: 53)),
    end: _n.subtract(const Duration(hours: 51))),       // 2h
  UsageSession(id: 'USE-004', machineId: 'MCH-001', machineName: 'Bambu X1 Carbon',
    staffName: 'Nina Patel', jobId: 'JOB-858',
    start: _n.subtract(const Duration(hours: 82)),
    end: _n.subtract(const Duration(hours: 80))),       // 2h

  // ── MCH-004 Voron 2.4 R2 — 6h this week ──
  UsageSession(id: 'USE-005', machineId: 'MCH-004', machineName: 'Voron 2.4 R2',
    staffName: 'Alex Turner', jobId: 'JOB-880',
    start: _n.subtract(const Duration(hours: 27)),
    end: _n.subtract(const Duration(hours: 25, minutes: 30))), // 1.5h
  UsageSession(id: 'USE-006', machineId: 'MCH-004', machineName: 'Voron 2.4 R2',
    staffName: 'Nina Patel', jobId: 'JOB-864',
    start: _n.subtract(const Duration(hours: 52)),
    end: _n.subtract(const Duration(hours: 50, minutes: 30))), // 1.5h
  UsageSession(id: 'USE-007', machineId: 'MCH-004', machineName: 'Voron 2.4 R2',
    staffName: 'Sarah Wilson', jobId: 'JOB-852',
    start: _n.subtract(const Duration(hours: 79)),
    end: _n.subtract(const Duration(hours: 76))),       // 3h

  // ── MCH-008 Bambu P1S — 4h this week ──
  UsageSession(id: 'USE-008', machineId: 'MCH-008', machineName: 'Bambu P1S',
    staffName: 'Lisa Garcia', jobId: 'JOB-872',
    start: _n.subtract(const Duration(hours: 54)),
    end: _n.subtract(const Duration(hours: 52))),       // 2h
  UsageSession(id: 'USE-009', machineId: 'MCH-008', machineName: 'Bambu P1S',
    staffName: 'Mike Johnson', jobId: 'JOB-856',
    start: _n.subtract(const Duration(hours: 80)),
    end: _n.subtract(const Duration(hours: 78))),       // 2h
];

final List<MaintenanceLog> _logs = [
  MaintenanceLog(id: 'LOG-001', machineId: 'MCH-003', machineName: 'Creality K1 Max',
    issue: 'Extruder clogging — repeated under-extrusion at layer 40+',
    workDone: 'Replaced brass nozzle 0.4mm, cold-pull cleaning, re-calibrated e-steps',
    technician: 'David Chen', date: _n.subtract(const Duration(days: 1)),
    partsUsed: ['Brass Nozzle 0.4mm', 'PTFE Tube 300mm'],
    downtime: const Duration(hours: 3), cost: 285),
  MaintenanceLog(id: 'LOG-002', machineId: 'MCH-001', machineName: 'Bambu X1 Carbon',
    issue: 'AMS filament feed error — sensor trigger false positives',
    workDone: 'Cleaned filament sensors, updated firmware to v1.8.2, recalibrated AMS hub',
    technician: 'Mike Johnson', date: _n.subtract(const Duration(days: 14)),
    partsUsed: [], downtime: const Duration(minutes: 90), cost: 0),
  MaintenanceLog(id: 'LOG-003', machineId: 'MCH-006', machineName: 'Sinterit Lisa Pro',
    issue: 'Laser module temperature sensor fault — print aborted mid-job',
    workDone: 'Replaced temperature sensor unit, ran diagnostic cycle, thermal recalibration',
    technician: 'David Chen', date: _n.subtract(const Duration(days: 3)),
    partsUsed: ['Temp Sensor Module (SLS)', 'Thermal Paste'],
    downtime: const Duration(hours: 8), cost: 3400),
  MaintenanceLog(id: 'LOG-004', machineId: 'MCH-004', machineName: 'Voron 2.4 R2',
    issue: 'Z-axis skipping steps intermittently on tall prints',
    workDone: 'Tightened Z-axis coupler, lubricated lead screw, tuned motor current via Klipper',
    technician: 'Nina Patel', date: _n.subtract(const Duration(days: 21)),
    partsUsed: ['Lubricant (PTFE)'], downtime: const Duration(hours: 2), cost: 120),
  MaintenanceLog(id: 'LOG-005', machineId: 'MCH-002', machineName: 'Prusa MK4',
    issue: 'Bed adhesion failures — PEI surface worn out',
    workDone: 'Replaced PEI build plate, full first-layer calibration',
    technician: 'Sarah Wilson', date: _n.subtract(const Duration(days: 7)),
    partsUsed: ['Build Plate PEI Sheet'], downtime: const Duration(minutes: 45), cost: 890),
  MaintenanceLog(id: 'LOG-006', machineId: 'MCH-005', machineName: 'Elegoo Saturn 4',
    issue: 'FEP film scratched — print releasing from FEP instead of plate',
    workDone: 'Replaced FEP film, resin vat cleaning with IPA, exposure recalibration',
    technician: 'Lisa Garcia', date: _n.subtract(const Duration(days: 5)),
    partsUsed: ['FEP Film 200x280mm', 'Isopropyl Alcohol 99%'],
    downtime: const Duration(hours: 1, minutes: 30), cost: 560),
];

final List<ScheduledTask> _schedule = [
  ScheduledTask(id: 'SCH-001', machineId: 'MCH-004', machineName: 'Voron 2.4 R2',
    taskName: 'Preventive — Full lubrication & belt tension check',
    assignedTo: 'Nina Patel', scheduledDate: _n.add(const Duration(days: 9)),
    status: ScheduleStatus.upcoming, estimatedDuration: const Duration(hours: 2),
    notes: 'Check all axis belts, lubricate lead screws, inspect hotend'),
  ScheduledTask(id: 'SCH-002', machineId: 'MCH-001', machineName: 'Bambu X1 Carbon',
    taskName: 'Preventive — AMS cleaning & nozzle inspection',
    assignedTo: 'Mike Johnson', scheduledDate: _n.add(const Duration(days: 16)),
    status: ScheduleStatus.upcoming, estimatedDuration: const Duration(hours: 1),
    notes: 'Deep clean AMS hub, inspect hardened nozzle wear'),
  ScheduledTask(id: 'SCH-003', machineId: 'MCH-006', machineName: 'Sinterit Lisa Pro',
    taskName: 'Corrective — Laser module replacement & full recal',
    assignedTo: 'David Chen', scheduledDate: _n.add(const Duration(days: 2)),
    status: ScheduleStatus.inProgress, estimatedDuration: const Duration(hours: 6),
    notes: 'Awaiting laser module part delivery from Sinterit. ETA 2 days'),
  ScheduledTask(id: 'SCH-004', machineId: 'MCH-008', machineName: 'Bambu P1S',
    taskName: 'Preventive — Hotend & extruder gear inspection',
    assignedTo: 'Sarah Wilson', scheduledDate: _n.add(const Duration(days: 12)),
    status: ScheduleStatus.upcoming, estimatedDuration: const Duration(minutes: 90),
    notes: 'Inspect extruder gear wear, clean hotend heatsink'),
  ScheduledTask(id: 'SCH-005', machineId: 'MCH-006', machineName: 'Sinterit Lisa Pro',
    taskName: 'Preventive — Powder chamber seal & filter replacement',
    assignedTo: 'David Chen', scheduledDate: _n.subtract(const Duration(days: 1)),
    status: ScheduleStatus.overdue, estimatedDuration: const Duration(hours: 3),
    notes: 'OVERDUE — machine is currently broken, reschedule after repair'),
  ScheduledTask(id: 'SCH-006', machineId: 'MCH-007', machineName: 'xTool D1 Pro',
    taskName: 'Preventive — Lens cleaning & rail alignment',
    assignedTo: 'Mike Johnson', scheduledDate: _n.add(const Duration(days: 20)),
    status: ScheduleStatus.upcoming, estimatedDuration: const Duration(minutes: 60),
    notes: 'Clean laser lens, check gantry squareness'),
];

final List<ReportedIssue> _issues = [
  ReportedIssue(id: 'ISS-001', machineId: 'MCH-006', machineName: 'Sinterit Lisa Pro',
    description: 'Machine stopped mid-print. Display shows TEMP_SENSOR_ERR. Print bed not heating.',
    reportedBy: 'Nina Patel', priority: IssuePriority.critical, status: IssueStatus.inProgress,
    reportedAt: _n.subtract(const Duration(days: 3)), assignedTo: 'David Chen'),
  ReportedIssue(id: 'ISS-002', machineId: 'MCH-003', machineName: 'Creality K1 Max',
    description: 'Extruder makes clicking noise and filament grinds. Print quality poor after layer 30.',
    reportedBy: 'John Doe', priority: IssuePriority.high, status: IssueStatus.inProgress,
    reportedAt: _n.subtract(const Duration(days: 1)), assignedTo: 'David Chen'),
  ReportedIssue(id: 'ISS-003', machineId: 'MCH-002', machineName: 'Prusa MK4',
    description: 'First layer not sticking. Tried re-leveling but issue persists. Wasted 3 prints.',
    reportedBy: 'Emily Davis', priority: IssuePriority.medium, status: IssueStatus.fixed,
    reportedAt: _n.subtract(const Duration(days: 7)), assignedTo: 'Sarah Wilson'),
  ReportedIssue(id: 'ISS-004', machineId: 'MCH-001', machineName: 'Bambu X1 Carbon',
    description: 'AMS showing filament run-out error even with full spool. Print pauses unexpectedly.',
    reportedBy: 'Michael Lee', priority: IssuePriority.medium, status: IssueStatus.fixed,
    reportedAt: _n.subtract(const Duration(days: 14)), assignedTo: 'Mike Johnson'),
  ReportedIssue(id: 'ISS-005', machineId: 'MCH-005', machineName: 'Elegoo Saturn 4',
    description: 'Prints releasing from FEP film rather than build plate. FEP may be cloudy.',
    reportedBy: 'Jane Smith', priority: IssuePriority.high, status: IssueStatus.fixed,
    reportedAt: _n.subtract(const Duration(days: 5)), assignedTo: 'Lisa Garcia'),
  ReportedIssue(id: 'ISS-006', machineId: 'MCH-007', machineName: 'xTool D1 Pro',
    description: 'Laser power seems weaker than usual. Cuts not going through 3mm acrylic cleanly.',
    reportedBy: 'Robert Brown', priority: IssuePriority.low, status: IssueStatus.pending,
    reportedAt: _n.subtract(const Duration(hours: 4)), assignedTo: null),
];

// ─────────────────────────────────────────────
//  RESPONSIVE ENTRY POINT
// ─────────────────────────────────────────────
class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 768) return const _WebMaintenanceView();
        return const _MobileMachineView();
      },
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED STATE MIXIN
// ─────────────────────────────────────────────
mixin _MaintenanceStateMixin<T extends StatefulWidget> on State<T> {
  Machine? selectedMachine;

  @override
  void initState() {
    super.initState();
    AppScheduleStore.instance.addListener(_onStoreChanged);
  }

  void _onStoreChanged() => setState(() {});

  @override
  void dispose() {
    AppScheduleStore.instance.removeListener(_onStoreChanged);
    super.dispose();
  }

  List<ScheduledTask> get mergedSchedule {
    final storeItems = AppScheduleStore.instance.tasks.map((t) {
      final s = switch (t.status) {
        SharedTaskStatus.upcoming   => ScheduleStatus.upcoming,
        SharedTaskStatus.inProgress => ScheduleStatus.inProgress,
        SharedTaskStatus.completed  => ScheduleStatus.completed,
        SharedTaskStatus.canceled   => ScheduleStatus.completed,
        SharedTaskStatus.overdue    => ScheduleStatus.overdue,
      };
      return ScheduledTask(id: t.id, machineId: t.machineId,
        machineName: t.machineName, taskName: t.title, assignedTo: t.assignedTo,
        scheduledDate: t.scheduledDate, status: s,
        estimatedDuration: t.estimatedDuration, notes: t.notes);
    }).toList();
    final hardcoded = _schedule.where((h) => !storeItems.any((s) => s.id == h.id)).toList();
    return [...hardcoded, ...storeItems];
  }

  /// Returns each machine's share of total weekly usage, summing to 100 %.
  Map<String, double> get weeklyUsagePercents {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final weekSessions = _usageSessions.where((s) => s.start.isAfter(cutoff)).toList();
    final machineMinutes = <String, int>{};
    for (final s in weekSessions) {
      machineMinutes[s.machineId] = (machineMinutes[s.machineId] ?? 0) + s.duration.inMinutes;
    }
    final total = machineMinutes.values.fold(0, (a, b) => a + b);
    if (total == 0) return {};
    return machineMinutes.map((id, mins) => MapEntry(id, (mins / total) * 100));
  }

  int get totalWeeklyMinutes {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return _usageSessions
        .where((s) => s.start.isAfter(cutoff))
        .fold(0, (sum, s) => sum + s.duration.inMinutes);
  }
}

// ─────────────────────────────────────────────
//  SHARED: MACHINE DETAIL CONTENT
//  (used by web side panel + mobile bottom sheet)
// ─────────────────────────────────────────────
class _SharedMachineDetailContent extends StatelessWidget {
  final Machine machine;
  final VoidCallback? onClose;

  const _SharedMachineDetailContent({required this.machine, this.onClose});

  @override
  Widget build(BuildContext context) {
    final sm = _statusMeta(machine.status);
    final ds = _displayStatus(machine);
    final machineLogs = _logs.where((l) => l.machineId == machine.id).toList();
    final machineIssues = _issues.where((i) => i.machineId == machine.id).toList();
    final machineSessions = _usageSessions.where((s) => s.machineId == machine.id).toList()
      ..sort((a, b) => b.start.compareTo(a.start));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          const Text('Machine Detail', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _C.textPrimary)),
          const Spacer(),
          if (onClose != null)
            GestureDetector(
              onTap: onClose,
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: _C.bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: _C.border)),
                child: const Icon(Icons.close_rounded, size: 16, color: _C.textSecondary),
              ),
            ),
        ]),
        const SizedBox(height: 16),

        // Machine name block
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: _C.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _C.border)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: sm.light, borderRadius: BorderRadius.circular(9)),
                child: Icon(_typeIcon(machine.type), color: sm.color, size: 18)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(machine.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _C.textPrimary)),
                Text('${machine.id}  ·  ${machine.model}', style: const TextStyle(fontSize: 11, color: _C.textMuted)),
              ])),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              _SharedStatusBadge(displayStatus: ds),
              const SizedBox(width: 8),
              _TypeBadge(type: machine.type),
            ]),
          ]),
        ),
        const SizedBox(height: 14),

        // Info rows
        _DetailRow(icon: Icons.place_rounded, label: 'Location', value: machine.location),
        _DetailRow(icon: Icons.person_rounded, label: 'Assigned Tech', value: machine.assignedTech),
        _DetailRow(icon: Icons.layers_rounded, label: 'Total Jobs', value: '${machine.totalJobs}'),
        if (machine.currentOperator != null)
          _DetailRow(icon: Icons.engineering_rounded, label: 'Currently Used By', value: machine.currentOperator!, valueColor: _C.emerald),
        if (machine.reservedBy != null)
          _DetailRow(icon: Icons.bookmark_rounded, label: 'Reserved By', value: machine.reservedBy!, valueColor: _C.sky),
        if (machine.currentJob != null)
          _DetailRow(icon: Icons.print_rounded, label: 'Active Job', value: machine.currentJob!, mono: true, valueColor: _C.indigo),

        const SizedBox(height: 4),
        // Uptime bar
        Row(children: [
          const Icon(Icons.speed_rounded, size: 13, color: _C.textMuted),
          const SizedBox(width: 8),
          const Text('Uptime', style: TextStyle(fontSize: 12, color: _C.textSecondary)),
          const Spacer(),
          Text('${machine.uptimePercent}%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
            color: machine.uptimePercent >= 90 ? _C.emerald : machine.uptimePercent >= 75 ? _C.amber : _C.rose)),
        ]),
        const SizedBox(height: 5),
        ClipRRect(borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: machine.uptimePercent / 100,
            backgroundColor: _C.border, minHeight: 6,
            valueColor: AlwaysStoppedAnimation(machine.uptimePercent >= 90 ? _C.emerald : machine.uptimePercent >= 75 ? _C.amber : _C.rose))),

        const SizedBox(height: 14),
        // Maintenance dates
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: _C.bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: _C.border)),
          child: Column(children: [
            Row(children: [
              const Icon(Icons.history_rounded, size: 13, color: _C.textMuted),
              const SizedBox(width: 6),
              const Text('Last Maintenance', style: TextStyle(fontSize: 12, color: _C.textSecondary)),
              const Spacer(),
              Text(_daysAgo(machine.lastMaintenance), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _C.textPrimary)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.event_rounded, size: 13, color: _C.textMuted),
              const SizedBox(width: 6),
              const Text('Next Maintenance', style: TextStyle(fontSize: 12, color: _C.textSecondary)),
              const Spacer(),
              Builder(builder: (_) {
                final overdue = machine.nextMaintenance.isBefore(DateTime.now());
                final days = machine.nextMaintenance.difference(DateTime.now()).inDays;
                return Text(
                  overdue ? 'OVERDUE' : 'In ${days}d',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                    color: overdue ? _C.rose : days <= 7 ? _C.amber : _C.emerald));
              }),
            ]),
          ]),
        ),

        // Usage history for this machine
        if (machineSessions.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Divider(height: 1, color: _C.border),
          const SizedBox(height: 12),
          const Text('Usage History', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _C.textPrimary)),
          const SizedBox(height: 8),
          _SharedUsageSessionTable(sessions: machineSessions),
        ],

        // Maintenance history
        if (machineLogs.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Divider(height: 1, color: _C.border),
          const SizedBox(height: 12),
          const Text('Maintenance History', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _C.textPrimary)),
          const SizedBox(height: 8),
          ...machineLogs.map((l) => _MiniLogCard(log: l)),
        ],

        // Issues
        if (machineIssues.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Divider(height: 1, color: _C.border),
          const SizedBox(height: 12),
          const Text('Reported Issues', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _C.textPrimary)),
          const SizedBox(height: 8),
          ...machineIssues.map((i) => _MiniIssueCard(issue: i)),
        ],
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED: WEEKLY USAGE CHART
// ─────────────────────────────────────────────
class _SharedWeeklyUsageChart extends StatelessWidget {
  final Map<String, double> percents; // machineId → %
  final int totalMinutes;

  const _SharedWeeklyUsageChart({required this.percents, required this.totalMinutes});

  @override
  Widget build(BuildContext context) {
    final totalHours = totalMinutes ~/ 60;
    final totalRemMins = totalMinutes % 60;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('Machine Usage This Week', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _C.textPrimary)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: _C.indigoLight, borderRadius: BorderRadius.circular(8)),
            child: Text(
              totalMinutes == 0 ? 'No usage' : 'Total: ${totalHours}h${totalRemMins > 0 ? ' ${totalRemMins}m' : ''}',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _C.indigo)),
          ),
        ]),
        const SizedBox(height: 4),
        const Text('All machines combined = 100% of usage time',
          style: TextStyle(fontSize: 11, color: _C.textMuted)),
        const SizedBox(height: 16),
        if (totalMinutes == 0)
          const Center(child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text('No usage sessions recorded this week',
              style: TextStyle(fontSize: 13, color: _C.textMuted)),
          ))
        else
          ..._machines.map((m) {
            final pct = percents[m.id] ?? 0.0;
            final mins = percents.containsKey(m.id)
                ? ((pct / 100) * totalMinutes).round() : 0;
            final h = mins ~/ 60;
            final rm = mins % 60;
            final ds = _displayStatus(m);

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(
                    child: Row(children: [
                      Container(width: 8, height: 8,
                        decoration: BoxDecoration(color: ds.color, shape: BoxShape.circle)),
                      const SizedBox(width: 7),
                      Expanded(child: Text(m.name,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _C.textPrimary),
                        overflow: TextOverflow.ellipsis)),
                    ]),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    pct == 0 ? '0%' : '${pct.toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                      color: pct == 0 ? _C.textMuted : ds.color)),
                  const SizedBox(width: 6),
                  SizedBox(width: 60,
                    child: Text(
                      pct == 0 ? '0h' : '${h}h${rm > 0 ? ' ${rm}m' : ''}',
                      style: const TextStyle(fontSize: 10, color: _C.textMuted),
                      textAlign: TextAlign.right)),
                ]),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: pct / 100,
                    backgroundColor: pct == 0 ? _C.slateLight : ds.color.withOpacity(0.12),
                    valueColor: AlwaysStoppedAnimation(pct == 0 ? _C.slateLight : ds.color),
                    minHeight: 8,
                  ),
                ),
              ]),
            );
          }),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED: USAGE SESSION TABLE  (per machine)
// ─────────────────────────────────────────────
class _SharedUsageSessionTable extends StatelessWidget {
  final List<UsageSession> sessions;
  const _SharedUsageSessionTable({required this.sessions});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _C.border),
      ),
      child: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: const BoxDecoration(color: _C.bg, borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
          child: Row(children: const [
            Expanded(flex: 3, child: _SmTH('Staff')),
            Expanded(flex: 2, child: _SmTH('Start')),
            Expanded(flex: 2, child: _SmTH('End')),
            Expanded(flex: 2, child: _SmTH('Duration')),
            Expanded(flex: 2, child: _SmTH('Job')),
          ]),
        ),
        const Divider(height: 1, color: _C.border),
        ...sessions.asMap().entries.map((e) {
          final s = e.value;
          final isEven = e.key.isEven;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: isEven ? Colors.white : _C.bg.withOpacity(0.5),
              borderRadius: e.key == sessions.length - 1
                  ? const BorderRadius.vertical(bottom: Radius.circular(10))
                  : null,
            ),
            child: Row(children: [
              Expanded(flex: 3, child: Row(children: [
                _Avatar(name: s.staffName, size: 20, color: _C.indigo),
                const SizedBox(width: 6),
                Expanded(child: Text(s.staffName.split(' ').first,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _C.textPrimary),
                  overflow: TextOverflow.ellipsis)),
              ])),
              Expanded(flex: 2, child: Text(_fmtTime(s.start),
                style: const TextStyle(fontSize: 11, color: _C.textSecondary))),
              Expanded(flex: 2, child: Text(_fmtTime(s.end),
                style: const TextStyle(fontSize: 11, color: _C.textSecondary))),
              Expanded(flex: 2, child: Text(_formatDuration(s.duration),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _C.indigo))),
              Expanded(flex: 2, child: s.jobId != null
                ? Text(s.jobId!, style: const TextStyle(fontSize: 10, color: _C.textMuted, fontFamily: 'monospace'))
                : const Text('—', style: TextStyle(fontSize: 11, color: _C.textMuted))),
            ]),
          );
        }),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED: MINI CARDS  (in detail panel)
// ─────────────────────────────────────────────
class _MiniLogCard extends StatelessWidget {
  final MaintenanceLog log;
  const _MiniLogCard({required this.log});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: _C.bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: _C.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(log.issue, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _C.textPrimary), overflow: TextOverflow.ellipsis)),
        const SizedBox(width: 8),
        Text(_fmtDate(log.date), style: const TextStyle(fontSize: 10, color: _C.textMuted)),
      ]),
      const SizedBox(height: 4),
      Text(log.workDone, style: const TextStyle(fontSize: 11, color: _C.textSecondary, height: 1.4)),
      const SizedBox(height: 6),
      Row(children: [
        _MiniMeta(icon: Icons.timer_rounded, value: _formatDuration(log.downtime)),
        const SizedBox(width: 10),
        _MiniMeta(icon: Icons.payments_rounded, value: '₱${log.cost.toStringAsFixed(0)}', color: _C.violet),
        if (log.partsUsed.isNotEmpty) ...[
          const SizedBox(width: 10),
          Expanded(child: Text(log.partsUsed.join(', '),
            style: const TextStyle(fontSize: 10, color: _C.textMuted), overflow: TextOverflow.ellipsis)),
        ],
      ]),
    ]),
  );
}

class _MiniIssueCard extends StatelessWidget {
  final ReportedIssue issue;
  const _MiniIssueCard({required this.issue});
  @override
  Widget build(BuildContext context) {
    final pm = _priorityMeta(issue.priority);
    final sm = _issueStatusMeta(issue.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: _C.bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: pm.color.withOpacity(0.2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: pm.light, borderRadius: BorderRadius.circular(5)),
            child: Text(pm.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: pm.color))),
          const SizedBox(width: 6),
          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: sm.light, borderRadius: BorderRadius.circular(5)),
            child: Text(sm.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: sm.color))),
        ]),
        const SizedBox(height: 6),
        Text(issue.description, style: const TextStyle(fontSize: 11, color: _C.textSecondary, height: 1.4)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED: FULL-SIZE CARDS  (Schedule, History, Issues)
// ─────────────────────────────────────────────
class _SharedScheduleCard extends StatelessWidget {
  final ScheduledTask task;
  const _SharedScheduleCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final sm = _scheduleMeta(task.status);
    final daysUntil = task.scheduledDate.difference(DateTime.now()).inDays;
    final isOverdue = task.status == ScheduleStatus.overdue;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isOverdue ? _C.rose.withOpacity(0.3) : _C.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(width: 52, padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: sm.light, borderRadius: BorderRadius.circular(10)),
          child: Column(children: [
            Text(_monthShort(task.scheduledDate), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: sm.color)),
            Text('${task.scheduledDate.day}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: sm.color)),
          ])),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(task.taskName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _C.textPrimary))),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: sm.light, borderRadius: BorderRadius.circular(7)),
              child: Text(sm.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: sm.color))),
          ]),
          const SizedBox(height: 4),
          Wrap(spacing: 12, children: [
            _InlineInfo(icon: Icons.precision_manufacturing_rounded, text: task.machineName),
            _InlineInfo(icon: Icons.person_rounded, text: task.assignedTo),
            _InlineInfo(icon: Icons.timer_rounded, text: _formatDuration(task.estimatedDuration)),
          ]),
          if (task.notes.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(task.notes, style: const TextStyle(fontSize: 11, color: _C.textMuted, fontStyle: FontStyle.italic)),
          ],
        ])),
        const SizedBox(width: 10),
        Text(isOverdue ? 'Overdue!' : daysUntil == 0 ? 'Today' : 'In ${daysUntil}d',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: sm.color)),
      ]),
    );
  }
}

class _SharedLogCard extends StatelessWidget {
  final MaintenanceLog log;
  const _SharedLogCard({required this.log});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _C.border),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))]),
    child: Column(children: [
      Padding(
        padding: const EdgeInsets.all(14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: _C.indigoLight, borderRadius: BorderRadius.circular(9)),
            child: const Icon(Icons.build_circle_rounded, color: _C.indigo, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(log.machineName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _C.textPrimary)),
              const SizedBox(width: 8),
              Text(log.machineId, style: const TextStyle(fontSize: 11, color: _C.textMuted, fontFamily: 'monospace')),
            ]),
            const SizedBox(height: 3),
            Text(log.issue, style: const TextStyle(fontSize: 12, color: _C.textSecondary)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(_fmtDate(log.date), style: const TextStyle(fontSize: 11, color: _C.textMuted)),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.person_rounded, size: 11, color: _C.textMuted),
              const SizedBox(width: 3),
              Text(log.technician, style: const TextStyle(fontSize: 11, color: _C.textSecondary, fontWeight: FontWeight.w600)),
            ]),
          ]),
        ]),
      ),
      Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
        decoration: const BoxDecoration(color: _C.bg, borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)), border: Border(top: BorderSide(color: _C.border))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Work Done', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _C.textMuted, letterSpacing: 0.4)),
          const SizedBox(height: 4),
          Text(log.workDone, style: const TextStyle(fontSize: 12, color: _C.textPrimary, height: 1.5)),
          const SizedBox(height: 10),
          Wrap(spacing: 16, children: [
            _MiniMeta(icon: Icons.timer_rounded, value: 'Downtime: ${_formatDuration(log.downtime)}'),
            _MiniMeta(icon: Icons.payments_rounded, value: 'Cost: ₱${log.cost.toStringAsFixed(0)}', color: _C.violet),
            if (log.partsUsed.isNotEmpty)
              _MiniMeta(icon: Icons.inventory_2_rounded, value: log.partsUsed.join(', ')),
          ]),
        ]),
      ),
    ]),
  );
}

class _SharedIssueCard extends StatelessWidget {
  final ReportedIssue issue;
  const _SharedIssueCard({required this.issue});

  @override
  Widget build(BuildContext context) {
    final pm = _priorityMeta(issue.priority);
    final sm = _issueStatusMeta(issue.status);
    final isFixed = issue.status == IssueStatus.fixed;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isFixed ? _C.border : pm.color.withOpacity(0.25)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 4, height: 64,
          decoration: BoxDecoration(color: isFixed ? _C.border : pm.color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(color: pm.light, borderRadius: BorderRadius.circular(6)),
              child: Text(pm.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: pm.color))),
            const SizedBox(width: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(color: sm.light, borderRadius: BorderRadius.circular(6)),
              child: Text(sm.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: sm.color))),
            const Spacer(),
            Text(_timeAgo(issue.reportedAt), style: const TextStyle(fontSize: 11, color: _C.textMuted)),
          ]),
          const SizedBox(height: 7),
          Row(children: [
            Text(issue.machineName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _C.textPrimary)),
            const SizedBox(width: 6),
            Text(issue.machineId, style: const TextStyle(fontSize: 11, color: _C.textMuted, fontFamily: 'monospace')),
          ]),
          const SizedBox(height: 4),
          Text(issue.description, style: const TextStyle(fontSize: 12, color: _C.textSecondary, height: 1.5)),
          const SizedBox(height: 7),
          Row(children: [
            const Icon(Icons.person_outline_rounded, size: 12, color: _C.textMuted),
            const SizedBox(width: 4),
            Text('Reported by ${issue.reportedBy}', style: const TextStyle(fontSize: 11, color: _C.textMuted)),
            if (issue.assignedTo != null) ...[
              const SizedBox(width: 12),
              const Icon(Icons.engineering_rounded, size: 12, color: _C.indigo),
              const SizedBox(width: 4),
              Text('Assigned: ${issue.assignedTo}', style: const TextStyle(fontSize: 11, color: _C.indigo, fontWeight: FontWeight.w600)),
            ] else ...[
              const SizedBox(width: 12),
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: _C.amberLight, borderRadius: BorderRadius.circular(5)),
                child: const Text('Unassigned', style: TextStyle(fontSize: 10, color: _C.amber, fontWeight: FontWeight.w600))),
            ],
            const Spacer(),
            Text(issue.id, style: const TextStyle(fontSize: 11, color: _C.textMuted, fontFamily: 'monospace')),
          ]),
        ])),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED SMALL WIDGETS
// ─────────────────────────────────────────────
class _SharedStatusBadge extends StatelessWidget {
  final ({String label, Color color, Color light}) displayStatus;
  const _SharedStatusBadge({required this.displayStatus});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(color: displayStatus.light, borderRadius: BorderRadius.circular(8)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 7, height: 7, margin: const EdgeInsets.only(right: 5),
        decoration: BoxDecoration(color: displayStatus.color, shape: BoxShape.circle)),
      Text(displayStatus.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: displayStatus.color)),
    ]),
  );
}

class _TypeBadge extends StatelessWidget {
  final MachineType type;
  const _TypeBadge({required this.type});
  @override
  Widget build(BuildContext context) {
    final data = switch (type) {
      MachineType.printer3D       => (label: 'FDM Printer', color: _C.indigo,  light: _C.indigoLight),
      MachineType.resinPrinter    => (label: 'Resin/MSLA',  color: _C.violet,  light: _C.violetLight),
      MachineType.slsPrinter      => (label: 'SLS Printer',  color: _C.amber,   light: _C.amberLight),
      MachineType.laserCutter     => (label: 'Laser Cutter', color: _C.rose,    light: _C.roseLight),
      MachineType.cnc             => (label: 'CNC Machine',  color: _C.sky,     light: _C.skyLight),
      MachineType.postProcessing  => (label: 'Post-Process', color: _C.slate,   light: _C.slateLight),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: data.light, borderRadius: BorderRadius.circular(7)),
      child: Text(data.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: data.color)),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final double size;
  final Color color;
  const _Avatar({required this.name, required this.size, required this.color});
  @override
  Widget build(BuildContext context) {
    final initials = name.split(' ').take(2).map((p) => p.isNotEmpty ? p[0] : '').join();
    return CircleAvatar(radius: size / 2,
      backgroundColor: color.withOpacity(0.15),
      child: Text(initials, style: TextStyle(fontSize: size * 0.35, fontWeight: FontWeight.w800, color: color)));
  }
}

class _StatChip extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _StatChip({required this.label, required this.value, required this.color, required this.icon});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.15))),
    child: Row(children: [
      Icon(icon, size: 13, color: color),
      const SizedBox(width: 6),
      Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
      const SizedBox(width: 5),
      Text(label, style: TextStyle(fontSize: 11, color: color.withOpacity(0.8))),
    ]),
  );
}

class _PillBadge extends StatelessWidget {
  final String label;
  final Color color, light;
  final IconData icon;
  const _PillBadge({required this.label, required this.color, required this.light, required this.icon});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
    decoration: BoxDecoration(color: light, borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.25))),
    child: Row(children: [
      Icon(icon, size: 13, color: color),
      const SizedBox(width: 6),
      Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
    ]),
  );
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _SectionLabel({required this.label, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 14, color: color),
    const SizedBox(width: 6),
    Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
  ]);
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final bool mono;
  final Color? valueColor;
  const _DetailRow({required this.icon, required this.label, required this.value, this.mono = false, this.valueColor});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Row(children: [
      Icon(icon, size: 13, color: _C.textMuted),
      const SizedBox(width: 8),
      Text(label, style: const TextStyle(fontSize: 12, color: _C.textSecondary)),
      const Spacer(),
      Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: valueColor ?? _C.textPrimary, fontFamily: mono ? 'monospace' : null)),
    ]),
  );
}

class _InlineInfo extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InlineInfo({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 11, color: _C.textMuted),
    const SizedBox(width: 3),
    Text(text, style: const TextStyle(fontSize: 11, color: _C.textSecondary)),
  ]);
}

class _MiniMeta extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color? color;
  const _MiniMeta({required this.icon, required this.value, this.color});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 11, color: color ?? _C.textMuted),
    const SizedBox(width: 3),
    Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color ?? _C.textSecondary)),
  ]);
}

class _SmTH extends StatelessWidget {
  final String label;
  const _SmTH(this.label);
  @override
  Widget build(BuildContext context) => Text(label,
    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _C.textMuted, letterSpacing: 0.3));
}

class _TabItem extends StatelessWidget {
  final String label;
  final int count;
  final int alertCount;
  const _TabItem({required this.label, required this.count, this.alertCount = 0});
  @override
  Widget build(BuildContext context) => Tab(
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(label),
      const SizedBox(width: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: alertCount > 0 ? _C.rose : _C.indigoLight,
          borderRadius: BorderRadius.circular(10)),
        child: Text('$count', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
          color: alertCount > 0 ? Colors.white : _C.indigo))),
    ]),
  );
}

// ─────────────────────────────────────────────
//  META HELPERS
// ─────────────────────────────────────────────
({Color color, Color light, String label}) _displayStatus(Machine m) {
  if (m.status == MachineStatus.broken)
    return (color: _C.rose, light: _C.roseLight, label: 'Down');
  if (m.status == MachineStatus.underMaintenance)
    return (color: _C.amber, light: _C.amberLight, label: 'Under Maintenance');
  if (m.currentJob != null)
    return (color: _C.emerald, light: _C.emeraldLight, label: 'In Use');
  if (m.reservedBy != null)
    return (color: _C.sky, light: _C.skyLight, label: 'Reserved');
  return (color: _C.indigo, light: _C.indigoLight, label: 'Available');
}

({Color color, Color light, String label}) _statusMeta(MachineStatus s) => switch (s) {
  MachineStatus.operational     => (color: _C.emerald, light: _C.emeraldLight, label: 'Operational'),
  MachineStatus.idle            => (color: _C.slate,   light: _C.slateLight,   label: 'Idle'),
  MachineStatus.underMaintenance=> (color: _C.amber,   light: _C.amberLight,   label: 'Under Maint.'),
  MachineStatus.broken          => (color: _C.rose,    light: _C.roseLight,    label: 'Broken'),
};

({Color color, Color light, String label}) _scheduleMeta(ScheduleStatus s) => switch (s) {
  ScheduleStatus.upcoming   => (color: _C.indigo,  light: _C.indigoLight,  label: 'Upcoming'),
  ScheduleStatus.inProgress => (color: _C.amber,   light: _C.amberLight,   label: 'In Progress'),
  ScheduleStatus.completed  => (color: _C.emerald, light: _C.emeraldLight, label: 'Completed'),
  ScheduleStatus.overdue    => (color: _C.rose,    light: _C.roseLight,    label: 'Overdue'),
};

({Color color, Color light, String label}) _priorityMeta(IssuePriority p) => switch (p) {
  IssuePriority.critical => (color: _C.rose,   light: _C.roseLight,   label: '🔴 Critical'),
  IssuePriority.high     => (color: _C.amber,  light: _C.amberLight,  label: '🟠 High'),
  IssuePriority.medium   => (color: _C.violet, light: _C.violetLight, label: '🟡 Medium'),
  IssuePriority.low      => (color: _C.slate,  light: _C.slateLight,  label: '🟢 Low'),
};

({Color color, Color light, String label}) _issueStatusMeta(IssueStatus s) => switch (s) {
  IssueStatus.pending    => (color: _C.amber,  light: _C.amberLight,  label: 'Pending'),
  IssueStatus.inProgress => (color: _C.indigo, light: _C.indigoLight, label: 'In Progress'),
  IssueStatus.fixed      => (color: _C.emerald,light: _C.emeraldLight,label: 'Fixed'),
};

IconData _typeIcon(MachineType t) => switch (t) {
  MachineType.printer3D      => Icons.precision_manufacturing_rounded,
  MachineType.resinPrinter   => Icons.water_drop_rounded,
  MachineType.slsPrinter     => Icons.grain_rounded,
  MachineType.laserCutter    => Icons.highlight_rounded,
  MachineType.cnc            => Icons.settings_rounded,
  MachineType.postProcessing => Icons.cleaning_services_rounded,
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
  final period = dt.hour < 12 ? 'AM' : 'PM';
  return '$h:$m $period';
}

String _monthShort(DateTime dt) {
  const m = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'];
  return m[dt.month - 1];
}

String _daysAgo(DateTime dt) {
  final d = DateTime.now().difference(dt).inDays;
  if (d == 0) return 'Today';
  if (d == 1) return 'Yesterday';
  return '${d}d ago';
}

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}

String _formatDuration(Duration d) {
  if (d.inHours == 0) return '${d.inMinutes}min';
  final m = d.inMinutes % 60;
  return m == 0 ? '${d.inHours}h' : '${d.inHours}h ${m}m';
}
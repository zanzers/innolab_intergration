import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:innolab/src/common/loader/app_loader.dart';
import 'package:innolab/src/features/core/admin/schedule/schedule_controller/schedule_controller.dart';
import 'package:innolab/src/features/core/admin/user/screens/App_schedule_store.dart';
import 'package:innolab/src/features/models/schedule_model.dart';
import 'package:innolab/utils/constant/enums.dart';

part 'schedule_screen_web.dart';
part 'schedule_screen_mobile.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS  (shared)
// ─────────────────────────────────────────────
class _C {
  static const bg = Color(0xFFF4F6FB);
  static const surface = Colors.white;
  static const border = Color(0xFFE8ECF4);
  static const indigo = Color(0xFF4F46E5);
  static const indigoLight = Color(0xFFEEF2FF);
  static const indigoDark = Color(0xFF3730A3);
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
//  FORM DROPDOWN OPTIONS  (shared)
// ─────────────────────────────────────────────
const _staffList = [
  'Mike Johnson', 'Sarah Wilson', 'David Chen',
  'Lisa Garcia', 'Nina Patel', 'Alex Turner',
];
const _machineList = [
  'Bambu X1 Carbon', 'Prusa MK4', 'Creality K1 Max',
  'Voron 2.4 R2', 'Elegoo Saturn 4', 'Sinterit Lisa Pro',
  'xTool D1 Pro', 'Bambu P1S',
];
const _locationList = [
  'Bay A1', 'Bay A2', 'Bay A3', 'Bay A4', 'Bay B1',
  'Bay C1', 'Bay D1', 'Vault C2', 'Conference Room 1',
  'Storage Room', 'Remote',
];

// ─────────────────────────────────────────────
//  RESPONSIVE ENTRY POINT
// ─────────────────────────────────────────────
class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 768) {
          return const _WebScheduleView();
        }
        return const _MobileScheduleView();
      },
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED STATE MIXIN  (used by both layouts)
// ─────────────────────────────────────────────
mixin _ScheduleStateMixin<T extends StatefulWidget> on State<T> {
  ScheduleController get _scheduleController {
    if (!Get.isRegistered<ScheduleController>()) {
      Get.put(ScheduleController());
    }
    return ScheduleController.instance;
  }

  List<ScheduleEvent> get events => _scheduleController.events;

  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();

  EventType? typeFilter;
  EventStatus? statusFilter;
  String? staffFilter;
  String searchQuery = '';

  @override
  void initState() {
    if (!Get.isRegistered<ScheduleController>()) {
      Get.put(ScheduleController());
    }
    super.initState();
  }

  List<ScheduleEvent> get filteredEvents {
    return events.where((e) {
      final matchType   = typeFilter == null   || e.type   == typeFilter;
      final matchStatus = statusFilter == null || e.status == statusFilter;
      final matchStaff  = staffFilter == null  ||
          e.assignedStaff == staffFilter || e.relatedUser == staffFilter;
      final q = searchQuery.toLowerCase();
      final matchSearch = q.isEmpty ||
          e.title.toLowerCase().contains(q) ||
          (e.machine?.toLowerCase().contains(q) ?? false) ||
          (e.assignedStaff?.toLowerCase().contains(q) ?? false) ||
          (e.linkedId?.toLowerCase().contains(q) ?? false);
      return matchType && matchStatus && matchStaff && matchSearch;
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  List<ScheduleEvent> eventsForDay(DateTime day) => filteredEvents
      .where((e) =>
          e.startTime.year  == day.year  &&
          e.startTime.month == day.month &&
          e.startTime.day   == day.day)
      .toList();

  int get pendingAdminTasks =>
      events.where((e) => e.isAdminTask && e.status == EventStatus.pending).length;
  int get pendingApprovals =>
      events.where((e) => e.type == EventType.requestApproval && e.status == EventStatus.pending).length;
  int get todayEventCount => eventsForDay(DateTime.now()).length;
  int get inProgressCount =>
      events.where((e) => e.status == EventStatus.inProgress).length;

  Future<void> handleQuickAction(ScheduleEvent event, String action) async {
    EventStatus? newStatus;
    if (action == 'approve') newStatus = EventStatus.approved;
    if (action == 'reject') newStatus = EventStatus.rejected;
    if (action == 'complete') newStatus = EventStatus.completed;
    if (newStatus == null) return;
    final updated = event.copyWith(status: newStatus);
    await _scheduleController.updateEvent(updated);
  }

  Future<void> handleStatusChange(ScheduleEvent event, EventStatus status) async {
    final updated = event.copyWith(status: status);
    await _scheduleController.updateEvent(updated);
    if (event.type == EventType.maintenance) {
      AppScheduleStore.instance.updateStatus(event.id, _toSharedStatus(status));
    }
  }

  Future<void> handleDelete(ScheduleEvent event) async {
    if (event.type == EventType.maintenance) {
      AppScheduleStore.instance.removeById(event.id);
    }
    await _scheduleController.deleteEvent(event.id);
  }

  Future<String?> handleSave(ScheduleEvent newEvent, ScheduleEvent? existing) async {
    if (existing != null) {
      await _scheduleController.updateEvent(newEvent);
      if (newEvent.type == EventType.maintenance) {
        AppScheduleStore.instance.addOrUpdateFromSchedule(SharedMaintenanceTask(
          id: newEvent.id,
          title: newEvent.title,
          notes: newEvent.description,
          assignedTo: newEvent.assignedStaff ?? 'Unassigned',
          machineName: newEvent.machine ?? 'N/A',
          machineId: newEvent.linkedId ?? newEvent.id,
          scheduledDate: newEvent.startTime,
          endDate: newEvent.endTime,
          status: _toSharedStatus(newEvent.status),
          estimatedDuration: newEvent.endTime.difference(newEvent.startTime),
        ));
      }
      return newEvent.id;
    }
    final id = await _scheduleController.addEvent(newEvent);
    if (newEvent.type == EventType.maintenance) {
      final synced = newEvent.copyWith(id: id);
      AppScheduleStore.instance.addOrUpdateFromSchedule(SharedMaintenanceTask(
        id: synced.id,
        title: synced.title,
        notes: synced.description,
        assignedTo: synced.assignedStaff ?? 'Unassigned',
        machineName: synced.machine ?? 'N/A',
        machineId: synced.linkedId ?? synced.id,
        scheduledDate: synced.startTime,
        endDate: synced.endTime,
        status: _toSharedStatus(synced.status),
        estimatedDuration: synced.endTime.difference(synced.startTime),
      ));
    }
    return id;
  }

  SharedTaskStatus _toSharedStatus(EventStatus s) => switch (s) {
    EventStatus.pending    => SharedTaskStatus.upcoming,
    EventStatus.inProgress => SharedTaskStatus.inProgress,
    EventStatus.completed  => SharedTaskStatus.completed,
    EventStatus.canceled   => SharedTaskStatus.canceled,
    EventStatus.approved   => SharedTaskStatus.upcoming,
    EventStatus.rejected   => SharedTaskStatus.canceled,
  };

  void clearFilters() =>
      setState(() { typeFilter = null; statusFilter = null; staffFilter = null; });
}

// ─────────────────────────────────────────────
//  SHARED: EVENT FORM DIALOG
// ─────────────────────────────────────────────
class _EventFormDialog extends StatefulWidget {
  final ScheduleEvent? existing;
  final Future<void> Function(ScheduleEvent) onSave;

  const _EventFormDialog({this.existing, required this.onSave});

  @override
  State<_EventFormDialog> createState() => _EventFormDialogState();
}

class _EventFormDialogState extends State<_EventFormDialog> {
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  late EventType   _type;
  late EventStatus _status;
  late DateTime    _startTime;
  late DateTime    _endTime;
  Duration _duration = const Duration(hours: 1);
  bool _isCustomDuration = false;
  String? _staff;
  String? _machine;
  String? _location;
  bool _isAdminTask = false;
  bool _overrideConflict = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    final n = DateTime.now();
    _titleCtrl.text = e?.title ?? '';
    _descCtrl.text  = e?.description ?? '';
    _type        = e?.type   ?? EventType.meeting;
    _status      = e?.status ?? EventStatus.pending;
    _startTime   = e?.startTime ?? DateTime(n.year, n.month, n.day, 9, 0);
    _endTime     = e?.endTime   ?? DateTime(n.year, n.month, n.day, 10, 0);
    final initialDuration = _endTime.difference(_startTime);
    _duration = initialDuration.inMinutes <= 0
        ? const Duration(hours: 1)
        : initialDuration;
    _isCustomDuration = !_isPresetDuration(_duration);
    _staff       = e?.assignedStaff;
    _machine     = e?.machine;
    _location    = e?.location;
    _isAdminTask = e?.isAdminTask ?? false;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  DateTime get _computedEndTime => _startTime.add(_duration);

  void _recomputeEndTime() {
    _endTime = _computedEndTime;
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startTime : _endTime,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: _C.indigo)),
        child: child!),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startTime = DateTime(
            picked.year, picked.month, picked.day,
            _startTime.hour, _startTime.minute);
        _recomputeEndTime();
      }
    });
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStart ? _startTime : _endTime),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: _C.indigo)),
        child: child!),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startTime = DateTime(
            _startTime.year, _startTime.month, _startTime.day,
            picked.hour, picked.minute);
        _recomputeEndTime();
      }
    });
  }

  Duration _durationFromLabel(String label) {
    switch (label) {
      case '30 min':
        return const Duration(minutes: 30);
      case '1 hour':
        return const Duration(hours: 1);
      case '1.5 hours':
        return const Duration(hours: 1, minutes: 30);
      case '2 hours':
        return const Duration(hours: 2);
      case '3 hours':
        return const Duration(hours: 3);
      case '4 hours':
        return const Duration(hours: 4);
      default:
        return const Duration(hours: 1);
    }
  }

  String _labelForDuration(Duration d) {
    final mins = d.inMinutes;
    if (mins == 30) return '30 min';
    if (mins == 60) return '1 hour';
    if (mins == 90) return '1.5 hours';
    if (mins == 120) return '2 hours';
    if (mins == 180) return '3 hours';
    if (mins == 240) return '4 hours';
    final hrs = d.inHours;
    return hrs <= 1 ? '1 hour' : '$hrs hours';
  }

  bool _isPresetDuration(Duration d) {
    const presets = [
      Duration(minutes: 30),
      Duration(hours: 1),
      Duration(hours: 1, minutes: 30),
      Duration(hours: 2),
      Duration(hours: 3),
      Duration(hours: 4),
    ];
    return presets.contains(d);
  }

  Future<void> _pickCustomDuration() async {
    final pickedEnd = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_computedEndTime),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: _C.indigo),
        ),
        child: child!,
      ),
    );
    if (pickedEnd == null) return;

    final end = DateTime(
      _startTime.year,
      _startTime.month,
      _startTime.day,
      pickedEnd.hour,
      pickedEnd.minute,
    );

    if (!end.isAfter(_startTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Custom end time must be after the start time.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _duration = end.difference(_startTime);
      _isCustomDuration = !_isPresetDuration(_duration);
      _recomputeEndTime();
    });
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    // Guard against invalid times; end is always derived from start + duration
    if (_computedEndTime.isBefore(_startTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'End time is before start time. Adjust start time or duration.'),
        ),
      );
      return;
    }
    await AAppLoading.showWhile<void>(
      context,
      () async => widget.onSave(
        ScheduleEvent(
          id: widget.existing?.id ?? '',
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          type: _type,
          status: _status,
          startTime: _startTime,
          endTime: _computedEndTime,
          assignedStaff: _staff,
          machine: _machine,
          location: _location,
          isAdminTask: _isAdminTask,
        ),
      ),
      message: widget.existing == null
          ? 'Saving event...'
          : 'Updating event...',
    );
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;
    final isMobile = screenW < 600;

    // Responsive sizing
    final dialogW   = isMobile ? screenW - 32 : 560.0;
    final dialogMaxH = isMobile ? screenH * 0.92 : 680.0;
    final bodyPad   = isMobile ? 16.0 : 24.0;

    return Dialog(
      // Remove default 40px inset so we control it ourselves
      insetPadding: isMobile
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 24)
          : const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogW,
          maxHeight: dialogMaxH,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(bodyPad, 18, 14, 16),
              decoration: const BoxDecoration(
                color: _C.bg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                border: Border(bottom: BorderSide(color: _C.border)),
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: _C.indigoLight,
                      borderRadius: BorderRadius.circular(9)),
                  child: Icon(
                      isEdit
                          ? Icons.edit_calendar_rounded
                          : Icons.add_circle_rounded,
                      color: _C.indigo,
                      size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isEdit ? 'Edit Event' : 'Create New Event',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _C.textPrimary),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: _C.border)),
                    child: const Icon(Icons.close_rounded,
                        size: 16, color: _C.textSecondary),
                  ),
                ),
              ]),
            ),

            // ── Body ─────────────────────────────────
            Flexible(
              child: Container(
                color: Colors.white,   // ← explicit white; fixes dark theme bleed
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(bodyPad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      _FormLabel('Event Title *'),
                      const SizedBox(height: 6),
                      _SharedTextField(
                          controller: _titleCtrl,
                          hint: 'e.g. Weekly Team Meeting'),
                      const SizedBox(height: 14),

                      // Description
                      _FormLabel('Description'),
                      const SizedBox(height: 6),
                      _SharedTextField(
                          controller: _descCtrl,
                          hint: 'Optional notes or details…',
                          maxLines: isMobile ? 2 : 3),
                      const SizedBox(height: 14),

                      // Type + Status  (always 2 columns — wide enough on any phone)
                      Row(children: [
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FormLabel('Event Type'),
                            const SizedBox(height: 6),
                            _SharedDropdown<EventType>(
                              value: _type,
                              items: EventType.values,
                              labelBuilder: (t) => _typeMeta(t).label,
                              onChanged: (t) =>
                                  setState(() => _type = t!),
                            ),
                          ],
                        )),
                        const SizedBox(width: 10),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FormLabel('Status'),
                            const SizedBox(height: 6),
                            _SharedDropdown<EventStatus>(
                              value: _status,
                              items: _statusOptionsForType(_type),
                              labelBuilder: (s) => _statusLabel(s),
                              onChanged: (s) =>
                                  setState(() => _status = s!),
                            ),
                          ],
                        )),
                      ]),
                      const SizedBox(height: 14),

                      // Date / Time  with duration ── 2-col on mobile, 4-col on web ──
                      if (isMobile) ...[
                        // Row 1: Start date + Start time
                        Row(children: [
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FormLabel('Date'),
                              const SizedBox(height: 6),
                              _DateTimeBtn(
                                  label: _fmtDateShort(_startTime),
                                  icon: Icons.calendar_today_rounded,
                                  onTap: () => _pickDate(true)),
                            ],
                          )),
                          const SizedBox(width: 10),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FormLabel('Start Time'),
                              const SizedBox(height: 6),
                              _DateTimeBtn(
                                  label: _fmtTime(_startTime),
                                  icon: Icons.access_time_rounded,
                                  onTap: () => _pickTime(true)),
                            ],
                          )),
                        ]),
                        const SizedBox(height: 10),
                        // Row 2: Duration + computed end time
                        Row(children: [
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FormLabel('Duration'),
                              const SizedBox(height: 6),
                              Builder(builder: (context) {
                                const presetLabels = [
                                  '30 min',
                                  '1 hour',
                                  '1.5 hours',
                                  '2 hours',
                                  '3 hours',
                                  '4 hours',
                                ];
                                const customKey = 'Custom…';
                                final isPreset = _isPresetDuration(_duration);
                                final items = [...presetLabels, customKey];
                                final currentLabel =
                                    isPreset ? _labelForDuration(_duration) : customKey;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _SharedDropdown<String>(
                                      value: currentLabel,
                                      items: items,
                                      labelBuilder: (s) => s,
                                      onChanged: (s) async {
                                        if (s == null) return;
                                        if (s == customKey) {
                                          await _pickCustomDuration();
                                          return;
                                        }
                                        setState(() {
                                          _duration = _durationFromLabel(s);
                                          _isCustomDuration = false;
                                          _recomputeEndTime();
                                        });
                                      },
                                    ),
                                    if (!isPreset) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Custom: ${_fmtDuration(_duration)}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: _C.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ],
                                );
                              }),
                            ],
                          )),
                          const SizedBox(width: 10),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FormLabel('Ends At'),
                              const SizedBox(height: 6),
                              _DateTimeBtn(
                                  label: _fmtTime(_computedEndTime),
                                  icon: Icons.lock_clock_rounded,
                                  onTap: () {}),
                            ],
                          )),
                        ]),
                      ] else ...[
                        // Web: Date, Start Time, Duration, Ends At
                        Row(children: [
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FormLabel('Date'),
                              const SizedBox(height: 6),
                              _DateTimeBtn(
                                  label: _fmtDateShort(_startTime),
                                  icon: Icons.calendar_today_rounded,
                                  onTap: () => _pickDate(true)),
                            ],
                          )),
                          const SizedBox(width: 10),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FormLabel('Start Time'),
                              const SizedBox(height: 6),
                              _DateTimeBtn(
                                  label: _fmtTime(_startTime),
                                  icon: Icons.access_time_rounded,
                                  onTap: () => _pickTime(true)),
                            ],
                          )),
                          const SizedBox(width: 10),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FormLabel('Duration'),
                              const SizedBox(height: 6),
                              Builder(builder: (context) {
                                const presetLabels = [
                                  '30 min',
                                  '1 hour',
                                  '1.5 hours',
                                  '2 hours',
                                  '3 hours',
                                  '4 hours',
                                ];
                                const customKey = 'Custom…';
                                final isPreset = _isPresetDuration(_duration);
                                final items = [...presetLabels, customKey];
                                final currentLabel =
                                    isPreset ? _labelForDuration(_duration) : customKey;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _SharedDropdown<String>(
                                      value: currentLabel,
                                      items: items,
                                      labelBuilder: (s) => s,
                                      onChanged: (s) async {
                                        if (s == null) return;
                                        if (s == customKey) {
                                          await _pickCustomDuration();
                                          return;
                                        }
                                        setState(() {
                                          _duration = _durationFromLabel(s);
                                          _isCustomDuration = false;
                                          _recomputeEndTime();
                                        });
                                      },
                                    ),
                                    if (!isPreset) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Custom: ${_fmtDuration(_duration)}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: _C.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ],
                                );
                              }),
                            ],
                          )),
                          const SizedBox(width: 10),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FormLabel('Ends At'),
                              const SizedBox(height: 6),
                              _DateTimeBtn(
                                  label: _fmtTime(_computedEndTime),
                                  icon: Icons.lock_clock_rounded,
                                  onTap: () {}),
                            ],
                          )),
                        ]),
                      ],
                      const SizedBox(height: 14),

                      // Smart Fields (Dynamic UI based on Event Type)
                      Builder(builder: (_) {
                        final isMachineUse = _type == EventType.machineUsage;
                        final isMeeting   = _type == EventType.meeting;
                        final isMaint     = _type == EventType.maintenance;

                        final machineField = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FormLabel('Machine'),
                            const SizedBox(height: 6),
                            _SharedDropdown<String?>(
                              value: _machine,
                              items: [null, ..._machineList],
                              labelBuilder: (m) => m ?? 'None',
                              onChanged: (m) =>
                                  setState(() => _machine = m),
                            ),
                          ],
                        );

                        final staffLabel =
                            isMeeting ? 'Participants' : 'Assigned Staff';

                        final staffField = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FormLabel(staffLabel),
                            const SizedBox(height: 6),
                            _SharedDropdown<String?>(
                              value: _staff,
                              items: [null, ..._staffList],
                              labelBuilder: (s) => s ?? 'None',
                              onChanged: (s) =>
                                  setState(() => _staff = s),
                            ),
                          ],
                        );

                        final locationField = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FormLabel('Location'),
                            const SizedBox(height: 6),
                            _SharedDropdown<String?>(
                              value: _location,
                              items: [null, ..._locationList],
                              labelBuilder: (l) => l ?? 'None',
                              onChanged: (l) =>
                                  setState(() => _location = l),
                            ),
                          ],
                        );

                        List<Widget> section = [];

                        if (isMachineUse) {
                          section = [
                            Row(children: [
                              Expanded(child: machineField),
                              const SizedBox(width: 10),
                              Expanded(child: staffField),
                            ]),
                          ];
                        } else if (isMeeting) {
                          section = [
                            locationField,
                            const SizedBox(height: 10),
                            staffField,
                          ];
                        } else if (isMaint) {
                          section = [
                            Row(children: [
                              Expanded(child: machineField),
                              const SizedBox(width: 10),
                              Expanded(child: staffField),
                            ]),
                            const SizedBox(height: 10),
                            locationField,
                          ];
                        } else {
                          section = [
                            Row(children: [
                              Expanded(child: staffField),
                              const SizedBox(width: 10),
                              Expanded(child: machineField),
                            ]),
                            const SizedBox(height: 10),
                            locationField,
                          ];
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...section,
                            const SizedBox(height: 10),
                          ],
                        );
                      }),
                      const SizedBox(height: 14),

                      // Admin task toggle
                      GestureDetector(
                        onTap: () =>
                            setState(() => _isAdminTask = !_isAdminTask),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _isAdminTask
                                ? _C.amberLight
                                : const Color(0xFFF8F9FC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: _isAdminTask
                                    ? _C.amber.withOpacity(0.5)
                                    : _C.border),
                          ),
                          child: Row(children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 150),
                              child: Icon(
                                _isAdminTask
                                    ? Icons.check_box_rounded
                                    : Icons.check_box_outline_blank_rounded,
                                key: ValueKey(_isAdminTask),
                                color: _isAdminTask
                                    ? _C.amber
                                    : _C.textMuted,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text('Mark as Admin Task',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: _C.textPrimary)),
                                  Text(
                                    'Appears in admin task reminders & badges',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: _C.textMuted),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Footer ───────────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(
                  bodyPad, 12, bodyPad, isMobile ? 16 : 20),
              decoration: const BoxDecoration(
                color: _C.bg,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(18)),
                border: Border(top: BorderSide(color: _C.border)),
              ),
              child: Row(children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: _C.textSecondary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  child: const Text('Cancel',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _save,
                  icon: Icon(
                      isEdit ? Icons.save_rounded : Icons.add_rounded,
                      size: 16),
                  label: Text(isEdit ? 'Save Changes' : 'Create Event'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.indigo,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 18 : 20,
                        vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11)),
                    elevation: 0,
                    textStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED SMALL FORM WIDGETS
// ─────────────────────────────────────────────
class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: _C.textSecondary));
}

class _SharedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  const _SharedTextField(
      {required this.controller, required this.hint, this.maxLines = 1});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _C.border)),
    child: TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
          fontSize: 14,
          color: _C.textPrimary,
          decoration: TextDecoration.none),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: _C.textMuted),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      ),
    ),
  );
}

class _SharedDropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final ValueChanged<T?> onChanged;
  const _SharedDropdown(
      {required this.value,
      required this.items,
      required this.labelBuilder,
      required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(
    height: 44,   // fixed height prevents layout jitter
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _C.border)),
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        dropdownColor: Colors.white,   // always white dropdown menu
        style: const TextStyle(fontSize: 13, color: _C.textPrimary),
        icon: const Icon(Icons.keyboard_arrow_down_rounded,
            size: 18, color: _C.textMuted),
        items: items
            .map((item) => DropdownMenuItem(
                value: item,
                child: Text(labelBuilder(item),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: _C.textPrimary, fontSize: 13))))
            .toList(),
        onChanged: onChanged,
      ),
    ),
  );
}

class _DateTimeBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _DateTimeBtn(
      {required this.label, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 44,   // same fixed height as dropdowns for visual alignment
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _C.border)),
      child: Row(children: [
        Icon(icon, size: 15, color: _C.indigo),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary),
          ),
        ),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────
//  SHARED PICKERS
// ─────────────────────────────────────────────
class _PickerOption {
  final String label;
  final VoidCallback onTap;
  const _PickerOption({required this.label, required this.onTap});
}

class _PickerSheet extends StatelessWidget {
  final String title;
  final List<_PickerOption> options;
  const _PickerSheet({required this.title, required this.options});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _C.textPrimary)),
        const SizedBox(height: 14),
        ...options.map((o) => ListTile(
              title: Text(o.label,
                  style: const TextStyle(
                      fontSize: 14, color: _C.textPrimary)),
              onTap: o.onTap,
              contentPadding: EdgeInsets.zero,
              dense: true,
            )),
      ],
    ),
  );
}

// ─────────────────────────────────────────────
//  META HELPERS  (shared)
// ─────────────────────────────────────────────
({Color color, Color light, String label, IconData icon}) _typeMeta(
        EventType t) =>
    switch (t) {
      EventType.requestApproval => (
        color: _C.rose,
        light: _C.roseLight,
        label: 'Approval',
        icon: Icons.pending_actions_rounded
      ),
      EventType.maintenance => (
        color: _C.amber,
        light: _C.amberLight,
        label: 'Maintenance',
        icon: Icons.build_rounded
      ),
      EventType.meeting => (
        color: _C.indigo,
        light: _C.indigoLight,
        label: 'Meeting',
        icon: Icons.groups_rounded
      ),
      EventType.machineUsage => (
        color: _C.emerald,
        light: _C.emeraldLight,
        label: 'Machine Use',
        icon: Icons.precision_manufacturing_rounded
      ),
      EventType.adminTask => (
        color: _C.violet,
        light: _C.violetLight,
        label: 'Admin Task',
        icon: Icons.assignment_rounded
      ),
    };

/// Distinct [EventType]s on a day, in enum order (stable chips / legend).
List<EventType> _distinctEventTypesOrdered(List<ScheduleEvent> dayEvents) {
  final present = dayEvents.map((e) => e.type).toSet();
  return EventType.values.where((t) => present.contains(t)).toList();
}

Widget _calendarDayTypeIcons(
  List<EventType> types, {
  required double iconSize,
  int maxIcons = 5,
  Color? iconColor,
}) {
  if (types.isEmpty) return const SizedBox.shrink();
  final show = types.take(maxIcons).toList();
  final moreTypes = types.length - show.length;
  final accent = iconColor;
  final overflowColor = accent ?? _C.textMuted;
  return Wrap(
    spacing: 3,
    runSpacing: 2,
    children: [
      ...show.map((t) {
        final m = _typeMeta(t);
        return Icon(m.icon, size: iconSize, color: accent ?? m.color);
      }),
      if (moreTypes > 0)
        Text(
          '+$moreTypes',
          style: TextStyle(
            fontSize: iconSize * 0.65,
            fontWeight: FontWeight.w700,
            color: overflowColor,
          ),
        ),
    ],
  );
}

/// Compact icon legend for calendar month views.
Widget _calendarTypeLegendStrip() => Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 6,
        children: EventType.values.map((t) {
          final m = _typeMeta(t);
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(m.icon, size: 13, color: m.color),
              const SizedBox(width: 4),
              Text(
                m.label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: _C.textSecondary,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );

({Color color, Color light, String label}) _statusMeta(EventStatus s) =>
    switch (s) {
      // Shown as "Scheduled" for normal events
      EventStatus.pending    => (color: _C.amber,   light: _C.amberLight,   label: 'Scheduled'),
      EventStatus.inProgress => (color: _C.indigo,  light: _C.indigoLight,  label: 'In Progress'),
      EventStatus.completed  => (color: _C.emerald, light: _C.emeraldLight, label: 'Completed'),
      EventStatus.canceled   => (color: _C.slate,   light: _C.slateLight,   label: 'Canceled'),
      EventStatus.approved   => (color: _C.emerald, light: _C.emeraldLight, label: 'Approved'),
      EventStatus.rejected   => (color: _C.rose,    light: _C.roseLight,    label: 'Rejected'),
    };

String _statusLabel(EventStatus s) => _statusMeta(s).label;
Color  _statusColor(EventStatus s) => _statusMeta(s).color;

List<EventStatus> _statusOptionsForType(EventType type) {
  if (type == EventType.requestApproval) {
    return const [
      EventStatus.pending,
      EventStatus.approved,
      EventStatus.rejected,
    ];
  }
  return const [
    EventStatus.pending,
    EventStatus.inProgress,
    EventStatus.completed,
    EventStatus.canceled,
  ];
}

// ─────────────────────────────────────────────
//  STRING / DATE HELPERS  (shared)
// ─────────────────────────────────────────────
bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _fmtTime(DateTime dt) {
  final h24 = dt.hour;
  final h12 = h24 % 12 == 0 ? 12 : h24 % 12;
  final hStr = h12.toString().padLeft(2, '0');
  final mStr = dt.minute.toString().padLeft(2, '0');
  final suffix = h24 >= 12 ? 'PM' : 'AM';
  return '$hStr:$mStr $suffix';
}

String _fmtDateShort(DateTime dt) {
  const months = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec'
  ];
  return '${months[dt.month - 1]} ${dt.day}';
}

String _fmtDateLong(DateTime dt) {
  const months = [
    'January','February','March','April','May','June',
    'July','August','September','October','November','December'
  ];
  const days = [
    'Monday','Tuesday','Wednesday','Thursday',
    'Friday','Saturday','Sunday'
  ];
  return '${days[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}, ${dt.year}';
}

String _fmtDuration(Duration d) {
  if (d.inHours == 0) return '${d.inMinutes}min';
  final m = d.inMinutes % 60;
  return m == 0 ? '${d.inHours}h' : '${d.inHours}h ${m}m';
}

String _weekdayShort(int wd) =>
    ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][wd - 1];

String _monthName(int m) => [
  'January','February','March','April','May','June',
  'July','August','September','October','November','December'
][m - 1];
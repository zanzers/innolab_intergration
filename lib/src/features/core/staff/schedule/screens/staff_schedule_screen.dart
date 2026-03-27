import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

// ── Machine data ──────────────────────────────────────────────────────────────

class _Machine {
  final String id;
  final String brand;
  final String model;
  final String type;
  final String buildSize;
  final List<String> materials;
  final IconData icon;
  final Color color;

  const _Machine({
    required this.id,
    required this.brand,
    required this.model,
    required this.type,
    required this.buildSize,
    required this.materials,
    required this.icon,
    required this.color,
  });
}

const List<_Machine> _machines = [
  _Machine(
    id: 'M-001',
    brand: 'Creality',
    model: 'Ender-3 V3 SE',
    type: 'Material Extrusion (FDM)',
    buildSize: '220 × 220 × 250 mm',
    materials: ['PLA', 'PETG', 'TPU', 'PA', 'ABS'],
    icon: Iconsax.cpu,
    color: Color(0xFF3B82F6),
  ),
  _Machine(
    id: 'M-002',
    brand: 'Elegoo',
    model: 'Saturn 3 Ultra',
    type: 'VAT Polymerization (MSLA)',
    buildSize: '218.88 × 122.88 × 260 mm',
    materials: ['Standard Resin', 'ABE Substitute', 'PE Substitute', 'Flexible Resin', 'Casting Resin', 'Draft Resin'],
    icon: Iconsax.box,
    color: Color(0xFF8B5CF6),
  ),
  _Machine(
    id: 'M-003',
    brand: 'Anycubic',
    model: 'Wash and Cure 3 Plus',
    type: 'Wash and Cure Station',
    buildSize: '260 × 228 × 128 mm',
    materials: ['Post-processing for Resin prints'],
    icon: Iconsax.refresh_circle,
    color: Color(0xFFF59E0B),
  ),
  _Machine(
    id: 'M-004',
    brand: 'Bambu Labs',
    model: 'X1 Carbon',
    type: 'Material Extrusion (FDM)',
    buildSize: '256 × 256 × 256 mm',
    materials: ['PLA', 'PETG', 'TPU', 'ABS', 'PVA', 'PET', 'PC', 'Carbon/Glass Fiber'],
    icon: Iconsax.cpu,
    color: Color(0xFF10B981),
  ),
  _Machine(
    id: 'M-005',
    brand: 'Shining 3D',
    model: 'Einstar',
    type: '3D Scanner',
    buildSize: '220 × 46 × 55 mm (scanner)',
    materials: ['High-quality Data', 'High Color Fidelity', 'Detail Enhancement', 'Outdoor Scanning'],
    icon: Iconsax.scan,
    color: Color(0xFFEF4444),
  ),
];

// ── Appointment ───────────────────────────────────────────────────────────────

class _Appointment {
  final String id;
  final String title;
  final String? requestId;
  final String? userName;
  final DateTime date;
  final String timeSlot;
  final String? note;
  bool isDone;

  _Appointment({
    required this.id,
    required this.title,
    this.requestId,
    this.userName,
    required this.date,
    required this.timeSlot,
    this.note,
    this.isDone = false,
  });
}

// ── Report Status ─────────────────────────────────────────────────────────────

enum ReportStatus { pending, inProgress, resolved }

extension ReportStatusExt on ReportStatus {
  String get label {
    switch (this) {
      case ReportStatus.pending:    return 'Pending';
      case ReportStatus.inProgress: return 'In Progress';
      case ReportStatus.resolved:   return 'Resolved';
    }
  }

  Color get color {
    switch (this) {
      case ReportStatus.pending:    return const Color(0xFFF59E0B);
      case ReportStatus.inProgress: return const Color(0xFF3B82F6);
      case ReportStatus.resolved:   return const Color(0xFF10B981);
    }
  }

  IconData get icon {
    switch (this) {
      case ReportStatus.pending:    return Iconsax.clock;
      case ReportStatus.inProgress: return Iconsax.refresh_2;
      case ReportStatus.resolved:   return Iconsax.tick_circle;
    }
  }
}

// ── Machine report ────────────────────────────────────────────────────────────

enum IssueType { mechanical, electrical, software, calibration, other }

extension IssueTypeExt on IssueType {
  String get label {
    switch (this) {
      case IssueType.mechanical:  return 'Mechanical';
      case IssueType.electrical:  return 'Electrical';
      case IssueType.software:    return 'Software';
      case IssueType.calibration: return 'Calibration';
      case IssueType.other:       return 'Other';
    }
  }

  Color get color {
    switch (this) {
      case IssueType.mechanical:  return const Color(0xFFEF4444);
      case IssueType.electrical:  return const Color(0xFFF59E0B);
      case IssueType.software:    return const Color(0xFF3B82F6);
      case IssueType.calibration: return const Color(0xFF8B5CF6);
      case IssueType.other:       return const Color(0xFF6B7280);
    }
  }

  IconData get icon {
    switch (this) {
      case IssueType.mechanical:  return Iconsax.setting_2;
      case IssueType.electrical:  return Iconsax.electricity;
      case IssueType.software:    return Iconsax.code;
      case IssueType.calibration: return Iconsax.maximize_3;
      case IssueType.other:       return Iconsax.warning_2;
    }
  }
}

class _MachineReport {
  final String id;
  final _Machine machine;
  final IssueType issueType;
  final String description;
  final DateTime reportedAt;
  final String submittedBy; // ← NEW: who submitted
  ReportStatus status;      // ← NEW: mutable status

  _MachineReport({
    required this.id,
    required this.machine,
    required this.issueType,
    required this.description,
    required this.reportedAt,
    required this.submittedBy,
    this.status = ReportStatus.pending,
  });
}

// ── Sample data ───────────────────────────────────────────────────────────────

final DateTime _today = DateTime.now();

List<_Appointment> _buildSampleAppointments() => [
  _Appointment(
    id: 'SCH-001',
    title: 'Pickup – bracket_v2.stl',
    requestId: 'REQ-2024-001',
    userName: 'Marcelo Santos',
    date: _today,
    timeSlot: '9:00 AM – 10:00 AM',
    note: 'Client will come with student ID.',
  ),
  _Appointment(
    id: 'SCH-002',
    title: 'Consultation – 3D model review',
    userName: 'Ana Rivera',
    date: _today,
    timeSlot: '11:00 AM – 11:30 AM',
  ),
  _Appointment(
    id: 'SCH-003',
    title: 'Pickup – gear_assembly.3mf',
    requestId: 'REQ-2024-003',
    userName: 'Jose Reyes',
    date: _today.add(const Duration(days: 2)),
    timeSlot: '2:00 PM – 3:00 PM',
  ),
  _Appointment(
    id: 'SCH-004',
    title: 'Consultation – material selection',
    userName: 'Maria Cruz',
    date: _today.add(const Duration(days: 4)),
    timeSlot: '10:00 AM – 10:30 AM',
  ),
];

// ── Main Screen ───────────────────────────────────────────────────────────────

class StaffScheduleScreen extends StatefulWidget {
  const StaffScheduleScreen({super.key});

  @override
  State<StaffScheduleScreen> createState() => _StaffScheduleScreenState();
}

class _StaffScheduleScreenState extends State<StaffScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _selectedDay;
  late DateTime _calendarMonth;
  late List<_Appointment> _appointments;
  final List<_MachineReport> _reports = [];

  // Controls whether the bottom calendar is expanded or collapsed
  bool _calendarExpanded = true;

  @override
  void initState() {
    super.initState();
    _tabController  = TabController(length: 3, vsync: this);
    _selectedDay    = _today;
    _calendarMonth  = DateTime(_today.year, _today.month, 1);
    _appointments   = _buildSampleAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _hasAppt(DateTime day) =>
      _appointments.any((a) => _isSameDay(a.date, day));

  List<_Appointment> get _selectedDayAppts =>
      _appointments.where((a) => _isSameDay(a.date, _selectedDay)).toList()
        ..sort((a, b) => a.timeSlot.compareTo(b.timeSlot));

  List<_Appointment> get _upcomingAppts =>
      _appointments
          .where((a) => a.date.isAfter(_today) && !_isSameDay(a.date, _today))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));

  void _toggleDone(String id) =>
      setState(() => _appointments.firstWhere((a) => a.id == id).isDone =
          !_appointments.firstWhere((a) => a.id == id).isDone);

  void _deleteAppt(String id) {
    setState(() => _appointments.removeWhere((a) => a.id == id));
    _showSnack('Appointment removed', Colors.grey.shade700);
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ── Calendar helpers ──────────────────────────────────────────────────────

  int get _daysInMonth =>
      DateTime(_calendarMonth.year, _calendarMonth.month + 1, 0).day;

  int get _firstWeekday =>
      DateTime(_calendarMonth.year, _calendarMonth.month, 1).weekday % 7;

  String _monthName(int m) => const [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ][m];

  String _weekdayShort(int w) =>
      const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][w - 1];

  String _formatDate(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${_weekdayShort(dt.weekday)}, ${months[dt.month - 1]} ${dt.day}';
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ── Header ──────────────────────────────────────────────────────────
        Padding(
         padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Schedule',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        letterSpacing: -0.3,
                      )),
                    const SizedBox(height: 4),
                    Text('Manage appointments and machine reports.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade500)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _showReportSheet,
                icon: const Icon(Iconsax.warning_2, size: 16),
                label: const Text('Submit Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 12),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── Tab bar ──────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(30),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicator: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(30),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade500,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 12),
              unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w400, fontSize: 12),
              tabs: [
                _tabItem(
                    "Today's Tasks", _selectedDayAppts.length),
                _tabItem('Upcoming', _upcomingAppts.length),
                _tabItem('Reports', _reports.length),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        // ── "Today's Tasks" label ────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Row(
            children: [
              Icon(Iconsax.task_square,
                  size: 13, color: Colors.grey.shade400),
              const SizedBox(width: 6),
              Text(
                "Today's Tasks",
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // ── Tab content ──────────────────────────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildApptList(_selectedDayAppts),
              _buildUpcomingList(),
              _buildReportsList(),
            ],
          ),
        ),

        // ── Collapsible calendar at the bottom ───────────────────────────────
        // CHANGE 1: Wrap the entire calendar container in GestureDetector
        // so tapping anywhere on it (even when collapsed) expands it.
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 16),
          child: GestureDetector(
            // Tap anywhere on the calendar bar → expand if collapsed
            onTap: () {
              if (!_calendarExpanded) {
                setState(() => _calendarExpanded = true);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: Colors.grey.shade100, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Month nav row + collapse toggle
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => setState(() => _calendarMonth =
                            DateTime(_calendarMonth.year,
                                _calendarMonth.month - 1, 1)),
                        icon: Icon(Iconsax.arrow_left_2,
                            size: 18, color: Colors.grey.shade600),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${_monthName(_calendarMonth.month)} ${_calendarMonth.year}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1D23)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => setState(() => _calendarMonth =
                            DateTime(_calendarMonth.year,
                                _calendarMonth.month + 1, 1)),
                        icon: Icon(Iconsax.arrow_right_2,
                            size: 18, color: Colors.grey.shade600),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      // Expand / collapse chevron
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => setState(
                            () => _calendarExpanded = !_calendarExpanded),
                        child: Icon(
                          _calendarExpanded
                              ? Iconsax.arrow_down_1
                              : Iconsax.arrow_up_2,
                          size: 18,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),

                  // Animated grid — hidden when collapsed
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 200),
                    crossFadeState: _calendarExpanded
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Column(
                      children: [
                        const SizedBox(height: 10),
                        // Weekday headers
                        Row(
                          children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
                              .map((d) => Expanded(
                                    child: Text(d,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade400)),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 8),
                        // Days grid
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _firstWeekday + _daysInMonth,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            childAspectRatio:
                                MediaQuery.of(context).size.width > 600
                                    ? 2.5
                                    : 1.2,
                            mainAxisSpacing: 2,
                            crossAxisSpacing: 2,
                          ),
                          itemBuilder: (_, i) {
                            if (i < _firstWeekday) return const SizedBox();
                            final day = i - _firstWeekday + 1;
                            final date = DateTime(_calendarMonth.year,
                                _calendarMonth.month, day);
                            final isSelected =
                                _isSameDay(date, _selectedDay);
                            final isToday = _isSameDay(date, _today);
                            final hasAppt = _hasAppt(date);

                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedDay = date),
                              child: AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 150),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.teal
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: isToday && !isSelected
                                      ? Border.all(
                                          color: Colors.teal, width: 1.5)
                                      : null,
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Text('$day',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight:
                                              isSelected || isToday
                                                  ? FontWeight.w700
                                                  : FontWeight.w400,
                                          color: isSelected
                                              ? Colors.white
                                              : isToday
                                                  ? Colors.teal
                                                  : Colors.black87,
                                        )),
                                    if (hasAppt)
                                      Container(
                                        width: 4,
                                        height: 4,
                                        margin: const EdgeInsets.only(
                                            top: 1),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.teal,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    secondChild: const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _tabItem(String label, int count) => Tab(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('$count',
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      );

  Widget _buildApptList(List<_Appointment> appts) {
    if (appts.isEmpty) return _emptyState('No appointments on this day.');
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 16),
      itemCount: appts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _ApptCard(
        appointment: appts[i],
        onToggle: () => _toggleDone(appts[i].id),
        onDelete: () => _deleteAppt(appts[i].id),
        onTap: () => _showApptDetail(appts[i]),
      ),
    );
  }

  Widget _buildUpcomingList() {
    final appts = _upcomingAppts;
    if (appts.isEmpty) return _emptyState('No upcoming appointments.');
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 16),
      itemCount: appts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final appt = appts[i];
        final showHeader =
            i == 0 || !_isSameDay(appt.date, appts[i - 1].date);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader) ...[
              if (i != 0) const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(_formatDate(appt.date),
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade500)),
              ),
            ],
            _ApptCard(
              appointment: appt,
              onToggle: () => _toggleDone(appt.id),
              onDelete: () => _deleteAppt(appt.id),
              onTap: () => _showApptDetail(appt),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReportsList() {
    if (_reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: Colors.red.shade50, shape: BoxShape.circle),
              child: Icon(Iconsax.warning_2,
                  size: 38, color: Colors.red.shade300),
            ),
            const SizedBox(height: 18),
            const Text('No machine reports yet',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1D23))),
            const SizedBox(height: 6),
            Text('Tap "Submit Report" if a machine has an issue.',
                style: TextStyle(
                    fontSize: 13, color: Colors.grey.shade500)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 16),
      itemCount: _reports.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      // CHANGE 2: Reports are now tappable — pass onTap and onStatusChange
      itemBuilder: (_, i) => _ReportCard(
        report: _reports[i],
        onTap: () => _showReportDetail(_reports[i]),
      ),
    );
  }

  Widget _emptyState(String msg) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.08),
                  shape: BoxShape.circle),
              child: const Icon(Iconsax.calendar_1,
                  size: 36, color: Colors.teal),
            ),
            const SizedBox(height: 16),
            Text(msg,
                style: TextStyle(
                    fontSize: 14, color: Colors.grey.shade500)),
          ],
        ),
      );

  // ── Submit Report bottom sheet ────────────────────────────────────────────

  void _showReportSheet() {
    _Machine? selectedMachine;
    IssueType selectedIssue = IssueType.mechanical;
    final descCtrl = TextEditingController();
    // Staff name — in a real app this would come from auth context
    final submitterCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => DraggableScrollableSheet(
          initialChildSize: 0.90,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scroll) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10)),
                        child: Icon(Iconsax.warning_2,
                            size: 18, color: Colors.red.shade400),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Submit Machine Report',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700)),
                          Text('Report an issue with a machine',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF6B7280))),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: Icon(Iconsax.close_circle,
                            color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.grey.shade100),
                Expanded(
                  child: ListView(
                    controller: scroll,
                    padding: const EdgeInsets.all(20),
                    children: [
                      // ── NEW: Submitted by field ──────────────────────────
                      const _SheetLabel(label: 'SUBMITTED BY'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: submitterCtrl,
                        decoration: _inputDeco(hint: 'Your name...'),
                        style: const TextStyle(fontSize: 13),
                      ),

                      const SizedBox(height: 16),

                      // Select machine
                      const _SheetLabel(label: 'SELECT MACHINE'),
                      const SizedBox(height: 10),
                      ...List.generate(_machines.length, (i) {
                        final m = _machines[i];
                        final sel = selectedMachine?.id == m.id;
                        return GestureDetector(
                          onTap: () =>
                              setSheet(() => selectedMachine = m),
                          child: AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 150),
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: sel
                                  ? m.color.withOpacity(0.06)
                                  : Colors.grey.shade50,
                              borderRadius:
                                  BorderRadius.circular(14),
                              border: Border.all(
                                color: sel
                                    ? m.color
                                    : Colors.grey.shade200,
                                width: sel ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color:
                                          m.color.withOpacity(0.1),
                                      borderRadius:
                                          BorderRadius.circular(10)),
                                  child: Icon(m.icon,
                                      size: 18, color: m.color),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          '${m.brand} ${m.model}',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: sel
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                              color: sel
                                                  ? m.color
                                                  : const Color(
                                                      0xFF1A1D23))),
                                      Text(m.type,
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors
                                                  .grey.shade500)),
                                    ],
                                  ),
                                ),
                                if (sel)
                                  Icon(Iconsax.tick_circle,
                                      size: 18, color: m.color),
                              ],
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 16),

                      // Issue type
                      const _SheetLabel(label: 'ISSUE TYPE'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: IssueType.values.map((t) {
                          final sel = selectedIssue == t;
                          return GestureDetector(
                            onTap: () => setSheet(
                                () => selectedIssue = t),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: sel
                                    ? t.color.withOpacity(0.1)
                                    : Colors.grey.shade100,
                                borderRadius:
                                    BorderRadius.circular(20),
                                border: Border.all(
                                    color: sel
                                        ? t.color
                                        : Colors.transparent),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(t.icon,
                                      size: 12,
                                      color: sel
                                          ? t.color
                                          : Colors.grey.shade500),
                                  const SizedBox(width: 6),
                                  Text(t.label,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: sel
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                          color: sel
                                              ? t.color
                                              : Colors
                                                  .grey.shade600)),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 16),

                      // Description
                      const _SheetLabel(label: 'DESCRIPTION'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: descCtrl,
                        maxLines: 4,
                        decoration: _inputDeco(
                            hint: 'Describe the issue in detail...'),
                        style: const TextStyle(fontSize: 13),
                      ),

                      const SizedBox(height: 24),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (selectedMachine == null ||
                                descCtrl.text.trim().isEmpty ||
                                submitterCtrl.text.trim().isEmpty) {
                              _showSnack('Please fill in all fields.',
                                  Colors.grey.shade700);
                              return;
                            }
                            setState(() {
                              _reports.insert(
                                  0,
                                  _MachineReport(
                                    id: 'RPT-${(_reports.length + 1).toString().padLeft(3, '0')}',
                                    machine: selectedMachine!,
                                    issueType: selectedIssue,
                                    description: descCtrl.text.trim(),
                                    reportedAt: DateTime.now(),
                                    submittedBy: submitterCtrl.text.trim(),
                                    status: ReportStatus.pending,
                                  ));
                            });
                            Navigator.pop(ctx);
                            _showSnack('Report submitted!',
                                Colors.red.shade400);
                            _tabController.animateTo(2);
                          },
                          icon: const Icon(Iconsax.send_2, size: 16),
                          label: const Text('Submit Report'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFFEF4444),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            textStyle: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Report detail sheet (NEW) ─────────────────────────────────────────────
  void _showReportDetail(_MachineReport report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          builder: (_, scroll) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 16),
                // Header row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                            color: report.machine.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12)),
                        child: Icon(report.machine.icon,
                            size: 20, color: report.machine.color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${report.machine.brand} ${report.machine.model}',
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A1D23))),
                            Text(report.id,
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: Icon(Iconsax.close_circle,
                            color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.grey.shade100),
                Expanded(
                  child: ListView(
                    controller: scroll,
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Status badge (tappable to change)
                      Row(
                        children: [
                          Text('STATUS',
                              style: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade500,
                                  letterSpacing: 0.8)),
                          const Spacer(),
                          // Cycle through statuses on tap
                          GestureDetector(
                            onTap: () {
                              final next = ReportStatus.values[
                                  (report.status.index + 1) %
                                      ReportStatus.values.length];
                              setState(() => report.status = next);
                              setSheet(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: report.status.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: report.status.color.withOpacity(0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(report.status.icon,
                                      size: 12, color: report.status.color),
                                  const SizedBox(width: 6),
                                  Text(report.status.label,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: report.status.color)),
                                  const SizedBox(width: 4),
                                  Icon(Iconsax.arrow_right_3,
                                      size: 10, color: report.status.color),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Details section
                      _DetailItem(
                          icon: report.issueType.icon,
                          label: report.issueType.label,
                          color: report.issueType.color),
                      const SizedBox(height: 10),
                      _DetailItem(
                          icon: Iconsax.user,
                          label: 'Submitted by ${report.submittedBy}'),
                      const SizedBox(height: 10),
                      _DetailItem(
                          icon: Iconsax.clock,
                          label: _formatDateTime(report.reportedAt)),
                      const SizedBox(height: 16),

                      // Description box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('DESCRIPTION',
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade500,
                                    letterSpacing: 0.8)),
                            const SizedBox(height: 8),
                            Text(report.description,
                                style: const TextStyle(
                                    fontSize: 13, color: Color(0xFF1A1D23),
                                    height: 1.5)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Machine details
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: report.machine.color.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: report.machine.color.withOpacity(0.15)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('MACHINE DETAILS',
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade500,
                                    letterSpacing: 0.8)),
                            const SizedBox(height: 10),
                            _DetailItem(
                                icon: Iconsax.info_circle,
                                label: report.machine.type),
                            const SizedBox(height: 6),
                            _DetailItem(
                                icon: Iconsax.maximize_3,
                                label: report.machine.buildSize),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    final min  = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  •  $hour:$min $ampm';
  }

  // ── Appointment detail sheet ──────────────────────────────────────────────

  void _showApptDetail(_Appointment appt) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Row(children: [
              Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Iconsax.calendar_1,
                      size: 20, color: Colors.teal)),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(appt.title,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                  Text(_formatDate(appt.date),
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500)),
                ],
              )),
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Iconsax.close_circle,
                      color: Colors.grey.shade400)),
            ]),
            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade100),
            const SizedBox(height: 10),
            _DetailItem(icon: Iconsax.clock, label: appt.timeSlot),
            if (appt.userName != null) ...[
              const SizedBox(height: 8),
              _DetailItem(icon: Iconsax.user, label: appt.userName!),
            ],
            if (appt.requestId != null) ...[
              const SizedBox(height: 8),
              _DetailItem(
                  icon: Iconsax.document_text,
                  label: appt.requestId!,
                  color: Colors.teal),
            ],
            if (appt.note != null) ...[
              const SizedBox(height: 8),
              _DetailItem(
                  icon: Iconsax.note_text, label: appt.note!),
            ],
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                  child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteAppt(appt.id);
                },
                icon: Icon(Iconsax.trash,
                    size: 14, color: Colors.red.shade400),
                label: const Text('Delete'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade400,
                    side: BorderSide(color: Colors.red.shade300),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding:
                        const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
              )),
              const SizedBox(width: 10),
              Expanded(
                  child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _toggleDone(appt.id);
                },
                icon: Icon(
                    appt.isDone
                        ? Iconsax.close_circle
                        : Iconsax.tick_circle,
                    size: 14),
                label:
                    Text(appt.isDone ? 'Mark Undone' : 'Mark Done'),
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                        appt.isDone ? Colors.grey.shade400 : Colors.teal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding:
                        const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
              )),
            ]),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Appointment Card ──────────────────────────────────────────────────────────

class _ApptCard extends StatelessWidget {
  const _ApptCard({
    required this.appointment,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
  });

  final _Appointment appointment;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: a.isDone ? Colors.grey.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100, width: 1.5),
          boxShadow: a.isDone
              ? null
              : [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 3))
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 5,
              height: 74,
              decoration: BoxDecoration(
                color: a.isDone ? Colors.grey.shade200 : Colors.teal,
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    color: a.isDone
                        ? Colors.grey.shade100
                        : Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(Iconsax.calendar_1,
                    size: 18,
                    color: a.isDone
                        ? Colors.grey.shade400
                        : Colors.teal),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.title,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: a.isDone
                                ? Colors.grey.shade400
                                : const Color(0xFF1A1D23),
                            decoration: a.isDone
                                ? TextDecoration.lineThrough
                                : null),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Row(children: [
                      Icon(Iconsax.clock,
                          size: 10,
                          color: a.isDone
                              ? Colors.grey.shade400
                              : Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(a.timeSlot,
                          style: TextStyle(
                              fontSize: 11,
                              color: a.isDone
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade500)),
                    ]),
                    if (a.userName != null) ...[
                      const SizedBox(height: 2),
                      Row(children: [
                        Icon(Iconsax.user,
                            size: 10, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text(a.userName!,
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade400)),
                      ]),
                    ],
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: a.isDone ? Colors.teal : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: a.isDone
                            ? Colors.teal
                            : Colors.grey.shade300,
                        width: 1.5),
                  ),
                  child: a.isDone
                      ? const Icon(Icons.check,
                          size: 12, color: Colors.white)
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Report Card ───────────────────────────────────────────────────────────────
// CHANGE 2: Added status badge, submittedBy, and onTap

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report, required this.onTap});
  final _MachineReport report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = report;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100, width: 1.5),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: Row(
          children: [
            // Left accent bar — colored by issue type
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: r.issueType.color,
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 14),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: r.machine.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(r.machine.icon,
                    size: 18, color: r.machine.color),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Machine name + status badge on same row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${r.machine.brand} ${r.machine.model}',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1D23)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        // ── Status badge ───────────────────────────────
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: r.status.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: r.status.color.withOpacity(0.35),
                                width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(r.status.icon,
                                  size: 9, color: r.status.color),
                              const SizedBox(width: 4),
                              Text(r.status.label,
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: r.status.color)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(children: [
                      Icon(r.issueType.icon,
                          size: 10, color: r.issueType.color),
                      const SizedBox(width: 4),
                      Text(r.issueType.label,
                          style: TextStyle(
                              fontSize: 11,
                              color: r.issueType.color,
                              fontWeight: FontWeight.w500)),
                    ]),
                    const SizedBox(height: 3),
                    Text(r.description,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    // ── Submitted by ──────────────────────────────────
                    Row(children: [
                      Icon(Iconsax.user,
                          size: 10, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(r.submittedBy,
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade400)),
                      const Spacer(),
                      Text(_timeAgo(r.reportedAt),
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey.shade400)),
                      const SizedBox(width: 10),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _SheetLabel extends StatelessWidget {
  const _SheetLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Text(label,
      style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
          letterSpacing: 0.8));
}

class _DetailItem extends StatelessWidget {
  const _DetailItem(
      {required this.icon, required this.label, this.color});
  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 14, color: color ?? Colors.grey.shade500),
        const SizedBox(width: 10),
        Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: color ?? Colors.grey.shade700,
                    fontWeight: color != null
                        ? FontWeight.w600
                        : FontWeight.normal))),
      ]);
}

InputDecoration _inputDeco({required String hint}) => InputDecoration(
      hintText: hint,
      hintStyle:
          TextStyle(color: Colors.grey.shade400, fontSize: 13),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Colors.teal, width: 1.5)),
    );
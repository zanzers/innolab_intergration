part of 'maintenance_screen.dart';

// ─────────────────────────────────────────────
//  MOBILE MACHINE VIEW ROOT
// ─────────────────────────────────────────────
class _MobileMachineView extends StatefulWidget {
  const _MobileMachineView();
  @override
  State<_MobileMachineView> createState() => _MobileMachineViewState();
}

class _MobileMachineViewState extends State<_MobileMachineView>
    with SingleTickerProviderStateMixin, _MaintenanceStateMixin {
  late TabController _tab;
  late final MachineController _machineController;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 5, vsync: this);
    _tab.addListener(() => setState(() {}));

    if (!Get.isRegistered<MachineController>()) {
      Get.put(MachineController());
    }
    _machineController = MachineController.instance;
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final schedule = mergedSchedule;
    final percents = weeklyUsagePercents;
    final totalMins = totalWeeklyMinutes;

    return Obx(
      () => Scaffold(
        backgroundColor: _C.bg,
        appBar: _buildAppBar(schedule),
        body: TabBarView(
          controller: _tab,
          children: [
            _MobileMachinesTab(
              machines: _machineController.machines,
              onMachineTap: _showMachineDetail,
              onEditMachine: _editMachine,
            ),
            _MobileUsageTab(percents: percents, totalMinutes: totalMins),
            _MobileScheduleTab(tasks: schedule),
            const _SharedHistoryContent(
              padding: EdgeInsets.fromLTRB(14, 16, 14, 40),
            ),
            _MobileIssuesTab(issues: _issues),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(List<ScheduledTask> schedule) {
    return AppBar(
      backgroundColor: _C.surface,
      elevation: 0,
      titleSpacing: 16,
      title: Row(children: [
        Container(width: 4, height: 22,
          decoration: BoxDecoration(
            gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [_C.indigo, _C.violet]),
            borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 10),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Maintenance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.4, color: _C.textPrimary)),
          Text('Equipment & Maintenance', style: TextStyle(fontSize: 11, color: _C.textSecondary)),
        ]),
      ]),
      actions: [
        IconButton(
          icon: const Icon(Icons.add_rounded, color: _C.indigo, size: 22),
          onPressed: _addMachine,
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: _C.surface,
          child: Obx(() => TabBar(
            controller: _tab,
            isScrollable: true,
            labelColor: _C.indigo,
            unselectedLabelColor: _C.textMuted,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            indicatorColor: _C.indigo,
            indicatorWeight: 2.5,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: _C.border,
            tabAlignment: TabAlignment.start,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            tabs: [
              _TabItem(label: 'Maintenance', count: _machineController.machines.length),
              _TabItem(label: 'Usage', count: _usageSessions.length),
              _TabItem(label: 'Schedule',
                count: schedule.where((s) => s.status != ScheduleStatus.completed).length),
              _TabItem(label: 'History', count: _machineController.machines.length),
              _TabItem(label: 'Issues',
                count: _issues.where((i) => i.status != IssueStatus.fixed).length,
                alertCount: _issues.where((i) => i.priority == IssuePriority.critical && i.status != IssueStatus.fixed).length),
            ],
          )),
        ),
      ),
    );
  }

  void _showMachineDetail(MachineModel machine) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.80,
        maxChildSize: 0.95,
        builder: (_, sc) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          child: Column(children: [
            Container(margin: const EdgeInsets.only(top: 10), width: 36, height: 4,
              decoration: BoxDecoration(color: _C.border, borderRadius: BorderRadius.circular(4))),
            Expanded(child: SingleChildScrollView(
              controller: sc,
              child: _SharedMachineDetailContent(
                machine: machine,
                onClose: () => Navigator.pop(context),
              ),
            )),
          ]),
        ),
      ),
    );
  }

  void _editMachine(MachineModel machine) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        builder: (_, sc) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(children: [
            Container(margin: const EdgeInsets.only(top: 10), width: 36, height: 4,
              decoration: BoxDecoration(color: _C.border, borderRadius: BorderRadius.circular(4))),
            Expanded(
              child: SingleChildScrollView(
                controller: sc,
                child: _EditMachinePanel(
                  machine: machine,
                  onClose: () => Navigator.pop(context),
                  onSave: (updated) async {
                    await _machineController.updateMachine(updated);
                  },
                  onDelete: (id) async {
                    await _machineController.deleteMachine(id);
                  },
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _addMachine() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        builder: (_, sc) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(children: [
            Container(margin: const EdgeInsets.only(top: 10), width: 36, height: 4,
              decoration: BoxDecoration(color: _C.border, borderRadius: BorderRadius.circular(4))),
            Expanded(
              child: SingleChildScrollView(
                controller: sc,
                child: _AddMachinePanel(
                  onClose: () => Navigator.pop(context),
                  onAdd: (newMachine) async {
                    await _machineController.addMachine(newMachine);
                  },
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  MOBILE: MACHINES TAB
// ─────────────────────────────────────────────
class _MobileMachinesTab extends StatelessWidget {
  final List<MachineModel> machines;
  final ValueChanged<MachineModel> onMachineTap;
  final ValueChanged<MachineModel> onEditMachine;

  const _MobileMachinesTab({
    required this.machines,
    required this.onMachineTap,
    required this.onEditMachine,
  });

  @override
  Widget build(BuildContext context) {
    final inUse = machines.where((m) => m.currentJob != null).length;
    final available = machines.where((m) => (m.status == MachineStatus.operational || m.status == MachineStatus.idle) && m.currentJob == null).length;
    final maint = machines.where((m) => m.status == MachineStatus.underMaintenance).length;
    return Column(children: [
      Container(
        color: _C.surface,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _MobileStatCard(label: 'In Use', value: inUse.toString(), color: _C.emerald, icon: Icons.circle_rounded),
            const SizedBox(width: 8),
            _MobileStatCard(label: 'Available', value: available.toString(), color: _C.indigo, icon: Icons.check_circle_rounded),
            const SizedBox(width: 8),
            _MobileStatCard(label: 'Maintenance', value: maint.toString(), color: _C.amber, icon: Icons.build_rounded),
          ]),
        ),
      ),
      Expanded(
        child: machines.isEmpty
            ? const Center(
                child: Text(
                  'No Machine saved',
                  style: TextStyle(fontSize: 13, color: _C.textMuted),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 40),
                itemCount: machines.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _MobileMachineCard(
                  machine: machines[i],
                  onTap: () => onMachineTap(machines[i]),
                  onEdit: () => onEditMachine(machines[i]),
                ),
              ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────
//  MOBILE: MACHINE CARD
// ─────────────────────────────────────────────
class _MobileMachineCard extends StatelessWidget {
  final MachineModel machine;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _MobileMachineCard({
    required this.machine,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final ds = _displayStatus(machine);
    final sm = _statusMeta(machine.status);
    final usedBy = machine.currentOperator ?? machine.reservedBy;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: machine.status == MachineStatus.broken ? _C.rose.withOpacity(0.35) : _C.border),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Column(children: [
            Container(height: 3, color: ds.color),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: sm.light, borderRadius: BorderRadius.circular(9)),
                    child: Icon(_typeIcon(machine.type), color: sm.color, size: 16)),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(machine.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _C.textPrimary)),
                    Text('${machine.id}  ·  ${machine.model}', style: const TextStyle(fontSize: 11, color: _C.textMuted)),
                  ])),
                  _SharedStatusBadge(displayStatus: ds),
                ]),
                const SizedBox(height: 10),
                Row(children: [_TypeBadge(type: machine.type)]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Used By', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _C.textMuted, letterSpacing: 0.3)),
                    const SizedBox(height: 3),
                    usedBy != null
                        ? Row(children: [
                            _Avatar(name: usedBy, size: 18, color: machine.currentOperator != null ? _C.emerald : _C.sky),
                            const SizedBox(width: 5),
                            Expanded(child: Text(usedBy,
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                                color: machine.currentOperator != null ? _C.emerald : _C.sky),
                              overflow: TextOverflow.ellipsis)),
                          ])
                        : const Text('—', style: TextStyle(fontSize: 12, color: _C.textMuted)),
                  ])),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, size: 18, color: _C.indigo),
                    onPressed: onEdit,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    tooltip: 'Edit machine',
                  ),
                ]),
                if (machine.currentJob != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: _C.emeraldLight, borderRadius: BorderRadius.circular(8)),
                    child: Row(children: [
                      Container(width: 6, height: 6, margin: const EdgeInsets.only(right: 6),
                        decoration: const BoxDecoration(color: _C.emerald, shape: BoxShape.circle)),
                      Text('Active: ${machine.currentJob}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _C.emerald, fontFamily: 'monospace')),
                    ]),
                  ),
                ],
                const SizedBox(height: 6),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  const Text('View details', style: TextStyle(fontSize: 11, color: _C.indigo, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 2),
                  const Icon(Icons.chevron_right_rounded, size: 16, color: _C.indigo),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  MOBILE: USAGE TAB
// ─────────────────────────────────────────────
class _MobileUsageTab extends StatefulWidget {
  final Map<String, double> percents;
  final int totalMinutes;
  const _MobileUsageTab({required this.percents, required this.totalMinutes});
  @override
  State<_MobileUsageTab> createState() => _MobileUsageTabState();
}

class _MobileUsageTabState extends State<_MobileUsageTab> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final machinesWithSessions = _machines.where((m) =>
      _usageSessions.any((s) => s.machineId == m.id)).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 40),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _SharedWeeklyUsageChart(percents: widget.percents, totalMinutes: widget.totalMinutes),
        const SizedBox(height: 20),
        const Text('Usage History Per Machine',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _C.textPrimary)),
        const SizedBox(height: 4),
        const Text('Tap a machine to see its sessions',
          style: TextStyle(fontSize: 12, color: _C.textSecondary)),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: machinesWithSessions.map((m) {
              final isSelected = _selectedId == m.id;
              final pct = widget.percents[m.id] ?? 0.0;
              final ds = _displayStatus(m);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedId = isSelected ? null : m.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? _C.indigo : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? _C.indigo : _C.border),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(width: 7, height: 7,
                        decoration: BoxDecoration(color: isSelected ? Colors.white : ds.color, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text(m.name.split(' ').take(2).join(' '),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : _C.textPrimary)),
                      const SizedBox(width: 5),
                      Text('${pct.toStringAsFixed(0)}%',
                        style: TextStyle(fontSize: 11, color: isSelected ? Colors.white.withOpacity(0.8) : _C.textMuted)),
                    ]),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (_selectedId != null) ...[
          const SizedBox(height: 16),
          Builder(builder: (_) {
            final m = _machines.firstWhere((x) => x.id == _selectedId!);
            final sessions = _usageSessions.where((s) => s.machineId == _selectedId && s.isThisWeek).toList()
              ..sort((a, b) => b.start.compareTo(a.start));
            final pct = widget.percents[_selectedId] ?? 0.0;
            final mins = ((pct / 100) * widget.totalMinutes).round();
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _C.border)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(m.name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _C.textPrimary))),
                    _TypeBadge(type: m.type),
                  ]),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: _C.indigoLight, borderRadius: BorderRadius.circular(9)),
                    child: Row(children: [
                      const Icon(Icons.bar_chart_rounded, size: 14, color: _C.indigo),
                      const SizedBox(width: 6),
                      Expanded(child: Text(
                        'This Week: ${pct.toStringAsFixed(1)}%  ·  ${mins ~/ 60}h${mins % 60 > 0 ? ' ${mins % 60}m' : ''} of ${widget.totalMinutes ~/ 60}h total',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _C.indigo))),
                    ]),
                  ),
                ]),
              ),
              const SizedBox(height: 10),
              if (sessions.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: _C.border)),
                  child: const Center(child: Text('No sessions this week', style: TextStyle(fontSize: 13, color: _C.textMuted))))
              else
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _C.border)),
                  child: _SharedUsageSessionTable(sessions: sessions)),
            ]);
          }),
        ],
        const SizedBox(height: 24),
        const Text('All Sessions This Week',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _C.textPrimary)),
        const SizedBox(height: 12),
        ..._machines.map((m) {
          final machineSessions = _usageSessions
              .where((s) => s.machineId == m.id && s.isThisWeek).toList()
              ..sort((a, b) => b.start.compareTo(a.start));
          if (machineSessions.isEmpty) return const SizedBox.shrink();
          final pct = widget.percents[m.id] ?? 0.0;
          final mins = ((pct / 100) * widget.totalMinutes).round();
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  Container(width: 9, height: 9,
                    decoration: BoxDecoration(color: _displayStatus(m).color, shape: BoxShape.circle)),
                  const SizedBox(width: 7),
                  Expanded(child: Text(m.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _C.textPrimary))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(color: _C.indigoLight, borderRadius: BorderRadius.circular(7)),
                    child: Text(
                      '${pct.toStringAsFixed(0)}%  ·  ${mins ~/ 60}h${mins % 60 > 0 ? ' ${mins % 60}m' : ''}',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _C.indigo))),
                ]),
              ),
              ...machineSessions.map((s) => _MobileSessionCard(session: s)),
            ]),
          );
        }),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  MOBILE: SESSION CARD
// ─────────────────────────────────────────────
class _MobileSessionCard extends StatelessWidget {
  final UsageSession session;
  const _MobileSessionCard({required this.session});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(10),
      border: Border.all(color: _C.border)),
    child: Row(children: [
      _Avatar(name: session.staffName, size: 34, color: _C.indigo),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(session.staffName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _C.textPrimary)),
        const SizedBox(height: 3),
        Row(children: [
          const Icon(Icons.access_time_rounded, size: 11, color: _C.textMuted),
          const SizedBox(width: 4),
          Text('${_fmtTime(session.start)} – ${_fmtTime(session.end)}',
            style: const TextStyle(fontSize: 11, color: _C.textSecondary)),
        ]),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(color: _C.indigoLight, borderRadius: BorderRadius.circular(7)),
          child: Text(_formatDuration(session.duration),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _C.indigo))),
        if (session.jobId != null) ...[
          const SizedBox(height: 3),
          Text(session.jobId!, style: const TextStyle(fontSize: 10, color: _C.textMuted, fontFamily: 'monospace')),
        ],
      ]),
    ]),
  );
}

// ─────────────────────────────────────────────
//  MOBILE: SCHEDULE TAB
// ─────────────────────────────────────────────
class _MobileScheduleTab extends StatelessWidget {
  final List<ScheduledTask> tasks;
  const _MobileScheduleTab({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final overdue    = tasks.where((t) => t.status == ScheduleStatus.overdue).toList();
    final inProgress = tasks.where((t) => t.status == ScheduleStatus.inProgress).toList();
    final upcoming   = tasks.where((t) => t.status == ScheduleStatus.upcoming).toList();
    final completed  = tasks.where((t) => t.status == ScheduleStatus.completed).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 40),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (overdue.isNotEmpty) ...[
          _SectionLabel(label: 'Overdue', icon: Icons.warning_rounded, color: _C.rose),
          const SizedBox(height: 8),
          ...overdue.map((t) => _SharedScheduleCard(task: t)),
          const SizedBox(height: 18),
        ],
        if (inProgress.isNotEmpty) ...[
          _SectionLabel(label: 'In Progress', icon: Icons.build_rounded, color: _C.amber),
          const SizedBox(height: 8),
          ...inProgress.map((t) => _SharedScheduleCard(task: t)),
          const SizedBox(height: 18),
        ],
        _SectionLabel(label: 'Upcoming', icon: Icons.calendar_today_rounded, color: _C.indigo),
        const SizedBox(height: 8),
        ...upcoming.map((t) => _SharedScheduleCard(task: t)),
        if (completed.isNotEmpty) ...[
          const SizedBox(height: 18),
          _SectionLabel(label: 'Completed', icon: Icons.check_circle_rounded, color: _C.emerald),
          const SizedBox(height: 8),
          ...completed.map((t) => _SharedScheduleCard(task: t)),
        ],
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  MOBILE: ISSUES TAB
// ─────────────────────────────────────────────
class _MobileIssuesTab extends StatelessWidget {
  final List<ReportedIssue> issues;
  const _MobileIssuesTab({required this.issues});
  @override
  Widget build(BuildContext context) {
    final sorted = [...issues]..sort((a, b) {
      const so = [IssueStatus.inProgress, IssueStatus.pending, IssueStatus.fixed];
      final si = so.indexOf(a.status), sb = so.indexOf(b.status);
      if (si != sb) return si.compareTo(sb);
      const po = [IssuePriority.critical, IssuePriority.high, IssuePriority.medium, IssuePriority.low];
      return po.indexOf(a.priority).compareTo(po.indexOf(b.priority));
    });
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 40),
      child: Column(children: sorted.map((i) => _SharedIssueCard(issue: i)).toList()),
    );
  }
}

// ─────────────────────────────────────────────
//  MOBILE-ONLY SMALL WIDGETS
// ─────────────────────────────────────────────
class _MobileStatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _MobileStatCard({required this.label, required this.value, required this.color, required this.icon});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withOpacity(0.15))),
    child: Row(children: [
      Icon(icon, size: 13, color: color),
      const SizedBox(width: 6),
      Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
      const SizedBox(width: 5),
      Text(label, style: TextStyle(fontSize: 11, color: color.withOpacity(0.8))),
    ]),
  );
}
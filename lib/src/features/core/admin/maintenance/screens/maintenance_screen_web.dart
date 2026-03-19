part of 'maintenance_screen.dart';

// ─────────────────────────────────────────────
//  WEB MACHINE VIEW ROOT
// ─────────────────────────────────────────────
class _WebMaintenanceView extends StatefulWidget {
  const _WebMaintenanceView();
  @override
  State<_WebMaintenanceView> createState() => _WebMaintenanceViewState();
}

class _WebMaintenanceViewState extends State<_WebMaintenanceView>
    with SingleTickerProviderStateMixin, _MaintenanceStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 5, vsync: this);
    _tab.addListener(() => setState(() {}));
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

    return Scaffold(
      backgroundColor: _C.bg,
      body: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ── TOP HEADER ──
            Container(
              color: _C.surface,
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _buildHeader(schedule),
                const SizedBox(height: 20),
                _buildTopStats(schedule),
                const SizedBox(height: 20),
                TabBar(
                  controller: _tab,
                  isScrollable: true,
                  labelColor: _C.indigo,
                  unselectedLabelColor: _C.textMuted,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  indicatorColor: _C.indigo,
                  indicatorWeight: 2.5,
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: _C.border,
                  tabs: [
                    _TabItem(label: 'Maintenance', count: _machines.length),
                    _TabItem(label: 'Usage', count: _usageSessions.length),
                    _TabItem(label: 'Schedule',
                      count: schedule.where((s) => s.status != ScheduleStatus.completed).length),
                    _TabItem(label: 'History', count: _logs.length),
                    _TabItem(label: 'Issues',
                      count: _issues.where((i) => i.status != IssueStatus.fixed).length,
                      alertCount: _issues.where((i) => i.priority == IssuePriority.critical && i.status != IssueStatus.fixed).length),
                  ],
                ),
              ]),
            ),
            // ── TAB BODY ──
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  _WebMachinesTab(
                    machines: _machines,
                    selectedMachine: selectedMachine,
                    onSelect: (m) => setState(() => selectedMachine = selectedMachine?.id == m.id ? null : m),
                  ),
                  _WebUsageTab(percents: percents, totalMinutes: totalMins),
                  _WebScheduleTab(tasks: schedule),
                  _WebHistoryTab(logs: _logs),
                  _WebIssuesTab(issues: _issues),
                ],
              ),
            ),
          ]),
        ),
        // ── MACHINE DETAIL PANEL ──
        if (selectedMachine != null && _tab.index == 0)
          Container(
            width: 360,
            constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
            decoration: const BoxDecoration(color: _C.surface, border: Border(left: BorderSide(color: _C.border))),
            child: _SharedMachineDetailContent(
              machine: selectedMachine!,
              onClose: () => setState(() => selectedMachine = null),
            ),
          ),
      ]),
    );
  }

  Widget _buildHeader(List<ScheduledTask> schedule) {
    return Row(children: [
      Expanded(child: Row(children: [
        Container(width: 6, height: 32,
          decoration: BoxDecoration(
            gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [_C.indigo, _C.violet]),
            borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 14),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Maintenance', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.6, color: _C.textPrimary)),
          Text('Equipment status, usage tracking & maintenance', style: TextStyle(fontSize: 13, color: _C.textSecondary)),
        ]),
      ])),
      if (_issues.any((i) => i.priority == IssuePriority.critical && i.status != IssueStatus.fixed))
        _PillBadge(
          label: '${_issues.where((i) => i.priority == IssuePriority.critical && i.status != IssueStatus.fixed).length} Critical Issues',
          color: _C.rose, light: _C.roseLight, icon: Icons.error_rounded),
      const SizedBox(width: 8),
      if (schedule.any((s) => s.status == ScheduleStatus.overdue))
        _PillBadge(label: 'Overdue Tasks', color: _C.amber, light: _C.amberLight, icon: Icons.schedule_rounded),
    ]);
  }

  Widget _buildTopStats(List<ScheduledTask> schedule) {
    final inUse = _machines.where((m) => m.currentJob != null).length;
    final available = _machines.where((m) => m.status == MachineStatus.operational && m.currentJob == null || m.status == MachineStatus.idle).length;
    final maint = _machines.where((m) => m.status == MachineStatus.underMaintenance).length;
    final broken = _machines.where((m) => m.status == MachineStatus.broken).length;
    final openIssues = _issues.where((i) => i.status != IssueStatus.fixed).length;
    final overdue = schedule.where((s) => s.status == ScheduleStatus.overdue).length;

    return Row(children: [
      _StatChip(label: 'In Use', value: inUse.toString(), color: _C.emerald, icon: Icons.circle_rounded),
      const SizedBox(width: 10),
      _StatChip(label: 'Available', value: available.toString(), color: _C.indigo, icon: Icons.check_circle_rounded),
      const SizedBox(width: 10),
      _StatChip(label: 'Maintenance', value: maint.toString(), color: _C.amber, icon: Icons.build_rounded),
      const SizedBox(width: 10),
      _StatChip(label: 'Down', value: broken.toString(), color: _C.rose, icon: Icons.error_rounded),
      const SizedBox(width: 10),
      _StatChip(label: 'Open Issues', value: openIssues.toString(), color: _C.violet, icon: Icons.report_rounded),
      const SizedBox(width: 10),
      _StatChip(label: 'Overdue', value: overdue.toString(), color: _C.amber, icon: Icons.warning_rounded),
      const Spacer(),
      Text('${_machines.length} total machines', style: const TextStyle(fontSize: 12, color: _C.textMuted)),
    ]);
  }
}

// ─────────────────────────────────────────────
//  WEB: MACHINES TAB  (status table)
// ─────────────────────────────────────────────
class _WebMachinesTab extends StatelessWidget {
  final List<Machine> machines;
  final Machine? selectedMachine;
  final ValueChanged<Machine> onSelect;

  const _WebMachinesTab({required this.machines, required this.selectedMachine, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 40),
      child: _WebTableBox(
        child: Column(children: [
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(color: _C.bg, borderRadius: BorderRadius.vertical(top: Radius.circular(14))),
            child: const Row(children: [
              Expanded(flex: 4, child: _WebTH('Machine')),
              Expanded(flex: 2, child: _WebTH('Type')),
              Expanded(flex: 2, child: _WebTH('Status')),
              Expanded(flex: 2, child: _WebTH('Used By')),
              Expanded(flex: 2, child: _WebTH('Last Maintenance')),
              Expanded(flex: 2, child: _WebTH('Next Maintenance')),
              Expanded(flex: 2, child: _WebTH('Uptime')),
            ]),
          ),
          const Divider(height: 1, color: _C.border),
          ...machines.asMap().entries.map((e) => _WebMachineRow(
            machine: e.value,
            isEven: e.key.isEven,
            isSelected: selectedMachine?.id == e.value.id,
            onTap: () => onSelect(e.value),
          )),
        ]),
      ),
    );
  }
}

class _WebMachineRow extends StatelessWidget {
  final Machine machine;
  final bool isEven, isSelected;
  final VoidCallback onTap;
  const _WebMachineRow({required this.machine, required this.isEven, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ds = _displayStatus(machine);
    final nextIsOverdue = machine.nextMaintenance.isBefore(DateTime.now());
    final nextDays = machine.nextMaintenance.difference(DateTime.now()).inDays;
    final nextColor = nextIsOverdue ? _C.rose : nextDays <= 7 ? _C.amber : _C.textSecondary;
    final usedBy = machine.currentOperator ?? machine.reservedBy;

    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? _C.indigoLight : isEven ? Colors.white : const Color(0xFFFAFBFD),
          border: Border(left: BorderSide(color: isSelected ? _C.indigo : Colors.transparent, width: 3)),
        ),
        child: Row(children: [
          // Name + model
          Expanded(flex: 4, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(machine.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _C.textPrimary)),
            Text('${machine.id}  ·  ${machine.model}', style: const TextStyle(fontSize: 11, color: _C.textMuted)),
            if (machine.currentJob != null)
              Padding(padding: const EdgeInsets.only(top: 3), child: Row(children: [
                Container(width: 5, height: 5, margin: const EdgeInsets.only(right: 4),
                  decoration: const BoxDecoration(color: _C.emerald, shape: BoxShape.circle)),
                Text(machine.currentJob!, style: const TextStyle(fontSize: 10, color: _C.emerald, fontFamily: 'monospace', fontWeight: FontWeight.w600)),
              ])),
          ])),
          // Type
          Expanded(flex: 2, child: _TypeBadge(type: machine.type)),
          // Status
          Expanded(flex: 2, child: _SharedStatusBadge(displayStatus: ds)),
          // Used By
          Expanded(flex: 2, child: usedBy != null
            ? Row(children: [
                _Avatar(name: usedBy, size: 22, color: machine.currentOperator != null ? _C.emerald : _C.sky),
                const SizedBox(width: 6),
                Expanded(child: Text(usedBy.split(' ').first,
                  style: TextStyle(fontSize: 12, color: machine.currentOperator != null ? _C.emerald : _C.sky, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis)),
              ])
            : const Text('—', style: TextStyle(fontSize: 12, color: _C.textMuted))),
          // Last maintenance
          Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_daysAgo(machine.lastMaintenance), style: const TextStyle(fontSize: 12, color: _C.textSecondary)),
            Text(_fmtDate(machine.lastMaintenance), style: const TextStyle(fontSize: 10, color: _C.textMuted)),
          ])),
          // Next maintenance
          Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(nextIsOverdue ? 'Overdue!' : 'In ${nextDays}d',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: nextColor)),
            Text(_fmtDate(machine.nextMaintenance), style: const TextStyle(fontSize: 10, color: _C.textMuted)),
          ])),
          // Uptime
          Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${machine.uptimePercent}%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
              color: machine.uptimePercent >= 90 ? _C.emerald : machine.uptimePercent >= 75 ? _C.amber : _C.rose)),
            const SizedBox(height: 4),
            ClipRRect(borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(value: machine.uptimePercent / 100, minHeight: 4,
                backgroundColor: _C.border,
                valueColor: AlwaysStoppedAnimation(machine.uptimePercent >= 90 ? _C.emerald : machine.uptimePercent >= 75 ? _C.amber : _C.rose))),
          ])),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  WEB: USAGE TAB
// ─────────────────────────────────────────────
class _WebUsageTab extends StatefulWidget {
  final Map<String, double> percents;
  final int totalMinutes;
  const _WebUsageTab({required this.percents, required this.totalMinutes});
  @override
  State<_WebUsageTab> createState() => _WebUsageTabState();
}

class _WebUsageTabState extends State<_WebUsageTab> {
  String? _selectedMachineId;

  @override
  Widget build(BuildContext context) {
    // Which machines have sessions?
    final machinesWithSessions = _machines.where((m) =>
      _usageSessions.any((s) => s.machineId == m.id)).toList();

    List<UsageSession> sessions;
    if (_selectedMachineId != null) {
      sessions = _usageSessions
          .where((s) => s.machineId == _selectedMachineId)
          .toList()
        ..sort((a, b) => b.start.compareTo(a.start));
    } else {
      sessions = <UsageSession>[];
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 40),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Weekly chart
        _SharedWeeklyUsageChart(percents: widget.percents, totalMinutes: widget.totalMinutes),
        const SizedBox(height: 24),

        // Per-machine session history
        const Text('Usage History Per Machine',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _C.textPrimary)),
        const SizedBox(height: 4),
        const Text('Select a machine to view session records',
          style: TextStyle(fontSize: 12, color: _C.textSecondary)),
        const SizedBox(height: 12),

        // Machine selector chips
        Wrap(spacing: 8, runSpacing: 8,
          children: machinesWithSessions.map((m) {
            final isSelected = _selectedMachineId == m.id;
            final pct = widget.percents[m.id] ?? 0.0;
            final ds = _displayStatus(m);
            return GestureDetector(
              onTap: () => setState(() => _selectedMachineId = isSelected ? null : m.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected ? _C.indigo : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isSelected ? _C.indigo : _C.border),
                  boxShadow: isSelected ? [BoxShadow(color: _C.indigo.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))] : [],
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 8, height: 8,
                    decoration: BoxDecoration(color: isSelected ? Colors.white : ds.color, shape: BoxShape.circle)),
                  const SizedBox(width: 7),
                  Text(m.name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : _C.textPrimary)),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white.withOpacity(0.2) : _C.indigoLight,
                      borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      pct == 0 ? '0%' : '${pct.toStringAsFixed(0)}%',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : _C.indigo))),
                ]),
              ),
            );
          }).toList()),

        if (_selectedMachineId != null) ...[
          const SizedBox(height: 20),
          Builder(builder: (_) {
            final m = _machines.firstWhere((x) => x.id == _selectedMachineId!);
            final pct = widget.percents[_selectedMachineId] ?? 0.0;
            final mins = ((pct / 100) * widget.totalMinutes).round();
            return Row(children: [
              Text(m.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _C.textPrimary)),
              const SizedBox(width: 12),
              _TypeBadge(type: m.type),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: _C.indigoLight, borderRadius: BorderRadius.circular(9)),
                child: Text(
                  'This Week: ${pct.toStringAsFixed(1)}%  ·  ${(mins ~/ 60)}h${mins % 60 > 0 ? ' ${mins % 60}m' : ''} of ${widget.totalMinutes ~/ 60}h total',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _C.indigo))),
            ]);
          }),
          const SizedBox(height: 12),
          if (sessions.isEmpty)
            const Center(child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Text('No sessions recorded this week', style: TextStyle(color: _C.textMuted, fontSize: 13))))
          else
            _WebTableBox(child: _SharedUsageSessionTable(sessions: sessions)),
        ] else
          const SizedBox(height: 32),

        // All machines summary
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
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 10, height: 10,
                  decoration: BoxDecoration(color: _displayStatus(m).color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(m.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _C.textPrimary)),
                const SizedBox(width: 10),
                _TypeBadge(type: m.type),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _C.indigoLight, borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    'This Week: ${pct.toStringAsFixed(0)}%  ·  ${mins ~/ 60}h${mins % 60 > 0 ? ' ${mins % 60}m' : ''}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _C.indigo))),
              ]),
              const SizedBox(height: 8),
              _WebTableBox(child: _SharedUsageSessionTable(sessions: machineSessions)),
            ]),
          );
        }),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  WEB: SCHEDULE, HISTORY, ISSUES TABS
// ─────────────────────────────────────────────
class _WebScheduleTab extends StatelessWidget {
  final List<ScheduledTask> tasks;
  const _WebScheduleTab({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final overdue    = tasks.where((t) => t.status == ScheduleStatus.overdue).toList();
    final inProgress = tasks.where((t) => t.status == ScheduleStatus.inProgress).toList();
    final upcoming   = tasks.where((t) => t.status == ScheduleStatus.upcoming).toList();
    final completed  = tasks.where((t) => t.status == ScheduleStatus.completed).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 40),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (overdue.isNotEmpty) ...[
          _SectionLabel(label: 'Overdue', icon: Icons.warning_rounded, color: _C.rose),
          const SizedBox(height: 8),
          ...overdue.map((t) => _SharedScheduleCard(task: t)),
          const SizedBox(height: 20),
        ],
        if (inProgress.isNotEmpty) ...[
          _SectionLabel(label: 'In Progress', icon: Icons.build_rounded, color: _C.amber),
          const SizedBox(height: 8),
          ...inProgress.map((t) => _SharedScheduleCard(task: t)),
          const SizedBox(height: 20),
        ],
        _SectionLabel(label: 'Upcoming', icon: Icons.calendar_today_rounded, color: _C.indigo),
        const SizedBox(height: 8),
        ...upcoming.map((t) => _SharedScheduleCard(task: t)),
        if (completed.isNotEmpty) ...[
          const SizedBox(height: 20),
          _SectionLabel(label: 'Completed', icon: Icons.check_circle_rounded, color: _C.emerald),
          const SizedBox(height: 8),
          ...completed.map((t) => _SharedScheduleCard(task: t)),
        ],
      ]),
    );
  }
}

class _WebHistoryTab extends StatelessWidget {
  final List<MaintenanceLog> logs;
  const _WebHistoryTab({required this.logs});
  @override
  Widget build(BuildContext context) {
    final sorted = [...logs]..sort((a, b) => b.date.compareTo(a.date));
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 40),
      child: Column(children: sorted.map((l) => _SharedLogCard(log: l)).toList()),
    );
  }
}

class _WebIssuesTab extends StatelessWidget {
  final List<ReportedIssue> issues;
  const _WebIssuesTab({required this.issues});
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
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 40),
      child: Column(children: sorted.map((i) => _SharedIssueCard(issue: i)).toList()),
    );
  }
}

// ─────────────────────────────────────────────
//  WEB-ONLY SMALL WIDGETS
// ─────────────────────────────────────────────
class _WebTableBox extends StatelessWidget {
  final Widget child;
  const _WebTableBox({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _C.border),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 14, offset: const Offset(0, 4))]),
    child: child,
  );
}

class _WebTH extends StatelessWidget {
  final String label;
  const _WebTH(this.label);
  @override
  Widget build(BuildContext context) => Text(label,
    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _C.textMuted, letterSpacing: 0.4));
}
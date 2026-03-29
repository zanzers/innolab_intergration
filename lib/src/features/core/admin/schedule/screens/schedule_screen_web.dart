part of 'schedule_screen.dart';

// ─────────────────────────────────────────────
//  WEB LAYOUT ROOT
// ─────────────────────────────────────────────
class _WebScheduleView extends StatefulWidget {
  const _WebScheduleView();
  @override
  State<_WebScheduleView> createState() => _WebScheduleViewState();
}

class _WebScheduleViewState extends State<_WebScheduleView>
    with SingleTickerProviderStateMixin, _ScheduleStateMixin {
  late TabController _viewTab;
  ScheduleEvent? _selectedEvent;

  @override
  void initState() {
    super.initState();
    _viewTab = TabController(length: 3, vsync: this);
    _viewTab.addListener(() {
      if (!mounted) return;
      if (_viewTab.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _viewTab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
      backgroundColor: _C.bg,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                // ── Top bar ──
                Container(
                  color: _C.surface,
                  padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 16),
                      _buildTopStats(),
                      const SizedBox(height: 16),
                      _buildFilters(),
                      const SizedBox(height: 16),
                      _buildViewBar(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _viewTab,
                    children: [
                      _WebDailyView(
                        selectedDay: selectedDay,
                        events: eventsForDay(selectedDay),
                        onEventTap: (e) => setState(() =>
                            _selectedEvent =
                                _selectedEvent?.id == e.id ? null : e),
                        selectedEvent: _selectedEvent,
                        onQuickAction: handleQuickAction,
                      ),
                      _WebWeeklyView(
                        focusedDay: focusedDay,
                        events: filteredEvents,
                        selectedDay: selectedDay,
                        onDayTap: (d) => setState(() {
                          selectedDay = d;
                          focusedDay = d;
                        }),
                        onEventTap: (e) => setState(() =>
                            _selectedEvent =
                                _selectedEvent?.id == e.id ? null : e),
                        selectedEvent: _selectedEvent,
                      ),
                      _WebMonthlyView(
                        focusedDay: focusedDay,
                        events: filteredEvents,
                        selectedDay: selectedDay,
                        onDayTap: (d) => setState(() {
                          selectedDay = d;
                          focusedDay = d;
                        }),
                        onMonthChanged: (d) =>
                            setState(() => focusedDay = d),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ── Side panel ──
          if (_selectedEvent != null)
            _WebEventDetailPanel(
              event: _selectedEvent!,
              onClose: () => setState(() => _selectedEvent = null),
              onEdit: () => _openFormDialog(event: _selectedEvent),
              onStatusChange: (status) async {
                await handleStatusChange(_selectedEvent!, status);
                if (!mounted) return;
                setState(() {
                  final id = _selectedEvent!.id;
                  final idx = events.indexWhere((e) => e.id == id);
                  if (idx != -1) _selectedEvent = events[idx];
                });
              },
              onDelete: () async {
                await handleDelete(_selectedEvent!);
                if (!mounted) return;
                setState(() => _selectedEvent = null);
              },
            ),
        ],
      ),
    ),
    );
  }

  // ── Header ──────────────────────────────────
  Widget _buildHeader() {
    return Row(children: [
      Expanded(
        child: Row(children: [
          Container(
            width: 6, height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_C.indigo, _C.violet],
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Schedule',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                      color: _C.textPrimary)),
              Text(
                  'Manage events, approvals and machine reservations',
                  style: TextStyle(fontSize: 13, color: _C.textSecondary)),
            ],
          ),
        ]),
      ),
      if (pendingApprovals > 0)
        _WebPillBadge(
          label: '$pendingApprovals Pending Approvals',
          color: _C.rose,
          light: _C.roseLight,
          icon: Icons.pending_actions_rounded,
        ),
    ]);
  }

  // ── Stats row ────────────────────────────────
  Widget _buildTopStats() {
    return Row(children: [
      _WebStatChip(
          label: "Today's Events",
          value: todayEventCount.toString(),
          color: _C.indigo,
          icon: Icons.today_rounded),
      const SizedBox(width: 10),
      _WebStatChip(
          label: 'Admin Tasks',
          value: pendingAdminTasks.toString(),
          color: _C.amber,
          icon: Icons.assignment_rounded),
      const SizedBox(width: 10),
      _WebStatChip(
          label: 'Approvals Due',
          value: pendingApprovals.toString(),
          color: _C.rose,
          icon: Icons.pending_actions_rounded),
      const SizedBox(width: 10),
      _WebStatChip(
          label: 'In Progress',
          value: inProgressCount.toString(),
          color: _C.emerald,
          icon: Icons.timelapse_rounded),
    ]);
  }

  // ── Filters ──────────────────────────────────
  Widget _buildFilters() {
    return Row(children: [
      Expanded(
        child: Container(
          height: 40,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: _C.border)),
          child: TextField(
            onChanged: (v) => setState(() => searchQuery = v),
            style: const TextStyle(fontSize: 13, color: _C.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Search events, machines, staff, IDs…',
              hintStyle:
                  TextStyle(fontSize: 12, color: _C.textMuted),
              prefixIcon:
                  Icon(Icons.search_rounded, size: 16, color: _C.textMuted),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      _WebFilterDropdown(
        label: typeFilter == null
            ? 'All Types'
            : _typeMeta(typeFilter!).label,
        color: typeFilter == null
            ? _C.textSecondary
            : _typeMeta(typeFilter!).color,
        onTap: _showTypePicker,
      ),
      const SizedBox(width: 6),
      _WebFilterDropdown(
        label: statusFilter == null
            ? 'All Status'
            : _statusLabel(statusFilter!),
        color: statusFilter == null
            ? _C.textSecondary
            : _statusColor(statusFilter!),
        onTap: _showStatusPicker,
      ),
      const SizedBox(width: 6),
      _WebFilterDropdown(
        label: staffFilter ?? 'All Staff',
        color: staffFilter == null ? _C.textSecondary : _C.indigo,
        onTap: _showStaffPicker,
      ),
      if (typeFilter != null || statusFilter != null || staffFilter != null)
        Padding(
          padding: const EdgeInsets.only(left: 6),
          child: GestureDetector(
            onTap: clearFilters,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _C.border)),
              child: const Icon(Icons.close_rounded,
                  size: 15, color: _C.textMuted),
            ),
          ),
        ),
    ]);
  }

  // ── View tab bar + day nav ───────────────────
  Widget _buildViewBar() {
    return Row(children: [
      SizedBox(
        width: 248,
        child: Container(
          decoration: BoxDecoration(
              color: _C.bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _C.border)),
          child: TabBar(
            controller: _viewTab,
            isScrollable: false,
            labelColor: Colors.white,
            unselectedLabelColor: _C.textSecondary,
            labelStyle: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 13),
            unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500, fontSize: 13),
            indicator: BoxDecoration(
                color: _C.indigo,
                borderRadius: BorderRadius.circular(8)),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            padding: const EdgeInsets.all(4),
            tabs: const [
              Tab(text: 'Daily'),
              Tab(text: 'Weekly'),
              Tab(text: 'Monthly'),
            ],
          ),
        ),
      ),
      const SizedBox(width: 12),
      _WebDayNav(
        selectedDay: selectedDay,
        onPrev: () => setState(() {
          selectedDay = selectedDay.subtract(const Duration(days: 1));
          focusedDay = selectedDay;
        }),
        onToday: () => setState(() {
          selectedDay = DateTime.now();
          focusedDay = DateTime.now();
        }),
        onNext: () => setState(() {
          selectedDay = selectedDay.add(const Duration(days: 1));
          focusedDay = selectedDay;
        }),
      ),
      const Spacer(),
      ElevatedButton.icon(
        onPressed: () => _openFormDialog(),
        icon: const Icon(Icons.add_rounded, size: 16),
        label: const Text('New Event'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _C.indigo,
          foregroundColor: Colors.white,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
      ),
    ]);
  }

  // ── Pickers ──────────────────────────────────
  void _showTypePicker() => showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) => _PickerSheet(title: 'Filter by Type', options: [
      _PickerOption(
          label: 'All Types',
          onTap: () {
            setState(() => typeFilter = null);
            Navigator.pop(context);
          }),
      ...EventType.values.map((t) => _PickerOption(
          label: _typeMeta(t).label,
          onTap: () {
            setState(() => typeFilter = t);
            Navigator.pop(context);
          })),
    ]),
  );

  void _showStatusPicker() => showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) => _PickerSheet(title: 'Filter by Status', options: [
      _PickerOption(
          label: 'All Status',
          onTap: () {
            setState(() => statusFilter = null);
            Navigator.pop(context);
          }),
      ...EventStatus.values.map((s) => _PickerOption(
          label: _statusLabel(s),
          onTap: () {
            setState(() => statusFilter = s);
            Navigator.pop(context);
          })),
    ]),
  );

  void _showStaffPicker() => showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) => _PickerSheet(title: 'Filter by Staff', options: [
      _PickerOption(
          label: 'All Staff',
          onTap: () {
            setState(() => staffFilter = null);
            Navigator.pop(context);
          }),
      ..._staffList.map((s) => _PickerOption(
          label: s,
          onTap: () {
            setState(() => staffFilter = s);
            Navigator.pop(context);
          })),
    ]),
  );

  void _openFormDialog({ScheduleEvent? event}) {
    showDialog(
      context: context,
      builder: (_) => _EventFormDialog(
        existing: event,
        onSave: (newEvent) async {
          final savedId = await handleSave(newEvent, event);
          if (!mounted) return;
          if (_selectedEvent != null && savedId != null) {
            setState(() {
              final idx = events.indexWhere((e) => e.id == savedId);
              _selectedEvent = idx != -1
                  ? events[idx]
                  : newEvent.copyWith(id: savedId);
            });
          }
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  WEB DAILY VIEW
// ─────────────────────────────────────────────
class _WebDailyView extends StatelessWidget {
  final DateTime selectedDay;
  final List<ScheduleEvent> events;
  final ValueChanged<ScheduleEvent> onEventTap;
  final ScheduleEvent? selectedEvent;
  final Function(ScheduleEvent, String) onQuickAction;

  const _WebDailyView({
    required this.selectedDay,
    required this.events,
    required this.onEventTap,
    required this.selectedEvent,
    required this.onQuickAction,
  });

  @override
  Widget build(BuildContext context) {
    final hours = List.generate(13, (i) => i + 7);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(
              _isSameDay(selectedDay, DateTime.now())
                  ? 'Today — ${_fmtDateLong(selectedDay)}'
                  : _fmtDateLong(selectedDay),
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _C.textPrimary),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: events.isEmpty ? _C.slateLight : _C.indigoLight,
                  borderRadius: BorderRadius.circular(6)),
              child: Text(
                events.isEmpty
                    ? 'No events'
                    : '${events.length} events',
                style: TextStyle(
                    fontSize: 11,
                    color:
                        events.isEmpty ? _C.textMuted : _C.indigo,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          ...hours.map((hour) {
            final hourEvents =
                events.where((e) => e.startTime.hour == hour).toList();
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 52,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '${hour.toString().padLeft(2, '0')}:00',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: hour == DateTime.now().hour &&
                                  _isSameDay(selectedDay, DateTime.now())
                              ? _C.indigo
                              : _C.textMuted,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(children: [
                      Container(
                        height: 1,
                        color: hour == DateTime.now().hour &&
                                _isSameDay(selectedDay, DateTime.now())
                            ? _C.indigo.withOpacity(0.3)
                            : _C.border,
                      ),
                      if (hourEvents.isEmpty)
                        const SizedBox(height: 48)
                      else
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            children: hourEvents
                                .map((e) => _WebEventTile(
                                      event: e,
                                      isSelected:
                                          selectedEvent?.id == e.id,
                                      onTap: () => onEventTap(e),
                                      onQuickAction: (action) =>
                                          onQuickAction(e, action),
                                    ))
                                .toList(),
                          ),
                        ),
                    ]),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  WEB WEEKLY VIEW
// ─────────────────────────────────────────────
class _WebWeeklyView extends StatelessWidget {
  final DateTime focusedDay;
  final List<ScheduleEvent> events;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onDayTap;
  final ValueChanged<ScheduleEvent> onEventTap;
  final ScheduleEvent? selectedEvent;

  const _WebWeeklyView({
    required this.focusedDay,
    required this.events,
    required this.selectedDay,
    required this.onDayTap,
    required this.onEventTap,
    required this.selectedEvent,
  });

  @override
  Widget build(BuildContext context) {
    final weekStart =
        focusedDay.subtract(Duration(days: focusedDay.weekday - 1));
    final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 40),
      child: Column(children: [
        Row(children: [
          const SizedBox(width: 52),
          ...days.map((day) {
            final isToday = _isSameDay(day, DateTime.now());
            final isSelected = _isSameDay(day, selectedDay);
            final dayEvents = events
                .where((e) =>
                    e.startTime.year == day.year &&
                    e.startTime.month == day.month &&
                    e.startTime.day == day.day)
                .toList();

            return Expanded(
              child: GestureDetector(
                onTap: () => onDayTap(day),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _C.indigo
                        : isToday
                            ? _C.indigoLight
                            : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: isSelected
                            ? _C.indigo
                            : isToday
                                ? _C.indigo.withOpacity(0.3)
                                : _C.border),
                  ),
                  child: Column(children: [
                    Text(_weekdayShort(day.weekday),
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.white.withOpacity(0.8)
                                : _C.textMuted)),
                    const SizedBox(height: 2),
                    Text('${day.day}',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? Colors.white
                                : isToday
                                    ? _C.indigo
                                    : _C.textPrimary)),
                    const SizedBox(height: 4),
                    if (dayEvents.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: dayEvents.take(3).map((e) => Container(
                          width: 5, height: 5,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.7)
                                : _typeMeta(e.type).color,
                            shape: BoxShape.circle,
                          ),
                        )).toList(),
                      ),
                  ]),
                ),
              ),
            );
          }),
        ]),
        const SizedBox(height: 16),
        // ── Events for selected day only ──
        Builder(builder: (_) {
          final selectedDayEvents = events
              .where((e) =>
                  e.startTime.year  == selectedDay.year &&
                  e.startTime.month == selectedDay.month &&
                  e.startTime.day   == selectedDay.day)
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date header
              Row(children: [
                Text(
                  _isSameDay(selectedDay, DateTime.now())
                      ? 'Today — ${_fmtDateLong(selectedDay)}'
                      : _fmtDateLong(selectedDay),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrimary),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: selectedDayEvents.isEmpty
                          ? _C.slateLight
                          : _C.indigoLight,
                      borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    selectedDayEvents.isEmpty
                        ? 'No events'
                        : '${selectedDayEvents.length} event${selectedDayEvents.length > 1 ? 's' : ''}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: selectedDayEvents.isEmpty
                            ? _C.textMuted
                            : _C.indigo),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              if (selectedDayEvents.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _C.border)),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                    const Icon(Icons.event_busy_rounded,
                        size: 28, color: _C.textMuted),
                    const SizedBox(height: 8),
                    Text(
                      'Nothing scheduled for ${_fmtDateShort(selectedDay)}',
                      style: const TextStyle(
                          fontSize: 13, color: _C.textMuted),
                    ),
                  ]),
                )
              else
                ...selectedDayEvents.map((e) => _WebEventTile(
                      event: e,
                      isSelected: selectedEvent?.id == e.id,
                      onTap: () => onEventTap(e),
                      onQuickAction: (_) {},
                    )),
            ],
          );
        }),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  WEB MONTHLY VIEW
// ─────────────────────────────────────────────
class _WebMonthlyView extends StatelessWidget {
  final DateTime focusedDay;
  final List<ScheduleEvent> events;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onDayTap;
  final ValueChanged<DateTime> onMonthChanged;

  const _WebMonthlyView({
    required this.focusedDay,
    required this.events,
    required this.selectedDay,
    required this.onDayTap,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay =
        DateTime(focusedDay.year, focusedDay.month, 1);
    final lastDay =
        DateTime(focusedDay.year, focusedDay.month + 1, 0);
    final startOffset = firstDay.weekday - 1;
    final totalCells = startOffset + lastDay.day;
    final rows = (totalCells / 7).ceil();
    const dayHeaders = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 40),
      child: Column(children: [
        Row(children: [
          _WebNavBtn(
              icon: Icons.chevron_left_rounded,
              onTap: () => onMonthChanged(
                  DateTime(focusedDay.year, focusedDay.month - 1))),
          const SizedBox(width: 12),
          Text(
            '${_monthName(focusedDay.month)} ${focusedDay.year}',
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _C.textPrimary,
                letterSpacing: -0.4),
          ),
          const SizedBox(width: 12),
          _WebNavBtn(
              icon: Icons.chevron_right_rounded,
              onTap: () => onMonthChanged(
                  DateTime(focusedDay.year, focusedDay.month + 1))),
        ]),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _C.border)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Column(children: [
              Container(
                width: double.infinity,
                color: const Color(0xFFF3F5F9),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                child: Row(
                  children: dayHeaders
                      .map((h) => Expanded(
                            child: Text(h,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _C.textMuted)),
                          ))
                      .toList(),
                ),
              ),
              const Divider(height: 1, thickness: 1, color: _C.border),
              ...List.generate(rows, (row) {
                const cellH = 88.0;
                return SizedBox(
                  height: cellH,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: List.generate(7, (col) {
                      final cellIndex = row * 7 + col;
                      final dayNum = cellIndex - startOffset + 1;
                      if (dayNum < 1 || dayNum > lastDay.day) {
                        return Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F8FA),
                              border: Border(
                                right: BorderSide(
                                  color: _C.border.withOpacity(0.55),
                                  width: 0.5,
                                ),
                                bottom: BorderSide(
                                  color: _C.border.withOpacity(0.55),
                                  width: 0.5,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      final day = DateTime(
                          focusedDay.year, focusedDay.month, dayNum);
                      final dayEvents = events
                          .where((e) =>
                              e.startTime.year == day.year &&
                              e.startTime.month == day.month &&
                              e.startTime.day == day.day)
                          .toList();
                      final typeIcons =
                          _distinctEventTypesOrdered(dayEvents);
                      final isToday = _isSameDay(day, DateTime.now());
                      final isSelected = _isSameDay(day, selectedDay);

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => onDayTap(day),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(6, 6, 6, 4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _C.indigoLight
                                  : isToday
                                      ? const Color(0xFFFAFBFD)
                                      : Colors.white,
                              border: Border(
                                right: BorderSide(
                                  color: _C.border.withOpacity(0.55),
                                  width: 0.5,
                                ),
                                bottom: BorderSide(
                                  color: _C.border.withOpacity(0.55),
                                  width: 0.5,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 26,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        color: isToday
                                            ? _C.indigo
                                            : Colors.transparent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '$dayNum',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: isToday || isSelected
                                                ? FontWeight.w800
                                                : FontWeight.w600,
                                            color: isToday
                                                ? Colors.white
                                                : isSelected
                                                    ? _C.indigo
                                                    : _C.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    if (dayEvents.isNotEmpty)
                                      Text(
                                        '${dayEvents.length}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: _C.textMuted,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: _calendarDayTypeIcons(
                                      typeIcons,
                                      iconSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ]),
          ),
        ),
        _calendarTypeLegendStrip(),
        const SizedBox(height: 20),
        // ── Selected day event list ──
        Builder(builder: (_) {
          final selectedDayEvents = events
              .where((e) =>
                  e.startTime.year  == selectedDay.year &&
                  e.startTime.month == selectedDay.month &&
                  e.startTime.day   == selectedDay.day)
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(
                  _isSameDay(selectedDay, DateTime.now())
                      ? 'Today — ${_fmtDateLong(selectedDay)}'
                      : _fmtDateLong(selectedDay),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrimary),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: selectedDayEvents.isEmpty
                          ? _C.slateLight
                          : _C.indigoLight,
                      borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    selectedDayEvents.isEmpty
                        ? 'No events'
                        : '${selectedDayEvents.length} event${selectedDayEvents.length > 1 ? 's' : ''}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: selectedDayEvents.isEmpty
                            ? _C.textMuted
                            : _C.indigo),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              if (selectedDayEvents.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _C.border)),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                    const Icon(Icons.event_available_rounded,
                        size: 26, color: _C.textMuted),
                    const SizedBox(height: 8),
                    Text(
                      'No events on ${_fmtDateShort(selectedDay)}. Tap another date.',
                      style: const TextStyle(
                          fontSize: 13, color: _C.textMuted),
                    ),
                  ]),
                )
              else
                ...selectedDayEvents.map((e) => _WebEventTile(
                      event: e,
                      isSelected: false,
                      onTap: () {},
                      onQuickAction: (_) {},
                    )),
            ],
          );
        }),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  WEB EVENT TILE
// ─────────────────────────────────────────────
class _WebEventTile extends StatelessWidget {
  final ScheduleEvent event;
  final bool isSelected;
  final VoidCallback onTap;
  final Function(String) onQuickAction;
  final bool compact;

  const _WebEventTile({
    required this.event,
    required this.isSelected,
    required this.onTap,
    required this.onQuickAction,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final tm = _typeMeta(event.type);
    final sm = _statusMeta(event.status);
    final isPending = event.status == EventStatus.pending;
    final isApprovalTask =
        event.type == EventType.requestApproval && isPending;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(bottom: 6),
        padding: EdgeInsets.all(compact ? 10 : 14),
        decoration: BoxDecoration(
          color: isSelected ? tm.color.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color:
                  isSelected ? tm.color.withOpacity(0.4) : _C.border),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                  width: 3,
                  height: compact ? 28 : 40,
                  decoration: BoxDecoration(
                      color: tm.color,
                      borderRadius: BorderRadius.circular(4))),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: tm.light,
                            borderRadius: BorderRadius.circular(5)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(tm.icon,
                                size: 10, color: tm.color),
                            const SizedBox(width: 3),
                            Text(tm.label,
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: tm.color)),
                          ],
                        ),
                      ),
                      if (event.isAdminTask) ...[
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                              color: _C.amberLight,
                              borderRadius: BorderRadius.circular(5)),
                          child: const Text('Admin',
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: _C.amber)),
                        ),
                      ],
                      const Spacer(),
                      Text(
                          '${_fmtTime(event.startTime)} – ${_fmtTime(event.endTime)}',
                          style: const TextStyle(
                              fontSize: 11,
                              color: _C.textMuted)),
                    ]),
                    const SizedBox(height: 3),
                    Text(event.title,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _C.textPrimary),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                    color: sm.light,
                    borderRadius: BorderRadius.circular(7)),
                child: Text(sm.label,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: sm.color)),
              ),
            ]),
            if (!compact) ...[
              const SizedBox(height: 8),
              Row(children: [
                if (event.machine != null) ...[
                  const Icon(Icons.precision_manufacturing_rounded,
                      size: 11, color: _C.textMuted),
                  const SizedBox(width: 4),
                  Text(event.machine!,
                      style: const TextStyle(
                          fontSize: 11,
                          color: _C.textSecondary)),
                  const SizedBox(width: 10),
                ],
                if (event.assignedStaff != null) ...[
                  const Icon(Icons.person_rounded,
                      size: 11, color: _C.textMuted),
                  const SizedBox(width: 4),
                  Text(event.assignedStaff!,
                      style: const TextStyle(
                          fontSize: 11,
                          color: _C.textSecondary)),
                  const SizedBox(width: 10),
                ],
                if (event.location != null) ...[
                  const Icon(Icons.place_rounded,
                      size: 11, color: _C.textMuted),
                  const SizedBox(width: 4),
                  Text(event.location!,
                      style: const TextStyle(
                          fontSize: 11,
                          color: _C.textSecondary)),
                ],
                if (event.linkedId != null) ...[
                  const Spacer(),
                  Text(event.linkedId!,
                      style: const TextStyle(
                          fontSize: 10,
                          color: _C.textMuted,
                          fontFamily: 'monospace')),
                ],
              ]),
              if (isApprovalTask) ...[
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onQuickAction('approve'),
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                            color: _C.emeraldLight,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_rounded,
                                size: 13, color: _C.emerald),
                            SizedBox(width: 4),
                            Text('Approve',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _C.emerald)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onQuickAction('reject'),
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                            color: _C.roseLight,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.close_rounded,
                                size: 13, color: _C.rose),
                            SizedBox(width: 4),
                            Text('Reject',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _C.rose)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ]),
              ],
              if (isPending &&
                  event.type != EventType.requestApproval &&
                  event.isAdminTask) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => onQuickAction('complete'),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                        color: _C.indigoLight,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.task_alt_rounded,
                            size: 13, color: _C.indigo),
                        SizedBox(width: 4),
                        Text('Mark Complete',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _C.indigo)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  WEB EVENT DETAIL PANEL
// ─────────────────────────────────────────────
class _WebEventDetailPanel extends StatelessWidget {
  final ScheduleEvent event;
  final VoidCallback onClose;
  final VoidCallback onEdit;
  final ValueChanged<EventStatus> onStatusChange;
  final VoidCallback onDelete;

  const _WebEventDetailPanel({
    required this.event,
    required this.onClose,
    required this.onEdit,
    required this.onStatusChange,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final tm = _typeMeta(event.type);
    final sm = _statusMeta(event.status);

    return Container(
      width: 320,
      constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
      decoration: const BoxDecoration(
          color: _C.surface,
          border: Border(left: BorderSide(color: _C.border))),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Text('Event Detail',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrimary)),
              const Spacer(),
              if (event.isEditable) ...[
                _WebIconBtn(
                    icon: Icons.edit_rounded,
                    color: _C.indigo,
                    light: _C.indigoLight,
                    onTap: onEdit),
                const SizedBox(width: 6),
                _WebIconBtn(
                    icon: Icons.delete_rounded,
                    color: _C.rose,
                    light: _C.roseLight,
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Delete Event'),
                        content: const Text(
                            'Are you sure you want to delete this event? This cannot be undone.'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                onDelete();
                              },
                              child: const Text('Delete',
                                  style: TextStyle(color: _C.rose))),
                        ],
                      ),
                    )),
                const SizedBox(width: 6),
              ],
              _WebIconBtn(
                  icon: Icons.close_rounded,
                  color: _C.textSecondary,
                  light: _C.bg,
                  onTap: onClose),
            ]),

            const SizedBox(height: 20),

            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                    color: tm.light,
                    borderRadius: BorderRadius.circular(8)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(tm.icon, size: 12, color: tm.color),
                  const SizedBox(width: 5),
                  Text(tm.label,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: tm.color)),
                ]),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                    color: sm.light,
                    borderRadius: BorderRadius.circular(8)),
                child: Text(sm.label,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: sm.color)),
              ),
              if (event.isAdminTask) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                      color: _C.amberLight,
                      borderRadius: BorderRadius.circular(8)),
                  child: const Text('Admin Task',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _C.amber)),
                ),
              ],
            ]),

            const SizedBox(height: 14),
            Text(event.title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _C.textPrimary,
                    letterSpacing: -0.3)),
            if (event.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(event.description,
                  style: const TextStyle(
                      fontSize: 13,
                      color: _C.textSecondary,
                      height: 1.5)),
            ],

            const SizedBox(height: 16),
            const Divider(height: 1, color: _C.border),
            const SizedBox(height: 14),

            _WebDetailRow(
                icon: Icons.calendar_today_rounded,
                label: 'Date',
                value: _fmtDateLong(event.startTime)),
            _WebDetailRow(
                icon: Icons.access_time_rounded,
                label: 'Time',
                value:
                    '${_fmtTime(event.startTime)} – ${_fmtTime(event.endTime)}'),
            _WebDetailRow(
                icon: Icons.timelapse_rounded,
                label: 'Duration',
                value: _fmtDuration(
                    event.endTime.difference(event.startTime))),
            if (event.location != null)
              _WebDetailRow(
                  icon: Icons.place_rounded,
                  label: 'Location',
                  value: event.location!),
            if (event.machine != null)
              _WebDetailRow(
                  icon: Icons.precision_manufacturing_rounded,
                  label: 'Machine',
                  value: event.machine!),
            if (event.assignedStaff != null)
              _WebDetailRow(
                  icon: Icons.engineering_rounded,
                  label: 'Assigned To',
                  value: event.assignedStaff!),
            if (event.relatedUser != null)
              _WebDetailRow(
                  icon: Icons.person_rounded,
                  label: 'User',
                  value: event.relatedUser!),
            if (event.linkedId != null)
              _WebDetailRow(
                  icon: Icons.link_rounded,
                  label: 'Linked ID',
                  value: event.linkedId!,
                  mono: true,
                  valueColor: _C.indigo),

            const SizedBox(height: 16),
            const Divider(height: 1, color: _C.border),
            const SizedBox(height: 14),

            const Text('Update Status',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _C.textPrimary)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: EventStatus.values.map((s) {
                final meta = _statusMeta(s);
                final isActive = event.status == s;
                return GestureDetector(
                  onTap: () => onStatusChange(s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive ? meta.color : meta.light,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: isActive
                              ? meta.color
                              : meta.color.withOpacity(0.2)),
                    ),
                    child: Text(meta.label,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isActive
                                ? Colors.white
                                : meta.color)),
                  ),
                );
              }).toList(),
            ),

            if (event.type == EventType.requestApproval &&
                event.status == EventStatus.pending) ...[
              const SizedBox(height: 16),
              const Divider(height: 1, color: _C.border),
              const SizedBox(height: 14),
              const Text('Quick Action',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrimary)),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => onStatusChange(EventStatus.approved),
                    icon: const Icon(Icons.check_rounded, size: 15),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _C.emerald,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9))),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => onStatusChange(EventStatus.rejected),
                    icon: const Icon(Icons.close_rounded, size: 15),
                    label: const Text('Reject'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _C.rose,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9))),
                  ),
                ),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  WEB-ONLY SMALL WIDGETS
// ─────────────────────────────────────────────
class _WebPillBadge extends StatelessWidget {
  final String label;
  final Color color, light;
  final IconData icon;
  const _WebPillBadge(
      {required this.label,
      required this.color,
      required this.light,
      required this.icon});
  @override
  Widget build(BuildContext context) => Container(
    padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
        color: light,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25))),
    child: Row(children: [
      Icon(icon, size: 13, color: color),
      const SizedBox(width: 6),
      Text(label,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color)),
    ]),
  );
}

class _WebStatChip extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _WebStatChip(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});
  @override
  Widget build(BuildContext context) => Container(
    padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.15))),
    child: Row(children: [
      Icon(icon, size: 13, color: color),
      const SizedBox(width: 6),
      Text(value,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color)),
      const SizedBox(width: 5),
      Text(label,
          style: TextStyle(
              fontSize: 11, color: color.withOpacity(0.8))),
    ]),
  );
}

class _WebFilterDropdown extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _WebFilterDropdown(
      {required this.label,
      required this.color,
      required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _C.border)),
      child: Row(children: [
        Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color)),
        const SizedBox(width: 4),
        const Icon(Icons.keyboard_arrow_down_rounded,
            size: 14, color: _C.textMuted),
      ]),
    ),
  );
}

class _WebDayNav extends StatelessWidget {
  final DateTime selectedDay;
  final VoidCallback onPrev, onToday, onNext;
  const _WebDayNav(
      {required this.selectedDay,
      required this.onPrev,
      required this.onToday,
      required this.onNext});
  @override
  Widget build(BuildContext context) => Row(children: [
    _WebNavBtn(icon: Icons.chevron_left_rounded, onTap: onPrev),
    const SizedBox(width: 6),
    GestureDetector(
      onTap: onToday,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _isSameDay(selectedDay, DateTime.now())
              ? _C.indigoLight
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: _isSameDay(selectedDay, DateTime.now())
                  ? _C.indigo.withOpacity(0.3)
                  : _C.border),
        ),
        child: Text(
          _isSameDay(selectedDay, DateTime.now())
              ? 'Today'
              : _fmtDateShort(selectedDay),
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _isSameDay(selectedDay, DateTime.now())
                  ? _C.indigo
                  : _C.textPrimary),
        ),
      ),
    ),
    const SizedBox(width: 6),
    _WebNavBtn(icon: Icons.chevron_right_rounded, onTap: onNext),
  ]);
}

class _WebNavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _WebNavBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _C.border)),
      child: Icon(icon, size: 16, color: _C.textSecondary),
    ),
  );
}

class _WebIconBtn extends StatelessWidget {
  final IconData icon;
  final Color color, light;
  final VoidCallback onTap;
  const _WebIconBtn(
      {required this.icon,
      required this.color,
      required this.light,
      required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
          color: light,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2))),
      child: Icon(icon, size: 15, color: color),
    ),
  );
}

class _WebDetailRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final bool mono;
  final Color? valueColor;
  const _WebDetailRow(
      {required this.icon,
      required this.label,
      required this.value,
      this.mono = false,
      this.valueColor});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Row(children: [
      Icon(icon, size: 13, color: _C.textMuted),
      const SizedBox(width: 8),
      Text(label,
          style: const TextStyle(
              fontSize: 12, color: _C.textSecondary)),
      const Spacer(),
      Text(value,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: valueColor ?? _C.textPrimary,
              fontFamily: mono ? 'monospace' : null)),
    ]),
  );
}
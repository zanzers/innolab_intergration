part of 'schedule_screen.dart';

// ─────────────────────────────────────────────
//  MOBILE LAYOUT ROOT
// ─────────────────────────────────────────────
class _MobileScheduleView extends StatefulWidget {
  const _MobileScheduleView();
  @override
  State<_MobileScheduleView> createState() => _MobileScheduleViewState();
}

class _MobileScheduleViewState extends State<_MobileScheduleView>
    with SingleTickerProviderStateMixin, _ScheduleStateMixin {
  late TabController _viewTab;

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
      // ── AppBar ──
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Stats strip
          _MobileStatsStrip(
            todayCount: todayEventCount,
            adminTaskCount: pendingAdminTasks,
            approvalsCount: pendingApprovals,
            inProgressCount: inProgressCount,
          ),
          // View selector + day nav
          Container(
            color: _C.surface,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Column(children: [
              // Tab bar
              Container(
                height: 36,
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
                  padding: const EdgeInsets.all(3),
                  tabs: const [
                    Tab(text: 'Daily'),
                    Tab(text: 'Weekly'),
                    Tab(text: 'Monthly'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Day navigator (shown for Daily + Weekly tabs)
              if (_viewTab.index < 2)
                _MobileDayNav(
                  selectedDay: selectedDay,
                  onPrev: () => setState(() {
                    selectedDay =
                        selectedDay.subtract(const Duration(days: 1));
                    focusedDay = selectedDay;
                  }),
                  onToday: () => setState(() {
                    selectedDay = DateTime.now();
                    focusedDay = DateTime.now();
                  }),
                  onNext: () => setState(() {
                    selectedDay =
                        selectedDay.add(const Duration(days: 1));
                    focusedDay = selectedDay;
                  }),
                ),
            ]),
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _viewTab,
              children: [
                _MobileDailyView(
                  selectedDay: selectedDay,
                  events: eventsForDay(selectedDay),
                  onEventTap: _showEventDetail,
                  onQuickAction: handleQuickAction,
                ),
                _MobileWeeklyView(
                  focusedDay: focusedDay,
                  events: filteredEvents,
                  selectedDay: selectedDay,
                  onDayTap: (d) => setState(() {
                    selectedDay = d;
                    focusedDay = d;
                  }),
                  onEventTap: _showEventDetail,
                ),
                _MobileMonthlyView(
                  focusedDay: focusedDay,
                  events: filteredEvents,
                  selectedDay: selectedDay,
                  onDayTap: (d) => setState(() {
                    selectedDay = d;
                    focusedDay = d;
                  }),
                  onMonthChanged: (d) => setState(() => focusedDay = d),
                ),
              ],
            ),
          ),
        ],
      ),
      // FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openFormDialog(),
        backgroundColor: _C.indigo,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Event',
            style: TextStyle(fontWeight: FontWeight.w700)),
        elevation: 3,
      ),
    ),
    );
  }

  // ── AppBar ───────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _C.surface,
      elevation: 0,
      titleSpacing: 16,
      title: Row(children: [
        Container(
          width: 4, height: 22,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_C.indigo, _C.violet],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Schedule',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: _C.textPrimary)),
            Text('Events & Approvals',
                style: TextStyle(fontSize: 11, color: _C.textSecondary)),
          ],
        ),
      ]),
      actions: [
        // Search icon
        IconButton(
          icon: const Icon(Icons.search_rounded,
              color: _C.textSecondary, size: 22),
          onPressed: _showSearchSheet,
        ),
        // Filter icon with badge
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.tune_rounded,
                  color: _C.textSecondary, size: 22),
              onPressed: _showFilterSheet,
            ),
            if (typeFilter != null ||
                statusFilter != null ||
                staffFilter != null)
              Positioned(
                top: 8, right: 8,
                child: Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                      color: _C.indigo, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _C.border),
      ),
    );
  }

  // ── Search sheet ─────────────────────────────
  void _showSearchSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) {
        String localQuery = searchQuery;
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Search Events',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrimary)),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                    color: _C.bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _C.border)),
                child: TextField(
                  autofocus: true,
                  controller: TextEditingController(text: searchQuery),
                  style: const TextStyle(
                      fontSize: 14, color: _C.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Events, machines, staff, IDs…',
                    hintStyle:
                        TextStyle(fontSize: 14, color: _C.textMuted),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: _C.textMuted, size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 14, horizontal: 4),
                  ),
                  onChanged: (v) => localQuery = v,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => searchQuery = localQuery);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.indigo,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Search',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
              if (searchQuery.isNotEmpty) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    setState(() => searchQuery = '');
                    Navigator.pop(context);
                  },
                  child: const Text('Clear Search',
                      style: TextStyle(color: _C.textSecondary)),
                ),
              ],
            ]),
          ),
        );
      },
    );
  }

  // ── Filter sheet ─────────────────────────────
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        // Declared outside StatefulBuilder so setSheetState rebuilds
        // don't reset them back to the current mixin values.
        EventType? localType = typeFilter;
        EventStatus? localStatus = statusFilter;
        String? localStaff = staffFilter;

        return StatefulBuilder(
          builder: (ctx, setSheetState) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.75,
            maxChildSize: 0.9,
            builder: (_, sc) => ListView(
              controller: sc,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              children: [
                Row(children: [
                  const Text('Filter Events',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _C.textPrimary)),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() => clearFilters());
                      Navigator.pop(ctx);
                    },
                    child: const Text('Clear All',
                        style: TextStyle(color: _C.rose)),
                  ),
                ]),
                const SizedBox(height: 16),

                // Type
                const Text('Event Type',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _C.textSecondary)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  _MobileFilterChip(
                    label: 'All',
                    isActive: localType == null,
                    activeColor: _C.indigo,
                    onTap: () => setSheetState(() => localType = null),
                  ),
                  ...EventType.values.map((t) {
                    final tm = _typeMeta(t);
                    return _MobileFilterChip(
                      label: tm.label,
                      isActive: localType == t,
                      activeColor: tm.color,
                      onTap: () => setSheetState(() => localType = t),
                    );
                  }),
                ]),
                const SizedBox(height: 16),

                // Status
                const Text('Status',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _C.textSecondary)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  _MobileFilterChip(
                    label: 'All',
                    isActive: localStatus == null,
                    activeColor: _C.indigo,
                    onTap: () => setSheetState(() => localStatus = null),
                  ),
                  ...EventStatus.values.map((s) {
                    final sm = _statusMeta(s);
                    return _MobileFilterChip(
                      label: sm.label,
                      isActive: localStatus == s,
                      activeColor: sm.color,
                      onTap: () => setSheetState(() => localStatus = s),
                    );
                  }),
                ]),
                const SizedBox(height: 16),

                // Staff
                const Text('Staff / Person',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _C.textSecondary)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  _MobileFilterChip(
                    label: 'All Staff',
                    isActive: localStaff == null,
                    activeColor: _C.indigo,
                    onTap: () => setSheetState(() => localStaff = null),
                  ),
                  ..._staffList.map((s) => _MobileFilterChip(
                        label: s,
                        isActive: localStaff == s,
                        activeColor: _C.indigo,
                        onTap: () => setSheetState(() => localStaff = s),
                      )),
                ]),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        typeFilter   = localType;
                        statusFilter = localStatus;
                        staffFilter  = localStaff;
                      });
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _C.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Apply Filters',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Event detail sheet ───────────────────────
  void _showEventDetail(ScheduleEvent event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MobileEventDetailSheet(
        event: event,
        onStatusChange: (status) async {
          await handleStatusChange(event, status);
          if (context.mounted) Navigator.pop(context);
        },
        onEdit: () {
          Navigator.pop(context);
          _openFormDialog(event: event);
        },
        onDelete: () async {
          await handleDelete(event);
          if (context.mounted) Navigator.pop(context);
        },
        onQuickAction: (action) async {
          await handleQuickAction(event, action);
          if (context.mounted) Navigator.pop(context);
        },
      ),
    );
  }

  // ── Form dialog ──────────────────────────────
  void _openFormDialog({ScheduleEvent? event}) {
    showDialog(
      context: context,
      useSafeArea: true,
      barrierColor: Colors.black54,
      builder: (_) => _EventFormDialog(
        existing: event,
        onSave: (newEvent) async {
          await handleSave(newEvent, event);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  MOBILE STATS STRIP
// ─────────────────────────────────────────────
class _MobileStatsStrip extends StatelessWidget {
  final int todayCount, adminTaskCount, approvalsCount, inProgressCount;
  const _MobileStatsStrip({
    required this.todayCount,
    required this.adminTaskCount,
    required this.approvalsCount,
    required this.inProgressCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _C.surface,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          _MobileStatCard(
              label: "Today",
              value: todayCount.toString(),
              color: _C.indigo,
              icon: Icons.today_rounded),
          const SizedBox(width: 8),
          _MobileStatCard(
              label: "Admin",
              value: adminTaskCount.toString(),
              color: _C.amber,
              icon: Icons.assignment_rounded),
          const SizedBox(width: 8),
          _MobileStatCard(
              label: "Approvals",
              value: approvalsCount.toString(),
              color: _C.rose,
              icon: Icons.pending_actions_rounded),
          const SizedBox(width: 8),
          _MobileStatCard(
              label: "Active",
              value: inProgressCount.toString(),
              color: _C.emerald,
              icon: Icons.timelapse_rounded),
        ]),
      ),
    );
  }
}

class _MobileStatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _MobileStatCard(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.15))),
    child: Row(children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 6),
      Text(value,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color)),
      const SizedBox(width: 5),
      Text(label,
          style: TextStyle(
              fontSize: 11, color: color.withOpacity(0.8))),
    ]),
  );
}

// ─────────────────────────────────────────────
//  MOBILE DAY NAV
// ─────────────────────────────────────────────
class _MobileDayNav extends StatelessWidget {
  final DateTime selectedDay;
  final VoidCallback onPrev, onToday, onNext;
  const _MobileDayNav(
      {required this.selectedDay,
      required this.onPrev,
      required this.onToday,
      required this.onNext});

  @override
  Widget build(BuildContext context) => Row(children: [
    GestureDetector(
      onTap: onPrev,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _C.border)),
        child: const Icon(Icons.chevron_left_rounded,
            size: 18, color: _C.textSecondary),
      ),
    ),
    const SizedBox(width: 8),
    Expanded(
      child: GestureDetector(
        onTap: onToday,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
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
                ? 'Today — ${_fmtDateShort(selectedDay)}'
                : _fmtDateLong(selectedDay).split(', ').take(2).join(', '),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _isSameDay(selectedDay, DateTime.now())
                    ? _C.indigo
                    : _C.textPrimary),
          ),
        ),
      ),
    ),
    const SizedBox(width: 8),
    GestureDetector(
      onTap: onNext,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _C.border)),
        child: const Icon(Icons.chevron_right_rounded,
            size: 18, color: _C.textSecondary),
      ),
    ),
  ]);
}

// ─────────────────────────────────────────────
//  MOBILE DAILY VIEW
// ─────────────────────────────────────────────
class _MobileDailyView extends StatelessWidget {
  final DateTime selectedDay;
  final List<ScheduleEvent> events;
  final ValueChanged<ScheduleEvent> onEventTap;
  final Function(ScheduleEvent, String) onQuickAction;

  const _MobileDailyView({
    required this.selectedDay,
    required this.events,
    required this.onEventTap,
    required this.onQuickAction,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return _MobileEmptyState(
        icon: Icons.event_busy_rounded,
        title: 'No events',
        subtitle: 'Nothing scheduled for ${_fmtDateShort(selectedDay)}',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
      itemCount: events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _MobileEventCard(
        event: events[i],
        onTap: () => onEventTap(events[i]),
        onQuickAction: (action) => onQuickAction(events[i], action),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  MOBILE WEEKLY VIEW
// ─────────────────────────────────────────────
class _MobileWeeklyView extends StatelessWidget {
  final DateTime focusedDay;
  final List<ScheduleEvent> events;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onDayTap;
  final ValueChanged<ScheduleEvent> onEventTap;

  const _MobileWeeklyView({
    required this.focusedDay,
    required this.events,
    required this.selectedDay,
    required this.onDayTap,
    required this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    final weekStart =
        focusedDay.subtract(Duration(days: focusedDay.weekday - 1));
    final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    // Compute selected-day events at the widget level so any prop change
    // (selectedDay, events) immediately produces the correct list.
    final dayEvents = events
        .where((e) =>
            e.startTime.year  == selectedDay.year &&
            e.startTime.month == selectedDay.month &&
            e.startTime.day   == selectedDay.day)
        .toList();

    return Column(children: [
      // Horizontal day strip
      Container(
        color: _C.surface,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: days.map((day) {
              final isToday = _isSameDay(day, DateTime.now());
              final isSelected = _isSameDay(day, selectedDay);
              final dayEvents = events
                  .where((e) =>
                      e.startTime.year == day.year &&
                      e.startTime.month == day.month &&
                      e.startTime.day == day.day)
                  .toList();

              return GestureDetector(
                onTap: () => onDayTap(day),
                child: Container(
                  width: 52,
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _C.indigo
                        : isToday
                            ? _C.indigoLight
                            : Colors.white,
                    borderRadius: BorderRadius.circular(12),
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
                    const SizedBox(height: 4),
                    Text('${day.day}',
                        style: TextStyle(
                            fontSize: 18,
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
                          margin: const EdgeInsets.symmetric(
                              horizontal: 1),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.7)
                                : _typeMeta(e.type).color,
                            shape: BoxShape.circle,
                          ),
                        )).toList(),
                      )
                    else
                      const SizedBox(height: 5),
                  ]),
                ),
              );
            }).toList(),
          ),
        ),
      ),
      // Events for selected day
      Expanded(
        child: dayEvents.isEmpty
            ? _MobileEmptyState(
                icon: Icons.event_available_rounded,
                title: 'No events',
                subtitle:
                    'Nothing scheduled for ${_fmtDateShort(selectedDay)}',
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
                    child: Row(children: [
                      Text(
                        _isSameDay(selectedDay, DateTime.now())
                            ? 'Today — ${_fmtDateShort(selectedDay)}'
                            : _fmtDateLong(selectedDay)
                                .split(', ')
                                .take(2)
                                .join(', '),
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _C.textSecondary),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                            color: _C.indigoLight,
                            borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          '${dayEvents.length} event${dayEvents.length > 1 ? 's' : ''}',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _C.indigo),
                        ),
                      ),
                    ]),
                  ),
                  Expanded(
                    child: ListView.separated(
                      // Key forces full rebuild when selected day changes
                      key: ValueKey(selectedDay),
                      padding: const EdgeInsets.fromLTRB(14, 4, 14, 100),
                      itemCount: dayEvents.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _MobileEventCard(
                        event: dayEvents[i],
                        onTap: () => onEventTap(dayEvents[i]),
                        onQuickAction: (_) {},
                      ),
                    ),
                  ),
                ],
              ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────
//  MOBILE MONTHLY VIEW
// ─────────────────────────────────────────────
class _MobileMonthlyView extends StatelessWidget {
  final DateTime focusedDay;
  final List<ScheduleEvent> events;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onDayTap;
  final ValueChanged<DateTime> onMonthChanged;

  const _MobileMonthlyView({
    required this.focusedDay,
    required this.events,
    required this.selectedDay,
    required this.onDayTap,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(focusedDay.year, focusedDay.month, 1);
    final lastDay  = DateTime(focusedDay.year, focusedDay.month + 1, 0);
    final startOffset = firstDay.weekday - 1;
    final totalCells  = startOffset + lastDay.day;
    final rows = (totalCells / 7).ceil();

    const dayHeaders = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    // Selected day's events
    final selectedEvents = events
        .where((e) =>
            e.startTime.year  == selectedDay.year &&
            e.startTime.month == selectedDay.month &&
            e.startTime.day   == selectedDay.day)
        .toList();

    return Column(children: [
      // Calendar grid
      Container(
        color: _C.surface,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        child: Column(children: [
          // Month nav
          Row(children: [
            GestureDetector(
              onTap: () => onMonthChanged(
                  DateTime(focusedDay.year, focusedDay.month - 1)),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: _C.bg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _C.border)),
                child: const Icon(Icons.chevron_left_rounded,
                    size: 18, color: _C.textSecondary),
              ),
            ),
            Expanded(
              child: Text(
                '${_monthName(focusedDay.month)} ${focusedDay.year}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _C.textPrimary),
              ),
            ),
            GestureDetector(
              onTap: () => onMonthChanged(
                  DateTime(focusedDay.year, focusedDay.month + 1)),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: _C.bg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _C.border)),
                child: const Icon(Icons.chevron_right_rounded,
                    size: 18, color: _C.textSecondary),
              ),
            ),
          ]),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _C.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Table(
              border: TableBorder.all(
                color: _C.border.withOpacity(0.75),
                width: 0.5,
              ),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xFFF3F5F9)),
                  children: dayHeaders
                      .map((h) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Center(
                              child: Text(
                                h,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _C.textMuted,
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                ...List.generate(rows, (row) {
                  return TableRow(
                    children: List.generate(7, (col) {
                      final cellIndex = row * 7 + col;
                      final dayNum = cellIndex - startOffset + 1;
                      const cellH = 62.0;
                      if (dayNum < 1 || dayNum > lastDay.day) {
                        return TableCell(
                          child: Container(
                            height: cellH,
                            color: const Color(0xFFF7F8FA),
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
                      final types = _distinctEventTypesOrdered(dayEvents);
                      final isToday = _isSameDay(day, DateTime.now());
                      final isSelected = _isSameDay(day, selectedDay);

                      return TableCell(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onDayTap(day),
                          child: Container(
                            height: cellH,
                            color: isSelected
                                ? _C.indigo
                                : isToday
                                    ? _C.indigoLight
                                    : Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 2, vertical: 4),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$dayNum',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isToday || isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : isToday
                                            ? _C.indigo
                                            : _C.textPrimary,
                                  ),
                                ),
                                if (types.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  SizedBox(
                                    height: 22,
                                    width: double.infinity,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: _calendarDayTypeIcons(
                                        types,
                                        iconSize: 12,
                                        iconColor: isSelected
                                            ? Colors.white
                                            : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ],
            ),
          ),
          _calendarTypeLegendStrip(),
        ]),
      ),
      // Events for selected day
      Expanded(
        child: selectedEvents.isEmpty
            ? _MobileEmptyState(
                icon: Icons.event_available_rounded,
                title: 'No events',
                subtitle:
                    'Nothing on ${_fmtDateShort(selectedDay)}. Tap a date.',
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(14, 12, 14, 6),
                    child: Text(
                      _fmtDateLong(selectedDay),
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _C.textSecondary),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      key: ValueKey(selectedDay),
                      padding: const EdgeInsets.fromLTRB(
                          14, 0, 14, 100),
                      itemCount: selectedEvents.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (_, i) => _MobileEventCard(
                        event: selectedEvents[i],
                        onTap: () {},
                        onQuickAction: (_) {},
                      ),
                    ),
                  ),
                ],
              ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────
//  MOBILE EVENT CARD
// ─────────────────────────────────────────────
class _MobileEventCard extends StatelessWidget {
  final ScheduleEvent event;
  final VoidCallback onTap;
  final Function(String) onQuickAction;

  const _MobileEventCard({
    required this.event,
    required this.onTap,
    required this.onQuickAction,
  });

  @override
  Widget build(BuildContext context) {
    final tm = _typeMeta(event.type);
    final sm = _statusMeta(event.status);
    final isPending = event.status == EventStatus.pending;
    final isApproval =
        event.type == EventType.requestApproval && isPending;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _C.border),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2))
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: IntrinsicHeight(
            child: Row(children: [
              // Left color strip
              Container(width: 4, color: tm.color),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type badge + time
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                              color: tm.light,
                              borderRadius: BorderRadius.circular(6)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(tm.icon,
                                  size: 11, color: tm.color),
                              const SizedBox(width: 4),
                              Text(tm.label,
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: tm.color)),
                            ],
                          ),
                        ),
                        if (event.isAdminTask) ...[
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                                color: _C.amberLight,
                                borderRadius: BorderRadius.circular(6)),
                            child: const Text('Admin',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: _C.amber)),
                          ),
                        ],
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                              color: sm.light,
                              borderRadius: BorderRadius.circular(6)),
                          child: Text(sm.label,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: sm.color)),
                        ),
                      ]),
                      const SizedBox(height: 6),
                      // Title
                      Text(event.title,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _C.textPrimary,
                              height: 1.3)),
                      const SizedBox(height: 6),
                      // Time + meta row
                      Wrap(
                        spacing: 10, runSpacing: 4,
                        children: [
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.access_time_rounded,
                                size: 12, color: _C.textMuted),
                            const SizedBox(width: 3),
                            Text(
                              '${_fmtTime(event.startTime)} – ${_fmtTime(event.endTime)}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: _C.textSecondary),
                            ),
                          ]),
                          if (event.location != null)
                            Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                              const Icon(Icons.place_rounded,
                                  size: 12, color: _C.textMuted),
                              const SizedBox(width: 3),
                              Text(event.location!,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: _C.textSecondary)),
                            ]),
                          if (event.machine != null)
                            Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                              const Icon(
                                  Icons.precision_manufacturing_rounded,
                                  size: 12,
                                  color: _C.textMuted),
                              const SizedBox(width: 3),
                              Text(event.machine!,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: _C.textSecondary)),
                            ]),
                          if (event.assignedStaff != null)
                            Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                              const Icon(Icons.person_rounded,
                                  size: 12, color: _C.textMuted),
                              const SizedBox(width: 3),
                              Text(event.assignedStaff!,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: _C.textSecondary)),
                            ]),
                        ],
                      ),
                      // Quick action buttons (Approval tasks)
                      if (isApproval) ...[
                        const SizedBox(height: 10),
                        Row(children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => onQuickAction('approve'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 9),
                                decoration: BoxDecoration(
                                    color: _C.emeraldLight,
                                    borderRadius:
                                        BorderRadius.circular(9)),
                                child: const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_rounded,
                                        size: 14, color: _C.emerald),
                                    SizedBox(width: 5),
                                    Text('Approve',
                                        style: TextStyle(
                                            fontSize: 13,
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
                                padding: const EdgeInsets.symmetric(
                                    vertical: 9),
                                decoration: BoxDecoration(
                                    color: _C.roseLight,
                                    borderRadius:
                                        BorderRadius.circular(9)),
                                child: const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.close_rounded,
                                        size: 14, color: _C.rose),
                                    SizedBox(width: 5),
                                    Text('Reject',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: _C.rose)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ]),
                      ],
                      // Mark complete (non-approval admin tasks)
                      if (isPending &&
                          event.type != EventType.requestApproval &&
                          event.isAdminTask) ...[
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () => onQuickAction('complete'),
                          child: Container(
                            width: double.infinity,
                            padding:
                                const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                                color: _C.indigoLight,
                                borderRadius: BorderRadius.circular(9)),
                            child: const Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(Icons.task_alt_rounded,
                                    size: 14, color: _C.indigo),
                                SizedBox(width: 5),
                                Text('Mark Complete',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: _C.indigo)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // Tap chevron
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(Icons.chevron_right_rounded,
                    size: 20,
                    color: _C.textMuted.withOpacity(0.5)),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  MOBILE EVENT DETAIL BOTTOM SHEET
// ─────────────────────────────────────────────
class _MobileEventDetailSheet extends StatelessWidget {
  final ScheduleEvent event;
  final ValueChanged<EventStatus> onStatusChange;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(String) onQuickAction;

  const _MobileEventDetailSheet({
    required this.event,
    required this.onStatusChange,
    required this.onEdit,
    required this.onDelete,
    required this.onQuickAction,
  });

  @override
  Widget build(BuildContext context) {
    final tm = _typeMeta(event.type);
    final sm = _statusMeta(event.status);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      maxChildSize: 0.95,
      builder: (_, sc) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 36, height: 4,
            decoration: BoxDecoration(
                color: _C.border,
                borderRadius: BorderRadius.circular(4)),
          ),
          // Sheet content
          Expanded(
            child: SingleChildScrollView(
              controller: sc,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(children: [
                    const Text('Event Detail',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _C.textPrimary)),
                    const Spacer(),
                    if (event.isEditable) ...[
                      _MobileIconBtn(
                          icon: Icons.edit_rounded,
                          color: _C.indigo,
                          light: _C.indigoLight,
                          onTap: onEdit),
                      const SizedBox(width: 8),
                      _MobileIconBtn(
                          icon: Icons.delete_outline_rounded,
                          color: _C.rose,
                          light: _C.roseLight,
                          onTap: () => showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(16)),
                              title: const Text('Delete Event'),
                              content: const Text(
                                  'Delete this event? This cannot be undone.'),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context),
                                    child: const Text('Cancel')),
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      onDelete();
                                    },
                                    child: const Text('Delete',
                                        style: TextStyle(
                                            color: _C.rose))),
                              ],
                            ),
                          )),
                    ],
                  ]),
                  const SizedBox(height: 14),

                  // Badges
                  Wrap(spacing: 8, runSpacing: 6, children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                          color: tm.light,
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(tm.icon, size: 13, color: tm.color),
                        const SizedBox(width: 5),
                        Text(tm.label,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: tm.color)),
                      ]),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                          color: sm.light,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(sm.label,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: sm.color)),
                    ),
                    if (event.isAdminTask)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                            color: _C.amberLight,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Text('Admin Task',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _C.amber)),
                      ),
                  ]),
                  const SizedBox(height: 12),

                  Text(event.title,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _C.textPrimary,
                          letterSpacing: -0.4,
                          height: 1.3)),
                  if (event.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(event.description,
                        style: const TextStyle(
                            fontSize: 13,
                            color: _C.textSecondary,
                            height: 1.6)),
                  ],

                  const SizedBox(height: 16),
                  const Divider(height: 1, color: _C.border),
                  const SizedBox(height: 14),

                  // Details grid (2-column)
                  Wrap(spacing: 0, runSpacing: 0, children: [
                    _MobileDetailTile(
                        icon: Icons.calendar_today_rounded,
                        label: 'Date',
                        value: _fmtDateLong(event.startTime)),
                    _MobileDetailTile(
                        icon: Icons.access_time_rounded,
                        label: 'Time',
                        value:
                            '${_fmtTime(event.startTime)} – ${_fmtTime(event.endTime)}'),
                    _MobileDetailTile(
                        icon: Icons.timelapse_rounded,
                        label: 'Duration',
                        value: _fmtDuration(
                            event.endTime.difference(event.startTime))),
                    if (event.location != null)
                      _MobileDetailTile(
                          icon: Icons.place_rounded,
                          label: 'Location',
                          value: event.location!),
                    if (event.machine != null)
                      _MobileDetailTile(
                          icon: Icons.precision_manufacturing_rounded,
                          label: 'Machine',
                          value: event.machine!),
                    if (event.assignedStaff != null)
                      _MobileDetailTile(
                          icon: Icons.engineering_rounded,
                          label: 'Staff',
                          value: event.assignedStaff!),
                    if (event.relatedUser != null)
                      _MobileDetailTile(
                          icon: Icons.person_rounded,
                          label: 'User',
                          value: event.relatedUser!),
                    if (event.linkedId != null)
                      _MobileDetailTile(
                          icon: Icons.link_rounded,
                          label: 'Linked ID',
                          value: event.linkedId!,
                          valueColor: _C.indigo),
                  ]),

                  const SizedBox(height: 16),
                  const Divider(height: 1, color: _C.border),
                  const SizedBox(height: 14),

                  // Status update
                  const Text('Update Status',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _C.textPrimary)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: EventStatus.values.map((s) {
                      final meta = _statusMeta(s);
                      final isActive = event.status == s;
                      return GestureDetector(
                        onTap: () => onStatusChange(s),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color:
                                isActive ? meta.color : meta.light,
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(
                                color: isActive
                                    ? meta.color
                                    : meta.color.withOpacity(0.2)),
                          ),
                          child: Text(meta.label,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isActive
                                      ? Colors.white
                                      : meta.color)),
                        ),
                      );
                    }).toList(),
                  ),

                  // Approve / Reject quick action
                  if (event.type == EventType.requestApproval &&
                      event.status == EventStatus.pending) ...[
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: _C.border),
                    const SizedBox(height: 14),
                    Row(children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              onStatusChange(EventStatus.approved),
                          icon: const Icon(Icons.check_rounded, size: 16),
                          label: const Text('Approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _C.emerald,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              onStatusChange(EventStatus.rejected),
                          icon: const Icon(Icons.close_rounded, size: 16),
                          label: const Text('Reject'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _C.rose,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ]),
                  ],
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  MOBILE DETAIL TILE  (2-column grid item)
// ─────────────────────────────────────────────
class _MobileDetailTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color? valueColor;
  const _MobileDetailTile(
      {required this.icon,
      required this.label,
      required this.value,
      this.valueColor});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _C.border))),
    child: Row(children: [
      Icon(icon, size: 14, color: _C.textMuted),
      const SizedBox(width: 8),
      Text(label,
          style: const TextStyle(
              fontSize: 12, color: _C.textSecondary)),
      const Spacer(),
      Flexible(
        child: Text(value,
            textAlign: TextAlign.right,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: valueColor ?? _C.textPrimary)),
      ),
    ]),
  );
}

// ─────────────────────────────────────────────
//  MOBILE EMPTY STATE
// ─────────────────────────────────────────────
class _MobileEmptyState extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const _MobileEmptyState(
      {required this.icon,
      required this.title,
      required this.subtitle});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: _C.indigoLight,
                shape: BoxShape.circle),
            child: Icon(icon, size: 32, color: _C.indigo),
          ),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _C.textPrimary)),
          const SizedBox(height: 6),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, color: _C.textSecondary)),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────
//  MOBILE FILTER CHIP
// ─────────────────────────────────────────────
class _MobileFilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;
  const _MobileFilterChip(
      {required this.label,
      required this.isActive,
      required this.activeColor,
      required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? activeColor
            : activeColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isActive
                ? activeColor
                : activeColor.withOpacity(0.2)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : activeColor)),
    ),
  );
}

// ─────────────────────────────────────────────
//  MOBILE ICON BUTTON
// ─────────────────────────────────────────────
class _MobileIconBtn extends StatelessWidget {
  final IconData icon;
  final Color color, light;
  final VoidCallback onTap;
  const _MobileIconBtn(
      {required this.icon,
      required this.color,
      required this.light,
      required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
          color: light,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.25))),
      child: Icon(icon, size: 17, color: color),
    ),
  );
}
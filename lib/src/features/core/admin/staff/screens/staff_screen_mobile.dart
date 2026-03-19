part of 'staff_screen.dart';

// ─────────────────────────────────────────────
//  MOBILE STAFF VIEW
// ─────────────────────────────────────────────
class _MobileStaffView extends StatefulWidget {
  const _MobileStaffView();
  @override
  State<_MobileStaffView> createState() => _MobileStaffViewState();
}

class _MobileStaffViewState extends State<_MobileStaffView>
    with SingleTickerProviderStateMixin, _StaffStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _SC.bg,
      appBar: _buildAppBar(),
      body: Column(children: [
        // Stats strip
        Container(
          color: _SC.surface,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
          child: _SharedStatsStrip(
            online: onlineCount, printing: printingCount,
            onBreak: onBreakCount, onTravel: onTravelCount,
            offline: offlineCount, completedToday: completedToday,
            activeJobs: activeJobsCount, pending: pendingCount,
          ),
        ),
        // Tab bar
        Container(
          color: _SC.surface,
          child: TabBar(
            controller: _tab,
            labelColor: _SC.indigo,
            unselectedLabelColor: _SC.textMuted,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            indicatorColor: _SC.indigo, indicatorWeight: 2.5,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: _SC.border,
            tabs: [
              Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Text('Staff'),
                const SizedBox(width: 6),
                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: _SC.indigoLight, borderRadius: BorderRadius.circular(9)),
                    child: Text('${kStaff.length}',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _SC.indigo))),
              ])),
              const Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('Activity'),
                SizedBox(width: 6),
                _LiveDot(),
              ])),
            ],
          ),
        ),
        Expanded(child: TabBarView(
          controller: _tab,
          children: [
            _buildStaffTab(),
            const _SharedActivityFeed(),
          ],
        )),
      ]),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final activeCount = kStaff.where((s) => s.status != StaffStatus.offline).length;
    return AppBar(
      backgroundColor: _SC.surface,
      elevation: 0,
      titleSpacing: 16,
      title: Row(children: [
        Container(width: 4, height: 22,
            decoration: BoxDecoration(
                gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [_SC.indigo, _SC.violet]),
                borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 10),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Staff Monitor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.4, color: _SC.textPrimary)),
          Text('Real-time activity', style: TextStyle(fontSize: 11, color: _SC.textSecondary)),
        ]),
      ]),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
              color: _SC.emerald.withOpacity(0.1), borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _SC.emerald.withOpacity(0.25))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.circle, color: _SC.emerald, size: 8),
            const SizedBox(width: 5),
            Text('$activeCount Active',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _SC.emerald)),
          ]),
        ),
      ],
      bottom: PreferredSize(preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _SC.border)),
    );
  }

  Widget _buildStaffTab() {
    return Column(children: [
      // Search + filter
      Container(
        color: _SC.surface,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        child: Column(children: [
          // Search
          Container(
            height: 40,
            decoration: BoxDecoration(color: _SC.bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: _SC.border)),
            child: TextField(
              onChanged: (v) => setState(() => searchQuery = v),
              style: const TextStyle(fontSize: 13, color: _SC.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Search name or role…',
                hintStyle: TextStyle(fontSize: 13, color: _SC.textMuted),
                prefixIcon: Icon(Icons.search_rounded, size: 17, color: _SC.textMuted),
                border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 10)),
            ),
          ),
          const SizedBox(height: 8),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _StaffStateMixin.filters.map((f) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () => setState(() => statusFilter = f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                    decoration: BoxDecoration(
                        color: statusFilter == f ? _SC.indigo : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusFilter == f ? _SC.indigo : _SC.border)),
                    child: Text(f, style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: statusFilter == f ? Colors.white : _SC.textSecondary)),
                  ),
                ),
              )).toList(),
            ),
          ),
        ]),
      ),
      // Staff list
      Expanded(child: _buildList()),
    ]);
  }

  Widget _buildList() {
    final staff = filteredStaff;
    if (staff.isEmpty) {
      return Center(child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(color: _SC.indigoLight, shape: BoxShape.circle),
              child: const Icon(Icons.people_outline_rounded, size: 28, color: _SC.indigo)),
          const SizedBox(height: 14),
          const Text('No staff found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _SC.textPrimary)),
          const SizedBox(height: 6),
          const Text('Try a different filter or search term',
              style: TextStyle(fontSize: 13, color: _SC.textSecondary)),
        ]),
      ));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 40),
      itemCount: staff.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _SharedStaffCard(
          member: staff[i],
          isSelected: false,
          onTap: () => _showDetailSheet(staff[i]),
        ),
    );
  }

  void _showDetailSheet(StaffMember member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.82,
        maxChildSize: 0.96,
        builder: (_, sc) => Container(
          decoration: const BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          child: Column(children: [
            Container(margin: const EdgeInsets.only(top: 10), width: 36, height: 4,
                decoration: BoxDecoration(color: _SC.border, borderRadius: BorderRadius.circular(4))),
            Expanded(child: SingleChildScrollView(
              controller: sc,
              child: _SharedStaffDetailContent(
                member: member,
                onClose: () => Navigator.pop(context),
                onMarkComplete: () => Navigator.pop(context),
                onReportIssue: () {
                  Navigator.pop(context);
                  _showReportSheet(member);
                },
              ),
            )),
          ]),
        ),
      ),
    );
  }

  void _showReportSheet(StaffMember member) {
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
            Row(children: [
              const Text('Report Issue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _SC.textPrimary)),
              const Spacer(),
              Text('Re: ${member.name}', style: const TextStyle(fontSize: 12, color: _SC.textSecondary)),
            ]),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(color: _SC.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _SC.border)),
              child: TextField(
                controller: ctrl, maxLines: 4, autofocus: true,
                style: const TextStyle(fontSize: 14, color: _SC.textPrimary),
                decoration: const InputDecoration(hintText: 'Describe the issue…',
                    hintStyle: TextStyle(color: _SC.textMuted),
                    border: InputBorder.none, contentPadding: EdgeInsets.all(12)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: _SC.rose, foregroundColor: Colors.white,
                  elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              child: const Text('Submit Report'),
            )),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  MOBILE-ONLY: LIVE DOT WIDGET
// ─────────────────────────────────────────────
class _LiveDot extends StatelessWidget {
  const _LiveDot();
  @override
  Widget build(BuildContext context) => Container(
      width: 7, height: 7,
      decoration: const BoxDecoration(color: _SC.emerald, shape: BoxShape.circle));
}
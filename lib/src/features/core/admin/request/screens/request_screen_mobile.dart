part of 'request_screen.dart';

// ─────────────────────────────────────────────
//  MOBILE REQUEST VIEW
// ─────────────────────────────────────────────
class _MobileRequestView extends StatefulWidget {
  const _MobileRequestView();
  @override
  State<_MobileRequestView> createState() => _MobileRequestViewState();
}

class _MobileRequestViewState extends State<_MobileRequestView>
    with SingleTickerProviderStateMixin, _RequestStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
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
      backgroundColor: _RC.bg,
      appBar: _buildAppBar(),
      body: Column(children: [
        // Analytics strip
        Container(
          color: _RC.surface,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _MobileKpiChip(label: 'Today', value: totalToday.toString(), color: _RC.indigo, icon: Icons.inbox_rounded),
              const SizedBox(width: 8),
              _MobileKpiChip(label: 'Auto', value: autoApprovedCount.toString(), color: _RC.emerald, icon: Icons.auto_awesome_rounded),
              const SizedBox(width: 8),
              _MobileKpiChip(label: 'Rejected', value: (staffRejectedCount + requests.where((r) => r.status == RequestStatus.adminRejected).length).toString(), color: _RC.rose, icon: Icons.cancel_rounded),
              const SizedBox(width: 8),
              _MobileKpiChip(label: 'Admin OK', value: adminApprovedCount.toString(), color: _RC.violet, icon: Icons.verified_rounded),
              const SizedBox(width: 8),
              _MobileKpiChip(label: 'Pending', value: adminPendingCount.toString(), color: _RC.amber, icon: Icons.pending_actions_rounded),
            ]),
          ),
        ),
        // Admin alert banner
        if (adminPendingCount > 0)
          GestureDetector(
            onTap: () => _tab.animateTo(1),
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                  color: _RC.amberLight, borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _RC.amber.withOpacity(0.3))),
              child: Row(children: [
                Container(padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: _RC.amber.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.pending_actions_rounded, size: 16, color: _RC.amber)),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('$adminPendingCount request${adminPendingCount > 1 ? 's' : ''} need your review',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _RC.amber)),
                  const Text('Tap to view pending admin approvals',
                      style: TextStyle(fontSize: 11, color: _RC.textSecondary)),
                ])),
                const Icon(Icons.chevron_right_rounded, size: 18, color: _RC.amber),
              ]),
            ),
          ),
        // Active filter chips
        if (statusFilter != null || typeFilter != null || searchQuery.isNotEmpty)
          _buildActiveFilters(),
        // Tab bar
        Container(
          color: _RC.surface,
          margin: const EdgeInsets.only(top: 8),
          child: TabBar(
            controller: _tab,
            isScrollable: true,
            labelColor: _RC.indigo,
            unselectedLabelColor: _RC.textMuted,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            indicatorColor: _RC.indigo, indicatorWeight: 2.5,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: _RC.border,
            tabAlignment: TabAlignment.start,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            tabs: [
              _MobileTabChip(label: 'All', count: filteredRequests.length),
              _MobileTabChip(label: 'Admin', count: adminPendingCount, alert: adminPendingCount > 0),
              _MobileTabChip(label: 'Auto-OK', count: autoApprovedCount),
              _MobileTabChip(label: 'Rejected', count: staffRejectedCount + requests.where((r) => r.status == RequestStatus.adminRejected).length),
            ],
          ),
        ),
        // Content
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [
              _buildList(filteredRequests),
              _buildList(pendingAdminList),
              _buildList(requests.where((r) =>
                  r.status == RequestStatus.autoApproved || r.status == RequestStatus.scheduled).toList()),
              _buildList(requests.where((r) =>
                  r.status == RequestStatus.staffRejected || r.status == RequestStatus.adminRejected).toList()),
            ],
          ),
        ),
      ]),
    );
  }

  // ── AppBar ───────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _RC.surface,
      elevation: 0,
      titleSpacing: 16,
      title: Row(children: [
        Container(width: 4, height: 22,
            decoration: BoxDecoration(
                gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [_RC.indigo, _RC.violet]),
                borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 10),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.4, color: _RC.textPrimary)),
          Text('Machine usage approvals', style: TextStyle(fontSize: 11, color: _RC.textSecondary)),
        ]),
      ]),
      actions: [
        // Search
        IconButton(icon: const Icon(Icons.search_rounded, color: _RC.textSecondary, size: 22), onPressed: _showSearchSheet),
        // Filter
        Stack(alignment: Alignment.center, children: [
          IconButton(icon: const Icon(Icons.tune_rounded, color: _RC.textSecondary, size: 22), onPressed: _showFilterSheet),
          if (statusFilter != null || typeFilter != null)
            Positioned(top: 8, right: 8, child: Container(width: 8, height: 8,
                decoration: const BoxDecoration(color: _RC.indigo, shape: BoxShape.circle))),
        ]),
        // Notification bell
        Stack(alignment: Alignment.center, children: [
          IconButton(icon: const Icon(Icons.notifications_rounded, color: _RC.textSecondary, size: 22), onPressed: _showNotifSheet),
          if (unreadNotifCount > 0)
            Positioned(top: 8, right: 8, child: Container(
                width: 14, height: 14,
                decoration: const BoxDecoration(color: _RC.rose, shape: BoxShape.circle),
                child: Center(child: Text('$unreadNotifCount', style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.white))))),
        ]),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _RC.border)),
    );
  }

  // ── Active filter chips ──────────────────────
  Widget _buildActiveFilters() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
    child: Row(children: [
      if (searchQuery.isNotEmpty)
        _ActiveChip(label: '"$searchQuery"', color: _RC.indigo, onRemove: () => setState(() => searchQuery = '')),
      if (typeFilter != null) ...[
        if (searchQuery.isNotEmpty) const SizedBox(width: 6),
        _ActiveChip(label: _typeMeta(typeFilter!).label, color: _typeMeta(typeFilter!).color,
            onRemove: () => setState(() => typeFilter = null)),
      ],
      if (statusFilter != null) ...[
        if (typeFilter != null || searchQuery.isNotEmpty) const SizedBox(width: 6),
        _ActiveChip(label: _statusMeta(statusFilter!).label, color: _statusMeta(statusFilter!).color,
            onRemove: () => setState(() => statusFilter = null)),
      ],
      const SizedBox(width: 6),
      GestureDetector(
        onTap: clearFilters,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: _RC.border)),
          child: const Text('Clear all', style: TextStyle(fontSize: 11, color: _RC.textMuted, fontWeight: FontWeight.w600))),
      ),
    ]),
  );

  // ── Request list ─────────────────────────────
  Widget _buildList(List<MachineRequest> list) {
    if (list.isEmpty) {
      return Center(child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(color: _RC.indigoLight, shape: BoxShape.circle),
              child: const Icon(Icons.inbox_rounded, size: 28, color: _RC.indigo)),
          const SizedBox(height: 14),
          const Text('No requests here', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _RC.textPrimary)),
          const SizedBox(height: 6),
          const Text('Nothing to show right now', style: TextStyle(fontSize: 13, color: _RC.textSecondary)),
        ]),
      ));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox.shrink(),
      itemBuilder: (_, i) => _RequestCard(
        request: list[i],
        onTap: () => _showDetailSheet(list[i]),
        onApprove: (id) { adminApprove(id); },
        onReject: (id, reason) { adminReject(id, reason); },
      ),
    );
  }

  // ── Detail bottom sheet ──────────────────────
  void _showDetailSheet(MachineRequest r) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          maxChildSize: 0.97,
          builder: (_, sc) => Container(
            decoration: const BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            child: Column(children: [
              Container(margin: const EdgeInsets.only(top: 10), width: 36, height: 4,
                  decoration: BoxDecoration(color: _RC.border, borderRadius: BorderRadius.circular(4))),
              Expanded(
                child: SingleChildScrollView(
                  controller: sc,
                  child: _SharedRequestDetail(
                    request: requests.firstWhere((req) => req.id == r.id),
                    onClose: () => Navigator.pop(ctx),
                    onApprove: (id) {
                      adminApprove(id);
                      setSheetState(() {});
                    },
                    onReject: (id, reason) {
                      adminReject(id, reason);
                      setSheetState(() {});
                    },
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  // ── Notification sheet ───────────────────────
  void _showNotifSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.92,
          builder: (_, sc) => Column(children: [
            Container(margin: const EdgeInsets.only(top: 10), width: 36, height: 4,
                decoration: BoxDecoration(color: _RC.border, borderRadius: BorderRadius.circular(4))),
            Padding(padding: const EdgeInsets.fromLTRB(20, 14, 16, 10),
              child: Row(children: [
                const Icon(Icons.notifications_active_rounded, size: 16, color: _RC.indigo),
                const SizedBox(width: 7),
                const Text('Notifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _RC.textPrimary)),
                const Spacer(),
                if (unreadNotifCount > 0)
                  TextButton(
                    onPressed: () { markAllNotifsRead(); setSheetState(() {}); },
                    child: const Text('Mark all read', style: TextStyle(fontSize: 12, color: _RC.indigo))),
              ])),
            const Divider(height: 1, color: _RC.border),
            Expanded(child: ListView.builder(
              controller: sc,
              itemCount: notifs.length,
              itemBuilder: (_, i) => _NotifTile(
                notif: notifs[i],
                onMarkRead: (id) { markNotifRead(id); setSheetState(() {}); },
              ),
            )),
          ]),
        ),
      ),
    );
  }

  // ── Search sheet ─────────────────────────────
  void _showSearchSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        String localQ = searchQuery;
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Search Requests', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _RC.textPrimary)),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(color: _RC.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _RC.border)),
                child: TextField(
                  autofocus: true,
                  controller: TextEditingController(text: searchQuery),
                  style: const TextStyle(fontSize: 14, color: _RC.textPrimary),
                  decoration: const InputDecoration(hintText: 'Name, machine or request ID…',
                      hintStyle: TextStyle(fontSize: 14, color: _RC.textMuted),
                      prefixIcon: Icon(Icons.search_rounded, color: _RC.textMuted, size: 20),
                      border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 14)),
                  onChanged: (v) => localQ = v,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(width: double.infinity, child: ElevatedButton(
                onPressed: () { setState(() => searchQuery = localQ); Navigator.pop(context); },
                style: ElevatedButton.styleFrom(backgroundColor: _RC.indigo, foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0, textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                child: const Text('Search'),
              )),
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        // Declared OUTSIDE StatefulBuilder to survive rebuilds
        RequestType? localType = typeFilter;
        RequestStatus? localStatus = statusFilter;

        return StatefulBuilder(
          builder: (ctx, setSheetState) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            builder: (_, sc) => ListView(
              controller: sc,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              children: [
                Row(children: [
                  const Text('Filter Requests', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _RC.textPrimary)),
                  const Spacer(),
                  TextButton(onPressed: () { setState(clearFilters); Navigator.pop(ctx); },
                      child: const Text('Clear All', style: TextStyle(color: _RC.rose))),
                ]),
                const SizedBox(height: 16),
                const Text('Request Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _RC.textSecondary)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  _FilterPill(label: 'All', isActive: localType == null, activeColor: _RC.indigo,
                      onTap: () => setSheetState(() => localType = null)),
                  ...RequestType.values.map((t) => _FilterPill(
                      label: _typeMeta(t).label, isActive: localType == t,
                      activeColor: _typeMeta(t).color,
                      onTap: () => setSheetState(() => localType = t))),
                ]),
                const SizedBox(height: 16),
                const Text('Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _RC.textSecondary)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  _FilterPill(label: 'All', isActive: localStatus == null, activeColor: _RC.indigo,
                      onTap: () => setSheetState(() => localStatus = null)),
                  ...RequestStatus.values.map((s) => _FilterPill(
                      label: _statusMeta(s).label, isActive: localStatus == s,
                      activeColor: _statusMeta(s).color,
                      onTap: () => setSheetState(() => localStatus = s))),
                ]),
                const SizedBox(height: 24),
                SizedBox(width: double.infinity, child: ElevatedButton(
                  onPressed: () {
                    setState(() { typeFilter = localType; statusFilter = localStatus; });
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: _RC.indigo, foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0, textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  child: const Text('Apply Filters'),
                )),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  MOBILE-ONLY SMALL WIDGETS
// ─────────────────────────────────────────────
class _MobileKpiChip extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _MobileKpiChip({required this.label, required this.value, required this.color, required this.icon});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10),
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

class _MobileTabChip extends StatelessWidget {
  final String label;
  final int count;
  final bool alert;
  const _MobileTabChip({required this.label, required this.count, this.alert = false});
  @override
  Widget build(BuildContext context) => Tab(
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(label),
      const SizedBox(width: 5),
      Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(color: alert ? _RC.rose : _RC.indigoLight, borderRadius: BorderRadius.circular(9)),
          child: Text('$count', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
              color: alert ? Colors.white : _RC.indigo))),
    ]),
  );
}

class _ActiveChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onRemove;
  const _ActiveChip({required this.label, required this.color, required this.onRemove});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      const SizedBox(width: 5),
      GestureDetector(onTap: onRemove, child: Icon(Icons.close_rounded, size: 13, color: color)),
    ]),
  );
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;
  const _FilterPill({required this.label, required this.isActive, required this.activeColor, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
          color: isActive ? activeColor : activeColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? activeColor : activeColor.withOpacity(0.2))),
      child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
          color: isActive ? Colors.white : activeColor)),
    ),
  );
}
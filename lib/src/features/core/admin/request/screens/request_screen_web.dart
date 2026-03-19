part of 'request_screen.dart';

// ─────────────────────────────────────────────
//  WEB REQUEST VIEW
// ─────────────────────────────────────────────
class _WebRequestView extends StatefulWidget {
  const _WebRequestView();
  @override
  State<_WebRequestView> createState() => _WebRequestViewState();
}

class _WebRequestViewState extends State<_WebRequestView>
    with SingleTickerProviderStateMixin, _RequestStateMixin {
  late TabController _tab;
  MachineRequest? _selectedRequest;
  bool _showNotifs = false;

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
      body: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ── Header ──
            Container(
              color: _RC.surface,
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _SharedAnalyticsStrip(
                  todayCount: totalToday,
                  autoApproved: autoApprovedCount,
                  staffRejected: staffRejectedCount,
                  adminApproved: adminApprovedCount,
                  adminPending: adminPendingCount,
                ),
                const SizedBox(height: 16),
                _buildFiltersBar(),
                const SizedBox(height: 16),
                TabBar(
                  controller: _tab,
                  isScrollable: true,
                  labelColor: _RC.indigo,
                  unselectedLabelColor: _RC.textMuted,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  indicatorColor: _RC.indigo, indicatorWeight: 2.5,
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: _RC.border,
                  tabs: [
                    _WebTabItem(label: 'All Requests', count: filteredRequests.length),
                    _WebTabItem(label: 'Needs Admin', count: adminPendingCount,
                        alert: adminPendingCount > 0),
                    _WebTabItem(label: 'Auto-Approved', count: autoApprovedCount),
                    _WebTabItem(label: 'Rejected', count: staffRejectedCount + requests.where((r) => r.status == RequestStatus.adminRejected).length),
                  ],
                ),
              ]),
            ),
            // ── Tab content ──
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  _buildRequestList(filteredRequests),
                  _buildRequestList(pendingAdminList),
                  _buildRequestList(requests.where((r) =>
                      r.status == RequestStatus.autoApproved || r.status == RequestStatus.scheduled).toList()),
                  _buildRequestList(requests.where((r) =>
                      r.status == RequestStatus.staffRejected || r.status == RequestStatus.adminRejected).toList()),
                ],
              ),
            ),
          ]),
        ),

        // ── Right panel: notifs OR request detail ──
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: (_showNotifs || _selectedRequest != null) ? 360 : 0,
          child: _showNotifs || _selectedRequest != null
              ? Container(
                  constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
                  decoration: const BoxDecoration(
                      color: _RC.surface, border: Border(left: BorderSide(color: _RC.border))),
                  child: _showNotifs
                      ? _buildNotifPanel()
                      : _selectedRequest != null
                          ? _SharedRequestDetail(
                              request: _selectedRequest!,
                              onClose: () => setState(() => _selectedRequest = null),
                              onApprove: (id) {
                                adminApprove(id);
                                setState(() {
                                  _selectedRequest = requests.firstWhere((r) => r.id == id);
                                });
                              },
                              onReject: (id, reason) {
                                adminReject(id, reason);
                                setState(() {
                                  _selectedRequest = requests.firstWhere((r) => r.id == id);
                                });
                              },
                            )
                          : const SizedBox.shrink(),
                )
              : const SizedBox.shrink(),
        ),
      ]),
    );
  }

  // ── Header ──────────────────────────────────
  Widget _buildHeader() {
    return Row(children: [
      Container(width: 6, height: 32,
          decoration: BoxDecoration(
              gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [_RC.indigo, _RC.violet]),
              borderRadius: BorderRadius.circular(4))),
      const SizedBox(width: 14),
      const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Requests', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.6, color: _RC.textPrimary)),
        Text('Review, approve or reject machine usage requests', style: TextStyle(fontSize: 13, color: _RC.textSecondary)),
      ]),
      const Spacer(),
      // Notification bell
      GestureDetector(
        onTap: () => setState(() { _showNotifs = !_showNotifs; if (_showNotifs) _selectedRequest = null; }),
        child: Stack(alignment: Alignment.topRight, children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: _showNotifs ? _RC.indigoLight : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _showNotifs ? _RC.indigo.withOpacity(0.3) : _RC.border)),
            child: Icon(Icons.notifications_rounded, size: 18,
                color: _showNotifs ? _RC.indigo : _RC.textSecondary)),
          if (unreadNotifCount > 0)
            Positioned(top: 4, right: 4, child: Container(
                width: 16, height: 16,
                decoration: const BoxDecoration(color: _RC.rose, shape: BoxShape.circle),
                child: Center(child: Text('$unreadNotifCount',
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white))))),
        ]),
      ),
      const SizedBox(width: 10),
      if (adminPendingCount > 0)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(color: _RC.amberLight, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _RC.amber.withOpacity(0.3))),
          child: Row(children: [
            const Icon(Icons.pending_actions_rounded, size: 14, color: _RC.amber),
            const SizedBox(width: 6),
            Text('$adminPendingCount need your attention',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _RC.amber)),
          ]),
        ),
    ]);
  }

  // ── Filters bar ─────────────────────────────
  Widget _buildFiltersBar() {
    return Row(children: [
      Expanded(child: Container(
        height: 40,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(9), border: Border.all(color: _RC.border)),
        child: TextField(
          onChanged: (v) => setState(() => searchQuery = v),
          style: const TextStyle(fontSize: 13, color: _RC.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Search by name, machine or ID…',
            hintStyle: TextStyle(fontSize: 12, color: _RC.textMuted),
            prefixIcon: Icon(Icons.search_rounded, size: 16, color: _RC.textMuted),
            border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 10)),
        ),
      )),
      const SizedBox(width: 8),
      _WebFilterBtn(
        label: typeFilter == null ? 'All Types' : _typeMeta(typeFilter!).label,
        color: typeFilter != null ? _typeMeta(typeFilter!).color : _RC.textSecondary,
        onTap: _showTypePicker,
      ),
      const SizedBox(width: 6),
      _WebFilterBtn(
        label: statusFilter == null ? 'All Status' : _statusMeta(statusFilter!).label,
        color: statusFilter != null ? _statusMeta(statusFilter!).color : _RC.textSecondary,
        onTap: _showStatusPicker,
      ),
      if (statusFilter != null || typeFilter != null || searchQuery.isNotEmpty)
        Padding(padding: const EdgeInsets.only(left: 6),
          child: GestureDetector(onTap: clearFilters,
            child: Container(padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: _RC.border)),
              child: const Icon(Icons.close_rounded, size: 15, color: _RC.textMuted)))),
    ]);
  }

  // ── Request list ─────────────────────────────
  Widget _buildRequestList(List<MachineRequest> list) {
    if (list.isEmpty) {
      return Center(child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(color: _RC.indigoLight, shape: BoxShape.circle),
              child: const Icon(Icons.inbox_rounded, size: 28, color: _RC.indigo)),
          const SizedBox(height: 14),
          const Text('No requests', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _RC.textPrimary)),
          const SizedBox(height: 6),
          const Text('Nothing here right now.', style: TextStyle(fontSize: 13, color: _RC.textSecondary)),
        ]),
      ));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 40),
      child: Column(children: list.map((r) => _RequestCard(
        request: r,
        isSelected: _selectedRequest?.id == r.id,
        onTap: () => setState(() {
          _selectedRequest = _selectedRequest?.id == r.id ? null : r;
          _showNotifs = false;
        }),
        onApprove: (id) { adminApprove(id); _refreshSelected(id); },
        onReject: (id, reason) { adminReject(id, reason); _refreshSelected(id); },
      )).toList()),
    );
  }

  void _refreshSelected(String id) {
    setState(() { _selectedRequest = requests.firstWhere((r) => r.id == id); });
  }

  // ── Notification panel ───────────────────────
  Widget _buildNotifPanel() {
    return SingleChildScrollView(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
          child: Row(children: [
            const Icon(Icons.notifications_active_rounded, size: 16, color: _RC.indigo),
            const SizedBox(width: 7),
            const Text('Admin Notifications',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _RC.textPrimary)),
            const Spacer(),
            GestureDetector(onTap: () => setState(() => _showNotifs = false),
              child: Container(padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: _RC.bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: _RC.border)),
                child: const Icon(Icons.close_rounded, size: 15, color: _RC.textSecondary))),
          ]),
        ),
        const Divider(height: 1, color: _RC.border),
        if (unreadNotifCount > 0) ...[
          Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(children: [
              Text('${unreadNotifCount} unread',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _RC.textMuted)),
              const Spacer(),
              TextButton(onPressed: markAllNotifsRead,
                  child: const Text('Mark all read', style: TextStyle(fontSize: 11, color: _RC.indigo))),
            ])),
        ],
        ...notifs.map((n) => _NotifTile(notif: n, onMarkRead: markNotifRead)),
      ]),
    );
  }

  void _showTypePicker() => showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) {
      return _PickerSheet(title: 'Filter by Type', options: [
        _PickerOption('All Types', () { setState(() => typeFilter = null); Navigator.pop(context); }),
        ...RequestType.values.map((t) => _PickerOption(
            _typeMeta(t).label, () { setState(() => typeFilter = t); Navigator.pop(context); })),
      ]);
    },
  );

  void _showStatusPicker() => showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) {
      return _PickerSheet(title: 'Filter by Status', options: [
        _PickerOption('All Status', () { setState(() => statusFilter = null); Navigator.pop(context); }),
        ...RequestStatus.values.map((s) => _PickerOption(
            _statusMeta(s).label, () { setState(() => statusFilter = s); Navigator.pop(context); })),
      ]);
    },
  );
}

// ─────────────────────────────────────────────
//  WEB-ONLY SMALL WIDGETS
// ─────────────────────────────────────────────
class _WebTabItem extends StatelessWidget {
  final String label;
  final int count;
  final bool alert;
  const _WebTabItem({required this.label, required this.count, this.alert = false});
  @override
  Widget build(BuildContext context) => Tab(
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(label),
      const SizedBox(width: 6),
      Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
              color: alert ? _RC.rose : _RC.indigoLight, borderRadius: BorderRadius.circular(10)),
          child: Text('$count', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
              color: alert ? Colors.white : _RC.indigo))),
    ]),
  );
}

class _WebFilterBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _WebFilterBtn({required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: _RC.border)),
      child: Row(children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        const SizedBox(width: 4),
        Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: color),
      ]),
    ),
  );
}

class _PickerOption {
  final String label;
  final VoidCallback onTap;
  const _PickerOption(this.label, this.onTap);
}

class _PickerSheet extends StatelessWidget {
  final String title;
  final List<_PickerOption> options;
  const _PickerSheet({required this.title, required this.options});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _RC.textPrimary)),
      const SizedBox(height: 14),
      ...options.map((o) => ListTile(
          title: Text(o.label, style: const TextStyle(fontSize: 14, color: _RC.textPrimary)),
          onTap: o.onTap, contentPadding: EdgeInsets.zero, dense: true)),
    ]),
  );
}
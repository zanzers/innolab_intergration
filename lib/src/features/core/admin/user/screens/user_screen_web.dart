part of 'user_screen.dart';

// ─────────────────────────────────────────────
//  WEB USER VIEW
// ─────────────────────────────────────────────
class _WebUserView extends StatefulWidget {
  const _WebUserView();
  @override
  State<_WebUserView> createState() => _WebUserViewState();
}

class _WebUserViewState extends State<_WebUserView> with _UserStateMixin {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _UC.bg,
      body: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Main content ──
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 32, 20, 40),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildSummaryRow(),
              const SizedBox(height: 20),
              _buildFilters(),
              const SizedBox(height: 16),
              _buildUserTable(),
            ]),
          ),
        ),

        // ── Detail panel ──
        if (selectedUser != null)
          Container(
            width: 360,
            constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
            decoration: const BoxDecoration(
                color: _UC.surface,
                border: Border(left: BorderSide(color: _UC.border))),
            child: _SharedUserDetail(
              user: selectedUser!,
              onClose: () => setState(() => selectedUser = null),
              onSuspend: () => suspendUser(selectedUser!.id),
              onReactivate: () => reactivateUser(selectedUser!.id),
            ),
          ),
      ]),
    );
  }

  // ── Header ──────────────────────────────────
  Widget _buildHeader() {
    return Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 6, height: 32,
              decoration: BoxDecoration(
                  gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [_UC.indigo, _UC.violet]),
                  borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 14),
          const Text('Users', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
              letterSpacing: -0.7, color: _UC.textPrimary)),
        ]),
        const SizedBox(height: 4),
        const Padding(padding: EdgeInsets.only(left: 20),
          child: Text('Manage and monitor all user print requests',
              style: TextStyle(fontSize: 14, color: _UC.textSecondary))),
      ])),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(color: _UC.indigoLight, borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _UC.indigo.withOpacity(0.2))),
        child: Row(children: [
          const Icon(Icons.people_alt_rounded, size: 15, color: _UC.indigo),
          const SizedBox(width: 8),
          Text('${users.length} Total Users',
              style: const TextStyle(color: _UC.indigo, fontWeight: FontWeight.w700, fontSize: 13)),
        ]),
      ),
    ]);
  }

  // ── Summary row ──────────────────────────────
  Widget _buildSummaryRow() => Row(children: [
    _SummaryCard(label: 'Active Users',    value: activeCount.toString(),              color: _UC.emerald, icon: Icons.person_rounded),
    const SizedBox(width: 12),
    _SummaryCard(label: 'Total Requests',  value: totalRequests.toString(),            color: _UC.indigo,  icon: Icons.layers_rounded),
    const SizedBox(width: 12),
    _SummaryCard(label: 'Pending',         value: totalPending.toString(),             color: _UC.amber,   icon: Icons.hourglass_top_rounded),
    const SizedBox(width: 12),
    _SummaryCard(label: 'Revenue',         value: '₱${totalRevenue.toStringAsFixed(0)}', color: _UC.violet, icon: Icons.payments_rounded),
    const SizedBox(width: 12),
    _SummaryCard(label: 'Suspended',       value: suspendedCount.toString(),           color: _UC.rose,    icon: Icons.block_rounded),
  ]);

  // ── Filters ──────────────────────────────────
  Widget _buildFilters() {
    return Row(children: [
      Expanded(child: Container(
        height: 42,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: _UC.border)),
        child: TextField(
          onChanged: (v) => setState(() => searchQuery = v),
          style: const TextStyle(fontSize: 14, color: _UC.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Search by name, email, type or ID…',
            hintStyle: TextStyle(fontSize: 13, color: _UC.textMuted),
            prefixIcon: Icon(Icons.search_rounded, size: 18, color: _UC.textMuted),
            border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 12)),
        ),
      )),
      const SizedBox(width: 12),
      // Status filter chips
      Row(children: [
        const Text('Status:', style: TextStyle(fontSize: 12, color: _UC.textSecondary, fontWeight: FontWeight.w600)),
        const SizedBox(width: 6),
        ..._UserStateMixin.statusFilters.map((f) => GestureDetector(
          onTap: () => setState(() => statusFilter = f),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(left: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
                color: statusFilter == f ? _UC.indigo : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusFilter == f ? _UC.indigo : _UC.border)),
            child: Text(f, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                color: statusFilter == f ? Colors.white : _UC.textSecondary)),
          ),
        )),
      ]),
    ]);
  }

  // ── User table ───────────────────────────────
  Widget _buildUserTable() {
    final list = filteredUsers;
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _UC.border),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))]),
      child: Column(children: [
        // Table header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: const BoxDecoration(color: _UC.bg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
          child: const Row(children: [
            Expanded(flex: 3, child: _TH('User')),
            Expanded(flex: 2, child: _TH('Type')),
            Expanded(flex: 2, child: _TH('Requests')),
            Expanded(flex: 1, child: _TH('Pending')),
            Expanded(flex: 2, child: _TH('Spent')),
            Expanded(flex: 2, child: _TH('Last Activity')),
            Expanded(flex: 2, child: _TH('Status')),
          ]),
        ),
        const Divider(height: 1, color: _UC.border),
        if (list.isEmpty)
          const Padding(padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: Text('No users match your filters',
                style: TextStyle(color: _UC.textMuted, fontSize: 14))))
        else
          ...list.asMap().entries.map((e) => _WebUserRow(
            user: e.value,
            isEven: e.key.isEven,
            isSelected: selectedUser?.id == e.value.id,
            onTap: () => setState(() {
              selectedUser = selectedUser?.id == e.value.id ? null : e.value;
            }),
          )),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
//  WEB USER ROW
// ─────────────────────────────────────────────
class _WebUserRow extends StatelessWidget {
  final AppUser user;
  final bool isEven, isSelected;
  final VoidCallback onTap;

  const _WebUserRow({required this.user, required this.isEven, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sm = _accountStatusMeta(user.accountStatus);
    final actColor = _lastActivityColor(user.lastActivity);

    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? _UC.indigoLight : isEven ? Colors.white : _UC.bg.withOpacity(0.5),
          border: Border(left: BorderSide(color: isSelected ? _UC.indigo : Colors.transparent, width: 3)),
        ),
        child: Row(children: [
          // User info
          Expanded(flex: 3, child: Row(children: [
            Stack(children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: user.isActive ? user.avatarColor.withOpacity(0.15) : _UC.slateLight,
                child: Text(user.initials, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                    color: user.isActive ? user.avatarColor : _UC.textMuted)),
              ),
              if (user.accountStatus == UserAccountStatus.suspended)
                Positioned(right: 0, bottom: 0, child: Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(color: _UC.rose, shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5)))),
            ]),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(user.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _UC.textPrimary)),
              Text(user.email, style: const TextStyle(fontSize: 11, color: _UC.textMuted), overflow: TextOverflow.ellipsis),
            ])),
          ])),
          // Type
          Expanded(flex: 2, child: Row(children: [
            const Icon(Icons.business_center_rounded, size: 12, color: _UC.textMuted),
            const SizedBox(width: 5),
            Text(user.type, style: const TextStyle(fontSize: 12, color: _UC.textSecondary)),
          ])),
          // Requests
          Expanded(flex: 2, child: Text(user.totalRequests.toString(),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _UC.textPrimary))),
          // Pending
          Expanded(flex: 1, child: user.pendingRequests > 0
              ? Container(
                  width: 28, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: _UC.amberLight, borderRadius: BorderRadius.circular(6)),
                  child: Text(user.pendingRequests.toString(),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _UC.amber)))
              : Text('—', style: TextStyle(fontSize: 13, color: _UC.textMuted.withOpacity(0.5)))),
          // Spent
          Expanded(flex: 2, child: Text('₱${user.totalSpent.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _UC.textPrimary, fontFamily: 'monospace'))),
          // Last Activity
          Expanded(flex: 2, child: Row(children: [
            Container(width: 7, height: 7, margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(color: actColor, shape: BoxShape.circle)),
            Text(_timeAgo(user.lastActivity),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: actColor)),
          ])),
          // Status
          Expanded(flex: 2, child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(color: sm.light, borderRadius: BorderRadius.circular(8)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(color: sm.color, shape: BoxShape.circle)),
                const SizedBox(width: 5),
                Text(sm.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: sm.color)),
              ]),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, size: 16, color: _UC.textMuted),
          ])),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  WEB TABLE HEADER WIDGET
// ─────────────────────────────────────────────
class _TH extends StatelessWidget {
  final String label;
  const _TH(this.label);
  @override
  Widget build(BuildContext context) => Text(label,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _UC.textMuted, letterSpacing: 0.4));
}
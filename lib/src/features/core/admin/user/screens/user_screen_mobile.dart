part of 'user_screen.dart';

// ─────────────────────────────────────────────
//  MOBILE USER VIEW
// ─────────────────────────────────────────────
class _MobileUserView extends StatefulWidget {
  const _MobileUserView();
  @override
  State<_MobileUserView> createState() => _MobileUserViewState();
}

class _MobileUserViewState extends State<_MobileUserView> with _UserStateMixin {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _UC.bg,
      appBar: _buildAppBar(),
      body: Column(children: [
        // Stats strip
        Container(
          color: _UC.surface,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _MobileStatChip(label: 'Active',    value: activeCount.toString(),              color: _UC.emerald, icon: Icons.person_rounded),
              const SizedBox(width: 8),
              _MobileStatChip(label: 'Requests',  value: totalRequests.toString(),            color: _UC.indigo,  icon: Icons.layers_rounded),
              const SizedBox(width: 8),
              _MobileStatChip(label: 'Pending',   value: totalPending.toString(),             color: _UC.amber,   icon: Icons.hourglass_top_rounded),
              const SizedBox(width: 8),
              _MobileStatChip(label: 'Revenue',   value: '₱${totalRevenue.toStringAsFixed(0)}', color: _UC.violet, icon: Icons.payments_rounded),
              const SizedBox(width: 8),
              _MobileStatChip(label: 'Suspended', value: suspendedCount.toString(),           color: _UC.rose,    icon: Icons.block_rounded),
            ]),
          ),
        ),
        // Search + filter
        Container(
          color: _UC.surface,
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
          child: Column(children: [
            Container(
              height: 40,
              decoration: BoxDecoration(color: _UC.bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: _UC.border)),
              child: TextField(
                onChanged: (v) => setState(() => searchQuery = v),
                style: const TextStyle(fontSize: 13, color: _UC.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Search name, email or type…',
                  hintStyle: TextStyle(fontSize: 13, color: _UC.textMuted),
                  prefixIcon: Icon(Icons.search_rounded, size: 17, color: _UC.textMuted),
                  border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 10)),
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: _UserStateMixin.statusFilters.map((f) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () => setState(() => statusFilter = f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                    decoration: BoxDecoration(
                        color: statusFilter == f ? _UC.indigo : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusFilter == f ? _UC.indigo : _UC.border)),
                    child: Text(f, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                        color: statusFilter == f ? Colors.white : _UC.textSecondary)),
                  ),
                ),
              )).toList()),
            ),
          ]),
        ),
        const Divider(height: 1, color: _UC.border),
        // User list
        Expanded(child: _buildList()),
      ]),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _UC.surface,
      elevation: 0,
      titleSpacing: 16,
      title: Row(children: [
        Container(width: 4, height: 22,
            decoration: BoxDecoration(
                gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [_UC.indigo, _UC.violet]),
                borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 10),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Users', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.4, color: _UC.textPrimary)),
          Text('Print request management', style: TextStyle(fontSize: 11, color: _UC.textSecondary)),
        ]),
      ]),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: _UC.indigoLight, borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _UC.indigo.withOpacity(0.2))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.people_alt_rounded, size: 13, color: _UC.indigo),
            const SizedBox(width: 5),
            Text('${users.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _UC.indigo)),
          ]),
        ),
      ],
      bottom: PreferredSize(preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _UC.border)),
    );
  }

  Widget _buildList() {
    final list = filteredUsers;
    if (list.isEmpty) {
      return Center(child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(color: _UC.indigoLight, shape: BoxShape.circle),
              child: const Icon(Icons.people_outline_rounded, size: 28, color: _UC.indigo)),
          const SizedBox(height: 14),
          const Text('No users found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _UC.textPrimary)),
          const SizedBox(height: 6),
          const Text('Try a different filter', style: TextStyle(fontSize: 13, color: _UC.textSecondary)),
        ]),
      ));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 40),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _MobileUserCard(
        user: list[i],
        onTap: () => _showDetail(list[i]),
      ),
    );
  }

  void _showDetail(AppUser user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.86,
          maxChildSize: 0.97,
          builder: (_, sc) => Container(
            decoration: const BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            child: Column(children: [
              Container(margin: const EdgeInsets.only(top: 10), width: 36, height: 4,
                  decoration: BoxDecoration(color: _UC.border, borderRadius: BorderRadius.circular(4))),
              Expanded(child: SingleChildScrollView(
                controller: sc,
                child: _SharedUserDetail(
                  user: users.firstWhere((u) => u.id == user.id),
                  onClose: () => Navigator.pop(ctx),
                  onSuspend: () {
                    suspendUser(user.id);
                    setSheetState(() {});
                  },
                  onReactivate: () {
                    reactivateUser(user.id);
                    setSheetState(() {});
                  },
                ),
              )),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  MOBILE USER CARD
// ─────────────────────────────────────────────
class _MobileUserCard extends StatelessWidget {
  final AppUser user;
  final VoidCallback onTap;
  const _MobileUserCard({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sm = _accountStatusMeta(user.accountStatus);
    final actColor = _lastActivityColor(user.lastActivity);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: user.accountStatus == UserAccountStatus.suspended
              ? _UC.rose.withOpacity(0.3) : _UC.border),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Row 1: avatar + name + status
          Row(children: [
            Stack(children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: user.isActive ? user.avatarColor.withOpacity(0.15) : _UC.slateLight,
                child: Text(user.initials, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                    color: user.isActive ? user.avatarColor : _UC.textMuted)),
              ),
              if (user.accountStatus == UserAccountStatus.suspended)
                Positioned(right: 0, bottom: 0, child: Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(color: _UC.rose, shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2)))),
            ]),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(user.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _UC.textPrimary)),
              Text(user.email, style: const TextStyle(fontSize: 11, color: _UC.textMuted), overflow: TextOverflow.ellipsis),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: sm.light, borderRadius: BorderRadius.circular(8)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(color: sm.color, shape: BoxShape.circle)),
                const SizedBox(width: 5),
                Text(sm.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: sm.color)),
              ]),
            ),
          ]),
          const SizedBox(height: 10),

          // Row 2: type + last activity
          Row(children: [
            const Icon(Icons.business_center_rounded, size: 12, color: _UC.textMuted),
            const SizedBox(width: 5),
            Text(user.type, style: const TextStyle(fontSize: 12, color: _UC.textSecondary)),
            const Expanded(child: SizedBox()),
            Container(width: 7, height: 7, margin: const EdgeInsets.only(right: 5),
                decoration: BoxDecoration(color: actColor, shape: BoxShape.circle)),
            Text(_timeAgo(user.lastActivity),
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: actColor)),
          ]),
          const SizedBox(height: 10),
          const Divider(height: 1, color: _UC.border),
          const SizedBox(height: 10),

          // Row 3: stats chips
          Row(children: [
            _StatPill(label: 'Requests', value: user.totalRequests.toString(), color: _UC.indigo),
            const SizedBox(width: 6),
            _StatPill(label: 'Completed', value: user.completedPrints.toString(), color: _UC.emerald),
            const SizedBox(width: 6),
            if (user.pendingRequests > 0)
              _StatPill(label: 'Pending', value: user.pendingRequests.toString(), color: _UC.amber),
            const Expanded(child: SizedBox()),
            Text('₱${user.totalSpent.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _UC.violet, fontFamily: 'monospace')),
          ]),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  MOBILE-ONLY SMALL WIDGETS
// ─────────────────────────────────────────────
class _MobileStatChip extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _MobileStatChip({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

class _StatPill extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatPill({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(7),
        border: Border.all(color: color.withOpacity(0.15))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 10, color: color.withOpacity(0.8))),
    ]),
  );
}
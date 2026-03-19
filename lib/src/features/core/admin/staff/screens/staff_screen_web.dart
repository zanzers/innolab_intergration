part of 'staff_screen.dart';

// ─────────────────────────────────────────────
//  WEB STAFF VIEW
// ─────────────────────────────────────────────
class _WebStaffView extends StatefulWidget {
  const _WebStaffView();
  @override
  State<_WebStaffView> createState() => _WebStaffViewState();
}

class _WebStaffViewState extends State<_WebStaffView>
    with _StaffStateMixin {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _SC.bg,
      body: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Main content ──
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 32, 20, 40),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _SharedStatsStrip(
                online: onlineCount, printing: printingCount,
                onBreak: onBreakCount, onTravel: onTravelCount,
                offline: offlineCount, completedToday: completedToday,
                activeJobs: activeJobsCount, pending: pendingCount,
              ),
              const SizedBox(height: 20),
              _buildSearchAndFilter(),
              const SizedBox(height: 20),
              _buildGrid(),
            ]),
          ),
        ),

        // ── Right panel — detail OR activity feed ──
        Container(
          width: 320,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
              color: _SC.surface,
              border: Border(left: BorderSide(color: _SC.border))),
          child: selectedStaff != null
              ? _SharedStaffDetailContent(
                  member: selectedStaff!,
                  onClose: () => setState(() => selectedStaff = null),
                  onMarkComplete: () => setState(() => selectedStaff = null),
                  onReportIssue: () => _showReportSheet(context),
                )
              : const _SharedActivityFeed(),
        ),
      ]),
    );
  }

  // ── Header ──────────────────────────────────
  Widget _buildHeader() {
    final activeCount = kStaff.where((s) => s.status != StaffStatus.offline).length;
    return Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 6, height: 32,
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [_SC.indigo, _SC.violet]),
                  borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 14),
          const Text('Staff Monitor',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.7, color: _SC.textPrimary)),
        ]),
        const SizedBox(height: 4),
        const Padding(padding: EdgeInsets.only(left: 20),
          child: Text('Real-time staff activity across all 3D printers',
              style: TextStyle(fontSize: 14, color: _SC.textSecondary))),
      ])),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
            color: _SC.emerald.withOpacity(0.1), borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _SC.emerald.withOpacity(0.25))),
        child: Row(children: [
          const Icon(Icons.circle, color: _SC.emerald, size: 9),
          const SizedBox(width: 8),
          Text('$activeCount Active',
              style: const TextStyle(color: _SC.emerald, fontWeight: FontWeight.w700, fontSize: 13)),
        ]),
      ),
    ]);
  }

  // ── Search + filter chips ───────────────────
  Widget _buildSearchAndFilter() {
    return Row(children: [
      Expanded(child: Container(
        height: 42,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: _SC.border)),
        child: TextField(
          onChanged: (v) => setState(() => searchQuery = v),
          style: const TextStyle(fontSize: 14, color: _SC.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Search staff by name or role…',
            hintStyle: TextStyle(fontSize: 13, color: _SC.textMuted),
            prefixIcon: Icon(Icons.search_rounded, size: 18, color: _SC.textMuted),
            border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 12)),
        ),
      )),
      const SizedBox(width: 12),
      ..._StaffStateMixin.filters.map((f) => Padding(
        padding: const EdgeInsets.only(left: 8),
        child: GestureDetector(
          onTap: () => setState(() => statusFilter = f),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            decoration: BoxDecoration(
                color: statusFilter == f ? _SC.indigo : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusFilter == f ? _SC.indigo : _SC.border)),
            child: Text(f, style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: statusFilter == f ? Colors.white : _SC.textSecondary)),
          ),
        ),
      )),
    ]);
  }

  // ── Staff grid ───────────────────────────────
  Widget _buildGrid() {
    final staff = filteredStaff;
    if (staff.isEmpty) {
      return Center(child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.people_outline_rounded, size: 48, color: _SC.textMuted.withOpacity(0.4)),
          const SizedBox(height: 12),
          const Text('No staff match your filter', style: TextStyle(color: _SC.textMuted, fontSize: 14)),
        ]),
      ));
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.85),
      itemCount: staff.length,
      itemBuilder: (_, i) => _SharedStaffCard(
        member: staff[i],
        isSelected: selectedStaff?.id == staff[i].id,
        onTap: () => setState(() {
          selectedStaff = selectedStaff?.id == staff[i].id ? null : staff[i];
        }),
      ),
    );
  }

  void _showReportSheet(BuildContext context) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Report Issue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _SC.textPrimary)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(color: _SC.bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: _SC.border)),
            child: TextField(
              controller: ctrl, maxLines: 4, autofocus: true,
              style: const TextStyle(fontSize: 13, color: _SC.textPrimary),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            child: const Text('Submit Report'),
          )),
        ]),
      ),
    );
  }
}
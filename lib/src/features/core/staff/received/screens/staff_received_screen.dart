import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
// ── Status enum ───────────────────────────────────────────────────────────────

enum ReceivedStatus { pending, processing, completed, cancelled }

extension ReceivedStatusExt on ReceivedStatus {
  String get label {
    switch (this) {
      case ReceivedStatus.pending:    return 'Pending';
      case ReceivedStatus.processing: return 'Processing';
      case ReceivedStatus.completed:  return 'Completed';
      case ReceivedStatus.cancelled:  return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case ReceivedStatus.pending:    return const Color(0xFFF59E0B);
      case ReceivedStatus.processing: return const Color(0xFF3B82F6);
      case ReceivedStatus.completed:  return const Color(0xFF10B981);
      case ReceivedStatus.cancelled:  return const Color(0xFFEF4444);
    }
  }

  Color get bgColor {
    switch (this) {
      case ReceivedStatus.pending:    return const Color(0xFFFFF8E1);
      case ReceivedStatus.processing: return const Color(0xFFEFF6FF);
      case ReceivedStatus.completed:  return const Color(0xFFF0FDF4);
      case ReceivedStatus.cancelled:  return const Color(0xFFFEF2F2);
    }
  }

  IconData get icon {
    switch (this) {
      case ReceivedStatus.pending:    return Iconsax.clock;
      case ReceivedStatus.processing: return Iconsax.setting_2;
      case ReceivedStatus.completed:  return Iconsax.tick_circle;
      case ReceivedStatus.cancelled:  return Iconsax.close_circle;
    }
  }

  // Next actionable status from staff's side
  ReceivedStatus? get nextStatus {
    switch (this) {
      case ReceivedStatus.pending:    return ReceivedStatus.processing;
      case ReceivedStatus.processing: return ReceivedStatus.completed;
      case ReceivedStatus.completed:  return null;
      case ReceivedStatus.cancelled:  return null;
    }
  }

  String get nextLabel {
    switch (this) {
      case ReceivedStatus.pending:    return 'Start Processing';
      case ReceivedStatus.processing: return 'Mark as Completed';
      case ReceivedStatus.completed:  return '';
      case ReceivedStatus.cancelled:  return '';
    }
  }

  IconData get nextIcon {
    switch (this) {
      case ReceivedStatus.pending:    return Iconsax.play;
      case ReceivedStatus.processing: return Iconsax.tick_circle;
      default:                        return Iconsax.tick_circle;
    }
  }
}

// ── Data models ───────────────────────────────────────────────────────────────

class _IncomingRequest {
  final String id;
  final String userName;
  final String userEmail;
  final String fileName;
  final String material;
  final String printer;
  final int quantity;
  final double grandTotal;
  ReceivedStatus status;
  final DateTime submittedAt;
  final String? userNote;
  final String? discountType;
  final List<_StatusStep> timeline;

  _IncomingRequest({
    required this.id,
    required this.userName,
    required this.userEmail,
    required this.fileName,
    required this.material,
    required this.printer,
    required this.quantity,
    required this.grandTotal,
    required this.status,
    required this.submittedAt,
    this.userNote,
    this.discountType,
    required this.timeline,
  });
}

class _StatusStep {
  final String label;
  final String? time;
  final bool done;
  final bool active;

  const _StatusStep({
    required this.label,
    this.time,
    required this.done,
    this.active = false,
  });
}

// ── Sample data ───────────────────────────────────────────────────────────────

final List<_IncomingRequest> _sampleRequests = [
  _IncomingRequest(
    id: 'REQ-2024-001',
    userName: 'Marcelo Santos',
    userEmail: 'marcelo@email.com',
    fileName: 'bracket_v2.stl',
    material: 'PLA Standard – White',
    printer: 'Creality Ender 3',
    quantity: 2,
    grandTotal: 1240.50,
    status: ReceivedStatus.processing,
    submittedAt: DateTime.now().subtract(const Duration(hours: 3)),
    userNote: 'Please make sure the layer height is 0.2mm.',
    timeline: [
      _StatusStep(label: 'Order Submitted',   time: '9:00 AM',  done: true),
      _StatusStep(label: 'Reviewed by Staff', time: '9:45 AM',  done: true),
      _StatusStep(label: 'Printing',          time: '10:00 AM', done: false, active: true),
      _StatusStep(label: 'Ready for Pickup',  time: null,       done: false),
    ],
  ),
  _IncomingRequest(
    id: 'REQ-2024-002',
    userName: 'Ana Rivera',
    userEmail: 'ana@email.com',
    fileName: 'phone_stand.obj',
    material: 'PETG – Transparent',
    printer: 'Bambu Lab X1C',
    quantity: 1,
    grandTotal: 580.00,
    status: ReceivedStatus.pending,
    submittedAt: DateTime.now().subtract(const Duration(minutes: 30)),
    discountType: 'Student',
    timeline: [
      _StatusStep(label: 'Order Submitted',   time: '11:30 AM', done: true),
      _StatusStep(label: 'Reviewed by Staff', time: null,       done: false, active: true),
      _StatusStep(label: 'Printing',          time: null,       done: false),
      _StatusStep(label: 'Ready for Pickup',  time: null,       done: false),
    ],
  ),
  _IncomingRequest(
    id: 'REQ-2024-003',
    userName: 'Jose Reyes',
    userEmail: 'jose@email.com',
    fileName: 'gear_assembly.3mf',
    material: 'ABS – Black',
    printer: 'Prusa MK4',
    quantity: 5,
    grandTotal: 3200.75,
    status: ReceivedStatus.completed,
    submittedAt: DateTime.now().subtract(const Duration(days: 2)),
    timeline: [
      _StatusStep(label: 'Order Submitted',   time: 'Nov 10', done: true),
      _StatusStep(label: 'Reviewed by Staff', time: 'Nov 10', done: true),
      _StatusStep(label: 'Printing',          time: 'Nov 11', done: true),
      _StatusStep(label: 'Ready for Pickup',  time: 'Nov 12', done: true),
    ],
  ),
  _IncomingRequest(
    id: 'REQ-2024-004',
    userName: 'Maria Cruz',
    userEmail: 'maria@email.com',
    fileName: 'test_cube.stl',
    material: 'Resin – Clear',
    printer: 'Elegoo Mars 4',
    quantity: 1,
    grandTotal: 320.00,
    status: ReceivedStatus.cancelled,
    submittedAt: DateTime.now().subtract(const Duration(days: 5)),
    userNote: 'File was corrupted, cancelled on request.',
    timeline: [
      _StatusStep(label: 'Order Submitted', time: 'Nov 7', done: true),
      _StatusStep(label: 'Cancelled',       time: 'Nov 7', done: true),
    ],
  ),
];

// ── Main Screen ───────────────────────────────────────────────────────────────

class StaffReceivedScreen extends StatefulWidget {
  const StaffReceivedScreen({super.key});

  @override
  State<StaffReceivedScreen> createState() => _StaffReceivedScreenState();
}

class _StaffReceivedScreenState extends State<StaffReceivedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _expandedId;

  // Local mutable copy so staff can update statuses
  final List<_IncomingRequest> _requests = List.from(_sampleRequests);

  final List<ReceivedStatus?> _tabs = [
    null,
    ReceivedStatus.pending,
    ReceivedStatus.processing,
    ReceivedStatus.completed,
    ReceivedStatus.cancelled,
  ];

  final List<String> _tabLabels = [
    'All', 'Pending', 'Processing', 'Completed', 'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<_IncomingRequest> _filtered(ReceivedStatus? status) =>
      status == null ? _requests : _requests.where((r) => r.status == status).toList();

  void _updateStatus(_IncomingRequest req, ReceivedStatus newStatus) {
    setState(() {
      final i = _requests.indexWhere((r) => r.id == req.id);
      if (i != -1) _requests[i].status = newStatus;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${req.id} marked as ${newStatus.label}'),
        backgroundColor: newStatus.color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _cancelRequest(_IncomingRequest req) {
    setState(() {
      final i = _requests.indexWhere((r) => r.id == req.id);
      if (i != -1) _requests[i].status = ReceivedStatus.cancelled;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${req.id} has been cancelled.'),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Received Requests',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage and update incoming user orders.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Stats row
              Row(
                children: [
                  _StatBadge(
                    label: 'Pending',
                    count: _filtered(ReceivedStatus.pending).length,
                    color: const Color(0xFFF59E0B),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── Tab bar ───────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(30),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicator: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(30),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade500,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
              tabs: List.generate(_tabLabels.length, (i) {
                final count = _filtered(_tabs[i]).length;
                return Tab(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        Text(_tabLabels[i]),
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ── Tab content ───────────────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _tabs.map((status) {
              final requests = _filtered(status);
              if (requests.isEmpty) return _buildEmptyState();
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                itemCount: requests.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, i) => _RequestCard(
                  request: requests[i],
                  isExpanded: _expandedId == requests[i].id,
                  onToggle: () => setState(() {
                    _expandedId = _expandedId == requests[i].id ? null : requests[i].id;
                  }),
                  onUpdateStatus: (newStatus) => _updateStatus(requests[i], newStatus),
                  onCancel: () => _cancelRequest(requests[i]),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.direct_inbox, size: 40, color: Colors.teal),
          ),
          const SizedBox(height: 20),
          const Text(
            'No requests here',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1D23)),
          ),
          const SizedBox(height: 6),
          Text(
            'Incoming user requests will appear here.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

// ── Stat Badge ────────────────────────────────────────────────────────────────

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Center(
              child: Text(
                '$count',
                style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

// ── Request Card ──────────────────────────────────────────────────────────────

class _RequestCard extends StatefulWidget {
  const _RequestCard({
    required this.request,
    required this.isExpanded,
    required this.onToggle,
    required this.onUpdateStatus,
    required this.onCancel,
  });

  final _IncomingRequest request;
  final bool isExpanded;
  final VoidCallback onToggle;
  final ValueChanged<ReceivedStatus> onUpdateStatus;
  final VoidCallback onCancel;

  @override
  State<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<_RequestCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _rotate = Tween<double>(begin: 0, end: 0.5)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    if (widget.isExpanded) _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant _RequestCard old) {
    super.didUpdateWidget(old);
    widget.isExpanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.request;
    final status = req.status;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: widget.onToggle,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Row 1: ID + status ────────────────────────────
                  Row(
                    children: [
                      Text(
                        req.id,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.teal,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: status.bgColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: status.color.withOpacity(0.25)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(status.icon, size: 11, color: status.color),
                            const SizedBox(width: 4),
                            Text(
                              status.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: status.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ── Row 2: user info ──────────────────────────────
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.teal.withOpacity(0.1),
                        child: Text(
                          req.userName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.teal,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            req.userName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1D23),
                            ),
                          ),
                          Text(
                            req.userEmail,
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                      if (req.discountType != null) ...[
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.purple.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Iconsax.discount_shape,
                                  size: 10, color: Colors.purple.shade400),
                              const SizedBox(width: 4),
                              Text(
                                '${req.discountType} 10%',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.purple.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 14),
                  Divider(height: 1, color: Colors.grey.shade100),
                  const SizedBox(height: 14),

                  // ── Row 3: file + price ───────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // File icon with extension badge
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(Iconsax.document_text,
                                size: 26, color: Colors.teal),
                            Positioned(
                              bottom: 6,
                              right: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.teal,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  req.fileName.split('.').last.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 7,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              req.fileName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1D23),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(Iconsax.layer,
                                    size: 11, color: Colors.grey.shade500),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    req.material,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Icon(Iconsax.cpu,
                                    size: 11, color: Colors.grey.shade400),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    req.printer,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Price + qty
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₱${req.grandTotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'x${req.quantity}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ── Row 4: time + expand ──────────────────────────
                  Row(
                    children: [
                      Icon(Iconsax.clock, size: 11, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(req.submittedAt),
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade400),
                      ),
                      const Spacer(),
                      Text(
                        widget.isExpanded ? 'Hide details' : 'View details',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.teal,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      AnimatedBuilder(
                        animation: _rotate,
                        builder: (_, child) => Transform.rotate(
                          angle: _rotate.value * 3.14159,
                          child: child,
                        ),
                        child: const Icon(Iconsax.arrow_down_2,
                            size: 12, color: Colors.teal),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded section ──────────────────────────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            child: widget.isExpanded
                ? Column(
                    children: [
                      Divider(height: 1, color: Colors.grey.shade100),
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Timeline
                            _buildTimeline(req.timeline),

                            // User note
                            if (req.userNote != null) ...[
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: Colors.amber.shade200),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Iconsax.note_text,
                                        size: 15,
                                        color: Colors.amber.shade700),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'User Note',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.amber.shade700,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            req.userNote!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.amber.shade900,
                                              height: 1.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 20),

                            // Staff action buttons
                            _buildStaffActions(req),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(List<_StatusStep> steps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Iconsax.path, size: 13, color: Colors.grey.shade500),
            const SizedBox(width: 6),
            Text(
              'ORDER TIMELINE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade500,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...widget.request.timeline.asMap().entries.map((e) {
          final i = e.key;
          final step = e.value;
          final isLast = i == widget.request.timeline.length - 1;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: step.done
                          ? const Color(0xFF10B981)
                          : step.active
                              ? Colors.teal
                              : Colors.grey.shade200,
                      shape: BoxShape.circle,
                      boxShadow: step.active
                          ? [
                              BoxShadow(
                                color: Colors.teal.withOpacity(0.35),
                                blurRadius: 6,
                                spreadRadius: 1,
                              )
                            ]
                          : null,
                    ),
                    child: Icon(
                      step.done
                          ? Iconsax.tick_circle
                          : step.active
                              ? Iconsax.clock
                              : Iconsax.minus_cirlce,
                      size: 11,
                      color: step.done || step.active
                          ? Colors.white
                          : Colors.grey.shade400,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 30,
                      color: step.done
                          ? const Color(0xFF10B981).withOpacity(0.25)
                          : Colors.grey.shade200,
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          step.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: step.active || step.done
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: step.done
                                ? const Color(0xFF10B981)
                                : step.active
                                    ? Colors.teal
                                    : Colors.grey.shade400,
                          ),
                        ),
                      ),
                      if (step.time != null)
                        Text(
                          step.time!,
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade400),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildStaffActions(_IncomingRequest req) {
    final next = req.status.nextStatus;

    if (req.status == ReceivedStatus.completed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.tick_circle, size: 16, color: Color(0xFF10B981)),
            SizedBox(width: 8),
            Text(
              'Order completed — ready for pickup',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF10B981),
              ),
            ),
          ],
        ),
      );
    }

    if (req.status == ReceivedStatus.cancelled) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.close_circle, size: 16, color: Color(0xFFEF4444)),
            SizedBox(width: 8),
            Text(
              'This request has been cancelled',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // ── View Details button (pending only) ────────────────────
        if (req.status == ReceivedStatus.pending) ...[
          GestureDetector(
            onTap: () => _showDetailsSheet(req),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.withOpacity(0.2)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.eye, size: 14, color: Colors.teal),
                  SizedBox(width: 8),
                  Text(
                    'View Full Details',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],

        // ── Action buttons ────────────────────────────────────────
        Row(
          children: [
            // Cancel button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showCancelDialog(req),
                icon: Icon(Iconsax.close_circle,
                    size: 14, color: Colors.red.shade400),
                label: const Text('Cancel'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade400,
                  side: BorderSide(color: Colors.red.shade300),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Progress button
            if (next != null)
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () => widget.onUpdateStatus(next),
                  icon: Icon(req.status.nextIcon, size: 14),
                  label: Text(req.status.nextLabel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  void _showDetailsSheet(_IncomingRequest req) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Iconsax.document_text,
                          size: 18, color: Colors.teal),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          req.id,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1D23),
                          ),
                        ),
                        Text(
                          'Request Details',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Iconsax.close_circle,
                          color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ),

              Divider(color: Colors.grey.shade100),

              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // ── User info ───────────────────────────────
                    _DetailSection(
                      icon: Iconsax.user,
                      title: 'USER INFORMATION',
                      child: Column(
                        children: [
                          _DetailRow(label: 'Name',  value: req.userName),
                          _DetailRow(label: 'Email', value: req.userEmail),
                          if (req.discountType != null)
                            _DetailRow(
                              label: 'Discount',
                              value: '${req.discountType} – 10% off',
                              valueColor: Colors.purple.shade400,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── File info ───────────────────────────────
                    _DetailSection(
                      icon: Iconsax.document_upload,
                      title: 'FILE INFORMATION',
                      child: Column(
                        children: [
                          _DetailRow(label: 'File Name', value: req.fileName),
                          _DetailRow(label: 'Material',  value: req.material),
                          _DetailRow(label: 'Printer',   value: req.printer),
                          _DetailRow(
                              label: 'Quantity',
                              value: '${req.quantity} unit(s)'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Cost summary ─────────────────────────────
                    _DetailSection(
                      icon: Iconsax.calculator,
                      title: 'COST SUMMARY',
                      child: Column(
                        children: [
                          _DetailRow(
                            label: 'Grand Total',
                            value: '₱${req.grandTotal.toStringAsFixed(2)}',
                            valueColor: Colors.teal,
                            bold: true,
                          ),
                          if (req.discountType != null)
                            _DetailRow(
                              label: 'Discount Applied',
                              value: '${req.discountType} (10%)',
                              valueColor: Colors.green.shade600,
                            ),
                        ],
                      ),
                    ),

                    // ── User note ────────────────────────────────
                    if (req.userNote != null) ...[
                      const SizedBox(height: 16),
                      _DetailSection(
                        icon: Iconsax.note_text,
                        title: 'USER NOTE',
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: Text(
                            req.userNote!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.amber.shade900,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // ── Action buttons inside sheet ───────────────
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _showCancelDialog(req);
                            },
                            icon: Icon(Iconsax.close_circle,
                                size: 14, color: Colors.red.shade400),
                            label: const Text('Cancel Request'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red.shade400,
                              side: BorderSide(color: Colors.red.shade300),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              textStyle: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              widget.onUpdateStatus(ReceivedStatus.processing);
                            },
                            icon: const Icon(Iconsax.play, size: 14),
                            label: const Text('Start Processing'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              textStyle: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCancelDialog(_IncomingRequest req) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Cancel Request?',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: Text(
          'Are you sure you want to cancel ${req.id} for ${req.userName}? This cannot be undone.',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Keep', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onCancel();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Cancel Request',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ── Detail Section ────────────────────────────────────────────────────────────

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: Colors.grey.shade500),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade500,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ── Detail Row ────────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: valueColor ?? const Color(0xFF1A1D23),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
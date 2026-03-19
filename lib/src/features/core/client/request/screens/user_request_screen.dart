import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

// ── Status enum ───────────────────────────────────────────────────────────────

enum RequestStatus { pending, processing, completed, cancelled }

extension RequestStatusExt on RequestStatus {
  String get label {
    switch (this) {
      case RequestStatus.pending:    return 'Pending';
      case RequestStatus.processing: return 'Processing';
      case RequestStatus.completed:  return 'Completed';
      case RequestStatus.cancelled:  return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case RequestStatus.pending:    return const Color(0xFFF59E0B);
      case RequestStatus.processing: return const Color(0xFF3B82F6);
      case RequestStatus.completed:  return const Color(0xFF10B981);
      case RequestStatus.cancelled:  return const Color(0xFFEF4444);
    }
  }

  Color get bgColor {
    switch (this) {
      case RequestStatus.pending:    return const Color(0xFFFFF8E1);
      case RequestStatus.processing: return const Color(0xFFEFF6FF);
      case RequestStatus.completed:  return const Color(0xFFF0FDF4);
      case RequestStatus.cancelled:  return const Color(0xFFFEF2F2);
    }
  }

  IconData get icon {
    switch (this) {
      case RequestStatus.pending:    return Iconsax.clock;
      case RequestStatus.processing: return Iconsax.setting_2;
      case RequestStatus.completed:  return Iconsax.tick_circle;
      case RequestStatus.cancelled:  return Iconsax.close_circle;
    }
  }
}

// ── Data models ───────────────────────────────────────────────────────────────

class _RequestOrder {
  final String id;
  final String fileName;
  final String material;
  final String printer;
  final int quantity;
  final double grandTotal;
  final RequestStatus status;
  final DateTime submittedAt;
  final String? note;
  final List<_StatusStep> timeline;

  const _RequestOrder({
    required this.id,
    required this.fileName,
    required this.material,
    required this.printer,
    required this.quantity,
    required this.grandTotal,
    required this.status,
    required this.submittedAt,
    this.note,
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

// ── Sample orders ─────────────────────────────────────────────────────────────

final List<_RequestOrder> _sampleOrders = [
  _RequestOrder(
    id: 'REQ-2024-001',
    fileName: 'bracket_v2.stl',
    material: 'PLA Standard – White',
    printer: 'Creality Ender 3',
    quantity: 2,
    grandTotal: 1240.50,
    status: RequestStatus.processing,
    submittedAt: DateTime.now().subtract(const Duration(hours: 3)),
    note: 'Please make sure the layer height is 0.2mm.',
    timeline: [
      _StatusStep(label: 'Order Submitted',   time: '9:00 AM',  done: true),
      _StatusStep(label: 'Reviewed by Staff', time: '9:45 AM',  done: true),
      _StatusStep(label: 'Printing',          time: '10:00 AM', done: false, active: true),
      _StatusStep(label: 'Ready for Pickup',  time: null,       done: false),
    ],
  ),
  _RequestOrder(
    id: 'REQ-2024-002',
    fileName: 'phone_stand.obj',
    material: 'PETG – Transparent',
    printer: 'Bambu Lab X1C',
    quantity: 1,
    grandTotal: 580.00,
    status: RequestStatus.pending,
    submittedAt: DateTime.now().subtract(const Duration(minutes: 30)),
    timeline: [
      _StatusStep(label: 'Order Submitted',   time: '11:30 AM', done: true),
      _StatusStep(label: 'Reviewed by Staff', time: null,       done: false, active: true),
      _StatusStep(label: 'Printing',          time: null,       done: false),
      _StatusStep(label: 'Ready for Pickup',  time: null,       done: false),
    ],
  ),
  _RequestOrder(
    id: 'REQ-2024-003',
    fileName: 'gear_assembly.3mf',
    material: 'ABS – Black',
    printer: 'Prusa MK4',
    quantity: 5,
    grandTotal: 3200.75,
    status: RequestStatus.completed,
    submittedAt: DateTime.now().subtract(const Duration(days: 2)),
    timeline: [
      _StatusStep(label: 'Order Submitted',   time: 'Nov 10', done: true),
      _StatusStep(label: 'Reviewed by Staff', time: 'Nov 10', done: true),
      _StatusStep(label: 'Printing',          time: 'Nov 11', done: true),
      _StatusStep(label: 'Ready for Pickup',  time: 'Nov 12', done: true),
    ],
  ),
  _RequestOrder(
    id: 'REQ-2024-004',
    fileName: 'test_cube.stl',
    material: 'Resin – Clear',
    printer: 'Elegoo Mars 4',
    quantity: 1,
    grandTotal: 320.00,
    status: RequestStatus.cancelled,
    submittedAt: DateTime.now().subtract(const Duration(days: 5)),
    note: 'File was corrupted, cancelled on request.',
    timeline: [
      _StatusStep(label: 'Order Submitted', time: 'Nov 7', done: true),
      _StatusStep(label: 'Cancelled',       time: 'Nov 7', done: true),
    ],
  ),
];

// ── Main Screen ───────────────────────────────────────────────────────────────

class UserRequestScreen extends StatefulWidget {
  const UserRequestScreen({super.key});

  @override
  State<UserRequestScreen> createState() => _UserRequestScreenState();
}

class _UserRequestScreenState extends State<UserRequestScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _expandedOrderId;

  final List<RequestStatus?> _tabs = [
    null,
    RequestStatus.pending,
    RequestStatus.processing,
    RequestStatus.completed,
    RequestStatus.cancelled,
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

  List<_RequestOrder> _filteredOrders(RequestStatus? status) =>
      status == null ? _sampleOrders : _sampleOrders.where((o) => o.status == status).toList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Clean flat header ─────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Requests',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track and manage your 3D print orders.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5C6BC0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Iconsax.box, size: 14, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      '${_sampleOrders.length} Orders',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
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
                color: const Color(0xFF5C6BC0),
                borderRadius: BorderRadius.circular(30),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade500,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
              tabs: List.generate(_tabLabels.length, (i) {
                final count = _filteredOrders(_tabs[i]).length;
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
              final orders = _filteredOrders(status);
              if (orders.isEmpty) return _buildEmptyState();
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                itemCount: orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, i) => _OrderCard(
                  order: orders[i],
                  isExpanded: _expandedOrderId == orders[i].id,
                  onToggle: () => setState(() {
                    _expandedOrderId =
                        _expandedOrderId == orders[i].id ? null : orders[i].id;
                  }),
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
              color: const Color(0xFF5C6BC0).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.box, size: 40, color: Color(0xFF5C6BC0)),
          ),
          const SizedBox(height: 20),
          const Text(
            'No orders here',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1D23)),
          ),
          const SizedBox(height: 6),
          Text(
            'Submit a quote to see your orders.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

// ── Order Card ────────────────────────────────────────────────────────────────

class _OrderCard extends StatefulWidget {
  const _OrderCard({
    required this.order,
    required this.isExpanded,
    required this.onToggle,
  });

  final _RequestOrder order;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _rotate = Tween<double>(begin: 0, end: 0.5).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    if (widget.isExpanded) _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant _OrderCard old) {
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
    final order = widget.order;
    final status = order.status;

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
            borderRadius: BorderRadius.circular(20), // Now covers entire card
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Row 1: ID + status badge ──────────────────────
                  Row(
                    children: [
                      Text(
                        order.id,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF5C6BC0),
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

                  // ── Row 2: file icon + details + price ───────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // File type icon box
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: const Color(0xFF5C6BC0).withOpacity(0.06),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(Iconsax.document_text,
                                size: 26, color: Color(0xFF5C6BC0)),
                            Positioned(
                              bottom: 6,
                              right: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF5C6BC0),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  order.fileName.split('.').last.toUpperCase(),
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

                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.fileName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1D23),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(Iconsax.layer, size: 11, color: Colors.grey.shade500),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    order.material,
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Icon(Iconsax.cpu, size: 11, color: Colors.grey.shade400),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    order.printer,
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
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
                            '₱${order.grandTotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF5C6BC0),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'x${order.quantity}',
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

                  // ── Row 3: date + expand hint ────────────────────
                  Row(
                    children: [
                      Icon(Iconsax.clock, size: 11, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(order.submittedAt),
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                      ),
                      const Spacer(),
                      Text(
                        widget.isExpanded ? 'Hide details' : 'View details',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF5C6BC0),
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
                            size: 12, color: Color(0xFF5C6BC0)),
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
                            _buildTimeline(order.timeline),
                            if (order.note != null) ...[
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.amber.shade200),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Iconsax.note_text, size: 15, color: Colors.amber.shade700),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        order.note!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.amber.shade900,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                            _buildActionRow(order),
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
        ...steps.asMap().entries.map((e) {
          final i = e.key;
          final step = e.value;
          final isLast = i == steps.length - 1;

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
                              ? const Color(0xFF5C6BC0)
                              : Colors.grey.shade200,
                      shape: BoxShape.circle,
                      boxShadow: step.active
                          ? [BoxShadow(
                              color: const Color(0xFF5C6BC0).withOpacity(0.35),
                              blurRadius: 6, spreadRadius: 1)]
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
                                    ? const Color(0xFF5C6BC0)
                                    : Colors.grey.shade400,
                          ),
                        ),
                      ),
                      if (step.time != null)
                        Text(
                          step.time!,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
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

  Widget _buildActionRow(_RequestOrder order) {
    if (order.status == RequestStatus.completed) {
      return Row(children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Iconsax.document_download, size: 14),
            label: const Text('Receipt'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF5C6BC0),
              side: const BorderSide(color: Color(0xFF5C6BC0)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Iconsax.refresh, size: 14),
            label: const Text('Reorder'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5C6BC0),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
        ),
      ]);
    }

    if (order.status == RequestStatus.pending) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {},
          icon: Icon(Iconsax.close_circle, size: 14, color: Colors.red.shade400),
          label: const Text('Cancel Request'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red.shade400,
            side: BorderSide(color: Colors.red.shade300),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 12),
            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ),
      );
    }

    if (order.status == RequestStatus.processing) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.setting_2, size: 14, color: Color(0xFF3B82F6)),
            SizedBox(width: 8),
            Text(
              'Printing in progress...',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF3B82F6)),
            ),
          ],
        ),
      );
    }

    if (order.status == RequestStatus.cancelled) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Iconsax.refresh, size: 14),
          label: const Text('Resubmit'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5C6BC0),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 12),
            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
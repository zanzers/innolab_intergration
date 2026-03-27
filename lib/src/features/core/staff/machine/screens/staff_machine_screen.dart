import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Design tokens
// ─────────────────────────────────────────────────────────────────────────────

const _kAccent    = Color(0xFF0D9488);
const _kAccentDark = Color(0xFF0F766E);
const _kText      = Color(0xFF1A1D23);
const _kSubtext   = Color(0xFF6B7280);
const _kBorder    = Color(0xFFE5E7EB);
const _kSurface   = Color(0xFFF3F4F6);

// ─────────────────────────────────────────────────────────────────────────────
// Machine models
// ─────────────────────────────────────────────────────────────────────────────

enum MachineStatus { available, inUse, maintenance }

extension MachineStatusExt on MachineStatus {
  String get label {
    switch (this) {
      case MachineStatus.available:   return 'Available';
      case MachineStatus.inUse:       return 'In Use';
      case MachineStatus.maintenance: return 'Maintenance';
    }
  }

  Color get dotColor {
    switch (this) {
      case MachineStatus.available:   return const Color(0xFF22C55E);
      case MachineStatus.inUse:       return const Color(0xFF3B82F6);
      case MachineStatus.maintenance: return const Color(0xFFF59E0B);
    }
  }

  Color get chipBg => dotColor.withValues(alpha: 0.12);
}

class _Machine {
  final String id;
  final String brand;
  final String model;
  final String type;
  final String buildSize;
  final List<String> materials;
  MachineStatus status;
  String? currentUser;
  DateTime? sessionStart;
  bool isMySession;

  _Machine({
    required this.id,
    required this.brand,
    required this.model,
    required this.type,
    required this.buildSize,
    required this.materials,
    this.status = MachineStatus.available,
    this.currentUser,
    this.sessionStart,
    this.isMySession = false,
  });
}

(IconData icon, Color bg, Color fg) _avatarForMachine(_Machine m) {
  final t = m.type.toLowerCase();
  if (t.contains('scanner')) {
    return (Iconsax.scan, const Color(0xFFE0F2FE), const Color(0xFF0369A1));
  }
  if (t.contains('wash') || t.contains('cure')) {
    return (Iconsax.drop, const Color(0xFFFEF9C3), const Color(0xFFCA8A04));
  }
  if (t.contains('msla') || t.contains('vat') || t.contains('polymerization')) {
    return (Iconsax.box, const Color(0xFFEDE9FE), const Color(0xFF7C3AED));
  }
  return (Iconsax.cpu, const Color(0xFFCCFBF1), _kAccentDark);
}

// ─────────────────────────────────────────────────────────────────────────────
// Sample data
// ─────────────────────────────────────────────────────────────────────────────

const String _staffName = 'Staff Name';

final List<_Machine> _machines = [
  _Machine(
    id: 'M-001', brand: 'Creality', model: 'Ender-3 V3 SE',
    type: 'Material Extrusion (FDM)', buildSize: '220 × 220 × 250 mm',
    materials: ['PLA', 'PETG', 'TPU', 'PA', 'ABS'],
    status: MachineStatus.inUse, currentUser: 'Juan Dela Cruz',
    sessionStart: DateTime.now().subtract(const Duration(hours: 1, minutes: 22)),
  ),
  _Machine(
    id: 'M-002', brand: 'Elegoo', model: 'Saturn 3 Ultra',
    type: 'VAT Polymerization (MSLA)', buildSize: '218.88 × 122.88 × 260 mm',
    materials: ['Standard Resin', 'ABE Substitute', 'PE Substitute', 'Flexible Resin', 'Casting Resin', 'Draft Resin'],
  ),
  _Machine(
    id: 'M-003', brand: 'Anycubic', model: 'Wash and Cure 3 Plus',
    type: 'Wash and Cure Station', buildSize: '260 × 228 × 128 mm',
    materials: ['Post-processing for Resin prints'],
    status: MachineStatus.maintenance,
  ),
  _Machine(
    id: 'M-004', brand: 'Bambu Labs', model: 'X1 Carbon',
    type: 'Material Extrusion (FDM)', buildSize: '256 × 256 × 256 mm',
    materials: ['PLA', 'PETG', 'TPU', 'ABS', 'PVA', 'PET', 'PC', 'Carbon/Glass Fiber'],
  ),
  _Machine(
    id: 'M-005', brand: 'Shining 3D', model: 'Einstar',
    type: '3D Scanner', buildSize: '220 × 46 × 55 mm',
    materials: ['High-quality Data', 'High Color Fidelity', 'Detail Enhancement Technology', 'Stable Outdoor Scanning'],
  ),
];

const List<String> _machineTypes = [
  'Material Extrusion (FDM)',
  'VAT Polymerization (MSLA)',
  'Wash and Cure Station',
  '3D Scanner',
  'Other',
];

// ─────────────────────────────────────────────────────────────────────────────
// Main Screen
// ─────────────────────────────────────────────────────────────────────────────

class StaffMachineScreen extends StatefulWidget {
  const StaffMachineScreen({super.key});

  @override
  State<StaffMachineScreen> createState() => _StaffMachineScreenState();
}

class _StaffMachineScreenState extends State<StaffMachineScreen> {
  final List<_Machine> _machineList = List.from(_machines);

  // ── Session helpers ─────────────────────────────────────────────────────────

  void _startSession(_Machine m) {
    setState(() {
      m.status       = MachineStatus.inUse;
      m.currentUser  = _staffName;
      m.sessionStart = DateTime.now();
      m.isMySession  = true;
    });
    _snack('Session started on ${m.model}', _kAccentDark);
  }

  void _endSession(_Machine m) {
    setState(() {
      m.status       = MachineStatus.available;
      m.currentUser  = null;
      m.sessionStart = null;
      m.isMySession  = false;
    });
    _snack('Session ended for ${m.model}', _kSubtext);
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ── Add Machine sheet ───────────────────────────────────────────────────────

  void _showAddMachineSheet() {
    final brandCtrl    = TextEditingController();
    final modelCtrl    = TextEditingController();
    final buildCtrl    = TextEditingController();
    final materialCtrl = TextEditingController();
    String selectedType     = _machineTypes.first;
    final List<String> mats = [];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          void addMaterial() {
            final v = materialCtrl.text.trim();
            if (v.isNotEmpty) setLocal(() { mats.add(v); materialCtrl.clear(); });
          }

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle
                    Center(
                      child: Container(width: 40, height: 4,
                        decoration: BoxDecoration(color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2))),
                    ),
                    const SizedBox(height: 20),

                    // Title row
                    Row(children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: const Color(0xFFCCFBF1),
                            borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Iconsax.cpu, size: 20, color: _kAccentDark),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Add Machine', style: TextStyle(fontSize: 17,
                              fontWeight: FontWeight.w800, color: _kText)),
                          Text('Register new equipment', style: TextStyle(
                              fontSize: 12, color: _kSubtext)),
                        ],
                      ),
                    ]),
                    const SizedBox(height: 24),

                    // Brand
                    _SheetLabel('Brand'),
                    const SizedBox(height: 6),
                    _SheetTextField(controller: brandCtrl, hint: 'e.g. Creality'),
                    const SizedBox(height: 14),

                    // Model
                    _SheetLabel('Model'),
                    const SizedBox(height: 6),
                    _SheetTextField(controller: modelCtrl, hint: 'e.g. Ender-3 V3 SE'),
                    const SizedBox(height: 14),

                    // Type
                    _SheetLabel('Technology Type'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      isExpanded: true,
                      decoration: _sheetInputDeco(''),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _kText),
                      items: _machineTypes.map((t) =>
                          DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (v) => setLocal(() => selectedType = v!),
                    ),
                    const SizedBox(height: 14),

                    // Build size
                    _SheetLabel('Build Volume'),
                    const SizedBox(height: 6),
                    _SheetTextField(controller: buildCtrl, hint: 'e.g. 220 × 220 × 250 mm'),
                    const SizedBox(height: 14),

                    // Materials
                    _SheetLabel('Supported Materials'),
                    const SizedBox(height: 6),
                    Row(children: [
                      Expanded(
                        child: TextField(
                          controller: materialCtrl,
                          onSubmitted: (_) => addMaterial(),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                          decoration: _sheetInputDeco('e.g. PLA, PETG…'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: addMaterial,
                        child: Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(color: _kAccent,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                        ),
                      ),
                    ]),
                    if (mats.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6, runSpacing: 6,
                        children: mats.map((mat) => _RemovableChip(
                          label: mat,
                          color: _kAccent,
                          onRemove: () => setLocal(() => mats.remove(mat)),
                        )).toList(),
                      ),
                    ],
                    const SizedBox(height: 28),

                    // Submit
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          if (brandCtrl.text.trim().isEmpty || modelCtrl.text.trim().isEmpty) {
                            _snack('Brand and Model are required', Colors.red.shade400);
                            return;
                          }
                          final newId = 'M-${(_machineList.length + 1).toString().padLeft(3, '0')}';
                          final m = _Machine(
                            id: newId,
                            brand: brandCtrl.text.trim(),
                            model: modelCtrl.text.trim(),
                            type: selectedType,
                            buildSize: buildCtrl.text.trim().isEmpty ? 'N/A' : buildCtrl.text.trim(),
                            materials: mats.isEmpty ? ['N/A'] : List.from(mats),
                          );
                          setState(() => _machineList.add(m));
                          Navigator.pop(ctx);
                          _snack('${m.model} added successfully', _kAccentDark);
                        },
                        icon: const Icon(Iconsax.add, size: 18),
                        label: const Text('Add Machine'),
                        style: FilledButton.styleFrom(
                          backgroundColor: _kAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Detail sheet ────────────────────────────────────────────────────────────

  void _showDetail(_Machine m) {
    final canUse = m.status == MachineStatus.available;
    final isMine = m.isMySession;
    final (avIcon, avBg, avFg) = _avatarForMachine(m);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.62,
        minChildSize: 0.42,
        maxChildSize: 0.92,
        builder: (_, scroll) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 24, offset: Offset(0, -4))],
          ),
          child: Column(children: [
            const SizedBox(height: 10),
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)))),
            Expanded(child: ListView(
              controller: scroll,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(color: avBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: avFg.withValues(alpha: 0.15))),
                    child: Icon(avIcon, size: 28, color: avFg),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(m.brand.toUpperCase(), style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w700,
                        letterSpacing: 1.1, color: Colors.grey.shade500)),
                    const SizedBox(height: 2),
                    Text(m.model, style: const TextStyle(fontSize: 20,
                        fontWeight: FontWeight.w800, color: _kText, letterSpacing: -0.4)),
                    const SizedBox(height: 4),
                    Text(m.type, style: TextStyle(fontSize: 13, height: 1.35, color: Colors.grey.shade600)),
                  ])),
                  _StatusPill(m.status),
                ]),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: _kSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _kBorder)),
                  child: Column(children: [
                    _DetailRow(icon: Iconsax.maximize_3, label: 'Build volume', value: m.buildSize),
                    Padding(padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1, color: Colors.grey.shade200)),
                    _DetailRow(icon: Iconsax.cpu, label: 'Technology', value: m.type),
                  ]),
                ),
                if (m.status == MachineStatus.inUse && m.currentUser != null) ...[
                  const SizedBox(height: 20),
                  Text('CURRENT SESSION', style: TextStyle(fontSize: 10,
                      fontWeight: FontWeight.w800, color: Colors.grey.shade500, letterSpacing: 0.9)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        const Color(0xFF3B82F6).withValues(alpha: 0.08),
                        const Color(0xFF6366F1).withValues(alpha: 0.06),
                      ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.2)),
                    ),
                    child: Column(children: [
                      _DetailRow(icon: Iconsax.user, label: 'Operator', value: m.currentUser!),
                      if (m.sessionStart != null) ...[
                        const SizedBox(height: 12),
                        _DetailRow(icon: Iconsax.clock, label: 'Started', value: _fmtTime(m.sessionStart!)),
                        const SizedBox(height: 12),
                        _DetailRow(icon: Iconsax.timer_1, label: 'Elapsed', value: _elapsed(m.sessionStart!)),
                      ],
                    ]),
                  ),
                ],
                const SizedBox(height: 22),
                Text('SUPPORTED MATERIALS', style: TextStyle(fontSize: 10,
                    fontWeight: FontWeight.w800, color: Colors.grey.shade500, letterSpacing: 0.9)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: m.materials.map((mat) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _kBorder)),
                    child: Text(mat, style: const TextStyle(fontSize: 12,
                        fontWeight: FontWeight.w600, color: _kText)),
                  )).toList(),
                ),
                const SizedBox(height: 28),
                if (m.status == MachineStatus.maintenance)
                  _InfoBar(icon: Iconsax.warning_2,
                      label: 'This machine is under maintenance.',
                      color: const Color(0xFFF59E0B))
                else
                  FilledButton.icon(
                    onPressed: (canUse || isMine) ? () {
                      Navigator.pop(sheetContext);
                      if (canUse) _startSession(m); else _endSession(m);
                    } : null,
                    icon: Icon(canUse ? Iconsax.play : isMine ? Iconsax.stop_circle : Iconsax.lock, size: 18),
                    label: Text(canUse ? 'Start session' : isMine ? 'End session' : 'In use by others'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _kAccent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade200,
                      disabledForegroundColor: Colors.grey.shade500,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ),
              ],
            )),
          ]),
        ),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final available = _machineList.where((m) => m.status == MachineStatus.available).length;
    final inUse     = _machineList.where((m) => m.status == MachineStatus.inUse).length;
    final maint     = _machineList.where((m) => m.status == MachineStatus.maintenance).length;

    return Stack(
      children: [
        CustomScrollView(slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Equipment',
                    style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800, color: _kText, letterSpacing: -0.4)),
                const SizedBox(height: 6),
                Text('Check availability, start sessions, and open details.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade500, height: 1.4)),
                const SizedBox(height: 20),
                Row(children: [
                  _StatChip(label: 'Available', value: '$available',
                      color: const Color(0xFF22C55E), icon: Iconsax.tick_circle),
                  const SizedBox(width: 10),
                  _StatChip(label: 'In use', value: '$inUse',
                      color: const Color(0xFF3B82F6), icon: Iconsax.cpu),
                  const SizedBox(width: 10),
                  _StatChip(label: 'Service', value: '$maint',
                      color: const Color(0xFFF59E0B), icon: Iconsax.setting_3),
                ]),
                const SizedBox(height: 22),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  if (i.isOdd) return const SizedBox(height: 12);
                  final m = _machineList[i ~/ 2];
                  return _MachineCard(
                    machine: m,
                    onOpenDetail: () => _showDetail(m),
                    onPrimaryAction: () {
                      if (m.status == MachineStatus.available) _startSession(m);
                      else if (m.isMySession) _endSession(m);
                    },
                    elapsed: m.sessionStart != null ? _elapsed(m.sessionStart!) : null,
                  );
                },
                childCount: _machineList.length * 2 - 1,
              ),
            ),
          ),
        ]),
        // FAB — bottom right
        Positioned(
          bottom: 28,
          right: 28,
          child: GestureDetector(
            onTap: _showAddMachineSheet,
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 22),
              decoration: BoxDecoration(
                color: _kAccent,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _kAccent.withValues(alpha: 0.45),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Iconsax.add, color: Colors.white, size: 22),
                  SizedBox(width: 10),
                  Text('Add Machine',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _fmtTime(DateTime dt) {
    final h   = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
    final min = dt.minute.toString().padLeft(2, '0');
    return '$h:$min ${dt.hour >= 12 ? 'PM' : 'AM'}';
  }

  String _elapsed(DateTime start) {
    final d = DateTime.now().difference(start);
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
    return '${d.inMinutes}m';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Machine card (unchanged)
// ─────────────────────────────────────────────────────────────────────────────

class _MachineCard extends StatelessWidget {
  const _MachineCard({
    required this.machine,
    required this.onOpenDetail,
    required this.onPrimaryAction,
    this.elapsed,
  });

  final _Machine machine;
  final VoidCallback onOpenDetail;
  final VoidCallback onPrimaryAction;
  final String? elapsed;

  @override
  Widget build(BuildContext context) {
    final m      = machine;
    final canUse = m.status == MachineStatus.available;
    final isMine = m.isMySession;
    final isMaint = m.status == MachineStatus.maintenance;
    final (avIcon, avBg, avFg) = _avatarForMachine(m);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpenDetail,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade100, width: 1.5),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(color: avBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: avFg.withValues(alpha: 0.12))),
                  child: Icon(avIcon, size: 26, color: avFg),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: _kSurface, borderRadius: BorderRadius.circular(8)),
                      child: Text(m.id, style: const TextStyle(fontSize: 11,
                          fontWeight: FontWeight.w800, color: _kSubtext, letterSpacing: 0.3)),
                    ),
                    const Spacer(),
                    _StatusPill(m.status),
                  ]),
                  const SizedBox(height: 8),
                  Text(m.brand, style: TextStyle(fontSize: 11,
                      fontWeight: FontWeight.w600, color: Colors.grey.shade500)),
                  const SizedBox(height: 2),
                  Text(m.model, style: const TextStyle(fontSize: 16,
                      fontWeight: FontWeight.w800, color: _kText, letterSpacing: -0.3)),
                  const SizedBox(height: 4),
                  Text(m.buildSize, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ])),
              ]),
            ),
            if (m.status == MachineStatus.inUse && m.currentUser != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.15)),
                  ),
                  child: Row(children: [
                    Icon(Iconsax.user, size: 16, color: Colors.blue.shade700),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(m.currentUser!, style: TextStyle(fontSize: 13,
                          fontWeight: FontWeight.w700, color: Colors.blue.shade900)),
                      if (elapsed != null)
                        Text('Running · $elapsed',
                            style: TextStyle(fontSize: 11, color: Colors.blue.shade700)),
                    ])),
                    Icon(Iconsax.arrow_right_3, size: 16, color: Colors.blue.shade400),
                  ]),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: isMaint
                  ? _InfoBar(icon: Iconsax.warning_2,
                      label: 'Scheduled maintenance', color: const Color(0xFFF59E0B))
                  : Row(children: [
                      Expanded(child: OutlinedButton(
                        onPressed: onOpenDetail,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _kSubtext,
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Details', style: TextStyle(fontWeight: FontWeight.w600)),
                      )),
                      const SizedBox(width: 10),
                      Expanded(flex: 2, child: FilledButton(
                        onPressed: (canUse || isMine) ? onPrimaryAction : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: canUse || isMine ? _kAccent : Colors.grey.shade300,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade200,
                          disabledForegroundColor: Colors.grey.shade500,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(canUse ? Iconsax.play : isMine ? Iconsax.stop_circle : Iconsax.lock, size: 16),
                          const SizedBox(width: 8),
                          Text(canUse ? 'Use machine' : isMine ? 'End session' : 'Unavailable',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        ]),
                      )),
                    ]),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared form helpers
// ─────────────────────────────────────────────────────────────────────────────

InputDecoration _sheetInputDeco(String hint) => InputDecoration(
  hintText: hint,
  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
  filled: true,
  fillColor: const Color(0xFFF9FAFB),
  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade200)),
  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade200)),
  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _kAccent, width: 1.5)),
);

class _SheetLabel extends StatelessWidget {
  const _SheetLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
          color: _kSubtext, letterSpacing: 0.2));
}

class _SheetTextField extends StatelessWidget {
  const _SheetTextField({required this.controller, required this.hint,
      this.keyboardType});
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _kText),
    decoration: _sheetInputDeco(hint),
  );
}

class _RemovableChip extends StatelessWidget {
  const _RemovableChip({required this.label, required this.color, required this.onRemove});
  final String label;
  final Color color;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.only(left: 10, right: 4, top: 6, bottom: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.2)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      const SizedBox(width: 4),
      GestureDetector(
        onTap: onRemove,
        child: Icon(Icons.close_rounded, size: 15, color: color.withValues(alpha: 0.7)),
      ),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Existing helper widgets (unchanged)
// ─────────────────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value,
      required this.color, required this.icon});
  final String label, value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100, width: 1.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color, height: 1)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey.shade500)),
      ]),
    ),
  );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill(this.status);
  final MachineStatus status;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: status.chipBg, borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 7, height: 7,
          decoration: BoxDecoration(color: status.dotColor, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(status.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: status.dotColor)),
    ]),
  );
}

class _InfoBar extends StatelessWidget {
  const _InfoBar({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
    decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.22))),
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 8),
      Flexible(child: Text(label, textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color))),
    ]),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label, value;

  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, size: 18, color: Colors.grey.shade400),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
          letterSpacing: 0.6, color: Colors.grey.shade500)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
          color: _kText, height: 1.35)),
    ])),
  ]);
}
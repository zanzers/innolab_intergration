import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:innolab/src/features/core/controller/profileController/profile_controller.dart';

class UserHomeTab extends StatelessWidget {
  const UserHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light grey background
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 32 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            
            _WelcomeBanner(isDesktop: isDesktop),
            const SizedBox(height: 24),

            // ── Summary Cards ────────────────────────────────────────
            isDesktop
                ? Row(
                    children: _summaryCards()
                        .map((c) => Expanded(
                            child: Padding(
                                padding: const EdgeInsets.only(right: 14),
                                child: c)))
                        .toList(),
                  )
                : GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.2,
                    children: _summaryCards(),
                  ),
            const SizedBox(height: 32),

            // ── Services Offered ─────────────────────────────────────
            _ServicesSection(isDesktop: isDesktop),
            const SizedBox(height: 32),

            // ── Schedule & Equipment Split View ──────────────────────
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 1, child: _ScheduleSection(isDesktop: true)),
                  const SizedBox(width: 32),
                  Expanded(flex: 1, child: _EquipmentStatusSection()),
                ],
              )
            else ...[
              _ScheduleSection(isDesktop: false),
              const SizedBox(height: 32),
              _EquipmentStatusSection(),
            ],

            const SizedBox(height: 32),

            // ── Location ─────────────────────────────────────────────
            _LocationSection(),
          ],
        ),
      ),
    );
  }

  List<Widget> _summaryCards() => [
        const _SummaryCard(
            icon: Icons.description_outlined,
            label: 'Quotes',
            value: '0',
            color: Color(0xFF5C6BC0)),
        const _SummaryCard(
            icon: Icons.receipt_long_outlined,
            label: 'Receipts',
            value: '0',
            color: Color(0xFF42A5F5)),
        const _SummaryCard(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Messages',
            value: '0',
            color: Color(0xFFAB47BC)),
        const _SummaryCard(
            icon: Icons.calendar_today_outlined,
            label: 'Schedules',
            value: '0',
            color: Color(0xFFFFA726)),
      ];
}

// ─────────────────────────────────────────────────────────────────────────────
// WELCOME BANNER
// ─────────────────────────────────────────────────────────────────────────────
class _WelcomeBanner extends StatelessWidget {
  final bool isDesktop;
  const _WelcomeBanner({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 32 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6554C0), Color(0xFF8B78E6)], // Purple gradient
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6554C0).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'DOST • AMCen',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(() {
                      final profile = Get.find<ProfileController>();
                      final name =
                          profile.user?.fullName.trim() ?? '';
                      final welcome = name.isEmpty
                          ? 'Welcome back 👋'
                          : 'Welcome back, $name 👋';
                      return Text(
                        welcome,
                        style: TextStyle(
                          fontSize: isDesktop ? 28 : 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    Text(
                      'Advanced Manufacturing Center — Your hub for 3D printing, CNC machining, and prototyping services.',
                      style: TextStyle(
                        fontSize: isDesktop ? 15 : 13,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (isDesktop) const SizedBox(width: 24),
              if (isDesktop)
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.bolt_rounded, size: 18),
                      label: const Text('Request Service'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF6554C0),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Get Quote'),
                    ),
                  ],
                ),
            ],
          ),
          if (!isDesktop) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.bolt_rounded, size: 18),
                    label: const Text('Request Service'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF6554C0),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Get Quote'),
                  ),
                ),
              ],
            )
          ]
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUMMARY CARD
// ─────────────────────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SERVICES SECTION
// ─────────────────────────────────────────────────────────────────────────────
class _ServicesSection extends StatelessWidget {
  final bool isDesktop;
  const _ServicesSection({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final services = [
      const _ServiceData(
          icon: Icons.view_in_ar_rounded,
          title: '3D Modeling',
          subtitle: 'CAD design & prototyping',
          color: Color(0xFF1E88E5)), // Blue
      const _ServiceData(
          icon: Icons.print_rounded,
          title: '3D Printing',
          subtitle: 'FDM & SLA printing',
          color: Color(0xFF8E24AA)), // Purple
      const _ServiceData(
          icon: Icons.precision_manufacturing_rounded,
          title: 'CNC',
          subtitle: 'Precision machining',
          color: Color(0xFF00897B)), // Teal/Green
      const _ServiceData(
          icon: Icons.water_drop_rounded,
          title: 'Resin Printing',
          subtitle: 'High-detail resin prints',
          color: Color(0xFFFF8F00)), // Orange
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Services Offered',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Select a service to get started',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: isDesktop ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isDesktop ? 2.0 : 1.3,
          children: services.map((s) => _ServiceCard(data: s)).toList(),
        ),
      ],
    );
  }
}

class _ServiceData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  const _ServiceData(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.color});
}

class _ServiceCard extends StatelessWidget {
  final _ServiceData data;
  const _ServiceCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 6,
              color: data.color,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: data.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(data.icon, size: 24, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SCHEDULE SECTION (Left Column)
// ─────────────────────────────────────────────────────────────────────────────
class _ScheduleSection extends StatelessWidget {
  final bool isDesktop;
  const _ScheduleSection({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Schedule Now',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Book a session for technical support or training',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Card + Button Stack
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _ScheduleCard(
                    icon: Icons.build_outlined,
                    title: 'Technical Support',
                    description:
                        'Get expert assistance with 3D modeling, 3D printing troubleshooting, or Arduino development projects.',
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.calendar_month_outlined, size: 18),
                    label: const Text('Schedule Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5C6BC0), // Indigo button
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Right Card
            const Expanded(
              child: _ScheduleCard(
                icon: Icons.school_outlined,
                title: 'Training',
                description:
                    'Hands-on training sessions in 3D design, Arduino programming, and resin printing techniques.',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _ScheduleCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 160, // Fixed height to ensure alignment
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEEFA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: const Color(0xFF5C6BC0)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EQUIPMENT STATUS (Right Column)
// ─────────────────────────────────────────────────────────────────────────────
class _EquipmentStatusSection extends StatelessWidget {
  final List<_EquipmentData> _equipment = const [
    _EquipmentData(
        name: '3D Printer #1', status: 'Available', type: '3d Printer'),
    _EquipmentData(
        name: 'Resin Printer', status: 'Available', type: 'Resin Printer'),
    _EquipmentData(
        name: '3D Printer #2', status: 'In Use', type: '3d Printer'),
    _EquipmentData(
        name: 'CNC Router', status: 'Maintenance', type: 'Cnc Router'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'Equipment Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.show_chart_rounded, size: 18, color: Colors.grey.shade600),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Real-time availability of machines',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _equipment.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = _equipment[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.type.contains('Resin')
                        ? Icons.water_drop_outlined
                        : item.type.contains('Cnc')
                            ? Icons.precision_manufacturing_outlined
                            : Icons.print_outlined,
                    size: 20,
                    color: Colors.grey.shade700,
                  ),
                ),
                title: Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                subtitle: Text(
                  item.type,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                trailing: _StatusPill(status: item.status),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color dotColor;

    if (status == 'Available') {
      bgColor = const Color(0xFFE8F5E9); // Light green
      dotColor = const Color(0xFF43A047);
    } else if (status == 'In Use') {
      bgColor = const Color(0xFFFFF8E1); // Light yellow
      dotColor = const Color(0xFFFFB300);
    } else {
      bgColor = const Color(0xFFFFEBEE); // Light red
      dotColor = const Color(0xFFE53935);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: dotColor.withOpacity(0.9), // Darker text variant
            ),
          ),
        ],
      ),
    );
  }
}

class _EquipmentData {
  final String name;
  final String status;
  final String type;
  const _EquipmentData(
      {required this.name, required this.status, required this.type});
}

// ─────────────────────────────────────────────────────────────────────────────
// LOCATION SECTION
// ─────────────────────────────────────────────────────────────────────────────
class _LocationSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AMCen Location',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Visit us at our facility',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Map Placeholder Area
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Container(
                  width: double.infinity,
                  height: 300,
                  color: const Color(0xFFE8EAF6),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Map Graphic Simulation
                      CustomPaint(
                        size: const Size(double.infinity, 300),
                        painter: _MapGridPainter(),
                      ),
                      // Fake Map image snippet representation (just aesthetics)
                      Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Center(
                          child: Icon(Icons.map_outlined,
                              size: 40, color: Colors.grey.shade400),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              // Bottom Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 20, color: const Color(0xFF5C6BC0)),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'AMCen, DOST Regional Office, Davao City',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Text(
                        'Open in Maps',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      label: const Icon(Icons.open_in_new_rounded, size: 16),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF5C6BC0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.indigo.withOpacity(0.05)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
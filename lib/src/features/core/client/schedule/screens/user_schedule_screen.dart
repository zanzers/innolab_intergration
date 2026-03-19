import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Responsive helper
// ─────────────────────────────────────────────────────────────────────────────
bool _isMobile(BuildContext context) =>
    MediaQuery.of(context).size.width < 700;

// ─────────────────────────────────────────────────────────────────────────────
// Dashed Border Painter
// ─────────────────────────────────────────────────────────────────────────────
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.dashWidth = 6,
    this.dashSpace = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(16),
      ));
    canvas.drawPath(
        _dashPath(path, dashLength: dashWidth, gapLength: dashSpace), paint);
  }

  Path _dashPath(Path source,
      {required double dashLength, required double gapLength}) {
    final result = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = distance + dashLength;
        if (end > metric.length) break;
        result.addPath(metric.extractPath(distance, end), Offset.zero);
        distance += dashLength + gapLength;
      }
    }
    return result;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Appointment Model
// ─────────────────────────────────────────────────────────────────────────────
enum AppointmentStatus { confirmed, pending, cancelled }

class Appointment {
  final String id;
  final String title;
  final String type;
  final DateTime date;
  final String timeFrom;
  final String timeTo;
  final AppointmentStatus status;
  final String? notes;

  const Appointment({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
    required this.timeFrom,
    required this.timeTo,
    required this.status,
    this.notes,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Service Card
// ─────────────────────────────────────────────────────────────────────────────
class ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mobile = _isMobile(context);
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(mobile ? 16 : 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.shade100,
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Column(children: [
              Icon(icon, size: mobile ? 30 : 40, color: theme.primaryColor),
              SizedBox(height: mobile ? 8 : 12),
              Text(title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: mobile ? 13 : null)),
              const SizedBox(height: 4),
              if (!mobile)
                Text(description,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey.shade600)),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Legend Dot
// ─────────────────────────────────────────────────────────────────────────────
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Calendar Section
// ─────────────────────────────────────────────────────────────────────────────
class CalendarSection extends StatefulWidget {
  final List<DateTime> busyDays;
  final List<Appointment> appointments;
  final Function(DateTime)? onDateSelected;

  const CalendarSection({
    super.key,
    this.busyDays = const [],
    this.appointments = const [],
    this.onDateSelected,
  });

  @override
  State<CalendarSection> createState() => _CalendarSectionState();
}

class _CalendarSectionState extends State<CalendarSection> {
  DateTime _currentMonth = DateTime.now();
  DateTime? _selectedDate;

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  void _previousMonth() => setState(() =>
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1));

  void _nextMonth() => setState(() =>
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1));

  bool _isWeekend(DateTime d) =>
      d.weekday == DateTime.saturday || d.weekday == DateTime.sunday;

  bool _isBusy(DateTime d) => widget.busyDays
      .any((b) => b.year == d.year && b.month == d.month && b.day == d.day);

  bool _isToday(DateTime d) {
    final n = DateTime.now();
    return d.year == n.year && d.month == n.month && d.day == n.day;
  }

  bool _isSelected(DateTime d) =>
      _selectedDate != null &&
      _selectedDate!.year == d.year &&
      _selectedDate!.month == d.month &&
      _selectedDate!.day == d.day;

  List<Appointment> _appointmentsOn(DateTime d) => widget.appointments
      .where((a) =>
          a.date.year == d.year &&
          a.date.month == d.month &&
          a.date.day == d.day)
      .toList();

  void _onDayTapped(DateTime date) {
    final isWeekend = _isWeekend(date);
    final isBusy = _isBusy(date);
    final appts = _appointmentsOn(date);

    if (isWeekend) {
      _showInfoDialog(context,
          icon: Icons.event_busy,
          iconColor: Colors.red.shade400,
          title: 'Office Closed',
          subtitle: _formatDateFull(date),
          message:
              'Our office is closed on weekends (Saturday & Sunday). Please select a weekday to schedule your appointment.',
          badgeLabel: 'Unavailable',
          badgeColor: Colors.red.shade400);
      return;
    }

    if (isBusy) {
      _showInfoDialog(context,
          icon: Icons.person_off_outlined,
          iconColor: Colors.orange.shade600,
          title: 'Admin Unavailable',
          subtitle: _formatDateFull(date),
          message:
              'The admin is currently out of the office on this day. Please choose another available date for your appointment.',
          badgeLabel: 'Admin Busy',
          badgeColor: Colors.orange.shade600);
      return;
    }

    if (appts.isNotEmpty) {
      _showDayAppointmentsDialog(context, date, appts);
      return;
    }

    setState(() => _selectedDate = date);
    widget.onDateSelected?.call(date);
  }

  void _showInfoDialog(BuildContext context,
      {required IconData icon,
      required Color iconColor,
      required String title,
      required String subtitle,
      required String message,
      required String badgeLabel,
      required Color badgeColor}) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20)),
              child: Text(badgeLabel,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: badgeColor)),
            ),
            const SizedBox(height: 8),
            Text(subtitle,
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: Colors.grey.shade700, height: 1.5)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Got it'),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _showDayAppointmentsDialog(
      BuildContext context, DateTime date, List<Appointment> appts) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: Colors.green.shade50, shape: BoxShape.circle),
                child: Icon(Icons.event_available,
                    color: Colors.green.shade600, size: 20),
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Your Appointments',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                Text(_formatDateFull(date),
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500)),
              ]),
            ]),
            const SizedBox(height: 16),
            ...appts.map((a) => _MiniAppointmentTile(apt: a)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Close'),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  String _formatDateFull(DateTime d) {
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    return '${weekdays[d.weekday - 1]}, ${_months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mobile = _isMobile(context);
    final daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final leadingBlanks =
        DateTime(_currentMonth.year, _currentMonth.month, 1).weekday - 1;

    return Container(
      padding: EdgeInsets.all(mobile ? 12 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Month / Year header
        Row(children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 20),
            onPressed: _previousMonth,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Expanded(
            child: Column(children: [
              Text(
                _months[_currentMonth.month - 1],
                style: TextStyle(
                    fontSize: mobile ? 16 : 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey.shade800),
              ),
              Text('${_currentMonth.year}',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500)),
            ]),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 20),
            onPressed: _nextMonth,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ]),
        const SizedBox(height: 10),

        // Legend — wrap on mobile
        Wrap(
          spacing: 8,
          runSpacing: 4,
          alignment: WrapAlignment.end,
          children: [
            _LegendDot(color: Colors.red.shade300, label: 'Closed'),
            _LegendDot(color: Colors.orange.shade400, label: 'Admin Busy'),
            _LegendDot(color: Colors.green.shade500, label: 'Scheduled'),
            _LegendDot(color: Colors.blue.shade300, label: 'Available'),
          ],
        ),
        const SizedBox(height: 10),

        // Weekday headers
        Row(
          children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
              .asMap()
              .entries
              .map((e) => Expanded(
                    child: Text(
                      mobile ? e.value.substring(0, 1) : e.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: e.key >= 5
                            ? Colors.red.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 6),

        // Day grid
        LayoutBuilder(builder: (context, constraints) {
          final cellW = constraints.maxWidth / 7;
          final cellH = mobile ? 36.0 : 40.0;
          final cells = <Widget>[];

          for (int i = 0; i < leadingBlanks; i++) {
            cells.add(SizedBox(width: cellW, height: cellH));
          }

          for (int day = 1; day <= daysInMonth; day++) {
            final date =
                DateTime(_currentMonth.year, _currentMonth.month, day);
            final weekend = _isWeekend(date);
            final busy = _isBusy(date);
            final appts = _appointmentsOn(date);
            final hasAppt = appts.isNotEmpty;
            final selected = _isSelected(date);
            final today = _isToday(date);

            Color bgColor = Colors.transparent;
            Color textColor = Colors.grey.shade800;
            Color? borderColor;
            Color? dotColor;

            if (selected && !weekend && !busy) {
              bgColor = theme.primaryColor;
              textColor = Colors.white;
            } else if (hasAppt && !weekend && !busy) {
              bgColor = Colors.green.shade50;
              textColor = Colors.green.shade700;
              borderColor = Colors.green.shade300;
              dotColor = Colors.green.shade500;
            } else if (today && !weekend && !busy) {
              borderColor = theme.primaryColor;
              textColor = theme.primaryColor;
            } else if (weekend) {
              bgColor = Colors.red.shade50;
              textColor = Colors.red.shade300;
            } else if (busy) {
              bgColor = Colors.orange.shade50;
              textColor = Colors.orange.shade700;
              dotColor = Colors.orange.shade400;
            }

            cells.add(
              GestureDetector(
                onTap: () => _onDayTapped(date),
                child: SizedBox(
                  width: cellW,
                  height: cellH,
                  child: Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: mobile ? 30 : 34,
                          height: mobile ? 30 : 34,
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(8),
                            border: borderColor != null
                                ? Border.all(color: borderColor, width: 1.5)
                                : null,
                          ),
                          child: Center(
                            child: Text('$day',
                                style: TextStyle(
                                  fontSize: mobile ? 11 : 12,
                                  fontWeight:
                                      (selected || today || hasAppt)
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                  color: textColor,
                                )),
                          ),
                        ),
                        if (dotColor != null)
                          Positioned(
                            top: 1,
                            right: 1,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: dotColor,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 1),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return Wrap(children: cells);
        }),

        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.info_outline, size: 12, color: Colors.grey.shade400),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              'Tap any date for details. Office closed on weekends.',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
            ),
          ),
        ]),
      ]),
    );
  }
}

class _MiniAppointmentTile extends StatelessWidget {
  final Appointment apt;
  const _MiniAppointmentTile({required this.apt});

  Color get _statusColor {
    switch (apt.status) {
      case AppointmentStatus.confirmed:
        return Colors.green.shade600;
      case AppointmentStatus.pending:
        return Colors.orange.shade600;
      case AppointmentStatus.cancelled:
        return Colors.red.shade400;
    }
  }

  String get _statusLabel {
    switch (apt.status) {
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(children: [
        Icon(apt.type == 'Training' ? Icons.school : Icons.support_agent,
            size: 18, color: _statusColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(apt.title,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text('${apt.timeFrom} – ${apt.timeTo}',
                style:
                    TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ]),
        ),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20)),
          child: Text(_statusLabel,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _statusColor)),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Appointment Panel
// ─────────────────────────────────────────────────────────────────────────────
class AppointmentPanel extends StatelessWidget {
  final List<Appointment> appointments;
  const AppointmentPanel({super.key, required this.appointments});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            Icon(Icons.event_note_rounded,
                size: 16, color: theme.primaryColor),
            const SizedBox(width: 6),
            Text('Upcoming Schedules',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 4),
          Text('Tap a card to view full details',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
          const SizedBox(height: 14),
          if (appointments.isEmpty)
            const _EmptyState()
          else
            ...appointments.map((apt) => _AppointmentCard(apt: apt)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(children: [
          Icon(Icons.calendar_today_outlined,
              size: 36, color: Colors.grey.shade300),
          const SizedBox(height: 8),
          Text('No schedules yet',
              style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
          Text('Tap a date to book an appointment',
              style:
                  TextStyle(color: Colors.grey.shade400, fontSize: 11)),
        ]),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment apt;
  const _AppointmentCard({required this.apt});

  Color get _statusColor {
    switch (apt.status) {
      case AppointmentStatus.confirmed:
        return Colors.green.shade600;
      case AppointmentStatus.pending:
        return Colors.orange.shade600;
      case AppointmentStatus.cancelled:
        return Colors.red.shade400;
    }
  }

  Color get _statusBg {
    switch (apt.status) {
      case AppointmentStatus.confirmed:
        return Colors.green.shade50;
      case AppointmentStatus.pending:
        return Colors.orange.shade50;
      case AppointmentStatus.cancelled:
        return Colors.red.shade50;
    }
  }

  String get _statusLabel {
    switch (apt.status) {
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _dayOrdinal(int d) {
    if (d >= 11 && d <= 13) return '${d}th';
    switch (d % 10) {
      case 1:
        return '${d}st';
      case 2:
        return '${d}nd';
      case 3:
        return '${d}rd';
      default:
        return '${d}th';
    }
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${weekdays[d.weekday - 1]}, ${months[d.month - 1]} ${_dayOrdinal(d.day)}';
  }

  String _formatDateLong(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    return '${weekdays[d.weekday - 1]}, ${months[d.month - 1]} ${_dayOrdinal(d.day)}, ${d.year}';
  }

  void _showDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                      color: _statusColor.withOpacity(0.1),
                      shape: BoxShape.circle),
                  child: Icon(
                    apt.type == 'Training'
                        ? Icons.school
                        : Icons.support_agent,
                    color: _statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(apt.title,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              color: _statusBg,
                              borderRadius: BorderRadius.circular(20)),
                          child: Text(_statusLabel,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _statusColor)),
                        ),
                      ]),
                ),
              ]),
              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 16),
              _DetailRow(
                  icon: Icons.category_outlined,
                  label: 'Service Type',
                  value: apt.type),
              const SizedBox(height: 12),
              _DetailRow(
                  icon: Icons.calendar_today,
                  label: 'Date',
                  value: _formatDateLong(apt.date)),
              const SizedBox(height: 12),
              _DetailRow(
                  icon: Icons.access_time,
                  label: 'Time',
                  value: '${apt.timeFrom} – ${apt.timeTo}'),
              if (apt.notes != null) ...[
                const SizedBox(height: 12),
                _DetailRow(
                    icon: Icons.notes,
                    label: 'Notes',
                    value: apt.notes!),
              ],
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                    color: _statusBg,
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        apt.status == AppointmentStatus.confirmed
                            ? Icons.check_circle_outline
                            : apt.status == AppointmentStatus.pending
                                ? Icons.hourglass_empty
                                : Icons.cancel_outlined,
                        size: 16,
                        color: _statusColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        apt.status == AppointmentStatus.confirmed
                            ? 'Your appointment is confirmed.'
                            : apt.status == AppointmentStatus.pending
                                ? 'Waiting for admin confirmation.'
                                : 'This appointment was cancelled.',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _statusColor),
                      ),
                    ]),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _showDetails(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: IntrinsicHeight(
          child: Row(children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: _statusColor,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                          child: Text(apt.title,
                              style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              color: _statusBg,
                              borderRadius: BorderRadius.circular(20)),
                          child: Text(_statusLabel,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: _statusColor)),
                        ),
                      ]),
                      const SizedBox(height: 6),
                      Row(children: [
                        Icon(Icons.calendar_today,
                            size: 11, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(_formatDate(apt.date),
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600)),
                      ]),
                      const SizedBox(height: 3),
                      Row(children: [
                        Icon(Icons.access_time,
                            size: 11, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text('${apt.timeFrom} – ${apt.timeTo}',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600)),
                      ]),
                      const SizedBox(height: 4),
                      Row(children: [
                        Icon(Icons.touch_app,
                            size: 10, color: Colors.grey.shade400),
                        const SizedBox(width: 3),
                        Text('Tap to view details',
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade400,
                                fontStyle: FontStyle.italic)),
                      ]),
                    ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 15, color: Colors.grey.shade500),
      const SizedBox(width: 10),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
          const SizedBox(height: 1),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600)),
        ]),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Upload Box
// ─────────────────────────────────────────────────────────────────────────────
class UploadBox extends StatelessWidget {
  final VoidCallback onUpload;
  const UploadBox({super.key, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onUpload,
      child: CustomPaint(
        painter: DashedBorderPainter(color: theme.primaryColor),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_upload_outlined,
                    size: 36, color: theme.primaryColor),
                const SizedBox(height: 8),
                Text('Upload Valid ID',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: theme.primaryColor)),
                const SizedBox(height: 4),
                Text('Tap to browse',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Input Field
// ─────────────────────────────────────────────────────────────────────────────
class InputField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;

  const InputField({
    super.key,
    required this.label,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Header (reusable inside forms)
// ─────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade700)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Technical Support Form  — fixed + responsive
// ─────────────────────────────────────────────────────────────────────────────
class TechnicalSupportForm extends StatefulWidget {
  const TechnicalSupportForm({super.key});

  @override
  State<TechnicalSupportForm> createState() =>
      _TechnicalSupportFormState();
}

class _TechnicalSupportFormState extends State<TechnicalSupportForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _initialsCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _initialsCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Technical Support request submitted!')),
      );
    }
  }

  void _uploadId() => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload ID tapped')),
      );

  Widget _personalFields() => Column(children: [
        InputField(label: 'Name', controller: _nameCtrl),
        const SizedBox(height: 12),
        InputField(label: 'Initials', controller: _initialsCtrl),
        const SizedBox(height: 12),
        InputField(label: 'Last Name', controller: _lastNameCtrl),
      ]);

  Widget _contactFields() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('Contact Information'),
          InputField(
              label: 'Email',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 12),
          InputField(
              label: 'Contact Number',
              controller: _contactCtrl,
              keyboardType: TextInputType.phone),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final mobile = _isMobile(context);
    final pad = mobile ? 16.0 : 28.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Form title & breadcrumb ──────────────────────────────────
          Row(children: [
            Icon(Icons.info_outline, size: 14, color: Colors.grey.shade500),
            const SizedBox(width: 6),
            Text('Fill in your details to book a session',
                style:
                    TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ]),
          const SizedBox(height: 10),
          Text('Schedule Technical Support',
              style: TextStyle(
                  fontSize: mobile ? 18 : 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade800)),
          const SizedBox(height: 4),
          Text('Our team will get back to you within 24 hours.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          const Divider(height: 24, thickness: 1),

          if (mobile) ...[
            // ── MOBILE: stacked layout ─────────────────────────────────
            const _SectionLabel('Personal Info'),
            _personalFields(),
            const SizedBox(height: 20),
            const _SectionLabel('Upload Valid ID'),
            UploadBox(onUpload: _uploadId),
            const SizedBox(height: 20),
            _contactFields(),
          ] else ...[
            // ── DESKTOP: 2-column layout ───────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionLabel('Personal Info'),
                        _personalFields(),
                        const SizedBox(height: 20),
                        _contactFields(),
                      ]),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionLabel('Upload Valid ID'),
                        UploadBox(onUpload: _uploadId),
                      ]),
                ),
              ],
            ),
          ],

          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Submit Request',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Training Form  — fixed checkbox labels + responsive
// ─────────────────────────────────────────────────────────────────────────────
class TrainingForm extends StatefulWidget {
  const TrainingForm({super.key});

  @override
  State<TrainingForm> createState() => _TrainingFormState();
}

class _TrainingFormState extends State<TrainingForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _initialsCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();

  // Courses with display name + icon
  final List<Map<String, dynamic>> _courses = [
    {'label': '3D Modeling', 'icon': Icons.view_in_ar, 'checked': false},
    {'label': '3D Printing', 'icon': Icons.print, 'checked': false},
    {'label': 'CNC Machining', 'icon': Icons.precision_manufacturing, 'checked': false},
    {'label': 'Resin Printing', 'icon': Icons.opacity, 'checked': false},
    {'label': 'Arduino', 'icon': Icons.developer_board, 'checked': false},
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _initialsCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final selected = _courses
        .where((c) => c['checked'] == true)
        .map((c) => c['label'] as String)
        .toList();
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select at least one course.')),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Training submitted! Courses: ${selected.join(', ')}')),
      );
    }
  }

  void _uploadId() => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload ID tapped')),
      );

  Widget _personalFields() => Column(children: [
        InputField(label: 'Name', controller: _nameCtrl),
        const SizedBox(height: 12),
        InputField(label: 'Initials', controller: _initialsCtrl),
        const SizedBox(height: 12),
        InputField(label: 'Last Name', controller: _lastNameCtrl),
      ]);

  Widget _contactFields() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('Contact Information'),
          InputField(
              label: 'Email',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 12),
          InputField(
              label: 'Contact Number',
              controller: _contactCtrl,
              keyboardType: TextInputType.phone),
        ],
      );

  // ── Course selector — fixed labels using manual Row ──────────────────
  Widget _courseSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: List.generate(_courses.length, (i) {
          final course = _courses[i];
          final isLast = i == _courses.length - 1;
          return Column(children: [
            InkWell(
              onTap: () =>
                  setState(() => course['checked'] = !course['checked']),
              borderRadius: BorderRadius.only(
                topLeft: i == 0
                    ? const Radius.circular(12)
                    : Radius.zero,
                topRight: i == 0
                    ? const Radius.circular(12)
                    : Radius.zero,
                bottomLeft: isLast
                    ? const Radius.circular(12)
                    : Radius.zero,
                bottomRight: isLast
                    ? const Radius.circular(12)
                    : Radius.zero,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                child: Row(children: [
                  // Custom checkbox
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: course['checked'] == true
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: course['checked'] == true
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade400,
                        width: 1.5,
                      ),
                    ),
                    child: course['checked'] == true
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 14)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  // Course icon
                  Icon(course['icon'] as IconData,
                      size: 18,
                      color: course['checked'] == true
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade500),
                  const SizedBox(width: 10),
                  // Course label  ← this is the fix
                  Expanded(
                    child: Text(
                      course['label'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: course['checked'] == true
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: course['checked'] == true
                            ? Colors.grey.shade800
                            : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ]),
              ),
            ),
            if (!isLast)
              Divider(height: 1, color: Colors.grey.shade100),
          ]);
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mobile = _isMobile(context);
    final pad = mobile ? 16.0 : 28.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Form title ───────────────────────────────────────────────
          Row(children: [
            Icon(Icons.info_outline, size: 14, color: Colors.grey.shade500),
            const SizedBox(width: 6),
            Text('Select your courses and fill in your details',
                style:
                    TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ]),
          const SizedBox(height: 10),
          Text('Schedule Training',
              style: TextStyle(
                  fontSize: mobile ? 18 : 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade800)),
          const SizedBox(height: 4),
          Text(
              'Choose one or more training courses and provide your information.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          const Divider(height: 24, thickness: 1),

          if (mobile) ...[
            // ── MOBILE: stacked ────────────────────────────────────────
            const _SectionLabel('Personal Info'),
            _personalFields(),
            const SizedBox(height: 20),
            const _SectionLabel('Upload Valid ID'),
            UploadBox(onUpload: _uploadId),
            const SizedBox(height: 20),
            _contactFields(),
            const SizedBox(height: 20),
            const _SectionLabel('Select Training Courses'),
            _courseSelector(),
          ] else ...[
            // ── DESKTOP: 2-column ──────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionLabel('Personal Info'),
                        _personalFields(),
                        const SizedBox(height: 20),
                        _contactFields(),
                      ]),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionLabel('Upload Valid ID'),
                        UploadBox(onUpload: _uploadId),
                        const SizedBox(height: 20),
                        const _SectionLabel('Select Training Courses'),
                        _courseSelector(),
                      ]),
                ),
              ],
            ),
          ],

          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Submit Request',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Schedule Today Tab  — responsive
// ─────────────────────────────────────────────────────────────────────────────
class ScheduleTodayTab extends StatelessWidget {
  final TabController tabController;

  const ScheduleTodayTab({super.key, required this.tabController});

  static final List<DateTime> _busyDays = [
    DateTime(2026, 3, 4),
    DateTime(2026, 3, 11),
    DateTime(2026, 3, 18),
    DateTime(2026, 3, 20),
    DateTime(2026, 3, 25),
  ];

  static final List<Appointment> _appointments = [
    Appointment(
      id: '001',
      title: 'Technical Support Session',
      type: 'Technical Support',
      date: DateTime(2026, 3, 20),
      timeFrom: '9:00 AM',
      timeTo: '10:00 AM',
      status: AppointmentStatus.confirmed,
      notes: 'Hardware troubleshooting for CNC machine unit 3.',
    ),
    Appointment(
      id: '002',
      title: 'Arduino Training Workshop',
      type: 'Training',
      date: DateTime(2026, 3, 24),
      timeFrom: '1:00 PM',
      timeTo: '3:00 PM',
      status: AppointmentStatus.pending,
      notes: 'Intro to Arduino Uno — bring your own laptop.',
    ),
    Appointment(
      id: '003',
      title: '3D Printing Basics',
      type: 'Training',
      date: DateTime(2026, 3, 26),
      timeFrom: '10:00 AM',
      timeTo: '12:00 PM',
      status: AppointmentStatus.confirmed,
      notes: 'FDM printing overview and hands-on session.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final mobile = _isMobile(context);
    final pad = mobile ? 16.0 : 28.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Schedule Today',
            style: TextStyle(
                fontSize: mobile ? 20 : 26, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('Manage your appointments and service requests.',
            style: TextStyle(
                fontSize: 13, color: Colors.grey.shade600)),
        SizedBox(height: mobile ? 16 : 24),

        // Service cards
        Row(children: [
          ServiceCard(
            icon: Icons.support_agent,
            title: 'Technical Support',
            description: 'Get help with technical issues',
            onTap: () => tabController.animateTo(1),
          ),
          const SizedBox(width: 12),
          ServiceCard(
            icon: Icons.school,
            title: 'Training',
            description: 'Book a training session',
            onTap: () => tabController.animateTo(2),
          ),
        ]),
        SizedBox(height: mobile ? 20 : 28),

        Text('Event Calendar',
            style: TextStyle(
                fontSize: mobile ? 15 : 17,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800)),
        const Divider(height: 16, thickness: 1),
        const SizedBox(height: 8),

        if (mobile) ...[
          // MOBILE: calendar full-width then appointment panel below
          CalendarSection(
              busyDays: _busyDays,
              appointments: _appointments,
              onDateSelected: (_) {}),
          const SizedBox(height: 16),
          AppointmentPanel(appointments: _appointments),
        ] else ...[
          // DESKTOP: side by side
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              flex: 2,
              child: CalendarSection(
                  busyDays: _busyDays,
                  appointments: _appointments,
                  onDateSelected: (_) {}),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: AppointmentPanel(appointments: _appointments),
            ),
          ]),
        ],

        SizedBox(height: mobile ? 20 : 28),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.factory, size: 15, color: Colors.grey.shade400),
          const SizedBox(width: 6),
          Text('Manufacturing Center - MIMAROPA',
              style: TextStyle(
                  fontSize: 12, color: Colors.grey.shade500)),
        ]),
        const SizedBox(height: 8),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main Screen with 3 Tabs  — responsive tab bar
// ─────────────────────────────────────────────────────────────────────────────
class UserScheduleScreen extends StatefulWidget {
  const UserScheduleScreen({super.key});

  @override
  State<UserScheduleScreen> createState() => _UserScheduleScreenState();
}

class _UserScheduleScreenState extends State<UserScheduleScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mobile = _isMobile(context);

    return Column(children: [
      // Tab Bar
      Container(
        color: Colors.white,
        child: TabBar(
          controller: _tabController,
          labelColor: theme.primaryColor,
          unselectedLabelColor: Colors.grey.shade500,
          indicatorColor: theme.primaryColor,
          indicatorWeight: 2.5,
          labelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: mobile ? 11 : 13),
          unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: mobile ? 11 : 13),
          tabs: [
            Tab(
              icon: Icon(Icons.calendar_month_outlined,
                  size: mobile ? 16 : 18),
              text: mobile ? 'Schedule' : 'Schedule Today',
              iconMargin: const EdgeInsets.only(bottom: 2),
            ),
            Tab(
              icon: Icon(Icons.support_agent_outlined,
                  size: mobile ? 16 : 18),
              text: mobile ? 'Tech Support' : 'Technical Support',
              iconMargin: const EdgeInsets.only(bottom: 2),
            ),
            Tab(
              icon:
                  Icon(Icons.school_outlined, size: mobile ? 16 : 18),
              text: 'Training',
              iconMargin: const EdgeInsets.only(bottom: 2),
            ),
          ],
        ),
      ),

      // Tab Views
      Expanded(
        child: TabBarView(
          controller: _tabController,
          children: [
            ScheduleTodayTab(tabController: _tabController),
            const TechnicalSupportForm(),
            const TrainingForm(),
          ],
        ),
      ),
    ]);
  }
}
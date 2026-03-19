import 'package:flutter/material.dart';
import 'dart:math' as math;

// ── Design tokens ──────────────────────────────────────────────────────────────
class AppColors {
  static const bg            = Color(0xFFF4F6FB);
  static const surface       = Colors.white;
  static const border        = Color(0xFFE8ECF4);
  static const indigo        = Color(0xFF4F46E5);
  static const indigoLight   = Color(0xFFEEF2FF);
  static const indigoDark    = Color(0xFF3730A3);
  static const emerald       = Color(0xFF10B981);
  static const emeraldLight  = Color(0xFFD1FAE5);
  static const rose          = Color(0xFFF43F5E);
  static const roseLight     = Color(0xFFFFE4E6);
  static const amber         = Color(0xFFF59E0B);
  static const amberLight    = Color(0xFFFEF3C7);
  static const violet        = Color(0xFF8B5CF6);
  static const violetLight   = Color(0xFFEDE9FE);
  static const sky           = Color(0xFF0EA5E9);
  static const skyLight      = Color(0xFFE0F2FE);
  static const teal          = Color(0xFF14B8A6);
  static const tealLight     = Color(0xFFCCFBF1);
  static const textPrimary   = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textMuted     = Color(0xFF94A3B8);
}

class AppText {
  static const displayLg = TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.8, color: AppColors.textPrimary, height: 1.2);
  static const titleMd   = TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.3, color: AppColors.textPrimary);
  static const labelSm   = TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.2,  color: AppColors.textSecondary);
  static const mono      = TextStyle(fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.w600);
}

// ── Data models ────────────────────────────────────────────────────────────────

class MonthlyGoal {
  final String   title;
  final String   unit;
  final double   target;
  final double   current;
  final IconData icon;
  final Color    color;
  final Color    lightColor;
  final String   description;

  const MonthlyGoal({
    required this.title, required this.unit,   required this.target,
    required this.current, required this.icon, required this.color,
    required this.lightColor, required this.description,
  });

  double get progress => (current / target).clamp(0.0, 1.0);
  bool   get isMet    => current >= target;

  double get _expectedProgress {
    final now  = DateTime.now();
    final days = DateUtils.getDaysInMonth(now.year, now.month);
    return now.day / days;
  }

  GoalStatus get status {
    if (isMet)                                return GoalStatus.met;
    if (progress >= _expectedProgress - 0.05) return GoalStatus.onTrack;
    if (progress >= _expectedProgress - 0.20) return GoalStatus.atRisk;
    return GoalStatus.behind;
  }
}

enum GoalStatus { met, onTrack, atRisk, behind }

extension GoalStatusX on GoalStatus {
  String get label {
    switch (this) {
      case GoalStatus.met:     return 'Goal Met';
      case GoalStatus.onTrack: return 'On Track';
      case GoalStatus.atRisk:  return 'At Risk';
      case GoalStatus.behind:  return 'Behind';
    }
  }
  Color get color {
    switch (this) {
      case GoalStatus.met:     return AppColors.indigo;
      case GoalStatus.onTrack: return AppColors.emerald;
      case GoalStatus.atRisk:  return AppColors.amber;
      case GoalStatus.behind:  return AppColors.rose;
    }
  }
  Color get lightColor {
    switch (this) {
      case GoalStatus.met:     return AppColors.indigoLight;
      case GoalStatus.onTrack: return AppColors.emeraldLight;
      case GoalStatus.atRisk:  return AppColors.amberLight;
      case GoalStatus.behind:  return AppColors.roseLight;
    }
  }
}

class WeeklyEntry {
  final String day;
  final double actual;
  final double target;
  const WeeklyEntry({required this.day, required this.actual, required this.target});
}

class BudgetGoal {
  final double budgetLimit;
  final double spent;
  final double reserved;
  const BudgetGoal({required this.budgetLimit, required this.spent, required this.reserved});

  double get remaining   => (budgetLimit - spent - reserved).clamp(0, budgetLimit);
  double get spentPct    => (spent    / budgetLimit).clamp(0, 1);
  double get reservedPct => (reserved / budgetLimit).clamp(0, 1);
  bool   get isOverBudget=> spent + reserved > budgetLimit;
}

class MonthHistory {
  final String month;
  final int    requestsHandled;
  final double approvalRate;
  final double avgResponseH;
  final double budgetUsedPct;

  const MonthHistory({
    required this.month, required this.requestsHandled,
    required this.approvalRate, required this.avgResponseH, required this.budgetUsedPct,
  });
}

// ── Main screen ────────────────────────────────────────────────────────────────

class AdminHomeDashboard extends StatefulWidget {
  const AdminHomeDashboard({super.key});

  @override
  State<AdminHomeDashboard> createState() => _AdminHomeDashboardState();
}

class _AdminHomeDashboardState extends State<AdminHomeDashboard> {
  late List<MonthlyGoal>  _monthlyGoals;
  late List<WeeklyEntry>  _weeklyData;
  late BudgetGoal         _budget;
  late List<MonthHistory> _history;
  int _selectedMetric = 0;

  @override
  void initState() {
    super.initState();

    _monthlyGoals = [
      const MonthlyGoal(title: 'Requests Processed', unit: 'req',   target: 500, current: 312,
        icon: Icons.assignment_turned_in_rounded,
        color: AppColors.indigo,  lightColor: AppColors.indigoLight,
        description: 'Total requests resolved this month'),
      const MonthlyGoal(title: 'Approval Rate',       unit: '%',     target: 85,  current: 78,
        icon: Icons.verified_rounded,
        color: AppColors.emerald, lightColor: AppColors.emeraldLight,
        description: 'Percentage of approved requests'),
      const MonthlyGoal(title: 'Avg Response Time',   unit: 'h',     target: 4,   current: 3.2,
        icon: Icons.timer_rounded,
        color: AppColors.sky,     lightColor: AppColors.skyLight,
        description: 'Average hours to first response'),
      const MonthlyGoal(title: 'Staff Utilization',   unit: '%',     target: 90,  current: 91,
        icon: Icons.people_alt_rounded,
        color: AppColors.violet,  lightColor: AppColors.violetLight,
        description: 'Active staff task coverage'),
      const MonthlyGoal(title: 'Maintenance Tasks',   unit: 'tasks', target: 60,  current: 28,
        icon: Icons.build_rounded,
        color: AppColors.amber,   lightColor: AppColors.amberLight,
        description: 'Scheduled maintenance completed'),
    ];

    _weeklyData = [
      const WeeklyEntry(day: 'Mon', actual: 18, target: 20),
      const WeeklyEntry(day: 'Tue', actual: 22, target: 20),
      const WeeklyEntry(day: 'Wed', actual: 15, target: 20),
      const WeeklyEntry(day: 'Thu', actual: 25, target: 20),
      const WeeklyEntry(day: 'Fri', actual: 19, target: 20),
      const WeeklyEntry(day: 'Sat', actual: 10, target: 12),
      const WeeklyEntry(day: 'Sun', actual:  8, target: 12),
    ];

    _budget = const BudgetGoal(
      budgetLimit: 250000,
      spent:       148500,
      reserved:     42000,
    );

    _history = const [
      MonthHistory(month: 'Oct', requestsHandled: 410, approvalRate: 80.0, avgResponseH: 4.2, budgetUsedPct: 88),
      MonthHistory(month: 'Nov', requestsHandled: 438, approvalRate: 83.0, avgResponseH: 3.9, budgetUsedPct: 91),
      MonthHistory(month: 'Dec', requestsHandled: 395, approvalRate: 76.0, avgResponseH: 4.8, budgetUsedPct: 95),
      MonthHistory(month: 'Jan', requestsHandled: 461, approvalRate: 81.0, avgResponseH: 3.7, budgetUsedPct: 82),
      MonthHistory(month: 'Feb', requestsHandled: 489, approvalRate: 84.0, avgResponseH: 3.5, budgetUsedPct: 87),
      MonthHistory(month: 'Mar', requestsHandled: 312, approvalRate: 78.0, avgResponseH: 3.2, budgetUsedPct: 59),
    ];
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    final header       = _buildHeader(isMobile);
    final monthBanner  = _buildMonthProgress();
    final budgetCard   = _buildBudgetCard(isMobile);
    final goalCards    = _buildGoalCards(isMobile);
    final weeklyChart  = _buildWeeklyChart();
    final breakdown    = _buildGoalBreakdown();
    final trendChart   = _buildTrendChart();
    final historyPanel = _buildHistoryPanel();

    final midSection = isMobile
        ? Column(children: [weeklyChart, const SizedBox(height: 20), breakdown])
        : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(flex: 3, child: weeklyChart),
            const SizedBox(width: 20),
            Expanded(flex: 2, child: breakdown),
          ]);

    final bottomSection = isMobile
        ? Column(children: [trendChart, const SizedBox(height: 20), historyPanel])
        : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(flex: 3, child: trendChart),
            const SizedBox(width: 20),
            Expanded(flex: 2, child: historyPanel),
          ]);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          isMobile ? 16 : 28, isMobile ? 20 : 32, isMobile ? 16 : 28, 40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            const SizedBox(height: 24),
            monthBanner,
            const SizedBox(height: 20),
            budgetCard,
            const SizedBox(height: 20),
            goalCards,
            const SizedBox(height: 24),
            midSection,
            const SizedBox(height: 24),
            bottomSection,
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(bool isMobile) {
    final now    = DateTime.now();
    final months = ['January','February','March','April','May','June',
                    'July','August','September','October','November','December'];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 6, height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [AppColors.indigo, AppColors.violet],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 14),
                Flexible(
                  child: Text(
                    isMobile ? 'Goal Tracker' : 'Monthly Goal Tracker',
                    style: AppText.displayLg.copyWith(fontSize: isMobile ? 22 : 28),
                  ),
                ),
              ]),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  '${months[now.month - 1]} ${now.year}  ·  Day ${now.day} of ${DateUtils.getDaysInMonth(now.year, now.month)}',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _DownloadButton(goals: _monthlyGoals, weekly: _weeklyData),
      ],
    );
  }

  // ── Month progress banner ──────────────────────────────────────────────────

  Widget _buildMonthProgress() {
    final now       = DateTime.now();
    final daysTotal = DateUtils.getDaysInMonth(now.year, now.month);
    final dayPct    = now.day / daysTotal;
    final metCount  = _monthlyGoals
        .where((g) => g.status == GoalStatus.met || g.status == GoalStatus.onTrack)
        .length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.indigo, AppColors.indigoDark],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.indigo.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Month Progress',
                style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
              child: Text('$metCount / ${_monthlyGoals.length} goals on track',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: dayPct,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${(dayPct * 100).toStringAsFixed(0)}% of month elapsed',
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text('${daysTotal - now.day} days remaining',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
        ],
      ),
    );
  }

  // ── Budget card ────────────────────────────────────────────────────────────

  Widget _buildBudgetCard(bool isMobile) {
    final b = _budget;
    String fmt(double v) {
      if (v >= 1000000) return '₱${(v / 1000000).toStringAsFixed(2)}M';
      if (v >= 1000)    return '₱${(v / 1000).toStringAsFixed(1)}K';
      return '₱${v.toStringAsFixed(0)}';
    }

    final overBudget  = b.isOverBudget;
    final accent      = overBudget ? AppColors.rose : AppColors.teal;
    final accentLight = overBudget ? AppColors.roseLight : AppColors.tealLight;

    final stats = [
      _BudgetStatData('Budget',    fmt(b.budgetLimit), AppColors.textPrimary, Icons.account_balance_wallet_outlined),
      _BudgetStatData('Spent',     fmt(b.spent),       AppColors.rose,        Icons.remove_circle_outline),
      _BudgetStatData('Reserved',  fmt(b.reserved),    AppColors.amber,       Icons.lock_outline),
      _BudgetStatData('Remaining', fmt(b.remaining),   accent,                Icons.savings_outlined),
    ];

    final statWidgets = stats.map((s) => Expanded(
      child: _BudgetStat(label: s.label, value: s.value, color: s.color, icon: s.icon),
    )).toList();

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: accentLight, borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.account_balance_wallet_rounded, color: accent, size: 18),
              ),
              const SizedBox(width: 10),
              const Text('Monthly Budget', style: AppText.titleMd),
            ]),
            overBudget
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.roseLight, borderRadius: BorderRadius.circular(20)),
                    child: Row(children: const [
                      Icon(Icons.warning_amber_rounded, color: AppColors.rose, size: 14),
                      SizedBox(width: 4),
                      Text('Over Budget', style: TextStyle(color: AppColors.rose, fontSize: 11, fontWeight: FontWeight.w700)),
                    ]),
                  )
                : _Chip(label: 'On Budget', color: AppColors.teal),
          ]),
          const SizedBox(height: 16),

          // Stacked progress bar (spent + reserved)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: Stack(children: [
                Container(color: AppColors.bg),
                FractionallySizedBox(
                  widthFactor: (b.spentPct + b.reservedPct).clamp(0, 1),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: overBudget
                            ? [AppColors.rose, AppColors.amber]
                            : [AppColors.rose, AppColors.amber],
                      ),
                    ),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: b.spentPct,
                  child: Container(color: AppColors.rose),
                ),
              ]),
            ),
          ),

          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Container(width: 8, height: 8, margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(color: AppColors.rose, borderRadius: BorderRadius.circular(2))),
              Text('Spent ${(b.spentPct * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
              const SizedBox(width: 10),
              Container(width: 8, height: 8, margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(color: AppColors.amber, borderRadius: BorderRadius.circular(2))),
              Text('Reserved ${(b.reservedPct * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
            ]),
            Text(
              '${((b.spent + b.reserved) / b.budgetLimit * 100).toStringAsFixed(0)}% committed',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                  color: overBudget ? AppColors.rose : AppColors.textSecondary),
            ),
          ]),

          const SizedBox(height: 16),
          isMobile
              ? Column(children: stats.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(children: [
                    Expanded(child: _BudgetStat(label: s.label, value: s.value, color: s.color, icon: s.icon)),
                  ]),
                )).toList())
              : Row(children: statWidgets),
        ],
      ),
    );
  }

  // ── Goal cards ─────────────────────────────────────────────────────────────

  Widget _buildGoalCards(bool isMobile) {
    if (isMobile) {
      return Column(
        children: _monthlyGoals.map((g) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _GoalCardMobile(goal: g),
        )).toList(),
      );
    }
    return Row(
      children: _monthlyGoals.asMap().entries.map((e) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: e.key < _monthlyGoals.length - 1 ? 16 : 0),
          child: _GoalCardWeb(goal: e.value),
        ),
      )).toList(),
    );
  }

  // ── Weekly bar chart ───────────────────────────────────────────────────────

  Widget _buildWeeklyChart() {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Weekly Progress', style: AppText.titleMd),
            Row(children: [
              _LegendDot(color: AppColors.indigo, label: 'Actual'),
              const SizedBox(width: 12),
              _LegendDot(color: AppColors.rose.withOpacity(0.5), label: 'Target', isDashed: true),
            ]),
          ]),
          const SizedBox(height: 6),
          const Text('Requests processed vs daily target',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 24),
          _WeeklyGoalChart(data: _weeklyData),
        ],
      ),
    );
  }

  // ── Goal breakdown ─────────────────────────────────────────────────────────

  Widget _buildGoalBreakdown() {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Goal Summary', style: AppText.titleMd),
            _Chip(label: 'This month', color: AppColors.indigo),
          ]),
          const SizedBox(height: 16),
          ..._monthlyGoals.map((g) => _GoalSummaryRow(goal: g)),
        ],
      ),
    );
  }

  // ── 6-month trend line chart ───────────────────────────────────────────────

  Widget _buildTrendChart() {
    const metricLabels = ['Requests', 'Approval %', 'Response h', 'Budget %'];
    const metricColors = [AppColors.indigo, AppColors.emerald, AppColors.sky, AppColors.amber];

    List<double> values() {
      switch (_selectedMetric) {
        case 0: return _history.map((h) => h.requestsHandled.toDouble()).toList();
        case 1: return _history.map((h) => h.approvalRate).toList();
        case 2: return _history.map((h) => h.avgResponseH).toList();
        case 3: return _history.map((h) => h.budgetUsedPct).toList();
        default: return [];
      }
    }

    final color = metricColors[_selectedMetric];

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('6-Month Trend', style: AppText.titleMd),
          const SizedBox(height: 4),
          const Text('Track performance over previous months',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 14),

          // Metric selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(metricLabels.length, (i) {
                final sel = i == _selectedMetric;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMetric = i),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel ? metricColors[i] : AppColors.bg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sel ? metricColors[i] : AppColors.border),
                    ),
                    child: Text(metricLabels[i],
                        style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : AppColors.textSecondary,
                        )),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: _TrendLineChart(
              values: values(),
              labels: _history.map((h) => h.month).toList(),
              color:  color,
            ),
          ),
        ],
      ),
    );
  }

  // ── History panel ──────────────────────────────────────────────────────────

  Widget _buildHistoryPanel() {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Month History', style: AppText.titleMd),
            _Chip(label: 'Last 6 months', color: AppColors.violet),
          ]),
          const SizedBox(height: 6),
          const Text('Snapshot of previous months',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 16),

          // Table header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(children: [
              SizedBox(width: 36, child: Text('Mo.', style: AppText.labelSm.copyWith(color: AppColors.textMuted, fontSize: 10))),
              Expanded(child: Text('Req',   style: AppText.labelSm.copyWith(color: AppColors.textMuted, fontSize: 10))),
              Expanded(child: Text('App%',  style: AppText.labelSm.copyWith(color: AppColors.textMuted, fontSize: 10))),
              Expanded(child: Text('Res h', style: AppText.labelSm.copyWith(color: AppColors.textMuted, fontSize: 10))),
              Expanded(child: Text('Bgt%',  style: AppText.labelSm.copyWith(color: AppColors.textMuted, fontSize: 10))),
            ]),
          ),
          Divider(color: AppColors.border, height: 8),

          ..._history.reversed.toList().asMap().entries.map((e) =>
            _HistoryRow(entry: e.value, isCurrentMonth: e.key == 0)),
        ],
      ),
    );
  }
}

// ── Budget stat ────────────────────────────────────────────────────────────────

class _BudgetStatData {
  final String   label, value;
  final Color    color;
  final IconData icon;
  const _BudgetStatData(this.label, this.value, this.color, this.icon);
}

class _BudgetStat extends StatelessWidget {
  const _BudgetStat({required this.label, required this.value, required this.color, required this.icon});
  final String  label, value;
  final Color   color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07), borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color, letterSpacing: -0.3)),
          Text(label,  style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
        ]),
      ]),
    );
  }
}

// ── Trend line chart ───────────────────────────────────────────────────────────

class _TrendLineChart extends StatelessWidget {
  const _TrendLineChart({required this.values, required this.labels, required this.color});
  final List<double> values;
  final List<String> labels;
  final Color        color;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();

    return Column(children: [
      Expanded(
        child: CustomPaint(
          painter: _LineChartPainter(values: values, color: color),
          child: const SizedBox.expand(),
        ),
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: labels.asMap().entries.map((e) {
          final isLast = e.key == labels.length - 1;
          return Text(e.value, style: TextStyle(
            fontSize: 11, fontWeight: isLast ? FontWeight.w700 : FontWeight.w500,
            color: isLast ? color : AppColors.textMuted,
          ));
        }).toList(),
      ),
    ]);
  }
}

class _LineChartPainter extends CustomPainter {
  const _LineChartPainter({required this.values, required this.color});
  final List<double> values;
  final Color        color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final minV   = values.reduce(math.min);
    final maxV   = values.reduce(math.max);
    final range  = (maxV - minV).clamp(1.0, double.infinity);
    const padTop = 20.0;
    const padBot = 4.0;

    double yFor(double v) => padTop + (1 - (v - minV) / range) * (size.height - padTop - padBot);
    double xFor(int    i) => i / (values.length - 1) * size.width;

    final pts = List.generate(values.length, (i) => Offset(xFor(i), yFor(values[i])));

    // filled area
    final areaPath = Path()..moveTo(pts.first.dx, size.height);
    for (final p in pts) areaPath.lineTo(p.dx, p.dy);
    areaPath..lineTo(pts.last.dx, size.height)..close();

    canvas.drawPath(
      areaPath,
      Paint()
        ..shader = LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [color.withOpacity(0.22), color.withOpacity(0.02)],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill,
    );

    // smooth line (catmull-rom spline)
    final linePath = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 0; i < pts.length - 1; i++) {
      final p0  = pts[math.max(i - 1, 0)];
      final p1  = pts[i];
      final p2  = pts[i + 1];
      final p3  = pts[math.min(i + 2, pts.length - 1)];
      final cp1 = Offset(p1.dx + (p2.dx - p0.dx) / 6, p1.dy + (p2.dy - p0.dy) / 6);
      final cp2 = Offset(p2.dx - (p3.dx - p1.dx) / 6, p2.dy - (p3.dy - p1.dy) / 6);
      linePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }

    canvas.drawPath(linePath,
      Paint()..color = color..strokeWidth = 2.5..style = PaintingStyle.stroke
             ..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);

    // dots + value labels
    for (int i = 0; i < pts.length; i++) {
      final isLast = i == pts.length - 1;
      canvas.drawCircle(pts[i], isLast ? 6 : 4, Paint()..color = Colors.white..style = PaintingStyle.fill);
      canvas.drawCircle(pts[i], isLast ? 4 : 2.5, Paint()..color = color..style = PaintingStyle.fill);

      final tp = TextPainter(
        text: TextSpan(
          text: _fmtVal(values[i]),
          style: TextStyle(fontSize: isLast ? 11 : 10,
              fontWeight: isLast ? FontWeight.w700 : FontWeight.w500,
              color: isLast ? color : AppColors.textMuted),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(pts[i].dx - tp.width / 2, pts[i].dy - tp.height - 4));
    }
  }

  String _fmtVal(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }

  @override
  bool shouldRepaint(_LineChartPainter old) => old.values != values || old.color != color;
}

// ── History row ────────────────────────────────────────────────────────────────

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry, required this.isCurrentMonth});
  final MonthHistory entry;
  final bool         isCurrentMonth;

  @override
  Widget build(BuildContext context) {
    Color approvalColor() {
      if (entry.approvalRate >= 85) return AppColors.emerald;
      if (entry.approvalRate >= 75) return AppColors.amber;
      return AppColors.rose;
    }
    Color budgetColor() {
      if (entry.budgetUsedPct <= 85) return AppColors.emerald;
      if (entry.budgetUsedPct <= 95) return AppColors.amber;
      return AppColors.rose;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrentMonth ? AppColors.indigoLight : AppColors.bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isCurrentMonth ? AppColors.indigo.withOpacity(0.2) : AppColors.border),
      ),
      child: Row(children: [
        SizedBox(width: 36,
          child: Text(entry.month, style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w700,
            color: isCurrentMonth ? AppColors.indigo : AppColors.textPrimary,
          ))),
        Expanded(child: Text('${entry.requestsHandled}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
        Expanded(child: _MiniTag(value: '${entry.approvalRate.toStringAsFixed(0)}%', color: approvalColor())),
        Expanded(child: Text('${entry.avgResponseH.toStringAsFixed(1)}h',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
        Expanded(child: _MiniTag(value: '${entry.budgetUsedPct.toStringAsFixed(0)}%', color: budgetColor())),
      ]),
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.value, required this.color});
  final String value;
  final Color  color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
      child: Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

// ── Reused goal card widgets ───────────────────────────────────────────────────

class _GoalCardWeb extends StatelessWidget {
  const _GoalCardWeb({required this.goal});
  final MonthlyGoal goal;

  String _fmt(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: goal.lightColor, borderRadius: BorderRadius.circular(10)),
              child: Icon(goal.icon, color: goal.color, size: 18)),
          _StatusBadge(status: goal.status),
        ]),
        const SizedBox(height: 16),
        Center(child: _ArcProgress(progress: goal.progress, color: goal.color, lightColor: goal.lightColor)),
        const SizedBox(height: 14),
        Text(goal.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text('${_fmt(goal.current)} / ${_fmt(goal.target)} ${goal.unit}',
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        const SizedBox(height: 10),
        ClipRRect(borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: goal.progress, backgroundColor: goal.lightColor,
                valueColor: AlwaysStoppedAnimation<Color>(goal.color), minHeight: 4)),
      ]),
    );
  }
}

class _GoalCardMobile extends StatelessWidget {
  const _GoalCardMobile({required this.goal});
  final MonthlyGoal goal;

  String _fmt(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(children: [
        _ArcProgress(progress: goal.progress, color: goal.color, lightColor: goal.lightColor,
            size: 64, strokeWidth: 7, fontSize: 11),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Flexible(child: Text(goal.title,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                overflow: TextOverflow.ellipsis)),
            _StatusBadge(status: goal.status),
          ]),
          const SizedBox(height: 4),
          Text(goal.description, style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 10),
          ClipRRect(borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: goal.progress, backgroundColor: goal.lightColor,
                  valueColor: AlwaysStoppedAnimation<Color>(goal.color), minHeight: 5)),
          const SizedBox(height: 5),
          Text('${_fmt(goal.current)} / ${_fmt(goal.target)} ${goal.unit}',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        ])),
      ]),
    );
  }
}

class _ArcProgress extends StatelessWidget {
  const _ArcProgress({required this.progress, required this.color, required this.lightColor,
    this.size = 88, this.strokeWidth = 9, this.fontSize = 13});
  final double progress, size, strokeWidth, fontSize;
  final Color  color, lightColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: size, height: size,
      child: Stack(alignment: Alignment.center, children: [
        CustomPaint(size: Size(size, size),
            painter: _ArcPainter(progress: progress, color: color, lightColor: lightColor, strokeWidth: strokeWidth)),
        Text('${(progress * 100).toInt()}%',
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w800, color: color)),
      ]));
  }
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter({required this.progress, required this.color, required this.lightColor, required this.strokeWidth});
  final double progress, strokeWidth;
  final Color  color, lightColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center     = Offset(size.width / 2, size.height / 2);
    final radius     = (size.width - strokeWidth) / 2;
    const startAngle = -math.pi * 0.75;
    const sweepFull  =  math.pi * 1.5;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepFull, false,
      Paint()..color = lightColor..strokeWidth = strokeWidth..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);

    if (progress > 0) {
      final shader = SweepGradient(
        startAngle: startAngle, endAngle: startAngle + sweepFull,
        colors: [color.withOpacity(0.6), color],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepFull * progress, false,
        Paint()..shader = shader..strokeWidth = strokeWidth..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.progress != progress || old.color != color;
}

class _WeeklyGoalChart extends StatelessWidget {
  const _WeeklyGoalChart({required this.data});
  final List<WeeklyEntry> data;

  @override
  Widget build(BuildContext context) {
    final maxVal   = data.map((e) => math.max(e.actual, e.target)).reduce(math.max);
    final today    = DateTime.now().weekday;
    const barWidth = 32.0;

    return SizedBox(
      height: 160,
      child: CustomPaint(
        painter: _TargetLinePainter(data: data, maxVal: maxVal),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: data.asMap().entries.map((entry) {
            final i       = entry.key;
            final item    = entry.value;
            final isToday = (i + 1) == today;
            final barH    = math.max(6.0, (item.actual / maxVal) * 110);
            final met     = item.actual >= item.target;

            return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              Text(item.actual.toInt().toString(),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                      color: isToday ? AppColors.indigo : AppColors.textMuted)),
              const SizedBox(height: 4),
              Container(
                width: barWidth, height: barH,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter, end: Alignment.topCenter,
                    colors: isToday
                        ? [AppColors.indigo, AppColors.violet]
                        : met
                            ? [AppColors.emerald.withOpacity(0.6), AppColors.emerald.withOpacity(0.85)]
                            : [AppColors.rose.withOpacity(0.5), AppColors.rose.withOpacity(0.75)],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  boxShadow: isToday
                      ? [BoxShadow(color: AppColors.indigo.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))]
                      : [],
                ),
              ),
              const SizedBox(height: 8),
              Text(item.day, style: TextStyle(fontSize: 12,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                  color: isToday ? AppColors.indigo : AppColors.textMuted)),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

class _TargetLinePainter extends CustomPainter {
  const _TargetLinePainter({required this.data, required this.maxVal});
  final List<WeeklyEntry> data;
  final double maxVal;

  @override
  void paint(Canvas canvas, Size size) {
    final avgTarget = data.map((e) => e.target).reduce((a, b) => a + b) / data.length;
    final y = size.height - 28 - (avgTarget / maxVal) * 110;
    final paint = Paint()..color = AppColors.rose.withOpacity(0.5)..strokeWidth = 1.5..style = PaintingStyle.stroke;
    const dashWidth = 6.0, dashSpace = 4.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, y), Offset(startX + dashWidth, y), paint);
      startX += dashWidth + dashSpace;
    }
    final tp = TextPainter(
      text: TextSpan(text: 'Target',
          style: TextStyle(fontSize: 10, color: AppColors.rose.withOpacity(0.8), fontWeight: FontWeight.w600)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(4, y - 14));
  }

  @override
  bool shouldRepaint(_TargetLinePainter old) => false;
}

class _GoalSummaryRow extends StatelessWidget {
  const _GoalSummaryRow({required this.goal});
  final MonthlyGoal goal;

  @override
  Widget build(BuildContext context) {
    final f = (double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        Container(width: 36, height: 36,
            decoration: BoxDecoration(color: goal.lightColor, borderRadius: BorderRadius.circular(8)),
            child: Icon(goal.icon, color: goal.color, size: 18)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(goal.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textPrimary)),
          const SizedBox(height: 3),
          ClipRRect(borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: goal.progress, backgroundColor: goal.lightColor,
                  valueColor: AlwaysStoppedAnimation<Color>(goal.color), minHeight: 4)),
        ])),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          _StatusBadge(status: goal.status, compact: true),
          const SizedBox(height: 3),
          Text('${f(goal.current)}/${f(goal.target)}',
              style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
        ]),
      ]),
    );
  }
}

// ── Tiny shared widgets ────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, this.compact = false});
  final GoalStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 8, vertical: compact ? 2 : 4),
      decoration: BoxDecoration(color: status.lightColor, borderRadius: BorderRadius.circular(20)),
      child: Text(status.label,
          style: TextStyle(color: status.color, fontSize: compact ? 10 : 11, fontWeight: FontWeight.w700)),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});
  final String label;
  final Color  color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label, this.isDashed = false});
  final Color  color;
  final String label;
  final bool   isDashed;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      isDashed
          ? Row(children: List.generate(3, (i) => Container(
              width: 4, height: 2, margin: const EdgeInsets.only(right: 2), color: color)))
          : Container(width: 10, height: 10,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
    ]);
  }
}

class _DownloadButton extends StatelessWidget {
  const _DownloadButton({required this.goals, required this.weekly});
  final List<MonthlyGoal> goals;
  final List<WeeklyEntry> weekly;

  void _onDownload(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: const [
        Icon(Icons.download_done_rounded, color: Colors.white, size: 18),
        SizedBox(width: 10),
        Flexible(child: Text('Report ready — connect pdf + printing packages to export')),
      ]),
      backgroundColor: AppColors.indigoDark,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 4),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onDownload(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.indigo, AppColors.indigoDark]),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: AppColors.indigo.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: const [
          Icon(Icons.download_rounded, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Text('Export', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
        ]),
      ),
    );
  }
}
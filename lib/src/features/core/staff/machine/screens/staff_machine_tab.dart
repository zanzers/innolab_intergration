import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:innolab/src/features/core/staff/machine/screens/staff_machine_screen.dart';
import 'package:innolab/src/features/core/staff/machine/screens/staff_inventory_screen.dart';

/// This is the root widget used by the sidebar nav item "Machine".
/// It contains two sub-tabs: Machines and Inventory — separate files,
/// shown together in the same tab.
class StaffMachineTab extends StatefulWidget {
  const StaffMachineTab({super.key});

  @override
  State<StaffMachineTab> createState() => _StaffMachineTabState();
}

class _StaffMachineTabState extends State<StaffMachineTab>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Sub-tab bar ────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(30),
            ),
            child: TabBar(
              controller: _tab,
              indicator: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(30),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade500,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13),
              unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w400, fontSize: 13),
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.cpu, size: 15),
                      SizedBox(width: 6),
                      Text('Machines'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.box, size: 15),
                      SizedBox(width: 6),
                      Text('Inventory'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Tab content ─────────────────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: const [
              StaffMachineScreen(),
              StaffInventoryScreen(),
            ],
          ),
        ),
      ],
    );
  }
}
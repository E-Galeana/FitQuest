import 'package:flutter/material.dart';
import 'package:fitquest/widgets/popup_log.dart'; // Quick popup
import 'package:fitquest/screens/barcode_scanner_page.dart';      // Barcode scanner screen

/// Main page design with integrated Quick Log functionality.
class MainPageDesign extends StatefulWidget {
  const MainPageDesign({Key? key}) : super(key: key);

  @override
  State<MainPageDesign> createState() => _MainPageDesignState();
}

class _MainPageDesignState extends State<MainPageDesign> {
  int _calories = 0;                   // Current calorie count
  final int _dailyGoal = 2000;         // Daily calorie goal

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FitQuest'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView(
            children: [
              // Calorie progress indicator
              Center(
                child: CircleProgressWidget(
                  progress: progress,
                  size: 210,
                  strokeWidth: 14,
                  backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
                  progressColor: Colors.greenAccent,
                  label: '$_calories kcal',
                ),
              ),
              const SizedBox(height: 24),

              // Quick Log button
              ElevatedButton.icon(
                onPressed: () async {
                  // Show the quick action popup
                  final action = await showQuickActionModal(context);
                  if (action == QuickAction.scanBarcode) {
                    // Open barcode scanner
                    final result = await Navigator.push<int>(
                      context,
                      MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
                    );
                    if (result != null) {
                      setState(() => _calories += result);
                    }
                  } else if (action == QuickAction.selectWorkout) {
                    final workout = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(builder: (_) => const WorkoutSelectionPage()),
                    );
                    if (workout != null) setState(() => _dailyWorkouts.add(workout));
                  }
                },
                icon: const Icon(Icons.flash_on),
                label: const Text('Quick Log'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // Today's entries list placeholder
              Text('Today’s Entries', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),

              // Workouts section
              if (_dailyWorkouts.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Text('Workouts', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                for (var w in _dailyWorkouts)
                  ListTile(
                    leading: const Icon(Icons.fitness_center),
                    title: Text(w),
                  ),
                const Divider(),
              ],

              // Meals section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Text('Meals', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const ListTile(
                leading: Icon(Icons.restaurant_menu),
                title: Text('Breakfast: Oatmeal'),
                trailing: Text('350 kcal'),
              ),
              const ListTile(
                leading: Icon(Icons.restaurant_menu),
                title: Text('Lunch: Salad'),
                trailing: Text('450 kcal'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      // Navigation bar placeholder
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          // TODO: Add calendar?
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Schedule'),
          // TODO: Add profile?
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: 0,
        onTap: (index) {},
      ),
    );
  }
}
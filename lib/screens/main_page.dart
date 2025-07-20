import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitquest/widgets/popup_log.dart';               // Quick-action modal helper
import 'package:fitquest/screens/barcode_scanner_page.dart';  // Barcode scanner screen
import 'package:fitquest/screens/workout_selection.dart';     // Workout selection screen
import 'package:fitquest/widgets/circle_progress_indicator.dart'; // Circular progress widget
import 'package:fitquest/screens/calendar_page.dart';         // Calendar view
import 'package:fitquest/widgets/weekly_chart.dart';          // Weekly chart widget
import 'package:fitquest/screens/profile_page.dart';          // Profile page

class MainPageDesign extends StatefulWidget {
  const MainPageDesign({super.key});

  @override
  State<MainPageDesign> createState() => _MainPageDesignState();
}

class _MainPageDesignState extends State<MainPageDesign> {
  int _calories = 0;                   // Current calorie count
  int _dailyGoal = 2000;               // Daily calorie goal default
  final List<String> dailyWorkouts = [];  // Workouts logged today

  // Meals logged with name and calories
  final List<Map<String, dynamic>> dailyMeals = [];

  @override
  void initState() {
    super.initState();
    loadDailyGoal();
  }

  Future<void> loadDailyGoal() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getDouble('maintenance')?.round();
    if (saved != null) {
      setState(() => _dailyGoal = saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (_calories / _dailyGoal).clamp(0.0, 1.0);

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
                  backgroundColor: theme
                      .colorScheme.onSurface
                      .withAlpha((0.1 * 255).round()),
                  progressColor: Colors.greenAccent,
                  label: '$_calories / $_dailyGoal cal',
                ),
              ),
              const SizedBox(height: 24),

              // Quick Log button
              ElevatedButton.icon(
                onPressed: () async {
                  final action = await showQuickActionModal(context);
                  if (action == QuickAction.scanBarcode) {
                    final product = await Navigator.push<Map<String, dynamic>>(
                      context,
                      MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
                    );
                    if (product != null) {
                      setState(() {
                        dailyMeals.add(product);
                        _calories += product['calories'] as int;
                      });
                    }
                  } else if (action == QuickAction.selectWorkout) {
                    final workout = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(builder: (_) => const WorkoutSelectionPage()),
                    );
                    if (workout != null) setState(() => dailyWorkouts.add(workout));
                  }
                },
                icon: const Icon(Icons.flash_on),
                label: const Text('Quick Log'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),

              // Updated weekly chart
              Text('Weekly Progress', style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: WeeklyCaloriesChart(
                  dailyCalories: [
                    for (int i = 0; i < 7; i++)
                      i == DateTime
                          .now()
                          .weekday - 1
                          ? dailyMeals.fold<double>(
                        0,
                            (sum, m) => sum + (m['calories'] as int).toDouble(),
                      )
                          : 0,
                  ],
                  dailyGoal: _dailyGoal.toDouble(),
                ),
              ),
              const SizedBox(height: 16),

              // Today's entries list
              Text('Today’s Entries', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              if (dailyWorkouts.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Text('Workouts', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                for (var w in dailyWorkouts)
                  ListTile(
                    leading: const Icon(Icons.fitness_center),
                    title: Text(w),
                  ),
                const Divider(),
              ],
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Text('Meals', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              for (var meal in dailyMeals)
                ListTile(
                  leading: const Icon(Icons.restaurant_menu),
                  title: Text(meal['name'] as String),
                  trailing: Text('${meal['calories']} cal'),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      // Bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today),
              label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: 0,
        onTap: (index) async {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CalendarPage()),
            );
            // Profile Page By Aidan Lawall
          } else if (index == 2) {
            final result = await Navigator.push<int>(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            );
            if (result != null) {
              setState(() => _dailyGoal = result);
            }
          }
        },
      ),
    );
  }
}
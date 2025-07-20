import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// By Aidan Lawall

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController tabController;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController heightController = TextEditingController(); // in cm
  final TextEditingController weightController = TextEditingController(); // in kg
  final TextEditingController ageController = TextEditingController();    // in years

  String gender = 'male'; // Default value
  double? maintenanceCalories;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    loadProfile();
  }

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nameController.text = prefs.getString('name') ?? '';
      heightController.text = prefs.getDouble('height')?.toString() ?? '';
      weightController.text = prefs.getDouble('weight')?.toString() ?? '';
      ageController.text = prefs.getInt('age')?.toString() ?? '';
      gender = prefs.getString('gender') ?? 'male';
      maintenanceCalories = prefs.getDouble('maintenance');
    });
  }
// Based on Mifflin–St formula 
  Future<void> calculateMaintenanceCalories() async {
    final height = double.tryParse(heightController.text);
    final weight = double.tryParse(weightController.text);
    final age = int.tryParse(ageController.text);

    if (height != null && weight != null && age != null) {
      final bmr = gender == 'male'
          ? (10 * weight) + (6.25 * height) - (5 * age) + 5
          : (10 * weight) + (6.25 * height) - (5 * age) - 161;

      final mCal = bmr * 1.55; // Moderate activity
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', nameController.text);
      await prefs.setDouble('height', height);
      await prefs.setDouble('weight', weight);
      await prefs.setInt('age', age);
      await prefs.setString('gender', gender);
      await prefs.setDouble('maintenance', mCal);

      setState(() {
        maintenanceCalories = mCal;
      });
      Navigator.pop(context, mCal.round());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: "Info"),
            Tab(text: "Result"),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Name"),
                  ),
                  TextField(
                    controller: ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Age (years)"),
                  ),
                  TextField(
                    controller: heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Height (cm)"),
                  ),
                  TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Weight (kg)"),
                  ),
                  const SizedBox(height: 16),

                  // Gender selection
                  Row(
                    children: [
                      const Text("Gender: "),
                      const SizedBox(width: 35),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<String>(
                            value: 'male',
                            groupValue: gender,
                            onChanged: (value) => setState(() => gender = value!),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: const Text('Female'),
                          leading: Radio<String>(
                            value: 'female',
                            groupValue: gender,
                            onChanged: (value) => setState(() => gender = value!),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: calculateMaintenanceCalories,
                    child: const Text("Save and Return"),
                  ),
                ],
              ),
            ),
          ),

          // Result tab
          Center(
            child: maintenanceCalories == null
                ? const Text("Enter your info to calculate")
                : Text(
              "Your estimated daily maintenance calories:\n${maintenanceCalories!.round()} kcal",
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class WorkoutSelectionPage extends StatelessWidget {
  const WorkoutSelectionPage({Key? key}) : super(key: key);

  static const List<String> commonWorkouts = [
    'Push‑ups',
    'Squats',
    'Lunges',
    'Plank',
    'Burpees',
    'Sit‑ups',
    'Jumping Jacks',
    'Pull‑ups',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select a Workout')),
      body: ListView.builder(
        itemCount: commonWorkouts.length,
        itemBuilder: (ctx, i) {
          final workout = commonWorkouts[i];
          return ListTile(
            leading: const Icon(Icons.fitness_center),
            title: Text(workout),
            onTap: () => Navigator.of(context).pop(workout),
          );
        },
      ),
    );
  }
}

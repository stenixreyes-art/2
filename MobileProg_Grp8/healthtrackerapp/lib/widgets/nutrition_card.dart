import 'package:flutter/material.dart';

class NutritionCard extends StatelessWidget {
  final String title;
  final String value;

  const NutritionCard({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(value),
      ),
    );
  }
}
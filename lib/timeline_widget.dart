import 'package:flutter/material.dart';

class TimelineWidget extends StatelessWidget {
  final String title;
  final List steps;
  final Function(int) onTap;

  const TimelineWidget({
    required this.title,
    required this.steps,
    required this.onTap,
  });

  bool isClickable(List steps, int index) {
    if (index == 0) return true;
    return steps[index - 1]['completed'];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(12),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            ...steps.asMap().entries.map((entry) {
              int i = entry.key;
              var step = entry.value;

              final clickable = isClickable(steps, i);

              return Opacity(
                opacity: clickable ? 1 : 0.4,
                child: Row(
                  children: [
                    Column(
                      children: [
                        Icon(
                          step['completed']
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: step['completed']
                              ? Colors.green
                              : Colors.grey,
                        ),
                        Container(height: 40, width: 2, color: Colors.grey)
                      ],
                    ),
                    Expanded(
                      child: ListTile(
                        title: Text(step['name']),
                        subtitle: Text(step['date'] ?? ""),
                        onTap: clickable ? () => onTap(i) : null,
                      ),
                    )
                  ],
                ),
              );
            })
          ],
        ),
      ),
    );
  }
}
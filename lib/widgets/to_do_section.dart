import 'package:flutter/material.dart';
import 'package:moodlog/widgets/to_do_card.dart';
import '../models/weekly_to_do.dart';

class TodoSection extends StatefulWidget {
  final List<WeeklyTodo> weeklyTodos;

  const TodoSection({Key? key, required this.weeklyTodos}) : super(key: key);

  @override
  _TodoSectionState createState() => _TodoSectionState();
}

class _TodoSectionState extends State<TodoSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Today's TO-DO List
        const Text(
          "Today’s TO-DO - Tuesday, October 10",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 8),
        ...widget.weeklyTodos[0].tasks.map((task) {
          return TodoCard(
            title: task.title,
            description: task.description,
            url: task.url,
            thumbnailUrl: task.thumbnailUrl,
            duration: task.duration,
            category: task.category,
            tags: task.tags,
            isCompleted: task.isCompleted,
            onCheckboxChanged: (value) {
              setState(() {
                task.isCompleted = value ?? false;
              });
            },
          );
        }).toList(),

        const SizedBox(height: 16),

        // Weekly TO-DO List
        ExpansionTile(
          title: const Text(
            "TO-DO for the Week",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          children: widget.weeklyTodos.map((weeklyTodo) {
            return ExpansionTile(
              title: Text(
                weeklyTodo.day,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              children: weeklyTodo.tasks.map((task) {
                return TodoCard(
                  title: task.title,
                  description: task.description,
                  url: task.url,
                  thumbnailUrl: task.thumbnailUrl,
                  duration: task.duration,
                  category: task.category,
                  tags: task.tags,
                  isCompleted: task.isCompleted,
                  onCheckboxChanged: (value) {
                    setState(() {
                      task.isCompleted = value ?? false;
                    });
                  },
                );
              }).toList(),
            );
          }).toList(),
        ),
      ],
    );
  }
}
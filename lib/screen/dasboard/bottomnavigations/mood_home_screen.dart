import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moodlog/models/mood_log_models.dart';

import '../../../database/database_helper.dart';
import '../../../utils/const_files.dart';
import '../../../widgets/buildBulletPoint.dart';
import '../../../widgets/buildMoodEntry.dart';
import '../../../widgets/to_do_section.dart';
import '../../../widgets/todo.dart';
import '../mood_selection_screen.dart';

class MoodHomeScreen extends StatelessWidget {
  const MoodHomeScreen({Key? key}) : super(key: key);



  // ✅ Function to handle mood selection
  void _onMoodTap(BuildContext context, String time, List<Map<String, dynamic>> moodLogs) async {
    // ✅ Check if a mood is already logged for this time
    final existingMood = moodLogs.firstWhere(
          (log) => log['selectedTime'] == time,
      orElse: () => {},
    );

    if (existingMood.isNotEmpty) {
      // ❌ Show Alert: Mood is already logged
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Already Logged"),
          content: const Text("You have already logged a mood for this time. You cannot enter again."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return; // ✅ Stop execution
    }

    // ✅ Check if time is still selectable
    if (isTimeSelectable(time)) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MoodSelectionScreen(selectedTime: time),
        ),
      );

      // ✅ Refresh UI after returning from MoodSelectionScreen
      if (result == true) {
        (context as Element).markNeedsBuild(); // ✅ Forces FutureBuilder to rebuild
      }
    } else {
      // ❌ Show Alert: Time expired
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Time Restriction"),
          content: const Text("You can't select mood for this time. Time limit exceeded!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }




  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchMoodLogsForToday(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error loading mood data!"));
        } else {
          final List<Map<String, dynamic>> moodLogs = snapshot.data ?? [];
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mood Today and Date
                const Text(
                  "Mood Today",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Text(
                  DateFormat('MMMM d, y').format(DateTime.now()),
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 16),

                // Mood Cards
                buildMoodCardWithData(moodLogs, "7 AM", context),
                buildMoodCardWithData(moodLogs, "2 PM", context),
                buildMoodCardWithData(moodLogs, "8 PM", context),

                const SizedBox(height: 16),

                // New TO-DO Section
                TodoSection(weeklyTodos: getDummyWeeklyTodos()),

                const SizedBox(height: 24),

                // Objectives Card
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: ExpandableCard(
                    title: "Objectives",
                    items: [
                      "Discover what impacts your emotions.",
                      "Track and measure daily stress.",
                      "Get tailored tips using open APIs.",
                      "Understand your mood patterns.",
                      "Promote healthier habits for the mind."
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        }
      },
    );
  }

  // ✅ **Fetch Mood Logs for Today (Convert to Map)**
  Future<List<Map<String, dynamic>>> fetchMoodLogsForToday() async {
    final String today = DateTime.now().toIso8601String().split('T')[0];
    List<MoodLog> moodLogs = await DatabaseHelper.instance.getMoodsByDate(today);
    print("here");
    print(moodLogs.toString());
    return moodLogs.map((mood) => mood.toMap()).toList(); // ✅ Convert MoodLog to Map
  }

  // ✅ **Modify `buildMoodCardWithData()`**
  Widget buildMoodCardWithData(List<Map<String, dynamic>> moodLogs, String time, BuildContext context) {
    final moodLog = moodLogs.firstWhere(
          (log) => log['selectedTime'] == time,
      orElse: () => {},
    );

    if (moodLog.isNotEmpty) {
      // ✅ Mood Logged: Display Mood Title + Emoji
      String mood = moodLog['mood'];
      int intensity = moodLog['intensityLevel'];
      String emoji = getEmojiForMood(mood, intensity);
      String moodTitle = getMoodTitle(mood, intensity); // ✅ Get mood title

      return buildMoodCard(
        context: context, // ✅ Pass context explicitly
        time: time,
        faceColor: Colors.green,
        icon: emoji,
        isLogged: true,
        moodTitle: moodTitle, // ✅ Pass mood title
        onTap: () => _onMoodTap(context, time, moodLogs),
        showArrow: isTimeSelectable(time), // ✅ Pass condition for arrow visibility
        isSelectable: isTimeSelectable(time), // ✅ Pass condition for time selectability
      );
    } else {
      // ✅ No Mood Logged: Check if time is valid for logging
      return Opacity(
        opacity: isTimeSelectable(time) ? 1.0 : 0.5, // Reduce opacity if time is not selectable
        child: buildMoodCard(
          context: context, // ✅ Pass context explicitly
          time: time,
          faceColor: isTimeSelectable(time) ? Colors.grey : Colors.grey[300] ?? Colors.grey, // Provide fallback color
          icon: isTimeSelectable(time) ? Icons.add : Icons.hourglass_empty, // 🕒 Expired icon
          isLogged: false,
          onTap: () => _onMoodTap(context, time, moodLogs),
          showArrow: isTimeSelectable(time), // ✅ Pass condition for arrow visibility
          isSelectable: isTimeSelectable(time), // ✅ Pass condition for time selectability
        ),
      );
    }
  }  // ✅ **Function to Get Emoji Based on Mood & Intensity**
  String getEmojiForMood(String mood, int intensity) {
    if (moodLevels.containsKey(mood)) {
      return moodLevels[mood]![intensity - 1]["emoji"] ?? "❓";
    }
    return "❓";
  }

  String getMoodTitle(String mood, int intensity) {
    if (moodLevels.containsKey(mood)) {
      return moodLevels[mood]![intensity - 1]["title"] ?? "Unknown Mood";
    }
    return "Unknown Mood";
  }
}

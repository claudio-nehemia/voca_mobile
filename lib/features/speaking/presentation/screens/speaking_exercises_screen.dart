import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_theme.dart';
import '../providers/speaking_provider.dart';
import 'speaking_detail_screen.dart';

import '../../../../core/widgets/main_bottom_nav.dart';

class SpeakingExercisesScreen extends StatefulWidget {
  const SpeakingExercisesScreen({super.key});

  @override
  State<SpeakingExercisesScreen> createState() => _SpeakingExercisesScreenState();
}

class _SpeakingExercisesScreenState extends State<SpeakingExercisesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<SpeakingProvider>().fetchSpeakings());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.deepOrange[100],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.mic, color: Colors.deepOrange[400], size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Speaking Exercises",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  "${context.watch<SpeakingProvider>().exercises.length} exercises",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MainBottomNav(selectedIndex: 2),
      body: Consumer<SpeakingProvider>(

        builder: (context, provider, child) {
          if (provider.isFetching) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.exercises.isEmpty) {
            return const Center(child: Text("No speaking exercises available."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.exercises.length,
            itemBuilder: (context, index) {
              final speaking = provider.exercises[index];
              return _buildSpeakingCard(speaking);
            },
          );
        },
      ),
    );
  }

  Widget _buildSpeakingCard(dynamic speaking) {
    IconData icon;
    Color iconBgColor = const Color(0xFFE0F2F1); // Light teal
    Color iconColor = const Color(0xFF009688);   // Teal

    switch (speaking.jenisName) {
      case 'Discussion':
        icon = Icons.groups;
        break;
      case 'Story & Scene':
        icon = Icons.auto_stories;
        break;
      default:
        icon = Icons.chat_bubble;
    }

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SpeakingDetailScreen(speaking: speaking),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.teal[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      speaking.jenisName,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.teal[300],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    speaking.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    speaking.instruction,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange[300], size: 16),
                    Text(
                      " ${speaking.point}",
                      style: TextStyle(
                        color: Colors.orange[400],
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (speaking.isDone)
                  const Icon(Icons.check_circle, color: Colors.green, size: 20)
                else
                  const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

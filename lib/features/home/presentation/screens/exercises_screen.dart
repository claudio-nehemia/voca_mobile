import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/widgets/main_bottom_nav.dart';
import '../../../writing/presentation/screens/writing_exercises_screen.dart';
import '../../../speaking/presentation/screens/speaking_exercises_screen.dart';
import '../providers/exercise_provider.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExerciseProvider>().fetchExerciseStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Consumer<ExerciseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.overallStats == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchExerciseStats(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Text(
                    'Exercises',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const Text(
                    'Practice your English skills',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.lightTextColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  _buildExerciseCard(
                    title: 'Writing Exercises',
                    description: 'Practice writing with guided, independent, and experience tasks',
                    icon: Icons.edit_document,
                    color: Colors.blue[50]!,
                    iconColor: Colors.blue,
                    count: provider.writingStats?.totalExercises ?? 0,
                    points: provider.writingStats?.totalPoints ?? 0,
                    onTap: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => const WritingExercisesScreen()));
                      provider.fetchExerciseStats();
                    },
                  ),
                  
                  const SizedBox(height: 16),

                  _buildExerciseCard(
                    title: 'Speaking Exercises',
                    description: 'Improve pronunciation with Q&A, discussions, and storytelling',
                    icon: Icons.mic,
                    color: Colors.orange[50]!,
                    iconColor: Colors.orange,
                    count: provider.speakingStats?.totalExercises ?? 0,
                    points: provider.speakingStats?.totalPoints ?? 0,
                    onTap: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => const SpeakingExercisesScreen()));
                      provider.fetchExerciseStats();
                    },
                  ),

                  const SizedBox(height: 40),
                  
                  _buildStatsSection(provider.overallStats),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const MainBottomNav(selectedIndex: 2),
    );
  }

  Widget _buildExerciseCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required int count,
    required int points,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        '$count exercises',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.stars, color: Colors.orange[300], size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '$points pts',
                        style: TextStyle(color: Colors.orange[400], fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(OverallStats? stats) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9).withOpacity(0.5),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
               Icon(Icons.bar_chart, color: Colors.blueGrey),
               SizedBox(width: 8),
               Text(
                'Exercise Stats',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(stats?.totalCompleted.toString() ?? '0', 'Completed', Colors.teal),
              _buildStatItem(stats?.totalExercises.toString() ?? '0', 'Total', Colors.blue),
              _buildStatItem(stats?.totalPointsEarned.toString() ?? '0', 'Points Earned', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/writing_provider.dart';
import '../../../../core/constants/app_theme.dart';
import 'writing_detail_screen.dart';

import '../../../../core/widgets/main_bottom_nav.dart';

class WritingExercisesScreen extends StatefulWidget {
  const WritingExercisesScreen({super.key});

  @override
  State<WritingExercisesScreen> createState() => _WritingExercisesScreenState();
}

class _WritingExercisesScreenState extends State<WritingExercisesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<WritingProvider>().fetchWritings());
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Consumer<WritingProvider>(
          builder: (context, provider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Writing Exercises',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${provider.exercises.length} exercises',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const MainBottomNav(selectedIndex: 2),
      body: Consumer<WritingProvider>(

        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.exercises.isEmpty) {
            return const Center(child: Text('No writing exercises available.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: provider.exercises.length,
            itemBuilder: (context, index) {
              final exercise = provider.exercises[index];
              return _buildWritingCard(exercise);
            },
          );
        },
      ),
    );
  }

  Widget _buildWritingCard(dynamic exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WritingDetailScreen(exercise: exercise),
              ),
            );
            // Refresh counts if needed, though provider handles local update.
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: exercise.isDone ? Colors.green.withOpacity(0.1) : AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    exercise.isDone ? Icons.check_circle : Icons.edit,
                    color: exercise.isDone ? Colors.green : AppTheme.primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          exercise.themeName,
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        exercise.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exercise.instruction,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.lightTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orangeAccent, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${exercise.point}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orangeAccent,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.chevron_right, color: AppTheme.lightTextColor),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

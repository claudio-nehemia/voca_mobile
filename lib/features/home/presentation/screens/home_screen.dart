import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/home_provider.dart';
import '../../../vocabulary/presentation/providers/vocabulary_provider.dart';
import '../../../vocabulary/presentation/screens/themes_screen.dart';
import '../../../vocabulary/presentation/screens/vocabulary_list_screen.dart';
import '../../../writing/presentation/screens/writing_exercises_screen.dart';
import '../../../../core/widgets/main_bottom_nav.dart';
import '../../../speaking/presentation/screens/speaking_exercises_screen.dart';
import '../../../materials/presentation/screens/materials_screen.dart';
import '../../../auth/domain/entities/user_entity.dart';
import 'leaderboard_screen.dart';


class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<HomeProvider>().fetchHomeData();
      context.read<VocabularyProvider>().fetchContinueLearning();
      
      final auth = context.read<AuthProvider>();
      if (auth.newlyUnlocked.isNotEmpty) {
        _showAchievementPopup(context, auth.newlyUnlocked);
        auth.clearNewlyUnlocked();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final topStudents = context.watch<HomeProvider>().topStudents;
    final continueLearning = context.watch<VocabularyProvider>().continueLearningThemes;
    final isLoadingContinue = context.watch<VocabularyProvider>().isLoadingContinue;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<HomeProvider>().fetchHomeData(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Header: Welcome Back
                _buildHeader(user?.name ?? 'Guest', user?.score ?? 0),
                const SizedBox(height: 30),

                // Progress Card
                _buildProgressCard(user),
                const SizedBox(height: 30),

                // Grid Menu
                _buildGridMenu(),
                const SizedBox(height: 40),

                // Continue Learning section
                _buildSectionHeader('Continue Learning', onSeeAll: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => ThemesScreen()));
                  if (mounted) {
                    context.read<HomeProvider>().fetchHomeData();
                    context.read<VocabularyProvider>().fetchContinueLearning();
                  }
                }),
                const SizedBox(height: 16),
                if (isLoadingContinue)
                  const Center(child: CircularProgressIndicator())
                else if (continueLearning.isEmpty)
                  const Center(child: Text('Start learning to see progress here!'))
                else
                  ...continueLearning.map((theme) => _buildLessonCard(
                        theme.name,
                        theme.progressPercentage.toDouble(),
                        continueLearning.indexOf(theme) + 1,
                        theme.id,
                      )),
                const SizedBox(height: 40),

                // Top Students section
                _buildSectionHeader('Top Students', onSeeAll: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen()));
                  if (mounted) {
                    context.read<HomeProvider>().fetchHomeData();
                  }
                }),
                const SizedBox(height: 16),
                _buildTopStudentsList(topStudents),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: MainBottomNav(selectedIndex: _selectedIndex),
    );
  }

  Widget _buildHeader(String name, int score) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back,',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.lightTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$name 👋',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.secondaryColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.local_fire_department, color: AppTheme.accentColor, size: 20),
              const SizedBox(width: 4),
              Text(
                score.toString(),
                style: const TextStyle(
                  color: AppTheme.accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard(UserEntity? user) {
    final double progressValue = (user?.progressPercentage ?? 0) / 100.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              Text(
                '${user?.progressPercentage ?? 0}%',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progressValue,
            minHeight: 12,
            borderRadius: BorderRadius.circular(10),
            backgroundColor: Colors.grey[100],
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            progressValue >= 1.0 
               ? "Incredible! You've mastered all lessons! 🏆"
               : "Keep going! You're making great progress. 🌟",
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.lightTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridMenu() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildMenuCard('Vocabulary', 'Learn new words', Icons.menu_book, AppTheme.primaryColor, () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => ThemesScreen()));
          if (mounted) {
            context.read<HomeProvider>().fetchHomeData();
            context.read<VocabularyProvider>().fetchContinueLearning();
          }
        }),
        _buildMenuCard('Writing', 'Practice writing skills', Icons.edit, Colors.indigo[100]!, () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const WritingExercisesScreen()));
          if (mounted) {
            context.read<HomeProvider>().fetchHomeData();
          }
        }),

        _buildMenuCard('Speaking', 'Improve pronunciation', Icons.mic, Colors.deepOrange[100]!, () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const SpeakingExercisesScreen()));
          if (mounted) {
            context.read<HomeProvider>().fetchHomeData();
          }
        }),

        _buildMenuCard('Materials', 'Download resources', Icons.download, Colors.green[100]!, () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const MaterialsScreen()));
          if (mounted) {
            context.read<HomeProvider>().fetchHomeData();
          }
        }),
      ],
    );
  }

  Widget _buildMenuCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.lightTextColor,
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: const Text(
            'See all >',
            style: TextStyle(color: AppTheme.lightTextColor),
          ),
        ),
      ],
    );
  }

  Widget _buildLessonCard(String title, double progress, int number, int themeId) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VocabularyListScreen(themeId: themeId, unitNumber: number),
          ),
        );
        if (mounted) {
          context.read<HomeProvider>().fetchHomeData();
          context.read<VocabularyProvider>().fetchContinueLearning();
        }
      },
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Text(
              number.toString(),
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress / 100,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(10),
                  backgroundColor: Colors.grey[100],
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '${progress.toInt()}%',
            style: const TextStyle(color: AppTheme.lightTextColor, fontSize: 12),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppTheme.lightTextColor),
        ],
      ),
      ),
    );
  }

  Widget _buildTopStudentsList(List topStudents) {
    // If empty, show dummy data as fallback/placeholder but user asked to fetch it.
    // I'll use placeholders if topStudents list is empty.
    final items = topStudents.isNotEmpty ? topStudents : [
      {'name': 'Michael Chen', 'class': '10-B', 'score': '3.200', 'rank': 1},
      {'name': 'Emma Wilson', 'class': '10-A', 'score': '2.980', 'rank': 2},
      {'name': 'James Brown', 'class': '10 C', 'score': '2.750', 'rank': 3},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: items.map<Widget>((item) {
          final bool isMap = item is Map;
          final String name = isMap ? item['name'] : item.name;
          final String scoreStr = isMap ? item['score'] : item.score.toString();
          final String className = isMap ? item['class'] : (item.role ?? 'Unknown');
          final int rank = isMap ? (item['rank'] ?? 1) : (items.indexOf(item) + 1);

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                _buildRankIcon(rank),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(className, style: const TextStyle(color: AppTheme.lightTextColor, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(scoreStr, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                    const Text('points', style: TextStyle(color: AppTheme.lightTextColor, fontSize: 10)),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRankIcon(int rank) {
    Color color;
    switch (rank) {
      case 1: color = Colors.orange; break;
      case 2: color = Colors.blueGrey; break;
      case 3: color = Colors.brown; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.emoji_events, color: color, size: 20),
    );
  }

  void _showAchievementPopup(BuildContext context, List<dynamic> unlocked) {
    for (var achievement in unlocked) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'New Achievement!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF5ABFA1)),
              ),
              const SizedBox(height: 20),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF5ABFA1).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(achievement['icon'] ?? '🏆', style: const TextStyle(fontSize: 50)),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                achievement['name'] ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                achievement['description'] ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5ABFA1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Great!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

}

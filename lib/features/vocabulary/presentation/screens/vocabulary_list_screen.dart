import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../providers/vocabulary_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/constants/app_theme.dart';

import '../../../../core/widgets/main_bottom_nav.dart';

class VocabularyListScreen extends StatefulWidget {
  final int themeId;
  final int unitNumber;

  const VocabularyListScreen({
    super.key,
    required this.themeId,
    required this.unitNumber,
  });

  @override
  State<VocabularyListScreen> createState() => _VocabularyListScreenState();
}

class _VocabularyListScreenState extends State<VocabularyListScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  int? _currentlyPlayingVocabId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<VocabularyProvider>().fetchVocabularies(widget.themeId));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _playAudio(int id, String? url) async {
    if (url == null || url.isEmpty) return;

    if (_audioPlayer.state == PlayerState.playing && _currentlyPlayingVocabId == id) {
      await _audioPlayer.stop();
      setState(() {
        _currentlyPlayingVocabId = null;
      });
    } else {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
      setState(() {
        _currentlyPlayingVocabId = id;
      });
    }

    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _currentlyPlayingVocabId = null;
        });
      }
    });
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
        title: Consumer<VocabularyProvider>(
          builder: (context, provider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unit ${widget.unitNumber}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Text(
                  provider.currentThemeName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const MainBottomNav(selectedIndex: 1),
      body: Consumer<VocabularyProvider>(

        builder: (context, provider, child) {
          if (provider.isLoadingVocabularies) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredVocabs = provider.vocabularies.where((v) {
            return v.title.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search words...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              // List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: filteredVocabs.length,
                  itemBuilder: (context, index) {
                    final vocab = filteredVocabs[index];
                    return _buildVocabCard(vocab);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVocabCard(dynamic vocab) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: vocab.isLearned 
            ? AppTheme.primaryColor.withOpacity(0.05) 
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: vocab.isLearned 
              ? AppTheme.primaryColor.withOpacity(0.2) 
              : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 60), // Space for icons
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        vocab.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (vocab.isLearned) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          '✓ Learned',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    Text(
                      '+${vocab.point} pts',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  vocab.goals,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.description_outlined, size: 16, color: AppTheme.primaryColor),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        vocab.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => _playAudio(vocab.id, vocab.audioUrl),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: _currentlyPlayingVocabId == vocab.id
                            ? AppTheme.primaryColor
                            : AppTheme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle),
                    child: Icon(
                      _currentlyPlayingVocabId == vocab.id
                          ? Icons.stop
                          : Icons.volume_up,
                      color: _currentlyPlayingVocabId == vocab.id
                          ? Colors.white
                          : AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: vocab.isLearned 
                      ? null 
                      : () async {
                          final success = await context.read<VocabularyProvider>().completeVocabulary(vocab.id);
                          if (success) {
                            if (mounted) {
                              final auth = context.read<AuthProvider>();
                              await auth.fetchUser();
                              if (mounted && auth.newlyUnlocked.isNotEmpty) {
                                _showAchievementPopup(context, auth.newlyUnlocked);
                                auth.clearNewlyUnlocked();
                              }
                            }
                          }
                        },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: vocab.isLearned ? Colors.green : Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: vocab.isLearned ? Colors.white : Colors.grey[400],
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

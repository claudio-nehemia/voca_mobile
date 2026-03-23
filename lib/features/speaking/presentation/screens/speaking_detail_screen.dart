import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../domain/entities/speaking_entity.dart';
import '../providers/speaking_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SpeakingDetailScreen extends StatefulWidget {
  final SpeakingEntity speaking;

  const SpeakingDetailScreen({super.key, required this.speaking});

  @override
  State<SpeakingDetailScreen> createState() => _SpeakingDetailScreenState();
}

class _SpeakingDetailScreenState extends State<SpeakingDetailScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playRecording(String path) async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      setState(() => _isPlaying = false);
    } else {
      await _audioPlayer.play(DeviceFileSource(path));
      setState(() => _isPlaying = true);
      _audioPlayer.onPlayerComplete.listen((_) {
        setState(() => _isPlaying = false);
      });
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return "$minutes:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              widget.speaking.jenisName,
              style: const TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.speaking.title,
              style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Consumer<SpeakingProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildInstructionCard(),
                const SizedBox(height: 24),
                _buildRecorderCard(provider),
                const SizedBox(height: 24),
                _buildTipsCard(),
                const SizedBox(height: 40),
                if (provider.recordedPath != null && !provider.isRecording)
                  _buildSubmitButton(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Task Instructions",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Text(
            widget.speaking.instruction,
            style: const TextStyle(color: Colors.grey, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildRecorderCard(SpeakingProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            "Record Your Response",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: () {
              if (provider.recordedPath != null && !provider.isRecording) {
                _playRecording(provider.recordedPath!);
              }
            },
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    provider.isRecording ? Icons.mic : (provider.recordedPath != null ? (_isPlaying ? Icons.stop : Icons.play_arrow) : Icons.mic_none),
                    color: Colors.blue[300],
                    size: 40,
                  ),
                  if (provider.isRecording)
                    const SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.blue,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _formatDuration(provider.recordDuration),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          if (!provider.isRecording)
            ElevatedButton.icon(
              onPressed: () {
                if (provider.isRecording) {
                  provider.stopRecording();
                } else {
                  provider.startRecording();
                }
              },
              icon: const Icon(Icons.mic, color: Colors.white),
              label: Text(provider.recordedPath != null ? "Record Again" : "Start Recording"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF64D2C1), // Teal from SS
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: () => provider.stopRecording(),
              icon: const Icon(Icons.stop, color: Colors.white),
              label: const Text("Stop Recording"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[300],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.orange[300]),
              const SizedBox(width: 8),
              const Text("Speaking Tips", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          const Text("• Speak clearly and at a moderate pace", style: TextStyle(color: Colors.grey, fontSize: 13)),
          const Text("• Use vocabulary from your lessons", style: TextStyle(color: Colors.grey, fontSize: 13)),
          const Text("• Don't be afraid to make mistakes!", style: TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(SpeakingProvider provider) {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: provider.isSubmitting
            ? null
            : () async {
                final success = await provider.submitAnswer(widget.speaking.id);
                if (success) {
                  // Update score in AuthProvider
                  final auth = context.read<AuthProvider>();
                  await auth.fetchUser();
                  
                  if (mounted && auth.newlyUnlocked.isNotEmpty) {
                    await _showAchievementPopup(context, auth.newlyUnlocked);
                    auth.clearNewlyUnlocked();
                  }

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Jawaban berhasil dikirim!")),
                    );
                    Navigator.pop(context);
                  }
                }
              },
        child: provider.isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Submit Recording", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Future<void> _showAchievementPopup(BuildContext context, List<dynamic> unlocked) async {
    for (var achievement in unlocked) {
      await showDialog(
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

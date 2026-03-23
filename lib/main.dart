import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/home/presentation/providers/home_provider.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/vocabulary/data/repositories/vocabulary_repository_impl.dart';
import 'features/vocabulary/presentation/providers/vocabulary_provider.dart';
import 'features/writing/data/repositories/writing_repository_impl.dart';
import 'features/writing/presentation/providers/writing_provider.dart';
import 'features/speaking/data/repositories/speaking_repository_impl.dart';
import 'features/speaking/presentation/providers/speaking_provider.dart';
import 'features/materials/presentation/providers/materials_provider.dart';
import 'features/home/presentation/providers/exercise_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load .env file
  await dotenv.load(fileName: ".env");

  // Dependency injection
  final apiClient = ApiClient();
  final tokenStorage = TokenStorage();
  final authRepository = AuthRepositoryImpl(apiClient);
  final vocabularyRepository = VocabularyRepositoryImpl(apiClient);
  final writingRepository = WritingRepositoryImpl(apiClient);
  final speakingRepository = SpeakingRepositoryImpl(apiClient);


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository, tokenStorage, apiClient)..checkStatus(),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeProvider(apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => VocabularyProvider(vocabularyRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => WritingProvider(writingRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => SpeakingProvider(speakingRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => MaterialsProvider(apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => ExerciseProvider(apiClient),
        ),
      ],

      child: const VocaMateApp(),
    ),
  );
}

class VocaMateApp extends StatelessWidget {
  const VocaMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voca-Mate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.status == AuthStatus.loading && auth.currentUser == null) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              ),
            );
          }

          if (auth.status == AuthStatus.authenticated) {
            return const HomeScreen();
          }

          return const LoginScreen();
        },
      ),
    );
  }
}

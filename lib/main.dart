import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/audio/audio_controller.dart';
import 'core/constants/app_constants.dart';
import 'core/navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Lock screen orientation to Landscape (Left and Right)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // 2. Hide system status bar for immersive full-screen retro gaming
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );

  // 3. Initialize Audio Controller (Settings & Preloads)
  await AudioController.instance.init();

  runApp(const CowboyCaveApp());
}

/// Root Application Widget for Cowboy Cave Adventure.
class CowboyCaveApp extends StatelessWidget {
  const CowboyCaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: AppConstants.fontFamily,
        scaffoldBackgroundColor: AppConstants.colorBackground,
        colorScheme: const ColorScheme.dark(
          primary: AppConstants.colorPrimary,
          secondary: AppConstants.colorSecondary,
          surface: AppConstants.colorSurface,
        ),
      ),
      initialRoute: AppRouter.dashboard,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}

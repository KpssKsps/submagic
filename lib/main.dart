import 'package:flutter/material.dart';
import 'package:submagic/models/security_screen.dart';
import 'package:submagic/models/theme_manager.dart';
import 'package:submagic/screens/video_selection_screen.dart';
import 'package:submagic/screens/settings_screen.dart';
import 'package:submagic/screens/video_player_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider<ThemeManager>(
      create: (_) => ThemeManager()..loadThemePreference(), // Ensure loadThemePreference is called here
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>( // Use Consumer to listen to ThemeManager
      builder: (context, themeManager, child) {
        return MaterialApp(
          title: 'Video Player App',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          darkTheme: ThemeData.dark(),
          themeMode: themeManager.themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => SecurityScreen(),
            '/videoSelection': (context) => VideoSelectionScreen(),
            '/settings': (context) => SettingsScreen(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/videoPlayer') {
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => VideoPlayerScreen(
                  videoPath: args['videoPath'],
                ),
              );
            }
            return null;
          },
        );
      },
    );
  }
}

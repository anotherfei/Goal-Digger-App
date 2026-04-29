import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'state/app_state.dart';
import 'screens/shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFF7F1E8),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const GoalDiggerApp());
}

class GoalDiggerApp extends StatelessWidget {
  const GoalDiggerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'Goal Digger',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF7F1E8),
          textTheme: GoogleFonts.interTextTheme(),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF14B8A6),
            brightness: Brightness.light,
            surface: const Color(0xFFF7F1E8),
          ),
        ),
        home: const AppShell(),
      ),
    );
  }
}

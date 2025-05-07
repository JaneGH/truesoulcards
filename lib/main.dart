import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:truesoulcards/providers/language_provider.dart';
import 'package:truesoulcards/screens/main.dart';
import 'package:flutter/services.dart';

ThemeData get lightTheme {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: const Color.fromARGB(255, 131, 57, 0),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(),
  );
}

ThemeData get darkTheme {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: const Color.fromARGB(255, 131, 57, 0),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
    if (kDebugMode) {
      print("Environment variables: ${dotenv.env}");
    }
  } catch (e) {
    if (kDebugMode) {
      print("Error loading .env file: $e");
    }
  }

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((fn){
    runApp(const ProviderScope(child: App()));
  });
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languages = ref.watch(languageProvider);
    final primaryLocale = languages['primary'] ?? 'en';

    return MaterialApp(
      title: 'My App',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      locale: Locale(primaryLocale),
      supportedLocales: const [
        Locale('en', ''),
        Locale('uk', ''),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const MainScreen(),
    );
  }
}
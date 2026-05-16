part of goal_digger;

/* -------------------------------------------------------------------------- */
/* DESIGN TOKENS                                                              */
/* -------------------------------------------------------------------------- */

const Color gdBackground = Color(0xFFF7F8FC);
const Color gdSurface = Color(0xFFFFFFFF);
const Color gdInk = Color(0xFF263247);
const Color gdMuted = Color(0xFF5F6B7A); // readable but softer secondary text
const Color gdPrimary = Color(0xFF315C9D);
const Color gdPrimaryDark = Color(0xFF496DA8);
const Color gdPrimarySoft = Color(0xFFE8F0FE);
const Color gdAccent = Color(0xFFE66A6A);
const Color gdAccentSoft = Color(0xFFFFE4E6);
const Color gdWarning = Color(0xFFC2410C);
const Color gdError = Color(0xFFDC2626);
const Color gdErrorSoft = Color(0xFFFEE2E2);
const Color gdBorder = Color(0xFFE2E8F0); // soft modern border color
const Color gdBorderStrong = Color(0xFFCBD5E1); // stronger border color
const Color gdHint = Color(0xFF64748B); // hint text color
const Color gdGradientCareerFrom = Color(0xFF06B6D4); // career gradient start
const Color gdGradientCareerTo = Color(0xFF2563EB); // career gradient end
const Color gdGradientStudyFrom = Color(0xFFF59E0B); // study gradient start
const Color gdGradientStudyTo = Color(0xFFEC4899); // study gradient end
const Color gdGradientWellnessFrom = Color(0xFFFB7185); // wellness gradient start
const Color gdGradientWellnessTo = Color(0xFFF43F5E); // wellness gradient end
const Color gdGradientFinanceFrom = Color(0xFF10B981); // finance gradient start
const Color gdGradientFinanceTo = Color(0xFF059669); // finance gradient end
const Color gdGradientCreativeFrom = Color(0xFF8B5CF6); // creative gradient start
const Color gdGradientCreativeTo = Color(0xFFD946EF); // creative gradient end
const Color gdPetMintFrom = Color(0xFF22D3EE); // pet aqua gradient start
const Color gdPetMintTo = Color(0xFF2DD4BF); // pet mint gradient end
const Color gdPetAccent = Color(0xFFEAF2FF); // high-contrast soft text on dark blue
const Color gdOnDark = Color(0xFFFFFFFF); // readable foreground on dark surfaces
const Color gdOnDarkMuted = Color(0xFFF4F7FF); // readable secondary text on soft blue surfaces
const Color gdCardLight = Color(0xFFF8FAFC); // crisp light card background
const Color gdStarGold = Color(0xFFE9A63A); // energetic star rating gold color
const double gdTouchTarget = 52;

ThemeData buildGoalDiggerTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: gdPrimary,
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: gdBackground,
    colorScheme: scheme.copyWith(
      primary: gdPrimary,
      onPrimary: Colors.white,
      secondary: gdAccent,
      onSecondary: Colors.white,
      tertiary: gdGradientCreativeFrom,
      surface: gdSurface,
      onSurface: gdInk,
      error: gdError,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      backgroundColor: gdBackground,
      foregroundColor: gdInk,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: gdInk,
        fontSize: 22,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      height: 72,
      labelTextStyle: MaterialStatePropertyAll(
        TextStyle(fontWeight: FontWeight.w800, color: gdInk),
      ),
      iconTheme: MaterialStatePropertyAll(
        IconThemeData(color: gdMuted),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: gdInk,
        fontSize: 34,
        height: 1.05,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.2,
      ),
      headlineMedium: TextStyle(
        color: gdInk,
        fontSize: 26,
        height: 1.1,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.7,
      ),
      titleLarge: TextStyle(
        color: gdInk,
        fontSize: 20,
        fontWeight: FontWeight.w900,
      ),
      titleMedium: TextStyle(
        color: gdInk,
        fontSize: 16,
        fontWeight: FontWeight.w900,
      ),
      bodyLarge: TextStyle(color: gdInk, fontSize: 16, height: 1.45),
      bodyMedium: TextStyle(color: gdInk, fontSize: 14, height: 1.4),
      bodySmall: TextStyle(color: gdMuted, fontSize: 12, height: 1.35),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: gdPrimarySoft,
      selectedColor: gdPrimary,
      labelStyle: const TextStyle(color: gdInk, fontWeight: FontWeight.w800),
      secondaryLabelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      side: BorderSide.none,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: gdSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: gdBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: gdPrimary, width: 2),
      ),
      labelStyle: const TextStyle(color: gdMuted, fontWeight: FontWeight.w700),
      hintStyle: const TextStyle(color: gdHint),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, gdTouchTarget),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, gdTouchTarget),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        side: const BorderSide(color: gdBorderStrong),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    iconTheme: const IconThemeData(color: gdPrimary),
  );
}

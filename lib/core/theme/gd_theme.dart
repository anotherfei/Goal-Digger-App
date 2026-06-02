import 'package:flutter/material.dart';

import 'gd_design.dart';

/* -------------------------------------------------------------------------- */
/*  GOAL DIGGER — THEME                                                        */
/*                                                                            */
/*  Maps the semantic design language (gd_design.dart) onto a Material 3       */
/*  ThemeData. Every value below is expressed through a colour ROLE or a       */
/*  token, so the look stays coherent and the palette can be re-tuned in one   */
/*  place. Intent:                                                             */
/*    • a calm, low-glare reading surface for focused work;                    */
/*    • blue chrome that recedes so category colour + reward gold can pop;     */
/*    • soft, generously rounded, comfortably-tappable controls;               */
/*    • a confident, legible type scale.                                       */
/* -------------------------------------------------------------------------- */

const String _fontFamily = 'PlusJakartaSans';

ThemeData buildGoalDiggerTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: GdColors.brand,
    brightness: Brightness.light,
  ).copyWith(
    primary: GdColors.brand,
    onPrimary: GdColors.onColor,
    primaryContainer: GdColors.brandSoft,
    onPrimaryContainer: GdColors.brandStrong,
    secondary: GdColors.warm,
    onSecondary: GdColors.onColor,
    secondaryContainer: GdColors.warmSoft,
    onSecondaryContainer: GdColors.ink,
    tertiary: GdColors.focus,
    onTertiary: GdColors.onColor,
    surface: GdColors.surface,
    onSurface: GdColors.ink,
    surfaceContainerHighest: GdColors.surfaceMuted,
    onSurfaceVariant: GdColors.inkMuted,
    error: GdColors.danger,
    onError: GdColors.onColor,
    errorContainer: GdColors.dangerSoft,
    outline: GdColors.borderStrong,
    outlineVariant: GdColors.border,
    shadow: GdColors.shadow,
    scrim: GdColors.scrim,
    // Disable M3's automatic surface tinting so cards stay true white/grey
    // instead of drifting toward lilac as they elevate.
    surfaceTint: Colors.transparent,
  );

  return ThemeData(
    useMaterial3: true,
    fontFamily: _fontFamily,
    scaffoldBackgroundColor: GdColors.canvas,
    colorScheme: scheme,
    splashFactory: InkSparkle.splashFactory,
    iconTheme: const IconThemeData(color: GdColors.brand),
    dividerTheme: const DividerThemeData(
      color: GdColors.border,
      thickness: 1,
      space: GdSpace.xl,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      backgroundColor: GdColors.canvas,
      surfaceTintColor: Colors.transparent,
      foregroundColor: GdColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: _fontFamily,
        color: GdColors.ink,
        fontSize: 22,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      elevation: 0,
      backgroundColor: GdColors.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: GdColors.brandSoft,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GdRadius.md),
      ),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w800,
          fontSize: 12,
          color: states.contains(WidgetState.selected)
              ? GdColors.brand
              : GdColors.inkMuted,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? GdColors.brand
              : GdColors.inkMuted,
        ),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: GdColors.ink,
        fontSize: 34,
        height: 1.05,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.2,
      ),
      headlineMedium: TextStyle(
        color: GdColors.ink,
        fontSize: 26,
        height: 1.1,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.7,
      ),
      titleLarge: TextStyle(
        color: GdColors.ink,
        fontSize: 20,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.3,
      ),
      titleMedium: TextStyle(
        color: GdColors.ink,
        fontSize: 16,
        fontWeight: FontWeight.w900,
      ),
      titleSmall: TextStyle(
        color: GdColors.ink,
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
      bodyLarge: TextStyle(color: GdColors.ink, fontSize: 16, height: 1.45),
      bodyMedium: TextStyle(color: GdColors.ink, fontSize: 14, height: 1.4),
      bodySmall: TextStyle(color: GdColors.inkMuted, fontSize: 12, height: 1.35),
      labelLarge: TextStyle(
        color: GdColors.ink,
        fontSize: 14,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.1,
      ),
      labelSmall: TextStyle(
        color: GdColors.inkMuted,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    ),
    cardTheme: CardThemeData(
      color: GdColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shadowColor: GdColors.shadow,
      shape: RoundedRectangleBorder(borderRadius: GdRadius.card),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: GdColors.brandSoft,
      selectedColor: GdColors.brand,
      disabledColor: GdColors.surfaceMuted,
      labelStyle: const TextStyle(
        color: GdColors.ink,
        fontWeight: FontWeight.w800,
        fontFamily: _fontFamily,
      ),
      secondaryLabelStyle: const TextStyle(
        color: GdColors.onColor,
        fontWeight: FontWeight.w800,
        fontFamily: _fontFamily,
      ),
      padding: const EdgeInsets.symmetric(horizontal: GdSpace.md, vertical: 6),
      shape: const StadiumBorder(),
      side: BorderSide.none,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: GdColors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: GdSpace.lg,
        vertical: GdSpace.lg,
      ),
      border: OutlineInputBorder(
        borderRadius: GdRadius.field,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: GdRadius.field,
        borderSide: const BorderSide(color: GdColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: GdRadius.field,
        borderSide: const BorderSide(color: GdColors.brand, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: GdRadius.field,
        borderSide: const BorderSide(color: GdColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: GdRadius.field,
        borderSide: const BorderSide(color: GdColors.danger, width: 2),
      ),
      labelStyle:
          const TextStyle(color: GdColors.inkMuted, fontWeight: FontWeight.w700),
      hintStyle: const TextStyle(color: GdColors.inkFaint),
      prefixIconColor: GdColors.inkMuted,
      suffixIconColor: GdColors.inkMuted,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: GdColors.brand,
        foregroundColor: GdColors.onColor,
        disabledBackgroundColor: GdColors.borderStrong,
        minimumSize: const Size(0, GdSpace.touchTarget),
        padding: const EdgeInsets.symmetric(horizontal: GdSpace.xl),
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w900,
        ),
        shape: RoundedRectangleBorder(borderRadius: GdRadius.control),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: GdColors.brand,
        minimumSize: const Size(0, GdSpace.touchTarget),
        padding: const EdgeInsets.symmetric(horizontal: GdSpace.xl),
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w900,
        ),
        side: const BorderSide(color: GdColors.borderStrong),
        shape: RoundedRectangleBorder(borderRadius: GdRadius.control),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: GdColors.brand,
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
        shape: RoundedRectangleBorder(borderRadius: GdRadius.control),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: GdColors.brand,
      foregroundColor: GdColors.onColor,
      elevation: 4,
      highlightElevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GdRadius.lg),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? GdColors.onColor
            : GdColors.surface,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? GdColors.brand
            : GdColors.borderStrong,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? GdColors.brand
            : Colors.transparent,
      ),
      checkColor: const WidgetStatePropertyAll(GdColors.onColor),
      side: const BorderSide(color: GdColors.borderStrong, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GdSpace.sm),
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: GdColors.brand,
      inactiveTrackColor: GdColors.brandSoft,
      thumbColor: GdColors.brand,
      overlayColor: GdColors.brand.withValues(alpha: 0.18),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: GdColors.brand,
      linearTrackColor: GdColors.brandSoft,
      circularTrackColor: GdColors.brandSoft,
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: GdColors.brand,
      textColor: GdColors.ink,
      titleTextStyle: TextStyle(
        fontFamily: _fontFamily,
        color: GdColors.ink,
        fontSize: 15,
        fontWeight: FontWeight.w800,
      ),
      subtitleTextStyle: TextStyle(
        fontFamily: _fontFamily,
        color: GdColors.inkMuted,
        fontSize: 13,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: GdColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GdRadius.xl),
      ),
      titleTextStyle: const TextStyle(
        fontFamily: _fontFamily,
        color: GdColors.ink,
        fontSize: 20,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.3,
      ),
      contentTextStyle: const TextStyle(
        fontFamily: _fontFamily,
        color: GdColors.inkMuted,
        fontSize: 15,
        height: 1.45,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: GdColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      showDragHandle: true,
      dragHandleColor: GdColors.borderStrong,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: GdRadius.xlRadius),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: GdColors.ink,
      contentTextStyle: const TextStyle(
        fontFamily: _fontFamily,
        color: GdColors.onColor,
        fontWeight: FontWeight.w700,
      ),
      actionTextColor: GdColors.reward,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GdRadius.md),
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: GdColors.ink,
        borderRadius: BorderRadius.circular(GdSpace.sm),
      ),
      textStyle: const TextStyle(
        fontFamily: _fontFamily,
        color: GdColors.onColor,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: GdColors.brand,
      unselectedLabelColor: GdColors.inkMuted,
      indicatorColor: GdColors.brand,
      dividerColor: Colors.transparent,
      labelStyle: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w900),
      unselectedLabelStyle:
          TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w700),
    ),
  );
}

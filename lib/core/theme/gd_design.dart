import 'package:flutter/material.dart';

/* ══════════════════════════════════════════════════════════════════════════
   GOAL DIGGER — DESIGN LANGUAGE
   ──────────────────────────────────────────────────────────────────────────
   One source of truth for how the app looks and feels. The guiding idea is
   SEMANTIC ROLES: you pick a colour by the JOB it does, never by its hue.

   Goal Digger is a gamified productivity *companion*, so the system is tuned
   to three emotional jobs, each mapped to a deliberate part of the palette:

     1. CALM FOCUS  — a quiet, low-glare base layer with high-contrast ink, so
                      deep work and focus sessions never feel stressful.
     2. TRUST       — blue carries every primary action and the app chrome.
     3. ENCOURAGE   — warm coral, achievement green and reward gold supply the
                      motivation a companion lives on.

   LIGHT + DARK
   Every role resolves at runtime from [GdColors.brightness]. The app shell
   publishes the active brightness once per build (see GoalDiggerApp), so the
   same token (e.g. GdColors.ink) returns the right value in either mode. This
   is why the tokens are getters, not consts — they must be able to change.

   HOW TO USE
     • Colour   →  GdColors.brand, GdColors.positive, GdColors.ink …
     • Space    →  GdSpace.lg          (a single 4-pt rhythm)
     • Radius   →  GdRadius.card       (soft, friendly shapes)
     • Shadow   →  GdShadows.soft      (airy, ink-tinted depth)
     • Gradient →  GdGradients.hero / GdCategory.gradientFor('Study')
   ════════════════════════════════════════════════════════════════════════ */

/// Active brightness for the whole token system. Set once per build by the app
/// shell from the resolved [ThemeData] brightness; never write it from widgets.
Brightness _gdBrightness = Brightness.light;
bool get _dark => _gdBrightness == Brightness.dark;

/// Resolve a role to its light or dark value.
Color _pick(int light, int dark) => Color(_dark ? dark : light);

/// Semantic colour roles — the heart of the system. Reach for the role whose
/// *purpose* matches your intent; never hard-code a hex value in a widget.
abstract final class GdColors {
  GdColors._();

  /// Publish the active brightness so every token getter resolves correctly.
  static void setBrightness(Brightness brightness) =>
      _gdBrightness = brightness;

  static Brightness get brightness => _gdBrightness;
  static bool get isDark => _dark;

  // ── Canvas & surfaces — the calm foundation ────────────────────────────
  /// App background. Cool and quiet so it adds no visual energy.
  static Color get canvas => _pick(0xFFF5F7FB, 0xFF0F1520);

  /// Primary card / sheet surface, lifted one step above [canvas].
  static Color get surface => _pick(0xFFFFFFFF, 0xFF19212E);

  /// Nested or secondary surface that should sit a step back from [surface].
  static Color get surfaceMuted => _pick(0xFFEFF3FA, 0xFF222C3C);

  /// Hairline dividers and resting outlines.
  static Color get border => _pick(0xFFE5EAF2, 0xFF2C3848);

  /// Stronger outline for emphasis or interactive edges.
  static Color get borderStrong => _pick(0xFFCAD4E0, 0xFF3B4859);

  // ── Content — legibility & hierarchy ────────────────────────────────────
  /// Primary text/icons. High contrast on [canvas] in either mode.
  static Color get ink => _pick(0xFF1B2638, 0xFFEAEFF7);

  /// Secondary text.
  static Color get inkMuted => _pick(0xFF566377, 0xFFA2AEC0);

  /// Placeholders, hints, decorative text.
  static Color get inkFaint => _pick(0xFF8893A4, 0xFF6E7C8E);

  /// Text/icons resting on a saturated brand/accent fill (kept white in both
  /// modes so the brand fills keep their familiar foreground).
  static Color get onColor => _pick(0xFFFFFFFF, 0xFFFFFFFF);

  /// Secondary text on a saturated or dark fill.
  static Color get onColorMuted => _pick(0xFFEAF1FF, 0xFFD6E2F5);

  // ── Brand — focus & trust (blue) ────────────────────────────────────────
  /// Primary actions and chrome. The productivity anchor. The dark tone is a
  /// touch brighter so it both reads as a foreground on dark surfaces and
  /// still carries white text on a fill.
  static Color get brand => _pick(0xFF2E5AC9, 0xFF5481E8);

  /// Pressed / hover / depth variant of [brand].
  static Color get brandStrong => _pick(0xFF1F47AC, 0xFF3D6AD9);

  /// Airy brand wash: selected states, chips, soft fills.
  static Color get brandSoft => _pick(0xFFE6EDFD, 0xFF213256);

  // ── Expressive accents — psychology-mapped ──────────────────────────────
  /// Encouragement & human warmth. Distinct from [danger].
  static Color get warm => _pick(0xFFF06A53, 0xFFF5836C);
  static Color get warmSoft => _pick(0xFFFFE7E0, 0xFF3A241E);

  /// Achievement, growth, completed work, streaks.
  static Color get positive => _pick(0xFF16A34A, 0xFF35C46E);
  static Color get positiveSoft => _pick(0xFFDCFAE6, 0xFF14301F);

  /// Caution that isn't an error.
  static Color get attention => _pick(0xFFD97706, 0xFFE8973A);
  static Color get attentionSoft => _pick(0xFFFEF1D6, 0xFF3A2A12);

  /// Errors and destructive actions only.
  static Color get danger => _pick(0xFFDC2626, 0xFFF05252);
  static Color get dangerSoft => _pick(0xFFFEE2E2, 0xFF3A1B1B);

  /// Neutral, informational messaging.
  static Color get info => _pick(0xFF0E97D9, 0xFF3FB0E8);
  static Color get infoSoft => _pick(0xFFDFF3FC, 0xFF12303C);

  /// Deep concentration — the focus-session field.
  static Color get focus => _pick(0xFF3F3DAE, 0xFF7A77E0);
  static Color get focusSoft => _pick(0xFFE8E7FB, 0xFF22214A);

  /// The reward economy: coins, stars, streak celebrations.
  static Color get reward => _pick(0xFFF2B33D, 0xFFF5C45E);

  // ── Effects ─────────────────────────────────────────────────────────────
  /// Shadow base. Ink-tinted in light; near-black in dark where depth is
  /// carried more by lighter surfaces than by shadow.
  static Color get shadow => _pick(0xFF1B2638, 0xFF000000);

  /// Modal scrim.
  static Color get scrim => _dark ? const Color(0x99000000) : const Color(0x661B2638);

  // ── Inverse surface — for elements that contrast the page (snackbars, ──────
  // tooltips, dark chips). Flips the opposite way to [surface]: dark-on-light
  // page, light-on-dark page.
  static Color get inverseSurface => _pick(0xFF1B2638, 0xFF2C3848);
  static Color get onInverse => _dark ? const Color(0xFFEAEFF7) : const Color(0xFFFFFFFF);

  // ── Colour functions ────────────────────────────────────────────────────
  /// WCAG-aware foreground. Returns dark [ink] on light fills and [onColor] on
  /// dark/saturated fills, so text laid over any category gradient or status
  /// colour stays legible without hand-tuning per screen.
  static Color onColorFor(Color background) =>
      background.computeLuminance() > 0.45 ? const Color(0xFF1B2638) : onColor;

  /// The canonical way to build a soft "tinted card" from any accent: blend the
  /// accent over [surface] at a fixed, gentle opacity instead of hand-picking a
  /// pale hex. Produces an opaque, low-saturation surface.
  static Color tintOf(Color color, [double opacity = GdAlpha.soft]) =>
      Color.alphaBlend(color.withValues(alpha: opacity), surface);

  /// A slightly stronger tint for borders/edges of a tinted surface.
  static Color edgeOf(Color color) => color.withValues(alpha: GdAlpha.muted);
}

/// The pet companion's own palette — kept friendly, fresh and identical in both
/// modes so the companion stays recognisable as its own character.
abstract final class GdPet {
  GdPet._();
  static const Color from = Color(0xFF22D3EE);
  static const Color to = Color(0xFF2DD4BF);
  static const Color accent = Color(0xFFEAF2FF);
}

/// 4-pt spacing rhythm. One scale for all padding and gaps keeps spacing
/// visually consistent across every screen.
abstract final class GdSpace {
  GdSpace._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Comfortable minimum tap target height.
  static const double touchTarget = 52;
}

/// Corner radii. Generous, consistent rounding signals a soft, low-pressure,
/// approachable tool.
abstract final class GdRadius {
  GdRadius._();
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;

  static const Radius xlRadius = Radius.circular(xl);
  static BorderRadius get card => BorderRadius.circular(xl);
  static BorderRadius get control => BorderRadius.circular(md);
  static BorderRadius get field => BorderRadius.circular(lg);
}

/// Motion timings — quick enough to feel responsive, smooth enough to feel calm.
abstract final class GdMotion {
  GdMotion._();
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
}

/// Tinted elevation. Soft, low, ink-tinted shadows give depth without weight.
abstract final class GdShadows {
  GdShadows._();

  /// Resting elevation for cards and tiles.
  static List<BoxShadow> get soft => [
        BoxShadow(
          color: GdColors.shadow.withValues(alpha: _dark ? 0.30 : 0.06),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ];

  /// Raised surfaces — sheets, popovers, the active focus card.
  static List<BoxShadow> get lifted => [
        BoxShadow(
          color: GdColors.shadow.withValues(alpha: _dark ? 0.42 : 0.10),
          blurRadius: 32,
          offset: const Offset(0, 18),
        ),
      ];

  /// A coloured glow that makes a tinted surface (pet, reward) feel alive.
  static List<BoxShadow> glow(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.32),
          blurRadius: 28,
          offset: const Offset(0, 14),
        ),
      ];
}

/// The gradient language. Gradients carry energy and identity; flat fills carry
/// calm. Reach for a named gradient instead of re-declaring `LinearGradient`s.
abstract final class GdGradients {
  GdGradients._();

  static LinearGradient get brand => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [GdColors.brand, GdColors.brandStrong],
      );

  /// Calm, optimistic header wash for hero areas.
  static LinearGradient get hero => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [GdColors.brand, GdColors.brandStrong],
      );

  /// Indigo focus-session field.
  static LinearGradient get focus => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [GdColors.focus, GdColors.brandStrong],
      );

  /// Reward / celebration sweep (coins, streaks, achievements).
  static LinearGradient get reward => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [const Color(0xFFF7C65B), GdColors.reward],
      );

  static const LinearGradient pet = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [GdPet.from, GdPet.to],
  );

  /// Build a diagonal gradient from any colour pair.
  static LinearGradient pair(List<Color> colors) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors.length >= 2 ? colors : [colors.first, colors.first],
      );
}

/// Status as a first-class concept: each carries its accent and its soft
/// surface as a matched pair (both resolve to light/dark), so a banner, chip or
/// icon never mixes the accent of one status with the surface of another.
enum GdStatus {
  positive,
  attention,
  danger,
  info,
  neutral;

  /// Foreground / accent colour.
  Color get color => switch (this) {
        GdStatus.positive => GdColors.positive,
        GdStatus.attention => GdColors.attention,
        GdStatus.danger => GdColors.danger,
        GdStatus.info => GdColors.info,
        GdStatus.neutral => GdColors.inkMuted,
      };

  /// Soft background paired with [color].
  Color get surface => switch (this) {
        GdStatus.positive => GdColors.positiveSoft,
        GdStatus.attention => GdColors.attentionSoft,
        GdStatus.danger => GdColors.dangerSoft,
        GdStatus.info => GdColors.infoSoft,
        GdStatus.neutral => GdColors.surfaceMuted,
      };
}

/// Maps a self-reported mood to colour by mirroring its *arousal level* — hue
/// communicates energy:
///   • Tired  → a calm, restorative green (settle, recover, go gently).
///   • Okay   → steady brand blue (balanced, neutral-positive).
///   • Great  → energising warm coral (enthusiasm, push further).
abstract final class GdMood {
  GdMood._();

  /// Accent colour for a mood.
  static Color accent(String mood) => switch (mood) {
        'Tired' => GdColors.positive,
        'Great' => GdColors.warm,
        _ => GdColors.brand,
      };

  /// Soft surface paired with [accent].
  static Color surface(String mood) => switch (mood) {
        'Tired' => GdColors.positiveSoft,
        'Great' => GdColors.warmSoft,
        _ => GdColors.brandSoft,
      };
}

/// Heading/title text styles sourced from the SAME live token resolver as every
/// surface, so a heading's colour can never drift out of sync with the card it
/// sits on. Prefer these over `Theme.of(context).textTheme.*`, whose colours
/// are baked per-theme and are a separate source of truth that can mismatch the
/// live tokens. Sizes/weights mirror the theme's text scale.
abstract final class GdText {
  GdText._();

  static TextStyle get headlineLarge => TextStyle(
        color: GdColors.ink,
        fontSize: 34,
        height: 1.05,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.2,
      );

  static TextStyle get headlineMedium => TextStyle(
        color: GdColors.ink,
        fontSize: 26,
        height: 1.1,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.7,
      );

  static TextStyle get titleLarge => TextStyle(
        color: GdColors.ink,
        fontSize: 20,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.3,
      );

  static TextStyle get titleMedium => TextStyle(
        color: GdColors.ink,
        fontSize: 16,
        fontWeight: FontWeight.w900,
      );
}

/// Single source of truth for each goal category's identity — label, icon and
/// gradient. Category hues are FIXED in both light and dark (identity must stay
/// recognisable), so they remain const literals.
enum GdCategory {
  study('Study', Icons.school_rounded, [Color(0xFFF59E0B), Color(0xFFEC4899)]),
  career('Career', Icons.work_rounded, [Color(0xFF06B6D4), Color(0xFF2563EB)]),
  wellness('Wellness', Icons.favorite_rounded,
      [Color(0xFFFB7185), Color(0xFFF43F5E)]),
  finance('Finance', Icons.savings_rounded,
      [Color(0xFF10B981), Color(0xFF059669)]),
  creative('Creative', Icons.palette_rounded,
      [Color(0xFF8B5CF6), Color(0xFFD946EF)]),
  other('Other', Icons.more_horiz_rounded,
      [Color(0xFF2E5AC9), Color(0xFF1F47AC)]);

  const GdCategory(this.label, this.icon, this.colors);

  final String label;
  final IconData icon;
  final List<Color> colors;

  /// Resolve a stored category string, defaulting to [study] when unknown.
  static GdCategory resolve(String category) {
    for (final value in values) {
      if (value.label.toLowerCase() == category.toLowerCase()) return value;
    }
    return study;
  }

  static List<Color> colorsFor(String category) => resolve(category).colors;
  static IconData iconFor(String category) => resolve(category).icon;
  static LinearGradient gradientFor(String category) =>
      GdGradients.pair(resolve(category).colors);
}

/// Consistent opacity steps. Overlays, tints and shadows pull from one ladder
/// instead of each call site inventing an alpha.
abstract final class GdAlpha {
  GdAlpha._();
  static const double faint = 0.06;
  static const double soft = 0.12;
  static const double muted = 0.24;
  static const double strong = 0.40;
  static const double heavy = 0.72;
}

/* ──────────────────────────────────────────────────────────────────────────
   COMPATIBILITY LAYER
   Flat aliases so existing widgets keep their token names while the system
   underneath is the semantic, light/dark role model above. New code should use
   GdColors.* / GdSpace.* / GdCategory.* directly.

   Theme-dependent roles are getters (they change with brightness); fixed
   identity colours (category gradients, pet) stay const.
   ────────────────────────────────────────────────────────────────────────── */

Color get gdBackground => GdColors.canvas;
Color get gdSurface => GdColors.surface;
Color get gdCardLight => GdColors.surfaceMuted;
Color get gdInk => GdColors.ink;
Color get gdMuted => GdColors.inkMuted;
Color get gdHint => GdColors.inkFaint;
Color get gdBorder => GdColors.border;
Color get gdBorderStrong => GdColors.borderStrong;
Color get gdPrimary => GdColors.brand;
Color get gdPrimaryDark => GdColors.brandStrong;
Color get gdPrimarySoft => GdColors.brandSoft;
Color get gdAccent => GdColors.warm;
Color get gdAccentSoft => GdColors.warmSoft;
Color get gdSuccess => GdColors.positive;
Color get gdSuccessSoft => GdColors.positiveSoft;
Color get gdWarning => GdColors.attention;
Color get gdWarningSoft => GdColors.attentionSoft;
Color get gdError => GdColors.danger;
Color get gdErrorSoft => GdColors.dangerSoft;
Color get gdInfo => GdColors.info;
Color get gdInfoSoft => GdColors.infoSoft;
Color get gdFocus => GdColors.focus;
Color get gdFocusSoft => GdColors.focusSoft;
Color get gdStarGold => GdColors.reward;
Color get gdCoin => GdColors.reward;
Color get gdOnDark => GdColors.onColor;
Color get gdOnDarkMuted => GdColors.onColorMuted;
Color get gdShadow => GdColors.shadow;
Color get gdScrim => GdColors.scrim;

// Fixed identity colours — same in both modes.
const Color gdPetMintFrom = GdPet.from;
const Color gdPetMintTo = GdPet.to;
const Color gdPetAccent = GdPet.accent;
const Color gdGradientCareerFrom = Color(0xFF06B6D4);
const Color gdGradientCareerTo = Color(0xFF2563EB);
const Color gdGradientStudyFrom = Color(0xFFF59E0B);
const Color gdGradientStudyTo = Color(0xFFEC4899);
const Color gdGradientWellnessFrom = Color(0xFFFB7185);
const Color gdGradientWellnessTo = Color(0xFFF43F5E);
const Color gdGradientFinanceFrom = Color(0xFF10B981);
const Color gdGradientFinanceTo = Color(0xFF059669);
const Color gdGradientCreativeFrom = Color(0xFF8B5CF6);
const Color gdGradientCreativeTo = Color(0xFFD946EF);
const double gdTouchTarget = GdSpace.touchTarget;

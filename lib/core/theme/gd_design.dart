import 'package:flutter/material.dart';

/* ══════════════════════════════════════════════════════════════════════════
   GOAL DIGGER — DESIGN LANGUAGE
   ──────────────────────────────────────────────────────────────────────────
   One source of truth for how the app looks and feels. The guiding idea is
   SEMANTIC ROLES: you pick a colour by the JOB it does, never by its hue.
   That keeps screens consistent, self-documenting, and ready to re-skin.

   Goal Digger is a gamified productivity *companion*, so the system is tuned
   to three emotional jobs, each mapped to a deliberate part of the palette:

     1. CALM FOCUS  — a cool, low-glare canvas with deep, high-contrast ink.
                      Quiet surfaces lower cognitive load so deep work and
                      focus sessions don't feel stressful.
     2. TRUST       — blue carries every primary action and the app chrome.
                      Blue reads as focus, reliability and stability, so it
                      anchors the experience and then gets out of the way.
     3. ENCOURAGE   — warm coral (human warmth), achievement green (growth +
                      completion) and reward gold (coins, streaks) supply the
                      motivation a companion lives on.

   Saturated colour is rationed: it's reserved for action, progress and
   reward, so a user's eye is always pulled toward the next worthwhile thing.
   Every text/background pairing here targets WCAG AA.

   HOW TO USE
     • Colour   →  GdColors.brand, GdColors.positive, GdColors.ink …
     • Space    →  GdSpace.lg          (a single 4-pt rhythm)
     • Radius   →  GdRadius.card       (soft, friendly shapes)
     • Shadow   →  GdShadows.soft      (airy, ink-tinted depth)
     • Gradient →  GdGradients.hero / GdCategory.gradientFor('Study')
   ════════════════════════════════════════════════════════════════════════ */

/// Semantic colour roles — the heart of the system. Reach for the role whose
/// *purpose* matches your intent; never hard-code a hex value in a widget.
abstract final class GdColors {
  GdColors._();

  // ── Canvas & surfaces — the calm foundation ────────────────────────────
  /// App background. Cool + slightly blue to cut glare and feel restful.
  static const Color canvas = Color(0xFFF5F7FB);

  /// Primary card / sheet surface.
  static const Color surface = Color(0xFFFFFFFF);

  /// Nested or secondary surface that should sit a step back from [surface].
  static const Color surfaceMuted = Color(0xFFEFF3FA);

  /// Hairline dividers and resting outlines.
  static const Color border = Color(0xFFE5EAF2);

  /// Stronger outline for emphasis or interactive edges.
  static const Color borderStrong = Color(0xFFCAD4E0);

  // ── Content — legibility & hierarchy ────────────────────────────────────
  /// Primary text/icons. Deep navy, ~13:1 on [canvas].
  static const Color ink = Color(0xFF1B2638);

  /// Secondary text. AA on white.
  static const Color inkMuted = Color(0xFF566377);

  /// Placeholders, hints, decorative text.
  static const Color inkFaint = Color(0xFF8893A4);

  /// Text/icons resting on a saturated or dark fill.
  static const Color onColor = Color(0xFFFFFFFF);

  /// Secondary text on a saturated or dark fill.
  static const Color onColorMuted = Color(0xFFEAF1FF);

  // ── Brand — focus & trust (blue) ────────────────────────────────────────
  /// Primary actions and chrome. The productivity anchor.
  static const Color brand = Color(0xFF2E5AC9);

  /// Pressed / hover / depth variant of [brand].
  static const Color brandStrong = Color(0xFF1F47AC);

  /// Airy brand wash: selected states, chips, soft fills.
  static const Color brandSoft = Color(0xFFE6EDFD);

  // ── Expressive accents — psychology-mapped ──────────────────────────────
  /// Encouragement & human warmth (the "companion" voice). Distinct from
  /// [danger] so warmth never reads as error.
  static const Color warm = Color(0xFFF06A53);
  static const Color warmSoft = Color(0xFFFFE7E0);

  /// Achievement, growth, completed work, streaks — positive reinforcement.
  static const Color positive = Color(0xFF16A34A);
  static const Color positiveSoft = Color(0xFFDCFAE6);

  /// Caution that isn't an error: nudges, deadlines approaching.
  static const Color attention = Color(0xFFD97706);
  static const Color attentionSoft = Color(0xFFFEF1D6);

  /// Errors and destructive actions only.
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerSoft = Color(0xFFFEE2E2);

  /// Neutral, informational messaging.
  static const Color info = Color(0xFF0E97D9);
  static const Color infoSoft = Color(0xFFDFF3FC);

  /// Deep concentration — the focus-session field. Indigo = calm intensity.
  static const Color focus = Color(0xFF3F3DAE);
  static const Color focusSoft = Color(0xFFE8E7FB);

  /// The reward economy: coins, stars, streak celebrations.
  static const Color reward = Color(0xFFF2B33D);

  // ── Effects ─────────────────────────────────────────────────────────────
  /// Ink-tinted shadow base — reads more natural than pure black on [canvas].
  static const Color shadow = Color(0xFF1B2638);

  /// Modal scrim.
  static const Color scrim = Color(0x661B2638);

  // ── Colour functions ────────────────────────────────────────────────────
  /// WCAG-aware foreground. Returns dark [ink] on light fills and [onColor] on
  /// dark/saturated fills, so text laid over any category gradient or status
  /// colour stays legible without hand-tuning per screen.
  static Color onColorFor(Color background) =>
      background.computeLuminance() > 0.45 ? ink : onColor;

  /// The canonical way to build a soft "tinted card" from any accent: blend the
  /// accent over [surface] at a fixed, gentle opacity instead of hand-picking a
  /// pale hex. Produces an opaque, low-saturation surface.
  static Color tintOf(Color color, [double opacity = GdAlpha.soft]) =>
      Color.alphaBlend(color.withValues(alpha: opacity), surface);

  /// A slightly stronger tint for borders/edges of a tinted surface.
  static Color edgeOf(Color color) => color.withValues(alpha: GdAlpha.muted);
}

/// Consistent opacity steps. Overlays, tints and shadows pull from one ladder
/// instead of each call site inventing an alpha — uniform depth, less noise.
abstract final class GdAlpha {
  GdAlpha._();

  /// Hairline tints and resting shadows.
  static const double faint = 0.06;

  /// Subtle fills, hover states, icon chips.
  static const double soft = 0.12;

  /// Dividers and outlines drawn on top of colour; disabled content.
  static const double muted = 0.24;

  /// Emphasised borders on colour, light scrims.
  static const double strong = 0.40;

  /// Pressed states and heavy overlays.
  static const double heavy = 0.72;
}

/// Status as a first-class concept: each carries its accent and its soft
/// surface as a matched pair, so a banner, chip or icon never mixes the accent
/// of one status with the surface of another.
enum GdStatus {
  positive(GdColors.positive, GdColors.positiveSoft),
  attention(GdColors.attention, GdColors.attentionSoft),
  danger(GdColors.danger, GdColors.dangerSoft),
  info(GdColors.info, GdColors.infoSoft),
  neutral(GdColors.inkMuted, GdColors.surfaceMuted);

  const GdStatus(this.color, this.surface);

  /// Foreground / accent colour.
  final Color color;

  /// Soft background paired with [color].
  final Color surface;
}

/// Maps a self-reported mood to colour by mirroring its *arousal level* — the
/// core idea from colour psychology that hue communicates energy:
///   • Tired  → a calm, restorative green (settle, recover, go gently).
///   • Okay   → steady brand blue (balanced, neutral-positive).
///   • Great  → energising warm coral (enthusiasm, push further).
/// Centralising this fixes the screens that previously each invented their own
/// mood hues, so the signal reads the same everywhere.
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

/// The pet companion's own palette — kept friendly, fresh and distinct from
/// the brand so the companion feels like its own character.
abstract final class GdPet {
  GdPet._();
  static const Color from = Color(0xFF22D3EE);
  static const Color to = Color(0xFF2DD4BF);
  static const Color accent = Color(0xFFEAF2FF);
}

/// 4-pt spacing rhythm. One scale for all padding and gaps keeps vertical and
/// horizontal spacing visually consistent across every screen.
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
/// approachable tool — important for a companion that should feel supportive.
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

/// Tinted elevation. Soft, low, ink-tinted shadows give depth without weight,
/// keeping the interface airy.
abstract final class GdShadows {
  GdShadows._();

  /// Resting elevation for cards and tiles.
  static List<BoxShadow> get soft => [
        BoxShadow(
          color: GdColors.shadow.withValues(alpha: 0.06),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ];

  /// Raised surfaces — sheets, popovers, the active focus card.
  static List<BoxShadow> get lifted => [
        BoxShadow(
          color: GdColors.shadow.withValues(alpha: 0.10),
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

  static const LinearGradient brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [GdColors.brand, GdColors.brandStrong],
  );

  /// Calm, optimistic header wash for hero areas.
  static const LinearGradient hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3E6FE0), GdColors.brandStrong],
  );

  /// Indigo focus-session field.
  static const LinearGradient focus = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5350C4), GdColors.focus],
  );

  /// Reward / celebration sweep (coins, streaks, achievements).
  static const LinearGradient reward = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF7C65B), GdColors.reward],
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

/// Single source of truth for each goal category's identity — label, icon and
/// gradient. Users orient by hue at a glance, so the colour and icon mappings
/// must never drift apart; centralising them here guarantees they can't.
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
      [GdColors.brand, GdColors.brandStrong]);

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

/* ──────────────────────────────────────────────────────────────────────────
   COMPATIBILITY LAYER
   These flat aliases let existing widgets keep referring to the old token
   names while the system underneath is the semantic role model above. New
   code should use GdColors.* / GdSpace.* / GdCategory.* directly.
   ────────────────────────────────────────────────────────────────────────── */

const Color gdBackground = GdColors.canvas;
const Color gdSurface = GdColors.surface;
const Color gdCardLight = GdColors.surfaceMuted;
const Color gdInk = GdColors.ink;
const Color gdMuted = GdColors.inkMuted;
const Color gdHint = GdColors.inkFaint;
const Color gdBorder = GdColors.border;
const Color gdBorderStrong = GdColors.borderStrong;
const Color gdPrimary = GdColors.brand;
const Color gdPrimaryDark = GdColors.brandStrong;
const Color gdPrimarySoft = GdColors.brandSoft;
const Color gdAccent = GdColors.warm;
const Color gdAccentSoft = GdColors.warmSoft;
const Color gdSuccess = GdColors.positive;
const Color gdSuccessSoft = GdColors.positiveSoft;
const Color gdWarning = GdColors.attention;
const Color gdWarningSoft = GdColors.attentionSoft;
const Color gdError = GdColors.danger;
const Color gdErrorSoft = GdColors.dangerSoft;
const Color gdInfo = GdColors.info;
const Color gdInfoSoft = GdColors.infoSoft;
const Color gdFocus = GdColors.focus;
const Color gdFocusSoft = GdColors.focusSoft;
const Color gdStarGold = GdColors.reward;
const Color gdCoin = GdColors.reward;
const Color gdOnDark = GdColors.onColor;
const Color gdOnDarkMuted = GdColors.onColorMuted;
const Color gdShadow = GdColors.shadow;
const Color gdScrim = GdColors.scrim;
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

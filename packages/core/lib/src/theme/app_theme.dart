import 'package:flutter/material.dart';

/// EasyFleet design tokens, shared by both apps.
///
/// "Depot instrument panel": petrol ink, paper white, signal amber and
/// verified teal. Amber is reserved for actions and wayfinding; teal is only
/// used for verified/successful states so status stays legible at a glance.
abstract final class AppColors {
  static const ink = Color(0xFF0B1B23);
  static const inkSoft = Color(0xFF1C3440);
  static const paper = Color(0xFFF5F7F4);
  static const paperRaised = Color(0xFFFFFFFF);
  static const road = Color(0xFFDDE5E3);
  static const slate = Color(0xFF4A616B);
  static const signal = Color(0xFFF2A93B);
  static const signalPale = Color(0xFFFCE7C4);
  static const verified = Color(0xFF2F8F83);
  static const verifiedPale = Color(0xFFD6EFEA);
  static const danger = Color(0xFFC9503F);

  /// Backwards-compatible aliases used by older feature code.
  static const seed = signal;
  static const success = verified;
  static const warning = signal;
  static const neutralSurface = paper;
}

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

abstract final class AppRadius {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double sheet = 28;
}

/// Motion is reserved for one route reveal and responses to a person's action.
abstract final class AppMotion {
  static const Duration reveal = Duration(milliseconds: 420);
  static const Duration quick = Duration(milliseconds: 180);
  static const Curve expressive = Curves.easeOutCubic;
}

/// A short, directional entrance for routes: quiet enough to repeat, distinct
/// from the generic per-card fade-and-slide stack. Reduced motion shows the
/// plain child.
class AppPageTransition extends PageTransitionsBuilder {
  const AppPageTransition();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) return child;
    final curved = CurvedAnimation(
      parent: animation,
      curve: AppMotion.expressive,
      reverseCurve: Curves.easeInCubic,
    );
    final fade = CurvedAnimation(
      parent: curved,
      curve: const Interval(0, 0.7, curve: Curves.easeOut),
    );
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.018),
      end: Offset.zero,
    ).animate(curved);
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }
}

class AppTheme {
  const AppTheme._();

  static ThemeData light() => _theme(Brightness.light);
  static ThemeData dark() => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.signal,
      onPrimary: AppColors.ink,
      primaryContainer: AppColors.signalPale,
      onPrimaryContainer: AppColors.ink,
      secondary: AppColors.verified,
      onSecondary: AppColors.paper,
      secondaryContainer: AppColors.verifiedPale,
      onSecondaryContainer: AppColors.ink,
      tertiary: AppColors.inkSoft,
      onTertiary: AppColors.paper,
      error: AppColors.danger,
      onError: AppColors.paper,
      surface: isLight ? AppColors.paper : AppColors.ink,
      onSurface: isLight ? AppColors.ink : AppColors.paper,
      surfaceContainerHighest: isLight ? AppColors.road : AppColors.inkSoft,
      onSurfaceVariant: isLight ? AppColors.slate : const Color(0xFFB8C7C9),
      outline: isLight ? const Color(0xFFAFC0BE) : const Color(0xFF3E5863),
      outlineVariant: AppColors.road.withValues(alpha: isLight ? 1 : 0.22),
      shadow: AppColors.ink,
      scrim: AppColors.ink,
      inverseSurface: isLight ? AppColors.ink : AppColors.paper,
      onInverseSurface: isLight ? AppColors.paper : AppColors.ink,
      inversePrimary: AppColors.signal,
      surfaceTint: AppColors.signal,
    );

    final typography = Typography.material2021(
      platform: TargetPlatform.android,
      colorScheme: colorScheme,
    );
    final applied = (isLight ? typography.black : typography.white).apply(
      fontFamily: 'IBMPlexSans',
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );
    const tabular = [FontFeature.tabularFigures()];
    final textTheme = applied.copyWith(
      displayLarge: applied.displayLarge?.copyWith(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        height: 1.12,
        fontFeatures: tabular,
      ),
      headlineLarge: applied.headlineLarge?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.15,
        fontFeatures: tabular,
      ),
      headlineMedium: applied.headlineMedium?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        fontFeatures: tabular,
      ),
      titleLarge: applied.titleLarge?.copyWith(
        fontSize: 19,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        fontFeatures: tabular,
      ),
      titleMedium: applied.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFeatures: tabular,
      ),
      bodyLarge: applied.bodyLarge?.copyWith(
        fontSize: 15,
        height: 1.45,
        fontFeatures: tabular,
      ),
      bodyMedium: applied.bodyMedium?.copyWith(
        fontSize: 14,
        height: 1.45,
        fontFeatures: tabular,
      ),
      bodySmall: applied.bodySmall?.copyWith(
        fontSize: 12.5,
        height: 1.4,
        fontFeatures: tabular,
      ),
      labelLarge: applied.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFeatures: tabular,
      ),
      labelMedium: applied.labelMedium?.copyWith(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        fontFeatures: tabular,
      ),
      labelSmall: applied.labelSmall?.copyWith(
        fontSize: 11.5,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        fontFeatures: tabular,
      ),
    );

    final outlineInput = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: BorderSide(color: colorScheme.outline),
    );
    final focusedInput = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          for (final platform in TargetPlatform.values)
            platform: const AppPageTransition(),
        },
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: textTheme.titleLarge,
        toolbarHeight: 64,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isLight ? AppColors.paperRaised : AppColors.inkSoft,
        surfaceTintColor: Colors.transparent,
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          side: BorderSide(color: colorScheme.outline),
          foregroundColor: colorScheme.onSurface,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colorScheme.onSurfaceVariant,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        focusElevation: 4,
        hoverElevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        extendedTextStyle: textTheme.labelLarge,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colorScheme.primary,
        selectionColor: colorScheme.primary.withValues(alpha: 0.3),
        selectionHandleColor: colorScheme.primary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(
          alpha: isLight ? 0.55 : 0.35,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        labelStyle: textTheme.bodyMedium,
        hintStyle: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        border: outlineInput,
        enabledBorder: outlineInput,
        focusedBorder: focusedInput,
        errorBorder: outlineInput.copyWith(
          borderSide: BorderSide(color: colorScheme.error),
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 10,
        ),
        minLeadingWidth: 40,
        titleTextStyle: textTheme.titleMedium,
        subtitleTextStyle: textTheme.bodySmall,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        space: 1,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        labelStyle: textTheme.labelMedium,
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.primaryContainer,
        circularTrackColor: colorScheme.primaryContainer,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.paper,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheet),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        labelTextStyle: WidgetStateProperty.all(textTheme.labelSmall),
      ),
    );
  }
}

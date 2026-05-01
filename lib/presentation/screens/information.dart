import 'package:flutter/material.dart';
import 'package:truesoulcards/l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:truesoulcards/presentation/widgets/glass_card.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = AppLocalizations.of(context)!;
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final backgroundBase = colorScheme.surface;
    final backgroundTint = Color.alphaBlend(
      colorScheme.primary.withOpacity(isDark ? 0.10 : 0.06),
      backgroundBase,
    );

    final glassBase = colorScheme.surface.withOpacity(isDark ? 0.72 : 0.86);
    final glassOutline = colorScheme.outlineVariant.withOpacity(isDark ? 0.22 : 0.18);
    final softShadow = theme.shadowColor.withOpacity(isDark ? 0.18 : 0.10);
    final mutedBody = colorScheme.onSurface.withOpacity(isDark ? 0.82 : 0.78);
    final iconPrimary = colorScheme.primary.withOpacity(isDark ? 0.55 : 0.50);
    final titlePrimary = colorScheme.primary.withOpacity(isDark ? 0.92 : 0.88);

    return Scaffold(
      backgroundColor: backgroundBase,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(localization.about_game),
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              backgroundBase,
              backgroundTint,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  child: GlassCard(
                    padding: const EdgeInsets.fromLTRB(18, 26, 18, 20),
                    backgroundColor: glassBase,
                    outlineColor: colorScheme.primary.withOpacity(isDark ? 0.18 : 0.22),
                    shadowColor: theme.shadowColor.withOpacity(isDark ? 0.24 : 0.14),
                    borderRadius: 28,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: SvgPicture.asset(
                                'assets/svg/pattern.svg',
                                fit: BoxFit.contain,
                                cacheColorFilter: true,
                                colorFilter: ColorFilter.mode(
                                  iconPrimary,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),

                            const SizedBox(width: 16),

                            Expanded(
                              child: Text(
                                localization.info_title,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: titlePrimary,
                                  fontWeight: FontWeight.w700,
                                  height: 1.18,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        Text(
                          '${localization.info_description_part1}\n\n${localization.info_description_part2}',
                          textAlign: TextAlign.left,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: mutedBody,
                            height: 1.65,
                            fontSize: 16.2,
                            letterSpacing: 0.05,
                          ),
                        ),

                        const SizedBox(height: 24),

                        Center(
                          child: Container(
                            width: 96,
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  colorScheme.primary.withOpacity(0.45),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
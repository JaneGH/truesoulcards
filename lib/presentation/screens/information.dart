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
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                    backgroundColor: glassBase,
                    outlineColor: glassOutline,
                    shadowColor: softShadow,
                    borderRadius: 22,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 32,
                              height: 32,
                              child: SvgPicture.asset(
                                'assets/svg/pattern.svg',
                                fit: BoxFit.contain,
                                colorFilter: ColorFilter.mode(
                                  iconPrimary,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                localization.info_title,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: titlePrimary,
                                  fontWeight: FontWeight.bold,
                                  height: 1.25,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        Text(
                          '${localization.info_description_part1}\n\n${localization.info_description_part2}',
                          textAlign: TextAlign.justify,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: mutedBody,
                            height: 1.55,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
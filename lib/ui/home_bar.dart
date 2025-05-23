import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shuttle/l10n/generated/app_localizations.dart';

class HomeBar extends StatelessWidget implements PreferredSizeWidget {
  final double toolbarHeight;
  final VoidCallback? estateOnTap;
  final VoidCallback? locationOnTap;
  final VoidCallback? toggleLanguage;
  final String estateTitle;
  final String stopTitle;

  const HomeBar({
    super.key,
    this.toolbarHeight = kToolbarHeight,
    this.estateOnTap,
    this.locationOnTap,
    this.toggleLanguage,
    required this.estateTitle,
    required this.stopTitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final localizations = AppLocalizations.of(context)!;

    return Container(
      color: colorScheme.surface,
      child: SafeArea(
        bottom: false,
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: 48,
              child: GestureDetector(
                onTap: locationOnTap,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    Lottie.asset(
                      'lib/assets/pulsing_pin.json',
                      width: 32,
                      height: 48,
                      fit: BoxFit.contain,
                      repeat: true,
                      reverse: false,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Text(
                          estateTitle,
                          style: textTheme.bodySmall!.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 120,
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  stopTitle,
                                  style: textTheme.titleLarge!.copyWith(
                                    color: colorScheme.onSurface,
                                    height: 1.2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down_rounded,
                                size: 28,
                                color: colorScheme.onSurface,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top:10),
              child: PopupMenuButton<String>(
                icon: Icon(
                  Icons.menu,
                  color: colorScheme.outline,
                ),
                onSelected: (String value) {
                  if (value == 'estate') {
                    estateOnTap?.call();
                  } else if (value == 'language') {
                    toggleLanguage?.call();
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'estate',
                    child: ListTile(
                      leading: Icon(
                        Icons.home_work_outlined,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      title: Text(
                        localizations.estateSwitch,
                        style: textTheme.bodyMedium!.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'language',
                    child: ListTile(
                      leading: Icon(
                        Icons.translate_outlined,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      title: Text(
                        localizations.languageSwitch,
                        style: textTheme.bodyMedium!.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: colorScheme.surface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);
}
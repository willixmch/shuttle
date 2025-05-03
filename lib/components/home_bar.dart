import 'package:flutter/material.dart';

class HomeBar extends StatelessWidget implements PreferredSizeWidget {
  final double toolbarHeight;
  final VoidCallback? estateOnTap;
  final VoidCallback? locationOnTap;
  final String estateTitle;

  const HomeBar({
    super.key,
    this.toolbarHeight = kToolbarHeight,
    this.estateOnTap,
    this.locationOnTap,
    required this.estateTitle,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final typescale = Theme.of(context).textTheme;

    return SafeArea(
      minimum: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: toolbarHeight,
              child: GestureDetector(
                onTap: estateOnTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      Text(
                        estateTitle,
                        style: typescale.headlineSmall!.copyWith(
                          color: color.onSurfaceVariant,
                        ),
                      ),
                      Icon(
                        Icons.import_export,
                        size: 24,
                        color: color.outlineVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: toolbarHeight,
              child: GestureDetector(
                onTap: locationOnTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 20,
                        color: color.primary,
                      ),
                      Text(
                        '沙田市中心(第一期)',
                        style: typescale.labelLarge!.copyWith(
                          color: color.onSurface,
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down_rounded,
                        size: 20,
                        color: color.onSurface,
                      ),
                    ],
                  ),
                ),
              ),
              
            )
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);
}
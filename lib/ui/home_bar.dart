import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class HomeBar extends StatelessWidget implements PreferredSizeWidget {
  final double toolbarHeight;
  final VoidCallback? estateOnTap;
  final VoidCallback? locationOnTap;
  final String estateTitle;
  final String stopTitle;

  const HomeBar({
    super.key,
    this.toolbarHeight = kToolbarHeight,
    this.estateOnTap,
    this.locationOnTap,
    required this.estateTitle,
    required this.stopTitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      color: colorScheme.surface,
      child: SafeArea(
        bottom: false,
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: toolbarHeight - 20,
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
                        style: textTheme.headlineSmall!.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Icon(
                        Icons.import_export,
                        size: 24,
                        color: colorScheme.outlineVariant,
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4,
                  children: [
                    Lottie.asset(
                      'lib/assets/pulsing_pin.json',
                      width: 28,          
                      height: 28,
                      fit: BoxFit.contain,
                      repeat: true,
                      reverse: false,
                    ),
                    Text(
                      stopTitle,
                      style: textTheme.labelLarge!.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down_rounded,
                      size: 20,
                      color: colorScheme.onSurface,
                    ),
                  ],
                ),
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
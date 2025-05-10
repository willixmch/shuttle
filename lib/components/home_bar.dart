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
    final color = Theme.of(context).colorScheme;
    final typescale = Theme.of(context).textTheme;

    return Container(
      color: color.surface,
      child: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Align(
          alignment: Alignment.centerLeft,
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
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);
}
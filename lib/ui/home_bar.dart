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
                            color: colorScheme.outline
                          )
                        ),
                        Row(
                          children: [
                            Text(
                              stopTitle,
                              style: textTheme.titleLarge!.copyWith(
                                color: colorScheme.onSurface,
                                height: 1.2,
                                overflow: TextOverflow.ellipsis, 
                              ),
                              maxLines: 1,
                            ),
                            Icon(
                              Icons.arrow_drop_down_rounded,
                              size: 28,
                              color: colorScheme.onSurface,
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                  ],
                ),
              ),
            ),
            Container(
              height: 56,
              alignment: Alignment.bottomCenter,
              child: IconButton.outlined(
                color: colorScheme.outline,
                onPressed: estateOnTap, 
                icon: Icon(Icons.home_work_outlined),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
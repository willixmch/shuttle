import 'package:flutter/material.dart';

class HomeBar extends StatelessWidget implements PreferredSizeWidget {
  final double toolbarHeight;

  const HomeBar({
    super.key,
    this.toolbarHeight = kToolbarHeight, // Default to 56.0
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final typescale = Theme.of(context).textTheme;

    return SafeArea(
      minimum: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          height: toolbarHeight,
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  Text(
                    'The Regent',
                    style: typescale.headlineSmall!.copyWith(
                      color: color.onSurfaceVariant,
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 24,
                    color: color.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);
}
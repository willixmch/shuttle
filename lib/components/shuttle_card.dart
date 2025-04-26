import 'package:flutter/material.dart';

class ShuttleCard extends StatefulWidget {
  final String route;
  final String info;
  final String eta;
  final List<String> upcomingEta;

  const ShuttleCard({
    super.key,
    required this.route,
    required this.info,
    required this.eta,
    required this.upcomingEta,
  });

  @override
  _ShuttleCardState createState() => _ShuttleCardState();
}

class _ShuttleCardState extends State<ShuttleCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {

    final color = Theme.of(context).colorScheme;
    final typescale = Theme.of(context).textTheme;

    return GestureDetector(

      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },

      child: Container(

        // Card Styling
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: ShapeDecoration(
          color: color.surfaceContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),),
        ),

        // Content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                // Route
                Text(
                  widget.route,
                  style: typescale.titleMedium!.copyWith(
                    color: color.onSurfaceVariant,
                  ),
                ),

                // Info
                Text(
                  widget.info,
                  style: typescale.bodyMedium!.copyWith(
                    color: color.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ETA
            Text(
              widget.eta,
              style: typescale.titleLarge!.copyWith(
                color: color.onSurface,
              ),
            ),

            // Upcoming ETA (Expandable)
            ClipRect(
              child: AnimatedContainer(

                // Config
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: _isExpanded
                    ? (widget.upcomingEta.length * 32.0 + 40.0)
                    : 0.0,
                
                // Content
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const SizedBox(height: 12),

                      // Icon & Title
                      Row(
                        spacing: 4,
                        children: [
                          Icon(Icons.departure_board, size: 16,),
                          Text(
                            '隨後班次',
                            style: typescale.labelSmall!.copyWith(color: color.onSurfaceVariant),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Upcoming ETA
                      ...widget.upcomingEta.map((eta) => Row(
                        spacing: 4,
                        children: [
                          Container(
                            width: 16,
                            height: 34,
                            alignment: Alignment.center,
                            child: VerticalDivider(
                              width: 1,
                              color: color.outlineVariant,
                            ),
                          ),
                          Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  eta,
                                  style: typescale.bodyLarge!.copyWith(color: color.onSurface,),
                                ),
                              ),
                        ],
                      )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
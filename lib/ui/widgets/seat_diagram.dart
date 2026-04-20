import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SeatDiagram extends StatelessWidget {
  final bool isLeftShady;

  const SeatDiagram({super.key, required this.isLeftShady});

  @override
  Widget build(BuildContext context) {
    // According to our recent inverted logic updates:
    // If isLeftShady is true -> text says "SIT RIGHT", and "sun will hit LEFT side".
    // Therefore, the sun should be placed on the LEFT, left seats are sunny, and right seats are shady.
    final bool showSunOnLeft = isLeftShady;
    final bool showShadyOnRight = isLeftShady;

    return Container(
      width: double.infinity,
      height: 260,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppTheme.lightGray,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Modern Sun Icon Indicator
          Positioned(
            left: showSunOnLeft ? 20 : null,
            right: showSunOnLeft ? null : 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wb_sunny, color: AppTheme.amber, size: 56),
                const SizedBox(height: 8),
                Text(
                  'Sun',
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          // Main Big Square / Vehicle Container
          Container(
            width: 150,
            height: 210,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(color: AppTheme.midGray, width: 2.5),
            ),
            child: Column(
              children: [
                // Front / Dashboard / Windshield
                Container(
                  height: 30,
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade100,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade300,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                ),
                const Expanded(child: SizedBox()),
                // Seats Layout
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left column of seats
                      _buildSeatColumn(
                        isShady: !showShadyOnRight,
                        label: !showShadyOnRight ? 'Shady' : 'Sunny',
                      ),
                      // Center Aisle Path
                      Container(
                        width: 26,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(4, (index) => 
                            Container(
                              width: 4,
                              height: 14,
                              color: Colors.grey.shade300,
                            )
                          ),
                        ),
                      ),
                      // Right column of seats
                      _buildSeatColumn(
                        isShady: showShadyOnRight,
                        label: showShadyOnRight ? 'Shady' : 'Sunny',
                      ),
                    ],
                  ),
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatColumn({required bool isShady, required String label}) {
    final bgColor = isShady ? AppTheme.lightGreen : AppTheme.lightAmber;
    final borderColor = isShady ? AppTheme.primaryGreen : AppTheme.amber;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < 3; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            width: 34,
            height: 26,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: borderColor, width: 2),
            ),
          ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: borderColor,
          ),
        ),
      ],
    );
  }
}
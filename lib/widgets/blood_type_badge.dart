import 'package:flutter/material.dart';

/// Her kan grubuna özel renk döndürür.
Color _colorForBloodType(String bloodType) {
  switch (bloodType) {
    case 'A+':
      return const Color(0xFFE53935);
    case 'A-':
      return const Color(0xFFEF5350);
    case 'B+':
      return const Color(0xFF1E88E5);
    case 'B-':
      return const Color(0xFF42A5F5);
    case 'AB+':
      return const Color(0xFF8E24AA);
    case 'AB-':
      return const Color(0xFFAB47BC);
    case '0+':
    case 'O+':
      return const Color(0xFF43A047);
    case '0-':
    case 'O-':
      return const Color(0xFF66BB6A);
    default:
      return const Color(0xFF757575);
  }
}

/// Kan grubunu renkli, yuvarlak köşeli bir badge olarak gösterir.
class BloodTypeBadge extends StatelessWidget {
  final String bloodType;
  final double fontSize;

  const BloodTypeBadge({
    super.key,
    required this.bloodType,
    this.fontSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colorForBloodType(bloodType);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.water_drop_rounded, color: color, size: fontSize + 2),
          const SizedBox(width: 4),
          Text(
            bloodType,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}

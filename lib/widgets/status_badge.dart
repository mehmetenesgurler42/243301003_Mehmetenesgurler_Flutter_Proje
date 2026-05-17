import 'package:flutter/material.dart';

/// Talep durumuna göre renk ve etiket döndürür.
Map<String, dynamic> _statusConfig(String status) {
  switch (status) {
    case 'bekliyor':
    case 'pending': // Eski verilerle uyumluluk için
      return {
        'label': 'Bekliyor',
        'color': const Color(0xFFF59E0B),
        'icon': Icons.hourglass_empty_rounded,
      };
    case 'karşılandı':
    case 'accepted': // Eski verilerle uyumluluk için
      return {
        'label': 'Karşılandı',
        'color': const Color(0xFF10B981),
        'icon': Icons.check_circle_outline_rounded,
      };
    default:
      return {
        'label': status,
        'color': const Color(0xFF6B7280),
        'icon': Icons.info_outline_rounded,
      };
  }
}

/// Talep durumunu renkli, ikonlu bir badge olarak gösterir.
class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig(status);
    final Color color = config['color'] as Color;
    final IconData icon = config['icon'] as IconData;
    final String label = config['label'] as String;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        border: Border.all(color: color, width: 1.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: fontSize + 2),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}

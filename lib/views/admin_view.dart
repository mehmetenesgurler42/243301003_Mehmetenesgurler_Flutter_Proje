import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/blood_request_provider.dart';
import '../widgets/blood_type_badge.dart';
import '../widgets/status_badge.dart';

class AdminView extends StatelessWidget {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    final requestProvider = Provider.of<BloodRequestProvider>(context);
    final requests = requestProvider.requests;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pendingCount = requests.where((r) => r.status == 'pending').length;
    final acceptedCount = requests.where((r) => r.status == 'accepted').length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Yönetim Paneli', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildStatCard(context, 'Bekleyen', pendingCount.toString(), Colors.orange),
                const SizedBox(width: 12),
                _buildStatCard(context, 'Tamamlanan', acceptedCount.toString(), Colors.green),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: BloodTypeBadge(bloodType: request.bloodType, fontSize: 14),
                    title: Text(request.patientName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                    subtitle: Text('${request.city} - ${request.hospitalName}', style: GoogleFonts.outfit(fontSize: 12)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StatusBadge(status: request.status),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Silme Onayı'),
                                content: const Text('Bu talebi yönetici olarak silmek istediğinize emin misiniz?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')),
                                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sil', style: TextStyle(color: Colors.red))),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await requestProvider.deleteRequest(request.id);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: GoogleFonts.outfit(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

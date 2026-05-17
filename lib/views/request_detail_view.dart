import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/blood_request_model.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/blood_request_provider.dart';
import '../widgets/blood_type_badge.dart';
import '../widgets/status_badge.dart';

class RequestDetailView extends StatelessWidget {
  final BloodRequest request;
  const RequestDetailView({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final requestProvider = Provider.of<BloodRequestProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Talep Detayları', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  BloodTypeBadge(bloodType: request.bloodType, fontSize: 32),
                  const SizedBox(height: 20),
                  Text(
                    request.patientName,
                    style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  StatusBadge(status: request.status),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(
                    context,
                    title: 'Hastane Bilgisi',
                    subtitle: request.hospitalName,
                    icon: Icons.local_hospital_rounded,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    context,
                    title: 'Şehir / Bölge',
                    subtitle: request.city,
                    icon: Icons.location_on_rounded,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    context,
                    title: 'İhtiyaç Duyulan Ünite',
                    subtitle: '${request.unitsNeeded} Ünite',
                    icon: Icons.water_drop_rounded,
                    color: Colors.orangeAccent,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    context,
                    title: 'Talep Tarihi',
                    subtitle: DateFormat('dd.MM.yyyy HH:mm').format(request.createdAt),
                    icon: Icons.calendar_today_rounded,
                    color: Colors.grey,
                  ),

                  // Bağışçı bilgisi (Eğer karşılandıysa)
                  if ((request.status == 'karşılandı' || request.status == 'accepted') && request.donorId != null) ...[
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      context,
                      title: 'Bağış Durumu',
                      subtitle: 'Bu talep başarıyla karşılandı!\nBağışçı ID: ${request.donorId!.length > 8 ? request.donorId!.substring(0, 8) : request.donorId}',
                      icon: Icons.favorite_rounded,
                      color: Colors.green,
                    ),
                  ],

                  const SizedBox(height: 40),
                  
                  // Donor Action
                  if (authProvider.user?.role == UserRole.donor && (request.status == 'pending' || request.status == 'bekliyor'))
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await requestProvider.updateRequest(request.id, {
                            'status': 'karşılandı',
                            'donor_id': authProvider.user?.id,
                          });
                          if (context.mounted) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                title: const Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.green, size: 32),
                                    SizedBox(width: 12),
                                    Text('Başarılı!'),
                                  ],
                                ),
                                content: const Text('Talep başarıyla karşılandı! Bir hayat kurtardınız.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Close dialog
                                      Navigator.pop(context); // Close detail view
                                    },
                                    child: const Text('Tamam', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Hata: ${e.toString()}')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.favorite),
                      label: const Text('Bağışçı Ol'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                        textStyle: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),

                  // Requester Action (Delete)
                  if (authProvider.user?.id == request.requesterId)
                    OutlinedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Talebi Sil'),
                            content: const Text('Bu kan talebini silmek istediğinize emin misiniz?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true), 
                                child: const Text('Sil', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await requestProvider.deleteRequest(request.id);
                          if (context.mounted) Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Talebi Sil'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        textStyle: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  Text(
                    'Lütfen hastane ile iletişime geçmeden önce tüm bilgilerin doğruluğundan emin olun.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

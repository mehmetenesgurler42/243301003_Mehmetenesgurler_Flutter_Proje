import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/blood_request_provider.dart';
import '../models/user_model.dart';
import '../widgets/blood_type_badge.dart';

class LogsView extends StatelessWidget {
  const LogsView({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final requestProvider = Provider.of<BloodRequestProvider>(context);
    final user = authProvider.user;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Filter requests based on user history
    final history = requestProvider.requests.where((req) {
      if (user?.role == UserRole.donor) {
        return req.status == 'karşılandı' || req.status == 'accepted'; // Show donations user participated in (simplified for now)
      } else {
        return req.requesterId == user?.id && req.status != 'pending' && req.status != 'bekliyor';
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('İşlem Geçmişi', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_rounded, size: 80, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz bir işlem geçmişiniz bulunmuyor.',
                    style: GoogleFonts.outfit(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final request = history[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade900 : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                  ),
                  child: Row(
                    children: [
                      BloodTypeBadge(bloodType: request.bloodType, fontSize: 14),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              request.patientName,
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              request.hospitalName,
                              style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            DateFormat('dd MMM').format(request.createdAt),
                            style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            request.status == 'karşılandı' || request.status == 'accepted' 
                              ? 'KARŞILANDI' 
                              : request.status.toUpperCase(),
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: (request.status == 'karşılandı' || request.status == 'accepted') ? Colors.green : Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

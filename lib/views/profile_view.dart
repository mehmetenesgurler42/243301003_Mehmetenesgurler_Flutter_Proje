import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../providers/theme_provider.dart';
import '../widgets/blood_type_badge.dart';
import '../services/database_service.dart';
import 'logs_view.dart';
import 'admin_view.dart';
import 'privacy_view.dart';
import 'notifications_view.dart';
import 'help_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = authProvider.user;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profilim', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.redAccent, width: 3),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                          child: Text(
                            user?.fullName.isNotEmpty == true 
                              ? user!.fullName.substring(0, 1).toUpperCase() 
                              : 'U',
                            style: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.redAccent),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                          child: const Icon(Icons.edit, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    user?.fullName ?? 'İsimsiz Kullanıcı',
                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: user?.role == UserRole.donor 
                            ? Colors.green.withValues(alpha: 0.1) 
                            : Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user?.role == UserRole.donor ? 'BAĞIŞÇI' : 'İHTİYAÇ SAHİBİ',
                          style: GoogleFonts.outfit(
                            color: user?.role == UserRole.donor ? Colors.green : Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      if (user?.bloodType != null) ...[
                        const SizedBox(width: 12),
                        BloodTypeBadge(bloodType: user!.bloodType!, fontSize: 12),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  if (user?.role == UserRole.admin)
                    _buildProfileItem(
                      context,
                      icon: Icons.admin_panel_settings_outlined,
                      title: 'Yönetim Paneli',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminView()),
                      ),
                    ),
                  _buildProfileItem(
                    context,
                    icon: Icons.person_outline,
                    title: 'Hesap Bilgileri',
                    onTap: () => _showAccountInfo(context),
                  ),
                  _buildProfileItem(
                    context,
                    icon: Icons.history,
                    title: 'Bağış Geçmişim',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LogsView()),
                    ),
                  ),
                  _buildProfileItem(
                    context,
                    icon: Icons.notifications_none,
                    title: 'Bildirimler',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotificationsView()),
                    ),
                  ),
                  _buildProfileItem(
                    context,
                    icon: Icons.security,
                    title: 'Gizlilik ve Güvenlik',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PrivacyView()),
                    ),
                  ),
                  _buildProfileItem(
                    context,
                    icon: Icons.help_outline,
                    title: 'Yardım Merkezi',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HelpView()),
                    ),
                  ),

                  const SizedBox(height: 32),
                  // Giriş Hareketleri (Login Logs)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Son Giriş Hareketleri',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildLoginLogs(context),

                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      authProvider.signOut();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                      foregroundColor: Colors.redAccent,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      'Çıkış Yap',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Uygulama Versiyonu 1.0.0',
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

  void _showAccountInfo(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Hesap Bilgileri', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildInfoRow(context, 'Ad Soyad', user?.fullName ?? '-'),
            _buildInfoRow(context, 'E-posta', user?.email ?? '-'),
            _buildInfoRow(context, 'Rol', user?.role == UserRole.donor ? 'Bağışçı' : user?.role == UserRole.admin ? 'Yönetici' : 'İhtiyaç Sahibi'),
            _buildInfoRow(context, 'Kan Grubu', user?.bloodType ?? 'Belirtilmemiş'),
            _buildInfoRow(context, 'Kayıt Tarihi', '${user?.createdAt.day}.${user?.createdAt.month}.${user?.createdAt.year}'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(color: Colors.grey, fontSize: 14)),
          Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildProfileItem(BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.redAccent),
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildLoginLogs(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseService().getLoginLogs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ));
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Giriş kaydı bulunamadı.',
              style: GoogleFonts.outfit(color: Colors.grey),
            ),
          );
        }

        final logs = snapshot.data!;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
          ),
          child: Column(
            children: logs.map((log) {
              final date = DateTime.parse(log['created_at']);
              final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(date);
              return ListTile(
                leading: const Icon(Icons.login, color: Colors.blueAccent),
                title: Text('Sisteme Giriş', style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
                subtitle: Text(formattedDate, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                dense: true,
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

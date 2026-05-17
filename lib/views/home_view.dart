import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/auth_provider.dart';
import '../providers/blood_request_provider.dart';
import '../models/user_model.dart';
import '../utils/blood_compatibility.dart';
import '../widgets/blood_type_badge.dart';
import '../widgets/status_badge.dart';
import '../widgets/profile_completion_dialog.dart';
import 'request_form_view.dart';
import 'request_detail_view.dart';
import 'profile_view.dart';
import 'logs_view.dart';
import 'admin_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', '0+', '0-'];
  Timer? _profileReminderTimer;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<BloodRequestProvider>(context, listen: false).fetchRequests();
      _checkProfileCompletion();
    });
  }

  void _checkProfileCompletion() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null && !user.isProfileComplete) {
      // İlk açılışta 3 saniye sonra göster
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) _showProfileReminder();
      });
      // Sonra her 2 dakikada bir hatırlat
      _profileReminderTimer = Timer.periodic(const Duration(minutes: 2), (_) {
        final currentUser = Provider.of<AuthProvider>(context, listen: false).user;
        if (currentUser != null && !currentUser.isProfileComplete && mounted) {
          _showProfileReminder();
        } else {
          _profileReminderTimer?.cancel();
        }
      });
    }
  }

  void _showProfileReminder() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const ProfileCompletionDialog(),
    );
  }

  @override
  void dispose() {
    _profileReminderTimer?.cancel();
    super.dispose();
  }

  /// Bağışçı kan bağışı formu
  void _showDonateDialog(BuildContext context, dynamic request) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null || !user.isProfileComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bağış yapabilmek için profilinizi tamamlayın.')),
      );
      _showProfileReminder();
      return;
    }

    final isCompatible = BloodCompatibility.canDonate(user.bloodType!, request.bloodType);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text('Bağış Uyumluluk Kontrolü', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    BloodTypeBadge(bloodType: user.bloodType!, fontSize: 20),
                    const SizedBox(height: 8),
                    Text('Sizin', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Icon(
                    isCompatible ? Icons.arrow_forward_rounded : Icons.close_rounded,
                    color: isCompatible ? Colors.green : Colors.red,
                    size: 32,
                  ),
                ),
                Column(
                  children: [
                    BloodTypeBadge(bloodType: request.bloodType, fontSize: 20),
                    const SizedBox(height: 8),
                    Text('İhtiyaç', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCompatible 
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    isCompatible ? Icons.check_circle : Icons.warning,
                    color: isCompatible ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isCompatible
                        ? '${user.bloodType} kan grubu, ${request.bloodType} kan grubuna bağış yapabilir.'
                        : '${user.bloodType} kan grubu, ${request.bloodType} kan grubuna bağış yapamaz.',
                      style: GoogleFonts.outfit(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Sağlık bilgileri özeti
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildInfoLine('Yaş', '${user.age}'),
                  _buildInfoLine('Sigara', user.isSmoker == true ? 'Evet ⚠️' : 'Hayır ✅'),
                  _buildInfoLine('Kronik Hastalık', user.hasDiseases == true ? 'Var ⚠️' : 'Yok ✅'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (isCompatible)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final requestProvider = Provider.of<BloodRequestProvider>(ctx, listen: false);
                    try {
                      await requestProvider.updateRequest(request.id, {
                        'status': 'karşılandı',
                        'donor_id': user.id,
                      });
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        
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
                            content: const Text(
                              'Talep başarıyla karşılandı!\nBağışınız için teşekkür ederiz. Bir hayat kurtardınız.',
                              style: TextStyle(fontSize: 16),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Tamam', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                      }
                    } catch (e) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.favorite),
                  label: Text('Bağış Yap', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Kapat', style: GoogleFonts.outfit()),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(color: Colors.grey)),
          Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final requestProvider = Provider.of<BloodRequestProvider>(context);
    final user = authProvider.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isProfileComplete = user?.isProfileComplete ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text('Kan Talepleri', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: _buildDrawer(context, user, authProvider),
      body: RefreshIndicator(
        onRefresh: () => requestProvider.fetchRequests(),
        child: Column(
          children: [
            // Profil tamamlama uyarısı
            if (!isProfileComplete)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: Colors.orange.withValues(alpha: 0.15),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Profilinizi tamamlayın — kısıtlı erişimdesiniz.',
                        style: GoogleFonts.outfit(fontSize: 13, color: Colors.orange.shade800),
                      ),
                    ),
                    TextButton(
                      onPressed: _showProfileReminder,
                      child: Text('Tamamla', style: GoogleFonts.outfit(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            // Arama
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Şehir veya Hasta Adı Ara...',
                  hintStyle: GoogleFonts.outfit(),
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
                onChanged: (val) => requestProvider.setSearchQuery(val),
              ),
            ),
            // Filter Chips
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _bloodTypes.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text('Tümü', style: GoogleFonts.outfit(fontSize: 13)),
                        selected: requestProvider.selectedBloodType == null,
                        selectedColor: Colors.redAccent,
                        labelStyle: GoogleFonts.outfit(
                          color: requestProvider.selectedBloodType == null ? Colors.white : null,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (_) => requestProvider.setFilter(null),
                      ),
                    );
                  }
                  final type = _bloodTypes[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(type, style: GoogleFonts.outfit(fontSize: 13)),
                      selected: requestProvider.selectedBloodType == type,
                      selectedColor: Colors.redAccent,
                      labelStyle: GoogleFonts.outfit(
                        color: requestProvider.selectedBloodType == type ? Colors.white : null,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (selected) => requestProvider.setFilter(selected ? type : null),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            // Request List
            Expanded(
              child: requestProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : requestProvider.requests.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 60, color: Colors.grey.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          Text('Talep bulunamadı.', style: GoogleFonts.outfit(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: requestProvider.requests.length,
                      itemBuilder: (context, index) {
                        final request = requestProvider.requests[index];
                        // Bağışçının kan grubu uyumluluğunu kontrol et
                        final userBlood = user?.bloodType;
                        final isCompatible = userBlood != null 
                          ? BloodCompatibility.canDonate(userBlood, request.bloodType) 
                          : false;
                        
                        return FadeInUp(
                          duration: const Duration(milliseconds: 400),
                          delay: Duration(milliseconds: index * 80),
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 2,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: isProfileComplete
                                ? () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => RequestDetailView(request: request)),
                                  )
                                : () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Detay görmek için profilinizi tamamlayın.')),
                                    );
                                  },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    BloodTypeBadge(bloodType: request.bloodType, fontSize: 16),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            request.patientName,
                                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  '${request.hospitalName}, ${request.city}',
                                                  style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          // Uyumluluk göstergesi
                                          if (user?.role == UserRole.donor && userBlood != null && (request.status == 'pending' || request.status == 'bekliyor')) ...[
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Icon(
                                                  isCompatible ? Icons.check_circle : Icons.cancel,
                                                  size: 14,
                                                  color: isCompatible ? Colors.green : Colors.red.shade300,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  isCompatible ? 'Bağış yapabilirsiniz' : 'Kan grubu uyumsuz',
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 11,
                                                    color: isCompatible ? Colors.green : Colors.red.shade300,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      children: [
                                        StatusBadge(status: request.status),
                                        // Bağış yap butonu (sadece uyumlu bağışçılar için)
                                        if (user?.role == UserRole.donor && isCompatible && (request.status == 'pending' || request.status == 'bekliyor') && isProfileComplete) ...[
                                          const SizedBox(height: 8),
                                          GestureDetector(
                                            onTap: () => _showDonateDialog(context, request),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.redAccent,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text('Bağışla', style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: (user?.role == UserRole.requester && isProfileComplete)
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RequestFormView())),
              icon: const Icon(Icons.add),
              label: Text('Yeni Talep', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  Widget _buildDrawer(BuildContext context, UserModel? user, AuthProvider authProvider) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.1)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.redAccent, width: 2)),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.redAccent.withValues(alpha: 0.15),
                      child: Text(
                        user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : 'U',
                        style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.redAccent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(user?.fullName ?? 'Kullanıcı', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(user?.email ?? '', style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (user?.bloodType != null) ...[
                        BloodTypeBadge(bloodType: user!.bloodType!, fontSize: 10),
                        const SizedBox(width: 8),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: user?.role == UserRole.donor ? Colors.green.withValues(alpha: 0.15) : Colors.blue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user?.role == UserRole.donor ? 'BAĞIŞÇI' : 'İHTİYAÇ SAHİBİ',
                          style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: user?.role == UserRole.donor ? Colors.green : Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _drawerItem(Icons.home_rounded, 'Ana Sayfa', () => Navigator.pop(context)),
                  _drawerItem(Icons.person_rounded, 'Profilim', () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileView()));
                  }),
                  _drawerItem(Icons.history_rounded, 'İşlem Geçmişi', () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LogsView()));
                  }),
                  if (user?.role == UserRole.admin)
                    _drawerItem(Icons.admin_panel_settings, 'Yönetim Paneli', () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminView()));
                    }),
                  const Divider(),
                  _drawerItem(Icons.logout, 'Çıkış Yap', () { authProvider.signOut(); Navigator.pop(context); }, color: Colors.redAccent),
                ],
              ),
            ),
            Padding(padding: const EdgeInsets.all(16), child: Text('v1.0.0', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12))),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.redAccent),
      title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w500, color: color)),
      onTap: onTap,
    );
  }
}

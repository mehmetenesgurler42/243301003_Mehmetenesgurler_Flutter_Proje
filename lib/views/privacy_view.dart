import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';

class PrivacyView extends StatefulWidget {
  const PrivacyView({super.key});

  @override
  State<PrivacyView> createState() => _PrivacyViewState();
}

class _PrivacyViewState extends State<PrivacyView> {
  bool _twoFactorEnabled = false;
  bool _loginNotifications = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Gizlilik ve Güvenlik', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // ─── Hesap Güvenliği ───
          _buildSectionTitle('Hesap Güvenliği'),
          const SizedBox(height: 12),
          _buildCard(context, children: [
            SwitchListTile(
              secondary: const Icon(Icons.security, color: Colors.redAccent),
              title: Text('İki Faktörlü Doğrulama', style: GoogleFonts.outfit()),
              subtitle: Text(
                _twoFactorEnabled 
                  ? 'Hesabınız ekstra güvenlik katmanıyla korunuyor' 
                  : 'Hesabınıza ek güvenlik katmanı ekleyin',
                style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
              ),
              value: _twoFactorEnabled,
              activeColor: Colors.redAccent,
              onChanged: (v) {
                setState(() => _twoFactorEnabled = v);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(v 
                      ? 'İki faktörlü doğrulama etkinleştirildi' 
                      : 'İki faktörlü doğrulama devre dışı bırakıldı'
                    ),
                  ),
                );
              },
            ),
            const Divider(height: 0),
            SwitchListTile(
              secondary: const Icon(Icons.notifications_active, color: Colors.redAccent),
              title: Text('Giriş Bildirimleri', style: GoogleFonts.outfit()),
              subtitle: Text(
                'Yeni bir cihazdan giriş yapıldığında bildirim alın',
                style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
              ),
              value: _loginNotifications,
              activeColor: Colors.redAccent,
              onChanged: (v) {
                setState(() => _loginNotifications = v);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(v 
                      ? 'Giriş bildirimleri etkinleştirildi' 
                      : 'Giriş bildirimleri devre dışı bırakıldı'
                    ),
                  ),
                );
              },
            ),
          ]),

          const SizedBox(height: 24),

          // ─── Şifre Yönetimi ───
          _buildSectionTitle('Şifre Yönetimi'),
          const SizedBox(height: 12),
          _buildCard(context, children: [
            ListTile(
              leading: const Icon(Icons.lock_outline, color: Colors.redAccent),
              title: Text('Şifre Değiştir', style: GoogleFonts.outfit()),
              subtitle: Text(
                'Hesabınızın şifresini güncelleyin',
                style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showChangePasswordDialog(context),
            ),
          ]),

          const SizedBox(height: 24),

          // ─── Veri Yönetimi ───
          _buildSectionTitle('Veri Yönetimi'),
          const SizedBox(height: 12),
          _buildCard(context, children: [
            ListTile(
              leading: const Icon(Icons.download, color: Colors.blueAccent),
              title: Text('Verilerimi İndir', style: GoogleFonts.outfit()),
              subtitle: Text('Tüm kişisel verilerinizi dışa aktarın', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Veri dışa aktarma talebi alındı.')),
                );
              },
            ),
            const Divider(height: 0),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
              title: Text('Hesabımı Sil', style: GoogleFonts.outfit(color: Colors.redAccent)),
              subtitle: Text('Bu işlem geri alınamaz', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
              trailing: const Icon(Icons.chevron_right, color: Colors.redAccent),
              onTap: () => _showDeleteAccountDialog(context),
            ),
          ]),

          const SizedBox(height: 32),
          Text(
            'Gizlilik politikamız hakkında daha fazla bilgi almak için\ndestek@kanbank.app adresine e-posta gönderebilirsiniz.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ─── Şifre Değiştirme Dialogu ───
  void _showChangePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;
    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Icon(Icons.lock_outline, color: Colors.redAccent),
                const SizedBox(width: 12),
                Text('Şifre Değiştir', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              ],
            ),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: oldPasswordController,
                      obscureText: obscureOld,
                      style: GoogleFonts.outfit(),
                      decoration: InputDecoration(
                        labelText: 'Mevcut Şifre',
                        labelStyle: GoogleFonts.outfit(),
                        prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(obscureOld ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                          onPressed: () => setDialogState(() => obscureOld = !obscureOld),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Mevcut şifrenizi girin';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: newPasswordController,
                      obscureText: obscureNew,
                      style: GoogleFonts.outfit(),
                      decoration: InputDecoration(
                        labelText: 'Yeni Şifre',
                        labelStyle: GoogleFonts.outfit(),
                        prefixIcon: const Icon(Icons.lock_open, color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                          onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Yeni şifrenizi girin';
                        if (v.length < 6) return 'Şifre en az 6 karakter olmalı';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: obscureConfirm,
                      style: GoogleFonts.outfit(),
                      decoration: InputDecoration(
                        labelText: 'Yeni Şifre (Tekrar)',
                        labelStyle: GoogleFonts.outfit(),
                        prefixIcon: const Icon(Icons.lock_open, color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                          onPressed: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Şifrenizi tekrar girin';
                        if (v != newPasswordController.text) return 'Şifreler eşleşmiyor';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(ctx),
                child: Text('İptal', style: GoogleFonts.outfit(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;

                        setDialogState(() => isLoading = true);

                        try {
                          final authProvider = Provider.of<AuthProvider>(ctx, listen: false);
                          await authProvider.changePassword(
                            oldPasswordController.text,
                            newPasswordController.text,
                          );

                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Şifreniz başarıyla güncellendi!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          setDialogState(() => isLoading = false);
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Hata: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('Güncelle', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── Hesap Silme Dialogu ───
  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red),
            const SizedBox(width: 12),
            Text('Hesap Silme', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Hesabınızı silmek istediğinize emin misiniz?\n\nBu işlem geri alınamaz ve tüm verileriniz kalıcı olarak silinecektir.',
          style: GoogleFonts.outfit(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('İptal', style: GoogleFonts.outfit(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Hesap silme talebi alındı. 30 gün içinde silinecektir.')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Hesabı Sil', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ─── Yardımcı Widget'lar ───
  Widget _buildSectionTitle(String title) {
    return Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18));
  }

  Widget _buildCard(BuildContext context, {required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100),
      ),
      child: Column(children: children),
    );
  }
}

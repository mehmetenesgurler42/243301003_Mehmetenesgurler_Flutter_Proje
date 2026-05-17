import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpView extends StatelessWidget {
  const HelpView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final faqs = [
      {
        'q': 'Nasıl bağışçı olabilirim?',
        'a': 'Uygulamaya "Bağışçı" rolüyle kayıt olduktan sonra, ana sayfadaki talepleri görüntüleyebilir ve uygun olanlara bağışçı olarak başvurabilirsiniz.',
      },
      {
        'q': 'Kan talebi nasıl oluşturulur?',
        'a': '"İhtiyaç Sahibi" olarak giriş yapın ve sağ alttaki "+" butonuna basarak yeni bir kan talebi formu açabilirsiniz.',
      },
      {
        'q': 'Kan grubumu nasıl değiştirebilirim?',
        'a': 'Profil > Hesap Bilgileri kısmından kan grubunuzu güncelleyebilirsiniz.',
      },
      {
        'q': 'Bağış geçmişimi nerede görebilirim?',
        'a': 'Profil sayfasındaki "Bağış Geçmişim" menüsünden tüm geçmiş bağışlarınızı ve taleplerinizi takip edebilirsiniz.',
      },
      {
        'q': 'Hesabımı nasıl silebilirim?',
        'a': 'Profil > Gizlilik ve Güvenlik > Veri Yönetimi bölümünden "Hesabımı Sil" seçeneğini kullanabilirsiniz.',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Yardım Merkezi', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Sık Sorulan Sorular
          Text('Sık Sorulan Sorular', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 16),
          ...faqs.map((faq) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100),
            ),
            child: ExpansionTile(
              leading: const Icon(Icons.help_outline, color: Colors.redAccent),
              title: Text(faq['q']!, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14)),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                Text(faq['a']!, style: GoogleFonts.outfit(color: Colors.grey, fontSize: 14)),
              ],
            ),
          )),
          const SizedBox(height: 32),

          // İletişim Bilgileri
          Text('Bize Ulaşın', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.email, color: Colors.redAccent),
                  title: Text('E-posta', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                  subtitle: Text('destek@kanbank.app', style: GoogleFonts.outfit(color: Colors.grey)),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.phone, color: Colors.redAccent),
                  title: Text('Telefon', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                  subtitle: Text('0850 123 45 67', style: GoogleFonts.outfit(color: Colors.grey)),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.access_time, color: Colors.redAccent),
                  title: Text('Çalışma Saatleri', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                  subtitle: Text('7/24 Destek', style: GoogleFonts.outfit(color: Colors.grey)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

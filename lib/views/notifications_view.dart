import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  bool _pushEnabled = true;
  bool _emailEnabled = false;
  bool _urgentOnly = false;
  bool _newRequests = true;
  bool _statusUpdates = true;
  bool _donorMatches = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Bildirimler', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSection(context, title: 'Bildirim Kanalları', children: [
            SwitchListTile(
              secondary: const Icon(Icons.notifications_active, color: Colors.redAccent),
              title: Text('Push Bildirimleri', style: GoogleFonts.outfit()),
              subtitle: Text('Anlık bildirimler alın', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
              value: _pushEnabled,
              activeColor: Colors.redAccent,
              onChanged: (v) => setState(() => _pushEnabled = v),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.email_outlined, color: Colors.redAccent),
              title: Text('E-posta Bildirimleri', style: GoogleFonts.outfit()),
              subtitle: Text('Günlük özet e-postası alın', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
              value: _emailEnabled,
              activeColor: Colors.redAccent,
              onChanged: (v) => setState(() => _emailEnabled = v),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection(context, title: 'Bildirim Tercihleri', children: [
            SwitchListTile(
              secondary: const Icon(Icons.warning_amber, color: Colors.orange),
              title: Text('Sadece Acil Talepler', style: GoogleFonts.outfit()),
              value: _urgentOnly,
              activeColor: Colors.redAccent,
              onChanged: (v) => setState(() => _urgentOnly = v),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.add_circle_outline, color: Colors.blue),
              title: Text('Yeni Kan Talepleri', style: GoogleFonts.outfit()),
              value: _newRequests,
              activeColor: Colors.redAccent,
              onChanged: (v) => setState(() => _newRequests = v),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.update, color: Colors.green),
              title: Text('Durum Güncellemeleri', style: GoogleFonts.outfit()),
              value: _statusUpdates,
              activeColor: Colors.redAccent,
              onChanged: (v) => setState(() => _statusUpdates = v),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.favorite, color: Colors.redAccent),
              title: Text('Bağışçı Eşleşmeleri', style: GoogleFonts.outfit()),
              value: _donorMatches,
              activeColor: Colors.redAccent,
              onChanged: (v) => setState(() => _donorMatches = v),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

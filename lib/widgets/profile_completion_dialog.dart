import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';

/// Profili tamamlanmamış kullanıcılar için bilgi toplama dialogu.
/// Kan grubu, yaş, hastalık durumu ve sigara kullanımı bilgilerini alır.
class ProfileCompletionDialog extends StatefulWidget {
  const ProfileCompletionDialog({super.key});

  @override
  State<ProfileCompletionDialog> createState() => _ProfileCompletionDialogState();
}

class _ProfileCompletionDialogState extends State<ProfileCompletionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', '0+', '0-'];
  String? _selectedBloodType;
  bool _hasDiseases = false;
  final _diseaseController = TextEditingController();
  bool _isSmoker = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _selectedBloodType = user?.bloodType;
    if (user?.age != null) _ageController.text = user!.age.toString();
    _hasDiseases = user?.hasDiseases ?? false;
    _diseaseController.text = user?.diseaseDetails ?? '';
    _isSmoker = user?.isSmoker ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_add, color: Colors.redAccent, size: 40),
                ),
                const SizedBox(height: 16),
                Text(
                  'Profilini Tamamla',
                  style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Uygulamayı tam olarak kullanabilmek için lütfen aşağıdaki bilgileri girin.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 24),

                // Kan Grubu
                DropdownButtonFormField<String>(
                  value: _selectedBloodType,
                  style: GoogleFonts.outfit(color: isDark ? Colors.white : Colors.black),
                  dropdownColor: isDark ? Colors.grey.shade900 : Colors.white,
                  decoration: InputDecoration(
                    labelText: 'Kan Grubu',
                    labelStyle: GoogleFonts.outfit(),
                    prefixIcon: const Icon(Icons.water_drop, color: Colors.redAccent),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                  ),
                  items: _bloodTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => _selectedBloodType = v),
                  validator: (v) => v == null ? 'Kan grubunuzu seçin' : null,
                ),
                const SizedBox(height: 16),

                // Yaş
                TextFormField(
                  controller: _ageController,
                  style: GoogleFonts.outfit(),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Yaş',
                    labelStyle: GoogleFonts.outfit(),
                    prefixIcon: const Icon(Icons.cake, color: Colors.redAccent),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Yaşınızı girin';
                    final age = int.tryParse(v);
                    if (age == null || age < 18 || age > 65) return '18-65 yaş arası olmalısınız';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Sigara
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                    border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                  ),
                  child: SwitchListTile(
                    title: Text('Sigara Kullanıyor musunuz?', style: GoogleFonts.outfit(fontSize: 14)),
                    secondary: Icon(Icons.smoking_rooms, color: _isSmoker ? Colors.orange : Colors.grey),
                    value: _isSmoker,
                    activeColor: Colors.redAccent,
                    onChanged: (v) => setState(() => _isSmoker = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 16),

                // Hastalık
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                    border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                  ),
                  child: SwitchListTile(
                    title: Text('Kronik Hastalığınız Var mı?', style: GoogleFonts.outfit(fontSize: 14)),
                    secondary: Icon(Icons.medical_services, color: _hasDiseases ? Colors.red : Colors.grey),
                    value: _hasDiseases,
                    activeColor: Colors.redAccent,
                    onChanged: (v) => setState(() => _hasDiseases = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                if (_hasDiseases) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _diseaseController,
                    style: GoogleFonts.outfit(),
                    decoration: InputDecoration(
                      labelText: 'Hastalık Detayları',
                      labelStyle: GoogleFonts.outfit(),
                      prefixIcon: const Icon(Icons.edit_note, color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                    ),
                    maxLines: 2,
                  ),
                ],
                const SizedBox(height: 24),

                // Kaydet Butonu
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text('Bilgilerimi Kaydet', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Daha Sonra', style: GoogleFonts.outfit(color: Colors.grey)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.updateProfile(
        bloodType: _selectedBloodType,
        age: int.parse(_ageController.text),
        hasDiseases: _hasDiseases,
        diseaseDetails: _hasDiseases ? _diseaseController.text : null,
        isSmoker: _isSmoker,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profiliniz başarıyla güncellendi!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

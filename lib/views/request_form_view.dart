import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/blood_request_model.dart';
import '../providers/auth_provider.dart';
import '../providers/blood_request_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class RequestFormView extends StatefulWidget {
  final BloodRequest? request;
  const RequestFormView({super.key, this.request});

  @override
  State<RequestFormView> createState() => _RequestFormViewState();
}

class _RequestFormViewState extends State<RequestFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _patientNameController;
  late TextEditingController _hospitalController;
  late TextEditingController _cityController;
  late TextEditingController _unitsController;
  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', '0+', '0-'];
  String? _selectedBloodType;
  bool _isForSelf = true; // Kendim için mi yoksa yakınım için mi?

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    _patientNameController = TextEditingController(
      text: widget.request?.patientName ?? authProvider.user?.fullName ?? '',
    );
    _selectedBloodType = widget.request?.bloodType ?? authProvider.user?.bloodType;
    _hospitalController = TextEditingController(text: widget.request?.hospitalName);
    _cityController = TextEditingController(text: widget.request?.city);
    _unitsController = TextEditingController(text: widget.request?.unitsNeeded.toString() ?? '1');
  }

  void _onForSelfChanged(bool isForSelf) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    setState(() {
      _isForSelf = isForSelf;
      if (isForSelf) {
        // Kendim için: Profildeki bilgileri otomatik doldur
        _patientNameController.text = authProvider.user?.fullName ?? '';
        _selectedBloodType = authProvider.user?.bloodType;
      } else {
        // Yakınım için: Alanları temizle, kullanıcı kendisi dolduracak
        _patientNameController.clear();
        _selectedBloodType = null;
      }
    });
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final requestProvider = Provider.of<BloodRequestProvider>(context, listen: false);

      final newRequest = BloodRequest(
        id: widget.request?.id ?? '',
        requesterId: authProvider.user!.id,
        patientName: _patientNameController.text.trim(),
        bloodType: _selectedBloodType!,
        hospitalName: _hospitalController.text.trim(),
        city: _cityController.text.trim(),
        unitsNeeded: int.parse(_unitsController.text),
        status: widget.request?.status ?? 'pending',
        createdAt: widget.request?.createdAt ?? DateTime.now(),
      );

      try {
        if (widget.request == null) {
          await requestProvider.addRequest(newRequest);
        } else {
          await requestProvider.updateRequest(widget.request!.id, newRequest.toMap());
        }
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.request == null ? 'Yeni Talep Oluştur' : 'Talebi Düzenle',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Kendim / Yakınım için toggle
            if (widget.request == null) ...[
              Text(
                'Bu talep kimin için?',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _onForSelfChanged(true),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _isForSelf 
                            ? Colors.redAccent.withValues(alpha: 0.15) 
                            : (isDark ? Colors.grey.shade900 : Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isForSelf ? Colors.redAccent : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.person, color: _isForSelf ? Colors.redAccent : Colors.grey, size: 28),
                            const SizedBox(height: 8),
                            Text(
                              'Kendim İçin',
                              style: GoogleFonts.outfit(
                                fontWeight: _isForSelf ? FontWeight.bold : FontWeight.normal,
                                color: _isForSelf ? Colors.redAccent : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _onForSelfChanged(false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: !_isForSelf 
                            ? Colors.blueAccent.withValues(alpha: 0.15) 
                            : (isDark ? Colors.grey.shade900 : Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: !_isForSelf ? Colors.blueAccent : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.family_restroom, color: !_isForSelf ? Colors.blueAccent : Colors.grey, size: 28),
                            const SizedBox(height: 8),
                            Text(
                              'Yakınım İçin',
                              style: GoogleFonts.outfit(
                                fontWeight: !_isForSelf ? FontWeight.bold : FontWeight.normal,
                                color: !_isForSelf ? Colors.blueAccent : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
            TextFormField(
              controller: _patientNameController,
              style: GoogleFonts.outfit(),
              decoration: const InputDecoration(
                labelText: 'Hasta Adı Soyadı',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              enabled: !_isForSelf || widget.request != null,
              validator: (v) => v!.isEmpty ? 'Lütfen hasta adını girin' : null,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedBloodType,
              style: GoogleFonts.outfit(color: isDark ? Colors.white : Colors.black87),
              dropdownColor: isDark ? Colors.grey.shade900 : Colors.white,
              decoration: const InputDecoration(
                labelText: 'Kan Grubu',
                prefixIcon: Icon(Icons.water_drop, color: Colors.red),
                border: OutlineInputBorder(),
              ),
              items: _bloodTypes.map((type) => DropdownMenuItem(
                value: type,
                child: Text(type),
              )).toList(),
              onChanged: (_isForSelf && widget.request == null) ? null : (val) => setState(() => _selectedBloodType = val),
              validator: (v) => v == null ? 'Lütfen kan grubu seçin' : null,
            ),
            if (_isForSelf && widget.request == null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Kan grubunuz profilinizden otomatik alındı.',
                  style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                ),
              ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _hospitalController,
              style: GoogleFonts.outfit(),
              decoration: const InputDecoration(
                labelText: 'Hastane Adı',
                prefixIcon: Icon(Icons.local_hospital),
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? 'Hastane adı boş bırakılamaz' : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _cityController,
              style: GoogleFonts.outfit(),
              decoration: const InputDecoration(
                labelText: 'Şehir',
                prefixIcon: Icon(Icons.location_city),
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? 'Lütfen şehir girin' : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _unitsController,
              style: GoogleFonts.outfit(),
              decoration: const InputDecoration(
                labelText: 'İhtiyaç Duyulan Ünite (1-10)',
                prefixIcon: Icon(Icons.numbers),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Ünite sayısı girin';
                final n = int.tryParse(v);
                if (n == null || n < 1 || n > 10) return '1 ile 10 arasında bir sayı girin';
                return null;
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/blood_request_model.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Tüm kan taleplerini getir
  Future<List<BloodRequest>> getBloodRequests() async {
    final response = await _supabase
        .from('blood_requests')
        .select()
        .order('created_at', ascending: false);
    
    return (response as List).map((e) => BloodRequest.fromMap(e)).toList();
  }

  // Yeni kan talebi oluştur
  Future<void> createBloodRequest(BloodRequest request) async {
    await _supabase.from('blood_requests').insert(request.toMap());
    await logAction('create_request', 'Created request for ${request.patientName}');
  }

  // Kan talebini güncelle
  Future<void> updateBloodRequest(String id, Map<String, dynamic> data) async {
    await _supabase.from('blood_requests').update(data).eq('id', id);
    await logAction('update_request', 'Updated request $id');
  }

  // Kan talebini sil
  Future<void> deleteBloodRequest(String id) async {
    await _supabase.from('blood_requests').delete().eq('id', id);
    await logAction('delete_request', 'Deleted request $id');
  }

  // İşlem Logu Kaydet
  Future<void> logAction(String action, String details) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      await _supabase.from('logs').insert({
        'user_id': userId,
        'action': action,
        'details': details,
      });
    }
  }

  // Profil Oluştur (Kayıt olurken)
  Future<void> createProfile(String id, String email, String fullName, String role, String? bloodType) async {
    await _supabase.from('profiles').insert({
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'blood_type': bloodType,
    });
  }

  // Sadece Kullanıcının Login Loglarını Getir
  Future<List<Map<String, dynamic>>> getLoginLogs() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('logs')
        .select()
        .eq('user_id', userId)
        .eq('action', 'login')
        .order('created_at', ascending: false)
        .limit(10);
    
    return List<Map<String, dynamic>>.from(response);
  }

  /// Veritabanına örnek kan talepleri ekle (eğer boşsa)
  Future<void> seedSampleRequests() async {
    final existing = await _supabase.from('blood_requests').select().limit(1);
    if ((existing as List).isNotEmpty) return; // Zaten veri var

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final sampleRequests = [
      {'patient_name': 'Ahmet Yılmaz', 'blood_type': 'A+', 'hospital_name': 'İstanbul Üniversitesi Tıp Fakültesi', 'city': 'İstanbul', 'units_needed': 3, 'status': 'bekliyor', 'requester_id': userId},
      {'patient_name': 'Fatma Demir', 'blood_type': 'B-', 'hospital_name': 'Ankara Şehir Hastanesi', 'city': 'Ankara', 'units_needed': 2, 'status': 'bekliyor', 'requester_id': userId},
      {'patient_name': 'Mehmet Kaya', 'blood_type': '0+', 'hospital_name': 'Ege Üniversitesi Hastanesi', 'city': 'İzmir', 'units_needed': 5, 'status': 'bekliyor', 'requester_id': userId},
      {'patient_name': 'Ayşe Çelik', 'blood_type': 'AB+', 'hospital_name': 'Hacettepe Üniversitesi', 'city': 'Ankara', 'units_needed': 1, 'status': 'karşılandı', 'requester_id': userId},
      {'patient_name': 'Ali Öztürk', 'blood_type': '0-', 'hospital_name': 'Bursa Yüksek İhtisas Hastanesi', 'city': 'Bursa', 'units_needed': 4, 'status': 'bekliyor', 'requester_id': userId},
      {'patient_name': 'Zeynep Arslan', 'blood_type': 'A-', 'hospital_name': 'Antalya Eğitim Araştırma Hastanesi', 'city': 'Antalya', 'units_needed': 2, 'status': 'bekliyor', 'requester_id': userId},
      {'patient_name': 'Mustafa Koç', 'blood_type': 'B+', 'hospital_name': 'Konya Şehir Hastanesi', 'city': 'Konya', 'units_needed': 3, 'status': 'bekliyor', 'requester_id': userId},
      {'patient_name': 'Elif Şahin', 'blood_type': 'AB-', 'hospital_name': 'Gaziantep Üniversitesi Hastanesi', 'city': 'Gaziantep', 'units_needed': 1, 'status': 'bekliyor', 'requester_id': userId},
    ];

    await _supabase.from('blood_requests').insert(sampleRequests);
  }
}


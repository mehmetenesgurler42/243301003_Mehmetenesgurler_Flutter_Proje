import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Mevcut oturumu al
  Session? get currentSession => _supabase.auth.currentSession;

  // Kayıt Ol
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? bloodType,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': role,
        if (bloodType != null) 'blood_type': bloodType,
      },
    );
    return response;
  }

  // Giriş Yap
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Çıkış Yap
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}

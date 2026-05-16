import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();
  
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => Supabase.instance.client.auth.currentSession != null;

  AuthProvider() {
    _loadUser();
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        _updateUserFromSession(session);
      } else {
        _user = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUser() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      _updateUserFromSession(session);
    }
  }

  void _updateUserFromSession(Session session) {
    final userData = session.user.userMetadata;
    _user = UserModel(
      id: session.user.id,
      email: session.user.email ?? '',
      fullName: userData?['full_name'] ?? '',
      role: UserModel.parseRoleFromString(userData?['role']),
      bloodType: userData?['blood_type'],
      age: userData?['age'],
      hasDiseases: userData?['has_diseases'],
      diseaseDetails: userData?['disease_details'],
      isSmoker: userData?['is_smoker'],
      createdAt: DateTime.parse(session.user.createdAt),
    );
    notifyListeners();
  }

  Future<void> signUp(String email, String password, String fullName, UserRole role, {String? bloodType}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        role: role.name,
        bloodType: bloodType,
      );
      
      final userId = response.user?.id;
      if (userId != null) {
        // Profili veritabanı tablosuna da ekle
        await _dbService.createProfile(userId, email, fullName, role.name, bloodType);
      }
      
      await _dbService.logAction('register', 'User registered as ${role.name}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.signIn(email: email, password: password);
      await _loadUser();
      await _dbService.logAction('login', 'User logged in');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _dbService.logAction('logout', 'User logged out');
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  /// Profil bilgilerini (kan grubu, yaş, hastalık, sigara) güncelle
  Future<void> updateProfile({
    String? bloodType,
    int? age,
    bool? hasDiseases,
    String? diseaseDetails,
    bool? isSmoker,
  }) async {
    final updates = <String, dynamic>{};
    if (bloodType != null) updates['blood_type'] = bloodType;
    if (age != null) updates['age'] = age;
    if (hasDiseases != null) updates['has_diseases'] = hasDiseases;
    if (diseaseDetails != null) updates['disease_details'] = diseaseDetails;
    if (isSmoker != null) updates['is_smoker'] = isSmoker;

    await Supabase.instance.client.auth.updateUser(
      UserAttributes(data: updates),
    );

    // Session'ı tekrar yükle
    await Supabase.instance.client.auth.refreshSession();
    await _loadUser();
    await _dbService.logAction('profile_update', 'User updated profile');
  }

  /// Şifre değiştir
  Future<void> changePassword(String oldPassword, String newPassword) async {
    final email = _user?.email;
    if (email == null) throw Exception('Oturum bulunamadı');

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: oldPassword,
      );
    } catch (e) {
      throw Exception('Mevcut şifreniz hatalı');
    }

    await Supabase.instance.client.auth.updateUser(
      UserAttributes(password: newPassword),
    );

    await _dbService.logAction('password_change', 'User changed password');
  }
}

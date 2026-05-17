import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLogin = true;
  UserRole _selectedRole = UserRole.donor;
  String? _selectedBloodType;

  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', '0+', '0-'];
  final _formKey = GlobalKey<FormState>();

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      if (_isLogin) {
        await authProvider.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        if (_selectedRole == UserRole.donor && _selectedBloodType == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lütfen kan grubunuzu seçin')),
          );
          return;
        }
        await authProvider.signUp(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nameController.text.trim(),
          _selectedRole,
          bloodType: _selectedRole == UserRole.donor ? _selectedBloodType : null,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kayıt başarılı! Giriş yapabilirsiniz.')),
          );
        }
        setState(() => _isLogin = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${e.toString()}')),
        );
      }
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.outfit(
        color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
      ),
      prefixIcon: Icon(icon, color: Colors.redAccent),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      filled: true,
      fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: const Icon(Icons.bloodtype_rounded, size: 100, color: Colors.redAccent),
                ),
                const SizedBox(height: 16),
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    _isLogin ? 'Hoş Geldiniz' : 'Yeni Hesap Oluştur',
                    style: GoogleFonts.outfit(
                      fontSize: 28, 
                      fontWeight: FontWeight.bold, 
                      letterSpacing: -0.5,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin ? 'Devam etmek için giriş yapın' : 'Hemen aramıza katılın',
                  style: GoogleFonts.outfit(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, 
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),
                if (!_isLogin) ...[
                  TextFormField(
                    controller: _nameController,
                    style: GoogleFonts.outfit(color: isDark ? Colors.white : Colors.black),
                    decoration: _inputDecoration('Ad Soyad', Icons.person_outline, context),
                    validator: (v) => v!.isEmpty ? 'Lütfen adınızı girin' : null,
                  ),
                  const SizedBox(height: 20),
                ],
                TextFormField(
                  controller: _emailController,
                  style: GoogleFonts.outfit(color: isDark ? Colors.white : Colors.black),
                  decoration: _inputDecoration('E-posta', Icons.email_outlined, context),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v!.isEmpty) return 'E-posta boş bırakılamaz';
                    if (!v.contains('@')) return 'Geçerli bir e-posta girin';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  style: GoogleFonts.outfit(color: isDark ? Colors.white : Colors.black),
                  decoration: _inputDecoration('Şifre', Icons.lock_outline, context),
                  obscureText: true,
                  validator: (v) {
                    if (v!.isEmpty) return 'Şifre boş bırakılamaz';
                    if (v.length < 6) return 'Şifre en az 6 karakter olmalı';
                    return null;
                  },
                ),
                if (!_isLogin) ...[
                  const SizedBox(height: 32),
                  Text(
                    'Rolünüzü Seçin:', 
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Radio<UserRole>(
                          value: UserRole.donor,
                          groupValue: _selectedRole,
                          activeColor: Colors.redAccent,
                          onChanged: (v) => setState(() => _selectedRole = v!),
                        ),
                        Text('Bağışçı', style: GoogleFonts.outfit(color: isDark ? Colors.white : Colors.black)),
                        const SizedBox(width: 20),
                        Radio<UserRole>(
                          value: UserRole.requester,
                          groupValue: _selectedRole,
                          activeColor: Colors.redAccent,
                          onChanged: (v) => setState(() => _selectedRole = v!),
                        ),
                        Text('İhtiyaç Sahibi', style: GoogleFonts.outfit(color: isDark ? Colors.white : Colors.black)),
                      ],
                    ),
                  ),
                  // Bağışçı ise kan grubu seçtir
                  if (_selectedRole == UserRole.donor) ...[
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedBloodType,
                      style: GoogleFonts.outfit(color: isDark ? Colors.white : Colors.black),
                      dropdownColor: isDark ? Colors.grey.shade900 : Colors.white,
                      decoration: _inputDecoration('Kan Grubunuz', Icons.water_drop, context),
                      items: _bloodTypes.map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      )).toList(),
                      onChanged: (val) => setState(() => _selectedBloodType = val),
                      validator: (v) => v == null ? 'Lütfen kan grubunuzu seçin' : null,
                    ),
                  ],
                ],
                const SizedBox(height: 40),
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    if (auth.isLoading) return const CircularProgressIndicator(color: Colors.redAccent);
                    return ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        _isLogin ? 'Giriş Yap' : 'Kayıt Ol',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(
                    _isLogin ? 'Hesabınız yok mu? Kayıt Olun' : 'Zaten hesabınız var mı? Giriş Yapın',
                    style: GoogleFonts.outfit(color: Colors.redAccent, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

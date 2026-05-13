# Kan Bağışı ve Takip Uygulaması

Bu uygulama, kan bağışı yapmak isteyenlerle kan ihtiyacı olanları buluşturan bir platformdur.

## Öğrenci Bilgileri
- **Ad Soyad:** [MEHMET ENES GURLER]
- **Öğrenci No:** [243301003]

## Uygulama Özellikleri
- **Rol Tabanlı Erişim**: Bağışçı ve İhtiyaç Sahibi rolleri için farklılaştırılmış kullanıcı deneyimi.
- **Supabase Entegrasyonu**: Kimlik doğrulama, gerçek zamanlı veri saklama ve işlem loglama.
- **5+ Ekran**: 
  - Giriş/Kayıt Ekranı (AuthView)
  - Ana Liste Ekranı (HomeView)
  - Talep Detay Ekranı (RequestDetailView)
  - Yeni Talep / Düzenleme Formu (RequestFormView)
  - Kullanıcı Profil Ekranı (ProfileView)
- **İşlem Logları**: Uygulama içinde yapılan her kritik işlem (kayıt, giriş, talep oluşturma vb.) veritabanında loglanır.
- **Oturum Devamlılığı**: Uygulama kapatılsa bile kullanıcı oturumu korunur.

## Kullanılan Paketler
- `supabase_flutter`: Veritabanı ve Kimlik doğrulama.
- `provider`: Durum yönetimi (State Management).
- `google_fonts`: Modern tipografi.
- `font_awesome_flutter`: Zengin ikon seti.
- `animate_do`: UI animasyonları.
- `intl`: Tarih ve sayı formatlama.
- `glassmorphism`: Modern tasarım bileşenleri.

## Test Hesapları
Uygulamayı test etmek için aşağıdaki hesapları kullanabilirsiniz:

### 1. Bağışçı (Donor) Rolü
- **E-posta:** test@test.com
- **Şifre:** test123456

### 2. İhtiyaç Sahibi (Requester) Rolü
- **E-posta:** test2@test.com
- **Ş1fre:** test123456

## Ekran Görüntüleri
![Giriş Ekranı](https://via.placeholder.com/200x400?text=Giris+Ekrani)
![Ana Liste](https://via.placeholder.com/200x400?text=Ana+Liste)
![Profil](https://via.placeholder.com/200x400?text=Profil)

## Kurulum
1. `lib/main.dart` içindeki Supabase URL ve Anon Key bilgilerini güncelleyin.
2. `flutter pub get` komutunu çalıştırın.
3. `flutter run` ile uygulamayı başlatın.

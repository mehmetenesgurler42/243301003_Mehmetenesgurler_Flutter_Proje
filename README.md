# 🩸 Kan Bağışı ve Takip Uygulaması

Bu mobil uygulama, kan bağışı yapmak isteyen (Bağışçı) bireyler ile acil kan ihtiyacı olan (İhtiyaç Sahibi) insanları modern, hızlı ve güvenilir bir arayüzde bir araya getiren bir platformdur.

---

## 🎓 Proje ve Öğrenci Bilgileri
- **Ad Soyad:** Mehmet Enes Gürler
- **Öğrenci No:** 243301003

---

## ✨ Uygulama Özellikleri

*   👤 **Rol Tabanlı Erişim:** Bağışçı (Donor) ve İhtiyaç Sahibi (Requester) rolleri için tamamen farklılaştırılmış ve özelleştirilmiş kullanıcı deneyimi.
*   ⚡ **Supabase Entegrasyonu:** Güvenli kimlik doğrulama (Auth), gerçek zamanlı veri akışı ve anlık işlem senkronizasyonu.
*   📜 **İşlem Logları:** Güvenlik ve takip amacıyla uygulama içinde yapılan her kritik işlem (kayıt, giriş, talep oluşturma vb.) veritabanında loglanır.
*   🔒 **Oturum Devamlılığı (Session Persistence):** Kullanıcı uygulamayı kapatsa bile oturumu korunur, her açılışta tekrar giriş yapması gerekmez.
*   🎨 **Modern Arayüz Tasarımı:** Kullanıcı dostu, animasyonlu ve "Glassmorphic" modern tasarım trendlerine uygun UI bileşenleri.

---

## 📱 Uygulama Ekranları (5+ Ekran)

Uygulama, modüler ve sürdürülebilir bir mimariyle geliştirilmiş olup şu temel ekranları içerir:
1.  **Giriş/Kayıt Ekranı (`AuthView`):** Kullanıcıların sisteme giriş yapmasını ve rollerine göre kayıt olmasını sağlar.
2.  **Ana Liste Ekranı (`HomeView`):** Aktif kan taleplerinin listelendiği, filtrelendiği ana akış paneli.
3.  **Talep Detay Ekranı (`RequestDetailView`):** Seçilen kan talebinin detaylarını ve iletişim bilgilerini gösteren ekran.
4.  **Yeni Talep / Düzenleme Formu (`RequestFormView`):** İhtiyaç sahiplerinin yeni kan talebi oluşturabileceği ya da mevcut taleplerini güncelleyebileceği form.
5.  **Kullanıcı Profil Ekranı (`ProfileView`):** Kullanıcı bilgilerinin, bağış geçmişinin ve çıkış yapma butonunun yer aldığı alan.

---

## 🛠️ Kullanılan Paketler ve Teknoloji Yığını

Projenin geliştirilmesinde Flutter SDK'sının yanı sıra aşağıdaki popüler paketlerden yararlanılmıştır:

| Paket Adı | Kullanım Amacı |
| :--- | :--- |
| `supabase_flutter` | Veritabanı yönetimi, Gerçek Zamanlı (Realtime) veri ve Kimlik Doğrulama (Auth) |
| `provider` | State Management (Durum Yönetimi) ve veri akışı |
| `google_fonts` | Modern ve okunabilir tipografi |
| `font_awesome_flutter` | Zengin ve tematik ikon setleri |
| `animate_do` | Akıcı ve göze hoş gelen UI/UX animasyonları |
| `intl` | Yerelleştirme, tarih ve sayı formatlama işlemleri |
| `glassmorphism` | Modern cam efekti (Glassmorphism) tasarımı |

---

## 🔐 Test Hesapları

Uygulamayı hızlıca test edebilmeniz için hazır tanımlanmış roller ve hesap bilgileri aşağıdadır:

### 1. Bağışçı (Donor) Rolü
*   **E-posta:** `test@test.com`
*   **Şifre:** `test123456`

### 2. İhtiyaç Sahibi (Requester) Rolü
*   **E-posta:** `test2@test.com`
*   **Şifre:** `test123456`

---

## 📸 Ekran Görüntüleri

| Giriş Ekranı | Ana Liste | Profil Ekranı |
| :---: | :---: | :---: |
| ![Giriş Ekranı](https://via.placeholder.com/200x400?text=Giris+Ekrani) | ![Ana Liste](https://via.placeholder.com/200x400?text=Ana+Liste) | ![Profil](https://via.placeholder.com/200x400?text=Profil) |

---

## 🚀 Kurulum ve Çalıştırma

Projeyi yerel ortamınızda çalıştırmak için aşağıdaki adımları sırasıyla uygulayabilirsiniz:

1.  **Supabase Bilgilerini Güncelleyin:**
    `lib/main.dart` (veya ilgili yapılandırma) dosyasını açarak kendi Supabase URL ve Anon Key bilgilerinizi ekleyin:
    ```dark
    await Supabase.initialize(
      url: 'YOUR_SUPABASE_URL',
      anonKey: 'YOUR_SUPABASE_ANON_KEY',
    );
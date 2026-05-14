/// Kan grubu uyumluluk tablosu
/// Her kan grubunun hangi gruplara bağış yapabileceğini ve
/// hangi gruplardan kan alabileceğini tanımlar.
class BloodCompatibility {
  // Bir kan grubunun hangi gruplara bağış yapabileceği
  static const Map<String, List<String>> canDonateTo = {
    '0-': ['0-', '0+', 'A-', 'A+', 'B-', 'B+', 'AB-', 'AB+'], // Evrensel verici
    '0+': ['0+', 'A+', 'B+', 'AB+'],
    'A-': ['A-', 'A+', 'AB-', 'AB+'],
    'A+': ['A+', 'AB+'],
    'B-': ['B-', 'B+', 'AB-', 'AB+'],
    'B+': ['B+', 'AB+'],
    'AB-': ['AB-', 'AB+'],
    'AB+': ['AB+'],
  };

  // Bir kan grubunun hangi gruplardan kan alabileceği
  static const Map<String, List<String>> canReceiveFrom = {
    '0-': ['0-'],
    '0+': ['0-', '0+'],
    'A-': ['0-', 'A-'],
    'A+': ['0-', '0+', 'A-', 'A+'],
    'B-': ['0-', 'B-'],
    'B+': ['0-', '0+', 'B-', 'B+'],
    'AB-': ['0-', 'A-', 'B-', 'AB-'],
    'AB+': ['0-', '0+', 'A-', 'A+', 'B-', 'B+', 'AB-', 'AB+'], // Evrensel alıcı
  };

  /// Bağışçı [donorType] kan grubundaki kişi, [recipientType] kan grubuna bağış yapabilir mi?
  static bool canDonate(String donorType, String recipientType) {
    return canDonateTo[donorType]?.contains(recipientType) ?? false;
  }

  /// [recipientType] kan grubundaki kişi, [donorType] kan grubundan kan alabilir mi?
  static bool canReceive(String recipientType, String donorType) {
    return canReceiveFrom[recipientType]?.contains(donorType) ?? false;
  }

  /// Bir talep için uyumlu bağışçı kan gruplarını döndür
  static List<String> compatibleDonors(String neededBloodType) {
    return canReceiveFrom[neededBloodType] ?? [];
  }

  /// Bir bağışçının bağış yapabileceği kan gruplarını döndür
  static List<String> compatibleRecipients(String donorBloodType) {
    return canDonateTo[donorBloodType] ?? [];
  }

  /// Uyumluluk önceliği: 0 = aynı grup, 1 = uyumlu, -1 = uyumsuz
  static int compatibilityPriority(String donorType, String recipientType) {
    if (donorType == recipientType) return 0; // En yüksek öncelik
    if (canDonate(donorType, recipientType)) return 1; // Uyumlu
    return -1; // Uyumsuz
  }
}

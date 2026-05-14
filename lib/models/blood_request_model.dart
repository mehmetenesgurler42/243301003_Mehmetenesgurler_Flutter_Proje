class BloodRequest {
  final String id;
  final String requesterId;
  final String? donorId;
  final String patientName;
  final String bloodType;
  final String hospitalName;
  final String city;
  final int unitsNeeded;
  final String status; // 'pending', 'accepted', 'completed'
  final DateTime createdAt;

  BloodRequest({
    required this.id,
    required this.requesterId,
    this.donorId,
    required this.patientName,
    required this.bloodType,
    required this.hospitalName,
    required this.city,
    required this.unitsNeeded,
    required this.status,
    required this.createdAt,
  });

  factory BloodRequest.fromMap(Map<String, dynamic> map) {
    return BloodRequest(
      id: map['id'],
      requesterId: map['requester_id'],
      donorId: map['donor_id'],
      patientName: map['patient_name'],
      bloodType: map['blood_type'],
      hospitalName: map['hospital_name'],
      city: map['city'],
      unitsNeeded: map['units_needed'],
      status: map['status'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'requester_id': requesterId,
      'donor_id': donorId,
      'patient_name': patientName,
      'blood_type': bloodType,
      'hospital_name': hospitalName,
      'city': city,
      'units_needed': unitsNeeded,
      'status': status,
    };
  }
}
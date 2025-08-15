class WorkEntry {
  int? id;
  String userId;
  String date; // yyyy-MM-dd
  double latitude;
  double longitude;
  String address;
  String unitNumber;
  String status; // completed | incomplete
  double meters;
  String photoBeforePath;
  String photoAfterPath;
  String startTime; // HH:mm
  String endTime; // HH:mm
  String notes;
  String invoiceCode; // modificabile dal supervisore

  WorkEntry({
    this.id,
    required this.userId,
    required this.date,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.unitNumber,
    required this.status,
    required this.meters,
    required this.photoBeforePath,
    required this.photoAfterPath,
    required this.startTime,
    required this.endTime,
    required this.notes,
    this.invoiceCode = '',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'date': date,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'unitNumber': unitNumber,
        'status': status,
        'meters': meters,
        'photoBeforePath': photoBeforePath,
        'photoAfterPath': photoAfterPath,
        'startTime': startTime,
        'endTime': endTime,
        'notes': notes,
        'invoiceCode': invoiceCode,
      };

  factory WorkEntry.fromMap(Map<String, dynamic> map) => WorkEntry(
        id: map['id'] as int?,
        userId: map['userId'] as String,
        date: map['date'] as String,
        latitude: (map['latitude'] as num).toDouble(),
        longitude: (map['longitude'] as num).toDouble(),
        address: map['address'] as String,
        unitNumber: map['unitNumber'] as String,
        status: map['status'] as String,
        meters: (map['meters'] as num).toDouble(),
        photoBeforePath: map['photoBeforePath'] as String,
        photoAfterPath: map['photoAfterPath'] as String,
        startTime: map['startTime'] as String,
        endTime: map['endTime'] as String,
        notes: map['notes'] as String,
        invoiceCode: map['invoiceCode'] as String? ?? '',
      );
}

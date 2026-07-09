class DriverModel {
  final int id;
  final String name;
  final String phoneNumber;
  final String licenseNumber;
  final String status;
  DriverModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.licenseNumber,
    required this.status,
  });
  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['driverId'] ?? json['id'],
      name: json['driverName'] ?? json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      licenseNumber: json['licenseNumber'] ?? '',
      status: json['status'] ?? 'active',
    );
  }
  Map<String, dynamic> toJson()=>{
'id': id,
'name':name,
'phoneNumber':phoneNumber,
'licenseNumber':licenseNumber,
'status':status
  };
}

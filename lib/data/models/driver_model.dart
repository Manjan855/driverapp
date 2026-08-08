// class DriverModel {
//   final int id;
//   final String name;
//   final String phoneNumber;
//   final String licenseNumber;
//   final String status;
//   final String? email; // ← new
//   final String? photoPath; // ← new (local file path after upload)

//   DriverModel({
//     required this.id,
//     required this.name,
//     required this.phoneNumber,
//     required this.licenseNumber,
//     required this.status,
//     this.email,
//     this.photoPath,
//   });

// //   factory DriverModel.fromJson(Map<String, dynamic> json) {
// //     return DriverModel(
// //       id: json['driverId'] ?? json['id'],
// //       name: json['driverName'] ?? json['name'] ?? '',
// //       phoneNumber: json['phoneNumber'] ?? '',
// //       licenseNumber: json['licenseNumber'] ?? '',
// //       status: json['status'] ?? 'active',
// //       email: json['email'],
// //       photoPath: json['photoPath'],
// //     );
// //   }

// //   Map<String, dynamic> toJson() => {
// //     'id': id,
// //     'name': name,
// //     'phoneNumber': phoneNumber,
// //     'licenseNumber': licenseNumber,
// //     'status': status,
// //     'email': email,
// //     'photoPath': photoPath,
// //   };

// //   // copyWith — lets us update individual fields without recreating the whole object
// //   DriverModel copyWith({String? name, String? email, String? photoPath}) {
// //     return DriverModel(
// //       id: id,
// //       name: name ?? this.name,
// //       phoneNumber: phoneNumber,
// //       licenseNumber: licenseNumber,
// //       status: status,
// //       email: email ?? this.email,
// //       photoPath: photoPath ?? this.photoPath,
// //     );
// //   }
// // }
// factory DriverModel.fromJson(Map<String, dynamic> json) {
//   return DriverModel(
//     id: json['driverId'] ?? json['id'],
//     // Backend uses 'driverName' per the Prisma schema
//     name: json['driverName'] ?? json['name'] ?? '',
//     phoneNumber: json['phoneNumber'] ?? '',
//     licenseNumber: json['licenseNumber'] ?? '',
//     status: json['status'] ?? 'active',
//     email: json['email'],
//     photoPath: json['photoUrl'] ?? json['photoPath'],
//   );
// }}
class DriverModel {
  final int id;
  final String name;
  final String phoneNumber;
  final String licenseNumber;
  final String status;
  final String? email;
  final String? photoPath;

  DriverModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.licenseNumber,
    required this.status,
    this.email,
    this.photoPath,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['driverId'] ?? json['id'],
      name: json['driverName'] ?? json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      licenseNumber: json['licenseNumber'] ?? '',
      status: json['status'] ?? 'active',
      email: json['email'],
      photoPath: json['photoUrl'] ?? json['photoPath'],
    );
  }

  // ✅ toJson — needed by AuthNotifier.updateDriver to save to secure storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phoneNumber': phoneNumber,
    'licenseNumber': licenseNumber,
    'status': status,
    'email': email,
    'photoPath': photoPath,
  };

  // ✅ copyWith — needed by EditProfileScreen to update individual fields
  DriverModel copyWith({String? name, String? email, String? photoPath}) {
    return DriverModel(
      id: id,
      name: name ?? this.name,
      phoneNumber: phoneNumber,
      licenseNumber: licenseNumber,
      status: status,
      email: email ?? this.email,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}

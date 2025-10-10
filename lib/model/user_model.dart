import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String empId;
  final String name;
  final String email;
  final String branch;
  final String role;
  final String password;
  final String? filePath;

  const User({
    required this.empId,
    required this.name,
    required this.email,
    required this.branch,
    required this.role,
    required this.password,
    this.filePath,
  });

  @override
  List<Object?> get props => [empId, name, email, branch, role, password, filePath];

  // helper for debugging
  @override
  String toString() {
    return 'User(empId: $empId, name: $name, email: $email, branch: $branch, role: $role, file: $filePath)';
  }

  Map<String, Object?> toMap() {
    return {
      'empId': empId,
      'name': name,
      'email': email,
      'branch': branch,
      'role': role,
      'password': password,
      'filepath': filePath,
    };
  }

  factory User.fromMap(Map<String, Object?> map) {
    return User(
      empId: map['empId'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      branch: map['branch'] as String,
      role: map['role'] as String,
      password: map['password'] as String,
      filePath: map['filepath'] as String?,
    );
  }
}

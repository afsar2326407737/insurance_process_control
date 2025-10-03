import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String empId;
  final String name;
  final String email;
  final String branch;
  final String role;
  final String password;
  final String? filePath; // optional

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
}

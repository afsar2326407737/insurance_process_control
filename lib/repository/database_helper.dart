import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/user_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'user.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            empId TEXT PRIMARY KEY,
            name TEXT,
            email TEXT,
            branch TEXT,
            role TEXT,
            password TEXT,
            filepath TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE login_state(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userEmail TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertUser(User user) async {
    final dbClient = await db;
    await dbClient.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<User>> getAllUsers() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> result = await dbClient.query('users');
    final users = result.map((e) => User.fromMap(e)).toList();
    for (var user in users) {
      if (kDebugMode) {
        print(user.toString());
      }
    }
    return users;
  }


  Future<User?> getUserByEmail(String email) async {
    final dbClient = await db;
    final maps = await dbClient.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<bool> doesEmpIdExist(String empId) async {
    final dbClient = await db;

    final maps = await dbClient.query(
      'users',
      where: 'empId = ?',
      whereArgs: [empId],
    );

    return maps.isNotEmpty;
  }

  Future<void> saveLoginState(String userEmail) async {
    final dbClient = await db;
    await dbClient.delete('login_state');
    await dbClient.insert('login_state', {'userEmail': userEmail});
  }

  Future<User?> getUserByEmpId(String empId) async {
    final dbClient = await db;
    final maps = await dbClient.query(
      'users',
      where: 'empId = ?',
      whereArgs: [empId],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  //change password funciton
  Future<bool> updateEmployeePassword({
    required String empId,
    required String oldPassword,
    required String newPassword,
  }) async {
    final dbClient = await db;
    // Check if user exists and old password matches
    final maps = await dbClient.query(
      'users',
      where: 'empId = ? AND password = ?',
      whereArgs: [empId, oldPassword],
    );
    log('Checking user with empId: $empId and oldPassword: $oldPassword', name: 'DatabaseHelper');
    log('Query result: $maps', name: 'DatabaseHelper');
    if (maps.isNotEmpty) {
      // Update password
      await dbClient.update(
        'users',
        {'password': newPassword},
        where: 'empId = ?',
        whereArgs: [empId],
      );
      return true;
    }
    return false;
  }



  /// to get the logged in user email
  Future<String?> getLoggedInUserEmail() async {
    final dbClient = await db;
    final result = await dbClient.query('login_state');
    if (result.isNotEmpty) {
      return result.first['userEmail'] as String;
    }
    return null;
  }

  /// logout function
  Future<void> logout() async {
    final dbClient = await db;
    await dbClient.delete('login_state');
  }

  /// function to check whether the email is present or not
  Future<bool> isEmailExists(String email) async {
    final dbClient = await db;
    final maps = await dbClient.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return maps.isNotEmpty;
  }
}



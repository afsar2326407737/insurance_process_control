import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:i_p_c/model/user_model.dart';

import '../utils/logout_container.dart';

class SettingsDrawer extends StatelessWidget {
  final User user;
  const SettingsDrawer({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                   CircleAvatar(
                    radius: 30,
                    backgroundImage: user.filePath != null
                        ? FileImage(File(user.filePath!))
                        : const NetworkImage("https://i.pravatar.cc/150?img=3"),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: user.role.toLowerCase() == 'inspector' ? Colors.green.shade500 : Colors.blue.shade500,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      user.role,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  _buildSettingsItem(
                    icon: Icons.person,
                    title: "Profile",
                    onTap: () {
                      context.push('/profile' , extra: {'user': user});
                    },
                  ),
                  _buildSettingsItem(
                    icon: Icons.lock,
                    title: "Change Password",
                    onTap: () {},
                  ),
                  _buildSettingsItem(
                    icon: Icons.help_outline,
                    title: "Help & Support",
                    onTap: () {},
                  ),
                  const Divider(),
                  _buildSettingsItem(
                    icon: Icons.logout,
                    title: "Logout",
                    onTap: () {
                      _showLogoutDialog(context);
                    },
                    iconColor: Colors.red,
                    textColor: Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return LogoutDialog();
      },
    );
  }


  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.black),
      title: Text(
        title,
        style: TextStyle(color: textColor ?? Colors.black, fontSize: 16),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

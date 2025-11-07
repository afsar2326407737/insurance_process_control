import 'dart:io';
import 'package:flutter/material.dart';
import 'package:i_p_c/model/user_model.dart';
import '../utils/image_dialog.dart';
import '../utils/logout_container.dart';

class ProfileScreen extends StatelessWidget {
  final User user;
  const ProfileScreen({required this.user, super.key});
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return LogoutDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title:  Text(
          'Profile',
          style:Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFF003B71)
                  ),
                ),
                Positioned(
                  bottom: -50,
                  left: 20,
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            ImageDialog(imageUrl: user.filePath ?? ""),
                      );
                    },
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 46,
                        backgroundImage: user.filePath != null
                            ? FileImage(File(user.filePath!))
                            : const NetworkImage(
                                    "https://i.pravatar.cc/150?img=3",
                                  )
                                  as ImageProvider,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: user.role.toLowerCase() == 'inspector'
                              ? Colors.green.shade600
                              : Colors.blue.shade600,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.role,
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.branch.bankId ?? "Null",
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(thickness: 1),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _profileItem(Icons.badge, "Employee ID", user.empId , context),
                      const Divider(
                        color: Colors.black,
                      ),
                      _profileItem(Icons.email_outlined, "Email", user.email , context),
                      const Divider(
                        color: Colors.black,
                      ),
                      _profileItem(Icons.location_city, "Branch", user.branch.bankName ?? "Null" , context),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(22.0),
              child: SizedBox(
                width: double.infinity,
                child: _actionButton(
                  icon: Icons.logout,
                  label: 'Logout',
                  color: Colors.redAccent,
                  onTap: () {
                    _showLogoutDialog(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileItem(IconData icon, String label, String value , BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF8E2DE2)),
          const SizedBox(width: 12),
          Text(
            label,
            style:Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.left,
              overflow: TextOverflow.clip,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Helper for LinkedIn-style action buttons
  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      onPressed: onTap,
    );
  }
}

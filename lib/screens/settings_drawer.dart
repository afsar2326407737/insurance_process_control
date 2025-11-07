import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:i_p_c/model/user_model.dart';
import 'package:i_p_c/repository/jokes_repository.dart';
import 'package:i_p_c/screens/joke_home_screen.dart';

import '../utils/logout_container.dart';

class SettingsDrawer extends StatefulWidget {
  final User user;
  SettingsDrawer({required this.user, super.key});

  @override
  State<SettingsDrawer> createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {
  final TextEditingController numberController = TextEditingController();
  String? selectedType;
  bool isNumberMode = true;



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
                    backgroundImage:
                        widget.user.filePath != null
                            ? FileImage(File(widget.user.filePath!))
                            : const NetworkImage(
                              "https://i.pravatar.cc/150?img=3",
                            ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 150,
                        child: FittedBox(
                          child: Text(
                            widget.user.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.clip,
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      SizedBox(
                        width: 170,
                        child: FittedBox(
                          child: Text(
                            widget.user.email,
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                            overflow: TextOverflow.clip,
                          ),
                        ),
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
                      color:
                          widget.user.role.toLowerCase() == 'inspector'
                              ? Colors.green.shade500
                              : Color(0xFF003B71),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.user.role,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                  _buildSettingsItem(
                    icon: Icons.person,
                    title: "Profile",
                    onTap: () {
                      context.push('/profile', extra: {'user': widget.user});
                    },
                  ),
                  _buildSettingsItem(
                    icon: Icons.lock,
                    title: "Change Password",
                    onTap: () {
                      context.push('/changepassword', extra: widget.user.empId);
                    },
                  ),
                  _buildSettingsItem(
                    icon: Icons.help_outline,
                    title: "Help & Support",
                    onTap: () {
                      context.push(
                        '/helpandsupport',
                        extra: {
                          'employeeId': widget.user.empId,
                          'isManager':
                              widget.user.role.toLowerCase() == 'manager',
                        },
                      );
                    },
                  ),
                  _buildSettingsItem(
                    icon: Icons.emoji_emotions_outlined,
                    title: "Joke API",
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: const Text("Choose Input Mode"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text("Type"),

                                        Switch(
                                          value: isNumberMode,
                                          onChanged: (val) {
                                            setState(() {
                                              isNumberMode = val;
                                              numberController.clear();
                                              selectedType = null;
                                            });
                                          },
                                        ),
                                        const Text("Number"),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    TextField(
                                      controller: numberController,
                                      keyboardType: TextInputType.number,
                                      enabled: isNumberMode,
                                      decoration: InputDecoration(
                                        labelText: "Enter number of jokes",
                                        border: const OutlineInputBorder(),
                                        filled: true,
                                        fillColor:
                                            isNumberMode
                                                ? Colors.white
                                                : Colors.grey.shade200,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    FutureBuilder<List<String>>(
                                      future: JokesRepository.fetchTypes(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        } else if (snapshot.hasError) {
                                          return Text(
                                            "Error: ${snapshot.error}",
                                          );
                                        } else {
                                          final types = snapshot.data ?? [];
                                          return DropdownButtonFormField<
                                            String
                                          >(
                                            decoration: const InputDecoration(
                                              labelText: "Select a type",
                                              border: OutlineInputBorder(),
                                            ),
                                            value: selectedType,
                                            items:
                                                types
                                                    .map(
                                                      (
                                                        type,
                                                      ) => DropdownMenuItem(
                                                        value: type,
                                                        child: Text(
                                                          type,
                                                          style: Theme.of(
                                                                context,
                                                              )
                                                              .textTheme
                                                              .bodyMedium!
                                                              .copyWith(
                                                                fontSize: 14,
                                                                color:
                                                                    Colors
                                                                        .black87,
                                                              ),
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
                                            onChanged:
                                                isNumberMode
                                                    ? null
                                                    : (val) {
                                                      setState(() {
                                                        selectedType = val;
                                                      });
                                                    },
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (isNumberMode &&
                                          numberController.text.isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Please enter a number",
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      if (!isNumberMode &&
                                          selectedType == null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Please select a type",
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      Navigator.pop(context);

                                      Future.microtask(() {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => JokesScreen(
                                                  type: selectedType ?? 'Any',
                                                  noOfJokes:
                                                      int.tryParse(
                                                        numberController.text,
                                                      ) ??
                                                      5,
                                                ),
                                          ),
                                        );
                                      });
                                    },
                                    child: const Text("Submit"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
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
        style: TextStyle(color: textColor ?? Colors.black, fontSize: 12),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

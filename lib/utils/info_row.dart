import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title , style: Theme.of(context).textTheme.bodyMedium,),
      subtitle: Text(value , style: Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: Colors.black
      ),),
    );
  }
}
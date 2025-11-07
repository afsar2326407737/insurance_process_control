import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color start;
  final Color end;

  const StatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.start,
    required this.end,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [start, end]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: end.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: FittedBox(
                    child: Text('$count',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  child: Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(color: Colors.white.withOpacity(0.95))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
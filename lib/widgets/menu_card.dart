
import 'package:flutter/material.dart';

class MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const MenuCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle = '',
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(
          color: Color(0xFFEAEFF5),
          width: 1,
        ),
      ),

      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ICON AND ARROW
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  // ICON CONTAINER
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      icon,
                      size: 23,
                      color: const Color(0xFF2563EB),
                    ),
                  ),

                  // NAVIGATION ARROW
                  const Icon(
                    Icons.arrow_outward_rounded,
                    size: 18,
                    color: Color(0xFF94A3B8),
                  ),
                ],
              ),

              const Spacer(),

              // MENU TITLE
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                  color: Color(0xFF1E293B),
                ),
              ),

              const SizedBox(height: 5),

              // MENU DESCRIPTION
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    height: 1.4,
                    color: Color(0xFF94A3B8),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

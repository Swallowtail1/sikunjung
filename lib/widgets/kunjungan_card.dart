
import 'package:flutter/material.dart';
import '../models/kunjungan.dart';

class KunjunganCard extends StatelessWidget {
  final Kunjungan kunjungan;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const KunjunganCard({
    super.key,
    required this.kunjungan,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color darkText = Color(0xFF1E293B);
  static const Color secondaryText = Color(0xFF64748B);

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
        borderRadius: BorderRadius.circular(18),

        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // HEADER: ICON, CUSTOMER NAME, ACTION BUTTONS
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // CUSTOMER ICON
                  Container(
                    width: 46,
                    height: 46,

                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(14),
                    ),

                    child: const Icon(
                      Icons.business_rounded,
                      color: primaryBlue,
                      size: 25,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // CUSTOMER INFORMATION
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),

                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [

                          // CUSTOMER NAME
                          Text(
                            kunjungan.namaPelanggan,

                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,

                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: darkText,
                              height: 1.3,
                            ),
                          ),

                          const SizedBox(height: 6),

                          // CUSTOMER ADDRESS
                          Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,

                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 15,
                                color: secondaryText,
                              ),

                              const SizedBox(width: 4),

                              Expanded(
                                child: Text(
                                  kunjungan.alamat,

                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,

                                  style: const TextStyle(
                                    fontSize: 11,
                                    height: 1.4,
                                    color: secondaryText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 6),

                  // ACTION BUTTONS
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      // EDIT BUTTON
                      IconButton(
                        onPressed: onEdit,
                        tooltip: 'Edit Kunjungan',

                        icon: const Icon(
                          Icons.edit_rounded,
                          size: 17,
                        ),

                        style: IconButton.styleFrom(
                          backgroundColor:
                          const Color(0xFFDBEAFE),
                          foregroundColor: primaryBlue,
                          fixedSize: const Size(38, 38),
                          padding: EdgeInsets.zero,

                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(11),
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // DELETE BUTTON
                      IconButton(
                        onPressed: onDelete,
                        tooltip: 'Hapus Kunjungan',

                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                        ),

                        style: IconButton.styleFrom(
                          backgroundColor:
                          const Color(0xFFFEE2E2),
                          foregroundColor:
                          const Color(0xFFEF4444),
                          fixedSize: const Size(38, 38),
                          padding: EdgeInsets.zero,

                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(11),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // DIVIDER
              const Divider(
                height: 1,
                color: Color(0xFFEAEFF5),
              ),

              const SizedBox(height: 12),

              // LOCATION COORDINATES AND DATE
              Wrap(
                spacing: 8,
                runSpacing: 8,

                children: [

                  // GPS COORDINATES
                  _InfoBadge(
                    icon: Icons.my_location_rounded,
                    text:
                    '${kunjungan.latitude}, ${kunjungan.longitude}',
                    color: primaryBlue,
                    backgroundColor:
                    const Color(0xFFEFF6FF),
                  ),

                  // VISIT DATE
                  _InfoBadge(
                    icon: Icons.calendar_today_rounded,
                    text: kunjungan.tanggal,
                    color: secondaryText,
                    backgroundColor:
                    const Color(0xFFF1F5F9),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// INFORMATION BADGE
class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final Color backgroundColor;

  const _InfoBadge({
    required this.icon,
    required this.text,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 240,
      ),

      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 7,
      ),

      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),

          const SizedBox(width: 5),

          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,

              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

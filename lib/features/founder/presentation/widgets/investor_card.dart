import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../investor_profile/domain/entities/investor_discovery_entity.dart';
import 'investor_detail_sheet.dart';

/// Premium, high-converting investor card used in founder horizontal rails and discovery lists.
class InvestorCard extends StatelessWidget {
  const InvestorCard({
    super.key,
    required this.investor,
    this.onTap,
  });

  final InvestorDiscoveryEntity investor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final handleTap = onTap ?? () => InvestorDetailSheet.show(context, investor);

    return Container(
      width: 270,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border.withOpacity(0.7)),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: handleTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top row: Avatar + Investor Type + Match Pill
                Row(
                  children: [
                    _Avatar(name: investor.displayName),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              investor.investorTypeLabel,
                              style: const TextStyle(
                                color: AppColors.primaryDark,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.place_outlined,
                                  size: 11, color: AppColors.textSecondary),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  investor.locationDisplay,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _MatchScoreBadge(score: investor.matchScore),
                  ],
                ),
                const SizedBox(height: 12),

                // Investor / Org Name
                Text(
                  investor.displayName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                // Subtitle if available
                if (investor.subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    investor.subtitle!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 10),

                // Ticket size highlight banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.payments_outlined,
                        size: 14,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        investor.ticketSizeDisplay,
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Preference tags (Industries / Stages)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ...investor.preferredIndustries.take(2).map((tag) => _TagChip(
                          label: tag,
                          bgColor: AppColors.secondarySoft,
                          fgColor: AppColors.secondary,
                        )),
                    if (investor.preferredStages.isNotEmpty)
                      _TagChip(
                        label: investor.preferredStages.first,
                        bgColor: AppColors.primarySoft,
                        fgColor: AppColors.primaryDark,
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                // "View Profile" button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: handleTap,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                    label: const Text(
                      'View Profile',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                      side: BorderSide(color: AppColors.border.withOpacity(0.9)),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'I';
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.secondary, AppColors.secondaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 17,
        ),
      ),
    );
  }
}

class _MatchScoreBadge extends StatelessWidget {
  const _MatchScoreBadge({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final isHigh = score >= 70;
    final bg = isHigh ? AppColors.successSoft : AppColors.primarySoft;
    final fg = isHigh ? AppColors.success : AppColors.primaryDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: fg.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt_rounded, size: 12, color: fg),
          const SizedBox(width: 2),
          Text(
            '$score%',
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    required this.bgColor,
    required this.fgColor,
  });

  final String label;
  final Color bgColor;
  final Color fgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fgColor,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
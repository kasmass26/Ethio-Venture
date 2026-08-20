import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../investor_profile/domain/entities/investor_discovery_entity.dart';
import '../../../messaging/domain/repositories/messaging_repository.dart';

/// Rich, interactive bottom sheet modal displaying an investor's full thesis and criteria.
class InvestorDetailSheet extends StatelessWidget {
  const InvestorDetailSheet({
    super.key,
    required this.investor,
  });

  final InvestorDiscoveryEntity investor;

  static Future<void> show(BuildContext context, InvestorDiscoveryEntity investor) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InvestorDetailSheet(investor: investor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.88;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sleek Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 14, bottom: 10),
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 6, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header with Avatar and Basic Info
                  _buildHeader(context, isDark),
                  const SizedBox(height: 20),

                  // Match Score Highlight Banner (if scored)
                  _buildMatchBanner(isDark),
                  const SizedBox(height: 20),

                  // Bio / Investment Thesis
                  if (investor.bio != null && investor.bio!.trim().isNotEmpty) ...[
                    _buildSectionTitle('Investment Thesis & Bio', Icons.article_outlined, isDark),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.backgroundDark.withValues(alpha: 0.5)
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(18),
                        border: Border(
                          left: BorderSide(
                            color: AppColors.primary,
                            width: 4,
                          ),
                        ),
                      ),
                      child: Text(
                        investor.bio!.trim(),
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                          fontSize: 14.5,
                          height: 1.55,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                  ],

                  // Investment Focus Details Grid
                  _buildSectionTitle('Investment Preferences', Icons.tune_rounded, isDark),
                  const SizedBox(height: 14),

                  // Ticket Size Card
                  _buildTicketSizeCard(isDark),
                  const SizedBox(height: 16),

                  // Industries
                  _buildTagGroup(
                    title: 'Preferred Industries',
                    icon: Icons.category_outlined,
                    tags: investor.preferredIndustries.isNotEmpty
                        ? investor.preferredIndustries
                        : ['Open to all industries'],
                    chipBg: AppColors.primarySoft,
                    chipFg: AppColors.primaryDark,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),

                  // Stages
                  _buildTagGroup(
                    title: 'Preferred Stages',
                    icon: Icons.timeline_rounded,
                    tags: investor.preferredStages.isNotEmpty
                        ? investor.preferredStages
                        : ['All growth stages'],
                    chipBg: AppColors.secondarySoft,
                    chipFg: AppColors.secondary,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),

                  // Geographic Focus
                  _buildTagGroup(
                    title: 'Geographic Focus',
                    icon: Icons.public_rounded,
                    tags: investor.geographicFocus.isNotEmpty
                        ? investor.geographicFocus
                        : ['Ethiopia', 'East Africa'],
                    chipBg: isDark ? AppColors.surfaceVariant : AppColors.surfaceVariant,
                    chipFg: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 28),

                  // Action Buttons
                  _buildActionButtons(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar with gradient
        Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.secondary, AppColors.secondaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.25),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            investor.displayName.isNotEmpty
                ? investor.displayName[0].toUpperCase()
                : 'I',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 26,
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Name and Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      investor.displayName,
                      style: TextStyle(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Icon(
                    Icons.verified_rounded,
                    size: 18,
                    color: Color(0xFFF59E0B),
                  ),
                ],
              ),
              if (investor.subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  investor.subtitle!,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      investor.investorTypeLabel,
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.location_on_outlined,
                      size: 14,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      investor.locationDisplay,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                        fontSize: 12,
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

        // Close button
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.close_rounded,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              size: 20,
            ),
          ),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  Widget _buildMatchBanner(bool isDark) {
    final isHighMatch = investor.matchScore >= 70;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppColors.primaryDark.withValues(alpha: 0.25),
                  AppColors.secondary.withValues(alpha: 0.25),
                ]
              : [
                  AppColors.primarySoft,
                  AppColors.secondarySoft.withValues(alpha: 0.6),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isHighMatch
              ? AppColors.success.withValues(alpha: 0.4)
              : AppColors.primary.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isHighMatch ? AppColors.success : AppColors.primaryDark,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${investor.matchScore}% AI Match',
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.secondary,
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: isHighMatch
                            ? AppColors.successSoft
                            : AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isHighMatch ? 'Strong Match' : 'Recommended',
                        style: TextStyle(
                          color: isHighMatch
                              ? AppColors.success
                              : AppColors.primaryDark,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  investor.matchReasons.isNotEmpty
                      ? investor.matchReasons.join(' • ')
                      : 'Aligned with your investment requirements & sector criteria',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 19, color: AppColors.secondary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.secondary,
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildTicketSizeCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceVariant.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.payments_outlined, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Target Check / Ticket Size',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                investor.ticketSizeDisplay,
                style: TextStyle(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTagGroup({
    required String title,
    required IconData icon,
    required List<String> tags,
    required Color chipBg,
    required Color chipFg,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.map((t) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: chipBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                t,
                style: TextStyle(
                  color: chipFg,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [AppColors.secondary, AppColors.secondaryLight],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            Navigator.of(context).pop();
            try {
              developer.log(
                'Connect & Pitch clicked for investor "${investor.displayName}" (id: ${investor.id})',
                name: 'InvestorDetailSheet.ConnectPitch',
              );
              final messagingRepo = sl<MessagingRepository>();
              final startupProfileId =
                  await messagingRepo.resolveStartupProfileId();

              if (startupProfileId == null) {
                throw Exception('Could not resolve your startup profile. Please complete startup setup.');
              }

              final conv = await messagingRepo.getOrCreateConversation(
                startupProfileId: startupProfileId,
                investorProfileId: investor.id,
              );

              if (context.mounted) {
                Navigator.of(context).pushNamed(
                  AppConstants.routeChat,
                  arguments: {
                    'conversationId': conv.id,
                    'participantName': investor.displayName,
                  },
                );
              }
            } catch (e, st) {
              developer.log(
                'ERROR in Connect & Pitch: $e',
                name: 'InvestorDetailSheet.ConnectPitch',
                error: e,
                stackTrace: st,
                level: 1000,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    content: Text(
                      'Could not connect with investor: ${e.toString().replaceAll('Exception: ', '')}',
                    ),
                  ),
                );
              }
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.send_rounded, size: 18, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'Connect & Pitch Deal',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
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

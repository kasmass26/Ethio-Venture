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

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header with Avatar and Basic Info
                  _buildHeader(context),
                  const SizedBox(height: 20),

                  // Match Score Highlight Banner (if scored)
                  _buildMatchBanner(),
                  const SizedBox(height: 20),

                  // Bio / Investment Thesis
                  if (investor.bio != null && investor.bio!.trim().isNotEmpty) ...[
                    _buildSectionTitle('Investment Thesis & Bio', Icons.article_outlined),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border.withOpacity(0.6)),
                      ),
                      child: Text(
                        investor.bio!.trim(),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Investment Focus Details Grid
                  _buildSectionTitle('Investment Preferences', Icons.tune_rounded),
                  const SizedBox(height: 12),

                  // Ticket Size Card
                  _buildTicketSizeCard(),
                  const SizedBox(height: 14),

                  // Industries
                  _buildTagGroup(
                    title: 'Preferred Industries',
                    icon: Icons.category_outlined,
                    tags: investor.preferredIndustries.isNotEmpty
                        ? investor.preferredIndustries
                        : ['Open to all industries'],
                    chipBg: AppColors.primarySoft,
                    chipFg: AppColors.primaryDark,
                  ),
                  const SizedBox(height: 14),

                  // Stages
                  _buildTagGroup(
                    title: 'Preferred Stages',
                    icon: Icons.timeline_rounded,
                    tags: investor.preferredStages.isNotEmpty
                        ? investor.preferredStages
                        : ['All growth stages'],
                    chipBg: AppColors.secondarySoft,
                    chipFg: AppColors.secondary,
                  ),
                  const SizedBox(height: 14),

                  // Geographic Focus
                  _buildTagGroup(
                    title: 'Geographic Focus',
                    icon: Icons.public_rounded,
                    tags: investor.geographicFocus.isNotEmpty
                        ? investor.geographicFocus
                        : ['Ethiopia', 'East Africa'],
                    chipBg: AppColors.surfaceVariant,
                    chipFg: AppColors.textPrimary,
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        Container(
          width: 60,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.secondary, AppColors.secondaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withOpacity(0.18),
                blurRadius: 12,
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
              fontWeight: FontWeight.w800,
              fontSize: 24,
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Name and Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                investor.displayName,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              if (investor.subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  investor.subtitle!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(6),
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
                  const Icon(Icons.place_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(
                      investor.locationDisplay,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
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
          icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  Widget _buildMatchBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primarySoft.withOpacity(0.8),
            AppColors.secondarySoft.withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.primaryDark,
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
                      '${investor.matchScore}% Match',
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.successSoft,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Recommended',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  investor.matchReasons.isNotEmpty
                      ? investor.matchReasons.join(' • ')
                      : 'Aligned with your investment requirements',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
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

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.secondary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.secondary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildTicketSizeCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
            ),
            child: const Icon(Icons.payments_outlined, color: AppColors.secondary, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Target Check / Ticket Size',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                investor.ticketSizeDisplay,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: chipBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                t,
                style: TextStyle(
                  color: chipFg,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                developer.log(
                  'Connect & Pitch clicked for investor "${investor.displayName}" (id: ${investor.id})',
                  name: 'InvestorDetailSheet.ConnectPitch',
                );
                final messagingRepo = sl<MessagingRepository>();
                final startupProfileId =
                    await messagingRepo.resolveStartupProfileId();
                developer.log(
                  'Resolved startupProfileId: "$startupProfileId"',
                  name: 'InvestorDetailSheet.ConnectPitch',
                );

                if (startupProfileId == null) {
                  throw Exception('Could not resolve your startup profile. Please complete startup setup.');
                }

                final conv = await messagingRepo.getOrCreateConversation(
                  startupProfileId: startupProfileId,
                  investorProfileId: investor.id,
                );
                developer.log(
                  'Conversation ready: ID "${conv.id}"',
                  name: 'InvestorDetailSheet.ConnectPitch',
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
            icon: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
            label: const Text(
              'Connect & Pitch',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }
}

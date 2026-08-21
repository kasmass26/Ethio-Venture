import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../connection_requests/domain/entities/connection_request_entity.dart';
import '../../../connection_requests/domain/repositories/connection_request_repository.dart';
import '../../../investor_profile/domain/entities/investor_discovery_entity.dart';
import '../../../messaging/domain/repositories/messaging_repository.dart';

/// Rich, interactive bottom sheet modal displaying an investor's full thesis and criteria.
/// The CTA button is gated by connection request status.
class InvestorDetailSheet extends StatefulWidget {
  const InvestorDetailSheet({
    super.key,
    required this.investor,
  });

  final InvestorDiscoveryEntity investor;

  static Future<void> show(
      BuildContext context, InvestorDiscoveryEntity investor) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InvestorDetailSheet(investor: investor),
    );
  }

  @override
  State<InvestorDetailSheet> createState() => _InvestorDetailSheetState();
}

class _InvestorDetailSheetState extends State<InvestorDetailSheet> {
  ConnectionRequestEntity? _request;
  bool _loadingStatus = true;
  bool _sending = false;

  InvestorDiscoveryEntity get investor => widget.investor;

  @override
  void initState() {
    super.initState();
    _loadRequestStatus();
  }

  Future<void> _loadRequestStatus() async {
    try {
      final repo = sl<ConnectionRequestRepository>();
      final req =
          await repo.getRequestBetween(otherUserId: investor.userId);
      if (mounted) setState(() => _request = req);
    } catch (_) {
      // Silently fallback — treat as no request yet
    } finally {
      if (mounted) setState(() => _loadingStatus = false);
    }
  }

  // ── Send a new connection request ─────────────────────────────────────────

  Future<void> _sendRequest({String? message}) async {
    setState(() => _sending = true);
    try {
      final repo = sl<ConnectionRequestRepository>();
      final req = await repo.sendRequest(
        investorUserId: investor.userId,
        investorProfileId: investor.id,
        message: message,
      );
      if (mounted) {
        setState(() {
          _request = req;
          _sending = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('✅ Request sent to ${investor.displayName}!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _sending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to send request: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  // ── Show the optional intro-message dialog then send ──────────────────────

  Future<void> _showSendRequestDialog() async {
    final messageController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.connect_without_contact_rounded,
                  color: AppColors.primaryDark, size: 20),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Send Connection Request',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Request to connect with ${investor.displayName}. They will be notified and can accept or decline.',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13.5),
            ),
            const SizedBox(height: 14),
            const Text(
              'Add an intro message (optional)',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: messageController,
              maxLines: 3,
              maxLength: 300,
              decoration: InputDecoration(
                hintText:
                    'Briefly introduce your startup and why you want to connect…',
                hintStyle: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(ctx).pop(true),
            icon: const Icon(Icons.send_rounded, size: 15),
            label: const Text('Send Request'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _sendRequest(
        message: messageController.text.trim().isEmpty
            ? null
            : messageController.text.trim(),
      );
    }
  }

  // ── Open chat (only when accepted) ───────────────────────────────────────

  Future<void> _openChat() async {
    Navigator.of(context).pop();
    try {
      final messagingRepo = sl<MessagingRepository>();
      final startupProfileId =
          await messagingRepo.resolveStartupProfileId();
      if (startupProfileId == null) {
        throw Exception(
            'Could not find your startup profile. Please complete setup first.');
      }
      final conv = await messagingRepo.getOrCreateConversation(
        startupProfileId: startupProfileId,
        investorProfileId: investor.id,
      );
      if (mounted) {
        Navigator.of(context).pushNamed(
          AppConstants.routeChat,
          arguments: {
            'conversationId': conv.id,
            'participantName': investor.displayName,
          },
        );
      }
    } catch (e, st) {
      developer.log('ERROR opening chat: $e',
          name: 'InvestorDetailSheet.openChat', error: e, stackTrace: st);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            content: Text(
                'Could not open chat: ${e.toString().replaceAll('Exception: ', '')}'),
          ),
        );
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

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
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(32)),
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
          // Drag handle
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
                  _buildHeader(context, isDark),
                  const SizedBox(height: 20),
                  _buildMatchBanner(isDark),
                  const SizedBox(height: 20),

                  if (investor.bio != null &&
                      investor.bio!.trim().isNotEmpty) ...[
                    _buildSectionTitle(
                        'Investment Thesis & Bio',
                        Icons.article_outlined,
                        isDark),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.backgroundDark
                                .withValues(alpha: 0.5)
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(18),
                        border: const Border(
                          left: BorderSide(
                              color: AppColors.primary, width: 4),
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

                  _buildSectionTitle('Investment Preferences',
                      Icons.tune_rounded, isDark),
                  const SizedBox(height: 14),
                  _buildTicketSizeCard(isDark),
                  const SizedBox(height: 16),
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
                  _buildTagGroup(
                    title: 'Geographic Focus',
                    icon: Icons.public_rounded,
                    tags: investor.geographicFocus.isNotEmpty
                        ? investor.geographicFocus
                        : ['Ethiopia', 'East Africa'],
                    chipBg: isDark
                        ? AppColors.surfaceVariant
                        : AppColors.surfaceVariant,
                    chipFg: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 28),

                  // ── Dynamic CTA ──────────────────────────────────────────
                  _buildActionButton(isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Dynamic CTA based on request status ──────────────────────────────────

  Widget _buildActionButton(bool isDark) {
    if (_loadingStatus) {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.surfaceVariant,
        ),
        child: const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
                strokeWidth: 2.5, color: AppColors.primary),
          ),
        ),
      );
    }

    final req = _request;

    // ── Accepted → Open Chat ────────────────────────────────────────────────
    if (req != null && req.isAccepted) {
      return _GradientButton(
        onTap: _openChat,
        icon: Icons.chat_bubble_outline_rounded,
        label: 'Open Chat',
        gradientColors: [AppColors.success, const Color(0xFF0DAF72)],
        shadowColor: AppColors.success,
      );
    }

    // ── Pending → status banner ─────────────────────────────────────────────
    if (req != null && req.isPending) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.warningSoft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
        ),
        child: const Row(
          children: [
            Icon(Icons.hourglass_top_rounded,
                color: AppColors.warning, size: 22),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Request Pending',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Awaiting investor response. You\'ll be notified when they accept.',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontSize: 12.5,
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

    // ── Declined → info banner ──────────────────────────────────────────────
    if (req != null && req.isDeclined) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEEEE),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel_outlined, color: AppColors.error, size: 22),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'This investor has declined your connection request.',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ── No request → Send Request button ───────────────────────────────────
    if (_sending) {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [AppColors.secondary, AppColors.secondaryLight],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
                strokeWidth: 2.5, color: Colors.white),
          ),
        ),
      );
    }

    return _GradientButton(
      onTap: _showSendRequestDialog,
      icon: Icons.connect_without_contact_rounded,
      label: 'Request to Connect',
      gradientColors: [AppColors.secondary, AppColors.secondaryLight],
      shadowColor: AppColors.secondary,
    );
  }

  // ── Reusable helpers (unchanged from original) ────────────────────────────

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Icon(Icons.verified_rounded,
                      size: 18, color: Color(0xFFF59E0B)),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 3.5),
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
            child: Icon(Icons.close_rounded,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
                size: 20),
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
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 20),
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
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.secondary,
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2.5),
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
        color: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceVariant.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDark ? AppColors.borderDark : AppColors.border.withValues(alpha: 0.6),
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
            child: const Icon(Icons.payments_outlined,
                color: Colors.white, size: 22),
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
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
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
            Icon(icon,
                size: 15,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
}

// ── Reusable gradient CTA button ─────────────────────────────────────────────

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.onTap,
    required this.icon,
    required this.label,
    required this.gradientColors,
    required this.shadowColor,
  });

  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final List<Color> gradientColors;
  final Color shadowColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
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

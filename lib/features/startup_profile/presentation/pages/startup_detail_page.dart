import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../messaging/domain/repositories/messaging_repository.dart';
import '../../../pitch_deck/presentation/cubit/document_cubit.dart';
import '../../../pitch_deck/presentation/widgets/pitch_deck_section_widget.dart';
import '../../domain/entities/startup_profile_entity.dart';
import '../../domain/usecases/get_startup_by_id.dart';
import '../../../tracked_startups/domain/usecases/is_startup_tracked.dart';
import '../../../tracked_startups/domain/usecases/track_startup.dart';
import '../../../tracked_startups/domain/usecases/untrack_startup.dart';

/// Detailed view of a startup profile for investors and public discovery.
class StartupDetailPage extends StatefulWidget {
  const StartupDetailPage({
    super.key,
    required this.startup,
    this.matchScore,
  }) : startupId = null;

  const StartupDetailPage.fromId({
    super.key,
    required this.startupId,
    this.matchScore,
  }) : startup = null;

  final StartupProfileEntity? startup;
  final String? startupId;
  final int? matchScore;

  @override
  State<StartupDetailPage> createState() => _StartupDetailPageState();
}

class _StartupDetailPageState extends State<StartupDetailPage> {
  StartupProfileEntity? _startup;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isTracked = false;

  @override
  void initState() {
    super.initState();
    if (widget.startup != null) {
      _startup = widget.startup;
      _checkIfTracked(widget.startup!.id);
    } else if (widget.startupId != null) {
      _loadStartup();
    }
  }

  Future<void> _checkIfTracked(String startupId) async {
    if (startupId.isEmpty) return;
    try {
      final isTracked = await sl<IsStartupTracked>()(startupId);
      if (mounted) {
        setState(() {
          _isTracked = isTracked;
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleTracking(StartupProfileEntity startup) async {
    final targetId = startup.id.isNotEmpty ? startup.id : startup.userId;
    if (targetId.isEmpty) return;

    final previousState = _isTracked;
    final newState = !previousState;

    setState(() {
      _isTracked = newState;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.secondary,
        content: Text(
          newState
              ? '${startup.startupName} added to your tracked startups.'
              : '${startup.startupName} removed from tracking.',
        ),
      ),
    );

    try {
      if (newState) {
        await sl<TrackStartup>()(targetId);
      } else {
        await sl<UntrackStartup>()(targetId);
      }
    } catch (e) {
      developer.log('Error toggling track startup: $e', name: 'StartupDetailPage');
      if (mounted) {
        setState(() {
          _isTracked = previousState;
        });
      }
    }
  }

  Future<void> _loadStartup() async {
    final startupId = widget.startupId;
    if (startupId == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final getStartupById = sl<GetStartupById>();
      final result = await getStartupById(startupId);
      if (mounted) {
        if (result != null) {
          setState(() {
            _startup = result;
            _isLoading = false;
          });
          _checkIfTracked(result.id);
        } else {
          setState(() {
            _errorMessage = 'Startup profile not found.';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load startup details: $e';
          _isLoading = false;
        });
      }
    }
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      final m = amount / 1000000;
      return '\$${m == m.truncateToDouble() ? m.toStringAsFixed(0) : m.toStringAsFixed(1)}M USD';
    }
    if (amount >= 1000) {
      final k = amount / 1000;
      return '\$${k == k.truncateToDouble() ? k.toStringAsFixed(0) : k.toStringAsFixed(1)}K USD';
    }
    return '\$${amount.toStringAsFixed(0)} USD';
  }

  Future<void> _launchWebsite(BuildContext context, String urlString) async {
    if (urlString.trim().isEmpty) return;
    var targetUrl = urlString.trim();
    if (!targetUrl.startsWith('http://') && !targetUrl.startsWith('https://')) {
      targetUrl = 'https://$targetUrl';
    }
    final uri = Uri.tryParse(targetUrl);
    if (uri != null) {
      try {
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!launched && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open link: $urlString')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error launching link: $e')),
          );
        }
      }
    }
  }

  void _showInterestDialog(BuildContext context, StartupProfileEntity startup) {
    final messageController = TextEditingController(
      text: 'Hi ${startup.startupName}, I reviewed your profile on EthioVenture and would like to connect.',
    );
    bool isSubmitting = false;

    showDialog<void>(
      context: context,
      barrierDismissible: !isSubmitting,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.handshake_outlined, color: AppColors.primaryDark),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Express Interest',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Start a direct chat with the founder of ${startup.startupName}. You can customize your opening message below:',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                enabled: !isSubmitting,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add an introductory note or investment thesis…',
                  hintStyle: const TextStyle(fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      developer.log(
                        'Express Interest clicked for startup "${startup.startupName}" (id: ${startup.id})',
                        name: 'StartupDetailPage.ExpressInterest',
                      );
                      setDialogState(() {
                        isSubmitting = true;
                      });

                      try {
                        final messagingRepo = sl<MessagingRepository>();
                        developer.log(
                          'Step 1: Resolving investorProfileId...',
                          name: 'StartupDetailPage.ExpressInterest',
                        );
                        final investorProfileId =
                            await messagingRepo.resolveInvestorProfileId();

                        developer.log(
                          'Resolved investorProfileId: "$investorProfileId"',
                          name: 'StartupDetailPage.ExpressInterest',
                        );

                        if (investorProfileId == null) {
                          throw Exception('Unable to resolve or create your investor account profile.');
                        }

                        developer.log(
                          'Step 2: Getting or creating conversation (startupProfileId: "${startup.id}", investorProfileId: "$investorProfileId")...',
                          name: 'StartupDetailPage.ExpressInterest',
                        );
                        final conv = await messagingRepo.getOrCreateConversation(
                          startupProfileId: startup.id,
                          investorProfileId: investorProfileId,
                        );

                        developer.log(
                          'Conversation ready: ID "${conv.id}"',
                          name: 'StartupDetailPage.ExpressInterest',
                        );

                        final textToSend = messageController.text.trim();
                        if (textToSend.isNotEmpty) {
                          developer.log(
                            'Step 3: Sending opening message: "$textToSend"...',
                            name: 'StartupDetailPage.ExpressInterest',
                          );
                          await messagingRepo.sendMessage(
                            conversationId: conv.id,
                            content: textToSend,
                          );
                          developer.log(
                            'Opening message sent successfully.',
                            name: 'StartupDetailPage.ExpressInterest',
                          );
                        }

                        if (dialogCtx.mounted) {
                          Navigator.pop(dialogCtx);
                        }

                        if (context.mounted) {
                          developer.log(
                            'Step 4: Navigating to ChatPage (conversationId: "${conv.id}", participantName: "${startup.startupName}")...',
                            name: 'StartupDetailPage.ExpressInterest',
                          );
                          Navigator.of(context).pushNamed(
                            AppConstants.routeChat,
                            arguments: {
                              'conversationId': conv.id,
                              'participantName': startup.startupName,
                            },
                          );
                        }
                      } catch (e, st) {
                        developer.log(
                          'ERROR in Express Interest flow: $e',
                          name: 'StartupDetailPage.ExpressInterest',
                          error: e,
                          stackTrace: st,
                          level: 1000,
                        );
                        setDialogState(() {
                          isSubmitting = false;
                        });
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.error,
                              content: Text(
                                'Could not start chat: ${e.toString().replaceAll('Exception: ', '')}',
                              ),
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Send & Start Chat',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          title: const Text('Startup Details'),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
      );
    }

    if (_errorMessage != null || _startup == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          title: const Text('Startup Details'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                const SizedBox(height: 16),
                Text(
                  _errorMessage ?? 'Startup details could not be loaded.',
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _loadStartup,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final startup = _startup!;
    final hasWebsite = startup.websiteUrl.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          startup.startupName,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isTracked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
              color: _isTracked ? AppColors.primary : AppColors.textPrimary,
            ),
            tooltip: _isTracked ? 'Stop Tracking' : 'Track Startup',
            onPressed: () => _toggleTracking(startup),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header / Hero Card ──────────────────────────────────────
              _HeroCard(
                startup: startup,
                matchScore: widget.matchScore,
                isDark: isDark,
              ),
              const SizedBox(height: 16),

              // ── Key Metrics Grid ─────────────────────────────────────────
              _KeyMetricsGrid(
                startup: startup,
                formattedFunding: _formatCurrency(startup.fundingAmountNeeded),
                isDark: isDark,
              ),
              const SizedBox(height: 16),

              // ── Website / Mobile App Card ──────────────────────────────────
              if (hasWebsite) ...[
                _WebsiteSectionCard(
                  websiteUrl: startup.websiteUrl,
                  onLaunch: () => _launchWebsite(context, startup.websiteUrl),
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
              ],

              // ── Overview & Vision ─────────────────────────────────────────
              _ContentSectionCard(
                title: 'Overview & Vision',
                icon: Icons.lightbulb_outline_rounded,
                content: startup.description.isNotEmpty
                    ? startup.description
                    : 'No description provided.',
                isDark: isDark,
              ),
              const SizedBox(height: 16),

              // ── Team & Founders ──────────────────────────────────────────
              _ContentSectionCard(
                title: 'Team & Founders',
                icon: Icons.groups_2_outlined,
                content: startup.teamInformation.isNotEmpty
                    ? startup.teamInformation
                    : 'No team details provided.',
                isDark: isDark,
              ),
              const SizedBox(height: 16),

              // ── Pitch Decks & Documents Section ──────────────────────────
              BlocProvider<DocumentCubit>(
                create: (context) =>
                    sl<DocumentCubit>()..loadDocuments(startupId: startup.id),
                child: PitchDeckSectionWidget(
                  startupId: startup.id,
                  isFounder: false,
                ),
              ),
              const SizedBox(height: 16),

              // ── Contact Details ───────────────────────────────────────────
              _ContactSectionCard(
                contactInfo: startup.contactInformation,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
      // ── Bottom Sticky Action Bar ─────────────────────────────────────────
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _toggleTracking(startup),
                icon: Icon(
                  _isTracked ? Icons.check_circle_outline : Icons.bookmark_add_outlined,
                  size: 18,
                  color: _isTracked ? AppColors.success : AppColors.primaryDark,
                ),
                label: Text(
                  _isTracked ? 'Tracked' : 'Track Deal',
                  style: TextStyle(
                    color: _isTracked ? AppColors.success : AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: _isTracked ? AppColors.success : AppColors.primaryDark,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () => _showInterestDialog(context, startup),
                icon: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                label: const Text(
                  'Express Interest',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Subcomponents
// ─────────────────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.startup,
    this.matchScore,
    required this.isDark,
  });

  final StartupProfileEntity startup;
  final int? matchScore;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.secondary, AppColors.secondaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  startup.startupName.isNotEmpty
                      ? startup.startupName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      startup.startupName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            startup.location.isNotEmpty
                                ? startup.location
                                : 'Ethiopia',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (matchScore != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryDark.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars_rounded, size: 16, color: AppColors.primaryDark),
                      const SizedBox(width: 4),
                      Text(
                        '$matchScore% Match',
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TagChip(
                label: startup.industry,
                icon: Icons.domain_rounded,
                bgColor: AppColors.secondarySoft,
                textColor: AppColors.secondary,
              ),
              _TagChip(
                label: startup.fundingStage,
                icon: Icons.trending_up_rounded,
                bgColor: AppColors.primarySoft,
                textColor: AppColors.primaryDark,
              ),
              const _TagChip(
                label: 'Verified Profile',
                icon: Icons.verified_rounded,
                bgColor: AppColors.successSoft,
                textColor: AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.textColor,
  });

  final String label;
  final IconData icon;
  final Color bgColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyMetricsGrid extends StatelessWidget {
  const _KeyMetricsGrid({
    required this.startup,
    required this.formattedFunding,
    required this.isDark,
  });

  final StartupProfileEntity startup;
  final String formattedFunding;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricItem(
            label: 'Funding Sought',
            value: formattedFunding,
            icon: Icons.monetization_on_outlined,
            accentColor: AppColors.primaryDark,
            bgColor: AppColors.primarySoft,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricItem(
            label: 'Current Stage',
            value: startup.fundingStage,
            icon: Icons.rocket_launch_outlined,
            accentColor: AppColors.secondary,
            bgColor: AppColors.secondarySoft,
          ),
        ),
      ],
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    required this.bgColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: accentColor),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _WebsiteSectionCard extends StatelessWidget {
  const _WebsiteSectionCard({
    required this.websiteUrl,
    required this.onLaunch,
    required this.isDark,
  });

  final String websiteUrl;
  final VoidCallback onLaunch;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.language_rounded, size: 18, color: AppColors.primaryDark),
              SizedBox(width: 8),
              Text(
                'Website & App Platform',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.link_rounded,
                  size: 18,
                  color: AppColors.primaryDark,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SelectableText(
                    websiteUrl,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 18, color: AppColors.textSecondary),
                  tooltip: 'Copy Website Link',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: websiteUrl));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Website URL copied to clipboard!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onLaunch,
            icon: const Icon(Icons.open_in_new_rounded, size: 16),
            label: const Text('Visit Product / Website'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              minimumSize: const Size.fromHeight(42),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentSectionCard extends StatelessWidget {
  const _ContentSectionCard({
    required this.title,
    required this.icon,
    required this.content,
    required this.isDark,
  });

  final String title;
  final IconData icon;
  final String content;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primaryDark),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactSectionCard extends StatelessWidget {
  const _ContactSectionCard({
    required this.contactInfo,
    required this.isDark,
  });

  final String contactInfo;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final hasContact = contactInfo.trim().isNotEmpty;
    final isEmail = contactInfo.contains('@');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.contact_mail_outlined, size: 18, color: AppColors.primaryDark),
              SizedBox(width: 8),
              Text(
                'Founder Contact',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          if (hasContact)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    isEmail ? Icons.email_outlined : Icons.phone_outlined,
                    size: 18,
                    color: AppColors.primaryDark,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SelectableText(
                      contactInfo,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 18, color: AppColors.textSecondary),
                    tooltip: 'Copy Contact',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: contactInfo));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Contact copied to clipboard!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
          else
            const Text(
              'No direct contact details provided.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
        ],
      ),
    );
  }
}

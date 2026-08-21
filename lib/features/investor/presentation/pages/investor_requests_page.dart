import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../connection_requests/domain/entities/connection_request_entity.dart';
import '../../../connection_requests/presentation/cubit/connection_request_cubit.dart';
import '../../../connection_requests/presentation/cubit/connection_request_state.dart';
import '../../../messaging/domain/repositories/messaging_repository.dart';
import '../widgets/app_bottom_nav.dart';

/// Investor-side page to manage all incoming connection requests.
/// Shows three tabs: Pending, Accepted, Declined.
class InvestorRequestsPage extends StatelessWidget {
  const InvestorRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConnectionRequestCubit>(
      create: (_) => sl<ConnectionRequestCubit>()..loadInvestorRequests(),
      child: const _InvestorRequestsView(),
    );
  }
}

class _InvestorRequestsView extends StatefulWidget {
  const _InvestorRequestsView();

  @override
  State<_InvestorRequestsView> createState() => _InvestorRequestsViewState();
}

class _InvestorRequestsViewState extends State<_InvestorRequestsView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          'Connection Requests',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryDark,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primaryDark,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Accepted'),
            Tab(text: 'Declined'),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        items: AppBottomNav.investorNavItems,
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacementNamed(
              AppConstants.routeInvestorDashboard,
            );
          } else if (index == 1) {
            Navigator.of(context).pushReplacementNamed(
              AppConstants.routeStartupSearch,
            );
          } else if (index == 2) {
            Navigator.of(context).pushNamed(AppConstants.routeMessages);
          } else if (index == 3) {
            Navigator.of(context).pushReplacementNamed(
              AppConstants.routeInvestorProfile,
            );
          }
        },
      ),
      body: BlocConsumer<ConnectionRequestCubit, ConnectionRequestState>(
        listener: (context, state) {
          if (state is ConnectionRequestError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
          if (state is ConnectionRequestResponded) {
            final isAccepted =
                state.request.status == ConnectionRequestStatus.accepted;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isAccepted
                    ? 'Request accepted! Conversation created.'
                    : 'Request declined.'),
                backgroundColor:
                    isAccepted ? AppColors.success : AppColors.textSecondary,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ConnectionRequestLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is ConnectionRequestLoaded) {
            final pending = state.requests
                .where((r) => r.isPending)
                .toList();
            final accepted = state.requests
                .where((r) => r.isAccepted)
                .toList();
            final declined = state.requests
                .where((r) => r.isDeclined)
                .toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _RequestsList(
                  requests: pending,
                  emptyIcon: Icons.hourglass_empty_rounded,
                  emptyLabel: 'No pending requests',
                  emptySubtitle: 'New connection requests from founders will appear here.',
                  showActions: true,
                ),
                _RequestsList(
                  requests: accepted,
                  emptyIcon: Icons.check_circle_outline_rounded,
                  emptyLabel: 'No accepted requests',
                  emptySubtitle: 'Founders you have accepted will appear here.',
                  showActions: false,
                ),
                _RequestsList(
                  requests: declined,
                  emptyIcon: Icons.cancel_outlined,
                  emptyLabel: 'No declined requests',
                  emptySubtitle: 'Requests you have declined will appear here.',
                  showActions: false,
                ),
              ],
            );
          }

          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        },
      ),
    );
  }
}

// ── Requests List ─────────────────────────────────────────────────────────────

class _RequestsList extends StatelessWidget {
  const _RequestsList({
    required this.requests,
    required this.emptyIcon,
    required this.emptyLabel,
    required this.emptySubtitle,
    required this.showActions,
  });

  final List<ConnectionRequestEntity> requests;
  final IconData emptyIcon;
  final String emptyLabel;
  final String emptySubtitle;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(emptyIcon,
                    size: 36, color: AppColors.primaryDark),
              ),
              const SizedBox(height: 16),
              Text(
                emptyLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                emptySubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async =>
          context.read<ConnectionRequestCubit>().loadInvestorRequests(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final request = requests[index];
          return _RequestCard(
            request: request,
            showActions: showActions,
          );
        },
      ),
    );
  }
}

// ── Request Card ──────────────────────────────────────────────────────────────

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request, required this.showActions});

  final ConnectionRequestEntity request;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    final founderInitial = (request.founderName?.isNotEmpty == true
            ? request.founderName![0]
            : request.startupName?.isNotEmpty == true
                ? request.startupName![0]
                : 'F')
        .toUpperCase();

    final displayName = request.startupName?.isNotEmpty == true
        ? request.startupName!
        : request.founderName ?? 'Founder';

    final date = DateFormat('MMM d, yyyy').format(request.createdAt.toLocal());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withOpacity(0.7)),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  founderInitial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      date,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(status: request.status),
            ],
          ),

          // Intro message
          if (request.message != null && request.message!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.format_quote_rounded,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      request.message!,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Action buttons (only for pending)
          if (showActions) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _decline(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Decline',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _accept(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Accept',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Open Chat (accepted)
          if (request.isAccepted) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openChat(context),
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                label: const Text('Open Chat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _accept(BuildContext context) {
    context.read<ConnectionRequestCubit>().respondToRequest(
          requestId: request.id,
          status: ConnectionRequestStatus.accepted,
        );
    // Create conversation on accept
    _createConversation(context);
  }

  void _decline(BuildContext context) {
    context.read<ConnectionRequestCubit>().respondToRequest(
          requestId: request.id,
          status: ConnectionRequestStatus.declined,
        );
  }

  Future<void> _createConversation(BuildContext context) async {
    try {
      if (request.startupProfileId != null &&
          request.investorProfileId != null) {
        final messagingRepo = sl<MessagingRepository>();
        await messagingRepo.getOrCreateConversation(
          startupProfileId: request.startupProfileId!,
          investorProfileId: request.investorProfileId!,
        );
      }
    } catch (_) {
      // Silently fail — the conversation can be created when they first message
    }
  }

  Future<void> _openChat(BuildContext context) async {
    try {
      if (request.startupProfileId != null &&
          request.investorProfileId != null) {
        final messagingRepo = sl<MessagingRepository>();
        final conv = await messagingRepo.getOrCreateConversation(
          startupProfileId: request.startupProfileId!,
          investorProfileId: request.investorProfileId!,
        );
        if (context.mounted) {
          Navigator.of(context).pushNamed(
            AppConstants.routeChat,
            arguments: {
              'conversationId': conv.id,
              'participantName': request.startupName ?? 'Founder',
            },
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open chat: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

// ── Status Chip ───────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final ConnectionRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      ConnectionRequestStatus.pending => (
          'Pending',
          AppColors.warningSoft,
          AppColors.warning
        ),
      ConnectionRequestStatus.accepted => (
          'Accepted',
          AppColors.successSoft,
          AppColors.success
        ),
      ConnectionRequestStatus.declined => (
          'Declined',
          const Color(0xFFFFEEEE),
          AppColors.error
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

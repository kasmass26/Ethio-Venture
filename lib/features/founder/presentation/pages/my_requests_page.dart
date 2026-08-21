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
import '../widgets/dashboard_bottom_nav.dart';

/// Founder-side page showing all outgoing connection requests and their statuses.
class MyRequestsPage extends StatelessWidget {
  const MyRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConnectionRequestCubit>(
      create: (_) => sl<ConnectionRequestCubit>()..loadFounderRequests(),
      child: const _MyRequestsView(),
    );
  }
}

class _MyRequestsView extends StatefulWidget {
  const _MyRequestsView();

  @override
  State<_MyRequestsView> createState() => _MyRequestsViewState();
}

class _MyRequestsViewState extends State<_MyRequestsView>
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
          'My Requests',
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
      bottomNavigationBar: DashboardBottomNav(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context)
                .pushReplacementNamed(AppConstants.routeFounderDashboard);
          } else if (index == 1) {
            Navigator.of(context)
                .pushReplacementNamed(AppConstants.routeFounderInvestors);
          } else if (index == 2) {
            Navigator.of(context).pushNamed(AppConstants.routeMessages);
          } else if (index == 3) {
            Navigator.of(context)
                .pushReplacementNamed(AppConstants.routeStartupProfile);
          }
        },
      ),
      body: BlocBuilder<ConnectionRequestCubit, ConnectionRequestState>(
        builder: (context, state) {
          if (state is ConnectionRequestLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is ConnectionRequestLoaded) {
            final pending =
                state.requests.where((r) => r.isPending).toList();
            final accepted =
                state.requests.where((r) => r.isAccepted).toList();
            final declined =
                state.requests.where((r) => r.isDeclined).toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _FounderRequestsList(
                  requests: pending,
                  emptyIcon: Icons.hourglass_empty_rounded,
                  emptyLabel: 'No pending requests',
                  emptySubtitle:
                      'Requests you\'ve sent that haven\'t been responded to yet.',
                ),
                _FounderRequestsList(
                  requests: accepted,
                  emptyIcon: Icons.check_circle_outline_rounded,
                  emptyLabel: 'No accepted requests',
                  emptySubtitle:
                      'Investors who\'ve accepted your connection requests will appear here.',
                ),
                _FounderRequestsList(
                  requests: declined,
                  emptyIcon: Icons.cancel_outlined,
                  emptyLabel: 'No declined requests',
                  emptySubtitle:
                      'Declined requests will appear here.',
                ),
              ],
            );
          }

          if (state is ConnectionRequestError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: AppColors.warning),
                  const SizedBox(height: 12),
                  Text(
                    state.message,
                    style: const TextStyle(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context
                        .read<ConnectionRequestCubit>()
                        .loadFounderRequests(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
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

// ── List ──────────────────────────────────────────────────────────────────────

class _FounderRequestsList extends StatelessWidget {
  const _FounderRequestsList({
    required this.requests,
    required this.emptyIcon,
    required this.emptyLabel,
    required this.emptySubtitle,
  });

  final List<ConnectionRequestEntity> requests;
  final IconData emptyIcon;
  final String emptyLabel;
  final String emptySubtitle;

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
          context.read<ConnectionRequestCubit>().loadFounderRequests(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final request = requests[index];
          return _FounderRequestCard(request: request);
        },
      ),
    );
  }
}

// ── Card ──────────────────────────────────────────────────────────────────────

class _FounderRequestCard extends StatelessWidget {
  const _FounderRequestCard({required this.request});
  final ConnectionRequestEntity request;

  @override
  Widget build(BuildContext context) {
    final investorName = request.investorName ?? 'Investor';
    final initial = investorName[0].toUpperCase();
    final date =
        DateFormat('MMM d, yyyy').format(request.createdAt.toLocal());

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
              // Investor avatar
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.secondary, AppColors.secondaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  initial,
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
                      investorName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.schedule_rounded,
                            size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          'Sent on $date',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _StatusChip(status: request.status),
            ],
          ),

          // Intro message preview
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

          // Status-specific info / action
          if (request.isPending) ...[
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.warningSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.hourglass_top_rounded,
                      size: 14, color: AppColors.warning),
                  SizedBox(width: 6),
                  Text(
                    'Awaiting investor response…',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (request.isAccepted) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openChat(context),
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                label: const Text('Send a Message'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
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

          if (request.isDeclined) ...[
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEEEE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 14, color: AppColors.error),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'This investor declined your request.',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
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
              'participantName': request.investorName ?? 'Investor',
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
          '⏳ Pending',
          AppColors.warningSoft,
          AppColors.warning
        ),
      ConnectionRequestStatus.accepted => (
          '✅ Accepted',
          AppColors.successSoft,
          AppColors.success
        ),
      ConnectionRequestStatus.declined => (
          '❌ Declined',
          const Color(0xFFFFEEEE),
          AppColors.error
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../domain/entities/pending_approval_entity.dart';
import 'rejection_reason_dialog.dart';

class PendingProfileCard extends StatefulWidget {
  final PendingApprovalEntity profile;
  final VoidCallback? onApprove;
  final Function(String reason)? onRejectWithReason;

  const PendingProfileCard({
    super.key,
    required this.profile,
    this.onApprove,
    this.onRejectWithReason,
  });

  @override
  State<PendingProfileCard> createState() => _PendingProfileCardState();
}

class _PendingProfileCardState extends State<PendingProfileCard> {
  bool _isExpanded = false;

  Future<void> _handleReject() async {
    final reason = await RejectionReasonDialog.show(
      context,
      profile: widget.profile,
    );
    if (reason != null && reason.trim().isNotEmpty) {
      widget.onRejectWithReason?.call(reason.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final isStartup = widget.profile.role == 'founder';
    final status = widget.profile.approvalStatus.toLowerCase();
    final isPending = status == 'pending';
    final isApproved = status == 'approved';
    final isRejected = status == 'rejected';

    Color statusColor = AppColors.warning;
    String statusLabel = 'Pending Review';
    IconData statusIcon = Icons.hourglass_top_rounded;

    if (isApproved) {
      statusColor = AppColors.success;
      statusLabel = 'Approved';
      statusIcon = Icons.check_circle_rounded;
    } else if (isRejected) {
      statusColor = AppColors.error;
      statusLabel = 'Rejected';
      statusIcon = Icons.cancel_rounded;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: BorderSide(
          color: _isExpanded ? AppColors.primary : AppColors.hairline,
          width: _isExpanded ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo/Icon
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: isStartup
                              ? AppColors.primarySoft
                              : AppColors.violetTint,
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        ),
                        child: widget.profile.logoUrl != null
                            ? ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusMd),
                                child: Image.network(
                                  widget.profile.logoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    isStartup
                                        ? Icons.business
                                        : Icons.account_balance,
                                    color: isStartup
                                        ? AppColors.primary
                                        : AppColors.violet,
                                    size: 28,
                                  ),
                                ),
                              )
                            : Icon(
                                isStartup
                                    ? Icons.business
                                    : Icons.account_balance,
                                color: isStartup
                                    ? AppColors.primary
                                    : AppColors.violet,
                                size: 28,
                              ),
                      ),
                      const SizedBox(width: AppSizes.md),
                      // Business Name & Badges
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.profile.businessName,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSizes.xs),
                            Wrap(
                              spacing: AppSizes.xs + 2,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                // Role Tag
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSizes.sm,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isStartup
                                        ? AppColors.primarySoft
                                        : AppColors.violetTint,
                                    borderRadius: BorderRadius.circular(
                                        AppSizes.radiusSm),
                                  ),
                                  child: Text(
                                    isStartup ? 'Startup' : 'Investor',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isStartup
                                          ? AppColors.primary
                                          : AppColors.violet,
                                    ),
                                  ),
                                ),
                                // Status Tag
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSizes.sm,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(
                                        AppSizes.radiusSm),
                                    border: Border.all(
                                      color: statusColor.withOpacity(0.4),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        statusIcon,
                                        size: 12,
                                        color: statusColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        statusLabel,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: statusColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Review Attempt Tag
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSizes.sm,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.slate.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(
                                        AppSizes.radiusSm),
                                    border: Border.all(
                                      color: AppColors.slate.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    'Attempt ${widget.profile.rejectionCount + 1}/3',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.slate,
                                    ),
                                  ),
                                ),
                                // Created date
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      size: 13,
                                      color: AppColors.slate,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      dateFormat.format(widget.profile.createdAt),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.slate,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Expand/Collapse Icon
                      Icon(
                        _isExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.md),
                  // Quick Info Row
                  Wrap(
                    spacing: AppSizes.md,
                    runSpacing: AppSizes.sm,
                    children: [
                      _buildInfoChip(
                        Icons.category,
                        widget.profile.industry.isNotEmpty
                            ? widget.profile.industry
                            : 'General',
                      ),
                      _buildInfoChip(
                        Icons.location_on,
                        widget.profile.location.isNotEmpty
                            ? widget.profile.location
                            : 'Ethiopia',
                      ),
                      if (widget.profile.fundingStage.isNotEmpty)
                        _buildInfoChip(
                          Icons.trending_up,
                          widget.profile.fundingStage,
                        ),
                    ],
                  ),

                  // Show rejection callout if rejected even in summary
                  if (isRejected &&
                      widget.profile.rejectionReason != null &&
                      widget.profile.rejectionReason!.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.sm),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSizes.sm + 2),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        border: Border.all(
                          color: AppColors.error.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 16,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: AppSizes.xs + 2),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Rejection Reason: ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.error,
                                    ),
                                  ),
                                  TextSpan(
                                    text: widget.profile.rejectionReason!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Expanded Details
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    'Contact Person',
                    widget.profile.name,
                    Icons.person,
                  ),
                  const SizedBox(height: AppSizes.sm),
                  _buildDetailRow(
                    'Email',
                    widget.profile.email,
                    Icons.email,
                  ),
                  const SizedBox(height: AppSizes.sm),
                  _buildDetailRow(
                    isStartup ? 'Funding Sought' : 'Target Ticket Size',
                    '\$${NumberFormat('#,##0').format(widget.profile.fundingAmountSought)}',
                    Icons.attach_money,
                  ),
                  if (widget.profile.approvalDate != null) ...[
                    const SizedBox(height: AppSizes.sm),
                    _buildDetailRow(
                      isApproved ? 'Approved Date' : 'Action Date',
                      dateFormat.format(widget.profile.approvalDate!),
                      Icons.calendar_today,
                    ),
                  ],
                  const SizedBox(height: AppSizes.md),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    widget.profile.description.isNotEmpty
                        ? widget.profile.description
                        : 'No description provided',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.slate,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  // Action Buttons based on status
                  if (isPending) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: widget.onRejectWithReason != null
                                ? _handleReject
                                : null,
                            icon: const Icon(Icons.cancel_outlined, size: 18),
                            label: const Text('Reject with Reason'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusMd),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.md),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: widget.onApprove,
                            icon: const Icon(Icons.check_circle, size: 18),
                            label: const Text('Approve & Publish'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: AppColors.white,
                              minimumSize: const Size.fromHeight(48),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusMd),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else if (isRejected) ...[
                    // Option to re-approve a rejected profile if needed
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: widget.onRejectWithReason != null
                                ? _handleReject
                                : null,
                            icon: const Icon(Icons.edit_note, size: 18),
                            label: const Text('Update Reason'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                              minimumSize: const Size.fromHeight(44),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.md),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: widget.onApprove,
                            icon: const Icon(Icons.check_circle_outline, size: 18),
                            label: const Text('Approve Now'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: AppColors.white,
                              minimumSize: const Size.fromHeight(44),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else if (isApproved) ...[
                    // Option to revoke approval if needed
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: widget.onRejectWithReason != null
                            ? _handleReject
                            : null,
                        icon: const Icon(Icons.cancel_outlined, size: 16),
                        label: const Text('Revoke Approval'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.hairline),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.fog,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.slate),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.slate,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.slate,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

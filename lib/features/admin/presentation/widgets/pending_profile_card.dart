import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../domain/entities/pending_approval_entity.dart';

class PendingProfileCard extends StatefulWidget {
  final PendingApprovalEntity profile;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const PendingProfileCard({
    super.key,
    required this.profile,
    required this.onApprove,
    required this.onReject,
  });

  @override
  State<PendingProfileCard> createState() => _PendingProfileCardState();
}

class _PendingProfileCardState extends State<PendingProfileCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final isStartup = widget.profile.role == 'founder';

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
                      // Business Name & Type
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.profile.businessName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSizes.xs),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSizes.sm,
                                    vertical: 4,
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
                                const SizedBox(width: AppSizes.sm),
                                Icon(Icons.access_time,
                                    size: 14, color: AppColors.slate),
                                const SizedBox(width: 4),
                                Text(
                                  dateFormat.format(widget.profile.createdAt),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.slate,
                                  ),
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
                        widget.profile.industry,
                      ),
                      _buildInfoChip(
                        Icons.location_on,
                        widget.profile.location,
                      ),
                      if (widget.profile.fundingStage.isNotEmpty)
                        _buildInfoChip(
                          Icons.trending_up,
                          widget.profile.fundingStage,
                        ),
                    ],
                  ),
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
                    'Funding Sought',
                    '\$${NumberFormat('#,##0').format(widget.profile.fundingAmountSought)}',
                    Icons.attach_money,
                  ),
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
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: widget.onReject,
                          icon: const Icon(Icons.close),
                          label: const Text('Reject'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            minimumSize: const Size.fromHeight(48),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.md),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: widget.onApprove,
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            minimumSize: const Size.fromHeight(48),
                          ),
                        ),
                      ),
                    ],
                  ),
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

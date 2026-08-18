import 'package:ethioventure/core/constants/app_styles.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class WelcomeHeader extends StatelessWidget {
  final String userName;
  final VoidCallback? onUpdatePitchDeck;

  const WelcomeHeader({
    super.key,
    required this.userName,
    this.onUpdatePitchDeck,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome back, $userName.', style: AppTextStyles.greeting),
          const SizedBox(height: 6),
          const Text(
            "Here is the latest data on your startup's traction.",
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerRight,
            child: _UpdatePitchDeckButton(onTap: onUpdatePitchDeck),
          ),
        ],
      ),
    );
  }
}

class _UpdatePitchDeckButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _UpdatePitchDeckButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withOpacity(0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.description_outlined,
                  size: 18, color: AppColors.primaryDark),
              SizedBox(width: 8),
              Text('Update Pitch Deck', style: AppTextStyles.buttonPrimary),
            ],
          ),
        ),
      ),
    );
  }
}
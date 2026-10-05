import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/app/theme/app_colors.dart';
import 'package:shopsphere/features/profile/models/user_profile.dart';

class ProfileHeaderCard extends StatelessWidget {
  final UserProfile profile;

  const ProfileHeaderCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.surface,
              child: const Icon(
                Icons.person_rounded,
                size: 36,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        profile.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.verified_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  profile.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.amberLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 13,
                        color: AppColors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        profile.membershipTier,
                        style: const TextStyle(
                          color: AppColors.amber,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.push('/profile/edit'),
            icon: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

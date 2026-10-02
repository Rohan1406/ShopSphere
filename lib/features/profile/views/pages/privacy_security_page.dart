import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/app/theme/app_colors.dart';
import 'package:shopsphere/features/profile/views/widgets/active_sessions_card.dart';
import 'package:shopsphere/features/profile/views/widgets/change_password_modal_sheet.dart';
import 'package:shopsphere/features/profile/views/widgets/delete_account_dialog.dart';
import 'package:shopsphere/features/profile/views/widgets/notification_section_card.dart';

class PrivacySecurityPage extends ConsumerStatefulWidget {
  const PrivacySecurityPage({super.key});

  @override
  ConsumerState<PrivacySecurityPage> createState() =>
      _PrivacySecurityPageState();
}

class _PrivacySecurityPageState extends ConsumerState<PrivacySecurityPage> {
  bool _twoFactorEnabled = true;
  bool _biometricEnabled = true;

  final List<Map<String, String>> _activeSessions = [
    {
      'device': 'iPhone 15 Pro (Current Device)',
      'location': 'Bengaluru, India',
      'lastActive': 'Active Now',
      'isCurrent': 'true',
    },
    {
      'device': 'Chrome Browser on macOS',
      'location': 'Bengaluru, India',
      'lastActive': '2 hours ago',
      'isCurrent': 'false',
    },
    {
      'device': 'iPad Pro 11"',
      'location': 'Mumbai, India',
      'lastActive': 'Yesterday, 04:30 PM',
      'isCurrent': 'false',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Privacy & Security')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Authentication & Protection
            NotificationSectionCard(
              title: 'Account Security',
              children: [
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.security_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Two-Factor Authentication (2FA)',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                  subtitle: const Text(
                    'Enforces SMS / Authenticator verification upon new device logins',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  value: _twoFactorEnabled,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() => _twoFactorEnabled = val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(val ? '2FA Enabled.' : '2FA Disabled.'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, color: AppColors.borderLight),
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.fingerprint_rounded,
                      color: AppColors.accent,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Biometric Quick Unlock',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                  subtitle: const Text(
                    'Use Face ID / Touch ID for lightning checkout authorization',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  value: _biometricEnabled,
                  activeThumbColor: AppColors.accent,
                  onChanged: (val) {
                    setState(() => _biometricEnabled = val);
                  },
                ),
                const Divider(height: 1, color: AppColors.borderLight),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.password_rounded,
                      color: AppColors.amber,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Change Password',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                  subtitle: const Text(
                    'Last modified 45 days ago',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: AppColors.textMuted,
                  ),
                  onTap: () => ChangePasswordModalSheet.show(context),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Section 2: Active Devices & Sessions
            ActiveSessionsCard(
              sessions: _activeSessions,
              onRevokeOtherSessions: () {
                setState(() {
                  _activeSessions.removeWhere((s) => s['isCurrent'] != 'true');
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logged out of all other device sessions.'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
            ),

            const SizedBox(height: 18),

            // Section 3: Data Rights & Account Deletion
            NotificationSectionCard(
              title: 'Data & Privacy Control',
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.download_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Download Personal Data Archive',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                  subtitle: const Text(
                    'Receive a ZIP file containing your orders, reviews, and logs',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: AppColors.textMuted,
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Personal data request created. Link will be emailed to you.',
                        ),
                        backgroundColor: AppColors.info,
                      ),
                    );
                  },
                ),
                const Divider(height: 1, color: AppColors.borderLight),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.errorSurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.delete_forever_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Delete Account',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      color: AppColors.error,
                    ),
                  ),
                  subtitle: const Text(
                    'Permanently erase your account and shopping data',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: AppColors.error,
                  ),
                  onTap: () => DeleteAccountDialog.show(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// In-app Privacy Policy screen.
///
/// This screen is shown from the Profile > Settings section.  It presents
/// the full privacy policy inline so that users can read it without leaving
/// the app.  It is also the mandatory landing point before account deletion.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D18),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1426),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildHeader('AI Nexus — Privacy Policy'),
          _buildDate('Effective date: 24 October 2026'),
          const SizedBox(height: 24),

          _buildSection('1. Who we are', '''
AI Nexus is a mobile application that aggregates publicly available AI/tech events from multiple platforms into a single searchable feed. The app is operated by the AI Nexus development team ("we", "us", or "our").'''),

          _buildSection('2. What data we collect', '''
We collect only the minimum data necessary to provide the service:

• **Account data** — your email address, display name, and profile photo URL when you create an account or sign in with Google.
• **Preferences** — your role, interests, and event-mode preference stored locally on your device using encrypted storage.
• **Bookmarks** — the IDs of events you bookmark, stored locally and optionally synced to our backend.
• **Device information** — device type (emulator vs. physical) used solely to determine the correct API host address; not stored on our servers.
• **Usage data** — we do not currently collect analytics or crash reports beyond what Firebase provides automatically under its own privacy policy.'''),

          _buildSection('3. How we use your data', '''
• To authenticate you and maintain your session.
• To personalise your event feed based on your stated interests.
• To persist your bookmarks across devices (when backend sync is enabled).
• To send push notifications about upcoming AI events (only with your explicit consent).

We do **not** sell, rent, or trade your personal data to any third party.'''),

          _buildSection('4. Data storage and security', '''
• Tokens and user preferences are stored in device-encrypted secure storage (flutter_secure_storage / Android Keystore / iOS Keychain).
• All network communication uses TLS 1.2 or higher. Certificate pinning is enforced in production builds.
• Screenshots and screen recordings of the app are blocked at the OS level to protect your data from being captured inadvertently.
• The app automatically logs you out after 30 minutes of inactivity and after 5 minutes in the background.'''),

          _buildSection('5. Firebase and Google services', '''
This app uses Firebase Authentication, Cloud Firestore, and Firebase Cloud Messaging. These services are provided by Google LLC and are governed by the Google Privacy Policy (https://policies.google.com/privacy). Firebase may collect device identifiers, IP addresses, and usage data as described in its own privacy policy.'''),

          _buildSection('6. Your rights', '''
You have the right to:
• Access the personal data we hold about you.
• Correct inaccurate data.
• Delete your account and all associated data.
• Withdraw consent for push notifications at any time via device settings.

To request account deletion or data removal, you can sign out via **Profile → Log out** or contact our team directly at the contact email below. All associated user data will be permanently purged within 30 days.'''),

          _buildSection('7. Data retention', '''
We retain your data for as long as your account is active. When you delete your account, your data is scheduled for permanent deletion within 30 days.'''),

          _buildSection("8. Children's privacy", '''
This app is not directed to children under the age of 13. We do not knowingly collect personal data from children. If you believe a child has provided us with personal data, please contact us and we will delete it immediately.'''),

          _buildSection('9. Changes to this policy', '''
We may update this Privacy Policy from time to time. When we do, we will notify you via an in-app notice. Your continued use of the app after changes constitutes your acceptance of the updated policy.'''),

          _buildSection('10. Contact', '''
If you have any questions about this Privacy Policy or your data, please open an issue on our GitHub repository or contact us at the email listed in the app store listing.'''),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        height: 1.3,
      ),
    );
  }

  Widget _buildDate(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.primary.withValues(alpha: 0.8),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

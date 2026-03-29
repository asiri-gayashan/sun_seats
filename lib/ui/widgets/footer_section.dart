import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../screens/about_screen.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.white,
        border: Border(top: BorderSide(color: AppTheme.midGray, width: 0.5)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 16,
          children: [
            const Text(
              '© 2026 ShadeSeat LK • Built for Sri Lanka',
              style: TextStyle(fontSize: 12, color: AppTheme.darkText),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _FooterLink('Privacy Policy', onTap: () {}),
                const SizedBox(width: 16),
                _FooterLink(
                  'About',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AboutScreen()),
                    );
                  },
                ),
                const SizedBox(width: 16),
                _FooterLink('Contact', onTap: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _FooterLink(this.text, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: AppTheme.primaryBlue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

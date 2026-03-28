import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/result_state.dart';
import 'seat_diagram.dart';

class ResultPanel extends StatelessWidget {
  const ResultPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ResultState>();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.midGray, width: 0.5),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildContent(context, state),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ResultState state) {
    switch (state.status) {
      case ResultPanelState.empty:
        return _buildEmptyState(context);
      case ResultPanelState.loading:
        return _buildLoadingState(context);
      case ResultPanelState.success:
        return _buildSuccessState(context, state);
      case ResultPanelState.error:
        return _buildErrorState(context, state);
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      key: const ValueKey('empty'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        const Icon(Icons.wb_sunny, size: 40, color: AppTheme.midGray),
        const SizedBox(height: 16),
        const Text('Ready to find your shade?', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: AppTheme.darkText)),
        const SizedBox(height: 16),
        const Text('1 — Enter where you’re headed\n2 — We’ll map your shady escape\n3 — Sit back and stay cool', 
          style: TextStyle(fontSize: 13, color: AppTheme.darkText, height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: AppTheme.lightBlue, borderRadius: BorderRadius.circular(12)),
          child: const Text('Optimised for Sri Lanka routes', style: TextStyle(color: AppTheme.primaryBlue, fontSize: 11)),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Column(
      key: const ValueKey('loading'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        const CircularProgressIndicator(color: AppTheme.primaryGreen),
        const SizedBox(height: 24),
        const Text('Calculating sun position along your route...', style: TextStyle(fontSize: 14, color: AppTheme.darkText)),
        const SizedBox(height: 8),
        const Text('Analysing 100+ points for maximum accuracy', style: TextStyle(fontSize: 12, color: AppTheme.midGray)),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSuccessState(BuildContext context, ResultState state) {
    final data = state.resultData;
    if (data == null) return const SizedBox();
    
    bool isLeft = data.isLeftShady; 
    return Column(
      key: const ValueKey('success'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(data.journeySummary, style: const TextStyle(fontSize: 12, color: AppTheme.darkText)),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: isLeft ? AppTheme.lightGreen : AppTheme.lightBlue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(isLeft ? 'SIT LEFT' : 'SIT RIGHT', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
        ),
        const SizedBox(height: 16),
        Text(
          data.explanation,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: AppTheme.darkText),
        ),
        const SizedBox(height: 8),
        Text('${data.shadyPercentage}% of route', style: const TextStyle(fontSize: 12, color: AppTheme.amber, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),

        // Seat Diagram!
        SeatDiagram(isLeftShady: isLeft),

        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () => _handleShare(context, data),
          icon: const Icon(Icons.share, size: 18),
          label: const Text('Share this result'),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => _handleTryAgain(context),
          child: const Text('Try another journey', style: TextStyle(color: AppTheme.darkText, decoration: TextDecoration.underline)),
        )
      ],
    );
  }

  Future<void> _handleShare(BuildContext context, data) async {
    final text = '${data.journeySummary}: SIT ${data.isLeftShady ? 'LEFT' : 'RIGHT'} for shade! 🌞 #ShadeSeatLK';
    
    try {
      // Try to use the native share sheet via url_launcher if available
      if (await canLaunchUrl(Uri.parse('whatsapp://send?text=$text'))) {
        // For web, we'll just show a copy-to-clipboard snackbar
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Share functionality - text ready to share'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share error: $e')),
        );
      }
    }
  }

  void _handleTryAgain(BuildContext context) {
    context.read<ResultState>().reset();
  }

  Widget _buildErrorState(BuildContext context, ResultState state) {
    return Column(
      key: const ValueKey('error'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.warning_amber_rounded, size: 48, color: AppTheme.amber),
        const SizedBox(height: 16),
        Text('Could not find this route', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(state.errorMessage ?? 'Please check your start and end locations.', textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: AppTheme.darkText)),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => state.reset(),
          child: const Text('Try Again', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

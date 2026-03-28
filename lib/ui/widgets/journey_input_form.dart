import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class JourneyInputForm extends StatefulWidget {
  const JourneyInputForm({super.key});

  @override
  State<JourneyInputForm> createState() => _JourneyInputFormState();
}

class _JourneyInputFormState extends State<JourneyInputForm> {
  // Temporary local state for UI toggles
  String _selectedMode = 'Bus';
  String _selectedTimezone = '(UTC+05:30) Sri Lanka';

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Plan your journey', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          _buildLocationFields(),
          const SizedBox(height: 24),
          _buildDateTimeFields(),
          const SizedBox(height: 24),
          _buildTransitModeFields(),
          const SizedBox(height: 24),
          _buildTimezoneField(),
          const SizedBox(height: 32),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildLocationFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Start Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.darkText)),
        const SizedBox(height: 8),
        const TextField(
          decoration: InputDecoration(
            hintText: 'e.g. Colombo Fort',
            prefixIcon: Icon(Icons.location_on_outlined, color: AppTheme.midGray),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {},
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.my_location, size: 16, color: AppTheme.primaryBlue),
              SizedBox(width: 6),
              Text('Use Current Location', style: TextStyle(color: AppTheme.primaryBlue, fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('End Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.darkText)),
        const SizedBox(height: 8),
        const TextField(
          decoration: InputDecoration(
            hintText: 'e.g. Kandy',
            prefixIcon: Icon(Icons.location_on, color: AppTheme.primaryBlue),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeFields() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.darkText)),
              const SizedBox(height: 8),
              TextField(
                readOnly: true,
                onTap: () {},
                decoration: const InputDecoration(
                  hintText: '29/03/2026',
                  suffixIcon: Icon(Icons.calendar_today, size: 18, color: AppTheme.midGray),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.darkText)),
              const SizedBox(height: 8),
              TextField(
                readOnly: true,
                onTap: () {},
                decoration: const InputDecoration(
                  hintText: '08:00 AM',
                  suffixIcon: Icon(Icons.access_time, size: 18, color: AppTheme.midGray),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransitModeFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Mode of Transit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.darkText)),
        const SizedBox(height: 8),
        Row(
          children: [
            _TransitModeButton(
              text: 'Bus',
              icon: Icons.directions_bus,
              isSelected: _selectedMode == 'Bus',
              onTap: () => setState(() => _selectedMode = 'Bus'),
            ),
            const SizedBox(width: 12),
            _TransitModeButton(
              text: 'Train',
              icon: Icons.train,
              isSelected: _selectedMode == 'Train',
              onTap: () => setState(() => _selectedMode = 'Train'),
            ),
            const SizedBox(width: 12),
            _TransitModeButton(
              text: 'Other',
              icon: Icons.directions_car,
              isSelected: _selectedMode == 'Other',
              onTap: () => setState(() => _selectedMode = 'Other'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimezoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Timezone', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.darkText)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.midGray),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedTimezone,
              items: ['(UTC+05:30) Sri Lanka', '(UTC+00:00) London']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14))))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedTimezone = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {},
        child: const Text('Find My Shady Spot', style: TextStyle(fontSize: 15)),
      ),
    );
  }
}

class _TransitModeButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TransitModeButton({
    required this.text,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.lightGreen : AppTheme.white,
            border: Border.all(color: isSelected ? AppTheme.primaryGreen : AppTheme.midGray),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppTheme.primaryGreen : AppTheme.midGray, size: 24),
              const SizedBox(height: 4),
              Text(
                text,
                style: TextStyle(
                  color: isSelected ? AppTheme.primaryGreen : AppTheme.midGray,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

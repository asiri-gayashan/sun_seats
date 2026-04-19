import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/journey_form_state.dart';
import '../../core/providers/location_state.dart';
import '../../core/providers/result_state.dart';
import '../../core/services/directions_service.dart';
import '../../core/services/calculation_engine.dart';
import '../../core/services/places_service.dart';

class JourneyInputForm extends StatefulWidget {
  const JourneyInputForm({super.key});

  @override
  State<JourneyInputForm> createState() => _JourneyInputFormState();
}

class _JourneyInputFormState extends State<JourneyInputForm> {
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final formState = context.read<JourneyFormState>();
    _startController.text = formState.startLocation;
    _endController.text = formState.endLocation;

    _startController.addListener(() {
      context.read<JourneyFormState>().setStartLocation(_startController.text);
    });
    _endController.addListener(() {
      context.read<JourneyFormState>().setEndLocation(_endController.text);
    });
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  void _handleCurrentLocationTap() async {
    final locationState = context.read<LocationState>();
    final loc = await locationState.fetchCurrentLocation();
    if (loc != null) {
      _startController.text = loc;
    }
  }

  void _handleFindShade(BuildContext context) async {
    final formState = context.read<JourneyFormState>();
    final resultState = context.read<ResultState>();

    if (!formState.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid start and end locations.'),
        ),
      );
      return;
    }

    resultState.startLoading();

    try {
      DateTime journeyDt = DateTime(
        formState.journeyDate.year,
        formState.journeyDate.month,
        formState.journeyDate.day,
        formState.journeyTime.hour,
        formState.journeyTime.minute,
      );

      final routesData = await DirectionsService.getRoutePolylines(
        formState.startLocation,
        formState.endLocation,
        formState.transitMode,
      );

      if (routesData.isEmpty) throw 'No routes found.';
      final primaryRoute = routesData[0];
      
      final List<LatLngNode> pathPoints = CalculationEngine.decodePolyline(primaryRoute.mergedPolyline);

      List<List<LatLngNode>> alternates = [];
      for (int i = 1; i < routesData.length; i++) {
        alternates.add(CalculationEngine.decodePolyline(routesData[i].mergedPolyline));
      }

      if (pathPoints.isEmpty) throw 'Route could not be decoded.';

      final shadeResult = CalculationEngine.calculateShade(
        pathPoints,
        journeyDt,
      );

      bool isNight = journeyDt.hour >= 18 || journeyDt.hour < 6;

      String explanation = shadeResult.isLeftShady
          ? 'The sun will mostly hit the left side. Sit on the right for shade.'
          : 'The sun will mostly hit the right side. Sit on the left for shade.';

      resultState.setSuccess(
        MockResultData(
          isLeftShady: shadeResult.isLeftShady,
          shadyPercentage: shadeResult.shadyPercentage,
          sunLeftPercentage: shadeResult.sunLeftPercentage,
          sunRightPercentage: shadeResult.sunRightPercentage,
          noSunPercentage: shadeResult.noSunPercentage,
          journeySummary:
              '${formState.startLocation} \u2192 ${formState.endLocation} \u2022 ${formState.transitMode} \u2022 ${primaryRoute.distance}',
          explanation: explanation,
          isNight: isNight,
          routePoints: pathPoints,
          routeSegments: shadeResult.segments,
          alternateRoutesPoints: alternates,
        ),
      );
    } catch (e) {
      resultState.setError(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.midGray, width: 0.5),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plan your journey',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          _buildLocationFields(context),
          const SizedBox(height: 24),
          _buildDateTimeFields(context),
          const SizedBox(height: 24),
          _buildTransitModeFields(context),
          const SizedBox(height: 24),
          _buildTimezoneField(context),
          const SizedBox(height: 32),
          _buildSubmitButton(context),
        ],
      ),
    );
  }

  Widget _buildLocationFields(BuildContext context) {
    final isFetchingLoc = context.watch<LocationState>().isFetching;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Start Location',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: AppTheme.darkText,
          ),
        ),
        const SizedBox(height: 8),
        _LocationAutocomplete(
          controller: _startController,
          hintText: 'e.g. Colombo Fort',
          prefixIcon: Icons.location_on_outlined,
          iconColor: AppTheme.midGray,
          onChanged: (val) {
            context.read<JourneyFormState>().setStartLocation(val);
          },
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: isFetchingLoc ? null : _handleCurrentLocationTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              isFetchingLoc
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(
                      Icons.my_location,
                      size: 16,
                      color: AppTheme.primaryBlue,
                    ),
              const SizedBox(width: 6),
              Text(
                isFetchingLoc ? 'Getting location...' : 'Use Current Location',
                style: TextStyle(
                  color: isFetchingLoc
                      ? AppTheme.midGray
                      : AppTheme.primaryBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'End Location',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: AppTheme.darkText,
          ),
        ),
        const SizedBox(height: 8),
        _LocationAutocomplete(
          controller: _endController,
          hintText: 'e.g. Kandy',
          prefixIcon: Icons.location_on,
          iconColor: AppTheme.primaryBlue,
          onChanged: (val) {
            context.read<JourneyFormState>().setEndLocation(val);
          },
        ),
      ],
    );
  }

  Widget _buildDateTimeFields(BuildContext context) {
    final formState = context.watch<JourneyFormState>();
    final dateStr =
        '${formState.journeyDate.day}/${formState.journeyDate.month}/${formState.journeyDate.year}';
    final timeStr = formState.journeyTime.format(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Date',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                readOnly: true,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: formState.journeyDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null && context.mounted) {
                    context.read<JourneyFormState>().setJourneyDate(picked);
                  }
                },
                decoration: InputDecoration(
                  hintText: dateStr,
                  suffixIcon: const Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: AppTheme.midGray,
                  ),
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
              const Text(
                'Time',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                readOnly: true,
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: formState.journeyTime,
                  );
                  if (picked != null) {
                    if (context.mounted) {
                      context.read<JourneyFormState>().setJourneyTime(picked);
                    }
                  }
                },
                decoration: InputDecoration(
                  hintText: timeStr,
                  suffixIcon: const Icon(
                    Icons.access_time,
                    size: 18,
                    color: AppTheme.midGray,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransitModeFields(BuildContext context) {
    final formState = context.watch<JourneyFormState>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mode of Transit',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: AppTheme.darkText,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _TransitModeButton(
              text: 'Bus',
              icon: Icons.directions_bus,
              isSelected: formState.transitMode == 'Bus',
              onTap: () =>
                  context.read<JourneyFormState>().setTransitMode('Bus'),
            ),
            const SizedBox(width: 12),
            _TransitModeButton(
              text: 'Train',
              icon: Icons.train,
              isSelected: formState.transitMode == 'Train',
              onTap: () =>
                  context.read<JourneyFormState>().setTransitMode('Train'),
            ),
            const SizedBox(width: 12),
            _TransitModeButton(
              text: 'Other',
              icon: Icons.directions_car,
              isSelected: formState.transitMode == 'Other',
              onTap: () =>
                  context.read<JourneyFormState>().setTransitMode('Other'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimezoneField(BuildContext context) {
    final formState = context.watch<JourneyFormState>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Timezone',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: AppTheme.darkText,
          ),
        ),
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
              value: formState.timezone,
              items: ['(UTC+05:30) Sri Lanka', '(UTC+00:00) London']
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e, style: const TextStyle(fontSize: 14)),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  context.read<JourneyFormState>().setTimezone(val);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () => _handleFindShade(context),
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
            border: Border.all(
              color: isSelected ? AppTheme.primaryGreen : AppTheme.midGray,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppTheme.primaryGreen : AppTheme.midGray,
                size: 24,
              ),
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

class _LocationAutocomplete extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final Color iconColor;
  final void Function(String) onChanged;

  const _LocationAutocomplete({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    required this.iconColor,
    required this.onChanged,
  });

  @override
  State<_LocationAutocomplete> createState() => _LocationAutocompleteState();
}

class _LocationAutocompleteState extends State<_LocationAutocomplete> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      textEditingController: widget.controller,
      focusNode: _focusNode,
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if (textEditingValue.text.length < 2) {
          return const Iterable<String>.empty();
        }
        return await PlacesService.getPlaceSuggestions(textEditingValue.text);
      },
      onSelected: (String selection) {
        widget.onChanged(selection);
      },
      fieldViewBuilder: (context, txtController, focusNode, onFieldSubmitted) {
        return ValueListenableBuilder<TextEditingValue>(
          valueListenable: txtController,
          builder: (context, value, child) {
            return TextField(
              controller: txtController,
              focusNode: focusNode,
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                hintText: widget.hintText,
                prefixIcon: Icon(widget.prefixIcon, color: widget.iconColor),
                suffixIcon: value.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          size: 18,
                          color: AppTheme.midGray,
                        ),
                        onPressed: () {
                          txtController.clear();
                          widget.onChanged('');
                        },
                      )
                    : null,
              ),
            );
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 250.0,
              width: MediaQuery.of(context).size.width >= 768
                  ? MediaQuery.of(context).size.width * 0.4
                  : MediaQuery.of(context).size.width * 0.8,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final String option = options.elementAt(index);
                  return InkWell(
                    onTap: () => onSelected(option),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppTheme.lightGray),
                        ),
                      ),
                      child: Text(
                        option,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.darkText,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

import '../../game/models/location.dart';
import '../../game/services/location_data_service.dart';

class LocationSelector extends StatelessWidget {
  final Location currentLocation;
  final List<String> availableLocations;
  final Function(String) onLocationChanged;

  const LocationSelector({
    super.key,
    required this.currentLocation,
    required this.availableLocations,
    required this.onLocationChanged,
  });

  @override
  Widget build(BuildContext context) {
    final locationService = LocationDataService.instance;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current location header
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Current Location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Current location card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentLocation.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${currentLocation.country}, ${currentLocation.continent}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (currentLocation.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    currentLocation.description,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          
          // Travel options
          if (availableLocations.length > 1) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.travel_explore,
                  color: Colors.blue.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Travel Destinations',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Travel destination chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableLocations
                  .where((id) => id != currentLocation.id)
                  .map((locationId) {
                final location = locationService.getLocationById(locationId);
                if (location == null) return const SizedBox.shrink();
                
                return InkWell(
                  onTap: () => onLocationChanged(locationId),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.flight_takeoff,
                          size: 16,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          location.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
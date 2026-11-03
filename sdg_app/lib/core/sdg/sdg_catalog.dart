import 'package:flutter/material.dart';

/// One entry per UN goal. `route` is null for the 12 not built yet - those
/// render greyed out with "Coming soon", which is the agreed home-screen
/// behaviour (shows the full ambition without faking features).
class SdgEntry {
  final int goal;
  final String titleKey;
  final String descKey;
  final IconData icon;
  final String? route;

  const SdgEntry({
    required this.goal,
    required this.titleKey,
    required this.descKey,
    required this.icon,
    this.route,
  });

  bool get isLive => route != null;
}

/// All 17 goals are built and translated (zip 24).
const List<SdgEntry> kSdgCatalog = [
  SdgEntry(
    goal: 1,
    titleKey: 'sdg1_title',
    descKey: 'sdg1_desc',
    icon: Icons.volunteer_activism_outlined,
    route: '/sdg/1',
  ),
  SdgEntry(
    goal: 2,
    titleKey: 'sdg2_title',
    descKey: 'sdg2_desc',
    icon: Icons.restaurant_outlined,
    route: '/sdg/2',
  ),
  SdgEntry(
    goal: 3,
    titleKey: 'sdg3_title',
    descKey: 'sdg3_desc',
    icon: Icons.favorite_outline,
    route: '/sdg/3',
  ),
  SdgEntry(
    goal: 4,
    titleKey: 'sdg4_title',
    descKey: 'sdg4_desc',
    icon: Icons.school_outlined,
    route: '/sdg/4',
  ),
  SdgEntry(
    goal: 5,
    titleKey: 'sdg5_title',
    descKey: 'sdg5_desc',
    icon: Icons.diversity_3_outlined,
    route: '/sdg/5',
  ),
  SdgEntry(
    goal: 6,
    titleKey: 'sdg6_title',
    descKey: 'sdg6_desc',
    icon: Icons.water_drop_outlined,
    route: '/sdg/6',
  ),
  SdgEntry(
    goal: 7,
    titleKey: 'sdg7_title',
    descKey: 'sdg7_desc',
    icon: Icons.bolt_outlined,
    route: '/sdg/7',
  ),
  SdgEntry(
    goal: 8,
    titleKey: 'sdg8_title',
    descKey: 'sdg8_desc',
    icon: Icons.work_outline,
    route: '/sdg/8',
  ),
  SdgEntry(
    goal: 9,
    titleKey: 'sdg9_title',
    descKey: 'sdg9_desc',
    icon: Icons.precision_manufacturing_outlined,
    route: '/sdg/9',
  ),
  SdgEntry(
    goal: 10,
    titleKey: 'sdg10_title',
    descKey: 'sdg10_desc',
    icon: Icons.balance_outlined,
    route: '/sdg/10',
  ),
  SdgEntry(
    goal: 11,
    titleKey: 'sdg11_title',
    descKey: 'sdg11_desc',
    icon: Icons.location_city_outlined,
    route: '/sdg/11',
  ),
  SdgEntry(
    goal: 12,
    titleKey: 'sdg12_title',
    descKey: 'sdg12_desc',
    icon: Icons.recycling_outlined,
    route: '/sdg/12',
  ),
  SdgEntry(
    goal: 13,
    titleKey: 'sdg13_title',
    descKey: 'sdg13_desc',
    icon: Icons.thermostat_outlined,
    route: '/sdg/13',
  ),
  SdgEntry(
    goal: 14,
    titleKey: 'sdg14_title',
    descKey: 'sdg14_desc',
    icon: Icons.waves_outlined,
    route: '/sdg/14',
  ),
  SdgEntry(
    goal: 15,
    titleKey: 'sdg15_title',
    descKey: 'sdg15_desc',
    icon: Icons.forest_outlined,
    route: '/sdg/15',
  ),
  SdgEntry(
    goal: 16,
    titleKey: 'sdg16_title',
    descKey: 'sdg16_desc',
    icon: Icons.gavel_outlined,
    route: '/sdg/16',
  ),
  SdgEntry(
    goal: 17,
    titleKey: 'sdg17_title',
    descKey: 'sdg17_desc',
    icon: Icons.handshake_outlined,
    route: '/sdg/17',
  ),
];

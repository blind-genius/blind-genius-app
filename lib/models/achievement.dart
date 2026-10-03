class Achievement {
  final String year;
  final String title;
  final String organization;
  final String description;
  final String iconType;

  const Achievement({
    required this.year,
    required this.title,
    required this.organization,
    required this.description,
    required this.iconType,
  });

  String get accessibilityLabel =>
      'Achievement in $year: $title awarded by $organization. Summary: $description.';
}

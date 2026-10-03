class Challenge {
  final String id;
  final String title;
  final String difficulty;
  final String deadline;
  final String reward;
  final String description;
  final String instructions;
  final bool isCompleted;
  final int participantsCount;

  const Challenge({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.deadline,
    required this.reward,
    required this.description,
    required this.instructions,
    this.isCompleted = false,
    this.participantsCount = 142,
  });

  String get accessibilityLabel =>
      'Challenge: $title. Difficulty: $difficulty. Deadline: $deadline. '
      'Reward: $reward. Participants: $participantsCount. Status: ${isCompleted ? "Completed" : "Active"}. '
      'Description: $description. Double tap for instructions and submission.';
}

class CommunityEvent {
  final String id;
  final String title;
  final String date;
  final String time;
  final String format; // "Live Audio Stream", "Workshop", "Concert"
  final String locationOrPlatform;
  final String description;
  final bool isRegistered;

  const CommunityEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.format,
    required this.locationOrPlatform,
    required this.description,
    this.isRegistered = false,
  });

  String get accessibilityLabel =>
      'Event: $title. Date: $date at $time. Format: $format on $locationOrPlatform. '
      'Status: ${isRegistered ? "You are registered" : "Not registered"}. '
      'Details: $description. Double tap to toggle registration.';
}

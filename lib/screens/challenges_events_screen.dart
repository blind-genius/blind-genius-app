import 'package:flutter/material.dart';
import '../models/challenge.dart';
import '../services/accessibility_service.dart';
import '../services/mock_data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/accessible_button.dart';
import '../widgets/accessible_card.dart';

class ChallengesEventsScreen extends StatefulWidget {
  const ChallengesEventsScreen({super.key});

  @override
  State<ChallengesEventsScreen> createState() => _ChallengesEventsScreenState();
}

class _ChallengesEventsScreenState extends State<ChallengesEventsScreen> {
  int _selectedSection = 0; // 0 = Challenges, 1 = Live Events
  late List<Challenge> _challenges;
  late List<CommunityEvent> _events;

  @override
  void initState() {
    super.initState();
    _challenges = List.from(MockDataService.sampleChallenges);
    _events = List.from(MockDataService.sampleEvents);
  }

  void _toggleChallengeStatus(int index) {
    final chal = _challenges[index];
    final updated = Challenge(
      id: chal.id,
      title: chal.title,
      difficulty: chal.difficulty,
      deadline: chal.deadline,
      reward: chal.reward,
      description: chal.description,
      instructions: chal.instructions,
      isCompleted: !chal.isCompleted,
      participantsCount: chal.isCompleted ? chal.participantsCount - 1 : chal.participantsCount + 1,
    );

    setState(() {
      _challenges[index] = updated;
    });

    AccessibilityService.hapticHeavy();
    AccessibilityService.announce(
      updated.isCompleted
          ? 'Challenge ${chal.title} marked as completed! Reward unlocked: ${chal.reward}'
          : 'Challenge ${chal.title} marked active.',
    );
  }

  void _toggleEventRegistration(int index) {
    final evt = _events[index];
    final updated = CommunityEvent(
      id: evt.id,
      title: evt.title,
      date: evt.date,
      time: evt.time,
      format: evt.format,
      locationOrPlatform: evt.locationOrPlatform,
      description: evt.description,
      isRegistered: !evt.isRegistered,
    );

    setState(() {
      _events[index] = updated;
    });

    AccessibilityService.hapticHeavy();
    AccessibilityService.announce(
      updated.isRegistered
          ? 'Successfully registered for ${evt.title} on ${evt.date}. Calendar reminder set.'
          : 'Registration cancelled for ${evt.title}.',
    );
  }

  void _showChallengeDetails(Challenge chal, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: AppTheme.goldAccent, width: 2)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        chal.title,
                        style: const TextStyle(
                          color: AppTheme.goldAccent,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textPrimary),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Difficulty: ${chal.difficulty} • ${chal.deadline}',
                style: const TextStyle(color: AppTheme.cyanAccent, fontWeight: FontWeight.bold),
              ),
              const Divider(color: AppTheme.border, height: 24),
              const Text(
                'Instructions for Screen Reader & Tactile Input:',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                chal.instructions,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceHighlight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.military_tech, color: AppTheme.goldAccent, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Reward: ${chal.reward}',
                        style: const TextStyle(
                          color: AppTheme.goldAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AccessibleButton(
                label: chal.isCompleted ? 'MARK AS INCOMPLETE' : 'COMPLETE & SUBMIT ENTRY',
                isPrimary: !chal.isCompleted,
                isFullWidth: true,
                onPressed: () {
                  Navigator.pop(ctx);
                  _toggleChallengeStatus(index);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Segmented Control
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceHighlight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: _selectedSection == 0,
                    label: 'Creative Challenges tab. ${_selectedSection == 0 ? "Selected" : ""}',
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() => _selectedSection = 0);
                        AccessibilityService.announce('Showing Creative Challenges');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedSection == 0 ? AppTheme.goldAccent : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'CHALLENGES',
                          style: TextStyle(
                            color: _selectedSection == 0 ? Colors.black : AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: _selectedSection == 1,
                    label: 'Live Events tab. ${_selectedSection == 1 ? "Selected" : ""}',
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() => _selectedSection = 1);
                        AccessibilityService.announce('Showing Live Community Events');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedSection == 1 ? AppTheme.goldAccent : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'LIVE EVENTS',
                          style: TextStyle(
                            color: _selectedSection == 1 ? Colors.black : AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Section Content
        Expanded(
          child: _selectedSection == 0 ? _buildChallengesList() : _buildEventsList(),
        ),
      ],
    );
  }

  Widget _buildChallengesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _challenges.length,
      itemBuilder: (context, index) {
        final chal = _challenges[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: AccessibleCard(
            semanticLabel: chal.accessibilityLabel,
            semanticHint: 'Double tap to view challenge details or record your answer',
            borderColor: chal.isCompleted ? AppTheme.mintGreen : null,
            onTap: () => _showChallengeDetails(chal, index),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceHighlight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        chal.difficulty.toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.goldAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    if (chal.isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.mintGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.mintGreen),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle, color: AppTheme.mintGreen, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'COMPLETED',
                              style: TextStyle(
                                color: AppTheme.mintGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Text(
                        chal.deadline,
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  chal.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  chal.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '👥 ${chal.participantsCount} joined',
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                    Semantics(
                      button: true,
                      label: chal.isCompleted
                          ? 'Unmark completion for ${chal.title}'
                          : 'Participate and submit ${chal.title}',
                      child: TextButton(
                        onPressed: () => _toggleChallengeStatus(index),
                        child: Text(
                          chal.isCompleted ? 'RESET' : 'PARTICIPATE',
                          style: TextStyle(
                            color: chal.isCompleted ? AppTheme.textMuted : AppTheme.goldAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final evt = _events[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: AccessibleCard(
            semanticLabel: evt.accessibilityLabel,
            semanticHint: 'Double tap to register or see live event connection details',
            borderColor: evt.isRegistered ? AppTheme.goldAccent : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.cyanAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.cyanAccent.withOpacity(0.4)),
                      ),
                      child: Text(
                        evt.format.toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.cyanAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    Text(
                      evt.time,
                      style: const TextStyle(color: AppTheme.goldAccent, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  evt.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: AppTheme.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      evt.date,
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  evt.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                Semantics(
                  button: true,
                  label: evt.isRegistered
                      ? 'Cancel reservation for ${evt.title}'
                      : 'RSVP and get access link for ${evt.title}',
                  child: ElevatedButton.icon(
                    onPressed: () => _toggleEventRegistration(index),
                    icon: Icon(
                      evt.isRegistered ? Icons.check_circle : Icons.event_available,
                      color: evt.isRegistered ? Colors.black : Colors.black,
                      size: 20,
                    ),
                    label: Text(evt.isRegistered ? 'REGISTERED (TAP TO CANCEL)' : 'RSVP FOR EVENT'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: evt.isRegistered ? AppTheme.mintGreen : AppTheme.goldAccent,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

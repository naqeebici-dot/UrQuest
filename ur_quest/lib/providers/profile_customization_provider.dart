import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/achievement_model.dart';

class ProfileCustomizationState {
  final String activeTitleId;
  final List<String?> showcaseAchievementIds;

  const ProfileCustomizationState({
    required this.activeTitleId,
    required this.showcaseAchievementIds,
  });

  ProfileCustomizationState copyWith({
    String? activeTitleId,
    List<String?>? showcaseAchievementIds,
  }) {
    return ProfileCustomizationState(
      activeTitleId: activeTitleId ?? this.activeTitleId,
      showcaseAchievementIds: showcaseAchievementIds ?? this.showcaseAchievementIds,
    );
  }
}

final profileCustomizationProvider =
    NotifierProvider<ProfileCustomizationNotifier, ProfileCustomizationState>(
  ProfileCustomizationNotifier.new,
);

class ProfileCustomizationNotifier extends Notifier<ProfileCustomizationState> {
  @override
  ProfileCustomizationState build() {
    final defaultTitle = HunterCodexMock.titles.firstWhere(
      (title) => title.state == HunterTitleState.equipped,
      orElse: () => HunterCodexMock.titles.first,
    );
    final unlocked = HunterCodexMock.achievements.where((a) => a.unlocked).toList();

    return ProfileCustomizationState(
      activeTitleId: defaultTitle.id,
      showcaseAchievementIds: [
        if (unlocked.isNotEmpty) unlocked[0].id else null,
        if (unlocked.length > 1) unlocked[1].id else null,
        if (unlocked.length > 2) unlocked[2].id else null,
      ],
    );
  }

  void equipTitle(String titleId) {
    state = state.copyWith(activeTitleId: titleId);
  }

  void setShowcaseAchievement(int slotIndex, String? achievementId) {
    if (slotIndex < 0 || slotIndex >= state.showcaseAchievementIds.length) return;
    final updated = [...state.showcaseAchievementIds];
    updated[slotIndex] = achievementId;
    state = state.copyWith(showcaseAchievementIds: updated);
  }
}

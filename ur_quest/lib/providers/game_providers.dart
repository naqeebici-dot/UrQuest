import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/mission_model.dart';
import '../services/api_service.dart';

// ── ID del usuario activo (cámbialo al implementar auth) ──
const String kActiveUserId = 'mock-001';

// ─────────────────────────────────────────────────────────
// USER PROVIDER
// ─────────────────────────────────────────────────────────

final userProvider =
    AsyncNotifierProvider<UserNotifier, UserModel>(UserNotifier.new);

class UserNotifier extends AsyncNotifier<UserModel> {
  @override
  Future<UserModel> build() async {
    try {
      return await ApiService.instance.getUser(kActiveUserId);
    } catch (_) {
      return UserModel.mock();
    }
  }

  void addGrit(int amount) {
    state.whenData((u) {
      state = AsyncData(_copyWith(u, gritBalance: u.gritBalance + amount));
    });
  }

  void addXp(int xp) {
    state.whenData((u) {
      final newXp = u.xpTotal + xp;
      state = AsyncData(_copyWith(u, xpTotal: newXp, level: _calcLevel(newXp)));
    });
  }

  void updateHp(int hp) {
    state.whenData((u) {
      state = AsyncData(_copyWith(u, hp: hp.clamp(0, u.maxHp)));
    });
  }

  int _calcLevel(int xp) {
    final l = (xp / 100.0).toInt();
    return l > 0 ? l.clamp(1, 999) : 1;
  }

  UserModel _copyWith(UserModel u, {
    int? gritBalance, int? xpTotal, int? level,
    int? hp, int? currentStreak, int? corruptionScore,
  }) =>
      UserModel(
        id: u.id, username: u.username,
        level:           level           ?? u.level,
        hp:              hp              ?? u.hp,
        maxHp:           u.maxHp,
        gritBalance:     gritBalance     ?? u.gritBalance,
        xpTotal:         xpTotal         ?? u.xpTotal,
        corruptionScore: corruptionScore ?? u.corruptionScore,
        currentStreak:   currentStreak   ?? u.currentStreak,
        attributes:      u.attributes,
      );
}

// ─────────────────────────────────────────────────────────
// MISSIONS PROVIDER
// ─────────────────────────────────────────────────────────

final dailyMissionsProvider =
    AsyncNotifierProvider<MissionsNotifier, List<MissionModel>>(
        MissionsNotifier.new);

class MissionsNotifier extends AsyncNotifier<List<MissionModel>> {
  @override
  Future<List<MissionModel>> build() async {
    try {
      return await ApiService.instance.getDailyMissions(kActiveUserId);
    } catch (_) {
      return MissionModel.mockDailyQuests();
    }
  }

  Future<void> completeMission(String missionId, {int elapsedSeconds = 0}) async {
    // Actualización optimista
    state.whenData((list) {
      state = AsyncData([
        for (final m in list)
          if (m.id == missionId)
            MissionModel(
              id: m.id, title: m.title, description: m.description,
              rank: m.rank, type: m.type, gritReward: m.gritReward,
              xpReward: m.xpReward, attribute: m.attribute,
              minDurationMin: m.minDurationMin, status: MissionStatus.completed,
            )
          else m,
      ]);
    });
    // Llamada al backend (falla silenciosa en offline)
    try {
      await ApiService.instance.completeMission(
        userId: kActiveUserId,
        missionId: missionId,
        elapsedSeconds: elapsedSeconds,
      );
    } catch (_) {}
  }
}

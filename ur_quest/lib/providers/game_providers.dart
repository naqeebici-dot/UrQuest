import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/mission_model.dart';
import '../models/reward_model.dart';
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

  void addAura(int amount) {
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

  /// Suma [amount] puntos al atributo [attributeKey] (ej. 'VIT', 'INT'…)
  /// forzando el redibujado del HexRadarChart en tiempo real.
  void addAttribute(String attributeKey, {int amount = 5}) {
    state.whenData((u) {
      final updated = Map<String, int>.from(u.attributes);
      if (updated.containsKey(attributeKey)) {
        updated[attributeKey] = (updated[attributeKey]! + amount).clamp(0, 100);
      }
      state = AsyncData(_copyWith(u, attributes: updated));
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
    Map<String, int>? attributes,
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
        attributes:      attributes      ?? u.attributes,
      );
}

// ─────────────────────────────────────────────────────────
// REWARDS PROVIDER
// ─────────────────────────────────────────────────────────

final rewardsProvider =
    AsyncNotifierProvider<RewardsNotifier, List<RewardModel>>(
        RewardsNotifier.new);

class RewardsNotifier extends AsyncNotifier<List<RewardModel>> {
  @override
  Future<List<RewardModel>> build() async {
    try {
      return await ApiService.instance.getRewards();
    } catch (_) {
      return RewardModel.mockRewards();
    }
  }

  /// Compra una recompensa: actualización optimista + llamada al backend.
  /// Descuenta [cost] del saldo AURA del usuario y marca la recompensa
  /// como comprada. Si el tier es GOLD sube el corruptionScore.
  Future<void> buyReward(RewardModel reward) async {
    // Actualización optimista
    state.whenData((list) {
      state = AsyncData([
        for (final r in list)
          if (r.id == reward.id) r.copyWith(isPurchased: true) else r,
      ]);
    });

    // Descuenta AURA del usuario
    ref.read(userProvider.notifier).addAura(-reward.currentCost);

    // Fallo silencioso en modo offline
    try {
      await ApiService.instance.buyReward(
        userId: kActiveUserId,
        rewardId: reward.id,
      );
    } catch (_) {}
  }

  Future<RewardModel> createReward(RewardModel reward) async {
    final current = state.valueOrNull ?? const <RewardModel>[];
    state = AsyncData([...current, reward]);

    try {
      final created = await ApiService.instance.createReward(
        userId: kActiveUserId,
        reward: reward,
      );
      final latest = state.valueOrNull ?? const <RewardModel>[];
      state = AsyncData([
        for (final r in latest)
          if (r.id == reward.id) created else r,
      ]);
      return created;
    } catch (_) {
      // El item ya se insertó de forma optimista; lo conservamos si la API falla.
      return reward;
    }
  }
}

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
    // Actualización optimista: marcar misión como completada y actualizar atributo
    state.whenData((list) {
      final mission = list.firstWhere(
        (m) => m.id == missionId,
        orElse: () => list.first,
      );
      state = AsyncData([
        for (final m in list)
          if (m.id == missionId)
            m.copyWith(status: MissionStatus.completed)
          else m,
      ]);

      // Actualiza el atributo específico en el UserModel → redibuja HexRadarChart
      if (mission.id == missionId) {
        ref.read(userProvider.notifier).addAttribute(mission.attribute, amount: 5);
      }
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

  Future<MissionModel> createMission(MissionModel mission) async {
    final current = state.valueOrNull ?? const <MissionModel>[];
    state = AsyncData([...current, mission]);

    try {
      final created = await ApiService.instance.createMission(
        userId: kActiveUserId,
        mission: mission,
      );
      final latest = state.valueOrNull ?? const <MissionModel>[];
      state = AsyncData([
        for (final m in latest)
          if (m.id == mission.id) created else m,
      ]);
      return created;
    } catch (_) {
      // La misión ya se insertó localmente para refresco inmediato.
      return mission;
    }
  }
}

// ─────────────────────────────────────────────────────────
// UGC PROVIDERS — Misiones y Rewards personalizadas (in-memory)
// ─────────────────────────────────────────────────────────

final customMissionsProvider =
    NotifierProvider<CustomMissionsNotifier, List<MissionModel>>(CustomMissionsNotifier.new);

class CustomMissionsNotifier extends Notifier<List<MissionModel>> {
  @override
  List<MissionModel> build() => [];

  void add(MissionModel m) => state = [...state, m];

  void remove(String id) => state = state.where((m) => m.id != id).toList();

  void complete(String id) {
    state = [
      for (final m in state)
        if (m.id == id)
          m.copyWith(status: MissionStatus.completed)
        else m,
    ];
  }
}

final customRewardsProvider =
    NotifierProvider<CustomRewardsNotifier, List<RewardModel>>(CustomRewardsNotifier.new);

class CustomRewardsNotifier extends Notifier<List<RewardModel>> {
  @override
  List<RewardModel> build() => [];

  void add(RewardModel r) => state = [...state, r];

  void remove(String id) => state = state.where((r) => r.id != id).toList();

  void purchase(String id) {
    state = [
      for (final r in state)
        if (r.id == id) r.copyWith(isPurchased: true) else r,
    ];
  }
}

// ─────────────────────────────────────────────────────────
// PROVIDERS COMBINADOS — Mocks + Custom UGC
// ─────────────────────────────────────────────────────────

/// Todas las misiones: mock/API + personalizadas
final allMissionsProvider = Provider<List<MissionModel>>((ref) {
  final daily  = ref.watch(dailyMissionsProvider).valueOrNull ?? [];
  final custom = ref.watch(customMissionsProvider);
  return [...daily, ...custom];
});

/// Todas las recompensas: mock/API + personalizadas
final allRewardsProvider = Provider<List<RewardModel>>((ref) {
  final rewards = ref.watch(rewardsProvider).valueOrNull ?? [];
  final custom  = ref.watch(customRewardsProvider);
  return [...rewards, ...custom];
});


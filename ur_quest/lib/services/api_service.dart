import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../models/mission_model.dart';

/// ──────────────────────────────────────────────────────────
/// URL base del backend.
/// • Emulador Android  → http://10.0.2.2:3000
/// • Web / dispositivo físico en red local → cambia _localIp
/// ──────────────────────────────────────────────────────────
const String _localIp = '127.0.0.1';      // ← cambia esto si usas dispositivo físico
const String _baseUrl = 'http://$_localIp:3000';

class ApiService {
  ApiService._()
      : _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
          headers: {'Content-Type': 'application/json'},
        ));

  static final ApiService instance = ApiService._();
  final Dio _dio;

  // ── Usuarios ──────────────────────────────────────────────

  /// Crea un usuario nuevo.  Devuelve el [UserModel] creado.
  Future<UserModel> createUser({
    required String username,
    required String email,
    required String password,
  }) async {
    final res = await _dio.post('/users', data: {
      'username': username,
      'email': email,
      'password': password,
    });
    return _userFromJson(res.data as Map<String, dynamic>);
  }

  /// Obtiene el usuario identificado por [userId].
  Future<UserModel> getUser(String userId) async {
    final res = await _dio.get('/users/$userId');
    return _userFromJson(res.data as Map<String, dynamic>);
  }

  // ── Misiones ──────────────────────────────────────────────

  /// Devuelve las misiones diarias disponibles para [userId].
  Future<List<MissionModel>> getDailyMissions(String userId) async {
    final res = await _dio.get('/missions/daily', queryParameters: {'userId': userId});
    final list = res.data as List<dynamic>;
    return list.map((j) => _missionFromJson(j as Map<String, dynamic>)).toList();
  }

  /// Marca una misión como completada.
  Future<void> completeMission({
    required String userId,
    required String missionId,
    required int elapsedSeconds,
  }) async {
    await _dio.post('/missions/$missionId/complete', data: {
      'userId': userId,
      'elapsedSeconds': elapsedSeconds,
    });
  }

  // ── Recompensas ───────────────────────────────────────────

  /// Compra una recompensa del mercado.
  Future<void> buyReward({
    required String userId,
    required String rewardId,
  }) async {
    await _dio.post('/rewards/$rewardId/buy', data: {'userId': userId});
  }

  // ── Parsers ───────────────────────────────────────────────

  UserModel _userFromJson(Map<String, dynamic> j) {
    final rawAttrs = j['attributes'] as Map<String, dynamic>? ?? {};
    return UserModel(
      id:              j['id']?.toString()            ?? '',
      username:        j['username']?.toString()       ?? '',
      level:           (j['level']           as num?)?.toInt() ?? 1,
      hp:              (j['hp']              as num?)?.toInt() ?? 100,
      maxHp:           (j['maxHp']           as num?)?.toInt() ?? 100,
      gritBalance:     (j['gritBalance']     as num?)?.toInt() ?? 0,
      xpTotal:         (j['xpTotal']         as num?)?.toInt() ?? 0,
      corruptionScore: (j['corruptionScore'] as num?)?.toInt() ?? 0,
      currentStreak:   (j['currentStreak']   as num?)?.toInt() ?? 0,
      attributes:      rawAttrs.map((k, v) => MapEntry(k, (v as num).toInt())),
    );
  }

  MissionModel _missionFromJson(Map<String, dynamic> j) {
    return MissionModel(
      id:             j['id']?.toString()          ?? '',
      title:          j['title']?.toString()        ?? '',
      description:    j['description']?.toString()  ?? '',
      rank:           _parseRank(j['rank']?.toString()),
      type:           _parseType(j['type']?.toString()),
      gritReward:     (j['gritReward']  as num?)?.toInt() ?? 0,
      xpReward:       (j['xpReward']    as num?)?.toInt() ?? 0,
      attribute:      j['attribute']?.toString()    ?? 'INT',
      minDurationMin: (j['minDurationMin'] as num?)?.toInt() ?? 0,
      status:         _parseStatus(j['status']?.toString()),
    );
  }

  MissionRank   _parseRank(String? s)   => MissionRank.values.firstWhere(
        (e) => e.name == s, orElse: () => MissionRank.C);
  MissionType   _parseType(String? s)   => MissionType.values.firstWhere(
        (e) => e.name == s, orElse: () => MissionType.daily);
  MissionStatus _parseStatus(String? s) => MissionStatus.values.firstWhere(
        (e) => e.name == s, orElse: () => MissionStatus.pending);
}


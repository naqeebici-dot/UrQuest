import 'package:flutter_test/flutter_test.dart';
import 'package:ur_quest/models/reward_model.dart';
import 'package:ur_quest/services/regex_dictionary_service.dart';

void main() {
  group('SystemParserService misiones', () {
    test('clasifica VIT y suma bonus numérico con multiplicador 1.5', () {
      final result = SystemParserService.evaluate(
        'Correr 10 km',
        mode: EntryMode.mission,
      );

      expect(result.detectedAttribute, 'VIT');
      // Base VIT = 60, bonus = 10 * 1.5 = 15, total = 75
      expect(result.suggestedReward, 75);
    });

    test('clasifica ESP sin bonus numérico (sin unidad detectada)', () {
      final result = SystemParserService.evaluate(
        'Meditar 5 minutos',
        mode: EntryMode.mission,
      );

      expect(result.detectedAttribute, 'ESP');
      // Base ESP = 40, bonus = 5 * 1.5 = 7.5, total = 47.5 -> 48
      expect(result.suggestedReward, 48);
    });

    test('clasifica VIT con flexiones', () {
      final result = SystemParserService.evaluate(
        '20 flexiones',
        mode: EntryMode.mission,
      );

      expect(result.detectedAttribute, 'VIT');
      // Base VIT = 60, bonus = 20 * 1.5 = 30, total = 90
      expect(result.suggestedReward, 90);
    });

    test('clasifica LOG con programar', () {
      final result = SystemParserService.evaluate(
        'Programar 2 horas',
        mode: EntryMode.mission,
      );

      expect(result.detectedAttribute, 'LOG');
      // Base LOG = 60, bonus = 2 * 1.5 = 3, total = 63
      expect(result.suggestedReward, 63);
    });

    test('detecta nuevas palabras del diccionario expandido', () {
      final vitResult = SystemParserService.evaluate('burpees', mode: EntryMode.mission);
      expect(vitResult.detectedAttribute, 'VIT');

      final intResult = SystemParserService.evaluate('documental', mode: EntryMode.mission);
      expect(intResult.detectedAttribute, 'INT');

      final logResult = SystemParserService.evaluate('sudoku', mode: EntryMode.mission);
      expect(logResult.detectedAttribute, 'LOG');

      final espResult = SystemParserService.evaluate('mindfulness', mode: EntryMode.mission);
      expect(espResult.detectedAttribute, 'ESP');

      final creaResult = SystemParserService.evaluate('piano', mode: EntryMode.mission);
      expect(creaResult.detectedAttribute, 'CREA');

      final socResult = SystemParserService.evaluate('socializar', mode: EntryMode.mission);
      expect(socResult.detectedAttribute, 'SOC');
    });

    test('detecta hábitos evitados como ESP con base alta', () {
      final result = SystemParserService.evaluate(
        'No fumar 3 dias',
        mode: EntryMode.mission,
      );

      expect(result.detectedAttribute, 'ESP');
      expect(result.suggestedEmoji, '🛡️');
      expect(result.suggestedReward, 85);
    });

    test('detecta tareas domésticas como rutina y orden', () {
      final result = SystemParserService.evaluate(
        'Limpiar habitacion',
        mode: EntryMode.mission,
      );

      expect(result.detectedAttribute, 'LOG');
      expect(result.suggestedEmoji, '🧹');
      expect(result.suggestedReward, 40);
    });

    test('detecta aprender una habilidad nueva como INT', () {
      final result = SystemParserService.evaluate(
        'Aprender una habilidad nueva',
        mode: EntryMode.mission,
      );

      expect(result.detectedAttribute, 'INT');
      expect(result.suggestedEmoji, '📚');
      expect(result.suggestedReward, 50);
    });

    test('detecta aprender una habilidad nueva con duración y suma bonus', () {
      final result = SystemParserService.evaluate(
        'Aprender una habilidad nueva 30 minutos',
        mode: EntryMode.mission,
      );

      expect(result.detectedAttribute, 'INT');
      // Base INT = 50, bonus = 30 * 1.5 = 45, total = 95
      expect(result.suggestedReward, 95);
    });
  });

  group('SystemParserService recompensas', () {
    test('clasifica weed como moderado', () {
      final result = SystemParserService.evaluate(
        '3 canutos',
        mode: EntryMode.reward,
      );

      expect(result.detectedTier, RewardTier.BRONZE);
      // Base moderado = 150, multiplicador = 1 + (3 * 0.2) = 1.6, total = 240
      expect(result.suggestedCost, 240);
      expect(result.suggestedEmoji, '🍺');
    });

    test('clasifica Tier C (BRONZE) para Netflix y calcula coste por horas', () {
      final result = SystemParserService.evaluate(
        'Netflix 4 horas',
        mode: EntryMode.reward,
      );

      expect(result.detectedTier, RewardTier.BRONZE);
      // Base Tier C = 50, multiplicador = 1 + (4 * 0.2) = 1.8, total = 90
      expect(result.suggestedCost, 90);
      expect(result.suggestedEmoji, '📱');
    });

    test('clasifica alcohol como peligroso', () {
      final result = SystemParserService.evaluate(
        '2 cervezas',
        mode: EntryMode.reward,
      );

      expect(result.detectedTier, RewardTier.BRONZE);
      expect(result.suggestedCost, 210);
      expect(result.suggestedEmoji, '🍺');
    });

    test('clasifica cheat meal como exceso', () {
      final result = SystemParserService.evaluate(
        'comer pizza',
        mode: EntryMode.reward,
      );

      expect(result.detectedTier, RewardTier.SILVER);
      expect(result.suggestedCost, 300);
      expect(result.suggestedEmoji, '🍔');
    });

    test('clasifica Tier crítico para fiesta', () {
      final result = SystemParserService.evaluate(
        'fiesta',
        mode: EntryMode.reward,
      );

      expect(result.detectedTier, RewardTier.GOLD);
      expect(result.suggestedCost, 800);
      expect(result.suggestedEmoji, '🪩');
    });

    test('clasifica videojuegos como exceso con multiplicador', () {
      final result = SystemParserService.evaluate(
        'valorant 5 partidas',
        mode: EntryMode.reward,
      );

      expect(result.detectedTier, RewardTier.SILVER);
      expect(result.suggestedCost, 600);
      expect(result.suggestedEmoji, '🎮');
    });

    test('clasifica tabaco como leve con multiplicador y emoji independiente', () {
      final result = SystemParserService.evaluate(
        '2 cigarros',
        mode: EntryMode.reward,
      );

      expect(result.detectedTier, RewardTier.BRONZE);
      expect(result.suggestedCost, 70);
      expect(result.suggestedEmoji, '🚬');
    });

    test('clasifica marihuana como weed moderado', () {
      final result = SystemParserService.evaluate(
        'marihuana',
        mode: EntryMode.reward,
      );

      expect(result.detectedTier, RewardTier.BRONZE);
      expect(result.suggestedCost, 150);
      expect(result.suggestedEmoji, '🍺');
    });

    test('clasifica vapear como tabaco leve', () {
      final result = SystemParserService.evaluate(
        'vapear 2 horas',
        mode: EntryMode.reward,
      );

      expect(result.detectedTier, RewardTier.BRONZE);
      expect(result.suggestedCost, 70);
      expect(result.suggestedEmoji, '🚬');
    });

    test('clasifica procrastinar como leve', () {
      final result = SystemParserService.evaluate(
        'procrastinar 2 horas',
        mode: EntryMode.reward,
      );

      expect(result.detectedTier, RewardTier.BRONZE);
      expect(result.suggestedCost, 70);
      expect(result.suggestedEmoji, '📱');
    });

    test('emojis específicos para diferentes vicios', () {
      expect(
        SystemParserService.evaluate('casino', mode: EntryMode.reward).suggestedEmoji,
        '🪩',
      );
      expect(
        SystemParserService.evaluate('mcdonalds', mode: EntryMode.reward).suggestedEmoji,
        '🍔',
      );
      expect(
        SystemParserService.evaluate('tiktok', mode: EntryMode.reward).suggestedEmoji,
        '📱',
      );
      expect(
        SystemParserService.evaluate('helado', mode: EntryMode.reward).suggestedEmoji,
        '🍦',
      );
    });
  });
}

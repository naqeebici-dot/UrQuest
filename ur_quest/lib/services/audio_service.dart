import 'package:audioplayers/audioplayers.dart';

/// Servicio de audio para efectos de sonido del juego.
/// Uso: await AudioService.instance.playSuccess();
class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  final AudioPlayer _player = AudioPlayer();

  /// Reproduce el sonido de misión completada.
  /// Asegúrate de tener el archivo en assets/sounds/success.mp3
  Future<void> playSuccess() async {
    try {
      await _player.play(AssetSource('sounds/success.mp3'));
    } catch (e) {
      // Si el archivo no existe o falla, no interrumpe el flujo
      // ignore: avoid_print
      print('[AudioService] No se pudo reproducir success.mp3: $e');
    }
  }

  /// Libera recursos cuando ya no se necesite (opcional, llamar en dispose).
  Future<void> dispose() async {
    await _player.dispose();
  }
}


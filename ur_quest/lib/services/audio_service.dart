import 'package:audioplayers/audioplayers.dart';

/// Servicio de audio para efectos de sonido del juego.
/// Uso: await AudioService.instance.init(); (llamar en main antes de runApp)
///      await AudioService.instance.playSuccess();
class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  final AudioPlayer _player = AudioPlayer();
  final AudioCache _cache = AudioCache(prefix: '');

  /// Pre-carga el archivo de audio en memoria para eliminar latencia
  /// en la primera reproducción. Debe llamarse en main() antes de runApp().
  Future<void> init() async {
    try {
      await _cache.load('assets/sounds/success.mp3');
    } catch (e) {
      // ignore: avoid_print
      print('[AudioService] No se pudo pre-cargar success.mp3: $e');
    }
  }

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


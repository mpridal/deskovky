/// What AudioService needs from the platform: two music channels (for
/// cross-fading) and a pool of effect slots. Implemented with just_audio in
/// the app and faked in tests.
abstract class AudioBackend {
  Future<void> loadMusic(int channel, String asset);

  Future<void> playMusic(int channel);

  Future<void> pauseMusic(int channel);

  Future<void> stopMusic(int channel);

  Future<void> setMusicVolume(int channel, double volume);

  Future<void> playSfx(int slot, String asset, double volume);

  Future<void> dispose();
}

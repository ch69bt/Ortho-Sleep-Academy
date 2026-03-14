import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _keyWakeHour = 'wake_hour';
  static const _keyWakeMinute = 'wake_minute';
  static const _keySleepHour = 'sleep_hour';
  static const _keySleepMinute = 'sleep_minute';
  static const _keyNotificationsEnabled = 'notifications_enabled';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  static Future<SettingsService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsService(prefs);
  }

  // 起床時刻
  int get wakeHour => _prefs.getInt(_keyWakeHour) ?? 7;
  int get wakeMinute => _prefs.getInt(_keyWakeMinute) ?? 0;

  Future<void> setWakeTime(int hour, int minute) async {
    await _prefs.setInt(_keyWakeHour, hour);
    await _prefs.setInt(_keyWakeMinute, minute);
  }

  // 就寝時刻
  int get sleepHour => _prefs.getInt(_keySleepHour) ?? 23;
  int get sleepMinute => _prefs.getInt(_keySleepMinute) ?? 0;

  Future<void> setSleepTime(int hour, int minute) async {
    await _prefs.setInt(_keySleepHour, hour);
    await _prefs.setInt(_keySleepMinute, minute);
  }

  // 通知ON/OFF
  bool get notificationsEnabled =>
      _prefs.getBool(_keyNotificationsEnabled) ?? false;

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_keyNotificationsEnabled, enabled);
  }
}

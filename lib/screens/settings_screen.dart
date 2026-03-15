import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/settings_service.dart';
import '../services/notification_service.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SettingsService _settings;
  late NotificationService _notificationService;
  bool _initialized = false;

  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _sleepTime = const TimeOfDay(hour: 23, minute: 0);
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService();
    _load();
  }

  Future<void> _load() async {
    _settings = await SettingsService.create();
    await _notificationService.initialize();
    if (mounted) {
      setState(() {
        _wakeTime = TimeOfDay(
          hour: _settings.wakeHour,
          minute: _settings.wakeMinute,
        );
        _sleepTime = TimeOfDay(
          hour: _settings.sleepHour,
          minute: _settings.sleepMinute,
        );
        _notificationsEnabled = _settings.notificationsEnabled;
        _initialized = true;
      });
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    if (value) {
      final granted = await _notificationService.requestPermission();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('通知の許可が必要です。設定から許可してください。')),
          );
        }
        return;
      }
      await _scheduleAll();
    } else {
      await _notificationService.cancelAll();
    }
    await _settings.setNotificationsEnabled(value);
    if (mounted) setState(() => _notificationsEnabled = value);
  }

  Future<void> _scheduleAll() async {
    await _notificationService.scheduleWakeNotification(
      _wakeTime.hour,
      _wakeTime.minute,
    );
    await _notificationService.scheduleSleepNotification(
      _sleepTime.hour,
      _sleepTime.minute,
    );
  }

  Future<void> _pickWakeTime() async {
    if (!_notificationsEnabled) return;
    final picked = await showTimePicker(
      context: context,
      initialTime: _wakeTime,
      helpText: '起床時刻を設定',
    );
    if (picked != null) {
      await _settings.setWakeTime(picked.hour, picked.minute);
      setState(() => _wakeTime = picked);
      if (_notificationsEnabled) {
        await _notificationService.scheduleWakeNotification(
          picked.hour,
          picked.minute,
        );
      }
    }
  }

  Future<void> _pickSleepTime() async {
    if (!_notificationsEnabled) return;
    final picked = await showTimePicker(
      context: context,
      initialTime: _sleepTime,
      helpText: '就寝時刻を設定',
    );
    if (picked != null) {
      await _settings.setSleepTime(picked.hour, picked.minute);
      setState(() => _sleepTime = picked);
      if (_notificationsEnabled) {
        await _notificationService.scheduleSleepNotification(
          picked.hour,
          picked.minute,
        );
      }
    }
  }

  Future<void> _sendFeedback() async {
    final Uri uri;
    if (Platform.isIOS) {
      // TODO: App Store Connect で確認した数字IDに差し替える
      const appStoreId = '6760588609';
      uri = Uri.parse(
        'https://apps.apple.com/app/id$appStoreId?action=write-review',
      );
    } else {
      const packageId = 'com.ortholutxmeter.orthoLuxmeter';
      uri = Uri.parse(
        'https://play.google.com/store/apps/details?id=$packageId&showAllReviews=true',
      );
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ストアを開けませんでした')),
        );
      }
    }
  }

  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('設定', style: AppTextStyles.appBarTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          // 通知セクション
          _sectionHeader('通知'),
          SwitchListTile(
            title: const Text('通知を受け取る'),
            value: _notificationsEnabled,
            onChanged: _toggleNotifications,
          ),
          ListTile(
            title: const Text('起床時刻'),
            trailing: Text(
              _formatTime(_wakeTime),
              style: TextStyle(
                color: _notificationsEnabled
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
            enabled: _notificationsEnabled,
            onTap: _pickWakeTime,
          ),
          ListTile(
            title: const Text('就寝時刻'),
            trailing: Text(
              _formatTime(_sleepTime),
              style: TextStyle(
                color: _notificationsEnabled
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
            enabled: _notificationsEnabled,
            onTap: _pickSleepTime,
          ),
          const Divider(),

          // サポートセクション
          _sectionHeader('サポート'),
          ListTile(
            title: const Text('フィードバックを送る'),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
            onTap: _sendFeedback,
          ),
          const Divider(),

          // アプリ情報セクション
          _sectionHeader('アプリ情報'),
          const ListTile(
            title: Text('バージョン'),
            trailing: Text(
              '1.0.0',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

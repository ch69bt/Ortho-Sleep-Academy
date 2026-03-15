class LuxThresholds {
  LuxThresholds._();

  /// 朝の推奨最低照度（lux）
  static const double morningMin = 2500;

  /// 夜の推奨最大照度（lux）
  static const double nightMax = 50;

  /// 測定上限値（lux）
  static const double maxLux = 300000;

  /// 最低値（lux）
  static const double minLux = 0;
}

class TimePeriodBoundary {
  TimePeriodBoundary._();

  /// 朝の終了時刻（12:00）
  static const int morningEndHour = 12;

  /// 昼の終了時刻（18:00）
  static const int afternoonEndHour = 18;
}

enum TimePeriod { morning, afternoon, night }

class LuxAdvice {
  LuxAdvice._();

  // 時間帯別 静的アドバイステキスト
  static const String morningAdvice =
      '起床後は明るい光を浴びて体内時計をリセットしましょう';
  static const String afternoonAdvice =
      '日中は自然光を積極的に取り入れましょう';
  static const String nightAdvice =
      '就寝前は光を抑えてメラトニンの分泌を止めないようにしましょう';

  // フィードバックテキスト
  static const String morningGood = '十分な光を浴びています';
  static const String morningBad = 'もう少し明るい場所へ移動しましょう';
  static const String afternoonNeutral = '現在の照度を確認してください';
  static const String nightGood = '良い光環境です';
  static const String nightBad = '光を抑えて寝る準備をしましょう';

  // 基準値ラベル
  static const String morningThresholdLabel = '基準値：2,500 lux 以上';
  static const String afternoonThresholdLabel = '基準値：なし（参考表示）';
  static const String nightThresholdLabel = '基準値：50 lux 以下';
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants/colors.dart';
import 'screens/main_screen.dart';

class OrthoSleepAcademyApp extends StatelessWidget {
  const OrthoSleepAcademyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ステータスバーのアイコンを白に（暗い背景向け）
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    return MaterialApp(
      title: 'ORTHO SLEEP ACADEMY',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: AppColors.secondary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),
        listTileTheme: const ListTileThemeData(
          textColor: AppColors.textPrimary,
          iconColor: AppColors.textSecondary,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? AppColors.secondary
                  : AppColors.textSecondary),
          trackColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? AppColors.secondary.withValues(alpha: 0.4)
                  : AppColors.surface),
        ),
        dividerColor: AppColors.surface,
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

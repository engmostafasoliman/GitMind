import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppThemeData {
  final ThemeMode mode;
  final String accentId;

  const AppThemeData({required this.mode, required this.accentId});

  bool get isDark => mode == ThemeMode.dark;
}

class ThemeCubit extends Cubit<AppThemeData> {
  ThemeCubit()
      : super(const AppThemeData(mode: ThemeMode.dark, accentId: 'indigo'));

  bool get isDark => state.isDark;

  void toggle() => emit(
        AppThemeData(
          mode: state.isDark ? ThemeMode.light : ThemeMode.dark,
          accentId: state.accentId,
        ),
      );

  void setAccent(String id) =>
      emit(AppThemeData(mode: state.mode, accentId: id));
}

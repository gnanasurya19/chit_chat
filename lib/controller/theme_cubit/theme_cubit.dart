import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeInitial()) {
    loadTheme();
  }
  ThemeMode themeMode = ThemeMode.light;

  loadTheme() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String theme = sp.getString('thememode') ?? '';
    themeMode = theme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    emit(ThemeInitial(themeMode: themeMode));
  }

  changeTheme(BuildContext context) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String theme = sp.getString('thememode') ?? 'light';
    if (theme == 'dark') {
      themeMode = ThemeMode.light;
    } else {
      themeMode = ThemeMode.dark;
    }
    sp.setString('thememode', themeMode == ThemeMode.dark ? 'dark' : 'light');
    emit(ThemeInitial(themeMode: themeMode));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends StateNotifier<ThemeMode>{
  ThemeNotifier():super(ThemeMode.dark){
    _loadSaveTheme();
  }
  static const _prefsKey = 'theme_data';
  Future<void> _loadSaveTheme()async{
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if(saved == 'light'){
      state = ThemeMode.light;
    }else if(saved == 'dark'){
      state = ThemeMode.dark;
    }else{
      state = ThemeMode.system;
    }
  }
    Future<void> setTheme(ThemeMode mode)async{
state = mode;
final prefs = await SharedPreferences.getInstance();
await prefs.setString(_prefsKey , mode.name);
    }
}
  final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref){
    return ThemeNotifier();
  });

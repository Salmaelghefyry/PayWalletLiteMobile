import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

ThemeData buildTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: C.teal,
    primary: C.teal, secondary: C.gold,
    surface: C.surface, onPrimary: Colors.white,
    onSurface: C.ink, error: C.red,
  ),
  scaffoldBackgroundColor: C.surface2,
  appBarTheme: const AppBarTheme(
    backgroundColor: C.surface2, elevation: 0,
    scrolledUnderElevation: 0, centerTitle: false,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark),
    titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: C.navy),
    iconTheme: IconThemeData(color: C.ink2),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(
    backgroundColor: C.teal, foregroundColor: Colors.white, elevation: 0,
    minimumSize: const Size(double.infinity, 54),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
  )),
  outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(
    foregroundColor: C.teal, side: const BorderSide(color: C.teal, width: 1.5),
    minimumSize: const Size(double.infinity, 54),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
  )),
  cardTheme: CardThemeData(color: C.surface, elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: C.border))),
  inputDecorationTheme: InputDecorationTheme(
    filled: true, fillColor: C.surface2,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: C.border)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: C.border)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: C.teal, width: 2)),
    hintStyle: const TextStyle(color: C.ink4, fontSize: 14),
    labelStyle: const TextStyle(color: C.ink3, fontSize: 13),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: C.surface, selectedItemColor: C.teal,
    unselectedItemColor: C.ink3, type: BottomNavigationBarType.fixed, elevation: 0,
    selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
    unselectedLabelStyle: TextStyle(fontSize: 10),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? C.teal : Colors.grey.shade400),
    trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? C.tealLight : Colors.grey.shade200),
  ),
  dividerTheme: const DividerThemeData(color: C.border, thickness: 1, space: 0),
);

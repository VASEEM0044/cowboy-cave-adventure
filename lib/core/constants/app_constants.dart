import 'package:flutter/material.dart';

/// Central application constants for Cowboy Cave Adventure.
abstract final class AppConstants {
  // Application Identity
  static const String appTitle = 'Cowboy Cave Adventure';
  static const String bundleIdentifier = 'com.vntm.cowboycavead';
  static const String version = '1.0.0';

  // Game Engine & Virtual Resolution Settings (LDtk 256x256 single-screen grid)
  static const double virtualWidth = 256.0;
  static const double virtualHeight = 256.0;

  // Typography
  static const String fontFamily = 'PixelOperator8';

  // Total playable levels designed for the arcade campaign
  static const int totalLevels = 5;

  // Retro Arcade Palette
  static const Color colorBackground = Color(0xFF10121A);
  static const Color colorSurface = Color(0xFF1E2130);
  static const Color colorSurfaceLight = Color(0xFF2C324A);
  static const Color colorPrimary = Color(0xFFFFB800);
  static const Color colorPrimaryDark = Color(0xFFC78C00);
  static const Color colorSecondary = Color(0xFF00E5FF);
  static const Color colorAccent = Color(0xFFFF4081);
  static const Color colorTextPrimary = Color(0xFFF4F4F6);
  static const Color colorTextMuted = Color(0xFF8A92A6);
  static const Color colorLocked = Color(0xFF42475B);
  static const Color colorBorder = Color(0xFF3F4865);
  static const Color colorSuccess = Color(0xFF00E676);
}

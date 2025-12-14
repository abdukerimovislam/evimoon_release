import 'package:flutter/material.dart';

class Responsive {
  // Получить ширину экрана
  static double width(BuildContext context) => MediaQuery.of(context).size.width;

  // Получить высоту экрана
  static double height(BuildContext context) => MediaQuery.of(context).size.height;

  // Проверка: это маленький телефон? (iPhone SE, старые Android)
  static bool isSmallScreen(BuildContext context) => width(context) < 380;

  // Динамический размер шрифта (чуть меньше на маленьких экранах)
  static double fontSize(BuildContext context, double size) {
    return isSmallScreen(context) ? size * 0.85 : size;
  }
}
import 'package:flutter/material.dart';

/// Tokens visuais compartilhados pelos componentes do dashboard.
/// Mantém o gradiente e os cantos iguais aos do resto do app.
const dashboardGradientColors = [Colors.pinkAccent, Colors.purpleAccent];

const dashboardGradient = LinearGradient(colors: dashboardGradientColors);

/// Percentual sem casas decimais, como '68%'.
String formatPercent(double percent) => '${percent.round()}%';

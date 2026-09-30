import 'package:flutter/material.dart';
import 'routes.dart';
import 'theme.dart';

class ZedAlkhairApp extends StatelessWidget {
  const ZedAlkhairApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'زاد الخير',

      theme: AppTheme.lightTheme,

      initialRoute: AppRoutes.login,

      routes: AppRoutes.routes,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_provider.dart';
import 'features/transactions/transaction_provider.dart';
import 'features/budget/budget_provider.dart';
import 'features/goals/goal_provider.dart';
import 'features/insight/insight_provider.dart';
import 'features/splash/splash_screen.dart';

class SaveryApp extends StatelessWidget {
  const SaveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider(create: (_) => GoalProvider()),
        ChangeNotifierProvider(create: (_) => InsightProvider()),
      ],
      child: MaterialApp(
        title: 'Savery',
        theme: AppTheme.light,
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'providers/employee_auth_provider.dart';
import 'providers/attendance_provider.dart';
import 'screens/employee_login_screen.dart';
import 'screens/employee_dashboard_screen.dart';
import 'screens/attendance_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/product_management_screen.dart';

void main() {
  runApp(const ConexaShipInternalApp());
}

class ConexaShipInternalApp extends StatelessWidget {
  const ConexaShipInternalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EmployeeAuthProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            title: 'Conexa Ship - Employee Portal',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1565C0), // Blue for internal
                primary: const Color(0xFF1565C0),
                secondary: const Color(0xFF2196F3),
              ),
              textTheme: GoogleFonts.robotoTextTheme(),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1565C0),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
            routerConfig: _router,
          );
        },
      ),
    );
  }
}

final _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const EmployeeLoginScreen()),
    GoRoute(path: '/', builder: (context, state) => const EmployeeDashboardScreen()),
    GoRoute(path: '/attendance', builder: (context, state) => const AttendanceScreen()),
    GoRoute(path: '/reports', builder: (context, state) => const ReportsScreen()),
    GoRoute(path: '/products', builder: (context, state) => const ProductManagementScreen()),
  ],
);

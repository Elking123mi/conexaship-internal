import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:conexaship_core/conexaship_core.dart';
import '../providers/employee_auth_provider.dart';
import '../providers/attendance_provider.dart';

class EmployeeDashboardScreen extends StatefulWidget {
  const EmployeeDashboardScreen({super.key});

  @override
  State<EmployeeDashboardScreen> createState() => _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<EmployeeAuthProvider>(context, listen: false);
      final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
      
      if (authProvider.currentEmployee != null) {
        attendanceProvider.loadAttendance(authProvider.currentEmployee!.id!);
      }
    });
  }

  String _getInitials(String firstName, String lastName) {
    String initials = '';
    if (firstName.isNotEmpty) {
      initials += firstName[0].toUpperCase();
    }
    if (lastName.isNotEmpty) {
      initials += lastName[0].toUpperCase();
    }
    return initials.isEmpty ? '?' : initials;
  }

  bool _hasRole(Employee employee, String role) {
    return employee.position.toLowerCase().contains(role.toLowerCase());
  }

  List<_ActionItem> _getActionsForRole(Employee employee) {
    List<_ActionItem> actions = [];

    // Actions for ALL employees
    actions.addAll([
      _ActionItem(
        icon: Icons.access_time,
        label: 'My Attendance',
        color: Colors.blue,
        route: '/attendance',
      ),
      _ActionItem(
        icon: Icons.person,
        label: 'My Profile',
        color: Colors.teal,
        route: '/profile',
      ),
    ]);

    // CASHIER actions
    if (_hasRole(employee, 'cashier')) {
      actions.addAll([
        _ActionItem(
          icon: Icons.point_of_sale,
          label: 'Sales',
          color: Colors.green,
          route: '/sales',
        ),
        _ActionItem(
          icon: Icons.receipt_long,
          label: 'Invoices',
          color: Colors.orange,
          route: '/invoices',
        ),
        _ActionItem(
          icon: Icons.payments,
          label: 'Payments',
          color: Colors.purple,
          route: '/payments',
        ),
      ]);
    }

    // MANAGER actions
    if (_hasRole(employee, 'manager')) {
      actions.addAll([
        _ActionItem(
          icon: Icons.people,
          label: 'Team',
          color: Colors.indigo,
          route: '/team',
        ),
        _ActionItem(
          icon: Icons.assessment,
          label: 'Reports',
          color: Colors.purple,
          route: '/reports',
        ),
        _ActionItem(
          icon: Icons.schedule,
          label: 'Schedules',
          color: Colors.cyan,
          route: '/schedules',
        ),
      ]);
    }

    // ADMIN actions
    if (_hasRole(employee, 'admin')) {
      actions.addAll([
        _ActionItem(
          icon: Icons.admin_panel_settings,
          label: 'Admin Panel',
          color: Colors.red,
          route: '/admin',
        ),
        _ActionItem(
          icon: Icons.people_outline,
          label: 'All Employees',
          color: Colors.deepPurple,
          route: '/employees',
        ),
        _ActionItem(
          icon: Icons.settings,
          label: 'Settings',
          color: Colors.blueGrey,
          route: '/settings',
        ),
        _ActionItem(
          icon: Icons.bar_chart,
          label: 'Analytics',
          color: Colors.amber,
          route: '/analytics',
        ),
      ]);
    }

    // DRIVER actions
    if (_hasRole(employee, 'driver')) {
      actions.addAll([
        _ActionItem(
          icon: Icons.local_shipping,
          label: 'My Deliveries',
          color: Colors.brown,
          route: '/deliveries',
        ),
        _ActionItem(
          icon: Icons.map,
          label: 'Routes',
          color: Colors.lightGreen,
          route: '/routes',
        ),
      ]);
    }

    // WAREHOUSE actions
    if (_hasRole(employee, 'warehouse')) {
      actions.addAll([
        _ActionItem(
          icon: Icons.inventory,
          label: 'Inventory',
          color: Colors.deepOrange,
          route: '/inventory',
        ),
        _ActionItem(
          icon: Icons.qr_code_scanner,
          label: 'Scanner',
          color: Colors.teal,
          route: '/scanner',
        ),
      ]);
    }

    // SUPERVISOR actions
    if (_hasRole(employee, 'supervisor')) {
      actions.addAll([
        _ActionItem(
          icon: Icons.checklist,
          label: 'Tasks',
          color: Colors.lightBlue,
          route: '/tasks',
        ),
        _ActionItem(
          icon: Icons.approval,
          label: 'Approvals',
          color: Colors.green,
          route: '/approvals',
        ),
      ]);
    }

    return actions;
  }

  Color _getRoleColor(Employee employee) {
    if (_hasRole(employee, 'admin')) return Colors.red;
    if (_hasRole(employee, 'manager')) return Colors.indigo;
    if (_hasRole(employee, 'supervisor')) return Colors.purple;
    if (_hasRole(employee, 'cashier')) return Colors.green;
    if (_hasRole(employee, 'driver')) return Colors.brown;
    if (_hasRole(employee, 'warehouse')) return Colors.deepOrange;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<EmployeeAuthProvider>(context);
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    final employee = authProvider.currentEmployee;

    if (employee == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await authProvider.logout();
              if (mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => attendanceProvider.loadAttendance(employee.id!),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Employee Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          _getInitials(employee.firstName, employee.lastName),
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              employee.fullName,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              employee.position,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              employee.department,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Code: ${employee.employeeCode}',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),

              // Clock In/Out Section
              Card(
                color: attendanceProvider.isClockedIn
                    ? Colors.green[50]
                    : Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        attendanceProvider.isClockedIn
                            ? Icons.timer
                            : Icons.access_time,
                        size: 48,
                        color: attendanceProvider.isClockedIn
                            ? Colors.green
                            : Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        attendanceProvider.isClockedIn
                            ? 'On Shift'
                            : 'Off Shift',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (attendanceProvider.currentAttendance != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Clock In: ${DateFormat('hh:mm a').format(attendanceProvider.currentAttendance!.clockIn)}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: attendanceProvider.isLoading
                              ? null
                              : () async {
                                  final success = attendanceProvider.isClockedIn
                                      ? await attendanceProvider.clockOut()
                                      : await attendanceProvider.clockIn(employee.id!);
                                  
                                  if (success && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          attendanceProvider.isClockedIn
                                              ? 'Clock In Marked!'
                                              : 'Clock Out Marked!',
                                        ),
                                      ),
                                    );
                                  }
                                },
                          icon: Icon(
                            attendanceProvider.isClockedIn
                                ? Icons.logout
                                : Icons.login,
                          ),
                          label: Text(
                            attendanceProvider.isClockedIn
                                ? 'Clock Out'
                                : 'Clock In',
                            style: const TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: attendanceProvider.isClockedIn
                                ? Colors.orange
                                : Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _QuickActionCard(
                    icon: Icons.access_time,
                    label: 'My Attendance',
                    color: Colors.blue,
                    onTap: () => context.push('/attendance'),
                  ),
                  _QuickActionCard(
                    icon: Icons.assessment,
                    label: 'Reports',
                    color: Colors.purple,
                    onTap: () => context.push('/reports'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
  String _currentTime = '';
  String _currentDate = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    // Update time every second
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        _updateTime();
        return true;
      }
      return false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<EmployeeAuthProvider>(context, listen: false);
      final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);

      if (authProvider.currentEmployee != null) {
        attendanceProvider.loadAttendance(authProvider.currentEmployee!.id!);
      }
    });
  }

  void _updateTime() {
    if (mounted) {
      setState(() {
        final now = DateTime.now();
        _currentTime = DateFormat('hh:mm:ss a').format(now);
        _currentDate = DateFormat('EEEE, MMMM dd, yyyy').format(now);
      });
    }
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
      _ActionItem(icon: Icons.person, label: 'My Profile', color: Colors.teal, route: '/profile'),
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
        _ActionItem(
          icon: Icons.calculate,
          label: 'Calculator',
          color: Colors.blueGrey,
          route: '/calculator',
        ),
      ]);
    }

    // MANAGER actions
    if (_hasRole(employee, 'manager')) {
      actions.addAll([
        _ActionItem(icon: Icons.people, label: 'My Team', color: Colors.indigo, route: '/team'),
        _ActionItem(
          icon: Icons.edit_note,
          label: 'Edit Profiles',
          color: Colors.deepPurple,
          route: '/edit-profiles',
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
        _ActionItem(
          icon: Icons.task_alt,
          label: 'Approvals',
          color: Colors.orange,
          route: '/approvals',
        ),
        _ActionItem(
          icon: Icons.calendar_month,
          label: 'Time Off',
          color: Colors.teal,
          route: '/time-off',
        ),
      ]);
    }

    // ADMIN actions
    if (_hasRole(employee, 'admin')) {
      actions.addAll([
        _ActionItem(
          icon: Icons.inventory,
          label: 'Products',
          color: Colors.deepOrange,
          route: '/products',
        ),
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
        _ActionItem(icon: Icons.map, label: 'Routes', color: Colors.lightGreen, route: '/routes'),
        _ActionItem(
          icon: Icons.navigation,
          label: 'GPS Navigation',
          color: Colors.blue,
          route: '/navigation',
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
        _ActionItem(
          icon: Icons.move_to_inbox,
          label: 'Receive',
          color: Colors.green,
          route: '/receive',
        ),
        _ActionItem(
          icon: Icons.outbox,
          label: 'Dispatch',
          color: Colors.orange,
          route: '/dispatch',
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
        _ActionItem(icon: Icons.group, label: 'Team', color: Colors.indigo, route: '/team'),
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

  IconData _getRoleIcon(Employee employee) {
    if (_hasRole(employee, 'admin')) return Icons.admin_panel_settings;
    if (_hasRole(employee, 'manager')) return Icons.supervisor_account;
    if (_hasRole(employee, 'supervisor')) return Icons.manage_accounts;
    if (_hasRole(employee, 'cashier')) return Icons.point_of_sale;
    if (_hasRole(employee, 'driver')) return Icons.local_shipping;
    if (_hasRole(employee, 'warehouse')) return Icons.warehouse;
    return Icons.work;
  }

  void _handleActionTap(BuildContext context, _ActionItem action, Employee employee) {
    switch (action.label) {
      case 'Products':
        context.go('/products');
        break;
      case 'My Attendance':
        _showAttendanceDialog(context, employee);
        break;
      case 'My Profile':
        _showProfileDialog(context, employee);
        break;
      case 'Edit Profiles':
        _showEditProfilesDialog(context);
        break;
      case 'Sales':
        _showSalesDialog(context);
        break;
      case 'Invoices':
        _showInvoicesDialog(context);
        break;
      case 'Payments':
        _showPaymentsDialog(context);
        break;
      case 'Calculator':
        _showCalculatorDialog(context);
        break;
      case 'My Team':
        _showTeamDialog(context);
        break;
      case 'Reports':
        _showReportsDialog(context);
        break;
      case 'Schedules':
        _showSchedulesDialog(context);
        break;
      case 'All Employees':
        _showEmployeesListDialog(context);
        break;
      case 'Settings':
        _showSettingsDialog(context);
        break;
      case 'Analytics':
        _showAnalyticsDialog(context);
        break;
      case 'Time Off':
        _showTimeOffDialog(context);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.construction, color: Colors.white),
                const SizedBox(width: 8),
                Text('${action.label} - Coming Soon!'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.orange[700],
          ),
        );
    }
  }

  void _showBreakOptions(BuildContext context, Employee employee) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Break Options',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _BreakOption(
              icon: Icons.coffee,
              title: 'Coffee Break',
              subtitle: '15 minutes',
              color: Colors.brown,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Coffee Break started - 15 min'),
                    backgroundColor: Colors.brown,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _BreakOption(
              icon: Icons.restaurant,
              title: 'Lunch Break',
              subtitle: '30-60 minutes',
              color: Colors.orange,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lunch Break started'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _BreakOption(
              icon: Icons.healing,
              title: 'Rest Break',
              subtitle: '10 minutes',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Rest Break started - 10 min'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _BreakOption(
              icon: Icons.stop_circle,
              title: 'End Break',
              subtitle: 'Resume work',
              color: Colors.green,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Break ended - Back to work!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showEditProfilesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit_note, color: Colors.deepPurple),
            const SizedBox(width: 8),
            const Text('Edit Employee Profiles'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: 8,
            itemBuilder: (context, index) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.primaries[index % Colors.primaries.length],
                  child: Text('E${index + 1}', style: const TextStyle(color: Colors.white)),
                ),
                title: Text('Employee ${index + 1}'),
                subtitle: Text(
                  index % 3 == 0
                      ? 'Cashier'
                      : index % 2 == 0
                      ? 'Sales'
                      : 'Warehouse',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditEmployeeDialog(context, index + 1);
                      },
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      icon: const Icon(Icons.schedule, size: 20, color: Colors.blue),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('View schedule for Employee ${index + 1}')),
                        );
                      },
                      tooltip: 'Schedule',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  void _showEditEmployeeDialog(BuildContext context, int employeeNum) {
    final nameController = TextEditingController(text: 'Employee $employeeNum');
    final emailController = TextEditingController(text: 'employee$employeeNum@conexaship.com');
    final positionController = TextEditingController(text: 'Employee');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Employee $employeeNum'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: positionController,
                decoration: const InputDecoration(
                  labelText: 'Position',
                  prefixIcon: Icon(Icons.work),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Department',
                  prefixIcon: Icon(Icons.business),
                  border: OutlineInputBorder(),
                ),
                initialValue: 'Sales',
                items: [
                  'Sales',
                  'Warehouse',
                  'Admin',
                  'Support',
                ].map((dept) => DropdownMenuItem(value: dept, child: Text(dept))).toList(),
                onChanged: (value) {},
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Status',
                  prefixIcon: Icon(Icons.toggle_on),
                  border: OutlineInputBorder(),
                ),
                initialValue: 'Active',
                items: [
                  'Active',
                  'Inactive',
                  'On Leave',
                ].map((status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
                onChanged: (value) {},
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Profile updated successfully!'),
                  backgroundColor: Colors.green,
                  action: SnackBarAction(label: 'View', textColor: Colors.white, onPressed: () {}),
                ),
              );
            },
            icon: const Icon(Icons.save),
            label: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showTimeOffDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.calendar_month, color: Colors.teal),
            const SizedBox(width: 8),
            const Text('Time Off Requests'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange[100],
                  child: Icon(Icons.pending, color: Colors.orange[700]),
                ),
                title: const Text('Vacation Request'),
                subtitle: const Text('Dec 20-25, 2025'),
                trailing: Chip(label: const Text('Pending'), backgroundColor: Colors.orange[100]),
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green[100],
                  child: Icon(Icons.check_circle, color: Colors.green[700]),
                ),
                title: const Text('Sick Leave'),
                subtitle: const Text('Nov 15, 2025'),
                trailing: Chip(label: const Text('Approved'), backgroundColor: Colors.green[100]),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Request time off - Coming Soon!')));
            },
            icon: const Icon(Icons.add),
            label: const Text('New Request'),
          ),
        ],
      ),
    );
  }

  void _showAttendanceDialog(BuildContext context, Employee employee) {
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.access_time, color: Colors.blue),
            const SizedBox(width: 8),
            const Text('My Attendance'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Employee: ${employee.fullName}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Status: ${attendanceProvider.isClockedIn ? "On Shift" : "Off Shift"}'),
            const SizedBox(height: 8),
            Text('Today: ${DateFormat('MMM dd, yyyy').format(DateTime.now())}'),
            const SizedBox(height: 8),
            if (attendanceProvider.currentAttendance != null)
              Text(
                'Clock In: ${DateFormat('hh:mm a').format(attendanceProvider.currentAttendance!.clockIn)}',
              ),
            const SizedBox(height: 16),
            const Text('Recent Activity:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '• Last 7 days: 38.5 hours\n• This month: 152 hours\n• Avg arrival: 8:05 AM',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Full attendance view - Coming Soon!')));
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('View Full'),
          ),
        ],
      ),
    );
  }

  void _showProfileDialog(BuildContext context, Employee employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.person, color: Colors.teal),
            const SizedBox(width: 8),
            const Text('My Profile'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: _getRoleColor(employee),
                  child: Text(
                    _getInitials(employee.firstName, employee.lastName),
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _ProfileItem(label: 'Full Name', value: employee.fullName),
              _ProfileItem(label: 'Email', value: employee.email),
              _ProfileItem(label: 'Position', value: employee.position),
              _ProfileItem(label: 'Department', value: employee.department),
              _ProfileItem(label: 'Employee ID', value: employee.employeeCode),
              _ProfileItem(label: 'Status', value: employee.isActive ? 'Active' : 'Inactive'),
              _ProfileItem(
                label: 'Hire Date',
                value: DateFormat('MMM dd, yyyy').format(employee.hireDate),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Edit profile - Coming Soon!')));
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  void _showSalesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.point_of_sale, color: Colors.green),
            const SizedBox(width: 8),
            const Text('Sales'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Sales',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            _SalesItem(label: 'Total Sales', value: '\$1,250.00', color: Colors.green),
            _SalesItem(label: 'Transactions', value: '18', color: Colors.blue),
            _SalesItem(label: 'Average Ticket', value: '\$69.44', color: Colors.orange),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Opening POS System...')));
              },
              icon: const Icon(Icons.add),
              label: const Text('New Sale'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 45),
              ),
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  void _showInvoicesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.receipt_long, color: Colors.orange),
            const SizedBox(width: 8),
            const Text('Recent Invoices'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: 5,
            itemBuilder: (context, index) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange[100],
                  child: Icon(Icons.receipt, color: Colors.orange[700]),
                ),
                title: Text('Invoice #${1000 + index}'),
                subtitle: Text('Amount: \$${(index + 1) * 125}.00'),
                trailing: Chip(
                  label: Text(index % 2 == 0 ? 'Paid' : 'Pending'),
                  backgroundColor: index % 2 == 0 ? Colors.green[100] : Colors.orange[100],
                ),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Create invoice - Coming Soon!')));
            },
            icon: const Icon(Icons.add),
            label: const Text('New'),
          ),
        ],
      ),
    );
  }

  void _showPaymentsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.payments, color: Colors.purple),
            const SizedBox(width: 8),
            const Text('Payment Methods'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.credit_card, color: Colors.blue),
              title: const Text('Credit/Debit Card'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.money, color: Colors.green),
              title: const Text('Cash'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.account_balance, color: Colors.indigo),
              title: const Text('Bank Transfer'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  void _showCalculatorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.calculate, color: Colors.blueGrey),
            const SizedBox(width: 8),
            const Text('Quick Calculator'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '0.00',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children:
                  ['7', '8', '9', '÷', '4', '5', '6', '×', '1', '2', '3', '-', '0', '.', '=', '+']
                      .map(
                        (e) => ElevatedButton(
                          onPressed: () {},
                          child: Text(e, style: const TextStyle(fontSize: 20)),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  void _showTeamDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.people, color: Colors.indigo),
            const SizedBox(width: 8),
            const Text('My Team'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: 6,
            itemBuilder: (context, index) => Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('E${index + 1}')),
                title: Text('Employee ${index + 1}'),
                subtitle: Text(
                  index % 3 == 0
                      ? 'Cashier'
                      : index % 2 == 0
                      ? 'Sales'
                      : 'Support',
                ),
                trailing: Chip(
                  label: Text(index % 4 == 0 ? 'On Shift' : 'Off'),
                  backgroundColor: index % 4 == 0 ? Colors.green[100] : Colors.grey[300],
                ),
              ),
            ),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  void _showReportsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.assessment, color: Colors.purple),
            const SizedBox(width: 8),
            const Text('Reports'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.bar_chart, color: Colors.blue),
              title: const Text('Sales Report'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.people, color: Colors.green),
              title: const Text('Staff Report'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.inventory, color: Colors.orange),
              title: const Text('Inventory Report'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.trending_up, color: Colors.purple),
              title: const Text('Performance Report'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  void _showSchedulesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.schedule, color: Colors.cyan),
            const SizedBox(width: 8),
            const Text('Schedules'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This Week', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _ScheduleItem(day: 'Monday', time: '8:00 AM - 5:00 PM'),
            _ScheduleItem(day: 'Tuesday', time: '8:00 AM - 5:00 PM'),
            _ScheduleItem(day: 'Wednesday', time: '8:00 AM - 5:00 PM'),
            _ScheduleItem(day: 'Thursday', time: '8:00 AM - 5:00 PM'),
            _ScheduleItem(day: 'Friday', time: '8:00 AM - 5:00 PM'),
            _ScheduleItem(day: 'Saturday', time: 'Off', isOff: true),
            _ScheduleItem(day: 'Sunday', time: 'Off', isOff: true),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  void _showEmployeesListDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.people_outline, color: Colors.deepPurple),
            const SizedBox(width: 8),
            const Text('All Employees'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: 12,
            itemBuilder: (context, index) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.primaries[index % Colors.primaries.length],
                  child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
                ),
                title: Text('Employee ${index + 1}'),
                subtitle: Text('ID: EMP${1000 + index}'),
                trailing: Icon(
                  Icons.circle,
                  size: 12,
                  color: index % 3 == 0 ? Colors.green : Colors.grey,
                ),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Add employee - Coming Soon!')));
            },
            icon: const Icon(Icons.person_add),
            label: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.settings, color: Colors.blueGrey),
            const SizedBox(width: 8),
            const Text('Settings'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Notifications'),
              subtitle: const Text('Receive push notifications'),
              value: true,
              onChanged: (val) {},
            ),
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Use dark theme'),
              value: false,
              onChanged: (val) {},
            ),
            ListTile(
              leading: Icon(Icons.language, color: Colors.blue),
              title: const Text('Language'),
              subtitle: const Text('English'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  void _showAnalyticsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.bar_chart, color: Colors.amber),
            const SizedBox(width: 8),
            const Text('Analytics'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Business Overview', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _AnalyticItem(
              label: 'Total Revenue',
              value: '\$45,230',
              change: '+12%',
              isPositive: true,
            ),
            _AnalyticItem(label: 'Active Users', value: '1,234', change: '+8%', isPositive: true),
            _AnalyticItem(label: 'Orders', value: '456', change: '-3%', isPositive: false),
            _AnalyticItem(
              label: 'Avg. Order Value',
              value: '\$99.12',
              change: '+5%',
              isPositive: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Full analytics - Coming Soon!')));
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('View Full'),
          ),
        ],
      ),
    );
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

    final actions = _getActionsForRole(employee);
    final roleColor = _getRoleColor(employee);
    final roleIcon = _getRoleIcon(employee);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.business, size: 24),
            const SizedBox(width: 8),
            const Text('Employee Portal'),
          ],
        ),
        actions: [
          // Live Clock
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _currentTime,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(_currentDate, style: const TextStyle(fontSize: 10)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifications',
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirm == true && mounted) {
                await authProvider.logout();
                if (mounted) context.go('/login');
              }
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
              // Employee Profile Card - Enhanced
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [roleColor, roleColor.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: roleColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 36,
                          backgroundColor: roleColor,
                          child: Text(
                            _getInitials(employee.firstName, employee.lastName),
                            style: const TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
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
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(roleIcon, color: Colors.white70, size: 16),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    employee.position,
                                    style: const TextStyle(color: Colors.white, fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              employee.department,
                              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'ID: ${employee.employeeCode}',
                              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Clock In/Out Section - Enhanced
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: attendanceProvider.isClockedIn
                          ? [Colors.green[50]!, Colors.green[100]!]
                          : [Colors.blue[50]!, Colors.blue[100]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (attendanceProvider.isClockedIn ? Colors.green : Colors.blue)
                                    .withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            attendanceProvider.isClockedIn ? Icons.timer : Icons.access_time,
                            size: 48,
                            color: attendanceProvider.isClockedIn ? Colors.green : Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          attendanceProvider.isClockedIn
                              ? 'Currently On Shift'
                              : 'Currently Off Shift',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: attendanceProvider.isClockedIn
                                ? Colors.green[800]
                                : Colors.blue[800],
                          ),
                        ),
                        if (attendanceProvider.currentAttendance != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.login, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                'Clock In: ${DateFormat('hh:mm a').format(attendanceProvider.currentAttendance!.clockIn)}',
                                style: TextStyle(color: Colors.grey[700], fontSize: 15),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 20),
                        // Multiple action buttons
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
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
                                              content: Row(
                                                children: [
                                                  Icon(
                                                    attendanceProvider.isClockedIn
                                                        ? Icons.check_circle
                                                        : Icons.logout,
                                                    color: Colors.white,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    attendanceProvider.isClockedIn
                                                        ? 'Clock In Successful!'
                                                        : 'Clock Out Successful!',
                                                  ),
                                                ],
                                              ),
                                              backgroundColor: Colors.green,
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        }
                                      },
                                icon: Icon(
                                  attendanceProvider.isClockedIn ? Icons.logout : Icons.login,
                                  size: 20,
                                ),
                                label: Text(
                                  attendanceProvider.isClockedIn ? 'Clock Out' : 'Clock In',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: attendanceProvider.isClockedIn
                                      ? Colors.orange[600]
                                      : Colors.green[600],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 5,
                                ),
                              ),
                            ),
                            if (attendanceProvider.isClockedIn) ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _showBreakOptions(context, employee),
                                  icon: const Icon(Icons.coffee, size: 18),
                                  label: const Text('Break'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    backgroundColor: Colors.brown[400],
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Quick Stats Row
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.calendar_today,
                      label: 'Today',
                      value: DateFormat('MMM dd').format(DateTime.now()),
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.access_time,
                      label: 'Hours',
                      value: attendanceProvider.isClockedIn ? '8.5' : '0',
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.trending_up,
                      label: 'This Week',
                      value: '38.5h',
                      color: Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Quick Actions Title
              Row(
                children: [
                  Icon(Icons.dashboard, color: Colors.grey[700], size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: roleColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: roleColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      '${actions.length} Actions',
                      style: TextStyle(color: roleColor, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Quick Actions Grid - 4 columns, much smaller cards
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.85,
                ),
                itemCount: actions.length,
                itemBuilder: (context, index) {
                  final action = actions[index];
                  return _QuickActionCard(
                    icon: action.icon,
                    label: action.label,
                    color: action.color,
                    onTap: () => _handleActionTap(context, action, employee),
                  );
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper class for action items
class _ActionItem {
  final IconData icon;
  final String label;
  final Color color;
  final String route;

  _ActionItem({required this.icon, required this.label, required this.color, required this.route});
}

// Enhanced Quick Action Card - Much smaller version
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
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 9,
                  color: Colors.grey[800],
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Break Option Widget
class _BreakOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _BreakOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
      ),
    );
  }
}

// Stat Card Widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]),
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

// Profile Item Widget
class _ProfileItem extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[600])),
          ),
        ],
      ),
    );
  }
}

// Sales Item Widget
class _SalesItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SalesItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: Colors.grey[700])),
            ],
          ),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
          ),
        ],
      ),
    );
  }
}

// Schedule Item Widget
class _ScheduleItem extends StatelessWidget {
  final String day;
  final String time;
  final bool isOff;

  const _ScheduleItem({required this.day, required this.time, this.isOff = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isOff ? Colors.grey : Colors.grey[800],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isOff ? Colors.grey[200] : Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              time,
              style: TextStyle(
                color: isOff ? Colors.grey[600] : Colors.blue[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Analytics Item Widget
class _AnalyticItem extends StatelessWidget {
  final String label;
  final String value;
  final String change;
  final bool isPositive;

  const _AnalyticItem({
    required this.label,
    required this.value,
    required this.change,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])),
          Row(
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isPositive ? Colors.green[100] : Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      size: 14,
                      color: isPositive ? Colors.green[700] : Colors.red[700],
                    ),
                    const SizedBox(width: 2),
                    Text(
                      change,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isPositive ? Colors.green[700] : Colors.red[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

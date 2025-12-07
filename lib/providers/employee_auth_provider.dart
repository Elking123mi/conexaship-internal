import 'package:flutter/foundation.dart';
import 'package:conexaship_core/conexaship_core.dart';

class EmployeeAuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  Employee? _currentEmployee;
  bool _isLoading = false;
  String? _error;

  Employee? get currentEmployee => _currentEmployee;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentEmployee != null;

  EmployeeAuthProvider() {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final isLogged = await _authService.isLoggedIn();
    if (isLogged) {
      final userData = await _authService.getCurrentUser();
      if (userData != null) {
        _currentEmployee = Employee.fromJson(userData);
        notifyListeners();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _authService.login(email, password);
      final user = data['user'] as Map<String, dynamic>;

      // Validate access to internal app
      final allowedApps = List<String>.from(user['allowed_apps'] ?? []);
      if (!allowedApps.contains('conexaship')) {
        await _authService.logout();
        _error =
            'You don\'t have access to Employee Portal. Allowed apps: ${allowedApps.join(", ")}';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentEmployee = Employee.fromJson(user);
      _isLoading = false;
      notifyListeners();
      return true;
    } on Exception catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('SocketException') || errorMsg.contains('Connection')) {
        _error = 'Cannot connect to server. Check your connection.';
      } else if (errorMsg.contains('TimeoutException')) {
        _error = 'Server not responding. Try again.';
      } else {
        _error = 'Error: $errorMsg';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Unexpected error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentEmployee = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

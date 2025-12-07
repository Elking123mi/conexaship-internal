import 'package:flutter/foundation.dart';
import 'package:conexaship_core/conexaship_core.dart';
import 'dart:io';

class AttendanceProvider with ChangeNotifier {
  final ApiService _apiService = ApiService(customBaseUrl: AppConstants.internalApiBaseUrl);
  List<Attendance> _records = [];
  Attendance? _currentAttendance;
  bool _isLoading = false;
  String? _error;

  List<Attendance> get records => _records;
  Attendance? get currentAttendance => _currentAttendance;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isClockedIn => _currentAttendance != null && !_currentAttendance!.isClockedOut;

  Future<void> loadAttendance(int employeeId, {DateTime? startDate, DateTime? endDate}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _records = await _apiService.getEmployeeAttendance(
        employeeId,
        startDate: startDate,
        endDate: endDate,
      );

      // Find if there's an active attendance (not clocked out)
      _currentAttendance = _records.firstWhere(
        (a) => !a.isClockedOut,
        orElse: () => Attendance(employeeId: 0, clockIn: DateTime.now()),
      );

      if (_currentAttendance!.employeeId == 0) {
        _currentAttendance = null;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar registros';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> clockIn(int employeeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final ipAddress = await _getIpAddress();
      final attendance = await _apiService.clockIn(
        employeeId,
        'Office', // You can add location detection
        ipAddress,
      );

      _currentAttendance = attendance;
      _records.insert(0, attendance);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al marcar entrada';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> clockOut() async {
    if (_currentAttendance == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final attendance = await _apiService.clockOut(_currentAttendance!.id!);

      // Update the record in the list
      final index = _records.indexWhere((a) => a.id == attendance.id);
      if (index >= 0) {
        _records[index] = attendance;
      }

      _currentAttendance = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al marcar salida';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<String> _getIpAddress() async {
    try {
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4) {
            return addr.address;
          }
        }
      }
      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

import '../services/auth_service_simple.dart';

/// Verificar si el usuario actual tiene un rol específico
Future<bool> hasRole(String role) async {
  final user = await AuthService().getCurrentUser();
  if (user == null) return false;

  final roles = List<String>.from(user['roles']);
  return roles.contains(role);
}

/// Verificar si el usuario actual tiene acceso a una app específica
Future<bool> canAccessApp(String appName) async {
  final user = await AuthService().getCurrentUser();
  if (user == null) return false;

  final allowedApps = List<String>.from(user['allowed_apps']);
  return allowedApps.contains(appName);
}

/// Verificar si el usuario tiene al menos uno de los roles especificados
Future<bool> hasAnyRole(List<String> roleList) async {
  final user = await AuthService().getCurrentUser();
  if (user == null) return false;

  final roles = List<String>.from(user['roles']);
  return roleList.any((role) => roles.contains(role));
}

/// Verificar si el usuario tiene todos los roles especificados
Future<bool> hasAllRoles(List<String> roleList) async {
  final user = await AuthService().getCurrentUser();
  if (user == null) return false;

  final roles = List<String>.from(user['roles']);
  return roleList.every((role) => roles.contains(role));
}

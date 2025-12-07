import 'package:flutter/material.dart';
import '../models/user.dart';

/// Widget that only displays its child if the user has required permissions
class PermissionGuard extends StatelessWidget {
  final User user;
  final Widget child;
  final List<String>? requiredRoles;
  final List<String>? requiredApps;
  final bool requireAll;
  final Widget? fallback;

  const PermissionGuard({
    super.key,
    required this.user,
    required this.child,
    this.requiredRoles,
    this.requiredApps,
    this.requireAll = false,
    this.fallback,
  });

  bool _hasPermission() {
    bool rolesOk = true;
    bool appsOk = true;

    if (requiredRoles != null && requiredRoles!.isNotEmpty) {
      if (requireAll) {
        rolesOk = requiredRoles!.every((role) => user.hasRole(role));
      } else {
        rolesOk = user.hasAnyRole(requiredRoles!);
      }
    }

    if (requiredApps != null && requiredApps!.isNotEmpty) {
      if (requireAll) {
        appsOk = requiredApps!.every((app) => user.canAccessApp(app));
      } else {
        appsOk = requiredApps!.any((app) => user.canAccessApp(app));
      }
    }

    return rolesOk && appsOk;
  }

  @override
  Widget build(BuildContext context) {
    if (_hasPermission()) {
      return child;
    }
    return fallback ?? const SizedBox.shrink();
  }
}

/// Mixin for easier permission checks in widgets
mixin PermissionChecks {
  bool canShowModule(
    User user, {
    List<String>? roles,
    List<String>? apps,
  }) {
    if (roles != null && roles.isNotEmpty) {
      if (!user.hasAnyRole(roles)) return false;
    }
    if (apps != null && apps.isNotEmpty) {
      if (!apps.any((app) => user.canAccessApp(app))) return false;
    }
    return true;
  }

  bool canShowVaneluxFeatures(User user) {
    return user.canAccessApp('vanelux');
  }

  bool canShowConexashipFeatures(User user) {
    return user.canAccessApp('conexaship');
  }
}

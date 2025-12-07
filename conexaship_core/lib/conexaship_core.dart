library conexaship_core;

// Models
export 'models/customer.dart';
export 'models/employee.dart';
export 'models/product.dart';
export 'models/order.dart';
export 'models/attendance.dart';
export 'models/user.dart';
export 'models/vendor.dart';

// Config
export 'config/api_config.dart';

// Services - Simple (Direct Backend Integration)
export 'services/auth_service_simple.dart';
export 'services/api_client.dart';
export 'services/trips_service.dart';
export 'services/user_service.dart';

// Services - V2 (Centralized Backend)
export 'services/auth_service_v2.dart';
export 'services/authenticated_http_client.dart';
export 'services/trips_repository.dart';
export 'services/payments_repository.dart';
export 'services/reports_repository.dart';
export 'services/storage_repository.dart';

// Services - Legacy (for backward compatibility)
export 'services/database_service.dart';
export 'services/auth_service.dart' hide AuthService;
export 'services/api_service.dart';

// Widgets
export 'widgets/permission_guard.dart';

// Screens
export 'screens/login_screen.dart';

// Utils
export 'utils/constants.dart';
export 'utils/validators.dart';
export 'utils/role_helpers.dart';

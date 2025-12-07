class AppConstants {
  // Database Configuration
  static const String dbHost = 'YOUR_SQL_SERVER_HOST';
  static const int dbPort = 1433;
  static const String dbName = 'ConexaShipDB';
  static const String dbUser = 'YOUR_DB_USER';
  static const String dbPassword = 'YOUR_DB_PASSWORD';

  // API Configuration - Centralized Backend
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://web-production-700fe.up.railway.app',
  );
  static const String originWebAllowed = String.fromEnvironment(
    'ORIGIN_WEB_ALLOWED',
    defaultValue: 'https://app.conexaship.tu',
  );
  static const int apiTimeout = int.fromEnvironment(
    'API_TIMEOUT',
    defaultValue: 30,
  );

  // Legacy internal URL (deprecated - use apiBaseUrl instead)
  static const String internalApiBaseUrl = apiBaseUrl;

  // App Configuration
  static const String appName = 'Conexa Ship';
  static const String appVersion = '1.0.0';

  // Network Configuration for Internal App
  static const List<String> allowedNetworks = [
    '192.168.1', // Replace with your company network prefix
    '10.0.0', // Add more allowed network ranges
  ];

  // Time Configuration
  static const int sessionTimeout = 3600; // 1 hour in seconds
}

class ApiEndpoints {
  // Auth Endpoints (Centralized Backend v1)
  static const String authLogin = '/api/v1/auth/login';
  static const String authRefresh = '/api/v1/auth/refresh';
  static const String authLogout = '/api/v1/auth/logout';
  static const String authRegister = '/api/v1/auth/register';

  // User Management
  static const String users = '/api/v1/users';

  // Public API Endpoints
  static const String products = '/api/v1/products';
  static const String categories = '/api/v1/categories';
  static const String orders = '/api/v1/orders';
  static const String customers = '/api/v1/customers';

  // Conexaship Business Endpoints
  static const String trips = '/api/v1/trips';
  static const String payments = '/api/v1/payments';
  static const String reportsExport = '/api/v1/reports/export';
  static String reportsStatus(String jobId) => '/api/v1/reports/status/$jobId';

  // Storage (Uploads)
  static const String storagePresign = '/api/v1/storage/presign';

  // Internal API Endpoints
  static const String employees = '/api/v1/employees';
  static const String attendance = '/api/v1/attendance';
  static const String clockIn = '/api/v1/attendance/clock-in';
  static const String clockOut = '/api/v1/attendance/clock-out';
  static const String reports = '/api/v1/reports';

  // Legacy endpoints (deprecated)
  static const String login = authLogin;
  static const String register = authRegister;
}

class ErrorMessages {
  static const String networkError = 'Error de conexión. Verifica tu internet.';
  static const String serverError = 'Error del servidor. Intenta más tarde.';
  static const String unauthorized = 'No autorizado. Inicia sesión nuevamente.';
  static const String invalidCredentials = 'Credenciales inválidas.';
  static const String notInCompanyNetwork =
      'Esta aplicación solo funciona en la red de la empresa.';
}

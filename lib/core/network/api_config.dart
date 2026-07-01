class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://172.16.49.115:8000',
  );

  static const String register = '/api/v1/auth/register';
  static const String login = '/api/v1/auth/login';
  static const String googleLogin = '/api/v1/auth/google-login';
  static const String telegramLoginStatus =
      '/api/v1/auth/telegram-login-status';
  static const String refreshToken = '/api/v1/auth/refresh-token';
  static const String forgotPassword = '/api/v1/auth/forgot-password';
  static const String verifyOtp = '/api/v1/auth/verify-otp';
  static const String resetPassword = '/api/v1/auth/reset-password';
  static const String changePassword = '/api/v1/auth/change-password';
  static const String getProfile = '/api/v1/users/me';
  static const String updateProfile = '/api/v1/users/me';
  static const String uploadAvatar = '/api/v1/users/me/avatar';
  static const String categories = '/api/v1/categories';
  static const String books = '/api/v1/books';
  static const String cart = '/api/v1/cart';
  static const String cartItems = '/api/v1/cart/items';
  static const String orders = '/api/v1/orders';
  static String orderSummary(String id) => '/api/v1/orders/$id/summary';
  static String cancelOrder(String id) => '/api/v1/orders/$id/cancel';
  static String orderInvoice(String id) => '/api/v1/orders/$id/invoice';
  static const String wishlist = '/api/v1/wishlist';
  static const String wishlistToggle = '/api/v1/wishlist/toggle';

  // ==== Location Section ======
  static const double shopLat = 11.5564;
  static const double shopLng = 104.9282;
  static const String shopName = "Librarain HQ";
  static const String shopAddress = "123 Norodom Blvd, Phnom Penh";
  static const String telegramBotUsername = String.fromEnvironment(
    'TELEGRAM_BOT_USERNAME',
    defaultValue: 'librarain_postman2_bot',
  );
}

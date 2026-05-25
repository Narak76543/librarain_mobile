class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.0.198:8000',

    // ah san wifi
    // defaultValue: 'http://172.16.53.187:8000',
  );

  static const String register = '/api/v1/auth/register';
  static const String login = '/api/v1/auth/login';
  static const String refreshToken = '/api/v1/auth/refresh-token';
  static const String forgotPassword = '/api/v1/auth/forgot-password';
  static const String verifyOtp = '/api/v1/auth/verify-otp';
  static const String resetPassword = '/api/v1/auth/reset-password';
  static const String getProfile = '/api/v1/users/me';
  static const String updateProfile = '/api/v1/users/me';
  static const String uploadAvatar = '/api/v1/users/me/avatar';
  static const String categories = '/api/v1/categories';
  static const String books = '/api/v1/books';
  static const String cart = '/api/v1/cart';
  static const String cartItems = '/api/v1/cart/items';
  static const String orders = '/api/v1/orders';
  static const String wishlist = '/api/v1/wishlist';
  static const String wishlistToggle = '/api/v1/wishlist/toggle';
}

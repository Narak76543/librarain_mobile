class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String welcome = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verifyOtp = '/verify-otp';
  static const String resetPassword = '/reset-password';
  static const String main = '/main';
  static const String home = '/main/home';
  static const String shop = '/main/shop';
  static const String cart = '/main/cart';
  static const String profile = '/main/profile';
  static const String editProfile = '/edit-profile';
  static const String wishlist = '/wishlist';
  static const String orders = '/orders';
  static const String orderConfirmed = '/orders/confirmed';
  static String orderSummary(String id) => '/orders/$id/summary';
}

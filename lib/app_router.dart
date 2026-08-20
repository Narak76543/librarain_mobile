import 'package:go_router/go_router.dart';
import 'core/constants/app_routes.dart';
import 'presentation/auth/views/forgot_password_screen.dart';
import 'presentation/auth/views/login_screen.dart';
import 'presentation/auth/views/otp_verify_screen.dart';
import 'presentation/auth/views/register_screen.dart';
import 'presentation/auth/views/reset_password_screen.dart';
import 'presentation/auth/views/welcome_screen.dart';
import 'presentation/main/main_screen.dart';
import 'presentation/onboarding/onboarding_screen.dart';
import 'presentation/profile/views/edit_profile_screen.dart';
import 'presentation/profile/views/shipping_address_screen.dart';
import 'presentation/profile/views/change_password_screen.dart';
import 'presentation/profile/views/wishlist_screen.dart';
import 'presentation/history/history_screen.dart';
import 'presentation/orders/views/order_summary_screen.dart';
import 'presentation/orders/views/order_confirmed_screen.dart';
import 'presentation/cart/cart_screen.dart';
import 'presentation/shop/views/book_detail_screen.dart';
import 'presentation/shop/views/ai_chat_screen.dart';
import 'presentation/home/views/notification_screen.dart';

GoRouter createAppRouter({required bool isLoggedIn}) {
  return GoRouter(
    initialLocation: isLoggedIn ? AppRoutes.main : AppRoutes.onboarding,
    routes: [

      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.verifyOtp,
        builder: (context, state) =>
            OtpVerifyScreen(email: state.extra as String),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) =>
            ResetPasswordScreen(email: state.extra as String),
      ),
      GoRoute(
        path: AppRoutes.main,
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.shippingAddress,
        builder: (context, state) => const ShippingAddressScreen(),
      ),
      GoRoute(
        path: AppRoutes.changePassword,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.wishlist,
        builder: (context, state) => const WishlistScreen(),
      ),
      GoRoute(
        path: AppRoutes.orders,
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.orderConfirmed,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return OrderConfirmedScreen(
            orderId:         extra['orderId'].toString(),
            orderTotal:      extra['orderTotal'] as double,
            orderItems:      extra['orderItems'] as List,
            deliveryWay:     extra['deliveryWay'] as String? ?? 'Pick Up',
            deliveryPartner: extra['deliveryPartner'] as String?,
            paymentMethod:   extra['paymentMethod'] as String? ?? 'COD',
          );
        },
      ),
      GoRoute(
        path: '/orders/:id/summary',
        builder: (context, state) {
          final orderId = state.pathParameters['id']!;
          return OrderSummaryScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: AppRoutes.cart,
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/book/:id',
        builder: (context, state) {
          final bookId = state.pathParameters['id']!;
          return BookDetailScreen(bookId: bookId);
        },
      ),
      GoRoute(
        path: AppRoutes.aiChat,
        builder: (context, state) => const AiChatScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationScreen(),
      ),
    ],
  );
}

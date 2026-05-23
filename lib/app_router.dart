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
    ],
  );
}

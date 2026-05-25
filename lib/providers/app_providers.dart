import 'package:provider/provider.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../presentation/auth/viewmodels/auth_view_model.dart';
import '../presentation/cart/viewmodels/cart_viewmodel.dart';
import '../presentation/profile/viewmodels/profile_viewmodel.dart';
import '../presentation/history/viewmodels/history_viewmodel.dart';
import '../data/repositories/order_repository.dart';

final appProviders = [
  ChangeNotifierProvider<AuthViewModel>(
    create: (_) => AuthViewModel(AuthRepository()),
  ),
  ChangeNotifierProvider<ProfileViewModel>(
    create: (_) => ProfileViewModel(ProfileRepository()),
  ),
  ChangeNotifierProvider<CartViewModel>(
    create: (_) => CartViewModel(),
  ),
  ChangeNotifierProvider<HistoryViewModel>(
    create: (_) => HistoryViewModel(OrderRepository()),
  ),
];

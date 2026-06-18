import 'package:provider/provider.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/order_repository.dart';
import '../../presentation/auth/viewmodels/auth_view_model.dart';
import '../../presentation/cart/viewmodels/cart_viewmodel.dart';
import '../../presentation/profile/viewmodels/profile_viewmodel.dart';
import '../../presentation/history/viewmodels/history_viewmodel.dart';
import '../../presentation/profile/viewmodels/wishlist_viewmodel.dart';
import '../../presentation/orders/viewmodels/order_viewmodel.dart';
import '../../presentation/shop/viewmodels/shop_viewmodel.dart';
import '../../presentation/shop/viewmodels/book_detail_viewmodel.dart';
import '../../presentation/shop/viewmodels/ai_chat_viewmodel.dart';
import '../../presentation/home/viewmodels/home_viewmodel.dart';
import '../../presentation/home/viewmodels/notification_viewmodel.dart';
import 'injection.dart'; // import sl

final appProviders = [
  ChangeNotifierProvider<NotificationViewModel>(
    create: (_) => NotificationViewModel(),
  ),
  ChangeNotifierProvider<AiChatViewModel>(
    create: (_) => AiChatViewModel(),
  ),
  ChangeNotifierProvider<HomeViewModel>(
    create: (_) => HomeViewModel()..loadAll(),
  ),
  ChangeNotifierProvider<AuthViewModel>(
    create: (_) => AuthViewModel(sl<AuthRepository>()),
  ),
  ChangeNotifierProvider<ProfileViewModel>(
    create: (_) => ProfileViewModel(sl<ProfileRepository>()),
  ),
  ChangeNotifierProvider<CartViewModel>(
    create: (_) => CartViewModel(),
  ),
  ChangeNotifierProvider<HistoryViewModel>(
    create: (_) => HistoryViewModel(sl<OrderRepository>()),
  ),
  ChangeNotifierProvider<WishlistViewModel>(
    create: (_) => WishlistViewModel(),
  ),
  ChangeNotifierProvider<OrderViewModel>(
    create: (_) => OrderViewModel(),
  ),
  ChangeNotifierProvider<ShopViewModel>(
    create: (_) => ShopViewModel(),
  ),
  ChangeNotifierProvider<BookDetailViewModel>(
    create: (_) => BookDetailViewModel(),
  ),
];

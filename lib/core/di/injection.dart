import 'package:get_it/get_it.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/book_repository.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/invoice_repository.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/wishlist_repository.dart';
import '../../data/services/ai_search_service.dart';

final sl = GetIt.instance;

Future<void> initDi() async {
  // Services
  sl.registerLazySingleton(() => AiSearchService());

  // Repositories
  sl.registerLazySingleton(() => AuthRepository());
  sl.registerLazySingleton(() => BookRepository());
  sl.registerLazySingleton(() => CartRepository());
  sl.registerLazySingleton(() => CategoryRepository());
  sl.registerLazySingleton(() => InvoiceRepository());
  sl.registerLazySingleton(() => OrderRepository());
  sl.registerLazySingleton(() => ProfileRepository());
  sl.registerLazySingleton(() => WishlistRepository());
}

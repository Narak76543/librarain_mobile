import 'package:provider/provider.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../presentation/auth/viewmodels/auth_view_model.dart';
import '../presentation/profile/viewmodels/profile_viewmodel.dart';

final appProviders = [
  ChangeNotifierProvider<AuthViewModel>(
    create: (_) => AuthViewModel(AuthRepository()),
  ),
  ChangeNotifierProvider<ProfileViewModel>(
    create: (_) => ProfileViewModel(ProfileRepository()),
  ),
];

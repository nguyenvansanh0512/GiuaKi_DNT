import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'screens/login_screen.dart';
import 'screens/user_list_screen.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});
  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      Provider(create: (_) => ApiService(), dispose: (_, api) => api.dispose()),
      Provider(create: (ctx) => UserService(ctx.read<ApiService>())),
      ChangeNotifierProvider(
        create: (ctx) => AuthProvider(AuthService(ctx.read<ApiService>())),
      ),
    ],
    child: MaterialApp(
      title: 'AdminSpace • Quản lý người dùng',
      debugShowCheckedModeBanner: false,
      locale: const Locale('vi'),
      supportedLocales: const [Locale('vi')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff176c64),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xfff3f6f8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 19),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const AuthGate(),
    ),
  );
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    final authenticated = context.watch<AuthProvider>().authenticated;
    return _SessionNavigator(
      key: ValueKey(authenticated),
      authenticated: authenticated,
    );
  }
}

class _SessionNavigator extends StatefulWidget {
  final bool authenticated;
  const _SessionNavigator({super.key, required this.authenticated});
  @override
  State<_SessionNavigator> createState() => _SessionNavigatorState();
}

class _SessionNavigatorState extends State<_SessionNavigator> {
  final _key = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) => NavigatorPopHandler<Object?>(
    onPopWithResult: (result) {
      _key.currentState?.maybePop(result);
    },
    child: Navigator(
      key: _key,
      onGenerateRoute: (_) => MaterialPageRoute<void>(
        builder: (_) =>
            widget.authenticated ? const UserListScreen() : const LoginScreen(),
      ),
    ),
  );
}

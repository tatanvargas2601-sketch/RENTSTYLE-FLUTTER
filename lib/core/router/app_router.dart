import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/usuario.dart';
import '../../providers/auth_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/home/prenda_detail_screen.dart';
import '../../screens/cart/cart_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/citas/citas_screen.dart';
import '../../screens/citas/agendar_cita_screen.dart';
import '../../screens/reservas/mis_reservas_screen.dart';
import '../../screens/admin/admin_shell.dart';
import '../../screens/admin/dashboard_screen.dart';
import '../../screens/admin/categorias_admin_screen.dart';
import '../../screens/admin/productos_admin_screen.dart';
import '../../screens/admin/inventario_admin_screen.dart';
import '../../screens/admin/usuarios_admin_screen.dart';
import '../../screens/admin/reservas_admin_screen.dart';

/// Puente entre el estado de Riverpod (authProvider) y go_router,
/// que necesita un Listenable para saber cuándo re-evaluar `redirect`.
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/registro';
      final goingHome = state.matchedLocation == '/';

      if (auth.isLoading) return null; // aún restaurando sesión, no redirigir todavía

      final protectedAdmin = state.matchedLocation.startsWith('/admin');
      final protectedEmpleado = state.matchedLocation.startsWith('/empleado');
      final protectedUser = ['/cart', '/profile', '/citas', '/agendar-cita', '/mis-reservas']
          .any((p) => state.matchedLocation.startsWith(p));

      // No autenticado intentando entrar a zona protegida -> login
      if (!auth.isAuthenticated && (protectedAdmin || protectedEmpleado || protectedUser)) {
        return '/login';
      }

      // Autenticado y en login/registro -> mándalo a su dashboard
      if (auth.isAuthenticated && loggingIn) {
        return _homeForRole(auth.role);
      }

      // Chequeo de rol: un "user" no puede entrar a /admin ni /empleado
      if (auth.isAuthenticated) {
        if (protectedAdmin && auth.role != AppRole.admin) return _homeForRole(auth.role);
        if (protectedEmpleado &&
            auth.role != AppRole.empleado &&
            auth.role != AppRole.admin) {
          return _homeForRole(auth.role);
        }
      }

      // Justo después del login, auth.isAuthenticated pasa a true mientras seguimos
      // en "/": mándalo directo a su dashboard según el rol (admin/empleado).
      // Para "user" el catálogo ("/") es su home, así que no lo redirigimos.
      if (goingHome && auth.isAuthenticated) {
        if (auth.role == AppRole.admin) return '/admin';
        if (auth.role == AppRole.empleado) return '/empleado';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (c, s) => const HomeScreen()),
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/registro', builder: (c, s) => const RegisterScreen()),
      GoRoute(
        path: '/prenda/:id',
        builder: (c, s) => PrendaDetailScreen(idPrenda: int.parse(s.pathParameters['id']!)),
      ),
      GoRoute(path: '/cart', builder: (c, s) => const CartScreen()),
      GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),
      GoRoute(path: '/citas', builder: (c, s) => const CitasScreen()),
      GoRoute(path: '/agendar-cita', builder: (c, s) => const AgendarCitaScreen()),
      GoRoute(path: '/mis-reservas', builder: (c, s) => const MisReservasScreen()),

      // Shell con Drawer/BottomNav compartido para admin y empleado
      // (igual que NavAdmin.jsx se reutiliza en ambas rutas en tu React).
      ShellRoute(
        builder: (c, s, child) => AdminShell(child: child),
        routes: [
          GoRoute(path: '/admin', builder: (c, s) => const DashboardScreen()),
          GoRoute(path: '/admin/productos', builder: (c, s) => const ProductosAdminScreen()),
          GoRoute(path: '/admin/usuarios', builder: (c, s) => const UsuariosAdminScreen()),
          GoRoute(path: '/admin/inventario', builder: (c, s) => const InventarioAdminScreen()),
          GoRoute(path: '/admin/reservas', builder: (c, s) => const ReservasAdminScreen()),
          GoRoute(path: '/empleado', builder: (c, s) => const DashboardScreen()),
          GoRoute(path: '/empleado/productos', builder: (c, s) => const ProductosAdminScreen()),
          GoRoute(path: '/empleado/usuarios', builder: (c, s) => const UsuariosAdminScreen()),
          GoRoute(path: '/empleado/inventario', builder: (c, s) => const InventarioAdminScreen()),
          GoRoute(path: '/empleado/reservas', builder: (c, s) => const ReservasAdminScreen()),
        ],
      ),
    ],
  );
});

String _homeForRole(AppRole? role) {
  switch (role) {
    case AppRole.admin:
      return '/admin';
    case AppRole.empleado:
      return '/empleado';
    default:
      return '/';
  }
}

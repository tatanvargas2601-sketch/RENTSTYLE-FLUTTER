import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/usuario.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _obscure = true;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Igual que Login.jsx: correo en minúsculas y sin espacios.
      await ref
          .read(authProvider.notifier)
          .login(_correoCtrl.text.trim().toLowerCase(), _passCtrl.text);

      final role = ref.read(authProvider).role;
      if (!mounted) return;
      // Navegación explícita por rol (además del redirect de go_router),
      // igual que el navigate() de tu Login.jsx.
      if (role == AppRole.admin) {
        context.go('/admin');
      } else if (role == AppRole.empleado) {
        context.go('/empleado');
      } else {
        context.go('/');
      }
    } catch (e) {
      setState(() => _error = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('Correo o contraseña')) return 'Correo o contraseña incorrectos';
    if (msg.contains('SocketException') || msg.contains('Connection')) {
      return 'No se pudo conectar con el servidor. Revisa que el backend esté '
          'corriendo y que kApiBaseUrl (api_client.dart) apunte a la IP correcta.';
    }
    return msg.replaceFirst('Exception: ', '');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final wide = MediaQuery.of(context).size.width >= 900;

    final leftPanel = _LeftHero(isDark: isDark);
    final rightPanel = _LoginForm(
      formKey: _formKey,
      correoCtrl: _correoCtrl,
      passCtrl: _passCtrl,
      loading: _loading,
      error: _error,
      obscure: _obscure,
      onToggleObscure: () => setState(() => _obscure = !_obscure),
      onSubmit: _submit,
    );

    return Scaffold(
      // Todo dentro de un único SingleChildScrollView (incluida la barra superior)
      // para que nunca pueda desbordar verticalmente, sin importar el alto de la ventana.
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _LoginTopNav(isDark: isDark),
              wide
                  ? IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: leftPanel),
                          Expanded(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(40),
                                child: rightPanel,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        leftPanel,
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                          child: rightPanel,
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginTopNav extends ConsumerWidget {
  final bool isDark;
  const _LoginTopNav({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('RentStyle', style: Theme.of(context).textTheme.headlineSmall),
          Row(
            children: [
              _ThemeToggleButton(isDark: isDark),
              const SizedBox(width: 8),
              _NavPill(label: 'Inicio', onTap: () => context.go('/')),
              const SizedBox(width: 8),
              _NavPill(label: 'Registrarse', onTap: () => context.push('/registro')),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeToggleButton extends ConsumerWidget {
  final bool isDark;
  const _ThemeToggleButton({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primary = Theme.of(context).colorScheme.primary;
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: () => ref.read(themeProvider.notifier).toggle(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Center(
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primary, width: 2),
              gradient: LinearGradient(
                colors: [primary, Colors.transparent],
                stops: const [0.5, 0.5],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavPill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NavPill({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withOpacity(0.04)
          : const Color(0xFFF5FAF4),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ),
    );
  }
}

class _LeftHero extends StatelessWidget {
  final bool isDark;
  const _LeftHero({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        gradient: isDark
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.loginLeftGradientLight,
              ),
        color: isDark ? AppColors.loginLeftBgDark : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'BIENVENIDO A',
            style: TextStyle(
              letterSpacing: 4,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.welcomeTextDark : AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text('RentStyle', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 16),
          Text(
            'Alquila lo que necesitas, cuando lo necesitas.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontSize: 16,
                  height: 1.6,
                ),
          ),
          const SizedBox(height: 24),
          for (final item in ['Catálogo actualizado', 'Alquiler flexible', 'Cancelación sin cargos'])
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text('✦ $item', style: Theme.of(context).textTheme.bodyLarge),
            ),
        ],
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController correoCtrl;
  final TextEditingController passCtrl;
  final bool loading;
  final String? error;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;

  const _LoginForm({
    required this.formKey,
    required this.correoCtrl,
    required this.passCtrl,
    required this.loading,
    required this.error,
    required this.obscure,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 450),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDarkLight.withOpacity(0.08),
              blurRadius: 35,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Iniciar sesión',
                  style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: 28),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Correo electrónico',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: correoCtrl,
                decoration: const InputDecoration(hintText: 'ejemplo@correo.com'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Contraseña',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: passCtrl,
                decoration: InputDecoration(
                  hintText: 'Ingresa tu contraseña',
                  suffixIcon: IconButton(
                    icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: onToggleObscure,
                  ),
                ),
                obscureText: obscure,
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                onFieldSubmitted: (_) => onSubmit(),
              ),
              const SizedBox(height: 20),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(error!,
                      style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: loading ? null : onSubmit,
                  child: loading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Ingresar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
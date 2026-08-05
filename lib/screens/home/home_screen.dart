import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/theme_provider.dart';

/// Equivalente exacto a Inicio.jsx + Nav.jsx: es solo la landing pública
/// (eyebrow + título + párrafo + tarjeta "Tu armario premium"), SIN catálogo.
/// El catálogo real vive en DashboardUserScreen ("/dashboarduser"), a donde
/// se entra después de iniciar sesión (igual que en React).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _PublicNav(isDark: isDark),
              _HeroSection(isDark: isDark),
            ],
          ),
        ),
      ),
    );
  }
}

class _PublicNav extends ConsumerWidget {
  final bool isDark;
  const _PublicNav({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('RentStyle', style: Theme.of(context).textTheme.headlineSmall),
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _ThemeDot(isDark: isDark),
              _Pill(label: 'Iniciar sesión', onTap: () => context.push('/login')),
              _Pill(label: 'Registrarse', onTap: () => context.push('/registro')),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeDot extends ConsumerWidget {
  final bool isDark;
  const _ThemeDot({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primary = Theme.of(context).colorScheme.primary;
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: () => ref.read(themeProvider.notifier).toggle(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: Center(
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primary, width: 2),
              gradient: LinearGradient(colors: [primary, Colors.transparent], stops: const [0.5, 0.5]),
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _Pill({required this.label, required this.onTap});

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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final bool isDark;
  const _HeroSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // .eyebrow -> pill con el mismo texto
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text('Elegancia bajo demanda',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 20),
          Text('RentStyle', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 44)),
          const SizedBox(height: 16),
          Text(
            'Alquila atuendos cuidadosamente seleccionados para cada ocasión. '
            'Diseño fresco, accesible y con estilo para tus eventos más especiales.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  height: 1.6,
                ),
          ),
          const SizedBox(height: 28),
          // .hero-tag
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tu armario premium', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Explora tus looks de gala, cóctel y eventos especiales con colores '
                  'suaves y detalles cuidadosamente pensados',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
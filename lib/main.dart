// lib/main.dart
// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Models
import 'package:commerce/models/product.dart';
import 'package:commerce/models/abonnement.dart';

// Services
import 'package:commerce/services/auth_service.dart';
import 'package:commerce/services/product_service.dart';
import 'package:commerce/services/order_service.dart';
import 'package:commerce/services/driver_service.dart';
import 'package:commerce/services/abonnement_service.dart';
import 'package:commerce/services/seller_service.dart';

// Facebook Services & Providers
import 'package:commerce/services/facebook_service.dart';
import 'package:commerce/provider/facebook_provider.dart';

// Notifiers
import 'package:commerce/notifiers/seller_profile_notifier.dart';

// Screens
import 'package:commerce/screens/splash_screen.dart';
import 'package:commerce/screens/login_screen.dart';
import 'package:commerce/screens/signup_screen.dart';
import 'package:commerce/screens/dashboard_screen.dart';
import 'package:commerce/screens/product_management_screen.dart';
import 'package:commerce/screens/addeditproductscreen.dart';
import 'package:commerce/screens/auth/forgot_password_screen.dart';
import 'package:commerce/screens/auth/verify_reset_code_screen.dart';
import 'package:commerce/screens/auth/reset_password_screen.dart';
import 'package:commerce/screens/drivers/driver_list_screen.dart';
import 'package:commerce/screens/drivers/create_driver_screen.dart';
import 'package:commerce/screens/drivers/edit_driver_screen.dart';
import 'package:commerce/screens/abonnement_screen.dart';
import 'package:commerce/screens/seller_profile_screen.dart';

// NOUVEAUX ÉCRANS AJOUTÉS
import 'package:commerce/screens/orders_screen.dart';
import 'package:commerce/screens/deliveries_screen.dart';
import 'package:commerce/screens/facebook_integration_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialiser SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // Créer le service d'authentification
    final authService = await createAuthService();

    runApp(MyApp(authService: authService, prefs: prefs));
  } catch (e) {
    // Gestion d'erreur au démarrage
    runApp(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Erreur')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 20),
                  const Text(
                    'Erreur de démarrage:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    e.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => main(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  final SharedPreferences prefs;

  const MyApp({super.key, required this.authService, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services d'authentification
        ChangeNotifierProvider<AuthService>.value(value: authService),

        // Services Facebook
        Provider<FacebookService>(
          create: (context) => FacebookService(context.read<AuthService>()),
        ),

        ChangeNotifierProvider<FacebookProvider>(
          create: (context) =>
              FacebookProvider(context.read<FacebookService>()),
        ),

        // Services métier
        ChangeNotifierProvider<ProductService>(
          create: (context) {
            return ProductService(
              getAuthToken: () {
                final auth = context.read<AuthService>();
                return auth.authToken ?? '';
              },
              getSellerId: () {
                final auth = context.read<AuthService>();
                return auth.currentVendor?.id ?? '';
              },
              getUserId: () {
                final auth = context.read<AuthService>();
                return auth.currentVendor?.id ?? '';
              },
            );
          },
        ),

        ChangeNotifierProvider<OrderService>(
          create: (context) => OrderService(),
        ),

        ChangeNotifierProvider<DriverService>(
          create: (context) => DriverService(),
        ),

        ChangeNotifierProvider<AbonnementFormData>(
          create: (context) => AbonnementFormData(),
        ),

        Provider<AbonnementService>(create: (context) => AbonnementService()),

        // Service pour le profil vendeur
        Provider<SellerService>(create: (context) => SellerService()),

        // Notifier pour le profil vendeur
        ChangeNotifierProvider<SellerProfileNotifier>(
          create: (context) {
            final auth = context.read<AuthService>();
            final currentVendor = auth.currentVendor;

            // Créer un profil vendeur initial à partir de l'authentification
            final initialProfile = SellerProfile(
              id: currentVendor?.id ?? '',
              fullName: currentVendor?.name ?? 'Non défini',
              email: currentVendor?.email ?? '',
              phone: currentVendor?.phone ?? '',
              address: currentVendor?.address ?? '',
              companyName: currentVendor?.companyName ?? '',
              status: 'active',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              facebookInfo: const {},
            );

            return SellerProfileNotifier(initialProfile);
          },
        ),
      ],
      child: MaterialApp(
        title: 'Live Commerce',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: const SplashScreen(),

        // ROUTES STATIQUES
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/products': (context) => const ProductManagementScreen(),
          '/products/add': (context) => const AddEditProductScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/drivers': (context) => const DriverListScreen(),
          '/drivers/create': (context) => const CreateDriverScreen(),
          '/abonnement': (context) => const AbonnementScreen(),
          '/sellerprofil': (context) => const SellerProfileScreen(),
          '/profile': (context) => const SellerProfileScreen(),
          '/orders': (context) => const OrdersScreen(),
          '/deliveries': (context) => const DeliveriesScreen(),
          '/facebook': (context) => const FacebookIntegrationScreen(),
        },

        // ROUTES DYNAMIQUES (avec arguments)
        onGenerateRoute: (settings) {
          // Route pour l'édition d'un produit
          if (settings.name == '/products/edit') {
            final args = settings.arguments as Map<String, dynamic>?;
            final product = args?['product'] as Product?;

            if (product == null) {
              return MaterialPageRoute(
                builder: (_) => const Scaffold(
                  body: Center(child: Text('Produit non trouvé')),
                ),
              );
            }

            return MaterialPageRoute(
              builder: (_) => AddEditProductScreen(product: product),
            );
          }

          // Route pour vérifier le code de réinitialisation
          if (settings.name == '/verify-reset-code') {
            final args = settings.arguments;
            String email = '';

            if (args is String) {
              email = args;
            } else if (args is Map<String, dynamic>) {
              email = args['email'] as String? ?? '';
            }

            return MaterialPageRoute(
              builder: (_) => VerifyResetCodeScreen(email: email),
            );
          }

          // Route pour réinitialiser le mot de passe
          if (settings.name == '/reset-password') {
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            final email = args['email'] as String? ?? '';
            final resetToken = args['resetToken'] as String? ?? '';

            return MaterialPageRoute(
              builder: (_) =>
                  ResetPasswordScreen(email: email, resetToken: resetToken),
            );
          }

          // Route pour l'édition d'un livreur
          if (settings.name == '/drivers/edit') {
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            final driver = args['driver'];

            if (driver == null) {
              return MaterialPageRoute(
                builder: (_) => const Scaffold(
                  body: Center(child: Text('Livreur non trouvé')),
                ),
              );
            }

            return MaterialPageRoute(
              builder: (_) => EditDriverScreen(driver: driver),
            );
          }

          // Page 404 pour les routes inconnues
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(
                title: const Text('Page non trouvée'),
                backgroundColor: Colors.red.shade700,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 80,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '404',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Route non trouvée: ${settings.name}',
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 30),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/dashboard',
                            (route) => false,
                          ),
                          icon: const Icon(Icons.dashboard, size: 18),
                          label: const Text('Tableau de bord'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/profile'),
                          icon: const Icon(Icons.person, size: 18),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          label: const Text('Mon profil'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/orders'),
                          icon: const Icon(Icons.shopping_cart, size: 18),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          label: const Text('Commandes'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/deliveries'),
                          icon: const Icon(Icons.local_shipping, size: 18),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                          ),
                          label: const Text('Livraisons'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/facebook'),
                          icon: const Icon(Icons.facebook, size: 18),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF1877F2),
                          ),
                          label: const Text('Facebook'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/products'),
                          icon: const Icon(Icons.inventory, size: 18),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          label: const Text('Produits'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (route) => false,
                          ),
                          icon: const Icon(Icons.login, size: 18),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey,
                          ),
                          label: const Text('Connexion'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
        secondary: Colors.green,
        tertiary: Colors.orange,
        tertiaryContainer: Colors.purple,
      ),
      primarySwatch: Colors.blue,
      appBarTheme: const AppBarTheme(
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 16),
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 2,
          shadowColor: Colors.blue.withOpacity(0.3),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.white,
      ),
      useMaterial3: true,
    );
  }
}

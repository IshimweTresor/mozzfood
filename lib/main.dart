import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vuba/providers/cartproviders.dart';
import 'utils/colors.dart';
import 'screens/auth/login_page.dart';
import 'screens/home_page.dart';
import 'screens/location_selection_page.dart';
import 'screens/map_location_picker_page.dart';
import 'screens/location_details_page.dart';
import 'screens/store_front_page.dart';
import 'screens/prime_page.dart';
import 'screens/orders_page.dart';
import 'screens/cart_page.dart';
import 'screens/address_book_page.dart';
import 'screens/vuba_wallet_page.dart';
import 'screens/rating_and_reviews_page.dart';
import 'screens/notification_settings_page.dart';
import 'screens/messages_page.dart';
import 'screens/about_us_page.dart';
import 'screens/more_options_page.dart';
import 'screens/personal_information_page.dart';
import 'screens/test_restaurants_page.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => CartProvider())],
      child: const VubaApp(),
    ),
  );
}

class VubaApp extends StatelessWidget {
  const VubaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      title: 'Pega Já',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.primary,
          surface: AppColors.surface,
          background: AppColors.background,
          error: AppColors.error,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.onSurface,
          onBackground: AppColors.onBackground,
          onError: Colors.white,
        ),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.onBackground,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonPrimary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.inputBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.inputBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.inputFocused,
              width: 2,
            ),
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return AppColors.primary;
            }
            return Colors.transparent;
          }),
          checkColor: MaterialStateProperty.all(Colors.white),
          side: const BorderSide(color: AppColors.inputBorder),
        ),
      ),
      home: const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/location-selection': (context) => const LocationSelectionPage(),
        '/map-location-picker': (context) => const MapLocationPickerPage(),
        '/location-details': (context) => const LocationDetailsPage(),
        '/store-front': (context) => StoreFrontPage(selectedLocationName: ''),
        '/prime': (context) => const PrimePage(),
        '/orders': (context) => const OrdersPage(),
        '/cart': (context) => const CartPage(),
        '/address-book': (context) => const AddressBookPage(),
        '/vuba-wallet': (context) => const VubaWalletPage(),
        '/rating-reviews': (context) => const RatingAndReviewsPage(),
        '/notification-settings': (context) => const NotificationSettingsPage(),
        '/messages': (context) => const MessagesPage(),
        '/about-us': (context) => const AboutUsPage(),
        '/more-options': (context) => const MoreOptionsPage(),
        '/personal-information': (context) => const PersonalInformationPage(),
        '/test-restaurants': (context) => const TestRestaurantsPage(),
      },
    );
  }
}

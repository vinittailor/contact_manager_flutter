import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/theme/app_theme.dart';
import 'app/routes/app_routes.dart';
import 'features/contacts/screens/home_screen.dart';
import 'features/contacts/screens/add_edit_contact_screen.dart';
import 'features/contacts/screens/contact_detail_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ContactManagerApp());
}

class ContactManagerApp extends StatelessWidget {
  const ContactManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Contact Manager',
      debugShowCheckedModeBanner: false,

      // ── Theming ──────────────────────────────────────────────────────
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // ── Initial Route ────────────────────────────────────────────────
      initialRoute: AppRoutes.home,

      // ── Route Pages ──────────────────────────────────────────────────
      getPages: [
        GetPage(
          name: AppRoutes.home,
          page: () => const HomeScreen(),
        ),
        GetPage(
          name: AppRoutes.addContact,
          page: () => const AddEditContactScreen(),
        ),
        GetPage(
          name: AppRoutes.editContact,
          page: () => const AddEditContactScreen(),
        ),
        GetPage(
          name: AppRoutes.contactDetail,
          page: () => const ContactDetailScreen(),
        ),
      ],
    );
  }
}

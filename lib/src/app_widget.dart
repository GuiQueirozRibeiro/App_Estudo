import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import 'feature/auth/usecase/auth_use_case.dart';
import 'feature/auth/viewmodel/auth_view_model.dart';
import 'feature/home/usecase/chat_notification_service.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LocalJsonLocalization.delegate.directories = ['lib/assets/i18n'];

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ChatNotificationService(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthUseCase(),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthViewModel(
            AuthUseCase(),
            context,
          ),
        ),
      ],
      child: MaterialApp.router(
        theme: ThemeData(
            fontFamily: 'Lato',
            colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: const Color(0xFF0096C7),
              secondary: Colors.orange.shade700,
              tertiary: Colors.white,
              outline: Colors.grey,
            )),
        debugShowCheckedModeBanner: false,
        scrollBehavior: AppScrollBehavior(),
        title: 'app_name'.i18n(),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          LocalJsonLocalization.delegate
        ],
        supportedLocales: const [
          Locale('pt', 'BR'),
          Locale('en', 'US'),
        ],
        routerConfig: Modular.routerConfig,
      ),
    );
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

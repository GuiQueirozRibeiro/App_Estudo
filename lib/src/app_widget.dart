import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import 'feature/auth/viewmodel/auth_view_model.dart';
import 'feature/home/repository/activity_list.dart';
import 'feature/home/repository/subject_list.dart';
import 'feature/home/repository/user_list.dart';
import 'feature/home/viewmodel/chat_view_model.dart';
import 'feature/onboarding/viewmodel/onboarding_view_model.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LocalJsonLocalization.delegate.directories = ['lib/assets/i18n'];

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => OnboardingViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(),
        ),
        ChangeNotifierProxyProvider<AuthViewModel, ChatViewModel>(
          create: (_) => ChatViewModel(),
          update: (ctx, auth, previous) {
            return ChatViewModel(
              auth.currentUser,
              previous?.chatList ?? [],
            );
          },
        ),
        ChangeNotifierProxyProvider<AuthViewModel, UserList>(
          create: (_) => UserList(),
          update: (ctx, auth, previous) {
            return UserList(
              auth.currentUser,
              previous?.showUserList ?? false,
              previous?.users ?? [],
            );
          },
        ),
        ChangeNotifierProxyProvider<AuthViewModel, SubjectList>(
          create: (_) => SubjectList(),
          update: (ctx, auth, previous) {
            return SubjectList(
              auth.currentUser,
              previous?.subjects ?? [],
            );
          },
        ),
        ChangeNotifierProxyProvider(
          create: (_) => ActivityList(),
          update: (ctx, auth, previous) {
            return ActivityList(
              previous?.activities ?? [],
            );
          },
        ),
      ],
      child: MaterialApp.router(
        theme: ThemeData(
          fontFamily: 'Lato',
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: const Color(0xFF012b5d),
            secondary: Colors.white,
            tertiary: const Color(0xFF0096c0),
            error: Colors.red,
            onError: Colors.green,
            outline: Colors.black,
            outlineVariant: Colors.grey,
            shadow: Colors.grey[300],
          ),
        ),
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

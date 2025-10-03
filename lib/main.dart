import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_p_c/components/font_style.dart';
import 'package:i_p_c/screens/properties_home_screen.dart';
import 'package:i_p_c/screens/login_screen.dart';
import 'package:i_p_c/screens/properties_detail_screen.dart';
import 'package:i_p_c/screens/settings_screen.dart';
import 'package:i_p_c/screens/signup_page.dart';
import 'bloc/inspection_bloc/inspection_bloc.dart';
import 'bloc/user_bloc/user_bloc.dart';
import 'model/inspection_detailes_model.dart';
import 'model/user_model.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => InspectionBloc()),
        BlocProvider(create: (context) => UserBloc()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GoRouter _router = GoRouter(
    routes: [
      // GoRoute(path: '/details/:id', builder: (context, state) {
      //   final id = state.params['id'];
      //   return DetailsPage(id: id);
      // }),
      GoRoute(path: '/', builder: (context, state) => LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => SignupPage()),
      GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
      GoRoute(path: '/settings' , builder: (context , state) => SettingsScreen()),
      GoRoute(
        path: '/details',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final inspection = extra?['inspection'] as Inspection?;
          final heroTag =
              (extra?['heroTag'] as String?) ??
              'inspection-${inspection?.inspectionId ?? 'unknown'}';
          if (inspection == null) {
            return const Scaffold(
              body: Center(child: Text('Missing inspection data')),
            );
          }
          return InspectionDetailsScreen(
            inspection: inspection,
            heroTag: heroTag,
          );
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    return MaterialApp.router(
      title: 'IPC',
      debugShowCheckedModeBanner: false,
      theme: theme,
      routerConfig: _router,
    );
  }
}

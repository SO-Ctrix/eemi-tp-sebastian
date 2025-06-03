import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/home_screen.dart';
import 'screens/add_product_screen.dart';
import 'screens/edit_product_screen.dart';

final GoRouter router = GoRouter(  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),    // Route de filtre supprimée car non essentielle
    GoRoute(
      path: '/add-product',
      builder: (context, state) => const AddProductScreen(),
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const AddProductScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end);
          final offsetAnimation = animation.drive(tween);
          
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    ),
    GoRoute(
      path: '/edit-product/:id',
      builder: (context, state) => EditProductScreen(
        productId: state.pathParameters['id']!,
      ),
      pageBuilder: (context, state) => CustomTransitionPage(
        child: EditProductScreen(
          productId: state.pathParameters['id']!,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end);
          final offsetAnimation = animation.drive(tween);
          
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    ),
  ],
  debugLogDiagnostics: true,
);

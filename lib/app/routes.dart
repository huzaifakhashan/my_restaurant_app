import 'package:flutter/material.dart';
import 'package:my_restaurant_app/screens/volunteer/tasks_screen.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/meals/meals_screen.dart';
import '../screens/reservations/reservations_screen.dart';
import '../screens/meals/add_meal_screen.dart';
import '../screens/meals/my_meals_screen.dart';
import '../screens/volunteer/volunteer_screen.dart';
import '../screens/donations/donations_screen.dart';
import '../screens/donations/my_donation_requests_screen.dart';
import '../screens/donations/add_donation_screen.dart';
import '../screens/donations/my_donations_screen.dart';
import '../screens/reservations/verify_reservation_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/notifications/notifications_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String meals = '/meals';
  static const String reservations = '/reservations';
  static const String addMeal = '/add-meal';
  static const String myMeals = '/my-meals';
  static const String volunteer = '/volunteer';
  static const String tasks = '/tasks';
  static const String donations = '/donations';
  static const String myDonationRequests = '/my-donation-requests';
  static const String verifyReservation = '/verify-reservation';
  static const String addDonation = '/add-donation';
  static const String myDonations = '/my-donations';
  static const String profile = '/profile';
  static const String notifications = '/notifications';
  static const String completedTasks = '/completed-tasks';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    home: (context) => const HomeScreen(),
    meals: (context) => const MealsScreen(),
    reservations: (context) => const ReservationsScreen(),
    addMeal: (context) => const AddMealScreen(),
    myMeals: (context) => const MyMealsScreen(),
    volunteer: (context) => const VolunteerScreen(),
    tasks: (context) => const TasksScreen(),
    donations: (context) => const DonationsScreen(),
    myDonationRequests: (context) => const MyDonationRequestsScreen(),
    verifyReservation: (context) => const VerifyReservationScreen(),
    addDonation: (context) => const AddDonationScreen(),
    myDonations: (context) => const MyDonationsScreen(),
    profile: (context) => const ProfileScreen(),
    notifications: (context) => const NotificationsScreen(),
    completedTasks: (context) => const TasksScreen(completedOnly: true),
  };
}

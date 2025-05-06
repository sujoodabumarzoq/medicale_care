import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:medicale_care/cubits/navigation_cubit.dart';
import 'package:medicale_care/cubits/speciality/specialty_cubit.dart';
import 'package:medicale_care/screens/auth/login_screen.dart';
import 'package:medicale_care/screens/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'cubits/appointment/appointment_cubit.dart';
// Cubits
import 'cubits/auth/auth_cubit.dart';
import 'cubits/doctor/doctor_cubit.dart';
import 'cubits/emergency/emergency_cubit.dart';
import 'cubits/patient/patient_cubit.dart';
import 'cubits/review/review_cubit.dart';
import 'repositories/appointment_repository.dart';
// Repositories
import 'repositories/auth_repository.dart';
import 'repositories/doctor_repository.dart';
import 'repositories/emergency_repository.dart';
import 'repositories/patient_repository.dart';
import 'repositories/review_repository.dart';
import 'repositories/specialty_repository.dart';

MaterialColor createMaterialColor(Color color) {
  List<double> strengths = <double>[.05, .1, .2, .3, .4, .5, .6, .7, .8, .9];
  Map<int, Color> swatch = {};
  final int r = color.r.toInt(), g = color.g.toInt(), b = color.b.toInt();

  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.toARGB32(), swatch);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variablesgit add .
  await dotenv.load(fileName: ".env");

  // Initialize Supabase يي
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize repositories
    final authRepository = AuthRepository();
    final doctorRepository = DoctorRepository();
    final patientRepository = PatientRepository();
    final specialtyRepository = SpecialtyRepository();
    final appointmentRepository = AppointmentRepository();
    final reviewRepository = ReviewRepository();
    final emergencyRepository = EmergencyRepository();

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(authRepository: authRepository),
        ),
        BlocProvider<DoctorCubit>(
          create: (context) => DoctorCubit(doctorRepository: doctorRepository),
        ),
        BlocProvider<SpecialtyCubit>(
          create: (context) => SpecialtyCubit(specialtyRepository: specialtyRepository),
        ),
        BlocProvider<AppointmentCubit>(
          create: (context) => AppointmentCubit(
            appointmentRepository: appointmentRepository,
            doctorRepository: doctorRepository,
          ),
        ),
        BlocProvider<ReviewCubit>(
          create: (context) => ReviewCubit(reviewRepository: reviewRepository),
        ),
        BlocProvider<EmergencyCubit>(
          create: (context) => EmergencyCubit(emergencyRepository: emergencyRepository),
        ),
        BlocProvider<PatientCubit>(
          create: (context) => PatientCubit(patientRepository: patientRepository),
        ),
        BlocProvider<NavigationCubit>(
          create: (_) => NavigationCubit(),
        ),
      ],
      child: MaterialApp(
        title: 'Medicale Care',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: false,
          primarySwatch: createMaterialColor(const Color(0xFF0266FF)),
          primaryColor: const Color(0xFF0266FF),
          scaffoldBackgroundColor: const Color(0xFFF5F7FB),
          fontFamily: 'Poppins',
          textTheme: const TextTheme(
            headlineLarge: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.w600,
              color: Color(0xFF222B45),
            ),
            headlineMedium: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
              color: Color(0xFF222B45),
            ),
            titleLarge: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              color: Color(0xFF222B45),
            ),
            titleMedium: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              color: Color(0xFF222B45),
            ),
            bodyLarge: TextStyle(
              fontSize: 16.0,
              color: Color(0xFF222B45),
            ),
            bodyMedium: TextStyle(
              fontSize: 14.0,
              color: Color(0xFF8F9BB3),
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF222B45),
            elevation: 0,
            centerTitle: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0266FF),
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF0266FF),
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
              ),
            ),
          ),
          cardTheme: CardTheme(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,


          ),
        ),
        home: const LoginScreen(),
      ),
    );
  }
}

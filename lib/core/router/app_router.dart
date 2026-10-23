import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/auth/login_screen.dart';
import '../widgets/home_shell.dart';
import '../../features/attendance/generate_qr_screen.dart';
import '../../features/attendance/scan_absen_screen.dart';
import '../../features/meeting/meeting_attendance_screen.dart';
import '../../features/student/student_class_detail_screen.dart';
import '../../features/student/class_group_students_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggingIn = state.uri.path == '/login';
      final status = authState.status;

      if (status == AuthStatus.initial) return null; // Still checking

      if (status == AuthStatus.unauthenticated && !isLoggingIn) {
        return '/login';
      }

      if (status == AuthStatus.authenticated) {
        if (isLoggingIn || state.uri.path == '/') {
          if (authState.role == 'DOSEN') {
            return '/dosen';
          } else {
            return '/admin';
          }
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dosen',
        builder: (context, state) => const DosenHomeShell(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminHomeShell(),
      ),
      GoRoute(
        path: '/generate-qr/:id',
        builder: (context, state) => GenerateQrScreen(scheduleId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/scan',
        builder: (context, state) => const ScanAbsenScreen(),
      ),
      GoRoute(
        path: '/meeting-attendance/:id',
        builder: (context, state) => MeetingAttendanceScreen(meetingId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/class-students/:id',
        builder: (context, state) => StudentClassDetailScreen(scheduleId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/student-class-detail/:id',
        builder: (context, state) => StudentClassDetailScreen(scheduleId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/class-group-students/:className/:semester',
        builder: (context, state) => ClassGroupStudentsScreen(
          className: state.pathParameters['className']!,
          semester: state.pathParameters['semester']!,
        ),
      ),
    ],
  );
});

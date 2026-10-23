import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../../features/schedule/dosen_schedule_screen.dart';
import '../../features/schedule/admin_schedule_screen.dart';
import '../../features/meeting/presensi_dosen_screen.dart';
import '../../features/student/admin_student_screen.dart';
import '../../features/leave/dosen_leave_screen.dart';
import '../../features/leave/admin_leave_screen.dart';
import '../../features/notification/notification_screen.dart';
import '../../features/notification/notification_provider.dart';
import '../../features/dashboard/admin_dashboard_screen.dart';
import '../../features/master_data/admin_master_screen.dart';

class DosenHomeShell extends ConsumerStatefulWidget {
  const DosenHomeShell({super.key});

  @override
  ConsumerState<DosenHomeShell> createState() => _DosenHomeShellState();
}

class _DosenHomeShellState extends ConsumerState<DosenHomeShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? AppColors.darkSurface : AppColors.surface;
    final activeColor = isDark ? AppColors.accent : AppColors.primary;
    final unselectedColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _buildBody(),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
          height: 68,
          decoration: BoxDecoration(
            color: navBg,
            borderRadius: BorderRadius.circular(34),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: activeColor.withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              elevation: 0,
              backgroundColor: Colors.transparent,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: activeColor,
              unselectedItemColor: unselectedColor,
              showSelectedLabels: true,
              showUnselectedLabels: false,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              items: [
                _buildNavItem(Icons.calendar_today_rounded, 'Jadwal', activeColor),
                _buildNavItem(Icons.qr_code_scanner_rounded, 'Presensi', activeColor),
                _buildNavItem(Icons.assignment_turned_in_rounded, 'Izin', activeColor),
                BottomNavigationBarItem(
                  icon: Badge(
                    label: Text('${ref.watch(unreadCountProvider)}'),
                    isLabelVisible: ref.watch(unreadCountProvider) > 0,
                    child: const Icon(Icons.notifications_rounded),
                  ),
                  activeIcon: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: activeColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Badge(
                      label: Text('${ref.watch(unreadCountProvider)}'),
                      isLabelVisible: ref.watch(unreadCountProvider) > 0,
                      child: Icon(Icons.notifications_rounded, color: activeColor),
                    ),
                  ),
                  label: 'Notif',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label, Color activeColor) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      activeIcon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: activeColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, color: activeColor),
      ),
      label: label,
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const DosenScheduleScreen();
      case 1:
        return const PresensiDosenScreen();
      case 2:
        return const DosenLeaveScreen();
      case 3:
        return const NotificationScreen();
      default:
        return const SizedBox.shrink();
    }
  }
}

class AdminHomeShell extends ConsumerStatefulWidget {
  const AdminHomeShell({super.key});

  @override
  ConsumerState<AdminHomeShell> createState() => _AdminHomeShellState();
}

class _AdminHomeShellState extends ConsumerState<AdminHomeShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? AppColors.darkSurface : AppColors.surface;
    final activeColor = isDark ? AppColors.accent : AppColors.primary;
    final unselectedColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _buildBody(),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          height: 68,
          decoration: BoxDecoration(
            color: navBg,
            borderRadius: BorderRadius.circular(34),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: activeColor.withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              elevation: 0,
              backgroundColor: Colors.transparent,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: activeColor,
              unselectedItemColor: unselectedColor,
              showSelectedLabels: true,
              showUnselectedLabels: false,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
              items: [
                _buildNavItem(Icons.space_dashboard_rounded, 'Dasbor', activeColor),
                _buildNavItem(Icons.calendar_today_rounded, 'Jadwal', activeColor),
                _buildNavItem(Icons.groups_rounded, 'Mhs', activeColor),
                _buildNavItem(Icons.dns_rounded, 'Master', activeColor),
                _buildNavItem(Icons.assignment_turned_in_rounded, 'Izin', activeColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label, Color activeColor) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      activeIcon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: activeColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, color: activeColor),
      ),
      label: label,
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const AdminDashboardScreen();
      case 1:
        return const AdminScheduleScreen();
      case 2:
        return const AdminStudentScreen();
      case 3:
        return const AdminMasterScreen();
      case 4:
        return const AdminLeaveScreen();
      default:
        return const SizedBox.shrink();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/auth_provider.dart';
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
    return Scaffold(
      extendBody: true, // Allows body to flow under the floating nav bar
      backgroundColor: const Color(0xFFF4F6F9),
      body: _buildBody(),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(35),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              elevation: 0,
              backgroundColor: Colors.transparent,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFF2E3192),
              unselectedItemColor: Colors.grey.shade400,
              showSelectedLabels: true,
              showUnselectedLabels: false,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              items: [
                _buildNavItem(Icons.dashboard_rounded, 'Jadwal', 0),
                _buildNavItem(Icons.qr_code_scanner_rounded, 'Presensi', 1),
                _buildNavItem(Icons.edit_document, 'Izin', 2),
                BottomNavigationBarItem(
                  icon: Badge(
                    label: Text('${ref.watch(unreadCountProvider)}'),
                    isLabelVisible: ref.watch(unreadCountProvider) > 0,
                    child: const Icon(Icons.notifications_rounded),
                  ),
                  activeIcon: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E3192).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Badge(
                      label: Text('${ref.watch(unreadCountProvider)}'),
                      isLabelVisible: ref.watch(unreadCountProvider) > 0,
                      child: const Icon(Icons.notifications_rounded),
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

  BottomNavigationBarItem _buildNavItem(IconData icon, String label, int index) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      activeIcon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2E3192).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon),
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
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF4F6F9),
      body: _buildBody(),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(35),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              elevation: 0,
              backgroundColor: Colors.transparent,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFF2E3192),
              unselectedItemColor: Colors.grey.shade400,
              showSelectedLabels: true,
              showUnselectedLabels: false,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              items: [
                _buildNavItem(Icons.dashboard_rounded, 'Dasbor'),
                _buildNavItem(Icons.schedule_rounded, 'Jadwal'),
                _buildNavItem(Icons.group_add_rounded, 'Mhs'),
                _buildNavItem(Icons.storage_rounded, 'Master'),
                _buildNavItem(Icons.edit_document, 'Izin'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      activeIcon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2E3192).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon),
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

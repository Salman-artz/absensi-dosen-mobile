import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../theme/app_colors.dart';

class ReportExporter {
  ReportExporter._();

  static Future<void> downloadAndOpenPdf({
    required BuildContext context,
    required Dio dio,
    required String scheduleId,
    required String courseName,
  }) async {
    final cleanName = courseName.replaceAll(RegExp(r'[^\w\s\-]'), '_').replaceAll(' ', '_');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mengunduh Laporan PDF...'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    try {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/Rekap_${cleanName}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      await dio.download('/reports/attendance/$scheduleId/pdf', filePath);

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF berhasil diunduh. Membuka dokumen...'),
            backgroundColor: AppColors.statusHadir,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      await OpenFilex.open(filePath);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Gagal mengunduh file';
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal unduh PDF: $msg'),
            backgroundColor: AppColors.statusAlpa,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka file: $e'),
            backgroundColor: AppColors.statusAlpa,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  static Future<void> downloadAndOpenExcel({
    required BuildContext context,
    required Dio dio,
    required String scheduleId,
    required String courseName,
  }) async {
    final cleanName = courseName.replaceAll(RegExp(r'[^\w\s\-]'), '_').replaceAll(' ', '_');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mengunduh Spreadsheet Excel (.xlsx)...'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    try {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/Rekap_${cleanName}_${DateTime.now().millisecondsSinceEpoch}.xlsx';

      await dio.download('/reports/attendance/$scheduleId/excel', filePath);

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Excel berhasil diunduh. Membuka dokumen...'),
            backgroundColor: AppColors.statusHadir,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      await OpenFilex.open(filePath);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Gagal mengunduh file';
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal unduh Excel: $msg'),
            backgroundColor: AppColors.statusAlpa,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka file: $e'),
            backgroundColor: AppColors.statusAlpa,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  static void showExportBottomSheet({
    required BuildContext context,
    required Dio dio,
    required String scheduleId,
    required String courseName,
    required String className,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Ekspor Rekapitulasi Presensi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$courseName ($className)',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // Option 1: PDF
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                  ),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.statusAlpa.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.statusAlpa, size: 24),
                ),
                title: Text(
                  'Laporan Rekap PDF',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'Format resmi siap cetak untuk pengarsipan',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
                trailing: const Icon(Icons.download_rounded, size: 20),
                onTap: () {
                  Navigator.pop(ctx);
                  downloadAndOpenPdf(
                    context: context,
                    dio: dio,
                    scheduleId: scheduleId,
                    courseName: '$courseName-$className',
                  );
                },
              ),
              const SizedBox(height: 12),

              // Option 2: Excel
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                  ),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.statusHadir.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.table_chart_rounded, color: AppColors.statusHadir, size: 24),
                ),
                title: Text(
                  'Spreadsheet Excel (.xlsx)',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'Format data tabular untuk rekap nilai & analisis',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
                trailing: const Icon(Icons.download_rounded, size: 20),
                onTap: () {
                  Navigator.pop(ctx);
                  downloadAndOpenExcel(
                    context: context,
                    dio: dio,
                    scheduleId: scheduleId,
                    courseName: '$courseName-$className',
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

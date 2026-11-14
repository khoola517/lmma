import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// نتيجة تقسيم القائمة إلى صفحة محددة مع حساب المؤشرات الآمنة.
class PaginationSlice<T> {
  final List<T> pageItems;
  final int totalFiltered;
  final int totalPages;
  final int safePage;
  final int startIndex;
  final int endIndex;

  const PaginationSlice({
    required this.pageItems,
    required this.totalFiltered,
    required this.totalPages,
    required this.safePage,
    required this.startIndex,
    required this.endIndex,
  });

  factory PaginationSlice.fromList(
    List<T> items, {
    required int currentPage,
    int itemsPerPage = 5,
  }) {
    final totalFiltered = items.length;
    final totalPages =
        totalFiltered == 0 ? 1 : ((totalFiltered - 1) ~/ itemsPerPage) + 1;
    final safePage = currentPage.clamp(1, totalPages);
    final startIndex = (safePage - 1) * itemsPerPage;
    final pageItems = items.skip(startIndex).take(itemsPerPage).toList();
    final endIndex = startIndex + pageItems.length;

    return PaginationSlice<T>(
      pageItems: pageItems,
      totalFiltered: totalFiltered,
      totalPages: totalPages,
      safePage: safePage,
      startIndex: startIndex,
      endIndex: endIndex,
    );
  }
}

/// شريط ترقيم الصفحات الموحد للجداول (5 صفوف لكل صفحة مع أرقام الصفحات).
class TablePaginationBar extends StatelessWidget {
  final PaginationSlice<dynamic> pagination;
  final String itemLabel;
  final ValueChanged<int> onPageChanged;

  const TablePaginationBar({
    super.key,
    required this.pagination,
    required this.itemLabel,
    required this.onPageChanged,
  });

  List<int?> _visiblePageNumbers() {
    final totalPages = pagination.totalPages;
    final safePage = pagination.safePage;

    if (totalPages <= 7) {
      return List<int?>.generate(totalPages, (i) => i + 1);
    }

    final pages = <int?>{1, totalPages};
    for (var p = safePage - 1; p <= safePage + 1; p++) {
      if (p > 1 && p < totalPages) pages.add(p);
    }
    if (safePage <= 3) {
      pages.addAll([2, 3, 4]);
    } else if (safePage >= totalPages - 2) {
      pages.addAll([totalPages - 3, totalPages - 2, totalPages - 1]);
    }

    final sorted = pages.whereType<int>().toList()..sort();
    final result = <int?>[];
    for (var i = 0; i < sorted.length; i++) {
      if (i > 0 && sorted[i] - sorted[i - 1] > 1) {
        result.add(null);
      }
      result.add(sorted[i]);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final visiblePages = _visiblePageNumbers();
    final totalFiltered = pagination.totalFiltered;
    final safePage = pagination.safePage;
    final totalPages = pagination.totalPages;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFFFCFAF7),
        border: Border(
          top: BorderSide(color: Color(0xFFEBE6DF)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              totalFiltered == 0
                  ? 'عرض 0 من إجمالي 0 $itemLabel'
                  : 'عرض ${pagination.startIndex + 1} - ${pagination.endIndex} من إجمالي $totalFiltered $itemLabel',
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8A7F84),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  onPressed:
                      safePage > 1 ? () => onPageChanged(safePage - 1) : null,
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'السابق',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: safePage > 1
                          ? const Color(0xFF4B5563)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                for (var i = 0; i < visiblePages.length; i++) ...[
                  if (visiblePages[i] == null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        '...',
                        style: GoogleFonts.cairo(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF8A7F84),
                        ),
                      ),
                    )
                  else
                    InkWell(
                      onTap: () => onPageChanged(visiblePages[i]!),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: safePage == visiblePages[i]
                              ? const Color(0xFFFCC201)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: safePage == visiblePages[i]
                                ? const Color(0xFFFCC201)
                                : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Text(
                          '${visiblePages[i]}',
                          style: GoogleFonts.cairo(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: safePage == visiblePages[i]
                                ? Colors.white
                                : const Color(0xFF4B5563),
                          ),
                        ),
                      ),
                    ),
                  if (i < visiblePages.length - 1) const SizedBox(width: 6),
                ],
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: safePage < totalPages
                      ? () => onPageChanged(safePage + 1)
                      : null,
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'التالي',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: safePage < totalPages
                          ? const Color(0xFF4B5563)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


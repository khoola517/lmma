import 'package:flutter/material.dart';

/// مكون موحد لعرض 4 كاردات إحصائية في صف أفقي واحد متناسق الحجم
class ProviderStatsRow extends StatelessWidget {
  final List<Widget> cards;
  final double minWidth;

  const ProviderStatsRow({
    super.key,
    required this.cards,
    this.minWidth = 860,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final row = Row(
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(width: 14),
              Expanded(child: cards[i]),
            ],
          ],
        );

        // إذا كانت المساحة المتوفرة كافية (860px فأعلى)، تظهر في صف واحد بالتساوي
        if (constraints.maxWidth >= minWidth) {
          return row;
        }

        // في الشاشات الضيقة، تظل في صف واحد أفقي قابل للتمرير دون أن تنكسر لصفين
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            width: minWidth,
            child: row,
          ),
        );
      },
    );
  }
}


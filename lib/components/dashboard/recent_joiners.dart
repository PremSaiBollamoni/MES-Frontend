import 'package:flutter/material.dart';
import '../../models/dashboard_summary.dart';
import '../../utils/theme_tokens.dart';

class RecentJoiners extends StatelessWidget {
  final List<RecentJoiner> joiners;
  const RecentJoiners({super.key, required this.joiners});

  String _formatDate(DateTime date) => "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 18, height: 2, color: ThemeTokens.primary),
            const SizedBox(width: 10.0),
            Text("RECENTLY JOINED", style: ThemeTokens.labelSmall),
          ],
        ),
        const SizedBox(height: 8.0),
        ...joiners.map((joiner) {
          return Container(
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: ThemeTokens.hairline))),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(ThemeTokens.radiusSmall),
                    border: Border.all(color: ThemeTokens.hairline),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    joiner.name.isNotEmpty ? joiner.name[0].toUpperCase() : "?",
                    style: ThemeTokens.headingMedium.copyWith(fontSize: 16, color: ThemeTokens.primary),
                  ),
                ),
                const SizedBox(width: 14.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(joiner.name, style: ThemeTokens.headingMedium.copyWith(fontSize: 15), overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2.0),
                      Text(
                        [joiner.employeeCode, if (joiner.department != null) joiner.department!].join('  ·  '),
                        style: ThemeTokens.caption,
                      ),
                    ],
                  ),
                ),
                Text(_formatDate(joiner.dateOfJoining), style: ThemeTokens.caption),
              ],
            ),
          );
        }),
      ],
    );
  }
}

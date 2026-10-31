import 'package:flutter/material.dart';
import '../models/payroll_preview.dart';
import '../utils/theme_tokens.dart';

/// Every operator's earnings for the generated date range, expandable to show exactly how
/// each figure was calculated (pieces x rate = earnings per operation) - lets HR verify the
/// numbers in the app before committing to a download.
class PayrollPreviewList extends StatelessWidget {
  final List<PayrollOperatorRow> rows;
  const PayrollPreviewList({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Column(children: rows.map((row) => _OperatorTile(row: row)).toList());
  }
}

class _OperatorTile extends StatelessWidget {
  final PayrollOperatorRow row;
  const _OperatorTile({required this.row});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      decoration: BoxDecoration(
        color: ThemeTokens.surfaceSolid,
        borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
        border: Border.all(color: ThemeTokens.hairline),
      ),
      // A solid-background Container directly parenting a ListTile-family widget (here,
      // ExpansionTile) hides its ink splashes without a Material in between - see the same
      // fix applied to SectionCard/station_assign_screen.
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          title: Text(row.operatorName, style: ThemeTokens.bodyLarge.copyWith(fontSize: 14.5)),
          subtitle: Text(
            '₹${row.totalEarnings.toStringAsFixed(2)} total',
            style: ThemeTokens.caption.copyWith(color: ThemeTokens.success, fontWeight: FontWeight.w600),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...row.operations.map((op) => _operationLine(op)),
            if (row.hasBankDetails) ...[
              const Padding(padding: EdgeInsets.symmetric(vertical: 6.0), child: Divider(height: 1)),
              _bankLine("Bank", row.bankName),
              _bankLine("Account No.", row.bankAccountNumber),
              _bankLine("IFSC", row.ifscCode),
            ],
          ],
        ),
      ),
    );
  }

  Widget _bankLine(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Text('$label: ', style: ThemeTokens.caption.copyWith(fontWeight: FontWeight.w600)),
          Text(value ?? '—', style: ThemeTokens.caption),
        ],
      ),
    );
  }

  Widget _operationLine(PayrollOperationLine op) {
    final label = op.isShared ? '${op.operationName} (shared by ${op.operatorCount})' : op.operationName;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: ThemeTokens.bodyMedium.copyWith(fontSize: 13))),
              Text(
                '${op.pieces} pcs × ₹${op.rate.toStringAsFixed(2)}${op.isShared ? ' ÷${op.operatorCount}' : ''} = ₹${op.earnings.toStringAsFixed(2)}',
                style: ThemeTokens.caption,
              ),
            ],
          ),
          Text('Logged by: ${op.loggedBy}', style: ThemeTokens.caption.copyWith(color: ThemeTokens.textLight)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/factory_detail.dart';
import '../utils/theme_tokens.dart';
import 'status_badge.dart';

/// Mirrors RoleCard's row-tile: ivory surface, hairline border, monogram square,
/// serif name, understated detail line.
class FactoryCard extends StatelessWidget {
  final FactoryDetail factory;
  final VoidCallback onTap;

  const FactoryCard({super.key, required this.factory, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
      child: InkWell(
        borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: ThemeTokens.surfaceSolid,
            borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
            border: Border.all(color: ThemeTokens.hairline),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: ThemeTokens.background,
                  borderRadius: BorderRadius.circular(ThemeTokens.radiusSmall),
                  border: Border.all(color: ThemeTokens.hairline),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.factory_rounded, size: 20, color: factory.active ? ThemeTokens.primary : ThemeTokens.textLight),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(factory.factoryName, style: ThemeTokens.headingMedium.copyWith(fontSize: 16), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4.0),
                    Text(
                      "${factory.factoryCode}${factory.location != null ? ' · ${factory.location}' : ''} · ${factory.hrmsEnabled ? 'HRMS on' : 'HRMS off'}",
                      style: ThemeTokens.caption,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12.0),
              StatusBadge(active: factory.active),
            ],
          ),
        ),
      ),
    );
  }
}

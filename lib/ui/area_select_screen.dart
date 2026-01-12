import 'package:flutter/material.dart';

import '../data/area_defs.dart';
import '../data/contract_defs.dart';
import '../data/ids.dart';

class AreaSelectScreen extends StatefulWidget {
  const AreaSelectScreen({
    super.key,
    required this.onAreaSelected,
    required this.onReturn,
  });

  static const String overlayKey = 'area_select_screen';

  final void Function(AreaDef area, List<ContractId> contracts) onAreaSelected;
  final VoidCallback onReturn;

  @override
  State<AreaSelectScreen> createState() => _AreaSelectScreenState();
}

class _AreaSelectScreenState extends State<AreaSelectScreen> {
  final Map<AreaId, Set<ContractId>> _selectedContractsByArea = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.black.withValues(alpha: 0.75),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select Area',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: areaDefs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final area = areaDefs[index];
                    final areaContracts = _contractsForArea(area);
                    final selectedContracts = _selectedContractsForArea(area);
                    final allowedContracts = areaContracts
                        .map((contract) => contract.id)
                        .toSet();
                    selectedContracts.removeWhere(
                      (id) => !allowedContracts.contains(id),
                    );
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111827),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            area.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            area.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 12,
                            runSpacing: 6,
                            children: [
                              _InfoChip(
                                label: 'Duration',
                                value: '${area.stageDuration}s',
                              ),
                              _InfoChip(
                                label: 'Recommended',
                                value: 'Lv ${area.recommendedLevel}',
                              ),
                              _InfoChip(label: 'Loot', value: area.lootProfile),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _InfoRow(
                            label: 'Difficulty',
                            value: area.difficultyTiers.join(' · '),
                          ),
                          const SizedBox(height: 6),
                          _InfoRow(
                            label: 'Enemies',
                            value: area.enemyThemes.isEmpty
                                ? 'Unknown'
                                : area.enemyThemes.join(' · '),
                          ),
                          if (area.lootModifiers.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            _InfoRow(
                              label: 'Loot Mods',
                              value: area.lootModifiers.join(' · '),
                            ),
                          ],
                          if (area.mapMutators.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            _InfoRow(
                              label: 'Mutators',
                              value: area.mapMutators.join(' · '),
                            ),
                          ],
                          const SizedBox(height: 6),
                          _InfoRow(
                            label: 'Contracts',
                            value: selectedContracts.isEmpty
                                ? 'None selected'
                                : _contractSummary(selectedContracts),
                            muted: selectedContracts.isEmpty,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              for (final contract in areaContracts)
                                Tooltip(
                                  message: contract.description,
                                  child: FilterChip(
                                    label: Text(
                                      '${contract.name} '
                                      '(+${contract.heat})',
                                    ),
                                    selected: selectedContracts.contains(
                                      contract.id,
                                    ),
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          selectedContracts.add(contract.id);
                                        } else {
                                          selectedContracts.remove(contract.id);
                                        }
                                      });
                                    },
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => widget.onAreaSelected(
                                area,
                                selectedContracts.toList(growable: false),
                              ),
                              child: const Text('Begin Stage'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: widget.onReturn,
                child: const Text('Return to Home Base'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $value',
        style: theme.textTheme.labelSmall?.copyWith(
          color: Colors.white70,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.muted = false,
  });

  final String label;
  final String value;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.labelMedium?.copyWith(
      color: muted ? Colors.white54 : Colors.white70,
      letterSpacing: 0.3,
    );
    return Row(
      children: [
        SizedBox(
          width: 92,
          child: Text(
            label.toUpperCase(),
            style: textStyle?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: textStyle)),
      ],
    );
  }
}

extension on _AreaSelectScreenState {
  Set<ContractId> _selectedContractsForArea(AreaDef area) {
    return _selectedContractsByArea.putIfAbsent(area.id, () => <ContractId>{});
  }

  List<ContractDef> _contractsForArea(AreaDef area) {
    if (area.contractPool.isEmpty) {
      return contractDefs;
    }
    final contracts = <ContractDef>[];
    for (final id in area.contractPool) {
      final def = contractDefsById[id];
      if (def != null) {
        contracts.add(def);
      }
    }
    return contracts;
  }

  String _contractSummary(Set<ContractId> contracts) {
    var heat = 0;
    var rewardMultiplier = 1.0;
    for (final id in contracts) {
      final def = contractDefsById[id];
      if (def == null) {
        continue;
      }
      heat += def.heat;
      rewardMultiplier *= def.rewardMultiplier;
    }
    return 'Heat $heat · Rewards x${rewardMultiplier.toStringAsFixed(2)}';
  }
}

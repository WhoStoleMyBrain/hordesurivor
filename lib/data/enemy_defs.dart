import 'ids.dart';
import 'tags.dart';

class EnemyDef {
  const EnemyDef({
    required this.id,
    required this.name,
    required this.description,
    required this.faction,
    required this.role,
    this.weight = 1,
  });

  final EnemyId id;
  final String name;
  final String description;
  final Faction faction;
  final EnemyRole role;
  final int weight;
}

const List<EnemyDef> enemyDefs = [
  EnemyDef(
    id: EnemyId.imp,
    name: 'Imp',
    description: 'Fast chaser with low health.',
    faction: Faction.demons,
    role: EnemyRole.chaser,
  ),
  EnemyDef(
    id: EnemyId.spitter,
    name: 'Spitter',
    description: 'Ranged attacker with imperfect aim.',
    faction: Faction.demons,
    role: EnemyRole.ranged,
  ),
  EnemyDef(
    id: EnemyId.portalKeeper,
    name: 'Portal Keeper',
    description: 'Summons imps until destroyed.',
    faction: Faction.demons,
    role: EnemyRole.spawner,
  ),
  EnemyDef(
    id: EnemyId.hexer,
    name: 'Hexer',
    description: 'Projects weakening curses and auras.',
    faction: Faction.demons,
    role: EnemyRole.disruptor,
  ),
  EnemyDef(
    id: EnemyId.brimstoneBrander,
    name: 'Brimstone Brander',
    description: 'Controls space with burning ground.',
    faction: Faction.demons,
    role: EnemyRole.zoner,
  ),
  EnemyDef(
    id: EnemyId.hellknight,
    name: 'Hellknight',
    description: 'Telegraphed dash with slam AOE.',
    faction: Faction.demons,
    role: EnemyRole.elite,
  ),
  EnemyDef(
    id: EnemyId.cinderling,
    name: 'Cinderling',
    description: 'Explodes on a timer or on death.',
    faction: Faction.demons,
    role: EnemyRole.exploder,
  ),
  EnemyDef(
    id: EnemyId.zealot,
    name: 'Zealot',
    description: 'Steady chaser with higher durability.',
    faction: Faction.angels,
    role: EnemyRole.chaser,
  ),
  EnemyDef(
    id: EnemyId.cherubArcher,
    name: 'Cherub Archer',
    description: 'Telegraphed volley pattern.',
    faction: Faction.angels,
    role: EnemyRole.ranged,
  ),
  EnemyDef(
    id: EnemyId.seraphMedic,
    name: 'Seraph Medic',
    description: 'Heals nearby allies with a beam.',
    faction: Faction.angels,
    role: EnemyRole.supportHealer,
  ),
  EnemyDef(
    id: EnemyId.herald,
    name: 'Herald',
    description: 'Buff aura for nearby allies.',
    faction: Faction.angels,
    role: EnemyRole.supportBuffer,
  ),
  EnemyDef(
    id: EnemyId.warden,
    name: 'Warden',
    description: 'Stationary hazard zones that deny space.',
    faction: Faction.angels,
    role: EnemyRole.zoner,
  ),
  EnemyDef(
    id: EnemyId.sentinel,
    name: 'Sentinel',
    description: 'Patrols in arcs with minimal tracking.',
    faction: Faction.angels,
    role: EnemyRole.pattern,
  ),
  EnemyDef(
    id: EnemyId.archonLancer,
    name: 'Archon Lancer',
    description: 'Telegraphed charge leaves a wind trail.',
    faction: Faction.angels,
    role: EnemyRole.elite,
  ),
];

final Map<EnemyId, EnemyDef> enemyDefsById = Map.unmodifiable({
  for (final def in enemyDefs) def.id: def,
});

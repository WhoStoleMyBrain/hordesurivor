enum SkillId {
  fireball,
  waterjet,
  oilBombs,
  swordThrust,
  swordCut,
  swordSwing,
  swordDeflect,
  poisonGas,
  roots,
  windCutter,
  steelShards,
  flameWave,
  frostNova,
  earthSpikes,
  sporeBurst,
  scrapRover,
  arcTurret,
  guardianOrbs,
  menderOrb,
  mineLayer,
}

enum SkillUpgradeId {
  fireballBlastCoating,
  fireballQuickFuse,
  waterjetPressureLine,
  waterjetSteadyStream,
  oilBombsExpandedPuddles,
  oilBombsHeavyPayload,
  swordThrustLongReach,
  swordThrustQuickStep,
  swordCutBroadArc,
  swordCutSharpenedEdge,
  swordSwingHeavyMomentum,
  swordSwingFlowingStrike,
  swordDeflectWiderParry,
  swordDeflectCountercut,
  poisonGasThickClouds,
  poisonGasVirulentFumes,
  rootsDeepBind,
  rootsTighteningGrasp,
}

enum StatusEffectId { slow, root, ignite, oilSoaked, vulnerable }

enum SynergyId { igniteOnOil, igniteOnRoot }

enum ItemId {
  glassCatalyst,
  heavyPlate,
  reinforcedPlating,
  featherBoots,
  overclockedTrigger,
  slowCooker,
  wideLens,
  sharpeningStone,
  focusingNozzle,
  volatileMixture,
  insulatedFlask,
  toxicFilters,
  briarCharm,
  ironGrip,
  vampiricSeal,
  luckyCoin,
  gamblersDie,
  reactiveShield,
  evasiveTalisman,
  ritualCandle,
  slickSoles,
  backpackOfGlass,
  thermalCoil,
  hydraulicStabilizer,
  sporeSatchel,
  gravelBoots,
  moltenBuckle,
  serratedEdge,
  mercyCharm,
}

enum ItemRarity { common, uncommon, rare, epic }

enum EnemyId {
  imp,
  spitter,
  portalKeeper,
  hexer,
  brimstoneBrander,
  hellknight,
  cinderling,
  zealot,
  cherubArcher,
  seraphMedic,
  herald,
  warden,
  sentinel,
  archonLancer,
}

enum AreaId { ashenOutskirts, haloBreach }

enum MetaUnlockId {
  fieldManual,
  extraReroll,
  extraChoice,
  reserveRerollCache,
  banishWrit,
  banishCodex,
  salvageProtocol,
  steelShardsLicense,
  thermalCoilBlueprint,
  sporeSatchelKit,
  flameWaveTechnique,
  hydraulicStabilizerPermit,
  gravelBootsPattern,
  sporeBurstCulture,
  frostNovaDiagram,
  moltenBuckleForge,
  serratedEdgeRecipe,
  mercyCharmVow,
  earthSpikesSurvey,
  infernalDisruptorDossier,
  infernalAnnihilatorDossier,
  celestialSupportAccords,
  celestialWardEdict,
  celestialVanguardWarrant,
  contractPrimer,
  contractEscalation,
  contractRadiantMandate,
}

enum ContractId {
  volleyPressure,
  eliteSurge,
  supportUplink,
  relentlessAdvance,
  coordinatedAssault,
  hardenedOnslaught,
  crossfireRush,
  siegeFormation,
  commandingPresence,
  vanguardVolley,
  radiantBarrage,
  radiantPursuit,
}

enum CurrencyId { xp, gold }

enum ProgressionTrackId { skills, items }

enum SelectionPoolId { skillPool, itemPool, futurePool }

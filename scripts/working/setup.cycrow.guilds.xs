SetVersion(17);
SetDescription("Guilds: Setup script");

$script.engine = getEngineVersion();

$page.id = 9620;
setGlobalData("pageid.guilds", $page.id);
loadText($page.id);

$read.text = readText($page.id, 99);
clientSetModNameDisplay($read.text);

$game.start.group = getGameStartGroupID();
if ($game.start.group == 100)
   return null;

if (scriptExists("plugin.manager.waretext"))
   START this->call("plugin.manager.waretext", $page.id);

this->call("plugin.guilds.loadconfig", FALSE);
$main.universe = this->call("plugin.guilds.utils", "mainUniverse", null, null);

START this->call("plugin.guilds.donoto");

$tasks = PLAYERSHIP->getAllRunningTasks();
if ($tasks)
{
   $i = arraySize($tasks);
   while ($i)
   {
      dec($i);
      $t = $tasks[$i];
      if (PLAYERSHIP->isScriptOnStack("plugin.cargobeam.start", $t))
         PLAYERSHIP->startScriptTask("!lib.interrupt", $t, 1000, null, null, null, null, null);
   }
}

// create guild data
$version = getScriptVersion();
$data = getGlobalData("guilds.data");
if not ($data)
{
   $data = tableAlloc();
   $data["version"] = $version;


// do one time init
   $sector = getSectorByCoord(22, 3);
   if ($sector->exists())
   {
      $flying.ware = SS_SH_K_M2;
      $main.type = getMainType($flying.ware);
      $sub.type = getSubtype($flying.ware);
      $flying.ware = createFlyingWare($main.type, $sub.type, 1, $sector, -21000, 7500, 40000, FALSE);
      $flying.ware->setFlyingWareBlueprint(TRUE);
      $flying.ware->setDiscovery(30000);
      $flying.ware->setInvincible(TRUE);
      wait(100);
      $flying.ware->playerSetLFLTarget(TRUE, 200000);
   }

   setGlobalData("guilds.data", $data);

// adjust pirate/yaki relations
   $array = getRaceShips(Pirates, OBJ_SHIP);
   gosub sub.NeutralRelation;
   $array = getRaceShips(Yaki, OBJ_SHIP);
   gosub sub.NeutralRelation;
   $array = getRaceStations(Pirates, OBJ_STATION);
   gosub sub.NeutralRelation;
   $array = getRaceStations(Yaki, OBJ_STATION);
   gosub sub.NeutralRelation;

   $table = tableAlloc();
   $table[SS_WARE_SPECIAL_DISCOVERY] = 100;
   $table[SS_WARE_R245] = 20;
   $table[SS_WARE_GLOWINGCRYSTAL] = 20;
   $table[SS_WARE_BLACKCRYSTAL] = 50;
   $table[SS_WARE_TRANSPCRYSTAL] = 100;
   $table[SS_WARE_YELLOWCRYSTAL] = 250;
   $table[SS_WARE_GREENCRYSTAL] = 500;
   $table[SS_WARE_BLUECRYSTAL] = 1000;
   $table[SS_WARE_REDCRYSTAL] = 2500;
   $table[SS_WARE_QUANTUMPR] = 30;
   $table[SS_WARE_FOCUSCR] = 30;
   START this->call("plugin.guilds.addtoasteroid", $table, FALSE, TRUE);

   START this->call("plugin.guilds.sectors", null, "init", null, null);

   $engine = getEngineVersion();
   if ($engine <= 70)
   {
      $tmp = "asteroid";
      START this->call("plugin.guilds.patch", $tmp, 5000);
   }

// check if the data is an older version
}
else
{
   $check.version = $data["version"];
   if ($version > $check.version)
   {
      $update.version = $check.version;
      while ($version > $update.version)
      {
         inc($update.version);
         this->call("plugin.guilds.patch", $update.version);
      }
      $data["version"] = $version;
   }
}

$guild.data = $data;
// Initilise the Guilds Data
START this->call("plugin.guilds.init", $data);

// Setup Repair Drones
upgradeAddCustomDrone(SS_WARE_REPAIRDRONE, SS_SH_REPAIR_DRONE, COMMAND_REPAIR_TARGET);
addMilitaryDockType(SS_DOCK_PI_MILITARY);
registerDroneCarrier(SS_SH_TR_LOST_M7D, SS_SH_TR_DRONE);

// Setup Races
raceAddFlags(Corporation2, RaceFlag::Inactive);
raceAddFlags(SpareRace2, RaceFlag::Inactive);
raceAddFlags(SpareRace1, RaceFlag::FixedNotority);
raceAddFlags(SpareRace1, RaceFlag::NPC);
raceAddFlags(SpareRace1, RaceFlag::Organised);
raceAddFlags(SpareRace1, RaceFlag::Piloted);
raceAddFlags(SpareRace1, RaceFlag::PilotSubrace);
raceAddFlags(SpareRace1, RaceFlag::HasEconomy);
raceRemoveFlags(SpareRace1, 2097152);
raceRemoveFlags(Beryll, 2097152);
raceAddFlags(Beryll, RaceFlag::NPC);
raceRemoveFlags(Industritech, 2097152);
raceAddFlags(Industritech, RaceFlag::NPC);
raceRemoveFlags(Corporation1, 2097152);
raceRemoveFlags(Corporation1, RaceFlag::Inactive);
raceAddFlags(Corporation1, RaceFlag::HasEconomy);
raceAddFlags(Corporation1, RaceFlag::NPC);
raceAddFlags(Corporation1, RaceFlag::Organised);
raceAddFlags(Corporation1, RaceFlag::TerranGroup);
$race = Corporation1;
$race->corpSetConnectedRace(Terran);
$race->corpSetSpeakerRace(Terran);
setNotoriety(SpareRace1, PlayerRace, Notoriety::Max);
setNotoriety(SpareRace1, Argon, Notoriety::Neutral);
setNotoriety(Argon, SpareRace1, Notoriety::Neutral);
setNotoriety(Corporation1, Terran, Notoriety::Max);
setNotoriety(Terran, Corporation1, Notoriety::Max);

raceSetWelcomeID(SpareRace1, 17001);
raceSetVoiceTextID(SpareRace1, 115);
raceSetWelcomeID(Corporation1, 17002);
raceSetVoiceTextID(Corporation1, 129);
raceSetRankPage(Corporation1, 842);

// Setup luxury wares
setWareFlags(SS_WARE_WINE, WareFlag::Luxury);
setWareFlags(SS_WARE_GAMES, WareFlag::Luxury);
setWareFlags(SS_WARE_MOTION, WareFlag::Luxury);
setWareFlags(SS_WARE_PMETALS, WareFlag::Luxury);
setWareFlags(SS_WARE_TOBACCO, WareFlag::Luxury);
setWareFlags(SS_WARE_CLOTHES, WareFlag::Luxury);
setWareFlags(SS_WARE_JEWELLERY, WareFlag::Luxury);
setWareFlags(SS_WARE_PC, WareFlag::Luxury);
setWareFlags(SS_WARE_SCULPTURE, WareFlag::Luxury);
setWareFlags(SS_WARE_PAINTING, WareFlag::Luxury);
setWareFlags(SS_WARE_TRANSLATE, WareFlag::Luxury);
setWareFlags(SS_WARE_MEDIC, WareFlag::Luxury);
setWareFlags(SS_WARE_SPORT, WareFlag::Luxury);
setWareFlags(SS_WARE_HOLO, WareFlag::Luxury);
setWareFlags(SS_WARE_LUXURYFOOD, WareFlag::Luxury);
setWareFlags(SS_WARE_DRUGS, WareFlag::Luxury);

// set illegal wares
$array = arrayCreateWithSize(2, SS_WARE_PRIESTPETAL, SS_WARE_DPACKAGE, null, null, null, null, null, null);
$i = arraySize($array);
while ($i)
{
   dec($i);
   $ware = $array[$i];
   setWareIllegal($ware, Argon, TRUE);
   setWareIllegal($ware, Boron, TRUE);
   setWareIllegal($ware, Split, TRUE);
   setWareIllegal($ware, Paranid, TRUE);
   setWareIllegal($ware, Teladi, TRUE);
   setWareIllegal($ware, Terran, TRUE);
   setWareIllegal($ware, Corporation1, TRUE);
   setWareIllegal($ware, OTAS, TRUE);
   setWareIllegal($ware, Atreus, TRUE);
   setWareIllegal($ware, NMMC, TRUE);
   setWareIllegal($ware, TerraCorp, TRUE);
   setWareIllegal($ware, Goner, TRUE);
   setWareIllegal($ware, Industritech, TRUE);
}

// setup equipment
$wareflags = WareFlag::Once | WareFlag::Equipment;
setWareFlags(SS_WARE_BOUNTYTRACK, $wareflags);
setWareFlags(SS_WARE_BOARDING_TELE, $wareflags);
setWareFlags(SS_WARE_MINERAL_ENH, $wareflags);
setWareFlags(SS_WARE_ADVJUMP_ACCEL, $wareflags);
setWareFlags(SS_WARE_ADVJUMP_FTL, $wareflags);
setWareFlags(SS_WARE_SHIELDBOOST, $wareflags);
$wareflags = WareFlag::Once | WareFlag::Equipment | WareFlag::NoPrice;
setWareFlags(SS_WARE_SECRETSCANNER, $wareflags);
$wareflags = WareFlag::Once | WareFlag::Equipment | WareFlag::Software;
setWareFlags(SS_WARE_CY_SCS, $wareflags);
setWareFlags(SS_WARE_DOCKING_EXT, $wareflags);
setWareFlags(SS_WARE_SW_TRADEEXT_2, $wareflags);
setWareFlags(SS_WARE_SW_TRADEEXT_3, $wareflags);
setWareFlags(SS_WARE_MERCNET, $wareflags);
setWareFlags(SS_WARE_SECRETSCANNER, $wareflags);
$wareflags = WareFlag::Once | WareFlag::Equipment | WareFlag::EquipmentVolume;
setWareFlags(SS_WARE_ESCAPECAP, $wareflags);
setWareFlags(SS_WARE_AUTOEJECT, $wareflags);
setWareFlags(SS_WARE_CAPT_CABIN, $wareflags);
setWareFlags(SS_WARE_CY_CARGOBEAM, $wareflags);
setWareFlags(SS_WARE_ADVJUMP_SOLAR, $wareflags);
setWareFlags(SS_WARE_ADVJUMP, $wareflags);
setWareFlags(SS_WARE_JD_ENERGY, $wareflags);
$wareflags = WareFlag::Equipment | WareFlag::EquipmentVolume;
setWareFlags(SS_WARE_CABIN_S, $wareflags);
setWareFlags(SS_WARE_CABIN_XL, $wareflags);
setWareFlags(SS_WARE_CABIN_F, $wareflags);
setWareFlags(SS_WARE_CABIN_L, $wareflags);
setWareFlags(SS_WARE_CABIN_M, $wareflags);
$wareflags = WareFlag::Equipment | WareFlag::EquipmentVolume | WareFlag::Dummy | WareFlag::NoEject | WareFlag::NoPrice | WareFlag::Permanant;
setWareFlags(SS_WARE_CABIN_S_O, $wareflags);
setWareFlags(SS_WARE_CABIN_XL_O, $wareflags);
setWareFlags(SS_WARE_CABIN_M_O, $wareflags);
setWareFlags(SS_WARE_CABIN_L_O, $wareflags);
setWareFlags(SS_WARE_CABIN_F_O, $wareflags);
$wareflags = WareFlag::Equipment | WareFlag::Once | WareFlag::NoEject | WareFlag::NoPrice | WareFlag::Permanant;
setWareFlags(SS_WARE_OVERTUNE, $wareflags);
setWareFlags(SS_WARE_OVERTUNE_IA, $wareflags);
setWareFlags(SS_WARE_OVERTUNE_POOR, $wareflags);
$wareflags = WareFlag::EquipmentPack | WareFlag::EquipmentVolume | WareFlag::Equipment;
setWareFlags(SS_WARE_PACK_PIRACY, $wareflags);
setWareFlags(SS_WARE_PACK_COMBAT, $wareflags);
setWareFlags(SS_WARE_PACK_GENERAL, $wareflags);
setWareFlags(SS_WARE_PACK_MINING, $wareflags);
setWareFlags(SS_WARE_PACK_TRADE, $wareflags);
setWareFlags(SS_WARE_ADVJUMP_KIT, $wareflags);
$wareflags = WareFlag::Player | WareFlag::Once | WareFlag::Equipment;
setWareFlags(SS_WARE_L_BOUNTY, $wareflags);
setWareFlags(SS_WARE_LFL_UPGRADE, $wareflags);
setWareFlags(SS_WARE_WORMHOLE_TRACK, $wareflags);
$wareflags = WareFlag::Permanant | WareFlag::Dummy | WareFlag::NoPrice | WareFlag::NoEject | WareFlag::Fluff;
setWareFlags(SS_WARE_DPACKAGE, $wareflags);
setWareFlags(SS_WARE_CRYSTALLINE, $wareflags);


$table = tableAlloc();
$table[SS_WARE_SW_PIRACY] = 1;
$table[SS_WARE_CY_SCS] = 1;
$table[SS_WARE_TECH276] = 1;
$table[SS_WARE_CY_CARGOBEAM] = 1;
addEquipmentPack(SS_WARE_PACK_PIRACY, $table);
$table = tableAlloc();
$table[SS_WARE_SW_FIGHT_1] = 1;
$table[SS_WARE_SW_FIGHT_2] = 1;
$table[SS_WARE_MISSILEDEF] = 1;
addEquipmentPack(SS_WARE_PACK_COMBAT, $table);
$table = tableAlloc();
$table[SS_WARE_TECH231] = 1;
$table[SS_WARE_SCANNER2] = 1;
$table[SS_WARE_SW_NAV_1] = 1;
$table[SS_WARE_SW_SPECIAL_1] = 1;
$table[SS_WARE_BOOST] = 1;
addEquipmentPack(SS_WARE_PACK_GENERAL, $table);
$table = tableAlloc();
$table[SS_WARE_SW_MINE] = 1;
$table[SS_WARE_TECH275] = 1;
$table[SS_WARE_SW_SPECIAL_1] = 1;
$table[SS_WARE_ORECOLLECTOR] = 1;
addEquipmentPack(SS_WARE_PACK_MINING, $table);
$table = tableAlloc();
$table[SS_WARE_TECH277] = 1;
$table[SS_WARE_SW_TRADE_1] = 1;
$table[SS_WARE_SW_TRADE_2] = 1;
$table[SS_WARE_SW_TRADEEXT_2] = 1;
$table[SS_WARE_BESTBUY] = 1;
$table[SS_WARE_BESTSELL] = 1;
addEquipmentPack(SS_WARE_PACK_TRADE, $table);
$table = tableAlloc();
$table[SS_WARE_ADVJUMP] = 1;
$table[SS_WARE_ADVJUMP_ACCEL] = 1;
$table[SS_WARE_SW_NAV_1] = 1;
addEquipmentPack(SS_WARE_ADVJUMP_KIT, $table);

wareSetInstallScript(SS_WARE_DOCKING_EXT, "plugin.guilds.dockingext", 20001);
wareSetInstallScript(SS_WARE_OVERTUNE, "plugin.guilds.overtune", 20002);
wareSetInstallScript(SS_WARE_ADVJUMP_SOLAR, "plugin.advjump.solar", 20003);
wareSetInstallScript(SS_WARE_SHIELDBOOST, "plugin.guilds.shieldboost.check", 20004);

wareAddDeployScript(SS_WARE_OWP_SMALL, "plugin.owp.deploy");
wareAddDeployScript(SS_WARE_OWP_MEDIUM, "plugin.owp.deploy");
wareAddDeployScript(SS_WARE_OWP_LARGE, "plugin.owp.deploy");

upgradeAddCustom(SS_WARE_SPYSAT, SS_SH_SPYSAT);


// setup weapons
laserAddRestriction(SS_LASER_KH_ALPHA, Khaak);
laserAddRestriction(SS_LASER_KH_BETA, Khaak);
laserAddRestriction(SS_LASER_KH_GAMMA, Khaak);
laserAddRestriction(SS_LASER_EMPE, ATF);
laserAddRestriction(SS_LASER_EMPE, Darkspace);
laserAddRestriction(SS_LASER_EMPE, Terran);
laserAddRestriction(SS_LASER_EMPE, Corporation1);
laserAddRestriction(SS_LASER_EMPE, Xenon);
laserAddRestriction(SS_LASER_TR_PC, ATF);
laserAddRestriction(SS_LASER_TR_PC, Terran);
laserAddRestriction(SS_LASER_TR_PC, Corporation1);
laserAddRestriction(SS_LASER_TR_PC, Darkspace);
laserAddRestriction(SS_LASER_TR_PC, SpareRace1);
laserAddRestriction(SS_LASER_FUSIONBEAM, ATF);
laserAddRestriction(SS_LASER_FUSIONBEAM, Terran);
laserAddRestriction(SS_LASER_FUSIONBEAM, Corporation1);
laserAddRestriction(SS_LASER_FUSIONBEAM, Darkspace);
laserAddRestriction(SS_LASER_FUSIONBEAM, StrongArms);
laserAddRestriction(SS_LASER_PBC, Argon);
laserAddRestriction(SS_LASER_PBC, Boron);
laserAddRestriction(SS_LASER_PBC, Pirates);
laserAddRestriction(SS_LASER_PBC, UnknownRace);
laserAddRestriction(SS_LASER_PBC, FriendRace);
laserAddRestriction(SS_LASER_PBC, Goner);
laserAddRestriction(SS_LASER_PBC, OTAS);
laserAddRestriction(SS_LASER_PBC, TerraCorp);
laserAddRestriction(SS_LASER_PBC, Atreus);
laserAddRestriction(SS_LASER_PBC, StrongArms);
laserAddRestriction(SS_LASER_PBC, Dukes);
laserAddRestriction(SS_LASER_TRIBEAM, Paranid);
laserAddRestriction(SS_LASER_TRIBEAM, Beryll);
laserAddRestriction(SS_LASER_TRIBEAM, Yaki);
laserAddRestriction(SS_LASER_TRIBEAM, Industritech);
laserAddRestriction(SS_LASER_TRIBEAM, Xenon);
laserAddRestriction(SS_LASER_TRIBEAM, StrongArms);
laserAddRestriction(SS_LASER_PAL, StrongArms);
laserAddRestriction(SS_LASER_PAL, Split);
laserAddRestriction(SS_LASER_PAL, UnknownRace);
laserAddRestriction(SS_LASER_PAL, Xenon);
laserAddRestriction(SS_LASER_PAL, Teladi);
laserAddRestriction(SS_LASER_PAL, NMMC);
laserAddRestriction(SS_LASER_PAL, SpareRace1);
laserAddRestriction(SS_LASER_EMRG, Corporation1);
laserAddRestriction(SS_LASER_EMRG, Terran);
laserAddRestriction(SS_LASER_EMRG, ATF);
laserAddRestriction(SS_LASER_EMRG, Darkspace);
laserAddRestriction(SS_LASER_IRE, Darkspace);
laserAddRestriction(SS_LASER_IRE, Xenon);
laserAddRestriction(SS_LASER_IRE, Argon);
laserAddRestriction(SS_LASER_IRE, Boron);
laserAddRestriction(SS_LASER_IRE, Split);
laserAddRestriction(SS_LASER_IRE, Paranid);
laserAddRestriction(SS_LASER_IRE, Teladi);
laserAddRestriction(SS_LASER_IRE, Pirates);
laserAddRestriction(SS_LASER_IRE, Goner);
laserAddRestriction(SS_LASER_IRE, PlayerRace);
laserAddRestriction(SS_LASER_IRE, FriendRace);
laserAddRestriction(SS_LASER_IRE, UnknownRace);
laserAddRestriction(SS_LASER_IRE, SpareRace1);
laserAddRestriction(SS_LASER_IRE, SpareRace2);
laserAddRestriction(SS_LASER_IRE, Yaki);
laserAddRestriction(SS_LASER_IRE, OTAS);
laserAddRestriction(SS_LASER_IRE, TerraCorp);
laserAddRestriction(SS_LASER_IRE, Atreus);
laserAddRestriction(SS_LASER_IRE, NMMC);
laserAddRestriction(SS_LASER_IRE, StrongArms);
laserAddRestriction(SS_LASER_IRE, Beryll);
laserAddRestriction(SS_LASER_IRE, Dukes);
laserAddRestriction(SS_LASER_IRE, Industritech);
laserAddRestriction(SS_LASER_IRE, Corporation1);
laserAddRestriction(SS_LASER_IRE, Corporation2);
laserAddRestriction(SS_LASER_GPE, Xenon);
laserAddRestriction(SS_LASER_GPE, Beryll);
laserAddRestriction(SS_LASER_FUBL, Teladi);
laserAddRestriction(SS_LASER_FUBL, Pirates);
laserAddRestriction(SS_LASER_HEPR, Xenon);
laserAddRestriction(SS_LASER_PPG, Paranid);
laserAddRestriction(SS_LASER_PPG, Industritech);
laserAddRestriction(SS_LASER_PPG, Beryll);
laserAddRestriction(SS_LASER_EMDA, Beryll);
laserAddRestriction(SS_LASER_EMDA, Paranid);
laserAddRestriction(SS_LASER_EMDA, Yaki);
laserAddRestriction(SS_LASER_DMBC, Xenon);
laserAddRestriction(SS_LASER_IONC, Boron);
laserAddRestriction(SS_LASER_IONC, OTAS);
laserAddRestriction(SS_LASER_IONC, Argon);
laserAddRestriction(SS_LASER_IONC, Atreus);
laserAddRestriction(SS_LASER_PBP, StrongArms);
laserAddRestriction(SS_LASER_PBP, Split);
laserAddRestriction(SS_LASER_PBP, SpareRace1);
laserAddRestriction(SS_LASER_QSC, Xenon);
laserAddRestriction(SS_LASER_PRG, Argon);
laserAddRestriction(SS_LASER_PRG, Boron);
laserAddRestriction(SS_LASER_PRG, Atreus);
laserAddRestriction(SS_LASER_PRG, SpareRace1);
laserAddRestriction(SS_LASER_PRG, OTAS);
laserAddRestriction(SS_LASER_PRG, TerraCorp);
laserAddRestriction(SS_LASER_PBE, Split);
laserAddRestriction(SS_LASER_PBE, StrongArms);
laserAddRestriction(SS_LASER_PBE, Yaki);
laserAddRestriction(SS_LASER_EMP, Terran);
laserAddRestriction(SS_LASER_EMP, Corporation1);
laserAddRestriction(SS_LASER_EMP, TerraCorp);
laserAddRestriction(SS_LASER_EMP, ATF);
laserAddRestriction(SS_LASER_EMP, Darkspace);
laserAddRestriction(SS_LASER_EMP, Xenon);
laserAddRestriction(SS_LASER_FBL, Paranid);
laserAddRestriction(SS_LASER_FBL, Industritech);
laserAddRestriction(SS_LASER_FBL, Beryll);
laserAddRestriction(SS_LASER_FBL, Yaki);
laserAddRestriction(SS_LASER_PD, Pirates);
laserAddRestriction(SS_LASER_PD, Dukes);
laserAddRestriction(SS_LASER_EBC, Teladi);
laserAddRestriction(SS_LASER_EBC, NMMC);
laserAddRestriction(SS_LASER_EBC, Pirates);
laserAddRestriction(SS_LASER_EBC, SpareRace1);

shipTypeSetMakerRace(SS_SH_CN_STARGAZER, Boron);
shipTypeSetMakerRace(SS_SH_CN_TP, Boron);
shipTypeSetMakerRace(SS_SH_MERC_M1, Pirates);
shipTypeSetMakerRace(SS_SH_MERC_M2, Pirates);
shipTypeSetMakerRace(SS_SH_MERC_M7, Pirates);
shipTypeSetMakerRace(SS_SH_MERC_M6, Pirates);
shipTypeSetMakerRace(SS_SH_MERC_M8, Pirates);
shipTypeSetMakerRace(SS_SH_MERC_M3, Pirates);
shipTypeSetMakerRace(SS_SH_MERC_M3P, Pirates);
shipTypeSetMakerRace(SS_SH_MERC_M4, Pirates);
shipTypeSetMakerRace(SS_SH_MERC_M5, Pirates);
shipTypeSetMakerRace(SS_SH_BH_M4, Split);
shipTypeSetMakerRace(SS_SH_BH_M3, Argon);
shipTypeSetMakerRace(SS_SH_AG_M4, Xenon);
shipTypeSetMakerRace(SS_SH_AG_M6, Xenon);
shipTypeSetMakerRace(SS_SH_AG_M1, Xenon);
shipTypeSetMakerRace(SS_SH_AG_M3, Xenon);
shipTypeSetSecondaryMakerRace(SS_SH_S_M3_ADV, Paranid);
shipTypeSetSecondaryMakerRace(SS_SH_CN_STARGAZER, Terran);
shipTypeSetSecondaryMakerRace(SS_SH_CN_TP, Paranid);
shipTypeSetSecondaryMakerRace(SS_SH_MERC_M1, Split);
shipTypeSetSecondaryMakerRace(SS_SH_MERC_M2, Split);
shipTypeSetSecondaryMakerRace(SS_SH_MERC_M7, Split);
shipTypeSetSecondaryMakerRace(SS_SH_MERC_M6, Split);
shipTypeSetSecondaryMakerRace(SS_SH_MERC_M8, Split);
shipTypeSetSecondaryMakerRace(SS_SH_MERC_M3, Split);
shipTypeSetSecondaryMakerRace(SS_SH_MERC_M3P, Split);
shipTypeSetSecondaryMakerRace(SS_SH_MERC_M4, Split);
shipTypeSetSecondaryMakerRace(SS_SH_MERC_M5, Split);
shipTypeSetSecondaryMakerRace(SS_SH_A_HYBRID, Terran);
shipTypeSetSecondaryMakerRace(SS_SH_PI_M3, Terran);
shipTypeSetSecondaryMakerRace(SS_SH_SA_M3, Terran);
shipTypeSetSecondaryMakerRace(SS_SH_SA_M3P, Terran);
shipTypeSetSecondaryMakerRace(SS_SH_FLAGSHIP, Argon);
shipTypeSetSecondaryMakerRace(SS_SH_A_M2P, Terran);
shipTypeSetSecondaryMakerRace(SS_SH_AG_M4, Split);
shipTypeSetSecondaryMakerRace(SS_SH_AG_M3, Argon);
shipTypeSetSecondaryMakerRace(SS_SH_AG_M6, Paranid);
shipTypeSetSecondaryMakerRace(SS_SH_AG_M1, Paranid);
shipTypeSetSecondaryMakerRace(SS_SH_AG_M1, Teladi);

// adjust sectors
$sector = getSectorByCoord(0, 15);
if ($sector->exists())
{
   $sector.owner = $sector->getOwner();
   if ($sector.owner == Boron)
   {
      $sector->setOwner(FriendRace);
      $read.text = readText($page.id, 304);
      $sector->setOverrideRaceName($read.text);
      $table = $sector->getStationsTable();
      if ($table)
      {
         $key = tableNext($table, null);
         while ($key)
         {
            $key->setOwner(FriendRace);
            $key = tableNext($table, $key);
         }
      }
   }
}

// add achivements
achRegister("bounty.guild.1", $page.id, 1182, TRUE);
achRegister("bounty.guild.2", $page.id, 1184, TRUE);
achRegister("beryll.plot.1", $page.id, 1000140, TRUE);
achRegister("assassin.guild.1", $page.id, 400039, TRUE);
achRegister("beryll.plot.cadet", $page.id, 1000177, TRUE);
achRegister("beryll.plot.2", $page.id, 1000179, TRUE);
achRegister("beryll.plot.3", $page.id, 1000181, TRUE);
achRegister("beryll.plot.4", $page.id, 1000183, TRUE);
achRegister("beryll.plot.5", $page.id, 1000185, TRUE);
achRegister("lost.colony", $page.id, 1100017, TRUE);

// add black market weapons
if ($script.engine >= 73)
{
   barterAddBlackWare(SS_LASER_KH_ALPHA, 2);
   barterAddBlackWare(SS_LASER_KH_BETA, 2);
   barterAddBlackWare(SS_LASER_KH_GAMMA, 1);
   barterAddBlackWare(SS_MISSILE_2, 5);
   barterAddBlackWare(SS_MISSILE_1, 5);
   barterAddBlackWare(SS_MISSILE_3, 5);
   barterAddBlackWare(SS_LASER_DMBC, 3);
   barterAddBlackWare(SS_LASER_GPE, 10);
   barterAddBlackWare(SS_LASER_QSC, 2);
   barterAddBlackWare(SS_WARE_ADVJUMP, 10);
   barterAddBlackWare(SS_WARE_BOARDING_TELE, 5);
   barterAddBlackWare(SS_WARE_CY_CARGOBEAM, 5);
   barterAddBlackWare(SS_WARE_ADVJUMP_ACCEL, 2);
   barterAddBlackWare(SS_WARE_DOCKING_EXT, 20);
   barterAddBlackWare(SS_WARE_AUTOEJECT, 10);
   barterAddBlackWare(SS_WARE_MINERAL_ENH, 4);
   barterAddBlackWare(SS_WARE_ESCAPECAP, 5);
   barterAddBlackWare(SS_LASER_HEPR, 5);
}

// add bbs articles
START this->call("plugin.bbs.init", $data);

// Start background tasks
START this->call("plugin.planets.run", FALSE);
START this->call("plugin.guilds.run", FALSE);
START this->call("plugin.bbs.run");
START this->call("plugin.logistics.run");

// Add Hotkeys
$key.id = registerMenuHotkey("plugin.boarding.tele", InputType::Upgrades, $page.id, 3000, TRUE, null);
$key.id = registerMenuHotkey("plugin.scs.claim", InputType::Upgrades, $page.id, 3081, TRUE, null);
$key.id = registerEventHotkey("plugin.cargobeam.hotkey", InputType::Upgrades, $page.id, 3030, null);
$key.id = registerMenuHotkey("plugin.advjump.hotkey", InputType::Menus, 7539, 37, TRUE, null);
$key.id = registerMenuHotkey("plugin.advjump.hotkey.target", InputType::Menus, 7539, 38, TRUE, null);
$key.id = registerMenuHotkey("plugin.guilds.hotkey.overtune", InputType::Upgrades, $page.id, 4030, TRUE, null);
$key.id = registerMenuHotkey("plugin.tradesys.wsearch.hotkey", InputType::Freight, 9616, 1, TRUE, null);
$key.id = registerMenuHotkey("plugin.guilds.shieldboost.hotkey", InputType::Upgrades, $page.id, 4190, TRUE, null);
$key.logistics = registerMenuHotkey("plugin.logistics.menu", InputType::Menus, $page.id, 4200, TRUE, null);
$data["key.logistics"] = $key.logistics;

$input.context = tableAlloc();
$data["input.context"] = $input.context;
$arr = arrayCreateWithSize(2, Hotkey::SectorMap, 537, null, null, null, null, null, null);
$context = inputAddContext("guilds.main", InputContext::Trade, $arr);
$input.context["guilds.main"] = $context;

$engine = getEngineVersion();
if ($engine >= 72)
{
   sidebarAddPersonalExt("weapon.browser", 63, $page.id, 3300, Sidebar::Empire, "plugin.guilds.wbrowser.menu");
   sidebarAddPersonalExt("cycrow.roverview", 122, $page.id, 3070, Sidebar::Empire, "plugin.roverview.menu");
   sidebarAddPersonalExt("guilds.masscc", 40, $page.id, 4100, Sidebar::Empire, "plugin.guilds.masscc.menu");
}
else
{
   sidebarAddPersonal("weapon.browser", 63, $page.id, 3300, "plugin.guilds.wbrowser.menu");
   sidebarAddPersonal("cycrow.roverview", 122, $page.id, 3070, "plugin.roverview.menu");
   sidebarAddPersonal("guilds.masscc", 40, $page.id, 4100, "plugin.guilds.masscc.menu");
}
sidebarAddPersonal("guilds.config", 65, $page.id, 109, "plugin.guilds.configmenu");
sidebarAddPersonal("loadout.manager", 153, $page.id, 3031, "plugin.loadoutm.mainmenu");
sidebarAddNavigation("guilds.soverview", 78, $page.id, 3400, "plugin.guilds.soverview.menu");
sidebarAddNavigation("adv.jump", 30, 2010, 226, "plugin.advjump.menu.event");
sidebarAddNavigation("ware.search", 7, 9616, 1, "plugin.tradesys.wsearch.hotkey");
sidebarAddPersonal("logistics", 17, $page.id, 4200, "plugin.logistics.menu");

// Add menus to context menus
objContextAdd("planet.econ", OBJ_DOCK, 59, $page.id, 1, "plugin.planets.info");
objContextAdd("guild.board", OBJ_DOCK, 40, $page.id, 100, "plugin.guilds.menu");
objContextAdd("guild.board.ship", OBJ_SHIP, 40, $page.id, 100, "plugin.guilds.menu");
objContextAdd("bbs", OBJ_DOCK, 4, $page.id, 123, "plugin.bbs.menu");
objContextAdd("guilds.cabin", OBJ_SHIP, 22, $page.id, 137, "plugin.guilds.cabinmenu");
objContextAdd("guilds.capt", OBJ_STATION, 42, $page.id, 138, "plugin.guilds.relax");
objContextAdd("guilds.wakeup", OBJ_STATION, 55, $page.id, 140, "plugin.guilds.relax");
objContextAdd("guilds.deepscan", OBJ_ASTEROID, 68, $page.id, 141, "plugin.guilds.deepscan.menu");
objContextAdd("cy.scs", OBJ_SHIP, 12, $page.id, 3086, "plugin.scs.objcontext");
objContextAdd("guild.cargohack", OBJ_SHIP_MOVEABLE, 23, $page.id, 151, "plugin.guilds.equipmentcontext");
objContextAdd("guild.overtune.on", OBJ_SHIP_MOVEABLE, 118, $page.id, 4031, "plugin.guilds.equipmentcontext");
objContextAdd("guild.overtune.off", OBJ_SHIP_MOVEABLE, 119, $page.id, 4032, "plugin.guilds.equipmentcontext");

commSetGlobal(OBJ_DOCK, null, "plugin.guilds.comm", TRUE);
commSetGlobal(OBJ_SHIP, null, "plugin.guilds.comm", TRUE);

addCustomCommand(9615, CmdMenu.Special);
addCustomCommand(9616, CmdMenu.Special);
addCustomCommand(9617, CmdMenu.Special);
addCustomCommand(9618, CmdMenu.Special);
addCustomCommand(9619, CmdMenu.Special);
addCustomCommand(9620, CmdMenu.Special);

removeGlobalCmdScript(COMMAND_TYPE_SHIP_36, OBJ_SHIP, PlayerRace);

setGlobalCmdScript(COMMAND_TYPE_PIRACY_20, "plugin.scs.cmd", 50, OBJ_SHIP_MOVEABLE, null);
setGlobalCmdScript(SHIPCOMMAND_9615, "plugin.shopping.cmd", 50, OBJ_SHIP_MOVEABLE, null);
setGlobalCmdScript(SHIPCOMMAND_9616, "plugin.tradesys.cmd.wsearch.pl", 50, OBJ_SHIP, PlayerRace);
setGlobalCmdScript(SHIPCOMMAND_9617, "plugin.tradesys.cmd.lanalyse.pl", 50, OBJ_SHIP, PlayerRace);
setGlobalCmdScript(COMMAND_TYPE_NAV_26, "plugin.advjump.cmd.jump", 10, OBJ_SHIP_MOVEABLE, null);
setGlobalCmdScript(COMMAND_TYPE_SHIP_36, "plugin.advjump.autojump", 10, OBJ_SHIP_MOVEABLE, PlayerRace);
setGlobalCmdScript(SHIPCOMMAND_9618, "plugin.guilds.docktend.std", 50, OBJ_SHIP_MOVEABLE, null);
setGlobalCmdScript(SHIPCOMMAND_9619, "plugin.tradesys.cmd.route.pl", 50, OBJ_SHIP, null);
removeGlobalCmdScript(SHIPCOMMAND_9620, OBJ_SHIP, null);

setShipCommandMenu(COMMAND_TYPE_PIRACY_20, "plugin.scs.cmd.menu", TRUE);
setShipCommandMenu(SHIPCOMMAND_9615, "plugin.shopping.cmd.menu", TRUE);
setShipCommandMenu(SHIPCOMMAND_9616, "plugin.tradesys.cmd.wsearch.menu", TRUE);
setShipCommandMenu(SHIPCOMMAND_9617, "plugin.tradesys.cmd.lanalyse.men", TRUE);
setShipCommandMenu(COMMAND_TYPE_NAV_26, "plugin.advjump.menu.event", TRUE);
setShipCommandMenu(SHIPCOMMAND_9618, "plugin.guilds.cmd.docktend.menu", TRUE);
setShipCommandMenu(SHIPCOMMAND_9619, "plugin.tradesys.cmd.route.menu", TRUE);

setCommandUpgradeScript(COMMAND_TYPE_PIRACY_20, SS_WARE_CY_SCS, "plugin.scs.cmd.check");
setCommandUpgrade(SHIPCOMMAND_9615, TRUE);
cmdAddAdditionalUpgrade(SHIPCOMMAND_9615, SS_WARE_SW_TRADE_2);
cmdAddAdditionalUpgrade(SHIPCOMMAND_9615, SS_WARE_SW_NAV_1);
setCommandUpgrade(SHIPCOMMAND_9616, TRUE);
cmdAddAdditionalUpgrade(SHIPCOMMAND_9616, SS_WARE_SW_TRADEEXT_2);
setCommandUpgrade(SHIPCOMMAND_9617, TRUE);
cmdAddAdditionalUpgrade(SHIPCOMMAND_9617, SS_WARE_SW_TRADEEXT_3);
setCommandUpgrade(COMMAND_TYPE_NAV_26, SS_WARE_SW_NAV_1);
setCommandUpgrade(COMMAND_TYPE_SHIP_36, SS_WARE_ADVJUMP);
setCommandUpgrade(SHIPCOMMAND_9618, TRUE);
cmdAddAdditionalUpgrade(SHIPCOMMAND_9618, SS_WARE_TECH277);
cmdAddAdditionalUpgrade(SHIPCOMMAND_9618, SS_WARE_SW_TRADE_1);
cmdAddAdditionalUpgrade(SHIPCOMMAND_9618, SS_WARE_SW_TRADE_2);
cmdAddRequirement(SHIPCOMMAND_9618, "dock.tend.1", $page.id, 4000);
setCommandUpgrade(SHIPCOMMAND_9619, TRUE);
cmdAddAdditionalUpgrade(SHIPCOMMAND_9619, SS_WARE_SW_TRADEEXT_3);

addGlobalSecondarySignal(SIGNAL_CREATED, null, OBJ_FACTORY, "plugin.guilds.signal.facbuild", 20, "guild.fac.build");
addGlobalSecondarySignal(SIGNAL_KILLED, null, OBJ_SHIP, "plugin.guilds.signal.kill", 100, "guild.ship.kill");
addGlobalSecondarySignal(SIGNAL_KILLED, null, OBJ_STATION, "plugin.guilds.signal.kill", 100, "guild.station.kill");
addGlobalSecondarySignal(SIGNAL_CHANGESECTOR, null, OBJ_SHIP, "plugin.guilds.signal.chsec", 100, "guild.chsec");
addGlobalSecondarySignal(SIGNAL_CREATED, null, OBJ_STATION, "plugin.guilds.signal.created", 90, "guilds.station.create");
addGlobalSecondarySignal(SIGNAL_CREATED, null, OBJ_SHIP, "plugin.guilds.signal.created", 90, "guilds.ship.create");

setWingCommandMenu(COMMAND_WING_TYPE_NAV_26, "plugin.advjump.menu.event", TRUE);

wingSetCommandUpgrade(COMMAND_WING_TYPE_NAV_26, SS_WARE_SW_NAV_1);

setWingGlobalCommandScript(COMMAND_WING_TYPE_NAV_26, PlayerRace, "plugin.advjump.cmd.wing", 50);

addScriptOptions("plugin.guilds.config.start", $page.id, 109);

godRegisterEvent("plugin.guilds.god.event", 100);
inputRegisterInfoScript("advjump.solar", OBJ_SHIP, "plugin.advjump.shipinfo");

diplomacySetCultureBonus(SpareRace1, 20, $page.id, 92000);
if not (diplomacyGetInfluence(PlayerRace, SpareRace1))
   diplomacySetInfluence(PlayerRace, SpareRace1, 0);

$table = $guild.data["diplomacy.cmd"];
if not ($table)
{
   $table = tableAlloc();
   $guild.data["diplomacy.cmd"] = $table;
}

if not ($table["claim.sector"])
{
   $id = setAgentCustomCommandMenu("plugin.guilds.dipl.claimsector.c", $page.id, 91000, "plugin.guilds.dipl.claimsector", TRUE, 2);
   START this->call("plugin.guilds.delayevent", "guilds.diplomacy.claimsector", PLAYERSHIP, $id, null, 10000);
   $table["claim.sector"] = $id;
}
if not ($table["examine.sector"])
{
   $id = setAgentCustomCommandMenu("plugin.guilds.dipl.examinesec", $page.id, 91003, "plugin.guilds.dipl.examinesec.m", TRUE, 1);
   START this->call("plugin.guilds.delayevent", "guilds.diplomacy.examinesector", PLAYERSHIP, $id, null, 10000);
   $table["examine.sector"] = $id;
}
if not ($table["drop.claim"])
{
   $id = setAgentCustomCommandMenu("plugin.guilds.dipl.dropclaim", $page.id, 91006, "plugin.guilds.dipl.dropclaim.m", TRUE, 5);
   $table["drop.claim"] = $id;
}
if not ($table["support.claim"])
{
   $id = setAgentCustomCommandMenu("plugin.guilds.dipl.claimsup", $page.id, 91009, "plugin.guilds.dipl.claimsup.m", TRUE, 3);
   $table["support.claim"] = $id;
}

// Casino Games
$page.id = 9611;
loadText($page.id);
setGlobalData("cycrow.casino.pageid", $page.id);
commSetGlobal(OBJ_SHIP, null, "plugin.casino.comm", TRUE);
// Boarding
$page.id = 9604;
setGlobalData("pageid.boarding", $page.id);
// Trade Sys
$page.id = 9616;
loadText($page.id);
setGlobalData("pageid.tradesys", $page.id);
// Advanced Jumpdrive
$page.id = 7539;
setGlobalData("advjump.pageid", $page.id);

// =====================
return null;


sub.NeutralRelation:
if ($array)
{
   $i = arraySize($array);
   while ($i)
   {
      dec($i);
      $obj = $array[$i];
      if ($obj->exists())
      {
         if (PLAYERSHIP->exists())
            $obj->setRelation(PLAYERSHIP, Relation.Neutral);
         $obj->setRelation(PlayerRace, Relation.Neutral);
      }
   }
}
endsub ;

return null;

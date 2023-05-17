

 /**
 * =============================================================================
 * Ready Up - RPG By Michael toth
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 */

#define NICK_MODEL				"models/survivors/survivor_gambler.mdl"
#define ROCHELLE_MODEL			"models/survivors/survivor_producer.mdl"
#define COACH_MODEL				"models/survivors/survivor_coach.mdl"
#define ELLIS_MODEL				"models/survivors/survivor_mechanic.mdl"
#define ZOEY_MODEL				"models/survivors/survivor_teenangst.mdl"
#define FRANCIS_MODEL			"models/survivors/survivor_biker.mdl"
#define LOUIS_MODEL				"models/survivors/survivor_manager.mdl"
#define BILL_MODEL				"models/survivors/survivor_namvet.mdl"
#define TEAM_SPECTATOR		1
#define TEAM_SURVIVOR		2
#define TEAM_INFECTED		3
#define MAX_ENTITIES		2048
#define MAX_CHAT_LENGTH		1024
#define COOPRECORD_DB				"db_season_coop"
#define SURVRECORD_DB				"db_season_surv"
#define PLUGIN_VERSION				"v1.3.5"
#define CLASS_VERSION				"v1.0"
#define PROFILE_VERSION				"v1.3"
#define LOOT_VERSION				"v0.0"
#define PLUGIN_CONTACT				"skye"
#define PLUGIN_NAME					"RPG Construction Set"
#define PLUGIN_DESCRIPTION			"Fully-customizable and modular RPG, like the one for Atari."
#define CONFIG_EVENTS				"rpg/events.cfg"
#define CONFIG_MAINMENU				"rpg/mainmenu.cfg"
#define CONFIG_MENUTALENTS			"rpg/talentmenu.cfg"
#define CONFIG_POINTS				"rpg/points.cfg"
#define CONFIG_MAPRECORDS			"rpg/maprecords.cfg"
#define CONFIG_STORE				"rpg/store.cfg"
#define CONFIG_TRAILS				"rpg/trails.cfg"
#define CONFIG_CHATSETTINGS			"rpg/chatsettings.cfg"
#define CONFIG_PETS					"rpg/pets.cfg"
#define CONFIG_WEAPONS				"rpg/weapondamages.cfg"
#define CONFIG_COMMONAFFIXES		"rpg/commonaffixes.cfg"
#define LOGFILE						"rum_rpg.txt"
#define JETPACK_AUDIO				"ambient/gas/steam2.wav"
//	=================================
#define DEBUG     				false
//	=================================
#define CVAR_SHOW			FCVAR_NOTIFY
#define DMG_HEADSHOT		2147483648
#define ZOMBIECLASS_SMOKER											1
#define ZOMBIECLASS_BOOMER											2
#define ZOMBIECLASS_HUNTER											3
#define ZOMBIECLASS_SPITTER											4
#define ZOMBIECLASS_JOCKEY											5
#define ZOMBIECLASS_CHARGER											6
#define ZOMBIECLASS_WITCH											7
#define ZOMBIECLASS_TANK											8
#define ZOMBIECLASS_SURVIVOR										0
#define TANKSTATE_TIRED												0
#define TANKSTATE_REFLECT											1
#define TANKSTATE_FIRE												2
#define TANKSTATE_DEATH												3
#define TANKSTATE_TELEPORT											4
#define TANKSTATE_HULK												5
#define EFFECTOVERTIME_ACTIVATETALENT	0
#define EFFECTOVERTIME_GETACTIVETIME	1
#define EFFECTOVERTIME_GETCOOLDOWN		2
#define DMG_SPITTERACID1 263168
#define DMG_SPITTERACID2 265216
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <smlib>
#include "wrap.inc"
#include <left4dhooks>
#include "l4d_stocks.inc"
#undef REQUIRE_PLUGIN
#include <readyup>
#define REQUIRE_PLUGIN


#pragma newdecls required

public Plugin myinfo = {
	name = PLUGIN_NAME,
	author = PLUGIN_CONTACT,
	description = PLUGIN_DESCRIPTION,
	version = PLUGIN_VERSION,
	url = "",
};
// trying to make it a bit easier to read...
// for the talentmenu.cfg
#define ABILITY_TYPE						0
#define COMPOUNDING_TALENT					1
#define COMPOUND_WITH						2
#define ACTIVATOR_ABILITY_EFFECTS			3
#define TARGET_ABILITY_EFFECTS				4
#define SECONDARY_EFFECTS					5
#define WEAPONS_PERMITTED					6
#define HEALTH_PERCENTAGE_REQ				7
#define COHERENCY_RANGE						8
#define COHERENCY_MAX						9
#define COHERENCY_REQ						10
#define HEALTH_PERCENTAGE_REQ_TAR_REMAINING	11
#define HEALTH_PERCENTAGE_REQ_TAR_MISSING	12
#define ACTIVATOR_TEAM_REQ					13
#define ACTIVATOR_CLASS_REQ					14
#define REQUIRES_ZOOM						15
#define COMBAT_STATE_REQ					16
#define PLAYER_STATE_REQ					17
#define PASSIVE_ABILITY						18
#define REQUIRES_HEADSHOT					19
#define REQUIRES_LIMBSHOT					20
#define REQUIRES_CROUCHING					21
#define ACTIVATOR_STAGGER_REQ				22
#define TARGET_STAGGER_REQ					23
#define CANNOT_TARGET_SELF					24
#define MUST_BE_JUMPING_OR_FLYING			25
#define VOMIT_STATE_REQ_ACTIVATOR			26
#define VOMIT_STATE_REQ_TARGET				27
#define REQ_ADRENALINE_EFFECT				28
#define DISABLE_IF_WEAKNESS					29
#define REQ_WEAKNESS						30
#define TARGET_CLASS_REQ					31
#define CLEANSE_TRIGGER						32
#define REQ_CONSECUTIVE_HITS				33
#define BACKGROUND_TALENT					34
#define STATUS_EFFECT_MULTIPLIER			35
#define MULTIPLY_RANGE						36
#define MULTIPLY_COMMONS					37
#define MULTIPLY_SUPERS						38
#define MULTIPLY_WITCHES					39
#define MULTIPLY_SURVIVORS					40
#define MULTIPLY_SPECIALS					41
#define STRENGTH_INCREASE_ZOOMED			42
#define STRENGTH_INCREASE_TIME_CAP			43
#define STRENGTH_INCREASE_TIME_REQ			44
#define ZOOM_TIME_HAS_MINIMUM_REQ			45
#define HOLDING_FIRE_STRENGTH_INCREASE		46
#define DAMAGE_TIME_HAS_MINIMUM_REQ			47
#define HEALTH_PERCENTAGE_REQ_MISSING		48
#define HEALTH_PERCENTAGE_REQ_MISSING_MAX	49
#define IS_OWN_TALENT						50
#define SECONDARY_ABILITY_TRIGGER			51
#define TARGET_IS_SELF						52
#define PRIMARY_AOE							53
#define SECONDARY_AOE						54
#define GET_TALENT_NAME						55
#define GET_TRANSLATION						56
#define GOVERNING_ATTRIBUTE					57
#define TALENT_TREE_CATEGORY				58
#define PART_OF_MENU_NAMED					59
#define GET_TALENT_LAYER					60
#define IS_TALENT_ABILITY					61
#define ACTION_BAR_NAME						62
#define NUM_TALENTS_REQ						63
#define TALENT_UPGRADE_STRENGTH_VALUE		64
#define TALENT_UPGRADE_SCALE				65
#define TALENT_COOLDOWN_STRENGTH_VALUE		66
#define TALENT_COOLDOWN_SCALE				67
#define TALENT_ACTIVE_STRENGTH_VALUE		68
#define TALENT_ACTIVE_SCALE					69
#define COOLDOWN_GOVERNOR_OF_TALENT			70
#define TALENT_STRENGTH_HARD_LIMIT			71
#define TALENT_IS_EFFECT_OVER_TIME			72
#define SPECIAL_AMMO_TALENT_STRENGTH		73
#define LAYER_COUNTING_IS_IGNORED			74
#define IS_ATTRIBUTE						75
#define HIDE_TRANSLATION					76
#define TALENT_ROLL_CHANCE					77
// spells
#define SPELL_INTERVAL_PER_POINT			78
#define SPELL_INTERVAL_FIRST_POINT			79
#define SPELL_RANGE_PER_POINT				80
#define SPELL_RANGE_FIRST_POINT				81
#define SPELL_STAMINA_PER_POINT				82
#define SPELL_BASE_STAMINA_REQ				83
#define SPELL_COOLDOWN_PER_POINT			84
#define SPELL_COOLDOWN_FIRST_POINT			85
#define SPELL_COOLDOWN_START				86
#define SPELL_ACTIVE_TIME_PER_POINT			87
#define SPELL_ACTIVE_TIME_FIRST_POINT		88
#define SPELL_AMMO_EFFECT					89
#define SPELL_EFFECT_MULTIPLIER				90
// abilities
#define ABILITY_ACTIVE_EFFECT				91
#define ABILITY_PASSIVE_EFFECT				92
#define ABILITY_COOLDOWN_EFFECT				93
#define ABILITY_IS_REACTIVE					94
#define ABILITY_TEAMS_ALLOWED				95
#define ABILITY_COOLDOWN_STRENGTH			96
#define ABILITY_MAXIMUM_PASSIVE_MULTIPLIER	97
#define ABILITY_MAXIMUM_ACTIVE_MULTIPLIER	98
#define ABILITY_ACTIVE_STATE_ENSNARE_REQ	99
#define ABILITY_ACTIVE_STRENGTH				100
#define ABILITY_PASSIVE_IGNORES_COOLDOWN	101
#define ABILITY_PASSIVE_STATE_ENSNARE_REQ	102
#define ABILITY_PASSIVE_STRENGTH			103
#define ABILITY_PASSIVE_ONLY				104
#define ABILITY_IS_SINGLE_TARGET			105
#define ABILITY_DRAW_DELAY					106
#define ABILITY_ACTIVE_DRAW_DELAY			107
#define ABILITY_PASSIVE_DRAW_DELAY			108
#define ATTRIBUTE_MULTIPLIER				109
#define ATTRIBUTE_USE_THESE_MULTIPLIERS		110
#define ATTRIBUTE_BASE_MULTIPLIER			111
#define ATTRIBUTE_DIMINISHING_MULTIPLIER	112
#define ATTRIBUTE_DIMINISHING_RETURNS		113
#define HUD_TEXT_BUFF_EFFECT_OVER_TIME		114
#define IS_SUB_MENU_OF_TALENTCONFIG			115
#define IS_TALENT_TYPE						116
#define ITEM_ITEM_ID						117
#define ITEM_RARITY							118
#define OLD_ATTRIBUTE_EXPERIENCE_START		119
#define OLD_ATTRIBUTE_EXPERIENCE_MULTIPLIER	120
#define IS_AURA_INSTEAD						121
#define EFFECT_COOLDOWN_TRIGGER				122
#define EFFECT_INACTIVE_TRIGGER				123
#define ABILITY_REACTIVE_TYPE				124
#define ABILITY_ACTIVE_TIME					125
#define ABILITY_REQ_NO_ENSNARE				126
#define ABILITY_SKY_LEVEL_REQ				127
#define ABILITY_TOGGLE_EFFECT				128
#define SPELL_HUMANOID_ONLY					129
#define SPELL_INANIMATE_ONLY				130
#define SPELL_ALLOW_COMMONS					131
#define SPELL_ALLOW_SPECIALS				132
#define SPELL_ALLOW_SURVIVORS				133
#define ABILITY_COOLDOWN					134
#define EFFECT_ACTIVATE_PER_TICK			135
#define EFFECT_SECONDARY_EPT_ONLY			136
#define ABILITY_ACTIVE_END_ABILITY_TRIGGER	137
#define ABILITY_COOLDOWN_END_TRIGGER		138
#define ABILITY_DOES_DAMAGE					139
#define TALENT_IS_SPELL						140
#define TALENT_MINIMUM_LEVEL_REQ			141
#define ABILITY_TOGGLE_STRENGTH				142
#define TARGET_AND_LAST_TARGET_CLASS_MATCH	143
#define TARGET_RANGE_REQUIRED				144
#define TARGET_RANGE_REQUIRED_OUTSIDE		145
#define TARGET_MUST_BE_LAST_TARGET			146
#define ACTIVATOR_MUST_BE_ON_FIRE			147
#define ACTIVATOR_MUST_SUFFER_ACID_BURN		148
#define ACTIVATOR_MUST_BE_EXPLODING			149
#define ACTIVATOR_MUST_BE_SLOW				150
#define ACTIVATOR_MUST_BE_FROZEN			151
#define ACTIVATOR_MUST_BE_SCORCHED			152
#define ACTIVATOR_MUST_BE_STEAMING			153
#define ACTIVATOR_MUST_BE_DROWNING			154
#define ACTIVATOR_MUST_HAVE_HIGH_GROUND		155
#define TARGET_MUST_HAVE_HIGH_GROUND		156
#define ACTIVATOR_TARGET_MUST_EVEN_GROUND	157
#define TARGET_MUST_BE_IN_THE_AIR			158
#define ABILITY_EVENT_TYPE					159
// because this value changes when we increase the list of key positions
// we should create a reference for the IsAbilityFound method, so that it doesn't waste time checking keys that we know aren't equal.
#define TALENT_FIRST_RANDOM_KEY_POSITION	160
// for super commons.
#define SUPER_COMMON_MAX_ALLOWED			0
#define SUPER_COMMON_AURA_EFFECT			1
#define SUPER_COMMON_RANGE_MIN				2
#define SUPER_COMMON_RANGE_PLAYER_LEVEL		3
#define SUPER_COMMON_RANGE_MAX				4
#define SUPER_COMMON_COOLDOWN				5
#define SUPER_COMMON_AURA_STRENGTH			6
#define SUPER_COMMON_STRENGTH_TARGET		7
#define SUPER_COMMON_LEVEL_STRENGTH			8
#define SUPER_COMMON_SPAWN_CHANCE			9
#define SUPER_COMMON_DRAW_TYPE				10
#define SUPER_COMMON_FIRE_IMMUNITY			11
#define SUPER_COMMON_MODEL_SIZE				12
#define SUPER_COMMON_GLOW					13
#define SUPER_COMMON_GLOW_RANGE				14
#define SUPER_COMMON_GLOW_COLOUR			15
#define SUPER_COMMON_BASE_HEALTH			16
#define SUPER_COMMON_HEALTH_PER_LEVEL		17
#define SUPER_COMMON_NAME					18
#define SUPER_COMMON_CHAIN_REACTION			19
#define SUPER_COMMON_DEATH_EFFECT			20
#define SUPER_COMMON_DEATH_BASE_TIME		21
#define SUPER_COMMON_DEATH_MAX_TIME			22
#define SUPER_COMMON_DEATH_INTERVAL			23
#define SUPER_COMMON_DEATH_MULTIPLIER		24
#define SUPER_COMMON_LEVEL_REQ				25
#define SUPER_COMMON_FORCE_MODEL			26
#define SUPER_COMMON_DAMAGE_EFFECT			27
#define SUPER_COMMON_ENEMY_MULTIPLICATION	28
#define SUPER_COMMON_ONFIRE_BASE_TIME		29
#define SUPER_COMMON_ONFIRE_LEVEL			30
#define SUPER_COMMON_ONFIRE_MAX_TIME		31
#define SUPER_COMMON_ONFIRE_INTERVAL		32
#define SUPER_COMMON_STRENGTH_SPECIAL		33
#define SUPER_COMMON_RAW_STRENGTH			34
#define SUPER_COMMON_RAW_COMMON_STRENGTH	35
#define SUPER_COMMON_RAW_PLAYER_STRENGTH	36
#define SUPER_COMMON_REQ_BILED_SURVIVORS	37

#define SUPER_COMMON_FIRST_RANDOM_KEY_POS	38

// for the events.cfg
#define EVENT_PERPETRATOR					0
#define EVENT_VICTIM						1
#define EVENT_SAMETEAM_TRIGGER				2
#define EVENT_PERPETRATOR_TEAM_REQ			3
#define EVENT_PERPETRATOR_ABILITY_TRIGGER	4
#define EVENT_VICTIM_TEAM_REQ				5
#define EVENT_VICTIM_ABILITY_TRIGGER		6
#define EVENT_DAMAGE_TYPE					7
#define EVENT_GET_HEALTH					8
#define EVENT_DAMAGE_AWARD					9
#define EVENT_GET_ABILITIES					10
#define EVENT_IS_PLAYER_NOW_IT				11
#define EVENT_IS_ORIGIN						12
#define EVENT_IS_DISTANCE					13
#define EVENT_MULTIPLIER_POINTS				14
#define EVENT_MULTIPLIER_EXPERIENCE			15
#define EVENT_IS_SHOVED						16
#define EVENT_IS_BULLET_IMPACT				17
#define EVENT_ENTERED_SAFEROOM				18


// Eyal282 here, adding things that appear missing.
char PathSetting[64];
int OriginalHealth[MAXPLAYERS + 1];
bool b_IsLoadingStore[MAXPLAYERS + 1];
int FreeUpgrades[MAXPLAYERS + 1];
bool b_IsLoadingTrees[MAXPLAYERS + 1];
bool b_IsArraysCreated[MAXPLAYERS + 1];
int PlayerUpgradesTotal[MAXPLAYERS + 1];
float f_TankCooldown;
float DeathLocation[MAXPLAYERS + 1][3];
int TimePlayed[MAXPLAYERS + 1];
bool b_IsLoading[MAXPLAYERS + 1];
int LastLivingSurvivor;
float f_OriginStart[MAXPLAYERS + 1][3];
float f_OriginEnd[MAXPLAYERS + 1][3];
int t_Distance[MAXPLAYERS + 1];
int t_Healing[MAXPLAYERS + 1];
bool b_IsActiveRound;
bool b_IsFirstPluginLoad;
char s_rup[32];
// End of Eyal282
char LastTargetClass[MAXPLAYERS + 1][10];
int iHealingPlayerInCombatPutInCombat;
ArrayList TimeOfEffectOverTime;
ArrayList EffectOverTime;
StringMap currentEquippedWeapon[MAXPLAYERS + 1];	// bullets fired from current weapon; variable needs to be renamed.
ArrayList GetCategoryStrengthKeys[MAXPLAYERS + 1];
ArrayList GetCategoryStrengthValues[MAXPLAYERS + 1];
ArrayList GetCategoryStrengthSection[MAXPLAYERS + 1];
bool bIsDebugEnabled = false;
int pistolXP[MAXPLAYERS + 1];
int meleeXP[MAXPLAYERS + 1];
int uziXP[MAXPLAYERS + 1];
int shotgunXP[MAXPLAYERS + 1];
int sniperXP[MAXPLAYERS + 1];
int assaultXP[MAXPLAYERS + 1];
int medicXP[MAXPLAYERS + 1];
int grenadeXP[MAXPLAYERS + 1];
float fProficiencyExperienceMultiplier;
float fProficiencyExperienceEarned;
//int iProficiencyMaxLevel;
int iProficiencyStart;
int iMaxIncap;
Handle hExecuteConfig = INVALID_HANDLE;
int iTanksPreset;
int ProgressEntity[MAXPLAYERS + 1];
//float fScoutBonus;
//float fTotemRating;
int iSurvivorRespawnRestrict;
bool bIsDefenderTank[MAXPLAYERS + 1];
float fOnFireDebuffDelay;
float fOnFireDebuff[MAXPLAYERS + 1];
//int iOnFireDebuffLimit;
int iSkyLevelMax;
int SkyLevel[MAXPLAYERS + 1];
int iIsSpecialFire;
int iIsRatingEnabled;
ArrayList hThreatSort;
bool bIsHideThreat[MAXPLAYERS + 1];
//float fTankThreatBonus;
int iTopThreat;
int iThreatLevel[MAXPLAYERS + 1];
int iThreatLevel_temp[MAXPLAYERS + 1];
ArrayList hThreatMeter;
int forceProfileOnNewPlayers;
bool bEquipSpells[MAXPLAYERS + 1];
ArrayList LoadoutConfigKeys[MAXPLAYERS + 1];
ArrayList LoadoutConfigValues[MAXPLAYERS + 1];
ArrayList LoadoutConfigSection[MAXPLAYERS + 1];
bool bIsGiveProfileItems[MAXPLAYERS + 1];
char sProfileLoadoutConfig[64];
int iIsWeaponLoadout[MAXPLAYERS + 1];
int iAwardBroadcast;
int iSurvivalCounter;
int iRestedDonator;
int iRestedRegular;
int iRestedSecondsRequired;
int iRestedMaximum;
int iFriendlyFire;
char sDonatorFlags[10];
float fDeathPenalty;
int iHardcoreMode;
int iDeathPenaltyPlayers;
ArrayList RoundStatistics;
bool bRushingNotified[MAXPLAYERS + 1];
bool bHasTeleported[MAXPLAYERS + 1];
bool IsAirborne[MAXPLAYERS + 1];
ArrayList RandomSurvivorClient;
int eBackpack[MAXPLAYERS + 1];
bool b_IsFinaleTanks;
char RatingType[64];
bool bJumpTime[MAXPLAYERS + 1];
float JumpTime[MAXPLAYERS + 1];
ArrayList AbilityConfigKeys[MAXPLAYERS + 1];
ArrayList AbilityConfigValues[MAXPLAYERS + 1];
ArrayList AbilityConfigSection[MAXPLAYERS + 1];
bool IsGroupMember[MAXPLAYERS + 1];
int IsGroupMemberTime[MAXPLAYERS + 1];
ArrayList GetAbilityKeys[MAXPLAYERS + 1];
ArrayList GetAbilityValues[MAXPLAYERS + 1];
ArrayList GetAbilitySection[MAXPLAYERS + 1];
ArrayList IsAbilityKeys[MAXPLAYERS + 1];
ArrayList IsAbilityValues[MAXPLAYERS + 1];
ArrayList IsAbilitySection[MAXPLAYERS + 1];
bool bIsSprinting[MAXPLAYERS + 1];
ArrayList CheckAbilityKeys[MAXPLAYERS + 1];
ArrayList CheckAbilityValues[MAXPLAYERS + 1];
ArrayList CheckAbilitySection[MAXPLAYERS + 1];
int StrugglePower[MAXPLAYERS + 1];
ArrayList GetTalentStrengthKeys[MAXPLAYERS + 1];
ArrayList GetTalentStrengthValues[MAXPLAYERS + 1];
ArrayList CastKeys[MAXPLAYERS + 1];
ArrayList CastValues[MAXPLAYERS + 1];
ArrayList CastSection[MAXPLAYERS + 1];
int ActionBarSlot[MAXPLAYERS + 1];
ArrayList ActionBar[MAXPLAYERS + 1];
bool DisplayActionBar[MAXPLAYERS + 1];
int ConsecutiveHits[MAXPLAYERS + 1];
int MyVomitChase[MAXPLAYERS + 1];
float JetpackRecoveryTime[MAXPLAYERS + 1];
bool b_IsHooked[MAXPLAYERS + 1];
int IsPvP[MAXPLAYERS + 1];
bool bJetpack[MAXPLAYERS + 1];
//int ServerLevelRequirement;
ArrayList TalentsAssignedKeys[MAXPLAYERS + 1];
ArrayList TalentsAssignedValues[MAXPLAYERS + 1];
ArrayList CartelValueKeys[MAXPLAYERS + 1];
ArrayList CartelValueValues[MAXPLAYERS + 1];
int ReadyUpGameMode;
bool b_IsLoaded[MAXPLAYERS + 1];
bool LoadDelay[MAXPLAYERS + 1];
int LoadTarget[MAXPLAYERS + 1];
char CompanionNameQueue[MAXPLAYERS + 1][64];
bool HealImmunity[MAXPLAYERS + 1];
char Hostname[64];
char sHostname[64];
char ProfileLoadQueue[MAXPLAYERS + 1][64];
bool bIsSettingsCheck;
ArrayList SuperCommonQueue;
bool bIsCrushCooldown[MAXPLAYERS + 1];
bool bIsBurnCooldown[MAXPLAYERS + 1];
bool ISBILED[MAXPLAYERS + 1];
int Rating[MAXPLAYERS + 1];
float RoundExperienceMultiplier[MAXPLAYERS + 1];
int BonusContainer[MAXPLAYERS + 1];
int CurrentMapPosition;
int DoomTimer;
int CleanseStack[MAXPLAYERS + 1];
float CounterStack[MAXPLAYERS + 1];
int MultiplierStack[MAXPLAYERS + 1];
char BuildingStack[MAXPLAYERS + 1];
ArrayList TempAttributes[MAXPLAYERS + 1];
ArrayList TempTalents[MAXPLAYERS + 1];
ArrayList PlayerProfiles[MAXPLAYERS + 1];
char LoadoutName[MAXPLAYERS + 1][64];
bool b_IsSurvivalIntermission;
float ISDAZED[MAXPLAYERS + 1];
//float ExplodeTankTimer[MAXPLAYERS + 1];
int TankState[MAXPLAYERS + 1];
//int LastAttacker[MAXPLAYERS + 1];
bool b_IsFloating[MAXPLAYERS + 1];
float JumpPosition[MAXPLAYERS + 1][2][3];
float LastDeathTime[MAXPLAYERS + 1];
float SurvivorEnrage[MAXPLAYERS + 1][2];
bool bHasWeakness[MAXPLAYERS + 1];
int HexingContribution[MAXPLAYERS + 1];
int BuffingContribution[MAXPLAYERS + 1];
int HealingContribution[MAXPLAYERS + 1];
int TankingContribution[MAXPLAYERS + 1];
int CleansingContribution[MAXPLAYERS + 1];
float PointsContribution[MAXPLAYERS + 1];
int DamageContribution[MAXPLAYERS + 1];
float ExplosionCounter[MAXPLAYERS + 1][2];
ArrayList CoveredInVomit;
bool AmmoTriggerCooldown[MAXPLAYERS + 1];
ArrayList SpecialAmmoEffectKeys[MAXPLAYERS + 1];
ArrayList SpecialAmmoEffectValues[MAXPLAYERS + 1];
ArrayList ActiveAmmoCooldownKeys[MAXPLAYERS +1];
ArrayList ActiveAmmoCooldownValues[MAXPLAYERS + 1];
ArrayList PlayActiveAbilities[MAXPLAYERS + 1];
ArrayList PlayerActiveAmmo[MAXPLAYERS + 1];
ArrayList SpecialAmmoKeys[MAXPLAYERS + 1];
ArrayList SpecialAmmoValues[MAXPLAYERS + 1];
ArrayList SpecialAmmoSection[MAXPLAYERS + 1];
ArrayList DrawSpecialAmmoKeys[MAXPLAYERS + 1];
ArrayList DrawSpecialAmmoValues[MAXPLAYERS + 1];
ArrayList SpecialAmmoStrengthKeys[MAXPLAYERS + 1];
ArrayList SpecialAmmoStrengthValues[MAXPLAYERS + 1];
ArrayList WeaponLevel[MAXPLAYERS + 1];
ArrayList ExperienceBank[MAXPLAYERS + 1];
ArrayList MenuPosition[MAXPLAYERS + 1];
ArrayList IsClientInRangeSAKeys[MAXPLAYERS + 1];
ArrayList IsClientInRangeSAValues[MAXPLAYERS + 1];
ArrayList SpecialAmmoData;
ArrayList SpecialAmmoSave;
float MovementSpeed[MAXPLAYERS + 1];
int IsPlayerDebugMode[MAXPLAYERS + 1];
char ActiveSpecialAmmo[MAXPLAYERS + 1][64];
float IsSpecialAmmoEnabled[MAXPLAYERS + 1][4];
bool bIsInCombat[MAXPLAYERS + 1];
float CombatTime[MAXPLAYERS + 1];
ArrayList AKKeys[MAXPLAYERS + 1];
ArrayList AKValues[MAXPLAYERS + 1];
ArrayList AKSection[MAXPLAYERS + 1];
bool bIsSurvivorFatigue[MAXPLAYERS + 1];
int SurvivorStamina[MAXPLAYERS + 1];
float SurvivorConsumptionTime[MAXPLAYERS + 1];
float SurvivorStaminaTime[MAXPLAYERS + 1];
Handle ISSLOW[MAXPLAYERS + 1];
float fSlowSpeed[MAXPLAYERS + 1];
Handle ISFROZEN[MAXPLAYERS + 1];
float ISEXPLODETIME[MAXPLAYERS + 1];
Handle ISEXPLODE[MAXPLAYERS + 1];
Handle ISBLIND[MAXPLAYERS + 1];
ArrayList EntityOnFire;
ArrayList EntityOnFireName;
ArrayList CommonInfected;
ArrayList RCAffixes[MAXPLAYERS + 1];
ArrayList h_CommonKeys;
ArrayList h_CommonValues;
ArrayList SearchKey_Section;
ArrayList h_CAKeys;
ArrayList h_CAValues;
ArrayList CommonList;
ArrayList CommonAffixes;// the array holding the common entity id and the affix associated with the common infected. If multiple affixes, multiple keyvalues for the entity id will be created instead of multiple entries.
ArrayList a_CommonAffixes;			// the array holding the config data
int UpgradesAwarded[MAXPLAYERS + 1];
int UpgradesAvailable[MAXPLAYERS + 1];
ArrayList InfectedAuraKeys[MAXPLAYERS + 1];
ArrayList InfectedAuraValues[MAXPLAYERS + 1];
ArrayList InfectedAuraSection[MAXPLAYERS + 1];
bool b_IsDead[MAXPLAYERS + 1];
int ExperienceDebt[MAXPLAYERS + 1];
ArrayList TalentUpgradeKeys[MAXPLAYERS + 1];
ArrayList TalentUpgradeValues[MAXPLAYERS + 1];
ArrayList TalentUpgradeSection[MAXPLAYERS + 1];
ArrayList InfectedHealth[MAXPLAYERS + 1];
ArrayList SpecialCommon[MAXPLAYERS + 1];
ArrayList WitchList;
ArrayList WitchDamage[MAXPLAYERS + 1];
ArrayList Give_Store_Keys;
ArrayList Give_Store_Values;
ArrayList Give_Store_Section;
bool bIsMeleeCooldown[MAXPLAYERS + 1];
ArrayList a_WeaponDamages;
ArrayList MeleeKeys[MAXPLAYERS + 1];
ArrayList MeleeValues[MAXPLAYERS + 1];
ArrayList MeleeSection[MAXPLAYERS + 1];
char Public_LastChatUser[64];
char Infected_LastChatUser[64];
char Survivor_LastChatUser[64];
char Spectator_LastChatUser[64];
char currentCampaignName[64];
ArrayList h_KilledPosition_X[MAXPLAYERS + 1];
ArrayList h_KilledPosition_Y[MAXPLAYERS + 1];
ArrayList h_KilledPosition_Z[MAXPLAYERS + 1];
bool bIsEligibleMapAward[MAXPLAYERS + 1];
char ChatSettingsName[MAXPLAYERS + 1][64];
ArrayList a_ChatSettings;
ArrayList ChatSettings[MAXPLAYERS + 1];
bool b_ConfigsExecuted;
bool b_FirstLoad;
bool b_MapStart;
bool b_HardcoreMode[MAXPLAYERS + 1];
int PreviousRoundIncaps[MAXPLAYERS + 1];
int RoundIncaps[MAXPLAYERS + 1];
char CONFIG_MAIN[64];
bool b_IsCampaignComplete;
bool b_IsRoundIsOver;
int RatingHandicap[MAXPLAYERS + 1];
bool bIsHandicapLocked[MAXPLAYERS + 1];
bool b_IsCheckpointDoorStartOpened;
int resr[MAXPLAYERS + 1];
int LastPlayLength[MAXPLAYERS + 1];
int RestedExperience[MAXPLAYERS + 1];
int MapRoundsPlayed;
char LastSpoken[MAXPLAYERS + 1][512];
ArrayList RPGMenuPosition[MAXPLAYERS + 1];
bool b_IsInSaferoom[MAXPLAYERS + 1];
Database hDatabase;
char ConfigPathDirectory[64];
char LogPathDirectory[64];
char PurchaseTalentName[MAXPLAYERS + 1][64];
int PurchaseTalentPoints[MAXPLAYERS + 1];
ArrayList a_Trails;
ArrayList TrailsKeys[MAXPLAYERS + 1];
ArrayList TrailsValues[MAXPLAYERS + 1];
bool b_IsFinaleActive;
int RoundDamage[MAXPLAYERS + 1];
// Eyal282 here. Warnings are evil.
//int RoundDamageTotal;
int SpecialsKilled;
ArrayList LockedTalentKeys;
ArrayList LockedTalentValues;
ArrayList LockedTalentSection;
ArrayList MOTKeys[MAXPLAYERS + 1];
ArrayList MOTValues[MAXPLAYERS + 1];
ArrayList MOTSection[MAXPLAYERS + 1];
ArrayList DamageKeys[MAXPLAYERS + 1];
ArrayList DamageValues[MAXPLAYERS + 1];
ArrayList DamageSection[MAXPLAYERS + 1];
ArrayList BoosterKeys[MAXPLAYERS + 1];
ArrayList BoosterValues[MAXPLAYERS + 1];
ArrayList StoreChanceKeys[MAXPLAYERS + 1];
ArrayList StoreChanceValues[MAXPLAYERS + 1];
ArrayList StoreItemNameSection[MAXPLAYERS + 1];
ArrayList StoreItemSection[MAXPLAYERS + 1];
ArrayList SaveSection[MAXPLAYERS + 1];
ArrayList LoadStoreSection[MAXPLAYERS + 1];
ArrayList StoreTimeKeys[MAXPLAYERS + 1];
ArrayList StoreTimeValues[MAXPLAYERS + 1];
ArrayList StoreKeys[MAXPLAYERS + 1];
ArrayList StoreValues[MAXPLAYERS + 1];
ArrayList StoreMultiplierKeys[MAXPLAYERS + 1];
ArrayList StoreMultiplierValues[MAXPLAYERS + 1];
ArrayList a_Store_Player[MAXPLAYERS + 1];
ArrayList a_Store;
ArrayList MainKeys;
ArrayList MainValues;
ArrayList a_Menu_Talents;
ArrayList a_Menu_Main;
ArrayList a_Events;
ArrayList a_Points;
ArrayList a_Pets;
ArrayList a_Database_Talents;
ArrayList a_Database_Talents_Defaults;
ArrayList a_Database_Talents_Defaults_Name;
ArrayList MenuKeys[MAXPLAYERS + 1];
ArrayList MenuValues[MAXPLAYERS + 1];
ArrayList MenuSection[MAXPLAYERS + 1];
ArrayList TriggerKeys[MAXPLAYERS + 1];
ArrayList TriggerValues[MAXPLAYERS + 1];
ArrayList TriggerSection[MAXPLAYERS + 1];
ArrayList AbilityKeys[MAXPLAYERS + 1];
ArrayList AbilityValues[MAXPLAYERS + 1];
ArrayList AbilitySection[MAXPLAYERS + 1];
ArrayList ChanceKeys[MAXPLAYERS + 1];
ArrayList ChanceValues[MAXPLAYERS + 1];
ArrayList ChanceSection[MAXPLAYERS + 1];
ArrayList PurchaseKeys[MAXPLAYERS + 1];
ArrayList PurchaseValues[MAXPLAYERS + 1];
ArrayList EventSection;
ArrayList HookSection;
ArrayList CallKeys;
ArrayList CallValues;
//ArrayList CallSection;
ArrayList DirectorKeys;
ArrayList DirectorValues;
//ArrayList DirectorSection;
ArrayList DatabaseKeys;
ArrayList DatabaseValues;
ArrayList DatabaseSection;
ArrayList a_Database_PlayerTalents_Bots;
ArrayList PlayerAbilitiesCooldown_Bots;
ArrayList PlayerAbilitiesImmune_Bots;
ArrayList BotSaveKeys;
ArrayList BotSaveValues;
ArrayList BotSaveSection;
ArrayList LoadDirectorSection;
ArrayList QueryDirectorKeys;
ArrayList QueryDirectorValues;
ArrayList QueryDirectorSection;
ArrayList FirstDirectorKeys;
ArrayList FirstDirectorValues;
ArrayList FirstDirectorSection;
ArrayList a_Database_PlayerTalents[MAXPLAYERS + 1];
ArrayList a_Database_PlayerTalents_Experience[MAXPLAYERS + 1];
ArrayList PlayerAbilitiesName;
ArrayList PlayerAbilitiesCooldown[MAXPLAYERS + 1];
//ArrayList PlayerAbilitiesImmune[MAXPLAYERS + 1][MAXPLAYERS + 1];
ArrayList PlayerInventory[MAXPLAYERS + 1];
ArrayList PlayerEquipped[MAXPLAYERS + 1];
ArrayList a_DirectorActions;
ArrayList a_DirectorActions_Cooldown;
int PlayerLevel[MAXPLAYERS + 1];
int PlayerLevelUpgrades[MAXPLAYERS + 1];
int TotalTalentPoints[MAXPLAYERS + 1];
int ExperienceLevel[MAXPLAYERS + 1];
int SkyPoints[MAXPLAYERS + 1];
char MenuSelection[MAXPLAYERS + 1][PLATFORM_MAX_PATH];
char MenuSelection_p[MAXPLAYERS + 1][PLATFORM_MAX_PATH];
char MenuName_c[MAXPLAYERS + 1][PLATFORM_MAX_PATH];
float Points[MAXPLAYERS + 1];
int DamageAward[MAXPLAYERS + 1][MAXPLAYERS + 1];
int DefaultHealth[MAXPLAYERS + 1];
char white[4];
char green[4];
char blue[4];
char orange[4];
bool b_IsBlind[MAXPLAYERS + 1];
bool b_IsImmune[MAXPLAYERS + 1];
float SpeedMultiplier[MAXPLAYERS + 1];
float SpeedMultiplierBase[MAXPLAYERS + 1];
bool b_IsJumping[MAXPLAYERS + 1];
float GravityBase[MAXPLAYERS + 1];
bool b_GroundRequired[MAXPLAYERS + 1];
int CoveredInBile[MAXPLAYERS + 1][MAXPLAYERS + 1];
int CommonKills[MAXPLAYERS + 1];
int CommonKillsHeadshot[MAXPLAYERS + 1];
char OpenedMenu_p[MAXPLAYERS + 1][512];
char OpenedMenu[MAXPLAYERS + 1][512];
int ExperienceOverall[MAXPLAYERS + 1];
//char CurrentTalentLoading_Bots[128];
//ArrayList a_Database_PlayerTalents_Bots;
//ArrayList PlayerAbilitiesCooldown_Bots;				// Because [designation] = ZombieclassID
int ExperienceLevel_Bots;
//int ExperienceOverall_Bots;
//int PlayerLevelUpgrades_Bots;
int PlayerLevel_Bots;
//int TotalTalentPoints_Bots;
float Points_Director;
ArrayList CommonInfectedQueue;
int g_oAbility = 0;

// Signatures:
Handle g_hIsStaggering = INVALID_HANDLE;
Handle g_hSetClass = INVALID_HANDLE;
Handle g_hCreateAbility = INVALID_HANDLE;
Handle gd = INVALID_HANDLE;
Handle g_hEffectAdrenaline = INVALID_HANDLE;
Handle g_hCallVomitOnPlayer = INVALID_HANDLE;
Handle hRoundRespawn = INVALID_HANDLE;
Handle g_hCreateAcid = INVALID_HANDLE;
// End of signatures
//ArrayList DirectorPurchaseHandle = INVALID_HANDLE;
bool b_IsDirectorTalents[MAXPLAYERS + 1];
//int LoadPos_Bots;
int LoadPos[MAXPLAYERS + 1];
int LoadPos_Director;
ConVar g_Steamgroup;
ConVar g_Tags;
ConVar g_Gamemode;
int RoundTime;
int g_iSprite = 0;
int g_BeaconSprite = 0;
int iNoSpecials;
//bool b_FirstClientLoaded;
bool b_HasDeathLocation[MAXPLAYERS + 1];
bool b_IsMissionFailed;
ArrayList CCASection;
ArrayList CCAKeys;
ArrayList CCAValues;
int LastWeaponDamage[MAXPLAYERS + 1];
float UseItemTime[MAXPLAYERS + 1];
ArrayList NewUsersRound;
bool bIsSoloHandicap;
ArrayList MenuStructure[MAXPLAYERS + 1];
ArrayList TankState_Array[MAXPLAYERS + 1];
bool bIsGiveIncapHealth[MAXPLAYERS + 1];
ArrayList TheLeaderboards[MAXPLAYERS + 1];
ArrayList TheLeaderboardsData[MAXPLAYERS + 1];
int TheLeaderboardsPage[MAXPLAYERS + 1];// 10 entries at a time, until the end of time.
bool bIsMyRanking[MAXPLAYERS + 1];
int TheLeaderboardsPageSize[MAXPLAYERS + 1];
int CurrentRPGMode;
bool IsSurvivalMode = false;
int BestRating[MAXPLAYERS + 1];
int MyRespawnTarget[MAXPLAYERS + 1];
bool RespawnImmunity[MAXPLAYERS + 1];
char TheDBPrefix[64];
int LastAttackedUser[MAXPLAYERS + 1];
ArrayList LoggedUsers;
ArrayList TalentTreeKeys[MAXPLAYERS + 1];
ArrayList TalentTreeValues[MAXPLAYERS + 1];
ArrayList TalentExperienceKeys[MAXPLAYERS + 1];
ArrayList TalentExperienceValues[MAXPLAYERS + 1];
ArrayList TalentActionKeys[MAXPLAYERS + 1];
ArrayList TalentActionValues[MAXPLAYERS + 1];
ArrayList TalentActionSection[MAXPLAYERS + 1];
bool bIsTalentTwo[MAXPLAYERS + 1];
ArrayList CommonDrawKeys;
ArrayList CommonDrawValues;
bool bAutoRevive[MAXPLAYERS + 1];
bool bIsClassAbilities[MAXPLAYERS + 1];
bool bIsDisconnecting[MAXPLAYERS + 1];
ArrayList LegitClassSection[MAXPLAYERS + 1];
int LoadProfileRequestName[MAXPLAYERS + 1];
//char LoadProfileRequest[MAXPLAYERS + 1];
char TheCurrentMap[64];
bool IsEnrageNotified;
//bool bIsNewClass[MAXPLAYERS + 1];
int ClientActiveStance[MAXPLAYERS + 1];
ArrayList SurvivorsIgnored[MAXPLAYERS + 1];
bool HasSeenCombat[MAXPLAYERS + 1];
int MyBirthday[MAXPLAYERS + 1];
//======================================
//Main config variables.
//======================================
float fSuperCommonLimit;
float fBurnPercentage;
int iTankRush;
int iTanksAlways;
float fSprintSpeed;
int iRPGMode;
int DirectorWitchLimit;
float fCommonQueueLimit;
float fDirectorThoughtDelay;
float fDirectorThoughtHandicap;
int iSurvivalRoundTime;
float fDazedDebuffEffect;
int ConsumptionInt;
float fStamSprintInterval;
float fStamRegenTime;
float fStamRegenTimeAdren;
float fBaseMovementSpeed;
float fFatigueMovementSpeed;
int iPlayerStartingLevel;
int iBotPlayerStartingLevel;
float fOutOfCombatTime;
int iWitchDamageInitial;
float fWitchDamageScaleLevel;
float fSurvivorDamageBonus;
float fSurvivorHealthBonus;
int iEnrageTime;
float fWitchDirectorPoints;
float fEnrageDirectorPoints;
float fCommonDamageLevel;
int iBotLevelType;
float fCommonDirectorPoints;
int iDisplayHealthBars;
int iMaxDifficultyLevel;
float fDamagePlayerLevel[7];
float fHealthPlayerLevel[7];
int iBaseSpecialDamage[7];
int iBaseSpecialInfectedHealth[7];
float fPointsMultiplierInfected;
float fPointsMultiplier;
float fHealingMultiplier;
float fBuffingMultiplier;
float fHexingMultiplier;
float TanksNearbyRange;
int iCommonAffixes;
int BroadcastType;
int iDoomTimer;
int iSurvivorStaminaMax;
float fRatingMultSpecials;
float fRatingMultSupers;
float fRatingMultCommons;
float fRatingMultTank;
float fTeamworkExperience;
float fItemMultiplierLuck;
float fItemMultiplierTeam;
char sQuickBindHelp[64];
float fPointsCostLevel;
int PointPurchaseType;
int iTankLimitVersus;
float fHealRequirementTeam;
int iSurvivorBaseHealth;
int iSurvivorBotBaseHealth;
char spmn[64];
float fHealthSurvivorRevive;
char RestrictedWeapons[1024];
int iMaxLevel;
int iExperienceStart;
float fExperienceMultiplier;
char sBotTeam[64];
int iActionBarSlots;
char MenuCommand[64];
int HostNameTime;
int DoomSUrvivorsRequired;
int DoomKillTimer;
float fVersusTankNotice;
int AllowedCommons;
int AllowedMegaMob;
int AllowedMobSpawn;
int AllowedMobSpawnFinale;
int AllowedPanicInterval;
int RespawnQueue;
int MaximumPriority;
float fUpgradeExpCost;
int iHandicapLevelDifference;
int iWitchHealthBase;
float fWitchHealthMult;
int RatingPerLevel;
int iCommonBaseHealth;
float fCommonRaidHealthMult;
float fCommonLevelHealthMult;
int iServerLevelRequirement;
int iRoundStartWeakness;
float GroupMemberBonus;
float FinSurvBon;
int RaidLevMult;
int iIgnoredRating;
int iIgnoredRatingMax;
//int iTrailsEnabled;
int iInfectedLimit;
float SurvivorExperienceMult;
float SurvivorExperienceMultTank;
float SurvivorExperienceMultHeal;
float TheScorchMult;
float TheInfernoMult;
float fAmmoHighlightTime;
float fAdrenProgressMult;
float DirectorTankCooldown;
int DisplayType;
char sDirectorTeam[64];
float fRestedExpMult;
float fSurvivorExpMult;
int iDebuffLimit;
int iRatingSpecialsRequired;
int iRatingTanksRequired;
char sDbLeaderboards[64];
int iIsLifelink;
int RatingPerHandicap;
ArrayList ItemDropArray;
char sItemModel[512];
int iSurvivorGroupMinimum;
/*float fDropChanceSpecial;
float fDropChanceCommon;
float fDropChanceWitch;
float fDropChanceTank;
float fDropChanceInfected;*/
ArrayList PreloadKeys;
ArrayList PreloadValues;
ArrayList ItemDropKeys;
ArrayList ItemDropValues;
ArrayList ItemDropSection;
ArrayList persistentCirculation;
int iRarityMax;
int iEnrageAdvertisement;
int iJoinGroupAdvertisement;
int iNotifyEnrage;
char sBackpackModel[64];
char ItemDropArraySize[64];
bool bIsNewPlayer[MAXPLAYERS + 1];
ArrayList MyGroup[MAXPLAYERS + 1];
int iCommonsLimitUpper;
bool bIsInCheckpoint[MAXPLAYERS + 1];
float fCoopSurvBon;
int iMinSurvivors;
int PassiveEffectDisplay[MAXPLAYERS + 1];
char sServerDifficulty[64];
int iSpecialsAllowed;
char sSpecialsAllowed[64];
int iSurvivorModifierRequired;
float fEnrageMultiplier;
int OverHealth[MAXPLAYERS + 1];
bool bHealthIsSet[MAXPLAYERS + 1];
int iIsLevelingPaused[MAXPLAYERS + 1];
int iIsBulletTrails[MAXPLAYERS + 1];
ArrayList ActiveStatuses[MAXPLAYERS + 1];
int InfectedTalentLevel;
float fEnrageModifier;
float LastAttackTime[MAXPLAYERS + 1];
ArrayList hWeaponList[MAXPLAYERS + 1];
ArrayList GCVKeys[MAXPLAYERS + 1];
ArrayList GCVValues[MAXPLAYERS + 1];
ArrayList GCVSection[MAXPLAYERS + 1];
int MyStatusEffects[MAXPLAYERS + 1];
int iShowLockedTalents;
//ArrayList GCMKeys[MAXPLAYERS + 1];
//ArrayList GCMValues[MAXPLAYERS + 1];
ArrayList PassiveStrengthKeys[MAXPLAYERS + 1];
ArrayList PassiveStrengthValues[MAXPLAYERS + 1];
ArrayList PassiveTalentName[MAXPLAYERS + 1];
ArrayList UpgradeCategoryKeys[MAXPLAYERS + 1];
ArrayList UpgradeCategoryValues[MAXPLAYERS + 1];
ArrayList UpgradeCategoryName[MAXPLAYERS + 1];
int iChaseEnt[MAXPLAYERS + 1];
int iTeamRatingRequired;
float fTeamRatingBonus;
float fRatingPercentLostOnDeath;
int PlayerCurrentMenuLayer[MAXPLAYERS + 1];
int iMaxLayers;
ArrayList TranslationOTNKeys[MAXPLAYERS + 1];
ArrayList TranslationOTNValues[MAXPLAYERS + 1];
ArrayList TranslationOTNSection[MAXPLAYERS + 1];
ArrayList acdrKeys[MAXPLAYERS + 1];
ArrayList acdrValues[MAXPLAYERS + 1];
ArrayList acdrSection[MAXPLAYERS + 1];
ArrayList GetLayerStrengthKeys[MAXPLAYERS + 1];
ArrayList GetLayerStrengthValues[MAXPLAYERS + 1];
ArrayList GetLayerStrengthSection[MAXPLAYERS + 1];
int iCommonInfectedBaseDamage;
int playerPageOfCharacterSheet[MAXPLAYERS + 1];
int nodesInExistence;
int iShowTotalNodesOnTalentTree;
ArrayList PlayerEffectOverTime[MAXPLAYERS + 1];
ArrayList PlayerEffectOverTimeEffects[MAXPLAYERS + 1];
ArrayList CheckEffectOverTimeKeys[MAXPLAYERS + 1];
ArrayList CheckEffectOverTimeValues[MAXPLAYERS + 1];
float fSpecialAmmoInterval;
float fEffectOverTimeInterval;
ArrayList FormatEffectOverTimeKeys[MAXPLAYERS + 1];
ArrayList FormatEffectOverTimeValues[MAXPLAYERS + 1];
ArrayList FormatEffectOverTimeSection[MAXPLAYERS + 1];
ArrayList CooldownEffectTriggerKeys[MAXPLAYERS + 1];
ArrayList CooldownEffectTriggerValues[MAXPLAYERS + 1];
ArrayList IsSpellAnAuraKeys[MAXPLAYERS + 1];
ArrayList IsSpellAnAuraValues[MAXPLAYERS + 1];
float fStaggerTickrate;
ArrayList StaggeredTargets;
ConVar staggerBuffer;
bool staggerCooldownOnTriggers[MAXPLAYERS + 1];
ArrayList CallAbilityCooldownTriggerKeys[MAXPLAYERS + 1];
ArrayList CallAbilityCooldownTriggerValues[MAXPLAYERS + 1];
ArrayList CallAbilityCooldownTriggerSection[MAXPLAYERS + 1];
ArrayList GetIfTriggerRequirementsMetKeys[MAXPLAYERS + 1];
ArrayList GetIfTriggerRequirementsMetValues[MAXPLAYERS + 1];
ArrayList GetIfTriggerRequirementsMetSection[MAXPLAYERS + 1];
bool ShowPlayerLayerInformation[MAXPLAYERS + 1];
ArrayList GAMKeys[MAXPLAYERS + 1];
ArrayList GAMValues[MAXPLAYERS + 1];
ArrayList GAMSection[MAXPLAYERS + 1];
char RPGMenuCommand[64];
int RPGMenuCommandExplode;
//new PrestigeLevel[MAXPLAYERS + 1];
char DefaultProfileName[64];
char DefaultBotProfileName[64];
char DefaultInfectedProfileName[64];
ArrayList GetGoverningAttributeKeys[MAXPLAYERS + 1];
ArrayList GetGoverningAttributeValues[MAXPLAYERS + 1];
ArrayList GetGoverningAttributeSection[MAXPLAYERS + 1];
int iTanksAlwaysEnforceCooldown;
ArrayList WeaponResultKeys[MAXPLAYERS + 1];
ArrayList WeaponResultValues[MAXPLAYERS + 1];
ArrayList WeaponResultSection[MAXPLAYERS + 1];
bool shotgunCooldown[MAXPLAYERS + 1];
float fRatingFloor;
char clientStatusEffectDisplay[MAXPLAYERS + 1][64];
char clientTrueHealthDisplay[MAXPLAYERS + 1][64];
char clientContributionHealthDisplay[MAXPLAYERS + 1][64];
int currLivingSurvivors;
int iExperienceDebtLevel;
int iExperienceDebtEnabled;
float fExperienceDebtPenalty;
int iShowDamageOnActionBar;
int iDefaultIncapHealth;
ArrayList GetAbilityCooldownKeys[MAXPLAYERS + 1];
ArrayList GetAbilityCooldownValues[MAXPLAYERS + 1];
ArrayList GetAbilityCooldownSection[MAXPLAYERS + 1];
ArrayList GetTalentValueSearchKeys[MAXPLAYERS + 1];
ArrayList GetTalentValueSearchValues[MAXPLAYERS + 1];
ArrayList GetTalentValueSearchSection[MAXPLAYERS + 1];
int iSkyLevelNodeUnlocks;
ArrayList GetTalentKeyValueKeys[MAXPLAYERS + 1];
ArrayList GetTalentKeyValueValues[MAXPLAYERS + 1];
ArrayList GetTalentKeyValueSection[MAXPLAYERS + 1];
ArrayList ApplyDebuffCooldowns[MAXPLAYERS + 1];
int iCanSurvivorBotsBurn;
char defaultLoadoutWeaponPrimary[64];
char defaultLoadoutWeaponSecondary[64];
int iDeleteCommonsFromExistenceOnDeath;
int iShowDetailedDisplayAlways;
int iCanJetpackWhenInCombat;
Handle ZoomcheckDelayer[MAXPLAYERS + 1];
ArrayList zoomCheckList;
float fquickScopeTime;
ArrayList holdingFireList;
int iEnsnareLevelMultiplier;
ArrayList CommonInfectedHealth;
int lastBaseDamage[MAXPLAYERS + 1];
int lastTarget[MAXPLAYERS + 1];
char lastWeapon[MAXPLAYERS + 1][64];
int iSurvivorBotsBonusLimit;
float fSurvivorBotsNoneBonus;
bool bTimersRunning[MAXPLAYERS + 1];
int iShowAdvertToNonSteamgroupMembers;
int displayBuffOrDebuff[MAXPLAYERS + 1];
ArrayList TalentAtMenuPositionSection[MAXPLAYERS + 1];
int iStrengthOnSpawnIsStrength;
ArrayList SetNodesKeys;
ArrayList SetNodesValues;
float fDrawHudInterval;
bool ImmuneToAllDamage[MAXPLAYERS + 1];
int iPlayersLeaveCombatDuringFinales;
int iAllowPauseLeveling;
//new iDropAcidOnLastDebuffDrop;
float fMaxDamageResistance;
float fStaminaPerPlayerLevel;
float fStaminaPerSkyLevel;
int LastBulletCheck[MAXPLAYERS + 1];
int iSpecialInfectedMinimum;
int iEndRoundIfNoHealthySurvivors;
float fAcidDamagePlayerLevel;
float fAcidDamageSupersPlayerLevel;
char ClientStatusEffects[MAXPLAYERS + 1][2][64];
float fTankMovementSpeed_Burning;
float fTankMovementSpeed_Hulk;
float fTankMovementSpeed_Death;
public Action CMD_DropWeapon(int client, int args) {
	int CurrentEntity			=	GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
	if (!IsValidEntity(CurrentEntity) || CurrentEntity < 1) return Plugin_Handled;
	char EntityName[64];
	GetEdictClassname(CurrentEntity, EntityName, sizeof(EntityName));
	if (StrContains(EntityName, "melee", false) != -1) return Plugin_Handled;
	int Entity					=	CreateEntityByName(EntityName);
	DispatchSpawn(Entity);
	float Origin[3];
	GetClientAbsOrigin(client, Origin);
	Origin[2] += 64.0;
	TeleportEntity(Entity, Origin, NULL_VECTOR, NULL_VECTOR);
	SetEntityMoveType(Entity, MOVETYPE_VPHYSICS);
	if (GetWeaponSlot(Entity) < 2) SetEntProp(Entity, Prop_Send, "m_iClip1", GetEntProp(CurrentEntity, Prop_Send, "m_iClip1"));
	AcceptEntityInput(CurrentEntity, "Kill");
	return Plugin_Handled;
}

public Action CMD_IAmStuck(int client, int args) {
	if (L4D2_GetInfectedAttacker(client) == -1 && !AnyTanksNearby(client, 512.0)) {
		int target = FindAnyRandomClient(true, client);
		if (target > 0) {
			GetClientAbsOrigin(target, DeathLocation[client]);
			TeleportEntity(client, DeathLocation[client], NULL_VECTOR, NULL_VECTOR);
			SetEntityMoveType(client, MOVETYPE_WALK);
		}
	}
	return Plugin_Handled;
}

stock void DoGunStuff(int client) {
	int targetgun = GetPlayerWeaponSlot(client, 0); //get the players primary weapon
	if (!IsValidEdict(targetgun)) return; //check for validity
	int iAmmoOffset = FindDataMapInfo(client, "m_iAmmo"); //get the iAmmo Offset
	iAmmoOffset = GetEntData(client, (iAmmoOffset + GetWeaponResult(client, 1)));
	PrintToChat(client, "reserve remaining: %d | reserve cap: %d", iAmmoOffset, GetWeaponResult(client, 2));
	return;
}

stock void CMD_OpenRPGMenu(int client) {
	MenuStructure[client].Clear();	// keeps track of the open menus.
	//VerifyAllActionBars(client);	// Because.
	if (LoadProfileRequestName[client] != -1) {
		if (!IsLegitimateClient(LoadProfileRequestName[client])) LoadProfileRequestName[client] = -1;
	}
	iIsWeaponLoadout[client] = 0;
	bEquipSpells[client] = false;
	PlayerCurrentMenuLayer[client] = 1;
	ShowPlayerLayerInformation[client] = false;
	if (iAllowPauseLeveling != 1 && iIsLevelingPaused[client] == 1) iIsLevelingPaused[client] = 0;
	BuildMenu(client, "main");
	/*new count = GetEntProp(client, Prop_Send, "m_iShovePenalty", 4);
	PrintToChat(client, "shove penalty: %d", count);
	if (count < 1) {
		SetEntProp(client, Prop_Send, "m_iShovePenalty", 10);
		SetEntPropFloat(client, Prop_Send, "m_flNextShoveTime", 900.0);
	}
	else {
		SetEntProp(client, Prop_Send, "m_iShovePenalty", 0);
		SetEntPropFloat(client, Prop_Send, "m_flNextShoveTime", 1.0);
	}*/
	//PrintToChat(client, "penalty soon: %d", count);
}

public void OnPluginStart() {
	CreateConVar("skyrpg_version", PLUGIN_VERSION, "version header", CVAR_SHOW);
	FindConVar("skyrpg_version").SetString(PLUGIN_VERSION);
	g_Steamgroup = FindConVar("sv_steamgroup");
	g_Steamgroup.Flags = g_Steamgroup.Flags & ~FCVAR_NOTIFY;
	g_Tags = FindConVar("sv_tags");
	g_Tags.Flags = g_Tags.Flags & ~FCVAR_NOTIFY;
	g_Gamemode = FindConVar("mp_gamemode");
	LoadTranslations("skyrpg.phrases");
	BuildPath(Path_SM, ConfigPathDirectory, sizeof(ConfigPathDirectory), "configs/readyup/");
	if (!DirExists(ConfigPathDirectory)) CreateDirectory(ConfigPathDirectory, 777);
	BuildPath(Path_SM, LogPathDirectory, sizeof(LogPathDirectory), "logs/readyup/rpg/");
	if (!DirExists(LogPathDirectory)) CreateDirectory(LogPathDirectory, 777);
	BuildPath(Path_SM, LogPathDirectory, sizeof(LogPathDirectory), "logs/readyup/rpg/%s", LOGFILE);
	if (!FileExists(LogPathDirectory)) SetFailState("[SKYRPG LOGGING] please create file at %s", LogPathDirectory);
	RegAdminCmd("sm_debugrpg", Cmd_debugrpg, ADMFLAG_KICK);
	RegAdminCmd("sm_resettpl", Cmd_ResetTPL, ADMFLAG_KICK);
	RegAdminCmd("sm_origin", Cmd_GetOrigin, ADMFLAG_KICK);
	RegAdminCmd("sm_deleteprofiles", CMD_DeleteProfiles, ADMFLAG_ROOT);
	// These are mandatory because of quick commands, so I hardcode the entries.
	RegConsoleCmd("say", CMD_ChatCommand);
	RegConsoleCmd("say_team", CMD_TeamChatCommand);
	RegConsoleCmd("callvote", CMD_BlockVotes);
	RegConsoleCmd("votemap", CMD_BlockIfReadyUpIsActive);
	RegConsoleCmd("vote", CMD_BlockVotes);
	//RegConsoleCmd("talentupgrade", CMD_TalentUpgrade);
	RegConsoleCmd("sm_loadoutname", CMD_LoadoutName);
	RegConsoleCmd("sm_stuck", CMD_IAmStuck);
	RegConsoleCmd("sm_ff", CMD_TogglePvP);
	RegConsoleCmd("sm_revive", CMD_RespawnYumYum);
	//RegConsoleCmd("abar", CMD_ActionBar);
	RegConsoleCmd("sm_handicap", CMD_Handicap);
	RegAdminCmd("sm_firesword", CMD_FireSword, ADMFLAG_KICK);
	RegAdminCmd("sm_fbegin", CMD_FBEGIN, ADMFLAG_KICK);
	RegAdminCmd("sm_witches", CMD_WITCHESCOUNT, ADMFLAG_KICK);
	//RegAdminCmd("staggertest", CMD_STAGGERTEST, ADMFLAG_KICK);
	Format(white, sizeof(white), "\x01");
	Format(orange, sizeof(orange), "\x04");
	Format(green, sizeof(green), "\x05");
	Format(blue, sizeof(blue), "\x03");
	gd = LoadGameConfigFile("rum_rpg");

	if (gd != INVALID_HANDLE) {
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(gd, SDKConf_Signature, "SetClass");
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
		g_hSetClass = EndPrepSDKCall();
		StartPrepSDKCall(SDKCall_Static);
		PrepSDKCall_SetFromConf(gd, SDKConf_Signature, "CreateAbility");
		PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
		PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Pointer);
		g_hCreateAbility = EndPrepSDKCall();
		g_oAbility = GameConfGetOffset(gd, "oAbility");
		StartPrepSDKCall(SDKCall_Entity);
		PrepSDKCall_SetFromConf(gd, SDKConf_Signature, "CSpitterProjectile_Detonate");
		g_hCreateAcid = EndPrepSDKCall();
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(gd, SDKConf_Signature, "CTerrorPlayer_OnAdrenalineUsed");
		PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
		g_hEffectAdrenaline = EndPrepSDKCall();
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(gd, SDKConf_Signature, "CTerrorPlayer_OnVomitedUpon");
		PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
		g_hCallVomitOnPlayer = EndPrepSDKCall();
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(gd, SDKConf_Signature, "RoundRespawn");
		hRoundRespawn = EndPrepSDKCall();
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(gd, SDKConf_Signature, "IsStaggering");
		PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
		g_hIsStaggering = EndPrepSDKCall();
	}
	else {
		SetFailState("Error: Unable to load Gamedata rum_rpg.txt");
	}
	CheckDifficulty();
	staggerBuffer = CreateConVar("sm_vscript_res", "", "returns results from vscript check on stagger");
}

public Action CMD_WITCHESCOUNT(int client, int args) {
	PrintToChat(client, "Witches: %d", WitchList.Length);
	return Plugin_Handled;
}

public Action CMD_FBEGIN(int client, int args) {
	ReadyUpEnd_Complete();
	return Plugin_Handled;
}

public Action Cmd_GetOrigin(int client, int args) {
	float OriginP[3];
	char sMelee[64];
	GetMeleeWeapon(client, sMelee, sizeof(sMelee));
	GetClientAbsOrigin(client, OriginP);
	PrintToChat(client, "[0] %3.3f [1] %3.3f [2] %3.3f\n%s", OriginP[0], OriginP[1], OriginP[2], sMelee);
	return Plugin_Handled;
}

public Action CMD_DeleteProfiles(int client, int args) {
	if (DeleteAllProfiles(client)) PrintToChat(client, "all saved profiles are deleted.");
	return Plugin_Handled;
}
public Action CMD_BlockVotes(int client, int args) {
	return Plugin_Handled;
}

public Action CMD_BlockIfReadyUpIsActive(int client, int args) {
	if (!b_IsRoundIsOver) return Plugin_Continue;
	return Plugin_Handled;
}

public int ReadyUp_SetSurvivorMinimum(int minSurvs) {
	iMinSurvivors = minSurvs;

	return 0;
}

public int ReadyUp_GetMaxSurvivorCount(int count) {
	if (count <= 1) bIsSoloHandicap = true;
	else bIsSoloHandicap = false;

	return 0;
}

stock void UnhookAll() {
	for (int i = 1; i <= MaxClients; i++) {
		if (IsLegitimateClient(i)) {
			SDKUnhook(i, SDKHook_OnTakeDamage, OnTakeDamage);
			b_IsHooked[i] = false;
		}
	}
}

public int ReadyUp_TrueDisconnect(int client) {
	if (bIsInCombat[client]) IncapacitateOrKill(client, _, _, true, true, true);
	//ChangeHook(client);
	staggerCooldownOnTriggers[client] = false;
	ISBILED[client] = false;
	DisplayActionBar[client] = false;
	IsPvP[client] = 0;
	b_IsFloating[client] = false;
	b_IsLoading[client] = false;
	b_HardcoreMode[client] = false;
	//WipeDebuffs(_, client, true);
	if (b_IsLoaded[client]) SaveAndClear(client, true);
	IsPlayerDebugMode[client] = 0;
	CleanseStack[client] = 0;
	CounterStack[client] = 0.0;
	MultiplierStack[client] = 0;
	LoadTarget[client] = -1;
	ImmuneToAllDamage[client] = false;
	b_IsLoaded[client] = false;		// only set to false if a REAL player leaves - this way bots don't repeatedly load their data.
	Format(ProfileLoadQueue[client], sizeof(ProfileLoadQueue[]), "none");
	Format(BuildingStack[client], sizeof(BuildingStack[]), "none");
	Format(LoadoutName[client], sizeof(LoadoutName[]), "none");
	//CreateTimer(1.0, Timer_RemoveSaveSafety, client, TIMER_FLAG_NO_MAPCHANGE);
	bIsSettingsCheck = true;
	if (b_IsActiveRound && TotalHumanSurvivors() < 1) {	// If the disconnecting player was the last human survivor, if the round is live, we end the round.
		ForceServerCommand("scenario_end");
		CallRoundIsOver();
	}
}
/*public ReadyUp_FwdChangeTeam(client, team) {

	if (team == TEAM_SPECTATOR) {

		if (bIsInCombat[client]) {

			IncapacitateOrKill(client, _, _, true, true);
		}

		b_IsHooked[client] = false;
		SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	}
	else if (team == TEAM_SURVIVOR && !b_IsHooked[client]) {

		b_IsHooked[client] = true;
		SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	}
}*/

//stock LoadConfigValues() {
//}

public void OnAllPluginsLoaded() {
	OnMapStartFunc();
	CheckDifficulty();
}

stock void OnMapStartFunc() {
	if (!b_MapStart) {
		b_MapStart								= true;
		CreateTimer(1.0, Timer_CheckDifficulty, _, TIMER_REPEAT);
		//LoadConfigValues();
		LogMessage("=====\t\tLOADING RPG\t\t=====");
		//char fubar[64];
		if (holdingFireList == INVALID_HANDLE || !b_FirstLoad) holdingFireList = new ArrayList(32);
		if (zoomCheckList == INVALID_HANDLE || !b_FirstLoad) zoomCheckList = new ArrayList(32);
		if (hThreatSort == INVALID_HANDLE || !b_FirstLoad) hThreatSort = new ArrayList(32);
		if (hThreatMeter == INVALID_HANDLE || !b_FirstLoad) hThreatMeter = new ArrayList(32);
		if (LoggedUsers == INVALID_HANDLE || !b_FirstLoad) LoggedUsers = new ArrayList(32);
		if (SuperCommonQueue == INVALID_HANDLE || !b_FirstLoad) SuperCommonQueue = new ArrayList(32);
		if (CommonInfectedQueue == INVALID_HANDLE || !b_FirstLoad) CommonInfectedQueue = new ArrayList(32);
		if (CoveredInVomit == INVALID_HANDLE || !b_FirstLoad) CoveredInVomit = new ArrayList(32);
		if (NewUsersRound == INVALID_HANDLE || !b_FirstLoad) NewUsersRound = new ArrayList(32);
		if (SpecialAmmoData == INVALID_HANDLE || !b_FirstLoad) SpecialAmmoData = new ArrayList(32);
		if (SpecialAmmoSave == INVALID_HANDLE || !b_FirstLoad) SpecialAmmoSave = new ArrayList(32);
		if (MainKeys == INVALID_HANDLE || !b_FirstLoad) MainKeys = new ArrayList(32);
		if (MainValues == INVALID_HANDLE || !b_FirstLoad) MainValues = new ArrayList(32);
		if (a_Menu_Talents == INVALID_HANDLE || !b_FirstLoad) a_Menu_Talents = new ArrayList(3);
		if (a_Menu_Main == INVALID_HANDLE || !b_FirstLoad) a_Menu_Main = new ArrayList(3);
		if (a_Events == INVALID_HANDLE || !b_FirstLoad) a_Events = new ArrayList(3);
		if (a_Points == INVALID_HANDLE || !b_FirstLoad) a_Points = new ArrayList(3);
		if (a_Pets == INVALID_HANDLE || !b_FirstLoad) a_Pets = new ArrayList(3);
		if (a_Store == INVALID_HANDLE || !b_FirstLoad) a_Store = new ArrayList(3);
		if (a_Trails == INVALID_HANDLE || !b_FirstLoad) a_Trails = new ArrayList(3);
		if (a_Database_Talents == INVALID_HANDLE || !b_FirstLoad) a_Database_Talents = new ArrayList(32);
		if (a_Database_Talents_Defaults == INVALID_HANDLE || !b_FirstLoad) a_Database_Talents_Defaults 	= new ArrayList(32);
		if (a_Database_Talents_Defaults_Name == INVALID_HANDLE || !b_FirstLoad) a_Database_Talents_Defaults_Name				= new ArrayList(32);
		if (EventSection == INVALID_HANDLE || !b_FirstLoad) EventSection									= new ArrayList(32);
		if (HookSection == INVALID_HANDLE || !b_FirstLoad) HookSection										= new ArrayList(32);
		if (CallKeys == INVALID_HANDLE || !b_FirstLoad) CallKeys										= new ArrayList(32);
		if (CallValues == INVALID_HANDLE || !b_FirstLoad) CallValues										= new ArrayList(32);
		if (DirectorKeys == INVALID_HANDLE || !b_FirstLoad) DirectorKeys									= new ArrayList(32);
		if (DirectorValues == INVALID_HANDLE || !b_FirstLoad) DirectorValues									= new ArrayList(32);
		if (DatabaseKeys == INVALID_HANDLE || !b_FirstLoad) DatabaseKeys									= new ArrayList(32);
		if (DatabaseValues == INVALID_HANDLE || !b_FirstLoad) DatabaseValues									= new ArrayList(32);
		if (DatabaseSection == INVALID_HANDLE || !b_FirstLoad) DatabaseSection									= new ArrayList(32);
		if (a_Database_PlayerTalents_Bots == INVALID_HANDLE || !b_FirstLoad) a_Database_PlayerTalents_Bots					= new ArrayList(32);
		if (PlayerAbilitiesCooldown_Bots == INVALID_HANDLE || !b_FirstLoad) PlayerAbilitiesCooldown_Bots					= new ArrayList(32);
		if (PlayerAbilitiesImmune_Bots == INVALID_HANDLE || !b_FirstLoad) PlayerAbilitiesImmune_Bots						= new ArrayList(32);
		if (BotSaveKeys == INVALID_HANDLE || !b_FirstLoad) BotSaveKeys										= new ArrayList(32);
		if (BotSaveValues == INVALID_HANDLE || !b_FirstLoad) BotSaveValues									= new ArrayList(32);
		if (BotSaveSection == INVALID_HANDLE || !b_FirstLoad) BotSaveSection									= new ArrayList(32);
		if (LoadDirectorSection == INVALID_HANDLE || !b_FirstLoad) LoadDirectorSection								= new ArrayList(32);
		if (QueryDirectorKeys == INVALID_HANDLE || !b_FirstLoad) QueryDirectorKeys								= new ArrayList(32);
		if (QueryDirectorValues == INVALID_HANDLE || !b_FirstLoad) QueryDirectorValues								= new ArrayList(32);
		if (QueryDirectorSection == INVALID_HANDLE || !b_FirstLoad) QueryDirectorSection							= new ArrayList(32);
		if (FirstDirectorKeys == INVALID_HANDLE || !b_FirstLoad) FirstDirectorKeys								= new ArrayList(32);
		if (FirstDirectorValues == INVALID_HANDLE || !b_FirstLoad) FirstDirectorValues								= new ArrayList(32);
		if (FirstDirectorSection == INVALID_HANDLE || !b_FirstLoad) FirstDirectorSection							= new ArrayList(32);
		if (PlayerAbilitiesName == INVALID_HANDLE || !b_FirstLoad) PlayerAbilitiesName								= new ArrayList(32);
		if (a_DirectorActions == INVALID_HANDLE || !b_FirstLoad) a_DirectorActions								= new ArrayList(3);
		if (a_DirectorActions_Cooldown == INVALID_HANDLE || !b_FirstLoad) a_DirectorActions_Cooldown						= new ArrayList(32);
		if (a_ChatSettings == INVALID_HANDLE || !b_FirstLoad) a_ChatSettings								= new ArrayList(3);
		if (LockedTalentKeys == INVALID_HANDLE || !b_FirstLoad) LockedTalentKeys							= new ArrayList(32);
		if (LockedTalentValues == INVALID_HANDLE || !b_FirstLoad) LockedTalentValues						= new ArrayList(32);
		if (LockedTalentSection == INVALID_HANDLE || !b_FirstLoad) LockedTalentSection						= new ArrayList(32);
		if (Give_Store_Keys == INVALID_HANDLE || !b_FirstLoad) Give_Store_Keys							= new ArrayList(32);
		if (Give_Store_Values == INVALID_HANDLE || !b_FirstLoad) Give_Store_Values							= new ArrayList(32);
		if (Give_Store_Section == INVALID_HANDLE || !b_FirstLoad) Give_Store_Section							= new ArrayList(32);
		if (a_WeaponDamages == INVALID_HANDLE || !b_FirstLoad) a_WeaponDamages = new ArrayList(32);
		if (a_CommonAffixes == INVALID_HANDLE || !b_FirstLoad) a_CommonAffixes = new ArrayList(32);
		if (CommonList == INVALID_HANDLE || !b_FirstLoad) CommonList = new ArrayList(32);
		if (WitchList == INVALID_HANDLE || !b_FirstLoad) WitchList				= new ArrayList(32);
		if (CommonAffixes == INVALID_HANDLE || !b_FirstLoad) CommonAffixes	= new ArrayList(32);
		if (h_CAKeys == INVALID_HANDLE || !b_FirstLoad) h_CAKeys = new ArrayList(32);
		if (h_CAValues == INVALID_HANDLE || !b_FirstLoad) h_CAValues = new ArrayList(32);
		if (SearchKey_Section == INVALID_HANDLE || !b_FirstLoad) SearchKey_Section = new ArrayList(32);
		if (CCASection == INVALID_HANDLE || !b_FirstLoad) CCASection = new ArrayList(32);
		if (CCAKeys == INVALID_HANDLE || !b_FirstLoad) CCAKeys = new ArrayList(32);
		if (CCAValues == INVALID_HANDLE || !b_FirstLoad) CCAValues = new ArrayList(32);
		if (h_CommonKeys == INVALID_HANDLE || !b_FirstLoad) h_CommonKeys = new ArrayList(32);
		if (h_CommonValues == INVALID_HANDLE || !b_FirstLoad) h_CommonValues = new ArrayList(32);
		if (CommonInfected == INVALID_HANDLE || !b_FirstLoad) CommonInfected = new ArrayList(32);
		if (EntityOnFire == INVALID_HANDLE || !b_FirstLoad) EntityOnFire = new ArrayList(32);
		if (EntityOnFireName == INVALID_HANDLE || !b_FirstLoad) EntityOnFireName = new ArrayList(32);
		if (CommonDrawKeys == INVALID_HANDLE || !b_FirstLoad) CommonDrawKeys = new ArrayList(32);
		if (CommonDrawValues == INVALID_HANDLE || !b_FirstLoad) CommonDrawValues = new ArrayList(32);
		if (ItemDropArray == INVALID_HANDLE || !b_FirstLoad) ItemDropArray = new ArrayList(32);
		if (PreloadKeys == INVALID_HANDLE || !b_FirstLoad) PreloadKeys = new ArrayList(32);
		if (PreloadValues == INVALID_HANDLE || !b_FirstLoad) PreloadValues = new ArrayList(32);
		if (ItemDropKeys == INVALID_HANDLE || !b_FirstLoad) ItemDropKeys = new ArrayList(32);
		if (ItemDropValues == INVALID_HANDLE || !b_FirstLoad) ItemDropValues = new ArrayList(32);
		if (ItemDropSection == INVALID_HANDLE || !b_FirstLoad) ItemDropSection = new ArrayList(32);
		if (persistentCirculation == INVALID_HANDLE || !b_FirstLoad) persistentCirculation = new ArrayList(32);
		if (RandomSurvivorClient == INVALID_HANDLE || !b_FirstLoad) RandomSurvivorClient = new ArrayList(32);
		if (RoundStatistics == INVALID_HANDLE || !b_FirstLoad) RoundStatistics = new ArrayList(16);
		if (EffectOverTime == INVALID_HANDLE || !b_FirstLoad) EffectOverTime = new ArrayList(32);
		if (TimeOfEffectOverTime == INVALID_HANDLE || !b_FirstLoad) TimeOfEffectOverTime = new ArrayList(32);
		if (StaggeredTargets == INVALID_HANDLE || !b_FirstLoad) StaggeredTargets = new ArrayList(32);
		if (CommonInfectedHealth == INVALID_HANDLE || !b_FirstLoad) CommonInfectedHealth = new ArrayList(32);
		if (SetNodesKeys == INVALID_HANDLE || !b_FirstLoad) SetNodesKeys = new ArrayList(32);
		if (SetNodesValues == INVALID_HANDLE || !b_FirstLoad) SetNodesValues = new ArrayList(32);
		
		for (int i = 1; i <= MAXPLAYERS; i++) {
			LastDeathTime[i] = 0.0;
			MyVomitChase[i] = -1;
			b_IsFloating[i] = false;
			DisplayActionBar[i] = false;
			ActionBarSlot[i] = -1;
			if (currentEquippedWeapon[i] == INVALID_HANDLE || !b_FirstLoad) currentEquippedWeapon[i] = new StringMap();
			if (GetCategoryStrengthKeys[i] == INVALID_HANDLE || !b_FirstLoad) GetCategoryStrengthKeys[i] = new ArrayList(32);
			if (GetCategoryStrengthValues[i] == INVALID_HANDLE || !b_FirstLoad) GetCategoryStrengthValues[i] = new ArrayList(32);
			if (GetCategoryStrengthSection[i] == INVALID_HANDLE || !b_FirstLoad) GetCategoryStrengthSection[i] = new ArrayList(32);
			//if (GCMKeys[i] == INVALID_HANDLE || !b_FirstLoad) GCMKeys[i] = new ArrayList(32);
			//if (GCMValues[i] == INVALID_HANDLE || !b_FirstLoad) GCMValues[i] = new ArrayList(32);
			if (PassiveStrengthKeys[i] == INVALID_HANDLE || !b_FirstLoad) PassiveStrengthKeys[i] = new ArrayList(32);
			if (PassiveStrengthValues[i] == INVALID_HANDLE || !b_FirstLoad) PassiveStrengthValues[i] = new ArrayList(32);
			if (PassiveTalentName[i] == INVALID_HANDLE || !b_FirstLoad) PassiveTalentName[i] = new ArrayList(32);
			if (UpgradeCategoryKeys[i] == INVALID_HANDLE || !b_FirstLoad) UpgradeCategoryKeys[i] = new ArrayList(32);
			if (UpgradeCategoryValues[i] == INVALID_HANDLE || !b_FirstLoad) UpgradeCategoryValues[i] = new ArrayList(32);
			if (UpgradeCategoryName[i] == INVALID_HANDLE || !b_FirstLoad) UpgradeCategoryName[i] = new ArrayList(32);
			if (TranslationOTNKeys[i] == INVALID_HANDLE || !b_FirstLoad) TranslationOTNKeys[i] = new ArrayList(32);
			if (TranslationOTNValues[i] == INVALID_HANDLE || !b_FirstLoad) TranslationOTNValues[i] = new ArrayList(32);
			if (TranslationOTNSection[i] == INVALID_HANDLE || !b_FirstLoad) TranslationOTNSection[i] = new ArrayList(32);
			if (GCVKeys[i] == INVALID_HANDLE || !b_FirstLoad) GCVKeys[i] = new ArrayList(32);
			if (GCVValues[i] == INVALID_HANDLE || !b_FirstLoad) GCVValues[i] = new ArrayList(32);
			if (GCVSection[i] == INVALID_HANDLE || !b_FirstLoad) GCVSection[i] = new ArrayList(32);
			if (hWeaponList[i] == INVALID_HANDLE || !b_FirstLoad) hWeaponList[i] = new ArrayList(32);
			if (LoadoutConfigKeys[i] == INVALID_HANDLE || !b_FirstLoad) LoadoutConfigKeys[i] = new ArrayList(32);
			if (LoadoutConfigValues[i] == INVALID_HANDLE || !b_FirstLoad) LoadoutConfigValues[i] = new ArrayList(32);
			if (LoadoutConfigSection[i] == INVALID_HANDLE || !b_FirstLoad) LoadoutConfigSection[i] = new ArrayList(32);
			if (ActiveStatuses[i] == INVALID_HANDLE || !b_FirstLoad) ActiveStatuses[i] = new ArrayList(32);
			if (AbilityConfigKeys[i] == INVALID_HANDLE || !b_FirstLoad) AbilityConfigKeys[i] = new ArrayList(32);
			if (AbilityConfigValues[i] == INVALID_HANDLE || !b_FirstLoad) AbilityConfigValues[i] = new ArrayList(32);
			if (AbilityConfigSection[i] == INVALID_HANDLE || !b_FirstLoad) AbilityConfigSection[i] = new ArrayList(32);
			if (GetAbilityKeys[i] == INVALID_HANDLE || !b_FirstLoad) GetAbilityKeys[i] = new ArrayList(32);
			if (GetAbilityValues[i] == INVALID_HANDLE || !b_FirstLoad) GetAbilityValues[i] = new ArrayList(32);
			if (GetAbilitySection[i] == INVALID_HANDLE || !b_FirstLoad) GetAbilitySection[i] = new ArrayList(32);
			if (IsAbilityKeys[i] == INVALID_HANDLE || !b_FirstLoad) IsAbilityKeys[i] = new ArrayList(32);
			if (IsAbilityValues[i] == INVALID_HANDLE || !b_FirstLoad) IsAbilityValues[i] = new ArrayList(32);
			if (IsAbilitySection[i] == INVALID_HANDLE || !b_FirstLoad) IsAbilitySection[i] = new ArrayList(32);
			if (CheckAbilityKeys[i] == INVALID_HANDLE || !b_FirstLoad) CheckAbilityKeys[i] = new ArrayList(32);
			if (CheckAbilityValues[i] == INVALID_HANDLE || !b_FirstLoad) CheckAbilityValues[i] = new ArrayList(32);
			if (CheckAbilitySection[i] == INVALID_HANDLE || !b_FirstLoad) CheckAbilitySection[i] = new ArrayList(32);
			if (GetTalentStrengthKeys[i] == INVALID_HANDLE || !b_FirstLoad) GetTalentStrengthKeys[i] = new ArrayList(32);
			if (GetTalentStrengthValues[i] == INVALID_HANDLE || !b_FirstLoad) GetTalentStrengthValues[i] = new ArrayList(32);
			if (CastKeys[i] == INVALID_HANDLE || !b_FirstLoad) CastKeys[i] = new ArrayList(32);
			if (CastValues[i] == INVALID_HANDLE || !b_FirstLoad) CastValues[i] = new ArrayList(32);
			if (CastSection[i] == INVALID_HANDLE || !b_FirstLoad) CastSection[i] = new ArrayList(32);
			if (ActionBar[i] == INVALID_HANDLE || !b_FirstLoad) ActionBar[i] = new ArrayList(32);
			if (TalentsAssignedKeys[i] == INVALID_HANDLE || !b_FirstLoad) TalentsAssignedKeys[i] = new ArrayList(32);
			if (TalentsAssignedValues[i] == INVALID_HANDLE || !b_FirstLoad) TalentsAssignedValues[i] = new ArrayList(32);
			if (CartelValueKeys[i] == INVALID_HANDLE || !b_FirstLoad) CartelValueKeys[i] = new ArrayList(32);
			if (CartelValueValues[i] == INVALID_HANDLE || !b_FirstLoad) CartelValueValues[i] = new ArrayList(32);
			if (LegitClassSection[i] == INVALID_HANDLE || !b_FirstLoad) LegitClassSection[i] = new ArrayList(32);
			if (TalentActionKeys[i] == INVALID_HANDLE || !b_FirstLoad) TalentActionKeys[i] = new ArrayList(32);
			if (TalentActionValues[i] == INVALID_HANDLE || !b_FirstLoad) TalentActionValues[i] = new ArrayList(32);
			if (TalentActionSection[i] == INVALID_HANDLE || !b_FirstLoad) TalentActionSection[i] = new ArrayList(32);
			if (TalentExperienceKeys[i] == INVALID_HANDLE || !b_FirstLoad) TalentExperienceKeys[i] = new ArrayList(32);
			if (TalentExperienceValues[i] == INVALID_HANDLE || !b_FirstLoad) TalentExperienceValues[i] = new ArrayList(32);
			if (TalentTreeKeys[i] == INVALID_HANDLE || !b_FirstLoad) TalentTreeKeys[i] = new ArrayList(32);
			if (TalentTreeValues[i] == INVALID_HANDLE || !b_FirstLoad) TalentTreeValues[i] = new ArrayList(32);
			if (TheLeaderboards[i] == INVALID_HANDLE || !b_FirstLoad) TheLeaderboards[i] = new ArrayList(32);
			if (TheLeaderboardsData[i] == INVALID_HANDLE || !b_FirstLoad) TheLeaderboardsData[i] = new ArrayList(32);
			if (TankState_Array[i] == INVALID_HANDLE || !b_FirstLoad) TankState_Array[i] = new ArrayList(32);
			if (PlayerInventory[i] == INVALID_HANDLE || !b_FirstLoad) PlayerInventory[i] = new ArrayList(32);
			if (PlayerEquipped[i] == INVALID_HANDLE || !b_FirstLoad) PlayerEquipped[i] = new ArrayList(32);
			if (MenuStructure[i] == INVALID_HANDLE || !b_FirstLoad) MenuStructure[i] = new ArrayList(32);
			if (TempAttributes[i] == INVALID_HANDLE || !b_FirstLoad) TempAttributes[i] = new ArrayList(32);
			if (TempTalents[i] == INVALID_HANDLE || !b_FirstLoad) TempTalents[i] = new ArrayList(32);
			if (PlayerProfiles[i] == INVALID_HANDLE || !b_FirstLoad) PlayerProfiles[i] = new ArrayList(32);
			if (SpecialAmmoEffectKeys[i] == INVALID_HANDLE || !b_FirstLoad) SpecialAmmoEffectKeys[i] = new ArrayList(32);
			if (SpecialAmmoEffectValues[i] == INVALID_HANDLE || !b_FirstLoad) SpecialAmmoEffectValues[i] = new ArrayList(32);
			if (ActiveAmmoCooldownKeys[i] == INVALID_HANDLE || !b_FirstLoad) ActiveAmmoCooldownKeys[i] = new ArrayList(32);
			if (ActiveAmmoCooldownValues[i] == INVALID_HANDLE || !b_FirstLoad) ActiveAmmoCooldownValues[i] = new ArrayList(32);
			if (PlayActiveAbilities[i] == INVALID_HANDLE || !b_FirstLoad) PlayActiveAbilities[i] = new ArrayList(32);
			if (PlayerActiveAmmo[i] == INVALID_HANDLE || !b_FirstLoad) PlayerActiveAmmo[i] = new ArrayList(32);
			if (SpecialAmmoKeys[i] == INVALID_HANDLE || !b_FirstLoad) SpecialAmmoKeys[i] = new ArrayList(32);
			if (SpecialAmmoValues[i] == INVALID_HANDLE || !b_FirstLoad) SpecialAmmoValues[i] = new ArrayList(32);
			if (SpecialAmmoSection[i] == INVALID_HANDLE || !b_FirstLoad) SpecialAmmoSection[i] = new ArrayList(32);
			if (DrawSpecialAmmoKeys[i] == INVALID_HANDLE || !b_FirstLoad) DrawSpecialAmmoKeys[i] = new ArrayList(32);
			if (DrawSpecialAmmoValues[i] == INVALID_HANDLE || !b_FirstLoad) DrawSpecialAmmoValues[i] = new ArrayList(32);
			if (SpecialAmmoStrengthKeys[i] == INVALID_HANDLE || !b_FirstLoad) SpecialAmmoStrengthKeys[i] = new ArrayList(32);
			if (SpecialAmmoStrengthValues[i] == INVALID_HANDLE || !b_FirstLoad) SpecialAmmoStrengthValues[i] = new ArrayList(32);
			if (WeaponLevel[i] == INVALID_HANDLE || !b_FirstLoad) WeaponLevel[i] = new ArrayList(32);
			if (ExperienceBank[i] == INVALID_HANDLE || !b_FirstLoad) ExperienceBank[i] = new ArrayList(32);
			if (MenuPosition[i] == INVALID_HANDLE || !b_FirstLoad) MenuPosition[i] = new ArrayList(32);
			if (IsClientInRangeSAKeys[i] == INVALID_HANDLE || !b_FirstLoad) IsClientInRangeSAKeys[i] = new ArrayList(32);
			if (IsClientInRangeSAValues[i] == INVALID_HANDLE || !b_FirstLoad) IsClientInRangeSAValues[i] = new ArrayList(32);
			if (InfectedAuraKeys[i] == INVALID_HANDLE || !b_FirstLoad) InfectedAuraKeys[i] = new ArrayList(32);
			if (InfectedAuraValues[i] == INVALID_HANDLE || !b_FirstLoad) InfectedAuraValues[i] = new ArrayList(32);
			if (InfectedAuraSection[i] == INVALID_HANDLE || !b_FirstLoad) InfectedAuraSection[i] = new ArrayList(32);
			if (TalentUpgradeKeys[i] == INVALID_HANDLE || !b_FirstLoad) TalentUpgradeKeys[i] = new ArrayList(32);
			if (TalentUpgradeValues[i] == INVALID_HANDLE || !b_FirstLoad) TalentUpgradeValues[i] = new ArrayList(32);
			if (TalentUpgradeSection[i] == INVALID_HANDLE || !b_FirstLoad) TalentUpgradeSection[i] = new ArrayList(32);
			if (InfectedHealth[i] == INVALID_HANDLE || 	!b_FirstLoad) InfectedHealth[i] = new ArrayList(32);
			if (WitchDamage[i] == INVALID_HANDLE || !b_FirstLoad) WitchDamage[i]	= new ArrayList(32);
			if (SpecialCommon[i] == INVALID_HANDLE || !b_FirstLoad) SpecialCommon[i] = new ArrayList(32);
			if (MenuKeys[i] == INVALID_HANDLE || !b_FirstLoad) MenuKeys[i]								= new ArrayList(32);
			if (MenuValues[i] == INVALID_HANDLE || !b_FirstLoad) MenuValues[i]							= new ArrayList(32);
			if (MenuSection[i] == INVALID_HANDLE || !b_FirstLoad) MenuSection[i]							= new ArrayList(32);
			if (TriggerKeys[i] == INVALID_HANDLE || !b_FirstLoad) TriggerKeys[i]							= new ArrayList(32);
			if (TriggerValues[i] == INVALID_HANDLE || !b_FirstLoad) TriggerValues[i]						= new ArrayList(32);
			if (TriggerSection[i] == INVALID_HANDLE || !b_FirstLoad) TriggerSection[i]						= new ArrayList(32);
			if (AbilityKeys[i] == INVALID_HANDLE || !b_FirstLoad) AbilityKeys[i]							= new ArrayList(32);
			if (AbilityValues[i] == INVALID_HANDLE || !b_FirstLoad) AbilityValues[i]						= new ArrayList(32);
			if (AbilitySection[i] == INVALID_HANDLE || !b_FirstLoad) AbilitySection[i]						= new ArrayList(32);
			if (ChanceKeys[i] == INVALID_HANDLE || !b_FirstLoad) ChanceKeys[i]							= new ArrayList(32);
			if (ChanceValues[i] == INVALID_HANDLE || !b_FirstLoad) ChanceValues[i]							= new ArrayList(32);
			if (PurchaseKeys[i] == INVALID_HANDLE || !b_FirstLoad) PurchaseKeys[i]						= new ArrayList(32);
			if (PurchaseValues[i] == INVALID_HANDLE || !b_FirstLoad) PurchaseValues[i]						= new ArrayList(32);
			if (ChanceSection[i] == INVALID_HANDLE || !b_FirstLoad) ChanceSection[i]						= new ArrayList(32);
			if (a_Database_PlayerTalents[i] == INVALID_HANDLE || !b_FirstLoad) a_Database_PlayerTalents[i]				= new ArrayList(32);
			if (a_Database_PlayerTalents_Experience[i] == INVALID_HANDLE || !b_FirstLoad) a_Database_PlayerTalents_Experience[i] = new ArrayList(32);
			if (PlayerAbilitiesCooldown[i] == INVALID_HANDLE || !b_FirstLoad) PlayerAbilitiesCooldown[i]				= new ArrayList(32);
			if (acdrKeys[i] == INVALID_HANDLE || !b_FirstLoad) acdrKeys[i] = new ArrayList(32);
			if (acdrValues[i] == INVALID_HANDLE || !b_FirstLoad) acdrValues[i] = new ArrayList(32);
			if (acdrSection[i] == INVALID_HANDLE || !b_FirstLoad) acdrSection[i] = new ArrayList(32);
			if (GetLayerStrengthKeys[i] == INVALID_HANDLE || !b_FirstLoad) GetLayerStrengthKeys[i] = new ArrayList(32);
			if (GetLayerStrengthValues[i] == INVALID_HANDLE || !b_FirstLoad) GetLayerStrengthValues[i] = new ArrayList(32);
			if (GetLayerStrengthSection[i] == INVALID_HANDLE || !b_FirstLoad) GetLayerStrengthSection[i] = new ArrayList(32);
			/*if (PlayerAbilitiesImmune[i][i] == INVALID_HANDLE || !b_FirstLoad) {	//[i][i] will NEVER be occupied.
				for (new y = 0; y <= MAXPLAYERS; y++) PlayerAbilitiesImmune[i][y]				= new ArrayList(32);
			}*/
			if (a_Store_Player[i] == INVALID_HANDLE || !b_FirstLoad) a_Store_Player[i]						= new ArrayList(32);
			if (StoreKeys[i] == INVALID_HANDLE || !b_FirstLoad) StoreKeys[i]							= new ArrayList(32);
			if (StoreValues[i] == INVALID_HANDLE || !b_FirstLoad) StoreValues[i]							= new ArrayList(32);
			if (StoreMultiplierKeys[i] == INVALID_HANDLE || !b_FirstLoad) StoreMultiplierKeys[i]					= new ArrayList(32);
			if (StoreMultiplierValues[i] == INVALID_HANDLE || !b_FirstLoad) StoreMultiplierValues[i]				= new ArrayList(32);
			if (StoreTimeKeys[i] == INVALID_HANDLE || !b_FirstLoad) StoreTimeKeys[i]						= new ArrayList(32);
			if (StoreTimeValues[i] == INVALID_HANDLE || !b_FirstLoad) StoreTimeValues[i]						= new ArrayList(32);
			if (LoadStoreSection[i] == INVALID_HANDLE || !b_FirstLoad) LoadStoreSection[i]						= new ArrayList(32);
			if (SaveSection[i] == INVALID_HANDLE || !b_FirstLoad) SaveSection[i]							= new ArrayList(32);
			if (StoreChanceKeys[i] == INVALID_HANDLE || !b_FirstLoad) StoreChanceKeys[i]						= new ArrayList(32);
			if (StoreChanceValues[i] == INVALID_HANDLE || !b_FirstLoad) StoreChanceValues[i]					= new ArrayList(32);
			if (StoreItemNameSection[i] == INVALID_HANDLE || !b_FirstLoad) StoreItemNameSection[i]					= new ArrayList(32);
			if (StoreItemSection[i] == INVALID_HANDLE || !b_FirstLoad) StoreItemSection[i]						= new ArrayList(32);
			if (TrailsKeys[i] == INVALID_HANDLE || !b_FirstLoad) TrailsKeys[i]							= new ArrayList(32);
			if (TrailsValues[i] == INVALID_HANDLE || !b_FirstLoad) TrailsValues[i]							= new ArrayList(32);
			if (DamageKeys[i] == INVALID_HANDLE || !b_FirstLoad) DamageKeys[i]						= new ArrayList(32);
			if (DamageValues[i] == INVALID_HANDLE || !b_FirstLoad) DamageValues[i]					= new ArrayList(32);
			if (DamageSection[i] == INVALID_HANDLE || !b_FirstLoad) DamageSection[i]				= new ArrayList(32);
			if (MOTKeys[i] == INVALID_HANDLE || !b_FirstLoad) MOTKeys[i] = new ArrayList(32);
			if (MOTValues[i] == INVALID_HANDLE || !b_FirstLoad) MOTValues[i] = new ArrayList(32);
			if (MOTSection[i] == INVALID_HANDLE || !b_FirstLoad) MOTSection[i] = new ArrayList(32);
			if (BoosterKeys[i] == INVALID_HANDLE || !b_FirstLoad) BoosterKeys[i]							= new ArrayList(32);
			if (BoosterValues[i] == INVALID_HANDLE || !b_FirstLoad) BoosterValues[i]						= new ArrayList(32);
			if (RPGMenuPosition[i] == INVALID_HANDLE || !b_FirstLoad) RPGMenuPosition[i]						= new ArrayList(32);
			if (ChatSettings[i] == INVALID_HANDLE || !b_FirstLoad) ChatSettings[i]						= new ArrayList(32);
			if (h_KilledPosition_X[i] == INVALID_HANDLE || !b_FirstLoad) h_KilledPosition_X[i]				= new ArrayList(32);
			if (h_KilledPosition_Y[i] == INVALID_HANDLE || !b_FirstLoad) h_KilledPosition_Y[i]				= new ArrayList(32);
			if (h_KilledPosition_Z[i] == INVALID_HANDLE || !b_FirstLoad) h_KilledPosition_Z[i]				= new ArrayList(32);
			if (MeleeKeys[i] == INVALID_HANDLE || !b_FirstLoad) MeleeKeys[i]						= new ArrayList(32);
			if (MeleeValues[i] == INVALID_HANDLE || !b_FirstLoad) MeleeValues[i]					= new ArrayList(32);
			if (MeleeSection[i] == INVALID_HANDLE || !b_FirstLoad) MeleeSection[i]					= new ArrayList(32);
			if (RCAffixes[i] == INVALID_HANDLE || !b_FirstLoad) RCAffixes[i] = new ArrayList(32);
			if (AKKeys[i] == INVALID_HANDLE || !b_FirstLoad) AKKeys[i]						= new ArrayList(32);
			if (AKValues[i] == INVALID_HANDLE || !b_FirstLoad) AKValues[i]					= new ArrayList(32);
			if (AKSection[i] == INVALID_HANDLE || !b_FirstLoad) AKSection[i]					= new ArrayList(32);
			if (SurvivorsIgnored[i] == INVALID_HANDLE || !b_FirstLoad) SurvivorsIgnored[i] = new ArrayList(32);
			if (MyGroup[i] == INVALID_HANDLE || !b_FirstLoad) MyGroup[i] = new ArrayList(32);
			if (PlayerEffectOverTime[i] == INVALID_HANDLE || !b_FirstLoad) PlayerEffectOverTime[i] = new ArrayList(32);
			if (PlayerEffectOverTimeEffects[i] == INVALID_HANDLE || !b_FirstLoad) PlayerEffectOverTimeEffects[i] = new ArrayList(32);
			if (CheckEffectOverTimeKeys[i] == INVALID_HANDLE || !b_FirstLoad) CheckEffectOverTimeKeys[i] = new ArrayList(32);
			if (CheckEffectOverTimeValues[i] == INVALID_HANDLE || !b_FirstLoad) CheckEffectOverTimeValues[i] = new ArrayList(32);
			if (FormatEffectOverTimeKeys[i] == INVALID_HANDLE || !b_FirstLoad) FormatEffectOverTimeKeys[i] = new ArrayList(32);
			if (FormatEffectOverTimeValues[i] == INVALID_HANDLE || !b_FirstLoad) FormatEffectOverTimeValues[i] = new ArrayList(32);
			if (FormatEffectOverTimeSection[i] == INVALID_HANDLE || !b_FirstLoad) FormatEffectOverTimeSection[i] = new ArrayList(32);
			if (CooldownEffectTriggerKeys[i] == INVALID_HANDLE || !b_FirstLoad) CooldownEffectTriggerKeys[i] = new ArrayList(32);
			if (CooldownEffectTriggerValues[i] == INVALID_HANDLE || !b_FirstLoad) CooldownEffectTriggerValues[i] = new ArrayList(32);
			if (IsSpellAnAuraKeys[i] == INVALID_HANDLE || !b_FirstLoad) IsSpellAnAuraKeys[i] = new ArrayList(32);
			if (IsSpellAnAuraValues[i] == INVALID_HANDLE || !b_FirstLoad) IsSpellAnAuraValues[i] = new ArrayList(32);
			if (CallAbilityCooldownTriggerKeys[i] == INVALID_HANDLE || !b_FirstLoad) CallAbilityCooldownTriggerKeys[i] = new ArrayList(32);
			if (CallAbilityCooldownTriggerValues[i] == INVALID_HANDLE || !b_FirstLoad) CallAbilityCooldownTriggerValues[i] = new ArrayList(32);
			if (CallAbilityCooldownTriggerSection[i] == INVALID_HANDLE || !b_FirstLoad) CallAbilityCooldownTriggerSection[i] = new ArrayList(32);
			if (GetIfTriggerRequirementsMetKeys[i] == INVALID_HANDLE || !b_FirstLoad) GetIfTriggerRequirementsMetKeys[i] = new ArrayList(32);
			if (GetIfTriggerRequirementsMetValues[i] == INVALID_HANDLE || !b_FirstLoad) GetIfTriggerRequirementsMetValues[i] = new ArrayList(32);
			if (GetIfTriggerRequirementsMetSection[i] == INVALID_HANDLE || !b_FirstLoad) GetIfTriggerRequirementsMetSection[i] = new ArrayList(32);
			if (GAMKeys[i] == INVALID_HANDLE || !b_FirstLoad) GAMKeys[i] = new ArrayList(32);
			if (GAMValues[i] == INVALID_HANDLE || !b_FirstLoad) GAMValues[i] = new ArrayList(32);
			if (GAMSection[i] == INVALID_HANDLE || !b_FirstLoad) GAMSection[i] = new ArrayList(32);
			if (GetGoverningAttributeKeys[i] == INVALID_HANDLE || !b_FirstLoad) GetGoverningAttributeKeys[i] = new ArrayList(32);
			if (GetGoverningAttributeValues[i] == INVALID_HANDLE || !b_FirstLoad) GetGoverningAttributeValues[i] = new ArrayList(32);
			if (GetGoverningAttributeSection[i] == INVALID_HANDLE || !b_FirstLoad) GetGoverningAttributeSection[i] = new ArrayList(32);
			if (WeaponResultKeys[i] == INVALID_HANDLE || !b_FirstLoad) WeaponResultKeys[i] = new ArrayList(32);
			if (WeaponResultValues[i] == INVALID_HANDLE || !b_FirstLoad) WeaponResultValues[i] = new ArrayList(32);
			if (WeaponResultSection[i] == INVALID_HANDLE || !b_FirstLoad) WeaponResultSection[i] = new ArrayList(32);
			if (GetAbilityCooldownKeys[i] == INVALID_HANDLE || !b_FirstLoad) GetAbilityCooldownKeys[i] = new ArrayList(32);
			if (GetAbilityCooldownValues[i] == INVALID_HANDLE || !b_FirstLoad) GetAbilityCooldownValues[i] = new ArrayList(32);
			if (GetAbilityCooldownSection[i] == INVALID_HANDLE || !b_FirstLoad) GetAbilityCooldownSection[i] = new ArrayList(32);
			if (GetTalentValueSearchKeys[i] == INVALID_HANDLE || !b_FirstLoad) GetTalentValueSearchKeys[i] = new ArrayList(32);
			if (GetTalentValueSearchValues[i] == INVALID_HANDLE || !b_FirstLoad) GetTalentValueSearchValues[i] = new ArrayList(32);
			if (GetTalentValueSearchSection[i] == INVALID_HANDLE || !b_FirstLoad) GetTalentValueSearchSection[i] = new ArrayList(32);
			if (GetTalentKeyValueKeys[i] == INVALID_HANDLE || !b_FirstLoad) GetTalentKeyValueKeys[i] = new ArrayList(32);
			if (GetTalentKeyValueValues[i] == INVALID_HANDLE || !b_FirstLoad) GetTalentKeyValueValues[i] = new ArrayList(32);
			if (GetTalentKeyValueSection[i] == INVALID_HANDLE || !b_FirstLoad) GetTalentKeyValueSection[i] = new ArrayList(32);
			if (ApplyDebuffCooldowns[i] == INVALID_HANDLE || !b_FirstLoad) ApplyDebuffCooldowns[i] = new ArrayList(32);
			if (TalentAtMenuPositionSection[i] == INVALID_HANDLE || !b_FirstLoad) TalentAtMenuPositionSection[i] = new ArrayList(32);
		}

		if (!b_FirstLoad) b_FirstLoad = true;
		//LogMessage("AWAITING PARAMETERS");

		if (!b_ConfigsExecuted) {
			b_ConfigsExecuted = true;
			if (hExecuteConfig == INVALID_HANDLE) hExecuteConfig = CreateTimer(1.0, Timer_ExecuteConfig, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(10.0, Timer_GetCampaignName, _, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	ReadyUp_NtvIsCampaignFinale();
}

public int ReadyUp_GetCampaignStatus(int mapposition) {
	CurrentMapPosition = mapposition;
}

public void OnMapStart() {
	iTopThreat = 0;
	// When the server restarts, for any reason, RPG will properly load.
	//if (!b_FirstLoad) OnMapStartFunc();
	// This can call more than once, and we only want it to fire once.
	// The variable resets to false when a map ends.
	PrecacheModel("models/infected/common_male_clown.mdl", true);
	PrecacheModel("models/infected/common_male_ceda.mdl", true);
	PrecacheModel("models/infected/common_male_fallen_survivor.mdl", true);
	PrecacheModel("models/infected/common_male_riot.mdl", true);
	PrecacheModel("models/infected/common_male_mud.mdl", true);
	PrecacheModel("models/infected/common_male_jimmy.mdl", true);
	PrecacheModel("models/infected/common_male_roadcrew.mdl", true);
	PrecacheModel("models/infected/witch_bride.mdl", true);
	PrecacheModel("models/infected/witch.mdl", true);
	PrecacheModel("models/props_interiors/toaster.mdl", true);
	PrecacheSound(JETPACK_AUDIO, true);

	g_iSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
	g_BeaconSprite = PrecacheModel("materials/sprites/halo01.vmt");
	b_IsActiveRound = false;
	MapRoundsPlayed = 0;
	b_IsCampaignComplete			= false;
	b_IsRoundIsOver					= true;
	b_IsCheckpointDoorStartOpened	= false;
	b_IsMissionFailed				= false;
	CommonInfected.Clear();
	CommonInfectedHealth.Clear();
	SpecialAmmoData.Clear();
	CommonAffixes.Clear();
	WitchList.Clear();
	EffectOverTime.Clear();
	TimeOfEffectOverTime.Clear();
	StaggeredTargets.Clear();
	GetCurrentMap(TheCurrentMap, sizeof(TheCurrentMap));
	Format(CONFIG_MAIN, sizeof(CONFIG_MAIN), "%srpg/%s.cfg", ConfigPathDirectory, TheCurrentMap);
	//LogMessage("CONFIG_MAIN DEFAULT: %s", CONFIG_MAIN);
	if (!FileExists(CONFIG_MAIN)) Format(CONFIG_MAIN, sizeof(CONFIG_MAIN), "rpg/config.cfg");
	else Format(CONFIG_MAIN, sizeof(CONFIG_MAIN), "rpg/%s.cfg", TheCurrentMap);
	FindConVar("director_no_death_check").SetInt(1);
	FindConVar("sv_rescue_disabled").IntValue = 0;
	FindConVar("z_common_limit").SetInt(0);	// there are no commons until the round starts in all game modes to give players a chance to move.
	CheckDifficulty();
	UnhookAll();
}

stock void ResetValues(int client) {

	// Yep, gotta do this *properly*
	b_HasDeathLocation[client] = false;
}

public void OnMapEnd() {
	if (b_IsActiveRound) b_IsActiveRound = false;
	for (int i = 1; i <= MaxClients; i++) {
		if (ISEXPLODE[i] != INVALID_HANDLE) {
			KillTimer(ISEXPLODE[i]);
			ISEXPLODE[i] = INVALID_HANDLE;
		}
	}
	NewUsersRound.Clear();
}

public Action Timer_GetCampaignName(Handle timer) {
	ReadyUp_NtvGetCampaignName();
	return Plugin_Stop;
}

public void OnConfigsExecuted() {
	if (!b_ConfigsExecuted) {
		b_ConfigsExecuted = true;
		if (hExecuteConfig == INVALID_HANDLE) {
			hExecuteConfig = CreateTimer(1.0, Timer_ExecuteConfig, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
		CreateTimer(10.0, Timer_GetCampaignName, _, TIMER_FLAG_NO_MAPCHANGE);
	}
}

stock void CheckGamemode() {
	char TheGamemode[64];
	g_Gamemode.GetString(TheGamemode, sizeof(TheGamemode));
	char TheRequiredGamemode[64];
	GetConfigValue(TheRequiredGamemode, sizeof(TheRequiredGamemode), "gametype?");
	if (!StrEqual(TheGamemode, TheRequiredGamemode, false)) {
		LogMessage("Gamemode did not match, changing to %s", TheRequiredGamemode);
		PrintToChatAll("Gamemode did not match, changing to %s", TheRequiredGamemode);
		g_Gamemode.SetString(TheRequiredGamemode);
		char TheMapname[64];
		GetCurrentMap(TheMapname, sizeof(TheMapname));
		ServerCommand("changelevel %s", TheMapname);
	}
}

public Action Timer_ExecuteConfig(Handle timer) {
	if (ReadyUp_NtvConfigProcessing() == 0) {
		// These are processed one-by-one in a defined-by-dependencies order, but you can place them here in any order you want.
		// I've placed them here in the order they load for uniformality.
		ReadyUp_ParseConfig(CONFIG_MAIN);
		ReadyUp_ParseConfig(CONFIG_EVENTS);
		ReadyUp_ParseConfig(CONFIG_MENUTALENTS);
		ReadyUp_ParseConfig(CONFIG_POINTS);
		ReadyUp_ParseConfig(CONFIG_STORE);
		ReadyUp_ParseConfig(CONFIG_TRAILS);
		ReadyUp_ParseConfig(CONFIG_CHATSETTINGS);
		ReadyUp_ParseConfig(CONFIG_MAINMENU);
		ReadyUp_ParseConfig(CONFIG_WEAPONS);
		ReadyUp_ParseConfig(CONFIG_PETS);
		ReadyUp_ParseConfig(CONFIG_COMMONAFFIXES);

		hExecuteConfig = INVALID_HANDLE;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action Timer_AutoRes(Handle timer) {
	if (b_IsCheckpointDoorStartOpened) return Plugin_Stop;
	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && GetClientTeam(i) == TEAM_SURVIVOR) {

			if (!IsPlayerAlive(i)) SDKCall(hRoundRespawn, i);
			else if (IsIncapacitated(i)) ExecCheatCommand(i, "give", "health");
		}
	}
	return Plugin_Continue;
}

stock bool AnyHumans() {
	for (int i = 1; i <= MaxClients; i++) {
		if (IsLegitimateClient(i) && !IsFakeClient(i)) return true;
	}
	return false;
}

public int ReadyUp_ReadyUpStart() {
	CheckDifficulty();
	CheckGamemode();
	RoundTime = 0;
	b_IsRoundIsOver = true;
	iTopThreat = 0;
	//SetSurvivorsAliveHostname();
	CreateTimer(1.0, Timer_AutoRes, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	/*
	When a new round starts, we want to forget who was the last person to speak on different teams.
	*/
	Format(Public_LastChatUser, sizeof(Public_LastChatUser), "none");
	Format(Spectator_LastChatUser, sizeof(Spectator_LastChatUser), "none");
	Format(Survivor_LastChatUser, sizeof(Survivor_LastChatUser), "none");
	Format(Infected_LastChatUser, sizeof(Infected_LastChatUser), "none");
	bool TeleportPlayers = false;
	float teleportIntoSaferoom[3];
	if (StrEqual(TheCurrentMap, "zerowarn_1r", false)) {
		teleportIntoSaferoom[0] = 4087.998291;
		teleportIntoSaferoom[1] = 11974.557617;
		teleportIntoSaferoom[2] = -300.968750;
		TeleportPlayers = true;
	}
	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i)) {
			if (CurrentMapPosition == 0 && GetClientTeam(i) == TEAM_SURVIVOR) GiveProfileItems(i);
			//if (GetClientTeam(i) == TEAM_SURVIVOR) GiveProfileItems(i);
			if (TeleportPlayers) TeleportEntity(i, teleportIntoSaferoom, NULL_VECTOR, NULL_VECTOR);
			//if (GetClientTeam(i) == TEAM_SURVIVOR && !b_IsLoaded[i]) IsClientLoadedEx(i);
			staggerCooldownOnTriggers[i] = false;
			ISBILED[i] = false;
			iThreatLevel[i] = 0;
			bIsEligibleMapAward[i] = true;
			HealingContribution[i] = 0;
			TankingContribution[i] = 0;
			DamageContribution[i] = 0;
			PointsContribution[i] = 0.0;
			HexingContribution[i] = 0;
			BuffingContribution[i] = 0;
			b_IsFloating[i] = false;
			ISDAZED[i] = 0.0;
			bIsInCombat[i] = false;
			b_IsInSaferoom[i] = true;
			// Anti-Farm/Anti-Camping system stuff.
			h_KilledPosition_X[i].Clear();		// We clear all positions from the array.
			h_KilledPosition_Y[i].Clear();
			h_KilledPosition_Z[i].Clear();
			/*if (b_IsMissionFailed && GetClientTeam(i) == TEAM_SURVIVOR && IsFakeClient(i)) {

				if (!b_IsLoading[i]) {

					b_IsLoaded[i] = false;
					OnClientLoaded(i);
				}
			}*/
		}
	}
	RefreshSurvivorBots();
}

public int ReadyUp_ReadyUpEnd() {
	ReadyUpEnd_Complete();
}

public Action Timer_Defibrillator(Handle timer, any client) {

	if (IsLegitimateClient(client) && !IsPlayerAlive(client)) Defibrillator(0, client);
	return Plugin_Stop;
}

public void ReadyUpEnd_Complete() {
	/*PrintToChatAll("DOor opened");
	b_IsCheckpointDoorStartOpened = true;
	b_IsActiveRound = true;*/
	if (b_IsRoundIsOver) {

		CheckDifficulty();
		b_IsMissionFailed = false;
		//if (ReadyUp_GetGameMode() == 3) {
		b_IsRoundIsOver = false;
		CommonInfected.Clear();
		CommonInfectedHealth.Clear();
		CommonAffixes.Clear();
			//b_IsSurvivalIntermission = true;
			//CreateTimer(5.0, Timer_AutoRes, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		//}
		//RoundTime					=	GetTime();
		b_IsCheckpointDoorStartOpened = false;
		for (int i = 1; i <= MaxClients; i++) {
			if (IsLegitimateClient(i) && IsFakeClient(i) && !b_IsLoaded[i]) IsClientLoadedEx(i);
		}

		if (iRoundStartWeakness == 1) {

			for (int i = 1; i <= MaxClients; i++) {

				if (IsLegitimateClient(i) && GetClientTeam(i) == TEAM_SURVIVOR) {
					staggerCooldownOnTriggers[i] = false;
					ISBILED[i] = false;
					bHasWeakness[i] = true;
					SurvivorEnrage[i][0] = 0.0;
					SurvivorEnrage[i][1] = 0.0;
					ISDAZED[i] = 0.0;
					if (b_IsLoaded[i]) {
						SurvivorStamina[i] = GetPlayerStamina(i) - 1;
						SetMaximumHealth(i);
					}
					else if (!b_IsLoading[i]) OnClientLoaded(i);
					//}
					bIsSurvivorFatigue[i] = false;
					LastWeaponDamage[i] = 1;
					HealingContribution[i] = 0;
					TankingContribution[i] = 0;
					DamageContribution[i] = 0;
					PointsContribution[i] = 0.0;
					HexingContribution[i] = 0;
					BuffingContribution[i] = 0;
					b_IsFloating[i] = false;
					bIsHandicapLocked[i] = false;
				}
			}
		}
	}
}

stock void TimeUntilEnrage(char[] TheText, int TheSize) {
	if (!IsEnrageActive()) {
		int Seconds = (iEnrageTime * 60) - (GetTime() - RoundTime);
		int Minutes = 0;
		while (Seconds >= 60) {

			Seconds -= 60;
			Minutes++;
		}
		if (Seconds == 0) {
			Format(TheText, TheSize, "%d minute", Minutes);
			if (Minutes > 1) Format(TheText, TheSize, "%ss", TheText);
		}
		else if (Minutes == 0) Format(TheText, TheSize, "%d seconds", Seconds);
		else {
			if (Minutes > 1) Format(TheText, TheSize, "%d minutes, %d seconds", Minutes, Seconds);
			else Format(TheText, TheSize, "%d minute, %d seconds", Minutes, Seconds);
		}
	}
	else Format(TheText, TheSize, "ACTIVE");
}

stock int GetSecondsUntilEnrage() {
	int secondsLeftUntilEnrage = (iEnrageTime * 60) - (GetTime() - RoundTime);
	return secondsLeftUntilEnrage;
}

stock int RPGRoundTime(bool IsSeconds = false) {
	int Seconds = GetTime() - RoundTime;
	if (IsSeconds) return Seconds;
	int Minutes = 0;
	while (Seconds >= 60) {
		Minutes++;
		Seconds -= 60;
	}
	return Minutes;
}

stock bool IsEnrageActive() {
	if (!b_IsActiveRound || IsSurvivalMode || iEnrageTime < 1) return false;
	if (RPGRoundTime() < iEnrageTime) return false;
	if (!IsEnrageNotified && iNotifyEnrage == 1) {
		IsEnrageNotified = true;
		PrintToChatAll("%t", "enrage period", orange, blue, orange);
	}
	return true;
}


stock bool PlayerHasWeakness(int client) {
	if (!IsLegitimateClientAlive(client)) return false;
	if (IsSpecialCommonInRange(client, 'w')) return true;
	if (!b_IsCheckpointDoorStartOpened || DoomTimer != 0) return true;
	if (IsClientInRangeSpecialAmmo(client, "W", true) == -2.0) return true;	// the player is not weak if inside cleansing ammo.*
	if (GetTalentStrengthByKeyValue(client, ACTIVATOR_ABILITY_EFFECTS, "weakness") > 0) return true;
	if (LastDeathTime[client] > GetEngineTime()) return true;
	return false;
}

public int ReadyUp_CheckpointDoorStartOpened() {
	if (!b_IsCheckpointDoorStartOpened) {
		b_IsCheckpointDoorStartOpened		= true;
		b_IsActiveRound = true;
		bIsSettingsCheck = true;
		IsEnrageNotified = false;
		b_IsFinaleTanks = false;
		for (int i = 1; i <= MaxClients; i++) {
			if (IsLegitimateClient(i) && IsFakeClient(i) && GetClientTeam(i) == TEAM_INFECTED) ForcePlayerSuicide(i);
		}
		persistentCirculation.Clear();
		CoveredInVomit.Clear();
		RoundStatistics.Clear();
		RoundStatistics.Resize(5);
		for (int i = 0; i < 5; i++) {

			RoundStatistics.Set(i, 0);
			if (CurrentMapPosition == 0) RoundStatistics.Set(i, 0, 1);	// first map of campaign, reset the total.
		}
		char pct[4];
		Format(pct, sizeof(pct), "%");
		int iMaxHandicap = 0;
		int iMinHandicap = RatingPerLevel;
		char text[64];
		int survivorCounter = TotalHumanSurvivors();
		bool AnyBotsOnSurvivorTeam = BotsOnSurvivorTeam();
		for (int i = 1; i <= MaxClients; i++) {
			if (IsLegitimateClient(i)) {
				if (!IsFakeClient(i)) {
					if (iTankRush == 1) RatingHandicap[i] = RatingPerLevel;
					else {
						iMaxHandicap = GetMaxHandicap(i);
						if (RatingHandicap[i] < iMinHandicap) RatingHandicap[i] = iMinHandicap;
						else if (RatingHandicap[i] > iMaxHandicap) RatingHandicap[i] = iMaxHandicap;
					}
					if (GroupMemberBonus > 0.0) {
						if (IsGroupMember[i]) PrintToChat(i, "%T", "group member bonus", i, blue, GroupMemberBonus * 100.0, pct, green, orange);
						else PrintToChat(i, "%T", "group member benefit", i, orange, blue, GroupMemberBonus * 100.0, pct, green, blue);
					}
					if (!AnyBotsOnSurvivorTeam && fSurvivorBotsNoneBonus > 0.0 && survivorCounter <= iSurvivorBotsBonusLimit) {
						PrintToChat(i, "%T", "group no survivor bots bonus", i, blue, fSurvivorBotsNoneBonus * 100.0, pct, green, orange);
					}
				}
				else SetBotHandicap(i);
			}
		}
		if (CurrentMapPosition != 0 || ReadyUpGameMode == 3) CheckDifficulty();
		RoundTime					=	GetTime();
		int ent = -1;
		if (ReadyUpGameMode != 3) {
			while ((ent = FindEntityByClassname(ent, "witch")) != -1) {
				// Some maps, like Hard Rain pre-spawn a ton of witches - we want to add them to the witch table.
				OnWitchCreated(ent);
			}
		}
		else {
			IsSurvivalMode = true;
			for (int i = 1; i <= MaxClients; i++) {
				if (IsLegitimateClientAlive(i) && GetClientTeam(i) == TEAM_SURVIVOR) {
					VerifyMinimumRating(i, true);
					RespawnImmunity[i] = false;
				}
			}
			char TheCurr[64];
			GetCurrentMap(TheCurr, sizeof(TheCurr));
			if (StrContains(TheCurr, "helms_deep", false) != -1) {
				// the bot has to be teleported to the machine gun, because samurai blocks the teleportation in the actual map scripting
				float TeleportBots[3];
				TeleportBots[0] = 1572.749146;
				TeleportBots[1] = -871.468811;
				TeleportBots[2] = 62.031250;
				char TheModel[64];
				for (int i = 1; i <= MaxClients; i++) {
					if (IsLegitimateClientAlive(i) && IsFakeClient(i)) {
						GetClientModel(i, TheModel, sizeof(TheModel));
						if (StrEqual(TheModel, LOUIS_MODEL)) TeleportEntity(i, TeleportBots, NULL_VECTOR, NULL_VECTOR);
					}
				}
				PrintToChatAll("\x04Man the gun, Louis!");
			}
		}
		b_IsCampaignComplete				= false;
		if (ReadyUpGameMode != 3) b_IsRoundIsOver						= false;
		if (ReadyUpGameMode == 2) MapRoundsPlayed = 0;	// Difficulty leniency does not occur in versus.
		SpecialsKilled				=	0;

		// Eyal282 here. Warnings are evil.
		//RoundDamageTotal			=	0;
		//MVPDamage					=	0;
		b_IsFinaleActive			=	false;
		if (GetConfigValueInt("director save priority?") == 1) PrintToChatAll("%t", "Director Priority Save Enabled", white, green);
		char thetext[64];
		GetConfigValue(thetext, sizeof(thetext), "path setting?");
		if (ReadyUpGameMode != 3 && !StrEqual(thetext, "none")) {
			if (!StrEqual(thetext, "random")) ServerCommand("sm_forcepath %s", thetext);
			else {
				if (StrEqual(PathSetting, "none")) {
					int random = GetRandomInt(1, 100);
					if (random <= 33) Format(PathSetting, sizeof(PathSetting), "easy");
					else if (random <= 66) Format(PathSetting, sizeof(PathSetting), "medium");
					else Format(PathSetting, sizeof(PathSetting), "hard");
				}
				ServerCommand("sm_forcepath %s", PathSetting);
			}
		}
		//new RatingLevelMultiplier = GetConfigValueInt("rating level multiplier?");
		for (int i = 1; i <= MaxClients; i++) {
			if (IsLegitimateClient(i) && GetClientTeam(i) == TEAM_SURVIVOR) {
				if (!IsPlayerAlive(i)) SDKCall(hRoundRespawn, i);
				VerifyMinimumRating(i);
				HealImmunity[i] = false;
				//DefaultHealth[i] = StringToInt(GetConfigValue("survivor health?"));
				//PlayerSpawnAbilityTrigger(i);
				//RefreshSurvivor(i);
				//SetClientMovementSpeed(i);
				//ResetCoveredInBile(i);
				//BlindPlayer(i);
				//GiveMaximumHealth(i);
				if (b_IsLoaded[i]) GiveMaximumHealth(i);
				else if (!b_IsLoading[i]) OnClientLoaded(i);
			}
		}
		f_TankCooldown				=	-1.0;
		ResetCDImmunity(-1);
		DoomTimer = 0;
		if (ReadyUpGameMode != 2) {
			// It destroys itself when a round ends.
			CreateTimer(1.0, Timer_DirectorPurchaseTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
		if (!bIsSoloHandicap && RespawnQueue > 0) CreateTimer(1.0, Timer_RespawnQueue, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		RaidInfectedBotLimit();
		CreateTimer(1.0, Timer_StartPlayerTimers, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		//CreateTimer(1.0, Timer_ShowHUD, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		//CreateTimer(1.0, Timer_DisplayHUD, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		//CreateTimer(1.0, Timer_AwardSkyPoints, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(1.0, Timer_CheckIfHooked, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(GetConfigValueFloat("settings check interval?"), Timer_SettingsCheck, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		//CreateTimer(fSpecialAmmoInterval, Timer_AmmoActiveTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		//CreateTimer(fEffectOverTimeInterval, Timer_EffectOverTime, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		if (DoomSUrvivorsRequired != 0) CreateTimer(1.0, Timer_Doom, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		//CreateTimer(fSpecialAmmoInterval, Timer_SpecialAmmoData, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		//CreateTimer(1.0, Timer_PlayTime, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(0.5, Timer_EntityOnFire, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);		// Fire status effect
		CreateTimer(1.0, Timer_ThreatSystem, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);		// threat system modulator
		//CreateTimer(0.1, Timer_IsSpecialCommonInRange, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);	// some special commons react based on range, not damage.
		CreateTimer(fStaggerTickrate, Timer_StaggerTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		if (GetConfigValueInt("common affixes?") > 0) {
			CommonAffixes.Clear();
			CreateTimer(1.0, Timer_CommonAffixes, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
		ClearRelevantData();
		LastLivingSurvivor = 1;
		int size = a_DirectorActions.Length;
		a_DirectorActions_Cooldown.Resize(size);
		for (int i = 0; i < size; i++) a_DirectorActions_Cooldown.SetString(i, "0");
		//if (CommonInfectedQueue == INVALID_HANDLE) CommonInfectedQueue = new ArrayList(32);
		//CommonInfectedQueue.Clear();
		int theCount = LivingSurvivorCount();
		if (theCount >= iSurvivorModifierRequired) {
			PrintToChatAll("%t", "teammate bonus experience", blue, green, ((theCount - (iSurvivorModifierRequired - 1)) * fSurvivorExpMult) * 100.0, pct);
		}
		RefreshSurvivorBots();
		if (iEnrageTime > 0) {
			TimeUntilEnrage(text, sizeof(text));
			PrintToChatAll("%t", "time until things get bad", orange, green, text, orange);
		}
	}
}

stock void RefreshSurvivorBots() {
	for (int i = 1; i <= MaxClients; i++) {
		if (IsSurvivorBot(i)) {
			//if (!IsPlayerAlive(i)) SDKCall(hRoundRespawn, i);
			RefreshSurvivor(i);
		}
	}
}

stock void SetClientMovementSpeed(int client) {
	if (IsValidEntity(client)) SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", fBaseMovementSpeed);
}

stock void ResetCoveredInBile(int client) {
	for (int i = 1; i <= MaxClients; i++) {
		if (IsLegitimateClient(i)) {
			CoveredInBile[client][i] = -1;
			CoveredInBile[i][client] = -1;
		}
	}
}

stock int FindTargetClient(int client, char[] arg) {
	bool tn_is_ml;
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	int targetclient;
	if ((target_count = ProcessTargetString(
		arg,
		client,
		target_list,
		MAXPLAYERS,
		COMMAND_FILTER_CONNECTED,
		target_name,
		sizeof(target_name),
		tn_is_ml)) > 0)
	{
		for (int i = 0; i < target_count; i++) targetclient = target_list[i];
	}
	return targetclient;
}

stock void CMD_CastAction(int client, int args) {
	char actionpos[64];
	GetCmdArg(1, actionpos, sizeof(actionpos));
	if (StrContains(actionpos, "action", false) != -1) {
		CastActionEx(client, actionpos, sizeof(actionpos));
	}
}

stock void CastActionEx(int client, char[] t_actionpos = "none", int TheSize, int pos = -1) {
	int ActionSlots = iActionBarSlots;
	char actionpos[64];
	if (pos == -1) pos = StringToInt(t_actionpos[strlen(t_actionpos) - 1]) - 1;//StringToInt(actionpos[strlen(actionpos) - 1]);
	if (pos >= 0 && pos < ActionSlots) {
		//pos--;	// shift down 1 for the array.
		ActionBar[client].GetString(pos, actionpos, sizeof(actionpos));
		if (IsTalentExists(actionpos)) { //PrintToChat(client, "%T", "Action Slot Empty", client, white, orange, blue, pos+1);
			int size =	a_Menu_Talents.Length;
			int RequiresTarget = 0;
			int AbilityTalent = 0;
			float TargetPos[3];
			char TalentName[64];
			float visualDelayTime = 0.0;
			for (int i = 0; i < size; i++) {
				CastKeys[client]			= a_Menu_Talents.Get(i, 0);
				CastValues[client]			= a_Menu_Talents.Get(i, 1);
				CastSection[client]			= a_Menu_Talents.Get(i, 2);
				CastSection[client].GetString(0, TalentName, sizeof(TalentName));
				if (!StrEqual(TalentName, actionpos)) continue;
				AbilityTalent = GetKeyValueIntAtPos(CastValues[client], IS_TALENT_ABILITY);
				if (GetKeyValueIntAtPos(CastValues[client], ABILITY_PASSIVE_ONLY) == 1) continue;
				if (AbilityTalent != 1 && GetTalentStrength(client, actionpos) < 1) {
					// talent exists but user has no points in it from a respec or whatever so we remove it.
					// we don't tell them either, next time they use it they'll find out.
					Format(actionpos, TheSize, "none");
					ActionBar[client].SetString(pos, actionpos);
				}
				else {
					RequiresTarget = GetKeyValueIntAtPos(CastValues[client], ABILITY_IS_SINGLE_TARGET);
					visualDelayTime = GetKeyValueFloatAtPos(CastValues[client], ABILITY_DRAW_DELAY);
					if (visualDelayTime < 1.0) visualDelayTime = 1.0;
					if (RequiresTarget > 0) {
						//GetClientAimTargetEx(client, actionpos, TheSize, true);
						RequiresTarget = GetAimTargetPosition(client, TargetPos);//StringToInt(actionpos);
						if (IsLegitimateClientAlive(RequiresTarget)) {
							if (AbilityTalent != 1) CastSpell(client, RequiresTarget, TalentName, TargetPos, visualDelayTime);
							else UseAbility(client, RequiresTarget, TalentName, CastKeys[client], CastValues[client], TargetPos);
						}
					}
					else {
						GetAimTargetPosition(client, TargetPos);
						/*GetClientAimTargetEx(client, actionpos, TheSize);
						ExplodeString(actionpos, " ", tTargetPos, 3, 64);
						TargetPos[0] = StringToFloat(tTargetPos[0]);
						TargetPos[1] = StringToFloat(tTargetPos[1]);
						TargetPos[2] = StringToFloat(tTargetPos[2]);*/
						if (AbilityTalent != 1) CastSpell(client, _, TalentName, TargetPos, visualDelayTime);
						else {
							CheckActiveAbility(client, pos, _, _, true, true);
							UseAbility(client, _, TalentName, CastKeys[client], CastValues[client], TargetPos);
						}
					}
				}
				break;
			}
		}
	}
	else {
		PrintToChat(client, "%T", "Action Slot Range", client, white, blue, ActionSlots, white);
	}
}

public Action CMD_ChatTag(int client, int args) {

	if (IsReserve(client) && args > 0 || GetConfigValueInt("all players chat settings?") == 1) {

		char arg[64];
		GetCmdArg(1, arg, sizeof(arg));
		if (strlen(arg) > GetConfigValueInt("tag name max length?")) PrintToChat(client, "%T", "Tag Name Too Long", client, GetConfigValueInt("tag name max length?"));
		else if (strlen(arg) > 1) {
		
			ReplaceString(arg, sizeof(arg), "+", " ");
			ChatSettings[client].SetString(1, arg);
			PrintToChat(client, "%T", "Tag Name Set", client, arg);
		}
		else {

			//Handle:ChatSettings[client].GetString(1, arg, sizeof(arg));
			GetClientName(client, arg, sizeof(arg));
			ChatSettings[client].SetString(1, arg);
			PrintToChat(client, "%T", "Tag Name Set", client, arg);
		}
	}
	return Plugin_Handled;
}

stock int MySurvivorCompanion(int client) {

	char SteamId[64], CompanionSteamId[64];
	GetClientAuthId(client, AuthId_Steam2, SteamId, sizeof(SteamId));

	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && GetClientTeam(i) == TEAM_SURVIVOR && IsFakeClient(i)) {

			GetEntPropString(i, Prop_Data, "m_iName", CompanionSteamId, sizeof(CompanionSteamId));
			if (StrEqual(CompanionSteamId, SteamId, false)) return i;
		}
	}
	return -1;
}

public Action CMD_CompanionOptions(int client, int args) {

	/*if (GetClientTeam(client) != TEAM_SURVIVOR) return Plugin_Handled;
	decl String:TheCommand[64], String:TheName[64], String:tquery[512], String:thetext[64], String:SteamId[64];
	GetCmdArg(1, TheCommand, sizeof(TheCommand));
	if (args > 1) {

		new companion = MySurvivorCompanion(client);

		if (companion == -1) {	// no companion active.

			if (StrEqual(TheCommand, "create", false)) {	// creates a companion.

				if (args == 2) {

					GetCmdArg(2, TheName, sizeof(TheName));
					ReplaceString(TheName, sizeof(TheName), "+", " ");

					Format(CompanionNameQueue[client], sizeof(CompanionNameQueue[]), "%s", TheName);
					GetClientAuthString(client, SteamId, sizeof(SteamId));

					Format(tquery, sizeof(tquery), "SELECT COUNT(*) FROM `%s` WHERE `companionowner` = '%s';", TheDBPrefix, SteamId);
					hDatabase.Query(Query_CheckCompanionCount, tquery, client);
				}
				else {

					GetConfigValue(thetext, sizeof(thetext), "companion command?");
					PrintToChat(client, "!%s create <name>", thetext);
				}
			}
			else if (StrEqual(TheCommand, "load", false)) {	// opens the comapnion load menu.

			}
		}
		else {	// player has a companion active.

			if (StrEqual(TheCommand, "delete", false)) {	// we delete the companion.

			}
			else if (StrEqual(TheCommand, "edit", false)) {	// opens the talent menu for the companion.

			}
			else if (StrEqual(TheCommand, "save", false)) {	// saves the companion, you should always do this before loading a new one.

			}
		}
	}
	else {

		// display the available commands to the user.
	}*/
	return Plugin_Handled;
}

public Action CMD_TogglePvP(int client, int args) {
	int TheTime = RoundToCeil(GetEngineTime());
	if (IsPvP[client] != 0) {
		if (IsPvP[client] + 30 <= TheTime) {
			IsPvP[client] = 0;
			PrintToChat(client, "%T", "PvP Disabled", client, white, orange);
		}
	}
	else {
		IsPvP[client] = TheTime + 30;
		PrintToChat(client, "%T", "PvP Enabled", client, white, blue);
	}
	return Plugin_Handled;
}

public Action CMD_GiveLevel(int client, int args) {
	char thetext[64];
	GetConfigValue(thetext, sizeof(thetext), "give player level flags?");
	if ((HasCommandAccess(client, thetext) || client == 0) && args > 1) {
		char arg[MAX_NAME_LENGTH], arg2[64], arg3[64];
		GetCmdArg(1, arg, sizeof(arg));
		GetCmdArg(2, arg2, sizeof(arg2));
		GetCmdArg(3, arg3, sizeof(arg3));
		int targetclient = FindTargetClient(client, arg);
		if (args < 3) {
			if (IsLegitimateClient(targetclient) && PlayerLevel[targetclient] != StringToInt(arg2)) {

				SetTotalExperienceByLevel(targetclient, StringToInt(arg2));
				char Name[64];
				GetClientName(targetclient, Name, sizeof(Name));
				if (client > 0) PrintToChat(client, "%T", "client level set", client, Name, green, white, blue, PlayerLevel[targetclient]);
				else PrintToServer("set %N level to %d", Name, PlayerLevel[targetclient]);
			}
		}
		else {

			if (IsLegitimateClient(targetclient)) {

				if (StrContains(arg3, "rating", false) != -1) Rating[targetclient] = StringToInt(arg2);
				else ModifyCartelValue(targetclient, arg3, StringToInt(arg2));
			}
		}
	}

	return Plugin_Handled;
}

stock int GetPlayerLevel(int client) {
	int iExperienceOverall = ExperienceOverall[client];
	int iLevel = 1;
	int ExperienceRequirement = CheckExperienceRequirement(client, false, iLevel);
	while (iExperienceOverall >= ExperienceRequirement && iLevel < iMaxLevel) {
		if (iIsLevelingPaused[client] == 1 && iExperienceOverall == ExperienceRequirement) break;
		iExperienceOverall -= ExperienceRequirement;
		iLevel++;
		ExperienceRequirement = CheckExperienceRequirement(client, false, iLevel);
	}
	return iLevel;
}

stock void SetTotalExperienceByLevel(int client, int newlevel, bool giveMaxXP = false) {

	int oldlevel = PlayerLevel[client];
	ExperienceOverall[client] = 0;
	ExperienceLevel[client] = 0;
	if (newlevel > iMaxLevel) newlevel = iMaxLevel;
	PlayerLevel[client] = newlevel;
	for (int i = 1; i <= newlevel; i++) {

		if (newlevel == i) break;
		ExperienceOverall[client] += CheckExperienceRequirement(client, false, i);
	}

	ExperienceOverall[client]++;
	ExperienceLevel[client]++;	// i don't like 0 / level, so i always do 1 / level as the minimum.
	if (giveMaxXP) ExperienceOverall[client] = CheckExperienceRequirement(client, false, iMaxLevel);
	if (oldlevel > PlayerLevel[client]) ChallengeEverything(client);
	else if (PlayerLevel[client] > oldlevel) {
		FreeUpgrades[client] += (PlayerLevel[client] - oldlevel);
	}
}

public Action CMD_ReloadConfigs(int client, int args) {

	char thetext[64];
	GetConfigValue(thetext, sizeof(thetext), "reload configs flags?");

	if (HasCommandAccess(client, thetext)) {

		CreateTimer(1.0, Timer_ExecuteConfig, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		PrintToChat(client, "Reloading Config.");
	}

	return Plugin_Handled;
}

public int ReadyUp_FirstClientLoaded() {

	//CreateTimer(1.0, Timer_ShowHUD, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	OnMapStartFunc();
	RefreshSurvivorBots();
	ReadyUpGameMode = ReadyUp_GetGameMode();
}

public Action CMD_SharePoints(int client, int args) {

	if (args < 2) {

		char thetext[64];
		GetConfigValue(thetext, sizeof(thetext), "reload configs flags?");

		PrintToChat(client, "%T", "Share Points Syntax", client, orange, white, thetext);
		return Plugin_Handled;
	}

	char arg[MAX_NAME_LENGTH], arg2[10];
	GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, arg2, sizeof(arg2));
	float SharePoints = 0.0;
	if (StrContains(arg2, ".", false) == -1) SharePoints = StringToInt(arg2) * 1.0;
	else SharePoints = StringToFloat(arg2);

	if (SharePoints > Points[client]) return Plugin_Handled;

	int targetclient = FindTargetClient(client, arg);
	if (!IsLegitimateClient(targetclient)) return Plugin_Handled;

	char Name[MAX_NAME_LENGTH];
	GetClientName(targetclient, Name, sizeof(Name));
	char GiftName[MAX_NAME_LENGTH];
	GetClientName(client, GiftName, sizeof(GiftName));

	Points[client] -= SharePoints;
	Points[targetclient] += SharePoints;

	PrintToChatAll("%t", "Share Points Given", blue, GiftName, white, green, SharePoints, white, blue, Name); 
	return Plugin_Handled;
}

stock int GetMaxHandicap(int client) {

	int iMaxHandicap = RatingPerHandicap;
	iMaxHandicap *= CartelLevel(client);
	iMaxHandicap += RatingPerLevel;

	return iMaxHandicap;
}

stock void VerifyHandicap(int client) {

	int iMaxHandicap = GetMaxHandicap(client);
	int iMinHandicap = RatingPerLevel;

	if (RatingHandicap[client] < iMinHandicap) RatingHandicap[client] = iMinHandicap;
	if (RatingHandicap[client] > iMaxHandicap) RatingHandicap[client] = iMaxHandicap;
}

public Action CMD_Handicap(int client, int args) {
	if (iIsRatingEnabled != 1) return Plugin_Handled;
	int iMaxHandicap = GetMaxHandicap(client);
	int iMinHandicap = RatingPerLevel;
	if (RatingHandicap[client] < iMinHandicap) RatingHandicap[client] = iMinHandicap;
	if (RatingHandicap[client] > iMaxHandicap) RatingHandicap[client] = iMaxHandicap;
	if (args < 1) {

		PrintToChat(client, "%T", "handicap range", client, white, orange, iMinHandicap, white, orange, iMaxHandicap);
	}
	else {
		if (!bIsHandicapLocked[client]) {
			char arg[10];
			GetCmdArg(1, arg, sizeof(arg));
			int iSetHandicap = StringToInt(arg);
			if (iSetHandicap >= iMinHandicap && iSetHandicap <= iMaxHandicap) {
				RatingHandicap[client] = iSetHandicap;
			}
			else if (iSetHandicap < iMinHandicap) RatingHandicap[client] = iMinHandicap;
			else if (iSetHandicap > iMaxHandicap) RatingHandicap[client] = iMaxHandicap;
		}
		else {
			PrintToChat(client, "%T", "player handicap locked", client, orange);
		}
	}

	PrintToChat(client, "%T", "player handicap", client, blue, orange, green, RatingHandicap[client]);
	return Plugin_Handled;
}

stock int SetBotHandicap(int client) {
	if (IsSurvivorBot(client)) {
		int iLowHandicap = RatingPerLevel;
		for (int i = 1; i <= MaxClients; i++) {
			if (!IsLegitimateClient(i) || GetClientTeam(i) != TEAM_SURVIVOR) continue;
			if (RatingHandicap[i] > iLowHandicap) iLowHandicap = RatingHandicap[i];
		}
		RatingHandicap[client] = iLowHandicap;
	}
	return RatingHandicap[client];
}

public Action CMD_ActionBar(int client, int args) {
	if (!DisplayActionBar[client]) {
		PrintToChat(client, "%T", "action bar displayed", client, white, blue);
		DisplayActionBar[client] = true;
	}
	else {
		PrintToChat(client, "%T", "action bar hidden", client, white, orange);
		DisplayActionBar[client] = false;
		ActionBarSlot[client] = -1;
	}
	return Plugin_Handled;
}

public Action CMD_GiveStorePoints(int client, int args) {
	char thetext[64];
	GetConfigValue(thetext, sizeof(thetext), "give store points flags?");
	if (!HasCommandAccess(client, thetext)) { PrintToChat(client, "You don't have access."); return Plugin_Handled; }
	if (args < 2) {
		PrintToChat(client, "%T", "Give Store Points Syntax", client, orange, white);
		return Plugin_Handled;
	}
	char arg[MAX_NAME_LENGTH], arg2[4];
	GetCmdArg(1, arg, sizeof(arg));
	if (args > 1) {
		GetCmdArg(2, arg2, sizeof(arg2));
	}
	int targetclient = FindTargetClient(client, arg);
	char Name[MAX_NAME_LENGTH];
	GetClientName(targetclient, Name, sizeof(Name));
	SkyPoints[targetclient] += StringToInt(arg2);
	PrintToChat(client, "%T", "Store Points Award Given", client, white, green, arg2, white, orange, Name);
	PrintToChat(targetclient, "%T", "Store Points Award Received", client, white, green, arg2, white);
	return Plugin_Handled;
}

public int ReadyUp_CampaignComplete() {
	if (!b_IsCampaignComplete) {
		b_IsCampaignComplete			= true;
		CallRoundIsOver();
		WipeDebuffs(true);
	}
}

public Action CMD_MyWeapon(int client, int args){
	char myWeapon[64];
	GetWeaponName(client, myWeapon, sizeof(myWeapon));
	PrintToChat(client, "%s", myWeapon);
	return Plugin_Handled;
}
public Action CMD_CollectBonusExperience(int client, int args) {
	/*if (CurrentMapPosition != 0 && RoundExperienceMultiplier[client] > 0.0 && BonusContainer[client] > 0 && !b_IsActiveRound) {
		new RewardWaiting = RoundToCeil(BonusContainer[client] * RoundExperienceMultiplier[client]);
		ExperienceLevel[client] += RewardWaiting;
		ExperienceOverall[client] += RewardWaiting;
		decl String:Name[64];
		GetClientName(client, Name, sizeof(Name));
		PrintToChatAll("%t", "collected bonus container", blue, Name, white, green, blue, AddCommasToString(RewardWaiting));
		BonusContainer[client] = 0;
		RoundExperienceMultiplier[client] = 0.0;
		ConfirmExperienceAction(client);
	}*/

	return Plugin_Handled;
}

public int ReadyUp_RoundIsOver(int gamemode) {
	CallRoundIsOver();
}

public Action Timer_SaveAndClear(Handle timer) {
	int LivingSurvs = TotalHumanSurvivors();
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i)) continue;
		//ToggleTank(i, true);
		if (b_IsMissionFailed && LivingSurvs > 0 && GetClientTeam(i) == TEAM_SURVIVOR) {
			RoundExperienceMultiplier[i] = 0.0;
			// So, the round ends due a failed mission, whether it's coop or survival, and we reset all players ratings.
			VerifyMinimumRating(i, true);
		}
		if(iChaseEnt[i] && EntRefToEntIndex(iChaseEnt[i]) != INVALID_ENT_REFERENCE) AcceptEntityInput(iChaseEnt[i], "Kill");
		iChaseEnt[i] = -1;
		SaveAndClear(i);
	}
	return Plugin_Stop;
}

stock void CallRoundIsOver() {
	if (!b_IsRoundIsOver) {
		for (int i = 0; i < 5; i++) {
			RoundStatistics.Set(i, RoundStatistics.Get(i) + RoundStatistics.Get(i, 1), 1);
		}
		int pEnt = -1;
		char pText[2][64];
		char text[64];
		int pSize = persistentCirculation.Length;
		for (int i = 0; i < pSize; i++) {
			persistentCirculation.GetString(i, text, sizeof(text));
			ExplodeString(text, ":", pText, 2, 64);
			pEnt = StringToInt(pText[0]);
			if (IsValidEntity(pEnt)) AcceptEntityInput(pEnt, "Kill");
		}
		persistentCirculation.Clear();
		b_IsRoundIsOver					= true;
		for (int i = 1; i <= MaxClients; i++) {
			if (IsLegitimateClient(i)) bTimersRunning[i] = false;
		}
		if (b_IsActiveRound) b_IsActiveRound = false;
		//SetSurvivorsAliveHostname();
		if (!b_IsMissionFailed) {
			//InfectedLevel = HumanSurvivorLevels();
			if (!IsSurvivalMode) {
				for (int i = 1; i <= MaxClients; i++) {
					if (IsLegitimateClient(i)) {
						WitchDamage[i].Clear();
						InfectedHealth[i].Clear();
						SpecialCommon[i].Clear();
						ImmuneToAllDamage[i] = false;
						iThreatLevel[i] = 0;
						bIsInCombat[i] = false;
						fSlowSpeed[i] = 1.0;
						if (GetClientTeam(i) == TEAM_SURVIVOR && IsPlayerAlive(i)) {
							if (Rating[i] < 0 && CurrentMapPosition != 1) VerifyMinimumRating(i);
							if (RoundExperienceMultiplier[i] < 0.0) RoundExperienceMultiplier[i] = 0.0;
							if (CurrentMapPosition != 1) {

								RoundExperienceMultiplier[i] += fCoopSurvBon;
								//PrintToChat(i, "xp bonus of %3.3f added : %3.3f bonus", fCoopSurvBon, RoundExperienceMultiplier[i]);
 							}
							//else PrintToChat(i, "no round bonus applied.");
							AwardExperience(i, _, _, true);
						}
					}
				}
			}
		}
		CreateTimer(1.0, Timer_SaveAndClear, _, TIMER_FLAG_NO_MAPCHANGE);
		b_IsCheckpointDoorStartOpened	= false;
		RemoveImmunities(-1);
		LoggedUsers.Clear();		// when a round ends, logged users are removed.
		b_IsActiveRound = false;
		MapRoundsPlayed++;
		int Seconds			= GetTime() - RoundTime;
		int Minutes			= 0;
		while (Seconds >= 60) {
			Minutes++;
			Seconds -= 60;
		}
		//common is 0
		//super is 1
		//witch is 2
		//si is 3
		//tank is 4
		char roundStatisticsText[6][64];
		PrintToChatAll("%t", "Round Time", orange, blue, Minutes, white, blue, Seconds, white);
		if (CurrentMapPosition != 1) {
			AddCommasToString(RoundStatistics.Get(0), roundStatisticsText[0], sizeof(roundStatisticsText[]));
			AddCommasToString(RoundStatistics.Get(1), roundStatisticsText[1], sizeof(roundStatisticsText[]));
			AddCommasToString(RoundStatistics.Get(2), roundStatisticsText[2], sizeof(roundStatisticsText[]));
			AddCommasToString(RoundStatistics.Get(3), roundStatisticsText[3], sizeof(roundStatisticsText[]));
			AddCommasToString(RoundStatistics.Get(4), roundStatisticsText[4], sizeof(roundStatisticsText[]));
			AddCommasToString(RoundStatistics.Get(0) + RoundStatistics.Get(1) + RoundStatistics.Get(2) + RoundStatistics.Get(3) + RoundStatistics.Get(4), roundStatisticsText[5], sizeof(roundStatisticsText[]));

			PrintToChatAll("%t", "round statistics", orange, orange, blue,
							roundStatisticsText[0], orange, blue,
							roundStatisticsText[1], orange, blue,
							roundStatisticsText[2], orange, blue,
							roundStatisticsText[3], orange, blue,
							roundStatisticsText[4], orange, green,
							roundStatisticsText[5]);
		}
		else {
			AddCommasToString(RoundStatistics.Get(0, 1), roundStatisticsText[0], sizeof(roundStatisticsText[]));
			AddCommasToString(RoundStatistics.Get(1, 1), roundStatisticsText[1], sizeof(roundStatisticsText[]));
			AddCommasToString(RoundStatistics.Get(2, 1), roundStatisticsText[2], sizeof(roundStatisticsText[]));
			AddCommasToString(RoundStatistics.Get(3, 1), roundStatisticsText[3], sizeof(roundStatisticsText[]));
			AddCommasToString(RoundStatistics.Get(4, 1), roundStatisticsText[4], sizeof(roundStatisticsText[]));
			AddCommasToString(RoundStatistics.Get(0, 1) + RoundStatistics.Get(1, 1) + RoundStatistics.Get(2, 1) + RoundStatistics.Get(3, 1) + RoundStatistics.Get(4, 1), roundStatisticsText[5], sizeof(roundStatisticsText[]));

			PrintToChatAll("%t", "campaign statistics", orange, orange, blue,
							roundStatisticsText[0], orange, blue,
							roundStatisticsText[1], orange, blue,
							roundStatisticsText[2], orange, blue,
							roundStatisticsText[3], orange, blue,
							roundStatisticsText[4], orange, green,
							roundStatisticsText[5]);
		}
		CommonInfected.Clear();
		WitchList.Clear();
		CommonList.Clear();
		EntityOnFire.Clear();
		EntityOnFireName.Clear();
		CommonInfectedQueue.Clear();
		SuperCommonQueue.Clear();
		StaggeredTargets.Clear();
		CommonInfectedHealth.Clear();
		SpecialAmmoData.Clear();
		CommonAffixes.Clear();
		EffectOverTime.Clear();
		TimeOfEffectOverTime.Clear();
		if (b_IsMissionFailed && StrContains(TheCurrentMap, "zerowarn", false) != -1) {
			PrintToChatAll("\x04Zero warning:\n\nThis campaign requires map restart on missionFail to prevent serverCrash.\nSorry for the inconvenience, Data will be preserved!!!");
			LogMessage("restarting zero warning.");
			// need to force-teleport players here on new spawn: 4087.998291 11974.557617 -269.968750
			CreateTimer(5.0, Timer_ResetMap, _, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public Action Timer_ResetMap(Handle timer) {
	ServerCommand("changelevel %s", TheCurrentMap);
	return Plugin_Stop;
}

stock void ResetArray(ArrayList TheArray) {

	TheArray.Clear();
}

public int ReadyUp_ParseConfigFailed(char[] config, char[] error) {

	if (StrEqual(config, CONFIG_MAIN) ||
		StrEqual(config, CONFIG_EVENTS) ||
		StrEqual(config, CONFIG_MENUTALENTS) ||
		StrEqual(config, CONFIG_MAINMENU) ||
		StrEqual(config, CONFIG_POINTS) ||
		StrEqual(config, CONFIG_STORE) ||
		StrEqual(config, CONFIG_TRAILS) ||
		StrEqual(config, CONFIG_CHATSETTINGS) ||
		StrEqual(config, CONFIG_WEAPONS) ||
		StrEqual(config, CONFIG_PETS) ||
		StrEqual(config, CONFIG_COMMONAFFIXES)) {

		SetFailState("%s , %s", config, error);
	}
}

public int ReadyUp_LoadFromConfigEx(Handle key1, Handle value1, Handle section1, char[] configname, int keyCount) {
	//PrintToChatAll("Size: %d config: %s", Handle:key.Length, configname);

	ArrayList key = view_as<ArrayList>(key1);
	ArrayList value = view_as<ArrayList>(value1);
	ArrayList section = view_as<ArrayList>(section1);

	if (!StrEqual(configname, CONFIG_MAIN) &&
		!StrEqual(configname, CONFIG_EVENTS) &&
		!StrEqual(configname, CONFIG_MENUTALENTS) &&
		!StrEqual(configname, CONFIG_MAINMENU) &&
		!StrEqual(configname, CONFIG_POINTS) &&
		!StrEqual(configname, CONFIG_STORE) &&
		!StrEqual(configname, CONFIG_TRAILS) &&
		!StrEqual(configname, CONFIG_CHATSETTINGS) &&
		!StrEqual(configname, CONFIG_WEAPONS) &&
		!StrEqual(configname, CONFIG_PETS) &&
		!StrEqual(configname, CONFIG_COMMONAFFIXES)) return;
	char s_key[512];
	char s_value[512];
	char s_section[512];
	ArrayList TalentKeys = new ArrayList(32);
	ArrayList TalentValues = new ArrayList(32);
	ArrayList TalentSection = new ArrayList(32);
	int lastPosition = 0;
	int counter = 0;
	if (keyCount > 0) {
		if (StrEqual(configname, CONFIG_MENUTALENTS)) a_Menu_Talents.Resize(keyCount);
		else if (StrEqual(configname, CONFIG_MAINMENU)) a_Menu_Main.Resize(keyCount);
		else if (StrEqual(configname, CONFIG_EVENTS)) a_Events.Resize(keyCount);
		else if (StrEqual(configname, CONFIG_POINTS)) a_Points.Resize(keyCount);
		else if (StrEqual(configname, CONFIG_PETS)) a_Pets.Resize(keyCount);
		else if (StrEqual(configname, CONFIG_STORE)) a_Store.Resize(keyCount);
		else if (StrEqual(configname, CONFIG_TRAILS)) a_Trails.Resize(keyCount);
		else if (StrEqual(configname, CONFIG_CHATSETTINGS)) a_ChatSettings.Resize(keyCount);
		else if (StrEqual(configname, CONFIG_WEAPONS)) a_WeaponDamages.Resize(keyCount);
		else if (StrEqual(configname, CONFIG_COMMONAFFIXES)) a_CommonAffixes.Resize(keyCount);
	}
	int a_Size						= key.Length;
	for (int i = 0; i < a_Size; i++) {
		key.GetString(i, s_key, sizeof(s_key));
		value.GetString(i, s_value, sizeof(s_value));
		TalentKeys.PushString(s_key);
		TalentValues.PushString(s_value);

		if (StrEqual(configname, CONFIG_MAIN)) {

			MainKeys.PushString(s_key);
			MainValues.PushString(s_value);
			if (StrEqual(s_key, "rpg mode?")) {

				CurrentRPGMode = StringToInt(s_value);
				LogMessage("=====\t\tRPG MODE SET TO %d\t\t=====", CurrentRPGMode);
			}
		}

		if (StrEqual(s_key, "EOM")) {

			section.GetString(i, s_section, sizeof(s_section));
			TalentSection.PushString(s_section);

			if (StrEqual(configname, CONFIG_MENUTALENTS)) SetConfigArrays(configname, a_Menu_Talents, TalentKeys, TalentValues, TalentSection, a_Menu_Talents.Length, lastPosition - counter);
			else if (StrEqual(configname, CONFIG_MAINMENU)) SetConfigArrays(configname, a_Menu_Main, TalentKeys, TalentValues, TalentSection, a_Menu_Main.Length, lastPosition - counter);
			else if (StrEqual(configname, CONFIG_EVENTS)) SetConfigArrays(configname, a_Events, TalentKeys, TalentValues, TalentSection, a_Events.Length, lastPosition - counter);
			else if (StrEqual(configname, CONFIG_POINTS)) SetConfigArrays(configname, a_Points, TalentKeys, TalentValues, TalentSection, a_Points.Length, lastPosition - counter);
			else if (StrEqual(configname, CONFIG_PETS)) SetConfigArrays(configname, a_Pets, TalentKeys, TalentValues, TalentSection, a_Pets.Length, lastPosition - counter);
			else if (StrEqual(configname, CONFIG_STORE)) SetConfigArrays(configname, a_Store, TalentKeys, TalentValues, TalentSection, a_Store.Length, lastPosition - counter);
			else if (StrEqual(configname, CONFIG_TRAILS)) SetConfigArrays(configname, a_Trails, TalentKeys, TalentValues, TalentSection, a_Trails.Length, lastPosition - counter);
			else if (StrEqual(configname, CONFIG_CHATSETTINGS)) SetConfigArrays(configname, a_ChatSettings, TalentKeys, TalentValues, TalentSection, a_ChatSettings.Length, lastPosition - counter);
			else if (StrEqual(configname, CONFIG_WEAPONS)) SetConfigArrays(configname, a_WeaponDamages, TalentKeys, TalentValues, TalentSection, a_WeaponDamages.Length, lastPosition - counter);
			else if (StrEqual(configname, CONFIG_COMMONAFFIXES)) SetConfigArrays(configname, a_CommonAffixes, TalentKeys, TalentValues, TalentSection, a_CommonAffixes.Length, lastPosition - counter);
			
			lastPosition = i + 1;
		}
	}
	//delete TalentKeys;
	//delete TalentValues;
	//delete TalentSection;

	if (StrEqual(configname, CONFIG_POINTS)) {

		if (a_DirectorActions != INVALID_HANDLE) a_DirectorActions.Clear();
		a_DirectorActions			=	new ArrayList(3);
		if (a_DirectorActions_Cooldown != INVALID_HANDLE) a_DirectorActions_Cooldown.Clear();
		a_DirectorActions_Cooldown	=	new ArrayList(32);

		int size						=	a_Points.Length;
		ArrayList Keys = new ArrayList(32);
		ArrayList Values = new ArrayList(32);
		ArrayList Section = new ArrayList(32);
		
		int sizer						=	0;

		for (int i = 0; i < size; i++) {

			Keys						=	a_Points.Get(i, 0);
			Values						=	a_Points.Get(i, 1);
			Section						=	a_Points.Get(i, 2);

			int size2					=	Keys.Length;
			for (int ii = 0; ii < size2; ii++) {

				Keys.GetString(ii, s_key, sizeof(s_key));
				Values.GetString(ii, s_value, sizeof(s_value));

				if (StrEqual(s_key, "model?")) PrecacheModel(s_value, false);
				else if (StrEqual(s_key, "director option?") && StrEqual(s_value, "1")) {

					sizer				=	a_DirectorActions.Length;

					a_DirectorActions.Resize(sizer + 1);
					a_DirectorActions.Set(sizer, Keys, 0);
					a_DirectorActions.Set(sizer, Values, 1);
					a_DirectorActions.Set(sizer, Section, 2);
					a_DirectorActions_Cooldown.Resize(sizer + 1);
					a_DirectorActions_Cooldown.SetString(sizer, "0");						// 0 means not on cooldown. 1 means on cooldown. This resets every map.
				}
			}
		}
		/*
		delete Keys;
		delete Values;
		delete Section;*/
		// We only attempt connection to the database in the instance that there are no open connections.
		//if (hDatabase == INVALID_HANDLE) {

		//	MySQL_Init();
		//}
	}

	char thetext[64];
	if (StrEqual(configname, CONFIG_MAIN) && !b_IsFirstPluginLoad) {
		b_IsFirstPluginLoad = true;
		if (hDatabase == INVALID_HANDLE) {

			MySQL_Init();
		}
		LoadMainConfig();
		GetConfigValue(RPGMenuCommand, sizeof(RPGMenuCommand), "rpg menu command?");
		RPGMenuCommandExplode = GetDelimiterCount(RPGMenuCommand, ",") + 1;
		GetConfigValue(thetext, sizeof(thetext), "drop weapon command?");
		RegConsoleCmd(thetext, CMD_DropWeapon);
		GetConfigValue(thetext, sizeof(thetext), "director talent command?");
		RegConsoleCmd(thetext, CMD_DirectorTalentToggle);
		GetConfigValue(thetext, sizeof(thetext), "rpg data erase?");
		RegConsoleCmd(thetext, CMD_DataErase);
		GetConfigValue(thetext, sizeof(thetext), "rpg bot data erase?");
		RegConsoleCmd(thetext, CMD_DataEraseBot);
		//GetConfigValue(thetext, sizeof(thetext), "give store points command?");
		//RegConsoleCmd(thetext, CMD_GiveStorePoints);
		GetConfigValue(thetext, sizeof(thetext), "give level command?");
		RegConsoleCmd(thetext, CMD_GiveLevel);
		GetConfigValue(thetext, sizeof(thetext), "chat tag naming command?");
		RegConsoleCmd(thetext, CMD_ChatTag);
		GetConfigValue(thetext, sizeof(thetext), "share points command?");
		RegConsoleCmd(thetext, CMD_SharePoints);
		GetConfigValue(thetext, sizeof(thetext), "buy menu command?");
		RegConsoleCmd(thetext, CMD_BuyMenu);
		GetConfigValue(thetext, sizeof(thetext), "abilitybar menu command?");
		RegConsoleCmd(thetext, CMD_ActionBar);
		//RegConsoleCmd("collect", CMD_CollectBonusExperience);
		RegConsoleCmd("myweapon", CMD_MyWeapon);
		GetConfigValue(thetext, sizeof(thetext), "companion command?");
		RegConsoleCmd(thetext, CMD_CompanionOptions);
		GetConfigValue(thetext, sizeof(thetext), "load profile command?");
		RegConsoleCmd(thetext, CMD_LoadProfileEx);
		//RegConsoleCmd("backpack", CMD_Backpack);
		//etConfigValue(thetext, sizeof(thetext), "rpg data force save?");
		//RegConsoleCmd(thetext, CMD_SaveData);
	}
	if (StrEqual(configname, CONFIG_EVENTS)) SubmitEventHooks(1);
	ReadyUp_NtvGetHeader();
	if (StrEqual(configname, CONFIG_MAIN)) {
		GetConfigValue(thetext, sizeof(thetext), "item drop model?");
		PrecacheModel(thetext, true);
		GetConfigValue(thetext, sizeof(thetext), "backpack model?");
		PrecacheModel(thetext, true);
	}
	/*

		We need to preload an array full of all the positions of item drops.
		Faster than searching every time.
	*/
	if (StrEqual(configname, CONFIG_MENUTALENTS)) {
		ItemDropArray.Clear();
		int mySize = a_Menu_Talents.Length;
		int curSize= -1;
		int pos = 0;
		for (int i = 0; i <= iRarityMax; i++) {
			for (int j = 0; j < mySize; j++) {
				//PreloadKeys				= a_Menu_Talents.Get(j, 0);
				PreloadValues			= a_Menu_Talents.Get(j, 1);
				if (GetKeyValueIntAtPos(PreloadValues, ITEM_ITEM_ID) != 1) continue;
				//ItemDropArray.Push(i);
				if (GetKeyValueIntAtPos(PreloadValues, ITEM_RARITY) != i) continue;
				curSize = ItemDropArray.Length;
				if (pos == curSize) ItemDropArray.Resize(curSize + 1);
				ItemDropArray.Set(pos, j, i);
				pos++;
			}
			if (i == 0) Format(ItemDropArraySize, sizeof(ItemDropArraySize), "%d", pos);
			else Format(ItemDropArraySize, sizeof(ItemDropArraySize), "%s,%d", ItemDropArraySize, pos);
			pos = 0;
		}
	}
}
/*
	These specific variables can be called the same way, every time, so we declare them globally.
	These are all from the config.cfg (main config file)
	We don't load other variables in this way because they are dynamically loaded and unloaded.
*/
stock void LoadMainConfig() {
	FindConVar("z_difficulty").GetString(sServerDifficulty, sizeof(sServerDifficulty));
	if (strlen(sServerDifficulty) < 4) GetConfigValue(sServerDifficulty, sizeof(sServerDifficulty), "server difficulty?");
	fProficiencyExperienceMultiplier 	= GetConfigValueFloat("proficiency requirement multiplier?");
	fProficiencyExperienceEarned 		= GetConfigValueFloat("experience multiplier proficiency?");
	fRatingPercentLostOnDeath			= GetConfigValueFloat("rating percentage lost on death?");
	//iProficiencyMaxLevel				= GetConfigValueInt("proficience level max?");
	iProficiencyStart					= GetConfigValueInt("proficiency level start?");
	iTeamRatingRequired					= GetConfigValueInt("team count rating bonus?");
	fTeamRatingBonus					= GetConfigValueFloat("team player rating bonus?");
	iTanksPreset						= GetConfigValueInt("preset tank type on spawn?");
	iSurvivorRespawnRestrict			= GetConfigValueInt("respawn queue players ignored?");
	iIsRatingEnabled					= GetConfigValueInt("handicap enabled?");
	iIsSpecialFire						= GetConfigValueInt("special infected fire?");
	iSkyLevelMax						= GetConfigValueInt("max sky level?");
	//iOnFireDebuffLimit				= GetConfigValueInt("standing in fire debuff limit?");
	fOnFireDebuffDelay					= GetConfigValueFloat("standing in fire debuff delay?");
	//fTankThreatBonus					= GetConfigValueFloat("tank threat bonus?");
	forceProfileOnNewPlayers			= GetConfigValueInt("Force Profile On New Player?");
	iShowLockedTalents					= GetConfigValueInt("show locked talents?");
	iAwardBroadcast						= GetConfigValueInt("award broadcast?");
	GetConfigValue(sSpecialsAllowed, sizeof(sSpecialsAllowed), "special infected classes?");
	iSpecialsAllowed					= GetConfigValueInt("special infected allowed?");
	iSpecialInfectedMinimum				= GetConfigValueInt("special infected minimum?");
	fEnrageMultiplier					= GetConfigValueFloat("enrage multiplier?");
	iRestedDonator						= GetConfigValueInt("rested experience earned donator?");
	iRestedRegular						= GetConfigValueInt("rested experience earned non-donator?");
	iRestedSecondsRequired				= GetConfigValueInt("rested experience required seconds?");
	iRestedMaximum						= GetConfigValueInt("rested experience maximum?");
	iFriendlyFire						= GetConfigValueInt("friendly fire enabled?");
	GetConfigValue(sDonatorFlags, sizeof(sDonatorFlags), "donator package flag?");
	GetConfigValue(sProfileLoadoutConfig, sizeof(sProfileLoadoutConfig), "profile loadout config?");
	iHardcoreMode						= GetConfigValueInt("hardcore mode?");
	fDeathPenalty						= GetConfigValueFloat("death penalty?");
	iDeathPenaltyPlayers				= GetConfigValueInt("death penalty players required?");
	iTankRush							= GetConfigValueInt("tank rush?");
	iTanksAlways						= GetConfigValueInt("tanks always active?");
	iTanksAlwaysEnforceCooldown 		= GetConfigValueInt("tanks always enforce cooldown?");
	fSprintSpeed						= GetConfigValueFloat("sprint speed?");
	iRPGMode							= GetConfigValueInt("rpg mode?");
	DirectorWitchLimit					= GetConfigValueInt("director witch limit?");
	fCommonQueueLimit					= GetConfigValueFloat("common queue limit?");
	fDirectorThoughtDelay				= GetConfigValueFloat("director thought process delay?");
	fDirectorThoughtHandicap			= GetConfigValueFloat("director thought process handicap?");
	iSurvivalRoundTime					= GetConfigValueInt("survival round time?");
	fDazedDebuffEffect					= GetConfigValueFloat("dazed debuff effect?");
	ConsumptionInt						= GetConfigValueInt("stamina consumption interval?");
	fStamSprintInterval					= GetConfigValueFloat("stamina sprint interval?");
	fStamRegenTime						= GetConfigValueFloat("stamina regeneration time?");
	fStamRegenTimeAdren					= GetConfigValueFloat("stamina regeneration time adren?");
	fBaseMovementSpeed					= GetConfigValueFloat("base movement speed?");
	fFatigueMovementSpeed				= GetConfigValueFloat("fatigue movement speed?");
	iPlayerStartingLevel				= GetConfigValueInt("new player starting level?");
	iBotPlayerStartingLevel				= GetConfigValueInt("new bot player starting level?");
	fOutOfCombatTime					= GetConfigValueFloat("out of combat time?");
	iWitchDamageInitial					= GetConfigValueInt("witch damage initial?");
	fWitchDamageScaleLevel				= GetConfigValueFloat("witch damage scale level?");
	fSurvivorDamageBonus				= GetConfigValueFloat("survivor damage bonus?");
	fSurvivorHealthBonus				= GetConfigValueFloat("survivor health bonus?");
	iSurvivorModifierRequired			= GetConfigValueInt("survivor modifier requirement?");
	iEnrageTime							= GetConfigValueInt("enrage time?");
	fWitchDirectorPoints				= GetConfigValueFloat("witch director points?");
	fEnrageDirectorPoints				= GetConfigValueFloat("enrage director points?");
	fCommonDamageLevel					= GetConfigValueFloat("common damage scale level?");
	iBotLevelType						= GetConfigValueInt("infected bot level type?");
	fCommonDirectorPoints				= GetConfigValueFloat("common infected director points?");
	iDisplayHealthBars					= GetConfigValueInt("display health bars?");
	iMaxDifficultyLevel					= GetConfigValueInt("max difficulty level?");
	char text[64], text2[64], text3[64], text4[64];
	for (int i = 0; i < 7; i++) {
		if (i == 6) {
			Format(text, sizeof(text), "(%d) damage player level?", i + 2);
			Format(text2, sizeof(text2), "(%d) infected health bonus", i + 2);
			Format(text3, sizeof(text3), "(%d) base damage?", i + 2);
			Format(text4, sizeof(text4), "(%d) base infected health?", i + 2);
		}
		else {
			Format(text, sizeof(text), "(%d) damage player level?", i + 1);
			Format(text2, sizeof(text2), "(%d) infected health bonus", i + 1);
			Format(text3, sizeof(text3), "(%d) base damage?", i + 1);
			Format(text4, sizeof(text4), "(%d) base infected health?", i + 1);
		}
		fDamagePlayerLevel[i]			= GetConfigValueFloat(text);
		fHealthPlayerLevel[i]			= GetConfigValueFloat(text2);
		iBaseSpecialDamage[i]			= GetConfigValueInt(text3);
		iBaseSpecialInfectedHealth[i]	= GetConfigValueInt(text4);
	}

	fAcidDamagePlayerLevel				= GetConfigValueFloat("acid damage spitter player level?");
	fAcidDamageSupersPlayerLevel		= GetConfigValueFloat("acid damage supers player level?");
	fPointsMultiplierInfected			= GetConfigValueFloat("points multiplier infected?");
	fPointsMultiplier					= GetConfigValueFloat("points multiplier survivor?");
	fHealingMultiplier					= GetConfigValueFloat("experience multiplier healing?");
	fBuffingMultiplier					= GetConfigValueFloat("experience multiplier buffing?");
	fHexingMultiplier					= GetConfigValueFloat("experience multiplier hexing?");
	TanksNearbyRange					= GetConfigValueFloat("tank nearby ability deactivate?");
	iCommonAffixes						= GetConfigValueInt("common affixes?");
	BroadcastType						= GetConfigValueInt("hint text type?");
	iDoomTimer							= GetConfigValueInt("doom kill timer?");
	iSurvivorStaminaMax					= GetConfigValueInt("survivor stamina?");
	fRatingMultSpecials					= GetConfigValueFloat("rating multiplier specials?");
	fRatingMultSupers					= GetConfigValueFloat("rating multiplier supers?");
	fRatingMultCommons					= GetConfigValueFloat("rating multiplier commons?");
	fRatingMultTank						= GetConfigValueFloat("rating multiplier tank?");
	fTeamworkExperience					= GetConfigValueInt("maximum teamwork experience?") * 1.0;
	fItemMultiplierLuck					= GetConfigValueFloat("buy item luck multiplier?");
	fItemMultiplierTeam					= GetConfigValueInt("buy teammate item multiplier?") * 1.0;
	GetConfigValue(sQuickBindHelp, sizeof(sQuickBindHelp), "quick bind help?");
	fPointsCostLevel					= GetConfigValueFloat("points cost increase per level?");
	PointPurchaseType					= GetConfigValueInt("points purchase type?");
	iTankLimitVersus					= GetConfigValueInt("versus tank limit?");
	fHealRequirementTeam				= GetConfigValueFloat("teammate heal health requirement?");
	iSurvivorBaseHealth					= GetConfigValueInt("survivor health?");
	iSurvivorBotBaseHealth				= GetConfigValueInt("survivor bot health?");
	GetConfigValue(spmn, sizeof(spmn), "sky points menu name?");
	fHealthSurvivorRevive				= GetConfigValueFloat("survivor revive health?");
	GetConfigValue(RestrictedWeapons, sizeof(RestrictedWeapons), "restricted weapons?");
	iMaxLevel							= GetConfigValueInt("max level?");
	iExperienceStart					= GetConfigValueInt("experience start?");
	fExperienceMultiplier				= GetConfigValueFloat("requirement multiplier?");
	GetConfigValue(sBotTeam, sizeof(sBotTeam), "survivor team?");
	iActionBarSlots						= GetConfigValueInt("action bar slots?");
	GetConfigValue(MenuCommand, sizeof(MenuCommand), "rpg menu command?");
	ReplaceString(MenuCommand, sizeof(MenuCommand), ",", " or ", true);
	HostNameTime						= GetConfigValueInt("display server name time?");
	DoomSUrvivorsRequired				= GetConfigValueInt("doom survivors ignored?");
	DoomKillTimer						= GetConfigValueInt("doom kill timer?");
	fVersusTankNotice					= GetConfigValueFloat("versus tank notice?");
	AllowedCommons						= GetConfigValueInt("common limit base?");
	AllowedMegaMob						= GetConfigValueInt("mega mob limit base?");
	AllowedMobSpawn						= GetConfigValueInt("mob limit base?");
	AllowedMobSpawnFinale				= GetConfigValueInt("mob finale limit base?");
	AllowedPanicInterval				= GetConfigValueInt("mega mob max interval base?");
	RespawnQueue						= GetConfigValueInt("survivor respawn queue?");
	MaximumPriority						= GetConfigValueInt("director priority maximum?");
	fUpgradeExpCost						= GetConfigValueFloat("upgrade experience cost?");
	iHandicapLevelDifference			= GetConfigValueInt("handicap level difference required?");
	iWitchHealthBase					= GetConfigValueInt("base witch health?");
	fWitchHealthMult					= GetConfigValueFloat("level witch multiplier?");
	//RatingPerLevel					= GetConfigValueInt("rating level multiplier?");
	iCommonBaseHealth					= GetConfigValueInt("common base health?");
	fCommonRaidHealthMult				= GetConfigValueFloat("common raid health multiplier?");
	fCommonLevelHealthMult				= GetConfigValueFloat("common level health?");
	//iServerLevelRequirement			= GetConfigValueInt("server level requirement?");
	iRoundStartWeakness					= GetConfigValueInt("weakness on round start?");
	GroupMemberBonus					= GetConfigValueFloat("steamgroup bonus?");
	RaidLevMult							= GetConfigValueInt("raid level multiplier?");
	iIgnoredRating						= GetConfigValueInt("rating to ignore?");
	iIgnoredRatingMax					= GetConfigValueInt("max rating to ignore?");
	//iTrailsEnabled					= GetConfigValueInt("trails enabled?");
	iInfectedLimit						= GetConfigValueInt("ensnare infected limit?");
	SurvivorExperienceMult				= GetConfigValueFloat("experience multiplier survivor?");
	SurvivorExperienceMultTank			= GetConfigValueFloat("experience multiplier tanking?");
	SurvivorExperienceMultHeal			= GetConfigValueFloat("experience multiplier healing?");
	TheScorchMult						= GetConfigValueFloat("scorch multiplier?");
	TheInfernoMult						= GetConfigValueFloat("inferno multiplier?");
	fAmmoHighlightTime					= GetConfigValueFloat("special ammo highlight time?");
	fAdrenProgressMult					= GetConfigValueFloat("adrenaline progress multiplier?");
	DirectorTankCooldown				= GetConfigValueFloat("director tank cooldown?");
	DisplayType							= GetConfigValueInt("survivor reward display?");
	GetConfigValue(sDirectorTeam, sizeof(sDirectorTeam), "director team name?");
	fRestedExpMult						= GetConfigValueFloat("rested experience multiplier?");
	fSurvivorExpMult					= GetConfigValueFloat("survivor experience bonus?");
	iDebuffLimit						= GetConfigValueInt("debuff limit?");
	iRatingSpecialsRequired				= GetConfigValueInt("specials rating required?");
	iRatingTanksRequired				= GetConfigValueInt("tank rating required?");
	GetConfigValue(sDbLeaderboards, sizeof(sDbLeaderboards), "db record?");
	iIsLifelink							= GetConfigValueInt("lifelink enabled?");
	RatingPerHandicap					= GetConfigValueInt("rating level handicap?");
	GetConfigValue(sItemModel, sizeof(sItemModel), "item drop model?");
	iRarityMax							= GetConfigValueInt("item rarity max?");
	iEnrageAdvertisement				= GetConfigValueInt("enrage advertise time?");
	iNotifyEnrage						= GetConfigValueInt("enrage notification?");
	iJoinGroupAdvertisement				= GetConfigValueInt("join group advertise time?");
	GetConfigValue(sBackpackModel, sizeof(sBackpackModel), "backpack model?");
	iSurvivorGroupMinimum				= GetConfigValueInt("group member minimum?");
	fBurnPercentage						= GetConfigValueFloat("burn debuff percentage?");
	fSuperCommonLimit					= GetConfigValueFloat("super common limit?");
	iCommonsLimitUpper					= GetConfigValueInt("commons limit max?");
	FinSurvBon							= GetConfigValueFloat("finale survival bonus?");
	fCoopSurvBon 						= GetConfigValueFloat("coop round survival bonus?");
	iMaxIncap							= GetConfigValueInt("survivor max incap?");
	iMaxLayers							= GetConfigValueInt("max talent layers?");
	iCommonInfectedBaseDamage			= GetConfigValueInt("common infected base damage?");
	iShowTotalNodesOnTalentTree			= GetConfigValueInt("show upgrade maximum by nodes?");
	fDrawHudInterval					= GetConfigValueFloat("hud display tick rate?");
	fSpecialAmmoInterval				= GetConfigValueFloat("special ammo tick rate?");
	fEffectOverTimeInterval				= GetConfigValueFloat("effect over time tick rate?");
	//fStaggerTime						= GetConfigValueFloat("stagger debuff time?");
	fStaggerTickrate					= GetConfigValueFloat("stagger tickrate?");
	fRatingFloor						= GetConfigValueFloat("rating floor?");
	iExperienceDebtLevel				= GetConfigValueInt("experience debt level?");
	iExperienceDebtEnabled				= GetConfigValueInt("experience debt enabled?");
	fExperienceDebtPenalty				= GetConfigValueFloat("experience debt penalty?");
	iShowDamageOnActionBar				= GetConfigValueInt("show damage on action bar?");
	iDefaultIncapHealth					= GetConfigValueInt("default incap health?");
	iSkyLevelNodeUnlocks				= GetConfigValueInt("sky level default node unlocks?");
	iCanSurvivorBotsBurn				= GetConfigValueInt("survivor bots debuffs allowed?");
	iDeleteCommonsFromExistenceOnDeath	= GetConfigValueInt("delete commons from existence on death?");
	iShowDetailedDisplayAlways			= GetConfigValueInt("show detailed display to survivors always?");
	iCanJetpackWhenInCombat				= GetConfigValueInt("can players jetpack when in combat?");
	fquickScopeTime						= GetConfigValueFloat("delay after zoom for quick scope kill?");
	iEnsnareLevelMultiplier				= GetConfigValueInt("ensnare level multiplier?");
	iNoSpecials							= GetConfigValueInt("disable non boss special infected?");
	fSurvivorBotsNoneBonus				= GetConfigValueFloat("group bonus if no survivor bots?");
	iSurvivorBotsBonusLimit				= GetConfigValueInt("no survivor bots group bonus requirement?");
	iShowAdvertToNonSteamgroupMembers	= GetConfigValueInt("show advertisement to non-steamgroup members?");
	iStrengthOnSpawnIsStrength			= GetConfigValueInt("spells,auras,ammos strength set on spawn?");
	iHealingPlayerInCombatPutInCombat	= GetConfigValueInt("healing a player in combat places you in combat?");
	iPlayersLeaveCombatDuringFinales	= GetConfigValueInt("do players leave combat during finales?");
	iAllowPauseLeveling					= GetConfigValueInt("let players pause their leveling?");
	fMaxDamageResistance				= GetConfigValueFloat("max damage resistance?");
	fStaminaPerPlayerLevel				= GetConfigValueFloat("stamina increase per player level?");
	fStaminaPerSkyLevel					= GetConfigValueFloat("stamina increase per prestige level?");
	iEndRoundIfNoHealthySurvivors		= GetConfigValueInt("end round if all survivors are incapped?");
	fTankMovementSpeed_Burning			= GetConfigValueFloat("fire tank movement speed?", 1.0);	// if this key is omitted, a default value is set. these MUST be > 0.0, so the default is hard-coded.
	fTankMovementSpeed_Hulk				= GetConfigValueFloat("hulk tank movement speed?", 0.75);
	fTankMovementSpeed_Death			= GetConfigValueFloat("death tank movement speed?", 0.5);
	//if (fMaxDamageResistance < 0.0) fMaxDamageResistance = 0.9;
	//iDropAcidOnLastDebuffDrop			= GetConfigValueInt("do prestige players poo acid on last tick?");
	GetConfigValue(DefaultProfileName, sizeof(DefaultProfileName), "new player profile?");
	GetConfigValue(DefaultBotProfileName, sizeof(DefaultBotProfileName), "new bot player profile?");
	GetConfigValue(DefaultInfectedProfileName, sizeof(DefaultInfectedProfileName), "new infected player profile?");
	GetConfigValue(defaultLoadoutWeaponPrimary, sizeof(defaultLoadoutWeaponPrimary), "default loadout primary weapon?");
	GetConfigValue(defaultLoadoutWeaponSecondary, sizeof(defaultLoadoutWeaponSecondary), "default loadout secondary weapon?");
	LogMessage("Main Config Loaded.");
}

//public Action:CMD_Backpack(int client, int args) { EquipBackpack(client); return Plugin_Handled; }
public Action CMD_BuyMenu(int client, int args) {
	if (iRPGMode < 0 || iRPGMode == 1 && b_IsActiveRound) return Plugin_Handled;
	//if (StringToInt(GetConfigValue("rpg mode?")) != 1) 
	BuildPointsMenu(client, "Buy Menu", "rpg/points.cfg");
	return Plugin_Handled;
}

public Action CMD_DataErase(int client, int args) {
	char arg[MAX_NAME_LENGTH];
	char thetext[64];
	GetConfigValue(thetext, sizeof(thetext), "delete bot flags?");
	if (args > 0 && HasCommandAccess(client, thetext)) {
		GetCmdArg(1, arg, sizeof(arg));
		int targetclient = FindTargetClient(client, arg);
		if (IsLegitimateClient(targetclient) && GetClientTeam(targetclient) != TEAM_INFECTED) DeleteAndCreateNewData(targetclient);
	}
	else DeleteAndCreateNewData(client);
	return Plugin_Handled;
}

public Action CMD_DataEraseBot(int client, int args) {
	DeleteAndCreateNewData(client, true);
	return Plugin_Handled;
}

stock void DeleteAndCreateNewData(int client, bool IsBot = false) {
	char key[64];
	char tquery[1024];
	char text[64];
	char pct[4];
	Format(pct, sizeof(pct), "%");
	if (!IsBot) {
		GetClientAuthId(client, AuthId_Steam2, key, sizeof(key));
		Format(tquery, sizeof(tquery), "DELETE FROM `%s` WHERE `steam_id` = '%s';", TheDBPrefix, key);
		hDatabase.Query(QueryResults, tquery, client);
		ResetData(client);
		CreateNewPlayerEx(client);
		PrintToChat(client, "data erased, new data created.");	// not bothering with a translation here, since it's a debugging command.
	}
	else {
		GetConfigValue(text, sizeof(text), "delete bot flags?");
		if (HasCommandAccess(client, text)) {

			for (int i = 1; i <= MaxClients; i++) {

				if (IsSurvivorBot(i)) KickClient(i);
			}

			Format(tquery, sizeof(tquery), "DELETE FROM `%s` WHERE `steam_id` LIKE '%s%s%s';", TheDBPrefix, pct, sBotTeam, pct);
			//Format(tquery, sizeof(tquery), "DELETE FROM `%s` WHERE `steam_id` LIKE 'STEAM';", TheDBPrefix);
			hDatabase.Query(QueryResults, tquery, client);
			LogMessage("%s", tquery);
			PrintToChatAll("%t", "bot data deleted", orange, blue);
		}
	}
}

public Action CMD_DirectorTalentToggle(int client, int args) {
	char thetext[64];
	GetConfigValue(thetext, sizeof(thetext), "director talent flags?");
	if (HasCommandAccess(client, thetext)) {

		if (b_IsDirectorTalents[client]) {

			b_IsDirectorTalents[client]			= false;
			PrintToChat(client, "%T", "Director Talents Disabled", client, white, green);
		}
		else {

			b_IsDirectorTalents[client]			= true;
			PrintToChat(client, "%T", "Director Talents Enabled", client, white, green);
		}
	}
	return Plugin_Handled;
}

stock void SetConfigArrays(char[] Config, ArrayList Main, ArrayList Keys, ArrayList Values, ArrayList Section, int size, int last) {

	char text[64];
	//Section.GetString(0, text, sizeof(text));

	ArrayList TalentKey = new ArrayList(32);
	ArrayList TalentValue = new ArrayList(32);
	ArrayList TalentSection = new ArrayList(32);

	char key[64];
	char value[64];
	int a_Size = Keys.Length;
	for (int i = last; i < a_Size; i++) {

		Keys.GetString(i, key, sizeof(key));
		Values.GetString(i, value, sizeof(value));
		//if (StrEqual(key, "EOM")) continue;	// we don't care about the EOM key at this point.

		TalentKey.PushString(key);
		TalentValue.PushString(value);
	}
	int pos = 0;
	int sortSize = 0;
	// Sort the keys/values for TALENTS ONLY /w.
	if (StrEqual(Config, CONFIG_MENUTALENTS)) {
		if (TalentKey.FindString("event type?") == -1) {
			TalentKey.PushString("event type?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("target must be in the air?") == -1) {
			TalentKey.PushString("target must be in the air?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("activator neither high or low ground?") == -1) {
			TalentKey.PushString("activator neither high or low ground?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("target high ground?") == -1) {
			TalentKey.PushString("target high ground?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("activator high ground?") == -1) {
			TalentKey.PushString("activator high ground?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("requires activator drowning?") == -1) {
			TalentKey.PushString("requires activator drowning?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("requires activator steaming?") == -1) {
			TalentKey.PushString("requires activator steaming?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("requires activator scorched?") == -1) {
			TalentKey.PushString("requires activator scorched?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("requires activator frozen?") == -1) {
			TalentKey.PushString("requires activator frozen?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("requires activator slowed?") == -1) {
			TalentKey.PushString("requires activator slowed?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("requires activator exploding?") == -1) {
			TalentKey.PushString("requires activator exploding?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("requires activator acid burn?") == -1) {
			TalentKey.PushString("requires activator acid burn?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("requires activator on fire?") == -1) {
			TalentKey.PushString("requires activator on fire?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("target must be last target?") == -1) {
			TalentKey.PushString("target must be last target?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("target must be outside range required?") == -1) {
			TalentKey.PushString("target must be outside range required?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("target range required?") == -1) {
			TalentKey.PushString("target range required?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("target class must be last target class?") == -1) {
			TalentKey.PushString("target class must be last target class?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("toggle strength?") == -1) {
			TalentKey.PushString("toggle strength?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("minimum level required?") == -1) {
			TalentKey.PushString("minimum level required?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("special ammo?") == -1) {
			TalentKey.PushString("special ammo?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("does damage?") == -1) {
			TalentKey.PushString("does damage?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("cooldown end ability trigger?") == -1) {
			TalentKey.PushString("cooldown end ability trigger?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("active end ability trigger?") == -1) {
			TalentKey.PushString("active end ability trigger?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("secondary ept only?") == -1) {
			TalentKey.PushString("secondary ept only?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("activate effect per tick?") == -1) {
			TalentKey.PushString("activate effect per tick?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("cooldown?") == -1) {
			TalentKey.PushString("cooldown?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("allow survivors?") == -1) {
			TalentKey.PushString("allow survivors?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("allow specials?") == -1) {
			TalentKey.PushString("allow specials?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("allow commons?") == -1) {
			TalentKey.PushString("allow commons?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("inanimate only?") == -1) {
			TalentKey.PushString("inanimate only?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("humanoid only?") == -1) {
			TalentKey.PushString("humanoid only?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("toggle effect?") == -1) {
			TalentKey.PushString("toggle effect?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("sky level requirement?") == -1) {
			TalentKey.PushString("sky level requirement?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("cannot be ensnared?") == -1) {
			TalentKey.PushString("cannot be ensnared?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("active time?") == -1) {
			TalentKey.PushString("active time?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("reactive type?") == -1) {
			TalentKey.PushString("reactive type?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("inactive trigger?") == -1) {
			TalentKey.PushString("inactive trigger?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("cooldown trigger?") == -1) {
			TalentKey.PushString("cooldown trigger?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("is aura instead?") == -1) {
			TalentKey.PushString("is aura instead?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("requirement multiplier?") == -1) {
			TalentKey.PushString("requirement multiplier?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("experience start?") == -1) {
			TalentKey.PushString("experience start?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("rarity?") == -1) {
			TalentKey.PushString("rarity?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("is item?") == -1) {
			TalentKey.PushString("is item?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("talent type?") == -1) {
			TalentKey.PushString("talent type?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("is sub menu?") == -1) {
			TalentKey.PushString("is sub menu?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("buff bar text?") == -1) {
			TalentKey.PushString("buff bar text?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("diminishing returns?") == -1) {
			TalentKey.PushString("diminishing returns?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("diminishing multiplier?") == -1) {
			TalentKey.PushString("diminishing multiplier?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("base multiplier?") == -1) {
			TalentKey.PushString("base multiplier?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("use these multipliers?") == -1) {
			TalentKey.PushString("use these multipliers?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("attribute?") == -1) {
			TalentKey.PushString("attribute?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("passive draw delay?") == -1) {
			TalentKey.PushString("passive draw delay?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("draw effect delay?") == -1) {
			TalentKey.PushString("draw effect delay?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("draw delay?") == -1) {
			TalentKey.PushString("draw delay?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("is single target?") == -1) {
			TalentKey.PushString("is single target?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("passive only?") == -1) {
			TalentKey.PushString("passive only?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("passive strength?") == -1) {
			TalentKey.PushString("passive strength?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("passive requires ensnare?") == -1) {
			TalentKey.PushString("passive requires ensnare?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("passive ignores cooldown?") == -1) {
			TalentKey.PushString("passive ignores cooldown?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("active strength?") == -1) {
			TalentKey.PushString("active strength?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("active requires ensnare?") == -1) {
			TalentKey.PushString("active requires ensnare?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("maximum active multiplier?") == -1) {
			TalentKey.PushString("maximum active multiplier?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("maximum passive multiplier?") == -1) {
			TalentKey.PushString("maximum passive multiplier?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("cooldown strength?") == -1) {
			TalentKey.PushString("cooldown strength?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("teams allowed?") == -1) {
			TalentKey.PushString("teams allowed?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("reactive ability?") == -1) {
			TalentKey.PushString("reactive ability?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("cooldown effect?") == -1) {
			TalentKey.PushString("cooldown effect?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("passive effect?") == -1) {
			TalentKey.PushString("passive effect?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("active effect?") == -1) {
			TalentKey.PushString("active effect?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("effect multiplier?") == -1) {
			TalentKey.PushString("effect multiplier?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("ammo effect?") == -1) {
			TalentKey.PushString("ammo effect?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("interval per point?") == -1) {
			TalentKey.PushString("interval per point?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("interval first point?") == -1) {
			TalentKey.PushString("interval first point?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("range per point?") == -1) {
			TalentKey.PushString("range per point?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("range first point value?") == -1) {
			TalentKey.PushString("range first point value?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("stamina per point?") == -1) {
			TalentKey.PushString("stamina per point?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("base stamina required?") == -1) {
			TalentKey.PushString("base stamina required?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("cooldown per point?") == -1) {
			TalentKey.PushString("cooldown per point?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("cooldown first point?") == -1) {
			TalentKey.PushString("cooldown first point?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("cooldown start?") == -1) {
			TalentKey.PushString("cooldown start?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("active time per point?") == -1) {
			TalentKey.PushString("active time per point?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("active time first point?") == -1) {
			TalentKey.PushString("active time first point?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("roll chance?") == -1) {
			TalentKey.PushString("roll chance?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("hide translation?") == -1) {
			TalentKey.PushString("hide translation?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("is attribute?") == -1) {
			TalentKey.PushString("is attribute?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("ignore for layer count?") == -1) {
			TalentKey.PushString("ignore for layer count?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("effect strength?") == -1) {
			TalentKey.PushString("effect strength?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("is effect over time?") == -1) {
			TalentKey.PushString("is effect over time?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("talent hard limit?") == -1) {
			TalentKey.PushString("talent hard limit?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("governs cooldown of talent named?") == -1) {
			TalentKey.PushString("governs cooldown of talent named?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("talent active time scale?") == -1) {
			TalentKey.PushString("talent active time scale?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("talent active time strength value?") == -1) {
			TalentKey.PushString("talent active time strength value?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("talent cooldown scale?") == -1) {
			TalentKey.PushString("talent cooldown scale?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("talent cooldown strength value?") == -1) {
			TalentKey.PushString("talent cooldown strength value?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("talent upgrade scale?") == -1) {
			TalentKey.PushString("talent upgrade scale?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("talent upgrade strength value?") == -1) {
			TalentKey.PushString("talent upgrade strength value?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("required talents required?") == -1) {
			TalentKey.PushString("required talents required?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("action bar name?") == -1) {
			TalentKey.PushString("action bar name?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("is ability?") == -1) {
			TalentKey.PushString("is ability?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("layer?") == -1) {
			TalentKey.PushString("layer?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("part of menu named?") == -1) {
			TalentKey.PushString("part of menu named?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("talent tree category?") == -1) {
			TalentKey.PushString("talent tree category?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("governing attribute?") == -1) {
			TalentKey.PushString("governing attribute?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("translation?") == -1) {
			TalentKey.PushString("translation?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("talent name?") == -1) {
			TalentKey.PushString("talent name?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("secondary aoe?") == -1) {
			TalentKey.PushString("secondary aoe?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("primary aoe?") == -1) {
			TalentKey.PushString("primary aoe?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("target is self?") == -1) {
			TalentKey.PushString("target is self?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("secondary ability trigger?") == -1) {
			TalentKey.PushString("secondary ability trigger?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("is own talent?") == -1) {
			TalentKey.PushString("is own talent?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("health percentage required missing max?") == -1) {
			TalentKey.PushString("health percentage required missing max?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("health percentage required missing?") == -1) {
			TalentKey.PushString("health percentage required missing?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("no effect if damage time is not met?") == -1) {
			TalentKey.PushString("no effect if damage time is not met?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("strength increase while holding fire?") == -1) {
			TalentKey.PushString("strength increase while holding fire?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("no effect if zoom time is not met?") == -1) {
			TalentKey.PushString("no effect if zoom time is not met?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("strength increase time required?") == -1) {
			TalentKey.PushString("strength increase time required?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("strength increase time cap?") == -1) {
			TalentKey.PushString("strength increase time cap?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("strength increase while zoomed?") == -1) {
			TalentKey.PushString("strength increase while zoomed?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("multiply specials?") == -1) {
			TalentKey.PushString("multiply specials?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("multiply survivors?") == -1) {
			TalentKey.PushString("multiply survivors?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("multiply witches?") == -1) {
			TalentKey.PushString("multiply witches?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("multiply supers?") == -1) {
			TalentKey.PushString("multiply supers?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("multiply commons?") == -1) {
			TalentKey.PushString("multiply commons?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("multiply range?") == -1) {
			TalentKey.PushString("multiply range?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("status effect multiplier?") == -1) {
			TalentKey.PushString("status effect multiplier?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("background talent?") == -1) {
			TalentKey.PushString("background talent?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("require consecutive hits?") == -1) {
			TalentKey.PushString("require consecutive hits?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("cleanse trigger?") == -1) {
			TalentKey.PushString("cleanse trigger?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("target class required?") == -1) {
			TalentKey.PushString("target class required?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("require weakness?") == -1) {
			TalentKey.PushString("require weakness?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("disabled if weakness?") == -1) {
			TalentKey.PushString("disabled if weakness?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("require adrenaline effect?") == -1) {
			TalentKey.PushString("require adrenaline effect?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("target vomit state required?") == -1) {
			TalentKey.PushString("target vomit state required?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("vomit state required?") == -1) {
			TalentKey.PushString("vomit state required?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("cannot be touching earth?") == -1) {
			TalentKey.PushString("cannot be touching earth?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("cannot target self?") == -1) {
			TalentKey.PushString("cannot target self?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("target stagger required?") == -1) {
			TalentKey.PushString("target stagger required?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("activator stagger required?") == -1) {
			TalentKey.PushString("activator stagger required?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("requires crouching?") == -1) {
			TalentKey.PushString("requires crouching?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("requires limbshot?") == -1) {
			TalentKey.PushString("requires limbshot?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("requires headshot?") == -1) {
			TalentKey.PushString("requires headshot?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("passive ability?") == -1) {
			TalentKey.PushString("passive ability?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("player state required?") == -1) {
			TalentKey.PushString("player state required?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("combat state required?") == -1) {
			TalentKey.PushString("combat state required?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("requires zoom?") == -1) {
			TalentKey.PushString("requires zoom?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("activator class required?") == -1) {
			TalentKey.PushString("activator class required?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("activator team required?") == -1) {
			TalentKey.PushString("activator team required?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("health percentage missing required target?") == -1) {
			TalentKey.PushString("health percentage missing required target?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("health percentage remaining required target?") == -1) {
			TalentKey.PushString("health percentage remaining required target?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("coherency required?") == -1) {
			TalentKey.PushString("coherency required?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("coherency max?") == -1) {
			TalentKey.PushString("coherency max?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("coherency range?") == -1) {
			TalentKey.PushString("coherency range?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("health percentage required?") == -1) {
			TalentKey.PushString("health percentage required?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("weapons permitted?") == -1) {
			TalentKey.PushString("weapons permitted?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("secondary effects?") == -1) {
			TalentKey.PushString("secondary effects?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("target ability effects?") == -1) {
			TalentKey.PushString("target ability effects?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("activator ability effects?") == -1) {
			TalentKey.PushString("activator ability effects?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("compound with?") == -1) {
			TalentKey.PushString("compound with?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("compounding talent?") == -1) {
			TalentKey.PushString("compounding talent?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("ability type?") == -1) {
			TalentKey.PushString("ability type?");
			TalentValue.PushString("-1");
		}
		sortSize = TalentKey.Length;
		pos = 0;
		while (pos < sortSize) {
			TalentKey.GetString(pos, text, sizeof(text));
			if (
			pos == 0 && !StrEqual(text, "ability type?") ||
			pos == 1 && !StrEqual(text, "compounding talent?") ||
			pos == 2 && !StrEqual(text, "compound with?") ||
			pos == 3 && !StrEqual(text, "activator ability effects?") ||
			pos == 4 && !StrEqual(text, "target ability effects?") ||
			pos == 5 && !StrEqual(text, "secondary effects?") ||
			pos == 6 && !StrEqual(text, "weapons permitted?") ||
			pos == 7 && !StrEqual(text, "health percentage required?") ||
			pos == 8 && !StrEqual(text, "coherency range?") ||
			pos == 9 && !StrEqual(text, "coherency max?") ||
			pos == 10 && !StrEqual(text, "coherency required?") ||
			pos == 11 && !StrEqual(text, "health percentage remaining required target?") ||
			pos == 12 && !StrEqual(text, "health percentage missing required target?") ||
			pos == 13 && !StrEqual(text, "activator team required?") ||
			pos == 14 && !StrEqual(text, "activator class required?") ||
			pos == 15 && !StrEqual(text, "requires zoom?") ||
			pos == 16 && !StrEqual(text, "combat state required?") ||
			pos == 17 && !StrEqual(text, "player state required?") ||
			pos == 18 && !StrEqual(text, "passive ability?") ||
			pos == 19 && !StrEqual(text, "requires headshot?") ||
			pos == 20 && !StrEqual(text, "requires limbshot?") ||
			pos == 21 && !StrEqual(text, "requires crouching?") ||
			pos == 22 && !StrEqual(text, "activator stagger required?") ||
			pos == 23 && !StrEqual(text, "target stagger required?") ||
			pos == 24 && !StrEqual(text, "cannot target self?") ||
			pos == 25 && !StrEqual(text, "cannot be touching earth?") ||
			pos == 26 && !StrEqual(text, "vomit state required?") ||
			pos == 27 && !StrEqual(text, "target vomit state required?") ||
			pos == 28 && !StrEqual(text, "require adrenaline effect?") ||
			pos == 29 && !StrEqual(text, "disabled if weakness?") ||
			pos == 30 && !StrEqual(text, "require weakness?") ||
			pos == 31 && !StrEqual(text, "target class required?") ||
			pos == 32 && !StrEqual(text, "cleanse trigger?") ||
			pos == 33 && !StrEqual(text, "require consecutive hits?") ||
			pos == 34 && !StrEqual(text, "background talent?") ||
			pos == 35 && !StrEqual(text, "status effect multiplier?") ||
			pos == 36 && !StrEqual(text, "multiply range?") ||
			pos == 37 && !StrEqual(text, "multiply commons?") ||
			pos == 38 && !StrEqual(text, "multiply supers?") ||
			pos == 39 && !StrEqual(text, "multiply witches?") ||
			pos == 40 && !StrEqual(text, "multiply survivors?") ||
			pos == 41 && !StrEqual(text, "multiply specials?") ||
			pos == 42 && !StrEqual(text, "strength increase while zoomed?") ||
			pos == 43 && !StrEqual(text, "strength increase time cap?") ||
			pos == 44 && !StrEqual(text, "strength increase time required?") ||
			pos == 45 && !StrEqual(text, "no effect if zoom time is not met?") ||
			pos == 46 && !StrEqual(text, "strength increase while holding fire?") ||
			pos == 47 && !StrEqual(text, "no effect if damage time is not met?") ||
			pos == 48 && !StrEqual(text, "health percentage required missing?") ||
			pos == 49 && !StrEqual(text, "health percentage required missing max?") ||
			pos == 50 && !StrEqual(text, "is own talent?") ||
			pos == 51 && !StrEqual(text, "secondary ability trigger?") ||
			pos == 52 && !StrEqual(text, "target is self?") ||
			pos == 53 && !StrEqual(text, "primary aoe?") ||
			pos == 54 && !StrEqual(text, "secondary aoe?") ||
			pos == 55 && !StrEqual(text, "talent name?") ||
			pos == 56 && !StrEqual(text, "translation?") ||
			pos == 57 && !StrEqual(text, "governing attribute?") ||
			pos == 58 && !StrEqual(text, "talent tree category?") ||
			pos == 59 && !StrEqual(text, "part of menu named?") ||
			pos == 60 && !StrEqual(text, "layer?") ||
			pos == 61 && !StrEqual(text, "is ability?") ||
			pos == 62 && !StrEqual(text, "action bar name?") ||
			pos == 63 && !StrEqual(text, "required talents required?") ||
			pos == 64 && !StrEqual(text, "talent upgrade strength value?") ||
			pos == 65 && !StrEqual(text, "talent upgrade scale?") ||
			pos == 66 && !StrEqual(text, "talent cooldown strength value?") ||
			pos == 67 && !StrEqual(text, "talent cooldown scale?") ||
			pos == 68 && !StrEqual(text, "talent active time strength value?") ||
			pos == 69 && !StrEqual(text, "talent active time scale?") ||
			pos == 70 && !StrEqual(text, "governs cooldown of talent named?") ||
			pos == 71 && !StrEqual(text, "talent hard limit?") ||
			pos == 72 && !StrEqual(text, "is effect over time?") ||
			pos == 73 && !StrEqual(text, "effect strength?") ||
			pos == 74 && !StrEqual(text, "ignore for layer count?") ||
			pos == 75 && !StrEqual(text, "is attribute?") ||
			pos == 76 && !StrEqual(text, "hide translation?") ||
			pos == 77 && !StrEqual(text, "roll chance?")) {
				TalentKey.Resize(sortSize+1);
				TalentValue.Resize(sortSize+1);
				TalentKey.SetString(sortSize, text);
				TalentValue.GetString(pos, text, sizeof(text));
				TalentValue.SetString(sortSize, text);
				TalentKey.Erase(pos);
				TalentValue.Erase(pos);
				continue;
			}	// had to split this argument up due to internal compiler error on arguments exceeding 80
			else if (
			pos == 78 && !StrEqual(text, "interval per point?") ||
			pos == 79 && !StrEqual(text, "interval first point?") ||
			pos == 80 && !StrEqual(text, "range per point?") ||
			pos == 81 && !StrEqual(text, "range first point value?") ||
			pos == 82 && !StrEqual(text, "stamina per point?") ||
			pos == 83 && !StrEqual(text, "base stamina required?") ||
			pos == 84 && !StrEqual(text, "cooldown per point?") ||
			pos == 85 && !StrEqual(text, "cooldown first point?") ||
			pos == 86 && !StrEqual(text, "cooldown start?") ||
			pos == 87 && !StrEqual(text, "active time per point?") ||
			pos == 88 && !StrEqual(text, "active time first point?") ||
			pos == 89 && !StrEqual(text, "ammo effect?") ||
			pos == 90 && !StrEqual(text, "effect multiplier?") ||
			pos == 91 && !StrEqual(text, "active effect?") ||
			pos == 92 && !StrEqual(text, "passive effect?") ||
			pos == 93 && !StrEqual(text, "cooldown effect?") ||
			pos == 94 && !StrEqual(text, "reactive ability?") ||
			pos == 95 && !StrEqual(text, "teams allowed?") ||
			pos == 96 && !StrEqual(text, "cooldown strength?") ||
			pos == 97 && !StrEqual(text, "maximum passive multiplier?") ||
			pos == 98 && !StrEqual(text, "maximum active multiplier?") ||
			pos == 99 && !StrEqual(text, "active requires ensnare?") ||
			pos == 100 && !StrEqual(text, "active strength?") ||
			pos == 101 && !StrEqual(text, "passive ignores cooldown?") ||
			pos == 102 && !StrEqual(text, "passive requires ensnare?") ||
			pos == 103 && !StrEqual(text, "passive strength?") ||
			pos == 104 && !StrEqual(text, "passive only?") ||
			pos == 105 && !StrEqual(text, "is single target?") ||
			pos == 106 && !StrEqual(text, "draw delay?") ||
			pos == 107 && !StrEqual(text, "draw effect delay?") ||
			pos == 108 && !StrEqual(text, "passive draw delay?") ||
			pos == 109 && !StrEqual(text, "attribute?") ||
			pos == 110 && !StrEqual(text, "use these multipliers?") ||
			pos == 111 && !StrEqual(text, "base multiplier?") ||
			pos == 112 && !StrEqual(text, "diminishing multiplier?") ||
			pos == 113 && !StrEqual(text, "diminishing returns?") ||
			pos == 114 && !StrEqual(text, "buff bar text?") ||
			pos == 115 && !StrEqual(text, "is sub menu?") ||
			pos == 116 && !StrEqual(text, "talent type?") ||
			pos == 117 && !StrEqual(text, "is item?") ||
			pos == 118 && !StrEqual(text, "rarity?") ||
			pos == 119 && !StrEqual(text, "experience start?") ||
			pos == 120 && !StrEqual(text, "requirement multiplier?") ||
			pos == 121 && !StrEqual(text, "is aura instead?") ||
			pos == 122 && !StrEqual(text, "cooldown trigger?") ||
			pos == 123 && !StrEqual(text, "inactive trigger?") ||
			pos == 124 && !StrEqual(text, "reactive type?") ||
			pos == 125 && !StrEqual(text, "active time?") ||
			pos == 126 && !StrEqual(text, "cannot be ensnared?") ||
			pos == 127 && !StrEqual(text, "sky level requirement?") ||
			pos == 128 && !StrEqual(text, "toggle effect?") ||
			pos == 129 && !StrEqual(text, "humanoid only?") ||
			pos == 130 && !StrEqual(text, "inanimate only?") ||
			pos == 131 && !StrEqual(text, "allow commons?") ||
			pos == 132 && !StrEqual(text, "allow specials?") ||
			pos == 133 && !StrEqual(text, "allow survivors?") ||
			pos == 134 && !StrEqual(text, "cooldown?") ||
			pos == 135 && !StrEqual(text, "activate effect per tick?") ||
			pos == 136 && !StrEqual(text, "secondary ept only?") ||
			pos == 137 && !StrEqual(text, "active end ability trigger?") ||
			pos == 138 && !StrEqual(text, "cooldown end ability trigger?") ||
			pos == 139 && !StrEqual(text, "does damage?") ||
			pos == 140 && !StrEqual(text, "special ammo?")) {
				TalentKey.Resize(sortSize+1);
				TalentValue.Resize(sortSize+1);
				TalentKey.SetString(sortSize, text);
				TalentValue.GetString(pos, text, sizeof(text));
				TalentValue.SetString(sortSize, text);
				TalentKey.Erase(pos);
				TalentValue.Erase(pos);
				continue;
			}
			else if (
				pos == 141 && !StrEqual(text, "minimum level required?") ||
				pos == 142 && !StrEqual(text, "toggle strength?") ||
				pos == 143 && !StrEqual(text, "target class must be last target class?") ||
				pos == 144 && !StrEqual(text, "target range required?") ||
				pos == 145 && !StrEqual(text, "target must be outside range required?") ||
				pos == 146 && !StrEqual(text, "target must be last target?") ||
				pos == 147 && !StrEqual(text, "requires activator on fire?") ||			// [Bu]
				pos == 148 && !StrEqual(text, "requires activator acid burn?") ||		// [Ab]
				pos == 149 && !StrEqual(text, "requires activator exploding?") ||		// [Ex]
				pos == 150 && !StrEqual(text, "requires activator slowed?") ||			// [Sl]
				pos == 151 && !StrEqual(text, "requires activator frozen?") ||			// [Fr]
				pos == 152 && !StrEqual(text, "requires activator scorched?") ||		// [Sc]
				pos == 153 && !StrEqual(text, "requires activator steaming?") ||		// [St]
				pos == 154 && !StrEqual(text, "requires activator drowning?") ||		// [Wa]
				pos == 155 && !StrEqual(text, "activator high ground?") ||
				pos == 156 && !StrEqual(text, "target high ground?") ||
				pos == 157 && !StrEqual(text, "activator neither high or low ground?") ||
				pos == 158 && !StrEqual(text, "target must be in the air?") ||
				pos == 159 && !StrEqual(text, "event type?")){
				TalentKey.Resize(sortSize+1);
				TalentValue.Resize(sortSize+1);
				TalentKey.SetString(sortSize, text);
				TalentValue.GetString(pos, text, sizeof(text));
				TalentValue.SetString(sortSize, text);
				TalentKey.Erase(pos);
				TalentValue.Erase(pos);
				continue;
			}
			pos++;
		}
	}
	else if (StrEqual(Config, CONFIG_EVENTS)) {
		if (TalentKey.FindString("entered saferoom?") == -1) {
			TalentKey.PushString("entered saferoom?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("bulletimpact?") == -1) {
			TalentKey.PushString("bulletimpact?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("shoved?") == -1) {
			TalentKey.PushString("shoved?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("multiplier exp?") == -1) {
			TalentKey.PushString("multiplier exp?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("multiplier points?") == -1) {
			TalentKey.PushString("multiplier points?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("distance?") == -1) {
			TalentKey.PushString("distance?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("origin?") == -1) {
			TalentKey.PushString("origin?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("tag ability?") == -1) {
			TalentKey.PushString("tag ability?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("abilities?") == -1) {
			TalentKey.PushString("abilities?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("damage award?") == -1) {
			TalentKey.PushString("damage award?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("health?") == -1) {
			TalentKey.PushString("health?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("damage type?") == -1) {
			TalentKey.PushString("damage type?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("victim ability trigger?") == -1) {
			TalentKey.PushString("victim ability trigger?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("victim team required?") == -1) {
			TalentKey.PushString("victim team required?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("perpetrator ability trigger?") == -1) {
			TalentKey.PushString("perpetrator ability trigger?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("perpetrator team required?") == -1) {
			TalentKey.PushString("perpetrator team required?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("same team event trigger?") == -1) {
			TalentKey.PushString("same team event trigger?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("victim?") == -1) {
			TalentKey.PushString("victim?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("perpetrator?") == -1) {
			TalentKey.PushString("perpetrator?");
			TalentValue.PushString("-1");
		}
		sortSize = TalentKey.Length;
		pos = 0;
		while (pos < sortSize) {
			TalentKey.GetString(pos, text, sizeof(text));
			if (
			pos == 0 && !StrEqual(text, "perpetrator?") ||
			pos == 1 && !StrEqual(text, "victim?") ||
			pos == 2 && !StrEqual(text, "same team event trigger?") ||
			pos == 3 && !StrEqual(text, "perpetrator team required?") ||
			pos == 4 && !StrEqual(text, "perpetrator ability trigger?") ||
			pos == 5 && !StrEqual(text, "victim team required?") ||
			pos == 6 && !StrEqual(text, "victim ability trigger?") ||
			pos == 7 && !StrEqual(text, "damage type?") ||
			pos == 8 && !StrEqual(text, "health?") ||
			pos == 9 && !StrEqual(text, "damage award?") ||
			pos == 10 && !StrEqual(text, "abilities?") ||
			pos == 11 && !StrEqual(text, "tag ability?") ||
			pos == 12 && !StrEqual(text, "origin?") ||
			pos == 13 && !StrEqual(text, "distance?") ||
			pos == 14 && !StrEqual(text, "multiplier points?") ||
			pos == 15 && !StrEqual(text, "multiplier exp?") ||
			pos == 16 && !StrEqual(text, "shoved?") ||
			pos == 17 && !StrEqual(text, "bulletimpact?") ||
			pos == 18 && !StrEqual(text, "entered saferoom?")) {
				TalentKey.Resize(sortSize+1);
				TalentValue.Resize(sortSize+1);
				TalentKey.SetString(sortSize, text);
				TalentValue.GetString(pos, text, sizeof(text));
				TalentValue.SetString(sortSize, text);
				TalentKey.Erase(pos);
				TalentValue.Erase(pos);
				continue;
			}
			pos++;
		}
	}
	else if (StrEqual(Config, CONFIG_COMMONAFFIXES)) {
		if (TalentKey.FindString("require bile?") == -1) {
			TalentKey.PushString("require bile?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("raw player strength?") == -1) {
			TalentKey.PushString("raw player strength?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("raw common strength?") == -1) {
			TalentKey.PushString("raw common strength?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("raw strength?") == -1) {
			TalentKey.PushString("raw strength?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("strength special?") == -1) {
			TalentKey.PushString("strength special?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("onfire interval?") == -1) {
			TalentKey.PushString("onfire interval?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("onfire max time?") == -1) {
			TalentKey.PushString("onfire max time?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("onfire level?") == -1) {
			TalentKey.PushString("onfire level?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("onfire base time?") == -1) {
			TalentKey.PushString("onfire base time?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("enemy multiplication?") == -1) {
			TalentKey.PushString("enemy multiplication?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("damage effect?") == -1) {
			TalentKey.PushString("damage effect?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("force model?") == -1) {
			TalentKey.PushString("force model?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("level required?") == -1) {
			TalentKey.PushString("level required?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("death multiplier?") == -1) {
			TalentKey.PushString("death multiplier?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("death interval?") == -1) {
			TalentKey.PushString("death interval?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("death max time?") == -1) {
			TalentKey.PushString("death max time?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("death base time?") == -1) {
			TalentKey.PushString("death base time?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("death effect?") == -1) {
			TalentKey.PushString("death effect?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("chain reaction?") == -1) {
			TalentKey.PushString("chain reaction?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("name?") == -1) {
			TalentKey.PushString("name?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("health per level?") == -1) {
			TalentKey.PushString("health per level?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("base health?") == -1) {
			TalentKey.PushString("base health?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("glow colour?") == -1) {
			TalentKey.PushString("glow colour?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("glow range?") == -1) {
			TalentKey.PushString("glow range?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("glow?") == -1) {
			TalentKey.PushString("glow?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("model size?") == -1) {
			TalentKey.PushString("model size?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("fire immunity?") == -1) {
			TalentKey.PushString("fire immunity?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("draw type?") == -1) {
			TalentKey.PushString("draw type?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("chance?") == -1) {
			TalentKey.PushString("chance?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("level strength?") == -1) {
			TalentKey.PushString("level strength?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("strength target?") == -1) {
			TalentKey.PushString("strength target?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("aura strength?") == -1) {
			TalentKey.PushString("aura strength?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("cooldown?") == -1) {
			TalentKey.PushString("cooldown?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("range max?") == -1) {
			TalentKey.PushString("range max?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("range player level?") == -1) {
			TalentKey.PushString("range player level?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("range minimum?") == -1) {
			TalentKey.PushString("range minimum?");
			TalentValue.PushString("-1.0");
		}
		if (TalentKey.FindString("aura effect?") == -1) {
			TalentKey.PushString("aura effect?");
			TalentValue.PushString("-1");
		}
		if (TalentKey.FindString("max allowed?") == -1) {
			TalentKey.PushString("max allowed?");
			TalentValue.PushString("-1");
		}
		sortSize = TalentKey.Length;
		pos = 0;
		while (pos < sortSize) {
			TalentKey.GetString(pos, text, sizeof(text));
			if (
			pos == 0 && !StrEqual(text, "max allowed?") ||
			pos == 1 && !StrEqual(text, "aura effect?") ||
			pos == 2 && !StrEqual(text, "range minimum?") ||
			pos == 3 && !StrEqual(text, "range player level?") ||
			pos == 4 && !StrEqual(text, "range max?") ||
			pos == 5 && !StrEqual(text, "cooldown?") ||
			pos == 6 && !StrEqual(text, "aura strength?") ||
			pos == 7 && !StrEqual(text, "strength target?") ||
			pos == 8 && !StrEqual(text, "level strength?") ||
			pos == 9 && !StrEqual(text, "chance?") ||
			pos == 10 && !StrEqual(text, "draw type?") ||
			pos == 11 && !StrEqual(text, "fire immunity?") ||
			pos == 12 && !StrEqual(text, "model size?") ||
			pos == 13 && !StrEqual(text, "glow?") ||
			pos == 14 && !StrEqual(text, "glow range?") ||
			pos == 15 && !StrEqual(text, "glow colour?") ||
			pos == 16 && !StrEqual(text, "base health?") ||
			pos == 17 && !StrEqual(text, "health per level?") ||
			pos == 18 && !StrEqual(text, "name?") ||
			pos == 19 && !StrEqual(text, "chain reaction?") ||
			pos == 20 && !StrEqual(text, "death effect?") ||
			pos == 21 && !StrEqual(text, "death base time?") ||
			pos == 22 && !StrEqual(text, "death max time?") ||
			pos == 23 && !StrEqual(text, "death interval?") ||
			pos == 24 && !StrEqual(text, "death multiplier?") ||
			pos == 25 && !StrEqual(text, "level required?") ||
			pos == 26 && !StrEqual(text, "force model?") ||
			pos == 27 && !StrEqual(text, "damage effect?") ||
			pos == 28 && !StrEqual(text, "enemy multiplication?") ||
			pos == 29 && !StrEqual(text, "onfire base time?") ||
			pos == 30 && !StrEqual(text, "onfire level?") ||
			pos == 31 && !StrEqual(text, "onfire max time?") ||
			pos == 32 && !StrEqual(text, "onfire interval?") ||
			pos == 33 && !StrEqual(text, "strength special?") ||
			pos == 34 && !StrEqual(text, "raw strength?") ||
			pos == 35 && !StrEqual(text, "raw common strength?") ||
			pos == 36 && !StrEqual(text, "raw player strength?") ||
			pos == 37 && !StrEqual(text, "require bile?")) {
				TalentKey.Resize(sortSize+1);
				TalentValue.Resize(sortSize+1);
				TalentKey.SetString(sortSize, text);
				TalentValue.GetString(pos, text, sizeof(text));
				TalentValue.SetString(sortSize, text);
				TalentKey.Erase(pos);
				TalentValue.Erase(pos);
				continue;
			}
			pos++;
		}
	}
	Section.GetString(size, text, sizeof(text));
	TalentSection.PushString(text);
	/*if (StrEqual(Config, CONFIG_MENUTALENTS) || StrEqual(Config, CONFIG_EVENTS)) {
		LogMessage("%s", text);
		sortSize = TalentKey.Length;
		for (new i = 0; i < sortSize; i++) {
			TalentKey.GetString(i, key, sizeof(key));
			TalentValue.GetString(i, value, sizeof(value));
			LogMessage("\t\"%s\"\t\t\"%s\"", key, value);
		}
	}*/
	if (StrEqual(Config, CONFIG_MENUTALENTS)) a_Database_Talents.PushString(text);
	Main.Resize(size + 1);
	Main.Set(size, TalentKey, 0);
	Main.Set(size, TalentValue, 1);
	Main.Set(size, TalentSection, 2);
}

public int ReadyUp_FwdGetHeader(const char[] header) {
	strcopy(s_rup, sizeof(s_rup), header);
}

public int ReadyUp_FwdGetCampaignName(const char[] mapname) {
	strcopy(currentCampaignName, sizeof(currentCampaignName), mapname);
}

public int ReadyUp_CoopMapFailed(int iGamemode) {
	if (!b_IsMissionFailed) {
		b_IsMissionFailed	= true;
		Points_Director = 0.0;
	}
}

stock bool IsCommonRegistered(int entity) {
	if (FindListPositionByEntity(entity, CommonList) >= 0 ||
		FindListPositionByEntity(entity, CommonInfected) >= 0) return true;
	return false;
}

stock bool IsSpecialCommon(int entity) {
	if (FindListPositionByEntity(entity, CommonList) >= 0) {
		if (IsCommonInfected(entity)) return true;
		else ClearSpecialCommon(entity, false);
	}
	return false;
}

/*stock FindClientWithAuth(authid) {

	decl String:AuthString[64];
	decl String:AuthComp[64];

	for (new i = 1; i <= MaxClients; i++) {
		
		if (!IsLegitimateClient(i)) continue;

		GetClientAuthId(i, AuthIdType:AuthId_Steam3, AuthString, 64);
		IntToString(authid, AuthComp, sizeof(AuthComp));

		if (StrContains(AuthString, AuthComp) != -1) return i;
	}
	return -1;
}*/
//GetClientAuthId(client, AuthIdType:AuthId_Steam3, String:AuthString, maxlen, bool:validate=true);

#include "rpg/rpg_menu.sp"
#include "rpg/rpg_menu_points.sp"
#include "rpg/rpg_menu_store.sp"
#include "rpg/rpg_menu_chat.sp"
#include "rpg/rpg_menu_director.sp"
#include "rpg/rpg_timers.sp"
#include "rpg/rpg_functions.sp"
#include "rpg/rpg_events.sp"
#include "rpg/rpg_database.sp"
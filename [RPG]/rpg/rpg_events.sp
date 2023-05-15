
#pragma newdecls required

// Every single event in the events.cfg is called by this function, and then sent off to a specific function.
// This way a separate template isn't required for events that have different event names.
public Action Event_Occurred(Event event, char[] event_name, bool dontBroadcast) {

	//if (b_IsSurvivalIntermission) return Plugin_Handled;

	int a_Size						= 0;
	a_Size							= a_Events.Length;

	char EventName[PLATFORM_MAX_PATH];
	int eventresult = 0;

	char CurrMap[64];
	GetCurrentMap(CurrMap, sizeof(CurrMap));

	for (int i = 0; i < a_Size; i++) {

		EventSection						= a_Events.Get(i, 2);
		EventSection.GetString(0, EventName, sizeof(EventName));

		if (StrEqual(EventName, event_name)) {

			//if (Call_Event(event, event_name, dontBroadcast, i) == -1) {

				/*if (StrEqual(EventName, "infected_hurt") || StrEqual(EventName, "player_hurt")) {

					

					//	Returns -1 when infected_hurt or player_hurt and the cause of the damage is not a common infected or a player
					//	or if the damage is "inferno" which can be discerned through the player_hurt event only; we have to resort to
					//	the prior for infected_hurt
					

					return Plugin_Handled;
				}*/
			//}
			eventresult = Call_Event(event, event_name, dontBroadcast, i);
			break;
		}
	}
	//if (StrEqual(EventName, "player_shoved", false)) PrintToChatAll("player shoved!");
	//if (StrEqual(EventName, "entity_shoved", false)) PrintToChatAll("entity shoved!");
	if (StrContains(EventName, "finale_radio_start", false) != -1) return Plugin_Continue;
	if (eventresult == -1 && b_IsActiveRound) return Plugin_Handled;
	return Plugin_Continue;
	//if (StrEqual(EventName, "infected_hurt") || StrEqual(EventName, "player_hurt")) return Plugin_Handled;
	//else return Plugin_Continue;
}

public void SubmitEventHooks(int value) {

	int size = a_Events.Length;
	char text[64];

	for (int i = 0; i < size; i++) {

		HookSection = a_Events.Get(i, 2);
		HookSection.GetString(0, text, sizeof(text));
		if (StrEqual(text, "player_hurt", false) ||
			StrEqual(text, "infected_hurt", false)) {

			if (value == 0) UnhookEvent(text, Event_Occurred, EventHookMode_Pre);
			else HookEvent(text, Event_Occurred, EventHookMode_Pre);
		}
		else {

			if (value == 0) UnhookEvent(text, Event_Occurred);
			else HookEvent(text, Event_Occurred);
		}
	}
}

stock void FindPlayerWeapon(int client, char[] weapon, int size) {
	if (IsLegitimateClient(client) && GetClientTeam(client) == TEAM_INFECTED) {
		GetClientWeapon(client, weapon, size);
	}
	else {
		int g_iActiveWeaponOffset = FindSendPropInfo("CTerrorPlayer", "m_hActiveWeapon");
		int iWeapon = GetEntDataEnt2(client, g_iActiveWeaponOffset);
		if (IsValidEdict(iWeapon)) GetEdictClassname(iWeapon, weapon, size);
		else Format(weapon, size, "-1");
	}
}

public int Call_Event(Event event, char[] event_name, bool dontBroadcast, int pos) {
	//CallKeys							= a_Events.Get(pos, 0);
	CallValues							= a_Events.Get(pos, 1);
	char ThePerp[64];
	CallValues.GetString(EVENT_PERPETRATOR, ThePerp, sizeof(ThePerp));
	int attacker = GetClientOfUserId(event.GetInt(ThePerp));
	CallValues.GetString(EVENT_VICTIM, ThePerp, sizeof(ThePerp));
	int victim = GetClientOfUserId(event.GetInt(ThePerp));
	bool IsLegitimateClientAttacker = IsLegitimateClient(attacker);
	int attackerTeam = -1;
	int attackerZombieClass = -1;
	bool IsFakeClientAttacker = false;
	if (IsLegitimateClientAttacker) {
		attackerTeam = GetClientTeam(attacker);
		IsFakeClientAttacker = IsFakeClient(attacker);
		attackerZombieClass = FindZombieClass(attacker);
	}
	int victimType = -1;
	int victimTeam = -1;
	bool IsFakeClientVictim = false;
	if (IsCommonInfected(victim)) victimType = 0;
	else if (IsWitch(victim)) victimType = 1;
	else if (IsLegitimateClient(victim)) {
		victimType = 2;
		victimTeam = GetClientTeam(victim);
		IsFakeClientVictim = IsFakeClient(victim);
	}
	if (IsLegitimateClientAttacker && victimType != -1) {
		if (victimType == 1 && FindListPositionByEntity(victim, WitchList) < 0) OnWitchCreated(victim);
		// These calls are specific to special infected and survivor events - does not handle common infected, super infected, or witches.
		// Talents/Nodes can be triggered when specific events occur.
		// They can be special calls, so that it looks for specific case-sens strings instead of characters.
		if (((victimType == 0 || victimType == 1) && attackerTeam == TEAM_SURVIVOR) ||
			victimType == 2 && (!IsLegitimateClientAttacker || attackerTeam != victimTeam || GetKeyValueIntAtPos(CallValues, EVENT_SAMETEAM_TRIGGER) == 1)) {
			char abilityTriggerActivator[64];
			char abilityTriggerTarget[64];
			CallValues.GetString(EVENT_PERPETRATOR_TEAM_REQ, abilityTriggerActivator, sizeof(abilityTriggerActivator));
			if (!StrEqual(abilityTriggerActivator, "-1")) {
				Format(ThePerp, sizeof(ThePerp), "%d", attackerTeam);
				if (StrContains(abilityTriggerActivator, ThePerp) != -1) {
					CallValues.GetString(EVENT_PERPETRATOR_ABILITY_TRIGGER, abilityTriggerActivator, sizeof(abilityTriggerActivator));
					if (!StrEqual(abilityTriggerActivator, "-1")) GetAbilityStrengthByTrigger(attacker, victim, abilityTriggerActivator);
				}
			}
			CallValues.GetString(EVENT_VICTIM_TEAM_REQ, abilityTriggerTarget, sizeof(abilityTriggerTarget));
			if (!StrEqual(abilityTriggerTarget, "-1")) {
				Format(ThePerp, sizeof(ThePerp), "%d", victimTeam);
				if (StrContains(abilityTriggerTarget, ThePerp) != -1) {
					CallValues.GetString(EVENT_VICTIM_ABILITY_TRIGGER, abilityTriggerTarget, sizeof(abilityTriggerTarget));
					if (!StrEqual(abilityTriggerTarget, "-1")) GetAbilityStrengthByTrigger(victim, attacker, abilityTriggerTarget);
				}
			}
		}
	}
	if (StrEqual(event_name, "ammo_pickup") && IsLegitimateClientAttacker) {
		GiveAmmoBack(attacker, 999);	// whenever a player picks up an ammo pile, we want to give them their full ammo reserves - vanilla + talents.
	}
	char weapon[64];
	if (StrEqual(event_name, "player_left_start_area") && IsLegitimateClientAttacker) {
		if (attackerTeam == TEAM_SURVIVOR) {
			if (IsFakeClientAttacker && attackerTeam == TEAM_SURVIVOR && !b_IsLoaded[attacker]) IsClientLoadedEx(attacker);
			if (b_IsInSaferoom[attacker] && RoundExperienceMultiplier[attacker] > 0.0) {
				b_IsInSaferoom[attacker] = false;
				//PrintToChat(attacker, "%T", "bonus container locked", attacker, orange, blue);
				char saferoomName[64];
				GetClientName(attacker, saferoomName, sizeof(saferoomName));
				char pct[4];
				Format(pct, sizeof(pct), "%");
				PrintToChatAll("%t", "round bonus multiplier", blue, saferoomName, white, orange, (1.0 + RoundExperienceMultiplier[attacker]) * 100.0, orange, pct, white);
			}
		}
	}
	if (IsLegitimateClientAttacker) {
		if (StrEqual(event_name, "player_entered_checkpoint")) bIsInCheckpoint[attacker] = true;
		if (StrEqual(event_name, "player_left_checkpoint")) bIsInCheckpoint[attacker] = false;
	}
	if (StrEqual(event_name, "player_spawn")) {
		if (IsLegitimateClientAttacker) {
			ActiveStatuses[attacker].Clear();
			if (attackerTeam == TEAM_SURVIVOR) {
				ChangeHook(attacker, true);
				RefreshSurvivor(attacker);
				RaidInfectedBotLimit();
			}
			else {
				SetInfectedHealth(attacker, 99999);
				if (!IsFakeClientAttacker) PlayerSpawnAbilityTrigger(attacker);
				if (!IsSurvivorBot(attacker)) {
					PlayerAbilitiesCooldown[attacker].Clear();
					InfectedHealth[attacker].Clear();
					int aDbSize = a_Database_Talents.Length;
					a_Database_PlayerTalents[attacker].Resize(aDbSize);
					PlayerAbilitiesCooldown[attacker].Resize(aDbSize);
					a_Database_PlayerTalents_Experience[attacker].Resize(aDbSize);
					InfectedHealth[attacker].Resize(1);	// infected player stores their actual health (from talents, abilities, etc.) locally...
					bHealthIsSet[attacker] = false;
					if (!b_IsHooked[attacker]) {
						ChangeHook(attacker, true);
						CreateMyHealthPool(attacker);
					}
					if (attackerZombieClass == ZOMBIECLASS_TANK) {
						TankState_Array[attacker].Clear();
						bHasTeleported[attacker] = false;
						if (iTanksPreset == 1) {
							int iRand = GetRandomInt(1, 3);
							if (iRand == 1) ChangeTankState(attacker, "hulk");
							else if (iRand == 2) ChangeTankState(attacker, "death");
							else if (iRand == 3) ChangeTankState(attacker, "burn");
						}
					}
				}
			}
		}
	}
	if (!b_IsActiveRound || IsLegitimateClientAttacker && attackerTeam == TEAM_SURVIVOR && !b_IsLoaded[attacker]) return 0;		// don't track ANYTHING when it's not an active round.
	char curEquippedWeapon[64];
	if (StrEqual(event_name, "weapon_reload") || StrEqual(event_name, "bullet_impact")) {
		int WeaponId =	GetEntPropEnt(attacker, Prop_Data, "m_hActiveWeapon");
		GetEntityClassname(WeaponId, curEquippedWeapon, sizeof(curEquippedWeapon));
	}
	if (victimType == 2 && victimTeam == TEAM_SURVIVOR) {
		if (StrEqual(event_name, "revive_success")) {
			if (attacker != victim) {
				GetAbilityStrengthByTrigger(victim, attacker, "R", _, 0);
				GetAbilityStrengthByTrigger(attacker, victim, "r", _, 0);
			}
			SetEntPropEnt(victim, Prop_Send, "m_reviveOwner", -1);
			SetEntPropEnt(attacker, Prop_Send, "m_reviveTarget", -1);
			int reviveOwner = GetEntPropEnt(victim, Prop_Send, "m_reviveOwner");
			if (IsLegitimateClient(reviveOwner)) SetEntPropEnt(reviveOwner, Prop_Send, "m_reviveTarget", -1);
			GiveMaximumHealth(victim);
		}
	}
	CallValues.GetString(EVENT_DAMAGE_TYPE, ThePerp, sizeof(ThePerp));
	int damagetype = event.GetInt(ThePerp);
	if (StrEqual(event_name, "finale_radio_start") && !b_IsFinaleActive) {
		// When the finale is active, players can earn experience whilst camping (not moving from a spot, re: farming)
		b_IsFinaleActive = true;
		if (GetInfectedCount(ZOMBIECLASS_TANK) < 1) b_IsFinaleTanks = true;
		if (iTankRush == 1) {
			PrintToChatAll("%t", "the zombies are coming", blue, orange, blue);
			ExecCheatCommand(FindAnyRandomClient(), "director_force_panic_event");
		}
	}
	if (StrEqual(event_name, "finale_vehicle_ready")) {
		// When the vehicle arrives, the finale is no longer active, but no experience can be earned. This stops farming.
		if (b_IsFinaleActive) {
			b_IsFinaleActive = false;
			int TheInfectedLevel = HumanSurvivorLevels();
			int TheHumans = HumanPlayersInGame();
			int TheLiving = LivingSurvivorCount();
			//new RatingMult = GetConfigValueInt("rating level multiplier?");
			int InfectedLevelType = iBotLevelType;
			for (int i = 1; i <= MaxClients; i++) {
				if (IsLegitimateClientAlive(i) && GetClientTeam(i) == TEAM_SURVIVOR) {
					if (InfectedLevelType == 0) Rating[i] += (RaidLevMult / TheLiving);
					else {
						if (!bIsSoloHandicap) Rating[i] += (TheInfectedLevel / TheHumans);
						else Rating[i] += RaidLevMult;
					}
					RoundExperienceMultiplier[i] += FinSurvBon;
				}
			}
		}
		//PrintToChatAll("%t", "Experience Gains Disabled", orange, white, orange, white, blue);
	}
	// Declare the values that can be defined by the event config, so we know whether to consider them.
	//new RPGMode						= iRPGMode;	// 1 experience 2 experience & points
	char AbilityUsed[PLATFORM_MAX_PATH];
	char abilities[PLATFORM_MAX_PATH];
	CallValues.GetString(EVENT_GET_HEALTH, ThePerp, sizeof(ThePerp));
	int healthvalue = event.GetInt(ThePerp);
	int isdamageaward = GetKeyValueIntAtPos(CallValues, EVENT_DAMAGE_AWARD);
	CallValues.GetString(EVENT_GET_ABILITIES, abilities, sizeof(abilities));
	int tagability = GetKeyValueIntAtPos(CallValues, EVENT_IS_PLAYER_NOW_IT);
	int originvalue = GetKeyValueIntAtPos(CallValues, EVENT_IS_ORIGIN);
	int distancevalue = GetKeyValueIntAtPos(CallValues, EVENT_IS_DISTANCE);
	float multiplierpts = GetKeyValueFloatAtPos(CallValues, EVENT_MULTIPLIER_POINTS);
	float multiplierexp = GetKeyValueFloatAtPos(CallValues, EVENT_MULTIPLIER_EXPERIENCE);
	int isshoved = GetKeyValueIntAtPos(CallValues, EVENT_IS_SHOVED);
	int bulletimpact = GetKeyValueIntAtPos(CallValues, EVENT_IS_BULLET_IMPACT);
	int isinsaferoom = GetKeyValueIntAtPos(CallValues, EVENT_ENTERED_SAFEROOM);
	if (bulletimpact == 1) {
		if (attackerTeam == TEAM_SURVIVOR) {
			int bulletsFired = 0;
			currentEquippedWeapon[attacker].GetValue(curEquippedWeapon, bulletsFired);
			currentEquippedWeapon[attacker].SetValue(curEquippedWeapon, bulletsFired + 1);
			float Coords[3];
			Coords[0] = event.GetFloat("x");
			Coords[1] = event.GetFloat("y");
			Coords[2] = event.GetFloat("z");
			float TargetPos[3];
			int target = GetAimTargetPosition(attacker, TargetPos);
			if (AllowShotgunToTriggerNodes(attacker)) LastWeaponDamage[attacker] = GetBaseWeaponDamage(attacker, target, Coords[0], Coords[1], Coords[2], damagetype);
			if (iIsBulletTrails[attacker] == 1) {
				float EyeCoords[3];
				GetClientEyePosition(attacker, EyeCoords);
				// Adjust the coords so they line up with the gun
				EyeCoords[2] -= 10.0;
				int TrailsColours[4];
				TrailsColours[3] = 200;
				char ClientModel[64];
				char TargetModel[64];
				GetClientModel(attacker, ClientModel, sizeof(ClientModel));
				int bulletsize		= a_Trails.Length;
				for (int i = 0; i < bulletsize; i++) {
					TrailsKeys[attacker] = a_Trails.Get(i, 0);
					TrailsValues[attacker] = a_Trails.Get(i, 1);
					FormatKeyValue(TargetModel, sizeof(TargetModel), TrailsKeys[attacker], TrailsValues[attacker], "model affected?");
					if (StrEqual(TargetModel, ClientModel)) {
						TrailsColours[0]		= GetKeyValueInt(TrailsKeys[attacker], TrailsValues[attacker], "red?");
						TrailsColours[1]		= GetKeyValueInt(TrailsKeys[attacker], TrailsValues[attacker], "green?");
						TrailsColours[2]		= GetKeyValueInt(TrailsKeys[attacker], TrailsValues[attacker], "blue?");
						break;
					}
				}
				for (int i = 1; i <= MaxClients; i++) {
					if (IsLegitimateClient(i) && !IsFakeClient(i)) {
						TE_SetupBeamPoints(EyeCoords, Coords, g_iSprite, 0, 0, 0, 0.06, 0.09, 0.09, 1, 0.0, TrailsColours, 0);
						TE_SendToClient(i);
					}
				}
			}
		}
	}
	if (StrEqual(event_name, "player_hurt") || StrEqual(event_name, "infected_hurt")) {
		if (IsLegitimateClientAttacker) {
			CheckIfHeadshot(attacker, victim, event, healthvalue);
			CheckIfLimbDamage(attacker, victim, event, healthvalue);
			if (IsPlayerUsingShotgun(attacker)) {
				if (shotgunCooldown[attacker]) return 0;
				shotgunCooldown[attacker] = true;
				CreateTimer(0.1, Timer_ResetShotgunCooldown, attacker, TIMER_FLAG_NO_MAPCHANGE);
			}
		}
		if (victimType == 2 && !b_IsHooked[victim]) ChangeHook(victim, true);
		//if (IsLegitimateClientAlive(victim) && GetClientTeam(victim) == TEAM_SURVIVOR && !b_IsHooked[victim]) ChangeHook(victim, true);
		if (IsLegitimateClientAttacker && IsFakeClientAttacker && attackerTeam == TEAM_SURVIVOR && !b_IsLoaded[attacker]) IsClientLoadedEx(attacker);
		if (victimType == 2 && IsFakeClientVictim && victimTeam == TEAM_SURVIVOR && !b_IsLoaded[victim]) IsClientLoadedEx(victim);
	}
	if (victimType == 2 && victimTeam == TEAM_INFECTED) {
		SetEntityHealth(victim, 400000);
	}
	if (tagability == 1 && victimType == 2) {
		if (!ISBILED[victim]) CreateTimer(15.0, Timer_RemoveBileStatus, victim, TIMER_FLAG_NO_MAPCHANGE);
		ISBILED[victim] = true;
	}
	if (tagability == 2 && IsLegitimateClientAttacker) ISBILED[attacker] = false;
	if (isdamageaward == 1) {
		if (IsLegitimateClientAttacker && victimType == 2 && attackerTeam == victimTeam) {
			if (!(damagetype & DMG_BURN) && !StrEqual(weapon, "inferno")) {
				// damage-based triggers now only occur under the circumstances in the code above. No longer do we have triggers for same-team damaging. Maybe at a later date, but it will not be the same ability trigger.
				GetAbilityStrengthByTrigger(attacker, victim, "d", _, healthvalue);
				GetAbilityStrengthByTrigger(victim, attacker, "l", _, healthvalue);
			}
			else ReadyUp_NtvFriendlyFire(attacker, victim, healthvalue, GetClientHealth(victim), 1, 0);
		}
		if (victimType == 2 && victimTeam == TEAM_INFECTED) SetEntityHealth(victim, 40000);
		if (IsLegitimateClientAttacker && attackerTeam == TEAM_SURVIVOR && isinsaferoom == 1) bIsInCheckpoint[attacker] = true;
	}
	if (isshoved == 1 && victimType == 2 && IsLegitimateClientAttacker && victimTeam != attackerTeam) {
		if (victimTeam == TEAM_INFECTED) SetEntityHealth(victim, GetClientHealth(victim) + healthvalue);
		GetAbilityStrengthByTrigger(victim, attacker, "H", _, 0);
	}
	if (isshoved == 2 && IsLegitimateClientAttacker && victimType == 0 && !IsCommonStaggered(victim)) {
		int staggeredSize = StaggeredTargets.Length;
		StaggeredTargets.Resize(staggeredSize + 1);
		StaggeredTargets.Set(staggeredSize, victim, 0);
		StaggeredTargets.Set(staggeredSize, 2.0, 1);
	}
	if (StrEqual(event_name, "weapon_reload")) {
		if (IsLegitimateClientAttacker && attackerTeam == TEAM_SURVIVOR) {
			ConsecutiveHits[attacker] = 0;	// resets on reload.
			currentEquippedWeapon[attacker].Remove(curEquippedWeapon);
		}
	}
	if (StrEqual(event_name, "player_spawn") && IsLegitimateClientAttacker && attackerTeam == TEAM_INFECTED) {
		if (IsFakeClientAttacker) {
			int changeClassId = 0;
			if (iSpecialsAllowed == 0 && attackerZombieClass != ZOMBIECLASS_TANK) {
				ForcePlayerSuicide(attacker);
			}
			if (iSpecialsAllowed == 1 && !StrEqual(sSpecialsAllowed, "-1")) {
				char myClass[5];
				Format(myClass, sizeof(myClass), "%d", attackerZombieClass);
				if (StrContains(sSpecialsAllowed, myClass) == -1) {
					while (StrContains(sSpecialsAllowed, myClass) == -1) {
						changeClassId = GetRandomInt(1,6);
						Format(myClass, sizeof(myClass), "%d", changeClassId);
					}
					ChangeInfectedClass(attacker, changeClassId);
				}
			}
			// In solo games, we restrict the number of ensnarement infected.
			IsAirborne[attacker] = false;
			b_GroundRequired[attacker] = false;
			HasSeenCombat[attacker] = false;
			MyBirthday[attacker] = GetTime();
			int iTankCount = GetInfectedCount(ZOMBIECLASS_TANK);
			int iTankLimit = DirectorTankLimit();
			int theClient = FindAnyRandomClient();
			int iSurvivors = TotalHumanSurvivors();
			int iSurvivorBots = TotalSurvivors() - iSurvivors;
			int iLivSurvs = LivingSurvivorCount();
			if (iSurvivorBots >= 2) iSurvivorBots /= 2;
			int requiredTankCount = GetAlwaysTanks(iSurvivors);
			if (attackerZombieClass == ZOMBIECLASS_TANK) {
				if (b_IsFinaleActive && b_IsFinaleTanks) {
					b_IsFinaleTanks = false;
					for (int i = 0; i + iTankCount < iTankLimit; i++) {
						ExecCheatCommand(theClient, "z_spawn_old", "tank auto");
					}
				}
				/*else {
					if (iTankCount > iTankLimit || f_TankCooldown != -1.0) {

						//PrintToChatAll("killing tank.");
						//ForcePlayerSuicide(attacker);
					}
				}*/
			}
			if (iNoSpecials == 1 || iTankRush == 1) {
				if (attackerZombieClass != ZOMBIECLASS_TANK) {
					//if (!IsEnrageActive())
					ForcePlayerSuicide(attacker);
					if (iSurvivors >= 1 && (iTankCount < requiredTankCount || !b_IsFinaleActive && iTankCount < iTankLimit)) {
						ExecCheatCommand(theClient, "z_spawn_old", "tank auto");
					}
				}
			}
			else if (attackerZombieClass != ZOMBIECLASS_TANK) {
				int iEnsnaredCount = EnsnaredInfected();
				int livingSurvivors = LivingHumanSurvivors();
				int ensnareBonus = (livingSurvivors > 1) ? livingSurvivors - 1 : 0;
				if (IsEnsnarer(attacker)) {
					if (iInfectedLimit == -2 && iEnsnaredCount > RaidCommonBoost(_, true) + ensnareBonus ||
					iInfectedLimit == -1 ||
					iInfectedLimit == 0 && iEnsnaredCount > livingSurvivors ||
					iInfectedLimit > 0 && iEnsnaredCount > iInfectedLimit ||
					iIsLifelink > 1 && iLivSurvs < iIsLifelink && iLivSurvs < iMinSurvivors) {
						while (IsEnsnarer(attacker, changeClassId)) {
							changeClassId = GetRandomInt(1,6);
						}
						ChangeInfectedClass(attacker, changeClassId);
					}
					else ChangeInfectedClass(attacker, _, true);	// doesn't change class but sets base health and speeds.
				}
				else ChangeInfectedClass(attacker, _, true);
			}
			else ChangeInfectedClass(attacker, _, true);
		}
		else SetSpecialInfectedHealth(attacker, attackerZombieClass);
	}
	if (StrEqual(event_name, "ability_use")) {
		if (attackerTeam == TEAM_INFECTED) {
			GetAbilityStrengthByTrigger(attacker, victim, "infected_abilityuse");
			event.GetString("ability", AbilityUsed, sizeof(AbilityUsed));
			if (StrContains(AbilityUsed, "ability_throw") != -1) {
				if (!(GetEntityFlags(attacker) & FL_ONFIRE) && !SurvivorsInRange(attacker, 1024.0)) ChangeTankState(attacker, "burn");
				else {
					ChangeTankState(attacker, "hulk");
					if (!SurvivorsInRange(attacker, 256.0)) ForceClientJump(attacker, 1000.0);
				}
			}
			/*if (StrContains(AbilityUsed, abilities, false) != -1) {

				if (FindZombieClass(attacker) == ZOMBIECLASS_HUNTER) PrintToChatAll("Pouncing!");

				// check for any abilities that are based on abilityused.
				GetClientAbsOrigin(attacker, Float:f_OriginStart[attacker]);
				//GetAbilityStrengthByTrigger(attacker, 0, 'A', FindZombieClass(attacker), healthvalue);
				GetAbilityStrengthByTrigger(attacker, _, 'A', FindZombieClass(attacker), healthvalue);	// activator, target, trigger ability, effects, zombieclass, damage
			}*/
		}
	}
	if (IsLegitimateClientAttacker && attackerTeam == TEAM_INFECTED) {
		float Distance = 0.0;
		float fTalentStrength = 0.0;
		if (originvalue > 0 || distancevalue > 0) {
			if (originvalue == 1 || distancevalue == 1) {
				GetClientAbsOrigin(attacker, f_OriginStart[attacker]);
				if (attackerZombieClass != ZOMBIECLASS_HUNTER &&
					attackerZombieClass != ZOMBIECLASS_SPITTER) {
					fTalentStrength = GetAbilityStrengthByTrigger(attacker, _, "Q", _, 0);
				}
				if (attackerZombieClass == ZOMBIECLASS_HUNTER) {
					// check for any abilities that are based on abilityused.
					GetClientAbsOrigin(attacker, f_OriginStart[attacker]);
					//GetAbilityStrengthByTrigger(attacker, 0, 'A', FindZombieClass(attacker), healthvalue);
					GetAbilityStrengthByTrigger(attacker, _, "A", _, healthvalue);
				}
				if (attackerZombieClass == ZOMBIECLASS_CHARGER) {
					CreateTimer(0.1, Timer_ChargerJumpCheck, attacker, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				}
			}
			if (originvalue == 2 || distancevalue == 2) {
				fTalentStrength = GetAbilityStrengthByTrigger(attacker, _, "q", _, 0);
				if (CheckActiveStatuses(attacker, "lunge", false, true) == 0) {
					SetEntityRenderMode(attacker, RENDER_NORMAL);
					SetEntityRenderColor(attacker, 255, 255, 255, 255);
					fTalentStrength += GetAbilityStrengthByTrigger(attacker, _, "A", _, 0);
				}
				GetClientAbsOrigin(attacker, f_OriginEnd[attacker]);
				if (victimType == 2 && victimTeam == TEAM_SURVIVOR) {
					Distance = GetVectorDistance(f_OriginStart[attacker], f_OriginEnd[attacker]);
					if (fTalentStrength > 0.0) Distance += (Distance * fTalentStrength);
					//SetClientTotalHealth(victim, RoundToCeil(Distance), _, true);
				}
			}
			if (attackerZombieClass == ZOMBIECLASS_JOCKEY || (distancevalue == 2 && t_Distance[attacker] > 0)) {
				if (distancevalue == 1) t_Distance[attacker] = GetTime();
				if (distancevalue == 2) {
					t_Distance[attacker] = GetTime() - t_Distance[attacker];
					multiplierexp *= t_Distance[attacker];
					multiplierpts *= t_Distance[attacker];
					t_Distance[attacker] = 0;
				}
			}
			else {
				if (distancevalue == 3 && victimType == 2) GetClientAbsOrigin(victim, f_OriginStart[attacker]);
				if (distancevalue == 2 || originvalue == 2 || distancevalue == 4 && victimType == 2) {
					if (distancevalue == 4) GetClientAbsOrigin(victim, f_OriginEnd[attacker]);
					//new Float:Distance = GetVectorDistance(f_OriginStart[attacker], f_OriginEnd[attacker]);
					multiplierexp *= Distance;
					multiplierpts *= Distance;
				}
			}
			if (originvalue == 2 || distancevalue == 2 || distancevalue == 4) {
				if (iRPGMode >= 1 && multiplierexp > 0.0) {
					ExperienceLevel[attacker] += RoundToCeil(multiplierexp);
					ExperienceOverall[attacker] += RoundToCeil(multiplierexp);
					ConfirmExperienceAction(attacker);
					if (iAwardBroadcast > 0 && !IsFakeClientAttacker) PrintToChat(attacker, "%T", "distance experience", attacker, white, green, RoundToCeil(multiplierexp), white);
				}
				if (iRPGMode != 1 && multiplierpts > 0.0) {

					Points[attacker] += multiplierpts;
					if (iAwardBroadcast > 0 && !IsFakeClientAttacker) PrintToChat(attacker, "%T", "distance points", attacker, white, green, multiplierpts, white);
				}
			}
		}
	}
	return 0;
}

stock bool AddOTEffect(int client, int target, char[] clientSteamID, float fStrength, int OTtype = 0) {
	float fClientStrength = 0.0;
	float fTargetStrength = 0.0;
	float fIntervalTime = 0.0;
	//new Float:fCurrentEffectStrength = 0.0;
	int iNewEffectStrength = 0;
	char SearchKey[64], SearchValue[64];
	GetClientAuthId(target, AuthId_Steam2, SearchKey, sizeof(SearchKey));
	Format(SearchKey, sizeof(SearchKey), "%s:%s:%d", clientSteamID, SearchKey, OTtype);
	if (OTtype == 0) {
		fClientStrength = GetAbilityStrengthByTrigger(client, client, "outhealingbonus", _, 0, _, _, "d", 1, true);	// we need a way to return a default value if there are no points in a category without using global variables. delete when this is solved.
		fIntervalTime	= GetAbilityStrengthByTrigger(client, client, "healingtickrate", _, 0, _, _, "d", 1, true);
		fTargetStrength = GetAbilityStrengthByTrigger(target, target, "inchealingbonus", _, 0, _, _, "d", 1, true);
		iNewEffectStrength = RoundToCeil((fClientStrength + fTargetStrength) * fStrength);	// uhhhhhhh this is a balance modifier for PvE/PvP
	}
	else if (OTtype == 1) {
		fClientStrength = GetAbilityStrengthByTrigger(client, client, "outdamagebonus", _, 0, _, _, "d", 1, true);
		fIntervalTime	= GetAbilityStrengthByTrigger(client, client, "damagetickrate", _, 0, _, _, "d", 1, true);
		fTargetStrength = GetAbilityStrengthByTrigger(target, target, "incdamagebonus", _, 0, _, _, "d", 1, true);
	}
	int size = EffectOverTime.Length;
	EffectOverTime.Resize(size + 1);
	EffectOverTime.Set(size, fIntervalTime, 0);
	EffectOverTime.Set(size, fIntervalTime, 1);
	EffectOverTime.Set(size, iNewEffectStrength, 2);
	//Format(SearchValue, sizeof(SearchValue), "%3.2f:%3.2f:%d", fIntervalTime, fIntervalTime, iNewEffectStrength);
	// a player could have multiple minor buffs or effects over time active at a time on them.
	//EffectOverTime.SetString(SearchKey, SearchValue);
	GetAbilityStrengthByTrigger(client, client, "damagebonus", _, 0, _, _, "d", 1, true);
}

stock void StoreItemName(int client, int pos, char[] s, int size) {

	StoreItemNameSection[client]					= a_Store.Get(pos, 2);
	StoreItemNameSection[client].GetString(0, s, size);
}

stock bool IsStoreItem(int client, char[] EName, bool b_IsAwarding = true) {

	char Name[64];
	int size				= a_Store.Length;

	for (int i = 0; i < size; i++) {

		StoreItemSection[client]				= a_Store.Get(i, 2);
		StoreItemSection[client].GetString(0, Name, sizeof(Name));

		if (StrEqual(Name, EName)) {

			if (b_IsAwarding) GiveClientStoreItem(client, i);
			return true;
		}
	}
	return false;
}

public Action Timer_ChargerJumpCheck(Handle timer, any client) {

	if (IsClientInGame(client) && IsFakeClient(client) && GetClientTeam(client) == TEAM_INFECTED) {

		if (FindZombieClass(client) != ZOMBIECLASS_CHARGER || !IsPlayerAlive(client)) return Plugin_Stop;
		int victim = L4D2_GetSurvivorVictim(client);
		if (victim == -1) return Plugin_Continue;
		if ((GetEntityFlags(client) & FL_ONGROUND)) {

			GetAbilityStrengthByTrigger(client, victim, "v", _, 0);
			return Plugin_Continue;
		}
	}
	return Plugin_Stop;
}

stock bool PlayerCastSpell(int client) {

	int CurrentEntity			=	GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");

	if (!IsValidEntity(CurrentEntity) || CurrentEntity < 1) return Plugin_Handled;
	char EntityName[64];


	GetEdictClassname(CurrentEntity, EntityName, sizeof(EntityName));

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

stock int CreateGravityAmmo(int client, float Force, float Range, bool UseTheForceLuke=false) {

	int entity		= CreateEntityByName("point_push");
	if (!IsValidEntity(entity)) return -1;
	char value[64];

	float Origin[3];
	float Angles[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
	GetEntPropVector(client, Prop_Send, "m_angRotation", Angles);
	Angles[0] += -90.0;

	DispatchKeyValueVector(entity, "origin", Origin);
	DispatchKeyValueVector(entity, "angles", Angles);
	Format(value, sizeof(value), "%d", RoundToCeil(Range / 2));
	DispatchKeyValue(entity, "radius", value);
	if (!UseTheForceLuke) DispatchKeyValueFloat(entity, "magnitude", Force * -1.0);
	else DispatchKeyValueFloat(entity, "magnitude", Force);
	DispatchKeyValue(entity, "spawnflags", "8");
	AcceptEntityInput(entity, "Enable");
	return entity;
}

stock bool GetActiveSpecialAmmoType(int client, int effect) {

	char EffectT[4];
	Format(EffectT, sizeof(EffectT), "%c", effect);
	char TheAmmoEffect[10];
	GetSpecialAmmoEffect(TheAmmoEffect, sizeof(TheAmmoEffect), client, ActiveSpecialAmmo[client]);

	if (StrContains(TheAmmoEffect, EffectT, true) != -1) return true;
	return false;
}

/*

	Checks whether a player is within range of a special ammo, and if they are, how affected they are.
	GetStatusOnly is so we know whether to start the revive bar for revive ammo, without triggering the actual effect, we just want to know IF they're affected, for example.
	If ammoposition is >= 0 AND GetStatus is enabled, it will return only for the ammo in question.
*/

stock float IsClientInRangeSpecialAmmo(int client, char[] EffectT, bool GetStatusOnly=true, int AmmoPosition=-1, float baseeffectvalue=0.0, int realowner=0) {
	float EntityPos[3];
	char TalentInfo[4][512];
	static int owner = 0;
	static int pos = -1;
	//decl String:newvalue[10];

	char value[10];
	//new Float:f_Strength = 0.0;
	//decl String:t_effect[4];

	float EffectStrength = 0.0;
	float EffectStrengthBonus = 0.0;
	bool IsInfected = false;
	bool IsSameteam = false;

	float ClientPos[3];
	bool clientIsLegitimate = IsLegitimateClient(client);
	//decl String:EffectT[4];
	if (!clientIsLegitimate || !IsPlayerAlive(client)) return EffectStrength;
	if (clientIsLegitimate) GetClientAbsOrigin(client, ClientPos);
	else {
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", ClientPos);
		IsInfected = true;
	}
	int experienceAwardType = (StrEqual(EffectT, "H", true)) ? 1 : (StrEqual(EffectT, "d", true) ||
							StrEqual(EffectT, "D", true) ||
							StrEqual(EffectT, "R", true) ||
							StrEqual(EffectT, "E", true) ||
							StrEqual(EffectT, "W", true) ||
							StrEqual(EffectT, "a", true)) ? 2 : 0;
	int otherExperienceAwardType = (StrEqual(EffectT, "F", true) || StrEqual(EffectT, "W", true) || StrEqual(EffectT, "x", true)) ? 1 :	(StrEqual(EffectT, "F", true) || StrEqual(EffectT, "x", true)) ? 2 : 0;

	float EffectStrengthValue = 0.0;
	float EffectMultiplierValue = 0.0;

	float t_Range	= 0.0;
	static int baseeffectbonus = 0;

	if (SpecialAmmoData.Length < 1) return 0.0;
	//new Float:fAmmoRangeTalentBonus = GetAbilityStrengthByTrigger(client, client, "aamRNG", FindZombieClass(client), 0, _, _, "d", 1, true);	// true at the end makes sure we don't actually fire off the ability or really check the "d" (resulteffects) here
	//if (fAmmoRangeTalentBonus < 1.0) fAmmoRangeTalentBonus = 1.0;

	//Format(EffectT, sizeof(EffectT), "%c", effect);
	for (int i = AmmoPosition; i < SpecialAmmoData.Length; i++) {
		if (i < 0) i = 0;
		if (AmmoPosition != -1 && i != AmmoPosition) continue;
		EntityPos[0] = SpecialAmmoData.Get(i, 0);
		EntityPos[1] = SpecialAmmoData.Get(i, 1);
		EntityPos[2] = SpecialAmmoData.Get(i, 2);

		// TalentInfo[0] = TalentName of ammo.
		// TalentInfo[1] = Talent Strength (so use StringToInt)
		// TalentInfo[2] = Talent Damage
		// TalentInfo[3] = Talent Interval
		owner = FindClientByIdNumber(SpecialAmmoData.Get(i, 7));
		if (!IsLegitimateClientAlive(owner) || SpecialAmmoData.Get(i, 6) <= 0.0) continue;
		pos			= SpecialAmmoData.Get(i, 3);
		GetTalentNameAtMenuPosition(client, pos, TalentInfo[0], sizeof(TalentInfo[]));
		if (IsPvP[owner] != 0 && client != owner) continue;
		t_Range		= GetSpecialAmmoStrength(owner, TalentInfo[0], 3);

		if (GetVectorDistance(ClientPos, EntityPos) > (t_Range / 2)) continue;


		
		//IsClientInRangeSAKeys[owner]				= a_Menu_Talents.Get(pos, 0);
		IsClientInRangeSAValues[owner]				= a_Menu_Talents.Get(pos, 1);
		IsClientInRangeSAValues[owner].GetString(SPELL_AMMO_EFFECT, value, sizeof(value));
		if (!StrEqual(value, EffectT, true)) continue;
		if (GetStatusOnly) {
			return -2.0;		// -2.0 is a special designation.
		}

		if (realowner == 0 || realowner == owner) {

			EffectStrengthValue = GetKeyValueFloatAtPos(IsClientInRangeSAValues[owner], SPECIAL_AMMO_TALENT_STRENGTH);
			EffectMultiplierValue = GetKeyValueFloatAtPos(IsClientInRangeSAValues[owner], SPELL_EFFECT_MULTIPLIER);

			if (EffectStrengthBonus == 0.0) {

				EffectStrength += EffectStrengthValue;
				EffectStrengthBonus = EffectMultiplierValue;
			}
			else {

				EffectStrength += (EffectStrengthValue * EffectStrengthBonus);
				EffectStrengthBonus *= EffectMultiplierValue;
			}

			if (baseeffectvalue > 0.0 && owner != client) {

				/*

					Award the user who has buffed a player.
				*/

				if (!IsInfected && GetClientTeam(client) == GetClientTeam(owner)) IsSameteam = true;





				baseeffectbonus = RoundToCeil(baseeffectvalue + (baseeffectvalue * EffectStrengthValue));
				baseeffectbonus += RoundToCeil(baseeffectbonus * SurvivorExperienceMult);
				if (baseeffectbonus > 0) {

					if (IsSameteam) {
						if (experienceAwardType > 0) AwardExperience(owner, experienceAwardType, baseeffectbonus);
						/*if (StrEqual(EffectT, "H", true)) AwardExperience(owner, 1, baseeffectbonus);
						if (StrEqual(EffectT, "d", true) ||
							StrEqual(EffectT, "D", true) ||
							StrEqual(EffectT, "R", true) ||
							StrEqual(EffectT, "E", true) ||
							StrEqual(EffectT, "W", true) ||
							StrEqual(EffectT, "a", true)) AwardExperience(owner, 2, baseeffectbonus);*/
					}
					else {

						if (otherExperienceAwardType == 1 && clientIsLegitimate ||
							otherExperienceAwardType == 2 && IsInfected) AwardExperience(owner, 3, baseeffectbonus);
					}
				}
			}
		}
		if (AmmoPosition != -1) break;
	}
	return EffectStrength;
}

public Action Timer_AmmoTriggerCooldown(Handle timer, any client) {

	if (IsLegitimateClient(client)) AmmoTriggerCooldown[client] = false;
	return Plugin_Stop;
}

stock void AdvertiseAction(int client, char[] TalentName, bool isSpell = false) {

	char TalentName_Temp[64];
	char Name[64];
	char text[64];

	GetTranslationOfTalentName(client, TalentName, text, sizeof(text), _, true);
	if (StrEqual(text, "-1")) GetTranslationOfTalentName(client, TalentName, text, sizeof(text), true);

	GetClientName(client, Name, sizeof(Name));



	for (int i = 1; i <= MaxClients; i++) {

		if (!IsLegitimateClient(i) || IsFakeClient(i)) continue;

		Format(TalentName_Temp, sizeof(TalentName_Temp), "%T", text, i);
		if (isSpell) PrintToChat(i, "%T", "player uses spell", i, blue, Name, orange, green, TalentName_Temp, orange);
		else PrintToChat(i, "%T", "player uses ability", i, blue, Name, orange, green, TalentName_Temp, orange);
	}
}

stock float GetSpellCooldown(int client, char[] TalentName) {

	float SpellCooldown = GetAbilityValue(client, TalentName, ABILITY_COOLDOWN);
	if (SpellCooldown == -1.0) return 0.0;
	float TheAbilityMultiplier = GetAbilityMultiplier(client, "L", -1);

	if (TheAbilityMultiplier != -1.0) {

		if (TheAbilityMultiplier < 0.0) TheAbilityMultiplier = 0.1;
		else if (TheAbilityMultiplier > 0.0) { //cooldowns are reduced

			SpellCooldown -= (SpellCooldown * TheAbilityMultiplier);
			if (SpellCooldown < 0.0) SpellCooldown = 0.0;
		}
	}
	return SpellCooldown;
}

stock bool UseAbility(int client, int target = -1, char[] TalentName, Handle Keys, Handle Values, float TargetPos[3]) {

	if (!b_IsActiveRound || GetAmmoCooldownTime(client, TalentName, true) != -1.0 || IsAbilityActive(client, TalentName)) return false;
	if (IsLegitimateClientAlive(target)) GetClientAbsOrigin(target, TargetPos);

	float TheAbilityMultiplier = 0.0;
	int myAttacker = L4D2_GetInfectedAttacker(client);
	if (GetKeyValueIntAtPos(Values, ABILITY_REQ_NO_ENSNARE) == 1 && myAttacker != -1) return false;

	float ClientPos[3];
	GetClientAbsOrigin(client, ClientPos);

	int MySecondary = GetPlayerWeaponSlot(client, 1);
	char MyWeapon[64];

	char Effects[64];
	float SpellCooldown = GetSpellCooldown(client, TalentName);

	//new MyAttacker = L4D2_GetInfectedAttacker(client);
	int MyStamina = GetPlayerStamina(client);
	int MyBonus = 0;
	//new MyMaxHealth = GetMaximumHealth(client);
	int iSkyLevelRequirement = GetKeyValueIntAtPos(Values, ABILITY_SKY_LEVEL_REQ);
	if (iSkyLevelRequirement < 0) iSkyLevelRequirement = 0;

	if (SkyLevel[client] < iSkyLevelRequirement) return false;
	Values.GetString(ABILITY_TOGGLE_EFFECT, Effects, sizeof(Effects));
	if (StrEqual(Effects, "stagger", true)) {
		if (myAttacker == -1) return false;	// knife cannot trigger if you are not a victim.
		ReleasePlayer(client);
		//EmitSoundToClient(client, "player/heartbeatloop.wav");
		//StopSound(client, SNDCHAN_AUTO, "player/heartbeatloop.wav");
	}
	else if (StrEqual(Effects, "r", true)) {

		if (!IsPlayerAlive(client) && b_HasDeathLocation[client]) {

			RespawnImmunity[client] = true;
			MyRespawnTarget[client] = -1;
			SDKCall(hRoundRespawn, client);
			CreateTimer(0.1, Timer_TeleportRespawn, client, TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(0.1, Timer_GiveMaximumHealth, client, TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(3.0, Timer_ImmunityExpiration, client, TIMER_FLAG_NO_MAPCHANGE);
		}
		else return false;
	}
	else if (StrEqual(Effects, "P", true)) {
		// Toggles between pistol / magnum
		if (IsValidEntity(MySecondary)) {
			GetEntityClassname(MySecondary, MyWeapon, sizeof(MyWeapon));
			RemovePlayerItem(client, MySecondary);
			AcceptEntityInput(MySecondary, "Kill");
		}
		if (StrContains(MyWeapon, "magnum", false) == -1 && StrContains(MyWeapon, "pistol", false) != -1) {

			// give them a magnum.
			ExecCheatCommand(client, "give", "pistol_magnum");
		}
		else {

			// make them dual wield.
			ExecCheatCommand(client, "give", "pistol");
			CreateTimer(0.5, Timer_GiveSecondPistol, client, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	else if (StrEqual(Effects, "T", true)) {
		GetClientStance(client, GetAmmoCooldownTime(client, TalentName, true));
	}
	/*if (StrContains(Effects, "S", true) != -1) {
		StaggerPlayer(client, client);
	}*/
	Values.GetString(ABILITY_ACTIVE_EFFECT, Effects, sizeof(Effects));
	if (!StrEqual(Effects, "-1")) {

		//if (AbilityTime > 0.0) IsAbilityActive(client, TalentName, AbilityTime);
		//We check active time another way now

		if (StrEqual(Effects, "A", true)) { // restores stamina

			TheAbilityMultiplier = GetAbilityMultiplier(client, "A", 1);
			MyBonus = RoundToCeil(MyStamina * TheAbilityMultiplier);
			if (SurvivorStamina[client] + MyBonus > MyStamina) {

				SurvivorStamina[client] = MyStamina;
			}
			else SurvivorStamina[client] += MyBonus;
		}
		if (StrEqual(Effects, "H", true)) {	// heals the individual

			TheAbilityMultiplier = GetAbilityMultiplier(client, "H", 1);
			HealPlayer(client, client, TheAbilityMultiplier, 'h');
		}
		if (StrEqual(Effects, "t", true)) {	// instantly lowers threat by a percentage

			TheAbilityMultiplier = GetAbilityMultiplier(client, "t", 1);
			iThreatLevel[client] -= RoundToFloor(iThreatLevel[client] * TheAbilityMultiplier);
		}
	}

	//if (menupos >= 0) CheckActiveAbility(client, menupos, _, _, true, true);
	//AdvertiseAction(client, TalentName, false);
	//IsAmmoActive(client, TalentName, SpellCooldown, true);

	// We do this AFTER we've activated the talent.
	if (GetKeyValueIntAtPos(Values, ABILITY_IS_REACTIVE) == 2) {	// instant, one-time-use abilities that have a cast-bar and then fire immediately.
		if (GetAbilityMultiplier(client, Effects, 5) == -2.0) {
			int reactiveType = GetKeyValueIntAtPos(Values, ABILITY_REACTIVE_TYPE);
			if (reactiveType == 1) StaggerPlayer(client, GetAnyPlayerNotMe(client));
			else if (reactiveType == 2) {
				float fActiveTime = GetKeyValueFloatAtPos(Values, ABILITY_ACTIVE_TIME);
				CreateProgressBar(client, fActiveTime);
				Handle datapack;
				CreateDataTimer(fActiveTime, Timer_ReactiveCast, datapack, TIMER_FLAG_NO_MAPCHANGE);
				datapack.WriteCell(client);
				datapack.WriteCell(RoundToCeil(GetMaximumHealth(client) * GetKeyValueFloatAtPos(Values, ABILITY_ACTIVE_STRENGTH)));
			}
			AdvertiseAction(client, TalentName, false);
			IsAmmoActive(client, TalentName, SpellCooldown, true);
		}
	}
	else {
		AdvertiseAction(client, TalentName, false);
		IsAmmoActive(client, TalentName, SpellCooldown, true);
	}

	return true;
}

public Action Timer_ReactiveCast(Handle timer, Handle datapack) {
	datapack.Reset();
	int client = datapack.ReadCell();
	if (IsLegitimateClient(client)) {
		int amount = datapack.ReadCell();
		CreateFireEx(client);
		DoBurn(client, client, amount);

		// we also do this burn damage to all supers, witches, and specials in range of the fire.
		// because molotov is a set size, trying to match that here.
		float cpos[3];
		GetClientAbsOrigin(client, cpos);
		float tpos[3];
		// specials
		for (int target = 1; target <= MaxClients; target++) {
			if (!IsLegitimateClient(target) || GetClientTeam(target) != TEAM_INFECTED) continue;
			GetClientAbsOrigin(target, tpos);
			if (GetVectorDistance(cpos, tpos) > 256.0) continue;
			DoBurn(target, client, amount);
		}
		// supers
		int common;
		/*for (new target = 0; target < CommonInfected.Length; target++) {
			common = CommonInfected.Get(target);
			if (!IsSpecialCommon(common)) continue;
			GetEntPropVector(common, Prop_Send, "m_vecOrigin", tpos);
			if (GetVectorDistance(cpos, tpos) > 256.0) continue;
			DoBurn(common, client, amount);
		}*/
		// witches
		for (int target = 0; target < WitchList.Length; target++) {
			common = WitchList.Get(target);
			if (!IsWitch(common)) continue;
			GetEntPropVector(common, Prop_Send, "m_vecOrigin", tpos);
			if (GetVectorDistance(cpos, tpos) > 256.0) continue;
			DoBurn(common, client, amount);
		}
	}
	return Plugin_Stop;
}

public Action Timer_GiveSecondPistol(Handle timer, any client) {

	if (IsLegitimateClientAlive(client)) {

		ExecCheatCommand(client, "give", "pistol");
	}
	return Plugin_Stop;
}

/* returns the # of unlocks a player will receive for the next prestige
   Put this here because we're going to use this to verify # of player upgrades.
*/
stock int GetPrestigeLevelNodeUnlocks(int level) {
	if (iSkyLevelNodeUnlocks > 0) return iSkyLevelNodeUnlocks;
	return level;
}

stock bool CastSpell(int client, int target = -1, char[] TalentName, float TargetPos[3], float visualDelayTime = 1.0) {

	if (!b_IsActiveRound || !IsLegitimateClientAlive(client) || L4D2_GetInfectedAttacker(client) != -1 || GetAmmoCooldownTime(client, TalentName) != -1.0) return false;
	if (IsSpellAnAura(client, TalentName)) {
		GetClientAbsOrigin(client, TargetPos);
		target = client;
	}
	else if (IsLegitimateClientAlive(target)) GetClientAbsOrigin(target, TargetPos);	// if the target is -1 / not alive, TargetPos will have been sent through.

	if (bIsSurvivorFatigue[client]) return false;

	int StaminaCost = RoundToCeil(GetSpecialAmmoStrength(client, TalentName, 2));
 	if (SurvivorStamina[client] < StaminaCost) return false;
 	SurvivorStamina[client] -= StaminaCost;
	if (SurvivorStamina[client] <= 0) {

		bIsSurvivorFatigue[client] = true;
		IsSpecialAmmoEnabled[client][0] = 0.0;
	}

	//IsAbilityActive(client, TalentName, AbilityTime);

	AdvertiseAction(client, TalentName, true);

	//new Float:SpellCooldown = GetSpecialAmmoStrength(client, TalentName, 1);
	//IsAmmoActive(client, TalentName, SpellCooldown);	// place it on cooldown for the lifetime (not the interval, even if it's greater)

	char key[64];
	GetClientAuthId(client, AuthId_Steam2, key, sizeof(key));
	int ClientMenuPosition = GetMenuPosition(client, TalentName);

	float f_TotalTime = GetSpecialAmmoStrength(client, TalentName);
	float SpellCooldown = f_TotalTime + GetSpecialAmmoStrength(client, TalentName, 1);
	
	// It's going to be a headache re-structuring this, so i am doing it in a sequence. to make it easier interval will just clone totaltime for now.
	float f_Interval = f_TotalTime; //GetSpecialAmmoStrength(client, TalentName, 4);
	if (IsSpellAnAura(client, TalentName)) f_Interval = fSpecialAmmoInterval;	// Auras follow players and re-draw on every tick.

	//if (f_Interval > f_TotalTime) f_Interval = f_TotalTime;
	IsAmmoActive(client, TalentName, SpellCooldown);

	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && !IsFakeClient(i)) DrawSpecialAmmoTarget(i, _, _, ClientMenuPosition, TargetPos[0], TargetPos[1], TargetPos[2], f_Interval, client, TalentName, target);
	}

	int bulletStrength = RoundToCeil(GetBaseWeaponDamage(client, target, TargetPos[0], TargetPos[1], TargetPos[2], DMG_BULLET) * 0.1);
	bulletStrength = RoundToCeil(GetAbilityStrengthByTrigger(client, -2, "D", _, bulletStrength, _, _, "D", 1, true, _, _, _, DMG_BULLET));
	float amSTR = GetSpecialAmmoStrength(client, TalentName, 5);
	if (amSTR > 0.0) bulletStrength = RoundToCeil(bulletStrength * amSTR);
	//decl String:SpecialAmmoData_s[512];
	//Format(SpecialAmmoData_s, sizeof(SpecialAmmoData_s), "%3.3f %3.3f %3.3f}%s{%d{%d{%3.2f}%s}%3.2f}%d}%3.2f}%d", TargetPos[0], TargetPos[1], TargetPos[2], TalentName, GetTalentStrength(client, TalentName), GetBaseWeaponDamage(client, -1, TargetPos[0], TargetPos[1], TargetPos[2], DMG_BULLET), f_Interval, key, SpellCooldown, -1, GetSpecialAmmoStrength(client, TalentName, 1), target);
	//Format(SpecialAmmoData_s, sizeof(SpecialAmmoData_s), "%3.3f %3.3f %3.3f}%s{%d{%d{%3.2f}%s}%3.2f}%d}%3.2f}%d", TargetPos[0], TargetPos[1], TargetPos[2], TalentName, GetTalentStrength(client, TalentName), bulletStrength, f_Interval, key, f_TotalTime, -1, GetSpecialAmmoStrength(client, TalentName, 1), target);
												//13908.302 2585.922 32.133}adren ammo{1{20{15.00}STEAM_1:1:440606022}15.00}-1}30.00}-1
	//PrintToChatAll("%d", StringToInt(key[10]));
	int sadsize = SpecialAmmoData.Length;

	SpecialAmmoData.Resize(sadsize + 1);
	SpecialAmmoData.Set(sadsize, TargetPos[0], 0);
	SpecialAmmoData.Set(sadsize, TargetPos[1], 1);
	SpecialAmmoData.Set(sadsize, TargetPos[2], 2);
	SpecialAmmoData.Set(sadsize, ClientMenuPosition, 3); //GetTalentNameAtMenuPosition(client, pos, String:TheString, stringSize) instead of storing TalentName
	SpecialAmmoData.Set(sadsize, GetTalentStrength(client, TalentName), 4);
	SpecialAmmoData.Set(sadsize, bulletStrength, 5);
	SpecialAmmoData.Set(sadsize, f_Interval, 6);
	// only captures the #ID: STEAM_0:1:<--cuts off the front, only stores the numbers: 440606022 - is faster than parsing a string every time.
	SpecialAmmoData.Set(sadsize, StringToInt(key[10]), 7);
	SpecialAmmoData.Set(sadsize, f_TotalTime, 8);
	SpecialAmmoData.Set(sadsize, -1, 9);
	SpecialAmmoData.Set(sadsize, GetSpecialAmmoStrength(client, TalentName, 1), 10);	// float.
	SpecialAmmoData.Set(sadsize, target, 11);
	SpecialAmmoData.Set(sadsize, visualDelayTime, 12);	// original value must be stored.
	SpecialAmmoData.Set(sadsize, visualDelayTime, 13);



	//Handle:SpecialAmmoData.PushString(SpecialAmmoData_s);
	return true;
}

stock void DoBurn(int attacker, int victim, float baseWeaponDamage) {
	//if (iTankRush == 1 && FindZombieClass(victim) == ZOMBIECLASS_TANK) return;
	bool IsLegitimateClientVictim = IsLegitimateClientAlive(victim);
	if (IsLegitimateClientVictim) {
		bIsBurnCooldown[victim] = true;
		CreateTimer(1.0, Timer_ResetBurnImmunity, victim, TIMER_FLAG_NO_MAPCHANGE);
	}
 	int hAttacker = attacker;
 	if (!IsLegitimateClient(hAttacker)) hAttacker = -1;
	bool IsCommonInfectedVictim = IsCommonInfected(victim);
 	if (IsCommonInfectedVictim || IsWitch(victim) && !(GetEntityFlags(victim) & FL_ONFIRE)) {
		if (IsCommonInfectedVictim) {
			if (!IsSpecialCommon(victim)) OnCommonInfectedCreated(victim, true);
			else AddSpecialCommonDamage(attacker, victim, baseWeaponDamage, true);
		}
		else {
			IgniteEntity(victim, 10.0);
			AddWitchDamage(attacker, victim, baseWeaponDamage, true);
		}
	}
 	if (IsLegitimateClientVictim && GetClientStatusEffect(victim, "burn") < iDebuffLimit) {
		if (ISEXPLODE[victim] == INVALID_HANDLE) CreateAndAttachFlame(victim, RoundToCeil(baseWeaponDamage * TheInfernoMult), 10.0, 0.5, hAttacker, "burn");
		else CreateAndAttachFlame(victim, RoundToCeil((baseWeaponDamage * TheInfernoMult) * TheScorchMult), 10.0, 0.5, hAttacker, "burn");
 	}
}

stock void BeanBagAmmo(int client, float force, int TalentClient) {
	if (!IsCommonInfected(client) && !IsLegitimateClientAlive(client)) return;
	if (!IsLegitimateClientAlive(TalentClient)) return;
	float Velocity[3];
	Velocity[0]	=	GetEntPropFloat(TalentClient, Prop_Send, "m_vecVelocity[0]");
	Velocity[1]	=	GetEntPropFloat(TalentClient, Prop_Send, "m_vecVelocity[1]");
	Velocity[2]	=	GetEntPropFloat(TalentClient, Prop_Send, "m_vecVelocity[2]");
	float Vec_Pull;
	float Vec_Lunge;
	/*if (client != TalentClient) {

		//new CartXP = RoundToCeil(GetClassMultiplier(TalentClient, force, "enX", true));
		//AddTalentExperience(TalentClient, "endurance", RoundToCeil(force));
	}*/
	Vec_Pull	=	GetRandomFloat(force * -1.0, force);
	Vec_Lunge	=	GetRandomFloat(force * -1.0, force);
	Velocity[2]	+=	force;
	if (Vec_Pull < 0.0 && Velocity[0] > 0.0) Velocity[0] *= -1.0;
	Velocity[0] += Vec_Pull;
	if (Vec_Lunge < 0.0 && Velocity[1] > 0.0) Velocity[1] *= -1.0;
	Velocity[1] += Vec_Lunge;
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, Velocity);
}

/*

	When a client who has special ammo enabled has an eligible target highlighted, we want to draw an aura around that target (just for the client)
	This aura will cycle appropriately as a player cycles their active ammo.

	I have consciously made the decision (ahead of time, having this foresight) to design it so special ammos cannot be used on self. If a client
	wants to use a defensive ammo, for example, on themselves, they would need to shoot an applicable target (enemy, teammate, vehicle... lol) and then step
	into the range.
*/

// no one sees my special ammo because it should be drawing it based on MY size not theirs but it's drawing it based on theirs and if they have zero points in the talent then they can't see it.
stock int DrawSpecialAmmoTarget(int TargetClient, bool IsDebugMode=false, bool IsValidTarget=false, int CurrentPosEx=-1, float PosX=0.0, float PosY=0.0, float PosZ=0.0, float f_ActiveTime=0.0, int owner=0, char[] TalentName="none", int Target = -1) {		// If we aren't actually drawing..? Stoned idea lost in thought but expanded somewhat not on the original path
	int client = TargetClient;
	if (owner != 0) client = owner;
	if (iRPGMode <= 0) return -1;
	int CurrentPos	= GetMenuPosition(client, TalentName);
	bool i_IsDebugMode = false;
	DrawSpecialAmmoValues[client]	= a_Menu_Talents.Get(CurrentPos, 1);
	if (CurrentPosEx == -1) {
		bool IsTargetCommonInfected = IsCommonInfected(Target);
		bool IsLegitimateClientTarget = IsLegitimateClientAlive(Target);
		int targetTeam = -1;
		if (IsLegitimateClientTarget) targetTeam = GetClientTeam(Target);
		if (GetKeyValueIntAtPos(DrawSpecialAmmoValues[client], SPELL_HUMANOID_ONLY) == 1) {
			//Humanoid Only could apply to a wide-range so we break it down here.
			if (!IsTargetCommonInfected && !IsLegitimateClientTarget) i_IsDebugMode = true;
		}
		if (GetKeyValueIntAtPos(DrawSpecialAmmoValues[client], SPELL_INANIMATE_ONLY) == 1) {
			//This is things like vehicles, dumpsters, and other objects that can one-shot your teammates.
			if (IsTargetCommonInfected || IsLegitimateClientTarget) i_IsDebugMode = true;
		}
		if (GetKeyValueIntAtPos(DrawSpecialAmmoValues[client], SPELL_ALLOW_COMMONS) == 0 && IsTargetCommonInfected ||
		GetKeyValueIntAtPos(DrawSpecialAmmoValues[client], SPELL_ALLOW_SPECIALS) == 0 && IsLegitimateClientTarget && targetTeam == TEAM_INFECTED ||
		GetKeyValueIntAtPos(DrawSpecialAmmoValues[client], SPELL_ALLOW_SURVIVORS) == 0 && IsLegitimateClientTarget && targetTeam == TEAM_SURVIVOR) {
			i_IsDebugMode = true;
		}
		if (i_IsDebugMode && !IsDebugMode) return 0;		// ie if an invalid target is highlighted and debug mode is disabled we don't draw and we don't tell the player anything.
		if (IsValidTarget) {
			if (i_IsDebugMode) return 0;
			else return 1;
		}
	}
	float AfxRange			= GetSpecialAmmoStrength(client, TalentName, 3);
	float AfxRangeBonus = GetAbilityStrengthByTrigger(client, TargetClient, "aamRNG", _, 0, _, _, "d", 1, true);
	if (AfxRangeBonus > 0.0) AfxRangeBonus *= (1.0 + AfxRangeBonus);
	float HighlightTime = fAmmoHighlightTime;
	char AfxDrawPos[64];
	char AfxDrawColour[64];
	int drawpos = TALENT_FIRST_RANDOM_KEY_POSITION;
	int drawcolor = TALENT_FIRST_RANDOM_KEY_POSITION;
	DrawSpecialAmmoKeys[client]		= a_Menu_Talents.Get(CurrentPos, 0);
	while (drawpos >= 0 && drawcolor >= 0) {
		drawpos = FormatKeyValue(AfxDrawPos, sizeof(AfxDrawPos), DrawSpecialAmmoKeys[client], DrawSpecialAmmoValues[client], "draw pos?", _, _, drawpos, false);
		drawcolor = FormatKeyValue(AfxDrawColour, sizeof(AfxDrawColour), DrawSpecialAmmoKeys[client], DrawSpecialAmmoValues[client], "draw colour?", _, _, drawcolor, false);
		if (drawpos < 0 || drawcolor < 0) return -1;
		//if (StrEqual(AfxDrawColour, "-1", false)) return -1;		// if there's no colour, we return otherwise you'll get errors like this: TE_Send Exception reported: No TempEntity call is in progress (return 0 here would cause endless loop set to -1 as it is ignored i broke the golden rule lul)
		if (CurrentPosEx != -1) {
			CreateRingSoloEx(-1, AfxRange, AfxDrawColour, AfxDrawPos, false, f_ActiveTime, TargetClient, PosX, PosY, PosZ);
		}
		else {

			CreateRingSoloEx(Target, AfxRange, AfxDrawColour, AfxDrawPos, false, HighlightTime, TargetClient);
			IsSpecialAmmoEnabled[client][3] = Target * 1.0;
		}
		drawpos++;
		drawcolor++;
	}
	return 2;
}

/*

	We need to get the talent name of the active special ammo.
	This way when an ammo activate triggers it only goes through if that ammo is the type the player currently has selected.
*/
stock bool GetActiveSpecialAmmo(int client, char[] TalentName) {

	if (!StrEqual(TalentName, ActiveSpecialAmmo[client], false)) return false;
	// So if the talent is the one equipped...
	return true;
}

stock void CreateProgressBar(int client, float TheTime, bool NahDestroyItInstead=false, bool NoAdrenaline=false) {

	if (TheTime >= 1.0) {

		float fActionTimeToReduce = GetAbilityStrengthByTrigger(client, client, "progbarspeed", _, 0, _, _, _, 1, true);
		if (fActionTimeToReduce > 0.0) TheTime *= (1.0 - fActionTimeToReduce);
	}

	SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
	if (NahDestroyItInstead) SetEntPropFloat(client, Prop_Send, "m_flProgressBarDuration", 0.0);
	else {

		float TheRealTime = TheTime;
		if (!NoAdrenaline && HasAdrenaline(client)) TheRealTime *= fAdrenProgressMult;

		SetEntPropFloat(client, Prop_Send, "m_flProgressBarDuration", TheRealTime);
		UseItemTime[client] = TheRealTime + GetEngineTime();
	}
}

stock void AdjustProgressBar(int client, float TheTime) { SetEntPropFloat(client, Prop_Send, "m_flProgressBarDuration", TheTime); }

stock bool ActiveProgressBar(int client) {

	if (GetEntPropFloat(client, Prop_Send, "m_flProgressBarDuration") <= 0.0) return false;
	return true;
}

public Action Timer_ImmunityExpiration(Handle timer, any client) {

	if (IsLegitimateClient(client)) RespawnImmunity[client] = false;
	return Plugin_Stop;
}

stock void Defibrillator(int client, int target = 0, bool IgnoreDistance = false) {

	if (target > 0 && IsLegitimateClientAlive(target)) return;


	// respawn people near the player.
	int respawntarget = 0;
	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClientAlive(i) && GetClientTeam(i) == TEAM_SURVIVOR) {

			respawntarget = i;
			break;
		}
	}
	float Origin[3];
	if (client > 0) GetClientAbsOrigin(client, Origin);

	// target defaults to 0.
	for (int i = target; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && !IsPlayerAlive(i) && GetClientTeam(i) == TEAM_SURVIVOR && (i != client || target == 0) && i != target) {

			if (target > 0 && i != target) continue;

			if (target == 0 && b_HasDeathLocation[i] && (IgnoreDistance || GetVectorDistance(Origin, DeathLocation[i]) < 256.0)) {

				PrintToChatAll("%t", "rise again", white, orange, white);
				RespawnImmunity[i] = true;
				MyRespawnTarget[i] = i;
				SDKCall(hRoundRespawn, i);
				CreateTimer(0.1, Timer_TeleportRespawn, i, TIMER_FLAG_NO_MAPCHANGE);
				CreateTimer(3.0, Timer_ImmunityExpiration, i, TIMER_FLAG_NO_MAPCHANGE);
			}
			else if (target == 0 && !b_HasDeathLocation[i] && IsLegitimateClientAlive(respawntarget)) {

				SDKCall(hRoundRespawn, i);
				RespawnImmunity[i] = true;
				MyRespawnTarget[i] = respawntarget;
				CreateTimer(0.1, Timer_TeleportRespawn, i, TIMER_FLAG_NO_MAPCHANGE);
				CreateTimer(3.0, Timer_ImmunityExpiration, i, TIMER_FLAG_NO_MAPCHANGE);
			}
			//SDKCall(hRoundRespawn, i);
			//if (client > 0) LastDeathTime[i] = GetEngineTime() + StringToFloat(GetConfigValue("death weakness time?"));
			//b_HasDeathLocation[i] = false;
		}
	}
}

/*public Action:Timer_BeaconCorpses(Handle:timer) {

	new CurrentEntity			=	-1;
	decl String:EntityName[64];
	if (!b_IsActiveRound) return Plugin_Stop;

	for (new i = 1; i <= MaxClients; i++) {

		if (!IsLegitimateClientAlive(i) || IsFakeClient(i) || GetClientTeam(i) != TEAM_SURVIVOR || IsIncapacitated(i)) continue;

		BeaconCorpsesCounter[i] += 0.01;
		if (BeaconCorpsesCounter[i] < 0.25) continue;

		CurrentEntity										= GetEntPropEnt(i, Prop_Data, "m_hActiveWeapon");
		if (IsValidEntity(CurrentEntity)) GetEdictClassname(CurrentEntity, EntityName, sizeof(EntityName));
		if (StrContains(EntityName, "defib", false) == -1) continue;

		BeaconCorpsesCounter[i] = 0.0;
		BeaconCorpsesInRange(i);
	}
	return Plugin_Continue;
}*/

// Eyal282 here, loc is unknown and throws errors.
/*
stock void InventoryItem(int client, char[] EntityName = "none", bool bIsPickup = false, int entity = -1) {

	char ItemName[64];

	int ExplodeCount = GetDelimiterCount(EntityName, ":");
	char[][] Classname = new char[ExplodeCount][64];
	ExplodeString(EntityName, ":", Classname, ExplodeCount, 64);

	if (bIsPickup) {	// Picking up the entity. We store it in the users inventory.

		GetEntityClassname(entity, Classname[0], sizeof(Classname[]));
		GetEntPropString(entity, Prop_Data, "m_iName", ItemName, sizeof(ItemName));
	}
	else {		// Creating the entity. Defaults to -1

		entity	= CreateEntityByName(Classname[0]);
		DispatchKeyValue(entity, "targetname", Classname[1]);
		DispatchKeyValue(entity, "rendermode", "5");
		DispatchKeyValue(entity, "spawnflags", "0");
		DispatchSpawn(entity);
		TeleportEntity(entity, loc, NULL_VECTOR, NULL_VECTOR);
	}
}
*/
stock bool IsCommonStaggered(int client) {
	//decl String:clientId[2][64];
	//decl String:text[64];
	//Float:timeRemaining = 0.0;
	for (int i = 0; i < StaggeredTargets.Length; i++) {
		//StaggeredTargets.GetString(i, text, sizeof(text));
		//ExplodeString(text, ":", clientId, 2, 64);
		if (StaggeredTargets.Get(i, 0) == client) return true;
		//if (StringToInt(clientId[0]) == client) return true;
	}
	return false;
}

public Action Timer_StaggerTimer(Handle timer) {
	//decl String:clientId[2][64];
	//decl String:text[64];
	if (!b_IsActiveRound) {
		StaggeredTargets.Clear();
		return Plugin_Stop;
	}
	float timeRemaining = 0.0;
	for (int i = 0; i < StaggeredTargets.Length; i++) {
		//StaggeredTargets.GetString(i, text, sizeof(text));
		//ExplodeString(text, ":", clientId, 2, 64);
		//timeRemaining = StringToFloat(clientId[1]);
		timeRemaining = StaggeredTargets.Get(i, 1);
		if (timeRemaining <= fStaggerTickrate) StaggeredTargets.Erase(i);
		else {
			StaggeredTargets.Set(i, timeRemaining - fStaggerTickrate, 1);
			//Format(text, sizeof(text), "%s:%3.3f", clientId[0], timeRemaining - fStaggerTickrate);
			//StaggeredTargets.SetString(i, text);
		}
	}
	return Plugin_Continue;
}

stock void EntityWasStaggered(int victim, int attacker = 0) {
	if (attacker != 0 && IsLegitimateClient(attacker) && (!IsLegitimateClient(victim) || GetClientTeam(victim) != GetClientTeam(attacker))) GetAbilityStrengthByTrigger(attacker, victim, "didStagger");
	if (victim != 0 && IsLegitimateClient(victim) && (!IsLegitimateClient(attacker) || GetClientTeam(attacker) != GetClientTeam(victim))) GetAbilityStrengthByTrigger(victim, attacker, "wasStagger");
}

public Action Timer_ResetStaggerCooldownOnTriggers(Handle timer, any client) {
	if (IsLegitimateClient(client)) staggerCooldownOnTriggers[client] = false;
	return Plugin_Stop;
}

public Action OnPlayerRunCmd(int client, int &buttons) {
	int clientFlags = -1;
	int clientTeam = -1;
	bool IsClientIncapacitated = false;
	bool IsClientAlive = false;
	if (IsLegitimateClientAlive(client)) {
		IsClientAlive = true;
		clientFlags = GetEntityFlags(client);
		clientTeam = GetClientTeam(client);
		IsClientIncapacitated = IsIncapacitated(client);
		// call the stagger ability triggers only when a fresh stagger occurs (and not if multiple staggers happen too-often within each other (2.0 seconds is slightly-longer than one stagger.))
		if (!staggerCooldownOnTriggers[client] && SDKCall(g_hIsStaggering, client)) {
			staggerCooldownOnTriggers[client] = true;
			CreateTimer(2.0, Timer_ResetStaggerCooldownOnTriggers, client, TIMER_FLAG_NO_MAPCHANGE);
			EntityWasStaggered(client);
		}
		if (clientTeam == TEAM_SURVIVOR) {
			if ((clientFlags & FL_ONFIRE) && (IsCoveredInBile(client) || clientFlags & FL_INWATER)) {
				RemoveAllDebuffs(client, "burn");
				ExtinguishEntity(client);
			}
			if ((clientFlags & FL_INWATER) && GetClientStatusEffect(client, "acid") > 0) {
				RemoveAllDebuffs(client, "acid");
			}
		}
	}
	float TheTime = GetEngineTime();
	if ((buttons & IN_ZOOM)) {
		if (ZoomcheckDelayer[client] == INVALID_HANDLE) {
			ZoomcheckDelayer[client] = CreateTimer(0.1, Timer_ZoomcheckDelayer, client, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	int MyAttacker = L4D2_GetInfectedAttacker(client);
	bool IsHoldingPrimaryFire = (buttons & IN_ATTACK) ? true : false;
	if (IsHoldingPrimaryFire) {
		int weaponEntity = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
		int bulletsRemaining = 0;
		if (IsValidEntity(weaponEntity)) {
			bulletsRemaining = GetEntProp(weaponEntity, Prop_Send, "m_iClip1");
			if (bulletsRemaining == LastBulletCheck[client]) bulletsRemaining = 0;
			else LastBulletCheck[client] = bulletsRemaining;
		}
		if (bulletsRemaining > 0 && GetEntProp(weaponEntity, Prop_Data, "m_bInReload") != 1 && MyAttacker == -1) {
			holdingFireCheckToggle(client, true);
		}
	}
	else holdingFireCheckToggle(client);

	bool isHoldingShift = (buttons & IN_SPEED) ? true : false;
	if (isHoldingShift) bIsSprinting[client] = true;
	else bIsSprinting[client] = false;
	bool isHoldingUseKey = (buttons & IN_USE) ? true : false;
	if (isHoldingUseKey && b_IsRoundIsOver) {
		if (ReadyUpGameMode == 3 || StrContains(TheCurrentMap, "zerowarn", false) != -1) {
			char EName[64];
			int entity = GetClientAimTarget(client, false);
			if (entity != -1) {
				GetEntityClassname(entity, EName, sizeof(EName));
				if (StrContains(EName, "weapon", false) != -1 || StrContains(EName, "physics", false) != -1) return Plugin_Continue;
			}
			buttons &= ~IN_USE;
			return Plugin_Changed;
		}
	}
	bool isClientOnSolidGround = (clientFlags & FL_ONGROUND) ? true : false;
	bool isClientOnFire = (clientFlags & FL_ONFIRE) ? true : false;
	bool isClientHoldingMovementKeys = false;
	if (isHoldingShift) isClientHoldingMovementKeys = (buttons & IN_FORWARD || buttons & IN_BACK || buttons & IN_MOVELEFT || buttons & IN_MOVERIGHT) ? true : false;
	if (ReadyUpGameMode == 3 && !b_IsCheckpointDoorStartOpened && IsClientAlive && clientTeam == TEAM_SURVIVOR) {
		if (isHoldingShift && isClientOnSolidGround && isClientHoldingMovementKeys) {
			MovementSpeed[client] = fSprintSpeed;
			SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", MovementSpeed[client]);
			buttons &= ~IN_SPEED;
			return Plugin_Changed;
		}
		else {
			MovementSpeed[client] = 1.0;
			SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", MovementSpeed[client]);
		}
	}

	if (IsClientAlive && b_IsActiveRound) {

		/*if (!IsFakeClient(client) && clientTeam == TEAM_SURVIVOR) {

			if (MyBirthday[client] == 0) MyBirthday[client] = GetTime();
			if (iRushingModuleEnabled == 1) {
				if (bRushingNotified[client] && IsPlayerRushing(client, 2048.0)) {

					//IncapacitateOrKill(client, _, _, true, true);
					FindRandomSurvivorClient(client, _, false);
					//bRushingNotified[client] = false;
				}
				else if (!bRushingNotified[client] && IsPlayerRushing(client, 1536.0)) {

					//FindRandomSurvivorClient(client);
					bRushingNotified[client] = true;
					PrintToChat(client, "%T", "Rushing Return To Team", client, orange, blue, orange);
				}
			}
		}*/

		if (clientTeam == TEAM_INFECTED && FindZombieClass(client) == ZOMBIECLASS_TANK) {

			if (!IsAirborne[client] && !isClientOnSolidGround) {

				IsAirborne[client] = true;	// when the tank lands, aoe explosion!
			}
			else if (IsAirborne[client] && isClientOnSolidGround) {

				IsAirborne[client] = false;	// the tank has landed; explosion;
				CreateExplosion(client, _, client, true);
			}
			int MyLifetime = GetTime() - MyBirthday[client];
			if (MyBirthday[client] > 0 && NearbySurvivors(client, 1028.0) < 1 && MyLifetime >= 30) {	// by this design, all tanks should ping-pong to the rushers.

				if (MyLifetime >= 90) {

					DeleteMeFromExistence(client);
				}
				else SetSpeedMultiplierBase(client, 2.0);
			}
		}

		/*if (clientTeam == TEAM_SURVIVOR) {

			//CheckIfItemPickup(client);
			//CheckBombs(client);
			if (IsFakeClient(client) && !bIsInCheckpoint[client]) {

				if (SurvivorsSaferoomWaiting()) SurvivorBotsRegroup(client);
			}
		}*/
		bool isClientHoldingJump = (buttons & IN_JUMP) ? true : false;
		if (isClientHoldingJump) bJumpTime[client] = true;
		else {

			bJumpTime[client] = false;
			JumpTime[client] = 0.0;
		}
		if (!IsLegitimateClientAlive(MyAttacker)) StrugglePower[client] = 0;
		bool EnrageActivity = IsEnrageActive();

		if (CombatTime[client] <= TheTime && bIsInCombat[client] && !EnrageActivity && (iPlayersLeaveCombatDuringFinales == 1 || !b_IsFinaleActive)) {

			bIsInCombat[client] = false;
			iThreatLevel[client] = 0;
			LastAttackTime[client] = 0.0;
			if (!IsSurvivalMode) AwardExperience(client);
		}
		else if (CombatTime[client] > TheTime || EnrageActivity || b_IsFinaleActive) {

			bIsInCombat[client] = true;
			if (!bIsHandicapLocked[client]) bIsHandicapLocked[client] = true;
		}
		//if (GetClientTeam(client) == TEAM_INFECTED) SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
		if (clientTeam == TEAM_SURVIVOR) {
			SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", MovementSpeed[client]);
		}

		if (ISDAZED[client] > TheTime) SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", GetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue") * fDazedDebuffEffect);
		else if (ISDAZED[client] <= TheTime && ISDAZED[client] != 0.0) {

			BlindPlayer(client, _, 0);	// wipe the dazed effect.
			ISDAZED[client] = 0.0;
		}

		if (IsPlayerAlive(client) && clientTeam == TEAM_SURVIVOR) {

			if (!isClientOnSolidGround && !b_IsFloating[client]) {

				b_IsFloating[client] = true;
				GetClientAbsOrigin(client, JumpPosition[client][0]);
			}
			if (isClientOnSolidGround) {

				if (b_IsFloating[client]) {

					GetClientAbsOrigin(client, JumpPosition[client][1]);
					//new Float:Z1 = JumpPosition[client][0][2];
					//new Float:Z2 = JumpPosition[client][1][2];

					//if (Z1 > Z2 && Z1 - Z2 >= StringToFloat(GetConfigValue("fall damage critical?"))) IncapacitateOrKill(client, _, _, true);
					//if (Z1 > Z2) {

						//Z1 -= Z2;
						//IsClientActiveBuff(client, 'Q', Z1);
					//}
				}
				b_IsFloating[client] = false;	// in case it was bugged or something (just for safe reason)
			}

			int CurrentEntity			=	GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");

			char EntityName[64];

			Format(EntityName, sizeof(EntityName), "}");
			if (IsValidEntity(CurrentEntity)) GetEdictClassname(CurrentEntity, EntityName, sizeof(EntityName));

			if (StrContains(EntityName, "chainsaw", false) != -1 && (buttons & IN_RELOAD) && GetEntProp(CurrentEntity, Prop_Data, "m_iClip1") < 10) {

				SetEntProp(CurrentEntity, Prop_Data, "m_iClip1", 30);
				buttons &= ~IN_RELOAD;
			}
			bool theClientHasAnActiveProgressBar = ActiveProgressBar(client);
			bool theClientHasPainPills = (StrContains(EntityName, "pain_pills", false) == -1) ? false : true;
			bool theClientHasAdrenaline = (StrContains(EntityName, "adrenaline", false) == -1) ? false : true;
			bool theClientHasFirstAid = (StrContains(EntityName, "first_aid", false) == -1) ? false : true;
			bool theClientHasDefib = (StrContains(EntityName, "defib", false) == -1) ? false : true;
			if (theClientHasAnActiveProgressBar &&
				CurrentEntity != ProgressEntity[client] ||
				(!isClientOnSolidGround && !IsClientIncapacitated) ||
				MyAttacker != -1 ||
				!IsValidEntity(CurrentEntity) && !IsClientIncapacitated ||
				!theClientHasPainPills && !theClientHasAdrenaline && !theClientHasFirstAid && !theClientHasDefib && !IsClientIncapacitated) {
				CreateProgressBar(client, 0.0, true);
				UseItemTime[client] = 0.0;
				theClientHasAnActiveProgressBar = false;
				if (GetEntPropEnt(client, Prop_Send, "m_reviveOwner") == client) {

					SetEntPropEnt(client, Prop_Send, "m_reviveOwner", -1);
					SetEntPropEnt(client, Prop_Send, "m_reviveTarget", -1);
				}
			}
			int PlayerMaxStamina = GetPlayerStamina(client);

			if (MyAttacker == -1 && (IsClientIncapacitated || (IsValidEntity(CurrentEntity) && (theClientHasPainPills || theClientHasAdrenaline || theClientHasFirstAid || theClientHasDefib)))) {

				//blocks the use of meds on people. will add an option in the menu later for now allowing.
				/*if ((buttons & IN_ATTACK2) && !IsIncapacitated(client)) {

					if (StrContains(EntityName, "first_aid", false) != -1) {

						buttons &= ~IN_ATTACK2;
						return Plugin_Changed;
					}
				}*/
				int reviveOwner = -1;
				if ((!IsHoldingPrimaryFire && theClientHasAnActiveProgressBar && !IsClientIncapacitated) || (!isHoldingUseKey && theClientHasAnActiveProgressBar && IsClientIncapacitated)) {

					CreateProgressBar(client, 0.0, true);
					UseItemTime[client] = 0.0;
					theClientHasAnActiveProgressBar = false;
					reviveOwner = GetEntPropEnt(client, Prop_Send, "m_reviveOwner");
					if (reviveOwner == client) {

						SetEntPropEnt(client, Prop_Send, "m_reviveOwner", -1);
						SetEntPropEnt(client, Prop_Send, "m_reviveTarget", -1);
					}
					/*
					if (IsLegitimateClientAlive(reviveOwner) && GetClientTeam(reviveOwner) == TEAM_SURVIVOR) {

						SetEntPropEnt(reviveOwner, Prop_Send, "m_reviveTarget", -1);
						SetEntPropEnt(client, Prop_Send, "m_reviveOwner", -1);
					}*/
				}
				if ((IsHoldingPrimaryFire && !IsClientIncapacitated) || (isHoldingUseKey && IsClientIncapacitated)) {
					if (!IsClientIncapacitated) buttons &= ~IN_ATTACK;
					else buttons &= ~IN_USE;
					if (UseItemTime[client] < TheTime) {
						if (theClientHasAnActiveProgressBar) {
							UseItemTime[client] = 0.0;
							CreateProgressBar(client, 0.0, true);
							if (!IsClientIncapacitated) {
								if (theClientHasPainPills) {
									HealPlayer(client, client, GetTempHealth(client) + (GetMaximumHealth(client) * 0.3), 'h', true);//SetTempHealth(client, client, GetTempHealth(client) + (GetMaximumHealth(client) * 0.3), false);		// pills add 10% of your total health in temporary health.
									AcceptEntityInput(CurrentEntity, "Kill");
								}
								else if (theClientHasAdrenaline) {
									SetAdrenalineState(client);
									int StaminaBonus = RoundToCeil(PlayerMaxStamina * 0.25);
									if (SurvivorStamina[client] + StaminaBonus >= PlayerMaxStamina) {
										SurvivorStamina[client] = PlayerMaxStamina;
										bIsSurvivorFatigue[client] = false;
									}
									else SurvivorStamina[client] += StaminaBonus;
									AcceptEntityInput(CurrentEntity, "Kill");
								}
								else if (theClientHasDefib) {
									Defibrillator(client);
									AcceptEntityInput(CurrentEntity, "Kill");
								}
								else if (theClientHasFirstAid) {
									GiveMaximumHealth(client);
									RefreshSurvivor(client);
									AcceptEntityInput(CurrentEntity, "Kill");
								}
							}
							else {
								ReviveDownedSurvivor(client);
								OnPlayerRevived(client, client);
								reviveOwner = GetEntPropEnt(client, Prop_Send, "m_reviveOwner");
								if (IsLegitimateClientAlive(reviveOwner)) SetEntPropEnt(reviveOwner, Prop_Send, "m_reviveTarget", -1);
								SetEntPropEnt(client, Prop_Send, "m_reviveOwner", -1);
							}
						}
						else {
							if (IsClientIncapacitated && UseItemTime[client] < TheTime) {
								reviveOwner = GetEntPropEnt(client, Prop_Send, "m_reviveOwner");
								if (!IsLegitimateClientAlive(reviveOwner)) {
									SetEntPropEnt(client, Prop_Send, "m_reviveOwner", client);
									ProgressEntity[client]			=	GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
									CreateProgressBar(client, 5.0);	// you can pick yourself up for free but it takes a bit.
								}
							}
							if (!IsClientIncapacitated && UseItemTime[client] < TheTime) {
								float fProgressBarCompletionTime = -1.0;
								if (theClientHasPainPills) fProgressBarCompletionTime = 2.0;
								else if (theClientHasAdrenaline) fProgressBarCompletionTime = 1.0;
								else if (theClientHasFirstAid || theClientHasDefib) fProgressBarCompletionTime = 5.0;
								if (fProgressBarCompletionTime != -1.0) {
									ProgressEntity[client]			=	GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
									CreateProgressBar(client, fProgressBarCompletionTime);
								}
							}
							if (theClientHasAnActiveProgressBar) SetEntPropEnt(client, Prop_Send, "m_reviveOwner", client);
						}
					}
					return Plugin_Changed;
				}
			}
			// For drawing special ammo.
			if (bIsSurvivorFatigue[client]) {
				IsSpecialAmmoEnabled[client][0] = 0.0;
				Format(ActiveSpecialAmmo[client], sizeof(ActiveSpecialAmmo[]), "none");
			}
			if (GetClientTeam(client) == TEAM_SURVIVOR) {
				if ((ReadyUp_GetGameMode() != 3 || !b_IsSurvivalIntermission) && iRPGMode >= 1) {
					bool IsJetpackBroken = (isClientOnFire || IsCoveredInBile(client));
					if (!IsJetpackBroken) IsJetpackBroken = AnyTanksNearby(client);
					/*
						Add or remove conditions from the following line to determine when the jetpack automatically disables.
						When adding new conditions, consider a switch so server operators can choose which of them they want to use.
					*/
					if (bJetpack[client] && (iCanJetpackWhenInCombat == 1 || !bIsInCombat[client]) && (!isClientHoldingJump || IsJetpackBroken || MyAttacker != -1)) {
						ToggleJetpack(client, true);
					}
					if ((bJetpack[client] || !bJetpack[client] && !isClientOnSolidGround) ||
						(isClientHoldingJump || isHoldingShift && isClientHoldingMovementKeys) &&
						SurvivorStamina[client] >= ConsumptionInt && !bIsSurvivorFatigue[client] && ISSLOW[client] == INVALID_HANDLE && ISFROZEN[client] == INVALID_HANDLE) {
						if (MyAttacker == -1 && ISSLOW[client] == INVALID_HANDLE && ISFROZEN[client] == INVALID_HANDLE) {
							if (SurvivorConsumptionTime[client] <= TheTime && (isClientHoldingJump || isHoldingShift)) {
								if (bJetpack[client]) {
									float nextSprintInterval = GetAbilityStrengthByTrigger(client, client, "jetpack", _, 0, _, _, "flightcost", _, _, 2);
									if (nextSprintInterval > 0.0) {
										SurvivorConsumptionTime[client] = TheTime + fStamSprintInterval + (fStamSprintInterval * nextSprintInterval);
									}
									else SurvivorConsumptionTime[client] = TheTime + fStamSprintInterval;
								}
								else SurvivorConsumptionTime[client] = TheTime + fStamSprintInterval;
								SurvivorStamina[client] -= ConsumptionInt;
								if (SurvivorStamina[client] <= 0) {
									bIsSurvivorFatigue[client] = true;
									IsSpecialAmmoEnabled[client][0] = 0.0;
									SurvivorStamina[client] = 0;
									if (bJetpack[client]) ToggleJetpack(client, true);
								}
							}
							if (!bIsSurvivorFatigue[client] && !bJetpack[client] && (isClientHoldingJump && (JumpTime[client] >= 0.2)) && (iCanJetpackWhenInCombat == 1 || !bIsInCombat[client]) && !IsJetpackBroken && JetpackRecoveryTime[client] <= GetEngineTime() && MyAttacker == -1) ToggleJetpack(client);
							if (!bJetpack[client]) MovementSpeed[client] = fSprintSpeed;
						}
						buttons &= ~IN_SPEED;
						return Plugin_Changed;
					}
					if (!isHoldingShift && !bJetpack[client]) {
						if (SurvivorStaminaTime[client] < TheTime && SurvivorStamina[client] < PlayerMaxStamina) {
							if (!HasAdrenaline(client)) SurvivorStaminaTime[client] = TheTime + fStamRegenTime;
							else SurvivorStaminaTime[client] = TheTime + fStamRegenTimeAdren;
							SurvivorStamina[client]++;
						}
						if (!bIsSurvivorFatigue[client]) MovementSpeed[client] = fBaseMovementSpeed;
						else MovementSpeed[client] = fFatigueMovementSpeed;
						if (ISSLOW[client] != INVALID_HANDLE) MovementSpeed[client] *= fSlowSpeed[client];
						if (SurvivorStamina[client] >= PlayerMaxStamina) {
							bIsSurvivorFatigue[client] = false;
							SurvivorStamina[client] = PlayerMaxStamina;
						}
					}
				}
			}

			/*if (buttons & IN_JUMP) {

				if (L4D2_GetInfectedAttacker(client) == -1 && L4D2_GetSurvivorVictim(client) == -1 && (GetEntityFlags(client) & FL_ONGROUND)) {

					GetAbilityStrengthByTrigger(client, 0, 'j', FindZombieClass(client), 0);
				}
				if (L4D2_GetSurvivorVictim(client) != -1) {

					new victim = L4D2_GetSurvivorVictim(client);
					if ((GetEntityFlags(victim) & FL_ONGROUND)) GetAbilityStrengthByTrigger(client, victim, 'J', FindZombieClass(client), 0);
				}
			}
			else if (!(buttons & IN_JUMP) && b_IsJumping[client]) ModifyGravity(client);*/
		}
	}
	return Plugin_Continue;
}

stock void ToggleJetpack(int client, bool DisableJetpack = false) {

	float ClientPos[3];
	GetClientAbsOrigin(client, ClientPos);
	if (!DisableJetpack && !bJetpack[client]) {

		EmitSoundToAll(JETPACK_AUDIO, client, SNDCHAN_WEAPON, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.5, SNDPITCH_NORMAL, -1, ClientPos, NULL_VECTOR, true, 0.0);
		SetEntityMoveType(client, MOVETYPE_FLY);
		bJetpack[client] = true;
	}
	else if (DisableJetpack && bJetpack[client]) {

		StopSound(client, SNDCHAN_WEAPON, JETPACK_AUDIO);
		//EmitSoundToAll(JETPACK_AUDIO, client, SNDCHAN_WEAPON, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, ClientPos, NULL_VECTOR, true, 0.0);
		SetEntityMoveType(client, MOVETYPE_WALK);
		bJetpack[client] = false;
	}
}

stock bool IsEveryoneBoosterTime() {

	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && !IsFakeClient(i) && GetClientTeam(i) != TEAM_SPECTATOR && !HasBoosterTime(i)) return false;
	}
	return true;
}

stock void CreateDamageStatusEffect(int client, int type = 0, int target = 0, int damage = 0, int owner = 0, float RangeOverride = 0.0) {
	if (!IsSpecialCommon(client)) return;
	float AfxRange = GetCommonValueFloatAtPos(client, SUPER_COMMON_RANGE_PLAYER_LEVEL);
	float AfxStrengthLevel = GetCommonValueFloatAtPos(client, SUPER_COMMON_LEVEL_STRENGTH);
	float AfxRangeMax = GetCommonValueFloatAtPos(client, SUPER_COMMON_RANGE_MAX);
	int AfxMultiplication = GetCommonValueIntAtPos(client, SUPER_COMMON_ENEMY_MULTIPLICATION);
	int AfxStrength = GetCommonValueIntAtPos(client, SUPER_COMMON_AURA_STRENGTH);
	float AfxStrengthTarget = GetCommonValueFloatAtPos(client, SUPER_COMMON_STRENGTH_TARGET);
	float AfxRangeBase = GetCommonValueFloatAtPos(client, SUPER_COMMON_RANGE_MIN);
	float OnFireBase = GetCommonValueFloatAtPos(client, SUPER_COMMON_ONFIRE_BASE_TIME);
	float OnFireLevel = GetCommonValueFloatAtPos(client, SUPER_COMMON_ONFIRE_LEVEL);
	float OnFireMax = GetCommonValueFloatAtPos(client, SUPER_COMMON_ONFIRE_MAX_TIME);
	float OnFireInterval = GetCommonValueFloatAtPos(client, SUPER_COMMON_ONFIRE_INTERVAL);
	int AfxLevelReq = GetCommonValueIntAtPos(client, SUPER_COMMON_LEVEL_REQ);
	float ClientPosition[3];
	float TargetPosition[3];
	int t_Strength = 0;
	float t_Range = 0.0;
	float t_OnFireRange = 0.0;
	if (damage > 0) AfxStrength = damage;	// if we want to base the damage on a specific value, we can override here.
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", ClientPosition);
	int NumLivingEntities = LivingEntitiesInRange(client, ClientPosition, AfxRangeMax);
	if (NumLivingEntities > 1) damage = (damage / NumLivingEntities);
	if (target == 0 || IsLegitimateClient(target)) {
		for (int i = 1; i <= MaxClients; i++) {
			if (!IsLegitimateClientAlive(i) || (target != 0 && i != target) || PlayerLevel[i] < AfxLevelReq) continue;		// if type is 1 and target is 0 acid is spread to all players nearby. but if target is not 0 it is spread to only the player the acid zombie hits. or whatever type uses it.
			GetClientAbsOrigin(i, TargetPosition);
			if (RangeOverride == 0.0) {
				if (AfxRange > 0.0) t_Range = AfxRange * (PlayerLevel[i] - AfxLevelReq);
				else t_Range = AfxRangeMax;
				if (t_Range + AfxRangeBase > AfxRangeMax) t_Range = AfxRangeMax;
				else t_Range += AfxRangeBase;
			}
			else t_Range = RangeOverride;
			if (GetVectorDistance(ClientPosition, TargetPosition) > (t_Range / 2)) continue;
			if (AfxMultiplication == 1) {
				if (AfxStrengthTarget < 0.0) t_Strength = AfxStrength * NumLivingEntities;
				else t_Strength = RoundToCeil(AfxStrength * (NumLivingEntities * AfxStrengthTarget));
			}
			else t_Strength = AfxStrength;
			if (AfxStrengthLevel > 0.0) t_Strength += RoundToCeil(t_Strength * ((PlayerLevel[i] - AfxLevelReq) * AfxStrengthLevel));
			t_OnFireRange = OnFireLevel * (PlayerLevel[i] - AfxLevelReq);
			t_OnFireRange += OnFireBase;
			if (t_OnFireRange > OnFireMax) t_OnFireRange = OnFireMax;
			if (IsSpecialCommonInRange(client, 'b')) t_Strength = GetSpecialCommonDamage(t_Strength, client, 'b', i);
			if (type == 0) CreateAndAttachFlame(i, t_Strength, t_OnFireRange, OnFireInterval, _, "burn");		// time for now.
			else if (type == 4) {
				CreateAndAttachFlame(i, t_Strength, t_OnFireRange, OnFireInterval, _, "acid");
				break;	// to prevent buffer overflow only allow it on one client.
			}
		}
	}
	if (target == 0 || IsCommonInfected(target)) {
		int ent = -1;
		for (int i = 0; i < CommonInfected.Length; i++) {
			ent = CommonInfected.Get(i);
			if (!IsCommonInfected(ent)) continue;
			if (ent == client) continue;
			if (target != 0 && ent != target) continue;
			GetEntPropVector(ent, Prop_Send, "m_vecOrigin", TargetPosition);
			if (GetVectorDistance(ClientPosition, TargetPosition) > (AfxRangeMax / 2)) continue;
			if (!IsSpecialCommon(ent)) {
				OnCommonInfectedCreated(ent, true, _, true); // will calculate xp rewards, unhook, and set on fire.
				if (i > 0) i--;
			}
			else if (IsLegitimateClient(owner) && GetClientTeam(owner) == TEAM_SURVIVOR) AddSpecialCommonDamage(owner, ent, damage);
		}
	}
	//ClearSpecialCommon(client);
}

stock int FindEntityInArrayBinarySearch(Handle hArray, int target) {
	int left = 0, right = hArray.Length;
	int middle;
	int ent;
	while (left < right) {
		middle = (left + right) / 2;
		ent = hArray.Get(middle);
		if (ent == target) return middle;
		if (ent < target) left = middle + 1;
		else right = middle;
	}
	return -1;
}

// Eyal282 here, rightEnt is unknown and throws errors.
/*
// inserting entity into an arraylist in ascending order so it's compatible with binary search
stock InsertIntoArrayAscending(Handle hArray, entity) {
	int size = hArray.Length;
	int left = 0, right = size;
	if (right < 1) {	// if the array is empty, just push.
		hArray.Push(entity);
		return 0;
	}
	else if (right < 2) {	// another outlier check to prevent array oob.
		if (entity > hArray.Get(0)) {
			hArray.Push(entity);
			return 1;
		}
		else {
			hArray.Resize(size+1);
			hArray.ShiftUp(size);
			hArray.Set(size, entity);
			return 0;
		}
	}
	else {
		int middle = (left + right) / 2;
		int middleEnt = hArray.Get(middle);
		int leftEnt = hArray.Get(middle - 1);
		while (entity < leftEnt || entity > middleEnt) {
			middle = (left + right) / 2;
			middleEnt = hArray.Get(middle);
			leftEnt = hArray.Get(middle - 1);
			if (entity < leftEnt) right--;
			else if (entity > rightEnt) left++;
			else break;
		}
		hArray.Resize(size+1);
		hArray.ShiftUp(middle);	// middle is now undefined.
		hArray.Set(middle, entity);	// place new entity in middle.
		return middle;
	}
	return -1;	// should be unreachable.
}
*/
stock int FindListPositionByEntity(int entity, Handle h_SearchList, int block = 0) {

	int size = h_SearchList.Length;
	if (size < 1) return -1;
	for (int i = 0; i < size; i++) {

		if (h_SearchList.Get(i, block) == entity) return i;
	}
	return -1;	// returns false
}

stock int FindCommonInfectedTargetInArray(Handle hArray, int target) {
	int size = hArray.Length;
	for (int i = 0; i < size; i++) {
		if (i >= size - 1 - i) break;
		if (hArray.Get(i) == target) return i;
		if (hArray.Get(size - 1 - i) == target) return size-1-i;
	}
	return -1;
}

stock void ExplosiveAmmo(int client, float damage, int TalentClient) {
	if (IsWitch(client)) AddWitchDamage(TalentClient, client, damage);
	else if (IsSpecialCommon(client)) AddSpecialCommonDamage(TalentClient, client, damage);
	else if (IsLegitimateClientAlive(client)) {
		if (GetClientTeam(client) == TEAM_INFECTED) AddSpecialInfectedDamage(TalentClient, client, damage);
		else SetClientTotalHealth(client, damage);	// survivor teammates don't reward players with experience or damage bonus, but they'll take damage from it.
	}
}

stock void HealingAmmo(int client, int healing, int TalentClient, bool IsCritical=false) {
	if (!IsLegitimateClientAlive(client) || !IsLegitimateClientAlive(TalentClient)) return;
	HealPlayer(client, TalentClient, healing * 1.0, 'h', true);
}

stock void LeechAmmo(int client, int damage, int TalentClient) {
	if (IsWitch(client)) AddWitchDamage(TalentClient, client, damage);
	else if (IsSpecialCommon(client)) AddSpecialCommonDamage(TalentClient, client, damage);
	else if (IsLegitimateClientAlive(client)) {
		if (GetClientTeam(client) == TEAM_INFECTED) AddSpecialInfectedDamage(TalentClient, client, damage);
		else SetClientTotalHealth(client, damage);
	}
	if (IsLegitimateClientAlive(TalentClient) && GetClientTeam(TalentClient) == TEAM_SURVIVOR) {
		//if (IsCritical || !IsCriticalHit(client, healing, TalentClient))	// maybe add this to leech? that would be cool.!
		HealPlayer(TalentClient, TalentClient, damage * 1.0, 'h', true);
	}
}

stock float CreateBomberExplosion(int client, int target, char[] Effects, int basedamage = 0) {

	//if (IsLegitimateClient(target) && !IsPlayerAlive(target)) return;
	if (!IsLegitimateClientAlive(target)) return;

	/*

		When a bomber dies, it explodes.
	*/
	float AfxRange = GetCommonValueFloatAtPos(client, SUPER_COMMON_RANGE_PLAYER_LEVEL);
	float AfxStrengthLevel = GetCommonValueFloatAtPos(client, SUPER_COMMON_LEVEL_STRENGTH);
	float AfxRangeMax = GetCommonValueFloatAtPos(client, SUPER_COMMON_RANGE_MAX);
	int AfxMultiplication = GetCommonValueIntAtPos(client, SUPER_COMMON_ENEMY_MULTIPLICATION);
	int AfxStrength = GetCommonValueIntAtPos(client, SUPER_COMMON_AURA_STRENGTH);
	int AfxChain = GetCommonValueIntAtPos(client, SUPER_COMMON_CHAIN_REACTION);
	float AfxStrengthTarget = GetCommonValueFloatAtPos(client, SUPER_COMMON_STRENGTH_TARGET);
	float AfxRangeBase = GetCommonValueFloatAtPos(client, SUPER_COMMON_RANGE_MIN);
	int AfxLevelReq = GetCommonValueIntAtPos(client, SUPER_COMMON_LEVEL_REQ);
	int isRaw = GetCommonValueIntAtPos(client, SUPER_COMMON_RAW_STRENGTH);
	int rawCommon = GetCommonValueIntAtPos(client, SUPER_COMMON_RAW_COMMON_STRENGTH);
	int rawPlayer = GetCommonValueIntAtPos(client, SUPER_COMMON_RAW_PLAYER_STRENGTH);


	if (IsSpecialCommon(client) && IsLegitimateClient(target) && GetClientTeam(target) == TEAM_SURVIVOR && PlayerLevel[target] < AfxLevelReq) return;

	float SourcLoc[3];
	float TargetPosition[3];
	int t_Strength = 0;
	float t_Range = 0.0;

	if (target > 0) {

		if (IsLegitimateClient(target)) GetClientAbsOrigin(target, SourcLoc);
		else GetEntPropVector(target, Prop_Send, "m_vecOrigin", SourcLoc);
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", TargetPosition);

		if (AfxRange > 0.0 && IsLegitimateClientAlive(target)) t_Range = AfxRange * (PlayerLevel[target] - AfxLevelReq);
		else t_Range = AfxRangeMax;
		if (t_Range + AfxRangeBase > AfxRangeMax) t_Range = AfxRangeMax;
		else t_Range += AfxRangeBase;

		if (IsLegitimateClientAlive(target) && GetClientTeam(target) == TEAM_SURVIVOR && target != client) {

			if (PlayerLevel[target] < AfxLevelReq) return;
			if (GetVectorDistance(SourcLoc, TargetPosition) > (t_Range / 2)) return;
		}

		int NumLivingEntities = 0;
		int rawStrength = 0;
		int abilityStrength = 0;
		if (isRaw == 0) {
			NumLivingEntities = LivingEntitiesInRange(client, SourcLoc, AfxRangeMax);
			if (AfxMultiplication == 1) {
				if (AfxStrengthTarget < 0.0) t_Strength = basedamage + (AfxStrength * NumLivingEntities);
				else t_Strength = RoundToCeil(basedamage + (AfxStrength * (NumLivingEntities * AfxStrengthTarget)));
			}
			else t_Strength = (basedamage + AfxStrength);
		}
		else {
			rawStrength = rawCommon * LivingEntitiesInRange(client, SourcLoc, AfxRangeMax, 1);
			rawStrength += rawPlayer * LivingEntitiesInRange(client, SourcLoc, AfxRangeMax, 4);
		}

		for (int i = 1; i <= MaxClients; i++) {

			if (!IsLegitimateClientAlive(i) || PlayerLevel[i] < AfxLevelReq) continue;
			GetClientAbsOrigin(i, TargetPosition);

			if (AfxRange > 0.0) t_Range = AfxRange * (PlayerLevel[i] - AfxLevelReq);
			else t_Range = AfxRangeMax;
			if (t_Range + AfxRangeBase > AfxRangeMax) t_Range = AfxRangeMax;
			else t_Range += AfxRangeBase;
			if (GetVectorDistance(SourcLoc, TargetPosition) > (t_Range / 2) || StrContains(clientStatusEffectDisplay[i], "[Fl]", false) != -1) continue;		// player not within blast radius, takes no damage. Or playing is floating.

			// Because range can fluctuate, we want to get the # of entities within range for EACH player individually.
			if (isRaw == 0) {
				abilityStrength = t_Strength;
			}
			else {
				abilityStrength = rawStrength;
			}
			if (AfxStrengthLevel > 0.0) abilityStrength += RoundToCeil(abilityStrength * ((PlayerLevel[i] - AfxLevelReq) * AfxStrengthLevel));

			//if (t_Strength > GetClientHealth(i)) IncapacitateOrKill(i);
			//else SetEntityHealth(i, GetClientHealth(i) - t_Strength);
			if (abilityStrength > 0) SetClientTotalHealth(i, abilityStrength);

			if (client == target) {

				// To prevent a never-ending chain reaction, we don't allow it to target the bomber that caused it.

				if (GetClientTeam(i) == TEAM_SURVIVOR && AfxChain == 1) CreateBomberExplosion(client, i, Effects);
			}
		}
		if (StrContains(Effects, "e", true) != -1 || StrContains(Effects, "x", true) != -1) {

			CreateExplosion(target);	// boom boom audio and effect on the location.
			if (IsLegitimateClientAlive(target) && !IsFakeClient(target)) ScreenShake(target);
		}
		if (StrContains(Effects, "B", true) != -1) {

			if (IsLegitimateClientAlive(target) && !ISBILED[target]) {

				SDKCall(g_hCallVomitOnPlayer, target, client, true);
				CreateTimer(15.0, Timer_RemoveBileStatus, target, TIMER_FLAG_NO_MAPCHANGE);
				ISBILED[target] = true;
				StaggerPlayer(target, client);
			}
		}
		if (StrContains(Effects, "a", true) != -1) {

			CreateDamageStatusEffect(client, 4, target, abilityStrength);
		}

		if (client == target) CreateBomberExplosion(client, 0, Effects);
		/*if (client == target) {

			for (new i = 0; i < Handle:CommonInfected.Length; i++) {

				ent = Handle:CommonInfected.Get(i);
				if (IsCommonInfected(ent)) {

					GetEntPropVector(ent, Prop_Send, "m_vecOrigin", TargetPosition);
					if (GetVectorDistance(SourcLoc, TargetPosition) <= (t_Range / 2)) {

						CreateBomberExplosion(client, ent, Effects);
					}
				}
			}
			CreateBomberExplosion(client, 0, Effects);
		}*/
	}
	/*else {

		GetEntPropVector(client, Prop_Send, "m_vecOrigin", SourcLoc);

		

		//	The bomber target is 0, so we eliminate any common infected within range.
		//	Don't worry - this function will have called and executed for all players in range before it gets here
		//	thanks to the magic of single-threaded language.
		
		ent = -1;
		for (new i = 0; i < Handle:CommonInfected.Length; i++) {

			ent = Handle:CommonInfected.Get(i);

			if (IsCommonInfected(ent)) {

				GetEntPropVector(ent, Prop_Send, "m_vecOrigin", TargetPosition);
				if (GetVectorDistance(SourcLoc, TargetPosition) <= (AfxRangeMax / 2)) {

					//AcceptEntityInput(ent, "Kill");
					
					//ent = FindListPositionByEntity(ent, Handle:CommonInfected);
					//if (ent >= 0) Handle:CommonInfected.Erase(ent);
					//CalculateInfectedDamageAward(ent);
					if ((StrContains(Effects, "e", true) != -1 || StrContains(Effects, "x", true) != -1) && !IsSpecialCommon(ent)) {

						OnCommonInfectedCreated(ent, true);
						if (i > 0) i--;
					}
					//if (StrContains(Effects, "B", true) != -1) SDKCall(g_hCallVomitOnPlayer, ent, client, true);
				}
			}
		}
	}*/
}

stock void CheckMinimumRate(int client) {
	if (Rating[client] < 0) Rating[client] = 0;
}

stock void CalculateInfectedDamageAward(int client, int killerblow = 0, int entityPos = -1) {
	bool IsLegitimateClientClient = IsLegitimateClient(client);
	int clientTeam = -1;
	if (IsLegitimateClientClient) clientTeam = GetClientTeam(client);
	int clientZombieClass = -1;
	if (clientTeam != -1) clientZombieClass = FindZombieClass(client);
	int ClientType = -1;
	if (IsLegitimateClientClient && clientTeam == TEAM_INFECTED) {
		ClientType = 0;
		ReadyUp_NtvStatistics(killerblow, 6, 1);
		if (clientZombieClass != ZOMBIECLASS_TANK) RoundStatistics.Set(3, RoundStatistics.Get(3) + 1);
		else RoundStatistics.Set(4, RoundStatistics.Get(4) + 1);
	}
	else if (IsWitch(client)) {
		ClientType = 1;
		RoundStatistics.Set(2, RoundStatistics.Get(2) + 1);
	}
	else if (IsSpecialCommon(client)) {
		ReadyUp_NtvStatistics(killerblow, 2, 1);
		ClientType = 2;
		RoundStatistics.Set(1, RoundStatistics.Get(1) + 1);
	}
	bool IsLegitimateClientKiller = IsLegitimateClient(killerblow);
	int killerClientTeam = -1;
	if (IsLegitimateClientKiller) killerClientTeam = GetClientTeam(killerblow);
	/*if (ClientType >= 0 && IsLegitimateClientKiller && killerClientTeam == TEAM_SURVIVOR) {
		if (isQuickscopeKill(killerblow)) {
			// If the user met the server operators standards for a quickscope kill, we do something.
			GetAbilityStrengthByTrigger(killerblow, client, "quickscope");
		}
	}*/
	//CreateItemRoll(client, killerblow);	// all infected types can generate an item roll
	float SurvivorPoints = 0.0;
	int SurvivorExperience = 0;
	float PointsMultiplier = fPointsMultiplier;
	float ExperienceMultiplier = SurvivorExperienceMult;
	float TankingMultiplier = SurvivorExperienceMultTank;
	float HealingMultiplier = SurvivorExperienceMultHeal;
	//new Float:RatingReductionMult = 0.0;
	int t_Contribution = 0;
	int h_Contribution = 0;
	int SurvivorDamage = 0;
	float TheAbilityMultiplier = 0.0;
	if (IsLegitimateClientKiller && ClientType == 0 && killerClientTeam == TEAM_SURVIVOR) {
		TheAbilityMultiplier = GetAbilityMultiplier(killerblow, "I");
		if (TheAbilityMultiplier > 0.0) { // heal because you dealt the killing blow
			HealPlayer(killerblow, killerblow, TheAbilityMultiplier * GetMaximumHealth(killerblow), 'h', true);
		}
		TheAbilityMultiplier = GetAbilityMultiplier(killerblow, "l");
		if (TheAbilityMultiplier > 0.0) {
			// Creates fire on the target and deals AOE explosion.
			CreateExplosion(client, RoundToCeil(DataScreenWeaponDamage(killerblow) * TheAbilityMultiplier), killerblow, true);
			CreateFireEx(client);
		}
	}
	//new owner = 0;
	//if (IsLegitimateClientAlive(commonkiller) && GetClientTeam(commonkiller) == TEAM_SURVIVOR) owner = commonkiller;
	if (ClientType == 0) SpecialsKilled++;
	float i_DamageContribution = 0.0000;
	// If it's a special common, we activate its death abilities.
	if (ClientType == 2) {
		char TheEffect[10];
		GetCommonValueAtPos(TheEffect, sizeof(TheEffect), client, SUPER_COMMON_AURA_EFFECT);
		CreateBomberExplosion(client, client, TheEffect);	// bomber aoe
	}
	int pos = -1;
	int RatingBonus = 0;
	int RatingTeamBonus = 0;
	int iLivingSurvivors = LivingSurvivors() - 1;
	//decl String:MyName[64];
	char killerName[64];
	char killedName[64];
	if (ClientType > 0 || IsLegitimateClientClient) {
		if (IsLegitimateClientClient) GetClientName(client, killedName, sizeof(killedName));
		else {
			if (ClientType == 1) Format(killedName, sizeof(killedName), "Witch");
			else {
				GetCommonValueAtPos(killedName, sizeof(killedName), client, SUPER_COMMON_NAME);
				Format(killedName, sizeof(killedName), "Common %s", killedName);
			}
		}
		if (IsLegitimateClientKiller) {
			GetClientName(killerblow, killerName, sizeof(killerName));
			PrintToChatAll("%t", "player killed special infected", blue, killerName, white, orange, killedName);
		}
		else if (ClientType != 2) {
			PrintToChatAll("%t", "killed special infected", orange, killedName, white);
		}
	}
	char ratingBonusText[64];
	char ratingTeamBonusText[64];
	bool survivorsAreLessThanRequired = (iLivingSurvivors <= iTeamRatingRequired) ? true : false;
	for (int i = 1; i <= MaxClients; i++) {
		RatingBonus = 0;
		SurvivorExperience = 0;
		SurvivorPoints = 0.0;
		i_DamageContribution = 0.0000;
		if (!IsLegitimateClient(i) || GetClientTeam(i) != TEAM_SURVIVOR) continue;
		if (ClientType == 0) pos = FindListPositionByEntity(client, InfectedHealth[i]);
		else if (ClientType == 1) pos = FindListPositionByEntity(client, WitchDamage[i]);
		else if (ClientType == 2) pos = FindListPositionByEntity(client, SpecialCommon[i]);
		if (pos < 0) continue;
		if (bIsInCheckpoint[i]) {
			if (ClientType == 0) InfectedHealth[i].Erase(pos);
			else if (ClientType == 1) WitchDamage[i].Erase(pos);
			else if (ClientType == 2) SpecialCommon[i].Erase(pos);
			continue;
		}
		if (LastAttackedUser[i] == client) LastAttackedUser[i] = -1;
		if (ClientType == 0) SurvivorDamage = InfectedHealth[i].Get(pos, 2);
		else if (ClientType == 1) SurvivorDamage = WitchDamage[i].Get(pos, 2);
		else if (ClientType == 2) SurvivorDamage = SpecialCommon[i].Get(pos, 2);
		RatingBonus = GetRatingReward(i, client);
		if (RatingBonus > 0) {
			if (!IsFakeClient(i) && ClientType >= 0) {
				AddCommasToString(RatingBonus, ratingBonusText, sizeof(ratingBonusText));
				if (survivorsAreLessThanRequired) {
					PrintToChat(i, "%T", "rating increase", i, white, blue, ratingBonusText, orange);
				}
				else {
					RatingTeamBonus += RoundToCeil(RatingBonus * ((iLivingSurvivors - iTeamRatingRequired) * fTeamRatingBonus));
					AddCommasToString(RatingTeamBonus, ratingTeamBonusText, sizeof(ratingTeamBonusText));
					Rating[i] += RatingTeamBonus;
					PrintToChat(i, "%T", "team rating increase", i, white, blue, ratingBonusText, orange, white, green, blue, ratingTeamBonusText, orange, white);
				}
			}
			CheckMinimumRate(i);
			Rating[i] += RatingBonus;
			TheAbilityMultiplier = GetAbilityMultiplier(i, "R");
			if (TheAbilityMultiplier > 0.0) { // heal because you dealt the killing blow
				HealPlayer(i, i, TheAbilityMultiplier * RatingBonus, 'h', true);
			}
		}
		if (SurvivorDamage > 0) {
			SurvivorExperience = RoundToFloor(SurvivorDamage * ExperienceMultiplier);
			SurvivorPoints = SurvivorDamage * PointsMultiplier;
		}
		i_DamageContribution = CheckTeammateDamages(client, i, true);
		if (i_DamageContribution > 0.0) {
			SurvivorExperience = RoundToFloor(SurvivorDamage * ExperienceMultiplier);
			SurvivorPoints = SurvivorDamage * PointsMultiplier;
		}
		t_Contribution = CheckTankingDamage(client, i);
		if (t_Contribution > 0) {
			t_Contribution = RoundToCeil(t_Contribution * TankingMultiplier);
			SurvivorPoints += (t_Contribution * (PointsMultiplier * TankingMultiplier));
		}
		//h_Contribution = HealingContribution[i];
		//HealingContribution[i] = 0;
		//CreateLootItem(i, i_DamageContribution, CheckTankingDamage(client, i), RoundToCeil(h_Contribution * HealingMultiplier));
		if (h_Contribution > 0) {
			h_Contribution = RoundToCeil(h_Contribution * HealingMultiplier);
			SurvivorPoints += (h_Contribution * (PointsMultiplier * HealingMultiplier));
		}
		//if (!bIsInCombat[i]) ReceiveInfectedDamageAward(i, client, SurvivorExperience, SurvivorPoints, t_Contribution, h_Contribution, Bu_Contribution, He_Contribution);
		HealingContribution[i] += h_Contribution;
		TankingContribution[i] += t_Contribution;
		PointsContribution[i] += SurvivorPoints;
		DamageContribution[i] += SurvivorExperience;
		if (ClientType == 0) InfectedHealth[i].Erase(pos);
		else if (ClientType == 1) WitchDamage[i].Erase(pos);
		else if (ClientType == 2) SpecialCommon[i].Erase(pos);
	}
	if (ClientType == 1) {
		SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
		AcceptEntityInput(client, "Kill");
		if (entityPos >= 0) WitchList.Erase(entityPos);		// Delete the witch. Forever.
	}
	if (IsLegitimateClientClient && clientTeam == TEAM_INFECTED) {

		if (clientZombieClass == ZOMBIECLASS_TANK) bIsDefenderTank[client] = false;

		if (iTankRush != 1 && clientZombieClass == ZOMBIECLASS_TANK && DirectorTankCooldown > 0.0 && f_TankCooldown == -1.0) {

			f_TankCooldown				=	DirectorTankCooldown;

			CreateTimer(1.0, Timer_TankCooldown, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
		TankState_Array[client].Clear();
		MyBirthday[client] = 0;
		CreateMyHealthPool(client, true);
		ChangeHook(client);
		ForcePlayerSuicide(client);

		if (b_IsFinaleActive && GetInfectedCount(ZOMBIECLASS_TANK) < 1) {

			b_IsFinaleTanks = true;	// next time the event tank spawns, it will allow it to spawn multiple tanks.
		}
	}
}

stock void ReceiveInfectedDamageAward(int client, int infected, int e_reward, float p_reward, int t_reward, int h_reward, int bu_reward, int he_reward, bool TheRoundHasEnded = false) {
	int RPGMode									= iRPGMode;
	if (RPGMode < 0) return;
	//new RPGBroadcast							= StringToInt(GetConfigValue("award broadcast?"));
	char InfectedName[64];
	//decl String:InfectedTeam[64];
	int enemytype = -1;
	if (infected > 0) {
		if (IsLegitimateClient(infected)) {
			GetClientName(infected, InfectedName, sizeof(InfectedName));
			enemytype = 3;
		}
		else if (IsWitch(infected)) {
			Format(InfectedName, sizeof(InfectedName), "Witch");
			enemytype = 2;
		}
		else if (IsSpecialCommon(infected)) {
			GetCommonValueAtPos(InfectedName, sizeof(InfectedName), infected, SUPER_COMMON_NAME);
			enemytype = 1;
		}
		else if (IsCommonInfected(infected)) {
			Format(InfectedName, sizeof(InfectedName), "Common");
			enemytype = 0;
		}
		Format(InfectedName, sizeof(InfectedName), "%s %s", sDirectorTeam, InfectedName);
	}
	float fRoundMultiplier = 1.0;
	if (RoundExperienceMultiplier[client] > 0.0) {
		fRoundMultiplier += RoundExperienceMultiplier[client];
		e_reward = RoundToCeil(e_reward * fRoundMultiplier);
		h_reward += RoundToCeil(h_reward * fRoundMultiplier);
		t_reward += RoundToCeil(t_reward * fRoundMultiplier);
		bu_reward += RoundToCeil(bu_reward * fRoundMultiplier);
		he_reward += RoundToCeil(he_reward * fRoundMultiplier);
	}
	int RestedAwardBonus = RoundToFloor(e_reward * fRestedExpMult);
	if (RestedAwardBonus >= RestedExperience[client]) {
		RestedAwardBonus = RestedExperience[client];
		RestedExperience[client] = 0;
	}
	else if (RestedAwardBonus < RestedExperience[client]) {
		RestedExperience[client] -= RestedAwardBonus;
	}
	int ExperienceBooster = RoundToFloor(e_reward * CheckExperienceBooster(client, e_reward));
	if (ExperienceBooster < 1) ExperienceBooster = 0;
	//new Float:TeammateBonus = 0.0;//(LivingSurvivors() - 1) * fSurvivorExpMult;
	int theCount = LivingSurvivorCount();
	if (theCount >= iSurvivorModifierRequired) {
		float TeammateBonus = (theCount - (iSurvivorModifierRequired - 1)) * fSurvivorExpMult;
		e_reward += RoundToCeil(TeammateBonus * e_reward);
		h_reward += RoundToCeil(TeammateBonus * h_reward);
		t_reward += RoundToCeil(TeammateBonus * t_reward);
		bu_reward += RoundToCeil(TeammateBonus * bu_reward);
		he_reward += RoundToCeil(TeammateBonus * he_reward);
	}
	if (IsGroupMember[client]) {
		e_reward += RoundToCeil(GroupMemberBonus * e_reward);
		h_reward += RoundToCeil(GroupMemberBonus * h_reward);
		t_reward += RoundToCeil(GroupMemberBonus * t_reward);
		bu_reward += RoundToCeil(GroupMemberBonus * bu_reward);
		he_reward += RoundToCeil(GroupMemberBonus * he_reward);
	}
	if (!BotsOnSurvivorTeam() && TotalHumanSurvivors() <= iSurvivorBotsBonusLimit) {
		e_reward += RoundToCeil(fSurvivorBotsNoneBonus * e_reward);
		h_reward += RoundToCeil(fSurvivorBotsNoneBonus * h_reward);
		t_reward += RoundToCeil(fSurvivorBotsNoneBonus * t_reward);
		bu_reward += RoundToCeil(fSurvivorBotsNoneBonus * bu_reward);
		he_reward += RoundToCeil(fSurvivorBotsNoneBonus * he_reward);
	}
	if (e_reward < 1) e_reward = 0;
	if (h_reward < 1) h_reward = 0;
	if (t_reward < 1) t_reward = 0;
	if (bu_reward < 1) bu_reward = 0;
	if (he_reward < 1) he_reward = 0;
	//h_reward = RoundToCeil(GetClassMultiplier(client, h_reward * 1.0, "hXP"));
	//t_reward = RoundToCeil(GetClassMultiplier(client, t_reward * 1.0, "tXP"));
	//if (!TheRoundHasEnded) {
	// Previously, if a player completed a round without ever leaving combat, they would receive no bonus container.
	if (iIsLevelingPaused[client] == 0) {
		// players who pause their levels don't earn bonus containers.
		BonusContainer[client]	+= e_reward;
		BonusContainer[client]	+= h_reward;
		BonusContainer[client]	+= t_reward;
		BonusContainer[client]	+= bu_reward;
		BonusContainer[client]	+= he_reward;
	}
	else BonusContainer[client] = 0;	// if the player enables it mid-match, this ensures the bonus container is always 0 for paused levelers.
	//	0 = Points Only
	//	1 = RPG Only
	//	2 - RPG + Points
	if (RPGMode > 0) {
		if (DisplayType > 0 && (infected == 0 || enemytype > 0)) {								// \x04Jockey \x01killed: \x04 \x03experience
			char rewardText[64];
			if (e_reward > 0) {
				AddCommasToString(e_reward, rewardText, sizeof(rewardText));
				if (infected > 0) PrintToChat(client, "%T", "base experience reward", client, orange, InfectedName, white, green, rewardText, blue);
				else if (infected == 0) PrintToChat(client, "%T", "damage experience reward", client, orange, green, white, green, rewardText, blue);
			}
			if (DisplayType == 2) {
				if (RestedAwardBonus > 0) {
					AddCommasToString(RestedAwardBonus, rewardText, sizeof(rewardText));
					PrintToChat(client, "%T", "rested experience reward", client, green, white, green, rewardText, blue);
				}
				if (ExperienceBooster > 0) {
					AddCommasToString(ExperienceBooster, rewardText, sizeof(rewardText));
					PrintToChat(client, "%T", "booster experience reward", client, green, white, green, rewardText, blue);
				}
			}
			if (t_reward > 0) {
				AddCommasToString(t_reward, rewardText, sizeof(rewardText));
				PrintToChat(client, "%T", "tanking experience reward", client, green, white, green, rewardText, blue);
			}
			if (h_reward > 0) {
				AddCommasToString(h_reward, rewardText, sizeof(rewardText));
				PrintToChat(client, "%T", "healing experience reward", client, green, white, green, rewardText, blue);
			}
			if (bu_reward > 0) {
				AddCommasToString(bu_reward, rewardText, sizeof(rewardText));
				PrintToChat(client, "%T", "buffing experience reward", client, green, white, green, rewardText, blue);
			}
			if (he_reward > 0) {
				AddCommasToString(he_reward, rewardText, sizeof(rewardText));
				PrintToChat(client, "%T", "hexing experience reward", client, green, white, green, rewardText, blue);
			}
		}
		int TotalExperienceEarned = (e_reward + RestedAwardBonus + ExperienceBooster + t_reward + h_reward + bu_reward + he_reward);
 		ExperienceLevel[client] += TotalExperienceEarned;
		ExperienceOverall[client] += TotalExperienceEarned;
		//GetProficiencyData(client, GetWeaponProficiencyType(client), TotalExperienceEarned);
		ConfirmExperienceAction(client, TheRoundHasEnded);
	}
	if (RPGMode >= 0 && RPGMode != 1 && p_reward > 0.0) {
		Points[client] += p_reward;
		if (DisplayType > 0 && (infected == 0 || enemytype > 0)) PrintToChat(client, "%T", "points from damage reward", client, green, white, green, p_reward, blue);
	}
	if (!TheRoundHasEnded) CheckKillPositions(client, true);
}

// Curious RPG System option?
// Points earned from hurting players used to unlock abilities, while experienced earned to increase level determines which abilities a player has access to.
// This way, even if the level is different, everyone starts with the same footing.
// Optional RPG System. Maybe call it "buy rpg mode?"

stock bool SameTeam_OnTakeDamage(int healer, int target, int iHealerAmount, bool IsDamageTalent = false,int  damagetype = -1) {
	if (!AllowShotgunToTriggerNodes(healer)) return false;
	if (HealImmunity[target] || bIsInCheckpoint[target]) return true;
	bool TheBool = IsMeleeAttacker(healer);
	if (TheBool && bIsMeleeCooldown[healer]) return true;
	//https://pastebin.com/tLLK9kZM
	if (damagetype & DMG_BULLET || damagetype & DMG_SLASH || damagetype & DMG_CLUB) {
		if (!TheBool) {
			iHealerAmount = RoundToCeil(GetAbilityStrengthByTrigger(healer, target, "hB", _, iHealerAmount, _, _, "d", 2, true, _, _, _, damagetype));
			iHealerAmount += RoundToCeil(GetAbilityStrengthByTrigger(healer, target, "hB", _, iHealerAmount, _, _, "healshot", 2, true, _, _, _, damagetype));
		}
		else {
			iHealerAmount = RoundToCeil(GetAbilityStrengthByTrigger(healer, target, "hM", _, iHealerAmount, _, _, "d", 2, true, _, _, _, damagetype));
			iHealerAmount += RoundToCeil(GetAbilityStrengthByTrigger(healer, target, "hM", _, iHealerAmount, _, _, "healmelee", 2, true, _, _, _, damagetype));
		}
	}
	else return true;
	if (iHealerAmount < 1) return true;
	if (iHealingPlayerInCombatPutInCombat == 1 && bIsInCombat[target]) {
		CombatTime[healer] = GetEngineTime() + fOutOfCombatTime;
		bIsInCombat[healer] = true;
	}
	if (TheBool) {
		bIsMeleeCooldown[healer] = true;				
		CreateTimer(0.5, Timer_IsMeleeCooldown, healer, TIMER_FLAG_NO_MAPCHANGE);
	}
	else GiveAmmoBack(healer, 1);
	HealImmunity[target] = true;
	CreateTimer(0.1, Timer_HealImmunity, target, TIMER_FLAG_NO_MAPCHANGE);
	HealPlayer(target, healer, iHealerAmount * 1.0, 'h', true);
	GetAbilityStrengthByTrigger(healer, target, "didHeals", _, iHealerAmount);
	GetAbilityStrengthByTrigger(target, healer, "wasHealed", _, iHealerAmount);
	// To prevent endless loops, we only call damage talents when the function is called directly from OnTakeDamage()
	if (IsDamageTalent) {
		GetAbilityStrengthByTrigger(healer, target, "d", FindZombieClass(healer), iHealerAmount);
		if (damagetype & DMG_CLUB) GetAbilityStrengthByTrigger(healer, target, "U", _, iHealerAmount);
		if (damagetype & DMG_SLASH) GetAbilityStrengthByTrigger(healer, target, "u", _, iHealerAmount);
	}
	if (LastAttackedUser[healer] == target) ConsecutiveHits[healer]++;
	else {
		LastAttackedUser[healer] = target;
		ConsecutiveHits[healer] = 0;
	}
	return true;
}

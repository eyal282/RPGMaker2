
#pragma newdecls required

public Action Timer_ZeroGravity(Handle timer, any client) {

	if (IsLegitimateClientAlive(client)) {

		ModifyGravity(client);
	}
	//ZeroGravityTimer[client] = INVALID_HANDLE;
	return Plugin_Stop;
}

public Action Timer_ResetCrushImmunity(Handle timer, any client) {

	if (IsLegitimateClient(client)) bIsCrushCooldown[client] = false;
	return Plugin_Stop;
}

public Action Timer_ResetBurnImmunity(Handle timer, any client) {

	if (IsLegitimateClient(client)) bIsBurnCooldown[client] = false;
	return Plugin_Stop;
}

public Action Timer_HealImmunity(Handle timer, any client) {

	if (IsLegitimateClient(client)) {

		HealImmunity[client] = false;
	}
	return Plugin_Stop;
}

public Action Timer_IsMeleeCooldown(Handle timer, any client) {

	if (IsLegitimateClient(client)) { bIsMeleeCooldown[client] = false; }
	return Plugin_Stop;
}

public Action Timer_ResetShotgunCooldown(Handle timer, any client) {
	if (IsLegitimateClient(client)) shotgunCooldown[client] = false;
	return Plugin_Stop;
}

bool VerifyMinimumRating(int client, bool setMinimumRating = false) {
	int minimumRating = RoundToCeil(BestRating[client] * fRatingFloor);
	if (setMinimumRating || Rating[client] < minimumRating) Rating[client] = minimumRating;
}

bool AllowShotgunToTriggerNodes(int client) {
	bool isshotgun = IsPlayerUsingShotgun(client);
	if (!isshotgun || isshotgun && !shotgunCooldown[client]) return true;
	return false;
}

stock void CheckDifficulty() {

	char Difficulty[64];
	FindConVar("z_difficulty").GetString(Difficulty, sizeof(Difficulty));
	if (!StrEqual(Difficulty, sServerDifficulty, false)) FindConVar("z_difficulty").SetString(sServerDifficulty);
}

stock void GiveProfileItems(int client) {

	if (hWeaponList[client].Length == 2) {
		char text[64];
		hWeaponList[client].GetString(0, text, sizeof(text));
		QuickCommandAccessEx(client, text, _, true);

		hWeaponList[client].GetString(1, text, sizeof(text));
		QuickCommandAccessEx(client, text, _, true);
	}
	else {
		hWeaponList[client].Resize(2);
		QuickCommandAccessEx(client, defaultLoadoutWeaponPrimary, _, true);
		QuickCommandAccessEx(client, defaultLoadoutWeaponSecondary, _, true);
	}
	if (SkyLevel[client] > 0) CreateTimer(0.5, Timer_GiveLaserBeam, client, TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_GiveLaserBeam(Handle timer, any client) {

	if (IsLegitimateClientAlive(client)) {

		ExecCheatCommand(client, "upgrade_add", "LASER_SIGHT");
	}
	return Plugin_Stop;
}

/*public Action:Timer_DisplayHUD(Handle:timer) {

	if (!b_IsActiveRound) return Plugin_Stop;
	iRotation = 0;
	for (new i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClientAlive(i) && !IsFakeClient(i)) {

			if (GetClientTeam(i) == TEAM_SURVIVOR) {

				DisplayHUD(i, iRotation);
				if (bIsGiveProfileItems[i]) {

					bIsGiveProfileItems[i] = false;
					GiveProfileItems(i);
				}
			}
			else if (GetClientTeam(i) == TEAM_INFECTED) DisplayInfectedHUD(i, iRotation);
		}
	}
	if (iRotation != 1) iRotation = 1;
	else iRotation = 0;

	return Plugin_Continue;
}*/

public Action Timer_CheckDifficulty(Handle timer) {

	CheckDifficulty();
	return Plugin_Continue;
}

public Action Timer_ShowHUD(Handle timer, any client) {
	if (!b_IsActiveRound || !IsLegitimateClient(client) || !bTimersRunning[client]) {
		return Plugin_Stop;
	}
	if (PlayerLevel[client] > iMaxLevel) SetTotalExperienceByLevel(client, iMaxLevel, true);
	TimePlayed[client]++;
	//if (TotalHumanSurvivors() < 1) RoundTime++;	// we don't count time towards enrage if there are no human survivors.
	char pct[10];
	Format(pct, sizeof(pct), "%");
	int ThisRoundTime = 0;
	ThisRoundTime = RPGRoundTime();
	int mymaxhealth = -1;
	float healregenamount = 0.0;
	//decl String:targetSteamID[64];
	if (iShowAdvertToNonSteamgroupMembers == 1 && !IsGroupMember[client]) {
		IsGroupMemberTime[client]++;
		if (IsGroupMemberTime[client] % iJoinGroupAdvertisement == 0) {
			PrintToChat(client, "%T", "join group advertisement", client, GroupMemberBonus * 100.0, pct, orange, blue, orange, blue, orange, blue, green, orange);
		}
	}

	playerTeam = 0;
	playerTeam = GetClientTeam(client);
	if (playerTeam == TEAM_SPECTATOR || (playerTeam == TEAM_SURVIVOR || !IsLegitimateClientAlive(client)) && !b_IsLoaded[client]) return Plugin_Continue;
	if (displayBuffOrDebuff[client] != 1) displayBuffOrDebuff[client] = 1;
	else displayBuffOrDebuff[client] = 0;
	if (!IsFakeClient(client)) DisplayHUD(client, displayBuffOrDebuff[client]);
	if (bIsGiveProfileItems[client]) {
		bIsGiveProfileItems[client] = false;
		GiveProfileItems(client);
	}
	if ((playerTeam == TEAM_SURVIVOR) && CurrentRPGMode >= 1) {
		healregenamount = 0.0;				
		mymaxhealth = GetMaximumHealth(client);
		if (ThisRoundTime < iEnrageTime && L4D2_GetInfectedAttacker(client) == -1) {
			healregenamount = GetAbilityStrengthByTrigger(client, _, "p", _, 0, _, _, "h");	// activator, target, trigger ability, effects, zombieclass, damage
			if (healregenamount > 0.0) HealPlayer(client, client, healregenamount, 'h', true);
		}
		ModifyHealth(client, GetAbilityStrengthByTrigger(client, client, "p", _, 0, _, _, "H"), 0.0);
		if (GetClientHealth(client) > mymaxhealth) SetEntityHealth(client, mymaxhealth);
	}
	if (playerTeam != TEAM_SPECTATOR) {
		GetAbilityStrengthByTrigger(client, client, "p");	// adding support for any type of passive.
	}
	RemoveStoreTime(client);
	LastPlayLength[client]++;
	if (ReadyUpGameMode != 3 && CurrentRPGMode >= 1 && ThisRoundTime >= iEnrageTime) {
		if (SurvivorEnrage[client][1] == 0.0) {
			EnrageBlind(client, 100);
			SurvivorEnrage[client][1] = 1.0;
		}
		else {
			SurvivorEnrage[client][1] = 0.0;
		}
	}
	/*for (new i = 1; i <= MaxClients; i++) {
		if (IsLegitimateClientAlive(i) && GetClientTeam(i) == TEAM_INFECTED && FindZombieClass(i) == ZOMBIECLASS_TANK) {
			if (IsClientInRangeSpecialAmmo(i, "W") == -2.0) IsDark = true;
			else IsDark = false;
			if (IsSpecialCommonInRange(i, 'w')) IsWeak = true;
			else IsWeak = false;
			if (IsWeak && IsDark) {
				Handle:TankState_Array[i].Clear();
				SetEntityRenderMode(i, RENDER_TRANSCOLOR);
				SetEntityRenderColor(i, 255, 255, 255, 200);
			}
		}
	}*/

	return Plugin_Continue;
}

stock LedgedSurvivors() {

	int count = 0;
	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClientAlive(i) && GetClientTeam(i) == TEAM_SURVIVOR && IsLedged(i)) count++;
	}
	return count;
}

stock bool NoLivingHumanSurvivors() {
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i) || IsFakeClient(i) || GetClientTeam(i) != TEAM_SURVIVOR || !IsPlayerAlive(i)) continue;
		return false;
	}
	return true;
}

stock bool NoHealthySurvivors(bool bMustNotBeABot = false) {

	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClientAlive(i) || IsIncapacitated(i) || GetClientTeam(i) != TEAM_SURVIVOR) continue;
		if (bMustNotBeABot && IsFakeClient(i)) continue;
		return false;
	}
	return true;
}

stock HumanSurvivors() {

	int count = 0;
	for (int i = 1; i <= MaxClients; i++) {

		if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == TEAM_SURVIVOR) count++;
	}
	return count;
}

public Action Timer_TeleportRespawn(Handle timer, any client) {

	if (b_IsActiveRound && IsLegitimateClient(client)) {

		int target = MyRespawnTarget[client];

		if (target != client && IsLegitimateClientAlive(target)) {

			GetClientAbsOrigin(target, DeathLocation[target]);
			TeleportEntity(client, DeathLocation[target], NULL_VECTOR, NULL_VECTOR);
			MyRespawnTarget[client] = client;
		}
		else TeleportEntity(client, DeathLocation[client], NULL_VECTOR, NULL_VECTOR);
	}
	return Plugin_Stop;
}

public Action Timer_GiveMaximumHealth(Handle timer, any client) {

	if (IsLegitimateClientAlive(client)) {

		GiveMaximumHealth(client);		// So instant heal doesn't put a player above their maximum health pool.
	}

	return Plugin_Stop;
}

public Action Timer_DestroyCombustion(Handle timer, any entity)
{
	if (!IsValidEntity(entity)) return Plugin_Stop;
	AcceptEntityInput(entity, "Kill");
	return Plugin_Stop;
}

/*public Action:Timer_DestroyDiscoveryItem(Handle:timer, any:entity) {

	if (IsValidEntity(entity)) {

		new client				= FindAnyRandomClient();

		if (client == -1) return Plugin_Stop;

		decl String:EName[64];
		GetEntPropString(entity, Prop_Data, "m_iName", EName, sizeof(EName));
		if (StrEqual(EName, "slate") || IsStoreItem(client, EName) || IsTalentExists(EName)) {

			if (!AcceptEntityInput(entity, "Kill")) RemoveEdict(entity);
		}
	}

	return Plugin_Stop;
}*/

public Action Timer_SlowPlayer(Handle timer, any client) {

	if (IsLegitimateClientAlive(client)) {

		SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", SpeedMultiplierBase[client]);
	}
	//SlowMultiplierTimer[client] = INVALID_HANDLE;
	return Plugin_Stop;
}

stock GetTimePlayed(client, char s[], size) {
	int seconds = TimePlayed[client];
	int minutes = 0;
	int hours = 0;
	int days = 0;
	while (seconds >= 86400) {
		days++;
		seconds -= 86400;
	}
	while (seconds >= 3600) {
		hours++;
		seconds -= 3600;
	}
	while (seconds >= 60) {
		minutes++;
		seconds -= 60;
	}
	Format(s, size, "%d Days, %d Hours, %d Minutes, %d Second(s)", days, hours, minutes, seconds);
}

/*public Action:Timer_AwardSkyPoints(Handle:timer) {

	if (!b_IsActiveRound) return Plugin_Stop;

	for (new i = 1; i <= MaxClients; i++) {

		if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) != TEAM_SPECTATOR) {

			CheckSkyPointsAward(i);
		}
	}

	return Plugin_Continue;
}

stock CheckSkyPointsAward(int client) {

	new SkyPointsAwardTime		=	GetConfigValueInt("sky points awarded _");
	new SkyPointsAwardValue		=	GetConfigValueInt("sky points time required?");
	new SkyPointsAwardAmount	=	GetConfigValueInt("sky points award amount?");

	new seconds					=	0;
	new minutes					=	0;
	new hours					=	0;
	new days					=	0;
	new oldminutes				=	0;
	new oldhours				=	0;
	new olddays					=	0;

	seconds				=	TimePlayed[client];
	while (seconds >= 86400) {

		olddays++;
		seconds -= 86400;
	}
	while (seconds >= 3600) {

		oldhours++;
		seconds -= 3600;
	}
	while (seconds >= 60) {

		oldminutes++;
		seconds -= 60;
	}

	TimePlayed[client]++;

	seconds = TimePlayed[client];

	while (seconds >= 86400) {

		days++;
		seconds -= 86400;
	}
	while (seconds >= 3600) {

		hours++;
		seconds -= 3600;
	}
	while (seconds >= 60) {

		minutes++;
		seconds -= 60;

	}
	if (SkyPointsAwardTime == 2 && days != olddays && days % SkyPointsAwardValue == 0) AwardSkyPoints(client, SkyPointsAwardAmount);
	if (SkyPointsAwardTime == 1 && hours != oldhours && hours % SkyPointsAwardValue == 0) AwardSkyPoints(client, SkyPointsAwardAmount);
	if (SkyPointsAwardTime == 0 && minutes != oldminutes && minutes % SkyPointsAwardValue == 0) AwardSkyPoints(client, SkyPointsAwardAmount);
}*/

/*public Action:Timer_SpeedIncrease(Handle:timer, any:client) {

	if (IsLegitimateClientAlive(client)) {

		SpeedIncrease(client);
	}
	//SpeedMultiplierTimer[client] = INVALID_HANDLE;
	return Plugin_Stop;
}*/

public Action Timer_BlindPlayer(Handle timer, any client) {

	if (IsLegitimateClient(client)) BlindPlayer(client);
	return Plugin_Stop;
}

public Action Timer_FrozenPlayer(Handle timer, any client) {

	if (IsLegitimateClient(client)) FrozenPlayer(client, _, 0);
	return Plugin_Stop;
}

stock float GetActiveZoomTime(int client) {
	int listClient = 0;
	float activeZoomTimeTime = 0.0;
	float activeZoomTime = GetEngineTime();
	for (int i = 0; i < zoomCheckList.Length; i++) {
		listClient = zoomCheckList.Get(i, 0);
		if (client != listClient) continue;
		activeZoomTimeTime = zoomCheckList.Get(i, 1);
		activeZoomTime -= activeZoomTimeTime;
		return activeZoomTime;
	}
	return 0.0;
}

stock bool isQuickscopeKill(int client) {
	int listClient = 0;
	float fClientHoldingFireTime = 0.0;
	float killDelayAfterScope = GetEngineTime();
	for (int i = 0; i < zoomCheckList.Length; i++) {
		listClient = zoomCheckList.Get(i, 0);
		if (client != listClient) continue;
		fClientHoldingFireTime = zoomCheckList.Get(i, 1);
		killDelayAfterScope -= fClientHoldingFireTime;
		if (killDelayAfterScope <= fquickScopeTime) return true;
		return false;
	}
	return false;
}

stock zoomCheckToggle(client, bool insert = false) {
	int listClient = 0;
	for (int i = 0; i < zoomCheckList.Length; i++) {
		listClient = zoomCheckList.Get(i, 0);
		if (client != listClient) continue;
		if (insert) return;
		// The user is unscoping so we remove them from the array.
		zoomCheckList.Erase(i);
	}
	if (insert) {
		// we don't even get here if the user is already in the list.
		int size = zoomCheckList.Length;
		zoomCheckList.Resize(size + 1);
		zoomCheckList.Set(size, client, 0);
		zoomCheckList.Set(size, GetEngineTime(), 1);
	}
	return;
}

public Action Timer_ZoomcheckDelayer(Handle timer, any client) {
	if (!IsLegitimateClient(client)) return Plugin_Stop;
	if (IsPlayerZoomed(client)) {
		// trigger nodes that fire when a player zooms in (like effects over time)
		zoomCheckToggle(client, true);
	}
	else zoomCheckToggle(client);
	ZoomcheckDelayer[client] = INVALID_HANDLE;
	return Plugin_Stop;
}

stock float GetHoldingFireTime(int client) {
	int listClient = 0;
	float fClientHoldingFireTime = 0.0;
	float holdingFireTime = GetEngineTime();
	for (int i = 0; i < holdingFireList.Length; i++) {
		listClient = holdingFireList.Get(i, 0);
		if (listClient != client) continue;
		fClientHoldingFireTime = holdingFireList.Get(i, 1);
		holdingFireTime -= fClientHoldingFireTime;
		return holdingFireTime;
	}
	return 0.0;
}

stock holdingFireCheckToggle(client, bool insert = false) {
	int listClient = 0;
	for (int i = 0; i < holdingFireList.Length; i++) {
		listClient = holdingFireList.Get(i, 0);
		if (listClient != client) continue;
		if (insert) return;
		// The user is unscoping so we remove them from the array.
		holdingFireList.Erase(i);
	}
	if (insert) {
		// we don't even get here if the user is already in the list.
		int size = holdingFireList.Length;
		holdingFireList.Resize(size + 1);
		holdingFireList.Set(size, client, 0);
		holdingFireList.Set(size, GetEngineTime(), 1);
	}
	return;
}

/*public Action:Timer_HoldingFireDelayer(Handle:timer, any:client) {
	if (!IsLegitimateClient(client)) return Plugin_Stop;
	new weaponEntity = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
	new bulletsRemaining = 0;
	if (IsValidEntity(weaponEntity)) bulletsRemaining = GetEntProp(weaponEntity, Prop_Send, "m_iClip1");
	if (bulletsRemaining > 0 && GetEntProp(weaponEntity, Prop_Data, "m_bInReload") != 1 && L4D2_GetInfectedAttacker(client) == -1) {
		// trigger nodes that fire when a player zooms in (like effects over time)
		holdingFireCheckToggle(client, true);
	}
	else holdingFireCheckToggle(client);
	holdingFireDelayer[client] = INVALID_HANDLE;
	return Plugin_Stop;
}*/

public Action Timer_Blinder(Handle timer, any client) {

	if (ISBLIND[client] == INVALID_HANDLE) return Plugin_Stop;

	if (!b_IsActiveRound || !IsLegitimateClient(client) || !IsSpecialCommonInRange(client, 'l')) {

		BlindPlayer(client);
		KillTimer(ISBLIND[client]);
		ISBLIND[client] = INVALID_HANDLE;
		//delete ISBLIND[client];
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action Timer_Freezer(Handle timer, any client) {
	if (!b_IsActiveRound || !IsLegitimateClient(client) || !IsPlayerAlive(client) || !IsSpecialCommonInRange(client, 'r')) {
		/*

			If the client is scorched, they no longer freeze.
		*/
		//KillTimer(ISFROZEN[client]);
		ISFROZEN[client] = INVALID_HANDLE;
		FrozenPlayer(client, _, 0);
		return Plugin_Stop;
	}
	float Velocity[3];
	SetEntityMoveType(client, MOVETYPE_WALK);
	Velocity[0]	=	GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
	Velocity[1]	=	GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");
	Velocity[2]	=	GetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]");
	Velocity[2] += 32.0;
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, Velocity);
	SetEntityMoveType(client, MOVETYPE_NONE);
	return Plugin_Continue;
}

public ReadyUp_FwdChangeTeam(client, team) {

	if (IsLegitimateClient(client)) {

		if (team == TEAM_SURVIVOR) {

			ChangeHook(client, true);
			if (!b_IsLoading[client] && !b_IsLoaded[client]) OnClientLoaded(client);
		}
		else if (team != TEAM_SURVIVOR) {

			//LogToFile(LogPathDirectory, "%N is no longer a survivor, unhooking.", client);
			if (bIsInCombat[client]) {

				IncapacitateOrKill(client, _, _, true, false, true);
			}
			ChangeHook(client);
		}
	}
}

stock ChangeHook(client, bool bHook = false) {

	b_IsHooked[client] = bHook;
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	if (b_IsHooked[client]) SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

/*public ReadyUp_FwdChangeTeam(client, team) {

	if (team != TEAM_SURVIVOR) {

		if (bIsInCombat[client]) {

			IncapacitateOrKill(client, _, _, true, false, true);
		}

		b_IsHooked[client] = false;
		SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	}
	else if (team == TEAM_SURVIVOR && !b_IsHooked[client]) {

		b_IsHooked[client] = true;
		SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	}
}*/

public Action Timer_DetectGroundTouch(Handle timer, any client) {

	if (IsClientHuman(client) && IsPlayerAlive(client)) {

		if (GetClientTeam(client) == TEAM_SURVIVOR && !(GetEntityFlags(client) & FL_ONGROUND) && b_IsJumping[client] && L4D2_GetInfectedAttacker(client) == -1 && !AnyTanksNearby(client)) return Plugin_Continue;
		b_IsJumping[client] = false;
		ModifyGravity(client);
	}
	return Plugin_Stop;
}

public Action Timer_ResetGravity(Handle timer, any client) {

	if (IsLegitimateClientAlive(client)) ModifyGravity(client);
	return Plugin_Stop;
}

public Action Timer_CloakingDeviceBreakdown(Handle timer, any client) {

	if (IsLegitimateClientAlive(client)) {

		SetEntityRenderMode(client, RENDER_NORMAL);
		SetEntityRenderColor(client, 255, 255, 255, 255);
	}
	return Plugin_Stop;
}

public Action Timer_ResetPlayerHealth(Handle timer, any client) {

	if (IsLegitimateClientAlive(client)) {

		LoadHealthMaximum(client);
		GiveMaximumHealth(client);
	}
	return Plugin_Stop;
}

/*public Action:Timer_RemoveImmune(Handle:timer, Handle:packy) {

	packy.Reset();
	new client			=	packy.ReadCell();
	new pos				=	packy.ReadCell();
	new owner			=	packy.ReadCell();

	if (client != -1 && IsClientActual(client) && !IsFakeClient(client)) {

		PlayerAbilitiesImmune[client].SetString(pos, "0");
	}
	else {

		PlayerAbilitiesImmune_Bots.SetString(pos, "0");
	}
	if (IsLegitimateClient(owner)) PlayerAbilitiesImmune[owner][client].SetString(pos, "0");

	return Plugin_Stop;
}*/


stock ResetCDImmunity(int client) {

	int size = 0;
	/*for (new i = 1; i <= MaxClients; i++) {

		if (!IsLegitimateClient(i)) continue;

		size = PlayerAbilitiesImmune[client][i].Length;
		for (new y = 0; y < size; y++) {

			PlayerAbilitiesImmune[client][i].SetString(y, "0");
		}
	}*/

	/*for (new i = 1; i <= MAXPLAYERS; i++) {

		//if (!IsLegitimateClient(i)) continue;
		for (new y = 1; y <= MAXPLAYERS; y++) {

			//if (!IsLegitimateClient(y)) continue;
			size = PlayerAbilitiesImmune[i][y].Length;
			for (new z = 0; z < size; z++) {

				PlayerAbilitiesImmune[i][y].SetString(z, "0");
			}
		}
	}*/

	if (IsLegitimateClient(client)) {

		size = PlayerAbilitiesCooldown[client].Length;
		for (int i = 0; i < size; i++) {

			PlayerAbilitiesCooldown[client].SetString(i, "0");
		}
		/*size = PlayerAbilitiesImmune[client].Length;
		for (new i = 0; i < size; i++) {

			PlayerAbilitiesImmune[client].SetString(i, "0");
		}*/
	}
	else if (client == -1) {

		size = PlayerAbilitiesCooldown_Bots.Length;
		for (int i = 0; i < size; i++) {

			PlayerAbilitiesCooldown_Bots.SetString(i, "0");
		}
		size = PlayerAbilitiesImmune_Bots.Length;
		for (int i = 0; i < size; i++) {

			PlayerAbilitiesImmune_Bots.SetString(i, "0");
		}
	}
}

/*public Action:Timer_CreateCooldown(Handle:timer, Handle:packttt) {

	packttt.Reset();
	new client				=	packttt.ReadCell();
	decl char[] TalentName[64];
	packttt.ReadString(TalentName, sizeof(TalentName));
	new Float:f_Cooldown	= packttt.ReadFloat();

	if (IsLegitimateClientAlive(client)) {

		CreateCooldown(client, GetTalentPosition(client, TalentName), f_Cooldown);
	}

	return Plugin_Stop;
}*/

/*public Action:Timer_IsIncapacitated(Handle:timer, any:client) {
	if (IsLegitimateClientAlive(client) && IsIncapacitated(client)) {
		new attacker = L4D2_GetInfectedAttacker(client);
		if (attacker == -1) GetAbilityStrengthByTrigger(client, attacker, "n", _, 0);
		else {
			GetAbilityStrengthByTrigger(attacker, client, "M");
			GetAbilityStrengthByTrigger(client, attacker, "N");
		}
	}
	return Plugin_Stop;
}*/

public Action Timer_Slow(Handle timer, any client) {
	if (!IsLegitimateClient(client)) return Plugin_Stop;
	if (!b_IsActiveRound || !IsPlayerAlive(client) || ISSLOW[client] == INVALID_HANDLE) {
		SetSpeedMultiplierBase(client);
		fSlowSpeed[client] = 1.0;
		KillTimer(ISSLOW[client]);
		ISSLOW[client] = INVALID_HANDLE;
		return Plugin_Stop;
	}
	//SetEntityMoveType(client, MOVETYPE_WALK);
	SetSpeedMultiplierBase(client);
	fSlowSpeed[client] = 1.0;
	return Plugin_Stop;
}

public Action Timer_Explode(Handle timer, Handle packagey) {

	packagey.Reset();

	int client 		= packagey.ReadCell();
	if (!IsLegitimateClientAlive(client)) {

		ISEXPLODETIME[client] = 0.0;
		KillTimer(ISEXPLODE[client]);
		ISEXPLODE[client] = INVALID_HANDLE;
		//delete ISBLIND[client];
		//delete packagey;
		return Plugin_Stop;
	}

	float ClientPosition[3];
	GetClientAbsOrigin(client, ClientPosition);

	float flStrengthAura = packagey.ReadCell() * 1.0;
	float flStrengthTarget = packagey.ReadFloat();
	float flStrengthLevel = packagey.ReadFloat();
	float flRangeMax = packagey.ReadFloat();
	float flDeathMultiplier = packagey.ReadFloat();
	float flDeathBaseTime = packagey.ReadFloat();
	float flDeathInterval = packagey.ReadFloat();
	float flDeathMaxTime = packagey.ReadFloat();
	char StAuraColour[64];
	char StAuraPos[64];
	packagey.ReadString(StAuraColour, sizeof(StAuraColour));
	packagey.ReadString(StAuraPos, sizeof(StAuraPos));
	int iLevelRequired = packagey.ReadCell();

	int NumLivingEntities = LivingEntitiesInRange(client, ClientPosition, flRangeMax);

	if (!b_IsActiveRound || !IsLegitimateClient(client) || IsLegitimateClient(client) && !IsPlayerAlive(client) || ISEXPLODETIME[client] >= flDeathBaseTime && NumLivingEntities < 1 || ISEXPLODETIME[client] >= flDeathMaxTime) {

		ISEXPLODETIME[client] = 0.0;
		KillTimer(ISEXPLODE[client]);
		ISEXPLODE[client] = INVALID_HANDLE;
		//delete ISBLIND[client];
		//delete packagey;
		return Plugin_Stop;
	}
	float flStrengthTotal = flStrengthAura + ((flStrengthTarget * NumLivingEntities) + (flStrengthLevel * PlayerLevel[client]));

	float TargetPosition[3];
	flStrengthTotal *= flDeathMultiplier;

	if (FindZombieClass(client) == ZOMBIECLASS_TANK && IsCoveredInBile(client)) {

		ISEXPLODETIME[client] += flDeathInterval;
		return Plugin_Continue;
	}
	CreateRing(client, flRangeMax, StAuraColour, StAuraPos);
	CreateExplosion(client);
	ScreenShake(client);
	int ReflectDebuff = 0;
	if (IsClientInRangeSpecialAmmo(client, "d") == -2.0) flStrengthTotal += (flStrengthTotal * IsClientInRangeSpecialAmmo(client, "d", false, _, flStrengthTotal));
	if (IsClientInRangeSpecialAmmo(client, "E") == -2.0) flStrengthTotal += (flStrengthTotal * IsClientInRangeSpecialAmmo(client, "E", false, _, flStrengthTotal));
	if (IsClientInRangeSpecialAmmo(client, "D") == -2.0) flStrengthTotal = (flStrengthTotal * (1.0 - IsClientInRangeSpecialAmmo(client, "D", false, _, flStrengthTotal)));

	int DamageValue = RoundToCeil(flStrengthTotal);
	SetClientTotalHealth(client, DamageValue);

	for (int i = 1; i <= MaxClients; i++) {

		if (!IsLegitimateClientAlive(i) || i == client) continue;
		if (GetClientTeam(i) == TEAM_SURVIVOR && PlayerLevel[i] < iLevelRequired) continue;	// we add infected later.

		GetClientAbsOrigin(i, TargetPosition);
		if (GetVectorDistance(ClientPosition, TargetPosition) > (flRangeMax / 2)) continue;

		CreateExplosion(i);	// boom boom audio and effect on the location.
		if (!IsFakeClient(i)) ScreenShake(i);

		//if (DamageValue > GetClientHealth(i)) IncapacitateOrKill(i);
		//else SetEntityHealth(i, GetClientHealth(i) - DamageValue);
		if (GetClientTeam(i) == TEAM_SURVIVOR) {

			if (IsClientInRangeSpecialAmmo(i, "D") == -2.0) SetClientTotalHealth(i, RoundToCeil(DamageValue * (1.0 - IsClientInRangeSpecialAmmo(i, "D", false, _, DamageValue * 1.0))));
			else SetClientTotalHealth(i, DamageValue);
			if (IsClientInRangeSpecialAmmo(i, "R") == -2.0) {

				ReflectDebuff = RoundToCeil(DamageValue * IsClientInRangeSpecialAmmo(i, "R", false, _, DamageValue * 1.0));
				SetClientTotalHealth(client, ReflectDebuff);
				CreateAndAttachFlame(i, ReflectDebuff, 3.0, 0.5, i, "reflect");
			}
		}
		else if (GetClientTeam(i) == TEAM_INFECTED) {

			if (IsSpecialCommonInRange(i, 'd')) {

				if (IsClientInRangeSpecialAmmo(client, "D") == -2.0) {

					ReflectDebuff = RoundToCeil(DamageValue * (1.0 - IsClientInRangeSpecialAmmo(client, "D", false, _, DamageValue * 1.0)));
					CreateAndAttachFlame(client, ReflectDebuff, 3.0, 0.5, i, "reflect");
				}
				else CreateAndAttachFlame(client, DamageValue, 3.0, 0.5, i, "reflect");
			}
			else AddSpecialInfectedDamage(client, i, DamageValue);
		}
	}
	int ent = -1;
	int SuperReflect = 0;
	char AuraEffect[10];
	bool entityIsSpecialCommon;
	for (int i = 0; i < CommonInfected.Length; i++) {
		ent = CommonInfected.Get(i);
		if (!IsCommonInfected(ent)) continue;
		entityIsSpecialCommon = IsSpecialCommon(ent);
		if (ent == client || entityIsSpecialCommon) continue;
		GetEntPropVector(ent, Prop_Send, "m_vecOrigin", TargetPosition);
		if (GetVectorDistance(ClientPosition, TargetPosition) > (flRangeMax / 2) || IsSpecialCommonInRange(ent, 'd')) continue;

		if (!entityIsSpecialCommon) AddCommonInfectedDamage(client, ent, DamageValue);
		else {
			// We check what kind of special common the entity is
			GetCommonValueAtPos(AuraEffect, sizeof(AuraEffect), ent, SUPER_COMMON_AURA_EFFECT);
			if (StrContains(AuraEffect, "d", true) == -1 || IsClientInRangeSpecialAmmo(client, "R") == -2.0) {
				if (IsClientInRangeSpecialAmmo(client, "R") == -2.0) AddSpecialCommonDamage(client, ent, RoundToCeil(DamageValue * IsClientInRangeSpecialAmmo(client, "R", false, _, DamageValue * 1.0)));
				else AddSpecialCommonDamage(client, ent, DamageValue);
			}
			else {	// if a player tries to reflect damage at a reflector, it's moot (ie reflects back to the player) so in this case the player takes double damage, though that's after mitigations.
				if (IsClientInRangeSpecialAmmo(client, "D") == -2.0) {
					SuperReflect = RoundToCeil(DamageValue * (1.0 - IsClientInRangeSpecialAmmo(client, "D", false, _, DamageValue * 1.0)));
					SetClientTotalHealth(client, SuperReflect);
					ReceiveCommonDamage(client, ent, SuperReflect);
				}
				else {
					SetClientTotalHealth(client, DamageValue);
					ReceiveCommonDamage(client, ent, DamageValue);
				}
			}
		}
	}
	for (int i = 0; i < WitchList.Length; i++) {

		ent = WitchList.Get(i);
		if (ent == client || !IsWitch(ent)) continue;
		GetEntPropVector(ent, Prop_Send, "m_vecOrigin", TargetPosition);
		if (GetVectorDistance(ClientPosition, TargetPosition) > (flRangeMax / 2)) continue;
		if (!IsSpecialCommonInRange(ent, 'd')) AddWitchDamage(client, ent, DamageValue);
		else {
			SetClientTotalHealth(client, DamageValue);
			ReceiveWitchDamage(client, ent, DamageValue);
		}
	}
	ISEXPLODETIME[client] += flDeathInterval;

	return Plugin_Continue;
}

public Action Timer_IsNotImmune(Handle timer, any client) {

	if (IsLegitimateClient(client)) b_IsImmune[client] = false;
	return Plugin_Stop;
}

public Action Timer_CheckIfHooked(Handle timer) {

	if (!b_IsActiveRound) {
		iSurvivalCounter = 0;
		return Plugin_Stop;
	}
	CurRPG = -2;
	LivingSerfs = 0;
	LivingSerfs = LivingSurvivors();
	RoundSeconds = 0;
	RoundSeconds = RPGRoundTime(true);
	if (IsSurvivalMode) {
		iSurvivalCounter++;
		if (iSurvivalCounter >= iSurvivalRoundTime) {

			for (int i = 1; i <= MaxClients; i++) {

				if (IsLegitimateClient(i)) {
					if (GetClientTeam(i) == TEAM_SURVIVOR) {
						IsSpecialAmmoEnabled[i][0] = 0.0;
						if (IsPlayerAlive(i)) AwardExperience(i, _, _, true);
						else Defibrillator(i, _, true);
					}
				}
			}
			iSurvivalCounter = 0;
			bIsSettingsCheck = true;
		}
	}
	if (RoundSeconds % HostNameTime == 0) {
		PrintToChatAll("%t", "playing in server name", orange, blue, Hostname, orange, blue, MenuCommand, orange);
	}
	if (SurvivorsSaferoomWaiting()) SurvivorBotsRegroup();
	if (TotalHumanSurvivors() >= 1 &&
		(iEndRoundIfNoHealthySurvivors == 1 && (LivingSerfs == LedgedSurvivors() || NoHealthySurvivors())) || LivingSerfs < 1 || NoLivingHumanSurvivors()) {
		// scenario will not end if there are bots alive because dead players can take control of them.
		ForceServerCommand("scenario_end");
		CallRoundIsOver();
		return Plugin_Stop;
	}
	char text[64];
	int secondsUntilEnrage = GetSecondsUntilEnrage();
	if (!IsSurvivalMode && iEnrageTime > 0 && RoundSeconds > 0 && RPGRoundTime() < iEnrageTime && (secondsUntilEnrage <= 300 && (secondsUntilEnrage % 60 == 0 || secondsUntilEnrage == 30 || secondsUntilEnrage <= 3) || (RoundSeconds % iEnrageAdvertisement) == 0)) {
		TimeUntilEnrage(text, sizeof(text));
		PrintToChatAll("%t", "enrage in...", orange, green, text, orange);
	}
	if (CurRPG == -2) CurRPG = iRPGMode;
	for (int i = 1; i <= MaxClients; i++) {
		if (CurRPG < 1 || !IsLegitimateClientAlive(i) || GetClientTeam(i) != TEAM_SURVIVOR) continue;
		if (PlayerHasWeakness(i)) {
			SetEntityRenderMode(i, RENDER_TRANSCOLOR);
			SetEntityRenderColor(i, 0, 0, 0, 255);
			SetEntProp(i, Prop_Send, "m_bIsOnThirdStrike", 1);
			if (!IsFakeClient(i)) EmitSoundToClient(i, "player/heartbeatloop.wav");
		}
		else {
			SetEntityRenderMode(i, RENDER_NORMAL);
			SetEntityRenderColor(i, 255, 255, 255, 255);
			if (!IsFakeClient(i)) StopSound(i, SNDCHAN_AUTO, "player/heartbeatloop.wav");
			SetEntProp(i, Prop_Send, "m_bIsOnThirdStrike", 0);
		}
	}
	return Plugin_Continue;
}

public Action Timer_Doom(Handle timer) {

	if (!b_IsActiveRound || DoomSUrvivorsRequired == 0) {

		DoomTimer = 0;
		return Plugin_Stop;
	}
	int SurvivorCount = LivingSurvivors();
	if (DoomSUrvivorsRequired == -1 && SurvivorCount != TotalSurvivors() ||
		DoomSUrvivorsRequired > 0 && SurvivorCount < DoomSUrvivorsRequired) {

		if (DoomTimer == 0) PrintToChatAll("%t", "you are doomed", orange);
		DoomTimer++;
	}
	else DoomTimer = 0;

	if (DoomTimer >= DoomKillTimer) {

		for (int i = 1; i <= MaxClients; i++) {

			if (IsLegitimateClientAlive(i) && GetClientTeam(i) == TEAM_SURVIVOR) {

				if (IsClientInRangeSpecialAmmo(i, "C", true) == -2.0) continue;
				HealingContribution[i] = 0;
				PointsContribution[i] = 0.0;
				TankingContribution[i] = 0;
				DamageContribution[i] = 0;
				BuffingContribution[i] = 0;
				HexingContribution[i] = 0;

				ForcePlayerSuicide(i);
			}
		}
		if (DoomTimer == DoomKillTimer) PrintToChatAll("%t", "survivors are doomed", orange);
		if (LivingHumanSurvivors() < 1) return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action Timer_TankCooldown(Handle timer) {

	float Counter								=	0.0;

	if (!b_IsActiveRound) {

		Counter											=	0.0;
		return Plugin_Stop;
	}
	Counter												+=	1.0;
	f_TankCooldown										-=	1.0;
	if (f_TankCooldown < 1.0) {

		Counter											=	0.0;
		f_TankCooldown									=	-1.0;
		for (int i = 1; i <= MaxClients; i++) {

			if (IsClientInGame(i) && !IsFakeClient(i) && (GetClientTeam(i) == TEAM_INFECTED || ReadyUp_GetGameMode() != 2)) {

				PrintToChat(i, "%T", "Tank Cooldown Complete", i, orange, white);
			}
		}

		return Plugin_Stop;
	}
	if (Counter >= fVersusTankNotice) {

		Counter											=	0.0;
		for (int i = 1; i <= MaxClients; i++) {

			if (IsClientInGame(i) && !IsFakeClient(i) && (GetClientTeam(i) == TEAM_INFECTED || ReadyUp_GetGameMode() != 2)) {

				PrintToChat(i, "%T", "Tank Cooldown Remaining", i, green, f_TankCooldown, white, orange, white);
			}
		}
	}

	return Plugin_Continue;
}

stock GetSuperCommonLimit() {
	return RoundToCeil((AllowedCommons + RaidCommonBoost()) * fSuperCommonLimit);
}

stock GetCommonQueueLimit() {
	return RoundToCeil((AllowedCommons + RaidCommonBoost()) * fCommonQueueLimit);
}

public Action Timer_SettingsCheck(Handle timer) {

	if (!b_IsActiveRound) {

		FindConVar("z_common_limit").SetInt(0);	// no commons unless active round.
		return Plugin_Stop;
	}

	RaidLevelCounter		= 0;
	bool bIsEnrage = false;
	//RageCommonLimit		= 0;

	if (!bIsSettingsCheck) return Plugin_Continue;
	bIsSettingsCheck = false;

	//if (!IsSurvivalMode) 
	//if (!IsSurvivalMode) 
	if (iTankRush != 1 || b_IsFinaleActive) {

		RaidLevelCounter = RaidCommonBoost();

		// we force a common limit on the tank rush servers
		if (iTankRush == 1 && RaidLevelCounter < 30) RaidLevelCounter = 30;
	}
	else RaidLevelCounter = 0;
	//else RaidLevelCounter = 0;
	//else RaidLevelCounter = 0;

	if (AllowedPanicInterval - RaidLevelCounter < 60) AllowedPanicInterval = 60;

	bIsEnrage = IsEnrageActive();

	int CommonAllowed = (AllowedCommons + RaidLevelCounter);
	if (bIsEnrage) RaidLevelCounter = RoundToCeil(fEnrageMultiplier * RaidLevelCounter);
	if (CommonAllowed <= iCommonsLimitUpper || bIsEnrage) FindConVar("z_common_limit").IntValue = AllowedCommons + RaidLevelCounter;
	else FindConVar("z_common_limit").SetInt(iCommonsLimitUpper);
	if (iTankRush != 1) FindConVar("z_reserved_wanderers").IntValue = RaidLevelCounter;
	else {

		//if (AllowedCommons + RaidLevelCounter)

		FindConVar("z_reserved_wanderers").SetInt(0);
		FindConVar("director_always_allow_wanderers").IntValue = 0;
	}
	FindConVar("z_mega_mob_size").SetInt(AllowedMegaMob + RaidLevelCounter);
	FindConVar("z_mob_spawn_max_size").IntValue = AllowedMobSpawn + RaidLevelCounter;
	FindConVar("z_mob_spawn_finale_size").SetInt(AllowedMobSpawnFinale + RaidLevelCounter);
	if (iTankRush != 1 && AllowedPanicInterval - RaidLevelCounter > 60) FindConVar("z_mega_mob_spawn_max_interval").IntValue = AllowedPanicInterval - RaidLevelCounter;
	else FindConVar("z_mega_mob_spawn_max_interval").SetInt(60);

	return Plugin_Continue;
}

bool IsSurvivorsHealthy() {

	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClientAlive(i) && L4D2_GetInfectedAttacker(i) == -1) return true;
	}
	return false;
}

/*public Action:Timer_IsSpecialCommonInRange(Handle:timer) {
	if (!b_IsActiveRound) return Plugin_Stop;
	commonInfected = 0;

	for (new i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClientAlive(i)) continue;
		if (GetClientTeam(i) != TEAM_SURVIVOR) continue;
		commonInfected = 0;
		IsSpecialCommonInRange(i, 'x', _, _, commonInfected);			// kamikazi
		if (commonInfected > 0) { // if it's a kamikazi, we force it to die, so it can trigger its effects on players in the vicinity.
			ClearSpecialCommon(commonInfected);
			commonInfected = 0;
		}
		IsSpecialCommonInRange(i, 'X', _, _, commonInfected);			// life drainer
	}
	return Plugin_Continue;
}*/

public Action Timer_RespawnQueue(Handle timer) {

	Counter										=	-1;
	TimeRemaining								=	0;
	RandomClient									=	-1;
	char text[64];

	if (!b_IsActiveRound || b_IsFinaleActive) {

		Counter = -1;
		return Plugin_Stop;
	}
	if (TotalHumanSurvivors() > iSurvivorRespawnRestrict) {

		/*	When there are a lot of players on the server, we want to maintain the difficulty that is experienced by lower level players.
			To prevent inflation on an exponential level, we just remove systems that aren't needed to compensate for players when there
			are less players in the server.
			Due to higher survivability and other important factors, removing the respawn queue feels like a pretty solid balance choice.
		*/
		return Plugin_Continue;
	}

	bool bIsHealth = false;
	bIsHealth = IsSurvivorsHealthy();

	if (!IsSurvivalMode && bIsHealth) Counter++;
	else Counter = iSurvivalCounter;
	TimeRemaining = RespawnQueue - Counter;
	if (TimeRemaining <= 0) RandomClient = FindAnyRandomClient(true);

	for (int i = 1; i <= MaxClients; i++) {

		if (!IsLegitimateClient(i) || GetClientTeam(i) != TEAM_SURVIVOR || IsPlayerAlive(i)) continue;
		if (TimeRemaining > 0) {

			if (!IsFakeClient(i)) {

				if (bIsHealth) Format(text, sizeof(text), "%T", "respawn queue", i, TimeRemaining);
				else Format(text, sizeof(text), "%T", "respawn queue paused", i, TimeRemaining);
				PrintHintText(i, text);
			}
		}
		else if (IsLegitimateClientAlive(RandomClient)) {

			GetClientAbsOrigin(RandomClient, DeathLocation[i]);
			SDKCall(hRoundRespawn, i);
			b_HasDeathLocation[i] = true;
			MyRespawnTarget[i] = -1;
			CreateTimer(3.0, Timer_TeleportRespawn, i, TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(3.0, Timer_GiveMaximumHealth, i, TIMER_FLAG_NO_MAPCHANGE);

			RandomClient = FindAnyRandomClient(true);
		}
	}
	if (Counter >= RespawnQueue) Counter = 0;
	return Plugin_Continue;
}

public Action Timer_AcidCooldown(Handle timer, any client) {
	if (IsLegitimateClient(client)) DebuffOnCooldown(client, "acid", true);
	return Plugin_Stop;
}

bool DebuffOnCooldown(client, char debuffToSearchFor[], bool removeDebuffCooldown = false) {
	char result[64];
	int size = ApplyDebuffCooldowns[client].Length;
	for (int pos = 0; pos < size; pos++) {
		ApplyDebuffCooldowns[client].GetString(pos, result, sizeof(result));
		if (!StrEqual(debuffToSearchFor, result)) continue;
		if (!removeDebuffCooldown) return true;
		ApplyDebuffCooldowns[client].Erase(pos);
		break;
	}
	return false;
}

stock bool IsClientSorted(int client) {

	int size = hThreatSort.Length;
	//new target = -1;
	for (int i = 0; i < size; i++) {

		if (client == hThreatSort.Get(i)) return true;
	}
	return false;
}

public Action Timer_PlayTime(Handle timer) {
	if (!b_IsActiveRound) return Plugin_Stop;
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i) || GetClientTeam(i) == TEAM_SPECTATOR) continue;
		TimePlayed[i]++;
	}
	return Plugin_Continue;
}

stock SortThreatMeter() {

	hThreatSort.Clear();
	hThreatMeter.Clear();
	int cTopThreat = -1;
	int cTopClient = -1;
	int cTotalClients = 0;
	int size = 0;
	for (int i = 1; i <= MaxClients; i++) {

		if (!IsLegitimateClientAlive(i) || GetClientTeam(i) != TEAM_SURVIVOR) continue;
		cTotalClients++;
	}
	while (hThreatSort.Length < cTotalClients) {

		cTopThreat = 0;
		for (int i = 1; i <= MaxClients; i++) {

			if (!IsLegitimateClientAlive(i) || GetClientTeam(i) != TEAM_SURVIVOR || IsClientSorted(i)) continue;
			if (iThreatLevel[i] > cTopThreat) {

				cTopThreat = iThreatLevel[i];
				cTopClient = i;
			}
		}
		if (cTopThreat > 0) {
			//Format(text, sizeof(text), "%d+%d", cTopClient, cTopThreat);
			//Handle:hThreatMeter.PushString(text);
			size = hThreatMeter.Length;
			hThreatMeter.Resize(size + 1);
			hThreatMeter.Set(size, cTopClient, 0);
			hThreatMeter.Set(size, cTopThreat, 1);
			hThreatSort.Push(cTopClient);
		}
		else break;
	}
}

public Action Timer_ThreatSystem(Handle timer) {

	cThreatTarget			= -1;
	cThreatOld				= -1;
	cThreatLevel				= 0;
	cThreatEnt				= -1;
	count					= 0;
	char temp[64];
	float vPos[3];

	if (!b_IsActiveRound) {
		iSurvivalCounter = -1;

		for (int i = 1; i <= MaxClients; i++) {

			if (IsLegitimateClient(i)) {

				iThreatLevel_temp[i] = 0;
				iThreatLevel[i] = 0;
			}
		}

		count = 0;
		cThreatLevel = 0;
		iTopThreat = 0;
		if (cThreatEnt && EntRefToEntIndex(cThreatEnt) != INVALID_ENT_REFERENCE) AcceptEntityInput(cThreatEnt, "Kill");
		cThreatEnt = -1;

		return Plugin_Stop;
	}
	iSurvivalCounter++;
	SortThreatMeter();
	count++;

	cThreatOld = cThreatTarget;
	cThreatLevel = 0;
	

	if (hThreatMeter.Length < 1) {

		for (int i = 1; i <= MaxClients; i++) {

			if (IsLegitimateClient(i) && GetClientTeam(i) == TEAM_SURVIVOR) {

				if (!IsPlayerAlive(i)) {

					iThreatLevel_temp[i] = 0;
					iThreatLevel[i] = 0;
					
					continue;
				}
				if (iThreatLevel[i] > cThreatLevel) {

					cThreatTarget = i;
					cThreatLevel = iThreatLevel[i];
				}
			}
		}
	}
	else {

		//Handle:hThreatMeter.GetString(0, temp, sizeof(temp));
		//ExplodeString(temp, "+", iThreatInfo, 2, 64);
		//client+threat
		cThreatTarget = hThreatMeter.Get(0, 0);
		//cThreatTarget = StringToInt(iThreatInfo[0]);
		
		//GetClientName(iClient, text, sizeof(text));
		//iThreatTarget = StringToInt(iThreatInfo[1]);
		cThreatLevel = iThreatLevel[cThreatTarget];
	}

	iTopThreat = cThreatLevel;	// when people use taunt, it sets iTopThreat + 1;
	if (cThreatOld != cThreatTarget || count >= 20) {

		count = 0;
		if (cThreatEnt && EntRefToEntIndex(cThreatEnt) != INVALID_ENT_REFERENCE) AcceptEntityInput(cThreatEnt, "Kill");
		cThreatEnt = -1;
	}

	if (cThreatEnt == -1 && IsLegitimateClientAlive(cThreatTarget)) {

		cThreatEnt = CreateEntityByName("info_goal_infected_chase");
		if (cThreatEnt > 0) {
			
			cThreatEnt = EntIndexToEntRef(cThreatEnt);

			DispatchSpawn(cThreatEnt);
			//new Float:vPos[3];
			GetClientAbsOrigin(cThreatTarget, vPos);
			vPos[2] += 20.0;
			TeleportEntity(cThreatEnt, vPos, NULL_VECTOR, NULL_VECTOR);

			SetVariantString("!activator");
			AcceptEntityInput(cThreatEnt, "SetParent", cThreatTarget);

			//decl String:temp[32];
			Format(temp, sizeof temp, "OnUser4 !self:Kill::20.0:-1");
			SetVariantString(temp);
			AcceptEntityInput(cThreatEnt, "AddOutput");
			AcceptEntityInput(cThreatEnt, "FireUser4");
		}
	}

	return Plugin_Continue;
}

public Action Timer_DirectorPurchaseTimer(Handle timer) {
	Counter										=	-1;
	float DirectorHandicap						=	-1.0;
	float DirectorDelay							=	0.0;
	if (!b_IsActiveRound) {
		Counter											=	-1;
		return Plugin_Stop;
	}
	theClient									=	-1;
	theTankStartTime								=	-1;
	int iTankCount = GetInfectedCount(ZOMBIECLASS_TANK);
	int iTankLimit = GetSpecialInfectedLimit(true);
	int iInfectedCount = GetInfectedCount();
	int iSurvivors = TotalHumanSurvivors();
	int iSurvivorBots = TotalSurvivors() - iSurvivors;
	int LivingSerfs = LivingSurvivorCount();
	int requiredAlwaysTanks = GetAlwaysTanks(iSurvivors);
	if (iSurvivorBots >= 2) iSurvivorBots /= 2;
	theClient = FindAnyRandomClient();
	if (requiredAlwaysTanks >= 1 && iTankCount < requiredAlwaysTanks && (iTanksAlwaysEnforceCooldown == 0 || f_TankCooldown == -1.0) || iTankRush == 1 && !b_IsFinaleActive && iTankCount < (iSurvivors + iSurvivorBots)) {
		ExecCheatCommand(theClient, "z_spawn_old", "tank auto");
	}
	else if (iTankRush == 0) {

		if (iInfectedCount < (iSurvivors + iSurvivorBots)) {

			SpawnAnyInfected(theClient);
		}
	}
	int iTankRequired = GetAlwaysTanks(iSurvivors);
	if (iTankRequired != 0) {

		if (theTankStartTime == -1) theTankStartTime = GetConfigValueInt("tank rush delay?");//theTankStartTime = GetRandomInt(30, 60);
		if (theTankStartTime == 0 || RPGRoundTime(true) >= theTankStartTime) {

			theTankStartTime = 0;

			if (iInfectedCount - iTankCount < (iSurvivors)) SpawnAnyInfected(theClient);
			//if (!b_IsFinaleActive && iTankCount < iTankLimit && iTankCount < iTanksAlways) {
			// no finale active			don't force on this server		or if we do and not on cooldown
			if (!b_IsFinaleActive && (iTanksAlwaysEnforceCooldown == 0 || f_TankCooldown == -1.0) && ((iTankRequired > 0 && iTankCount < iTankLimit + iTankRequired) || (iTankRequired == 0 && iTankCount < iSurvivors + iSurvivorBots))) {

				if (IsLegitimateClientAlive(theClient))	ExecCheatCommand(theClient, "z_spawn_old", "tank auto");
			}
		}
	}
	/*if (HumanPlayersInGame() < 1) {

		Counter = -1;
		CallRoundIsOver();
		return Plugin_Stop;
	}*/
	if (DirectorHandicap == -1.0) {

		DirectorHandicap = fDirectorThoughtHandicap;
		DirectorDelay	 = fDirectorThoughtDelay;
	}
	if (Counter == -1 || b_IsSurvivalIntermission || LivingSurvivorCount() < 1) {

		Counter = GetTime() + RoundToCeil(DirectorDelay - (LivingHumanSurvivors() * DirectorHandicap));
		return Plugin_Continue;
	}
	else if (Counter > GetTime()) {

		// We still spawn specials, out of range of players to enforce the active special limit.
		return Plugin_Continue;
	}
	//PrintToChatAll("%t", "Director Think Process", orange, white);


	Counter = GetTime() + RoundToCeil(DirectorDelay - (LivingSerfs * DirectorHandicap));

	int size				=	a_DirectorActions.Length;

	for (int i = 1; i <= MaximumPriority; i++) { CheckDirectorActionPriority(i, size); }

	return Plugin_Continue;
}

stock GetAlwaysTanks(survivors) {

	if (iTanksAlways > 0) return iTanksAlways;
	if (iTanksAlways < 0) {
		return RoundToFloor((survivors * 1.0)/(iTanksAlways * -1));
	}
	return 0;
}

stock CheckDirectorActionPriority(pos, size) {

	char text[64];
	for (int i = 0; i < size; i++) {

		if (i < a_DirectorActions_Cooldown.Length) a_DirectorActions_Cooldown.GetString(i, text, sizeof(text));
		else break;
		if (StringToInt(text) > 0) continue;			// Purchase still on cooldown.
		
		DirectorKeys					=	a_DirectorActions.Get(i, 0);
		DirectorValues					=	a_DirectorActions.Get(i, 1);

		if (GetKeyValueInt(DirectorKeys, DirectorValues, "priority?") != pos || !DirectorPurchase_Valid(DirectorKeys, DirectorValues, i)) continue;
		DirectorPurchase(DirectorKeys, DirectorValues, i);
	}
}

stock bool DirectorPurchase_Valid(Handle Keys, Handle Values, pos) {

	float PointCost		=	0.0;
	float PointCostMin	=	0.0;
	char Cooldown[64];

	a_DirectorActions_Cooldown.GetString(pos, Cooldown, sizeof(Cooldown));
	if (StringToInt(Cooldown) > 0) return false;

	PointCost				=	GetKeyValueFloat(Keys, Values, "point cost?") + (GetKeyValueFloat(Keys, Values, "cost handicap?") * LivingHumanSurvivors());
	if (PointCost > 1.0) PointCost = 1.0;
	PointCostMin			=	GetKeyValueFloat(Keys, Values, "point cost minimum?") + (GetKeyValueFloat(Keys, Values, "min cost handicap?") * LivingHumanSurvivors());

	if (Points_Director > 0.0) PointCost *= Points_Director;
	if (PointCost < PointCostMin) PointCost = PointCostMin;

	if (Points_Director >= PointCost) return true;
	return false;
}

stock bool bIsDirectorTankEligible() {

	if (ActiveTanks() < DirectorTankLimit()) return true;
	return false;
}

stock ActiveTanks() {
	int iSurvivors = TotalHumanSurvivors();
	//new iSurvivorBots = TotalSurvivors() - iSurvivors;
	int count = GetAlwaysTanks(iSurvivors);

	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && GetClientTeam(i) == TEAM_INFECTED && IsPlayerAlive(i) && FindZombieClass(i) == ZOMBIECLASS_TANK) count++;
	}
	return count;
}

stock DirectorTankLimit() {
	return GetSpecialInfectedLimit(true);
}

stock GetWitchCount() {

	int count = 0;
	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "witch")) != INVALID_ENT_REFERENCE) {

		// Some maps, like Hard Rain pre-spawn a ton of witches - we want to add them to the witch table.
		count++;
	}
	return count;
}

stock DirectorPurchase(Handle Keys, Handle Values, pos) {

	char Command[64];
	char Parameter[64];
	char Model[64];
	int IsPlayerDrop		=	0;
	int Count				=	0;

	float PointCost		=	0.0;
	float PointCostMin	=	0.0;

	float MinimumDelay	=	0.0;

	PointCost				=	GetKeyValueFloat(Keys, Values, "point cost?") + (GetKeyValueFloat(Keys, Values, "cost handicap?") * LivingHumanSurvivors());
	PointCostMin			=	GetKeyValueFloat(Keys, Values, "point cost minimum?") + (GetKeyValueFloat(Keys, Values, "min cost handicap?") * LivingHumanSurvivors());
	FormatKeyValue(Parameter, sizeof(Parameter), Keys, Values, "parameter?");
	Count					=	GetKeyValueInt(Keys, Values, "count?");
	FormatKeyValue(Command, sizeof(Command), Keys, Values, "command?");
	IsPlayerDrop			=	GetKeyValueInt(Keys, Values, "drop?");
	FormatKeyValue(Model, sizeof(Model), Keys, Values, "model?");
	MinimumDelay			=	GetKeyValueFloat(Keys, Values, "minimum delay?");

	if (PointCost > 1.0) {

		PointCost			=	1.0;
	}

	bool bIsEnrage = IsEnrageActive();

	//if (ReadyUp_GetGameMode() != 3 && b_IsFinaleActive && StrContains(Parameter, "witch", false) == -1 && StrContains(Parameter, "tank", false) == -1) return;

	if (DirectorWitchLimit == 0) DirectorWitchLimit = LivingSurvivorCount();


	if (StrContains(Parameter, "witch", false) != -1 && (IsSurvivalMode || GetWitchCount() >= DirectorWitchLimit || WitchList.Length + 1 >= DirectorWitchLimit)) return;
	if (StrContains(Parameter, "tank", false) != -1 && (IsSurvivalMode || (ActiveTanks() >= DirectorTankLimit() && !bIsEnrage || bIsEnrage && ActiveTanks() >= LivingHumanSurvivors()) || f_TankCooldown != -1.0)) return;

	if (StrEqual(Parameter, "common")) {

		if (CommonInfectedQueue.Length + Count >= GetCommonQueueLimit()) {

			return;
		}
	}

	/*if ((StrEqual(Command, "director_force_panic_event") || IsPlayerDrop) && b_IsFinaleActive) {

		return;
	}*/
	//if (!IsEnrageActive() && StrEqual(Command, "director_force_panic_event")) return;

	if (Points_Director > 0.0) PointCost *= Points_Director;
	if (PointCost < PointCostMin) PointCost = PointCostMin;

	if (Points_Director < PointCost) return;

	if (LivingSurvivorCount() < GetKeyValueInt(Keys, Values, "living survivors?")) return;

	int Client				=	FindLivingSurvivor();
	if (Client < 1) return;
	Points_Director -= PointCost;

	if (!IsEnrageActive() && MinimumDelay > 0.0) {

		a_DirectorActions_Cooldown.SetString(pos, "1");
		MinimumDelay = MinimumDelay - (LivingHumanSurvivors() * fDirectorThoughtHandicap) - (GetKeyValueFloat(Keys, Values, "delay handicap?") * LivingHumanSurvivors());
		if (MinimumDelay < 0.0) MinimumDelay = 0.0;
		fDirectorThoughtDelay = fDirectorThoughtDelay - (LivingHumanSurvivors() * fDirectorThoughtHandicap);
		if (fDirectorThoughtDelay < 0.0) fDirectorThoughtDelay = 0.0;
		CreateTimer(fDirectorThoughtDelay + MinimumDelay, Timer_DirectorActions_Cooldown, pos, TIMER_FLAG_NO_MAPCHANGE);
	}

	if (!StrEqual(Parameter, "common")) ExecCheatCommand(Client, Command, Parameter);
	else {
		char superCommonType[64];
		FormatKeyValue(superCommonType, sizeof(superCommonType), Keys, Values, "supercommon?");
		SpawnCommons(Client, Count, Command, Parameter, Model, IsPlayerDrop, superCommonType);
	}
}

/*stock InsertInfected(survivor, infected) {

	CreateListPositionByEntity(survivor, infected, InfectedHealth[survivor]);
	new isArraySize = Handle:InfectedHealth[survivor].Length;
	new t_InfectedHealth = 0;
	Handle:InfectedHealth[survivor].Resize(isArraySize + 1);
	Handle:InfectedHealth[survivor].Set(isArraySize, infected, 0);

	//An infected wasn't added on spawn to this player, so we add it now based on class.
	if (FindZombieClass(infected) == ZOMBIECLASS_TANK) t_InfectedHealth = 4000;
	else if (FindZombieClass(infected) == ZOMBIECLASS_HUNTER || FindZombieClass(infected) == ZOMBIECLASS_SMOKER) t_InfectedHealth = 250;
	else if (FindZombieClass(infected) == ZOMBIECLASS_BOOMER) t_InfectedHealth = 50;
	else if (FindZombieClass(infected) == ZOMBIECLASS_SPITTER) t_InfectedHealth = 100;
	else if (FindZombieClass(infected) == ZOMBIECLASS_CHARGER) t_InfectedHealth = 600;
	else if (FindZombieClass(infected) == ZOMBIECLASS_JOCKEY) t_InfectedHealth = 325;

	decl String:ss_InfectedHealth[64];
	Format(ss_InfectedHealth, sizeof(ss_InfectedHealth), "(%d) infected health bonus", FindZombieClass(infected));

	if (StringToInt(GetConfigValue("infected bot level type?")) == 1) t_InfectedHealth += t_InfectedHealth * RoundToCeil(HumanSurvivorLevels() * StringToFloat(GetConfigValue(ss_InfectedHealth)));
	else t_InfectedHealth += t_InfectedHealth * RoundToCeil(PlayerLevel[survivor] * StringToFloat(GetConfigValue(ss_InfectedHealth)));
	if (HandicapLevel[survivor] > 0) t_InfectedHealth += t_InfectedHealth * RoundToCeil(HandicapLevel[survivor] * StringToFloat(GetConfigValue("handicap health increase?")));

	Handle:InfectedHealth[survivor].Set(isArraySize, t_InfectedHealth, 1);
	Handle:InfectedHealth[survivor].Set(isArraySize, 0, 2);
	Handle:InfectedHealth[survivor].Set(isArraySize, 0, 3);
	if (isArraySize == 0) return -1;
	return isArraySize;
}*/

stock SpawnCommons(Client, Count, char Command[], Parameter[], Model[], IsPlayerDrop, SuperCommon[] = "none") {

	int TargetClient				=	-1;
	int CommonQueueLimit = GetCommonQueueLimit();
	if (StrContains(Model, ".mdl", false) != -1) {

		for (int i = Count; i > 0 && CommonInfectedQueue.Length < CommonQueueLimit; i--) {

			if (IsPlayerDrop == 1) {

				CommonInfectedQueue.Resize(CommonInfectedQueue.Length + 1);
				CommonInfectedQueue.ShiftUp(0);
				CommonInfectedQueue.SetString(0, Model);
				TargetClient		=	FindLivingSurvivor();
				if (StrContains(SuperCommon, "-", false) == -1 && !StrEqual(SuperCommon, "none", false)) SuperCommonQueue.PushString(SuperCommon);
				if (TargetClient > 0) ExecCheatCommand(TargetClient, Command, Parameter);
			}
			else CommonInfectedQueue.PushString(Model);
		}
	}
}

stock FindLivingSurvivor() {


	/*new Client = -1;
	while (Client == -1 && LivingSurvivorCount() > 0) {

		Client = GetRandomInt(1, MaxClients);
		if (!IsClientInGame(Client) || !IsClientHuman(Client) || !IsPlayerAlive(Client) || GetClientTeam(Client) != TEAM_SURVIVOR) Client = -1;
	}
	return Client;*/
	for (int i = LastLivingSurvivor; i <= MaxClients && LivingSurvivorCount() > 0; i++) {

		if (IsLegitimateClientAlive(i) && GetClientTeam(i) == TEAM_SURVIVOR) {

			LastLivingSurvivor = i;
			return i;
		}
	}
	LastLivingSurvivor = 1;
	if (LivingSurvivorCount() < 1) return -1;
	return -1;
}

stock LivingSurvivorCount(ignore = -1) {

	int Count = 0;
	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClientAlive(i) && GetClientTeam(i) == TEAM_SURVIVOR && (ignore == -1 || i != ignore)) Count++;
	}
	return Count;
}

public Action Timer_DirectorActions_Cooldown(Handle timer, any pos) {

	a_DirectorActions_Cooldown.SetString(pos, "0");
	return Plugin_Stop;
}

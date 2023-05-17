
#pragma newdecls required

/*
 *	Provides a shortcut method to calling ANY value from keys found in CONFIGS/READYUP/RPG/CONFIG.CFG
 *	@return		-1		if the requested key could not be found.
 *	@return		value	if the requested key is found.
 */
stock void GetConfigValue(char[] TheString, int TheSize, char[] KeyName) {
	char text[512];
	int a_Size			= MainKeys.Length;
	for (int i = 0; i < a_Size; i++) {

		MainKeys.GetString(i, text, sizeof(text));

		if (StrEqual(text, KeyName)) {

			MainValues.GetString(i, TheString, TheSize);
			return;
		}
	}
	Format(TheString, TheSize, "-1");
}

stock float GetConfigValueFloat(char[] KeyName, float fDefaultVal = -1.0) {
	
	char text[512];

	int a_Size			= MainKeys.Length;

	for (int i = 0; i < a_Size; i++) {

		MainKeys.GetString(i, text, sizeof(text));

		if (StrEqual(text, KeyName)) {

			MainValues.GetString(i, text, sizeof(text));
			return StringToFloat(text);
		}
	}
	return fDefaultVal;
}

stock int GetConfigValueInt(char[] KeyName) {
	
	char text[512];

	int a_Size			= MainKeys.Length;

	for (int i = 0; i < a_Size; i++) {

		MainKeys.GetString(i, text, sizeof(text));

		if (StrEqual(text, KeyName)) {

			MainValues.GetString(i, text, sizeof(text));
			return StringToInt(text);
		}
	}
	return -1;
}

/*
 *	Checks if any survivors are incapacitated.
 *	@return		true/false		depending on the result.
 */
stock bool AnySurvivorsIncapacitated() {

	for (int i = 1; i <= MaxClients; i++) {

		if (IsClientInGame(i) && GetClientTeam(i) == TEAM_SURVIVOR && IsIncapacitated(i)) return true;
	}
	return false;
}

/*
 *	Checks if there are any non-bot, non-spectator players in the game.
 *	@return		true/false		depending on the result.
 */
stock bool IsPlayersParticipating() {

	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && !IsFakeClient(i) && GetClientTeam(i) != TEAM_SPECTATOR) return true;
	}
	return false;
}

stock int GetAnyPlayerNotMe(int client) {
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i) || i == client) continue;
		return i;
	}
	return -1;
}

/*
 *	Finds a random, non-infected client in-game.
 *	@return		client index if found.
 *	@return		-1 if not found.
 */
stock int FindAnyRandomClient(bool bMustBeAlive = false, int ignoreclient = 0) {

	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && GetClientTeam(i) == TEAM_SURVIVOR && !IsLedged(i) && (GetEntityFlags(i) & FL_ONGROUND) && i != ignoreclient) {

			if (bMustBeAlive && IsPlayerAlive(i) || !bMustBeAlive) return i;
		}
	}
	return -1;
}

stock bool IsMeleeWeaponParameter(char[] parameter) {

	if (StrEqual(parameter, "fireaxe", false) ||
		StrEqual(parameter, "cricket_bat", false) ||
		StrEqual(parameter, "tonfa", false) ||
		StrEqual(parameter, "frying_pan", false) ||
		StrEqual(parameter, "golfclub", false) ||
		StrEqual(parameter, "electric_guitar", false) ||
		StrEqual(parameter, "katana", false) ||
		StrEqual(parameter, "machete", false) ||
		StrEqual(parameter, "crowbar", false)) return true;
	return false;
}
// Eyal282 here, a_Melee_Damage doesn't exist and throws errors.
/*
stock int GetMeleeWeaponDamage(int attacker, int victim, char[] weapon) {

	int zombieclass				= FindZombieClass(victim);
	int size					= a_Melee_Damage.Length;
	int healthvalue				= 0;

	char s_zombieclass[4];

	for (int i = 0; i < size; i++) {

		MeleeKeys[attacker]		= a_Melee_Damage.Get(i, 0);
		MeleeValues[attacker]	= a_Melee_Damage.Get(i, 1);
		MeleeSection[attacker]	= a_Melee_Damage.Get(i, 2);

		MeleeSection[attacker].GetString(0, s_zombieclass, sizeof(s_zombieclass));
		if (StringToInt(s_zombieclass) == zombieclass) {

			healthvalue			= RoundToCeil(GetKeyValueFloat(MeleeKeys[attacker], MeleeValues[attacker], weapon) * GetMaximumHealth(victim));
			if (healthvalue > GetClientTotalHealth(victim)) healthvalue		= GetClientTotalHealth(victim);
			return healthvalue;
		}
	}
	return 0;
}
*/
/*
 *	Checks to see if the client has an active experience booster.
 *	If the client does, ExperienceValue is multiplied against the booster value and returned.
 *	@return (ExperienceValue * Multiplier)		where Multiplier is modified based on the result of AddMultiplier(client, i)
 */
stock float CheckExperienceBooster(int client, int ExperienceValue) {

	// Return ExperienceValue as it is if the client doesn't have a booster active.
	char key[64];
	char value[64];

	float Multiplier					= 0.0;	// 1.0 is the DEFAULT (Meaning NO CHANGE)

	int size								= a_Store.Length;
	int size2								= 0;
	for (int i = 0; i < size; i++) {

		StoreKeys[client]					= a_Store.Get(i, 0);
		StoreValues[client]					= a_Store.Get(i, 1);

		size2								= StoreKeys[client].Length;
		for (int ii = 0; ii < size2; ii++) {

			StoreKeys[client].GetString(ii, key, sizeof(key));
			StoreValues[client].GetString(ii, value, sizeof(value));

			if (StrEqual(key, "item effect?") && StrEqual(value, "x")) {

				Multiplier += AddMultiplier(client, i);		// If the client has no time in it, it just adds 0.0.
			}
		}
	}

	return Multiplier;
}

/*
 *	Checks to see whether:
 *	a.) The position in the store is an experience booster
 *	b.) If it is, if the client has time remaining in it.
 *	@return		Float:value			time remaining on experience booster. 0.0 if it could not be found.
 */
stock float AddMultiplier(int client, int pos) {

	if (!IsLegitimateClient(client) || pos >= a_Store_Player[client].Length) return 0.0;
	char ClientValue[64];
	a_Store_Player[client].GetString(pos, ClientValue, sizeof(ClientValue));

	char key[64];
	char value[64];

	if (StringToInt(ClientValue) > 0) {

		StoreMultiplierKeys[client]			= a_Store.Get(pos, 0);
		StoreMultiplierValues[client]		= a_Store.Get(pos, 1);

		int size							= StoreMultiplierKeys[client].Length;
		for (int i = 0; i < size; i++) {

			StoreMultiplierKeys[client].GetString(i, key, sizeof(key));
			StoreMultiplierValues[client].GetString(i, value, sizeof(value));

			if (StrEqual(key, "item strength?")) return StringToFloat(value);
		}
	}

	return 0.0;		// It wasn't found, so no multiplier is added.
}

stock bool IsPlayerUsingShotgun(int client) {

	int CurrentEntity								= GetPlayerWeaponSlot(client, 0);

	char EntityName[64];
	if (IsValidEntity(CurrentEntity)) GetEntityClassname(CurrentEntity, EntityName, sizeof(EntityName));
	if (StrContains(EntityName, "shotgun", false) != -1) return true;
	return false;
}

stock void GetMeleeWeapon(int client, char[] Weapon, int size) {

	int g_iActiveWeaponOffset = 0;
	int iWeapon = 0;
	GetClientWeapon(client, Weapon, size);
	if (StrEqual(Weapon, "weapon_melee", false)) {
		g_iActiveWeaponOffset = FindSendPropInfo("CTerrorPlayer", "m_hActiveWeapon");
		iWeapon = GetEntDataEnt2(client, g_iActiveWeaponOffset);
		GetEntityClassname(iWeapon, Weapon, size);
		GetEntPropString(iWeapon, Prop_Data, "m_strMapSetScriptName", Weapon, size);
	}
	else Format(Weapon, size, "null");
}

stock void GetWeaponName(int client, char[] s, int size) {
	GetClientWeapon(client, s, size);
}

stock bool IsMeleeWeapon(int client) {

	char Weapon[64];
	GetClientWeapon(client, Weapon, sizeof(Weapon));
	if (StrEqual(Weapon, "weapon_melee", false) || StrContains(Weapon, "chainsaw", false) != -1) return true;
	return false;
}

// we format the string for the name of the target, but we also send back an int result to let the code know
// how to interpret the results (and what information to show on the weapons page of the character sheet)
stock int DataScreenTargetName(int client, char[] stringRef, int size) {
	//decl String:text[64];
	float TargetPos[3];
	int target = GetAimTargetPosition(client, TargetPos);
	//GetClientAimTargetEx(client, text, sizeof(text), true);
	//new target = StringToInt(text);
	if (target == -1) {
		Format(stringRef, size, "%T", "You cannot aim at anything", client);
		return -1;
	}
	else {
		if (IsLegitimateClient(target)) {
			GetClientName(target, stringRef, size);
			return 4;
		}
		else if (IsWitch(target)) {
			Format(stringRef, size, "%T", "witch aim target", client);
			return 3;
		}
		else if (IsSpecialCommon(target)) {
			Format(stringRef, size, "%T", "special common aim target", client);
			return 2;
		}
		else {
			Format(stringRef, size, "%T", "common aim target", client);
			return 1;
		}
	}
}

stock int DataScreenWeaponDamage(int client) {
	float TargetPos[3];
	int target = GetAimTargetPosition(client, TargetPos);
	//decl String:text[64];
	//GetClientAimTargetEx(client, text, sizeof(text), true);
	//new target = StringToInt(text);
	//new Float:
	//if (target == -1) GetAimTargetPosition(client, TargetPos);
	//if (target == -1) GetClientAimTargetEx(client, text, sizeof(text));

	//decl String:aimtarget[3][64];
	//ExplodeString(text, " ", aimtarget, 3, 64);
	return GetBaseWeaponDamage(client, target, TargetPos[0], TargetPos[1], TargetPos[2], DMG_BULLET, _, true);
	//return GetBaseWeaponDamage(client, target, StringToFloat(aimtarget[0]), StringToFloat(aimtarget[1]), StringToFloat(aimtarget[2]), DMG_BULLET, _, true);
	//if (!bIsBaseDamageOnly) return GetBaseWeaponDamage(client, target, StringToFloat(aimtarget[0]), StringToFloat(aimtarget[1]), StringToFloat(aimtarget[2]), DMG_BULLET);
	//else return GetBaseWeaponDamage(client, target, StringToFloat(aimtarget[0]), StringToFloat(aimtarget[1]), StringToFloat(aimtarget[2]), DMG_BULLET, true);
}

stock int GetWeaponProficiencyType(int client) {
	char Weapon[64];
	GetClientWeapon(client, Weapon, sizeof(Weapon));
	if (StrEqual(Weapon, "weapon_melee", false)) return 1;
	if (StrContains(Weapon, "smg", false) != -1) return 2;
	if (StrContains(Weapon, "shotgun", false) != -1) return 3;
	if (StrContains(Weapon, "sniper", false) != -1 || StrContains(Weapon, "hunting", false) != -1) return 4;
	if (StrContains(Weapon, "rifle", false) != -1) return 5;
	//if (StrContains(Weapon, "pistol", false) != -1) return 0;
	return 0;
}
/*
	result 1 to get the offset, which is used to determine how much reserve ammo there is remaining.
	result 2 to get the max amount of reserve ammo this weapon can hold.
	result 3 to get the current amount of reserve ammo is remaining.
*/
stock int GetWeaponResult(int client, int result = 0, int amountToAdd = 0) {
	int iWeapon = GetPlayerWeaponSlot(client, 0);
	if (!IsValidEntity(iWeapon)) return -1;
	char Weapon[64];
	char WeaponName[64];
	GetEntityClassname(iWeapon, Weapon, sizeof(Weapon));
	int size = a_WeaponDamages.Length;
	float fValue = 0.0;
	int targetgun = GetPlayerWeaponSlot(client, 0);
	int wOffset = 0;
	if (result == 3 || result == 4) {
		if (!IsValidEdict(targetgun)) return -1;
		targetgun = FindDataMapInfo(client, "m_iAmmo");
		wOffset = GetWeaponResult(client, 1);
	}

	for (int i = 0; i < size; i++) {
		WeaponResultSection[client] = a_WeaponDamages.Get(i, 2);
		WeaponResultSection[client].GetString(0, WeaponName, sizeof(WeaponName));
		if (!StrEqual(WeaponName, Weapon, false)) continue;
		WeaponResultKeys[client] = a_WeaponDamages.Get(i, 0);
		WeaponResultValues[client] = a_WeaponDamages.Get(i, 1);
		if (result == 0) {
			fValue = GetKeyValueFloat(WeaponResultKeys[client], WeaponResultValues[client], "range");
			fValue = GetAbilityStrengthByTrigger(client, _, "gunRNG", _, RoundToCeil(fValue), _, _, "d", 1, true);
			if (bIsInCombat[client]) fValue = GetAbilityStrengthByTrigger(client, _, "ICwRNG", _, RoundToCeil(fValue), _, _, "d", 1, true);
			else fValue = GetAbilityStrengthByTrigger(client, _, "OCwRNG", _, RoundToCeil(fValue), _, _, "d", 1, true);
			return RoundToCeil(fValue);
		}
		if (result == 1) return GetKeyValueInt(WeaponResultKeys[client], WeaponResultValues[client], "offset");
		if (result == 2) {
			int value = GetKeyValueInt(WeaponResultKeys[client], WeaponResultValues[client], "ammo");
			return value + RoundToCeil(GetAbilityStrengthByTrigger(client, _, "ammoreserve", _, value, _, _, "ammoreserve", 0, true));
		}
		if (result == 3) {
			return GetEntData(client, (targetgun + wOffset));
		}
		if (result == 4) {
			SetEntData(client, (targetgun + wOffset), GetEntData(client, (targetgun + wOffset)) + amountToAdd);
			return amountToAdd;
		}
		break;
	}
	return -1;
}

stock int GetBaseWeaponDamage(int client, int target, float impactX = 0.0, float impactY = 0.0, float impactZ = 0.0, int damagetype, bool bGetBaseDamage = false, bool IsDataSheet = false) {
	char WeaponName[512];
	char Weapon[512];
	int WeaponId = -1;
	int g_iActiveWeaponOffset = 0;
	int iWeapon = 0;
	bool IsMelee = false;
	//new bool:IsTank = (IsLegitimateClient(target) && FindZombieClass(target) == ZOMBIECLASS_TANK) ? true : false;
	// we only want this to return true for standard commons, not super commons.
	//new bool:IsCommonInfectedTarget = (IsCommonInfected(target)) ? true : false;
	GetClientWeapon(client, Weapon, sizeof(Weapon));
	if (StrEqual(Weapon, "weapon_melee", false)) {

		IsMelee = true;
		g_iActiveWeaponOffset = FindSendPropInfo("CTerrorPlayer", "m_hActiveWeapon");
		iWeapon = GetEntDataEnt2(client, g_iActiveWeaponOffset);
		GetEntityClassname(iWeapon, Weapon, sizeof(Weapon));
		GetEntPropString(iWeapon, Prop_Data, "m_strMapSetScriptName", Weapon, sizeof(Weapon));
	}
	else if (StrContains(Weapon, "weapon_", false) != -1) {

		if (StrContains(Weapon, "pistol", false) == -1 && StrContains(Weapon, "chainsaw", false) == -1) WeaponId = GetPlayerWeaponSlot(client, 0);
		else {

			WeaponId = GetPlayerWeaponSlot(client, 1);
			if (StrContains(Weapon, "chainsaw", false) != -1) IsMelee = true;
		}
		if (IsValidEntity(WeaponId)) GetEntityClassname(WeaponId, Weapon, sizeof(Weapon));
		else return -1;
	}
	// To help cut down on the cost of calculating damage on EVERY event...
	// if we know the damage is going to be the same, why calculate it again?
	// If the target is a common infected, if their last target was a common infected or super common, we don't calculate damage and instead return the last calculated damage value.
	//if (IsCommonInfectedTarget && (target == lastTarget[client] || IsCommonInfected(lastTarget[client])) && StrEqual(Weapon, lastWeapon[client])) { return lastBaseDamage[client]; }
	int WeaponDamage = 0;
	float WeaponRange = 0.0;
	float WeaponDamageRangePenalty = 0.0;
	float RangeRequired = 0.0;

	float cpos[3];
	float tpos[3];
	GetClientAbsOrigin(client, cpos);
	if (target != -1) {
		GetEntPropVector(target, Prop_Send, "m_vecOrigin", tpos);
	}
	else {
		tpos[0] = impactX;
		tpos[1] = impactY;
		tpos[2] = impactZ;
	}
	float Distance = GetVectorDistance(cpos, tpos);
	int baseWeaponTemp = 0;
	int size = a_WeaponDamages.Length;
	float TheAbilityMultiplier;
	float MaxMultiplier;
	int clientFlags = GetEntityFlags(client);
	for (int i = 0; i < size; i++) {
		DamageSection[client] = a_WeaponDamages.Get(i, 2);
		DamageSection[client].GetString(0, WeaponName, sizeof(WeaponName));
		if (!StrEqual(WeaponName, Weapon, false)) continue;

		DamageKeys[client] = a_WeaponDamages.Get(i, 0);
		DamageValues[client] = a_WeaponDamages.Get(i, 1);
		WeaponDamage = GetKeyValueInt(DamageKeys[client], DamageValues[client], "damage");
 		baseWeaponTemp = WeaponDamage;
		if (IsDataSheet) baseWeaponTemp += RoundToCeil(GetAbilityStrengthByTrigger(client, target, "D", _, WeaponDamage, _, _, "d", 1, true, _, _, _, damagetype));
		if ((clientFlags & IN_DUCK)) baseWeaponTemp += RoundToCeil(GetAbilityStrengthByTrigger(client, target, "crouch", _, WeaponDamage, _, _, "d", 1, true, _, _, _, damagetype));
 		if ((clientFlags & FL_INWATER)) baseWeaponTemp += RoundToCeil(GetAbilityStrengthByTrigger(client, target, "wtr", _, WeaponDamage, _, _, "d", 1, true, _, _, _, damagetype));
 		else if (!(clientFlags & FL_ONGROUND)) baseWeaponTemp += RoundToCeil(GetAbilityStrengthByTrigger(client, target, "grnd", _, WeaponDamage, _, _, "d", 1, true, _, _, _, damagetype));
 		if ((clientFlags & FL_ONFIRE)) baseWeaponTemp += RoundToCeil(GetAbilityStrengthByTrigger(client, target, "onfire", _, WeaponDamage, _, _, "d", 1, true, _, _, _, damagetype));

 		// The player, above, receives a flat damage increase of 50% just for having adrenaline active.
 		// Now, we increase their damage if they're in rage ammo, which is a separate thing, although it also provides the adrenaline buff.
 		if (IsClientInRangeSpecialAmmo(client, "a") == -2.0) baseWeaponTemp += RoundToCeil(WeaponDamage * IsClientInRangeSpecialAmmo(client, "a", false, _, WeaponDamage * 1.0));
 		if (IsClientInRangeSpecialAmmo(client, "d") == -2.0) baseWeaponTemp += RoundToCeil(WeaponDamage * IsClientInRangeSpecialAmmo(client, "d", false, _, WeaponDamage * 1.0));
 		if (IsClientInRangeSpecialAmmo(client, "E") == -2.0) baseWeaponTemp += RoundToCeil(WeaponDamage * IsClientInRangeSpecialAmmo(client, "E", false, _, WeaponDamage * 1.0));
 		if (IsLegitimateClientAlive(target) && IsClientInRangeSpecialAmmo(target, "E") == -2.0) baseWeaponTemp += RoundToCeil(WeaponDamage * IsClientInRangeSpecialAmmo(target, "E", false, _, WeaponDamage * 1.0));
		//}
		//else
		if (damagetype == DMG_BURN) baseWeaponTemp += RoundToCeil(GetAbilityStrengthByTrigger(client, target, "G", _, WeaponDamage, _, _, "d", 1, true, _, _, _, damagetype));	// THE 1 simply means that it adds the damagevalue before multiplying; if the player has no points in the talent, they do the base damage instead.
		if (damagetype == DMG_BLAST) baseWeaponTemp += RoundToCeil(GetAbilityStrengthByTrigger(client, target, "S", _, WeaponDamage, _, _, "d", 1, true, _, _, _, damagetype));
		if (damagetype == DMG_CLUB) baseWeaponTemp += RoundToCeil(GetAbilityStrengthByTrigger(client, target, "U", _, WeaponDamage, _, _, "d", 1, true, _, _, _, damagetype));
	 	if (damagetype == DMG_SLASH) baseWeaponTemp += RoundToCeil(GetAbilityStrengthByTrigger(client, target, "u", _, WeaponDamage, _, _, "d", 1, true, _, _, _, damagetype));
		
		WeaponRange = GetKeyValueFloat(DamageKeys[client], DamageValues[client], "range");

		//if (!IsMelee && (damagetype & DMG_BULLET)) {
		if (!IsMelee) {
			WeaponRange += GetAbilityStrengthByTrigger(client, target, "gunRNG", _, RoundToCeil(WeaponRange), _, _, "d", 1, true, _, _, _, damagetype);
			baseWeaponTemp += RoundToCeil(GetAbilityStrengthByTrigger(client, target, "gunDMG", _, WeaponDamage, _, _, "d", 1, true, _, _, _, damagetype));

			if (bIsInCombat[client]) {
				WeaponRange += GetAbilityStrengthByTrigger(client, target, "ICwRNG", _, RoundToCeil(WeaponRange), _, _, "d", 1, true, _, _, _, damagetype);
				baseWeaponTemp += RoundToCeil(GetAbilityStrengthByTrigger(client, target, "ICwDMG", _, WeaponDamage, _, _, "d", 1, true, _, _, _, damagetype));
			}
			else {
				WeaponRange += GetAbilityStrengthByTrigger(client, target, "OCwRNG", _, RoundToCeil(WeaponRange), _, _, "d", 1, true, _, _, _, damagetype);
				baseWeaponTemp += RoundToCeil(GetAbilityStrengthByTrigger(client, target, "OCwDMG", _, WeaponDamage, _, _, "d", 1, true, _, _, _, damagetype));
			}
		}
		else {
			baseWeaponTemp += RoundToCeil(GetAbilityStrengthByTrigger(client, target, "mDMG", _, WeaponDamage, _, _, "d", 1, true, _, _, _, damagetype));
		}
		if (baseWeaponTemp > 0) WeaponDamage = baseWeaponTemp;

		TheAbilityMultiplier = GetAbilityMultiplier(client, "N");
		if (TheAbilityMultiplier != -1.0) WeaponDamage += RoundToCeil(WeaponDamage * TheAbilityMultiplier);
		TheAbilityMultiplier = GetAbilityMultiplier(client, "C");
		if (TheAbilityMultiplier != -1.0) {
			MaxMultiplier = GetAbilityMultiplier(client, "C", 3);
			if (ConsecutiveHits[client] > 0) TheAbilityMultiplier *= ConsecutiveHits[client];
			if (TheAbilityMultiplier > MaxMultiplier) TheAbilityMultiplier = MaxMultiplier;
			if (TheAbilityMultiplier > 0.0) WeaponDamage += RoundToCeil(WeaponDamage * TheAbilityMultiplier); // damage dealt is increased
		}
		if (!(clientFlags & FL_ONGROUND)) {
			TheAbilityMultiplier = GetAbilityMultiplier(client, "K");
			if (TheAbilityMultiplier != -1.0) WeaponDamage += RoundToCeil(WeaponDamage * TheAbilityMultiplier);
		}
		if ((clientFlags & FL_INWATER)) {
			TheAbilityMultiplier = GetAbilityMultiplier(client, "a");
			if (TheAbilityMultiplier != -1.0) WeaponDamage += RoundToCeil(WeaponDamage * TheAbilityMultiplier);
		}
		if ((clientFlags & FL_ONFIRE)) {
			TheAbilityMultiplier = GetAbilityMultiplier(client, "f");
			if (TheAbilityMultiplier != -1.0) WeaponDamage += RoundToCeil(WeaponDamage * TheAbilityMultiplier);
		}
		RangeRequired = 0.0;
		if (Distance > WeaponRange && WeaponRange > 0.0) {

			/*

				In order to balance weapons and prevent one weapon from being the all-powerful go-to choice
				a weapon fall-off range is introduced.
				The amount of damage when receiving this penalty is equal to
				RoundToCeil(((Distance - WeaponRange) / WeaponRange) * damage);

				We subtract this value from overall damage.

				Some weapons (like certain sniper rifles) may not have a fall-off range.
			*/
			WeaponDamageRangePenalty = 1.0 - ((Distance - WeaponRange) / WeaponRange);
			WeaponDamage = RoundToCeil(WeaponDamage * WeaponDamageRangePenalty);
			if (WeaponDamage < 1) WeaponDamage = 1;		// If you're double the range or greater, congrats, bb gun.
		}
		if (Distance <= RangeRequired && RangeRequired > 0.0) {

			WeaponDamageRangePenalty = 1.0 - ((RangeRequired - Distance) / RangeRequired);
			WeaponDamage = RoundToCeil(WeaponDamage * WeaponDamageRangePenalty);
			if (WeaponDamage < 1) WeaponDamage = 1;
		}
		lastBaseDamage[client] = WeaponDamage;
		Format(lastWeapon[client], sizeof(lastWeapon[]), "%s", Weapon);
		lastTarget[client] = target;
		return WeaponDamage;
	}
	//LogMessage("Could not find header for %s", Weapon);
	return 0;
}

stock bool IsSurvivor(int client) {

	if (IsLegitimateClient(client) && GetClientTeam(client) == TEAM_SURVIVOR) return true;
	return false;
}

stock bool IsFireDamage(int damagetype) {

	if (damagetype == 8 || damagetype == 2056 || damagetype == 268435464) return true;
	return false;
}

stock void GetSurvivorBotName(int client, char[] TheBuffer, int TheSize) {

	char TheModel[64];
	GetClientModel(client, TheModel, sizeof(TheModel));	// helms deep creates bots that aren't necessarily on the survivor team.
		
	if (StrEqual(TheModel, NICK_MODEL)) Format(TheBuffer, TheSize, "Nick");
	else if (StrEqual(TheModel, ROCHELLE_MODEL)) Format(TheBuffer, TheSize, "Rochelle");
	else if (StrEqual(TheModel, COACH_MODEL)) Format(TheBuffer, TheSize, "Coach");
	else if (StrEqual(TheModel, ELLIS_MODEL)) Format(TheBuffer, TheSize, "Ellis");
	else if (StrEqual(TheModel, LOUIS_MODEL)) Format(TheBuffer, TheSize, "Louis");
	else if (StrEqual(TheModel, ZOEY_MODEL)) Format(TheBuffer, TheSize, "Zoey");
	else if (StrEqual(TheModel, BILL_MODEL)) Format(TheBuffer, TheSize, "Bill");
	else if (StrEqual(TheModel, FRANCIS_MODEL)) Format(TheBuffer, TheSize, "Francis");
}

stock void ForceLoadDefaultProfiles(int loadtarget) {
	if (!IsLegitimateClient(loadtarget)) return;
	if (GetClientTeam(loadtarget) == TEAM_SURVIVOR) {
		if (IsSurvivorBot(loadtarget)) {
			SetTotalExperienceByLevel(loadtarget, iBotPlayerStartingLevel);
			LoadProfileEx(loadtarget, DefaultBotProfileName);
		}
		else {
			SetTotalExperienceByLevel(loadtarget, iPlayerStartingLevel);
			LoadProfileEx(loadtarget, DefaultProfileName);
		}
	}
	else LoadProfileEx(loadtarget, DefaultInfectedProfileName);
	return;
}

stock bool IsSurvivorBot(int client) {

	if (IsLegitimateClient(client) && IsFakeClient(client) && GetClientTeam(client) == TEAM_SURVIVOR) {

		/*decl String:TheCurr[64];
		GetCurrentMap(TheCurr, sizeof(TheCurr));
		if (StrContains(TheCurr, "helms_deep", false) == -1) {

			if (GetClientTeam(client) == TEAM_SURVIVOR) return true;
		}
		else {*/

		char TheModel[64];
		GetClientModel(client, TheModel, sizeof(TheModel));	// helms deep creates bots that aren't necessarily on the survivor team.
		if (StrEqual(TheModel, NICK_MODEL) ||
			StrEqual(TheModel, ROCHELLE_MODEL) ||
			StrEqual(TheModel, COACH_MODEL) ||
			StrEqual(TheModel, ELLIS_MODEL) ||
			StrEqual(TheModel, ZOEY_MODEL) ||
			StrEqual(TheModel, FRANCIS_MODEL) ||
			StrEqual(TheModel, LOUIS_MODEL) ||
			StrEqual(TheModel, BILL_MODEL)) {

			return true;
		}
	}
	return false;
}

stock bool IsSurvivorPlayer(int client) {

	if (IsLegitimateClient(client) && GetClientTeam(client) == TEAM_SURVIVOR) return true;
	return false;
}

stock bool CommonInfectedModel(int ent, char[] SearchKey) {

	char ModelName[64];
 	GetEntPropString(ent, Prop_Data, "m_ModelName", ModelName, sizeof(ModelName));
 	if (StrContains(ModelName, SearchKey, false) != -1) return true;
 	return false;
}

stock int GetSurvivorsInRange(int client, float Distance) {

	float cpos[3];
	float spos[3];
	int count = 0;
	GetClientAbsOrigin(client, cpos);

	for (int i = 1; i <= MaxClients; i++) {

		if (!IsLegitimateClientAlive(i) || GetClientTeam(i) != TEAM_SURVIVOR) continue;
		GetClientAbsOrigin(i, spos);
		if (GetVectorDistance(cpos, spos) <= Distance) count++;
	}
	return count;
}

stock bool SurvivorsWithinRange(int client, float Distance) {

	float cpos[3];
	float spos[3];
	GetClientAbsOrigin(client, cpos);

	for (int i = 1; i <= MaxClients; i++) {

		if (!IsLegitimateClientAlive(i) || GetClientTeam(i) != TEAM_SURVIVOR) continue;
		GetClientAbsOrigin(i, spos);
		if (GetVectorDistance(cpos, spos) <= Distance) return true;
	}
	return false;
}

stock int DoesClientHaveTheHighGround(float cpos[3], int target) {
	float tpos[3];
	GetEntPropVector(target, Prop_Send, "m_vecOrigin", tpos);
	if (cpos[2] > tpos[2]) return 1;	// client is above target
	if (cpos[2] < tpos[2]) return -1;	// client is below target
	return 0;							// client and target are on same level.
}

stock float GetTargetRange(int client, int target) {
	float cpos[3];
	float tpos[3];
	if (IsCommonInfected(client) || IsWitch(client)) GetEntPropVector(client, Prop_Send, "m_vecOrigin", cpos);
	else GetClientAbsOrigin(client, cpos);
	if (IsCommonInfected(target) || IsWitch(target)) GetEntPropVector(target, Prop_Send, "m_vecOrigin", tpos);
	else GetClientAbsOrigin(target, tpos);

	return GetVectorDistance(cpos, tpos);
}

stock bool IsClientInRange(int client, int target, float range) {

	float cpos[3];
	float tpos[3];
	if (IsCommonInfected(client) || IsWitch(client)) GetEntPropVector(client, Prop_Send, "m_vecOrigin", cpos);
	else GetClientAbsOrigin(client, cpos);
	if (IsCommonInfected(target) || IsWitch(target)) GetEntPropVector(target, Prop_Send, "m_vecOrigin", tpos);
	else GetClientAbsOrigin(target, tpos);

	if (GetVectorDistance(cpos, tpos) <= range) return true;
	return false;
}

stock bool CheckTankState(int client, char[] StateName) {

	char text[64];
	for (int i = 0; i < TankState_Array[client].Length; i++) {

		TankState_Array[client].GetString(i, text, sizeof(text));
		if (StrEqual(text, StateName)) return true;	
	}
	//if (TankState_Array[client].Length)
	return false;
}

stock int ChangeTankState(int client, char[] StateName, bool IsDelete = false, bool GetState = false) {

	if (!b_IsActiveRound) return -1;
	if (!IsLegitimateClientAlive(client) || FindZombieClass(client) != ZOMBIECLASS_TANK) return -3;

	char text[64];
	int size = TankState_Array[client].Length;

	char sCurState[64];
	if (size > 0) TankState_Array[client].GetString(0, sCurState, sizeof(sCurState));

	if (GetState || IsDelete) {

		//if (size < 1 && IsDelete) return 0;
		if (size < 1) return 0;
		if (StrEqual(text, StateName)) {

			if (!IsDelete) return 1;
			TankState_Array[client].Clear();
			return -1;
		}
	}
	else {

		if (iTanksPreset == 0 && size > 0 && !StrEqual(sCurState, StateName) || size < 1) {

			if (size > 0) TankState_Array[client].SetString(0, StateName);
			else TankState_Array[client].PushString(StateName);

			if (iTanksPreset == 1) {

				char sTank[64];
				Format(sTank, sizeof(sTank), "tank spawn:%s", StateName);
				char sText[64];
				for (int i = 1; i <= MaxClients; i++) {

					if (!IsLegitimateClient(i) || IsFakeClient(i)) continue;
					Format(sText, sizeof(sText), "%T", sTank, i);
					PrintToChat(i, "%T", "tank spawn notification", i, orange, sText, white, blue);
				}
			}

			if (StrEqual(StateName, "hulk")) {

				SetEntityRenderMode(client, RENDER_TRANSCOLOR);
				SetEntityRenderColor(client, 0, 255, 0, 255);
			}
			else if (StrEqual(StateName, "death")) {

				//Handle TankState_Array[client].Clear();	// you who walks through the valley of death loses everything.

				SetEntityRenderMode(client, RENDER_TRANSCOLOR);
				SetEntityRenderColor(client, 0, 0, 0, 255);
			}
			else if (StrEqual(StateName, "burn")) {

				SetEntityRenderMode(client, RENDER_TRANSCOLOR);
				SetEntityRenderColor(client, 255, 0, 0, 200);
			}
			else if (StrEqual(StateName, "teleporter")) {

				SetEntityRenderMode(client, RENDER_TRANSCOLOR);
				SetEntityRenderColor(client, 50, 50, 255, 200);

				if (b_IsActiveRound) FindRandomSurvivorClient(client, true);
			}
			/*else {

				if (StrEqual(StateName, "burn")) {

					if (!(GetEntityFlags(client) & FL_ONFIRE)) IgniteEntity(client, 30.0);
					SetEntityRenderMode(client, RENDER_TRANSCOLOR);
					SetEntityRenderColor(client, 255, 0, 0, 255);
				}
				else if ((GetEntityFlags(client) & FL_ONFIRE)) ExtinguishEntity(client);
			}*/
		}
		return 2;
	}
	return -2;
}

stock void FindRandomSurvivorClient(int client, bool bIsTeleportTo = false, bool bPrioritizeTanks = true) {

	if (!IsLegitimateClientAlive(client) || !b_IsActiveRound) return;

	RandomSurvivorClient.Clear();
	//decl String:ClassRoles[64];
	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClientAlive(i) && GetClientTeam(i) == TEAM_SURVIVOR) {

			if (client == i) continue;
			RandomSurvivorClient.Push(i);
		}
	}
	if (bPrioritizeTanks && RandomSurvivorClient.Length < 1) {

		//if (TotalHumanSurvivors() >= 4)
		FindRandomSurvivorClient(client, bIsTeleportTo, false);	// now all clients are viable.
		return;
	}
	int size = RandomSurvivorClient.Length;
	if (size < 1) return;

	int target = GetRandomInt(1, size);
	target = RandomSurvivorClient.Get(target - 1);

	float Origin[3];
	GetClientAbsOrigin(target, Origin);
	/*decl String:text[64];
	GetClientAimTargetEx(target, text, sizeof(text));

	decl String:aimtarget[3][64];
	ExplodeString(text, " ", aimtarget, 3, 64);

	new Float:Origin[3];
	Origin[0] = StringToFloat(aimtarget[0]);
	Origin[1] = StringToFloat(aimtarget[1]);
	Origin[2] = StringToFloat(aimtarget[2]);*/
	TeleportEntity(client, Origin, NULL_VECTOR, NULL_VECTOR);
	/*if (GetClientTeam(client) == TEAM_SURVIVOR && bRushingNotified[client]) {

		bRushingNotified[client] = false;
	}*/
	if (GetClientTeam(client) == TEAM_INFECTED) bHasTeleported[client] = true;
}

/*bool:AnySurvivorInRange(client, Float:Range) {

	for (new i = 1; i <= MaxClients; i++) {

		if (!IsLegitimateClientAlive(i) || GetClientTeam(i) != TEAM_SURVIVOR || IsFakeClient(i)) continue;
		if (IsClientInRange(client, i, Range)) return true;
	}
	return false;
}*/

stock void CheckTankSubroutine(int tank, int survivor = 0, int damage = 0, bool TankIsVictim = false) {

	if (iRPGMode == -1) return;
	if (!IsLegitimateClientAlive(tank) || FindZombieClass(tank) != ZOMBIECLASS_TANK) return;	

	//if (IsSurvivalMode) return;

	int DeathState		= ChangeTankState(tank, "death", _, true);

	if (DeathState != 1 && (IsSpecialCommonInRange(tank, 'w') || IsClientInRangeSpecialAmmo(tank, "W") == -2.0)) {

		//ChangeTankState(client, "hulk", true);
		ChangeTankState(tank, "death");
	}
	int tankFlags = GetEntityFlags(tank);

	//if (survivor == 0 && damage == 0 && !(GetEntityFlags(tank) & FL_ONFIRE) && !SurvivorsInRange(tank)) ChangeTankState(tank, "teleporter");

	//new TankEnrageMechanic			= GetConfigValueInt("boss tank enrage count?");
	//new Float:TankTeleportMechanic	= GetConfigValueFloat("boss tank teleport distance?");

	if (tankFlags & FL_INWATER) {

		ChangeTankState(tank, "burn", true);
	}
	//new bool:IsDeath = false;

	//new DeathState		= ChangeTankState(tank, "death", _, true);
	int BurnState		= ChangeTankState(tank, "burn", _, true);
	//new bool:IsOnFire = false;
	if ((tankFlags & FL_ONFIRE) && BurnState != 1) {

		ExtinguishEntity(tank);
	}
	bool IsBiled	= IsCoveredInBile(tank);
	int IsHulkState		= ChangeTankState(tank, "hulk", _, true);

	if (bIsDefenderTank[tank] || DeathState == 1) {
		SetSpeedMultiplierBase(tank, fTankMovementSpeed_Death);
		SetEntityRenderMode(tank, RENDER_TRANSCOLOR);
		if (bIsDefenderTank[tank]) SetEntityRenderColor(tank, 0, 0, 255, 255);
		else SetEntityRenderColor(tank, 0, 0, 0, 150);
	}
	else if (IsHulkState == 1) {
		SetSpeedMultiplierBase(tank, fTankMovementSpeed_Hulk);

		SetEntityRenderMode(tank, RENDER_TRANSCOLOR);
		SetEntityRenderColor(tank, 0, 255, 0, 200);
	}
	else if (BurnState == 1) {

		SetSpeedMultiplierBase(tank, fTankMovementSpeed_Burning);

		SetEntityRenderMode(tank, RENDER_TRANSCOLOR);
		SetEntityRenderColor(tank, 255, 0, 0, 200);
		if (!(tankFlags & FL_ONFIRE)) IgniteEntity(tank, 3.0);
	}
	if (BurnState != 1) ExtinguishEntity(tank);
	/*if (BurnState) {

		SetSpeedMultiplierBase(tank, 1.0);
		ChangeTankState(tank, "hulk", true);
		IsHulkState = 0;
		SetEntityRenderMode(tank, RENDER_TRANSCOLOR);
		SetEntityRenderColor(tank, 255, 0, 0, 255);
	}*/
	bool IsLegitimateClientSurvivor = IsLegitimateClient(survivor);
	int survivorTeam = -1;
	if (IsLegitimateClientSurvivor) survivorTeam = GetClientTeam(survivor);
	if (survivor == 0 || !IsLegitimateClientSurvivor || survivorTeam != TEAM_SURVIVOR) return;

	//decl String:ClassRoles[64];

	//new Float:IsSurvivorWeak = IsClientInRangeSpecialAmmo(survivor, "W");
	//new Float:IsSurvivorReflect = 0.0;
	bool IsSurvivorBiled = false;

	if (IsLegitimateClientSurvivor && survivorTeam == TEAM_SURVIVOR) {

		//IsClientInRangeSpecialAmmo(survivor, "R");
		//IsCoveredInVomit(survivor);
	}

	if (!TankIsVictim) {

		if (BurnState == 1) {

			int Count = GetClientStatusEffect(survivor, "burn");

			if (!IsSurvivorBiled && Count < iDebuffLimit) {

				//if (IsSurvivorReflect) CreateAndAttachFlame(tank, RoundToCeil(damage * 0.1), 10.0, 1.0, survivor, "burn");
				//else
				if (Count == 0) Count = 1;
				CreateAndAttachFlame(survivor, RoundToCeil((damage * fBurnPercentage) / Count), 10.0, 0.5, tank, "burn");
			}
		}
		if (DeathState == 0) ChangeTankState(tank, "hulk");
		else if (IsHulkState == 1) ChangeTankState(tank, "death");
		else if (DeathState == 1) {

			int SurvivorHealth = GetClientTotalHealth(survivor);

			int SurvivorHalfHealth = SurvivorHealth / 2;
			if (SurvivorHalfHealth / GetMaximumHealth(survivor) > 0.25) {

				SetClientTotalHealth(survivor, SurvivorHalfHealth);
				AddSpecialInfectedDamage(survivor, tank, SurvivorHalfHealth, true);
			}
		}
		else if (IsHulkState == 1) {

			CreateExplosion(survivor, damage, tank, true);
		}
	}
	else {

		if (IsBiled) {

			if (BurnState == 1) ChangeTankState(tank, "hulk");
			if (!ISBILED[survivor]) {
				SDKCall(g_hCallVomitOnPlayer, survivor, tank, true);
				CreateTimer(15.0, Timer_RemoveBileStatus, survivor, TIMER_FLAG_NO_MAPCHANGE);
				ISBILED[survivor] = true;
			}
		}
	}
}

public Action Hook_SetTransmit(int entity, int client) {
	
	if(EntIndexToEntRef(entity) == eBackpack[client]) return Plugin_Handled;
	return Plugin_Continue;
}

/*
 *	SDKHooks function.
 *	We're using it to prevent any melee damage, due to the bizarre way that melee damage is handled, it's hit or miss whether it is changed.
 *	@return Plugin_Changed		if a melee weapon was used.
 *	@return Plugin_Continue		if a melee weapon was not used.
 */

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage_ignore, int &damagetype) {
	if (!b_IsActiveRound || b_IsSurvivalIntermission) {

		damage_ignore = 0.0;
		return Plugin_Handled;
	}
	/*if (IsCommonInfected(victim) && !IsSpecialCommon(victim)) {
		damage_ignore = 9999.0;
		return Plugin_Changed;
	}*/
	int survivorIncomingDamage = RoundToCeil(damage_ignore);
	float damage = damage_ignore;
	if (damage <= 0.0) {
		damage_ignore = 0.0;
		return Plugin_Handled;
		/* So survivor bots will now damage jimmy gibbs and riot police as if they were not uncommon infected.
		// If we don't do this, the bots don't understand that the weapons that the uncommons are immune to, and if they are in
		// possession of said weapon, will just shoot the bots indefinitely.
		if (!IsSurvivorBot(attacker)) {
			damage_ignore = 0.0;
			return Plugin_Handled;
		}*/
	}
	bool bIsEnrageActive = IsEnrageActive();
	int baseWeaponDamage = 0;
	int loadtarget = -1;
	float TheAbilityMultiplier = 0.0;
	int cTank = -1;
	bool IsSurvivorBotVictim = IsSurvivorBot(victim);
	bool IsSurvivorBotAttacker = IsSurvivorBot(attacker);

 	int DamageShield = 0;
 	int ReflectIncomingDamage = 0;
	int theCount = LivingSurvivorCount();
	/*
		Code for LEGITIMATE attackers goes here.
		This only handles survivors and special infected attackers; witches, commons, and super attackers are at the bottom of this method.
	*/
	bool IsLegitimateClientVictim = IsLegitimateClient(victim);
	int victimTeam = -1;
	if (IsLegitimateClientVictim) victimTeam = GetClientTeam(victim);
	bool IsLegitimateClientAttacker = IsLegitimateClient(attacker);
	int attackerTeam = -1;
	if (IsLegitimateClientAttacker) attackerTeam = GetClientTeam(attacker);
	int victimType = -1;
	int attackerType = -1;
	if (IsLegitimateClientAttacker) {
		if (b_IsLoading[attacker]) {	// may cause issues if infected players are stuck in loading; they shouldn't be, guess we'll find out.
			damage_ignore = 0.0;
			return Plugin_Handled;
		}
		else if (!IsFakeClient(attacker) && SkyLevel[attacker] < 1 && PlayerLevel[attacker] < iPlayerStartingLevel || (IsFakeClient(attacker) || IsSurvivorBotAttacker) && PlayerLevel[attacker] < iBotPlayerStartingLevel) {
			loadtarget = attacker;
			ForceLoadDefaultProfiles(loadtarget);
		}
		b_IsDead[attacker] = false;
		LastAttackTime[attacker] = GetEngineTime();
		if (!HasSeenCombat[attacker]) HasSeenCombat[attacker] = true;
		if (attackerTeam == TEAM_SURVIVOR) {
			VerifyHandicap(attacker);
			baseWeaponDamage = GetBaseWeaponDamage(attacker, victim, _, _, _, damagetype);

			if (bAutoRevive[attacker] && !IsIncapacitated(attacker)) bAutoRevive[attacker] = false;
			victimType = (IsCommonInfected(victim)) ? 1 :
							   (IsWitch(victim)) ? 2 :
							   (IsLegitimateClientVictim && victimTeam != TEAM_SURVIVOR) ? 3 :
							   (IsLegitimateClientVictim && victimTeam == TEAM_SURVIVOR) ? 4 : 5;

			int survivorResult = IfSurvivorIsAttackerDoStuff(attacker, victim, baseWeaponDamage, damagetype, victimType);
			if (survivorResult == -1) {
				damage_ignore = 0.0;
				return Plugin_Handled;
			}
			ReadyUp_NtvStatistics(attacker, 0, baseWeaponDamage);
			ReadyUp_NtvStatistics(victim, 8, baseWeaponDamage);
			if (survivorResult == -2) {
				damage_ignore = (baseWeaponDamage * 1.0);
				return Plugin_Changed;
			}
		}
		else if (attackerTeam == TEAM_INFECTED) {
			if (bIsEnrageActive) damage *= fEnrageModifier;
			if (FindZombieClass(attacker) == ZOMBIECLASS_TANK) cTank = attacker;
		}
	}
	if (IsLegitimateClientVictim) {
		if (b_IsLoading[victim]) {
			damage_ignore = 0.0;
			return Plugin_Handled;
		}
		else if (!IsFakeClient(victim) && SkyLevel[victim] < 1 && PlayerLevel[victim] < iPlayerStartingLevel || (IsFakeClient(victim) || IsSurvivorBotVictim) && PlayerLevel[victim] < iBotPlayerStartingLevel) {
			loadtarget = victim;
			ForceLoadDefaultProfiles(loadtarget);
		}
		b_IsDead[victim] = false;
		if (RespawnImmunity[victim]) {
			damage_ignore = 0.0;
			return Plugin_Handled;
		}
		LastAttackTime[victim] = GetEngineTime();
		if (!HasSeenCombat[victim]) HasSeenCombat[victim] = true;
		if ((damagetype & DMG_CRUSH)) {
			if (bIsCrushCooldown[victim]) {

				damage_ignore = 0.0;
				return Plugin_Handled;
			}
			bIsCrushCooldown[victim] = true;
			CreateTimer(1.0, Timer_ResetCrushImmunity, victim, TIMER_FLAG_NO_MAPCHANGE);
		}
		if (victimTeam == TEAM_SURVIVOR) {
			/*	==============================================================================================
				We need to calculate the attackers damage before we calculate the victims damage taken.
				==============================================================================================*/
			bool isCommonInfectedAttacker = IsCommonInfected(attacker);
			attackerType = (isCommonInfectedAttacker) ? 1 :
							   (IsWitch(attacker)) ? 2 :
							   (IsLegitimateClientAttacker && attackerTeam == TEAM_INFECTED) ? 3 :
							   (IsLegitimateClientAttacker && attackerTeam == TEAM_SURVIVOR) ? 4 : 5;
			if (attackerType <= 3) {
				CombatTime[victim] = GetEngineTime() + fOutOfCombatTime;
				JetpackRecoveryTime[victim] = GetEngineTime() + 1.0;
				ToggleJetpack(victim, true);
				if (attackerType == 3) {
					survivorIncomingDamage = IfInfectedIsAttackerDoStuff(attacker, victim);
					ReadyUp_NtvStatistics(attacker, 1, survivorIncomingDamage);
					ReadyUp_NtvStatistics(victim, 8, survivorIncomingDamage);
					if (survivorIncomingDamage == -1) {
						damage_ignore = 0.0;
						return Plugin_Handled;
					}
				}
				else if (attackerType == 2) {
					int i_WitchDamage = iWitchDamageInitial;
					if (IsSpecialCommonInRange(attacker, 'b')) i_WitchDamage += GetSpecialCommonDamage(i_WitchDamage, attacker, 'b', victim);
					if (fWitchDamageScaleLevel > 0.0 && iRPGMode >= 1) {
						if (iBotLevelType == 0) i_WitchDamage += RoundToCeil(fWitchDamageScaleLevel * GetDifficultyRating(victim));
						else i_WitchDamage += RoundToCeil(fWitchDamageScaleLevel * SurvivorLevels());
					}
					if (theCount >= iSurvivorModifierRequired) i_WitchDamage += RoundToCeil(i_WitchDamage * ((theCount - (iSurvivorModifierRequired - 1)) * fSurvivorDamageBonus));
					if (IsClientInRangeSpecialAmmo(victim, "D") == -2.0) DamageShield = RoundToCeil(i_WitchDamage * IsClientInRangeSpecialAmmo(victim, "D", false, _, i_WitchDamage * 1.0));
					if (DamageShield > 0) {
						i_WitchDamage -= DamageShield;
						if (i_WitchDamage < 0) i_WitchDamage = 0;
					}
					TheAbilityMultiplier = GetAbilityMultiplier(victim, "X");
					if (TheAbilityMultiplier >= 1.0) {	// Damage taken reduced to 0.
						damage_ignore = 0.0;
						return Plugin_Handled;
					}
					else if (TheAbilityMultiplier > 0.0) {	// Damage received is reduced by the amount.
						i_WitchDamage -= RoundToCeil(i_WitchDamage * TheAbilityMultiplier);
					}
					if (IsSurvivalMode || RPGRoundTime() < iEnrageTime) Points_Director += (fWitchDirectorPoints * i_WitchDamage);
					else Points_Director += (fEnrageDirectorPoints * i_WitchDamage);
					int damageReduction = RoundToCeil(GetAbilityStrengthByTrigger(victim, attacker, "L", _, i_WitchDamage, _, _, "o", _, true));
					if (damageReduction > 0) {
						int maxDamageReduction = RoundToFloor(i_WitchDamage * fMaxDamageResistance);
						if (damageReduction > maxDamageReduction) damageReduction = maxDamageReduction;
						i_WitchDamage -= damageReduction; // true means we just get the result and don't execute the ability.
					}
					SetClientTotalHealth(victim, i_WitchDamage);
					ReceiveWitchDamage(victim, attacker, i_WitchDamage);
					// Reflect damage.
					if (IsClientInRangeSpecialAmmo(victim, "R") == -2.0) ReflectIncomingDamage = RoundToCeil(i_WitchDamage * IsClientInRangeSpecialAmmo(victim, "R", false, _, i_WitchDamage * 1.0));
					if (ReflectIncomingDamage > 0) AddWitchDamage(victim, attacker, ReflectIncomingDamage);
					survivorIncomingDamage = i_WitchDamage;
				}
				else if (isCommonInfectedAttacker) {
					survivorIncomingDamage = IfCommonInfectedIsAttackerDoStuff(attacker, victim, damagetype, theCount);
					if (survivorIncomingDamage == -1) {
						damage_ignore = 0.0;
						return Plugin_Handled;
					}
				}
			}
			/*	============================================================
				We can now calculate the damage the victim will take.
				============================================================*/
			if (!IsSurvivorBotVictim || iCanSurvivorBotsBurn == 1) {
				char effectToCreate[10];
				if ((damagetype & DMG_BURN) && !DebuffOnCooldown(victim, "burn")) Format(effectToCreate, sizeof(effectToCreate), "burn");
				else if ((damagetype & DMG_SPITTERACID1 || damagetype & DMG_SPITTERACID2) && !DebuffOnCooldown(victim, "acid")) Format(effectToCreate, sizeof(effectToCreate), "acid");
				else Format(effectToCreate, sizeof(effectToCreate), "-1");

				if (!StrEqual(effectToCreate, "-1")) {
					int iBurnCounter = GetClientStatusEffect(victim, effectToCreate);
					if (iBurnCounter < iDebuffLimit && fOnFireDebuff[victim] <= 0.0) {

						if (fOnFireDebuff[victim] == -1.0) {

							ExtinguishEntity(victim);
							fOnFireDebuff[victim] = 0.0;
						}
						else {

							fOnFireDebuff[victim] = fOnFireDebuffDelay;
							ApplyDebuffCooldowns[victim].PushString(effectToCreate);
							if (iRPGMode >= 1) {
								float fAcidDamage = (attackerType == 1) ? fAcidDamageSupersPlayerLevel : fAcidDamagePlayerLevel;
								if (iBotLevelType == 1) {
									if (StrEqual(effectToCreate, "acid")) survivorIncomingDamage += RoundToFloor(survivorIncomingDamage * (SurvivorLevels() * fAcidDamage));
									else survivorIncomingDamage += RoundToFloor(survivorIncomingDamage * (SurvivorLevels() * fBurnPercentage));
								}
								else {
									if (StrEqual(effectToCreate, "acid")) survivorIncomingDamage += RoundToFloor(survivorIncomingDamage * (GetDifficultyRating(victim) * fAcidDamage));
									else survivorIncomingDamage += RoundToFloor(survivorIncomingDamage * (GetDifficultyRating(victim) * fBurnPercentage));
								}
							}
							//PrintToChatAll("DoT Damage: %d %d", survivorIncomingDamage, survivorIncomingDamage * (iBurnCounter + 1));
							CreateAndAttachFlame(victim, survivorIncomingDamage * (iBurnCounter + 1), 10.0, 0.5, FindInfectedClient(true), effectToCreate);
						}
					}
					damage_ignore = 0.0;
					return Plugin_Handled;
				}
			}
			if (IsLegitimateClientAttacker && attackerTeam == TEAM_SURVIVOR) {
				if (SameTeam_OnTakeDamage(attacker, victim, baseWeaponDamage, _, damagetype)) {
					damage_ignore = 0.0;
					return Plugin_Handled;
				}
			}
			if (damagetype & DMG_FALL) {
				int DMGFallDamage = RoundToCeil(damage_ignore);
				int MyInfectedAttacker = L4D2_GetInfectedAttacker(victim);
				if (MyInfectedAttacker != -1) DMGFallDamage = RoundToCeil(DMGFallDamage * 0.4);
				TheAbilityMultiplier = GetAbilityMultiplier(victim, "F");
				if (TheAbilityMultiplier > 0.0) DMGFallDamage -= RoundToCeil(DMGFallDamage * TheAbilityMultiplier);
				if (DMGFallDamage < 100) {
					DMGFallDamage = RoundToCeil((damage_ignore * 0.01) * GetMaximumHealth(victim));
					SetClientTotalHealth(victim, DMGFallDamage, _, true);
				}
				else if (DMGFallDamage >= 100 && DMGFallDamage < 200) SetClientTotalHealth(victim, GetClientTotalHealth(victim), _, true);
				else IncapacitateOrKill(victim, _, _, true);
				damage_ignore = 0.0;
				return Plugin_Handled;
			}
			if (damagetype & DMG_DROWN) {
				if (!IsIncapacitated(victim)) SetClientTotalHealth(victim, GetClientTotalHealth(victim));
				else IncapacitateOrKill(victim, _, _, true);
				damage_ignore = 0.0;
				return Plugin_Handled;
			}
		}
		else {	// infected victim.
			if (FindZombieClass(victim) == ZOMBIECLASS_TANK) cTank = victim;
		}
	}
	if (cTank > 0) {
		if (IsSpecialCommonInRange(cTank, 't') && !bIsDefenderTank[cTank]) {
			// tank copies nearby defender abilities, permanently.
			bIsDefenderTank[cTank] = true;
			SetEntityRenderMode(cTank, RENDER_TRANSCOLOR);
			SetEntityRenderColor(cTank, 0, 0, 255, 200);
		}
	}
	
 	//new StaminaCost = 0;
 	//new baseWeaponTemp = 0;
	// IgnoreTeam = 1 when the attacker is survivor.
	// IgnoreTeam = 2 when the attacker is infected.
	// IgnoreTeam = 3 when the victim is infected.
	// IgnoreTeam = 4 when the victim is common/witch
	// IgnoreTeam = 5 when the attacker is common/witch
	//damage_ignore = 0.0;
	//return Plugin_Handled;

	damage_ignore = baseWeaponDamage * 1.0;
	/*if (victimType == 3 && victimTeam == TEAM_INFECTED ||
		victimType == 1 && FindListPositionByEntity(victim, CommonInfected) >= 0 ||
		victimType == 2 && FindListPositionByEntity(victim, WitchList) >= 0) {*/
	if (victimType >= 1 && victimType <= 3) {
		SetInfectedHealth(victim, 50000);	// we don't want NPC zombies to die prematurely.
		return Plugin_Changed;
	}
	if (IsLegitimateClientVictim && victimTeam == TEAM_SURVIVOR) {
		damage_ignore = survivorIncomingDamage * 1.0;
		return Plugin_Changed;
	}
	return Plugin_Changed;
}

stock int IfCommonInfectedIsAttackerDoStuff(int attacker, int victim, int damagetype, int survivorCount) {
	float CommonDamageScaleLevel = fCommonDamageLevel;
	int CommonsDamage = iCommonInfectedBaseDamage;
	if (IsSpecialCommonInRange(attacker, 'b')) CommonsDamage += GetSpecialCommonDamage(CommonsDamage, attacker, 'b', victim);
	if (!(damagetype & DMG_DIRECT)) {
		if (b_IsJumping[victim]) ModifyGravity(victim);
		if (CommonDamageScaleLevel > 0.0) {
			if (iBotLevelType == 0 && iRPGMode >= 1) CommonsDamage += RoundToCeil(CommonsDamage * (CommonDamageScaleLevel * GetDifficultyRating(victim)));
			else CommonsDamage += RoundToCeil(CommonsDamage * (CommonDamageScaleLevel * SurvivorLevels()));
		}
		if (survivorCount >= iSurvivorModifierRequired) CommonsDamage += RoundToCeil(CommonsDamage * ((survivorCount - (iSurvivorModifierRequired - 1)) * fSurvivorDamageBonus));				
		int DamageShield = 0;
		if (IsClientInRangeSpecialAmmo(victim, "D") == -2.0) DamageShield = RoundToCeil(CommonsDamage * IsClientInRangeSpecialAmmo(victim, "D", false, _, CommonsDamage * 1.0));
		if (DamageShield > 0) {
			CommonsDamage -= DamageShield;
			if (CommonsDamage < 0) CommonsDamage = 0;
		}
		float TheAbilityMultiplier = GetAbilityMultiplier(victim, "X");
		if (TheAbilityMultiplier >= 1.0) return -1;
		else if (TheAbilityMultiplier > 0.0) CommonsDamage -= RoundToCeil(CommonsDamage * TheAbilityMultiplier);
		int damageReduction = RoundToCeil(GetAbilityStrengthByTrigger(victim, attacker, "L", _, CommonsDamage, _, _, "o", _, true));
		if (damageReduction > 0) {
			int maxDamageReduction = RoundToFloor(CommonsDamage * fMaxDamageResistance);
			if (damageReduction > maxDamageReduction) damageReduction = maxDamageReduction;
			CommonsDamage -= damageReduction; // true means we just get the result and don't execute the ability.
		}
		if (IsSurvivalMode || RPGRoundTime() < iEnrageTime) Points_Director += (fCommonDirectorPoints * CommonsDamage);
		else Points_Director += (fEnrageDirectorPoints * CommonsDamage);
		GetAbilityStrengthByTrigger(victim, attacker, "Y", _, CommonsDamage);
		SetClientTotalHealth(victim, CommonsDamage);
		ReceiveCommonDamage(victim, attacker, CommonsDamage);
		GetAbilityStrengthByTrigger(victim, attacker, "L", _, CommonsDamage);
	}
	char TheCommonValue[64];
	bool attackerIsSpecial = IsSpecialCommon(attacker);
	if (attackerIsSpecial) {
		char slevelrequired[10];
		GetCommonValueAtPos(slevelrequired, sizeof(slevelrequired), attacker, SUPER_COMMON_LEVEL_REQ);
		if (PlayerLevel[victim] >= StringToInt(slevelrequired)) {
			GetCommonValueAtPos(TheCommonValue, sizeof(TheCommonValue), attacker, SUPER_COMMON_AURA_EFFECT);

			// Flamers explode when they receive or take damage.
			if (StrEqual(TheCommonValue, "f", true)) CreateDamageStatusEffect(attacker, _, victim, CommonsDamage);
			else if (StrEqual(TheCommonValue, "a", true)) CreateBomberExplosion(attacker, victim, TheCommonValue, CommonsDamage);
			else if (StrEqual(TheCommonValue, "E", true)) {
				char deatheffectshappen[10];
				GetCommonValueAtPos(deatheffectshappen, sizeof(deatheffectshappen), attacker, SUPER_COMMON_DEATH_EFFECT);
				CreateDamageStatusEffect(attacker, _, victim, CommonsDamage);
				CreateBomberExplosion(attacker, victim, deatheffectshappen);
				ClearSpecialCommon(attacker, _, CommonsDamage);
			}
		}
	}
	int BuffDamage = 0;
	if (IsClientInRangeSpecialAmmo(victim, "R") == -2.0) BuffDamage = RoundToCeil(CommonsDamage * IsClientInRangeSpecialAmmo(victim, "R", false, _, CommonsDamage * 1.0));
	if (BuffDamage > 0) {
		if (!attackerIsSpecial) AddCommonInfectedDamage(victim, attacker, BuffDamage);
		else {
			GetCommonValueAtPos(TheCommonValue, sizeof(TheCommonValue), attacker, SUPER_COMMON_AURA_EFFECT);
			if (!StrEqual(TheCommonValue, "d", true)) AddSpecialCommonDamage(victim, attacker, BuffDamage);
			else {	// if a player tries to reflect damage at a reflector, it's moot (ie reflects back to the player) so in this case the player takes double damage, though that's after mitigations.
				SetClientTotalHealth(victim, BuffDamage);
				ReceiveCommonDamage(victim, attacker, BuffDamage);
			}
		}
	}
	return CommonsDamage;
}

stock int IfInfectedIsAttackerDoStuff(int attacker, int victim) {
	CombatTime[victim] = GetEngineTime() + fOutOfCombatTime;
	if (b_IsJumping[victim]) ModifyGravity(victim);
	int myzombieclass = FindZombieClass(attacker);
	int totalIncomingDamage = (myzombieclass != ZOMBIECLASS_TANK) ? iBaseSpecialDamage[myzombieclass - 1] : iBaseSpecialDamage[myzombieclass - 2];
	if (IsSpecialCommonInRange(attacker, 'b')) totalIncomingDamage += GetSpecialCommonDamage(totalIncomingDamage, attacker, 'b', victim);
	int MaxLevelCalc = iMaxDifficultyLevel;

	//Incoming Damage is calculated a very specific way, so that handicap is always the final calculation.
	if (iRPGMode >= 1) {
		if (iBotLevelType == 1) {
			if (myzombieclass != ZOMBIECLASS_TANK) totalIncomingDamage += RoundToFloor(totalIncomingDamage * (SurvivorLevels() * fDamagePlayerLevel[myzombieclass - 1]));
			else totalIncomingDamage += RoundToFloor(totalIncomingDamage * (SurvivorLevels() * fDamagePlayerLevel[myzombieclass - 2]));
		}
		else {
			if (PlayerLevel[victim] < MaxLevelCalc) MaxLevelCalc = PlayerLevel[victim];
			if (myzombieclass != ZOMBIECLASS_TANK) totalIncomingDamage += RoundToFloor(totalIncomingDamage * (GetDifficultyRating(victim) * fDamagePlayerLevel[myzombieclass - 1]));
			else totalIncomingDamage += RoundToFloor(totalIncomingDamage * (GetDifficultyRating(victim) * fDamagePlayerLevel[myzombieclass - 2]));
		}
	}
	int totalIncomingTemp = 0;
	// INFECTED MULTIPLIERS FOR VERSUS AND COOP
	// berserk ammo affects both the attacker and the victim (increases the attackers damage and increases the damage the victim receives)
	if (IsClientInRangeSpecialAmmo(victim, "E") == -2.0) totalIncomingTemp = RoundToCeil(totalIncomingDamage * IsClientInRangeSpecialAmmo(victim, "E", false, _, totalIncomingDamage * 1.0));
	if (totalIncomingTemp > 0) totalIncomingDamage += totalIncomingTemp;
	if (IsClientInRangeSpecialAmmo(attacker, "E") == -2.0) totalIncomingTemp = RoundToCeil(totalIncomingDamage * IsClientInRangeSpecialAmmo(attacker, "E", false, _, totalIncomingDamage * 1.0));
	if (totalIncomingTemp > 0) totalIncomingDamage += totalIncomingTemp;
	int theCount = LivingSurvivorCount();
	if (theCount >= iSurvivorModifierRequired) totalIncomingDamage += RoundToCeil(totalIncomingDamage * ((theCount - (iSurvivorModifierRequired - 1)) * fSurvivorDamageBonus));

	int DamageShield = 0;
	if (IsClientInRangeSpecialAmmo(victim, "D") == -2.0) DamageShield = RoundToCeil(totalIncomingDamage * IsClientInRangeSpecialAmmo(victim, "D", false, _, totalIncomingDamage * 1.0));
	if (DamageShield > 0) {
		totalIncomingDamage -= DamageShield;
		if (totalIncomingDamage < 0) return -1;
	}
	float TheAbilityMultiplier = GetAbilityMultiplier(victim, "X");
	if (TheAbilityMultiplier > 0.9) TheAbilityMultiplier = 0.9;
	if (TheAbilityMultiplier > 0.0) totalIncomingDamage -= RoundToCeil(totalIncomingDamage * TheAbilityMultiplier); // Damage received is reduced by the amount.
	int damageReduction = RoundToCeil(GetAbilityStrengthByTrigger(victim, attacker, "L", _, totalIncomingDamage, _, _, "o", _, true));
	if (damageReduction > 0) {
		int maxDamageReduction = RoundToFloor(totalIncomingDamage * fMaxDamageResistance);
		if (damageReduction > maxDamageReduction) damageReduction = maxDamageReduction;
		totalIncomingDamage -= damageReduction; // true means we just get the result and don't execute the ability.
	}
	//totalIncomingDamage -= RoundToCeil(GetAbilityStrengthByTrigger(victim, attacker, "L", _, totalIncomingDamage, _, _, "o", _, true));
	if (CheckActiveAbility(victim, totalIncomingDamage, 1) > 0.0) {
		SetClientTotalHealth(victim, totalIncomingDamage);
		AddSpecialInfectedDamage(victim, attacker, totalIncomingDamage, true);	// bool is tanking instead.
	}
	if (FindZombieClass(attacker) == ZOMBIECLASS_TANK) CheckTankSubroutine(attacker, victim, totalIncomingDamage);
	if (IsFakeClient(attacker)) {
		if (IsSurvivalMode || RPGRoundTime() < iEnrageTime) Points_Director += (totalIncomingDamage * fPointsMultiplierInfected);
		else Points_Director += ((totalIncomingDamage * fPointsMultiplierInfected) * fEnrageDirectorPoints);
	}
	bool bIsInfectedSwarm = false;
	char weapon[64];
	FindPlayerWeapon(attacker, weapon, sizeof(weapon));
	if (StrEqual(weapon, "insect_swarm")) bIsInfectedSwarm = true;
	if (L4D2_GetSurvivorVictim(attacker) != -1) GetAbilityStrengthByTrigger(attacker, victim, "v", _, totalIncomingDamage);
	if (bIsInfectedSwarm) GetAbilityStrengthByTrigger(attacker, victim, "T", _, totalIncomingDamage);
	GetAbilityStrengthByTrigger(victim, attacker, "L", _, totalIncomingDamage);
	GetAbilityStrengthByTrigger(attacker, victim, "D", _, totalIncomingDamage);
	if (L4D2_GetInfectedAttacker(victim) == attacker) GetAbilityStrengthByTrigger(victim, attacker, "s", _, totalIncomingDamage);
	if (L4D2_GetInfectedAttacker(victim) != -1 && L4D2_GetInfectedAttacker(victim) != attacker) {

		// If the infected player dealing the damage isn't the player hurting the victim, we give the victim a chance to strike at both! This is balance!
		GetAbilityStrengthByTrigger(victim, L4D2_GetInfectedAttacker(victim), "V", _, totalIncomingDamage);
		if (attacker != L4D2_GetInfectedAttacker(victim)) GetAbilityStrengthByTrigger(victim, attacker, "V", _, totalIncomingDamage);
	}
	int ReflectIncomingDamage = 0;
	if (!bIsInfectedSwarm && IsClientInRangeSpecialAmmo(victim, "R") == -2.0) ReflectIncomingDamage = RoundToCeil(totalIncomingDamage * IsClientInRangeSpecialAmmo(victim, "R", false, _, totalIncomingDamage * 1.0));
	if (ReflectIncomingDamage > 0) AddSpecialInfectedDamage(victim, attacker, ReflectIncomingDamage);
	return totalIncomingDamage;
}

stock int IfSurvivorIsAttackerDoStuff(int attacker, int victim, int baseWeaponDamage, int damagetype, int victimType) {
	if (victimType <= 4) {
		if (LastAttackedUser[attacker] == victim) ConsecutiveHits[attacker]++;
		else {
			LastAttackedUser[attacker] = victim;
			ConsecutiveHits[attacker] = 0;
		}
	}
	// we need to move last weapon damage, or record lastweaponbasedamage and lastweaponbuffdamage.
	if (baseWeaponDamage < 1) baseWeaponDamage = 1;
	LastWeaponDamage[attacker] = baseWeaponDamage;
	if (iDisplayHealthBars == 1) DisplayInfectedHealthBars(attacker, victim);
	int infectedResult = 0;
	if (victimType <= 2) {
		infectedResult = TryToDamageNonPlayerInfected(attacker, victim, baseWeaponDamage, damagetype);
		if (infectedResult > 1) {
			SDKUnhook(victim, SDKHook_OnTakeDamage, OnTakeDamage);
			if (!IsSpecialCommon(victim) && (iDeleteCommonsFromExistenceOnDeath == 1 || iDeleteCommonsFromExistenceOnDeath > 1 && CommonInfected.Length >= iDeleteCommonsFromExistenceOnDeath)) AcceptEntityInput(victim, "Kill");
			else SetInfectedHealth(victim, 1);
			OnCommonInfectedCreated(victim, true);
			return -2;
		}
		else if (infectedResult == -1) return -1;
	}
	if (victimType == 3) {
		if (TryToDamagePlayerInfected(attacker, victim, baseWeaponDamage, damagetype) == -1) return -1;
		if (IsSpecialCommonInRange(attacker, 'd') && (damagetype & DMG_BULLET)) SetClientTotalHealth(attacker, baseWeaponDamage);
	}
	
	char weapon[64];
	FindPlayerWeapon(attacker, weapon, sizeof(weapon));
	if ((StrContains(weapon, "melee", false) != -1 || StrContains(weapon, "chainsaw", false) != -1) && bIsMeleeCooldown[attacker]) return -1;
	return 0;
}

stock int TryToDamagePlayerInfected(int attacker, int victim, int baseWeaponDamage, int damagetype) {
	//if (!IsLegitimateClient(victim) || GetClientTeam(victim) != TEAM_INFECTED) return 0;
	//Checks if a Common Defender or a Defender Tank is in range if the 2nd arg isn't left blank
	if (IsSpecialCommonInRange(victim, 't') || DrawSpecialInfectedAffixes(victim, victim) == 1) {
		// If a Defender is within range, the entity is immune.
		// If the entity is a tyrant, it's also immune.
		return -1;
	}
	if (L4D2_GetSurvivorVictim(victim) != -1) GetAbilityStrengthByTrigger(victim, attacker, "t", _, baseWeaponDamage, _, _, _, _, _, _, _, _, damagetype);
	char weapon[64];
	FindPlayerWeapon(attacker, weapon, sizeof(weapon));
	bool bIsMeleeAttack = IsMeleeAttacker(attacker);
	if ((((StrContains(weapon, "molotov", false) != -1 || (damagetype & DMG_BURN)) && iIsSpecialFire != 1) || (!bIsMeleeAttack && TankState[victim] == TANKSTATE_DEATH)) && IsPlayerAlive(victim)) return -1;
	if (StrContains(weapon, "molotov", false) != -1 || !IsPlayerAlive(victim) || RestrictedWeaponList(weapon)) return 0;
	if ((StrContains(weapon, "melee", false) != -1 || StrContains(weapon, "chainsaw", false) != -1) && !bIsMeleeCooldown[attacker]) {
		bIsMeleeCooldown[attacker] = true;
		CreateTimer(0.05, Timer_IsMeleeCooldown, attacker, TIMER_FLAG_NO_MAPCHANGE);
	}
	if (AllowShotgunToTriggerNodes(attacker)) {
		GetAbilityStrengthByTrigger(attacker, victim, "D", _, baseWeaponDamage, _, _, _, _, _, _, _, _, damagetype);
		GetAbilityStrengthByTrigger(victim, attacker, "L", _, baseWeaponDamage, _, _, _, _, _, _, _, _, damagetype);
		
		if (FindZombieClass(victim) == ZOMBIECLASS_TANK) CheckTankSubroutine(victim, attacker, baseWeaponDamage, true);
	}
	if (IsLegitimateClientAlive(victim)) AddSpecialInfectedDamage(attacker, victim, baseWeaponDamage);
	//CombatTime[attacker] = GetEngineTime() + fOutOfCombatTime;
	return 1;
}

stock int TryToDamageNonPlayerInfected(int attacker, int victim, int baseWeaponDamage, int damagetype) {
	//if (!IsWitch(victim) && !IsCommonInfected(victim)) return 0;
	//Checks if a Common Defender or a Defender Tank is in range if the 2nd arg isn't left blank
	if (IsSpecialCommonInRange(victim, 't') || DrawSpecialInfectedAffixes(victim, victim) == 1) {
		// If a Defender is within range, the entity is immune.
		// If the entity is a tyrant, it's also immune.
		return -1;
	}
	char weapon[64];
	char TheCommonValue[10];
	FindPlayerWeapon(attacker, weapon, sizeof(weapon));
	if (StrContains(weapon, "melee", false) == -1 && StrContains(weapon, "chainsaw", false) == -1 || !bIsMeleeCooldown[attacker]) {
		bool isVictimSpecial = IsSpecialCommon(victim);
		bool allowshotgun = AllowShotgunToTriggerNodes(attacker);
		if (StrContains(weapon, "melee", false) != -1 || StrContains(weapon, "chainsaw", false) != -1) {
			bIsMeleeCooldown[attacker] = true;				
			CreateTimer(0.1, Timer_IsMeleeCooldown, attacker, TIMER_FLAG_NO_MAPCHANGE);
		}
		if (allowshotgun) {
			GetAbilityStrengthByTrigger(attacker, victim, "D", _, baseWeaponDamage, _, _, _, _, _, _, _, _, damagetype);
			GetAbilityStrengthByTrigger(victim, attacker, "L", _, baseWeaponDamage, _, _, _, _, _, _, _, _, damagetype);
		}
		if (IsWitch(victim)) {
			//if (FindListPositionByEntity(victim, WitchList) >= 0) {
			AddWitchDamage(attacker, victim, baseWeaponDamage);
			if (GetEntProp(victim, Prop_Send, "m_mobRush") < 1) SetEntProp(victim, Prop_Send, "m_mobRush", 1);
			//}
		}
		else if (isVictimSpecial) AddSpecialCommonDamage(attacker, victim, baseWeaponDamage);
		else if (IsCommonInfected(victim)) {
			AddCommonInfectedDamage(attacker, victim, baseWeaponDamage);
			if (IsCommonInfectedDead(victim)) return baseWeaponDamage;
		}
		if (allowshotgun && CheckTeammateDamages(victim, attacker) < 1.0) {
			if (isVictimSpecial) {
				GetCommonValueAtPos(TheCommonValue, sizeof(TheCommonValue), victim, SUPER_COMMON_DAMAGE_EFFECT);
				// The bomber explosion initially targets itself so that the chain-reaction (if enabled) doesn't go indefinitely.
				if (StrEqual(TheCommonValue, "f", true)) CreateDamageStatusEffect(victim, _, attacker, baseWeaponDamage);
				// Cannot trigger on survivor bots because they're frankly too stupid and it wouldn't be fair.
				else if (StrEqual(TheCommonValue, "d", true)) CreateDamageStatusEffect(victim, 3, attacker, baseWeaponDamage);		// attacker is not target but just used to pass for reference.
			}
		}
		//CombatTime[attacker] = GetEngineTime() + fOutOfCombatTime;
	}
	return 1;
}

stock bool IsMeleeAttacker(int client) {

	char weapon[64];
	GetClientWeapon(client, weapon, sizeof(weapon));
	if (StrContains(weapon, "melee", false) != -1 || StrContains(weapon, "chainsaw", false) != -1) {
		return true;
		//if (!bIsMeleeCooldown[client] || cooldownIsIgnored) return true;
		//return false;
	}
	return false;
}

stock void SpawnAnyInfected(int client) {

	if (IsLegitimateClientAlive(client)) {

		char InfectedName[20];
		int rand = GetRandomInt(1,6);
		if (rand == 1) Format(InfectedName, sizeof(InfectedName), "smoker");
		else if (rand == 2) Format(InfectedName, sizeof(InfectedName), "boomer");
		else if (rand == 3) Format(InfectedName, sizeof(InfectedName), "hunter");
		else if (rand == 4) Format(InfectedName, sizeof(InfectedName), "spitter");
		else if (rand == 5) Format(InfectedName, sizeof(InfectedName), "jockey");
		else Format(InfectedName, sizeof(InfectedName), "charger");
		Format(InfectedName, sizeof(InfectedName), "%s auto", InfectedName);

		ExecCheatCommand(client, "z_spawn_old", InfectedName);
	}
}

stock int GetInfectedCount(int zombieclass = 0) {

	int count = 0;
	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClientAlive(i) && GetClientTeam(i) == TEAM_INFECTED && (zombieclass == 0 || FindZombieClass(i) == zombieclass)) count++;
	}
	return count;
}

stock void CreateMyHealthPool(int client, bool IMeanDeleteItInstead = false) {

	int whatami = 3;
	if (IsSpecialCommon(client)) whatami = 1;
	else if (IsWitch(client)) whatami = 2;
	else if (IsCommonInfected(client)) return;

	/*if (IsLegitimateClientAlive(client) && FindZombieClass(client) == ZOMBIECLASS_TANK && iTankRush == 1) {

		SetSpeedMultiplierBase(client, 1.0);
	}*/

	/*if (!b_IsFinaleActive && IsEnrageActive() && whatami == 3 && IsLegitimateClientAlive(client) && GetClientTeam(client) == TEAM_INFECTED && FindZombieClass(client) == ZOMBIECLASS_TANK && !IsTyrantExist()) {

		IsTyrant[client] = true;
		SetEntityRenderMode(client, RENDER_TRANSCOLOR);
		SetEntityRenderColor(client, 0, 255, 0, 255);
	}
	else*/

	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && GetClientTeam(i) == TEAM_SURVIVOR) {

			if (!IMeanDeleteItInstead) {

				if (whatami == 1) AddSpecialCommonDamage(i, client, -1);
				else if (whatami == 2) AddWitchDamage(i, client, -1);
				else if (whatami == 3) AddSpecialInfectedDamage(i, client, -1);
			}
			else {

				if (whatami == 1) AddSpecialCommonDamage(i, client, -2);
				else if (whatami == 2) AddWitchDamage(i, client, -2);
				else if (whatami == 3) AddSpecialInfectedDamage(i, client, -2);
			}
		}
	}
	return;
}

stock int EnsnaredInfected() {

	int count = 0;
	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && IsFakeClient(i) && GetClientTeam(i) == TEAM_INFECTED && IsEnsnarer(i)) count++;
	}
	return count;
}

stock bool IsEnsnarer(int client, int class = 0) {

	int zombieclass = class;
	if (class == 0) zombieclass = FindZombieClass(client);
	if (zombieclass == ZOMBIECLASS_HUNTER ||
		zombieclass == ZOMBIECLASS_SMOKER ||
		zombieclass == ZOMBIECLASS_JOCKEY ||
		zombieclass == ZOMBIECLASS_CHARGER) return true;
	return false;
}

/*bool:HasInstanceGenerated(client, target) {
	if (FindListPositionByEntity(target, InfectedHealth[client]) >= 0) return true;
	return false;
}*/

stock int AddSpecialInfectedDamage(int client, int target, int TotalDamage, bool IsTankingInstead = false, int damagevariant = -1) {

	int isEntityPos = FindListPositionByEntity(target, InfectedHealth[client]);
	//new f 0;
	if (isEntityPos >= 0 && TotalDamage <= -1) {

		// delete the mob.
		InfectedHealth[client].Erase(isEntityPos);
		if (TotalDamage == -2) return 0;
		isEntityPos = -1;
	}

	int myzombieclass = FindZombieClass(target, true);
	if (myzombieclass < 1 || myzombieclass > 8) return 0;

	if (isEntityPos < 0) {

		int t_InfectedHealth = DefaultHealth[target];
		isEntityPos = InfectedHealth[client].Length;
		InfectedHealth[client].Resize(isEntityPos + 1);
		InfectedHealth[client].Set(isEntityPos, target, 0);

		//An infected wasn't added on spawn to this player, so we add it now based on class.
		if (myzombieclass == ZOMBIECLASS_TANK) t_InfectedHealth = 4000;
		else if (myzombieclass == ZOMBIECLASS_HUNTER || myzombieclass == ZOMBIECLASS_SMOKER) t_InfectedHealth = 200;
		else if (myzombieclass == ZOMBIECLASS_BOOMER) t_InfectedHealth = 50;
		else if (myzombieclass == ZOMBIECLASS_SPITTER) t_InfectedHealth = 100;
		else if (myzombieclass == ZOMBIECLASS_CHARGER) t_InfectedHealth = 600;
		else if (myzombieclass == ZOMBIECLASS_JOCKEY) t_InfectedHealth = 300;

		OriginalHealth[target] = t_InfectedHealth;
		GetAbilityStrengthByTrigger(target, _, "a", _, 0);
		if (DefaultHealth[target] < OriginalHealth[target]) DefaultHealth[target] = OriginalHealth[target];
		if (!IsFakeClient(target)) {

			DefaultHealth[target] = SetMaximumHealth(target);
		}
		else OverHealth[target] = 0;

		if (iBotLevelType == 1) {

			if (myzombieclass != ZOMBIECLASS_TANK) t_InfectedHealth += RoundToCeil(t_InfectedHealth * (SurvivorLevels() * fHealthPlayerLevel[myzombieclass - 1]));
			else t_InfectedHealth += RoundToCeil(t_InfectedHealth * (SurvivorLevels() * fHealthPlayerLevel[myzombieclass - 2]));
		}
		else {

			if (myzombieclass != ZOMBIECLASS_TANK) t_InfectedHealth += RoundToCeil(t_InfectedHealth * (GetDifficultyRating(client) * fHealthPlayerLevel[myzombieclass - 1]));
			else t_InfectedHealth += RoundToCeil(t_InfectedHealth * (GetDifficultyRating(client) * fHealthPlayerLevel[myzombieclass - 2]));
		}

		// only add raid health if > 4 survivors.
		int theCount = LivingSurvivorCount();
		if (theCount >= iSurvivorModifierRequired) t_InfectedHealth += RoundToCeil(t_InfectedHealth * ((theCount - (iSurvivorModifierRequired - 1)) * fSurvivorHealthBonus));

		InfectedHealth[client].Set(isEntityPos, t_InfectedHealth + OverHealth[target], 1);
		InfectedHealth[client].Set(isEntityPos, 0, 2);
		InfectedHealth[client].Set(isEntityPos, 0, 3);
		InfectedHealth[client].Set(isEntityPos, 0, 4);
		// This slot is only for versus/human infected players; health remaining after "ARMOR" (global health) is gone.

		if (!bHealthIsSet[target]) {

			bHealthIsSet[target] = true;
			InfectedHealth[target].Resize(InfectedHealth[target].Length + 1);
			InfectedHealth[target].Set(0, DefaultHealth[target], 5);
			InfectedHealth[target].Set(0, 0, 6);
			//Handle InfectedHealth[client].Set(isEntityPos, t_InfectedHealth, 5);
		}
	}
	if (TotalDamage < 1) return 0;

	int i_DamageBonus = TotalDamage;
	int i_InfectedMaxHealth = InfectedHealth[client].Get(isEntityPos, 1);
	int i_InfectedCurrent = InfectedHealth[client].Get(isEntityPos, 2);
	if (i_InfectedCurrent < 0) i_InfectedCurrent = 0;
	//if (i_DamageBonus > TrueHealthRemaining) i_DamageBonus = TrueHealthRemaining;

	if (!IsTankingInstead) {
		int i_HealthRemaining = i_InfectedMaxHealth - i_InfectedCurrent;
		if (i_DamageBonus > i_HealthRemaining) i_DamageBonus = i_HealthRemaining;

		if (IsSpecialCommonInRange(target, 't')) return 0;
		if (damagevariant != 2 && i_DamageBonus > 0) {
			GetProficiencyData(client, GetWeaponProficiencyType(client), RoundToCeil(i_DamageBonus * fProficiencyExperienceEarned));

			InfectedHealth[client].Set(isEntityPos, i_InfectedCurrent + i_DamageBonus, 2);

			// Eyal282 here. Warnings are evil.
			//RoundDamageTotal += (i_DamageBonus);
			RoundDamage[client] += (i_DamageBonus);

			/*if (damagevariant == 1) AddTalentExperience(client, "endurance", i_DamageBonus);
			else if (damagevariant == -1) {

				new bool:bIsMeleeAttack = IsMeleeAttacker(client);
				if (!bIsMeleeAttack) AddTalentExperience(client, "agility", i_DamageBonus);
				else AddTalentExperience(client, "constitution", i_DamageBonus);
			}*/
		}
		else {

			InfectedHealth[client].Set(isEntityPos, i_InfectedMaxHealth - i_DamageBonus, 1);	// lowers the total health pool if variant = 2 (bot damage)
		}
	}
	else {
		i_InfectedCurrent += i_DamageBonus;
		InfectedHealth[client].Set(isEntityPos, i_InfectedCurrent, 3);
	}
	ThreatCalculator(client, i_DamageBonus);
	CheckTeammateDamagesEx(client, target, i_DamageBonus);
	return 0;
}

stock void ThreatCalculator(int client, int iThreatAmount) {

	if (IsLegitimateClientAlive(client) && GetClientTeam(client) == TEAM_SURVIVOR) {

		float TheAbilityMultiplier = GetAbilityMultiplier(client, "t");
		if (TheAbilityMultiplier != -1.0) {

			TheAbilityMultiplier *= (iThreatAmount * 1.0);
			iThreatLevel[client] += (iThreatAmount - RoundToFloor(TheAbilityMultiplier));
		}
		else {

			iThreatLevel[client] += iThreatAmount;
		}
	}
}

stock int AddSpecialCommonDamage(int client, int entity, int playerDamage, bool IsStatusDamage = false, int damagevariant = -1) {

	//if (!IsSpecialCommon(entity)) return 1;
	int pos		= FindListPositionByEntity(entity, CommonList);
	if (pos < 0 || IsSpecialCommonInRange(entity, 't')) return 1;
	int damageTotal = -1;
	int my_size	= SpecialCommon[client].Length;
	int my_pos	= FindListPositionByEntity(entity, SpecialCommon[client]);
	if (my_pos >= 0 && playerDamage <= -1) {
		// delete the mob.
		SpecialCommon[client].Erase(my_pos);
		if (playerDamage == -2) return 0;
		my_pos = -1;
	}
	if (my_pos < 0) {
		int CommonHealth = GetCommonValueIntAtPos(entity, SUPER_COMMON_BASE_HEALTH);
		if (iBotLevelType == 1) CommonHealth += RoundToCeil(CommonHealth * (SurvivorLevels() * GetCommonValueFloatAtPos(entity, SUPER_COMMON_HEALTH_PER_LEVEL)));
		else CommonHealth += RoundToCeil(CommonHealth * (GetDifficultyRating(client) * GetCommonValueFloatAtPos(entity, SUPER_COMMON_HEALTH_PER_LEVEL)));
		// only add raid health if > 4 survivors.
		int theCount = LivingSurvivorCount();
		if (theCount >= iSurvivorModifierRequired) CommonHealth += RoundToCeil(CommonHealth * ((theCount - (iSurvivorModifierRequired - 1)) * fSurvivorHealthBonus));
		SpecialCommon[client].Resize(my_size + 1);
		SpecialCommon[client].Set(my_size, entity, 0);
		SpecialCommon[client].Set(my_size, CommonHealth, 1);
		SpecialCommon[client].Set(my_size, 0, 2);
		SpecialCommon[client].Set(my_size, 0, 3);
		SpecialCommon[client].Set(my_size, 0, 4);
		my_pos = my_size;
	}
	if (playerDamage >= 0) {
		damageTotal = SpecialCommon[client].Get(my_pos, 2);
		//new TrueHealthRemaining = RoundToCeil((1.0 - CheckTeammateDamages(entity, client)) * healthTotal);	// in case other players have damaged the mob - we can't just assume the remaining health without comparing to other players.
		if (damageTotal < 0) damageTotal = 0;
		//if (playerDamage > TrueHealthRemaining) playerDamage = TrueHealthRemaining;
		SpecialCommon[client].Set(my_pos, damageTotal + playerDamage, 2);
		if (playerDamage > 0) {
			CheckTeammateDamagesEx(client, entity, playerDamage);
			GetProficiencyData(client, GetWeaponProficiencyType(client), RoundToCeil(playerDamage * fProficiencyExperienceEarned));
		}
	}
	else {
		damageTotal = SpecialCommon[client].Get(my_pos, 1);
		SpecialCommon[client].Set(my_pos, damageTotal + playerDamage, 1);
	}
	//ThreatCalculator(client, playerDamage);
	/*if (CheckIfEntityShouldDie(entity, client, playerDamage, IsStatusDamage) == 1) {
		if (IsLegitimateClientAlive(client) && GetClientTeam(client) == TEAM_SURVIVOR && IsIncapacitated(client)) {
			GetAbilityStrengthByTrigger(client, entity, "K", FindZombieClass(client), playerDamage);
		}
		return (damageTotal + playerDamage);
	}*/
	return 1;
}

stock void AwardExperience(int client, int type = 0, int AMOUNT = 0, bool TheRoundHasEnded=false) {

	char pct[4];
	Format(pct, sizeof(pct), "%");

	if (type == -1){//} && RoundExperienceMultiplier[client] > 0.0) {	//	This occurs when a player fully loads-in to a game, and is bonus container from previous round.

		//new RewardWaiting = RoundToCeil(BonusContainer[client] * RoundExperienceMultiplier[client]);
		//BonusContainer[client] += RoundToCeil(BonusContainer[client] * RoundExperienceMultiplier[client]);
		//PrintToChat(client, "%T", "bonus experience waiting", client, blue, green, AddCommasToString(RewardWaiting), blue, orange, blue, orange, blue, green, RoundExperienceMultiplier[client] * 100.0, pct);
		//PrintToChat(client, "%T", "round bonus private", )
		return;
	}

	int InfectedBotLevelType = iBotLevelType;

	if (!TheRoundHasEnded && AMOUNT > 0 && (bIsInCombat[client] || !bIsInCombat[client] || InfectedBotLevelType == 1 || b_IsFinaleActive || IsEnrageActive() || DoomTimer != 0)) {

		int bAMOUNT = 0;
		if (RoundExperienceMultiplier[client] > 0.0) {

			bAMOUNT = AMOUNT + RoundToCeil(AMOUNT * RoundExperienceMultiplier[client]);
		}
		else bAMOUNT = AMOUNT;
		if (type == 1) HealingContribution[client] += bAMOUNT;
		else if (type == 2) BuffingContribution[client] += bAMOUNT;
		else if (type == 3) HexingContribution[client] += bAMOUNT;
		//AddTalentExperience(client, "endurance", bAMOUNT);
	}
	if (TheRoundHasEnded || !b_IsFinaleActive && !IsEnrageActive() && AMOUNT == 0 && !bIsInCombat[client]) {

		//float PointsMultiplier = fPointsMultiplier;
		float HealingMultiplier = fHealingMultiplier;
		float BuffingMultiplier = fBuffingMultiplier;
		float HexingMultiplier = fHexingMultiplier;

		if (IsPlayerAlive(client)) {

			int h_Contribution = 0;
			if (HealingContribution[client] > 0) h_Contribution = RoundToCeil(HealingContribution[client] * HealingMultiplier);

			//float SurvivorPoints = 0.0;
			//if (h_Contribution > 0) SurvivorPoints = (h_Contribution * (PointsMultiplier * HealingMultiplier));

			int Bu_Contribution = 0;
			if (BuffingContribution[client] > 0) Bu_Contribution = RoundToCeil(BuffingContribution[client] * BuffingMultiplier);

			//if (Bu_Contribution > 0) SurvivorPoints += (Bu_Contribution * (PointsMultiplier * BuffingMultiplier));

			int He_Contribution = 0;
			if (HexingContribution[client] > 0) He_Contribution = RoundToCeil(HexingContribution[client] * HexingMultiplier);
			//if (He_Contribution > 0) SurvivorPoints += (He_Contribution * (PointsMultiplier * HexingMultiplier));

			//ReceiveInfectedDamageAward(client, 0, DamageContribution[client], PointsContribution[client], TankingContribution[client], h_Contribution, Bu_Contribution, He_Contribution, TheRoundHasEnded);
			ReceiveInfectedDamageAward(client, 0, DamageContribution[client], PointsContribution[client], TankingContribution[client], h_Contribution, Bu_Contribution, He_Contribution, TheRoundHasEnded);
		}
		HealingContribution[client] = 0;
		PointsContribution[client] = 0.0;
		TankingContribution[client] = 0;
		DamageContribution[client] = 0;
		BuffingContribution[client] = 0;
		HexingContribution[client] = 0;
			//ReceiveInfectedDamageAward(i, client, SurvivorExperience, SurvivorPoints, t_Contribution, h_Contribution);
	}
}
// Eyal282 here. Warnings are evil.
/*
stock bool IsClassType(int client, char[] SearchString) {
}
*/
stock int GetPassiveStrength(int client, char[] SearchKey, char[] TalentName, int TheSize = 64) {

	if (IsLegitimateClient(client)) {

		int size = a_Menu_Talents.Length;
		char SearchValue[64];
		//decl char[] TalentName[64];
		Format(TalentName, TheSize, "-1");
		int pos = -1;

		for (int i = 0; i < size; i++) {

			PassiveStrengthKeys[client] = a_Menu_Talents.Get(i, 0);
			PassiveStrengthValues[client] = a_Menu_Talents.Get(i, 1);

			
			PassiveStrengthValues[client].GetString(PASSIVE_ABILITY, SearchValue, sizeof(SearchValue));
			
			if (!StrEqual(SearchKey, SearchValue)) continue;
			PassiveTalentName[client] = a_Menu_Talents.Get(i, 2);
			PassiveTalentName[client].GetString(0, TalentName, TheSize);

			pos = GetDatabasePosition(client, TalentName);
			if (pos >= 0) {

				//GCMKeys[client] = PassiveStrengthKeys[client];
				//GCMValues[client] = PassiveStrengthValues[client];

				return a_Database_PlayerTalents[client].Get(pos);
			}
			break;	// should never get here unless there's a spelling mistake in code/config
		}
	}
	return 0;
}

stock float GetPassiveInfo(int client, int target, ArrayList Keys, ArrayList Values, char[] TalentName, bool bIsCreateCooldown = false) {
	float f_EachPoint	= GetTalentInfo(client, Values, 1, _, TalentName, target);
	float f_Cooldown	= GetTalentInfo(client, Values, 3, _, TalentName, target);
	float f_Strength			=	f_EachPoint;
	if (bIsCreateCooldown && f_Cooldown > 0.00) CreateCooldown(client, GetTalentPosition(client, TalentName), f_Cooldown);
	return f_Strength;
}

stock int GetDatabasePosition(int client, char[] TalentName) {

	int size				=	0;
	if (client != -1) size	=	a_Database_PlayerTalents[client].Length;
	else size				=	a_Database_PlayerTalents_Bots.Length;
	char text[64];

	for (int i = 0; i < size; i++) {

		a_Database_Talents.GetString(i, text, sizeof(text));
		if (StrEqual(TalentName, text)) return i;
	}
	return -1;
}

stock int TalentRequirementsMet(int client, ArrayList Keys, ArrayList Values, char[] sTalentList = "none", int TheSize = 0, int requiredTalentsToUnlock = 0) {
	int pos = TALENT_FIRST_RANDOM_KEY_POSITION;
	char TalentName[64];
	char text[64];
	char talentTranslation[64];
	int count = 0;
	while (pos >= 0) {
		pos = FormatKeyValue(TalentName, sizeof(TalentName), Keys, Values, "talents required?", _, _, pos, false);
		if (!StrEqual(sTalentList, "none")) {
			if (pos < 0) {
				Format(sTalentList, TheSize, "%s", text);
				break;
			}

			if (GetTalentStrength(client, TalentName) < 1) {
				count++;
				GetTranslationOfTalentName(client, TalentName, talentTranslation, sizeof(talentTranslation), true);
				Format(talentTranslation, sizeof(talentTranslation), "%T", talentTranslation, client);
				if (count > 1) Format(text, sizeof(text), "%s\n%s", text, talentTranslation);
				else Format(text, sizeof(text), "%s", talentTranslation);
			}
			else requiredTalentsToUnlock--;
		}
		else {
			if (GetTalentStrength(client, TalentName) > 0) requiredTalentsToUnlock--;
			else count++;
		}
		if (TheSize == -1) return count;
		if (pos == -1) break;
		pos++;
	}
	return requiredTalentsToUnlock;
	//return true;
	//return (requiredTalentsToUnlock <= 0) ? true : false;
}

/*bool:DontAllowShotgunDamage(int client) {
	if (IsLegitimateClient(client) && IsPlayerUsingShotgun(client) && shotgunCooldown[client]) return true;
	return false;
}*/

stock bool IsStatusEffectFound(int client, ArrayList Keys, ArrayList Values) {
	char statusEffectToSearchFor[64];
	int pos = TALENT_FIRST_RANDOM_KEY_POSITION;
	while (pos >= 0) {
		pos = FormatKeyValue(statusEffectToSearchFor, sizeof(statusEffectToSearchFor), Keys, Values, "positive effect required?", _, _, pos, false);
		if (pos == -1) break;
		// if we can't find the positive status effect.
		if (StrContains(ClientStatusEffects[client][1], statusEffectToSearchFor, true) == -1) return false;
		pos++;
	}
	pos = TALENT_FIRST_RANDOM_KEY_POSITION;
	while (pos >= 0) {
		pos = FormatKeyValue(statusEffectToSearchFor, sizeof(statusEffectToSearchFor), Keys, Values, "negative effect required?", _, _, pos, false);
		if (pos == -1) break;
		// if we can't find the negative status effect.
		if (StrContains(ClientStatusEffects[client][0], statusEffectToSearchFor, true) == -1) return false;
		pos++;
	}
	// If all status effects are found (or none are found)
	return true;
}

stock bool IsAbilityFound(ArrayList Keys, ArrayList Values, char[] tSubstring) {
	char searchString[64];
	int pos = TALENT_FIRST_RANDOM_KEY_POSITION;
	while (pos >= 0) {
		pos = FormatKeyValue(searchString, sizeof(searchString), Keys, Values, "ability trigger?", _, _, pos, false);
		if (pos == -1) break;
		if (StrEqual(searchString, tSubstring)) return true;
		pos++;
	}
	return false;
}

stock void GetGoverningAttribute(int client, char[] TalentName, char[] governingAttribute, int theSize) {
	char text[64];
	int size = a_Menu_Talents.Length;
	for (int i = 0; i < size; i++) {
		GetGoverningAttributeSection[client]	= a_Menu_Talents.Get(i, 2);
		GetGoverningAttributeSection[client].GetString(0, text, sizeof(text));
		if (!StrEqual(TalentName, text)) continue;

		//GetGoverningAttributeKeys[client]		= a_Menu_Talents.Get(i, 0);
		GetGoverningAttributeValues[client]		= a_Menu_Talents.Get(i, 1);
		GetGoverningAttributeValues[client].GetString(GOVERNING_ATTRIBUTE, text, sizeof(text));
		if (StrEqual(text, "-1")) Format(governingAttribute, theSize, "-1");
		else GetTranslationOfTalentName(client, text, governingAttribute, theSize, true, _, true);
		break;
	}
}

stock void GetTranslationOfTalentName(int client, char[] nameOfTalent, char[] translationText, int theSize, bool bGetTalentNameInstead = false, bool bJustKiddingActionBarName = false, bool returnResult = false) {
	char talentName[64];
	int size = a_Menu_Talents.Length;

	for (int i = 0; i < size; i++) {
		TranslationOTNSection[client]	= a_Menu_Talents.Get(i, 2);
		TranslationOTNSection[client].GetString(0, talentName, sizeof(talentName));
		if (!returnResult && !StrEqual(talentName, nameOfTalent) ||
			returnResult && StrContains(talentName, nameOfTalent, false) == -1) continue;
		//TranslationOTNKeys[client]		= a_Menu_Talents.Get(i, 0);
		TranslationOTNValues[client]	= a_Menu_Talents.Get(i, 1);
		// Just a quick hack, I'll fix this later when I have time.
		// it works why change it?
		if (bJustKiddingActionBarName) {
			TranslationOTNValues[client].GetString(ACTION_BAR_NAME, translationText, theSize);
		}
		else if (!bGetTalentNameInstead) {
			TranslationOTNValues[client].GetString(GET_TRANSLATION, translationText, theSize);
			//if (StrEqual(translationText, "-1")) SetFailState("No \"translation?\" set for Talent %s in /configs/readyup/rpg/talentmenu.cfg", talentName);
			//else break;
		}
		else {
			TranslationOTNValues[client].GetString(GET_TALENT_NAME, translationText, theSize);
			if (!returnResult && StrEqual(translationText, "-1")) Format(translationText, theSize, "%s", talentName);
		}
		break;
	}
}

stock float GetAbilityStrengthByTrigger(int activator, int target = 0, char[] AbilityT, int zombieclass = 0, int damagevalue = 0,
										bool IsOverdriveStacks = false, bool IsCleanse = false, char[] ResultEffects = "none",
										int ResultType = 0, bool bDontActuallyActivate = false, int typeOfValuesToRetrieve = 1,
										int hitgroup = -1, char[] abilityTrigger = "none", int damagetype = -1) {// activator, target, trigger ability, survivor effects, infected effects, 
														//common effects, zombieclass, damage typeofvalues: 0 (all) 1 (NO RAW) 2(raw values only)
	if (iRPGMode <= 0 || !IsLegitimateClient(activator)) return 0.0;
	// ResultType:
	// 0 Activator
	// 1 Target, but returns additive*multiplicative result.
	// 2 Target, but returns multiplicative result.
	//ResultEffects are so when compounding talents we know which type to pull from.
	//This is an alternative to GetAbilityStrengthByTrigger for talents that need it, and maybe eventually the whole system.
	if (target == -2) target = FindAnyRandomClient();
	if (target < 1) target = activator;
	if (!IsLegitimateClient(activator)) return 0.0;

	int talenttarget = 0;
	if (target != activator && IsLegitimateClient(target)) talenttarget = target;

	char activatorteam[10];
	char targetteam[10];
	char activatoreffects[64];
	char targeteffects[64];
	char secondaryEffects[64];
	char secondaryTrigger[64];
	char TargetClassRequired[32];
	char ActivatorClass[32];
	char TargetClass[32];
	int targetEntityType = -1;
	//new activatorEntityType = 0;
	//new bool:activatorIsSurvivorBot = IsSurvivorBot(activator);
	if (IsLegitimateClient(target)) {

		if (GetClientTeam(target) == TEAM_INFECTED) {
			Format(TargetClass, sizeof(TargetClass), "%d", FindZombieClass(target));
			targetEntityType = 3;
		}
		else {
			Format(TargetClass, sizeof(TargetClass), "0");
			targetEntityType = 4;
		}
	}
	else if (IsWitch(target)) {
		Format(TargetClass, sizeof(TargetClass), "7");
		targetEntityType = 2;
	}
	else if (IsSpecialCommon(target)) {
		Format(TargetClass, sizeof(TargetClass), "9");
		targetEntityType = 1;
	}
	else {	// normal commons
		Format(TargetClass, sizeof(TargetClass), "a");
		targetEntityType = 0;
	}

	if (GetClientTeam(activator) == TEAM_INFECTED) Format(ActivatorClass, sizeof(ActivatorClass), "%d", FindZombieClass(activator));
	else Format(ActivatorClass, sizeof(ActivatorClass), "0");

	Format(activatorteam, sizeof(activatorteam), "%d", GetClientTeam(activator));
	Format(targetteam, sizeof(targetteam), "0");

	char WeaponsPermitted[512];
	char PlayerWeapon[64];
	if (GetClientTeam(activator) == TEAM_SURVIVOR) {
		GetClientWeapon(activator, PlayerWeapon, sizeof(PlayerWeapon));
	}
	else Format(PlayerWeapon, sizeof(PlayerWeapon), "ignore");
	bool activatorIsSurvivor = (GetClientTeam(activator) == TEAM_SURVIVOR) ? true : false;
	float f_Strength			= 0.0;
	//new Float:f_FirstPoint			= 0.0;
	float f_EachPoint			= 0.0;
	float f_Time				= 0.0;
	float f_Cooldown			= 0.0;
	float p_Strength			= 0.0;
	float eotStrength			= 0.0;
	float t_Strength			= 0.0;
	float p_Time				= 0.0;
	bool bIsCompounding = false;
	char TalentName[64];
	bool iHasWeakness = PlayerHasWeakness(activator);
	bool activatorIsStaggered = IsStaggered(activator);
	bool targetIsStaggered = (activator == target) ? activatorIsStaggered : IsStaggered(target);
	char TheString[64];
	char MultiplierText[64];
	//new Float:ExplosiveAmmoRange = 0.0;
	int TheTalentStrength = 0;
	int CombatStateRequired;
	//new Float:healregenrange = -1.0;
	//new Float:healerpos[3], Float:targetpos[3];
	int iStrengthOverride = 0;
	//decl String:sClassAllowed[64];
	//decl String:sClassID[64];
	//new requiredTalentsRequired = 0;
	bool bIsStatusEffects = false;
	//new nodeUnlockCost = 0;
	int isRawType = 0;
	bool activatorBileStatus = IsCoveredInBile(activator);
	bool targetBileStatus = IsCoveredInBile(target);
	int hitgroupType = GetHitgroupType(hitgroup);
	int consecutiveHitsRequired = 0;
	float fMultiplyRange = 0.0;
	int iMultiplyCount = 0;
	bool isScoped = false;
	//if (!IsFakeClient(activator)) isScoped = IsPlayerZoomed(activator);
	float playerZoomTime = 0.0;//= GetActiveZoomTime(activator);
	float fPlayerMaxZoomTime = 0.0;
	float playerHoldingFireTime = 0.0;
	float activatorPos[3];
	GetEntPropVector(activator, Prop_Send, "m_vecOrigin", activatorPos);
	int activatorHighGroundResult = 0;
	if (!IsFakeClient(activator)) {
		playerHoldingFireTime = GetHoldingFireTime(activator);
		playerZoomTime =  GetActiveZoomTime(activator);
		isScoped = IsPlayerZoomed(activator);
	}
	float fPlayerMaxHoldingFireTime = 0.0;
	int ASize = a_Menu_Talents.Length;
	bool IsAFakeClient = IsFakeClient(activator);
	int activatorFlags = GetEntityFlags(activator);
	int targetFlags = (IsLegitimateClient(target)) ? GetEntityFlags(target) : -1;
	bool isTargetInTheAir = (targetFlags != -1 && !(targetFlags & FL_ONGROUND)) ? true : false;
	bool activatorHasAdrenaline = HasAdrenaline(activator);
	bool activatorIsTouchingTheGround = (activatorFlags & FL_ONGROUND) ? true : false;
	bool activatorIsDucking = (activatorFlags & IN_DUCK) ? true : false;
	bool targetIsSurvivor = (IsLegitimateClient(target) && GetClientTeam(target) == TEAM_SURVIVOR) ? true : false;
	int activatorCombatState = (bIsInCombat[activator]) ? 1 : 0;
	int infectedAttacker = L4D2_GetInfectedAttacker(activator);
	bool incapState = IsIncapacitated(activator);
	bool ledgeState = IsLedged(activator);
	int activatorTeamInt = GetClientTeam(activator);
	float fPercentageHealthRemaining = ((GetClientHealth(activator) * 1.0) / (GetMaximumHealth(activator) * 1.0));
	float fPercentageHealthRequired = 0.0;
	float fPercentageHealthRequiredMax = 0.0;
	float fPercentageHealthMissing = 1.0 - fPercentageHealthRemaining;
	int iSurvivorsInRange = 0;
	int iCoherencyMax = 0;
	float fPercentageHealthTargetRemaining = GetClientHealthPercentage(activator, target, true);
	float fPercentageHealthTargetMissing = 1.0 - fPercentageHealthTargetRemaining;
	float fTargetRangeRequired = 0.0;
	float fTargetRange = GetTargetRange(activator, target);
	bool bTargetMustBeWithinRange = false;
	bool bTalentRequiresLimbshot = false;
	bool bTalentRequiresHeadshot = false;
	bool bTargetIsLastTarget = (target == lastTarget[activator]) ? true : false;
	int iLastTargetResult = -1;
	bool activatorIsOnFire = (GetClientStatusEffect(activator, "burn") > 0) ? true : false;
	bool activatorIsSufferingAcidBurn = (GetClientStatusEffect(activator, "acid") > 0) ? true : false;
	bool activatorIsExploding = (ISEXPLODE[activator] != INVALID_HANDLE) ? true : false;
	bool activatorIsSlowed = ((ISSLOW[activator] != INVALID_HANDLE || IsClientInRangeSpecialAmmo(activator, "s") == -2.0) && fSlowSpeed[activator] < 1.0) ? true : false;
	bool activatorIsFrozen = (ISFROZEN[activator] != INVALID_HANDLE) ? true : false;
	bool activatorIsScorched = (activatorIsOnFire && activatorIsSufferingAcidBurn) ? true : false;
	bool activatorIsSteaming = (activatorIsOnFire && activatorIsFrozen) ? true : false;
	bool activatorIsDrowning = (activatorFlags & FL_INWATER) ? true : false;
	for (int i = 0; i < ASize; i++) {
		TriggerKeys[activator]		= a_Menu_Talents.Get(i, 0);
		TriggerValues[activator]	= a_Menu_Talents.Get(i, 1);
		TriggerSection[activator]	= a_Menu_Talents.Get(i, 2);
		TriggerSection[activator].GetString(0, TalentName, sizeof(TalentName));
		if (!IsAbilityFound(TriggerKeys[activator], TriggerValues[activator], AbilityT)) continue;
		if (activatorTeamInt == TEAM_SURVIVOR || !IsAFakeClient) {
			TheTalentStrength = GetTalentStrength(activator, TalentName);
			if (TheTalentStrength < 1) continue;
		}
		else {	// Infected bot controllers only
			if (targetIsSurvivor) {
				TheTalentStrength = (Rating[target] / InfectedTalentLevel);
				if (TheTalentStrength < 1) TheTalentStrength = 1;
			}
			else TheTalentStrength = 1;
			iStrengthOverride = TheTalentStrength;
		}
		if (IsAbilityCooldown(activator, TalentName)) continue;
		if (GetKeyValueIntAtPos(TriggerValues[activator], TARGET_AND_LAST_TARGET_CLASS_MATCH) == 1 && !StrEqual(TargetClass, LastTargetClass[activator])) continue;
		fTargetRangeRequired = GetKeyValueFloatAtPos(TriggerValues[activator], TARGET_RANGE_REQUIRED);
		if (fTargetRangeRequired > 0.0) {
			if (activator == target) continue;	// talents requiring a target range can't trigger if the activator is the target.
			bTargetMustBeWithinRange = (GetKeyValueIntAtPos(TriggerValues[activator], TARGET_RANGE_REQUIRED_OUTSIDE) != 1) ? true : false;
			if (bTargetMustBeWithinRange && fTargetRange > fTargetRangeRequired) continue;
			if (!bTargetMustBeWithinRange && fTargetRange <= fTargetRangeRequired) continue;
		}
		iLastTargetResult = GetKeyValueIntAtPos(TriggerValues[activator], TARGET_MUST_BE_LAST_TARGET);
		if (!bTargetIsLastTarget && iLastTargetResult == 1) continue;
		if (bTargetIsLastTarget && iLastTargetResult == 0) continue;
		if (!isTargetInTheAir && GetKeyValueIntAtPos(TriggerValues[activator], TARGET_MUST_BE_IN_THE_AIR) == 1) continue;

		if (activator != target) {
			activatorHighGroundResult = DoesClientHaveTheHighGround(activatorPos, target);
			if (activatorHighGroundResult != 1 && GetKeyValueIntAtPos(TriggerValues[activator], ACTIVATOR_MUST_HAVE_HIGH_GROUND) == 1) continue;
			if (activatorHighGroundResult != -1 && GetKeyValueIntAtPos(TriggerValues[activator], TARGET_MUST_HAVE_HIGH_GROUND) == 1) continue;
			if (activatorHighGroundResult != 0 && GetKeyValueIntAtPos(TriggerValues[activator], ACTIVATOR_TARGET_MUST_EVEN_GROUND) == 1) continue;
		}

		if (!activatorIsOnFire && GetKeyValueIntAtPos(TriggerValues[activator], ACTIVATOR_MUST_BE_ON_FIRE) == 1) continue;
		if (!activatorIsSufferingAcidBurn && GetKeyValueIntAtPos(TriggerValues[activator], ACTIVATOR_MUST_SUFFER_ACID_BURN) == 1) continue;
		if (!activatorIsExploding && GetKeyValueIntAtPos(TriggerValues[activator], ACTIVATOR_MUST_BE_EXPLODING) == 1) continue;
		if (!activatorIsSlowed && GetKeyValueIntAtPos(TriggerValues[activator], ACTIVATOR_MUST_BE_SLOW) == 1) continue;
		if (!activatorIsFrozen && GetKeyValueIntAtPos(TriggerValues[activator], ACTIVATOR_MUST_BE_FROZEN) == 1) continue;
		if (!activatorIsScorched && GetKeyValueIntAtPos(TriggerValues[activator], ACTIVATOR_MUST_BE_SCORCHED) == 1) continue;
		if (!activatorIsSteaming && GetKeyValueIntAtPos(TriggerValues[activator], ACTIVATOR_MUST_BE_STEAMING) == 1) continue;
		if (!activatorIsDrowning && GetKeyValueIntAtPos(TriggerValues[activator], ACTIVATOR_MUST_BE_DROWNING) == 1) continue;
		//if (!IsStatusEffectFound(activator, TriggerKeys[activator], TriggerValues[activator])) continue;
		isRawType = (GetKeyValueIntAtPos(TriggerValues[activator], ABILITY_TYPE) == 3) ? 1 : 0;
		if (typeOfValuesToRetrieve == 1 && isRawType == 1 || typeOfValuesToRetrieve == 2 && isRawType == 0) continue;

		f_Strength	=	TheTalentStrength * 1.0;
		iStrengthOverride = 0;
		bIsStatusEffects = false;
		bIsCompounding = false;
		iSurvivorsInRange = 0;

		if (GetKeyValueIntAtPos(TriggerValues[activator], COMPOUNDING_TALENT) == 1) {
			bIsCompounding = true;
			if (StrEqual(ResultEffects, "none", false)) TriggerValues[activator].GetString(COMPOUND_WITH, ResultEffects, sizeof(ResultEffects[]));
			if (StrEqual(ResultEffects, "-1", false)) continue;
		}
		TriggerValues[activator].GetString(ACTIVATOR_ABILITY_EFFECTS, activatoreffects, sizeof(activatoreffects));
		if (ResultType >= 1) {
			TriggerValues[activator].GetString(TARGET_ABILITY_EFFECTS, targeteffects, sizeof(targeteffects));
			TriggerValues[activator].GetString(SECONDARY_EFFECTS, secondaryEffects, sizeof(secondaryEffects));
		}
		if ((bIsCompounding || ResultType >= 1)) {

			if (ResultType == 0 && StrContains(ResultEffects, activatoreffects, true) == -1) continue;
			if (ResultType >= 1) {
				if (targetEntityType >= 0 && StrContains(ResultEffects, targeteffects, true) == -1) continue;
			}
		}
		if (target != activator) {
			if (targetEntityType == -1) continue;
			if (StrEqual(targeteffects, "0")) continue;
		}
		else if (StrEqual(activatoreffects, "0")) continue;
		if (activatorIsSurvivor) {
			TriggerValues[activator].GetString(WEAPONS_PERMITTED, WeaponsPermitted, sizeof(WeaponsPermitted));
			if (!StrEqual(WeaponsPermitted, "-1", false) && !StrEqual(WeaponsPermitted, "ignore", false) && !StrEqual(WeaponsPermitted, "all", false)) {
				if (!IsWeaponPermittedFound(activator, WeaponsPermitted, PlayerWeapon)) continue;
			}
			fPercentageHealthRequired = GetKeyValueFloatAtPos(TriggerValues[activator], HEALTH_PERCENTAGE_REQ);
			if (fPercentageHealthRequired > 0.0 && fPercentageHealthRemaining > fPercentageHealthRequired) continue;
			fPercentageHealthRequired = GetKeyValueFloatAtPos(TriggerValues[activator], COHERENCY_RANGE);
			if (fPercentageHealthRequired > 0.0) {
				iSurvivorsInRange = NumSurvivorsInRange(activator, fPercentageHealthRequired);
				iCoherencyMax = GetKeyValueIntAtPos(TriggerValues[activator], COHERENCY_MAX);
				if (iCoherencyMax > 0 && iSurvivorsInRange > iCoherencyMax) iSurvivorsInRange = iCoherencyMax;
				if (iSurvivorsInRange < 1 && GetKeyValueIntAtPos(TriggerValues[activator], COHERENCY_REQ) == 1) continue;
			}
			if (targetEntityType >= 0 && target != activator) {	// target exists and is not the activator.
				fPercentageHealthRequired = GetKeyValueFloatAtPos(TriggerValues[activator], HEALTH_PERCENTAGE_REQ_TAR_REMAINING);
				if (fPercentageHealthRequired > 0.0 && fPercentageHealthTargetRemaining < fPercentageHealthRequired) continue;
				fPercentageHealthRequired = GetKeyValueFloatAtPos(TriggerValues[activator], HEALTH_PERCENTAGE_REQ_TAR_MISSING);
				if (fPercentageHealthRequired > 0.0 && fPercentageHealthTargetMissing < fPercentageHealthRequired) continue;
			}
		}
		TriggerValues[activator].GetString(ACTIVATOR_TEAM_REQ, TheString, sizeof(TheString));
		if (!StrEqual(TheString, "-1") && StrContains(TheString, activatorteam) == -1) continue;
		TriggerValues[activator].GetString(ACTIVATOR_CLASS_REQ, TheString, sizeof(TheString));
		if (!StrEqual(TheString, "-1") && StrContains(TheString, ActivatorClass) == -1) continue;
		
		if (!isScoped && GetKeyValueIntAtPos(TriggerValues[activator], REQUIRES_ZOOM) == 1) continue;

		CombatStateRequired = GetKeyValueIntAtPos(TriggerValues[activator], COMBAT_STATE_REQ);
		if (CombatStateRequired >= 0 && CombatStateRequired != activatorCombatState) continue;

		TriggerValues[activator].GetString(PLAYER_STATE_REQ, TheString, sizeof(TheString));
		if (!ComparePlayerState(activator, TheString, incapState, ledgeState, infectedAttacker)) continue;

		TriggerValues[activator].GetString(PASSIVE_ABILITY, TheString, sizeof(TheString));
		if (!StrEqual(TheString, "-1")) continue;	// passive abilities from classes don't trigger here, they have specific points of trigger!

		bTalentRequiresHeadshot = (GetKeyValueIntAtPos(TriggerValues[activator], REQUIRES_HEADSHOT) == 1) ? true : false;
		bTalentRequiresLimbshot = (GetKeyValueIntAtPos(TriggerValues[activator], REQUIRES_LIMBSHOT) == 1) ? true : false;
		if (bTalentRequiresHeadshot && bTalentRequiresLimbshot) {
			if (hitgroupType != 1 && hitgroupType != 2) continue;
		}
		else {
			if (hitgroupType != 1 && bTalentRequiresHeadshot) continue;
			if (hitgroupType != 2 && bTalentRequiresLimbshot) continue;
		}
		if (!activatorIsDucking && GetKeyValueIntAtPos(TriggerValues[activator], REQUIRES_CROUCHING) == 1) continue;

		if (!activatorIsStaggered && GetKeyValueIntAtPos(TriggerValues[activator], ACTIVATOR_STAGGER_REQ) == 1) continue;
		if (!targetIsStaggered && GetKeyValueIntAtPos(TriggerValues[activator], TARGET_STAGGER_REQ) == 1) continue;

		if (activator == target && GetKeyValueIntAtPos(TriggerValues[activator], CANNOT_TARGET_SELF) == 1) continue;

		if (activatorIsTouchingTheGround && GetKeyValueIntAtPos(TriggerValues[activator], MUST_BE_JUMPING_OR_FLYING) == 1) continue;

		if (!activatorBileStatus && GetKeyValueIntAtPos(TriggerValues[activator], VOMIT_STATE_REQ_ACTIVATOR) == 1) continue;
		if (!targetBileStatus && GetKeyValueIntAtPos(TriggerValues[activator], VOMIT_STATE_REQ_TARGET) == 1) continue;

		if (!activatorHasAdrenaline && GetKeyValueIntAtPos(TriggerValues[activator], REQ_ADRENALINE_EFFECT) == 1) continue;
		if (iHasWeakness) {
			if (GetKeyValueIntAtPos(TriggerValues[activator], DISABLE_IF_WEAKNESS) == 1) continue;
		}
		else if (GetKeyValueIntAtPos(TriggerValues[activator], REQ_WEAKNESS) == 1) continue;
		TriggerValues[activator].GetString(TARGET_CLASS_REQ, TargetClassRequired, sizeof(TargetClassRequired));
		if (!StrEqual(TargetClassRequired, "-1") && StrContains(TargetClassRequired, TargetClass, false) == -1) continue;

		if (IsCleanse && GetKeyValueIntAtPos(TriggerValues[activator], CLEANSE_TRIGGER) != 1) continue;
		// with this key, we can fire off nodes every x consecutive hits.
		consecutiveHitsRequired = GetKeyValueIntAtPos(TriggerValues[activator], REQ_CONSECUTIVE_HITS);
		if (consecutiveHitsRequired > 0 && (ConsecutiveHits[activator] < 1 || ConsecutiveHits[activator] % consecutiveHitsRequired != 0)) continue;

		f_EachPoint				= GetTalentInfo(activator, TriggerValues[activator], _, _, TalentName, talenttarget, iStrengthOverride);
		f_Time					= GetTalentInfo(activator, TriggerValues[activator], 2, _, TalentName, talenttarget, iStrengthOverride);
		f_Cooldown				= GetTalentInfo(activator, TriggerValues[activator], 3, _, TalentName, talenttarget, iStrengthOverride);
		f_Strength				= f_EachPoint;
		// we don't put the node on cooldown if we're not activating it.
		if (!bDontActuallyActivate && f_Cooldown > 0.0) CreateCooldown(activator, GetTalentPosition(activator, TalentName), f_Cooldown);
		p_Strength += f_Strength;
		p_Time += f_Time;
		// background talents toggle bDontActuallyActivate here, because we do still want them to go on cooldown, and if we set it before the CreateCooldown method is called, they will not go on cooldown.
		// bDontActuallyActivate can be forcefully-called elsewhere, which is why it's ordered this way.
		if (GetKeyValueIntAtPos(TriggerValues[activator], BACKGROUND_TALENT) == 1) bDontActuallyActivate = true;
		if (activator == target) Format(MultiplierText, sizeof(MultiplierText), "tS_%s", activatoreffects);
		else Format(MultiplierText, sizeof(MultiplierText), "tS_%s", targeteffects);
		//if (GetKeyValueIntAtPos(TriggerValues[activator], STATUS_EFFECT_MULTIPLIER) == 1) bIsStatusEffects = true;
		
		fMultiplyRange = GetKeyValueFloatAtPos(TriggerValues[activator], MULTIPLY_RANGE);
		if (fMultiplyRange > 0.0) { // this talent multiplies its strength by the # of a certain type of entities in range.
			if (GetKeyValueIntAtPos(TriggerValues[activator], MULTIPLY_COMMONS) == 1) {
				iMultiplyCount += LivingEntitiesInRangeByType(activator, fMultiplyRange, 0);
			}
			if (GetKeyValueIntAtPos(TriggerValues[activator], MULTIPLY_SUPERS) == 1) {
				iMultiplyCount += LivingEntitiesInRangeByType(activator, fMultiplyRange, 1);
			}
			if (GetKeyValueIntAtPos(TriggerValues[activator], MULTIPLY_WITCHES) == 1) {
				iMultiplyCount += LivingEntitiesInRangeByType(activator, fMultiplyRange, 2);
			}
			if (GetKeyValueIntAtPos(TriggerValues[activator], MULTIPLY_SURVIVORS) == 1) {
				iMultiplyCount += LivingEntitiesInRangeByType(activator, fMultiplyRange, 3);
			}
			if (GetKeyValueIntAtPos(TriggerValues[activator], MULTIPLY_SPECIALS) == 1) {
				iMultiplyCount += LivingEntitiesInRangeByType(activator, fMultiplyRange, 4);
			}
			if (iMultiplyCount > 0) p_Strength *= iMultiplyCount;
		}
		fMultiplyRange = GetKeyValueFloatAtPos(TriggerValues[activator], STRENGTH_INCREASE_ZOOMED);
		if (fMultiplyRange > 0.0) {
			// If we want a cap on when staying zoomed in stops increasing the strength...
			fPlayerMaxZoomTime = GetKeyValueFloatAtPos(TriggerValues[activator], STRENGTH_INCREASE_TIME_CAP);
			if (fPlayerMaxZoomTime > 0.0 && playerZoomTime > fPlayerMaxZoomTime) playerZoomTime = fPlayerMaxZoomTime;
			// If we only want the bonus to be applied when a minimum amount of time has passed...
			fPlayerMaxZoomTime = GetKeyValueFloatAtPos(TriggerValues[activator], STRENGTH_INCREASE_TIME_REQ);
			// no minimum time is required	or	player meets or exceeds time requirement.
			if (fPlayerMaxZoomTime <= 0.0 || playerZoomTime >= fPlayerMaxZoomTime) p_Strength += (p_Strength * (playerZoomTime / fMultiplyRange));
			else {
				// If the player doesn't meet the time requirement for this perk to give a bonus, we need to check if this is an x-increase over time perk, and don't fire if it is.
				if (GetKeyValueIntAtPos(TriggerValues[activator], ZOOM_TIME_HAS_MINIMUM_REQ) == 1) continue;
			}
		}
		fMultiplyRange = GetKeyValueFloatAtPos(TriggerValues[activator], HOLDING_FIRE_STRENGTH_INCREASE);
		if (fMultiplyRange > 0.0) {
			// If we want a cap on when staying zoomed in stops increasing the strength...
			fPlayerMaxHoldingFireTime = GetKeyValueFloatAtPos(TriggerValues[activator], STRENGTH_INCREASE_TIME_CAP);
			if (fPlayerMaxHoldingFireTime > 0.0 && playerHoldingFireTime > fPlayerMaxHoldingFireTime) playerHoldingFireTime = fPlayerMaxHoldingFireTime;
			// If we only want the bonus to be applied when a minimum amount of time has passed...
			fPlayerMaxHoldingFireTime = GetKeyValueFloatAtPos(TriggerValues[activator], STRENGTH_INCREASE_TIME_REQ);
			// no minimum time is required	or	player meets or exceeds time requirement.
			if (fPlayerMaxHoldingFireTime <= 0.0 || playerHoldingFireTime >= fPlayerMaxHoldingFireTime) p_Strength += (p_Strength * (playerHoldingFireTime / fMultiplyRange));
			else {
				// If the player doesn't meet the time requirement for this perk to give a bonus, we need to check if this is an x-increase over time perk, and don't fire if it is.
				if (GetKeyValueIntAtPos(TriggerValues[activator], DAMAGE_TIME_HAS_MINIMUM_REQ) == 1) continue;
			}
		}
		fPercentageHealthRequired = GetKeyValueFloatAtPos(TriggerValues[activator], HEALTH_PERCENTAGE_REQ_MISSING);
		if (fPercentageHealthRequired > 0.0 && fPercentageHealthMissing >= fPercentageHealthRequired) {	// maximum bonus (eg: 0.4 (40%) missing) we require 0.2 (20%) to be missing. 40% > 20%, so:
			fPercentageHealthRequiredMax = GetKeyValueFloatAtPos(TriggerValues[activator], HEALTH_PERCENTAGE_REQ_MISSING_MAX);	// say we only want to allow the buff once at 20%, and not twice at 40%:
			fPercentageHealthRequired = (fPercentageHealthRequiredMax > 0.0 && (fPercentageHealthMissing / fPercentageHealthRequired) > fPercentageHealthRequiredMax) ?	// 40% / 20% = 2.0 , if we set the max to 1.0 (to allow the buff just once:
										fPercentageHealthRequiredMax :							// true (so we set the max to 1.0 as in our sample scenario)
										(fPercentageHealthMissing / fPercentageHealthRequired);	// false (but doesn't happen in our example scenario)
			p_Strength += (p_Strength * fPercentageHealthRequired);
		}
		if (iSurvivorsInRange > 0) p_Strength += (p_Strength * iSurvivorsInRange);
		if (bIsCompounding || ResultType >= 1) {

			if (!bIsStatusEffects) t_Strength += p_Strength;
			else t_Strength += (p_Strength * MyStatusEffects[activator]);
		}
		else {
			if (!IsOverdriveStacks) {
				if (GetKeyValueIntAtPos(TriggerValues[activator], CLEANSE_TRIGGER) == 1) {
					p_Strength = (CleanseStack[activator] * p_Strength);
				}
				if (!IsCleanse || GetKeyValueIntAtPos(TriggerValues[activator], IS_OWN_TALENT) == 1) {
					TriggerValues[activator].GetString(SECONDARY_ABILITY_TRIGGER, secondaryTrigger, sizeof(secondaryTrigger));
					if (bIsStatusEffects) p_Strength = (p_Strength * MyStatusEffects[activator]);
					if (target != activator) {
						if (!bDontActuallyActivate) {
							// If this is an effect over time
							if (!AllowEffectOverTimeToContinue(activator, TriggerValues[activator], TalentName, damagevalue, targeteffects, target, p_Strength)) continue;
							eotStrength = GetEffectOverTimeStrength(activator, targeteffects);
							if (eotStrength > 0.0) p_Strength *= eotStrength;
							if (GetKeyValueIntAtPos(TriggerValues[activator], TARGET_IS_SELF) == 1) {
								// We have an override that makes it so we can have talents that have to trigger off of either enemies or other players
								// But then activate on the activator, using this key.
								target = activator;
							}
							//AddTalentExperience(activator, "resilience", RoundToCeil(p_Strength * 100.0));
							//AddTalentExperience(activator, "technique", RoundToCeil(p_Strength * 100.0));							
							ActivateAbilityEx(activator, target, damagevalue, targeteffects, p_Strength, p_Time, target, _, isRawType,
												GetKeyValueFloatAtPos(TriggerValues[activator], PRIMARY_AOE), secondaryEffects,
												GetKeyValueFloatAtPos(TriggerValues[activator], SECONDARY_AOE), hitgroup, secondaryTrigger, abilityTrigger, damagetype);
						}
					}
					else {
						if (!bDontActuallyActivate) {
							// If this is an effect over time
							if (!AllowEffectOverTimeToContinue(activator, TriggerValues[activator], TalentName, damagevalue, activatoreffects, target, p_Strength)) continue;
							eotStrength = GetEffectOverTimeStrength(activator, activatoreffects);
							if (eotStrength > 0.0) p_Strength *= eotStrength;
							ActivateAbilityEx(activator, activator, damagevalue, activatoreffects, p_Strength, p_Time, target, _, isRawType,
																		GetKeyValueFloatAtPos(TriggerValues[activator], PRIMARY_AOE), secondaryEffects,
																		GetKeyValueFloatAtPos(TriggerValues[activator], SECONDARY_AOE), hitgroup, secondaryTrigger, abilityTrigger, damagetype);
						}
					}
				}
				else t_Strength += (CleanseStack[activator] * p_Strength);
			}
			else {

				if (!bIsStatusEffects) t_Strength += p_Strength;
				else t_Strength += (p_Strength * MyStatusEffects[activator]);
			}
		}
		p_Strength = 0.0;
		p_Time = 0.0;
	}
	Format(LastTargetClass[activator], sizeof(LastTargetClass[]), "%s", TargetClass);
	if (damagevalue > 0 && t_Strength > 0.0) {

		if (ResultType == 0 || ResultType == 2) return (t_Strength * damagevalue);
		if (ResultType == 1) return (damagevalue + (t_Strength * damagevalue));
	}
	return t_Strength;
}

stock bool EnemiesWithinExplosionRange(int client, float TheRange, float TheStrength) {

	if (!IsLegitimateClientAlive(client)) return false;
	float MyRange[3];
	GetClientAbsOrigin(client, MyRange);

	bool IsInRangeTheRange = false;
	int RealStrength = RoundToCeil(TheStrength * GetClientHealth(client));
	if (RealStrength < 1) return false;

	float TheirRange[3];

	for (int i = 1; i <= MaxClients; i++) {

		if (!IsLegitimateClientAlive(i) || i == client || GetClientTeam(i) == TEAM_SURVIVOR) continue;
		GetClientAbsOrigin(i, TheirRange);
		if (GetVectorDistance(MyRange, TheirRange) <= TheRange) {

			if (!IsInRangeTheRange) {

				IsInRangeTheRange = true;
				CreateAmmoExplosion(client, MyRange[0], MyRange[1], MyRange[2]);		// Boom!
			}
			if (IsSpecialCommonInRange(i, 't')) continue;	// even though the mob is within the explosion range, it is immune because a defender is nearby.
			AddSpecialInfectedDamage(client, i, RealStrength, _, 1);
			CheckTeammateDamagesEx(client, i, RealStrength);
		}
	}
	/*new zombieLimit = Handle CommonInfected.Length;
	for (new zombie = 0; zombie < zombieLimit; zombie++) {

		ent = Handle CommonInfected.Get(zombie);
		if (!IsCommonInfected(ent)) continue;	// || IsClientInRangeSpecialAmmo(ent, DataAmmoEffect, _, i) != -2.0) continue;
		GetEntPropVector(ent, Prop_Send, "m_vecOrigin", TheirRange);
		if (GetVectorDistance(MyRange, TheirRange) <= TheRange) {

			if (!IsInRangeTheRange) {

				IsInRangeTheRange = true;
				CreateAmmoExplosion(client, MyRange[0], MyRange[1], MyRange[2]);
			}

			if (IsSpecialCommon(ent)) AddSpecialCommonDamage(client, ent, RealStrength, _, 1);
			else AddCommonInfectedDamage(client, ent, RealStrength, _, 1);
		}
	}
	zombieLimit = WitchList.Length;
	for (new zombie = 0; zombie < zombieLimit; zombie++) {

		ent = Handle WitchList.Get(zombie);
		if (!IsWitch(ent)) continue;
		GetEntPropVector(ent, Prop_Send, "m_vecOrigin", TheirRange);
		if (GetVectorDistance(MyRange, TheirRange) <= TheRange) {

			if (!IsInRangeTheRange) {

				IsInRangeTheRange = true;
				CreateAmmoExplosion(client, MyRange[0], MyRange[1], MyRange[2]);
			}
			AddWitchDamage(client, ent, RealStrength, _, 1);
		}
	}*/
	return IsInRangeTheRange;
}

stock bool ComparePlayerState(int client, char[] CombatState, bool incapState, bool ledgeState, int infectedAttacker) {

	if (StrEqual(CombatState, "-1") || StrContains(CombatState, "0") != -1) return true;

	if (incapState && StrContains(CombatState, "1") != -1) return true;
	if (!incapState && StrContains(CombatState, "2") != -1) return true;
	if (infectedAttacker == -1 && !incapState && StrContains(CombatState, "3") != -1) return true;
	if (ledgeState && StrContains(CombatState, "4") != -1) return true;
	return false;
}

stock int GetPIV(int client, float Distance, bool IsSameTeam = true) {

	float ClientOrigin[3];
	float iOrigin[3];

	GetClientAbsOrigin(client, ClientOrigin);

	int count = 0;
	for (int i = 1; i <= MaxClients; i++) {

		if (!IsLegitimateClientAlive(i) || i == client) continue;
		if (IsSameTeam && GetClientTeam(client) != GetClientTeam(i)) continue;
		GetClientAbsOrigin(i, iOrigin);
		if (GetVectorDistance(ClientOrigin, iOrigin) <= Distance) count++;
	}
	return count;
}

stock float GetPlayerDistance(int client, int target) {

	float ClientDistance[3];
	if (IsLegitimateClient(client)) GetClientAbsOrigin(client, ClientDistance);
	else GetEntPropVector(client, Prop_Send, "m_vecOrigin", ClientDistance);

	float TargetDistance[3];
	if (IsLegitimateClient(target)) GetClientAbsOrigin(target, TargetDistance);
	else GetEntPropVector(target, Prop_Send, "m_vecOrigin", TargetDistance);

	return GetVectorDistance(ClientDistance, TargetDistance);
}

stock bool AbilityChanceSuccess(int client, char[] s_TalentName = "none") {
	if (IsLegitimateClient(client)) {
		int pos				=	FindChanceRollAbility(client, s_TalentName);
		if (pos == -1) return false;

		char talentname[64];

		float i_EachPoint	=	0.0;
		int range			=	0;

		//AbilityKeys[client]			= a_Menu_Talents.Get(pos, 0);
		AbilityValues[client]		= a_Menu_Talents.Get(pos, 1);
		AbilitySection[client]		= a_Menu_Talents.Get(pos, 2);

		AbilitySection[client].GetString(0, talentname, sizeof(talentname));
		if (GetTalentStrength(client, talentname) < 1) return false;

		i_EachPoint				= GetTalentInfo(client, AbilityValues[client], _, _, talentname);
		range					= RoundToCeil(1.0 / (i_EachPoint * 100.0));

		range				=	GetRandomInt(1, range);

		if (range <= 1) return true;
	}
	return false;
}

stock void GetAugmentStrength(int augmentId, char[] TalentName) {

	// Augments have their own unique identifiers that aren't tied to players, even though a player can have the particular item equipped at any time.
}

stock int GetCategoryStrength(int client, char[] sTalentCategory, bool bGetMaximumTreePointsInstead = false) {
	if (!IsLegitimateClient(client)) return 0;
	int count = 0;
	char sText[64];
	char sTalentName[64];
	int iStrength = 0;

	int size = a_Menu_Talents.Length;
	for (int i = 0; i < size; i++) {
		//GetCategoryStrengthKeys[client]		= a_Menu_Talents.Get(i, 0);
		GetCategoryStrengthValues[client]	= a_Menu_Talents.Get(i, 1);
		GetCategoryStrengthValues[client].GetString(TALENT_TREE_CATEGORY, sText, sizeof(sText));
		if (!StrEqual(sTalentCategory, sText, false)) continue;
		
		GetCategoryStrengthSection[client]	= a_Menu_Talents.Get(i, 2);
		GetCategoryStrengthSection[client].GetString(0, sTalentName, sizeof(sTalentName));

		if (bGetMaximumTreePointsInstead) count++;
		else {
			iStrength = GetTalentStrength(client, sTalentName, _, i);
			if (iStrength > 0) count++;
		}
	}
	return count;
}

stock int GetLayerUpgradeStrength(int client, int layer = 1, bool bIsCheckEligibility = false, bool bResetLayer = false, bool countAllOptionsOnLayer = false, bool getAllLayerNodes = false, bool ignoreAttributes = false) {
	int size = a_Menu_Talents.Length;
	int count = 0;
	char TalentName[64];
	//new nodeUnlockCost = 0;
	for (int i = 0; i < size; i++) {										// loop through this talents keyfile.
		GetLayerStrengthKeys[client] = a_Menu_Talents.Get(i, 0);	// "keys"
		GetLayerStrengthValues[client] = a_Menu_Talents.Get(i, 1);// "values"
		// talents are ordered by "layers" (think a 3-d talent tree)
		if (GetKeyValueIntAtPos(GetLayerStrengthValues[client], GET_TALENT_LAYER) != layer) continue;
		if (ignoreAttributes && GetKeyValueIntAtPos(GetLayerStrengthValues[client], IS_ATTRIBUTE) == 1) continue;
		if (getAllLayerNodes) {	// we just want to get how many nodes are on this layer, even the ones that we ignore for layer count.
			count++;
			continue;
		}
		if (!countAllOptionsOnLayer && GetKeyValueIntAtPos(GetLayerStrengthValues[client], LAYER_COUNTING_IS_IGNORED) == 1) continue;
		if (bResetLayer) {
			GetLayerStrengthSection[client] = a_Menu_Talents.Get(i, 2);	// Array holding the "name" of the talent.
			GetLayerStrengthSection[client].GetString(0, TalentName, sizeof(TalentName));
			count = GetTalentStrength(client, TalentName);
			if (count < 1) continue;
			PlayerUpgradesTotal[client]--;	// nodes can only be upgraded once regardless of their unlock cost.
			FreeUpgrades[client]++;//= nodeUnlockCost;
			AddTalentPoints(client, TalentName, 0);	// This func actually SETS the talent points to the value you specify... SetTalentPoints?
			continue;
		}
		count += a_Database_PlayerTalents[client].Get(i);	// how many talent points have the player invested in this node?
	}
	if (bResetLayer) return -2;	// for logging purposes.
	if (bIsCheckEligibility && count < layer + 1) {	// we only check the eligibility of the layer the player just locked(refunded) their node in.
		for (int i = layer + 1; i <= iMaxLayers; i++) {	// if any layer is found to not meet eligibility, all subsequent layers are reset.
			GetLayerUpgradeStrength(client, i, _, true);
		}
		return -1;	// logging
	}
	return count;
}

stock void GetTalentKeyValue(int client, char[] TalentName, int pos, char[] storage, int storageLocSize) {
	int size = a_Menu_Talents.Length;
	char result[64];
	for (int i = 0; i < size; i++) {
		GetTalentKeyValueSection[client]		= a_Menu_Talents.Get(i, 2);
		GetTalentKeyValueSection[client].GetString(0, result, sizeof(result));
		if (!StrEqual(result, TalentName)) continue;

		//GetTalentKeyValueKeys[client]		= a_Menu_Talents.Get(i, 0);
		GetTalentKeyValueValues[client]		= a_Menu_Talents.Get(i, 1);
		GetTalentKeyValueValues[client].GetString(pos, storage, storageLocSize);
		break;
	}
}

stock int GetTalentStrengthByKeyValue(int client, int pos, char[] searchValue, bool getFirstTalentResult = true) {
	int size = a_Menu_Talents.Length;
	char result[64];
	int count = 0;
	int total = 0;
	for (int i = 0; i < size; i++) {
		//GetTalentValueSearchKeys[client]		= a_Menu_Talents.Get(i, 0);
		GetTalentValueSearchValues[client]		= a_Menu_Talents.Get(i, 1);
		GetTalentValueSearchValues[client].GetString(pos, result, sizeof(result));
		if (!StrEqual(result, searchValue)) continue;
		// we found a talent with the search value required, so we want to get its name.
		GetTalentValueSearchSection[client]		= a_Menu_Talents.Get(i, 2);
		GetTalentValueSearchSection[client].GetString(0, result, sizeof(result));
		// and its strength.
		count = GetTalentStrength(client, result);
		if (count < 1) continue;
		// if there are multiple nodes with the same function, but we only care if at least one is unlocked
		if (getFirstTalentResult) return count;
		total += count;
	}
	return total;
}

stock int GetTalentStrength(int client, char[] TalentName, int target = 0, int pos = -1, bool containsTalentName = false) {
	if (!IsLegitimateClient(client)) return 0;
	if (GetClientTeam(client) == TEAM_INFECTED && IsFakeClient(client)) {
		int counter = 1;
		if (target > 0 && IsLegitimateClient(target) && GetClientTeam(target) == TEAM_SURVIVOR) {

			counter = (Rating[target] / InfectedTalentLevel);
		}
		if (counter < 1) counter = 1;
		return counter;
	}


	int size				=	0;
	if (client != -1) size	=	a_Database_PlayerTalents[client].Length;
	else size				=	a_Database_PlayerTalents_Bots.Length;
	char text[64];
	int count = 0;


	for (int i = 0; i < size; i++) {
		a_Database_Talents.GetString(i, text, sizeof(text));
		if (containsTalentName) {
			if (StrContains(text, TalentName, false) != -1) count += a_Database_PlayerTalents[client].Get(i);
		}
		else if (StrEqual(TalentName, text)) {
			return a_Database_PlayerTalents[client].Get(i);
		}
	}
	if (containsTalentName) return count;
	return 0;
}

/*
	This method lets us make it so all talent nodes have a key field named "attribute?"

	Server operators can set these to any custom value, as long as there is an attribute node with that name made.
	The attributes multiplier, weighed based on several factors seen below, scales all factors of the talent.

	These include strength, active time, cooldown time, passive time, etc.
	If you don't want a node connected to an attribute, omit "attribute?" from the node.
*/
stock float GetAttributeMultiplier(int client, char[] TalentName) {
	int size = a_Database_PlayerTalents[client].Length;
	int iStrength = 0;
	char text[64];
	float baseMultiplier;
	float dimMultiplier;
	int dimPoint;
	bool multipliersSet = false;
	size = a_Menu_Talents.Length;
	for (int i = 0; i < size; i++) {
		GAMKeys[client]		= a_Menu_Talents.Get(i, 0);
		GAMValues[client]	= a_Menu_Talents.Get(i, 1);

		/*	Is this node an attribute node?
			we count how many attribute nodes the player has unlocked to determine the multiplier of said attribute.
		*/
		GAMValues[client].GetString(ATTRIBUTE_MULTIPLIER, text, sizeof(text));
		if (!StrEqual(text, TalentName)) continue;

		GAMSection[client]	= a_Menu_Talents.Get(i, 2);
		GAMSection[client].GetString(0, text, sizeof(text));
		if (GetTalentStrength(client, text) > 0) iStrength++;

		if (!multipliersSet && GetKeyValueIntAtPos(GAMValues[client], ATTRIBUTE_USE_THESE_MULTIPLIERS) == 1) {
			multipliersSet = true;
			baseMultiplier	= GetKeyValueFloatAtPos(GAMValues[client], ATTRIBUTE_BASE_MULTIPLIER);
			dimMultiplier	= GetKeyValueFloatAtPos(GAMValues[client], ATTRIBUTE_DIMINISHING_MULTIPLIER);
			dimPoint		= GetKeyValueIntAtPos(GAMValues[client], ATTRIBUTE_DIMINISHING_RETURNS);
		}
	}
	float currStrength = 0.0;
	for (int i = 1; i <= iStrength; i++) {
		if (i % dimPoint == 0) baseMultiplier *= dimMultiplier;
		currStrength += baseMultiplier;
	}
	return currStrength;
}

stock int GetKeyPos(ArrayList Keys, char[] SearchKey) {

	char key[64];
	int size = Keys.Length;
	for (int i = 0; i < size; i++) {

		Keys.GetString(i, key, sizeof(key));
		if (StrEqual(key, SearchKey)) return i;
	}
	return -1;
}

stock bool FoundCooldownReduction(char[] TalentName, char[] CooldownList) {
	int ExplodeCount = GetDelimiterCount(CooldownList, "|") + 1;
	if (ExplodeCount == 1) {
		if (StrContains(TalentName, CooldownList, false) != -1) return true;
	}
	else {
		char[][] cooldownTalentName = new char[ExplodeCount][64];
		ExplodeString(CooldownList, "|", cooldownTalentName, ExplodeCount, 64);
		for (int i = 0; i < ExplodeCount; i++) {
			if (StrContains(TalentName, cooldownTalentName[i], false) != -1) return true;
		}
	}
	return false;
}

stock int FormatKeyValue(char[] TheValue, int TheSize, ArrayList Keys, ArrayList Values, char[] SearchKey, char[] DefaultValue = "none", bool bDebug = false, int pos = 0, bool incrementPos = true) {

	char key[512];

	int size = Keys.Length;
	if (pos > 0 && incrementPos) pos++;
	for (int i = pos; i < size; i++) {

		Keys.GetString(i, key, sizeof(key));
		if (StrEqual(key, SearchKey)) {

			Values.GetString(i, TheValue, TheSize);
			return i;
		}
	}
	if (StrEqual(DefaultValue, "none", false)) Format(TheValue, TheSize, "-1");
	else Format(TheValue, TheSize, "%s", DefaultValue);
	return -1;
}

stock float GetKeyValueFloat(ArrayList Keys, ArrayList Values, char[] SearchKey, char[] DefaultValue = "none", bool bDebug = false, int pos = 0) {

	char key[64];
	if (pos > 0) pos++;
	int size = Keys.Length;
	for (int i = pos; i < size; i++) {

		Keys.GetString(i, key, sizeof(key));
		if (StrEqual(key, SearchKey)) {

			Values.GetString(i, key, sizeof(key));
			return StringToFloat(key);
		}
	}
	if (StrEqual(DefaultValue, "none", false)) return -1.0;
	return StringToFloat(DefaultValue);
}

stock int GetKeyValueIntAtPos(ArrayList Values, int pos) {
	char key[64];
	Values.GetString(pos, key, sizeof(key));
	return StringToInt(key);
}

stock float GetKeyValueFloatAtPos(ArrayList Values, int pos) {
	char key[64];
	Values.GetString(pos, key, sizeof(key));
	return StringToFloat(key);
}

stock int GetKeyValueInt(ArrayList Keys, ArrayList Values, char[] SearchKey, char[] DefaultValue = "none", bool bDebug = false) {

	char key[64];

	int size = Keys.Length;
	for (int i = 0; i < size; i++) {

		Keys.GetString(i, key, sizeof(key));
		if (StrEqual(key, SearchKey)) {

			Values.GetString(i, key, sizeof(key));
			return StringToInt(key);
		}
	}
	if (StrEqual(DefaultValue, "none", false)) return -1;
	return StringToInt(DefaultValue);
}

stock void GetMenuOfTalent(int client, char[] TalentName, char[] TheText, int TheSize) {

	char s_TalentName[64];

	int size = a_Menu_Talents.Length;
	for (int i = 0; i < size; i++) {

		//MOTKeys[client]			= a_Menu_Talents.Get(i, 0);
		MOTValues[client]		= a_Menu_Talents.Get(i, 1);
		MOTSection[client]		= a_Menu_Talents.Get(i, 2);

		MOTSection[client].GetString(0, s_TalentName, sizeof(s_TalentName));
		if (!StrEqual(s_TalentName, TalentName, false)) continue;
		MOTValues[client].GetString(PART_OF_MENU_NAMED, TheText, TheSize);
		return;
	}
	Format(TheText, TheSize, "-1");
}

stock int FindChanceRollAbility(int client, char[] s_TalentName = "none") {

	if (IsLegitimateClient(client)) {

		int a_Size			=	0;

		a_Size		= a_Menu_Talents.Length;

		char TalentName[64];
		char MenuName[64];

		for (int i = 0; i < a_Size; i++) {

			//ChanceKeys[client]			= a_Menu_Talents.Get(i, 0);
			ChanceValues[client]		= a_Menu_Talents.Get(i, 1);
			ChanceSection[client]		= a_Menu_Talents.Get(i, 2);

			//Handle ChanceSection[client].GetString(0, TalentName, sizeof(TalentName));
			ChanceValues[client].GetString(PART_OF_MENU_NAMED, TalentName, sizeof(TalentName));
			GetMenuOfTalent(client, s_TalentName, MenuName, sizeof(MenuName));
			if (!StrEqual(TalentName, MenuName, false)) continue;

			ChanceValues[client].GetString(ACTIVATOR_ABILITY_EFFECTS, TalentName, sizeof(TalentName));

			if (StrContains(TalentName, "C", true) != -1) return i;
		}
	}
	return -1;
}

stock int GetWeaponSlot(int entity) {

	if (IsValidEntity(entity)) {

		char Classname[64];
		GetEntityClassname(entity, Classname, sizeof(Classname));

		if (StrContains(Classname, "pistol", false) != -1 || StrContains(Classname, "chainsaw", false) != -1) return 1;
		if (StrContains(Classname, "molotov", false) != -1 || StrContains(Classname, "pipe_bomb", false) != -1 || StrContains(Classname, "vomitjar", false) != -1) return 2;
		if (StrContains(Classname, "defib", false) != -1 || StrContains(Classname, "first_aid", false) != -1) return 3;
		if (StrContains(Classname, "adren", false) != -1 || StrContains(Classname, "pills", false) != -1) return 4;
		return 0;
	}
	return -1;
}

stock void SurvivorPowerSlide(int client) {
	float vel[3];
	vel[0]	=	GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
	vel[1]	=	GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");
	vel[2]	=	GetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]");

	if (vel[0] > 0.0) vel[0] += 100.0;
	else vel[0] -= 100.0;
	if (vel[1] > 0.0) vel[1] += 100.0;
	else vel[1] -= 100.0;
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
}

stock void BeanBag(int client, float force) {

	if (IsLegitimateClientAlive(client)) {

		int myteam = GetClientTeam(client);

		if (myteam == TEAM_INFECTED && L4D2_GetSurvivorVictim(client) != -1 || (GetEntityFlags(client) & FL_ONGROUND)) {

			float Velocity[3];

			Velocity[0]	=	GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
			Velocity[1]	=	GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");
			Velocity[2]	=	GetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]");

			float Vec_Pull;
			float Vec_Lunge;

			Vec_Pull	=	GetRandomFloat(force * -1.0, force);
			Vec_Lunge	=	GetRandomFloat(force * -1.0, force);
			Velocity[2]	+=	force;

			if (Vec_Pull < 0.0 && Velocity[0] > 0.0) Velocity[0] *= -1.0;
			Velocity[0] += Vec_Pull;

			if (Vec_Lunge < 0.0 && Velocity[1] > 0.0) Velocity[1] *= -1.0;
			Velocity[1] += Vec_Lunge;

			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, Velocity);
			if (myteam == TEAM_INFECTED) {

				int victim = L4D2_GetSurvivorVictim(client);
				if (victim != -1) TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, Velocity);
			}
		}
	}
}

stock void CreateExplosion(int client, int damage = 0, int attacker = 0, bool IsAOE = false, float fRange = 96.0) {

	int entity 				= CreateEntityByName("env_explosion");
	float loc[3], tloc[3];
	int totalIncomingDamage = 0, aClient = 0;
	if (IsLegitimateClientAlive(client) && GetClientTeam(client) == TEAM_INFECTED) aClient = client;
	if (IsLegitimateClientAlive(client)) GetClientAbsOrigin(client, loc);
	else GetEntPropVector(client, Prop_Send, "m_vecOrigin", loc);

	DispatchKeyValue(entity, "fireballsprite", "sprites/zerogxplode.spr");
	DispatchKeyValue(entity, "iMagnitude", "0");	// we don't want the fireball dealing damage - we do this manually.
	DispatchKeyValue(entity, "iRadiusOverride", "0");
	DispatchKeyValue(entity, "rendermode", "5");
	DispatchKeyValue(entity, "spawnflags", "0");
	DispatchSpawn(entity);
	TeleportEntity(entity, loc, NULL_VECTOR, NULL_VECTOR);
	AcceptEntityInput(entity, "explode");

	int zombieclass = -1;
	if (aClient > 0) FindZombieClass(client);

	if (damage > 0 || zombieclass == ZOMBIECLASS_TANK) {

		if (IsAOE) {

			for (int i = 1; i <= MaxClients; i++) {

				if (!IsLegitimateClientAlive(i)) continue;
				if (GetClientTeam(i) != TEAM_SURVIVOR) continue;

				GetClientAbsOrigin(i, tloc);
				if (GetVectorDistance(loc, tloc) > fRange) continue;
				if (totalIncomingDamage > 0) {

					SetClientTotalHealth(i, totalIncomingDamage);
					if (aClient > 0 && GetClientTeam(aClient) == TEAM_INFECTED) AddSpecialInfectedDamage(i, client, totalIncomingDamage, true);
				}
				if (zombieclass == ZOMBIECLASS_TANK) {

					// tank aoe jump explosion.
					ScreenShake(i);
					StaggerPlayer(i, client);
				}
			}
			return;
		}

		if (IsWitch(client)) {

			if (FindListPositionByEntity(client, WitchList) >= 0) AddWitchDamage(attacker, client, damage);
			else OnWitchCreated(client, true);
		}
		else if (IsSpecialCommon(client)) AddSpecialCommonDamage(attacker, client, damage);
		else if (IsLegitimateClientAlive(client) && IsLegitimateClientAlive(attacker) && FindZombieClass(attacker) == ZOMBIECLASS_TANK) {
			if ((GetEntityFlags(client) & FL_ONGROUND)) {

				if (CheckActiveAbility(client, totalIncomingDamage, 1) > 0.0) {

					if (GetClientTotalHealth(client) <= totalIncomingDamage) ChangeTankState(attacker, "hulk", true);

					SetClientTotalHealth(client, totalIncomingDamage);
					AddSpecialInfectedDamage(client, attacker, totalIncomingDamage, true);	// bool is tanking instead.
				}
			}
			else {

				// If a player follows the mechanic successfully, hulk ends and changes to death state.

				//ChangeTankState(attacker, "hulk", true);
				//ChangeTankState(attacker, "death");
			}
		}
	}
}

stock void CreateAmmoExplosion(int client, float PosX=0.0, float PosY=0.0, float PosZ=0.0) {

	int entity 				= CreateEntityByName("env_explosion");
	float loc[3];
	loc[0] = PosX;
	loc[1] = PosY;
	loc[2] = PosZ;

	DispatchKeyValue(entity, "fireballsprite", "sprites/zerogxplode.spr");
	DispatchKeyValue(entity, "iMagnitude", "0");	// we don't want the fireball dealing damage - we do this manually.
	DispatchKeyValue(entity, "iRadiusOverride", "0");
	DispatchKeyValue(entity, "rendermode", "5");
	DispatchKeyValue(entity, "spawnflags", "0");
	DispatchSpawn(entity);
	TeleportEntity(entity, loc, NULL_VECTOR, NULL_VECTOR);
	AcceptEntityInput(entity, "explode");
	if (IsValidEntity(entity)) AcceptEntityInput(entity, "Kill");
}

stock void ScreenShake(int client) {

	int entity = CreateEntityByName("env_shake");

	float loc[3];
	GetClientAbsOrigin(client, loc);
	if(entity >= 0)
	{
		DispatchKeyValue(entity, "spawnflags", "8");
		DispatchKeyValue(entity, "amplitude", "16.0");
		DispatchKeyValue(entity, "frequency", "1.5");
		DispatchKeyValue(entity, "duration", "0.9");
		DispatchKeyValue(entity, "radius", "0.0");
		DispatchSpawn(entity);
		ActivateEntity(entity);
		AcceptEntityInput(entity, "Enable");

		TeleportEntity(entity, loc, NULL_VECTOR, NULL_VECTOR);
		AcceptEntityInput(entity, "StartShake");

		SetVariantString("OnUser1 !self:Kill::1.1:1");
		AcceptEntityInput(entity, "AddOutput");
		AcceptEntityInput(entity, "FireUser1");
	}
}

stock void ZeroGravity(int client, int victim, float g_TalentStrength, float g_TalentTime) {

	if (IsLegitimateClientAlive(client) && IsLegitimateClientAlive(victim)) {

		if (L4D2_GetSurvivorVictim(victim) != -1 || ((GetEntityFlags(victim) & FL_ONGROUND) || !b_GroundRequired[victim])) {


		//if (GetEntityFlags(victim) & FL_ONGROUND || !b_GroundRequired[victim]) {

			//if (ZeroGravityTimer[victim] == INVALID_HANDLE) {

			float vel[3];
			vel[0] = GetEntPropFloat(victim, Prop_Send, "m_vecVelocity[0]");
			vel[1] = GetEntPropFloat(victim, Prop_Send, "m_vecVelocity[1]");
			vel[2] = GetEntPropFloat(victim, Prop_Send, "m_vecVelocity[2]");
			//ZeroGravityTimer[victim] = 
			CreateTimer(g_TalentTime, Timer_ZeroGravity, victim, TIMER_FLAG_NO_MAPCHANGE);
			SetEntityGravity(victim, GravityBase[victim] - g_TalentStrength);
			TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, vel);

			int survivor = L4D2_GetSurvivorVictim(victim);
			if (survivor != -1) {

				//ZeroGravityTimer[survivor] = 
				CreateTimer(g_TalentTime, Timer_ZeroGravity, survivor, TIMER_FLAG_NO_MAPCHANGE);
				SetEntityGravity(survivor, GravityBase[survivor] - g_TalentStrength);
				TeleportEntity(survivor, NULL_VECTOR, NULL_VECTOR, vel);
			}
			//}
		}
	}
}

/*stock SpeedIncrease(client, Float:effectTime = 0.0, Float:amount = -1.0, bool:IsTeamAffected = false) {

	if (IsLegitimateClientAlive(client)) {

		//if (amount == -1.0) amount = SpeedMultiplierBase[client];

		//if (effectTime == 0.0) {

		//	if (!IsFakeClient(client)) SpeedMultiplier[client] = SpeedMultiplierBase[client] + (Agility[client] * 0.01) + amount;
		//	else SpeedMultiplier[client] = SpeedMultiplierBase[client] + (Agility_Bots * 0.01) + amount;
		//}
		//else {

		if (amount >= 0.0) {

			SpeedMultiplier[client] = SpeedMultiplierBase[client] + amount;
			//if (SpeedMultiplierTimer[client] != INVALID_HANDLE) {

			//	KillTimer(SpeedMultiplierTimer[client]);
			//	SpeedMultiplierTimer[client] = INVALID_HANDLE;
			//}
			//SpeedMultiplierTimer[client] =
			SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", SpeedMultiplier[client]);
			CreateTimer(effectTime, Timer_SpeedIncrease, client, TIMER_FLAG_NO_MAPCHANGE);
		}
		else {

			SetSpeedMultiplierBase(client);
			//SpeedMultiplier[client] = SpeedMultiplierBase[client];
		}
		//LogMessage("%N Base: %3.3f amount: %3.3f Current: %3.3f", client, SpeedMultiplierBase[client], amount, SpeedMultiplier[client]);

		if (IsTeamAffected) {

			for (new i = 1; i <= MaxClients; i++) {

				if (IsLegitimateClientAlive(i) && !IsFakeClient(i) && GetClientTeam(i) == GetClientTeam(client) && client != i) {

					if (effectTime == 0.0) SpeedMultiplier[i] = SpeedMultiplierBase[i] + (Agility[i] * 0.01) + amount;
					else {

						SpeedMultiplier[i] = SpeedMultiplierBase[i] + amount;
						//if (SpeedMultiplierTimer[i] != INVALID_HANDLE) {

						//	KillTimer(SpeedMultiplierTimer[i]);
						//	SpeedMultiplierTimer[i] = INVALID_HANDLE;
						//}
						//SpeedMultiplierTimer[i] = 
						CreateTimer(effectTime, Timer_SpeedIncrease, i, TIMER_FLAG_NO_MAPCHANGE);
					}
					SetEntPropFloat(i, Prop_Send, "m_flLaggedMovementValue", SpeedMultiplier[i]);
				}
			}
		}
	}
}*/

stock void SlowPlayer(int client, float g_TalentStrength, float g_TalentTime) {

	if (IsLegitimateClientAlive(client) && ISSLOW[client] == INVALID_HANDLE) {

		//if (SlowMultiplierTimer[client] != INVALID_HANDLE) {

		//	KillTimer(SlowMultiplierTimer[client]);
		//	SlowMultiplierTimer[client] = INVALID_HANDLE;
		//}
		//SlowMultiplierTimer[client] = 
		ISSLOW[client] = CreateTimer(g_TalentTime, Timer_Slow, client, TIMER_FLAG_NO_MAPCHANGE);
		fSlowSpeed[client] = g_TalentStrength;
	}
}

// Eyal282 here, target doesn't exist and throws errors.
/*
stock void DamageBonus(attacker, victim, damagevalue, float amount) {

	if (IsLegitimateClientAlive(victim)) {

		int i_DamageBonus = RoundToFloor(damagevalue * amount);

		if (GetClientTeam(victim) == TEAM_SURVIVOR) {

			//if (GetClientTotalHealth(victim) > i_DamageBonus)
			SetClientTotalHealth(victim, i_DamageBonus); //SetEntityHealth(victim, GetClientHealth(victim) - CommonsDamage);
			//else if (GetClientTotalHealth(victim) <= i_DamageBonus) IncapacitateOrKill(victim, attacker);
		}
		else {

			int isEntityPos = FindListPositionByEntity(victim, InfectedHealth[attacker]);

			if (isEntityPos < 0) {

				int t_InfectedHealth = DefaultHealth[victim];
				isEntityPos = InfectedHealth[attacker].Length;
				InfectedHealth[attacker].Resize(isEntityPos + 1);
				InfectedHealth[attacker].Set(isEntityPos, victim, 0);

				int myzombieclass = FindZombieClass(victim);

				//An infected wasn't added on spawn to this player, so we add it now based on class.
				if (myzombieclass == ZOMBIECLASS_TANK) {

					t_InfectedHealth = 4000;
					if (iTankRush == 1) t_InfectedHealth = 1000;
				}
				else if (myzombieclass == ZOMBIECLASS_HUNTER || myzombieclass == ZOMBIECLASS_SMOKER) t_InfectedHealth = 200;
				else if (myzombieclass == ZOMBIECLASS_BOOMER) t_InfectedHealth = 50;
				else if (myzombieclass == ZOMBIECLASS_SPITTER) t_InfectedHealth = 100;
				else if (myzombieclass == ZOMBIECLASS_CHARGER) t_InfectedHealth = 600;
				else if (myzombieclass == ZOMBIECLASS_JOCKEY) t_InfectedHealth = 300;

				if (!IsFakeClient(target)) {

					DefaultHealth[target] = SetMaximumHealth(target);
				}
				else OverHealth[target] = 0;

				if (iBotLevelType == 1) {

					if (myzombieclass != ZOMBIECLASS_TANK) t_InfectedHealth += RoundToCeil(t_InfectedHealth * (SurvivorLevels() * fHealthPlayerLevel[myzombieclass - 1]));
					else t_InfectedHealth += RoundToCeil(t_InfectedHealth * (SurvivorLevels() * fHealthPlayerLevel[myzombieclass - 2]));
				}
				else {

					if (myzombieclass != ZOMBIECLASS_TANK) t_InfectedHealth += RoundToCeil(t_InfectedHealth * (GetDifficultyRating(client) * fHealthPlayerLevel[myzombieclass - 1]));
					else t_InfectedHealth += RoundToCeil(t_InfectedHealth * (GetDifficultyRating(client) * fHealthPlayerLevel[myzombieclass - 2]));
				}
				//t_InfectedHealth += RoundToCeil(t_InfectedHealth * fSurvivorHealthBonus);

				// only add raid health if > 4 survivors.
				int theCount = LivingSurvivorCount();
				if (theCount >= iSurvivorModifierRequired) t_InfectedHealth += RoundToCeil(t_InfectedHealth * ((theCount - (iSurvivorModifierRequired - 1)) * fSurvivorHealthBonus));

				InfectedHealth[attacker].Set(isEntityPos, t_InfectedHealth + OverHealth[victim], 1);
				InfectedHealth[attacker].Set(isEntityPos, 0, 2);
				InfectedHealth[attacker].Set(isEntityPos, 0, 3);
				InfectedHealth[attacker].Set(isEntityPos, 0, 4);
				if (!bHealthIsSet[victim]) {

					bHealthIsSet[victim] = true;

					InfectedHealth[victim].Set(0, DefaultHealth[victim], 5);
					InfectedHealth[victim].Set(0, 0, 6);
				}
			}

			if (damagevalue <= 0) return;

			int i_InfectedMaxHealth = InfectedHealth[attacker].Get(isEntityPos, 1);
			int i_InfectedCurrent = InfectedHealth[attacker].Get(isEntityPos, 2);
			int i_HealthRemaining = i_InfectedMaxHealth - i_InfectedCurrent;
			if (i_HealthRemaining <= 0 && !IsFakeClient(victim)) i_HealthRemaining = InfectedHealth[victim].Get(0, 5);
			if (i_DamageBonus > i_HealthRemaining) i_DamageBonus = i_HealthRemaining;
			InfectedHealth[attacker].Set(isEntityPos, InfectedHealth[attacker].Get(isEntityPos, 2) + i_DamageBonus, 2);

			if (i_InfectedMaxHealth - i_InfectedCurrent <= 0) InfectedHealth[victim].Set(0, InfectedHealth[victim].Get(0, 5) + i_DamageBonus, 6);
			RoundDamageTotal += i_DamageBonus;
			RoundDamage[attacker] += i_DamageBonus;
			//LogToFile(LogPathDirectory, "[PLAYER %N] Damage Bonus against %N for %d (base damage: %d)", attacker, victim, i_DamageBonus, damagevalue);

			if (iDisplayHealthBars == 1) {

				DisplayInfectedHealthBars(attacker, victim);
			}
			if (CheckTeammateDamages(victim, attacker) >= 1.0 ||
				CheckTeammateDamages(victim, attacker, true) >= 1.0) {

				if (!IsFakeClient(victim)) {

					char ePct[64];
					ExperienceBar(client, ePct, sizeof(ePct), 2, true);
					if (StringToFloat(ePct) < 100.0) return;
				}
				CalculateInfectedDamageAward(victim, attacker);
			}
		}
	}
}
*/
stock int CreateLineSoloEx(int client, int target, char[] DrawColour, char[] DrawPos, float lifetime = 0.5, int targetClient = 0) {

	float ClientPos[3];
	float TargetPos[3];
	if (IsLegitimateClient(client)) GetClientAbsOrigin(client, ClientPos);
	else GetEntPropVector(client, Prop_Send, "m_vecOrigin", ClientPos);
	if (IsLegitimateClient(target)) GetClientAbsOrigin(target, TargetPos);
	else GetEntPropVector(target, Prop_Send, "m_vecOrigin", TargetPos);

	ClientPos[2] += StringToFloat(DrawPos);
	TargetPos[2] += StringToFloat(DrawPos);

	if (StrEqual(DrawColour, "green", false)) TE_SetupBeamPoints(ClientPos, TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {0, 255, 0, 200}, 50);
	else if (StrEqual(DrawColour, "red", false)) TE_SetupBeamPoints(ClientPos, TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {255, 0, 0, 200}, 50);
	else if (StrEqual(DrawColour, "blue", false)) TE_SetupBeamPoints(ClientPos, TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {0, 0, 255, 200}, 50);
	else if (StrEqual(DrawColour, "purple", false)) TE_SetupBeamPoints(ClientPos, TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {255, 0, 255, 200}, 50);
	else if (StrEqual(DrawColour, "yellow", false)) TE_SetupBeamPoints(ClientPos, TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {255, 255, 0, 200}, 50);
	else if (StrEqual(DrawColour, "orange", false)) TE_SetupBeamPoints(ClientPos, TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {255, 69, 0, 200}, 50);
	else if (StrEqual(DrawColour, "black", false)) TE_SetupBeamPoints(ClientPos, TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {0, 0, 0, 200}, 50);
	else if (StrEqual(DrawColour, "brightblue", false)) TE_SetupBeamPoints(ClientPos, TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {132, 112, 255, 200}, 50);
	else if (StrEqual(DrawColour, "darkgreen", false)) TE_SetupBeamPoints(ClientPos, TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {178, 34, 34, 200}, 50);
	else if (StrEqual(DrawColour, "white", false)) TE_SetupBeamPoints(ClientPos, TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {255, 255, 255, 200}, 50);
	else return 0;
	TE_SendToClient(targetClient);
	return 1;
}
stock int CreateRingSoloEx(int client, float RingAreaSize, char[] DrawColour, char[] DrawPos, bool IsPulsing = true, float lifetime = 1.0, int targetClient, float PosX=0.0, float PosY=0.0, float PosZ=0.0) {
	float ClientPos[3];
	if (client != -1) {
		if (IsLegitimateClient(client)) GetClientAbsOrigin(client, ClientPos);
		else GetEntPropVector(client, Prop_Send, "m_vecOrigin", ClientPos);
	}
	else {
		ClientPos[0] = PosX;
		ClientPos[1] = PosY;
		ClientPos[2] = PosZ;
	}
	float pulserange = 0.0;
	if (IsPulsing) pulserange = 32.0;
	else pulserange = RingAreaSize - 32.0;

	ClientPos[2] += 20.0;
	ClientPos[2] += StringToFloat(DrawPos);

	if (StrEqual(DrawColour, "green", false)) TE_SetupBeamRingPoint(ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {0, 255, 0, 200}, 50, 0);
	else if (StrEqual(DrawColour, "red", false)) TE_SetupBeamRingPoint(ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {255, 0, 0, 200}, 50, 0);
	else if (StrEqual(DrawColour, "blue", false)) TE_SetupBeamRingPoint(ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {0, 0, 255, 200}, 50, 0);
	else if (StrEqual(DrawColour, "purple", false)) TE_SetupBeamRingPoint(ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {255, 0, 255, 200}, 50, 0);
	else if (StrEqual(DrawColour, "yellow", false)) TE_SetupBeamRingPoint(ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {255, 255, 0, 200}, 50, 0);
	else if (StrEqual(DrawColour, "orange", false)) TE_SetupBeamRingPoint(ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {255, 69, 0, 200}, 50, 0);
	else if (StrEqual(DrawColour, "black", false)) TE_SetupBeamRingPoint(ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {0, 0, 0, 200}, 50, 0);
	else if (StrEqual(DrawColour, "brightblue", false)) TE_SetupBeamRingPoint(ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {132, 112, 255, 200}, 50, 0);
	else if (StrEqual(DrawColour, "darkgreen", false)) TE_SetupBeamRingPoint(ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {178, 34, 34, 200}, 50, 0);
	else if (StrEqual(DrawColour, "white", false)) TE_SetupBeamRingPoint(ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {255, 255, 255, 200}, 50, 0);
	else return 0;
	TE_SendToClient(targetClient);
	return 1;
}

stock int CreateRingEx(int client, float RingAreaSize, char[] DrawColour, float DrawPos, bool IsPulsing = true, float lifetime = 1.0, int targetClient = 0) {

	float ClientPos[3];
	if (IsLegitimateClient(client)) GetClientAbsOrigin(client, ClientPos);
	else GetEntPropVector(client, Prop_Send, "m_vecOrigin", ClientPos);

	float pulserange = 0.0;
	if (IsPulsing) pulserange = 32.0;
	else pulserange = RingAreaSize - 32.0;

	ClientPos[2] += DrawPos;
	if (StrEqual(DrawColour, "green", false)) TE_SetupBeamRingPoint(ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {0, 255, 0, 200}, 50, 0);
	else if (StrEqual(DrawColour, "red", false)) TE_SetupBeamRingPoint(ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {255, 0, 0, 200}, 50, 0);
	else if (StrEqual(DrawColour, "blue", false)) TE_SetupBeamRingPoint(ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {0, 0, 255, 200}, 50, 0);
	else if (StrEqual(DrawColour, "purple", false)) TE_SetupBeamRingPoint(ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {255, 0, 255, 200}, 50, 0);
	else if (StrEqual(DrawColour, "yellow", false)) TE_SetupBeamRingPoint(ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {255, 255, 0, 200}, 50, 0);
	else if (StrEqual(DrawColour, "orange", false)) TE_SetupBeamRingPoint(ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {255, 69, 0, 200}, 50, 0);
	else if (StrEqual(DrawColour, "black", false)) TE_SetupBeamRingPoint(ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {0, 0, 0, 200}, 50, 0);
	else if (StrEqual(DrawColour, "brightblue", false)) TE_SetupBeamRingPoint(ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {132, 112, 255, 200}, 50, 0);
	else if (StrEqual(DrawColour, "darkgreen", false)) TE_SetupBeamRingPoint(ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {178, 34, 34, 200}, 50, 0);
	else if (StrEqual(DrawColour, "white", false)) TE_SetupBeamRingPoint(ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {255, 255, 255, 200}, 50, 0);
	else return 0;
	TE_SendToAll();
	return 1;
}























stock void CreateLineSolo(int client, int target, char[] DrawColour, char[] DrawPos, float lifetime = 0.5, int targetClient = 0) {

	float ClientPos[3];
	float TargetPos[3];
	if (IsLegitimateClient(client)) GetClientAbsOrigin(client, ClientPos);
	else GetEntPropVector(client, Prop_Send, "m_vecOrigin", ClientPos);
	if (IsLegitimateClient(target)) GetClientAbsOrigin(target, TargetPos);
	else GetEntPropVector(target, Prop_Send, "m_vecOrigin", TargetPos);

	int DrawColourCount = GetDelimiterCount(DrawColour, ":") + 1;
	char[][] t_DrawColour = new char[DrawColourCount][12];
	ExplodeString(DrawColour, ":", t_DrawColour, DrawColourCount, 12);

	char[][] t_DrawPos = new char[DrawColourCount][10];
	ExplodeString(DrawPos, ":", t_DrawPos, DrawColourCount, 10);

	float t_ClientPos[3];
	t_ClientPos = ClientPos;
	float t_TargetPos[3];
	t_TargetPos = TargetPos;

	for (int i = 0; i < DrawColourCount; i++) {

		t_ClientPos = ClientPos;
		t_TargetPos = TargetPos;

		t_ClientPos[2] += StringToFloat(t_DrawPos[i]);
		t_TargetPos[2] += StringToFloat(t_DrawPos[i]);

		if (StrEqual(t_DrawColour[i], "green", false)) TE_SetupBeamPoints(t_ClientPos, t_TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {0, 255, 0, 200}, 50);
		else if (StrEqual(t_DrawColour[i], "red", false)) TE_SetupBeamPoints(t_ClientPos, t_TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {255, 0, 0, 200}, 50);
		else if (StrEqual(t_DrawColour[i], "blue", false)) TE_SetupBeamPoints(t_ClientPos, t_TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {0, 0, 255, 200}, 50);
		else if (StrEqual(t_DrawColour[i], "purple", false)) TE_SetupBeamPoints(t_ClientPos, t_TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {255, 0, 255, 200}, 50);
		else if (StrEqual(t_DrawColour[i], "yellow", false)) TE_SetupBeamPoints(t_ClientPos, t_TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {255, 255, 0, 200}, 50);
		else if (StrEqual(t_DrawColour[i], "orange", false)) TE_SetupBeamPoints(t_ClientPos, t_TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {255, 69, 0, 200}, 50);
		else if (StrEqual(t_DrawColour[i], "black", false)) TE_SetupBeamPoints(t_ClientPos, t_TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {0, 0, 0, 200}, 50);
		else if (StrEqual(t_DrawColour[i], "brightblue", false)) TE_SetupBeamPoints(t_ClientPos, t_TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {132, 112, 255, 200}, 50);
		else if (StrEqual(t_DrawColour[i], "darkgreen", false)) TE_SetupBeamPoints(t_ClientPos, t_TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {178, 34, 34, 200}, 50);
		else if (StrEqual(t_DrawColour[i], "white", false)) TE_SetupBeamPoints(t_ClientPos, t_TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {255, 255, 255, 200}, 50);
		else continue;
		TE_SendToClient(targetClient);
	}
}
stock void CreateRingSolo(int client, float RingAreaSize, char[] DrawColour, char[] DrawPos, bool IsPulsing = true, float lifetime = 1.0, int targetClient, float PosX=0.0, float PosY=0.0, float PosZ=0.0) {

	float ClientPos[3];
	//if (!IsWitch(client) && !IsCommonInfected(client)) GetClientAbsOrigin(client, ClientPos);
	if (client != -1) {

		if (IsLegitimateClient(client)) GetClientAbsOrigin(client, ClientPos);
		else GetEntPropVector(client, Prop_Send, "m_vecOrigin", ClientPos);
	}
	else {

		ClientPos[0] = PosX;
		ClientPos[1] = PosY;
		ClientPos[2] = PosZ;
	}

	float pulserange = 0.0;
	if (IsPulsing) pulserange = 32.0;
	else pulserange = RingAreaSize - 32.0;
	//LogMessage("==============\nDraw Colour: %s\n===============", DrawColour);

	int DrawColourCount = GetDelimiterCount(DrawColour, ":") + 1;
	char[][] t_DrawColour = new char[DrawColourCount][12];
	ExplodeString(DrawColour, ":", t_DrawColour, DrawColourCount, 12);

	char[][] t_DrawPos = new char[DrawColourCount][10];
	ExplodeString(DrawPos, ":", t_DrawPos, DrawColourCount, 10);

	ClientPos[2] += 20.0;

	float t_ClientPos[3];
	t_ClientPos = ClientPos;

	for (int i = 0; i < DrawColourCount; i++) {

		t_ClientPos = ClientPos;

		t_ClientPos[2] += StringToFloat(t_DrawPos[i]);

		if (StrEqual(t_DrawColour[i], "green", false)) TE_SetupBeamRingPoint(t_ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {0, 255, 0, 200}, 50, 0);
		else if (StrEqual(t_DrawColour[i], "red", false)) TE_SetupBeamRingPoint(t_ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {255, 0, 0, 200}, 50, 0);
		else if (StrEqual(t_DrawColour[i], "blue", false)) TE_SetupBeamRingPoint(t_ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {0, 0, 255, 200}, 50, 0);
		else if (StrEqual(t_DrawColour[i], "purple", false)) TE_SetupBeamRingPoint(t_ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {255, 0, 255, 200}, 50, 0);
		else if (StrEqual(t_DrawColour[i], "yellow", false)) TE_SetupBeamRingPoint(t_ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {255, 255, 0, 200}, 50, 0);
		else if (StrEqual(t_DrawColour[i], "orange", false)) TE_SetupBeamRingPoint(t_ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {255, 69, 0, 200}, 50, 0);
		else if (StrEqual(t_DrawColour[i], "black", false)) TE_SetupBeamRingPoint(t_ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {0, 0, 0, 200}, 50, 0);
		else if (StrEqual(t_DrawColour[i], "brightblue", false)) TE_SetupBeamRingPoint(t_ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {132, 112, 255, 200}, 50, 0);
		else if (StrEqual(t_DrawColour[i], "darkgreen", false)) TE_SetupBeamRingPoint(t_ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {178, 34, 34, 200}, 50, 0);
		else if (StrEqual(t_DrawColour[i], "white", false)) TE_SetupBeamRingPoint(t_ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {255, 255, 255, 200}, 50, 0);
		else continue;
		TE_SendToClient(targetClient);
	}
}

// line 840
stock void CreateLine(int client, int target, char[] DrawColour, char[] DrawPos, float lifetime = 0.5, int targetClient = 0) {

	float ClientPos[3];
	float TargetPos[3];
	if (IsLegitimateClient(client)) GetClientAbsOrigin(client, ClientPos);
	else GetEntPropVector(client, Prop_Send, "m_vecOrigin", ClientPos);
	if (IsLegitimateClient(target)) GetClientAbsOrigin(target, TargetPos);
	else GetEntPropVector(target, Prop_Send, "m_vecOrigin", TargetPos);

	int DrawColourCount = GetDelimiterCount(DrawColour, ":") + 1;
	char[][] t_DrawColour = new char[DrawColourCount][12];
	ExplodeString(DrawColour, ":", t_DrawColour, DrawColourCount, 12);

	char[][] t_DrawPos = new char[DrawColourCount][10];
	ExplodeString(DrawPos, ":", t_DrawPos, DrawColourCount, 10);

	float t_ClientPos[3];
	t_ClientPos = ClientPos;
	float t_TargetPos[3];
	t_TargetPos = TargetPos;

	for (int i = 0; i < DrawColourCount; i++) {
		t_ClientPos = ClientPos;
		t_TargetPos = TargetPos;
		t_ClientPos[2] += StringToFloat(t_DrawPos[i]);
		t_TargetPos[2] += StringToFloat(t_DrawPos[i]);
		if (StrEqual(t_DrawColour[i], "green", false)) TE_SetupBeamPoints(t_ClientPos, t_TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {0, 255, 0, 200}, 50);
		else if (StrEqual(t_DrawColour[i], "red", false)) TE_SetupBeamPoints(t_ClientPos, t_TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {255, 0, 0, 200}, 50);
		else if (StrEqual(t_DrawColour[i], "blue", false)) TE_SetupBeamPoints(t_ClientPos, t_TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {0, 0, 255, 200}, 50);
		else if (StrEqual(t_DrawColour[i], "purple", false)) TE_SetupBeamPoints(t_ClientPos, t_TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {255, 0, 255, 200}, 50);
		else if (StrEqual(t_DrawColour[i], "yellow", false)) TE_SetupBeamPoints(t_ClientPos, t_TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {255, 255, 0, 200}, 50);
		else if (StrEqual(t_DrawColour[i], "orange", false)) TE_SetupBeamPoints(t_ClientPos, t_TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {255, 69, 0, 200}, 50);
		else if (StrEqual(t_DrawColour[i], "black", false)) TE_SetupBeamPoints(t_ClientPos, t_TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {0, 0, 0, 200}, 50);
		else if (StrEqual(t_DrawColour[i], "brightblue", false)) TE_SetupBeamPoints(t_ClientPos, t_TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {132, 112, 255, 200}, 50);
		else if (StrEqual(t_DrawColour[i], "darkgreen", false)) TE_SetupBeamPoints(t_ClientPos, t_TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {178, 34, 34, 200}, 50);
		else if (StrEqual(t_DrawColour[i], "white", false)) TE_SetupBeamPoints(t_ClientPos, t_TargetPos, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, 0, 0.5, {255, 255, 255, 200}, 50);
		else continue;
		TE_SendToAll();
	}
}

stock void CreateRing(int client, float RingAreaSize, char[] DrawColour, char[] DrawPos, bool IsPulsing = true, float lifetime = 1.0, int targetClient = 0) {

	float ClientPos[3];
	if (IsLegitimateClient(client)) GetClientAbsOrigin(client, ClientPos);
	else GetEntPropVector(client, Prop_Send, "m_vecOrigin", ClientPos);

	float pulserange = 0.0;
	if (IsPulsing) pulserange = 32.0;
	else pulserange = RingAreaSize - 32.0;
	//LogMessage("==============\nDraw Colour: %s\n===============", DrawColour);

	int DrawColourCount = GetDelimiterCount(DrawColour, ":") + 1;
	char[][] t_DrawColour = new char[DrawColourCount][12];
	ExplodeString(DrawColour, ":", t_DrawColour, DrawColourCount, 12);

	char[][] t_DrawPos = new char[DrawColourCount][10];
	ExplodeString(DrawPos, ":", t_DrawPos, DrawColourCount, 10);

	float t_ClientPos[3];
	t_ClientPos = ClientPos;

	for (int i = 0; i < DrawColourCount; i++) {
		t_ClientPos = ClientPos;
		t_ClientPos[2] += StringToFloat(t_DrawPos[i]);
		if (StrEqual(t_DrawColour[i], "green", false)) TE_SetupBeamRingPoint(t_ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {0, 255, 0, 200}, 50, 0);
		else if (StrEqual(t_DrawColour[i], "red", false)) TE_SetupBeamRingPoint(t_ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {255, 0, 0, 200}, 50, 0);
		else if (StrEqual(t_DrawColour[i], "blue", false)) TE_SetupBeamRingPoint(t_ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {0, 0, 255, 200}, 50, 0);
		else if (StrEqual(t_DrawColour[i], "purple", false)) TE_SetupBeamRingPoint(t_ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {255, 0, 255, 200}, 50, 0);
		else if (StrEqual(t_DrawColour[i], "yellow", false)) TE_SetupBeamRingPoint(t_ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {255, 255, 0, 200}, 50, 0);
		else if (StrEqual(t_DrawColour[i], "orange", false)) TE_SetupBeamRingPoint(t_ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {255, 69, 0, 200}, 50, 0);
		else if (StrEqual(t_DrawColour[i], "black", false)) TE_SetupBeamRingPoint(t_ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {0, 0, 0, 200}, 50, 0);
		else if (StrEqual(t_DrawColour[i], "brightblue", false)) TE_SetupBeamRingPoint(t_ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {132, 112, 255, 200}, 50, 0);
		else if (StrEqual(t_DrawColour[i], "darkgreen", false)) TE_SetupBeamRingPoint(t_ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {178, 34, 34, 200}, 50, 0);
		else if (StrEqual(t_DrawColour[i], "white", false)) TE_SetupBeamRingPoint(t_ClientPos, pulserange, RingAreaSize, g_iSprite, g_BeaconSprite, 0, 15, lifetime, 2.0, 0.5, {255, 255, 255, 200}, 50, 0);
		else continue;
		TE_SendToAll();
	}
}

/*stock BeaconCorpsesInRange(int client) {

	new Float:ClientPos[3];
	GetClientAbsOrigin(client, ClientPos);
	new Float:Pos[3];

	for (new i = 1; i <= MaxClients; i++) {

		if (!IsLegitimateClient(i) || GetClientTeam(i) != TEAM_SURVIVOR || IsFakeClient(i) || IsPlayerAlive(i)) continue;
		if (GetVectorDistance(ClientPos, DeathLocation[i]) < 1024.0) {

			Pos[0] = DeathLocation[i][0];
			Pos[1] = DeathLocation[i][1];
			Pos[2] = DeathLocation[i][2] + 40.0;
			TE_SetupBeamRingPoint(Pos, 128.0, 256.0, g_iSprite, g_BeaconSprite, 0, 15, 0.5, 2.0, 0.5, {20, 20, 150, 150}, 50, 0);
			TE_SendToClient(client);
		}
	}
}*/

stock void CreateBeacons(int client, float Distance) {

	float Pos[3];
	float Pos2[3];

	GetClientAbsOrigin(client, Pos);
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsLegitimateClientAlive(i) && i != client && GetClientTeam(i) != GetClientTeam(client)) {

			GetClientAbsOrigin(i, Pos2);
			if (GetVectorDistance(Pos, Pos2) > Distance) continue;

			Pos2[2] += 20.0;
			TE_SetupBeamRingPoint(Pos2, 32.0, 128.0, g_iSprite, g_BeaconSprite, 0, 15, 0.5, 2.0, 0.5, {20, 20, 150, 150}, 50, 0);
			TE_SendToClient(client);
		}
	}
}

stock void FrozenPlayer(int client, float effectTime = 3.0, int amount = 100) {
	if (IsLegitimateClient(client)) {
		if (amount < 0) amount = 0;
		if (amount > 0) {
			if (effectTime > 0.0) {
				CreateTimer(effectTime, Timer_FrozenPlayer, client, TIMER_FLAG_NO_MAPCHANGE);
				SetEntityMoveType(client, MOVETYPE_NONE);
			}
			else if (ISFROZEN[client] == INVALID_HANDLE) {
				ISFROZEN[client] = CreateTimer(0.25, Timer_Freezer, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				SetEntityMoveType(client, MOVETYPE_NONE);
			}
		}
		else SetEntityMoveType(client, MOVETYPE_WALK);

		if (!IsFakeClient(client)) {

			int clients[2];
			clients[0] = client;
			UserMsg BlindMsgID = GetUserMessageId("Fade");
			Handle message = StartMessageEx(BlindMsgID, clients, 1);

			BfWriteShort(message, 1536);
			BfWriteShort(message, 1536);
			
			if (amount == 0) BfWriteShort(message, (0x0001 | 0x0010));
			else BfWriteShort(message, (0x0002 | 0x0008));

			BfWriteByte(message, 132);
			BfWriteByte(message, 112);
			BfWriteByte(message, 255);
			BfWriteByte(message, amount);

			EndMessage();
		}	
	}
}

stock void EnrageBlind(int client, int amount=0) {

	if (IsLegitimateClient(client) && !IsFakeClient(client)) {

		int clients[2];
		clients[0] = client;
		UserMsg BlindMsgID = GetUserMessageId("Fade");
		Handle message = StartMessageEx(BlindMsgID, clients, 1);
		BfWriteShort(message, 1536);
		BfWriteShort(message, 1536);
		
		if (amount == 0)
		{
			BfWriteShort(message, (0x0001 | 0x0010));
		}
		else
		{
			BfWriteShort(message, (0x0002 | 0x0008));
		}

		if (amount > 0) {

			BfWriteByte(message, 100);
			BfWriteByte(message, 20);
			BfWriteByte(message, 20);
		}
		else {

			BfWriteByte(message, 0);
			BfWriteByte(message, 0);
			BfWriteByte(message, 0);
		}
		BfWriteByte(message, amount);
		EndMessage();
	}
}

stock void BlindPlayer(int client, float effectTime = 3.0, int amount = 0) {

	if (IsLegitimateClient(client) && !IsFakeClient(client)) {

		int clients[2];
		clients[0] = client;
		UserMsg BlindMsgID = GetUserMessageId("Fade");
		Handle message = StartMessageEx(BlindMsgID, clients, 1);
		BfWriteShort(message, 1536);
		BfWriteShort(message, 1536);
		
		if (amount == 0)
		{
			BfWriteShort(message, (0x0001 | 0x0010));
		}
		else
		{
			BfWriteShort(message, (0x0002 | 0x0008));
		}

		BfWriteByte(message, 0);
		BfWriteByte(message, 0);
		BfWriteByte(message, 0);
		
		if (amount > 0) {

			//b_IsBlind[client] = true;
			if (effectTime > 0.0) CreateTimer(effectTime, Timer_BlindPlayer, client, TIMER_FLAG_NO_MAPCHANGE);
			else {

				/*

					Special Commons set an effect time of 0.0.
				*/
				if (ISBLIND[client] == INVALID_HANDLE) ISBLIND[client] = CreateTimer(0.25, Timer_Blinder, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			}
			BfWriteByte(message, amount);
		}
		else {

			//b_IsBlind[client] = false;
			BfWriteByte(message, 0);
		}
		EndMessage();
	}
}

stock void CreateFireEx(int client)
{
	if (IsLegitimateClient(client)) {

		float pos[3];
		GetClientAbsOrigin(client, pos);
		CreateFire(pos);
	}
}

//const String:MODEL_PIPEBOMB[] = "models/w_models/weapons/w_eq_pipebomb.mdl;"

char MODEL_GASCAN[] = "models/props_junk/gascan001a.mdl";

stock void CreateFire(const float BombOrigin[3])
{
	int entity = CreateEntityByName("prop_physics");
	DispatchKeyValue(entity, "physdamagescale", "0.0");
	if (!IsModelPrecached(MODEL_GASCAN))
	{
		PrecacheModel(MODEL_GASCAN);
	}
	DispatchKeyValue(entity, "model", MODEL_GASCAN);
	DispatchSpawn(entity);
	TeleportEntity(entity, BombOrigin, NULL_VECTOR, NULL_VECTOR);
	SetEntityMoveType(entity, MOVETYPE_VPHYSICS);
	AcceptEntityInput(entity, "Break");
}

stock bool EnemyCombatantsWithinRange(int client, float f_Distance) {

	float d_Client[3];
	float e_Client[3]
	GetClientAbsOrigin(client, d_Client);
	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && GetClientTeam(i) != GetClientTeam(client)) {

			GetClientAbsOrigin(i, e_Client);
			if (GetVectorDistance(d_Client, e_Client) <= f_Distance) return true;
		}
	}
	return false;
}

stock bool IsTanksActive() {

	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && GetClientTeam(i) == TEAM_INFECTED && FindZombieClass(i) == ZOMBIECLASS_TANK) return true;
	}
	return false;
}

stock void ModifyGravity(int client, float g_Gravity = 0.9, float g_Time = 0.0, bool b_Jumping = false) {

	if (IsLegitimateClientAlive(client)) {

		//if (b_IsJumping[client]) return;	// survivors only, for the moon jump ability
		if (b_Jumping) {

			b_IsJumping[client] = true;
			CreateTimer(0.1, Timer_DetectGroundTouch, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
		if (g_Gravity == 0.9) SetEntityGravity(client, g_Gravity);
		else {

			if (g_Gravity > 1.0 && g_Gravity < 100.0) g_Gravity *= 0.01;
			else if (g_Gravity > 1.0 && g_Gravity < 1000.0) g_Gravity *= 0.001;
			else if (g_Gravity > 1.0 && g_Gravity < 10000.0) g_Gravity *= 0.0001;
			g_Gravity = 0.9 - g_Gravity;
			if (g_Gravity < 0.1) g_Gravity = 0.1;
			SetEntityGravity(client, g_Gravity);
		}
		if (g_Gravity < 0.9 && !b_Jumping) CreateTimer(g_Time, Timer_ResetGravity, client, TIMER_FLAG_NO_MAPCHANGE);
	}
}

stock bool OnPlayerRevived(int client, int targetclient) {

	if (SetTempHealth(client, targetclient, GetMaximumHealth(targetclient) * fHealthSurvivorRevive, true)) return true;
	return false;
}

stock float GetTempHealth(int client) {

	return GetEntPropFloat(client, Prop_Send, "m_healthBuffer");
}

stock int SetMaximumHealth(int client) {
	if (!IsLegitimateClient(client)) return 1;
	int ClientTeam = GetClientTeam(client);

	if (ClientTeam != TEAM_SURVIVOR) return DefaultHealth[client];

	bool playerIsIncapacitated = IsIncapacitated(client);

	int isRaw = RoundToCeil(GetAbilityStrengthByTrigger(client, client, "p", _, 0, _, _, "H", _, _, 2));			// 2 gets ONLY raw returns

	float TheAbilityMultiplier = GetAbilityMultiplier(client, "V");
	//if (TheAbilityMultiplier == -1.0) TheAbilityMultiplier = 0.0;
	if (TheAbilityMultiplier != -1) isRaw += RoundToCeil(isRaw * TheAbilityMultiplier);
	// health values are now only raw values.
	if (!playerIsIncapacitated && IsClientInRangeSpecialAmmo(client, "O") == -2.0) isRaw += RoundToCeil(isRaw * IsClientInRangeSpecialAmmo(client, "O", false, _, isRaw * 1.0));
	if (playerIsIncapacitated) DefaultHealth[client] = iDefaultIncapHealth + isRaw;
	else DefaultHealth[client] = iSurvivorBaseHealth + isRaw;

	if (DefaultHealth[client] > 50000) DefaultHealth[client] = 50000;
	SetEntProp(client, Prop_Send, "m_iMaxHealth", DefaultHealth[client]);

	if (playerIsIncapacitated && bIsGiveIncapHealth[client]) {
		bIsGiveIncapHealth[client] = false;
		GiveMaximumHealth(client, DefaultHealth[client]);
	}
	if (GetClientHealth(client) > DefaultHealth[client]) GiveMaximumHealth(client);
	return DefaultHealth[client];
}

stock int FindZombieClass(int client, bool SIOnly = false)
{
	if (!SIOnly) {

		if (IsWitch(client)) return 7;
		if (IsSpecialCommon(client)) return 8;
		if (IsCommonInfected(client)) return 9;
		if (GetClientTeam(client) == TEAM_SURVIVOR) return 0;
	}
	if (IsLegitimateClient(client)) return GetEntProp(client, Prop_Send, "m_zombieClass");
	return -1;
}

stock void SetInfectedHealth(int client, int value) {

	SetEntProp(client, Prop_Data, "m_iHealth", value);
}

stock int GetInfectedHealth(int client) {

	return GetEntProp(client, Prop_Data, "m_iHealth");
}

stock void SetBaseHealth(int client) {

	SetEntProp(client, Prop_Send, "m_iMaxHealth", DefaultHealth[client]);
}

stock void GiveMaximumHealth(int client, int healthOverride = 0) {

	if (IsLegitimateClientAlive(client) && !b_IsLoading[client]) {
		if (healthOverride == 0) healthOverride = GetMaximumHealth(client);

		GetAbilityStrengthByTrigger(client, _, "a");

		if (GetClientTeam(client) == TEAM_INFECTED || !IsIncapacitated(client)) SetEntPropFloat(client, Prop_Send, "m_healthBuffer", 0.0);
		else SetEntPropFloat(client, Prop_Send, "m_healthBuffer", healthOverride * 1.0);
		
		SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime() * 1.0);
		SetEntityHealth(client, healthOverride);
	}
}

stock int GetMaximumHealth(int client)
{
	if (IsLegitimateClient(client)) {

		//return GetEntProp(client, Prop_Send, "m_iMaxHealth");
		int iMaxHealth = GetEntProp(client, Prop_Send, "m_iMaxHealth");
		if (iMaxHealth > DefaultHealth[client]) DefaultHealth[client] = iMaxHealth;
		return iMaxHealth;
	}
	else return 0;
}

// This is for active statuses, not buffs/talents/etc.
int CheckActiveStatuses(int client, char[] sStatus, bool bGetStatus = true, bool bDeleteStatus = false) {

	char text[64];

	int size = ActiveStatuses[client].Length;

	for (int i = 0; i < size; i++) {

		ActiveStatuses[client].GetString(i, text, sizeof(text));
		if (StrEqual(sStatus, text)) {

			if (!bDeleteStatus || bGetStatus) return 2;	// 2 - Cannot add status because it is already in effect.
			ActiveStatuses[client].Erase(i);
			return 0;									// 0 - means the status was deleted.
		}
	}
	if (!bDeleteStatus && !bGetStatus) {

		ActiveStatuses[client].PushString(sStatus);
		return 1;										// 1 - status inserted
	}
	return -1;											// -1 - status not found.
}

stock void CloakingDevice(int client) {

	int theresult = CheckActiveStatuses(client, "lunge");

	if (IsLegitimateClientAlive(client) && theresult == -1) {

		SetEntityRenderMode(client, RENDER_TRANSCOLOR);
		SetEntityRenderColor(client, 255, 255, 255, 0);
		//CreateTimer(g_Time, Timer_CloakingDeviceBreakdown, client, TIMER_FLAG_NO_MAPCHANGE);

		CheckActiveStatuses(client, "lunge", false);	// adds the lunge effect to the active statuses.
	}
}

stock void AbsorbDamage(int client, float s_Strength, int damage) {

	if (IsLegitimateClientAlive(client)) {

		if (GetClientTeam(client) == TEAM_INFECTED || !IsIncapacitated(client)) {

			int absorb = RoundToFloor(s_Strength);
			if (absorb > damage) absorb = damage;

			SetEntityHealth(client, GetClientHealth(client) + absorb);
		}
	}
}

stock void DamagePlayer(int client, int victim, float s_Strength) {

	if (IsLegitimateClientAlive(client) && IsLegitimateClientAlive(victim)) {

		int d_Damage = RoundToFloor(s_Strength);

		if (GetClientHealth(victim) > 1) {

			if (GetClientHealth(victim) + 1 < d_Damage) d_Damage = GetClientHealth(victim) - 1;
			if (d_Damage > 0) {

				DamageAward[client][victim] += d_Damage;
				SetEntityHealth(victim, GetClientHealth(victim) - d_Damage);
			}
		}
	}
}

stock void WipeDamageAward(int client) {

	for (int i = 1; i <= MaxClients; i++) {

		DamageAward[client][i] = 0;
	}
}

stock void ReflectDamage(int client, int target, int AttackDamage) {
	int enemytype = -1;
	int enemyteam = -1;
	if (IsSpecialCommon(target)) enemytype = 1;
	else if (IsCommonInfected(target)) enemytype = 0;
	else if (IsWitch(target)) enemytype = 2;
	else if (IsLegitimateClientAlive(target)) {
		enemytype = 3;
		enemyteam = GetClientTeam(target);
	}
	if (enemytype == 1) AddSpecialCommonDamage(client, target, AttackDamage, true);
	else if (enemytype == 0) AddCommonInfectedDamage(client, target, AttackDamage, true);
	else if (enemytype == 2) {
		if (FindListPositionByEntity(target, WitchList) < 0) OnWitchCreated(target);
		AddWitchDamage(client, target, AttackDamage, true);
	}
	else if (enemytype == 3 && enemyteam == TEAM_INFECTED) AddSpecialInfectedDamage(client, target, AttackDamage);
	if (enemytype > 0) {
		if (LastAttackedUser[client] == target) ConsecutiveHits[client]++;
		else {
			LastAttackedUser[client] = target;
			ConsecutiveHits[client] = 0;
		}
	}
	if (!IsLegitimateClient(target) || enemyteam == TEAM_INFECTED) {
		CheckTeammateDamagesEx(client, target, AttackDamage);
	}
}

stock void CheckTeammateDamagesEx(int client, int target, int TotalDamage, bool bSpellDeath = false) {
	if (CheckTeammateDamages(target, client) >= 1.0 || CheckTeammateDamages(target, client, true) >= 1.0) {
		if (IsLegitimateClientAlive(target)) {
			GetAbilityStrengthByTrigger(client, target, "e", _, TotalDamage);
			GetAbilityStrengthByTrigger(target, client, "E", _, TotalDamage);
			CalculateInfectedDamageAward(target, client);
		}
		else {
			if (IsWitch(target)) {
				GetAbilityStrengthByTrigger(client, target, "witchkill", _, TotalDamage);
				OnWitchCreated(target, true);
			}
			else if (IsSpecialCommon(target)) {
				GetAbilityStrengthByTrigger(client, target, "superkill", _, TotalDamage);
				ClearSpecialCommon(target, _, TotalDamage, client);
			}
			else GetAbilityStrengthByTrigger(client, target, "C", _, TotalDamage);
		}
	}
}

/*stock ReflectDamage(client, victim, Float:g_TalentStrength, d_Damage) {

	if (IsLegitimateClientAlive(client) && IsLegitimateClientAlive(victim)) {

		new reflectHealth = RoundToFloor(g_TalentStrength);
		new reflectValue = 0;
		if (reflectHealth > d_Damage) reflectHealth = d_Damage;
		if (!IsIncapacitated(client) && IsPlayerAlive(client)) {

			if (GetClientHealth(client) > reflectHealth) reflectValue = reflectHealth;
			else reflectValue = GetClientHealth(client) - 1;
			SetEntityHealth(client, GetClientHealth(client) - reflectValue);
			DamageAward[client][victim] -= reflectValue;
			DamageAward[victim][client] += reflectValue;
		}
	}
}*/

stock void SendPanelToClientAndClose(Panel panel, int client, MenuHandler handler, int time) {

	panel.Send(client, handler, time);
	delete panel;
}

stock void CreateAcid(int client, int victim, float radius = 128.0) {
	if (IsCommonInfected(client) || IsLegitimateClient(client)) {
		if (IsLegitimateClientAlive(victim)) {
			float pos[3];
			if (IsLegitimateClient(victim)) GetClientAbsOrigin(victim, pos);
			else GetEntPropVector(victim, Prop_Send, "m_vecOrigin", pos);
			pos[2] += 96.0;
			int acidball = CreateEntityByName("spitter_projectile");
			if (IsValidEntity(acidball)) {
				DispatchSpawn(acidball);
				SetEntPropEnt(acidball, Prop_Send, "m_hThrower", client);
				SetEntPropFloat(acidball, Prop_Send, "m_DmgRadius", radius);
				SetEntProp(acidball, Prop_Send, "m_bIsLive", 1);
				TeleportEntity(acidball, pos, NULL_VECTOR, NULL_VECTOR);
				SDKCall(g_hCreateAcid, acidball);
			}
		}
	}
}

stock void ForceClientJump(int activator, float g_TalentStrength, int victim = 0) {

	if (IsLegitimateClient(activator)) {

		if (GetEntityFlags(activator) & FL_ONGROUND || victim > 0 && GetEntityFlags(victim) & FL_ONGROUND) {

			//new attacker = -1;
			//if (GetClientTeam(activator) != TEAM_INFECTED) attacker = L4D2_GetInfectedAttacker(activator);
			//if (attacker == -1 || !IsClientActual(attacker) || GetClientTeam(attacker) != TEAM_INFECTED || (FindZombieClass(attacker) != ZOMBIECLASS_JOCKEY && FindZombieClass(attacker) != ZOMBIECLASS_CHARGER)) attacker = -1;

			float vel[3];
			vel[0] = GetEntPropFloat(activator, Prop_Send, "m_vecVelocity[0]");
			vel[1] = GetEntPropFloat(activator, Prop_Send, "m_vecVelocity[1]");
			vel[2] = GetEntPropFloat(activator, Prop_Send, "m_vecVelocity[2]");
			vel[2] += g_TalentStrength;
			if (victim == 0) TeleportEntity(activator, NULL_VECTOR, NULL_VECTOR, vel);
			else TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, vel);
		}
	}
}

stock void ActivateAbilityEx(int activator, int target, int d_Damage, char[] Effects, float g_TalentStrength, float g_TalentTime, int victim = 0,
						char[] Trigger = "0", int isRaw = 0, float AoERange = 0.0, char[] secondaryEffects = "-1",
						float secondaryAoERange = 0.0, int hitgroup = -1, char[] secondaryTrigger = "-1", char[] AbilityTriggerIgnore = "none", int damagetype = -1) {

	//PrintToChat(activator, "damage %d Effects: %s Strength: %3.2f", d_Damage, Effects, g_TalentStrength);
	// Activator is ALWAYS the person who holds the talent. The TARGET is who the ability ALWAYS activates on.

	/*
		It lags a lot when it has to check the string for a specific substring every single time, so we need to call activateabilityex multiple times for each different effect, instead.
	*/

	if (g_TalentStrength > 0.0) {
		// When a node successfully fires, it can call custom ability triggers.
		if (!StrEqual(secondaryTrigger, "-1")) GetAbilityStrengthByTrigger(activator, target, secondaryTrigger);

		// a single node can fire off two effects at maximum. I haven't personally used it to fire off more than one but the option exists.
		if (!StrEqual(secondaryEffects, "-1")) {
			ActivateAbilityEx(activator, target, d_Damage, secondaryEffects, g_TalentStrength, g_TalentTime, victim, Trigger, isRaw, secondaryAoERange, _, _, hitgroup, _, _, damagetype);
		}
		int activatorTeam = GetClientTeam(activator);

		int iDamage = RoundToCeil(d_Damage * g_TalentStrength);
		if (isRaw == 1 || d_Damage == 0) iDamage = RoundToCeil(d_Damage + g_TalentStrength);
		int oDamage = d_Damage;
		int talentStr = RoundToCeil(g_TalentStrength);
		if (iDamage - d_Damage < 0) oDamage = 0;
		if (AoERange > 0.0) {
			int playersInAoERangeCount = 0;
			float activatorPos[3];
			float playersRangePos[3];
			GetClientAbsOrigin(activator, activatorPos);
			for (int i = 1; i <= MaxClients; i++) {
				if (i == activator || !IsLegitimateClientAlive(i) || GetClientTeam(i) == activatorTeam) continue;
				GetClientAbsOrigin(i, playersRangePos);
				if (GetVectorDistance(activatorPos, playersRangePos) <= AoERange) playersInAoERangeCount++;
			}
			if (playersInAoERangeCount > 0) {
				d_Damage /= playersInAoERangeCount;
				if (!StrEqual(AbilityTriggerIgnore, "aoegive")) GetAbilityStrengthByTrigger(activator, target, "aoegive", _, d_Damage, _, _, _, _, _, _, hitgroup, "aoegive", damagetype);
				for (int i = 1; i <= MaxClients; i++) {
					if (i == activator || !IsLegitimateClientAlive(i) || GetClientTeam(i) == activatorTeam) continue;
					GetClientAbsOrigin(i, playersRangePos);
					if (GetVectorDistance(activatorPos, playersRangePos) <= AoERange) {
						// loop the effect through anyone within range of it. because AoERange in this call is 0.0, it won't loop indefinitely.
						ActivateAbilityEx(activator, i, d_Damage, Effects, g_TalentStrength, g_TalentTime, victim, Trigger, isRaw, _, _, _, _, _, _, damagetype);
						if (!StrEqual(AbilityTriggerIgnore, "aoereceive")) GetAbilityStrengthByTrigger(i, target, "aoereceive", _, d_Damage, _, _, _, _, _, _, hitgroup, "aoereceive", damagetype);
					}
				}
				if (!StrEqual(secondaryEffects, "-1")) {
					ActivateAbilityEx(activator, target, d_Damage, secondaryEffects, g_TalentStrength, g_TalentTime, victim, Trigger, isRaw, secondaryAoERange, _, _, hitgroup, _, _, damagetype);
				}
			}
			return;	// if it's an aoe effect we don't do anything for the activating player.
		}
		int anyPlayerNotMe = GetAnyPlayerNotMe(target);
		if (StrEqual(Effects, "maghalfempty")) {
			// this goes up here and we're gonna recursively call for "d"
			//ActivateAbilityEx(activator, target, d_Damage, String:Effects[], Float:g_TalentStrength, Float:g_TalentTime, victim = 0, String:Trigger[] = "0")
			char curEquippedWeapon[64];
			int bulletsFired = 0;
			int WeaponId =	GetEntPropEnt(activator, Prop_Data, "m_hActiveWeapon");
			int bulletsRemaining = GetEntProp(WeaponId, Prop_Send, "m_iClip1");
			GetEntityClassname(WeaponId, curEquippedWeapon, sizeof(curEquippedWeapon));
			currentEquippedWeapon[activator].GetValue(curEquippedWeapon, bulletsFired);
			if (bulletsFired >= bulletsRemaining) {
				// we only do something if the mag is half or more empty.
				int totalMagSize = bulletsFired + bulletsRemaining;
				float fMagazineExhausted = ((bulletsFired * 1.0)/(totalMagSize * 1.0));

				ActivateAbilityEx(activator, target, d_Damage, secondaryEffects, (fMagazineExhausted * g_TalentStrength), g_TalentTime, victim, Trigger, isRaw, secondaryAoERange, _, _, hitgroup, _, _, damagetype);
			}
		}
		else if (StrEqual(Effects, "parry") && IsLegitimateClientAlive(activator) && IsLegitimateClientAlive(target)) {
			StaggerPlayer(target, (activator == target) ? anyPlayerNotMe : activator);
		}
		else if (StrEqual(Effects, "a") && !HasAdrenaline(target)) SDKCall(g_hEffectAdrenaline, target, g_TalentTime);
		else if (StrEqual(Effects, "A") && GetClientTeam(target) == TEAM_SURVIVOR && b_HasDeathLocation[target]) {

			if (!IsPlayerAlive(target)) {

				SDKCall(hRoundRespawn, target);
				b_HasDeathLocation[target] = false;
				CreateTimer(1.0, Timer_TeleportRespawn, target, TIMER_FLAG_NO_MAPCHANGE);
			}
		}
		else if (StrEqual(Effects, "b")) BeanBag(target, g_TalentStrength);
		else if (StrEqual(Effects, "c")) {

			//CreateCombustion(target, g_TalentStrength, g_TalentTime);
			if (FindZombieClass(target) != ZOMBIECLASS_TANK) CreateAndAttachFlame(target, iDamage, g_TalentTime, 0.5, activator, "burn");
		}
		else if (StrEqual(Effects, "d")) {
			bool IsCommonTarget = false;
			bool IsSpecialCommonTarget = false;
			bool IsWitchTarget = false;
			IsWitchTarget = IsWitch(target);
			if (!IsWitchTarget) {
				IsSpecialCommonTarget = IsSpecialCommon(target);
				if (!IsSpecialCommonTarget) IsCommonTarget = IsCommonInfected(target);
			}

			//if (IsSpecialCommonInRange(activator, 'd')) CreateDamageStatusEffect(, 3, activator, RoundToCeil(d_Damage * g_TalentStrength));
			// If the player is biled, we want to trigger abilities that trigger based on damage dealt when biled on, as the player has just dealt bonus damage.
			// they"ll deal additional bonus damage to the target if this is the case.
			// To prevent potential loops we don"t allow a trigger that calls a damage bonus to trigger any talents that use the same trigger in this regard.
			if (IsCoveredInBile(activator)) GetAbilityStrengthByTrigger(activator, target, "B", _, d_Damage);
			if (IsWitchTarget) AddWitchDamage(activator, target, iDamage, true);
			else if (IsSpecialCommonTarget) AddSpecialCommonDamage(activator, target, iDamage, true);
			else if (IsCommonTarget) {
				AddCommonInfectedDamage(activator, target, iDamage, true);
			}
			else if (IsLegitimateClientAlive(target)) {

				if (activatorTeam == TEAM_SURVIVOR && GetClientTeam(target) == activatorTeam && activator != target) SameTeam_OnTakeDamage(activator, target, iDamage - oDamage, true, damagetype);
				else if (GetClientTeam(target) == TEAM_INFECTED) {

					CheckTankSubroutine(target, activator, iDamage, true);
					AddSpecialInfectedDamage(activator, target, iDamage); //DamageBonus(activator, target, d_Damage, g_TalentStrength);
				}
			}
 			if (iDisplayHealthBars == 1) {

				DisplayInfectedHealthBars(activator, target);
			}
			if (CheckTeammateDamages(target, activator) >= 1.0 ||
				CheckTeammateDamages(target, activator, true) >= 1.0) {

				if (IsWitchTarget) OnWitchCreated(target, true);
				else if (IsSpecialCommonTarget) {

					if (IsIncapacitated(activator)) GetAbilityStrengthByTrigger(activator, target, "K", _, iDamage);
					ClearSpecialCommon(target, _, iDamage, activator);
					//IgniteEntity(target, 1.0);
				}
				else if (IsCommonTarget) {

					OnCommonInfectedCreated(target, true, activator);
					IgniteEntity(target, 1.0);
				}
			}
			else {

				/*

						So the player / common took damage.
				*/
				if (IsSpecialCommonTarget) {

					char TheValue[10];
					int pos = 0;
					while (pos >= 0) {
						pos = GetCommonValueAtPos(TheValue, sizeof(TheValue), target, SUPER_COMMON_DAMAGE_EFFECT, pos, false);
						if (pos == -1) break;
						// The bomber explosion initially targets itself so that the chain-reaction (if enabled) doesn"t go indefinitely.
						if (StrEqual(TheValue, "f", true)) CreateDamageStatusEffect(target, _, activator, iDamage);
						if (StrEqual(TheValue, "d", true)) CreateDamageStatusEffect(target, 3, activator, iDamage);		// attacker is not target but just used to pass for reference.
						pos++;
					}
				}
			}
		}
		else if (StrEqual(Effects, "f") && IsLegitimateClient(target)) CreateFireEx(target);
		else if (StrEqual(Effects, "E")) {

			// Healing based on damage RECEIVED.
			HealPlayer(target, activator, (d_Damage * g_TalentStrength) * 1.0, 'h', true);
		}
		else if (StrEqual(Effects, "e")) CreateBeacons(target, g_TalentStrength);
		else if (StrEqual(Effects, "g")) ModifyGravity(target, g_TalentStrength, g_TalentTime, true);
		else if (StrEqual(Effects, "h")) {

			HealPlayer(target, activator, iDamage * 1.0, 'h', true);
		}
		else if (StrEqual(Effects, "u")) {

			HealPlayer(target, activator, iDamage * 1.0, 'h', true);
		}
		// the difference is U affects only players not the caster and u affects everyone. we will code a change later on to free this char
		else if (StrEqual(Effects, "U")) {

			if (target != activator && IsLegitimateClientAlive(activator)) {

				HealPlayer(target, activator, iDamage * 1.0, 'h', true);
			}
		}
		/*else if (StrEqual(Effects, "H")) {

			//ModifyHealth(target, GetAbilityStrengthByTrigger(activator, activator, 'p', FindZombieClass(activator), d_Damage, _, _, "H"), g_TalentTime);
			//ModifyHealth(target, iDamage * 1.0, g_TalentTime, isRaw);
			SetMaximumHealth(target);
		}*/
		else if (StrEqual(Effects, "i") && IsLegitimateClientAlive(target) && !ISBILED[target]) {
			SDKCall(g_hCallVomitOnPlayer, target, activator, true);
			CreateTimer(15.0, Timer_RemoveBileStatus, target, TIMER_FLAG_NO_MAPCHANGE);
			ISBILED[target] = true;
		}
		else if (StrEqual(Effects, "j")) ForceClientJump(activator, g_TalentStrength, target);
		else if (StrEqual(Effects, "l")) CloakingDevice(target);
		else if (StrEqual(Effects, "m")) DamagePlayer(activator, target, g_TalentStrength);
		// There are 3 different result effects for giving ammo back, depending on the request.
		else if (StrEqual(Effects, "r1bullet")) {	// refund a single bullet. great for heal bullet proficiency.
			GiveAmmoBack(target, 1 * talentStr, _, activator);
		}
		else if (StrEqual(Effects, "rrbullet")) { // refund a raw amount, not based on magazine size.
			GiveAmmoBack(target, talentStr, _, activator);
		}
		else if (StrEqual(Effects, "rpbullet")) {
			GiveAmmoBack(target, _, g_TalentStrength, activator);
		}
		else if (StrEqual(Effects, "R")) {

			//LogToFile(LogPathDirectory, "%N used reflect for %d damage", activator, RoundToCeil(g_TalentStrength * d_Damage));
			//if (IsSpecialCommon(target)) LogToFile(LogPathDirectory, "%N reflected %d to a special common!", activator, RoundToCeil(g_TalentStrength * d_Damage));
			//else if (IsCommonInfected(target)) LogToFile(LogPathDirectory, "%N reflected %d to a common!", activator, RoundToCeil(g_TalentStrength * d_Damage));

			ReflectDamage(activator, target, iDamage);
		}
		else if (StrEqual(Effects, "s")) SlowPlayer(target, g_TalentStrength, g_TalentTime);
		else if (StrEqual(Effects, "speed")) SlowPlayer(target, 1.0 + g_TalentStrength, g_TalentTime);
		else if (StrEqual(Effects, "S")) {

			StaggerPlayer(target, activator);
			//ExecCheatCommand(target, "sm_slap");// this is a workaround but i dont really want the ability in the game anymore. freebies != soulslike
			//decl String:clientname[64];
			//GetClientName(target, clientname, sizeof(clientname));
			//ExecCheatCommand(-1, "sm_slap", clientname);
		}
		else if (StrEqual(Effects, "t")) CreateAcid(activator, target, 512.0);
		else if (StrEqual(Effects, "T")) HealPlayer(target, activator, iDamage * 1.0, 'T');
		else if (StrEqual(Effects, "z")) ZeroGravity(activator, target, g_TalentStrength, g_TalentTime);
		else if (StrEqual(Effects, "revive")) ReviveDownedSurvivor(target);
	}
}

stock int GiveAmmoBack(int client, int rawToReturn = 1, float percentageToReturn = 0.0, int activator = 0) {
	if (activator == 0) activator = client;
	int reserveCap = GetWeaponResult(client, 2);
	int reserveRemaining = GetWeaponResult(client, 3);
	int returnAmount = rawToReturn;
	if (percentageToReturn > 0.0) {
		returnAmount = RoundToCeil(reserveCap * percentageToReturn);
	}
	if (reserveRemaining == reserveCap) return 0;
	if (reserveRemaining + returnAmount > reserveCap) returnAmount = reserveCap - reserveRemaining;
	if (activator != client) AwardExperience(activator, 2, returnAmount);
	return GetWeaponResult(client, 4, returnAmount);
}

stock bool GetResultByVScript(int client, char[] scriptCallByRef, bool printResults = false) {
	int entity = CreateEntityByName("logic_script");
	if (entity >= 0) {
		DispatchSpawn(entity);
		char text[96];
		Format(text, sizeof(text), "Convars.SetValue(\"sm_vscript_res\", \"\" + %s + \"\");", scriptCallByRef);
		SetVariantString(text);
		AcceptEntityInput(entity, "RunScriptCode");
		AcceptEntityInput(entity, "Kill");
		staggerBuffer.GetString(text, sizeof(text));
		staggerBuffer.SetString("");
		if (StrEqual(text, "true", false)) return true;
	}
	return false;
}

stock bool IsCoveredInBile(int client) {
	if (!IsLegitimateClient(client)) return false;
	return (ISBILED[client]) ? true : false;
}

stock bool IsStaggered(int client) {
	if (!IsLegitimateClient(client)) {
		// if the client is not a player client
		if (!IsCommonStaggered(client)) return false;
		return true;
	}
	if (SDKCall(g_hIsStaggering, client)) return true;
	return false;
}

public Action Timer_RemoveBileStatus(Handle timer, any client) {
	if (IsLegitimateClient(client)) ISBILED[client] = false;
	return Plugin_Stop;
}
/*void StaggerClient(int userid, const float vPos[3])
{
	int iScriptLogic = INVALID_ENT_REFERENCE;
	if(iScriptLogic == INVALID_ENT_REFERENCE || !IsValidEntity(iScriptLogic))
	{
		iScriptLogic = EntIndexToEntRef(CreateEntityByName("logic_script"));
		if(iScriptLogic == INVALID_ENT_REFERENCE || !IsValidEntity(iScriptLogic))
			LogError("Could not create 'logic_script");

		DispatchSpawn(iScriptLogic);
	}

	char sBuffer[96];
	Format(sBuffer, sizeof(sBuffer), "GetPlayerFromUserID(%d).Stagger(Vector(%d,%d,%d))", userid, RoundFloat(vPos[0]), RoundFloat(vPos[1]), RoundFloat(vPos[2]));
	SetVariantString(sBuffer);
	AcceptEntityInput(iScriptLogic, "RunScriptCode");
	RemoveEntity(iScriptLogic);
}*/

stock void StaggerPlayer(int target, int activator) {
	float pos[3];
	GetEntPropVector(target, Prop_Send, "m_vecOrigin", pos);

	char text[96];
	int ent = CreateEntityByName("logic_script");
	if (ent >= 0) {
		DispatchSpawn(ent);
		Format(text, sizeof(text), "GetPlayerFromUserID(%d).Stagger(Vector(%d,%d,%d))", activator, RoundFloat(pos[0]), RoundFloat(pos[1]), RoundFloat(pos[2]));
		SetVariantString(text);
		AcceptEntityInput(ent, "RunScriptCode");
		AcceptEntityInput(ent, "Kill");
		//PrintToChatAll("%s", text);

		EntityWasStaggered(target, activator);
	}
}

// Eyal282 here. Warnings are evil.
/*
stock float GetMagazineRemaining(int client, bool bIsPercentage = false) {

}
*/

/*new client = GetClientOfUserId(event.GetInt("userid"));
	new weaponIndex = GetPlayerWeaponSlot(client, 0);
	
	if(weaponIndex == -1)
		return Plugin_Continue;
	
	new String:classname[64];
	
	GetEdictClassname(weaponIndex, classname, sizeof(classname));
	
	if(StrEqual(classname, "weapon_rifle_m60") || StrEqual(classname, "weapon_grenade_launcher"))
	{
		new iClip1 = GetEntProp(weaponIndex, Prop_Send, "m_iClip1");
		new iPrimType = GetEntProp(weaponIndex, Prop_Send, "m_iPrimaryAmmoType");
		
		if(StrEqual(classname, "weapon_rifle_m60"))
		{
			SetEntProp(client, Prop_Send, "m_iAmmo", ((hM60Ammo.IntValue+150)-iClip1), _, iPrimType);
		}
		else
		{
			SetEntProp(client, Prop_Send, "m_iAmmo", ((hGLAmmo.IntValue+1)-iClip1), _, iPrimType);
		}
		return Plugin_Handled;
	}
	return Plugin_Continue;


stock bool:CanIReloadTheM60(int client) {

	new PlayerWeapon = GetPlayerWeaponSlot(client, 0);
	if (IsValidEntity(PlayerWeapon)) {

		decl String:Classname[64];
		GetEdictClassname(PlayerWeapon, Classname, sizeof(Classname));
		if (StrContains(Classname, "m60", false) != -1) {

			new PlayerAmmo = GetEntProp(PlayerWeapon, Prop_Send, "m_iClip1", 1);
			if (PlayerAmmo < 150) return true;
		}
	}
	return false;
}

stock ReturnClipOnReload(client, activator = -1) {

	if (activator == -1 || !IsLegitimateClient(activator)) activator = client;
	new PlayerWeapon = GetPlayerWeaponSlot(client, 0);	// we only refill primary ammo
	if (!IsValidEntity(PlayerWeapon)) return 0;
	decl String:Classname[64];
	GetEdictClassname(PlayerWeapon, Classname, sizeof(Classname));

	new PlayerAmmo	= GetEntProp(PlayerWeapon, Prop_Send, "m_iClip1", 1);
	new AmmoType	= GetEntProp(PlayerWeapon, Prop_Send, "m_iPrimaryAmmoType");

	if (StrContains(Classname, "m60", false) != -1) {	// the m60 doesn't have reserve ammo, so we call this differently for the m60

		SetEntProp(PlayerWeapon, Prop_Send, "m_iAmmo", 300 - PlayerAmmo);
	}
	else if (StrContains(Classname, "launcher", false) != -1) {

	}
	else {

	}
	return 1;
}*/

stock void RestoreHealBullet(int client, int bulletsRestored = 1) {

	if (!IsMeleeAttacker(client)) {

		int WeaponSlot = GetActiveWeaponSlot(client);
		int PlayerWeapon = GetPlayerWeaponSlot(client, WeaponSlot);
		if (PlayerWeapon < 0 || !IsValidEntity(PlayerWeapon)) return;
		int bullets = GetEntProp(PlayerWeapon, Prop_Send, "m_iClip1", 1);
		if (bullets + bulletsRestored < 200) SetEntProp(PlayerWeapon, Prop_Send, "m_iClip1", bullets + bulletsRestored);
		else SetEntProp(PlayerWeapon, Prop_Send, "m_iClip1", 200);
	}
}

stock void ModifyPlayerAmmo(int target, float g_TalentStrength) {

	int PlayerWeapon = GetPlayerWeaponSlot(target, 0);
	if (!IsValidEntity(PlayerWeapon)) return;

	int PlayerAmmo = GetEntProp(PlayerWeapon, Prop_Send, "m_iClip1", 1);
	//new PlayerMaxAmmo = GetEntProp(PlayerWeapon, Prop_Send, "m_iMaxClip1", 1);
	int PlayerAmmoAward = RoundToCeil(g_TalentStrength * PlayerAmmo);
	PlayerAmmoAward = GetRandomInt(1, PlayerAmmoAward);

	/*

		If the players clip reaches the max, it resets to the default.
	*/
	//new PlayerMaxIncrease = PlayerMaxAmmo + RoundToCeil(PlayerMaxAmmo * g_TalentStrength);
	SetEntProp(PlayerWeapon, Prop_Send, "m_iClip1", PlayerAmmo + PlayerAmmoAward, 1);

	//if (PlayerAmmo + PlayerAmmoAward >= PlayerMaxIncrease) SetEntProp(PlayerWeapon, Prop_Send, "m_iClip1", PlayerMaxAmmo, 1);
}

stock bool RestrictedWeaponList(char[] WeaponName) {	// Some weapons might be insanely powerful, so we see if they're in this string and don't let them damage multiplier if they are.

	if (StrContains(RestrictedWeapons, WeaponName, false) != -1) return true;
	return false;
}

stock void ConfirmExperienceAction(int client, bool TheRoundHasEnded = false, bool IsAllowLevelUp = false) {

	if (!IsLegitimateClient(client)) return;

	int ExperienceRequirement = CheckExperienceRequirement(client, _, PlayerLevel[client]);

	if (iIsLevelingPaused[client] == 1) {

		if (ExperienceLevel[client] > ExperienceRequirement) {

			ExperienceOverall[client] -= (ExperienceLevel[client] - ExperienceRequirement);
			ExperienceLevel[client] = ExperienceRequirement;
		}
	}
	if (ExperienceLevel[client] >= ExperienceRequirement && PlayerLevel[client] < iMaxLevel && (iIsLevelingPaused[client] == 0 || IsAllowLevelUp)) {

		char Name[64];
		GetClientName(client, Name, sizeof(Name));
		//else GetSurvivorBotName(client, Name, sizeof(Name));
		int count = 0;
		int MaxLevel = iMaxLevel;

		while (ExperienceLevel[client] >= ExperienceRequirement) {
			ExperienceLevel[client] -= ExperienceRequirement;
			if (PlayerLevel[client] + count <= MaxLevel)	count++;
			if (PlayerLevel[client] + count < MaxLevel) {

				ExperienceRequirement		= CheckExperienceRequirement(client, _, PlayerLevel[client] + count);
			}
			else {

				//ExperienceLevel[client]		= 1;
				ExperienceRequirement		= CheckExperienceRequirement(client, _, MaxLevel);
			}
		}
		if (ExperienceLevel[client] < 1) ExperienceLevel[client] = 1;
		if (count >= 1) {

			if (count > 0) {

				if (PlayerLevel[client] < MaxLevel) {

					PlayerLevel[client] += count;
					UpgradesAwarded[client] += count;
					UpgradesAvailable[client] += count;
					TotalTalentPoints[client] += count;
					if (!IsFakeClient(client)) PrintToChat(client, "%T", "upgrade awarded", client, white, green, orange, white, count);
					PlayerLevelUpgrades[client] = 0;
				}

				if (count == 1) PrintToChatAll("%t", "player level up", green, white, green, Name, PlayerLevel[client]);
				else {
					char formattedLevel[64];
					AddCommasToString(PlayerLevel[client], formattedLevel, sizeof(formattedLevel));
					PrintToChatAll("%t", "player multiple level up", blue, Name, white, green, count, white, blue, formattedLevel);
				}
			}
			else {

				// experience resets & cartel are awarded, but no level if at cap

				//ExperienceLevel[client] = 1;
			}
			// Whenever a player levels, we also level up talents that have earned enough experience for at least 1 point gain.
			ConfirmExperienceActionTalents(client, _, TheRoundHasEnded);

			bIsSettingsCheck = true;
		}
	}
}

stock void ConfirmExperienceActionTalents(int client, bool WipeXP = false, bool TheRoundHasEnded = false) {

	if (!IsLegitimateClient(client)) return;

	int size = a_Menu_Talents.Length;
	char text[64];
	char text2[64];
	char Name[64];

	GetClientName(client, Name, sizeof(Name));
	//else GetSurvivorBotName(client, Name, sizeof(Name));
	int count = 0;
	int talentlevel = 0;
	int ExperienceValue = 0;
	int ExperienceRequirement = 0;

	/*if (WipeXP) {
	
		new WipedExperience = RoundToCeil(ExperienceLevel[client] * fDeathPenalty);
		if (WipedExperience > 1) {

			ExperienceOverall[client] -= WipedExperience;
			ExperienceLevel[client] -= WipedExperience;

			if (!IsFakeClient(client)) PrintToChat(client, "%T", "groupmate death penalty", client, blue, orange, green, AddCommasToString(WipedExperience), blue);
			// a member of your group has died!
			// you have lost x experience!
		}
	}*/

	for (int i = 0; i < size; i++) {

		//TalentActionKeys[client]		= a_Menu_Talents.Get(i, 0);
		TalentActionValues[client]		= a_Menu_Talents.Get(i, 1);

		if (GetKeyValueIntAtPos(TalentActionValues[client], IS_SUB_MENU_OF_TALENTCONFIG) == 1) continue;
		if (GetKeyValueIntAtPos(TalentActionValues[client], IS_TALENT_TYPE) <= 0) continue;

		ExperienceValue = a_Database_PlayerTalents_Experience[client].Get(i);

		if (WipeXP) {

			ExperienceValue -= RoundToCeil(ExperienceValue * fDeathPenalty);	//	 ExperienceValue = 0;
			if (ExperienceValue < 0) ExperienceValue = 0;
		}
		else {

			TalentActionSection[client]		= a_Menu_Talents.Get(i, 2);

			//a_Database_PlayerTalents_Experience[client].GetString(i, text, sizeof(text));
			//a_Database_PlayerTalents[client].GetString(i, text2, sizeof(text2));
			talentlevel = a_Database_PlayerTalents[client].Get(i);
			//ExperienceValue = a_Database_PlayerTalents_Experience[client].Get(i);
			TalentActionSection[client].GetString(0, text, sizeof(text));

			ExperienceRequirement		= CheckExperienceRequirementTalents(client, text, talentlevel, i);
			
			//while ((PlayerLevel[client] >= iMaxLevel || talentlevel + count < PlayerLevel[client]) && ExperienceValue >= ExperienceRequirement) {
			while (ExperienceValue >= ExperienceRequirement) {

				ExperienceValue -= ExperienceRequirement;
				count++;
				ExperienceRequirement	= CheckExperienceRequirementTalents(client, text, talentlevel + count, i);
			}
			if (count < 1) continue;	// no level-ups
			for (int ii = 1; ii <= MaxClients; ii++) {

				if (!IsLegitimateClient(ii) || IsFakeClient(ii)) continue;
				Format(text2, sizeof(text2), "%T", text, ii);
				PrintToChat(ii, "%T", "talent level up", ii, blue, Name, white, green, count, white, orange, text2);	//{1}{2} {3}has gained {4}{5} {6}points of {7}{8}
			}
			a_Database_PlayerTalents[client].Set(i, talentlevel + count);
		}
		a_Database_PlayerTalents_Experience[client].Set(i, ExperienceValue);
		count = 0;
	}
	// if wiping experience, we are also killing the survivor. class data auto-saves when a round ends, when player data saves.
	// to prevent a redundant save, when a player dies, we check that there are other survivors still alive before saving their data.
	//if (!TheRoundHasEnded && (!WipeXP || LivingSurvivorCount(client) > 0)) SaveClassData(client);
}

stock void AddTalentExperience(int client, char[] TalentName, int ExperienceAmount, int posover = -1) {

	if (b_IsLoading[client]) return;

	int pos = posover;
	if (posover == -1) pos = GetTalentPosition(client, TalentName);
	if (pos == -1) return;
	int size = a_Menu_Talents.Length;
	if (a_Database_PlayerTalents[client].Length != size) {

		a_Database_PlayerTalents[client].Resize(size);
		PlayerAbilitiesCooldown[client].Resize(size);
		a_Database_PlayerTalents_Experience[client].Resize(size);
		return;
		//for (new i = 1; i <= MAXPLAYERS; i++) PlayerAbilitiesImmune[client][i].Resize(size);
	}
	//if (GetTalentLevel(client, TalentName) < PlayerLevel[client] || PlayerLevel[client] >= iMaxLevel) a_Database_PlayerTalents_Experience[client].Set(pos, a_Database_PlayerTalents_Experience[client].Get(pos) + ExperienceAmount);
	//if (PlayerLevel[client] < iMaxLevel)
	a_Database_PlayerTalents_Experience[client].Set(pos, a_Database_PlayerTalents_Experience[client].Get(pos) + ExperienceAmount);
	//else a_Database_PlayerTalents_Experience[client].Set(pos, 0);
}

stock int CheckExperienceRequirementTalents(int client, char[] TalentName, int iLevel = 0, int posover = -1) {

	if (!IsLegitimateClient(client)) return 0;
	int pos = posover;
	if (posover == -1) pos = GetTalentPosition(client, TalentName);

	int TalentLevel = 0;
	float RequirementMultiplier = 0.0;
	int RequirementStart = 0;

	//TalentExperienceKeys[client]		= a_Menu_Talents.Get(pos, 0);
	TalentExperienceValues[client]		= a_Menu_Talents.Get(pos, 1);

	if (GetKeyValueIntAtPos(TalentExperienceValues[client], IS_SUB_MENU_OF_TALENTCONFIG) == 1) return -1;
	if (GetKeyValueIntAtPos(TalentExperienceValues[client], IS_TALENT_TYPE) <= 0) return -1;	// incompatible talent.

	RequirementStart = GetKeyValueIntAtPos(TalentExperienceValues[client], OLD_ATTRIBUTE_EXPERIENCE_START);
	RequirementMultiplier = GetKeyValueFloatAtPos(TalentExperienceValues[client], OLD_ATTRIBUTE_EXPERIENCE_MULTIPLIER);
	TalentLevel = a_Database_PlayerTalents[client].Get(pos);

	if (iLevel == 0) RequirementMultiplier		= RequirementMultiplier * (TalentLevel - 1);
	else RequirementMultiplier					= RequirementMultiplier * (iLevel - 1);

	if (TalentLevel > 0) RequirementStart						+= RoundToCeil(RequirementStart * RequirementMultiplier);

	return RequirementStart;

}

/*
	return types:
	0 - level	1 - experience	2 - experience requirement
*/
stock int GetProficiencyData(int client, int proficiencyType = 0, int iExperienceEarned = 0, int iReturnType = 0, bool bGetLevel = false) {
	int proficiencyExperience = pistolXP[client];
	if (proficiencyType == 1) proficiencyExperience = meleeXP[client];
	else if (proficiencyType == 2) proficiencyExperience = uziXP[client];
	else if (proficiencyType == 3) proficiencyExperience = shotgunXP[client];
	else if (proficiencyType == 4) proficiencyExperience = sniperXP[client];
	else if (proficiencyType == 5) proficiencyExperience = assaultXP[client];
	else if (proficiencyType == 6) proficiencyExperience = medicXP[client];
	else if (proficiencyType == 7) proficiencyExperience = grenadeXP[client];

	//PrintToChat(client, "%d %d", proficiencyType, iExperienceEarned);

	/*
		get current level
	*/
	int curLevel = 1;
	if (!bGetLevel) curLevel = GetProficiencyData(client, proficiencyType, _, _, true);
	proficiencyExperience += iExperienceEarned;	// else not necessary as we are passing 0 for iExperienceEarned in curLevel

	int proficiencyLevel = 0;
	int experienceRequirement = iProficiencyStart;
	//new Float:experienceMultiplier = 0.0;
	while (proficiencyExperience >= experienceRequirement) {
		proficiencyExperience -= experienceRequirement;
		proficiencyLevel++;
		experienceRequirement = iProficiencyStart + RoundToCeil(iProficiencyStart * (fProficiencyExperienceMultiplier * proficiencyLevel));
	}
	if (bGetLevel) return proficiencyLevel;
	if (iReturnType == 1) return proficiencyExperience;
	if (iReturnType == 2) return experienceRequirement;
	if (iExperienceEarned > 0) {		
		if (proficiencyType == 0) pistolXP[client] += iExperienceEarned;
		else if (proficiencyType == 1) meleeXP[client] += iExperienceEarned;
		else if (proficiencyType == 2) uziXP[client] += iExperienceEarned;
		else if (proficiencyType == 3) shotgunXP[client] += iExperienceEarned;
		else if (proficiencyType == 4) sniperXP[client] += iExperienceEarned;
		else if (proficiencyType == 5) assaultXP[client] += iExperienceEarned;
		else if (proficiencyType == 6) medicXP[client] += iExperienceEarned;
		else if (proficiencyType == 7) grenadeXP[client] += iExperienceEarned;
	}
	if (curLevel < proficiencyLevel) {
		char proficiencyName[64];
		char playerName[64];
		GetClientName(client, playerName, sizeof(playerName));
		if (proficiencyType == 0) Format(proficiencyName, sizeof(proficiencyName), "%t", "pistol proficiency up");
		else if (proficiencyType == 1) Format(proficiencyName, sizeof(proficiencyName), "%t", "melee proficiency up");
		else if (proficiencyType == 2) Format(proficiencyName, sizeof(proficiencyName), "%t", "uzi proficiency up");
		else if (proficiencyType == 3) Format(proficiencyName, sizeof(proficiencyName), "%t", "shotgun proficiency up");
		else if (proficiencyType == 4) Format(proficiencyName, sizeof(proficiencyName), "%t", "sniper proficiency up");
		else if (proficiencyType == 5) Format(proficiencyName, sizeof(proficiencyName), "%t", "assault proficiency up");
		else if (proficiencyType == 6) Format(proficiencyName, sizeof(proficiencyName), "%t", "medic proficiency up");
		else if (proficiencyType == 7) Format(proficiencyName, sizeof(proficiencyName), "%t", "grenade proficiency up");
		PrintToChatAll("%t", "proficiency level up", blue, playerName, white, orange, proficiencyName, white, blue, proficiencyLevel);
	}
	return curLevel;
}

stock int CheckExperienceRequirement(int client, bool bot = false, int iLevel = 0) {

	int experienceRequirement = 0;
	if (IsLegitimateClient(client)) {

		experienceRequirement			=	iExperienceStart;
		float experienceMultiplier	=	0.0;

		if (iLevel == 0) experienceMultiplier		=	fExperienceMultiplier * (PlayerLevel[client] - 1);
		else experienceMultiplier 					=	fExperienceMultiplier * (iLevel - 1);

		experienceRequirement			=	iExperienceStart + RoundToCeil(iExperienceStart * experienceMultiplier);
	}

	return experienceRequirement;
}

/*stock StrengthValue(int client) {

	if (GetRandomInt(1, 100) <= Luck[client]) return GetRandomInt(0, Strength[client]);
	return 0;
}*/

/*stock bool:IsAbilityImmune(owner, client, char[] TalentName[]) {

	if (IsLegitimateClient(client)) {

		new a_Size				=	0;
		if (!IsFakeClient(client)) a_Size					=	a_Database_PlayerTalents[client].Length;
		else a_Size											=	a_Database_PlayerTalents_Bots.Length;

		decl String:Name[PLATFORM_MAX_PATH];

		for (new i = 0; i < a_Size; i++) {

			Handle a_Database_Talents.GetString(i, Name, sizeof(Name));
			if (StrEqual(Name, TalentName)) {

				decl String:t_Cooldown[8];
				Handle PlayerAbilitiesImmune[owner][client].GetString(i, t_Cooldown, sizeof(t_Cooldown));

				//if (!IsFakeClient(client)) Handle PlayerAbilitiesImmune[client].GetString(i, t_Cooldown, sizeof(t_Cooldown));
				//else Handle PlayerAbilitiesImmune_Bots.GetString(i, t_Cooldown, sizeof(t_Cooldown));
				if (StrEqual(t_Cooldown, "1")) return true;
				break;
			}
		}
	}
	return false;
}*/

stock bool SurvivorsBiled() {
	for (int i = 1; i <= MaxClients; i++) {
		if (IsLegitimateClientAlive(i) && GetClientTeam(i) == TEAM_SURVIVOR && IsCoveredInBile(i)) return true;
	}
	return false;
}

stock int SuperCommonsInPlay(char[] Name) {

	int size = CommonAffixes.Length;
	char text[64];
	int count = 0;
	int ent = -1;
	for (int i = 0; i < size; i++) {
		ent = CommonAffixes.Get(i); //Handle CommonAffixes.GetString(i, text, sizeof(text));
		if (IsValidEntity(ent)) {
			GetEntPropString(ent, Prop_Data, "m_iName", text, sizeof(text));
			if (StrEqual(text, Name)) count++;
		}
	}
	return count;
}

/*

	This function is called when a common infected is spawned, and attempts to roll for affixes.
*/
stock int CreateCommonAffix(int entity) {
	int size = a_CommonAffixes.Length;
	if (CommonAffixes.Length >= GetSuperCommonLimit()) return 0;	// there's a maximum limit on the # of super commons.
	float RollChance = 0.0;
	char Section_Name[64];
	char AuraEffectCCA[55];
	char ForceName[64];
	char Model[64];
	Format(ForceName, sizeof(ForceName), "none");
	if (SuperCommonQueue.Length > 0) {
		SuperCommonQueue.GetString(0, ForceName, sizeof(ForceName));
		SuperCommonQueue.Erase(0);
	}
	int maxallowed = 1;
	//decl String:iglowColour[3][4];
	//decl String:glowColour[10];
	float ModelSize = 1.0;
	bool SurvivorsAreBiled = SurvivorsBiled();
	for (int i = 0; i < size; i++) {
		CCAKeys				= a_CommonAffixes.Get(i, 0);
		CCAValues			= a_CommonAffixes.Get(i, 1);
		//if (AfxSection.Length < 1 || AfxKeys.Length < 1) continue;
		if (GetKeyValueIntAtPos(CCAValues, SUPER_COMMON_REQ_BILED_SURVIVORS) == 1 && !SurvivorsAreBiled) continue;
		maxallowed = GetKeyValueIntAtPos(CCAValues, SUPER_COMMON_MAX_ALLOWED);
		if (maxallowed < 0) maxallowed = 1;
		if (SuperCommonsInPlay(Section_Name) >= maxallowed) continue;
		RollChance = GetKeyValueFloatAtPos(CCAValues, SUPER_COMMON_SPAWN_CHANCE);
		if (StrEqual(ForceName, "none", false) && GetRandomInt(1, RoundToCeil(1.0 / RollChance)) > 1) continue;		// == 1 for successful roll
		CCASection			= a_CommonAffixes.Get(i, 2);
		CCASection.GetString(0, Section_Name, sizeof(Section_Name));
		if (!StrEqual(ForceName, "none", false) && !StrEqual(Section_Name, ForceName, false)) continue;
		SetEntPropString(entity, Prop_Data, "m_iName", Section_Name);
		CommonAffixes.Push(entity);
		OnCommonCreated(entity);
		//	Now that we've confirmed this common is special, let's go ahead and activate pertinent functions...
		//	Doing some of these, repeatedly, in a timer is a) wasteful and b) crashy. I know, from experience.
		CCAValues.GetString(SUPER_COMMON_AURA_EFFECT, AuraEffectCCA, sizeof(AuraEffectCCA));
		//FormatKeyValue(AuraEffectCCA, sizeof(AuraEffectCCA), CCAKeys, CCAValues, "aura effect?");
		if (StrEqual(AuraEffectCCA, "f", true)) CreateAndAttachFlame(entity, _, _, _, _, "burn");
		ModelSize = GetKeyValueFloatAtPos(CCAValues, SUPER_COMMON_MODEL_SIZE);
		if (ModelSize > 0.0) SetEntPropFloat(entity, Prop_Send, "m_flModelScale", ModelSize);
		CCAValues.GetString(SUPER_COMMON_FORCE_MODEL, Model, sizeof(Model));
		//FormatKeyValue(Model, sizeof(Model), CCAKeys, CCAValues, "force model?");
		if (IsModelPrecached(Model)) SetEntityModel(entity, Model);
		else if (CommonInfectedQueue.Length > 0) {
			CommonInfectedQueue.GetString(0, Model, sizeof(Model));
			if (IsModelPrecached(Model)) SetEntityModel(entity, Model);
			CommonInfectedQueue.Erase(0);
		}
		return 1;		// we only create one affix on a common. maybe we'll allow more down the road.
	}
	return 0;
	// If no special common affix was successful, it's a standard common.

	//Handle AfxSection.Clear();
	//Handle AfxKeys.Clear();
	//Handle AfxValues.Clear();
	//LogMessage("This common remains normal... %d", entity);
}

stock void RemoveAllDebuffs(int client, char[] debuffName) {
	int size = EntityOnFire.Length;
	char text[64];
	for (int i = 0; i < size; i++) {
		if (client != EntityOnFire.Get(i, 0)) continue;	// client isn't the client owning this debuff
		EntityOnFireName.GetString(i, text, sizeof(text));
		if (!StrEqual(debuffName, text)) continue;
		EntityOnFireName.Erase(i);
		EntityOnFire.Erase(i);
		size--;
		if (i > 0) i--;
	}
}

/*

		2nd / 3rd args have defaults for use with special common infected.
		When these special commons explode, they can apply custom versions of these flames to players
		and the plugin will check every so often to see if a player has such an entity attached to them.
		If they do, they'll burn. Players can have multiple of these, so it is dangerous.
*/
stock void CreateAndAttachFlame(int client, int damage = 0, float lifetime = 10.0, float tickInt = 1.0, int owner = -1, char[] DebuffName = "burn", float tickIntContinued = -2.0) {
	if (IsSurvivalMode && IsCommonInfected(client)) {
		OnCommonInfectedCreated(client, true);
		return;
	}
	float TheAbilityMultiplier = GetAbilityMultiplier(client, "B");
	if (TheAbilityMultiplier > 0.0) damage += RoundToCeil(damage * TheAbilityMultiplier);
	if (tickIntContinued <= 0.0) tickIntContinued = tickInt;
	/* old code:
	Format(t_EntityOnFire, sizeof(t_EntityOnFire), "%d+%d+%3.2f+%3.2f+%3.2f+%s+%s", client, damage, lifetime, tickInt, tickIntContinued, SteamID, DebuffName);
	Handle EntityOnFire.PushString(t_EntityOnFire);*/
	int size = EntityOnFire.Length;
	EntityOnFire.Resize(size + 1);	// we're going to add to the top.
	EntityOnFire.Set(size, client, 0);	// structured by blocks (3d array list)
	EntityOnFire.Set(size, damage, 1);
	EntityOnFire.Set(size, lifetime, 2);
	EntityOnFire.Set(size, tickInt, 3);
	EntityOnFire.Set(size, tickIntContinued, 4);
	EntityOnFire.Set(size, owner, 5);
	EntityOnFireName.Resize(size + 1);	// strings need to be stored in a separate list.
	EntityOnFireName.SetString(size, DebuffName);
	//bNoNewFireDebuff[client] = false;
	DebuffOnCooldown(client, DebuffName, true); // using an array so we can store all the cooldowns in one place. this removes the cooldown.
	if (StrEqual(DebuffName, "burn", false)) {

		if (IsLegitimateClient(client)) {
			//if (FindZombieClass(client) == ZOMBIECLASS_TANK) LogMessage("CreateAndAttachFlame() on tank");
			IgniteEntity(client, lifetime);
		}
	}
	//if (StrEqual(DebuffName, "acid", false) && (IsLegitimateClient(client) || damage == 0 && IsCommonInfected(client))) CreateAcid(FindInfectedClient(true), client, 48.0);
	if (damage == 0 && StrEqual(DebuffName, "acid", false) && IsCommonInfected(client)) CreateAcid(FindInfectedClient(true), client, 48.0);
	//}
}

/*stock TransferStatusEffect(client, target) {

	new size = Handle EntityOnFire.Length;
	decl String:Evaluate[7][64];
	decl String:Value[64];
	decl String:ClientS[512];
	decl String:TargetS[64];
	decl String:TheName[64];
	if (IsSurvivorBot(client)) {

		GetSurvivorBotName(client, TheName, sizeof(TheName));
		Format(ClientS, sizeof(ClientS), "%s%s", sBotTeam, TheName);
	}
	else {

		if (IsLegitimateClient(client) && GetClientTeam(client) == TEAM_SURVIVOR) GetClientAuthString(client, ClientS, sizeof(ClientS));
		else Format(ClientS, sizeof(ClientS), "%d", client);
	}
	if (IsSurvivorBot(target)) {

		GetSurvivorBotName(target, TheName, sizeof(TheName));
		Format(TargetS, sizeof(TargetS), "%s%s", sBotTeam, TheName);
	}
	else {

		GetClientAuthString(target, TargetS, sizeof(TargetS));
	}
	for (new i = 0; i < size; i++) {

		Handle EntityOnFire.GetString(i, Value, sizeof(Value));
		ExplodeString(Value, "+", Evaluate, 7, 64);

		if (StrEqual(ClientS, Evaluate[5], false)) {

			//CreateAndAttachFlame(target, StringToInt(Evaluate[1]), StringToFloat(Evaluate[2]), StringToFloat(Evaluate[3]), -2, Evaluate[6], StringToFloat(Evaluate[4]));	//owner as -2 indicates cleansing debuff.
			CleansingContribution[target] += StringToInt(Evaluate[1]);
			Handle EntityOnFire.Erase(i);
			return;
		}
	}
}*/

stock int RemoveClientStatusEffect(int client, char[] EffectName = "all") {
	char text[64];
	if (!IsLegitimateClient(client)) return 0;
	for (int i = 0; i < EntityOnFire.Length; i++) {
		if (EntityOnFire.Get(i, 0) != client) continue;
		if (!StrEqual(EffectName, "all")) {
			EntityOnFireName.GetString(i, text, sizeof(text));
			if (!StrEqual(EffectName, text)) continue;
		}
		EntityOnFire.Erase(i);
		EntityOnFireName.Erase(i);
		return 1;
	}
	return 0;
}

stock int GetClientStatusEffect(int client, char[] EffectName = "burn") {
	int Count = 0;
	char TalentName[64];
	if (!IsLegitimateClient(client) || IsFakeClient(client)) return 0;
	for (int i = 0; i < EntityOnFire.Length; i++) {
		if (EntityOnFire.Get(i, 0) != client) continue;
		EntityOnFireName.GetString(i, TalentName, sizeof(TalentName));
		if (!StrEqual(EffectName, TalentName)) continue;
		Count++;
	}
	return Count;
}

/*stock bool:IsClientStatusEffect(client, bool:RemoveIt=false, String:EffectName[] = "burn") {
	decl char[] TalentName[64];
	new targetClient = -1;
	if (!IsLegitimateClient(client) || IsFakeClient(client)) return false;	// survivor bots can't be affected by status effects for balance purposes.

	for (new i = 0; i < Handle EntityOnFire.Length; i++) {
		targetClient = EntityOnFire.Get(i, 5);
		if (client != targetClient) continue;
		EntityOnFireName.GetString(i, TalentName, sizeof(TalentName));
		if (!StrEqual(EffectName, TalentName)) continue;
		if (RemoveIt) {
			Handle EntityOnFire.Erase(i);
			EntityOnFireName.Erase(i);
		}
		return true;
	}
	return false;
}*/

stock void ClearRelevantData() {

	for (int i = 1; i <= MaxClients; i++) {

		if (!IsClientActual(i) || !IsClientInGame(i)) continue;
		ResetOtherData(i);
	}
	//Handle WitchList.Clear();
}

stock void WipeDebuffs(bool IsEndOfCampaign = false, int client = -1, bool IsDisconnect = false) {

	if (client == -1) {

		ResetArray(CommonInfected);
		ResetArray(WitchList);
		ResetArray(CommonList);

		if (IsEndOfCampaign) {

			EntityOnFire.Clear();
			CommonInfectedQueue.Clear();
			CommonList.Clear();
			Points_Director = 0.0;

			for (int i = 1; i <= MaxClients; i++) {

				if (IsLegitimateClient(i)) Points[i] = 0.0;
			}
		}
	}
	else {

		b_HardcoreMode[client] = false;
		ResetCDImmunity(client);
		EnrageBlind(client, 0);

		if (IsDisconnect) {

			CleanseStack[client] = 0;
			CounterStack[client] = 0.0;
			MultiplierStack[client] = 0;
			Format(BuildingStack[client], sizeof(BuildingStack[]), "none");

			Points[client] = 0.0;
		}
		b_IsFloating[client] = false;
		if (b_IsActiveRound) {
			b_IsInSaferoom[client] = false;
			bIsInCheckpoint[client] = false;
		}
		else {
			b_IsInSaferoom[client] = true;
			bIsInCheckpoint[client] = true;
		}
		b_IsBlind[client]				= false;
		b_IsImmune[client]				= false;
		b_IsJumping[client]				= false;
		CommonKills[client]				= 0;
		CommonKillsHeadshot[client]		= 0;
		bIsMeleeCooldown[client]			= false;
		shotgunCooldown[client]			= false;
		AmmoTriggerCooldown[client] = false;
		ExplosionCounter[client][0] = 0.0;
		ExplosionCounter[client][1] = 0.0;
		HealingContribution[client] = 0;
		TankingContribution[client] = 0;
		DamageContribution[client] = 0;
		PointsContribution[client] = 0.0;
		HexingContribution[client] = 0;
		BuffingContribution[client] = 0;
		CleansingContribution[client] = 0;
		//if (HandicapLevel[client] < 1) HandicapLevel[client] = -1;
		if (PlayerHasWeakness(client)) bHasWeakness[client] = false;
		bIsHandicapLocked[client] = false;
		WipeDamageContribution(client);
	}
}

/*public Action:Timer_QuickscopeCheck(Handle timer) {
	if (!b_IsActiveRound) {
		quickscopeCheck.Clear();
		return Plugin_Stop;
	}
	// format is %d:time for client id, time activated.

}*/

public Action Timer_EntityOnFire(Handle timer) {
	if (!b_IsActiveRound) {
		return Plugin_Stop;
	}
	static int Client = 0;
	static int damage = 0;
	static int Owner = 0;
	float FlTime = 0.0;
	float TickInt = 0.0;
	float TickIntOriginal = 0.0;
	static int t_Damage = 0;
	//decl String:t_Delim[2][64];
	char ModelName[64];
	static int DamageShield = 0;
	char TalentName[64];
	bool IsClientAlive = false;
	for (int i = 0; i < EntityOnFire.Length; i++) {
		Client = EntityOnFire.Get(i, 0);
		IsClientAlive = IsLegitimateClientAlive(Client);
		if (!IsCommonInfected(Client) && !IsWitch(Client) && !IsClientAlive) {
			EntityOnFire.Erase(i);
			EntityOnFireName.Erase(i);
			continue;
		}
		if ((GetEntityFlags(Client) & FL_INWATER)) {
			ExtinguishEntity(Client);
			EntityOnFire.Erase(i);
			EntityOnFireName.Erase(i);
			continue;
		}
		EntityOnFireName.GetString(i, TalentName, sizeof(TalentName));
		damage = EntityOnFire.Get(i, 1);
		FlTime = EntityOnFire.Get(i, 2);
		TickInt = EntityOnFire.Get(i, 3);
		TickIntOriginal = EntityOnFire.Get(i, 4);
		Owner = EntityOnFire.Get(i, 5);
		if (Owner != -1) Owner = FindClientByIdNumber(Owner);
		if (TickInt - 0.5 <= 0.0) {
			TickInt = TickIntOriginal;
			t_Damage = RoundToCeil(damage / (FlTime / TickInt));
			//damage -= t_Damage;
			// HERE WE FIND OUT IF THE COMMON OR WITCH OR WHATEVER IS IMMUNE TO THE DAMAGE
			//CODEBEAN
			GetEntPropString(Client, Prop_Data, "m_ModelName", ModelName, sizeof(ModelName));
			if (IsClientAlive && GetClientTeam(Client) == TEAM_SURVIVOR || !IsSpecialCommonInRangeEx(Client, "jimmy") && StrContains(ModelName, "jimmy", false) == -1 && !IsSpecialCommonInRange(Client, 't')) {
				if (IsClientAlive) {
					if (IsClientInRangeSpecialAmmo(Client, "D") == -2.0) {
						DamageShield = RoundToCeil(t_Damage * (1.0 - IsClientInRangeSpecialAmmo(Client, "D", false, _, t_Damage * 1.0)));
						if (DamageShield > 0) {
							SetClientTotalHealth(Client, DamageShield);
							AddSpecialInfectedDamage(Client, Owner, DamageShield, true);
						}
					}
					else {
						SetClientTotalHealth(Client, t_Damage);
						AddSpecialInfectedDamage(Client, Owner, t_Damage, true);
					}
				}
				else EntityStatusEffectDamage(Client, t_Damage);
				if (Client != Owner && IsLegitimateClientAlive(Owner) && (!IsLegitimateClient(Client) || GetClientTeam(Client) != GetClientTeam(Owner))) {
					HexingContribution[Owner] += t_Damage;
					GetAbilityStrengthByTrigger(Client, Owner, "L", _, t_Damage);
				}
			}
		}
		if (FlTime - 0.5 <= 0.0 || damage <= 0) {
			EntityOnFire.Erase(i);
			EntityOnFireName.Erase(i);
			continue;
		}
		EntityOnFire.Set(i, damage - t_Damage, 1);
		EntityOnFire.Set(i, FlTime - 0.5, 2);
		EntityOnFire.Set(i, TickInt - 0.5, 3);
	}
	return Plugin_Continue;
}

stock void CreateCombustion(int client, float g_Strength, float f_Time)
{
	int entity				= CreateEntityByName("env_fire");
	float loc[3];
	GetClientAbsOrigin(client, loc);

	char s_Strength[64];
	Format(s_Strength, sizeof(s_Strength), "%3.3f", g_Strength);

	DispatchKeyValue(entity, "StartDisabled", "0");
	DispatchKeyValue(entity, "damagescale", s_Strength);
	char s_Health[64];
	Format(s_Health, sizeof(s_Health), "%3.3f", f_Time);

	DispatchKeyValue(entity, "fireattack", "2");
	DispatchKeyValue(entity, "firesize", "128");
	DispatchKeyValue(entity, "health", s_Health);
	DispatchKeyValue(entity, "ignitionpoint", "1");
	DispatchSpawn(entity);

	TeleportEntity(entity, loc, NULL_VECTOR, NULL_VECTOR);
	AcceptEntityInput(entity, "Enable");
	AcceptEntityInput(entity, "StartFire");
	
	CreateTimer(f_Time, Timer_DestroyCombustion, entity, TIMER_FLAG_NO_MAPCHANGE);
}


// FIX THIS FIRST
stock int GetSpecialCommonDamage(int damage, int client, int Effect, int victim) {

	/*

		Victim is always a survivor, and is only used to pass to the GetCommonsInRange function which uses their level
		to determine its range of buff.
	*/
	float f_Strength = 1.0;

	float ClientPos[3], fEntPos[3];
	if (!IsLegitimateClient(client)) GetEntPropVector(client, Prop_Send, "m_vecOrigin", ClientPos);
	else GetClientAbsOrigin(client, ClientPos);

	int ent = -1;
	char EffectT[4];
	Format(EffectT, sizeof(EffectT), "%c", Effect);

	char AuraEffectIsh[10];
	for (int i = 0 ; i < CommonInfected.Length; i++) {

		ent = CommonInfected.Get(i);
		if (ent == client || !IsSpecialCommon(ent)) continue;
		GetCommonValueAtPos(AuraEffectIsh, sizeof(AuraEffectIsh), ent, SUPER_COMMON_AURA_EFFECT);
		if (StrContains(AuraEffectIsh, EffectT, true) != -1) {

			GetEntPropVector(ent, Prop_Send, "m_vecOrigin", fEntPos);
			
			//	If the damaging common is in range of an entity meeting the specific effect, then we add its effects. In this case, it's damage.
			
			if (IsInRange(fEntPos, ClientPos, GetCommonValueFloatAtPos(ent, SUPER_COMMON_RANGE_MAX))) {

				f_Strength += (GetCommonValueFloatAtPos(ent, SUPER_COMMON_STRENGTH_TARGET) * GetEntitiesInRange(ent, victim, 0));
				f_Strength += (GetCommonValueFloatAtPos(ent, SUPER_COMMON_STRENGTH_SPECIAL) * GetEntitiesInRange(ent, victim, 1));
			}
		}
	}
	return RoundToCeil(damage * f_Strength);
}

stock int GetEntitiesInRange(int client, int victim, int EntityType) {
	float ClientPos[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", ClientPos);

	float AfxRange		= GetCommonValueFloatAtPos(client, SUPER_COMMON_RANGE_PLAYER_LEVEL) * PlayerLevel[victim];
	float AfxRangeMax	= GetCommonValueFloatAtPos(client, SUPER_COMMON_RANGE_MAX);
	float AfxRangeBase	= GetCommonValueFloatAtPos(client, SUPER_COMMON_RANGE_MIN);
	if (AfxRange + AfxRangeBase > AfxRangeMax) AfxRange = AfxRangeMax;
	else AfxRange += AfxRangeBase;
	int ent = -1;
	float EntPos[3];
	int count = 0;
	if (EntityType == 0) {
		for (int i = 0; i < CommonInfected.Length; i++) {
			ent = CommonInfected.Get(i);
			if (ent == client) continue;
			if (!IsCommonInfected(ent)) {
				CommonInfected.Erase(i);
				CommonInfectedHealth.Erase(i);
				continue;
			}
			GetEntPropVector(ent, Prop_Send, "m_vecOrigin", EntPos);
			if (IsInRange(ClientPos, EntPos, AfxRange)) count++;
		}
	}
	else {
		for (int i = 1; i <= MaxClients; i++) {
			if (IsLegitimateClientAlive(i) && GetClientTeam(i) == TEAM_INFECTED) {
				GetClientAbsOrigin(i, EntPos);
				if (IsInRange(ClientPos, EntPos, AfxRange)) count++;
			}
		}
	}
	return count;
}

stock bool IsSpecialCommonInRangeEx(int client, char[] vEntity="none", bool IsAuraEffect = true) {	// false for death effect

	float ClientPos[3];
	float fEntPos[3];
	if (!IsLegitimateClient(client)) GetEntPropVector(client, Prop_Send, "m_vecOrigin", ClientPos);
	else GetClientAbsOrigin(client, ClientPos);

	int ent = -1;
	//new Effect = 't';
	for (int i = 0; i < CommonAffixes.Length; i++) {
		ent = CommonAffixes.Get(i);
		if (ent == client || !IsCommonInfected(ent)) continue;
		if (!StrEqual(vEntity, "none", false)) {
			if(!CommonInfectedModel(ent, vEntity)) continue;
		}

		/*

			At a certain level, like a lower one, it's just too much having to deal with auras, so some players will absolutely be oblivious to the shit
			going on and killing other players who CAN see them.
		*/
		if (IsLegitimateClient(client) && PlayerLevel[client] < GetCommonValueIntAtPos(ent, SUPER_COMMON_LEVEL_REQ)) return false;

		GetEntPropVector(ent, Prop_Send, "m_vecOrigin", fEntPos);
		if (IsInRange(fEntPos, ClientPos, GetCommonValueFloatAtPos(ent, SUPER_COMMON_RANGE_MAX))) return true;
	}
	return false;
}

stock bool IsSpecialCommonInRange(int client, int Effect = -1, int vEntity = -1, bool IsAuraEffect = true, int infectedTarget = 0) {	// false for death effect

	float ClientPos[3];
	float fEntPos[3];
	if (!IsLegitimateClient(client)) GetEntPropVector(client, Prop_Send, "m_vecOrigin", ClientPos);
	else GetClientAbsOrigin(client, ClientPos);

	char EffectT[4];
	Format(EffectT, sizeof(EffectT), "%c", Effect);

	char TheAuras[10];
	char TheDeaths[10];

	if (vEntity != -1) {

		GetCommonValueAtPos(TheAuras, sizeof(TheAuras), vEntity, SUPER_COMMON_AURA_EFFECT);
		GetCommonValueAtPos(TheDeaths, sizeof(TheDeaths), vEntity, SUPER_COMMON_DEATH_EFFECT);

		float AfxRange = GetCommonValueFloatAtPos(vEntity, SUPER_COMMON_RANGE_PLAYER_LEVEL);
		//new Float:AfxStrengthLevel = StringToFloat(GetCommonValue(vEntity, "level strength?"));
		float AfxRangeMax = GetCommonValueFloatAtPos(vEntity, SUPER_COMMON_RANGE_MAX);
		//new AfxMultiplication = StringToInt(GetCommonValue(vEntity, "enemy multiplication?"));
		//new AfxStrength = StringToInt(GetCommonValue(vEntity, "aura strength?"));
		//new AfxChain = StringToInt(GetCommonValue(vEntity, "chain reaction?"));
		//new Float:AfxStrengthTarget = StringToFloat(GetCommonValue(vEntity, "strength target?"));
		float AfxRangeBase = GetCommonValueFloatAtPos(vEntity, SUPER_COMMON_RANGE_MIN);
		int AfxLevelReq = GetCommonValueIntAtPos(vEntity, SUPER_COMMON_LEVEL_REQ);

		if (IsLegitimateClient(client) && GetClientTeam(client) == TEAM_SURVIVOR && PlayerLevel[client] < AfxLevelReq) return false;

		//new Float:SourcLoc[3];
		//new Float:TargetPosition[3];
		//new t_Strength = 0;
		float t_Range = 0.0;

		if (AfxRange > 0.0) t_Range = AfxRange * (PlayerLevel[client] - AfxLevelReq);
		else t_Range = AfxRangeMax;
		if (t_Range + AfxRangeBase > AfxRangeMax) t_Range = AfxRangeMax;
		else t_Range += AfxRangeBase;

		if (IsAuraEffect && StrContains(TheAuras, EffectT, true) != -1 || !IsAuraEffect && StrContains(TheDeaths, EffectT, true) != -1) {

			GetEntPropVector(vEntity, Prop_Send, "m_vecOrigin", fEntPos);
			if (IsInRange(fEntPos, ClientPos, t_Range)) {
				infectedTarget = vEntity;
				return true;
			}
		}
	}
	else {

		int ent = -1;
		for (int i = 0; i < CommonAffixes.Length; i++) {

			ent = CommonAffixes.Get(i);
			
			if (ent == client) continue;
			if (!IsCommonInfected(ent)) {
				CommonAffixes.Erase(i);
				continue;
			}
			if (vEntity >= 0 && ent != vEntity) continue;

			GetCommonValueAtPos(TheAuras, sizeof(TheAuras), ent, SUPER_COMMON_AURA_EFFECT);
			GetCommonValueAtPos(TheDeaths, sizeof(TheDeaths), ent, SUPER_COMMON_DEATH_EFFECT);

			/*

				At a certain level, like a lower one, it's just too much having to deal with auras, so some players will absolutely be oblivious to the shit
				going on and killing other players who CAN see them.
			*/
			if (IsLegitimateClient(client) && PlayerLevel[client] < GetCommonValueIntAtPos(ent, SUPER_COMMON_LEVEL_REQ)) return false;

			if (IsAuraEffect && StrContains(TheAuras, EffectT, true) != -1 || !IsAuraEffect && StrContains(TheDeaths, EffectT, true) != -1) {

				GetEntPropVector(ent, Prop_Send, "m_vecOrigin", fEntPos);
				if (IsInRange(fEntPos, ClientPos, GetCommonValueFloatAtPos(ent, SUPER_COMMON_RANGE_MAX))) {
					infectedTarget = ent;
					return true;
				}
			} 
		}
	}
	return false;
}

/*

	This timer runs 100 times / second. =)
	Overseer of the Common Affixes Program or CAP.
*/

public Action Timer_CommonAffixes(Handle timer) {

	if (!b_IsActiveRound) {

		for (int i = 1; i <= MaxClients; i++) {

			//CommonAffixesCooldown[i].Clear();
			SpecialCommon[i].Clear();
		}
		ResetArray(CommonInfected);
		ResetArray(WitchList);
		ResetArray(CommonList);
		ResetArray(CommonAffixes);
		return Plugin_Stop;
	}
	static int ent = -1;
	static int IsCommonAffixesEnabled = -2;
	if (IsCommonAffixesEnabled == -2) IsCommonAffixesEnabled = iCommonAffixes;
	if (IsCommonAffixesEnabled == 2) {
		for (int zombie = 0; zombie < CommonAffixes.Length; zombie++) {
			ent = CommonAffixes.Get(zombie);
			if (IsCommonInfected(ent)) DrawCommonAffixes(ent);
		}
	}
	// tanks with cloned abilities
	for (int i = 1; i <= MaxClients; i++) {

		if (!IsLegitimateClientAlive(i) || GetClientTeam(i) != TEAM_INFECTED || FindZombieClass(i) != ZOMBIECLASS_TANK) continue;
		if (bIsDefenderTank[i]) {

			// draw defender tank rings
			DrawSpecialInfectedAffixes(i);
		}
	}
	return Plugin_Continue;
}

stock int GetCommonVisuals(char[] TheString, int TheSize, int entity, int key = 0, int pos = 0) {
	char AffixName[2][64];
	int ent = -1;
	int size = CommonAffixes.Length;
	for (int i = 0; i < size; i++) {

		//Handle CommonAffixes.GetString(i, SectionName, sizeof(SectionName));
		//ent = FindEntityInString(SectionName);
		ent = CommonAffixes.Get(i);
		if (!IsValidEntity(ent)) {
			CommonAffixes.Erase(i);
			size--;
			continue;
		}
		if (entity != ent) continue;	// searching for a specific entity.
		GetEntPropString(entity, Prop_Data, "m_iName", AffixName[0], sizeof(AffixName[]));
		//Format(AffixName[0], sizeof(AffixName[]), "%s", SectionName);
		//ExplodeString(AffixName[0], ":", AffixName, 2, 64);

		ent = FindListPositionBySearchKey(AffixName[0], a_CommonAffixes, 2, DEBUG);
		if (ent < 0) return -1;
		h_CommonKeys		= a_CommonAffixes.Get(ent, 0);
		h_CommonValues		= a_CommonAffixes.Get(ent, 1);
		if (key == 0) return FormatKeyValue(TheString, TheSize, h_CommonKeys, h_CommonValues, "draw colour?", _, _, pos);
		else return FormatKeyValue(TheString, TheSize, h_CommonKeys, h_CommonValues, "draw pos?", _, _, pos);
	}
	Format(TheString, TheSize, "-1");
	return -1;
}

stock int GetCommonValueAtPos(char[] TheString, int TheSize, int entity, int valPos, int pos = 0, bool incrementNonZeroPos = true) {
	char AffixName[2][64];
	int ent = -1;
	if (pos > 0 && incrementNonZeroPos) pos++;
	int size = CommonAffixes.Length;
	for (int i = pos; i < size; i++) {

		//Handle CommonAffixes.GetString(i, SectionName, sizeof(SectionName));
		//ent = FindEntityInString(SectionName);
		ent = CommonAffixes.Get(i);
		if (!IsValidEntity(ent)) {
			CommonAffixes.Erase(i);
			size--;
			continue;
		}
		if (entity != ent) continue;	// searching for a specific entity.

		//Format(AffixName[0], sizeof(AffixName[]), "%s", SectionName);
		//ExplodeString(AffixName[0], ":", AffixName, 2, 64);
		GetEntPropString(entity, Prop_Data, "m_iName", AffixName[0], sizeof(AffixName[]));

		ent = FindListPositionBySearchKey(AffixName[0], a_CommonAffixes, 2, DEBUG);
		//if (ent < 0) LogMessage("[GetCommonValue] failed at FindListPositionBySearchKey(%s)", AffixName[0]);
		if (ent >= 0) {

			//h_CommonKeys		= a_CommonAffixes.Get(ent, 0);
			h_CommonValues		= a_CommonAffixes.Get(ent, 1);
			h_CommonValues.GetString(valPos, TheString, TheSize);
			//FormatKeyValue(TheString, TheSize, h_CommonKeys, h_CommonValues, Key);
			return i;
		}
	}
	Format(TheString, TheSize, "-1");
	return -1;
}

stock int GetCommonValueIntAtPos(int entity, int pos) {
	char AffixName[2][64];
	int ent = -1;

	char text[64];

	int size = CommonAffixes.Length;
	for (int i = 0; i < size; i++) {

		//Handle CommonAffixes.GetString(i, SectionName, sizeof(SectionName));
		//ent = FindEntityInString(SectionName);
		ent = CommonAffixes.Get(i);
		if (!IsValidEntity(ent)) {

			CommonAffixes.Erase(i);
			size--;
			continue;
		}
		if (entity != ent) continue;	// searching for a specific entity.
		GetEntPropString(entity, Prop_Data, "m_iName", AffixName[0], sizeof(AffixName[]));
		//Format(AffixName[0], sizeof(AffixName[]), "%s", SectionName);
		//ExplodeString(AffixName[0], ":", AffixName, 2, 64);

		ent = FindListPositionBySearchKey(AffixName[0], a_CommonAffixes, 2, DEBUG);
		if (ent < 0) continue;//LogMessage("[GetCommonValue] failed at FindListPositionBySearchKey(%s)", AffixName[0]);
		//h_CommonKeys		= a_CommonAffixes.Get(ent, 0);
		h_CommonValues		= a_CommonAffixes.Get(ent, 1);
		h_CommonValues.GetString(pos, text, sizeof(text));
		return StringToInt(text);
	}
	return -1;
}

stock float GetCommonValueFloatAtPos(int entity, int pos, char[] Section_Name = "none") {	// can override the section
	char AffixName[2][64];
	int ent = -1;

	char text[64];

	int size = CommonAffixes.Length;
	for (int i = 0; i < size; i++) {

		ent = CommonAffixes.Get(i);
		if (!IsValidEntity(ent)) {

			CommonAffixes.Erase(i);
			size--;
			continue;
		}
		if (entity != ent) continue;	// searching for a specific entity.
		GetEntPropString(entity, Prop_Data, "m_iName", AffixName[0], sizeof(AffixName[]));

		ent = FindListPositionBySearchKey(AffixName[0], a_CommonAffixes, 2, DEBUG);
		if (ent < 0) LogMessage("[GetCommonValue] failed at FindListPositionBySearchKey(%s)", AffixName[0]);
		else {

			//h_CommonKeys		= a_CommonAffixes.Get(ent, 0);
			h_CommonValues		= a_CommonAffixes.Get(ent, 1);
			h_CommonValues.GetString(pos, text, sizeof(text));
			return StringToFloat(text);
		}
	}
	return -1.0;
}

stock int GetCommonValue(char[] TheString, int TheSize, int entity, char[] Key, int pos = 0, bool incrementNonZeroPos = true) {
	char AffixName[2][64];
	int ent = -1;
	if (pos > 0 && incrementNonZeroPos) pos++;
	int size = CommonAffixes.Length;
	for (int i = pos; i < size; i++) {

		//Handle CommonAffixes.GetString(i, SectionName, sizeof(SectionName));
		//ent = FindEntityInString(SectionName);
		ent = CommonAffixes.Get(i);
		if (!IsValidEntity(ent)) {
			CommonAffixes.Erase(i);
			size--;
			continue;
		}
		if (entity != ent) continue;	// searching for a specific entity.

		//Format(AffixName[0], sizeof(AffixName[]), "%s", SectionName);
		//ExplodeString(AffixName[0], ":", AffixName, 2, 64);
		GetEntPropString(entity, Prop_Data, "m_iName", AffixName[0], sizeof(AffixName[]));

		ent = FindListPositionBySearchKey(AffixName[0], a_CommonAffixes, 2, DEBUG);
		//if (ent < 0) LogMessage("[GetCommonValue] failed at FindListPositionBySearchKey(%s)", AffixName[0]);
		if (ent >= 0) {

			h_CommonKeys		= a_CommonAffixes.Get(ent, 0);
			h_CommonValues		= a_CommonAffixes.Get(ent, 1);
			FormatKeyValue(TheString, TheSize, h_CommonKeys, h_CommonValues, Key, _, _, SUPER_COMMON_FIRST_RANDOM_KEY_POS, false);
			return i;
		}
	}
	Format(TheString, TheSize, "-1");
	return -1;
}

stock int GetCommonValueInt(int entity, char[] Key) {
	char AffixName[2][64];
	int ent = -1;

	char text[64];

	int size = CommonAffixes.Length;
	for (int i = 0; i < size; i++) {

		//Handle CommonAffixes.GetString(i, SectionName, sizeof(SectionName));
		//ent = FindEntityInString(SectionName);
		ent = CommonAffixes.Get(i);
		if (!IsValidEntity(ent)) {

			CommonAffixes.Erase(i);
			size--;
			continue;
		}
		if (entity != ent) continue;	// searching for a specific entity.
		GetEntPropString(entity, Prop_Data, "m_iName", AffixName[0], sizeof(AffixName[]));
		//Format(AffixName[0], sizeof(AffixName[]), "%s", SectionName);
		//ExplodeString(AffixName[0], ":", AffixName, 2, 64);

		ent = FindListPositionBySearchKey(AffixName[0], a_CommonAffixes, 2, DEBUG);
		if (ent < 0) continue;//LogMessage("[GetCommonValue] failed at FindListPositionBySearchKey(%s)", AffixName[0]);
		h_CommonKeys		= a_CommonAffixes.Get(ent, 0);
		h_CommonValues		= a_CommonAffixes.Get(ent, 1);
		FormatKeyValue(text, sizeof(text), h_CommonKeys, h_CommonValues, Key);
		return StringToInt(text);
	}
	return -1;
}

stock float GetCommonValueFloat(int entity, char[] Key, char[] Section_Name = "none") {	// can override the section
	char AffixName[2][64];
	int ent = -1;

	char text[64];

	int size = CommonAffixes.Length;
	for (int i = 0; i < size; i++) {

		ent = CommonAffixes.Get(i);
		if (!IsValidEntity(ent)) {

			CommonAffixes.Erase(i);
			size--;
			continue;
		}
		if (entity != ent) continue;	// searching for a specific entity.
		GetEntPropString(entity, Prop_Data, "m_iName", AffixName[0], sizeof(AffixName[]));

		ent = FindListPositionBySearchKey(AffixName[0], a_CommonAffixes, 2, DEBUG);
		if (ent < 0) LogMessage("[GetCommonValue] failed at FindListPositionBySearchKey(%s)", AffixName[0]);
		else {

			h_CommonKeys		= a_CommonAffixes.Get(ent, 0);
			h_CommonValues		= a_CommonAffixes.Get(ent, 1);
			FormatKeyValue(text, sizeof(text), h_CommonKeys, h_CommonValues, Key);
			return StringToFloat(text);
		}
	}
	return -1.0;
}

stock bool IsInRange(float EntitLoc[3], float TargetLo[3], float AllowsMaxRange, float ModeSize = 1.0) {

	//new Float:ModelSize = 48.0 * ModeSize;
	
	if (GetVectorDistance(EntitLoc, TargetLo) <= (AllowsMaxRange / 2)) return true;
	return false;
}

stock int DrawSpecialInfectedAffixes(int client, int target = -1, float fRange = 256.0) {
	if (target != -1) {
		float clientPos[3];
		float targetPos[3];
		GetEntPropVector(target, Prop_Send, "m_vecOrigin", targetPos);
		for (client = 1; client <= MaxClients; client++) {
			if (client == target || !IsLegitimateClient(client) || FindZombieClass(client) != ZOMBIECLASS_TANK || !bIsDefenderTank[client]) continue;
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", clientPos);
			if (GetVectorDistance(clientPos, targetPos) <= fRange) return 1;
		}
		return 0;
	}
	char AfxDrawColour[10];
	char AfxDrawPos[10];
	if (FindZombieClass(client) == ZOMBIECLASS_TANK) {
		if (bIsDefenderTank[client]) {
			Format(AfxDrawColour, sizeof(AfxDrawColour), "blue:blue");
			Format(AfxDrawPos, sizeof(AfxDrawPos), "20.0:30.0");
		}
	}
	else return 0;
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i) || IsFakeClient(i)) continue;
		CreateRingSolo(client, fRange, AfxDrawColour, AfxDrawPos, false, 0.25, i);
	}
	return 1;
}

stock void DrawCommonAffixes(int entity, char[] sForceAuraEffect = "none") {
	char AfxEffect[64];
	char AfxDrawColour[64];
	float AfxRange = -1.0;
	float AfxRangeMax = -1.0;
	char AfxDrawPos[64];
	int AfxDrawType = -1;

	float EntityPos[3];
	float TargetPos[3];

	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", EntityPos);

	float AfxRangeBase = -1.0;

	GetCommonValueAtPos(AfxEffect, sizeof(AfxEffect), entity, SUPER_COMMON_AURA_EFFECT);
	AfxRange		= GetCommonValueFloatAtPos(entity, SUPER_COMMON_RANGE_PLAYER_LEVEL);
	AfxRangeMax		= GetCommonValueFloatAtPos(entity, SUPER_COMMON_RANGE_MAX);
	AfxDrawType		= GetCommonValueIntAtPos(entity, SUPER_COMMON_DRAW_TYPE);
	if (AfxDrawType == -1) return;
	AfxRangeBase	= GetCommonValueFloatAtPos(entity, SUPER_COMMON_RANGE_MIN);

	int AfxLevelReq = GetCommonValueIntAtPos(entity, SUPER_COMMON_LEVEL_REQ);



	//AfxRange += AfxRangeBase;
	int drawColourPos = 0;
	int drawPosPos = 0;
	float t_Range = -1.0;
	while (drawColourPos >= 0 && drawPosPos >= 0) {
		drawColourPos	= GetCommonVisuals(AfxDrawColour, sizeof(AfxDrawColour), entity, 0, drawColourPos);
		drawPosPos		= GetCommonVisuals(AfxDrawPos, sizeof(AfxDrawPos), entity, 1, drawPosPos);
		if (drawColourPos < 0 || drawPosPos < 0) return;
		for (int i = 1; i <= MaxClients; i++) {
			if (!IsLegitimateClient(i) || IsFakeClient(i)) continue;
			if (GetClientTeam(i) == TEAM_SURVIVOR && PlayerLevel[i] < AfxLevelReq) continue;
			if (AfxRange > 0.0) t_Range = AfxRange * (PlayerLevel[i] - AfxLevelReq);
			else t_Range = AfxRangeMax;
			if (t_Range + AfxRangeBase > AfxRangeMax) t_Range = AfxRangeMax;
			else t_Range += AfxRangeBase;
			if (AfxDrawType == 0) CreateRingSoloEx(entity, t_Range, AfxDrawColour, AfxDrawPos, false, 0.25, i);
			else if (AfxDrawType == 1) {
				for (int y = 1; y <= MaxClients; y++) {
					if (!IsLegitimateClient(y) || IsFakeClient(y) || GetClientTeam(y) != TEAM_SURVIVOR) continue;
					GetClientAbsOrigin(y, TargetPos);
					// Player is outside the applicable range.
					if (!IsInRange(EntityPos, TargetPos, t_Range)) continue;

					CreateLineSoloEx(entity, y, AfxDrawColour, AfxDrawPos, 0.25, i);	// the last arg makes sure the line is drawn only for the player, otherwise it is drawn for all players, and that is bad as we are looping all players here already.
				}
			}
			t_Range = 0.0;
		}
	}

	

	//Now we execute the effects, after all players have clearly seen them.

	int t_Strength			= 0;
	int AfxStrength			= GetCommonValueIntAtPos(entity, SUPER_COMMON_AURA_STRENGTH);
	int AfxMultiplication	= GetCommonValueIntAtPos(entity, SUPER_COMMON_ENEMY_MULTIPLICATION);
	float AfxStrengthLevel = GetCommonValueFloatAtPos(entity, SUPER_COMMON_LEVEL_STRENGTH);
	
	if (AfxMultiplication == 1) t_Strength = AfxStrength * LivingEntitiesInRange(entity, EntityPos, t_Range);
	else t_Strength = AfxStrength;

	for (int i = 1; i <= MaxClients; i++) {

		if (!IsLegitimateClientAlive(i) || GetClientTeam(i) != TEAM_SURVIVOR || PlayerLevel[i] < AfxLevelReq) continue;
		GetClientAbsOrigin(i, TargetPos);

		if (AfxRange > 0.0) t_Range = AfxRange * (PlayerLevel[i] - AfxLevelReq);
		else t_Range = AfxRangeMax;
		if (t_Range + AfxRangeBase > AfxRangeMax) t_Range = AfxRangeMax;
		else t_Range += AfxRangeBase;

		// Player is outside the applicable range.
		if (!IsInRange(EntityPos, TargetPos, t_Range)) continue;

		if (AfxStrengthLevel > 0.0) t_Strength += RoundToCeil(t_Strength * (PlayerLevel[i] * AfxStrengthLevel));

		//If they are not immune to the effects, we consider the effects.
		
		if (StrContains(AfxEffect, "d", true) != -1) {

			//if (t_Strength > GetClientHealth(i)) IncapacitateOrKill(i);
			//else SetEntityHealth(i, GetClientHealth(i) - t_Strength);
			SetClientTotalHealth(i, t_Strength);
		}
		if (StrContains(AfxEffect, "l", true) != -1) {


			//	We don't want multiple blinders to spam blind a player who is already blind.
			//	Furthermore, we don't want it to accidentally blind a player AFTER it dies and leave them permablind.

			//	ISBLIND is tied a timer, and when the timer reverses the blind, it will close the handle.
			if (ISBLIND[i] == INVALID_HANDLE) BlindPlayer(i, 0.0, 255);
		}
		if (StrContains(AfxEffect, "r", true) != -1) {

			//

			//	Freeze players, teleport them up a lil bit.

			//
			if (ISFROZEN[i] == INVALID_HANDLE) FrozenPlayer(i, 0.0);
		}
	}
	/*new bool:IsHealer = (StrContains(AfxEffect, "h", true) != -1) ? true : false;
	if (!IsHealer) return;

	new ent = -1;
	new pos = -1;

	for (new i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClientAlive(i) || GetClientTeam(i) != TEAM_INFECTED) continue;
		GetClientAbsOrigin(i, TargetPos);
		if (!IsInRange(EntityPos, TargetPos, AfxRangeMax)) continue;
		for (new y = 1; y <= MaxClients; y++) {
			if (!IsLegitimateClient(y) || GetClientTeam(y) != TEAM_SURVIVOR) continue;
			pos = FindListPositionByEntity(i, InfectedHealth[y]);
			if (pos < 0) continue;
			Handle InfectedHealth[y].Set(pos, Handle InfectedHealth[y].Get(pos, 1) + t_Strength, 1);
		}
	}
	new commonHealth = 0;
	for (new i = 0; i < Handle CommonInfected.Length; i++) {
		ent = Handle CommonInfected.Get(i);
		if (ent == entity || !IsCommonInfected(ent)) continue;
		GetEntPropVector(ent, Prop_Send, "m_vecOrigin", TargetPos);
		if (!IsInRange(EntityPos, TargetPos, AfxRangeMax)) continue;
		commonHealth = CommonInfectedHealth.Get(i);
		CommonInfectedHealth.Set(i, commonHealth + t_Strength);
	}*/
}

stock int LivingEntitiesInRangeByType(int client, float effectRange, int targetTeam = 0) {
	int count = 0;
	int target = 0;
	float ClientPos[3];
	if (IsLegitimateClient(client)) GetClientAbsOrigin(client, ClientPos);
	else GetEntPropVector(client, Prop_Send, "m_vecOrigin", ClientPos);
	float TargetPos[3];
	if (targetTeam >= 3) {	// 3 survivor, 4 infected
		for (int i = 1; i <= MaxClients; i++) {
			if (i == client) continue;
			if (!IsLegitimateClientAlive(i)) continue;
			if (GetClientTeam(i) + 1 != targetTeam) continue;

			GetClientAbsOrigin(i, TargetPos);
			if (GetVectorDistance(ClientPos, TargetPos) > effectRange) continue;
			count++;
		}
	}
	else if (targetTeam <= 1) { // 0 commons, 1 special commons
		for (int i = 0; i < CommonInfected.Length; i++) {
			target = CommonInfected.Get(i);
			if (targetTeam == 1 && !IsSpecialCommon(target)) continue;

			GetEntPropVector(target, Prop_Send, "m_vecOrigin", TargetPos);
			if (GetVectorDistance(ClientPos, TargetPos) > effectRange) continue;
			count++;
		}
	}
	else if (targetTeam == 2) { // witches
		for (int i = 0; i < WitchList.Length; i++) {
			target = WitchList.Get(i);
			if (!IsWitch(target)) continue;

			GetEntPropVector(target, Prop_Send, "m_vecOrigin", TargetPos);
			if (GetVectorDistance(ClientPos, TargetPos) > effectRange) continue;
			count++;
		}
	}
	return count;
}

stock int LivingEntitiesInRange(int entity, float SourceLoc[3], float EffectRange, int targetType = 0) {

	int count = 0;
	float Pos[3];
	if (targetType != 1) {
		for (int i = 1; i <= MaxClients; i++) {
			if (IsLegitimateClientAlive(i)) {
				if (targetType != 4) {
					if (targetType == 2 && GetClientTeam(i) != TEAM_SURVIVOR) continue;
					else if (targetType == 3 && GetClientTeam(i) != TEAM_INFECTED) continue;
				}

				GetClientAbsOrigin(i, Pos);
				if (!IsInRange(SourceLoc, Pos, EffectRange)) continue;
				count++;
			}
		}
	}
	if (targetType <= 1) {
		int ent = -1;
		for (int i = 0; i < CommonInfected.Length; i++) {
			ent = CommonInfected.Get(i);
			if (!IsCommonInfected(ent)) continue;
			GetEntPropVector(ent, Prop_Send, "m_vecOrigin", Pos);
			if (!IsInRange(SourceLoc, Pos, EffectRange)) continue;
			count++;
		}
	}
	return count;
}

stock bool IsAbilityCooldown(int client, char[] TalentName) {

	int a_Size				=	0;
	a_Size					=	a_Database_PlayerTalents[client].Length;
	char Name[PLATFORM_MAX_PATH];
	char t_Cooldown[8];
	for (int i = 0; i < a_Size; i++) {
		a_Database_Talents.GetString(i, Name, sizeof(Name));
		if (StrEqual(Name, TalentName)) {
			PlayerAbilitiesCooldown[client].GetString(i, t_Cooldown, sizeof(t_Cooldown));
			if (StrEqual(t_Cooldown, "1")) return true;
			break;
		}
	}
	return false;
}

stock void GetTalentNameAtMenuPosition(int client, int pos, char[] TheString, int stringSize) {
	TalentAtMenuPositionSection[client] = a_Menu_Talents.Get(pos, 2);
	TalentAtMenuPositionSection[client].GetString(0, TheString, stringSize);
}

stock int GetMenuPosition(int client, char[] TalentName) {
	int size						=	a_Menu_Talents.Length;
	char Name[PLATFORM_MAX_PATH];
	for (int i = 0; i < size; i++) {
		MenuPosition[client]				= a_Menu_Talents.Get(i, 2);
		MenuPosition[client].GetString(0, Name, sizeof(Name));
		if (StrEqual(Name, TalentName)) return i;
	}
	return -1;
}


stock int GetTalentPosition(int client, char[] TalentName) {
	int pos = -1;
	int a_Size				=	0;
	a_Size					=	a_Database_PlayerTalents[client].Length;
	char Name[PLATFORM_MAX_PATH];
	for (int i = 0; i < a_Size; i++) {
		a_Database_Talents.GetString(i, Name, sizeof(Name));
		if (StrEqual(Name, TalentName)) return i;
	}
	return pos;
}

stock void RemoveImmunities(int client) {

	// We remove all immunities when a round ends, otherwise they may not properly remove and then players become immune, forever.
	int size = 0;
	if (client == -1) {

		size = PlayerAbilitiesCooldown_Bots.Length;
		for (int i = 0; i < size; i++) {

			//PlayerAbilitiesImmune_Bots.SetString(i, "0");
			PlayerAbilitiesCooldown_Bots.SetString(i, "0");
		}
		for (int i = 1; i <= MAXPLAYERS; i++) {

			RemoveImmunities(i);
		}
	}
	else {

		size = PlayerAbilitiesCooldown[client].Length;
		for (int i = 0; i < size; i++) {

			//PlayerAbilitiesImmune[client].SetString(i, "0");
			PlayerAbilitiesCooldown[client].SetString(i, "0");
		}
	}
}

/*stock CreateImmune(activator, client, pos, Float:f_Cooldown) {

	if (IsLegitimateClient(client)) {

		//if (!IsFakeClient(client)) PlayerAbilitiesImmune[client].SetString(pos, "1");
		//else PlayerAbilitiesImmune_Bots.SetString(pos, "1");
		PlayerAbilitiesImmune[client][activator].SetString(pos, "1");

		new Handle packy;
		CreateDataTimer(f_Cooldown, Timer_RemoveImmune, packy, TIMER_FLAG_NO_MAPCHANGE);
		if (IsFakeClient(client)) client = -1;
		packy.WriteCell(client);
		packy.WriteCell(pos);
		packy.WriteCell(activator);
	}
}*/

stock int GetAimTargetPosition(int client, float TargetPos[3]) {
	float ClientEyeAngles[3];
	float ClientEyePosition[3];
	GetClientEyeAngles(client, ClientEyeAngles);
	GetClientEyePosition(client, ClientEyePosition);
	int aimTarget = 0;

	Handle trace = TR_TraceRayFilterEx(ClientEyePosition, ClientEyeAngles, MASK_SHOT, RayType_Infinite, TraceRayIgnoreSelf, client);
	if (TR_DidHit(trace)) {
		aimTarget = TR_GetEntityIndex(trace);
		if (IsCommonInfected(aimTarget) || IsWitch(aimTarget) || IsLegitimateClient(aimTarget)) {
			GetEntPropVector(aimTarget, Prop_Send, "m_vecOrigin", TargetPos);
		}
		else {
			aimTarget = -1;
			TR_GetEndPosition(TargetPos, trace);
		}
	}
	delete trace;
	return aimTarget;
}

// GetTargetOnly is set to true only when casting single-target spells, which require an actual target.
stock void GetClientAimTargetEx(int client, char[] TheText, int TheSize, bool GetTargetOnly = false) {

	float ClientEyeAngles[3];
	float ClientEyePosition[3];
	float ClientLookTarget[3];

	GetClientEyeAngles(client, ClientEyeAngles);
	GetClientEyePosition(client, ClientEyePosition);

	Handle trace = TR_TraceRayFilterEx(ClientEyePosition, ClientEyeAngles, MASK_SHOT, RayType_Infinite, TraceRayIgnoreSelf, client);

	if (TR_DidHit(trace)) {

		int Target = TR_GetEntityIndex(trace);
		if (GetTargetOnly) {

			if (IsLegitimateClientAlive(Target)) Format(TheText, TheSize, "%d", Target);
			else Format(TheText, TheSize, "-1");
		}
		else {

			TR_GetEndPosition(ClientLookTarget, trace);
			Format(TheText, TheSize, "%3.3f %3.3f %3.3f", ClientLookTarget[0], ClientLookTarget[1], ClientLookTarget[2]);
		}
	}
	delete trace;
}

public bool TraceRayIgnoreSelf(int entity, int mask, any client) {
	
	if (entity < 1 || entity == client) return false;
	return true;
}

stock int GetAbilityDataPosition(int client, int pos) {
	for (int i = 0; i < PlayActiveAbilities[client].Length; i++) {
		if (PlayActiveAbilities[client].Get(i, 0) == pos) return i;
	}
	return -1;
}

public Action Timer_SpecialAmmoData(Handle timer, any client) {

	if (!b_IsActiveRound || !IsLegitimateClient(client) || !bTimersRunning[client]) {
		return Plugin_Stop;
	}
	float EntityPos[3];
	char TalentInfo[4][512];
	static int dataClient = 0;
	float f_TimeRemaining = 0.0;
	static int WorldEnt = -1;
	static int ent = -1;
	static int drawtarget = -1;
	char DataAmmoEffect[10];
	float AmmoStrength = 0.0;
	static int auraMenuPosition = 0;
	bool IsPlayerSameTeam;
	static int dataAmmoType = 0;
	static int bulletStrength = 0;
	float fVisualDelay = 0.0;
	static int numOfStatusEffects = 0;
	numOfStatusEffects = GetClientStatusEffect(client);
	CheckActiveAbility(client, -1, _, _, true);	// draws effects for any active ability this client has.
	for (int i = 0; i < SpecialAmmoData.Length; i++) {
		dataClient = FindClientByIdNumber(SpecialAmmoData.Get(i, 7));
		WorldEnt = SpecialAmmoData.Get(i, 9);
		if (!IsLegitimateClientAlive(dataClient)) {
			SpecialAmmoData.Erase(i);
			if (WorldEnt > 0 && IsValidEntity(WorldEnt)) AcceptEntityInput(WorldEnt, "Kill");
			continue;
		}

		AmmoStrength = 0.0;
		dataAmmoType = 0;
		bulletStrength = 0;
		drawtarget = SpecialAmmoData.Get(i, 11);
		Format(DataAmmoEffect, sizeof(DataAmmoEffect), "0");	// reset it after each go.
		
		//TalentInfo[0] = TalentName of ammo.
		//TalentInfo[1] = Talent Strength (so use StringToInt)
		//TalentInfo[2] = Talent Damage
		//TalentInfo[3] = Talent Interval
		
		GetTalentNameAtMenuPosition(client, SpecialAmmoData.Get(i, 3), TalentInfo[0], sizeof(TalentInfo[]));
		GetSpecialAmmoEffect(DataAmmoEffect, sizeof(DataAmmoEffect), client, TalentInfo[0]);
		if (StrEqual(DataAmmoEffect, "x", true)) dataAmmoType = 1;
		else if (StrEqual(DataAmmoEffect, "h", true)) dataAmmoType = 2;
		else if (StrEqual(DataAmmoEffect, "F", true)) dataAmmoType = 3;
		else if (StrEqual(DataAmmoEffect, "b", true)) dataAmmoType = 4;
		else if (StrEqual(DataAmmoEffect, "a", true)) dataAmmoType = 5;
		else if (StrEqual(DataAmmoEffect, "H", true)) dataAmmoType = 6;
		else if (StrEqual(DataAmmoEffect, "B", true)) dataAmmoType = 7;
		else if (StrEqual(DataAmmoEffect, "C", true)) dataAmmoType = 8;
		
		bulletStrength = SpecialAmmoData.Get(i, 5);
		if (IsClientInRangeSpecialAmmo(client, DataAmmoEffect, _, i) == -2.0) {
			IsPlayerSameTeam = (client == dataClient || GetClientTeam(client) == GetClientTeam(dataClient)) ? true : false;

			AmmoStrength			= (IsClientInRangeSpecialAmmo(client, DataAmmoEffect, false, _, bulletStrength * 1.0)) * bulletStrength;
			if (AmmoStrength <= 0.0) continue;

			if (!IsPlayerSameTeam) {	// the owner of the ammo and the player inside of it are NOT on the same team.
				if (dataAmmoType == 1) ExplosiveAmmo(client, RoundToCeil(AmmoStrength), dataClient);
				else if (dataAmmoType == 2) LeechAmmo(client, RoundToCeil(AmmoStrength), dataClient);
				else if (dataAmmoType == 3) {
					if (ISEXPLODE[client] == INVALID_HANDLE) CreateAndAttachFlame(client, RoundToCeil(AmmoStrength), f_TimeRemaining, f_TimeRemaining, dataClient);
					else CreateAndAttachFlame(client, RoundToCeil(AmmoStrength * TheScorchMult), f_TimeRemaining, f_TimeRemaining, dataClient);
				}
				else if (dataAmmoType == 4) BeanBagAmmo(client, AmmoStrength, dataClient);
			}
			else {
				if (dataAmmoType == 5 && !HasAdrenaline(client)) SetAdrenalineState(client, f_TimeRemaining);
				else if (dataAmmoType == 6) HealingAmmo(client, RoundToCeil(AmmoStrength), dataClient);
				else if (dataAmmoType == 7 && !ISBILED[client]) {
					SDKCall(g_hCallVomitOnPlayer, client, dataClient, true);
					CreateTimer(20.0, Timer_RemoveBileStatus, client, TIMER_FLAG_NO_MAPCHANGE);
					ISBILED[client] = true;
				}
				else if (dataAmmoType == 8 && numOfStatusEffects > 0) RemoveClientStatusEffect(client); //TransferStatusEffect(client, dataClient);
			}
		}
		if (dataClient == client) {	// if this player is the owner of this spell or talent...
			if (IsSpellAnAura(client, TalentInfo[0])) {
				GetClientAbsOrigin(client, EntityPos);
				// update the location of the ammo/spell/whatever
				SpecialAmmoData.Set(i, EntityPos[0], 0);
				SpecialAmmoData.Set(i, EntityPos[1], 1);
				SpecialAmmoData.Set(i, EntityPos[2], 2);
				fVisualDelay = SpecialAmmoData.Get(i, 13);
				fVisualDelay -= fSpecialAmmoInterval;
				if (fVisualDelay > 0.0) SpecialAmmoData.Set(i, fVisualDelay, 13);
				else {
					SpecialAmmoData.Set(i, SpecialAmmoData.Get(i, 12), 13);	
					auraMenuPosition = GetMenuPosition(client, TalentInfo[0]);
					for (int ii = 1; ii <= MaxClients; ii++) {
						if (!IsLegitimateClient(ii) || IsFakeClient(ii)) continue;
						DrawSpecialAmmoTarget(ii, _, _, auraMenuPosition, EntityPos[0], EntityPos[1], EntityPos[2], fSpecialAmmoInterval, client, TalentInfo[0], drawtarget);
					}
				}
			}
			else {
				EntityPos[0] = SpecialAmmoData.Get(i, 0);
				EntityPos[1] = SpecialAmmoData.Get(i, 1);
				EntityPos[2] = SpecialAmmoData.Get(i, 2);
			}
			f_TimeRemaining = SpecialAmmoData.Get(i, 8);
			f_TimeRemaining -= fSpecialAmmoInterval;
			if (f_TimeRemaining <= 0.0) {
				SpecialAmmoData.Erase(i);
				if (IsValidEntity(WorldEnt)) AcceptEntityInput(WorldEnt, "Kill");
				continue;
			}
			// Anything that was changed needs to be reinserted.
			SpecialAmmoData.Set(i, f_TimeRemaining, 8);
			if (iStrengthOnSpawnIsStrength != 1) SpecialAmmoData.Set(i, GetSpecialAmmoStrength(client, TalentInfo[0], 1), 10);

			if (dataAmmoType == 1) CreateAmmoExplosion(client, EntityPos[0], EntityPos[1], EntityPos[2]);
			if (dataAmmoType >= 1 && dataAmmoType <= 3) {
				for (int zombie = 0; zombie < CommonInfected.Length; zombie++) {
					ent = CommonInfected.Get(zombie);
					if (IsClientInRangeSpecialAmmo(ent, DataAmmoEffect, _, i) == -2.0) {
						AmmoStrength			= (IsClientInRangeSpecialAmmo(ent, DataAmmoEffect, false, _, bulletStrength * 1.0)) * bulletStrength;
						if (AmmoStrength <= 0.0) continue;

						if (dataAmmoType == 1) ExplosiveAmmo(ent, RoundToCeil(AmmoStrength), client);
						else if (dataAmmoType == 2) LeechAmmo(ent, RoundToCeil(AmmoStrength), client);
						else if (dataAmmoType == 3) DoBurn(client, ent, RoundToCeil(AmmoStrength));
					}
				}
			}
		}
	}
	return Plugin_Continue;
}
/*public Action:Timer_SpecialAmmoData(Handle timer) {

	if (!b_IsActiveRound) {

		Handle SpecialAmmoData.Clear();
		return Plugin_Stop;
	}

	String:text[512];
	String:result[7][512];
	String:t_pos[3][512];
	Float:EntityPos[3];
	//new Float:TargetPos[3];
	String:TalentInfo[4][512];
	client = 0;
	Float:f_TimeRemaining = 0.0;
	//Float:f_Interval = 0.0;
	//Float:f_Cooldown = 0.0;
	//new size = SpecialAmmoData.Length;
	WorldEnt = -1;
	ent = -1;
	drawtarget = -1;
	//new ammotarget = -1;
	String:DataAmmoEffect[10];
	//LogMessage("Ammo size: %d", size);

	Float:AmmoStrength = 0.0;
	//ThePosition = -1;
	//Float:TheStrength = -1.0;
	//bool:hastargetfound = false;
	for (new i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClientAlive(i)) CheckActiveAbility(i, -1, _, _, true);	// draws effects for any active ability.
	}
	auraMenuPosition = 0;

	for (new i = 0; i < Handle SpecialAmmoData.Length; i++) {

		AmmoStrength = 0.0;

		Format(DataAmmoEffect, sizeof(DataAmmoEffect), "0");	// reset it after each go.

		//hastargetfound = false;

		Handle SpecialAmmoData.GetString(i, text, sizeof(text));
		//LogMessage("Original: %s", text);
		ExplodeString(text, "}", result, 7, 512);

		WorldEnt = StringToInt(result[4]);

		client = FindClientWithAuthString(result[2]);
		//f_Interval -= 0.01;

		if (!IsLegitimateClientAlive(client) || GetClientTeam(client) != TEAM_SURVIVOR) {

			Handle SpecialAmmoData.Erase(i);
			//if (i > 0) i--;
			//size = SpecialAmmoData.Length;
			//if (IsLegitimateClientAlive(client) && GetClientTeam(client) == TEAM_SURVIVOR) CheckActiveAmmoCooldown(client, TalentInfo[0], true);// should the cooldown start when the first bullet expires, or when the first bullets first cooldown(interval) occurs? need to calculate. is it too spammy?
			if (IsValidEntity(WorldEnt)) AcceptEntityInput(WorldEnt, "Kill");
			continue;
		}
		drawtarget = StringToInt(result[6]);

		ExplodeString(result[1], "{", TalentInfo, 4, 512);

		if (IsSpellAnAura(client, TalentInfo[0])) {
			GetClientAbsOrigin(client, EntityPos);
			// auras follow players and are drawn on every tick. They can be VERY performance-intensive if higher tickrates are used (lower intervals / tick)
			auraMenuPosition = GetMenuPosition(client, TalentInfo[0]);
			for (new ii = 1; ii <= MaxClients; ii++) {
				if (!IsLegitimateClient(ii) || IsFakeClient(ii)) continue;
				DrawSpecialAmmoTarget(ii, _, _, auraMenuPosition, EntityPos[0], EntityPos[1], EntityPos[2], fSpecialAmmoInterval, client, TalentInfo[0], drawtarget);
			}
		}
		else {
			ExplodeString(result[0], " ", t_pos, 3, 512);
			EntityPos[0] = StringToFloat(t_pos[0]);
			EntityPos[1] = StringToFloat(t_pos[1]);
			EntityPos[2] = StringToFloat(t_pos[2]);
		}
		// TalentInfo[0] = TalentName of ammo.
		// TalentInfo[1] = Talent Strength (so use StringToInt)
		// TalentInfo[2] = Talent Damage
		// TalentInfo[3] = Talent Interval

		//f_Interval = StringToFloat(TalentInfo[3]);

		f_TimeRemaining = StringToFloat(result[3]) - fSpecialAmmoInterval;
		//f_TimeRemaining -= 0.01;

		//f_Cooldown = StringToFloat(result[5]);
		GetSpecialAmmoEffect(DataAmmoEffect, sizeof(DataAmmoEffect), client, TalentInfo[0]);
		//Format(DataAmmoEffect, sizeof(DataAmmoEffect), "%s", GetSpecialAmmoEffect(client, TalentInfo[0]));

		//f_Interval = f_TimeRemaining;
		//if (f_Interval > f_TimeRemaining) f_Interval = f_TimeRemaining;
		if (f_TimeRemaining > 0.0) {

			//ThePosition = GetTalentPosition(client, TalentInfo[0]);
			//TheStrength = GetSpecialAmmoStrength(client, TalentInfo[0], 1);
			
			if (IsClientInRangeSpecialAmmo(client, DataAmmoEffect, _, i) == -2.0) {

				AmmoStrength			= (IsClientInRangeSpecialAmmo(client, DataAmmoEffect, false, _, StringToInt(TalentInfo[2]) * 1.0));
				AmmoStrength			*= StringToInt(TalentInfo[2]);
				if (AmmoStrength > 0.0) {

					//if (StrContains(DataAmmoEffect, "b", true) == -1) AmmoStrength *= StringToInt(TalentInfo[2]);
					//CreateCooldown(client, ThePosition, TheStrength);

					if (StrContains(DataAmmoEffect, "b", true) != -1) BeanBagAmmo(client, AmmoStrength, client);
					else if (StrContains(DataAmmoEffect, "a", true) != -1 && !HasAdrenaline(client)) SetAdrenalineState(client, f_TimeRemaining);
					else if (StrContains(DataAmmoEffect, "x", true) != -1) ExplosiveAmmo(client, RoundToCeil(AmmoStrength), client);
					else if (StrContains(DataAmmoEffect, "H", true) != -1) {

						//LogToFile(LogPathDirectory, "Healing ammo %N for %3.3f (%d)", client, AmmoStrength, GetMaximumHealth(client));

						HealingAmmo(client, RoundToCeil(AmmoStrength), client);
					}
					else if (StrContains(DataAmmoEffect, "F", true) != -1) {

						if (ISEXPLODE[client] == INVALID_HANDLE) CreateAndAttachFlame(client, RoundToCeil(AmmoStrength), f_TimeRemaining, f_TimeRemaining);
	 					else if (ISEXPLODE[client] != INVALID_HANDLE) CreateAndAttachFlame(client, RoundToCeil(AmmoStrength * TheScorchMult), f_TimeRemaining, f_TimeRemaining);
					}
					else if (StrContains(DataAmmoEffect, "B", true) != -1 && !ISBILED[client]) {
						SDKCall(g_hCallVomitOnPlayer, client, client, true);
						CreateTimer(15.0, Timer_RemoveBileStatus, client, TIMER_FLAG_NO_MAPCHANGE);
						ISBILED[client] = true;
					}
				}
			}
			for (new ammotarget = 1; ammotarget <= MaxClients; ammotarget++) {

				if (ammotarget != client && IsLegitimateClientAlive(ammotarget) && IsClientInRangeSpecialAmmo(ammotarget, DataAmmoEffect, _, i) == -2.0) {

					AmmoStrength			= (IsClientInRangeSpecialAmmo(ammotarget, DataAmmoEffect, false, _, StringToInt(TalentInfo[2]) * 1.0));
					AmmoStrength			*= StringToInt(TalentInfo[2]);

					if (AmmoStrength <= 0.0) continue;

					//CreateCooldown(ammotarget, ThePosition, TheStrength);
					//if (StrContains(DataAmmoEffect, "b", true) == -1 && StrContains(DataAmmoEffect, "W", true) == -1) AmmoStrength *= StringToInt(TalentInfo[2]);

					if (StrContains(DataAmmoEffect, "b", true) != -1) BeanBagAmmo(ammotarget, AmmoStrength, client);
					else if ((GetClientTeam(ammotarget) == TEAM_SURVIVOR || IsSurvivorBot(ammotarget)) && StrContains(DataAmmoEffect, "a", true) != -1 && !HasAdrenaline(ammotarget)) SetAdrenalineState(ammotarget, f_TimeRemaining);
					else if (GetClientTeam(ammotarget) == TEAM_INFECTED && StrContains(DataAmmoEffect, "x", true) != -1) ExplosiveAmmo(ammotarget, RoundToCeil(AmmoStrength), client);
					else if ((GetClientTeam(ammotarget) == TEAM_SURVIVOR || IsSurvivorBot(ammotarget)) && StrContains(DataAmmoEffect, "H", true) != -1) HealingAmmo(ammotarget, RoundToCeil(AmmoStrength), client);
					else if (GetClientTeam(ammotarget) == TEAM_INFECTED && StrContains(DataAmmoEffect, "h", true) != -1) LeechAmmo(ammotarget, RoundToCeil(AmmoStrength), client);
					else if (StrContains(DataAmmoEffect, "F", true) != -1) {

						DoBurn(client, ammotarget, RoundToCeil(AmmoStrength));
					}
					else if (StrContains(DataAmmoEffect, "B", true) != -1 && !ISBILED[ammotarget]) {
						SDKCall(g_hCallVomitOnPlayer, ammotarget, client, true);
						CreateTimer(15.0, Timer_RemoveBileStatus, ammotarget, TIMER_FLAG_NO_MAPCHANGE);
						ISBILED[ammotarget] = true;
					}
					else if (StrContains(DataAmmoEffect, "C", true) != -1 && AmmoStrength <= 0.0) {
				
						if (IsClientStatusEffect(ammotarget, Handle EntityOnFire)) {

							TransferStatusEffect(ammotarget, Handle EntityOnFire, client);
						}
					}
					//hastargetfound = true;
					//break;
				}
			}
			if (StrContains(DataAmmoEffect, "x", true) != -1) {

				CreateAmmoExplosion(client, EntityPos[0], EntityPos[1], EntityPos[2]);
				//continue;
			}
			if (StrContains(DataAmmoEffect, "x", true) != -1 ||
				StrContains(DataAmmoEffect, "h", true) != -1 ||
				StrContains(DataAmmoEffect, "F", true) != -1) {

				for (new zombie = 0; zombie < Handle CommonInfected.Length; zombie++) {

					ent = Handle CommonInfected.Get(zombie);
					//if (!IsSpecialCommon(ent)) continue;
					if (!IsCommonInfected(ent)) continue;	// || IsClientInRangeSpecialAmmo(ent, DataAmmoEffect, _, i) != -2.0) continue;
					if (IsClientInRangeSpecialAmmo(ent, DataAmmoEffect, _, i) == -2.0) AmmoStrength			= (IsClientInRangeSpecialAmmo(ent, DataAmmoEffect, false, _, StringToInt(TalentInfo[2]) * 1.0)) * StringToInt(TalentInfo[2]);
					else continue;
					AmmoStrength			*= StringToInt(TalentInfo[2]);
					if (AmmoStrength <= 0.0) continue;

					if (StrContains(DataAmmoEffect, "x", true) != -1) {

						ExplosiveAmmo(ent, RoundToCeil(AmmoStrength), client);
						//break;
					}
					if (StrContains(DataAmmoEffect, "h", true) != -1) {

						LeechAmmo(ent, RoundToCeil(AmmoStrength), client);
						//break;
					}
					if (StrContains(DataAmmoEffect, "F", true) != -1) {

						DoBurn(client, ent, RoundToCeil(AmmoStrength));

						//CreateAndAttachFlame(ent, RoundToCeil(AmmoStrength), f_TimeRemaining, f_Interval);
						//break;
					}
				}
			}
		}
		else {

			Handle SpecialAmmoData.Erase(i);
			if (IsValidEntity(WorldEnt)) AcceptEntityInput(WorldEnt, "Kill");
			continue;
		}

		for (new ii = 1; ii <= MaxClients; ii++) {

			if (IsLegitimateClientAlive(ii) && strlen(MyAmmoEffects[ii]) > 0) Format(MyAmmoEffects[ii], sizeof(MyAmmoEffects[]), "");
		}

		//Format(text, sizeof(text), "%3.3f %3.3f %3.3f}%s{%d{%d{%3.2f}%s}%3.2f}%d}%3.2f}%d", EntityPos[0], EntityPos[1], EntityPos[2], TalentInfo[0], GetTalentStrength(client, TalentInfo[0]), StringToInt(TalentInfo[2]), f_Interval, result[2], f_TimeRemaining, WorldEnt, f_Cooldown, drawtarget);
		Format(text, sizeof(text), "%3.3f %3.3f %3.3f}%s{%d{%d{%3.2f}%s}%3.2f}%d}%3.2f}%d", EntityPos[0], EntityPos[1], EntityPos[2], TalentInfo[0], GetTalentStrength(client, TalentInfo[0]), StringToInt(TalentInfo[2]), f_TimeRemaining, result[2], f_TimeRemaining, WorldEnt, f_TimeRemaining, drawtarget);
		Handle SpecialAmmoData.SetString(i, text);
		//LogMessage(text);
		//size = Handle SpecialAmmoData.Length;
	}
	return Plugin_Continue;
}*/

public Action Timer_StartPlayerTimers(Handle timer) {
	if (!b_IsActiveRound) return Plugin_Stop;
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i) || GetClientTeam(i) != TEAM_SURVIVOR || bTimersRunning[i] || !b_IsLoaded[i]) continue;
		bTimersRunning[i] = true;
		if (GetClientTeam(i) == TEAM_SURVIVOR) {
			CreateTimer(fSpecialAmmoInterval, Timer_AmmoActiveTimer, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(fEffectOverTimeInterval, Timer_EffectOverTime, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(fSpecialAmmoInterval, Timer_SpecialAmmoData, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			//CreateTimer(fDrawAbilityInterval, Timer_DrawAbilities, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(fDrawHudInterval, Timer_ShowHUD, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	return Plugin_Continue;
}

public Action Timer_AmmoActiveTimer(Handle timer, any client) {

	if (!b_IsActiveRound || !IsLegitimateClient(client) || !bTimersRunning[client]) {
		PlayerActiveAmmo[client].Clear();
		PlayActiveAbilities[client].Clear();
		return Plugin_Stop;
	}
	//SortThreatMeter();
	char result[64];
	static int currTalentStrength = 0;
	float talentTimeRemaining = 0.0;
	static int triggerRequirementsAreMet = 0;
	if (bJumpTime[client]) JumpTime[client] += fSpecialAmmoInterval;
	if (fOnFireDebuff[client] > 0.0) {
		fOnFireDebuff[client] -= fSpecialAmmoInterval;
		if (fOnFireDebuff[client] <= 0.0) fOnFireDebuff[client] = -1.0;
	}
	if (!IsFakeClient(client)) {
		if (!bIsHideThreat[client]) SendPanelToClientAndClose(ShowThreatMenu(client), client, ShowThreatMenu_Init, 1); //ShowThreatMenu(i);
		else if (IsPlayerAlive(client) && DisplayActionBar[client]) ShowActionBar(client);
	}
	// timer for the cooldowns of anything on the action bar (ammos, abilities)
	if (PlayerActiveAmmo[client].Length > 0) {
		for (int i = 0; i < PlayerActiveAmmo[client].Length; i++) {
			talentTimeRemaining = PlayerActiveAmmo[client].Get(i, 1);
			if (talentTimeRemaining - fSpecialAmmoInterval <= 0.0) {
				PlayerActiveAmmo[client].Erase(i);
				continue;
			}
			PlayerActiveAmmo[client].Set(i, talentTimeRemaining - fSpecialAmmoInterval, 1);
		}
	}
	if (PlayActiveAbilities[client].Length > 0) {
		for (int i = 0; i < PlayActiveAbilities[client].Length; i++) {
			GetTalentNameAtMenuPosition(client, PlayActiveAbilities[client].Get(i, 0), result, sizeof(result));
			currTalentStrength = GetTalentStrength(client, result);
			if (currTalentStrength < 1) {
				PlayActiveAbilities[client].Erase(i);
				continue;
			}
			talentTimeRemaining = PlayActiveAbilities[client].Get(i, 1);
			triggerRequirementsAreMet = PlayActiveAbilities[client].Get(i, 2);
			if (triggerRequirementsAreMet == 1 && !IsAbilityActive(client, result) && IsAbilityActive(client, result, fSpecialAmmoInterval)) {
				CallAbilityCooldownAbilityTrigger(client, result, true);
			}
			if (talentTimeRemaining - fSpecialAmmoInterval <= 0.0) {
				if (triggerRequirementsAreMet == 1) CallAbilityCooldownAbilityTrigger(client, result);
				PlayActiveAbilities[client].Erase(i);
			}
			else {
				PlayActiveAbilities[client].Set(i, talentTimeRemaining - fSpecialAmmoInterval, 1);
			}
		}
	}
	return Plugin_Continue;
}

stock bool BotsOnSurvivorTeam() {
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i) || !IsFakeClient(i) || GetClientTeam(i) != TEAM_SURVIVOR) continue;
		return true;
	}
	return false;
}

stock bool SetActiveAbilityConditionsMet(int client, char[] TalentName, bool GetIfConditionIsAlreadyMet = false) {

	int size = PlayActiveAbilities[client].Length;
	int areConditionsMet = 0;
	//decl String:text[64];
	char result[3][64];
	for (int i = 0; i < size; i++) {
		GetTalentNameAtMenuPosition(client, PlayActiveAbilities[client].Get(i, 0), result[0], sizeof(result[]));
		if (!StrEqual(result[0], TalentName)) continue;
		areConditionsMet = PlayActiveAbilities[client].Get(i, 2);
		if (GetIfConditionIsAlreadyMet) {
			if (areConditionsMet == 1) return true;
			return false;
		}
		if (areConditionsMet == 1) return true;
		PlayActiveAbilities[client].Set(i, 1, 2);	// sets conditions met to true.
		return true;
	}
	return false;
}

stock bool IsSpellAnAura(int client, char[] TalentName) {
	int pos = GetTalentPosition(client, TalentName);
	IsSpellAnAuraKeys[client]	= a_Menu_Talents.Get(pos, 0);
	IsSpellAnAuraValues[client] = a_Menu_Talents.Get(pos, 1);
	return (GetKeyValueIntAtPos(IsSpellAnAuraValues[client], IS_AURA_INSTEAD) == 1) ? true : false;
}

stock bool IsTriggerCooldownEffect(int client, int target, char[] TalentName, bool isActivePeriodEndInstead = false) {
	int pos = GetTalentPosition(client, TalentName);
	if (pos == -1) return false;// log an error? can this statement EVEN HAPPEN?
	if (GetTalentStrength(client, TalentName) < 1) return false;
	//CooldownEffectTriggerKeys[client]	= a_Menu_Talents.Get(pos, 0);
	CooldownEffectTriggerValues[client] = a_Menu_Talents.Get(pos, 1);

	char CooldownEffect[64];
	if (!isActivePeriodEndInstead) CooldownEffectTriggerValues[client].GetString(EFFECT_COOLDOWN_TRIGGER, CooldownEffect, sizeof(CooldownEffect));
	else CooldownEffectTriggerValues[client].GetString(EFFECT_INACTIVE_TRIGGER, CooldownEffect, sizeof(CooldownEffect));
	if (StrEqual(CooldownEffect, "-1")) return false;
	// We could theoretically 'chain' multiple effect over times with each other using this...
	// Or we could have one talent split up into multiple "cycles" and each node unlocks an additional cycle.
	GetAbilityStrengthByTrigger(client, target, CooldownEffect);
	return true;
}

stock float GetEffectOverTimeStrength(int client, char[] searchEffect) {
	float talentStrength = 0.0;
	char result[64];
	for (int pos = 0; pos < PlayerEffectOverTimeEffects[client].Length; pos++) {
		PlayerEffectOverTimeEffects[client].GetString(pos, result, sizeof(result));
		if (!StrEqual(searchEffect, result)) continue;
		//talentStrength += StringToFloat(result[6]);
		talentStrength += PlayerEffectOverTime[client].Get(pos, 5);
	}
	return talentStrength;
}

public Action Timer_EffectOverTime(Handle timer, any client) {
	if (!b_IsActiveRound || !IsLegitimateClient(client) || !bTimersRunning[client]) {
		PlayerEffectOverTime[client].Clear();
		PlayerEffectOverTimeEffects[client].Clear();
		return Plugin_Stop;
	}
	char periodicActivation[64];
	//String:result[7][64];
	float activeTime = 0.0;
	float cooldownTime = 0.0;
	static int damage = 0;

	char secondaryEffects[64];
	char secondaryTrigger[64];
	static int target = 0;
	float talentStrength = 0.0;
	char AoERange[10];
	char AoERange2[10];
	char TalentName[64];
	char primaryEffects[64];
	if (GetClientTeam(client) == TEAM_SURVIVOR && L4D2_GetInfectedAttacker(client) != -1) {
		// when the requirement is met for the first time in a reactive talent or ability's active period, we
		// trigger its reactive perk; reactive perks can only fire ONE time!
		if (GetAbilityMultiplier(client, "parry", 5) == -2.0) {
			StaggerPlayer(client, GetAnyPlayerNotMe(client));
		}
	}
	if (PlayerEffectOverTime[client].Length < 1) return Plugin_Continue;
	for (int pos = 0; pos < PlayerEffectOverTime[client].Length; pos++) {
		GetTalentNameAtMenuPosition(client, PlayerEffectOverTime[client].Get(pos, 0), TalentName, sizeof(TalentName));
		activeTime		= PlayerEffectOverTime[client].Get(pos, 1);
		cooldownTime	= PlayerEffectOverTime[client].Get(pos, 2);
		damage			= PlayerEffectOverTime[client].Get(pos, 3);
		target			= PlayerEffectOverTime[client].Get(pos, 4);
		talentStrength	= PlayerEffectOverTime[client].Get(pos, 5);
		PlayerEffectOverTimeEffects[client].GetString(pos, primaryEffects, sizeof(primaryEffects));

		//PlayerEffectOverTime[client].GetString(pos, result[0], sizeof(result[]));
		//ExplodeString(result[0], ":", result, 7, 64);

		/*activeTime		= StringToFloat(result[1]);
		cooldownTime	= StringToFloat(result[2]);
		damage			= StringToInt(result[3]);
		target			= StringToInt(result[5]);
		talentStrength	= StringToFloat(result[6]);*/
		// if the cooldown is about to expire, we trigger the "cooldown trigger?" ability trigger.
		if (activeTime <= fEffectOverTimeInterval && cooldownTime <= fEffectOverTimeInterval) {
			IsTriggerCooldownEffect(client, target, TalentName);
			PlayerEffectOverTime[client].Erase(pos);
			PlayerEffectOverTimeEffects[client].Erase(pos);
			continue;
		}
		if (activeTime <= fEffectOverTimeInterval) {
			// if the active period is ending, we trigger the "inactive trigger?" ability trigger.
			if (activeTime > 0.0) IsTriggerCooldownEffect(client, target, TalentName, true);
			activeTime = 0.0;
		}
		else {
			activeTime -= fEffectOverTimeInterval;
			GetTalentKeyValue(client, TalentName, EFFECT_ACTIVATE_PER_TICK, periodicActivation, sizeof(periodicActivation));
			if (StringToInt(periodicActivation) == 1) {
				GetTalentKeyValue(client, TalentName, EFFECT_SECONDARY_EPT_ONLY, periodicActivation, sizeof(periodicActivation));
				//GetTalentKeyValue(i, result[0], result[4], effects, sizeof(effects));
				GetTalentKeyValue(client, TalentName, PRIMARY_AOE, AoERange, sizeof(AoERange));
				GetTalentKeyValue(client, TalentName, SECONDARY_AOE, AoERange2, sizeof(AoERange2));
				GetTalentKeyValue(client, TalentName, SECONDARY_EFFECTS, secondaryEffects, sizeof(secondaryEffects));
				GetTalentKeyValue(client, TalentName, SECONDARY_ABILITY_TRIGGER, secondaryTrigger, sizeof(secondaryTrigger));
				if (StringToInt(periodicActivation) == 1) ActivateAbilityEx(client, target, damage, secondaryEffects, talentStrength, 0.0, _, _, _, StringToFloat(AoERange));
				else ActivateAbilityEx(client, target, damage, primaryEffects, talentStrength, 0.0, _, _, _, StringToFloat(AoERange), secondaryEffects, StringToFloat(AoERange2), _, secondaryTrigger);

				if (!StrEqual(secondaryTrigger, "-1")) GetAbilityStrengthByTrigger(client, target, secondaryTrigger, _, damage);
			}
		}
		if (cooldownTime <= fEffectOverTimeInterval) cooldownTime = 0.0;
		else cooldownTime -= fEffectOverTimeInterval;
		PlayerEffectOverTime[client].Set(pos, activeTime, 1);
		PlayerEffectOverTime[client].Set(pos, cooldownTime, 2);

		//Format(result[0], sizeof(result[]), "%s:%3.3f:%3.3f", result[0], activeTime, cooldownTime);
		//Format(result[0], sizeof(result[]), "%s:%3.2f:%3.2f:%d:%s:%d:%3.3f", result[0], activeTime, cooldownTime, damage, result[4], target, talentStrength);
		//PlayerEffectOverTime[client].SetString(pos, result[0]);
	}
	return Plugin_Continue;
}

stock bool AllowEffectOverTimeToContinue(int client, ArrayList Values, char[] TalentName, int damage, char[] effects = "-1", int target = 0, float fTalentStrength = 0.0) {
	if (GetKeyValueIntAtPos(Values, TALENT_IS_EFFECT_OVER_TIME) != 1) return true;
	float effectGetActiveTime		= CheckEffectOverTimeCooldown(client, TalentName, EFFECTOVERTIME_GETACTIVETIME);
	bool isEffectCoolingDownStill	= (effectGetActiveTime == 0.0 && CheckEffectOverTimeCooldown(client, TalentName, EFFECTOVERTIME_GETCOOLDOWN) != -1.0) ? true : false;
	if (isEffectCoolingDownStill) return false;	// not active, on cooldown.
	if (effectGetActiveTime > 0.0) return true; // is active.
	/*	if the effect is not active, and is not on cooldown, we check to see if this event triggers it or not.
		if it does, we activate it.
		return false in either event, for consistency with EoT's that don't share effect and ability triggers.
	*/
	CheckEffectOverTimeCooldown(client, TalentName, EFFECTOVERTIME_ACTIVATETALENT, damage, effects, target, fTalentStrength);
	return false;
}

stock void FormatEffectOverTimeBuffs(int client, char[] eBar, int eBarSize, int pos = -1) {
	int size = a_Menu_Talents.Length;
	char TalentName[64];
	char text[64];
	int count = 0;
	int startpos = 0;
	if (pos > 0) startpos = pos;
	for (int i = startpos; i < size; i++) {
		//FormatEffectOverTimeKeys[client] = a_Menu_Talents.Get(i, 0);
		FormatEffectOverTimeValues[client] = a_Menu_Talents.Get(i, 1);
		if (GetKeyValueIntAtPos(FormatEffectOverTimeValues[client], TALENT_IS_EFFECT_OVER_TIME) != 1) {
			if (pos == -1) continue;
			Format(eBar, eBarSize, "-1");
			break;
		}

		FormatEffectOverTimeSection[client] = a_Menu_Talents.Get(i, 2);
		FormatEffectOverTimeSection[client].GetString(0, TalentName, sizeof(TalentName));
		if (GetTalentStrength(client, TalentName) < 1) continue;

		if (CheckEffectOverTimeCooldown(client, TalentName, EFFECTOVERTIME_GETACTIVETIME) > 0.0) {
			FormatEffectOverTimeValues[client].GetString(HUD_TEXT_BUFF_EFFECT_OVER_TIME, TalentName, sizeof(TalentName));
			if (StrEqual(TalentName, "-1")) continue;	// buffs with no buff bar text aren't added.
			if (count == 0) Format(text, sizeof(text), "[%s]", TalentName);
			else Format(text, sizeof(text), "%s[%s]", text, TalentName);
			count++;
		}
		if (pos != -1) {
			Format(eBar, eBarSize, "%s", text);
			break;
		}
	}
	if (pos == -1 && count > 0) Format(eBar, eBarSize, "%s%s", eBar, text);
}
																		// 0 to insert, 1 to get the active time, 2 to get the cooldown
stock float CheckEffectOverTimeCooldown(int client, char[] TalentName, int cooldownSwitch = 0, int damage = 0, char[] effects = "-1", int target = 0, float fTalentStrength = 0.0) {
	if (!IsLegitimateClient(client)) return -1.0;
	// return the active time remaining for the talent.
	if (cooldownSwitch == EFFECTOVERTIME_GETACTIVETIME) return EffectOverTimeActiveStatus(client, TalentName);
	
	// we need to check if there's currently a cooldown active on this talent.
	// if we are specifically-requesting the cooldown, or if the talent is on cooldown, we return the cooldown remaining.
	float effectOverTimeCooldown = EffectOverTimeActiveStatus(client, TalentName, _, true);
	if (cooldownSwitch == EFFECTOVERTIME_GETCOOLDOWN || effectOverTimeCooldown > 0.0) return effectOverTimeCooldown;
	// If the talent is not active, not on cooldown, and we left the switch at default, we activate the talent.
	return EffectOverTimeActiveStatus(client, TalentName, true, _, damage, effects, target, fTalentStrength);
}

stock float EffectOverTimeActiveStatus(int client, char[] TalentName, bool activateTalent = false, bool checkIfCooldownIsActive = false, int damage = 0, char[] effects = "-1", int target = 0, float fTalentStrength = 0.0) {
	//decl String:result[7][64];
	char text[64];
	int size = PlayerEffectOverTime[client].Length;
	if (checkIfCooldownIsActive) {
		for (int i = 0; i < size; i++) {	// if we want to know the cooldown time (if any)
			//Handle PlayerEffectOverTime[client].GetString(i, result[0], sizeof(result[]));
			//ExplodeString(result[0], ":", result, 7, 64);
			GetTalentNameAtMenuPosition(client, PlayerEffectOverTime[client].Get(i, 0), text, sizeof(text));
			if (!StrEqual(TalentName, text)) continue;
			return PlayerEffectOverTime[client].Get(i, 2);
			//if (StrEqual(result[0], TalentName, false)) return StringToFloat(result[2]);
		}
		return -1.0;	// If no cooldown is active we return -1.0;
	}
	// Check if the effect over time is currently active.
	for (int i = 0; i < size; i++) {
		//Handle PlayerEffectOverTime[client].GetString(i, result[0], sizeof(result[]));
		//ExplodeString(result[0], ":", result, 7, 64);
		// return active time remaining on the talent.
		GetTalentNameAtMenuPosition(client, PlayerEffectOverTime[client].Get(i, 0), text, sizeof(text));
		if (!StrEqual(TalentName, text)) continue;
		return PlayerEffectOverTime[client].Get(i, 1);
		//if (StrEqual(result[0], TalentName, false)) return StringToFloat(result[1]);
	}
	// if the talent isn't on cooldown, isn't active, and we want to activate it.
	if (activateTalent) {
		// GetTalentInfo line 2868 rpg_menu.sp
		float effectOverTimeCooldown	= GetTalentInfo(client, CheckEffectOverTimeValues[client], 3, _, TalentName);
		float effectActiveTime			= GetTalentInfo(client, CheckEffectOverTimeValues[client], 2, _, TalentName); 

		size = PlayerEffectOverTime[client].Length;
		PlayerEffectOverTime[client].Resize(size + 1);
		PlayerEffectOverTimeEffects[client].Resize(size + 1);

		PlayerEffectOverTime[client].Set(size, GetMenuPosition(client, TalentName), 0);
		PlayerEffectOverTime[client].Set(size, effectActiveTime, 1);
		PlayerEffectOverTime[client].Set(size, effectOverTimeCooldown, 2);
		PlayerEffectOverTime[client].Set(size, damage, 3);
		PlayerEffectOverTime[client].Set(size, target, 4);
		PlayerEffectOverTime[client].Set(size, fTalentStrength, 5);
		//Format(result[0], sizeof(result[]), "%s:%3.2f:%3.2f:%d:%s:%d:%3.3f", TalentName, effectActiveTime, effectOverTimeCooldown, damage, effects, target, fTalentStrength);
		//PlayerEffectOverTime[client].PushString(result[0]);
		PlayerEffectOverTimeEffects[client].SetString(size, effects);
		return 2.0;	// return 2 if talent is successfully activated.
	}
	return 0.0;	// if the talent isn't on cooldown, isn't active, and we aren't activating it (ie. we are checking its status.)
}

stock int CheckActiveAmmoCooldown(int client, char[] TalentName, bool bIsCreateCooldown=false) {

	/*

		The original function is below. Rewritten after adding new functionality to function as originally intended.
	*/
	if (!IsLegitimateClient(client)) return -1;
	if (IsAmmoActive(client, TalentName)) return 2;	// even if bIsCreateCooldown, if it is on cooldown already, we don't create another cooldown.
	else if (bIsCreateCooldown) IsAmmoActive(client, TalentName, GetSpecialAmmoStrength(client, TalentName, 1));
	else return 1;
	return 0;
}

stock bool IsAmmoActive(int client, char[] TalentName, float f_Delay=0.0, bool IsActiveAbility = false) {
	char result[2][64];
	int pos = -1;
	int size = -1;
	if (f_Delay == 0.0) {
		size = PlayerActiveAmmo[client].Length;
		if (IsActiveAbility) size = PlayActiveAbilities[client].Length;
		for (int i = 0; i < size; i++) {
			if (!IsActiveAbility) {
				GetTalentNameAtMenuPosition(client, PlayerActiveAmmo[client].Get(i, 0), result[0], sizeof(result[]));
			}
			else {
				GetTalentNameAtMenuPosition(client, PlayActiveAbilities[client].Get(i, 0), result[0], sizeof(result[]));
			}
			if (StrEqual(result[0], TalentName, false)) return true;

		}
		return false;
	}
	else {
		pos = GetMenuPosition(client, TalentName);
		if (!IsActiveAbility) {
			size = PlayerActiveAmmo[client].Length;
			PlayerActiveAmmo[client].Resize(size + 1);
			PlayerActiveAmmo[client].Set(size, pos, 0);	// storing the position of the talent instead of the talent so we don't have to store a string.
			PlayerActiveAmmo[client].Set(size, f_Delay, 1);
		}
		else {
			size = PlayActiveAbilities[client].Length;
			PlayActiveAbilities[client].Resize(size + 1);
			PlayActiveAbilities[client].Set(size, pos, 0);
			PlayActiveAbilities[client].Set(size, f_Delay, 1);
			PlayActiveAbilities[client].Set(size, GetIfTriggerRequirementsMetAlways(client, TalentName), 2);
			PlayActiveAbilities[client].Set(size, 0.0, 3);	// so that all abilities active/passive visual effects show on the first tick.
		}
	}
	return false;
}

stock float GetAmmoCooldownTime(int client, char[] TalentName, bool IsActiveTimeInstead = false) {

	//Push to an array.
	char result[3][64];
	int size = PlayerActiveAmmo[client].Length;
	float timeRemaining = 0.0;
	if (IsActiveTimeInstead) size = PlayActiveAbilities[client].Length;
	for (int i = 0; i < size; i++) {

		if (!IsActiveTimeInstead) {
			GetTalentNameAtMenuPosition(client, PlayerActiveAmmo[client].Get(i, 0), result[0], sizeof(result[]));
			timeRemaining = PlayerActiveAmmo[client].Get(i, 1);
		}
		else {
			GetTalentNameAtMenuPosition(client, PlayActiveAbilities[client].Get(i, 0), result[0], sizeof(result[]));
			timeRemaining = PlayActiveAbilities[client].Get(i, 1);
		}
		if (StrEqual(result[0], TalentName, false)) return timeRemaining;
	}
	return -1.0;
}

stock float GetAbilityValue(int client, char[] TalentName, int valuePos) {

	char TheTalent[64];

	int size = a_Menu_Talents.Length;
	for (int i = 0; i < size; i++) {
		//AbilityConfigKeys[client]		= a_Menu_Talents.Get(i, 0);
		AbilityConfigSection[client]	= a_Menu_Talents.Get(i, 2);
		AbilityConfigSection[client].GetString(0, TheTalent, sizeof(TheTalent));
		if (!StrEqual(TheTalent, TalentName)) continue;
		AbilityConfigValues[client]		= a_Menu_Talents.Get(i, 1);
		return GetKeyValueFloatAtPos(AbilityConfigValues[client], valuePos);
	}
	return -1.0;
}

stock bool IsAbilityInstant(int client, char[] TalentName) {

	if (GetAbilityValue(client, TalentName, ABILITY_ACTIVE_TIME) > 0.0) return false;
	return true;
}

stock bool CallAbilityCooldownAbilityTrigger(int client, char[] TalentName, bool activePeriodNotCooldownPeriodEnds = false) {
	char text[64];
	int size = a_Menu_Talents.Length;
	for (int i = 0; i < size; i++) {
		CallAbilityCooldownTriggerSection[client]	= a_Menu_Talents.Get(i, 2);
		CallAbilityCooldownTriggerSection[client].GetString(0, text, sizeof(text));
		if (!StrEqual(text, TalentName)) continue;

		CallAbilityCooldownTriggerKeys[client]		= a_Menu_Talents.Get(i, 0);
		CallAbilityCooldownTriggerValues[client]	= a_Menu_Talents.Get(i, 1);
		if (activePeriodNotCooldownPeriodEnds) CallAbilityCooldownTriggerValues[client].GetString(ABILITY_ACTIVE_END_ABILITY_TRIGGER, text, sizeof(text));
		else CallAbilityCooldownTriggerValues[client].GetString(ABILITY_COOLDOWN_END_TRIGGER, text, sizeof(text));
		if (StrEqual(text, "-1")) break;

		GetAbilityStrengthByTrigger(client, L4D2_GetInfectedAttacker(client), text);
		return true;
	}
	return false;
}

stock int GetIfTriggerRequirementsMetAlways(int client, char[] TalentName) {
	char text[64];
	int size = a_Menu_Talents.Length;
	for (int i = 0; i < size; i++) {
		GetIfTriggerRequirementsMetSection[client]	= a_Menu_Talents.Get(i, 2);
		GetIfTriggerRequirementsMetSection[client].GetString(0, text, sizeof(text));
		if (!StrEqual(text, TalentName)) continue;
		//GetIfTriggerRequirementsMetKeys[client]		= a_Menu_Talents.Get(i, 0);
		GetIfTriggerRequirementsMetValues[client]	= a_Menu_Talents.Get(i, 1);
		// Reactive abilities start with their requirements for active end or cooldown end ability triggers to fire, not met.
		if (GetKeyValueIntAtPos(GetIfTriggerRequirementsMetValues[client], ABILITY_IS_REACTIVE) == 1) return 0;
		break;
	}
	// If we get here, we meet the requirements.
	return 1;
}

bool AbilityIsInactiveAndOnCooldown(int client, char[] TalentName, float fCooldownRemaining) {
	if (fCooldownRemaining == -1.0) return false;

	float AmmoCooldownTime = GetAbilityValue(client, TalentName, ABILITY_ACTIVE_TIME);
	if (AmmoCooldownTime == -1.0) return false;

	float fAmmoCooldownTime = GetSpellCooldown(client, TalentName);
	AmmoCooldownTime = AmmoCooldownTime - (fAmmoCooldownTime - fCooldownRemaining);
	if (AmmoCooldownTime > 0.0) return false;
	return true;
}

// by default this function does not handle instants, so we use an override to force it.
stock float GetAbilityMultiplier(int client, char[] abilityT, int override = 0, char[] TalentName_t = "none") { // we need the option to force certain results in the menus (1) active (2) passive
	//new Handle Keys		= GetAbilityKeys[client];
	ArrayList Values	= GetAbilityValues[client];
	ArrayList Section	= GetAbilitySection[client];
	/*
		For recursive calls for GetSpellCooldown, we need to use a different set of array lists
		so that we don't override the active set.
	*/
	if (override == -1) {
		//Keys			= GetAbilityCooldownKeys[client];
		Values			= GetAbilityCooldownValues[client];
		Section			= GetAbilityCooldownSection[client];
	}
	
	//if (IsSurvivorBot(client)) return -1.0;
	//bIsAbility && AmmoCooldownTime != -1.0 && AmmoCooldownTime > 0.0

	char TalentName[64];
	//decl String:abilityT[4];


	float totalStrength = 0.0, theStrength = 0.0;
	bool foundone = false;

	//if (StrEqual(TalentName_t, "none")) Format(abilityT, sizeof(abilityT), "%c", ability);
	char MyTeam[6], TheTeams[6];
	Format(MyTeam, sizeof(MyTeam), "%d", GetClientTeam(client));

	int size = a_Menu_Talents.Length;
	if (override == 0) size = ActionBar[client].Length;
	float fCooldownRemaining = 0.0;
	int isReactive = 0;

	char activeEffect[10];
	char passiveEffect[10];
	char cooldownEffect[10];
	bool IsCurrentlyActive;
	int combatStateRequired;
	char allowedWeapons[64];
	char clientWeapon[64];
	int pos = -1;
	bool talentPassiveIsActive = false;
	for (int i = 0; i < size; i++) {
		if (override != 0) {
			pos = i;
			Section				= a_Menu_Talents.Get(pos, 2);
			Section.GetString(0, TalentName, sizeof(TalentName));
		}
		else {
			ActionBar[client].GetString(i, TalentName, sizeof(TalentName));
			pos = GetMenuPosition(client, TalentName);
		}
		if (pos < 0) continue;
		if (StrEqual(TalentName_t, "none")) {
			if (!IsAbilityEquipped(client, TalentName)) continue;
		}
		else if (!StrEqual(TalentName, TalentName_t)) continue;

		//Keys				= a_Menu_Talents.Get(pos, 0);
		Values				= a_Menu_Talents.Get(pos, 1);
		if (GetKeyValueIntAtPos(Values, IS_TALENT_ABILITY) != 1) continue;
		combatStateRequired = GetKeyValueIntAtPos(Values, COMBAT_STATE_REQ);
		// if no combat state is set, it will return -1, and then work regardless of their combat status.
		if (combatStateRequired == 0 && bIsInCombat[client] ||
			combatStateRequired == 1 && !bIsInCombat[client]) continue;
		Values.GetString(WEAPONS_PERMITTED, allowedWeapons, sizeof(allowedWeapons));
		if (!StrEqual(allowedWeapons, "-1")) {
			GetClientWeapon(client, clientWeapon, sizeof(clientWeapon));
			if (!IsWeaponPermittedFound(client, allowedWeapons, clientWeapon)) continue;
		}
		Values.GetString(ABILITY_ACTIVE_EFFECT, activeEffect, sizeof(activeEffect));
		Values.GetString(ABILITY_PASSIVE_EFFECT, passiveEffect, sizeof(passiveEffect));
		Values.GetString(ABILITY_COOLDOWN_EFFECT, cooldownEffect, sizeof(cooldownEffect));

		IsCurrentlyActive = IsAbilityActive(client, TalentName, _, abilityT);

		isReactive = GetKeyValueIntAtPos(Values, ABILITY_IS_REACTIVE);
		if (isReactive != 1 && override == 5) continue;
		if (isReactive == 1 && override != 5) continue;
		
		Values.GetString(ABILITY_TEAMS_ALLOWED, TheTeams, sizeof(TheTeams));
		if (StrContains(TheTeams, MyTeam) == -1) continue;

		fCooldownRemaining = GetAmmoCooldownTime(client, TalentName, true);
		if (override != -1 && AbilityIsInactiveAndOnCooldown(client, TalentName, fCooldownRemaining)) {
			return -1.0;
		}
		talentPassiveIsActive = (GetAmmoCooldownTime(client, TalentName) == -1.0) ? true : false;

		//if (override == 0 && GetAmmoCooldownTime(client, TalentName, true) != -1.0 || override == 1) {
		if (override == 4 || !IsCurrentlyActive && !talentPassiveIsActive) {
			theStrength = GetKeyValueFloatAtPos(Values, ABILITY_COOLDOWN_STRENGTH);
			if (override == 4 || fCooldownRemaining > 0.0 && theStrength > 0.0) {
				if (!StrEqual(abilityT, cooldownEffect)) continue;
				if (theStrength > 0.0) return theStrength;
			}
		}
		if (override == 3) {

			if (!IsCurrentlyActive) return GetKeyValueFloatAtPos(Values, ABILITY_MAXIMUM_PASSIVE_MULTIPLIER);
			else return GetKeyValueFloatAtPos(Values, ABILITY_MAXIMUM_ACTIVE_MULTIPLIER);
		}
		else if (override == 1 || IsCurrentlyActive) {

			if (StrEqual(TalentName_t, "none")) {
				if (!StrEqual(abilityT, activeEffect)) continue;
				
				if (override != 1 && GetKeyValueIntAtPos(Values, ABILITY_ACTIVE_STATE_ENSNARE_REQ) == 1 && L4D2_GetInfectedAttacker(client) == -1) continue;
				if (override == 5) {
					// this only happens if the requirements to trigger are met (and cannot trigger if they've been met before.)
					if (!SetActiveAbilityConditionsMet(client, TalentName, true)) {
						SetActiveAbilityConditionsMet(client, TalentName);
						return -2.0;	// this is how we know that reactive abilities are active (and can thus trigger)
					}
					else return -3.0;	// this is the return if the reactive effect has already triggered (reactive can only trigger once during their active period.)
				}
			}
			//Keys			= a_Menu_Talents.Get(i, 0);
			//Values		= a_Menu_Talents.Get(i, 1);
			theStrength = GetKeyValueFloatAtPos(Values, ABILITY_ACTIVE_STRENGTH);
		}
		else if (override == 2 || talentPassiveIsActive || GetKeyValueIntAtPos(Values, ABILITY_PASSIVE_IGNORES_COOLDOWN) == 1) {
			if (StrEqual(TalentName_t, "none")) {
				if (!StrEqual(abilityT, passiveEffect)) continue;
				if (override != 2 && GetKeyValueIntAtPos(Values, ABILITY_PASSIVE_STATE_ENSNARE_REQ) == 1 && L4D2_GetInfectedAttacker(client) == -1) continue;
			}
			theStrength = GetKeyValueFloatAtPos(Values, ABILITY_PASSIVE_STRENGTH);
		}
		else continue;	// If it's not active, or it's on cooldown, we ignore its value.
		
		if (override == 4) {

			totalStrength += ((1.0 - totalStrength) * theStrength);
		} 
		else totalStrength += theStrength;
		foundone = true;
	}
	if (!foundone) totalStrength = -1.0;
	return totalStrength;
}

stock bool IsAbilityEquipped(int client, char[] TalentName) {

	char text[64];

	int size = iActionBarSlots;
	if (ActionBar[client].Length != size) ActionBar[client].Resize(size);
	for (int i = 0; i < size; i++) {
		ActionBar[client].GetString(i, text, sizeof(text));
		if (!StrEqual(text, TalentName)) continue;
		if (GetTalentStrength(client, TalentName) > 0) return true;
		break;
	}
	return false;
}

stock bool IsAbilityActive(int client, char[] TalentName, float timeToAdd = 0.0, char[] checkEffect = "none") {
	if (StrEqual(checkEffect, "L")) return false;

	float fCooldownRemaining = GetAmmoCooldownTime(client, TalentName, true);
	if (fCooldownRemaining == -1.0) return false;
	if (GetAbilityValue(client, TalentName, ABILITY_COOLDOWN) == -1.0) return false;

	float AmmoCooldownTime		 = GetAbilityValue(client, TalentName, ABILITY_ACTIVE_TIME);
	if (AmmoCooldownTime == -1.0) return false;

	float fAmmoCooldownTime = GetSpellCooldown(client, TalentName);
	AmmoCooldownTime				 = AmmoCooldownTime - (fAmmoCooldownTime - fCooldownRemaining) + timeToAdd;

	if (AmmoCooldownTime < 0.0) return false;
	return true;
}

/*

	Return different types of results about the special ammo. 0, the default, returns its active time
	0	Ability Time
	1	Cooldown Time
	2	Stamina Cost
	3	Range
	4	Interval Time
	5	Effect Strength
*/
stock float GetSpecialAmmoStrength(int client, char[] TalentName, int resulttype=0, bool bGetNextUpgrade=false, int TalentStrengthOverride = 0) {

	int pos							=	GetMenuPosition(client, TalentName);
	if (pos == -1) return -1.0;		// no ammo is selected.
	int TheStrength = GetTalentStrength(client, TalentName);
	float f_Str					=	TheStrength * 1.0;
	float baseTalentStrength	= 0.0;
	float i_FirstPoint			= 0.0;
	float i_FirstPoint_Temp		= 0.0;
	//new Float:i_Time_Temp			= 0.0;
	//new Float:i_Cooldown_Temp		= 0.0;
	//new Float:f_Min					= 0.0;
	float i_EachPoint			= 0.0;
	float i_EachPoint_Temp		= 0.0;
	float i_CooldownStart		= 0.0;
	if (TalentStrengthOverride != 0) f_Str = TalentStrengthOverride * 1.0;
	else if (bGetNextUpgrade) f_Str++;		// We add 1 point if we're showing the next upgrade value.

	//SpecialAmmoStrengthKeys[client]			= a_Menu_Talents.Get(pos, 0);
	SpecialAmmoStrengthValues[client]		= a_Menu_Talents.Get(pos, 1);

	char governingAttribute[64];
	GetGoverningAttribute(client, TalentName, governingAttribute, sizeof(governingAttribute));
	float attributeMult = 0.0;
	if (!StrEqual(governingAttribute, "-1")) attributeMult = GetAttributeMultiplier(client, governingAttribute);

	/*new Cons = GetTalentStrength(client, "constitution");
	new Agil = GetTalentStrength(client, "agility");
	new Resi = GetTalentStrength(client, "resilience");
	new Tech = GetTalentStrength(client, "technique");
	new Endu = GetTalentStrength(client, "endurance");*/
	//new Luck = GetTalentStrength(client, "luck");

	float f_StrEach = f_Str - 1;
	float TheAbilityMultiplier = 0.0;

	if (f_Str > 0.0) {

		if (resulttype == 0) {		// Ability Time

			i_FirstPoint		=	GetKeyValueFloatAtPos(SpecialAmmoStrengthValues[client], SPELL_ACTIVE_TIME_FIRST_POINT);
			i_FirstPoint_Temp	=	(i_FirstPoint * attributeMult);	// Constitution increases the first point value of spells.
			i_FirstPoint		+= i_FirstPoint_Temp;


			
			i_EachPoint			=	(GetKeyValueFloatAtPos(SpecialAmmoStrengthValues[client], SPELL_ACTIVE_TIME_PER_POINT));
			i_EachPoint			+=	(i_EachPoint * attributeMult);
			if (i_EachPoint < 0.0) i_EachPoint = 0.0;

			i_EachPoint *= f_StrEach;

			f_Str			=	i_FirstPoint + i_EachPoint;
			f_Str += GetAbilityStrengthByTrigger(client, _, "spellbuff", _, _, _, _, "activetime", 0, true);
		}
		else if (resulttype == 1) {		// Cooldown Time

			i_CooldownStart			=	GetKeyValueFloatAtPos(SpecialAmmoStrengthValues[client], SPELL_COOLDOWN_START);
			i_FirstPoint			=	GetKeyValueFloatAtPos(SpecialAmmoStrengthValues[client], SPELL_COOLDOWN_FIRST_POINT);
			i_EachPoint				=	GetKeyValueFloatAtPos(SpecialAmmoStrengthValues[client], SPELL_COOLDOWN_PER_POINT);

			i_EachPoint_Temp		=	(i_EachPoint * attributeMult)
			i_EachPoint_Temp		-=	(i_EachPoint * attributeMult);
			if (i_EachPoint_Temp > 0.0) i_EachPoint -= i_EachPoint_Temp;
			if (i_EachPoint < 0.0) i_EachPoint = 0.0;


			TheAbilityMultiplier = GetAbilityMultiplier(client, "L");
			if (TheAbilityMultiplier != -1.0) {

				if (TheAbilityMultiplier < 0.0) TheAbilityMultiplier = 0.1;
				else if (TheAbilityMultiplier > 0.0) { //cooldowns are reduced

					i_FirstPoint		*= TheAbilityMultiplier;
					i_EachPoint			*= TheAbilityMultiplier;
				}
			}

			i_EachPoint *= f_StrEach;

			f_Str			=	i_FirstPoint + i_EachPoint;
			f_Str			+=	i_CooldownStart;
			f_Str += GetAbilityStrengthByTrigger(client, _, "spellbuff", _, _, _, _, "cooldown", 0, true);
			// If talents reduce the cooldown time, we need to make sure the cooldown is never less than the active time - or they could have multiple of the same spell active at one time.
			if (f_Str < 0.0) f_Str = 0.0;//f_Str = GetSpecialAmmoStrength(client, TalentName, _, bGetNextUpgrade, TalentStrengthOverride);
		}
		else if (resulttype == 2) {		// Stamina Cost

			i_FirstPoint						=	GetKeyValueIntAtPos(SpecialAmmoStrengthValues[client], SPELL_BASE_STAMINA_REQ) * 1.0;
			i_FirstPoint_Temp					=	(i_FirstPoint * attributeMult);
			i_FirstPoint_Temp					-=	(i_FirstPoint * attributeMult);
			if (i_FirstPoint_Temp > 0.0) i_FirstPoint += i_FirstPoint_Temp;
			baseTalentStrength = i_FirstPoint;

			i_EachPoint							=	GetKeyValueFloatAtPos(SpecialAmmoStrengthValues[client], SPELL_STAMINA_PER_POINT);
			i_EachPoint_Temp					=	(i_EachPoint * attributeMult);
			i_EachPoint							-=	i_EachPoint_Temp;
			if (i_EachPoint < 0.0) i_EachPoint = 0.0;

			i_EachPoint *= f_StrEach;

			f_Str								=	i_FirstPoint + i_EachPoint;
			if (f_Str < baseTalentStrength) f_Str = baseTalentStrength;
			f_Str += GetAbilityStrengthByTrigger(client, _, "spellbuff", _, _, _, _, "staminacost", 0, true);
			if (f_Str < 1.0) f_Str = 1.0;
			// we do class multiplier after because we want to allow classes to modify the restrictions
		}
		else if (resulttype == 3) {		// Range

			i_FirstPoint						=	GetKeyValueFloatAtPos(SpecialAmmoStrengthValues[client], SPELL_RANGE_FIRST_POINT);
			i_FirstPoint_Temp					=	(i_FirstPoint * attributeMult);
			i_FirstPoint						+=	i_FirstPoint_Temp;



			i_EachPoint							=	GetKeyValueFloatAtPos(SpecialAmmoStrengthValues[client], SPELL_RANGE_PER_POINT);
			i_EachPoint_Temp					=	(i_EachPoint * attributeMult);
			i_EachPoint_Temp					-=	(i_EachPoint * attributeMult);
			if (i_EachPoint_Temp > 0.0) i_EachPoint += i_EachPoint_Temp;

			i_EachPoint *= f_StrEach;

			f_Str			=	i_FirstPoint + i_EachPoint;
			f_Str += GetAbilityStrengthByTrigger(client, _, "spellbuff", _, _, _, _, "range", 0, true);
		}
		else if (resulttype == 4) {		// Interval

			i_FirstPoint		=	GetKeyValueFloatAtPos(SpecialAmmoStrengthValues[client], SPELL_INTERVAL_FIRST_POINT);
			i_FirstPoint_Temp	=	(i_FirstPoint * attributeMult);
			i_FirstPoint		+=	i_FirstPoint_Temp;

			i_EachPoint			=	GetKeyValueFloatAtPos(SpecialAmmoStrengthValues[client], SPELL_INTERVAL_PER_POINT);
			i_EachPoint_Temp	=	(i_EachPoint * attributeMult);
			i_EachPoint_Temp	-=	(i_EachPoint * attributeMult);
			if (i_EachPoint_Temp > 0.0) i_EachPoint += i_EachPoint_Temp;

			i_EachPoint *= f_StrEach;
			f_Str			=	i_FirstPoint + i_EachPoint;
			f_Str += GetAbilityStrengthByTrigger(client, _, "spellbuff", _, _, _, _, "interval", 0, true);
		}
	}
	//if (resulttype == 3) return (f_Str / 2);	// we always measure from the center-point.
	f_Str += (f_Str * GetAbilityStrengthByTrigger(client, _, "spellbuff", _, _, _, _, "strengthup", 0, true));
	return f_Str;
}

/*stock CreateActiveTime(client, char[] TalentName[], Float:f_Delay) {

	if (IsLegitimateClient(client)) {

		if (IsAmmoActive(client, TalentName)) return 2;	// we don't need to initiate the ammo's activation period if it's already active.
		IsAmmoActive(client, TalentName, f_Delay);
		return 1;
	}
	return 0;
}*/

public Action Timer_RemoveCooldown(Handle timer, DataPack packi) {

	packi.Reset();
	int client				=	packi.ReadCell();
	int pos					=	packi.ReadCell();
	char StackType[64];
	packi.ReadString(StackType, sizeof(StackType));
	//new StackCount			=	packi.ReadCell();
	int target				=	packi.ReadCell();
	float f_Cooldown	= packi.ReadFloat();


	if (StrEqual(StackType, "none", false)) {

		if (IsLegitimateClient(client)) {

		//if (client != -1 || (GetClientTeam(client) == TEAM_SURVIVOR || IsSurvivorBot(client))) {

			PlayerAbilitiesCooldown[client].SetString(pos, "0");
		}
		//}
		/*else {

			PlayerAbilitiesCooldown_Bots.SetString(pos, "0");
		}*/
	}
	else if (IsLegitimateClient(target)) {

		CleanseStack[client]--;		// again we will open this for more expansion later.

		CounterStack[target] -= f_Cooldown;
		if (CounterStack[target] <= 0.0) {

			MultiplierStack[target] = 0;
			Format(BuildingStack[target], sizeof(BuildingStack[]), "none");
		}
	}
	return Plugin_Stop;
}

stock void CreateCooldown(int client, int pos, float f_Cooldown, char[] StackType = "none", int StackCount = 0, int target = 0) {
	if (IsLegitimateClient(client)) {
		if (target == 0) target = client;
		if (PlayerAbilitiesCooldown[client].Length < pos) PlayerAbilitiesCooldown[client].Resize(pos + 1);
		//if (GetClientTeam(client) == TEAM_SURVIVOR || IsSurvivorBot(client))
		PlayerAbilitiesCooldown[client].SetString(pos, "1");
		//else PlayerAbilitiesCooldown_Bots.SetString(pos, "1");
		DataPack packi;
		CreateDataTimer(f_Cooldown, Timer_RemoveCooldown, packi, TIMER_FLAG_NO_MAPCHANGE);
		//if (IsFakeClient(client)) client = -1;
		packi.WriteCell(client);
		packi.WriteCell(pos);
		if (!StrEqual(StackType, "none", false)) {
			CounterStack[target] += f_Cooldown;		// we subtract this value when the datatimer executes and if it is <= 0.0 then we set the building stack type to none.
			if (!StrEqual(StackType, BuildingStack[target], false)) {
				MultiplierStack[target] = 0;	// if the cleanse removes a different effect, we reset the overdrive, but it is also refreshed.
				Format(BuildingStack[target], sizeof(BuildingStack[]), "%s", StackType);
				PrintToChat(target, "%T", "building stack change", target, orange, blue, StackType, orange, green, f_Cooldown, blue);
			}
		}
		// So we can let clients build special stacks.
		packi.WriteString(StackType);
		//packi.WriteCell(StackCount);
		packi.WriteCell(target);
		packi.WriteFloat(f_Cooldown);
	}
}

stock bool HasAbilityPoints(int client, char[] TalentName) {

	if (IsLegitimateClientAlive(client)) {

		// Check if the player has any ability points in the specified ability

		int a_Size				=	0;
		//if (client != -1)
		a_Size		=	a_Database_PlayerTalents[client].Length;
		//else a_Size						=	a_Database_PlayerTalents_Bots.Length;

		char Name[PLATFORM_MAX_PATH];

		for (int i = 0; i < a_Size; i++) {

			a_Database_Talents.GetString(i, Name, sizeof(Name));
			if (StrEqual(Name, TalentName)) {

				//if (client != -1)
				a_Database_PlayerTalents[client].GetString(i, Name, sizeof(Name));
				//else Handle a_Database_PlayerTalents_Bots.GetString(i, Name, sizeof(Name));
				if (StringToInt(Name) > 0) return true;
			}
		}
	}
	return false;
}

/*stock AwardSkyPoints(client, amount) {

	decl String:thetext[64];
	GetConfigValue(thetext, sizeof(thetext), "donator package flag?");


	if (HasCommandAccess(client, thetext)) amount = RoundToCeil(amount * 2.0);
	SkyPoints[client] += amount;
	decl String:Name[64];
	GetClientName(client, Name, sizeof(Name));

	GetConfigValue(thetext, sizeof(thetext), "sky points menu name?");
	PrintToChatAll("%t", "Sky Points Award", green, amount, orange, thetext, white, green, Name, white);
}*/

stock int GetUpgradeExperienceCost(int client, bool b_IsLevelUp = false) {

	int experienceCost = 0;
	if (IsLegitimateClient(client)) {

		//if (client == -1) return RoundToCeil(CheckExperienceRequirement(-1) * ((PlayerLevelUpgrades_Bots + 1) * fUpgradeExpCost));
		
		//new Float:Multiplier		= (PlayerUpgradesTotal[client] * 1.0) / (MaximumPlayerUpgrades(client) * 1.0);
		if (fUpgradeExpCost < 1.0) experienceCost		= RoundToCeil(CheckExperienceRequirement(client) * ((UpgradesAwarded[client] + 1) * fUpgradeExpCost));
		else experienceCost = CheckExperienceRequirement(client);
		//experienceCost				= RoundToCeil(CheckExperienceRequirement(client) * Multiplier);
	}
	return experienceCost;
}

stock void PrintToSurvivors(int RPGMode, char[] SurvivorName, char[] InfectedName, int SurvExp, float SurvPoints) {

	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && !IsFakeClient(i) && GetClientTeam(i) == TEAM_SURVIVOR) {

			if (RPGMode == 1) PrintToChat(i, "%T", "Experience Earned Total Team Survivor", i, white, blue, white, orange, white, green, white, SurvivorName, InfectedName, SurvExp);
			else if (RPGMode == 2) PrintToChat(i, "%T", "Experience Points Earned Total Team Survivor", i, white, blue, white, orange, white, green, white, green, white, SurvivorName, InfectedName, SurvExp, SurvPoints);
		}
	}
}

stock void PrintToInfected(int RPGMode, char[] SurvivorName, char[] InfectedName, int InfTotalExp, float InfTotalPoints) {

	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && !IsFakeClient(i) && GetClientTeam(i) == TEAM_INFECTED) {

			if (RPGMode == 1) PrintToChat(i, "%T", "Experience Earned Total Team", i, white, orange, white, green, white, InfectedName, InfTotalExp);
			else if (RPGMode == 2) PrintToChat(i, "%T", "Experience Points Earned Total Team", i, white, orange, white, green, white, green, white, InfectedName, InfTotalExp, InfTotalPoints);
		}
	}
}

stock void ResetOtherData(int client) {

	if (IsLegitimateClient(client)) {

		for (int i = 1; i <= MAXPLAYERS; i++) {

			DamageAward[client][i]		=	0;
			DamageAward[i][client]		=	0;
			CoveredInBile[client][i]	=	-1;
			CoveredInBile[i][client]	=	-1;
		}
	}
}

stock int LivingInfected(bool KillAll=false) {

	int countt = 0;
	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && GetClientTeam(i) == TEAM_INFECTED && FindZombieClass(i) != ZOMBIECLASS_TANK) {

			if (KillAll) ForcePlayerSuicide(i);
			else countt++;
		}
	}
	return countt;
}

/*stock bool:SurvivorsHaveHandicap() {

	for (new i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClientAlive(i) && !IsFakeClient(i) && GetClientTeam(i) == TEAM_SURVIVOR && HandicapLevel[i] != -1) return true;
	}
	return false;
}*/

stock int LivingSurvivors() {

	int count = 0;
	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClientAlive(i) && GetClientTeam(i) == TEAM_SURVIVOR) count++;
	}
	return count;
}

stock int TotalSurvivors() {

	int count = 0;
	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && GetClientTeam(i) == TEAM_SURVIVOR) count++;
	}
	return count;
}

stock void ChangeInfectedClass(int client, int zombieclass = 0, bool dontChangeClass = false) {
	bool clientIsFake = IsLegitimateClient(client) && IsFakeClient(client);

	if (clientIsFake || IsLegitimateClient(client)) {

		if (GetClientTeam(client) == TEAM_INFECTED) {

			if (!dontChangeClass) {
				if (!IsGhost(client)) SetEntProp(client, Prop_Data, "m_takedamage", 1, 1);
				int wi;
				while ((wi = GetPlayerWeaponSlot(client, 0)) != -1) {

					RemovePlayerItem(client, wi);
					AcceptEntityInput(wi, "Kill");
				}
				SDKCall(g_hSetClass, client, zombieclass);
				if (clientIsFake) {
					if (zombieclass == 1) SetClientInfo(client, "name", "Smoker");
					else if (zombieclass == 2) SetClientInfo(client, "name", "Boomer");
					else if (zombieclass == 3) SetClientInfo(client, "name", "Hunter");
					else if (zombieclass == 4) SetClientInfo(client, "name", "Spitter");
					else if (zombieclass == 5) SetClientInfo(client, "name", "Jockey");
					else if (zombieclass == 6) SetClientInfo(client, "name", "Charger");
					else if (zombieclass == 8) SetClientInfo(client, "name", "Tank");
				}
				AcceptEntityInput(MakeCompatEntRef(GetEntProp(client, Prop_Send, "m_customAbility")), "Kill");
				if (IsPlayerAlive(client)) SetEntProp(client, Prop_Send, "m_customAbility", GetEntData(SDKCall(g_hCreateAbility, client), g_oAbility));
				if (!IsGhost(client)) SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);		// client can be killed again.
			}
			SpeedMultiplier[client] = 1.0;		// defaulting the speed. It'll get modified in speed modifer spawn talents.
			SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", SpeedMultiplier[client]);
			SetSpecialInfectedHealth(client, zombieclass);
			//GetAbilityStrengthByTrigger(client, _, "a", FindZombieClass(client), 0);	// activator, target, trigger ability, effects, zombieclass, damage
		}
	}
}

stock void SetSpecialInfectedHealth(int attacker, int zombieclass = 0) {
	int t_InfectedHealth = 0;
	int myzombieclass = (zombieclass == 0) ? FindZombieClass(attacker) : zombieclass;

	if (myzombieclass == ZOMBIECLASS_TANK)  t_InfectedHealth = 4000;
	else if (myzombieclass == ZOMBIECLASS_HUNTER || myzombieclass == ZOMBIECLASS_SMOKER) t_InfectedHealth = 200;
	else if (myzombieclass == ZOMBIECLASS_BOOMER) t_InfectedHealth = 50;
	else if (myzombieclass == ZOMBIECLASS_SPITTER) t_InfectedHealth = 100;
	else if (myzombieclass == ZOMBIECLASS_CHARGER) t_InfectedHealth = 600;
	else if (myzombieclass == ZOMBIECLASS_JOCKEY) t_InfectedHealth = 300;

	OriginalHealth[attacker] = t_InfectedHealth;
	GetAbilityStrengthByTrigger(attacker, _, "a", _, 0);

	if (DefaultHealth[attacker] < OriginalHealth[attacker]) DefaultHealth[attacker] = OriginalHealth[attacker];
}

stock int TotalHumanSurvivors(int ignore = -1) {
	int count = 0;
	for (int i = 1; i <= MaxClients; i++) {
		if (ignore != -1 && i == ignore) continue;
		if (!IsLegitimateClient(i) || IsFakeClient(i) || GetClientTeam(i) != TEAM_SURVIVOR) continue;
		count++;
	}
	return count;
}

stock int LivingHumanSurvivors() {

	int count = 0;
	for (int i = 1; i <= MaxClients; i++) {

		if (!IsLegitimateClient(i) || IsFakeClient(i) || !IsPlayerAlive(i) || GetClientTeam(i) != TEAM_SURVIVOR) continue;
		count++;
	}
	return count;
}

stock int HumanPlayersInGame() {

	int count = 0;
	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && !IsFakeClient(i) && GetClientTeam(i) != TEAM_SPECTATOR) count++;
	}
	return count;
}

public Action Cmd_debugrpg(int client, int args) {
	if (bIsDebugEnabled) {
		PrintToChatAll("\x04rpg debug disabled");
		bIsDebugEnabled = false;
	}
	else {
		PrintToChatAll("\x03rpg debug enabled");
		bIsDebugEnabled = true;
	}
	return Plugin_Handled;
}

public Action Cmd_ResetTPL(int client, int args)
{
	PlayerLevelUpgrades[client] = 0;
	return Plugin_Handled;
}

stock bool StringExistsArray(char[] Name, ArrayList array) {

	char text[PLATFORM_MAX_PATH];

	int a_Size			=	array.Length;

	for (int i = 0; i < a_Size; i++) {

		array.GetString(i, text, sizeof(text));

		if (StrEqual(Name, text)) return true;
	}

	return false;
}

stock void AddCommasToString(int value, char[] theString, int theSize) 
{
	char buffer[64];

	// Eyal282 here, I think the seperator needs to be 2 characters long and not 1, because [0] = ",", [1] = EOS.
	char separator[2];
	separator = ",";
	buffer[0] = '\0'; 
	int divisor = 1000; 
	int offcut = 0;
	
	while (value >= 1000 || value <= -1000)
	{
		offcut = value % divisor;
		value = RoundToFloor(float(value) / float(divisor));
		Format(buffer, sizeof(buffer), "%s%03.d%s", separator, offcut, buffer); 
	}
	
	Format(theString, theSize, "%d%s", value, buffer);
}

stock int HandicapDifference(int client, int target) {

	if (IsLegitimateClientAlive(client) && IsLegitimateClientAlive(target)) {

		int clientLevel = 0;
		int targetLevel = 0;

		if (GetClientTeam(client) == TEAM_SURVIVOR) clientLevel = PlayerLevel[client];
		else clientLevel = PlayerLevel_Bots;

		if (GetClientTeam(client) == TEAM_SURVIVOR) targetLevel = PlayerLevel[target];
		else targetLevel = PlayerLevel_Bots;

		if (targetLevel < clientLevel) {
		
			int dif = clientLevel - targetLevel;
			int han = iHandicapLevelDifference;

			if (dif > han) return (dif - han);
		}
	}
	return 0;
}

stock void ReceiveCommonDamage(int client, int entity, int playerDamageTaken) {

	/*new pos = -1;
	if (IsSpecialCommon(entity)) pos = FindListPositionByEntity(entity, CommonList);
	else if (IsCommonInfected(entity)) pos = FindListPositionByEntity(entity, CommonInfected);*/

	/*if (pos < 0) {

		OnCommonCreated(entity);
		pos = FindListPositionByEntity(entity, CommonInfected);
	}*/
	int my_pos = 0;
	if (IsSpecialCommon(entity)) {

		AddSpecialCommonDamage(client, entity, 0);
		my_pos = FindListPositionByEntity(entity, SpecialCommon[client]);
		if (my_pos >= 0) SpecialCommon[client].Set(my_pos, SpecialCommon[client].Get(my_pos, 3) + playerDamageTaken, 3);
	}
}

stock void ReceiveWitchDamage(int client, int entity, int playerDamageTaken) {

	if (!IsWitch(entity)) {

		OnWitchCreated(entity, true);
		return;
	}
	int pos = FindListPositionByEntity(entity, WitchList);
	if (pos < 0) {

		OnWitchCreated(entity);
		pos = FindListPositionByEntity(entity, WitchList);
	}

	int my_size = WitchDamage[client].Length;
	int my_pos = FindListPositionByEntity(entity, WitchDamage[client]);
	if (my_pos < 0) {

		int WitchHealth = iWitchHealthBase;
		if (iBotLevelType == 0) WitchHealth += RoundToCeil(WitchHealth * (GetDifficultyRating(client) * fWitchHealthMult));
		else WitchHealth += RoundToCeil(WitchHealth * (SurvivorLevels() * fWitchHealthMult));

		WitchDamage[client].Resize(my_size + 1);
		WitchDamage[client].Set(my_size, entity, 0);
		WitchDamage[client].Set(my_size, WitchHealth, 1);
		WitchDamage[client].Set(my_size, 0, 2);
		WitchDamage[client].Set(my_size, playerDamageTaken, 3);
		WitchDamage[client].Set(my_size, 0, 4);
	}
	else {

		WitchDamage[client].Set(my_pos, WitchDamage[client].Get(my_pos, 3) + playerDamageTaken, 3);
	}
}

stock void EntityStatusEffectDamage(int client, int damage) {

	/*

		This function rotates through the list of all players who have an initialized health pool with this entity.
		If they don't, it will create one.

		To simulate the illusion of the entity taking fire damage when players are not dealing damage to it, we instead
		remove the value from its total health pool. Everyone's CNT bars will rise, and the entity's E.HP bar will fall.
	*/
	int pos = -1;
	bool ClientIsWitch = IsWitch(client);
	if (ClientIsWitch) pos = FindListPositionByEntity(client, WitchList);
	if (pos < 0) return;
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClientAlive(i) || GetClientTeam(i) != TEAM_SURVIVOR) continue;
		AddWitchDamage(i, client, 0, true);	// If the player doesn't have the witch, it will be initialized for them.
		AddWitchDamage(i, client, damage * -1, true);		// After we verify initialization, we multiple damage by -1 so the function knows to remove health instead of add contribution.
	}
}

stock int GetDifficultyRating(int client, bool JustBaseRating = false) {

	if (iTankRush == 1) RatingHandicap[client] = RatingPerLevel;
	int iRatingPerLevel = RatingPerLevel;
	if (iRatingPerLevel < RatingHandicap[client]) iRatingPerLevel = RatingHandicap[client];
	iRatingPerLevel *= TotalPointsAssigned(client);
	//iRatingPerLevel *= CartelLevel(client);
	if (!JustBaseRating) return iRatingPerLevel + Rating[client];
	return iRatingPerLevel;
}

stock int AddCommonInfectedDamage(int client, int entity, int playerDamage, bool IsStatusDamage = false, int damagevariant = -1) {

	/*if (!IsCommonInfected(entity)) {

		OnCommonInfectedCreated(entity, true, client);
		return;
	}*/
	//new Float:searchTime = GetEngineTime();
	//new pos		= FindCommonInfectedTargetInArray(Handle CommonInfected, entity);
	//PrintToChatAll("FindCommonInfectedTargetInArray() in %3.20fs", GetEngineTime() - searchTime);
	//searchTime = GetEngineTime();
	int pos		= FindListPositionByEntity(entity, CommonInfected);
	//PrintToChatAll("FindListPositionByEntity() in %3.20fs", GetEngineTime() - searchTime);

	
	if (pos < 0) {
		OnCommonInfectedCreated(entity);
		return 1;
	}
	//if (IsSpecialCommonInRange(entity, 't')) return 1;
	if (playerDamage > 0) {
		int commonHealthRemaining = CommonInfectedHealth.Get(pos);
		if (playerDamage >= commonHealthRemaining) {
			//if (IsMeleeAttacker(client)) GiveAmmoBack(client, 1);
			// common dies.
			// give 1 ammo back if the client used a melee weapon.
			Rating[client] += RoundToCeil(fRatingMultCommons * 100.0);
			ReadyUp_NtvStatistics(client, 2, 1);
			RoundStatistics.Set(0, RoundStatistics.Get(0) + 1);

			OnCommonInfectedCreated(entity, true, client);
			GetAbilityStrengthByTrigger(client, entity, "killcommon");
		}
		else {
			CommonInfectedHealth.Set(pos, commonHealthRemaining - playerDamage);
			// do something ability trigger when you damage but don't kill commons
			GetAbilityStrengthByTrigger(client, entity, "hurtcommon");
		}
	}
	//if (playerDamage > 0 && CheckIfEntityShouldDie(entity, client, playerDamage, IsStatusDamage) == 1) {

	//return (damageTotal + playerDamage);
	//}
	//ThreatCalculator(client, playerDamage);
	return 1;
}

stock int AddWitchDamage(int client, int entity, int playerDamageToWitch, bool IsStatusDamage = false, int damagevariant = -1) {

	if (!IsWitch(entity)) {

		OnWitchCreated(entity, true);
		return 1;
	}
	if (IsSpecialCommonInRange(entity, 't')) return 1;

	int damageTotal = -1;
	int healthTotal = -1;
	int pos		= FindListPositionByEntity(entity, WitchList);
	if (pos < 0) return -1;
	if (client == -1) {
		for (int i = 1; i <= MaxClients; i++) {
			if (!IsLegitimateClient(i) || GetClientTeam(i) != TEAM_SURVIVOR) continue;
			AddWitchDamage(i, entity, playerDamageToWitch, _, 2);	// 2 so we subtract from her health but don't reward any players.
		}
		return 1;
	}

	int my_size	= WitchDamage[client].Length;
	int my_pos	= FindListPositionByEntity(entity, WitchDamage[client]);
	// create an instance of the witch for the player, because one wasn't found.
	if (my_pos < 0) {
		int WitchHealth = iWitchHealthBase;
		WitchHealth += RoundToCeil(WitchHealth * (GetDifficultyRating(client) * fWitchHealthMult));
		//WItchHealth += RoundToCeil(WitchHealth * fSurvivorHealthBonus);

		if (fSurvivorHealthBonus > 0.0) {
			int theCount = LivingSurvivorCount();
			if (theCount >= iSurvivorModifierRequired) WitchHealth += RoundToCeil(WitchHealth * ((theCount - (iSurvivorModifierRequired - 1)) * fSurvivorHealthBonus));
		}
		WitchDamage[client].Resize(my_size + 1);
		WitchDamage[client].Set(my_size, entity, 0);
		WitchDamage[client].Set(my_size, WitchHealth, 1);
		WitchDamage[client].Set(my_size, 0, 2);
		WitchDamage[client].Set(my_size, 0, 3);
		WitchDamage[client].Set(my_size, 0, 4);
		my_pos = my_size;
	}
	if (playerDamageToWitch >= 0) {
		healthTotal = WitchDamage[client].Get(my_pos, 1);
		//new TrueHealthRemaining = RoundToCeil((1.0 - CheckTeammateDamages(entity, client)) * healthTotal);	// in case other players have damaged the mob - we can't just assume the remaining health without comparing to other players.
		if (damagevariant != 2) {
			damageTotal = WitchDamage[client].Get(my_pos, 2);
			if (damageTotal < 0) damageTotal = 0;
			//if (IsSpecialCommonInRange(entity, 't')) return 1;
			//if (playerDamageToWitch > TrueHealthRemaining) playerDamageToWitch = TrueHealthRemaining;

			WitchDamage[client].Set(my_pos, damageTotal + playerDamageToWitch, 2);
			if (playerDamageToWitch > 0) GetProficiencyData(client, GetWeaponProficiencyType(client), RoundToCeil(playerDamageToWitch * fProficiencyExperienceEarned));
		}
		else WitchDamage[client].Set(my_pos, healthTotal - playerDamageToWitch, 1);
	}
	else {

		/*

			When the witch is burning, or hexed (ie it is simply losing health) we come here instead.
			Negative values detract from the overall health instead of adding player contribution.
		*/
		damageTotal = WitchDamage[client].Get(my_pos, 1);
		WitchDamage[client].Set(my_pos, damageTotal + playerDamageToWitch, 1);
	}
	CheckTeammateDamagesEx(client, entity, playerDamageToWitch);
	//CheckIfEntityShouldDie(entity, client, playerDamageToWitch, IsStatusDamage);
	/*if (playerDamageToWitch > 0 && CheckIfEntityShouldDie(entity, client, playerDamageToWitch, IsStatusDamage) == 1) {

		return (damageTotal + playerDamageToWitch);
	}*/
	ThreatCalculator(client, playerDamageToWitch);
	return 1;
}

stock int CheckIfEntityShouldDie(int victim, int attacker, int damage = 0, bool IsStatusDamage = false) {

	if (CheckTeammateDamages(victim, attacker) >= 1.0 ||
		CheckTeammateDamages(victim, attacker, true) >= 1.0) {

		if (IsWitch(victim)) {
			if (IsLegitimateClient(attacker) && AllowShotgunToTriggerNodes(attacker)) {
				GetAbilityStrengthByTrigger(attacker, victim, "witchkill", _, damage);
			}
			OnWitchCreated(victim, true, attacker);
		}
		else if (IsSpecialCommon(victim)) {

			ClearSpecialCommon(victim, _, damage, attacker);
			return 1;
		}
		else return 1;
		if (IsStatusDamage) {

			IgniteEntity(victim, 1.0);
		}
		else return 1;
	}
	else {

		/*

			So the player / common took damage.
		*/
		if (IsWitch(victim)) SetInfectedHealth(victim, 50000);
		else if (IsSpecialCommon(victim)) {

			char AuraEffs[10];
			GetCommonValueAtPos(AuraEffs, sizeof(AuraEffs), victim, SUPER_COMMON_AURA_EFFECT);

			// The bomber explosion initially targets itself so that the chain-reaction (if enabled) doesn't go indefinitely.
			if (StrContains(AuraEffs, "f", true) != -1) {

				//CreateDamageStatusEffect(victim);		// 0 is the default, which is fire.
				//CreateExplosion(attacker);
				CreateDamageStatusEffect(victim, _, attacker, damage);
			}
		}
	}
	return 0;
}

/*

	This function removes a dying (or dead) common infected from all client cooldown arrays.
*/
stock void RemoveCommonAffixes(int entity) {

	int size = CommonAffixes.Length;
	int ent = -1;

	for (int i = 0; i < size; i++) {

		//CASection			= CommonAffixes.Get(i, 2);
		//if (CASection.Length < 1) continue;
		//Handle CommonAffixes.GetString(i, SectionName, sizeof(SectionName));
		//if (StrContains(SectionName, EntityId, false) == -1) continue;
		ent = CommonAffixes.Get(i);
		if (entity != ent) continue;
		CommonAffixes.Erase(i);
		break;
	}
	/*for (new i = 1; i <= MaxClients; i++) {

		size = CommonAffixesCooldown[i].Length;
		for (new y = 0; y < size; y++) {

			RCAffixes[i]			= CommonAffixesCooldown[i].Get(y, 2);
			Handle RCAffixes[i].GetString(0, SectionName, sizeof(SectionName));
			if (StrContains(SectionName, EntityId, false) == -1) continue;
			Handle CommonAffixesCooldown[i].Erase(y);
			break;
		}
	}*/
}

stock int FindInfectedClient(bool GetClient=false) {

	int count = 0;
	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && GetClientTeam(i) == TEAM_INFECTED) {

			if (GetClient) return i;
			count++;
		}
	}
	return count;
}
/*
stock GetExplosionDamage(target, damage, survivor) {
	new TheStrength = GetTalentStrength(survivor, "explosive ammo");
	if (TheStrength > 0) {	// when a healers health regen tics, it heals all teammates nearby, too.

		new Float:explosionrange = GetSpecialAmmoStrength(survivor, "explosive ammo", 3) * 2.0;
		new Float:TargetPos[3];
		GetEntPropVector(target, Prop_Send, "m_vecOrigin", TargetPos);
		TheStrength = LivingEntitiesInRange(target, TargetPos, explosionrange);
		if (TheStrength > 0) return (damage / TheStrength);
	}
	return 0;
}*/

stock void ClearSpecialCommon(int entity, bool IsCommonEntity = true, int playerDamage = 0, int lastAttacker = -1) {

	if (CommonList == INVALID_HANDLE) return;

	char TheDraws[64];
	char ThePos[64];

	int pos = FindListPositionByEntity(entity, CommonList);
	if (pos >= 0) {

		if (IsCommonEntity && IsSpecialCommon(entity)) {

			char CommonEntityEffect[55];
			GetCommonValueAtPos(CommonEntityEffect, sizeof(CommonEntityEffect), entity, SUPER_COMMON_DEATH_EFFECT);
			if (IsLegitimateClientAlive(lastAttacker) && GetClientTeam(lastAttacker) == TEAM_SURVIVOR && StrContains(CommonEntityEffect, "f", true) != -1) {
				CreateDamageStatusEffect(entity);
			}

			for (int y = 1; y <= MaxClients; y++) {

				if (!IsLegitimateClientAlive(y)) continue; // || GetClientTeam(y) != TEAM_SURVIVOR) continue;
				if (StrContains(CommonEntityEffect, "x", true) != -1 && IsSpecialCommonInRange(y, 'x', entity, false)) {
					CreateBomberExplosion(entity, y, "x");
				}
				if (StrContains(CommonEntityEffect, "b", true) != -1 && IsSpecialCommonInRange(y, 'b', entity, false) && FindInfectedClient() > 0 && !ISBILED[y]) {
					SDKCall(g_hCallVomitOnPlayer, y, FindInfectedClient(true), true);
					CreateTimer(15.0, Timer_RemoveBileStatus, y, TIMER_FLAG_NO_MAPCHANGE);
					ISBILED[y] = true;
				}
				if (StrContains(CommonEntityEffect, "a", true) != -1 && IsSpecialCommonInRange(y, 'a', entity, false) && FindInfectedClient() > 0) {

					CreateAcid(FindInfectedClient(true), y, 48.0);
					break;
				}
				if (StrContains(CommonEntityEffect, "e", true) != -1 && IsSpecialCommonInRange(y, 'e', entity, false)) {	// false so we compare death effect instead of aura effect which defaults to true

					if (ISEXPLODE[y] == INVALID_HANDLE) {

						ISEXPLODETIME[y] = 0.0;
						DataPack packagey;
						ISEXPLODE[y] = CreateDataTimer(GetCommonValueFloatAtPos(entity, SUPER_COMMON_DEATH_INTERVAL), Timer_Explode, packagey, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
						packagey.WriteCell(y);
						packagey.WriteCell(GetCommonValueIntAtPos(entity, SUPER_COMMON_AURA_STRENGTH));
						packagey.WriteFloat(GetCommonValueFloatAtPos(entity, SUPER_COMMON_STRENGTH_TARGET));
						packagey.WriteFloat(GetCommonValueFloatAtPos(entity, SUPER_COMMON_LEVEL_STRENGTH));
						packagey.WriteFloat(GetCommonValueFloatAtPos(entity, SUPER_COMMON_RANGE_MAX));
						packagey.WriteFloat(GetCommonValueFloatAtPos(entity, SUPER_COMMON_DEATH_MULTIPLIER));
						packagey.WriteFloat(GetCommonValueFloatAtPos(entity, SUPER_COMMON_DEATH_BASE_TIME));
						packagey.WriteFloat(GetCommonValueFloatAtPos(entity, SUPER_COMMON_DEATH_INTERVAL));
						packagey.WriteFloat(GetCommonValueFloatAtPos(entity, SUPER_COMMON_DEATH_MAX_TIME));
						GetCommonValue(TheDraws, sizeof(TheDraws), entity, "draw colour?");
						packagey.WriteString(TheDraws);
						GetCommonValue(ThePos, sizeof(ThePos), entity, "draw pos?");
						packagey.WriteString(ThePos);
						packagey.WriteCell(GetCommonValueIntAtPos(entity, SUPER_COMMON_LEVEL_REQ));
					}
				}
				if (StrContains(CommonEntityEffect, "s", true) != -1 && IsSpecialCommonInRange(y, 's', entity, false)) {

					if (ISSLOW[y] == INVALID_HANDLE) {

						SetSpeedMultiplierBase(y, GetCommonValueFloatAtPos(entity, SUPER_COMMON_DEATH_MULTIPLIER));
						SetEntityMoveType(y, MOVETYPE_WALK);
						ISSLOW[y] = CreateTimer(GetCommonValueFloatAtPos(entity, SUPER_COMMON_DEATH_BASE_TIME), Timer_Slow, y, TIMER_FLAG_NO_MAPCHANGE);
					}
				}
				if (StrContains(CommonEntityEffect, "f", true) != -1) {

					CreateDamageStatusEffect(entity, _, y, playerDamage);
					//if (FindZombieClass(y) == ZOMBIECLASS_TANK) ChangeTankState(y, "burn");
				}
			}

			CalculateInfectedDamageAward(entity, lastAttacker);
			SDKUnhook(entity, SDKHook_OnTakeDamage, OnTakeDamage);
		}
		if (pos < CommonList.Length) CommonList.Erase(pos);
		RemoveCommonAffixes(entity);
		OnCommonInfectedCreated(entity, true);
	}
	//if (IsValidEntity(entity)) SetInfectedHealth(entity, 1);	// this is so it dies right away.
	if (IsValidEntity(entity)) {
		AcceptEntityInput(entity, "Kill");
		//IgniteEntity(entity, 1.0);
	}
}

stock int GetTeamRatingAverage(int teamToGatherRatingOf = 2) {	// 2 == survivors
	int rating = 0;
	int count = 0;
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i) || GetClientTeam(i) != teamToGatherRatingOf) continue;
		rating += Rating[i];
		count++;
	}
	if (count > 1) rating /= count;
	return rating;
}

stock bool IsCommonInfectedDead(int entity) {

	if (FindListPositionByEntity(entity, CommonInfected) < 0) return true;
	return false;
}

stock void OnCommonCreated(int entity, bool bIsDestroyed = false, bool isSpecial = false) {

	//decl String:EntityId[64];
	//Format(EntityId, sizeof(EntityId), "%d", entity);

	//if (!bIsDestroyed) InsertCommonSorted(entity);
	if (!bIsDestroyed) CommonList.Push(entity);
	else if (isSpecial || IsSpecialCommon(entity)) ClearSpecialCommon(entity);
}

stock void OnCommonInfectedCreated(int entity, bool bIsDestroyed = false, int finalkillclient=0, bool IsIgnite = false) {
	if (CommonInfected == INVALID_HANDLE) return;
	if (!b_IsActiveRound) return;
	int pos = FindListPositionByEntity(entity, CommonInfected);
	//new ASize = Handle CommonInfected.Length;
	if (!bIsDestroyed && pos < 0) {
		CommonInfected.Push(entity);
		CommonInfectedHealth.Push(iCommonBaseHealth + RoundToCeil(iCommonBaseHealth * (GetTeamRatingAverage() * fCommonLevelHealthMult)));
	}
	else if (bIsDestroyed && pos >= 0) {

		//CalculateInfectedDamageAward(entity, finalkillclient);
		//SDKUnhook(entity, SDKHook_OnTakeDamage, OnTakeDamage);
		CommonInfected.Erase(pos);
		CommonInfectedHealth.Erase(pos);
		OnCommonCreated(entity, true);
		//RemoveCommonAffixes(entity);
		if (IsIgnite) {

			SDKUnhook(entity, SDKHook_OnTakeDamage, OnTakeDamage);
			IgniteEntity(entity, 1.0);
		}
	}
}

/*

	Witches are created different than other infected.
	If we want to track them and then remove them when they die
	we need to write custom code for it.

	This function serves to manage, maintain, and remove dead witches
	from both the list of active witches as well as reward players who
	hurt them and then reset that said damage as well.
*/
stock void OnWitchCreated(int entity, bool bIsDestroyed = false, int lastHitAttacker = 0) {

	if (WitchList == INVALID_HANDLE) return;

	if (!bIsDestroyed) {

		/*

			When a new witch is created, we add them to the list, and then we
			make sure all survivor players lists are the same size.
		*/
		//LogMessage("[WITCH_LIST] Witch Created %d", entity);
		WitchList.Push(entity);
		SetInfectedHealth(entity, 50000);
		SDKHook(entity, SDKHook_OnTakeDamage, OnTakeDamage);

		//CreateMyHealthPool(entity);
	}
	else {

		/*

			When a Witch dies, we reward all players who did damage to the witch
			and then we remove the row of the witch id in both the witch list
			and in player lists.
		*/
		int pos = FindListPositionByEntity(entity, WitchList);
		if (pos < 0) {

			LogMessage("[WITCH_LIST] Could not find Witch by id %d", entity);
		}
		else {

			CalculateInfectedDamageAward(entity, lastHitAttacker, pos);
			//ogMessage("[WITCH_LIST] Witch %d Killed", entity);
			//SDKUnhook(entity, SDKHook_OnTakeDamage, OnTakeDamage);
			//AcceptEntityInput(entity, "Kill");
			//Handle WitchList.Erase(pos);		// Delete the witch. Forever. now occurs in CalculateInfectedDamageAward()
		}
	}
}

stock int FindEntityInString(char[] SearchKey, char[] Delim = ":") {

	if (StrContains(SearchKey, Delim, false) == -1) return -1;
	char tExploded[2][64];

	ExplodeString(SearchKey, Delim, tExploded, 2, 64);
	return StringToInt(tExploded[1]);
}

stock int GetArraySizeEx(char[] SearchKey, char[] Delim = ":") {

	int count = 0;
	for (int i = 0; i <= strlen(SearchKey); i++) {

		if (StrContains(SearchKey[i], Delim, false) != -1) count++;
	}
	if (count == 0) return -1;
	return count + 1;
}

stock int FindDelim(char[] EntityName, char[] Delim = ":") {

	char DelimStr[2];

	for (int i = 0; i <= strlen(EntityName); i++) {

		Format(DelimStr, sizeof(DelimStr), "%s", EntityName[i]);
		if (StrContains(DelimStr, Delim, false) != -1) {

			// Found it!
			return i + 1;
		}
	}
	return -1;
}

stock int GetDelimiterCount(char[] TextCase, char[] Delimiter) {

	int count = 0;
	char Delim[2];
	for (int i = 0; i <= strlen(TextCase); i++) {

		Format(Delim, sizeof(Delim), "%s", TextCase[i]);
		if (StrContains(Delim, Delimiter, false) != -1) count++;
	}
	return count;
}

stock int FindListPositionBySearchKey(char[] SearchKey, ArrayList h_SearchList, int block = 0, bool bDebug = false) {

	/*

		Some parts of rpg are formatted differently, so we need to check by entityname instead of id.
	*/
	char SearchId[64];

	//new ArrayList Section = new ArrayList(8);

	int size = h_SearchList.Length;
	if (bDebug) {

		LogMessage("=== FindListPositionBySearchKey ===");
		LogMessage("SearchKey: %s", SearchKey);
	}
	for (int i = 0; i < size; i++) {

		//size = Handle h_SearchList.Length;
		//if (i >= size) continue;

		SearchKey_Section						= h_SearchList.Get(i, block);

		if (SearchKey_Section.Length < 1) {

			//if (bDebug) LogMessage("Section header cannot be found for pos %d in the array", i);
			continue;
		}

		SearchKey_Section.GetString(0, SearchId, sizeof(SearchId));
		if (bDebug) {

			LogMessage("Section: %s", SearchId);
			LogMessage("Pos: %d", i);
			LogMessage("Size: %d", size);
		}
		if (StrEqual(SearchId, SearchKey, false)) {

			if (bDebug) {

				LogMessage("SearchKey Found!");
				LogMessage("===================================");
			}

			//Handle Section.Clear();
			return i;
		}
		else if (bDebug) LogMessage("Wrong SearchKey (%s)", SearchId);
	}
	if (bDebug) {

		LogMessage("SearchKey not found :(");
		LogMessage("===================================");
	}
	//Handle Section.Clear();
	return -1;
}

stock bool SurvivorsSaferoomWaiting() {

	int count = 0;
	int numOfLivingHumanSurvivors = LivingHumanSurvivors();
	if (numOfLivingHumanSurvivors < 1) return false;
	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClientAlive(i) && GetClientTeam(i) == TEAM_SURVIVOR && !IsFakeClient(i) && bIsInCheckpoint[i]) count++;
	}
	if (count >= numOfLivingHumanSurvivors) return true;
	return false;
}

stock void SurvivorBotsRegroup() {
	float pos[3];
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i) || IsFakeClient(i) || GetClientTeam(i) != TEAM_SURVIVOR) continue;
		GetClientAbsOrigin(i, pos);
		break;
	}
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i) || !IsFakeClient(i) || GetClientTeam(i) != TEAM_SURVIVOR) continue;
		TeleportEntity(i, pos, NULL_VECTOR, NULL_VECTOR);
	}
}

stock void PenalizeGroupmates(int client) {

	//ew size = Handle MyGroup[client].Length;
	char text[64];
	int jerk = 0;
	// Eyal282 here. Warnings are evil.
	//float ThePenalty = 1.0 / MyGroup[client].Length;

	while (MyGroup[client].Length > 0) {

		MyGroup[client].GetString(0, text, sizeof(text));
		jerk = FindClientWithAuthString(text, true);

		if (IsLegitimateClientAlive(jerk) && !IsFakeClient(jerk) && GetClientTeam(jerk) == TEAM_SURVIVOR) LogMessage("steamid: %s, size: %d", text, MyGroup[client].Length);//ConfirmExperienceActionTalents(jerk, true, _, ThePenalty);
		MyGroup[client].Erase(0);
	}

	/*for (new i = 0; i < size; i++) {

		MyGroup[client].GetString(i, text, sizeof(text));
		jerk = FindClientWithAuthString(text, true);

		if (IsLegitimateClientAlive(jerk) && !IsFakeClient(jerk) && GetClientTeam(jerk) == TEAM_SURVIVOR) {

			ConfirmExperienceActionTalents(jerk, true, _, ThePenalty);
		}
	}*/
	MyGroup[client].Clear();
}

stock bool IsSurvivorInAGroup(int client) {

	if (IsFakeClient(client)) return false;	// we don't penalize players if bots die, so we always assume bots "aren't in a group" during this phase

	MyGroup[client].Clear();
	// Checks if a player is in a group, right before they die.
	// While the dying player loses it all, group members will also lose a percentage of their XP, based on their group size.
	// Small groups have a larger split of the total XP, which means they also take a larger penalty when one of their members goes out.

	float Origin[3];
	GetClientAbsOrigin(client, Origin);

	float Pos[3];
	char AuthID[64];
	for (int i = 1; i <= MaxClients; i++) {

		if (i == client || !IsLegitimateClientAlive(i) || GetClientTeam(i) != TEAM_SURVIVOR || IsFakeClient(i)) continue;
		GetClientAbsOrigin(i, Pos);
		if (GetVectorDistance(Origin, Pos) <= 1536.0 || IsPlayerRushing(i)) {	// rushers get treated like they're a member of everyone who dies group, so that they are punished every time someone dies.

			GetClientAuthId(i, AuthId_Steam2, AuthID, sizeof(AuthID));
			MyGroup[client].PushString(AuthID);
			LogMessage("Size is now: %d added new steamid: %s of %N", MyGroup[client].Length, AuthID, i);
		}
	}
	if (MyGroup[client].Length < iSurvivorGroupMinimum) return false;
	return true;
}

stock bool IsPlayerRushing(int client, float fDistance = 2048.0) {

	int TotalClients = LivingHumanSurvivors();
	int MyGroupSize = GroupSize(client);
	int LargestGroup = GroupSize();

	if (!AnyGroups() && MyGroupSize >= LargestGroup || TotalClients <= iSurvivorGroupMinimum || NearbySurvivors(client, fDistance, true, true) >= iSurvivorGroupMinimum) return false;
	return true;
}

stock float SurvivorRushingMultiplier(int client, bool IsForTankTeleport = false) {

	int SurvivorsCount	= LivingHumanSurvivors();
	if (SurvivorsCount <= iSurvivorGroupMinimum) return 1.0;	// no penalty if less players than group minimum exist.

	int SurvivorsNear	= NearbySurvivors(client, 1536.0, true, true);
	if (SurvivorsNear >= iSurvivorGroupMinimum) return 1.0; // If the player is in a group of players, they take no penalty.
	else if (IsForTankTeleport) return -2.0;					// If tanks are trying to find a player to teleport to, if this player isn't in a group, they are eligible targets.

	float GetMultiplier = 1.0 / SurvivorsCount;
	GetMultiplier *= SurvivorsNear;
	return GetMultiplier;
}

stock bool AnyGroups() {

	for (int i = 1; i <= MaxClients; i++) {

		if (!IsLegitimateClientAlive(i) || GetClientTeam(i) != TEAM_SURVIVOR) continue;
		if (NearbySurvivors(i, 1536.0, true) >= iSurvivorGroupMinimum) return true;
	}
	return false;
}

stock int GroupSize(int client = 0) {

	if (client > 0) return NearbySurvivors(client, 1536.0, true);
	int largestGroup = 0;
	int count = 0;
	for (int i = 1; i <= MaxClients; i++) {

		if (client == i || !IsLegitimateClientAlive(i) || GetClientTeam(i) != TEAM_SURVIVOR) continue;
		count = NearbySurvivors(i, 1536.0, true);
		if (count > largestGroup) largestGroup = count;
	}
	return count;
}

stock int NearbySurvivors(int client, float range = 512.0, bool Survivors = false, bool IsRushing = false) {

	float pos[3];
	if (IsLegitimateClientAlive(client)) GetClientAbsOrigin(client, pos);
	else GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
	float spos[3];

	int count = 0;
	int TheTime = GetTime();

	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClientAlive(i) && GetClientTeam(i) == TEAM_SURVIVOR && i != client) {

			if (Survivors && IsSurvivorBot(i)) continue;
			if (IsRushing && (MyBirthday[i] == 0 || (TheTime - MyBirthday[i]) < 60 || NearbySurvivors(i, 1536.0, true) < iSurvivorGroupMinimum)) {

				// If a player has only been in the game a short time, or is not near enough survivors to be in a group, we consider them part of everyone's group.

				count++;
				continue;
			}

			GetClientAbsOrigin(i, spos);
			if (GetVectorDistance(pos, spos) <= range) count++;
		}
	}
	return count;
}

stock int NumSurvivorsInRange(int client, float range = 512.0) {

	float pos[3];
	if (IsLegitimateClientAlive(client)) GetClientAbsOrigin(client, pos);
	else GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
	float spos[3];
	int count = 0;
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClientAlive(i) || GetClientTeam(i) != TEAM_SURVIVOR || i == client) continue;
		GetClientAbsOrigin(i, spos);
		if (GetVectorDistance(pos, spos) <= range) count++;
	}
	return count;
}

stock bool SurvivorsInRange(int client, float range = 512.0, bool NoSurvivorBots = false) {

	float pos[3];
	if (IsLegitimateClientAlive(client)) GetClientAbsOrigin(client, pos);
	else GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
	float spos[3];

	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClientAlive(i) || GetClientTeam(i) != TEAM_SURVIVOR || i == client) continue;
		if (NoSurvivorBots && IsFakeClient(i)) continue;

		GetClientAbsOrigin(i, spos);
		if (GetVectorDistance(pos, spos) <= range) return true;
	}
	return false;
}

stock bool AnyTanksNearby(int client, float range = 0.0) {

	if (range == 0.0) range = TanksNearbyRange;

	float pos[3];
	float ipos[3];
	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClientAlive(i) && GetClientTeam(i) == TEAM_INFECTED && FindZombieClass(i) == ZOMBIECLASS_TANK) {

			GetClientAbsOrigin(client, pos);
			GetClientAbsOrigin(i, ipos);
			if (GetVectorDistance(pos, ipos) <= range) return true;
		}
	}
	return false;
}

stock bool IsVectorsCrossed(int client, float torigin[3], float aorigin[3], int f_Distance) {

	float porigin[3];
	float vorigin[3];
	MakeVectorFromPoints(torigin, aorigin, vorigin);
	if (GetVectorDistance(porigin, vorigin) <= f_Distance) return true;
	return false;
}

public void OnEntityDestroyed(int entity) {

	if (IsCommonInfected(entity)) OnCommonInfectedCreated(entity, true);
}

/*stock DestroyCommons() {

	new entity = -1;
	while ((entity = FindEntityByClassname(entity, "infected")) != INVALID_ENT_REFERENCE) {
	    
		AcceptEntityInput(entity, "Kill");
		//SDKUnhook(entity, SDKHook_OnTakeDamage, OnTakeDamage);
		//IgniteEntity(100.0);
	}
}*/

bool IsPlayerZoomed(int client) {
	return (GetEntPropEnt(client, Prop_Send, "m_hZoomOwner") == -1) ? false : true;
}

/*bool:IsPlayerHoldingFire(int client) {
	if (GetEntityFlags(client) & IN_ATTACK) return true;
	return false;
}*/

public Action Timer_DestroyRock(Handle timer, any ent) {

	if (IsValidEntity(ent) && IsValidEdict(ent)) {

		char classname[64];
		GetEntityClassname(ent, classname, sizeof(classname));
		if (StrEqual(classname, "tank_rock", false)) {

			float fTankPos[3], fRockPos[3];
			int tank = -1;
			GetEntPropVector(ent, Prop_Send, "m_vecOrigin", fRockPos);
			for (int i = 1; i <= MaxClients; i++) {

				if (!IsLegitimateClientAlive(i) || GetClientTeam(i) != TEAM_INFECTED || FindZombieClass(i) != ZOMBIECLASS_TANK) continue;
				GetClientAbsOrigin(i, fTankPos);
				if (GetVectorDistance(fTankPos, fRockPos) >= 32.0) continue;

				tank = i;
				break;
			}
			if (!AcceptEntityInput(ent, "Kill")) LogMessage("Could not destroy rock.");
			if (tank != -1) {

				ChangeTankState(tank, "burn");
				FindRandomSurvivorClient(tank, true);
			}
		}
	}

	return Plugin_Stop;
}

public void OnEntityCreated(int entity, const char[] classname) {

	//if (!b_IsActiveRound) return;
	OnEntityCreatedEx(entity, classname);
}

stock void OnEntityCreatedEx(int entity, const char[] classname, bool creationOverride = false) {
	if (iTankRush > 0 && StrEqual(classname, "tank_rock", false)) {
		CreateTimer(1.4, Timer_DestroyRock, entity, TIMER_FLAG_NO_MAPCHANGE);
		return;
	}
	if (b_IsActiveRound && IsWitch(entity)) {
		SetInfectedHealth(entity, 50000);
		OnWitchCreated(entity);
	}
	if (creationOverride || StrEqual(classname, "infected", false)) {
		if (!b_IsActiveRound) return;
		SetInfectedHealth(entity, 50000);
		OnCommonInfectedCreated(entity);	// ALL commons (including specials) get stored.
		SDKHook(entity, SDKHook_OnTakeDamage, OnTakeDamage);

		if (iCommonAffixes >= 1 && CreateCommonAffix(entity) == 1) return;
		if (CommonInfectedQueue.Length > 0) {
			char Model[64];
			CommonInfectedQueue.GetString(0, Model, sizeof(Model));
			SetEntityModel(entity, Model);
			CommonInfectedQueue.Erase(0);
		}
	}
}

bool IsWitch(int entity) {

	if (entity <= 0 || !IsValidEntity(entity)) return false;

	char className[16];
	GetEntityClassname(entity, className, sizeof(className));
	return strcmp(className, "witch") == 0;
}

bool IsCommonInfected(int entity) {

	if (entity <= 0 || !IsValidEntity(entity)) return false;

	char className[16];
	GetEntityClassname(entity, className, sizeof(className));
	return strcmp(className, "infected") == 0;
}

stock void ExperienceBarBroadcast(int client, char[] sStatusEffects) {

	char eBar[64];
	char currExperience[64];
	char currExperienceTarget[64];
	if (GetClientTeam(client) == TEAM_SURVIVOR) {
		ExperienceBar(client, eBar, sizeof(eBar));
		AddCommasToString(ExperienceLevel[client], currExperience, sizeof(currExperience));
		AddCommasToString(CheckExperienceRequirement(client), currExperienceTarget, sizeof(currExperienceTarget));

		if (BroadcastType == 0) PrintHintText(client, "%T", "Hint Text Broadcast 0", client, eBar);
		if (BroadcastType == 1) PrintHintText(client, "%T", "Hint Text Broadcast 1", client, eBar, currExperience, currExperienceTarget);
		if (BroadcastType == 2) PrintHintText(client, "%T", "Hint Text Broadcast 2", client, eBar, currExperience, currExperienceTarget, Points[client]);
	}
	else if (GetClientTeam(client) == TEAM_INFECTED) {

		ExperienceBar(client, eBar, sizeof(eBar), 1);	// armor
		char aBar[64];
		ExperienceBar(client, aBar, sizeof(aBar), 2);	// actual health
		int tHealth = InfectedHealth[client].Get(0, 5);	// total health
		int dHealth = InfectedHealth[client].Get(0, 6);	// damage to health

		AddCommasToString(tHealth - dHealth, currExperience, sizeof(currExperience));
		AddCommasToString(tHealth, currExperienceTarget, sizeof(currExperienceTarget));

		PrintHintText(client, "%T", "Infected Health Broadcast", client, eBar, aBar, currExperience, currExperienceTarget, sStatusEffects);
	}
}

stock int CheckTankingDamage(int infected, int client) {

	int pos = -1;
	int cDamage = 0;

	if (IsLegitimateClient(infected)) pos = FindListPositionByEntity(infected, InfectedHealth[client]);
	else if (IsWitch(infected)) pos = FindListPositionByEntity(infected, WitchDamage[client]);
	else if (IsSpecialCommon(infected)) pos = FindListPositionByEntity(infected, SpecialCommon[client]);
	// Have decided commons shouldn't award tanking damage; it's too easy to abuse.

	if (pos < 0) return 0;

	if (IsLegitimateClient(infected)) cDamage = InfectedHealth[client].Get(pos, 3);
	else if (IsWitch(infected)) cDamage = WitchDamage[client].Get(pos, 3);
	else if (IsSpecialCommon(infected)) cDamage = SpecialCommon[client].Get(pos, 3);
	
	/*

		If the player dealt more damage to the special than took damage from it, they do not receive tanking rewards.
	*/
	return cDamage;
}

stock void WipeDamageContribution(int client) {

	/*

		This function will completely wipe out a players contribution and earnings.
		Use this when a player dies to essentially "give back" the health equal to contribution.
		Other players can then earn the contribution that is restored, albeit a mob that was about to die would
		suddenly gain a bunch of its life force back.
	*/
	if (IsLegitimateClient(client)) {

		InfectedHealth[client].Clear();
		WitchDamage[client].Clear();
		SpecialCommon[client].Clear();
	}
}

stock float CheckTeammateDamages(int infected, int client = -1, bool bIsMyDamageOnly = false) {

	/*

		Common Infected have a shared-health pool, as a result we compare a players
		damage only when considering commons damage; the player who deals the killing blow
		on a common will receive the bonus.

		However, special commons and special infected will have separate health pools.
	*/

	float isDamageValue = 0.0;
	int pos = -1;
	int cHealth = 0;
	int tHealth = 0;
	float tBonus = 0.0;
	int enemytype = -1;
	if (IsLegitimateClient(infected)) enemytype = 0;
	else if (IsWitch(infected)) enemytype = 1;
	else if (IsSpecialCommon(infected)) enemytype = 2;
	else return 0.0;
	//else if (IsCommonInfected(infected)) enemytype = 3;
	for (int i = 1; i <= MaxClients; i++) {

		if (!IsLegitimateClient(i) || GetClientTeam(i) != TEAM_SURVIVOR) continue;
		if (bIsMyDamageOnly && client != i) continue;
		/*
			isDamageValue is a percentage of the total damage a player has dealt to the special infected.
			We calculate this by taking the player damage contribution and dividing it by the total health of the infected.
			we then add this value, and return the total of all players.
			if the value > or = to 1.0, the infected player dies.

			This health bar will display two health bars.
			True health: The actual health the infected player has remaining
			E. Health: The health the infected has FOR YOU
		*/
		if (enemytype == 0) {

			pos = FindListPositionByEntity(infected, InfectedHealth[i]);
			if (pos < 0) continue;	// how?
			cHealth = InfectedHealth[i].Get(pos, 2);
			tHealth = InfectedHealth[i].Get(pos, 1);
		}
		else if (enemytype == 1) {

			pos = FindListPositionByEntity(infected, WitchDamage[i]);
			if (pos < 0) continue;
			cHealth = WitchDamage[i].Get(pos, 2);
			tHealth = WitchDamage[i].Get(pos, 1);
		}
		else if (enemytype == 2) {

			pos = FindListPositionByEntity(infected, SpecialCommon[i]);
			if (pos < 0) continue;
			cHealth = SpecialCommon[i].Get(pos, 2);
			tHealth = SpecialCommon[i].Get(pos, 1);
		}
		tBonus = (cHealth * 1.0) / (tHealth * 1.0);
		isDamageValue += tBonus;
	}
	//PrintToChatAll("Damage percent: %3.3f", isDamageValue);
	if (isDamageValue > 1.0) isDamageValue = 1.0;
	return isDamageValue;
}

stock void DisplayInfectedHealthBars(int survivor, int infected) {

	if (iRPGMode == -1 || IsCommonInfected(infected)) return;

	char text[512];
	if (IsLegitimateClient(infected)) GetClientName(infected, text, sizeof(text));
	else if (IsWitch(infected)) Format(text, sizeof(text), "Bitch");
	else if (IsSpecialCommon(infected)) GetCommonValueAtPos(text, sizeof(text), infected, SUPER_COMMON_NAME);

	//Format(text, sizeof(text), "%s %s", GetConfigValue("director team name?"), text);
	GetInfectedHealthBar(survivor, infected, false, clientContributionHealthDisplay[survivor], sizeof(clientContributionHealthDisplay[]));
	if (currLivingSurvivors > 1) {
		GetInfectedHealthBar(survivor, infected, true, clientTrueHealthDisplay[survivor], sizeof(clientTrueHealthDisplay[]));
		Format(text, sizeof(text), "E.HP%s(%s)\nCNT%s", clientTrueHealthDisplay[survivor], text, clientContributionHealthDisplay[survivor]);
	}
	else Format(text, sizeof(text), "CNT%s(%s)", clientContributionHealthDisplay[survivor], text);
	PrintCenterText(survivor, text);
}

stock void GetStatusEffects(int client, int EffectType = 0, char[] theStringToStoreItIn, int theSizeOfTheString) {

	int Count = 0;
	int iNumStatusEffects = 0;
	// NEGATIVE effects
	//new printClient = client;

	//decl String:TargetName[64];
	//GetClientAimTargetEx(client, TargetName, sizeof(TargetName), true);
	//client = StringToInt(TargetName);
	//if (!IsLegitimateClientAlive(client) || GetClientTeam(client) != GetClientTeam(printClient)) client = printClient;
	int clientFlags = GetEntityFlags(client);
	if (EffectType == 0) {

		//new AcidCount = GetClientStatusEffect(client, Handle EntityOnFire, "acid");
		int FireCount = GetClientStatusEffect(client, "burn");
		int AcidCount = GetClientStatusEffect(client, "acid");
		Format(theStringToStoreItIn, theSizeOfTheString, "[-]");
		if (DoomTimer != 0) Format(theStringToStoreItIn, theSizeOfTheString, "[Dm%d]%s", iDoomTimer - DoomTimer, theStringToStoreItIn);
		if (bIsSurvivorFatigue[client]) Format(theStringToStoreItIn, theSizeOfTheString, "[Fa]%s", theStringToStoreItIn);

		//Count = GetClientStatusEffect(client, "burn");
		if (FireCount > 0) iNumStatusEffects++;
		if (FireCount >= 3) Format(theStringToStoreItIn, theSizeOfTheString, "[Bu++]%s", theStringToStoreItIn);
		else if (FireCount >= 2) Format(theStringToStoreItIn, theSizeOfTheString, "[Bu++]%s", theStringToStoreItIn);
		else if (FireCount > 0) Format(theStringToStoreItIn, theSizeOfTheString, "[Bu]%s", theStringToStoreItIn);

		//Count = GetClientStatusEffect(client, "acid");
		if (AcidCount > 0) iNumStatusEffects++;
		if (AcidCount >= 3) Format(theStringToStoreItIn, theSizeOfTheString, "[Ab++]%s", theStringToStoreItIn);
		else if (AcidCount >= 2) Format(theStringToStoreItIn, theSizeOfTheString, "[Ab+]%s", theStringToStoreItIn);
		else if (AcidCount > 0) Format(theStringToStoreItIn, theSizeOfTheString, "[Ab]%s", theStringToStoreItIn);

		Count = GetClientStatusEffect(client, "reflect");
		if (Count > 0) iNumStatusEffects++;
		if (Count >= 3) Format(theStringToStoreItIn, theSizeOfTheString, "[Re++]%s", theStringToStoreItIn);
		else if (Count >= 2) Format(theStringToStoreItIn, theSizeOfTheString, "[Re+]%s", theStringToStoreItIn);
		else if (Count > 0) Format(theStringToStoreItIn, theSizeOfTheString, "[Re]%s", theStringToStoreItIn);

		if (ISBLIND[client] != INVALID_HANDLE) {

			Format(theStringToStoreItIn, theSizeOfTheString, "[Bl]%s", theStringToStoreItIn);
			iNumStatusEffects++;
		}
		if (ISEXPLODE[client] != INVALID_HANDLE || IsClientInRangeSpecialAmmo(client, "x") == -2.0) {

			Format(theStringToStoreItIn, theSizeOfTheString, "[Ex]%s", theStringToStoreItIn);
			iNumStatusEffects++;
		}
		if (ISFROZEN[client] != INVALID_HANDLE) {

			Format(theStringToStoreItIn, theSizeOfTheString, "[Fr]%s", theStringToStoreItIn);
			iNumStatusEffects++;
		}
		
		if (ISSLOW[client] != INVALID_HANDLE || IsClientInRangeSpecialAmmo(client, "s") == -2.0) {
			if (fSlowSpeed[client] == 1.0) {
				if (ISSLOW[client] != INVALID_HANDLE) {
					KillTimer(ISSLOW[client]);
					ISSLOW[client] = INVALID_HANDLE;
				}
			}
			else {
				if (fSlowSpeed[client] < 1.0) Format(theStringToStoreItIn, theSizeOfTheString, "[Sl]%s", theStringToStoreItIn);
				else Format(theStringToStoreItIn, theSizeOfTheString, "[Sp]%s", theStringToStoreItIn);
				iNumStatusEffects++;
			}
		}
		//if (ISSLOW[client] != INVALID_HANDLE) Format(theStringToStoreItIn, theSizeOfTheString, "[Sl]%s", theStringToStoreItIn);
		
		if (ISFROZEN[client] != INVALID_HANDLE && FireCount > 0) {

			Format(theStringToStoreItIn, theSizeOfTheString, "[St]%s", theStringToStoreItIn);
			iNumStatusEffects++;
		}
		if (FireCount > 0 && AcidCount > 0) {

			Format(theStringToStoreItIn, theSizeOfTheString, "[Sc]%s", theStringToStoreItIn);
			iNumStatusEffects++;
		}
		if (!(clientFlags & FL_ONGROUND)) {

			Format(theStringToStoreItIn, theSizeOfTheString, "[Fl]%s", theStringToStoreItIn);
			iNumStatusEffects++;
		}
		if (bIsInCombat[client]) Format(theStringToStoreItIn, theSizeOfTheString, "[Ic]%s", theStringToStoreItIn);
		if (ISBILED[client]) {

			Format(theStringToStoreItIn, theSizeOfTheString, "[Bi]%s", theStringToStoreItIn);
			iNumStatusEffects++;
		}
		if (ISDAZED[client] > GetEngineTime()) {

			Format(theStringToStoreItIn, theSizeOfTheString, "[Dz]%s", theStringToStoreItIn);
			iNumStatusEffects++;
		}
		
		if (PlayerHasWeakness(client)) {

			Format(theStringToStoreItIn, theSizeOfTheString, "[Wk]%s", theStringToStoreItIn);
			iNumStatusEffects++;
		}
		
		if (IsSpecialCommonInRange(client, 'd')) {

			Format(theStringToStoreItIn, theSizeOfTheString, "[Re]%s", theStringToStoreItIn);
			iNumStatusEffects++;
		}
		
		/*if (IsActiveAmmoCooldown(client, 'H')) Format(theStringToStoreItIn, theSizeOfTheString, "[HeA]%s", theStringToStoreItIn);
		if (IsActiveAmmoCooldown(client, 'h')) Format(theStringToStoreItIn, theSizeOfTheString, "[LeA]%s", theStringToStoreItIn);
		if (IsActiveAmmoCooldown(client, 'b')) Format(theStringToStoreItIn, theSizeOfTheString, "[BeA]%s", theStringToStoreItIn);
		if (IsActiveAmmoCooldown(client, 's')) Format(theStringToStoreItIn, theSizeOfTheString, "[SlA]%s", theStringToStoreItIn);
		if (IsActiveAmmoCooldown(client, 'x')) Format(theStringToStoreItIn, theSizeOfTheString, "[ExA]%s", theStringToStoreItIn);
		if (IsActiveAmmoCooldown(client, 'g')) Format(theStringToStoreItIn, theSizeOfTheString, "[GrA]%s", theStringToStoreItIn);
		if (IsActiveAmmoCooldown(client, 'B')) Format(theStringToStoreItIn, theSizeOfTheString, "[BiA]%s", theStringToStoreItIn);
		if (IsActiveAmmoCooldown(client, 'O')) Format(theStringToStoreItIn, theSizeOfTheString, "[OdA]%s", theStringToStoreItIn);
		if (IsActiveAmmoCooldown(client, 'E')) Format(theStringToStoreItIn, theSizeOfTheString, "[BkA]%s", theStringToStoreItIn);
		if (IsActiveAmmoCooldown(client, 'a')) Format(theStringToStoreItIn, theSizeOfTheString, "[AdA]%s", theStringToStoreItIn);
		if (IsActiveAmmoCooldown(client, 'W')) Format(theStringToStoreItIn, theSizeOfTheString, "[DkA]%s", theStringToStoreItIn);*/

		//if (printClient != client) Format(theStringToStoreItIn, theSizeOfTheString, "%s\n%s", TargetName, theStringToStoreItIn);
	}
	else if (EffectType == 1) {		// POSITIVE EFFECTS

		Format(theStringToStoreItIn, theSizeOfTheString, "[+]");
		FormatEffectOverTimeBuffs(client, theStringToStoreItIn, theSizeOfTheString);
		//if (printClient != client) Format(theStringToStoreItIn, theSizeOfTheString, "%s\n%s", TargetName, theStringToStoreItIn);
		if (!bIsInCombat[client]) Format(theStringToStoreItIn, theSizeOfTheString, "%s[Oc]", theStringToStoreItIn);
		if (IsClientInRangeSpecialAmmo(client, "b") == -2.0) {

			Format(theStringToStoreItIn, theSizeOfTheString, "%s[Be]", theStringToStoreItIn);
			iNumStatusEffects++;
		}
		if (IsClientInRangeSpecialAmmo(client, "h") == -2.0) {

			Format(theStringToStoreItIn, theSizeOfTheString, "%s[Le]", theStringToStoreItIn);
			iNumStatusEffects++;
		}
		if (IsClientInRangeSpecialAmmo(client, "g") == -2.0) {

			Format(theStringToStoreItIn, theSizeOfTheString, "%s[Gr]", theStringToStoreItIn);
			iNumStatusEffects++;
		}
		if (IsClientInRangeSpecialAmmo(client, "H") == -2.0) {

			Format(theStringToStoreItIn, theSizeOfTheString, "%s[He]", theStringToStoreItIn);
			iNumStatusEffects++;
		}
		if (IsClientInRangeSpecialAmmo(client, "d") == -2.0) {

			Format(theStringToStoreItIn, theSizeOfTheString, "%s[Da]", theStringToStoreItIn);
			iNumStatusEffects++;
		}
		if (IsClientInRangeSpecialAmmo(client, "D") == -2.0) {

			Format(theStringToStoreItIn, theSizeOfTheString, "%s[Ds]", theStringToStoreItIn);
			iNumStatusEffects++;
		}
		if (IsClientInRangeSpecialAmmo(client, "R") == -2.0) {

			Format(theStringToStoreItIn, theSizeOfTheString, "%s[Re]", theStringToStoreItIn);
			iNumStatusEffects++;
		}
		if (IsClientInRangeSpecialAmmo(client, "B") == -2.0) {

			Format(theStringToStoreItIn, theSizeOfTheString, "%s[Bi]", theStringToStoreItIn);
			iNumStatusEffects++;
		}
		if (IsClientInRangeSpecialAmmo(client, "O") == -2.0) {

			Format(theStringToStoreItIn, theSizeOfTheString, "%s[Od]", theStringToStoreItIn);
			iNumStatusEffects++;
		}
		if (IsClientInRangeSpecialAmmo(client, "E") == -2.0) {

			Format(theStringToStoreItIn, theSizeOfTheString, "%s[Bk]", theStringToStoreItIn);
			iNumStatusEffects++;
		}
		if (HasAdrenaline(client)) {

			Format(theStringToStoreItIn, theSizeOfTheString, "%s[Ad]", theStringToStoreItIn);
			iNumStatusEffects++;
		}
		if (clientFlags & FL_INWATER) {

			Format(theStringToStoreItIn, theSizeOfTheString, "%s[Wa]", theStringToStoreItIn);
			iNumStatusEffects++;
		}
	}
	Format(ClientStatusEffects[client][EffectType], 64, "%s", theStringToStoreItIn);
	//PrintToChat(client, "%s", ClientStatusEffects[client][EffectType]);
	//if (EffectType == 0) Format(theStringToStoreItIn, theSizeOfTheString, "[-]%s", theStringToStoreItIn);
	//else Format(theStringToStoreItIn, theSizeOfTheString, "[+]%s", theStringToStoreItIn);

	if (IsPvP[client] != 0) Format(theStringToStoreItIn, theSizeOfTheString, "%s[PvP]", theStringToStoreItIn);

	MyStatusEffects[client] = iNumStatusEffects;
}

/*stock ToggleTank(client, bool:bDisableTank = false) {

	if (!bDisableTank && (!IsValidEntity(MyVomitChase[client]) || MyVomitChase[client] == -1)) {

		decl String:TargetName[64];

		if (IsValidEntity(MyVomitChase[client])) {

			AcceptEntityInput(MyVomitChase[client], "Kill");
			MyVomitChase[client] = -1;
		}
		MyVomitChase[client] = CreateEntityByName("info_goal_infected_chase");
		if (IsValidEntity(MyVomitChase[client])) {

			new Float:ClientPos[3];
			GetClientAbsOrigin(client, ClientPos);
			ClientPos[2] += 20.0;

			DispatchKeyValueVector(MyVomitChase[client], "origin", ClientPos);
			Format(TargetName, sizeof(TargetName), "goal_infected%d", client);
			DispatchKeyValue(MyVomitChase[client], "targetname", TargetName);
			GetClientName(client, TargetName, sizeof(TargetName));
			DispatchKeyValue(client, "parentname", TargetName);
			DispatchSpawn(MyVomitChase[client]);
			SetVariantString(TargetName);
			AcceptEntityInput(MyVomitChase[client], "SetParent", MyVomitChase[client], MyVomitChase[client], 0);
			ActivateEntity(MyVomitChase[client]);
			AcceptEntityInput(MyVomitChase[client], "Enable");
		}
	}
	else if (bDisableTank) {

		if (IsValidEntity(MyVomitChase[client])) AcceptEntityInput(MyVomitChase[client], "Kill");
		MyVomitChase[client] = -1;
	}
}*/

// Eyal282 here, IsPlayerFeeble doesn't exist.
/*
stock bool IsClientCleansing(int client) {

	if (IsClientInRangeSpecialAmmo(client, "C") == -2.0 && !IsPlayerFeeble(client)) return true;
	return false;
}
*/
stock bool IsActiveAmmoCooldown(int client, int effect = '0', char[] activeTalentSearchKey = "none") {
	char result[2][64];
	char EffectT[4];
	Format(EffectT, sizeof(EffectT), "%c", effect);
	int size = PlayerActiveAmmo[client].Length;
	int pos = -1;
	char text[64];
	for (int i = 0; i < size; i++) {
		pos = PlayerActiveAmmo[client].Get(i);
		GetTalentNameAtMenuPosition(client, pos, result[0], sizeof(result[]));
		if (pos < 0) continue;	// wtf?
		//ActiveAmmoCooldownKeys[client]				= a_Menu_Talents.Get(pos, 0);
		ActiveAmmoCooldownValues[client]			= a_Menu_Talents.Get(pos, 1);
		if (StrEqual(activeTalentSearchKey, "none")) {
			ActiveAmmoCooldownValues[client].GetString(SPELL_AMMO_EFFECT, text, sizeof(text));
			if (StrContains(text, EffectT, true) == -1) continue;
		}
		else {
			ActiveAmmoCooldownValues[client].GetString(ABILITY_ACTIVE_EFFECT, text, sizeof(text));
			if (!StrEqual(text, activeTalentSearchKey, true)) continue;	// case sensitive
		}
		if (CheckActiveAmmoCooldown(client, result[0]) == 2) return true;
	}
	return false;
}

stock void GetSpecialAmmoEffect(char[] TheValue, int TheSize, int client, char[] TalentName) {

	int pos			= GetMenuPosition(client, TalentName);
	if (pos >= 0) {

		//SpecialAmmoEffectKeys[client]				= a_Menu_Talents.Get(pos, 0);
		SpecialAmmoEffectValues[client]			= a_Menu_Talents.Get(pos, 1);

		SpecialAmmoEffectValues[client].GetString(SPELL_AMMO_EFFECT, TheValue, TheSize);
	}
}

stock int GetPlayerStamina(int client) {

	/*

		This function gets a players maximum stamina, which is important so they don't regenerate beyond it.
	*/
	/*new StaminaMax = GetConfigValueInt("survivor stamina?");
	new StaminaMax_Temp = 0;
	new Endu = GetTalentStrength(client, "endurance");
	for (new i = 0; i < Endu; i++) {

		StaminaMax_Temp += RoundToCeil(StaminaMax * GetConfigValueFloat("endurance stam?"));
	}
	StaminaMax += StaminaMax_Temp;*/

	int StaminaMax = iSurvivorStaminaMax + RoundToCeil(PlayerLevel[client] * fStaminaPerPlayerLevel) + RoundToCeil(SkyLevel[client] * fStaminaPerSkyLevel);
	int StaminaBonus = RoundToCeil(GetAbilityStrengthByTrigger(client, client, "getstam", _, 0, _, _, "stamina", _, _, 2));
	if (StaminaBonus > 0) StaminaMax += StaminaBonus;

	float TheAbilityMultiplier = 0.0;
	TheAbilityMultiplier = GetAbilityMultiplier(client, "T");
	//if (TheAbilityMultiplier == -1.0) TheAbilityMultiplier = 0.0;	// no change
	if (TheAbilityMultiplier != -1) StaminaMax += RoundToCeil(StaminaMax * TheAbilityMultiplier);
	// Here we make sure that the players current stamina never goes above their maximum stamina.
	if (SurvivorStamina[client] > StaminaMax) SurvivorStamina[client] = StaminaMax;
	return StaminaMax;
}

stock void DisplayInfectedHUD(int client, int statusType) {
	GetStatusEffects(client, statusType, clientStatusEffectDisplay[client], sizeof(clientStatusEffectDisplay[]));
	ExperienceBarBroadcast(client, clientStatusEffectDisplay[client]);
}

stock void DisplayHUD(int client, int statusType) {

	if (iRPGMode >= 1) {
		GetStatusEffects(client, statusType, clientStatusEffectDisplay[client], sizeof(clientStatusEffectDisplay[]));

		if (IsLegitimateClientAlive(client) && GetClientTeam(client) == TEAM_INFECTED && !IsFakeClient(client)) {

			int healthremaining = GetHumanInfectedHealth(client);
			if (healthremaining > 0) SetEntityHealth(client, GetHumanInfectedHealth(client));
		}

		char text[64];
		//decl String:text2[64];
		char testelim[1];
		char EnemyName[64];
		float TargetPos[3];
		int enemycombatant = GetAimTargetPosition(client, TargetPos);
		int enemytype = -1;
		//GetClientAimTargetEx(client, EnemyName, sizeof(EnemyName), true);
		//new enemycombatant = LastAttackedUser[client];
		//new enemycombatant = StringToInt(EnemyName);
		//if (!IsWitch(enemycombatant) && !IsLegitimateClientAlive(enemycombatant) || IsLegitimateClientAlive(enemycombatant) && !IsFakeClient(enemycombatant)) enemycombatant = -1;
		if (IsSpecialCommon(enemycombatant)) enemytype = 0;
		else if (IsWitch(enemycombatant)) enemytype = 1;
		else if (IsLegitimateClientAlive(enemycombatant)) enemytype = 2;
		
		if (enemytype != -1) {

			if (enemytype == 0) GetCommonValueAtPos(EnemyName, sizeof(EnemyName), enemycombatant, SUPER_COMMON_NAME);
			else if (enemytype == 1) Format(EnemyName, sizeof(EnemyName), "Witch");
			else {
				if (!IsSurvivorBot(enemycombatant)) GetClientName(enemycombatant, EnemyName, sizeof(EnemyName));
				else GetSurvivorBotName(enemycombatant, EnemyName, sizeof(EnemyName));
			}
		}
		else enemycombatant = -1;
		Format(testelim, sizeof(testelim), " ");
		if (enemytype == 2 && GetClientTeam(enemycombatant) == TEAM_SURVIVOR) {

			char TheClass[64];
			int myClassLevel = CartelLevel(enemycombatant);
			if (myClassLevel < 0) myClassLevel = 0;

			Format(TheClass, sizeof(TheClass), "%T", "Vanilla", client);


			char classLevelText[64];
			AddCommasToString(myClassLevel, classLevelText, sizeof(classLevelText));
			Format(EnemyName, sizeof(EnemyName), "(Lv.%s) %s", classLevelText, EnemyName);
			//}
			//Format(EnemyName, sizeof(EnemyName), "%s %s Lv.%d", TheClass, EnemyName, PlayerLevel[enemycombatant]);
			//if (IsPvP[enemycombatant] != 0) Format(EnemyName, sizeof(EnemyName), "%s[PvP]", EnemyName);
		}

		//if (!StrEqual(ActiveSpecialAmmo[client], "none")) Format(text, sizeof(text), "HC %s %s STA %s %s %s", testelim, testelim, testelim, testelim, ActiveSpecialAmmo[client]);
		char targetHealthText[64];
		if (bJetpack[client]) {

			int PlayerMaxStamina = GetPlayerStamina(client);
			float PlayerCurrStamina = ((SurvivorStamina[client] * 1.0) / (PlayerMaxStamina * 1.0)) * 100.0;

			char pct[4];
			Format(pct, sizeof(pct), "%");

			Format(text, sizeof(text), "Jetpack Fuel: %3.2f %s\n%s", PlayerCurrStamina, pct, clientStatusEffectDisplay[client]);
		}
		else if (iShowDetailedDisplayAlways == 1 && enemytype != -1) {
			if (enemytype < 2 || GetClientTeam(enemycombatant) != TEAM_SURVIVOR) {
				AddCommasToString(GetTargetHealth(client, enemycombatant), targetHealthText, sizeof(targetHealthText));
				Format(text, sizeof(text), "%s: %sHP\n%s\n%d HITS!", EnemyName, targetHealthText, clientStatusEffectDisplay[client], ConsecutiveHits[client]);
			}
			else if (GetClientTeam(enemycombatant) == TEAM_SURVIVOR) {
				AddCommasToString(GetTargetHealth(client, enemycombatant, true), targetHealthText, sizeof(targetHealthText));
				Format(text, sizeof(text), "%s HP: %s %s\n%s\n%d HITS!", EnemyName, testelim, targetHealthText, clientStatusEffectDisplay[enemycombatant], ConsecutiveHits[client]);
			}
		}
		else {
			Format(text, sizeof(text), "%s", clientStatusEffectDisplay[client]);
		}
		if (strlen(text) > 1) PrintHintText(client, text);
	}
}

stock void GetPlayerStaminaBar(int client, char[] eBar, int theSize) {

	Format(eBar, theSize, "[----------]");
	if (IsLegitimateClientAlive(client)) {

		/*

			Players have a stamina bar.
		*/

		float eCnt = 0.0;
		float ePct = (SurvivorStamina[client] * 1.0 / (GetPlayerStamina(client) * 1.0)) * 100.0;
		for (int i = 1; i < strlen(eBar); i++) {

			if (eCnt + 10.0 <= ePct) {

				eBar[i] = '=';
				eCnt += 10.0;
			}
		}
	}
}

stock float GetTankingContribution(int survivor, int infected) {

	int TotalHealth = 0;
	int DamageTaken = 0;

	int pos = -1;
	if (IsLegitimateClient(infected)) pos = FindListPositionByEntity(infected, InfectedHealth[survivor]);
	else if (IsWitch(infected)) pos = FindListPositionByEntity(infected, WitchDamage[survivor]);
	else if (IsSpecialCommon(infected)) pos = FindListPositionByEntity(infected, SpecialCommon[survivor]);

	if (pos < 0) return 0.0;

	if (IsWitch(infected)) {

		TotalHealth		= WitchDamage[survivor].Get(pos, 1);
		DamageTaken		= WitchDamage[survivor].Get(pos, 3);
	}
	else if (IsSpecialCommon(infected)) {

		TotalHealth		= SpecialCommon[survivor].Get(pos, 1);
		DamageTaken		= SpecialCommon[survivor].Get(pos, 3);
	}
	else if (IsLegitimateClient(infected) && GetClientTeam(infected) == TEAM_INFECTED) {

		TotalHealth		= InfectedHealth[survivor].Get(pos, 1);
		DamageTaken		= InfectedHealth[survivor].Get(pos, 3);
	}
	if (DamageTaken == 0) return 0.0;
	if (DamageTaken > TotalHealth) return 1.0;
	//new Float:TheDamageTaken = (DamageTaken * 1.0) / (TotalHealth * 1.0);
	return ((DamageTaken * 1.0) / (TotalHealth * 1.0));
}

stock int GetTargetHealth(int client, int target, bool MyHealth = false) {

	int TotalHealth = 0;
	int DamageDealt = 0;

	int pos = -1;
	if (IsSpecialCommon(target)) pos = FindListPositionByEntity(target, SpecialCommon[client]);
	else if (IsWitch(target)) pos = FindListPositionByEntity(target, WitchDamage[client]);
	else if (IsLegitimateClientAlive(target) && GetClientTeam(target) == TEAM_INFECTED) pos = FindListPositionByEntity(target, InfectedHealth[client]);
	else if (IsLegitimateClientAlive(target) && GetClientTeam(target) == TEAM_SURVIVOR) {

		return GetClientHealth(target);
	}

	if (pos >= 0) {

		if (IsWitch(target)) {

			TotalHealth		= WitchDamage[client].Get(pos, 1);
			DamageDealt		= WitchDamage[client].Get(pos, 2);
		}
		else if (IsLegitimateClient(target) && GetClientTeam(target) == TEAM_INFECTED) {

			TotalHealth		= InfectedHealth[client].Get(pos, 1);
			DamageDealt		= InfectedHealth[client].Get(pos, 2);
		}
		else if (IsSpecialCommon(target)) {

			TotalHealth		= SpecialCommon[client].Get(pos, 1);
			DamageDealt		= SpecialCommon[client].Get(pos, 2);
		}
		if (!MyHealth) TotalHealth = RoundToCeil((1.0 - CheckTeammateDamages(target, client)) * TotalHealth);
		else TotalHealth -= DamageDealt;
	}
	return TotalHealth;
}

stock int GetRatingReward(int survivor, int infected) {

	int RatingRewardDamage = 0;
	int RatingRewardTanking = 0;

	// If the player took less total damage than the health of the mob, you do Rating += RoundToFloor((PlayerDamageTaken / MobTotalHealth) * 100.0);
	int TotalHealth = 0;
	//new DamageTaken = 0;
	//new DamageDealt = 0;
	float RatingMultiplier = 0.0;

	int pos = -1;
	if (IsLegitimateClient(infected)) pos = FindListPositionByEntity(infected, InfectedHealth[survivor]);
	else if (IsWitch(infected)) pos = FindListPositionByEntity(infected, WitchDamage[survivor]);
	else if (IsSpecialCommon(infected)) pos = FindListPositionByEntity(infected, SpecialCommon[survivor]);

	if (pos < 0) return 0;

	if (IsWitch(infected)) {

		TotalHealth		= WitchDamage[survivor].Get(pos, 1);
		//DamageTaken		= Handle WitchDamage[survivor].Get(pos, 3);
		RatingMultiplier = fRatingMultTank;
	}
	else if (IsSpecialCommon(infected)) {

		TotalHealth		= SpecialCommon[survivor].Get(pos, 1);
		//DamageTaken		= Handle SpecialCommon[survivor].Get(pos, 3);
		RatingMultiplier = fRatingMultSupers;
	}
	else if (IsLegitimateClient(infected) && GetClientTeam(infected) == TEAM_INFECTED) {

		TotalHealth		= InfectedHealth[survivor].Get(pos, 1);
		//DamageTaken		= Handle InfectedHealth[survivor].Get(pos, 3);
		if (FindZombieClass(infected) != ZOMBIECLASS_TANK) RatingMultiplier = fRatingMultSpecials;
		else RatingMultiplier = fRatingMultTank;
	}
	if (RatingMultiplier <= 0.0) return 0;

	//if (DamageDealt > TotalHealth) DamageDealt = TotalHealth;

	RatingRewardDamage = RoundToFloor(CheckTeammateDamages(infected, survivor, true) * 100.0);
	
	if (TotalHealth <= 0) return 0;

	//RatingRewardTanking = RoundToCeil(RatingReductionMult * RatingRewardTanking);

	RatingRewardDamage = RoundToFloor(RatingRewardDamage * RatingMultiplier);
	RatingRewardDamage += RatingRewardTanking;	// 0 if the user is not a tank
	return RatingRewardDamage;
}

stock int GetHumanInfectedHealth(int client) {

	float isHealthRemaining = CheckTeammateDamages(client);
	return RoundToCeil(GetMaximumHealth(client) * isHealthRemaining);
}

stock float GetClientHealthPercentageSurvivor(int client, bool GetHealthRemaining = false) {
	float fHealthRemaining = (GetClientHealth(client) * 1.0) / (GetMaximumHealth(client) * 1.0);
	if (GetHealthRemaining) return fHealthRemaining;
	return 1.0 - fHealthRemaining;
}

stock float GetClientHealthPercentage(int client, int target, bool GetHealthRemaining = false) {
	int pos = -1;
	if (IsLegitimateClient(target)) {
		if (GetClientTeam(target) == TEAM_INFECTED) pos = FindListPositionByEntity(target, InfectedHealth[client]);
		else return GetClientHealthPercentageSurvivor(target, GetHealthRemaining);
	}
	else if (IsWitch(target)) pos = FindListPositionByEntity(target, WitchDamage[client]);
	else if (IsSpecialCommon(target)) pos = FindListPositionByEntity(target, SpecialCommon[client]);
	else if (IsCommonInfected(target)) pos = FindListPositionByEntity(target, CommonInfected);
	if (pos < 0) return -1.0;
	float fHealthRemaining = CheckTeammateDamages(target, client);
	if (GetHealthRemaining) return 1.0 - fHealthRemaining;
	return fHealthRemaining;
}

stock void GetInfectedHealthBar(int survivor, int infected, bool bTrueHealth = false, char[] eBar, int theSize) {

	Format(eBar, theSize, "[----------------------------------------]");

	int pos = 0;
	if (IsLegitimateClient(infected)) pos = FindListPositionByEntity(infected, InfectedHealth[survivor]);
	else if (IsWitch(infected)) pos = FindListPositionByEntity(infected, WitchDamage[survivor]);
	else if (IsSpecialCommon(infected)) pos = FindListPositionByEntity(infected, SpecialCommon[survivor]);
	if (pos >= 0) {

		float isHealthRemaining = CheckTeammateDamages(infected, survivor);

		// isDamageContribution is the total damage the player has, themselves, dealt to the special infected.
		int isDamageContribution = 0;
		int isTotalHealth = 0;
		if (IsLegitimateClient(infected)) {

			isDamageContribution = InfectedHealth[survivor].Get(pos, 2);
			isTotalHealth = InfectedHealth[survivor].Get(pos, 1);
		}
		else if (IsWitch(infected)) {

			isDamageContribution = WitchDamage[survivor].Get(pos, 2);
			isTotalHealth = WitchDamage[survivor].Get(pos, 1);
		}
		else if (IsSpecialCommon(infected)) {

			isDamageContribution = SpecialCommon[survivor].Get(pos, 2);
			isTotalHealth = SpecialCommon[survivor].Get(pos, 1);
		}

		
		//new Float:tPct = 100.0 - (isHealthRemaining * 100.0);
		//new Float:yPct = ((isDamageContribution * 1.0) / (isTotalHealth * 1.0) * 100.0);
		float ePct = 0.0;
		if (bTrueHealth) ePct = 100.0 - (isHealthRemaining * 100.0);
		else ePct = ((isDamageContribution * 1.0) / (isTotalHealth * 1.0) * 100.0);
		float eCnt = 0.0;

		for (int i = 1; i + 1 < strlen(eBar); i++) {

			if (eCnt + 2.5 < ePct) {

				eBar[i] = '|';
				eCnt += 2.5;
			}
		}
	}
}

stock void ExperienceBar(int client, char[] sTheString, int iTheSize, int iBarType = 0, bool bReturnValue = false) {// 0 XP, 1 Infected armor (humans only), 2 Infected Health from talents, etc. (humans only)

	//decl String:eBar[256];
	float ePct = 0.0;
	if (iBarType == 0) ePct = ((ExperienceLevel[client] * 1.0) / (CheckExperienceRequirement(client) * 1.0)) * 100.0;
	else if (iBarType == 1) ePct = 100.0 - CheckTeammateDamages(client) * 100.0;
	else if (iBarType == 2) {

		ePct = (InfectedHealth[client].Get(0, 6) / InfectedHealth[client].Get(0, 5)) * 100.0;
	}
	if (bReturnValue) {

		Format(sTheString, iTheSize, "%3.3f", ePct);
	}
	else {

		float eCnt = 0.0;
		//Format(eBar, sizeof(eBar), "[--------------------]");
		Format(sTheString, iTheSize, "[....................]");

		for (int i = 1; i + 1 <= strlen(sTheString); i++) {

			if (eCnt + 10.0 < ePct) {

				sTheString[i] = '|';
				eCnt += 5.0;
			}
		}
	}

	//return eBar;
}

stock void MenuExperienceBar(int client, int currXP = -1, int nextXP = -1, char[] eBar, int theSize) {

	float ePct = 0.0;
	if (currXP == -1) currXP = ExperienceLevel[client];
	if (nextXP == -1) nextXP = CheckExperienceRequirement(client);
	ePct = ((currXP * 1.0) / (nextXP * 1.0)) * 100.0;

	float eCnt = 0.0;
	Format(eBar, theSize, "[....................]");

	for (int i = 1; i + 1 <= strlen(eBar); i++) {

		if (eCnt < ePct) {

			eBar[i] = '|';
			eCnt += 5.0;
		}
	}
}

public Action CMD_TeamChatCommand(int client, int args) {

	if (QuickCommandAccess(client, args, true)) {

		// Set colors for chat
		if (ChatTrigger(client, args, true)) return Plugin_Continue;
		else return Plugin_Handled;
	}
	return Plugin_Handled;
}

public Action CMD_ChatCommand(int client, int args) {

	if (QuickCommandAccess(client, args, false)) {

		// Set Colors for chat
		if (ChatTrigger(client, args, false)) return Plugin_Continue;
		else return Plugin_Handled;
	}
	return Plugin_Handled;
}

stock int CartelLevel(int client) {

	//new CartelStrength = GetTalentStrength(client, "constitution") + GetTalentStrength(client, "agility") + GetTalentStrength(client, "resilience") + GetTalentStrength(client, "technique") + GetTalentStrength(client, "endurance") + GetTalentStrength(client, "luck");
	//return CartelStrength;
	return PlayerLevel[client];
}

stock bool IsOpenRPGMenu(char[] searchString) {
	char[][] RPGCommands = new char[RPGMenuCommandExplode][64];
	ExplodeString(RPGMenuCommand, ",", RPGCommands, RPGMenuCommandExplode, 64);
	for (int i = 0; i < RPGMenuCommandExplode; i++) {
		if (StrContains(searchString, RPGCommands[i], false) != -1) return true;
	}
	return false;
}

public bool ChatTrigger(int client, int args, bool teamOnly) {

	if (!IsLegitimateClient(client)) return true;
	char[] sBuffer = new char[MAX_CHAT_LENGTH];
	char[] Message = new char[MAX_CHAT_LENGTH];
	char Name[64];
	char authString[64];
	GetClientAuthId(client, AuthId_Steam2, authString, sizeof(authString));
	GetClientName(client, Name, sizeof(Name));
	GetCmdArg(1, sBuffer, MAX_CHAT_LENGTH);
	if (sBuffer[0] == '!' && IsOpenRPGMenu(sBuffer)) {
		CMD_OpenRPGMenu(client);
		return false;	// if we want to suppress the chat command
	}
	Format(LastSpoken[client], sizeof(LastSpoken[]), "%s", sBuffer);
	char TagColour[64];
	char TagName[64];
	char ChatColour[64];
	if (ChatSettings[client].Length != 3) {
		ChatSettings[client].Resize(3);
		Format(TagColour, sizeof(TagColour), "none");
		Format(TagName, sizeof(TagName), "none");
		Format(ChatColour, sizeof(ChatColour), "none");
	}
	else {
		ChatSettings[client].GetString(0, TagColour, sizeof(TagColour));
		ChatSettings[client].GetString(1, TagName, sizeof(TagName));
		ChatSettings[client].GetString(2, ChatColour, sizeof(ChatColour));
	}
	if (StrEqual(TagColour, "none", false)) {
		Format(TagColour, sizeof(TagColour), "N");
		ChatSettings[client].SetString(0, TagColour);
	}
	if (!StrEqual(TagName, "none", false)) {
		Format(Message, MAX_CHAT_LENGTH, "{%s}%s", TagColour, TagName);
	}
	else {
		GetClientName(client, Message, MAX_CHAT_LENGTH);
		Format(Message, MAX_CHAT_LENGTH, "{%s}%s", TagColour, Message);
	}
	if (StrEqual(ChatColour, "none", false)) {
		Format(ChatColour, sizeof(ChatColour), "N");
		ChatSettings[client].SetString(2, ChatColour);
	}
	if (iRPGMode > 0) {
		if (GetClientTeam(client) == TEAM_SURVIVOR) Format(Message, MAX_CHAT_LENGTH, "{N}({B}Lv.%d{N}) %s", PlayerLevel[client], Message);
		else if (GetClientTeam(client) == TEAM_INFECTED) Format(Message, MAX_CHAT_LENGTH, "{N}({R}Lv.%d{N}) %s", PlayerLevel[client], Message);
		else if (GetClientTeam(client) == TEAM_SPECTATOR) Format(Message, MAX_CHAT_LENGTH, "{N}({GRA}Lv.%d{N}) %s", PlayerLevel[client], Message);

		if (SkyLevel[client] >= 1) Format(Message, MAX_CHAT_LENGTH, "{N}({B}PLv.%d{N})%s", SkyLevel[client], Message);
	}
	Format(sBuffer, MAX_CHAT_LENGTH, "{N}-> {%s}%s", ChatColour, sBuffer);

	if (GetClientTeam(client) == TEAM_SPECTATOR) Format(Message, MAX_CHAT_LENGTH, "{N}[{GRA}SPEC{N}] %s", Message);
	else {
		if (IsGhost(client)) Format(Message, MAX_CHAT_LENGTH, "{N}[{B}ghost{N}] %s", Message);
		else if (!IsPlayerAlive(client)) {

			if (GetClientTeam(client) == TEAM_SURVIVOR) Format(Message, MAX_CHAT_LENGTH, "{N}[{B}DEAD{N}] %s", Message);
			else Format(Message, MAX_CHAT_LENGTH, "{N}[{R}DEAD{N}] %s", Message);
		}
		else if (IsIncapacitated(client)) Format(Message, MAX_CHAT_LENGTH, "{N}[{B}INCAP{N}] %s", Message);
	}
	if (teamOnly) {
		if (GetClientTeam(client) == TEAM_SURVIVOR) Format(Message, MAX_CHAT_LENGTH, "{N}[{B}TEAM{N}] %s", Message);
		else if (GetClientTeam(client) == TEAM_INFECTED) Format(Message, MAX_CHAT_LENGTH, "{N}[{R}TEAM{N}] %s", Message);
		Format(Message, MAX_CHAT_LENGTH, "%s %s", Message, sBuffer);
		for (int i = 1; i <= MaxClients; i++) {
			if (IsLegitimateClient(i) && GetClientTeam(i) == GetClientTeam(client)) Client_PrintToChat(i, true, Message);
		}
		if (GetClientTeam(client) == TEAM_SPECTATOR) Format(Spectator_LastChatUser, sizeof(Spectator_LastChatUser), "%s", authString);
		else if (GetClientTeam(client) == TEAM_SURVIVOR) Format(Survivor_LastChatUser, sizeof(Survivor_LastChatUser), "%s", authString);
		else if (GetClientTeam(client) == TEAM_INFECTED) Format(Infected_LastChatUser, sizeof(Infected_LastChatUser), "%s", authString);
	}
	else {
		Format(Message, MAX_CHAT_LENGTH, "%s %s", Message, sBuffer);
		for (int i = 1; i <= MaxClients; i++) {
			if (IsLegitimateClient(i)) Client_PrintToChat(i, true, Message);
		}
	}
	return false;
}

stock int GetTargetClient(int client, char[] TargetName) {
	char Name[64];
	for (int i = 1; i <= MaxClients; i++) {
		if (IsLegitimateClient(i) && i != client && GetClientTeam(i) == GetClientTeam(client)) {
			GetClientName(i, Name, sizeof(Name));
			if (StrContains(Name, TargetName, false) != -1) return i;
		}
	}
	return -1;
}

stock void TeamworkRewardNotification(int client, int target, float PointCost, char[] ItemName) {

	// Client is the user who purchased the item.
	// Target is the user who received it the item.
	// PointCost is the actual price the client paid - to determine their experience reward.
	if (client == target || b_IsFinaleActive) return;
	if (PointCost > fTeamworkExperience) PointCost = fTeamworkExperience;
	// there's no teamwork in 'i'
	int experienceReward	= RoundToCeil(PointCost * (fItemMultiplierTeam * (GetRandomInt(1, GetTalentStrength(client, "luck")) * fItemMultiplierLuck)));
	char ClientName[MAX_NAME_LENGTH];
	GetClientName(client, ClientName, sizeof(ClientName));
	char ItemName_s[64];
	Format(ItemName_s, sizeof(ItemName_s), "%T", ItemName, target);
	PrintToChat(target, "%T", "received item from teammate", target, green, ItemName_s, white, blue, ClientName);
	// {1}{2} {3}purchased and given to you by {4}{5}
	Format(ItemName_s, sizeof(ItemName_s), "%T", ItemName, client);
	GetClientName(target, ClientName, sizeof(ClientName));
	PrintToChat(client, "%T", "teamwork reward notification", client, green, ClientName, white, blue, ItemName_s, white, green, experienceReward);
	// {1}{2} {3}has received {4}{5}{6}: {7}{8}
	ExperienceLevel[client] += experienceReward;
	ExperienceOverall[client] += experienceReward;
	ConfirmExperienceAction(client);
	GetProficiencyData(client, 6, experienceReward);
}

stock int GetActiveWeaponSlot(int client) {

	char Weapon[64];
	GetClientWeapon(client, Weapon, sizeof(Weapon));
	if (StrEqual(Weapon, "weapon_melee", false) || StrContains(Weapon, "pistol", false) != -1 || StrContains(Weapon, "chainsaw", false) != -1) return 1;
	return 0;
}

public Action CMD_FireSword(int client, int args) {

	char Weapon[64];
	int g_iActiveWeaponOffset = 0;
	int iWeapon = 0;
	GetClientWeapon(client, Weapon, sizeof(Weapon));
	if (StrEqual(Weapon, "weapon_melee", false)) {

		g_iActiveWeaponOffset = FindSendPropInfo("CTerrorPlayer", "m_hActiveWeapon");
		iWeapon = GetEntDataEnt2(client, g_iActiveWeaponOffset);
	}
	else {

		if (StrContains(Weapon, "pistol", false) == -1) iWeapon = GetPlayerWeaponSlot(client, 0);
		else iWeapon = GetPlayerWeaponSlot(client, 1);
	}

	if (IsValidEntity(iWeapon)) {

		ExtinguishEntity(iWeapon);
		IgniteEntity(iWeapon, 30.0);
	}
	return Plugin_Handled;
}

public Action CMD_LoadoutName(int client, int args) {

	if (args < 1) {

		PrintToChat(client, "!loadoutname <name identifier>");
		return Plugin_Handled;
	}
	GetCmdArg(1, LoadoutName[client], sizeof(LoadoutName[]));
	if (strlen(LoadoutName[client]) < 4) {

		PrintToChat(client, "loadout name must be >= 4 chars.");
		return Plugin_Handled;
	}
	if (StrContains(LoadoutName[client], "SavedProfile", false) != -1) {

		PrintToChat(client, "invalid loadout name, try again.");
		return Plugin_Handled;
	}
	ReplaceString(LoadoutName[client], sizeof(LoadoutName[]), "+", " ");	// this way the delimiter only shows where it's supposed to.
	hDatabase.Escape(LoadoutName[client], LoadoutName[client], sizeof(LoadoutName[]));
	Format(LoadoutName[client], sizeof(LoadoutName[]), "%s", LoadoutName[client]);
	PrintToChat(client, "%T", "loadout name set", client, orange, green, LoadoutName[client]);
	return Plugin_Handled;
}

stock float GetMissingHealth(int client) {

	return ((GetClientHealth(client) * 1.0) / (GetMaximumHealth(client) * 1.0));
}

stock bool QuickCommandAccess(int client, int args, bool b_IsTeamOnly) {

	if (IsLegitimateClient(client) && GetClientTeam(client) != TEAM_SPECTATOR) CMD_CastAction(client, args);
	char Command[64];
	GetCmdArg(1, Command, sizeof(Command));
	StripQuotes(Command);
	if (Command[0] != '/' && Command[0] != '!') return true;

	return QuickCommandAccessEx(client, Command, b_IsTeamOnly);
}

stock bool QuickCommandAccessEx(int client, char[] sCommand, bool b_IsTeamOnly = false, bool bGiveProfileItem = false, bool bIsItemExists = false) {

	int TargetClient = -1;
	char SplitCommand[2][64];
	char Command[64];
	Format(Command, sizeof(Command), "%s", sCommand);
	if (!bIsItemExists && !bGiveProfileItem && StrContains(Command, " ", false) != -1) {

		ExplodeString(Command, " ", SplitCommand, 2, 64);
		Format(Command, sizeof(Command), "%s", SplitCommand[0]);
		TargetClient	 = GetTargetClient(client, SplitCommand[1]);
		if (StrContains(Command, "revive", false) != -1 && TargetClient != client) return false;
	//	if (StrContains(Command, "@") != -1 && HasCommandAccess(client, GetConfigValue("reload configs flags?"))) {

		//	if (StrContains(Command, "commons", true) != -1) WipeAllCommons();
			//else if (StrContains(Command, "supercommons", true) != -1) WipeAllCommons(true);
		//}
	}

	char text[512];
	char cost[64];
	char bind[64];
	char pointtext[64];
	char description[512];
	char team[64];
	char CheatCommand[64];
	char CheatParameter[64];
	char Model[64];
	char Count[64];
	char CountHandicap[64];
	char Drop[64];
	float PointCost		= 0.0;
	float PointCostM	= 0.0;
	char MenuName[64];
	float f_GetMissingHealth = 1.0;

	int size					=	0;
	char Description_Old[512];
	char ItemName[64];
	char IsRespawn[64];
	int RemoveClient = -1;
	int iWeaponCat = -1;
	int iTargetClient = -1;
	int iCommonQueueLimit = GetCommonQueueLimit();

	//if (StringToInt(GetConfigValue("rpg mode?")) != 1) BuyItem(client, Command[1]);

	if ((iRPGMode != 1 || !b_IsActiveRound || bIsItemExists || bGiveProfileItem) && iRPGMode >= 0) {

		//GetConfigValue(thetext, sizeof(thetext), "quick bind help?");

		if (StrEqual(Command[1], sQuickBindHelp, false)) {

			size						=	a_Points.Length;

			for (int i = 0; i < size; i++) {

				MenuKeys[client]		=	a_Points.Get(i, 0);
				MenuValues[client]		=	a_Points.Get(i, 1);

				//size2					=	MenuKeys[client].Length;

				PointCost				= GetKeyValueFloat(MenuKeys[client], MenuValues[client], "point cost?");
				if (PointCost < 0.0) continue;

				PointCostM				= GetKeyValueFloat(MenuKeys[client], MenuValues[client], "point cost minimum?");
				FormatKeyValue(bind, sizeof(bind), MenuKeys[client], MenuValues[client], "quick bind?");
				Format(bind, sizeof(bind), "!%s", bind);
				FormatKeyValue(description, sizeof(description), MenuKeys[client], MenuValues[client], "description?");
				Format(description, sizeof(description), "%T", description, client);
				FormatKeyValue(team, sizeof(team), MenuKeys[client], MenuValues[client], "team?");

				/*
						
						Determine the actual cost for the player.
				*/
				
				if (Points[client] == 0.0 || Points[client] > 0.0 && (Points[client] * PointCost) < PointCostM) PointCost = PointCostM;
				else {

					PointCost += (PointCost * fPointsCostLevel);
					//if (PointCost > 1.0) PointCost = 1.0;
					PointCost *= Points[client];
				}
				Format(cost, sizeof(cost), "%3.3f", PointCost);
				

				if (StringToInt(team) != GetClientTeam(client)) continue;
				Format(pointtext, sizeof(pointtext), "%T", "Points", client);
				Format(pointtext, sizeof(pointtext), "%s %s", cost, pointtext);

				Format(text, sizeof(text), "%T", "Command Information", client, orange, bind, white, green, pointtext, white, blue, description);
				if (StrEqual(Description_Old, bind, false)) continue;		// in case there are duplicates
				Format(Description_Old, sizeof(Description_Old), "%s", bind);
				PrintToConsole(client, text);
			}
			PrintToChat(client, "%T", "Commands Listed Console", client, orange, white, green);
		}
		else {

			size						=	a_Points.Length;

			int iPreGameFree			=	0;

			for (int i = 0; i < size; i++) {

				MenuKeys[client]		=	a_Points.Get(i, 0);
				MenuValues[client]		=	a_Points.Get(i, 1);
				MenuSection[client]		=	a_Points.Get(i, 2);

				MenuSection[client].GetString(0, ItemName, sizeof(ItemName));

				PointCost		= GetKeyValueFloat(MenuKeys[client], MenuValues[client], "point cost?");
				PointCostM		= GetKeyValueFloat(MenuKeys[client], MenuValues[client], "point cost minimum?");
				FormatKeyValue(bind, sizeof(bind), MenuKeys[client], MenuValues[client], "quick bind?");
				FormatKeyValue(team, sizeof(team), MenuKeys[client], MenuValues[client], "team?");
				FormatKeyValue(CheatCommand, sizeof(CheatCommand), MenuKeys[client], MenuValues[client], "command?");
				FormatKeyValue(CheatParameter, sizeof(CheatParameter), MenuKeys[client], MenuValues[client], "parameter?");

				if (bIsItemExists && StrEqual(Command, ItemName)) return true;

				iWeaponCat = GetKeyValueInt(MenuKeys[client], MenuValues[client], "weapon category?");
				if (bGiveProfileItem) {

					if (StrEqual(Command, ItemName)) {

						if (iWeaponCat == 0) L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Primary);
						else if (iWeaponCat == 1) L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Secondary);

						if (!StrEqual(CheatCommand, "melee")) ExecCheatCommand(client, CheatCommand, CheatParameter);
						else {

							int ent			= CreateEntityByName("weapon_melee");

							DispatchKeyValue(ent, "melee_script_name", CheatParameter);
							DispatchSpawn(ent);

							EquipPlayerWeapon(client, ent);
						}
						return true;
					}
					continue;
				}

				if (StrEqual(Command[1], bind, false) && StringToInt(team) == GetClientTeam(client)) {		// we found the bind the player used, and the player is on the appropriate team.

					FormatKeyValue(Model, sizeof(Model), MenuKeys[client], MenuValues[client], "model?");
					FormatKeyValue(Count, sizeof(Count), MenuKeys[client], MenuValues[client], "count?");
					FormatKeyValue(CountHandicap, sizeof(CountHandicap), MenuKeys[client], MenuValues[client], "count handicap?");
					FormatKeyValue(Drop, sizeof(Drop), MenuKeys[client], MenuValues[client], "drop?");
					FormatKeyValue(MenuName, sizeof(MenuName), MenuKeys[client], MenuValues[client], "part of menu named?");
					FormatKeyValue(IsRespawn, sizeof(IsRespawn), MenuKeys[client], MenuValues[client], "isrespawn?");
					iPreGameFree = GetKeyValueInt(MenuKeys[client], MenuValues[client], "pre-game free?");

					if (StringToInt(IsRespawn) == 1) {

						if (TargetClient == -1) {

							if (!b_HasDeathLocation[client] || IsPlayerAlive(client) || IsEnrageActive()) return false;
						}
						if (TargetClient != -1) {

							if (IsPlayerAlive(TargetClient) || IsEnrageActive()) return false;
						}
					}
					if (TargetClient != -1 && IsPlayerAlive(TargetClient)) {

						if (IsIncapacitated(TargetClient)) f_GetMissingHealth	= 0.0;	// Player is incapped, has no missing life.
						else f_GetMissingHealth	= GetMissingHealth(TargetClient);
					}

					int ExperienceCost			=	GetKeyValueInt(MenuKeys[client], MenuValues[client], "experience cost?");
					if (ExperienceCost > 0) {

						float fExperienceCostMultiplier = GetKeyValueFloat(MenuKeys[client], MenuValues[client], "experience multiplier?");
						if (fExperienceCostMultiplier == -1.0) fExperienceCostMultiplier = fExperienceMultiplier;
						if (ExperienceCost > 0) ExperienceCost = RoundToCeil(ExperienceCost * (fExperienceCostMultiplier * (PlayerLevel[client] - 1)));
					}
					int TargetClient_s			=	0;

					if (FindCharInString(CheatCommand, ':') != -1) {

						BuildPointsMenu(client, CheatCommand[1], CONFIG_POINTS);		// Always CONFIG_POINTS for quick commands
					}
					else {

						if (GetClientTeam(client) == TEAM_INFECTED) {

							if (StringToInt(CheatParameter) == 8 && ActiveTanks() >= iTankLimitVersus) {

								PrintToChat(client, "%T", "Tank Limit Reached", client, orange, green, iTankLimitVersus, white);
								return false;
							}
							else if (StringToInt(CheatParameter) == 8 && f_TankCooldown != -1.0) {

								PrintToChat(client, "%T", "Tank On Cooldown", client, orange, white);
								return false;
							}
						}
						if (Points[client] == 0.0 || Points[client] > 0.0 && (Points[client] * PointCost) < PointCostM) PointCost = PointCostM;
						else PointCost *= Points[client];

						if (Points[client] >= PointCost ||
							PointCost == 0.0 ||
							(!b_IsActiveRound && iPreGameFree == 1) ||
							GetClientTeam(client) == TEAM_INFECTED && StrEqual(CheatCommand, "change class", false) && StringToInt(CheatParameter) != 8 && (TargetClient == -1 && IsGhost(client) || TargetClient != -1 && IsGhost(TargetClient))) {

							if (!StrEqual(CheatCommand, "change class") ||
								StrEqual(CheatCommand, "change class") && StrEqual(CheatParameter, "8") ||
								StrEqual(CheatCommand, "change class") && (TargetClient == -1 && IsPlayerAlive(client) && !IsGhost(client) || TargetClient != -1 && IsPlayerAlive(TargetClient) && !IsGhost(TargetClient))) {

								if (PointPurchaseType == 0 && (Points[client] >= PointCost || PointCost == 0.0 || (!b_IsActiveRound && iPreGameFree == 1))) {

									if (PointCost > 0.0 && Points[client] >= PointCost || PointCost <= 0.0) {

										if (iPreGameFree != 1 || b_IsActiveRound) Points[client] -= PointCost;
									}
								}
								else if (PointPurchaseType == 1 && (ExperienceLevel[client] >= ExperienceCost || ExperienceCost == 0)) ExperienceLevel[client] -= ExperienceCost;
							}

							if (StrEqual(CheatParameter, "common") && StrContains(Model, ".mdl", false) != -1) {

								Format(Count, sizeof(Count), "%d", StringToInt(Count) + (StringToInt(CountHandicap) * LivingSurvivorCount()));

								for (int iii = StringToInt(Count); iii > 0 && CommonInfectedQueue.Length < iCommonQueueLimit; iii--) {

									if (StringToInt(Drop) == 1) {

										CommonInfectedQueue.Resize(CommonInfectedQueue.Length + 1);
										CommonInfectedQueue.ShiftUp(0);
										CommonInfectedQueue.SetString(0, Model);
										TargetClient_s		=	FindLivingSurvivor();
										if (TargetClient_s > 0) ExecCheatCommand(TargetClient_s, CheatCommand, CheatParameter);
									}
									else CommonInfectedQueue.PushString(Model);
								}
							}
							else if (StrEqual(CheatCommand, "change class")) {

								// We don't give them points back if ghost because we don't take points if ghost.
								//if (IsGhost(client) && PointPurchaseType == 0) Points[client] += PointCost;
								//else if (IsGhost(client) && PointPurchaseType == 1) ExperienceLevel[client] += ExperienceCost;
								if ((!IsGhost(client) && FindZombieClass(client) == ZOMBIECLASS_TANK && TargetClient == -1 ||
									TargetClient != -1 && !IsGhost(TargetClient) && FindZombieClass(TargetClient) == ZOMBIECLASS_TANK) && PointPurchaseType == 0) Points[client] += PointCost;
								else if ((!IsGhost(client) && FindZombieClass(client) == ZOMBIECLASS_TANK && TargetClient == -1 || TargetClient != -1 && !IsGhost(TargetClient) && FindZombieClass(TargetClient) == ZOMBIECLASS_TANK) && PointPurchaseType == 1) ExperienceLevel[client] += ExperienceCost;
								else if ((!IsGhost(client) && IsPlayerAlive(client) && FindZombieClass(client) == ZOMBIECLASS_CHARGER && L4D2_GetSurvivorVictim(client) != -1 && TargetClient == -1 ||
										  TargetClient != -1 && !IsGhost(TargetClient) && IsPlayerAlive(TargetClient) && FindZombieClass(TargetClient) == ZOMBIECLASS_CHARGER && L4D2_GetSurvivorVictim(TargetClient) == -1) && PointPurchaseType == 0) Points[client] += PointCost;
								else if ((!IsGhost(client) && IsPlayerAlive(client) && FindZombieClass(client) == ZOMBIECLASS_CHARGER && L4D2_GetSurvivorVictim(client) != -1 && TargetClient == -1 ||
										  TargetClient != -1 && !IsGhost(TargetClient) && IsPlayerAlive(TargetClient) && FindZombieClass(TargetClient) == ZOMBIECLASS_CHARGER && L4D2_GetSurvivorVictim(TargetClient) == -1) && PointPurchaseType == 1) ExperienceLevel[client] += ExperienceCost;
								if (FindZombieClass(client) != ZOMBIECLASS_TANK && TargetClient == -1 || TargetClient != -1 && FindZombieClass(TargetClient) != ZOMBIECLASS_TANK) {

									if (TargetClient == -1) ChangeInfectedClass(client, StringToInt(CheatParameter));
									else ChangeInfectedClass(TargetClient, StringToInt(CheatParameter));

									if (TargetClient != -1) TeamworkRewardNotification(client, TargetClient, PointCost, ItemName);
								}
							}
							else if (StringToInt(IsRespawn) == 1) {

								if (TargetClient == -1 && !IsPlayerAlive(client) && b_HasDeathLocation[client]) {

									SDKCall(hRoundRespawn, client);
									b_HasDeathLocation[client] = false;
									CreateTimer(1.0, Timer_TeleportRespawn, client, TIMER_FLAG_NO_MAPCHANGE);
								}
								else if (TargetClient != -1 && !IsPlayerAlive(TargetClient) && b_HasDeathLocation[TargetClient]) {

									SDKCall(hRoundRespawn, TargetClient);
									b_HasDeathLocation[TargetClient] = false;
									CreateTimer(1.0, Timer_TeleportRespawn, TargetClient, TIMER_FLAG_NO_MAPCHANGE);

									TeamworkRewardNotification(client, TargetClient, PointCost, ItemName);
								}
							}
							else {

								//CheckIfRemoveWeapon(client, CheatParameter);
								RemoveClient = client;
								if (IsLegitimateClientAlive(TargetClient)) RemoveClient = TargetClient;
								if ((PointCost == 0.0 || (iPreGameFree == 1 && !b_IsActiveRound)) && GetClientTeam(RemoveClient) == TEAM_SURVIVOR) {

									// there is no code here to give a player a FREE weapon forcefully because that would be fucked up. TargetClient just gets ignored here.
									if (StrContains(CheatParameter, "pistol", false) != -1 || IsMeleeWeaponParameter(CheatParameter)) L4D_RemoveWeaponSlot(RemoveClient, L4DWeaponSlot_Secondary);
									else L4D_RemoveWeaponSlot(RemoveClient, L4DWeaponSlot_Primary);
								}
								if (IsMeleeWeaponParameter(CheatParameter)) {

									// Get rid of their old weapon
									if (TargetClient == -1)	L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Secondary);
									else L4D_RemoveWeaponSlot(TargetClient, L4DWeaponSlot_Secondary);

									int ent			= CreateEntityByName("weapon_melee");

									DispatchKeyValue(ent, "melee_script_name", CheatParameter);
									DispatchSpawn(ent);

									if (TargetClient == -1) EquipPlayerWeapon(client, ent);
									else EquipPlayerWeapon(TargetClient, ent);
								}
								else {

									if (StrContains(CheatParameter, "pistol", false) != -1) L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Secondary);
									else if (iWeaponCat >= 0 && iWeaponCat <= 1) L4D_RemoveWeaponSlot(client, L4DWeaponSlot_Primary);

									if (TargetClient == -1) {

										iTargetClient = client;

										if (StrEqual(CheatParameter, "health")) {

											if (L4D2_GetInfectedAttacker(client) != -1) Points[client] += PointCost;
											else {

												ExecCheatCommand(client, CheatCommand, CheatParameter);
												GiveMaximumHealth(client);		// So instant heal doesn't put a player above their maximum health pool.
											}
										}
										else ExecCheatCommand(client, CheatCommand, CheatParameter);
									}
									else {

										iTargetClient = TargetClient;

										if (StrEqual(CheatParameter, "health")) {

											if (L4D2_GetInfectedAttacker(TargetClient) != -1 || f_GetMissingHealth > fHealRequirementTeam) Points[client] += PointCost;
											else {

												ExecCheatCommand(TargetClient, CheatCommand, CheatParameter);
												GiveMaximumHealth(TargetClient);		// So instant heal doesn't put a player above their maximum health pool.
											}
										}
										else ExecCheatCommand(TargetClient, CheatCommand, CheatParameter);
									}
									if (StrContains(CheatParameter, "pistol", false) != -1 && StrContains(CheatParameter, "magnum", false) == -1) {

										CreateTimer(0.5, Timer_GiveSecondPistol, iTargetClient, TIMER_FLAG_NO_MAPCHANGE);
									}
									if (iWeaponCat == 0 && SkyLevel[client] > 0) CreateTimer(0.5, Timer_GiveLaserBeam, iTargetClient, TIMER_FLAG_NO_MAPCHANGE);
								}
								if (TargetClient != -1) {

									if (StrEqual(CheatParameter, "health", false) && L4D2_GetInfectedAttacker(TargetClient) == -1 && f_GetMissingHealth <= fHealRequirementTeam || !StrEqual(CheatParameter, "health", false)) {

										if (StrEqual(CheatParameter, "health", false)) TeamworkRewardNotification(client, TargetClient, PointCost * (1.0 - f_GetMissingHealth), ItemName);
										else TeamworkRewardNotification(client, TargetClient, PointCost, ItemName);
									}
								}
							}
							//if (TargetClient != -1) LogMessage("%N bought %s for %N", client, CheatParameter, TargetClient);
						}
						else {

							if (PointPurchaseType == 0) PrintToChat(client, "%T", "Not Enough Points", client, orange, white, PointCost);
							else if (PointPurchaseType == 1) PrintToChat(client, "%T", "Not Enough Experience", client, orange, white, ExperienceCost);
						}
					}
					break;
				}
			}
			if (bIsItemExists) return false;
		}
	}
	if (Command[0] == '!') return true;
	return false;
}

stock void LoadHealthMaximum(int client) {

	if (GetClientTeam(client) == TEAM_INFECTED) DefaultHealth[client] = GetClientHealth(client);
	else {

		if (!IsFakeClient(client)) DefaultHealth[client] = iSurvivorBaseHealth;	// 100 is the default. no reason to think otherwise.
		else DefaultHealth[client] = iSurvivorBotBaseHealth;
	}

	// testing new system
	GetAbilityStrengthByTrigger(client, _, "a", _, 0);	// activator, target, trigger ability, effects, zombieclass, damage
}

stock void SetSpeedMultiplierBase(int attacker, float amount = 1.0) {

	if (GetClientTeam(attacker) == TEAM_SURVIVOR) SetEntPropFloat(attacker, Prop_Send, "m_flLaggedMovementValue", fBaseMovementSpeed);
	else SetEntPropFloat(attacker, Prop_Send, "m_flLaggedMovementValue", amount);
}

stock void PlayerSpawnAbilityTrigger(int attacker) {

	if (IsLegitimateClientAlive(attacker)) {

		TankState[attacker] = TANKSTATE_TIRED;

		SetSpeedMultiplierBase(attacker);

		SpeedMultiplier[attacker] = SpeedMultiplierBase[attacker];		// defaulting the speed. It'll get modified in speed modifer spawn talents.
		
		if (GetClientTeam(attacker) == TEAM_INFECTED) DefaultHealth[attacker] = GetClientHealth(attacker);
		else {

			if (!IsFakeClient(attacker)) DefaultHealth[attacker] = iSurvivorBaseHealth;
			else DefaultHealth[attacker] = iSurvivorBotBaseHealth;
		}
		b_IsImmune[attacker] = false;

		GetAbilityStrengthByTrigger(attacker, _, "a", _, 0);
		if (GetClientTeam(attacker) != TEAM_SURVIVOR) {

			GiveMaximumHealth(attacker);
			CreateMyHealthPool(attacker);		// when the infected spawns, if there are any human players, they'll automatically be added to their pools to ensure that bots don't one-shot them.
		}
	}
}

stock bool NoHumanInfected() {

	for (int i = 1; i <= MaxClients; i++) {

		if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == TEAM_INFECTED) return false;
	}

	return true;
}

stock void InfectedBotSpawn(int client) {

	//new Float:HealthBonus = 0.0;
	//new Float:SpeedBonus = 0.0;

	if (IsLegitimateClient(client)) {

		/*

			In the new health adjustment system, it is based on the number of living players as well as their total level.
			Health bonus is multiplied by the number of total levels of players alive in the session.
		*/
		/*decl String:InfectedHealthBonusType[64];
		Format(InfectedHealthBonusType, sizeof(InfectedHealthBonusType), "(%d) infected health bonus", FindZombieClass(client));
		HealthBonus = StringToFloat(GetConfigValue(InfectedHealthBonusType)) * (SurvivorLevels() * 1.0);*/

		//GetAbilityStrengthByTrigger(client, _, 'a', 0, 0);
	}
}

stock int TruRating(int client) {

	int TrueRating = RatingPerLevel;
	if (RatingHandicap[client] > TrueRating) TrueRating = RatingHandicap[client];
	//TrueRating *= PlayerLevel[client];
	TrueRating *= CartelLevel(client);
	TrueRating += Rating[client];
	return TrueRating;
}

stock bool CheckServerLevelRequirements(int client) {

	if (iServerLevelRequirement > 0) {

		if (IsFakeClient(client)) {

			if (IsSurvivorBot(client) && PlayerLevel[client] < iServerLevelRequirement) SetTotalExperienceByLevel(client, iServerLevelRequirement);
			return true;
		}
		LogMessage("Level required to enter is %d and %N is %d", iServerLevelRequirement, client, PlayerLevel[client]);
	}
	if (IsFakeClient(client)) return true;
	char LevelKickMessage[128];
	if (iServerLevelRequirement == -2 && !IsGroupMember[client]) {

		// some servers can allow only steamgroup members to join.
		// this prevents people who are trying to quick-match a vanilla game from joining the server if you activate it.
		b_IsLoading[client] = true;
		Format(LevelKickMessage, sizeof(LevelKickMessage), "Only steamgroup members can access this server.");
		KickClient(client, LevelKickMessage);
		return false;
	}
	if (PlayerLevel[client] < iServerLevelRequirement) {

		b_IsLoading[client] = true;	// prevent saving data on kick

		Format(LevelKickMessage, sizeof(LevelKickMessage), "Your level: %d\nSorry, you must be level %d to enter this server.", PlayerLevel[client], iServerLevelRequirement);
		KickClient(client, LevelKickMessage);
		return false;
	}
	else bIsSettingsCheck = true;
	//EnforceServerTalentMaximum(client);
	return true;
}

stock int GetSpecialInfectedLimit(bool IsTankLimit = false) {

	int speciallimit = 0;
	int Dividend = iRatingSpecialsRequired;
	if (IsTankLimit) Dividend = iRatingTanksRequired;
	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && GetClientTeam(i) == TEAM_SURVIVOR) {

			if (Rating[i] < 0) Rating[i] = 0;
			speciallimit += Rating[i];
		}
	}
	if (iIgnoredRating > 0) {

		int ignoredRating = TotalSurvivors() * iIgnoredRating;
		if (ignoredRating > iIgnoredRatingMax) ignoredRating = iIgnoredRatingMax;

		speciallimit -= ignoredRating;
		if (speciallimit < 0) speciallimit = 0;
	}
	speciallimit = RoundToFloor(speciallimit * 1.0 / Dividend * 1.0);
	if (!IsTankLimit && iSpecialInfectedMinimum >= 0) {
		if (iSpecialInfectedMinimum > 0) speciallimit += iSpecialInfectedMinimum;
		else speciallimit += TotalSurvivors();
	}
	
	/*if (speciallimit < 1) {

		if (b_IsFinaleActive) speciallimit = 2;
		else speciallimit = 1;
	}*/
	return speciallimit;
}

stock int RaidCommonBoost(bool bInfectedTalentStrength = false, bool IsEnsnareMultiplier = false) {

	int totalTeamRating = 0;
	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && GetClientTeam(i) == TEAM_SURVIVOR) {

			if (Rating[i] < 0) Rating[i] = 0;
			totalTeamRating += Rating[i];
		}
	}
	int Multiplier = RaidLevMult;
	if (bInfectedTalentStrength) Multiplier = InfectedTalentLevel;
	else if (IsEnsnareMultiplier) Multiplier = iEnsnareLevelMultiplier;

	if (iIgnoredRating > 0) {

		int ignoredRating = TotalSurvivors() * iIgnoredRating;
		if (ignoredRating > iIgnoredRatingMax) ignoredRating = iIgnoredRatingMax;

		totalTeamRating -= ignoredRating;
		if (totalTeamRating < 0) totalTeamRating = 0;
	}

	totalTeamRating /= Multiplier;
	if (totalTeamRating < 1) totalTeamRating = 0;
	return totalTeamRating;
}

stock int HumanSurvivorLevels() {

	int fff = 0;
	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && !IsFakeClient(i) && GetClientTeam(i) == TEAM_SURVIVOR) {

			if (Rating[i] < 0) Rating[i] = 0;
			fff += Rating[i];
		}
	}
	//if (StringToInt(GetConfigValue("infected bot level type?")) == 1) return f;	// player combined level
	//if (LivingHumanSurvivors() > 0) return f / LivingHumanSurvivors();
	if (iIgnoredRating > 0) {

		int ignoredRating = TotalSurvivors() * iIgnoredRating;
		if (ignoredRating > iIgnoredRatingMax) ignoredRating = iIgnoredRatingMax;

		fff -= ignoredRating;
		if (fff < 0) fff = 0;
	}
	return fff;
}

stock int SurvivorLevels() {

	int fff = 0;
	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && GetClientTeam(i) == TEAM_SURVIVOR) {

			if (Rating[i] < 0) Rating[i] = 0;
			fff += Rating[i];
		}
	}
	//if (StringToInt(GetConfigValue("infected bot level type?")) == 1) return f;	// player combined level
	//if (LivingHumanSurvivors() > 0) return f / LivingHumanSurvivors();
	if (iIgnoredRating > 0) {

		int ignoredRating = TotalSurvivors() * iIgnoredRating;
		if (ignoredRating > iIgnoredRatingMax) ignoredRating = iIgnoredRatingMax;

		fff -= ignoredRating;
		if (fff < 0) fff = 0;
	}
	return fff;
}

stock bool IsLegitimateClient(int client) {

	if (client < 1 || client > MaxClients || !IsClientConnected(client) || !IsClientInGame(client)) return false;
	return true;
}

stock bool IsLegitimateClientAlive(int client) {

	if (IsLegitimateClient(client) && IsPlayerAlive(client)) return true;
	return false;
}

stock void RaidInfectedBotLimit() {

	/*new count = LivingHumanSurvivors() + 1;
	new CurrInfectedLevel = SurvivorLevels();
	new RaidLevelRequirement = RaidLevMult;
	while (CurrInfectedLevel >= RaidLevelRequirement) {

		CurrInfectedLevel -= RaidLevelRequirement;
		count++;
	}
	new HumanInGame = HumanPlayersInGame();
	if (HumanInGame > 4) count = HumanInGame;*/

	bIsSettingsCheck = true;
	int count = GetSpecialInfectedLimit();

	ReadyUp_NtvHandicapChanged(count);
}

stock void RefreshSurvivor(int client, bool IsUnhook = false) {

	if (IsLegitimateClientAlive(client) && GetClientTeam(client) == TEAM_SURVIVOR) {

		SetEntProp(client, Prop_Send, "m_currentReviveCount", 0);
		StopSound(client, SNDCHAN_AUTO, "player/heartbeatloop.wav");
		SetEntProp(client, Prop_Send, "m_bIsOnThirdStrike", 0);
		//if (IsFakeClient(client)) {

			//SetMaximumHealth(client);
			//Rating[client] = 1;
			//PlayerLevel[client] = iPlayerStartingLevel;
		//}
	}
}

public Action Timer_CheckForExperienceDebt(Handle timer, any client) {

	if (!IsLegitimateClient(client)) return Plugin_Stop;
	return Plugin_Stop;
}

stock void DeleteMeFromExistence(int client) {

	int pos = -1;

	for (int i = 1; i <= MaxClients; i++) {

		if (!IsLegitimateClient(i)) continue;
		pos = FindListPositionByEntity(client, InfectedHealth[i]);
		if (pos >= 0) InfectedHealth[i].Erase(pos);
	}
	ForcePlayerSuicide(client);
}

stock void IncapacitateOrKill(int client, int attacker = 0, int healthvalue = 0, bool bIsFalling = false, bool bIsLifelinkPenalty = false, bool ForceKill = false) {
	bool isPlayerASurvivorBot = IsSurvivorBot(client);

	if ((ForceKill || IsLegitimateClientAlive(client)) && (GetClientTeam(client) != TEAM_INFECTED || isPlayerASurvivorBot)) {
		bool isClientIncapacitated = IsIncapacitated(client);
		//new IncapCounter	= GetEntProp(client, Prop_Send, "m_currentReviveCount");
		if (ForceKill || isClientIncapacitated || bIsFalling && !IsLedged(client) || PlayerHasWeakness(client) || GetIncapCount(client) >= iMaxIncap) {
			//if (FindZombieClass(attacker) == ZOMBIECLASS_JOCKEY) PrintToChatAll("jockey did the incap.");
			HealingContribution[client] = 0;
			DamageContribution[client] = 0;
			PointsContribution[client] = 0.0;
			TankingContribution[client] = 0;
			BuffingContribution[client] = 0;
			HexingContribution[client] = 0;
			char PlayerName[64];
			char PlayerID[64];
			if (!isPlayerASurvivorBot) {

				GetClientName(client, PlayerName, sizeof(PlayerName));
				GetClientAuthId(client, AuthId_Steam2, PlayerID, sizeof(PlayerID));
			}
			else {

				GetSurvivorBotName(client, PlayerName, sizeof(PlayerName));
				Format(PlayerID, sizeof(PlayerID), "%s%s", sBotTeam, PlayerName);
			}
			char pct[4];
			Format(pct, sizeof(pct), "%");
			if (iRPGMode >= 0 && IsPlayerAlive(client)) {

				if (iIsLevelingPaused[client] == 1 || PlayerLevel[client] >= iMaxLevel || PlayerLevel[client] >= iHardcoreMode && fDeathPenalty > 0.0 && iDeathPenaltyPlayers > 0 && TotalHumanSurvivors() >= iDeathPenaltyPlayers) ConfirmExperienceActionTalents(client, true);

				if (iIsLevelingPaused[client] == 1 || PlayerLevel[client] >= iMaxLevel) {

					ExperienceOverall[client] -= (ExperienceLevel[client] - 1);
					ExperienceLevel[client] = 1;
				}

				int LivingHumansCounter = LivingSurvivors() - 1;
				if (LivingHumansCounter < 0) LivingHumansCounter = 0;

				PrintToChatAll("%t", "teammate has died", blue, PlayerName, orange, green, (LivingHumansCounter * fSurvivorExpMult) * 100.0, pct);
				if (RoundExperienceMultiplier[client] > 0.0) {

					PrintToChatAll("%t", "bonus container burst", blue, PlayerName, orange, green, 100.0 * RoundExperienceMultiplier[client], orange, pct);
					BonusContainer[client] = 0;
					RoundExperienceMultiplier[client] = 0.0;
				}
			} 

			char text[512];
			char ColumnName[64];
			//new TheGameMode = ReadyUp_GetGameMode();
			if (Rating[client] > BestRating[client]) {

				BestRating[client] = Rating[client];
				Format(ColumnName, sizeof(ColumnName), "%s", sDbLeaderboards);
				if (StrEqual(ColumnName, "-1")) {

					if (ReadyUpGameMode != 3) Format(ColumnName, sizeof(ColumnName), "%s", COOPRECORD_DB);
					else Format(ColumnName, sizeof(ColumnName), "%s", SURVRECORD_DB);
				}
				Format(text, sizeof(text), "UPDATE `%s` SET `%s` = '%d' WHERE `steam_id` = '%s';", TheDBPrefix, ColumnName, BestRating[client], PlayerID);
				hDatabase.Query(QueryResults, text, client);
			}
			//if (ReadyUpGameMode != 3)
			Rating[client] = RoundToCeil(Rating[client] * (1.0 - fRatingPercentLostOnDeath)) + 1;
			int minimumRating = RoundToCeil(BestRating[client] * fRatingFloor);
			if (Rating[client] < minimumRating) Rating[client] = minimumRating;

			if (!isPlayerASurvivorBot) {

				char MyName[64];
				GetClientName(client, MyName, sizeof(MyName));
				if (!CheckServerLevelRequirements(client)) {

					PrintToChatAll("%t", "player no longer eligible", blue, MyName, orange);
					return;
				}
			}
			RaidInfectedBotLimit();

			if (iIsLifelink == 1 && !bIsLifelinkPenalty) {	// prevents looping

				for (int i = 1; i <= MaxClients; i++) {

					if (IsLegitimateClientAlive(i) && GetClientTeam(i) == TEAM_SURVIVOR) IncapacitateOrKill(i, _, _, true, true);		// second true prevents this loop from being triggered by the function.
				}
			}

			//if (!bIsFalling) b_HasDeathLocation[client] = true;
			//else b_HasDeathLocation[client] = false;
			if (!ForceKill) {

				GetClientAbsOrigin(client, DeathLocation[client]);
				b_HasDeathLocation[client] = true;
			}
			/*LogMessage("%N HAS DIED!!!", client);
			if (Handle InfectedHealth[client].Length > 0 && IsSurvivorInAGroup(client)) {

				Handle InfectedHealth[client].Clear();	// infected get their health back when a player dies and the player gets no XP for their contributions.
				PenalizeGroupmates(client);
			}*/
			ForcePlayerSuicide(client);
			iThreatLevel[client] = 0;
			bIsGiveProfileItems[client] = true;		// so when the player returns to life, their weapon loadout for that profile will be given to them.
			MyBirthday[client] = 0;
			bIsInCombat[client] = false;
			MyRespawnTarget[client] = client;
			//CreateTimer(1.0, Timer_CheckForExperienceDebt, client, TIMER_FLAG_NO_MAPCHANGE);
			//ToggleTank(client, true);
			//IsCoveredInVomit(client, _, true);
			if (RatingHandicap[client] > RatingPerLevel) {
				RatingHandicap[client] = RatingPerLevel;
				PrintToChat(client, "%T", "player handicap", client, blue, orange, green, RatingHandicap[client]);
			}

			RefreshSurvivor(client);
			//AutoAdjustHandicap(client, 1);
			//if (ReadyUp_GetGameMode() == 3 && Rating[client] > PlayerLevel[client]) Rating[client] = PlayerLevel[client];		// death in survival resets the handicap.
			//WipeDamageContribution(client);

			GetAbilityStrengthByTrigger(client, attacker, "E", _, 0);
			if (attacker > 0) GetAbilityStrengthByTrigger(attacker, client, "e", _, healthvalue);
			if (IsLegitimateClientAlive(attacker) && FindZombieClass(attacker) == ZOMBIECLASS_TANK) {

				if (IsFakeClient(attacker)) ChangeTankState(attacker, "death");
			}
			SaveAndClear(client);
		}
		else if (!isClientIncapacitated) {
			
			if (!ImmuneToAllDamage[client]) {
				ImmuneToAllDamage[client] = true;
				CreateTimer(1.0, Timer_RemoveDamageImmunity, client, TIMER_FLAG_NO_MAPCHANGE);
			}

			ReadyUp_NtvStatistics(client, 3, 1);
			ReadyUp_NtvStatistics(attacker, 4, 1);

			SetEntProp(client, Prop_Send, "m_isIncapacitated", 1);
			iThreatLevel[client] /= 2;
			//bIsGiveIncapHealth[client] = true;	// because we do it here
			//ModifyHealth(client, GetAbilityStrengthByTrigger(client, client, "p", FindZombieClass(client), 0, _, _, "H"), 0.0);
			bIsGiveIncapHealth[client] = true;
			SetMaximumHealth(client);
			
			//GiveMaximumHealth(client);
			
			//GiveMaximumHealth(client);
			b_HasDeathLocation[client] = false;
			//SetTempHealth(client, client, GetMaximumHealth(client) * 1.0);

			// After setting initial temp health we can set a different one if they have the talent
			if (attacker != 0 && IsLegitimateClient(attacker)) GetAbilityStrengthByTrigger(client, attacker, "N", _, healthvalue);
			else GetAbilityStrengthByTrigger(client, attacker, "n", _, healthvalue);
			/*new Float:IncapHealthStrength = GetAbilityStrengthByTrigger(client, client, 'p', FindZombieClass(client), 0, _, _, "H");
			if (IncapHealthStrength < 1.0) IncapHealthStrength = (iSurvivorBaseHealth * 1.0) / 100.0;	// 100 health if nothing.
			if (iRPGMode >= 1) ModifyHealth(client, IncapHealthStrength, 0.0);
			else ModifyHealth(client, iSurvivorBaseHealth * 4.0, 0.0);*/
			//SetEntityHealth(client, RoundToCeil(GetMaximumHealth(client) * StringToFloat(GetConfigValue("survivor incap health?"))));
			//SetClientTotalHealth(client, GetMaximumHealth(client), true);
			//SetClientTempHealth(client);
			RoundIncaps[client]++;
			//if (ReadyUp_GetGameMode() != 3) AutoAdjustHandicap(client, 0);
			int infectedAttacker = L4D2_GetInfectedAttacker(client);

			if (infectedAttacker == -1) GetAbilityStrengthByTrigger(client, attacker, "n", _, healthvalue);
			else {							
				//CreateTimer(1.0, Timer_IsIncapacitated, victim, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				GetAbilityStrengthByTrigger(client, attacker, "N", _, healthvalue);
				if (infectedAttacker == attacker) GetAbilityStrengthByTrigger(attacker, client, "m", _, healthvalue);
				else GetAbilityStrengthByTrigger(client, infectedAttacker, "m", _, healthvalue);
			}
		}
	}
}

public Action Timer_RemoveDamageImmunity(Handle timer, any client) {
	if (IsLegitimateClient(client)) ImmuneToAllDamage[client] = false;
	return Plugin_Stop;
}
	/*
	// ---------------------------
	//  Hit Group standards
	// ---------------------------
	#define HITGROUP_GENERIC     0
	#define HITGROUP_HEAD        1
	#define HITGROUP_CHEST       2
	#define HITGROUP_STOMACH     3
	#define HITGROUP_LEFTARM     4    
	#define HITGROUP_RIGHTARM    5
	#define HITGROUP_LEFTLEG     6
	#define HITGROUP_RIGHTLEG    7
	#define HITGROUP_GEAR        10            // alerts NPC, but doesn't do damage or bleed (1/100th damage)
	*/
stock int GetHitgroupType(int hitgroup) {
	if (hitgroup >= 4 && hitgroup <= 7) return 2;	// limb
	if (hitgroup == 1) return 1;					// headshot
	return 0;										// not a limb
}
stock bool CheckIfLimbDamage(int attacker, int victim, Event event, int damage) {
	if (IsLegitimateClientAlive(attacker) && GetClientTeam(attacker) == TEAM_SURVIVOR) {
		if (!b_IsHooked[attacker]) ChangeHook(attacker, true);
		int hitgroup = event.GetInt("hitgroup");
		if (hitgroup >= 4 && hitgroup <= 7) {
			GetAbilityStrengthByTrigger(attacker, victim, "limbshot", _, damage, _, _, _, _, _, _, hitgroup);
			return true;			
		}
	}
	return false;
}

/*
	GetAbilityStrengthByTrigger(activator, target = 0, String:AbilityT[], zombieclass = 0, damagevalue = 0,
										bool:IsOverdriveStacks = false, bool:IsCleanse = false, String:ResultEffects[] = "none", ResultType = 0,
										bool:bDontActuallyActivate = false, typeOfValuesToRetrieve = 1, hitgroup = -1)
*/

stock bool CheckIfHeadshot(int attacker, int victim, Event event, int damage) {
	if (IsLegitimateClientAlive(attacker) && GetClientTeam(attacker) == TEAM_SURVIVOR) {
		if (!b_IsHooked[attacker]) ChangeHook(attacker, true);
		int hitgroup = event.GetInt("hitgroup");
		if (hitgroup == 1) {
			GetAbilityStrengthByTrigger(attacker, victim, "headshot", _, damage, _, _, _, _, _, _, hitgroup);
			if (IsCommonInfected(victim) && !IsSpecialCommon(victim)) AddCommonInfectedDamage(attacker, victim, 9999, true);	// if someone shoots a common infected in the head, we want to auto-kill it.
			return true;			
		}
	}
	return false;
}

stock bool EquipBackpack(int client) {

	if (eBackpack[client] > 0 && IsValidEntity(eBackpack[client])) {

		AcceptEntityInput(eBackpack[client], "Kill");
		eBackpack[client] = 0;
	}

	if (eBackpack[client] > 0 && IsValidEntity(eBackpack[client]) || !IsLegitimateClientAlive(client)) return false;	// backpack is already created.
	float Origin[3];

	int entity = CreateEntityByName("prop_dynamic_override");

	GetClientAbsOrigin(client, Origin);

	char text[64];
	Format(text, sizeof(text), "%d", client);
	DispatchKeyValue(entity, "model", sBackpackModel);
	//DispatchKeyValue(entity, "parentname", text);
	DispatchSpawn(entity);

	SetVariantString("!activator");
	AcceptEntityInput(entity, "SetParent", client);
	SetVariantString("spine");
	AcceptEntityInput(entity, "SetParentAttachment");

	// Lux
	AcceptEntityInput(entity, "DisableCollision");
	SetEntProp(entity, Prop_Send, "m_noGhostCollision", 1, 1);
	SetEntProp(entity, Prop_Data, "m_CollisionGroup", 0x0004);
	float dFault[3];
	SetEntPropVector(entity, Prop_Send, "m_vecMins", dFault);
	SetEntPropVector(entity, Prop_Send, "m_vecMaxs", dFault);
	// Lux

	//TeleportEntity(entity, g_vPos[index], g_vAng[index], NULL_VECTOR);
	SetEntProp(entity, Prop_Data, "m_iEFlags", 0);


	Origin[0] += 10.0;

	TeleportEntity(entity, Origin, NULL_VECTOR, NULL_VECTOR);
	eBackpack[client] = entity;

	return true;
}

stock bool GetClientStance(int client, float fChaseTime = 20.0) {

	//if (stance == ClientActiveStance[client]) return true;
	/*if (bChangeStance) {

		ClientActiveStance[client] = stance;

		if (stance == 1) {

			new entity = CreateEntityByName("info_goal_infected_chase");
			if (entity > 0)
			{
				iChaseEnt[client] = EntIndexToEntRef(entity);

				DispatchSpawn(entity);
				new Float:vPos[3];
				GetClientAbsOrigin(client, vPos);
				vPos[2] += 20.0;
				TeleportEntity(entity, vPos, NULL_VECTOR, NULL_VECTOR);

				SetVariantString("!activator");
				AcceptEntityInput(entity, "SetParent", client);

				decl String:temp[32];
				Format(temp, sizeof temp, "OnUser4 !self:Kill::300.0:-1");
				SetVariantString(temp);
				AcceptEntityInput(entity, "AddOutput");
				AcceptEntityInput(entity, "FireUser4");

				//iChaseEnt[client] = entity;
			}
		}
		else {

			if(iChaseEnt[client] && EntRefToEntIndex(iChaseEnt[client]) != INVALID_ENT_REFERENCE) AcceptEntityInput(iChaseEnt[client], "Kill");
			iChaseEnt[client] = -1;
		}
		return true;
	}*/
	if (ClientActiveStance[client] == 1) return false;

	int entity = CreateEntityByName("info_goal_infected_chase");
	if (entity > 0) {
		
		iChaseEnt[client] = EntIndexToEntRef(entity);

		DispatchSpawn(entity);
		float vPos[3];
		GetClientAbsOrigin(client, vPos);
		vPos[2] += 20.0;
		TeleportEntity(entity, vPos, NULL_VECTOR, NULL_VECTOR);

		SetVariantString("!activator");
		AcceptEntityInput(entity, "SetParent", client);

		char temp[32];
		Format(temp, sizeof temp, "OnUser4 !self:Kill::%f:-1", fChaseTime);
		SetVariantString(temp);
		AcceptEntityInput(entity, "AddOutput");
		AcceptEntityInput(entity, "FireUser4");

		ClientActiveStance[client] = 1;
		CreateTimer(fChaseTime, Timer_ForcedThreat, client, TIMER_FLAG_NO_MAPCHANGE);

		iThreatLevel[client] = iTopThreat + 1;

		return true;
	}
	return false;
}

public Action Timer_ForcedThreat(Handle timer, any client) {

	if (IsLegitimateClient(client)) {

		ClientActiveStance[client] = 0;
		if(iChaseEnt[client] && EntRefToEntIndex(iChaseEnt[client]) != INVALID_ENT_REFERENCE) AcceptEntityInput(iChaseEnt[client], "Kill");
		iChaseEnt[client] = -1;
	}
	return Plugin_Stop;
}

stock bool IsAllSurvivorsDead() {

	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClientAlive(i) && GetClientTeam(i) == TEAM_SURVIVOR) return false;
	}
	return true;
}

stock void GiveAdrenaline(int client, bool Remove=false) {

	if (Remove) SetEntProp(client, Prop_Send, "m_bAdrenalineActive", 0);
	else if (!HasAdrenaline(client)) SetEntProp(client, Prop_Send, "m_bAdrenalineActive", 1);
}

stock bool HasAdrenaline(int client) {

	if (IsClientInRangeSpecialAmmo(client, "a") == -2.0) return true;
	return view_as<bool>(GetEntProp(client, Prop_Send, "m_bAdrenalineActive"));
}

/*stock bool:IsDualWield(int client) {

	return bool:GetEntProp(client, Prop_Send, "m_isDualWielding");
}*/

stock bool IsLedged(int client) {

	return view_as<bool>(GetEntProp(client, Prop_Send, "m_isHangingFromLedge"));
}

stock bool FallingFromLedge(int client) {

	return view_as<bool>(GetEntProp(client, Prop_Send, "m_isFallingFromLedge"));
}

stock void SetAdrenalineState(int client, float time=10.0) {

	if (!HasAdrenaline(client)) SDKCall(g_hEffectAdrenaline, client, time);
}

stock int GetClientTotalHealth(int client) {

	int SolidHealth			= GetClientHealth(client);
	float TempHealth	= GetEntPropFloat(client, Prop_Send, "m_healthBuffer");
	//if (IsIncapacitated(client)) TempHealth = 0.0;

	if (!IsIncapacitated(client)) return RoundToCeil(SolidHealth + TempHealth);
	else return RoundToCeil(TempHealth);
}
 
stock void SetClientTotalHealth(int client, int damage, bool IsSetHealthInstead = false, bool bIgnoreMultiplier = false) {
	if (ImmuneToAllDamage[client]) return;
	float fHealthBuffer = 0.0;

	if (IsSetHealthInstead) {

		SetMaximumHealth(client);
		SetEntityHealth(client, damage);
		SetEntPropFloat(client, Prop_Send, "m_healthBuffer", damage * 1.0);
		SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime());
		return;
	}

	if (GetClientTeam(client) == TEAM_SURVIVOR) {
		ReadyUp_NtvStatistics(client, 7, damage);

		fHealthBuffer = GetEntPropFloat(client, Prop_Send, "m_healthBuffer");
		if (fHealthBuffer > 0.0) {

			if (damage >= fHealthBuffer) {	// temporary health is always checked first.

				if (IsIncapacitated(client)) IncapacitateOrKill(client);	// kill
				else {

					SetEntPropFloat(client, Prop_Send, "m_healthBuffer", 0.0);
					SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime());
					damage -= RoundToFloor(fHealthBuffer);
				}
			}
			else {

				fHealthBuffer -= damage;
				SetEntityHealth(client, RoundToCeil(fHealthBuffer));
				SetEntPropFloat(client, Prop_Send, "m_healthBuffer", fHealthBuffer);
				SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime());
				damage = 0;
			}
		}
		if (IsPlayerAlive(client)) {

			if (damage >= GetClientTotalHealth(client)) IncapacitateOrKill(client);	// hint: they won't be killed.
			else if (!IsIncapacitated(client)) {

				SetEntityHealth(client, GetClientHealth(client) - damage);
				//AddTalentExperience(client, "constitution", damage);
			}
		}
	}
	else {
		ReadyUp_NtvStatistics(client, 8, damage);
		if (damage >= GetClientHealth(client)) CalculateInfectedDamageAward(client);
		else SetEntityHealth(client, GetClientHealth(client) - damage);
	}
}

stock void RestoreClientTotalHealth(int client, int damage) {

	int SolidHealth			= GetClientHealth(client);
	float TempHealth	= 0.0;
	if (GetClientTeam(client) == TEAM_SURVIVOR) TempHealth = GetEntPropFloat(client, Prop_Send, "m_healthBuffer");
	if (RoundToFloor(TempHealth) > 0) {

		SetEntPropFloat(client, Prop_Send, "m_healthBuffer", TempHealth + damage);
		SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime());
	}
	else SetEntityHealth(client, SolidHealth + damage);
}

stock bool SetTempHealth(int client, int targetclient, float TemporaryHealth=30.0, bool IsRevive=false, bool IsInNeedOfPickup=false) {

	if (!IsLegitimateClientAlive(targetclient)) return false;
	if (IsRevive) {

		if (IsInNeedOfPickup) ReviveDownedSurvivor(targetclient);

		// When a player revives someone (or is revived) we call the SetTempHealth function and here
		// It simply calls itself 
		GetAbilityStrengthByTrigger(targetclient, client, "R", _, 0);
		GetAbilityStrengthByTrigger(client, targetclient, "r", _, 0);
		//GiveMaximumHealth(targetclient);
	}
	else {

		SetEntPropFloat(targetclient, Prop_Send, "m_healthBuffer", TemporaryHealth);
		SetEntPropFloat(targetclient, Prop_Send, "m_healthBufferTime", GetGameTime());
	}
	if (client != targetclient) AwardExperience(client, 1, RoundToCeil(TemporaryHealth));
	return true;
}

/*stock ModifyTempHealth(client, Float:health) {

	SetEntPropFloat(client, Prop_Send, "m_healthBuffer", health);
}*/

/*stock SetClientMaximumTempHealth(int client) {

	SetMaximumHealth(client);
	SetEntityHealth(client, 1);
	SetClientTempHealth(client, GetMaximumHealth(client) - 1);
}*/

stock void ModifyHealth(int client, float TalentStrength, float TalentTime, int isRawValue = 0) {

	if (!IsLegitimateClientAlive(client)) return;
	SetMaximumHealth(client);
	/*if (GetClientTeam(client) == TEAM_INFECTED) {

		DefaultHealth[client] = (isRawValue == 0) ? 
								OriginalHealth[client] + RoundToCeil(OriginalHealth[client] * TalentStrength) : 
								OriginalHealth[client] + RoundToCeil(OriginalHealth[client] + TalentStrength);
		
		SetMaximumHealth(client, false, DefaultHealth[client] * 1.0);
	}
	else {

		//if (IsClientInRangeSpecialAmmo(client, "O") == -2.0) {
		
		//if (IsClientInRangeSpecialAmmo(client, "O") == -2.0) TalentStrength += (TalentStrength * IsClientInRangeSpecialAmmo(client, "O", false, _, TalentStrength));
		
		//if (TalentStrength < 1.0) TalentStrength = 1.0; 
		SetMaximumHealth(client, false, TalentStrength, isRawValue);
		//else SetMaximumHealth(client, false, TalentStrength * StringToFloat(GetConfigValue("survivor incap health?")));
	}*/
}

stock void ReviveDownedSurvivor(int client) {

	//if (IsLedged(client)) HealPlayer(client, client, 1.0, 'h');
	//else
	ExecCheatCommand(client, "give", "health");
	//SetEntProp(client, Prop_Send, "m_isIncapacitated", 0);
	SetMaximumHealth(client);
}

/*
if (RoundToFloor(PlayerHealth_Temp + HealAmount) >= GetMaximumHealth(client) && IsIncapacitated(client)) {

		//SetEntProp(client, Prop_Send, "m_isIncapacitated", 0);
		ReviveDownedSurvivor(client);
		GetAbilityStrengthByTrigger(client, activator, 'R', FindZombieClass(client), 0);
		GetAbilityStrengthByTrigger(activator, client, 'r', FindZombieClass(activator), 0);
		GiveMaximumHealth(client);
	}
	*/

stock int GetIncapCount(int client) {

	return GetEntProp(client, Prop_Send, "m_currentReviveCount");
}

stock bool IsBeingRevived(int client) {

	int target = GetEntPropEnt(client, Prop_Send, "m_reviveOwner");
	if (IsLegitimateClientAlive(target)) return true;
	return false;
}

stock int ReleasePlayer(int client) {
	int attacker = L4D2_GetInfectedAttacker(client);
	if (attacker > 0) {
		CalculateInfectedDamageAward(attacker, client);
		return attacker;
	}
	/* Charger */
	/*attacker = GetEntPropEnt(client, Prop_Send, "m_pummelAttacker");
	if (attacker > 0) {
		SetEntPropEnt(client, Prop_Send, "m_pummelAttacker", -1);
		SetEntPropEnt(attacker, Prop_Send, "m_pummelVictim", -1);
		//SetEntPropEnt(attacker, Prop_Send, "m_isCharging", 0);
		SetEntPropEnt(client, Prop_Send, "m_isHangingFromTongue", 0);
		SetEntityMoveType(client, MOVETYPE_WALK);
		SetEntityMoveType(attacker, MOVETYPE_WALK);
		StopSound(client, SNDCHAN_AUTO, "player/heartbeatloop.wav");
		return attacker;
	}
	attacker = GetEntPropEnt(client, Prop_Send, "m_carryAttacker");
	if (attacker > 0) {
		SetEntPropEnt(client, Prop_Send, "m_carryAttacker", -1);
		SetEntPropEnt(attacker, Prop_Send, "m_carryVictim", -1);
		SetEntPropEnt(attacker, Prop_Send, "m_isCharging", 0);
		SetEntPropEnt(client, Prop_Send, "m_isHangingFromTongue", 0);
		SetEntityMoveType(client, MOVETYPE_WALK);
		SetEntityMoveType(attacker, MOVETYPE_WALK);
		StopSound(client, SNDCHAN_AUTO, "player/heartbeatloop.wav");
		return attacker;
	}
	attacker = GetEntPropEnt(client, Prop_Send, "m_pounceAttacker");
	if (attacker > 0) {
		SetEntPropEnt(client, Prop_Send, "m_pounceAttacker", -1);
		SetEntPropEnt(attacker, Prop_Send, "m_pounceVictim", -1);
		SetEntityMoveType(client, MOVETYPE_WALK);
		SetEntityMoveType(attacker, MOVETYPE_WALK);
		StopSound(client, SNDCHAN_AUTO, "player/heartbeatloop.wav");
		return attacker;
	}
	attacker = GetEntPropEnt(client, Prop_Send, "m_tongueOwner");
	if (attacker > 0) {
		SetEntPropEnt(client, Prop_Send, "m_tongueOwner", -1);
		SetEntPropEnt(attacker, Prop_Send, "m_tongueVictim", -1);
		SetEntPropEnt(client, Prop_Send, "m_isHangingFromTongue", 0);
		SetEntityMoveType(client, MOVETYPE_WALK);
		SetEntityMoveType(attacker, MOVETYPE_WALK);
		StopSound(client, SNDCHAN_AUTO, "player/heartbeatloop.wav");
		return attacker;
	}
	attacker = GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker");
	if (attacker > 0) {
		SetEntPropEnt(client, Prop_Send, "m_jockeyAttacker", -1);
		SetEntPropEnt(attacker, Prop_Send, "m_jockeyVictim", -1);
		SetEntityMoveType(client, MOVETYPE_WALK);
		SetEntityMoveType(attacker, MOVETYPE_WALK);
		StopSound(client, SNDCHAN_AUTO, "player/heartbeatloop.wav");
		return attacker;
	}*/
	return -1;
}

stock int HealPlayer(int client, int activator, float f_TalentStrength, int ability, bool IsStrength = false) {	// must heal for abilities that instant-heal

	if (!IsLegitimateClientAlive(client)) return 0;
	int MyMaximumHealth = GetMaximumHealth(client);
	int PlayerHealth = GetClientHealth(client);
	/*if (PlayerHealth >= MyMaximumHealth && !IsIncapacitated(client)) {

		SetMaximumHealth(client);
		return 0;
	}*/
	if (L4D2_GetInfectedAttacker(client) != -1) return 0;
	float TalentStrength = GetAbilityMultiplier(activator, "E");
	if (TalentStrength == -1.0) TalentStrength = 0.0;
	TalentStrength = f_TalentStrength + (TalentStrength * f_TalentStrength);
	//if (!IsIncapacitated(client)) PlayerHealth = GetClientHealth(client) * 1.0;
	float PlayerHealth_Temp = GetEntPropFloat(client, Prop_Send, "m_healthBuffer");

	int HealAmount = 0;
	if (IsStrength) HealAmount = RoundToCeil(TalentStrength);
	else {

		if (TalentStrength > 1.0) TalentStrength = 1.0;
		HealAmount = RoundToCeil(GetMaximumHealth(client) * TalentStrength);
	}

	if (HealAmount < 1) return 0;

	int NewHealth = PlayerHealth + HealAmount;

	if (IsIncapacitated(client)) {
		if (NewHealth <= MyMaximumHealth) {
			// Incap health can't exceed actual player health - or they get instantly ressed.
			// that's wrong and i'll fix it, later. noted.
			SetEntityHealth(client, NewHealth);
			SetEntPropFloat(client, Prop_Send, "m_healthBuffer", NewHealth * 1.0);
			SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime() * 1.0);
		}
		else {
			HealAmount = MyMaximumHealth - PlayerHealth;
			SetEntityHealth(client, MyMaximumHealth);
			SetEntPropFloat(client, Prop_Send, "m_healthBuffer", 0.0);
			SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime() * 1.0);

			//OnPlayerRevived(activator, client);

			GetAbilityStrengthByTrigger(client, activator, "R", _, 0);
			GetAbilityStrengthByTrigger(activator, client, "r", _, 0);
		}
		// We auto-revive any survivor who heals over their maximum incap health.
		// We also give them a default health on top of the overheal, to help them maybe not get knocked again, immediately.
		// You don't die if you get incapped too many times, but it would be a pretty annoying game play loop.
		if (NewHealth >= MyMaximumHealth) {
		//if (!IsBeingRevived(client)) {
			SetEntProp(client, Prop_Send, "m_isIncapacitated", 0);
			int reviveOwner = GetEntPropEnt(client, Prop_Send, "m_reviveOwner");
			if (IsLegitimateClientAlive(reviveOwner)) {
				SetEntPropEnt(reviveOwner, Prop_Send, "m_reviveTarget", -1);
				SetEntityMoveType(reviveOwner, MOVETYPE_WALK);
			}
			SetEntPropEnt(client, Prop_Send, "m_reviveOwner", -1);
			NewHealth -= MyMaximumHealth;
			SetEntityMoveType(client, MOVETYPE_WALK);
			SetEntityHealth(client, RoundToCeil(GetMaximumHealth(client) * fHealthSurvivorRevive) + NewHealth);
		}
		/*else {
			SetEntityHealth(client, MyMaximumHealth);
			SetEntPropFloat(client, Prop_Send, "m_healthBuffer", MyMaximumHealth * 1.0);
			SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime());
		}*/
	}
	else {

		if (RoundToCeil(PlayerHealth + PlayerHealth_Temp + HealAmount) >= MyMaximumHealth) {

			int TempDiff = MyMaximumHealth - (PlayerHealth + HealAmount);

			if (TempDiff > 0) {

				HealAmount = MyMaximumHealth - RoundToFloor(PlayerHealth + PlayerHealth_Temp);

				SetEntPropFloat(client, Prop_Send, "m_healthBuffer", 0.0);
				SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime());
				GiveMaximumHealth(client);
			}
			else {

				SetEntityHealth(client, PlayerHealth + HealAmount);
				SetEntPropFloat(client, Prop_Send, "m_healthBuffer", TempDiff * 1.0);
				SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime());
			}
		}
		else {

			SetEntityHealth(client, PlayerHealth + HealAmount);
			if (PlayerHealth_Temp > 0.0) {

				SetEntPropFloat(client, Prop_Send, "m_healthBuffer", PlayerHealth_Temp);
				SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime());
			}
		}
	}
	if (HealAmount > 0) {

		if (IsLegitimateClientAlive(activator) && activator != client) {
			AwardExperience(activator, 1, HealAmount);
			float TheAbilityMultiplier = GetAbilityMultiplier(activator, "t");
			if (TheAbilityMultiplier != -1.0) {

				TheAbilityMultiplier *= (HealAmount * 1.0);
				iThreatLevel[activator] += (HealAmount - RoundToFloor(TheAbilityMultiplier));
			}
			else {

				iThreatLevel[activator] += HealAmount;
			}
		}
		// friendly fire module is no longer used - depricated //if (ability == 'T') ReadyUp_NtvFriendlyFire(activator, client, 0 - HealAmount, GetClientHealth(client), 1, 0);	// we "subtract" negative values from health.
	}

	return HealAmount;		// to prevent cartel being awarded for overheal.
}

stock void EnableHardcoreMode(int client, bool Disable=false) {

	if (!Disable) {
	
		SetEntityRenderMode(client, RENDER_TRANSCOLOR);
		SetEntityRenderColor(client, 255, 0, 0, 255);
		SetEntProp(client, Prop_Send, "m_bIsOnThirdStrike", 1);
		EmitSoundToClient(client, "player/heartbeatloop.wav");
	}
	else {

		SetEntityRenderMode(client, RENDER_NORMAL);
		SetEntityRenderColor(client, 255, 255, 255, 255);
		StopSound(client, SNDCHAN_AUTO, "player/heartbeatloop.wav");
	}
}

/*

	Helping new players adjust to the game brought on the idea of Pets.
	Pets provide benefits to the user, and can be changed at any time.

	Pets that have not yet been discovered are hidden from player view.
	This function properly positions the pet.
*/
/*
new entity = CreateEntityByName("prop_dynamic_override");
	if( entity != -1 )
	{
		SetEntityModel(entity, g_sModels[index]);
		DispatchSpawn(entity);
		if( g_bLeft4Dead2 )
		{
			SetEntPropFloat(entity, Prop_Send, "m_flModelScale", g_fSize[index]);
		}

		SetVariantString("!activator");
		AcceptEntityInput(entity, "SetParent", client);
		SetVariantString("eyes");
		AcceptEntityInput(entity, "SetParentAttachment");
		TeleportEntity(entity, g_vPos[index], g_vAng[index], NULL_VECTOR);
		SetEntProp(entity, Prop_Data, "m_iEFlags", 0);

		if( g_iCvarOpaq )
		{
			SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
			SetEntityRenderColor(entity, 255, 255, 255, g_iCvarOpaq);
		}

		g_iSelected[client] = index;
		g_iHatIndex[client] = EntIndexToEntRef(entity);

		if( !g_bHatView[client] )
			SDKHook(entity, SDKHook_SetTransmit, Hook_SetTransmit);

		if( g_bTranslation == false )
		{
			CPrintToChat(client, "%s%t", CHAT_TAG, "Hat_Wearing", g_sNames[index]);
		}
		else
		{
			decl String:sMsg[128];
			Format(sMsg, sizeof(sMsg), "Hat %d", index + 1);
			Format(sMsg, sizeof(sMsg), "%T", sMsg, client);
			CPrintToChat(client, "%s%t", CHAT_TAG, "Hat_Wearing", sMsg);
		}

		return true;
	}
*/


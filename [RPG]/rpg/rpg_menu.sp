/* put the line below after all of the includes!
#pragma newdecls required
*/

stock void BuildMenuTitle(int client, Handle menu, int bot = 0, int type = 0, bool bIsPanel = false, bool ShowLayerEligibility = false) {	// 0 is legacy type that appeared on all menus. 0 - Main Menu | 1 - Upgrades | 2 - Points

	char text[512];
	int CurRPGMode = iRPGMode;

	char currExperience[64];
	char targExperience[64];
	char ratingFormatted[64];

	if (bot == 0) {
		AddCommasToString(ExperienceLevel[client], currExperience, sizeof(currExperience));
		AddCommasToString(CheckExperienceRequirement(client), targExperience, sizeof(targExperience));
		AddCommasToString(Rating[client], ratingFormatted, sizeof(ratingFormatted));

		char PointsText[64];
		Format(PointsText, sizeof(PointsText), "%T", "Points Text", client, Points[client]);

		int CheckRPGMode = iRPGMode;
		if (CheckRPGMode > 0) {

			bool bIsLayerEligible = (PlayerCurrentMenuLayer[client] <= 1 || GetLayerUpgradeStrength(client, PlayerCurrentMenuLayer[client] - 1) >= PlayerCurrentMenuLayer[client]) ? true : false;

			int TotalPoints = TotalPointsAssigned(client);
			char PlayerLevelText[256];
			MenuExperienceBar(client, _, _, PlayerLevelText, sizeof(PlayerLevelText));
			Format(PlayerLevelText, sizeof(PlayerLevelText), "%T", "Player Level Text", client, PlayerLevel[client], iMaxLevel, currExperience, PlayerLevelText, targExperience, ratingFormatted);
			if (SkyLevel[client] > 0) Format(PlayerLevelText, sizeof(PlayerLevelText), "%T", "Prestige Level Text", client, SkyLevel[client], iSkyLevelMax, PlayerLevelText);
			int maximumPlayerUpgradesToShow = (iShowTotalNodesOnTalentTree == 1) ? MaximumPlayerUpgrades(client, true) : MaximumPlayerUpgrades(client);
			if (CheckRPGMode != 0) {
				Format(text, sizeof(text), "%T", "RPG Header", client, PlayerLevelText, TotalPoints, maximumPlayerUpgradesToShow, UpgradesAvailable[client] + FreeUpgrades[client]);
				if (ShowLayerEligibility) {
					if (bIsLayerEligible) {
						int strengthOfCurrentLayer = GetLayerUpgradeStrength(client, PlayerCurrentMenuLayer[client], _, _, _, _, true);
						int allUpgradesThisLayer = GetLayerUpgradeStrength(client, PlayerCurrentMenuLayer[client], _, _, true);//true for skip attributes, too?
						int totalPossibleNodesThisLayer = GetLayerUpgradeStrength(client, PlayerCurrentMenuLayer[client], _, _, _, true);
						Format(text, sizeof(text), "%T", "RPG Layer Eligible", client, text, PlayerCurrentMenuLayer[client], strengthOfCurrentLayer, PlayerCurrentMenuLayer[client] + 1, allUpgradesThisLayer, totalPossibleNodesThisLayer);
					}
					else Format(text, sizeof(text), "%T", "RPG Layer Not Eligible", client, text, PlayerCurrentMenuLayer[client]);
				}
			}
			if (CheckRPGMode != 1) Format(text, sizeof(text), "%s\n%s", text, PointsText);
			if (ExperienceDebt[client] > 0 && iExperienceDebtEnabled == 1 && PlayerLevel[client] >= iExperienceDebtLevel) {
				AddCommasToString(ExperienceDebt[client], currExperience, sizeof(currExperience));
				Format(text, sizeof(text), "%T", "Menu Experience Debt", client, text, currExperience, RoundToCeil(100.0 * fExperienceDebtPenalty));
			}
		}
		else if (CurRPGMode == 0) Format(text, sizeof(text), "%s", PointsText);
		else Format(text, sizeof(text), "Control Panel");
	}
	else {
		AddCommasToString(ExperienceLevel_Bots, currExperience, sizeof(currExperience));
		AddCommasToString(CheckExperienceRequirement(-1, true), targExperience, sizeof(targExperience));
		AddCommasToString(GetUpgradeExperienceCost(-1), ratingFormatted, sizeof(ratingFormatted));

		if (CurRPGMode == 0 || CurRPGMode == 2 && bot == -1) Format(text, sizeof(text), "%T", "Menu Header 0 Director", client, Points_Director);
		else if (CurRPGMode == 1) {

			// Bots level up strictly based on experience gain. Honestly, I have been thinking about removing talent-based leveling.
			Format(text, sizeof(text), "%T", "Menu Header 1 Talents Bot", client, PlayerLevel_Bots, iMaxLevel, currExperience, targExperience, ratingFormatted);
		}
		else if (CurRPGMode == 2) {

			Format(text, sizeof(text), "%T", "Menu Header 2 Talents Bot", client, PlayerLevel_Bots, iMaxLevel, currExperience, targExperience, ratingFormatted, Points_Director);
		}
	}
	ReplaceString(text, sizeof(text), "PCT", "%%", true);
	Format(text, sizeof(text), "\n \n%s\n \n", text);
	if (!bIsPanel) menu.SetTitle(text);
	else menu.DrawText(text);
}

stock bool CheckKillPositions(client, bool b_AddPosition) {

	// If the finale is active, we don't do anything here, and always return false.
	//if (!b_IsFinaleActive) return false;
	// If there are enemy combatants within range - and thus the player is fighting - don't save locations.
	//if (EnemyCombatantsWithinRange(client, StringToFloat(GetConfigValue("out of combat distance?")))) return false;

	// If not adding a kill position, it means we need to check the clients current position against all positions in the list, and see if any are within the config value.
	// If they are, we return true, otherwise false.
	// If we are adding a position, we check to see if the size is greater than the max value in the config. If it is, we remove the oldest entry, and add the newest entry.
	// We can do this by removing from array, or just resizing the array to the config value after adding the value.

	float Origin[3];
	GetClientAbsOrigin(client, Origin);
	char coords[64];

	float AntiFarmDistance = GetConfigValueFloat("anti farm kill distance?");
	int AntiFarmMax = GetConfigValueInt("anti farm kill max locations?");

	if (!b_AddPosition) {

		float Last_Origin[3];
		int size				= h_KilledPosition_X[client].Length;
		
		for (int i = 0; i < size; i++) {

			h_KilledPosition_X[client].GetString(i, coords, sizeof(coords));
			Last_Origin[0]		= StringToFloat(coords);
			h_KilledPosition_Y[client].GetString(i, coords, sizeof(coords));
			Last_Origin[1]		= StringToFloat(coords);
			h_KilledPosition_Z[client].GetString(i, coords, sizeof(coords));
			Last_Origin[2]		= StringToFloat(coords);

			// If the players current position is too close to any stored positions, return true
			if (GetVectorDistance(Origin, Last_Origin) <= AntiFarmDistance) return true;
		}
	}
	else {

		int newsize = h_KilledPosition_X[client].Length;

		h_KilledPosition_X[client].Resize(newsize + 1);
		Format(coords, sizeof(coords), "%3.4f", Origin[0]);
		h_KilledPosition_X[client].SetString(newsize, coords);

		h_KilledPosition_Y[client].Resize(newsize + 1);
		Format(coords, sizeof(coords), "%3.4f", Origin[1]);
		h_KilledPosition_Y[client].SetString(newsize, coords);

		h_KilledPosition_Z[client].Resize(newsize + 1);
		Format(coords, sizeof(coords), "%3.4f", Origin[2]);
		h_KilledPosition_Z[client].SetString(newsize, coords);

		while (h_KilledPosition_X[client].Length > AntiFarmMax) {

			h_KilledPosition_X[client].Erase(0);
			h_KilledPosition_Y[client].Erase(0);
			h_KilledPosition_Z[client].Erase(0);
		}
	}
	return false;
}

stock bool HasTalentUpgrades(int client, char[] TalentName) {

	if (IsLegitimateClient(client)) {

		int a_Size			=	0;

		a_Size		= a_Menu_Talents.Length;

		char TalentName_Compare[64];

		for (int i = 0; i < a_Size; i++) {

			//ChanceKeys[client]			= a_Menu_Talents.Get(i, 0);
			//ChanceValues[client]		= a_Menu_Talents.Get(i, 1);
			ChanceSection[client]		= a_Menu_Talents.Get(i, 2);

			ChanceSection[client].GetString(0, TalentName_Compare, sizeof(TalentName_Compare));
			if (StrEqual(TalentName, TalentName_Compare, false) && GetTalentStrength(client, TalentName) > 0) return true;
		}
	}
	return false;
}

public Action CMD_LoadProfileEx(int client, int args) {

	if (args < 1) {

		PrintToChat(client, "!loadprofile <in-game user / steamid>");
		return Plugin_Handled;
	}
	char arg[512];
	GetCmdArg(1, arg, sizeof(arg));

	if (!bIsTalentTwo[client] && StrContains(arg, "STEAM", false) == -1) {	// they have named a user.

		char TheName[512];
		for (int i = 1; i <= MaxClients; i++) {

			if (!IsLegitimateClient(i) || IsFakeClient(i)) continue;

			GetClientName(i, TheName, sizeof(TheName));
			if (StrContains(arg, TheName, false) != -1) {

				GetClientAuthId(i, AuthId_Steam2, arg, sizeof(arg));
				break;
			}
		}
	}
	ReadProfiles(client, arg);
	PrintToChat(client, "trying to load profile of steam id: %s", arg);
	return Plugin_Handled;
}

stock void LoadProfileEx(int client, char[] key) {
	if (IsSurvivorBot(LoadTarget[client]) || IsSurvivorBot(client) || LoadTarget[client] == -1 || IsLegitimateClient(LoadTarget[client]) && GetClientTeam(LoadTarget[client]) == TEAM_SURVIVOR) {
		int targetClient = LoadTarget[client];
		if (LoadTarget[client] == -1 || !IsLegitimateClient(LoadTarget[client])) targetClient = client;
		LoadTarget[client] = -1;
		if (IsSurvivorBot(targetClient) || b_IsLoaded[targetClient]) {
			LoadProfileEx_Confirm(targetClient, key);
		}
	}
}

stock void LoadProfileEx_Confirm(int client, char[] key) {
	if (!IsLegitimateClient(client)) return;

	char tquery[512];
	if (hDatabase == INVALID_HANDLE) {

		LogMessage("Database couldn't be found, cannot save for %N", client);
		return;
	}
	TempAttributes[client].Clear();

	//if (HasCommandAccess(client, GetConfigValue("director talent flags?"))) PrintToChat(client, "%T", "loading profile ex", client, orange, key);
	//else
	if (!IsFakeClient(client)) PrintToChat(client, "%T", "loading profile", client, orange, green, key);

	//b_IsLoading[client] = false;
	Format(tquery, sizeof(tquery), "SELECT `steam_id`, `total upgrades` FROM `%s` WHERE (`steam_id` = '%s');", TheDBPrefix, key);
	// maybe set a value equal to the users steamid integer only, so if steam:0:1:23456, set the value of "client" equal to 23456 and then set the client equal to whatever client's steamid contains 23456?
	//LogMessage("Loading %N data: %s", client, tquery);
	hDatabase.Query(QueryResults_LoadEx, tquery, client);
	LogMessage(tquery);
}

/*stock CheckLoadProfileRequest(client, RequestType = 0, bool:DontTell = false) {

	if (!IsLegitimateClient(client)) return -1;
	decl String:TargetName[64];

	for (new i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && GetClientTeam(i) == TEAM_SURVIVOR && i != client) {

			if (client == LoadProfileRequestName[i]) {	// this is the player that client sent the request to.

				if (RequestType == 0) {		// 0	- Deny Request

					GetClientName(i, TargetName, sizeof(TargetName));
					if (!DontTell) PrintToChat(client, "%T", "profile request cancelled", client, orange, green, TargetName);
					LoadProfileRequestName[i] = -1;
					if (LoadTarget[])
				}
			}
		}
	}
}*/

/*stock CheckLoadProfileRequest(client, bool:CancelRequest = false, bool:DontTell = false) {

	if (!IsLegitimateClient(client)) return -1;
	decl String:TargetName[64];

	for (new i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && GetClientTeam(i) != TEAM_INFECTED && i != client) {

			if (client == LoadProfileRequestName[i]) {

				// the client has sent a load request, so if they are trying to cancel, we cancel.
				if (CancelRequest) {

					GetClientName(i, TargetName, sizeof(TargetName));
					if (!DontTell) PrintToChat(client, "%T", "profile request cancelled", client, orange, green, TargetName);
					LoadProfileRequestName[i] = -1;
					LoadTarget[client] = -1;
					return -1;
				}
				return i;
			}
		}
	}
	if (LoadTarget[client] == -1) return client;
	return LoadTarget[client];
}*/

public QueryResults_LoadEx(Handle howner, Handle hndl, const char[] error, any client)
{
	if ( hndl != INVALID_HANDLE )
	{
		char key[64];
		char text[64];
		char result[3][64];

		int owner = client;	// so if the load target is not the client we can track both.
		bool rowsFound = false;

		while (hndl.FetchRow())
		{
			hndl.FetchString(0, key, sizeof(key));
			rowsFound = true;	// not sure how else to verify this without running a count query first.
			if (LoadTarget[owner] != owner && LoadTarget[owner] != -1 && (IsSurvivorBot(LoadTarget[owner]) || IsLegitimateClient(LoadTarget[owner]) && GetClientTeam(LoadTarget[owner]) != TEAM_INFECTED)) client = LoadTarget[owner];
			if (!IsLegitimateClient(client)) return;

			ExplodeString(key, "+", result, 3, 64);
			if (!StrEqual(result[1], LoadoutName[owner], false)) Format(LoadoutName[client], sizeof(LoadoutName[]), "%s", result[1]);
			TempAttributes[client].PushString(key);
			TempAttributes[client].Push(hndl.FetchInt(1));

			PlayerUpgradesTotal[client]	= hndl.FetchInt(1);
			UpgradesAvailable[client]	= 0;
			FreeUpgrades[client] = PlayerLevel[client] - PlayerUpgradesTotal[client];
			if (FreeUpgrades[client] < 0) FreeUpgrades[client] = 0;
			PurchaseTalentPoints[client] = PlayerUpgradesTotal[client];
		}
		if (!rowsFound || !IsLegitimateClient(client)) {
			b_IsLoading[client] = false;
			//LogMessage("Could not load the profile on target client forced by %N, exiting loading sequence.", client);
			return;
		}
		char tquery[512];
		//decl String:key[64];
		GetClientAuthId(client, AuthId_Steam2, key, sizeof(key));

		LoadPos[client] = 0;
		if (!b_IsLoadingTrees[client]) b_IsLoadingTrees[client] = true;
		a_Database_Talents.GetString(0, text, sizeof(text));
		Format(tquery, sizeof(tquery), "SELECT `steam_id`, `%s` FROM `%s` WHERE (`steam_id` = '%s');", text, TheDBPrefix, key);
		hDatabase.Query(QueryResults_LoadTalentTreesEx, tquery, client);
	}
	else
	{
		SetFailState("Error: %s PREFIX IS: %s", error, TheDBPrefix);
		return;
	}
}

public QueryResults_LoadTalentTreesEx(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl != INVALID_HANDLE) {

		char text[512];
		char tquery[512];
		int talentlevel = 0;
		int size = a_Menu_Talents.Length;
		char key[64];
		char skey[64];

		if (!IsLegitimateClient(client)) {

			LogMessage("is not a valid client.");
			return;
		}

		if (a_Database_PlayerTalents[client].Length != size) {

			PlayerAbilitiesCooldown[client].Resize(size);
			a_Database_PlayerTalents[client].Resize(size);
			a_Database_PlayerTalents_Experience[client].Resize(size);
		}

		while (hndl.FetchRow()) {

			hndl.FetchString(0, key, sizeof(key));

			if (LoadPos[client] < a_Database_Talents.Length) {

				talentlevel = hndl.FetchInt(1);
				//TempTalents[client].SetString(LoadPos[client], text);
				a_Database_PlayerTalents[client].Set(LoadPos[client], talentlevel);

				LoadPos[client]++;
				while (LoadPos[client] < a_Database_Talents.Length) {

					//TalentTreeKeys[client]			= a_Menu_Talents.Get(LoadPos[client], 0);
					TalentTreeValues[client]		= a_Menu_Talents.Get(LoadPos[client], 1);

					if (GetKeyValueIntAtPos(TalentTreeValues[client], IS_TALENT_TYPE) == 1 ||
						GetKeyValueIntAtPos(TalentTreeValues[client], IS_SUB_MENU_OF_TALENTCONFIG) == 1 ||
						GetKeyValueIntAtPos(TalentTreeValues[client], ITEM_ITEM_ID) == 1) {

						LoadPos[client]++;
						continue;	// we don't load class attributes because we're loading another players talent specs. don't worry... we'll load the CARTEL for the user, after.
					}
					break;
				}
				if (LoadPos[client] < a_Database_Talents.Length) {

					a_Database_Talents.GetString(LoadPos[client], text, sizeof(text));
					Format(tquery, sizeof(tquery), "SELECT `steam_id`, `%s` FROM `%s` WHERE (`steam_id` = '%s');", text, TheDBPrefix, key);
					hDatabase.Query(QueryResults_LoadTalentTreesEx, tquery, client);
					return;
				}
				else {

					Format(tquery, sizeof(tquery), "SELECT `steam_id`, `primarywep`, `secondwep` FROM `%s` WHERE (`steam_id` = '%s');", TheDBPrefix, key);
					//PrintToChat(client, "%s", tquery);
					hDatabase.Query(QueryResults_LoadTalentTreesEx, tquery, client);
					return;
				}
			}
			else {
				if (hWeaponList[client].Length != 2) {

					hWeaponList[client].Clear();
					hWeaponList[client].Resize(2);
				}
				else if (hWeaponList[client].Length > 0) {

					hndl.FetchString(1, text, sizeof(text));
					hWeaponList[client].SetString(0, text);
					
					hndl.FetchString(2, text, sizeof(text));
					hWeaponList[client].SetString(1, text);

					GiveProfileItems(client);
				}
				//PrintToChat(client, "ABOUT TO LOAD %s", text);
				//}

				GetClientAuthId(client, AuthId_Steam2, skey, sizeof(skey));	// this is necessary, because they might still be in the process of loading another users data. this is a backstop in-case the loader has switched targets mid-load. this is why we don't first check the value of LoadProfileRequestName[client].
				LoadPos[client] = 0;
				LoadTalentTrees(client, skey, true, key);
			}
			int PlayerTalentPoints			=	0;
			char TalentName[64];

			//new size						=	a_Menu_Talents.Length;

			//if (StrEqual(ConfigName, CONFIG_MENUSURVIVOR)) size			=	a_Menu_Talents_Survivor.Length;
			//else if (StrEqual(ConfigName, CONFIG_MENUINFECTED)) size	=	a_Menu_Talents_Infected.Length;

			for (int i = 0; i < size; i++) {

				//MenuKeys[client]			= a_Menu_Talents.Get(i, 0);
				MenuValues[client]			= a_Menu_Talents.Get(i, 1);
				MenuSection[client]			= a_Menu_Talents.Get(i, 2);
				if (GetKeyValueIntAtPos(MenuValues[client], IS_TALENT_TYPE) == 1) continue;		// skips attributes.
				//if (GetKeyValueInt(MenuKeys[client], MenuValues[client], "is ability?") == 1) continue;		// abilities used to be auto-unlocked, now they require a point.
				if (GetKeyValueIntAtPos(MenuValues[client], ITEM_ITEM_ID) == 1) continue;

				MenuSection[client].GetString(0, TalentName, sizeof(TalentName));

				PlayerTalentPoints = GetTalentStrength(client, TalentName);
				if (PlayerTalentPoints > 1) {
					FreeUpgrades[client] += (PlayerTalentPoints - 1);
					PlayerUpgradesTotal[client] -= (PlayerTalentPoints - 1);
					AddTalentPoints(client, TalentName, (PlayerTalentPoints - 1));
				}
			}
		}
		if (IsSurvivorBot(client) && PlayerLevel[client] < iPlayerStartingLevel) {
			b_IsLoading[client] = false;
			bIsTalentTwo[client] = false;
			b_IsLoadingTrees[client] = false;
			CreateNewPlayerEx(client);
			return;
		}
		else {

			char Name[64];
			if (iRPGMode >= 1) {

				SetMaximumHealth(client);
				GiveMaximumHealth(client);
				ProfileEditorMenu(client);
				GetClientName(client, Name, sizeof(Name));
				b_IsLoading[client] = false;
				b_IsLoadingTrees[client] = false;
				//bIsTalentTwo[client] = false;

				if (PlayerLevel[client] >= iPlayerStartingLevel) {

					PrintToChatAll("%t", "loaded profile", blue, Name, white, green, LoadoutName[client]);
					if (bIsNewPlayer[client]) {

						bIsNewPlayer[client] = false;
						SaveAndClear(client);
						ReadProfiles(client, "all");	// int players are given an option on what they want to play.
					}
				}
				else SetTotalExperienceByLevel(client, iPlayerStartingLevel);
				//EquipBackpack(client);
				return;
			}
		}
	}
	else {
		
		SetFailState("Error: %s", error);
		return;
	}
}

stock void LoadProfile_Confirm(int client, char[] ProfileName) {

	//new Handle:menu = new Menu(LoadProfile_ConfirmHandle);
	//decl String:text[64];
	//decl String:result[2][64];
	LoadProfileEx(client, ProfileName);
}

stock LoadProfileEx_Request(client, target) {

	LoadProfileRequestName[target] = client;

	Handle menu = new Menu(LoadProfileRequestHandle);
	char text[512];
	char ClientName[64];
	GetClientName(client, ClientName, sizeof(ClientName));
	Format(text, sizeof(text), "%T", "profile load request", target, ClientName);
	menu.SetTitle(text);

	Format(text, sizeof(text), "%T", "Allow Profile Request", target);
	menu.AddItem(text, text);
	Format(text, sizeof(text), "%T", "Deny Profile Request", target);
	menu.AddItem(text, text);

	menu.ExitBackButton = true;
	menu.Display(target, 0);
}

public LoadProfileRequestHandle(Handle menu, MenuAction action, client, slot) {

	if (action == MenuAction_Select) {

		char TargetName[64];
		if (slot == 0 && IsLegitimateClient(LoadProfileRequestName[client])) {

			GetClientName(LoadProfileRequestName[client], TargetName, sizeof(TargetName));
			PrintToChat(client, "%T", "target has authorized you", client, green, TargetName, orange);
			GetClientName(client, TargetName, sizeof(TargetName));
			PrintToChat(LoadProfileRequestName[client], "%T", "authorized client to load", LoadProfileRequestName[client], orange, green, TargetName, orange, blue, orange);

			LoadTarget[LoadProfileRequestName[client]] = client;
			//LoadProfileEx_Confirm(LoadProfileRequestName[client], LoadProfileRequest[client]);
		}
		else {

			if (IsLegitimateClient(LoadProfileRequestName[client]) && LoadTarget[LoadProfileRequestName[client]] == client) {

				GetClientName(client, TargetName, sizeof(TargetName));
				PrintToChat(LoadProfileRequestName[client], "%T", "user has withdrawn authorization", LoadProfileRequestName[client], green, TargetName, orange);
				GetClientName(LoadProfileRequestName[client], TargetName, sizeof(TargetName));
				PrintToChat(client, "%T", "withdrawn authorization to user", client, orange, green, TargetName);
				LoadTarget[LoadProfileRequestName[client]] = -1;
			}
			LoadProfileRequestName[client] = -1;
			delete menu;
		}
	}
	else if (action == MenuAction_Cancel) {

		if (slot == MenuCancel_ExitBack) {

			ProfileEditorMenu(client);
		}
	}
	if (action == MenuAction_End && menu != INVALID_HANDLE) {

		delete menu;
	}
}

stock GetTeamComposition(int client) {

	Handle menu = new Menu(TeamCompositionMenuHandle);
	RPGMenuPosition[client].Clear();

	char text[512];
	char ratingText[64];

	int myteam = GetClientTeam(client);
	for (int i = 1; i <= MaxClients; i++) {

		if (!IsLegitimateClient(i) || myteam != GetClientTeam(i)) continue;

		GetClientName(i, text, sizeof(text));

		AddCommasToString(Rating[i], ratingText, sizeof(ratingText));
		Format(text, sizeof(text), "%s Lv.%d\t\tScore: %s", text, PlayerLevel[i], ratingText);
		menu.AddItem(text, text);
	}
	menu.ExitBackButton = true;
	menu.Display(client, 0);
}

public TeamCompositionMenuHandle(Handle menu, MenuAction action, client, slot) {

	if (action == MenuAction_Select) {

		GetTeamComposition(client);
	}
	else if (action == MenuAction_Cancel) {

		if (slot == MenuCancel_ExitBack) {

			BuildMenu(client, "main");
		}
	}
	if (action == MenuAction_End) {

		//LoadTarget[client] = -1;
		delete menu;
	}
}

stock LoadProfileTargetSurvivorBot(int client) {

	Handle menu = new Menu(TargetSurvivorBotMenuHandle);
	RPGMenuPosition[client].Clear();

	char text[512];
	char pos[512];
	char ratingText[64];

	Format(text, sizeof(text), "%T", "select survivor bot", client);
	menu.SetTitle(text);
	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && GetClientTeam(i) != TEAM_INFECTED) {

			Format(pos, sizeof(pos), "%d", i);
			RPGMenuPosition[client].PushString(pos);
			GetClientName(i, pos, sizeof(pos));
			AddCommasToString(Rating[i], ratingText, sizeof(ratingText));
			Format(pos, sizeof(pos), "%s Lv.%d\t\tScore: %s", pos, PlayerLevel[i], ratingText);
			menu.AddItem(pos, pos);
		}
	}
	menu.ExitBackButton = true;
	menu.Display(client, 0);
}

public TargetSurvivorBotMenuHandle(Handle menu, MenuAction action, client, slot) {

	if (action == MenuAction_Select) {

		char text[64];
		RPGMenuPosition[client].GetString(slot, text, sizeof(text));
		int target = StringToInt(text);
		if (IsLegitimateClient(LoadTarget[client]) && IsLegitimateClient(LoadProfileRequestName[LoadTarget[client]]) && client == LoadProfileRequestName[LoadTarget[client]]) LoadProfileRequestName[LoadTarget[client]] = -1;
		if (target == client) {

			LoadTarget[client] = -1;
		}
		else {

			char thetext[64];
			GetConfigValue(thetext, sizeof(thetext), "profile override flags?");

			if (IsSurvivorBot(target) || HasCommandAccess(client, thetext)) LoadTarget[client] = target;
			else {

				LoadProfileEx_Request(client, target);
				ProfileEditorMenu(client);
			}
		}
		ProfileEditorMenu(client);
	}
	else if (action == MenuAction_Cancel) {

		if (slot == MenuCancel_ExitBack) {

			ProfileEditorMenu(client);
		}
	}
	if (action == MenuAction_End) {

		//LoadTarget[client] = -1;
		delete menu;
	}
}

stock ReadProfilesEx(int client) {	// To view/load another users profile, we need to know who to target.


	//	ReadProfiles_Generate has been called and the PlayerProfiles[client] handle has been generated.
	Handle menu = new Menu(ReadProfilesMenuHandle);
	RPGMenuPosition[client].Clear();

	char text[64];
	char pos[10];
	char result[3][64];

	Format(text, sizeof(text), "%T", "profile editor title", client, LoadoutName[client]);
	menu.SetTitle(text);

	int size = PlayerProfiles[client].Length;
	if (size < 1) {

		PrintToChat(client, "%T", "no profiles to load", client, orange);
		ProfileEditorMenu(client);
		return;
	}
	for (int i = 0; i < size; i++) {

		PlayerProfiles[client].GetString(i, text, sizeof(text));
		ExplodeString(text, "+", result, 3, 64);
		menu.AddItem(result[1], result[1]);

		Format(pos, sizeof(pos), "%d", i);
		RPGMenuPosition[client].PushString(pos);
	}
	menu.ExitBackButton = true;
	menu.Display(client, 0);
}

public ReadProfilesMenuHandle(Handle menu, MenuAction action, client, slot) {

	if (action == MenuAction_Select) {

		char text[64];
		RPGMenuPosition[client].GetString(slot, text, sizeof(text));

		//new target = client;
		//if (LoadTarget[client] != -1 && LoadTarget[client] != client) target = LoadTarget[client]; 
		// && (IsSurvivorBot(LoadTarget[client]) || !bIsInCombat[LoadTarget[client]]))

		if (StringToInt(text) < PlayerProfiles[client].Length) {
			//(!bIsInCombat[client] || target != client) &&

			PlayerProfiles[client].GetString(StringToInt(text), text, sizeof(text));
			LoadProfile_Confirm(client, text);
		}
		else ProfileEditorMenu(client);
	}
	else if (action == MenuAction_Cancel) {

		if (slot == MenuCancel_ExitBack) ProfileEditorMenu(client);
	}
	if (action == MenuAction_End) {

		delete menu;
	}
}

stock bool GetLastOpenedMenu(client, bool SetIt = false) {

	int size	= a_Menu_Main.Length;
	char menuname[64];
	char pmenu[64];

	for (int i = 0; i < size; i++) {

		// Pull data from the parsed config.
		MenuKeys[client]		= a_Menu_Main.Get(i, 0);
		MenuValues[client]		= a_Menu_Main.Get(i, 1);
		FormatKeyValue(menuname, sizeof(menuname), MenuKeys[client], MenuValues[client], "menu name?");

		if (!StrEqual(menuname, LastOpenedMenu[client], false)) continue;
		FormatKeyValue(pmenu, sizeof(pmenu), MenuKeys[client], MenuValues[client], "previous menu?");

		if (SetIt) {

			if (!StrEqual(pmenu, "-1", false)) Format(LastOpenedMenu[client], sizeof(LastOpenedMenu[]), "%s", pmenu);
			return true;
		}
	}
	return false;
}

stock void AddMenuStructure(int client, char[] MenuName) {

	MenuStructure[client].Resize(MenuStructure[client].Length + 1);
	MenuStructure[client].SetString(MenuStructure[client].Length - 1, MenuName);
}

stock void VerifyAllActionBars(int client) {

	if (!IsLegitimateClient(client)) return;
	int ActionSlots = iActionBarSlots;
	if (ActionBar[client].Length != ActionSlots) ActionBar[client].Resize(ActionSlots);

	// If the user doesn't meet the requirements or have the item it'll be unequipped here

	char talentname[64];

	int size = iActionBarSlots;
	for (int i = 0; i < size; i++) {

		ActionBar[client].GetString(i, talentname, sizeof(talentname));
		VerifyActionBar(client, talentname, i);
	}
}

stock ShowActionBar(int client) {

	Handle menu = new Menu(ActionBarHandle);

	char text[128], talentname[64];
	Format(text, sizeof(text), "Stamina: %d/%d", SurvivorStamina[client], GetPlayerStamina(client));
	static baseWeaponDamage = 0;
	static char baseWeaponDamageText[64];
	if (iShowDamageOnActionBar == 1) {
		baseWeaponDamage = DataScreenWeaponDamage(client);
		if (baseWeaponDamage > 0) {
			AddCommasToString(baseWeaponDamage, baseWeaponDamageText, sizeof(baseWeaponDamageText));
			if (IsMeleeAttacker(client)) Format(text, sizeof(text), "%s\nMelee Damage: %s", text, baseWeaponDamageText);
			else Format(text, sizeof(text), "%s\nGun Damage: %s", text, baseWeaponDamageText);
			// DataScreenTargetName returns two results on every call - an integer return value, and the text it formats w/ baseWeaponDamageText
			if (DataScreenTargetName(client, baseWeaponDamageText, sizeof(baseWeaponDamageText)) != -1) {
				Format(text, sizeof(text), "%s (%s)", text, baseWeaponDamageText);
			}
		}
	}
	//if (baseWeaponDamage > 0) Format(text, sizeof(text), "%s\nBullet Damage: %s", text, AddCommasToString(baseWeaponDamage));
	menu.SetTitle(text);
	int size = iActionBarSlots;
	float AmmoCooldownTime = -1.0, fAmmoCooldownTime = -1.0, fAmmoCooldown = 0.0, fAmmoActive = 0.0;

	char acmd[10];
	GetConfigValue(acmd, sizeof(acmd), "action slot command?");
	int TalentStrength = 0;

	//decl String:TheValue[64];
	bool bIsAbility = false;
	int ManaCost = 0;
	float TheAbilityMultiplier = 0.0;
	//decl String:tCooldown[16];
	for (int i = 0; i < size; i++) {

		ActionBar[client].GetString(i, talentname, sizeof(talentname));
		TalentStrength = GetTalentStrength(client, talentname);
		if (TalentStrength > 0) {

			AmmoCooldownTime = GetAmmoCooldownTime(client, talentname);
			GetTranslationOfTalentName(client, talentname, text, sizeof(text), _, true);
			Format(text, sizeof(text), "%T", text, client);
		}
		else Format(text, sizeof(text), "%T", "No Action Equipped", client);

		Format(text, sizeof(text), "!%s%d:\t%s", acmd, i+1, text);
		if (TalentStrength > 0) {

			bIsAbility = IsAbilityTalent(client, talentname);

			if (!bIsAbility) {

				ManaCost = RoundToCeil(GetSpecialAmmoStrength(client, talentname, 2));
				if (ManaCost > 0) Format(text, sizeof(text), "%s\nStamina Cost: %d", text, ManaCost);

				AmmoCooldownTime = GetAmmoCooldownTime(client, talentname);
				fAmmoCooldownTime = AmmoCooldownTime;
				if (fAmmoCooldownTime != -1.0) {

					AmmoCooldownTime = GetSpecialAmmoStrength(client, talentname);

					// finding out the active time of ammos isn't as easy because of design...
					fAmmoCooldown = AmmoCooldownTime + GetSpecialAmmoStrength(client, talentname, 1);
					AmmoCooldownTime = AmmoCooldownTime - (fAmmoCooldown - fAmmoCooldownTime);
					//PrintToChat(client, "%3.3f = %3.3f - (%3.3f - %3.3f)", AmmoCooldownTime, GetSpecialAmmoStrength(client, talentname), fAmmoCooldown, fAmmoCooldownTime);
				}
				else {

					AmmoCooldownTime = GetSpecialAmmoStrength(client, talentname);
				}
			}
			else {
				if (AbilityDoesDamage(client, talentname)) {
					TheAbilityMultiplier = GetAbilityMultiplier(client, "0", _, talentname);
					baseWeaponDamage = RoundToCeil(baseWeaponDamage * TheAbilityMultiplier);

					Format(text, sizeof(text), "%s\nDamage: %d", text, baseWeaponDamage);
				}
				AmmoCooldownTime = GetAmmoCooldownTime(client, talentname, true);
				fAmmoCooldownTime = AmmoCooldownTime;

				// abilities dont show active time correctly (NOT FIXED)
				fAmmoActive = GetAbilityValue(client, talentname, ABILITY_ACTIVE_TIME);
				if (fAmmoCooldownTime != -1.0) {

					fAmmoCooldown = GetSpellCooldown(client, talentname);
					AmmoCooldownTime = fAmmoActive - (fAmmoCooldown - fAmmoCooldownTime);
				}
			}
			if (bIsAbility && AmmoCooldownTime != -1.0 && AmmoCooldownTime > 0.0 || !bIsAbility && (AmmoCooldownTime > 0.0 || AmmoCooldownTime == -1.0)) Format(text, sizeof(text), "%s\nActive: %3.2fs", text, AmmoCooldownTime);

			AmmoCooldownTime = fAmmoCooldownTime;
			if (AmmoCooldownTime != -1.0) Format(text, sizeof(text), "%s\nCooldown: %3.2fs", text, AmmoCooldownTime);
		}
		menu.AddItem(text, text);
	}
	menu.ExitBackButton = false;
	menu.Display(client, 0);
}

stock bool AbilityDoesDamage(int client, char[] TalentName) {

	char theQuery[64];
	//Format(theQuery, sizeof(theQuery), "does damage?");
	IsAbilityTalent(client, TalentName, theQuery, 64, ABILITY_DOES_DAMAGE);

	if (StringToInt(theQuery) == 1) return true;
	return false;
}

stock bool VerifyActionBar(int client, char[] TalentName, pos) {
	//if (defaultTalentStrength == -1) defaultTalentStrength = GetTalentStrength(client, TalentName);
	if (StrEqual(TalentName, "none", false)) return false;
	if (!IsTalentExists(TalentName) || GetTalentStrength(client, TalentName) < 1) {
		char none[64];
		Format(none, sizeof(none), "none");
		ActionBar[client].SetString(pos, none);
		return false;
	}
	return true;
}

stock bool IsAbilityTalent(int client, char[] TalentName, char[] SearchKey = "none", int TheSize = 0, int pos = -1) {	// Can override the search query, and then said string will be replaced and sent back

	char text[64];

	int size = a_Database_Talents.Length;
	for (int i = 0; i < size; i++) {
		a_Database_Talents.GetString(i, text, sizeof(text));
		IsAbilitySection[client]		= a_Menu_Talents.Get(i, 2);
		IsAbilitySection[client].GetString(0, text, sizeof(text));
		if (!StrEqual(TalentName, text)) continue;
		//IsAbilityKeys[client]			= a_Menu_Talents.Get(i, 0);
		IsAbilityValues[client]			= a_Menu_Talents.Get(i, 1);

		if (pos == -1) {

			if (GetKeyValueIntAtPos(IsAbilityValues[client], IS_TALENT_ABILITY) == 1) return true;
		}
		else {

			IsAbilityValues[client].GetString(pos, SearchKey, TheSize);
			return true;
		}
		break;
	}
	return false;
}
// Delay can be set to a default value because it is only used for overloading.
stock void DrawAbilityEffect(int client, char[] sDrawEffect, float fDrawHeight, int fDrawDelay = 0.0, int fDrawSize, char[] sTalentName, int iEffectType = 0) {

	// no longer needed because we check for it before we get here.if (StrEqual(sDrawEffect, "-1")) return;							//size					color		pos		   pulse?  lifetime
	//CreateRingEx(client, fDrawSize, sDrawEffect, fDrawHeight, false, 0.2);
	if (iEffectType == 1 || iEffectType == 2) CreateRingEx(client, fDrawSize, sDrawEffect, fDrawHeight, false, 0.2);
	else {
		Handle drawpack;
		CreateDataTimer(fDrawDelay, Timer_DrawInstantEffect, drawpack, TIMER_FLAG_NO_MAPCHANGE);
		drawpack.WriteCell(client);
		drawpack.WriteString(sDrawEffect);
		drawpack.WriteFloat(fDrawHeight);
		drawpack.WriteFloat(fDrawSize);
	}
}

public Action Timer_DrawInstantEffect(Handle timer, Handle drawpack) {

	drawpack.Reset();
	int client				=	drawpack.ReadCell();
	if (IsLegitimateClient(client) && IsPlayerAlive(client)) {

		char DrawColour[64];
		drawpack.ReadString(DrawColour, sizeof(DrawColour));
		float fHeight = drawpack.ReadFloat();
		float fSize = drawpack.ReadFloat();

		CreateRingEx(client, fSize, DrawColour, fHeight, false, 0.2);
	}

	return Plugin_Stop;
}

stock bool IsActionAbilityCooldown(int client, char[] TalentName, bool IsActiveInstead = false) {

	float AmmoCooldownTime = GetAmmoCooldownTime(client, TalentName, true);
	float fAmmoCooldownTime = AmmoCooldownTime;
	float fAmmoCooldown = 0.0;

	// abilities dont show active time correctly (NOT FIXED)
	float fAmmoActive = GetAbilityValue(client, TalentName, ABILITY_ACTIVE_TIME);
	if (fAmmoCooldownTime != -1.0) {

		fAmmoCooldown = GetSpellCooldown(client, TalentName);
		AmmoCooldownTime = fAmmoActive - (fAmmoCooldown - fAmmoCooldownTime);//copy to source
	}
	if (!IsActiveInstead) {

		if (AmmoCooldownTime != -1.0) return true;
	}
	else {

		if (AmmoCooldownTime != -1.0 && AmmoCooldownTime > 0.0) return true;
	}
	
	return false;
}

stock float CheckActiveAbility(int client, int thevalue, int eventtype = 0, bool IsPassive = false, bool IsDrawEffect = false, bool IsInstantDraw = false) {

	// we try to match up the eventtype with any ACTIVE talents on the action bar.
	// it is REALLY super simple, we have functions for everything. everythingggggg
	// get the size of the action bars first.
	//LAMEO
	//if (IsSurvivorBot(client) && !IsDrawEffect) return 0.0;
	int ActionBarSize = iActionBarSlots;	// having your own extensive api really helps.
	if (ActionBar[client].Length != ActionBarSize) ActionBar[client].Resize(ActionBarSize);
	char text[64], Effects[64], none[64], sDrawEffect[PLATFORM_MAX_PATH], sDrawPos[PLATFORM_MAX_PATH], sDrawDelay[PLATFORM_MAX_PATH], sDrawSize[PLATFORM_MAX_PATH];// free guesses on what this one is for.
	Format(none, sizeof(none), "none");	// you guessed it.
	int pos = -1;
	bool IsMultiplier = false;
	float MyMultiplier = 1.0;
	//new MyAttacker = L4D2_GetInfectedAttacker(client);
	int size = ActionBar[client].Length;
	//new Float:fAbilityTime = 0.0;
	int drawpos = TALENT_FIRST_RANDOM_KEY_POSITION;
	int drawheight = TALENT_FIRST_RANDOM_KEY_POSITION;
	int drawdelay = TALENT_FIRST_RANDOM_KEY_POSITION;
	int drawsize = TALENT_FIRST_RANDOM_KEY_POSITION;

	int IsPassiveAbility = 0;
	int abPos = -1;
	float visualsCooldown = 0.0;
	PassiveEffectDisplay[client]++;
	if (PassiveEffectDisplay[client] >= size ||
		PassiveEffectDisplay[client] < 0) PassiveEffectDisplay[client] = 0;

	for (int i = 0; i < size; i++) {
		if (IsInstantDraw && thevalue != i) continue;
		ActionBar[client].GetString(i, text, sizeof(text));
		if (!VerifyActionBar(client, text, i)) continue;	// not a real talent or has no points in it.
		//if (StrEqual(text, "none", false) || GetTalentStrength(client, text) < 1) continue;
		if (!IsAbilityActive(client, text) && !IsDrawEffect) continue;	// inactive / passive / toggle abilities go through to the draw section.
		pos = GetMenuPosition(client, text);
		if (pos < 0) continue;
		CheckAbilityKeys[client]		= a_Menu_Talents.Get(pos, 0);
		CheckAbilityValues[client]		= a_Menu_Talents.Get(pos, 1);
		if (IsDrawEffect) {
			if (GetKeyValueIntAtPos(CheckAbilityValues[client], IS_TALENT_ABILITY) == 1) {
				IsPassiveAbility = GetKeyValueIntAtPos(CheckAbilityValues[client], ABILITY_PASSIVE_ONLY);
				if (IsInstantDraw) {
					while (drawpos >= 0 && drawheight >= 0 && drawdelay >= 0 && drawsize >= 0) {
						drawpos = FormatKeyValue(sDrawEffect, sizeof(sDrawEffect), CheckAbilityKeys[client], CheckAbilityValues[client], "instant draw?", _, _, drawpos, false);
						drawheight = FormatKeyValue(sDrawPos, sizeof(sDrawPos), CheckAbilityKeys[client], CheckAbilityValues[client], "instant draw pos?", _, _, drawheight, false);
						drawdelay = FormatKeyValue(sDrawDelay, sizeof(sDrawDelay), CheckAbilityKeys[client], CheckAbilityValues[client], "instant draw delay?", _, _, drawdelay, false);
						drawsize = FormatKeyValue(sDrawSize, sizeof(sDrawSize), CheckAbilityKeys[client], CheckAbilityValues[client], "instant draw size?", _, _, drawsize, false);
						if (drawpos == -1 || drawheight == -1 || drawdelay == -1 || drawsize == -1) break;
						DrawAbilityEffect(client, sDrawEffect, StringToFloat(sDrawPos), _, StringToFloat(sDrawSize), text);
						drawpos++;
						drawheight++;
						drawdelay++;
						drawsize++;
					}
				}
				else {
					abPos = GetAbilityDataPosition(client, pos);
					if (abPos == -1) continue;
					visualsCooldown = PlayActiveAbilities[client].Get(abPos, 3);
					visualsCooldown -= fSpecialAmmoInterval;
					if (visualsCooldown > 0.0) {
						PlayActiveAbilities[client].Set(abPos, visualsCooldown, 3);
						continue;	// do not draw if visuals are on cooldown
					}
					if (IsActionAbilityCooldown(client, text, true)) {// || !StrEqual(sPassiveEffects, "-1.0") && !IsActionAbilityCooldown(client, text)) {
						PlayActiveAbilities[client].Set(abPos, GetKeyValueFloatAtPos(CheckAbilityValues[client], ABILITY_ACTIVE_DRAW_DELAY), 3);
						while (drawpos >= 0 && drawheight >= 0 && drawsize >= 0) {
							drawpos = FormatKeyValue(sDrawEffect, sizeof(sDrawEffect), CheckAbilityKeys[client], CheckAbilityValues[client], "draw effect?", _, _, drawpos, false);
							drawheight = FormatKeyValue(sDrawPos, sizeof(sDrawPos), CheckAbilityKeys[client], CheckAbilityValues[client], "draw effect pos?", _, _, drawheight, false);
							drawsize = FormatKeyValue(sDrawSize, sizeof(sDrawSize), CheckAbilityKeys[client], CheckAbilityValues[client], "draw effect size?", _, _, drawsize, false);
							if (drawpos == -1 || drawheight == -1 || drawsize == -1) break;
							DrawAbilityEffect(client, sDrawEffect, StringToFloat(sDrawPos), _, StringToFloat(sDrawSize), text, 1);
							drawpos++;
							drawheight++;
							drawsize++;
						}
					}
					else if (PassiveEffectDisplay[client] == i && IsPassiveAbility == 1) {
						PlayActiveAbilities[client].Set(abPos, GetKeyValueFloatAtPos(CheckAbilityValues[client], ABILITY_PASSIVE_DRAW_DELAY), 3);
						while (drawpos >= 0 && drawheight >= 0 && drawsize >= 0) {
							drawpos = FormatKeyValue(sDrawEffect, sizeof(sDrawEffect), CheckAbilityKeys[client], CheckAbilityValues[client], "passive draw?", _, _, drawpos, false);
							drawheight = FormatKeyValue(sDrawPos, sizeof(sDrawPos), CheckAbilityKeys[client], CheckAbilityValues[client], "passive draw pos?", _, _, drawheight, false);
							drawsize = FormatKeyValue(sDrawSize, sizeof(sDrawSize), CheckAbilityKeys[client], CheckAbilityValues[client], "passive draw size?", _, _, drawsize, false);
							if (drawpos == -1 || drawheight == -1 || drawsize == -1) break;
							DrawAbilityEffect(client, sDrawEffect, StringToFloat(sDrawPos), _, StringToFloat(sDrawSize), text, 2);
							drawpos++;
							drawheight++;
							drawsize++;
						}
					}
				}
			}
			continue;
		}

		if (GetKeyValueIntAtPos(CheckAbilityValues[client], ABILITY_EVENT_TYPE) != eventtype) continue;
		
		if (!IsPassive) {

			CheckAbilityValues[client].GetString(ABILITY_ACTIVE_EFFECT, Effects, sizeof(Effects));

			if (StrContains(Effects, "X", true) != -1) {

				if (thevalue >= GetClientHealth(client)) {

					// attacks that would kill or incapacitate are completely nullified
					// this unfortunately also means that abilties that would be offensive or utility as a result of this attack do not fire.
					// we will later create a class that ignores this rule. Adventurer: "Years of hardened adventuring and ability use has led to the ability to both use AND bend mothers will"
					if (!IsMultiplier) return 0.0;
					MyMultiplier = 0.0;		// even if other active abilities fire, no incoming damage is coming through. Go you, adventurer.
				}
			}
		}
		else {

			CheckAbilityValues[client].GetString(ABILITY_PASSIVE_EFFECT, Effects, sizeof(Effects));

			if (StrContains(Effects, "S", true) != -1 && thevalue == 19) {

				return 1.0;
			}
		}
	}
	if (MyMultiplier <= 0.0) return 0.0;
	return (MyMultiplier * thevalue);
}

public ActionBarHandle(Handle menu, MenuAction action, client, slot) {

	if (action == MenuAction_Select) {

		CastActionEx(client, _, -1, slot);
	}
	else if (action == MenuAction_Cancel) {

		if (slot != MenuCancel_ExitBack) {
		}
	}
	if (action == MenuAction_End) {

		//DisplayActionBar[client] = false;
		delete menu;
	}
}

stock void BuildMenu(int client, char[] TheMenuName = "none") {

	if (b_IsLoading[client]) {

		PrintToChat(client, "%T", "loading data cannot open menu", client, orange);
		return;
	}

	char MenuName[64];
	if (StrEqual(TheMenuName, "none", false) && MenuStructure[client].Length > 0) {

		MenuStructure[client].GetString(MenuStructure[client].Length - 1, MenuName, sizeof(MenuName));
		MenuStructure[client].Erase(MenuStructure[client].Length - 1);
	}
	else Format(MenuName, sizeof(MenuName), "%s", TheMenuName);
	if (StrEqual(MenuName, "main")) ShowPlayerLayerInformation[client] = false;		// layer info is NEVER shown on the main menu.

	//PrintToChatAll("Menu name: %s", MenuName);


	// Format(LastOpenedMenu[client], sizeof(LastOpenedMenu[]), "%s", MenuName);
	//VerifyUpgradeExperienceCost(client);
	VerifyMaxPlayerUpgrades(client);
	RPGMenuPosition[client].Clear();

	// Build the base menu
	Handle menu		= new Menu(BuildMenuHandle);
	// Keep track of the position selected.
	char pos[64];

	if (!b_IsDirectorTalents[client]) BuildMenuTitle(client, menu, _, 0, _, ShowPlayerLayerInformation[client]);
	else BuildMenuTitle(client, menu, 1, _, _, ShowPlayerLayerInformation[client]);

	char text[PLATFORM_MAX_PATH];
	// declare the variables for requirements to display in menu.
	char teamsAllowed[64];
	char gamemodesAllowed[64];
	char flagsAllowed[64];
	char currentGamemode[4];
	char clientTeam[4];
	char configname[64];

	char t_MenuName[64];
	char c_MenuName[64];

	//PrintToChatAll("Menu named: %s", MenuName);


	char s_TalentDependency[64];
	// Collect player team and server gamemode.
	Format(currentGamemode, sizeof(currentGamemode), "%d", ReadyUp_GetGameMode());
	Format(clientTeam, sizeof(clientTeam), "%d", GetClientTeam(client));

	int size	= a_Menu_Main.Length;
	int CurRPGMode = iRPGMode;
	int XPRequired = CheckExperienceRequirement(client);
	//new ActionBarOption = -1;

	char pct[4];
	Format(pct, sizeof(pct), "%");

	int iIsReadMenuName = 0;
	int iHasLayers = 0;
	int strengthOfCurrentLayer = 0;

	char sCvarRequired[64];
	char sCatRepresentation[64];

	char translationInfo[64];

	char formattedText[64];
	float fPercentageHealthRequired;
	float fPercentageHealthRequiredMax;
	float fPercentageHealthRequiredBelow;
	float fCoherencyRange;
	int iCoherencyMax = 0;
	for (int i = 0; i < size; i++) {

		// Pull data from the parsed config.
		MenuKeys[client]		= a_Menu_Main.Get(i, 0);
		MenuValues[client]		= a_Menu_Main.Get(i, 1);
		MenuSection[client]		= a_Menu_Main.Get(i, 2);

		FormatKeyValue(t_MenuName, sizeof(t_MenuName), MenuKeys[client], MenuValues[client], "target menu?");
		FormatKeyValue(c_MenuName, sizeof(c_MenuName), MenuKeys[client], MenuValues[client], "menu name?");
		if (!StrEqual(MenuName, c_MenuName, false)) continue;

		//ActionBarOption = GetKeyValueInt(MenuKeys[client], MenuValues[client], "action bar option?");
		//if (ActionBarSlot[client] != -1 && ActionBarOption != 1) continue;
		
		// Reset data in display requirement variables to default values.
		Format(teamsAllowed, sizeof(teamsAllowed), "123");			// 1 (Spectator) 2 (Survivor) 3 (Infected) players allowed.
		Format(gamemodesAllowed, sizeof(gamemodesAllowed), "123");	// 1 (Coop) 2 (Versus) 3 (Survival) game mode variants allowed.
		Format(flagsAllowed, sizeof(flagsAllowed), "-1");			// -1 means no flag requirements specified.
		//TheDBPrefix
		// Collect the display requirement variables values.
		FormatKeyValue(teamsAllowed, sizeof(teamsAllowed), MenuKeys[client], MenuValues[client], "team?", teamsAllowed);
		FormatKeyValue(gamemodesAllowed, sizeof(gamemodesAllowed), MenuKeys[client], MenuValues[client], "gamemode?", gamemodesAllowed);
		FormatKeyValue(flagsAllowed, sizeof(flagsAllowed), MenuKeys[client], MenuValues[client], "flags?", flagsAllowed);
		FormatKeyValue(configname, sizeof(configname), MenuKeys[client], MenuValues[client], "config?");
		FormatKeyValue(s_TalentDependency, sizeof(s_TalentDependency), MenuKeys[client], MenuValues[client], "talent dependency?");
		FormatKeyValue(sCvarRequired, sizeof(sCvarRequired), MenuKeys[client], MenuValues[client], "cvar_required?");
		FormatKeyValue(translationInfo, sizeof(translationInfo), MenuKeys[client], MenuValues[client], "translation?");

		iIsReadMenuName = GetKeyValueInt(MenuKeys[client], MenuValues[client], "ignore header name?");
		iHasLayers = GetKeyValueInt(MenuKeys[client], MenuValues[client], "layers?");

		if (CurRPGMode < 0 && !StrEqual(configname, "leaderboards", false)) continue;

		// If a talent dependency is found AND the player has NO upgrades in said talent, the category is not displayed.
		if (StringToInt(s_TalentDependency) != -1 && !HasTalentUpgrades(client, s_TalentDependency)) continue;

		// If the player doesn't meet the requirements to have access to this menu option, we skip it.
		/*if (StrContains(teamsAllowed, clientTeam, false) == -1 || StrContains(gamemodesAllowed, currentGamemode, false) == -1 ||
			(!StrEqual(flagsAllowed, "-1", false) && !HasCommandAccess(client, flagsAllowed))) continue;*/

		if ((StrContains(teamsAllowed, clientTeam, false) == -1 && !b_IsDirectorTalents[client] || StrEqual(teamsAllowed, "2", false) && b_IsDirectorTalents[client]) ||
			!b_IsDirectorTalents[client] && (StrContains(gamemodesAllowed, currentGamemode, false) == -1 ||
			(!StrEqual(flagsAllowed, "-1", false) && !HasCommandAccess(client, flagsAllowed)))) continue;

		// Some menu options display only under specific circumstances, regardless of the new mainmenu.cfg structure.
		if (CurRPGMode == 0 && !StrEqual(configname, CONFIG_POINTS)) continue;
		if (CurRPGMode == 1 && StrEqual(configname, CONFIG_POINTS) && !b_IsDirectorTalents[client]) continue;
		if (a_Store.Length < 1 && StrEqual(configname, CONFIG_STORE)) continue;

		if (!StrEqual(sCvarRequired, "-1", false) && FindConVar(sCvarRequired) == INVALID_HANDLE) continue;
		if (StrEqual(configname, "level up") && PlayerLevel[client] == iMaxLevel) continue;
		if (StrEqual(configname, "autolevel toggle") && iAllowPauseLeveling != 1) continue;
		if (StrEqual(configname, "prestige") && (SkyLevel[client] >= iSkyLevelMax || PlayerLevel[client] < iMaxLevel)) continue;
		//if (StrEqual(configname, "respec", false) && bIsInCombat[client] && b_IsActiveRound) continue;

		// If director talent menu options is enabled by an admin, only specific options should show. We determine this here.
		if (b_IsDirectorTalents[client]) {
			if (StrEqual(configname, CONFIG_MENUTALENTS) ||
			StrEqual(configname, CONFIG_POINTS) ||
			b_IsDirectorTalents[client] && StrEqual(configname, "level up") ||
			PlayerLevel[client] >= iMaxLevel && StrEqual(configname, "prestige") ||
			StrEqual(MenuName, c_MenuName, false)) {
				Format(pos, sizeof(pos), "%d", i);
				RPGMenuPosition[client].PushString(pos);
			}
			else continue;
		}
		if (iIsReadMenuName == 1) {

			if (StrEqual(configname, "autolevel toggle")) {

				if (iIsLevelingPaused[client] == 1 && b_IsActiveRound) Format(text, sizeof(text), "%T", "auto level (locked)", client, fDeathPenalty * 100.0, pct);
				else if (iIsLevelingPaused[client] == 1) Format(text, sizeof(text), "%T", "auto level (disabled)", client, fDeathPenalty * 100.0, pct);
				else Format(text, sizeof(text), "%T", "auto level (enabled)", client, fDeathPenalty * 100.0, pct);
			}
			else if (StrEqual(configname, "trails toggle")) {

				if (iIsBulletTrails[client] == 0) Format(text, sizeof(text), "%T", "bullet trails (disabled)", client);
				else Format(text, sizeof(text), "%T", "bullet trails (enabled)", client);
			}
			else if (StrEqual(configname, "level up")) {

				//if (!b_IsDirectorTalents[client]) {

				//if (PlayerUpgradesTotal[client] < MaximumPlayerUpgrades(client)) continue; //Format(text, sizeof(text), "%T", "level up unavailable", client, MaximumPlayerUpgrades(client) - PlayerUpgradesTotal[client]);
				if (iIsLevelingPaused[client] == 1) {

					if (ExperienceLevel[client] >= XPRequired) {
						AddCommasToString(XPRequired, formattedText, sizeof(formattedText));
						Format(text, sizeof(text), "%T", "level up available", client, formattedText);
					}
					else {
						AddCommasToString(XPRequired - ExperienceLevel[client], formattedText, sizeof(formattedText));
						Format(text, sizeof(text), "%T", "level up unavailable", client, formattedText);
					}
				}
				else continue;
			}
			else if (StrEqual(configname, "prestige") && SkyLevel[client] < iSkyLevelMax && PlayerLevel[client] == iMaxLevel) {// we now require players to be max level to see the prestige information.
				Format(text, sizeof(text), "%T", "prestige up available", client, GetPrestigeLevelNodeUnlocks(SkyLevel[client]));
			}
			else if (StrEqual(configname, "layerup")) {
				if (PlayerCurrentMenuLayer[client] <= 1) continue;
				Format(text, sizeof(text), "%T", "layer move", client, PlayerCurrentMenuLayer[client] - 1);
			}
			else if (StrEqual(configname, "layerdown")) {
				if (PlayerCurrentMenuLayer[client] >= iMaxLayers) continue;
				strengthOfCurrentLayer = GetLayerUpgradeStrength(client, PlayerCurrentMenuLayer[client]);
				if (strengthOfCurrentLayer >= PlayerCurrentMenuLayer[client] + 1) Format(text, sizeof(text), "%T", "layer move", client, PlayerCurrentMenuLayer[client] + 1);
				else Format(text, sizeof(text), "%T", "layer move locked", client, PlayerCurrentMenuLayer[client] + 1, PlayerCurrentMenuLayer[client], PlayerCurrentMenuLayer[client] + 1 - strengthOfCurrentLayer);
			}
		}
		else {
			MenuSection[client].GetString(0, text, sizeof(text));
			//if (iHasLayers < 1) {
			Format(text, sizeof(text), "%T", text, client);
			/*}
			else {
				Format(text, sizeof(text), "%T", text, PlayerCurrentMenuLayer[client], client);
			}*/
		}
		FormatKeyValue(sCatRepresentation, sizeof(sCatRepresentation), MenuKeys[client], MenuValues[client], "talent tree category?");
		if (!StrEqual(sCatRepresentation, "-1")) {
			int iMaxCategoryStrength = 0;
			if (iHasLayers == 1) {
				Format(sCatRepresentation, sizeof(sCatRepresentation), "%s%d", sCatRepresentation, PlayerCurrentMenuLayer[client]);
				iMaxCategoryStrength = GetCategoryStrength(client, sCatRepresentation, true);
				if (iMaxCategoryStrength < 1) continue;
			}
			Format(sCatRepresentation, sizeof(sCatRepresentation), "%T", "tree strength display", client, GetCategoryStrength(client, sCatRepresentation), iMaxCategoryStrength);
			Format(text, sizeof(text), "%s\t%s", text, sCatRepresentation);
		}
		// important that this specific statement about hiding/displaying menus is last, due to potential conflicts with director menus.
		if (!b_IsDirectorTalents[client]) {

			char thevalue[64];
			GetConfigValue(thevalue, sizeof(thevalue), "chat settings flags?");

			if ((HasCommandAccess(client, thevalue) || GetConfigValueInt("all players chat settings?") == 1) || !StrEqual(configname, CONFIG_CHATSETTINGS)) {

				Format(pos, sizeof(pos), "%d", i);
				RPGMenuPosition[client].PushString(pos);
			}
			else continue;
		}
		if (!StrEqual(translationInfo, "-1")) {
			fPercentageHealthRequired = GetKeyValueFloatAtPos(MenuValues[client], HEALTH_PERCENTAGE_REQ_MISSING);
			fPercentageHealthRequiredBelow = GetKeyValueFloatAtPos(MenuValues[client], HEALTH_PERCENTAGE_REQ);
			fCoherencyRange = GetKeyValueFloatAtPos(MenuValues[client], COHERENCY_RANGE);
			iCoherencyMax = GetKeyValueIntAtPos(PurchaseValues[client], COHERENCY_MAX);
			if (fPercentageHealthRequired > 0.0 || fPercentageHealthRequiredBelow > 0.0 || fCoherencyRange > 0.0) {
				fPercentageHealthRequiredMax = GetKeyValueFloatAtPos(MenuValues[client], HEALTH_PERCENTAGE_REQ_MISSING_MAX);
				Format(translationInfo, sizeof(translationInfo), "%T", translationInfo, client, fPercentageHealthRequired * 100.0, pct, fPercentageHealthRequiredMax * 100.0, pct, fPercentageHealthRequiredBelow * 100.0, pct, fCoherencyRange, iCoherencyMax);
			}
			else Format(translationInfo, sizeof(translationInfo), "%T", translationInfo, client);
			Format(text, sizeof(text), "%s\n%s", text, translationInfo);
		}

		menu.AddItem(text, text);
	}
	if (!StrEqual(MenuName, "main", false)) menu.ExitBackButton = true;
	else menu.ExitBackButton = false;
	menu.Display(client, 0);
}

stock void GetProfileLoadoutConfig(int client, char[] TheString, int thesize) {

	char config[64];
	int size = a_Menu_Main.Length;

	for (int i = 0; i < size; i++) {

		LoadoutConfigKeys[client]		= a_Menu_Main.Get(i, 0);
		LoadoutConfigValues[client]		= a_Menu_Main.Get(i, 1);
		LoadoutConfigSection[client]	= a_Menu_Main.Get(i, 2);

		FormatKeyValue(config, sizeof(config), LoadoutConfigKeys[client], LoadoutConfigValues[client], "config?");
		if (!StrEqual(sProfileLoadoutConfig, config)) continue;

		LoadoutConfigSection[client].GetString(0, TheString, thesize);
		break;
	}
	return;
}

public int BuildMenuHandle(Handle menu, MenuAction action, int client, int slot) {

	if (action == MenuAction_Select)
	{
		// Declare variables for target config, menu name (some submenu's require this information) and the ACTUAL position for a slot
		// (as pos won't always line up with slot since items can be hidden under special circumstances.)
		char config[64];
		char menuname[64];
		char pos[4];

		char t_MenuName[64];
		char c_MenuName[64];

		char Name[64];

		char sCvarRequired[64];

		int XPRequired = CheckExperienceRequirement(client);
		int iIsIgnoreHeader = 0;
		int iHasLayers = 0;
		//new isSubMenu = 0;

		// Get the real position to use based on the slot that was pressed.
		// This position was stored above in the accompanying menu function.
		RPGMenuPosition[client].GetString(slot, pos, sizeof(pos));
		MenuKeys[client]			= a_Menu_Main.Get(StringToInt(pos), 0);
		MenuValues[client]			= a_Menu_Main.Get(StringToInt(pos), 1);
		MenuSection[client]			= a_Menu_Main.Get(StringToInt(pos), 2);
		MenuSection[client].GetString(0, menuname, sizeof(menuname));

		int showLayerInfo = GetKeyValueInt(MenuKeys[client], MenuValues[client], "show layer info?");

		// We want to know the value of the target config based on the keys and values pulled.
		// This will be used to determine where we send the player.
		FormatKeyValue(config, sizeof(config), MenuKeys[client], MenuValues[client], "config?");
		FormatKeyValue(t_MenuName, sizeof(t_MenuName), MenuKeys[client], MenuValues[client], "target menu?");
		FormatKeyValue(c_MenuName, sizeof(c_MenuName), MenuKeys[client], MenuValues[client], "menu name?");

		iIsIgnoreHeader = GetKeyValueInt(MenuKeys[client], MenuValues[client], "ignore header name?");
		iHasLayers = GetKeyValueInt(MenuKeys[client], MenuValues[client], "layers?");

		FormatKeyValue(sCvarRequired, sizeof(sCvarRequired), MenuKeys[client], MenuValues[client], "cvar_required?");
		//isSubMenu = GetKeyValueInt(MenuKeys[client], MenuValues[client], "is sub menu?");
		// we only modify the value if it's set, otherwise it's grandfathered.
		if (showLayerInfo == 1) ShowPlayerLayerInformation[client] = true;
		else if (showLayerInfo == 0) ShowPlayerLayerInformation[client] = false;
		
		AddMenuStructure(client, c_MenuName);
		if (!StrEqual(sCvarRequired, "-1", false) && FindConVar(sCvarRequired) != INVALID_HANDLE) {

			// Calls the fortspawn menu in another plugin.
			ReadyUp_NtvCallModule(sCvarRequired, t_MenuName, client);
		}
		// I've set it to not require case-sensitivity in case some moron decides to get cute.
		else if (!StrEqual(t_MenuName, "-1", false) && iIsIgnoreHeader <= 0) {
			if (StrEqual(t_MenuName, "editactionbar", false)) {
				bEquipSpells[client] = true;

				Format(MenuName_c[client], sizeof(MenuName_c[]), "%s", c_MenuName);
				BuildSubMenu(client, menuname, config, c_MenuName);
			}
			else BuildMenu(client, t_MenuName);
		}
		else if (StrEqual(config, "spawnloadout", false)) {

			SpawnLoadoutEditor(client);
		}
		else if (StrEqual(config, "composition", false)) {

			GetTeamComposition(client);
		}
		else if (StrEqual(config, "autolevel toggle", false)) {

			if (iIsLevelingPaused[client] == 1 && !b_IsActiveRound) iIsLevelingPaused[client] = 0;
			else if (iIsLevelingPaused[client] == 0) iIsLevelingPaused[client] = 1;
			BuildMenu(client);
		}
		else if (StrEqual(config, "trails toggle", false)) {

			if (iIsBulletTrails[client] == 1) iIsBulletTrails[client] = 0;
			else iIsBulletTrails[client] = 1;
			BuildMenu(client);
		}
		else if (StrEqual(config, "level up", false) && PlayerLevel[client] < iMaxLevel) {

			if (iIsLevelingPaused[client] == 1 && ExperienceLevel[client] >= XPRequired) ConfirmExperienceAction(client, _, true);
			BuildMenu(client);
		}
		else if (StrEqual(config, "layerup")) {
			if (PlayerCurrentMenuLayer[client] > 1) PlayerCurrentMenuLayer[client]--;
			BuildMenu(client);
		}
		else if (StrEqual(config, "layerdown")) {
			//if (PlayerCurrentMenuLayer[client] < iMaxLayers && GetLayerUpgradeStrength(client, PlayerCurrentMenuLayer[client]) >= PlayerCurrentMenuLayer[client] + 1) PlayerCurrentMenuLayer[client]++;
			if (PlayerCurrentMenuLayer[client] < iMaxLayers) PlayerCurrentMenuLayer[client]++;
			BuildMenu(client);
		}
		else if (StrEqual(config, "prestige", false)) {
			if (PlayerLevel[client] >= iMaxLevel && SkyLevel[client] < iSkyLevelMax) {
				PlayerLevel[client] = 1;
				SkyLevel[client]++;
				ExperienceLevel[client] = 0;
				GetClientName(client, Name, sizeof(Name));
				PrintToChatAll("%t", "player sky level up", green, white, blue, Name, SkyLevel[client]);
				ChallengeEverything(client);
				SaveAndClear(client);
			}
			BuildMenu(client);
		}
		else if (StrEqual(config, "profileeditor", false)) {

			ProfileEditorMenu(client);
		}
		else if (StrEqual(config, "charactersheet", false)) {
			playerPageOfCharacterSheet[client] = 0;
			CharacterSheetMenu(client);
		}
		else if (StrEqual(config, "readallprofiles", false)) {

			ReadProfiles(client, "all");
		}
		else if (StrEqual(config, "leaderboards", false)) {

			bIsMyRanking[client] = true;
			TheLeaderboardsPage[client] = 0;
			LoadLeaderboards(client, 0);
		} 
		else if (StrEqual(config, "respec", false)) {

			ChallengeEverything(client);
			BuildMenu(client);
		}
		else if (StrEqual(config, "threatmeter", false)) {

			//ShowThreatMenu(client);
			bIsHideThreat[client] = false;
		}
		else if (a_Store.Length > 0 && StrEqual(config, CONFIG_STORE)) {

			BuildStoreMenu(client);
		}
		else if (StrEqual(config, CONFIG_CHATSETTINGS)) {

			Format(ChatSettingsName[client], sizeof(ChatSettingsName[]), "none");
			BuildChatSettingsMenu(client);
		}
		else if (StrEqual(config, CONFIG_MENUTALENTS)) {

			// In previous versions of RPG, players could see, but couldn't open specific menus if the director talents were active.
			// In this version, if director talents are active, you just can't see a talent with "activator class required?" that is strictly 0.
			// However, values that are, say, "01" will show, as at least 1 infected class can use the talent.
			Format(MenuName_c[client], sizeof(MenuName_c[]), "%s", c_MenuName);
			
			if (iHasLayers == 1) {
				FormatKeyValue(menuname, sizeof(menuname), MenuKeys[client], MenuValues[client], "talent tree category?");
				Format(menuname, sizeof(menuname), "%s%d", menuname, PlayerCurrentMenuLayer[client]);
			}
			if (!StrEqual(t_MenuName, "-1", false)) BuildSubMenu(client, menuname, config, t_MenuName);
			else BuildSubMenu(client, menuname, config, c_MenuName);
			//PrintToChat(client, "buidling a sub menu. %s", t_MenuName);
		}
		else if (StrEqual(config, CONFIG_POINTS)) {

			// A much safer method for grabbing the current config value for the MenuSelection.
			iIsWeaponLoadout[client] = 0;
			Format(MenuSelection[client], sizeof(MenuSelection[]), "%s", config);
			BuildPointsMenu(client, menuname, config);
		}
		else if (StrEqual(config, "inventory", false)) {

			LoadInventory(client);
		}
		else if (StrEqual(config, "proficiency", false)) {
			LoadProficiencyData(client);
		}
		/*else {

			BuildMenu(client);
		}*/
	}
	else if (action == MenuAction_Cancel) {

		if (slot == MenuCancel_ExitBack) {

			BuildMenu(client);
		}
	}
	if (action == MenuAction_End) {

		delete menu;
	}
}

stock int GetNodesInExistence() {
	if (nodesInExistence > 0) return nodesInExistence;
	int size			=	a_Menu_Talents.Length;
	nodesInExistence	=	0;
	int nodeLayer		=	0;	// this will hide nodes not currently available from players total node count.
	for (int i = 0; i < size; i++) {
		//SetNodesKeys			=	a_Menu_Talents.Get(i, 0);
		SetNodesValues			=	a_Menu_Talents.Get(i, 1);
		if (GetKeyValueIntAtPos(SetNodesValues, IS_SUB_MENU_OF_TALENTCONFIG) == 1) continue;
		nodeLayer = GetKeyValueIntAtPos(SetNodesValues, GET_TALENT_LAYER);
		if (nodeLayer >= 1 && nodeLayer <= iMaxLayers) nodesInExistence++;
	}
	if (StrContains(Hostname, "{N}", true) != -1) {
		char nodetext[10];
		Format(nodetext, sizeof(nodetext), "%d", nodesInExistence);
		ReplaceString(Hostname, sizeof(Hostname), "{N}", nodetext);
		ServerCommand("hostname %s", Hostname);
	}
	return nodesInExistence;
}

stock int PlayerTalentLevel(int client) {

	int PTL = RoundToFloor((((PlayerUpgradesTotal[client] * 1.0) + FreeUpgrades[client]) / PlayerLevel[client]) * PlayerLevel[client]);
	if (PTL < 0) PTL = 0;

	return PTL;
	//return PlayerLevel[client];
}

stock float PlayerBuffLevel(int client) {

	float PBL = ((PlayerUpgradesTotal[client] * 1.0) + FreeUpgrades[client]) / PlayerLevel[client];
	PBL = 1.0 - PBL;
	//PBL = PBL * 100.0;
	if (PBL < 0.0) PBL = 0.0; // This can happen if a player uses free upgrades, so, yeah...
	return PBL;
}

stock int MaximumPlayerUpgrades(int client, bool getNodeCountInstead = false) {

	if (!getNodeCountInstead) {
		if (SkyLevel[client] < 1) return PlayerLevel[client];
		int count = 0;
		for (int i = 1; i < SkyLevel[client] + 1; i++) {
			count += GetPrestigeLevelNodeUnlocks(i);
		}
		return count + PlayerLevel[client];
	}
	return nodesInExistence;
}

stock void VerifyMaxPlayerUpgrades(int client) {

	if (PlayerUpgradesTotal[client] + FreeUpgrades[client] > MaximumPlayerUpgrades(client)) {
		//PrintToChat(client, "resetting talents: %d of %d (%d)", PlayerUpgradesTotal[client], FreeUpgrades[client], MaximumPlayerUpgrades(client));
		FreeUpgrades[client]								=	MaximumPlayerUpgrades(client);
		UpgradesAvailable[client]							=	0;
		PlayerUpgradesTotal[client]							=	0;
		WipeTalentPoints(client);
	}
}

stock void UpgradesUsed(int client, char[] text, int size) {
	Format(text, size, "%T", "Upgrades Used", client);
	Format(text, size, "(%s: %d / %d)", text, PlayerUpgradesTotal[client], MaximumPlayerUpgrades(client));
}

stock void LoadInventory(int client) {

	if (hDatabase == INVALID_HANDLE) return;
	char key[64];
	GetClientAuthId(client, AuthId_Steam2, key, sizeof(key));
	Format(key, sizeof(key), "%s%s", key, LOOT_VERSION);
	char tquery[128];
	Format(tquery, sizeof(tquery), "SELECT `owner_id` FROM `%s_loot` WHERE (`owner_id` = '%s');", TheDBPrefix, key);
	PlayerInventory[client].Clear();
	hDatabase.Query(LoadInventory_Generate, tquery, client);
}

stock LoadProficiencyData(int client) {
	Handle menu = new Menu(LoadProficiencyMenuHandle);
	RPGMenuPosition[client].Clear();

	char text[64];
	int CurLevel = 0;
	int CurExp = 0;
	int CurGoal = 0;
	char theExperienceBar[64];

	char currAmount[64];
	char currTarget[64];
	for (int i = 0; i <= 7; i++) {
		CurLevel = GetProficiencyData(client, i);
		CurExp = GetProficiencyData(client, i, _, 1);
		CurGoal = GetProficiencyData(client, i, _, 2);
		//new Float:CurPerc = (CurExp * 1.0) / (CurGoal * 1.0);
		if (i == 0) Format(text, sizeof(text), "%T", "pistol proficiency", client);
		else if (i == 1) Format(text, sizeof(text), "%T", "melee proficiency", client);
		else if (i == 2) Format(text, sizeof(text), "%T", "uzi proficiency", client);
		else if (i == 3) Format(text, sizeof(text), "%T", "shotgun proficiency", client);
		else if (i == 4) Format(text, sizeof(text), "%T", "sniper proficiency", client);
		else if (i == 5) Format(text, sizeof(text), "%T", "assault proficiency", client);
		else if (i == 6) Format(text, sizeof(text), "%T", "medic proficiency", client);
		else if (i == 7) Format(text, sizeof(text), "%T", "grenade proficiency", client);
		
		MenuExperienceBar(client, CurExp, CurGoal, theExperienceBar, sizeof(theExperienceBar));

		AddCommasToString(CurExp, currAmount, sizeof(currAmount));
		AddCommasToString(CurGoal, currTarget, sizeof(currTarget));
		Format(text, sizeof(text), "%s Lv.%d %s %s %sXP", text, CurLevel, currAmount, theExperienceBar, currTarget);
		menu.AddItem(text, text, ITEMDRAW_DISABLED);
	}
	menu.ExitBackButton = true;
	menu.Display(client, 0);
}

public LoadProficiencyMenuHandle(Handle menu, MenuAction action, client, slot) {

	if (action == MenuAction_Select) { }
	else if (action == MenuAction_Cancel) {
		if (slot == MenuCancel_ExitBack) BuildMenu(client);
	}
	if (action == MenuAction_End) delete menu;
}

stock LoadInventoryEx(int client) {

	Handle menu = new Menu(LoadInventoryMenuHandle);
	RPGMenuPosition[client].Clear();

	char text[64];
	char pos[10];
	char result[3][64];

	Format(text, sizeof(text), "%T", "Inventory", client);
	menu.SetTitle(text);

	int size = PlayerInventory[client].Length;
	if (size < 1) {

		Format(text, sizeof(text), "%T", "inventory empty", client);
		menu.AddItem(text, text);
	}
	else {

		for (int i = 0; i < size; i++) {

			PlayerInventory[client].GetString(i, text, sizeof(text));
			ExplodeString(text, "+", result, 3, 64);
			menu.AddItem(result[1], result[1]);

			Format(pos, sizeof(pos), "%d", i);
			RPGMenuPosition[client].PushString(pos);
		}
	}
	menu.ExitBackButton = true;
	menu.Display(client, 0);
}

public LoadInventoryMenuHandle(Handle menu, MenuAction action, client, slot) {

	if (action == MenuAction_Select) {

	}
	else if (action == MenuAction_Cancel) {

		if (slot == MenuCancel_ExitBack) {

			BuildMenu(client);
		}
	}
	if (action == MenuAction_End) {

		delete menu;
	}
}

public Handle DisplayTheLeaderboards(int client) {

	Handle menu = new Panel();

	char tquery[64];
	char text[512];

	char textFormatted[64];

	if (TheLeaderboardsPageSize[client] > 0) {

		Format(text, sizeof(text), "Name\t\t\t\t\t\t\tScore");
		menu.DrawText(text);

		for (int i = 0; i < TheLeaderboardsPageSize[client]; i++) {

			TheLeaderboardsData[client]		= TheLeaderboards[client].Get(0, 0);
			TheLeaderboardsData[client].GetString(i, tquery, sizeof(tquery));
			Format(text, sizeof(text), "%s", tquery);

			TheLeaderboardsData[client]		= TheLeaderboards[client].Get(0, 1);
			TheLeaderboardsData[client].GetString(i, tquery, sizeof(tquery));

			AddCommasToString(StringToInt(tquery), textFormatted, sizeof(textFormatted));
			Format(text, sizeof(text), "%s: \t%s", text, textFormatted);

			menu.DrawText(text);

			if (bIsMyRanking[client]) break;
		}
	}
	Format(text, sizeof(text), "%T", "Leaderboards Top Page", client);
	menu.DrawItem(text);
	if (TheLeaderboardsPageSize[client] >= GetConfigValueInt("leaderboard players per page?")) {

		Format(text, sizeof(text), "%T", "Leaderboards Next Page", client);
		menu.DrawItem(text);
	}
	Format(text, sizeof(text), "%T", "View My Ranking", client);
	menu.DrawItem(text);
	Format(text, sizeof(text), "%T", "return to talent menu", client);
	menu.DrawItem(text);

	return menu;
}

public DisplayTheLeaderboards_Init (Handle topmenu, MenuAction action, client, param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				bIsMyRanking[client] = false;
				LoadLeaderboards(client, 0);
			}
			case 2:
			{
				if (TheLeaderboardsPageSize[client] >= GetConfigValueInt("leaderboard players per page?")) {

					bIsMyRanking[client] = false;
					LoadLeaderboards(client, 1);
				}
				else {

					bIsMyRanking[client] = true;
					LoadLeaderboards(client, 0);
				}
			}
			case 3:
			{
				if (TheLeaderboardsPageSize[client] >= GetConfigValueInt("leaderboard players per page?")) {

					bIsMyRanking[client] = true;
					LoadLeaderboards(client, 0);
				}
				else {

					TheLeaderboards[client].Clear();
					TheLeaderboardsPage[client] = 0;
					BuildMenu(client);
				}
			}
			case 4:
			{
				if (TheLeaderboardsPageSize[client] >= GetConfigValueInt("leaderboard players per page?")) {

					TheLeaderboards[client].Clear();
					TheLeaderboardsPage[client] = 0;
					BuildMenu(client);
				}
			}
		}
	}
	if (topmenu != INVALID_HANDLE)
	{
		delete topmenu;
	}
}

public Handle SpawnLoadoutEditor(int client) {

	Handle menu		= new Menu(SpawnLoadoutEditorHandle);

	char text[512];
	Format(text, sizeof(text), "%T", "profile editor title", client, LoadoutName[client]);
	menu.SetTitle(text);

	hWeaponList[client].GetString(0, text, sizeof(text));
	if (!QuickCommandAccessEx(client, text, _, _, true)) Format(text, sizeof(text), "%T", "No Weapon Equipped", client);
	else Format(text, sizeof(text), "%T", text, client);
	Format(text, sizeof(text), "%T", "Primary Weapon", client, text);
	menu.AddItem(text, text);

	hWeaponList[client].GetString(1, text, sizeof(text));
	if (!QuickCommandAccessEx(client, text, _, _, true)) Format(text, sizeof(text), "%T", "No Weapon Equipped", client);
	else Format(text, sizeof(text), "%T", text, client);
	Format(text, sizeof(text), "%T", "Secondary Weapon", client, text);
	menu.AddItem(text, text);

	menu.ExitBackButton = true;
	menu.Display(client, 0);
}

public SpawnLoadoutEditorHandle(Handle menu, MenuAction action, client, slot) {

	if (action == MenuAction_Select) {

		char menuname[64];
		GetProfileLoadoutConfig(client, menuname, sizeof(menuname));

		Format(MenuSelection[client], sizeof(MenuSelection[]), "%s", sProfileLoadoutConfig);

		iIsWeaponLoadout[client] = slot + 1;	// 1 - 1 = 0 Primary, 2 - 1 = 1 Secondary
		BuildPointsMenu(client, menuname, "rpg/points.cfg");
	}
	else if (action == MenuAction_Cancel) {

		if (slot == MenuCancel_ExitBack) {

			iIsWeaponLoadout[client] = 0;
			BuildMenu(client, "main");
		}
	}
	if (action == MenuAction_End) {

		delete menu;
	}
}

stock GetTotalThreat() {

	int iThreatAmount = 0;
	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClientAlive(i) && GetClientTeam(i) == TEAM_SURVIVOR) {

			iThreatAmount += iThreatLevel[i];
		}
	}
	return iThreatAmount;
}

/*stock GetThreatPos(int client) {

	decl String:text[64];
	decl String:iThreatInfo[2][64];

	new size = Handle:hThreatMeter.Length;
	if (size > 0) {

		for (new i = 0; i < size; i++) {

			Handle:hThreatMeter.GetString(i, text, sizeof(text));
			ExplodeString(text, "+", iThreatInfo, 2, 64);
			//client+threat
			
			if (client == StringToInt(iThreatInfo[0])) return i;
		}
	}
	return -1;
}*/

public Handle ShowThreatMenu(int client) {

	Handle menu = new Panel();

	char text[512];
	//Handle:hThreatMeter.GetString(0, text, sizeof(text));
	int iTotalThreat = GetTotalThreat();
	int iThreatTarget = -1;
	float iThreatPercent = 0.0;

	char tBar[64];
	int iBar = 0;

	char tClient[64];

	char threatLevelText[64];

	Format(text, sizeof(text), "%T", "threat meter title", client);
	//new pos = GetThreatPos(client);
	if (iThreatLevel[client] > 0) {

		//Handle:hThreatMeter.GetString(pos, text, sizeof(text));
		//ExplodeString(text, "+", iThreatInfo, 2, 64);
		//iThreatTarget = StringToInt(text[FindDelim(text, "+")]);
		//if (iThreatTarget > 0) {

		iThreatPercent = ((1.0 * iThreatLevel[client]) / (1.0 * iTotalThreat));
		iBar = RoundToFloor(iThreatPercent / 0.05);
		if (iBar > 0) {

			for (int ii = 0; ii < iBar; ii++) {

				if (ii == 0) Format(tBar, sizeof(tBar), "~");
				else Format(tBar, sizeof(tBar), "%s~", tBar);
			}
			Format(tBar, sizeof(tBar), "%s>", tBar);
		}
		else Format(tBar, sizeof(tBar), ">");
		GetClientName(client, tClient, sizeof(tClient));
		AddCommasToString(iThreatLevel[client], threatLevelText, sizeof(threatLevelText));
		Format(tBar, sizeof(tBar), "%s%s %s", tBar, threatLevelText, tClient);
		Format(text, sizeof(text), "%s\nYou:\n%s\n\t\nTeam:", text, tBar);
		//}
	}
	menu.SetTitle(text);

	int size = hThreatMeter.Length;
	int iClient = 0;
	if (size > 0) {

		for (int i = 0; i < size; i++) {
		
			//Handle:hThreatMeter.GetString(i, text, sizeof(text));
			//ExplodeString(text, "+", iThreatInfo, 2, 64);
			//client+threat
			iClient = hThreatMeter.Get(i, 0);
			//iClient = StringToInt(iThreatInfo[0]);
			if (client == iClient) continue;			// the menu owner data is shown in the title so not here.
			GetClientName(iClient, text, sizeof(text));
			iThreatTarget = hThreatMeter.Get(i, 1);
			//iThreatTarget = StringToInt(iThreatInfo[1]);

			if (!IsLegitimateClientAlive(iClient) || iThreatTarget < 1) continue;	// we don't show players who have no threat on the table.

			iThreatPercent = ((1.0 * iThreatTarget) / (1.0 * iTotalThreat));
			iBar = RoundToFloor(iThreatPercent / 0.05);
			if (iBar > 0) {

				for (int ii = 0; ii < iBar; ii++) {

					if (ii == 0) Format(tBar, sizeof(tBar), "~");
					else Format(tBar, sizeof(tBar), "%s~", tBar);
				}
				Format(tBar, sizeof(tBar), "%s>", tBar);
			}
			else Format(tBar, sizeof(tBar), ">");
			AddCommasToString(iThreatTarget, threatLevelText, sizeof(threatLevelText));
			Format(tBar, sizeof(tBar), "%s%s %s", tBar, threatLevelText, text);
			menu.DrawText(tBar);
		}
	}
	Format(text, sizeof(text), "%T", "return to talent menu", client);
	menu.DrawItem(text);
	return menu;
}

public ShowThreatMenu_Init(Handle topmenu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				//bIsMyRanking[client] = false;
				//LoadLeaderboards(client, 0);
				bIsHideThreat[client] = true;
				BuildMenu(client);
			}
		}
	}
	/*if (action == MenuAction_Cancel) {

		//if (action == MenuCancel_ExitBack) {

		bIsHideThreat[client] = true;
		BuildMenu(client);
		//}
	}
	if (action == MenuAction_End) {

		bIsHideThreat[client] = true;
		delete topmenu;
	}
	if (topmenu != INVALID_HANDLE)
	{
		//bIsHideThreat[client] = true;
		delete topmenu;
	}*/
}

public CharacterSheetMenuHandle(Handle menu, MenuAction action, client, slot) {

	if (action == MenuAction_Select) {
		if (slot == 0) {
			playerPageOfCharacterSheet[client] = (playerPageOfCharacterSheet[client] == 0) ? 1 : 0;
			CharacterSheetMenu(client);
		}
	}
	if (action == MenuAction_Cancel) {

		if (slot == MenuCancel_ExitBack) {

			BuildMenu(client);
		}
	}
	if (action == MenuAction_End) {

		delete menu;
	}
}

public Handle CharacterSheetMenu(int client) {
	Handle menu		= new Menu(CharacterSheetMenuHandle);

	char text[512];
	// we create a string called data to use as reference in GetCharacterSheetData()
	// as opposed to using a String method that has to create a new string each time.
	char data[64];
	// parse the menu according to how the server operator has designed it.
	
	if (playerPageOfCharacterSheet[client] == 0) {
		Format(text, sizeof(text), "%T", "Infected Sheet Info", client);

		if (StrContains(text, "{CH}", true) != -1) {
			GetCharacterSheetData(client, data, sizeof(data), 1);
			ReplaceString(text, sizeof(text), "{CH}", data);
		}
		if (StrContains(text, "{CD}", true) != -1) {
			GetCharacterSheetData(client, data, sizeof(data), 2);
			ReplaceString(text, sizeof(text), "{CD}", data);
		}
		if (StrContains(text, "{WH}", true) != -1) {
			GetCharacterSheetData(client, data, sizeof(data), 3);
			ReplaceString(text, sizeof(text), "{WH}", data);
		}
		if (StrContains(text, "{WD}", true) != -1) {
			GetCharacterSheetData(client, data, sizeof(data), 4);
			ReplaceString(text, sizeof(text), "{WD}", data);
		}
		if (StrContains(text, "{HUNTERHP}", true) != -1) {
			GetCharacterSheetData(client, data, sizeof(data), 5, ZOMBIECLASS_HUNTER);
			ReplaceString(text, sizeof(text), "{HUNTERHP}", data);
		}
		if (StrContains(text, "{SMOKERHP}", true) != -1) {
			GetCharacterSheetData(client, data, sizeof(data), 5, ZOMBIECLASS_SMOKER);
			ReplaceString(text, sizeof(text), "{SMOKERHP}", data);
		}
		if (StrContains(text, "{BOOMERHP}", true) != -1) {
			GetCharacterSheetData(client, data, sizeof(data), 5, ZOMBIECLASS_BOOMER);
			ReplaceString(text, sizeof(text), "{BOOMERHP}", data);
		}
		if (StrContains(text, "{SPITTERHP}", true) != -1) {
			GetCharacterSheetData(client, data, sizeof(data), 5, ZOMBIECLASS_SPITTER);
			ReplaceString(text, sizeof(text), "{SPITTERHP}", data);
		}
		if (StrContains(text, "{JOCKEYHP}", true) != -1) {
			GetCharacterSheetData(client, data, sizeof(data), 5, ZOMBIECLASS_JOCKEY);
			ReplaceString(text, sizeof(text), "{JOCKEYHP}", data);
		}
		if (StrContains(text, "{CHARGERHP}", true) != -1) {
			GetCharacterSheetData(client, data, sizeof(data), 5, ZOMBIECLASS_CHARGER);
			ReplaceString(text, sizeof(text), "{CHARGERHP}", data);
		}
		if (StrContains(text, "{TANKHP}", true) != -1) {
			GetCharacterSheetData(client, data, sizeof(data), 5, ZOMBIECLASS_TANK);
			ReplaceString(text, sizeof(text), "{TANKHP}", data);
		}
		if (StrContains(text, "{HUNTERDMG}", true) != -1) {
			GetCharacterSheetData(client, data, sizeof(data), 6, ZOMBIECLASS_HUNTER);
			ReplaceString(text, sizeof(text), "{HUNTERDMG}", data);
		}
		if (StrContains(text, "{SMOKERDMG}", true) != -1) {
			GetCharacterSheetData(client, data, sizeof(data), 6, ZOMBIECLASS_SMOKER);
			ReplaceString(text, sizeof(text), "{SMOKERDMG}", data);
		}
		if (StrContains(text, "{BOOMERDMG}", true) != -1) {
			GetCharacterSheetData(client, data, sizeof(data), 6, ZOMBIECLASS_BOOMER);
			ReplaceString(text, sizeof(text), "{BOOMERDMG}", data);
		}
		if (StrContains(text, "{SPITTERDMG}", true) != -1) {
			GetCharacterSheetData(client, data, sizeof(data), 6, ZOMBIECLASS_SPITTER);
			ReplaceString(text, sizeof(text), "{SPITTERDMG}", data);
		}
		if (StrContains(text, "{JOCKEYDMG}", true) != -1) {
			GetCharacterSheetData(client, data, sizeof(data), 6, ZOMBIECLASS_JOCKEY);
			ReplaceString(text, sizeof(text), "{JOCKEYDMG}", data);
		}
		if (StrContains(text, "{CHARGERDMG}", true) != -1) {
			GetCharacterSheetData(client, data, sizeof(data), 6, ZOMBIECLASS_CHARGER);
			ReplaceString(text, sizeof(text), "{CHARGERDMG}", data);
		}
		if (StrContains(text, "{TANKDMG}", true) != -1) {
			GetCharacterSheetData(client, data, sizeof(data), 6, ZOMBIECLASS_TANK);
			ReplaceString(text, sizeof(text), "{TANKDMG}", data);
		}
	}
	else { // Survivor Sheet!
		char targetName[64];
		//new typeOfAimTarget = DataScreenTargetName(client, targetName, sizeof(targetName));
		char weaponDamage[64];
		char otherText[64];
		AddCommasToString(DataScreenWeaponDamage(client), weaponDamage, sizeof(weaponDamage));
		Format(weaponDamage, sizeof(weaponDamage), "%s", weaponDamage);

		Format(text, sizeof(text), "%T", "Survivor Sheet Info", client);
		if (StrContains(text, "{PLAYTIME}", true) != -1) {
			GetTimePlayed(client, otherText, sizeof(otherText));
			ReplaceString(text, sizeof(text), "{PLAYTIME}", otherText);
		}
		if (StrContains(text, "{AIMTARGET}", true) != -1) {
			ReplaceString(text, sizeof(text), "{AIMTARGET}", targetName);
		}
		if (StrContains(text, "{WDMG}", true) != -1) {
			ReplaceString(text, sizeof(text), "{WDMG}", weaponDamage);
		}
		if (StrContains(text, "{MYSTAM}", true) != -1) {
			Format(weaponDamage, sizeof(weaponDamage), "%d", GetPlayerStamina(client));
			ReplaceString(text, sizeof(text), "{MYSTAM}", weaponDamage);
		}
		if (StrContains(text, "{MYHP}", true) != -1) {
			SetMaximumHealth(client);
			Format(weaponDamage, sizeof(weaponDamage), "%d", GetMaximumHealth(client));
			ReplaceString(text, sizeof(text), "{MYHP}", weaponDamage);
		}
		if (StrContains(text, "{CON}", true) != -1) {
			Format(weaponDamage, sizeof(weaponDamage), "%d", GetTalentStrength(client, "constitution", _, _, true));
			ReplaceString(text, sizeof(text), "{CON}", weaponDamage);
		}
		if (StrContains(text, "{AGI}", true) != -1) {
			Format(weaponDamage, sizeof(weaponDamage), "%d", GetTalentStrength(client, "agility", _, _, true));
			ReplaceString(text, sizeof(text), "{AGI}", weaponDamage);
		}
		if (StrContains(text, "{RES}", true) != -1) {
			Format(weaponDamage, sizeof(weaponDamage), "%d", GetTalentStrength(client, "resilience", _, _, true));
			ReplaceString(text, sizeof(text), "{RES}", weaponDamage);
		}
		if (StrContains(text, "{TEC}", true) != -1) {
			Format(weaponDamage, sizeof(weaponDamage), "%d", GetTalentStrength(client, "technique", _, _, true));
			ReplaceString(text, sizeof(text), "{TEC}", weaponDamage);
		}
		if (StrContains(text, "{END}", true) != -1) {
			Format(weaponDamage, sizeof(weaponDamage), "%d", GetTalentStrength(client, "endurance", _, _, true));
			ReplaceString(text, sizeof(text), "{END}", weaponDamage);
		}
		if (StrContains(text, "{LUC}", true) != -1) {
			Format(weaponDamage, sizeof(weaponDamage), "%d", GetTalentStrength(client, "luck", _, _, true));
			ReplaceString(text, sizeof(text), "{LUC}", weaponDamage);
		}
	}

	menu.SetTitle(text);
	if (playerPageOfCharacterSheet[client] == 0) Format(text, sizeof(text), "%T", "Character Sheet (Survivor Page)", client);
	else Format(text, sizeof(text), "%T", "Character Sheet (Infected Page)", client);
	menu.AddItem(text, text);

	menu.ExitBackButton = true;
	menu.Display(client, 0);
}

stock bool IsWeaponPermittedFound(int client, char[] WeaponsPermitted, char[] PlayerWeapon) {
	bool IsFound = false;
	if (StrContains(WeaponsPermitted, "{ALLSMG}", true) != -1 && StrContains(PlayerWeapon, "smg", false) != -1 ||
		StrContains(WeaponsPermitted, "{ALLSHOTGUN}", true) != -1 && StrContains(PlayerWeapon, "shotgun", false) != -1 ||
		StrContains(WeaponsPermitted, "{PUMP}", true) != -1 && (StrContains(PlayerWeapon, "pump", false) != -1 || StrContains(PlayerWeapon, "chrome", false) != -1) ||
		StrContains(WeaponsPermitted, "{ALLRIFLE}", true) != -1 && StrContains(PlayerWeapon, "rifle", false) != -1 && StrContains(PlayerWeapon, "hunting", false) == -1 ||
		StrContains(WeaponsPermitted, "{M60}", true) != -1 && StrContains(PlayerWeapon, "m60", false) != -1 ||
		StrContains(WeaponsPermitted, "{ALLSNIPER}", true) != -1 && StrContains(PlayerWeapon, "sniper", false) != -1 ||
		StrContains(WeaponsPermitted, "{ALLPISTOL}", true) != -1 && StrContains(PlayerWeapon, "pistol", false) != -1 ||
		StrContains(WeaponsPermitted, "{MAGNUM}", true) != -1 && StrContains(PlayerWeapon, "magnum", false) != -1 ||
		StrContains(WeaponsPermitted, "{50CAL}", true) != -1 && (StrContains(PlayerWeapon, "magnum", false) != -1 || StrContains(PlayerWeapon, "awp", false) != -1) ||
		StrContains(WeaponsPermitted, "{SR}", true) != -1 && (StrContains(PlayerWeapon, "awp", false) != -1 || StrContains(PlayerWeapon, "scout", false) != -1) ||
		StrContains(WeaponsPermitted, "{DMR}", true) != -1 && (StrContains(PlayerWeapon, "hunting", false) != -1 || StrContains(PlayerWeapon, "military", false) != -1) ||
		StrContains(WeaponsPermitted, "{PISTOL}", true) != -1 && (StrContains(PlayerWeapon, "pistol", false) != -1 && StrContains(PlayerWeapon, "magnum", false) == -1) ||
		StrContains(WeaponsPermitted, "{GUNS}", true) != -1 && !IsMeleeAttacker(client) ||
		StrContains(WeaponsPermitted, "{MELEE}", true) != -1 && IsMeleeAttacker(client) ||
		StrContains(WeaponsPermitted, "{TIER1}", true) != -1 &&
			(StrContains(PlayerWeapon, "smg", false) != -1 || StrContains(PlayerWeapon, "chrome", false) != -1 ||
			StrContains(PlayerWeapon, "pump", false) != -1 ||
			(StrContains(PlayerWeapon, "pistol", false) != -1 && StrContains(PlayerWeapon, "magnum", false) == -1)) ||
		StrContains(WeaponsPermitted, "{TIER2}", true) != -1 &&
			(StrContains(PlayerWeapon, "spas", false) != -1 || StrContains(PlayerWeapon, "autoshotgun", false) != -1 ||
			StrContains(PlayerWeapon, "sniper", false) != -1 ||
			(StrContains(PlayerWeapon, "rifle", false) != -1 && StrContains(PlayerWeapon, "huntingrifle", false) == -1)) ||
		StrContains(WeaponsPermitted, PlayerWeapon, false) != -1) IsFound = true;
	return IsFound;
}

stock int GetCharacterSheetData(int client, char[] stringRef, int theSize, int request, int zombieclass = 0, bool isRecalled = false) {
	//new Float:fResult;
	int iResult = (iBotLevelType == 1) ? SurvivorLevels() : GetDifficultyRating(client);
	float fMultiplier;
	float AbilityMultiplier = (request % 2 == 0) ? GetAbilityMultiplier(client, "X", 4) : 0.0;
	int theCount = LivingSurvivorCount();
	// common infected health
	if (request == 1) {	// odd requests return integers
						// equal requests return floats
		fMultiplier = (iBotLevelType == 1) ? fCommonRaidHealthMult : fCommonLevelHealthMult;
		iResult = iCommonBaseHealth + RoundToCeil(iCommonBaseHealth * (iResult * fMultiplier));
	}
	// common infected damage
	if (request == 2) {
		fMultiplier = fCommonDamageLevel;
		iResult = iCommonInfectedBaseDamage + RoundToCeil(iCommonInfectedBaseDamage * (fMultiplier * iResult));
	}
	// witch health
	if (request == 3) {
		fMultiplier = fWitchHealthMult;
		iResult = iWitchHealthBase + RoundToCeil(iWitchHealthBase * (iResult * fWitchHealthMult));
	}
	// witch infected damage
	if (request == 4) {
		fMultiplier = fWitchDamageScaleLevel;
		iResult = iWitchDamageInitial + RoundToCeil(fMultiplier * iResult);
	}
	// only if a zombieclass has been specified.
	if (zombieclass != 0) {
		if (zombieclass != ZOMBIECLASS_TANK) zombieclass--;
		else zombieclass -= 2;
	}
	// special infected health
	if (request == 5) {
		fMultiplier = fHealthPlayerLevel[zombieclass];
		iResult = iBaseSpecialInfectedHealth[zombieclass] + RoundToCeil(iBaseSpecialInfectedHealth[zombieclass] * (iResult * fMultiplier));
	}
	// special infected damage
	if (request == 6) {
		fMultiplier = fDamagePlayerLevel[zombieclass];
		iResult = iBaseSpecialDamage[zombieclass] + RoundToFloor(iBaseSpecialDamage[zombieclass] * (iResult * fMultiplier));
	}// even requests are for damage.
	if (request != 7 && theCount >= iSurvivorModifierRequired) {
		// health result or damage result
		if (request % 2 != 0) iResult += RoundToCeil(iResult * ((theCount - (iSurvivorModifierRequired - 1)) * fSurvivorHealthBonus));
		else iResult += RoundToCeil(iResult * ((theCount - (iSurvivorModifierRequired - 1)) * fSurvivorDamageBonus));
	}
	//result 7 returns damage shield values. result 8(which is even so no check required) returns damage reduction ability strength.
	if (zombieclass != 0 && (request % 2 == 0 || request == 7)) {
		int DamageShield = 0;
		float DamageShieldMult = (IsClientInRangeSpecialAmmo(client, "D") == -2.0) ? IsClientInRangeSpecialAmmo(client, "D", false, _, iResult * 1.0) : 0.0;

		if (DamageShieldMult > 0.0) DamageShield = RoundToCeil(iResult * DamageShieldMult);
		if (request == 7) {	// Damage Shield percentage reduction in the string and the raw value reduced in the return value.
			if (DamageShield > 0) Format(stringRef, theSize, "%3.3f", DamageShieldMult * 100.0);
			return DamageShield;
		}
		iResult -= DamageShield;
		if (request == 8) {
			if (AbilityMultiplier > 0.0) {
				Format(stringRef, theSize, "%3.3f", AbilityMultiplier * 100.0);
				return RoundToCeil(iResult * AbilityMultiplier);
			}
			return 0;
		}
		iResult -= RoundToCeil(iResult * AbilityMultiplier);
	}


	//if (request % 2 == 0) Format(stringRef, theSize, "%3.3f", fResult);
	//else Format(stringRef, theSize, "%d", iResult);
	AddCommasToString(iResult, stringRef, theSize);
	//Format(stringRef, theSize, "%s", AddCommasToString(iResult));
	return 0;
}

public Handle ProfileEditorMenu(int client) {

	Handle menu		= new Menu(ProfileEditorMenuHandle);

	char text[512];
	Format(text, sizeof(text), "%T", "profile editor title", client, LoadoutName[client]);
	menu.SetTitle(text);

	Format(text, sizeof(text), "%T", "Save Profile", client);
	menu.AddItem(text, text);
	Format(text, sizeof(text), "%T", "Load Profile", client);
	menu.AddItem(text, text);
	Format(text, sizeof(text), "%T", "Load All", client);
	menu.AddItem(text, text);

	char TheName[64];
	int thetarget = LoadProfileRequestName[client];
	if (thetarget == -1 || thetarget == client || !IsLegitimateClient(thetarget) || GetClientTeam(thetarget) != TEAM_SURVIVOR) thetarget = LoadTarget[client];
	if (IsLegitimateClient(thetarget) && GetClientTeam(thetarget) != TEAM_INFECTED && thetarget != client) {

		//decl String:theclassname[64];
		GetClientName(thetarget, TheName, sizeof(TheName));
		char ratingText[64];
		AddCommasToString(Rating[thetarget], ratingText, sizeof(ratingText));
		Format(text, sizeof(text), "%s Lv.%d\t\tScore: %s", TheName, PlayerLevel[thetarget], ratingText);
	}
	else {

		LoadTarget[client] = -1;
		Format(TheName, sizeof(TheName), "%T", "Yourself", client);
	}
	Format(text, sizeof(text), "%T", "Select Load Target", client, TheName);
	menu.AddItem(text, text);
	Format(text, sizeof(text), "%T", "Delete Profile", client);
	menu.AddItem(text, text);

	int Requester = CheckRequestStatus(client);
	if (Requester != -1) {

		if (!IsLegitimateClient(LoadProfileRequestName[client])) LoadProfileRequestName[client] = -1;
		else {

			GetClientName(LoadProfileRequestName[client], TheName, sizeof(TheName));
			Format(text, sizeof(text), "%T", "Cancel Load Request", client, TheName);
			menu.AddItem(text, text);
		}
	}

	menu.ExitBackButton = true;
	menu.Display(client, 0);
}

stock CheckRequestStatus(client, bool CancelRequest = false) {

	char TargetName[64];

	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i) && !IsFakeClient(i) && i != client && LoadProfileRequestName[i] == client) {

			if (!CancelRequest) return i;
			LoadProfileRequestName[i] = -1;
			GetClientName(client, TargetName, sizeof(TargetName));
			PrintToChat(i, "%T", "user has withdrawn request", i, green, TargetName, orange);
			GetClientName(i, TargetName, sizeof(TargetName));
			PrintToChat(client, "%T", "withdrawn request to user", client, orange, green, TargetName);

			return -1;
		}
	}
	return -1;
}

stock DeleteProfile(client, bool DisplayToClient = true) {

	if (strlen(LoadoutName[client]) < 4) return;

	char tquery[512];
	char t_Loadout[64];
	char pct[4];
	Format(pct, sizeof(pct), "%");
	GetClientAuthId(client, AuthId_Steam2, t_Loadout, sizeof(t_Loadout));
	Format(t_Loadout, sizeof(t_Loadout), "%s+%s", t_Loadout, LoadoutName[client]);
	Format(tquery, sizeof(tquery), "DELETE FROM `%s` WHERE `steam_id` LIKE '%s%s' AND `steam_id` LIKE '%sSavedProfile%s';", TheDBPrefix, t_Loadout, pct, pct, pct);
	//PrintToChat(client, tquery);
	LogMessage(tquery);
	hDatabase.Query(QueryResults, tquery, client);
	if (DisplayToClient) {

		PrintToChat(client, "%T", "loadout deleted", client, orange, green, LoadoutName[client]);
		Format(LoadoutName[client], sizeof(LoadoutName[]), "none");
	}
}

stock bool DeleteAllProfiles(int client) {
	char tquery[512];
	char pct[4];
	Format(pct, sizeof(pct), "%");
	Format(tquery, sizeof(tquery), "DELETE FROM `%s` WHERE `steam_id` LIKE '%sSavedProfile%s';", TheDBPrefix, pct, pct);
	LogMessage(tquery);
	hDatabase.Query(QueryResults, tquery, client);
	return true;
}

public ProfileEditorMenuHandle(Handle menu, MenuAction action, client, slot) {

	if (action == MenuAction_Select) {

		if (slot == 0) {

			DeleteProfile(client, false);
			SaveProfile(client);
			ProfileEditorMenu(client);
		}
		if (slot == 1) {

			ReadProfiles(client);
		}
		if (slot == 2) {

			ReadProfiles(client, "all");
		}
		if (slot == 3) {

			//ReadProfiles(client, "all");
			LoadProfileTargetSurvivorBot(client);
		}
		if (slot == 4) {

			DeleteProfile(client);
			ReadProfiles(client);
		}
		if (slot == 5) {

			int Requester = CheckRequestStatus(client);

			if (Requester != -1) {

				CheckRequestStatus(client, true);
				ProfileEditorMenu(client);
			}
		}
	}
	else if (action == MenuAction_Cancel) {

		if (slot == MenuCancel_ExitBack) {

			BuildMenu(client);
		}
	}
	if (action == MenuAction_End) {

		delete menu;
	}
}

stock SaveProfile(client, SaveType = 0) {	// 1 insert a new save, 2 overwrite an existing save.

	if (strlen(LoadoutName[client]) < 8) {

		PrintToChat(client, "use !loadoutname to name your loadout. Must be >= 8 chars");
		return;
	}

	char tquery[512];
	char key[128];
	char pct[4];
	Format(pct, sizeof(pct), "%");

	GetClientAuthId(client, AuthId_Steam2, key, sizeof(key));
	Format(key, sizeof(key), "%s+", key);
	if (SaveType != 0) {

		if (SaveType == 1) PrintToChat(client, "%T", "int save", client, orange, green, LoadoutName[client]);
		else PrintToChat(client, "%T", "update save", client, orange, green, LoadoutName[client]);

		if (StrContains(LoadoutName[client], "Lv.", false) == -1) Format(key, sizeof(key), "%s%s Lv.%d+SavedProfile%s", key, LoadoutName[client], TotalPointsAssigned(client), PROFILE_VERSION);
		else Format(key, sizeof(key), "%s%s+SavedProfile%s", key, LoadoutName[client], PROFILE_VERSION);
		SaveProfileEx(client, key, SaveType);
	}
	else {

		Format(tquery, sizeof(tquery), "SELECT COUNT(*) FROM `%s` WHERE `steam_id` LIKE '%s%s';", TheDBPrefix, key, pct);
		hDatabase.Query(Query_CheckIfProfileLimit, tquery, client);
	}
}

stock void SaveProfileEx(int client, char[] key, int SaveType) {

	char tquery[512];
	char text[512];
	char ActionBarText[64];

	char sPrimary[64];
	char sSecondary[64];
	hWeaponList[client].GetString(0, sPrimary, sizeof(sPrimary));
	hWeaponList[client].GetString(1, sSecondary, sizeof(sSecondary));

	int talentlevel = 0;
	int size = a_Database_Talents.Length;
	int isDisab = 0;
	if (DisplayActionBar[client]) isDisab = 1;
	if (SaveType == 1) {

		//	A save doesn't exist for this steamid so we create one before saving anything.
		Format(tquery, sizeof(tquery), "INSERT INTO `%s` (`steam_id`) VALUES ('%s');", TheDBPrefix, key);
		//PrintToChat(client, tquery);
		hDatabase.Query(QueryResults, tquery, client);
	}

	// if the database isn't connected, we don't try to save data, because that'll just throw errors.
	// If the player didn't participate, or if they are currently saving data, we don't save as well.
	// It's possible (but not likely) for a player to try to save data while saving, due to their ability to call the function at any time through commands.
	if (hDatabase == INVALID_HANDLE) {

		LogMessage("Database couldn't be found, cannot save for %N", client);
		return;
	}

	//if (PlayerLevel[client] < 1) return;		// Clearly, their data hasn't loaded, so we don't save.
	Format(tquery, sizeof(tquery), "UPDATE `%s` SET `total upgrades` = '%d' WHERE `steam_id` = '%s';", TheDBPrefix, PlayerLevel[client] - UpgradesAvailable[client] - FreeUpgrades[client], key);
	//PrintToChat(client, tquery);
	//LogMessage(tquery);
	hDatabase.Query(QueryResults, tquery, client);

	Format(tquery, sizeof(tquery), "UPDATE `%s` SET `primarywep` = '%s', `secondwep` = '%s' WHERE `steam_id` = '%s';", TheDBPrefix, sPrimary, sSecondary, key);
	hDatabase.Query(QueryResults, tquery, client);

	for (int i = 0; i < size; i++) {

		a_Database_Talents.GetString(i, text, sizeof(text));
		//TalentTreeKeys[client]			= a_Menu_Talents.Get(i, 0);
		TalentTreeValues[client]		= a_Menu_Talents.Get(i, 1);

		if (GetKeyValueIntAtPos(TalentTreeValues[client], IS_TALENT_TYPE) == 1) continue;	// we don't save class attributes.
		if (GetKeyValueIntAtPos(TalentTreeValues[client], IS_SUB_MENU_OF_TALENTCONFIG) == 1) continue;
		//if (GetKeyValueInt(TalentTreeKeys[client], TalentTreeValues[client], "is ability?") == 1) continue;
		if (GetKeyValueIntAtPos(TalentTreeValues[client], ITEM_ITEM_ID) == 1) continue;

		talentlevel = a_Database_PlayerTalents[client].Get(i);// a_Database_PlayerTalents[client].GetString(i, text2, sizeof(text2));
		Format(tquery, sizeof(tquery), "UPDATE `%s` SET `%s` = '%d' WHERE `steam_id` = '%s';", TheDBPrefix, text, talentlevel, key);
		hDatabase.Query(QueryResults, tquery, client);
	}

	for (int i = 0; i < iActionBarSlots; i++) {	// isnt looping?

		ActionBar[client].GetString(i, ActionBarText, sizeof(ActionBarText));
		//if (StrEqual(ActionBarText, "none")) continue;
		if (!IsAbilityTalent(client, ActionBarText) && (!IsTalentExists(ActionBarText) || GetTalentStrength(client, ActionBarText) < 1)) Format(ActionBarText, sizeof(ActionBarText), "none");
		Format(tquery, sizeof(tquery), "UPDATE `%s` SET `aslot%d` = '%s' WHERE (`steam_id` = '%s');", TheDBPrefix, i+1, ActionBarText, key);
		hDatabase.Query(QueryResults, tquery);
	}
	Format(tquery, sizeof(tquery), "UPDATE `%s` SET `disab` = '%d' WHERE (`steam_id` = '%s');", TheDBPrefix, isDisab, key);
	hDatabase.Query(QueryResults, tquery);

	LogMessage("Saving Profile %N where steamid: %s", client, key);
}

stock void ReadProfiles(int client, char[] target = "none") {

	if (bIsTalentTwo[client]) {

		BuildMenu(client);
		return;
	}

	if (hDatabase == INVALID_HANDLE) return;
	char key[64];
	GetClientAuthId(StrEqual(target, AuthId_Steam2, "none", false));
	if (StrEqual(target, "none", false)) 
		GetClientAuthString(client, key, sizeof(key));
	else
		Format(key, sizeof(key), "%s", target);

	Format(key, sizeof(key), "%s+", key);
	char tquery[128];
	char pct[4];
	Format(pct, sizeof(pct), "%");

	int owner = client;
	if (LoadTarget[owner] != -1 && LoadTarget[owner] != owner && IsSurvivorBot(LoadTarget[owner])) client = LoadTarget[owner]; 

	if (!StrEqual(target, "all", false)) Format(tquery, sizeof(tquery), "SELECT `steam_id` FROM `%s` WHERE `steam_id` LIKE '%s%s' AND `total upgrades` <= '%d';", TheDBPrefix, key, pct, MaximumPlayerUpgrades(client));
	else Format(tquery, sizeof(tquery), "SELECT `steam_id` FROM `%s` WHERE `steam_id` LIKE '%s+SavedProfile%s' AND `total upgrades` <= '%d';", TheDBPrefix, pct, PROFILE_VERSION, MaximumPlayerUpgrades(client));
	//PrintToChat(client, tquery);
	//decl String:tqueryE[512];
	//Handle:hDatabase.Escape(tquery, tqueryE, sizeof(tqueryE));
	// maybe set a value equal to the users steamid integer only, so if steam:0:1:23456, set the value of "client" equal to 23456 and then set the client equal to whatever client's steamid contains 23456?
	//LogMessage("Loading %N data: %s", client, tquery);
	PlayerProfiles[owner].Clear();
	if (!StrEqual(target, "all", false)) hDatabase.Query(ReadProfiles_Generate, tquery, owner);
	else hDatabase.Query(ReadProfiles_GenerateAll, tquery, owner);
}

stock void BuildSubMenu(int client, char[] MenuName, char[] ConfigName, char[] ReturnMenu = "none") {
	bIsClassAbilities[client] = false;
	// Each talent has a defined "menu name" ("part of menu named?") and will list under that menu. Genius, right?
	Handle menu					=	new Menu(BuildSubMenuHandle);
	// So that back buttons work properly we need to know the previous menu; Store the current menu.
	if (!StrEqual(ReturnMenu, "none", false)) Format(OpenedMenu[client], sizeof(OpenedMenu[]), "%s", ReturnMenu);
	Format(OpenedMenu_p[client], sizeof(OpenedMenu_p[]), "%s", OpenedMenu[client]);
	Format(OpenedMenu[client], sizeof(OpenedMenu[]), "%s", MenuName);
	Format(MenuSelection_p[client], sizeof(MenuSelection_p[]), "%s", MenuSelection[client]);
	Format(MenuSelection[client], sizeof(MenuSelection[]), "%s", ConfigName);

	if (!b_IsDirectorTalents[client]) {

		if (StrEqual(ConfigName, CONFIG_MENUTALENTS)) {

			BuildMenuTitle(client, menu, _, 1, _, ShowPlayerLayerInformation[client]);
		}
		else if (StrEqual(ConfigName, CONFIG_POINTS)) {

			BuildMenuTitle(client, menu, _, 2);
		}
	}
	else BuildMenuTitle(client, menu, 1);

	char text[PLATFORM_MAX_PATH];
	char pct[4];
	char TalentName[128];
	char TalentName_Temp[128];
	int isSubMenu = 0;
	int TalentLevelRequired			=	0;
	int PlayerTalentPoints			=	0;
	//new AbilityInherited			=	0;
	//new StorePurchaseCost			=	0;
	int AbilityTalent				=	0;
	int isSpecialAmmo				=	0;
	//decl String:sClassAllowed[64];
	//decl String:sClassID[64];
	char sTalentsRequired[512];
	bool bIsNotEligible = false;
	//new iSkyLevelReq = 0;//deprecated for now
	//new nodeUnlockCost = 0;
	int optionsRemaining = 0;
	Format(pct, sizeof(pct), "%");//required for translations

	int size						=	a_Menu_Talents.Length;
	// all talents are now housed in a shared config file... taking our total down to like.. 14... sigh... is customization really worth that headache?
	// and I mean the headache for YOU, not the headache for me. This is easy. EASY. YOU CAN'T BREAK ME.
	//if (StrEqual(ConfigName, CONFIG_MENUSURVIVOR)) size			=	a_Menu_Talents_Survivor.Length;
	//else if (StrEqual(ConfigName, CONFIG_MENUINFECTED)) size	=	a_Menu_Talents_Infected.Length;
	
	// so if we're not equipping items to the action bar, we show them based on which submenu we've called.
	// these keys/values/section names match their talentmenu.cfg notations.
	int requiredTalentsRequiredToUnlock = 0;
	int requiredCopy = 0;
	for (int i = 0; i < size; i++) {
		MenuKeys[client]			= a_Menu_Talents.Get(i, 0);
		MenuValues[client]			= a_Menu_Talents.Get(i, 1);
		MenuSection[client]			= a_Menu_Talents.Get(i, 2);

		MenuSection[client].GetString(0, TalentName, sizeof(TalentName));
		if (!bEquipSpells[client] && !TalentListingFound(client, MenuKeys[client], MenuValues[client], MenuName)) continue;
		AbilityTalent	=	GetKeyValueIntAtPos(MenuValues[client], IS_TALENT_ABILITY);
		isSpecialAmmo	=	GetKeyValueIntAtPos(MenuValues[client], TALENT_IS_SPELL);
		PlayerTalentPoints = GetTalentStrength(client, TalentName);

		if (bEquipSpells[client]) {
			if (AbilityTalent != 1 && isSpecialAmmo != 1) continue;
			if (PlayerTalentPoints < 1) continue;

			//Format(TalentName_Temp, sizeof(TalentName_Temp), "%T", TalentName, client);
			MenuValues[client].GetString(ACTION_BAR_NAME, text, sizeof(text));
			if (StrEqual(text, "-1")) SetFailState("%s missing action bar name", TalentName);
			Format(text, sizeof(text), "%T", text, client);
			menu.AddItem(text, text);
			continue;
		}

		GetTranslationOfTalentName(client, TalentName, TalentName_Temp, sizeof(TalentName_Temp), true);
		Format(TalentName_Temp, sizeof(TalentName_Temp), "%T", TalentName_Temp, client);
		isSubMenu = GetKeyValueIntAtPos(MenuValues[client], IS_SUB_MENU_OF_TALENTCONFIG);
		TalentLevelRequired = GetKeyValueIntAtPos(MenuValues[client], TALENT_MINIMUM_LEVEL_REQ);
		// isSubMenu 3 is for a different operation, we do || instead of &&
		if (isSubMenu == 1 || isSubMenu == 2) {

			// We strictly show the menu option.
			if (isSubMenu == 1 && PlayerLevel[client] < TalentLevelRequired) Format(text, sizeof(text), "%T", "Submenu Locked", client, TalentName_Temp, TalentLevelRequired);
			else Format(text, sizeof(text), "%T", "Submenu Available", client, TalentName_Temp);
		}
		else {
			if (GetKeyValueIntAtPos(MenuValues[client], ITEM_ITEM_ID) == 1) continue;	// ignore items.
			//AbilityInherited = GetKeyValueInt(MenuKeys[client], MenuValues[client], "ability inherited?");
			//nodeUnlockCost = GetKeyValueInt(MenuKeys[client], MenuValues[client], "node unlock cost?", "1");	// we want to default the nodeUnlockCost to 1 if it's not set.
			if (!b_IsDirectorTalents[client]) {
				//FormatKeyValue(sTalentsRequired, sizeof(sTalentsRequired), MenuKeys[client], MenuValues[client], "talents required?");
				//if (GetKeyValueInt(MenuKeys[client], MenuValues[client], "show debug info?") == 1) PrintToChat(client, "%s", sTalentsRequired);
				requiredTalentsRequiredToUnlock = GetKeyValueIntAtPos(MenuValues[client], NUM_TALENTS_REQ);
				requiredCopy = requiredTalentsRequiredToUnlock;
				optionsRemaining = TalentRequirementsMet(client, MenuKeys[client], MenuValues[client], _, -1);
				if (requiredTalentsRequiredToUnlock > 0) requiredTalentsRequiredToUnlock = TalentRequirementsMet(client, MenuKeys[client], MenuValues[client], sTalentsRequired, sizeof(sTalentsRequired), requiredTalentsRequiredToUnlock);
				if (requiredTalentsRequiredToUnlock > 0) {
					bIsNotEligible = true;
					if (PlayerTalentPoints > 0) {
						FreeUpgrades[client]++;// += nodeUnlockCost;
						PlayerUpgradesTotal[client] -= PlayerTalentPoints;
						AddTalentPoints(client, TalentName, 0);
					}
				}
				else {
					bIsNotEligible = false;
					if (PlayerTalentPoints > 1) {
						/*
						The player was on a server with different talent settings; specifically,
						it's clear some talents allowed greater values. Since this server doesn't,
						we set them to the maximum, refund the extra points.
						*/
						// dev note; we did this because players have saveable profiles and they can just load their server-specific profiles at any time.
						// instantly, and effortlessly, because it's an rpg and a common sense feature that should ALWAYS EXIST IN AN RPG.
						FreeUpgrades[client] += (PlayerTalentPoints - 1);
						PlayerUpgradesTotal[client] -= (PlayerTalentPoints - 1);
						AddTalentPoints(client, TalentName, (PlayerTalentPoints - 1));
					}
				}
			}
			else PlayerTalentPoints = GetTalentStrength(-1, TalentName);
			if (GetKeyValueIntAtPos(MenuValues[client], IS_TALENT_TYPE) <= 0) {
				if (bIsNotEligible) {
					if (iShowLockedTalents == 0) continue;
					if (requiredTalentsRequiredToUnlock > 1) {
						if (requiredCopy == optionsRemaining) Format(text, sizeof(text), "%T", "node locked by talents all (treeview)", client, TalentName_Temp, sTalentsRequired);
						else Format(text, sizeof(text), "%T", "node locked by talents multiple (treeview)", client, TalentName_Temp, sTalentsRequired, requiredTalentsRequiredToUnlock);
					} else {
						if (optionsRemaining == 1) Format(text, sizeof(text), "%T", "node locked by talents last one (treeview)", client, TalentName_Temp, sTalentsRequired);
						else Format(text, sizeof(text), "%T", "node locked by talents single (treeview)", client, TalentName_Temp, sTalentsRequired, requiredTalentsRequiredToUnlock);
					}
				}
				else if (PlayerTalentPoints < 1) {
					Format(text, sizeof(text), "%T", "node locked", client, TalentName_Temp, 1);
				}
				else Format(text, sizeof(text), "%T", "node unlocked", client, TalentName_Temp);
			}
			else {
				Format(text, sizeof(text), "%T", TalentName_Temp, client);
			}
		}
		menu.AddItem(text, text);
	}
	menu.ExitBackButton = true;
	menu.Display(client, 0);
}

stock bool TalentListingFound(int client, Handle Keys, Handle Values, char[] MenuName, bool IsAllowItems = false) {

	int size = Keys.Length;

	char key[64];
	char value[64];

	for (int i = 0; i < size; i++) {

		Keys.GetString(i, key, sizeof(key));
		if (StrEqual(key, "part of menu named?")) {

			Values.GetString(i, value, sizeof(value));
			if (!StrEqual(MenuName, value)) return false;
		}
		/*if (StrEqual(key, "is item?") && !IsAllowItems) { // can be true only in bestiary

			Handle:Values.GetString(i, value, sizeof(value));
			if (StringToInt(value) == 1) return false;
		}*/
		// The following segment is no longer used. It was originally used when configs were not split based on team number.
		// It meant that server operators would fill a single, massive config with team data, and it would be parsed to a player based on this setting.
		// That's still an option that I'm looking at, for the future, but for now, it won't be the case.
		/*if (StrEqual(key, "team?")) {

			Handle:Values.GetString(i, value, sizeof(value));
			if (strlen(value) > 0 && GetClientTeam(client) != StringToInt(value)) return false;
		}
		*/
		// If this value is set to anything other than "none" a player won't be able to view or select it unless they have at least one of the flags
		// provided. This allows server operators to experiment with new talents, publicly, while granting access to these talents to specific players.
		if (StrEqual(key, "flags?")) {

			Values.GetString(i, value, sizeof(value));
			if (!StrEqual(value, "none", false) && !HasCommandAccess(client, value)) return false;
		}
	}
	return true;
}

public BuildSubMenuHandle(Handle menu, MenuAction action, client, slot)
{
	if (action == MenuAction_Select)
	{
		char ConfigName[64];
		Format(ConfigName, sizeof(ConfigName), "%s", MenuSelection[client]);
		char MenuName[64];
		Format(MenuName, sizeof(MenuName), "%s", OpenedMenu[client]);
		int pos							=	-1;

		BuildMenuTitle(client, menu);

		char pct[4];

		char TalentName[64];
		int isSubMenu = 0;


		int PlayerTalentPoints			=	0;

		char SurvEffects[64];
		Format(SurvEffects, sizeof(SurvEffects), "0");

		Format(pct, sizeof(pct), "%");

		int size						=	a_Menu_Talents.Length;
		int TalentLevelRequired			= 0;
		int AbilityTalent				= 0;
		int isSpecialAmmo				= 0;
		//decl String:sClassAllowed[64];
		//decl String:sClassID[64];
		//decl String:sTalentsRequired[64];
		//new nodeUnlockCost = 0;

		//new bool:bIsNotEligible = false;

		//new iSkyLevelReq = 0;

		//if (StrEqual(ConfigName, CONFIG_MENUSURVIVOR)) size			=	a_Menu_Talents_Survivor.Length;
		//else if (StrEqual(ConfigName, CONFIG_MENUINFECTED)) size	=	a_Menu_Talents_Infected.Length;

		for (int i = 0; i < size; i++) {

			MenuKeys[client]				= a_Menu_Talents.Get(i, 0);
			MenuValues[client]				= a_Menu_Talents.Get(i, 1);
			MenuSection[client]				= a_Menu_Talents.Get(i, 2);

			MenuSection[client].GetString(0, TalentName, sizeof(TalentName));
			if (!bEquipSpells[client] && !TalentListingFound(client, MenuKeys[client], MenuValues[client], MenuName)) continue;
			AbilityTalent	=	GetKeyValueIntAtPos(MenuValues[client], IS_TALENT_ABILITY);
			isSpecialAmmo	=	GetKeyValueIntAtPos(MenuValues[client], TALENT_IS_SPELL);
			PlayerTalentPoints = GetTalentStrength(client, TalentName);
			if (bEquipSpells[client]) {
				if (AbilityTalent != 1 && isSpecialAmmo != 1) continue;
				if (PlayerTalentPoints < 1) continue;
			}
			isSubMenu = GetKeyValueIntAtPos(MenuValues[client], IS_SUB_MENU_OF_TALENTCONFIG);
			TalentLevelRequired = GetKeyValueIntAtPos(MenuValues[client], TALENT_MINIMUM_LEVEL_REQ);
			//iSkyLevelReq	=	GetKeyValueInt(MenuKeys[client], MenuValues[client], "sky level requirement?");
			//nodeUnlockCost = GetKeyValueInt(MenuKeys[client], MenuValues[client], "node unlock cost?", "1");
			//FormatKeyValue(sTalentsRequired, sizeof(sTalentsRequired), MenuKeys[client], MenuValues[client], "talents required?");
			//if (!TalentRequirementsMet(client, sTalentsRequired)) continue;
			if (GetKeyValueIntAtPos(MenuValues[client], ITEM_ITEM_ID) == 1) continue;
			pos++;
			//FormatKeyValue(SurvEffects, sizeof(SurvEffects), MenuKeys[client], MenuValues[client], "survivor ability effects?");
			if (pos == slot) break;
		}

		if (isSubMenu == 1 || isSubMenu == 2) {
			if (PlayerLevel[client] < TalentLevelRequired) {
				BuildSubMenu(client, OpenedMenu[client], MenuSelection[client]);
			}
			else {
				// If the player is eligible we open a new sub-menu.
				BuildSubMenu(client, TalentName, MenuSelection[client], OpenedMenu[client]);
			}
		}
		else {
			PlayerTalentPoints = GetTalentStrength(client, TalentName);
			//if (AbilityTalent == 1 || PlayerLevel[client] >= TalentLevelRequired || bEquipSpells[client]) {// submenu 2 is to send to spell equip screen *Flex*
			if (PlayerLevel[client] >= TalentLevelRequired || bEquipSpells[client]) {// submenu 2 is to send to spell equip screen *Flex*

				PurchaseTalentName[client] = TalentName;
				PurchaseTalentPoints[client] = PlayerTalentPoints;

				if (bEquipSpells[client]) ShowTalentInfoScreen(client, TalentName, MenuKeys[client], MenuValues[client], true);
				else ShowTalentInfoScreen(client, TalentName, MenuKeys[client], MenuValues[client]);
			}
			else {
				char TalentName_temp[64];
				Format(TalentName_temp, sizeof(TalentName_temp), "%T", TalentName, client);

				PrintToChat(client, "%T", "talent level requirement not met", client, orange, blue, TalentLevelRequired, orange, green, TalentName_temp);
				BuildSubMenu(client, OpenedMenu[client], MenuSelection[client]);
			}
		}
	}
	else if (action == MenuAction_Cancel) {

		if (slot == MenuCancel_ExitBack) {
			bEquipSpells[client] = false;
			BuildMenu(client);
		}
	}
	if (action == MenuAction_End)
	{
		delete menu;
	}
}
// need to code in abilities as showing if bIsEquipSpells and requiring an upgrade point to enable.
stock void ShowTalentInfoScreen(int client, char[] TalentName, Handle Keys, Handle Values, bool bIsEquipSpells = false) {

	PurchaseKeys[client] = Keys;
	PurchaseValues[client] = Values;
	Format(PurchaseTalentName[client], sizeof(PurchaseTalentName[]), "%s", TalentName);
	//new IsAbilityType = GetKeyValueInt(PurchaseKeys[client], PurchaseValues[client], "is ability?");
	//new IsSpecialAmmo = GetKeyValueInt(PurchaseKeys[client], PurchaseValues[client], "special ammo?");
	//PurchaseTalentName[client] = TalentName;
	// programming the logic is hard when baked :(
	//if (IsAbilityType == 1 || IsSpecialAmmo == 1 && bIsSprinting[client]) SendPanelToClientAndClose(TalentInfoScreen_Special(client), client, TalentInfoScreen_Special_Init, MENU_TIME_FOREVER);
	if (bIsEquipSpells) SendPanelToClientAndClose(TalentInfoScreen_Special(client), client, TalentInfoScreen_Special_Init, MENU_TIME_FOREVER);
	else SendPanelToClientAndClose(TalentInfoScreen(client), client, TalentInfoScreen_Init, MENU_TIME_FOREVER);
	//if (IsAbilityType == 0 || !bIsSprinting[client]) SendPanelToClientAndClose(TalentInfoScreen(client), client, TalentInfoScreen_Init, MENU_TIME_FOREVER);
	//else if (IsSpecialAmmo == 1 || IsAbilityType == 1) SendPanelToClientAndClose(TalentInfoScreen_Special(client), client, TalentInfoScreen_Special_Init, MENU_TIME_FOREVER);
}

stock float GetTalentInfo(int client, Handle Values, int infotype = 0, bool bIsNext = false, char[] pTalentNameOverride = "none", int target = 0, int iStrengthOverride = 0) {
	float f_Strength	= 0.0;
	char TalentNameOverride[64];
	if (iStrengthOverride > 0) f_Strength = iStrengthOverride * 1.0;
	else {
		if (StrEqual(pTalentNameOverride, "none")) Format(TalentNameOverride, sizeof(TalentNameOverride), "%s", PurchaseTalentName[client]);
		else Format(TalentNameOverride, sizeof(TalentNameOverride), "%s", pTalentNameOverride);
		f_Strength	=	GetTalentStrength(client, TalentNameOverride) * 1.0;
	}
	if (bIsNext) f_Strength++;
	if (f_Strength <= 0.0) return 0.0;
	float f_StrengthPoint	= 0.0;
	if (target == 0 || !IsLegitimateClient(target)) target = client;
	/*
		Server operators can make up their own custom attributes, and make them affect any node they want.
		This key "governing attribute?" lets me know what attribute multiplier to collect.
		If you don't want a node governed by an attribute, omit the field.
	*/
	Values = a_Menu_Talents.Get(GetMenuPosition(client, TalentNameOverride), 1);
	char text[64];
	Values.GetString(GOVERNING_ATTRIBUTE, text, sizeof(text));
	float governingAttributeMultiplier = 0.0;
	if (!StrEqual(text, "-1")) governingAttributeMultiplier = GetAttributeMultiplier(client, text);

	//we want to add support for a "type" of talent.
	char sTalentStrengthType[64];
	if (infotype == 0 || infotype == 1) Values.GetString(TALENT_UPGRADE_STRENGTH_VALUE, sTalentStrengthType, sizeof(sTalentStrengthType));
	else if (infotype == 2) Values.GetString(TALENT_ACTIVE_STRENGTH_VALUE, sTalentStrengthType, sizeof(sTalentStrengthType));
	else if (infotype == 3) Values.GetString(TALENT_COOLDOWN_STRENGTH_VALUE, sTalentStrengthType, sizeof(sTalentStrengthType));
	int istrength = RoundToCeil(f_Strength);
	float f_StrengthIncrement = StringToFloat(sTalentStrengthType);
	if (istrength < 1) return 0.0;
	f_StrengthPoint = f_StrengthIncrement;

	if (governingAttributeMultiplier > 0.0) {
		f_StrengthPoint += (f_StrengthPoint * governingAttributeMultiplier);
	}
	if (infotype == 3) {
		char sCooldownGovernor[64];
		float cdReduction = 0.0;
		int acdReduction = a_Menu_Talents.Length;
		for (int i = 0; i < acdReduction; i++) {
			acdrValues[client] = a_Menu_Talents.Get(i, 1);
			acdrValues[client].GetString(COOLDOWN_GOVERNOR_OF_TALENT, sCooldownGovernor, sizeof(sCooldownGovernor));
			if (!FoundCooldownReduction(TalentNameOverride, sCooldownGovernor)) continue;

			acdrSection[client] = a_Menu_Talents.Get(i, 2);
			acdrSection[client].GetString(0, sCooldownGovernor, sizeof(sCooldownGovernor));
			cdReduction += GetTalentInfo(client, acdrValues[client], _, _, sCooldownGovernor);
		}
		if (cdReduction > 0.0) f_StrengthPoint -= (f_StrengthPoint * cdReduction);
		if (f_StrengthPoint < 0.0) f_StrengthPoint = 0.0;	// can't have cooldowns that are less than 0.0 seconds.
	}

	float TalentHardLimit = GetKeyValueFloatAtPos(Values, TALENT_STRENGTH_HARD_LIMIT);
	if (infotype != 3 && f_StrengthPoint > TalentHardLimit && TalentHardLimit > 0.0) f_StrengthPoint = TalentHardLimit;

	return f_StrengthPoint;
}

public Handle TalentInfoScreen(int client) {
	int AbilityTalent			= GetKeyValueInt(PurchaseKeys[client], PurchaseValues[client], "is ability?");
	int IsSpecialAmmo = GetKeyValueInt(PurchaseKeys[client], PurchaseValues[client], "special ammo?");

	Handle menu = new Panel();
	BuildMenuTitle(client, menu, _, 0, true, true);

	char TalentName[64];
	Format(TalentName, sizeof(TalentName), "%s", PurchaseTalentName[client]);

	int TalentPointAmount		= 0;
	if (!b_IsDirectorTalents[client]) TalentPointAmount = GetTalentStrength(client, TalentName);
	else TalentPointAmount = GetTalentStrength(-1, TalentName);

	int TalentType = GetKeyValueInt(PurchaseKeys[client], PurchaseValues[client], "talent type?");
	int nodeUnlockCost = GetKeyValueInt(PurchaseKeys[client], PurchaseValues[client], "node unlock cost?", "1");

	float s_TalentPoints = GetTalentInfo(client, PurchaseValues[client]);
	float s_OtherPointNext = GetTalentInfo(client, PurchaseValues[client], _, true);

	char pct[4];
	Format(pct, sizeof(pct), "%");
	
	float f_CooldownNow = GetTalentInfo(client, PurchaseValues[client], 3);
	float f_CooldownNext = GetTalentInfo(client, PurchaseValues[client], 3, true);

	char TalentIdCode[64];
	char TalentIdNum[64];
	FormatKeyValue(TalentIdNum, sizeof(TalentIdNum), PurchaseKeys[client], PurchaseValues[client], "id_number");

	Format(TalentIdCode, sizeof(TalentIdCode), "%T", "Talent Id Code", client);
	Format(TalentIdCode, sizeof(TalentIdCode), "%s: %s", TalentIdCode, TalentIdNum);

	//	We copy the talent name to another string so we can show the talent in the language of the player.
	
	char TalentName_Temp[64];
	char TalentNameTranslation[64];
	GetTranslationOfTalentName(client, TalentName, TalentNameTranslation, sizeof(TalentNameTranslation), true);
	Format(TalentName_Temp, sizeof(TalentName_Temp), "%T", TalentNameTranslation, client);
	char text[512];	
	if (AbilityTalent != 1) {

		if (FreeUpgrades[client] < 0) FreeUpgrades[client] = 0;
		Format(text, sizeof(text), "%T", "Talent Upgrade Title", client, TalentName_Temp, TalentPointAmount);
	}
	else Format(text, sizeof(text), "%s", TalentName_Temp);
	menu.DrawText(text);

	char governingAttribute[64];
	GetGoverningAttribute(client, TalentName, governingAttribute, sizeof(governingAttribute));
	if (!StrEqual(governingAttribute, "-1")) {
		Format(text, sizeof(text), "%T", governingAttribute, client);
		Format(text, sizeof(text), "%T", "Node Governing Attribute", client, text);
		menu.DrawText(text);
	}
	float AoEEffectRange = GetKeyValueFloatAtPos(PurchaseValues[client], PRIMARY_AOE);
	if (AoEEffectRange > 0.0) {
		Format(text, sizeof(text), "%T", "primary aoe range", client, AoEEffectRange);
		menu.DrawText(text);
	}
	AoEEffectRange = GetKeyValueFloatAtPos(PurchaseValues[client], SECONDARY_AOE);
	if (AoEEffectRange > 0.0) {
		Format(text, sizeof(text), "%T", "secondary aoe range", client, AoEEffectRange);
		menu.DrawText(text);
	}
	AoEEffectRange = GetKeyValueFloatAtPos(PurchaseValues[client], MULTIPLY_RANGE);
	if (AoEEffectRange > 0.0) {
		Format(text, sizeof(text), "%T", "multiply aoe range", client, AoEEffectRange);
		menu.DrawText(text);
	}
	bool IsEffectOverTime = (GetKeyValueIntAtPos(PurchaseValues[client], TALENT_IS_EFFECT_OVER_TIME) == 1) ? true : false;

	char TalentInfo[128];
	int AbilityType = 0;
	if (AbilityTalent != 1) {

		if (IsSpecialAmmo != 1) {
			if (f_CooldownNext > 0.0) {
				if (TalentPointAmount == 0) Format(text, sizeof(text), "%T", "Talent Cooldown Info - No Points", client, f_CooldownNext);
				else Format(text, sizeof(text), "%T", "Talent Cooldown Info", client, f_CooldownNow, f_CooldownNext);
				menu.DrawText(text);
			}
			//else Format(text, sizeof(text), "%T", "No Talent Cooldown Info", client);

			float i_AbilityTime = GetTalentInfo(client, PurchaseValues[client], 2);
			float i_AbilityTimeNext = GetTalentInfo(client, PurchaseValues[client], 2, true);
			/*
				ability type ONLY EXISTS for displaying different information to the players via menus.
				the EXCEPTION to this is type 3, where rpg_functions.sp line 2428 makes a check using it.

				Otherwise, it's just how we translate it for the player to understand.
			*/
			AbilityType = GetKeyValueIntAtPos(PurchaseValues[client], ABILITY_TYPE);
			if (AbilityType < 0) AbilityType = 0;	// if someone forgets to set this, we have to set it to the default value.
			//if (TalentPointAmount > 0) s_PenaltyPoint = 0.0;
			if (TalentType <= 0) {
				if (TalentPointAmount < 1) {
					if (AbilityType == 0) Format(text, sizeof(text), "%T", "Ability Info Percent", client, s_TalentPoints * 100.0, pct, s_OtherPointNext * 100.0, pct);
					else if (AbilityType == 1) Format(text, sizeof(text), "%T", "Ability Info Time", client, i_AbilityTime, i_AbilityTimeNext);
					else if (AbilityType == 2) Format(text, sizeof(text), "%T", "Ability Info Distance", client, s_TalentPoints, s_OtherPointNext);
					else if (AbilityType == 3) Format(text, sizeof(text), "%T", "Ability Info Raw", client, RoundToCeil(s_TalentPoints), RoundToCeil(s_OtherPointNext));
				}
				else {
					if (AbilityType == 0) Format(text, sizeof(text), "%T", "Ability Info Percent Max", client, s_TalentPoints * 100.0, pct);
					else if (AbilityType == 1) Format(text, sizeof(text), "%T", "Ability Info Time Max", client, i_AbilityTime);
					else if (AbilityType == 2) Format(text, sizeof(text), "%T", "Ability Info Distance Max", client, s_TalentPoints);
					else if (AbilityType == 3) Format(text, sizeof(text), "%T", "Ability Info Raw Max", client, RoundToCeil(s_TalentPoints));
				}
				menu.DrawText(text);
				//menu.DrawText(TalentIdCode);
				if (IsEffectOverTime) {
					// Effects over time ALWAYS show the period of time.
					if (TalentPointAmount < 1) Format(text, sizeof(text), "%T", "Ability Info Time", client, i_AbilityTime, i_AbilityTimeNext);
					else Format(text, sizeof(text), "%T", "Ability Info Time Max", client, i_AbilityTime);
					menu.DrawText(text);
				}
			}
		}
		else {


			/*if (FreeUpgrades[client] == 0) Format(text, sizeof(text), "%T", "Talent Upgrade Title", client, TalentName_Temp, TalentPointAmount, TalentPointMaximum);
			else Format(text, sizeof(text), "%T", "Talent Upgrade Title Free", client, TalentName_Temp, TalentPointAmount, TalentPointMaximum, FreeUpgrades[client]);
			menu.SetTitle(text);*/

			float fTimeCur = GetSpecialAmmoStrength(client, TalentName);
			float fTimeNex = GetSpecialAmmoStrength(client, TalentName, 0, true);

			//new Float:flIntCur = GetSpecialAmmoStrength(client, TalentName, 4);
			//new Float:flIntNex = GetSpecialAmmoStrength(client, TalentName, 4, true);

			//if (flIntCur > fTimeCur) flIntCur = fTimeCur;
			//if (flIntNex > fTimeNex) flIntNex = fTimeNex;

			//Format(text, sizeof(text), "%T", "Special Ammo Interval", client, flIntCur, flIntNex);
			//menu.DrawText(text);
			if (TalentPointAmount < 1) {
				Format(text, sizeof(text), "%T", "Special Ammo Time", client, fTimeNex);
				menu.DrawText(text);
				Format(text, sizeof(text), "%T", "Special Ammo Cooldown", client, fTimeNex + GetSpecialAmmoStrength(client, TalentName, 1, true));
				menu.DrawText(text);
				Format(text, sizeof(text), "%T", "Special Ammo Stamina", client, RoundToCeil(GetSpecialAmmoStrength(client, TalentName, 2, true)));
				menu.DrawText(text);
				Format(text, sizeof(text), "%T", "Special Ammo Range", client, GetSpecialAmmoStrength(client, TalentName, 3, true));
				menu.DrawText(text);
			}
			else {
				Format(text, sizeof(text), "%T", "Special Ammo Time Max", client, fTimeCur);
				menu.DrawText(text);
				Format(text, sizeof(text), "%T", "Special Ammo Cooldown Max", client, fTimeCur + GetSpecialAmmoStrength(client, TalentName, 1));
				menu.DrawText(text);
				Format(text, sizeof(text), "%T", "Special Ammo Stamina Max", client, RoundToCeil(GetSpecialAmmoStrength(client, TalentName, 2)));
				menu.DrawText(text);
				Format(text, sizeof(text), "%T", "Special Ammo Range Max", client, GetSpecialAmmoStrength(client, TalentName, 3));
				menu.DrawText(text);
			}
			Format(text, sizeof(text), "%T", "Special Ammo Effect Strength", client, GetKeyValueFloatAtPos(PurchaseValues[client], SPECIAL_AMMO_TALENT_STRENGTH) * 100.0, pct);
			menu.DrawText(text);
			//menu.DrawText(TalentIdCode);
		}
	}

	if (TalentType <= 0 || AbilityTalent == 1) {

		if (TalentPointAmount == 0) {
			int ignoreLayerCount = (GetKeyValueIntAtPos(PurchaseValues[client], LAYER_COUNTING_IS_IGNORED) == 1) ? 1 :
								   (GetKeyValueIntAtPos(PurchaseValues[client], IS_ATTRIBUTE) == 1) ? 1 : 0;
			bool bIsLayerEligible = (PlayerCurrentMenuLayer[client] <= 1 || GetLayerUpgradeStrength(client, PlayerCurrentMenuLayer[client] - 1) >= PlayerCurrentMenuLayer[client]) ? true : false;
			if (bIsLayerEligible) bIsLayerEligible = ((ignoreLayerCount == 1 || GetLayerUpgradeStrength(client, PlayerCurrentMenuLayer[client], _, _, _, _, true) < PlayerCurrentMenuLayer[client] + 1) && UpgradesAvailable[client] + FreeUpgrades[client] >= nodeUnlockCost) ? true : false;

			//decl String:sTalentsRequired[64];
			char formattedTalentsRequired[64];
			//FormatKeyValue(sTalentsRequired, sizeof(sTalentsRequired), PurchaseKeys[client], PurchaseValues[client], "talents required?");
			int requirementsRemaining = GetKeyValueIntAtPos(PurchaseValues[client], NUM_TALENTS_REQ);
			int requiredCopy = requirementsRemaining;
			requirementsRemaining = TalentRequirementsMet(client, PurchaseKeys[client], PurchaseValues[client], formattedTalentsRequired, sizeof(formattedTalentsRequired), requirementsRemaining);
			int optionsRemaining = TalentRequirementsMet(client, PurchaseKeys[client], PurchaseValues[client], _, -1);	// -1 for size gets the count remaining
			if (bIsLayerEligible || requirementsRemaining >= 1) {
				if (requirementsRemaining <= 0) Format(text, sizeof(text), "%T", "Insert Talent Upgrade", client, 1);
				else if (requirementsRemaining >= 1) {
					if (requirementsRemaining > 1) {
						if (requiredCopy == optionsRemaining) Format(text, sizeof(text), "%T", "node locked by talents all (talentview)", client, formattedTalentsRequired);
						else Format(text, sizeof(text), "%T", "node locked by talents multiple (talentview)", client, formattedTalentsRequired, requirementsRemaining);
					} else {
						if (optionsRemaining == 1) Format(text, sizeof(text), "%T", "node locked by talents last one (talentview)", client, formattedTalentsRequired);
						else Format(text, sizeof(text), "%T", "node locked by talents single (talentview)", client, formattedTalentsRequired, requirementsRemaining);
					}
				}
				menu.DrawItem(text);
			}
		}
		else {
			Format(text, sizeof(text), "%T", "Refund Talent Upgrade", client, 1);
			menu.DrawItem(text);
		}
	}
	else if (TalentType > 0)  {

		// draw the talent type 1 leveling information and a return option only.
		int talentlevel = GetTalentLevel(client, TalentName);

		int iTalentExperience = GetTalentLevel(client, TalentName, true);
		char talentexperience[64];
		AddCommasToString(iTalentExperience, talentexperience, sizeof(talentexperience));

		int iTalentRequirement = CheckExperienceRequirementTalents(client, TalentName);
		char talentrequirement[64];
		AddCommasToString(iTalentRequirement, talentrequirement, sizeof(talentrequirement));

		char theExperienceBar[64];
		MenuExperienceBar(client, iTalentExperience, iTalentRequirement, theExperienceBar, sizeof(theExperienceBar));
		Format(text, sizeof(text), "%T", "cartel experience screen", client, talentlevel, talentexperience, talentrequirement, TalentName_Temp, theExperienceBar);
		menu.DrawText(text);
	}
	int talentCombatStatesAllowed = GetKeyValueIntAtPos(PurchaseValues[client], COMBAT_STATE_REQ);
	if (talentCombatStatesAllowed >= 0) {
		if (talentCombatStatesAllowed == 1) Format(text, sizeof(text), "%T", "in combat state required", client);
		else Format(text, sizeof(text), "%T", "no combat state required", client);
		menu.DrawText(text);
	}
	Format(text, sizeof(text), "%T", "return to talent menu", client);
	menu.DrawItem(text);

	if (GetKeyValueIntAtPos(PurchaseValues[client], HIDE_TRANSLATION) != 1) {
		//	Talents now have a brief description of what they do on their purchase page.
		//	This variable is pre-determined and calls a translation file in the language of the player.
		GetTranslationOfTalentName(client, TalentName, TalentNameTranslation, sizeof(TalentNameTranslation));
		//Format(TalentInfo, sizeof(TalentInfo), "%s", GetTranslationOfTalentName(client, TalentName));
		float rollChance = GetKeyValueFloatAtPos(PurchaseValues[client], TALENT_ROLL_CHANCE);
		float fPercentageHealthRequired = GetKeyValueFloatAtPos(PurchaseValues[client], HEALTH_PERCENTAGE_REQ_MISSING);
		float fPercentageHealthRequiredBelow = GetKeyValueFloatAtPos(PurchaseValues[client], HEALTH_PERCENTAGE_REQ);
		float fCoherencyRange = GetKeyValueFloatAtPos(PurchaseValues[client], COHERENCY_RANGE);
		float fTargetRangeRequired = GetKeyValueFloatAtPos(PurchaseValues[client], TARGET_RANGE_REQUIRED);
		int iCoherencyMax = GetKeyValueIntAtPos(PurchaseValues[client], COHERENCY_MAX);
		if (fPercentageHealthRequired > 0.0 || fPercentageHealthRequiredBelow > 0.0 || fCoherencyRange > 0.0 || fTargetRangeRequired > 0.0) {
			float fPercentageHealthRequiredMax = GetKeyValueFloatAtPos(PurchaseValues[client], HEALTH_PERCENTAGE_REQ_MISSING_MAX);
			Format(TalentInfo, sizeof(TalentInfo), "%T", TalentNameTranslation, client, fPercentageHealthRequired * 100.0, pct, fPercentageHealthRequiredMax * 100.0, pct, fPercentageHealthRequiredBelow * 100.0, pct, fCoherencyRange, iCoherencyMax, fTargetRangeRequired);
		}
		else if (TalentType <= 0 && rollChance > 0.0) {
			Format(text, sizeof(text), "%3.2f%s", rollChance * 100.0, pct);
			Format(TalentInfo, sizeof(TalentInfo), "%T", TalentNameTranslation, client, text);
		}
		else Format(TalentInfo, sizeof(TalentInfo), "%T", TalentNameTranslation, client);

		menu.DrawText(TalentInfo);	// rawline means not a selectable option.
	}
	if (AbilityTalent == 1) {

		GetAbilityText(client, text, sizeof(text), PurchaseKeys[client], PurchaseValues[client]);
		if (!StrEqual(text, "-1")) menu.DrawText(text);
		GetAbilityText(client, text, sizeof(text), PurchaseKeys[client], PurchaseValues[client], ABILITY_PASSIVE_EFFECT);
		if (!StrEqual(text, "-1")) menu.DrawText(text);
		GetAbilityText(client, text, sizeof(text), PurchaseKeys[client], PurchaseValues[client], ABILITY_TOGGLE_EFFECT);
		if (!StrEqual(text, "-1")) menu.DrawText(text);
		GetAbilityText(client, text, sizeof(text), PurchaseKeys[client], PurchaseValues[client], ABILITY_COOLDOWN_EFFECT);
		if (!StrEqual(text, "-1")) menu.DrawText(text);
	}
	if (AbilityType == 1) {	// show the player what the buff shows as on the buff bar because we aren't monsters like Fatshark.
		FormatEffectOverTimeBuffs(client, text, sizeof(text), GetTalentPosition(client, TalentName));
		if (!StrEqual(text, "-1")) {
			Format(text, sizeof(text), "%T", "buff visual display text", client, text);
			menu.DrawText(text);
		}
	}
	int isCompoundingTalent = GetKeyValueInt(PurchaseKeys[client], PurchaseValues[client], "compounding talent?");	// -1 if no value is provided.
	if (isCompoundingTalent == 1) {
		Format(text, sizeof(text), "%T", "compounding talent info", client);
		menu.DrawText(text);
	}
	if (IsEffectOverTime) {
		Format(text, sizeof(text), "%T", "effect over time talent info", client);
		menu.DrawText(text);
	}
	return menu;
}

stock void GetAbilityText(int client, char[] TheString, int TheSize, Handle Keys, Handle Values, int pos = ABILITY_ACTIVE_EFFECT) {

	char text[512], text2[512], tDraft[512], AbilityType[64], TheMaximumMultiplier[64];
	float TheAbilityMultiplier = 0.0;
	char pct[4];
	Format(pct, sizeof(pct), "%");
	Values.GetString(pos, text, sizeof(text));
	if (StrEqual(text, "-1")) {

		Format(TheString, TheSize, "-1");
		return;
	}

	if (pos == ABILITY_ACTIVE_EFFECT) {

		Format(tDraft, sizeof(tDraft), "%T", "Active Effects", client);
		Format(AbilityType, sizeof(AbilityType), "Active Ability");
		TheAbilityMultiplier = GetKeyValueFloatAtPos(Values, ABILITY_ACTIVE_STRENGTH);

		Format(TheMaximumMultiplier, sizeof(TheMaximumMultiplier), "active");
	}
	else if (pos == ABILITY_PASSIVE_EFFECT) {

		Format(tDraft, sizeof(tDraft), "%T", "Passive Effects", client);
		Format(AbilityType, sizeof(AbilityType), "Passive Ability");
		TheAbilityMultiplier = GetKeyValueFloatAtPos(Values, ABILITY_PASSIVE_STRENGTH);

		Format(TheMaximumMultiplier, sizeof(TheMaximumMultiplier), "passive");
	}
	else if (pos == ABILITY_COOLDOWN_EFFECT) {

		Format(tDraft, sizeof(tDraft), "%T", "Cooldown Effects", client);
		Format(AbilityType, sizeof(AbilityType), "Cooldown Ability");
		TheAbilityMultiplier = GetKeyValueFloatAtPos(Values, ABILITY_COOLDOWN_STRENGTH);

		Format(TheMaximumMultiplier, sizeof(TheMaximumMultiplier), "cooldown");
	}
	else {

		Format(tDraft, sizeof(tDraft), "%T", "Toggle Effects", client);
		Format(AbilityType, sizeof(AbilityType), "Toggle Ability");
		TheAbilityMultiplier = GetKeyValueFloatAtPos(Values, ABILITY_TOGGLE_STRENGTH);
	}
	Format(text2, sizeof(text2), "%s %s", text, AbilityType);
	int isReactive = GetKeyValueIntAtPos(Values, ABILITY_IS_REACTIVE);
	if (isReactive == 1) {
		Format(text2, sizeof(text2), "%T", text2, client);
	}
	else {
		if (StrEqual(text, "C", true)) {

			Format(TheMaximumMultiplier, sizeof(TheMaximumMultiplier), "maximum %s multiplier?", TheMaximumMultiplier);
			float MaxMult = GetKeyValueFloat(Keys, Values, TheMaximumMultiplier, _, _, TALENT_FIRST_RANDOM_KEY_POSITION);
			Format(text2, sizeof(text2), "%T", text2, client, TheAbilityMultiplier * 100.0, pct, MaxMult * 100.0, pct);
		}
		else if (TheAbilityMultiplier > 0.0 || StrEqual(text, "S", true)) {

			Format(text2, sizeof(text2), "%T", text2, client, TheAbilityMultiplier * 100.0, pct);
		}
		else {

			Format(text2, sizeof(text2), "%s Disabled", text);
			Format(text2, sizeof(text2), "%T", text2, client);
		}
	}
	Format(tDraft, sizeof(tDraft), "%s\n%s", tDraft, text2);
	if (pos == ABILITY_ACTIVE_EFFECT) {

		Values.GetString(ABILITY_COOLDOWN, text, sizeof(text));

		TheAbilityMultiplier = GetAbilityMultiplier(client, "L");
		if (TheAbilityMultiplier != -1.0) {

			if (TheAbilityMultiplier < 0.0) TheAbilityMultiplier = 0.1;
			else if (TheAbilityMultiplier > 0.0) { //cooldowns are reduced

				Format(text, sizeof(text), "%3.0f", StringToFloat(text) - (StringToFloat(text) * TheAbilityMultiplier));
			}
		}

		//Format(text, sizeof(text), "%3.3f", StringToFloat(text))
		if (!StrEqual(text, "-1")) Format(text, sizeof(text), "%T", "Ability Cooldown", client, text);
		else Format(text, sizeof(text), "%T", "No Ability Cooldown", client);

		Values.GetString(ABILITY_ACTIVE_TIME, text2, sizeof(text2));
		if (!StrEqual(text2, "-1")) Format(text2, sizeof(text2), "%T", "Ability Active Time", client, text2);
		else Format(text2, sizeof(text2), "%T", "Instant Ability", client);

		Format(TheString, TheSize, "%s\n%s\n%s", text, text2, tDraft);
	}
	else Format(TheString, TheSize, "%s", tDraft);
}

stock int GetTalentLevel(int client, char[] TalentName, bool IsExperience = false) {

	int pos = GetTalentPosition(client, TalentName);
	int value = 0;

	if (IsExperience) {

		value = a_Database_PlayerTalents_Experience[client].Get(pos);
		if (value < 0) {

			value = 0;
			a_Database_PlayerTalents_Experience[client].Set(pos, value);
		}
	}
	else {

		value = a_Database_PlayerTalents[client].Get(pos);
		if (value < 0) {

			value = 0;
			a_Database_PlayerTalents[client].Set(pos, value);
		}
	}
	return value;
}

public Handle TalentInfoScreen_Special (int client) {

	char TalentName[64];
	Format(TalentName, sizeof(TalentName), "%s", PurchaseTalentName[client]);

	Handle menu = new Panel();

	int AbilityTalent			= GetKeyValueInt(PurchaseKeys[client], PurchaseValues[client], "is ability?");
	int TalentPointAmount		= GetTalentStrength(client, TalentName);
	int TalentPointMaximum		= 1;

	char TalentIdCode[64];
	char theval[64];
	FormatKeyValue(theval, sizeof(theval), PurchaseKeys[client], PurchaseValues[client], "id_number");
	Format(TalentIdCode, sizeof(TalentIdCode), "%T", "Talent Id Code", client);
	Format(TalentIdCode, sizeof(TalentIdCode), "%s: %s", TalentIdCode, theval);

	

	//	We copy the talent name to another string so we can show the talent in the language of the player.
	
	char TalentName_Temp[64];
	GetTranslationOfTalentName(client, TalentName, TalentName_Temp, sizeof(TalentName_Temp), _, true);
	Format(TalentName_Temp, sizeof(TalentName_Temp), "%T", TalentName_Temp, client);

	

	//	Talents now have a brief description of what they do on their purchase page.
	//	This variable is pre-determined and calls a translation file in the language of the player.
	
	char TalentInfo[128], text[512];

	if (AbilityTalent != 1) {

		GetTranslationOfTalentName(client, TalentName, TalentInfo, sizeof(TalentInfo));

		//Format(TalentInfo, sizeof(TalentInfo), "%s", GetTranslationOfTalentName(client, TalentName));
		Format(TalentInfo, sizeof(TalentInfo), "%T", TalentInfo, client);

		if (FreeUpgrades[client] == 0) Format(text, sizeof(text), "%T", "Talent Upgrade Title", client, TalentName_Temp, TalentPointAmount, TalentPointMaximum);
		else Format(text, sizeof(text), "%T", "Talent Upgrade Title Free", client, TalentName_Temp, TalentPointAmount, TalentPointMaximum, FreeUpgrades[client]);
		menu.SetTitle(text);

		float fltime = GetSpecialAmmoStrength(client, TalentName);
		float fltimen = GetSpecialAmmoStrength(client, TalentName, 0, true);

		Format(text, sizeof(text), "%T", "Special Ammo Time", client, fltime, fltimen);
		menu.DrawText(text);
		//Format(text, sizeof(text), "%T", "Special Ammo Interval", client, GetSpecialAmmoStrength(client, TalentName, 4), GetSpecialAmmoStrength(client, TalentName, 4, true));
		//menu.DrawText(text);
		Format(text, sizeof(text), "%T", "Special Ammo Cooldown", client, fltime + GetSpecialAmmoStrength(client, TalentName, 1), fltimen + GetSpecialAmmoStrength(client, TalentName, 1, true));
		menu.DrawText(text);
		Format(text, sizeof(text), "%T", "Special Ammo Stamina", client, RoundToCeil(GetSpecialAmmoStrength(client, TalentName, 2)), RoundToCeil(GetSpecialAmmoStrength(client, TalentName, 2, true)));
		menu.DrawText(text);
		Format(text, sizeof(text), "%T", "Special Ammo Range", client, GetSpecialAmmoStrength(client, TalentName, 3), GetSpecialAmmoStrength(client, TalentName, 3, true));
		menu.DrawText(text);
		menu.DrawText(TalentIdCode);
	}
	else {

		//decl String:tTalentStatus[64];
		GetTranslationOfTalentName(client, TalentName, TalentInfo, sizeof(TalentInfo), _, true);
		Format(TalentInfo, sizeof(TalentInfo), "%T", TalentInfo, client);
		//if (TalentPointAmount < 1) Format(tTalentStatus, sizeof(tTalentStatus), "%T", "ability locked translation", client);
		//else Format(tTalentStatus, sizeof(tTalentStatus), "%T", "ability unlocked translation", client);
		//Format(TalentInfo, sizeof(TalentInfo), "%s (%s)", TalentInfo, tTalentStatus);
		menu.DrawText(TalentInfo);
	}

	// We only have the option to assign it to action bars, instead.
	char ActionBarText[64], CommandText[64];
	GetConfigValue(CommandText, sizeof(CommandText), "action slot command?");
	int ActionBarSize = ActionBar[client].Length;

	for (int i = 0; i < ActionBarSize; i++) {
		ActionBar[client].GetString(i, ActionBarText, sizeof(ActionBarText));
		if (!IsTalentExists(ActionBarText)) Format(ActionBarText, sizeof(ActionBarText), "%T", "No Action Equipped", client);
		else {
			GetTranslationOfTalentName(client, ActionBarText, ActionBarText, sizeof(ActionBarText), _, true);
			Format(ActionBarText, sizeof(ActionBarText), "%T", ActionBarText, client);
		}
		Format(text, sizeof(text), "%T", "Assign to Action Bar", client, CommandText, i + 1, ActionBarText);
		menu.DrawItem(text);
	}
	
	Format(text, sizeof(text), "%T", "return to talent menu", client);
	menu.DrawItem(text);
	if (AbilityTalent == 1) {

		GetAbilityText(client, text, sizeof(text), PurchaseKeys[client], PurchaseValues[client]);
		if (!StrEqual(text, "-1")) menu.DrawText(text);
		GetAbilityText(client, text, sizeof(text), PurchaseKeys[client], PurchaseValues[client], ABILITY_PASSIVE_EFFECT);
		if (!StrEqual(text, "-1")) menu.DrawText(text);
		GetAbilityText(client, text, sizeof(text), PurchaseKeys[client], PurchaseValues[client], ABILITY_TOGGLE_EFFECT);
		if (!StrEqual(text, "-1")) menu.DrawText(text);
		GetAbilityText(client, text, sizeof(text), PurchaseKeys[client], PurchaseValues[client], ABILITY_COOLDOWN_EFFECT);
		if (!StrEqual(text, "-1")) menu.DrawText(text);
	}
	else menu.DrawText(TalentInfo);	// rawline means not a selectable option.
	return menu;
}

public TalentInfoScreen_Init (Handle topmenu, MenuAction action, client, param2)
{
	if (action == MenuAction_Select)
	{
		int MaxPoints = 1;	// all talents have a minimum of 1 max points, including spells and abilities.
		int TalentStrength = GetTalentStrength(client, PurchaseTalentName[client]);
		char TalentName[64];
		Format(TalentName, sizeof(TalentName), "%s", PurchaseTalentName[client]);
		int TalentType = GetKeyValueIntAtPos(PurchaseValues[client], IS_TALENT_TYPE);
		int AbilityTalent = GetKeyValueIntAtPos(PurchaseValues[client], IS_TALENT_ABILITY);

		//decl String:sTalentsRequired[64];
		//FormatKeyValue(sTalentsRequired, sizeof(sTalentsRequired), PurchaseKeys[client], PurchaseValues[client], "talents required?");
		int requiredTalentsRequired = GetKeyValueIntAtPos(PurchaseValues[client], NUM_TALENTS_REQ);
		if (requiredTalentsRequired > 0) requiredTalentsRequired = TalentRequirementsMet(client, PurchaseKeys[client], PurchaseValues[client], _, _, requiredTalentsRequired);
		
		int nodeUnlockCost = 1;
		bool isNodeCostMet = (UpgradesAvailable[client] + FreeUpgrades[client] >= nodeUnlockCost) ? true : false;
		int currentLayer = GetKeyValueIntAtPos(PurchaseValues[client], GET_TALENT_LAYER);
		//new ignoreLayerCount = GetKeyValueInt(PurchaseKeys[client], PurchaseValues[client], "ignore for layer count?");
		int ignoreLayerCount = (GetKeyValueIntAtPos(PurchaseValues[client], LAYER_COUNTING_IS_IGNORED) == 1) ? 1 :
								   (GetKeyValueIntAtPos(PurchaseValues[client], IS_ATTRIBUTE) == 1) ? 1 : 0;	// attributes both count towards the layer requirements and can be unlocked when the layer requirements are met.

		bool bIsLayerEligible = (TalentStrength > 0) ? true : false;
		if (!bIsLayerEligible) {
			bIsLayerEligible = (requiredTalentsRequired < 1 && (PlayerCurrentMenuLayer[client] <= 1 || GetLayerUpgradeStrength(client, PlayerCurrentMenuLayer[client] - 1) >= PlayerCurrentMenuLayer[client])) ? true : false;
			if (bIsLayerEligible) bIsLayerEligible = ((ignoreLayerCount == 1 || GetLayerUpgradeStrength(client, PlayerCurrentMenuLayer[client], _, _, _, _, true) < PlayerCurrentMenuLayer[client] + 1) && UpgradesAvailable[client] + FreeUpgrades[client] >= nodeUnlockCost) ? true : false;
		}
		/*if (AbilityTalent == 1 && bActionBarMenuRequest) {

			new ActionBarSize = Handle:ActionBar[client].Length;

			if (param2 > ActionBarSize) BuildSubMenu(client, OpenedMenu[client], MenuSelection[client]);
			else {

				if (!SwapActions(client, PurchaseTalentName[client], param2 - 1)) Handle:ActionBar[client].SetString(param2 - 1, PurchaseTalentName[client]);
				SendPanelToClientAndClose(TalentInfoScreen(client), client, TalentInfoScreen_Init, MENU_TIME_FOREVER);
			}
			//SendPanelToClientAndClose(TalentInfoScreen(client), client, TalentInfoScreen_Init, MENU_TIME_FOREVER);
		}*/
		if (TalentType <= 0 || AbilityTalent == 1) {

			switch (param2)
			{
				case 1: {

					if (bIsLayerEligible) {
						if (TalentType <= 0) {
							if (TalentStrength == 0) {
								if (UpgradesAvailable[client] + FreeUpgrades[client] < nodeUnlockCost) BuildSubMenu(client, OpenedMenu[client], MenuSelection[client]);
								else if (isNodeCostMet && TalentStrength + 1 <= MaxPoints) {
								//else if ((UpgradesAvailable[client] > 0 || FreeUpgrades[client] > 0) && TalentStrength + 1 <= MaxPoints) {
									if (UpgradesAvailable[client] >= nodeUnlockCost) {
										TryToTellPeopleYouUpgraded(client);
										UpgradesAvailable[client] -= nodeUnlockCost;
										PlayerLevelUpgrades[client]++;
									}
									else if (FreeUpgrades[client] >= nodeUnlockCost) FreeUpgrades[client] -= nodeUnlockCost;
									else {
										nodeUnlockCost -= FreeUpgrades[client];
										UpgradesAvailable[client] -= nodeUnlockCost;
									}
									PlayerUpgradesTotal[client]++;
									PurchaseTalentPoints[client]++;
									AddTalentPoints(client, PurchaseTalentName[client], PurchaseTalentPoints[client]);
									SendPanelToClientAndClose(TalentInfoScreen(client), client, TalentInfoScreen_Init, MENU_TIME_FOREVER);
								}
							}
							else {
								PlayerUpgradesTotal[client]--;
								PurchaseTalentPoints[client]--;
								FreeUpgrades[client] += nodeUnlockCost;
								AddTalentPoints(client, PurchaseTalentName[client], PurchaseTalentPoints[client]);

								// Check if locking this node makes them ineligible for deeper trees, and remove points
								// in those talents if it's the case, locking the nodes.
								GetLayerUpgradeStrength(client, currentLayer, true);
								SendPanelToClientAndClose(TalentInfoScreen(client), client, TalentInfoScreen_Init, MENU_TIME_FOREVER);
							}
						}
						else {
							BuildSubMenu(client, OpenedMenu[client], MenuSelection[client]);
						}
					}
					else {

						BuildSubMenu(client, OpenedMenu[client], MenuSelection[client]);
					}
				}
				case 2: {

					BuildSubMenu(client, OpenedMenu[client], MenuSelection[client]);
				}
			}
		}
	}
	if (action == MenuAction_End)
	{
		delete topmenu;
	}
	/*else if (topmenu != INVALID_HANDLE)
	{
		delete topmenu;
	}*/
}

public TalentInfoScreen_Special_Init (Handle topmenu, MenuAction action, client, param2)
{
	if (action == MenuAction_Select)
	{
		int ActionBarSize = ActionBar[client].Length;

		if (param2 > ActionBarSize) {

			BuildSubMenu(client, OpenedMenu[client], MenuSelection[client]);
		}
		else {
			//																	Abilities now require an upgrade point in their node in order to be used.
			if (!SwapActions(client, PurchaseTalentName[client], param2 - 1) && GetTalentStrength(client, PurchaseTalentName[client]) > 0) ActionBar[client].SetString(param2 - 1, PurchaseTalentName[client]);
			SendPanelToClientAndClose(TalentInfoScreen_Special(client), client, TalentInfoScreen_Special_Init, MENU_TIME_FOREVER);
		}
		//delete topmenu;
	}
	if (action == MenuAction_End) {

		delete topmenu;
	}
}

bool SwapActions(int client, char[] TalentName, int slot) {

	char text[64], text2[64];

	int size = ActionBar[client].Length;
	for (int i = 0; i < size; i++) {

		ActionBar[client].GetString(i, text, sizeof(text));
		if (StrEqual(TalentName, text)) {

			ActionBar[client].GetString(slot, text2, sizeof(text2));

			ActionBar[client].SetString(i, text2);
			ActionBar[client].SetString(slot, text);

			return true;
		}
	}
	return false;
}

stock TryToTellPeopleYouUpgraded(int client) {

	if (FreeUpgrades[client] == 0 && GetConfigValueInt("display when players upgrade to team?") == 1) {

		char text2[64];
		char PlayerName[64];
		char translationText[64];
		GetClientName(client, PlayerName, sizeof(PlayerName));
		GetTranslationOfTalentName(client, PurchaseTalentName[client], translationText, sizeof(translationText), true);
		for (int k = 1; k <= MaxClients; k++) {

			if (IsLegitimateClient(k) && !IsFakeClient(k) && GetClientTeam(k) == GetClientTeam(client)) {

				Format(text2, sizeof(text2), "%T", translationText, k);
				if (GetClientTeam(client) == TEAM_SURVIVOR) PrintToChat(k, "%T", "Player upgrades ability", k, blue, PlayerName, white, green, text2, white);
				else if (GetClientTeam(client) == TEAM_INFECTED) PrintToChat(k, "%T", "Player upgrades ability", k, orange, PlayerName, white, green, text2, white);
			}
		}
	}
}

stock int FindTalentPoints(int client, char[] Name) {

	char text[64];

	int a_Size							=	a_Database_Talents.Length;

	for (int i = 0; i < a_Size; i++) {

		a_Database_Talents.GetString(i, text, sizeof(text));

		if (StrEqual(text, Name)) {

			if (client != -1) a_Database_PlayerTalents[client].GetString(i, text, sizeof(text));
			else a_Database_PlayerTalents_Bots.GetString(i, text, sizeof(text));
			return StringToInt(text);
		}
	}
	//return -1;	// this is to let us know to setfailstate.
	return 0;	// this will be removed. only for testing.
}

stock void AddTalentPoints(int client, char[] Name, int TalentPoints) {

	if (!IsLegitimateClient(client)) return;
	
	char text[64];
	int a_Size							=	a_Database_Talents.Length;

	for (int i = 0; i < a_Size; i++) {

		a_Database_Talents.GetString(i, text, sizeof(text));

		if (StrEqual(text, Name)) {

			a_Database_PlayerTalents[client].Set(i, TalentPoints);
			return;
		}
	}
}

stock void UnlockTalent(client, char[] Name, bool bIsEndOfMapRoll = false, bool bIsLegacy = false) {

	char text[64];
	char PlayerName[64];
	GetClientName(client, PlayerName, sizeof(PlayerName));

	int size			= a_Database_Talents.Length;

	for (int i = 0; i < size; i++) {

		a_Database_Talents.GetString(i, text, sizeof(text));
		if (StrEqual(text, Name)) {

			a_Database_PlayerTalents[client].Set(i, 0);

			if (!bIsLegacy) {		// We advertise elsewhere if it's a legacy roll.

				for (int ii = 1; ii <= MaxClients; ii++) {

					if (IsClientInGame(ii) && !IsFakeClient(ii)) {

						Format(text, sizeof(text), "%T", Name, ii);
						if (!bIsEndOfMapRoll) PrintToChat(ii, "%T", "Locked Talent Award", ii, blue, PlayerName, white, orange, text, white);
						else PrintToChat(ii, "%T", "Locked Talent Award (end of map roll)", ii, blue, PlayerName, white, orange, text, white, white, orange, white);
					}
				}
			}
			break;
		}
	}
}

stock bool IsTalentExists(char[] Name) {

	char text[64];
	int size			= a_Database_Talents.Length;
	for (int i = 0; i < size; i++) {

		a_Database_Talents.GetString(i, text, sizeof(text));
		if (StrEqual(text, Name)) return true;
	}
	return false;
}

stock bool IsTalentLocked(int client, char[] Name) {

	int value = 0;
	char text[64];

	int size			= a_Database_Talents.Length;

	for (int i = 0; i < size; i++) {

		a_Database_Talents.GetString(i, text, sizeof(text));
		if (StrEqual(text, Name)) {

			value = a_Database_PlayerTalents[client].Get(i);

			if (value >= 0) return false;
			break;
		}
	}

	return true;
}

stock WipeTalentPoints(int client) {

	if (!IsLegitimateClient(client) || IsFakeClient(client)) return;

	UpgradesAwarded[client] = 0;

	int size							= a_Menu_Talents.Length;

	int value = 0;

	for (int i = 0; i < size; i++) {	// We only reset talents a player has points in, so locked talents don't become unlocked.
		//TalentTreeKeys[client]			= a_Menu_Talents.Get(i, 0);
		//TalentTreeValues[client]		= a_Menu_Talents.Get(i, 1);

		value = a_Database_PlayerTalents[client].Get(i);
		if (value > 0)	a_Database_PlayerTalents[client].Set(i, 0);
	}
}

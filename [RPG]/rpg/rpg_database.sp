/* put the line below after all of the includes!
#pragma newdecls required
*/

void MySQL_Init()
{
	if (hDatabase != INVALID_HANDLE) return;	// already connected.
	//hDatabase														=	INVALID_HANDLE;

	GetConfigValue(TheDBPrefix, sizeof(TheDBPrefix), "database prefix?");
	GetConfigValue(Hostname, sizeof(Hostname), "server name?");
	if (GetConfigValueInt("friendly fire enabled?") == 1) ReplaceString(Hostname, sizeof(Hostname), "{FF}", "FF ON");
	else ReplaceString(Hostname, sizeof(Hostname), "{FF}", "FF OFF");
	if (StrContains(Hostname, "{V}", true) != -1) ReplaceString(Hostname, sizeof(Hostname), "{V}", PLUGIN_VERSION);

	iServerLevelRequirement		= GetConfigValueInt("server level requirement?");
	RatingPerLevel				= GetConfigValueInt("rating level multiplier?");
	InfectedTalentLevel			= GetConfigValueInt("talent level multiplier?");
	fEnrageModifier				= GetConfigValueFloat("enrage modifier?");

	if (iServerLevelRequirement > 0) {

		if (StrContains(Hostname, "{RS}", true) != -1) {

			char HostLevels[64];
			//Format(HostLevels, sizeof(HostLevels), "Lv%s(TruR%s)", AddCommasToString(iServerLevelRequirement), AddCommasToString(iServerLevelRequirement * RatingPerLevel));
			Format(HostLevels, sizeof(HostLevels), "Lv%d+", iServerLevelRequirement);
			ReplaceString(Hostname, sizeof(Hostname), "{RS}", HostLevels);
		}
	}
	//Format(sHostname, sizeof(sHostname), "%s", Hostname);

	GetConfigValue(RatingType, sizeof(RatingType), "db record?");
	if (StrEqual(RatingType, "-1")) {

		if (ReadyUp_GetGameMode() == 3) Format(RatingType, sizeof(RatingType), "%s", SURVRECORD_DB);
		else Format(RatingType, sizeof(RatingType), "%s", COOPRECORD_DB);
	}

	//LogMessage("Setting hostname %s", Hostname);
	ServerCommand("hostname %s", Hostname);
	//SetSurvivorsAliveHostname();
	Database.Connect(DBConnect, TheDBPrefix);
}

stock void SetSurvivorsAliveHostname() {

	static char Newhost[64];
	Format(Newhost, sizeof(Newhost), "%s", sHostname);
	if (b_IsActiveRound) Format(Newhost, sizeof(Newhost), "%s - %d alive", sHostname, LivingSurvivors());
	else Format(Newhost, sizeof(Newhost), "%s - Intermission", sHostname);
	ServerCommand("hostname %s", Newhost);
}

public void ReadyUp_GroupMemberStatus(int client, int groupStatus) {

	if (IsLegitimateClient(client)) {
		if (HasCommandAccess(client, "donator package flag?") || groupStatus == 1) IsGroupMember[client] = true;
		else IsGroupMember[client] = false;

		CheckGroupStatus(client);
	}
}

public void DBConnect(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == INVALID_HANDLE)
	{
		LogMessage("Unable to connect to database: %s", error);
		SetFailState("%s", error);
	}

	hDatabase = hndl;

	int GenerateDB = GetConfigValueInt("generate database?");
	
	char tquery[PLATFORM_MAX_PATH];
	char text[64];
	
	if (GenerateDB == 1) {

		//Format(tquery, sizeof(tquery), "SET NAMES 'UTF8';");
		//hDatabase.Query(QueryResults, tquery);
		//Format(tquery, sizeof(tquery), "SET CHARACTER SET utf8;");
		//hDatabase.Query(QueryResults, tquery);

		//Format(tquery, sizeof(tquery), "CREATE TABLE IF NOT EXISTS `%s_maps` (`mapname` varchar(64) NOT NULL, PRIMARY KEY (`mapname`)) ENGINE=MyISAM;", TheDBPrefix);
		//hDatabase.Query(QueryResults, tquery);

		Format(tquery, sizeof(tquery), "CREATE TABLE IF NOT EXISTS `%s` (`steam_id` varchar(64) NOT NULL, PRIMARY KEY (`steam_id`)) ENGINE=InnoDB;", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` CHARACTER SET utf8 COLLATE utf8_general_ci;", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `primarywep` varchar(32) NOT NULL DEFAULT 'none';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `secondwep` varchar(32) NOT NULL DEFAULT 'none';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `exp` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `expov` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `upgrade cost` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `level` int(32) NOT NULL DEFAULT '1';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `skylevel` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);

		GetConfigValue(text, sizeof(text), "sky points menu name?");
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `%s` int(32) NOT NULL DEFAULT '0';", TheDBPrefix, text);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `time played` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `talent points` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `total upgrades` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `free upgrades` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `restt` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `restexp` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `lpl` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `resr` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `survpoints` varchar(32) NOT NULL DEFAULT '0.0';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `bec` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `rem` varchar(32) NOT NULL DEFAULT '0.0';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `%s` int(32) NOT NULL DEFAULT '0';", TheDBPrefix, COOPRECORD_DB);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `%s` int(32) NOT NULL DEFAULT '0';", TheDBPrefix, SURVRECORD_DB);
		hDatabase.Query(QueryResults, tquery);
		GetConfigValue(text, sizeof(text), "db record?");
		if (!StrEqual(text, "-1")) {

			Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `%s` int(32) NOT NULL DEFAULT '0';", TheDBPrefix, text);
			hDatabase.Query(QueryResults, tquery);
		}
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `myrating %s` int(32) NOT NULL DEFAULT '0';", TheDBPrefix, RatingType);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `ratinghc %s` int(32) NOT NULL DEFAULT'0';", TheDBPrefix, RatingType);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `pri` int(32) NOT NULL DEFAULT '1';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `tcolour` varchar(32) NOT NULL DEFAULT 'none';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `tname` varchar(32) NOT NULL DEFAULT 'none';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `ccolour` varchar(32) NOT NULL DEFAULT 'none';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		//Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `mapname` varchar(32) NOT NULL DEFAULT 'none';", TheDBPrefix);
		//hDatabase.Query(QueryResults, tquery);

		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `xpdebt` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `upav` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `upawarded` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);

		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `companionname` varchar(32) NOT NULL DEFAULT 'survivor';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `companionowner` varchar(32) NOT NULL DEFAULT 'survivor';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);

		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `lastserver` varchar(64) NOT NULL DEFAULT 'none';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `myseason` varchar(32) NOT NULL DEFAULT 'none';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);

		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `lvlpaused` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `itrails` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);

		/*
			weapon levels
			\\rewarding players who use a specific weapon category with increased proficiency in that category.
		*/
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `pistol_xp` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `melee_xp` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `uzi_xp` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		/*
			has both pump and auto shotgun tiers
		*/
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `shotgun_xp` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `sniper_xp` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `assault_xp` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);

		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `medic_xp` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `grenade_xp` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);


		Format(tquery, sizeof(tquery), "CREATE TABLE IF NOT EXISTS `%s_loot` (`owner_id` varchar(64) NOT NULL, PRIMARY KEY (`owner_id`)) ENGINE=InnoDB;", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s_loot` CHARACTER SET utf8 COLLATE utf8_general_ci;", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s_loot` ADD `constitution` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s_loot` ADD `resilience` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s_loot` ADD `agility` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s_loot` ADD `technique` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s_loot` ADD `endurance` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s_loot` ADD `armor` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s_loot` ADD `talent` varchar(32) NOT NULL DEFAULT 'none';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s_loot` ADD `reference` varchar(32) NOT NULL DEFAULT 'none';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s_loot` ADD `augments` varchar(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s_loot` ADD `value` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s_loot` ADD `forsale` int(4) NOT NULL DEFAULT '0';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s_loot` ADD `itemname` varchar(64) NOT NULL DEFAULT 'none';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);



		int ActionSlotSize = iActionBarSlots;
		for (int i = 0; i < ActionSlotSize; i++) {

			Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `aslot%d` VARCHAR(32) NOT NULL DEFAULT 'None';", TheDBPrefix, i+1);
			hDatabase.Query(QueryResults, tquery);
		}
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `disab` INT(4) NOT NULL DEFAULT '0';", TheDBPrefix);
		hDatabase.Query(QueryResults, tquery);

		/*new size			=	a_Database_Talents.Length;

		for (new i = 0; i < size; i++) {

			Handle:a_Database_Talents.GetString(i, text, sizeof(text));
			Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `%s` int(32) NOT NULL DEFAULT '0';", TheDBPrefix, text);
			hDatabase.Query(QueryResults, tquery);
		}*/
	}

	a_Database_Talents_Defaults.Clear();
	a_Database_Talents_Defaults_Name.Clear();
	//Handle:a_ClassNames.Clear();

	char NewValue[64];

	int size			=	a_Menu_Talents.Length;
	for (int i = 0; i < size; i++) {

		DatabaseKeys			=	a_Menu_Talents.Get(i, 0);
		DatabaseValues			=	a_Menu_Talents.Get(i, 1);
		if (GetKeyValueIntAtPos(DatabaseValues, IS_SUB_MENU_OF_TALENTCONFIG) == 1) continue;

		DatabaseSection			=	a_Menu_Talents.Get(i, 2);

		DatabaseSection.GetString(0, text, sizeof(text));
		a_Database_Talents_Defaults_Name.PushString(text);
		if (GenerateDB == 1) {

			Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `%s` int(32) NOT NULL DEFAULT '0';", TheDBPrefix, text);
			//else Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `%s` int(32) NOT NULL DEFAULT '-1';", TheDBPrefix, text);
			hDatabase.Query(QueryResults, tquery);
		}

		//if (StringToInt(NewValue) < 0) Format(NewValue, sizeof(NewValue), "0");
		a_Database_Talents_Defaults.PushString(NewValue);
	}

	if (GenerateDB == 1) {

		GenerateDB = 0;

		size				=	a_DirectorActions.Length;

		for (int i = 0; i < size; i++) {

			DatabaseSection			=	a_DirectorActions.Get(i, 2);
			DatabaseSection.GetString(0, text, sizeof(text));
			Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `%s` int(32) NOT NULL DEFAULT '0';", TheDBPrefix, text);
			hDatabase.Query(QueryResults, tquery);
		}

		size				=	a_Store.Length;

		for (int i = 0; i < size; i++) {

			DatabaseSection			=	a_Store.Get(i, 2);
			DatabaseSection.GetString(0, text, sizeof(text));
			Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `%s` int(32) NOT NULL DEFAULT '0';", TheDBPrefix, text);
			hDatabase.Query(QueryResults, tquery);
		}
	}

	size = a_Database_Talents.Length;

	a_Database_PlayerTalents_Bots.Resize(size);
	PlayerAbilitiesCooldown_Bots.Resize(size);
	PlayerAbilitiesImmune_Bots.Resize(size);

	GetNodesInExistence();
}

public void QuerySaveNewPlayer(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl == INVALID_HANDLE) {

		if (StrContains(error, "Duplicate column name", false) == -1) LogMessage("QuerySaveNewPlayer Error %s", error);
		return;
	}
	if (IsLegitimateClient(client)) SaveAndClear(client, _, true);
}

public void QueryResults(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl == INVALID_HANDLE) {

		if (StrContains(error, "Duplicate column name", false) == -1) LogMessage("QueryResults Error %s", error);
		return;
	}
}

public void QueryResults1(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl == INVALID_HANDLE) {

		if (StrContains(error, "Duplicate column name", false) == -1) LogMessage("QueryResults1 Error %s", error);
		return;
	}
}

public void QueryResults2(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl == INVALID_HANDLE) {

		if (StrContains(error, "Duplicate column name", false) == -1) LogMessage("QueryResults2 Error %s", error);
		return;
	}
}

public void QueryResults3(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl == INVALID_HANDLE) {

		if (StrContains(error, "Duplicate column name", false) == -1) LogMessage("QueryResults3 Error %s", error);
		return;
	}
}

public void QueryResults4(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl == INVALID_HANDLE) {

		if (StrContains(error, "Duplicate column name", false) == -1) LogMessage("QueryResults4 Error %s", error);
		return;
	}
}

public void QueryResults5(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl == INVALID_HANDLE) {

		if (StrContains(error, "Duplicate column name", false) == -1) LogMessage("QueryResults5 Error %s", error);
		return;
	}
}

public void QueryResults6(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl == INVALID_HANDLE) {

		if (StrContains(error, "Duplicate column name", false) == -1) LogMessage("QueryResults6 Error %s", error);
		return;
	}
}

public void QueryResults7(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl == INVALID_HANDLE) {

		if (StrContains(error, "Duplicate column name", false) == -1) LogMessage("QueryResults7 Error %s", error);
		return;
	}
}

public void QueryResults8(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl == INVALID_HANDLE) {

		if (StrContains(error, "Duplicate column name", false) == -1) LogMessage("QueryResults8 Error %s", error);
		return;
	}
}

stock void LoadLeaderboards(int client, int count) {

	int listpage = GetConfigValueInt("leaderboard players per page?");
	if (count == 0) {

		if (TheLeaderboardsPageSize[client] >= listpage) TheLeaderboardsPage[client] -= listpage;
		else TheLeaderboardsPage[client] = 0;
	}
	else if (TheLeaderboardsPageSize[client] >= listpage) {		// if a page didn't load 10 entries, we don't increment. If a page exactly 10 entries, the next page will be empty and only have a return option.

		TheLeaderboardsPage[client] += listpage;
	}
	char tquery[1024];
	char Mapname[64];
	GetCurrentMap(Mapname, sizeof(Mapname));

	Format(tquery, sizeof(tquery), "SELECT `tname`, `steam_id`, `%s` FROM `%s` ORDER BY `%s` DESC;", RatingType, TheDBPrefix, RatingType);
	hDatabase.Query(LoadLeaderboardsQuery, tquery, client);
}

public void LoadLeaderboardsQuery(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == INVALID_HANDLE)
	{
		LogMessage("[LoadLeaderboardsQuery] %s", error);
		return;
	}
	int i = 0;
	int count = 0;
	int counter = 0;
	int listpage = GetConfigValueInt("leaderboard players per page?");
	Handle LeadName = new ArrayList(16);
	Handle LeadRating = new ArrayList(16);

	if (!bIsMyRanking[data]) {

		LeadName.Resize(listpage);
		LeadRating.Resize(listpage);
	}
	else {

		LeadName.Resize(1);
		LeadRating.Resize(1);
	}
	char text[64];
	//decl String:tquery[1024];
	int Pint = 0;
	int IgnoreRating = RatingPerLevel;
	char SteamID[64];
	GetClientAuthId(data, AuthId_Steam2, SteamID, sizeof(SteamID));
	TheLeaderboards[data].Clear();		// reset the data held when a page is loaded.

	while (i < listpage && hndl.FetchRow())
	{
		hndl.FetchString(1, text, sizeof(text));
		if (bIsMyRanking[data] && !StrEqual(text, SteamID, false)) {

			counter++;
			continue;
		}
		if (StrContains(text, sBotTeam, false) != -1) continue;

		count++;
		counter++;
		if (count < TheLeaderboardsPage[data]) continue;

		Pint = hndl.FetchInt(2);
		if (Pint <= IgnoreRating) {

			count--;
			counter--;
			continue;	// players can un-set their name to hide themselves on the leaderboards.
		}

		/*hndl.FetchString(2, text, sizeof(text));
		if (bIsMyRanking[data] && !StrEqual(text, SteamID, false)) {// ||
			//StrContains(text, "STEAM_", true) == -1) {

			count--;
			//if (StrContains(text, "STEAM_", true) == -1)
			//counter--;
			continue;	// will not display bots rating in the leaderboards.
		}*/

		hndl.FetchString(0, text, sizeof(text));
		if (strlen(text) < 16) {

			if (strlen(text) > 12) Format(text,sizeof(text), "%s\t", text);
			else if (strlen(text) > 8) Format(text,sizeof(text), "%s\t\t\t", text);
			else if (strlen(text) > 4) Format(text,sizeof(text), "%s\t\t\t\t\t\t", text);
			else Format(text,sizeof(text), "%s\t\t\t\t\t\t\t", text);
		}
		Format(text, sizeof(text), "#%d %s", counter, text);

		LeadName.SetString(i, text);

		Pint = hndl.FetchInt(2);
		Format(text, sizeof(text), "%d", Pint);
		LeadRating.SetString(i, text);

		i++;
		if (bIsMyRanking[data]) break;
	}
	//bIsMyRanking[data] = false;

	//new size = TheLeaderboards[data].Length;

	if (!bIsMyRanking[data]) {

		LeadName.Resize(i);
		LeadRating.Resize(i);
	}
	TheLeaderboardsPageSize[data] = i;

	TheLeaderboards[data].Resize(1);
	TheLeaderboards[data].Set(0, LeadName, 0);
	TheLeaderboards[data].Set(0, LeadRating, 1);

	if (TheLeaderboards[data].Length > 0) SendPanelToClientAndClose(DisplayTheLeaderboards(data), data, DisplayTheLeaderboards_Init, MENU_TIME_FOREVER);
	else BuildMenu(data);

	delete LeadName;
	delete LeadRating;
}

stock void ResetData(int client) {

	RefreshSurvivor(client);
	HealingContribution[client] = 0;
	TankingContribution[client] = 0;
	DamageContribution[client] = 0;
	PointsContribution[client] = 0.0;
	HexingContribution[client] = 0;
	BuffingContribution[client] = 0;
	bIsCrushCooldown[client]		= false;
	//Points[client]					= 0.0;
	//SlatePoints[client]				= 0;
	//FreeUpgrades[client]			= 0;
	b_IsDirectorTalents[client]		= false;
	b_IsJumping[client]				= false;
	ModifyGravity(client);
	ResetCoveredInBile(client);
	SpeedMultiplierBase[client]		= 1.0;
	if (IsLegitimateClientAlive(client) && !IsGhost(client)) SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", SpeedMultiplierBase[client]);
	//TimePlayed[client]				= 0;
	t_Distance[client]				= 0;
	t_Healing[client]				= 0;
	b_IsBlind[client]				= false;
	b_IsImmune[client]				= false;
	GravityBase[client]				= 1.0;
	CommonKills[client]				= 0;
	CommonKillsHeadshot[client]		= 0;
	bIsMeleeCooldown[client]		= false;
	shotgunCooldown[client]			= false;
	InfectedHealth[client].Clear();
	PlayerActiveAmmo[client].Clear();
	PlayActiveAbilities[client].Clear();
	ApplyDebuffCooldowns[client].Clear();
	if (ISFROZEN[client] != INVALID_HANDLE) {
		KillTimer(ISFROZEN[client]);
		ISFROZEN[client] = INVALID_HANDLE;
	}
	StrugglePower[client] = 0;
}

stock void ClearAndLoad(int client, bool IgnoreLoad = false) {

	if (hDatabase == INVALID_HANDLE) return;
	//new client = FindClientWithAuthString(key, true);
	if (client < 1) return;

	char key[64];
	GetClientAuthId(client, AuthId_Steam2, key, sizeof(key));

	//if (StrContains(key, "BOT", false) != -1) {
	if (IsFakeClient(client)) {

		char TheName[64];
		GetSurvivorBotName(client, TheName, sizeof(TheName));
		Format(key, 64, "%s%s", sBotTeam, TheName);
	}

	int size = a_Database_Talents.Length;
	if (a_Database_PlayerTalents[client].Length != size) {

		a_Database_PlayerTalents[client].Resize(size);
		PlayerAbilitiesCooldown[client].Resize(size);
		a_Database_PlayerTalents_Experience[client].Resize(size);
			//for (new i = 1; i <= MAXPLAYERS; i++) PlayerAbilitiesImmune[client][i].Resize(size);
	}
	hWeaponList[client].Clear();
	hWeaponList[client].Resize(2);

	char text[64];
	Format(text, sizeof(text), "none");
	hWeaponList[client].SetString(0, text);
	hWeaponList[client].SetString(1, text);
	if (b_IsLoading[client] && !IgnoreLoad) return;
	b_IsLoading[client] = true;
	ResetData(client);

	LoadPos[client] = 0;

	if (!b_IsArraysCreated[client]) {

		b_IsArraysCreated[client]			= true;
	}
	if (a_Store_Player[client].Length != a_Store.Length) {

		a_Store_Player[client].Resize(a_Store.Length);
	}

	for (int i = 0; i < a_Store.Length; i++) {

		a_Store_Player[client].SetString(i, "0");				// We clear all players arrays for the store.
	}
	ChatSettings[client].Resize(3);
	char tquery[2048];
	Format(tquery, sizeof(tquery), "none");
	ChatSettings[client].SetString(0, tquery);
	ChatSettings[client].SetString(1, tquery);
	ChatSettings[client].SetString(2, tquery);

	//LogMessage("Loading %N data", client);

	char themenu[64];
	GetConfigValue(themenu, sizeof(themenu), "sky points menu name?");

	Format(tquery, sizeof(tquery), "SELECT `steam_id`, `exp`, `expov`, `upgrade cost`, `level`, `skylevel`, `%s`, `time played`, `talent points`, `total upgrades`, `free upgrades`, `restt`,`restexp`, `lpl`, `resr`, `survpoints`, `bec`, `rem`, `pri`, `tcolour`, `tname`, `ccolour`, `xpdebt`, `upav`, `upawarded`, `%s`, `myrating %s`, `ratinghc %s`, `lastserver`, `myseason`, `lvlpaused`, `itrails`, `pistol_xp`, `melee_xp`, `uzi_xp`, `shotgun_xp`, `sniper_xp`, `assault_xp`, `medic_xp`, `grenade_xp` FROM `%s` WHERE (`steam_id` = '%s');", themenu, RatingType, RatingType, RatingType, TheDBPrefix, key);
// maybe set a value equal to the users steamid integer only, so if steam:0:1:23456, set the value of "client" equal to 23456 and then set the client equal to whatever client's steamid contains 23456?
	hDatabase.Query(QueryResults_Load, tquery, client);
}

public void Query_CheckIfProfileLimit(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl == INVALID_HANDLE) {

		LogMessage("Query_CheckIfProfileLimit Error: %s", error);
		return;
	}
	int ProfileCountLimit = GetConfigValueInt("profile editor limit?");
	char thetext[64];
	GetConfigValue(thetext, sizeof(thetext), "donator package flag?");
	if (IsGroupMember[client] || HasCommandAccess(client, thetext)) ProfileCountLimit = RoundToCeil(ProfileCountLimit * 2.0);
	char tquery[1024];
	char key[128];

	while (hndl.FetchRow()) {

		if (hndl.FetchInt(0) < ProfileCountLimit) {

			GetClientAuthId(client, AuthId_Steam2, key, sizeof(key));
			Format(key, sizeof(key), "%s%s+%s", key, PROFILE_VERSION, LoadoutName[client]);

			Format(tquery, sizeof(tquery), "SELECT COUNT(*) FROM `%s` WHERE (`steam_id` = '%s');", TheDBPrefix, key);
			hDatabase.Query(Query_CheckIfProfileExists, tquery, client);
		}
		else PrintToChat(client, "%T", "profile editor limit reached", client, orange);
	}
}

public void Query_CheckCompanionCount(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl == INVALID_HANDLE) {

		LogMessage("Query_CheckCompanionCount Error: %s", error);
		return;
	}
	while (hndl.FetchRow()) {

		if (hndl.FetchInt(0) >= GetConfigValueInt("max unique companions?")) {

			PrintToChat(client, "companion limit %d exceeded", GetConfigValueInt("max unique companions?"));
			return;
		}
		else {

			PrintToChat(client, "Your party is not full, adding %s to the party!", CompanionNameQueue[client]);

			char tquery[1024];
			Format(tquery, sizeof(tquery), "SELECT COUNT(*) FROM `%s` WHERE `companionname` = '%s';", TheDBPrefix, CompanionNameQueue[client]);
			hDatabase.Query(Query_CheckIfCompanionExists, tquery, client);
		}
	}
}

public void Query_CheckIfCompanionExists(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl == INVALID_HANDLE) {

		LogMessage("Query_CheckIfCompanionExists Error: %s", error);
		return;
	}
	while (hndl.FetchRow()) {

		if (hndl.FetchInt(0) < 1) {

			ReadyUp_NtvCreateCompanion(client, CompanionNameQueue[client]);		// The companion of this name doesn't exist, so we allow the player to create it.
			CreateTimer(1.0, Timer_SaveCompanion, client, TIMER_FLAG_NO_MAPCHANGE);		// now we save the companion to the database so no one else can use this name.
		}
		else {

			PrintToChat(client, "companion name taken, please pick another");
			return;
		}
	}
}

public void Query_CheckIfProfileExists(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl == INVALID_HANDLE) {

		LogMessage("Query_CheckIfProfileExists Error: %s", error);
		return;
	}
	while (hndl.FetchRow()) {

		if (hndl.FetchInt(0) < 1) {

			SaveProfile(client, 1);		// 1 for saving a new profile.
		}
		else SaveProfile(client, 2);	// 2 for overwriting an existing profile.
	}
}

stock void ModifyCartelValue(int client, char[] thetalent, int thevalue) {

	int size = a_Menu_Talents.Length;
	char text[512];

	for (int i = 0; i < size; i++) {

		CartelValueKeys[client]			= a_Menu_Talents.Get(i, 0);
		CartelValueValues[client]		= a_Menu_Talents.Get(i, 1);

		if (GetKeyValueIntAtPos(CartelValueValues[client], IS_SUB_MENU_OF_TALENTCONFIG) == 1) continue;
		if (GetKeyValueIntAtPos(CartelValueValues[client], IS_TALENT_TYPE) <= 0) continue;

		a_Database_Talents.GetString(i, text, sizeof(text));
		if (!StrEqual(text, thetalent, false)) continue;
		
		a_Database_PlayerTalents[client].Set(i, thevalue);
		a_Database_PlayerTalents_Experience[client].Set(i, 0);
	}
}

stock void CreateNewPlayerEx(int client) {

	char tquery[1024];
	//decl String:text[64];
	char TagColour[64];
	char TagName[64];
	char ChatColour[64];
	int size = a_Database_Talents.Length;

	char key[512];
	char TheName[64];
	if (IsSurvivorBot(client)) {

		GetSurvivorBotName(client, TheName, sizeof(TheName));
		Format(key, sizeof(key), "%s%s", sBotTeam, TheName);
	}
	else {

		GetClientAuthId(client, AuthId_Steam2, key, sizeof(key));
	}

	LogMessage("No data rows for %N with steamid: %s, could be found, creating new player data.", client, key);

	ChatSettings[client].Resize(3);

	Format(tquery, sizeof(tquery), "none");
	ChatSettings[client].SetString(0, tquery);
	ChatSettings[client].SetString(1, tquery);
	ChatSettings[client].SetString(2, tquery);

	if (IsFakeClient(client)) PlayerLevel[client] = iBotPlayerStartingLevel;
	else PlayerLevel[client]				=	iPlayerStartingLevel;
	SetTotalExperienceByLevel(client, PlayerLevel[client]);
	ChallengeEverything(client);

	bIsNewPlayer[client]			= true;
	b_IsLoading[client]				= false;
	bIsTalentTwo[client]			= false;
	b_IsLoadingStore[client]		= false;
	b_IsLoadingTrees[client]		= false;
	LoadTarget[client]				=	-1;
	Rating[client]					=	0;
	ExperienceDebt[client]			=	0;
	//ExperienceLevel[client]			=	1;
	//ExperienceOverall[client]		=	1;
	PlayerLevelUpgrades[client]		=	0;
	SkyPoints[client]				=	0;
	TotalTalentPoints[client]		=	0;
	TimePlayed[client]				=	0;
	PlayerUpgradesTotal[client]		=	0;
	UpgradesAvailable[client]		= MaximumPlayerUpgrades(client);
	FreeUpgrades[client]			=	0;
	if (!IsFakeClient(client)) DefaultHealth[client]			=	iSurvivorBaseHealth;
	else DefaultHealth[client]			= iSurvivorBotBaseHealth;
	//PrintToChatAll("Setting %N to %d", client, PlayerLevel[client]);
	GiveMaximumHealth(client);
	Format(ActiveSpecialAmmo[client], sizeof(ActiveSpecialAmmo[]), "none");


	//for (new i = 1; i <= MAXPLAYERS; i++) PlayerAbilitiesImmune[client][i].Resize(size);
	//PlayerAbilitiesImmune[client].Resize(size);

	for (int i = 0; i < size; i++) {

		/*

			We used to set defaults here, instead we set everything to 0, and just don't allow a player to insert a point if it is locked.
		*/

		//a_Database_Talents_Defaults.GetString(i, text, sizeof(text));
		//Format(text, sizeof(text), "%d", StringToInt(text) - 1);
		a_Database_PlayerTalents[client].Set(i, 0);
		a_Database_PlayerTalents_Experience[client].Set(i, 0);
	}
	if (a_Store_Player[client].Length != a_Store.Length) {

		a_Store_Player[client].Resize(a_Store.Length);
	}

	for (int i = 0; i < a_Store.Length; i++) {

		a_Store_Player[client].SetString(i, "0");				// We clear all players arrays for the store.
	}
	BuildMenu(client);

	Format(TagColour, sizeof(TagColour), "none");
	//Format(TagName, sizeof(TagName), "none");
	if (!IsSurvivorBot(client)) GetClientName(client, TagName, sizeof(TagName));
	else GetSurvivorBotName(client, TagName, sizeof(TagName));

	hDatabase.Escape(TagName, TagName, sizeof(TagName));

	Format(ChatColour, sizeof(ChatColour), "none");
	//Format(tquery, sizeof(tquery), "INSERT INTO `%s` (`steam_id`, `exp`, `expov`, `upgrade cost`, `level`, `%s`, `time played`, `talent points`, `total upgrades`, `free upgrades`, `tcolour`, `tname`, `ccolour`) VALUES ('%s', '%d', '%d', '%d', '%d', '%d', '%d', '%d', '%d', '%d', '%s', '%s', '%s');", TheDBPrefix, spmn, key, ExperienceLevel[client], ExperienceOverall[client], PlayerLevelUpgrades[client], PlayerLevel[client], SkyPoints[client], TimePlayed[client], TotalTalentPoints[client], PlayerUpgradesTotal[client], FreeUpgrades[client], TagColour, TagName, ChatColour);
	Format(tquery, sizeof(tquery), "INSERT INTO `%s` (`steam_id`) VALUES ('%s');", TheDBPrefix, key);
	//hDatabase.Escape(tquery, tquery, sizeof(tquery));
	hDatabase.Query(QuerySaveNewPlayer, tquery, client);

	CreateTimer(1.0, Timer_LoggedUsers, client, TIMER_FLAG_NO_MAPCHANGE);
}

public void Query_CheckIfDataExists(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl == INVALID_HANDLE) {

		LogMessage("Query_ChecKIfDataExists Error: %s", error);
		return;
	}
	char key[512];
	char TheName[64];
	int count	= 0;
	if (!IsLegitimateClient(client)) return;
	if (IsSurvivorBot(client)) {

		GetSurvivorBotName(client, TheName, sizeof(TheName));
		Format(key, sizeof(key), "%s%s", sBotTeam, TheName);
	}
	else {

		GetClientAuthId(client, AuthId_Steam2, key, sizeof(key));
	}

	int size = a_Database_Talents.Length;

	while (hndl.FetchRow()) {

		//hndl.FetchString(0, key, sizeof(key));
		count	= hndl.FetchInt(0);

		PlayerAbilitiesCooldown[client].Resize(size);
		a_Database_PlayerTalents[client].Resize(size);
		a_Database_PlayerTalents_Experience[client].Resize(size);
	}
	if (count < 1) {

		if (!CheckServerLevelRequirements(client)) return;	// client was kicked.

		CreateNewPlayerEx(client);

			//decl String:DefaultProfileName[512];
			//GetConfigValue(DefaultProfileName, sizeof(DefaultProfileName), "new player profile?");
			//if (StrContains(DefaultProfileName, "-1", false) == -1) LoadProfileEx(client, DefaultProfileName);
	}
	else {

		LogMessage("%d Data rows found for %N with steamid: %s, loading player data.", count, client, key);
		//b_IsLoading[client] = false;
		ClearAndLoad(client, true);
		//if (!IsFakeClient(client)) CheckServerLevelRequirements(client);
	}
}

stock void CheckGroupStatus(int client) {

	char pct[4];
	Format(pct, sizeof(pct), "%");

	if (IsLegitimateClient(client) && !IsFakeClient(client) && GroupMemberBonus > 0.0) {

		if (IsGroupMember[client]) PrintToChat(client, "%T", "group member bonus", client, blue, GroupMemberBonus * 100.0, pct, green, orange);
		else PrintToChat(client, "%T", "group member benefit", client, orange, blue, GroupMemberBonus * 100.0, pct, green, blue);
	}
}

stock void SaveCompanionData(int client, bool DontTell = false) {

	/*if (StrEqual(ActiveCompanion[client], "none")) return;
	if (!DontTell) PrintToChat(client, "%T", "saving companion data", orange, green, ActiveCompanion[client]);

	decl String:tquery[1024];
	decl String:text[64];
	GetClientAuthString(client, text, sizeof(text));
	Format(tquery, sizeof(tquery), "SELECT COUNT(*) FROM `%s` WHERE (`companion` = '%s');", TheDBPrefix, ActiveCompanion[client]);
	hDatabase.Query(Query_SaveCompanionData)*/
}

public Action Timer_LoadDelay(Handle timer, any client) {

	if (IsLegitimateClient(client)) {

		LoadDelay[client] = false;
	}
	return Plugin_Stop;
}

stock void CreateNewPlayer(int client) {

	if (hDatabase == INVALID_HANDLE) {

		LogMessage("cannot create data because the database is still loading. %N", client);
		return;
	}
	//if (LoadDelay[client]) return;	// prevent constant loading (bots, specifically.)
	//LoadDelay[client] = true;
	//CreateTimer(3.0, Timer_LoadDelay, client, TIMER_FLAG_NO_MAPCHANGE);
	char tquery[1024];
	char key[512];
	char TheName[64];

	if (b_IsLoading[client]) return;	// should stop bots (and players) from looping indefinitely.
	b_IsLoading[client] = true;

	LogMessage("Looking up player %N in Database before creating new data.", client);
	if (IsSurvivorBot(client)) {

		GetSurvivorBotName(client, TheName, sizeof(TheName));
		Format(key, sizeof(key), "%s%s", sBotTeam, TheName);
	}
	else {

		GetClientAuthId(client, AuthId_Steam2, key, sizeof(key));
	}

	Format(tquery, sizeof(tquery), "SELECT COUNT(*) FROM `%s` WHERE (`steam_id` = '%s');", TheDBPrefix, key);
	hDatabase.Query(Query_CheckIfDataExists, tquery, client);
}

public Action Timer_SaveCompanion(Handle timer, any client) {

	//new companion = MySurvivorCompanion(client);
	//SaveAndClear(companion);
	return Plugin_Stop;
}

stock void SaveInfectedData(int client) {

	//return;
}

stock bool veAndClear(int client, bool b_IsTrueDisconnect = false, bool IsNewPlayer = false) {

	if (!IsLegitimateClient(client)) return;
	bool IsLoadingData = b_IsLoading[client];
	if (!IsLoadingData) {
		LogMessage("Loading of Talents was completed for %N", client);
		IsLoadingData = bIsTalentTwo[client];
	}

	// if the database isn't connected, we don't try to save data, because that'll just throw errors.
	// If the player didn't participate, or if they are currently saving data, we don't save as well.
	// It's possible (but not likely) for a player to try to save data while saving, due to their ability to call the function at any time through commands.
	if (hDatabase == INVALID_HANDLE) {

		LogMessage("Database couldn't be found, cannot save for %N", client);
		return;
	}
	//ClearImmunities(client);
	if (!IsLegitimateClient(client)) return;	// fuck me!!
	//if (GetClientTeam(client) == TEAM_SPECTATOR) return;
	if (GetClientTeam(client) == TEAM_INFECTED) {

		SaveInfectedData(client);
		return;
	}
	if (a_Database_PlayerTalents[client].Length < 1) {

		// This is probably a survivor bot, or a human player who is simply playing vanilla.
		// I thought I had checks in place to make sure they didn't get this far, but it looks like something is still getting through.
		// Oh well, now it's not.
		return;
	}
	if (b_IsTrueDisconnect) {

		RoundExperienceMultiplier[client] = 0.0;
		BonusContainer[client] = 0;

		HealImmunity[client] = false;
		b_IsLoading[client] = false;
		bIsTalentTwo[client] = false;

		resr[client] = 1;
		WipeDebuffs(_, client, true);
		bIsDisconnecting[client] = true;
	}
	else resr[client] = 0;

	b_IsDirectorTalents[client] = false;

	if (IsLoadingData) {
		LogMessage("Client is loading Data, cannot save. %N", client);
		return;
	}
	//bSaveData[client] = true;

	char tquery[1024];
	char key[512];
	char text[512];
	//decl String:text2[512];
	int talentlevel = 0;

	PreviousRoundIncaps[client] = RoundIncaps[client];

	int size = a_Database_Talents.Length;

	char thesp[64];
	char TheName[64];
	//decl String:Name[64];
	GetConfigValue(thesp, sizeof(thesp), "sky points menu name?");

	if (IsSurvivorBot(client)) {

		GetSurvivorBotName(client, TheName, sizeof(TheName));
		Format(key, sizeof(key), "%s%s", sBotTeam, TheName);
	}
	else {

		GetClientAuthId(client, AuthId_Steam2, key, sizeof(key));
	}
	/*if (PlayerUpgradesTotal[client] == 0 && FreeUpgrades[client] == 0 && PlayerLevel[client] <= 1) {

		Format(tquery, sizeof(tquery), "DELETE FROM `%s` WHERE `steam_id` = '%s';", TheDBPrefix, key);
		hDatabase.Query(QueryResults, tquery, client);
		bSaveData[client] = false;
		return;
	}*/

	char sPoints[64];
	Format(sPoints, sizeof(sPoints), "%3.3f", Points[client]);

	//if (PlayerLevel[client] < 1) return;		// Clearly, their data hasn't loaded, so we don't save.
	Format(tquery, sizeof(tquery), "UPDATE `%s` SET `exp` = '%d', `expov` = '%d', `upgrade cost` = '%d', `level` = '%d', `%s` = '%d', `time played` = '%d', `talent points` = '%d', `total upgrades` = '%d', `free upgrades` = '%d' WHERE (`steam_id` = '%s');", TheDBPrefix, ExperienceLevel[client], ExperienceOverall[client], PlayerLevelUpgrades[client], PlayerLevel[client], thesp, SkyPoints[client], TimePlayed[client], TotalTalentPoints[client], PlayerUpgradesTotal[client], FreeUpgrades[client], key);

	hDatabase.Query(QueryResults1, tquery, client);
	
	Format(tquery, sizeof(tquery), "UPDATE `%s` SET `upav` = '%d', `upawarded` = '%d', `lvlpaused` = '%d', `itrails` = '%d' WHERE (`steam_id` = '%s');", TheDBPrefix, UpgradesAvailable[client], UpgradesAwarded[client], iIsLevelingPaused[client], iIsBulletTrails[client], key);
	hDatabase.Query(QueryResults2, tquery, client);

	Format(tquery, sizeof(tquery), "UPDATE `%s` SET `pistol_xp` = '%d', `melee_xp` = '%d', `uzi_xp` = '%d', `shotgun_xp` = '%d', `sniper_xp` = '%d', `assault_xp` = '%d', `medic_xp` = '%d', `grenade_xp` = '%d' WHERE (`steam_id` = '%s');", TheDBPrefix, pistolXP[client], meleeXP[client], uziXP[client], shotgunXP[client], sniperXP[client], assaultXP[client], medicXP[client], grenadeXP[client], key);
	hDatabase.Query(QueryResults3, tquery, client);

	char bonusMult[64];
	Format(bonusMult, sizeof(bonusMult), "%3.3f", RoundExperienceMultiplier[client]);

	Format(tquery, sizeof(tquery), "UPDATE `%s` SET `myseason` = '%s', `rem` = '%s' WHERE (`steam_id` = '%s');", TheDBPrefix, RatingType, bonusMult, key);
	hDatabase.Query(QueryResults1, tquery, client);

	hDatabase.Escape(Hostname, text, sizeof(text));
	Format(tquery, sizeof(tquery), "UPDATE `%s` SET `lastserver` = '%s' WHERE (`steam_id` = '%s');", TheDBPrefix, text, key);
	hDatabase.Query(QueryResults1, tquery, client);

	Format(tquery, sizeof(tquery), "UPDATE `%s` SET `skylevel` = '%d' WHERE (`steam_id` = '%s');", TheDBPrefix, SkyLevel[client], key);
	hDatabase.Query(QueryResults1, tquery, client);
	//if (!IsFakeClient(client)) LogMessage(tquery);

	if (Rating[client] > BestRating[client]) BestRating[client] = Rating[client];
	int minimumRating = RoundToCeil(BestRating[client] * fRatingFloor);
	if (Rating[client] < minimumRating) Rating[client] = minimumRating;

	Format(tquery, sizeof(tquery), "UPDATE `%s` SET `restt` = '%d', `restexp` = '%d', `lpl` = '%d', `resr` = '%d', `pri` = '%d', `survpoints` = '%s', `bec` = '%d', `%s` = '%d', `myrating %s` = '%d', `ratinghc %s` = '%d' WHERE (`steam_id` = '%s');", TheDBPrefix, GetTime(), RestedExperience[client], LastPlayLength[client], resr[client], PreviousRoundIncaps[client], sPoints, BonusContainer[client], RatingType, BestRating[client], RatingType, Rating[client], RatingType, RatingHandicap[client], key);
	hDatabase.Query(QueryResults4, tquery, client);

	for (int i = 0; i < size; i++) {

		TalentTreeKeys[client]			= a_Menu_Talents.Get(i, 0);
		TalentTreeValues[client]		= a_Menu_Talents.Get(i, 1);

		if (GetKeyValueIntAtPos(TalentTreeValues[client], IS_SUB_MENU_OF_TALENTCONFIG) == 1) continue;

		//if (GetKeyValueInt(TalentTreeKeys[client], TalentTreeValues[client], "is survivor class role?") == 1) continue;	// class roles aren't stored in the database in the same way that talents/CARTEL are.

		a_Database_Talents.GetString(i, text, sizeof(text));
		talentlevel = a_Database_PlayerTalents[client].Get(i);// a_Database_PlayerTalents[client].GetString(i, text2, sizeof(text2));

		/*if (GetKeyValueInt(TalentTreeKeys[client], TalentTreeValues[client], "talent type?") == 1) {

			talentexperience = a_Database_PlayerTalents_Experience[client].Get(i);
			//a_Database_PlayerTalents_Experience[client].GetString(i, text3, sizeof(text3));
		
			Format(tquery, sizeof(tquery), "UPDATE `%s` SET `%s` = '%d', `%s xp` = '%d' WHERE (`steam_id` = '%s');", TheDBPrefix, text, talentlevel, text, talentexperience, key);
			hDatabase.Query(QueryResults5, tquery, client);
		}
		else {*/
		Format(tquery, sizeof(tquery), "UPDATE `%s` SET `%s` = '%d' WHERE (`steam_id` = '%s');", TheDBPrefix, text, talentlevel, key);
		hDatabase.Query(QueryResults6, tquery, client);
		//}
	}
	int ActionSlotSize = iActionBarSlots;
	if (ActionBar[client].Length != ActionSlotSize) ActionBar[client].Resize(ActionSlotSize);
	char ActionBarText[64];
	for (int i = 0; i < ActionSlotSize; i++) {	// isnt looping?

		ActionBar[client].GetString(i, ActionBarText, sizeof(ActionBarText));
		//if (StrEqual(ActionBarText, "none")) continue;
		if (!IsAbilityTalent(client, ActionBarText) && (!IsTalentExists(ActionBarText) || GetTalentStrength(client, ActionBarText) < 1)) Format(ActionBarText, sizeof(ActionBarText), "none");
		Format(tquery, sizeof(tquery), "UPDATE `%s` SET `aslot%d` = '%s' WHERE (`steam_id` = '%s');", TheDBPrefix, i+1, ActionBarText, key);
		hDatabase.Query(QueryResults, tquery);
	}
	int isDisab = 0;
	if (DisplayActionBar[client]) isDisab = 1;
	Format(tquery, sizeof(tquery), "UPDATE `%s` SET `disab` = '%d' WHERE (`steam_id` = '%s');", TheDBPrefix, isDisab, key);
	hDatabase.Query(QueryResults, tquery);

	if (hWeaponList[client].Length < 2) {
		hWeaponList[client].Resize(2);
		int wepid = GetPlayerWeaponSlot(client, 0);
		if (IsValidEntity(wepid)) {
			GetEntityClassname(wepid, text, sizeof(text));
			hWeaponList[client].SetString(0, text);
		}
		else Format(text, sizeof(text), "%s", defaultLoadoutWeaponPrimary);
		Format(tquery, sizeof(tquery), "UPDATE `%s` SET `primarywep` = '%s'", TheDBPrefix, text);

		GetMeleeWeapon(client, text, sizeof(text));
		if (StrEqual(text, "null")) {	// if the secondary is not a melee weapon
			wepid = GetPlayerWeaponSlot(client, 1);
			if (IsValidEntity(wepid)) GetEntityClassname(wepid, text, sizeof(text));
			else Format(text, sizeof(text), "%s", defaultLoadoutWeaponSecondary);
		}
		hWeaponList[client].SetString(1, text);
		Format(tquery, sizeof(tquery), "%s, `secondwep` = '%s' WHERE (`steam_id` = '%s');", tquery, text, key);
	}
	else {
		hWeaponList[client].GetString(0, text, sizeof(text));
		Format(tquery, sizeof(tquery), "UPDATE `%s` SET `primarywep` = '%s'", TheDBPrefix, text);

		hWeaponList[client].GetString(1, text, sizeof(text));
		Format(tquery, sizeof(tquery), "%s, `secondwep` = '%s' WHERE (`steam_id` = '%s');", tquery, text, key);
	}
	hDatabase.Query(QueryResults, tquery);

	/*size				=	a_Store.Length;

	for (new i = 0; i < size; i++) {

		SaveSection[client]			=	a_Store.Get(i, 2);
		Handle:SaveSection[client].GetString(0, text, sizeof(text));
		a_Store_Player[client].GetString(i, text2, sizeof(text2));
		Format(tquery, sizeof(tquery), "UPDATE `%s` SET `%s` = '%s' WHERE (`steam_id` = '%s');", TheDBPrefix, text, text2, key);
		hDatabase.Query(QueryResults7, tquery, client);
	}*/

	if (ChatSettings[client].Length != 3) {

		ChatSettings[client].Resize(3);

		Format(tquery, sizeof(tquery), "none");
		ChatSettings[client].SetString(0, tquery);
		ChatSettings[client].SetString(1, tquery);
		ChatSettings[client].SetString(2, tquery);
	}
	char TagColour[64];
	char TagName[64];
	char ChatColour[64];
	ChatSettings[client].GetString(0, TagColour, sizeof(TagColour));
	ChatSettings[client].GetString(1, TagName, sizeof(TagName));
	ChatSettings[client].GetString(2, ChatColour, sizeof(ChatColour));

	if (StrEqual(TagName, "none")) {

		if (!IsSurvivorBot(client)) GetClientName(client, TagName, sizeof(TagName));
		else GetSurvivorBotName(client, TagName, sizeof(TagName));
	}
	hDatabase.Escape(TagName, TagName, sizeof(TagName));

	Format(tquery, sizeof(tquery), "UPDATE `%s` SET `tcolour` = '%s', `tname` = '%s', `ccolour` = '%s' WHERE (`steam_id` = '%s');", TheDBPrefix, TagColour, TagName, ChatColour, key);
	//hDatabase.Escape(tquery, tquery, sizeof(tquery));// comment this line if it breaks
	hDatabase.Query(QueryResults8, tquery, client);
	if (IsNewPlayer) {

		CreateTimer(1.0, Timer_LoadNewPlayer, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	//else if (StrContains(key, "BOT", false) != -1 && IsSurvivorBot(client) || StrContains(key, "BOT", false) == -1 && !IsFakeClient(client)) {

		//SaveClassData(client);
		//if (!IsSurvivorBot(client)) SaveCompanionData(client);
	//}
	//bSaveData[client] = false;
}

public Action Timer_LoadNewPlayer(Handle timer, any client) {
	if (!IsLegitimateClient(client)) return Plugin_Stop;
	if (forceProfileOnNewPlayers != 1) b_IsLoading[client] = false;
	else {
		b_IsLoading[client] = true;
		LoadTarget[client] = -1;
		if (IsSurvivorBot(client) && !StrEqual(DefaultBotProfileName, "-1")) LoadProfileEx(client, DefaultBotProfileName);
		else if (GetClientTeam(client) == TEAM_INFECTED && !StrEqual(DefaultInfectedProfileName, "-1")) LoadProfileEx(client, DefaultInfectedProfileName);
		else if (GetClientTeam(client) == TEAM_SURVIVOR && !StrEqual(DefaultProfileName, "-1")) LoadProfileEx(client, DefaultProfileName);
		else b_IsLoading[client] = false;
	}
	if (b_IsLoading[client]) LogMessage("Loading profile for new player %N", client);
	return Plugin_Stop;
}

stock LoadDirectorActions() {

	if (hDatabase == INVALID_HANDLE) return;
	char key[64];
	char section_t[64];
	char tquery[1024];
	GetConfigValue(key, sizeof(key), "director steam id?");
	LoadPos_Director = 0;

	LoadDirectorSection					=	a_DirectorActions.Get(LoadPos_Director, 2);
	LoadDirectorSection.GetString(0, section_t, sizeof(section_t));

	//decl String:thevalue[64];
	//GetConfigValue(thevalue, sizeof(thevalue), "database prefix?");

	Format(tquery, sizeof(tquery), "SELECT `%s` FROM `%s` WHERE (`steam_id` = '%s');", section_t, TheDBPrefix, key);
	//LogMessage("Loading Director Priorities: %s", tquery);
	hDatabase.Query(QueryResults_LoadDirector, tquery, -1);
}

public QueryResults_LoadDirector(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl != INVALID_HANDLE) {

		char text[64];
		char key[64];
		char key_t[64];
		char value_t[64];
		char section_t[64];
		char tquery[1024];

		bool NoLoad						=	false;

		GetConfigValue(key, sizeof(key), "director steam id?");
		//decl String:dbpref[64];
		//GetConfigValue(dbpref, sizeof(dbpref), "database prefix?");
		int size = 0;

		while (hndl.FetchRow()) {

			hndl.FetchString(0, text, sizeof(text));

			if (StrEqual(text, "0")) NoLoad = true;
			if (LoadPos_Director < a_DirectorActions.Length) {

				QueryDirectorSection						=	a_DirectorActions.Get(LoadPos_Director, 2);
				QueryDirectorSection.GetString(0, section_t, sizeof(section_t));

				QueryDirectorKeys							=	a_DirectorActions.Get(LoadPos_Director, 0);
				QueryDirectorValues							=	a_DirectorActions.Get(LoadPos_Director, 1);

				size							=	QueryDirectorKeys.Length;

				for (int i = 0; i < size && !NoLoad; i++) {

					QueryDirectorKeys.GetString(i, key_t, sizeof(key_t));
					QueryDirectorValues.GetString(i, value_t, sizeof(value_t));

					if (StrEqual(key_t, "priority?")) {

						QueryDirectorValues.SetString(i, text);
						a_DirectorActions.Set(LoadPos_Director, QueryDirectorValues, 1);
						break;
					}
				}
				LoadPos_Director++;
				if (LoadPos_Director < a_DirectorActions.Length && !NoLoad) {

					QueryDirectorSection						=	a_DirectorActions.Get(LoadPos_Director, 2);
					QueryDirectorSection.GetString(0, section_t, sizeof(section_t));

					Format(tquery, sizeof(tquery), "SELECT `%s` FROM `%s` WHERE (`steam_id` = '%s');", section_t, TheDBPrefix, key);
					hDatabase.Query(QueryResults_LoadDirector, tquery, -1);
				}
				else if (NoLoad) FirstUserDirectorPriority();
			}
		}
	}
}

stock FirstUserDirectorPriority() {

	int size						=	a_Points.Length;

	int sizer						=	0;

	char s_key[64];
	char s_value[64];

	for (int i = 0; i < size; i++) {

		FirstDirectorKeys						=	a_Points.Get(i, 0);
		FirstDirectorValues						=	a_Points.Get(i, 1);
		FirstDirectorSection					=	a_Points.Get(i, 2);

		int size2					=	FirstDirectorKeys.Length;
		for (int ii = 0; ii < size2; ii++) {

			FirstDirectorKeys.GetString(ii, s_key, sizeof(s_key));
			FirstDirectorValues.GetString(ii, s_value, sizeof(s_value));

			if (StrEqual(s_key, "model?")) PrecacheModel(s_value, false);
			else if (StrEqual(s_key, "director option?") && StrEqual(s_value, "1")) {

				sizer				=	a_DirectorActions.Length;

				a_DirectorActions.Resize(sizer + 1);
				a_DirectorActions.Set(sizer, FirstDirectorKeys, 0);
				a_DirectorActions.Set(sizer, FirstDirectorValues, 1);
				a_DirectorActions.Set(sizer, FirstDirectorSection, 2);

				a_DirectorActions_Cooldown.Resize(sizer + 1);
				a_DirectorActions_Cooldown.SetString(sizer, "0");						// 0 means not on cooldown. 1 means on cooldown. This resets every map.
			}
		}
	}
}

stock FindClientByIdNumber(searchId) {
	char AuthId[64];
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i)) continue;
		GetClientAuthId(i, AuthId_Steam2, AuthId, sizeof(AuthId));
		if (searchId == StringToInt(AuthId[10])) return i;
	}
	return -1;
}

stock FindClientWithAuthString(char[] key, bool MustBeExact = false) {

	char AuthId[512];
	char TheName[64];
	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i)) {

			if (IsSurvivorBot(i)) {

				GetSurvivorBotName(i, TheName, sizeof(TheName));
				Format(AuthId, sizeof(AuthId), "%s%s", sBotTeam, TheName);
			}
			else {

				GetClientAuthId(i, AuthId_Steam2, AuthId, sizeof(AuthId));
			}
			if (MustBeExact && StrEqual(key, AuthId, false) || !MustBeExact && StrContains(key, AuthId, false) != -1) return i;
		}
	}
	return -1;
}

stock bool IsReserve(int client) {

	char thevalue[64];
	GetConfigValue(thevalue, sizeof(thevalue), "donator package flag?");

	if (IsGroupMember[client] || HasCommandAccess(client, thevalue)) return true;
	return false;
}

stock bool HasCommandAccess(client, char accessflags[]) {

	char flagpos[2];

	// We loop through the access flags passed to this function to see if the player has any of them and return the result.
	// This means flexibility for anything in RPG that allows custom flags, such as reserve player access or director menu access.
	for (int i = 0; i < strlen(accessflags); i++) {

		flagpos[0] = accessflags[i];
		flagpos[1] = 0;
		if (HasCommandAccessEx(client, flagpos)) return true;
	}
	// Old Method -> if (HasCommandAccess(client, "z") || HasCommandAccess(client, "a")) return true;
	return false;
}

public LoadInventory_Generate(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl != INVALID_HANDLE) {

		char text[128];

		while (hndl.FetchRow()) {

			hndl.FetchString(0, text, sizeof(text));
			PlayerInventory[client].PushString(text);
			if (hndl.MoreRows) hndl.FetchMoreResults();
		}
		LoadInventoryEx(client);
	}
}

public ReadProfiles_Generate(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl != INVALID_HANDLE) {

		char text[128];
		char result[2][128];
		char VersionNumber[64];
		Format(VersionNumber, sizeof(VersionNumber), "SavedProfile%s", PROFILE_VERSION);

		while (hndl.FetchRow()) {

			hndl.FetchString(0, text, sizeof(text));
			ExplodeString(text, "+", result, 2, 128);
			if (strlen(result[1]) >= 8 && StrContains(text, VersionNumber, true) != -1) {

				PlayerProfiles[client].PushString(text);
			}
			if (hndl.MoreRows) hndl.FetchMoreResults();
		}
		ReadProfilesEx(client);
	}
}

public ReadProfiles_GenerateAll(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl != INVALID_HANDLE) {

		char text[128];
		char result[2][128];
		char VersionNumber[64];
		Format(VersionNumber, sizeof(VersionNumber), "SavedProfile%s", PROFILE_VERSION);

		while (hndl.FetchRow()) {

			hndl.FetchString(0, text, sizeof(text));
			ExplodeString(text, "+", result, 2, 128);
			if (StrContains(text, "default", false) == -1 && strlen(result[1]) >= 8 && StrContains(text, VersionNumber, true) != -1) {

				PlayerProfiles[client].PushString(text);
			}
			if (hndl.MoreRows) hndl.FetchMoreResults();
		}
		ReadProfilesEx(client);
	}
}

public QueryResults_Load(Handle owner, Handle hndl, const char[] error, any client)
{
	if ( hndl != INVALID_HANDLE )
	{
		char key[64];
		char text[64];
		//decl String:tquery[512];
		char t_Hostname[64];

		char CurrentSeason[64];
		int RestedTime		= 0;
		int iLevel = 0;
		//decl String:t_Class[64];

		if (!IsLegitimateClient(client)) {

			if (client > 0) b_IsLoading[client] = false;
			return;
		}

		while (hndl.FetchRow())
		{
			hndl.FetchString(0, key, sizeof(key));
			//client = FindClientWithAuthString(key, true);
			if (client == -1) return;

			ExperienceLevel[client]		=	hndl.FetchInt(1);
			ExperienceOverall[client]	=	hndl.FetchInt(2);
			PlayerLevelUpgrades[client]	=	hndl.FetchInt(3);
			PlayerLevel[client]			=	hndl.FetchInt(4);
			SkyLevel[client]			=	hndl.FetchInt(5);
			SkyPoints[client]			=	hndl.FetchInt(6);
			TimePlayed[client]			=	hndl.FetchInt(7);
			TotalTalentPoints[client]	=	hndl.FetchInt(8);
			PlayerUpgradesTotal[client]	=	hndl.FetchInt(9);
			FreeUpgrades[client]		=	hndl.FetchInt(10);
			RestedTime					=	hndl.FetchInt(11);
			RestedExperience[client]	=	hndl.FetchInt(12);
			LastPlayLength[client]		=	hndl.FetchInt(13);
			resr[client]				=	hndl.FetchInt(14);
			hndl.FetchString(15, text, sizeof(text));
			Points[client] = StringToFloat(text);
			BonusContainer[client] = hndl.FetchInt(16);

			hndl.FetchString(17, text, sizeof(text));
			RoundExperienceMultiplier[client] = StringToFloat(text);

			PreviousRoundIncaps[client]	=	hndl.FetchInt(18);
			hndl.FetchString(19, text, sizeof(text));
			ChatSettings[client].SetString(0, text);
			hndl.FetchString(20, text, sizeof(text));
			ChatSettings[client].SetString(1, text);
			hndl.FetchString(21, text, sizeof(text));
			ChatSettings[client].SetString(2, text);
			ExperienceDebt[client]		=	hndl.FetchInt(22);
			UpgradesAvailable[client]	=	hndl.FetchInt(23);
			UpgradesAwarded[client]		=	hndl.FetchInt(24);
			//Format(ActiveSpecialAmmo[client], sizeof(ActiveSpecialAmmo[]), "none");
			//hndl.FetchString(25, ActiveSpecialAmmo[client], sizeof(ActiveSpecialAmmo[]));
			BestRating[client] =	hndl.FetchInt(25);
			Rating[client] = hndl.FetchInt(26);
			RatingHandicap[client] = hndl.FetchInt(27);
			hndl.FetchString(28, t_Hostname, sizeof(t_Hostname));
			// Rating is now stored individually based on each server, so we don't have to reset it when they switch between servers - it'll remember where they left off, everywhere (Handicap, too!)
			/*if (!StrEqual(Hostname, t_Hostname)) {

				// Player is on a different server from where they earned their rating.
				LogMessage("%N LAST SERVER: %s CURRENT SERVER: %s", client, t_Hostname, Hostname);
				Rating[client] = 0;
			}*/
			hndl.FetchString(29, CurrentSeason, sizeof(CurrentSeason));
			iIsLevelingPaused[client]	= hndl.FetchInt(30);
			iIsBulletTrails[client]		= hndl.FetchInt(31);
			//iNoobAssistance[client]		= hndl.FetchInt(32);

			pistolXP[client] = hndl.FetchInt(32);
			meleeXP[client] = hndl.FetchInt(33);
			uziXP[client] = hndl.FetchInt(34);
			shotgunXP[client] = hndl.FetchInt(35);
			sniperXP[client] = hndl.FetchInt(36);
			assaultXP[client] = hndl.FetchInt(37);
			medicXP[client] = hndl.FetchInt(38);
			grenadeXP[client] = hndl.FetchInt(39);
		}
		if (PlayerLevel[client] > 0) {

			if (PlayerLevel[client] >= iHardcoreMode) PrintToChat(client, "%T", "hardcore mode enabled", client, orange, green, PlayerLevel[client], orange, blue);

			if (CurrentMapPosition == 0) {

				BonusContainer[client] = 0;
				RoundExperienceMultiplier[client] = 0.0;
				Points[client] = 0.0;
				LogMessage("%N Bonus multiplier is reset.", client);
			}

			/*new Minlevel = iPlayerStartingLevel;
			if (PlayerLevel[client] < Minlevel) {

				SetTotalExperienceByLevel(client, Minlevel);
				decl String:DefaultProfileName[64];
				GetConfigValue(DefaultProfileName, sizeof(DefaultProfileName), "new player profile?");
				if (StrContains(DefaultProfileName, "-1", false) == -1) LoadProfileEx(client, DefaultProfileName);
			}*/

			/*if (ReadyUp_GetGameMode() == 3) {

				BestRating[client] = MyNewRating;
				Rating[client] = RatingLevelMultiplier;
			}
			else Rating[client] = MyNewRating;*/

			// Don't need to reset rating in this way, since Rating/BestRating is pulled uniquely from each server.
			/*if (!StrEqual(CurrentSeason, RatingType)) {

				// If the leaderboard record is from a different season, we reset.
				LogMessage("Season: %s , RatingType: %s", CurrentSeason, RatingType);
				BestRating[client] = 0;
				Rating[client] = 0;
				Format(tquery, sizeof(tquery), "UPDATE `%s` SET `%s` = '%d', `myrating` = '%d', `myseason` = '%s' WHERE (`steam_id` = '%s');", TheDBPrefix, RatingType, BestRating[client], Rating[client], RatingType, key);
				hDatabase.Query(QueryResults4, tquery, client);
			}*/

			if (Rating[client] < 0) Rating[client] = 0;
			if (!CheckServerLevelRequirements(client)) {

				b_IsLoading[client] = false;
				bIsTalentTwo[client] = false;
				ResetData(client);
				return;	// client was kicked.
			}
			if (!IsFakeClient(client)) AwardExperience(client, -1);

			//	"experience start?" can be modified at any time in the config.
			//	In order to properly adjust player levels, we use this to check.

			if (resr[client] == 1) {	// they're loading in after previous leaving so does not accrue for a player whose disconnect is not from leaving (re: map changes)

				if (RestedTime > 0) {

					RestedTime					=	GetTime() - RestedTime;
					if (RestedTime > LastPlayLength[client]) RestedTime = LastPlayLength[client];

					while (RestedTime >= iRestedSecondsRequired) {

						RestedTime -= iRestedSecondsRequired;
						if (IsGroupMember[client]) RestedExperience[client] += iRestedDonator;
						else RestedExperience[client] += iRestedRegular;
					}
					int RestedExperienceMaximum = iRestedMaximum;
					if (RestedExperienceMaximum < 1) RestedExperienceMaximum = CheckExperienceRequirement(client);
					if (RestedExperience[client] > RestedExperienceMaximum) {

						RestedExperience[client] = RestedExperienceMaximum;
					}
				}
				LastPlayLength[client] = 0;
				Points[client] = 0.0;
			}
			else {		// Player did not leave the match - so a map transition occurred.

				if (iFriendlyFire == 1 || IsPvP[client] != 0) {

					PrintToChat(client, "%T", "PvP Enabled", client, white, blue);
				}
				iLevel = GetPlayerLevel(client);
				if (SkyLevel[client] < 1 && iLevel < iPlayerStartingLevel) iLevel = iPlayerStartingLevel;
				if (PlayerLevel[client] != iLevel) SetTotalExperienceByLevel(client, iLevel);
			}
			SetSpeedMultiplierBase(client);
			LoadPos[client] = 0;
			LoadTalentTrees(client, key);
		}
		else {

			ResetData(client);
			CreateNewPlayer(client);
		}
		if (iRPGMode < 1) {
			b_IsLoading[client] = false;
			bIsTalentTwo[client] = false;
			//VerifyAllActionBars(client);
		}
		//if (b_IsLoading[client] && !IsFakeClient(client)) CheckServerLevelRequirements(client);
		/*b_IsLoading[client] = false;
		bIsTalentTwo[client] = false;
		VerifyAllActionBars(client);*/
		//if (!bFound && IsLegitimateClient(client)) {
	}
	else
	{
		//decl String:err[64];
		//GetConfigValue(err, sizeof(err), "database prefix?");
		SetFailState("Error: %s PREFIX IS: %s", error, TheDBPrefix);
		return;
	}
}

/*stock bool:IsClassLoading(String:key[]) {

	decl String:text[64];
	new size = a_ClassNames.Length;
	for (new i = 0; i < size; i++) {

		a_ClassNames.GetString(i, text, sizeof(text));
		if (StrContains(key, text, false) != -1) return true;
	}
	return false;
}*/

public QueryResults_LoadTalentTrees(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl != INVALID_HANDLE) {

		char text[512];
		char tquery[1024];

		//decl String:newplay[64];
		//GetConfigValue(newplay, sizeof(newplay), "new player profile?");

		//TalentTreeKeys[client]			= a_Menu_Talents.Get(LoadPos[client], 0);
		//TalentTreeValues[client]		= a_Menu_Talents.Get(LoadPos[client], 1);
		int size = a_Database_Talents.Length;
		int theresult = 0;

		int talentlevel = 0;
		int talentexperience = 0;
		char key[512];
		char TheName[64];
		//new iLevel			= 0;

		while (hndl.FetchRow()) {

			hndl.FetchString(0, key, sizeof(key));
			//if (!IsClassLoading(key)) client = FindClientWithAuthString(key, true);
			//else client = FindClientWithAuthString(key);
			if (client == -1 || !IsLegitimateClient(client) || IsLegitimateClient(client) && GetClientTeam(client) != TEAM_SURVIVOR && IsFakeClient(client)) {

				if (IsLegitimateClient(client)) bIsTalentTwo[client] = false;
				return;
			}
			if (IsSurvivorBot(client)) {

				GetSurvivorBotName(client, TheName, sizeof(TheName));
				Format(key, sizeof(key), "%s%s", sBotTeam, TheName);
			}
			else {

				GetClientAuthId(client, AuthId_Steam2, key, sizeof(key));
			}
			if (LoadPos[client] < a_Database_Talents.Length) {

				talentlevel = hndl.FetchInt(1);
				//if (bIsTalentTwo[client]) PrintToChat(client, "talent level %d", talentlevel);
				if (talentlevel < 0) {

					talentlevel = 0;
					if (!bIsTalentTwo[client]) talentlevel = 1;
				}
				a_Database_PlayerTalents[client].Set(LoadPos[client], talentlevel);
				a_Database_PlayerTalents_Experience[client].Set(LoadPos[client], 0);		// overwritten by actual value if
				if (bIsTalentTwo[client]) {

					talentexperience = hndl.FetchInt(2);
					if (talentexperience < 0) talentexperience = 0;
					a_Database_PlayerTalents_Experience[client].Set(LoadPos[client], talentexperience);
				}
				LoadPos[client]++;	// otherwise it'll just loop the same request

				if (bIsTalentTwo[client]) {

					while (LoadPos[client] < size) {

						//TalentTreeKeys[client]			= a_Menu_Talents.Get(LoadPos[client], 0);
						TalentTreeValues[client]		= a_Menu_Talents.Get(LoadPos[client], 1);

						if (GetKeyValueIntAtPos(TalentTreeValues[client], IS_SUB_MENU_OF_TALENTCONFIG) == 1) {

							LoadPos[client]++;
							continue;
						}

						theresult						= GetKeyValueIntAtPos(TalentTreeValues[client], IS_TALENT_TYPE);
						if (theresult <= 0) {

							LoadPos[client]++;
							continue;
						}
						else break;
					}
				}
				else {

					for (int i = LoadPos[client]; i < size; i++) {

						//TalentTreeKeys[client]			= a_Menu_Talents.Get(i, 0);
						TalentTreeValues[client]		= a_Menu_Talents.Get(i, 1);

						if (GetKeyValueIntAtPos(TalentTreeValues[client], IS_SUB_MENU_OF_TALENTCONFIG) == 1) continue; //||
							//GetKeyValueInt(TalentTreeKeys[client], TalentTreeValues[client], "is survivor class role?") == 1) continue;
						LoadPos[client] = i;
						break;
					}
				}
				if (LoadPos[client] < a_Database_Talents.Length) {

					a_Database_Talents.GetString(LoadPos[client], text, sizeof(text));

					//TalentTreeKeys[client]			= a_Menu_Talents.Get(LoadPos[client], 0);
					//TalentTreeValues[client]		= a_Menu_Talents.Get(LoadPos[client], 1);

					if (!bIsTalentTwo[client]) Format(tquery, sizeof(tquery), "SELECT `steam_id`, `%s` FROM `%s` WHERE (`steam_id` = '%s');", text, TheDBPrefix, key);
					else Format(tquery, sizeof(tquery), "SELECT `steam_id`, `%s`, `%s xp` FROM `%s` WHERE (`steam_id` = '%s');", text, text, TheDBPrefix, key);
					hDatabase.Query(QueryResults_LoadTalentTrees, tquery, client);

					return;
				}
			}
		}
		b_IsLoadingTrees[client] = false;
		if (!bIsTalentTwo[client]) {

			//iLevel = GetPlayerLevel(client);
			//if (iLevel < iPlayerStartingLevel) iLevel = iPlayerStartingLevel;
			//if (PlayerLevel[client] != iLevel) SetTotalExperienceByLevel(client, iLevel);

			SetMaximumHealth(client);
			GiveMaximumHealth(client);
			LoadStoreData(client, key);
			
			LoadPos[client] = 0;
			LoadTalentTrees(client, key, true);
		}
		else {

			//IsLoadingClassData[client] = false;

			//b_IsLoadingTrees[client] = false;
			bIsTalentTwo[client] = false;

		}
		CreateTimer(1.0, Timer_LoggedUsers, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	else {
		
		SetFailState("Error: %s", error);
		return;
	}
}

stock void LoadTalentTrees(client, char[] key, bool IsTalentTwo = false, char[] profilekey = "none") {

	//client = FindClientWithAuthString(key, true);
	if (!IsLegitimateClient(client)) return;

	b_IsLoadingTrees[client] = true;
	int size = a_Menu_Talents.Length;
	int theresult = 0;

	if (!IsTalentTwo) {

		bIsTalentTwo[client] = false;
	}
	else bIsTalentTwo[client] = true;

	char text[64];
	char tquery[1024];
	//decl String:key[64];
	GetClientAuthId(client, AuthId_Steam2, key, sizeof(key));

	if (bIsTalentTwo[client]) {

		while (LoadPos[client] < size) {

			//TalentTreeKeys[client]			= a_Menu_Talents.Get(LoadPos[client], 0);
			TalentTreeValues[client]		= a_Menu_Talents.Get(LoadPos[client], 1);

			if (GetKeyValueIntAtPos(TalentTreeValues[client], IS_SUB_MENU_OF_TALENTCONFIG) == 1) {

				LoadPos[client]++;
				continue;
			}
			theresult						= GetKeyValueIntAtPos(TalentTreeValues[client], IS_TALENT_TYPE);
			if (theresult <= 0) {

				LoadPos[client]++;
				continue;
			}
			break;
		}
	}
	else {

		for (int i = LoadPos[client]; i < size; i++) {

			//TalentTreeKeys[client]			= a_Menu_Talents.Get(i, 0);
			TalentTreeValues[client]		= a_Menu_Talents.Get(i, 1);

			if (GetKeyValueIntAtPos(TalentTreeValues[client], IS_SUB_MENU_OF_TALENTCONFIG) == 1) continue;// ||
				//GetKeyValueInt(TalentTreeKeys[client], TalentTreeValues[client], "is survivor class role?") == 1) continue;
			LoadPos[client] = i;
			break;
		}
	}

	if (LoadPos[client] < size) {

		a_Database_Talents.GetString(LoadPos[client], text, sizeof(text));
		// !bIsTalentTwo[client]
		if (!IsTalentTwo) Format(tquery, sizeof(tquery), "SELECT `steam_id`, `%s` FROM `%s` WHERE (`steam_id` = '%s');", text, TheDBPrefix, key);
		else Format(tquery, sizeof(tquery), "SELECT `steam_id`, `%s`, `%s xp` FROM `%s` WHERE (`steam_id` = '%s');", text, text, TheDBPrefix, key);
		//PrintToChat(client, "FULL STOP %s", tquery);
		hDatabase.Query(QueryResults_LoadTalentTrees, tquery, client);
	}
	if (IsTalentTwo) {

		int ActionSlots = iActionBarSlots;
		Format(tquery, sizeof(tquery), "SELECT `steam_id`");
		for (int i = 0; i < ActionSlots; i++) {

			Format(tquery, sizeof(tquery), "%s, `aslot%d`", tquery, i+1);
		}
		Format(tquery, sizeof(tquery), "%s, `disab`, `primarywep`, `secondwep`", tquery);

		if (StrEqual(profilekey, "none")) Format(tquery, sizeof(tquery), "%s FROM `%s` WHERE (`steam_id` = '%s');", tquery, TheDBPrefix, key);
		else Format(tquery, sizeof(tquery), "%s FROM `%s` WHERE (`steam_id` = '%s');", tquery, TheDBPrefix, profilekey);
		hDatabase.Query(QueryResults_LoadActionBar, tquery, client);
	}
}


public QueryResults_LoadActionBar(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl != INVALID_HANDLE) {

		char text[512];
		char key[64];
		int IsDisab = 0;
		int ActionSlots = iActionBarSlots;
		bool IsFound = false;

		if (client == -1 || !IsLegitimateClient(client) || IsLegitimateClient(client) && GetClientTeam(client) != TEAM_SURVIVOR && IsFakeClient(client)) return;
		if (ActionBar[client].Length != ActionSlots) ActionBar[client].Resize(ActionSlots);

		while (hndl.FetchRow()) {

			hndl.FetchString(0, key, sizeof(key));
			//client = FindClientWithAuthString(key);
			//if (client == -1 || IsLegitimateClient(client) && GetClientTeam(client) != TEAM_SURVIVOR && IsFakeClient(client)) return;
			for (int i = 0; i < ActionSlots; i++) {

				hndl.FetchString(i+1, text, sizeof(text));
				ActionBar[client].SetString(i, text);
			}
			IsDisab = hndl.FetchInt(ActionSlots+1);
			if (IsDisab == 0) DisplayActionBar[client] = false;
			else DisplayActionBar[client] = true;

			hndl.FetchString(ActionSlots+2, text, sizeof(text));
			hWeaponList[client].SetString(0, text);
				
			hndl.FetchString(ActionSlots+3, text, sizeof(text));
			hWeaponList[client].SetString(1, text);

			GiveProfileItems(client);

			IsFound = true;
		}

		if (IsFound && !IsFakeClient(client)) PrintToChat(client, "\x04I have loaded your player data successfully."); //PrintToChat(client, "%T", "Action Bar Loaded", client, orange, blue);
		b_IsLoading[client] = false;
		bIsTalentTwo[client] = false;
	}
	else {
		
		SetFailState("Error: %s", error);
		return;
	}
}

stock TotalPointsAssigned(int client) {

	int count = 0;
	int MaxTalents = MaximumPlayerUpgrades(client);
	int currentValue = 0;
	//decl String:TalentName[64];

	int size = a_Database_PlayerTalents[client].Length;
	for (int i = 0; i < size; i++) {

		//TalentsAssignedKeys[client]		= a_Menu_Talents.Get(i, 0);
		TalentsAssignedValues[client]	= a_Menu_Talents.Get(i, 1);

		if (GetKeyValueIntAtPos(TalentsAssignedValues[client], IS_TALENT_TYPE) == 1) continue;
		//if (GetKeyValueInt(TalentsAssignedKeys[client], TalentsAssignedValues[client], "is survivor class role?") == 1) continue;
		if (GetKeyValueIntAtPos(TalentsAssignedValues[client], IS_SUB_MENU_OF_TALENTCONFIG) == 1) continue;
		currentValue = a_Database_PlayerTalents[client].Get(i);
		if (currentValue > 0) count += currentValue;
	}
	if (count > MaxTalents) ChallengeEverything(client);
	else return count;
	return 0;
}

stock LoadStoreData(client, char[] key) {

	/*client = FindClientWithAuthString(key, true);
	if (!IsLegitimateClient(client)) return;

	if (a_Store_Player[client].Length != a_Store.Length) a_Store_Player[client].Resize(a_Store.Length);

	decl String:text[64];
	decl String:tquery[1024];

	decl String:dbpref[64];
	GetConfigValue(dbpref, sizeof(dbpref), "database prefix?");
	//decl String:key[64];
	//GetClientAuthString(client, key, sizeof(key));

	b_IsLoadingStore[client] = true;
	LoadPosStore[client] = 0;

	LoadStoreSection[client]		=	a_Store.Get(0, 2);
	Handle:LoadStoreSection[client].GetString(0, text, sizeof(text));
	Format(tquery, sizeof(tquery), "SELECT `steam_id`, `%s` FROM `%s` WHERE (`steam_id` = '%s');", text, dbpref, key);
	hDatabase.Query(QueryResults_LoadStoreData, tquery, client);*/
}

/*public QueryResults_LoadStoreData(Handle:owner, Handle:hndl, const String:error[], any:client) {

	if (hndl != INVALID_HANDLE) {

		decl String:text[512];
		decl String:tquery[1024];
		decl String:dbpref[64];
		decl String:key[64];
		GetConfigValue(dbpref, sizeof(dbpref), "database prefix?");

		while (hndl.FetchRow()) {

			hndl.FetchString(0, key, sizeof(key));
			client = FindClientWithAuthString(key, true);
			if (!IsLegitimateClient(client)) return;

			if (LoadPosStore[client] == 0) {

				for (new i = 0; i < a_Store.Length; i++) {

					a_Store_Player[client].SetString(i, "0");
				}
			}

			if (LoadPosStore[client] < a_Store.Length) {

				hndl.FetchString(1, text, sizeof(text));
				a_Store_Player[client].SetString(LoadPosStore[client], text);

				LoadPosStore[client]++;
				if (LoadPosStore[client] < a_Store.Length) {

					LoadStoreSection[client]		=	a_Store.Get(LoadPosStore[client], 2);
					Handle:LoadStoreSection[client].GetString(0, text, sizeof(text));
					Format(tquery, sizeof(tquery), "SELECT `steam_id`, `%s` FROM `%s` WHERE (`steam_id` = '%s');", text, dbpref, key);
					hDatabase.Query(QueryResults_LoadStoreData, tquery, client);
				}
				else {

					b_IsLoadingStore[client] = false;
				}
			}
			else {

				b_IsLoadingStore[client] = false;
			}
		}
	}
	else {
		
		SetFailState("Error: %s", error);
		return;
	}
}*/

/*bool:HasIdlePlayer(int client) {

	if (IsSurvivorBot(client)) {

		new SpectatorSurvivor = GetClientOfUserId(GetEntData(client, FindSendPropInfo("SurvivorBot", "m_humanSpectatorUserID"))); 
		if (IsLegitimateClient(SpectatorSurvivor)) return true;
	}
	return false;
}*/

public OnClientDisconnect(client)
{
	if (IsClientInGame(client)) {
		if (IsFakeClient(client)) {
			//LogMessage("bot removed, setting to not loaded.");
			b_IsLoaded[client] = false;
		}
		bTimersRunning[client] = false;

		if (ISEXPLODE[client] != INVALID_HANDLE) {

			KillTimer(ISEXPLODE[client]);
			ISEXPLODE[client] = INVALID_HANDLE;
		}
		fOnFireDebuff[client] = 0.0;
		IsGroupMemberTime[client] = 0;
		if (ZoomcheckDelayer[client] != INVALID_HANDLE) {
			KillTimer(ZoomcheckDelayer[client]);
			ZoomcheckDelayer[client] = INVALID_HANDLE;
		}
		ChangeHook(client);

		/*if (IsValidEntity(iChaseEnt[client])) {

			AcceptEntityInput(iChaseEnt[client], "Kill");
		}*/
		if(iChaseEnt[client] && EntRefToEntIndex(iChaseEnt[client]) != INVALID_ENT_REFERENCE) AcceptEntityInput(iChaseEnt[client], "Kill");
		iChaseEnt[client] = -1;
		//bIsHideThreat[client] = true;
		iThreatLevel[client] = 0;
		//IsLoadingClassData[client] = false;
		bRushingNotified[client] = false;
		ClientActiveStance[client] = 0;
		//ExperienceLevel[client] = 0;
		//ExperienceOverall[client] = 0;
		//bIsNewClass[client] = false;
		b_IsLoadingTrees[client] = false;
		b_IsLoadingStore[client] = false;
		b_IsLoading[client] = false;
		bIsTalentTwo[client] = false;
		bTimersRunning[client] = false;
		//b_IsLoaded[client] = false;
		bIsMeleeCooldown[client] = false;
		shotgunCooldown[client] = false;
		b_IsInSaferoom[client] = false;
		bIsInCheckpoint[client] = false;
		//b_IsArraysCreated[client] = false;
		ResetData(client);
		//PlayerLevel[client] = 0;
		//Rating[client] = 0;
		//RatingHandicap[client] = 0;
		//bIsHandicapLocked[client] = false;
		//BestRating[client] = 0;
		//DisplayActionBar[client] = false;
		//MyBirthday[client] = 0;
		Format(ProfileLoadQueue[client], sizeof(ProfileLoadQueue[]), "none");
		//Format(ClassLoadQueue[client], sizeof(ClassLoadQueue[]), "none");
		//IsGroupMember[client] = false;
		if (IsPlayerAlive(client) && eBackpack[client] > 0 && IsValidEntity(eBackpack[client])) {

			AcceptEntityInput(eBackpack[client], "Kill");
			eBackpack[client] = 0;
		}
		//ToggleTank(client, true);
	}
}

public ReadyUp_IsClientLoaded(int client) {

	//ChangeHook(client, true);	// we re-hook new players to the server.
	HealingContribution[client] = 0;
	TankingContribution[client] = 0;
	DamageContribution[client] = 0;
	PointsContribution[client] = 0.0;
	HexingContribution[client] = 0;
	BuffingContribution[client] = 0;
	RUP_IsClientLoaded(client);
	CheckDifficulty();
}

stock RUP_IsClientLoaded(int client) {

	CreateTimer(1.0, Timer_InitializeClientLoad, client, TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_InitializeClientLoad(Handle timer, any client) {
	if (!IsLegitimateClient(client)) return Plugin_Stop;
	float teleportIntoSaferoom[3];
	if (StrEqual(TheCurrentMap, "zerowarn_1r", false)) {
		teleportIntoSaferoom[0] = 4087.998291;
		teleportIntoSaferoom[1] = 11974.557617;
		teleportIntoSaferoom[2] = -300.968750;
		TeleportEntity(client, teleportIntoSaferoom, NULL_VECTOR, NULL_VECTOR);
	}
	if (b_IsLoaded[client]) return Plugin_Stop;
	ImmuneToAllDamage[client] = false;
	//ToggleTank(client, true);
	//ChangeHook(client);
	bTimersRunning[client] = false;
	b_IsInSaferoom[client] = true;
	bIsInCheckpoint[client] = false;
	eBackpack[client] = 0;
	ClientActiveStance[client] = 0;
	//bIsNewClass[client] = false;
	bIsNewPlayer[client] = false;
	IsPvP[client] = 0;
	b_IsLoadingTrees[client] = false;
	b_IsLoadingStore[client] = false;
	b_IsLoading[client] = false;
	bIsInCombat[client] = false;
	RatingHandicap[client] = 0;
	bIsHandicapLocked[client] = false;
	DisplayActionBar[client] = false;
	bRushingNotified[client] = false;
	MyBirthday[client] = 0;
	//IsLoadingClassData[client] = false;
	Format(ProfileLoadQueue[client], sizeof(ProfileLoadQueue[]), "none");
	//Format(ClassLoadQueue[client], sizeof(ClassLoadQueue[]), "none");
	bIsGiveProfileItems[client] = false;
	InfectedHealth[client].Clear();
	ActionBar[client].Resize(iActionBarSlots);
	IsClientLoadedEx(client);
	return Plugin_Stop;
}

stock IsClientLoadedEx(int client) {

	/*decl String:ClientName[64];
	GetClientName(client, ClientName, sizeof(ClientName));*/
	if (GetClientTeam(client) == TEAM_INFECTED && IsFakeClient(client)) return;	// only human players.
	//LogToFile(LogPathDirectory, "%N is loaded.", client);

	/*if (!b_IsHooked[client] && GetClientTeam(client) == TEAM_SURVIVOR) {

		b_IsHooked[client] = true;
		SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	}*/
	//ChangeHook(client, true);
	OnClientLoaded(client);
}

stock OnClientLoaded(client, bool IsHooked = false) {

	//if (!IsClientConnected(client)) return;
	if (b_IsLoaded[client]) {
		if (GetClientTeam(client) == TEAM_SURVIVOR) GiveProfileItems(client);
		return;
	}
	bTimersRunning[client] = false;
	b_IsLoaded[client] = true;
	IsGroupMemberTime[client] = 0;
	Format(ProfileLoadQueue[client], sizeof(ProfileLoadQueue[]), "none");
	/*if (!b_IsHooked[client]) {

		b_IsHooked[client] = true;
		SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	}*/
	ApplyDebuffCooldowns[client].Clear();
	if (ISFROZEN[client] != INVALID_HANDLE) {
		KillTimer(ISFROZEN[client]);
		ISFROZEN[client] = INVALID_HANDLE;
	}
	FreeUpgrades[client] = 0;
	bIsHideThreat[client] = true;
	iThreatLevel[client] = 0;
	iChaseEnt[client] = -1;
	MyStatusEffects[client] = 0;
	ExperienceLevel[client] = 0;
	ExperienceOverall[client] = 0;
	iIsLevelingPaused[client] = 0;
	iIsBulletTrails[client] = 0;

	RatingHandicap[client] = 0;
	Rating[client] = 0;
	BestRating[client] = 0;
	bIsDisconnecting[client] = false;
	bJetpack[client] = false;
	bEquipSpells[client] = false;
	IsPvP[client] = 0;
	//ToggleTank(client, true);

	//bIsClassAbilities[client] = false;
	LoadTarget[client] = -1;
	bIsTalentTwo[client] = false;
	//CheckGamemode();
	LoadDelay[client] = false;
	b_IsLoading[client] = false;
	b_IsLoadingStore[client] = false;
	b_IsLoadingTrees[client] = false;
	HealImmunity[client] = false;
	LastAttackedUser[client] = -1;
	if (b_IsActiveRound) b_IsInSaferoom[client] = false;
	else b_IsInSaferoom[client] = true;
	bIsSurvivorFatigue[client] = true;
	//b_ActiveThisRound[client] = false;
	PreviousRoundIncaps[client] = 1;
	Points[client] = 0.0;
	b_HasDeathLocation[client] = false;
	PlayerLevel[client] = 0;
	UpgradesAvailable[client] = 0;
	UpgradesAwarded[client] = 0;
	SurvivorStamina[client] = 0;
	SurvivorStaminaTime[client] = 0.0;
	CombatTime[client] = 0.0;
	bIsInCombat[client] = false;
	MovementSpeed[client] = 1.0;
	UseItemTime[client] = 0.0;
	AmmoTriggerCooldown[client] = false;
	ExplosionCounter[client][0] = 0.0;
	ExplosionCounter[client][1] = 0.0;
	HealingContribution[client] = 0;
	TankingContribution[client] = 0;
	DamageContribution[client] = 0;
	PointsContribution[client] = 0.0;
	HexingContribution[client] = 0;
	BuffingContribution[client] = 0;
	RespawnImmunity[client] = false;
	b_IsFloating[client] = false;
	ISDAZED[client] = 0.0;
	bIsCrushCooldown[client] = false;
	bIsBurnCooldown[client] = false;
	b_IsInSaferoom[client] = true;

	Format(ActiveSpecialAmmo[client], sizeof(ActiveSpecialAmmo[]), "none");
	if (!b_IsCheckpointDoorStartOpened) {

		bIsEligibleMapAward[client] = false;
	}
	else {

		bIsEligibleMapAward[client] = true;
	}
	CreateTimer(1.0, Timer_LoadData, client, TIMER_FLAG_NO_MAPCHANGE);

	if (!IsSurvivorBot(client)) {	// unfortunately, survivor bots triggering in this way seem to cause a server crash

		char thetext[64];
		GetConfigValue(thetext, sizeof(thetext), "enter server flags?");

		if (StrContains(thetext, "-", false) == -1) {

			if (!HasCommandAccess(client, thetext)) KickClient(client, "\nYou do not have the privileges\nto access this server.\n");
		}
	}
	/*if (StrEqual(TheCurrentMap, "zerowarn_1r", false)) {
		new Float:teleportIntoSaferoom[3];
		teleportIntoSaferoom[0] = 4087.998291;
		teleportIntoSaferoom[1] = 11974.557617;
		teleportIntoSaferoom[2] = -269.968750;
		TeleportEntity(client, teleportIntoSaferoom, NULL_VECTOR, NULL_VECTOR);
	}*/
}

public Action Timer_LoadData(Handle timer, any client) {

	if (IsClientInGame(client)) {

		ResetData(client);
		char key[512];
		char TheName[64];

		ChangeHook(client, true);

		if (IsSurvivorBot(client)) {

			GetSurvivorBotName(client, TheName, sizeof(TheName));
			Format(key, sizeof(key), "%s%s", sBotTeam, TheName);
		}
		GetClientAuthId(client, AuthId_Steam2, key, sizeof(key));
		LogMessage("Client is loaded, %N of %s", client, key);

		CreateNewPlayer(client);	// it only creates a new player if one doesn't exist.
	}
	else if (IsClientConnected(client)) return Plugin_Continue;
	return Plugin_Stop;
}

public Action Timer_LoggedUsers(Handle timer, any client) {

	if (!IsLegitimateClient(client)) return Plugin_Stop;
	
	//CheckGroupStatus(client);
	if (IsPlayerAlive(client) && (GetClientTeam(client) == TEAM_SURVIVOR || IsSurvivorBot(client))) {

		//VerifyAllActionBars(client);	// in case they don't have the gear anymore to support it?
		//IsLogged(client, true);		// Only log them if the player isn't alive.
		return Plugin_Stop;
	}
	if (IsLogged(client)) {

		if (!IsFakeClient(client)) {

			if (ReadyUp_GetGameMode() != 3) PrintToChat(client, "%T", "rejoining too fast", client, orange);
			else PrintToChat(client, "%T", "rejoining too fast survival", client, orange);
		}
		return Plugin_Stop;
	}
	IsLogged(client, true);
	return Plugin_Stop;
}

stock bool IsLogged(client, bool InsertID = false) {

	char SteamID[512];
	char TheName[64];
	char text[64];
	if (IsSurvivorBot(client)) {

		GetSurvivorBotName(client, TheName, sizeof(TheName));
		Format(SteamID, sizeof(SteamID), "%s%s", sBotTeam, TheName);
	}
	else {

		GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
	}
	//if (IsLegitimateClientAlive(client) && GetClientTeam(client) == TEAM_SURVIVOR) return true;
	if (!InsertID) {

		int size = LoggedUsers.Length;
		for (int i = 0; i < size; i++) {

			LoggedUsers.GetString(i, text, sizeof(text));
			if (StrEqual(SteamID, text)) return true;
		}
		return false;
	}
	LoggedUsers.PushString(SteamID);
	FindARespawnTarget(client);
	return true;
}

public Action CMD_RespawnYumYum(int client, int args) {

	if (GetClientTeam(client) == TEAM_SURVIVOR && !IsPlayerAlive(client)) {

		for (int i = 1; i <= MaxClients; i++) {

			if (IsSurvivorBot(i) && IsPlayerAlive(i)) {

				FindARespawnTarget(client, i);
				break;
			}
		}
	}
}

stock FindARespawnTarget(client, sacrifice = -1) {

	if (!IsPlayerAlive(client)) {

		SDKCall(hRoundRespawn, client);
		for (int i = 1; i <= MaxClients; i++) {
			if (!IsLegitimateClientAlive(i) || GetClientTeam(i) != TEAM_SURVIVOR || i == client) continue;
			MyRespawnTarget[client] = i;
			CreateTimer(1.0, TeleportToMyTarget, client, TIMER_FLAG_NO_MAPCHANGE);
			break;
		}
		if (IsLegitimateClient(sacrifice)) {

			char MyName[64];
			GetClientName(client, MyName, sizeof(MyName));
			PrintToChatAll("%t", "sacrificed a bot to respawn", white, blue, MyName, orange);
			IncapacitateOrKill(sacrifice, _, _, true);
		}
	}
}

public Action TeleportToMyTarget(Handle timer, any client) {

	if (!IsLegitimateClientAlive(client) || !IsLegitimateClientAlive(MyRespawnTarget[client])) return Plugin_Stop;
	float TeleportPos[3];
	GetClientAbsOrigin(MyRespawnTarget[client], TeleportPos);
	TeleportEntity(client, TeleportPos, NULL_VECTOR, NULL_VECTOR);

	return Plugin_Stop;
}

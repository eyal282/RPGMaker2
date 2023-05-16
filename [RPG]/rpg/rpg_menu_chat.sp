
#pragma newdecls required

stock bool StrExistsInArrayValue(char[] text, ArrayList Array) {

	int size						=	Array.Length;
	ArrayList Values;

	char target[64];

	Values							=	new ArrayList(8);

	for (int i = 0; i < size; i++) {

		Values						=	Array.Get(i, 1);
		int size2					=	Values.Length;

		for (int ii = 0; ii < size2; ii++) {

			Values.GetString(ii, target, sizeof(target));
			if (StrEqual(text, target, false)) {

				delete Values;
				return true;
			}
		}
	}
	delete Values;
	return false;
}

void BuildChatSettingsMenu(int client) {

	Menu menu					=	new Menu(BuildChatSettingsHandle);

	char text[512];
	Format(text, sizeof(text), "%T", "Chat Settings (Reserve)", client);
	menu.SetTitle(text);
	
	char key[64];
	char Name[64];
	char Name_Temp[64];
	
	int size						=	a_ChatSettings.Length;

	for (int i = 0; i < size; i++) {

		MenuKeys[client]			=	a_ChatSettings.Get(i, 0);
		MenuValues[client]			=	a_ChatSettings.Get(i, 1);
		MenuSection[client]			=	a_ChatSettings.Get(i, 2);

		MenuSection[client].GetString(0, Name, sizeof(Name));
		if (!StrEqual(ChatSettingsName[client], "none", false) && !StrEqual(ChatSettingsName[client], Name, false)) continue;

		int size2					=	MenuKeys[client].Length;

		if (!StrEqual(ChatSettingsName[client], "none", false)) {

			for (int ii = 0; ii < size2; ii++) {

				MenuKeys[client].GetString(ii, key, sizeof(key));
				if (StrEqual(key, "EOM", false)) continue;
				Format(Name_Temp, sizeof(Name_Temp), "%T", key, client);
				menu.AddItem(Name_Temp, Name_Temp);

			}
		}
		else {

			Format(Name_Temp, sizeof(Name_Temp), "%T", Name, client);
			menu.AddItem(Name_Temp, Name_Temp);
		}
	}

	menu.ExitBackButton = true;
	menu.ExitButton = false;
	menu.Display(client, 0);
}

public int BuildChatSettingsHandle(Handle menu, MenuAction action, int client, int slot) {

	if (action == MenuAction_Select) {

		char value[64];
		char Name[64];

		int size					=	a_ChatSettings.Length;

		for (int i = 0; i < size; i++) {

			MenuValues[client]		=	a_ChatSettings.Get(i, 1);
			MenuSection[client]		=	a_ChatSettings.Get(i, 2);

			MenuSection[client].GetString(0, Name, sizeof(Name));

			if (StrEqual(ChatSettingsName[client], "none", false) && i == slot) {

				// When ChatSettingsName is "none" there are only options equal to the number of sections.
				Format(ChatSettingsName[client], sizeof(ChatSettingsName[]), "%s", Name);
				BuildChatSettingsMenu(client);
				return;
			}
			if (!StrEqual(ChatSettingsName[client], "none", false)) {

				int size2			=	MenuKeys[client].Length;
				for (int ii = 0; ii < size2; ii++) {

					MenuValues[client].GetString(ii, value, sizeof(value));
					if (StrEqual(value, "EOM", false)) continue;
					if (ii == slot) {

						if (StrEqual(ChatSettingsName[client], "tag colors", false)) ChatSettings[client].SetString(0, value);
						else if (StrEqual(ChatSettingsName[client], "chat colors", false)) ChatSettings[client].SetString(2, value);

						Format(ChatSettingsName[client], sizeof(ChatSettingsName[]), "none");
						BuildChatSettingsMenu(client);
						return;
					}
				}
			}
		}
	}
	else if (action == MenuAction_Cancel) {

		if (slot == MenuCancel_ExitBack) BuildMenu(client);
	}
	else if (action == MenuAction_End) {

		delete menu;
	}
}

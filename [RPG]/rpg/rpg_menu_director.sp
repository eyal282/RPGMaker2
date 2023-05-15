
#pragma newdecls required

stock void BuildDirectorPriorityMenu(int client) {

	Handle menu						=	new Menu(BuildDirectorPriorityMenuHandle);

	int size							=	a_DirectorActions.Length;
	char Name[64];
	char Name_t[64];

	char key[64];
	char value[64];

	int Priority						=	0;

	for (int i = 0; i < size; i++) {

		MenuKeys[client]							=	a_DirectorActions.Get(i, 0);
		MenuValues[client]							=	a_DirectorActions.Get(i, 1);
		MenuSection[client]							=	a_DirectorActions.Get(i, 2);

		MenuSection[client].GetString(0, Name, sizeof(Name));
		Format(Name_t, sizeof(Name_t), "%T", Name, client);

		int size2						=	MenuKeys[client].Length;
		for (int ii = 0; ii < size2; ii++) {

			MenuKeys[client].GetString(ii, key, sizeof(key));
			MenuValues[client].GetString(ii, value, sizeof(value));

			if (StrEqual(key, "priority?")) Priority		=	StringToInt(value);
		}
		Format(Name_t, sizeof(Name_t), "%s (%d / %d)", Name_t, Priority, GetConfigValueInt("director priority maximum?"));
		menu.AddItem(Name_t, Name_t);
	}
	menu.ExitBackButton = false;
	menu.Display(client, 0);
}

public int BuildDirectorPriorityMenuHandle(Handle menu, MenuAction action, int client, int slot) {

	if (action == MenuAction_Select) {

		char key[64];
		char value[64];

		char Priority[64];
		Format(Priority, sizeof(Priority), "0");
		int PriorityMaximum				=	GetConfigValueInt("director priority maximum?");

		MenuKeys[client]							=	a_DirectorActions.Get(slot, 0);
		MenuValues[client]							=	a_DirectorActions.Get(slot, 1);

		int size						=	MenuKeys[client].Length;

		for (int i = 0; i < size; i++) {

			MenuKeys[client].GetString(i, key, sizeof(key));
			MenuValues[client].GetString(i, value, sizeof(value));

			if (StrEqual(key, "priority?")) {

				Format(Priority, sizeof(Priority), "%s", value);

				if (StringToInt(Priority) < PriorityMaximum) Format(Priority, sizeof(Priority), "%d", StringToInt(Priority) + 1);
				else Format(Priority, sizeof(Priority), "1");

				MenuValues[client].SetString(i, Priority);
				a_DirectorActions.Set(slot, MenuValues[client], 1);
				break;
			}
		}
		BuildDirectorPriorityMenu(client);
	}
	else if (action == MenuAction_End) {

		delete menu;
	}
}

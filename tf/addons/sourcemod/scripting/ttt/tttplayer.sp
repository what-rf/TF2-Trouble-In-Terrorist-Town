StringMap hMap[MAXPLAYERS+1];

methodmap TTTPlayer
{
	public TTTPlayer(const int index)
	{
		return view_as< TTTPlayer >(index);
	}

	property int index 
	{
		public get()			{ return view_as< int >(this); }
	}

	property StringMap hMap
	{
	public get()
		{
			if (hMap[this.index] == INVALID_HANDLE)
			{
				PrintToServer("[TTT WARNING] hMap[%d] was uninitialized! Fixing now...", this.index);
				hMap[this.index] = new StringMap();
			}
			return hMap[this.index];
		}
	}


	public any GetProp(const char[] key)
	{
		any val; 
		this.hMap.GetValue(key, val);
		return val;
	}
	public void SetProp(const char[] key, any val)
	{
		this.hMap.SetValue(key, val);
	}
	public float GetPropFloat(const char[] key)
	{
		float val; 
		this.hMap.GetValue(key, val);
		return val;
	}
	public void SetPropFloat(const char[] key, float val)
	{
		this.hMap.SetValue(key, val);
	}
	/*public int GetPropString(const char[] key, char[] buffer, int maxlen)
	{
		return this.hMap.GetString(key, buffer, maxlen);
	}
	public void SetPropString(const char[] key, const char[] val)
	{
		this.hMap.SetString(key, val);
	}
	public void GetPropArray(const char[] key, any[] buffer, int maxlen)
	{
		this.hMap.GetArray(key, buffer, maxlen);
	}
	public void SetPropArray(const char[] key, const any[] val, int maxlen)
	{
		this.hMap.SetArray(key, val, maxlen);
	}*/

	property Role role
	{
		public get() 				{ return this.GetProp("role"); }
		public set( const Role i )	{ this.SetProp("role", i); }
	}

	property Role killerRole
	{
		public get() 				{ return this.GetProp("killerRole"); }
		public set( const Role i )	{ this.SetProp("killerRole", i); }
	}

	property int killCount
	{
		public get() 				{ return this.GetProp("killCount"); }
		public set( const int i )	{ this.SetProp("killCount", i); }
	}

	property int credits
	{
		public get() 				{ return this.GetProp("credits"); }
		public set( const int i )	{ this.SetProp("credits", i); }
	}

	property int karma
	{
		public get() 				{ return this.GetProp("karma"); }
		public set( const int i )	{ this.SetProp("karma", i); }
	}

	property float deathTime
	{
		public get() 				{ return this.GetPropFloat("deathTime"); }
		public set( const float i )	{ this.SetPropFloat("deathTime", i); }
	}

	public int SpawnItem(char[] name, int index, int level=1, int qual=0, const char[] att = NULL_STRING)
	{
		Handle hWeapon = TF2Items_CreateItem(OVERRIDE_ALL);
		int client = this.index;
		
		TF2Items_SetClassname(hWeapon, name);
		TF2Items_SetItemIndex(hWeapon, index);
		TF2Items_SetLevel(hWeapon, level);
		TF2Items_SetQuality(hWeapon, qual);
		
		char atts[32][32];
		int count = ExplodeString(att, " ; ", atts, 32, 32);
		if (att[0])
		{
			TF2Items_SetNumAttributes(hWeapon, count / 2);
			int i2 = 0;
			for (int i = 0; i < count; i += 2)
			{
				TF2Items_SetAttribute(hWeapon, i2, StringToInt(atts[i]), StringToFloat(atts[i + 1]));
				i2++;
			}
		}
		else 
			TF2Items_SetNumAttributes(hWeapon, 0);
		
		int entity = TF2Items_GiveNamedItem(client, hWeapon);
		SetEntProp(entity, Prop_Send, "m_bValidatedAttachedEntity", true);
		
		if (StrContains(name, "tf_wearable") == 0) 
			SDKCall(g_hSDKCallEquipWearable, client, entity);
		else 
			EquipPlayerWeapon(client, entity);
		
		delete hWeapon;
		return entity;
	}

	public void GiveInitialWeapon()
	{
		int client = this.index;
		TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
		TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
		int wep;
		switch (TF2_GetPlayerClass(client))
		{
			case TFClass_Soldier:
			{
				wep = this.SpawnItem("tf_weapon_shotgun_soldier", 10);
			}
			case TFClass_Pyro:
			{
				wep = this.SpawnItem("tf_weapon_shotgun_pyro", 12);
			}
			case TFClass_Heavy:
			{
				wep = this.SpawnItem("tf_weapon_shotgun_hwg", 11);
			}
			default: // because bots fuck up things
			{
				wep = this.SpawnItem("tf_weapon_shotgun_soldier", 10);
			}
		}
		SetAmmo(client, wep, 16);
	}

	public void ShowRoleMenu(Role role = NOROLE)
	{
		Panel panel = new Panel();
		panel.SetTitle("[TF2] Trouble In Terrorist Town:");

		if (role == NOROLE)
			role = this.role;

		switch (role)
		{
			case INNOCENT:
			{
				panel.DrawItem("Você é um INOCENTE!");
				panel.DrawItem("SOBREVIVA para ganhar o round!");
				panel.DrawItem("Matar outros Inocentes abaixa seu KARMA, diminuindo seu DANO.");
			}

			case DETECTIVE:
			{
				panel.DrawItem("Você é um DETETIVE!");
				panel.DrawItem("Mate todos os TRAIDORES para ganhar o round!");
				panel.DrawItem("Aperte MOUSE2 para TRANSFORMAR! A Transformação cega todos por 7 segundos.");
				panel.DrawItem("Após TRANSFORMAR, aperte MOUSE2 para lançar um RAIO DE ENERGIA!");
				panel.DrawItem("Matar outros Inocentes abaixa seu KARMA, diminuindo seu DANO.");
			}

			case TRAITOR:
			{
				panel.DrawItem("Você é um TRAIDOR!");
				panel.DrawItem("Mate todos os INOCENTES para ganhar o round!");
				panel.DrawItem("Seus companheiros estão marcados somente para você!");
				panel.DrawItem("Aperte TAB para abrir a LOJA!");
			}

			case DISGUISER:
			{
				panel.DrawItem("Você é a FARSA!");
				panel.DrawItem("Mate todos os INOCENTES para ganhar o round!");
				panel.DrawItem("Seus companheiros estão marcados somente para você!");
				panel.DrawItem("Aperte MOUSE2 para matar seu alvo e ROUBAR seus cosmeticos.");
			}

			case NECROMANCER:
			{
				panel.DrawItem("Você é o NECROMANTE!");
				panel.DrawItem("Mate todos os INOCENTES para ganhar o round!");
				panel.DrawItem("Seus companheiros estão marcados somente para você!");
				panel.DrawItem("Enquanto vivo, aperte MOUSE2 para criar TERREMOTOS e chacoalhar as telas dos outros!");
				panel.DrawItem("Enquanto morto, digite 'RESPAWN' para REVIVER um TRAIDOR!");
			}

			case PESTILENCE:
			{
				panel.DrawItem("Você é a PESTILENCIA!");
				panel.DrawItem("Seus companheiros estão marcados somente para você!");
				panel.DrawItem("Mate todos os INOCENTES para ganhar o round!");
				panel.DrawItem("Você pode matar pelo TOQUE!");
				panel.DrawItem("Após tocar em um jogador, aperte MOUSE2 para matá-lo de qualquer distância!");
				char text[128];
				FormatEx(text, sizeof(text), "Você será EXPOSTO após ter %i vítimas.", g_cvExposeCount.IntValue);
				panel.DrawItem(text);
			}

			case THUNDER:
			{
				panel.DrawItem("Você é o TROVÃO!");
				panel.DrawItem("Mate todos os INOCENTES para ganhar o round!");
				panel.DrawItem("Seus companheiros estão marcados somente para você!");
				panel.DrawItem("Aperte MOUSE2 para dar CHOQUE em outros jogadores! (Sem Cooldown)");
				panel.DrawItem("Você será lançado para os céus após sua primeira vítima!");
				panel.DrawItem("Todos ganharão uma AWP com uma bala para te matar.");
			}

			default:
			{
				panel.DrawItem("Você não tem um cargo.");
				panel.DrawItem("Espere o round atual acabar!");
			}
		}

		panel.DrawItem("Aperte RELOAD para inspecionar um CORPO.");
		panel.Send(this.index, RoleMenu, 30);
		delete panel;
	}

	public void Setup()
	{
		int client = this.index;
		
		Swap(client, this.role == DETECTIVE ? TFTeam_Blue : TFTeam_Red);
		TF2_RegeneratePlayer(client);
		this.GiveInitialWeapon();
		this.ShowRoleMenu();
	}

	public void Reset()
	{
		int karma = this.karma;
		int credits = this.credits;

		this.hMap.Clear();

		this.karma = karma;
		this.credits = credits;
	}
};

public int RoleMenu(Menu menu, MenuAction action, int param1, int param2) {
	return;
 }
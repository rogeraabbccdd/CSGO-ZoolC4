#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <sdkhooks>

#pragma newdecls requiredw

#define VPATH "models/weapons/v_zoolc4.mdl"
#define WPATH "models/weapons/w_zoolc4.mdl"
#define DPATH "models/weapons/w_zoolc4_dropped.mdl"

int C4_VMODEL, C4_WMODEL;
int PlayerModelIndex[MAXPLAYERS+1];

public Plugin myinfo = 
{
	name = "Zool's C4 model",
	author = "Kento, Zool",
	description = "Change C4 models to Zool's C4 model",
	version = "1.0",
	url = "http://steamcommunity.com/id/kentomatoryoshika/"
};

public void OnPluginStart()
{
	// Hook
	HookEvent("player_spawn", Event_Spawn, EventHookMode_Post);
	HookEvent("bomb_planted", Event_BomPlanted);
}

public void OnMapStart() 
{ 
	// precache
	C4_VMODEL = PrecacheModel(VPATH, true);
	C4_WMODEL = PrecacheModel(WPATH, true);
	PrecacheModel(DPATH, true);

	// Download
	AddFileToDownloadsTable("materials/models/weapons/v_models/c4_source2/c4_bomb_bricks.vmt");
	AddFileToDownloadsTable("materials/models/weapons/v_models/c4_source2/c4_bomb_bricks_color_psd_a747451.vtf");
	AddFileToDownloadsTable("materials/models/weapons/v_models/c4_source2/c4_bomb_bricks_normal.vtf");
	AddFileToDownloadsTable("materials/models/weapons/v_models/c4_source2/c4_bomb_illuminated.vmt");
	AddFileToDownloadsTable("materials/models/weapons/v_models/c4_source2/c4_bomb_illuminated_color_psd_15fb58d0.vtf");
	AddFileToDownloadsTable("materials/models/weapons/v_models/c4_source2/c4_bomb_illuminated_gloss.vtf");
	AddFileToDownloadsTable("materials/models/weapons/v_models/c4_source2/c4_bomb_illuminated_illum_psd_a90d354.vtf");
	AddFileToDownloadsTable("materials/models/weapons/v_models/c4_source2/c4_bomb_illuminated_off.vmt");
	AddFileToDownloadsTable("materials/models/weapons/v_models/c4_source2/c4_bomb_pcb.vmt");
	AddFileToDownloadsTable("materials/models/weapons/v_models/c4_source2/c4_bomb_pcb_color_psd_7c6cebce.vtf");
	AddFileToDownloadsTable("materials/models/weapons/v_models/c4_source2/c4_bomb_pcb_gloss.vtf");
	AddFileToDownloadsTable("materials/models/weapons/v_models/c4_source2/c4_bomb_pipe.vmt");
	AddFileToDownloadsTable("materials/models/weapons/v_models/c4_source2/c4_bomb_pipe_color_psd_8c0a77ee.vtf");
	AddFileToDownloadsTable("materials/models/weapons/v_models/c4_source2/c4_bomb_pipe_gloss.vtf");
	AddFileToDownloadsTable("materials/models/weapons/v_models/c4_source2/c4_bomb_wires.vmt");
	AddFileToDownloadsTable("materials/models/weapons/v_models/c4_source2/c4_bomb_wires_color_psd_6ca3d918.vtf");
	AddFileToDownloadsTable("materials/models/weapons/v_models/c4_source2/c4_bomb_wires_normal.vtf");
	AddFileToDownloadsTable("models/weapons/v_zoolc4.ani");
	AddFileToDownloadsTable("models/weapons/v_zoolc4.dx90.vtx");
	AddFileToDownloadsTable("models/weapons/v_zoolc4.mdl");
	AddFileToDownloadsTable("models/weapons/v_zoolc4.vvd");
	AddFileToDownloadsTable("models/weapons/w_zoolc4.dx90.vtx");
	AddFileToDownloadsTable("models/weapons/w_zoolc4.mdl");
	AddFileToDownloadsTable("models/weapons/w_zoolc4.phy");
	AddFileToDownloadsTable("models/weapons/w_zoolc4.vvd");
	AddFileToDownloadsTable("models/weapons/w_zoolc4_dropped.dx90.vtx");
	AddFileToDownloadsTable("models/weapons/w_zoolc4_dropped.mdl");
	AddFileToDownloadsTable("models/weapons/w_zoolc4_dropped.phy");
	AddFileToDownloadsTable("models/weapons/w_zoolc4_dropped.vvd");
}

public void OnClientPutInServer(int client)
{
	// V
	SDKHook(client, SDKHook_WeaponSwitchPost, WeaponDeployPost);
	// W
	SDKHook(client, SDKHook_WeaponEquip, PostWeaponEquip);
	// D
	SDKHook(client, SDKHook_WeaponDropPost, WeaponDropPost);
}

// V model
public Action Event_Spawn(Event event, const char[] gEventName, bool iDontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	PlayerModelIndex[client] = Weapon_GetViewModelIndex(client);
}

public void WeaponDeployPost(int client, int iWeapon) 
{
	char iWeaponClass[64];
	GetEntityClassname(iWeapon, iWeaponClass, sizeof(iWeaponClass));
	if(StrEqual(iWeaponClass, "weapon_c4"))
	{
		// set model and skin
		SetEntProp(PlayerModelIndex[client], Prop_Send, "m_nModelIndex", C4_VMODEL);
		SetEntProp(iWeapon, Prop_Send, "m_nModelIndex", 0);
	}
}

// W model
public void PostWeaponEquip(int client, int iWeapon) 
{
	char sname[64];
	if(!GetEdictClassname(iWeapon, sname, 64)) return;

	if(StrEqual(sname, "weapon_c4"))
	{
		int iWorldModel = GetEntPropEnt(iWeapon, Prop_Send, "m_hWeaponWorldModel"); 
		if(IsValidEdict(iWorldModel))	SetEntProp(iWorldModel, Prop_Send, "m_nModelIndex", C4_WMODEL);

		SetEntProp(client, Prop_Send, "m_iAddonBits", GetEntProp(client, Prop_Send, "m_iAddonBits") & ~(1<<4));
	}
}

// D model
public void WeaponDropPost(int client, int iWeapon) 
{
	char sname[64];
	if(iWeapon < -1) return;
	if(!GetEdictClassname(iWeapon, sname, 64)) return;
	
	if(StrEqual(sname, "weapon_c4"))	CreateTimer(0.1, SetDropModel, EntIndexToEntRef(iWeapon));
}

// back model

public Action SetDropModel(Handle timer, any ref)
{
	int iWeapon =  EntRefToEntIndex(ref);
	if(iWeapon == INVALID_ENT_REFERENCE) return;
	SetEntityModel(iWeapon, DPATH);
}

// Get model index and prevent server from crash
int Weapon_GetViewModelIndex(int client)
{
	int iIndex = -1;
	
	// Find entity and return index
	while ((iIndex = FindEntityByClassname2(iIndex, "predicted_viewmodel")) != -1)
	{
		int iOwner = GetEntPropEnt(iIndex, Prop_Data, "m_hOwner");
		if (iOwner != client)	continue;
		return iIndex;
	}
	return -1;
}

// Get entity name
int FindEntityByClassname2(int iStartEnt, char[] sClassname)
{
	while (iStartEnt > -1 && !IsValidEntity(iStartEnt)) 
		iStartEnt--;
	
	return FindEntityByClassname(iStartEnt, sClassname);
}

// Planted model
public Action Event_BomPlanted(Handle event, const char [] name, bool dontBroadcast)
{
	int c4 = -1;
	c4 = FindEntityByClassname(c4, "planted_c4");
	if(IsValidEntity(c4))	SetEntityModel(c4, DPATH);
	return Plugin_Continue;
}

stock bool IsValidClient(int client)
{
	if (client <= 0) return false;
	if (client > MaxClients) return false;
	if (!IsClientConnected(client)) return false;
	return IsClientInGame(client);
}

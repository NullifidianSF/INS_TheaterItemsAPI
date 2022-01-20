/*
 * @Description: 
 *               中文INS服务器使用此插件请注明和鸣谢作者。
 * @Author: Gandor
 * @Github: https://github.com/gandor233
 * @Date: 2021-02-10 04:38:27
 * @LastEditTime: 2022-01-19 21:29:55
 * @LastEditors: Gandor
 * @FilePath: \SourceMod_1.10.0\TheaterItemsAPI.sp
 */
public Plugin myinfo = 
{
    name = "TheaterItemsAPI",
    author = "Gandor | 游而不擊 轉進如風",
    description = "Theater Items API For Insurgency(2014)",
    version = "1.0",
    url = "https://github.com/gandor233"
};

#pragma semicolon 1
// #include <sourcemod>
// #include <sdktools>
// #include <sdkhooks>
// #undef REQUIRE_PLUGIN
// #include <TheaterItemsAPI>
// #define REQUIRE_PLUGIN

#define DATA_SAVE_PATH           "cfg/theater_items"

ConVar mp_theater_override;
bool g_bNeedUpdateTheaterItems = true;

enum THEATER_ITEM_TABLE_TYPE
{
    THEATER_ITEM_TABLE_WAEPONS = 0,
    THEATER_ITEM_TABLE_WAEPON_UPGRADES,
    THEATER_ITEM_TABLE_EXPLOSIVES,
    THEATER_ITEM_TABLE_PLAYER_GEAR,
}
char g_cTheaterItemsTableNameList[][] = 
{
    "Weapons",
    "WeaponUpgrades",
    "Explosives",
    "PlayerGear",
};
char g_cTheaterItemsList[sizeof(g_cTheaterItemsTableNameList)][256][128];
int g_iTheaterItemsStringsCount[sizeof(g_cTheaterItemsTableNameList)];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    CreateNative("TI_GetTheaterItemIdByName", Native_GetTheaterItemIdByName);
    CreateNative("TI_GetWeaponItemName", Native_GetWeaponItemName);
    CreateNative("TI_GetWeaponUpgradeItemName", Native_GetWeaponUpgradeItemName);
    CreateNative("TI_GetExplosiveItemName", Native_GetExplosiveItemName);
    CreateNative("TI_GetPlayerGearItemName", Native_GetPlayerGearItemName);
    RegPluginLibrary("TheaterItemsAPI");
    return APLRes_Success;
}
public void OnPluginStart()
{
    char cPath[PLATFORM_MAX_PATH];
    Format(cPath, sizeof(cPath), DATA_SAVE_PATH);
    if (!DirExists(cPath))
        CreateDirectory(cPath, FPERM_U_READ|FPERM_U_WRITE|FPERM_U_EXEC|FPERM_G_READ|FPERM_G_EXEC|FPERM_O_READ|FPERM_O_EXEC);
    
    mp_theater_override = FindConVar("mp_theater_override");
    mp_theater_override.AddChangeHook(OnTheaterChange);
    
    RegAdminCmd("sm_update_theater_items", Command_UpdateTheaterItems, ADMFLAG_ROOT, "Force update the theater items name record list");

    RegAdminCmd("listweapons", Command_ListItemName, ADMFLAG_ROOT);
    RegAdminCmd("listweapon", Command_ListItemName, ADMFLAG_ROOT);
    RegAdminCmd("listupgrades", Command_ListItemName, ADMFLAG_ROOT);
    RegAdminCmd("listupg", Command_ListItemName, ADMFLAG_ROOT);
    RegAdminCmd("listexplosives", Command_ListItemName, ADMFLAG_ROOT);
    RegAdminCmd("listexp", Command_ListItemName, ADMFLAG_ROOT);
    RegAdminCmd("listplayergear", Command_ListItemName, ADMFLAG_ROOT);
    RegAdminCmd("listgear", Command_ListItemName, ADMFLAG_ROOT);
    
    g_bNeedUpdateTheaterItems = true;
    return;
}
public void OnConfigsExecuted()
{
    CreateTimer(5.0, CheckTheaterItemsDelay_Timer, _, TIMER_FLAG_NO_MAPCHANGE);
    return;
}
public void OnTheaterChange(ConVar convar, const char[] oldValue, const char[] newValue)
{
    g_bNeedUpdateTheaterItems = true;
    return;
}

// Function
public Action Command_ListItemName(int client, int args)
{
    char cCommand[65];
    GetCmdArg(0, cCommand, sizeof(cCommand));
    ReplaceString(cCommand, sizeof(cCommand), "list", "", false);
    for (int i = 0; i < sizeof(g_cTheaterItemsTableNameList); i++)
    {
        if (StrContains(g_cTheaterItemsTableNameList[i], cCommand, false) > -1)
        {
            PrintToServer("Listing %s [1~%d]", g_cTheaterItemsTableNameList[i], g_iTheaterItemsStringsCount[i]);
            PrintToConsoleAll("Listing %s [1~%d]", g_cTheaterItemsTableNameList[i], g_iTheaterItemsStringsCount[i]);
            for (int j = 1; j <= g_iTheaterItemsStringsCount[i]; j++)
            {
                PrintToServer("  %d - %s", j, g_cTheaterItemsList[i][j]);
                PrintToConsoleAll("  %d - %s", j, g_cTheaterItemsList[i][j]);
            }
            PrintToServer(" ");
            PrintToConsoleAll(" ");
            break;
        }
    }
    return Plugin_Handled;
}
public int GetTheaterItemIdByName(THEATER_ITEM_TABLE_TYPE iItemTableType, char[] cItemName)
{
    if (iItemTableType >= THEATER_ITEM_TABLE_WAEPONS && iItemTableType <= THEATER_ITEM_TABLE_PLAYER_GEAR)
    {
        for (int i = 1; i <= g_iTheaterItemsStringsCount[iItemTableType]; i++)
        {
            if (StrEqual(g_cTheaterItemsList[iItemTableType][i], cItemName, false))
            {
                PrintToServer("GetTheaterItemIdByName %s == %s - iUpgradeID: %d", cItemName, g_cTheaterItemsList[iItemTableType][i], i);
                return i;
            }
        }
    }

    return -1;
}

// Update
public Action Command_UpdateTheaterItems(int client, int args)
{
    RequestFrame(UpdateTheaterItems);
    return Plugin_Handled;
}
public Action CheckTheaterItemsDelay_Timer(Handle timer, int client)
{
    if (g_bNeedUpdateTheaterItems)
    {
        UpdateTheaterItems();
    }
    return Plugin_Stop;
}
public void UpdateTheaterItems()
{
    char cTheaterName[256];
    mp_theater_override.GetString(cTheaterName, sizeof(cTheaterName));
    
    char cFileName[PLATFORM_MAX_PATH];
    Format(cFileName, sizeof(cFileName), "%s/%s.cfg", DATA_SAVE_PATH, cTheaterName);
    
    File hFile = OpenFile(cFileName, "w");
    if (hFile == INVALID_HANDLE)
        LogError("Failed to open file %s", cFileName);
    
    char cListTheaterItemsOutput[32000];
    ServerCommandEx(cListTheaterItemsOutput, sizeof(cListTheaterItemsOutput), "listtheateritems");
    
    char cTheaterItems[500][64];
    ExplodeString(cListTheaterItemsOutput, "\n", cTheaterItems, sizeof(cTheaterItems), sizeof(cTheaterItems[]));
    
    int iTempTableIndex = 0;
    char cTempTableNameList[5][128];
    for (int i = 0; i < sizeof(cTheaterItems); i++)
    {
        if (strlen(cTheaterItems[i]) > 0)
        {
            if (StrContains(cTheaterItems[i], "Player Gear: ", false) > -1 || StrContains(cTheaterItems[i], "Explosives: ", false) > -1
             || StrContains(cTheaterItems[i], "Weapon Upgrades: ", false) > -1 || StrContains(cTheaterItems[i], "Weapons: ", false) > -1)
            {
                char cTheaterItemsTableName[128];
                cTheaterItemsTableName = cTheaterItems[i];
                ReplaceString(cTheaterItemsTableName, sizeof(cTheaterItemsTableName), " ", "", false);
                SplitString(cTheaterItemsTableName, ":", cTheaterItemsTableName, sizeof(cTheaterItemsTableName));
                cTempTableNameList[iTempTableIndex] = cTheaterItemsTableName;
                iTempTableIndex++;
                continue;
            }
        }
    }
    
    iTempTableIndex = 0;
    int iTableStringIndex = 0;
    int iTableIndex = GetTheaterItemsTableIndexByTableName(cTempTableNameList[iTempTableIndex]);
    if (hFile != INVALID_HANDLE)
        hFile.WriteLine("\"%s\"\n{", cTempTableNameList[iTempTableIndex]);
    for (int i = 0; i < sizeof(cTheaterItems); i++)
    {
        if (strlen(cTheaterItems[i]) > 0)
        {
            if (StrContains(cTheaterItems[i], "Player Gear: ", false) > -1 || StrContains(cTheaterItems[i], "Explosives: ", false) > -1
             || StrContains(cTheaterItems[i], "Weapon Upgrades: ", false) > -1 || StrContains(cTheaterItems[i], "Weapons: ", false) > -1)
            {
                iTempTableIndex++;
                iTableStringIndex = 0;
                if (strlen(cTempTableNameList[iTempTableIndex]) > 0)
                {
                    if (hFile != INVALID_HANDLE)
                        hFile.WriteLine("}\n\"%s\"\n{", cTempTableNameList[iTempTableIndex]);
                    iTableIndex = GetTheaterItemsTableIndexByTableName(cTempTableNameList[iTempTableIndex]);
                }
                continue;
            }
            
            if (iTableIndex >= 0)
            {
                iTableStringIndex++;
                if (hFile != INVALID_HANDLE)
                    hFile.WriteLine("\t\"%d\" \"%s\"", iTableStringIndex, cTheaterItems[i]);
                g_iTheaterItemsStringsCount[iTableIndex] = iTableStringIndex;
                g_cTheaterItemsList[iTableIndex][iTableStringIndex] = cTheaterItems[i];
            }
        }
    }
    if (hFile != INVALID_HANDLE)
    {
        hFile.WriteLine("}");
        hFile.Flush();
        hFile.Close();
    }
    return;
}
stock int GetTheaterItemsTableIndexByTableName(char[] cTableName)
{
    for (int i = 0; i <sizeof(g_cTheaterItemsTableNameList); i++)
    {
        if (StrEqual(g_cTheaterItemsTableNameList[i], cTableName, false))
            return i;
    }
    return -1;
}

// Native
public int Native_GetTheaterItemIdByName(Handle plugin, args)
{
    char cItemName[64];
    GetNativeString(2, cItemName, sizeof(cItemName));
    return GetTheaterItemIdByName(view_as<THEATER_ITEM_TABLE_TYPE>(GetNativeCell(1)), cItemName);
}
public int Native_GetWeaponItemName(Handle plugin, args)
{
    int iTableStringIndex = GetNativeCell(1);
    if (iTableStringIndex > 0 && iTableStringIndex <= g_iTheaterItemsStringsCount[THEATER_ITEM_TABLE_WAEPONS])
    {
        SetNativeString(2, g_cTheaterItemsList[THEATER_ITEM_TABLE_WAEPONS][iTableStringIndex], GetNativeCell(3));
        return true;
    }
    return false;
}
public int Native_GetWeaponUpgradeItemName(Handle plugin, args)
{
    int iTableStringIndex = GetNativeCell(1);
    if (iTableStringIndex > 0 && iTableStringIndex <= g_iTheaterItemsStringsCount[THEATER_ITEM_TABLE_WAEPON_UPGRADES])
    {
        SetNativeString(2, g_cTheaterItemsList[THEATER_ITEM_TABLE_WAEPON_UPGRADES][iTableStringIndex], GetNativeCell(3));
        return true;
    }
    return false;
}
public int Native_GetExplosiveItemName(Handle plugin, args)
{
    int iTableStringIndex = GetNativeCell(1);
    if (iTableStringIndex > 0 && iTableStringIndex <= g_iTheaterItemsStringsCount[THEATER_ITEM_TABLE_EXPLOSIVES])
    {
        SetNativeString(2, g_cTheaterItemsList[THEATER_ITEM_TABLE_EXPLOSIVES][iTableStringIndex], GetNativeCell(3));
        return true;
    }
    return false;
}
public int Native_GetPlayerGearItemName(Handle plugin, args)
{
    int iTableStringIndex = GetNativeCell(1);
    if (iTableStringIndex > 0 && iTableStringIndex <= g_iTheaterItemsStringsCount[THEATER_ITEM_TABLE_PLAYER_GEAR])
    {
        SetNativeString(2, g_cTheaterItemsList[THEATER_ITEM_TABLE_PLAYER_GEAR][iTableStringIndex], GetNativeCell(3));
        return true;
    }
    return false;
}
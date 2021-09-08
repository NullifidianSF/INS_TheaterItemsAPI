#if defined _TheaterItemsAPI_included
 #endinput
#endif
#define _TheaterItemsAPI_included

#define INS_PL_BUYZONE (1 << 7)

public SharedPlugin __pl_TheaterItemsAPI =
{
    name = "TheaterItemsAPI",
    file = "TheaterItemsAPI.smx",
#if defined REQUIRE_PLUGIN
    required = 1,
#else
    required = 0,
#endif
};

#if !defined THEATER_ITEM_TABLE_TYPE
enum THEATER_ITEM_TABLE_TYPE
{
    THEATER_ITEM_TABLE_WAEPONS = 0,
    THEATER_ITEM_TABLE_WAEPON_UPGRADES,
    THEATER_ITEM_TABLE_EXPLOSIVES,
    THEATER_ITEM_TABLE_PLAYER_GEAR,
}
#endif

#if !defined WEAPON_UPGRADE_SLOT
enum WEAPON_UPGRADE_SLOT
{
    WEAPON_UPGRADE_OPTICS = 0,    // optics 瞄具（瞄准镜）
    WEAPON_UPGRADE_AMMO,          // ammo 弹种（穿甲弹）
    WEAPON_UPGRADE_MAGAZONE,      // magazine 弹药容器（弹股）
    WEAPON_UPGRADE_BARREL,        // barrel 枪管（消音器）
    WEAPON_UPGRADE_STOCK,         // stock 枪托（枪带）
    WEAPON_UPGRADE_SIDERAIL,      // siderail 导轨（手电筒）
    WEAPON_UPGRADE_UNDERBARREL,   // underbarrel 下挂（前握把）
    WEAPON_UPGRADE_AESTHETIC,     // aesthetic 外观（快速换弹）
}
#endif

native int TI_GetTheaterItemIdByName(THEATER_ITEM_TABLE_TYPE iItemTableType, char[] cItemName);
native bool TI_GetWeaponItemName(int iItemIndex, char[] cItemName, int len);
native bool TI_GetWeaponUpgradeItemName(int iItemIndex, char[] cItemName, int len);
native bool TI_GetExplosiveItemName(int iItemIndex, char[] cItemName, int len);
native bool TI_GetPlayerGearItemName(int iItemIndex, char[] cItemName, int len);

#if !defined REQUIRE_PLUGIN
public __pl_TheaterItemsAPI_SetNTVOptional()
{
    MarkNativeAsOptional("TI_GetTheaterItemIdByName");
    MarkNativeAsOptional("TI_GetWeaponItemName");
    MarkNativeAsOptional("TI_GetWeaponUpgradeItemName");
    MarkNativeAsOptional("TI_GetExplosiveItemName");
    MarkNativeAsOptional("TI_GetPlayerGearItemName");
}
#endif

stock bool IsPluginExists_TheaterItemsAPI()
{
    static bool s_bExists = false;
    if (s_bExists || (s_bExists = LibraryExists("TheaterItemsAPI")))
        return true;
    return false;
}

 /**
 * Get theater item's index by weapon Name
 * 
 * @param cWeaponName         Weapon name in theater.
 * @return                    Weapon theater item's index if found, -1 otherwise.
 */
stock int GetTheaterItemIdByWeaponName(char[] cWeaponName)
{
    if (IsPluginExists_TheaterItemsAPI())
        return TI_GetTheaterItemIdByName(THEATER_ITEM_TABLE_WAEPONS, cWeaponName);
    else
        return -1;
}

 /**
 * Get theater item's index by weapon upgrade Name
 * 
 * @param cWeaponUpgradeName  Weapon upgrade name in theater.
 * @return                    Weapon upgrade theater item's index if found, -1 otherwise.
 */
stock int GetTheaterItemIdByWeaponUpgradeName(char[] cWeaponUpgradeName)
{
    if (IsPluginExists_TheaterItemsAPI())
        return TI_GetTheaterItemIdByName(THEATER_ITEM_TABLE_WAEPON_UPGRADES, cWeaponUpgradeName);
    else
        return -1;
}

 /**
 * Get theater item's index by explosive Name
 * 
 * @param cExplosiveName      Explosive name in theater.
 * @return                    Explosive theater item's index if found, -1 otherwise.
 */
stock int GetTheaterItemIdByExplosiveName(char[] cExplosiveName)
{
    if (IsPluginExists_TheaterItemsAPI())
        return TI_GetTheaterItemIdByName(THEATER_ITEM_TABLE_EXPLOSIVES, cExplosiveName);
    else
        return -1;
}

 /**
 * Get theater item's index by Player gear Name
 * 
 * @param cPlayerGearName     Player gear name in theater.
 * @return                    Player gear theater item's index if found, -1 otherwise.
 */
stock int GetTheaterItemIdByPlayerGearName(char[] cPlayerGearName)
{
    if (IsPluginExists_TheaterItemsAPI())
        return TI_GetTheaterItemIdByName(THEATER_ITEM_TABLE_PLAYER_GEAR, cPlayerGearName);
    else
        return -1;
}

 /**
 * Get weapon name by theater weapon item's index
 * 
 * @param iItemIndex          Theater weapon items index
 * @param cItemName           Buffer to store the item's name.
 * @param len                 Maximum length of string buffer
 * @return                    True on success, false otherwise.
 */
stock bool GetWeaponItemName(int iItemIndex, char[] cItemName, int len)
{
    return (IsPluginExists_TheaterItemsAPI() && TI_GetWeaponItemName(iItemIndex, cItemName, len));
}

 /**
 * Get weapon upgrade name by theater weapon upgrade item's index
 * 
 * @param iItemIndex          Theater weapon upgrade items index
 * @param cItemName           Buffer to store the item's name.
 * @param len                 Maximum length of string buffer
 * @return                    True on success, false otherwise.
 */
stock bool GetWeaponUpgradeItemName(int iItemIndex, char[] cItemName, int len)
{
    return (IsPluginExists_TheaterItemsAPI() && TI_GetWeaponUpgradeItemName(iItemIndex, cItemName, len));
}

 /**
 * Get explosive name by theater explosive item's index
 * 
 * @param iItemIndex          Theater explosive items index
 * @param cItemName           Buffer to store the item's name.
 * @param len                 Maximum length of string buffer
 * @return                    True on success, false otherwise.
 */
stock bool GetExplosiveItemName(int iItemIndex, char[] cItemName, int len)
{
    return (IsPluginExists_TheaterItemsAPI() && TI_GetExplosiveItemName(iItemIndex, cItemName, len));
}

 /**
 * Get player gear name by theater player gear item's index
 * 
 * @param iItemIndex          Theater player gear items index
 * @param cItemName           Buffer to store the item's name.
 * @param len                 Maximum length of string buffer
 * @return                    True on success, false otherwise.
 */
stock bool GetPlayerGearItemName(int iItemIndex, char[] cItemName, int len)
{
    return (IsPluginExists_TheaterItemsAPI() && TI_GetPlayerGearItemName(iItemIndex, cItemName, len));
}


// #include <TheaterItemsAPI> // https://github.com/gandor233/INS_TheaterItemsAPI
 /**
 * Check if client has gear by gear name. (this "has" only mean player actually equipped and wearing it, but not necessarily equipped it in the inventory.)
 * 
 * @param client              Client index
 * @param cGearName           Gear name for check
 * @return                    Whether client has the gear
 */
stock bool IsClientHasGear(int client, char[] cGearName, char[] cReturnName = "", int len = 0)
{
    int iItemId = 255;
    int iMaxItems = GetEntPropArraySize(client, Prop_Send, "m_iMyGear");
    for (int i = 0; i < iMaxItems; i++)
    {
        iItemId = GetEntProp(client, Prop_Send, "m_iMyGear", _, i);
        if (iItemId == 255)
            continue;
        
        char cItemName[128];
        GetPlayerGearItemName(iItemId, cItemName, sizeof(cItemName));
        if (StrContains(cItemName, cGearName, false) > -1)
        {
            if (len > 0)
                strcopy(cReturnName, len, cItemName);
            return true;
        }
    }
    
    return false;
}

 /**
 * Check if client equipped gear by gear name. (this "equipped" only mean equipped in the inventory, but it's not necessarily actually equipped. player may not be wearing it)
 * 
 * @param client              Client index
 * @param cGearName           Gear name for check
 * @return                    Whether client Equipped the gear
 */
stock bool IsClientEquippedGear(int client, char[] cGearName)
{
    int iItemId = 255;
    int iMaxItems = GetEntPropArraySize(client, Prop_Send, "m_EquippedGear");
    for (int i = 0; i < iMaxItems; i++)
    {
        iItemId = GetEntProp(client, Prop_Send, "m_EquippedGear", _, i);
        if (iItemId == 255)
            continue;
        
        char cItemName[128];
        GetPlayerGearItemName(iItemId, cItemName, sizeof(cItemName));
        if (StrContains(cItemName, cGearName, false) > -1)
            return true;
    }
    
    return false;
}

 /**
 * Check if weapon has upgrade by upgrade name
 * 
 * @param iWeaponID           Weapon index
 * @param cUpgradeName        Weapon Upgrade name for check
 * @return                    Whether weapon has the upgrade
 */
stock bool IsWeaponHasUpgrade(int iWeaponID, char[] cUpgradeName)
{
    int iItemId = 255;
    int iMaxItems = GetEntPropArraySize(client, Prop_Send, "m_upgradeSlots");
    for (int i = 0; i < iMaxItems; i++)
    {
        int iItemIndex = GetEntProp(iWeaponID, Prop_Send, "m_upgradeSlots", 4, i);
        if (iItemIndex == 255)
            continue;
        
        char cItemName[256];
        GetWeaponUpgradeItemName(iItemIndex, cItemName, sizeof(cItemName));
        if (StrContains(cItemName, cUpgradeName, false) > -1)
            return true;
    }
    
    return false;
}

 /**
 * Give weapon a upgrade by upgrade name
 * 
 * @param iWeaponID           Weapon index
 * @param iUpgradeSlotType    Weapon upgrade slot type
 * @param cUpgradeName        Weapon Upgrade name in theater
 * @return                    True on success, false otherwise.
 */
stock bool GiveUpgradeToWeaponByName(int iWeaponID, WEAPON_UPGRADE_SLOT iUpgradeSlotType, char[] cUpgradeName)
{
    int iUpgradeID = GetTheaterItemIdByWeaponUpgradeName(cUpgradeName);
    return GiveUpgradeToWeaponByTheaterId(iWeaponID, iUpgradeSlotType, iUpgradeID);
}

 /**
 * Give weapon a upgrade by upgrade theater item's index
 * 
 * @param iWeaponID           Weapon index
 * @param iUpgradeSlotType    Weapon upgrade slot type
 * @param iUpgradeID          Weapon Upgrade theater item's index
 * @return                    True on success, false otherwise.
 */
stock bool GiveUpgradeToWeaponByTheaterId(int iWeaponID, WEAPON_UPGRADE_SLOT iUpgradeSlotType, int iUpgradeID)
{
    if (iUpgradeID <= 0 || iUpgradeID >= 255)
        return false;
    
    int iUpgradeSlot = view_as<int>(iUpgradeSlotType);
    int iMaxUpgradeSlot = GetEntPropArraySize(iWeaponID, Prop_Send, "m_upgradeSlots");
    if (iUpgradeSlot < 0 || iUpgradeSlot >= iMaxUpgradeSlot)
        return false;
    
    SetEntProp(iWeaponID, Prop_Send, "m_upgradeSlots", iUpgradeID, 4, iUpgradeSlot);

    // Try to refresh weapon view model
    int client = GetEntPropEnt(iWeaponID, Prop_Data, "m_hOwnerEntity");
    if (client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client))
    {
        // Refresh is required only when the weapon is in the player's hand
        if (iWeaponID != GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon"))
            return true;

        int iFlags = GetEntProp(client, Prop_Send, "m_iPlayerFlags");
        if (iFlags & INS_PL_BUYZONE)
            return true;

        int iWeaponSlot = -1;
        for (int i = 0; i < 4 ; ++i)
        {
            if (GetPlayerWeaponSlot(client, i) == iWeaponID)
                iWeaponSlot = i;
        }
        SDKHooks_DropWeapon(client, iWeaponID, NULL_VECTOR, NULL_VECTOR);
        EquipPlayerWeapon(client, iWeaponID);
        ClientCommand(client, "slot%d", iWeaponSlot+1);
    }
    return true;
}
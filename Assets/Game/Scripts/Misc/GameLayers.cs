//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using UnityEngine;

/// <summary>
/// The game layers.
/// </summary>
public static class GameLayers
{
    private static int? walkable;
    private static int? clickable;
    private static int? mainRole;
    private static int? role;
    private static int? areaAtmosphere;
    private static int? water;
    private static int? bigBuilding;
    private static int? smallBuilding;
    private static int? uiEffect1;
    private static int? uiEffect2;
    private static int? uiEffect3;
    //private static int? iosAuditUI;

    /// <summary>
    /// Gets the default layer.
    /// </summary>
    public static int Default
    {
        get { return 0; }
    }

    /// <summary>
    /// Gets the walkable layer.
    /// </summary>
    public static int Walkable
    {
        get
        {
            if (!walkable.HasValue)
            {
                walkable = LayerMask.NameToLayer("Walkable");
            }

            return walkable.Value;
        }
    }

    /// <summary>
    /// Gets the clickable layer.
    /// </summary>
    public static int Clickable
    {
        get
        {
            if (!clickable.HasValue)
            {
                clickable = LayerMask.NameToLayer("Clickable");
            }

            return clickable.Value;
        }
    }

    /// <summary>
    /// Gets the main role layer.
    /// </summary>
    public static int MainRole
    {
        get
        {
            if (!mainRole.HasValue)
            {
                mainRole = LayerMask.NameToLayer("MainRole");
            }

            return mainRole.Value;
        }
    }

    /// <summary>
    /// Gets the role layer.
    /// </summary>
    public static int Role
    {
        get
        {
            if (!role.HasValue)
            {
                role = LayerMask.NameToLayer("Role");
            }

            return role.Value;
        }
    }

    /// <summary>
    /// Gets the area atmosphere layer.
    /// </summary>
    public static int AreaAtmosphere
    {
        get
        {
            if (!areaAtmosphere.HasValue)
            {
                areaAtmosphere = LayerMask.NameToLayer("AreaAtmosphere");
            }

            return areaAtmosphere.Value;
        }
    }

    public static int Water
    {
        get
        {
            if (!water.HasValue)
            {
                water = LayerMask.NameToLayer("Water");
            }

            return water.Value;
        }
    }

    public static int BigBuilding
    {
        get
        {
            if (!bigBuilding.HasValue)
            {
                bigBuilding = LayerMask.NameToLayer("BigBuilding");
            }

            return bigBuilding.Value;
        }
    }

    public static int SmallBuilding
    {
        get
        {
            if (!smallBuilding.HasValue)
            {
                smallBuilding = LayerMask.NameToLayer("SmallBuilding");
            }

            return smallBuilding.Value;
        }
    }

    public static int UIEffect1
    {
        get
        {
            if (!uiEffect1.HasValue)
            {
                uiEffect1 = LayerMask.NameToLayer("UIEffect1");
            }

            return uiEffect1.Value;
        }
    }

    public static int UIEffect2
    {
        get
        {
            if (!uiEffect2.HasValue)
            {
                uiEffect2 = LayerMask.NameToLayer("UIEffect2");
            }

            return uiEffect2.Value;
        }
    }

    public static int UIEffect3
    {
        get
        {
            if (!uiEffect3.HasValue)
            {
                uiEffect3 = LayerMask.NameToLayer("UIEffect3");
            }

            return uiEffect3.Value;
        }
    }

    /* public static int IosAuditUI
    {
        get
        {
            if (!iosAuditUI.HasValue)
            {
                iosAuditUI = LayerMask.NameToLayer("IosAuditUI");
            }

            return iosAuditUI.Value;
        }
    } */
    

}

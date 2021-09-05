//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

/// <summary>
/// Help for event trigger selection UI.
/// </summary>
public static class SkillActionHelper
{
    private static string[] actionNames = new string[]
    {
        "attack1",
        "attack2",
        "attack3",

        "skill1_1",
        "skill1_2",
        "skill1_3",

        "skill2_1",
        "skill2_2",
        "skill2_3",

        "skill3_1",
        "skill3_2",
        "skill3_3",

        "custom",
    };

    /// <summary>
    /// Gets the action name.
    /// </summary>
    public static string[] ActionNames
    {
        get { return actionNames; }
    }

    /// <summary>
    /// Find the event index by eventName and eventParam.
    /// </summary>
    public static int FindActionIndex(string actionName)
    {
        for (int i = 0; i < actionNames.Length; ++i)
        {
            if (actionNames[i] == actionName)
            {
                return i;
            }
        }

        return actionNames.Length - 1;
    }

    /// <summary>
    /// Find the event name and param by index.
    /// </summary>
    public static string FindActionName(int index)
    {
        if (index < actionNames.Length)
        {
            return actionNames[index];
        }
        else
        {
            return string.Empty;
        }
    }
}

using System.Collections;
using System.Collections.Generic;
using Nirvana;
using UnityEditor;
using UnityEngine;

public class UINameTableEditor : Editor {
    [MenuItem("CONTEXT/UINameTable/Change Prefab Name")]
    static void ChangeName(MenuCommand menuCommand)
    {
        var uiNameTable = menuCommand.context as UINameTable;
        foreach (var bind in uiNameTable.binds)
        {
            Undo.RecordObject(bind.Widget, "Widget");
            bind.Widget.name = bind.Name;
        }
    }
}

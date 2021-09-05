//////// Custom Tree-IGenericMenu Example ////////
/*
        To add your own module, inherit the slot class (HierarchyExtensions.CustomModule_Slot1 / 2 / 3) anywhere in your code.
*/

#if UNITY_EDITOR

using System;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.UI;


/////////////////////////////////////////////////////MENU ITEM TEMPLATE///////////////////////////////////////////////////////////////////////////////
/*
    class MyModule : HierarchyExtensions.CustomModule_Slot1
    {
        public override string NameOfModule { get { return "MyModule"; } }
    
        // In this method, you can display information and buttons
        public override void Draw(Rect drawRect, GameObject o)
        {
            // You can invoke different built-in methods for changing variables
            //        if (GUI.Button(drawRect,"string")) SHOW_StringInput(...
            //        if (GUI.Button(drawRect,"int")) SHOW_IntInput(...
            //        if (GUI.Button(drawRect,"dropdown")) SHOW_DropDownMenu(...
        }
    
        // ToString(...) method is used for the search box
        public override string ToString(GameObject o)
        {
            return null;
        }
    }
*/
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


namespace Hierarchy_Examples
{
    #region MODULE 1 - RotationDirection
    class CustomModule_Example_RotationDirection : HierarchyExtensions.CustomModule_Slot1
    {
        public override string NameOfModule { get { return "Rotation"; } }


        Dictionary<Vector3, string> types = new Dictionary<Vector3, string>() {
            {Vector3.back, "back" },
            {Vector3.forward, "forward" },
            {Vector3.left, "left" },
            {Vector3.right, "right" },
            {Vector3.up, "up" },
            {Vector3.down, "down" }
                                                                             };

        Vector3 GetRoundedRotation(GameObject o)
        {
            //var roundRotation = o.transform.rotation.ToAngleAxis(;
            var roundRotation = o.transform.localRotation * Vector3.forward;
            for (int i = 0; i < 3; i++) roundRotation[i] = (float)Math.Round(roundRotation[i], 4);
            return roundRotation;
        }

        public override string ToString(GameObject o)
        {
            var roundRotation = GetRoundedRotation(o);
            return types.ContainsKey(roundRotation) ? types[roundRotation] : "—";
        }


        public override void Draw(Rect drawRect, GameObject o)
        {
            if (GUI.Button(drawRect, ToString(o)))
            {
                var itemsVectors = types.Keys.ToList();
                var itemsStrings = types.Values.ToArray();
                var selectedIndex = itemsVectors.IndexOf(GetRoundedRotation(o));
                SHOW_DropDownMenu(selectedIndex, itemsStrings,
                    newIndex => {
                        Undo.RecordObject(o.transform, "Change Rotation");
                        o.transform.localRotation = Quaternion.LookRotation(itemsVectors[newIndex]);
                        EditorUtility.SetDirty(o);
                        EditorSceneManager.MarkSceneDirty(o.scene);
                    });
            }
        }

    }
    #endregion // MODULE 1 - RotationDirection








    #region MODULE 2 - StringTypes
    class CustomModule_Example_StringTypes : HierarchyExtensions.CustomModule_Slot2
    {
        public override string NameOfModule { get { return "UI Text"; } }
        static Color green = new Color(0, 1.0f, 0.4f, 0.2f);

        public override string ToString(GameObject o)
        {
            var component = o.GetComponent<Text>();
            return component ? component.text : "";
        }


        public override void Draw(Rect drawRect, GameObject o)
        {
            var component = o.GetComponent<Text>();
            if (component) EditorGUI.DrawRect(drawRect, green);
            else return;

            if (GUI.Button(drawRect, component.text))
            {
                SHOW_StringInput(component.text,
                    newText => {
                        component = o.GetComponent<Text>();
                        if (component)
                        {
                            Undo.RecordObject(component, "Change Text");
                            component.text = newText;
                            EditorUtility.SetDirty(o);
                            EditorSceneManager.MarkSceneDirty(o.scene);
                        }
                    });
            }
        }

    }
    #endregion // MODULE 2 - StringTypes

}

#endif
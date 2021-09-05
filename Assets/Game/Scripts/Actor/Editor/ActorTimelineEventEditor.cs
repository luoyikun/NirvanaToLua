//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using System.Collections.Generic;
using Nirvana;
using UnityEditor;
using UnityEditorInternal;
using UnityEngine;

/// <summary>
/// The editor for <see cref="ActorTimelineEvent"/>
/// </summary>
[CustomEditor(typeof(ActorTimelineEvent))]
public class ActorTimelineEventEditor : Editor
{
    private string[] eventNames;
    private SerializedProperty eventTimes;
    private ReorderableList eventTimeList;

    /// <inheritdoc/>
    public override void OnInspectorGUI()
    {
        this.serializedObject.Update();
        this.eventTimeList.DoLayoutList();
        this.serializedObject.ApplyModifiedProperties();
    }

    private void OnEnable()
    {
        if (this.target == null)
        {
            return;
        }

        // Find all animator event.
        var timelineEvent = (ActorTimelineEvent)this.target;
        var animator = timelineEvent.GetComponent<Animator>();
        if (animator != null)
        {
            this.BuildEventNames(animator);
        }

        // Access all property.
        this.eventTimes = this.serializedObject.FindProperty("eventTimes");

        // Create list editor.
        this.eventTimeList = new ReorderableList(
            this.serializedObject, this.eventTimes);
        this.eventTimeList.drawHeaderCallback =
            rect => GUI.Label(rect, "Timeline:");
        this.eventTimeList.elementHeight = 2 * EditorGUIUtility.singleLineHeight;
        this.eventTimeList.drawElementCallback =
            (rect, index, selected, focused) =>
            {
                this.DrawTimeline(
                    this.eventTimes, rect, index, selected, focused);
            };
    }

    private void BuildEventNames(Animator animator)
    {
        var names = new List<string>();
        var behaviours = animator.GetBehaviours<AnimatorTimelineBehaviour>();
        foreach (var behaviour in behaviours)
        {
            var timtlineEvents = behaviour.TimelineEvents;
            foreach (var timtlineEvent in timtlineEvents)
            {
                names.Add(timtlineEvent.EventName);
            }
        }

        if (names.Count > 0)
        {
            names.Sort();
            this.eventNames = names.ToArray();
        }
        else
        {
            this.eventNames = null;
        }
    }

    private void DrawTimeline(
        SerializedProperty property,
        Rect rect,
        int index,
        bool selected,
        bool focused)
    {
        var element = property.GetArrayElementAtIndex(index);

        var eventName = element.FindPropertyRelative("EventName");
        var normalizedTime = element.FindPropertyRelative("NormalizedTime");

        // Start rect line.
        var rectLine = new Rect(
            rect.x,
            rect.y,
            rect.width,
            EditorGUIUtility.singleLineHeight);

        if (this.eventNames != null)
        {
            var eventIndex = ArrayUtility.IndexOf(
                this.eventNames, eventName.stringValue);
            EditorGUI.BeginChangeCheck();
            eventIndex = EditorGUI.Popup(rectLine, eventIndex, this.eventNames);
            if (EditorGUI.EndChangeCheck())
            {
                eventName.stringValue = this.eventNames[eventIndex];
            }
        }
        else
        {
            EditorGUI.PropertyField(rectLine, eventName);
        }

        // Draw normalized time.
        rectLine.y += EditorGUIUtility.singleLineHeight;
        EditorGUI.PropertyField(
            rectLine,
            normalizedTime,
            new GUIContent("Normalized Time:"));
    }
}

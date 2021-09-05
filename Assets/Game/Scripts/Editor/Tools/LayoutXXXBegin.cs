
using UnityEngine;

using System;

namespace UnityEditor
{
	public class EditorGUILayoutHorizontal : IDisposable
	{
		public readonly Rect	Rect;

		public EditorGUILayoutHorizontal( params GUILayoutOption[] options )
		{
			Rect = EditorGUILayout.BeginHorizontal( options );
		}

		public EditorGUILayoutHorizontal( GUIStyle style, params GUILayoutOption[] options )
		{
			Rect = EditorGUILayout.BeginHorizontal( style, options );
		}

		void IDisposable.Dispose()
		{
			EditorGUILayout.EndHorizontal();
		}
	}

	public class EditorGUILayoutVertical : IDisposable
	{
		public readonly Rect	Rect;

		public EditorGUILayoutVertical( params GUILayoutOption[] options )
		{
			Rect = EditorGUILayout.BeginVertical( options );
		}

		public EditorGUILayoutVertical( GUIStyle style, params GUILayoutOption[] options )
		{
			Rect = EditorGUILayout.BeginVertical( style, options );
		}

		void IDisposable.Dispose()
		{
			EditorGUILayout.EndVertical();
		}
	}

	public class EditorGUILayoutScrollView : IDisposable
	{

		public EditorGUILayoutScrollView(ref Vector2 scrollPosition, GUIStyle style )
		{
            scrollPosition = EditorGUILayout.BeginScrollView( scrollPosition, style );
		}

		public EditorGUILayoutScrollView(ref Vector2 scrollPosition, params GUILayoutOption[] options )
		{
            scrollPosition = EditorGUILayout.BeginScrollView( scrollPosition, options );
		}

		public EditorGUILayoutScrollView(ref Vector2 scrollPosition, bool alwaysShowHorizontal, bool alwaysShowVertical, params GUILayoutOption[] options )
		{
            scrollPosition = EditorGUILayout.BeginScrollView( scrollPosition, alwaysShowHorizontal, alwaysShowVertical, options );
		}

		public EditorGUILayoutScrollView(ref Vector2 scrollPosition, GUIStyle horizontalScrollbar, GUIStyle verticalScrollbar, params GUILayoutOption[] options )
		{
            scrollPosition = EditorGUILayout.BeginScrollView( scrollPosition, horizontalScrollbar, verticalScrollbar, options );
		}

		public EditorGUILayoutScrollView(ref Vector2 scrollPosition, bool alwaysShowHorizontal, bool alwaysShowVertical, GUIStyle horizontalScrollbar, GUIStyle verticalScrollbar, GUIStyle background, params GUILayoutOption[] options )
		{
            scrollPosition = EditorGUILayout.BeginScrollView( scrollPosition, alwaysShowHorizontal, alwaysShowVertical, horizontalScrollbar, verticalScrollbar, background, options );
		}

		void IDisposable.Dispose()
		{
			EditorGUILayout.EndScrollView();
		}
	}
}
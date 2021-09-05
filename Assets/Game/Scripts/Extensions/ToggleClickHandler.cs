//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------
using Nirvana;
using System;
using UnityEngine.Events;
using UnityEngine.UI;

/// <summary>
/// Attatch this script to a Toggle GameObject
/// </summary>

using UnityEngine;
using UnityEngine.EventSystems;

namespace Nirvana
{
    public class ToggleClickHandler : MonoBehaviour, IPointerClickHandler
    {

        private event PointerEventDelegate PointerClickEvent;

        public delegate void PointerEventDelegate(PointerEventData eventData);

        //Detect if a click occurs
        public void OnPointerClick(PointerEventData pointerEventData)
        {
            if (this.PointerClickEvent != null)
            {
                this.PointerClickEvent(pointerEventData);
            }
        }

        public void AddClickListener(PointerEventDelegate call)
        {
            this.PointerClickEvent += call;
        }

        public void RemoveAllListeners()
        {
            if (null == PointerClickEvent) return;

            Delegate[] dels = PointerClickEvent.GetInvocationList();
            foreach (Delegate d in dels)
            {
                object delObj = d.GetType().GetProperty("Method").GetValue(d, null);
                string funcName = (string)delObj.GetType().GetProperty("Name").GetValue(delObj, null);
                this.PointerClickEvent -= d as PointerEventDelegate;
            }
        }
    }
}

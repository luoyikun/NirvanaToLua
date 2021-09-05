//------------------------------------------------------------------------------
// Copyright (c) 2018-2018 Nirvana Technology Co. Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

using UnityEngine;
using UnityEngine.EventSystems;
using System.Collections.Generic;

/// <summary>
/// 事件透传.
/// </summary>
public sealed class PenetratEvent : MonoBehaviour, IPointerClickHandler
{
    //监听点击
    public void OnPointerClick(PointerEventData eventData)
    {
        PassEvent(eventData, ExecuteEvents.submitHandler);
        PassEvent(eventData, ExecuteEvents.pointerClickHandler);
    }
 
    //把事件透下去
    public void  PassEvent<T>(PointerEventData data, ExecuteEvents.EventFunction<T> function)
        where T : IEventSystemHandler
    {
        List<RaycastResult> results = new List<RaycastResult>();
        EventSystem.current.RaycastAll(data, results); 
        GameObject current = data.pointerCurrentRaycast.gameObject ;
        for(int i =0; i< results.Count;i++)
        {
            if(current!= results[i].gameObject)
            {
                ExecuteEvents.Execute(results[i].gameObject, data, function);
                break;
            }
        }
    }
}

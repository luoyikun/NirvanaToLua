using Nirvana;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class EffectOrderGroup
{
    private static int curOrder = -30000;
    private static Dictionary<string, int> groupOrder = new Dictionary<string, int>();

    public static void OnGameStop()
    {
        curOrder = -30000;
        groupOrder.Clear();
    }

    public static void RefreshRenderOrder(GameObject effectObj)
    {
        if (null == effectObj)
        {
            return;
        }

        int startOrder = 0;
        bool isNewGroup = true;
        if (!groupOrder.TryGetValue(effectObj.name, out startOrder))
        {
            isNewGroup = false;
            startOrder = curOrder;
            groupOrder.Add(effectObj.name, curOrder);
        }

        ParticleSystem[] particles = effectObj.GetComponentsInChildren<ParticleSystem>();
        if (particles.Length > 0)
        {
            foreach (var item in particles)
            {
                Renderer render = item.GetComponentInChildren<Renderer>();
                if (null != render)
                {
                    render.sortingOrder = startOrder + render.sortingOrder;
                }
            }

            if (isNewGroup)
            {
                curOrder += 10;
                if (curOrder >= 30000)
                {
                    curOrder = -30000;
                }
            }
        }
    }
}

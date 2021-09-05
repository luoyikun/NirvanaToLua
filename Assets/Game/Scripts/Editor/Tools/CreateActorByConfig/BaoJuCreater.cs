using Nirvana;
using UnityEngine;
/// <summary>
/// 
/// </summary>
public class BaoJuCreater : ActorCreater
{
    public override void AddComponentsByConfig(GameObject gameObj)
    {
        var optimizer = gameObj.GetOrAddComponent<AnimatorOptimizer>();
        optimizer.SearchPatterns = new[] { "guadian_*" };
        optimizer.SearchExposed();
        optimizer.Optimize();
        gameObj.GetOrAddComponent<AnimatorEventDispatcher>();
    }

    protected override string CustomFilter(string clipName)
    {
        var filter = string.Empty;
        switch (clipName)
        {
            case "d_idle":
                filter = "idle";
                break;
            case "d_idle_fight":
                filter = "idle";
                break;
            case "d_rest":
                filter = "zhankai";
                break;
        }
        return filter;
    }
}

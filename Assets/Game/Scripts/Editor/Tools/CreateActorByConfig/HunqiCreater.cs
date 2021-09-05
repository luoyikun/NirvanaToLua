using Nirvana;
using UnityEngine;
/// <summary>
/// 
/// </summary>
public class HunqiCreater : ActorCreater
{
    public override void AddComponentsByConfig(GameObject gameObj)
    {
        var optimizer = gameObj.GetOrAddComponent<AnimatorOptimizer>();
        optimizer.SearchPatterns = new[] { "guadian", "texiao" };
        optimizer.SearchExposed();
        optimizer.Optimize();
    }

    protected override string CustomFilter(string clipName)
    {
        return "idle";
    }
}

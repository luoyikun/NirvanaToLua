using UnityEngine;

[ExecuteInEditMode]
public class LimitSceneEffects : MonoBehaviour
{
    [SerializeField]
    private GameObject[] effects;

    private void OnTransformParentChanged()
    {
        if (Application.isPlaying)
        {
            this.CheckEffects();
        }
    }

    private void CheckEffects()
    {
        var display = this.GetComponentInParent<Nirvana.UI3DDisplay>();
        if(display != null)
        {
            this.ShowEffects();
            return;
        }
        if(this.effects == null || this.effects.Length <= 0)
        {
            return;
        }
        foreach(var effects in this.effects)
        {
            if(effects != null)
            {
                effects.SetActive(false);
            }
        }
    }

    private void ShowEffects()
    {
        if(this.effects == null || this.effects.Length <= 0)
        {
            return;
        }
        foreach(var effects in this.effects)
        {
            if(effects != null)
            {
                effects.SetActive(true);
            }
        }
    }
}

using UnityEngine;
using System.Collections;

public class ListenTrigger : MonoBehaviour
{

    public delegate void TriggerEnterDelegate(GameObject gameObject);

    public TriggerEnterDelegate triggerenter;
    private void OnTriggerEnter2D(Collider2D coll)
    {
        if (triggerenter != null)
        {
            triggerenter(coll.gameObject);
        }
    }
}

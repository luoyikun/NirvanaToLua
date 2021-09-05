using Nirvana;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Game;

public class CameraCullObjMgr : Singleton<CameraCullObjMgr>
{
    private float nextCheckCullTime = 0;
    private HashSet<CameraCullObj> cullObjs = new HashSet<CameraCullObj>();

    public void OnGameStop()
    {
        cullObjs.Clear();
    }

    public void UpdateCull()
    {
        if (Time.time - this.nextCheckCullTime >= 0.2)
        {
            this.nextCheckCullTime = Time.time;
            foreach (var cullObj in this.cullObjs)
            {
                if (null != cullObj)
                {
                    cullObj.RefreshCullStatus();
                }
            }
        }
    }

    public void AddCullObj(CameraCullObj cullObj)
    {
        this.cullObjs.Add(cullObj);
    }

    public void RemoveCullObj(CameraCullObj cullObj)
    {
        this.cullObjs.Remove(cullObj);
    }
}

public class CameraCullObj : MonoBehaviour
{
    [SerializeField]
    private int cullDistance = 50;

    private bool isCulled = false;
    private GameObjectAttach objAttach;

    private void Awake()
    {
        this.objAttach = this.GetComponent<GameObjectAttach>();
        if (null != this.objAttach)
        {
            this.objAttach.enabled = false;
        }
        else
        {
            this.gameObject.SetActive(false);
        }

        CameraCullObjMgr.Instance.AddCullObj(this);
    }

    private void OnDestroy()
    {
        CameraCullObjMgr.Instance.RemoveCullObj(this);
    }

    public void RefreshCullStatus()
    {
        if (null != Camera.main)
        {
            bool isCulled = false;
            var vector = Camera.main.transform.position - this.transform.position;
            if (vector.sqrMagnitude >= cullDistance * cullDistance
                || Vector3.Dot(vector, Camera.main.transform.forward) > 0)
            {
              
                isCulled = true;
            }

            this.SetIsCulled(isCulled);
        }
    }

    private void SetIsCulled(bool isCulled)
    {
        if (this.isCulled == isCulled)
        {
            return;
        }

        this.isCulled = isCulled;
        if (null != this.objAttach)
        {
            this.objAttach.enabled = !isCulled;
        }
        else
        {
            this.gameObject.SetActive(!isCulled);
        }
    }
}

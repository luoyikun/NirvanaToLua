#if UNITY_ANDROID && !UNITY_EDITOR
#define ANDROID
#endif


#if UNITY_IPHONE && !UNITY_EDITOR
#define IPHONE
#endif

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using Nirvana;

public class UIMouseClick : MonoBehaviour {
    [SerializeField]
    private GameObject[] effects;

    private GameObject effectInstance;
    private RectTransform rectTransform;
    private Canvas canvas;
    private int index = 0;
    private Vector3 normal_scale = new Vector3(1, 1, 1);
	// Use this for initialization
	void Start () {
        this.rectTransform = this.GetComponent<RectTransform>();
        this.canvas = this.GetComponent<Canvas>();
    }
	
	// Update is called once per frame
	void Update () {
        if (Input.GetMouseButtonDown(0) || (Input.touchCount > 0 && Input.GetTouch(0).phase == TouchPhase.Began))
        {
#if IPHONE || ANDROID
			if (EventSystem.current.IsPointerOverGameObject(Input.GetTouch(0).fingerId))
#else
            if (EventSystem.current.IsPointerOverGameObject())
#endif
            {
                this.ShowClickEffect();
            }
        }
    }

    void ShowClickEffect()
    {
        EventDispatcher.Instance.OnUIMouseClickEffect(this.effectInstance, this.effects, this.canvas, this.transform);
        // if (null != this.effectInstance)
        //     GameObjectPool.Instance.Free(this.effectInstance);
        // this.effectInstance = null;
        // if (this.effects.Length > 0)
        // {
        //     var obj = this.effects[this.index++];
        //     this.index %= this.effects.Length;
        //     if (null != obj)
        //     {
        //         this.effectInstance = GameObjectPool.Instance.Spawn(obj, this.transform);
        //         this.effectInstance.transform.localScale = normal_scale;
        //         var rect = this.effectInstance.transform as RectTransform;
        //         Vector2 _pos = Vector2.one;
        //         RectTransformUtility.ScreenPointToLocalPointInRectangle(this.canvas.transform as RectTransform,
        //                     Input.mousePosition, canvas.worldCamera, out _pos);
        //         rect.localPosition = new Vector3(_pos.x, _pos.y, 0); 
        //         this.effectInstance.GetComponent<Animator>().ListenEvent("exit", (arg1, arg2) =>
        //         {
        //             if (null != this.effectInstance)
        //                 GameObjectPool.Instance.Free(this.effectInstance);
        //             this.effectInstance = null;
        //         });
        //     }
        // }
    }
}

using UnityEngine;
using UnityEngine.EventSystems;
using DG.Tweening;
using UnityEngine.UI;
using Nirvana;

[ExecuteInEditMode]
public class ButtonClickScale : MonoBehaviour, IPointerUpHandler, IPointerDownHandler
{
    [Header("按钮用到的放大缩小倍数")]
    [SerializeField][ReName("按钮弹起时的倍数")]
    private float ClickUpScale = 1f;

    [SerializeField][ReName("按钮按下时的倍数")]
    private float ClickDownScale = 0.9f;

    // 点击响应的事件
    private GameObject button_click;

    void Awake()
    {
        var button = GetComponent<Button>();
        if (button != null)
        {
            button.transition = Selectable.Transition.None;
        }

        if (Application.isPlaying)
        {
            button_click = new GameObject("ButtonClickScale");
            button_click.AddComponent<UIBlock>();
            button_click.transform.SetParent(transform, false);
            button_click.transform.SetAsFirstSibling();

            var rect = button_click.GetComponent<RectTransform>();
            if (rect)
            {
                rect.anchorMin = new Vector2(0, 0);
                rect.anchorMax = new Vector2(1, 1);
                rect.anchoredPosition3D = new Vector3(0, 0, 0);
                rect.sizeDelta = new Vector2(0, 0);
            }
            button_click.transform.localScale = new Vector3(ClickUpScale, ClickUpScale, ClickUpScale);
        }
    }

    void OnDestroy()
    {
        if (button_click)
        {
            if (Application.isPlaying)
            {
                Destroy(button_click);
            }
            else
            {
                DestroyImmediate(button_click);
            }
        }
    }

    public void OnPointerUp(PointerEventData eventData)
    {
        if (button_click)
        {
            button_click.transform.localScale = new Vector3(ClickUpScale, ClickUpScale, ClickUpScale);
        }
        transform.DOScale(ClickUpScale, 0.05f);
    }

    public void OnPointerDown(PointerEventData eventData)
    {
        var select_table = GetComponent<Selectable>();
        if (select_table != null && select_table.interactable)
        {
            if (button_click)
            {
                button_click.transform.localScale = new Vector3(1 / ClickDownScale, 1 / ClickDownScale, 1 / ClickDownScale);
            }
            transform.DOScale(ClickDownScale, 0.05f);
        }
    }
}



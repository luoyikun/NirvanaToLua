using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(InputField))]
public sealed class TextInputLimitChar : MonoBehaviour
{
    public int maxCharacters = 6;
    private InputField textInput;

    private void Awake()
    {
        this.textInput = this.GetComponent<InputField>();
        if (null != this.textInput)
        {
            this.textInput.characterLimit = maxCharacters * 2;

#if UNITY_EDITOR
            this.textInput.onValueChanged.AddListener(this.OnValueChange);
#else
             this.textInput.onEndEdit.AddListener(delegate { OnEditEnd(); });
#endif
        }
    }

    private void OnValueChange(string str)
    {
        TrimContent();
    }

    public void OnEditEnd()
    {
        TrimContent();
    }

    private void TrimContent()
    {
        if (null == this.textInput)
        {
            return;
        }

        string new_content = "";
        float consume = 0.0f;
        string content = this.textInput.text;

        for (int i = 0; i < content.Length; ++i)
        {
            string str = content.Substring(i, 1);
            byte[] bytestr = System.Text.Encoding.UTF8.GetBytes(str);
            int asc = (int)bytestr[0];
            if (1 == bytestr.Length && asc <= 176)
            {
                consume += 0.65f / 1.0f;
            }
            else
            {
                consume += 1.0f;
            }

            if (consume > maxCharacters)
            {
                break;
            }
            else
            {
                new_content += str;
            }
        }

        if (this.textInput.text != new_content)
        {
            this.textInput.text = new_content;
        }
    }
}

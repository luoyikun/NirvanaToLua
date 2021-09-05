using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UIPalceholder : MonoBehaviour {
    private InputField input;
	// Use this for initialization
	void Start () {
        this.input = this.GetComponent<InputField>();
    }
	
	// Update is called once per frame
	void Update () {
		if (input.isFocused)
        {
            input.placeholder.enabled = false;
        }
        else if (input.text.Length <= 0)
        {
            input.placeholder.enabled = true;
        }
	}
}

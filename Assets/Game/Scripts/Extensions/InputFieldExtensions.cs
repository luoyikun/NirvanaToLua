//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using UnityEngine.Events;
using UnityEngine.UI;

/// <summary>
/// The extensions for input field.
/// </summary>
public static class InputFieldExtensions
{
    public static void AddEndEditListener(
        this InputField inputField, UnityAction<string> call)
    {
        inputField.onEndEdit.AddListener(call);
    }
}

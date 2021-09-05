PlayerPrefsUtil = {}
local data_dic = {}

function PlayerPrefsUtil.SetInt(key, value)
	if data_dic[key] ~= value then
		data_dic[key] = value
		UnityEngine.PlayerPrefs.SetInt(key, value)
	end
end

function PlayerPrefsUtil.GetInt(key)
	if nil ~= data_dic[key] then
		return data_dic[key]
	end

	local value = UnityEngine.PlayerPrefs.GetInt(key)
	data_dic[key] = value
	return value
end

function PlayerPrefsUtil.SetFloat(key, value)
	if data_dic[key] ~= value then
		data_dic[key] = value
		UnityEngine.PlayerPrefs.SetFloat(key, value)
	end
end

function PlayerPrefsUtil.GetFloat(key)
	if nil ~= data_dic[key] then
		return data_dic[key]
	end

	local value = UnityEngine.PlayerPrefs.GetFloat(key)
	data_dic[key] = value
	return value
end

function PlayerPrefsUtil.SetString(key, value)
	if data_dic[key] ~= value then
		data_dic[key] = value
		UnityEngine.PlayerPrefs.SetString(key, value)
	end
end

function PlayerPrefsUtil.GetString(key)
	if nil ~= data_dic[key] then
		return data_dic[key]
	end

	local value = UnityEngine.PlayerPrefs.GetString(key)
	data_dic[key] = value
	return value
end

function PlayerPrefsUtil.HasKey(key)
	if nil ~= data_dic[key] then
		return true
	end

	return UnityEngine.PlayerPrefs.HasKey(key)
end

function PlayerPrefsUtil.DeleteKey(key)
	data_dic[key] = nil
	UnityEngine.PlayerPrefs.DeleteKey(key)
end
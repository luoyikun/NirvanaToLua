local develop_mode = UnityEngine.PlayerPrefs.GetInt("develop_mode")

local DevelopMode = {}
local check_list = {}
local isStopDevelopMode = false

G_IsDeveloper = false

function DevelopMode:Init()
	check_list = {
		require("editor.check_deleteme"),
		require("editor.check_listen"),
		require("editor.check_timer"),
		require("editor.check_reference"),
		-- require("editor.check_loader"),
	}

	self:RefreshDelopMode()
end

function DevelopMode:UnLoadAllcheck()
	for _, v in ipairs(check_list) do
		_G.package.loaded[v] = nil
	end

	check_list = {}
end

function DevelopMode:IsDeveloper()
	if isStopDevelopMode then
		return false
	end

	return 1 == develop_mode
end

function DevelopMode:RefreshDelopMode()
	G_IsDeveloper = self:IsDeveloper()
end

function DevelopMode:StopDevelopMode()
	isStopDevelopMode = true
	self:RefreshDelopMode()
end

function DevelopMode:ResumeDevelopMode()
	isStopDevelopMode = false
	self:RefreshDelopMode()
end

function DevelopMode:Update(now_time, elapse_time)
	if not self:IsDeveloper() then
		return
	end

	for _, v in ipairs(check_list) do
		if nil ~= v.Update then
			v:Update(now_time, elapse_time)
		end
	end
end

function DevelopMode:OnReleaseView(view)
	for _, v in ipairs(check_list) do
		if nil ~= v.OnReleaseView then
			v:OnReleaseView(view)
		end
	end
end

function DevelopMode:OnCreateClass(class_type)
	for _, v in ipairs(check_list) do
		if nil ~= v.OnCreateClass then
			v:OnCreateClass(class_type)
		end
	end
end

function DevelopMode:OnCreateObj(obj, class_type)
	for _, v in ipairs(check_list) do
		if nil ~= v.OnCreateObj then
			v:OnCreateObj(obj, class_type)
		end
	end
end

function DevelopMode:OnDeleteObj(obj)
	for _, v in ipairs(check_list) do
		if nil ~= v.OnDeleteObj then
			v:OnDeleteObj(obj)
		end
	end
end

function DevelopMode:OnBindFun(obj, func, new_func)
	for _, v in ipairs(check_list) do
		if nil ~= v.OnBindFun then
			v:OnBindFun(obj, func, new_func)
		end
	end
end

function DevelopMode:OnGameStop()
	for _, v in ipairs(check_list) do
		if nil ~= v.OnGameStop then
			v:OnGameStop()
		end
	end
end

DevelopMode:Init()
return DevelopMode



ViewManager = ViewManager or BaseClass()

function ViewManager:__init()
	if nil ~= ViewManager.Instance then
		print_error("[ViewManager]:Attempt to create singleton twice!")
	end
	ViewManager.Instance = self

	self.view_list = {}
	self.open_view_list = {}
	self.modal_view_stack = {}
	self.wait_load_chat_list = {}
end

function ViewManager:__delete()
	if self.main_open_event then
		GlobalEventSystem:UnBind(self.main_open_event)
		self.main_open_event = nil
	end
	ViewManager.Instance = nil
end

function ViewManager:DestoryAllAndClear(record_list)
	for k,v in pairs(self.view_list) do
		if v:IsOpen() then
			v:Close()
			v:Release()
		end
	end

	self.view_list = {}
	self.open_view_list = {}
	self.modal_view_stack = {}
	self.wait_load_chat_list = {}
end

-- 注册一个界面
function ViewManager:RegisterView(view, view_name)
	self.view_list[view_name] = view
end

-- 反注册一个界面
function ViewManager:UnRegisterView(view_name)
	self.view_list[view_name] = nil
end

-- 获取一个界面
function ViewManager:GetView(view_name)
	return self.view_list[view_name]
end

-- 界面是否打开
function ViewManager:IsOpen(view_name)
	if nil == self.view_list[view_name] then
		return false
	end

	return self.view_list[view_name]:IsOpen()
end

-- 界面是否打开
function ViewManager:HasOpenView()
	local list = self.open_view_list[UiLayer.Normal]
	if nil == list then
		return false
	end

	for k,v in pairs(list) do
		if v.view_name and v.view_name ~= ViewName.Main and v.view_name ~= "" and v.active_close and v:IsRealOpen() then
			return true
		end
	end

	return false
end

-- 打开界面
local now_view = nil
function ViewManager:Open(view_name, index, key, values)
	now_view = self.view_list[view_name]
	if nil ~= now_view then
		--活动界面特殊处理
		if view_name == ViewName.ActivityDetail then
			if IS_ON_CROSSSERVER then
				SysMsgCtrl.Instance:ErrorRemind(Language.Common.CantOpenInCross)
			else
				ActivityCtrl.Instance:ShowDetailView(index)
			end
			return
		end
		if view_name == ViewName.ArenaActivityView then
			local is_arena_open = ArenaData.Instance:GetArenaOpenOrNot()
			if not is_arena_open then
				TipsCtrl.Instance:ShowSystemMsg(Language.Arena.ArenaHasEnd)
				return
			end
		end
		local is_open, tips = self:CheckShowUi(view_name, index)
		if is_open then
			now_view:Open(index, true)
			if key ~= nil and values ~= nil then
				now_view:Flush(key, values)
			end

			-- 检测是否从自己面板打开其他面板
			for k, v in pairs(self.view_list) do
				if v:IsOpen() then
					v:OtherOpenView()
				end
			end
		else
			tips = (tips and tips ~= "" and tips) or Language.Common.FunOpenTip
			SysMsgCtrl.Instance:ErrorRemind(tips)
		end
	end
end

-- 配表打开界面
function ViewManager:OpenByCfg(cfg, data)
	if cfg == nil then
		return
	end

	local t = Split(cfg, "#")
	local view_name = t[1]
	local tab_index = t[2]

	-- 判断功能开启
	if TabIndex[tab_index] == TabIndex.baoju_medal and not OpenFunData.Instance:CheckIsHide("baoju_medal") then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.FuncNoOpen)
		return
	end

	local param_t = {
		open_param = nil,			--打开面板参数
		sub_view_name = nil,		--打开二级面板
		to_ui_name = nil,				--跳转ui
		to_ui_param = nil,			--跳转ui参数
	}
	param_t.item_id = data and data.item_id or 0
	if t[3] ~= nil then
		local key_value_list = Split(t[3], ",")
		for k,v in pairs(key_value_list) do
			local key_value_t = Split(v, "=")
			local key = key_value_t[1]
			local value = key_value_t[2]

			if key == "sub" then
				param_t.sub_view_name = value
			elseif key == "op" then
				param_t.open_param = value
			elseif key == "uin" then
				param_t.to_ui_name = value
			elseif key == "uip" then
				param_t.to_ui_param = value
			end
		end
		-- 精灵界面加第三个参数，不确定其他界面有没加第三个参数，故这里特殊处理
		if view_name == ViewName.SpiritView then
			SpiritData.Instance:SetOpenParam(t[3])
		end
	end
	local index = TabIndex[tab_index]
	if tonumber(tab_index)then
		index = tonumber(tab_index)
	end

	local key = param_t.sub_view_name or param_t.to_ui_name or "all"
	data = data or param_t

	self:Open(view_name, index, key, data)
end

-- 关闭界面
function ViewManager:Close(view_name, ...)
	now_view = self.view_list[view_name]
	if nil ~= now_view then
		now_view:Close(...)
	end
end

-- 关闭所有界面
function ViewManager:CloseAll()
	for k,v in pairs(self.view_list) do
		if v:CanActiveClose() then
			if v:IsOpen() then
				v:Close()
			end
		end
	end
end

-- 关闭界面
function ViewManager:CloseAllViewExceptViewName(view_name)
	for k, v in pairs(self.view_list) do
		if v:CanActiveClose() and k ~= view_name then
			if v:IsOpen() then
				if v.view_name ~= ViewName.ReviveView then
					v:Close()
				end
			end
		end
	end
end

-- 关闭界面
function ViewManager:CloseAllViewExceptViewName2(view_name, view_name2, view_name3)
	for k, v in pairs(self.view_list) do
		if v:CanActiveClose() and k ~= view_name and k ~= view_name2 and k ~= view_name3 then
			if v:IsOpen() then
				if v.view_name ~= ViewName.ReviveView then
					v:Close()
				end
			end
		end
	end
end

-- 是否可以显示该UI
function ViewManager:CheckShowUi(view_name, index)
	local can_show_view = true
	local tips = ""
	if IS_ON_CROSSSERVER then
		if view_name then
			-- 跨服中是否可以打开
			can_show_view, tips = CrossServerData.Instance:CheckCanOpenInCross(view_name)
		end
	end
	if view_name and can_show_view then
		can_show_view, tips = OpenFunData.Instance:CheckIsHide(string.lower(view_name))
	end
	local can_show_index = true
	if index and can_show_view and not self:IsntShowByIndex(view_name) and view_name ~= ViewName.KaifuActivityView  then
		can_show_index, tips = OpenFunData.Instance:CheckIsHide(index)
	end
	return can_show_view and can_show_index, tips
end

--显示不关乎index(排行榜的index没写在TabIndex)
function ViewManager:IsntShowByIndex(view_name)
	return view_name == ViewName.Ranking
end

-- 刷新界面
function ViewManager:FlushView(view_name, ...)
	now_view = self.view_list[view_name]
	if nil ~= now_view then
		now_view:Flush(...)
	end
end

-- 获得UI节点
function ViewManager:GetUiNode(view_name, node_name)
	now_view = self.view_list[view_name]
	if nil ~= now_view then
		return now_view:OnGetUiNode(node_name)
	end
	return nil
end

function ViewManager:PopViewToFront(view_name)
	now_view = self.view_list[view_name]
	if nil ~= now_view then
		self:RemoveOpenView(now_view)
		self:AddOpenView(now_view)
	end
end

function ViewManager:AddOpenView(view)
	self:RemoveOpenView(view, true)
	self.open_view_list[view:GetLayer()] = self.open_view_list[view:GetLayer()] or {}
	table.insert(self.open_view_list[view:GetLayer()], view)

	self:SortView(view:GetLayer())
	self:CheckViewRendering()
	self:CheckModalBg(view)

	GlobalEventSystem:Fire(OtherEventType.VIEW_OPEN, view)
end

--只显示最上面的一个界面的模态背景
function ViewManager:CheckModalBg(view, is_close)
	if view.is_modal then
		for k, v in pairs(self.modal_view_stack) do
			if view == v then
				table.remove(self.modal_view_stack, k)
			end
		end

		if not is_close then
			local insert_pos = 1
			if #self.modal_view_stack > 0 then
				for i = #self.modal_view_stack, 1, -1 do
					if view:GetLayer() >= self.modal_view_stack[i]:GetLayer() then
						insert_pos = i + 1
						break
					end
				end
			end
			table.insert(self.modal_view_stack, insert_pos, view)
			-- table.insert(self.modal_view_stack, view)
		end

		for i = 1, #self.modal_view_stack do
			local view = self.modal_view_stack[i]
			if nil ~= view and nil ~= view.mask_bg then
				local color_value = i == #self.modal_view_stack and view.background_opacity / 255 or 0
				local image = view.mask_bg.gameObject:GetComponent(typeof(UnityEngine.UI.Image))
				image.color = Color(0, 0, 0, color_value)
			end
		end
	end
end

function ViewManager:RemoveOpenView(view, ignore)
	if nil == self.open_view_list[view:GetLayer()] then
		return
	end

	for k, v in ipairs(self.open_view_list[view:GetLayer()]) do
		if v == view then
			v.__sort_order__ = 0
			table.remove(self.open_view_list[view:GetLayer()], k)
			break
		end
	end
	if not ignore then
		self:CheckViewRendering()
		if view.is_modal then
			self:CheckModalBg(view, true)
		end
	end
	GlobalEventSystem:Fire(OtherEventType.VIEW_CLOSE, view)
end

local is_full_screen = false
local can_inactive = false
local view = nil
local is_open = false
local is_rendering = false
local task_view = nil
local task_view_isopen = false
local unlock_view = nil
local unlock_view_isopen = false
function ViewManager:CheckViewRendering()
	is_full_screen = false
	task_view = task_view or self:GetView(ViewName.TaskDialog)
	task_view_isopen = task_view and task_view.is_real_open
	unlock_view = unlock_view or self:GetView(ViewName.Unlock)
	unlock_view_isopen = unlock_view and unlock_view.is_real_open
	for i=UiLayer.MaxLayer, 0, -1 do
		if self.open_view_list[i] then
			for j=#self.open_view_list[i], 1, -1 do
				view = self.open_view_list[i][j]
				can_inactive = false
				if view then
					if view.view_name ~= ViewName.TaskDialog
						and view.view_name ~= ViewName.TipsPowerChangeView
						and view.view_name ~= ViewName.TipsDisconnectedView
						and view.view_name ~= ViewName.LoadingTips
						and view.view_name ~= ViewName.Unlock
						and view.view_name ~= ViewName.PackageView
						and view.view_name ~= ViewName.TipsDoubleHitView
						and view.view_name ~= ViewName.SceneLoading then
						if unlock_view_isopen and view.view_name ~= ViewName.Main then
							can_inactive = true
						elseif task_view_isopen or is_full_screen then
							can_inactive = true
						elseif MainUIData.IsFightState and view.fight_info_view then
							can_inactive = true
						end
					end
					is_open = view.is_real_open
					is_rendering = view:IsRendering()
					if is_open and is_rendering ~= not can_inactive then
						view:SetRendering(not can_inactive)
						if not is_rendering and not can_inactive and view.root_node then
							view:ShowIndexCallBack(view.show_index)
						end
					end
					if view.full_screen and not is_full_screen and not task_view_isopen and not unlock_view_isopen then
						is_full_screen = true
					end
				end
			end
		end
	end

	--屏蔽场景和屏幕上的移动UI
	if Scene.Instance ~= nil and not Scene.Instance:IsSceneLoading() then
		Scene.Instance:SetSceneVisible(task_view_isopen or not is_full_screen)
		FightText.Instance:SetActive(task_view_isopen or not is_full_screen)
	end

	-- Close the ui scene.
	if not is_full_screen and UIScene.ui_scene_obj then
		UIScene:ChangeScene(nil)
	end
end

local SORT_INTERVAL = 30
OverrideOrderGroupMgr.Instance:SetGroupCanvasOrderInterval(SORT_INTERVAL)

function ViewManager:SortView(layer)
	if nil == self.open_view_list[layer] then
		return
	end

	for i, v in ipairs(self.open_view_list[layer]) do
		if v.__sort_order__ ~= i then
			v.__sort_order__ = i
			local root = v:GetRootNode()
			if nil ~= root then
				-- Dropdown会设置到30000，默认是所有层级的最上面。
				-- 防止把Dropdown的行为改变了.
				local canvas = root:GetComponentInChildren(typeof(UnityEngine.Canvas))
				if canvas.sortingOrder < 30000 then
					canvas.overrideSorting = true
					canvas.sortingOrder = canvas.sortingOrder % SORT_INTERVAL + layer * 1000 + i * SORT_INTERVAL
				end

				local overriders = root:GetComponentsInChildren(typeof(SortingOrderOverrider), true)
				local overrider_len = overriders.Length
				for j = 0, overrider_len - 1 do
					local overrider = overriders[j]
					overrider.SortingOrder = overrider.SortingOrder % SORT_INTERVAL + layer * 1000 + i * SORT_INTERVAL
				end
			end
		end
	end
end

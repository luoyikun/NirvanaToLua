KuafuGuildBattleScenePanle = KuafuGuildBattleScenePanle or BaseClass(BaseView)
local Max_Scence_Num = 6
-- 场景id对应Index
local MAP_INDEX_SCENE_ID = {
	[1450] = 1,		--不败皇城
	[1460] = 2,		--炽焰卫城
	[1461] = 3,		--鎏金卫城
	[1462] = 4,		--陵木卫城
	[1463] = 5,		--水心卫城
	[1464] = 6,		--墟土围城
}

function KuafuGuildBattleScenePanle:__init()
	self.active_close = false
	self.ui_config = {{"uis/views/kuafuliujie_prefab", "SceneMap"}}
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.item_list = {}
	self.change_scene_handle = nil
	self.fight_state_button_handle = nil
end

function KuafuGuildBattleScenePanle:ReleaseCallBack()
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	for k,v in pairs(self.flag_group_list) do
		v:DeleteMe()
	end
	self.flag_group_list = {}

	GlobalEventSystem:UnBind(self.change_scene_handle)
	self.change_scene_handle = nil
	GlobalEventSystem:UnBind(self.fight_state_button_handle)
	self.fight_state_button_handle = nil
	if self.move_tween then
		self.move_tween:Pause()
		self.move_tween = nil
	end
end

function KuafuGuildBattleScenePanle:CloseCallBack()
	local main_chat_view = MainUICtrl.Instance:GetMainChatView()
	if main_chat_view then
		main_chat_view:SetChatButtons(true)
	end
	MainUICtrl.Instance:SetShowExpBottle(true)
end

-- 打开后调用
function KuafuGuildBattleScenePanle:OpenCallBack()
	self:ActionComplete()
	self:FlushGuildMenber()
	local main_chat_view = MainUICtrl.Instance:GetMainChatView()
	if main_chat_view then
		main_chat_view:SetChatButtons(false)
	end
	MainUICtrl.Instance:SetShowExpBottle(false)
end

function KuafuGuildBattleScenePanle:LoadCallBack()
	self.item_list = {}
	for i = 1, Max_Scence_Num do
		self.item_list[i] = KuafuSceneItemRender.New(self.node_list["CellItem_" .. i])
		-- local map_info = KuafuGuildBattleData.Instance:GetMapCfg(i - 1)
		-- local scene_cfg = ConfigManager.Instance:GetSceneConfig(map_info.scene_id)
		-- if nil ~= scene_cfg then
		-- 	self.node_list["SceneName" .. i].text.text = scene_cfg.name
		-- end
	end

	self.flag_group_list = {}
	for i = 1, Max_Scence_Num do
		self.flag_group_list[i] = KuafuSceneFlagGroupRender.New(self.node_list["FlagPlace" .. i])
	end

	self.node_list["BtnOpen"].toggle:AddClickListener(BindTool.Bind(self.OnClickOpen, self))
	self.change_scene_handle = GlobalEventSystem:Bind(SceneEventType.SCENE_ALL_LOAD_COMPLETE, BindTool.Bind1(self.OnSceneChangeComplete, self))
	self.fight_state_button_handle = GlobalEventSystem:Bind(MainUIEventType.FIGHT_STATE_BUTTON, BindTool.Bind(self.CheckFightState, self))
	self:SetButtonIndex()

end

function KuafuGuildBattleScenePanle:OnFlush(param_list)
	for i = 1, Max_Scence_Num do
		self.item_list[i]:SetData(i)
	end
	local status = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.KF_GUILDBATTLE)
	for i = 1, Max_Scence_Num do
		self.node_list["FlagPlace" ..i]:SetActive(status)
	end
	for k,v in pairs(param_list) do
		if k == "occupy" then
			local flag_data = KuafuGuildBattleData.Instance:GetGuildBattleSceneMapInfo()
			if flag_data then
				local flag_index = MAP_INDEX_SCENE_ID[flag_data.scene_id]
				if flag_index then
					if self.flag_group_list[flag_index] then
						self.flag_group_list[flag_index]:SetFlagStatus(flag_data.occupy_list, 1)
					end
				end
			end
		elseif k == "enter" then
			local flag_data_list = KuafuGuildBattleData.Instance:GetGuildBattleEnterSceneInfo()
			if flag_data_list then
				for k,v in pairs(flag_data_list) do
					local flag_index = MAP_INDEX_SCENE_ID[v.scene_id]
					if flag_index and self.flag_group_list[flag_index] then
						self.flag_group_list[flag_index]:SetFlagStatus(v.flag_list, 2)
					end
				end
			end
		elseif k == "clear" then
			if self.flag_group_list then
				for k,v in pairs(self.flag_group_list) do
					v:SetFlagStatus(false, 3)
				end
			end
		elseif k == "menber_num" then
			self:FlushGuildMenber()
		end
	end
end

function KuafuGuildBattleScenePanle:FlushGuildMenber()
	local guild_menber_list = KuafuGuildBattleData.Instance:GetCrossGuildBattleSceneGuilderNumList()
	local scene_id = Scene.Instance:GetSceneId()
	if guild_menber_list then
		for k,v in pairs(guild_menber_list) do
			if v.scene_id then
				local scene_index = MAP_INDEX_SCENE_ID[v.scene_id]
				if scene_index and self.node_list and self.node_list["TxtGuildMenberNum" .. scene_index] then
					local num = v.guilder_num
					if v.scene_id == scene_id then
						num = num - 1
					end
					if num > 0 then
						self.node_list["TxtGuildMenberNum" .. scene_index]:SetActive(true)
						self.node_list["TxtGuildMenberNum" .. scene_index].text.text = string.format(Language.KuafuGuildBattle.SceneGuildMenber, num)
					else
						self.node_list["TxtGuildMenberNum" .. scene_index]:SetActive(false)
					end
				end
			end
		end
	end
end

function KuafuGuildBattleScenePanle:SetButtonIndex()
	for i = 1, Max_Scence_Num do
		self.item_list[i]:SetData(i)
	end
end

function KuafuGuildBattleScenePanle:CheckFightState(is_on)
	if self.root_node then
		self.root_node:SetActive(not is_on)
	end
end

function KuafuGuildBattleScenePanle:OnSceneChangeComplete(is_on)
	self:Flush()
end

function KuafuGuildBattleScenePanle:OnClickOpen()
	local pos_x = self.node_list["BtnOpen"].toggle.isOn and -256 or 30
		self.move_tween = self.node_list["BtnOpen"].transform:DOLocalMoveX(
		pos_x, 1)
end

function KuafuGuildBattleScenePanle:ActionComplete()
	if self.move_tween then
		self.move_tween:Pause()
		self.move_tween = nil
	end
	local pos_x = self.node_list["BtnOpen"].toggle.isOn and -256 or 30
	local Position = self.node_list["BtnOpen"].transform.localPosition
	self.node_list["BtnOpen"].transform.localPosition = Vector3(pos_x, Position.y, Position.z)
end

-------------------------------------------------------------------------------------------
KuafuSceneItemRender = KuafuSceneItemRender or BaseClass(BaseRender)
function KuafuSceneItemRender:__init()
	self.node_list["UpXunluStateImg"].toggle:AddClickListener(BindTool.Bind(self.UpXunluState, self))

	self.node_list["UpXunluStateImg"].event_trigger_listener:AddPointerUpListener(BindTool.Bind(self.OnClickUp, self))
	self.node_list["UpXunluStateImg"].event_trigger_listener:AddPointerDownListener(BindTool.Bind(self.OnClickDown, self))

end

function KuafuSceneItemRender:__delete()

end

function KuafuSceneItemRender:OnClickUp()
	self.node_list["UpXunluStateImg"].transform:SetAsFirstSibling()
end


function KuafuSceneItemRender:OnClickDown()
	self.node_list["UpXunluStateImg"].transform:SetAsLastSibling()
end



function KuafuSceneItemRender:OnFlush()
	local map_info = KuafuGuildBattleData.Instance:GetMapCfg(self.index - 1)
	local is_can_active = map_info.scene_id == Scene.Instance:GetSceneId()
	self.node_list["AtImg"]:SetActive(is_can_active)
	self.node_list["HighLight"]:SetActive(is_can_active)
	local scene_cfg = ConfigManager.Instance:GetSceneConfig(map_info.scene_id)
	if nil ~= scene_cfg then
		self.node_list["MapNameTxt"].text.text = scene_cfg.name
	end
end

function KuafuSceneItemRender:SetData(data)
	self.index = data
	self:Flush()
end

function KuafuSceneItemRender:UpXunluState()
	if ActivityData.Instance:GetActivityIsReady(ACTIVITY_TYPE.KF_GUILDBATTLE) then
		TipsCtrl.Instance:ShowSystemMsg(Language.GuildBattle.NoChangeCity)
		return
	end

	local main_role = Scene.Instance:GetMainRole()
	if main_role and main_role:IsFightState() and main_role.vo.attack_mode ~= GameEnum.ATTACK_MODE_PEACE then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CannotFlyInFight)
		return
	end

	local map_info = KuafuGuildBattleData.Instance:GetMapCfg(self.index - 1)
	if nil == map_info then return end
	local is_same_place = (map_info.scene_id == Scene.Instance:GetSceneId())
	if not is_same_place then
		GuajiCtrl.Instance:StopGuaji()
		GuajiCtrl.Instance:ClearAllOperate()
		MoveCache.end_type = MoveEndType.Auto
		KuafuGuildBattleCtrl.Instance:SendCrossGuildBattleOperateReq(CROSS_GUILDBATTLE_OPERATE.CROSS_GUILDBATTLE_OPERATE_GOTO_SCENE, map_info.city_index)
		KuafuGuildBattleCtrl.Instance:ResetSelcetedMonsterIndex()
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.GuildBattle.SamePlaceRemind)
		GuajiCtrl.Instance:MoveToScenePos(map_info.scene_id, map_info.relive_pos_x, map_info.relive_pos_y)
		-- GuajiCtrl.Instance:StopGuaji()
		-- GuajiCtrl.Instance:ClearAllOperate()
	end
end

---------------------------------------------------------------------------
KuafuSceneFlagGroupRender = KuafuSceneFlagGroupRender or BaseClass(BaseRender)

function KuafuSceneFlagGroupRender:__init()

end

function KuafuSceneFlagGroupRender:__delete()
end

function KuafuSceneFlagGroupRender:SetFlagStatus(occupy_list, index)
	if nil == occupy_list or nil == index then return end
	local guild_name = GameVoManager.Instance:GetMainRoleVo().guild_name
	if index == 1 then
		for k,v in pairs(occupy_list) do
			if self.node_list["Flag" .. k] then
				self.node_list["Flag" .. k]:SetActive(guild_name == v.guild_name)
			end
		end
	elseif index == 2 then
		for k,v in pairs(occupy_list) do
			if self.node_list["Flag" .. k] then
				self.node_list["Flag" .. k]:SetActive(guild_name == v.guild_name)
			end
		end
	elseif index == 3 then
		for i = 1, 3 do
			if self.node_list["Flag" .. i] then
				self.node_list["Flag" .. i]:SetActive(false)
			end
		end
	end
end
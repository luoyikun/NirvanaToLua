MapGlobalView = MapGlobalView or BaseClass(BaseRender)

local MAP_COUNT = 10

function MapGlobalView:__init(instance)
	if instance == nil then
		return
	end

	self.map_obj = self.node_list["Map"]

	self.map_img = {}
	self.label = {}
	self.map_name = {}
	self.wander_num = {}
	self.level = {}
	self.wander_all = {}
	self.lock = {}
	for i = 1, MAP_COUNT do
		local scene_id = MapData.WORLDCFG[i]
		self.map_img[scene_id] = self.node_list["ImageIcon" .. i]

		local label_obj = self.map_img[scene_id]:GetComponent(typeof(UINameTable)):Find("InvisiblePos")
		if label_obj ~= nil then
			label_obj = U3DObject(label_obj)
		end
		self.label[scene_id] = label_obj

		local name_table = self.map_img[scene_id]:GetComponent(typeof(UINameTable))
		local node_list = U3DNodeList(name_table)
		self.map_name[scene_id] = node_list["Text"]
		self.level[scene_id] = node_list["Text1"]
		if CROSS_BINGJINGZHIDI_DEF.MAP_ID == scene_id then
			self.lock[scene_id] = {node_list["InvisiblePos"], node_list["ImgNormal"], node_list["Text"], node_list["Label"], node_list["Map_Lock"], node_list["ImgBoss"], node_list["ActTisFrame"]}
		else
			self.lock[scene_id] = {node_list["InvisiblePos"], node_list["ImgNormal"], node_list["Text"], node_list["Label"]}
		end
		node_list["ImgIcon1"].toggle:AddClickListener(BindTool.Bind(self.OnClickButton, self, scene_id))
		self.wander_num[scene_id] = node_list["BossNum"]
		self.wander_all[scene_id] = node_list["Yunyouboss"]
		local map_config = MapData.Instance:GetMapConfig(scene_id)
		if map_config then
			local name = map_config.name or ""
			self.map_name[scene_id].text.text = name

			local level = map_config.levellimit or 0
			-- local str = string.format(Language.Guild.XXGrade, level)
			-- if level >= 100 then
			-- 	local sub_level, rebirth = PlayerData.GetLevelAndRebirth(level)
			-- 	if sub_level <= 1 then
			-- 		str = string.format(Language.Common.LevelFormat3, rebirth)
			-- 	else
			-- 		str = string.format(Language.Common.LevelFormat, sub_level, rebirth)
			-- 	end
			-- end
			self.level[scene_id].text.text = string.format(Language.Map.OpenLevel, PlayerData.GetLevelString(level))
		end
	end

	local size_delta = self.map_obj.rect.sizeDelta
	self.map_width = size_delta.x / 2
	self.map_height = size_delta.y / 2

	self.is_can_click = true
	self.eh_load_quit = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_QUIT, BindTool.Bind1(self.OnSceneLoadingQuite, self))
	self:Flush()
end

function MapGlobalView:__delete()
	if nil ~= self.eh_load_quit then
		GlobalEventSystem:UnBind(self.eh_load_quit)
		self.eh_load_quit = nil
	end

	self:CancleActCountDown()
	self:CancleActTipFrame()
end

function MapGlobalView:CloseCallBack()
	self:CancleActCountDown()
	self:CancleActTipFrame()
end

function MapGlobalView:SetShowLock(scene_id, is_show)
	self.lock[scene_id][1]:SetActive(is_show)
	UI:SetGraphicGrey(self.lock[scene_id][2], is_show)
	UI:SetGraphicGrey(self.lock[scene_id][3], is_show)
	UI:SetGraphicGrey(self.lock[scene_id][4], is_show)

	if CROSS_BINGJINGZHIDI_DEF.MAP_ID == scene_id then
		self:SetKFBorderlandIconState(scene_id, is_show)
	end
end

function MapGlobalView:OnSceneLoadingQuite()
	self:Flush()
end

function MapGlobalView:OnClickButton(target_scene_id)
	if not TaskData.Instance:GetCanFly() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Task.TaskTaskNoFly)
		return
	end
	local scene_id = Scene.Instance:GetSceneId()

	if nil ~= self.target_scene_id and nil ~= self.map_img[self.target_scene_id] then
		self.map_img[self.target_scene_id].toggle.isOn = true
	end

	if (self.is_can_click and target_scene_id ~= scene_id and self:GetIsCanGoToScene(target_scene_id, true)) then
		self.is_can_click = false
		-- 如果vip等级不够，且小飞鞋道具不足
		-- local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
		-- if not VipData.Instance:GetIsCanFly(vip_level) then
		-- 	local fly_shoe_id = MapData.Instance:GetFlyShoeId() or 0
		-- 	local num = ItemData.Instance:GetItemNumInBagById(fly_shoe_id) or 0
		-- 	if num <= 0 then
		-- 		self:OnMoveEnd(target_scene_id)
		-- 		ViewManager.Instance:Close(ViewName.Map)
		-- 		return
		-- 	end
		-- end
		self.target_scene_id = target_scene_id
		local uicamera = GameObject.Find("GameRoot/UICamera"):GetComponent(typeof(UnityEngine.Camera))
		local screen_pos_tbl = UnityEngine.RectTransformUtility.WorldToScreenPoint(uicamera, self.label[target_scene_id].rect.position)
		local rect = self.map_obj.rect
		local _, local_position_tbl = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(rect, screen_pos_tbl, uicamera, Vector2(0, 0))

		local target_position = local_position_tbl
		target_position.x = target_position.x + self.map_width
		target_position.y = target_position.y - self.map_height
		local tweener = self.node_list["MainroleIcon"].rect:DOAnchorPos(target_position, 1, false)
		tweener:OnComplete(BindTool.Bind(self.OnMoveEnd, self, target_scene_id))
	end
end

function MapGlobalView:Flush()
	--等级限制
	local main_role = GameVoManager.Instance:GetMainRoleVo()
	local level = main_role.level
	for _, v in ipairs(MapData.WORLDCFG) do
		local scene_config = ConfigManager.Instance:GetSceneConfig(v)
		if not scene_config then return end

		local levellimit = scene_config.levellimit
		self:SetShowLock(v, level < levellimit)
		self.map_img[v].toggle.enabled = level >= levellimit
		local wander_config = MapData.Instance:GetMapWanderAllInfocfg(v)
		if wander_config > 0 and level >= levellimit then
			self.wander_all[v]:SetActive(true)
			self.wander_num[v].text.text = string.format(Language.Boss.YunYouBossNum, wander_config)
		else
			self.wander_all[v]:SetActive(false)
		end
	end

	local scene_id = Scene.Instance:GetSceneId()
	if not self.label[scene_id] then
		self.node_list["MainroleIcon"]:SetActive(false)
		return
	end
	self.node_list["MainroleIcon"]:SetActive(true)
	local uicamera = GameObject.Find("GameRoot/UICamera"):GetComponent(typeof(UnityEngine.Camera))
	local screen_pos_tbl = UnityEngine.RectTransformUtility.WorldToScreenPoint(uicamera, self.label[scene_id].rect.position)
	local rect = self.map_obj.rect
	local _, local_position_tbl = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(rect, screen_pos_tbl, uicamera, Vector2(0, 0))
	self.node_list["MainroleIcon"].rect:SetLocalPosition(local_position_tbl.x, local_position_tbl.y, 0)

	self.map_img[scene_id].toggle.isOn = true
end

function MapGlobalView:OnMoveEnd(target_scene_id)
	self.is_can_click = true
	local scene_id = Scene.Instance:GetSceneId()
	if target_scene_id ~= scene_id then
		GuajiCtrl.Instance:ClearTaskOperate()
		if CROSS_BINGJINGZHIDI_DEF.MAP_ID == target_scene_id then
			CrossServerCtrl.Instance:SendCrossStartReq(ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_BIANJING_ZHIDI)
		elseif Scene.Instance:GetMainRole():IsFightState() then
			GuajiCtrl.Instance:MoveToScene(target_scene_id)
		else
			GuajiCtrl.Instance:FlyToScene(target_scene_id)
		end
		GuajiCtrl.Instance:SetMoveToPosCallBack(nil)
		ViewManager.Instance:Close(ViewName.Map)
	end
	self.target_scene_id = nil
end

function MapGlobalView:GetIsCanGoToScene(target_scene_id, is_tip)
	local tip = ""
	local is_can_go = true

	local scene = ConfigManager.Instance:GetSceneConfig(target_scene_id)
	if scene ~= nil then
		local level = scene.levellimit or 0
		if level > PlayerData.Instance:GetRoleVo().level then
			tip = string.format(Language.Map.level_limit_tip, PlayerData.GetLevelString(level))
			is_can_go = false
		end
	end

	if Scene.Instance:GetSceneType() ~= 0 then
		is_can_go = false
		tip = Language.Map.TransmitLimitTip
	end

	if is_can_go and CROSS_BINGJINGZHIDI_DEF.MAP_ID == target_scene_id then
		local guild_id = PlayerData.Instance.role_vo.guild_id
		local activity_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_BIANJING_ZHIDI)
		local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
		local open_act_day = KuaFuBorderlandData.Instance:GetKFBorderlandActivityOtherCfg().server_open_day or 0
		if open_day < open_act_day then
			is_can_go = false
			tip = Language.KFBorderland.NoArriveOpenDay
		elseif guild_id > 0 and activity_info and next(activity_info) and activity_info.status == ACTIVITY_STATUS.CLOSE then
			is_can_go = false
			tip = Language.Guild.GUILDJIUHUINOOPEN
		elseif guild_id <= 0 then
			is_can_go = false
			tip = Language.KFBorderland.MustHaveGuild
		end
	end

	if not is_can_go and is_tip and tip ~= "" then
		SysMsgCtrl.Instance:ErrorRemind(tip)
	end

	return is_can_go
end

function MapGlobalView:SetKFBorderlandIconState(scene_id, is_show)
	local activity_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_BIANJING_ZHIDI)
	if nil == activity_info or nil == next(activity_info) then 
		return
	end

	local guild_id = PlayerData.Instance.role_vo.guild_id
	if activity_info and next(activity_info) then
		self.lock[scene_id][5]:SetActive(is_show or (activity_info.status == ACTIVITY_STATUS.CLOSE or guild_id <= 0))
		self.lock[scene_id][6]:SetActive(not is_show and activity_info.status ~= ACTIVITY_STATUS.CLOSE and guild_id > 0)
	end

	self.lock[scene_id][7]:SetActive(false)
	self.node_list["DaDouEff"]:SetActive(false)
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local open_act_day = KuaFuBorderlandData.Instance:GetKFBorderlandActivityOtherCfg().server_open_day or 0
	if open_day < open_act_day then
		self.level[scene_id].text.text = ToColorStr(string.format(Language.KFBorderland.OpenDayOpenAct, open_act_day), TEXT_COLOR.RED) 
	else
		if activity_info.status == ACTIVITY_STATUS.OPEN or activity_info.status == ACTIVITY_STATUS.STANDY then
			self.level[scene_id].text.text = ToColorStr(Language.Activity.KaiQiZhong, TEXT_COLOR.GREEN)
			self.lock[scene_id][7]:SetActive(true)
			self.node_list["DaDouEff"]:SetActive(true and not is_show)
		else
			local open_act_cfg = KuaFuBorderlandData.Instance:GetOpenActTimeCfg()
			if open_act_cfg then
				local function get_time(num)
					local time_1 = math.floor(num / 100)
					local time_2 = num % 100
					local time_3 = (time_2 <= 10) and ("0" .. time_2) or time_2
					return string.format("%s:%s", time_1, time_3)
				end
				local open_time = get_time(open_act_cfg.activity_start_time)
				local end_time = get_time(open_act_cfg.activity_end_time)
				self.level[scene_id].text.text = ToColorStr(string.format(Language.KFBorderland.TimeOpenAct, open_time, end_time), TEXT_COLOR.RED) 
			end
		end
	end
end

function MapGlobalView:CancleActTipFrame()
	if self.act_tip_count_down then
		CountDown.Instance:RemoveCountDown(self.act_tip_count_down)
		self.act_tip_count_down = nil
	end
end

function MapGlobalView:CancleActCountDown()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end	
end

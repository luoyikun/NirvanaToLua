MapLocalView = MapLocalView or BaseClass(BaseRender)

function MapLocalView:__init(instance)
	if instance == nil then
		return
	end

	self.boss_icon_obj_list = {}
	self.yunyouboss_icon_obj_list = {}

	self.toggle_group = self.node_list["ContentGroup"].toggle_group

	local size_delta = self.node_list["MapImage"].rect.sizeDelta
	self.map_width = size_delta.x
	self.map_height = size_delta.y
	self.node_list["MapImage"].event_trigger_listener:AddPointerClickListener(BindTool.Bind(self.OnClickMiniMap, self))

	self:SetMapTargetImg(false)

	self.node_list["Btn1"].toggle:AddClickListener(BindTool.Bind(self.OnClickButton, self))
	self.node_list["Btn2"].toggle:AddClickListener(BindTool.Bind(self.OnClickButton, self))
	self.node_list["Btn3"].toggle:AddClickListener(BindTool.Bind(self.OnClickButton, self))
	self.node_list["Button"].button:AddClickListener(BindTool.Bind(self.OnClickChangeLine, self))
	self.node_list["ButtonImg"].button:AddClickListener(BindTool.Bind(self.OnClickChangeLine, self))
	self.node_list["FlyShoe"].button:AddClickListener(BindTool.Bind(self.OnClickFly, self))

	self.scene_id = Scene.Instance:GetSceneId()
	self.last_scene_id = 0
	self.is_draw_path = false
	self.is_can_draw_path = true
	self.last_move_end_time = 0
	self.is_zhu_cheng = false
	self.node_list["TargetIcon"]:SetActive(false)
	if not MinimapCamera.Instance then
		print_warning("MinimapCamera.Instance == nil")
	end

	self.eh_load_quit = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_QUIT, BindTool.Bind1(self.OnSceneLoadingQuite, self))
	self.eh_pos_change = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_POS_CHANGE, BindTool.Bind1(self.OnMainRolePosChangeFunc, self))
	self.eh_move_end = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_MOVE_END, BindTool.Bind1(self.OnMainRoleMoveEnd, self))
	self.task_change = GlobalEventSystem:Bind(OtherEventType.TASK_CHANGE,BindTool.Bind(self.OnTaskChange, self))
	self.reset_pos = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_RESET_POS,BindTool.Bind(self.OnMainRoleMoveEnd, self))
	self.cannot_find_theway = GlobalEventSystem:Bind(ObjectEventType.CAN_NOT_FIND_THE_WAY, BindTool.Bind1(self.OnCanNotFindWay, self))

	self:Flush()
end

function MapLocalView:__delete()
	self:ClearCache()
	if nil ~= self.eh_load_quit then
		GlobalEventSystem:UnBind(self.eh_load_quit)
		self.eh_load_quit = nil
	end

	if nil ~= self.eh_pos_change then
		GlobalEventSystem:UnBind(self.eh_pos_change)
		self.eh_pos_change = nil
	end
	if nil ~= self.eh_move_end then
		GlobalEventSystem:UnBind(self.eh_move_end)
		self.eh_move_end = nil
	end
	if nil ~= self.reset_pos then
		GlobalEventSystem:UnBind(self.reset_pos)
		self.reset_pos = nil
	end
	if nil ~= self.task_change then
		GlobalEventSystem:UnBind(self.task_change)
		self.task_change = nil
	end

	if nil ~= self.cannot_find_theway then
		GlobalEventSystem:UnBind(self.cannot_find_theway)
		self.cannot_find_theway = nil
	end

	self:RemoveCountDown()
	if self.delay_time2 then
		GlobalTimerQuest:CancelQuest(self.delay_time2)
		self.delay_time2 = nil
	end

	for k, v in pairs(self.yunyouboss_icon_obj_list) do
		ResMgr:Destroy(v)
	end
	self.yunyouboss_icon_obj_list = {}


	for k, v in pairs(self.boss_icon_obj_list) do
		ResMgr:Destroy(v)
	end
	self.boss_icon_obj_list = {}

	if self.wander_boss_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.wander_boss_down)
		self.wander_boss_down = nil
	end

end

function MapLocalView:RemoveCountDown()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

function MapLocalView:OnClickButton()
	self.node_list["MonsterTip"]:SetActive(false)
end

function MapLocalView:OnClickFly()
	-- 当前场景无法移动
	local logic = Scene.Instance:GetSceneLogic()
	if logic and not logic:CanCancleAutoGuaji() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Rune.CanNotCancleGuaji)
		return
	end
	if not TaskData.Instance:GetCanFly() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Task.TaskTaskNoFly)
		return
	end
	self:FlyToPos(self.scene_id, self.target_position.x, self.target_position.y)
	self.node_list["MonsterTip"]:SetActive(false)
end

function MapLocalView:OnClickChangeLine()
	ViewManager.Instance:Open(ViewName.LineView)
	self.node_list["MonsterTip"]:SetActive(false)
end

function MapLocalView:OnSceneLoadingQuite()
	self.scene_id = Scene.Instance:GetSceneId()
	self:Flush()
	self:ClearWalkPath()
end

function MapLocalView:OnTaskChange(task_event_type, task_id)
	local icon_table = MapData.Instance:GetNpcIcon()
	if icon_table then
		for _, v in pairs(icon_table) do
			local task_status = TaskData.Instance:GetNpcTaskStatus(v.npc_id)
			if task_status == TASK_STATUS.CAN_ACCEPT then
				v.jing_tan_hao_image:SetActive(true)
				v.wen_hao_image:SetActive(false)
			elseif task_status == TASK_STATUS.ACCEPT_PROCESS or task_status == TASK_STATUS.COMMIT then
				v.wen_hao_image:SetActive(true)
				v.jing_tan_hao_image:SetActive(false)
			else
				v.wen_hao_image:SetActive(false)
				v.jing_tan_hao_image:SetActive(false)
			end
		end
	end
end

function MapLocalView:Flush()
	if MinimapCamera.Instance then
		self.node_list["MapImage"].raw_image.texture = MinimapCamera.Instance.MapTexture
	end

	self.node_list["Content"]:SetActive(self.scene_id == 103)
	self.node_list["Content2"]:SetActive(self.scene_id ~= 103)

	self:FlushCell()
	self:SetMapMainRoleImg()
	self.delay_time2 = GlobalTimerQuest:AddDelayTimer(function() self:FlushBtn() end, 0.1)

	local open_line = PlayerData.Instance:GetAttr("open_line") or 0
	local scene_key = PlayerData.Instance:GetAttr("scene_key") or 0
	scene_key = scene_key + 1
	if open_line <= 0 then
		self.node_list["BtnLine"]:SetActive(false)
	else
		self.node_list["BtnLine"]:SetActive(true)
		self.node_list["Text"].text.text = string.format(Language.Common.Line, CommonDataManager.GetDaXie(scene_key))
	end
	local time_show = MapData.Instance:IsYunYouShowTime()
	local _, yunyouboss_count = MapData.Instance:GetBossPosCounInfo()
	if time_show and scene_key == 1 then
		self.node_list["YunyouText"]:SetActive(true)
		self.node_list["Countdown"]:SetActive(false)
		if self.wander_boss_down ~= nil then
			CountDown.Instance:RemoveCountDown(self.wander_boss_down)
			self.wander_boss_down = nil
		end
		if yunyouboss_count > 0 then
			self.node_list["Bosstips"].text.text = Language.Boss.YunYouBossTips
			self.node_list["BossNum"].text.text = string.format(Language.Boss.YunYouBossNum1, yunyouboss_count)
			self.node_list["BossCond"].text.text = Language.Boss.YunYouBossCond
			self.node_list["BossCond"]:SetActive(true)
		else
			self:SetReMainTime()
		end
	else
		self.node_list["YunyouText"]:SetActive(false)
		self.node_list["Countdown"]:SetActive(false)
		self.node_list["BossCond"]:SetActive(false)
	end
	self:SetYunYouBossIcon()
end

function MapLocalView:SetReMainTime()
	self.node_list["YunyouText"]:SetActive(false)
	self.node_list["Countdown"]:SetActive(true)
	local fush_time = MapData.Instance:GetYunYonFlushInfo()
	local sever_time = TimeCtrl.Instance:GetServerTime()
	local diff_time = fush_time - sever_time
	if self.wander_boss_down == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.wander_boss_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.wander_boss_down)
					self.wander_boss_down = nil
				end
				return
			end
			local time_str = TimeUtil.FormatSecond(left_time, 3)
			self.node_list["Countdown"].text.text = string.format(Language.Boss.YunYouBossTime, time_str)
		end

		diff_time_func(0, diff_time)
		self.wander_boss_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end


function MapLocalView:FlushBtn()
	for i = 1, 3 do
		self.node_list["Btn" .. i].accordion_element:Refresh()
	end
end

-- 清空缓存
function MapLocalView:ClearCache()
	MapData.Instance:ClearInfo()
	MapData.Instance:ClearIcon()
end

-- logic坐标转ui坐标
function MapLocalView:LogicToUI(logic_x, logic_y)
	if not MinimapCamera.Instance then 
		return 0, 0
	end
	local wx, wy = GameMapHelper.LogicToWorld(logic_x, logic_y)
	local uipos = MinimapCamera.Instance:TransformWorldToUV(Vector3(wx, 0, wy))
	local ui_x, ui_y = self.map_width * uipos.x, self.map_height * uipos.y
	return ui_x, ui_y
end

-- ui坐标转logic坐标
function MapLocalView:UIToLogic(ui_x, ui_y)
	if not MinimapCamera.Instance then return end
	local uipos_x = ui_x / self.map_width
	local uipos_y =  ui_y / self.map_height
	local world_pos = MinimapCamera.Instance:TransformUVToWorld(Vector2(uipos_x, uipos_y))
	local logic_x, logic_y = GameMapHelper.WorldToLogic(world_pos.x, world_pos.z)
	return logic_x, logic_y
end

function MapLocalView:MoveToPos(scene_id, x, y)
	--GuajiCtrl.Instance:StopGuaji()
	--GuajiCtrl.Instance:ClearTaskOperate()
	GuajiCtrl.Instance:SetGuajiType(GuajiType.HalfAuto)
	local scene_key = PlayerData.Instance:GetAttr("scene_key") or 0
	GuajiCtrl.Instance:MoveToPos(scene_id, x, y, 0, 0, false, scene_key)
	self:DrawWalkPath()
end

function MapLocalView:FlyToPos(scene_id, x, y)
	TaskCtrl.Instance:SendFlyByShoe(scene_id, x, y)
end

--设置小地图角色人物小图标
function MapLocalView:SetMapMainRoleImg()
	if not MinimapCamera.Instance then
		return
	end
	self.node_list["MainroleIcon"].transform:SetAsLastSibling()
	-- 旋转
	-- local forwardDir = Scene.Instance:GetMainRole():GetRoot().transform.forward
	-- local resultEuler = Quaternion.LookRotation(forwardDir).eulerAngles
	-- local cameraEuler = MinimapCamera.Instance.transform.localEulerAngles.y
	-- self.node_list["MainroleIcon"].rect.localRotation = Quaternion.Euler(0,0,-resultEuler.y + cameraEuler)

	local role_x, role_y = Scene.Instance:GetMainRole():GetLogicPos()
	local ui_x, ui_y = self:LogicToUI(role_x, role_y)
	self.node_list["MainroleIcon"].transform:SetLocalPosition(ui_x, ui_y, 0)


end

function MapLocalView:SetMapTargetImg(flag, x, y)
	self.node_list["FlyShoe"].transform:SetAsLastSibling()
	if x and y then
		local ui_x, ui_y = self:LogicToUI(x, y)
		self.node_list["FlyShoe"].transform:SetLocalPosition(ui_x, ui_y, 0)
	end
	if not flag then
		self.node_list["FlyShoe"]:SetActive(false)
		return
	end
	self.node_list["FlyShoe"]:SetActive(true)
end

--角色移动回调
function MapLocalView:OnMainRolePosChangeFunc()
	if not MapCtrl.Instance.view:IsLoaded() then
		return
	end
	self:SetMapMainRoleImg()
	self.node_list["FlyShoe"]:SetActive(true)
	if self.last_move_end_time + 0.2 > Status.NowTime then
		self.node_list["FlyShoe"]:SetActive(false)
	end
	if Scene.Instance:GetMainRole().vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
		self.node_list["FlyShoe"]:SetActive(false)
		return
	end

	local main_role = Scene.Instance:GetMainRole()
	local path_pos_list = main_role:GetPathPosList()
	if self.last_path_pos_list ~= path_pos_list then
		self.last_path_pos_list = path_pos_list
		self:ClearWalkPath()
	end

	if not self.is_draw_path and not self.is_move_finished then
		self:DrawWalkPath()
	else
		self.is_move_finished = false
	end
	self:UpdateWalkPath()
end

--角色移动结束
function MapLocalView:OnMainRoleMoveEnd()
	if not MapCtrl.Instance.view:IsLoaded() then
		return
	end
	if Scene.Instance:GetMainRole().vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
		return
	end
	self.node_list["FlyShoe"]:SetActive(false)
	self.is_move_finished = true
	self:ClearWalkPath()
	self.last_move_end_time = Status.NowTime
end

function MapLocalView:OnClickMiniMap(event)
	-- 当前场景无法移动
	local logic = Scene.Instance:GetSceneLogic()
	if logic and not logic:CanCancleAutoGuaji() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Rune.CanNotCancleGuaji)
		return
	end
	self.node_list["MonsterTip"]:SetActive(false)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CanNotMoveInJump)
		return
	end

	local ok, localPosition = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(
		self.node_list["MapImage"].rect, event.position, event.pressEventCamera, localPosition)
	if not ok then
		return
	end

	local logic_x, logic_y = self:UIToLogic(localPosition.x, localPosition.y)
	if logic_x and logic_y then
		if AStarFindWay:IsBlock(logic_x, logic_y) then
			return
		end
	end

	GuajiCtrl.Instance:StopGuaji()
	self:MoveToPos(self.map_id, logic_x, logic_y)
	GlobalEventSystem:Fire(OtherEventType.MOVE_BY_CLICK)
end

-- 找不到去往目标的路径
function MapLocalView:OnCanNotFindWay()
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	GuajiCtrl.Instance:StopGuaji()
end

-----------------------------------------------动态生成Cell------------------------------------------------------
function MapLocalView:FlushCell()
	self.map_id = self.scene_id
	if (self.map_id == self.last_scene_id) then
		return
	end

	local config = MapData.Instance:GetMapConfig(self.map_id)
	if not config then
		print_warning("No Map Config")
		return
	end

	-- 是否是主城
	self.is_zhu_cheng = (self.scene_id == 103)

	self.node_list["TxtTitle"].text.text = config.name

	local prefab_table = {}
	-- 读取Gather，不生成button
	local map_config = MapData.Instance:GetMapConfig(self.scene_id) or {}
	if map_config.scene_type ~= 0 or self.is_zhu_cheng then
		local gather_config = ConfigManager.Instance:GetAutoConfig("gather_auto").gather_list
		local last_gather_id = 0
		local last_obj = nil
		for _, v in ipairs(config.gathers) do
			if self.map_id == 8002 and last_obj and not self:CalDistance(last_obj.x, last_obj.y, v.x, v.y, 20) then
				last_gather_id = 0
			end
			if (last_gather_id ~= v.id) then
				last_gather_id = v.id
				last_obj = v
				local name = ""
				if gather_config and gather_config[v.id] then
					name = gather_config[v.id].show_name
				end
				local info = {
					obj = object,
					x = v.x,
					y = v.y,
					id = v.id,
					obj_type = SceneObjType.GatherObj,
					scene_id = self.map_id,
					name = name,
					level = level
				}
				prefab_table[info] = info
			end
		end
	end
	MapData.Instance:SetInfo(prefab_table)

	local res_async_loader = AllocResAsyncLoader(self, "button_res_loader")
	res_async_loader:Load("uis/views/map_prefab", "Button", nil, function (prefab)
		if nil == prefab then
			return
		end
		-- 生成NPC
		local npc_config = ConfigManager.Instance:GetAutoConfig("npc_auto").npc_list
		for _, v in pairs(config.npcs) do
			if npc_config[v.id] and npc_config[v.id].is_view == 1 then
				local object = ResMgr:Instantiate(prefab)
				object.transform:SetParent(self.node_list["List" .. 1].transform, false)
				object:GetComponent("Toggle").group = self.toggle_group
				local obj_name = U3DObject(object:GetComponent(typeof(UINameTable)):Find("Text"))
				local name = ""
				if npc_config[v.id] and npc_config[v.id].show_name and npc_config[v.id].show_name ~= "" then
					name = npc_config[v.id].show_name
				end
				obj_name.text.text = name
				local info = {
					obj = object,
					x = v.x,
					y = v.y,
					id = v.id,
					obj_type = SceneObjType.Npc,
					scene_id = self.map_id,
					name = name,
					level = 0
				}
				prefab_table[info] = info
				object:GetComponent(typeof(UnityEngine.UI.Toggle)):AddClickListener(BindTool.Bind(self.ClickButton, self, info))
			end
		end
		-- 生成Door
		for _, v in pairs(config.doors) do
			local object = ResMgr:Instantiate(prefab)
			object.transform:SetParent(self.node_list["List" .. 3].transform, false)
			object:GetComponent("Toggle").group = self.toggle_group
			--local obj_name = object.transform:FindHard("Text"):GetComponent(typeof(UnityEngine.UI.Text))
			local obj_name = U3DObject(object:GetComponent(typeof(UINameTable)):Find("Text"))
			local scene_config = MapData.Instance:GetMapConfig(v.target_scene_id)
			local name = ""
			local level = 0
			if scene_config then
				name = scene_config.name
				level = scene_config.levellimit
			end
			obj_name.text.text = name
			local info = {
				obj = object,
				x = v.x,
				y = v.y,
				id = v.id,
				obj_type = SceneObjType.Door,
				scene_id = self.map_id,
				name = name,
				level = level
			}
			prefab_table[info] = info
			object:GetComponent(typeof(UnityEngine.UI.Toggle)):AddClickListener(BindTool.Bind(self.ClickButton, self, info))
		end

		self:FlushIcon(scene_id)
	end)

	if not is_zhu_cheng then
		local res_async_loader = AllocResAsyncLoader(self, "button1_loader")
		res_async_loader:Load("uis/views/map_prefab", "Button1", nil, function (prefab)
			if nil == prefab then
				return
			end

			-- 生成Monster
			local monster_config = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
			local last_monster_id = 0
			local last_obj = nil

			for _, v in ipairs(config.monsters) do
				if self.map_id == 8002 and last_obj and not self:CalDistance(last_obj.x, last_obj.y, v.x, v.y, 20) then
					last_monster_id = 0
				end

				if (last_monster_id ~= v.id) then
					local object = ResMgr:Instantiate(prefab)
					last_monster_id = v.id
					last_obj = v
					object.transform:SetParent(self.node_list["List" .. 2].transform, false)
					object:GetComponent("Toggle").group = self.toggle_group
					local name = ""
					local level = 0
					if monster_config[v.id] and monster_config[v.id].name and monster_config[v.id].name ~= "" and monster_config[v.id].level then
						name = monster_config[v.id].name
						level = monster_config[v.id].level
					end
					U3DObject(object:GetComponent(typeof(UINameTable)):Find("Text")).text.text = name
					if Scene.Instance:GetSceneType() == SceneType.Common then
						local monsters_info = MapData.Instance:GetMonster(v.id)
						if monsters_info then
							level = monsters_info.mix_level
						end
					end
					local monsters_info = MapData.Instance:GetMonster(v.id)
					U3DObject(object:GetComponent(typeof(UINameTable)):Find("Text1")).text.text = "Lv." .. level .. "-" .. level + 20
					local info = {
						obj = object,
						x = v.x,
						y = v.y,
						id = v.id,
						obj_type = SceneObjType.Monster,
						scene_id = self.map_id,
						name = name,
						level = level
					}
					prefab_table[info] = info
					object:GetComponent(typeof(UnityEngine.UI.Toggle)):AddClickListener(BindTool.Bind(self.ClickButton, self, info))
				end
			end

			self:FlushIcon(scene_id)
			self:OpenCallBack()
			self.node_list["Btn2"].accordion_element.isOn = true
			GlobalTimerQuest:AddDelayTimer(function() 
				if self.node_list then
					self.node_list["Btn2"].accordion_element:Refresh() 
				end
				end, 0.1)
		end)
	end
end

-- 点击右侧的按钮
function MapLocalView:CalDistance(x, y, target_x, target_y, range)
	return math.floor((x - target_x) * (x - target_x)) + math.floor((y - target_y) * (y - target_y)) <= range * range
end

-- 点击右侧的按钮
function MapLocalView:ClickButton(index)
	local info = MapData.Instance:GetInfoByIndex(index)
	-- 当前场景无法移动
	local logic = Scene.Instance:GetSceneLogic()
	if logic and not logic:CanCancleAutoGuaji() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Rune.CanNotCancleGuaji)
		return
	end
	if info then
		if (info.obj_type == SceneObjType.Npc) then
			MoveCache.end_type = MoveEndType.NpcTask
			MoveCache.param1 = info.id
			GuajiCache.target_obj_id = info.id
			self:MoveToPos(info.scene_id, info.x, info.y)
		elseif (info.obj_type == SceneObjType.Monster) then
			local monsters_info = MapData.Instance:GetMonster(info.id)
			if monsters_info ~= nil then
				self:SetMonterTip(index, monsters_info)
			end
			
			MoveCache.end_type = MoveEndType.Auto
			MoveCache.param1 = info.id
			GuajiCache.target_obj_id = info.id
			GuajiCache.guaji_type = GuajiType.Monster
			GuajiCache.monster_id = info.id
			self:MoveToPos(info.scene_id, info.x, info.y)

		elseif (info.obj_type == SceneObjType.Door) then
			MoveCache.end_type = MoveEndType.Normal
			self:MoveToPos(info.scene_id, info.x, info.y)
		end
	end
end

function MapLocalView:OpenCallBack()
	self:SetMonterTip()
	local info = nil
	local monsters_info = MapData.Instance:GetInfoByType(SceneObjType.Monster)
	local main_role_level = GameVoManager.Instance:GetMainRoleVo().level or 0
	local level_diff = 1000
	if monsters_info then
		for k,v in pairs(monsters_info) do
			if v.level <= main_role_level then
				local temp = main_role_level - v.level
				if temp < level_diff then
					level_diff = temp
					info = v
				end
			end
		end
	end
	if info then
		local monsters_info = MapData.Instance:GetMonster(info.id)
		if monsters_info ~= nil then
			self:SetMonterTip(info, monsters_info)
			if info.obj then
				-- info.obj:GetComponent("Toggle").isOn = true
			end
		end
	end
end

function MapLocalView:SetMonterTip(index, monsters_info)
	if monsters_info then
		self.node_list["MonsterTip"]:SetActive(true)
		local ui_x, ui_y = self:LogicToUI(index.x, index.y)
		local anchor_x = 0
		local anchor_y = 1
		if ui_x > 110 then --面板位置超出界面时改变锚点
			anchor_x = 1
		end
		if ui_y < -165 then
			anchor_y = 0
		end

		local equip_level = CommonDataManager.GetDaXie(monsters_info.equip_level)
		local standard_exp =  CommonDataManager.ConverMoney(monsters_info.standard_exp or 0)

		self.node_list["TxtLevel"].text.text = string.format(Language.Map.RecommendLevel, monsters_info.mix_level)
		self.node_list["TxtGongJi"].text.text = string.format(Language.Map.RecommendPower, monsters_info.recommend_gongji)
		self.node_list["TxtBlueNum"].text.text = string.format(Language.Map.BlueNum, equip_level, monsters_info.blue_num)
		self.node_list["TxtPurpleNum"].text.text = string.format(Language.Map.PurpleNum, equip_level, monsters_info.purple_num)
		self.node_list["TxtExp"].text.text = string.format(Language.Map.StandardExp, standard_exp)
		self.node_list["MonsterTip"].rect.pivot = Vector2(anchor_x, anchor_y)
		self.node_list["MonsterTip"].transform:SetLocalPosition(ui_x, ui_y, 0)
	else
		self.node_list["MonsterTip"]:SetActive(false)
	end
end
-----------------------------------------------动态生成Icon------------------------------------------------------
function MapLocalView:FlushIcon(scene_id)
	if not MinimapCamera.Instance then
		return
	end
	local icon_table = {}
	local count_down = 4

	local res_async_loader = AllocResAsyncLoader(self, "Icon_NPC_loader")
	res_async_loader:Load("uis/views/map_prefab", "Icon_NPC", nil, function (prefab)
		if nil == prefab then
			return
		end

		local npc_info, count = MapData.Instance:GetInfoByType(SceneObjType.Npc)
		for i = 1, count do
			local info = npc_info[i]
			local object = ResMgr:Instantiate(prefab)
			local name_table = object:GetComponent(typeof(UINameTable))
			local node_list = U3DNodeList(name_table)
			local wen_hao_image = node_list["Img1"]
			local jing_tan_hao_image = node_list["Img"]
			table.insert(icon_table, {obj = object, wen_hao_image = wen_hao_image, jing_tan_hao_image = jing_tan_hao_image, npc_id = info.id})
			self:SetMapImg(object, info.x, info.y)
			local task_status = TaskData.Instance:GetNpcTaskStatus(info.id)
			if task_status == TASK_STATUS.CAN_ACCEPT then
				jing_tan_hao_image:SetActive(true)
			elseif task_status == TASK_STATUS.ACCEPT_PROCESS or task_status == TASK_STATUS.COMMIT then
				wen_hao_image:SetActive(true)
			end
		end

		count_down = count_down - 1
		if (count_down == 0) then
			MapData.Instance:SetIcon(icon_table)
		end
	end)

	local res_async_loader = AllocResAsyncLoader(self, "Icon_Monster_loader")
	res_async_loader:Load("uis/views/map_prefab", "Icon_Monster", nil, function (prefab)
		if nil == prefab then
			return
		end

		local monster_info, count = MapData.Instance:GetInfoByType(SceneObjType.Monster)
		for i = 1, count do
			local info = monster_info[i]
			local object = ResMgr:Instantiate(prefab)
			table.insert(icon_table, {obj = object, })
			local level = info.level or 0
			local node_list = U3DNodeList(object:GetComponent(typeof(UINameTable)))
			node_list["Text"].text.text = level .. Language.Common.Ji
			self:SetMapImg(object, info.x, info.y)
		end

		count_down = count_down - 1
		if (count_down == 0) then
			MapData.Instance:SetIcon(icon_table)
		end
	end)

	local res_async_loader = AllocResAsyncLoader(self, "Icon_Gather_loader")
	res_async_loader:Load("uis/views/map_prefab", "Icon_Gather", nil, function (prefab)
		if nil == prefab then
			return
		end

		local gather_info, count = MapData.Instance:GetInfoByType(SceneObjType.GatherObj)
		for i = 1, count do
			local info = gather_info[i]
			local object = ResMgr:Instantiate(prefab)
			table.insert(icon_table, {obj = object, })
			local node_list = U3DNodeList(object:GetComponent(typeof(UINameTable)))
			node_list["Text"].text.text = info.name
			self:SetMapImg(object, info.x, info.y)
		end

		count_down = count_down - 1
		if (count_down == 0) then
			MapData.Instance:SetIcon(icon_table)
		end
	end)

	local res_async_loader = AllocResAsyncLoader(self, "Icon_Door_loader")
	res_async_loader:Load("uis/views/map_prefab", "Icon_Door", nil, function (prefab)
		if nil == prefab then
			return
		end

		local door_info, count = MapData.Instance:GetInfoByType(SceneObjType.Door)
		for i = 1, count do
			local info = door_info[i]
			local object = ResMgr:Instantiate(prefab)
			table.insert(icon_table, {obj = object, })
			local level = info.level or 0
			object.transform:FindHard("Text"):GetComponent(typeof(UnityEngine.UI.Text)).text = info.name
			self:SetMapImg(object, info.x, info.y)
		end

		count_down = count_down - 1
		if (count_down == 0) then
			MapData.Instance:SetIcon(icon_table)
		end
	end)

	self:SetXingZuoYiJiBossIcon()
end


--云游BOSS
function MapLocalView:SetYunYouBossIcon()
	-- local is_show = MapDataInstance:IsYunYouShowTime()
	-- local load_boss_icon = MapData.Instance:GetBossMapCfg(scene_id)
	-- if not is_show then return end
	for k, v in pairs(self.yunyouboss_icon_obj_list) do
		ResMgr:Destroy(v)
	end
	self.yunyouboss_icon_obj_list = {}

	local scene_key = PlayerData.Instance:GetAttr("scene_key") or 0
	scene_key = scene_key + 1
	if scene_key ~= 1 then
		return
	end

	local res_async_loader = AllocResAsyncLoader(self, "Icon_YunYouBoss_loader")
	res_async_loader:Load("uis/views/map_prefab", "Icon_YunYouBoss", nil, function (prefab)
		if nil == prefab then
			return
		end
		local is_show = MapData.Instance:IsYunYouShowTime()
		if is_show then
			local yunyou_info, count = MapData.Instance:GetBossPosCounInfo()
			for i = 1, count do
				local info = yunyou_info[i]
				local object = ResMgr:Instantiate(prefab)
				table.insert(self.yunyouboss_icon_obj_list, object)
				local level = info.level or 0
				-- object.transform:FindHard("Text"):GetComponent(typeof(UnityEngine.UI.Text)).text = info.name
				self:SetMapImg(object, info.born_pos_x, info.born_pos_y)
			end
		end
	end)
end

-- 星座遗迹特殊处理，显示BOSS图标
function MapLocalView:SetXingZuoYiJiBossIcon()
	local scene_id = Scene.Instance:GetSceneId()
	local load_boss_icon = MapData.Instance:GetBossMapCfg(scene_id)

	if next(load_boss_icon) == nil then return end

	for k, v in pairs(self.boss_icon_obj_list) do
		ResMgr:Destroy(v)
	end
	self.boss_icon_obj_list = {}


	local res_async_loader = AllocResAsyncLoader(self, "Icon_Boss_loader")
	res_async_loader:Load("uis/views/map_prefab", "Icon_Boss", nil, function (prefab)
		if nil == prefab then
			return
		end

		for k, v in pairs(load_boss_icon) do
			if v.activity_type == 0 or ActivityData.Instance:GetActivityIsOpen(v.activity_type) then
				local object = ResMgr:Instantiate(prefab)
				table.insert(self.boss_icon_obj_list, object)
				object.transform:FindHard("Text"):GetComponent(typeof(UnityEngine.UI.Text)).text = v.boss_name
				self:SetMapImg(object, v.pos_x, v.pos_y)
			end
		end
	end)
end


function MapLocalView:SetMapImg(obj, x, y)
	obj.transform:SetParent(self.node_list["MapImage"].transform, false)
	local ui_x, ui_y = self:LogicToUI(x, y)
	obj.transform:SetLocalPosition(ui_x, ui_y, 0)
end

function MapLocalView:ChangeNpcImage()

end

--------------------------------------------------------------------画路径线-----------------------------------------------------------------

function MapLocalView:ClearWalkPath()
	self.node_list["PathLine"].line_renderer.positionCount = 0
	self.node_list["PathLine"]:SetActive(false)
	self.is_draw_path = false
	self:SetMapTargetImg(false)
	self.is_can_draw_path = false
	self:RemoveCountDown()
	self.delay_time = GlobalTimerQuest:AddDelayTimer(function() self.is_can_draw_path = true end, 0.3)
end

function MapLocalView:DrawWalkPath()
	self.node_list["PathLine"]:SetActive(true)
	local main_role = Scene.Instance:GetMainRole()
	local path_pos_list = main_role:GetPathPosList()

	if #path_pos_list <= 0 then
		self:ClearWalkPath()
		return
	end

	self.target_position = {}
	self.target_position.x = path_pos_list[#path_pos_list].x
	self.target_position.y = path_pos_list[#path_pos_list].y

	--设置结束位置图标
	self:SetMapTargetImg(true, self.target_position.x, self.target_position.y)

	if not self.is_can_draw_path then
		return
	end
	if Scene.Instance:GetMainRole().vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
		self.node_list["FlyShoe"]:SetActive(false)
		return
	end

	--画线
	local count = #path_pos_list + 1
	-- if (count == 1) then
	--  count = 2
	-- end
	self.node_list["PathLine"].line_renderer.positionCount = count

	for i = 1, #path_pos_list do
		local role_spinodal_x, role_spinodal_y = self:LogicToUI(path_pos_list[i].x, path_pos_list[i].y)
		role_spinodal_x = role_spinodal_x + self.map_width / 2
		role_spinodal_y = role_spinodal_y - self.map_height / 2
		self.node_list["PathLine"].line_renderer:SetPosition(count - 1 - i, Vector3(role_spinodal_x, role_spinodal_y, 0))
	end
	-- if (#path_pos_list == 1) then
		local role_spinodal_x, role_spinodal_y = self:LogicToUI(path_pos_list[1].x, path_pos_list[1].y)
		role_spinodal_x = role_spinodal_x + self.map_width / 2
		role_spinodal_y = role_spinodal_y - self.map_height / 2
		self.node_list["PathLine"].line_renderer:SetPosition(count - 1, Vector3(role_spinodal_x, role_spinodal_y, 0))
	-- end

	self.is_draw_path = true
end

function MapLocalView:UpdateWalkPath()
	if not self.is_draw_path then
		-- self:DrawWalkPath()
		return
	end
	if not self.is_can_draw_path then
		return
	end
	local main_role = Scene.Instance:GetMainRole()
	local path_pos_list = main_role:GetPathPosList()
	local path_index = main_role:GetPathPosIndex()
	local total_count = #path_pos_list
	local count = total_count - path_index + 2
	self.node_list["PathLine"].line_renderer.positionCount = count

	local role_x, role_y = main_role:GetLogicPos()
	local role_spinodal_x, role_spinodal_y = self:LogicToUI(role_x, role_y)
	-- local path_pos_index = main_role:GetPathPosIndex()
	-- local next_pos = path_pos_list[path_pos_index]
	-- if next_pos then
	-- 	local next_x, next_y = self:LogicToUI(next_pos.x, next_pos.y)
	-- 	self.node_list["MainroleIcon"].transform:DORotate(Vector3(0, 0,
	-- 	 Vector3.Angle(
	-- 	 	Vector3(next_x - role_spinodal_x, next_y - role_spinodal_y, 0), Vector3.up)), 0.5)
	-- end

	role_spinodal_x = role_spinodal_x + self.map_width / 2
	role_spinodal_y = role_spinodal_y - self.map_height / 2
	self.node_list["PathLine"].line_renderer:SetPosition(count - 1, Vector3(role_spinodal_x, role_spinodal_y, 0))
end









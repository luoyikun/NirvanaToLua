-- 仙宠-奇遇-MeetContent
SpiritMeetView = SpiritMeetView or BaseClass(BaseRender)

local MAP_COUNT = 9

function SpiritMeetView:__init(instance)

end

function SpiritMeetView:LoadCallBack(instance)
	if instance == nil then
		return
	end

	self.node_list["HelpBtn"].button:AddClickListener(BindTool.Bind(self.ClickHelp, self))
	self.node_list["QuickBtn"].button:AddClickListener(BindTool.Bind(self.OnClickQuick, self))
	self.map_img = {}
	self.label = {}
	self.map_name = {}
	self.level = {}
	self.is_lock = {}
	self.spirit_count = {}
	self.has_spirit = {}
	self.has_spirit2 = {}
	for i = 1, MAP_COUNT do
		local scene_id = MapData.WORLDCFG[i]
		self.map_img[scene_id] = self.node_list["ImageIcon" .. i]

		local label_obj = self.map_img[scene_id]:GetComponent(typeof(UINameTable)):Find("TargetPosition")
		if label_obj ~= nil then
			label_obj = U3DObject(label_obj)
		end
		self.label[scene_id] = label_obj
		local name_table = self.map_img[scene_id]:GetComponent(typeof(UINameTable))
		self.map_name[scene_id] = name_table:Find("NameTxt")
		self.level[scene_id] = name_table:Find("LevelTxt")
		self.is_lock[scene_id] = name_table:Find("IsLockImg")
		self.spirit_count[scene_id] = name_table:Find("Txtcount")
		self.has_spirit[scene_id] = name_table:Find("SpiritImg")
		self.has_spirit2[scene_id] = name_table:Find("PanelImg")
		self.map_img[scene_id].toggle:AddClickListener(BindTool.Bind(self.OnClickButton, self, scene_id))
		local map_config = MapData.Instance:GetMapConfig(scene_id)
		if map_config then
			local name = map_config.name or ""
			self.map_name[scene_id]:GetComponent(typeof(UnityEngine.UI.Text)).text = name
			self.level[scene_id]:GetComponent(typeof(UnityEngine.UI.Text)).text = ToColorStr(Language.GoldMember.Member_shop_level, COLOR.RED)
		end
	end

	local size_delta = self.node_list["Map"].rect.sizeDelta
	self.map_width = size_delta.x / 2
	self.map_height = size_delta.y / 2

	self.is_can_click = true

	self.eh_load_quit = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_QUIT, BindTool.Bind1(self.OnSceneLoadingQuite, self))

	self:Flush()

	for i = 1, 9 do
		local obj = self.node_list["arrow" .. i]
		local rect_tran = obj:GetComponent(typeof(UnityEngine.RectTransform))
		local tween = rect_tran:DOAnchorPosY(10, 0.5)
		tween:SetEase(DG.Tweening.Ease.InOutSine)
		tween:SetLoops(-1, DG.Tweening.LoopType.Yoyo)
	end
end

function SpiritMeetView:__delete()
	if nil ~= self.eh_load_quit then
		GlobalEventSystem:UnBind(self.eh_load_quit)
		self.eh_load_quit = nil
	end
end

function SpiritMeetView:OpenCallBack()
	self:Flush()
end

function SpiritMeetView:CloseCallBack()
end


function SpiritMeetView:OnSceneLoadingQuite()
	self:Flush()
end

function SpiritMeetView:OnFlush(param_list)
	self:FlushView()
	for k, v in pairs(param_list) do
		if k == "spirit_egg_pos_info" then
			self:FlushFlySpiritEggPos()
		end
	end
end

function SpiritMeetView:OnClickButton(target_scene_id)
	if not TaskData.Instance:GetCanFly() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Task.TaskTaskNoFly)
		return
	end
	local scene_id = Scene.Instance:GetSceneId()
	if (self.is_can_click and self:GetIsCanGoToScene(target_scene_id, true)) then
		self.is_can_click = false
		local uicamera = GameObject.Find("GameRoot/UICamera"):GetComponent(typeof(UnityEngine.Camera))
		local screen_pos_tbl = UnityEngine.RectTransformUtility.WorldToScreenPoint(uicamera, self.label[target_scene_id].rect.position)
		local rect = self.node_list["Map"].rect
		local _, local_position_tbl = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(rect, screen_pos_tbl, uicamera, Vector2(0, 0))
		local target_position = local_position_tbl
		-- if scene_id ~= target_scene_id then
		-- 	target_position.x = target_position.x + self.map_width
		-- 	target_position.y = target_position.y - self.map_height
		-- else
			target_position.x = target_position.x + self.map_width
			target_position.y = target_position.y - self.map_height
		-- end
		local tweener = self.node_list["MainroleIcon"].rect:DOAnchorPos(target_position, 1, false)
		tweener:OnComplete(BindTool.Bind(self.OnMoveEnd, self, target_scene_id))
	end
end

function SpiritMeetView:FlushView()
	local main_role = GameVoManager.Instance:GetMainRoleVo()
	local level = main_role.level
	-- for _, v in ipairs(MapData.WORLDCFG) do
	for i = 1, MAP_COUNT do
		local v = MapData.WORLDCFG[i]
		if v then
			local scene_config = ConfigManager.Instance:GetSceneConfig(v)
			local levellimit = scene_config.levellimit
			local is_can_enter = level >= levellimit
			self.map_img[v].toggle.enabled = is_can_enter
			self.is_lock[v]:SetActive(not is_can_enter)
			local blue_count, purple_count = SpiritData.Instance:GetSceneHasSpirit(v)
			self.has_spirit[v]:SetActive(blue_count > 0 and is_can_enter)
			self.has_spirit2[v]:SetActive(purple_count > 0 and is_can_enter)
			self.spirit_count[v]:GetComponent(typeof(UnityEngine.UI.Text)).text = string.format(Language.JingLing.HasSpirit, blue_count)
		end
	end

	local spirit_meet_cfg = SpiritData.Instance:GetSpiritAdvantageCfg()
	local spirit_meet_info = SpiritData.Instance:GetSpiritAdvantageInfo()
	local spirit_count = spirit_meet_info.today_gather_blue_jingling_count or 0
	local residue_count =  spirit_meet_cfg.other[1].times - spirit_count

	if level >= spirit_meet_cfg.other[1].skip_limit_level and residue_count > 0 then
		self.node_list["QuickBtn"]:SetActive(true)
	else
		self.node_list["QuickBtn"]:SetActive(false)
	end

	if residue_count <= 0 then
		residue_count = ToColorStr(residue_count, COLOR.RED)
	else
		residue_count = ToColorStr(residue_count, COLOR.GREEN)
	end
	self.node_list["TextTxt"].text.text = string.format(Language.Common.GrabNum, residue_count)

	local scene_id = Scene.Instance:GetSceneId()
	if not self.label[scene_id] then
		self.node_list["MainroleIcon"]:SetActive(false)
		return
	end
	self.node_list["MainroleIcon"]:SetActive(true)

	local uicamera = GameObject.Find("GameRoot/UICamera"):GetComponent(typeof(UnityEngine.Camera))
	local screen_pos_tbl = UnityEngine.RectTransformUtility.WorldToScreenPoint(uicamera, self.label[scene_id].rect.position)
	local rect = self.node_list["Map"].rect
	local _, local_position_tbl = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(rect, screen_pos_tbl, uicamera, Vector2(0, 0))
	self.node_list["MainroleIcon"].rect:SetLocalPosition(local_position_tbl.x, local_position_tbl.y, 0)

	self.map_img[scene_id].toggle.isOn = true
end

function SpiritMeetView:OnMoveEnd(target_scene_id)
	self.is_can_click = true
	local scene_id = Scene.Instance:GetSceneId()
	-- if target_scene_id ~= scene_id then
		-- 请求要传送的场景位置信息
		GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
		BossCtrl.Instance:SendJingLingAdvantageBossEnter(JINGLING_ADCANTAGE_OPER_TYPE.JINGLING_ADCANTAGE_OPER_TYPE_EGG, target_scene_id)
	-- end
end

-- 刷新到仙宠蛋位置
function SpiritMeetView:FlushFlySpiritEggPos()
	local spirit_meet_egg_pos_info = SpiritData.Instance:GetSpiritMeetEggPosInfo()
	local x = spirit_meet_egg_pos_info.pos_x or 0
	local y = spirit_meet_egg_pos_info.pos_y or 0

	if x == 0 and y == 0 then
		GuajiCtrl.Instance:ClearTaskOperate()
		if Scene.Instance:GetMainRole():IsFightState() then
			GuajiCtrl.Instance:MoveToScene(spirit_meet_egg_pos_info.scene_id)
		else
			GuajiCtrl.Instance:FlyToScene(spirit_meet_egg_pos_info.scene_id)
		end
		GuajiCtrl.Instance:SetMoveToPosCallBack(nil)
	else
		GuajiCtrl.Instance:ClearTaskOperate()
		local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
		local fly_shoe_id = MapData.Instance:GetFlyShoeId() or 0
		local num = ItemData.Instance:GetItemNumInBagById(fly_shoe_id) or 0
		if not VipData.Instance:GetIsCanFly(vip_level) and num <= 0 then
			local callback = function()
				local SceneKey = 0 --这里默认去1线
				GuajiCtrl.Instance:MoveToPos(spirit_meet_egg_pos_info.scene_id, x, y, 1, 1, false, SceneKey)
			end
			callback()
			GuajiCtrl.Instance:SetMoveToPosCallBack(callback)
		else
			local SceneKey = 0 --这里默认去1线
			GuajiCtrl.Instance:FlyToScenePos(spirit_meet_egg_pos_info.scene_id, x, y, false, SceneKey)
			GuajiCtrl.Instance:SetMoveToPosCallBack(nil)
		end
	end

	self.target_scene_id = nil
	SpiritCtrl.Instance:SpiritViewClose()
end

function SpiritMeetView:GetIsCanGoToScene(target_scene_id, is_tip)
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

	if not is_can_go and is_tip and tip ~= "" then
		SysMsgCtrl.Instance:ErrorRemind(tip)
	end

	return is_can_go
end

function SpiritMeetView:ClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(217)
end

function SpiritMeetView:OnClickQuick()
	local spirit_meet_cfg = SpiritData.Instance:GetSpiritAdvantageCfg()
	local spirit_meet_info = SpiritData.Instance:GetSpiritAdvantageInfo()
	local spirit_count = spirit_meet_info.today_gather_blue_jingling_count or 0
	local residue_count =  spirit_meet_cfg.other[1].times - spirit_count

	local gold = residue_count * spirit_meet_cfg.other[1].skip_gather_consume
	local str = string.format(Language.QuickCompletion[SKIP_TYPE.SKIP_TYPE_JINGLING_ADVANTAGE], gold, residue_count)

	local ok_callback = function ()
		MarriageCtrl.Instance:SendCSSkipReq(SKIP_TYPE.SKIP_TYPE_JINGLING_ADVANTAGE, -1)
	end
	
	TipsCtrl.Instance:ShowCommonAutoView("", str, ok_callback, nil, true, nil, nil, Language.Task.YouXianBindGold)
end

function SpiritMeetView:UITween()
	UITween.MoveShowPanel(self.node_list["HelpBtn"], Vector3(-47.7, 385, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["BottomPanel"], Vector3(0, -430, 0), 0.7)
	UITween.AlpahShowPanel(self.node_list["Map"], true, 0.5, DG.Tweening.Ease.InExpo)
end
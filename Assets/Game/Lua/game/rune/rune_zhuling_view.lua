local POINTER_ANGLE_LIST = {
	[1] = 0,
	[2] = -60,
	[3] = -120,
	[4] = 180,
	[5] = 120,
	[6] = 60,
}

RuneZhuLingView = RuneZhuLingView or BaseClass(BaseRender)

local MOVE_TIME = 0.5
function RuneZhuLingView:UIsMove()
	UITween.MoveShowPanel(self.node_list["RightPanel"] , Vector3(200 , 10 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["DownPanel"] , Vector3(-210 , -410 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["BtnTip"] , Vector3(-440 , 420 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["AnimToggle"] , Vector3(65 , -330 , 0 ) , MOVE_TIME )
	UITween.AlpahShowPanel(self.node_list["Table"] , true , MOVE_TIME , DG.Tweening.Ease.InExpo)
	UITween.ScaleShowPanel(self.node_list["Table"] ,Vector3(0.7 , 0.7 , 0.7 ) , MOVE_TIME )
end

function RuneZhuLingView:__init()
	for i = 1, 6 do
		local slot_cfg = RuneData.Instance:GetRuneZhulingSlotCfg()
		self.node_list["Reward_text" .. i].text.text = slot_cfg[i].description
	end
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["ZhanLiNumTxt"])

	self.node_list["CenterAuto"].button:AddClickListener(BindTool.Bind(self.OnCenterAuto, self, true))
	self.node_list["Center"].button:AddClickListener(BindTool.Bind(self.OnSpawnCircle, self))
	self.node_list["BtnTip"].button:AddClickListener(BindTool.Bind(self.OnOpenHelp, self))

	self.stars_list = {}
	local stars_obj = self.node_list["Stars"]
	for i = 1, 5 do
		self.stars_list[i] = stars_obj.transform:FindHard("star" .. i)
	end

	self.slot_cell_list = {}
	for i = 1, 8 do
		local slot_obj = self.node_list["RuneItme" .. i]
		local slot_cell = RuneFuLingCell.New(slot_obj, self)
		slot_cell:SetIndex(i)
		slot_cell:SetClickCallBack(BindTool.Bind(self.SlotClick, self, i))
		table.insert(self.slot_cell_list, slot_cell)
	end

	self.show_hight_light_list = {}
	for i = 1, 6 do
		self.show_hight_light_list[i] = self.node_list["HighLight" .. i]
	end

	self.cur_select_index = 1
	self.is_rolling = false
	self.cur_reward_index = 1
	self.zhuling_slot_bless = 0
	self.delay_flush_prog_timer = nil
	self:ResetLastLevel()
	self.is_auto = false
	self.node_list["ImageText"].text.text = Language.Rune.AutoLianHun
end

function RuneZhuLingView:__delete()
	for k,v in pairs(self.slot_cell_list) do
		v:DeleteMe()
	end
	self.slot_cell_list = {}

	self.show_hight_light_list = {}

	self.center_pointer = nil
	self.btn_text = nil
	self.btn_zhuling = nil
	self.is_auto = nil
	self.is_can = nil
	self.delay_flush_prog_timer = nil
	self.fight_text = nil

	self.stars_list = {}
end

function RuneZhuLingView:CloseCallBack()
	self.is_auto = false
	TipsCtrl.Instance:DestroyFlyEffectByViewName(ViewName.Rune)
end

function RuneZhuLingView:InitView()
	self:FlushView()
end

function RuneZhuLingView:OnRewardDataChange(cur_reward_slot, zhuling_slot_bless)
	self:ResetVariable()
	self:ResetHighLight()

	self:SaveVariable(cur_reward_slot + 1, zhuling_slot_bless)
	self:TrunPointer()
end

function RuneZhuLingView:TrunPointer()
	if self.is_rolling then
		return
	end

	if self.node_list["AnimToggle"].toggle.isOn then
		local angle = POINTER_ANGLE_LIST[self.cur_reward_index]
		self.node_list["CenterPointer"].transform.localRotation = Quaternion.Euler(0, 0, angle)
		self:ShowHightLight()
		return
	end

	self.is_rolling = true
	self:SetAllToggleEnabled(false)
	local time = 0
	local tween = self.node_list["CenterPointer"].transform:DORotate(
		Vector3(0, 0, -360 * 20),
		20,
		DG.Tweening.RotateMode.FastBeyond360)
	tween:SetEase(DG.Tweening.Ease.OutQuart)
	tween:OnUpdate(function ()
		time = time + UnityEngine.Time.deltaTime
		if time >= 1 then
			tween:Pause()
			local angle = POINTER_ANGLE_LIST[self.cur_reward_index]
			local tween1 = self.node_list["CenterPointer"].transform:DORotate(
					Vector3(0, 0, -360 * 3 + angle),
					2,
					DG.Tweening.RotateMode.FastBeyond360)
			tween1:OnComplete(function ()
				self:SetAllToggleEnabled(true)
				self:ShowHightLight()
				if false == self:FlushProgressEffect() then
					self.is_rolling = false 
				end
			end)
		end
	end)
end

function RuneZhuLingView:ResetVariable()
	local rune_info = RuneData.Instance:GetRuneZhulingInfo()
	self.zhuling_slot_bless = rune_info.zhuling_slot_bless
end

function RuneZhuLingView:ResetHighLight()

	for k,v in pairs(self.show_hight_light_list) do
		v.gameObject:SetActive(false)
	end
end

function RuneZhuLingView:SaveVariable(cur_reward_index, zhuling_slot_bless)
	self.cur_reward_index = cur_reward_index
	self.zhuling_slot_bless = zhuling_slot_bless
end

function RuneZhuLingView:ShowHightLight()
	for i = 1, 6 do
		self.node_list["HighLight" .. i]:SetActive(i == self.cur_reward_index)
	end
end

function RuneZhuLingView:FlushProgressEffect()
	if self.delay_flush_prog_timer then
		GlobalTimerQuest:CancelQuest(self.delay_flush_prog_timer)
		self.delay_flush_prog_timer = nil
	end
	self.delay_flush_prog_timer = GlobalTimerQuest:AddDelayTimer(function() 
			self.is_rolling = false 
			end, 2)
	return true
end

function RuneZhuLingView:SetAllToggleEnabled(enabled)
	for k,v in pairs(self.slot_cell_list) do
		v:SetToggleEnabled(enabled)
	end
end

function RuneZhuLingView:SlotClick(index)
	if self.cur_select_index ~= index then 
		self.is_auto = false
	end
	if self.is_rolling then
		self:FlushView()
		return
	end

	local slot_list = RuneData.Instance:GetSlotList()
	if slot_list[index + 1] and slot_list[index + 1].type < 0 then
		if not RuneData.Instance:GetIsLockByIndex(index + 1) then
			RuneCtrl.Instance:SetSlotIndex(index)
			SysMsgCtrl.Instance:ErrorRemind(Language.Rune.Tips)
		end
		return
	end

	self.cur_select_index = index
	self:ResetLastLevel()
	self:FlushView()
end

function RuneZhuLingView:FlushView()
	local rune_info = RuneData.Instance:GetRuneZhulingInfo()
	if nil == rune_info.zhuling_slot_bless then
		return
	end
	self:ResetVariable()

	local slot_list = RuneData.Instance:GetSlotList()
	for k, v in ipairs(self.slot_cell_list) do
		local slot_data = slot_list[k + 1]
		v:SetHighLight(k == self.cur_select_index and slot_data.type >= 0)
		v:SetData(slot_data)
	end

	local grade = rune_info.run_zhuling_list[self.cur_select_index] and rune_info.run_zhuling_list[self.cur_select_index].grade or 0
	local zhuling_bless = rune_info.run_zhuling_list[self.cur_select_index] and rune_info.run_zhuling_list[self.cur_select_index].zhuling_bless or 0
	local grade_cfg = RuneData.Instance:GetRuneZhulingGradeCfg(self.cur_select_index - 1, grade)

	self.node_list["ProgressBGValue"].text.text = zhuling_bless .. "/" .. grade_cfg.need_bless
	self.node_list["ProgressBG"].slider.value = zhuling_bless / grade_cfg.need_bless
	self.node_list["LevelText"].text.text = string.format(Language.Rune.JiLian, CommonDataManager.GetDaXie(grade_cfg.client_grade))

	--属性
	local cur_attr = CommonDataManager.GetAttributteByClass(grade_cfg)
	self.node_list["HPValue"].text.text = cur_attr.max_hp
	self.node_list["AttackValue"].text.text = cur_attr.gong_ji
	self.node_list["DefenceValue"].text.text = cur_attr.fang_yu
	self.node_list["ShanBiValue"].text.text = cur_attr.shan_bi

	self.node_list["MingZhongValue"].text.text = cur_attr.ming_zhong
	self.node_list["BaoJiValue"].text.text = cur_attr.bao_ji
	self.node_list["JianRenValue"].text.text = cur_attr.jian_ren
	self.node_list["SystemAttrValue"].text.text = string.format("+%s", grade_cfg.special_add / 100) .. "%"

	local next_grade_cfg = RuneData.Instance:GetRuneZhulingGradeCfg(self.cur_select_index - 1, grade + 1)
	local is_active = nil ~= next_grade_cfg
	self.node_list["HPUpAttr"]:SetActive(is_active)
	self.node_list["AttackUpAttr"]:SetActive(is_active)
	self.node_list["DefenceUpAttr"]:SetActive(is_active)
	self.node_list["MingZhongUpAttr"]:SetActive(is_active)
	self.node_list["ShanBiUpAttr"]:SetActive(is_active)
	self.node_list["BaoJiUpAttr"]:SetActive(is_active)
	self.node_list["JianRenUpAttr"]:SetActive(is_active)
	self.node_list["SystemAttrUpAttr"]:SetActive(is_active)

	-- self.node_list["StartButtonText"].text.text = not is_active and Language.Common.YiManJi or Language.Rune.ZhuRuLingLi
	-- UI:SetButtonEnabled(self.node_list["BtnZhuLing"], is_active)

	local next_attr = CommonDataManager.GetAttributteByClass(next_grade_cfg)
	if nil ~= next_grade_cfg then
		self.node_list["HPUpAttrValue"].text.text = next_attr.max_hp - cur_attr.max_hp
		self.node_list["AttackUpAttrValue"].text.text = next_attr.gong_ji - cur_attr.gong_ji
		self.node_list["DefenceUpAttrValue"].text.text = next_attr.fang_yu - cur_attr.fang_yu
		self.node_list["ShanBiUpAttrValue"].text.text = next_attr.shan_bi - cur_attr.shan_bi
		self.node_list["MingZhongUpAttrValue"].text.text = next_attr.ming_zhong - cur_attr.ming_zhong
		self.node_list["BaoJiUpAttrValue"].text.text = next_attr.bao_ji - cur_attr.bao_ji
		self.node_list["JianRenUpAttrValue"].text.text = next_attr.jian_ren - cur_attr.jian_ren
		self.node_list["UpAttrValue_up"].text.text = string.format("+%s", ((next_grade_cfg.special_add - grade_cfg.special_add) / 100)) .. "%"
	else
		self.node_list["ProgressBGValue"].text.text = Language.Common.YiMan
		self.node_list["ProgressBG"].slider.value = 1

	end
	local flag = nil ~= grade_cfg
	local next_flag = ni ~= next_grade_cfg
	self.node_list["HP"]:SetActive((flag and cur_attr.max_hp > 0) or (next_flag and next_attr.max_hp > 0))
	self.node_list["Attack"]:SetActive((flag and cur_attr.gong_ji > 0) or (next_flag and next_attr.gong_ji > 0))
	self.node_list["Defence"]:SetActive((flag and cur_attr.fang_yu > 0) or (next_flag and next_attr.fang_yu > 0))
	self.node_list["MingZhong"]:SetActive((flag and cur_attr.shan_bi > 0) or (next_flag and next_attr.shan_bi > 0))
	self.node_list["ShanBi"]:SetActive((flag and cur_attr.ming_zhong > 0) or (next_flag and next_attr.ming_zhong > 0))
	self.node_list["BaoJi"]:SetActive((flag and cur_attr.bao_ji > 0) or (next_flag and next_attr.bao_ji > 0))
	self.node_list["JianRen"]:SetActive((flag and cur_attr.jian_ren > 0) or (next_flag and next_attr.jian_ren > 0))

	local stars_count = grade % 5 > 0 and grade % 5 or 5
	stars_count = grade <= 0 and 0 or stars_count

	--战力
	local select_data = self.slot_cell_list[self.cur_select_index]:GetData()
	local select_rune_data = RuneData.Instance:GetAttrInfo(select_data.quality, select_data.type, select_data.level)
	local attr_info = CommonStruct.AttributeNoUnderline()
	local attr_type_1 = Language.Rune.AttrType[select_rune_data.attr_type_0]
	local attr_type_2 = Language.Rune.AttrType[select_rune_data.attr_type_1]
	if attr_type_1 then
		RuneData.Instance:CalcAttr(attr_info, attr_type_1, select_rune_data.add_attributes_0 * grade_cfg.special_add / 10000)
	end
	if attr_type_2 then
		RuneData.Instance:CalcAttr(attr_info, attr_type_2, select_rune_data.add_attributes_1 * grade_cfg.special_add / 10000)
	end

	local zhuling_cap = CommonDataManager.GetCapability(cur_attr)
	local rune_axtra_cap = CommonDataManager.GetCapability(attr_info)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = zhuling_cap + rune_axtra_cap
	end
	self:FlushStars()
end

function RuneZhuLingView:ResetLastLevel()
	local rune_info = RuneData.Instance:GetRuneZhulingInfo()
	self.last_level = rune_info.run_zhuling_list[self.cur_select_index] and rune_info.run_zhuling_list[self.cur_select_index].grade or 0
end

function RuneZhuLingView:FlushStars()
	local rune_info = RuneData.Instance:GetRuneZhulingInfo()
	if nil == rune_info.zhuling_slot_bless then
		return
	end
	local level = rune_info.run_zhuling_list[self.cur_select_index] and rune_info.run_zhuling_list[self.cur_select_index].grade or 0
	local index = level % 5
	if index == 0 then
		for k, v in pairs(self.stars_list) do
			UI:SetGraphicGrey(v, level <= 0)
		end
	else
		for i = 1, index do
			UI:SetGraphicGrey(self.stars_list[i], false)
		end
		for i = index + 1, 5 do
			UI:SetGraphicGrey(self.stars_list[i], true)
		end
	end
	if level >= self.last_level + 1 then
		self.last_level = level
		if index == 0 then
			index = 5
		elseif index == 1 and level ~= 1 then
			self.is_auto = false
			self:SetAutoButtonGray()
		end
		local bundle_name, asset_name = ResPath.GetMiscEffect("Effect_baodian")
		EffectManager.Instance:PlayAtTransform(bundle_name, asset_name, self.stars_list[index].transform, 1.0, nil, nil)
	end
end

function RuneZhuLingView:OnCenterAuto(is_can)
	if nil == self.slot_cell_list[self.cur_select_index] then
		return
	end
	local select_data = self.slot_cell_list[self.cur_select_index]:GetData()
	if nil == select_data or (select_data and select_data.type < 0) then
		TipsCtrl.Instance:ShowSystemMsg(Language.Rune.PleaseSelect)
		return
	end
	if is_can then
		self.is_auto = not self.is_auto
	end
	UI:SetButtonEnabled(self.node_list["Center"], not self.is_auto)
	if self.is_auto then
		self.node_list["AnimToggle"].toggle.isOn = true
		self:OnSpawnCircle()
		self:RemoveCountDown()
		self.delay_time = GlobalTimerQuest:AddDelayTimer(function()
				self:OnCenterAuto()
		end, 0.7)
	end
	self:SetAutoButtonGray()
end

function RuneZhuLingView:RemoveCountDown()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

function RuneZhuLingView:SetAutoButtonGray()
	if self.is_auto then
		self.node_list["ImageText"].text.text = Language.Rune.Stop
	else
		self.node_list["ImageText"].text.text = Language.Rune.AutoLianHun
		self.is_auto = false
	end
end
function RuneZhuLingView:Zhuling()
	local callback = function()
		self:FlushView()
	end
	local param = 1
	if self.is_rolling then
		param = 2
	end
	local bundle_name, asset_name = ResPath.GetUiXEffect("UI_guangdian1")
	TipsCtrl.Instance:ShowFlyEffectManager(ViewName.Rune, bundle_name, asset_name, self.node_list["CenterPointer"], self.node_list["EffetGreen"], nil, param, callback)
end

function RuneZhuLingView:OnSpawnCircle()
	if self.is_rolling then
		return
	end
	if nil == self.slot_cell_list[self.cur_select_index] then
		return
	end
	local select_data = self.slot_cell_list[self.cur_select_index]:GetData()
	if nil == select_data or (select_data and select_data.type < 0) then
		TipsCtrl.Instance:ShowSystemMsg(Language.Rune.PleaseSelect)
		return
	end

	local other_cfg = RuneData.Instance:GetOtherCfg()
	local rune_info = RuneData.Instance:GetRuneZhulingInfo()
	if nil == rune_info.zhuling_slot_bless then
		return
	end
	local grade_cfg = RuneData.Instance:GetRuneZhulingGradeCfg(self.cur_select_index - 1)
	local grade = rune_info.run_zhuling_list[self.cur_select_index] and rune_info.run_zhuling_list[self.cur_select_index].grade or 0

	if grade >= #grade_cfg then
		self.is_auto = false
		self:SetAutoButtonGray()
		return
	end

	if PlayerData.Instance:GetRoleVo().gold < other_cfg.zhuling_cost then
		self.is_auto = false
		TipsCtrl.Instance:ShowLackDiamondView()
		return
	end

	RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_RAND_ZHILING_SLOT, self.cur_select_index - 1)
end

function RuneZhuLingView:OnOpenHelp()
	local tips_id = 232
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function RuneZhuLingView:GetSelectIndex()
	return self.cur_select_index
end

-----------------------RuneFuLingCell---------------------------
RuneFuLingCell = RuneFuLingCell or BaseClass(BaseRender)
function RuneFuLingCell:__init(obj, parant)
	self.parent = parant
	self.node_list["Slot_1"].toggle:AddClickListener(BindTool.Bind(self.Click, self))
end

function RuneFuLingCell:__delete()
end

function RuneFuLingCell:SetCurrentSelect(index)
	self.select_rune_index = index
end

function RuneFuLingCell:Click()
	if self.clickcallback then
		self.clickcallback(self, self.data)
	end
end

function RuneFuLingCell:SetClickCallBack(callback)
	self.clickcallback = callback
end

function RuneFuLingCell:SetIndex(index)
	self.index = index
end

function RuneFuLingCell:SetHighLight(state)
	self.root_node.toggle.isOn = state
end

function RuneFuLingCell:SetToggleEnabled(enabled)
	if enabled and nil ~= self.data then
		local lock_state = RuneData.Instance:GetIsLockByIndex(self.index + 1)
		self.node_list["LockImage"]:SetActive(lock_state)
		self.node_list["Image"]:SetActive(not lock_state)
		self.root_node.toggle.enabled = not lock_state and self.data.type >= 0
	else
		self.root_node.toggle.enabled = false
	end
end

function RuneFuLingCell:SetData(data)
	if not data or not next(data) then
		return
	end
	self.data = data

	local item_id = RuneData.Instance:GetRealId(data.quality, data.type)
	if item_id > 0 then
		self.node_list["Image"].image:LoadSprite(ResPath.GetItemIcon(item_id))
	end

	self:SetToggleEnabled(true)
end

function RuneFuLingCell:GetData()
	return self.data
end
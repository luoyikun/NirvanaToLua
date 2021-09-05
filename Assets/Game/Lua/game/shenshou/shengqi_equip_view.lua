ShengQiEquipView = ShengQiEquipView or BaseClass(BaseRender)

local SERIES = 3	--4个系列(暂时屏蔽粉色)

local TabColor = {
	"#F12FEA",
	"#F08229",
	"#F9463B",
	"#FF8AD1",
}

function ShengQiEquipView:__delete()
	if self.item_cell_list then
		for k,v in pairs(self.item_cell_list) do
			v:DeleteMe()
		end
		self.item_cell_list = {}
	end

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	for k,v in pairs(self.jichu_attr_list) do
		v:DeleteMe()
	end
	self.jichu_attr_list = {}

	for k,v in pairs(self.fuling_attr_list) do
		v:DeleteMe()
	end
	self.fuling_attr_list = {}

	if self.model_view then
		self.model_view:DeleteMe()
		self.model_view = nil
	end

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	self.fight_text = nil
	TitleData.Instance:ReleaseTitleEff(self.node_list["Img_chenghao"])
end

function ShengQiEquipView:LoadCallBack()
	self.list_index = 1
	self.last_item_index = nil
	self.item_index = 11
	self.item_list = {}
	self.jichu_attr_list = {}
	self.fuling_attr_list = {}
	self.goal_data = {}

	self.node_list["BtnSpirit"].button:AddClickListener(BindTool.Bind(self.SpiritShengQi, self))
	self.node_list["BtnStrength"].button:AddClickListener(BindTool.Bind(self.StrengthShengQi, self))
	self.node_list["BtnJiHuo"].button:AddClickListener(BindTool.Bind(self.ActivateShengQi, self))
	self.node_list["BtnKill"].button:AddClickListener(BindTool.Bind(self.KillShengQi, self))
	self.node_list["ImgMoney1"].button:AddClickListener(BindTool.Bind(self.OnClickMoney1, self))
	self.node_list["ImgMoney2"].button:AddClickListener(BindTool.Bind(self.OnClickMoney2, self))
	self.node_list["Img_chenghao"].button:AddClickListener(BindTool.Bind(self.OpenTipsTitleLimit, self, false))
	self.node_list["Node_big_goal"].button:AddClickListener(BindTool.Bind(self.OpenTipsTitleLimit, self, true, false))
	self:InitCell()
	self:DestoryGameObject()
	self:UpdateList()
	self:InitAttr()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["Item"])
	self.model_view = RoleModel.New()
	self.model_view:SetDisplay(self.node_list["Display"].ui3d_display, 0)
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtPower"])
end

function ShengQiEquipView:InitCell()
	self.left_bar_list = {}
	for i = 1, 7 do
		self.left_bar_list[i] = {}
		self.left_bar_list[i].select_btn = self.node_list["select_btn_" .. i]
		self.left_bar_list[i].list = self.node_list["list_" .. i]
		self.left_bar_list[i].btn_text = self.node_list["TxtBtn" .. i]
		self.left_bar_list[i].red_state = self.node_list["ImgRedPoint" .. i]
		self.left_bar_list[i].btn_text_high = self.node_list["TxtBtnHigh" .. i]
		self.node_list["select_btn_" .. i].toggle:AddClickListener(BindTool.Bind(self.OnClickSelect, self, i))
	end
end

function ShengQiEquipView:InitAttr()
	for i = 1, 4 do
		local jichu_attr = ShengQiJiChuAttr.New(self.node_list["JichuAttr" .. i])
		self.jichu_attr_list[i] = jichu_attr
		self.jichu_attr_list[i]:SetIndex(i)
	end

	for i = 1, 4 do
		local fuling_attr = ShengQiFuLingAttr.New(self.node_list["FuLingAttr" .. i])
		self.fuling_attr_list[i] = fuling_attr
		self.fuling_attr_list[i]:SetIndex(i)
		self.fuling_attr_list[i]:SetClickOpenFuling(BindTool.Bind(self.GetSpiritValue, self, i - 1))
	end
end

function ShengQiEquipView:OpenCallBack()
	local left_pos = self.node_list["NodeLeftMove"].transform.anchoredPosition
	local under_pos = self.node_list["NodeUnderMove"].transform.anchoredPosition

	UITween.MoveShowPanel(self.node_list["NodeLeftMove"], Vector3(left_pos.x - 200, left_pos.y, left_pos.z))
	UITween.MoveShowPanel(self.node_list["NodeUnderMove"], Vector3(under_pos.x, under_pos.y - 200, under_pos.z))
	UITween.AlpahShowPanel(self.node_list["NodeGoal"], true, MOVE_TIME , DG.Tweening.Ease.InExpo)
	UITween.AlpahShowPanel(self.node_list["NodeCenterMove"], true)
end

function ShengQiEquipView:DestoryGameObject()
	if nil == next(self.item_list) then
		return
	end
	self.is_load = false
	for k,v in pairs(self.item_list) do
		ResMgr:Destroy(v.gameObject)
	end
	self.item_list = {}
	self.item_cell_list = {}
end

function ShengQiEquipView:UpdateList()
	self.left_bar_list[self.list_index].select_btn.accordion_element.isOn = false
	self.left_bar_list[self.list_index].list:SetActive(false)
	self.item_list = {}
	self.item_cell_list = {}

	for i = 1, SERIES do
		self.left_bar_list[i].select_btn:SetActive(true)
		self.left_bar_list[i].btn_text.text.text = Language.ShenShou.ShengQiType[i]
		self.left_bar_list[i].btn_text_high.text.text = Language.ShenShou.ShengQiType[i]
		self:LoadCell(i, i - 1)
	end
end

function ShengQiEquipView:LoadCell(index, sub_type)
	local compose_item_list = ShenShouData.Instance:GetShengQiCfgBySeries(sub_type)

	local res_async_loader = AllocResAsyncLoader(self, "item_res_async_loader" .. index)
	res_async_loader:Load("uis/views/shenshouview_prefab", "ItemType", nil, function(prefab)
		if nil == prefab then
			return
		end
		for i = 1, #compose_item_list do
			local obj = ResMgr:Instantiate(prefab)
			local obj_transform = obj.transform
			obj_transform:SetParent(self.left_bar_list[index].list.transform, false)
			obj:GetComponent("Toggle").group = self.left_bar_list[index].list.toggle_group
			local item_cell = ShengQIComposeItem.New(obj)
			item_cell:SetIndex(i)
			item_cell:SetSeries(sub_type)
			item_cell:SetData(compose_item_list[i])
			item_cell:SetClickEvent(BindTool.Bind(self.ClickEquipCell, self, 10 * index + i))
			self.item_list[#self.item_list + 1] = obj_transform
			self.item_cell_list[10 * index + i] = item_cell
		end
		self:CheckIsSelect()
		if self.item_cell_list and self.item_cell_list[self.item_index] and self.item_cell_list[self.item_index].data then
			self.selectet_tree_item = self.item_cell_list[self.item_index].data
		end
		self:Flush()
	end)
end

function ShengQiEquipView:ClickEquipCell(index)
	if self.item_index == index then return end

	self.last_item_index = self.item_index
	self.item_index = index
	self.selectet_tree_item = self.item_cell_list[self.item_index].data
	self:FlushUI()
	self:SetSelectItem()
end

function ShengQiEquipView:CheckIsSelect()
	if self.left_bar_list[self.list_index].select_btn.accordion_element.isOn then --刷新
		self.left_bar_list[self.list_index].select_btn.accordion_element.isOn = false
		self.left_bar_list[self.list_index].select_btn.accordion_element.isOn = true
		return
	end
	self.left_bar_list[self.list_index].select_btn.accordion_element.isOn = true
	self:SetSelectItem()
end

function ShengQiEquipView:OnClickSelect(index)
	self.list_index = index
	self:SetSelectItem()
	for i = 1, 7 do
		self.node_list["BtnRightActive" .. i]:SetActive(false)
	end
	self.node_list["BtnRightActive" .. self.list_index]:SetActive(true) 
end

function ShengQiEquipView:SetSelectItem()
	self:OnFlushItem()
	if self.item_cell_list[self.item_index] then
		self.item_cell_list[self.item_index]:SetHighLight(true)
	end
	if self.item_cell_list[self.last_item_index] then
		self.item_cell_list[self.last_item_index]:SetHighLight(false)
	end
end

function ShengQiEquipView:OnFlushItem()
	if self.item_cell_list ~= nil then
		for k,v in pairs(self.item_cell_list) do
			v:SetHighLight(false)
		end
	end
end

function ShengQiEquipView:FlushSubNum()
	for k,v in pairs(self.item_cell_list) do
		v:SetNum(self:GetBtnRedState((k - 1) / 10))
	end
end

function ShengQiEquipView:OnFlush()
	self:FlshGoalContent()
	for i = 1, 7 do
		self.node_list["BtnRightActive" .. i]:SetActive(false)
	end
	if nil ~= self.list_index then 
		self.node_list["BtnRightActive" .. self.list_index]:SetActive(true)
	end
	if self.item_cell_list[self.item_index] then
		self.item_cell_list[self.item_index]:SetHighLight(true)
	end
	if self.item_cell_list[self.last_item_index] then
		self.item_cell_list[self.last_item_index]:SetHighLight(false)
	end
	self:FlushUI()

	for _, v in pairs(self.item_cell_list) do
		v:Flush()
	end
end

function ShengQiEquipView:FlushUI()
	if not next(self.item_cell_list) then return end
	local shengqi_cfg = self.item_cell_list[self.item_index]:GetData()
	local info = ShenShouData.Instance:GetShengQiEquipInfoByIndex(shengqi_cfg.index)
	if not info then return end
	local strength_cfg = ShenShouData.Instance:GetShengQiStrengthCfg()[shengqi_cfg.index][info.level]
	local spirit_cfg = ShenShouData.Instance:GetShengQiSpiritCfg()[shengqi_cfg.index + 1]
	local is_active_shengqi = ShenShouData.Instance:GetShengQiEquipInfoActivateByIndex(shengqi_cfg.index + 1)
	local last_info = ShenShouData.Instance:GetShengQiEquipInfoByIndex(shengqi_cfg.index - 1)
	if not strength_cfg or not spirit_cfg then return end

	self.spirit_stuff_id = spirit_cfg.spirit_stuff_id
	self.strength_stuff_id = strength_cfg.strength_stuff_id

	local level_txt = ToColorStr("Lv." .. info.level, TEXT_COLOR.GREEN)
	self.node_list["TxtTitle"].text.text = level_txt .. " " .. shengqi_cfg.name
	local count1 = ItemData.Instance:GetItemNumInBagById(self.spirit_stuff_id)
	self.node_list["TxtMoney1"].text.text = count1
	local count2 = ItemData.Instance:GetItemNumInBagById(self.strength_stuff_id)
	self.node_list["TxtMoney2"].text.text = count2
	local bundle, asset = ResPath.GetItemIcon(self.spirit_stuff_id)
	self.node_list["ImgMoney1"].image:LoadSprite(bundle, asset)
	bundle, asset = ResPath.GetItemIcon(self.strength_stuff_id)
	self.node_list["ImgMoney2"].image:LoadSprite(bundle, asset)

	local attr_cfg = CommonDataManager.GetAttributteByClass(strength_cfg)
	local attribute = CommonDataManager.GetOrderAttributte(attr_cfg)
	local attr_list = {}
	for k, v in pairs(attribute) do
		if v.value > 0 then
			local attr = {}
			attr[v.key] = v.value
			attr_list[#attr_list + 1] = attr
		end
	end
	
	for i = 1, 4 do
		self.jichu_attr_list[i]:SetActive(attr_list[i] ~= nil)
		self.jichu_attr_list[i]:SetData(attr_list[i], i)
	end
	self.node_list["JiHuo"]:SetActive(1 == is_active_shengqi)
	self.node_list["NotJiHuo"]:SetActive(0 == is_active_shengqi)

	local active_list = bit:d2b(info.spirit_flag)
	for i = 1, 4 do
		local data = {}
		data.spirit_value = info.spirit_value[i]
		data.per_spirit_value = info.per_spirit_value[i]
		data.is_active = active_list[33 - i]
		data.attr_type = spirit_cfg["attr_type_" .. i]
		data.is_active_shengqi = is_active_shengqi
		self.fuling_attr_list[i]:SetData(data)
	end

	local bundle, asset = ResPath.GetShengqiModel(shengqi_cfg.id)
	self.model_view:SetMainAsset(bundle, asset)
	self.model_view:ResetRotation()

	self.node_list["Item"]:SetActive(0 == is_active_shengqi and shengqi_cfg.series ~= 0)
	UI:SetGraphicGrey(self.node_list["Display"], 0 == is_active_shengqi)
	self.node_list["ImgFengYin"]:SetActive(0 == is_active_shengqi)
	-- self.node_list["NodePower"]:SetActive(0 ~= is_active_shengqi)
	if 0 == is_active_shengqi then
		local open_condition_cfg = ShenShouData.Instance:GetShengQiOpenCfg()
		if open_condition_cfg and shengqi_cfg.series ~= 0 then
			local id = open_condition_cfg[shengqi_cfg.index + 1].stuff_id
			if id ~= 0 then
				self.item_cell:SetData({item_id = id})
			end
			local count = ItemData.Instance:GetItemNumInBagById(id)
			self.node_list["RedBtnJiHuo"]:SetActive(count >= open_condition_cfg[shengqi_cfg.index + 1].stuff_num)
			self.node_list["TxtJiHuo"].text.text = Language.ShenShou.NeedToActivate
		elseif open_condition_cfg and 0 == shengqi_cfg.series then
			if last_info then
				self.node_list["RedBtnJiHuo"]:SetActive(last_info.level >= open_condition_cfg[shengqi_cfg.index + 1].open_level)
			end
			self.node_list["TxtJiHuo"].text.text = string.format(Language.ShenShou.NeedToActivate2, open_condition_cfg[shengqi_cfg.index + 1].open_level)
		end
	else
		local next_strength_cfg = ShenShouData.Instance:GetShengQiStrengthCfg()[shengqi_cfg.index][info.level + 1] or nil
		if not next_strength_cfg then
			self.node_list["TxtBtnStrength"].text.text = Language.ShenShou.YiManJi
			UI:SetButtonEnabled(self.node_list["BtnStrength"], false)
		else
			self.node_list["TxtBtnStrength"].text.text = Language.ShenShou.Strength
			UI:SetButtonEnabled(self.node_list["BtnStrength"], true)
		end

		local other_cfg = ShenShouData.Instance:GetShengQiOtherCfg()
		local is_max_fuling = true
		if other_cfg then
			for i = 1, 4 do
				if info.per_spirit_value[i] > 0 and info.per_spirit_value[i] < other_cfg[1].spirit_max * 100 then
					is_max_fuling = false
					break
				end
			end
		end
		if is_max_fuling then
			self.node_list["TxtBtnSpirit"].text.text = Language.ShenShou.YiManJi
			UI:SetButtonEnabled(self.node_list["BtnSpirit"], false)
		else
			self.node_list["TxtBtnSpirit"].text.text = Language.ShenShou.Spirit
			UI:SetButtonEnabled(self.node_list["BtnSpirit"], true)
		end

		if spirit_cfg.spirit_stuff_num <= count1 and not is_max_fuling then
			self.node_list["RedBtnSpirit"]:SetActive(true)
		else
			self.node_list["RedBtnSpirit"]:SetActive(false)
		end
		if strength_cfg.strength_stuff_num <= count2 and next_strength_cfg then
			self.node_list["RedBtnStrength"]:SetActive(true)
		else
			self.node_list["RedBtnStrength"]:SetActive(false)
		end
	end

	local fuling_active_attr = CommonStruct.Attribute()
	local value = 1
	for i = 1, 4 do
		if spirit_cfg["attr_type_" .. i] == 22 then
			value = value + info.per_spirit_value[i] / 10000		--万分比
		else
			if 1 == active_list[33 - i] then
				fuling_active_attr[ShengQiAttrStruct[spirit_cfg["attr_type_" .. i]]] = info.spirit_value[i]
			end
		end
	end

	local jichu_active_attr = CommonStruct.Attribute()
	jichu_active_attr = CommonDataManager.MulAttribute(CommonDataManager.GetAttributteByClass(strength_cfg), value)
	local attr = CommonDataManager.AddAttributeAttr(fuling_active_attr, jichu_active_attr)
	local attr_no_parcent = CommonDataManager.GetAttributteNoParcent(attr)
	local power = CommonDataManager.GetCapability(attr_no_parcent)

	-- 策划要求，圣器未激活时要算20%的基础属性加成
	if is_active_shengqi == 1 then
		self.fight_text.text.text = power
	else
		self.fight_text.text.text = (info.spirit_value[1] / 10000 + 1) * power
	end

	for i = 0, 3 do
		local num = ShenShouData.Instance:GetShengQiRemindBySeries(i)
		self.node_list["ImgRedPoint" .. i + 1]:SetActive(num > 0)
	end
	self.node_list["BtnKill"]:SetActive(1 ~= self.list_index and 0 ~= is_active_shengqi)
end

--激活
function ShengQiEquipView:ActivateShengQi()
	local shengqi_cfg = self.item_cell_list[self.item_index]:GetData()
	if 0 == shengqi_cfg.series then
		local last_info = ShenShouData.Instance:GetShengQiEquipInfoByIndex(shengqi_cfg.index - 1)
		local open_condition_cfg = ShenShouData.Instance:GetShengQiOpenCfg()
		if not last_info or not open_condition_cfg then return end

		local open_level = open_condition_cfg[shengqi_cfg.index + 1].open_level
		if last_info.level < open_level then
			local str = string.format(Language.ShenShou.NeedToActivate2, open_level)
			TipsCtrl.Instance:ShowSystemMsg(str)
			return
		end
	end
	ShenShouCtrl.Instance:SendShengQiEquipReq(ShenShouData.OpenType.OpenTypeActive, self.selectet_tree_item.id)
end

--强化,打开强化界面
function ShengQiEquipView:StrengthShengQi()
	ShenShouCtrl.Instance:OpenShengQiequipStrengthView(self.selectet_tree_item)
end

--附灵，打开附灵界面
function ShengQiEquipView:SpiritShengQi()
	ShenShouCtrl.Instance:OpenShengQiequipSpiritView(self.selectet_tree_item)
end

function ShengQiEquipView:KillShengQi()
	ViewManager.Instance:Open(ViewName.ShengQiKillView)
end

--开启附灵属性
function ShengQiEquipView:GetSpiritValue(index)
	local func = function()
		ShenShouCtrl.Instance:SendShengQiEquipReq(ShenShouData.OpenType.OpenTypeOpenSpirit, self.selectet_tree_item.id, index)
	end
	local other_cfg = ShenShouData.Instance:GetShengQiOtherCfg()
	local str = string.format(Language.ShenShou.GetValueConsume, other_cfg[1].open_gold)
	TipsCtrl.Instance:ShowCommonAutoView("shengqi_clear", str, func, nil, nil, nil, nil, nil, nil, false)
end

function ShengQiEquipView:OnClickMoney1()
	local data = {item_id = self.spirit_stuff_id}
	TipsCtrl.Instance:OpenItem(data)
end

function ShengQiEquipView:OnClickMoney2()
	local data = {item_id = self.strength_stuff_id}
	TipsCtrl.Instance:OpenItem(data)
end

function ShengQiEquipView:FlshGoalContent()
	self.goal_info = ShenShouData.Instance:GetShengQiGoalInfo()
	if self.goal_info then
		local sever_time = TimeCtrl.Instance:GetServerTime()
		local diff_time = self.goal_info.open_system_timestamp - sever_time
		if self.goal_info.fetch_flag[0] == 0 then
			local is_show_little_goal = RuneData.Instance:IsShowJGoalRewardIcon(0, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENGQI)
			if is_show_little_goal then
				self.node_list["Node_little_goal"]:SetActive(true)
				local goal_cfg_info = ShenShouData.Instance:GetItemGoalInfo(0, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENGQI)
				if goal_cfg_info then
					local title_id = goal_cfg_info.reward_show
					local item_id = goal_cfg_info.reward_item[0].item_id
					self.goal_data.item_id = item_id
					self.goal_data.cost = goal_cfg_info.cost
					self.goal_data.can_fetch = self.goal_info.active_flag[0] == 1

					diff_time = diff_time + goal_cfg_info.free_time_since_open * 3600
					local cfg = TitleData.Instance:GetTitleCfg(title_id)
					if nil == cfg then
						return
					end
					local zhanli = CommonDataManager.GetCapabilityCalculation(cfg)
					local bundle, asset = ResPath.GetTitleIcon(title_id)
					self.node_list["Img_chenghao"].image:LoadSprite(bundle, asset, function() 
						TitleData.Instance:LoadTitleEff(self.node_list["Img_chenghao"], title_id, true)
						UI:SetGraphicGrey(self.node_list["Img_chenghao"], self.goal_info.active_flag[0] == 0)
						end)
					self.node_list["Txt_fightpower"].text.text = Language.Goal.PowerUp .. zhanli
					self.node_list["NodeGoal"].animator:SetBool("IsShake" , self.goal_data.can_fetch)
					self.node_list["little_goal_redpoint"]:SetActive(self.goal_data.can_fetch)
				end
			else
				self.node_list["Txt_lefttime"]:SetActive(false)
				self.node_list["Node_little_goal"]:SetActive(false)
			end
		else
			local is_show_big_goal = RuneData.Instance:IsShowJGoalRewardIcon(1, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENGQI)
			if is_show_big_goal then
				self.node_list["Node_little_goal"]:SetActive(false)
				self.node_list["Node_big_goal"]:SetActive(true)
				self.node_list["Txt_shuxing"]:SetActive(true)
				UI:SetGraphicGrey(self.node_list["Img_touxiang_frame"], not(self.goal_info.active_special_attr_flag == 1 and self.goal_info.fetch_flag[1] == 1))
				self.node_list["Effect"]:SetActive(self.goal_info.fetch_flag[1] == 0)
				local goal_cfg_info = ShenShouData.Instance:GetItemGoalInfo(1, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENGQI)
				if goal_cfg_info then
					local attr_percent = ShenShouData.Instance:GetGoalAttr(ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENGQI)
					local item_id = goal_cfg_info.reward_item[0].item_id
					local item_cfg = ItemData.Instance:GetItemConfig(item_id)
					if item_cfg == nil then
						return
					end
					local item_bundle, item_asset = ResPath.GetItemIcon(item_cfg.icon_id)
					self.node_list["Img_touxiang"].image:LoadSprite(item_bundle, item_asset)
					self.goal_data.item_id = item_id
					self.goal_data.cost = goal_cfg_info.cost
					self.goal_data.can_fetch = self.goal_info.active_flag[1] == 1
					diff_time = diff_time + goal_cfg_info.free_time_since_open * 3600
					self.node_list["Txt_shuxing"].text.text = string.format(Language.Goal.AttrAdd, attr_percent/100) .. "%"
					self.node_list["NodeGoal"].animator:SetBool("IsShake" , self.goal_data.can_fetch and self.goal_info.fetch_flag[1] ~= 1)
					self.node_list["big_goal_redpoint"]:SetActive(self.goal_data.can_fetch and self.goal_info.fetch_flag[1] ~= 1)
				end
			else
				self.node_list["Node_little_goal"]:SetActive(false)
				self.node_list["Node_big_goal"]:SetActive(false)
				self.node_list["Txt_shuxing"]:SetActive(false)
			end
		end

		self.goal_data.left_time = diff_time
		if self.count_down == nil then
			function diff_time_func(elapse_time, total_time)
				local left_time = math.floor(diff_time - elapse_time + 0.5)
				if left_time <= 0 then
					if self.count_down ~= nil then
						self.node_list["Txt_lefttime"]:SetActive(false)
						CountDown.Instance:RemoveCountDown(self.count_down)
						self.count_down = nil
					end
					return
				end
				if left_time > 0 then
					self.node_list["Txt_lefttime"]:SetActive(true)
					self.node_list["Txt_lefttime"].text.text = Language.Goal.FreeTime .. TimeUtil.FormatSecond(left_time, 10)
				else
					self.node_list["Txt_lefttime"]:SetActive(false)
				end

				if self.goal_info.fetch_flag[0] == 1 and self.goal_info.fetch_flag[1] == 1 then
					self.node_list["Txt_lefttime"]:SetActive(false)
				end
			end

			diff_time_func(0, diff_time)
			self.count_down = CountDown.Instance:AddCountDown(
				diff_time, 0.5, diff_time_func)
		end
	end
end

function ShengQiEquipView:OpenTipsTitleLimit(is_model, is_other_item)
	local fun = function(click_type)
		RuneCtrl.Instance:SendBigSmallGoalOper(ROLE_BIG_SMALL_GOAL_OPERA_TYPE.ROLE_BIG_SMALL_GOAL_OPERA_FETCH, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENGQI, click_type)
	end

	self.goal_data.from_panel = ""
	self.goal_data.call_back = fun
	TipsCtrl.Instance:ShowGoalTimeLimitTitleView(self.goal_data, is_model, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENGQI, is_other_item)
end

-------------------------------------------------------------------------------------------
ShengQIComposeItem = ShengQIComposeItem or BaseClass(BaseCell)

function ShengQIComposeItem:__init()
	self.model_view = RoleModel.New()
	self.model_view:SetDisplay(self.node_list["Display"].ui3d_display, 0)
	self.model_id = 0
end

function ShengQIComposeItem:__delete()
	if self.model_view then
		self.model_view:DeleteMe()
	end
	self.model_id = nil
end

function ShengQIComposeItem:SetIndex(index)
	self.index = index
end

function ShengQIComposeItem:OnFlush()
	if not self.data then return end
	local open_condition_cfg = ShenShouData.Instance:GetShengQiOpenCfg()
	if not open_condition_cfg then return end

	local name_txt = "<color=%s>%s</color>"
	self.node_list["Name"].text.text = string.format(name_txt, TabColor[self.series + 1], self.data.name)
	local is_active_shengqi = ShenShouData.Instance:GetShengQiEquipInfoActivateByIndex(self.data.index + 1)
	if 1 == is_active_shengqi then
		local info = ShenShouData.Instance:GetShengQiEquipInfoByIndex(self.data.index)
		local spirit_cfg = ShenShouData.Instance:GetShengQiSpiritCfg()[self.data.index + 1]
		if not info or not spirit_cfg then return end
		local strength_cfg = ShenShouData.Instance:GetShengQiStrengthCfg()[self.data.index][info.level]
	end
	local num = ShenShouData.Instance:GetShengQiRemindByIndex(self.data.index)
	self.node_list["RedPoint"]:SetActive(num > 0)

	if self.model_id ~= self.data.id then
		local bundle, asset = ResPath.GetShengqiModel(self.data.id)
		self.model_view:SetMainAsset(bundle, asset)
		self.model_id = self.data.id
	end

	local is_show, _, cfg = DisCountData.Instance:IsOpenYiZheAllBySystemId(Sysetem_Id_Jump.Sheng_Qi)

	self.node_list["XianShiImg"]:SetActive(false)
	if is_show and cfg and cfg.system_index then
		for k, v in pairs(cfg.system_index) do
			local index_list = Split(v, "|")
			for k, v in pairs(index_list) do
				if tonumber(v) == self.data.index then
					self.node_list["XianShiImg"]:SetActive(true)
					break
				end
			end
		end
	end
end

function ShengQIComposeItem:SetHighLight(value)
	if value then
		self.root_node.toggle.isOn = true
	else
		self.root_node.toggle.isOn = false
	end
end

function ShengQIComposeItem:SetClickEvent(click_event)
	self.root_node.toggle:AddClickListener(click_event)
end

function ShengQIComposeItem:SetSeries(series)
	self.series = series
end

------------------------------------------------------------------------------------------------------------------
ShengQiJiChuAttr = ShengQiJiChuAttr or BaseClass(BaseCell)

function ShengQiJiChuAttr:SetData(data, index)
	self.data = data
	self.index = index
	self:Flush()
end

function ShengQiJiChuAttr:OnFlush()
	if self.data and self.index then
		for k, v in pairs(self.data) do
			local value = v
			if self.index > 3 then --三个基础属性
				value = (v / 100) .. "%"
			end
			self.node_list["AttrName"].text.text = CommonDataManager.GetAttrName(k) .. "："
			self.node_list["AttrCount"].text.text = value
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------
ShengQiFuLingAttr = ShengQiFuLingAttr or BaseClass(BaseCell)
function ShengQiFuLingAttr:OnFlush()
	local color = "<color=%s>%s</color>"
	local value = self.data.spirit_value
	if self.data.attr_type <= 22 and self.data.attr_type >= 12 then
		value = (self.data.spirit_value / 100) .. "%"
	end		
	local txt_fuling_attr = ToColorStr(value, COLOR.WHITE)
	if 0 == self.data.is_active_shengqi then
		self.node_list["TxtPercentage"].text.text = Language.ShenShou.ShengQiNotActive
		self.node_list["Button"]:SetActive(false)
		self.node_list["TxtFuLingAttr"].text.text = Language.ShenShou.SHENGQI_FULING_ATTR[self.data.attr_type] .. txt_fuling_attr
		return
	end

	self.node_list["TxtFuLingAttr"].text.text = Language.ShenShou.SHENGQI_FULING_ATTR[self.data.attr_type] .. txt_fuling_attr

	if self.data.is_active == 1 then
		local per_spirit_value = self.data.per_spirit_value
		local next_value = "(" .. per_spirit_value / 100 .. "%)"
		if per_spirit_value < 2500 then
			next_value = string.format(color, ShenqiData.AttrColor.WHITE, next_value)
		elseif per_spirit_value < 5000 then
			next_value = string.format(color, ShenqiData.AttrColor.Blue, next_value)
		elseif per_spirit_value < 7500 then
			next_value = string.format(color, ShenqiData.AttrColor.PURPLE, next_value)
		elseif per_spirit_value < 10000 then
			next_value = string.format(color, ShenqiData.AttrColor.ORANGE, next_value)
		elseif per_spirit_value >= 10000 then
			next_value = string.format(color, ShenqiData.AttrColor.RED, next_value)
		end
		self.node_list["TxtPercentage"].text.text = next_value
		self.node_list["Button"]:SetActive(false)
	else
		self.node_list["Button"]:SetActive(true)
	end
end

function ShengQiFuLingAttr:SetClickOpenFuling(click_event)
	self.node_list["Button"].button:AddClickListener(BindTool.Bind(click_event, self, self.index))
end
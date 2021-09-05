ForgeUpStarView = ForgeUpStarView or BaseClass(BaseRender)

function ForgeUpStarView:__init()
	self.node_list["ButtonFunc"].button:AddClickListener(BindTool.Bind(self.OpenAtrrTips, self))
	self.node_list["UpStarBtn"].button:AddClickListener(BindTool.Bind(self.ClickStarUp, self))
	self.node_list["BtnStartUpAuto"].button:AddClickListener(BindTool.Bind(self.OnClickAuto, self))
	self.node_list["ButtonHelp"].button:AddClickListener(BindTool.Bind(self.ClickHelp, self))
	self.node_list["MoJingItem"].button:AddClickListener(BindTool.Bind(self.OnClickMoJingItem, self))


	self.equip_item_list = {}
	for i = 0, 9 do
		local item_cell = UpStarEquipCell.New(self.node_list["EquipItem" .. (i + 1)])
		item_cell:SetIndex(i)
		item_cell:SetToggleGroup(self.node_list["EquipListGroup"].toggle_group)
		item_cell:SetClickCallBack(BindTool.Bind(self.ClcikEquipItemCell, self))
		self.equip_item_list[i] = item_cell
	end

	self.attr_list = {}
	local count = 1
	local child_number = self.node_list["AttrGroup"].transform.childCount
	for i = 0, child_number - 1 do
		local obj = self.node_list["AttrGroup"].transform:GetChild(i).gameObject
		if string.find(obj.name, "Attr") ~= nil then
			local variable_table = U3DNodeList(obj:GetComponent(typeof(UINameTable)))
			local item_tab = {}
			item_tab.obj = obj
			item_tab["Attr"] = variable_table["Attr"]
			item_tab["Arrow"] = variable_table["Arrow"]
			item_tab["AttrDiff"]= variable_table["AttrDiff"]
			self.attr_list[count] = item_tab
			count = count + 1
		end
	end

	self.equip_cell = ItemCell.New()
	self.equip_cell:SetInstanceParent(self.node_list["UpEquipItemCell"])
	self.equip_cell:SetFromView(TipsFormDef.FROM_BAG_EQUIP)

	self.progress = ProgressBar.New(self.node_list["ProgressBG"])

	self.mojing_change_callback = BindTool.Bind1(self.MoJingChange, self)
	ExchangeCtrl.Instance:NotifyWhenScoreChange(self.mojing_change_callback)

	self:FlushLeftEquipPanel()
	
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["PowerTxt"])
	self.total_fight_text = CommonDataManager.FightPower(self, self.node_list["FightPowerLabel"])
end

function ForgeUpStarView:__delete()
	for k, v in pairs(self.equip_item_list) do
		v:DeleteMe()
	end
	self.equip_item_list = {}

	if self.progress then
		self.progress:DeleteMe()
		self.progress = nil
	end

	if self.equip_cell then
		self.equip_cell:DeleteMe()
		self.equip_cell = nil
	end

	if self.mojing_change_callback then
		ExchangeCtrl.Instance:UnNotifyWhenScoreChange(self.mojing_change_callback)
		self.mojing_change_callback = nil
	end

	self.attr_list = {}
	self.is_max_level = nil
	self.select_index = nil
	self.fight_text = nil
	self.total_fight_text = nil
end

function ForgeUpStarView:GetUpStarBtn()
	return self.node_list["UpStarBtn"], BindTool.Bind(self.ClickStarUp, self)
end

-- 魔晶监听变化
function ForgeUpStarView:MoJingChange(equip_index)
	local mojing = tonumber(ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.MOJING))
	if mojing >= 100000 then
		mojing = math.floor(mojing / 10000) .. Language.Common.Wan
	end
	self.node_list["MoJingText"].text.text = mojing
end

function ForgeUpStarView:ClcikEquipItemCell(equip_index)
	self.click_equip = true
	self.select_index = equip_index
	self:Flush()
end

function ForgeUpStarView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "ui_tween" then
			local ui_cfg = ForgeData.Instance:GetUITweenCfg(TabIndex.forge_up_star)
			UITween.MoveShowPanel(self.node_list["LeftPanel"] , ui_cfg["LeftPanel"], ui_cfg["MOVE_TIME"])
			UITween.MoveShowPanel(self.node_list["RightPanel"] , ui_cfg["RightPanel"], ui_cfg["MOVE_TIME"])
		end
	end

	if self.select_index == nil then return end
	self.cell_data = ForgeData.Instance:GetZhuanzhiEquip(self.select_index)
	if nil == self.cell_data or self.cell_data.item_id <= 0 then 
		return 
	end

	local data = self.cell_data
	local star_level = ForgeData.Instance:GetUpStarLevelByIndex(self.cell_data.index) or 0

	self.equip_cell:SetData(self.cell_data)
	self.equip_cell:ShowStrengthLable(false)
	self.equip_cell:ShowStarLevel(true)
	self.equip_cell:SetStarLevel("+" .. star_level)
	
	local curr_cfg = ForgeData.Instance:GetUpStarSingleCfg(data.index, star_level)
	self.next_cfg = ForgeData.Instance:GetUpStarSingleCfg(data.index, star_level + 1)
	if nil == self.next_cfg then
		local max_level = ForgeData.Instance:GetMaxUpStarLevel(data.index)
		if max_level and max_level == star_level then
			self.is_max_level = true
		else
			return
		end
	else
		self.is_max_level = false
	end

	if self.is_max_level then
		self.node_list["StartUpText"].text.text = Language.Forge.FullLevel
		self.node_list["StarLevleText"].text.text = Language.Forge.FullLevel

		self.progress:SetValue(1)
		self.node_list["ProgressBGText"].text.text = ""
		self.node_list["MaxText"]:SetActive(true)
		self.node_list["BtnStartUpAuto"]:SetActive(false)
		self.node_list["MoJing"]:SetActive(false)
		UI:SetButtonEnabled(self.node_list["UpStarBtn"], false)
	else
		self.node_list["StartUpText"].text.text = Language.Forge.UpStar
		self.node_list["StarLevleText"].text.text = star_level

		self:FlushProgress(self.next_cfg)
		self.node_list["MaxText"]:SetActive(false)
		self.node_list["BtnStartUpAuto"]:SetActive(true)
		self.node_list["MoJing"]:SetActive(true)
		UI:SetButtonEnabled(self.node_list["UpStarBtn"], not self.is_auto_upstar)
	end

	-- 属性
	local attr, fight_power = self:GetAttrTabAndFight(curr_cfg, self.next_cfg)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = fight_power
	end
	for k, v in pairs(self.attr_list) do
		if attr[k] then
			v.obj:SetActive(true)
			v["Attr"].text.text = attr[k].name .. " : " .. ToColorStr(attr[k].value, TEXT_COLOR.WHITE) 
			if attr[k].diff then
				v["AttrDiff"].text.text = attr[k].diff
				v["Arrow"]:SetActive(true)
			else
				v["AttrDiff"].text.text = ""
				v["Arrow"]:SetActive(false)
			end
		else
			v.obj:SetActive(false)
		end
	end

	if self.is_auto_upstar then
		self.equip_item_list[self.auto_index]:SetUpStarEffect()
	else
		if self.equip_index_cache and self.equip_index_cache == self.select_index then
			if self.equip_star_cache < star_level then
				self.equip_index_cache = self.select_index
				self.equip_star_cache = star_level
				self.equip_item_list[self.select_index]:SetUpStarEffect()
			end
		else
			self.equip_index_cache = self.select_index
			self.equip_star_cache = star_level
		end
	end

	local all_equip = ForgeData.Instance:GetZhuanzhiEquipAll()
	local total_power = 0
	for k, v in pairs(all_equip) do
		if v.item_id and v.item_id > 0 then
			local star_level = ForgeData.Instance:GetUpStarLevelByIndex(v.index) or 0
			local curr_cfg = ForgeData.Instance:GetUpStarSingleCfg(v.index, star_level)
			total_power = total_power + CommonDataManager.GetCapabilityCalculation(curr_cfg)
		end
	end

	if self.total_fight_text and self.total_fight_text.text then
		self.total_fight_text.text.text = total_power
	end

	self:FlushStarList(star_level)
	self:MoJingChange()
	self:FlushLeftEquipPanel()
end

function ForgeUpStarView:FlushLeftEquipPanel()
	if self.click_equip then
		self.click_equip = nil
		return
	end
	local equip_data = ForgeData.Instance:GetZhuanzhiEquipAll()
	for i = 0, 9 do
		self.equip_item_list[i]:SetData(equip_data[i])
	end
end

--刷新进度条
function ForgeUpStarView:FlushProgress()
	local now_exp = ForgeData.Instance:GetUpStarExpByIndex(self.cell_data.index) or 0
	local mojing = ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.MOJING)
	if self.next_cfg then
		local max_pro = self.next_cfg.need_mojing
		local need_exp = max_pro - now_exp
		local add_pro = (mojing >= need_exp) and need_exp or mojing
		self.node_list["ProgressBGText"].text.text = string.format(Language.Forge.UpStarProgreeBgText, now_exp, add_pro, max_pro)
		if not self.old_star_level or (self.old_cell_index and self.old_cell_index ~= self.cell_data.index) then
			self.old_cell_index = self.cell_data.index
			self.old_star_level = ForgeData.Instance:GetUpStarLevelByIndex(self.cell_data.index) or 0
			self.progress:SetValue(now_exp / max_pro)
		else
			local new_star_level = ForgeData.Instance:GetUpStarLevelByIndex(self.cell_data.index) or 0
			if self.old_star_level < new_star_level then
				if self.pro_quest ~= nil then
					self.node_list["ProgressBG"].slider.value = 0
					GlobalTimerQuest:CancelQuest(self.pro_quest)
					self.pro_quest = nil
				end
				local pro_num = now_exp
				self.pro_quest = GlobalTimerQuest:AddRunQuest(function ()
					self.node_list["ProgressBG"].slider.value = pro_num
					pro_num = pro_num + 0.1
					if self.node_list["ProgressBG"].slider.value >= 1 then
						if self.pro_quest ~= nil then
							GlobalTimerQuest:CancelQuest(self.pro_quest)
							self.pro_quest = nil
						end
						self.progress:SetValue(now_exp / max_pro)
					end
				end, 0)
				-- self.progress:SetValue(1)
				self.old_star_level = new_star_level
			else
				self.progress:SetValue(now_exp / max_pro)
			end
		end
	else
		self.progress:SetValue(0)
	end
end

--刷新星星
function ForgeUpStarView:FlushStarList(star_level)
	local star_type = math.floor(star_level / 10)
	local star_count = star_level % 10
	star_type =  (star_type >= 10) and math.floor(star_type % 10) or star_type
	star_type = star_type % 5

	local is_no_star = (star_level < 10) and true or false
	for i = 1, 10 do
		local name = ""
		if i <= star_count then
			name = ("icon_star_" .. star_type + 1)
		else
			if is_no_star then
				name = "icon_star_0"
			else
				local down_star_type = (star_type == 0) and 5 or (star_type)
				name = ("icon_star_" .. down_star_type)
			end
		end
		local bubble, asset = ResPath.GetImages(name)
		self.node_list["Star" .. i].image:LoadSprite(bubble, asset)
	end
end

-- 属性和战斗力
function ForgeUpStarView:GetAttrTabAndFight(curr_equip_cfg, next_equip_cfg)
	local curr_attr_tab = curr_equip_cfg and CommonDataManager.GetAttributteByClass(curr_equip_cfg) or CommonStruct.Attribute()
	local next_attr_tab = {}
	local diff_attr_tab = {}
	if next_equip_cfg and next(next_equip_cfg) then
		next_attr_tab = CommonDataManager.GetAttributteByClass(next_equip_cfg)
		diff_attr_tab = CommonDataManager.LerpAttributeAttr(curr_attr_tab, next_attr_tab)
	end
	local sort_curr_attr= CommonDataManager.GetOrderAttributte(curr_attr_tab)
	local sort_next_attr= CommonDataManager.GetOrderAttributte(next_attr_tab)
	local sort_diff_attr = CommonDataManager.GetOrderAttributte(diff_attr_tab)

	local fight_power = CommonDataManager.GetCapabilityCalculation(curr_attr_tab)
	local total_attr = {}
	local count = 1
	for k, v in pairs(sort_curr_attr) do
		if v.value > 0 or (sort_next_attr[k] and sort_next_attr[k].value and sort_next_attr[k].value > 0) then
			total_attr[count] = {}
			total_attr[count].name = CommonDataManager.GetAttrName(v.key)
			total_attr[count].value = v.value
			total_attr[count].diff = sort_diff_attr[k].value or nil 
			count = count + 1
		end
	end
	return total_attr, fight_power
end

--打开属性加成
function ForgeUpStarView:OpenAtrrTips()
	local star_level, now_cfg, next_cfg = ForgeData.Instance:GetTotleStarInfo()
	TipsCtrl.Instance:ShowTotalAttrView(Language.Forge.ForgeStarSuitAtt, star_level, now_cfg, next_cfg)
end

-- 升星
function ForgeUpStarView:ClickStarUp()
	if nil == self.cell_data then 
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.NoSelectEquip)
		return
	end

	if self.is_max_level then
		SysMsgCtrl.Instance:ErrorRemind(Language.Forge.StarMaxLevel)
		return
	end

	if self.next_cfg then
		local mojing = ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.MOJING)
		if mojing <= 0 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Player.NoMojin)
			TipsCtrl.Instance:ShowItemGetWayView(ResPath.CurrencyToIconId["shengwang"])
		else
			ForgeCtrl.Instance:SendCSZhuanzhiEquipOpe(ZHUANZHI_EQUIP_OPERATE_TYPE.ZHUANZHI_EQUIP_OPERATE_TYPE_UP_STAR, self.cell_data.index)
		end
	end
end

--一键升星
function ForgeUpStarView:OnClickAuto()
	if nil == self.cell_data then 
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.NoSelectEquip)
		return
	end
	
	if self.is_auto_upstar then
		self:StopAutoQuest()
		return
	end

	self.auto_index = ForgeData.Instance:GetMinStarIndex()
	if self.auto_index == -2 then
		TipsCtrl.Instance:ShowItemGetWayView(ResPath.CurrencyToIconId["shengwang"])
		return
	elseif self.auto_index == -1 then
		return
	end
	self.is_auto_upstar = true
	self:FlushBtnAutoState(true)

	if self.auto_upstar_quest == nil then
		self.auto_upstar_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.AutoQuest, self), 0.2)
	end
end

function ForgeUpStarView:AutoQuest()
	self.auto_index = ForgeData.Instance:GetMinStarIndex()
	if self.auto_index ~= -1 and  self.auto_index ~= -2 then
		ForgeCtrl.Instance:SendCSZhuanzhiEquipOpe(ZHUANZHI_EQUIP_OPERATE_TYPE.ZHUANZHI_EQUIP_OPERATE_TYPE_UP_STAR, self.auto_index)
	else
		self:StopAutoQuest()
	end
end

function ForgeUpStarView:StopAutoQuest()
	self.is_auto_upstar = false
	self:FlushBtnAutoState(false)
	if self.auto_upstar_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.auto_upstar_quest)
		self.auto_upstar_quest = nil
	end
end

function ForgeUpStarView:FlushBtnAutoState(state)
	UI:SetButtonEnabled(self.node_list["UpStarBtn"], not state)
	UI:SetGraphicGrey(self.node_list["UpStarBtn"], state)
	UI:SetGraphicGrey(self.node_list["StartUpText"], state)
	self.node_list["BtnAutoText"].text.text = state and Language.Forge.StopStar or Language.Forge.OneKeyUpStar
end

function ForgeUpStarView:ClickHelp()
	local tips_id = 259
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function ForgeUpStarView:OnClickMoJingItem()
	local item_data = {item_id = 90002}
	TipsCtrl.Instance:OpenItem(item_data)	
end


-------------------------------------
------ 装备格子 UpStarEquipCell
UpStarEquipCell = UpStarEquipCell or BaseClass(BaseCell)
function UpStarEquipCell:__init(instance, is_next)
	self.equip_cell = ItemCell.New()
	self.equip_cell:SetInstanceParent(self.node_list["EquipItem"])

	self.equip_cell:ListenClick(BindTool.Bind(self.ClickItem, self))
end

function UpStarEquipCell:__delete()
	if self.equip_cell then
		self.equip_cell:DeleteMe()
		self.equip_cell = nil
	end
end

function UpStarEquipCell:ClickItem()
	if nil == self.data then return end

	if self.click_callback then
		self.click_callback(self.index)
	end
end

function UpStarEquipCell:OnFlush()
	if nil == self.data or self.data.item_id <= 0 then 
		self:SetDefaultIcon()
		return 
	end

	self.equip_cell:SetData(self.data)
	self.equip_cell:ShowStarLevel(true)
	self.equip_cell:SetIconGrayScale(false)
	self.equip_cell:ShowQuality(true)

	local star_level = ForgeData.Instance:GetUpStarLevelByIndex(self.data.index) or 0
	self.equip_cell:ShowStrengthLable(false)
	self.equip_cell:SetStarLevel("+" .. star_level)

	self.node_list["BtnImprove"]:SetActive(ForgeData.Instance:CheckUpStarIsCanImprove(self.data) == 0)
end

function UpStarEquipCell:SetDefaultIcon()
	local item_id = EquipData.Instance:GetZhuanzhiDefaultIcon(self.index)
	self.equip_cell:SetData({item_id = item_id})
	self.equip_cell:ShowQuality(false)
	self.equip_cell:ShowHighLight(false)
	self.equip_cell:SetIconGrayScale(true)
	self.equip_cell:ShowEquipGrade(false)
	self.equip_cell:ListenClick(BindTool.Bind(function () end))
end

function UpStarEquipCell:SetToggleGroup(toggle_group)
	self.equip_cell:SetToggleGroup(toggle_group)
end

function UpStarEquipCell:SetUpStarEffect()
	local async_loader = AllocAsyncLoader(self, "effect_" .. self.index)
	local bundle_name, asset_name = ResPath.GetMiscEffect("Effect_baodian")
	async_loader:Load(bundle_name, asset_name, 
		function (obj)
			if not IsNil(obj) then
				local transform = obj.transform
				transform:SetParent(self.root_node.transform, false)

				GlobalTimerQuest:AddDelayTimer(function()
					ResMgr:Destroy(obj)
					ViewManager.Instance:Close(ViewName.FlowerReMindView)
				end, 1)
			end
		end)
end

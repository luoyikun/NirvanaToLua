MarriageRingCountView = MarriageRingCountView or BaseClass(BaseRender)

local EFFECT_CD = 1

function MarriageRingCountView:__init()
	self.effect_cd = 0
	self.now_ring_item_id = 0
	self.now_ring_level = 0

	self.ring_cell = ItemCell.New()
	self.ring_cell:SetInstanceParent(self.node_list["RingCell"])
	self.ring_cell:SetData(nil)
	self.ring_cell:SetInteractable(false)

	self.ring_item_cell = ItemCellReward.New()
	self.ring_item_cell:SetInstanceParent(self.node_list["RingItemCell"])

	self.node_list["TxtSelfUp"].text.text = Language.Common.AutoUpgrade

	self.node_list["BtnUp"].button:AddClickListener(BindTool.Bind(self.UpgradeRingClick, self))
	self.node_list["BtnSelfUp"].button:AddClickListener(BindTool.Bind(self.AutoUpgradeRingClick, self))
	self.node_list["BtnMail"].button:AddClickListener(BindTool.Bind(self.OpenMail, self))
	self.node_list["BtnMail2"].button:AddClickListener(BindTool.Bind(self.OpenMail, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.ClickHelp, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtNumber"])


	self.ring_cell_data = {}
	self.ring_cell_list = {}
	local list_view_delegate = self.node_list["RingList"].list_simple_delegate
	list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshListView, self)
end

function MarriageRingCountView:__delete()
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.ring_item_cell then
		self.ring_item_cell:DeleteMe()
		self.ring_item_cell = nil
	end

	if self.ring_cell then
		self.ring_cell:DeleteMe()
		self.ring_cell = nil
	end
	
	self.fight_text = nil

	for k, v in pairs(self.ring_cell_list) do
		v:DeleteMe()
	end
	self.ring_cell_list = {}
end

function MarriageRingCountView:GetNumberOfCells()
	return #self.ring_cell_data or 0
end

-- 背包宝石列表
function MarriageRingCountView:RefreshListView(cell, cell_index)
	cell_index = cell_index + 1
	local item_cell = self.ring_cell_list[cell]
	if nil == item_cell then
		item_cell = RingTargetCell.New(cell.gameObject)
		self.ring_cell_list[cell] = item_cell
	end

	local data = self.ring_cell_data[cell_index]
	item_cell:SetData(data)
end

function MarriageRingCountView:RingChange()
	--戒指图标
	local ring_cfg = MarriageData.Instance:GetRingCfg()
	local ring_id = nil
	if ring_cfg ~= nil then
		ring_id = ring_cfg.equip_id
	else
		ring_id = MarriageData.Instance:GetLevelOneRingCfg().equip_id
	end
	if self.now_ring_item_id ~= ring_id then
		self.ring_cell:SetData({item_id = ring_id, is_bind = 0}, true)
		self.ring_cell:SetInteractable(false)
		self.now_ring_item_id = ring_id
	end
	local item_cfg = ItemData.Instance:GetItemConfig(ring_id)
	--设置戒指信息
	local flag, item_id = MarriageData.Instance:GetRingInfo()
	if flag == 3 then
		--未激活
		self.node_list["PanelLeft"]:SetActive(false)
		self.node_list["PanelRight"]:SetActive(false)
		self.node_list["LeftFrame"]:SetActive(false)
		self.node_list["PanelNotActive"]:SetActive(true)
		if self.init_proess then
			self.init_proess = false
			self.node_list["Slider"].slider.value = 0
		else
			self.node_list["Slider"].slider.value = 0
		end
	else
		--已激活
		self.node_list["PanelLeft"]:SetActive(true)
		self.node_list["PanelRight"]:SetActive(true)
		self.node_list["LeftFrame"]:SetActive(true)
		self.node_list["PanelNotActive"]:SetActive(false)
		local item_cfg = ItemData.Instance:GetItemConfig(ring_id) 
		-- local str = ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color])
		-- self.node_list["Name"].text.text = str
		local ring_cfg2, is_max = MarriageData.Instance:GetRingCfg()
		local ring_exp = MarriageData.Instance:GetRingExp()
		if is_max then
			self.node_list["TxtPage"].text.text = Language.Common.MaxLevelDesc
			self.node_list["TxtNum"].text.text = Language.Common.MaxLevelDesc
			if self.init_proess then
				self.init_proess = false
				self.node_list["Slider"].slider.value = 1
			else
				self.node_list["Slider"].slider.value = 1
			end
		else
			local progress_value = ring_exp / ring_cfg2.exp
			if self.init_proess then
				self.init_proess = false
				self.node_list["Slider"].slider.value = progress_value
			else
				self.node_list["Slider"].slider.value = progress_value
			end
			self.node_list["TxtPage"].text.text = ring_exp .. "/" .. ring_cfg2.exp
		end
		--能否升级
		self.node_list["ImgRedPoint"]:SetActive(flag == 1)
	end

	--设置材料信息
	local id = MarriageData.Instance:GetRingUpgradeItem().stuff_id
	local num = ItemData.Instance:GetItemNumInBagById(id)
	if num < 1 then
		num = ToColorStr(num, TEXT_COLOR.RED)
	else
		num = ToColorStr(num, TEXT_COLOR.GREEN)
	end
	self.node_list["TxtNum"].text.text =string.format(Language.Marriage.ResidueValue, num)
	local data = {}
	data.item_id = id
	self.ring_item_cell:SetData(data)

	if ring_cfg then
		local attrs = CommonDataManager.GetAttributteByClass(ring_cfg, true)
		local capability = CommonDataManager.GetCapability(attrs)
		local item_cfg = ItemData.Instance:GetItemConfig(ring_cfg.equip_id)
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = capability
		end

		for i = 0, 9 do
			local is_grey = ring_cfg.star <= i
			UI:SetGraphicGrey(self.node_list["ImgLittleHeart" .. i], is_grey)
		end

		local level = ring_cfg.level
		if self.now_ring_level > 0 and level > self.now_ring_level then
			
			--播放升级特效
			self:PlayUpStarEffect()
		end
		self.now_ring_level = level--记录开始升级前的等级

		--设置当前信息
		self.node_list["TxtLevel1"].text.text = "Lv." .. level
		self.node_list["TxtGongJi"].text.text = string.format(Language.Marriage.GoJi2, ToColorStr(ring_cfg.gongji, TEXT_COLOR.ORANGE_4))
		self.node_list["TxtFangYu"].text.text =string.format(Language.Marriage.FangYu2,  ToColorStr(ring_cfg.fangyu, TEXT_COLOR.ORANGE_4))
		self.node_list["TxtShengMing"].text.text = string.format(Language.Marriage.Hp2,  ToColorStr(ring_cfg.maxhp, TEXT_COLOR.ORANGE_4))

		--获取下一级效果
		local next_cfg = MarriageData.Instance:GetNextRingCfg()
		if next_cfg then
			self.node_list["PanelUp"]:SetActive(true)
			self.node_list["TxtGongJi2"].text.text = ToColorStr(next_cfg.gongji - ring_cfg.gongji, TEXT_COLOR.ORANGE_4)
			self.node_list["TxtFangYu2"].text.text = ToColorStr(next_cfg.fangyu - ring_cfg.fangyu, TEXT_COLOR.ORANGE_4)
			self.node_list["TxtShengMing2"].text.text = ToColorStr(next_cfg.maxhp - ring_cfg.maxhp, TEXT_COLOR.ORANGE_4)
		else
			self.node_list["PanelUp"]:SetActive(true)
			for i = 1, 3 do
				self.node_list["next_attr_" .. i]:SetActive(false)
			end
		end

		self.ring_cell_data = MarriageData.Instance:GetShowRingTargetData(ring_cfg.target_id, level)
		self.node_list["RingList"].scroller:ReloadData(0)

		for i = 1, 4 do
			if i <= ring_cfg.star_num then
				self.node_list["Star" .. i]:SetActive(true)
			else
				self.node_list["Star" .. i]:SetActive(false)
			end
		end
	end
end

function MarriageRingCountView:OpenMail()
	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_mail)
end

function MarriageRingCountView:ClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(9)
end

--播放升级特效
function MarriageRingCountView:PlayUpStarEffect()
	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
		local bundle_name, asset_name = ResPath.GetUiEffect("UI_shengjichenggong")
		EffectManager.Instance:PlayAtTransformCenter(
			bundle_name, 
			asset_name, 
			self.node_list["EffectRoot"].transform, 
		2.0)
		self.effect_cd = Status.NowTime + EFFECT_CD
	end
end

--升级戒指按下时
function MarriageRingCountView:UpgradeRingClick()
	local flag, item_id = MarriageData.Instance:GetRingInfo()
	if flag == 0 then
		--满级了
		TipsCtrl.Instance:ShowSystemMsg(Language.Marriage.Ring_Max_Level)
	elseif flag == 1 then
		--未满级-可升级
		MarriageCtrl.Instance:SendUpgradeRing(1, 0)
	elseif flag == 2 then
		--不够材料
		TipsCtrl.Instance:ShowItemGetWayView(item_id)
	elseif flag == 3 then
		--未激活
		if self:CheckIsMarry() then
			--已结婚
			TipsCtrl.Instance:ShowSystemMsg(Language.Marriage.Activate_Ring)
		else
			--未结婚
			self:ShowGoToMarryTips()
		end
	end
end

--自动升级戒指
function MarriageRingCountView:AutoUpgradeRingClick()
	if self.time_quest ~= nil then
		self:StopAutoUpgrade()
	else
		local flag, item_id = MarriageData.Instance:GetRingInfo()

		local function ok_callback()
			self.start_level = self.now_ring_level
			local time_per_once = MarriageData.Instance:GetRingUpgradeItem().interval_time
			self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.AutoUpgrade, self), time_per_once)
		end

		if flag == 0 then
			--满级了
			TipsCtrl.Instance:ShowSystemMsg(Language.Marriage.Ring_Max_Level)
		elseif flag == 1 then
			--未满级-可升级
			local des = Language.Marriage.AutoUpLevelRing
			-- TipsCtrl.Instance:ShowCommonAutoView("auto_ring_up", des, ok_callback)
			ok_callback()
		elseif flag == 2 then
			--不够材料
			TipsCtrl.Instance:ShowItemGetWayView(item_id)
		elseif flag == 3 then
			--未激活
			if self:CheckIsMarry() then
				--已结婚
				TipsCtrl.Instance:ShowSystemMsg(Language.Marriage.Activate_Ring)
			else
				--未结婚
				self:ShowGoToMarryTips()
			end
		end
	end
end

--是否已婚
function MarriageRingCountView:CheckIsMarry()
	return MarriageData.Instance:CheckIsMarry()
end

function MarriageRingCountView:Flush()
	--是否结婚
	self.init_proess = true
	local is_marry = self:CheckIsMarry()
	
	self.node_list["PanelNotActive"]:SetActive(not is_marry)
	self:RingChange()
end

function MarriageRingCountView:StopAutoUpgrade()
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	if self.node_list["TxtSelfUp"] then
		self.node_list["TxtSelfUp"].text.text = Language.Common.AutoUpgrade
	end
end

function MarriageRingCountView:AutoUpgrade()
	local ring_cfg = MarriageData.Instance:GetRingCfg()
	local _, big_lev = math.modf(ring_cfg.equip_id / 10)
	big_lev = string.format("%.2f", big_lev or 0) * 100
	local level = big_lev + ring_cfg.star
	local stop_big_level = math.modf((self.start_level + 10) / 10)
	local stop_level = stop_big_level * 10
	if level >= stop_level then
		self:StopAutoUpgrade()
		return
	end

	local flag, item_id = MarriageData.Instance:GetRingInfo()
	if flag == 1 then
		MarriageCtrl.Instance:SendUpgradeRing(1, 0)
		if self.node_list["TxtSelfUp"] then
			self.node_list["TxtSelfUp"].text.text = Language.Common.Stop
		end
	elseif flag == 2 then
		TipsCtrl.Instance:ShowItemGetWayView(item_id)
		self:StopAutoUpgrade()
	else
		self:StopAutoUpgrade()
	end
end

--戒指按下时
function MarriageRingCountView:RingClick()
	local ring_had_active = MarriageData.Instance:GetRingHadActive()
	if ring_had_active then
	else
		if self:CheckIsMarry() then
			TipsCtrl.Instance:ShowSystemMsg(Language.Marriage.Activate_Ring)
		else
			self:ShowGoToMarryTips()
		end
	end
end

--前往结婚提示板
function MarriageRingCountView:ShowGoToMarryTips()
	local click_func = BindTool.Bind(self.GoToMarryClick, self)
	TipsCtrl.Instance:ShowOneOptionView(Language.Marriage.Not_Marry_Can_Not_Use, click_func, Language.Marriage.Go_To_Marry)
end
-----------------------------------------
-- 戒指升级目标 RingTargetCell
RingTargetCell = RingTargetCell or BaseClass(BaseCell)
function RingTargetCell:__init()
	
end

function RingTargetCell:__delete()
	
end

function RingTargetCell:OnFlush()
	if nil == self.data then return end

	self.node_list["Name"].text.text = self.data.target_name

	local ring_cfg = MarriageData.Instance:GetRingCfg()
	if not ring_cfg then return end
	if self.data.level <= ring_cfg.level then
		self.node_list["HLBg"]:SetActive(true)
	else
		self.node_list["HLBg"]:SetActive(false)
	end
end

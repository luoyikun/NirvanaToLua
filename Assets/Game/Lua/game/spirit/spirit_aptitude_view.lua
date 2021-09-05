-- 仙宠-仙宠悟性-AptitudeView
SpiritAptitudeView = SpiritAptitudeView or BaseClass(BaseRender)

local APTITUDE_TYPE = {"gongji", "fangyu", "maxhp", "maxhp_zizhi"}
local ZiZhi_Total_Attr = {"maxhp_zizhi", "gongji_zizhi", "fangyu_zizhi"}

function SpiritAptitudeView:__init(Instance)
	self.use_lucky_mark = false
	self.auto_buy = false
	self.upgrade_jump_show = false

	self.base_attr_list = {}
	for i = 1, 4 do
		self.base_attr_list[i] = {value = self.node_list["CurAttrTxt" .. i], next_value = self.node_list["NextAttrTxt"..i], 
		}

	end

	self.cur_owned = {}
	for i = 1, 2 do
		self.cur_owned[i] = self.node_list["NunTxt" .. i]
	end

	self.auto_buy_toggle = self.node_list["AutoBuyToggle"].toggle
	self.material = ItemCellReward.New()
	self.material:SetInstanceParent(self.node_list["Material"])

	self.node_list["ImageBtn"].button:AddClickListener(BindTool.Bind(self.OpenSpiritAptitudeTip, self))
	self.node_list["AutoBuyToggle"].toggle.onValueChanged:AddListener(BindTool.Bind(self.ToggleAutoBuy, self))
	self.node_list["ToggleLucky"].button:AddClickListener(BindTool.Bind(self.OnClickUseLuckyMark, self))
	self.node_list["GameBtn"].button:AddClickListener(BindTool.Bind(self.OnClickUpgrade, self))
	self.wuxing_data = SpiritData.Instance:GetWuXing()

	self.titles, self.title_needs, self.extra_attr, self.title_effect = self:GetAllTitle()

	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["UseLuckyImg"])
	self.item:ListenClick(BindTool.Bind(self.OnClickUseLuckyMark, self))

end

function SpiritAptitudeView:__delete()
	if self.material then
		self.material:DeleteMe()
		self.material = nil
	end

	if self.item then
		self.item:DeleteMe()
	end
end

function SpiritAptitudeView:SetAptitude(data)
	if data then
		UI:SetButtonEnabled(self.node_list["GameBtn"], tonumber(data.wu_xing) ~= self.maxlevel)
		self.node_list["GameBtnText"].text.text = tonumber(data.wu_xing) ~= self.maxlevel and Language.Common.TiShengWuXing or Language.Common.YiManJi
		if data.safe_id ~= 0 then
			self.item:SetData({item_id = data.safe_id})
		end

		local is_max = false
		if tonumber(data.wu_xing) == self.maxlevel then
			self.node_list["GongjiImg"]:SetActive(false)
			self.node_list["NextAttrNode"]:SetActive(false)
			self.node_list["IcomImg"]:SetActive(false)
			self.node_list["NetAttrNode"]:SetActive(false)
			self.node_list["GongjiImg1"]:SetActive(false)
			self.node_list["NetAttrNode1"]:SetActive(false)
			self.node_list["GongjiImg2"]:SetActive(false)
			self.node_list["NetAttrNode2"]:SetActive(false)
			self.node_list["GongjiImg3"]:SetActive(false)
			self.node_list["NetAttrNode23"]:SetActive(false)

			is_max = true
		else
			self.node_list["GongjiImg"]:SetActive(true)
			self.node_list["NextAttrNode"]:SetActive(true)
			self.node_list["IcomImg"]:SetActive(true)
			self.node_list["NetAttrNode"]:SetActive(true)
			self.node_list["GongjiImg1"]:SetActive(true)
			self.node_list["NetAttrNode1"]:SetActive(true)
			self.node_list["GongjiImg2"]:SetActive(false)
			self.node_list["NetAttrNode2"]:SetActive(false)
			self.node_list["GongjiImg3"]:SetActive(true)
			self.node_list["NetAttrNode23"]:SetActive(true)
		end
		self.node_list["Gongji_4"]:SetActive(data.quality > 4)
		if data.cur_deleption[2] == 0 then
			self.node_list["ToggleLucky"]:SetActive(false)
		else 
			self.node_list["ToggleLucky"]:SetActive(false)
		end
		self.node_list["TitleTxt"].text.text = string.format("%s Lv.%s", Language.JingLing.TabbarName[8], data.wu_xing)
		local x = {}
		x.item_id = data.item_id
		self.material:SetData(x)

		self.node_list["SuccessRateTxt"].text.text = string.format("%s%%", data.percent)

		for i = 1, 4 do
			if data.aptitude_list[i] and data.aptitude_list[i].value then
				if i == 4 and data.aptitude_list[i].next_value then
					-- self.base_attr_list[i].value.text.text = data.aptitude_list[i].name .. "：<color=#ffffff>" .. data.aptitude_list[i].value .. "%" .. "</color>"
					-- self.base_attr_list[i].next_value.text.text = data.aptitude_list[i].next_value .. "%" 
					if is_max then
						self.base_attr_list[i].value.text.text = string.format(Language.JingLing.WuXingSpecial, data.aptitude_list[i].value) .. Language.JingLing.MaxLevel
					else
						self.base_attr_list[i].value.text.text = string.format(Language.JingLing.WuXingSpecial, data.aptitude_list[i].value) .. string.format(Language.JingLing.WuXingSpecialNext, data.aptitude_list[i].next_level,  data.aptitude_list[i].next_value)
					end
				else
					self.base_attr_list[i].value.text.text = data.aptitude_list[i].name .. "：<color=#ffffff>" .. data.aptitude_list[i].value .. "</color>"
					self.base_attr_list[i].next_value.text.text = data.aptitude_list[i].next_value
				end

				--self.node_list["GongjiImg2"]:SetActive((data.aptitude_list[i].value ~= "") and (tonumber(data.wu_xing) ~= self.maxlevel))
				if data.aptitude_list[i].value == "" then
					self.base_attr_list[i].value.text.text = ""
					self.base_attr_list[i].next_value.text.text = ""
				end
			end
		end

		local value = ""
		for i = 1, 2 do
			if self.cur_data.cur_owned[i] < self.cur_data.cur_deleption[i] then
				value = string.format(Language.Mount.ShowRedNum, self.cur_data.cur_owned[i])
			else
				value = self.cur_data.cur_owned[i]
			end

			if is_max and i == 1 then
				self.cur_owned[i].text.text = Language.Common.MaxLevelDesc
			else
				self.cur_owned[i].text.text = value .. " / " .. data.cur_deleption[i]
			end
		end

		if data.cur_owned[2] < data.cur_deleption[2] then
			self.use_lucky_mark = false
			self.node_list["UseLuckyImg"]:SetActive(false)
			self.node_list["UseLuckyBtn"]:SetActive(true)
			self.node_list["NunTxt2"]:SetActive(false)
		end

		self.node_list["CurAttrImg"].text.text = string.format(Language.JingLing.JiNengCao, data.skill_num)
		self.node_list["CurTxt"].text.text = string.format(Language.Common.jIShu, data.next_skill, data.cur_level, data.need_level)
		self.node_list["CurAttrImg1"]:SetActive(data.show_limit)
		self.node_list["NextAttrNode1"]:SetActive(data.show_limit)
	end
end

function SpiritAptitudeView:OpenSpiritAptitudeTip()
	TipsCtrl.Instance:ShowSpiritAptitudeView(self.cur_data)
end

function SpiritAptitudeView:GetFightPower()
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	if spirit_info then
		if spirit_info.use_jingling_id <= 0 then
			return 0
		end
	end
	if self.cur_data and next(self.cur_data) then
		local attr_table = {}
		for i = 1, 4 do
			attr_table[APTITUDE_TYPE[i]] = self.cur_data.aptitude_list[i].value
		end
		local role_hp = PlayerData.Instance and PlayerData.Instance:GetRoleVo().base_max_hp or 0
		local add_hp = role_hp * attr_table.maxhp_zizhi / 100
		attr_table.maxhp = attr_table.maxhp + add_hp

		local fight_power = CommonDataManager.GetCapabilityCalculation(attr_table)
		return fight_power
	else
		return 0
	end
end

-- 对外的入口
function SpiritAptitudeView:FlushData(data)
	if next(data) then
		if data.item_id ~= self.cur_item then
			self.use_lucky_mark = false
			self.node_list["UseLuckyImg"]:SetActive(self.use_lucky_mark)
			self.node_list["UseLuckyBtn"]:SetActive(not self.use_lucky_mark)
			self.node_list["NunTxt2"]:SetActive(self.use_lucky_mark)
		end

		self.aptitude_data = SpiritData.Instance:GetSpiritTalentAttrCfgById(data.item_id)
		local item_cfg, big_type = ItemData.Instance:GetItemConfig(data.item_id)

		self.cur_item = data.item_id
		data.quality = item_cfg.color
		self:ConstructData(data)
		self.maxlevel = SpiritData.Instance:GetWuXingMaxLevel(item_cfg.color)
	else
		for i = 1, 4 do
			if i <= 3 then
				self.base_attr_list[i].value.text.text = Language.JingLing.JingLingAttrName[i] .. 0
				self.base_attr_list[i].next_value.text.text = 0
			else
				self.base_attr_list[i].value:SetActive(false)
			end
		end
		self.material:SetData(nil)
		self.node_list["TitleTxt"].text.text = string.format("%s Lv.%s", Language.JingLing.TabbarName[8], 0)
		for i = 1, 2 do
			self.cur_owned[i].text.text = "- / -"
		end
	end
end

function SpiritAptitudeView:ConstructData(data)
	if data == nil then 
		return
	end
	self.cur_data = {}

	self.cur_data.titles = self.titles
	self.cur_data.title_needs = self.title_needs
	self.cur_data.extra_attr = self.extra_attr
	self.cur_data.title_effect = self.title_effect

	self.cur_data.wu_xing = data.param.param1
	local wu_xing = tonumber(self.cur_data.wu_xing)		-- 就是悟性等级
	local highest_wu_xing = tonumber(data.param.param2)

	local wuxing_cfg = SpiritData.Instance:GetWuXingCfgByLevel(wu_xing, data.quality)

	self.cur_data.skill_num = wuxing_cfg.skill_num
	self.cur_data.cur_level = "<color=" .. TEXT_COLOR.RED .. ">" .. highest_wu_xing .. "</color>"
	self.cur_data.need_level = SpiritData.Instance:GetNextWuXingBySkillNum(self.cur_data.skill_num)
	self.cur_data.show_limit = SpiritData.Instance:GetMaxSkillNum() ~= self.cur_data.skill_num
	self.cur_data.next_skill = self.cur_data.skill_num + 1
	self.cur_data.percent = wuxing_cfg.succ_rate
	self.cur_data.safe_id = wuxing_cfg.safe_id
	self.cur_data.index = data.index
	self.cur_data.quality = data.quality
	self.cur_data.aptitude_list = {}
	self.cur_data.cur_owned = {}
	self.cur_data.cur_deleption = {}

	self.cur_data.item_id = SpiritData.Instance:GetWuXingDanId(data.quality)

	for i = 1, 4 do
		self.cur_data.aptitude_list[i] = {}
		self.cur_data.aptitude_list[i].name = Language.ZiZhi[i]
		self.cur_data.aptitude_list[i].original_value = self.aptitude_data[APTITUDE_TYPE[i]]
		if i == 4 then
			local next_level = math.floor(wu_xing / 10) + 1 
			next_level = next_level * 10
			next_level = wu_xing == self.maxlevel and wu_xing or next_level
			local wuxing_cfg_next = SpiritData.Instance:GetWuXingCfgByLevel(next_level, data.quality)
			if wuxing_cfg_next then
				self.cur_data.aptitude_list[i].next_level = next_level
				self.cur_data.aptitude_list[i].value = math.floor(wuxing_cfg[APTITUDE_TYPE[i]]) / 100
				-- self.cur_data.aptitude_list[i].next_value = math.max(0, wuxing_cfg_next[APTITUDE_TYPE[i]] - wuxing_cfg[APTITUDE_TYPE[i]]) / 100
				self.cur_data.aptitude_list[i].next_value = math.max(0, wuxing_cfg_next[APTITUDE_TYPE[i]]) / 100
			else
				self.cur_data.aptitude_list[i].value = math.floor(wuxing_cfg[APTITUDE_TYPE[i]])
			end
		else
			local next_wuxing = wu_xing == self.maxlevel and wu_xing or wu_xing + 1
			local wuxing_cfg_next = SpiritData.Instance:GetWuXingCfgByLevel(next_wuxing, data.quality)
			if wuxing_cfg_next then
				self.cur_data.aptitude_list[i].value = math.floor(wuxing_cfg[APTITUDE_TYPE[i]])
				self.cur_data.aptitude_list[i].next_value = math.max(0, wuxing_cfg_next[APTITUDE_TYPE[i]] - wuxing_cfg[APTITUDE_TYPE[i]])
			else
				self.cur_data.aptitude_list[i].value = math.floor(wuxing_cfg[APTITUDE_TYPE[i]])
			end
		end
	end

	local items = {}
	table.insert(items, self.cur_data.item_id)
	table.insert(items, self.cur_data.safe_id)
	local itemsNum = {}
	table.insert(itemsNum, wuxing_cfg.stuff_num)
	table.insert(itemsNum, wuxing_cfg.safe_num)

	for i = 1, 2 do
		self.cur_data.cur_owned[i] = ItemData.Instance:GetItemNumInBagById(items[i])
		self.cur_data.cur_deleption[i] = itemsNum[i] 
	end
	self:SetAptitude(self.cur_data)
end

function SpiritAptitudeView:OnClickUpgrade()
	self.upgrade_jump_show = true
	if self:CheckLevel() then
		TipsCtrl.Instance:ShowSystemMsg(Language.JingLing.MaxJingLingLevel)
		return
	end

	if not self.auto_buy then
		if self.cur_data.cur_owned[1] < self.cur_data.cur_deleption[1] then
			local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
				MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
				--勾选自动购买
				if is_buy_quick then
					self.auto_buy_toggle.isOn = true
					self.auto_buy = true
				end
			end
			 TipsCtrl.Instance:ShowSystemMsg(Language.JingLing.WuXingDanBuZu)
		else
			local lucky_mark_number = self.use_lucky_mark and 1 or 0
			SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_UPLEVEL_WUXING, self.cur_data.index, lucky_mark_number, 0)
		end
	else
		local lucky_mark_number = self.use_lucky_mark and 1 or 0
		SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_UPLEVEL_WUXING, 
		self.cur_data.index, lucky_mark_number, 1)
	end
end

function SpiritAptitudeView:GetUpgradeJumpShow()
	return self.upgrade_jump_show
end

function SpiritAptitudeView:OnClickUseLuckyMark()
	if self.cur_data.cur_owned[2] < self.cur_data.cur_deleption[2] then
		self.use_lucky_mark = false
		self.node_list["UseLuckyImg"]:SetActive(false)
		self.node_list["UseLuckyBtn"]:SetActive(true)
		self.node_list["NunTxt2"]:SetActive(false)
		TipsCtrl.Instance:ShowItemGetWayView(self.cur_data.safe_id)
		return
	end
	self.use_lucky_mark = not self.use_lucky_mark
	if self.node_list then
		self.node_list["UseLuckyImg"]:SetActive(self.use_lucky_mark)
		self.node_list["UseLuckyBtn"]:SetActive(not self.use_lucky_mark)
		self.node_list["NunTxt2"]:SetActive(self.use_lucky_mark)
	end
	self.item:SetHighLight(false)
end

function SpiritAptitudeView:ToggleAutoBuy()
	self.auto_buy = not self.auto_buy
end

-- 检查是否顶级
function SpiritAptitudeView:CheckLevel()
	if self.cur_data then
		return self.cur_data.wu_xing == self.maxlevel
	end
end

function SpiritAptitudeView:GetAllTitle()
	local titles = {}
	local title_needs = {}
	local title_extra_add = {}
	local title_effect = {}
	for i, v in ipairs(self.wuxing_data) do
		if titles[#titles] ~= v.title then
			table.insert(titles, v.title)
			table.insert(title_effect, v.effect_id)
			table.insert(title_extra_add, v.extra_attr)
			if v.title ~= "" then
				table.insert(title_needs, i)

			end
		end
	end
	return titles, title_needs, title_extra_add, title_effect
end

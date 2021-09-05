-- 仙盟剑阵-AltarContent
GuildAltarView = GuildAltarView or BaseClass(BaseRender)

local SkillEnum = {
		[0] = "gongji",
		[1] = "fangyu",		
		[2] = "maxhp",
		[3] = "zhufuyiji_per",
	}

local ALLHASATTRNUM = 3
function GuildAltarView:__init(instance)

end

function GuildAltarView:__delete()
	for i = 1, 4 do
		if self.model_list[i] then
			self.model_list[i]:DeleteMe()
			self.model_list[i] = nil
		end
	end
	self.model_list = {}

	for i,v in ipairs(self.left_view) do
		v:DeleteMe()
		self.left_view[i] = nil
	end

	for k, v in pairs(self.fight_text) do
		v = nil
	end
	self.fight_text = {}
	self.left_view = {}

	self.is_first_open = nil
end

function GuildAltarView:LoadCallBack(instance)
	self.fight_text = {}
	self.model_list = {}
	self.left_view = {}
	for i = 1, 4 do
		self.model_list[i] = RoleModel.New()
		self.model_list[i]:SetDisplay(self.node_list["Display" .. i].ui3d_display, MODEL_CAMERA_TYPE.BASE, true)
		self.fight_text[i] = CommonDataManager.FightPower(self, self.node_list["Fight" .. i])
		self.node_list["BtnDisplayMask" .. i].button:AddClickListener(BindTool.Bind(self.ClickFourSword, self, i - 1))
		self.left_view[i] = GuildLeftView.New(self.node_list["LeftContent" .. i], self)
			-- body
	end

	self.is_first_open = true
	self.select_index = -1		-- 选中的剑

	local cfg = GuildData.Instance:GetSkillDecCfg()
	for k,v in pairs(cfg) do
		if self.node_list["Name" .. (k + 1)] then
			self.node_list["Name" .. (k + 1)].text.text = v.skill_name
		end
	end
end

function GuildAltarView:OpenCallBack()
	self.is_first_open = true

	self.node_list["SkillContentOne"]:SetActive(true)
	UITween.AlpahShowPanel(self.node_list["SkillContentOne"], true, 0.5, DG.Tweening.Ease.Linear, nil)
	
end

function GuildAltarView:OnFlush()
	if not self.is_first_open then
		self:FlushLeftView()
	end
	self:SetFourSwordModel()
	self:FlushSwordRemind()
	for i = 1, 4 do
		self.left_view[i]:FlushRightInfoPane()
	end
	
end

-- 设置4把剑模型
function GuildAltarView:SetFourSwordModel()
	local skill_dec_cfg = GuildData.Instance:GetSkillDecCfg()
	if skill_dec_cfg and self.is_first_open then
		for k, v in pairs(skill_dec_cfg) do
			local index = k + 1
			self:FlushFight(index)
			self.model_list[index]:SetRotation()
			local bundle,asset = ResPath.GetSkillSwordModel(v.model_id)
			self.model_list[index]:SetMainAsset(bundle,asset, function()
				self.model_list[index]:SetScale(Vector3(1.3, 1.3, 1.3))
			end)
		end
		self.is_first_open = false
	end
end

function GuildAltarView:FlushFight(index)
		local level = GuildData.Instance:GetSkillLevel(index) or 0
		local skill_cfg = GuildData.Instance:GetSkillConfig(index, level)
		local skill_attr = CommonDataManager.GetAttributteByClass(skill_cfg) 
		if self.fight_text[index] and self.fight_text[index].text then
			self.fight_text[index].text.text = CommonDataManager.GetCapabilityCalculation(skill_attr)
		end
end
-- 刷新剑上的红点
function GuildAltarView:FlushSwordRemind()
	for i = 1, 4 do
		 self.node_list["Remind" .. i]:SetActive(GuildData.Instance:IsCanUpgrade(i))
	end
end

-- 点击剑的监听
function GuildAltarView:ClickFourSword(index)
	self.select_index = index
	self:Flush()
end

function GuildAltarView:FlushLeftView()
	if self.left_view[self.select_index + 1] == nil then
		return
	end
	if self.left_view[self.select_index + 1].is_open then
		self.left_view[self.select_index + 1]:FlushRightInfoPane()
		self:FlushFight(self.select_index + 1)
		return
	end

	for _,v in ipairs(self.left_view) do
		if v.is_open then
			v:ClickCloseInfoPanel()
		end
	end
	self.left_view[self.select_index + 1]:ClickOpenInfoPanel()
end

GuildLeftView = GuildLeftView or BaseClass(BaseRender)
function GuildLeftView:__init(instance, parent)
	self.parent = parent
	self.is_expend_goods = true -- 是否消耗物品
	self.is_open = false 		-- 是否打开

	self.item_list = {}
	for i = 1, 2 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self.node_list["ItemParent" .. i])
	end

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.ClickCloseInfoPanel, self))
	self.node_list["BtnUpgrade"].button:AddClickListener(BindTool.Bind(self.ClickUpGrade, self))
end

function GuildLeftView:__delete()
	for i = 1, 2 do
		if self.item_list[i] then
			self.item_list[i]:DeleteMe()
			self.item_list[i] = nil 
		end
	end
	self.item_list = {}
	
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

-- 关闭详细信息面板
function GuildLeftView:ClickCloseInfoPanel()
	self.node_list["Content1"]:SetActive(false)
	self.node_list["LeftContent"].rect.sizeDelta = Vector2(0, 712)
	self.node_list["ContentBG"].rect.sizeDelta = Vector2(0, 733)
	self.parent.node_list["Content"].rect.sizeDelta = Vector2(1216, 712)
	UITween.SizeShowPanel(self.node_list["ContentBG"], Vector2(533, 733), 0.3, DG.Tweening.Ease.Linear)
	UITween.SizeShowPanel(self.node_list["LeftContent"], Vector2(516, 712), 0.3, DG.Tweening.Ease.Linear, function ()
		self.node_list["LeftContent"]:SetActive(false)
		self.node_list["ContentBG"]:SetActive(false)
		self.is_open = false
	end)
end

--打开详细信息面板
function GuildLeftView:ClickOpenInfoPanel()
	self.node_list["Content1"]:SetActive(false)
	self.node_list["LeftContent"]:SetActive(true)
	self.node_list["ContentBG"]:SetActive(true)
	self.is_open = true
	self.node_list["LeftContent"].rect.sizeDelta = Vector2(516, 712)
	self.node_list["ContentBG"].rect.sizeDelta = Vector2(533, 733)
	self.parent.node_list["Content"].rect.sizeDelta = Vector2(1732, 712)
	self:SetScrollPostion()
	UITween.SizeShowPanel(self.node_list["ContentBG"], Vector2(0, 733), 0.3, DG.Tweening.Ease.Linear)
	UITween.SizeShowPanel(self.node_list["LeftContent"], Vector2(0, 712), 0.3, DG.Tweening.Ease.Linear, function ()
		self.node_list["Content1"]:SetActive(true)
		self:FlushRightInfoPane()
	end)
end

--位移
function GuildLeftView:SetScrollPostion()
	if self.timer ~= nil then return end

	local scroll_position = self.parent.node_list["SkillContentOne"].scroll_rect.horizontalNormalizedPosition
	local value = self.parent.select_index < 2 and self.parent.select_index / 4 or (self.parent.select_index + 1) / 4
	local time = TimeCtrl.Instance:GetServerTime() + 0.4
	value = value > 1 and 1 or value
	self.timer = GlobalTimerQuest:AddRunQuest(function ()
		local lerp_time = time - TimeCtrl.Instance:GetServerTime()
		if lerp_time < 0 then
			self.parent.node_list["SkillContentOne"].scroll_rect.horizontalNormalizedPosition = value
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
		local t = 1 - (lerp_time / 0.4)
		local lerp_value = Mathf.Lerp(scroll_position, value, t)
		self.parent.node_list["SkillContentOne"].scroll_rect.horizontalNormalizedPosition = lerp_value
	end, 0.01)
end

-- 技能升级
function GuildLeftView:ClickUpGrade()
	local level = GuildData.Instance:GetSkillLevel(self.parent.select_index + 1)
	if level >= GuildData.Instance:GetMaxGuildSkillLevel() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.GuildLevelMax)
		return
	end
	local config = GuildData.Instance:GetSkillConfig(self.parent.select_index + 1, level)

	if config then
		local gongxian = GuildData.Instance:GetGuildGongxian()
		if gongxian < config.uplevel_gongxian then
			SysMsgCtrl.Instance:ErrorRemind(Language.Guild.EnoughGongXian)
			return
		end

		if self.is_expend_goods then
			local have_item_num = ItemData.Instance:GetItemNumInBagById(config.uplevel_stuff_id)
			if have_item_num < config.uplevel_stuff_count then
				SysMsgCtrl.Instance:ErrorRemind(Language.Guild.EnoughGoods)
				return
			end
		end

		local skill_index = config.skill_idx
		GuildCtrl.Instance:SendGuildSkillUplevelReq(skill_index)
	end

end


-- 刷新右边详细信息面板
function GuildLeftView:FlushRightInfoPane()
	local select_sword_cfg = GuildData.Instance:GetSkillDecCfg()[self.parent.select_index]
	local level = GuildData.Instance:GetSkillLevel(self.parent.select_index + 1) or 0
	local skill_cfg = GuildData.Instance:GetSkillConfig(self.parent.select_index + 1, level)
	if not select_sword_cfg or not skill_cfg then
		return
	end

	local is_max_level = level >= GuildData.Instance:GetMaxGuildSkillLevel()

	self.node_list["TextDec"].text.text = select_sword_cfg.desc

	self.is_expend_goods = skill_cfg.uplevel_stuff_id ~= 0 and skill_cfg.uplevel_stuff_count ~= 0
	self.node_list["ImageAdd"]:SetActive(self.is_expend_goods)
	self.node_list["ItemParent2"]:SetActive(self.is_expend_goods)

	local item_cfg_one = ItemData.Instance:GetItemConfig(COMMON_CONSTS.VIRTUAL_ITEM_GONGXIAN)
	if item_cfg_one then
		self.node_list["TextGoodsName1"].text.text = ToColorStr(item_cfg_one.name, ORDER_COLOR[item_cfg_one.color])
		self.item_list[1]:SetData({item_id = COMMON_CONSTS.VIRTUAL_ITEM_GONGXIAN})
		local gongxian = GuildData.Instance:GetGuildGongxian()
		local gongxian_str = CommonDataManager.ConverMoney(gongxian)
		if gongxian >= skill_cfg.uplevel_gongxian then
			self.node_list["TextNum1"].text.text = gongxian_str .." / " .. skill_cfg.uplevel_gongxian
		else
			self.node_list["TextNum1"].text.text = ToColorStr(gongxian_str, TEXT_COLOR.RED) .." / " .. ToColorStr(skill_cfg.uplevel_gongxian, TEXT_COLOR.GREEN)
		end

		if is_max_level then
			self.node_list["TextNum1"].text.text = Language.Common.MaxLevelDesc
		end
	end

	if self.is_expend_goods then
		local item_cfg_two = ItemData.Instance:GetItemConfig(skill_cfg.uplevel_stuff_id)
		if item_cfg_two then
			self.node_list["TextGoodsName2"].text.text = ToColorStr(item_cfg_two.name, ORDER_COLOR[item_cfg_two.color])
			local have_item_num = ItemData.Instance:GetItemNumInBagById(skill_cfg.uplevel_stuff_id)
			local  str_have_num = have_item_num .. ""
			if have_item_num < skill_cfg.uplevel_stuff_count then
				str_have_num = ToColorStr(have_item_num, TEXT_COLOR.RED)
			end
			self.node_list["TextNum2"].text.text = string.format("%s / %d", str_have_num, skill_cfg.uplevel_stuff_count)
			self.item_list[2]:SetData({item_id = skill_cfg.uplevel_stuff_id})

			if is_max_level then
				self.node_list["TextNum2"].text.text = Language.Common.MaxLevelDesc
			end
		end
	end

	self.node_list["Detail2"]:SetActive(not is_max_level)
	self.node_list["ImageArrow"]:SetActive(not is_max_level)
	self.node_list["TextCurrentLevel"].text.text = "Lv." .. level
	
	
	for i = 0, ALLHASATTRNUM - 1 do
		local attr_name = Language.Common.AttrNameNoUnderline[SkillEnum[i]]
		self.node_list["TextCurrentAttr" .. i].text.text = string.format(Language.Guild.AttrAddNum, attr_name, skill_cfg[SkillEnum[i]])
		self.node_list["TextCurrentAttr" .. i]:SetActive(true)
	end
	if self.parent.select_index == ALLHASATTRNUM and self.node_list["TextSpecialAttr"] then
		local next_level = level + 10 - ((level + 10) % 10)
		local is_next_level = next_level <= GuildData.Instance:GetMaxGuildSkillLevel()

		-- local attr_name = Language.Common.AttrNameNoUnderline[SkillEnum[ALLHASATTRNUM]]
		local value = math.floor(skill_cfg[SkillEnum[ALLHASATTRNUM]] / 10)
		local left_value = self:GetPercentStr(value)

		if is_next_level then
			local next_add_cfg = GuildData.Instance:GetSkillConfig(ALLHASATTRNUM + 1, next_level)
			local next_add_zhufu = math.floor(next_add_cfg[SkillEnum[ALLHASATTRNUM]] / 10)
			local right_value = self:GetPercentStr(next_add_zhufu)

			self.node_list["TextSpecialAttr"].text.text = string.format(Language.Guild.AttrAddSpecial, left_value, next_level, right_value) 
		else
			self.node_list["TextSpecialAttr"].text.text = string.format(Language.Guild.AttrMaxAddSpecial, left_value)
		end
		self.node_list["TextSpecialAttr"]:SetActive(true)
	end

	if not is_max_level then
		local next_level_skill_cfg = GuildData.Instance:GetSkillConfig(self.parent.select_index + 1, level + 1)
		if next_level_skill_cfg then
			self.node_list["TextNextLevel"].text.text = "Lv." .. (level + 1)
			for i = 0, ALLHASATTRNUM - 1 do
				local attr_name = Language.Common.AttrNameNoUnderline[SkillEnum[i]]
				self.node_list["TextNextAttr" .. i].text.text = string.format(Language.Guild.AttrAddNum, attr_name, next_level_skill_cfg[SkillEnum[i]])
				self.node_list["TextNextAttr" .. i]:SetActive(true)
			end
		end
	end

	UI:SetButtonEnabled(self.node_list["BtnUpgrade"], not is_max_level)
	self.node_list["TextBtnUpgrade"].text.text = is_max_level and Language.Guild.YiManJi or Language.Guild.Upgrade
end

function GuildLeftView:GetPercentStr(value)
	local value = value or 0
	local point_left = math.floor(value / 10)
	local point_right = value % 10
	local txt_value = ""
	if point_right == 0 then
		txt_value = point_left
	else
		txt_value = point_left .. "." .. point_right
	end

	return txt_value
end
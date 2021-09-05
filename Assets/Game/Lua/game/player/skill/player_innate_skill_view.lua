PlayerInnateSkillView = PlayerInnateSkillView or BaseClass(BaseRender)

local SKILL_TYPE = {
	[1] = "Atk",
	[2] = "Def",
	[3] = "Common",
	[4] = "Pro",
}

local ATK_SKILL_NUM = 13
local DEF_SKILL_NUM = 13
local COMMON_SKILL_NUM = 12
local PRO_SKILL_NUM = 15

local layout_skill_item = {
	[1] = "InnateSkillOneItemRender",
	[2] = "InnateSkillTwoItemRender",
	[3] = "InnateSkillThreeItemRender",
	[4] = "InnateFourThreeItemRender",
}

function PlayerInnateSkillView:__init(instance, parent_view)
	for i = 1, #SKILL_TYPE do
		self.node_list["Skill" .. SKILL_TYPE[i]].toggle:AddClickListener(BindTool.Bind(self.OnClickSkillType, self, i))
	end

	self.skill_item_list = {}

	self.skill_type = 0
	self.skill_index = 1
	self.is_max_level = false

	self:OnClickSkillType(1)

	self.node_list["ResetBtn"].button:AddClickListener(BindTool.Bind(self.OnClickResetBtn, self))
	self.node_list["UpgradeBtn"].button:AddClickListener(BindTool.Bind(self.OnUpGradeBtn, self))
	self.node_list["HelpTip"].button:AddClickListener(BindTool.Bind(self.OnHelpTip, self))

	local _, zhuan = PlayerData.Instance:GetRoleBaseProf()
	if zhuan < SkillData.Instance:GetInnateSkillOpen("zhuan_gongfang") then
		self.node_list["SkillAtk"]:SetActive(false)
		self.node_list["SkillDef"]:SetActive(false)
	else
		self.node_list["SkillAtk"]:SetActive(true)
		self.node_list["SkillDef"]:SetActive(true)
	end
	if zhuan < SkillData.Instance:GetInnateSkillOpen("zhuan_tongyong") then
		self.node_list["SkillCommon"]:SetActive(false)
	else
		self.node_list["SkillCommon"]:SetActive(true)
	end
	-- if zhuan < SkillData.Instance:GetInnateSkillOpen("zhuan_jingtong") then
	-- 	self.node_list["SkillPro"]:SetActive(false)
	-- else
	-- 	self.node_list["SkillPro"]:SetActive(true)
	-- end
end

function PlayerInnateSkillView:__delete()
	RemindManager.Instance:UnBind(self.remind_change)

	for k,v in pairs(self.skill_item_list) do
		v:DeleteMe()
	end
	self.skill_item_list = nil
end

function PlayerInnateSkillView:OnClickSkillType(skill_type)
	if self.skill_type == skill_type then
		return
	end
	if nil == self.skill_item_list[skill_type] then
		if skill_type == 1 then
			self.skill_item_list[skill_type] = InnateSkillOneItemRender.New(self.node_list["AtkList"], self, skill_type)
			self.node_list["SkillAtk"].toggle.isOn = true
		elseif skill_type == 2 then
			self.skill_item_list[skill_type] = InnateSkillTwoItemRender.New(self.node_list["DefList"], self, skill_type)
		elseif skill_type == 3 then
			self.skill_item_list[skill_type] = InnateSkillThreeItemRender.New(self.node_list["CommonList"], self, skill_type)
		-- elseif skill_type == 4 then
			-- self.skill_item_list[skill_type] = InnateSkillFourItemRender.New(self.node_list["ProList"], self, skill_type)
		end
	end

	for i = 1, #SKILL_TYPE do
		self.node_list[SKILL_TYPE[i] .. "List"]:SetActive(skill_type == i)
		self.node_list["SkillTitel"].text.text = Language.Player.InnateSkillTitle[skill_type]
	end

	self.skill_type = skill_type
	self:OnClickSkillIcon(skill_type, 1)
end

function PlayerInnateSkillView:OnClickResetBtn()
	local other_cfg = SkillData.Instance:GetRoleTalentSkillResetItem()
	local reset_consume_item = other_cfg.reset_consume_item
	local item_num = ItemData.Instance:GetItemNumInBagById(reset_consume_item)
	if item_num > 0 then
		local ok_fun = function ()
			SkillCtrl.Instance:SendRoleTelentOperate(GameEnum.ROLE_TALENT_OPERATE_TYPE.ROLE_TALENT_OPERATE_TYPE_RESET)
		end
		local item_name = ItemData.Instance:GetItemName(reset_consume_item)
		local cfg = string.format(Language.Player.ResetText, item_name)
		TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, cfg)
	else
		local ok_fun = function ()
			SkillCtrl.Instance:SendRoleTelentOperate(GameEnum.ROLE_TALENT_OPERATE_TYPE.ROLE_TALENT_OPERATE_TYPE_RESET, 1)
		end
		local item_name = ItemData.Instance:GetItemName(reset_consume_item)
		local cast_cfg = ShopData.Instance:GetShopItemCfg(reset_consume_item)
		if cast_cfg then
			local cast = cast_cfg.gold
			local cfg = string.format(Language.Player.BuySkillThing, cast, item_name)
			TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, cfg)
		end
	end
end

function PlayerInnateSkillView:OnUpGradeBtn()
	if self.is_max_level then
		TipsCtrl.Instance:ShowSystemMsg(Language.Player.IsMaxLevel)
		return
	end
	local max_skill_cfg_list = SkillData.Instance:SetRoleTalentLevelList(self.skill_type)
	local max_skill_cfg = max_skill_cfg_list[self.skill_index]
	if max_skill_cfg then
		SkillCtrl.Instance:SendRoleTelentOperate(GameEnum.ROLE_TALENT_OPERATE_TYPE.ROLE_TALENT_OPERATE_TYPE_UPLEVEL, max_skill_cfg.talent_id)
	end
end

function PlayerInnateSkillView:OnHelpTip()
	local tips_id = 292
  	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function PlayerInnateSkillView:OnFlush()
	self.node_list["SkillRemainNum"].text.text = SkillData.Instance:GetRoleTalentPoint()

	for k,v in pairs(SKILL_TYPE) do
		local skill_type_level = SkillData.Instance:GetRoleTalentSkillTypeLevel(k)
		self.node_list[v .. "Level"].text.text = skill_type_level
	end

	self:FlushExplain()
	self:FlushAllSkillIcon()
	self:FlushRedPoint()

	local other_cfg = SkillData.Instance:GetRoleTalentSkillResetItem()
	-- if PlayerData.Instance:GetRoleLevel() < other_cfg.open_proficient_talent_level or not TaskData.Instance:GetTaskIsCompleted(other_cfg.task_id) then
	-- 	self.node_list["Skill" .. SKILL_TYPE[4]]:SetActive(false)
	-- else
	-- 	self.node_list["Skill" .. SKILL_TYPE[4]]:SetActive(true)
	-- end
	local next_talentpoint_level = SkillData.Instance:GetNextTalentPointLevel()
	-- if next_talentpoint_level and next_talentpoint_level >= 0 then
	-- 	self.node_list["ExplainText"]:SetActive(true)
	-- 	self.node_list["ExplainText"].text.text = string.format(Language.Player.ExplainText, next_talentpoint_level)
	-- else
	-- 	self.node_list["ExplainText"]:SetActive(false)
	-- end
end

function PlayerInnateSkillView:FlushExplain()
	local max_skill_cfg_list = SkillData.Instance:SetRoleTalentLevelList(self.skill_type)
	local max_skill_cfg = max_skill_cfg_list[self.skill_index]
	-- local next_skill_cfg = SkillData.Instance:GetRoleTalentSkillCfg(max_skill_cfg.talent_id, max_skill_cfg.level + 1)
	if not max_skill_cfg then return end

	self.node_list["SkillName"].text.text = max_skill_cfg.name
	self.node_list["SkillLevel"].text.text = string.format(Language.Player.InnateSkillLevel, max_skill_cfg.level, max_skill_cfg.max_level)

	local icon_index_cfg = SkillData.Instance:GetUseWarSceneSkill(self.skill_type, self.skill_index)
	local asset, bundle
	if icon_index_cfg then
		asset, bundle = ResPath.GetInnateSkillImage(self.skill_type, icon_index_cfg.icon)
	else
		asset, bundle = ResPath.GetInnateSkillImage(self.skill_type, self.skill_index)
	end
	self.node_list["SkillBg"].image:LoadSprite(asset, bundle)

	local skill_text_1, skill_text_2 = nil, nil

	self.is_max_level = false
	local show_state = 1
	if max_skill_cfg.level == 0 then
		show_state = 0
		self.node_list["Title1"].text.text = Language.Player.TitleNameMax
		skill_text_1 = SkillData.Instance:GetRoleTalentSkillCfg(max_skill_cfg.talent_id, max_skill_cfg.max_level)
		skill_text_2 = SkillData.Instance:GetRoleTalentSkillCfg(max_skill_cfg.talent_id, max_skill_cfg.level + 1)
	elseif max_skill_cfg.level >= max_skill_cfg.max_level then
		show_state = 2
		self.node_list["Title1"].text.text = Language.Player.TitleNameNow
		skill_text_1 = SkillData.Instance:GetRoleTalentSkillCfg(max_skill_cfg.talent_id, max_skill_cfg.level)
		self.is_max_level = true
	else
		self.node_list["Title1"].text.text = Language.Player.TitleNameNow
		skill_text_1 = SkillData.Instance:GetRoleTalentSkillCfg(max_skill_cfg.talent_id, max_skill_cfg.level)
		skill_text_2 = SkillData.Instance:GetRoleTalentSkillCfg(max_skill_cfg.talent_id, max_skill_cfg.level + 1)
	end
	self.node_list["NowSkillText"].text.text = skill_text_1 and skill_text_1.desc or ""
	self.node_list["NextSkillText"].text.text = skill_text_2 and skill_text_2.desc or Language.Common.MaxLvTips
	UI:SetButtonEnabled(self.node_list["UpgradeBtn"], not self.is_max_level)
	local str = ""
	str = self.is_max_level and Language.Common.YiManJi or Language.Common.UpGrade
	self.node_list["TxtUpBtn"].text.text = str

	local need_desc1, need_desc2 = "", ""
	local skill_cfg = show_state ~= 0 and skill_text_1 or skill_text_2
	if nil == skill_cfg then return end

	if skill_cfg.pre_talent_type ~= 0 and skill_cfg.pre_talent_type_level ~= 0 then
		local type_all_level = SkillData.Instance:GetRoleTalentSkillTypeLevel(skill_cfg.pre_talent_type)
		local text_color = type_all_level < skill_cfg.pre_talent_type_level and COLOR.RED or TEXT_COLOR.GREEN
		type_all_level = ToColorStr(type_all_level, text_color)
		need_desc1 = string.format(Language.Player.NeedText, Language.Player.NeedSkillType[self.skill_type], type_all_level, skill_cfg.pre_talent_type_level)
	end

	if skill_cfg.pre_talent_id ~= 0 and skill_cfg.pre_talent_level ~= 0 then
		local skill_level = SkillData.Instance:GetRoleTalentSkillLevel(skill_cfg.pre_talent_id) or 0
		local skill_name = SkillData.Instance:GetRoleTalentSkillName(skill_cfg.pre_talent_id) or ""
		local skill_color = skill_level < skill_cfg.pre_talent_level and COLOR.RED or TEXT_COLOR.GREEN
		skill_level = ToColorStr(skill_level, skill_color)
		need_desc2 = string.format(Language.Player.NeedText, skill_name, skill_level, skill_cfg.pre_talent_level)
	end

	if skill_cfg.talent_type == 4 and skill_cfg.pre_talent_type == 0 then
		local type_all_level = SkillData.Instance:GetRoleTalentAllSkillType()
		local limit_num = SkillData.Instance:GetRoleTalentSkillResetItem().proficient_talent_limit
		local skill_color = type_all_level < limit_num and COLOR.RED or ""
		type_all_level = ToColorStr(type_all_level, skill_color)
		need_desc1 = string.format(Language.Player.NeedText, Language.Player.NeedSkillTypeJtTf, type_all_level, limit_num)
	end

	self.node_list["SkillNeed1"].text.text = need_desc1
	self.node_list["SkillNeed2"].text.text = need_desc2
end

function PlayerInnateSkillView:FlushAllSkillIcon()
	if self.skill_item_list and self.skill_item_list[self.skill_type] then
		if self.skill_type == 1 then
			for i = 1, ATK_SKILL_NUM do
				self.skill_item_list[self.skill_type]:FlushSkillIcon(i)
			end
		elseif self.skill_type == 2 then
			for i = 1, DEF_SKILL_NUM do
				self.skill_item_list[self.skill_type]:FlushSkillIcon(i)
			end
		elseif self.skill_type == 3 then
			for i = 1, COMMON_SKILL_NUM do
				self.skill_item_list[self.skill_type]:FlushSkillIcon(i)
			end
		-- elseif self.skill_type == 4 then
		-- 	for i = 1, PRO_SKILL_NUM do
		-- 		self.skill_item_list[self.skill_type]:FlushSkillIcon(i)
		-- 	end
		end
		self.skill_item_list[self.skill_type]:SetSkillData(self.skill_index)
	end
end

function PlayerInnateSkillView:FlushSkillIcon()
	self:FlushAllSkillIcon()
end


function PlayerInnateSkillView:OnClickSkillIcon(skill_type, skill_index)
	self.skill_type = skill_type
	self.skill_index = skill_index
	self:FlushExplain()
	self:FlushSkillIcon()
end

function PlayerInnateSkillView:DoPanelTweenPlay()
	local ui_cfg = PlayerData.Instance:GetUITweenCfg(TabIndex.role_innate_skill)
	UITween.MoveShowPanel(self.node_list["LeftView"], ui_cfg["LeftPanel"], ui_cfg["MOVE_TIME"], DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["BottumView"], ui_cfg["DownPanel"], ui_cfg["MOVE_TIME"], DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["RightView"], ui_cfg["RightPanel"], ui_cfg["MOVE_TIME"], DG.Tweening.Ease.InOutSine)
	UITween.AlpahShowPanel(self.node_list["SkillList"] , true , MOVE_TIME , DG.Tweening.Ease.InExpo)
end

function PlayerInnateSkillView:FlushRedPoint()
	for i = 1, 4 do
		local cont_num = SkillData.Instance:GetRoleTalentSkillTypeLevel(i)
		local max_num = SkillData.Instance:GetTalentCfgSkillCount(i)
		local skill_point_num = SkillData.Instance:GetRoleTalentPoint()
		self.node_list["RedPoint" .. i]:SetActive(cont_num < max_num and skill_point_num > 0)
	end
end

-------------------第一页--------------------
InnateSkillOneItemRender = InnateSkillOneItemRender or BaseClass(BaseRender)
function InnateSkillOneItemRender:__init(instance, parent, skill_type)
	self.parent = parent
	self.skill_type = skill_type
	self.skill_index = 1

	self.skill_icon = {}
	local res_async_loader = AllocResAsyncLoader(self, "item_res_async_loader")
	res_async_loader:Load("uis/views/player_prefab",  "SkillIcon", nil, function(prefab)
		if prefab then
			for i = 1, ATK_SKILL_NUM do
				local obj = ResMgr:Instantiate(prefab)
				local object = U3DObject(obj)
				object.transform:SetParent(self.node_list["Skill" .. i].transform, false)

				self.skill_icon[i] = InnateSkillIcon.New(obj)
				self.skill_icon[i]:SetToggleGroup(self.parent.node_list["AtkList"].toggle_group)
				self.skill_icon[i]:SetTypeIndex(self.skill_type, i)
				self.skill_icon[i]:ListenAllEvent(self.parent)
			end
		end
	end)

end

function InnateSkillOneItemRender:__delete()
	for k,v in pairs(self.skill_icon) do
		v:DeleteMe()
	end
	self.skill_icon = nil
end

function InnateSkillOneItemRender:SetSkillData(skill_data)
	if self.skill_icon[skill_data] then
		self.skill_icon[skill_data]:SetSkillData(skill_data)
	end
end

function InnateSkillOneItemRender:FlushSkillIcon(skill_index)
	if self.skill_icon[skill_index] then
		self.skill_icon[skill_index]:Flush()
		self.skill_icon[skill_index]:FlushHL()
	end
end

-------------------第二页--------------------
InnateSkillTwoItemRender = InnateSkillTwoItemRender or BaseClass(BaseRender)
function InnateSkillTwoItemRender:__init(instance, parent, skill_type)
	self.parent = parent
	self.skill_type = skill_type
	self.skill_index = 1

	self.skill_icon = {}
	local res_async_loader = AllocResAsyncLoader(self, "item_res_async_loader")
	res_async_loader:Load("uis/views/player_prefab",  "SkillIcon", nil, function(prefab)
		if prefab then
			for i = 1, DEF_SKILL_NUM do
				local obj = ResMgr:Instantiate(prefab)
				local object = U3DObject(obj)
				object.transform:SetParent(self.node_list["Skill" .. i].transform, false)

				self.skill_icon[i] = InnateSkillIcon.New(obj)
				self.skill_icon[i]:SetToggleGroup(self.parent.node_list["DefList"].toggle_group)
				self.skill_icon[i]:SetTypeIndex(self.skill_type, i)
				self.skill_icon[i]:ListenAllEvent(self.parent)
			end
		end
	end)
end

function InnateSkillTwoItemRender:__delete()
	for k,v in pairs(self.skill_icon) do
		v:DeleteMe()
	end
	self.skill_icon = nil
end

function InnateSkillTwoItemRender:SetSkillData(skill_data)
	if self.skill_icon[skill_data] then
		self.skill_icon[skill_data]:SetSkillData(skill_data)
	end
end

function InnateSkillTwoItemRender:SetSkillType(skill_type)
	self.skill_type = skill_type
end

function InnateSkillTwoItemRender:FlushSkillIcon(skill_index)
	if self.skill_icon[skill_index] then
		self.skill_icon[skill_index]:Flush()
		self.skill_icon[skill_index]:FlushHL()
	end
end

-------------------第三页--------------------
InnateSkillThreeItemRender = InnateSkillThreeItemRender or BaseClass(BaseRender)

function InnateSkillThreeItemRender:__init(instance, parent, skill_type)
	self.parent = parent
	self.skill_type = skill_type
	self.skill_index = 1

	self.skill_icon = {}
	local res_async_loader = AllocResAsyncLoader(self, "item_res_async_loader")
	res_async_loader:Load("uis/views/player_prefab",  "SkillIcon", nil, function(prefab)
		if prefab then
			for i = 1, COMMON_SKILL_NUM do
				local obj = ResMgr:Instantiate(prefab)
				local object = U3DObject(obj)
				object.transform:SetParent(self.node_list["Skill" .. i].transform, false)

				self.skill_icon[i] = InnateSkillIcon.New(obj)
				self.skill_icon[i]:SetToggleGroup(self.parent.node_list["CommonList"].toggle_group)
				self.skill_icon[i]:SetTypeIndex(self.skill_type, i)
				self.skill_icon[i]:ListenAllEvent(self.parent)
			end
		end
	end)
end

function InnateSkillThreeItemRender:__delete()
	for k,v in pairs(self.skill_icon) do
		v:DeleteMe()
	end
	self.skill_icon = nil
end

function InnateSkillThreeItemRender:SetSkillData(skill_data)
	if self.skill_icon[skill_data] then
		self.skill_icon[skill_data]:SetSkillData(skill_data)
	end
end

function InnateSkillThreeItemRender:SetSkillType(skill_type)
	self.skill_type = skill_type
end

function InnateSkillThreeItemRender:FlushSkillIcon(skill_index)
	if self.skill_icon[skill_index] then
		self.skill_icon[skill_index]:Flush()
		self.skill_icon[skill_index]:FlushHL()
	end
end

-------------------第四页--------------------
InnateSkillFourItemRender = InnateSkillFourItemRender or BaseClass(BaseRender)

function InnateSkillFourItemRender:__init(instance, parent, skill_type)
	self.parent = parent
	self.skill_type = skill_type
	self.skill_index = 1

	self.skill_icon = {}
	local res_async_loader = AllocResAsyncLoader(self, "item_res_async_loader")
	res_async_loader:Load("uis/views/player_prefab",  "SkillIcon", nil, function(prefab)
		if prefab then
			for i = 1, PRO_SKILL_NUM do
				local obj = ResMgr:Instantiate(prefab)
				local object = U3DObject(obj)
				object.transform:SetParent(self.node_list["Skill" .. i].transform, false)
				self.skill_icon[i] = InnateSkillIcon.New(obj)
				self.skill_icon[i]:SetToggleGroup(self.parent.node_list["ProList"].toggle_group)
				self.skill_icon[i]:SetTypeIndex(self.skill_type, i)
				self.skill_icon[i]:ListenAllEvent(self.parent)
			end
		end
	end)
end

function InnateSkillFourItemRender:__delete()
	for k,v in pairs(self.skill_icon) do
		v:DeleteMe()
	end
	self.skill_icon = nil
end

function InnateSkillFourItemRender:SetSkillData(skill_data)
	if self.skill_icon[skill_data] then
		self.skill_icon[skill_data]:SetSkillData(skill_data)
	end
end

function InnateSkillFourItemRender:SetSkillType(skill_type)
	self.skill_type = skill_type
end

function InnateSkillFourItemRender:FlushSkillIcon(skill_index)
	if self.skill_icon[skill_index] then
		self.skill_icon[skill_index]:Flush()
		self.skill_icon[skill_index]:FlushHL()
	end
end

-------------------技能图标--------------------
InnateSkillIcon = InnateSkillIcon or BaseClass(BaseRender)
function InnateSkillIcon:__init()
	self.skill_type = 1
	self.skill_index = 1
end

function InnateSkillIcon:__delete()

end

function InnateSkillIcon:SetTypeIndex(skill_type, skill_index)
	self.skill_type = skill_type
	self.skill_index = skill_index

	self:Flush()
	self:FlushHL()
end

function InnateSkillIcon:SetSkillData(skill_data)
	self.skill_data = skill_data
	self.node_list["SkillIcon"].toggle.isOn = true
end

function InnateSkillIcon:FlushHL()
	if self.skill_index == 1 then
		self.node_list["SkillIcon"].toggle.isOn = true
	end
end

function InnateSkillIcon:OnFlush()
	local icon_index_cfg = SkillData.Instance:GetUseWarSceneSkill(self.skill_type, self.skill_index)
	local asset, bundle
	if icon_index_cfg then
		asset, bundle = ResPath.GetInnateSkillImage(self.skill_type, icon_index_cfg.icon)
	else
		asset, bundle = ResPath.GetInnateSkillImage(self.skill_type, self.skill_index)
	end
	 
	self.node_list["Image"].image:LoadSprite(asset, bundle)
	local max_skill_cfg_list = SkillData.Instance:SetRoleTalentLevelList(self.skill_type)
	local max_skill_cfg = max_skill_cfg_list[self.skill_index]
	if max_skill_cfg then
		UI:SetGraphicGrey(self.node_list["Image"], max_skill_cfg.level <= 0)
		self.node_list["SkillIconLevel"].text.text = string.format(Language.Player.IconLevel, max_skill_cfg.level, max_skill_cfg.max_level)
	end
end

function InnateSkillIcon:ListenAllEvent(parent)
	self.node_list["SkillIcon"].toggle:AddClickListener(BindTool.Bind(function()
			parent:OnClickSkillIcon(self.skill_type, self.skill_index)
		end, self))

	if self.skill_index == 1 then
		parent:OnClickSkillIcon(self.skill_type, self.skill_index)
	end
end

function InnateSkillIcon:SetToggleGroup(group)
  	self.root_node.toggle.group = group
end
PlayerSkillView = PlayerSkillView or BaseClass(BaseRender)

local EFFECT_CD = 0.8
local PROFESSOIN_SKILL_NUM = 5 	-- 主动技能数
local PASSIVE_SKILL_NUM = 7 	-- 被动技能数
local KILL_SKILL_ID = 5			-- 必杀技ID
local MIESHI_SKILL_NUM = 3		-- 灭世技能数

local PASSVIE_SKILL_ID_STAR = 41	-- 被动技能起始ID
local PASSVIE_SKILL_ID_END = 47		-- 被动技能结束ID
local MOJING_ID = 90002             --魔晶ID

function PlayerSkillView:__init(instance, parent_view)
	self.node_list["BtnUpgrade"].button:AddClickListener(BindTool.Bind(self.OnClickUpgradeButtonPro, self, true))
	self.node_list["UpgradeButton"].button:AddClickListener(BindTool.Bind(self.OnClickUpgradeButton, self))
	self.node_list["ProfessionSkilButton"].toggle:AddClickListener(BindTool.Bind(self.OnClickProfessionButton, self))
	self.node_list["PassiveSkilButton"].toggle:AddClickListener(BindTool.Bind(self.OnClickPassiveButton, self))
	self.node_list["BtnStop"].button:AddClickListener(BindTool.Bind(self.StopLevelUp, self))
	self.node_list["BtnSkillInfoStop"].button:AddClickListener(BindTool.Bind(self.StopLevelUp, self))
	self.node_list["AllUpGradeBtn2"].button:AddClickListener(BindTool.Bind(self.OnAllUpGradeBtn, self, 1))
	self.node_list["AllUpGradeBtn1"].button:AddClickListener(BindTool.Bind(self.OnAllUpGradeBtn, self))

	for i = 1, 3 do
		self.node_list["MieShiSkill" .. i].toggle:AddClickListener(BindTool.Bind(self.OnClickMieShi, self, i))
	end
	
	self.mieshi_info_cfg = ConfigManager.Instance:GetAutoConfig("rolegoalconfig_auto").skill
	self.parent_view = parent_view

	self.node_list["BtnUpgrade"]:SetActive(true)
	self.node_list["BtnStop"]:SetActive(false)
	self.node_list["UpgradeButton"]:SetActive(true)
	self.node_list["BtnSkillInfoStop"]:SetActive(false)


	self.passive_index = 7
	self.last_passive_index = 7
	self.profession_skill = {}							-- 职业技能,职业技能列表的第五个 为必杀技能
	self.passive_skill = {}								-- 被动技能
	self.profession_skill_data = {}
	self.passive_skill_data = {}
	self.mieshi_skill = {}
	for i = 1, PROFESSOIN_SKILL_NUM do       ----5
		local skill = self.node_list["ProSkill" .. i]
		local icon = self.node_list["ActiveSkillIcon" .. i]
		local name_lable = skill.transform:FindHard("SkillNameLable")
		local skill_name = name_lable.transform:FindHard("Name")
		local skill_level = name_lable.transform:FindHard("Level")
		local arrow = skill.transform:FindHard("Arrow")
		table.insert(self.profession_skill, {skill = skill, icon = icon,
					 name_lable = name_lable, skill_name = skill_name, skill_level = skill_level, arrow = arrow,})
	end

	for i = 1, PASSIVE_SKILL_NUM do
		local skill = self.node_list["PassiveSkill" .. i]
		local icon = self.node_list["PassiveSkillIcon" .. i]
		local name_lable = skill.transform:FindHard("SkillNameLable")
		local skill_name = name_lable.transform:FindHard("Name")
		local skill_level = name_lable.transform:FindHard("Level")
		local arrow = skill.transform:FindHard("Arrow")
		local effect = skill.transform:FindHard("UI_Effect")
		local animator = arrow:GetComponent(typeof(UnityEngine.Animator))
		table.insert(self.passive_skill, {skill = skill, icon = icon, name_lable = name_lable, skill_name = skill_name, skill_level = skill_level,arrow = arrow, animator = animator, effect = effect})
	end

	for i = 1, MIESHI_SKILL_NUM do
		local skill = self.node_list["MieShiSkill" .. i]
		local arrow = skill.transform:FindHard("Arrow")
		local effect = skill.transform:FindHard("UI_Effect")
		local skill_level = skill.transform:FindHard("MieShiLevel" .. i)
		table.insert(self.mieshi_skill, {skill = skill, arrow = arrow, effect = effect, skill_level = skill_level})
	end

	self.profession_skill_data, self.passive_skill_data = self:InitAllSkillList()
	self.index = 1
	self.temp_skill_id = 0
	self:AddSkillListenEvent()
	self.node_list["ProfessionSkilButton"].toggle.isOn = false
	self.node_list["PassiveSkilButton"].toggle.isOn = true
	self.is_click_skill = false
	self.attack_hit_handle = {}
	self.passive_level_list = {}
	self.effect_cd = 0
	self.auto_level_up = false
	self.is_set_model = false
	self.cur_toggle_state = -1
	self.is_skill_or_mieshi = false
	self.is_index = 0
	self.is_can = false

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.PlayerSkill)

	self.mieshi_skill_level_list = PlayerData.Instance:GetSkillLevelList()

	self:FlushMieShiSkillView()
	--self.node_list["ContentText2"]:SetActive(false)
	
	--local mojing = ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.MOJING)
end



function PlayerSkillView:LoadCallBack()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
end

function PlayerSkillView:__delete()
	RemindManager.Instance:UnBind(self.remind_change)
	self.is_index = nil
	self.parent_view = nil
	self.index = nil
	self.temp_skill_id = nil
	self.profession_skill = nil							-- 职业技能,职业技能列表的第五个 为必杀技能
	self.passive_skill = nil								-- 被动技能
	self.profession_skill_data = nil
	self.passive_skill_data = nil
	self.is_init_exp_radio = nil
	self.is_click_skill = nil
	self.is_set_model = nil
	self.passive_level_list = {}
	self.profession_skill = {}							-- 职业技能,职业技能列表的第五个 为必杀技能
	self.passive_skill = {}								-- 被动技能
	self.profession_skill_data = {}
	self.passive_skill_data = {}
	self.mieshi_skill = {}
	if self.go then
		ResMgr:Destroy(self.go.gameObject)
	end
	for k, v in pairs(self.attack_hit_handle) do
		v:Dispose()
	end

	self.attack_hit_handle = {}
	self:StopLevelUp()
	self:RemoveCountDown()

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function PlayerSkillView:InitAllSkillList()
	local profession_skill_data = {}
	local passive_skill_data = {}
	local roleskill_auto = ConfigManager.Instance:GetAutoConfig("roleskill_auto")
	local skillinfo = roleskill_auto.skillinfo
	local prof = PlayerData.Instance:GetRoleBaseProf()

	for skill_id, v in pairs(skillinfo) do

		if prof == math.modf(skill_id / 100) then
			profession_skill_data[v.skill_index] = v
		elseif skill_id == KILL_SKILL_ID then
			profession_skill_data[v.skill_index] = v
		end
		for i = PASSVIE_SKILL_ID_STAR, PASSVIE_SKILL_ID_END do
			if i == skill_id then
				passive_skill_data[v.skill_index] = v
			end
		end
	end
	return profession_skill_data, passive_skill_data
end

-- 灭世技能
function PlayerSkillView:OnClickMieShi(index)
	self.node_list["TxtUpgradeBtn"]:SetActive(true)
	self.node_list["TxtUpgradeBtn1"]:SetActive(false)
	self.node_list["TxtSkillInfoUpgradeBtn"]:SetActive(true)
	self.node_list["TxtSkillInfoUpgradeBtn1"]:SetActive(false)
	self.is_skill_or_mieshi = true
	--self.index = index
	self.node_list["UpgradeButton"]:SetActive(true)
	-- self.node_list["TxtFightPowerLabel"]:SetActive(true)
	--self.node_list["TxtFightPowerLabel2"]:SetActive(false)
	self.node_list["NoteNextEffect"]:SetActive(true)
	self.node_list["NoteNextEffect2"]:SetActive(true)
	self.node_list["TxtMieShiLevel"]:SetActive(false)
	self.node_list["TxtNeedConsumeLevel"]:SetActive(false)
	self.node_list["TxtTitle"]:SetActive(true)
	local level_info = {}
	--index = index --+ PASSIVE_SKILL_NUM
	for k,v in pairs(self.mieshi_info_cfg) do
		if v.skill_type == index then
			self.node_list["TxtPassSkillName"].text.text = v.skill_name
			self.node_list["TxtFightPowerTitleSkillName"].text.text = v.skill_name
			self.node_list["TxtPassSkillName2"].text.text = v.skill_name
			self.node_list["TxtFightPowerTitleSkillName2"].text.text = v.skill_name
			table.insert(level_info, v)
		end
	end
	level_info = ListToMapList(level_info, "skill_level")
	self.mieshi_skill_level_list = PlayerData.Instance:GetSkillLevelList()
	self.is_index = index
	local current_level = self.mieshi_skill_level_list[index]
	--current_level = 100
	if current_level > 0 then
		--如果有等级
		self.node_list["NoteCurrentEffect"]:SetActive(true)
		self.node_list["NoteCurrentEffect2"]:SetActive(true)
		--self.node_list["UnActiveCurrentEffect"]:SetActive(false)

		local desc = ""
		desc = string.gsub(level_info[current_level][1].skill_desc2, "%[.-%]" , function(str)
			return tonumber(level_info[current_level][1][string.sub(str, 2, -2)]) / 100
		 end)
		self.node_list["TxtCurrentEffect"].text.text = desc
		self.node_list["TxtCurrentEffect1"].text.text = desc
		self.node_list["ContentText2"]:SetActive(false)
		
		-- self.node_list["TxtFightPowerNumber"].text.text = level_info[current_level][1].capability
		self.node_list["TxtFightPowerNumber2"].text.text = level_info[current_level][1].capability
		--如果最高级
		if current_level >= #level_info then

			self.node_list["NoteNextEffect"]:SetActive(false)
			self.node_list["NoteNextEffect2"]:SetActive(false)
			current_level = current_level - 1 
		end
		desc = string.gsub(level_info[current_level + 1][1].skill_desc2, "%[.-%]" , function(str)
			return tonumber(level_info[current_level + 1][1][string.sub(str, 2, -2)]) / 100
		 end)
		current_level = self.mieshi_skill_level_list[index]
		self.node_list["TxtNextEffect"].text.text = desc
		self.node_list["TxtSkillEffect"].text.text = desc
		self.node_list["TxtLevel"].text.text = string.format("%s/%s", current_level, #level_info)
		self.node_list["TxtNeedConsumeLevel2"].text.text = string.format("%s/%s", current_level, #level_info)
	else
		--未升级
		local desc = ""
		desc = string.gsub(level_info[current_level + 1][1].skill_desc2, "%[.-%]" , function(str)
			return tonumber(level_info[current_level + 1][1][string.sub(str, 2, -2)]) / 100
		 end)
		self.node_list["NoteCurrentEffect"]:SetActive(false)
		self.node_list["NoteCurrentEffect2"]:SetActive(false)
		--self.node_list["UnActiveCurrentEffect"]:SetActive(false)
		self.node_list["TxtNextEffect"].text.text = desc
		self.node_list["TxtSkillEffect"].text.text = desc
		self.node_list["TxtLevel"].text.text = string.format("%s/%s", 0, #level_info)
		self.node_list["TxtNeedConsumeLevel2"].text.text = string.format("%s/%s", 0, #level_info)
		self.node_list["TxtFightPowerNumber2"].text.text = 0
	end
	if current_level >= #level_info then
		current_level = current_level - 1 
	end
	self.node_list["TxtSkillInfoFightPowerNum"].text.text = level_info[current_level + 1][1].capability
	self.node_list["TxtSkillInfoNum"].text.text = level_info[current_level + 1][1].capability
	self.node_list["TxtLevel"].text.text = string.format("%s/%s", current_level, #level_info)
	self.node_list["TxtNeedConsumeLevel2"].text.text = string.format("%s/%s", current_level, #level_info)

	local role_prof = PlayerData.Instance:GetRoleBaseProf()
	local material_info = level_info[current_level][1]["uplevel_stuff_prof"..role_prof]
	local item_id = material_info.item_id
	local have_count = ItemData.Instance:GetItemNumInBagById(tonumber(item_id))
	local need_count = material_info.num
	local data = {item_id = item_id}
	self.item_cell:SetData(data)

	if have_count >= need_count then
		self.node_list["TxtTitle"].text.text = ToColorStr(have_count, TEXT_COLOR.GREEN_4) .. ToColorStr(" / " .. need_count, TEXT_COLOR.GREEN_4)
	else
		self.node_list["TxtTitle"].text.text = ToColorStr(have_count, TEXT_COLOR.RED) .. ToColorStr(" / " .. need_count, TEXT_COLOR.GREEN_4)
	end
	self:FlushMieShiSkillView()
end

-- 灭世技能信息
function PlayerSkillView:SetMieShiSkillInfo(index)
	local cfg = ConfigManager.Instance:GetAutoConfig("rolegoalconfig_auto").battlefield_goal or {}
	local desc = ""
	local single_cfg = CollectiveGoalsData.Instance:GetGoalsSingleCfg(index )-- PASSIVE_SKILL_NUM)

	if single_cfg and next(single_cfg) then
		desc = string.gsub(single_cfg.skill_desc2, "%b()%%" , function(str)
			return tonumber(single_cfg[string.sub(str, 2, -3)]) / 1000
		end)
		desc = string.gsub(desc, "%b[]%%" , function(str)
			return tonumber(single_cfg[string.sub(str, 2, -3)]) / 100 .. "%"
		end)
		desc = string.gsub(desc, "%[.-%]" , function(str)
			return single_cfg[string.sub(str, 2, -2)]
		end)

		-- 技能名字
		self.node_list["TxtPassSkillName"].text.text = single_cfg.skill_name
		self.node_list["TxtFightPowerTitleSkillName"].text.text = single_cfg.skill_name
		self.node_list["TxtPassSkillName2"].text.text = single_cfg.skill_name
		self.node_list["TxtFightPowerTitleSkillName2"].text.text = single_cfg.skill_name
		local ser_day = TimeCtrl.Instance:GetCurOpenServerDay()
		local is_active = CollectiveGoalsData.Instance:IsGetRewardBySeq(single_cfg.act_sep) or ser_day > single_cfg.open_server_day
		self.node_list["TxtMieShiInfo"].text.text = desc
		local cur_level = string.format(Language.Mount.ShowRedStr, 0)
		self.node_list["TxtMieShiLevel"].text.text = string.format(Language.Player.MieShiLevel, cur_level.."/1")
	end
end

function PlayerSkillView:FlushMieShiSkillView()
	for i = 8, 10 do
		self:FlushMieShiSkillIcon(i)
	end
end

-- 灭世技能图标
function PlayerSkillView:FlushMieShiSkillIcon(index)
	local mieshi_siki_index = index - PASSIVE_SKILL_NUM
	self.mieshi_skill_level_list = PlayerData.Instance:GetSkillLevelList()
	local current_level = self.mieshi_skill_level_list[mieshi_siki_index]
	local bundle, asset = ResPath.GetSkillGoalsIcon(mieshi_siki_index)
	self.node_list["ImgIcon" .. index].image:LoadSprite(bundle, asset .. ".png")

	UI:SetGraphicGrey(self.node_list["ImgIcon" .. index], current_level <= 0)
	local level_info = {}
	for k,v in pairs(self.mieshi_info_cfg) do
		if v.skill_type == mieshi_siki_index then
			table.insert(level_info, v)
		end
	end
	level_info = ListToMapList(level_info, "skill_level")
	local role_prof = PlayerData.Instance:GetRoleBaseProf()
	local level = 0
	if current_level >= #level_info then
		level = current_level - 1
	else
		level = current_level
	end

	local material_info = level_info[level][1]["uplevel_stuff_prof"..role_prof]
	if not material_info then return end
	local item_id = material_info.item_id
	local have_count = ItemData.Instance:GetItemNumInBagById(tonumber(item_id))
	local need_count = material_info.num
	if current_level < #level_info and need_count <= have_count then
		self.mieshi_skill[mieshi_siki_index].arrow.gameObject:SetActive(true)
	else
		self.mieshi_skill[mieshi_siki_index].arrow.gameObject:SetActive(false)
	end
	self.mieshi_skill[mieshi_siki_index].skill_level:GetComponent(typeof(UnityEngine.UI.Text)).text = "Lv：" .. level
end

function PlayerSkillView:AddSkillListenEvent()
	for k, v in pairs(self.profession_skill) do
		v.skill.toggle:AddClickListener(BindTool.Bind(self.OnClickSkill, self,
			self.profession_skill_data[k].skill_icon, self.profession_skill_data[k].skill_id,
			self.profession_skill_data[k].skill_name, k, false, 0.4))
	end
	for k, v in pairs(self.passive_skill) do
		v.skill.toggle:AddClickListener(BindTool.Bind(self.OnClickSkill, self,
			self.passive_skill_data[k].skill_icon, self.passive_skill_data[k].skill_id,
			self.passive_skill_data[k].skill_name, k, true, 0.4))
	end
	if self.node_list["ProfessionSkilButton"].toggle.isOn then
		self:OnClickSkill(self.profession_skill_data[self.index].skill_icon,
		self.profession_skill_data[self.index].skill_id, self.profession_skill_data[self.index].skill_name, self.index, false, 0.4)
		self.profession_skill[self.index].skill.toggle.isOn = true
	else
		self:GetSkillInfo(self.passive_skill_data[self.index].skill_id, self.passive_skill_data[self.index].skill_name, self.index)
		self.passive_skill[self.index].skill.toggle.isOn = true
	end
end

function PlayerSkillView:OnClickSkill(skill_icon, skill_id, skill_name, index, is_passive, delay_play_skill_time)
	self.is_skill_or_mieshi = false
	self.node_list["TxtUpgradeBtn"]:SetActive(false)
	self.node_list["TxtUpgradeBtn1"]:SetActive(true)
	self.node_list["TxtSkillInfoUpgradeBtn"]:SetActive(false)
	self.node_list["TxtSkillInfoUpgradeBtn1"]:SetActive(true)
	-- 显示升级按钮
	self.node_list["UpgradeButton"]:SetActive(true)
	self.node_list["NoteMieShiInfo"]:SetActive(false)
	self.node_list["TxtMieShiLevel"]:SetActive(false)
	self.node_list["TxtNeedConsumeLevel"]:SetActive(false)

	if is_passive then
		-- 显示材料
		self.node_list["TxtTitle"]:SetActive(true)
		-- 显示战力
		-- self.node_list["TxtFightPowerLabel"]:SetActive(false)
		--self.node_list["TxtFightPowerLabel2"]:SetActive(true)

		if self.auto_level_up then
			local temp_skill_id = self.passive_skill_data[self.last_passive_index].skill_id
			local skill_cfg = ConfigManager.Instance:GetAutoConfig("roleskill_auto")["s"..temp_skill_id]
			local skill_info = SkillData.Instance:GetSkillInfoById(temp_skill_id)
			local level = skill_info and skill_info.level + 1 or 1
			local item_id = skill_cfg[level] and skill_cfg[level].item_cost_id or 0
			local cost_num = skill_cfg[level] and skill_cfg[level].item_cost or -1
			local index_list = SkillData.Instance:GetPassvieSkillCanUpLevelIndexList(self.passive_skill_data)
			self.node_list["NeedTxt"].text.text =string.format(Language.Player.NeedLevel, skill_cfg[level + 1].learn_level_limit) 
		
			if (level <= 100 and cost_num <= ItemData.Instance:GetItemNumInBagById(item_id)) or (nil == skill_cfg[level] and nil == next(index_list)) then
				self:StopLevelUp()
			end
		end
		self.passive_index = index
	end

	if self.temp_skill_id ~= skill_id then
		self:StopLevelUp()
	end

	self.index = index
	self.temp_skill_id = skill_id
	self.is_click_skill = true
	self:GetSkillInfo(skill_id, skill_name, index)
	if nil ~= self.skill_delay_timer then
		GlobalTimerQuest:CancelQuest(self.skill_delay_timer)
	end
	self.skill_delay_timer = GlobalTimerQuest:AddDelayTimer(function()
		self:OnClickPlayButton(self.index)
	end, delay_play_skill_time)
end

--全部升级
function PlayerSkillView:OnAllUpGradeBtn(index)
	local is_all_max = 0
	local is_all_less = 0
	local skill_tab = {}
	skill_tab = index == 1 and self.profession_skill_data or self.passive_skill_data


	for k, v in pairs(skill_tab) do
		local skill_cfg = ConfigManager.Instance:GetAutoConfig("roleskill_auto")["s".. v.skill_id] 
		local skill_info = SkillData.Instance:GetSkillInfoById(v.skill_id)
		if not skill_cfg and not skill_info then return end

		local level = skill_info and skill_info.level + 1 or 1
		if level >= skill_cfg[#skill_cfg].skill_level then
			is_all_max = is_all_max + 1
		else
			local item_id = skill_cfg[level].item_cost_id
			if skill_cfg[level].item_cost > ItemData.Instance:GetItemNumInBagById(item_id) then
				is_all_less = is_all_less + 1
			end
		end
	end

	if is_all_max >= #skill_tab then
		SysMsgCtrl.Instance:ErrorRemind(Language.Player.MaxLevel)
		return
	elseif (is_all_less + is_all_max) >= #skill_tab then
		SysMsgCtrl.Instance:ErrorRemind(Language.Player.SkillCostItemAllLess)
		return
	end

	if index == 1 then
		SkillCtrl.Instance:SendRoleSkillLearnReq(0, UPLEVEL_SKILL_TYPE.UPLEVEL_ACTIVE_SKILL_ALL)
	else
		SkillCtrl.Instance:SendRoleSkillLearnReq(0, UPLEVEL_SKILL_TYPE.UPLEVEL_PASSIVE_SKILL_ALL)	
	end
end

function PlayerSkillView:OnClickUpgradeButtonPro()
		local skill_cfg = ConfigManager.Instance:GetAutoConfig("roleskill_auto")["s"..self.temp_skill_id]
		local skill_info = SkillData.Instance:GetSkillInfoById(self.temp_skill_id)
		local level = skill_info and skill_info.level + 1 or 1

		if level > #skill_cfg or nil == skill_cfg[level] then
			self:StopLevelUp()
			SysMsgCtrl.Instance:ErrorRemind(Language.Player.MaxLevel)
			return
		end
		if skill_cfg[level].mojing_cost > ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.MOJING) then
			self.is_can = false
			if not self.auto_level_up then
				TipsCtrl.Instance:ShowItemGetWayView(MOJING_ID)
			end
			self:StopLevelUp()
			local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[MOJING_ID]
			if item_cfg == nil then
				return
			end
			if item_cfg.bind_gold == 0 then
				TipsCtrl.Instance:ShowShopView(MOJING_ID, 2)
				return
			end
			local func = function(item_id2, item_num, is_bind, is_use)
				MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
			end
			TipsCtrl.Instance:ShowCommonBuyView(func, MOJING_ID, nil,
				(MOJING_ID - ItemData.Instance:GetItemNumInBagById(MOJING_ID)))

		else
			self.node_list["BtnUpgrade"]:SetActive(false)
			self.node_list["BtnStop"]:SetActive(true)
			SkillCtrl.Instance:SendRoleSkillLearnReq(self.temp_skill_id, UPLEVEL_SKILL_TYPE.UPLEVEL_SKILL)
			self.is_can = true
			if self.is_can then
				self:RemoveCountDown()
				self.delay_time1 = GlobalTimerQuest:AddDelayTimer(function()
					if self.is_can then
						self:OnClickUpgradeButtonPro()
					end
						
				end, 0.3)
			end
			
		end
		self:FlushSkillInfo()
end

--点击升级按钮
function PlayerSkillView:OnClickUpgradeButton()
	if not self.is_skill_or_mieshi then
		local skill_cfg = ConfigManager.Instance:GetAutoConfig("roleskill_auto")["s"..self.temp_skill_id]
		local skill_info = SkillData.Instance:GetSkillInfoById(self.temp_skill_id)
		local level = skill_info and skill_info.level + 1 or 1

		if level > #skill_cfg or nil == skill_cfg[level] then
			self:StopLevelUp()
			SysMsgCtrl.Instance:ErrorRemind(Language.Player.MaxLevel)
			return
		end
		self:StopLevelUp()
		local item_id = skill_cfg[level].item_cost_id
		if skill_cfg[level].item_cost > ItemData.Instance:GetItemNumInBagById(item_id)  then
			if not self.auto_level_up then
				TipsCtrl.Instance:ShowItemGetWayView(item_id)
			end
			self:StopLevelUp()
			local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[item_id]
			if item_cfg == nil then
				return
			end
			if item_cfg.bind_gold == 0 then
				TipsCtrl.Instance:ShowShopView(item_id, 2)
				return
			end
			local func = function(item_id2, item_num, is_bind, is_use)
				MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
			end
			TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nil,
				(item_id - ItemData.Instance:GetItemNumInBagById(item_id)))
		else

			self.auto_level_up = true
			self.node_list["BtnUpgrade"]:SetActive(false)
			self.node_list["BtnStop"]:SetActive(true)
			self.node_list["UpgradeButton"]:SetActive(false)
			self.node_list["BtnSkillInfoStop"]:SetActive(true)
			SkillCtrl.Instance:SendRoleSkillLearnReq(self.temp_skill_id, UPLEVEL_SKILL_TYPE.UPLEVEL_SKILL)
	
			if self.auto_level_up then
					self:RemoveCountDown()
					self.delay_time = GlobalTimerQuest:AddDelayTimer(function()
						 if self.auto_level_up then
							self:OnClickUpgradeButton()
						 end 
					end, 0.3)
			end
		end
	else
		local index = self.is_index -- PASSIVE_SKILL_NUM
		local level_info = {}
		for k,v in pairs(self.mieshi_info_cfg) do
			if v.skill_type == index then
				table.insert(level_info, v)
			end
		end

		level_info = ListToMapList(level_info, "skill_level")
		self.mieshi_skill_level_list = PlayerData.Instance:GetSkillLevelList()
		local current_level = self.mieshi_skill_level_list[index]

		--如果最高等级
		if current_level < #level_info then
			local role_prof = PlayerData.Instance:GetRoleBaseProf()
			local prof = PlayerData.Instance:GetRoleBaseProf(role_prof)
			local material_info = level_info[current_level][1]["uplevel_stuff_prof"..prof]
			local item_id = material_info.item_id
			local have_count = ItemData.Instance:GetItemNumInBagById(tonumber(item_id))
			local need_count = material_info.num
			if have_count >= need_count then
				local passive_skill = self.mieshi_skill[index]
				if Status.NowTime - self.effect_cd > EFFECT_CD then
					passive_skill.effect.gameObject:SetActive(true)
					self.effect_cd = Status.NowTime
					GlobalTimerQuest:AddDelayTimer(function ()
						passive_skill.effect.gameObject:SetActive(false)
					end, 0.75)
				end
			end
		end
		PlayerCtrl.Instance:SendRoleGoalOperaReq(PERSONAL_GOAL_OPERA_TYPE.UPLEVEL_SKILL, self.is_index) --- PASSIVE_SKILL_NUM)
	end
	-- self:FlushSkillInfo()
end

function PlayerSkillView:StopLevelUp()
	self.auto_level_up = false
	self.is_can = false
	self.node_list["BtnUpgrade"]:SetActive(true)
	self.node_list["BtnStop"]:SetActive(false)
	self.node_list["UpgradeButton"]:SetActive(true)
	self.node_list["BtnSkillInfoStop"]:SetActive(false)
end

function PlayerSkillView:OnClickPlayButton(index)
	if PlayerCtrl.Instance.view:GetShowIndex() ~= TabIndex.role_skill then
		return
	end

	if not self.node_list["ProfessionSkilButton"].toggle.isOn or not self.profession_skill[self.index] or not self.profession_skill[self.index].skill.toggle.isOn then
		return
	end

	self.skill_index = index or self.index
	local skill_action = self.profession_skill_data[index].skill_action

	if self.profession_skill_data[index].hit_count == 1 then
		self:SetDefaultState()
		UIScene:SetTriggerValue(skill_action)
		UIScene:SetAnimation(skill_action)
	elseif self.profession_skill_data[index].hit_count == 3 then
		self:SetDefaultState()
		for i = 1, 3 do
			local normal_skill_action = skill_action.."_"..i
			UIScene:SetTriggerValue(normal_skill_action)
			UIScene:SetAnimation(normal_skill_action)
		end
	end
end

function PlayerSkillView:GetSkillInfo(skill_id, skill_name, index)
	if skill_id == 0 or skill_name == nil or index == nil then
		return
	end

	local skill_info = SkillData.Instance:GetSkillInfoById(skill_id)



	local skill_cfg = ConfigManager.Instance:GetAutoConfig("roleskill_auto")["s"..skill_id]
	self.node_list["TxtPassSkillName"].text.text = skill_name
	self.node_list["TxtFightPowerTitleSkillName"].text.text = skill_name
	self.node_list["TxtPassSkillName2"].text.text = skill_name
	self.node_list["TxtFightPowerTitleSkillName2"].text.text = skill_name
	self.node_list["NoteCurrentEffect"]:SetActive(skill_info ~= nil)
	self.node_list["NoteCurrentEffect2"]:SetActive(skill_info ~= nil)

	if skill_info == nil then
		self:SetSkillInfo(skill_cfg, index, nil, skill_info)
	else
		-- 客户端记录的技能等级，熟练度
		local proficient = SkillData.Instance:GetSkillProficiency(skill_id)
		local level = skill_info.level
		self:SetSkillInfo(skill_cfg, index, level, skill_info)
	end
end

-- 设置角色技能为0级时，右边技能信息的显示
function PlayerSkillView:SetSkillInfo(skill_cfg, index, level, skill_info, is_passive)
	local effect_level = level or 1
	local cur_level = level or 0
	local desc = ""
	local next_desc = ""
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local max_level = skill_cfg[#skill_cfg].skill_level

	self.node_list["TxtLevel"].text.text = string.format("%s/%s", cur_level, #skill_cfg)
	self.node_list["TxtNeedConsumeLevel2"].text.text = string.format("%s/%s", cur_level, #skill_cfg)
	if self.node_list["ProfessionSkilButton"].toggle.isOn and not is_passive then
		-- 主动技能
		for k, v in pairs(self.profession_skill) do
			local info = SkillData.Instance:GetSkillInfoById(self.profession_skill_data[k].skill_id)
			local skill_level = 0
			if info == nil then
				UI:SetGraphicGrey(v.icon, true)
			else
				local small_lieve = info.level
				if small_lieve == 0 then
					UI:SetGraphicGrey(v.icon, true)
				else
					UI:SetGraphicGrey(v.icon, false)
				end
				skill_level = info.level 
			end
			v.skill_name:GetComponent(typeof(UnityEngine.UI.Text)).text = self.profession_skill_data[k].skill_name
			v.skill_level:GetComponent(typeof(UnityEngine.UI.Text)).text = "Lv：" .. skill_level 
			if k == #self.profession_skill then
				v.skill_name:GetComponent(typeof(UnityEngine.UI.Text)).text = Language.Player["SkiiName" .. main_vo.prof]
			end

			if skill_level == max_level then
				v.skill_level:GetComponent(typeof(UnityEngine.UI.Text)).text = Language.Common.YiManJi
			end
			
			local bundle, asset = ResPath.GetRoleSkillIcon(self.profession_skill_data[k].skill_icon)
			if self.profession_skill_data[k].skill_id == KILL_SKILL_ID then
				local skill_icon = self.profession_skill_data[k].skill_icon + main_vo.prof
				
				if skill_icon >= 500004 then
					--图片缺少 TODO
					bundle, asset = ResPath.GetRoleSkillIcon(skill_icon - 1)
				else
					bundle, asset = ResPath.GetRoleSkillIcon(skill_icon)
				end
				
			end
			v.icon.image:LoadSprite(bundle, asset)
		end
		if not self.profession_skill_data[index] then return end
		desc = string.gsub(self.profession_skill_data[index].skill_desc, "%b()%%" , function(str)
			return tonumber(skill_cfg[effect_level][string.sub(str, 2, -3)]) / 1000
		end)
		desc = string.gsub(desc, "%b[]%%" , function(str)
			return tonumber(skill_cfg[effect_level][string.sub(str, 2, -3)]) / 100 .. "%"
		end)
		desc = string.gsub(desc, "%[.-%]" , function(str)
			return skill_cfg[effect_level][string.sub(str, 2, -2)]
		end)

		self.node_list["TxtSkillInfoSlider"].text.text = string.format("%s/%s", 0, 0)
		self.node_list["ImgSkillInfoSliderBg"].slider.value = 0

		self.node_list["NoteNextEffect"]:SetActive(true)
		self.node_list["NoteNextEffect2"]:SetActive(true)
		--主动技能战斗力
		-- local attr = CommonStruct.Attribute()
		-- local attr_n = CommonStruct.Attribute()
		-- for k, v in pairs(Language.Common.PassvieSkillAttr) do
		-- 	if skill_cfg[effect_level].skill_name == v then
		-- 		if skill_info then
		-- 			attr[k] = skill_cfg[effect_level].param_a
		-- 			if effect_level < #skill_cfg then
		-- 				attr_n[k] = skill_cfg[effect_level + 1].param_a
		-- 			end

		-- 		else
		-- 			attr_n[k] = skill_cfg[effect_level].param_a
		-- 		end
		-- 	end
		-- end
		-- local capability = CommonDataManager.GetCapability(attr)
		
		-- self.node_list["TxtFightPowerNumber"].text.text = capability


		if skill_info then
			if effect_level >= #skill_cfg then
				self.node_list["NoteNextEffect"]:SetActive(false)
				self.node_list["NoteNextEffect2"]:SetActive(false)
				self.node_list["TxtSkillInfoSlider"].text.text = string.format("%s/%s", 0, 0)
				self.node_list["ImgSkillInfoSliderBg"].slider.value = 0
				self.node_list["Slider"]:SetActive(false)
			else
				local proficient = SkillData.Instance:GetSkillProficiency(skill_info.skill_id)
				self.node_list["TxtSkillInfoSlider"].text.text = string.format("%s/%s", proficient, 0)
				next_desc = string.gsub(self.profession_skill_data[index].skill_desc, "%b()%%" , function(str)
					return tonumber(skill_cfg[effect_level][string.sub(str, 2, -3)]) / 1000
				end)
				next_desc = string.gsub(next_desc, "%b[]%%" , function(str)
					return tonumber(skill_cfg[effect_level + 1][string.sub(str, 2, -3)]) / 100 .. "%"
				end)
				next_desc = string.gsub(next_desc, "%[.-%]" , function(str)
					return skill_cfg[effect_level + 1][string.sub(str, 2, -2)]
				end)

				if self.is_init_exp_radio or self.is_click_skill then
				else
				end
				self.node_list["Slider"]:SetActive(true)
			end
			self.node_list["TxtSkillInfoSlider"].text.text = string.format("%s/%s", 0, skill_cfg[effect_level].zhenqi_cost)
		end
		self.is_click_skill = false
		local mojingnum1 = ToColorStr(ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.MOJING), TEXT_COLOR.GREEN_4)
		local mojingnum2 = ToColorStr(ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.MOJING), TEXT_COLOR.RED)
		local mojingnum = ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.MOJING)

		
		if effect_level == max_level then
			self.node_list["NeedTxt"].text.text = Language.Common.YiManJi
		else
			if skill_cfg[effect_level + 1].learn_level_limit <= main_vo.level then
				self.node_list["NeedTxt"].text.text = Language.Player.NeedLevel .. ToColorStr(skill_cfg[effect_level + 1].learn_level_limit, TEXT_COLOR.GREEN_4)
			else
				self.node_list["NeedTxt"].text.text = Language.Player.NeedLevel .. ToColorStr(skill_cfg[effect_level + 1].learn_level_limit, TEXT_COLOR.RED)
			end

			if skill_cfg[effect_level + 1].mojing_cost < mojingnum then
				self.node_list["XiaoHaoTxt"].text.text = mojingnum1 .. ToColorStr(" / " .. skill_cfg[level + 1].mojing_cost, TEXT_COLOR.GREEN_4)
			else 
				self.node_list["XiaoHaoTxt"].text.text = mojingnum2 .. ToColorStr(" / " .. skill_cfg[level + 1].mojing_cost, TEXT_COLOR.GREEN_4) 
			end
		end
		local data = {item_id = MOJING_ID} 
		self.item_cell:SetData(data)
		self.node_list["TxtFightPowerNumber"].text.text = 0
	else
		-- 被动技能
		for k, v in pairs(self.passive_skill) do
			v.skill_name:GetComponent(typeof(UnityEngine.UI.Text)).text = self.passive_skill_data[k].skill_name
			local info = SkillData.Instance:GetSkillInfoById(self.passive_skill_data[k].skill_id)
			local local_skill_cfg = ConfigManager.Instance:GetAutoConfig("roleskill_auto")["s".. self.passive_skill_data[k].skill_id]
			local level = 0
			if info ~= nil then
				level = info.level
			end
			v.skill_level:GetComponent(typeof(UnityEngine.UI.Text)).text = "Lv：" .. level
			if max_level <= level then
				v.arrow.gameObject:SetActive(false)
			else
				local local_level = level == 0 and 1 or level
				local count = ItemData.Instance:GetItemNumInBagById(local_skill_cfg[local_level].item_cost_id)
				if count < local_skill_cfg[level + 1].item_cost then
					v.arrow.gameObject:SetActive(false)
				else
					v.arrow.gameObject:SetActive(true)
				end
			end
		end

		local passive_info = SkillData.Instance:GetSkillInfoById(self.passive_skill_data[index].skill_id)
		local passive_skill = self.passive_skill[index]
		if passive_info then
			local bundle, asset = ResPath.GetRoleSkillIcon(self.passive_skill_data[index].skill_icon)
			passive_skill.icon.image:LoadSprite(bundle, asset)
			UI:SetGraphicGrey(passive_skill.icon.gameObject, false)
			self.node_list["UnActiveCurrentEffect"]:SetActive(false)
			if self.passive_level_list[index] then
				if self.passive_level_list[index] < passive_info.level then
					if Status.NowTime - self.effect_cd > EFFECT_CD then
						passive_skill.effect.gameObject:SetActive(true)
						self.effect_cd = Status.NowTime
						GlobalTimerQuest:AddDelayTimer(function ()
							passive_skill.effect.gameObject:SetActive(false)
						end, 0.75)
					end
				end
			end
		else
			UI:SetGraphicGrey(passive_skill.icon.gameObject, true)
			self.node_list["UnActiveCurrentEffect"]:SetActive(true)
		end

		-- 战斗力
		local attr = CommonStruct.Attribute()
		local attr_n = CommonStruct.Attribute()
		for k, v in pairs(Language.Common.PassvieSkillAttr) do
			if skill_cfg[effect_level].skill_name == v then
				if skill_info then
					attr[k] = skill_cfg[effect_level].param_a
					if effect_level < #skill_cfg then
						attr_n[k] = skill_cfg[effect_level + 1].param_a
					end
				else
					attr_n[k] = skill_cfg[effect_level].param_a
				end
			end
		end
		local capability = CommonDataManager.GetCapability(attr)
		-- self.node_list["TxtFightPowerNumber"].text.text = capability
		self.node_list["TxtFightPowerNumber2"].text.text = capability
		local capability_n = CommonDataManager.GetCapability(attr_n, true, attr)
		self.node_list["TxtSkillInfoFightPowerNum"].text.text = capability_n
		self.node_list["TxtSkillInfoNum"].text.text = capability_n

		desc = string.gsub(self.passive_skill_data[index].skill_desc, "%[.-%]" , function(str)
			return skill_cfg[effect_level][string.sub(str, 2, -2)]
		end)
		self.node_list["NoteNextEffect"]:SetActive(true)
		self.node_list["NoteNextEffect2"]:SetActive(true)
		if skill_info then
			if effect_level >= #skill_cfg then
				self.node_list["NoteNextEffect"]:SetActive(false)
				self.node_list["NoteNextEffect2"]:SetActive(false)
			else
				next_desc = string.gsub(self.passive_skill_data[index].skill_desc, "%[.-%]" , function(str)
					return skill_cfg[effect_level + 1][string.sub(str, 2, -2)]
				end)
			end
		end
		
		local data = {item_id = skill_cfg[effect_level].item_cost_id} -- ItemData.Instance:GetItem(MOJING_ID)
		self.item_cell:SetData(data)

		local item_cfg = ItemData.Instance:GetItemConfig(skill_cfg[effect_level].item_cost_id)
		local count = ItemData.Instance:GetItemNumInBagById(skill_cfg[effect_level].item_cost_id)
		if effect_level < #skill_cfg then
			if count < skill_cfg[effect_level + 1].item_cost then
				-- self.passive_skill[index].arrow.gameObject:SetActive(false)
				self.node_list["TxtTitle"].text.text = (ToColorStr(count, TEXT_COLOR.RED)) .. (ToColorStr(" / " .. skill_cfg[effect_level + 1].item_cost, TEXT_COLOR.GREEN_4))
			else
				
				-- self.passive_skill[index].arrow.gameObject:SetActive(true)
				self.node_list["TxtTitle"].text.text = (ToColorStr(count, TEXT_COLOR.GREEN_4)) .. (ToColorStr(" / " .. skill_cfg[effect_level + 1].item_cost, TEXT_COLOR.GREEN_4))
			end
		else
			-- self.passive_skill[index].arrow.gameObject:SetActive(false)
		end
		self.passive_level_list[index] = passive_info and passive_info.level or 0
	end

	if skill_info == nil then
		self.node_list["TxtNextEffect"].text.text = desc
		self.node_list["TxtSkillEffect"].text.text = desc
	else
		self.node_list["TxtCurrentEffect"].text.text = desc
		self.node_list["TxtCurrentEffect1"].text.text = desc
		for k, v in pairs(self.profession_skill) do
			local info = SkillData.Instance:GetSkillInfoById(self.profession_skill_data[k].skill_id)
			local level = 0
			if info ~= nil then
				level = info.level
			else
				self.node_list["ContentText2"]:SetActive(true)
			end
		end
		if effect_level < #skill_cfg then
			self.node_list["TxtNextEffect"].text.text = next_desc
			self.node_list["TxtSkillEffect"].text.text = next_desc
		end
	end

	self.is_init_exp_radio = false
end

function PlayerSkillView:SetDefultToggle()
	self.node_list["ProfessionSkilButton"].toggle.isOn = false
	self.node_list["PassiveSkilButton"].toggle.isOn = true
	self.is_set_model = false
	self:OnClickPassiveButton()
	self:FlushMieShiSkillView()
	self.is_init_exp_radio = false
end

function PlayerSkillView:OnClickProfessionButton()
	self.is_skill_or_mieshi = false
	self.node_list["TxtUpgradeBtn"]:SetActive(false)
	self.node_list["TxtUpgradeBtn1"]:SetActive(true)
	self.node_list["TxtSkillInfoUpgradeBtn"]:SetActive(false)
	self.node_list["TxtSkillInfoUpgradeBtn1"]:SetActive(true)
	if self.cur_toggle_state == 1 then
		return
	end
	self.parent_view:SetSceneMaskState(true)
	local call_back = function()
		if self.parent_view then
			self.parent_view:SetSceneMaskState(false)
		end
	end
	UIScene:SetUISceneLoadCallBack(call_back)
	self.is_init_exp_radio = true
	self.node_list["ProfessionSkilButton"].toggle.isOn = true
	self.node_list["PassiveSkilButton"].toggle.isOn = false
	self.index = 1
	self:FlushSkillInfo()
	-- 显示角色切换到非战斗状态
	UIScene:SetActionEnable(true)
	self:SetRoleFight(true)
	UIScene:ResetRotate()
	-- UIScene:Rotate(0, -63, 0)
	self:StopLevelUp()
	self.is_set_model = false
	self.cur_toggle_state = 1
end

function PlayerSkillView:SetDefaultState()
	UIScene:SetActionEnable(true)
	self:SetRoleFight(true)
	UIScene:ResetRotate()
	-- UIScene:Rotate(0, -63, 0)
	self.is_set_model = false
end

function PlayerSkillView:OnClickPassiveButton(v)
	if self.cur_toggle_state == 2 then
		return
	end
	if not self.node_list["PassiveSkilButton"].toggle.isOn then
		return
	end
	self.parent_view:SetSceneMaskState(true)
	if not self.is_set_model then
		local call_back = function()
			if self.parent_view then
				self.parent_view:SetSceneMaskState(false)
			end
		end
		UIScene:SetUISceneLoadCallBack(call_back)
		self:SetRoleFight(false)
		UIScene:SetActionEnable(true)
		self.is_set_model = true
	end
	self.node_list["PassiveSkilButton"].toggle.isOn = true
	self.node_list["ProfessionSkilButton"].toggle.isOn = false
	self:FlushSkillInfo()
	self.cur_toggle_state = 2
	self.node_list["BtnSkillInfoStop"]:SetActive(false)
end

function PlayerSkillView:SetRoleFight(enable)
	UIScene:SetFightBool(enable)
end

function PlayerSkillView:FlushSkillExpInfo()
	self.is_click_skill = true
	if self.is_skill_or_mieshi then
		self:OnClickMieShi(self.is_index)
		return
	end
	if not self.node_list["PassiveSkilButton"].toggle.isOn and self.profession_skill_data[self.index] then
		self:GetSkillInfo(self.profession_skill_data[self.index].skill_id, self.profession_skill_data[self.index].skill_name, self.index)
	else
		self:GetSkillInfo(self.passive_skill_data[self.index].skill_id, self.passive_skill_data[self.index].skill_name, self.index)
	end
end

function PlayerSkillView:CloseCallBack()
	self.node_list["ProfessionSkilButton"].toggle.isOn = false
	self.node_list["PassiveSkilButton"].toggle.isOn = true
end

function PlayerSkillView:FlushSkillInfo()

	if self.node_list["PassiveSkilButton"].toggle.isOn then
		self.last_passive_index = self.passive_index
		local temp_skill_id = self.passive_skill_data[self.passive_index].skill_id
		local skill_cfg = ConfigManager.Instance:GetAutoConfig("roleskill_auto")["s"..temp_skill_id]
		local skill_info = SkillData.Instance:GetSkillInfoById(temp_skill_id)
		local level = skill_info and skill_info.level or 1

		for k = 7, 1, -1 do
			local v = self.passive_skill_data[k]
			if v == nil then return end
			skill_cfg = ConfigManager.Instance:GetAutoConfig("roleskill_auto")["s"..v.skill_id]
			skill_info = SkillData.Instance:GetSkillInfoById(v.skill_id)

			level = 1
			if skill_info then
				level = skill_info.level
			end
			self:SetSkillInfo(skill_cfg, k, level, skill_info, true)
		end

		local item_id = skill_cfg[level].item_cost_id
		local data = ItemData.Instance:GetItem(item_id)
		self.item_cell:SetData(data)

		local index_list = SkillData.Instance:GetPassvieSkillCanUpLevelIndexList(self.passive_skill_data)
		local index = -1
		local select_index_can_up = false
		for k, v in pairs(index_list) do
			if v == self.passive_index then
				select_index_can_up = true
				index = self.passive_index
			end
		end
		if not select_index_can_up then
			index = index_list[#index_list] or self.passive_index
		end

		if index ~= self.passive_index or not next(index_list) or (index == self.passive_index and select_index_can_up) then
			self.passive_skill[index].skill.toggle.isOn = true
		end
		self.passive_index = index > 0 and index or self.passive_index
		self:GetSkillInfo(self.passive_skill_data[self.passive_index].skill_id, self.passive_skill_data[self.passive_index].skill_name, self.passive_index)
		self.temp_skill_id = self.passive_skill_data[self.passive_index].skill_id

		for i = 8, 10 do
			self:FlushMieShiSkillIcon(i)
		end

	else
		self.index = self.index or 1
		if self.profession_skill[self.index] and self.profession_skill_data[self.index] then
			self:OnClickSkill(self.profession_skill_data[self.index].skill_icon,
					self.profession_skill_data[self.index].skill_id, self.profession_skill_data[self.index].skill_name, self.index, false, 2)
		end
	end
end

function PlayerSkillView:RemoveCountDown()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end

	if self.delay_time1 then
		GlobalTimerQuest:CancelQuest(self.delay_time1)
		self.delay_time1 = nil
	end

	if self.skill_delay_timer then
		GlobalTimerQuest:CancelQuest(self.skill_delay_timer)
		self.skill_delay_timer = nil
	end
end

function PlayerSkillView:RemindChangeCallBack(remind_name, num)
	--self.node_list["Remind"]:SetActive(num > 0)
end

PlayerActiveSkillView = PlayerActiveSkillView or BaseClass(BaseRender)

local EFFECT_CD = 0.8
local KILL_SKILL_ID = 5			-- 必杀技ID
local EFFECT_CD = 1

local MOJING_ID = 90002             --魔晶ID

function PlayerActiveSkillView:__init(instance, parent_view)
	self.node_list["BtnUpgrade"].button:AddClickListener(BindTool.Bind(self.OnClickUpgradeButtonPro, self, true))
	self.node_list["BtnStop"].button:AddClickListener(BindTool.Bind(self.StopLevelUp, self))
	self.node_list["AllUpGradeBtn2"].button:AddClickListener(BindTool.Bind(self.OnAllUpGradeBtn, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFightPowerNumber"])

	self.parent_view = parent_view

	self.node_list["BtnStop"]:SetActive(false)

	self.profession_skill = {}							-- 职业技能,职业技能列表的第五个 为必杀技能
	for i = 1, SkillData.PROFESSOIN_SKILL_NUM do       ----7
		local skill = self.node_list["ProSkill" .. i]
		local icon = self.node_list["ActiveSkillIcon" .. i]
		local point = self.node_list["RedPoint" .. i]
		local name_lable = skill.transform:FindHard("SkillNameLable")
		local skill_name = name_lable.transform:FindHard("Name")
		local skill_level = name_lable.transform:FindHard("Level")
		local arrow = skill.transform:FindHard("Arrow")
		table.insert(self.profession_skill, {skill = skill, icon = icon,
					 name_lable = name_lable, skill_name = skill_name, skill_level = skill_level, point = point, arrow = arrow,})
	end

	self.profession_skill_data = SkillData.Instance:GetActiveSkillListCfg()

	self.index = 1
	self.temp_skill_id = 0
	self:GetMaxLevelList()
	self:AddSkillListenEvent()
	self.attack_hit_handle = {}
	self.effect_cd = 0
	self.auto_level_up = false
	self.is_index = 0
	self.is_can = false
	self.effect_cd = 0
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.PlayerSkill)
end

function PlayerActiveSkillView:LoadCallBack()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ConsumeItem"])
end

function PlayerActiveSkillView:__delete()
	RemindManager.Instance:UnBind(self.remind_change)
	self.is_index = nil
	self.parent_view = nil
	self.index = nil
	self.temp_skill_id = nil
	self.profession_skill = {}							-- 职业技能,职业技能列表的第五个 为必杀技能
	self.profession_skill_data = nil
	self.is_init_exp_radio = nil
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
	self.fight_text = nil
end


function PlayerActiveSkillView:GetMaxLevelList()
	self.max_level_list = {}
	local role_skill_cfg = ConfigManager.Instance:GetAutoConfig("roleskill_auto")
	for k,v in pairs(self.profession_skill_data) do
		local skill_cfg = {}
		local prof = PlayerData.Instance:GetRoleBaseProf()
		if v.skill_id >= ZHUAN_ZHI_SKILL_MIN and v.skill_id <= ZHUAN_ZHI_SKILL_MAX then
			if v.skill_id == ZHUAN_ZHI_SKILL1[prof] or v.skill_id == ZHUAN_ZHI_SKILL2[prof] then
				skill_cfg = {{skill_level = 1}}
			end
		else
			skill_cfg = role_skill_cfg["s" .. v.skill_id]
		end
		table.insert(self.max_level_list, skill_cfg)
		self.max_level_list[k] = #skill_cfg
	end
end

function PlayerActiveSkillView:AddSkillListenEvent()
	for k, v in pairs(self.profession_skill) do
		v.skill.toggle:AddClickListener(BindTool.Bind(self.OnClickSkill, self,
			self.profession_skill_data[k].skill_icon, self.profession_skill_data[k].skill_id,
			self.profession_skill_data[k].skill_name, k, false, 0.4))
	end

	self:OnClickSkill(self.profession_skill_data[self.index].skill_icon,
		self.profession_skill_data[self.index].skill_id, self.profession_skill_data[self.index].skill_name, self.index, false, 0.4)
	self.profession_skill[self.index].skill.toggle.isOn = true
end

function PlayerActiveSkillView:OnClickSkill(skill_icon, skill_id, skill_name, index, is_passive, delay_play_skill_time)
	if self.temp_skill_id ~= skill_id then
		self:StopLevelUp()
	end

	self.index = index
	self.temp_skill_id = skill_id
	self:GetSkillInfo(skill_id, skill_name, index)
	-- if nil ~= self.skill_delay_timer then
		-- GlobalTimerQuest:CancelQuest(self.skill_delay_timer)
	-- end
	-- self.skill_delay_timer = GlobalTimerQuest:AddDelayTimer(function()
		self:OnClickPlayButton(self.index)
	-- end, delay_play_skill_time)
end

--全部升级
function PlayerActiveSkillView:OnAllUpGradeBtn()
	local is_all_max = 0
	local is_all_less = 0
	local skill_tab = self.profession_skill_data or {}

	self.temp_skill_level = {}
	local prof = PlayerData.Instance:GetRoleBaseProf()
	for k, v in pairs(skill_tab) do
		if v.skill_id >= ZHUAN_ZHI_SKILL_MIN and v.skill_id <= ZHUAN_ZHI_SKILL_MAX then
			break
		end

		local skill_cfg = ConfigManager.Instance:GetAutoConfig("roleskill_auto")["s" .. v.skill_id] 
		local skill_info = SkillData.Instance:GetSkillInfoById(v.skill_id)
		if skill_cfg and skill_info then
			local level = skill_info and skill_info.level + 1 or 1
			if level >= skill_cfg[#skill_cfg].skill_level then
				is_all_max = is_all_max + 1
			else
				local item_id = skill_cfg[level].item_cost_id
				if skill_cfg[level].item_cost > ItemData.Instance:GetItemNumInBagById(item_id) then
					is_all_less = is_all_less + 1
				end
			end
			self.temp_skill_level[v.skill_id] = {}
			self.temp_skill_level[v.skill_id].level = skill_info.level
			self.temp_skill_level[v.skill_id].is_all_uplevel = true
		end
	end

	

	if is_all_max >= #skill_tab then
		SysMsgCtrl.Instance:ErrorRemind(Language.Player.MaxLevel)
		return
	elseif (is_all_less + is_all_max) >= #skill_tab then
		SysMsgCtrl.Instance:ErrorRemind(Language.Player.SkillCostItemAllLess)
		return
	end

	SkillCtrl.Instance:SendRoleSkillLearnReq(0, UPLEVEL_SKILL_TYPE.UPLEVEL_ACTIVE_SKILL_ALL)
end

function PlayerActiveSkillView:OnClickUpgradeButtonPro()
	local skill_cfg = ConfigManager.Instance:GetAutoConfig("roleskill_auto")["s"..self.temp_skill_id]
	local skill_info = SkillData.Instance:GetSkillInfoById(self.temp_skill_id)
	local level = skill_info and skill_info.level + 1 or 1
	local main_vo = GameVoManager.Instance:GetMainRoleVo()

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
		SkillCtrl.Instance:SendRoleSkillLearnReq(self.temp_skill_id, UPLEVEL_SKILL_TYPE.UPLEVEL_SKILL)
		if skill_cfg[level].learn_level_limit <= main_vo.level then
			self:PlayEffect()
		end
	end
	self:FlushSkillInfo()
end

function PlayerActiveSkillView:PlayEffect(index)
	local play_index = index or self.index
	if self.effect_cd then
		local bundle_name, asset_name = ResPath.GetUiXEffect("UI_jinengshengji")
		EffectManager.Instance:PlayAtTransform(
			bundle_name,
			asset_name,
			self.profession_skill[play_index].icon.transform,
			2.0)
		self.effect_cd = Status.NowTime + EFFECT_CD
	end
end

function PlayerActiveSkillView:StopLevelUp()
	self.auto_level_up = false
	self.is_can = false
	self.node_list["BtnUpgrade"]:SetActive(true)
	self.node_list["BtnStop"]:SetActive(false)
end

function PlayerActiveSkillView:OnClickPlayButton(index)
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

function PlayerActiveSkillView:GetSkillInfo(skill_id, skill_name, index)
	if skill_id == 0 or skill_name == nil or index == nil then
		return
	end

	local skill_cfg
	local skill_info = SkillData.Instance:GetSkillInfoById(skill_id)
	local prof = PlayerData.Instance:GetRoleBaseProf()
	if skill_id == ZHUAN_ZHI_SKILL1[prof] or skill_id == ZHUAN_ZHI_SKILL2[prof] then
		local cfg = SkillData.GetNormalSkillinfoConfig(skill_id)
		skill_cfg = {[1] = cfg}
	else
		skill_cfg = ConfigManager.Instance:GetAutoConfig("roleskill_auto")["s" .. skill_id]
	end
	self.node_list["TxtPassSkillName"].text.text = skill_name
	self.node_list["TxtFightPowerTitleSkillName"].text.text = skill_name
	-- self.node_list["NoteCurrentEffect"]:SetActive(skill_info ~= nil)

	if skill_info == nil then
		self:SetSkillInfo(skill_cfg, index, nil, skill_info)
	else
		-- 客户端记录的技能等级，熟练度
		local level = skill_info.level
		self:SetSkillInfo(skill_cfg, index, level, skill_info)
	end
end

-- 设置角色技能为0级时，右边技能信息的显示
function PlayerActiveSkillView:SetSkillInfo(skill_cfg, index, level, skill_info, is_passive)
	local effect_level = level or 1
	local cur_level = level or 0
	local desc = ""
	local next_desc = ""
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local max_level = skill_cfg[#skill_cfg].skill_level

	self.node_list["TxtLevel"].text.text = string.format("%s/%s", cur_level, #skill_cfg)
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

		local skill_id = self.profession_skill_data[k].skill_id
		if self.temp_skill_level and self.temp_skill_level[skill_id] and self.temp_skill_level[skill_id].is_all_uplevel then
			local temp_level = self.temp_skill_level[skill_id].level
			if temp_level and temp_level < info.level then
				self:PlayEffect(k)
				self.temp_skill_level[skill_id].is_all_uplevel = false
				self.temp_skill_level[skill_id].level = nil
			end
		end
		local prof = PlayerData.Instance:GetRoleBaseProf()
		if skill_id ~= ZHUAN_ZHI_SKILL1[prof] and skill_id ~= ZHUAN_ZHI_SKILL2[prof] then
			local cur_skill_cfg = ConfigManager.Instance:GetAutoConfig("roleskill_auto")["s" .. skill_id]
			if cur_skill_cfg and cur_skill_cfg[skill_level + 1] and cur_skill_cfg[skill_level + 1].mojing_cost  then
				-- if skill_id ~= KILL_SKILL[prof] then
					if skill_level > 0 and skill_level < cur_skill_cfg[#cur_skill_cfg].skill_level and ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.MOJING) >= cur_skill_cfg[skill_level + 1].mojing_cost 
						and PlayerData.Instance:GetAttr("level") >= cur_skill_cfg[skill_level + 1].learn_level_limit then
						v.point:SetActive(true)
					else
						v.point:SetActive(false)
					end
				-- else
					-- if skill_level > 0 and skill_level < cur_skill_cfg[#cur_skill_cfg].skill_level and ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.MOJING) >= cur_skill_cfg[skill_level + 1].mojing_cost then
						-- v.point:SetActive(true)
					-- else
						-- v.point:SetActive(false)
					-- end
				-- end
			else
				v.point:SetActive(false)
			end
		end
		
		
		v.skill_name:GetComponent(typeof(UnityEngine.UI.Text)).text = self.profession_skill_data[k].skill_name
		v.skill_level:GetComponent(typeof(UnityEngine.UI.Text)).text = "Lv：" .. skill_level 
		if k == 5 then --第五个为必杀技
			v.skill_name:GetComponent(typeof(UnityEngine.UI.Text)).text = Language.Player["SkiiName" .. (main_vo.prof % 10)]
		end
		local prof = PlayerData.Instance:GetRoleBaseProf()
		if skill_level == self.max_level_list[k] then
			v.skill_level:GetComponent(typeof(UnityEngine.UI.Text)).text = Language.Common.YiManJi
		elseif self.profession_skill_data[k].skill_id == ZHUAN_ZHI_SKILL1[prof] then
			v.skill_level:GetComponent(typeof(UnityEngine.UI.Text)).text = Language.Player.OpenCondition[5]
		elseif self.profession_skill_data[k].skill_id == ZHUAN_ZHI_SKILL2[prof] then
			v.skill_level:GetComponent(typeof(UnityEngine.UI.Text)).text = Language.Player.OpenCondition[6]
		end
		local bundle, asset = ResPath.GetRoleSkillIcon(self.profession_skill_data[k].skill_icon)
		if self.profession_skill_data[k].skill_id == KILL_SKILL_ID then
			local skill_icon = self.profession_skill_data[k].skill_icon + (main_vo.prof % 10)
			bundle, asset = ResPath.GetRoleSkillIcon(skill_icon)
		elseif self.profession_skill_data[k].skill_id == ZHUAN_ZHI_SKILL1[prof] or
				self.profession_skill_data[k].skill_id == ZHUAN_ZHI_SKILL2[prof] then
			--local skill_icon = self.profession_skill_data[k].skill_icon  .. (main_vo.prof % 10) .. "_2"
			bundle, asset = ResPath.GetRoleSkillIcon(self.profession_skill_data[k].skill_id)
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
		local add_target = skill_info ~= nil and SkillData.Instance:GetSkillIsAddTarget(skill_info.skill_id) or 0
		return (skill_cfg[effect_level][string.sub(str, 2, -2)] + add_target)
		end)

	self.node_list["TxtSkillInfoSlider"].text.text = string.format("%s/%s", 0, 0)
	self.node_list["ImgSkillInfoSliderBg"].slider.value = 0

	self.node_list["NoteNextEffect"]:SetActive(true)
	-- self.node_list["NoteNextEffect2"]:SetActive(true)
	-- 主动技能战斗力
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
	--local capability = CommonDataManager.GetCapability(attr)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = skill_cfg[effect_level].capbility
	end

	if skill_info then
		if effect_level >= #skill_cfg then
			self.node_list["NoteNextEffect"]:SetActive(false)
			-- self.node_list["NoteNextEffect2"]:SetActive(false)
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
				local add_target = SkillData.Instance:GetSkillIsAddTarget(skill_info.skill_id) or 0
				return (skill_cfg[effect_level + 1][string.sub(str, 2, -2)] + add_target)
				end)

			self.node_list["Slider"]:SetActive(true)
		end
		self.node_list["TxtSkillInfoSlider"].text.text = string.format("%s/%s", 0, skill_cfg[effect_level].zhenqi_cost)
	end
	local mojingnum1 = ToColorStr(ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.MOJING), TEXT_COLOR.GREEN_4)
	local mojingnum2 = ToColorStr(ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.MOJING), TEXT_COLOR.RED)
	local mojingnum = ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.MOJING)

	if cur_level == 0 then
		self.node_list["TxtUpgradeBtn"].text.text = Language.Player.WeiKaiQi
		UI:SetButtonEnabled(self.node_list["BtnUpgrade"], false)
		local prof = PlayerData.Instance:GetRoleBaseProf()
		if skill_cfg[1] and skill_cfg[1].skill_id == ZHUAN_ZHI_SKILL1[prof] then
			self.node_list["NeedTxt"].text.text = Language.Player.NeedLevel .. ToColorStr(Language.Player.OpenCondition[5], TEXT_COLOR.RED)
		elseif skill_cfg[1] and skill_cfg[1].skill_id == ZHUAN_ZHI_SKILL2[prof] then
			self.node_list["NeedTxt"].text.text = Language.Player.NeedLevel .. ToColorStr(Language.Player.OpenCondition[6], TEXT_COLOR.RED)
		elseif skill_cfg[1] and skill_cfg[1].skill_id == KILL_SKILL[prof] then
			self.node_list["NeedTxt"].text.text = Language.Player.NeedLevel .. ToColorStr(Language.Player.OpenCondition[1], TEXT_COLOR.RED)
		else
			self.node_list["NeedTxt"].text.text = Language.Player.NeedLevel .. ToColorStr(skill_cfg[1].learn_level_limit, TEXT_COLOR.RED)
		end
	elseif effect_level == max_level then
		self.node_list["NeedTxt"].text.text = ""
		self.node_list["XiaoHaoTxt"].text.text = Language.Common.MaxLevelDesc
		self.node_list["TxtUpgradeBtn"].text.text = Language.Common.YiManJi
		UI:SetButtonEnabled(self.node_list["BtnUpgrade"], false)
	else
		local prof = PlayerData.Instance:GetRoleBaseProf()
		-- if skill_cfg[1] and skill_cfg[1].skill_id == KILL_SKILL[prof] then
		-- 	self.node_list["NeedTxt"].text.text = Language.Player.NeedLevel .. ToColorStr(Language.Player.OpenCondition[1], TEXT_COLOR.GREEN_4)
		-- else
		if skill_cfg[effect_level + 1].learn_level_limit <= main_vo.level then
			self.node_list["NeedTxt"].text.text = Language.Player.NeedLevel .. ToColorStr(skill_cfg[effect_level + 1].learn_level_limit, TEXT_COLOR.GREEN_4)
		else
			self.node_list["NeedTxt"].text.text = Language.Player.NeedLevel .. ToColorStr(skill_cfg[effect_level + 1].learn_level_limit, TEXT_COLOR.RED)
		end
		-- end

		if skill_cfg[effect_level + 1].mojing_cost < mojingnum then
			self.node_list["XiaoHaoTxt"].text.text = mojingnum1 .. ToColorStr(" / " .. skill_cfg[level + 1].mojing_cost, TEXT_COLOR.GREEN_4)
		else 
			self.node_list["XiaoHaoTxt"].text.text = mojingnum2 .. ToColorStr(" / " .. skill_cfg[level + 1].mojing_cost, TEXT_COLOR.GREEN_4) 
		end
		self.node_list["TxtUpgradeBtn"].text.text = Language.Player.UpGrade
		UI:SetButtonEnabled(self.node_list["BtnUpgrade"], true)
	end
	local data = {item_id = MOJING_ID} 
	self.item_cell:SetData(data)
	if skill_info == nil then
		self.node_list["TxtNextEffect"].text.text = desc
		self.node_list["TxtCurrentEffect"].text.text = Language.Common.NoActivate
		self.node_list["XiaoHaoTxt"].text.text = "- / -"
	else
		self.node_list["TxtCurrentEffect"].text.text = desc
		for k, v in pairs(self.profession_skill) do
			local info = SkillData.Instance:GetSkillInfoById(self.profession_skill_data[k].skill_id)
			local level = 0
			if info ~= nil then
				level = info.level
			else
				-- self.node_list["ContentText2"]:SetActive(true)
			end
		end
		if effect_level < #skill_cfg then
			self.node_list["TxtNextEffect"].text.text = next_desc
		end
	end

	self.is_init_exp_radio = false
end

function PlayerActiveSkillView:OnClickProfessionButton()
	self.parent_view:SetSceneMaskState(true)
	local call_back = function()
		if self.parent_view then
			self.parent_view:SetSceneMaskState(false)
		end
	end
	UIScene:SetUISceneLoadCallBack(call_back)
	self.is_init_exp_radio = true

	-- self.index = 1
	self:FlushSkillInfo()
	-- 显示角色切换到非战斗状态
	-- UIScene:SetActionEnable(true)
	self:SetRoleFight(true)
	UIScene:ResetRotate()
	-- UIScene:Rotate(0, -63, 0)
	self:StopLevelUp()
end

function PlayerActiveSkillView:SetDefaultState()
	-- UIScene:SetActionEnable(true)
	self:SetRoleFight(true)
	UIScene:ResetRotate()
	-- UIScene:Rotate(0, -63, 0)
end

function PlayerActiveSkillView:SetRoleFight(enable)
	UIScene:SetFightBool(enable)
end

function PlayerActiveSkillView:FlushSkillExpInfo()
	self:GetSkillInfo(self.profession_skill_data[self.index].skill_id, self.profession_skill_data[self.index].skill_name, self.index)
end

function PlayerActiveSkillView:FlushSkillInfo()
	self.index = self.index or 1
	if self.profession_skill[self.index] and self.profession_skill_data[self.index] then
		self:OnClickSkill(self.profession_skill_data[self.index].skill_icon,
				self.profession_skill_data[self.index].skill_id, self.profession_skill_data[self.index].skill_name, self.index, false, 2)
	end
end

function PlayerActiveSkillView:RemoveCountDown()
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

function PlayerActiveSkillView:RemindChangeCallBack(remind_name, num)
end

function PlayerActiveSkillView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["LeftView"], PlayerData.TweenPosition.Left , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["SkillInfoInitiative"], PlayerData.TweenPosition.Right , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end
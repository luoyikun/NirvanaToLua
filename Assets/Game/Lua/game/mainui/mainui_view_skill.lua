MainUIViewSkill = MainUIViewSkill or BaseClass(BaseRender)

local not_show_normal_skill_scene_type = {
	[SceneType.FarmHunting] = 1
}

local function SkillInfo()
	return {
		icon = nil,
		skill_id = 0,
		is_exist = false,
	}
end
local JUMP_MAX_ENERGY = 100 
function MainUIViewSkill:__init(instance, parent)
	-- 初始化
	self.parent = parent
	self.skill_infos = {
		SkillInfo(),
		SkillInfo(),
		SkillInfo(),
		SkillInfo(),
		SkillInfo(),
		SkillInfo(),
		SkillInfo(),
		SkillInfo(),
		SkillInfo(),
		SkillInfo(),
		SkillInfo(),
		SkillInfo(),
	}

	-- 找到要控制的变量
	self.skill_icons = {
		self.node_list["ImgAttack"],--普攻
		self.node_list["Skill1Img"],
		self.node_list["Skill2Img"],
		self.node_list["Skill3Img"],
		self.node_list["Skill4Img"],--怒气
		
		self.node_list["Skill6Img"],--女神技能
		self.node_list["Skill5Img"],--魔戒技能
		self.node_list["Skill8Img"],
		self.node_list["Skill9Img"],
		self.node_list["Skill10Img"],
		self.node_list["Skill11Img"],
		self.node_list["Skill12Img"],
		self.node_list["JumpButton"],
		self.node_list["LandingButton"],
	}

	self.qinggong_btn = self.node_list["JumpButton"]
	self.qinggong_down_btn = self.node_list["LandingButton"]

	self.show_mojie_panel_anmi = self.node_list["Skill5ChangePanel"].animator
	self.node_list["Skill5ChangePanel"]:SetActive(false)						--策划说这魔戒两个技能改被动不要显示了

	self.goddess_is_lock = nil

	self.other_mojie_info = {
		SkillInfo(),
		SkillInfo(),
	}
	self.other_mojie_icon = {
		self.node_list["Skill51Img"],
		self.node_list["Skill52Img"],
	}

	self.other_mojie_name = {
		self.node_list["Skill51NameTxt"],
		self.node_list["Skill52NameTxt"],
	}

	self.skill_cd_progress = {
		false,
		self.node_list["Skill1CDMask"],
		self.node_list["Skill2CDMask"],
		self.node_list["Skill3CDMask"],
		self.node_list["Skill4KillCDImg"],
		self.node_list["Skill6CDMask"],
		self.node_list["Skill5CDMask"],
		self.node_list["Skill8CDMask"],
		self.node_list["Skill9CDMask"],
		self.node_list["Skill10CDMask"],
		self.node_list["Skill11CDMask"],
		self.node_list["Skill12CDMask"],
	}

	for i = 1, 12 do
		if self.skill_cd_progress[i] then
			self.skill_cd_progress[i].image.fillAmount = 0
		end
	end

	self.skill_cd_time = {
		false,
		self.node_list["Skill1TxtCDTime"],
		self.node_list["Skill2TxtCDTime"],
		self.node_list["Skill3TxtCDTime"],
		self.node_list["Skill4TxtCDTime"],
		
		self.node_list["Skill6TxtCDTime"],
		self.node_list["Skill5TxtCDTime"],
		self.node_list["Skill8TxtCDTime"],
		self.node_list["Skill9TxtCDTime"],
		self.node_list["Skill10TxtCDTime"],
		self.node_list["Skill11TxtCDTime"],
		self.node_list["Skill12TxtCDTime"],
	}

	self.skill_lock = {
		false,
		self.node_list["Skill1Lock"],
		self.node_list["Skill2Lock"],
		self.node_list["Skill3Lock"],
		self.node_list["Skill4Lock"],
		false,
		false,
		
		false,
		false,
		false,
		false,
		false,
	}

	self.general_skill = {}
	self.general_skill.cd_time = self.node_list["BianShenCDText"]
	self.general_skill.is_bianshen = false
	self.general_skill.show_effect = false

	self.skill_count_down = {}
	self.speci_skill_count_down = {}

	-- 监听UI事件
	self.node_list["SkillAttackBtn"].event_trigger_listener:AddPointerDownListener(BindTool.Bind(self.OnClickAttackDown, self, self.skill_infos[1]))
	self.node_list["SkillAttackBtn"].event_trigger_listener:AddPointerUpListener(BindTool.Bind(self.OnClickAttackUp, self, self.skill_infos[1]))

	self.node_list["Skill1"].button:AddClickListener(BindTool.Bind(self.OnClickSkill, self, self.skill_infos[2]))
	self.node_list["Skill2"].button:AddClickListener(BindTool.Bind(self.OnClickSkill, self, self.skill_infos[3]))
	self.node_list["Skill3"].button:AddClickListener(BindTool.Bind(self.OnClickSkill, self, self.skill_infos[4]))
	self.node_list["Skill4"].button:AddClickListener(BindTool.Bind(self.OnClickSkill, self, self.skill_infos[5]))

	self.node_list["Skill5"].event_trigger_listener:AddPointerUpListener(BindTool.Bind(self.OnClickSkill5Up, self, self.skill_infos[7]))
	self.node_list["Skill5"].event_trigger_listener:AddPointerDownListener(BindTool.Bind(self.OnClickSkill5Down, self, self.skill_infos[7]))

	self.node_list["Skill51"].button:AddClickListener(BindTool.Bind(self.ClickSkill5Change, self, 1))
	self.node_list["Skill52"].button:AddClickListener(BindTool.Bind(self.ClickSkill5Change, self, 2))
	
	self.node_list["Skill6"].button:AddClickListener(BindTool.Bind(self.OnClickSkill, self, self.skill_infos[6]))
	self.node_list["Skill8"].button:AddClickListener(BindTool.Bind(self.OnClickSkill, self, self.skill_infos[8]))
	self.node_list["Skill9"].button:AddClickListener(BindTool.Bind(self.OnClickSkill, self, self.skill_infos[9]))
	self.node_list["Skill10"].button:AddClickListener(BindTool.Bind(self.OnClickSkill, self, self.skill_infos[10]))
	self.node_list["Skill11"].button:AddClickListener(BindTool.Bind(self.OnClickSkill, self, self.skill_infos[11]))
	self.node_list["Skill12"].button:AddClickListener(BindTool.Bind(self.OnClickSkill, self, self.skill_infos[12]))
	self.node_list["Skill13"].button:AddClickListener(BindTool.Bind(self.OnClickForward, self))

	self.node_list["Skill8BtnArrowLeft"].button:AddClickListener(BindTool.Bind(self.OnClickQieHuan, self, self.skill_infos[8], "left"))
	self.node_list["Skill8BtnArrowRight"].button:AddClickListener(BindTool.Bind(self.OnClickQieHuan, self, self.skill_infos[8], "right"))

	self.node_list["SkillJinJie"].button:AddClickListener(BindTool.Bind(self.OnClickJinjieEquipSkill, self))

	self.node_list["SpecSkillSwitchBtn"].toggle:AddClickListener(BindTool.Bind(self.OnSwitchSpecSkills, self))
	self.node_list["ActSkillSwitchBtn"].button:AddClickListener(BindTool.Bind(self.OnSwitchActivitySkills, self))
	self.node_list["BtnBianShen"].button:AddClickListener(BindTool.Bind(self.ClickGeneralSkill, self))

	self.node_list["JumpButton"].button:AddClickListener(BindTool.Bind(self.OnClickJump, self))
	self.node_list["LandingButton"].button:AddClickListener(BindTool.Bind(self.OnClickLanding, self))
	self.node_list["LandingButton"]:SetActive(false)
	self.node_list["DoubleJump"]:SetActive(false)

	self:IsShowJumpBtn()

	-- 监听系统事件
	self.player_data_change_callback = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.player_data_change_callback)

	self.recv_main_role_info_handle = GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.OnRecvMainRoleInfo, self))
	self.role_skill_change_handle = GlobalEventSystem:Bind(MainUIEventType.ROLE_SKILL_CHANGE, BindTool.Bind(self.OnSkillChange, self))
	self.scene_complete_handle = GlobalEventSystem:Bind(SceneEventType.SCENE_ALL_LOAD_COMPLETE, BindTool.Bind1(self.OnSkillChange, self))
	self.role_use_skill_handle = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_USE_SKILL, BindTool.Bind(self.OnMainRoleUseSkill, self))
	-- self.jinjie_equip_skill_change_handle = GlobalEventSystem:Bind(MainUIEventType.JINJIE_EQUIP_SKILL_CHANGE, BindTool.Bind(self.SetJinjieSkillInfo, self))

	self.change_area_type = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_CHANGE_AREA_TYPE, BindTool.Bind(self.OnMainRoleSwitchScene, self))
	self.show_mode_list_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_MODE_LIST, BindTool.Bind(self.OnMainUIModeListChange, self))
	self.menu_toggle_change = GlobalEventSystem:Bind(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, BindTool.Bind(self.PortraitToggleChange, self))

	self.enter_jump = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_ENTER_JUMP_STATE, BindTool.Bind(self.OnMainRoleJumpState, self, true))
	self.exit_jump = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_EXIT_JUMP_STATE, BindTool.Bind(self.OnMainRoleJumpState, self, false))
	self.enabled_qing_gong = GlobalEventSystem:Bind(OtherEventType.ENABLE_QING_GONG_CHANGE, function (enabled)
		local is_visible = enabled
		self.node_list["JumpButton"]:SetActive(is_visible)
	end)

	self.mojie_info_event = BindTool.Bind(self.OnSkillChange, self, "mojie")
	MojieData.Instance:AddListener(MojieData.MOJIE_EVENT, self.mojie_info_event)

	-- 首次刷新数据
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self:PlayerDataChangeCallback("nuqi", vo.nuqi, 0)
	self:PlayerDataChangeCallback("level", vo.level, vo.level)
	self:OnRecvMainRoleInfo(SkillData.ANGER_SKILL_ID)
	self:OnSkillChange()
	self:FlushGeneralSkill()

	-- 定位技能按钮位置
	self.skill_icon_pos_list = {
		[1] = self.node_list["Skill1"],
		[2] = self.node_list["Skill2"],
		[3] = self.node_list["Skill3"],
		[4] = self.node_list["Skill4"],
		[5] = self.node_list["Skill5"],
		[6] = self.node_list["Skill6"],
		[7] = self.node_list["Skill7"],
		[8] = self.node_list["Skill8"],
		[9] = self.node_list["Skill9"],
		[10] = self.node_list["Skill10"],
		[11] = self.node_list["Skill11"],
		[12] = self.node_list["Skill12"],
	}

	Runner.Instance:AddRunObj(self, 6)

	-- 是否显示四个小技能（某些场景需要用其他技能代替）

	self.enter_safe_area_animator = self.node_list["EnterSafeArea"].animator
	self.leave_safe_area_animator = self.node_list["LeaveSafeArea"].animator

	self.show_mojie_skill = false
	self.is_show_spc_skill = true
	self.is_guild_station = false

	self.select_obj_group_list = {}
	self.is_show_jump = false
	self.qinggong_index = 0
	self.cur_qinggong_time = 0.3
	self.jump_energy = JUMP_MAX_ENERGY
	-- self:SetJinjieSkillInfo()
end


function MainUIViewSkill:FlusChengZhuSkill()
	self:OnSkillChange()
end

function MainUIViewSkill:__delete()
	PlayerData.Instance:UnlistenerAttrChange(self.player_data_change_callback)
	self.player_data_change_callback = nil

	Runner.Instance:RemoveRunObj(self)

	GlobalEventSystem:UnBind(self.recv_main_role_info_handle)
	GlobalEventSystem:UnBind(self.role_skill_change_handle)
	GlobalEventSystem:UnBind(self.role_use_skill_handle)
	GlobalEventSystem:UnBind(self.enter_jump)
	GlobalEventSystem:UnBind(self.exit_jump)
	GlobalEventSystem:UnBind(self.enabled_qing_gong)
	

	if self.scene_complete_handle ~= nil then
		GlobalEventSystem:UnBind(self.scene_complete_handle)
		self.scene_complete_handle = nil
	end
	
	if self.change_area_type ~= nil then
		GlobalEventSystem:UnBind(self.change_area_type)
		self.change_area_type = nil
	end
	GlobalTimerQuest:CancelQuest(self.delete_area_tips_timer)
	GlobalTimerQuest:CancelQuest(self.skill5_time_quest)
	self.skill5_time_quest = nil
	if self.show_mode_list_event ~= nil then
		GlobalEventSystem:UnBind(self.show_mode_list_event)
		self.show_mode_list_event = nil
	end
	if self.menu_toggle_change ~= nil then
		GlobalEventSystem:UnBind(self.menu_toggle_change)
		self.menu_toggle_change = nil
	end
	if MojieData.Instance then
		MojieData.Instance:RemoveListener(MojieData.MOJIE_EVENT, self.mojie_info_event)
	end

	for i, v in ipairs(self.skill_infos) do
		CountDown.Instance:RemoveCountDown(v.countdonw1)
		CountDown.Instance:RemoveCountDown(v.countdonw2)
	end

	if nil ~= self.common_skill_timer then
		GlobalTimerQuest:CancelQuest(self.common_skill_timer)
		self.common_skill_timer = nil
	end

	if self.cur_qinggong_timer ~= nil then
		CountDown.Instance:RemoveCountDown(self.cur_qinggong_timer)
		self.cur_qinggong_timer = nil
	end

	if self.add_energy_time then
		GlobalTimerQuest:CancelQuest(self.add_energy_time)
		self.add_energy_time = nil
	end
	self.show_ping_left = nil
	self.show_ping_rignt = nil
	self.is_guild_station = nil

	if self.qinggong_down_guide_eff  ~= nil then
		ResMgr:Destroy(self.qinggong_down_guide_eff)
		self.qinggong_down_guide_eff = nil
	end

	if self.qinggong_guide_eff  ~= nil then
		ResMgr:Destroy(self.qinggong_guide_eff)
		self.qinggong_guide_eff = nil
	end

end

function MainUIViewSkill:SetSkillLock(index, is_lock)
	if self.skill_icons[index] and not TipsCtrl.Instance:GetIsOpenNewSkill() then
		self.skill_icons[index]:SetActive(not is_lock)
	end
	if self.skill_lock[index] then
		self.skill_lock[index]:SetActive(is_lock)
	end
	if self.skill_cd_progress[index] then
		self.skill_cd_progress[index]:SetActive(not is_lock)
	end
	if self.skill_cd_time[index] then
		self.skill_cd_time[index]:SetActive(not is_lock)
	end
	if self.skill_cd_progress[index] then
		self.skill_cd_progress[index]:SetActive(not is_lock)
	end
end

function MainUIViewSkill:ShowSkill6Effect(param)
	if false == param then
		self.node_list["Skill6Img"]:SetActive(true)
		self.node_list["Skill6NameTxt"]:SetActive(true)
		self.node_list["Skill6NameBg"]:SetActive(true)
		for i = 1, 2 do
			self.node_list["Skill6Effect" .. i]:SetActive(false)
		end
		return
	end

	self.node_list["Skill6Img"]:SetActive(false)
	self.node_list["Skill6NameTxt"]:SetActive(false)
	self.node_list["Skill6NameBg"]:SetActive(false)

	for i = 1, 2 do
		self.node_list["Skill6Effect" .. i]:SetActive(param == i)
	end
end	

function MainUIViewSkill:SetJinjieSkillInfo()
	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	if game_vo.upgrade_next_skill < 0 then
		return
	end

	local gauge_count = AdvanceData.Instance:GetJinjieGaugeCount()
	if nil == gauge_count then
		return
	end

	self.node_list["SkillJinJie"]:SetActive(gauge_count > 0)--进阶装备技能先屏蔽
	self.node_list["SkillJinJieTxtCDTime"].text.text = string.format("%s/%s", game_vo.upgrade_cur_calc_num, gauge_count)

	local bundle, asset = AdvanceData.Instance:GetEquipSkillResPath(game_vo.upgrade_next_skill)
	self.node_list["SkillJinJieImg"].image:LoadSprite(bundle, asset .. ".png")
end

function MainUIViewSkill:OnClickJinjieEquipSkill()
	ViewManager.Instance:Open(ViewName.AdvanceEquipSkillView)
end

--技能切换
function MainUIViewSkill:OnClickQieHuan(skill_info,flag)
	local skill_id_list =  EquipData.Instance:GetEquipSkilIdList()
	local change_skill_id = 0
	local cur_skill_id = skill_info.skill_id
	if nil == skill_id_list then
		return
	end
	for i = 1, 3 do
		local index = i
		if flag == "left" then
			index = 4 - i
		end
		if skill_id_list[index] then
			if flag == "right" and skill_id_list[index] > cur_skill_id then
				change_skill_id = skill_id_list[index]
				break
			elseif flag == "left" and skill_id_list[index] < cur_skill_id then
				change_skill_id = skill_id_list[index]
				break
			end
		end
	end
	local skill_icon_list = {[170] = "170",[171] = "171" ,[172] = "172"}

	local skill_data = SkillData.Instance:GetSkillInfoById(change_skill_id)
	if skill_data then
		self.skill_infos[8].is_exist = true
		self.skill_infos[8].skill_id = skill_data.skill_id
		self.skill_infos[8].skill_icon = skill_icon_list[skill_data.skill_id]
		self:OnMainRoleUseSkill(skill_data.skill_id)
	end

	self:OnFlush({skill = true})

end

function MainUIViewSkill:SetMojiePanelAnimation(value)
	if self.show_mojie_skill and self.show_mojie_panel_anmi.isActiveAndEnabled then
		self.show_mojie_panel_anmi:SetBool("fold", value)
	end
end


function MainUIViewSkill:OnMainUIModeListChange(is_show)
	self:SetMojiePanelAnimation(false)
end

function MainUIViewSkill:PortraitToggleChange(state, from_joystick)
	self:SetMojiePanelAnimation(false)
end

function MainUIViewSkill:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "nuqi" then
		-- self.skill_cd_progress[6]:SetValue(value / COMMON_CONSTS.NUQI_FULL)
		-- if (value >= COMMON_CONSTS.NUQI_FULL and old_value < COMMON_CONSTS.NUQI_FULL) or
		--  (value < COMMON_CONSTS.NUQI_FULL and old_value >= COMMON_CONSTS.NUQI_FULL) then
		-- 	self:CheckNuqiEff()
		-- end
	elseif attr_name == "level" then
		self:IsShowJumpBtn()
	end
end

function MainUIViewSkill:IsShowJumpBtn()
	if self.node_list["JumpButton"] then
		local enabled_qing_gong = false
		local main_role = Scene.Instance:GetMainRole()
		if main_role then
			enabled_qing_gong = main_role:IsCanUseQingGong()
		end
		self.node_list["JumpButton"]:SetActive(enabled_qing_gong)
	end
end

function MainUIViewSkill:SetJumpButIsShow(value)
	if value then
		self:IsShowJumpBtn()
	else
		if self.node_list["JumpButton"] then
			self.node_list["JumpButton"]:SetActive(value)
		end
	end
end

function MainUIViewSkill:OnRecvMainRoleInfo()
	local prof = PlayerData.Instance:GetAttr("prof")
	local base_prof = PlayerData.Instance:GetRoleBaseProf(prof)
	local roleskill_auto = ConfigManager.Instance:GetAutoConfig("roleskill_auto")
	local skillinfo = roleskill_auto.skillinfo

	local skill_list = {}
	-- local kill_skill_id = 5

	-- 四个小技能隐藏显示
	local is_show_normal_skill = not_show_normal_skill_scene_type[Scene.Instance:GetSceneType()] == nil
	self.node_list["Skill1"]:SetActive(is_show_normal_skill)
	self.node_list["Skill2"]:SetActive(is_show_normal_skill)
	self.node_list["Skill3"]:SetActive(is_show_normal_skill)
	self.node_list["Skill4"]:SetActive(is_show_normal_skill)
	for skill_id, v in pairs(skillinfo) do
		if base_prof == math.modf(skill_id / 100) then
			skill_list[v.skill_index] = v
		-- elseif skill_id == kill_skill_id then
		-- 	skill_list[5] = v
		elseif skill_id == 6 then
			skill_list[11] = v
		elseif skill_id == 7 then
			skill_list[12] = v
		end
	end
	for i, v in ipairs(self.skill_infos) do
		v.skill_id = skill_list[i] and skill_list[i].skill_id or 0
	end
end

function MainUIViewSkill:CheckNuqiEff()
	local skill_info = SkillData.Instance:GetSkillInfoById(SkillData.ANGER_SKILL_ID)
	local cd = 1
	if skill_info and PlayerData.Instance.role_vo.special_appearance ~= SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_TERRITORYWAR then
		cd = skill_info.cd_end_time - Status.NowTime
	end
	self.node_list["Skill4Effect"]:SetActive(cd <= 0)
	if cd <= 0 and self.skill_cd_progress[5] then
		self.skill_cd_progress[5].image.fillAmount = 1
		self.node_list["Skill4CDMask"].image.fillAmount = 0
	end
end

function MainUIViewSkill:OnSkillChange(change_type, skill_id)
	local mojie_index = 0
	local skill_info = nil
	local skill_cfg = nil
	for i, v in ipairs(self.skill_infos) do
		if i == 7 then
			v.is_exist = false
			v.skill_id = 0
			for k1,v1 in pairs(MojieData.SKILL_T) do
				skill_info = SkillData.Instance:GetSkillInfoById(v1)
				if skill_info then
					self.show_mojie_skill = true
					v.is_exist = nil ~= skill_info
					v.skill_id = v1
					skill_cfg = SkillData.GetSkillinfoConfig(v.skill_id)
					if nil ~= skill_cfg then
						v.skill_icon = skill_cfg.skill_icon
					end
				else
					mojie_index = mojie_index + 1
					local vo = self.other_mojie_info[mojie_index]
					if vo then
						vo.skill_id = v1
						skill_cfg = SkillData.GetSkillinfoConfig(vo.skill_id)
						if nil ~= skill_cfg then
							vo.skill_icon = skill_cfg.skill_icon
						end
					end
				end
			end
		elseif i == 6 then
			v.is_exist = false
			v.skill_id = 0
			skill_info = SkillData.Instance:GetCurGoddessSkill()
			if skill_info then
				v.is_exist = nil ~= skill_info
				v.skill_id = skill_info.skill_id
				skill_cfg = SkillData.GetSkillinfoConfig(v.skill_id)
				if nil ~= skill_cfg then
					v.skill_icon = skill_cfg.skill_icon
				end
			end
		elseif i == 8 then
			local skill_list = {170, 171, 172}
			local skill_icon_list = {[170] = 170,[171] = 171 ,[172] = 172}
			v.is_exist = SkillData.Instance:GetSkillInfoById(v.skill_id) ~= nil
			-- v.skill_id = 0
			for k1,v1 in pairs(skill_list) do
				skill_info = SkillData.Instance:GetSkillInfoById(v1)
				if skill_info and not v.is_exist then
					v.is_exist = nil ~= skill_info
					v.skill_id = skill_info.skill_id
					-- skill_cfg = SkillData.GetNormalSkillinfoConfig(v.skill_id)
					v.skill_icon = skill_icon_list[skill_info.skill_id]
				end
			end
		elseif i == 9 or i == 10 then
			local skill_id = 0
			local prof = PlayerData.Instance:GetRoleBaseProf()
			if i == 9 then
				skill_id = ZHUAN_ZHI_SKILL1[prof]
			elseif i == 10 then
				skill_id = ZHUAN_ZHI_SKILL2[prof]
			end
			skill_info = SkillData.Instance:GetSkillInfoById(tonumber(skill_id))
			if skill_info then
				v.is_exist = nil ~= skill_info
				v.skill_id = skill_info.skill_id
				if i == 9 then
					v.skill_icon = ZHUAN_ZHI_SKILL1[prof]
				elseif i == 10 then
					v.skill_icon = ZHUAN_ZHI_SKILL2[prof]
				end
			end
		elseif i == 11 then
			v.is_exist = false
			v.skill_id = 0
			skill_info = SkillData.Instance:GetSkillInfoById(6)
			if skill_info ~= nil then
				local scene_id= Scene.Instance:GetSceneId()
				v.is_exist = nil ~= skill_info and scene_id ~= 609 and scene_id ~= 5001 and scene_id ~= 5002 and scene_id ~= 9050
				v.skill_id = skill_info.skill_id
				skill_cfg = SkillData.GetSkillinfoConfig(v.skill_id)
				if nil ~= skill_cfg then
					v.skill_icon = skill_cfg.skill_icon
				end
			end
		elseif i == 12 then
			v.is_exist = false
			v.skill_id = 0
			skill_info = SkillData.Instance:GetSkillInfoById(7)
			if skill_info ~= nil then
				local scene_id = Scene.Instance:GetSceneId()
				v.is_exist = nil ~= skill_info and IS_ON_CROSSSERVER and (BossData.Instance:IsShenYuBossScene(scene_id) or BossData.Instance:IsCrossBossScene(scene_id) or BossData.Instance:IsFamilyBossScene(scene_id) or BossData.Instance:IsBossFamilyKfScene(scene_id))
				v.skill_id = skill_info.skill_id
				skill_cfg = SkillData.GetSkillinfoConfig(v.skill_id)
				if nil ~= skill_cfg then
					v.skill_icon = skill_cfg.skill_icon
				end
			end
		else
			skill_info = SkillData.Instance:GetSkillInfoById(v.skill_id)
			v.is_exist = nil ~= skill_info
			skill_cfg = SkillData.GetSkillinfoConfig(v.skill_id)
			if nil ~= skill_cfg then
				if v.skill_id == 5 then
					local prof = PlayerData.Instance:GetAttr("prof")
					local base_prof = PlayerData.Instance:GetRoleBaseProf(prof)
					v.skill_icon = skill_cfg.skill_icon + base_prof
				else
					v.skill_icon = skill_cfg.skill_icon
				end
			end
		end
		if skill_info and ("list" == change_type or nil == change_type) then
			if v.skill_id ~= SkillData.ANGER_SKILL_ID or not self.has_cheak_nuqi then
				self:OnMainRoleUseSkill(v.skill_id)
				if v.skill_id == SkillData.ANGER_SKILL_ID then
					self:CheckNuqiEff()
				end
			end
		end
	end
	if self.skill_infos[1] and SkillData.Instance:GetSkillInfoById(self.skill_infos[1].skill_id or 0) then
		self.has_cheak_nuqi = true
	end
	local skill_data = {}
	for i = 1, 5 do
		skill_data[i] = {}
		skill_data[i].is_exist = false
		if self.skill_infos[i] then
			skill_data[i].is_exist = self.skill_infos[i].is_exist
			skill_data[i].skill_id = self.skill_infos[i].skill_id
		end
	end
	MainUIData.Instance:SetSkillData(skill_data)
	IosAuditSender:UpdateSkillData()
	self.parent:Flush("skill")
end

function MainUIViewSkill:OnMainRoleUseSkill(skill_id)
	local prof = PlayerData.Instance:GetRoleBaseProf()
	if PlayerData.Instance.role_vo.special_appearance == SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_TERRITORYWAR then
		for i, v in ipairs(self.skill_infos) do
			if i == 4 then
				if self.speci_skill_count_down[skill_id] then
					return
				end
				self.speci_skill_count_down[skill_id] = true
				local skill_info = ClashTerritoryData.Instance:GetSkillInfoById(skill_id)
				if skill_info and skill_info.index ~= 1 then
					local cd = skill_info.cd_end_time - Status.NowTime
					if cd < 1 then
						self.speci_skill_count_down[skill_id] = false
						return
					end
					self.has_Flush_appearance = true
					self.skill_cd_progress[i].image.fillAmount = 1.0
					CountDown.Instance:RemoveCountDown(v.countdonw1)
					CountDown.Instance:RemoveCountDown(v.countdonw2)
					v.countdonw1 = CountDown.Instance:AddCountDown(
						cd, 0.05, function(elapse_time, total_time)
							local progress = (total_time - elapse_time) / total_time
							self.skill_cd_progress[i].image.fillAmount = progress
						end)

					self.skill_cd_time[i].text.text = math.ceil(cd) > 0 and math.ceil(cd) or ""
					v.countdonw2 = CountDown.Instance:AddCountDown(
						cd, 1.0, function(elapse_time, total_time)
							self.skill_cd_time[i].text.text = math.ceil(total_time - elapse_time) > 0 and math.ceil(total_time - elapse_time) or ""
							if total_time - elapse_time <= 0 then
								self.speci_skill_count_down[skill_id] = false
							end
						end)
				end
				break
			end
		end
	elseif math.floor(skill_id / 10) == math.floor(self.skill_infos[1].skill_id / 10) then
		-- 如果是主动技能, 更新主动技能图标
		local skill_cfg = SkillData.GetSkillinfoConfig(skill_id)
		if nil ~= skill_cfg then
			local bundle, asset = ResPath.GetRoleSkillIcon(skill_cfg.skill_icon)
			self.skill_icons[1].image:LoadSprite(bundle, asset .. ".png")
		end

		if nil ~= self.common_skill_timer then
			GlobalTimerQuest:CancelQuest(self.common_skill_timer)
			self.common_skill_timer = nil
		end

		self.common_skill_timer = GlobalTimerQuest:AddDelayTimer(function()
			local bundle, asset = ResPath.GetRoleSkillIcon(self.skill_infos[1].skill_icon)
			self.skill_icons[1].image:LoadSprite(bundle, asset .. ".png")
			self.common_skill_timer = nil
		end, 1.0)
	elseif (skill_id % 10 == 1 and (skill_id < 170 or skill_id > 173)) 
			or skill_id == ZHUAN_ZHI_SKILL1[prof] 
			or skill_id == ZHUAN_ZHI_SKILL2[prof]
			or MojieData.IsMojieSkill(skill_id) 
			or GoddessData.Instance:IsGoddessSkill(skill_id) 
			or skill_id == SkillData.ANGER_SKILL_ID 
			or skill_id == 6 or skill_id == 7 then

		-- 触发技能的CD倒计时
		for i, v in ipairs(self.skill_infos) do
			if v.skill_id == skill_id then
				if self.skill_count_down[skill_id] and not GoddessData.Instance:IsGoddessSkill(skill_id) then
					return
				end
				self.skill_count_down[skill_id] = true
				local skill_info = SkillData.Instance:GetSkillInfoById(skill_id)
				local cd = skill_info.cd_end_time - Status.NowTime

				local skill_cd_progress = self.skill_cd_progress[i]
				if skill_id == SkillData.ANGER_SKILL_ID then
					skill_cd_progress.image.fillAmount = 0.0
					self.node_list["Skill4CDMask"].image.fillAmount = 1.0
					self:CheckNuqiEff()
				else
					skill_cd_progress.image.fillAmount = 1.0
				end

				CountDown.Instance:RemoveCountDown(v.countdonw1)
				CountDown.Instance:RemoveCountDown(v.countdonw2)

				v.countdonw1 = CountDown.Instance:AddCountDown(
					cd, 0.05, function(elapse_time, total_time)
						local progress = (total_time - elapse_time) / total_time
						if skill_id == SkillData.ANGER_SKILL_ID then
							skill_cd_progress.image.fillAmount = 1 - progress
							self.node_list["Skill4CDMask"].image.fillAmount = progress
							if progress <= 0 then
								self:CheckNuqiEff()
								self.skill_count_down[skill_id] = false
							end
						else
							skill_cd_progress.image.fillAmount = progress
						end
					end)
				if self.skill_cd_time[i] then
					self.skill_cd_time[i].text.text = math.ceil(cd) > 0 and math.ceil(cd) or ""
					v.countdonw2 = CountDown.Instance:AddCountDown(
						cd, 1.0, function(elapse_time, total_time)
							self.skill_cd_time[i].text.text = math.ceil(total_time - elapse_time) > 0 and math.ceil(total_time - elapse_time) or ""
							if total_time - elapse_time <= 0 then
								self.skill_count_down[v.skill_id] = false
							end
						end)
				end
				break
			end
		end
		-- 粉色装备技能
	elseif skill_id >= 170 and skill_id <= 172 then
		for i, v in ipairs(self.skill_infos) do
			if v.skill_id == skill_id then
				-- if self.skill_count_down[skill_id] then
				-- 	return
				-- end
				
				local skill_info = SkillData.Instance:GetSkillInfoById(skill_id)
				local cd = skill_info.cd_end_time - Status.NowTime
				if cd > 0 then
					self.skill_count_down[skill_id] = true
				end

				local skill_cd_progress = self.skill_cd_progress[8]
				skill_cd_progress:SetValue(1.0)

				CountDown.Instance:RemoveCountDown(v.countdonw1)
				CountDown.Instance:RemoveCountDown(v.countdonw2)
				v.countdonw1 = CountDown.Instance:AddCountDown(
					cd, 0.05, function(elapse_time, total_time)
						local progress = (total_time - elapse_time) / total_time
						skill_cd_progress:SetValue(progress)
					end)
				break
			end
		end
	end
end

function MainUIViewSkill:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "flush_bianshen_cd" then
			self:GeneralBianShenCd()
		elseif k == "check_skill" then
			local is_spec = false
			local role = Scene.Instance:GetMainRole()
			local war_state = false
			if role ~= nil then
				war_state = role:IsWarSceneState()
			end

			if self.skill_infos then
				for k,v in pairs(self.skill_infos) do
					if v ~= nil and v.skill_id ~= nil and SkillData.Instance:CheckIsWarSceneSkill(v.skill_id) ~= nil and not war_state then
						is_spec = true
						break
					end 
				end
			end
			if v.is_change or is_spec then
				self:OnRecvMainRoleInfo()
				self:OnSkillChange(nil, nil, true)
			end
			self:FlushGeneralSkill()
		end
	end

	local is_show = SceneType.FarmHunting == Scene.Instance:GetSceneType()
	self.node_list["Skill13"]:SetActive(is_show)

	if param_t.goddess_skill_tips then
		self:ShowSkill6Effect(2)
		self.is_show_kill6_effect = false
		GlobalTimerQuest:AddDelayTimer(function()
			self:ShowSkill6Effect(false)
		end, 0.5)
		return
	end
	if nil == param_t.skill then
		return
	end

	local show_mojie, show_goddess, show_chengzhu, show_guild_skill = false, false, false, false
	for i, v in ipairs(self.skill_infos) do
		if i == 7 then
			show_mojie = v.is_exist
			self.node_list["Skill5Panel"]:SetActive(v.is_exist)
			if v.skill_id ~= 0 then
				local skill_name = SkillData.GetSkillinfoConfig(v.skill_id).pram_1
				if skill_name then
					self.node_list["Skill5NameTxt"].text.text = skill_name
				end
			end
		elseif i == 6 then
			self.node_list["Skill6"]:SetActive(v.is_exist)
			show_goddess = v.is_exist
			if v.skill_id ~= 0 then
				local skill_name = SkillData.GetSkillinfoConfig(v.skill_id).pram_1
				if skill_name then
					self.node_list["Skill6NameTxt"].text.text = skill_name
				end
			end
			if self.goddess_is_lock and v.is_exist then
				self:ShowSkill6Effect(1)
				self.is_show_kill6_effect = true
			end
			if SkillData.SKILL_INFO_GET then
				self.goddess_is_lock = not v.is_exist
			end
		elseif i == 8 then
			self.node_list["PanelSkill8"]:SetActive(v.is_exist)
			if v.skill_id + 1 > 173 then
				UI:SetGraphicGrey(self.node_list["Skill8BtnArrowLeft"], true)
			else
				UI:SetGraphicGrey(self.node_list["Skill8BtnArrowLeft"], false)
			end
			if v.skill_id - 1 < 170 then
				UI:SetGraphicGrey(self.node_list["Skill8BtnArrowRight"], true)
			else
				UI:SetGraphicGrey(self.node_list["Skill8BtnArrowRight"], false)
			end

			local is_show_next_arrow = false
			local is_show_last_arrow = false
			local skill_id_list = EquipData.Instance:GetEquipSkilIdList() or {}
			for k2,v2 in pairs(skill_id_list) do
				if v2 > v.skill_id then
					is_show_next_arrow = true
				elseif v2 < v.skill_id then
					is_show_last_arrow = true
				end
			end

			self.node_list["Skill8BtnArrowLeft"]:SetActive(is_show_last_arrow)
			self.node_list["Skill8BtnArrowRight"]:SetActive(is_show_next_arrow)
		elseif i == 9 or i == 10 then
			local prof = PlayerData.Instance:GetRoleBaseProf()
			if i == 9 then
				v.skill_icon = ZHUAN_ZHI_SKILL1[prof]
			elseif i == 10 then
				v.skill_icon = ZHUAN_ZHI_SKILL2[prof]
			end
			self.node_list["Skill" .. i]:SetActive(v.is_exist)
			-- UI:SetGraphicGrey(self.node_list["Skill" .. i], not v.is_exist)
			self.node_list["SkillTips".. i]:SetActive(false)
		elseif i == 11 then
			show_chengzhu = v.is_exist
			self.node_list["Skill" .. i]:SetActive(v.is_exist)
		elseif i == 12 then
			show_guild_skill = v.is_exist
			self.node_list["Skill" .. i]:SetActive(v.is_exist)
		else
			self:SetSkillLock(i, not v.is_exist)
		end

		if nil ~= v.skill_icon then
			if v.is_exist or i == 9 or i == 10 then
				local prof = PlayerData.Instance:GetRoleBaseProf()
				local skill_cfg = SkillData.Instance:GetActiveSkillListCfg()
				local skill_txt = ""
				if i == 9 then
					v.skill_icon = ZHUAN_ZHI_SKILL1[prof]
					for i,v in pairs(skill_cfg) do
						if v.skill_id == ZHUAN_ZHI_SKILL1[prof] then
							skill_txt = v.pram_1
						end
					end
					self.node_list["SkillTxt9"].text.text = skill_txt
				elseif i == 10 then
					v.skill_icon = ZHUAN_ZHI_SKILL2[prof]
					for i,v in pairs(skill_cfg) do
						if v.skill_id == ZHUAN_ZHI_SKILL2[prof] then
							skill_txt = v.pram_1
						end
					end
					self.node_list["SkillTxt10"].text.text = skill_txt
				end
				local bundle, asset = ResPath.GetRoleSkillIcon(v.skill_icon)
				self.skill_icons[i].image:LoadSprite(bundle, asset .. ".png")
			end
		end

		v.territory_lock = false

		if PlayerData.Instance.role_vo.special_appearance == SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_TERRITORYWAR then
			if i == 7 then
				self.node_list["Skill5Panel"]:SetActive(false)
			elseif i == 6 then
				self.node_list["Skill6"]:SetActive(false)
			else
				v.territory_lock = i ~= 1 and i ~= 4
				self:SetSkillLock(i, v.territory_lock)
			end
			if i == 1 or i == 4 then
				local skill_icon = ClashTerritoryData.Instance:GetTerritorySkillIcon(SkillData.Instance:GetRealSkillIndex(v.skill_id))
				if skill_icon then
					local bundle, asset = ResPath.GetRoleSkillIcon(skill_icon)
					self.skill_icons[i].image:LoadSprite(bundle, asset .. ".png")
				end
			end
			if not self.has_Flush_appearance and i ~= 1 then
				self:OnMainRoleUseSkill(v.skill_id)
			end
		else
			self.has_Flush_appearance = false
		end

		if param_t.special_appearance and i == 4 and v.is_exist then
			self.speci_skill_count_down = {}
			self:OnMainRoleUseSkill(v.skill_id)
			self:CheckNuqiEff()
		end
	end

	local is_active_spc_skill = show_mojie or show_goddess or show_chengzhu or show_guild_skill
	self.node_list["PanelSpecSkills"]:SetActive(is_active_spc_skill)
	if SceneType.FarmHunting == Scene.Instance:GetSceneType() then
		self.node_list["PanelSpecSkills"]:SetActive(true)
	end
	self.node_list["ActSkillSwitchBtn"]:SetActive(is_active_spc_skill)

	for i,v in ipairs(self.other_mojie_info) do
		if v.skill_icon then
			local bundle, asset = ResPath.GetRoleSkillIcon(v.skill_icon)
			self.other_mojie_icon[i].image:LoadSprite(bundle, asset .. ".png")
			self.other_mojie_name[i].text.text = SkillData.GetSkillinfoConfig(v.skill_id).pram_1
			if self.node_list["Skill5" .. i .. "Img"] then
				local is_gray = MojieData.Instance:GetMojieInfoBySkillId(v.skill_id) == nil
				UI:SetGraphicGrey(self.node_list["Skill5" .. i .. "Img"], is_gray)
			end
		end
	end
end

function MainUIViewSkill:ClickSkill5Change(index)
	local skill_id = self.other_mojie_info[index].skill_id
	if skill_id > 0 then
		local mojie_info = MojieData.Instance:GetMojieInfoBySkillId(skill_id)
		if nil == mojie_info then
			SysMsgCtrl.Instance:ErrorRemind(Language.Role.NotActive)
		else
			MojieCtrl.SendMojieChangeSkillReq(mojie_info.mojie_skill_id, mojie_info.mojie_skill_type, mojie_info.mojie_skill_level)
		end
	end
	self:SetMojiePanelAnimation(false)
end

local click_attack_down = nil
function MainUIViewSkill:OnClickAttackDown(skill_info)
	click_attack_down = UnityEngine.Input.mousePosition
end

function MainUIViewSkill:OnClickAttackUp(skill_info)
	if nil == click_attack_down then return end
	local off_y = click_attack_down.y - UnityEngine.Input.mousePosition.y
	if off_y > 1000 or off_y < -1000 then
		return
	elseif math.abs(off_y) < 20 then
		self:OnClickSkill(skill_info)
	else
		if off_y < 0 then
			GlobalEventSystem:Fire(MainUIEventType.OPEN_NEAR_VIEW)
		else
			self:SelectObj(SceneObjType.Monster, SelectType.Enemy)
		end
	end
	click_attack_down = nil
end

function MainUIViewSkill:SelectObj(obj_type, select_type)
	-- 获取所有可选对象
	local obj_list = Scene.Instance:GetObjListByType(obj_type)
	if not next(obj_list) then
		return
	end

	local temp_obj_list = {}
	local x, y = Scene.Instance:GetMainRole():GetLogicPos()
	local target_x, target_y = 0, 0

	local can_select = true
	for k, v in pairs(obj_list) do
		can_select = true
		if SelectType.Friend == select_type then
			can_select = Scene.Instance:IsFriend(v, self.main_role)
		elseif SelectType.Enemy == select_type then
			can_select = Scene.Instance:IsEnemy(v, self.main_role)
		elseif SelectType.Alive == select_type then
			can_select = not v:IsRealDead()
		end

		if can_select then
			target_x, target_y = v:GetLogicPos()
			table.insert(temp_obj_list, {obj = v, dis = GameMath.GetDistance(x, y, target_x, target_y, false)})
		end
	end
	if not next(temp_obj_list) then
		return
	end
	table.sort(temp_obj_list, function(a, b) return a.dis < b.dis end)

	-- 排除已选过的
	local select_obj_list = self.select_obj_group_list[obj_type]
	if nil == select_obj_list then
		select_obj_list = {}
		self.select_obj_group_list[obj_type] = select_obj_list
	end

	local select_obj = nil
	for i, v in ipairs(temp_obj_list) do
		if nil == select_obj_list[v.obj:GetObjId()] then
			select_obj = v.obj
			break
		end
	end

	-- 如果没有选中，选第一个，并清空已选列表
	if nil == select_obj then
		select_obj = temp_obj_list[1].obj
		select_obj_list = {}
		self.select_obj_group_list[obj_type] = select_obj_list
	end
	if nil == select_obj then
		return
	end
	select_obj_list[select_obj:GetObjId()] = select_obj

	GlobalEventSystem:Fire(ObjectEventType.BE_SELECT, select_obj, "select")

	return select_obj
end

function MainUIViewSkill:OnClickSkill5Up(skill_info)
	if self.skill5_time_quest then
		if self.show_mojie_skill and self.show_mojie_panel_anmi:GetBool("fold") then
			self:SetMojiePanelAnimation(false)
		else
			self:OnClickSkill(skill_info)
		end
	end
	GlobalTimerQuest:CancelQuest(self.skill5_time_quest)
	self.skill5_time_quest = nil
end

function MainUIViewSkill:OnClickSkill5Down(skill_info)
	local function open_change()
		GlobalTimerQuest:CancelQuest(self.skill5_time_quest)
		self.skill5_time_quest = nil
		self:SetMojiePanelAnimation(true)
	end
	self.skill5_time_quest = GlobalTimerQuest:AddDelayTimer(open_change, 0.5)
end

function MainUIViewSkill:OnClickAuditSkill(skill_index)
	if skill_index and self.skill_infos[skill_index] then
		self:OnClickSkill(self.skill_infos[skill_index])
	end
end

function MainUIViewSkill:OnClickSkill(skill_info)
	self:SetMojiePanelAnimation(false)
	if not skill_info.is_exist then
		return
	end

	if skill_info.territory_lock then
		return
	end

	
	local main_role = Scene.Instance:GetMainRole()
	local scene_id = Scene.Instance:GetSceneId()
	if not (BossData.Instance:IsShenYuBossScene(scene_id) or BossData.Instance:IsCrossBossScene(scene_id) or BossData.Instance:IsFamilyBossScene(scene_id) or BossData.Instance:IsBossFamilyKfScene(scene_id)) and skill_info.skill_id == 7 then
		SysMsgCtrl.Instance:ErrorRemind(Language.GuildSkill.RemindMsg)
		return
	end
	
	if skill_info.skill_id == 7 and main_role:IsInSafeArea() then
		return
	end

	if not main_role:CanAttack() then
		return
	end
	if GoddessData.Instance:IsGoddessSkill(skill_info.skill_id) and self.is_show_kill6_effect then
		-- ViewManager.Instance:Open(ViewName.MainUIGoddessSkillTip)
		self:OnFlush({goddess_skill_tips = true})
		return
	end

	if SkillData.Instance:IsSkillCD(skill_info.skill_id) and SkillData.IsNotNormalSkill(skill_info.skill_id) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.SkillCD)
		return
	end
	local prof = PlayerData.Instance:GetRoleBaseProf()
	-- 自我释放技能
	if skill_info and (skill_info.skill_id == 81 or skill_info.skill_id == 83 or skill_info.skill_id == 170 or skill_info.skill_id == 172 
		or skill_info.skill_id == ZHUAN_ZHI_SKILL2[prof]) then
		local x, y = main_role:GetLogicPos()
		local logic_pos = main_role.logic_pos
		local index = SkillData.Instance:GetRealSkillIndex(skill_info.skill_id)
		FightCtrl.SendPerformSkillReq(index, 1, x, y, main_role:GetObjId(), false, logic_pos.x, logic_pos.y)
		return
	end

	local target_obj = GuajiCtrl.Instance:SelectAtkTarget(true, {
			[SceneIgnoreStatus.MAIN_ROLE_IN_SAFE] = true,
		}, skill_info.skill_id == 71 or skill_info.skill_id == 6) --城主技能只对玩家
	if SkillData.IsBuffSkill(skill_info.skill_id) or
		(PlayerData.Instance.role_vo.special_appearance == SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_TERRITORYWAR
		and SkillData.Instance:GetRealSkillIndex(skill_info.skill_id) == 5) then
		target_obj = main_role
	end
	if PlayerData.Instance.role_vo.special_appearance == SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_TERRITORYWAR
		and SkillData.Instance:GetRealSkillIndex(skill_info.skill_id) == 6 then
		GuajiCtrl.Instance:StopGuaji()
		target_obj = GuajiCtrl.Instance:SelectFriend()
	end

	if nil == target_obj then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.NoTarget)
		return
	end

	GlobalEventSystem:Fire(MainUIEventType.MAINUI_CLEAR_TASK_TOGGLE)
	GlobalEventSystem:Fire(MainUIEventType.CLICK_SKILL_BUTTON, skill_info.skill_id, target_obj)
	GuajiCtrl.Instance:DoFightByClick(skill_info.skill_id, target_obj, nil, true)
end

function MainUIViewSkill:OnClickForward()
	local x, y = FarmHuntingData.Instance:GetNearRongluPoint()
	GuajiCtrl.Instance:StopGuaji()
	GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), x, y, 0, 0)
end

function MainUIViewSkill:OnClickJump()
	--场景定点跳跃中 or 轻功新手指引中，不可使用轻功
	local main_role = Scene.Instance:GetMainRole()
	if main_role:IsJump() or FunctionGuide.Instance:GetIsQingGongGuide() then 
		return
	end

	if self.qinggong_index < 4 and self.jump_energy < JUMP_MAX_ENERGY/4 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.SkillJump)
		return
	end
	
	main_role:Jump()
end

function MainUIViewSkill:OnClickLanding()
	if FunctionGuide.Instance:GetIsQingGongGuide() then
		return
	end
	local main_role = Scene.Instance:GetMainRole()
	main_role:Landing()
end

function MainUIViewSkill:FlushJumpEnergyShow()
	if self.jump_energy < JUMP_MAX_ENERGY then
		if self.add_energy_time then
			GlobalTimerQuest:CancelQuest(self.add_energy_time)
			self.add_energy_time = nil
		end
		self.add_energy_time = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushEnergyTime, self), 0.1)
	end
end

function MainUIViewSkill:FlushEnergyTime()
	self.jump_energy = self.jump_energy + 0.6
	if self.node_list["CDJump"] and self.node_list["CDJump"].image then
		self.node_list["CDJump"].image.fillAmount = self.jump_energy/JUMP_MAX_ENERGY
	end
	if self.jump_energy >= JUMP_MAX_ENERGY then
		self.jump_energy = JUMP_MAX_ENERGY
		if self.add_energy_time then
			GlobalTimerQuest:CancelQuest(self.add_energy_time)
			self.add_energy_time = nil
		end
	end
end

--刷新跳跃显示
function MainUIViewSkill:FlushJumpState(qinggong_index)
	if qinggong_index <= 0 or self.qinggong_index ~= 0 and self.qinggong_index == qinggong_index then
		return
	end
	self.jump_energy = self.jump_energy - 26
	self:FlushJumpEnergyShow()
	self.is_show_jump = true
	if self.cur_qinggong_timer ~= nil then
		CountDown.Instance:RemoveCountDown(self.cur_qinggong_timer)
		self.cur_qinggong_timer = nil
	end
	self.qinggong_index = qinggong_index
	if self.qinggong_index == 1 then
		if self.node_list["JumpProgress1"] and self.node_list["JumpProgress1"].slider and self.node_list["JumpProgress2"].slider and self.node_list["JumpProgress3"] then
			self.node_list["JumpProgress1"].slider:DOValue(0, 0, false)
			self.node_list["JumpProgress2"].slider:DOValue(0, 0, false)
			self.node_list["JumpProgress3"].slider:DOValue(0, 0, false)
		end
		self:FlushQinggongShow()
	else
		self.cur_qinggong_timer = CountDown.Instance:AddCountDown(self.cur_qinggong_time, 0.01, BindTool.Bind(self.JumpProgress, self))
	end
end

-- 倒计时函数
function MainUIViewSkill:JumpProgress(elapse_time, total_time)
	if self.node_list["JumpProgress1"] and self.node_list["JumpProgress1"].slider and self.node_list["JumpProgress2"].slider then
		local num = 1 - (total_time - elapse_time) / self.cur_qinggong_time
		if self.qinggong_index == 2 then
			self.node_list["JumpProgress1"].slider:DOValue(num, 0, false)
		elseif self.qinggong_index == 3 then
			self.node_list["JumpProgress2"].slider:DOValue(num, 0, false)
		elseif self.qinggong_index == 4 then
			self.node_list["JumpProgress3"].slider:DOValue(num, 0, false)
		end
	end
	if elapse_time >= total_time then
		if self.cur_qinggong_timer ~= nil then
			CountDown.Instance:RemoveCountDown(self.cur_qinggong_timer)
			self.cur_qinggong_timer = nil
		end
		self:FlushQinggongShow()
	end
end

function MainUIViewSkill:FlushQinggongShow()
	self.node_list["JumpEffect2"]:SetActive(self.qinggong_index >= 2)
	self.node_list["JumpEffect3"]:SetActive(self.qinggong_index >= 3)
	self.node_list["JumpEffect4"]:SetActive(self.qinggong_index >= 4)
	if self.qinggong_index >= 4 then
		self.node_list["JumpProgress1"].slider:DOValue(1, 0, false)
		self.node_list["JumpProgress2"].slider:DOValue(1, 0, false)
		self.node_list["JumpProgress3"].slider:DOValue(1, 0, false)
	end
end

function MainUIViewSkill:OnMainRoleJumpState(state)
	if state then
		if self.is_show_jump then
			self.node_list["LandingButton"]:SetActive(true)
			self.node_list["DoubleJump"]:SetActive(true)
			-- GlobalEventSystem:Fire(MainUIEventType.CHNAGE_FIGHT_STATE_BTN, true)
			MainUICtrl.Instance:FlushView("fly_task_is_hide", {true})
		end
	else
		self.node_list["LandingButton"]:SetActive(false)
		self.node_list["DoubleJump"]:SetActive(false)
		-- GlobalEventSystem:Fire(MainUIEventType.CHNAGE_FIGHT_STATE_BTN, false)
		MainUICtrl.Instance:FlushView("fly_task_is_hide", {false})
		self.qinggong_index = 0
		self.is_show_jump = false
	end
end

function MainUIViewSkill:Update()
	-- Refresh jump time
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local srv_time = TimeCtrl.Instance:GetServerTime()
	local pass_time = srv_time - vo.jump_last_recover_time
	local recover_times = math.floor(pass_time / GameEnum.JUMP_RECOVER_TIME)
	if recover_times > 0 then
		local new_times = vo.jump_remain_times + recover_times
		if new_times > GameEnum.JUMP_MAX_COUNT then
			new_times = GameEnum.JUMP_MAX_COUNT
		end

		vo.jump_last_recover_time = vo.jump_last_recover_time + recover_times * GameEnum.JUMP_RECOVER_TIME
		if vo.jump_remain_times ~= new_times then
			vo.jump_remain_times = new_times
			-- self.jump_count = vo.jump_remain_times
		end
	end
end

function MainUIViewSkill:GetSkillButtonPosition()
	return self.skill_icon_pos_list
end

local old_type = nil
function MainUIViewSkill:OnMainRoleSwitchScene(area_type)
	if IsNil(self.enter_safe_area_animator) then 
		return
	end

	GlobalTimerQuest:CancelQuest(self.delete_area_tips_timer)
	if old_type then
		self:DeleteAreaTip(old_type)
	end
	old_type = area_type
	self.delete_area_tips_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.DeleteAreaTip,self, area_type), 3)
	if area_type == SceneConvertionArea.WAY_TO_SAFE then
		if self.enter_safe_area_animator and self.enter_safe_area_animator.isActiveAndEnabled then
			self.enter_safe_area_animator:SetBool("enter", true)
		end
	elseif area_type == SceneConvertionArea.SAFE_TO_WAY then
		if self.leave_safe_area_animator and self.leave_safe_area_animator.isActiveAndEnabled then
			self.leave_safe_area_animator:SetBool("enter", true)
		end
	end
end

function MainUIViewSkill:DeleteAreaTip(area_type)
	if area_type == SceneConvertionArea.WAY_TO_SAFE then
		if self.enter_safe_area_animator and self.enter_safe_area_animator.isActiveAndEnabled then
			self.enter_safe_area_animator:SetBool("enter", false)
		end
	elseif area_type == SceneConvertionArea.SAFE_TO_WAY then
		if self.leave_safe_area_animator and self.leave_safe_area_animator.isActiveAndEnabled then
			self.leave_safe_area_animator:SetBool("enter", false)
		end
	end
end

function MainUIViewSkill:ClickGeneralSkill()
	if self.send_general_timer == nil then
		self.send_general_timer = Status.NowTime - 1
	end


	if Status.NowTime - self.send_general_timer < 1 then
		return
	else
		self.send_general_timer = Status.NowTime
	end

	-- if PlayerData.Instance.role_vo.hold_beauty_npcid > 0 then
	-- 	SysMsgCtrl.Instance:ErrorRemind(Language.Task.JunXianTaskLimit[1])
	-- 	return
	-- end
	local main_role = Scene.Instance:GetMainRole()
	if main_role:IsJump() then
		return
	end

	if main_role and main_role:IsWarSceneState() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.IsNoUseBianShen)
		return			
	end
	
	BianShenCtrl.Instance:SendRequest(GREATE_SOLDIER_REQ_TYPE.GREATE_SOLDIER_REQ_TYPE_BIANSHEN)
end

function MainUIViewSkill:SetGuildStation(is_active)
	if self.is_guild_station then
		self.is_guild_station = is_active
	end
end

function MainUIViewSkill:FlushGeneralSkill(is_in)
	local is_in = is_in or false
	if self.node_list["BtnBianShen"] then
		local is_can_bianshen = is_in and true or Scene.Instance:IsBianShenScene()
		if BianShenData.Instance:CheckShowSkill() and not self.is_guild_station and is_can_bianshen then
			local value = BianShenData.Instance:GetCurUseSeq()
			local has_general_skill = BianShenData.Instance:GetHasGeneralSkill()
			if value == -1 and has_general_skill then
				self.node_list["BtnBianShen"]:SetActive(false)
			else
				self.node_list["BtnBianShen"]:SetActive(true and not IS_AUDIT_VERSION)
				local current_use_huan_hua_id = BianShenData.Instance:GetCurrentUseHuanHuaId()
				local bundle, asset = "uis/icons/bianshenicon_atlas", "btn_bianshen_huanhua_icon.png"
				if current_use_huan_hua_id <= 0 then
					local slot_info =  BianShenData.Instance:GetCurrentMingJiangInfo()
					if slot_info and slot_info.item_seq then
						bundle, asset = ResPath.GetFamousGeneralBtnIcon(slot_info.item_seq)
					end
				end
				self.node_list["BianShenImage"].image:LoadSprite(bundle, asset)
			end
		else
			self.node_list["BtnBianShen"]:SetActive(false)
		end
	end
end

-- 获取变身引导
function MainUIViewSkill:GetMainBianShen()
	if self.node_list["BtnBianShen"] then
		return self.node_list["BtnBianShen"], BindTool.Bind(self.ClickGeneralSkill, self)
	end
end

function MainUIViewSkill:GeneralBianShenCd()
	local is_general = BianShenData.Instance:GetCurUseSeq()
	local cd_s = 0
	local func = nil
	local complere_fun = nil
	self:ChangeBianShenEffect()
	if is_general == -1 then
		-- 变身结束
		cd_s = math.floor(BianShenData.Instance:GetBianShenCds())
		func = BindTool.Bind(self.UpdateGeneralCD, self)
		self:SetBtnBianShenEffect(false, false)
		UI:SetGraphicGrey(self.node_list["BianShenImage"], true)
	else
		-- 变身中
		cd_s = math.floor(BianShenData.Instance:GetBianShenTime())
		func = BindTool.Bind(self.UpdateGeneralSkill, self)
		self:SetBtnBianShenEffect(true, false)
		UI:SetGraphicGrey(self.node_list["BianShenImage"], false)
	end
	CountDown.Instance:RemoveCountDown(self.general_skill.countdonw)
	self.general_skill.cd_time.text.text = ""

	if cd_s > 0 then
		complere_fun = BindTool.Bind(self.GeneralComplereFun, self, is_general)
		self.general_skill.countdonw = CountDown.Instance:AddCountDown(cd_s, 0.5, func, complere_fun)
	else
		self:ChangeBianShenEffect()
		self:SetBtnBianShenEffect(false, true)
		UI:SetGraphicGrey(self.node_list["BianShenImage"], false)
	end
end

function MainUIViewSkill:UpdateGeneralSkill(elapse_time, total_time)
	local daiff_value = math.floor(total_time - elapse_time)
	if self.general_skill and not IsNil(self.general_skill.cd_time.gameObject) then
		self.general_skill.cd_time.text.text = TimeUtil.FormatSecond(daiff_value, 2)
	end
	
	if daiff_value < 0 then
		self.general_skill.cd_time.text.text = ""
		CountDown.Instance:RemoveCountDown(self.general_skill.countdonw)
		self:SetBtnBianShenEffect(false, true)
		UI:SetGraphicGrey(self.node_list["BianShenImage"], true)
	end
end

function MainUIViewSkill:UpdateGeneralCD(elapse_time, total_time)
	local daiff_value = math.floor(total_time - elapse_time)
	if self.general_skill and not IsNil(self.general_skill.cd_time.gameObject)  then
		self.general_skill.cd_time.text.text = TimeUtil.FormatSecond(daiff_value, 2)
	end

	if daiff_value < 0 then
		self.general_skill.cd_time.text.text = ""
		CountDown.Instance:RemoveCountDown(self.general_skill.countdonw)
		self:SetBtnBianShenEffect(false, true)
		self:ChangeBianShenEffect()
		UI:SetGraphicGrey(self.node_list["BianShenImage"], false)
	end
end

-- 变身按钮计时器结束回调
function MainUIViewSkill:GeneralComplereFun(is_general)
	self.general_skill.cd_time.text.text = ""
	CountDown.Instance:RemoveCountDown(self.general_skill.countdonw)

	if is_general == -1 then
		self:SetBtnBianShenEffect(false, true)
		self:ChangeBianShenEffect()
		UI:SetGraphicGrey(self.node_list["BianShenImage"], false)
	else
		self:SetBtnBianShenEffect(false, true)
		UI:SetGraphicGrey(self.node_list["BianShenImage"], true)
	end
end

function MainUIViewSkill:SetBtnBianShenEffect(is_nb, is_ruo)
	if self.node_list and self.node_list["BtnBianShenEffect_1"] then
		self.node_list["BtnBianShenEffect_1"]:SetActive(is_nb)
		self.node_list["BtnBianShenEffect_2"]:SetActive(is_nb)
		self.node_list["BtnBianShenEffect_3"]:SetActive(is_ruo)
		self.node_list["BtnBianShenEffect_4"]:SetActive(is_ruo)
	end
end

--引导用名将变身技能
function MainUIViewSkill:GetClickGeneralSkillCallBack()
	return BindTool.Bind(self.ClickGeneralSkill, self)
end

function MainUIViewSkill:ChangeBianShenEffect()
	local main_role = Scene.Instance:GetMainRole()
	local now_cd = BianShenData.Instance:GetBianShenCds()
	if main_role and main_role:IsFightState() and now_cd <= 0 then
		self.general_skill.show_effect = true
	else
		self.general_skill.show_effect = false
	end
end

function MainUIViewSkill:OnSwitchSpecSkills()
	if self.spc_skill_is_tweening then
		return
	end
	self.spc_skill_is_tweening = true
	self.is_show_spc_skill = not self.is_show_spc_skill

	local from_x = self.is_show_spc_skill and 370 or 0
	local to_x = self.is_show_spc_skill and 0 or 370

	self.node_list["SpecSkillsLayer"].transform.anchoredPosition = Vector3(from_x, 0, 0)
	local spc_tween = self.node_list["SpecSkillsLayer"].transform:DOAnchorPosX(to_x, 0.16)
	spc_tween:SetEase(DG.Tweening.Ease.Linear)
	spc_tween:OnComplete(function ()
		self.spc_skill_is_tweening = false
	end)
end

function MainUIViewSkill:OnShowActivitySkill(attach_obj)
	local is_show_act_skill = nil ~= attach_obj and type(attach_obj) == "userdata"

	self.node_list["SpecSkillSwitchBtn"]:SetActive(not is_show_act_skill)
	self.node_list["PanelActivitySkills"]:SetActive(is_show_act_skill)

	self:ClearActivitySkill()

	if is_show_act_skill and nil ~= attach_obj and self.node_list["ActSkillsLayer"] then
		attach_obj.transform:SetParent(self.node_list["ActSkillsLayer"].transform, false)


		self.is_show_act_skill = false
		self:OnSwitchActivitySkills(0.6)
	else
		if self.is_show_act_skill then
			self.is_show_spc_skill = false
			self:OnSwitchSpecSkills()
		end

		self.is_show_act_skill = true
		self:OnSwitchActivitySkills()
	end
end

function MainUIViewSkill:ClearActivitySkill()
	if self.node_list["ActSkillsLayer"] then
		for i = 0, self.node_list["ActSkillsLayer"].transform.childCount - 1 do
			ResMgr:Destroy(self.node_list["ActSkillsLayer"].transform:GetChild(i).gameObject)
		end
	end
end

function MainUIViewSkill:OnSwitchActivitySkills(duration_time)
	if not self.node_list["PanelSpecSkills"].gameObject.activeInHierarchy then
		return
	end

	if nil == duration_time and self.act_spc_skill_is_tweening then
		return
	end
	self.act_spc_skill_is_tweening = true
	self.is_show_act_skill = not self.is_show_act_skill

	local from_x = self.is_show_act_skill and 370 or 0
	local to_x = self.is_show_act_skill and 0 or 370
	duration_time = duration_time or 0.16

	self.node_list["ActSkillsLayer"].transform.anchoredPosition = Vector3(from_x, 0, 0)
	local act_tween = self.node_list["ActSkillsLayer"].transform:DOAnchorPosX(to_x, duration_time)
	act_tween:SetEase(DG.Tweening.Ease.Linear)
	act_tween:OnComplete(function ()
		self.act_spc_skill_is_tweening = false
	end)

	self.node_list["SpecSkillsLayer"].transform.anchoredPosition = Vector3(to_x, 0, 0)
	local spc_tween = self.node_list["SpecSkillsLayer"].transform:DOAnchorPosX(from_x, duration_time - 0.1)
	spc_tween:SetEase(DG.Tweening.Ease.Linear)
end

-- 功能引导仙女技能
function MainUIViewSkill:GetSkill6()
	if self.node_list["Skill6"] then
		return self.node_list["Skill6"], BindTool.Bind(self.OnClickSkill, self, self.skill_infos[6])
	end
end

function MainUIViewSkill:GetQingGongBtn()
	if self.node_list["JumpButton"] then
		return self.node_list["JumpButton"]
	end
end

function MainUIViewSkill:GetQingGongDown()
	if self.node_list["LandingButton"] then
		return self.node_list["LandingButton"]
	end
end

function MainUIViewSkill:ShowQingGongGuideSkillEffect(is_show, is_qinggong_down)
	is_qinggong_down = is_qinggong_down or false
	if is_show then
		local bundle, asset = ResPath.GetUiXEffect("UI_tishitexiao_lan")
		if is_qinggong_down then
			if self.qinggong_down_guide_eff then
				self.qinggong_down_guide_eff:SetActive(true)
			else
				local async_loader = AllocAsyncLoader(self, "qinggong_down_guide_eff_loader")
				async_loader:SetParent(self.qinggong_down_btn.transform)
				-- self.qinggong_down_guide_eff = AsyncLoader.New(self.qinggong_down_btn.transform)
				async_loader:Load(bundle, asset, function(obj)
					if not IsNil(obj) then
						if self.qinggong_down_guide_eff  ~= nil then
							ResMgr:Destroy(self.qinggong_down_guide_eff)
							self.qinggong_down_guide_eff = nil
						end
						self.qinggong_down_guide_eff = obj
						self.qinggong_down_guide_eff:SetActive(true)
					end
				end)
			end
		else
			if self.qinggong_guide_eff then
				self.qinggong_guide_eff:SetActive(true)
			else
				local async_loader = AllocAsyncLoader(self, "qinggong_guide_eff_loader")
				async_loader:SetParent(self.qinggong_btn.transform)
				async_loader:Load(bundle, asset, function(obj)
					if not IsNil(obj) then
						if self.qinggong_guide_eff  ~= nil then
							ResMgr:Destroy(self.qinggong_guide_eff)
							self.qinggong_guide_eff = nil
						end
						self.qinggong_guide_eff = obj
						self.qinggong_guide_eff:SetActive(true)
					end
				end)
			end
		end
	else
		if self.qinggong_guide_eff then
			self.qinggong_guide_eff:SetActive(false)
		end
		if self.qinggong_down_guide_eff then
			self.qinggong_down_guide_eff:SetActive(false)
		end
	end
end

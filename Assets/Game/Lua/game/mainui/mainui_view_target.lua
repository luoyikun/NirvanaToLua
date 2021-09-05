MainUIViewTarget = MainUIViewTarget or BaseClass(BaseRender)

-- Boss血条运动一格的时间
local BOSS_HP_DURATION = 1
-- Boss血条最大的时间
local MAX_BOSS_HP_DURATION = 1.5

function MainUIViewTarget:__init()
	self:BindGlobalEvent(ObjectEventType.BE_SELECT, BindTool.Bind(self.OnSelectObjHead, self))
	self:BindGlobalEvent(ObjectEventType.OBJ_DELETE, BindTool.Bind(self.OnObjDeleteHead, self))
	self:BindGlobalEvent(ObjectEventType.OBJ_DEAD, BindTool.Bind(self.OnObjDeleteHead, self))
	self:BindGlobalEvent(ObjectEventType.TARGET_HP_CHANGE, BindTool.Bind(self.OnTargetHpChangeHead, self))
	self:BindGlobalEvent(ObjectEventType.SPECIAL_SHIELD_CHANGE, BindTool.Bind(self.OnSpecialShieldChangeBlood, self))

	self.node_list["SliderBossDunHp"]:SetActive(false)

	self.node_list["BtnPortraitLabel"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
	self.node_list["BtnBossPortraitLabel"].button:AddClickListener(BindTool.Bind(self.OnClick, self))

	self.boss_hp_middle_slider = self.node_list["HPMiddle"].slider
	self.boss_hp_top_slider = self.node_list["SliderBossHp"].slider
	-- 首次刷新数据
	self:OnSelectObjHead(nil, nil)
	self.is_show = true
	self.target_is_boss = false
	self.target_boss_hp_index = 0
	self.cur_boss_hp_index = 0
	self.total_duration = 0
	self.total_value = 0
	self.effect_flush = true
	self.last_change_hp_time_stamp = Status.NowTime
	-- self.rect = self.root_node.transform:GetComponent(typeof(UnityEngine.RectTransform))
	-- local x, y = self.rect.anchoredPosition.x, self.rect.anchoredPosition.y
	-- self.height_pos = Vector2(x, 0);
	-- self.pos = Vector2(x, y);
end

-- 选择对象显示头像
function MainUIViewTarget:OnSelectObjHead(target_obj, select_type)
	local scene_type = Scene.Instance:GetSceneType()
	-- 攻城战旗帜
	local qizhi_id = ConfigManager.Instance:GetAutoConfig("gongchengzhan_auto").other[1].boss2_id or 0
	--隐藏护盾
	self.node_list["Black"]:SetActive(false)
	self.node_list["SliderBossDunHp"]:SetActive(false)
	if nil == target_obj
		or target_obj:GetType() == SceneObjType.MainRole
		or target_obj:GetType() == SceneObjType.TruckObj
		or target_obj:GetType() == SceneObjType.EventObj
		or target_obj:GetType() == SceneObjType.Trigger
		or target_obj:GetType() == SceneObjType.MingRen
		or target_obj:GetType() == SceneObjType.DefenseObj
		or target_obj:IsNpc()
		or (target_obj.IsGather and target_obj:IsGather())
		or (target_obj:IsMonster() and not target_obj:IsBoss() and target_obj:GetMonsterId() ~= qizhi_id)
		or (target_obj:GetType() == SceneObjType.Monster and target_obj:GetMonsterId() == 1101 and scene_type == SceneType.QunXianLuanDou) then
		self.target_obj = nil
		self.node_list["PanelTargeInfo"]:SetActive(false)
		return
	end
	self.target_obj = target_obj
	self.node_list["PanelTargeInfo"]:SetActive(self.target_obj ~= nil and self.is_show)
	if self.target_obj == nil then
		return
	end
	
	if scene_type == SceneType.Kf_OneVOne or scene_type == SceneType.Field1v1 or scene_type == SceneType.Mining or scene_type == SceneType.KF_Arena then
		self.node_list["PanelTargeInfo"]:SetActive(false)
		return
	end

	local vo = target_obj:GetVo()
	self.target_is_boss = false
	if target_obj:IsRole() then
		self.node_list["HpBar"]:SetActive(true)
		self.node_list["BossHpBar"]:SetActive(false)
		self.node_list["Txt_dps"]:SetActive(false)
		self.node_list["Img_dps"]:SetActive(false)
		self.node_list["BtnPortraitLabel"]:SetActive(true)
		self.node_list["BtnBossPortraitLabel"]:SetActive(false)
		self.node_list["portrait_raw"]:SetActive(false)
		self.node_list["TxtTargetName"].text.text = target_obj:GetName()
		-- local lv, zhuan = PlayerData.GetLevelAndRebirth(target_obj:GetAttr("level"))
		-- self.node_list["TxtTargetLevel"].text.text = string.format("%s", string.format(Language.Mainui.Level2, lv, zhuan))
		self.node_list["TxtTargetLevel"].text.text = string.format(Language.Mainui.Level, PlayerData.GetLevelString(target_obj:GetAttr("level")))
		-- self.node_list["TxtTargetLevel"].text.text = PlayerData.GetLevelString(target_obj:GetAttr("level"))

		local base_prof, zhuan = PlayerData.Instance:GetRoleBaseProf(vo.prof)
		local res_id = ZhuanZhiData.Instance:GetZhuanZhiLimitProfImg(base_prof, zhuan)
		if self.node_list["ProfImage"] and res_id then
			local bundle,asset = ResPath.GetTransferNameIcon(res_id)
			self.node_list["ProfImage"].image:LoadSpriteAsync(bundle, asset)
		end
		local max_hp = target_obj:GetAttr("max_hp")
		if max_hp ~= nil and max_hp > 0 then
			self:SetHpPercent(target_obj:GetAttr("hp") / max_hp)
		end
		self.node_list["HpText"].text.text = CommonDataManager.ConverMoney2(target_obj:GetAttr("hp"))
		self:OnHeadChange(vo)
	elseif target_obj:IsMonster() then
		self.node_list["HpBar"]:SetActive(false)
		self.node_list["BossHpBar"]:SetActive(true)
		self.node_list["Txt_dps"]:SetActive(true)
		self.node_list["BtnPortraitLabel"]:SetActive(false)
		self.node_list["BtnBossPortraitLabel"]:SetActive(true)
		self.node_list["Bossportrait"]:SetActive(true)
		local max_hp = target_obj:GetAttr("max_hp")
		if max_hp ~= nil and max_hp > 0 then
			self:SetHpPercent(target_obj:GetAttr("hp") / max_hp)
			self.target_boss_hp_index = target_obj:GetAttr("hp") / max_hp * 100
		end

		self.target_is_boss = true
		self.cur_boss_hp_index = self.target_boss_hp_index
		self.boss_hp_middle_slider.value = self.cur_boss_hp_index % 1 > 0 and self.cur_boss_hp_index % 1 or 1
		self.boss_hp_top_slider.value = self.boss_hp_middle_slider.value
		self:UpdateBossHp()
		local monster_id = vo.monster_id
		local config = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
		if config then
			if config[monster_id] then
				local level = config[monster_id].level or 0
				self.node_list["TxtTargetName"].text.text = target_obj:GetName() .. " <color=#07cc72>" .. Language.Mainui.Level3 .. level .. "</color>"
				self.node_list["TxtTargetLevel"].text.text = ""
				self:OnTargetDpsChange(target_obj)
			end
		end
	else
		self:SetHpPercent(1)
	end

	if scene_type == SceneType.ClashTerritory then
		self.node_list["TxtTargetName"].text.text = ClashTerritoryData.Instance:GetMonsterName(target_obj.vo)
	elseif scene_type == SceneType.CrossTuanZhan then
		self.node_list["TxtTargetName"].text.text = KuaFuTuanZhanData.Instance:GetMonsterName(target_obj.vo)
	elseif scene_type == SceneType.CrossGuild then
		self.node_list["TxtTargetName"].text.text = KuafuGuildBattleData.Instance:GetMonsterName(target_obj.vo)
	end

	if target_obj:IsMonster() then
		if target_obj:GetMonsterHead() > 0 then
			local bundle, asset = ResPath.GetBossIcon(target_obj:GetMonsterHead())
			self.node_list["portrait"].image:LoadSpriteAsync(bundle, asset .. ".png")
			self.node_list["Bossportrait"].image:LoadSpriteAsync(bundle, asset .. ".png")
		else
			self.node_list["Bossportrait"]:SetActive(false)
		end
	end
end

-- 取消
function MainUIViewTarget:OnObjDeleteHead(obj)
	if self.target_obj == obj then
		self.target_obj = nil
		self.node_list["PanelTargeInfo"]:SetActive(false)
	end
end

-- 目标血量改变
function MainUIViewTarget:OnTargetHpChangeHead(target_obj)
	local max_hp = target_obj:GetAttr("max_hp")
	if max_hp ~= nil and max_hp > 0 then
		self:SetHpPercent(target_obj:GetAttr("hp") / max_hp)
	end
	if self.node_list["HpText"] then
		self.node_list["HpText"].text.text = CommonDataManager.ConverMoney2(target_obj:GetAttr("hp"))
	end
	if target_obj:IsMonster() then
		self:OnTargetDpsChange(target_obj)
	end
end

-- BOSS归属者显示
function MainUIViewTarget:OnTargetDpsChange(target_obj)
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	if fb_scene_cfg.pb_bossAttribution and fb_scene_cfg.pb_bossAttribution == 1 then
		self.node_list["Img_dps"]:SetActive(false)
		self.node_list["Txt_dps"].text.text = ""
		return
	end

	local target_name = target_obj:GetDpsTargetName()
	self.node_list["Txt_dps"].text.text = target_name
	if target_name == nil or target_name == "" then
		self.node_list["Img_dps"]:SetActive(false)
	else
		self.node_list["Img_dps"]:SetActive(true)
	end
end

function MainUIViewTarget:OnSpecialShieldChangeBlood(info)
	if self.target_obj and self.target_obj:GetObjId() == info.obj_id then
		if info ~= nil and info.max_times ~= nil and info.max_times ~= 0 then
			self.node_list["SliderBossDunHp"].slider.value = info.left_times / info.max_times
			self.node_list["TxtBossDun"].text.text = math.ceil(info.left_times) .."/".. info.max_times
			self.node_list["SliderBossDunHp"]:SetActive(info.left_times / info.max_times > 0)
		end

		if info.max_times <= 0 then
			self.node_list["SliderBossDunHp"]:SetActive(false)
			self.node_list["TxtBossDun"].text.text = ""
			self.node_list["SliderBossDunHp"].slider.value = 0
			if self.cal_time_quest then
				GlobalTimerQuest:CancelQuest(self.cal_time_quest)
				self.cal_time_quest = nil
			end
		end
	end
	if self.cal_time_quest == nil then
		self:CalTimeHideDun()
	end
end

function MainUIViewTarget:CalTimeHideDun()
	local timer_cal = 20
	self.cal_time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer_cal = timer_cal - UnityEngine.Time.deltaTime
		if timer_cal < 0 then
			self.node_list["SliderBossDunHp"]:SetActive(false)
			self.node_list["SliderBossDunHp"].slider.value = 0
			self.node_list["TxtBossDun"].text.text = ""
			GlobalTimerQuest:CancelQuest(self.cal_time_quest)
			self.cal_time_quest = nil
		end
	end, 0)
end

-- 设置目标血条
local old_index = 0
function MainUIViewTarget:SetHpPercent(percent)
	self.node_list["SliderHp"].slider.value = percent
	self.node_list["SliderHp1"].slider.value = percent
	local index = math.floor(percent * 100)
	local per = percent * 100 - index
	if self.target_is_boss then
		self.target_boss_hp_index = percent * 100
		if self.cur_boss_hp_index >= self.target_boss_hp_index then
			self.total_value = self.cur_boss_hp_index - self.target_boss_hp_index
			self.total_duration = math.min(self.total_value * BOSS_HP_DURATION, MAX_BOSS_HP_DURATION)
			self.last_change_hp_time_stamp = Status.NowTime
		else
			self.cur_boss_hp_index = self.target_boss_hp_index
			self.boss_hp_top_slider.value = self.target_boss_hp_index % 1
			self.boss_hp_middle_slider.value = self.target_boss_hp_index % 1
		end
		self:UpdateBossHp()
	end

	if per == 0 and percent ~= 0 then
		per = 1
		index = index - 1
	end
	local res_index = index % 5
	local bundle, asset = ResPath.GetBossHp(5 - res_index)
	self.node_list["ImgBossHp"].image:LoadSpriteAsync(bundle, asset .. ".png")
	self.node_list["ImgBossHp1"].image:LoadSpriteAsync(bundle, asset .. ".png")

	-- self.node_list["ImgBgBossHp"]:SetActive(index > 0)
	-- if index > 0 then
	-- 	local bundle, asset =  ResPath.GetBossHp(6 - res_index > 5 and 1 or 6 - res_index)
	-- 	self.node_list["ImgBgBossHp"].image:LoadSpriteAsync(bundle, asset .. ".png")
	-- end
	-- self.node_list["TxtBossHp"].text.text = index == 0 and "" or ("x " .. index)
	-- self.node_list["SliderBossHp"].slider.value = per
	self.node_list["SliderBossHp1"].slider.value = per
	self.node_list["SliderBossHp2"].slider.value = per

	old_index = index
end

function MainUIViewTarget:ChangeBossHpColor(index)
	local res_index = index % 5
	self.node_list["BossHpBg"]:SetActive(index > 0)
	if index > 0 then
		self.node_list["BossHpBg"].image:LoadSpriteAsync(ResPath.GetBossHp(6 - res_index > 5 and 1 or 6 - res_index))
	end
end

function MainUIViewTarget:UpdateBossHp()
	self:StopTweener()
	-- 假血条整数部分
	local integer_cur = math.floor(self.cur_boss_hp_index)
	-- 目标血条整数部分
	local integer_target = math.floor(self.target_boss_hp_index)

	local title_index = math.ceil(self.cur_boss_hp_index) - 1
	self.node_list["TxtBossHp"].text.text = (title_index <= 0 and "" or ("x " .. title_index))
	self:ChangeBossHpColor(title_index)

	if title_index >= integer_target then
		--超过2条血的伤害就加个遮罩
		-- if title_index - integer_target > 2 then
		-- 	self.node_list["Black"]:SetActive(true)
		-- else
		-- 	self.node_list["Black"]:SetActive(false)
		-- end
		local next_boss_hp_index = self.target_boss_hp_index
		if title_index > integer_target then
			if self.cur_boss_hp_index % 1 == 0 then
				next_boss_hp_index = self.cur_boss_hp_index - 1
			else
				next_boss_hp_index = integer_cur
			end
		end
		local value = 0
		if title_index == integer_target then
			value = self.target_boss_hp_index % 1
		end
		
		if self.effect_flush and self.total_value > 0 then
			self.effect_flush = false
			local callback = function()
				self.effect_flush = true
			end
			local handle_pos = self.node_list["TopHandle"].transform.position
			local position = Vector3(handle_pos.x + 5, handle_pos.y - 12, handle_pos.z)
			local bundle_name, asset_name = ResPath.GetUiEffect("UI_diaoxuedaoguang")
			EffectManager.Instance:PlayAtTransform(bundle_name, asset_name, self.node_list["TopHandle"].transform, 0.5, position, nil, nil, callback)
		end

		self.boss_hp_top_slider.value = value
		local duration = 0
		if self.total_value > 0 then
			local diff = self.boss_hp_middle_slider.value - value
			-- 把函数调用消耗时间也计算进去，只有这样才能保证在任何情况下都能在限制的时间之内跑完
			self.total_duration = math.max(0, self.total_duration - (Status.NowTime - self.last_change_hp_time_stamp))
			self.last_change_hp_time_stamp = Status.NowTime
			local total_value = self.total_value * self.total_duration
			if total_value ~= 0 then
				duration = diff / total_value
			end
			self.total_value = self.total_value - diff
			duration = math.max(0, duration)
			if title_index == integer_target then
				duration = diff * BOSS_HP_DURATION * 0.5
			end
		end
		self.tweener = self.boss_hp_middle_slider:DOValue(value, duration)
		self.tweener:SetEase(DG.Tweening.Ease.Linear)
		self.tweener:OnComplete(function ()
			if title_index == 0 and self.target_boss_hp_index == 0 then
				self.target_obj = nil
				self.node_list["PanelTargeInfo"]:SetActive(false)
				-- local is_gongcheng_zhan = CityCombatData.Instance:GetCurSceneIsGongChengZhan()
				-- if is_gongcheng_zhan then
				-- 	CityCombatCtrl.Instance:SetCityCombatFBTimeValue(false)
				-- end
				self:StopTweener()
				return
			end
			self.tweener = nil
			self.cur_boss_hp_index = next_boss_hp_index
			if next_boss_hp_index % 1 == 0 and next_boss_hp_index > 1 then
				self.boss_hp_top_slider.value = value == 0 and 1 or value
				self.boss_hp_middle_slider.value = 1
			end
			if next_boss_hp_index ~= self.target_boss_hp_index then
				self:UpdateBossHp()
			end
		end)
	end
end

function MainUIViewTarget:StopTweener()
	if self.tweener then
		self.tweener:Pause()
		self.tweener = nil
		self.cur_boss_hp_index = math.ceil(self.cur_boss_hp_index) - 1 + self.boss_hp_middle_slider.value
	end
end

function MainUIViewTarget:SetState(switch)
	self.is_show = switch or false
	if self.target_obj then
		if self.is_show then
			self.node_list["PanelTargeInfo"]:SetActive(true)
		else
			self.node_list["PanelTargeInfo"]:SetActive(false)
		end
	end
end

function MainUIViewTarget:OnClick()
	if self.target_obj then
		if self.target_obj:GetType() == SceneObjType.Role then
			local name = self.target_obj:GetName()
			if name then
				ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.Default, name)
			end
		end
	end
end

-- 头像更换
function MainUIViewTarget:OnHeadChange(vo)
	if not vo then return end
	-- 现在跨服也可以使用头像了，就屏蔽掉下面代码
	-- if IS_ON_CROSSSERVER then
	-- 	--温泉场景使用默认头像
	-- 	self.node_list["portrait_raw"]:SetActive(false)
	-- 	self.node_list["BtnPortraitLabel"]:SetActive(true)
	-- 	local bundle, asset = AvatarManager.GetDefAvatar(PlayerData.Instance:GetRoleBaseProf(vo.prof), false, vo.sex)
	-- 	self.node_list["portrait"].image:LoadSpriteAsync(bundle, asset .. ".png")
	-- 	self.node_list["Bossportrait"].image:LoadSpriteAsync(bundle, asset .. ".png")
	-- 	return
	-- end
	AvatarManager.Instance:SetAvatar(vo.plat_role_id, self.node_list["portrait_raw"], self.node_list["portrait"], vo.sex, vo.prof, false)
end

function MainUIViewTarget:ChangeToHigh(value)
	-- if self.rect then
	-- 	self.rect.anchoredPosition = value and self.pos or self.height_pos
	-- end
end
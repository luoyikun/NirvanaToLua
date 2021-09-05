AdvanceFightMountView = AdvanceFightMountView or BaseClass(BaseRender)

local EFFECT_CD = 1.8
local ZIZHILEVEL = 3
local EQUIPLEVEL = 5
local TALENTLEVEL = 8
local MOVE_TIME = 0.5
local SHOWSPECGRADE = 10

function AdvanceFightMountView:UIsMove()
	UITween.MoveShowPanel(self.node_list["InfoPanel"], Vector3(250 , -17 , 0 ) , MOVE_TIME)
	UITween.MoveShowPanel(self.node_list["SkillPanel"], Vector3(0 , -560 , 0 ) , MOVE_TIME)
	-- UITween.MoveShowPanel(self.node_list["Panel1"], Vector3(165 , 600 , 0 ) , MOVE_TIME)
	UITween.MoveShowPanel(self.node_list["Panel4"], Vector3(-35 , 480 , 0 ) , MOVE_TIME)
	UITween.MoveShowPanel(self.node_list["TitlePanel"], Vector3(0 , 400 , 0 ) , MOVE_TIME)
	UITween.MoveShowPanel(self.node_list["BtnPanel"], Vector3(0 , -360 , 0 ) , MOVE_TIME)
	UITween.AlpahShowPanel(self.node_list["Panel3"], true, MOVE_TIME , DG.Tweening.Ease.InExpo)
	UITween.AlpahShowPanel(self.node_list["Panel2"], true, MOVE_TIME , DG.Tweening.Ease.InExpo)
	UITween.AlpahShowPanel(self.node_list["Panel1"], true, MOVE_TIME , DG.Tweening.Ease.InExpo)
	UITween.MoveShowPanel(self.node_list["ActPanel"], GoddessData.TweenPosition.Up2 , MOVE_TIME)
end

function AdvanceFightMountView:__init(instance)
	self.node_list["StartButton"].button:AddClickListener(BindTool.Bind(self.OnStartAdvance, self))
	self.node_list["AutoButton"].button:AddClickListener(BindTool.Bind(self.OnAutomaticAdvance, self))
	self.node_list["GrayUseButton"].button:AddClickListener(BindTool.Bind(self.OnClickUse, self))
	self.node_list["BtnLeftButton"].button:AddClickListener(BindTool.Bind(self.OnClickLastButton, self))
	self.node_list["BtnRightButton"].button:AddClickListener(BindTool.Bind(self.OnClickNextButton, self))
	self.node_list["BtnQualifications"].button:AddClickListener(BindTool.Bind(self.OnClickZiZhi, self))
	self.node_list["BtnHuanHua"].button:AddClickListener(BindTool.Bind(self.OnClickHuanHua, self))
	self.node_list["ShenCiHuanhua"].button:AddClickListener(BindTool.Bind(self.OnClickShenCiHuanHua, self))
	self.node_list["BtnEquipButton"].button:AddClickListener(BindTool.Bind(self.OnClickEquipBtn, self))
	-- self.node_list["BtnFuLingButton"].button:AddClickListener(BindTool.Bind(self.OnClickTalent, self)) -- 屏蔽天赋
	self.node_list["BtnTitle"].button:AddClickListener(BindTool.Bind(self.OnClickOpenSmallTarget, self))
	self.node_list["BtnBigTarget"].button:AddClickListener(BindTool.Bind(self.OnClickJinJieAward, self))
	self.node_list["ActPanel"].button:AddClickListener(BindTool.Bind(self.ClickActIcon, self))
	self.node_list["ShenCiHuanhua"]:SetActive(false)
	self.node_list["ShenCiHuanhua"].image:LoadSprite("uis/views/advanceview/images_atlas", "icon_shenci_fightmount")

	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["ItemParent"])
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightPower"])
	self.tesu_index = 0
	self.is_max = false
	self.is_auto = false
	self.is_can_auto = true
	self.jinjie_next_time = 0
	self.cur_select_grade = -1
	self.temp_grade = -1
	self.is_first_open = true
	self.old_attrs = {}
	self.mount_skill_list = {}
	self.res_id = -1
	self.prefab_preload_id = 0
	self.last_level = 0
	self.is_can_tip = true

	local other_cfg = FightMountData.Instance:GetOhterCfg()
	self.medal_skill_index = other_cfg and other_cfg.medal_skill_index or 3
	self:GetMountSkill()
	-- self:InitMountSkillIcon()

	local left_time = FuBenData.Instance:GetLastTime()
	if left_time > 0 then
		local last_time = TimeUtil.FormatSecond(left_time, 16)
		self.node_list["TxtRestTime"].text.text = string.format(Language.Advance.RestTime, last_time)
	end
end

function AdvanceFightMountView:__delete()
	self:RemoveCountDown()
	self.tesu_index = 0
	self.cur_select_grade = nil
	self.jinjie_next_time = nil
	self.is_auto = nil
	self.is_can_tip = nil
	self.mount_skill_list = nil
	self.temp_grade = nil
	self.is_first_open = nil
	self.res_id = nil
	self.last_level = nil
	self.begin_clear = nil
	self.clear_time_text = nil
	self.offtime = nil
	if nil ~= self.item then
		self.item:DeleteMe()
		self.item = nil
	end
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	self.old_attrs = {}
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
	if self.count then
		CountDown.Instance:RemoveCountDown(self.count)
	end

	if self.challenge_count_down then
		CountDown.Instance:RemoveCountDown(self.challenge_count_down)
		self.challenge_count_down = nil
	end
	self.count = nil
	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	self.fight_text = nil
	TitleData.Instance:ReleaseTitleEff(self.node_list["BtnTitle"])
end

function AdvanceFightMountView:InitMountSkillIcon()
	for i = 1, 4 do
		self.node_list["AdvanceSkill"..i].toggle:AddValueChangedListener(BindTool.Bind(self.OnClickMountSkill, self, i))
	end
end

function AdvanceFightMountView:OnClickMountSkill(index)
	if index == self.medal_skill_index + 1 then
		ViewManager.Instance:Open(ViewName.TipXunZhangView, nil, "fightmountskill", {index = index - 1})
	else
		if self.is_shake_skill and index == 1 then
			self.node_list["Special"].animator:SetBool("IsShake", false)
			self.is_shake_skill = nil
		end
		ViewManager.Instance:Open(ViewName.TipSkillUpgrade, nil, "fightmountskill", {index = index - 1})
	end
end

--战骑技能
function AdvanceFightMountView:GetMountSkill()
	for i = 1, 4 do
		local cur_level = 0
		local next_level = 1
		local skill = nil
		self.cur_data = FightMountData.Instance:GetMountSkillCfgById(i - 1) or {}
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = FightMountData.Instance:GetMountSkillCfgById(i - 1, next_level) or {}
		local is_teshu = false
		skill = self.node_list["AdvanceSkill"..i]
		if self.cur_data and next(self.cur_data) and self.cur_data.is_teshu then
			is_teshu = self.cur_data.is_teshu == 1
		else
			if self.next_data_cfg and next(self.next_data_cfg) and self.next_data_cfg.is_teshu then
				is_teshu = self.next_data_cfg.is_teshu == 1
			end
		end
		if is_teshu then
			skill = self.node_list["SpecialSkill"]
			self.node_list["AdvanceSkill" ..i ]:SetActive(false)
			self.node_list["SpecialSkill"]:SetActive(true)
			self.node_list["SpecialSkillText"]:SetActive(true)
			self.tesu_index = i
		end

		if self.medal_skill_index + 1 == i then
			skill = self.node_list["BtnSkill"]
			self.node_list["AdvanceSkill" ..i ]:SetActive(false)
			self.node_list["MedalSkill"]:SetActive(true)
		end
		self.node_list["SpecialSkill"]:SetActive(false)
		self.node_list["SpecialSkillText"]:SetActive(false)
		local icon = skill.transform:FindHard("Image")
		icon = U3DObject(icon, icon.transform, self)
		table.insert(self.mount_skill_list, {skill = skill, icon = icon})
	end
	for k, v in pairs(self.mount_skill_list) do
		local bundle, asset = ResPath.GetFightMountSkillIcon(k)
		v.icon.image:LoadSprite(bundle, asset)
		v.skill.toggle:AddClickListener(BindTool.Bind(self.OnClickMountSkill, self, k))
	end
end

function AdvanceFightMountView:FlushSkillIcon()
	local info = FightMountData.Instance:GetFightMountInfo()
	if next(info) then
		local mount_skill_list = info.skill_level_list
		if nil == mount_skill_list then return end

		-- for i = 1,4 do
		-- 	local node = self.node_list["AdvanceSkill"..i].transform:FindHard("Image")
		-- 	if node then
		-- 		UI:SetGraphicGrey(node,mount_skill_list[i - 1] == 0)
		-- 	end
		-- end
		for k, v in pairs(self.mount_skill_list) do
			local node = v.skill.transform:FindHard("Image")
			if node then
				UI:SetGraphicGrey(node,mount_skill_list[k - 1] == 0)
			end
		end
	end

	local mount_info = FightMountData.Instance:GetFightMountInfo()
	if mount_info ~= nil or next(mount_info) ~= nil then
		if mount_info.grade > SHOWSPECGRADE then
			self.node_list["SpecialSkill"]:SetActive(true)
			self.node_list["SpecialSkillText"]:SetActive(true)
		end
	end

	local cur_skill_data = FightMountData.Instance:GetMountSkillCfgById(self.medal_skill_index) or {}
	local cur_grade = cur_skill_data and cur_skill_data.skill_level or 1
	local bundle, asset = ResPath.GetMedalLevelImage(cur_grade)
	self.mount_skill_list[self.medal_skill_index + 1].icon.image:LoadSprite(bundle, asset)
	local next_data_cfg = FightMountData.Instance:GetMountSkillCfgById(self.medal_skill_index, cur_grade + 1)
	if nil == next_data_cfg then
		self.node_list["TimeLimit"]:SetActive(false)
		self.node_list["TxtTimePanel"]:SetActive(false)
	end

	local cur_level = 0
	local next_level = 1
	local cur_data = FightMountData.Instance:GetMountSkillCfgById(self.tesu_index - 1) or {}
	if next(cur_data) then
		cur_level = cur_data.skill_level
		next_level = cur_level + 1
	end
	local next_data_cfg = FightMountData.Instance:GetMountSkillCfgById(self.tesu_index - 1, next_level) or {}
	if next(next_data_cfg) then
		self.node_list["JiHuo"]:SetActive(true)
		self.node_list["JiHuo"].text.text = next_data_cfg.jineng_desc or ""
	else
		self.node_list["JiHuo"]:SetActive(false)
	end
	self.node_list["MostFightPower"]:SetActive(self.tesu_index ~= 0)

	local mount_grade_cfg = FightMountData.Instance:GetMountGradeCfg(self.cur_select_grade)
	if mount_grade_cfg and mount_grade_cfg.image_id then
		local image_cfg = FightMountData.Instance:GetMountImageCfg()
		if image_cfg then
			local color = (self.cur_select_grade / 3 + 1) >= 5 and 5 or math.floor(self.cur_select_grade / 3 + 1)
			local cur_skill_data = FightMountData.Instance:GetMountSkillCfgById(self.medal_skill_index) or {}
			local skill_name = cur_skill_data.skill_name and string.format(Language.Advance.SkillName, cur_skill_data.skill_name) or Language.Advance.NotLevelSkillName
			local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..image_cfg[mount_grade_cfg.image_id].image_name..skill_name.."</color>"
			self.node_list["Name"].text.text = mount_grade_cfg.gradename .. "·" .. name_str
		end
	end
end

-- 开始进阶
function AdvanceFightMountView:OnStartAdvance()
	local mount_info = FightMountData.Instance:GetFightMountInfo()
	-- local star_cfg = FightMountData.Instance:GetMountStarLevelCfg(mount_info.star_level)
	local is_auto_buy_toggle = self.node_list["AutoToggle"].toggle.isOn
	-- if not star_cfg then return end
	local grade_cfg = FightMountData.Instance:GetMountGradeCfg(mount_info.grade)
	if nil == grade_cfg then return end

	local close_func = function()
		local item_id = FightMountData.Instance:GetMountUpStarStuffCfg().up_star_item_id
		local pack_num = grade_cfg.upgrade_stuff_count
		local prop_bag_num = ItemData.Instance:GetItemNumInBagById(item_id) + ItemData.Instance:GetItemNumInBagById(grade_cfg.upgrade_stuff2_id)

		if prop_bag_num < pack_num and not is_auto_buy_toggle then
			-- 物品不足，弹出TIP框
			self.is_auto = false
			self.is_can_tip = true
			self.is_can_auto = true
			self:SetAutoButtonGray()
			local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[item_id]
			if item_cfg == nil then
				TipsCtrl.Instance:ShowItemGetWayView(item_id)
				return
			end

			if item_cfg.bind_gold == 0 then
				TipsCtrl.Instance:ShowShopView(item_id, 2)
				return
			end

			local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
				MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
				if is_buy_quick then
					self.node_list["AutoToggle"].toggle.isOn = true
				end
			end

			TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nil, 1)
			return
		end
		local is_auto_buy = is_auto_buy_toggle and 1 or 0
		local pack_num = grade_cfg and grade_cfg.pack_num or 1
		local next_time = grade_cfg and grade_cfg.next_time or 0.1
		FightMountCtrl.Instance:SendUpGradeReq(is_auto_buy, self.is_auto)
		self.jinjie_next_time = Status.NowTime + (next_time or 0.1)
	end

	local describe = Language.Advance.AdvanceReturnNotLingQu
	if KaifuActivityData.Instance:IsOpenAdvanceReturnActivity() and self.is_can_tip then
		local open_advance_one = KaifuActivityData.Instance:GetOpenAdvanceType(TYPE_UPGRADE_RETURN.FIGHTMOUNT_UPGRADE_RETURN)
		local open_advance_two = KaifuActivityData.Instance:GetOpenAdvanceTypeTwo(TYPE_UPGRADE_RETURN.FIGHTMOUNT_UPGRADE_RETURN)
		local is_not_lingqu_one = AdvancedReturnData.Instance:GetFanHuanRemind() == 1
		local is_not_lingqu_two = AdvancedReturnTwoData.Instance:GetFanHuanTwoRemind() == 1
		if open_advance_one == 1 and is_not_lingqu_one then
			local ok_func = function()
				ViewManager.Instance:Open(ViewName.AdvancedReturn)
				self.is_auto = false
				self.is_can_auto = true
				self:SetAutoButtonGray()
			end
			TipsCtrl.Instance:ShowCommonTip(ok_func, nil, describe, nil, close_func)
			return 
		elseif open_advance_two == 1 and is_not_lingqu_two then
			local ok_func = function()
				ViewManager.Instance:Open(ViewName.AdvancedReturnTwo)
				self.is_auto = false
				self.is_can_auto = true
				self:SetAutoButtonGray()
			end
			TipsCtrl.Instance:ShowCommonTip(ok_func, nil, describe, nil, close_func)
			return
		end
	end

	local is_have_zhishengdan, item_id = FightMountData.Instance:IsHaveZhiShengDanInGrade()
	local item = ItemData.Instance:GetItem(item_id)
	if is_have_zhishengdan and self.is_can_tip and item then
		local function ok_callback()
			PackageCtrl.Instance:SendUseItem(item.index, 1)
			self.is_can_auto = true
			self:SetAutoButtonGray()
		end	
		TipsCtrl.Instance:ShowCommonAutoView(nil, string.format(Language.Advance.IsUseZhiShengDan, mount_info.grade), ok_callback, close_func)
		return
	end
	close_func()
end

function AdvanceFightMountView:AutoUpGradeOnce()
	local jinjie_next_time = 0
	if nil ~= self.upgrade_timer_quest then
		if self.jinjie_next_time >= Status.NowTime then
			jinjie_next_time = self.jinjie_next_time - Status.NowTime
		end
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
	end
	self.is_can_tip = true
	if self.cur_select_grade and self.cur_select_grade > 0 and self.cur_select_grade <= FightMountData.Instance:GetMaxGrade() then
		if self.is_auto then
			self.is_can_tip = false
			self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.OnStartAdvance,self), jinjie_next_time)
		end
	end
end

function AdvanceFightMountView:OnFightMountUpgradeResult(result)
	self.is_can_auto = true
	if 0 == result then
		self.is_auto = false
		self.is_can_tip = true
		self:SetAutoButtonGray()
	else
		self:AutoUpGradeOnce()
	end
end

-- 自动进阶
function AdvanceFightMountView:OnAutomaticAdvance()
	if not self.is_can_auto then return end
	local function ok_callback()
		self.is_auto = self.is_auto == false
		self.is_can_tip = self.is_auto
		self.is_can_auto = false
		self:OnStartAdvance()
		self:SetAutoButtonGray()
	end
	ok_callback()
end

function AdvanceFightMountView:OnClickTalent()
	local is_open, tips = OpenFunData.Instance:CheckIsHide("img_fuling_talent")
	if not is_open then
		TipsCtrl.Instance:ShowSystemMsg(tips)
		return
	end
	local mount_info = FightMountData.Instance:GetFightMountInfo()
	if nil ~= mount_info and nil ~= mount_info.grade then
		if mount_info.grade <= TALENTLEVEL then
			TipsCtrl.Instance:ShowSystemMsg(Language.Advance.WuJieOpen)
		else
			ViewManager.Instance:Open(ViewName.ImageFuLing, TabIndex.img_fuling_talent, "talent_type_tab", {TALENT_TYPE.TALENT_FIGHTMOUNT})
		end
	end
end

function AdvanceFightMountView:OnClickHuanHua()
	AdvanceData.Instance:SetHuanHuaType(TabIndex.fight_mount_huan_hua)
	AdvanceData.Instance:SetImageFulingType(IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_FIGHT_MOUNT)
	ViewManager.Instance:Open(ViewName.AdvanceHuanhua,TabIndex.mount_huanhua,"fightmounthuanhua", {TALENT_TYPE.TALENT_FIGHTMOUNT})
	AdvanceCtrl.Instance:FlushView("fightmounthuanhua")
end

-- 幻化
function AdvanceFightMountView:OnClickShenCiHuanHua()
	ViewManager.Instance:Open(ViewName.ShenCiFightMountHuanHua,TabIndex.shenci_fightmount_huan_hua,"fightmounthuanhua",{TALENT_TYPE.TALENT_WING})
end

function AdvanceFightMountView:OnClickZiZhi()
	local mount_info = FightMountData.Instance:GetFightMountInfo()
	if nil ~= mount_info and nil ~= mount_info.grade then
		if mount_info.grade <= ZIZHILEVEL then
			TipsCtrl.Instance:ShowSystemMsg(Language.Advance.SanJieOpen)
		else
			ViewManager.Instance:Open(ViewName.TipZiZhi, nil, "fightmountzizhi", {item_id = FightMountDanId.ZiZhiDanId})
		end
	end
end

-- 点击进阶装备
function AdvanceFightMountView:OnClickEquipBtn()
	local is_active, activite_grade = FightMountData.Instance:IsOpenEquip()
	if not is_active then
		local name = Language.Advance.PercentAttrNameList[TabIndex.fight_mount] or ""
		TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Advance.OnOpenEquipTip, name, CommonDataManager.GetDaXie(activite_grade), name))
		return
	end
	local mount_info = FightMountData.Instance:GetFightMountInfo()
	if nil ~= mount_info and nil ~= mount_info.grade then
		if mount_info.grade <= EQUIPLEVEL then
			TipsCtrl.Instance:ShowSystemMsg(Language.Advance.SiJieOpen)
		else
			ViewManager.Instance:Open(ViewName.AdvanceEquipView, TabIndex.fight_mount)
		end
	end
end

-- 使用当前坐骑
function AdvanceFightMountView:OnClickUse()
	if not self.cur_select_grade then return end
	local grade_cfg = FightMountData.Instance:GetMountGradeCfg(self.cur_select_grade)
	if not grade_cfg then return end
	FightMountCtrl.Instance:SendUseFightMountImage(grade_cfg.image_id)
end

--显示上一阶形象
function AdvanceFightMountView:OnClickLastButton()
	if not self.cur_select_grade or self.cur_select_grade <= 0 then return end
	self.cur_select_grade = self.cur_select_grade - 1
	self:SetArrowState(self.cur_select_grade)
	self:SwitchGradeAndName(self.cur_select_grade)
end

--显示下一阶形象
function AdvanceFightMountView:OnClickNextButton()
	local mount_info = FightMountData.Instance:GetFightMountInfo()
	local image_cfg = FightMountData.Instance:GetMountImageCfg()
	if not self.cur_select_grade or self.cur_select_grade > mount_info.grade or mount_info.grade == 0 then
		return
	end
	self.cur_select_grade = self.cur_select_grade + 1
	self:SetArrowState(self.cur_select_grade)
	self:SwitchGradeAndName(self.cur_select_grade)
end

function AdvanceFightMountView:SwitchGradeAndName(cur_select_grade)
	if cur_select_grade == nil then return end
	local mount_grade_cfg = FightMountData.Instance:GetMountGradeCfg(cur_select_grade)
	local image_cfg = FightMountData.Instance:GetMountImageCfg()
	if mount_grade_cfg == nil or not image_cfg then return end

	local bundle, asset = nil, nil
	if math.floor(cur_select_grade / 3 + 1) >= 5 then
		 bundle, asset = ResPath.GetMountGradeQualityBG(5)
	else
		 bundle, asset = ResPath.GetMountGradeQualityBG(math.floor(cur_select_grade / 3 + 1))
	end

	local color = (cur_select_grade / 3 + 1) >= 5 and 5 or math.floor(cur_select_grade / 3 + 1)
	local cur_skill_data = FightMountData.Instance:GetMountSkillCfgById(self.medal_skill_index) or {}
	local skill_name = cur_skill_data.skill_name and string.format(Language.Advance.SkillName, cur_skill_data.skill_name) or Language.Advance.NotLevelSkillName
	local name_str = "<color=" .. SOUL_NAME_COLOR[color] .. ">" .. image_cfg[mount_grade_cfg.image_id].image_name ..skill_name .."</color>"
	local call_back = function(model, obj)
		if obj then
			-- model:SetTrigger(ANIMATOR_PARAM.REST)
			obj.gameObject.transform.localRotation = Quaternion.Euler(0, -35, 0)
		end
	end
	UIScene:SetModelLoadCallBack(call_back)
	self.node_list["Name"].text.text = mount_grade_cfg.gradename .. "·" .. name_str
	if mount_grade_cfg and self.res_id ~= image_cfg[mount_grade_cfg.image_id].res_id then
		bundle, asset = ResPath.GetFightMountModel(image_cfg[mount_grade_cfg.image_id].res_id)
		PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
		local load_list = {{bundle, asset}}
		self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
				local bundle_list = {[SceneObjPart.Main] = bundle}
				local asset_list = {[SceneObjPart.Main] = asset}
				UIScene:ModelBundle(bundle_list, asset_list)
			end)

		self.res_id = image_cfg[mount_grade_cfg.image_id].res_id
	end
end

-- 设置坐骑属性
function AdvanceFightMountView:SetMountAtrr()
	local mount_info = FightMountData.Instance:GetFightMountInfo()
	local image_cfg = FightMountData.Instance:GetMountImageCfg()

	if not mount_info or not mount_info.grade or mount_info.grade <= 0 then
		self:SetAutoButtonGray()
		return
	end

	local mount_grade_cfg = FightMountData.Instance:GetMountGradeCfg(mount_info.grade)
	if not mount_grade_cfg then return end

	self.node_list["TextZiZhi"].text.text = mount_info.grade > ZIZHILEVEL and Language.Advance.ZiZhi or Language.Advance.SanJieOpen
	self.node_list["TextEquip"].text.text = mount_info.grade > EQUIPLEVEL and Language.Advance.FightMountEquipType or Language.Advance.SiJieOpen 
	self.node_list["TextTalent"].text.text = mount_info.grade > TALENTLEVEL and Language.Advance.Talent  or Language.Advance.WuJieOpen

	UI:SetGraphicGrey(self.node_list["BtnQualifications"], mount_info.grade <= ZIZHILEVEL)
	UI:SetGraphicGrey(self.node_list["BtnEquipButton"], mount_info.grade <= EQUIPLEVEL)
	-- UI:SetGraphicGrey(self.node_list["BtnFuLingButton"], mount_info.grade <= TALENTLEVEL)
	self.node_list["EffectTalent"]:SetActive(ImageFuLingData.Instance:GetAdvanceTalentRemind(TALENT_TYPE.TALENT_FIGHTMOUNT) > 0 and mount_info.grade > TALENTLEVEL)

	local stuff_item_id = FightMountData.Instance:GetMountUpStarStuffCfg().up_star_item_id

	if self.temp_grade < 0 then
		if mount_grade_cfg.show_grade == 0 then
			self.cur_select_grade = mount_info.grade
		else
			self.cur_select_grade = mount_info.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID and mount_info.grade
									or FightMountData.Instance:GetMountGradeByUseImageId(mount_info.used_imageid)
		end
		self:SetAutoButtonGray()
		self:SetArrowState(self.cur_select_grade)
		self:SwitchGradeAndName(self.cur_select_grade)
		self.temp_grade = mount_info.grade
	else
		if self.temp_grade < mount_info.grade then
			-- 升级成功音效
			AudioService.Instance:PlayAdvancedAudio()
			-- 升级特效
			if not self.effect_cd or self.effect_cd <= Status.NowTime then
				self.node_list["ShowEffect"]:SetActive(false)
				self.node_list["ShowEffect"]:SetActive(true)
				self.effect_cd = EFFECT_CD + Status.NowTime
			end

			if mount_grade_cfg.show_grade == 0 then
				self.cur_select_grade = mount_info.grade
			else
				self.cur_select_grade = mount_info.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID and mount_info.grade
										or FightMountData.Instance:GetMountGradeByUseImageId(mount_info.used_imageid)
			end
			self.is_auto = false
			self.is_can_tip = true
			self:SetAutoButtonGray()
			self:SetArrowState(self.cur_select_grade)
			self:SwitchGradeAndName(mount_info.grade)

		end
		self.temp_grade = mount_info.grade
	end

	local skill_capability = 0
	for i = 0, 3 do
		if FightMountData.Instance:GetMountSkillCfgById(i) then
			skill_capability = skill_capability + FightMountData.Instance:GetMountSkillCfgById(i).capability
		end
	end
	
	local attr = FightMountData.Instance:GetMountAttrSum()
	local capability = CommonDataManager.GetCapability(attr)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = capability + skill_capability
	end
	if mount_info.grade == 1 then
		local attr1 = FightMountData.Instance:GetMountAttrSum(nil, true)
		local attr0 = FightMountData.Instance:GetMountAttrSum()
		local switch_attr_list_1 = CommonDataManager.SwitchAttri(attr1)
		local switch_attr_list_0 = CommonDataManager.SwitchAttri(attr0)
		switch_attr_list_1 = CommonDataManager.GetOrderAttributte(switch_attr_list_1)
		switch_attr_list_0 = CommonDataManager.GetOrderAttributte(switch_attr_list_0)
		local diff_attr = CommonDataManager.LerpAttributeAttr(attr0, attr1)
		local switch_diff_attr_list = CommonDataManager.SwitchAttri(diff_attr)
		switch_diff_attr_list = CommonDataManager.GetOrderAttributte(switch_diff_attr_list)
		local index = 0
		for k, v in pairs(switch_attr_list_1) do
			local attr_name = Language.Advance.NormalAttr[v.key]
			if nil ~= attr_name and v.value ~= 0 then
				index = index + 1
				self.node_list["ShuXing_" .. index]:SetActive(true)
				self.node_list["Value_" .. index]:SetActive(true)
				self.node_list["ShuXing_" .. index].text.text = attr_name
				self.node_list["Value_" .. index].text.text = switch_attr_list_0[k].value or 0
				local is_show = switch_diff_attr_list[k].value == "0" or switch_diff_attr_list[k].value == "0%"
				self.node_list["Arrow" .. index]:SetActive(not is_show)
				self.node_list["AddValue" .. index]:SetActive(not is_show)	
				self.node_list["AddValue" .. index].text.text = switch_diff_attr_list[k].value or 0				
			end
		end
	else
		local attr2 = FightMountData.Instance:GetMountAttrSum()
		local switch_attr_list = CommonDataManager.SwitchAttri(attr2)
		switch_attr_list = CommonDataManager.GetOrderAttributte(switch_attr_list)
		local next_attr = FightMountData.Instance:GetMountAttrSum(nil, true)
		local diff_attr = CommonDataManager.LerpAttributeAttr(attr2, next_attr)
		local switch_diff_attr_list = CommonDataManager.SwitchAttri(diff_attr)
		switch_diff_attr_list = CommonDataManager.GetOrderAttributte(switch_diff_attr_list)
		local index = 0
		for k, v in pairs(switch_attr_list) do
			local attr_name = Language.Advance.NormalAttr[v.key]
			if nil ~= attr_name and v.value ~= 0 then
				index = index + 1
				self.node_list["ShuXing_" .. index]:SetActive(true)
				self.node_list["Value_" .. index]:SetActive(true)
				self.node_list["ShuXing_" .. index].text.text = attr_name
				self.node_list["Value_" .. index].text.text = v.value
				if mount_info.grade >= FightMountData.Instance:GetMaxGrade() then
					self.node_list["Arrow" .. index]:SetActive(false)
					self.node_list["AddValue" .. index]:SetActive(false)
				else
					local is_show = switch_diff_attr_list[k].value == "0" or switch_diff_attr_list[k].value == "0%"
					self.node_list["Arrow" .. index]:SetActive(not is_show)
					self.node_list["AddValue" .. index]:SetActive(not is_show)
					self.node_list["AddValue" .. index].text.text = switch_diff_attr_list[k].value or 0
				end				
			end
		end
	end

	local active_grade, attr_type, attr_value = FightMountData.Instance:GetSpecialAttrActiveType()
	local max_grade = FightMountData.Instance:GetMaxGrade()
	if active_grade and attr_type and attr_value then
		if mount_info.grade < active_grade then
			local str = string.format(Language.Advance.LevelOpen, CommonDataManager.GetDaXie(active_grade - 1))
			self.node_list["TxtSpecialAttr"]:SetActive(true)
			self.node_list["TxtSpecialAttr"].text.text = string.format(Language.Advance.SpecialAttr[attr_type] .. attr_value / 100 .. "%%") .. str
		else
			local str = ""
			local special_attr = nil
			for i = mount_info.grade + 1, max_grade do
				local next_active_grade, next_attr_type, next_attr_value = FightMountData.Instance:GetSpecialAttrActiveType(i)
				if next_attr_value then
					if next_attr_value ~= attr_value then
						special_attr = next_attr_value - attr_value
						str = string.format(Language.Advance.NextAttr, CommonDataManager.GetDaXie(next_active_grade - 1), special_attr / 100)
						break
					end
				end
			end
			self.node_list["TxtSpecialAttr"]:SetActive(true)
			self.node_list["TxtSpecialAttr"].text.text = string.format(Language.Advance.SpecialAttr[attr_type] .. attr_value / 100 .. "%%") .. str
		end
	else
		self.node_list["TxtSpecialAttr"]:SetActive(false)
	end

		local data = {item_id = stuff_item_id}
		self.item:SetData(data)

		-- self.old_attrs = attr_list

		if mount_info.grade >= FightMountData.Instance:GetMaxGrade() then
			self.node_list["CurBless"].text.text = Language.Common.YiMan
			self.node_list["BlessRadio"].slider.value = 1.0
			self.is_max = true
			self:FlushClearTime()
		else
			-- local star_cfg = FightMountData.Instance:GetMountStarLevelCfg(mount_info.star_level)
			-- if nil ~= star_cfg then
	 			if self.is_first_open then
					self.node_list["BlessRadio"].slider.value = mount_info.grade_bless_val/mount_grade_cfg.bless_val_limit
				else
					self.node_list["BlessRadio"].slider.value = mount_info.grade_bless_val/mount_grade_cfg.bless_val_limit
				end
				self.node_list["CurBless"].text.text = mount_info.grade_bless_val .. "/" .. mount_grade_cfg.bless_val_limit
			-- end
		end
	local can_uplevel_skill_list = FightMountData.Instance:CanSkillUpLevelList()
	self.node_list["ShowSkillUplevel"]:SetActive(can_uplevel_skill_list[0] ~= nil)
	self.node_list["ShowSkillUplevel1"]:SetActive(can_uplevel_skill_list[1] ~= nil)
	self.node_list["ShowSkillUplevel2"]:SetActive(can_uplevel_skill_list[2] ~= nil)
	self.node_list["ShowSkillUplevel3"]:SetActive(can_uplevel_skill_list[3] ~= nil)
	self.node_list["ShowMedalUplevel"]:SetActive(can_uplevel_skill_list[3] ~= nil)

	self:SetUseImageButtonState(self.cur_select_grade)
	self.node_list["ShowZizhiRedPoint"]:SetActive(FightMountData.Instance:IsShowZizhiRedPoint())
	self.node_list["ShowHuanhuaRedPoint"]:SetActive(FightMountData.Instance:CanHuanhuaUpgrade())
	self.node_list["ShenCiHuanhuaRed"]:SetActive(FightMountData.Instance:CanShenCiHuanhuaUpgrade())
	self.node_list["ShowEquipRemind"]:SetActive(FightMountData.Instance:CalAllEquipRemind() > 0)
	self.is_first_open = false
	self:FlushNeedItemStr()
end

function AdvanceFightMountView:FlushNeedItemStr()
	local mount_info = FightMountData.Instance:GetFightMountInfo()
	local max_grade = FightMountData.Instance:GetMaxGrade()
	local grade_cfg = FightMountData.Instance:GetMountGradeCfg(mount_info.grade)
	local bag_num = ItemData.Instance:GetItemNumInBagById(grade_cfg.upgrade_stuff_id) + ItemData.Instance:GetItemNumInBagById(grade_cfg.upgrade_stuff2_id)
	local bag_num_str = string.format(Language.Mount.ShowGreenNum, bag_num)
	if bag_num < grade_cfg.upgrade_stuff_count then
		bag_num_str = string.format(Language.Mount.ShowRedNum, bag_num)
	end

	local item_cfg = ItemData.Instance:GetItemConfig(grade_cfg.upgrade_stuff_id)

	local str = string.format("%s / %s", bag_num_str, grade_cfg.upgrade_stuff_count)
	if mount_info.grade < max_grade then
		self.node_list["PropText"].text.text = str
	else
		self.node_list["PropText"].text.text = ToColorStr("- / -", TEXT_COLOR.WHITE)
	end

	local is_show_remind = FightMountData.Instance:CanShowRed()
	self.node_list["RemindBtn"]:SetActive(is_show_remind and (not self.is_auto))
end


function AdvanceFightMountView:SetArrowState(cur_select_grade)
	local mount_info = FightMountData.Instance:GetFightMountInfo()
	local max_grade = FightMountData.Instance:GetMaxGrade()
	local grade_cfg = FightMountData.Instance:GetMountGradeCfg(cur_select_grade)
	if not mount_info or not mount_info.grade or not cur_select_grade or not max_grade then
		return
	end
	self.node_list["BtnRightButton"]:SetActive(cur_select_grade < mount_info.grade + 1 and cur_select_grade < max_grade)
	self.node_list["BtnLeftButton"]:SetActive(grade_cfg.image_id > 1 or (mount_info.grade  == 1 and cur_select_grade > mount_info.grade))
	self:SetUseImageButtonState(cur_select_grade)
end

function AdvanceFightMountView:SetUseImageButtonState(cur_select_grade)
	local mount_info = FightMountData.Instance:GetFightMountInfo()
	local max_grade = FightMountData.Instance:GetMaxGrade()
	local grade_cfg = FightMountData.Instance:GetMountGradeCfg(cur_select_grade)

	if not mount_info or not mount_info.grade or not cur_select_grade or not max_grade then
		return
	end 
	self.node_list["GrayUseButton"]:SetActive(cur_select_grade <= mount_info.grade and grade_cfg.image_id ~= mount_info.used_imageid)
	self.node_list["UseImage"]:SetActive(grade_cfg.image_id == mount_info.used_imageid)
end

-- 物品不足，购买成功后刷新物品数量
function AdvanceFightMountView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	self:FlushNeedItemStr()
end

-- 设置进阶按钮状态
function AdvanceFightMountView:SetAutoButtonGray()
	local mount_info = FightMountData.Instance:GetFightMountInfo()
	if mount_info.grade == nil then return end
	local max_grade = FightMountData.Instance:GetMaxGrade()
	if not mount_info or not mount_info.grade or mount_info.grade <= 0
		or mount_info.grade >= max_grade then
		self.node_list["StartButton"]:SetActive(false)
		self.node_list["AutoButtonText"].text.text = Language.Advance.MaxGradeText
		UI:SetButtonEnabled(self.node_list["StartButton"], false)
		UI:SetButtonEnabled(self.node_list["AutoButton"], false)
		return
	end

	if self.is_auto then
		self.node_list["AutoButtonText"].text.text = Language.Common.Stop
		UI:SetButtonEnabled(self.node_list["StartButton"], false)
		UI:SetButtonEnabled(self.node_list["AutoButton"], true)
	else
		self.node_list["AutoButtonText"].text.text = Language.Common.ZiDongJinJie
		UI:SetButtonEnabled(self.node_list["StartButton"], true)
		UI:SetButtonEnabled(self.node_list["AutoButton"], true)

	end
end

function AdvanceFightMountView:SetModle(is_show)
	if is_show then
		if not FightMountData.Instance:IsActiviteMount() then return end
		local mount_info = FightMountData.Instance:GetFightMountInfo()
		local used_imageid = mount_info.used_imageid
		if used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			local grade_cfg = FightMountData.Instance:GetMountGradeCfg(mount_info.grade)
			used_imageid = grade_cfg and grade_cfg.image_id
		end
		local mount_grade_cfg = FightMountData.Instance:GetMountGradeCfg(mount_info.grade)

		self.node_list["GrayUseButton"]:SetActive(false)

		if used_imageid and mount_grade_cfg and self.cur_select_grade < 0 then
			local cur_select_grade = mount_grade_cfg.show_grade == 0 and mount_info.grade or FightMountData.Instance:GetMountGradeByUseImageId(used_imageid)
			self:SetArrowState(cur_select_grade)
			self:SwitchGradeAndName(cur_select_grade)
			self.cur_select_grade = self.cur_select_grade and cur_select_grade
		end
	else
		self.temp_grade = -1
		self.cur_select_grade = -1
		if self.node_list["ShowEffect"] then
			self.node_list["ShowEffect"]:SetActive(false)
		end
	end
end

function AdvanceFightMountView:ClearTempData()
	self.res_id = -1
	self.cur_select_grade = -1
	self.temp_grade = -1
	self.is_auto = false
	self.is_can_tip = true
end

function AdvanceFightMountView:RemoveNotifyDataChangeCallBack()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.temp_grade = -1
	self.cur_select_grade = -1
	self.res_id = -1
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
end

function AdvanceFightMountView:ResetModleRotation()
	if self.mount_display ~= nil then
		self.mount_display.ui3d_display:ResetRotation()
	end
end

function AdvanceFightMountView:OpenCallBack()
	if self.node_list["ShowEffect"] then
		self.node_list["ShowEffect"]:SetActive(false)
	end
	local mount_info = FightMountData.Instance:GetFightMountInfo()
	self.last_level = mount_info.star_level
	self.node_list["UseImage1"]:SetActive(false)
	self.node_list["BtnText"].text.text = Language.Advance.QiCheng

	self:FlushRestChallengeTime()
end
function AdvanceFightMountView:FlushClearTime()
		--设置祝福值清空
	local mount_info = FightMountData.Instance:GetFightMountInfo()
	local mount_grade_cfg = FightMountData.Instance:GetMountGradeCfg(mount_info.grade)
	local mount_max_grade = FightMountData.Instance:GetMaxGrade()
	if mount_info.grade == mount_max_grade then
		self.node_list["ClearTime"]:SetActive(false)
		return
	end
	if mount_info.grade_bless_val == 0 then
		if nil ~= self.count then
			CountDown.Instance:RemoveCountDown(self.count)
			self.count = nil
		end
	end
	if ADVANCE_CLEAR_BLESS.NOT_CLEAR == mount_grade_cfg.is_clear_bless then
		self.node_list["ClearTime"].text.text = Language.Advance.ClearBlessTip
		return
	end
	if mount_info.grade_bless_val == 0 then
		self.node_list["ClearTime"].text.text = Language.Advance.ClearBlessStr1
		return
	end
	local cleartime = mount_info.clear_upgrade_time
	local servertime = TimeCtrl.Instance:GetServerTime()
	self.offtime = cleartime - servertime

	if self.count ~= nil and mount_grade_cfg.grade == 6 then 	--服务端4阶前发送的servertime为0
		CountDown.Instance:RemoveCountDown(self.count)
		self.count = nil
	end
	if self.count == nil then
		self:ClickTimer(self.offtime)
		self.count = CountDown.Instance:AddCountDown(self.offtime, 1, function ()
		self.offtime = self.offtime - 1
		local offtime = TimeUtil.FormatSecond(self.offtime - 1)
		self.node_list["ClearTime"].text.text = string.format(Language.Advance.ClearBlessStr,tostring(offtime))
	end)
	end
end

--计时器,用于取消默认延迟1s显示
function AdvanceFightMountView:ClickTimer(offtime)
	offtime = offtime - 1
	local temptime = TimeUtil.FormatSecond(offtime - 1)
	self.node_list["ClearTime"].text.text = string.format(Language.Advance.ClearBlessStr,tostring(temptime))
end

function AdvanceFightMountView:OnFlush(param_list)
	if not FightMountData.Instance:IsActiviteMount() then return end

	local advance_view = AdvanceCtrl.Instance:GetAdvanceView()
	if advance_view:IsOpen() and advance_view:GetShowIndex() ~= TabIndex.fight_mount then return end
	self:JinJieReward()
	self:SetMountAtrr()
	self:FlushSkillIcon()
	self:FlushClearTime()
end

function AdvanceFightMountView:FlushRestChallengeTime()
	local cur_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local left_time = FuBenData.Instance:GetLastTime()
	if left_time < 0 then 						-- 开服前5天
		self.node_list["TxtTimePanel"]:SetActive(false)
		self.node_list["TimeLimit"]:SetActive(false)
		return
	end
	if self.node_list["TimeLimit"] then
		self.node_list["TimeLimit"]:SetActive(true)
	end
	if nil == self.challenge_count_down then
		local diff_time = function(elapse_time, total_time)
			local time = math.floor(total_time - elapse_time + 0.5)
			local last_time = TimeUtil.FormatSecond(time, 16)
			if self.node_list and self.node_list["TxtRestTime"] then
				self.node_list["TxtRestTime"].text.text = string.format(Language.Advance.RestTime, last_time)
			end
			if elapse_time >= total_time then
				self.node_list["TxtTimePanel"]:SetActive(false)
				self.node_list["TimeLimit"]:SetActive(false)
				if self.challenge_count_down then
					CountDown.Instance:RemoveCountDown(self.challenge_count_down)
					self.challenge_count_down = nil
				end
			end
		end
		self.challenge_count_down = CountDown.Instance:AddCountDown(left_time, 1, diff_time)
	end
end

--------------------------------------------------进阶奖励相关显示---------------------------------------------------
--进阶奖励相关
function AdvanceFightMountView:JinJieReward()
	local system_type = JINJIE_TYPE.JINJIE_TYPE_FIGHT_MOUNT
	local is_show_small_target = JinJieRewardData.Instance:IsShowSmallTarget(system_type)
	self.node_list["JinJieSmallTarget"]:SetActive(is_show_small_target)
	local target_type
	if is_show_small_target then --小目标
		target_type = JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET
		self:SmallTargetConstantData(system_type, target_type)
		self:SmallTargetNotConstantData(system_type, target_type)
	else -- 大目标
		target_type = JIN_JIE_REWARD_TARGET_TYPE.BIG_TARGET
		self:BigTargetConstantData(system_type, target_type)
		self:BigTargetNotConstantData(system_type, target_type)
	end

	JinJieRewardData.Instance:SetCurSystemType(system_type)

	local is_bipin = AdvanceData.Instance:GetIsBiPinSystemType(system_type)
	if is_bipin and OpenFunData.Instance:CheckIsHide("advance_target") then
		local mount_info = FightMountData.Instance:GetFightMountInfo()
		if mount_info == nil or mount_info.grade == nil then
			return
		end

		local cur_img_grade = mount_info.grade - 1
		if not self.old_img_grade then
			self.old_img_grade = cur_img_grade
		end

		if cur_img_grade < 5 then
			self.act_click_type = 1
			self.node_list["ActPanel"]:SetActive(true)
			self.node_list["ActDesc"].text.text = Language.Advance.ActStateText
			self:SetActTime()
		elseif cur_img_grade >= 5 and cur_img_grade < 8 then
			self.act_click_type = 2
			self.node_list["ActPanel"]:SetActive(true)
			self.node_list["ActDesc"].text.text = Language.Advance.ActStateText2
			self:SetActTime()
		elseif cur_img_grade == 8 then
			self.act_click_type = 3
			self.node_list["ActPanel"]:SetActive(true)
			self.node_list["ActDesc"].text.text = Language.Advance.ActStateText3
			self:SetActTime()
		else
			self.act_click_type = nil
			self.node_list["ActPanel"]:SetActive(false)
		end

		if self.act_click_type then
			local item_id = AdvanceData.Instance:GetSystemTypeJinJieItem(system_type, self.act_click_type)
			local item_cfg = ItemData.Instance:GetItemConfig(item_id)
			local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
			self.node_list["ActIcon"].image:LoadSprite(bundle, asset)
		end

		if self.old_img_grade == 2 and cur_img_grade == 3 then
			AdvanceCtrl.Instance:OpenJinJieShowGoalView(system_type, 1)
		elseif self.old_img_grade == 3 and cur_img_grade == 4 then
			local item_id = AdvanceData.Instance:GetSystemTypeJinJieItem(system_type, UPLEVEL_ITEM_TYPE.SMALL_TYPE)
			local item = ItemData.Instance:GetItem(item_id)
			if item then
				-- local function ok_callback()
				-- 	PackageCtrl.Instance:SendUseItem(item.index, 1)
				-- end	
				-- TipsCtrl.Instance:ShowCommonAutoView(nil, Language.Advance.IsUseItem, ok_callback)
			else
				AdvanceCtrl.Instance:OpenJinJieShowGoalView(system_type, 2)
			end
		elseif self.old_img_grade == 4 and cur_img_grade == 5 then
			self:OnClickOpenSmallTarget()
		elseif self.old_img_grade == 5 and cur_img_grade == 6 then
			AdvanceCtrl.Instance:OpenJinJieShowGoalView(system_type, 3)
		elseif self.old_img_grade == 6 and cur_img_grade == 7 then
			local item_id = AdvanceData.Instance:GetSystemTypeJinJieItem(system_type, UPLEVEL_ITEM_TYPE.BIG_TYPE)
			local item = ItemData.Instance:GetItem(item_id)
			if item then
				-- local function ok_callback()
				-- 	PackageCtrl.Instance:SendUseItem(item.index, 1)
				-- end	
				-- TipsCtrl.Instance:ShowCommonAutoView(nil, Language.Advance.IsUseItem2, ok_callback)
			else
				AdvanceCtrl.Instance:OpenJinJieShowGoalView(system_type, 4)
			end
		elseif self.old_img_grade == 7 and cur_img_grade == 8 then
			AdvanceCtrl.Instance:OpenJinJieShowGoalView(system_type, 5)
		elseif self.old_img_grade == 8 and cur_img_grade == 9 then
			self:OnClickJinJieAward()
		elseif self.old_img_grade == 9 and cur_img_grade == 10 then
			self.node_list["Special"].animator:SetBool("IsShake", true)
			self.is_shake_skill = true
		elseif self.is_shake_skill and cur_img_grade >= 11 then
			self.node_list["Special"].animator:SetBool("IsShake", false)
			self.is_shake_skill = nil
		end
		self.old_img_grade = cur_img_grade
	else
		self.node_list["ActPanel"]:SetActive(false)
	end		
end

function AdvanceFightMountView:ClickActIcon()
	if not self.act_click_type then
		local system_type = JINJIE_TYPE.JINJIE_TYPE_FIGHT_MOUNT
		local mount_info = FightMountData.Instance:GetFightMountInfo()
		if mount_info == nil or mount_info.grade == nil then
			return
		end
		local cur_img_grade = mount_info.grade - 1
		if cur_img_grade < 5 then
			self.act_click_type = 1
		elseif cur_img_grade >= 5 and cur_img_grade < 8 then
			self.act_click_type = 2
		elseif cur_img_grade == 8 then
			self.act_click_type = 3
		end
	end

	if self.act_click_type == 1 then
		local index = DailyChargeData.Instance:GetIsOpenActiveReward() and 3 or 2
		ViewManager.Instance:Open(ViewName.LeiJiDailyView, nil, "list_index", {["list_index"] = index})
	elseif self.act_click_type == 2 then
		local index = DailyChargeData.Instance:GetIsOpenActiveReward() and 5 or 4
		ViewManager.Instance:Open(ViewName.LeiJiDailyView, nil, "list_index", {["list_index"] = index})
	elseif self.act_click_type == 3 then
		ViewManager.Instance:Open(ViewName.CompetitionActivity)
	end
end

function AdvanceFightMountView:SetActTime()
	local time_table = os.date('*t',TimeCtrl.Instance:GetServerTime())
	local cur_time = time_table.hour * 3600 + time_table.min * 60 + time_table.sec
	local diff_time = 24 * 3600 - cur_time
	if self.count_down == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				return
			end
			self.node_list["ActTime"].text.text = string.format(Language.Advance.ActTimeDesc, TimeUtil.FormatSecond(left_time, 10))
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end	
end

--清除大目标/小目标免费数据 target_type 目标类型  不传默认大目标
function AdvanceFightMountView:ClearJinJieFreeData(target_type)
	if target_type and target_type == JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET then --小目标
		self.node_list["TitleFreeTime"].text.text = ""
		self.node_list["TitleFreeTime"]:SetActive(false)
	else    --大目标
		self.node_list["TextFreeTime"].text.text = ""
		self.node_list["TextFreeTime"]:SetActive(false)
	end
end

--大目标 变动显示
function AdvanceFightMountView:BigTargetNotConstantData(system_type, target_type)
	local is_show_jin_jie = JinJieRewardData.Instance:IsShowJinJieRewardIcon(system_type)
	local speical_is_active = JinJieRewardData.Instance:GetSystemIsActiveSpecialImage(system_type)
	local active_is_end = JinJieRewardData.Instance:GetSystemFreeIsEnd(system_type)
	local active_big_target = JinJieRewardData.Instance:GetSystemIsGetActiveNeedItemFromInfo(system_type)
	local can_fetch = JinJieRewardData.Instance:GetSystemIsCanFreeLingQuFromInfo(system_type)

	self.node_list["JinJieBig"]:SetActive(is_show_jin_jie)
	self.node_list["RedPoint"]:SetActive(not speical_is_active)
	-- self.node_list["ItemImage"]:SetActive(speical_is_active)
	self.node_list["TextFreeTime"]:SetActive(not active_is_end)
	self.node_list["Panel1"].animator:SetBool("IsShake1", can_fetch and not active_big_target)
	self.node_list["big_goal_redpoint"]:SetActive(can_fetch and not active_big_target)
	UI:SetGraphicGrey(self.node_list["ItemImage"], not active_big_target)
	self:RemoveCountDown()

	if active_is_end then
		self:ClearJinJieFreeData(target_type)
		return
	end

	local end_time = JinJieRewardData.Instance:GetSystemFreeEndTime(system_type, target_type)
	self:FulshJinJieFreeTime(end_time, target_type)
end

--小目标 变动显示
function AdvanceFightMountView:SmallTargetNotConstantData(system_type, target_type)
	local is_free_end = JinJieRewardData.Instance:GetSystemSmallTargetFreeIsEnd(system_type)
	local is_can_free = JinJieRewardData.Instance:GetSystemSmallIsCanFreeLingQuFromInfo(system_type)
	UI:SetGraphicGrey(self.node_list["BtnTitle"], not is_can_free)
	-- UI:SetGraphicGrey(self.node_list["BtnBigTarget"], not is_can_free)
	self.node_list["TitleFreeTime"]:SetActive(not is_free_end)
	self.node_list["Panel1"].animator:SetBool("IsShake1", is_can_free)
	self.node_list["little_goal_redpoint"]:SetActive(is_can_free)
	self:RemoveCountDown()

	if is_free_end then
		self:ClearJinJieFreeData(target_type)
		return
	end

	local end_time = JinJieRewardData.Instance:GetSystemFreeEndTime(system_type, target_type)
	self:FulshJinJieFreeTime(end_time, target_type)
end

--小目标固定显示
function AdvanceFightMountView:SmallTargetConstantData(system_type, target_type)
	if self.set_small_target then
		return 
	end

	self.set_small_target = true
	local small_target_title_image = JinJieRewardData.Instance:GetSingleRewardCfgParam0(system_type, target_type)
	local bundle, asset = ResPath.GetTitleIcon(small_target_title_image)
	self.node_list["BtnTitle"].image:LoadSprite(bundle, asset)
	TitleData.Instance:LoadTitleEff(self.node_list["BtnTitle"], small_target_title_image or 0, true)

	local power = JinJieRewardData.Instance:GetSmallTargetTitlePower(target_type)
	self.node_list["TitlePower"].text.text = string.format(Language.Advance.AddFightPower, power)
end

--大目标固定显示
function AdvanceFightMountView:BigTargetConstantData(system_type, target_type)
	local flag = JinJieRewardData.Instance:IsShowJinJieRewardIcon(system_type)
	if not flag or self.set_big_target then
		return
	end

	self.set_big_target = true
	local item_id = JinJieRewardData.Instance:GetSingleRewardCfgRewardId(system_type, target_type)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg and self.node_list["ItemImage"] then
		local item_bundle, item_asset = ResPath.GetItemIcon(item_cfg.icon_id)
		self.node_list["ItemImage"].image:LoadSprite(item_bundle, item_asset)
	end
	local bundle, asset = ResPath.GetAdvaneTargetTypeImage(system_type)
	self.node_list["TypeImage"].image:LoadSprite(bundle, asset)

	local per = JinJieRewardData.Instance:GetSingleAttrCfgAttrAddPer(system_type)
	local per_text = per * 0.01
	self.node_list["TextAdd"].text.text = string.format(Language.Advance.AddShuXing, per_text)
end

--刷新免费时间
function AdvanceFightMountView:FulshJinJieFreeTime(end_time, target_type)
	if end_time == 0 then
		self:ClearJinJieFreeData(target_type)
		return
	end

	local now_time = TimeCtrl.Instance:GetServerTime()
	local rest_time = end_time - now_time
	self:SetJinJieFreeTime(rest_time, target_type)
	if rest_time >= 0 and nil == self.least_time_timer then
		self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
			self:SetJinJieFreeTime(rest_time, target_type)
		end)
	else
		self:RemoveCountDown()
		self:ClearJinJieFreeData(target_type)
	end
end

--设置进阶时间
function AdvanceFightMountView:SetJinJieFreeTime(time, target_type)
	if time > 0 then
		local time_str = TimeUtil.FormatSecond(time, 10)
		self:FreeTimeShow(time_str, target_type)
	else
		self:RemoveCountDown()
		self:ClearJinJieFreeData(target_type)
		self:JinJieReward()
	end
end

--免费时间显示
function AdvanceFightMountView:FreeTimeShow(time, target_type)
	if target_type and target_type == JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET then --小目标
		self.node_list["TitleFreeTime"].text.text = string.format(Language.Advance.LimitTime, time) 
	else    --大目标
		self.node_list["TextFreeTime"].text.text = string.format(Language.Advance.LimitTime, time) 
	end
end

--移除倒计时
function AdvanceFightMountView:RemoveCountDown()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

--打开大目标面板
function AdvanceFightMountView:OnClickJinJieAward()
	JinJieRewardCtrl.Instance:OpenJinJieAwardView(JINJIE_TYPE.JINJIE_TYPE_FIGHT_MOUNT)
end

--打开小目标面板
function AdvanceFightMountView:OnClickOpenSmallTarget()
	local function callback()
		local param1 = JINJIE_TYPE.JINJIE_TYPE_FIGHT_MOUNT
		local param2 = JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET
		local req_type = JINJIESYS_REWARD_OPEAR_TYPE.JINJIESYS_REWARD_OPEAR_TYPE_BUY

		local is_can_free = JinJieRewardData.Instance:GetSystemSmallIsCanFreeLingQuFromInfo(param1)
		if is_can_free then
			req_type = JINJIESYS_REWARD_OPEAR_TYPE.JINJIESYS_REWARD_OPEAR_TYPE_FETCH
		end
		JinJieRewardCtrl.Instance:SendJinJieRewardOpera(req_type, param1, param2)
	end

	local data = JinJieRewardData.Instance:GetSmallTargetShowData(JINJIE_TYPE.JINJIE_TYPE_FIGHT_MOUNT, callback)
	TipsCtrl.Instance:ShowTimeLimitTitleView(data)
end
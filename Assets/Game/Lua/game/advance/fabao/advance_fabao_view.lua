AdvanceFaBaoView = AdvanceFaBaoView or BaseClass(BaseRender)

local EFFECT_CD = 1.8
local ZIZHILEVEL = 3
local EQUIPLEVEL = 5
local TALENTLEVEL = 8
local MOVE_TIME = 0.5
local SHOWSPECGRADE = 10

function AdvanceFaBaoView:UIsMove()
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

function AdvanceFaBaoView:__init(instance)
	self.node_list["StartButton"].button:AddClickListener(BindTool.Bind(self.OnStartAdvance, self))
	self.node_list["AutoButton"].button:AddClickListener(BindTool.Bind(self.OnAutomaticAdvance, self))
	self.node_list["GrayUseButton"].button:AddClickListener(BindTool.Bind(self.OnClickUse, self))
	self.node_list["BtnQualifications"].button:AddClickListener(BindTool.Bind(self.OnClickZiZhi, self))
	self.node_list["BtnHuanHua"].button:AddClickListener(BindTool.Bind(self.OnClickHuanHua, self))
	self.node_list["BtnLeftButton"].button:AddClickListener(BindTool.Bind(self.OnClickLastButton, self))
	self.node_list["BtnRightButton"].button:AddClickListener(BindTool.Bind(self.OnClickNextButton, self))
	self.node_list["BtnEquipButton"].button:AddClickListener(BindTool.Bind(self.OnClickEquipBtn, self))
	-- self.node_list["BtnFuLingButton"].button:AddClickListener(BindTool.Bind(self.OnClickTalent, self)) -- 屏蔽天赋
	self.node_list["AutoToggle"].toggle:AddValueChangedListener(BindTool.Bind(self.OnAutoBuyToggleChange, self))
	self.node_list["BtnTitle"].button:AddClickListener(BindTool.Bind(self.OnClickOpenSmallTarget, self))
	self.node_list["BtnBigTarget"].button:AddClickListener(BindTool.Bind(self.OnClickJinJieAward, self))
	self.node_list["SelectToggle"].toggle:AddValueChangedListener(BindTool.Bind(self.ToggleOnClick, self))
	self.node_list["ActPanel"].button:AddClickListener(BindTool.Bind(self.ClickActIcon, self))

	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["ItemParent"])
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightPower"])

	self.tesu_index = 0
	self.fabao_skill_list = {}
	local other_cfg = FaBaoData.Instance:GetOhterCfg()
	self.medal_skill_index = other_cfg and other_cfg.medal_skill_index or 3
	self:GetFaBaoSkill()

	self.is_auto = false
	self.is_can_auto = true
	self.is_can_tip = true
	self.jinjie_next_time = 0
	self.old_attrs = {}
	self.skill_fight_power = 0
	self.res_id = 0
	self.cur_select_grade = -1
	self.temp_grade = -1
	self.prefab_preload_id = 0
	self.last_level = 0

	local left_time = FuBenData.Instance:GetLastTime()
	if left_time > 0 then
		local last_time = TimeUtil.FormatSecond(left_time, 16)
		self.node_list["TxtRestTime"].text.text = string.format(Language.Advance.RestTime, last_time)
	end
end

function AdvanceFaBaoView:__delete()
	self.fight_text = nil
	self:RemoveCountDown()
	self.tesu_index = 0
	self.jinjie_next_time = nil
	self.is_auto = nil
	self.fabao_skill_list = nil
	self.temp_grade = nil
	self.cur_select_grade = nil
	self.old_attrs = {}
	self.skill_fight_power = nil
	self.res_id = nil
	self.last_level = nil
	self.is_can_tip = nil

	if self.item ~= nil then
		self.item:DeleteMe()
		self.item = nil
	end
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
	if self.CountDownTimer then
		CountDown.Instance:RemoveCountDown(self.CountDownTimer)
	end

	if self.challenge_count_down then
		CountDown.Instance:RemoveCountDown(self.challenge_count_down)
		self.challenge_count_down = nil
	end
	self.CountDownTimer = nil

	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	TitleData.Instance:ReleaseTitleEff(self.node_list["BtnTitle"])
end

-- 开始进阶
function AdvanceFaBaoView:OnStartAdvance()
	local fabao_info = FaBaoData.Instance:GetFaBaoInfo()
	if fabao_info.grade == nil or fabao_info.grade <= 0 then
		return
	end
	
	if fabao_info.grade >= FaBaoData.Instance:GetMaxGrade() then
		return
	end
	local close_func = function()
		local grade_cfg = FaBaoData.Instance:GetFaBaoGradeCfg(fabao_info.grade)
		local stuff_item_id = FaBaoData.Instance:GetFaBaoUpgradeStuffCfg(fabao_info.grade)
		local is_auto_buy_toggle = self.node_list["AutoToggle"].toggle.isOn
		local pack_num = grade_cfg.upgrade_stuff_count
		local count_num = ItemData.Instance:GetItemNumInBagById(stuff_item_id) + ItemData.Instance:GetItemNumInBagById(grade_cfg.upgrade_stuff2_id)
		if count_num < pack_num and not is_auto_buy_toggle then
			self.is_auto = false
			self.is_can_auto = true
			self.is_can_tip = true
			self:SetAutoButtonGray()
			-- 物品不足，弹出TIP框
			local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[stuff_item_id]
			if item_cfg == nil then
				TipsCtrl.Instance:ShowSystemMsg(Language.Exchange.NotEnoughItem)
				return
			end

			if item_cfg.bind_gold == 0 then
				TipsCtrl.Instance:ShowShopView(stuff_item_id, 2)
				return
			end

			local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
				MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)

				if is_buy_quick then
					self.node_list["AutoToggle"].toggle.isOn = true
				end
			end
			TipsCtrl.Instance:ShowCommonBuyView(func, stuff_item_id, nofunc, 1)

			return
		end
		local is_auto_buy = self.node_list["AutoToggle"].toggle.isOn and 1 or 0
		local grade_cfg_1_pack_num = FaBaoData.Instance:GetGradeCfg()[1].pack_num
		local pack_num = grade_cfg_1_pack_num and grade_cfg_1_pack_num or 1
		local next_time = grade_cfg and grade_cfg.next_time or 0.1
		FaBaoCtrl.Instance:SendUpGradeReq(CS_FABAO_REQ_TYPE.CS_FABAO_REQ_TYPE_UPGRADE, is_auto_buy, self.is_auto and pack_num or 1)
		
		self.jinjie_next_time = Status.NowTime + (next_time or 0.1)
	end

	local describe = Language.Advance.AdvanceReturnNotLingQu
	if KaifuActivityData.Instance:IsOpenAdvanceReturnActivity() and self.is_can_tip then
		local open_advance_one = KaifuActivityData.Instance:GetOpenAdvanceType(TYPE_UPGRADE_RETURN.FABAO_UPGRADE_RETURN)
		local open_advance_two = KaifuActivityData.Instance:GetOpenAdvanceTypeTwo(TYPE_UPGRADE_RETURN.FABAO_UPGRADE_RETURN)
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

	local is_have_zhishengdan, item_id = FaBaoData.Instance:IsHaveZhiShengDanInGrade()
	local item = ItemData.Instance:GetItem(item_id)
	if is_have_zhishengdan and self.is_can_tip and item then
		local function ok_callback()
			PackageCtrl.Instance:SendUseItem(item.index, 1)
			self.is_can_auto = true
			self:SetAutoButtonGray()
		end	
		TipsCtrl.Instance:ShowCommonAutoView(nil, string.format(Language.Advance.IsUseZhiShengDan, fabao_info.grade), ok_callback, close_func)
		return
	end

	close_func()
end

function AdvanceFaBaoView:AutoUpGradeOnce()
	local jinjie_next_time = 0
	if nil ~= self.upgrade_timer_quest then
		if self.jinjie_next_time >= Status.NowTime then
			jinjie_next_time = self.jinjie_next_time - Status.NowTime
		end
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
	end
	self.is_can_tip = true
	if self.cur_select_grade > 0 and self.cur_select_grade <= FaBaoData.Instance:GetMaxGrade() then
		if self.is_auto then
			self.is_can_tip = false
			self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.OnStartAdvance,self), jinjie_next_time)
		end
	end
end

function AdvanceFaBaoView:FaBaoUpgradeResult(result)
	self.is_can_auto = true
	if 0 == result then
		self.is_auto = false
		self.is_can_auto = true
		self:SetAutoButtonGray()
	else
		self:AutoUpGradeOnce()
	end
end


-- 自动进阶
function AdvanceFaBaoView:OnAutomaticAdvance()
	local fabao_info = FaBaoData.Instance:GetFaBaoInfo()
	if fabao_info.grade == 0 and not self.is_can_auto then
		return
	end

	self.is_auto = self.is_auto == false
	self.is_can_tip = self.is_auto
	self.is_can_auto = false
	self:OnStartAdvance()
	self:SetAutoButtonGray()

end

function AdvanceFaBaoView:OnClickTalent()
	local is_open, tips = OpenFunData.Instance:CheckIsHide("img_fuling_talent")
	if not is_open then
		TipsCtrl.Instance:ShowSystemMsg(tips)
		return
	end
	local fabao_info = FaBaoData.Instance:GetFaBaoInfo()
	if nil ~= fabao_info and nil ~= fabao_info.grade then
		if fabao_info.grade <= TALENTLEVEL then
			TipsCtrl.Instance:ShowSystemMsg(Language.Advance.WuJieOpen)
		else
			ViewManager.Instance:Open(ViewName.ImageFuLing, TabIndex.img_fuling_talent, "talent_type_tab", {TALENT_TYPE.TALENT_FABAO})
		end
	end
end
-- 使用当前法宝
function AdvanceFaBaoView:OnClickUse()
	if self.cur_select_grade == nil then
		return
	end

	local fabao_grade_cfg = FaBaoData.Instance:GetFaBaoGradeCfg(self.cur_select_grade)
	
	if not fabao_grade_cfg then return end
	local image_id = fabao_grade_cfg.image_id
	if not image_id then return end
	
	FaBaoCtrl.Instance:SendUseFaBaoImage(CS_FABAO_REQ_TYPE.CS_FABAO_REQ_TYPE_USEIMA, image_id)
end

--显示上一阶形象
function AdvanceFaBaoView:OnClickLastButton()
	if not self.cur_select_grade or self.cur_select_grade <= 0 then
		return
	end
	self.cur_select_grade = self.cur_select_grade - 1
	self:SetArrowState(self.cur_select_grade)
	self:SwitchGradeAndName(self.cur_select_grade)

	if self.fabao_display ~= nil then
		self.fabao_display.ui3d_display:ResetRotation()
	end
end

--显示下一阶形象
function AdvanceFaBaoView:OnClickNextButton()
	local fabao_info = FaBaoData.Instance:GetFaBaoInfo()
	if not fabao_info.grade or not self.cur_select_grade or self.cur_select_grade > fabao_info.grade or fabao_info.grade == 0 then
		return
	end
	self.cur_select_grade = self.cur_select_grade + 1
	self:SetArrowState(self.cur_select_grade)
	self:SwitchGradeAndName(self.cur_select_grade)

	if self.fabao_display ~= nil then
		self.fabao_display.ui3d_display:ResetRotation()
	end
end

function AdvanceFaBaoView:SwitchGradeAndName(index)
	if index == nil then return end

	local fabao_grade_cfg = FaBaoData.Instance:GetFaBaoGradeCfg(index)
	local image_cfg = FaBaoData.Instance:GetFaBaoImageCfg()
	if fabao_grade_cfg == nil then return end
	local color = (index / 3 + 1) >= 5 and 5 or math.floor(index / 3 + 1)
	local cur_skill_data = FaBaoData.Instance:GetFaBaoSkillCfgById(self.medal_skill_index) or {}
	local skill_name = cur_skill_data.skill_name and string.format(Language.Advance.SkillName, cur_skill_data.skill_name) or Language.Advance.NotLevelSkillName
	local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..image_cfg[fabao_grade_cfg.image_id].image_name..skill_name.."</color>"
	self.node_list["Name"].text.text = fabao_grade_cfg.gradename .. "·" .. name_str
	
	if image_cfg[fabao_grade_cfg.image_id] and self.res_id ~= image_cfg[fabao_grade_cfg.image_id].res_id then

		local call_back = function(model, obj)
			if obj then
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, 30, 0)
			end
		end
		UIScene:SetModelLoadCallBack(call_back)

		local bundle, asset = ResPath.GetFaBaoModel(image_cfg[fabao_grade_cfg.image_id].res_id)
		local load_list = {{bundle, asset}}
		PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
		self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
				local bundle_list = {[SceneObjPart.Main] = bundle}
				local asset_list = {[SceneObjPart.Main] = asset}
				UIScene:ModelBundle(bundle_list, asset_list)
			end)
		self.res_id = image_cfg[fabao_grade_cfg.image_id].res_id
	end
end

-- 资质
function AdvanceFaBaoView:OnClickZiZhi()
	local fabao_info = FaBaoData.Instance:GetFaBaoInfo()
	if nil ~= fabao_info and nil ~= fabao_info.grade then
		if fabao_info.grade <= ZIZHILEVEL then
			TipsCtrl.Instance:ShowSystemMsg(Language.Advance.SanJieOpen)
		else
			ViewManager.Instance:Open(ViewName.TipZiZhi, nil, "fabaozizhi", {item_id = FaBaoDanId.ZiZhiDanId})
		end
	end
end

-- 点击法宝装备
function AdvanceFaBaoView:OnClickEquipBtn()
	local is_active, activite_grade = FaBaoData.Instance:IsOpenEquip()
	if not is_active then
		local name = Language.Advance.PercentAttrNameList[TabIndex.fabao_jinjie] or ""
		TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Advance.OnOpenEquipTip, name, CommonDataManager.GetDaXie(activite_grade), name))
		return
	end
	local fabao_info = FaBaoData.Instance:GetFaBaoInfo()
	if nil ~= fabao_info and nil ~= fabao_info.grade then
		if fabao_info.grade <= EQUIPLEVEL then
			TipsCtrl.Instance:ShowSystemMsg(Language.Advance.SiJieOpen)
		else
			ViewManager.Instance:Open(ViewName.AdvanceEquipView, TabIndex.fabao_jinjie)
		end
	end
end

-- 幻化
function AdvanceFaBaoView:OnClickHuanHua()
	AdvanceData.Instance:SetHuanHuaType(TabIndex.fabao_huan_hua)
	AdvanceData.Instance:SetImageFulingType(IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_FABAO)
	ViewManager.Instance:Open(ViewName.AdvanceHuanhua,TabIndex.mount_huanhua,"fabaohuanhua", {TALENT_TYPE.TALENT_FABAO})
	AdvanceCtrl.Instance:FlushView("fabaohuanhua")
end

-- 点击法宝技能
function AdvanceFaBaoView:OnClickFaBaoSkill(index)
	if index == self.medal_skill_index + 1 then
		ViewManager.Instance:Open(ViewName.TipXunZhangView, nil, "fabaoskill", {index = index - 1})
	else
		if self.is_shake_skill and index == 1 then
			self.node_list["Special"].animator:SetBool("IsShake", false)
			self.is_shake_skill = nil
		end
		ViewManager.Instance:Open(ViewName.TipSkillUpgrade, nil, "fabaoskill", {index = index - 1})
	end
end

function AdvanceFaBaoView:GetFaBaoSkill()
	for i = 1, 4 do
		local cur_level = 0
		local next_level = 1
		local skill = nil
		self.cur_data = FaBaoData.Instance:GetFaBaoSkillCfgById(i - 1) or {}
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = FaBaoData.Instance:GetFaBaoSkillCfgById(i - 1, next_level) or {}
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
		table.insert(self.fabao_skill_list, {skill = skill, icon = icon})
	end
	for k, v in pairs(self.fabao_skill_list) do
		local bundle, asset = ResPath.GetFaBaoSkillIcon(k)
		v.icon.image:LoadSprite(bundle, asset)
		v.skill.toggle:AddClickListener(BindTool.Bind(self.OnClickFaBaoSkill, self, k))
	end
end

function AdvanceFaBaoView:FlushSkillIcon()
	local fabao_skill_list = FaBaoData.Instance:GetFaBaoInfo().skill_level_list

	if nil == fabao_skill_list then return end

	-- for i = 1, 4 do
	-- 	local node = self.node_list["AdvanceSkill"..i].transform:FindHard("Image")
	-- 	if node then
	-- 		UI:SetGraphicGrey(node, fabao_skill_list[i] == 0)
	-- 	end
	-- end
	for k, v in pairs(self.fabao_skill_list) do
		local node = v.skill.transform:FindHard("Image")
		if node then
			UI:SetGraphicGrey(node,fabao_skill_list[k] == 0)
		end
	end

	local fabao_info = FaBaoData.Instance:GetFaBaoInfo()
	if fabao_info ~= nil or fabao_info.grade ~= nil then
		if fabao_info.grade > SHOWSPECGRADE then
			self.node_list["SpecialSkill"]:SetActive(true)
			self.node_list["SpecialSkillText"]:SetActive(true)
		end
	end

	local cur_skill_data = FaBaoData.Instance:GetFaBaoSkillCfgById(self.medal_skill_index) or {}
	local cur_grade = cur_skill_data and cur_skill_data.skill_level or 1
	local bundle, asset = ResPath.GetMedalLevelImage(cur_grade)
	self.fabao_skill_list[self.medal_skill_index + 1].icon.image:LoadSprite(bundle, asset)
	local next_data_cfg = FaBaoData.Instance:GetFaBaoSkillCfgById(self.medal_skill_index, cur_grade + 1)
	if nil == next_data_cfg then
		self.node_list["TimeLimit"]:SetActive(false)
		self.node_list["TxtTimePanel"]:SetActive(false)
	end

	local cur_level = 0
	local next_level = 1
	local cur_data = FaBaoData.Instance:GetFaBaoSkillCfgById(self.tesu_index - 1) or {}
	if next(cur_data) then
		cur_level = cur_data.skill_level
		next_level = cur_level + 1
	end
	local next_data_cfg = FaBaoData.Instance:GetFaBaoSkillCfgById(self.tesu_index - 1, next_level) or {}
	if next(next_data_cfg) then
		self.node_list["JiHuo"]:SetActive(true)
		self.node_list["JiHuo"].text.text = next_data_cfg.jineng_desc or ""
	else
		self.node_list["JiHuo"]:SetActive(false)
	end
	self.node_list["MostFightPower"]:SetActive(self.tesu_index ~= 0)

	local fabao_grade_cfg = FaBaoData.Instance:GetFaBaoGradeCfg(self.cur_select_grade)
	if fabao_grade_cfg and fabao_grade_cfg.image_id then
		local image_cfg = FaBaoData.Instance:GetFaBaoImageCfg()
		if image_cfg then
			local color = (self.cur_select_grade / 3 + 1) >= 5 and 5 or math.floor(self.cur_select_grade / 3 + 1)
			local cur_skill_data = FaBaoData.Instance:GetFaBaoSkillCfgById(self.medal_skill_index) or {}
			local skill_name = cur_skill_data.skill_name and string.format(Language.Advance.SkillName, cur_skill_data.skill_name) or Language.Advance.NotLevelSkillName
			local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..image_cfg[fabao_grade_cfg.image_id].image_name..skill_name.."</color>"
			self.node_list["Name"].text.text = fabao_grade_cfg.gradename .. "·" .. name_str
		end
	end
end

-- 设置法宝属性
function AdvanceFaBaoView:SetFaBaoAtrr()
	local fabao_info = FaBaoData.Instance:GetFaBaoInfo()

	if fabao_info == nil or fabao_info.grade == nil then
		self:SetAutoButtonGray()
		return
	end

	local stuff_item_id = FaBaoData.Instance:GetFaBaoUpgradeStuffCfg(fabao_info.grade)
	if fabao_info.grade == 0 or fabao_info.grade == nil then
		local fabao_grade_cfg = FaBaoData.Instance:GetFaBaoGradeCfg(1)
		self:SetAutoButtonGray()
		return
	end

	local fabao_grade_cfg = FaBaoData.Instance:GetFaBaoGradeCfg(fabao_info.grade)
	if not fabao_grade_cfg then return end

	self.node_list["TextZiZhi"].text.text = fabao_info.grade > ZIZHILEVEL and Language.Advance.ZiZhi or Language.Advance.SanJieOpen
	self.node_list["TextEquip"].text.text = fabao_info.grade > EQUIPLEVEL and Language.Advance.FaoBaoEquipType or Language.Advance.SiJieOpen 
	self.node_list["TextTalent"].text.text = fabao_info.grade > TALENTLEVEL and Language.Advance.Talent  or Language.Advance.WuJieOpen

	UI:SetGraphicGrey(self.node_list["BtnQualifications"], fabao_info.grade <= ZIZHILEVEL)
	UI:SetGraphicGrey(self.node_list["BtnEquipButton"], fabao_info.grade <= EQUIPLEVEL)
	-- UI:SetGraphicGrey(self.node_list["BtnFuLingButton"], fabao_info.grade <= TALENTLEVEL)
	self.node_list["EffectTalent"]:SetActive(ImageFuLingData.Instance:GetAdvanceTalentRemind(TALENT_TYPE.TALENT_FABAO) > 0 and fabao_info.grade > TALENTLEVEL)
	if self.temp_grade < 0 then
		if fabao_grade_cfg.show_grade == 0 then
			self.cur_select_grade = fabao_info.grade
		else
			self.cur_select_grade = fabao_info.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID and fabao_info.grade
									or FaBaoData.Instance:GetFaBaoGradeByUseImageId(fabao_info.used_imageid)
		end
		self:SetAutoButtonGray()
		self:SetArrowState(self.cur_select_grade)
		self:SwitchGradeAndName(self.cur_select_grade)
		self.temp_grade = fabao_info.grade
	else
		if self.temp_grade < fabao_info.grade then
			-- 升级成功音效
			AudioService.Instance:PlayAdvancedAudio()
			-- 升级特效
			if not self.effect_cd or self.effect_cd <= Status.NowTime then
				self.node_list["ShowEffect"]:SetActive(false)
				self.node_list["ShowEffect"]:SetActive(true)

				self.effect_cd = EFFECT_CD + Status.NowTime
			end

			if fabao_grade_cfg.show_grade == 0 then
				self.cur_select_grade = fabao_info.grade
			else
				self.cur_select_grade = fabao_info.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID and fabao_info.grade
										or FaBaoData.Instance:GetFaBaoGradeByUseImageId(fabao_info.used_imageid)
			end
			self.is_auto = false
			self.is_can_tip = true
			self.res_id = -1
			self:SetAutoButtonGray()
			self:SetArrowState(self.cur_select_grade)
			self:SwitchGradeAndName(fabao_info.grade)
		end
		self.temp_grade = fabao_info.grade
	end
	self:SetUseImageButtonState(self.cur_select_grade)

	if fabao_info.grade >= FaBaoData.Instance:GetMaxGrade() then
		self:SetAutoButtonGray()
		self.node_list["CurBless"].text.text = Language.Common.YiMan
		self.node_list["BlessRadio"].slider.value = 1.0
	else
		local grade_cfg = FaBaoData.Instance:GetFaBaoGradeCfg(fabao_info.grade)
		if nil ~= grade_cfg then
			self.node_list["CurBless"].text.text = fabao_info.grade_bless_val .. "/" .. grade_cfg.bless_val_limit
			self.node_list["BlessRadio"].slider.value = fabao_info.grade_bless_val / grade_cfg.bless_val_limit
		end
	end

	local skill_capability = 0
	for i = 0, 3 do
		if FaBaoData.Instance:GetFaBaoSkillCfgById(i) then
			skill_capability = skill_capability + FaBaoData.Instance:GetFaBaoSkillCfgById(i).capability
		end
	end

	self.skill_fight_power = skill_capability

	local attr = FaBaoData.Instance:GetFaBaoAttrSum()
	local capability = CommonDataManager.GetCapability(attr)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = capability + skill_capability
	end
	if fabao_info.grade == 1 then
		local attr1 = FaBaoData.Instance:GetFaBaoAttrSum(nil, true)
		local attr0 = FaBaoData.Instance:GetFaBaoAttrSum()
		local switch_attr_list_1 = CommonDataManager.GetOrderAttributte(attr1)
		local switch_attr_list_0 = CommonDataManager.GetOrderAttributte(attr0)
		local diff_attr = CommonDataManager.LerpAttributeAttr(attr0, attr1)
		local switch_diff_attr_list = CommonDataManager.GetOrderAttributte(diff_attr)		
		local index = 0
		for k, v in pairs(switch_attr_list_1) do
			local attr_name = Language.Advance.NormalAttr[v.key]
			if nil ~= attr_name and v.value ~= 0 then
				index = index + 1
				self.node_list["ShuXing_" .. index]:SetActive(true)
				self.node_list["Value_" .. index]:SetActive(true)
				self.node_list["ShuXing_" .. index].text.text = attr_name
				self.node_list["Value_" .. index].text.text = switch_attr_list_0[k].value or 0
				self.node_list["Arrow" .. index]:SetActive(true)
				self.node_list["AddValue" .. index]:SetActive(true)
				self.node_list["AddValue" .. index].text.text = switch_diff_attr_list[k].value or 0				
			end
		end
	else
		local attr2 = FaBaoData.Instance:GetFaBaoAttrSum()
		local switch_attr_list = CommonDataManager.GetOrderAttributte(attr2)
		local next_attr = FaBaoData.Instance:GetFaBaoAttrSum(nil, true)
		local diff_attr = CommonDataManager.LerpAttributeAttr(attr2, next_attr)
		local switch_diff_attr_list = CommonDataManager.GetOrderAttributte(diff_attr)		
		local index = 0
		for k, v in pairs(switch_attr_list) do
			local attr_name = Language.Advance.NormalAttr[v.key]
			if nil ~= attr_name and v.value ~= 0 then
				index = index + 1
				self.node_list["ShuXing_" .. index]:SetActive(true)
				self.node_list["Value_" .. index]:SetActive(true)
				self.node_list["ShuXing_" .. index].text.text = attr_name
				self.node_list["Value_" .. index].text.text = v.value
				if fabao_info.grade >= FaBaoData.Instance:GetMaxGrade() then
					self.node_list["Arrow" .. index]:SetActive(false)
					self.node_list["AddValue" .. index]:SetActive(false)
				else
					self.node_list["Arrow" .. index]:SetActive(true)
					self.node_list["AddValue" .. index]:SetActive(true)
					self.node_list["AddValue" .. index].text.text = switch_diff_attr_list[k].value or 0
				end				
			end
		end
	end

	local active_grade, attr_type, attr_value = FaBaoData.Instance:GetSpecialAttrActiveType()
	local max_grade = FaBaoData.Instance:GetMaxGrade()
	if active_grade and attr_type and attr_value then
		if fabao_info.grade < active_grade then
			local str = string.format(Language.Advance.LevelOpen, CommonDataManager.GetDaXie(active_grade - 1))
			self.node_list["TxtSpecialAttr"]:SetActive(true)
			self.node_list["TxtSpecialAttr"].text.text = string.format(Language.Advance.SpecialAttr[attr_type] .. attr_value / 100 .. "%%") .. str
		else
			local str = ""
			local special_attr = nil
			for i = fabao_info.grade + 1, max_grade do
				local next_active_grade, next_attr_type, next_attr_value = FaBaoData.Instance:GetSpecialAttrActiveType(i)
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

	self.node_list["ShowZizhiRedPoint"]:SetActive(FaBaoData.Instance:IsShowZizhiRedPoint())
	self.node_list["ShowHuanhuaRedPoint"]:SetActive(FaBaoData.Instance:CanHuanhuaUpgrade())
	self.node_list["ShowEquipRemind"]:SetActive(FaBaoData.Instance:CalAllEquipRemind() > 0)

	local can_uplevel_skill_list = FaBaoData.Instance:CanSkillUpLevelList()
	self.node_list["ShowSkillUplevel1"]:SetActive(can_uplevel_skill_list[1] ~= nil)
	self.node_list["ShowSkillUplevel2"]:SetActive(can_uplevel_skill_list[2] ~= nil)
	self.node_list["ShowSkillUplevel3"]:SetActive(can_uplevel_skill_list[3] ~= nil)
	self.node_list["ShowMedalUplevel"]:SetActive(can_uplevel_skill_list[3] ~= nil)

	local data = {item_id = fabao_grade_cfg.upgrade_stuff_id}
	self.item:SetData(data)

	self:FlushNeedItemStr()
end

function AdvanceFaBaoView:FlushNeedItemStr()
	local fabao_info = FaBaoData.Instance:GetFaBaoInfo()
	local max_grade = FaBaoData.Instance:GetMaxGrade()
	local fabao_grade_cfg = FaBaoData.Instance:GetFaBaoGradeCfg(fabao_info.grade)

	local bag_num = ItemData.Instance:GetItemNumInBagById(fabao_grade_cfg.upgrade_stuff_id) + ItemData.Instance:GetItemNumInBagById(fabao_grade_cfg.upgrade_stuff2_id)
	local stuff_count = fabao_grade_cfg.upgrade_stuff_count
	local bag_num_str = string.format(Language.Mount.ShowGreenNum, bag_num)
	if bag_num < stuff_count or bag_num == 0 then
		bag_num_str = string.format(Language.Mount.ShowRedNum, bag_num)
	end

	local str = string.format("%s / %s", bag_num_str, fabao_grade_cfg.upgrade_stuff_count)
	if fabao_info.grade < max_grade then
		self.node_list["PropText"].text.text = str
	else
		self.node_list["PropText"].text.text = ToColorStr("- / -", TEXT_COLOR.WHITE)
	end
	
	local is_show_remind = FaBaoData.Instance:CanShowRed()
	self.node_list["RemindBtn"]:SetActive(is_show_remind and (not self.is_auto))
end


function AdvanceFaBaoView:SetArrowState(cur_select_grade)
	local fabao_info = FaBaoData.Instance:GetFaBaoInfo()
	local max_grade = FaBaoData.Instance:GetMaxGrade()
	local grade_cfg = FaBaoData.Instance:GetFaBaoGradeCfg(cur_select_grade)

	if not fabao_info or not fabao_info.grade or not cur_select_grade or not max_grade or not grade_cfg then
		return
	end

	self.node_list["BtnRightButton"]:SetActive(cur_select_grade < fabao_info.grade + 1 and cur_select_grade < max_grade)
	self.node_list["BtnLeftButton"]:SetActive((grade_cfg.image_id > 1 or (fabao_info.grade  == 1 and cur_select_grade > fabao_info.grade)))

	self:SetUseImageButtonState(cur_select_grade)
end

function AdvanceFaBaoView:SetUseImageButtonState(cur_select_grade)
	local fabao_info = FaBaoData.Instance:GetFaBaoInfo()
	local max_grade = FaBaoData.Instance:GetMaxGrade()
	local grade_cfg = FaBaoData.Instance:GetFaBaoGradeCfg(cur_select_grade)

	if not fabao_info or not fabao_info.grade or not cur_select_grade or not max_grade or not grade_cfg then
		return
	end

	-- 若使用了特殊形象，将已经激活的基础形象的使用状态全部设置为可以使用
	if fabao_info.is_used_special_img == 1 then
		self.node_list["GrayUseButton"]:SetActive(cur_select_grade <= fabao_info.grade)
		self.node_list["UseImage1"]:SetActive(false)
	else
		self.node_list["GrayUseButton"]:SetActive(cur_select_grade <= fabao_info.grade and grade_cfg.image_id ~= fabao_info.used_imageid)
		self.node_list["UseImage1"]:SetActive(grade_cfg.image_id == fabao_info.used_imageid and fabao_info.is_used_special_img == 0)
	end
end

-- 物品不足，购买成功后刷新物品数量
function AdvanceFaBaoView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	self:FlushNeedItemStr()
end

-- 点击自动进阶后，设置按钮状态
function AdvanceFaBaoView:SetAutoButtonGray()
	local fabao_info = FaBaoData.Instance:GetFaBaoInfo()
	if fabao_info.grade == nil then return end

	local max_grade = FaBaoData.Instance:GetMaxGrade()

	if not fabao_info or not fabao_info.grade or fabao_info.grade <= 0
		or fabao_info.grade >= max_grade then
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

function AdvanceFaBaoView:SetModle(is_show)
	if is_show then
		if not FaBaoData.Instance:IsActiviteFaBao() then
			print_error("FaBao is not activite!")
			return
		end

		local fabao_info = FaBaoData.Instance:GetFaBaoInfo()
		local used_imageid = fabao_info.used_imageid
		local fabao_grade_cfg = FaBaoData.Instance:GetFaBaoGradeCfg(fabao_info.grade)

		self.node_list["GrayUseButton"]:SetActive(false)

		if used_imageid and fabao_grade_cfg and self.cur_select_grade < 0 then
			local cur_select_grade = fabao_grade_cfg.show_grade == 0 and fabao_info.grade or FaBaoData.Instance:GetFaBaoGradeByUseImageId(used_imageid)
			self.cur_select_grade = self.cur_select_grade and cur_select_grade
		end

		self:SetArrowState(self.cur_select_grade)
		self:SwitchGradeAndName(self.cur_select_grade)

	else
		self.temp_grade = -1
		self.cur_select_grade = -1
		if self.node_list["ShowEffect"] then
			self.node_list["ShowEffect"]:SetActive(false)
		end
	end
end

function AdvanceFaBaoView:ClearTempData()
	self.res_id = -1
	self.cur_select_grade = -1
	self.temp_grade = -1
	self.is_auto = false
end



function AdvanceFaBaoView:RemoveNotifyDataChangeCallBack()

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

function AdvanceFaBaoView:ResetModleRotation()

end

-- 剩余时间刷新
function AdvanceFaBaoView:SetRestTime()

end

function AdvanceFaBaoView:OnAutoBuyToggleChange(isOn)

end


function AdvanceFaBaoView:OpenCallBack()
	self.node_list["Hide"]:SetActive(true)
	if self.node_list["ShowEffect"] then
		self.node_list["ShowEffect"]:SetActive(false)
	end

	local flag = SettingData.Instance:GetAdvanceTypeHideFlag(ADVANCE_HIDE_TYPE.FABAO)
	self.node_list["HighLight"]:SetActive(flag == 1)
	self.node_list["UseImage"]:SetActive(false)
	self.node_list["BtnText"].text.text = Language.Advance.Use

	self:FlushRestChallengeTime()
end

function AdvanceFaBaoView:ShowClearOrTips()
	local fabao_info = FaBaoData.Instance:GetFaBaoInfo()
	if fabao_info == nil or fabao_info.grade == nil then
		return
	end
	local max_grade = FaBaoData.Instance:GetMaxGrade()
	local fabao_grade_cfg = FaBaoData.Instance:GetFaBaoGradeCfg(fabao_info.grade)
	if fabao_info.grade_bless_val == 0 then
		if nil ~= self.CountDownTimer then
			CountDown.Instance:RemoveCountDown(self.CountDownTimer)
			self.CountDownTimer = nil
		end
	end
	if fabao_grade_cfg.is_clear_bless == 0 then
		self.node_list["ClearTime"]:SetActive(true)
		self.node_list["ClearTime"].text.text = string.format(Language.Advance.ClearBlessTip)
	elseif fabao_grade_cfg.is_clear_bless ~= 0 then
		if fabao_grade_cfg.grade < max_grade then
			self.node_list["ClearTime"]:SetActive(true)
			is_show_cd_flag = true
			if fabao_info.grade_bless_val == 0 then
				self.node_list["ClearTime"].text.text = Language.Advance.ClearBlessStr1
				return
			end
			local ClearTimes = fabao_info.clear_bless_time
			local ServerTimes = TimeCtrl.Instance:GetServerTime()
			local end_time = ClearTimes - ServerTimes
			if nil == self.CountDownTimer  then
				self:ClickTimer(end_time)
				self.CountDownTimer = CountDown.Instance:AddCountDown(end_time, 1, function ()
				end_time = end_time - 1
				local FinalTime = TimeUtil.FormatSecond(end_time - 1)
				self.node_list["ClearTime"].text.text = string.format(Language.Advance.ClearBlessStr,tostring(FinalTime))
				end)
			end
		else
			self.node_list["ClearTime"]:SetActive(false)
		end
	end
end

--计时器,用于取消默认延迟1s显示
function AdvanceFaBaoView:ClickTimer(offtime)
	offtime = offtime - 1
	local temptime = TimeUtil.FormatSecond(offtime - 1)
	self.node_list["ClearTime"].text.text = string.format(Language.Advance.ClearBlessStr,tostring(offtime))
end

function AdvanceFaBaoView:OnFlush(param_list, uplevel_list)
	if not FaBaoData.Instance:IsActiviteFaBao() then
		return
	end
	local advance_view = AdvanceCtrl.Instance:GetAdvanceView()
	if advance_view:IsOpen() and advance_view:GetShowIndex() ~= TabIndex.fabao_jinjie then return end
	self:JinJieReward()
	self:ShowClearOrTips()

	self:SetFaBaoAtrr()
	self:FlushSkillIcon()
end

function AdvanceFaBaoView:FlushRestChallengeTime()
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
function AdvanceFaBaoView:JinJieReward()
	local system_type = JINJIE_TYPE.JINJIE_TYPE_FABAO
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
		local fabao_info = FaBaoData.Instance:GetFaBaoInfo()
		if fabao_info == nil or fabao_info.grade == nil then
			return
		end
		local cur_img_grade = fabao_info.grade - 1
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

function AdvanceFaBaoView:ClickActIcon()
	if not self.act_click_type then
		local system_type = JINJIE_TYPE.JINJIE_TYPE_FABAO
		local fabao_info = FaBaoData.Instance:GetFaBaoInfo()
		if fabao_info == nil or fabao_info.grade == nil then
			return
		end
		local cur_img_grade = fabao_info.grade - 1
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

function AdvanceFaBaoView:SetActTime()
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
function AdvanceFaBaoView:ClearJinJieFreeData(target_type)
	if target_type and target_type == JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET then --小目标
		self.node_list["TitleFreeTime"].text.text = ""
		self.node_list["TitleFreeTime"]:SetActive(false)
	else    --大目标
		self.node_list["TextFreeTime"].text.text = ""
		self.node_list["TextFreeTime"]:SetActive(false)
	end
end

--大目标 变动显示
function AdvanceFaBaoView:BigTargetNotConstantData(system_type, target_type)
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
function AdvanceFaBaoView:SmallTargetNotConstantData(system_type, target_type)
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
function AdvanceFaBaoView:SmallTargetConstantData(system_type, target_type)
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
function AdvanceFaBaoView:BigTargetConstantData(system_type, target_type)
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
function AdvanceFaBaoView:FulshJinJieFreeTime(end_time, target_type)
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
function AdvanceFaBaoView:SetJinJieFreeTime(time, target_type)
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
function AdvanceFaBaoView:FreeTimeShow(time, target_type)
	if target_type and target_type == JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET then --小目标
		self.node_list["TitleFreeTime"].text.text = string.format(Language.Advance.LimitTime, time) 
	else    --大目标
		self.node_list["TextFreeTime"].text.text = string.format(Language.Advance.LimitTime, time) 
	end
end

--移除倒计时
function AdvanceFaBaoView:RemoveCountDown()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

--打开大目标面板
function AdvanceFaBaoView:OnClickJinJieAward()
	JinJieRewardCtrl.Instance:OpenJinJieAwardView(JINJIE_TYPE.JINJIE_TYPE_FABAO)
end

--打开小目标面板
function AdvanceFaBaoView:OnClickOpenSmallTarget()
	local function callback()
		local param1 = JINJIE_TYPE.JINJIE_TYPE_FABAO
		local param2 = JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET
		local req_type = JINJIESYS_REWARD_OPEAR_TYPE.JINJIESYS_REWARD_OPEAR_TYPE_BUY

		local is_can_free = JinJieRewardData.Instance:GetSystemSmallIsCanFreeLingQuFromInfo(param1)
		if is_can_free then
			req_type = JINJIESYS_REWARD_OPEAR_TYPE.JINJIESYS_REWARD_OPEAR_TYPE_FETCH
		end
		JinJieRewardCtrl.Instance:SendJinJieRewardOpera(req_type, param1, param2)
	end

	local data = JinJieRewardData.Instance:GetSmallTargetShowData(JINJIE_TYPE.JINJIE_TYPE_FABAO, callback)
	TipsCtrl.Instance:ShowTimeLimitTitleView(data)
end

function AdvanceFaBaoView:ToggleOnClick()
	local flag = SettingData.Instance:GetAdvanceTypeHideFlag(ADVANCE_HIDE_TYPE.FABAO) == 0 and 1 or 0
	SettingData.Instance:SetAdvanceTypeHideFlag(ADVANCE_HIDE_TYPE.FABAO, flag)
	self.node_list["HighLight"]:SetActive(flag == 1)
	if flag == 1 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.Hide .. Language.Advance.AdvanceHideType[ADVANCE_HIDE_TYPE.FABAO])
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.UnHide .. Language.Advance.AdvanceHideType[ADVANCE_HIDE_TYPE.FABAO])
	end
	SettingCtrl.Instance:SendHotkeyInfoReq()
end
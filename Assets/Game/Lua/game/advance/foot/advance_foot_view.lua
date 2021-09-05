AdvanceFootView = AdvanceFootView or BaseClass(BaseRender)

local EFFECT_CD = 1.8
local ZIZHILEVEL = 3
local EQUIPLEVEL = 5
local TALENTLEVEL = 8
local MOVE_TIME = 0.5
local SHOWSPECGRADE = 10

function AdvanceFootView:UIsMove()
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

function AdvanceFootView:__init(instance)

	self.node_list["StartButton"].button:AddClickListener(BindTool.Bind(self.OnStartAdvance,self))
	self.node_list["AutoButton"].button:AddClickListener(BindTool.Bind(self.OnAutomaticAdvance,self))
	self.node_list["GrayUseButton"].button:AddClickListener(BindTool.Bind(self.OnClickUse,self))
	self.node_list["BtnQualifications"].button:AddClickListener(BindTool.Bind(self.OnClickZiZhi, self))
	self.node_list["BtnHuanHua"].button:AddClickListener(BindTool.Bind(self.OnClickHuanHua, self))
	self.node_list["BtnLeftButton"].button:AddClickListener(BindTool.Bind(self.OnClickLastButton, self))
	self.node_list["BtnRightButton"].button:AddClickListener(BindTool.Bind(self.OnClickNextButton, self))
	self.node_list["BtnEquipButton"].button:AddClickListener(BindTool.Bind(self.OnClickEquipBtn, self))
	-- self.node_list["BtnFuLingButton"].button:AddClickListener(BindTool.Bind(self.OnClickTalent, self)) -- 屏蔽天赋
	self.node_list["BtnTitle"].button:AddClickListener(BindTool.Bind(self.OnClickOpenSmallTarget, self))
	self.node_list["BtnBigTarget"].button:AddClickListener(BindTool.Bind(self.OnClickJinJieAward, self))
	self.node_list["SelectToggle"].toggle:AddValueChangedListener(BindTool.Bind(self.ToggleOnClick, self))
	self.node_list["ActPanel"].button:AddClickListener(BindTool.Bind(self.ClickActIcon, self))

	self.tesu_index = 0
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["ItemParent"])
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightPower"])

	-- --足迹技能Icon
	-- for i = 1,4 do
	-- 	local bundle,asset = ResPath.GetFootSkillIcon(i)
	-- 	local icon = self.node_list["AdvanceSkill"..i].transform:FindHard("Image")
	-- 	icon = U3DObject(icon, icon.transform, self)
	-- 	icon.image:LoadSprite(bundle, asset)
	-- 	self.node_list["AdvanceSkill"..i].toggle:AddValueChangedListener(BindTool.Bind(self.OnClickFootSkill, self, i))
	-- end
	self.foot_skill_list = {}
	self:GetFootSkill()
	self.is_auto = false
	self.is_can_auto = true
	self.is_can_tip = true
	self.jinjie_next_time = 0
	-- self.old_attrs = {}
	self.skill_fight_power = 0
	self.fix_show_time = 10
	self.res_id = -1
	self.cur_select_grade = -1
	self.temp_grade = -1
	self.prefab_preload_id = nil
	self.last_level = 0
end

function AdvanceFootView:__delete()
	self:RemoveCountDown()
	self.foot_skill_list = nil
	self.is_auto = nil
	self.is_can_auto = nil
	self.jinjie_next_time = nil
	-- self.old_attrs = nil
	self.skill_fight_power = nil
	self.fix_show_time = nil
	self.res_id = nil
	self.cur_select_grade = nil
	self.temp_grade = nil
	self.last_level = nil
	self.is_can_tip = nil

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if nil ~= self.clear_count_down then
		CountDown.Instance:RemoveCountDown(self.clear_count_down)
		self.clear_count_down = nil
	end

	if self.item ~= nil then
		self.item:DeleteMe()
		self.item = nil
	end

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end

	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	self.fight_text = nil
	TitleData.Instance:ReleaseTitleEff(self.node_list["BtnTitle"])
end


function AdvanceFootView:GetFootSkill()
	--足迹技能Icon
	for i = 1,4 do
		-- local bundle,asset = ResPath.GetFootSkillIcon(i)
		-- local icon = self.node_list["AdvanceSkill"..i].transform:FindHard("Image")
		-- icon = U3DObject(icon, icon.transform, self)
		-- icon.image:LoadSprite(bundle, asset)
		-- self.node_list["AdvanceSkill"..i].toggle:AddValueChangedListener(BindTool.Bind(self.OnClickFootSkill, self, i))
		local cur_level = 0
		local next_level = 1
		local skill = nil
		self.cur_data = FootData.Instance:GetFootSkillCfgById(i - 1) or {}
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = FootData.Instance:GetFootSkillCfgById(i - 1, next_level) or {}
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
		self.node_list["SpecialSkill"]:SetActive(false)
		self.node_list["SpecialSkillText"]:SetActive(false)

		local icon = skill.transform:FindHard("Image")
		icon = U3DObject(icon, icon.transform, self)
		table.insert(self.foot_skill_list, {skill = skill, icon = icon})
	end
	for k, v in pairs(self.foot_skill_list) do
		local bundle, asset = ResPath.GetFootSkillIcon(k)
		v.icon.image:LoadSprite(bundle, asset)
		v.skill.toggle:AddValueChangedListener(BindTool.Bind(self.OnClickFootSkill, self, k))
	end
end

-- 开始进阶
function AdvanceFootView:OnStartAdvance()
	local foot_info = FootData.Instance:GetFootInfo()
	if foot_info.grade == 0 or foot_info.grade >= FootData.Instance:GetMaxGrade() then return end
	local foot_grade_cfg = FootData.Instance:GetFootGradeCfg(foot_info.grade)
	local is_auto_buy_toggle = self.node_list["AutoToggle"].toggle.isOn
	local close_func = function()
		if foot_grade_cfg then
			local stuff_item_id = foot_grade_cfg.upgrade_stuff_id  --进阶符id
			local pack_num = foot_grade_cfg.upgrade_stuff_count
			local count_num = ItemData.Instance:GetItemNumInBagById(stuff_item_id) + ItemData.Instance:GetItemNumInBagById(foot_grade_cfg.upgrade_stuff2_id)
			if count_num < pack_num and not is_auto_buy_toggle then
				self.is_auto = false
				self.is_can_auto = true
				self.is_can_tip = true
				self:SetAutoButtonGray()

				-- 物品不足，弹出TIP框
				local item_cfg = ShopData.Instance:GetShopItemCfg(stuff_item_id)
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
		end
		local is_auto_buy = self.node_list["AutoToggle"].toggle.isOn and 1 or 0
		local pack_num = self.is_auto and foot_grade_cfg.pack_num or 1
		local next_time = foot_grade_cfg and foot_grade_cfg.next_time or 0.1
		--发送进阶请求
		FootCtrl.Instance:SendUpGradeReq(is_auto_buy,pack_num)
		self.jinjie_next_time = Status.NowTime + next_time
	end

	local describe = Language.Advance.AdvanceReturnNotLingQu
	if KaifuActivityData.Instance:IsOpenAdvanceReturnActivity() and self.is_can_tip then
		local open_advance_one = KaifuActivityData.Instance:GetOpenAdvanceType(TYPE_UPGRADE_RETURN.FOOT_UPGRADE_RETURN)
		local open_advance_two = KaifuActivityData.Instance:GetOpenAdvanceTypeTwo(TYPE_UPGRADE_RETURN.FOOT_UPGRADE_RETURN)
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

	local is_have_zhishengdan, item_id = FootData.Instance:IsHaveZhiShengDanInGrade()
	local item = ItemData.Instance:GetItem(item_id)
	if is_have_zhishengdan and self.is_can_tip and item then
		local function ok_callback()
			PackageCtrl.Instance:SendUseItem(item.index, 1)
			self.is_can_auto = true
			self:SetAutoButtonGray()
		end	
		TipsCtrl.Instance:ShowCommonAutoView(nil, string.format(Language.Advance.IsUseZhiShengDan, foot_info.grade), ok_callback, close_func)
		return
	end

	close_func()
end

function AdvanceFootView:AutoUpGradeOnce()
	local jinjie_next_time = 0
	if nil ~= self.upgrade_timer_quest then
		if self.jinjie_next_time >= Status.NowTime then
			jinjie_next_time = self.jinjie_next_time - Status.NowTime
		end
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
	end
	self.is_can_tip = true
	if self.cur_select_grade > 0 and self.cur_select_grade <= FootData.Instance:GetMaxGrade() then
		if self.is_auto then
			self.is_can_tip = false
			self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.OnStartAdvance,self), jinjie_next_time)
		end
	end
end

function AdvanceFootView:FootUpgradeResult(result)
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
function AdvanceFootView:OnAutomaticAdvance()
	local foot_info = FootData.Instance:GetFootInfo()
	if foot_info.grade == 0 then return end
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

function AdvanceFootView:OnClickTalent()
	local is_open, tips = OpenFunData.Instance:CheckIsHide("img_fuling_talent")
	if not is_open then
		TipsCtrl.Instance:ShowSystemMsg(tips)
		return
	end
	local foot_info = FootData.Instance:GetFootInfo()
	if nil ~= foot_info and nil ~= foot_info.grade then
		if foot_info.grade <= TALENTLEVEL then
			TipsCtrl.Instance:ShowSystemMsg(Language.Advance.WuJieOpen)
		else
			ViewManager.Instance:Open(ViewName.ImageFuLing, TabIndex.img_fuling_talent, "talent_type_tab", {TALENT_TYPE.TALENT_FOOTPRINT})
		end
	end
end

-- 使用当前足迹
function AdvanceFootView:OnClickUse()
	if nil == self.cur_select_grade then return end
	local grade_cfg = FootData.Instance:GetFootGradeCfg(self.cur_select_grade)
	if not grade_cfg then return end
	FootCtrl.Instance:SendUseFootImage(grade_cfg.image_id)
end

--显示上一阶形象
function AdvanceFootView:OnClickLastButton()
	if not self.cur_select_grade or self.cur_select_grade <= 0 then return  end
	self.cur_select_grade = self.cur_select_grade - 1
	self:SetArrowState(self.cur_select_grade)
	self:SwitchGradeAndName(self.cur_select_grade)
end

--显示下一阶形象
function AdvanceFootView:OnClickNextButton()
	local foot_info = FootData.Instance:GetFootInfo()
	if not self.cur_select_grade or self.cur_select_grade > foot_info.grade or foot_info.grade == 0 then
		return
	end
	self.cur_select_grade = self.cur_select_grade + 1
	self:SetArrowState(self.cur_select_grade)
	self:SwitchGradeAndName(self.cur_select_grade)
end

function AdvanceFootView:SwitchGradeAndName(index)
	if index == nil then return end
	local foot_grade_cfg = FootData.Instance:GetFootGradeCfg(index)
	local image_cfg = FootData.Instance:GetFootImageCfg()
	if foot_grade_cfg == nil then return end
	local color = (index / 3 + 1) >= 5 and 5 or math.floor(index / 3 + 1)
	local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..image_cfg[foot_grade_cfg.image_id].image_name.."</color>"
	self.node_list["Name"].text.text = foot_grade_cfg.gradename .. "·" .. name_str

	if image_cfg[foot_grade_cfg.image_id] and self.res_id ~= image_cfg[foot_grade_cfg.image_id].res_id then

		local call_back = function(model, obj)
			if obj then
				model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, -90, 0)
			end
		end
		
		UIScene:SetModelLoadCallBack(call_back)

		PrefabPreload.Instance:StopLoad(self.prefab_preload_id)

		local bundle, asset = ResPath.GetFootModel(image_cfg[foot_grade_cfg.image_id].res_id)
		local load_list = {{bundle, asset}}
		self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
				local vo = GameVoManager.Instance:GetMainRoleVo()
				local info = {}
				info.foot_info = {used_imageid = foot_grade_cfg.image_id}
				info.prof = PlayerData.Instance:GetRoleBaseProf()
				info.sex = vo.sex
				info.is_not_show_weapon = true
				local fashion_info = FashionData.Instance:GetFashionInfo()
				local is_used_special_img = fashion_info.is_used_special_img
				info.is_normal_fashion = is_used_special_img == 0 and true or false
				info.shizhuang_part_list = {{image_id = 0}, {image_id = is_used_special_img == 0 and fashion_info.use_clothing_index or fashion_info.use_special_img}}
				UIScene:SetRoleModelResInfo(info, false, false, false, false, true)
			end)
		self.res_id = image_cfg[foot_grade_cfg.image_id].res_id
	end
end

-- 资质
function AdvanceFootView:OnClickZiZhi()
	local foot_info = FootData.Instance:GetFootInfo()
	if nil ~= foot_info and nil ~= foot_info.grade then
		if foot_info.grade <= ZIZHILEVEL then
			TipsCtrl.Instance:ShowSystemMsg(Language.Advance.SanJieOpen)
		else
			ViewManager.Instance:Open(ViewName.TipZiZhi, nil, "footzizhi", {item_id = FootDanId.ZiZhiDanId})
		end
	end
end

-- 点击进阶装备
function AdvanceFootView:OnClickEquipBtn()
	local is_active, activite_grade = FootData.Instance:IsOpenEquip()
	if not is_active then
		local name = Language.Advance.PercentAttrNameList[TabIndex.foot_jinjie] or ""
		TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Advance.OnOpenEquipTip, name, CommonDataManager.GetDaXie(activite_grade), name))
		return
	end
	local foot_info = FootData.Instance:GetFootInfo()
	if nil ~= foot_info and nil ~= foot_info.grade then
		if foot_info.grade <= EQUIPLEVEL then
			TipsCtrl.Instance:ShowSystemMsg(Language.Advance.SiJieOpen)
		else
			ViewManager.Instance:Open(ViewName.AdvanceEquipView, TabIndex.foot_jinjie)
		end
	end
end

-- 幻化
function AdvanceFootView:OnClickHuanHua()
	AdvanceData.Instance:SetHuanHuaType(TabIndex.foot_huan_hua)
	AdvanceData.Instance:SetImageFulingType(IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_FOOT_PRINT)
	ViewManager.Instance:Open(ViewName.AdvanceHuanhua,TabIndex.mount_huanhua, "foothuanhua",{TALENT_TYPE.TALENT_FOOTPRINT})
	AdvanceCtrl.Instance:FlushView("foothuanhua")
end

-- 点击足迹技能
function AdvanceFootView:OnClickFootSkill(index)
	if self.is_shake_skill and index == 1 then
		self.node_list["Special"].animator:SetBool("IsShake", false)
		self.is_shake_skill = nil
	end	
	ViewManager.Instance:Open(ViewName.TipSkillUpgrade, nil, "footskill", {index = index - 1})
end

function AdvanceFootView:FlushSkillIcon()
	local foot_skill_list = FootData.Instance:GetFootInfo().skill_level_list
	if nil == foot_skill_list then return end

	-- for i = 1,4 do
	-- 	local node = self.node_list["AdvanceSkill"..i].transform:FindHard("Image")
	-- 	if node then
	-- 		UI:SetGraphicGrey(node,foot_skill_list[i - 1] == 0)
	-- 	end
	-- end
	for k, v in pairs(self.foot_skill_list) do
		local node = v.skill.transform:FindHard("Image")
		if node then
			UI:SetGraphicGrey(node,foot_skill_list[k - 1] == 0)
		end
	end

	local foot_info = FootData.Instance:GetFootInfo()
	if foot_info ~= nil or next(foot_info) ~= nil then
		if foot_info.grade > SHOWSPECGRADE then
			self.node_list["SpecialSkill"]:SetActive(true)
			self.node_list["SpecialSkillText"]:SetActive(true)
		end
	end

	local cur_level = 0
	local next_level = 1
	local cur_data = FootData.Instance:GetFootSkillCfgById(self.tesu_index - 1) or {}
	if next(cur_data) then
		cur_level = cur_data.skill_level
		next_level = cur_level + 1
	end
	local next_data_cfg = FootData.Instance:GetFootSkillCfgById(self.tesu_index - 1, next_level) or {}
	if next(next_data_cfg) then
		self.node_list["JiHuo"]:SetActive(true)
		self.node_list["JiHuo"].text.text = next_data_cfg.jineng_desc or ""
	else
		self.node_list["JiHuo"]:SetActive(false)
	end
	self.node_list["MostFightPower"]:SetActive(self.tesu_index ~= 0)
end

-- 设置足迹属性
function AdvanceFootView:SetFootAtrr()
	local foot_info = FootData.Instance:GetFootInfo()
	if foot_info == nil or foot_info.grade == nil then return end
	local foot_grade_cfg = FootData.Instance:GetFootGradeCfg(foot_info.grade)
	if not foot_grade_cfg then return end
	local stuff_item_id = foot_grade_cfg.upgrade_stuff_id  --足迹进阶符id

	self.node_list["TextZiZhi"].text.text = foot_info.grade > ZIZHILEVEL and Language.Advance.ZiZhi or Language.Advance.SanJieOpen
	self.node_list["TextEquip"].text.text = foot_info.grade > EQUIPLEVEL and Language.Advance.FootEquipType or Language.Advance.SiJieOpen 
	self.node_list["TextTalent"].text.text = foot_info.grade > TALENTLEVEL and Language.Advance.Talent  or Language.Advance.WuJieOpen

	UI:SetGraphicGrey(self.node_list["BtnQualifications"], foot_info.grade <= ZIZHILEVEL)
	UI:SetGraphicGrey(self.node_list["BtnEquipButton"], foot_info.grade <= EQUIPLEVEL)
	-- UI:SetGraphicGrey(self.node_list["BtnFuLingButton"], foot_info.grade <= TALENTLEVEL)
	self.node_list["EffectTalent"]:SetActive(ImageFuLingData.Instance:GetAdvanceTalentRemind(TALENT_TYPE.TALENT_FOOTPRINT) > 0 and foot_info.grade > TALENTLEVEL)

	if self.temp_grade < 0 then
		if foot_grade_cfg.show_grade == 0 then
			self.cur_select_grade = foot_info.grade
		else
			self.cur_select_grade = foot_info.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID and 
				foot_info.grade or FootData.Instance:GetFootGradeByUseImageId(foot_info.used_imageid)
		end

		self:SetAutoButtonGray()
		self:SetArrowState(self.cur_select_grade)
		self:SwitchGradeAndName(self.cur_select_grade)
		self.temp_grade = foot_info.grade
	else
		if self.temp_grade < foot_info.grade then
			-- 升级成功音效
			AudioService.Instance:PlayAdvancedAudio()
			-- 升级特效
			if not self.effect_cd or self.effect_cd <= Status.NowTime then
				self.node_list["ShowEffect"]:SetActive(false)
				self.node_list["ShowEffect"]:SetActive(true)
				self.effect_cd = EFFECT_CD + Status.NowTime
			end

			if foot_grade_cfg.show_grade == 0 then
				self.cur_select_grade = foot_info.grade
			else
				self.cur_select_grade = foot_info.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID and
					 foot_info.grade or FootData.Instance:GetFootGradeByUseImageId(foot_info.used_imageid)
			end

			self.is_auto = false
			self.is_can_tip = true
			self.res_id = -1

			self:SetAutoButtonGray()
			self:SetArrowState(self.cur_select_grade)
			self:SwitchGradeAndName(foot_info.grade)
		end
		self.temp_grade = foot_info.grade
	end
	self:SetUseImageButtonState(self.cur_select_grade)

	if foot_info.grade >= FootData.Instance:GetMaxGrade() then
		self:SetAutoButtonGray()
		self.node_list["CurBless"].text.text = Language.Common.YiMan
		self.node_list["BlessRadio"].slider.value = 1
	else
		--设置祝福值
		if nil ~= foot_grade_cfg then
			self.node_list["CurBless"].text.text = (foot_info.grade_bless_val .. "/" .. foot_grade_cfg.bless_val_limit)
			self.node_list["BlessRadio"].slider.value = (foot_info.grade_bless_val / foot_grade_cfg.bless_val_limit)
		end
	end

	local skill_capability = 0
	for i = 0, 3 do
		if FootData.Instance:GetFootSkillCfgById(i) then
			skill_capability = skill_capability + FootData.Instance:GetFootSkillCfgById(i).capability
		end
	end
	self.skill_fight_power = skill_capability

	local attr = FootData.Instance:GetFootAttrSum()
	local capability = CommonDataManager.GetCapability(attr)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = capability + skill_capability
	end
	if foot_info.grade == 1 then
		local attr1 = FootData.Instance:GetFootAttrSum(nil, true)
		local attr0 = FootData.Instance:GetFootAttrSum()
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
		local attr2 = FootData.Instance:GetFootAttrSum()
		local switch_attr_list = CommonDataManager.GetOrderAttributte(attr2)
		local next_attr = FootData.Instance:GetFootAttrSum(nil, true)
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
				if foot_info.grade >= FootData.Instance:GetMaxGrade() then
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

	local active_grade, attr_type, attr_value = FootData.Instance:GetSpecialAttrActiveType()
	local max_grade = FootData.Instance:GetMaxGrade()
	if active_grade and attr_type and attr_value then
		if foot_info.grade < active_grade then
			local str = string.format(Language.Advance.LevelOpen, CommonDataManager.GetDaXie(active_grade - 1))
			self.node_list["TxtSpecialAttr"]:SetActive(true)
			self.node_list["TxtSpecialAttr"].text.text = string.format(Language.Advance.SpecialAttr[attr_type] .. attr_value / 100 .. "%%") .. str
		else
			local str = ""
			local special_attr = nil
			for i = foot_info.grade + 1, max_grade do
				local next_active_grade, next_attr_type, next_attr_value = FootData.Instance:GetSpecialAttrActiveType(i)
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
	self.node_list["ShowZizhiRedPoint"]:SetActive(FootData.Instance:IsShowZizhiRedPoint())
	self.node_list["ShowHuanhuaRedPoint"]:SetActive(FootData.Instance:CanHuanhuaUpgrade())
	local can_uplevel_skill_list = FootData.Instance:CanSkillUpLevelList()
	self.node_list["ShowSkillUplevel1"]:SetActive(nil ~= can_uplevel_skill_list[1])
	self.node_list["ShowSkillUplevel2"]:SetActive(nil ~= can_uplevel_skill_list[2])
	self.node_list["ShowSkillUplevel3"]:SetActive(nil ~= can_uplevel_skill_list[3])
	self.node_list["ShowEquipRemind"]:SetActive(FootData.Instance:CalAllEquipRemind() > 0)
	self:ShowJinJieDanNum()
end

--显示进阶丹数量 当前拥有/本次消耗
function AdvanceFootView:ShowJinJieDanNum()
	local foot_info = FootData.Instance:GetFootInfo()
	local max_grade = FootData.Instance:GetMaxGrade()
	local grade_cfg = FootData.Instance:GetFootGradeCfg(foot_info.grade)
	if grade_cfg == nil then return end
	local bag_num = ItemData.Instance:GetItemNumInBagById(grade_cfg.upgrade_stuff_id) + ItemData.Instance:GetItemNumInBagById(grade_cfg.upgrade_stuff2_id)
	local bag_num_str = string.format(Language.Mount.ShowGreenNum, bag_num)
	if bag_num < grade_cfg.upgrade_stuff_count then
		bag_num_str = string.format(Language.Mount.ShowRedNum, bag_num)
	end

	local item_cfg = ItemData.Instance:GetItemConfig(grade_cfg.upgrade_stuff_id)

	local str = string.format("%s / %s", bag_num_str, grade_cfg.upgrade_stuff_count)
	if foot_info.grade < max_grade then
		self.node_list["PropText"].text.text = str
	else
		self.node_list["PropText"].text.text = ToColorStr("- / -", TEXT_COLOR.WHITE)
	end

	local is_show_remind = FootData.Instance:CanShowRed()
	self.node_list["RemindBtn"]:SetActive(is_show_remind and (not self.is_auto))
end

--设置切换形象箭头按钮
function AdvanceFootView:SetArrowState(cur_select_grade)
	local foot_info = FootData.Instance:GetFootInfo()
	local max_grade = FootData.Instance:GetMaxGrade()
	local grade_cfg = FootData.Instance:GetFootGradeCfg(cur_select_grade)
	if not foot_info or not foot_info.grade or not cur_select_grade or not max_grade or not grade_cfg then
		return
	end

	self.node_list["BtnRightButton"]:SetActive(cur_select_grade < foot_info.grade + 1 and cur_select_grade < max_grade)
	self.node_list["BtnLeftButton"]:SetActive(grade_cfg.image_id > 1 or (foot_info.grade  == 1 and cur_select_grade > foot_info.grade))
	self:SetUseImageButtonState(cur_select_grade)
end

--设置使用形象按钮
function AdvanceFootView:SetUseImageButtonState(cur_select_grade)
	local foot_info = FootData.Instance:GetFootInfo()
	local max_grade = FootData.Instance:GetMaxGrade()
	local grade_cfg = FootData.Instance:GetFootGradeCfg(cur_select_grade)

	if not foot_info or not foot_info.grade or not cur_select_grade or not max_grade or not grade_cfg then
		return
	end

	self.node_list["GrayUseButton"]:SetActive(cur_select_grade <= foot_info.grade and grade_cfg.image_id ~= foot_info.used_imageid)
	self.node_list["UseImage1"]:SetActive(grade_cfg.image_id == foot_info.used_imageid)

end

-- 点击自动进阶，服务器返回信息，设置按钮状态
function AdvanceFootView:SetAutoButtonGray()
	local foot_info = FootData.Instance:GetFootInfo()
	if foot_info.grade == nil then return end
	local max_grade = FootData.Instance:GetMaxGrade()

	if not foot_info or not foot_info.grade or foot_info.grade <= 0
		or foot_info.grade >= max_grade then
		self.node_list["StartButton"]:SetActive(false)
		self.node_list["AutoButtonText"].text.text = Language.Advance.MaxGradeText
		UI:SetButtonEnabled(self.node_list["StartButton"], false)
		UI:SetButtonEnabled(self.node_list["AutoButton"],false)
		return
	end

	if self.is_auto then
		self.node_list["AutoButtonText"].text.text = Language.Common.Stop
		UI:SetButtonEnabled(self.node_list["StartButton"], false)
		UI:SetButtonEnabled(self.node_list["AutoButton"],true)
	else
		self.node_list["AutoButtonText"].text.text = Language.Common.ZiDongJinJie
		UI:SetButtonEnabled(self.node_list["StartButton"], true)
		UI:SetButtonEnabled(self.node_list["AutoButton"],true)
	end

end

-- 物品不足，购买成功后刷新物品数量
function AdvanceFootView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	self:ShowJinJieDanNum()
end

function AdvanceFootView:SetModle(is_show)
	if is_show then
		if not FootData.Instance:IsActiviteFoot() then
			return
		end
		local foot_info = FootData.Instance:GetFootInfo()
		local used_imageid = foot_info.used_imageid
		local foot_grade_cfg = FootData.Instance:GetFootGradeCfg(foot_info.grade)
		if used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			used_imageid = FootData.Instance:GetFootGradeCfg(foot_info.grade).image_id
		end

		if foot_grade_cfg and used_imageid and self.cur_select_grade < 0 then
			local grade_cfg = FootData.Instance:GetImageListInfo(foot_info.used_imageid)
			if nil == grade_cfg then 
				grade_cfg = {}
				grade_cfg.show_grade = 0
			end
			local cur_select_grade = foot_grade_cfg.show_grade == 0 and foot_info.grade or grade_cfg.show_grade
			self:SetArrowState(cur_select_grade)
			self:SwitchGradeAndName(cur_select_grade)
			self.cur_select_grade = self.cur_select_grade and cur_select_grade
		end
	else
		self.temp_grade = -1
		self.cur_select_grade = -1
		if self.node_list["ShowEffect"]  then
			self.node_list["ShowEffect"]:SetActive(false)
		end
		self.node_list["ShowEffect"]:SetActive(false)
	end
end

function AdvanceFootView:ClearTempData()
	self.res_id = -1
	self.cur_select_grade = -1
	self.temp_grade = -1
	self.is_auto = false
end

function AdvanceFootView:RemoveNotifyDataChangeCallBack()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.temp_grade = -1
	self.res_id = -1
	self.cur_select_grade = -1
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
end


function AdvanceFootView:OpenCallBack()
	self.node_list["Hide"]:SetActive(true)
	if self.node_list["ShowEffect"] then
		self.node_list["ShowEffect"]:SetActive(false)
	end
	local flag = SettingData.Instance:GetAdvanceTypeHideFlag(ADVANCE_HIDE_TYPE.FOOT)
	self.node_list["HighLight"]:SetActive(flag == 1)
	self.node_list["UseImage"]:SetActive(false)
	self.node_list["BtnText"].text.text = Language.Advance.Use
end

function AdvanceFootView:OnFlush(param_list, uplevel_list)
	if not FootData.Instance:IsActiviteFoot() then return end
	
	local advance_view = AdvanceCtrl.Instance:GetAdvanceView()
	if advance_view:IsOpen() and advance_view:GetShowIndex() ~= TabIndex.foot_jinjie then return end
	self:JinJieReward()
	self:SetFootAtrr()
	self:FlushSkillIcon()
	self:ClearBlessTip()
end

function AdvanceFootView:ResetModleRotation()
	if self.foot_display ~= nil then
		self.foot_display.ui3d_display:ResetRotation()
	end
end

--祝福值提示 清空祝福值 清空时间
function AdvanceFootView:ClearBlessTip()
	local footinfo = FootData.Instance:GetFootInfo()
	if footinfo == nil or footinfo.grade == nil then
		return
	end
	local foot_max_grade = FootData.Instance:GetMaxGrade()
	local grade_cfg = FootData.Instance:GetFootGradeCfg(footinfo.grade)
	if footinfo.grade == foot_max_grade then --最大等级
		self.node_list["ClearTime"]:SetActive(false)
		return
	end

	if footinfo.grade_bless_val == 0 then
		if nil ~= self.clear_count_down then
			CountDown.Instance:RemoveCountDown(self.clear_count_down)
			self.clear_count_down = nil
		end
	end

	if ADVANCE_CLEAR_BLESS.NOT_CLEAR == grade_cfg.is_clear_bless then --不清空祝福值显示提示信息
		self.node_list["ClearTime"].text.text = Language.Advance.ClearBlessTip
		return
	end
	if ADVANCE_CLEAR_BLESS.CLEAR == grade_cfg.is_clear_bless then --清空祝福值
		if footinfo.grade_bless_val == 0 then
			self.node_list["ClearTime"].text.text = Language.Advance.ClearBlessStr1
			return
		end
		local clear_bless_time = footinfo.clear_bless_time 
		local server_time = TimeCtrl.Instance:GetServerTime()
		local remaining_time = clear_bless_time - server_time
		if nil == self.clear_count_down then
			self:ClickTimer(remaining_time)
			self.clear_count_down = CountDown.Instance:AddCountDown(remaining_time,1,function()
				remaining_time = remaining_time - 1
				local tmp_time = TimeUtil.FormatSecond(remaining_time - 1)
				self.node_list["ClearTime"].text.text = string.format(Language.Advance.ClearBlessStr,tostring(tmp_time))
			end)
		end
	end
end

--计时器,用于取消默认延迟1s显示
function AdvanceFootView:ClickTimer(remaining_time)
	remaining_time = remaining_time - 1
	local tmp_time = TimeUtil.FormatSecond(remaining_time - 1)
	self.node_list["ClearTime"].text.text = string.format(Language.Advance.ClearBlessStr,tostring(tmp_time))
end

--------------------------------------------------进阶奖励相关显示---------------------------------------------------
--进阶奖励相关
function AdvanceFootView:JinJieReward()
	local system_type = JINJIE_TYPE.JINJIE_TYPE_FOOTPRINT
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
		local foot_info = FootData.Instance:GetFootInfo()
		if foot_info == nil or foot_info.grade == nil then
			return
		end

		local cur_img_grade = foot_info.grade - 1
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
			-- 	local function ok_callback()
			-- 		PackageCtrl.Instance:SendUseItem(item.index, 1)
			-- 	end	
			-- 	TipsCtrl.Instance:ShowCommonAutoView(nil, Language.Advance.IsUseItem2, ok_callback)
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

function AdvanceFootView:ClickActIcon()
	if not self.act_click_type then
		local system_type = JINJIE_TYPE.JINJIE_TYPE_FOOTPRINT
		local foot_info = FootData.Instance:GetFootInfo()
		if foot_info == nil or foot_info.grade == nil then
			return
		end
		local cur_img_grade = foot_info.grade - 1
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

function AdvanceFootView:SetActTime()
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
function AdvanceFootView:ClearJinJieFreeData(target_type)
	if target_type and target_type == JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET then --小目标
		self.node_list["TitleFreeTime"].text.text = ""
		self.node_list["TitleFreeTime"]:SetActive(false)
	else    --大目标
		self.node_list["TextFreeTime"].text.text = ""
		self.node_list["TextFreeTime"]:SetActive(false)
	end
end

--大目标 变动显示
function AdvanceFootView:BigTargetNotConstantData(system_type, target_type)
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
function AdvanceFootView:SmallTargetNotConstantData(system_type, target_type)
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
function AdvanceFootView:SmallTargetConstantData(system_type, target_type)
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
function AdvanceFootView:BigTargetConstantData(system_type, target_type)
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
function AdvanceFootView:FulshJinJieFreeTime(end_time, target_type)
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
function AdvanceFootView:SetJinJieFreeTime(time, target_type)
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
function AdvanceFootView:FreeTimeShow(time, target_type)
	if target_type and target_type == JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET then --小目标
		self.node_list["TitleFreeTime"].text.text = string.format(Language.Advance.LimitTime, time) 
	else    --大目标
		self.node_list["TextFreeTime"].text.text = string.format(Language.Advance.LimitTime, time) 
	end
end

--移除倒计时
function AdvanceFootView:RemoveCountDown()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

--打开大目标面板
function AdvanceFootView:OnClickJinJieAward()
	JinJieRewardCtrl.Instance:OpenJinJieAwardView(JINJIE_TYPE.JINJIE_TYPE_FOOTPRINT)
end

--打开小目标面板
function AdvanceFootView:OnClickOpenSmallTarget()
	local function callback()
		local param1 = JINJIE_TYPE.JINJIE_TYPE_FOOTPRINT
		local param2 = JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET
		local req_type = JINJIESYS_REWARD_OPEAR_TYPE.JINJIESYS_REWARD_OPEAR_TYPE_BUY

		local is_can_free = JinJieRewardData.Instance:GetSystemSmallIsCanFreeLingQuFromInfo(param1)
		if is_can_free then
			req_type = JINJIESYS_REWARD_OPEAR_TYPE.JINJIESYS_REWARD_OPEAR_TYPE_FETCH
		end
		JinJieRewardCtrl.Instance:SendJinJieRewardOpera(req_type, param1, param2)
	end

	local data = JinJieRewardData.Instance:GetSmallTargetShowData(JINJIE_TYPE.JINJIE_TYPE_FOOTPRINT, callback)
	TipsCtrl.Instance:ShowTimeLimitTitleView(data)
end

function AdvanceFootView:ToggleOnClick()
	local flag = SettingData.Instance:GetAdvanceTypeHideFlag(ADVANCE_HIDE_TYPE.FOOT) == 0 and 1 or 0
	SettingData.Instance:SetAdvanceTypeHideFlag(ADVANCE_HIDE_TYPE.FOOT, flag)
	self.node_list["HighLight"]:SetActive(flag == 1)
	if flag == 1 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.Hide .. Language.Advance.AdvanceHideType[ADVANCE_HIDE_TYPE.FOOT])
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.UnHide .. Language.Advance.AdvanceHideType[ADVANCE_HIDE_TYPE.FOOT])
	end
	SettingCtrl.Instance:SendHotkeyInfoReq()
end


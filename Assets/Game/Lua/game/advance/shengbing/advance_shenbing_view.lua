

AdvanceShenBingView = AdvanceShenBingView or BaseClass(BaseRender)

local EFFECT_CD = 1.8
local ZIZHILEVEL = 3
local EQUIPLEVEL = 5
local TALENTLEVEL = 8
local MOVE_TIME = 0.5
local SHOWSPECGRADE = 10

function AdvanceShenBingView:UIsMove()
	UITween.MoveShowPanel(self.node_list["InfoPanel"], Vector3(250 , -17 , 0 ) , MOVE_TIME)
	UITween.MoveShowPanel(self.node_list["SkillPanel"], Vector3(0 , -560 , 0 ) , MOVE_TIME)
	-- UITween.MoveShowPanel(self.node_list["Panel1"], Vector3(165 , 600 , 0 ) , MOVE_TIME)
	UITween.MoveShowPanel(self.node_list["Panel4"], Vector3(-35 , 480 , 0 ) , MOVE_TIME)
	UITween.MoveShowPanel(self.node_list["TitlePanel"], Vector3(0 , 400 , 0 ) , MOVE_TIME)
	UITween.MoveShowPanel(self.node_list["BtnPanel"], Vector3(0 , -360 , 0 ) , MOVE_TIME)
	UITween.AlpahShowPanel(self.node_list["Panel3"], true, MOVE_TIME , DG.Tweening.Ease.InExpo)
	UITween.AlpahShowPanel(self.node_list["Panel2"], true, MOVE_TIME , DG.Tweening.Ease.InExpo)
	UITween.AlpahShowPanel(self.node_list["Panel1"], true, MOVE_TIME , DG.Tweening.Ease.InExpo)
end

function AdvanceShenBingView:__init()

	self.node_list["StartButton"].button:AddClickListener(BindTool.Bind(self.StartAdvance, self))
	self.node_list["AutoButton"].button:AddClickListener(BindTool.Bind(self.AutomaticAdvance, self))
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

	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["ItemParent"])
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightPower"])

	self.tesu_index = 0
	self.show_use_button = false
	self.show_use_image = true
	self.show_right_button = true
	self.show_left_button = true
	self.skill_fight_power = 0
	self.shenbing_skill_list = {}
	self:GetWuQiSkill()

	self.is_can_auto = true
	self.is_look_state = false                      --是否处于预览状态
	self.is_can_tip = true
	self.now_index = FashionData.Instance:GetWuQiGrade() + 1                --从服务器获取当前阶数
	self.show_index = self.now_index                        --当前展示时装的索引
	local cfg = FashionData.Instance:GetUpgradeCfg()
	self.max_index = #cfg                           --最大索引
	self.is_automatic = false                       --是否自动进阶
	self.jinjie_next_time = 0
	self.cur_select_grade = -1
	self.temp_grade = -1
	self.res_id = -1
	self.is_auto = false
	self.cur_cfg_list = {}
end

function AdvanceShenBingView:ReleaseCallBack()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
		if self.item ~= nil then
			self.item:DeleteMe()
		self.item = nil
	end
end 

function AdvanceShenBingView:__delete()
	self:RemoveCountDown()
	if self.item ~= nil then
		self.item:DeleteMe()
		self.item = nil
	end
	self.need_num = nil
	self.remainder_num = nil
	self.is_show_cd = nil
	self.is_max_grade = nil

	self.jinjie_next_time = nil
	self.is_auto = nil
	self.shenbing_skill_list = nil
	self.temp_grade = nil
	self.cur_select_grade = nil
	self.old_attrs = {}
	self.skill_fight_power = nil
	self.res_id = nil
	self.skill_table = nil
	self.last_level = nil
	self.is_text_gray = nil
	self.is_text_gray_blue = nil
	self.is_can_tip = nil

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end

	if self.count then
		CountDown.Instance:RemoveCountDown(self.count)
	end

	self.count = nil
	PrefabPreload.Instance:StopLoad(self.pre_load_id)
	self.fight_text = nil
	TitleData.Instance:ReleaseTitleEff(self.node_list["BtnTitle"])
end

function AdvanceShenBingView:OnFlush(param_list, uplevel_list)
	if not FashionData.Instance:IsActiviteWuQi() then
		return
	end
	
	local advance_view = AdvanceCtrl.Instance:GetAdvanceView()
	if advance_view:IsOpen() and advance_view:GetShowIndex() ~= TabIndex.role_shenbing then return end

	self:JinJieReward()
	self:ShowClearOrTips()
	self:SetWuQiAtrr()
	self:FlushSkillIcon()
	self:SetModelCamera()
end

function AdvanceShenBingView:SwitchGradeAndName(index)
	if nil == index then return end
	local wuqi_grade_cfg = FashionData.Instance:GetWuQiGradeCfg(index) 
	local image_cfg = FashionData.Instance:GetWuQiImageID() 
	if nil == wuqi_grade_cfg or nil == image_cfg then return end
	local color = (index / 3 + 1) >= 5 and 5 or math.floor(index / 3 + 1)
	local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..image_cfg[wuqi_grade_cfg.image_id].image_name.."</color>"
	self.node_list["Name"].text.text = wuqi_grade_cfg.gradename .. "·" .. name_str
	self.model_data = image_cfg[wuqi_grade_cfg.image_id] 
	local role_vo = PlayerData.Instance:GetRoleVo()
	local prof = PlayerData.Instance:GetRoleBaseProf()
	local modela = self.model_data["resouce" .. prof .. role_vo.sex]  -- 当前角色神兵id 
	local call_back = function(model, obj)
		if obj then
			model:SetTrigger(ANIMATOR_PARAM.FIGHT)
			if prof == GameEnum.ROLE_PROF_4 then
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, -45, 0)
			else
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, 0, 0)
			end
		end
	end
	UIScene:SetModelLoadCallBack(call_back)

	local load_list = {}
	if tonumber(prof..role_vo.sex) == 30 then   
		local  tmp_split_list = Split(modela,",")
		for i = 1,#tmp_split_list do
			load_list[i] = ResPath.GetWeaponModel(tmp_split_list[i])
		end
	else
		local  bundle,asset = ResPath.GetWeaponModel(modela)
		load_list = {{bundle,asset}}
	end

	PrefabPreload.Instance:StopLoad(self.pre_load_id)
	self.pre_load_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
		local vo = GameVoManager.Instance:GetMainRoleVo()
		local info = {}
		info.prof = PlayerData.Instance:GetRoleBaseProf()
		info.sex = vo.sex
		local fashion_info = FashionData.Instance:GetFashionInfo()
		local is_used_special_img = fashion_info.is_used_special_img
		info.is_normal_fashion = is_used_special_img == 0 and true or false
		info.is_normal_wuqi = true
		info.shizhuang_part_list = {{image_id = wuqi_grade_cfg.image_id}, {image_id = is_used_special_img == 0 and fashion_info.use_clothing_index or fashion_info.use_special_img}}
		UIScene:SetRoleModelResInfo(info, false, false, false, true)
	end)
end

function AdvanceShenBingView:ClearTempData()
	self.res_id = -1
	self.cur_select_grade = -1
	self.temp_grade = -1
	self.is_auto = false
end

function AdvanceShenBingView:StartAdvance()
	local wuqi_info = FashionData.Instance:GetWuQiInfo()
	if wuqi_info.grade == 0 or wuqi_info.grade >= FashionData.Instance:GetMaxGrade() then
		return
	end
	local close_func = function()
		local wuqi_grade_cfg = FashionData.Instance:GetWuQiGradeCfg(wuqi_info.grade)
		local is_auto_buy_toggle = self.node_list["AutoToggle"].toggle.isOn
		local stuff_item_id = wuqi_grade_cfg.upgrade_stuff_id  --进阶符id
		local pack_num = wuqi_grade_cfg.upgrade_stuff_count
		local count_num = ItemData.Instance:GetItemNumInBagById(stuff_item_id) + ItemData.Instance:GetItemNumInBagById(wuqi_grade_cfg.upgrade_stuff2_id)
		if count_num < pack_num and not is_auto_buy_toggle then
			self.is_auto = false
			self.is_can_auto = true
			self.is_can_tip = true
			self:SetWuQiAtrr()
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

		local is_auto_buy = self.node_list["AutoToggle"].toggle.isOn and 1 or 0 
		local pack_num = self.is_auto and wuqi_grade_cfg.pack_num or 1
		local next_time = wuqi_grade_cfg and wuqi_grade_cfg.next_time or 0.1
		--发送进阶请求
		FashionCtrl.Instance:SendShenBingUpgradeReq(is_auto_buy, self.is_auto, pack_num)
		self.jinjie_next_time = Status.NowTime + (next_time or 0.1)
	end

	local describe = Language.Advance.AdvanceReturnNotLingQu
	if KaifuActivityData.Instance:IsOpenAdvanceReturnActivity() and self.is_can_tip then
		local open_advance_one = KaifuActivityData.Instance:GetOpenAdvanceType(TYPE_UPGRADE_RETURN.WUQI_UPGRADE_RETURN)
		local open_advance_two = KaifuActivityData.Instance:GetOpenAdvanceTypeTwo(TYPE_UPGRADE_RETURN.WUQI_UPGRADE_RETURN)
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

	local is_have_zhishengdan, item_id = FashionData.Instance:IsHaveZhiShengDanInGrade()
	local item = ItemData.Instance:GetItem(item_id)
	if is_have_zhishengdan and self.is_can_tip and item then
		local function ok_callback()
			PackageCtrl.Instance:SendUseItem(item.index, 1)
			self.is_can_auto = true
			self:SetAutoButtonGray()
		end	
		TipsCtrl.Instance:ShowCommonAutoView(nil, string.format(Language.Advance.IsUseZhiShengDan, wuqi_info.grade), ok_callback, close_func)
		return
	end

	close_func()
end

function AdvanceShenBingView:AutoUpGradeOnce()
	local jinjie_next_time = 0
	if nil ~= self.upgrade_timer_quest then
		if self.jinjie_next_time >= Status.NowTime then
			jinjie_next_time = self.jinjie_next_time - Status.NowTime
		end
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
	end
	self.is_can_tip = true
	if self.cur_select_grade > 0 and self.cur_select_grade <= FashionData.Instance:GetMaxGrade() then
		if self.is_auto then
			self.is_can_tip = false
			self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.StartAdvance,self), jinjie_next_time)
		end
	end
end

function AdvanceShenBingView:AutomaticAdvance()
	local wuqi_info = FashionData.Instance:GetWuQiInfo()

	if wuqi_info.grade == 0 then
		return
	end
	if not self.is_can_auto then
		return
	end

	local function ok_callback()
		self.is_auto = self.is_auto == false
		self.is_can_tip = self.is_auto
		self.is_can_auto = false
		self:StartAdvance()
		self:SetAutoButtonGray()
	end
		ok_callback()
end

--武器自动进阶其他返回
function AdvanceShenBingView:ShenBingUpgradeResult(result)
	self.is_can_auto = true

	if 0 == result then
		self.is_auto = false
		self.is_can_auto = true
		self:SetAutoButtonGray()
	else
		self:AutoUpGradeOnce()
		self:SetAutoButtonGray()
	end
end

-- 使用当前武器形象
function AdvanceShenBingView:OnClickUse()

	if self.cur_select_grade == nil then
		return
	end

	local grade_cfg = FashionData.Instance:GetWuQiGradeCfg(self.cur_select_grade)

	if not grade_cfg then return end
	FashionCtrl.Instance:SendShizhuangUseReq(SHIZHUANG_TYPE.WUQI, 0, grade_cfg.image_id)
end


function AdvanceShenBingView:SetWuQiAtrr()
	local wuqi_info = FashionData.Instance:GetWuQiInfo()
	-- local image_cfg = FashionData.Instance:GetWuQiImageID()

	if wuqi_info == nil or wuqi_info.grade == nil then
		self:SetAutoButtonGray()
		return
	end
	local wuqi_grade_cfg = FashionData.Instance:GetWuQiGradeCfg(wuqi_info.grade)
	local stuff_item_id = wuqi_grade_cfg.upgrade_stuff_id

	self.node_list["TextZiZhi"].text.text = wuqi_info.grade > ZIZHILEVEL and Language.Advance.ZiZhi or Language.Advance.SanJieOpen
	self.node_list["TextEquip"].text.text = wuqi_info.grade > EQUIPLEVEL and Language.Advance.ShenBingEquipType or Language.Advance.SiJieOpen 
	self.node_list["TextTalent"].text.text = wuqi_info.grade > TALENTLEVEL and Language.Advance.Talent  or Language.Advance.WuJieOpen

	UI:SetGraphicGrey(self.node_list["BtnQualifications"], wuqi_info.grade <= ZIZHILEVEL)
	UI:SetGraphicGrey(self.node_list["BtnEquipButton"], wuqi_info.grade <= EQUIPLEVEL)
	-- UI:SetGraphicGrey(self.node_list["BtnFuLingButton"], wuqi_info.grade <= TALENTLEVEL)
	self.node_list["EffectTalent"]:SetActive(ImageFuLingData.Instance:GetAdvanceTalentRemind(TALENT_TYPE.TALENT_SHENYI) > 0 and wuqi_info.grade > TALENTLEVEL)
	if not wuqi_grade_cfg then return end
	if self.temp_grade < 0 then
		if wuqi_grade_cfg.image_id == 0 then
			self.cur_select_grade = wuqi_info.grade
		else
			local grade_cfg = FashionData.Instance:GetImageListInfo(wuqi_info.use_idx)
			local image_id = nil
			if grade_cfg and next(grade_cfg) then
				image_id = wuqi_info.grade == 1 and grade_cfg.image_id or grade_cfg.image_id + 1
			end
			image_id = image_id or 1
			-- self.cur_select_grade = wuqi_info.use_idx >= GameEnum.MOUNT_SPECIAL_IMA_ID and wuqi_info.grade or image_id
			self.cur_select_grade = wuqi_info.grade
		end
		self:SetAutoButtonGray()
		self:SetArrowState(self.cur_select_grade)
		self:SwitchGradeAndName(self.cur_select_grade)
		self.temp_grade = wuqi_info.grade
	else
		if self.temp_grade < wuqi_info.grade then
			-- 升级成功音效
			AudioService.Instance:PlayAdvancedAudio()
			-- 升级特效
			if not self.effect_cd or self.effect_cd <= Status.NowTime then
				self.node_list["ShowEffect"]:SetActive(false)
				self.node_list["ShowEffect"]:SetActive(true)
				self.effect_cd = EFFECT_CD + Status.NowTime
			end
			if wuqi_grade_cfg.image_id == 0 then
				self.cur_select_grade = wuqi_info.grade
			else
				local grade_cfg = FashionData.Instance:GetImageListInfo(wuqi_info.use_idx)
				self.cur_select_grade = wuqi_info.use_idx >= GameEnum.MOUNT_SPECIAL_IMA_ID and wuqi_info.grade or (grade_cfg.image_id + 1)
			end
			
			self.is_auto = false
			self.is_can_tip = true
			self.res_id = -1

			self:SetAutoButtonGray()
			self:SetArrowState(self.cur_select_grade)
			self:SwitchGradeAndName(wuqi_info.grade)
		end
		self.temp_grade = wuqi_info.grade
	end

	self:SetUseImageButtonState(self.cur_select_grade)

	if wuqi_info.grade >= FashionData.Instance:GetMaxGrade() then
		self:SetAutoButtonGray()
		self.node_list["CurBless"].text.text = Language.Common.YiMan
		self.node_list["BlessRadio"].slider.value = 1
	else
		--设置祝福值
		if nil ~= wuqi_grade_cfg then
			self.node_list["CurBless"].text.text = wuqi_info.grade_bless_val .. "/"..wuqi_grade_cfg.bless_val_limit
			self.node_list["BlessRadio"].slider.value = wuqi_info.grade_bless_val/wuqi_grade_cfg.bless_val_limit
		end
	end

	local skill_capability = 0
	for i = 0, 3 do
		if FashionData.Instance:GetWuQiSkillCfgById(i) then
			skill_capability = skill_capability + FashionData.Instance:GetWuQiSkillCfgById(i).capability
		end
	end
	self.skill_fight_power = skill_capability

	local attr = FashionData.Instance:GetWuQiAttrNum()
	local capability = CommonDataManager.GetCapability(attr)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = capability + skill_capability
	end
	if wuqi_info.grade == 1 then
		local attr1 = FashionData.Instance:GetWuQiAttrNum(nil, true)
		local attr0 = FashionData.Instance:GetWuQiAttrNum()
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
		local attr2 = FashionData.Instance:GetWuQiAttrNum()
		local switch_attr_list = CommonDataManager.GetOrderAttributte(attr2)
		local next_attr = FashionData.Instance:GetWuQiAttrNum(nil, true)
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
				if wuqi_info.grade >= FashionData.Instance:GetMaxGrade() then
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

	local active_grade, attr_type, attr_value = FashionData.Instance:GetSpecialAttrActiveType()
	local max_grade = FashionData.Instance:GetMaxGrade()
	if active_grade and attr_type and attr_value then
		if wuqi_info.grade < active_grade then
			local str = string.format(Language.Advance.LevelOpen, CommonDataManager.GetDaXie(active_grade - 1))
			self.node_list["TxtSpecialAttr"]:SetActive(true)
			self.node_list["TxtSpecialAttr"].text.text = string.format(Language.Advance.SpecialAttr[attr_type] .. attr_value / 100 .. "%%") .. str
		else
			local str = ""
			local special_attr = nil
			for i = wuqi_info.grade + 1, max_grade do
				local next_active_grade, next_attr_type, next_attr_value = FashionData.Instance:GetSpecialAttrActiveType(i)
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
		--加载足迹item
	
	local data = {item_id = stuff_item_id}
	self.item:SetData(data)

	self.node_list["ShowZizhiRedPoint"]:SetActive(FashionData.Instance:IsShowZizhiRedPoint())
	self.node_list["ShowHuanhuaRedPoint"]:SetActive(FashionData.Instance:CanWuQiHuanhuaUpgrade())
	local can_uplevel_skill_list = FashionData.Instance:CanSkillUpLevelListOne()
	self.node_list["ShowSkillUplevel1"]:SetActive(can_uplevel_skill_list[1] ~= nil)
	self.node_list["ShowSkillUplevel2"]:SetActive(can_uplevel_skill_list[2] ~= nil)
	self.node_list["ShowSkillUplevel3"]:SetActive(can_uplevel_skill_list[3] ~= nil)
	self.node_list["ShowEquipRemind"]:SetActive(FashionData.Instance:CalAllEquipRemind() > 0)
	self:FlushNeedItemStr()
end

function AdvanceShenBingView:FlushNeedItemStr()
	local wuqi_info = FashionData.Instance:GetWuQiInfo()
	local grade_cfg = FashionData.Instance:GetWuQiGradeCfg(wuqi_info.grade)

	local bag_num = ItemData.Instance:GetItemNumInBagById(grade_cfg.upgrade_stuff_id) + ItemData.Instance:GetItemNumInBagById(grade_cfg.upgrade_stuff2_id)
	local bag_num_str = string.format(Language.Mount.ShowGreenNum, bag_num)
	if bag_num < grade_cfg.upgrade_stuff_count then
		bag_num_str = string.format(Language.Mount.ShowRedNum, bag_num)
	end

	local item_cfg = ItemData.Instance:GetItemConfig(grade_cfg.upgrade_stuff_id)

	local str = string.format("%s / %s", bag_num_str, grade_cfg.upgrade_stuff_count)
	if wuqi_info.grade < self.max_index then
		self.node_list["PropText"].text.text = str
	else
		self.node_list["PropText"].text.text = ToColorStr("- / -", TEXT_COLOR.WHITE)
	end

	if bag_num >= grade_cfg.upgrade_stuff_count and ADVANCE_CLEAR_BLESS.NOT_CLEAR == grade_cfg.is_clear_bless and (not self.is_auto) then
		self.node_list["RemindBtn"]:SetActive(true)
	else
		self.node_list["RemindBtn"]:SetActive(false)
	end
end

			 --设置
function AdvanceShenBingView:SetUseImageButtonState(cur_select_grade)
	local wuqi_info = FashionData.Instance:GetWuQiInfo()
	local max_grade = FashionData.Instance:GetMaxGrade()
	local grade_cfg = FashionData.Instance:GetWuQiGradeCfg(cur_select_grade)

	if not wuqi_info or not wuqi_info.grade or not cur_select_grade or not max_grade or not grade_cfg then
		return
	end

	-- 若使用了特殊形象，将基础形象的使用状态全部设置为可以使用
	if wuqi_info.is_used_special_img == 1 then
		self.node_list["GrayUseButton"]:SetActive(cur_select_grade <= wuqi_info.grade)
		self.node_list["UseImage1"]:SetActive(false)
	else
		self.node_list["GrayUseButton"]:SetActive(cur_select_grade <= wuqi_info.grade and grade_cfg.image_id ~= wuqi_info.use_idx)
		self.node_list["UseImage1"]:SetActive(grade_cfg.image_id == wuqi_info.use_idx and wuqi_info.is_used_special_img == 0)
	end
end

function AdvanceShenBingView:SetArrowState(cur_select_grade)
	local wuqi_info = FashionData.Instance:GetWuQiInfo()
	local max_grade = FashionData.Instance:GetMaxGrade()
	local grade_cfg = FashionData.Instance:GetWuQiGradeCfg(cur_select_grade)
	if not wuqi_info or not wuqi_info.grade or not cur_select_grade or not max_grade or not grade_cfg then
		return
	end
	self.show_right_button = cur_select_grade < wuqi_info.grade + 1 and cur_select_grade < max_grade
	self.node_list["BtnRightButton"]:SetActive(self.show_right_button )
	self.show_left_button = grade_cfg.image_id > 1 or (wuqi_info.grade  == 1 and cur_select_grade > wuqi_info.grade)
	self.node_list["BtnLeftButton"]:SetActive(self.show_left_button )
	self:SetUseImageButtonState(cur_select_grade)
end


function AdvanceShenBingView:SetModle(is_show)
	if is_show then
		if not FashionData.Instance:IsActiviteWuQi() then
			return
		end
		local wuqi_info = FashionData.Instance:GetWuQiInfo()
		local use_idx = wuqi_info.use_idx
		local wuqi_grade_cfg = FashionData.Instance:GetWuQiGradeCfg(wuqi_info.grade)
		if use_idx >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			use_idx = FashionData.Instance:GetWuQiGradeCfg(wuqi_info.grade).image_id
		end

		if wuqi_grade_cfg and use_idx  < 0 then
			local grade_cfg = FashionData.Instance:GetImageListInfo(wuqi_info.use_idx)
			local cur_select_grade = wuqi_grade_cfg.grade == 0 and wuqi_info.grade or grade_cfg.image_id
			self:SetArrowState(cur_select_grade)
			self:SwitchGradeAndName(cur_select_grade)
			self.cur_select_grade = self.cur_select_grade and cur_select_grade
		end
	else
		self.temp_grade = -1
		self.cur_select_grade = -1
		if self.node_list["ShowEffect"] then
			self.node_list["ShowEffect"]:SetActive(true)
		end
	end

end

function AdvanceShenBingView:RemoveNotifyDataChangeCallBack()
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

function AdvanceShenBingView:SetShowIndex(index)
	if index < 0 or index > self.max_index then return end
	self.show_index = index
end

--点击查看上一阶
function AdvanceShenBingView:OnClickLastButton()
	if not self.cur_select_grade or self.cur_select_grade <= 0 then
		return
	end
	self.cur_select_grade = self.cur_select_grade - 1
	self:SetArrowState(self.cur_select_grade)
	self:SwitchGradeAndName(self.cur_select_grade)
	self:SetWuQiAtrr()
end

--点击查看下一阶
function AdvanceShenBingView:OnClickNextButton()
	local wuqi_info = FashionData.Instance:GetWuQiInfo()
	if not self.cur_select_grade or self.cur_select_grade > wuqi_info.grade or wuqi_info.grade == 0 then
		return
	end
	self.cur_select_grade = self.cur_select_grade + 1
	self:SetArrowState(self.cur_select_grade)
	self:SwitchGradeAndName(self.cur_select_grade)
	self:SetWuQiAtrr()

end

function AdvanceShenBingView:OnClickTalent()
	local is_open, tips = OpenFunData.Instance:CheckIsHide("img_fuling_talent")
	if not is_open then
		TipsCtrl.Instance:ShowSystemMsg(tips)
		return
	end
	local wuqi_info = FashionData.Instance:GetWuQiInfo()
	if nil ~= wuqi_info and nil ~= wuqi_info.grade then
		if wuqi_info.grade <= TALENTLEVEL then
			TipsCtrl.Instance:ShowSystemMsg(Language.Advance.WuJieOpen)
		else
			ViewManager.Instance:Open(ViewName.ImageFuLing, TabIndex.img_fuling_talent, "talent_type_tab", {TALENT_TYPE.TALENT_SHENYI})
		end
	end
end

function AdvanceShenBingView:OnClickEquipBtn()
	local is_active, activite_grade = FashionData.Instance:IsOpenShenBingEquip()
	if not is_active then
		local name = Language.Advance.PercentAttrNameList[TabIndex.role_shenbing] or ""
		TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Advance.OnOpenEquipTip, name, CommonDataManager.GetDaXie(activite_grade), name))
		return
	end
	local wuqi_info = FashionData.Instance:GetWuQiInfo()
	if nil ~= wuqi_info and nil ~= wuqi_info.grade then
		if wuqi_info.grade <= EQUIPLEVEL then
			TipsCtrl.Instance:ShowSystemMsg(Language.Advance.SiJieOpen)
		else
			ViewManager.Instance:Open(ViewName.AdvanceEquipView, TabIndex.role_shenbing)
		end
	end
end

--点击toggle
function AdvanceShenBingView:OnAutoBuyToggleChange(isOn)

end

--物品不足，购买成功后刷新物品数量
function AdvanceShenBingView:ItemDataChangeCallback()
	self:FlushNeedItemStr()
end

function AdvanceShenBingView:SetAutoButtonGray()
	local sbing_info = FashionData.Instance:GetWuQiInfo()
	if sbing_info.grade == nil then return end

	local max_grade = FashionData.Instance:GetMaxGrade()

	if not sbing_info or not sbing_info.grade or sbing_info.grade <= 0
		or sbing_info.grade >= max_grade then
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

--点击使用资质丹
function AdvanceShenBingView:OnClickZiZhi()
	local wuqi_info = FashionData.Instance:GetWuQiInfo()
	if nil ~= wuqi_info and nil ~= wuqi_info.grade then
		if wuqi_info.grade <= ZIZHILEVEL then
			TipsCtrl.Instance:ShowSystemMsg(Language.Advance.SanJieOpen)
		else
			ViewManager.Instance:Open(ViewName.TipZiZhi, nil, "wuqizizhi", {item_id = FashionDanId.ShenBingZiZhiDanID})
		end
	end
end

--点击幻化按钮
function AdvanceShenBingView:OnClickHuanHua()
	AdvanceData.Instance:SetHuanHuaType(TabIndex.wuqi_huan_hua)
	AdvanceData.Instance:SetImageFulingType(IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_SHENYI)
	ViewManager.Instance:Open(ViewName.AdvanceHuanhua,TabIndex.mount_huanhua,"wuqihuanhuaview",{TALENT_TYPE.TALENT_SHENYI})
	AdvanceCtrl.Instance:FlushView("wuqihuanhuaview")
end

function AdvanceShenBingView:OpenCallBack()
	if self.node_list["ShowEffect"] then
		self.node_list["ShowEffect"]:SetActive(false)
	end
	self.node_list["UseImage"]:SetActive(false)
	self.node_list["BtnText"].text.text = Language.Advance.Use
end

function AdvanceShenBingView:ResetModleRotation()
	if self.wuqi_display ~= nil then
		self.wuqi_display.ui3d_display:ResetRotation()
	end
end

-- 点击武器技能
function AdvanceShenBingView:OnClickWuQiSkill(index)
	if self.is_shake_skill and index == 1 then
		self.node_list["Special"].animator:SetBool("IsShake", false)
		self.is_shake_skill = nil
	end	
	ViewManager.Instance:Open(ViewName.TipSkillUpgrade, nil, "wuqikill", {index = index - 1})
end

--武器技能
function AdvanceShenBingView:GetWuQiSkill() 
	for i = 1, 4 do
		local cur_level = 0
		local next_level = 1
		local skill = nil
		self.cur_data = FashionData.Instance:GetWuQiSkillCfgById(i - 1) or {}
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = FashionData.Instance:GetWuQiSkillCfgById(i - 1, next_level) or {}
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
		table.insert(self.shenbing_skill_list, {skill = skill, icon = icon})
	end

	for k, v in pairs(self.shenbing_skill_list) do
		local bundle, asset = ResPath.GetShenBingSkillIcon(k)
		v.icon.image:LoadSprite(bundle, asset)
		v.skill.toggle:AddValueChangedListener(BindTool.Bind(self.OnClickWuQiSkill, self, k))
	end
end

function AdvanceShenBingView:FlushSkillIcon()
	local shenbing_skill_list = FashionData.Instance:GetWuQiInfo().skill_level_list
	if nil == shenbing_skill_list then return end
	for k, v in pairs(self.shenbing_skill_list) do
		UI:SetGraphicGrey(v.icon, shenbing_skill_list[k - 1] <= 0 )
	end
	local cur_level = 0
	local next_level = 1
	local cur_data = FashionData.Instance:GetWuQiSkillCfgById(self.tesu_index - 1) or {}
	if next(cur_data) then
		cur_level = cur_data.skill_level
		next_level = cur_level + 1
	end

	local wuqi_info = FashionData.Instance:GetWuQiInfo()
	if wuqi_info ~= nil or next(wuqi_info) ~= nil then
		if wuqi_info.grade > SHOWSPECGRADE then
			self.node_list["SpecialSkill"]:SetActive(true)
			self.node_list["SpecialSkillText"]:SetActive(true)
		end
	end

	local next_data_cfg = FashionData.Instance:GetWuQiSkillCfgById(self.tesu_index - 1, next_level) or {}
	if next(next_data_cfg) then
		self.node_list["JiHuo"]:SetActive(true)
		self.node_list["JiHuo"].text.text = next_data_cfg.jineng_desc or ""
	else
		self.node_list["JiHuo"]:SetActive(false)
	end
	self.node_list["MostFightPower"]:SetActive(self.tesu_index ~= 0)
end
--计时器,用于取消默认延迟1s显示
function AdvanceShenBingView:ClickTimer(offtime)
	offtime = offtime - 1
	local temptime = TimeUtil.FormatSecond(offtime - 1)
	self.node_list["ClearTime"].text.text = string.format(Language.Advance.ClearBlessStr,tostring(temptime))
end


--四阶之后祝福值每五点清零
function AdvanceShenBingView:ShowClearOrTips()
	local wuqi_info = FashionData.Instance:GetWuQiInfo()
	if wuqi_info == nil or wuqi_info.grade == nil then
		return
	end
	local wuqi_max_cfg = FashionData.Instance:GetMaxGrade()
	local wuqi_grade_cfg = FashionData.Instance:GetWuQiGradeCfg(wuqi_info.grade)
	if wuqi_info.grade == wuqi_max_cfg then --最大等级
		self.node_list["ClearTime"]:SetActive(false)
		return
	end
	if wuqi_info.grade_bless_val == 0 then
		if nil ~= self.count then
			CountDown.Instance:RemoveCountDown(self.count)
			self.count = nil
		end
	end
	if wuqi_grade_cfg.is_clear_bless == ADVANCE_CLEAR_BLESS.NOT_CLEAR then
		self.node_list["ClearTime"].text.text = Language.Advance.ClearBlessTip
	else
		local cleartime = wuqi_info.clear_bless_value_time
		local servertime = TimeCtrl.Instance:GetServerTime()
		local offtime = cleartime - servertime
		if wuqi_info.grade_bless_val == 0 then
			self.node_list["ClearTime"].text.text = Language.Advance.ClearBlessStr1
			return
		end
		if  self.count == nil then
			self:ClickTimer(offtime)
			self.count = CountDown.Instance:AddCountDown(offtime, 1, function ()
				offtime = offtime - 1
				local temptime = TimeUtil.FormatSecond(offtime - 1)
				self.node_list["ClearTime"].text.text = string.format(Language.Advance.ClearBlessStr,tostring(temptime))
			end)
		end
	end
end

function AdvanceShenBingView:SetModelCamera()
	local role_vo = PlayerData.Instance:GetRoleVo()
	local call_back = function(model, obj)
		if obj then
			model:SetTrigger(ANIMATOR_PARAM.FIGHT)
			local prof = PlayerData.Instance:GetRoleBaseProf()
			if prof == GameEnum.ROLE_PROF_4 then
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, -45, 0)
			else
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, 0, 0)
			end
		end
	end
	UIScene:SetModelLoadCallBack(call_back)
end

--------------------------------------------------进阶奖励相关显示---------------------------------------------------
--进阶奖励相关
function AdvanceShenBingView:JinJieReward()
	local system_type = JINJIE_TYPE.JINJIE_TYPE_SHENBING
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

	-- local wuqi_info = FashionData.Instance:GetWuQiInfo()
	-- if wuqi_info == nil or wuqi_info.grade == nil then
	-- 	return
	-- end

	-- local cur_img_grade = wuqi_info.grade - 1
	-- if not self.old_img_grade then
	-- 	self.old_img_grade = cur_img_grade
	-- end

	-- local end_time = JinJieRewardData.Instance:GetSystemFreeEndTime(system_type, target_type)
	-- local now_time = TimeCtrl.Instance:GetServerTime()
	-- if end_time - now_time > 0 then

	-- 	if self.old_img_grade == 4 and cur_img_grade == 5 then
	-- 		self:OnClickOpenSmallTarget()
	-- 	elseif self.old_img_grade == 8 and cur_img_grade == 9 then
	-- 		self:OnClickJinJieAward()
	-- 	end
	-- end

	-- if self.old_img_grade == 9 and cur_img_grade == 10 then
	-- 	self.node_list["Special"].animator:SetBool("IsShake", true)
	-- 	self.is_shake_skill = true
	-- end
	-- self.old_img_grade = cur_img_grade
end

--清除大目标/小目标免费数据 target_type 目标类型  不传默认大目标
function AdvanceShenBingView:ClearJinJieFreeData(target_type)
	if target_type and target_type == JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET then --小目标
		self.node_list["TitleFreeTime"].text.text = ""
		self.node_list["TitleFreeTime"]:SetActive(false)
	else    --大目标
		self.node_list["TextFreeTime"].text.text = ""
		self.node_list["TextFreeTime"]:SetActive(false)
	end
end

--大目标 变动显示
function AdvanceShenBingView:BigTargetNotConstantData(system_type, target_type)
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
function AdvanceShenBingView:SmallTargetNotConstantData(system_type, target_type)
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
function AdvanceShenBingView:SmallTargetConstantData(system_type, target_type)
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
function AdvanceShenBingView:BigTargetConstantData(system_type, target_type)
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
function AdvanceShenBingView:FulshJinJieFreeTime(end_time, target_type)
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
function AdvanceShenBingView:SetJinJieFreeTime(time, target_type)
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
function AdvanceShenBingView:FreeTimeShow(time, target_type)
	if target_type and target_type == JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET then --小目标
		self.node_list["TitleFreeTime"].text.text = string.format(Language.Advance.LimitTime, time) 
	else    --大目标
		self.node_list["TextFreeTime"].text.text = string.format(Language.Advance.LimitTime, time) 
	end
end

--移除倒计时
function AdvanceShenBingView:RemoveCountDown()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

--打开大目标面板
function AdvanceShenBingView:OnClickJinJieAward()
	JinJieRewardCtrl.Instance:OpenJinJieAwardView(JINJIE_TYPE.JINJIE_TYPE_SHENBING)
end

--打开小目标面板
function AdvanceShenBingView:OnClickOpenSmallTarget()
	local function callback()
		local param1 = JINJIE_TYPE.JINJIE_TYPE_SHENBING
		local param2 = JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET
		local req_type = JINJIESYS_REWARD_OPEAR_TYPE.JINJIESYS_REWARD_OPEAR_TYPE_BUY

		local is_can_free = JinJieRewardData.Instance:GetSystemSmallIsCanFreeLingQuFromInfo(param1)
		if is_can_free then
			req_type = JINJIESYS_REWARD_OPEAR_TYPE.JINJIESYS_REWARD_OPEAR_TYPE_FETCH
		end
		JinJieRewardCtrl.Instance:SendJinJieRewardOpera(req_type, param1, param2)
	end

	local data = JinJieRewardData.Instance:GetSmallTargetShowData(JINJIE_TYPE.JINJIE_TYPE_SHENBING, callback)
	TipsCtrl.Instance:ShowTimeLimitTitleView(data)
end

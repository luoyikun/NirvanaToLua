-- 仙女仙阵 FaZhenContent
AdvanceShenyiView = AdvanceShenyiView or BaseClass(BaseRender)

local EFFECT_CD = 1.8
local TWEEN_TIME = 0.5
local ZIZHILEVEL = 3
local EQUIPLEVEL = 5
local SHOWSPECGRADE = 10
function AdvanceShenyiView:__init(instance)
	self.node_list["StartButton"].button:AddClickListener(BindTool.Bind(self.OnStartAdvance, self, true))
	self.node_list["AutoButton"].button:AddClickListener(BindTool.Bind(self.OnAutomaticAdvance, self))
	self.node_list["GrayUseButton"].button:AddClickListener(BindTool.Bind(self.OnClickUse, self))
	self.node_list["BtnQualifications"].button:AddClickListener(BindTool.Bind(self.OnClickZiZhi, self))
	self.node_list["BtnHuanHua"].button:AddClickListener(BindTool.Bind(self.OnClickHuanHua, self))
	self.node_list["BtnLeft"].button:AddClickListener(BindTool.Bind(self.OnClickLastButton, self))
	self.node_list["BtnRight"].button:AddClickListener(BindTool.Bind(self.OnClickNextButton, self))
	self.node_list["EquipButton"].button:AddClickListener(BindTool.Bind(self.OnClickEquipBtn, self))
	self.node_list["BtnFuLing"].button:AddClickListener(BindTool.Bind(self.OnClickFuLing, self))
	self.node_list["BtnTitle"].button:AddClickListener(BindTool.Bind(self.OnClickOpenSmallTarget, self))
	self.node_list["BtnBigTarget"].button:AddClickListener(BindTool.Bind(self.OnClickJinJieAward, self))
	self.node_list["ActPanel"].button:AddClickListener(BindTool.Bind(self.ClickActIcon, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["Capability"])

	self.show_use_button = false
	self.show_use_image = true
	self.show_left_button = true
	self.show_right_button = true

	self.show_cancel_btn = false

	self.shenyi_skill_list = {}
	self.tesu_index = 0

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["Item1"])

	self:GetShenyiSkill()

	self.is_can_auto = true
	self.is_auto = false
	self.is_can_tip = true
	self.jinjie_next_time = 0
	self.old_attrs = {}
	self.skill_fight_power = 0

	self.prefab_preload_id = 0
	self.last_level = 0
	self:SetNotifyDataChangeCallBack()
end

function AdvanceShenyiView:__delete()
	self.fight_text = nil
	self:RemoveCountDown()
	self.tesu_index = 0
	self.jinjie_next_time = nil
	self.is_can_tip = nil
	self.is_auto = nil
	self.shenyi_skill_list = nil
	self.old_attrs = {}
	self.skill_fight_power = nil
	self.last_level = nil

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	if self.item_cell then
		self.item_cell:DeleteMe()
	end
	self.item_cell = nil

	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end

	if self.count then
		CountDown.Instance:RemoveCountDown(self.count)
	end
	self.count = nil
	
	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	self:RemoveNotifyDataChangeCallBack()

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	TitleData.Instance:ReleaseTitleEff(self.node_list["BtnTitle"])
end

function AdvanceShenyiView:CloseCallBack()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

-- 进阶按钮
function AdvanceShenyiView:OnStartAdvance(is_click)
	local is_auto_buy_toggle = self.node_list["AutoToggle"].toggle.isOn
	local data = ShenyiData.Instance
	local shenyi_info = data:GetShenyiInfo()
	if nil == shenyi_info.grade then return end
	local shenyi_grade_cfg = data:GetShenyiGradeCfg(shenyi_info.grade)
	if nil == shenyi_grade_cfg then return end

	local close_func = function()
		local pack_num = shenyi_grade_cfg.upgrade_stuff_count
		local num = ItemData.Instance:GetItemNumInBagById(shenyi_grade_cfg.upgrade_stuff_id) + ItemData.Instance:GetItemNumInBagById(shenyi_grade_cfg.upgrade_stuff2_id)

		if num < pack_num and not is_auto_buy_toggle then
			-- 物品不足，弹出TIP框
			self.is_auto = false
			self.is_can_auto = true
			self:SetAutoButtonGray()
			if is_click then
				local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[shenyi_grade_cfg.upgrade_stuff_id]
				if item_cfg == nil then
					TipsCtrl.Instance:ShowItemGetWayView(shenyi_grade_cfg.upgrade_stuff_id)
					return
				end

				if item_cfg.bind_gold == 0 then
					TipsCtrl.Instance:ShowShopView(shenyi_grade_cfg.upgrade_stuff_id, 2)
					return
				end

				local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
					MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
					if is_buy_quick then
						self.node_list["AutoToggle"].toggle.isOn = true
					end
				end
				TipsCtrl.Instance:ShowCommonBuyView(func, shenyi_grade_cfg.upgrade_stuff_id, nil, 1)
			end
			return
		end

		local is_auto_buy = self.node_list["AutoToggle"].toggle.isOn and 1 or 0
		local next_time = shenyi_grade_cfg.next_time
		ShenyiCtrl.Instance:SendUpGradeReq(is_auto_buy, self.is_auto, math.floor(num / pack_num))
		self.jinjie_next_time = Status.NowTime + next_time
	end

	local describe = Language.Advance.AdvanceReturnNotLingQu
	if KaifuActivityData.Instance:IsOpenAdvanceReturnActivity() and self.is_can_tip then
		local open_advance_one = KaifuActivityData.Instance:GetOpenAdvanceType(TYPE_UPGRADE_RETURN.SHENYI_UPGRADE_RETURN)
		local open_advance_two = KaifuActivityData.Instance:GetOpenAdvanceTypeTwo(TYPE_UPGRADE_RETURN.SHENYI_UPGRADE_RETURN)
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

	local is_have_zhishengdan, item_id = ShenyiData.Instance:IsHaveZhiShengDanInGrade()
	local item = ItemData.Instance:GetItem(item_id)
	if is_have_zhishengdan and self.is_can_tip and item then
		local function ok_callback()
			PackageCtrl.Instance:SendUseItem(item.index, 1)
			self.is_can_auto = true
			self:SetAutoButtonGray()
		end	
		TipsCtrl.Instance:ShowCommonAutoView(nil, string.format(Language.Advance.IsUseZhiShengDan, shenyi_info.grade), ok_callback, close_func)
		return
	end
	close_func()
end

-- 自动进阶按钮
function AdvanceShenyiView:OnAutomaticAdvance()
	local shenyi_info = ShenyiData.Instance:GetShenyiInfo()
	if not shenyi_info or not next(shenyi_info) then return end

	local shenyi_info = ShenyiData.Instance:GetShenyiInfo()

	if shenyi_info.grade == 0 then
		return
	end

	if not self.is_can_auto then
		return
	end

	self.is_auto = self.is_auto == false
	self.is_can_tip = self.is_auto
	self.is_can_auto = false
	self:OnStartAdvance(true)
	self:SetAutoButtonGray()
end

function AdvanceShenyiView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["TopContent"], GoddessData.TweenPosition.Up , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["LeftContent"], GoddessData.TweenPosition.Left , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["RightContent"], GoddessData.TweenPosition.Right , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["Bottom"], GoddessData.TweenPosition.Down , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["ActPanel"], GoddessData.TweenPosition.Up2 , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.AlpahShowPanel(self.node_list["Panel1"], true, MOVE_TIME , DG.Tweening.Ease.InExpo)
end

function AdvanceShenyiView:AutoUpGradeOnce()
	local jinjie_next_time = 0
	if nil ~= self.upgrade_timer_quest then
		if self.jinjie_next_time >= Status.NowTime then
			jinjie_next_time = self.jinjie_next_time - Status.NowTime
		end
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
	end
	self.is_can_tip = true
	if self.cur_select_grade > 0 and self.cur_select_grade <= MountData.Instance:GetMaxGrade() then
		if self.is_auto then
			self.is_can_tip = false
			self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.OnStartAdvance, self), jinjie_next_time)
		end
	end
end

function AdvanceShenyiView:FlushView()
	self:Flush()
end

function AdvanceShenyiView:ShenyiUpGradeResult(result)
	self.is_can_auto = true
	if 0 == result then
		self.is_auto = false
		self.is_can_tip = true
		self:SetAutoButtonGray()
	else
		self:AutoUpGradeOnce()
	end
end

function AdvanceShenyiView:OnClickCancelButton()
	ShenyiCtrl.SendUnUseShenyiImage(image_id)
	local shenyi_data = ShenyiData.Instance
	self.cur_select_grade = shenyi_data:GetShenyiInfo().grade
	local grade_cfg = shenyi_data:GetShenyiGradeCfg(self.cur_select_grade)
	if not grade_cfg then return end
	ShenyiCtrl.Instance:SendUseShenyiImage(grade_cfg.image_id)
end

function AdvanceShenyiView:CancelTheQuest()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	if self.time_quest_2 then
		GlobalTimerQuest:CancelQuest(self.time_quest_2)
		self.time_quest_2 = nil
	end
	if self.upgrade_timer_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
	self.is_auto = false
	self.node_list["AutoUpBtnText"].text.text = Language.Common.ZiDongJinJie
end

function AdvanceShenyiView:OnClickFuLing()
	local is_open_img_fuling, tips = OpenFunData.Instance:CheckIsHide("img_fuling")
	if not is_open_img_fuling then
		TipsCtrl.Instance:ShowSystemMsg(tips)
		return
	end
	ViewManager.Instance:Open(ViewName.ImageFuLing, TabIndex.img_fuling_content, "fuling_type_tab", {IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_SHENYI})
end

-- 使用当前法阵法阵
function AdvanceShenyiView:OnClickUse()
	if self.cur_select_grade == nil then
		return
	end
	local grade_cfg = ShenyiData.Instance:GetShenyiGradeCfg(self.cur_select_grade)
	if not grade_cfg then return end
	ShenyiCtrl.Instance:SendUseShenyiImage(grade_cfg.image_id)
end

--显示上一阶法阵
function AdvanceShenyiView:OnClickLastButton()
	if not self.cur_select_grade or self.cur_select_grade <= 0 then
		return
	end
	self.cur_select_grade = self.cur_select_grade - 1
	self:SetArrowState(self.cur_select_grade)
	self:SwitchGradeAndName(self.cur_select_grade)

	-- if self.node_list["ShenyiDisplay"] ~= nil then
		-- self.node_list["ShenyiDisplay"].ui3d_display:ResetRotation()
	-- end
end

--显示下一阶
function AdvanceShenyiView:OnClickNextButton()
	local shenyi_info = ShenyiData.Instance:GetShenyiInfo()
	if not self.cur_select_grade or self.cur_select_grade > shenyi_info.grade or shenyi_info.grade == 0 then
		return
	end
	self.cur_select_grade = self.cur_select_grade + 1
	self:SetArrowState(self.cur_select_grade)
	self:SwitchGradeAndName(self.cur_select_grade)

	-- if self.node_list["ShenyiDisplay"] ~= nil then
		-- self.node_list["ShenyiDisplay"].ui3d_display:ResetRotation()
	-- end
end

function AdvanceShenyiView:SwitchGradeAndName(index, no_flush_modle)
	if index == nil then return end
	local shenyi_grade_cfg = ShenyiData.Instance:GetShenyiGradeCfg(index)
	local image_cfg = ShenyiData.Instance:GetShenyiImageCfg()
	if shenyi_grade_cfg == nil then return end

	if image_cfg[shenyi_grade_cfg.image_id] then
		local color = (index / 3 + 1) >= 5 and 5 or math.floor(index / 3 + 1)
		local name_str = "<color="..SOUL_NAME_COLOR[color] .. ">" .. image_cfg[shenyi_grade_cfg.image_id].image_name .. "</color>"
		self.node_list["Name"].text.text = shenyi_grade_cfg.gradename .. "·" .. name_str
		local info = {}
		info.role_res_id = GoddessData.Instance:GetShowXiannvResId() or -1
		info.fazhen_res_id = -1
		if self.cur_select_grade == nil then
			self.cur_select_grade = ShenyiData.Instance:GetShenyiInfo().grade
		end
		info.fazhen_res_id = ShenyiData.Instance:GetShowShenyiRes(self.cur_select_grade)

		if not no_flush_modle then
			self:SetModle(true)
		end
	end

end

function AdvanceShenyiView:Set3DModel(info)
	

	local bundle1, asset1 = ResPath.GetGoddessModel(info.role_res_id)
	local bundle2, asset2 = ResPath.GetGoddessFaZhenModel(info.fazhen_res_id)

	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	local load_list = {{bundle1, asset1}, {bundle2, asset2}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
			-- local bundle_list = {[SceneObjPart.Main] = bundle1, [SceneObjPart.FaZhen] = bundle2}
			-- local asset_list = {[SceneObjPart.Main] = asset1, [SceneObjPart.FaZhen] = asset2}
			-- UIScene:ModelBundle(bundle_list, asset_list)
			UIScene:SetGoddessModelResInfo(info, true)
		end)

	self:CalToShowAnim(true)
end

function AdvanceShenyiView:CalToShowAnim(is_change_tab)
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	local timer = GameEnum.GODDESS_ANIM_LONG_TIME
	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer = timer - UnityEngine.Time.deltaTime
		if timer <= 0 or is_change_tab == true then
			if is_change_tab then
				if timer <= 6 then
					self:PlayAnim(is_change_tab)
					is_change_tab = false
					timer = GameEnum.GODDESS_ANIM_LONG_TIME
					GlobalTimerQuest:CancelQuest(self.time_quest)
				end
			else
				self:PlayAnim(is_change_tab)
				is_change_tab = false
				timer = GameEnum.GODDESS_ANIM_LONG_TIME
				GlobalTimerQuest:CancelQuest(self.time_quest)
			end
		end
	end, 0)

end

function AdvanceShenyiView:PlayAnim(is_change_tab)
	local is_change_tab = is_change_tab
	if self.time_quest_2 then
		GlobalTimerQuest:CancelQuest(self.time_quest_2)
		self.time_quest_2 = nil
	end
end

-- 资质
function AdvanceShenyiView:OnClickZiZhi()
	local shenyi_info = ShenyiData.Instance:GetShenyiInfo()
	if nil ~= shenyi_info and nil ~= shenyi_info.grade then
		if shenyi_info.grade <= ZIZHILEVEL then
			TipsCtrl.Instance:ShowSystemMsg(Language.Advance.SanJieOpen)
		else
			ViewManager.Instance:Open(ViewName.TipZiZhi, nil, "shenyizizhi", {item_id = ShenyiDanId.ZiZhiDanId})
		end
	end
end

-- 点击进阶装备
function AdvanceShenyiView:OnClickEquipBtn()
	local is_active, activite_grade = ShenyiData.Instance:IsOpenEquip()
	if not is_active then
		local name = Language.Advance.PercentAttrNameList[TabIndex.goddess_shenyi] or ""
		TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Advance.OnOpenEquipTip, name, CommonDataManager.GetDaXie(activite_grade), name))
		return
	end
	local shenyi_info = ShenyiData.Instance:GetShenyiInfo()
	if nil ~= shenyi_info and nil ~= shenyi_info.grade then
		if shenyi_info.grade <= EQUIPLEVEL then
			TipsCtrl.Instance:ShowSystemMsg(Language.Advance.SiJieOpen)
		else
			ViewManager.Instance:Open(ViewName.AdvanceEquipView, TabIndex.goddess_shenyi)
		end
	end
end

-- 幻化
function AdvanceShenyiView:OnClickHuanHua()
	ViewManager.Instance:Open(ViewName.ShenyiHuanHua)
	ShenyiHuanHuaCtrl.Instance:FlushView("shenyihuanhua")
end

-- 点击法阵技能
function AdvanceShenyiView:OnClickShenyiSkill(index)
	if self.is_shake_skill and index == 1 then
		self.node_list["Special"].animator:SetBool("IsShake", false)
		self.is_shake_skill = nil
	end
	ViewManager.Instance:Open(ViewName.TipSkillUpgrade, nil, "shenyiskill", {index = index - 1})
end

function AdvanceShenyiView:GetShenyiSkill()
	for i = 1,4 do
		local cur_level = 0
		local next_level = 1
		local skill = nil
		self.cur_data = ShenyiData.Instance:GetShenyiSkillCfgById(i - 1) or {}
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = ShenyiData.Instance:GetShenyiSkillCfgById(i - 1, next_level) or {}
		local is_teshu = false
		skill = self.node_list["ShenyiSkill"..i]
		if self.cur_data and next(self.cur_data) and self.cur_data.is_teshu then
			is_teshu = self.cur_data.is_teshu == 1
		else
			if self.next_data_cfg and next(self.next_data_cfg) and self.next_data_cfg.is_teshu then
				is_teshu = self.next_data_cfg.is_teshu == 1
			end
		end
		if is_teshu then
			skill = self.node_list["SpecialSkill"]
			self.node_list["ShenyiSkill" ..i ]:SetActive(false)
			self.node_list["SpecialSkill"]:SetActive(true)
			self.node_list["SpecialSkillText"]:SetActive(true)
			self.tesu_index = i
		end
		self.node_list["SpecialSkill"]:SetActive(false)
		self.node_list["SpecialSkillText"]:SetActive(false)

		local bundle,asset = ResPath.GetFaZhenSkillIcon(i)
		local icon = skill.transform:FindHard("Image")
		icon = U3DObject(icon, icon.transform, self)
		icon.image:LoadSprite(bundle, asset)
		table.insert(self.shenyi_skill_list, {skill = skill, icon = icon})
	end
	for k, v in pairs(self.shenyi_skill_list) do
		v.skill.toggle:AddValueChangedListener(BindTool.Bind(self.OnClickShenyiSkill, self, k))
	end
end

function AdvanceShenyiView:FlushSkillIcon()
	local shenyi_skill_list = ShenyiData.Instance:GetShenyiInfo().skill_level_list
	if nil == shenyi_skill_list then return end

	for k, v in pairs(self.shenyi_skill_list) do
		local node = v.skill.transform:FindHard("Image")
		if node then
			UI:SetGraphicGrey(node, shenyi_skill_list[k - 1] == 0)
		end
	end

	local cur_level = 0
	local next_level = 1
	local cur_data = ShenyiData.Instance:GetShenyiSkillCfgById(self.tesu_index - 1) or {}
	if next(cur_data) then
		cur_level = cur_data.skill_level
		next_level = cur_level + 1
	end
	local next_data_cfg = ShenyiData.Instance:GetShenyiSkillCfgById(self.tesu_index - 1, next_level) or {}
	if next(next_data_cfg) then
		self.node_list["JiHuo"]:SetActive(true)
		self.node_list["JiHuo"].text.text = next_data_cfg.jineng_desc or ""
	else
		self.node_list["JiHuo"]:SetActive(false)
	end
	self.node_list["MostFightPower"]:SetActive(self.tesu_index ~= 0)

	local info = ShenyiData.Instance:GetShenyiInfo()
	if info ~= nil or next(info) ~= nil then
		if info.grade > SHOWSPECGRADE then
			self.node_list["SpecialSkill"]:SetActive(true)
			self.node_list["SpecialSkillText"]:SetActive(true)
		end
	end
end

-- 设置提升物品格子数据
function AdvanceShenyiView:SetPropItemCellsData()
	local data = ShenyiData.Instance
	local info = data:GetShenyiInfo()
	if nil == info.grade then return end
	local shenyi_grade_cfg = data:GetShenyiGradeCfg(info.grade)
	if nil == shenyi_grade_cfg then return end

	self.item_cell:SetData({item_id = shenyi_grade_cfg.upgrade_stuff_id, num = 0})

	local count = ItemData.Instance:GetItemNumInBagById(shenyi_grade_cfg.upgrade_stuff_id) + ItemData.Instance:GetItemNumInBagById(shenyi_grade_cfg.upgrade_stuff2_id)
	if count < shenyi_grade_cfg.upgrade_stuff_count  then
		count = string.format(Language.Mount.ShowRedNum, count)
	else
		count = string.format(Language.Common.ShowGreenStr, count)
	end

	local is_show_remind =  AdvanceData.Instance:GetShenyiCanJinjie()
	self.node_list["RemindBtn"]:SetActive(is_show_remind and (not self.is_auto))

	self.node_list["PropText"].text.text = count .. " / " .. shenyi_grade_cfg.upgrade_stuff_count
end

-- 设置女神法阵属性
function AdvanceShenyiView:SetShenyiAtrr()
	local shenyi_info = ShenyiData.Instance:GetShenyiInfo()
	local image_cfg = ShenyiData.Instance:GetShenyiImageCfg()
	if shenyi_info == nil or shenyi_info.shenyi_level == nil then
		return
	end

	if shenyi_info.shenyi_level == 0 or shenyi_info.grade == 0 then
		local shenyi_grade_cfg = ShenyiData.Instance:GetShenyiGradeCfg(1)
		return
	end
	self.node_list["TextZiZhi"].text.text = shenyi_info.grade > ZIZHILEVEL and Language.Advance.ZiZhi or Language.Advance.SanJieOpen
	self.node_list["TextEquip"].text.text = shenyi_info.grade > EQUIPLEVEL and Language.Advance.XianNvFaZhenEquip or Language.Advance.SiJieOpen 

	UI:SetGraphicGrey(self.node_list["BtnQualifications"], shenyi_info.grade <= ZIZHILEVEL)
	UI:SetGraphicGrey(self.node_list["EquipButton"], shenyi_info.grade <= EQUIPLEVEL)

	local shenyi_grade_cfg = ShenyiData.Instance:GetShenyiGradeCfg(shenyi_info.grade)

	if not shenyi_grade_cfg then return end

	if not self.temp_grade then
		if shenyi_grade_cfg.show_grade == 0 then
			self.cur_select_grade = shenyi_info.grade
		else
			self.cur_select_grade = shenyi_info.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID and shenyi_info.grade
									or ShenyiData.Instance:GetShenyiGradeByUseImageId(shenyi_info.used_imageid)
		end
		self:SetAutoButtonGray()
		self:SetArrowState(self.cur_select_grade, true)
		self:SwitchGradeAndName(self.cur_select_grade, true)
		self.temp_grade = shenyi_info.grade
	else
		if self.temp_grade < shenyi_info.grade then
			local new_attr = ShenyiData.Instance:GetShenyiAttrSum(nil, true)
			local old_capability = CommonDataManager.GetCapability(self.old_attrs) + self.skill_fight_power
			local new_capability = CommonDataManager.GetCapability(new_attr) + self.skill_fight_power
			TipsCtrl.Instance:ShowAdvanceSucceView(image_cfg[shenyi_grade_cfg.image_id], new_attr, self.old_attrs, "shenyi_view", new_capability, old_capability)

						-- 升级成功音效
			AudioService.Instance:PlayAdvancedAudio()
			-- 升级特效
			if not self.effect_cd or self.effect_cd <= Status.NowTime then
				self.effect_cd = EFFECT_CD + Status.NowTime
				local bundle_name, asset_name = ResPath.GetUiXEffect("UI_jinjiechenggeng")
				TipsCtrl.Instance:OpenEffectView(bundle_name, asset_name, EFFECT_CD)
			end

			if shenyi_grade_cfg.show_grade == 0 then
				self.cur_select_grade = shenyi_info.grade
			else
				self.cur_select_grade = shenyi_info.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID and shenyi_info.grade
										or ShenyiData.Instance:GetShenyiGradeByUseImageId(shenyi_info.used_imageid)
			end
			self.is_auto = false
			self.is_can_tip = true
			self:SetAutoButtonGray()
			self:SetArrowState(self.cur_select_grade)
			self:SwitchGradeAndName(shenyi_info.grade)
		end
		self.temp_grade = shenyi_info.grade
	end
	self:SetUseImageButtonState(self.cur_select_grade, true)

	if shenyi_info.grade >= ShenyiData.Instance:GetMaxGrade() then
		self.node_list["CurBless"].text.text = Language.Common.YiMan
		self.node_list["ProgBg"].slider.value = 1
		self.node_list["TxtValue"]:SetActive(false)
		self:FlushClearTime()
		self:SetAutoButtonGray()
	else
		self.node_list["CurBless"].text.text = shenyi_info.grade_bless_val .. " / " .. shenyi_grade_cfg.bless_val_limit
		self.node_list["ProgBg"].slider.value = shenyi_info.grade_bless_val / shenyi_grade_cfg.bless_val_limit
	end

	local skill_capability = 0
	for i = 0, 3 do
		local attr = ShenyiData.Instance:GetShenyiSkillCfgById(i)
		if attr then
			skill_capability = skill_capability + attr.capability + CommonDataManager.GetCapabilityCalculation(attr)
		end
	end
	self.skill_fight_power = skill_capability

	if shenyi_info.grade == 1 then
		local attr1 = ShenyiData.Instance:GetShenyiGradeCfg(shenyi_info.grade + 1)
		local attr0 = ShenyiData.Instance:GetShenyiGradeCfg(shenyi_info.grade)
		local switch_attr_list_1 = CommonDataManager.GetOrderAttributte(attr1)
		local switch_attr_list_0 = CommonDataManager.GetOrderAttributte(attr0)
		local cur_attr = CommonDataManager.GetAttributteByClass(attr0)
		local next_attr = CommonDataManager.GetAttributteByClass(attr1)
		local diff_attr = CommonDataManager.LerpAttributeAttr(cur_attr, next_attr)
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
		local attr2 = ShenyiData.Instance:GetShenyiGradeCfg(shenyi_info.grade)
		local switch_attr_list = CommonDataManager.GetOrderAttributte(attr2)
		local next_attr = ShenyiData.Instance:GetShenyiGradeCfg(shenyi_info.grade + 1)
		local switch_next_attr_list = CommonDataManager.GetOrderAttributte(next_attr)
		local cur_attr = CommonDataManager.GetAttributteByClass(attr2)
		local next_attr1 = CommonDataManager.GetAttributteByClass(next_attr)
		local diff_attr = CommonDataManager.LerpAttributeAttr(cur_attr, next_attr1)
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
				if shenyi_info.grade >= ShenyiData.Instance:GetMaxGrade() then
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

	local max_grade = ShenyiData.Instance:GetMaxGrade()
	local active_grade, attr_type, attr_value = ShenyiData.Instance:GetSpecialAttrActiveType()
	if active_grade and attr_type and attr_value then
		if shenyi_info.grade < active_grade then
			local str = string.format(Language.Advance.LevelOpen, CommonDataManager.GetDaXie(active_grade - 1))
			self.node_list["TxtSpecialAttr"]:SetActive(true)
			self.node_list["TxtSpecialAttr"].text.text = string.format(Language.Advance.SpecialAttr[attr_type] .. attr_value / 100 .. "%%") .. str
		else
			local str = ""
			local special_attr = nil
			for i = shenyi_info.grade + 1, max_grade do
				local next_active_grade, next_attr_type, next_attr_value = ShenyiData.Instance:GetSpecialAttrActiveType(i)
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
	local attr = ShenyiData.Instance:GetShenyiGradeCfg(shenyi_info.grade)
	local capability = CommonDataManager.GetCapability(attr)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = capability + skill_capability
	end
	if self.index then
		local grade = ShenyiData.Instance:GetShenyiGradeCfg(self.index).gradename
		self.node_list["Name"].text.text = grade .. "·" .. image_cfg[self.index].image_name
	end

	self.node_list["RedPointZiZhi"]:SetActive(ShenyiData.Instance:IsShowZizhiRedPoint())
	self.node_list["RedPointHuanHua"]:SetActive(not(ShenyiData.Instance:CanHuanhuaUpgrade() == 0))

	local can_uplevel_skill_list = ShenyiData.Instance:CanSkillUpLevelList()
	self.node_list["SkillUpLevel2"]:SetActive(can_uplevel_skill_list[1] ~= nil)
	self.node_list["SkillUpLevel3"]:SetActive(can_uplevel_skill_list[2] ~= nil)
	self.node_list["SkillUpLevel4"]:SetActive(can_uplevel_skill_list[3] ~= nil)
	self.node_list["RedPointEquip"]:SetActive(ShenyiData.Instance:CalAllEquipRemind() > 0)
end

function AdvanceShenyiView:SetArrowState(cur_select_grade, no_flush_modle)
	local cur_select_grade = cur_select_grade or self.cur_select_grade
	local shenyi_info = ShenyiData.Instance:GetShenyiInfo()
	local max_grade = ShenyiData.Instance:GetMaxGrade()
	local grade_cfg = ShenyiData.Instance:GetShenyiGradeCfg(cur_select_grade)
	if not shenyi_info or not shenyi_info.grade or not cur_select_grade or not max_grade or not grade_cfg then
		return
	end
	self.show_right_button = cur_select_grade < shenyi_info.grade + 1 and cur_select_grade < max_grade
	self.node_list["BtnRight"]:SetActive(self.show_right_button)
	self.show_left_button = grade_cfg.image_id > 1 or (shenyi_info.grade  == 1 and cur_select_grade > shenyi_info.grade)
	self.node_list["BtnLeft"]:SetActive(self.show_left_button)
	self:SetUseImageButtonState(cur_select_grade, no_flush_modle)
end

function AdvanceShenyiView:SetUseImageButtonState(cur_select_grade, no_flush_modle)
	local shenyi_info = ShenyiData.Instance:GetShenyiInfo()
	local max_grade = ShenyiData.Instance:GetMaxGrade()
	local grade_cfg = ShenyiData.Instance:GetShenyiGradeCfg(cur_select_grade)

	if not shenyi_info or not shenyi_info.grade or not cur_select_grade or not max_grade or not grade_cfg then
		return
	end
	local is_show_cancel_btn = ShenyiData.Instance:IsShowCancelHuanhuaBtn(cur_select_grade)
	self.show_use_button = cur_select_grade <= shenyi_info.grade and grade_cfg.image_id ~= shenyi_info.used_imageid
	self.node_list["GrayUseButton"]:SetActive(self.show_use_button)
	self.show_use_image = grade_cfg.image_id == shenyi_info.used_imageid
	self.node_list["ImgAdvance"]:SetActive(self.show_use_image)
	self.show_cancel_btn = is_show_cancel_btn
	self:SwitchGradeAndName(self.cur_select_grade, no_flush_modle)
end

-- 物品不足，购买成功后刷新物品数量
function AdvanceShenyiView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	local shenyi_info = ShenyiData.Instance:GetShenyiInfo()
	if shenyi_info.grade == nil then
		return
	end
	self:SetPropItemCellsData()
end

-- 设置进阶按钮状态
function AdvanceShenyiView:SetAutoButtonGray()
	local shenyi_info = ShenyiData.Instance:GetShenyiInfo()
	if shenyi_info.grade == nil then return end

	local max_grade = ShenyiData.Instance:GetMaxGrade()

	if not shenyi_info or not shenyi_info.grade or shenyi_info.grade <= 0
		or shenyi_info.grade >= max_grade then

		self.node_list["AutoUpBtnText"].text.text = Language.Advance.MaxGradeText
		self.node_list["StartButton"]:SetActive(false)
		UI:SetButtonEnabled(self.node_list["AutoButton"], false)
		self.node_list["PropText"].text.text = ToColorStr("- / -", TEXT_COLOR.WHITE)
		return
	end

	if self.is_auto then
		self.node_list["AutoUpBtnText"].text.text = Language.Common.Stop
		UI:SetButtonEnabled(self.node_list["StartButton"], false)
		UI:SetButtonEnabled(self.node_list["AutoButton"], true)
	else
		self.node_list["AutoUpBtnText"].text.text = Language.Common.ZiDongJinJie
		UI:SetButtonEnabled(self.node_list["StartButton"], true)
		UI:SetButtonEnabled(self.node_list["AutoButton"], true)
	end
end

function AdvanceShenyiView:SetModle(is_show, grade, flush_flag)
	if is_show then
		if not ShenyiData.Instance:IsActiviteShenyi() then
			return
		end
		local goddess_data = GoddessData.Instance
		local info = {}
		info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
		info.fazhen_res_id = -1
		if grade then
			self.cur_select_grade = grade
		else
			if self.cur_select_grade == nil or self.is_in_preview == true or flush_flag then
				self.is_in_preview = false
				self.cur_select_grade = ShenyiData.Instance:GetShenyiInfo().grade
			end
		end

		local grade_cfg = ShenyiData.Instance:GetShenyiGradeCfg(self.cur_select_grade).image_id
		if grade_cfg then
			info.fazhen_res_id = ShenyiData.Instance:GetShowShenyiRes(self.cur_select_grade)
			self:Set3DModel(info)
		end
	end
end

function AdvanceShenyiView:SetNotifyDataChangeCallBack()
	-- 监听系统事件
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function AdvanceShenyiView:RemoveNotifyDataChangeCallBack()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	self.temp_grade = nil
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
end

function AdvanceShenyiView:OpenCallBack()
	self:DoPanelTweenPlay()
	self:Flush()
end

----祝福值提示 清空祝福值 清空时间
function AdvanceShenyiView:FlushClearTime()
	local shenyi_info = ShenyiData.Instance:GetShenyiInfo()
	local shenyi_max_grade = ShenyiData.Instance:GetMaxGrade()
	local shenyi_grade_cfg = ShenyiData.Instance:GetShenyiGradeCfg(shenyi_info.grade)

	if shenyi_info.grade == shenyi_max_grade then --最大等级
		self.node_list["ClearTime"]:SetActive(false)
		return
	end

	-- 当祝福值为0要清空计时器
	if shenyi_info.grade_bless_val == 0 then
		if nil ~= self.count then
			CountDown.Instance:RemoveCountDown(self.count)
			self.count = nil
		end
	end

	if  ADVANCE_CLEAR_BLESS.NOT_CLEAR == shenyi_grade_cfg.is_clear_bless then --不清空祝福值显示提示信息
		self.node_list["ClearTime"].text.text = Language.Advance.ClearBlessTip
		return
	end

	if ADVANCE_CLEAR_BLESS.CLEAR == shenyi_grade_cfg.is_clear_bless then  --清空祝福值
		if shenyi_info.grade_bless_val == 0 then
			self.node_list["ClearTime"].text.text = Language.Advance.ClearBlessStr1
			return
		end
		local cleartime = shenyi_info.clear_upgrade_time
		local servertime = TimeCtrl.Instance:GetServerTime()
		local offtime = cleartime - servertime
		if self.count == nil and cleartime > 0 then
			self:ClickTimer(offtime)
			self.count = CountDown.Instance:AddCountDown(offtime, 1, function ()
				offtime = offtime - 1
				if offtime <= 0 then
					CountDown.Instance:RemoveCountDown(self.count)
					self.count = nil
				end
				local temptime = TimeUtil.FormatSecond(offtime - 1)
				self.node_list["ClearTime"].text.text = string.format(Language.Advance.ClearBlessStr,tostring(temptime))
				end)
		end
	end
end
--计时器,用于取消默认延迟1s显示
function AdvanceShenyiView:ClickTimer(offtime)
	offtime = offtime - 1
	local temptime = TimeUtil.FormatSecond(offtime - 1)
	self.node_list["ClearTime"].text.text = string.format(Language.Advance.ClearBlessStr,tostring(temptime))
end

function AdvanceShenyiView:OnFlush()
	if not ShenyiData.Instance:IsActiviteShenyi() then
		return
	end

	self:JinJieReward()
	self:SetPropItemCellsData()
	self:SetShenyiAtrr()
	self:FlushSkillIcon()
	self:FlushClearTime()
end

--------------------------------------------------进阶奖励相关显示---------------------------------------------------
--进阶奖励相关
function AdvanceShenyiView:JinJieReward()
	local system_type = JINJIE_TYPE.JINJIE_TYPE_SHENYI
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
		local shenyi_info = ShenyiData.Instance:GetShenyiInfo()
		if shenyi_info == nil or shenyi_info.grade == nil then
			return
		end
		
		local cur_img_grade = shenyi_info.grade - 1
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
				local function ok_callback()
					PackageCtrl.Instance:SendUseItem(item.index, 1)
				end	
				TipsCtrl.Instance:ShowCommonAutoView(nil, Language.Advance.IsUseItem, ok_callback)
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
				local function ok_callback()
					PackageCtrl.Instance:SendUseItem(item.index, 1)
				end	
				TipsCtrl.Instance:ShowCommonAutoView(nil, Language.Advance.IsUseItem2, ok_callback)
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

function AdvanceShenyiView:ClickActIcon()
	if not self.act_click_type then
		local system_type = JINJIE_TYPE.JINJIE_TYPE_SHENYI
		local shenyi_info = ShenyiData.Instance:GetShenyiInfo()
		if shenyi_info == nil or shenyi_info.grade == nil then
			return
		end
		local cur_img_grade = shenyi_info.grade - 1
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

function AdvanceShenyiView:SetActTime()
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
function AdvanceShenyiView:ClearJinJieFreeData(target_type)
	if target_type and target_type == JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET then --小目标
		self.node_list["TitleFreeTime"].text.text = ""
		self.node_list["TitleFreeTime"]:SetActive(false)
	else    --大目标
		self.node_list["TextFreeTime"].text.text = ""
		self.node_list["TextFreeTime"]:SetActive(false)
	end
end

--大目标 变动显示
function AdvanceShenyiView:BigTargetNotConstantData(system_type, target_type)
	local is_show_jin_jie = JinJieRewardData.Instance:IsShowJinJieRewardIcon(system_type)
	local speical_is_active = JinJieRewardData.Instance:GetSystemIsActiveSpecialImage(system_type)
	local active_is_end = JinJieRewardData.Instance:GetSystemFreeIsEnd(system_type)
	local active_big_target = JinJieRewardData.Instance:GetSystemIsGetActiveNeedItemFromInfo(system_type)
	local can_fetch = JinJieRewardData.Instance:GetSystemIsCanFreeLingQuFromInfo(system_type)
	self.node_list["JinJieBig"]:SetActive(is_show_jin_jie)
	self.node_list["RedPoint"]:SetActive(not speical_is_active)
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
function AdvanceShenyiView:SmallTargetNotConstantData(system_type, target_type)
	local is_free_end = JinJieRewardData.Instance:GetSystemSmallTargetFreeIsEnd(system_type)
	local is_can_free = JinJieRewardData.Instance:GetSystemSmallIsCanFreeLingQuFromInfo(system_type)
	UI:SetGraphicGrey(self.node_list["BtnTitle"], not is_can_free)
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
function AdvanceShenyiView:SmallTargetConstantData(system_type, target_type)
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
function AdvanceShenyiView:BigTargetConstantData(system_type, target_type)
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

	local bundle, asset = ResPath.GetGoddesTargetTypeImage(system_type)
	self.node_list["TypeImage"].image:LoadSprite(bundle, asset)

	local per = JinJieRewardData.Instance:GetSingleAttrCfgAttrAddPer(system_type)
	local per_text = per * 0.01
	self.node_list["TextAdd"].text.text = string.format(Language.Advance.AddShuXing, per_text)
end

--刷新免费时间
function AdvanceShenyiView:FulshJinJieFreeTime(end_time, target_type)
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
function AdvanceShenyiView:SetJinJieFreeTime(time, target_type)
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
function AdvanceShenyiView:FreeTimeShow(time, target_type)
	if target_type and target_type == JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET then --小目标
		self.node_list["TitleFreeTime"].text.text = string.format(Language.Advance.LimitTime, time) 
	else    --大目标
		self.node_list["TextFreeTime"].text.text = string.format(Language.Advance.LimitTime, time) 
	end
end

--移除倒计时
function AdvanceShenyiView:RemoveCountDown()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

--打开大目标面板
function AdvanceShenyiView:OnClickJinJieAward()
	JinJieRewardCtrl.Instance:OpenJinJieAwardView(JINJIE_TYPE.JINJIE_TYPE_SHENYI)
end

--打开小目标面板
function AdvanceShenyiView:OnClickOpenSmallTarget()
	local function callback()
		local param1 = JINJIE_TYPE.JINJIE_TYPE_SHENYI
		local param2 = JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET
		local req_type = JINJIESYS_REWARD_OPEAR_TYPE.JINJIESYS_REWARD_OPEAR_TYPE_BUY

		local is_can_free = JinJieRewardData.Instance:GetSystemSmallIsCanFreeLingQuFromInfo(param1)
		if is_can_free then
			req_type = JINJIESYS_REWARD_OPEAR_TYPE.JINJIESYS_REWARD_OPEAR_TYPE_FETCH
		end
		JinJieRewardCtrl.Instance:SendJinJieRewardOpera(req_type, param1, param2)
	end

	local data = JinJieRewardData.Instance:GetSmallTargetShowData(JINJIE_TYPE.JINJIE_TYPE_SHENYI, callback)
	TipsCtrl.Instance:ShowTimeLimitTitleView(data)
end

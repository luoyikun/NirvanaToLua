AdvanceCloakView = AdvanceCloakView or BaseClass(BaseRender)

local EFFECT_CD = 1.8
local MOVE_TIME = 0.5

function AdvanceCloakView:UIsMove()
	UITween.MoveShowPanel(self.node_list["InfoPanel"], Vector3(250, -17, 0 ) , MOVE_TIME)
	UITween.MoveShowPanel(self.node_list["SkillPanel"], Vector3(0 , -560 , 0 ) , MOVE_TIME)
	UITween.MoveShowPanel(self.node_list["Panel1"], Vector3(165, 600, 0 ), MOVE_TIME)
	UITween.MoveShowPanel(self.node_list["Panel4"], Vector3(-35, 480, 0 ), MOVE_TIME)
	UITween.MoveShowPanel(self.node_list["TitlePanel"], Vector3(0, 400, 0 ), MOVE_TIME)
	UITween.MoveShowPanel(self.node_list["BtnPanel"], Vector3(0, -360, 0 ), MOVE_TIME)
	UITween.AlpahShowPanel(self.node_list["Panel3"], true, MOVE_TIME, DG.Tweening.Ease.InExpo)
	UITween.AlpahShowPanel(self.node_list["NodeNextStr"], true, MOVE_TIME, DG.Tweening.Ease.InExpo)
	UITween.AlpahShowPanel(self.node_list["Panel2"], true, MOVE_TIME, DG.Tweening.Ease.InExpo)
end

function AdvanceCloakView:__init(instance)
	if instance == nil then
		return
	end
	self.node_list["StartButton"].button:AddClickListener(BindTool.Bind(self.OnStartAdvance, self))
	self.node_list["AutoButton"].button:AddClickListener(BindTool.Bind(self.OnAutomaticAdvance, self))
	self.node_list["GrayUseButton"].button:AddClickListener(BindTool.Bind(self.OnClickUse, self))
	self.node_list["BtnQualifications"].button:AddClickListener(BindTool.Bind(self.OnClickZiZhi, self))
	self.node_list["BtnHuanHua"].button:AddClickListener(BindTool.Bind(self.OnClickHuanHua, self))
	self.node_list["BtnLeftButton"].button:AddClickListener(BindTool.Bind(self.OnClickLastButton, self))
	self.node_list["BtnRightButton"].button:AddClickListener(BindTool.Bind(self.OnClickNextButton, self))
	self.node_list["BtnEquipButton"].button:AddClickListener(BindTool.Bind(self.OnClickEquipBtn, self))
	self.node_list["BtnChengZhang"].button:AddClickListener(BindTool.Bind(self.OnClickChengZhang, self))
	self.node_list["SelectToggle"].toggle:AddValueChangedListener(BindTool.Bind(self.ToggleOnClick, self))

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFightPowerNum"])

	self.node_list["BtnQualifications"]:SetActive(false)	-- 策划说灵刃和披风屏蔽掉这两个按钮和技能
	self.node_list["BtnChengZhang"]:SetActive(false)
	self.node_list["SkillPanel"]:SetActive(false)

	self.show_use_button = false
	self.show_use_image = true
	self.show_left_button = true
	self.show_right_button = true

	self.show_next_attr = true
	self.is_show_next_str = true
	self.show_left_txt = true
	self.stars_list = {}
	self.tesu_index = 0
	for i = 1, 10 do
		self.stars_list[i] = self.node_list["Stars"].transform:FindHard("Star"..i)
	end

	self.item_index = 1
	self.toggle_group = self.node_list["items"].toggle_group
	self.item_cell_list = {}
	for i = 1, 3 do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self.node_list["item"..i])
		-- self.item_cell_list[i]:SetToggleGroup(self.toggle_group)
		local handler = function()
			if self.item_index == i then
				self.item_cell_list[i]:OnClickItemCell()
			end
			self.item_index = i
			for i = 1, 3 do
				self.item_cell_list[i]:SetToggle(self.item_index == i)
			end
		end
		-- self.item_cell_list[i]:ListenClick(handler)
	end

	self.cloak_skill_list = {}

	self:GetCloakSkill()

	self.is_auto = false
	self.is_can_auto = true
	self.jinjie_next_time = 0
	self.old_attrs = {}
	self.skill_fight_power = 0
	self.fix_show_time = 10
	self.res_id = -1
	self.cur_select_img_index = -1
	self.temp_img_index = -1
	self.prefab_preload_id = 0
	self.last_level = 0
	self.is_set_select_add = false
end

function AdvanceCloakView:__delete()
	self.fight_text = nil
	self.tesu_index = 0
	self.node_list["Stars"] = nil
	self.show_next_attr = nil

	self.toggle_group = nil
	for i = 1, 3 do
		self.item_cell_list[i]:DeleteMe()
	end

	self.cloak_skill_list = {}

	self.jinjie_next_time = nil
	self.is_auto = nil
	
	self.old_attrs = {}
	self.skill_fight_power = nil
	self.fix_show_time = nil
	self.res_id = nil
	self.last_level = nil
	self.is_text_gray = nil
	self.node_list["TxtStartButton"] = nil
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end

	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
end

function AdvanceCloakView:CheckSelectItem()
	-- local index = CloakData.Instance:CheckSelectItem(self.item_index)
	-- self.item_index = index

	-- for i = 1, 3 do
	-- 	self.item_cell_list[i]:SetToggle(self.item_index == i)
	-- end
end
function AdvanceCloakView:CheckActiveBind()

	self.node_list["GrayUseButton"]:SetActive(self.show_use_button )
	self.node_list["ImgAdvacned"]:SetActive(self.show_use_image )
	self.node_list["BtnLeftButton"]:SetActive(self.show_left_button )
	self.node_list["BtnRightButton"]:SetActive(self.show_right_button )
	self.node_list["NodeNextStr"]:SetActive(self.is_show_next_str and self.show_next_attr and self.show_left_txt)
	self.node_list["NodeAttr1"]:SetActive(self.show_next_attr)
	self.node_list["NodeAttr2"]:SetActive(self.show_next_attr)
	self.node_list["NodeAttr3"]:SetActive(self.show_next_attr)
end
-- 开始进阶
function AdvanceCloakView:OnStartAdvance()
	local cloak_info = CloakData.Instance:GetCloakInfo()
	local level_cfg = CloakData.Instance:GetCloakLevelCfg(cloak_info.cloak_level)

	if cloak_info.cloak_level >= CloakData.Instance:GetMaxCloakLevel() then
		return
	end

	local stuff_item_id = CloakData.Instance:GetCloakUpLevelStuffCfg(self.item_index).up_level_item_id
	local num = ItemData.Instance:GetItemNumInBagById(stuff_item_id)
	if num <= 0 then
		self.is_auto = false
		self.is_can_auto = true
		self:SetAutoButtonGray()
		TipsCtrl.Instance:ShowItemGetWayView(stuff_item_id)
		return
	end

	local pack_num = level_cfg and level_cfg.pack_num or 1
	local next_time = level_cfg and level_cfg.next_time or 0.1

	CloakCtrl.Instance:SendCloakUpLevelReq(self.item_index, is_auto_buy, self.is_auto and pack_num or 1) -- , self.is_auto
	self.jinjie_next_time = Status.NowTime + next_time
end

function AdvanceCloakView:AutoUpLevelOnce()
	local jinjie_next_time = 0
	if nil ~= self.upgrade_timer_quest then
		if self.jinjie_next_time >= Status.NowTime then
			jinjie_next_time = self.jinjie_next_time - Status.NowTime
		end
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
	end

	local cloak_info = CloakData.Instance:GetCloakInfo()
	if cloak_info.cloak_level < CloakData.Instance:GetMaxCloakLevel() then
		if self.is_auto then
			self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.OnStartAdvance,self), jinjie_next_time)
		end
	end
end

function AdvanceCloakView:CloakUpgradeResult(result)
	self.is_can_auto = true

	self:CheckSelectItem()

	local up_level_cfg = CloakData.Instance:GetCloakUpLevelStuffCfg(self.item_index)
	local num = ItemData.Instance:GetItemNumInBagById(up_level_cfg.up_level_item_id)

	if num <= 0 then
		self.is_auto = false
		self:SetAutoButtonGray()
	else
		self:AutoUpLevelOnce()
	end
end

-- 自动进阶
function AdvanceCloakView:OnAutomaticAdvance()
	local cloak_info = CloakData.Instance:GetCloakInfo()
	if cloak_info.cloak_level < 0 then
		return
	end

	if not self.is_can_auto then
		return
	end

	self.is_auto = self.is_auto == false
	self.is_can_auto = false
	self:OnStartAdvance()
	self:SetAutoButtonGray()
end

function AdvanceCloakView:OnClickEquipBtn()
end
function AdvanceCloakView:OnClickHuanHua()
	-- body
end

function AdvanceCloakView:SwitchGradeAndName(index)
	if index == nil then return end

	local cloak_info = CloakData.Instance:GetCloakInfo()
	local image_cfg = CloakData.Instance:GetImageListInfo(index)
	local cloak_level_cfg = CloakData.Instance:GetCloakLevelCfg(cloak_info.cloak_level)
	local name_cfg = CloakData.Instance:GetImageListInfo(cloak_level_cfg.active_image)

	local max_level = CloakData.Instance:GetMaxCloakLevel()
	local level = cloak_info.cloak_level
	local color = math.floor((cloak_level_cfg.active_image - 1) / 2) + 1
	if name_cfg and next(name_cfg) then
		local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..name_cfg.image_name.."</color>"
		self.node_list["TxtDisplayName"].text.text = "Lv."..level .. " " .. name_str
	else
		self.node_list["TxtDisplayName"].text.text = "Lv."..level
	end

	local next_ative_img_level = CloakData.Instance:GetActiveImgLevelByActiveImage(index)
	self.is_show_next_str = nil ~= next_ative_img_level
	if next_ative_img_level then
		self.node_list["TxtNextImgActiveLevel"].text.text = next_ative_img_level
		if cloak_level_cfg then
			self.node_list["TxtNextImgActiveName"].text.text = image_cfg.image_name
		end
	end

	local call_back = function(model, obj)
		if obj then
			local vo = GameVoManager.Instance:GetMainRoleVo()
			if vo.prof == GameEnum.ROLE_PROF_1 then
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, 130, 0)
			elseif vo.prof == GameEnum.ROLE_PROF_2 then
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, 170, 0)
			else
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, 145, 0)
			end
		end
	end
	UIScene:SetModelLoadCallBack(call_back)
	if image_cfg and self.res_id ~= image_cfg.res_id then
		PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
		local bundle, asset = ResPath.GetPifengModel(image_cfg.res_id)
		local load_list = {{bundle, asset}}
		self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
				local vo = GameVoManager.Instance:GetMainRoleVo()
				local info = {}
				info.cloak_info = {used_imageid = index}
				info.prof = PlayerData.Instance:GetRoleBaseProf()
				info.sex = vo.sex
				info.is_not_show_weapon = true
				local fashion_info = FashionData.Instance:GetFashionInfo()
				local is_used_special_img = fashion_info.is_used_special_img
				info.is_normal_fashion = is_used_special_img == 0 and true or false
				info.shizhuang_part_list = {{image_id = 0}, {image_id = is_used_special_img == 0 and fashion_info.use_clothing_index or fashion_info.use_special_img}}
				UIScene:SetRoleModelResInfo(info, false, true)
			end)
		self.res_id = image_cfg.res_id
	end
end

-- 使用当前形象
function AdvanceCloakView:OnClickUse()
	if self.cur_select_img_index == nil then
		return
	end

	if nil == CloakData.Instance:GetImageListInfo(self.cur_select_img_index) then
		return
	end
	
	CloakCtrl.Instance:SendUseCloakImage(self.cur_select_img_index)
end

-- 资质
function AdvanceCloakView:OnClickZiZhi()
	ViewManager.Instance:Open(ViewName.TipZiZhi, nil, "cloakzizhi", {item_id = CloakDanId.ZiZhiDanId})
end

-- 成长
function AdvanceCloakView:OnClickChengZhang()
	ViewManager.Instance:Open(ViewName.TipChengZhang, nil, "cloakchengzhang", {item_id = CloakDanId.ChengZhangDanId})
end


-- 点击披风技能
function AdvanceCloakView:OnClickCloakSkill(index)
	TipsCtrl.Instance:ShowTipSkillView(index - 1, "cloak")
end

function AdvanceCloakView:GetCloakSkill()
	for i = 1, 4 do
		local skill = nil
		self.cur_data = CloakData.Instance:GetCloakSkillCfgBuyIndex(i - 1) or {}
		local is_teshu = false
		skill = self.node_list["AdvanceSkill"..i]
		if self.cur_data and next(self.cur_data) and self.cur_data.is_teshu then
			is_teshu = self.cur_data.is_teshu == 1
		end
		if is_teshu then
			skill = self.node_list["SpecialSkill"]
			self.node_list["AdvanceSkill" ..i ]:SetActive(false)
			self.node_list["SpecialSkill"]:SetActive(true)
			self.node_list["SpecialSkillText"]:SetActive(true)
			self.tesu_index = i
		end
		local icon = skill.transform:FindHard("Image")
		icon = U3DObject(icon, icon.transform, self)
		table.insert(self.cloak_skill_list, {skill = skill, icon = icon})
	end
	for k, v in pairs(self.cloak_skill_list) do
		local bundle, asset = ResPath.GetCloakSkillIcon(k)
		v.icon.image:LoadSprite(bundle, asset)
		v.skill.toggle:AddValueChangedListener(BindTool.Bind(self.OnClickCloakSkill, self, k))
	end
end

function AdvanceCloakView:FlushSkillIcon()
	for k, v in pairs(self.cloak_skill_list) do
		local is_active = CloakData.Instance:GetSkillIsActive(k - 1)
		UI:SetGraphicGrey(v.icon, not is_active)
	end
	local cur_data = CloakData.Instance:GetCloakSkillCfgBuyIndex(self.tesu_index - 1) or {}
	local cloak_info = CloakData.Instance:GetCloakInfo()
	if next(cur_data) then
		if cur_data.level and cloak_info and cloak_info.cloak_level and cur_data.level >= cloak_info.cloak_level then
			self.node_list["JiHuo"]:SetActive(true)
			self.node_list["JiHuo"].text.text = cur_data.jineng_desc or ""
		else
			self.node_list["JiHuo"]:SetActive(false)
		end
	else
		self.node_list["JiHuo"]:SetActive(false)
	end
end

--显示上一形象
function AdvanceCloakView:OnClickLastButton()
	if not self.cur_select_img_index or self.cur_select_img_index <= 0 then
		return
	end
	self.cur_select_img_index = self.cur_select_img_index - 1
	self:SetArrowState(self.cur_select_img_index)
	self:SwitchGradeAndName(self.cur_select_img_index)
end

--显示下一形象
function AdvanceCloakView:OnClickNextButton()
	local cloak_info = CloakData.Instance:GetCloakInfo()
	local level_cfg = CloakData.Instance:GetCloakLevelCfg(cloak_info.cloak_level)
	local max_level = CloakData.Instance:GetMaxCloakLevel()
	local max_level_cfg = CloakData.Instance:GetCloakLevelCfg(max_level)
	if not max_level_cfg or not level_cfg then
		return
	end
	-- if self.cur_select_img_index >= max_level_cfg.active_image or self.cur_select_img_index > level_cfg.active_image + 1 then
	if self.cur_select_img_index >= max_level_cfg.active_image then
		return
	end

	self.cur_select_img_index = self.cur_select_img_index + 1
	self:SetArrowState(self.cur_select_img_index)
	self:SwitchGradeAndName(self.cur_select_img_index)
end

-- 设置披风属性
function AdvanceCloakView:SetCloakAtrr()
	local cloak_info = CloakData.Instance:GetCloakInfo()
	if cloak_info == nil or cloak_info.cloak_level < 0 then
		self:SetAutoButtonGray()
		return
	end

	self:FlushItemNum()
	local cloak_level_cfg = CloakData.Instance:GetCloakLevelCfg(cloak_info.cloak_level)
	if not cloak_level_cfg then return end

	local up_level_cfg = CloakData.Instance:GetCloakUpLevelStuffCfg(self.item_index)
	local stuff_item_id = up_level_cfg.up_level_item_id

	if cloak_info.cloak_level < 0 then
		self:SetAutoButtonGray()
		return
	end

	if self.cur_select_img_index < 0 or self.temp_img_index < 0 then
		local cur_select_img_index = cloak_level_cfg.active_image > 0 and cloak_level_cfg.active_image or 1
		self.cur_select_img_index = cloak_info.used_imageid ~= 0 and cloak_info.used_imageid or cur_select_img_index

		self.temp_img_index = cur_select_img_index
	end

	if self.temp_img_index < cloak_level_cfg.active_image then
		-- 升级成功音效
		AudioService.Instance:PlayAdvancedAudio()
		-- 升级特效
		if not self.effect_cd or self.effect_cd <= Status.NowTime then
			self.node_list["EffectSuccess"]:SetActive(false)
			self.node_list["EffectSuccess"]:SetActive(true)
			self.effect_cd = EFFECT_CD + Status.NowTime
		end

		self.is_auto = false
		self.res_id = -1

		self.cur_select_img_index = cloak_level_cfg.active_image
		self.temp_img_index = cloak_level_cfg.active_image
	end

	self:SetAutoButtonGray()
	self:SetArrowState(self.cur_select_img_index)
	self:SwitchGradeAndName(self.cur_select_img_index)

	if cloak_info.cloak_level >= CloakData.Instance:GetMaxCloakLevel() then
		self.node_list["TxtBlessVal"].text.text = Language.Common.YiMan
		self.node_list["SliderBlessRadio"].slider.value = 1
	else
		self.node_list["TxtBlessVal"].text.text = cloak_info.cur_exp .. "/" .. cloak_level_cfg.up_level_exp
		self.node_list["SliderBlessRadio"].slider.value = cloak_info.cur_exp / cloak_level_cfg.up_level_exp
	end

	local attr = CloakData.Instance:GetCloakAttrSum()
	local capability = CommonDataManager.GetCapability(attr)
	self.old_attrs = attr
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = capability
	end
	if cloak_info.cloak_level == 0 then
		local attr1 = CloakData.Instance:GetCloakAttrSum(nil, true)
		local attr0 = CloakData.Instance:GetCloakAttrSum()
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
		local attr2 = CloakData.Instance:GetCloakAttrSum()
		local switch_attr_list = CommonDataManager.GetOrderAttributte(attr2)
		local next_attr = CloakData.Instance:GetCloakAttrSum(nil, true)
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
				if cloak_info.cloak_level >= CloakData.Instance:GetMaxCloakLevel() then
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

	local max_grade = CloakData.Instance:GetMaxCloakLevel()
	local active_grade, attr_type, attr_value = CloakData.Instance:GetSpecialAttrActiveType()
	if active_grade and attr_type and attr_value then
		if cloak_info.cloak_level < active_grade then
			local str = string.format(Language.Advance.OpenLevel, active_grade)
			self.node_list["TxtSpecialAttr"]:SetActive(true)
			self.node_list["TxtSpecialAttr"].text.text = string.format(Language.Advance.SpecialAttr[attr_type] .. attr_value / 100 .. "%%") .. str
		else
			local str = ""
			local special_attr = nil
			for i = cloak_info.cloak_level + 1, max_grade do
				local next_active_grade, next_attr_type, next_attr_value = CloakData.Instance:GetSpecialAttrActiveType(i)
				if next_attr_value then
					if next_attr_value ~= attr_value then
						special_attr = next_attr_value - attr_value
						str = string.format(Language.Advance.NextLevelAttr, next_active_grade, special_attr / 100)
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

	local max_level = CloakData.Instance:GetMaxCloakLevel()
	
	if cloak_info.cloak_level >= max_level then
		self.show_next_attr = false
	end
	-- local item_cfg = ItemData.Instance:GetItemConfig(stuff_item_id)
	-- local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">" ..item_cfg.name.."</color>"

	self.node_list["ImgZiZhiRemind"]:SetActive(CloakData.Instance:IsShowZizhiRedPoint())
	self.node_list["EffectChengZhang"]:SetActive(CloakData.Instance:IsShowChengzhangRedPoint())
	self:CheckSelectItem()
	self:CheckActiveBind()
end

function AdvanceCloakView:FlushItemNum()
	for i = 1, 3 do
		local up_stuff_cfg = CloakData.Instance:GetCloakUpLevelStuffCfg(i)
		if nil ~= up_stuff_cfg then
			local data = {}
			data.item_id = up_stuff_cfg.up_level_item_id
			data.num = ItemData.Instance:GetItemNumInBagById(up_stuff_cfg.up_level_item_id)
			self.item_cell_list[i]:SetShowNumTxtLessNum(-1)
			self.item_cell_list[i]:SetData(data)
		end
		self.node_list["item" .. i]:SetActive(nil ~= up_stuff_cfg)
	end
	self.node_list["RemindBtn"]:SetActive(CloakData.Instance:GetClockLevelRemind() and (not self.is_auto))
end

function AdvanceCloakView:SetArrowState(cur_select_img_index)
	local cloak_info = CloakData.Instance:GetCloakInfo()
	local level_cfg = CloakData.Instance:GetCloakLevelCfg(cloak_info.cloak_level)
	local max_level = CloakData.Instance:GetMaxCloakLevel()
	local max_level_cfg = CloakData.Instance:GetCloakLevelCfg(max_level)

	if not cloak_info or not cloak_info.cloak_level or not cur_select_img_index or not max_level then
		return
	end

	self.show_right_button = cur_select_img_index < max_level_cfg.active_image
	self.show_left_button = cur_select_img_index > 1
	
	self.show_use_button = cur_select_img_index ~= cloak_info.used_imageid and cur_select_img_index <= level_cfg.active_image

	self.show_use_image = cur_select_img_index == cloak_info.used_imageid

	local cloak_info = CloakData.Instance:GetCloakInfo()
	local next_ative_img_level = CloakData.Instance:GetActiveImgLevelByActiveImage(cur_select_img_index)
	if next_ative_img_level ~= nil and cloak_info.cloak_level >= next_ative_img_level then
		self.show_left_txt = false
	else	
		self.show_left_txt = true
	end

	self:CheckActiveBind()
end

-- 点击自动进阶，服务器返回信息，设置按钮状态
function AdvanceCloakView:SetAutoButtonGray()
	local cloak_info = CloakData.Instance:GetCloakInfo()
	if cloak_info.cloak_level == nil then return end

	local max_level = CloakData.Instance:GetMaxCloakLevel()

	if not cloak_info or not cloak_info.cloak_level or cloak_info.cloak_level < 0
		or cloak_info.cloak_level >= max_level then
		self.node_list["StartButton"]:SetActive(false)
		self.node_list["TxtAutoButton"].text.text = Language.Common.MaxLevel
		UI:SetButtonEnabled(self.node_list["StartButton"], false)
		UI:SetButtonEnabled(self.node_list["AutoButton"], false)
		return
	end

	local cloak_level_cfg = CloakData.Instance:GetCloakLevelCfg(cloak_info.cloak_level)
	local cur_select_img_index = cloak_level_cfg.active_image > 0 and cloak_level_cfg.active_image or 1
	if self.is_auto then
		self.node_list["TxtAutoButton"].text.text = Language.Common.Stop
		UI:SetButtonEnabled(self.node_list["StartButton"], false)
		UI:SetButtonEnabled(self.node_list["AutoButton"], true)
		if cloak_info.cloak_level >= 10 and not self.is_set_select_add then
			self.cur_select_img_index = cur_select_img_index + 1
			self.is_set_select_add = true
		end
	else
		self.node_list["TxtAutoButton"].text.text = Language.Common.ZiDongJinJie
		UI:SetButtonEnabled(self.node_list["StartButton"], true)
		UI:SetButtonEnabled(self.node_list["AutoButton"], true)
		if self.is_set_select_add then
			self.cur_select_img_index = cur_select_img_index
			self.is_set_select_add = false
		end
	end
end

-- 物品不足，购买成功后刷新物品数量
function AdvanceCloakView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	self:FlushItemNum()
end

function AdvanceCloakView:SetModle(is_show)
	if is_show then
		if not CloakData.Instance:IsActiviteCloak() then
			return
		end
		local cloak_info = CloakData.Instance:GetCloakInfo()
		local used_imageid = cloak_info.used_imageid
		local cloak_level_cfg = CloakData.Instance:GetCloakLevelCfg(cloak_info.cloak_level)
		if used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			used_imageid = used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID
		end
		if cloak_level_cfg and used_imageid and self.cur_select_img_index < 0 then
			local cur_select_img_index = used_imageid
			self:SetArrowState(cur_select_img_index)
			self:SwitchGradeAndName(cur_select_img_index)
			self.cur_select_img_index = self.cur_select_img_index and cur_select_img_index
		end
	else
		self.temp_img_index = -1
		self.cur_select_img_index = -1
		if self.node_list["EffectSuccess"] then
			self.node_list["EffectSuccess"]:SetActive(false)
		end
	end
	self:CheckActiveBind()
end

function AdvanceCloakView:ClearTempData()
	self.res_id = -1
	self.cur_select_img_index = -1
	self.temp_img_index = -1
	self.is_auto = false
end

function AdvanceCloakView:RemoveNotifyDataChangeCallBack()

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.temp_img_index = -1
	self.res_id = -1
	self.cur_select_img_index = -1
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
end

function AdvanceCloakView:OpenCallBack()
	self.node_list["Hide"]:SetActive(true)
	if self.node_list["EffectSuccess"] then
		self.node_list["EffectSuccess"]:SetActive(false)
	end

	local flag = SettingData.Instance:GetAdvanceTypeHideFlag(ADVANCE_HIDE_TYPE.CLOAK)
	self.node_list["HighLight"]:SetActive(flag == 1)

	local cloak_info = CloakData.Instance:GetCloakInfo()
	self.last_level = cloak_info.star_level
end

function AdvanceCloakView:FlushStars()
	local cloak_info = CloakData.Instance:GetCloakInfo()
	if nil == cloak_info.star_level then
		return
	end
	local index = cloak_info.star_level % 10
	if index == 0 then
		for k, v in pairs(self.stars_list) do
			UI:SetGraphicGrey(v,true)
		end
	else
		for i = 1, index do
			UI:SetGraphicGrey(self.stars_list[i],false)
		end
		for i = index + 1, 10 do
			UI:SetGraphicGrey(self.stars_list[i],true)
		end
	end
	if cloak_info.star_level == self.last_level + 1 then
		self.last_level = cloak_info.star_level
		if index == 0 then
			index = 10
		end
		local bundle_name, asset_name = ResPath.GetMiscEffect("Effect_baodian")
		EffectManager.Instance:PlayAtTransform(bundle_name, asset_name, self.stars_list[index].transform, 1.0, nil, nil)
	end
end

function AdvanceCloakView:OnFlush(param_list, uplevel_list)
	if not CloakData.Instance:IsActiviteCloak() then
		return
	end
	
	local advance_view = AdvanceCtrl.Instance:GetAdvanceView()
	if advance_view:IsOpen() and advance_view:GetShowIndex() ~= TabIndex.cloak_jinjie then return end
	self:SetCloakAtrr()
	self:FlushSkillIcon()
end

function AdvanceCloakView:ResetModleRotation()

end

function AdvanceCloakView:ToggleOnClick()
	local flag = SettingData.Instance:GetAdvanceTypeHideFlag(ADVANCE_HIDE_TYPE.CLOAK) == 0 and 1 or 0
	SettingData.Instance:SetAdvanceTypeHideFlag(ADVANCE_HIDE_TYPE.CLOAK, flag)
	self.node_list["HighLight"]:SetActive(flag == 1)
	if flag == 1 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.Hide .. Language.Advance.AdvanceHideType[ADVANCE_HIDE_TYPE.CLOAK])
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.UnHide .. Language.Advance.AdvanceHideType[ADVANCE_HIDE_TYPE.CLOAK])
	end
	SettingCtrl.Instance:SendHotkeyInfoReq()
end
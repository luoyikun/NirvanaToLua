AdvanceLingRenView = AdvanceLingRenView or BaseClass(BaseRender)

local EFFECT_CD = 1
local MOVE_TIME = 0.5

function AdvanceLingRenView:UIsMove()
	UITween.MoveShowPanel(self.node_list["InfoPanel"], Vector3(250 , -17 , 0 ) , MOVE_TIME)
	UITween.MoveShowPanel(self.node_list["SkillPanel"], Vector3(0 , -560 , 0 ) , MOVE_TIME)
	UITween.MoveShowPanel(self.node_list["Panel4"], Vector3(-35 , 480 , 0 ) , MOVE_TIME)
	UITween.MoveShowPanel(self.node_list["TitlePanel"], Vector3(0 , 400 , 0 ) , MOVE_TIME)
	-- UITween.MoveShowPanel(self.node_list["BtnPanel"] , Vector3(150 , -400 , 0 ) , MOVE_TIME )
end

function AdvanceLingRenView:__init(instance)
	local info = LingRenData.Instance:GetShenBingInfo()
	if instance == nil then
		return
	end
	self.is_auto = false
	self.item_index = 1
	self.effect_cd = 0
	self.prefab_preload_id = 0
	self.tesu_index = 0

	self.toggle_group = self.node_list["items"].toggle_group

	self.item_cell_list = {}
	self.toggle_list = {}
	for i = 1, 3 do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self.node_list["item"..i])
		self.item_cell_list[i]:SetToggleGroup(self.toggle_group)
		local handler = function()
			if self.item_index == i then
				self.item_cell_list[i]:OnClickItemCell()
			end
			self.item_index = i
			for i = 1, 3 do
				self.item_cell_list[i]:SetToggle(self.item_index == i)
			end
		end
		self.item_cell_list[i]:ListenClick(handler)
	end
	self.node_list["StartButton"].button:AddClickListener(BindTool.Bind(self.OnJinJieClick, self))
	self.node_list["BtnQualifications"].button:AddClickListener(BindTool.Bind(self.OnShuXingDanClick, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnHelpClick, self))
	self.node_list["AutoButton"].button:AddClickListener(BindTool.Bind(self.OnAutoJinJieClick, self))
	self.node_list["BtnChengZhang"].button:AddClickListener(BindTool.Bind(self.OnClickChengZhang, self))

	self.node_list["BtnQualifications"]:SetActive(false)	-- 策划说灵刃和披风屏蔽掉这两个按钮和技能
	self.node_list["BtnChengZhang"]:SetActive(false)
	self.node_list["SkillPanel"]:SetActive(false)

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFightPowerNum"])

	self.skill_icon_list = {}
	self.show_skill_gray_list = {}
	-- for i = 1, 4 do
	-- 	self.show_skill_gray_list[i] = self.node_list["ImgShengBingSkill"..i]
	-- 	self.node_list["ShengBingSkill"..i].toggle.onValueChanged:AddListener(BindTool.Bind(self.OnSkillClick, self, i))
	-- end
	self:GetLingRenSkill()
	self.node_list["ImgZiZhiReming"]:SetActive(LingRenData.Instance:GetShenBingZiZhiRemind())
	self.node_list["EffectChengZhang"]:SetActive(LingRenData.Instance:GetShenBingChengZhangRemind())
	self:SetNotifyDataChangeCallBack()
end

function AdvanceLingRenView:__delete()
	self.fight_text = nil
	self:RemoveNotifyDataChangeCallBack()
	self.tesu_index = 0
	for i = 1, 3 do
		self.item_cell_list[i]:DeleteMe()
	end
	if self.model_view then
		self.model_view:DeleteMe()
		self.model_view = nil
	end
	self.effect_root = nil
	self.is_text_gray = nil
	self.is_text_gray_blue = nil
	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
end

function AdvanceLingRenView:GetLingRenSkill()
	for i = 1, 4 do
		local skill = nil
		self.cur_data = LingRenData.Instance:GetShenBingSkillCfg(i - 1) or {}
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
		table.insert(self.show_skill_gray_list, {skill = skill, icon = icon})
	end
	for k, v in pairs(self.show_skill_gray_list) do
		local bundle, asset = ResPath.GetLingRenSkillIcon(k)
		v.icon.image:LoadSprite(bundle, asset)
		v.skill.toggle:AddValueChangedListener(BindTool.Bind(self.OnSkillClick, self, k))
	end
end

function AdvanceLingRenView:SetAuto(is_auto)
	self.is_auto = is_auto
	if self.is_auto then
		self.node_list["TxtAutoButton"].text.text = Language.Common.AutoUpgrade2[2]
		UI:SetButtonEnabled(self.node_list["AutoButton"], true)
		UI:SetButtonEnabled(self.node_list["StartButton"], false)
	else
		self.node_list["TxtAutoButton"].text.text = Language.Common.AutoUpgrade2[1]
		UI:SetButtonEnabled(self.node_list["AutoButton"], true)
		UI:SetButtonEnabled(self.node_list["StartButton"], true)
	end


end

function AdvanceLingRenView:CheckSelectItem()
	local index = LingRenData.Instance:CheckSelectItem(self.item_index - 1)
	self.item_index = index + 1
	for i = 1, 3 do
		self.item_cell_list[i]:SetToggle(self.item_index == i)
	end
end

function AdvanceLingRenView:WuQiUpgradeResult(result)
	self:OnUpgradeResult(result)
end

function AdvanceLingRenView:SetModle(is_show)
	local call_back = function(model, obj)
		if obj then
		end
	end
	UIScene:SetModelLoadCallBack(call_back)
	if is_show then
		PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
		local bundle, asset = ResPath.GetHunQiModel(17007)
		local load_list = {{bundle, asset}}
		self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
			local bundle_list = {[SceneObjPart.Main] = bundle}
			local asset_list = {[SceneObjPart.Main] = asset}
			UIScene:ModelBundle(bundle_list, asset_list)

			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "hunqi")
			UIScene:SetCameraTransform(transform, Vector2(-0.3, 0))
			end)
	end
end

function AdvanceLingRenView:OnFlush(param_t)
	local advance_view = AdvanceCtrl.Instance:GetAdvanceView()
	if advance_view:IsOpen() and advance_view:GetShowIndex() ~= TabIndex.immortals_jinjie then return end
	
	if nil ~= param_t.upgraderesult then
		self:OnUpgradeResult(param_t.upgraderesult[1])
	end
	self:FlushItem()
	local info = LingRenData.Instance:GetShenBingInfo()
	if next(info) and info.level and info.level >= 0 then
		self:SetLingRenAttr(info)
		local cur_attr = LingRenData.Instance:GetLevelAttrCfg(info.level)
		local next_attr = LingRenData.Instance:GetLevelAttrCfg(info.level + 1)
		if nil == cur_attr or nil == next(cur_attr) then
			cur_attr = LingRenData.Instance:GetLevelAttrCfg(info.level + 1)
		end
		if cur_attr and next(cur_attr) then
			self.node_list["SliderBlessRadio"].slider.value = info.exp / cur_attr.uplevel_exp
			self.node_list["TxtBlessRadio"].text.text = info.exp.."/"..cur_attr.uplevel_exp
			if self.fight_text and self.fight_text.text then
				self.fight_text.text.text = CommonDataManager.GetCapability(cur_attr)
			end
		end
		self.node_list["ImgZiZhiReming"]:SetActive(LingRenData.Instance:GetShenBingZiZhiRemind())
		self.node_list["EffectChengZhang"]:SetActive(LingRenData.Instance:GetShenBingChengZhangRemind())
		if info.level >= LingRenData.Instance:GetLingRenMaxLevel() then
			self.node_list["SliderBlessRadio"].slider.value = 1
			self.node_list["TxtBlessRadio"].text.text = Language.Common.YiMan
			self.node_list["StartButton"]:SetActive(false)
			UI:SetButtonEnabled(self.node_list["AutoButton"], false)
			self.node_list["TxtAutoButton"].text.text = Language.Common.MaxLevel
		end

		for k, v in pairs(self.show_skill_gray_list) do
			-- UI:SetGraphicGrey(self.show_skill_gray_list[i],not LingRenData.Instance:GetIsActive(i - 1))
			local node = v.skill.transform:FindHard("Image")
			if node then
				UI:SetGraphicGrey(node, not LingRenData.Instance:GetIsActive(k - 1))
			end
		end
	end
	local cur_data = LingRenData.Instance:GetShenBingSkillCfg(self.tesu_index - 1) or {}
	if cur_data and next(cur_data) then
		if cur_data.shenbing_level and info and info.level and cur_data.shenbing_level >= info.level then
			self.node_list["JiHuo"]:SetActive(true)
			self.node_list["JiHuo"].text.text = cur_data.jineng_desc or ""
		else
			self.node_list["JiHuo"]:SetActive(false)
		end
	else
		self.node_list["JiHuo"]:SetActive(false)
	end

	self.node_list["TxtName"].text.text = string.format("Lv.%s ", info.level) .. Language.Common.ShenBingName
	self:CheckSelectItem()
end

function AdvanceLingRenView:SetLingRenAttr(info)
	if info.level == 0 then
		local attr1 = LingRenData.Instance:GetLevelAttrCfg(info.level + 1)
		local attr0 = LingRenData.Instance:GetLevelAttrCfg(info.level)
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
		local attr2 = LingRenData.Instance:GetLevelAttrCfg(info.level)
		local switch_attr_list = CommonDataManager.GetOrderAttributte(attr2)
		local next_attr = LingRenData.Instance:GetLevelAttrCfg(info.level + 1)
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
				if info.level >= LingRenData.Instance:GetLingRenMaxLevel() then
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

	local active_grade, attr_type, attr_value = LingRenData.Instance:GetSpecialAttrActiveType()
	if active_grade and attr_type and attr_value then
		if info.level < active_grade then
			local str = string.format(Language.Advance.OpenLevel, active_grade)
			self.node_list["TxtSpecialAttr"]:SetActive(true)
			self.node_list["TxtSpecialAttr"].text.text = string.format(Language.Advance.SpecialAttr[attr_type] .. attr_value / 100 .. "%%") .. str
		else
			local str = ""
			local special_attr = nil
			for i = info.level + 1, LingRenData.Instance:GetLingRenMaxLevel() do
				local next_active_grade, next_attr_type, next_attr_value = LingRenData.Instance:GetSpecialAttrActiveType(i)
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
end

function AdvanceLingRenView:FlushItem()
	for i= 1, 3 do
		local up_level_cfg = LingRenData.Instance:GetUpLevelCfg(i - 1)
		local data = {}
		data.item_id = up_level_cfg.up_level_item_id
		data.num = ItemData.Instance:GetItemNumInBagById(up_level_cfg.up_level_item_id)
		self.item_cell_list[i]:SetShowNumTxtLessNum(-1)
		self.item_cell_list[i]:SetData(data)
		-- self.item_cell_list[i]:SetIconGrayScale(data.num <= 0)
		-- self.item_cell_list[i]:ShowQuality(data.num > 0)
	end
	self.node_list["RemindBtn"]:SetActive(LingRenData.Instance:GetShenBingLevelRemind() and (not self.is_auto))
end

function AdvanceLingRenView:OnJinJieClick()
	self.is_auto = false
	self:SendJinJie()
end

function AdvanceLingRenView:AutoJinJieResult()
	if self.is_auto == true then 
		self:SendJinJie()
	 end
end

function AdvanceLingRenView:SendJinJie()
	local item_id = LingRenData.Instance:GetUpLevelCfg(self.item_index - 1).up_level_item_id
	local my_count = ItemData.Instance:GetItemNumInBagById(item_id)
	if my_count > 0 then
		LingRenCtrl.SentShenBingUpLevel(self.item_index - 1)
	else
		TipsCtrl.Instance:ShowItemGetWayView(item_id)
		self.is_auto = false
	end

	if self.is_auto then

		self.node_list["TxtAutoButton"].text.text = Language.Common.AutoUpgrade2[2]
		UI:SetButtonEnabled(self.node_list["AutoButton"], true)
		UI:SetButtonEnabled(self.node_list["StartButton"], false)

	else
		self.node_list["TxtAutoButton"].text.text = Language.Common.AutoUpgrade2[1]
		UI:SetButtonEnabled(self.node_list["AutoButton"], true)
		UI:SetButtonEnabled(self.node_list["StartButton"], true)
	end


end

function AdvanceLingRenView:OnAutoJinJieClick()
	if self.is_auto == true then --再点一次停止
		self.is_auto = false
	else
		self.is_auto = true
	end
	if self.is_auto then
		self.node_list["TxtAutoButton"].text.text = Language.Common.AutoUpgrade2[2]
		UI:SetButtonEnabled(self.node_list["AutoButton"], true)
		UI:SetButtonEnabled(self.node_list["StartButton"], false)

	else
		self.node_list["TxtAutoButton"].text.text = Language.Common.AutoUpgrade2[1]
		UI:SetButtonEnabled(self.node_list["AutoButton"], true)
		UI:SetButtonEnabled(self.node_list["StartButton"], true)
	end
	self:AutoJinJieResult()
end

function AdvanceLingRenView:OnUpgradeResult(defalut)
	self:CheckSelectItem()
	if defalut == true and self.is_auto == true then
		self:AutoJinJieResult()
	end
end

function AdvanceLingRenView:OnShuXingDanClick()
	ViewManager.Instance:Open(ViewName.TipZiZhi, nil, "shenbingzizhi", {item_id = ShenBingDanId.ZiZhiDanId})
end

-- 成长
function AdvanceLingRenView:OnClickChengZhang()
	ViewManager.Instance:Open(ViewName.TipChengZhang, nil, "shenbingchengzhang", {item_id = ShenBingDanId.ChengZhangDanId})
end

function AdvanceLingRenView:OnHelpClick()
	local tips_id = 164
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function AdvanceLingRenView:OnSkillClick(i)
	TipsCtrl.Instance:ShowTipSkillView(i - 1, "shenbing")
end

function AdvanceLingRenView:RemoveNotifyDataChangeCallBack()
	if self.item_data_event ~= nil then
		if ItemData.Instance then
			print(self.item_data_event)
			ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
			self.item_data_event = nil
		end
	end
end

function AdvanceLingRenView:SetNotifyDataChangeCallBack()
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	end
end

function AdvanceLingRenView:ItemDataChangeCallback(item_id)
	local shen_data = LingRenData.Instance
	if item_id == ShenBingDanId.ZiZhiDanId then
		self.node_list["ImgZiZhiReming"]:SetActive(shen_data:GetShenBingZiZhiRemind())
		return
	end
	if item_id == ShenBingDanId.ChengZhangDanId then
		self.node_list["EffectChengZhang"]:SetActive(LingRenData.Instance:GetShenBingChengZhangRemind())
		return
	end
	local item_id_list = {}
	for i = 1, 3 do
		if item_id == shen_data:GetUpLevelCfg(i - 1).up_level_item_id then
			self:FlushItem()
			return
		end
	end
end

function AdvanceLingRenView:PlayUpStarEffect()
	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
		EffectManager.Instance:PlayAtTransformCenter(
			"effects/prefabs/misc_prefab",
			"UI_shengjichenggong",
			self.node_list["effect_root"].transform,
			2.0)
		self.effect_cd = Status.NowTime + EFFECT_CD
	end
end
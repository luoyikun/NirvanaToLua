-- 法则 ShengWuContent
local Gradient_Color1 = {
	[1] = Color(0/255, 222/255, 34/255, 1),
	[2] = Color(43/255, 173/255, 255/255, 1),
	[3] = Color(255/255, 118/255, 250/255, 1),
	[4] = Color(254/255, 144/255, 36/255, 1),
	[5] = Color(255/255, 1/255, 0/255, 1),
}
local Gradient_Color2 = {
	[1] = Color(75/255, 234/255, 122/255, 1),
	[2] = Color(69/255, 209/255, 255/255, 1),
	[3] = Color(203/255, 12/255, 255/255, 1),
	[4] = Color(255/255, 204/255, 0/255, 1),
	[5] = Color(255/255, 105/255, 80/255, 1),
}

GoddessShengWuView = GoddessShengWuView or BaseClass(BaseRender)

local AUTO_SPEED = 0.3
local TWEEN_TIME = 0.5
function GoddessShengWuView:__init(instance)
	self.uicamera = GameObject.Find("GameRoot/UICamera"):GetComponent(typeof(UnityEngine.Camera))

	self.chou_exp_stuff1 = GoddessData.Instance:GetXianNvChouExpStuff(GODDESS_CHOUEXP_TYPE.COMMON)
	self.chou_exp_stuff2 = GoddessData.Instance:GetXianNvChouExpStuff(GODDESS_CHOUEXP_TYPE.PERFECT)

	self.shengwu_auto_vip_level = GoddessData.Instance:GetXianNvOtherCfg().shengwu_auto_vip_level
	self.shengwu_ten_vip_level = GoddessData.Instance:GetXianNvOtherCfg().shengwu_ten_vip_level

	self.is_can_conmmon_auto = 0
	self.is_can_perfect_auto = 0
	self.select_index = 0
	self.is_on_fly = false
	self.is_on_fly_index = 0
	self.is_on_fly_shengwu_id = -1
	self.is_on_fly_chou_list = {}
	self:InitView()
	self.shengwu_comsume_cfg = GoddessData.Instance:GetShengWuComsumeCfg()
	self.is_common_effect = false
	self.is_perfect_effext = false
	self:SetNotifyDataChangeCallBack()

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["Power"])
	self.attr_list = {}
	for i = 1, 5 do
		local temp_tab = {}
		temp_tab.value = self.node_list["Label" .. i]
		temp_tab.arrow = self.node_list["Arrow" .. i]
		temp_tab.add_value = self.node_list["AddValue" .. i]
		self.attr_list[i] = temp_tab
	end
	self.is_auto = false
end

function GoddessShengWuView:InitView()
	self.node_list["BtnTip"].button:AddClickListener(BindTool.Bind(self.OnClickTip, self))
	self.node_list["BtnGongMingTip"].button:AddClickListener(BindTool.Bind(self.OnClickGongMingTip, self))
	self.node_list["BtnUpgrade"].button:AddClickListener(BindTool.Bind(self.OnClickUpgrade, self))
	self.node_list["BtnActive"].button:AddClickListener(BindTool.Bind(self.OnClickActive, self))
	self.node_list["BtnAutoUpgrade"].button:AddClickListener(BindTool.Bind(self.OnBtnAutoUpgrade, self))
	self.node_list["SkillIcon"].button:AddClickListener(BindTool.Bind(self.OnBtnSkillIcon, self))
	self.node_list["ButtonShouGou"].button:AddClickListener(BindTool.Bind(self.OnButtonShouGou, self))

	self.itemcell = ItemCell.New()
	self.itemcell:SetInstanceParent(self.node_list["ItemCell"])

	for i = 0, 3 do
		self["shengwu_icon" .. i] = GoddessShengWuIconItem.New(self.node_list["ShengWuIcon" .. i])
		self["shengwu_icon" .. i]:SetShengWuId(i)
		self.node_list["ShengWuIcon" .. i].toggle:AddValueChangedListener(BindTool.Bind(self.ToggleEvent, self, i))
	end

	self.hight_list = {}
	self.remind_list = {}
	for i = 0, 3  do
		self.hight_list[i] = self.node_list["Hight" .. i]
		self.remind_list[i] = self.node_list["Remind" .. i]
	end

	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	self.model_id = nil

	self.progress = ProgressBar.New(self.node_list["ProgressBG"])

	self:Flush()
end

function GoddessShengWuView:OpenCallBack()
	self:DoPanelTweenPlay()
	self:ToggleEvent(0)
	self:Flush()
end

function GoddessShengWuView:__delete()
	for i = 0,3 do
		if nil ~= self["shengwu_icon" .. i] then
			self["shengwu_icon" .. i]:DeleteMe()
			self["shengwu_icon" .. i] = nil
		end
	end
	
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	if self.itemcell then
		self.itemcell:DeleteMe()
		self.itemcell = nil
	end

	if self.progress then
		self.progress:DeleteMe()
		self.progress = nil
	end

	if self.auto_uplevel_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.auto_uplevel_quest)
		self.auto_uplevel_quest = nil
	end
	self.is_auto = false

	self.chou_exp_stuff1 = 0
	self.chou_exp_stuff2 = 0
	self.shengwu_auto_vip_level = 0
	self.shengwu_ten_vip_level = 0
	self.is_on_fly = false
	self.is_on_fly_index = 0
	self.is_on_fly_shengwu_id = -1
	self.is_on_fly_chou_list = {}

	self.is_can_conmmon_auto = 0
	self.is_can_perfect_auto = 0
	self:RemoveNotifyDataChangeCallBack()
	self.uicamera = nil
	self.fight_text = nil
end

function GoddessShengWuView:SetNotifyDataChangeCallBack()
	-- 监听系统事件
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function GoddessShengWuView:RemoveNotifyDataChangeCallBack()
	if self.item_data_event then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

-- 物品不足，购买成功后刷新物品数量
function GoddessShengWuView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	self:UpdataStuffShow()
end

function GoddessShengWuView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["TopContent"], GoddessData.OtherTweenPosition.Up , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["LeftContent"], GoddessData.OtherTweenPosition.Left , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["RightContent"], GoddessData.OtherTweenPosition.Right , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.AlpahShowPanel(self.node_list["Bottom"], true , TWEEN_TIME, DG.Tweening.Ease.InExpo)
end

function GoddessShengWuView:OnClickTip()
	TipsCtrl.Instance:ShowHelpTipView(Language.Goddess.GoddessShengWuTip2)
end

function GoddessShengWuView:CloseCallBack()
	if self.auto_uplevel_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.auto_uplevel_quest)
		self.auto_uplevel_quest = nil
	end
	self.is_auto = false
end


function GoddessShengWuView:OnFlush()
	self:UpdataStuffShow()
	self:UpdataShengWuIconShow()
	self:FlushRedPoint()
	self:FlushFaZheRemind()
end

function GoddessShengWuView:FlushRedPoint()
	local show_redpoint = GoddessData.Instance:GetFaZeRed()
	if self.node_list["RedPoint"] then
		self.node_list["RedPoint"]:SetActive(show_redpoint == 1)
	end
end

function GoddessShengWuView:UpdataShengWuIconShow()
	for i = 0, 3 do
		if self["shengwu_icon" .. i] then
			self["shengwu_icon" .. i]:SetShengWuId(i)
		end
	end
end

function GoddessShengWuView:ToggleEvent(index)
	if index ~= self.select_index and self.select_index == 0 then
		self:StopAutoQuest()
	end
	self.select_index = index
	for k, v in pairs(self.hight_list) do
		v:SetActive(false)
	end
	self.hight_list[index]:SetActive(true)
	local sc_info_data = GoddessData.Instance:GetXiannvScShengWuIconAttr(index)
	local shengwu_level = sc_info_data.level
	local info_data = GoddessData.Instance:GetXianNvShengWuCfg(index, shengwu_level)
	local upgrade_cfg = GoddessData.Instance:GetShengWuUpgradeCfg(index)
	if info_data == nil or upgrade_cfg == nil then
		return
	end

	if upgrade_cfg.consume_type == 1 then
		self.itemcell:SetData({item_id = ResPath.CurrencyToIconId["xiannv_jinghua"], is_bind = 0})
	else
		self.itemcell:SetData({item_id = upgrade_cfg.upgrade_stuff_id, is_bind = 0})
	end

	if self.model then
		local need_change = false
		if self.model_id == nil then
			self.model_id = info_data.display_id
			need_change = true
		else
			if self.model_id ~= info_data.display_id then
				need_change = true
				self.model_id = info_data.display_id
			end
		end
		-- 设置法则模型
		if need_change then
			local asset, bundle = ResPath.GetGatherModel(info_data.display_id)
			local fun = function ()
				self.model:SetScale(Vector3(2, 2, 2))
				self.camera = self.node_list["Display"].ui3d_display:GetComponentInChildren(typeof(UnityEngine.Camera))
				if index == 0 then
					self.camera.transform.localPosition = Vector3(0, 1.5, 7.5)
				elseif index == 1 then
					self.camera.transform.localPosition = Vector3(0, 2.6, 7.5)
				end
			end
			self.model:SetMainAsset(asset, bundle, fun)
			self.model_id  = info_data.display_id
		end
	end

	self:UpdataStuffShow()
end

function GoddessShengWuView:UpdataStuffShow()
	local sc_info_data = GoddessData.Instance:GetXiannvScShengWuIconAttr(self.select_index)
	local shengwu_level = sc_info_data.level
	local info_data = GoddessData.Instance:GetXianNvShengWuCfg(self.select_index, shengwu_level)
	local upgrade_cfg = GoddessData.Instance:GetShengWuUpgradeCfg(self.select_index)
	if upgrade_cfg == nil or info_data == nil then
		return
	end

	self.node_list["ShengwuName"].text.text = ToColorStr("Lv." .. info_data.level .." " .. info_data.name, SOUL_NAME_COLOR[info_data.shengwu_id + 2])
	local name_color = self.node_list["ShengwuName"]:GetComponent(typeof(UIGradient))
	if name_color then
		name_color.Color1 = Gradient_Color1[info_data.shengwu_id + 2]
		name_color.Color2 = Gradient_Color2[info_data.shengwu_id + 2]
	end

	local need_num = GoddessData.Instance:GetShengWuUpgradeCfg(self.select_index).active_need_fairy
	local has_num = #GoddessData.Instance:GetXiannvActiveList()
	local btn_text = ""
	if shengwu_level < 1 then
		self.node_list["Frame1"]:SetActive(true)
		self.node_list["Frame2"]:SetActive(false)
		self.node_list["ButtonShouGou"]:SetActive(false)
		if has_num < need_num then
			has_num = ToColorStr(has_num, TEXT_COLOR.RED)
			local num_desc = "(" .. has_num .. "/" .. need_num .. ")"
			self.node_list["ActiveCondition"].text.text =  ToColorStr(string.format(Language.Goddess.HasGoddesNum, need_num) .. num_desc, TEXT_COLOR.RED)
		else
			has_num = ToColorStr(has_num, TEXT_COLOR.GREEN)
			local num_desc = "(" .. has_num .. "/" .. need_num .. ")"
			self.node_list["ActiveCondition"].text.text =  ToColorStr(string.format(Language.Goddess.HasGoddesNum, need_num) .. num_desc, TEXT_COLOR.GREEN)
		end
		btn_text = Language.Common.Activate
		self.node_list["BtnAutoUpgrade"]:SetActive(false)
	else
		self.node_list["Frame1"]:SetActive(false)
		self.node_list["Frame2"]:SetActive(true)
		self.node_list["ButtonShouGou"]:SetActive(info_data.shengwu_id >= 2)
		btn_text = Language.ChatWin.BubbleActive
		if self.select_index == 0 then
			self.node_list["BtnAutoUpgrade"]:SetActive(true)
			self.node_list["ProgressBG"]:SetActive(true)
		else
			self.node_list["BtnAutoUpgrade"]:SetActive(false)
			self.node_list["ProgressBG"]:SetActive(false)
		end
	end
	-- self.node_list["HasGoddesNum"].text.text = string.format(Language.Goddess.HasGoddesNum, has_num, need_num)

	if self.select_index == 0 then
		local jinghua = GoddessData.Instance:GetXianQiJingHua()
		-- local show_color = jinghua >= info_data.upgrade_need_shengwu_essence and TEXT_COLOR.GREEN or TEXT_COLOR.RED
		-- self.node_list["ItemNum0"].text.text = ToColorStr(jinghua, show_color) .. "/" .. info_data.upgrade_need_shengwu_essence
		self.node_list["ItemNum0"].text.text = ToColorStr(jinghua, TEXT_COLOR.BLUE_1)
	else
		local need_item = ItemData.Instance:GetItemNumInBagById(upgrade_cfg.upgrade_stuff_id)
		local need_num = info_data.upgrade_need_stuff_number
		local show_color = TEXT_COLOR.GREEN
		if need_item < need_num then
			show_color = TEXT_COLOR.RED
		end
		local show_num = ToColorStr(need_item, show_color)
		self.node_list["ItemNum0"].text.text = show_num .. " / " .. need_num
	end


	if info_data.level >= upgrade_cfg.max_upgrade_level then
		self.node_list["BtnText"].text.text = Language.Common.YiManJi
		UI:SetButtonEnabled(self.node_list["BtnUpgrade"], false)
		self.node_list["ItemNum0"].text.text = "- / -"
	else
		self.node_list["BtnText"].text.text = btn_text
		UI:SetButtonEnabled(self.node_list["BtnUpgrade"], true)
		--UI:SetGraphicGrey(self.node_list["BtnUpgrade"], false)
	end

	local is_max = false
	local next_info_data
	if info_data.level >= upgrade_cfg.max_upgrade_level then
		is_max = true
	else
		next_info_data =GoddessData.Instance:GetXianNvShengWuCfg(self.select_index, shengwu_level + 1) or {}
	end

	local total_attr, fight_power = self:GetAttrTabAndFight(info_data, next_info_data)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = fight_power
	end
	for k, v in pairs(self.attr_list) do
		if total_attr[k] then
			v.value.text.text = total_attr[k].name .. "：" ..ToColorStr(total_attr[k].value, TEXT_COLOR.WHITE)
			v.value:SetActive(true)
			if total_attr[k].diff then
				v.add_value.text.text = total_attr[k].diff
				v.arrow:SetActive(true)
				v.add_value:SetActive(true)
			else
				v.arrow:SetActive(false)
				v.add_value:SetActive(false)
			end
		else
			v.value:SetActive(false)
			v.arrow:SetActive(false)
			v.add_value:SetActive(false)
		end
	end

	--经验设置
	if self.select_index == 0 then
		if is_max then
			self.node_list["ProgressBGText"].text.text = Language.Goddess.GoddessShengWuMax
			self.node_list["ProgressBG"].slider.value = 1
			self.node_list["BtnAutoUpgrade"]:SetActive(false)
		elseif not self.is_lock_bless then
			local jinghua = GoddessData.Instance:GetXianQiJingHua()
			jinghua = (jinghua > info_data.upgrade_need_exp) and info_data.upgrade_need_exp or jinghua
			local jinghua_str = ToColorStr(string.format("+%s", jinghua), TEXT_COLOR.YELLOW)
			self.node_list["BtnAutoUpgrade"]:SetActive(shengwu_level >= 1)
			local show_exp_radio = tonumber(string.format("%.2f", sc_info_data.exp / info_data.upgrade_need_exp))
			self.node_list["ProgressBGText"].text.text = sc_info_data.exp .. jinghua_str .. "/" .. info_data.upgrade_need_exp

			if not self.old_shengwu_level then
				self.old_shengwu_level = shengwu_level
				self.progress:SetValue(show_exp_radio)
			else
				if self.old_shengwu_level < shengwu_level and shengwu_level ~= 1 then
					if self.pro_quest ~= nil then
						self.node_list["ProgressBG"].slider.value = 0
						GlobalTimerQuest:CancelQuest(self.pro_quest)
						self.pro_quest = nil
					end
					local pro_num = self.node_list["ProgressBG"].slider.value
					self.pro_quest = GlobalTimerQuest:AddRunQuest(function ()
						self.node_list["ProgressBG"].slider.value = pro_num
						pro_num = pro_num + 0.1
						if self.node_list["ProgressBG"].slider.value >= 1 then
							if self.pro_quest ~= nil then
								GlobalTimerQuest:CancelQuest(self.pro_quest)
								self.pro_quest = nil
							end
							self.progress:SetValue(show_exp_radio)
						end
					end, 0)
					self.old_shengwu_level = shengwu_level
				else
					self.progress:SetValue(show_exp_radio)
				end
			end
		end
	end


	-- 技能
	local skill_id = info_data.skill_id or 1
	local skill_level = info_data.skill_level or 0
	local skill_level_next = skill_level + 1
	local icon_num = info_data.icon_num or 0

	local now_data = GoddessData.Instance:GetXianNvShengWuSkillCfg(skill_id, skill_level)
	local next_data = GoddessData.Instance:GetXianNvShengWuSkillCfg(skill_id, skill_level_next)
	local bundle, asset = ResPath.GetGoddessRes("shengwu_skill_" .. (self.select_index + 1))
	self.node_list["SkillIcon"].image:LoadSprite(bundle, asset)
	self.node_list["IconPercent"]:SetActive(self.select_index == 3)
	if skill_level == 0 then
		if next_data then
			self.node_list["SkillName"].text.text = "Lv.0 " .. next_data.name 
			self.node_list["SkillDesc"].text.text = next_data.skill_desc
			UI:SetGraphicGrey(self.node_list["SkillIcon"], true)
		end
	else
		if now_data then
			self.node_list["SkillName"].text.text = "Lv." .. skill_level .. " " .. now_data.name 
			self.node_list["SkillDesc"].text.text = now_data.skill_desc 
			UI:SetGraphicGrey(self.node_list["SkillIcon"], false)
		end
	end

	local next_skill_info = GoddessData.Instance:GetShengwuCfgBySkillLevel(self.select_index, skill_level_next)
	if next_skill_info then
		if skill_level == 0 then
			self.node_list["SkillActive"].text.text = ToColorStr("(Lv." .. next_skill_info.level .. Language.Common.Activate .. ")", TEXT_COLOR.RED) 
		else
			self.node_list["SkillActive"].text.text = ToColorStr("(Lv." .. next_skill_info.level .. Language.Common.UpGrade .. ")", TEXT_COLOR.RED) 
		end
		self.node_list["SkillActive"]:SetActive(true)
	else
		self.node_list["SkillActive"]:SetActive(false)
	end


	self:FlushRedPoint()
	self:FlushFaZheRemind()
end

function GoddessShengWuView:GetAttrTabAndFight(curr_equip_cfg, next_equip_cfg)
	local curr_attr_tab = CommonDataManager.GetGoddessAttributteNoUnderline(curr_equip_cfg)
	local next_attr_tab = {}
	local diff_attr_tab = {}
	if next_equip_cfg and next(next_equip_cfg) then
		next_attr_tab = CommonDataManager.GetGoddessAttributteNoUnderline(next_equip_cfg)
		diff_attr_tab = CommonDataManager.LerpAttributeAttrNoUnderLine(curr_attr_tab, next_attr_tab)
	end
	local sort_curr_attr= CommonDataManager.GetOrderAttributte(curr_attr_tab)
	local sort_next_attr= CommonDataManager.GetOrderAttributte(next_attr_tab)
	local sort_diff_attr = CommonDataManager.GetOrderAttributte(diff_attr_tab)

	local fight_power = CommonDataManager.GetCapabilityCalculation(curr_attr_tab)
	if next_equip_cfg and next_equip_cfg.level == 1 then
		fight_power = CommonDataManager.GetCapabilityCalculation(next_attr_tab)
	end
	local total_attr = {}
	local count = 1
	for k, v in pairs(sort_curr_attr) do
		if v.value > 0 or (sort_next_attr[k] and sort_next_attr[k].value and sort_next_attr[k].value > 0) then
			total_attr[count] = {}
			total_attr[count].name = CommonDataManager.GetAttrName(v.key) ~= "nil" and CommonDataManager.GetAttrName(v.key) or Language.Common.AttrNameNoUnderlineGoddess.goddess_gongji
			total_attr[count].value = v.value
			total_attr[count].diff = (next_equip_cfg and next(next_equip_cfg)) and sort_diff_attr[k].value or nil 
			count = count + 1
		end
	end
	return total_attr, fight_power
end

-- 刷新仙女仙器升级提示红点
function GoddessShengWuView:FlushFaZheRemind()
	for i = 0, 3 do
		local upgrade_cfg = GoddessData.Instance:GetShengWuUpgradeCfg(i)
		if upgrade_cfg == nil then return end
		local have_item_num = ItemData.Instance:GetItemNumInBagById(upgrade_cfg.upgrade_stuff_id)
		local sc_info_data = GoddessData.Instance:GetXiannvScShengWuIconAttr(i)
		if sc_info_data == nil then return end
		local shengwu_level = sc_info_data.level
		if shengwu_level == nil then return end
		local info_data = GoddessData.Instance:GetXianNvShengWuCfg(i, shengwu_level)
		if info_data == nil then return end
		local need_xiannv_num = GoddessData.Instance:GetShengWuUpgradeCfg(i).active_need_fairy or 0
		local have_xiannv_num = #GoddessData.Instance:GetXiannvActiveList() or 0

		local is_show_remind = false
		if info_data.level >= 1 then -- 激活状态
			if i == 0 then
				local need_jinghua = info_data.upgrade_need_shengwu_essence
				local have_jinghua = GoddessData.Instance:GetXianQiJingHua()
				is_show_remind = (sc_info_data.exp + have_jinghua >= need_jinghua) and (info_data.level < upgrade_cfg.max_upgrade_level)
			else
				is_show_remind = (have_item_num >= info_data.upgrade_need_stuff_number) and (info_data.level < upgrade_cfg.max_upgrade_level)
			end
		else 						-- 未激活状态
			is_show_remind = have_xiannv_num >= need_xiannv_num
		end
		self.remind_list[i]:SetActive(is_show_remind)
	end
end

function GoddessShengWuView:UpdataPowerShow()
	
end

function GoddessShengWuView:OnClickActive()
	GoddessCtrl.Instance:SentCSXiannvShengwuReqReq(GODDESS_REQ_TYPE.UPGRADE_EXP, self.select_index)
end

function GoddessShengWuView:OnBtnAutoUpgrade()
	local upgrade_cfg = GoddessData.Instance:GetShengWuUpgradeCfg(self.select_index)
	if upgrade_cfg.upgrade_stuff_id == nil then
		return
	end

	local sc_info_data = GoddessData.Instance:GetXiannvScShengWuIconAttr(self.select_index)
	local shengwu_level = sc_info_data.level

	if shengwu_level < 1 then 
	--激活
		local need_num = upgrade_cfg.active_need_fairy
		local has_num = #GoddessData.Instance:GetXiannvActiveList()
		if has_num < need_num then
			TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Goddess.HasGoddesNum, need_num))
			return
		end
	else 
	--升级
		local need_item = 0
		if upgrade_cfg.consume_type == 2 then
			need_item = ItemData.Instance:GetItemNumInBagById(upgrade_cfg.upgrade_stuff_id)
			local info_data = GoddessData.Instance:GetXianNvShengWuCfg(self.select_index, shengwu_level)
			local need_num = info_data.upgrade_need_stuff_number
			if need_item < need_num then
				-- 物品不足，弹出TIP框
				TipsCtrl.Instance:ShowItemGetWayView(upgrade_cfg.upgrade_stuff_id)
				return
			end
		else
			local info_data = GoddessData.Instance:GetXianNvShengWuCfg(self.select_index, shengwu_level)
			need_item = GoddessData.Instance:GetXianQiJingHua()
			if need_item <= 0 then 
				-- 物品不足，弹出TIP框
				TipsCtrl.Instance:ShowItemGetWayView(ResPath.CurrencyToIconId["xiannv_jinghua"])
				return
			elseif info_data.level >= upgrade_cfg.max_upgrade_level then
				TipsCtrl.Instance:ShowSystemMsg(Language.Goddess.YiManJi)
				return				
			end
		end
	end

	if self.auto_uplevel_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.auto_uplevel_quest)
		self.auto_uplevel_quest = nil
	end

	self.is_auto = not self.is_auto

	if self.is_auto then
		if self.auto_uplevel_quest == nil then
			self.auto_uplevel_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.OnClickUpgrade, self), 0.3)
		end
		self.node_list["BtnAutoText"].text.text = Language.Common.Stop
		UI:SetButtonEnabled(self.node_list["BtnUpgrade"], false)
	else
		self:StopAutoQuest()
	end
end

function GoddessShengWuView:OnBtnSkillIcon()
	local data = {
		select_index = self.select_index,
	}
	TipsCtrl.Instance:SetSkillShowTipData(data, "shengwu_skill")
end

function GoddessShengWuView:OnButtonShouGou()
	MarketData.Instance:SetPurchaseItemId(5)
	ViewManager.Instance:Open(ViewName.Market, TabIndex.market_purchase, "select_purchase", {select_index == 5})
end

function GoddessShengWuView:StopAutoQuest()
	UI:SetButtonEnabled(self.node_list["BtnUpgrade"], true)
	self.node_list["BtnAutoText"].text.text = Language.Common.AutoUpgrade
	self.is_auto = false
	if self.auto_uplevel_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.auto_uplevel_quest)
		self.auto_uplevel_quest = nil
	end	
end

function GoddessShengWuView:OnClickUpgrade()
	local upgrade_cfg = GoddessData.Instance:GetShengWuUpgradeCfg(self.select_index)
	if upgrade_cfg.upgrade_stuff_id == nil then
		return
	end

	local sc_info_data = GoddessData.Instance:GetXiannvScShengWuIconAttr(self.select_index)
	local shengwu_level = sc_info_data.level

	if shengwu_level < 1 then 
	--激活
		local need_num = upgrade_cfg.active_need_fairy
		local has_num = #GoddessData.Instance:GetXiannvActiveList()
		if has_num < need_num then
			TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Goddess.HasGoddesNum, need_num))
			return
		end
	else 
	--升级
		local need_item = 0
		if upgrade_cfg.consume_type == 2 then
			need_item = ItemData.Instance:GetItemNumInBagById(upgrade_cfg.upgrade_stuff_id)
			local info_data = GoddessData.Instance:GetXianNvShengWuCfg(self.select_index, shengwu_level)
			local need_num = info_data.upgrade_need_stuff_number
			if need_item < need_num then
				-- 物品不足，弹出TIP框
				TipsCtrl.Instance:ShowItemGetWayView(upgrade_cfg.upgrade_stuff_id)
				return
			end
		else
			local info_data = GoddessData.Instance:GetXianNvShengWuCfg(self.select_index, shengwu_level)
			need_item = GoddessData.Instance:GetXianQiJingHua()
			if need_item <= 0 then 
				-- 物品不足，弹出TIP框
				if self.is_auto then
					self:StopAutoQuest()
				else
					TipsCtrl.Instance:ShowItemGetWayView(ResPath.CurrencyToIconId["xiannv_jinghua"])
				end
				return
			elseif info_data.level >= upgrade_cfg.max_upgrade_level then
				TipsCtrl.Instance:ShowSystemMsg(Language.Goddess.YiManJi)
				self:StopAutoQuest()
				return				
			end
		end
	end

	GoddessCtrl.Instance:SentCSXiannvShengwuReqReq(GODDESS_REQ_TYPE.UPGRADE_EXP, self.select_index)
end

function GoddessShengWuView:OnClickGongMingTip()
	self.cap_data = GoddessData.Instance:GetXiannvShengWuTotalAttr()
	TipsCtrl.Instance:ShowAttrAllView(self.cap_data)
end

function GoddessShengWuView:OnMoveChouEnd(obj, eff_obj)
	if not IsNil(obj) then
		ResMgr:Destroy(obj)
	end

	self:OnClickHuiYiIconCallFun()
	eff_obj:ShowEffect(true)
end

function GoddessShengWuView:OnClickHuiYiIconCallFun()
	GoddessCtrl.Instance:SentCSXiannvShengwuReqReq(GODDESS_REQ_TYPE.FETCH_EXP)
end

function GoddessShengWuView:OnMoveEnd(obj)
	if not IsNil(obj) then
		ResMgr:Destroy(obj)
	end

	for i = 0, 3 do
		if self["shengwu_icon" .. i] then
			self["shengwu_icon" .. i]:SetBlessValue()
		end
	end
end

function GoddessShengWuView:ShowFlyText(begin_obj, value)
	ResPoolMgr:GetDynamicObjAsync("uis/views/goddess_prefab", "ShenwuText", 
		function(obj)
			local list = U3DNodeList(obj:GetComponent(typeof(UINameTable)), self)
			list["Text"].text.text = value
			obj.transform:SetParent(begin_obj.transform, false)
			local tween = obj.transform:DOLocalMoveY(10, 0.5)
			tween:SetEase(DG.Tweening.Ease.Linear)
			tween:OnComplete(BindTool.Bind(self.OnMoveEnd, self, obj))
		end)
end

function GoddessShengWuView:OnClickIcon()
	TipsCtrl.Instance:OpenItem({item_id = self.chou_exp_stuff1})
end

--------------------------------------------------------------------------------
-- 圣物 GoddessShengWuIcon_ .. i
GoddessShengWuIconItem = GoddessShengWuIconItem or BaseClass(BaseRender)
function GoddessShengWuIconItem:__init()
	self.node_list["SkillIcon"].button:AddClickListener(BindTool.Bind(self.SkillOnClick, self))

	self.shengwu_id = 0
	self.shengwu_level = 0

	for i = 0, 2 do
		self["info_text_" .. i] = self.node_list["InfoText".. i]
	end

	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)

	-- self.fight_text = CommonDataManager.FightPower(self, self.node_list["Power"])

	self.model_id = nil
	self.is_lock_bless = false
end

function GoddessShengWuIconItem:__delete()
	-- self.fight_text = nil
	
	for i = 0, 2 do
		self["info_text_" .. i] = nil
	end
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	self.model_id = nil
	self.is_lock_bless = false
end

function GoddessShengWuIconItem:SkillOnClick()
	GoddessCtrl.Instance:OpenGoddessSkillTipView(self.shengwu_id)
end

function GoddessShengWuIconItem:OnFlush()
	local sc_info_data = GoddessData.Instance:GetXiannvScShengWuIconAttr(self.shengwu_id)
	self.shengwu_level = sc_info_data.level
	local info_data = GoddessData.Instance:GetXianNvShengWuCfg(self.shengwu_id, self.shengwu_level)
	local next_info_data = GoddessData.Instance:GetXianNvShengWuCfg(self.shengwu_id, self.shengwu_level + 1)
	if info_data == nil then
		return
	end

	if self.model then
		local need_change = false
		if self.model_id == nil then
			self.model_id = info_data.display_id
			need_change = true
		else
			if self.model_id ~= info_data.display_id then
				need_change = true
				self.model_id = info_data.display_id
			end
		end
		-- 设置法则模型
		if need_change then
			local asset, bundle = ResPath.GetGatherModel(info_data.display_id)
			self.model:SetMainAsset(asset, bundle)
			self.model_id  = info_data.display_id
		end
	end
	-- 属性显示设置
	local now_attr = CommonDataManager.GetGoddessAttributteNoUnderline(info_data)
	local had_base_attr = {}

	-- local cap = CommonDataManager.GetCapability(now_attr)
	-- if cap and cap >= 0 then
	-- 	self.fight_text.text.text = cap
	-- else
	-- 	self.fight_text.text.text = 0
	-- end

	local had_base_attr_gj = {}
	if self.shengwu_level == 0 then
		local next_attr = CommonDataManager.GetGoddessAttributteNoUnderline(next_info_data, true)
		for k, v in pairs(next_attr) do
			if v > 0 then
				if now_attr[k] and now_attr[k] > 0 then
					if k == "goddess_gongji" then 
						table.insert(had_base_attr_gj,{key = k, value = now_attr[k]})
					else
						table.insert(had_base_attr,{key = k, value = now_attr[k]})
					end
				else
					if k == "goddess_gongji" then 
						table.insert(had_base_attr_gj,{key = k, value = 0})
					else
						table.insert(had_base_attr,{key = k, value = 0})
					end
				end
			end
		end
	else
		for k, v in pairs(now_attr) do
			if v > 0 then
				if k == "goddess_gongji" then 
					table.insert(had_base_attr_gj,{key = k, value = v})
				else
					table.insert(had_base_attr,{key = k, value = v})
				end
			end
		end
	end

	local attr_index = 0
	for k, v in pairs(had_base_attr) do
		if attr_index < 3 then
			local sttr_name = Language.Common.AttrNameNoUnderlineGoddess[v.key]
			local sttr_value = v.value
			local sttr_str = string.format(Language.Goddess.GoddessShuXing, sttr_name, sttr_value)
			self["info_text_" .. attr_index].text.text = sttr_str
			attr_index = attr_index + 1
		end
	end
	for k, v in pairs(had_base_attr_gj) do
		local sttr_name = Language.Common.AttrNameNoUnderlineGoddess[v.key]
		local sttr_value = v.value
		local sttr_str = string.format(Language.Goddess.GoddessShuXing, sttr_name, sttr_value)
		self["info_text_" .. attr_index].text.text = sttr_str
		attr_index = attr_index + 1
	end

	self.node_list["IconLevel"].text.text = string.format(Language.Goddess.GoddessShengWuName, info_data.name, info_data.level)
	self.node_list["SkillLevel"].text.text = "Lv."..info_data.skill_level


	local btn_show = info_data.skill_level == 0 and 255 or 0
	if nil ~= self.node_list["SkillIcon"] and btn_show ~= 0 then
		UI:SetGraphicGrey(self.node_list["SkillIcon"], true)
	else
		UI:SetGraphicGrey(self.node_list["SkillIcon"], false)
	end

	--经验设置
	if nil == next_info_data then
		self.node_list["CurBless"].text.text = Language.Goddess.GoddessShengWuMax
		self.node_list["ProgBg"].slider.value = 1
	elseif not self.is_lock_bless then
		local show_exp_radio = string.format("%.2f", sc_info_data.exp / info_data.upgrade_need_exp)

		self.node_list["CurBless"].text.text = sc_info_data.exp .. "/" .. info_data.upgrade_need_exp

		self.node_list["ProgBg"].slider.value = show_exp_radio
	end
end

function GoddessShengWuIconItem:SetShengWuId(index)
	self.shengwu_id = index
	self:Flush()
end

function GoddessShengWuIconItem:SetBlessValue()
	if nil == self.shengwu_id  or not self.is_lock_bless then
		return
	end

	local sc_info_data = GoddessData.Instance:GetXiannvScShengWuIconAttr(self.shengwu_id)
	self.shengwu_level = sc_info_data.level
	local info_data = GoddessData.Instance:GetXianNvShengWuCfg(self.shengwu_id, self.shengwu_level)
	local next_info_data = GoddessData.Instance:GetXianNvShengWuCfg(self.shengwu_id, self.shengwu_level + 1)
	if nil ==  info_data then return end

	local show_exp_radio = string.format("%.2f", sc_info_data.exp / info_data.upgrade_need_exp)
	self.node_list["CurBless"].text.text = sc_info_data.exp .. "/" .. info_data.upgrade_need_exp
	self.node_list["ProgBg"].slider.value = show_exp_radio
	self.is_lock_bless = false
end

function GoddessShengWuIconItem:SetBlessLockState(state)
	self.is_lock_bless = state
end

function GoddessShengWuIconItem:ShowEffect(flag)
	local bundle_name, asset_name = ResPath.GetMiscEffect("Effect_baodian")
	EffectManager.Instance:PlayAtTransform(bundle_name, asset_name, self.root_node.transform, 1.0, nil, nil, Vector3(1.5, 1.5, 1.5))
end


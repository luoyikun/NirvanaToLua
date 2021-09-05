SettingContentView = SettingContentView or BaseClass(BaseRender)

local DIFFERENCE = 5 					 -- data那边自动拾取装备的颜色那5项

local SKILLMAXNUM = 6

local QUALITY_VALUE =
{
	3, 	--低端
	2,  --普通
	1,  --良好
	0,  --最佳
}

function SettingContentView:__init(instance)
	SettingContentView.Instance = self
	self:InitView()
	self.is_init = true
	self.open_click = false
end

function SettingContentView:__delete()
	if SettingContentView.Instance ~= nil then
		 SettingContentView.Instance = nil
	end

	for k, v in pairs(self.skill_cell_list) do
		v:DeleteMe()
	end
	self.skill_cell_list = {}

	self.toggle_list = {}

	if self.countdonw then
		CountDown.Instance:RemoveCountDown(self.countdonw)
		self.countdonw = nil
	end
end

function SettingContentView:InitView()
	self.toggle_list = {}
	self.node_list["SelectAccoutBtn"].button:AddClickListener(BindTool.Bind(self.BackLoginOnClick, self))
	self.node_list["SelectAccountBtn"].button:AddClickListener(BindTool.Bind(self.BackLoginOnClick, self))
	self.node_list["SelectRoleBtn"].button:AddClickListener(BindTool.Bind(self.SelectRoleOnClick, self))
	self.node_list["SelctRoleBtn"].button:AddClickListener(BindTool.Bind(self.SelectRoleOnClick, self))
	self.node_list["auto_pick"].dropdown.onValueChanged:AddListener(BindTool.Bind(self.AutoPickValueChange, self))
	self.node_list["TlksBtn"].button:AddClickListener(BindTool.Bind(self.OnClickTlksBtn, self))
	if IS_AUDIT_VERSION then
		self.node_list["SelectRoleBtn"]:SetActive(false)
		self.node_list["SelectAccoutBtn"].transform.localPosition = Vector3(0, 0, 0)
	end

	self.frame_1 = self.node_list["frame_1"]
	self.frame_2 = self.node_list["frame_2"]
	
	local recommend_value = SettingData.Instance:GetRecommendQuality()
	for i = 1, 4 do
		self.node_list["TuiJian" .. i]:SetActive(3 - recommend_value == i - 1)
		self.node_list["pic_toggle_" .. i].toggle:AddClickListener(BindTool.Bind2(self.QualityToggleClick, self, QUALITY_VALUE[i]))
	end
	self:FlushHl(PlayerPrefsUtil.GetInt("quality_level"))
	for i = 1, SettingData.MAX_INDEX - DIFFERENCE do  										--面板中的toggle的数量
		self.toggle_list[i] = self.node_list["toggle_" .. i]
		self.node_list["toggle_" .. i].toggle:AddValueChangedListener(BindTool.Bind2(self.ToggleOnClick, self, i))
	end

	self.skill_data_list = {}
	self.skill_cell_list = {}
	local skill_list_delegate = self.node_list["SkillList"].list_simple_delegate
	skill_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetSkillCellNumber, self)
	skill_list_delegate.CellRefreshDel = BindTool.Bind(self.SkillCellRefresh, self)

	self.set_flag_1 = {}
	self.set_flag_2 = {}
	self.set_flag_3 = {}
	for i = 1, 32 do
		self.set_flag_1[i] = 0
		self.set_flag_2[i] = 0
		self.set_flag_3[i] = 0
	end

	self.set_flag_1_dirty = false
	self.set_flag_2_dirty = false
	self.set_flag_3_dirty = false

	local setting_list = SettingData.Instance:GetSettingList()

	self.node_list["auto_pick"].dropdown.value = setting_list[SETTING_TYPE.AUTO_PICK_COLOR] or 0
	SettingData.Instance:SetPickLimitValue(self.node_list["auto_pick"].dropdown.value)
	self.is_first = true
	self:SetTlksTimeCd()
end

function SettingContentView:FlushClick1()
	self.frame_1:SetActive(true)
	self.frame_2:SetActive(false)
	UI:SetButtonEnabled(self.node_list["SelectRoleBtn"], not IS_ON_CROSSSERVER)
	UI:SetButtonEnabled(self.node_list["SelectAccoutBtn"], not IS_ON_CROSSSERVER)

	local setting_list = SettingData.Instance:GetSettingList()

	self.open_click = true

	for k,v in pairs(SettingPanel1) do 											--对应于面板的toggle，从服务器那边拿到数据，匹配赋值
		if v > 20 then
			if self.toggle_list[v - DIFFERENCE].toggle then
				self.toggle_list[v - DIFFERENCE].toggle.isOn = setting_list[v]
			end
		else
			if self.toggle_list[v].toggle then
				self.toggle_list[v].toggle.isOn = setting_list[v]
			end
		end
	end
	self.open_click = false
	self.flush_click_flag_1 = true
end

function SettingContentView:FlushClick2()

	self.frame_1:SetActive(false)
	self.frame_2:SetActive(true)
	UI:SetButtonEnabled(self.node_list["SelctRoleBtn"], not IS_ON_CROSSSERVER)
	UI:SetButtonEnabled(self.node_list["SelectAccountBtn"], not IS_ON_CROSSSERVER)

	local setting_list = SettingData.Instance:GetSettingList()
	self.open_click = true

	for k,v in pairs(SettingPanel2) do 											--对应于面板的toggle，从服务器那边拿到数据，匹配赋值
		if v > 20 then
			if self.toggle_list[v - DIFFERENCE].toggle then
				self.toggle_list[v - DIFFERENCE].toggle.isOn = setting_list[v]
			end
		else 
			if self.toggle_list[v].toggle then
				self.toggle_list[v].toggle.isOn = setting_list[v]
			end
		end
	end
	self.open_click = false
	self.flush_click_flag_2 = true

	if self.node_list["SkillList"] then
		self.skill_data_list = SkillData.Instance:GetActiveSkillListCfg()
		table.remove(self.skill_data_list, 1)
		for k, v in pairs(self.skill_data_list) do
			local skill_info = SkillData.Instance:GetSkillInfoById(v.skill_id)
			if nil == skill_info or 0 == skill_info.level then
				self.skill_data_list[k] = nil
			end
		end

		local list_width = {
			[1] = 300, [2] = 452, [3] = 620, [4] = 773, [5] = 940, [6] = 1090
		}
		if #self.skill_data_list > SKILLMAXNUM then
			self.node_list["SkillList"].rect.sizeDelta = Vector2(list_width[SKILLMAXNUM], 106)
		else
			self.node_list["SkillList"].rect.sizeDelta = Vector2(list_width[#self.skill_data_list], 106)
		end
		self.node_list["SkillList"].scroller:ReloadData(0)
	end
end

function  SettingContentView:FlushAutoUseSkill()
	if self.node_list["SkillList"] then
		self.node_list["SkillList"].scroller:ReloadData(0)
	end
end

function SettingContentView:SetFrame1Active(is_active)
	if self.is_init then
		return
	end
	self.frame_1:SetActive(is_active)
	self.frame_2:SetActive(not is_active)
end

function SettingContentView:FlushHl(quality_value)
	for i = 1, 4 do
		self.node_list["Hl" .. i]:SetActive(i - 1 == 3 - quality_value)

		self.node_list["pic_toggle_" .. i].toggle.isOn = i-1 == 3-quality_value
	end
end

function SettingContentView:ToggleOnClick(i, is_click)
	for k,v in pairs(SETTING_TYPE) do 					--点击面板中的toggle与data中SETTING_TYPE的相匹配
		if i < 20 then
			if i == v then
				self:SetFlag(SETTING_TYPE[k],is_click)
			end
		else
			if i + DIFFERENCE == v then
				local setting_list = SettingData.Instance:GetSettingList()
				if v == SETTING_TYPE.AUTO_USE_HIGH_FPS and not setting_list[v] then
					local describe = string.format(Language.Common.UseHighFps)
					local func = function() 
						self:SetFlag(SETTING_TYPE[k],is_click) 
					end
					local close_func = function() self.node_list["toggle_" .. i].toggle.isOn = false end
					TipsCtrl.Instance:ShowCommonAutoView(nil, describe, func, close_func)
				else
					self:SetFlag(SETTING_TYPE[k],is_click)
				end
			end
		end
	end
end

function SettingContentView:QualityToggleClick(i,is_click)
	if is_click then
		QualityConfig.QualityLevel = i
		PlayerPrefsUtil.SetInt("quality_level", i)
		if i == 2 or i == 3 then
			LimitScreenResolution(720)
		else
			LimitScreenResolution(1080)
		end

		self:FlushHl(i)
		GlobalEventSystem:Fire(ObjectEventType.QUALITY_CHANGE)
	end
end

function SettingContentView:SelectRoleOnClick()
	local sure_func = function()
		local combine_data = LoginData.Instance:GetCombineData()
		-- 合服后只有一个角色的玩家直接返回登录界面(不允许再创角)
		if combine_data.count and combine_data.count == 1 then
			GlobalEventSystem:Fire(LoginEventType.LOGOUT)
		else
			UtilU3d.CacheData("select_role_state", 1)
			UtilU3d.CacheData("select_role_plat_name", GameVoManager.Instance:GetUserVo().plat_name)
			GameRoot.Instance:Restart()
		end
		JUST_BACK_FROM_CROSS_SERVER = false
	end
	TipsCtrl.Instance:ShowCommonTip(sure_func, nil, Language.Common.IsLeaveSelectRole)
end

function SettingContentView:BackLoginOnClick()
	local sure_func = function()
		GlobalEventSystem:Fire(LoginEventType.LOGOUT)
		JUST_BACK_FROM_CROSS_SERVER = false
	end
	TipsCtrl.Instance:ShowCommonTip(sure_func, nil, Language.Common.IsLeaveLogin)
end

function SettingContentView:OnClickTlksBtn()
	local main_role = Scene.Instance:GetMainRole()
	if main_role and main_role:IsFightState() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.FightNotTlks)
		return

	elseif SceneType.Common ~= Scene.Instance:GetSceneType() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.SenceNotTlks)
		return
	end

	local func = function() 
		if self.countdonw then
			CountDown.Instance:RemoveCountDown(self.countdonw)
			self.countdonw = nil
		end
		SettingData.Instance:SetTlksClickTime()
		self:SetTlksTimeCd()
		SettingCtrl.Instance:SendRoleReturnReAlivePosi()
	end
	local describe = string.format(Language.Common.TlksDescribe)
	TipsCtrl.Instance:ShowCommonAutoView(nil, describe, func)
end

function SettingContentView:SetTlksTimeCd()
	if self.countdonw then
		return
	end
	local tlks_cds = SettingData.Instance:GetTlksClickTime()
	local cd_s = tlks_cds - Status.NowTime
	if cd_s > 0 then
		UI:SetButtonEnabled(self.node_list["TlksBtn"], false)
		self.countdonw = CountDown.Instance:AddCountDown(cd_s, 0.1, function(elapse_time, total_time)
			local time = math.floor(total_time - elapse_time)

			if time <= 0 then
				if self.node_list["Tlkstime"] and self.node_list["TlksBtn"] then
					self.node_list["Tlkstime"].text.text = ""
					UI:SetButtonEnabled(self.node_list["TlksBtn"], true)
				end
				CountDown.Instance:RemoveCountDown(self.countdonw)
				self.countdonw = nil
			else
				if self.node_list["Tlkstime"] then
					self.node_list["Tlkstime"].text.text = TimeUtil.FormatSecond(time, 2)
				end
			end
		end)
	end
end

function SettingContentView:SetFlag(index,is_click)
	if not self.open_click then  -- 手动点击的才记录
		for k, v in pairs(FixBugSettting) do
			if v == index then
				SettingData.Instance:SetBugFixRecordValue(index, is_click)
			end
		end
	end

	if index <= 16 then
		if is_click then
			self.set_flag_1[33 - index] = 1
		else
			self.set_flag_1[33 - index] = 0
		end

		if not self.open_click then  --确保赋值过flag_1
			self.set_flag_1_dirty = true
			SettingData.Instance:SetHasSetting(index)
		end
	elseif index > 16 and index <= 32 then
		if is_click then
			self.set_flag_2[33 - index + 16] = 1
		else
			self.set_flag_2[33 - index + 16] = 0
		end

		if not self.open_click then --确保赋值过flag_2
			self.set_flag_2_dirty = true
		end
	else
		if is_click then
			self.set_flag_3[65 - index] = 1
		else
			self.set_flag_3[65 - index] = 0
		end

		if not self.open_click then --确保赋值过flag_2
			self.set_flag_3_dirty = true
		end
	end

	local setting_data = SettingData.Instance
	setting_data:SetSettingData(index, is_click)
	if not self.open_click then
		setting_data:AfterSystemAutoSetting(index, is_click)
	end
end

function SettingContentView:CloseCallBack()

	if self.set_flag_1_dirty then
		self.set_flag_1_dirty = false
		SettingCtrl.Instance:SendChangeHotkeyReq(HOT_KEY.SYS_SETTING_1, bit:b2d(self.set_flag_1))
	end

	if self.set_flag_2_dirty then
		self.set_flag_2_dirty = false
		SettingCtrl.Instance:SendChangeHotkeyReq(HOT_KEY.SYS_SETTING_2, bit:b2d(self.set_flag_2))
	end

	if self.set_flag_3_dirty then
		self.set_flag_3_dirty = false
		SettingCtrl.Instance:SendChangeHotkeyReq(HOT_KEY.SYS_SETTING_3, bit:b2d(self.set_flag_3))
	end

	SettingCtrl.Instance:SendChangeHotkeyReq(HOT_KEY.SYS_SETTING_DROPDOWN_1, self.node_list["auto_pick"].dropdown.value)
	SettingCtrl.Instance:SendHotkeyInfoReq()
end

function SettingContentView:AutoPickValueChange(value)
	SettingData.Instance:SetPickLimitValue(value)
end


function SettingContentView:AutoRecycleValueChange(value)
	-- SettingData.Instance:SetRecycleLimitValue(value)
end

function SettingContentView:AutoUpgradeValueChange(value)
	if self.is_first then
		self.is_first = false
		return
	end
	SettingData.Instance:SetUgradeLimitValue(value)
end

-- 技能列表
function SettingContentView:GetSkillCellNumber(value)
	local skill_num = #self.skill_data_list
	if skill_num > SKILLMAXNUM then
		return SKILLMAXNUM
	end
	return skill_num
end

function SettingContentView:SkillCellRefresh(cell, index)
	local skill_cell = self.skill_cell_list[cell]
	index = index + 1
	if nil == skill_cell then
		skill_cell = SkillIconItemCell.New(cell.gameObject)
		self.skill_cell_list[cell] = skill_cell
	end

	local data = self.skill_data_list[index]
	skill_cell:SetData(data)
end



------------------------------------------
--------SkillIconItemCell 技能Item

SkillIconItemCell = SkillIconItemCell or BaseClass(BaseCell)
function SkillIconItemCell:__init()
	-- self.node_list["Bg"].button:AddClickListener(BindTool.Bind(self.ClickItem, self))
	self.node_list["Toggle"].button:AddClickListener(BindTool.Bind(self.ToggleOnClick, self))
end

function SkillIconItemCell:__delete()

end

-- function SkillIconItemCell:ClickItem()
-- 	ViewManager.Instance:Open(ViewName.SettingSkill)
-- end

function SkillIconItemCell:ToggleOnClick()
	if (SettingData.Instance:GetAutoUseSkillFlag(self.data.skill_index - 1) == 1) then
		SettingData.Instance:SetAutoUseSkillFlag(self.data.skill_index - 1, 0)
	else
		SettingData.Instance:SetAutoUseSkillFlag(self.data.skill_index - 1, 1)
	end
	SettingCtrl.Instance:SendHotkeyInfoReq()
end

function SkillIconItemCell:OnFlush()
	if nil == self.data then
		return
	end

	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local prof = PlayerData.Instance:GetRoleBaseProf()
	local bundle, asset = "", ""
	if self.data.skill_id == GameEnum.KILL_SKILL_ID then
		local skill_icon = self.data.skill_icon + (main_vo.prof % 10)
		bundle, asset = ResPath.GetRoleSkillIcon(skill_icon)
	elseif self.data.skill_id == ZHUAN_ZHI_SKILL1[prof] or self.data.skill_id == ZHUAN_ZHI_SKILL2[prof] then

		-- local skill_icon = self.data.skill_icon .. (main_vo.prof % 10) .. "_2"
		bundle, asset = ResPath.GetRoleSkillIcon(self.data.skill_id)
	else
 		bundle, asset = ResPath.GetRoleSkillIcon(self.data.skill_icon)
	end
	self.node_list["SkillIcon"].image:LoadSprite(bundle, asset)

	self.node_list["HighLight"]:SetActive(SettingData.Instance:GetAutoUseSkillFlag(self.data.skill_index - 1) == 1)
end


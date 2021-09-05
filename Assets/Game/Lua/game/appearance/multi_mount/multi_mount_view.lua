-- 仙域-外观-双骑-MultiMount
MultiMountView = MultiMountView or BaseClass(BaseRender)

local EFFECT_CD = 1.8
function MultiMountView:__init(instance)
	-- self.node_list["AutoButton"].button:AddClickListener(BindTool.Bind(self.OnAutomaticAdvance, self))
	self.node_list["BtnAdvance"].button:AddClickListener(BindTool.Bind(self.OnClickCancle, self))
	self.node_list["GrayUseButton"].button:AddClickListener(BindTool.Bind(self.OnClickUse, self))
	self.node_list["BtnHelpButton"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["StartButton"].button:AddClickListener(BindTool.Bind(self.OnStartAdvance, self))
	-- self.node_list["AutoToggle"].toggle:AddValueChangedListener(BindTool.Bind(self.OnAutoBuyToggleChange, self))
	self.node_list["BtnLeft"].button:AddClickListener(BindTool.Bind(self.ClickLastButton, self))
	self.node_list["BtnRight"].button:AddClickListener(BindTool.Bind(self.ClickNextButton, self))
	self.node_list["BtnHuanHua"].button:AddClickListener(BindTool.Bind(self.ClickHuanHua, self))
	
	self.cell_list = {}
	self.list_index = self.list_index or 1

	local list_delegate = self.node_list["MountList"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	-- 显示星星
	self.stars_list = {}

	-- 显示双骑进阶丹itemcell
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["ItemCell"])

	self.show_use_button = false
	self.show_use_image = true
	self.is_auto = false
	self.is_can_auto = true
	self.jinjie_next_time = 0
	self.temp_grade = -1
	self.fix_show_time = 10
	self.res_id = -1
	self.is_on_look = false
	self.prefab_preload_id = 0
	self.last_level = 0
	self.is_gray_upgrade_btn = false   -- 进阶按钮是否置灰

end

function MultiMountView:LoadCallBack(instance)
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFightPowerNum"])

end

function MultiMountView:__delete()
	self.jinjie_next_time = nil
	self.is_auto = nil
	self.temp_grade = nil
	self.list_index = nil
	self.res_id = nil
	self.last_level = nil
	self.is_gray_upgrade_btn = nil

	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end

	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = {}
	end

	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end

	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	self.fight_text = nil
end

-- 打开幻化界面
function MultiMountView:ClickHuanHua()
	ViewManager.Instance:Open(ViewName.MultiMountHuanHua)
end

-- 显示上一个形象
function MultiMountView:ClickLastButton()
	self:SetSelectIndex(self.list_index - 1)
end

-- 显示下一个形象
function MultiMountView:ClickNextButton()
	self:SetSelectIndex(self.list_index + 1)
end

-- 开始进阶
function MultiMountView:OnStartAdvance()
	local mount_info = MultiMountData.Instance:GetMountInfoByIndex(self.list_index)
	if nil == mount_info then return end
	local star_cfg = MultiMountData.Instance:GetMountCfgByIdAndLevel(self.list_index, mount_info.grade)
	if nil == star_cfg  then return end

	if mount_info.grade >= MultiMountData.Instance:GetMaxGradeByIndex(self.list_index) then
		return
	end

	if ItemData.Instance:GetItemNumInBagById(star_cfg.upgrade_stuff_id) < star_cfg.upgrade_stuff_num then --and not self.node_list["AutoToggle"].toggle.isOn
		self.is_auto = false
		self.is_can_auto = true
		self:SetAutoButtonGray()
		-- 物品不足，弹出TIP框
		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[star_cfg.upgrade_stuff_id]
		if nil == item_cfg then
			TipsCtrl.Instance:ShowItemGetWayView(star_cfg.upgrade_stuff_id)
			return
		end

		local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			if is_buy_quick then
				-- self.node_list["AutoToggle"].toggle.isOn = true
			end
		end

		TipsCtrl.Instance:ShowCommonBuyView(func, star_cfg.upgrade_stuff_id, nofunc, 1)
		return
	end
	-- local is_auto_buy = self.node_list["AutoToggle"].toggle.isOn and 1 or 0
	local is_auto_buy = 0
	local pack_num = star_cfg and star_cfg.pack_num or 1
	local next_time = star_cfg and star_cfg.next_time or 0.1
	MultiMountCtrl.Instance:SendMultiModuleReq(MULTI_MOUNT_REQ_TYPE.MULTI_MOUNT_REQ_TYPE_UPGRADE, self.list_index, pack_num, is_auto_buy)
	self.jinjie_next_time = Status.NowTime + (next_time or 0.1)
end

function MultiMountView:FlsuhAutoBuyToggle()
	-- if self.node_list["AutoToggle"] and self.node_list["AutoToggle"].toggle then
	-- 	self.node_list["AutoToggle"].toggle.isOn = TipsOtherHelpData.Instance:GetIsAutoBuy()
	-- end
end

function MultiMountView:AutoUpGradeOnce()
	local jinjie_next_time = 0

	if nil ~= self.upgrade_timer_quest then
		if self.jinjie_next_time >= Status.NowTime then
			jinjie_next_time = self.jinjie_next_time - Status.NowTime
		end
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
	end

	local mount_info = MultiMountData.Instance:GetMountInfoByIndex(self.list_index)

	if mount_info and mount_info.grade < MultiMountData.Instance:GetMaxGradeByIndex(self.list_index) then
		if self.is_auto then
			self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.OnStartAdvance,self), jinjie_next_time)
		end
	end
end

function MultiMountView:MultiMountUpgradeResult(result)
	self.is_can_auto = true
	if 0 == result then
		self.is_auto = false
		self:SetAutoButtonGray()
	else
		self:AutoUpGradeOnce()
	end
end

-- 自动进阶
function MultiMountView:OnAutomaticAdvance()
	local grade = MultiMountData.Instance:GetMountLevelByIndex(self.list_index)
	if nil == grade then return end

	if not self.is_can_auto then
		return
	end

	local function ok_callback()
		self.is_auto = self.is_auto == false
		self.is_can_auto = false
		self:OnStartAdvance()
		self:SetAutoButtonGray()
	end

	if self.is_can_auto then
		ok_callback()
	end
end

-- 使用当前坐骑
function MultiMountView:OnClickUse()
	if self.list_index == nil then
		return
	end
	MultiMountCtrl.Instance:SendMultiModuleReq(MULTI_MOUNT_REQ_TYPE.MULTI_MOUNT_REQ_TYPE_SELECT_MOUNT, self.list_index)
end

-- 取消使用当前坐骑
function MultiMountView:OnClickCancle()
	if self.list_index == nil then
		return
	end
	MultiMountCtrl.Instance:SendMultiModuleReq(MULTI_MOUNT_REQ_TYPE.MULTI_MOUNT_REQ_TYPE_USE_SPECIAL_IMG, 0)
	MultiMountCtrl.Instance:SendMultiModuleReq(MULTI_MOUNT_REQ_TYPE.MULTI_MOUNT_REQ_TYPE_SELECT_MOUNT, self.list_index)
end

function MultiMountView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(233)
end

function MultiMountView:GetSelectIndex()
	return self.list_index or 1
end

function MultiMountView:SetSelectIndex(index)
	self.list_index = index
	self.temp_grade = -1
	self.is_auto = false
	self:SetAutoButtonGray()
	self:Flush()

	local mount_info = MultiMountData.Instance:GetMountInfoByIndex(self.list_index)
	if mount_info then
		self.last_level = mount_info.grade
	end
end

-- 设置坐骑属性
function MultiMountView:SetMultiMountAtrr()
	local mount_info = MultiMountData.Instance:GetMountInfoByIndex(self.list_index)
	if nil == mount_info then
		self:SetAutoButtonGray()
		return
	end

	local star_cfg = MultiMountData.Instance:GetMountCfgByIdAndLevel(self.list_index, mount_info.grade)
	if nil == star_cfg then return end

	if self.temp_grade < 0 then
		self:SwitchGradeAndName(self.list_index)
		self:SetAutoButtonGray()
		self.temp_grade = star_cfg.client_grade
	else
		if self.temp_grade < star_cfg.client_grade then
			-- 升级成功音效
			AudioService.Instance:PlayAdvancedAudio()
			-- 升级特效
			if not self.effect_cd or self.effect_cd <= Status.NowTime then
				self.node_list["EffectShowEffect"]:SetActive(false)
				self.node_list["EffectShowEffect"]:SetActive(true)
				self.effect_cd = EFFECT_CD + Status.NowTime
			end
			self:SwitchGradeAndName(self.list_index)
			self.is_auto = false
			-- self.res_id = -1
			self:SetAutoButtonGray()
			self.show_on_look = false
			self.node_list["GrayUseButton"]:SetActive(self.show_use_button and (not self.show_on_look))
			self.node_list["BtnAdvance"]:SetActive(self.show_use_image and (not self.show_on_look))
		end
		self.temp_grade = star_cfg.client_grade
	end

	self:SetUseImageButtonState(self.list_index)
	self:SetArrowState(self.list_index)

	if mount_info.grade >= MultiMountData.Instance:GetMaxGradeByIndex(self.list_index) then
		-- self.node_list["TxtBlessRadio"].text.text = Language.Common.YiMan
		self:SetAutoButtonGray()
		-- self.node_list["SliderBlessRadio"].slider.value = 1
	else
		-- self.node_list["TxtBlessRadio"].text.text = mount_info.grade_bless .. "/" .. star_cfg.max_bless
		-- self.node_list["SliderBlessRadio"].slider.value = mount_info.grade_bless / star_cfg.max_bless
	end
	
	self:SetAttr(mount_info)

	self:ShowJinJieDanNum(star_cfg.upgrade_stuff_id, star_cfg.upgrade_stuff_num)
	self:ShowGradeRedPoint(star_cfg.upgrade_stuff_id, star_cfg.upgrade_stuff_num, self.list_index)

	local grade_dan_id = MultiMountData.Instance:GetGradeDanId(self.list_index, mount_info.grade)
	if nil ~= grade_dan_id then
		local data = {item_id = grade_dan_id}
		self.item:SetData(data)
	end
end

function MultiMountView:SetAttr(mount_info)
	if mount_info.grade == 0 then
		local attr1 = MultiMountData.Instance:GetMountCfgByIdAndLevel(self.list_index, mount_info.grade + 1)
		local attr0 = MultiMountData.Instance:GetMountCfgByIdAndLevel(self.list_index, mount_info.grade)
		local switch_attr_list_1 = CommonDataManager.GetAttributteByClass(attr1)
		local switch_attr_list_0 = CommonDataManager.GetAttributteByClass(attr0)
		local attr = CommonDataManager.GetAttributteByClass(switch_attr_list_1)
		switch_attr_list_1 = CommonDataManager.GetOrderAttributte(switch_attr_list_1)
		switch_attr_list_0 = CommonDataManager.GetOrderAttributte(switch_attr_list_0)
		local diff_1 = CommonDataManager.GetAttributteByClass(attr0)
		local diff_2 = CommonDataManager.GetAttributteByClass(attr1)
		local diff_attr = CommonDataManager.LerpAttributeAttr(diff_1, diff_2)
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
				self.node_list["Arrow" .. index]:SetActive(true)
				self.node_list["AddValue" .. index]:SetActive(true)				
				self.node_list["AddValue" .. index].text.text = switch_diff_attr_list[k].value or 0
			end
		end
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = CommonDataManager.GetCapabilityCalculation(attr)
		end
	else
		local attr2 = MultiMountData.Instance:GetMountCfgByIdAndLevel(self.list_index, mount_info.grade)
		local next_attr = MultiMountData.Instance:GetMountCfgByIdAndLevel(self.list_index, mount_info.grade + 1)
		local switch_attr_list = CommonDataManager.GetAttributteByClass(attr2)
		local attr = CommonDataManager.GetAttributteByClass(switch_attr_list)
		switch_attr_list = CommonDataManager.GetOrderAttributte(switch_attr_list)
		local diff_1 = CommonDataManager.GetAttributteByClass(attr2)
		local diff_2 = CommonDataManager.GetAttributteByClass(next_attr)
		local diff_attr = CommonDataManager.LerpAttributeAttr(diff_1, diff_2)
		local switch_diff_attr_list = CommonDataManager.GetAttributteByClass(diff_attr)
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
				if mount_info.grade >= MultiMountData.Instance:GetMaxGradeByIndex(self.list_index) then
					self.node_list["Arrow" .. index]:SetActive(false)
					self.node_list["AddValue" .. index]:SetActive(false)
				else
					self.node_list["Arrow" .. index]:SetActive(true)
					self.node_list["AddValue" .. index]:SetActive(true)
					self.node_list["AddValue" .. index].text.text = switch_diff_attr_list[k].value or 0
				end
			end
		end
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = CommonDataManager.GetCapabilityCalculation(attr)
		end
	end
end


-- 设置切换按钮状态
function MultiMountView:SetArrowState(index)
	self.node_list["BtnRight"]:SetActive(index < MultiMountData.Instance:GetMaxIndex())
	self.node_list["BtnLeft"]:SetActive(index > 1)
end

function MultiMountView:SetUseImageButtonState(index)
	local mount_info = MultiMountData.Instance:GetMountInfoByIndex(self.list_index)
	if mount_info == nil then return end

	local used_imageid = MultiMountData.Instance:GetCurUseMountId()
	local is_active = MultiMountData.Instance:GetMountIsActiveByIndex(index)

	self.show_use_button = index ~= used_imageid and is_active
	self.show_use_image = index == used_imageid and is_active
	-- self.node_list["NodeShowDec"]:SetActive((not self.show_use_button) and (not self.show_use_image))
	self.node_list["GrayUseButton"]:SetActive(self.show_use_button and (not self.show_on_look))
	self.node_list["BtnAdvance"]:SetActive(self.show_use_image and (not  self.show_on_look))
	self.node_list["TxtStartButton"].text.text = is_active and Language.MultiMount.Jinjie or Language.MultiMount.Active
	self.node_list["UpgradeTitleTxt"].text.text = is_active and Language.MultiMount.JinjieTitle or Language.MultiMount.ActiveTitle

	-- --该坐骑是否激活
	-- local content = ""
	-- if not is_active then
	-- 	local grade, name = MultiMountData.Instance:GetCurMountActiveCfg(index - 1)
	-- 	local name_color = ""
	-- 	local active_level = MultiMountData.Instance:GetCurMountActiveCfg(index)
	-- 	local is_mount_active = true
	-- 	if self.list_index == 1 then
	-- 		is_mount_active = true --第一个坐骑默认激活了。。。
	-- 	else
	-- 		local last_img_level = MultiMountData.Instance:GetMountLevelByIndex(index - 1)	--上一形象阶级
	-- 		name_color = "<color=" .. SOUL_NAME_COLOR[index - 1] .. ">" .. name .. "</color>"
	-- 		is_mount_active = last_img_level >= grade	--这里根据上一坐骑的阶数，来判断当前坐骑是否激活
	-- 	end
	-- 	content = is_mount_active and  string.format(Language.MultiMount.ActiveLevel, MultiMountData.Instance:GetBigGrade(index, active_level)) or
	-- 	string.format(Language.MultiMount.CanActive, name_color, MultiMountData.Instance:GetBigGrade(index - 1, grade))
	-- end

	-- self.node_list["TxtLimitText"].text.text = content
end

-- 物品不足，购买成功后刷新物品数量
function MultiMountView:ItemDataChangeCallback()
	local mount_info = MultiMountData.Instance:GetMountInfoByIndex(self.list_index)
	if nil == mount_info then return end

	local star_cfg = MultiMountData.Instance:GetMountCfgByIdAndLevel(self.list_index, mount_info.grade)
	if nil == star_cfg  then return end

	self:ShowJinJieDanNum(star_cfg.upgrade_stuff_id, star_cfg.upgrade_stuff_num)
	self:ShowGradeRedPoint(star_cfg.upgrade_stuff_id, star_cfg.upgrade_stuff_num, self.list_index)
end

-- 切换坐骑阶数、名字、模型
function MultiMountView:SwitchGradeAndName(index)
	if nil == index then return end
	local mount_grade_cfg = MultiMountData.Instance:GetMountInfoCfgByIndex(index)
	local mount_info = MultiMountData.Instance:GetMountInfoByIndex(index)
	if mount_grade_cfg == nil or mount_info == nil then return end

	local big_grade = CommonDataManager.GetDaXie(mount_info.grade) .. Language.Common.Jie
	self.mount_rank = big_grade
	self.mount_name = ToColorStr(mount_grade_cfg.mount_name, TEXT_COLOR.PURERED) 
	self.node_list["TxtRankAndName"].text.text = string.format("%s·%s", self.mount_rank, self.mount_name)

	if self.res_id ~= mount_grade_cfg.res_id and self:IsOpen() then
		UIScene:SetModelLoadCallBack(function(model, obj)
				model:SetTrigger(ANIMATOR_PARAM.REST)
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, -45, 0)
		end)
		local bundle, asset = ResPath.GetMountModel(mount_grade_cfg.res_id)
		PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
		local load_list = {{bundle, asset}}
		self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
				local bundle_list = {[SceneObjPart.Main] = bundle}
				local asset_list = {[SceneObjPart.Main] = asset}
				UIScene:ModelBundle(bundle_list, asset_list)
			end)
		
		self.res_id = mount_grade_cfg.res_id
	end
end

-- 设置进阶按钮状态
function MultiMountView:SetAutoButtonGray()
	local mount_info = MultiMountData.Instance:GetMountInfoByIndex(self.list_index)
	local max_grade = MultiMountData.Instance:GetMaxGradeByIndex(self.list_index)
	if nil == mount_info or nil == max_grade then
		return 
	end

	-- self.node_list["StarsList"]:SetActive(true)
	UI:SetButtonEnabled(self.node_list["StartButton"], true)
	if not mount_info or mount_info.grade >= max_grade then
		-- self.node_list["TxtAutoButton"].text.text = Language.MultiMount.YiManJie
		UI:SetButtonEnabled(self.node_list["StartButton"], false)
		self.node_list["TxtStartButton"].text.text = Language.MultiMount.MaxJie
		self.node_list["TxtMatNum"].text.text = "- / -"
		self.is_gray_upgrade_btn = true
		-- UI:SetButtonEnabled(self.node_list["AutoButton"], false)
		-- self.node_list["StarsList"]:SetActive(false)
		return
	end

	if self.is_auto then
		-- self.node_list["TxtAutoButton"].text.text = Language.MultiMount.Stop
		UI:SetButtonEnabled(self.node_list["StartButton"], false)
		self.is_gray_upgrade_btn = true
		-- UI:SetButtonEnabled(self.node_list["AutoButton"], true)
	else
		-- self.node_list["TxtAutoButton"].text.text = Language.Common.ZiDongJinJie
		UI:SetButtonEnabled(self.node_list["StartButton"], true)
		self.is_gray_upgrade_btn = false
		-- UI:SetButtonEnabled(self.node_list["AutoButton"], true)

	end
end

function MultiMountView:SetModle(is_show)
	if is_show then
		local used_imageid = MultiMountData.Instance:GetCurUseMountId()

		-- 还原到非预览状态
		self.is_on_look = false
		self.show_on_look = false
		self.node_list["GrayUseButton"]:SetActive(self.show_use_button and (not self.show_on_look))
		self.node_list["BtnAdvance"]:SetActive(self.show_use_image and (not self.show_on_look))

		self.list_index = self.list_index > 0 and self.list_index or used_imageid
		self:SwitchGradeAndName(self.list_index)
	else
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
		self.list_index = -1
		self.temp_grade = -1
		if self.node_list["EffectShowEffect"] then
			self.node_list["EffectShowEffect"]:SetActive(false)
		end
	end
end

function MultiMountView:ClearTempData()
	self.res_id = -1
	self.list_index = 1
	self.temp_grade = -1
	self.is_auto = false
end

function MultiMountView:ResetModleRotation()
	if self.foot_display ~= nil then
		self.foot_display.ui3d_display:ResetRotation()
	end
end

function MultiMountView:RemoveNotifyDataChangeCallBack()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	self.temp_grade = -1
	self.list_index = -1
	self.res_id = -1
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
end

function MultiMountView:OnAutoBuyToggleChange(isOn)

end

function MultiMountView:OpenCallBack()
	if self.node_list["EffectShowEffect"] then
		self.node_list["EffectShowEffect"]:SetActive(false)
	end

	self:Flush()

	local mount_info = MultiMountData.Instance:GetMountInfoByIndex(self.list_index)
	if mount_info then
		self.last_level = mount_info.grade
	end

end

function MultiMountView:FlushStars()
	local mount_info = MultiMountData.Instance:GetMountInfoByIndex(self.list_index)
	if nil == mount_info then
		return
	end

	-- 	local bundle_name, asset_name = ResPath.GetMiscEffect("Effect_baodian")
	-- 	EffectManager.Instance:PlayAtTransformCenter(bundle_name, asset_name, self.stars_list[index].transform, 1.0)
	-- end

	self.node_list["EffectHuanHuaBtn"]:SetActive(MultiMountData.Instance:CalcHuanHuaRemind() == 1)
end

function MultiMountView:OnFlush()
	if self.root_node.gameObject.activeSelf then
		self:SetMultiMountAtrr()
		self:FlushStars()
		self.node_list["MountList"].scroller:RefreshActiveCellViews()
	end
end

function MultiMountView:GetNumberOfCells()
	return math.max(MultiMountData.Instance:GetMaxIndex(), 4)
end

function MultiMountView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local star_cell = self.cell_list[cell]

	if star_cell == nil then
		star_cell = MultiMountItem.New(cell.gameObject)
		star_cell.root_node.toggle.group = self.node_list["MountList"].toggle_group
		star_cell.multi_mount_view = self
		self.cell_list[cell] = star_cell
	end
	star_cell:SetItemIndex(data_index)
	star_cell:SetData(MultiMountData.Instance:GetMountInfoCfgByIndex(data_index))
end

--显示进阶丹数量 当前拥有/本次消耗
function MultiMountView:ShowJinJieDanNum(stuff_item_id,expend_num)
	local bag_num = ItemData.Instance:GetItemNumInBagById(stuff_item_id)

	if bag_num < expend_num then
		local bag_num_str = string.format(Language.Mount.ShowRedNum,bag_num)
		self.node_list["TxtMatNum"].text.text = bag_num_str .. " / " .. tostring(expend_num)
		return
	end
	self.node_list["TxtMatNum"].text.text = bag_num .. " / " .. tostring(expend_num)
	local mount_info = MultiMountData.Instance:GetMountInfoByIndex(self.list_index)
	local max_grade = MultiMountData.Instance:GetMaxGradeByIndex(self.list_index)
	if not mount_info or mount_info.grade >= max_grade then
		self.node_list["TxtMatNum"].text.text = ToColorStr("- / -", TEXT_COLOR.WHITE)
	end
end

-- 显示可进阶按钮红点
function MultiMountView:ShowGradeRedPoint(stuff_item_id, expend_num, index)
	local bag_num = ItemData.Instance:GetItemNumInBagById(stuff_item_id)
	local is_can_jinjie = (1 == MultiMountData.Instance:GetMountCanJinJieByIndex(index))
	if nil == bag_num then return end

	if bag_num >= expend_num and not self.is_gray_upgrade_btn and is_can_jinjie then
		self.node_list["RedPointBtn"]:SetActive(true)
	else
		self.node_list["RedPointBtn"]:SetActive(false)
	end
end

function MultiMountView:UITween()
	UITween.MoveShowPanel(self.node_list["TopPanel"], Vector3(0, 95, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["BottomPanel"], Vector3(0, -310, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["Bottom"], Vector3(6, -420, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["MountInfo"], Vector3(70, -27.9, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["LeftContent"], Vector3(-200, -24, 0), 0.7)
	
end

---------------------MultiMountItem--------------------------------
MultiMountItem = MultiMountItem or BaseClass(BaseCell)

function MultiMountItem:__init()
	self.multi_mount_view = nil

	self.node_list["MultiMountItem"].toggle.onValueChanged:AddListener(BindTool.Bind(self.OnClickItem, self))
end

function MultiMountItem:__delete()
	self.multi_mount_view = nil
end

function MultiMountItem:SetItemIndex(index)
	self.item_index = index
end

function MultiMountItem:OnFlush()
	self:FlushHL()
	self.node_list["ImgLock"]:SetActive(self.data == nil)

	local is_active = MultiMountData.Instance:GetMountIsActiveByIndex(self.item_index)

	self.node_list["ImgShowRedPoint"]:SetActive(MultiMountData.Instance:MountCanJinjie(self.item_index))
	self.node_list["ImgIcon"].image:LoadSprite("uis/views/appearance/images_atlas", "multi_mount_head_" .. self.item_index .. ".png")
end

function MultiMountItem:OnClickItem(is_click)
	if is_click then
		local select_index = self.multi_mount_view:GetSelectIndex()
		if select_index == self.item_index then
			return
		end
		self.multi_mount_view:SetSelectIndex(self.item_index)
	end
end

function MultiMountItem:FlushHL()
	local select_index = self.multi_mount_view:GetSelectIndex()
	self.node_list["ImgSelectImage"]:SetActive(select_index == self.item_index)
end


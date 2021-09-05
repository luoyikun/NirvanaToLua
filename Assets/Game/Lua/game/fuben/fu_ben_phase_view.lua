-- 进阶
FuBenPhaseView = FuBenPhaseView or BaseClass(BaseRender)

local ROW_NUM = 5
local SAO_DANG_LEVEL_LIMIT = 350		-- 开启扫荡最低等级
local TOGGLE_NUM = 7
local PHASE_CLOSE_CHALLENGE_OPEN_DAY = 5
function FuBenPhaseView:__init(instance)
	self.layer = FuBenData.Instance:GetSelectLayer()
	self.cur_page = FuBenData.Instance:GetOpenCurPage(self.layer)
	self.node_list["ListView"].page_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.node_list["ListView"].page_simple_delegate.CellRefreshDel = BindTool.Bind(self.RefreshMountCell, self)
	self.node_list["ListView"].scroll_rect.onValueChanged:AddListener(BindTool.Bind(self.OnValueChanged, self))
	self.node_list["ListView"].page_view:Reload()

	self.node_list["BtnChouJiang"].button:AddClickListener(BindTool.Bind(self.OnClickChouJiang, self))
	self.node_list["BtnChallenge"].button:AddClickListener(BindTool.Bind(self.OnClickChallenge, self))
	self.node_list["BtnSaoDang"].button:AddClickListener(BindTool.Bind(self.OnClickSaoDang, self))
	self.node_list["BtnAdd"].button:AddClickListener(BindTool.Bind(self.OnClickAdd, self))
	self.node_list["BtnTips"].button:AddClickListener(BindTool.Bind(self.OnButtonHelp, self))

	local toggle_list_view = self.node_list["ListNameView"].list_simple_delegate
	toggle_list_view.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfToggleCells, self)
	toggle_list_view.CellRefreshDel = BindTool.Bind(self.RefreshToggleNameCell, self)
	self.node_list["ListView"].page_view:JumpToIndex(self.cur_page - 1)
	FuBenData.Instance:SetIsShowPhaseToggleRedPoint(1, 0)
	FuBenData.Instance:BindPlayerDataChange()

	self.list = {}
	self.guide_list = {}
	self.today_times_list = {}
	self.release_timer = {}
	self.toggle_list = {}

	self.fuben_cfg = {}
	self.fuben_info = {}

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.FuBen_JinJie)
end

function FuBenPhaseView:LoadCallBack()
	local left_time = FuBenData.Instance:GetLastTime()
	if left_time > 0 then
		local last_time = TimeUtil.FormatSecond(left_time, 16)
		self.node_list["TxtRestTime"].text.text = last_time
	end
end

function FuBenPhaseView:__delete()
	for k, v in pairs(self.list) do
		if v then
			v:DeleteMe()
		end
	end
	self.list = {}

	for k, v in pairs(self.guide_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.guide_list = {}

	for k,v in pairs(self.release_timer) do
		if v then
			GlobalTimerQuest:CancelQuest(v)
			v = nil
		end
	end
	if self.toggle_list then
		for k,v in pairs(self.toggle_list) do
			v:DeleteMe()
		end
	end
	if self.challenge_count_down then
		CountDown.Instance:RemoveCountDown(self.challenge_count_down)
		self.challenge_count_down = nil
	end
	self.release_timer = {}
	self.today_times_list = {}

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end	
end

function FuBenPhaseView:ShowIndex()
	FuBenData.Instance:SetIsShowPhaseToggleRedPoint(self.layer, 0)
end

function FuBenPhaseView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["BottomArea"], FuBenTweenData.PhaseDown)
	UITween.MoveShowPanel(self.node_list["ListNameView"], FuBenTweenData.PhaseUp)
end

function FuBenPhaseView:OnClickAdd()
	local ok_fun = function ()
		FuBenCtrl.Instance:SendGetPhaseFBInfoReq(PHASE_FB_OPERATE_TYPE.PHASE_FB_OPERATE_TYPE_BUY_TIMES, self.layer - 1)
		self:FlushEnterNum()
	end
	local data_fun = function ()
		local data = {}
		local buy_count = 0
		if self.fuben_info and self.fuben_info[self.layer - 1] then
			buy_count = self.fuben_info[self.layer - 1].today_buy_times
		end
		data[2] = buy_count or 0
		data[1] = FuBenData.Instance:GetPhaseFbResetGold(self.layer - 1) or 0
		data[3] = VipPower:GetParam(VipPowerId.fuben_phase_buy_times)
		data[4] = VipPower:GetParam(VipPowerId.fuben_phase_buy_times, true)
		return data
	end
	local data = data_fun()
	FuBenCtrl.Instance:ShowExpBuyTip(data[1], data[2], data[3], data[4], VipPowerId.fuben_phase_buy_times, ok_fun, data_fun)
end

function FuBenPhaseView:CloseCallBack()
	self.today_times_list = {}
end

function FuBenPhaseView:GetNumberOfToggleCells()
	-- local num = FuBenData.Instance:GetToggleNum() and FuBenData.Instance:GetToggleNum() or TOGGLE_NUM
	local num_list = FuBenData.Instance:GetOpenToggleNum()
	if num_list and #num_list > 0 then
		return #num_list
	end
	return 0
end

function FuBenPhaseView:OnValueChanged()
	local page = self.node_list["ListView"].page_view.ActiveCellsMiddleIndex + 1
	if self.cur_page ~= page then
		self.cur_page = page
		FuBenData.Instance:SetSelectCurPage(self.cur_page)
		for k, v in pairs(self.list) do
			if v.data then
				v:IsSelect(v.data.index == self.cur_page)
			end
		end
		self:Flush()
	end
end

function FuBenPhaseView:SelectItemCallback(cell)
	if cell == nil or cell.data == nil then return end
	self.node_list["ListView"].page_view:JumpToIndex(cell.data.index - 1, 0, 5 / #self.select_cfg_list)
end

function FuBenPhaseView:RefreshToggleNameCell(cell, data_index)
	data_index = data_index + 1
	local the_cell = self.toggle_list[cell]

	if the_cell == nil then
		the_cell = FuBenPhaseToggle.New(cell.gameObject)
		the_cell.node_list["Toggle_Layer"].toggle.group = self.node_list["ListNameView"].toggle_group
		the_cell.mother_view = self
		self.toggle_list[cell] = the_cell
	end
	local data = FuBenData.Instance:GetOpenToggleNum()
	the_cell:SetIndex(data_index)
	the_cell:SetData(data[data_index])
	the_cell:Flush()
end

function FuBenPhaseView:ClickToggleItem(index, is_click)
	if is_click then
		self.layer = index
		FuBenData.Instance:SetIsShowPhaseToggleRedPoint(index, 0)
		FuBenData.Instance:SetSelectLayer(self.layer)
		FuBenData.Instance:SetSelectCurPage(1)
		for k,v in pairs(self.toggle_list) do
			v:Flush()
		end
		self:Flush()
		local max_level = FuBenData.Instance:GetOpenCurPage(self.layer)
		self.node_list["ListView"].page_view:JumpToIndex(max_level - 1)
		self.node_list["ListView"].page_view:Reload()
	end
end

function FuBenPhaseView:GetNumberOfCells()
	if self.select_cfg_list then
		return #self.select_cfg_list
	end
	return 0
end


function FuBenPhaseView:OnButtonHelp()
	TipsCtrl.Instance:ShowHelpTipView(185)
end

-- 用于功能引导
function FuBenPhaseView:GetChallengeButton(index)
	return self.node_list["BtnChallenge"], BindTool.Bind(self.OnClickChallenge, self)
end

function FuBenPhaseView:RefreshMountCell(data_index, list)
	local fuben_list = self.list[list]
	if fuben_list == nil then
		fuben_list = PhaseFuBenListView.New(list.gameObject)
		self.guide_list[data_index] = fuben_list
		fuben_list:SetClickCallback(BindTool.Bind(self.SelectItemCallback, self))
		fuben_list:IsSelect(data_index + 1 == self.cur_page)
		self.list[list] = fuben_list
	end

	local data = {}
	if self.select_cfg_list and self.fuben_info and next(self.fuben_info) then
		local temp_list = self.select_cfg_list[data_index + 1]
		if temp_list then
			data.index = data_index + 1
			data.is_pass = self.fuben_info[self.layer - 1].is_pass
			data.today_use_times = self.fuben_info[self.layer - 1].today_times
			data.free_times = temp_list.free_times - data.today_use_times
			data.role_level = temp_list.role_level
			data.task_id = temp_list.open_task_id
			data.power = temp_list.zhanli or 0
			data.had_active = temp_list.role_level <= PlayerData.Instance:GetRoleLevel() and TaskData.Instance:GetTaskIsCompleted(data.task_id)
			data.no_active = temp_list.role_level > PlayerData.Instance:GetRoleLevel() or not TaskData.Instance:GetTaskIsCompleted(data.task_id)
			data.task_compelete = TaskData.Instance:GetTaskIsCompleted(data.task_id)

			data.small_image_name = temp_list.small_name_list
			data.fb_name = string.format(Language.FB.CurLevel, data_index + 1)
			data.fb_index = temp_list.fb_level - 1
			fuben_list:SetData(data, data_index + 1)
			fuben_list:SetIndex(data_index + 1)
			fuben_list:IsSelect(data_index + 1 == self.cur_page)
			local item_data = {}
			if data.is_pass <= data_index then
				for k,v in pairs(temp_list.first_reward) do
					if v then
						table.insert(item_data, v)
					end
				end
				fuben_list:SetItemCellData(item_data)
			else
				for k,v in pairs(temp_list.reset_reward) do
					if v then
						table.insert(item_data, v)
					end
				end
				fuben_list:SetItemCellData(item_data)
			end
		end
	end
end

function FuBenPhaseView:OnFlush(param_t)
	self:FlushFuBenList()
	self:FlushButtonActive()
	self:FlushEnterNum()
	self:FlushRestChallengeTime()
	self.node_list["ListNameView"].scroller:RefreshAndReloadActiveCellViews(true)
	for k, v in pairs(param_t) do
		if k == "task_fb_phase" then
			self:ClickToggleItem(tonumber(v[1]), true)
			return
		elseif k == "click_next" then
			local cur_page = FuBenData.Instance:GetOpenCurPage(self.layer)
			self.node_list["ListView"].page_view:JumpToIndex(cur_page - 1)
			return
		end
	end
end

function FuBenPhaseView:FlushRestChallengeTime()
	local cur_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local left_time = FuBenData.Instance:GetLastTime()
	if left_time < 0 then
		self.node_list["Bg"]:SetActive(false)
		FuBenData.Instance:SetIsNotClickFuBen(true)
		MainUICtrl.Instance:GetView():ShowXianShiChallenge()
		return
	end
	if nil == self.challenge_count_down then
		local diff_time = function(elapse_time, total_time)
			local time = math.floor(total_time - elapse_time + 0.5)
			local last_time = TimeUtil.FormatSecond(time, 16)
			if self.node_list and self.node_list["TxtRestTime"] then
				self.node_list["TxtRestTime"].text.text = last_time
			end
			if elapse_time >= total_time then
				self.node_list["TxtTimePanel"]:SetActive(false)
				if self.challenge_count_down then
					CountDown.Instance:RemoveCountDown(self.challenge_count_down)
					self.challenge_count_down = nil
				end
			end
		end
		self.challenge_count_down = CountDown.Instance:AddCountDown(left_time, 1, diff_time)
	end
end

function FuBenPhaseView:FlushEnterNum()
	if self.fuben_info and self.fuben_info[self.layer - 1] and self.fuben_cfg then
		self.enter_count = self.fuben_cfg.free_times + self.fuben_info[self.layer - 1].today_buy_times - self.fuben_info[self.layer - 1].today_times
		local total_times = self.fuben_cfg.free_times + self.fuben_info[self.layer - 1].today_buy_times
		local left_times_color = self.enter_count <= 0 and TEXT_COLOR.RED or TEXT_COLOR.GREEN
		local str = ToColorStr(self.enter_count, left_times_color) .. " / " .. total_times
		self.node_list["TxtRestNum"].text.text = string.format(Language.FuBen.LeaveCount, str)
	end
end

function FuBenPhaseView:FlushButtonActive()
	if self.fuben_info and next(self.fuben_info) and self.fuben_cfg then
		if self.fuben_info[self.layer - 1] then
			local max_num = self.fuben_info[self.layer - 1].today_buy_times + self.fuben_cfg.free_times
			local flag = self.fuben_info[self.layer - 1].today_times >= max_num
			local flag2 = self.fuben_info[self.layer - 1].is_pass >= self.fuben_cfg.fb_level
			local flag4 = self.fuben_info[self.layer - 1].is_pass+1 >= self.fuben_cfg.fb_level
			local flag3 = self.fuben_info[self.layer - 1].is_pass + 1 == self.cur_page
			local left_time = FuBenData.Instance:GetLastTime()
			local flag5 = left_time > 0
			UI:SetButtonEnabled(self.node_list["BtnChallenge"], flag3 and flag4 and flag5)
		end
		UI:SetButtonEnabled(self.node_list["BtnSaoDang"], false)
		for k,v in pairs(self.fuben_info) do
			if v and v.is_pass > 0 then
				UI:SetButtonEnabled(self.node_list["BtnSaoDang"], true)
				break
			end
		end
	end
	self:UpDateClearRedPoint()	
end

function FuBenPhaseView:RemindChangeCallBack(remind_name, num)
	if remind_name == RemindName.FuBen_JinJie then
		self:UpDateClearRedPoint()
	end
end

function FuBenPhaseView:UpDateClearRedPoint()
	if self.node_list and self.node_list["ClearRedPoint"] then
		local saodang_redpoint_num = FuBenData.Instance:GetSaoDangRedPointNum()
		if saodang_redpoint_num == 1 then
			self.node_list["ClearRedPoint"]:SetActive(true)
		else
			self.node_list["ClearRedPoint"]:SetActive(false)
		end
	end	
end

function FuBenPhaseView:OnClickSaoDang()
	FuBenData.Instance:SetClickSaoDang()
	self:UpDateClearRedPoint()
	if not FuBenData.Instance:GetIsInCommonScene() then
		SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.FuBenNotSaoDang)
		return
	end
	ViewManager.Instance:Open(ViewName.PhaseSaoDangView) 			--一键扫荡的
end

function FuBenPhaseView:FlushFuBenList()
	self.select_cfg_list = FuBenData.Instance:GetPhaseFBCfgByIndex(self.layer - 1)
	self.fuben_cfg = FuBenData.Instance:GetCurFbCfgByIndex(self.layer - 1, self.cur_page)
	self.fuben_info = FuBenData.Instance:GetPhaseFBInfo()
	if self.node_list["ListView"] then
		self.node_list["ListView"].page_view:Reload()
	end
end

function FuBenPhaseView:OnClickChallenge()
	if not self.fuben_info or not next(self.fuben_info) or not self.fuben_cfg then return end
	local cur_page = FuBenData.Instance:GetOpenCurPage(self.layer) or 0
	FuBenData.Instance:SetSelectCurPage(cur_page)
	PlayerPrefsUtil.SetInt("phaseindex", self.layer - 1)
	ViewManager.Instance:CloseAll()
	FuBenCtrl.Instance:SetPhaseLevle(self.fuben_cfg.fb_level)
	FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_PHASE, self.layer - 1)
end

function FuBenPhaseView:FlushView()

end

-- 转盘抽奖
function FuBenPhaseView:OnClickChouJiang()
	ViewManager.Instance:Open(ViewName.Welfare, TabIndex.welfare_goldturn)
end

---------------------------生成的列表--------------------------------
PhaseFuBenListView = PhaseFuBenListView or BaseClass(BaseRender)

function PhaseFuBenListView:__init(instance)
	self.item_cells = {}
	self.set_modle_time_quests = {}
	for i = 1, 2 do
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["Item"..i])
		self.item_cells[i] = item
	end
	self.node_list["ImgBg"].button:AddClickListener(BindTool.Bind(self.OnClickItem, self))
end

function PhaseFuBenListView:__delete()
	for k, v in pairs(self.item_cells) do
		v:DeleteMe()
	end
	self.item_cells = {}
end

function PhaseFuBenListView:ListenClick(handler)
	self.node_list["BtnEnter"].button:AddClickListener(handler)
end

function PhaseFuBenListView:GetChallengeButton()
	return self.node_list["BtnEnter"]
end

function PhaseFuBenListView:SetItemCellData(data)
	for k,v in pairs(self.item_cells) do
		if data[k] then
			v:SetParentActive(true)
			v:SetData(data[k])
		else
			v:SetParentActive(false)
		end
	end
end

function PhaseFuBenListView:SetClickCallback(handler)
	self.handler = handler
end

function PhaseFuBenListView:OnClickItem()
	if self.handler then
		self.handler(self)
	end
end

function PhaseFuBenListView:GetIndex()
	return self.index
end

function PhaseFuBenListView:SetIndex(index)
	self.index = index
end

function PhaseFuBenListView:IsSelect(value)
	self.node_list["RawImgSelect"]:SetActive(value)
end

function PhaseFuBenListView:GetData()
	return self.data or {}
end

function PhaseFuBenListView:SetData(data, data_index)
	if data == nil or data == "" then return end
	self.data = data
	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	self.node_list["FBNameTxt"].text.text = data.fb_name
	local power_col = data.power <= game_vo.capability and TEXT_COLOR.GREEN or TEXT_COLOR.RED
	self.node_list["regPowerTxt"].text.text = ToColorStr(data.power, power_col)

	if data.is_pass + 1 < data_index or not data.had_active then
		self.node_list["TextPlane"]:SetActive(true)
		self.node_list["regPower"]:SetActive(false)
	else
		self.node_list["TextPlane"]:SetActive(false)
		self.node_list["regPower"]:SetActive(true)
	end
	if data.is_pass >= data_index then
		self.node_list["ImgState"].image:LoadSprite("uis/views/fubenview/images_atlas", "defense_state_finish.png")
		self.node_list["TextReward"].text.text = Language.Dungeon.SweepingReward
	else
		self.node_list["ImgState"].image:LoadSprite("uis/views/fubenview/images_atlas", "defense_state_unopen.png")
		self.node_list["TextReward"].text.text = Language.Dungeon.AverageReward
	end
	-- local color = game_vo.level > data.role_level and TEXT_COLOR.GREEN or TEXT_COLOR.RED
	-- self.node_list["OpenText_1"].text.text = ToColorStr(string.format(Language.Dungeon.LevelUpto, data.role_level), color)
	local color1 = data_index == data.is_pass + 1 and TEXT_COLOR.GREEN or TEXT_COLOR.RED
	self.node_list["OpenText_2"]:SetActive(data_index ~= 1)
	self.node_list["OpenText_2"].text.text = ToColorStr(Language.Dungeon.HasPass, color1)
	if data_index == data.is_pass + 1 and data.had_active then
		self.node_list["ImgState"].image:LoadSprite("uis/views/fubenview/images_atlas", "defense_state_doing.png")
		self.node_list["TextReward"].text.text = Language.Dungeon.AverageReward
	end
	local bundle, asset = ResPath.GetFubenRawImage(data.small_image_name, data.small_image_name)
	self.node_list["ImgBg"].raw_image:LoadSprite(bundle, asset, function ()
		self.node_list["ImgBg"].raw_image:SetNativeSize()
	end)
end

-------------FuBenPhaseToggle----------------
FuBenPhaseToggle = FuBenPhaseToggle or BaseClass(BaseCell)
function FuBenPhaseToggle:__init()
	self.node_list["Toggle_Layer"].toggle.onValueChanged:AddListener(BindTool.Bind(self.ClickToggle, self))
end

function FuBenPhaseToggle:__delete()
end

function FuBenPhaseToggle:ClickToggle(isOn)
	if isOn then
		FuBenData.Instance:SetIsShowPhaseToggleRedPoint(self.data.fb_type, 0)
		self.mother_view:ClickToggleItem(self.data.fb_type, isOn)
	end
end

function FuBenPhaseToggle:OnFlush()
	if nil == self.data then
		return
	end
	local data = Language.FuBen.PhaseToggleName
	self.node_list["Txt_layer"].text.text = data[self.data.fb_type]
	self.node_list["Txt_hl"].text.text = data[self.data.fb_type]
	self.node_list["HL"]:SetActive(self.data.fb_type == self.mother_view.layer)
	self.node_list["Toggle_Layer"].toggle.interactable = not (self.data.fb_type == self.mother_view.layer)

	local fuben_cfg = FuBenData.Instance:GetCurFbCfgByIndex(self.data.fb_type - 1, 1)
	local fuben_info = FuBenData.Instance:GetPhaseFBInfo()
	if fuben_info and fuben_info[self.data.fb_type - 1] and fuben_cfg then
		local enter_count = fuben_cfg.free_times + fuben_info[self.data.fb_type - 1].today_buy_times - fuben_info[self.data.fb_type- 1].today_times
		local is_show = FuBenData.Instance:GetIsShowPhaseToggleRedPoint(self.data.fb_type)
		local is_pass = fuben_info[self.data.fb_type- 1].is_pass or 0
		self.node_list["RedPoint"]:SetActive(enter_count > 0 and is_show > 0 and is_pass <= 0)
		-- self.node_list["RedPoint"]:SetActive(false)
	end
end

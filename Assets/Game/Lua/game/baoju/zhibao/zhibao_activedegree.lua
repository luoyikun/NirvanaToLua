ZhiBaoActiveDegreeView = ZhiBaoActiveDegreeView or BaseClass(BaseRender)

local ListViewDelegate = ListViewDelegate
local CENTER_POINT_OFFSET = 60
function ZhiBaoActiveDegreeView:__init()
	self.cell_position_list = {}
	self:InitScroller()
	self.complete_call_back = BindTool.Bind(self.CompleteCallBack, self)

	local obj_group = self.node_list["ObjGroup"]
	local reward_group_long = obj_group.rect.rect.width
	self.rewards = {}
	local child_number = obj_group.transform.childCount
	local count = 1
	for i = 0, child_number - 1 do
		local obj = obj_group.transform:GetChild(i).gameObject
		if string.find(obj.name, "RewardsGroup") ~= nil then
			self.rewards[count] = ActiveDegreeRewardCell.New(obj)
			self.rewards[count].index = count - 1
			count = count + 1
		end
	end

	local max_value = ZhiBaoData.Instance:GetActiveDegreeLimit()
	local all_rewards = ZhiBaoData.Instance:GetActiveRewardInfo()

	for i = 1, #all_rewards do
		if self.rewards[i] ~= nil then
			self.rewards[i]:SetActive(true)
			local pos_x = (all_rewards[i].cfg.degree_limit / max_value) * reward_group_long
			local pos = self.rewards[i].root_node.rect.anchoredPosition3D
			pos.x = pos_x
			self.rewards[i].root_node.rect.anchoredPosition3D = pos
		else
			self.rewards[i]:SetActive(false)
		end
	end

	self.active_degree_limit = ZhiBaoData.Instance:GetActiveDegreeLimit()
	self:Flush()
end

function ZhiBaoActiveDegreeView:__delete()
	for k, v in pairs(self.rewards) do
		v:DeleteMe()
	end
	self.rewards = nil
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function ZhiBaoActiveDegreeView:OpenCallBack()
	GlobalTimerQuest:AddDelayTimer(function()
		self.arrow_index = 1
		self.node_list["Scroller"].scroller:ReloadData(0)
	end, 0)
end

function ZhiBaoActiveDegreeView:OnProtocolChange()
	self.scroller_data = ZhiBaoData.Instance:GetActiveDegreeScrollerData()
	self:Flush()
end

function ZhiBaoActiveDegreeView:CompleteCallBack()
	local active_degree_data = ZhiBaoData.Instance:GetActiveDegreeInfo()
	local now_value = self.node_list["SliderProgress02"].slider.value
	local next_value = now_value + self.interval_value
	self.node_list["SliderProgress02"].slider.value = next_value

	local next_total_degree = self.active_degree_limit * next_value
	next_total_degree = string.format("%.2f", next_total_degree)
	next_total_degree = math.ceil(next_total_degree)
	-- self.node_list["TxtSliderNumber"].text.text = string.format(Language.BaoJu.DegreeSliderNumber, next_total_degree..' / '..self.active_degree_limit)
	self.node_list["TxtSliderNumber"].text.text = next_total_degree
	if next_total_degree >= active_degree_data.total_degree then
		self.reward_data = ZhiBaoData.Instance:GetActiveRewardInfo()
		for i = 1, #self.rewards do
			self.rewards[i]:SetData(self.reward_data[i])
		end
	end
end

function ZhiBaoActiveDegreeView:Flush()
	local is_change = ZhiBaoData.Instance:GetIsChange()
	local start_fly_obj = ZhiBaoData.Instance:GetStartFlyObj()
	local active_degree_data = ZhiBaoData.Instance:GetActiveDegreeInfo()
	self.reward_data = ZhiBaoData.Instance:GetActiveRewardInfo()
	for i = 1, #self.rewards do
		if self.reward_data[i] and next(self.reward_data[i]) ~= nil then
			self.rewards[i]:SetActive(true)
			self.rewards[i]:SetData(self.reward_data[i])
		else
			self.rewards[i]:SetActive(false)
		end
	end
	--进度条
	-- self.node_list["TxtSliderNumber"].text.text = string.format(Language.BaoJu.DegreeSliderNumber, active_degree_data.total_degree..' / '..self.active_degree_limit)
	self.node_list["TxtSliderNumber"].text.text = active_degree_data.total_degree
	local value = active_degree_data.total_degree / self.active_degree_limit
	self.node_list["SliderProgress02"].slider.value = value

	if self.node_list["Scroller"] and self.node_list["Scroller"].scroller.isActiveAndEnabled then
		self.node_list["Scroller"].scroller:RefreshActiveCellViews()

		if is_change and start_fly_obj then
			local bundle_name, asset_name = ResPath.GetUiXEffect("UI_guangdian1")
			TipsCtrl.Instance:ShowFlyEffectManager(ViewName.BaoJu, bundle_name, asset_name, start_fly_obj, self.node_list["HandleSlideObj"], nil, 1)
		end
	end
end

function ZhiBaoActiveDegreeView:InitScroller()
	self.cell_list = {}
	self.scroller_data = ZhiBaoData.Instance:GetActiveDegreeScrollerData()

	-- 报错的，先屏蔽了，如果功能引导有用，再开出来修复吧
	-- self.node_list["Scroller"].scroller.scrollerScrolled = function ()
	-- 	local enum = self.node_list["Scroller"].scroller:GetPositionBeforeEnum()
	-- 	local half_rect_size = self.node_list["Scroller"].scroller.ScrollRectSize / 2

	-- 	for _, v in pairs(self.cell_list) do
	-- 		local index = v:GetIndex()
	-- 		local cell_position = self.node_list["Scroller"].scroller:GetScrollPositionForDataIndex(index, enum)
	-- 		local cell_height = v:GetHeight()
	-- 		local center_point = self.node_list["Scroller"].scroller.ScrollPosition + half_rect_size + 24
	-- 		center_point = math.ceil(center_point)
	-- 		cell_position = cell_position + cell_height/2
	-- 		self.cell_position_list[v] = cell_position
	-- 		local distance = cell_position - center_point
	-- 		if distance < 0 and distance > -75 then
	-- 			self.arrow_index = index
	-- 			self:FlushArrow()
	-- 		end
	-- 	end
	-- end

	local delegate = self.node_list["Scroller"].list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		return #self.scroller_data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		if nil == self.cell_list[cell] then
			self.cell_list[cell] = ActiveDegreeScrollCell.New(cell.gameObject)
			self.cell_list[cell].parent_view = self
			if data_index == 1 then
				self.guide_item = self.cell_list[cell]
			end
		end
		self.cell_list[cell]:SetIndex(data_index)
		self.cell_list[cell]:SetData(self.scroller_data[data_index])
		self:FlushArrow()
	end
end

-- 引导用
function ZhiBaoActiveDegreeView:GetGoToPanel()
	if self.guide_item then
		return self.guide_item:GetGoToPanel()
	end
end

function ZhiBaoActiveDegreeView:FlushArrow()
	for k,v in pairs(self.cell_list) do
		v:ShowArrow(v.index == self.arrow_index)
	end
end

----------------------------------------------------------------------------
--ActiveDegreeScrollCell 		活跃滚动条格子
----------------------------------------------------------------------------

ActiveDegreeScrollCell = ActiveDegreeScrollCell or BaseClass(BaseCell)
function ActiveDegreeScrollCell:__init(instance)

	self.node_list["BtnGo"].button:AddClickListener(BindTool.Bind(self.OnGetReward, self))
	self.node_list["BtnGet"].button:AddClickListener(BindTool.Bind(self.OnGetReward, self))
	self.have_go_to = true
	self.is_grey = false
	self.can_get = false
	self.items={}
	for i = 1, 2 do
		local item_obj = self.node_list["Item_"..i]
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(item_obj)
		self.items[i] = {item_obj = item_obj, item_cell = item_cell}
	end
	self.activity_time_change_callback = BindTool.Bind(self.HandleTime, self)
	WelfareData.Instance:NotifyWhenTimeChange(self.activity_time_change_callback)
end

function ActiveDegreeScrollCell:__delete()
	if WelfareData.Instance ~= nil then
		WelfareData.Instance:UnNotifyWhenTimeChange(self.activity_time_change_callback)
	end

	self.parent_view = nil

	for k, v in ipairs(self.items) do
		v.item_cell:DeleteMe()
	end
	self.items = {}
end

function ActiveDegreeScrollCell:OnFlush()
	local degree = ZhiBaoData.Instance:GetActiveDegreeListBySeq(self.data.show_seq) or 0
	local item_data = {}
	local exp = ZhiBaoData.Instance:GetExpRatio() * self.data.exp_factor_type
	table.insert(item_data, {item_id = ResPath.CurrencyToIconId.huoyue or 0,num=self.data.add_degree,is_bind = 0})
	table.insert(item_data, {item_id = ResPath.CurrencyToIconId.exp or 0,num=exp,is_bind = 0})
	for k,v in pairs(item_data) do
		if v then
			self.items[k].item_cell:SetData(v)
			self.items[k].item_obj:SetActive(true)
		end
	end
	self.node_list["TxtName"].text.text = self.data.act_name
	local bundle , asset = ResPath.GetActiveDegreeIcon(self.data.pic_id)
	self.node_list["ImgIcon"].image:LoadSprite(bundle, asset .. ".png", function()
		self.node_list["ImgIcon"].image:SetNativeSize()
	end)
	self.node_list["TxtTimes"].text.text = degree
	self.node_list["TxtTotalTimes"].text.text = self.data.max_times
	
	if degree >= self.data.max_times then
		self.is_grey = (1 == ZhiBaoData.Instance:GetRewardFetchFlag(self.data.type))
		self.node_list["BtnGo"]:SetActive(self.have_go_to and (not self.is_grey) and (not self.can_get))
		self.node_list["BtnGet"]:SetActive(self.can_get and (not self.is_grey))
		self.node_list["ImgHaveGet"]:SetActive(self.is_grey)
	else
		self.is_grey = false
		self.node_list["BtnGo"]:SetActive(self.have_go_to and (not self.is_grey) and (not self.can_get))
		self.node_list["BtnGet"]:SetActive(self.can_get and (not self.is_grey))
		self.node_list["ImgHaveGet"]:SetActive(self.is_grey)
	end

	if self.data.type == 0 then
		if degree >= self.data.max_times then
			self.node_list["TxtShowTime"]:SetActive(false)
			self.have_go_to = true
			self.node_list["BtnGo"]:SetActive(self.have_go_to and (not self.is_grey) and (not self.can_get))
			self.node_list["TxtGo"]:SetActive(self.have_go_to)
		else
			self.node_list["TxtShowTime"]:SetActive(true)
			self.have_go_to = false
			self.node_list["BtnGo"]:SetActive(self.have_go_to and (not self.is_grey) and (not self.can_get))
			self.node_list["TxtGo"]:SetActive(self.have_go_to)
		end
	else
		self.node_list["TxtShowTime"]:SetActive(false)
		self.have_go_to = true
		self.node_list["BtnGo"]:SetActive(self.have_go_to and (not self.is_grey) and (not self.can_get))
		self.node_list["TxtGo"]:SetActive(self.have_go_to)
	end

	if ZhiBaoData.Instance:GetActiveDegreeListByIndex(self.data.type) >= self.data.max_times then
		self.can_get = true
		self.node_list["BtnGo"]:SetActive(self.have_go_to and (not self.is_grey) and (not self.can_get))
		self.node_list["BtnGet"]:SetActive(self.can_get and (not self.is_grey))
	else
		self.can_get = false
		self.node_list["BtnGo"]:SetActive(self.have_go_to and (not self.is_grey) and (not self.can_get))
		self.node_list["BtnGet"]:SetActive(self.can_get and (not self.is_grey))
	end
end

function ActiveDegreeScrollCell:HandleTime()
	local hour, min, sec = WelfareData.Instance:GetOnlineTime()
	self.node_list["TxtShowTime"].text.text = string.format("%02d:%02d:%02d",hour,min,sec)
end

function ActiveDegreeScrollCell:OnGetReward()
	if ZhiBaoData.Instance:GetActiveDegreeListByIndex(self.data.type) >= self.data.max_times then
		ZhiBaoData.Instance:SetStartFlyObj(self.node_list["TargetObj"])
		ZhiBaoCtrl.Instance:SendGetActiveReward(FETCH_ACTIVE_REWARD_OPERATE_TYEP.FETCH_ACTIVE_DEGREE_REWARD, self.data.type)
	else
		self.OnGoClick(self.data)
	end
end

function ActiveDegreeScrollCell.OnGoClick(data)
	if nil == data then return end
	if data.goto_panel ~= "" then
		if data.goto_panel == "GuildTask" then
			local task_id = TaskData.Instance:GetRandomTaskIdByType(TASK_TYPE.GUILD)
			if task_id == nil or task_id == 0 then
				local vo = GameVoManager.Instance:GetMainRoleVo()
				if(vo.guild_id <= 0) then
					ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_request)
				else
					ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_info)
				end
				return
			end
			TaskCtrl.Instance:AutoDoTaskState(true)
			TaskCtrl.Instance:DoTask(task_id)
			ViewManager.Instance:Close(ViewName.BaoJu)
			return
		elseif data.goto_panel == "DailyTask" then
			local task_id = TaskData.Instance:GetRandomTaskIdByType(TASK_TYPE.RI)
			print("task_id:  "..task_id)
			if task_id == nil or task_id == 0 then
				TipsCtrl.Instance:ShowSystemMsg(Language.BaoJu.NotDailyTask)
				return
			end
			TaskCtrl.Instance:AutoDoTaskState(true)
			TaskCtrl.Instance:DoTask(task_id)
			ViewManager.Instance:Close(ViewName.BaoJu)
			return
		elseif data.goto_panel == "HuSong" then
			ViewManager.Instance:Close(ViewName.BaoJu)
			YunbiaoCtrl.Instance:MoveToHuShongReceiveNpc()
			return
		elseif data.goto_panel == "PaohuanTask" then
			local task_id = TaskData.Instance:GetRandomTaskIdByType(TASK_TYPE.HUAN)
			if task_id == nil or task_id == 0 then
				TipsCtrl.Instance:ShowSystemMsg(Language.BaoJu.NotDailyTask)
				return
			end
			TaskCtrl.Instance:AutoDoTaskState(true)
			TaskCtrl.Instance:DoTask(task_id)
			ViewManager.Instance:Close(ViewName.BaoJu)
			return
		end
		ViewManager.Instance:Close(ViewName.BaoJu)
		local t = Split(data.goto_panel, "#")
		local view_name = t[1]
		local tab_index = t[2]
		local seq = t[3] and t[3] or nil
		if view_name == "FuBen" then
			FuBenCtrl.Instance:SendGetPhaseFBInfoReq(PHASE_FB_OPERATE_TYPE.PHASE_FB_OPERATE_TYPE_INFO)
			FuBenCtrl.Instance:SendGetExpFBInfoReq()
			FuBenCtrl.Instance:SendGetStoryFBGetInfo()
			FuBenCtrl.Instance:SendGetVipFBGetInfo()
			FuBenCtrl.Instance:SendGetTowerFBGetInfo()
		elseif view_name == "Activity" then
			ActivityCtrl.Instance:ShowDetailView(ACTIVITY_TYPE[tab_index])
			return
		elseif view_name == "EnterScene" then
			GuajiCtrl.Instance:MoveToScene(tonumber(tab_index))
			return
		elseif view_name == "EnterAct" then
			local scene_type = Scene.Instance:GetSceneType()
			if scene_type ~= SceneType.Common or GuajiCtrl.Instance:IsSpecialCommonScene() then
				SysMsgCtrl.Instance:ErrorRemind(Language.Common.CannotFindPath)
				return
			end
			ActivityCtrl.Instance:SendActivityEnterReq(tab_index, 0)
			return
		elseif view_name == "Guild" then
			local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
			if guild_id < 1 then
				tab_index = "guild_request"
			end
		end
		if tab_index == "fb_team_tower" then 					-- 组队副本特殊处理一哈，
			if seq then
				if tonumber(seq) == 1 then
					FuBenData.Instance:SetDefaultChoose(ScoietyData.InviteOpenType.EquipTeamFbNew)
				elseif tonumber(seq) == 2 then
					FuBenData.Instance:SetDefaultChoose(ScoietyData.InviteOpenType.TeamTowerDefend)
				end
			end
			ViewManager.Instance:Open(view_name, TabIndex[tab_index])
		else
			ViewManager.Instance:Open(view_name, TabIndex[tab_index])
		end
	end
end

--引导用
function ActiveDegreeScrollCell:GetGoToPanel()
	return self.node_list["BtnGo"], BindTool.Bind(self.OnGetReward, self)
end

function ActiveDegreeScrollCell:ShowArrow(is_show)
	local degree = ZhiBaoData.Instance:GetActiveDegreeListBySeq(self.data.show_seq) or 0
	local is_show = is_show and degree < self.data.max_times and self.data.act_name ~= Language.BaoJu.OnLineTime
	self.node_list["ImgArrow"]:SetActive(is_show)
end

function ActiveDegreeScrollCell:GetHeight()
	return self.root_node.rect.rect.height
end
----------------------------------------------------------------------------
--ActiveDegreeRewardCell		活跃奖励格子
----------------------------------------------------------------------------

ActiveDegreeRewardCell = ActiveDegreeRewardCell or BaseClass(BaseCell)
function ActiveDegreeRewardCell:__init()
	self.item_cell = ItemCellReward.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
end

function ActiveDegreeRewardCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function ActiveDegreeRewardCell:OnFlush()
	if nil == self.data or nil == next(self.data) then
		return
	end
	self.item_cell:SetData(self.data.cfg.item)
	self.node_list["TxtValue"].text.text = self.data.cfg.degree_limit
	self.node_list["ImgGray"]:SetActive(self.data.flag)
	self.node_list["ImgHaveGot"]:SetActive(self.data.flag)
	self.node_list["ImgMask"]:SetActive(self.data.flag)
	if self.data.flag then
		--已领取
		self.node_list["EffectRedPoint"]:SetActive(false)
		self.item_cell:ClearItemEvent()
	else
		--未领取
		local degree_info =  ZhiBaoData.Instance:GetActiveDegreeInfo()
		local player_degree = degree_info.total_degree
		local click_func = nil
		if self.data.cfg.degree_limit <= player_degree then
			--可领取
			self.node_list["EffectRedPoint"]:SetActive(true)
			click_func = function()
			if nil == self.data then return end
			ZhiBaoCtrl.Instance:SendGetActiveReward(FETCH_ACTIVE_REWARD_OPERATE_TYEP.FETCHE_TOTAL_ACTIVE_DEGREE_REWARD, self.data.cfg.reward_index)
			AudioService.Instance:PlayRewardAudio()
			 	-- TipsCtrl.Instance:OpenGuildRewardView(self.data.cfg.item, nil, BindTool.Bind(self.SendReward, self))
			end
		else
			--不可领取
			self.node_list["EffectRedPoint"]:SetActive(false)
			click_func = function() TipsCtrl.Instance:OpenItem(self.data.cfg.item) end
		end
		self.item_cell:ListenClick(click_func)
	end
end

-- function ActiveDegreeRewardCell:SendReward()
-- 	if nil == self.data then return end
-- 	ZhiBaoCtrl.Instance:SendGetActiveReward(FETCH_ACTIVE_REWARD_OPERATE_TYEP.FETCHE_TOTAL_ACTIVE_DEGREE_REWARD, self.data.cfg.reward_index)
-- 	AudioService.Instance:PlayRewardAudio()
-- end

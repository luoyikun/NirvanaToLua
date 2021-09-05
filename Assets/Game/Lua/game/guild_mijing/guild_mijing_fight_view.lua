
GuildMijingFightView = GuildMijingFightView or BaseClass(BaseView)

function GuildMijingFightView:__init()
	self.ui_config = {{"uis/views/guildmijing_prefab","GuildMijingFightView"}}
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true						-- IphoneX适配
	self.active_close = false
	self.fight_info_view = true
end

function GuildMijingFightView:__delete()

end

function GuildMijingFightView:LoadCallBack()
	self.score_info = MijingScoreInfoView.New(self.node_list["ScorePerson"])
	-- self.shrink_button_toggle = self:FindObj("ShrinkButton").toggle
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE,
		BindTool.Bind(self.MianUIOpenComlete, self))

	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))


	self.rank_data_list = {}
	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)
	self.item_t = {}
end

function GuildMijingFightView:ReleaseCallBack()
	if self.score_info then
		self.score_info:DeleteMe()
		self.score_info = nil
	end

	if self.main_view_complete ~= nil then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end

	if self.skill_render then
		self.skill_render:DeleteMe()
		self.skill_render = nil
	end

	for k,v in pairs(self.item_t) do
		v:DeleteMe()
	end
	self.item_t = {}	
end

function GuildMijingFightView:OpenCallBack()
	MainUICtrl.Instance:SetViewState(false)
	-- self.node_list["NextTimeTips"]:SetActive(false)
	self.node_list["NextTime"]:SetActive(false)
	self.node_list["EndTime"]:SetActive(false)
	self:Flush()

	local loader = AllocAsyncLoader(self, "skill_button_loader")
	loader:Load("uis/views/guildmijing_prefab", "GuildMijingFightSkill", function (obj)
		if IsNil(obj) then
			return
		end

		MainUICtrl.Instance:ShowActivitySkill(obj)
		if nil == self.skill_render then
			self.skill_render = GuildMijingFightSkillRender.New(obj)
			self.skill_render:Flush()
		end
	end)

end

function GuildMijingFightView:CloseCallBack()
	MainUICtrl.Instance:SetViewState(true)
	GlobalTimerQuest:CancelQuest(self.next_countdown)

	MainUICtrl.Instance:ShowActivitySkill(false)
	if self.skill_render then
		self.skill_render:DeleteMe()
		self.skill_render = nil
	end
end

function GuildMijingFightView:MianUIOpenComlete()
	MainUICtrl.Instance:SetViewState(false)
	self:Flush()
end
function GuildMijingFightView:OnFlush(param_t)
	self.score_info:Flush()
	self:FlushRankView()
	for k,v in pairs(param_t) do
		if k == "mijing_info" then
			for k1,v1 in pairs(v) do
				local mijing_info = v1
				if 1 == mijing_info.is_finish then
					GlobalTimerQuest:CancelQuest(self.next_countdown)
					self:LeaveCountDown()
					local seconds = mijing_info.kick_role_time - TimeCtrl.Instance:GetServerTime()
					self.node_list["EndTime"]:SetActive(seconds > 0)
					if seconds > 0 then
						self.next_countdown = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.LeaveCountDown, self), 1)
					end
					return
				elseif mijing_info.notify_reason == GuildFbNotifyReason.WAIT and mijing_info.next_wave_time > 0 then
					GlobalTimerQuest:CancelQuest(self.next_countdown)
					local seconds = mijing_info.next_wave_time - TimeCtrl.Instance:GetServerTime()
					self.node_list["NextTime"]:SetActive(seconds > 0)
					if seconds > 0 then
						self:OpenNextWaveCountDown()
						self.next_countdown = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.OpenNextWaveCountDown, self), 1)
					end
				end
			end
		end
	end
end

function GuildMijingFightView:OpenNextWaveCountDown()
	local mijing_info = GuildMijingData.Instance:GetGuildMiJingSceneInfo()
	local seconds = math.floor(mijing_info.next_wave_time - TimeCtrl.Instance:GetServerTime())
	if seconds <= 0 then
		GlobalTimerQuest:CancelQuest(self.next_countdown)
		self.node_list["NextTime"]:SetActive(false)
		return
	end
	self.node_list["NextTimeTips"].text.text =  seconds
end

function GuildMijingFightView:LeaveCountDown()
	local mijing_info = GuildMijingData.Instance:GetGuildMiJingSceneInfo()
	local seconds = math.floor(mijing_info.kick_role_time - TimeCtrl.Instance:GetServerTime())
	if seconds <= 0 then
		GlobalTimerQuest:CancelQuest(self.next_countdown)
		self.node_list["EndTime"]:SetActive(false)
		return
	end
	self.node_list["EndText"].text.text =  seconds
end

function GuildMijingFightView:SwitchButtonState(enable)
	self.node_list["InfoPanel"]:SetActive(enable)
end


----------------------View----------------------
GuildMijingFightSkillRender = GuildMijingFightSkillRender or BaseClass(BaseRender)
function GuildMijingFightSkillRender:__init()
	
end

function GuildMijingFightSkillRender:__delete()

end

function GuildMijingFightSkillRender:LoadCallBack()
	self.node_list["BtnGuard"].button:AddClickListener(BindTool.Bind(self.FollowGuard, self))
	self.node_list["BtnConvene"].button:AddClickListener(BindTool.Bind(self.OnClickZhaoJi, self))
end

function GuildMijingFightSkillRender:FollowGuard()
	GuildMijingCtrl.SendGetGuildFBGuardPos()
end

function GuildMijingFightSkillRender:OnClickZhaoJi()
	local dec = Language.Guild.GuildShiLianStart
	ChatCtrl.SendChannelChat(CHANNEL_TYPE.GUILD, dec, CHAT_CONTENT_TYPE.TEXT)
	-- ViewManager.Instance:Open(ViewName.ChatGuild)
end

function GuildMijingFightSkillRender:OnFlush()
	local post = GuildData.Instance:GetGuildPost()
	local flag = post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG
	self.node_list["BtnConvene"]:SetActive(flag)
end	


----------------------View----------------------
MijingScoreInfoView = MijingScoreInfoView or BaseClass(BaseRender)
function MijingScoreInfoView:__init()
	self.item_cells = {}
	for i = 1, 3 do
		self.item_cells[i] = ItemCell.New()
		self.item_cells[i]:SetInstanceParent(self.node_list["Item"..i])
		self.item_cells[i]:SetActive(false)
	end
	self:Flush()
	self.hp_index = 1
end

function MijingScoreInfoView:__delete()
	for k, v in pairs(self.item_cells) do
		v:DeleteMe()
	end
	self.item_cells = {}
end

function MijingScoreInfoView:OnFlush()
	local mijing_info = GuildMijingData.Instance:GetGuildMiJingSceneInfo()
	local max_wave = #ConfigManager.Instance:GetAutoConfig("guildfb_auto").wave_cfg
	-- local wave_cfg = ListToMap(max_wave, "wave")
	local cur_wave = math.min((mijing_info.curr_wave + 1), max_wave)
	
	if cur_wave < max_wave then
		self.node_list["Kill"].text.text = "<color=#F9463BFF>" .. cur_wave .. "</color>/" .. max_wave
	else
		self.node_list["Kill"].text.text = cur_wave .. "/" .. max_wave
	end

	self.node_list["MyScore"].text.text = mijing_info.wave_enemy_count

	local rate = mijing_info.hp / mijing_info.max_hp
	if mijing_info.hp == 0 then
		rate = 0
	end
	local value = (rate - rate % 0.0001) * 100
	local guard_blood = (rate - rate % 0.0001) * 100 .. "%"
	self.node_list["RewardTxt"].text.text = guard_blood
	self.node_list["Progress"].slider.value =  (rate - rate % 0.0001)
	self.node_list["GFNodeEffect"]:SetActive(false)
		-- 如果hp值发生变化,则
	if self.hp_index ~= value then
		self.hp_index =  (rate - rate % 0.0001) * 100
		self.node_list["GFNodeEffect"]:SetActive(true)
	end
	if nil == self.wave_cfg then
		self.wave_cfg = ConfigManager.Instance:GetAutoConfig("guildfb_auto").wave_cfg
	end
	local reward_cfg = {}
	-- local gong_xian = 0
	local item_index = 0 				-- 从0开始
	for k, v in pairs(self.wave_cfg) do 
		if v.wave == cur_wave - 1 then
			reward_cfg = v.reward_item 
			-- gong_xian = v.reward_gongxian
			item_index = item_index + 1
		end
	end
	-- reward_cfg[item_index] = {item_id = ResPath.CurrencyToIconId.guild_gongxian or 0,num = gong_xian,is_bind = 0}
	if reward_cfg then
		local reward_count = 0
		self.item_data = {}
		for k, v in pairs(self.item_cells) do
			v:SetActive(false)
			if reward_cfg[k - 1] and reward_cfg[k - 1].item_id > 0 then
				reward_count = reward_count + 1
				v:SetActive(true)
				v:SetData(reward_cfg[k - 1])
				self.item_data[k] = reward_cfg[k - 1]
			end
		end
	end

	if ActivityData.Instance:GetActivityIsReady(ACTIVITY_TYPE.GUILD_SHILIAN) then
		self.node_list["GFNodeEffect"]:SetActive(false)
	end
end


function GuildMijingFightView:BagGetNumberOfCells()
	return #self.rank_data_list
end

function GuildMijingFightView:BagRefreshCell(cell, data_index, cell_index)
	local item = self.item_t[cell]
	if nil == item then
		item = GuildMijingRankItem.New(cell.gameObject)
		self.item_t[cell] = item
	end
	item:SetIndex(cell_index + 1)
	if self.rank_data_list[cell_index + 1] then
		item:SetData(self.rank_data_list[cell_index + 1])
	else
		item:SetData({name = "--", hurt = 0})
	end
end

function GuildMijingFightView:FlushRankView()
	self.rank_data_list = GuildMijingData.Instance:GetRankDataList()
	if self.node_list["ListView"].scroller.isActiveAndEnabled then
		self.node_list["ListView"].scroller:ReloadData(0)
	end

	local mijing_info = GuildMijingData.Instance:GetGuildMiJingSceneInfo()
	if mijing_info.my_rank_pos > 0 then
		self.node_list["shanghai"].text.text = CommonDataManager.ConverMoney2(mijing_info.my_hurt_val)  
		self.node_list["myrank"].text.text = string.format(Language.Guild.MJRank, mijing_info.my_rank_pos)
	else
		self.node_list["shanghai"].text.text = 0
		self.node_list["myrank"].text.text = string.format(Language.Guild.MJRank, 0)
	end
end

GuildMijingRankItem = GuildMijingRankItem or BaseClass(BaseRender)

function GuildMijingRankItem:__init()
end

function GuildMijingRankItem:SetIndex(index)
	if index <= 3 then
		local bundle, asset = ResPath.GetRankIcon(index)
		self.node_list["rank"]:SetActive(false)
		self.node_list["Img_rank"]:SetActive(true)
		self.node_list["Img_rank"].image:LoadSprite(bundle, asset)
	else
		self.node_list["Img_rank"]:SetActive(false)
		self.node_list["rank"]:SetActive(true)
		self.node_list["rank"].text.text = index
	end
end

function GuildMijingRankItem:SetData(data)
	self.data = data
	self:Flush()
end

function GuildMijingRankItem:OnFlush()
	if nil == self.data then
		return
	end
	self.node_list["name"].text.text = self.data.user_name
	self.node_list["score"].text.text = CommonDataManager.ConverMoney2(self.data.hurt_val)
end
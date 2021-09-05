CollectiveGoalsView = CollectiveGoalsView or BaseClass(BaseView)

INDEXTOACTIVITYID = {
	[1] = ACTIVITY_TYPE.QUNXIANLUANDOU,
	[2] = ACTIVITY_TYPE.GUILDBATTLE,
	[3] = ACTIVITY_TYPE.GONGCHENGZHAN,
	[4] = ACTIVITY_TYPE.CLASH_TERRITORY,
}
function CollectiveGoalsView:__init()
	self.ui_config = {{"uis/views/serveractivity/goals_prefab", "CollectiveGoalsView"}}
	self.full_screen = true								-- 是否是全屏界面
	self.play_audio = true
	self.cell_list = {}
	self.select_index = 1
	self.act_sep = 1
	self.active_countdown = nil
	self.is_fist_open = true
end

function CollectiveGoalsView:ReleaseCallBack()
	if self.role_model  then
		self.role_model:DeleteMe()
		self.role_model = nil
	end
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.reward_item then
		self.reward_item:DeleteMe()
		self.reward_item = nil
	end
	if self.active_countdown then
		GlobalTimerQuest:CancelQuest(self.active_countdown)
		self.active_countdown = nil
	end
	TitleData.Instance:ReleaseTitleEff(self.node_list["TitleImage"])
end

-- 切换标签调用
function CollectiveGoalsView:ShowIndexCallBack(index)
	local server_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	self:SelectIndex(server_open_day)
end

function CollectiveGoalsView:FistOpenCallBack()
	local bundle_name, asset_name = ResPath.GetMiscEffect("UI_ChengGongTongYong")
	TipsCtrl.Instance:OpenEffectView(bundle_name, asset_name, 1.5)
end

function CollectiveGoalsView:CloseCallBack()
	if self.active_countdown then
		GlobalTimerQuest:CancelQuest(self.active_countdown)
		self.active_countdown = nil
	end
end

function CollectiveGoalsView:LoadCallBack()
	self.effect_obj = nil
	self.is_load_effect = false

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnGetReward"].button:AddClickListener(BindTool.Bind(self.OnClickGetReward, self))
	self.node_list["BtnSkillNode"].button:AddClickListener(BindTool.Bind(self.OnClickSkill, self))
	self.node_list["BtnJumpTo"].button:AddClickListener(BindTool.Bind(self.OnClickJumpTo, self))

	self.role_model = RoleModel.New()
	self.role_model:SetDisplay(self.node_list["Display"].ui3d_display)
	
	self.rewart_item = {}
	local item = ItemCell.New()
	item:SetInstanceParent(self.node_list["RewardItem"])
	self.reward_item = item

	local list_delegate = self.node_list["BtnList"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.CellRefresh, self)
end

function CollectiveGoalsView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ZHENG_BA,
		RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_FETCH_BATTE_INFO)

	if self.active_countdown then
		GlobalTimerQuest:CancelQuest(self.active_countdown)
		self.active_countdown = nil
	end
	self.active_countdown = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateCountDown, self), 0.5)
	self:Flush()
end

function CollectiveGoalsView:OnFlush()
	local title_data = CollectiveGoalsData.Instance:GetTitleSingleCfg(self.act_sep)
	local goals_data = CollectiveGoalsData.Instance:GetGoalsSingleCfg(self.act_sep)

	self:FlushAllCell()
	if not title_data or not goals_data then return end

	self.node_list["TxtTopTitle"].text.text = goals_data.chapter_title
	self.node_list["TxtPlotDesc"].text.text = goals_data.chapter_describe
	self.node_list["TxtRewardTitle"].text.text = Language.CollectiveGoals.ChapterReward
	self.node_list["BtnJumpTo"]:SetActive(CollectiveGoalsData.Instance:IsShowJumpIcon(self.act_sep))

	local bundle, asset = ResPath.GetJumpIcon(self.act_sep)
	self.node_list["BtnJumpTo"].image:LoadSprite(bundle, asset)
	local bundle, asset = ResPath.GetTitleIcon(title_data.title_id)
	self.node_list["TitleImage"].image:LoadSprite(bundle, asset)
	TitleData.Instance:LoadTitleEff(self.node_list["TitleImage"], title_data.title_id, true)
	local bundle, asset = ResPath.GetSkillGoalsIcon(goals_data.skill_type)
	self.node_list["SkillIcon"].image:LoadSprite(bundle, asset)

	self:FlushBtn()
	-- 优先显示物品 有多个物品只显示第一个
	local reward_desc_str = string.format(Language.CollectiveGoals.GetWay, title_data.act_name, goals_data.complete_score)
	local skill_desc_str = ""
	if goals_data.is_has_reward == 1 then
		self.reward_item:SetData(goals_data.item_reward[0])
		self.node_list["RewardItem"]:SetActive(true)
		self.node_list["BtnSkillNode"]:SetActive(false)
		skill_desc_str = goals_data.skill_desc
	elseif goals_data.skill_type > 0 then
		self.node_list["RewardItem"]:SetActive(true)
		self.node_list["BtnSkillNode"]:SetActive(false)
		skill_desc_str = string.gsub(goals_data.skill_desc, "%b()%%", function (str)
			return (tonumber(goals_data[string.sub(str, 2, -3)]) / 100) .. "%"
		end)
		skill_desc_str = string.gsub(skill_desc_str, "%b[]%%", function (str)
			return goals_data[string.sub(str, 2, -3)] / 100 .. "%"
		end)
		skill_desc_str = string.gsub(skill_desc_str, "%[.-%]", function (str)
			return goals_data[string.sub(str, 2, -2)]
		end)
	end
	self.node_list["RewardDescText"].text.text = reward_desc_str
	self.node_list["RewardDuckText"].text.text = skill_desc_str
	self.node_list["DescTxt"].text.text = string.format(Language.CollectiveGoals.First, title_data.act_name)
	local role_info_list = KaifuActivityData.Instance:GetBattleRoleInfo()
	local single_role_info = role_info_list[self.act_sep]
	if not single_role_info then
		self.role_model:ClearModel()
		self.node_list["RoleNameTxt"].text.text = ""
		self.node_list["BlackImage"]:SetActive(true)
		return
	end
	self:SetRoleModelInfo(single_role_info)
	self.node_list["BlackImage"]:SetActive(false)
end

function CollectiveGoalsView:SetRoleModelInfo(role_info)
	self.role_model:SetModelResInfo(role_info, nil, nil, true)
	self.node_list["RoleNameTxt"].text.text = role_info.role_name
end

function CollectiveGoalsView:OnClickGetReward()
	local goals_data = CollectiveGoalsData.Instance:GetGoalsSingleCfg(self.act_sep)
	PersonalGoalsCtrl.Instance:SendRoleGoalOperaReq(PERSONAL_GOAL_OPERA_TYPE.FETCH_BATTLE_FIELD_GOAL_REWARD_REQ, goals_data.field_type)
	local can_get_flag = PersonalGoalsData.Instance:GetGolasRewardFlag()

	if can_get_flag and goals_data.skill_type ~= 0 then
		-- TipsCtrl.Instance:ShowOpenFunFlyView(nil, true, goals_data.skill_type)
	end
end

function CollectiveGoalsView:GetNumberOfCells()
	return #CollectiveGoalsData.Instance:GetActiveCfg()
end

function CollectiveGoalsView:CellRefresh(cell, data_index)
	data_index = data_index + 1
	local tmp_cell = self.cell_list[cell]
	if tmp_cell == nil then
		self.cell_list[cell] = CollectiveGoalsBtn.New(cell)
		tmp_cell = self.cell_list[cell]
		tmp_cell:SetParent(self)
	end
	local title_data = KaifuActivityData.Instance:GetBattleTitleCfg()
	local data = {}
	data.data_index = data_index
	data.act_seq = 0
	if title_data[data_index] then
		data.act_sep = title_data[data_index].act_sep
	end
	tmp_cell:SetData(data)
end

function CollectiveGoalsView:OnCellSelect(data_index, act_sep)
	self.select_index = data_index
	self.act_sep = act_sep
end

function CollectiveGoalsView:SelectIndex(data_index)
	self.select_index = data_index
	local title_data = KaifuActivityData.Instance:GetBattleTitleCfg()
	if title_data[data_index] then
		self.act_sep = title_data[data_index].act_sep
	end
end

function CollectiveGoalsView:GetCurSelectIndex()
	return self.select_index
end

function CollectiveGoalsView:FlushAllHL()
	for k,v in pairs(self.cell_list) do
		v:FlushHL()
	end
end

function CollectiveGoalsView:FlushAllCell()
	for k,v in pairs(self.cell_list) do
		v:Flush()
	end
end

function CollectiveGoalsView:UpdateCountDown()
	local str, _ = CollectiveGoalsData.Instance:GetNextTime()
	self.node_list["TopText"].text.text = str
	if str == "" then
		self.node_list["GoalImg"]:SetActive(false)
	end
end

function CollectiveGoalsView:FlushBtn()
	local goals_data = CollectiveGoalsData.Instance:GetGoalsSingleCfg(self.act_sep)
	local can_get_flag = PersonalGoalsData.Instance:GetGolasRewardFlag()
	local server_open_day = TimeCtrl.Instance:GetCurOpenServerDay()

	can_get_flag =  0 ~= bit:_and(can_get_flag, bit:_lshift(1, goals_data.field_type))
	local has_get_flag = PersonalGoalsData.Instance:GetGolasHasGetFlag()
	has_get_flag =  0 ~= bit:_and(has_get_flag, bit:_lshift(1, goals_data.field_type))
	UI:SetButtonEnabled(self.node_list["BtnGetReward"],can_get_flag and not has_get_flag)

	local brn_str = Language.CollectiveGoals.CanNotGet
	if can_get_flag and goals_data.open_server_day == server_open_day then
		brn_str = Language.CollectiveGoals.CanGet
	end
	if has_get_flag or goals_data.open_server_day < server_open_day then
		brn_str = Language.CollectiveGoals.HasGet
		UI:SetButtonEnabled(self.node_list["BtnGetReward"], false)
	end
	self.node_list["GetRewardText"].text.text = brn_str
end

function CollectiveGoalsView:OnClickSkill()

end

function CollectiveGoalsView:OnClickJumpTo()
	self:OpenView()
	self:Close()
end

function CollectiveGoalsView:OpenView()
	self:OpenActivityView(INDEXTOACTIVITYID[self.act_sep])
end

--打开活动面板
function CollectiveGoalsView:OpenActivityView(activity_type)
	if activity_type == ACTIVITY_TYPE.CLASH_TERRITORY then
		ViewManager.Instance:Open(ViewName.ClashTerritory)
	else
		ActivityCtrl.Instance:ShowDetailView(activity_type)
	end
end

------------------------------ CollectiveGoalsBtn -------------------------
CollectiveGoalsBtn = CollectiveGoalsBtn or BaseClass(BaseCell)
function CollectiveGoalsBtn:__init()
	self.node_list["TopTitleText"].text.text =
	self.node_list["BtnItem"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function CollectiveGoalsBtn:__delete()
	self.parent = nil
end

function CollectiveGoalsBtn:SetParent(parent)
	self.parent = parent
end

function CollectiveGoalsBtn:OnClick()
	if self.data.data_index <= TimeCtrl.Instance:GetCurOpenServerDay() then
		local select_index = self.parent:GetCurSelectIndex()
		if select_index == self.data.data_index then
			return
		end
		self.parent:OnCellSelect(self.data.data_index, self.data.act_sep)
		self.parent:FlushAllHL()
		self.parent:Flush()
		self:Flush()
	end
end

function CollectiveGoalsBtn:OnFlush()
	local title_data = CollectiveGoalsData.Instance:GetTitleSingleCfg(self.data.act_sep)
	local goals_data = CollectiveGoalsData.Instance:GetGoalsSingleCfg(self.data.act_sep)
	if not title_data or not goals_data then return end
	if self.data.data_index > TimeCtrl.Instance:GetCurOpenServerDay() then
		self.node_list["TopTitleText"].text.text = "????"
	else
		self.node_list["TopTitleText"].text.text = goals_data.chapter_title
	end
	self.node_list["RedPoint"]:SetActive(CollectiveGoalsData.Instance:GetRedPointBySeq(self.data.data_index))
	self:FlushHL()
end

function CollectiveGoalsBtn:FlushHL()
	local select_index = self.parent:GetCurSelectIndex()
	self.node_list["bg"]:SetActive(select_index == self.data.data_index)
	self.node_list["HL"]:SetActive(select_index == self.data.data_index)
	self.node_list["TextHL"]:SetActive(select_index == self.data.data_index)
	self.node_list["TopTitleText"]:SetActive(select_index == self.data.data_index)

end
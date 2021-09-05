YiZhanDaoDiView = YiZhanDaoDiView or BaseClass(BaseView)

function YiZhanDaoDiView:__init()
	self.ui_config = {{"uis/views/yizhandaodiview_prefab", "YiZhanDaoDiView"}}
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.rank_count = 0
	self.active_close = false 
	self.fight_info_view = true
	self.is_safe_area_adapter = true						-- IphoneX适配
end

function YiZhanDaoDiView:__delete()

end

function YiZhanDaoDiView:LoadCallBack()
	self.cell_list = {}

	self.node_list["BtnClickBuy"].button:AddClickListener(BindTool.Bind(self.OnClickBuy, self))
	self.node_list["RewardToggle"].toggle:AddClickListener(BindTool.Bind(self.OnClickReward, self))
	self.node_list["RankToggle"].toggle:AddClickListener(BindTool.Bind(self.OnClickRank, self))

	self.item_list = {}
	for i = 1,2 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self.node_list["Item" .. i])
	end
	self.kill_item_list = {}
	for i = 1,3 do
		self.kill_item_list[i] = ItemCell.New()
		self.kill_item_list[i]:SetInstanceParent(self.node_list["Item_" .. i])
	end

	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetRankNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshRankCell, self)
	local num = YiZhanDaoDiData.Instance:GetYiZhanDaoDiKillReward()
	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON, BindTool.Bind(self.SwitchButtonState, self))
end

function YiZhanDaoDiView:OpenCallBack()
	self.node_list["RewardToggle"].toggle.isOn = true
	self.rank_count = #YiZhanDaoDiData.Instance:GetYiZhanDaoDiRankInfo()
	self:Flush()
end

function YiZhanDaoDiView:CloseCallBack()
end

function YiZhanDaoDiView:ReleaseCallBack()
	if self.show_or_hide_other_button then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function YiZhanDaoDiView:SwitchButtonState(enable)
	self.node_list["PanelTombExploreInfoView"]:SetActive(enable)
end

function YiZhanDaoDiView:GetRankNumberOfCells()
	return #YiZhanDaoDiData.Instance:GetYiZhanDaoDiRankInfo()
end

function YiZhanDaoDiView:RefreshRankCell(cell, data_index)
	local group_cell = self.cell_list[cell]
	if group_cell == nil then
		group_cell = YiZhanDaoDiRankCell.New(cell.gameObject)
		self.cell_list[cell] = group_cell
	end

	local data = YiZhanDaoDiData.Instance:GetYiZhanDaoDiRankInfo()[data_index + 1]
	group_cell:SetData(data, data_index)
end

function YiZhanDaoDiView:OnClickBuy()
	local user_info = YiZhanDaoDiData.Instance:GetYiZhanDaoDiUserInfo()
	if nil == next(user_info) then return end

	local other_cfg = YiZhanDaoDiData.Instance:GetOtherCfg()
	if nil == other_cfg then return end

	if user_info.gongji_guwu_per >= other_cfg.gongji_guwu_max_per then
		TipsCtrl.Instance:ShowSystemMsg(Language.YiZhanDaoDi.MaxGuWu)
		return
	end

	local func = function()
		YiZhanDaoDiCtrl.Instance:SendYiZhanDaoDiGuwuReq(YIZHANDAODI_GUWU_TYPE.YIZHANDAODI_GUWU_TYPE_GONGJI)
	end
	local cost_gold = other_cfg.gongji_guwu_gold
	TipsCtrl.Instance:ShowCommonTip(func, nil, string.format(Language.YiZhanDaoDi.BuyGongJiTip, cost_gold), nil, nil, true, false, "buy_yzdd_gongji", false, "", "", false, nil, true, Language.Common.Cancel, nil, true)
end

function YiZhanDaoDiView:OnClickReward()
	self:SetRewardPanelInfo()
end

function YiZhanDaoDiView:OnClickRank()
	self:FlushRankList()
end

function YiZhanDaoDiView:FlushRankList()
	if self.node_list["ListView"].scroller.isActiveAndEnabled then
		if self.rank_count ~= #YiZhanDaoDiData.Instance:GetYiZhanDaoDiRankInfo() then
			self.node_list["ListView"].scroller:ReloadData(0)
		else
			self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
		end
	end
	local user_info = YiZhanDaoDiData.Instance:GetYiZhanDaoDiUserInfo()
	if nil == next(user_info) then return end
	local my_rankpos = YiZhanDaoDiData.Instance:GetMyRankPos()
	self.node_list["KillNum"].text.text = string.format(Language.YiZhanDaoDi.CurKill, user_info.jisha_count)
	self.node_list["Myrank"].text.text = string.format(Language.YiZhanDaoDi.RankPos, my_rankpos)
	self.node_list["ImgHasGot"]:SetActive(false)
end

function YiZhanDaoDiView:SetRewardPanelInfo()
	local user_info = YiZhanDaoDiData.Instance:GetYiZhanDaoDiUserInfo()
	if nil == next(user_info) then return end
	local my_rankpos = YiZhanDaoDiData.Instance:GetMyRankPos()
	-- self.node_list["KillNum"].text.text = string.format(Language.YiZhanDaoDi.CurKill, user_info.jisha_count)
	-- self.node_list["Myrank"].text.text = string.format(Language.YiZhanDaoDi.RankPos, my_rankpos)

	local is_in_rank, rank_index = YiZhanDaoDiData.Instance:IsUserInRank()
	local rank = is_in_rank and rank_index or Language.YiZhanDaoDi.NoInRank
	self.node_list["TxtRank"].text.text = string.format(Language.YiZhanDaoDi.CurRank, rank)

	local rank_reward_cfg = YiZhanDaoDiData.Instance:GetKillRankRewardCfg()
	if nil ~= rank_reward_cfg then
		local reward_cfg_index = is_in_rank and rank_index or YIZHANDAODI_RANK_NUM + 1
		local next_reward_cfg_index = is_in_rank and (rank_index - 1) or YIZHANDAODI_RANK_NUM

		if nil ~= rank_reward_cfg[reward_cfg_index] then
			local reward_item = rank_reward_cfg[reward_cfg_index].reward_item
			local item_cfg = ItemData.Instance:GetItemConfig(reward_item.item_id)
			if nil ~= item_cfg then
				-- self.node_list["TxtReward1"].text.text = string.format(Language.Common.ToColor, SOUL_NAME_COLOR[item_cfg.color], item_cfg.name.."*"..reward_item.num)
				self.item_list[1]:SetData(reward_item)
			end

			-- 下一排名奖励
			local next_reward_cfg = rank_reward_cfg[next_reward_cfg_index]
			if nil == next_reward_cfg then
				self.item_list[2]:SetActive(false)
				self.node_list["TxtReward2"].text.text = string.format(Language.YiZhanDaoDi.MaxRankReward)
				self.node_list["TxtReward2"]:SetActive(true)
			else
				local next_reward_item = next_reward_cfg.reward_item
				local next_item_cfg = ItemData.Instance:GetItemConfig(next_reward_item.item_id)
				self.node_list["TxtReward2"].text.text = ""
				if nil ~= next_item_cfg then
					-- self.node_list["TxtReward2"].text.text = string.format(Language.Common.ToColor, SOUL_NAME_COLOR[next_item_cfg.color], next_item_cfg.name .. "*" .. next_reward_item.num)
					self.item_list[2]:SetActive(true)
					self.item_list[2]:SetData(next_reward_item)
				end
			end
		end
	end
	self.node_list["TxtReward3"].text.text = string.format(Language.YiZhanDaoDi.AddGongJi, user_info.gongji_guwu_per)
	self.node_list["TxtScore"].text.text = string.format(Language.YiZhanDaoDi.Score, user_info.jisha_score)

	local other_cfg = YiZhanDaoDiData.Instance:GetOtherCfg() or {}
	self.node_list["TxtRestReliveTimes"].text.text = string.format(Language.YiZhanDaoDi.RealiveTimes, (other_cfg.dead_max_count or 0) - user_info.dead_count)
	local reward_cfg = YiZhanDaoDiData.Instance:GetKillNumReward()
	local index = YiZhanDaoDiData.Instance:GetShowRewardListNum() >= #reward_cfg and #reward_cfg or YiZhanDaoDiData.Instance:GetShowRewardListNum()
	if reward_cfg and reward_cfg[index] then
		if user_info.jisha_count >= reward_cfg[index].kill_count then
			self.node_list["TxtKillPeople"].text.text = string.format(Language.YiZhanDaoDi.KillText, user_info.jisha_count,reward_cfg[index].kill_count)
		else
			self.node_list["TxtKillPeople"].text.text = string.format(Language.YiZhanDaoDi.KillTextTwo, user_info.jisha_count,reward_cfg[index].kill_count)
		end
	else
		if reward_cfg and reward_cfg[#reward_cfg] then
			if user_info.jisha_count >= reward_cfg[index].kill_count then
				self.node_list["TxtKillPeople"].text.text = string.format(Language.YiZhanDaoDi.KillText, user_info.jisha_count,reward_cfg[index].kill_count)
			else
				self.node_list["TxtKillPeople"].text.text = string.format(Language.YiZhanDaoDi.KillTextTwo, user_info.jisha_count,reward_cfg[index].kill_count)
			end
		end
	end



	--self.node_list["ItemGroup"]:SetActive(index <= #reward_cfg)
	self.node_list["ImgHasGot"]:SetActive(index >= #reward_cfg and self.node_list["RewardToggle"].toggle.isOn)

	local reward_item = YiZhanDaoDiData.Instance:GetShowRewardList()
	for i = 1,3 do
		if reward_item and reward_item[i - 1] then
			self.kill_item_list[i]:SetData(reward_item[i - 1])
		else
			self.kill_item_list[i]:SetActive(false)
		end
	end
end

function YiZhanDaoDiView:OnFlush(param_t)
	if self.node_list["RewardToggle"].toggle.isOn then
		self:SetRewardPanelInfo()
	else
		self:FlushRankList()
	end
end


YiZhanDaoDiRankCell = YiZhanDaoDiRankCell or BaseClass(BaseRender)

function YiZhanDaoDiRankCell:__init(instance)
end

function YiZhanDaoDiRankCell:__delete()
end

function YiZhanDaoDiRankCell:SetData(data, rank_index)
	if nil == data then return end
	
	self.node_list["TxtRank"].text.text = rank_index + 1
	self.node_list["TxtName"].text.text = data.user_name
	self.node_list["TxtKillNum"].text.text = data.jisha_count
	if rank_index + 1 <= 3 then
		self.node_list["TxtRank"]:SetActive(false)
		self.node_list["RankImage"]:SetActive(true)
		local bundle, asset = ResPath.GetRankIcon(rank_index+1)
		self.node_list["RankImage"].image:LoadSprite(bundle, asset .. ".png")
		self.node_list["RankImage"].image:SetNativeSize()
	else
		self.node_list["TxtRank"]:SetActive(true)
		self.node_list["RankImage"]:SetActive(false)
	end
end
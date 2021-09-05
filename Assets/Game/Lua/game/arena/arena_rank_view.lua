ArenaRankView = ArenaRankView or BaseClass(BaseRender)
local RANK = {
	ONE = 1,
	TWO = 2,
	THREE = 3,
	TEN = 10,
}
local TWEEN_TIME = 0.5
function ArenaRankView:__init()
	self.cell_list = {}
	self.cur_page = 1
	self.max_page = 0
	self.select_rank = 1
	self.cur_player_info = nil
	self.item_list = {}

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFightPowerNum"])

	self.node_list["button_get"].button:AddClickListener(BindTool.Bind(self.FetchArenaRankReward, self))
	-- self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OpenArenaRankTips, self))
	self.node_list["BtnNextPage"].button:AddClickListener(BindTool.Bind(self.SwitchRankListPage, self,"next"))
	self.node_list["BtnLastPage"].button:AddClickListener(BindTool.Bind(self.SwitchRankListPage, self,"last"))
	-- self.node_list["BtnPreviewButton"].button:AddClickListener(BindTool.Bind(self.OpenPreview, self,"last"))

	local list_delegate = self.node_list["list_view"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.node_list["list_view"].scroller.scrollerScrolled = BindTool.Bind(self.ScrollerScrolledDelegate, self)
	self.node_list["list_view"].scroller:ReloadData(0)

	for i=1,2 do 		--本来两个奖励，礼包被干掉了
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self.node_list["Item" .. i])
	end

	self.show_reward_item = ItemCell.New()
	self.show_reward_item:SetInstanceParent(self.node_list["Show_Reward_Item"])

	local start_pos = Vector3(0 , -30 , 0)
	local end_pos = Vector3(0 , 0 , 0)
	UITween.MoveLoop(self.node_list["ImgTitle"], start_pos, end_pos, 1, MOVE_LOOP)
	UITween.MoveLoop(self.node_list["Show_Reward_Item"], start_pos, end_pos, 1, MOVE_LOOP)
	-- local cfg =ConfigManager.Instance:GetAutoConfig("challengefield_auto").other[1]
	-- self.default_reward = {cfg.reward_item1, cfg.reward_item2, cfg.reward_item3}

	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	local other_cfg = ConfigManager.Instance:GetAutoConfig("challengefield_auto").other[1]
	if nil ~= other_cfg then
		self.first_wing_id = other_cfg.first_wing_id
	end
	local res_id = 0
	for k, v in pairs(WingData.Instance:GetSpecialImagesCfg()) do
		if v.item_id == self.first_wing_id then
			res_id = v.res_id
			break
		end
	end
	local bundle, asset = ResPath.GetWingModel(res_id)
	self.node_list["Display"]:SetActive(false)
	self.model:SetMainAsset(bundle, asset, function()
		self.node_list["Display"]:SetActive(true)
		self.model:SetTrigger("action")
		end )
	-- self.model:SetGoddessWingNeedAction(false)


end

function ArenaRankView:LoadCallBack()

end

function ArenaRankView:__delete()
	self.fight_text = nil
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if nil ~= self.model then
		self.model:DeleteMe()
		self.model = nil
	end


	self.item_list = {}
	self.show_reward_item = nil
	self.name = nil
	self.zhanli_text = nil
	self.rank_desc = nil
	self.list_view = nil
	self.list_view2 = nil
	self.display = nil
	self.page_index = nil
	self.cur_page = 1
	self.max_page = 0
	self.cur_player_info = nil
	self.can_get = nil
	self.show_title = nil
	if self.role_info then
		self.role_info = nil
	end

	if self.day_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.day_count_down)
		self.day_count_down = nil
	end
	TitleData.Instance:ReleaseTitleEff(self.node_list["ImgTitle"])
end

function ArenaRankView:OpenCallBack()
	ArenaCtrl.Instance:ReqFieldGetRankInfo()
	self:SetReMainTime()
	self:Flush()
end

function ArenaRankView:CloseCallBack()

end

function ArenaRankView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["ListFrame"], Vector3(430, -28, 0) , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["Left"], Vector3(-244, 14, 0) , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end

function ArenaRankView:FetchArenaRankReward()
	ArenaCtrl.Instance:ResetGetGuangHuiReward()
	UI:SetButtonEnabled(self.node_list["button_get"], ArenaData.Instance:GetIsCanFetchRankReward())
	self:Flush()
end

function ArenaRankView:SwitchRankListPage(key)
	if "next" == key then
		self.cur_page = self.cur_page + 1
	elseif "last" == key then
		self.cur_page = self.cur_page - 1
	end

	self.max_page = ArenaData.Instance:GetArenaRankListMaxPage()
	if self.cur_page < 1 then
		self.cur_page = 1
		return
	elseif self.cur_page > self.max_page then
		self.cur_page = self.max_page
		return
	end
	self.node_list["list_view"].scroller:ReloadData(0)
	self:Flush()
end

function ArenaRankView:GetNumberOfCells()
	return ArenaData.Instance:GetCurRankItemNumByIndex(self.cur_page)
end

function ArenaRankView:RefreshCell(cell, cell_index)
	local the_cell = self.cell_list[cell]
	if the_cell == nil then
		the_cell = ArenaRankCell.New(cell.gameObject, self)
		self.cell_list[cell] = the_cell
		the_cell:SetToggleGroup(self.node_list["list_view"].toggle_group)
	end
	cell_index = (self.cur_page - 1) * 5 + cell_index + 1
	the_cell:SetRank(cell_index)
	the_cell:Flush()
end

function ArenaRankView:ScrollerScrolledDelegate(go, param1, param2, param3)
	if self.is_cell_active and self.jump_flag == true then
		self:CheckToJump()
	end
end

function ArenaRankView:OnFlush()
	local max_page = ArenaData.Instance:GetArenaRankListMaxPage()
	if self.node_list["TxtPageIndex"] ~= nil then
		self.node_list["TxtPageIndex"].text.text = self.cur_page .. "/" .. max_page
	end
	
	if self.node_list["list_view"] ~= nil then
	self.node_list["list_view"].scroller:ReloadData(0)
	end

	if self.node_list["button_get"] ~= nil then
		UI:SetButtonEnabled(self.node_list["button_get"], ArenaData.Instance:GetIsCanFetchRankReward())
	end
	self:FlushAllHL()
end

function ArenaRankView:SetListViewCallBack(data)
	-- if data.rank <= RANK.TEN then
		self.node_list["Item1"]:SetActive(false)
		-- self.node_list["Item2"]:SetActive(true)
		self.node_list["DisplayTitleModel"]:SetActive(true)
	-- else
		-- self.node_list["TxtRoleName"].text.text = string.format(Language.Field1v1.PreviewRewardDesc2, Language.Field1v1.PreviewDesc2[data.rank - 10])
		-- self.node_list["DisplayTitleModel"]:SetActive(false)
	-- end
	self.node_list["TxtRoleName"].text.text = string.format(Language.Field1v1.PreviewRewardDesc, data.rank)
	local user_info = ArenaData.Instance:GetUserInfo()
	local flag = data.rank
	local server_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local cfg = ArenaData.Instance:GetRankRewardData(server_open_day)
	if user_info ~= nil then
		self.node_list["txt_my_rank"].text.text = string.format(Language.Field1v1.MyRank, user_info.rank)
		local my_rank = user_info.rank - 1
		for k, v in pairs(cfg) do
			if my_rank >= v.min_rank_pos and my_rank <= v.max_rank_pos then
				self.node_list["Item2"]:SetActive(true)
				if self.item_list[2] then
					self.item_list[2]:SetData(v.reward_show[0])
				end
			end
		end
	end

	for k, v in pairs(cfg) do
		if data.rank >= v.min_rank_pos and data.rank <= v.max_rank_pos then
			flag = k - 1
		end
	end

	self.select_rank = data.rank
	self:FlushAllHL()
	self.node_list["DisplayObj"]:SetActive(self.select_rank <= 3)
	local text_index = 1
	if self.select_rank <= 3 then
		text_index = self.select_rank
	elseif self.select_rank <= 10 and self.select_rank > 3 then
		text_index = 4
	elseif self.select_rank <= 20 and self.select_rank > 10 then
		text_index = 5
	elseif self.select_rank <= 50 and self.select_rank > 20 then
		text_index = 6
	else
		text_index = 7
	end
	self.node_list["Txt_desc"].text.text = Language.Arena.DescGroup[text_index]
	local zhanli = 0
	-- if self.select_rank <= RANK.TEN then
		self.node_list["ZhanLiFrame"]:SetActive(true)
		self.node_list["Show_Reward_Item_Obj"]:SetActive(false)
		self.node_list["Txt_GetHunYu"]:SetActive(false)
		if self.select_rank <= 3 then
			if self.first_wing_id ~= nil then
				zhanli = ItemData.GetFightPower(self.first_wing_id)
			end
		end

		local title_id = ArenaData.Instance:GetTitleID(data.rank - 1)
		if title_id ~= nil then
			local cfg2 = TitleData.Instance:GetTitleCfg(title_id)
			zhanli = zhanli + CommonDataManager.GetCapabilityCalculation(cfg2)
			local bundle, asset = ResPath.GetArenaRankBigTitle(title_id)
			local func = function()
				local child_node = self.node_list["ImgTitle"].transform:GetChild(0)
				if child_node and child_node.gameObject then
					child_node.gameObject.transform.localScale = Vector3(1.5, 1.5, 1.5)
				end
			end
			self.node_list["ImgTitle"].image:LoadSprite(bundle, asset, function() 
				TitleData.Instance:LoadTitleEff(self.node_list["ImgTitle"], title_id, true, func)
					end)
		end
	-- else
	-- 	self.node_list["Show_Reward_Item_Obj"]:SetActive(true)
	-- 	self.node_list["Txt_GetHunYu"]:SetActive(true)
	-- 	if cfg[flag] ~= nil and cfg[flag].reward_show[0] ~= nil then
	-- 		self.show_reward_item:SetData(cfg[flag].reward_show[0])
	-- 		self.node_list["Txt_GetHunYu"].text.text = Language.Field1v1.RewardTxt
	-- 	else
	-- 		self.show_reward_item:SetData(cfg[flag].reward_item[0])
	-- 		self.node_list["Txt_GetHunYu"].text.text = Language.Field1v1.RewardTxt2
	-- 	end
	-- 	self.node_list["ZhanLiFrame"]:SetActive(false)
	-- end
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = zhanli
	end
end

function ArenaRankView:SetReMainTime()
	local cur_time = TimeCtrl.Instance:GetServerTime()
	local server_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local sever_day = ArenaData.Instance:GetArenaViewOpenSeverDay()
	local differ_day = sever_day - server_open_day
	local str = os.date("%X", cur_time)
	local time_tab = Split(str, ":")
	local time = tonumber(time_tab[1]) * 3600 + tonumber(time_tab[2]) * 60 + tonumber(time_tab[3])
	local diff_time = 86400 * differ_day + 22 * 3600 - time
	if self.day_count_down == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				self.node_list["bg_time"]:SetActive(false)
				self.node_list["refresh_tips"].text.text = ""
				if self.day_count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.day_count_down)
					self.day_count_down = nil
				end
				return
			end
			local time_str = TimeUtil.FormatSecond(left_time, 17)
			self.node_list["bg_time"]:SetActive(true)
			self.node_list["refresh_tips"].text.text = string.format(Language.Arena.ArenaRankRewardEnd, time_str)
		end

		diff_time_func(0, diff_time)
		self.day_count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end

function ArenaRankView:FlushAllHL()
	for k,v in pairs(self.cell_list) do
		v:FlushHL(self.select_rank)
	end
end

----------------------------------------------------
ArenaRankCell = ArenaRankCell or BaseClass(BaseCell)

function ArenaRankCell:__init(instance, parent)
	self.parent = parent
	self.rank = 0
	self.is_click = false
	self.node_list["RankItem"].toggle.onValueChanged:AddListener(BindTool.Bind(self.ToggleClick, self))
end

function ArenaRankCell:__delete()
	self.parent = nil
end

function ArenaRankCell:SetRank(rank)
	self.rank = rank
end

function ArenaRankCell:OnFlush()
	self.root_node.gameObject:SetActive(true)
	local rank_data = ArenaData.Instance:GetArenaRankInfo() or {}
	local server_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local cfg = ArenaData.Instance:GetRankRewardData(server_open_day)
	local flag = self.rank
	for k, v in pairs(cfg) do
		if self.rank >= v.min_rank_pos and self.rank <= v.max_rank_pos then
			flag = k
		end
	end

	self.rank_info = rank_data[self.rank]
	if self.rank_info == nil then
		self.root_node.gameObject:SetActive(false)
		return
	end

	if self.rank <= RANK.THREE then
		self.node_list["ImgRankImage"]:SetActive(true)
		local bundle, asset = ResPath.GetRankIcon(self.rank)
		self.node_list["ImgRankImage"].image:LoadSprite(bundle, asset)
		local bundle1, asset1 = ResPath.GetArenaRankbg(self.rank)
		self.node_list["Img_rank_item_bg"]:SetActive(true)
		self.node_list["Img_rank_item_bg"].image:LoadSprite(bundle1, asset1)
	else
		self.node_list["TxtRank"].text.text = self.rank
		self.node_list["ImgRankImage"]:SetActive(false)
		self.node_list["Img_rank_item_bg"]:SetActive(false)
	end

	local data = cfg[flag]
	if data == nil then
		data = {reward_guanghui = 0}
	end
	if self.rank_info then
		-- if self.rank <= RANK.TEN then
			self.node_list["Txt_Reward"].text.text = data.reward_guanghui
			self.node_list["TxtName"].text.text = self.rank_info.target_name
			self.node_list["TxtRankValue"].text.text = self.rank_info.capability
			self.node_list["TxtRank"].text.text = self.rank
		-- else
		-- 	self.node_list["TxtName"].text.text = Language.Field1v1.PreviewDesc2[self.rank - 10]
		-- 	self.node_list["TxtRankValue"].text.text = 0
		-- 	self.node_list["TxtRank"].text.text = ""
		-- 	self.node_list["Txt_Reward"].text.text = data.reward_guanghui
		-- end
		if not self.is_click then
			self.parent:SetListViewCallBack(rank_data[self.parent.cur_page * 5 - 4])
		end
	end
end

function ArenaRankCell:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function ArenaRankCell:ToggleClick(is_click)
	self.is_click = true
	if is_click then
		if self.rank_info == nil  then return end
		self.parent:SetListViewCallBack(self.rank_info)
	end
end

function ArenaRankCell:FlushHL(index)
	self.node_list["ImgHightLight"]:SetActive(index == self.rank)
end
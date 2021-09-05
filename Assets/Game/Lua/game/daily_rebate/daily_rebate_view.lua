DailyRebateView = DailyRebateView or BaseClass(BaseView)

function DailyRebateView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelTwo_1"},
		{"uis/views/dailyrebate_prefab","DailyRebateView"},
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelTwo_2"},
	}
	self.full_screen = false
	self.play_audio = true

	self.is_modal = true
	
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function DailyRebateView:__delete()
end

function DailyRebateView:ReleaseCallBack()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	for k, v in pairs(self.top_cell_list) do
		v:DeleteMe()
	end
	self.top_cell_list = nil

	for k, v in pairs(self.down_cell_list) do
		v:DeleteMe()
	end
	self.down_cell_list = nil
	self.fight_text = nil

end

function DailyRebateView:LoadCallBack()
	self.model = RoleModel.New("daily_rebate_panel")
	self.model:SetDisplay(self.node_list["Display"].ui3d_display)

	self.top_cell_list = {}
	self.top_list_data = DailyRebateData.Instance:GetRareRewardCfg()
	local top_scroller_delegate = self.node_list["TopListView"].list_simple_delegate
	self.top_cell_size = top_scroller_delegate:GetCellViewSize(self.node_list["TopListView"].scroller, 0)						--单个cell的大小（根据排列顺序对应高度或宽度）
	self.top_list_view_spacing = self.node_list["TopListView"].scroller.spacing										--间距
	top_scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.TopListNumberOfCell, self)
	top_scroller_delegate.CellRefreshDel = BindTool.Bind(self.TopListCellRefresh, self)

	self.down_cell_list = {}
	self.down_list_data = DailyRebateData.Instance:GetDayRewardCfg()
	local down_scroller_delegate = self.node_list["DownListView"].list_simple_delegate
	self.down_cell_size = down_scroller_delegate:GetCellViewSize(self.node_list["DownListView"].scroller, 0)					--单个cell的大小（根据排列顺序对应高度或宽度）
	self.down_list_view_spacing = self.node_list["DownListView"].scroller.spacing										--间距
	down_scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.DownListNumberOfCell, self)
	down_scroller_delegate.CellRefreshDel = BindTool.Bind(self.DownListCellRefresh, self)

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["PowerTxt"])
end

function DailyRebateView:CloseWindow()
	self:Close()
end

function DailyRebateView:TopListNumberOfCell()
	return #self.top_list_data
end

function DailyRebateView:TopListCellRefresh(cell, data_index)
	data_index = data_index + 1
	local top_cell = self.top_cell_list[cell]
	if top_cell == nil then
		top_cell = DailyRebateTopCell.New(cell.gameObject)
		self.top_cell_list[cell] = top_cell
	end

	top_cell:SetIndex(data_index)
	top_cell:SetData(self.top_list_data[data_index])
end

function DailyRebateView:DownListNumberOfCell()
	return #self.down_list_data
end

function DailyRebateView:DownListCellRefresh(cell, data_index)
	data_index = data_index + 1
	local down_cell = self.down_cell_list[cell]
	if down_cell == nil then
		down_cell = DailyRebateDownCell.New(cell.gameObject)
		self.down_cell_list[cell] = down_cell
	end

	down_cell:SetIndex(data_index)
	down_cell:SetData(self.down_list_data[data_index])
end

function DailyRebateView:OpenCallBack()
	self.is_first = true
	self.model_item_id = 0
	self:Flush()
end

function DailyRebateView:CloseCallBack()

end

function DailyRebateView:FlushModel()
	local chongzhi_day = DailyRebateData.Instance:GetChongZhiDay()
	local cfg = DailyRebateData.Instance:GetNextModelRewardCfgInfo(chongzhi_day)
	if cfg == nil then
		return
	end

	if self.model_item_id == cfg.model_item_id then
		return
	end
	self.model_item_id = cfg.model_item_id

	self.model:ResetRotation()
	ItemData.ChangeModel(self.model, self.model_item_id)
	if self.model_item_id == 24957 then
		self.model:SetRotation(Vector3(0, -30, 0))
	end
end

function DailyRebateView:ForceJumpIndex(index, list, cell_size, list_space, list_data)
	local list_view_size = list.rect.rect.width
	local max_size = (cell_size + list_space) * #list_data - list_space
	local not_see_size = math.max(max_size - list_view_size, 0)
	local bili = 0
	if not_see_size > 0 then
		bili = math.min(((cell_size + list_space) * (index - 1)) / not_see_size, 1)
	end
	list.scroller:ReloadData(bili)
end

function DailyRebateView:FlushTopList()
	if self.is_first then
		local top_index = DailyRebateData.Instance:GetNextRareRewardClientIndex()
		if top_index > 0 then
			--上面跳到可领取的位置
			self:ForceJumpIndex(top_index, self.node_list["TopListView"], self.top_cell_size, self.top_list_view_spacing, self.top_list_data)
		else
			self.node_list["TopListView"].scroller:ReloadData(0)
		end
	else
		self.node_list["TopListView"].scroller:RefreshActiveCellViews()
	end
end

function DailyRebateView:FlushDownList()
	if self.is_first then
		local down_index = DailyRebateData.Instance:GetNextDayRewardClientIndex()
		if down_index > 0 then
			--下面跳到可领取的位置
			self:ForceJumpIndex(down_index, self.node_list["DownListView"], self.down_cell_size, self.down_list_view_spacing, self.down_list_data)
		else
			self.node_list["DownListView"].scroller:ReloadData(0)
		end
	else	
		self.node_list["DownListView"].scroller:RefreshActiveCellViews()
	end
end

function DailyRebateView:FlushListView()
	self:FlushTopList()
	self:FlushDownList()
end

function DailyRebateView:FlushView()
	local chongzhi_day = DailyRebateData.Instance:GetChongZhiDay()
	local cfg = DailyRebateData.Instance:GetNextModelRewardCfgInfo(chongzhi_day)
	if cfg == nil then
		return
	end

	self.node_list["DayTxt"].text.text = string.format(Language.TianTianFanLi.ChongZhi, chongzhi_day)
	self.node_list["DayTxt2"].text.text = string.format(Language.TianTianFanLi.ChongZhiDay, cfg.need_chongzhi_day)
	local help_des = TipsOtherHelpData.Instance:GetTipsTextById(303)
	self.node_list["DecTxt"].text.text = help_des
	local power = ItemData.GetFightPower(cfg.model_item_id)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = power
	end

	self:FlushListView()
	
	self.is_first = false
end

function DailyRebateView:OnFlush()
	self:FlushView()
	self:FlushModel()
end

----------------------DailyRebateTopCell----------------------------
DailyRebateTopCell = DailyRebateTopCell or BaseClass(BaseCell)
function DailyRebateTopCell:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["item_cell"])
	self.item_cell:ShowHighLight(false)
	self.item_cell:ListenClick(BindTool.Bind(self.ClickItem, self))
end

function DailyRebateTopCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function DailyRebateTopCell:ClickItem()
	if self.data == nil then
		return
	end

	local can_fetch = DailyRebateData.Instance:RareRewardCanFetchByIndex(self.data.index + 1)

	if can_fetch then
		DailyRebateCtrl.Instance:ReqDayChongzhiRewardReq(DAY_CHONGZHI_REWARD_OPERA_TYPE.DAY_CHONGZHI_REWARD_OPERA_TYPE_FETCH_RARE_REWARD, self.data.index)
	else
		self.item_cell:OnClickItemCell()
	end
end

function DailyRebateTopCell:OnFlush()
	if self.data == nil then
		return
	end
	self.node_list["DayText"].text.text = string.format(Language.TianTianFanLi.LeiJiDay, self.data.need_chongzhi_day)

	local item_data = self.data.rare_reward_item[0]
	self.item_cell:SetData(item_data)

	local can_fetch = DailyRebateData.Instance:RareRewardCanFetchByIndex(self.data.index + 1)
	self.node_list["RedPoint"]:SetActive(can_fetch)

	local is_fetch = DailyRebateData.Instance:RareRewardIsFetchByIndex(self.data.index + 1)
	self.item_cell:SetIconGrayVisible(is_fetch)
	self.node_list["ShowGet"]:SetActive(is_fetch)

	local all_data = DailyRebateData.Instance:GetRareRewardCfg()
	--最后一个不展示默认底进度条
	self.node_list["Image1"]:SetActive(self.index ~= #all_data)

	--获取下一级数据
	local next_reward_cfg_info = DailyRebateData.Instance:GetRareRewardCfgInfo(self.index + 1)
	local next_can_fetch = false
	local next_is_fetch = false
	if next_reward_cfg_info then
		next_can_fetch = DailyRebateData.Instance:RareRewardCanFetchByIndex(next_reward_cfg_info.index + 1)
		next_is_fetch = DailyRebateData.Instance:RareRewardIsFetchByIndex(next_reward_cfg_info.index + 1)
	end

	self.node_list["Image2"]:SetActive(next_can_fetch or next_is_fetch)
end

----------------------DailyRebateDownCell----------------------------
DailyRebateDownCell = DailyRebateDownCell or BaseClass(BaseCell)
function DailyRebateDownCell:__init()
	self.item_cell_list ={}
	for i = 0, 1 do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self.node_list["item_cell" .. i])
		self.item_cell_list[i] = item_cell
	end
	self.node_list["Button"].button:AddClickListener(BindTool.Bind(self.ClickFetch, self))
end

function DailyRebateDownCell:__delete()
	for k, v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = nil
end

function DailyRebateDownCell:ClickFetch()
	if self.data == nil then
		return
	end

	DailyRebateCtrl.Instance:ReqDayChongzhiRewardReq(DAY_CHONGZHI_REWARD_OPERA_TYPE.DAY_CHONGZHI_REWARD_OPERA_TYPE_FETCH_REWARD, self.data.index)
end

function DailyRebateDownCell:OnFlush()
	if self.data == nil then
		return
	end

	for k, v in pairs(self.item_cell_list) do
		local item_data = self.data.reward_item[k]
		if item_data then
			v:SetParentActive(true)
			v:SetData(item_data)
		else
			v:SetParentActive(false)
		end
	end

	self.node_list["TitleText"].text.text = string.format(Language.TianTianFanLi.LeiJiDay2, self.data.need_chongzhi_day)

	local chongzhi_day = DailyRebateData.Instance:GetChongZhiDay()
	local show_tip = self.data.index > chongzhi_day
	if show_tip then
		self.node_list["Money"].text.text = Language.TianTianFanLi.ChongzhiTip
	else
		self.node_list["Money"].text.text = string.format(Language.TianTianFanLi.ChongZhiDay2, self.data.need_gold)
	end

	local is_fetch = DailyRebateData.Instance:DayRewardIsFetchByIndex(self.data.index + 1)
	local can_fetch = DailyRebateData.Instance:DayRewardCanFetchByIndex(self.data.index + 1)
	UI:SetButtonEnabled(self.node_list["Button"], not is_fetch)
	self.node_list["Button"]:SetActive(can_fetch or is_fetch)
	self.node_list["ButtonText1"]:SetActive(is_fetch)
	self.node_list["WeiDaCheng"]:SetActive((not can_fetch) and (not is_fetch))


	
	self.node_list["Button"]:SetActive(can_fetch or is_fetch)
	self.node_list["ButtonText2"]:SetActive(can_fetch)
	self.node_list["WeiDaCheng"]:SetActive((not can_fetch) and (not is_fetch))
end
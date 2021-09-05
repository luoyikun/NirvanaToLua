KuaFu1v1AwardView = KuaFu1v1AwardView or BaseClass(BaseView)

local Max_Reward_Num = 7

function KuaFu1v1AwardView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/kuafu1v1_prefab", "NodeGradeWindow"},
	}
	self.play_audio = true
	self.hide = false
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function KuaFu1v1AwardView:__delete()
end

function KuaFu1v1AwardView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))

	self.red_point_list = {}
	for i = 1, Max_Reward_Num do
		self.node_list["RankBtn" .. i].toggle:AddClickListener(function() self:OnClickRank(i) end)
		self.node_list["ShowRedPointImg" .. i]:SetActive(false)
	end
	self.node_list["Txt"].text.text = Language.Kuafu1V1.GradeTitle
	self.node_list["Bg"].rect.sizeDelta = Vector3(860, 550, 0)
	self:InitScroller()
	self:InitPreview()
	self.current_rank = 1
end

function KuaFu1v1AwardView:ReleaseCallBack()
	for k, v in pairs(self.preview_next_cell) do
		v:DeleteMe()
	end
	self.preview_next_cell = {}

	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	self.enhanced_cell_type = nil
	TitleData.Instance:ReleaseTitleEff(self.node_list["TitleImg"])
end

function KuaFu1v1AwardView:OnFlush()
	self:FlushGradeInfoWindow()
	self:FlushPreview(self.current_rank)
	--self:FlushRedPoint()
end

function KuaFu1v1AwardView:OnClickShowDetails()
	self.node_list["NodeGradeWindow"]:SetActive(true)
end

function KuaFu1v1AwardView:OnClickRank(index)
	self.current_rank = index
	self:FlushGradeInfoWindow()
	self:FlushPreview(self.current_rank)
end

function KuaFu1v1AwardView:OnClickClose()
	self:Close()
end

function KuaFu1v1AwardView:OnClickGetReward()

end
---------------------------------------------------预览--奖励itemcell-----------------------------------------------------------
function KuaFu1v1AwardView:InitPreview()
	self.preview_next_cell = {}
	for i = 1, 2 do
		local  item = ItemCell.New()
		item:SetInstanceParent(self.node_list["ItemCell"..i])
		table.insert(self.preview_next_cell, item)
		self.preview_next_cell[i]:SetActive(false)
	end

	self.node_list["GetBtn"].button:AddClickListener(BindTool.Bind(self.GetReward, self))
	self:FlushPreview(1)
end

function KuaFu1v1AwardView:FlushPreview(index)
	local info = KuaFu1v1Data.Instance:GetRoleData()
	local history_cfg = KuaFu1v1Data.Instance:GetHistoryConfig()
	if info and history_cfg then
		self.node_list["NodeShowNextReward"]:SetActive(true)
		if index == #history_cfg + 1 then
			self.node_list["NodeShowNextReward"]:SetActive(false)
		end
		local cfg = KuaFu1v1Data.Instance:GetHistoryCfgByIndex(index) or {}
		local need_score = cfg.score or 0
		-- -- 如果这个历史奖励未领取过，且当前积分大于要求积分
		-- if KuaFu1v1Data.Instance:GetRewardFlagByIndex(index - 1) and info.cross_score_1v1 >= need_score then
		-- 	UI:SetButtonEnabled(self.node_list["GetBtn"], true)
		-- 	UI:SetGraphicGrey(self.node_list["IsCanGetTxt"], true)
		-- 	self.node_list["IsCanGetImg"]:SetActive(true)
		-- else
		-- 	UI:SetButtonEnabled(self.node_list["GetBtn"], false)
		-- 	UI:SetGraphicGrey(self.node_list["IsCanGetTxt"], false)
		-- 	self.node_list["IsCanGetImg"]:SetActive(false)
		-- end
		local next_cfg = history_cfg[index]
		if next_cfg then
			for k,v in pairs(next_cfg.reward_item) do
				if v.item_id > 0 then
					local cell = self.preview_next_cell[k + 1]
					if cell then
						cell:SetActive(true)
						cell:SetData(v)
					end
				end
			end
			self.node_list["NameTxt"].text.text = string.format(Language.Activity.KaiFu1V1, next_cfg.name)
			local bundle, asset = ResPath.GetTitleIcon(next_cfg.title_id)
			self.node_list["TitleImg"].image:LoadSprite(bundle, asset, function ()
				self.node_list["TitleImg"].image:SetNativeSize()
				end)
			TitleData.Instance:LoadTitleEff(self.node_list["TitleImg"], next_cfg.title_id, true)
		end
	end
end

-- function KuaFu1v1AwardView:GetReward()
-- 	local info = KuaFu1v1Data.Instance:GetRoleData()
-- 	if info then
-- 		if not KuaFu1v1Data.Instance:GetRewardFlagByIndex(self.current_rank - 1) then
-- 			SysMsgCtrl.Instance:ErrorRemind(Language.Kuafu1V1.CantReward)
-- 			return
-- 		end
-- 		KuaFu1v1Ctrl.Instance:SendGetCross1V1RankRewardReq(self.current_rank - 1)
-- 	end
-- end

-- function KuaFu1v1AwardView:FlushRedPoint()
-- 	local info = KuaFu1v1Data.Instance:GetRoleData()
-- 	if not info then return end

-- 	for i = 1, 7 do
-- 		local cfg = KuaFu1v1Data.Instance:GetHistoryCfgByIndex(i) or {}
-- 		local need_score = cfg.score or 0
-- 		-- 最后一个段位不显示红点
-- 		if i < 7 and KuaFu1v1Data.Instance:GetRewardFlagByIndex(i - 1) and info.cross_score_1v1 >= need_score then
-- 			self.node_list["ShowRedPointImg" .. i]:SetActive(true)
-- 		else
-- 			self.node_list["ShowRedPointImg" .. i]:SetActive(false)
-- 		end
-- 	end
-- end
-- ---------------------------------------------------------------GradeInfoWindow--------------------------------------------------------

--初始化滚动条
function KuaFu1v1AwardView:InitScroller()
	local list_view_delegate = ListViewDelegate()
	self.cell_list = {}
	local res_async_loader = AllocAsyncLoader(self, "scroller_loader")
	res_async_loader:Load("uis/views/kuafu1v1_prefab", "GradeInfo", function(obj)
		if IsNil(obj) then
			return
		end
		local enhanced_cell_type = obj:GetComponent(typeof(EnhancedUI.EnhancedScroller.EnhancedScrollerCellView))

		self.enhanced_cell_type = enhanced_cell_type
		self.node_list["Scroller"].scroller.Delegate = list_view_delegate

		list_view_delegate.numberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
		list_view_delegate.cellViewSizeDel = BindTool.Bind(self.GetCellSize, self)
		list_view_delegate.cellViewDel = BindTool.Bind(self.GetCellView, self)
	end)
end

--滚动条数量
function KuaFu1v1AwardView:GetNumberOfCells()
	local count = KuaFu1v1Data.Instance:GetRankCountByType(self.current_rank)
	return count
end

--滚动条大小
function KuaFu1v1AwardView:GetCellSize(data_index)
	return 50
end

--滚动条刷新
function KuaFu1v1AwardView:GetCellView(scroller, data_index, cell_index)
	local cell_view = scroller:GetCellView(self.enhanced_cell_type)
	local cell = self.cell_list[cell_view]
	if cell == nil then
		self.cell_list[cell_view] = KuaFu1v1GradeInfoCell.New(cell_view)
		cell = self.cell_list[cell_view]
	end
	local data = KuaFu1v1Data.Instance:GetRankByIndex(self.current_rank, data_index + 1)
	if data then
		cell:SetData(data)
	end
	return cell_view
end

function KuaFu1v1AwardView:FlushGradeInfoWindow()
	if self.node_list["Scroller"].scroller.isActiveAndEnabled then
		self.node_list["Scroller"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

------------------------------------------------------------GradeInfoCell---------------------------------------------------------
KuaFu1v1GradeInfoCell = KuaFu1v1GradeInfoCell or BaseClass(BaseCell)

function KuaFu1v1GradeInfoCell:__init()
	self.root_node.list_cell.refreshCell = BindTool.Bind(self.Flush, self)
end

function KuaFu1v1GradeInfoCell:__delete()
end

function KuaFu1v1GradeInfoCell:OnFlush()
	if self.data then
		local item_list = Split(self.data.reward, ":")
		self.node_list["TxtRank"].text.text = self.data.rank_name
		if item_list and item_list[2] then
			self.node_list["TxtWeiwang"].text.text = item_list[2]
		end
		self.node_list["TxtJifen"].text.text = self.data.rank_score
	end
end

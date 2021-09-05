GoldHuntExchangeView = GoldHuntExchangeView or BaseClass(BaseView)

function GoldHuntExchangeView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/tips/goldhuntexchangetips_prefab", "GoldHuntExchangeTips"},
	}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function GoldHuntExchangeView:LoadCallBack()
	self.cell_list = {}
	self.list_view_delegate = self.node_list["list_view"].list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnCloseClick, self))
	self.node_list["Bg"].rect.sizeDelta = Vector3(630, 510, 0)
	self.node_list["Txt"].text.text = Language.Common.LieQuExchange
end

function GoldHuntExchangeView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	self.list_view_delegate = nil
end

function GoldHuntExchangeView:OpenCallBack()
	self:Flush()
end

function GoldHuntExchangeView:OnFlush()
	self.node_list["list_view"].scroller:RefreshAndReloadActiveCellViews(true)
	self.node_list["list_view"].scroller:ReloadData(0)
end

function GoldHuntExchangeView:GetNumberOfCells()
	return GoldHuntData.Instance:GetHuntInfoCfgCount()
end

function GoldHuntExchangeView:RefreshView(cell, data_index)
	data_index = data_index + 1
	local the_cell = self.cell_list[cell]
	if the_cell == nil then
		the_cell = GoldHuntExchangeCell.New(cell.gameObject)
		--the_cell.parent = self
		self.cell_list[cell] = the_cell
	end
	-- the_cell:SetData()
	the_cell:SetIndex(data_index)
	-- the_cell:SetIndex(GameEnum.RA_MINE_MAX_REFRESH_COUNT + 1 - data_index)
	the_cell:Flush()
end

function GoldHuntExchangeView:OnCloseClick()
	self:Close()
end

-------------------------------------------------------------------------
GoldHuntExchangeCell = GoldHuntExchangeCell or BaseClass(BaseCell)

function GoldHuntExchangeCell:__init()
	self.item_cell_2 = ItemCell.New()
	self.item_cell_2:SetInstanceParent(self.node_list["item2"])
	self.node_list["BtnExchange"].button:AddClickListener(BindTool.Bind(self.ExchangeClick, self))
end

function GoldHuntExchangeCell:__delete()
	if nil ~= self.item_cell_2 then
		self.item_cell_2:DeleteMe()
	end
	
	self.parent = nil
end

function GoldHuntExchangeCell:ExchangeClick()
	local gold_hunt_data = GoldHuntData.Instance
	local num = #gold_hunt_data:GetHuntInfoCfg() + 1
	local info_cfg = GoldHuntData.Instance:GetHuntInfoCfgSort()[self.index]
	GoldHuntCtrl.Instance:SendRandActivityOperaReq(GoldHuntData.GOLD_HUNT_ID, GOLD_HUNT_OPERA_TYPE.OPERA_EXCHANGE_REWARD, info_cfg.seq)
end

function GoldHuntExchangeCell:OnFlush()
	local gold_hunt_data = GoldHuntData.Instance
	local num = #gold_hunt_data:GetHuntInfoCfg()
	local info_cfg = gold_hunt_data:GetHuntInfoCfgSort()[self.index]
	if not info_cfg then
		return
	end
	-- local is_over_open_day = gold_hunt_data:GetOpenDay() > info_cfg.opengame_day
	-- self.root_node.gameObject:SetActive(not is_over_open_day)
	-- if is_over_open_day then
	-- 	return
	-- end

	self["item_cell_2"]:SetData(info_cfg.item_list)

	self.node_list["TxtName"].text.text = info_cfg.name

	local info = GoldHuntData.Instance:GetHuntInfo().gather_count_list
	if not info then
		return
	end

	local my_count = info[info_cfg.seq] or 0
	local color = my_count >= info_cfg.exchange_need_num and TEXT_COLOR.GREEN or TEXT_COLOR.RED
	self.node_list["TxtRemain"].text.text = ToColorStr(my_count.."/"..info_cfg.exchange_need_num, color)

	local ok_callback = function()
		self.node_list["item1"].image:SetNativeSize()
		self.node_list["item1"].transform.localScale = Vector3(0.9, 0.9, 0.9)
	end

	local asset, name = ResPath.GetGoldHuntModelImg("head_" .. info_cfg.seq+1)
	self.node_list["item1"].image:LoadSprite(asset, name, ok_callback)
end
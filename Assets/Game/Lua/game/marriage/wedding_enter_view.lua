WeddingEnterView = WeddingEnterView or BaseClass(BaseView)

function WeddingEnterView:__init()
	self.ui_config = {{"uis/views/marriageview_prefab", "WeddingEnterView"}}
	self.scroller_data = {}
	self.cell_list = {}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function WeddingEnterView:__delete()

end

function WeddingEnterView:ReleaseCallBack()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	self.scroller = nil
end

function WeddingEnterView:LoadCallBack()
	self:InitScroller()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.ClickClose, self))
end

function WeddingEnterView:SetScrollerData()
	self.scroller_data = MarriageData.Instance:GetGetInviteData()
end

function WeddingEnterView:OpenCallBack()
	self:Flush()
end

function WeddingEnterView:InitScroller()
	self.scroller_data = {}
	local delegate = self.node_list["Scroller"].list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		return #self.scroller_data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index)
		data_index = data_index + 1
		local item_cell = self.cell_list[cell]
		if not item_cell then
			item_cell = WedingScrollerCell.New(cell.gameObject)
			self.cell_list[cell] = item_cell
		end
		local data = self.scroller_data[data_index]
		item_cell:SetData(data)
	end
end

function WeddingEnterView:OnFlush()
	self:SetScrollerData()
	self.node_list["Scroller"].scroller:RefreshAndReloadActiveCellViews(true)
end

function WeddingEnterView:ClickClose()
	self:Close()
end

--滚动条格子-------------------------------------
WedingScrollerCell = WedingScrollerCell or BaseClass(BaseCell)
function WedingScrollerCell:__init()
	self.node_list["BtnGetIn"].button:AddClickListener(BindTool.Bind(self.OnCLick, self))
end

function WedingScrollerCell:__delete()

end

function WedingScrollerCell:OnCLick()
	if Scene.Instance:GetSceneType() == SceneType.HunYanFb then
		TipsCtrl.Instance:ShowSystemMsg(Language.Marriage.AlreadyInWeeding)
	else
		MarriageCtrl.Instance:SendMarryOpera(HUNYAN_OPERA_TYPE.HUNYAN_OPERA_TYPE_JOIN_HUNYAN, self.data.yanhui_fb_key)
	end
end

function WedingScrollerCell:OnFlush()
	self.node_list["TxtMale"].text.text = self.data.man_name
	self.node_list["TxtFemale"].text.text = self.data.women_name
	local hunyan_type = self.data.hunyan_type

	local res_str = hunyan_type == 1 and "text_hunyan1" or "text_hunyan2"
	local bunble, asset = ResPath.GetMarryTxtImage(res_str)
	self.node_list["ImgWedding"].image:LoadSprite(bundle, asset .. ".png")

	local max_num = 0
	local hunyan_cfg = MarriageData.Instance:GetHunYanCfg()
	if hunyan_type == 1 then
		max_num = hunyan_cfg.bind_gold_gather_max or 0
	else
		max_num = hunyan_cfg.gather_max or 0
	end
	self.node_list["TxtCollectCount"].text.text = string.format(Language.Marriage.CaiJiCount, self.data.garden_num,max_num)
end

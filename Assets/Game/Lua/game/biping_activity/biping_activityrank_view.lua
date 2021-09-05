BiPingActivityRankView = BiPingActivityRankView or BaseClass(BaseView)

function BiPingActivityRankView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/bipingact_prefab", "BiPinRank"},
	}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
end

function BiPingActivityRankView:LoadCallBack()
	self.rank_item_list = {}
	self.node_list["Bg"].rect.sizeDelta = Vector3(600,630,0)
	self.node_list["Txt"].text.text = Language.BiPin.Title
	self.node_list["ListView"].list_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.node_list["ListView"].list_simple_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
end

function BiPingActivityRankView:CloseCallBack()

end

function BiPingActivityRankView:OnClickClose()
	self:Close()
end

function BiPingActivityRankView:RefreshCell(cell, data_index)
	local data = BiPingActivityData.Instance:GetImageRankCfg()
	local tower_rank_item = self.rank_item_list[cell]
	data_index = data_index + 1
	if nil == tower_rank_item then
		tower_rank_item = BipinRankItem.New(cell.gameObject)
		self.rank_item_list[cell] = tower_rank_item
	end

	local data_list = data[data_index]
	tower_rank_item:SetIndex(data_index)
	tower_rank_item:SetData(data_list)
end

function BiPingActivityRankView:GetNumberOfCells()
	return #BiPingActivityData.Instance:GetImageRankCfg()
end

function BiPingActivityRankView:OpenCallBack()

end

function BiPingActivityRankView:ReleaseCallBack()
	for k, v in pairs(self.rank_item_list) do
		v:DeleteMe()
	end
	self.rank_item_list = {}
end

--决定显示那个界面
function BiPingActivityRankView:ShowIndexCallBack()
	
end



function BiPingActivityRankView:OnFlush()
		if self.node_list["ListView"].scroller.isActiveAndEnabled then
			self.node_list["ListView"].scroller:ReloadData(0)
		end
end

BipinRankItem = BipinRankItem or BaseClass(BaseCell)
function BipinRankItem:__init()

end

function BipinRankItem:__delete()

end

function BipinRankItem:OnFlush()
	if nil == self.data then
		return
	end
	self.node_list["RankTxt"].text.text = self.index
	self.node_list["GuildNameTxt"].text.text = self.data.user_name
	self.node_list["ServerIdTxt"].text.text = self.data.rank_value
	
	if self.index <= 3 then
		self.node_list["RankImage"]:SetActive(true)
		self.node_list["RankTxt"]:SetActive(false)
		
	 	local bundle, asset = ResPath.GetRankIcon(self.index)
		self.node_list["RankImage"].image:LoadSprite(bundle, asset)
	else
		self.node_list["RankImage"]:SetActive(false)
		self.node_list["RankTxt"]:SetActive(true)
	end
end




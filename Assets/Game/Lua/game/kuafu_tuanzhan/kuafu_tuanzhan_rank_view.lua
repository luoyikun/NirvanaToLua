KuaFuTuanZhanRankView = KuaFuTuanZhanRankView or BaseClass(BaseView)

local RANK_NUM = 4

function KuaFuTuanZhanRankView:__init()
	self.active_close = false
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.ui_config = {
			{"uis/views/kuafutuanzhan_prefab", "KuaFuTuanZhanRankView"},
	}

	self.cell_list = {}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function KuaFuTuanZhanRankView:ReleaseCallBack()
	self.rank_panel = nil
	self.rank_list_data = nil

	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
	end
	self.cell_list = {}

end

function KuaFuTuanZhanRankView:__delete()

end

function KuaFuTuanZhanRankView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	local list_delegate = self.node_list["RankInfoList"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function KuaFuTuanZhanRankView:GetNumberOfCells()
	return #self.rank_list_data
end

function KuaFuTuanZhanRankView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	if nil == self.cell_list[cell] then
		self.cell_list[cell] = KuaFuTuanZhanListCell.New(cell.gameObject)
	end
	if nil ~= self.rank_list_data[data_index] then
		local cell_data = self.rank_list_data[data_index]
		cell_data.data_index = data_index
		self.cell_list[cell]:SetData(cell_data)
	end
end

function KuaFuTuanZhanRankView:InitRankPanel()

end

function KuaFuTuanZhanRankView:FlushRank()
	self.rank_list_data = KuaFuTuanZhanData.Instance:GetRankListInfo()
end

function KuaFuTuanZhanRankView:OnFlush(param_t)
	self:FlushRank()
end

function KuaFuTuanZhanRankView:OpenCallBack()
	self:FlushRank()
end


----------------滚动条格子-----------------

KuaFuTuanZhanListCell = KuaFuTuanZhanListCell or BaseClass(BaseCell)
function KuaFuTuanZhanListCell:__init()
	
end

function KuaFuTuanZhanListCell:__delete()
	
end

function KuaFuTuanZhanListCell:OnFlush()
	local rank_num = self.data.data_index
	
	if rank_num < RANK_NUM then
		self.node_list["Img_rank"]:SetActive(true)
		self.node_list["Txt_rank"]:SetActive(false)
		self.node_list["Img_rank"].image:LoadSprite(ResPath.GetRankIcon(rank_num))
		self.node_list["Img_rank"].image:SetNativeSize()
	else
		self.node_list["Img_rank"]:SetActive(false)
		self.node_list["Txt_rank"]:SetActive(true)
		self.node_list["Txt_rank"].text.text = rank_num
	end
	self.node_list["TxtName"].text.text = self.data.name
	self.node_list["TxtScore"].text.text = self.data.score
	self.node_list["TxtKillAssist"].text.text = self.data.kill .. "/" .. self.data.assist
end
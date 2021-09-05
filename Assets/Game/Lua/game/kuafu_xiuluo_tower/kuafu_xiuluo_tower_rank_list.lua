KuaFuXiuLuoTowerRankList = KuaFuXiuLuoTowerRankList or BaseClass(BaseRender)
local  NUM = 4
function KuaFuXiuLuoTowerRankList:__init()
	self.scroller_data = {}
	self:InitScroller()
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.is_modal = true
end

function KuaFuXiuLuoTowerRankList:__delete()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function KuaFuXiuLuoTowerRankList:OnFlush()
	-- self.node_list["Scroller"].scroller:ReloadData(0)
	if self.node_list["Scroller"] and self.node_list["Scroller"].scroller and self.node_list["Scroller"].scroller.isActiveAndEnabled then
		self.node_list["Scroller"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function KuaFuXiuLuoTowerRankList:InitScroller()
	self.cell_list = {}
	self.scroller_data = KuaFuXiuLuoTowerData.Instance:GetRankList()
	local delegate = self.node_list["Scroller"].list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		return #self.scroller_data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1

		local target_cell = self.cell_list[cell]

		if nil == target_cell then
			self.cell_list[cell] = XiuLuoRankScrollerCell.New(cell.gameObject)
			target_cell = self.cell_list[cell]
			target_cell.mother_view = self
		end
		local cell_data = self.scroller_data[data_index]
		cell_data.data_index = data_index
		target_cell:SetData(cell_data)
	end
end

function KuaFuXiuLuoTowerRankList:CloseView()
	self:Close()
end
----------------滚动条格子-----------------

XiuLuoRankScrollerCell = XiuLuoRankScrollerCell or BaseClass(BaseCell)

function XiuLuoRankScrollerCell:__init()

end

function XiuLuoRankScrollerCell:__delete()
end

function XiuLuoRankScrollerCell:OnFlush()
	local rank_is_self = (self.data.user_name == GameVoManager.Instance:GetMainRoleVo().name)
	self.node_list["ImgSelfLayer"]:SetActive(rank_is_self)
	local rank_num = self.data.data_index
	if rank_num < NUM then
		self.node_list["ImgIcon"].image:LoadSprite(ResPath.GetRankIcon(rank_num))
		self.node_list["ImgIcon"].image:SetNativeSize()
		self.node_list["ImgIcon"]:SetActive(true)
		self.node_list["TxtRank"]:SetActive(false)
	else
		self.node_list["ImgIcon"]:SetActive(false)
		self.node_list["TxtRank"]:SetActive(true)
		self.node_list["TxtRank"].text.text = rank_num
	end
	self.node_list["TxtName"].text.text = self.data.user_name
	self.node_list["TxtScore"].text.text = self.data.max_layer
end
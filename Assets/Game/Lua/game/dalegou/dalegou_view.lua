DaLeGouView = DaLeGouView or BaseClass(BaseView)
function DaLeGouView:__init()
	self.ui_config = {
		{"uis/views/dalegou_prefab", "DaLeGouView"}
	}
	self.is_modal = true
end

function DaLeGouView:__delete()
end

function DaLeGouView:ReleaseCallBack()
	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = nil

	self.list_view = nil
end

function DaLeGouView:LoadCallBack()
	self.node_list["Content"].button:AddClickListener(BindTool.Bind(self.ClickRecharge, self))
	self.node_list["Close"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))

	self.list_data = {}
	self.cell_list = {}
	self.list_view = self.node_list["ListView"]
	local scroller_delegate = self.list_view.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.NumberOfCells, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.CellRefresh, self)
end

function DaLeGouView:ClickRecharge()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function DaLeGouView:CloseWindow()
	self:Close()
end

function DaLeGouView:NumberOfCells()
	return #self.list_data
end

function DaLeGouView:CellRefresh(cell_obj, data_index)
	local cell = self.cell_list[cell_obj]
	if cell == nil then
		cell = DaLeGouCell.New(cell_obj.gameObject)
		self.cell_list[cell_obj] = cell
	end

	cell:SetData(self.list_data[#self.list_data - data_index])
	cell:SetIndex(data_index)
end

function DaLeGouView:OpenCallBack()
	local list_data = DaLeGouData.Instance:GetActivityCfg()
	list_data = ListToMapList(list_data, "level")
	self.list_data = {}
	for k, v in pairs(list_data) do
		self.list_data[k + 1] = v
	end

	self.list_view.scroll_rect.vertical = false

	--请求充值信息
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DALEGOU, RA_CRACYBUY_TYPE.RA_CRACYBUY_ALL_INFO)
	--请求限购信息
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DALEGOU, RA_CRACYBUY_TYPE.RA_CRACYBUY_LIMIT_INFO)
end

function DaLeGouView:CloseCallBack()
end

function DaLeGouView:OnFlush()
	self.list_view.scroller:ReloadData(0)

	local next_recharge = DaLeGouData.Instance:GetNextLevelRecharge()
	local now_recharge = DaLeGouData.Instance:GetChongZhi()
	local interval = next_recharge - now_recharge
	interval = math.max(0, interval)

	self.node_list["Recharge"].text.text = string.format(Language.DaLeGou.YuanBao, now_recharge)
	self.node_list["Text"].text.text = string.format(Language.DaLeGou.Txt5, interval)
end

---------------------------DaLeGouCell--------------------------
DaLeGouCell = DaLeGouCell or BaseClass(BaseCell)
function DaLeGouCell:__init()
	self.item_list_obj = self.node_list["ItemList"]
	self.item_list = {}
	self:LoadItemList()

end

function DaLeGouCell:__delete()
	for _, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = nil
end

function DaLeGouCell:ItemClick(item_index, item_cell)
	if self.data == nil then
		return
	end

	local function close_callback()
		if item_cell then
			item_cell:SetHighLight(false)
		end
	end
	local data = self.data[item_index]
	DaLeGouCtrl.Instance:ShowTips(data, close_callback)
end

function DaLeGouCell:SetIndex(index)
	self.index = index
end


function DaLeGouCell:LoadItemList()
	local res_async_loader = AllocResAsyncLoader(self, "item_res_async_loader")
	res_async_loader:Load("uis/views/dalegou_prefab", "DaLeGouItemCell", nil, function(prefab)
		if prefab and not self:IsNil() then
			--暂时都创建5个
			for i = 1, 6 do
				local obj = ResMgr:Instantiate(prefab)
				obj = U3DObject(obj.gameObject)
				obj.transform:SetParent(self.item_list_obj.transform, false)
				obj.transform.localPosition = Vector3(0, 0, 0)
				obj.transform.localScale = Vector3(0.9, 0.9, 0.9)

				local item = ItemCell.New()
				item:SetInstanceParent(obj)
				item.root_node.transform:SetSiblingIndex(0)
				item:ListenClick(BindTool.Bind(self.ItemClick, self, i, item))

				local data = self.data and self.data[i]
				if data then
					item:SetParentActive(true)

					local limit_info = DaLeGouData.Instance:GetBuyLimitInfoBySeq(data.seq)
					local is_sell_out = false
					if limit_info then
						if limit_info.person_limit >= data.role_buy_times_limit or limit_info.all_limit >= data.server_buy_times_limit then
							is_sell_out = true
						end
					end
					local name_table = obj:GetComponent(typeof(UINameTable)):Find("Image")
					name_table:SetActive(is_sell_out)

					item:SetData(data.reward_item)
					item:SetIconGrayVisible(is_sell_out)
				else
					item:SetParentActive(false)
				end

				table.insert(self.item_list, item)
			end
			self:Flush()
		end
	end)
end

function DaLeGouCell:OnFlush()
	if self.data == nil then
		return
	end

	self.node_list["Image"].transform.localPosition = Vector3(-106 - self.index * 44, 0, 0)

	for k, v in ipairs(self.item_list) do
		local data = self.data[k]
		if data then
			v:SetParentActive(true)

			local limit_info = DaLeGouData.Instance:GetBuyLimitInfoBySeq(data.seq)
			local is_sell_out = false
			if limit_info then
				if limit_info.person_limit >= data.role_buy_times_limit or limit_info.all_limit >= data.server_buy_times_limit then
					is_sell_out = true
				end
			end
			
			local parent_obj = v.root_node.transform.parent.gameObject
			local name_table = parent_obj:GetComponent(typeof(UINameTable)):Find("Image")
			name_table:SetActive(is_sell_out)

			v:SetData(data.reward_item)
			v:SetIconGrayVisible(is_sell_out)
		else
			v:SetParentActive(false)
		end
	end

	local data = self.data[1]
	self.node_list["Text"].text.text = string.format(Language.DaLeGou.Txt6, data.gold_level)
end
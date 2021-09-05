MainuiResIconListView = MainuiResIconListView or BaseClass(BaseView)

function MainuiResIconListView:__init()
	self.ui_config = {{"uis/views/mainui_prefab", "MainuiResIconListDetail"}}
	self.view_layer = UiLayer.Pop
	self.cell_list_t = {{}, {}, {}, {}}
	self.scroller_t = {}
	self.scroller_data = {}
	self.dir = 1 --1 左下 2 右上 3 左上 4 右下
end

function MainuiResIconListView:__delete()

end

function MainuiResIconListView:ReleaseCallBack( ... )
	for k, v in pairs(self.cell_list_t) do
		for _,v1 in pairs(v) do
			v1:DeleteMe()
		end
		self.cell_list_t[k] = {}
	end

	-- 清理变量和对象
	self.rect = nil
	self.click_obj = nil
	self.scroller_t = {}
end

function MainuiResIconListView:LoadCallBack()
	self.node_list["BtnBgClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnBgClose1"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnBgClose2"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnBgClose3"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.rect = self.node_list["ChangePoint"].transform:GetComponent(typeof(UnityEngine.RectTransform))
end

function MainuiResIconListView:FlushList(dir)
	if self.scroller_t[dir] == nil then
		self.scroller_t[dir] = self.node_list["ButtonList" .. dir]
		local scroller_delegate = self.scroller_t[dir].page_simple_delegate
		--生成数量
		scroller_delegate.NumberOfCellsDel = function()
			return math.ceil(#self.scroller_data / 4) * 4
		end
		--刷新函数
		scroller_delegate.CellRefreshDel = function(data_index, cell)
			local grid_index = math.floor(data_index / 4) * 4 + (4 - data_index % 4)

			local detail_cell = self.cell_list_t[dir][cell]
			if detail_cell == nil then
				detail_cell = MainuiResIconDetailCell.New(cell.gameObject)
				detail_cell.list_detail_view = self
				self.cell_list_t[dir][cell] = detail_cell
			end

			detail_cell:SetIndex(grid_index)
			detail_cell:SetData(self.scroller_data[grid_index])
			detail_cell.root_node:SetActive(self.scroller_data[grid_index] ~= nil)
		end
	end
	self.scroller_t[dir].list_view:Reload()
	self.scroller_t[dir].list_view:JumpToIndex(0)
end

function MainuiResIconListView:CloseWindow()
	self:Close()
end

function MainuiResIconListView:CloseCallBack()
	if self.close_call_back then
		self.close_call_back()
		self.close_call_back = nil
	end
	self.scroller_data = {}

	self.role_name = ""

	self.click_obj = nil

	if not self.root_node then
		return
	end
end

function MainuiResIconListView:SetRoleName(name)
	self.role_name = name
end

function MainuiResIconListView:SetCloseCallBack(callback)
	self.close_call_back = callback
end

function MainuiResIconListView:OpenCallBack()
	local item_count = #self.scroller_data or 0
	self:ChangePanelHeight(item_count)

	for i = 1, 4 do
		self.node_list["Panel" .. i]:SetActive(self.dir == i)
	end
	self:Flush()
end

function MainuiResIconListView:SetClickObj(obj, dir)
	self.click_obj = obj
	self.dir = dir or 1
end

--改变列表长度
function MainuiResIconListView:ChangePanelHeight(item_count)
	local panel = self.node_list["Panel" .. self.dir] or self.node_list["Panel1"]
	local row = item_count < 4 and item_count or 4
	local col = math.max(math.ceil(item_count / 4), 1)
	local panel_width = 82 * row + 8 * (row - 1) + 20
	local panel_height = 82 * col + 8 * (col - 1) + 40

	panel.rect.sizeDelta = Vector2(panel_width, panel_height)
	if not self.click_obj then
		return
	end
	--获取指引按钮的屏幕坐标
	local uicamera = GameObject.Find("GameRoot/UICamera"):GetComponent(typeof(UnityEngine.Camera))
	local obj_world_pos = self.click_obj.transform:GetComponent(typeof(UnityEngine.RectTransform)).position
	local screen_pos_tbl = UnityEngine.RectTransformUtility.WorldToScreenPoint(uicamera, obj_world_pos)

	--转换屏幕坐标为本地坐标
	local rect = self.root_node:GetComponent(typeof(UnityEngine.RectTransform))
	local _, local_pos_tbl = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(rect, screen_pos_tbl, uicamera, Vector2(0, 0))
	local y_dir =  (self.dir == 1 or self.dir == 4) and 1 or -1
	local_pos_tbl.y = local_pos_tbl.y - 60 * y_dir
	local x_dir = (self.dir == 1 or self.dir == 3) and 1 or -1
	local_pos_tbl.x = local_pos_tbl.x + 30 * x_dir

	self.rect.anchoredPosition = local_pos_tbl
end

function MainuiResIconListView:SetData(data)
	self.scroller_data = data
	self:Open()
end

function MainuiResIconListView:OnFlush()
	self:FlushList(self.dir)
end

----------------------------------------------------------------------------
--MainuiResIconDetailCell 		列表滚动条格子
----------------------------------------------------------------------------

MainuiResIconDetailCell = MainuiResIconDetailCell or BaseClass(BaseCell)

function MainuiResIconDetailCell:__init()
	self.list_detail_view = nil
	self.node_list["BtnImg"].button:AddClickListener(BindTool.Bind(self.OnButtonClick, self))
end

function MainuiResIconDetailCell:__delete()
	self.list_detail_view = nil
end

function MainuiResIconDetailCell:OnFlush()
	if not self.data or not next(self.data) then return end

	local bundle, asset = ResPath.GetMainIcon(self.data.res)
	self.node_list["Icon"].image:LoadSpriteAsync(bundle, asset, function ()
		-- self.node_list["Icon"].image:SetNativeSize()
	end)
	bundle, asset = ResPath.GetMainIcon(self.data.res .. "Name")
	self.node_list["Name"].image:LoadSpriteAsync(bundle, asset, function ()
		self.node_list["Name"].image:SetNativeSize()
	end)

	self.node_list["ImgLimit"]:SetActive(self.data.limit)
	if self.data.limit then
		bundle, asset = ResPath.GetMainUI("half_off")
		self.node_list["ImgLimit"].image:LoadSpriteAsync(bundle, asset, function ()
			self.node_list["ImgLimit"].image:SetNativeSize()
		end)
	end

	self.node_list["Effect"]:SetActive(self.data.show_eff or false)
	self.node_list["ImgRedPoint"]:SetActive(self.data.remind ~= nil and self.data.remind > 0)
end

function MainuiResIconDetailCell:OnButtonClick()
	self.list_detail_view:Close()
	self.data.callback()
end
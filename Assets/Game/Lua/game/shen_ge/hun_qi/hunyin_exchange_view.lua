HunYinExchangView = HunYinExchangView or BaseClass(BaseView)

HunYinExchangView.Middle_ShengLing_Type = 11					-- 中级圣灵兑换类型
HunYinExchangView.High_ShengLing_Type = 12						-- 高级圣灵兑换类型
HunYinExchangView.Top_ShengLing_Type = 13						-- 顶级圣灵兑换类型

function HunYinExchangView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/hunqiview_prefab", "HunYinExchangeContent",}
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	
	self.convert_cfg = ExchangeData.Instance:GetHunYinExchangeCfg()
	self.middle__type_shengling = {}
	self.high__type_shengling = {}
	self.top__type_shengling = {}
	for k,v in pairs(self.convert_cfg) do
		if HunYinExchangView.Middle_ShengLing_Type == v.price_type then
			table.insert(self.middle__type_shengling, v) 
		end
		if HunYinExchangView.High_ShengLing_Type == v.price_type then
			table.insert(self.high__type_shengling, v) 
		end
		if HunYinExchangView.Top_ShengLing_Type == v.price_type then
			table.insert(self.top__type_shengling, v) 
		end
	end
	self.exchenge_cell_count = #self.middle__type_shengling
	self.current_shengling_info = {}
end

function HunYinExchangView:__delete()
	
end

function HunYinExchangView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.ClickClosen, self))
	self.node_list["Button_1"].toggle:AddClickListener(BindTool.Bind(self.ClickMiddle, self))
	self.node_list["Button_2"].toggle:AddClickListener(BindTool.Bind(self.ClickSenior, self))
	self.node_list["Button_3"].toggle:AddClickListener(BindTool.Bind(self.ClickClimax, self))
	self.node_list["BtnAdd"].button:AddClickListener(BindTool.Bind(self.ClickAdd, self))

	self.exchange_list = {}
	local page_simple_delegate = self.node_list["ExchangeList"].page_simple_delegate
	page_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.NumberOfCellsDel, self)
	page_simple_delegate.CellRefreshDel = BindTool.Bind(self.CellRefreshDel, self)

	self.node_list["Txt"].text.text = Language.HunQi.TxtTitle3
	self.node_list["Bg"].rect.sizeDelta = Vector3(994, 570, 0)

	self.button_list = {}
	for i = 1, 3 do
		local btn = self.node_list["Button_" .. i]
		table.insert(self.button_list, btn)
	end
end

-- 销毁前调用
function HunYinExchangView:ReleaseCallBack()
	self.button_group_obj = nil
	self.button_list = {}
	
	for k,v in pairs(self.exchange_list) do
		v:DeleteMe()
	end
	self.exchange_list = {}
end

-- 打开后调用
function HunYinExchangView:OpenCallBack()
	self:ClickMiddle()
end

-- 关闭前调用
function HunYinExchangView:CloseCallBack()
	self.button_list[1].toggle.isOn = true
end

--显示对应种类的圣灵
function HunYinExchangView:FlushHomologousView(type_shengling_info)
	if nil ~= next(type_shengling_info) then
		self.current_shengling_info = type_shengling_info
		self.exchenge_cell_count = #self.current_shengling_info
		self.node_list["ExchangeList"].list_view:JumpToIndex(0)
		self.node_list["ExchangeList"].list_view:Reload()
		self.all_lingzhi = ExchangeData.Instance:GetAllLingzhi()
	end
end

function HunYinExchangView:NumberOfCellsDel()
	return self.exchenge_cell_count
end

-- cell刷新 每个进入一次
function HunYinExchangView:CellRefreshDel(data_index, cell)
	data_index = data_index + 1
	local data = self.current_shengling_info[data_index]
	local item_cell = self.exchange_list[cell]
	if nil == item_cell then
		item_cell = ExchangeCell.New(cell.gameObject)
		self.exchange_list[cell] = item_cell
	end
	item_cell:SetClickCallBack(BindTool.Bind(self.ClickExchange, self))
	item_cell:SetIndex(data_index)
	item_cell:SetData(data)
end

function HunYinExchangView:ClickAdd()
	ViewManager.Instance:Open(ViewName.HunYinResolve)
	self:Close()
end

function HunYinExchangView:ClickExchange(item_cell)
	local item_data = item_cell:GetData()
	ExchangeCtrl.Instance:SendScoreToItemConvertReq(item_data.conver_type, item_data.seq, 1)
end

function HunYinExchangView:FlushLingzhiCount()
	self.all_lingzhi = ExchangeData.Instance:GetAllLingzhi()
	self.node_list["TxtCount"].text.text = self.all_lingzhi[self.current_type]
end

--中级
function HunYinExchangView:ClickMiddle()
	self:FlushHomologousView(self.middle__type_shengling)
	self.node_list["TxtCount"].text.text = self.all_lingzhi.blue
	local asset, bundle = ResPath.GetHunQiImg("small_lanlingzhi")
	self.node_list["ImgIcon"].image:LoadSprite(asset, bundle, function()
		self.node_list["ImgIcon"].image:SetNativeSize()
		end)
	self.current_type = "blue"
end

--高级
function HunYinExchangView:ClickSenior()
	self:FlushHomologousView(self.high__type_shengling)
	self.node_list["TxtCount"].text.text = self.all_lingzhi.purple
	local asset, bundle = ResPath.GetHunQiImg("small_zilingzhi")
	self.node_list["ImgIcon"].image:LoadSprite(asset, bundle, function()
		self.node_list["ImgIcon"].image:SetNativeSize()
		end)
	self.current_type = "purple"
end

--顶级
function HunYinExchangView:ClickClimax()
	self:FlushHomologousView(self.top__type_shengling)
	self.node_list["TxtCount"].text.text = self.all_lingzhi.orange
	local asset, bundle = ResPath.GetHunQiImg("small_chenglingzhi")
	self.node_list["ImgIcon"].image:LoadSprite(asset, bundle, function()
		self.node_list["ImgIcon"].image:SetNativeSize()
		end)
	self.current_type = "orange"
end

function HunYinExchangView:ClickClosen()
	self:Close()
end

------------------ExchangeCell--------------------
ExchangeCell = ExchangeCell or BaseClass(BaseCell)
function ExchangeCell:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["item_cell"])
	self.item_cell:SetData({})
	self.item_cell:ListenClick(BindTool.Bind1(self.OnIcon, self))
	self.item_cell.root_node.toggle.interactable = true
	self.node_list["BtnExchange"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function ExchangeCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function ExchangeCell:OnFlush()
	local data = self:GetData()
	if data.price_type == HunYinExchangView.Middle_ShengLing_Type then
		self.node_list["Imgsucai"].image:LoadSprite(ResPath.GetHunQiImg("small_lanlingzhi"))
	elseif  data.price_type == HunYinExchangView.High_ShengLing_Type then
		self.node_list["Imgsucai"].image:LoadSprite(ResPath.GetHunQiImg("small_zilingzhi"))
	else
		self.node_list["Imgsucai"].image:LoadSprite(ResPath.GetHunQiImg("small_chenglingzhi"))
	end

	self.node_list["TxtCost"].text.text = data.price
	local name = ItemData.Instance:GetItemConfig(data.item_id).name
	self.node_list["TxtName"].text.text = name

	local icon = HunQiData.Instance:GetHunYinItemIconId(data.item_id)
	if 0 == icon then
		icon = HunQiData.Instance:GetGiftItemIconId(data.item_id)
	end
	self.item_cell.node_list["Icon"]:SetActive(true)
	self.item_cell.node_list["Icon"].image:LoadSprite(ResPath.GetItemIcon(icon))
end

function ExchangeCell:OnIcon()
	local hunyin_id = self:GetData().item_id or 0
	local hunyin_info = HunQiData.Instance:GetHunQiInfo()
	local data = hunyin_info[hunyin_id][1]
	local attr_info = CommonStruct.AttributeNoUnderline()
	attr_info.maxhp = data.maxhp
	attr_info.gongji = data.gongji
	attr_info.fangyu = data.fangyu
	attr_info.mingzhong = data.mingzhong
	attr_info.shanbi = data.shanbi
	attr_info.baoji = data.baoji
	attr_info.jianren = data.jianren
	self.item_cell:SetHighLight(false)
	TipsCtrl.Instance:ShowAttrView(attr_info)
end
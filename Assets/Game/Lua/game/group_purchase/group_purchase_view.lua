GroupPurchaseView = GroupPurchaseView or BaseClass(BaseView)

function GroupPurchaseView:__init()
	self.ui_config = {
		-- {"uis/views/commonwidgets_prefab", "BaseActivityPanelTwo_1"},
		{"uis/views/grouppurchaseview_prefab", "GroupPurchaseView"},
		-- {"uis/views/commonwidgets_prefab", "BaseActivityPanelTwo_2"},
	}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function GroupPurchaseView:__delete()

end

function GroupPurchaseView:LoadCallBack()
	self.purchase_cell_list = {}
	self.purchase_data_list = {}
	self.cart_cell_list = {}
	self.cart_data_list = {}
	self.toggle_list = {}
	local bundle, asset = ResPath.GetRawImage("img_grouppurchasebg")
	self.node_list["Bg"].raw_image:LoadSprite(bundle, asset, function()
		self.node_list["Bg"].raw_image:SetNativeSize()
	end)

	local list_delegate = self.node_list["ListView"].page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	local cart_list_delegate = self.node_list["CartListView"].page_simple_delegate
	cart_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetCartNumberOfCells, self)
	cart_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCartCell, self)

	for i=1, 3 do
		self.toggle_list[i] = self.node_list["Toggle"..i]
		self.node_list["Toggle" .. i].toggle:AddClickListener(BindTool.Bind(self.OnClickToggle, self, i - 1))
	end

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["BtnAllBuy"].button:AddClickListener(BindTool.Bind(self.OnClickAllBuy, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
end

function GroupPurchaseView:ReleaseCallBack()
	self.node_list["CartListView"] = nil
	self.purchase_data_list = {}
	self.cart_data_list = {}
	self.toggle_list = {}

	for k,v in pairs(self.purchase_cell_list) do
		v:DeleteMe()
	end
	self.purchase_cell_list = {}

	for k,v in pairs(self.cart_cell_list) do
		v:DeleteMe()
	end
	self.cart_cell_list = {}
end

function GroupPurchaseView:CloseCallBack()
	self:CancelTimeQuest()
end

function GroupPurchaseView:OpenCallBack()
	if self.toggle_list and self.toggle_list[3] and self.toggle_list[3].toggle then
		self.toggle_list[3].toggle.isOn = true
	end

	self.discount_price = 0
	self.select_buy_type = 2
	self:SetPurchaseData(true)
	self:SetCartData()
	self:SetGroupPurchaseDes()
	self:FlushActivityTimeCountDown()
end

--获取可购买物品信息
function GroupPurchaseView:SetPurchaseData(flag)
	self.purchase_data_list = GroupPurchaseData.Instance:GetSingleTypeBuyItemCfgByType(self.select_buy_type)
	self:FlushPurchaseList(flag)
end

--获取购物车信息
function GroupPurchaseView:SetCartData()
	self.cart_data_list = GroupPurchaseData.Instance:GetCartData()
	self:FlushCartList()
	self:SetPrice()
end

--刷新物品列表
function GroupPurchaseView:FlushPurchaseList(flag)
	if self.node_list["ListView"] and nil ~= self.node_list["ListView"].list_view and self.node_list["ListView"].list_view.isActiveAndEnabled then
		self.node_list["ListView"].list_view:Reload()
		if flag then
			self.node_list["ListView"].list_view:JumpToIndex(0)
		end
	end
end

--刷新购物车列表
function GroupPurchaseView:FlushCartList()
	if self.node_list["CartListView"] and nil ~= self.node_list["CartListView"].list_view and self.node_list["CartListView"].list_view.isActiveAndEnabled then
		self.node_list["CartListView"].list_view:Reload()
		self.node_list["CartListView"].list_view:JumpToIndex(0)
	end
end

--设置描述
function GroupPurchaseView:SetGroupPurchaseDes()
	local cfg = GroupPurchaseData.Instance:GetBuyDiscountCfg() or {}
	local des = Language.GroupPurchase.DesOne .."\n"
	for i,v in pairs(cfg) do
		local item_count = v.item_count
		local discount = v.discount
		if item_count and discount then
				local dis = math.floor(discount / 10)
				local dis_num = discount % 10
				if dis_num == 0 then
					self.node_list["Discount"..i.."_img1"]:SetActive(true)
					self.node_list["Discount"..i.."_img2"]:SetActive(false)
					self.node_list["Discount"..i.."_img3"]:SetActive(false)
					local bundle, asset = ResPath.GetGroupPurchaseImg("img_discount"..dis)
					self.node_list["Discount"..i.."_img1"].image:LoadSprite(bundle, asset, function()
						self.node_list["Discount"..i.."_img1"].image:SetNativeSize()
					end)
					
				else
					self.node_list["Discount"..i.."_img1"]:SetActive(true)
					self.node_list["Discount"..i.."_img2"]:SetActive(true)
					self.node_list["Discount"..i.."_img3"]:SetActive(true)
					local bundle2, asset2 = ResPath.GetGroupPurchaseImg("img_discount"..dis)
					self.node_list["Discount"..i.."_img1"].image:LoadSprite(bundle2, asset2, function()
						self.node_list["Discount"..i.."_img1"].image:SetNativeSize()
					end)
					local bundle1, asset1 = ResPath.GetGroupPurchaseImg("img_discount"..dis_num)
					self.node_list["Discount"..i.."_img3"].image:LoadSprite(bundle1, asset1, function()
						self.node_list["Discount"..i.."_img3"].image:SetNativeSize()
					end)
				end
			-- end
			-- if i == #cfg then
			-- 	des = des .. string.format(Language.GroupPurchase.DesThree, item_count, dis)
			-- else
			-- 	des = des .. string.format(Language.GroupPurchase.DesTwo, item_count, dis)
			-- end
		end
	end
	-- self.des:SetValue(des)
	-- self.node_list["TextDesBg"].text.text = des
end

function GroupPurchaseView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "has_buy_info" then
			self:SetPurchaseData()
			self:SetGroupPurchaseDes()
		elseif k == "cart_info" then
			self:SetCartData()
		end
	end

	self:FlushActivityTimeCountDown()
end

function GroupPurchaseView:OnClickClose()
	self:Close()
end

function GroupPurchaseView:OnClickHelp()
	local tip_id = 304
	TipsCtrl.Instance:ShowHelpTipView(tip_id)
end

--全部购买
function GroupPurchaseView:OnClickAllBuy()
	local cart_num = self:GetCartNumberOfCells()
	if cart_num <= 0 then
		local str = Language.GroupPurchase.CartNoItem
		TipsCtrl.Instance:ShowSystemMsg(str)
		return
	end

	local vo = GameVoManager.Instance:GetMainRoleVo()
	if self.discount_price and vo.gold < self.discount_price then
		TipsCtrl.Instance:ShowLackDiamondView()
		return
	end

	local opera_type = RA_COMBINE_BUY_OPERA_TYPE.RA_COMBINE_BUY_OPERA_TYPE_BUY
	GroupPurchaseCtrl.Instance:SendRandActivityOperaReqReq(opera_type)
end

--toggle点击事件
function GroupPurchaseView:OnClickToggle(index)
	if index and self.select_buy_type == index then
		return
	end

	self.select_buy_type = index
	self:SetPurchaseData(true)
end

function GroupPurchaseView:GetNumberOfCells()
	local num = self.purchase_data_list and #self.purchase_data_list or 0
	return num
end

function GroupPurchaseView:RefreshCell(cell_index, cellObj)
	local purchase_cell = self.purchase_cell_list[cellObj]
	if nil == purchase_cell then
		purchase_cell = GroupPurchaseCell.New(cellObj)
		purchase_cell:SetClickCallBack(BindTool.Bind(self.OnClickPurchaseCellCallBack, self))
		self.purchase_cell_list[cellObj] = purchase_cell
	end

	local data = self.purchase_data_list[cell_index + 1]
	purchase_cell:SetData(data)
end

--加入购物车
function GroupPurchaseView:OnClickPurchaseCellCallBack(cell)
	if nil == cell then
		return
	end

	--检测是否超过购物车容纳上限
	local cart_num = self:GetCartNumberOfCells()
	if cart_num >= GameEnum.RA_COMBINE_BUY_BUCKET_ITEM_COUNT then
		local str = Language.GroupPurchase.CartNotCanAdd
		TipsCtrl.Instance:ShowSystemMsg(str)
		return
	end

	local data = cell:GetData()
	if nil == data or nil == data.seq then
		return
	end

	--检测是否达到物品购买上限
	local is_can_buy = GroupPurchaseData.Instance:GetIsCanBuyBySeq(data.seq)
	if not is_can_buy then
		local str = Language.GroupPurchase.NotCanBuy
		TipsCtrl.Instance:ShowSystemMsg(str)
		return
	end

	local opera_type = RA_COMBINE_BUY_OPERA_TYPE.RA_COMBINE_BUY_OPERA_TYPE_ADD_IN_BUCKET
	local param1 = data.seq
	GroupPurchaseCtrl.Instance:SendRandActivityOperaReqReq(opera_type, param1)
end

function GroupPurchaseView:GetCartNumberOfCells()
	local num = self.cart_data_list and #self.cart_data_list or 0
	return num
end

function GroupPurchaseView:RefreshCartCell(cell_index, cellObj)
	local cart_cell = self.cart_cell_list[cellObj]
	if nil == cart_cell then
		cart_cell = GroupCartCell.New(cellObj)
		cart_cell:SetClickCallBack(BindTool.Bind(self.OnClickCartCellCallBack, self))
		self.cart_cell_list[cellObj] = cart_cell
	end

	local data = self.cart_data_list[cell_index + 1]
	cart_cell:SetData(data)
end

--移除购物车
function GroupPurchaseView:OnClickCartCellCallBack(cart_cell)
	if nil == cart_cell then
		return
	end

	local data = cart_cell:GetData()
	if nil == data or nil == data.index then
		return
	end

	local opera_type = RA_COMBINE_BUY_OPERA_TYPE.RA_COMBINE_BUY_OPERA_TYPE_REMOVE_BUCKET
	local param1 = data.index
	GroupPurchaseCtrl.Instance:SendRandActivityOperaReqReq(opera_type, param1)
end

--设置价格
function GroupPurchaseView:SetPrice()
	local is_dicount, all_price, discount_price = GroupPurchaseData.Instance:GetCartAllPriceAndDiscountPrice()
	self.discount_price = discount_price
	self.node_list["TextOriginal"].text.text = all_price
	self.node_list["TextAfterDiscount"].text.text = discount_price
	self.node_list["IsShowPrice"]:SetActive(is_dicount)
end

--刷新活动剩余时间
function GroupPurchaseView:FlushActivityTimeCountDown()
	self:CancelTimeQuest()
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end
end

function GroupPurchaseView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GROUP_PURCHASE)
	local timer = ""
	if time <= 0 then
		self:CancelTimeQuest()
	end
	timer = TimeUtil.FormatSecond(time, 10)
	self.node_list["TextLeftTime"].text.text = string.format(Language.Activity.ActivityTime1, ToColorStr(timer, TEXT_COLOR.GREEN_4)) 
end

function GroupPurchaseView:CancelTimeQuest()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

------------------------------------------物品Item------------------------------------------------
GroupPurchaseCell = GroupPurchaseCell or BaseClass(BaseCell)

function GroupPurchaseCell:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])

	self.node_list["BtnAddCart"].button:AddClickListener(BindTool.Bind(self.OnClickAddCart, self))
end

function GroupPurchaseCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function GroupPurchaseCell:SetData(data)
	self.data = data
	self:OnFlush()
end

function GroupPurchaseCell:OnFlush()
	if nil == self.data then
		return 
	end

	local seq = self.data.seq or 0
	self.node_list["TextPrice"].text.text = self.data.price or 0

	--此处判断改成是否售完
	local is_sell_out = GroupPurchaseData.Instance:IsSellOut(seq)
	self.node_list["IsCanBuy"]:SetActive(not is_sell_out)
	self.node_list["TextBuy"]:SetActive(is_sell_out)
	UI:SetButtonEnabled(self.node_list["BtnAddCart"], not is_sell_out)
	UI:SetGraphicGrey(self.node_list["TextBuy"], is_sell_out)

	local limit_num = self.data.buy_limit or 0
	self.node_list["TextPurchaseNum"]:SetActive(limit_num ~= 0)
	if limit_num ~= 0 then
		local has_buy_num = GroupPurchaseData.Instance:GetItemHasPurchaseNumBySeq(seq)
		local color = has_buy_num < limit_num and "89F201FF" or "ff0000"
		local surplus_times = limit_num - has_buy_num
		self.node_list["TextPurchaseNum"].text.text = string.format(Language.GroupPurchase.HasPurchaseNum, color, surplus_times)
	end

	local item_list = self.data.item
	if item_list then
		local item_id = item_list.item_id
		local cfg = ItemData.Instance:GetItemConfig(item_id)
		if cfg and cfg.name then
			self.node_list["TextTile"].text.text = cfg.name-- "<color="..SOUL_NAME_COLOR[cfg.color]..">"..cfg.name.."</color>"
		end
		self.item_cell:SetData(self.data.item)
	end
end

function GroupPurchaseCell:OnClickAddCart()
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end

-----------------------------------------购物车Item-------------------------------------------------
GroupCartCell = GroupCartCell or BaseClass(BaseCell)

function GroupCartCell:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])

	self.node_list["BtnCancel"].button:AddClickListener(BindTool.Bind(self.OnClickCancel, self))
end

function GroupCartCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function GroupCartCell:SetData(data)
	self.data = data
	self:OnFlush()
end

function GroupCartCell:OnFlush()
	if nil == self.data or nil == self.data.seq then
		return 
	end

	local cfg = GroupPurchaseData.Instance:GetSingleTypeBuyItemCfgBySeq(self.data.seq)
	if nil == cfg or nil == cfg.item then
		return
	end

	self.item_cell:SetData(cfg.item)
end

function GroupCartCell:OnClickCancel()
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end
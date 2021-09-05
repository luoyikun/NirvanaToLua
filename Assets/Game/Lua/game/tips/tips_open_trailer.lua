TipsOpenTrailerView = TipsOpenTrailerView or BaseClass(BaseView)
function TipsOpenTrailerView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/tips/funtrailer_prefab", "NewFunTrailerTips"}}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.cur_page = 1
	self.list = {}

	self.is_cell_active = false
	self.is_scroll_create = false
end

function TipsOpenTrailerView:__delete()

end

function TipsOpenTrailerView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close,self))

	self.node_list["Bg"].rect.sizeDelta = Vector3(1128, 600, 0)
	self.node_list["Txt"].text.text = Language.Mainui.TrailerTitle
	self.node_list["ListView"].list_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.node_list["ListView"].list_simple_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.node_list["ListView"].scroller.scrollerScrolled = function()
		if not self.is_scroll_create then
			if self.is_cell_active and self.node_list["ListView"] and self.node_list["ListView"].scroller.isActiveAndEnabled then
				self.node_list["ListView"].scroller:JumpToDataIndex(OpenFunData.Instance:GetTrailerLastRewardId())
				self.is_scroll_create = true
			end
		end
	end
end

function TipsOpenTrailerView:ReleaseCallBack()
	for k, v in pairs(self.list) do
		if v then
			v:DeleteMe()
		end
	end
	self.is_cell_active = false
	self.is_scroll_create = false
end

function TipsOpenTrailerView:OpenCallBack()
	self:Flush()
end
function TipsOpenTrailerView:CloseCallBack()
	self.is_cell_active = false
	self.is_scroll_create = false
end
function TipsOpenTrailerView:OnFlush()
	if not self.is_scroll_create then
		self.node_list["ListView"].scroller:ReloadData(OpenFunData.Instance:GetTrailerLastRewardId() / #OpenFunData.Instance:GetNoticeList())
	else
		self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function TipsOpenTrailerView:SetData(cfg)
end

function TipsOpenTrailerView:GetNumberOfCells()
	return #OpenFunData.Instance:GetNoticeList()
end

function TipsOpenTrailerView:RefreshCell(cell, data_index)
	local cell_item = self.list[cell]
	if cell_item == nil then
		cell_item = TrailerTipsItem.New(cell.gameObject)
		cell_item:SetClickCallback(BindTool.Bind(self.SelectItemCallback, self))
		self.list[cell] = cell_item
	end
	local open_cfg = OpenFunData.Instance:GetNoticeList()
	local data = {}
	data.cfg = open_cfg[data_index + 1]
	data.index = data_index + 1 
	cell_item:SetData(data)

	self.is_cell_active = true
end

function TipsOpenTrailerView:SelectItemCallback(cell)
	if cell == nil or cell.data.index == nil then return end
	local open_cfg = OpenFunData.Instance:GetNoticeList()[cell.data.index]
	if open_cfg then
		OpenFunCtrl.Instance:SendAdvanceNoitceOperate(ADVANCE_NOTICE_OPERATE_TYPE.ADVANCE_NOTICE_FETCH_REWARD, open_cfg.id)
		local level = GameVoManager.Instance:GetMainRoleVo().level
		if level >= open_cfg.end_level then
			self:Close()
			if open_cfg.open_panel_name ~= "" then
				ViewManager.Instance:OpenByCfg(open_cfg.open_panel_name)
			end
		end
	end
end


TrailerTipsItem = TrailerTipsItem or BaseClass(BaseRender)

function TrailerTipsItem:__init()
end

function TrailerTipsItem:LoadCallBack()
	self.item_list = {}
	for i = 1, 2 do
		self.item_list[i] = {}
		self.item_list[i].root = self.node_list["Item" .. i]
		self.item_list[i].item = ItemCell.New()
		self.item_list[i].item:SetInstanceParent(self.item_list[i].root)
		self.item_list[i].item:ListenClick(BindTool.Bind(self.OnClickItem, self, i))
	end
	self.node_list["ButItem"].button:AddClickListener(BindTool.Bind(self.OnClickItem,self))
end

function TrailerTipsItem:__delete()
	for k,v in pairs(self.item_list) do
		v.item:DeleteMe()
	end
	self.item_list = {}
end

function TrailerTipsItem:SetData(data)
	if not data then return end
	self.data = data
	self:Flush()
end

function TrailerTipsItem:OnFlush()
	if self.data == nil then return end
	local bundle, asset = ResPath.GetMainIcon(self.data.cfg.icon_view)
	self.node_list["ImgIcon"].image:LoadSprite(bundle, asset)
	if self.node_list["IconName"] then
		self.node_list["IconName"].image:LoadSprite(bundle, asset .. "Name", function()
			self.node_list["IconName"].image:SetNativeSize()
			self.node_list["IconName"].transform:SetLocalScale(1.2, 1.2, 1.2)
		end)
	end
	self.node_list["TxtDesc"].text.text = self.data.cfg.fun_dec

	local desc_list = Split(self.data.cfg.open_dec, "#")
	local desc = ""
	if #desc_list == 1 then
		desc = self.data.cfg.open_dec
	else
		desc = desc_list[1] .. desc_list[2]
	end
	self.node_list["TxtOpenDesc"].text.text = desc
	self.node_list["TitleText"].text.text = string.format(Language.FuBen.WeaponFuBenTip, self.data.cfg.end_level)

	local is_can_reward = self.data.cfg.id == OpenFunData.Instance:GetTrailerLastRewardId() + 1
	local is_show_item = GameVoManager.Instance:GetMainRoleVo().level >= self.data.cfg.end_level
	for k,v in pairs(self.item_list) do
		if self.data.cfg.reward_item[k -1] then
			v.item:SetData(self.data.cfg.reward_item[k -1])
			v.item:ShowItemRewardEffect(is_show_item and is_can_reward)
		end
		v.root:SetActive(k == 1)
	end
	self.node_list["OpenNeed"]:SetActive(false)
	self.node_list["Yilingqu"]:SetActive(not is_can_reward and self.data.cfg.id <= OpenFunData.Instance:GetTrailerLastRewardId() + 1)
	-- self.node_list["ItemList"]:SetActive(is_show_item)
	self.node_list["ImgBlock"]:SetActive(not is_show_item or self.data.cfg.id > OpenFunData.Instance:GetTrailerLastRewardId() + 1)
	self:IsSelect(is_can_reward)
	self:GetRootNode().transform.localScale = is_can_reward and Vector3(1, 1, 1) or Vector3(0.92, 0.92, 0.92)
end

function TrailerTipsItem:IsSelect(value)
	self.node_list["RawImgSelect"]:SetActive(value)
end

function TrailerTipsItem:SetClickCallback(handler)
	self.handler = handler
end

function TrailerTipsItem:OnClickItem()
	if self.data and self.data.cfg then
		if self.data.cfg.id ~= OpenFunData.Instance:GetTrailerLastRewardId() + 1 then
			return
		end
	end
	if self.handler then
		self.handler(self)
	end
end
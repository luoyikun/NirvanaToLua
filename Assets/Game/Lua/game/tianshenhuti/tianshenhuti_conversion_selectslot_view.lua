TianshenhutiSelectSlotView = TianshenhutiSelectSlotView or BaseClass(BaseView)

function TianshenhutiSelectSlotView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/tianshenhutiview_prefab", "ConversionSelectSlotView"},
	}
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TianshenhutiSelectSlotView:__delete()

end

function TianshenhutiSelectSlotView:CloseCallBack()

end

function TianshenhutiSelectSlotView:ReleaseCallBack()
	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function TianshenhutiSelectSlotView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(666,356,0)
	self.node_list["Txt"].text.text = Language.Tianshenhuti.SelectPart
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))

	self.cell_list = {}
	local equip_parent = self.node_list["SlotParent"]
	local res_async_loader = AllocResAsyncLoader(self, "TianShen_Conversion_Select")
	res_async_loader:Load("uis/views/tianshenhutiview_prefab", "Slot", nil,
		function(prefab)
			for i = 1,GameEnum.TIANSHENHUTI_EQUIP_MAX_COUNT do
				local obj = ResMgr:Instantiate(prefab)
				obj.transform:SetParent(equip_parent.transform, false)
				obj = U3DObject(obj)
				item = TianshenhutiConversionSlotCell.New(obj)
				item:ListenClick(BindTool.Bind(self.ItemCellClick, self, i - 1))
				self.cell_list[i] = item
			end
			self:Flush()
		end)

	self.is_show_name = true
end

function TianshenhutiSelectSlotView:CloseWindow()
	self:Close()
end

function TianshenhutiSelectSlotView:OpenCallBack()
	self:Flush()
end

function TianshenhutiSelectSlotView:SetCallBack(call_back)
	self.call_back = call_back
end

function TianshenhutiSelectSlotView:ItemCellClick(index)
	if self.call_back ~= nil then
		self.call_back(index)
		self.call_back = nil
	end
	self:Close()
end


function TianshenhutiSelectSlotView:OnFlush(param_list)
	for k,v in pairs(self.cell_list) do
		v:SetData(k - 1)
		v:SetShowName(self.is_show_name)
	end
end

function TianshenhutiSelectSlotView:SetShowName(enable)
	self.is_show_name = enable or true
end


-------------------TianshenhutiConversionSlotCell-----------------------
TianshenhutiConversionSlotCell = TianshenhutiConversionSlotCell or BaseClass(BaseCell)
function TianshenhutiConversionSlotCell:__init()
	
end

function TianshenhutiConversionSlotCell:__delete()

end

function TianshenhutiConversionSlotCell:OnFlush()
	local select_data_t = TianshenhutiData.Instance:GetComposeSelectList()
	local  select_data = select_data_t[1] or select_data_t[2]
	if self.data == nil or nil == select_data then
		self:SetIcon()
		self.node_list["TxtName"].text.text = ""
		self:SetDefualtQuality()
		return
	end
	local item_cfg = TianshenhutiData.Instance:GetEquipCfg(self.data * GameEnum.TIANSHENHUTI_EQUIP_MAX_COUNT + 1)
	if item_cfg then
		local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
		self:SetIcon(bundle, asset)
	end
	self.node_list["TxtName"].text.text = Language.Tianshenhuti.EquipSlot[self.data]
	local bundle1, asset1 = ResPath.GetQualityIcon(6)
	local item_cfg = TianshenhutiData.Instance:GetEquipCfg(select_data.item_id)
	if item_cfg then
		bundle1, asset1 = ResPath.GetQualityIcon(item_cfg.color)
	end
	self.node_list["BgQuality"].image:LoadSprite(bundle1, asset1)
end

function TianshenhutiConversionSlotCell:SetIcon(bundle, asset)
	if nil ==  bundle or nil == asset then 
		self.node_list["ImgIcon"]:SetActive(false)
		return 
	end
	self.node_list["ImgIcon"]:SetActive(true)
	self.node_list["ImgIcon"].image:LoadSprite(bundle, asset)
end

function TianshenhutiConversionSlotCell:SetDefualtQuality()
	local bundle1, asset1 = ResPath.GetQualityIcon(5)
	self.node_list["BgQuality"].image:LoadSprite(bundle1, asset1)
end

function TianshenhutiConversionSlotCell:ListenClick(handler)
	self.node_list["Slot"].button:AddClickListener(handler)
end

function TianshenhutiConversionSlotCell:SetShowName(enable)
	self.node_list["TxtName"]:SetActive(enable)
end
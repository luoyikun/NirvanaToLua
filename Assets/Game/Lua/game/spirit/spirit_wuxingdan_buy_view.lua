-- 仙宠-悟性丹收购
SpiritWuxingdanBuyView = SpiritWuxingdanBuyView or BaseClass(BaseView)

function SpiritWuxingdanBuyView:__init(instance)
self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/spiritview_prefab", "WuXingDanBuyView"},
	}
	
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.is_modal = true
	self.is_any_click_close = true
end

function SpiritWuxingdanBuyView:LoadCallBack(instance)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["Bg"].rect.sizeDelta = Vector3(700, 400, 0)
	self.node_list["Txt"].text.text = Language.JingLing.TabbarName[16]
	self.node_list["BtnBuy"].button:AddClickListener(BindTool.Bind(self.OnClickBtnBuy, self))

	self.item_list = {}
	for i = 1, 4 do
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["Item" .. i])
		item:ListenClick(BindTool.Bind(self.OnClickItem, self, i, item))
		item:SetToggleGroup(self.node_list["ItemList"].toggle_group)
		table.insert(self.item_list, item)
	end

	self:SetItemCellData()

	self.select_stuff_id = 0
end

function SpiritWuxingdanBuyView:OpenCallBack()
	 local wuxing_cfg = SpiritData.Instance:GetWuXingDanCfg()
	 -- self.select_stuff_id = wuxing_cfg[1].stuff_id
	 -- self.item_list[1]:ShowHighLight(true)
	local item_id = SpiritData.Instance:GetSelectSpiritItemId() or 0
	local color = ItemData.Instance:GetItemQuailty(item_id)
	for k,v in pairs(wuxing_cfg) do
		local wuxing_color = ItemData.Instance:GetItemQuailty(v.stuff_id) or 0
		if color == wuxing_color then
			if self.item_list[k] then
				self.item_list[k]:ShowHighLight(true)
				self.select_stuff_id = v.stuff_id
			end
		end
	end
end

function SpiritWuxingdanBuyView:CloseCallBack()
	self.select_stuff_id = 0
end



function SpiritWuxingdanBuyView:OnClickItem(index)
	 local wuxing_cfg = SpiritData.Instance:GetWuXingDanCfg()
	 self.select_stuff_id = wuxing_cfg[index].stuff_id
end

function SpiritWuxingdanBuyView:SetItemCellData()
	 local wuxing_cfg = SpiritData.Instance:GetWuXingDanCfg()
	 if nil == wuxing_cfg then
	 	return
	 end

	 for k, v in pairs(wuxing_cfg) do
	 	if v.stuff_id == 27832 or v.stuff_id == 27795 then
	 		self.node_list["Item" .. k]:SetActive(false)
	 	else
	 		if self.item_list[k] then
			 	self.item_list[k]:SetData({item_id = v.stuff_id})
			 	self.node_list["Item" .. k]:SetActive(true)
			end
		end
	 end
end

function SpiritWuxingdanBuyView:__delete()
	self.select_stuff_id = nil
end

function SpiritWuxingdanBuyView:ReleaseCallBack()

	if self.item_list then
		for k,v in pairs(self.item_list) do
			v:DeleteMe()
		end
	end
	self.item_list = {}
end

function SpiritWuxingdanBuyView:OnFlush(param_list)
	
end

function SpiritWuxingdanBuyView:OnClickBtnBuy()
	if not ChatData.Instance:GetChannelCdIsEnd(CHANNEL_TYPE.WORLD) then
		local time = ChatData.Instance:GetChannelCdEndTime(CHANNEL_TYPE.WORLD) - Status.NowTime
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Chat.CanNotChat, math.ceil(time)))
		return
	end

	if self.select_stuff_id and self.select_stuff_id > 0 then
		local text = string.format(Language.WantBuy[math.random(1, #Language.WantBuy)], self.select_stuff_id)
		ChatData.Instance:SetChannelCdEndTime(CHANNEL_TYPE.WORLD)
		ChatCtrl.SendChannelChat(CHANNEL_TYPE.WORLD, text, content_type)
		TipsCtrl.Instance:ShowSystemMsg(Language.GetBuyChat.Send)
		self:Close()
	end
end

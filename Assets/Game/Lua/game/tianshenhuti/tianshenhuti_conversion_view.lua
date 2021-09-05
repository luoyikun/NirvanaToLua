--无双装备转化
TianshenhutiConversionView = TianshenhutiConversionView or BaseClass(BaseRender)

function TianshenhutiConversionView:__init()
	self.select_slot = -1

	local res_async_loader = AllocResAsyncLoader(self, "TianShen_Conversion")
	res_async_loader:Load("uis/views/tianshenhutiview_prefab", "Slot", nil,
		function(prefab)
			local obj = ResMgr:Instantiate(prefab)
			obj.transform:SetParent(self.node_list["HeChenngItem"].transform, false)
			obj = U3DObject(obj)
			self.item = TianshenhutiConversionSlotCell.New(obj)
			self.item:SetDefualtQuality()
			self.item:ListenClick(BindTool.Bind(self.OnClickSelectSlot, self, i))
			self:Flush()
		end)

	self.item_list = {}
	for i = 1, 2 do
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["Item"..i])
		item:SetInteractable(true)
		item:ListenClick(BindTool.Bind(self.OnClickItem, self, i))
		self.item_list[i] = item
	end

	self.node_list["BtnYes"].button:AddClickListener(BindTool.Bind(self.OnClickYes, self))
	self.node_list["BtnNo"].button:AddClickListener(BindTool.Bind(self.OnClickNo, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["TxtName"].button:AddClickListener(BindTool.Bind(self.OnClickSelectSlot, self))

	self.data_change_event = BindTool.Bind(self.OnDataChange, self)
	TianshenhutiData.Instance:AddListener(TianshenhutiData.COMPOSE_SELECT_CHANGE_EVENT, self.data_change_event)
end

function TianshenhutiConversionView:__delete()
	if nil ~= TianshenhutiData.Instance and self.data_change_event then
		TianshenhutiData.Instance:RemoveListener(TianshenhutiData.COMPOSE_SELECT_CHANGE_EVENT, self.data_change_event)
		self.data_change_event = nil
	end
	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end
	if self.item_list then
		for k,v in pairs(self.item_list) do
			v:DeleteMe()
		end
		self.item_list = {}
	end
end

function TianshenhutiConversionView:UITween()
	UITween.MoveShowPanel(self.node_list["BtnHelp"], Vector3(-176, 40, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["ButtonFrame"], Vector3(-65, -70, 0), 0.7)
	UITween.AlpahShowPanel(self.node_list["MaskCenter"], true, 0.5, DG.Tweening.Ease.InExpo)
end

function TianshenhutiConversionView:OpenCallBack()
	self.select_slot = -1
	self:Flush()
	TianshenhutiData.Instance:ClearComposeSelectList()
end

function TianshenhutiConversionView:CloseCallBack()

end

function TianshenhutiConversionView:OnClickItem(index)
	local tsht_data = TianshenhutiData.Instance

	if tsht_data:GetComposeSelect(index) then --，如果有,清除当前的
		tsht_data:DelComposeSelect(index)
		return
	end

	local select_data = tsht_data:GetCanComposeDataList()
	if next(select_data) == nil then
		SysMsgCtrl.Instance:ErrorRemind(Language.Tianshenhuti.NoCanSelectTips)
		return
	end

	TianshenhutiCtrl.Instance:ShowSelectView(index, {}, "") --弹出神格面板
end

function TianshenhutiConversionView:OnClickYes()
	local data_list = TianshenhutiData.Instance:GetComposeSelectList()
	if self.select_slot < 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Tianshenhuti.SelectSlotTips)
		return
	end
	if data_list[1] == nil or data_list[2] == nil then
		SysMsgCtrl.Instance:ErrorRemind(Language.Equip.XuanzeZhuangBei)
		return
	end
	TianshenhutiCtrl.SendTianshenhutiTransform(data_list[1].index, data_list[2].index, self.select_slot)
end

function TianshenhutiConversionView:OnClickSelectSlot()
	local data_list = TianshenhutiData.Instance:GetComposeSelectList()
	if data_list[1] == nil or data_list[2] == nil then
		SysMsgCtrl.Instance:ErrorRemind(Language.Equip.XuanzeZhuangBei)
		return
	end
	TianshenhutiCtrl.Instance:OpenSelectSlot(BindTool.Bind(self.SelectSlotCallBack, self))
end

function TianshenhutiConversionView:SelectSlotCallBack(index)
	self.select_slot = index
	local select_name_str = Language.Tianshenhuti.EquipSlot[index] or ""
	self.node_list["TxtName"].text.text = self.select_slot > -1 and select_name_str or Language.Tianshenhuti.SelectConversionTips
	self.item:SetData(self.select_slot)
	self.item:SetShowName(false)
end

function TianshenhutiConversionView:OnClickNo()
	TianshenhutiData.Instance:ClearComposeSelectList()
end

function TianshenhutiConversionView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(336)
end

function TianshenhutiConversionView:OnDataChange(data_list)
	self:InitItemData(data_list)
end

function TianshenhutiConversionView:InitItemData(index)
	local data_list = TianshenhutiData.Instance:GetComposeSelectList()
	if index then
		if self.item_list[index] then
			if data_list[index] then
				local data = TianshenhutiData.Instance:GetEquipItemIdCfgByCfg(data_list[index].item_id)
				self.item_list[index]:SetData(data)
			else
				self.item_list[index]:SetData(nil)
			end
			self.node_list["BtnPlus" .. index]:SetActive(data_list[index] == nil)
		end
	else
		for k, v in pairs(self.item_list) do
			if data_list[k] then
				local data = TianshenhutiData.Instance:GetEquipItemIdCfgByCfg(data_list[k].item_id)
				v:SetData(data)
			else
				v:SetData(nil)
			end
			self.node_list["BtnPlus" .. k]:SetActive(data_list[k] == nil)
		end
	end
	if data_list[1] == nil and data_list[2] == nil then
		self.select_slot = -1
		self:ClearComposeData()
	end
end

function TianshenhutiConversionView:ClearComposeData()
	if self.item == nil then return end
	self.item:SetData()
	self.item:SetDefualtQuality()

	local select_name_str = Language.Tianshenhuti.EquipSlot[index] or ""
	self.node_list["TxtName"].text.text = self.select_slot > -1 and select_name_str or Language.Tianshenhuti.SelectConversionTips
end

function TianshenhutiConversionView:OnFlush(param_t)
	if self.select_slot < 0 then
		self:ClearComposeData()
	elseif self.item then
		self.item:SetData(self.select_slot)
	end
end
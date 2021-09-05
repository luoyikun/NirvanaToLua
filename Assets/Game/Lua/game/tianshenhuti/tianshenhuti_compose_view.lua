TianshenhutiComposeView = TianshenhutiComposeView or BaseClass(BaseRender)
function TianshenhutiComposeView:__init()
	
end

function TianshenhutiComposeView:LoadCallBack(instance)
	self.item = ItemCell.New()     --中间神格
	self.item:SetInstanceParent(self.node_list["ComposeItemCell"])
	self.item_list = {}
	for i = 1, 3 do
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["ItemCell"..i])
		item:SetInteractable(true)
		item:ListenClick(BindTool.Bind(self.OnClickItem, self, i))
		self.item_list[i] = item
	end


	self.node_list["BtnReset"].button:AddClickListener(BindTool.Bind(self.OnClickReset, self))
	self.node_list["BtnCompose"].button:AddClickListener(BindTool.Bind(self.OnClickCompose, self))
	self.node_list["BtnAutoCopose"].button:AddClickListener(BindTool.Bind(self.OnClickAutoCompose, self))
	self.node_list["BtnTips"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))

	self.data_change_event = BindTool.Bind(self.OnDataChange, self)
	TianshenhutiData.Instance:AddListener(TianshenhutiData.COMPOSE_SELECT_CHANGE_EVENT, self.data_change_event)
end

function TianshenhutiComposeView:__delete()
	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end
	if self.item_list then
		for i = 1,3 do
			self.item_list[i]:DeleteMe()
			self.item_list[i] = nil
		end
	end
	self.item_list = {}
	if nil ~= TianshenhutiData.Instance and self.data_change_event then
		TianshenhutiData.Instance:RemoveListener(TianshenhutiData.COMPOSE_SELECT_CHANGE_EVENT, self.data_change_event)
		self.data_change_event = nil
	end
end

function TianshenhutiComposeView:OpenCallBack()
	TianshenhutiData.Instance:ClearComposeSelectList()
end


function TianshenhutiComposeView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(335)
end

function TianshenhutiComposeView:OnDataChange(index)
	self:InitItemData(index)
end

function TianshenhutiComposeView:InitItemData(index)
	local data_list = TianshenhutiData.Instance:GetComposeSelectList()
	if index then
		if self.item_list[index] then
			if data_list[index] then
				local item_data = TianshenhutiData.Instance:GetEquipItemIdCfgByCfg(data_list[index].item_id or 0)
				if item_data then
					self.item_list[index]:SetData(item_data)
				end
			else
				self.item_list[index]:SetData(nil)
			end
			self.node_list["ImgAdd" .. index]:SetActive(data_list[index] == nil)
		end
	else
		for k, v in pairs(self.item_list) do
			if data_list[k] then
				local item_data = TianshenhutiData.Instance:GetEquipItemIdCfgByCfg(data_list[k].item_id or 0)
				if item_data then
					v:SetData(item_data)
				end
			else
				v:SetData(nil)
			end
			self.node_list["ImgAdd" .. k]:SetActive(data_list[k] == nil)
		end
	end
	if next(data_list) then
		self:ClearComposeData()
	end
end

function TianshenhutiComposeView:ClearComposeData()
	self.item:SetData()
end


function TianshenhutiComposeView:OnClickItem(index)
	if TianshenhutiData.Instance:GetComposeSelect(index) then --，如果有,清除当前的
		TianshenhutiData.Instance:DelComposeSelect(index)
		return
	end

	local select_data = TianshenhutiData.Instance:GetCanComposeDataList(true)
	if next(select_data) == nil then
		SysMsgCtrl.Instance:ErrorRemind(Language.Tianshenhuti.NoCanSelectTips)
		return
	end

	TianshenhutiCtrl.Instance:ShowSelectView(index, {}, "from_compose") --弹出神格面板
	self.item:SetData()
end

function TianshenhutiComposeView:UITween()
	UITween.MoveShowPanel(self.node_list["BtnTips"], Vector3(-60, 90, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["BottomContent"], Vector3(1, -90, 0), 0.7)
	UITween.AlpahShowPanel(self.node_list["ComposeMat"], true, 0.5, DG.Tweening.Ease.InExpo)
end

function TianshenhutiComposeView:OnClickReset()
	TianshenhutiData.Instance:ClearComposeSelectList()
end

function TianshenhutiComposeView:OnClickCompose()
	local data_list = TianshenhutiData.Instance:GetComposeSelectList()
	if data_list[1] == nil or data_list[2] == nil or data_list[3] == nil then
		SysMsgCtrl.Instance:ErrorRemind(Language.Equip.XuanzeZhuangBei)
		return
	end
	TianshenhutiCtrl.SendTianshenhutiCombine(data_list[1].index, data_list[2].index, data_list[3].index)
end

function TianshenhutiComposeView:OnClickAutoCompose()
	TianshenhutiCtrl.Instance:OpenOneKeyCompose()
end
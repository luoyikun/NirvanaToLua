ComposeContentView = ComposeContentView or BaseClass(BaseRender)
local EFFECT_CD = 1
local BaoShiDai = 16
local JingJieLingPai = 36
local ShengQi = 39
local ShenMo = 50
function ComposeContentView:__init(instance)
	ComposeContentView.Instance = self
	self.node_list["BtnSelectMax"].button:AddClickListener(BindTool.Bind(self.MaxBtnOnClick, self))
	self.node_list["BtnInput"].button:AddClickListener(BindTool.Bind(self.OnInputClick, self))
	self.node_list["BtnCompose"].button:AddClickListener(BindTool.Bind(self.ComposeBtnClick, self))

	self.node_list["select_toggle"].toggle:AddValueChangedListener(BindTool.Bind(self.OnSelectShowClick, self))
	self.the_item_list = {}
	self.btn_num = 15
	for i = 1, 4 do
		local handler = function()
			local close_call_back = function()
				self.the_item_list[i].item_cell:ShowHighLight(false)
			end
			local data = {}
			if self.the_item_list[i] and self.the_item_list[i].item_cell then
				data = self.the_item_list[i].item_cell:GetData()
			end
			if data.item_id ~= nil then
				self.the_item_list[i].item_cell:ShowHighLight(true)
				TipsCtrl.Instance:OpenItem(data, nil, nil, close_call_back)
			end
		end
		self.the_item_list[i] = {}
		self.the_item_list[i].item_cell = ItemCell.New()
		self.the_item_list[i].item_cell:SetInstanceParent(self.node_list["item_cell_" .. i])
		self.the_item_list[i].item_cell:ListenClick(handler)
	end

	for i = 1, self.btn_num do
		if i ~= 9 and i ~= 10 then
			self.node_list["select_btn_" .. i].toggle:AddClickListener(BindTool.Bind(self.OnClickSelect, self, i))
		end
	end

	self.current_type = -1
	self.buy_num = -1
	self.list_index = 1
	self.item_list = {}
	self.item_cell_list = {}
	self.current_item_id = 0
	self.item_data_event = nil
	self.effect_cd = 0
	self.is_buy_quick = false

end

function ComposeContentView:__delete()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	self.effect_cd = nil

	for k, v in pairs(self.the_item_list) do
		if v.item_cell then
			v.item_cell:DeleteMe()
		end
	end
	self.the_item_list = {}
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	self:DestoryGameObject()
end

function ComposeContentView:UpdateList(type)
	local compose_data = ComposeData.Instance
	local compose_item_list = compose_data:GetTypeOfAllItem(type)
	local can_compose_id = compose_data:CheckBagMat(compose_item_list)
	local to_product_id = compose_data:GetToProductId()
	if to_product_id then
		self.current_item_id = to_product_id
	else
		if can_compose_id ~= 0 then
			self.current_item_id = can_compose_id
		else
			self.current_item_id = compose_data:GetShowId(self.current_type)
		end
	end

	self:SetIcon()
	self.current_type = type
	if self.node_list["select_btn_" .. self.list_index] then
		self.node_list["select_btn_" .. self.list_index].accordion_element.isOn = false
	end
	if self.node_list["list_" .. self.list_index] then
		self.node_list["list_" .. self.list_index]:SetActive(false)
	end
	
	local count = compose_data:GetComposeTypeOfCount(type)
	local name_list = compose_data:GetComposeTypeOfNameList(type)
	local sub_type_list = compose_data:GetSubTypeList(type)
	-- self.item_list = {}
	-- self.cell_list = {}
	self:DestoryGameObject()
	if count > self.btn_num then
		print_error("按钮数量不够，需要扩展了")
		return
	end
	for i = 1, count do
		local sub_list = compose_data:GetComposeItemList(sub_type_list[i])
		local compose_id = compose_data:CheckBagMat(sub_list)
		if (self.current_type ~= 1 or sub_type_list[i] == BaoShiDai) and (sub_type_list[i] == ShengQi or sub_type_list[i] == ShenMo) then 		-- 策划说境界不要红点
			self.node_list["RedPoint" .. i]:SetActive(compose_id > 0)
		else
			self.node_list["RedPoint" .. i]:SetActive(false)
		end
		self.node_list["select_btn_" .. i]:SetActive(true)
		local is_has_compose_num = ComposeData.Instance:GetSubIsHaveComposeNum(sub_type_list[i]) or 0
		local flag = ComposeData.Instance:GetSelectFlag()
		if is_has_compose_num > 0 and flag ~= 0 then
			self.node_list["TxtBtn" .. i].text.text = string.format(Language.Compose.IsHasComposeNum, name_list[i], is_has_compose_num)
		else
			self.node_list["TxtBtn" .. i].text.text = name_list[i]
		end

		if is_has_compose_num > 0 and flag ~= 0 then
			self.node_list["Text" .. i].text.text = string.format(Language.Compose.IsHasComposeNum, name_list[i], is_has_compose_num)
		else
			self.node_list["Text" .. i].text.text = name_list[i]
		end
		
		self:LoadCell(i, sub_type_list[i])
	end

	for i=count + 1, self.btn_num do
		self.node_list["select_btn_" .. i]:SetActive(false)
	end
end

function ComposeContentView:MaxBtnOnClick()
	self.buy_num = ComposeData.Instance:GetCanByNum(self.current_item_id)
	if self.buy_num == 0 then
		self.buy_num = 1
	elseif tonumber(self.buy_num) >= 999 then
		self.buy_num = 999
	end
	self.node_list["TxtInput"].text.text = self.buy_num
end

function ComposeContentView:OnSelectShowClick()
	local flag = ComposeData.Instance:GetSelectFlag() == 0 and 1 or 0
	ComposeData.Instance:SetSelectFlag(flag)

	self:CheckIsSelect()
	self:FlushIsHasComposeNum()
end

function ComposeContentView:CheckIsSelect()
	local flag = ComposeData.Instance:GetSelectFlag()
	self.node_list["ImgHighLight"]:SetActive(flag ~= 0)
	if flag ~= 0 then
		self:OnFlushItem()
	else
		self:OnSetItemActive()
	end
	if self.node_list["select_btn_" .. self.list_index] and self.node_list["select_btn_" .. self.list_index].accordion_element.isOn then --刷新
		self.node_list["select_btn_" .. self.list_index].accordion_element.isOn = false
		self.node_list["select_btn_" .. self.list_index].accordion_element.isOn = true
	end

	if flag ~= 0 and self.node_list["select_btn_" .. self.list_index] then --根据背包是否拥有来判断是否关闭按钮
		local compose_data = ComposeData.Instance
		local sub_type_list = compose_data:GetSubTypeList(self.current_type)
		local compose_item_list = compose_data:GetComposeItemList(sub_type_list[self.list_index])
		for k,v in pairs(compose_item_list) do
			if compose_data:JudgeMatRich(v.product_id) then
				self.node_list["select_btn_" .. self.list_index].accordion_element.isOn = true
				return
			end
		end
		self.node_list["select_btn_" .. self.list_index].accordion_element.isOn = false
	end
end

function ComposeContentView:ComposeBtnClick()
	if self.buy_num == 0 then
		return
	end

	local compose_data = ComposeData.Instance
	local compose_item = compose_data:GetComposeItem(self.current_item_id)

	if self.buy_num + 0 <= compose_data:GetCanByNum(self.current_item_id) then
		self:PlayUpStarEffect()
		ComposeCtrl.Instance:SendItemCompose(compose_item.producd_seq, self.buy_num, 0)
	else
		for i = 1, 3 do
			local is_rich = compose_data:GetSingleMatRich(self.current_item_id, i)
			if not is_rich then
				local is_shop_exist = compose_data:GetIsHaveSingleItemOfShop(self.current_item_id, i)
				if is_shop_exist then
					self:OpenShopBuyTips(i)
				else
					TipsCtrl.Instance:ShowItemGetWayView(compose_item["stuff_id_"..i])
				end
			end
		end
	end
end

function ComposeContentView:OpenShopBuyTips(stuff_index)
	local compose_item = ComposeData.Instance:GetComposeItem(self.current_item_id)
	local bag_num = ItemData.Instance:GetItemNumInBagById(compose_item["stuff_id_"..stuff_index])
	local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
		self.is_buy_quick = is_buy_quick
		MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
	end
	if not self.is_buy_quick then
		TipsCtrl.Instance:ShowCommonBuyView(func, compose_item["stuff_id_"..stuff_index], nil, compose_item["stuff_count_"..stuff_index] - bag_num)
	else
		MarketCtrl.Instance:SendShopBuy(compose_item["stuff_id_"..stuff_index], compose_item["stuff_count_"..stuff_index] - bag_num, 0, 0)
	end

end

function ComposeContentView:OnInputClick()
	local open_func = function(buy_num)
		self.buy_num = buy_num + 0
		if self.buy_num == 0 then
			self.buy_num = 1
		end
		self.node_list["TxtInput"].text.text = self.buy_num
	end
	local close_func = function()
		if self.buy_num ~= -1 then
			return
		end
		self:FlushBuyNum()
	end
	local max_num = ComposeData.Instance:GetCanByNum(self.current_item_id)
	if max_num == 0 then
		max_num = 1
	end
	TipsCtrl.Instance:OpenCommonInputView(0,open_func,close_func,max_num)
end

function ComposeContentView:LoadCell(index, sub_type)
	local compose_item_list = ComposeData.Instance:GetComposeItemList(sub_type)
	self.node_list["select_btn_" .. index]:SetActive(#compose_item_list > 0)

	local res_async_loader = AllocResAsyncLoader(self, "loader_" .. index .. "_" .. sub_type)
	res_async_loader:Load("uis/views/composeview_prefab", "ItemType", nil, function (prefab)
		if nil == prefab then
			return
		end
		for i = 1, #compose_item_list do
			local obj = ResMgr:Instantiate(prefab)
			local obj_transform = obj.transform
			obj_transform:SetParent(self.node_list["list_" .. index].transform, false)
			obj:GetComponent("Toggle").group = self.node_list["list_" .. index].toggle_group

			local item_cell = ComposeItem.New(obj)
			item_cell:InitCell(compose_item_list[i].product_id)
			-- item_cell:FlushFontSize(sub_type)

			self.item_list[#self.item_list + 1] = obj
			self.item_cell_list[#self.item_cell_list + 1] = item_cell
		end
		self:CheckIsSelect()
	end)
end

function ComposeContentView:OnClickSelect(index)
	self.list_index = index
	self:OnFlushNum()
end

function ComposeContentView:OnBaoShi()
	self:DestoryGameObject()
	self.current_type = 1
	self:UpdateList(1)
	self:OpenFrame()
	self:SetIcon()
	ComposeData.Instance:SetToProductId(nil)
end

function ComposeContentView:OnQiTa()
	self:DestoryGameObject()
	self.current_type = 3
	self:UpdateList(3)
	self:OpenFrame()
	self:SetIcon()
	ComposeData.Instance:SetToProductId(nil)
end

function ComposeContentView:OnJinJie()
	self:DestoryGameObject()
	self.current_type = 2
	self:UpdateList(2)
	self:OpenFrame()
	self:SetIcon()
	ComposeData.Instance:SetToProductId(nil)
end

function ComposeContentView:OnShengQi()
	self:DestoryGameObject()
	self.current_type = 4
	self:UpdateList(4)
	self:OpenFrame()
	self:SetIcon()
	ComposeData.Instance:SetToProductId(nil)
end

function ComposeContentView:OnShenMo()
	self:DestoryGameObject()
	self.current_type = 5
	self:UpdateList(5)
	self:OpenFrame()
	self:SetIcon()
	ComposeData.Instance:SetToProductId(nil)
end

function ComposeContentView:OpenFrame()
	local list_index = ComposeData.Instance:GetCurrentListIndex()
	self.list_index = list_index
	if self.node_list["select_btn_" .. list_index] then
		self.node_list["select_btn_" .. list_index].accordion_element.isOn = true
	end
	
end

function ComposeContentView:DestoryGameObject()
	if self.item_list and next(self.item_list) then
		for k,v in pairs(self.item_list) do
			ResMgr:Destroy(v.gameObject)
		end
		self.item_list = {}
	end

	if self.item_cell_list and next(self.item_cell_list) then
		for k,v in pairs(self.item_cell_list) do
			v:DeleteMe()
		end
		self.item_cell_list = {}
	end
end

function ComposeContentView:SetIcon()
	self.node_list["ItemFrame1"]:SetActive(false)
	self.node_list["ItemFrame2"]:SetActive(false)
	self.node_list["ItemFrame3"]:SetActive(false)
	local flag = 0
	local compose_cfg = ComposeData.Instance:GetComposeItem(self.current_item_id)
	if compose_cfg then
		local stuff_list = {}
		stuff_list = {[1] = compose_cfg.stuff_id_1, [2] = compose_cfg.stuff_id_2, [3] = compose_cfg.stuff_id_3 }
		for i = 1, 3 do
			if stuff_list[i] ~= 0 then
				flag = flag + 1
				self.the_item_list[i].item_cell:SetCellLock(false)
				self.node_list["TxtShowCount" .. i]:SetActive(true)
				self.the_item_list[i].item_cell:SetData({item_id = stuff_list[i]})
				local count_text_list = ComposeData.Instance:GetCountText(self.current_item_id)
				self.node_list["TxtShowCount" .. i].text.text = count_text_list[i]
			else
				local data = {}
				data.item_id = 0
				self.the_item_list[i].item_cell:SetData(data)
				self.the_item_list[i].item_cell:SetCellLock(true)
				self.node_list["TxtShowCount" .. i]:SetActive(false)
			end
		end
		if flag == 2 then
			self.node_list["ItemFrame1"]:SetActive(true)
			self.node_list["ItemFrame2"]:SetActive(true)
			self.node_list["ItemFrame1"].transform.localPosition = Vector3(-70, -90,0)
			self.node_list["ItemFrame2"].transform.localPosition = Vector3(70, -90,0)
		elseif flag == 3 then
			self.node_list["ItemFrame1"]:SetActive(true)
			self.node_list["ItemFrame2"]:SetActive(true)
			self.node_list["ItemFrame3"]:SetActive(true)
			self.node_list["ItemFrame1"].transform.localPosition = Vector3(0,-100,0)
			self.node_list["ItemFrame2"].transform.localPosition = Vector3(-120,-60,0)
			self.node_list["ItemFrame3"].transform.localPosition = Vector3(120,-60,0)
		else
			self.node_list["ItemFrame1"]:SetActive(true)
			self.node_list["ItemFrame1"].transform.localPosition = Vector3(0,-100,0)
		end
		local item_cfg = ItemData.Instance:GetItemConfig(self.current_item_id)
		local name_str = ToColorStr(item_cfg.name, SOUL_NAME_COLOR[item_cfg.color])
		self.node_list["TxtItemName"].text.text = name_str
		local can_buy_num = ComposeData.Instance:GetCanByNum(self.current_item_id)
		self.node_list["TxtCount"].text.text = string.format(Language.Compose.Count, can_buy_num)
		self.the_item_list[4].item_cell:SetData({item_id = self.current_item_id})
	end
end

function ComposeContentView:OnFlushItem()
	if self.item_cell_list ~= nil then
		for k,v in pairs(self.item_cell_list) do
			v:Flush()
		end
	end
end

function ComposeContentView:OnFlushNum()
	if self.item_cell_list ~= nil then
		for k,v in pairs(self.item_cell_list) do
			v:FlushNum()
		end
	end
end

function ComposeContentView:OnSetItemActive()
	if self.item_cell_list ~= nil then
		for k,v in pairs(self.item_cell_list) do
			v:SetItemActive(true)
		end
	end
end

function ComposeContentView:SetCurrentItemId(item_id)
	self.current_item_id = item_id
end

function ComposeContentView:GetCurrentItemId()
	return self.current_item_id
end

function ComposeContentView:GetCurrentType()
	return self.current_type
end

function ComposeContentView:FlushBuyNum()
	self.buy_num = 1
	self.node_list["TxtInput"].text.text = self.buy_num
end

function ComposeContentView:ItemDataChangeCallback(the_item_id)
	self:OnFlushNum()
	self:SetIcon()

	local compose_data = ComposeData.Instance
	local count = compose_data:GetComposeTypeOfCount(self.current_type)
	local sub_type_list = compose_data:GetSubTypeList(self.current_type)
	for i = 1, count do
		local sub_list = compose_data:GetComposeItemList(sub_type_list[i])
		local compose_id = compose_data:CheckBagMat(sub_list)
		if (self.current_type ~= 1 or sub_type_list[i] == BaoShiDai) and (sub_type_list[i] == ShengQi or sub_type_list[i] == ShenMo) then 		-- 策划说境界不要红点
			self.node_list["RedPoint" .. i]:SetActive(compose_id > 0)
		else
			self.node_list["RedPoint" .. i]:SetActive(false)
		end
	end
	if the_item_id ~= self.current_item_id then
		if compose_data:GetEnoughMatEqualNeedCount(compose_data:GetProductIdByStuffId(the_item_id)) then
			self:OnFlushNum()
			self:FlushBuyNum()
			self:CheckOpenOrNot()
			self:CheckIsSelect()
			self:SetIcon()
		end
		return
	end
	self:FlushBuyNum()
	local flag = ComposeData.Instance:GetSelectFlag()
	if flag ~= 0 then
		self:IsSelect(the_item_id)
	else
		self:IsNotSelect()
	end
	if self.item_cell_list ~= nil then
		for k,v in pairs(self.item_cell_list) do
			if self.current_item_id == v:GetItemId() then
				v:SetHighLight()
			end
		end
	end
	self:SetIcon()
	self:FlushIsHasComposeNum()
		
end

function ComposeContentView:FlushIsHasComposeNum()
	local sub_type_list = ComposeData.Instance:GetSubTypeList(self.current_type)
	local count = ComposeData.Instance:GetComposeTypeOfCount(self.current_type)
	local name_list = ComposeData.Instance:GetComposeTypeOfNameList(self.current_type)
	local flag = ComposeData.Instance:GetSelectFlag()
	for i = 1, count do
		local is_has_compose_num = ComposeData.Instance:GetSubIsHaveComposeNum(sub_type_list[i]) or 0
		if is_has_compose_num > 0 and flag ~= 0 then
			self.node_list["TxtBtn" .. i].text.text = string.format(Language.Compose.IsHasComposeNum, name_list[i], is_has_compose_num)
		else
			self.node_list["TxtBtn" .. i].text.text = name_list[i]
		end

		if is_has_compose_num > 0 and flag ~= 0 then
			self.node_list["Text" .. i].text.text = string.format(Language.Compose.IsHasComposeNum, name_list[i], is_has_compose_num)
		else
			self.node_list["Text" .. i].text.text = name_list[i]
		end
	end
end



function ComposeContentView:IsNotSelect()
	local compose_data = ComposeData.Instance
	local enough_mat = compose_data:JudgeMatRich(self.current_item_id)
	if enough_mat then
		return
	end

	local is_have = compose_data:GetSubIsHaveCompose(compose_data:GetComposeItem(self.current_item_id).sub_type)
	local item_id = compose_data:GetShowItemId(self.current_type, compose_data:GetComposeItem(self.current_item_id).sub_type)
	if item_id ~= -1 then
		self.current_item_id = item_id
	else
		return
	end
	if compose_data:GetSubIsHaveCompose(compose_data:GetComposeItem(self.current_item_id).sub_type) == false then
		self:CheckOpenOrNot()
		self:CheckIsSelect()
	else
		if is_have == false then
			self:CheckOpenOrNot()
			self:CheckIsSelect()
		end
	end
end

function ComposeContentView:IsSelect(the_item_id)
	local compose_data = ComposeData.Instance
	local enough_need = compose_data:GetEnoughMatEqualNeedCount(compose_data:GetProductIdByStuffId(the_item_id))
	local enough_mat = compose_data:JudgeMatRich(the_item_id)
	if not enough_need and enough_mat then
		return
	end
	local item_id = -1
	if not enough_mat then
		item_id = compose_data:GetShowItemId(self.current_type, compose_data:GetComposeItem(self.current_item_id).sub_type)
	end

	if item_id ~= -1 then
		self.current_item_id = item_id
	else
		self:OnFlushItem()
	end
	self:CheckOpenOrNot()
	self:CheckIsSelect()
end

function ComposeContentView:CheckOpenOrNot()
	local list_index = ComposeData.Instance:GetCurrentListIndex()
	if self.list_index ~= list_index and self.node_list["select_btn_" .. self.list_index] then
		self.list_index = list_index
		self.node_list["select_btn_" .. self.list_index].accordion_element.isOn = true
	end
end

function ComposeContentView:PlayUpStarEffect()
	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
		local bundle_name, asset_name = ResPath.GetUiXEffect("UI_hechengdaoju")
		EffectManager.Instance:PlayAtTransformCenter(
			bundle_name,
			asset_name,
			self.node_list["effect_root"].transform,
			2.0)
		self.effect_cd = Status.NowTime + EFFECT_CD
	end
end

------------------------------------------------
ComposeItem = ComposeItem or BaseClass(BaseCell)
function ComposeItem:__init(instance)
	self.name = ""
	self.num = ""
	self.item_id = 0
	self.node_list["BtnItemType"].toggle:AddValueChangedListener(BindTool.Bind(self.OnItemClick, self))
	self.can_buy_num = 0

end

function ComposeItem:__delete()
	self.can_buy_num = nil
	self.item_id = nil
end

function ComposeItem:InitCell(item_id)
	self.item_id = item_id
	self.name = ItemData.Instance:GetItemConfig(item_id).name
	self:FlushNum()
end

function ComposeItem:FlushFontSize(sub_type)
	if sub_type == 21 or sub_type == 22 or sub_type == 23 or sub_type == 24 then
		self.node_list["Name"].text.fontSize = 14
		self.node_list["NameHL"].text.fontSize = 14
	else
		self.node_list["Name"].text.fontSize = 20
		self.node_list["NameHL"].text.fontSize = 20
	end
end

function ComposeItem:OnFlush()
	local is_rich = ComposeData.Instance:JudgeMatRich(self.item_id)
	if is_rich then
		self.root_node:SetActive(true)
	else
		self.root_node:SetActive(false)
	end
end

function ComposeItem:FlushNum()
	local compose_cfg = ComposeData.Instance:GetComposeItem(self.item_id)
	local is_have = ComposeData.Instance:JudgeMatRich(self.item_id)
	self.can_buy_num = ComposeData.Instance:GetCanByNum(self.item_id)

	self.node_list["Name"].text.text = self.name
	self.node_list["NameHL"].text.text = self.name

	if is_have and (compose_cfg.type ~= 1 or compose_cfg.sub_type == BaoShiDai) and 
		(compose_cfg.sub_type == ShengQi or compose_cfg.sub_type == ShenMo) then 		-- 策划说境界不要红点
		self.node_list["RedPoint"]:SetActive(true)
	else
		self.node_list["RedPoint"]:SetActive(false)
	end
	self:SetHighLight()
end

function ComposeItem:SetHighLight()
	if ComposeContentView.Instance:GetCurrentItemId() == self.item_id then
		self.root_node.toggle.isOn = true
	else
		self.root_node.toggle.isOn = false
	end
end

function ComposeItem:GetCanBuyNum()
	return self.can_buy_num
end

function ComposeItem:SetItemActive(is_active)
	self.root_node:SetActive(is_active)
end

function ComposeItem:OnItemClick(is_click)
	if is_click then
		ComposeContentView.Instance:SetCurrentItemId(self.item_id)
		ComposeContentView.Instance:SetIcon(self.item_id)
		ComposeContentView.Instance:FlushBuyNum()
	end
end

function ComposeItem:GetItemId()
	return self.item_id
end
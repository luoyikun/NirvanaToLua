WeddingBlessingView = WeddingBlessingView or BaseClass(BaseView)

function WeddingBlessingView:__init()
	self.ui_config = {{"uis/views/marriageview_prefab","MarryblessView"},}

	self.is_modal = true
	self.is_any_click_close = true

end

function WeddingBlessingView:__delete()

end

function WeddingBlessingView:LoadCallBack()
	self.is_select = 3
	self.node_list["Close"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnGive"].button:AddClickListener(BindTool.Bind(self.ClickGive, self))
	for i = 0, 5 do
		self.node_list["Check".. i].toggle.onValueChanged:AddListener(BindTool.Bind(self.ClickSelect, self, i))
	end
	for i = 1, 2 do
		self.node_list["Player"..i].button:AddClickListener(BindTool.Bind(self.OnClickHeadHandler, self, i))
	end
end

function WeddingBlessingView:ClickSelect(i, is_click)
	if is_click then
		self.is_select = i
	end
end

function WeddingBlessingView:OpenCallBack()
	MarriageCtrl.Instance:SendMarryOpera(HUNYAN_OPERA_TYPE.HUNYAN_GET_WEDDING_ROLE_INFO)
	MarriageCtrl.Instance:SendMarryOpera(HUNYAN_OPERA_TYPE.HUNYAN_GET_BLESS_RECORD_INFO)
	self:Flush()
end

function WeddingBlessingView:OnClickHeadHandler(i)
	local marry_info = MarriageData.Instance:GetHunYanCurAllInfo()
	if i == 1 then
		self.wedding_id = marry_info.role_id
		self.node_list["Player1Hl"]:SetActive(true)
		self.node_list["Player2Hl"]:SetActive(false)
	elseif i == 2 then
		self.wedding_id = marry_info.lover_role_id
		self.node_list["Player1Hl"]:SetActive(false)
		self.node_list["Player2Hl"]:SetActive(true)
	end
end

function WeddingBlessingView:ClickGive()
	if not self.wedding_id then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.SendTips)
		return
	end

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo.role_id == self.wedding_id then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.NoBless)
		return
	end

	if self.is_select > 2 then
		local is_select = self.is_select - 3
		local cfg = MarriageData.Instance:GetBlessMoneyCfg(is_select)
		if main_role_vo.gold < cfg.param then
			TipsCtrl.Instance:ShowLackDiamondView()
			return
		end
		MarriageCtrl.Instance:SendMarryOpera(HUNYAN_OPERA_TYPE.HUNYAN_OPERA_TYPE_RED_BAG, self.wedding_id, is_select)
	else
		local cfg = MarriageData.Instance:GetBlessFlowerCfg(self.is_select)
		local item_id = cfg.param
		local num = ItemData.Instance:GetItemNumInBagById(item_id)
		if num >= 1 then
			MarriageCtrl.Instance:SendMarryOpera(HUNYAN_OPERA_TYPE.HUNYAN_OPERA_TYPE_FOLWER, self.wedding_id, self.is_select)
		else
			local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[item_id]
			if item_cfg == nil then
				TipsCtrl.Instance:ShowSystemMsg(Language.Flower.HasNotFlowerTip)
				return
			else
				if TipsCommonBuyView.AUTO_LIST[item_id] then
					local item_cfg = ItemData.Instance:GetItemConfig(item_id)
					MarketCtrl.Instance:SendShopBuy(item_id, 1, 1, item_cfg.is_tip_use)
				else
					local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
						MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
					end
					TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nil, 1)
				end
			end
		end
	end
end

function WeddingBlessingView:OnFlush()
	local marry_info = MarriageData.Instance:GetHunYanCurAllInfo()
	if not next(marry_info) then     -- 协议信息可能还没下发
		return 
	end

	if marry_info then
		self:SetHead(marry_info)
		local data = MarriageData.Instance:GetBlessingRecordInfo()
		for i = 1, #data do
			self:SetZhuFuData(data[i], i)
		end
	end
end

function WeddingBlessingView:SetHead(marry_info)
	local role_id = {marry_info.role_id, marry_info.lover_role_id}
	local prof = {marry_info.role_prof, marry_info.lover_role_prof}
	for i = 1, 2 do
			local role_sex = 1
			if prof[i] > 2 then
				role_sex = 0
			end
			local role_base_prof = PlayerData.Instance:GetRoleBaseProf(prof[i])
			AvatarManager.Instance:SetAvatar(role_id[i], self.node_list["PlayerRawImage" .. i], self.node_list["PlayerImage" .. i], ROLE_PROF_SEX[role_base_prof], prof[i], false)
	end
	self.node_list["Name1"].text.text = marry_info.role_name
	self.node_list["Name2"].text.text = marry_info.lover_role_name
end

function WeddingBlessingView:SetZhuFuData(data, i)
	if next(data) == nil then return end
	local str = ""
	if data.bless_type == 0 then
		local blessing_cfg = MarriageData.Instance:GetBlessingListCfg(data.param)
		str = string.format(Language.Marriage.BlessingTips1, data.role_name, data.to_role_name, data.param)
	elseif data.bless_type == 1 then
		local blessing_cfg = MarriageData.Instance:GetBlessingListCfg(data.param)
		local item_cfg = ItemData.Instance:GetItemConfig(blessing_cfg.param)
		str = string.format(Language.Marriage.BlessingTips2, data.role_name, data.to_role_name, item_cfg.name)
	else
		local item_id = 0
		if data.param > 10 then
			item_id = 23878
		else
			item_id = 23879
		end
		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		str = string.format(Language.Marriage.BlessingTips3, data.role_name, item_cfg.name, data.param)
	end
	self.node_list["Text" .. i].text.text = str
end


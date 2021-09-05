BiaoBaiQiangTips = BiaoBaiQiangTips or BaseClass(BaseView)

function BiaoBaiQiangTips:__init()
	self.ui_config = {
		{"uis/views/biaobaiqiangview_prefab", "BiaoBaiTips"},
	}
	self.is_modal = true
	self.is_any_click_close = true
	-- self.view_layer = UiLayer.PopTop
end

function BiaoBaiQiangTips:LoadCallBack()
	self.other_id = 0
	self.select_item = 1
	self.cell = {}
	for i=1,3 do
		self.cell[i] = BiaoBaiQiangItems.New(self.node_list["Item" .. i])
		self.node_list["Item" .. i].toggle:AddClickListener(BindTool.Bind(self.ClickItem, self, i))
	end
	-- self.items = ItemCell.New()
	-- self.items:SetInstanceParent(self.node_list["SelectItem"])
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnHelpClick, self))
	self.node_list["ChoseFriend"].button:AddClickListener(BindTool.Bind(self.OnSelectClick, self))
	self.node_list["BtnClick"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
	local is_marry = MarriageData.Instance:CheckIsMarry()
	if is_marry then
		local role_info = {}
		role_info.user_id = GameVoManager.Instance:GetMainRoleVo().lover_uid or 0
		role_info.gamename = GameVoManager.Instance:GetMainRoleVo().lover_name or ""
		role_info.sex = GameVoManager.Instance:GetMainRoleVo().sex == 0 and 1 or 0
		role_info.prof = MarriageData.Instance:GetLoverProf()
		self:SelectFriendCallBack(role_info)
	end
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function BiaoBaiQiangTips:OpenCallBack()
	self:Flush()
end



function BiaoBaiQiangTips:CloseCallBack()
	BiaoBaiQiangCtrl.Instance:SendProfessWallReq(PROFESS_WALL_REQ_TYPE.PROFESS_WALL_REQ_INFO, 0)
	BiaoBaiQiangCtrl.Instance:SendProfessWallReq(PROFESS_WALL_REQ_TYPE.PROFESS_WALL_REQ_INFO, 1)
	BiaoBaiQiangCtrl.Instance:SendProfessWallReq(PROFESS_WALL_REQ_TYPE.PROFESS_WALL_REQ_INFO, 2)

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

function BiaoBaiQiangTips:__delete()
end

function BiaoBaiQiangTips:ReleaseCallBack()
	for i = 1,3 do
		self.cell[i]:DeleteMe()
		self.cell[i] = nil
	end

	-- if self.items then
	-- 	self.items:DeleteMe()
	-- 	self.items = nil
	-- end
end

function BiaoBaiQiangTips:OnHelpClick()
	local tips_id = 300
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function BiaoBaiQiangTips:ClickItem(i)
	self.select_item = i
	self:Flush()
end

function BiaoBaiQiangTips:OnFlush()
	for i=1,3 do
		self.cell[i]:SetColor(i == self.select_item)
		local data = BiaoBaiQiangData.Instance:GetCfgByType(i - 1)
		self.cell[i]:SetData(data)
	end
	self:ItemDataChangeCallback()
end

function BiaoBaiQiangTips:ItemDataChangeCallback()
	if self:IsOpen() then
		local data = BiaoBaiQiangData.Instance:GetCfgByType(self.select_item - 1)
		local num = ItemData.Instance:GetItemNumInBagById(data.gift_id)
		-- self.items:SetData({item_id = data.gift_id})
		-- self.node_list["ItemName"].text.text = data.gift_name
		local color = num >= 1 and TEXT_COLOR.GREEN_4 or TEXT_COLOR.RED
		-- self.node_list["Num"].text.text = string.format(Language.Marriage.BiaoBaiTips, color, num)
	end
end

function BiaoBaiQiangTips:OnSelectClick()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local sex = main_role_vo.sex == 1 and 0 or 1
	local callback = BindTool.Bind(self.SelectFriendCallBack, self)
	MarriageCtrl.Instance:ShowFriendListView(callback, sex)
end

function BiaoBaiQiangTips:OnClick()
	if self.other_id <= 0 then
		TipsCtrl.Instance:ShowSystemMsg(Language.BiaoBai.NotSelect)
		return
	end
	local data = BiaoBaiQiangData.Instance:GetCfgByType(self.select_item - 1)
	local num = ItemData.Instance:GetItemNumInBagById(data.gift_id)
	local is_auto = self.node_list["IsAuto"].toggle.isOn and 1 or 0
	if num <= 0 and is_auto == 0 then
		-- 物品不足，弹出TIP框
		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[data.gift_id]
		if nil == item_cfg then
			TipsCtrl.Instance:ShowItemGetWayView(data.gift_id)
			return
		end

		local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			if is_buy_quick then
				self.node_list["IsAuto"].toggle.isOn = true
			end
		end

		TipsCtrl.Instance:ShowCommonBuyView(func, data.gift_id, nofunc, 1)
		return
	end

	local text = self.node_list["Input"].input_field.text
	if text == "" then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.ContentNotNull)
		return
	end
    text = ChatFilter.Instance:Filter(text)
    
	
	BiaoBaiQiangCtrl.Instance:SendProfessToReq(self.other_id, self.select_item - 1, is_auto, text)
end

function BiaoBaiQiangTips:SelectFriendCallBack(role_info)
	self.other_id = role_info.user_id
	if nil ~= self.node_list then
		self.node_list["NodeOtherHeadMask"]:SetActive(true)
		self.node_list["AddIcon"]:SetActive(false)
		self:SetOtherHead(role_info)
	end
end

--设置他人头像
function BiaoBaiQiangTips:SetOtherHead(info)
	local role_id = info.user_id
	local prof = info.prof
	local sex = info.sex

	self.node_list["FriendName"].text.text = info.gamename
	AvatarManager.Instance:SetAvatar(role_id, self.node_list["OtherRawImage"], self.node_list["ImgOtherHeadMask"], sex, prof, false)
end
--告白物品
BiaoBaiQiangItems = BiaoBaiQiangItems or BaseClass(BaseCell)

function BiaoBaiQiangItems:__init()
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["ItemCell"])
end

function BiaoBaiQiangItems:__delete()
	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end
end

function BiaoBaiQiangItems:SetData(data)
	self.node_list["Name"].text.text = data.gift_name
	self.node_list["Exp"].text.text = string.format(Language.BiaoBai.exp, data.exp)
	self.node_list["JifenText"].text.text = string.format(Language.BiaoBai.JiFenTips, data.score)
	self.item:SetData({item_id = data.gift_id})
	local item_id = data.gift_id
	local num = ItemData.Instance:GetItemNumInBagByIndex(ItemData.Instance:GetItemIndex(item_id),item_id)
	local color = num >= 1 and "#89F201FF" or "#F9463bFF"
	self.node_list["ConsumptionNum"].text.text = string.format(Language.BiaoBai.BagItemNum, color, num)
	local is_show = ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PROFESS_RANK)
	self.node_list["JifenImage"]:SetActive(is_show)
end

function BiaoBaiQiangItems:SetColor(state)
	local color1 = Color(186/255, 9/255, 46/255, 1)
	local color2 = Color(70/255, 41/255, 83/255, 1)

	self.node_list["Name"].text.color = state and color2 or color1
	self.node_list["Exp"].text.color = state and color2 or color1
end
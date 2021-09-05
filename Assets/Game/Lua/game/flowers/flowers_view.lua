FlowersView = FlowersView or BaseClass(BaseView)

function FlowersView:__init()
	self.ui_config = {{"uis/views/flowersview_prefab", "Flowers"}}
	self.full_screen = false
	self.play_audio = true
	self.is_modal = true
	self.is_auto_buy_stone = {false, false, false, false}
end

function FlowersView:OnFlush(param_t)
	for i = 1, 4 do
		local num = ItemData.Instance:GetItemNumInBagById(FLOWER_ID_LIST[i])
		if i == 1 then
			local free_time = FlowersData.Instance:GetFreeFlowerTime()
			local max_free = FlowersData.Instance:GetSendFlowerCfgFreeTime()
			if free_time and max_free then
				local str = (num + (max_free - free_time)) .. " / " .. 1
				if num + (max_free - free_time) < 1 then
					str = ToColorStr(str, TEXT_COLOR.WHITE)
				else
					str = ToColorStr(str, TEXT_COLOR.GREEN)
				end
				self.node_list["TxtFlower" .. i].text.text = str
				self.node_list["TxtFlower_" .. i].text.text = free_time < max_free and Language.Common.FreeSend or Language.Common.ZengSong
			end
		else
			self.node_list["TxtFlower_" .. i].text.text = Language.Common.ZengSong
			local str = num  .. " / " .. 1
			if num < 1 then
				str = ToColorStr(str, TEXT_COLOR.WHITE)
			else
				str = ToColorStr(str, TEXT_COLOR.GREEN)
			end
			self.node_list["TxtFlower" .. i].text.text = str
				
		end
	end
end

function FlowersView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseView,self))
	self.node_list["BtnChoseFriend"].button:AddClickListener(BindTool.Bind(self.ChosenFriend,self))
	self.node_list["BtnChosenFriend"].button:AddClickListener(BindTool.Bind(self.ChosenFriend,self))
	self.node_list["TxtCfgCount"].text.text = string.format(Language.Flower.SendFlowerTips, FlowersData.Instance:GetSendFlowerCfgFreeTime()) --每天前{0}次免费赠送可获得好友回礼哦!
	self.flower_amount_text_list = {}
	self.btn_text_list = {}
	for i = 1, 4 do
		self.node_list["BtnFlower" .. i].button:AddClickListener(BindTool.Bind2(self.OnSendClick, self, i))
	end
	self.infotable = {}
	self.flower_nums = {}
	self.is_autochosen = true
end

function FlowersView:ReleaseCallBack()
	-- 清理变量和对象
	self.head = nil
	self.flower = nil
	self.image_obj = nil
	self.raw_image_obj = nil
	self.cfg_count = nil
	self.is_show_add_icon = nil
	for i = 1, 4 do
		self.flower_amount_text_list[i] = nil
		self.btn_text_list[i] = nil
	end
	self.flower_amount_text_list = {}
	self.btn_text_list = {}
end

function FlowersView:OpenCallBack()
	self:SetNotifyDataChangeCallBack()
	if FlowersData.Instance:GetFlowersInfo().target_uid ~= -1 then
		local name, id = FlowersData.Instance:GetFriendInfo()
		self.node_list["TxtFriendName"].text.text = name
		self.node_list["ImgIcon"]:SetActive(true)
		self.node_list["ImgAddIcon"]:SetActive(false)
		self:SetFriend(name,id)
	else
		local bundle, asset = ResPath.GetRoleHeadSmall(1)
		self.node_list["RoleImage"].image:LoadSprite(bundle, asset .. ".png")
		self.node_list["RoleImage"]:SetActive(true)
		self.node_list["RawImage"]:SetActive(false)
		self.node_list["TxtFriendName"].text.text = Language.Flower.SelectObj
	end
	self:Flush()
end

--移除物品回调
function FlowersView:RemoveNotifyDataChangeCallBack()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

-- 设置物品回调
function FlowersView:SetNotifyDataChangeCallBack()
	-- 监听系统事件
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function FlowersView:ItemDataChangeCallback()
	self:Flush()
end

function FlowersView:CloseView()
	self.node_list["TxtFriendName"].text.text = Language.Flower.SelectObj
	self.node_list["RoleImage"]:SetActive(false)
	self.node_list["RawImage"]:SetActive(false)
	self.node_list["ImgIcon"]:SetActive(false)
	self.node_list["ImgAddIcon"]:SetActive(true)

	self.infotable.friend_name = nil
	self.infotable = {}
	FlowersData.Instance:ClearFlowerId()
	self:Close()
end

function FlowersView:CloseCallBack()
	self:RemoveNotifyDataChangeCallBack()
end

function FlowersView:OnSendClick(i)
	if self.infotable.user_id and self.infotable.user_id ~= 0 then
		if i == 1 then
			local free_time = FlowersData.Instance:GetFreeFlowerTime()
			local max_free = FlowersData.Instance:GetSendFlowerCfgFreeTime()
			if free_time < max_free then
				FlowersCtrl.Instance:SendFlowersReq(0, FLOWER_ID_LIST[i], self.infotable.user_id, 0, 0)
				return
			end
		end
		local num = ItemData.Instance:GetItemNumInBagById(FLOWER_ID_LIST[i])
		if num > 0 then
			local grid_index = ItemData.Instance:GetItemIndex(FLOWER_ID_LIST[i])
			FlowersCtrl.Instance:SendFlowersReq(grid_index, FLOWER_ID_LIST[i], self.infotable.user_id, 0, 0)
		else
			local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[FLOWER_ID_LIST[i]]
			if item_cfg == nil then
				TipsCtrl.Instance:ShowSystemMsg(Language.Flower.HasNotFlowerTip)
				return
			else
				if self.is_auto_buy_stone[i] then
					FlowersCtrl.Instance:SendFlowersReq(-1, FLOWER_ID_LIST[i], self.infotable.user_id, 0, 0)
				else
					local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
						MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
						if is_buy_quick then
							self.is_auto_buy_stone[i] = true
						end
					end
					TipsCtrl.Instance:ShowCommonBuyView(func, FLOWER_ID_LIST[i], nil, 1)
				end
			end
		end
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Flower.NotSelectObj)
		return
	end
end

function FlowersView:ChosenFriend()
	local func = function(role_info)
		local name = role_info.gamename
		local id = role_info.user_id
		self.infotable.friend_name = name
		self.infotable.user_id = id
		self.node_list["TxtFriendName"].text.text = name
		local info = ScoietyData.Instance:GetFriendInfoByName(name)
		local prof = info.prof
		local avatar_key_big = info.avatar_key_big
		local avatar_key_small = info.avatar_key_small
		self.node_list["ImgIcon"]:SetActive(true)
		self.node_list["ImgAddIcon"]:SetActive(false)
		AvatarManager.Instance:SetAvatarKey(id, avatar_key_big, avatar_key_small)

		AvatarManager.Instance:SetAvatar(id, self.node_list["RawImage"], self.node_list["RoleImage"], info.sex, info.prof, false)
	end

	ScoietyCtrl.Instance:ShowFriendListView(func)
end

function FlowersView:SetFriend(name,id)
	self.infotable.friend_name = name
	self.infotable.user_id = id

	self.node_list["TxtFriendName"].text.text = name

	local prof = FlowersData.Instance:GetRoleInfo().prof
	local avatar_key_big = FlowersData.Instance:GetRoleInfo().avatar_key_big
	local avatar_key_small = FlowersData.Instance:GetRoleInfo().avatar_key_small

	AvatarManager.Instance:SetAvatarKey(id, avatar_key_big, avatar_key_small)

	AvatarManager.Instance:SetAvatar(id, self.node_list["RawImage"], self.node_list["RoleImage"], FlowersData.Instance:GetRoleInfo().sex, prof, false)
end

function FlowersView:GetInfoTable()
	return self.infotable
end
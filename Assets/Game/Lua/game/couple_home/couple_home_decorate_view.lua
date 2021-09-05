local FurnitureNameType = {
	["Decoration"] = SPOUSE_HOME_FURNITURE_MAX_IMPRINT_SLOT_TYPE.FURNITURE_COUNT_DECORATION,
	["Lamp1"] = SPOUSE_HOME_FURNITURE_MAX_IMPRINT_SLOT_TYPE.FURNITURE_COUNT_LAMP_LEFT,
	["Lamp2"] = SPOUSE_HOME_FURNITURE_MAX_IMPRINT_SLOT_TYPE.FURNITURE_COUNT_LAMP_RIGHT,
	["Desk"] = SPOUSE_HOME_FURNITURE_MAX_IMPRINT_SLOT_TYPE.FURNITURE_COUNT_DESK,
	["Wardrobe"] = SPOUSE_HOME_FURNITURE_MAX_IMPRINT_SLOT_TYPE.FURNITURE_COUNT_WARDROBE,
	["Carpet"] = SPOUSE_HOME_FURNITURE_MAX_IMPRINT_SLOT_TYPE.FURNITURE_COUNT_CARPET,
	["Chair"] = SPOUSE_HOME_FURNITURE_MAX_IMPRINT_SLOT_TYPE.FURNITURE_COUNT_CHAIR,
	["Blanket"] = SPOUSE_HOME_FURNITURE_MAX_IMPRINT_SLOT_TYPE.FURNITURE_COUNT_BLANKET,
	["Bed"] = SPOUSE_HOME_FURNITURE_MAX_IMPRINT_SLOT_TYPE.FURNITURE_COUNT_BED,
	["DiningTable"] = SPOUSE_HOME_FURNITURE_MAX_IMPRINT_SLOT_TYPE.FURNITURE_COUNT_DINING_TABLE,
	["Screen"] = SPOUSE_HOME_FURNITURE_MAX_IMPRINT_SLOT_TYPE.FURNITURE_COUNT_SCREEN,
	["Mirror"] = SPOUSE_HOME_FURNITURE_MAX_IMPRINT_SLOT_TYPE.FURNITURE_COUNT_MIRROR,
	["Plant1"] = SPOUSE_HOME_FURNITURE_MAX_IMPRINT_SLOT_TYPE.FURNITURE_COUNT_PLANT_LEFT,
	["Plant2"] = SPOUSE_HOME_FURNITURE_MAX_IMPRINT_SLOT_TYPE.FURNITURE_COUNT_PLANT_RIGHT,
}

CoupleHomeDecorateContentView = CoupleHomeDecorateContentView or BaseClass(BaseRender)
function CoupleHomeDecorateContentView:__init()
	self.click_house_cell_call_back = BindTool.Bind(self.ClickHouseCellCallBack, self)
	self.click_other_cell_call_back = BindTool.Bind(self.ClickOtherCellCallBack, self)
	self.click_furniture_cell_call_back = BindTool.Bind(self.ClickFurnitureCellCallBack, self)

	self.select_other_list_type = "friend"			--列表选中的类型
	self.select_other_list_uid = 0					--列表选中的对象uid
	self.select_house_client_index = 1				--选择的房子客户端index
	self.put_on_state = false						--是否处于摆放状态
	self.last_pet_id = -1							--最后设置的小宠物id

	-- self.normal_avtar = self.node_list["normal_avtar"]
	self.show_normal = self.node_list["Normal"]

	self.toggle_friend = self.node_list["ToggleFriend"]
	self.toggle_guild = self.node_list["ToggleGuild"]
	self.list_toggle = self.node_list["ListToggle"]
	self.house_list_toggle = self.node_list["HouseListToggle"]
	self.special_avtar = self.node_list["SpecialAvtar"]
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["Number"], "FightPower3")

	self.pet_model = RoleModel.New()
	self.pet_model:SetDisplay(self.node_list["PetModel"].ui3d_display, MODEL_CAMERA_TYPE.BASE)

	--创建家具类
	self:CreateFurnitureClass()

	self.node_list["PutOnBtn"].button:AddClickListener(BindTool.Bind(self.ClickPutOn, self))
	self.node_list["LoverFurniture"].button:AddClickListener(BindTool.Bind(self.ClickLoverFurniture, self))
	self.node_list["ReturnBtn"].button:AddClickListener(BindTool.Bind(self.ClickReturn, self))
	self.node_list["TotalAttr"].button:AddClickListener(BindTool.Bind(self.ClickTotalAttr, self))
	self.node_list["ToggleFriend"].toggle:AddClickListener(BindTool.Bind(self.ClickFriend, self))
	self.node_list["ToggleGuild"].toggle:AddClickListener(BindTool.Bind(self.ClickGuild, self))
	self.node_list["ListToggle"].toggle:AddClickListener(BindTool.Bind(self.ClickOtherList, self))
	--房子列表
	self.house_list_data = {}
	self.house_cell_list = {}
	self.house_list = self.node_list["HouseList"]
	local scroller_delegate = self.house_list.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.HouseNumberOfCell, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.HouseCellRefresh, self)

	--其他人列表
	self.other_list_data = {}
	self.other_cell_list = {}
	self.other_list = self.node_list["FriendList"]
	scroller_delegate = self.other_list.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.NumberOfCell, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.CellRefresh, self)

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function CoupleHomeDecorateContentView:__delete()
	if self.pet_model then
		self.pet_model:DeleteMe()
		self.pet_model = nil
	end

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	for k, v in pairs(self.house_cell_list) do
		v:DeleteMe()
	end
	self.house_cell_list = nil

	for k, v in pairs(self.other_cell_list) do
		v:DeleteMe()
	end
	self.other_cell_list = nil

	for k, v in ipairs(self.furniture_cell_list) do
		v:DeleteMe()
	end
	self.furniture_cell_list = nil
	self.fight_text = nil
	self:StopPetModelTimeQuest()
end

function CoupleHomeDecorateContentView:CreateFurnitureClass()
	self.furniture = self.node_list["Furniture"]
	self.furniture_cell_list = {}
	local child_count = self.furniture.transform.childCount
	for i = 0, child_count - 1 do
		local obj = self.furniture.transform:GetChild(i)
		local furniture_index = FurnitureNameType[obj.gameObject.name]
		local cell = FurnitureCell.New(obj.gameObject)
		cell:SetClickCallBack(self.click_furniture_cell_call_back)
		cell:SetFurnitureIndex(furniture_index)

		table.insert(self.furniture_cell_list, cell)
	end
end

function CoupleHomeDecorateContentView:ClickHouseCellCallBack(cell)
	cell:SetToggleIsOn(true)

	local data = cell:GetData()
	if data == nil then
		--弹出购买房子界面
		ViewManager.Instance:Open(ViewName.CoupleHomeView, TabIndex.couple_home_buy)
		return
	end

	local index = cell:GetIndex()
	if index == self.select_house_client_index then
		return
	end
	self.select_house_client_index = index

	--跳转到对应房子
	self:FlushView()
end

function CoupleHomeDecorateContentView:ClickOtherCellCallBack(cell)
	cell:SetToggleIsOn(true)

	local data = cell:GetData()
	if data == nil then
		return
	end

	if data.uid == self.select_other_list_uid then
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.CoupleHome.InOtherHouse, data.role_name))
		return
	end
	self.select_other_list_uid = data.uid

	--默认选择第一个房子
	self.select_house_client_index = 1
	--取消摆放状态
	self.put_on_state = false
	--显示房子列表
	self.house_list_toggle.toggle.isOn = false

	--等待查看状态
	self.is_wait_for_see = true

	--设置等待参观的玩家信息
	self.see_home_role_info = {}
	self.see_home_role_info.uid = data.uid or 0
	self.see_home_role_info.sex = data.sex or 0
	self.see_home_role_info.prof = data.prof or 0
	self.see_home_role_info.role_name = data.role_name or ""

	--查看玩家家园
	CoupleHomeHomeCtrl.Instance:SendSpouseHomeOperaReq(CS_SPOUSE_HOME_TYPE.CS_SPOUSE_HOME_TYPE_VIEW_OTHER_PEOPLE_ROOM, data.uid)
end

function CoupleHomeDecorateContentView:ClickFurnitureCellCallBack(cell)
	local furniture_index = cell:GetFurnitureIndex()
	if not self.put_on_state then
		local furniture_info = CoupleHomeHomeData.Instance:GetFurnitureInfo(self.select_house_client_index, furniture_index)
		if furniture_info and furniture_info.item_id > 0 then
			local data = {item_id = furniture_info.item_id}
			TipsCtrl.Instance:OpenItem(data)
		end
		return
	end

	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local house_uid = CoupleHomeHomeData.Instance:GetHouseUid()
	if house_uid == main_vo.role_id then
		local function callback(item_id)
			local item_index = ItemData.Instance:GetItemIndex(item_id)
			if item_index >= 0 then
				local house_data = self.house_list_data[self.select_house_client_index]
				if house_data == nil then
					return
				end

				local house_index = house_data.house_index
				CoupleHomeHomeCtrl.Instance:SendSpouseHomeOperaReq(CS_SPOUSE_HOME_TYPE.CS_SPOUSE_HOME_TYPE_FURNITURE_EQUIT, house_index, furniture_index, item_index)
			end
		end
		local item_list = CoupleHomeHomeData.Instance:GetItemListInBagByIndex(furniture_index)
		if item_list == nil or item_list[1] == nil then
			SysMsgCtrl.Instance:ErrorRemind(Language.CoupleHome.CoupleHomeError)
		else
			CoupleHomeCtrl.Instance:ShowPacketView(self.select_house_client_index, furniture_index, callback)
		end
	elseif house_uid == main_vo.lover_uid then
		local function lovercallback(item_id)
			local item_index = ItemData.Instance:GetItemIndex(item_id)
			if item_index >= 0 then
				local house_data = self.house_list_data[self.select_house_client_index]
				if house_data == nil then
					return
				end

				local house_index = house_data.house_index
				CoupleHomeHomeCtrl.Instance:SendSpouseHomeOperaReq(CS_SPOUSE_HOME_TYPE.CS_SPOUSE_HOME_TYPE_FURNITURE_EQUIT_FOR_LOVER, house_uid, house_index, furniture_index, item_index)
			end
		end

		local furniture_info = CoupleHomeHomeData.Instance:GetFurnitureInfo(self.select_house_client_index, furniture_index)
		if furniture_info and furniture_info.item_id > 0 then
			return SysMsgCtrl.Instance:ErrorRemind(Language.CoupleHome.NoModify)
		else
			local item_list = CoupleHomeHomeData.Instance:GetItemListInBagByIndex(furniture_index)
			if item_list == nil or item_list[1] == nil then
				SysMsgCtrl.Instance:ErrorRemind(Language.CoupleHome.CoupleHomeError)
			else
				CoupleHomeCtrl.Instance:ShowPacketView(self.select_house_client_index, furniture_index, lovercallback)
			end
		end
	end
end

function CoupleHomeDecorateContentView:HouseNumberOfCell()
	local other_cfg = CoupleHomeData.Instance:GetOtherCfg()
	local list_num = #self.house_list_data
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local house_uid = CoupleHomeHomeData.Instance:GetHouseUid()
	if list_num >= other_cfg.room_limit_count or main_vo.role_id ~= house_uid then
		return list_num
	end

	return list_num + 1
end

function CoupleHomeDecorateContentView:HouseCellRefresh(cell, data_index)
	data_index = data_index + 1
	local house_cell = self.house_cell_list[cell]
	if house_cell == nil then
		house_cell = CoupleHomeHouseCell.New(cell.gameObject)
		house_cell:SetClickCallBack(self.click_house_cell_call_back)
		house_cell:SetToggleGroup(self.house_list.toggle_group)
		self.house_cell_list[cell] = house_cell
	end

	house_cell:SetIndex(data_index)
	house_cell:SetData(self.house_list_data[data_index])
	house_cell:SetToggleIsOn(self.select_house_client_index == data_index)
end

function CoupleHomeDecorateContentView:NumberOfCell()
	return #self.other_list_data
end

function CoupleHomeDecorateContentView:CellRefresh(cell, data_index)
	data_index = data_index + 1
	local other_cell = self.other_cell_list[cell]
	if other_cell == nil then
		other_cell = CoupleHomeOtherCell.New(cell.gameObject)
		other_cell:SetClickCallBack(self.click_other_cell_call_back)
		other_cell:SetToggleGroup(self.other_list.toggle_group)
		self.other_cell_list[cell] = other_cell
	end

	other_cell:SetIndex(data_index)
	other_cell:SetListType(self.select_other_list_type)
	other_cell:SetData(self.other_list_data[data_index])
	other_cell:ChangeToggleIsOn(self.select_other_list_uid)
end

function CoupleHomeDecorateContentView:ClickFriend()
	if self.select_other_list_type == "friend" then
		return
	end
	self.select_other_list_type = "friend"

	--请求好友家园数据列表
	CoupleHomeHomeCtrl.Instance:SendSpouseHomeOperaReq(CS_SPOUSE_HOME_TYPE.CS_SPOUSE_HOME_TYPE_FRIEND_LIST_INFO)
end

function CoupleHomeDecorateContentView:ClickGuild()
	if self.select_other_list_type == "guild" then
		return
	end
	self.select_other_list_type = "guild"

	--请求盟友家园数据列表
	CoupleHomeHomeCtrl.Instance:SendSpouseHomeOperaReq(CS_SPOUSE_HOME_TYPE.CS_SPOUSE_HOME_TYPE_GUILD_MEMBER_INFO)
end

function CoupleHomeDecorateContentView:ClickPutOn()
	self.put_on_state = not self.put_on_state
	--自动处理收起房间
	self.house_list_toggle.toggle.isOn = self.put_on_state

	self:FlushView()
end

function CoupleHomeDecorateContentView:ClickLoverFurniture()
	self.put_on_state = not self.put_on_state
	--自动处理收起房间
	self.house_list_toggle.toggle.isOn = self.put_on_state

	self:FlushView()
end

function CoupleHomeDecorateContentView:ClickReturn()
	self.select_house_client_index = 1
	self.select_other_list_uid = 0
	self.put_on_state = false
	self.house_list_toggle.toggle.isOn = false

	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	--回到自己的庄园
	CoupleHomeHomeCtrl.Instance:SendSpouseHomeOperaReq(CS_SPOUSE_HOME_TYPE.CS_SPOUSE_HOME_TYPE_VIEW_OTHER_PEOPLE_ROOM, main_vo.role_id)
end

function CoupleHomeDecorateContentView:ClickTotalAttr()
	CoupleHomeCtrl.Instance:ShowTotalAttrView(self.select_house_client_index)
end

--界面隐藏时调用
function CoupleHomeDecorateContentView:CloseView()
	self.is_wait_for_see = false
	self.see_home_role_info = nil
	self:StopPetModelTimeQuest()

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

--界面显示时调用
function CoupleHomeDecorateContentView:InitView()
	self.list_toggle.toggle.isOn = false
	self.select_other_list_type = "friend"
	self.select_house_client_index = 1
	self.select_other_list_uid = 0
	self.toggle_friend.toggle.isOn = true
	self.last_pet_id = -1
	self.put_on_state = false
	self.house_list_toggle.toggle.isOn = false

	self.is_wait_for_see = false
	self.see_home_role_info = nil

	self:FlushHouseList()
	self:FlushView()

	--请求好友家园数据列表
	CoupleHomeHomeCtrl.Instance:SendSpouseHomeOperaReq(CS_SPOUSE_HOME_TYPE.CS_SPOUSE_HOME_TYPE_FRIEND_LIST_INFO)

	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	--请求自己的庄园数据
	CoupleHomeHomeCtrl.Instance:SendSpouseHomeOperaReq(CS_SPOUSE_HOME_TYPE.CS_SPOUSE_HOME_TYPE_VIEW_OTHER_PEOPLE_ROOM, main_vo.role_id)
end

function CoupleHomeDecorateContentView:ClickOtherList()
	if self.select_other_list_type == "friend" then
		CoupleHomeHomeCtrl.Instance:SendSpouseHomeOperaReq(CS_SPOUSE_HOME_TYPE.CS_SPOUSE_HOME_TYPE_FRIEND_LIST_INFO)
	elseif self.select_other_list_type == "guild" then
		CoupleHomeHomeCtrl.Instance:SendSpouseHomeOperaReq(CS_SPOUSE_HOME_TYPE.CS_SPOUSE_HOME_TYPE_GUILD_MEMBER_INFO)
	end
end

function CoupleHomeDecorateContentView:FlushOtherList(key)
	-- if self.select_other_list_type ~= key then
	-- 	return
	-- end

	self.other_list_data = CoupleHomeHomeData.Instance:GetFriendList()
	if self.select_other_list_type == "guild" then
		self.other_list_data = CoupleHomeHomeData.Instance:GetGuildList()
	end
	self.other_list.scroller:RefreshAndReloadActiveCellViews(false)
	-- self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(false)
end

function CoupleHomeDecorateContentView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	self:FlushFurniture()
end

--刷新家具展示
function CoupleHomeDecorateContentView:FlushFurniture()
	local house_info = CoupleHomeHomeData.Instance:GetHouseInfoByIndex(self.select_house_client_index)
	if house_info == nil then
		return
	end

	local is_self = false
	local house_uid = CoupleHomeHomeData.Instance:GetHouseUid()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_vo.role_id == house_uid or main_vo.lover_uid == house_uid then
		is_self = true
	end

	for k, v in ipairs(self.furniture_cell_list) do
		v:SetHouseClientIndex(self.select_house_client_index)

		if not is_self then
			v:ShowAdd(false)
			v:UpDateFurnitureRes(self.select_house_client_index)
		else
			local furniture_info = CoupleHomeHomeData.Instance:GetFurnitureInfo(self.select_house_client_index, v:GetFurnitureIndex())
			if self.put_on_state then
				if furniture_info then
					if furniture_info.item_id > 0 then
						v:ShowAdd(false)
						v:UpDateFurnitureRes(self.select_house_client_index)
					else
						v:ShowAdd(true)
						v:CheckArrow()
						v:ShowFurniture(false)
					end
				else
					v:ShowAdd(true)
					v:CheckArrow()
					v:ShowFurniture(false)
				end
			else
				v:ShowAdd(false)
				if furniture_info and furniture_info.item_id > 0 then
					v:UpDateFurnitureRes(self.select_house_client_index)
				else
					v:ShowFurniture(false)
				end
			end
		end
	end
end

-- select_end选择最后一个
function CoupleHomeDecorateContentView:FlushHouseList(select_end)
	local house_list = CoupleHomeHomeData.Instance:GetHouseList()
	if house_list == nil then
		return
	end

	self.house_list_data = house_list

	if select_end then
		self.select_house_client_index = #self.house_list_data
	end

	self.house_list.scroller:ReloadData(0)
end

function CoupleHomeDecorateContentView:StopPetModelTimeQuest()
	if self.pet_model_time_quest then
		GlobalTimerQuest:CancelQuest(self.pet_model_time_quest)
		self.pet_model_time_quest = nil
	end
end

function CoupleHomeDecorateContentView:StartPetModelTimeQuest()
	self.pet_model_time_quest = GlobalTimerQuest:AddRunQuest(function()
		self.pet_model:SetTrigger("rest")
	end, 10)
end

--刷新小宠物模型
function CoupleHomeDecorateContentView:FlushPetModel()
	local pet_id = CoupleHomeHomeData.Instance:GetPetId()
	if self.last_pet_id == pet_id then
		return
	end
	self.last_pet_id = pet_id

	--停止播放休闲动作
	self:StopPetModelTimeQuest()

	local item_id = LittlePetData.Instance:GetLittlePetItemIDByID(pet_id)
	if item_id <= 0 then
		self.pet_model:ClearModel()
		return
	end

	local res_id = LittlePetData.Instance:GetLittlePetResIDByItemID(item_id)
	local bundle, asset = ResPath.GetLittlePetModel(res_id)
	self.pet_model:SetMainAsset(bundle, asset)


	--开始播放休闲动作
	self:StartPetModelTimeQuest()
	self.pet_model:SetTrigger("rest")
end

function CoupleHomeDecorateContentView:ChangeAvtar()
	if self.see_home_role_info == nil then
		return
	end

	local role_id = self.see_home_role_info.uid
	local function download_callback(path)
		if nil == self.special_avtar or IsNil(self.special_avtar.gameObject) then
			return
		end
		if not self.see_home_role_info or self.see_home_role_info.uid ~= role_id then
			return
		end
		self.special_avtar:SetActive(true)
		self.show_normal:SetActive(false)
		local avatar_path = path or AvatarManager.GetFilePath(role_id, true)
		self.special_avtar.raw_image:LoadSprite(avatar_path,
		function()
			if not self.see_home_role_info or self.see_home_role_info.uid ~= role_id then
				return
			end
		end)
	end

	local sex = self.see_home_role_info.sex
	local prof = self.see_home_role_info.prof
	self.show_normal:SetActive(true)
	self.special_avtar:SetActive(false)
	CommonDataManager.NewSetAvatar(role_id, self.special_avtar, self.show_normal, self.special_avtar, sex, prof, false, download_callback)

	--设置名字
	local role_name = self.see_home_role_info.role_name
	self.node_list["Name"].text.text = role_name
end

function CoupleHomeDecorateContentView:FlushView()
	local house_info = CoupleHomeHomeData.Instance:GetHouseInfoByIndex(self.select_house_client_index)
	if house_info == nil then
		return
	end

	local is_self = false
	local house_uid = CoupleHomeHomeData.Instance:GetHouseUid()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_vo.role_id == house_uid then
		is_self = true
	end
	self.node_list["Avtar"]:SetActive(not is_self)
	self.node_list["TotalAttr"]:SetActive(is_self)
	self.node_list["PutOnBtn"]:SetActive(is_self)
	self.node_list["ReturnBtn"]:SetActive(not is_self)
	
	self.node_list["LoverFurniture"]:SetActive(main_vo.lover_uid == house_uid)
	--判断是否出现进入家园提示语
	if self.is_wait_for_see then
		if self.see_home_role_info and self.see_home_role_info.uid == house_uid then
			SysMsgCtrl.Instance:ErrorRemind(string.format(Language.CoupleHome.EnterOtherHouse, self.see_home_role_info.role_name))
			--设置头像信息
			self:ChangeAvtar()
			self.is_wait_for_see = false
		end
	end

	self.node_list["PutOn"]:SetActive(not self.put_on_state)
	self.node_list["PutOff"]:SetActive(self.put_on_state)

	local theme_type = house_info.theme_type
	local theme_bundle, theme_asset = ResPath.GetRawImage("home_theme_" .. theme_type, true)
	self.node_list["ThemeBg"].raw_image:LoadSprite(theme_bundle, theme_asset)

	-- local title_bundle, title_asset = ResPath.GetCoupleHomeImg("title_text_" .. theme_type)
	-- self.node_list["TitleText"].image:LoadSprite(title_bundle, title_asset)

	local power = CoupleHomeHomeData.Instance:GetHousePowerByHouseIndex(self.select_house_client_index)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = power
	end

	self:FlushFurniture()
	self:FlushPetModel()
end

function CoupleHomeDecorateContentView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "friend" or k == "guild" then
			self:FlushOtherList(k)
		elseif k == "decorate" then
			if v.is_self then
				if v.house_count_change then
					self:FlushHouseList(true)
				else
					self:FlushHouseList()
				end
				self:FlushView()
			else
				self:FlushHouseList()
				self:FlushView()
			end
		end
	end
end

--------------------------CoupleHomeHouseCell--------------------------------
CoupleHomeHouseCell = CoupleHomeHouseCell or BaseClass(BaseCell)
function CoupleHomeHouseCell:__init()

	self.node_list["HouseCell"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function CoupleHomeHouseCell:__delete()
	
end

function CoupleHomeHouseCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function CoupleHomeHouseCell:SetToggleIsOn(is_on)
	self.root_node.toggle.isOn = is_on
end

function CoupleHomeHouseCell:OnFlush()
	if self.data == nil then
		self.node_list["NormalIcon"]:SetActive(false)
		self.node_list["LockIcon"]:SetActive(true)
		self.node_list["Add"]:SetActive(true)
		return
	end
	self.node_list["NormalIcon"]:SetActive(true)
	self.node_list["LockIcon"]:SetActive(false)
	self.node_list["Add"]:SetActive(false)

	local theme_type = self.data.theme_type
	local bundle, asset = ResPath.GetCoupleHomeImg("house_icon_" .. theme_type)
	self.node_list["NormalIcon"].image:LoadSprite(bundle, asset)
end

--------------------------FurnitureCell--------------------------------
FurnitureCell = FurnitureCell or BaseClass(BaseCell)
function FurnitureCell:__init()
	self.house_client_index = 0
	self.furniture_index = -1
	self.asset_name = ""

	self.furniture = self.node_list["Furniture"]

	self.node_list["Bg"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
	self.node_list["Furniture"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function FurnitureCell:__delete()
	
end

function FurnitureCell:SetHouseClientIndex(house_client_index)
	self.house_client_index = house_client_index
end

function FurnitureCell:SetFurnitureIndex(furniture_index)
	self.furniture_index = furniture_index
end

function FurnitureCell:GetFurnitureIndex()
	return self.furniture_index
end

function FurnitureCell:ShowAdd(state)
	self.node_list["ShowAdd"]:SetActive(state)
end

function FurnitureCell:ShowFurniture(state)
	self.node_list["Furniture"]:SetActive(state)
end

function FurnitureCell:CheckArrow()
	local is_have = CoupleHomeHomeData.Instance:HaveFurnitureEquipByIndex(self.house_client_index, self.furniture_index)
	self.node_list["Arrow"]:SetActive(is_have)
end

function FurnitureCell:UpDateFurnitureRes(house_index)
	local furniture_info = CoupleHomeHomeData.Instance:GetFurnitureInfo(house_index, self.furniture_index)
	if furniture_info == nil or furniture_info.item_id <= 0 then
		self:ShowFurniture(false)
		return
	end
	self:ShowFurniture(true)

	local item_id = furniture_info.item_id

	local asset_name = "furniture_" .. item_id
	if asset_name == self.asset_name then
		return
	end
	self.asset_name = asset_name

	--由于底层问题，这里替换资源前先把rawiamge脚本隐藏掉，替换完成自动会还原
	-- self.furniture.raw_image.enabled = false

	--替换资源
	local bundle, asset = ResPath.GetRawImage(self.asset_name)
	self.furniture.raw_image:LoadSprite(bundle, asset, function()
		self.furniture.raw_image:SetNativeSize()
	end)

	--更新位置
	self:UpDateFurniturePos(item_id)
end

function FurnitureCell:UpDateFurniturePos(item_id)
	local pos_x, pos_y = CoupleHomeHomeData.Instance:GetFurniturePosByItemId(item_id)
	self.furniture.transform:SetLocalPosition(pos_x, pos_y, 0)
end

--------------------------CoupleHomeOtherCell------------------------------
CoupleHomeOtherCell = CoupleHomeOtherCell or BaseClass(BaseCell)
function CoupleHomeOtherCell:__init()
	--头像相关
	self.special_avtar_obj = self.node_list["Avtar"]
	self.show_normal = self.node_list["Special"]
	self.normal_avtar = self.node_list["Normal"]

	self.node_list["ButtonCell"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function CoupleHomeOtherCell:__delete()

end

function CoupleHomeOtherCell:SetListType(list_type)
	self.list_type = list_type
end

function CoupleHomeOtherCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function CoupleHomeOtherCell:ChangeToggleIsOn(select_uid)
	if self.data == nil then
		return
	end

	if select_uid == self.data.uid then
		self:SetToggleIsOn(true)
	else
		self:SetToggleIsOn(false)
	end
end

function CoupleHomeOtherCell:SetToggleIsOn(is_on)
	self.root_node.toggle.isOn = is_on
end

function CoupleHomeOtherCell:FlushAvtar()
	local role_id = self.data.uid
	local function download_callback(path)
		if nil == self.special_avtar_obj or IsNil(self.special_avtar_obj.gameObject) then
			return
		end
		if self.data.uid ~= role_id then
			return
		end
		self.normal_avtar:SetActive(false)
		self.show_normal:SetActive(true)
		local avatar_path = path or AvatarManager.GetFilePath(role_id, true)
		self.show_normal.raw_image:LoadSprite(avatar_path,
		function()
			if self.data.uid ~= role_id then
				return
			end
		end)
	end
	self.normal_avtar:SetActive(true)
	self.show_normal:SetActive(false)
	CommonDataManager.NewSetAvatar(role_id, self.show_normal, self.normal_avtar, self.show_normal, self.data.sex, self.data.prof, true, download_callback)
end

function CoupleHomeOtherCell:OnFlush()
	if self.data == nil then
		return
	end

	self:FlushAvtar()

	if self.index <= 3 then
		local rank_bundle, rank_asset = ResPath.GetRankIcon(self.index)
		self.node_list["RankIcon"].image:LoadSprite(rank_bundle, rank_asset)
	else
		self.node_list["RankText"].text.text = self.index
	end
	self.node_list["RankIcon"]:SetActive(self.index <= 3)
	self.node_list["RankText"]:SetActive(self.index > 3)

	self.node_list["HomeCount"].text.text = self.data.room_count

	self.node_list["Name"].text.text = (self.data.role_name)
end
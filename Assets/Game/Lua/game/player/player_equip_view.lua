PlayerEquipView = PlayerEquipView or BaseClass(BaseRender)

local Defult_Icon_List = {
	100, 1100, 3100, 4100, 5100, 6100, {8100, 8200, 8300}, 9100, 2100, 9100
	}

local JIEZHI_INDEX_1 = 8
local JIEZHI_INDEX_2 = 10

function PlayerEquipView:__init(instance, parent_view)

	self.parent_view = parent_view
	self.from_view = TipsFormDef.FROM_PLAYER_INFO
	self.is_opening = false

	self.cells = {}
	self.spec_cells = {}

	self:Init()

	self.mojie_info_event = BindTool.Bind(self.UpdateMojieData, self)
	MojieData.Instance:AddListener(MojieData.MOJIE_EVENT, self.mojie_info_event)

	self.node_list["ImgBg"].button:AddClickListener(BindTool.Bind(self.HandleOpenMojie, self))
	self.node_list["BtnPic"].button:AddClickListener(BindTool.Bind(self.HandleOpenCheckEquipView, self))
	self.node_list["BtnShenEuip"].button:AddClickListener(BindTool.Bind(self.SwitchToShenEquip, self))
	self.node_list["BtnGoToTreasure"].button:AddClickListener(BindTool.Bind(self.GoToTreasure, self))
	self.node_list["BtnGoToTreasure1"].button:AddClickListener(BindTool.Bind(self.GoToTreasure, self))
	self.node_list["BtnItem9GoToTreasure"].button:AddClickListener(BindTool.Bind(self.GoToTreasure, self))
	self.node_list["BtnItem10GoToTreasure"].button:AddClickListener(BindTool.Bind(self.GoToTreasure, self))
	self.node_list["BtnItem11GoToTreasure1"].button:AddClickListener(BindTool.Bind(self.GoToTreasure, self))
	self.node_list["BtnItem12GoToTreasure2"].button:AddClickListener(BindTool.Bind(self.GoToTreasure, self))

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.Mojie)
	RemindManager.Instance:Bind(self.remind_change, RemindName.ShenEquip)
end

function PlayerEquipView:__delete()
	RemindManager.Instance:UnBind(self.remind_change)

	if EquipData.Instance ~= nil then
		EquipData.Instance:UnNotifyDataChangeCallBack(self.equip_data_change_fun)
		self.equip_data_change_fun = nil
		EquipData.Instance:UnNotifyDataChangeCallBack(self.equip_datalist_change_fun)
		self.equip_datalist_change_fun = nil
	end
	if MojieData.Instance then
		MojieData.Instance:RemoveListener(MojieData.MOJIE_EVENT, self.mojie_info_event)
	end
	for k, v in pairs(self.cells) do
		v:DeleteMe()
	end
	self.cells = {}
	for k, v in pairs(self.spec_cells) do
		v:DeleteMe()
	end
	self.spec_cells = {}
	self.parent_view = nil
end

function PlayerEquipView:OpenCallBack()
	if self.is_opening then
		return
	end
	
	self.is_opening = true
	if self.equip_data_change_fun == nil then
		self.equip_data_change_fun = BindTool.Bind1(self.OnEquipDataChange, self)
		EquipData.Instance:NotifyDataChangeCallBack(self.equip_data_change_fun)
	end
	if self.equip_datalist_change_fun == nil then
		self.equip_datalist_change_fun = BindTool.Bind1(self.OnEquipDataListChange, self)
		EquipData.Instance:NotifyDataChangeCallBack(self.equip_datalist_change_fun, true)
	end

	self:OnEquipDataChange()

	if self.node_list["BtnShenEuip"] then
		local flag = OpenFunData.Instance:CheckIsHide("shenzhuang")
		self.node_list["BtnShenEuip"]:SetActive(flag)
	end
end

function PlayerEquipView:CloseCallBack()
	if not self.is_opening then
		return
	end

	self.is_opening = false
	if self.equip_data_change_fun ~= nil then
		EquipData.Instance:UnNotifyDataChangeCallBack(self.equip_data_change_fun)
		self.equip_data_change_fun = nil
	end
	if self.equip_datalist_change_fun ~= nil then
		EquipData.Instance:UnNotifyDataChangeCallBack(self.equip_datalist_change_fun)
		self.equip_datalist_change_fun = nil
	end
end

function PlayerEquipView:HandleOpenMojie()
	ViewManager.Instance:Open(ViewName.Mojie)
end

function PlayerEquipView:HandleOpenCheckEquipView()
	PlayerCtrl.Instance:OpenCheckEquipView()
end

function PlayerEquipView:GoToTreasure()
	ViewManager.Instance:Open(ViewName.Treasure, TabIndex.treasure_choujiang)
	ViewManager.Instance:Close(ViewName.Player)
end

function PlayerEquipView:SwitchToShenEquip()
	self.parent_view:OnSwitchToShenEquip(true)
end

--主角身上的装备发生变化
function PlayerEquipView:OnEquipDataChange(item_id, index, reason)
	local equip_list = EquipData.Instance:GetDataList()
	self:SetData(equip_list)
end

--主角身上的列表装备变化
function PlayerEquipView:OnEquipDataListChange()
	local equip_list = EquipData.Instance:GetDataList()
	self:SetData(equip_list)
end

function PlayerEquipView:SetPlayerData(t)
	local equiplist = EquipData.Instance:GetDataList()
	self:SetData(equiplist)
end

function PlayerEquipView:UpdateMojieData()
	for k,v in pairs(self.spec_cells) do
		local data = MojieData.Instance:GetOneMojieInfo(k - 1)
		v:SetData(data)
		v:ListenClick(BindTool.Bind(self.OnClickMojieItem, self, k, data, v))
		v:SetIconGrayScale(data.mojie_level <= 0)
		v:ShowQuality(data.mojie_level > 0)

      -----显示获取按钮
		if data.mojie_level==0 then
			self.node_list["BtnItem" .. (k + 8) .. "GoToTreasure"]:SetActive(true)
        else
        	self.node_list["BtnItem" .. (k + 8) .. "GoToTreasure"]:SetActive(false)
        end
-------------
	end
end

function PlayerEquipView:SetData(equiplist)
	for k, v in pairs(self.cells) do
		v:ShowGetEffect(false)
		if equiplist[k - 1] and equiplist[k - 1].item_id then
			v:SetData(equiplist[k - 1])
			v:SetIconGrayScale(false)
			v:ShowQuality(true)
			v:SetHighLight(self.cur_index == k)
			if GameEnum.EQUIP_INDEX_JIEZHI == (k - 1) then
				self.node_list["BtnGoToTreasure"]:SetActive(false)
			end
			if GameEnum.EQUIP_INDEX_JIEZHI_2 == (k - 1) then
				self.node_list["BtnGoToTreasure1"]:SetActive(false)
			end
			if ItemData.Instance:GetItemConfig(equiplist[k - 1].item_id).color == GameEnum.ITEM_COLOR_PINK then
				v:ShowGetEffect(true)
			end
		else
			local data = {}
			v:ShowQuality(false)
			data.is_bind = 0
			if type(Defult_Icon_List[k]) == "table" then
				local base_prof = PlayerData.Instance:GetRoleBaseProf()
				data.item_id = Defult_Icon_List[k][base_prof]
			else
				data.item_id= Defult_Icon_List[k]
			end
			if GameEnum.EQUIP_INDEX_JIEZHI == (k - 1) then
				self.node_list["BtnGoToTreasure"]:SetActive(true)
			end
			if GameEnum.EQUIP_INDEX_JIEZHI_2 == (k - 1) then
				self.node_list["BtnGoToTreasure1"]:SetActive(true)
			end
			v:SetData(data)
			v:SetIconGrayScale(true)
			v:SetHighLight(false)
		end
		v:ListenClick(BindTool.Bind(self.OnClickItem, self, k, equiplist[k - 1], v))
	end
end

function PlayerEquipView:Init()
	for i = 1, 10 do
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["Item" .. i])
		self.cells[i] = item
	end
	for i = 1, MOJIE_MAX_TYPE do
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["SpecItem" .. i])
		self.spec_cells[i] = item
	end
	self:UpdateMojieData()
end

function PlayerEquipView:OnClickMojieItem(index, data, cell)
	data.index = index
	local close_callback = function ()
		cell:SetHighLight(false)
	end
	TipsCtrl.Instance:OpenItem(data, self.from_view, nil, close_callback)
end

function PlayerEquipView:OnClickItem(index, data, cell)
	if data == nil or not next(data) then
		cell:SetHighLight(false)
		if index == JIEZHI_INDEX_1 or index == JIEZHI_INDEX_2 then
			ViewManager.Instance:Open(ViewName.Treasure, TabIndex.treasure_choujiang)
			ViewManager.Instance:Close(ViewName.Player)
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.Equip.GetWayTip)
		end
		return
	end
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if not item_cfg then
		cell:SetHighLight(false)
		if index == JIEZHI_INDEX_1 or index == JIEZHI_INDEX_2 then
			ViewManager.Instance:Open(ViewName.Treasure, TabIndex.treasure_choujiang)
			ViewManager.Instance:Close(ViewName.Player)
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.Equip.GetWayTip)
		end
		return
	end
	self.cur_index = index
	cell:SetHighLight(self.cur_index == index)
	local close_callback = function ()
		cell:SetHighLight(false)
		self.cur_index = nil
	end

	if data.param then
		local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
		local shen_info = EquipmentShenData.Instance:GetEquipData(equip_index)
		data.param.angel_level = shen_info and shen_info.level or 0
	end
	TipsCtrl.Instance:OpenItem(data, self.from_view, nil, close_callback)
end

function PlayerEquipView:RemindChangeCallBack(remind_name, num)
	if RemindName.Mojie == remind_name then
		self.node_list["RedPoint"]:SetActive(num > 0)
	elseif RemindName.ShenEquip == remind_name then
		self.node_list["Remind"]:SetActive(num > 0)
		self.node_list["Effect"]:SetActive(num > 0)
	end
end
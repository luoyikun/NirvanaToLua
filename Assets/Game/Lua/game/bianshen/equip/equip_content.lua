-- 幻域-神魔-装备
EquipContent = EquipContent or BaseClass(BaseRender)
local SERIES = 4
function EquipContent:__init()
		
end

function EquipContent:ReleaseCallBack()

end

function EquipContent:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.item_cell_list then
		for k,v in pairs(self.item_cell_list) do
			v:DeleteMe()
		end
		self.item_cell_list = {}
	end

	for k, v in pairs(self.item_equip_list) do
		v:DeleteMe()
	end
	self.item_equip_list = {}
	self.cur_select_index = nil   -- list列表的索引
	self.select_index = nil   	-- 选中名将的索引
end

function EquipContent:OpenCallBack()
	self.cur_role_index = nil
	self.cur_select_index = 1   -- list列表的索引
	self.select_index = BianShenData.Instance:AfterSortList()[self.cur_select_index].seq + 1   ---- 选中名将的索引
	self:OnClickSelect(1)
	self:CheckIsSelect()
end

function EquipContent:UITween()
	UITween.MoveShowPanel(self.node_list["ListBg"], Vector3(-142, 276.3, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["Name"], Vector3(-162.8, 844, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["RightContent"], Vector3(995, -25.1, 0), 0.7)
end

function EquipContent:LoadCallBack()
	self.list_index = 1

	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))

	self.cell_list = {}

	self.item_equip_list = {}
	self.add_btn_list = {}
	self.lock_btn_list = {}
	self.arrow_list = {}
	for i = 1, 4 do
		self.item_equip_list[i] = ItemCell.New()
		self.item_equip_list[i]:SetInstanceParent(self.node_list["ItemCell" .. i])
		self.item_equip_list[i]:ListenClick(BindTool.Bind(self.OnClickEquipItem, self, i))
		self.add_btn_list[i] = self.node_list["BtnAdd" .. i]
		self.node_list["BtnAdd" .. i].button:AddClickListener(BindTool.Bind(self.OnClickAddEquip, self, i))
		self.lock_btn_list[i] = self.node_list["Lock" .. i]
		self.node_list["Lock" .. i].button:AddClickListener(BindTool.Bind(self.OnClickLockEquip, self, i))
		self.arrow_list[i] = self.node_list["Arrow" .. i]
	end

	self.cur_select_index = 1   -- list列表的索引
	self.select_index = BianShenData.Instance:GetSeqBySelectIndex(self.cur_select_index)   ---- 选中名将的索引
	
	self.item_list = {}
	self:InitCell()
	self:DestoryGameObject()
	self:UpdateList()
end

function EquipContent:OnFlush(param_t)
	local select_cfg = BianShenData.Instance:GetSingleDataBySeq(self.select_index - 1)
	if not select_cfg then return end
	local name_str = ToColorStr(select_cfg.name, ITEM_COLOR[select_cfg.color])
	self.node_list["TextName"].text.text = name_str
	self.node_list["TextHeadName"].text.text = name_str
	self:FlushModel(select_cfg)

	local item_cfg = ItemData.Instance:GetItemConfig(select_cfg.item_id)
	if not item_cfg then return end
	local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id or 0)
	self.node_list["HeadIcon"].image:LoadSprite(bundle, asset)
	local is_active = BianShenData.Instance:CheckGeneralIsActive(select_cfg.seq)
	UI:SetGraphicGrey(self.node_list["HeadIconCell"], not is_active)

	local equipment_list_info = BianShenData.Instance:GetEquipmentListInfo(self.select_index - 1)
	if not equipment_list_info then return end
	for i = 1, 4 do
		local is_show_equipment = equipment_list_info[i].item_id == 0
		self.lock_btn_list[i]:SetActive(not is_active)
		self.add_btn_list[i]:SetActive(is_active and is_show_equipment)
		self.item_equip_list[i]:SetActive(is_active and not is_show_equipment)
		self.item_equip_list[i]:SetData({item_id = equipment_list_info[i].item_id})
		local is_show_arrow = BianShenData.Instance:IsShowArrow(select_cfg.seq, i - 1)
		self.arrow_list[i]:SetActive(is_active and is_show_arrow)
	end

	for i = 1, SERIES do
		local is_show_red = BianShenData.Instance:ShowRemindEquipByColor(i + 2)
		self.left_bar_list[i].red_state:SetActive(is_show_red)
	end

	for k, v in pairs(self.item_cell_list) do
		v:SetUpArrow()
	end
	
end

function EquipContent:FlushModel(select_cfg)
	if self.cur_role_index ~= self.select_index then
		UIScene:SetModelLoadCallBack(function(model, obj)
			obj.gameObject.transform.localRotation = Quaternion.Euler(0, 0, 0)
			UIScene:SetRoleModelScale(1.3)
			model:SetTrigger(ANIMATOR_PARAM.REST)
		end)
		local bundle, asset = ResPath.GetMingJiangRes(select_cfg.image_id)
		PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
		local load_list = {{bundle, asset}}
		self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
				local bundle_list = {[SceneObjPart.Main] = bundle}
				local asset_list = {[SceneObjPart.Main] = asset}
				UIScene:ModelBundle(bundle_list, asset_list)
			end)
		self.cur_role_index = self.select_index
	end
end

function EquipContent:InitCell()
	self.left_bar_list = {}
	for i = 1, 4 do
		self.left_bar_list[i] = {}
		self.left_bar_list[i].select_btn = self.node_list["SelectBtn" .. i]
		self.left_bar_list[i].list = self.node_list["List" .. i]
		self.left_bar_list[i].btn_text = self.node_list["BtnText" .. i]
		self.left_bar_list[i].red_state = self.node_list["RedPoint" .. i]
		self.left_bar_list[i].btn_text_high = self.node_list["TxtBtnHigh" .. i]
		self.node_list["SelectBtn" .. i].toggle:AddClickListener(BindTool.Bind(self.OnClickSelect, self, i))
	end
end

function EquipContent:OnClickSelect(index)
	self.list_index = index
	self:SetSelectItem()
	for i = 1, 4 do
		self.node_list["BtnRightActive" .. i]:SetActive(false)
	end
	self.node_list["BtnRightActive" .. self.list_index]:SetActive(true) 
end

function EquipContent:SetSelectItem()
	if self.item_cell_list ~= nil then
		for k,v in pairs(self.item_cell_list) do
			v:SetHighLight(self.cur_select_index)
		end
	end
end

function EquipContent:DestoryGameObject()
	if nil == next(self.item_list) then
		return
	end
	self.is_load = false
	for k,v in pairs(self.item_list) do
		ResMgr:Destroy(v.gameObject)
	end
	self.item_list = {}
	self.item_cell_list = {}
end

function EquipContent:UpdateList()
	self.left_bar_list[self.list_index].select_btn.accordion_element.isOn = false
	self.left_bar_list[self.list_index].list:SetActive(false)
	self.item_list = {}
	self.item_cell_list = {}

	for i = 1, SERIES do
		local bianshen_item_list = BianShenData.Instance:GetListByColorType(i + 2)
		self.left_bar_list[i].select_btn:SetActive(#bianshen_item_list > 0)
		self.left_bar_list[i].btn_text.text.text = Language.BianShen.ShengQiType[i]
		self.left_bar_list[i].btn_text_high.text.text = Language.BianShen.ShengQiType[i]
		self:LoadCell(i, bianshen_item_list)
	end
end

function EquipContent:LoadCell(index, bianshen_item_list)
	local res_async_loader = AllocResAsyncLoader(self, "item_res_async_loader" .. index)
	res_async_loader:Load("uis/views/bianshen_prefab", "BianShenHeadItem", nil, function(prefab)
		if nil == prefab then
			return
		end
		local data_list = BianShenData.Instance:AfterSortList()
		for i = 1, #bianshen_item_list do
			local seq = bianshen_item_list[i].seq + 1
			local obj = ResMgr:Instantiate(prefab)
			local obj_transform = obj.transform
			obj_transform:SetParent(self.left_bar_list[index].list.transform, false)
			obj:GetComponent("Toggle").group = self.left_bar_list[index].list.toggle_group
			local item_cell = BianShenHeadItem.New(obj)
			item_cell:SetTabIndex(3)
			local data = BianShenData.Instance:GetDatalistBySeq(bianshen_item_list[i].seq)
			item_cell:SetData(data)
			item_cell:ListenClick(BindTool.Bind(self.OnClickRoleListCell, self, seq, data, item_cell))
			self.item_list[#self.item_list + 1] = obj_transform
			self.item_cell_list[seq] = item_cell
		end
		self:CheckIsSelect()
		self:Flush()
	end)
end

function EquipContent:CheckIsSelect()
	if self.left_bar_list[self.list_index].select_btn.accordion_element.isOn then --刷新
		self.left_bar_list[self.list_index].select_btn.accordion_element.isOn = false
		self.left_bar_list[self.list_index].select_btn.accordion_element.isOn = true
		return
	end
	self.left_bar_list[self.list_index].select_btn.accordion_element.isOn = true
	self:SetSelectItem()
end

function EquipContent:GetSelectIndex()
	return self.cur_select_index
end

function EquipContent:OnClickRoleListCell(cell_index, cell_data, item_cell)
	if self.cur_select_index == cell_index then return end
	self.last_item_index = self.cur_select_index

	BianShenData.Instance:SetSelectIndex(cell_index)
	self.select_index = cell_data.seq + 1
	self.cur_select_index = cell_index
	self:FlushAllHl()
	self:SetSelectItem()
	self:Flush()
	BianShenCtrl.Instance:SetCurSelectIndex(self.select_index - 1)
end

function EquipContent:FlushAllHl()
	for k,v in pairs(self.cell_list) do
		v:FlushHL()
	end
end

function EquipContent:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(318)
end

function EquipContent:OnClickAddEquip(index)
	local select_cfg = BianShenData.Instance:GetSingleDataBySeq(self.select_index - 1)
	if not select_cfg then return end

	BianShenCtrl.Instance:SetBianShenEquipIndex(index, select_cfg.color, self.select_index - 1)
	ViewManager.Instance:Open(ViewName.BianShenEquipBag)
end

function EquipContent:OnClickLockEquip(index)
	SysMsgCtrl.Instance:ErrorRemind(Language.BianShen.NeedActive)
end

function EquipContent:OnClickEquipItem(index)
	local select_cfg = BianShenData.Instance:GetSingleDataBySeq(self.select_index - 1)
	if not select_cfg then return end
	BianShenCtrl.Instance:SetBianShenEquipIndex(index, select_cfg.color, self.select_index - 1)
	
	local equipment_list_info = BianShenData.Instance:GetEquipmentListInfo(self.select_index - 1)
	if not equipment_list_info then return end
	local data = {}
	data.item_id = equipment_list_info[index].item_id
	data.seq = self.select_index - 1	-- 名将索引
	data.slot_index = index - 1			-- 槽位索引
	TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_BIANSHEN_EQUIP, nil)
end



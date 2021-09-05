TipsFamousSkillView = TipsFamousSkillView or BaseClass(BaseView)

function TipsFamousSkillView:__init()
	self.ui_config = {
		{"uis/views/bianshen_prefab", "FamousSkillTip"},
		{"uis/views/bianshen_prefab", "ModelDragLayerTwo" },
	}

	self.play_audio = true
	self.full_screen = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipsFamousSkillView:OpenCallBack()
	self.skill_index = 1
	self.cur_role_index = 0
	self.node_list["SkillFrame_1"].toggle.isOn = true
end

function TipsFamousSkillView:CloseCallBack()
	self.skill_index = 1
	self.cur_role_index = 0
	UIScene:SetFightBool(false)
end

function TipsFamousSkillView:ReleaseCallBack()
	self.head_cell_list = {}
	self.bianshen_cell_list = {}
	self.cur_role_index = 0
	self.select_index = 1
end

function TipsFamousSkillView:ShowIndexCallBack()
	UIScene:SetBackground("uis/views/bianshen/images/nopack_atlas", "skill_view_bg.png")
	UIScene:SetTerraceBg("uis/views/bianshen/images/nopack_atlas", "skill_view_taizi.png", {position = Vector3(30, -140, 0)}, nil)
	self.cur_role_index = 0
	self:FlushInfo()
	self:FlushModel()
end

function TipsFamousSkillView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	local event_trigger = self.node_list["RotateEventTrigger"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDrag, self))

	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetHeadNumOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshHeadCell, self)
	self.bianshen_cell_list = BianShenData.Instance:AfterSortList()
	self.head_cell_list = {}
	self.select_index = 1
	self.cur_role_index = 0

	self.skill_data_list = BianShenData.Instance:GetSkillCfg() or {}
	for i = 1, #self.skill_data_list do
		self.node_list["IconSkill_" .. i].image:LoadSprite(ResPath.GetFamousGeneral("Skill_" .. self.skill_data_list[i].skill_id))
		self.node_list["SkillFrame_" .. i].toggle:AddClickListener(BindTool.Bind(self.OnClickSkillToggle, self, i))
	end
	self.node_list["SkillFrame_1"].toggle.isOn = true
end

function TipsFamousSkillView:OnClickSkillToggle(index)
	if self.skill_index ~= index then
		self.skill_index = index
		self:FlushInfo()
	end

	local skill_id = self.skill_data_list[index].skill_id
	local skill_cfg = ConfigManager.Instance:GetAutoConfig("roleskill_auto").skillinfo[skill_id]
	if nil ~= skill_cfg and skill_cfg.skill_action then
		UIScene:SetFightBool(true)
		local action_name = skill_cfg.skill_action
		if skill_cfg.hit_count == 1 then
			UIScene:SetTriggerValue(action_name)
			UIScene:SetAnimation(action_name)
		elseif skill_cfg.hit_count >= 3 then
			for i = 1, 3 do
				UIScene:SetTriggerValue(action_name .. "_" .. i)
				UIScene:SetAnimation(action_name .. "_" .. i)
			end
		end
	end
end

function TipsFamousSkillView:GetHeadNumOfCells()
	return #self.bianshen_cell_list
end

function TipsFamousSkillView:RefreshHeadCell(cell, data_index)
	local head_cell = self.head_cell_list[cell]
	if nil == head_cell then
		head_cell = HeadItem.New(cell.gameObject)
		head_cell:SetToggleGroup(self.node_list["ListView"].toggle_group)
		self.head_cell_list[cell] = head_cell
	end
	head_cell:ListenClick(BindTool.Bind(self.ClickItem, self, data_index + 1, cell))
	head_cell:SetData(self.bianshen_cell_list[data_index + 1])
	head_cell:SetHighLight(data_index + 1 == self.select_index)
end

function TipsFamousSkillView:ClickItem(index, cell)
	if self.select_index == index then return end 

	self.select_index = index
	self.skill_index = 1
	self.head_cell_list[cell]:SetHighLight(true)
	self.node_list["SkillFrame_1"].toggle.isOn = true
	self:FlushModel()
	self:FlushInfo()
end

function TipsFamousSkillView:FlushInfo()
	local skill_id = self.skill_data_list[self.skill_index] and self.skill_data_list[self.skill_index].skill_id or 0
	local skill_cfg = ConfigManager.Instance:GetAutoConfig("roleskill_auto").skillinfo[skill_id]
	if skill_cfg and nil ~= next(skill_cfg) then
		self.node_list["TextSkillDec"].text.text = skill_cfg.skill_desc
		self.node_list["TextSkillName"].text.text = skill_cfg.skill_name
	end
	local data = self.bianshen_cell_list[self.select_index]
	if data and nil ~= next(data) then
		local color_type = data.color > 2 and data.color - 2 or 1
		self.node_list["TextType"].text.text = Language.BianShen.ShengQiType[color_type]
		local bundle, asset = ResPath.GetMingJiangNameImage(data.seq)
		self.node_list["ImgName"].image:LoadSprite(bundle, asset, function ()
			self.node_list["ImgName"].image:SetNativeSize()
		end)
	end
end

function TipsFamousSkillView:FlushModel()
	if self.cur_role_index ~= self.select_index then
		UIScene:ChangeScene(self, nil)
		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "mingjiang")
		transform.position = Vector3(10, 4, 13)
		transform.rotation = Quaternion.Euler(0, -142, 0)
		UIScene:SetCameraTransform(transform)
		UIScene:SetModelLoadCallBack(function(model, obj)
			obj.gameObject.transform.localRotation = Quaternion.Euler(0, 0, 0)
			obj.gameObject.transform.localScale = Vector3(1.3, 1.3, 1.3)
			self:OnClickSkillToggle(1)
		end)
		local data = self.bianshen_cell_list[self.select_index]
		local bundle, asset = "", ""
		if data and nil ~= next(data) then
			bundle, asset = ResPath.GetMingJiangRes(data.image_id)
			UIScene:SetActorConfigPrefabData(ConfigManager.Instance:GetPrefabDataAutoConfig("Mingjiang", data.image_id))
		end

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

function TipsFamousSkillView:OnRoleDrag(data)
	if UIScene.role_model then
		UIScene:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

------------------------------------------------HeadItem--------------------------

HeadItem = HeadItem or BaseClass(BaseCell)
function HeadItem:__init()

end

function HeadItem:__delete()

end

function HeadItem:OnFlush()
	if nil == self.data then return end
	local bundle, asset = ResPath.GetItemIcon(self.data.item_id)
	self.node_list["Head"].image:LoadSprite(bundle, asset)
end

function HeadItem:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function HeadItem:ListenClick(handler)
	self.node_list["HeadItem"].toggle:AddClickListener(handler)
end

function HeadItem:SetHighLight(enable)
	self.root_node.toggle.isOn = enable
end

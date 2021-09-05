ShenGeItemTips = ShenGeItemTips or BaseClass(BaseView)
function ShenGeItemTips:__init()
	self.is_modal = true
	self.is_any_click_close = true
	self.ui_config = {{"uis/views/shengeview_prefab", "ShenGeItemTips"}}

	self.play_audio = true
	self.view_layer = UiLayer.Pop

	self.index = -1
end

function ShenGeItemTips:__delete()
end

function ShenGeItemTips:ReleaseCallBack()
	self.fight_text = nil
end

function ShenGeItemTips:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtNumber"], "FightPower3")
end

function ShenGeItemTips:SetData(data)
	self.data = data
end

function ShenGeItemTips:SetCloseCallBack(callback)
	self.callback = callback
end

function ShenGeItemTips:OpenCallBack()
	self:FlushView()
end

function ShenGeItemTips:CloseCallBack()
	self.index = -1
	if self.callback then
		self.callback()
		self.callback = nil
	end
end

function ShenGeItemTips:CloseWindow()
	self:Close()
end

function ShenGeItemTips:FlushView()
	if not self.data or not next(self.data) then
		return
	end
	local data = self.data

	local item_id = ShenGeData.Instance:GetShenGeItemId(data.types, data.quality)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg.icon_id > 0 then
		self.node_list["ImgIcon"].image:LoadSprite(ResPath.GetItemIcon(item_cfg.icon_id))
	end

	local name_color = ITEM_COLOR[data.quality + 1] or TEXT_COLOR.GOLD
	local name = Language.ShenGe.AttrTypeName[data.types] or ""
	local name_des = ToColorStr(name, name_color)
	self.node_list["TxtName"].text.text = name_des

	-- self.node_list["TxtLevelDes"].text.text = string.format(Language.ShenGe.LevelDesc, data.level)
	self.node_list["ImgText"].image:LoadSprite(ResPath.GetRomeNumImage(data.quality))

	local types_des = Language.ShenGe.ShenGeType1
	if data.kind == 1 then
		types_des = Language.ShenGe.ShenGeType2
	end
	self.node_list["TxtTypeDes"].text.text = string.format(Language.ShenGe.TypeDesc, types_des)

	self.node_list["TxtAttr1"]:SetActive(false)
	local attr_type_name = ""
	local attr_value = 0

	attr_type_name = Language.ShenGe.AttrTypeName[data.attr_type_0] or ""
	attr_value = data.add_attributes_0

	local attr_des = string.format(Language.Rune.AttrDes, attr_type_name, attr_value)
	self.node_list["TxtAttr"].text.text = attr_des
	if data.attr_type_1 > 0 then
		attr_type_name = Language.ShenGe.AttrTypeName[data.attr_type_1] or ""
		attr_value = data.add_attributes_1
		attr_des = string.format(Language.Rune.AttrDes, attr_type_name, attr_value)
		self.node_list["TxtAttr1"].text.text = attr_des
		self.node_list["TxtAttr1"]:SetActive(true)
	else
		self.node_list["TxtAttr1"].text.text = ""
	end
	-- 设置战斗力
	local attr_info = CommonStruct.AttributeNoUnderline()
	local attr_type_1 = Language.ShenGe.AttrType[data.attr_type_0]
	local attr_type_2 = Language.ShenGe.AttrType[data.attr_type_1]
	if attr_type_1 then
		RuneData.Instance:CalcAttr(attr_info, attr_type_1, data.add_attributes_0)
	end
	if attr_type_2 then
		RuneData.Instance:CalcAttr(attr_info, attr_type_2, data.add_attributes_1)
	end
	local capability = CommonDataManager.GetCapabilityCalculation(attr_info)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = capability
	end
end
ForgeBaseCell = ForgeBaseCell or BaseClass(BaseCell)

function ForgeBaseCell:__init(instance, cell_type, forge_type)
	self.attr_list = {}
	local child_number = self.node_list["ObjGroup"].transform.childCount
	local count = 1
	for i = 0, child_number - 1 do
		local obj = self.node_list["ObjGroup"].transform:GetChild(i).gameObject
		if string.find(obj.name, "Attr") ~= nil then
			local variable_name_table = obj:GetComponent(typeof(UINameTable))
			local variable_table = U3DNodeList(variable_name_table)
			local data = {}
			data.attr_value = variable_table["AttrValueTxt"]
			data.attr_valueNumber = variable_table["AttrValueNumTxt"]
			data.is_show = variable_table["AttrValueTxt"]
			if forge_type == FORGE_TYPE.SHENZHU then
			data.up_value = variable_table["UpValueTxt"]
			end
			self.attr_list[count] = data
			count = count + 1
		end
	end
	if cell_type ~= nil then
		self.is_next = true
		self.flush_func = BindTool.Bind(self.NextCellFlush, self)
		self.type = cell_type
	else
		self.flush_func = BindTool.Bind(self.CommonFlush, self)
	end
	self.forge_type = forge_type
	if self.forge_type == FORGE_TYPE.SHENZHU then
	end
	self.effect_obj = nil
	self.is_load_effect = false
end

function ForgeBaseCell:__delete()
	if self.effect_obj then
		ResMgr:Destroy(self.effect_obj)
		self.effect_obj = nil
	end
	self.is_load_effect = nil
end

--触发刷新的函数
function ForgeBaseCell:OnFlush()
	self.node_list["ObjGroup"]:SetActive(true)
	self.flush_func()
end

--通用刷新
function ForgeBaseCell:CommonFlush()
	self:AttrFlush()
	self:FlushCallBack()
end

function ForgeBaseCell:AttrFlush(previous_attr)
	--previous_attr不是空的话就是下一效果格子
	local attr_data = {}
	local power_value = 0
	local next_attr_data = nil
	attr_data, power_value = ForgeData.Instance:GetEquipAttrAndPower(self.data)
	if not previous_attr then
		self.data.param.strengthen_level = self.data.param.strengthen_level + 1
		self.data.param.shen_level = self.data.param.shen_level + 1
		next_attr_data = ForgeData.Instance:GetEquipAttrAndPower(self.data)
		self.data.param.strengthen_level = self.data.param.strengthen_level - 1
		self.data.param.shen_level = self.data.param.shen_level - 1
	end
	self.node_list["ZhanLiTxt"].text.text = power_value
	if self.forge_type == FORGE_TYPE.SHENZHU then
		local equip_index = EquipData.Instance:GetEquipIndexByType(self.data.item_cfg.sub_type)
		local shen_level = self.data.param.shen_level
		local cfg = ForgeData.Instance:GetShenOpSingleCfg(equip_index, shen_level)

		local cur_attr_present = 0
		if cfg and next(cfg) then
			cur_attr_present = cfg.attr_percent
		end
		local next_cfg = ForgeData.Instance:GetNextShenZhuAttrPresent(equip_index, cur_attr_present)

		if cfg then
			local curtext = string.format(Language.Forge.ShenZhuCurAttrDesc, Language.Forge.EquipName[equip_index], cfg.attr_percent)
			self.node_list["CurrentAttrTxt"].text.text = curtext
		else
			local curtext = string.format(Language.Forge.ShenZhuCurAttrDesc, Language.Forge.EquipName[equip_index], 0)
			self.node_list["CurrentAttrTxt"].text.text = curtext
		end
		if next_cfg then
			self.node_list["Arrow"]:SetActive(true)
			self.node_list["UpValue"]:SetActive(true)
			self.node_list["Arrow1"]:SetActive(true)
			self.node_list["UpValue1"]:SetActive(true)
			self.node_list["Arrow2"]:SetActive(true)
			self.node_list["UpValue2"]:SetActive(true)
			self.node_list["Arrow3"]:SetActive(true)
			self.node_list["UpValue3"]:SetActive(true)
			self.node_list["Arrow4"]:SetActive(true)
			self.node_list["UpValue4"]:SetActive(true)
			self.node_list["Arrow5"]:SetActive(true)
			self.node_list["UpValue5"]:SetActive(true)
			self.node_list["NextAttrTxt"]:SetActive(true)
			local next_attr_present = string.format(Language.Forge.ShenZhuNextAttrDesc, Language.Forge.EquipName[equip_index], next_cfg.attr_percent)
			
			local next_limit_text = "("..string.format("<color=#f9463b>%s</color>", shen_level.."") .."/".. next_cfg.shen_level ..")"
			self.node_list["NextAttrTxt"].text.text = string.format("%s%s", next_attr_present, next_limit_text)
		else
			self.node_list["Arrow"]:SetActive(false)
			self.node_list["UpValue"]:SetActive(false)
			self.node_list["Arrow1"]:SetActive(false)
			self.node_list["UpValue1"]:SetActive(false)
			self.node_list["Arrow2"]:SetActive(false)
			self.node_list["UpValue2"]:SetActive(false)
			self.node_list["Arrow3"]:SetActive(false)
			self.node_list["UpValue3"]:SetActive(false)
			self.node_list["Arrow4"]:SetActive(false)
			self.node_list["UpValue4"]:SetActive(false)
			self.node_list["Arrow5"]:SetActive(false)
			self.node_list["UpValue5"]:SetActive(false)
			self.node_list["NextAttrTxt"]:SetActive(false)
			local next_attr_present = ""
			local next_limit_text = ""
			self.node_list["NextAttrTxt"].text.text = string.format("%s%s", next_attr_present, next_limit_text)
		end
	end

	local count = 1

	for k,v in pairs(attr_data) do
		if v > 0 then
			if count > #self.attr_list then
				print("属性超出最大可显示范围",k,v)
				break
			end
			local data = self.attr_list[count]
			if previous_attr ~= nil then
				--下一效果格子
				local previous_attr_value = previous_attr[k] or 0
				local promote_value = v - previous_attr_value
				if promote_value > 0 then
					--有提升
					data.is_show:SetActive(true)
					data.attr_value.text.text = k..'：'
					data.attr_valueNumber.text.text = v
					count = count + 1
				else
					--无提升
					data.is_show:SetActive(true)
				end
			else
				--当前效果格子
				data.is_show:SetActive(true)
				data.attr_value.text.text = k..'：'
				data.attr_valueNumber.text.text = v
				if data.up_value then
					local shen_level = self.data.param.shen_level
					local equip_index = EquipData.Instance:GetEquipIndexByType(self.data.item_cfg.sub_type)
					local cfg = ForgeData.Instance:GetShenOpSingleCfg(equip_index, shen_level)
					local next_cfg = ForgeData.Instance:GetShenOpSingleCfg(equip_index, shen_level + 1)
					if next_cfg then
						local diff_value = 0
						local cur_value = 0
						if k == Language.Forge.AttrNameCampareCommon.shengming then
							if cfg and next(cfg) then cur_value = cfg.maxhp end
							diff_value = next_cfg.maxhp -cur_value
						elseif k == Language.Forge.AttrNameCampareCommon.gongji then
							if cfg and next(cfg) then cur_value = cfg.gongji end
							diff_value = next_cfg.gongji - cur_value
						elseif k == Language.Forge.AttrNameCampareCommon.fangyu then
							if cfg and next(cfg) then cur_value = cfg.fangyu end
							diff_value = next_cfg.fangyu - cur_value
						elseif k == Language.Forge.AttrNameCampareCommon.mingzhong then
							if cfg and next(cfg) then cur_value = cfg.mingzhong end
							diff_value = next_cfg.mingzhong - cur_value
						elseif k == Language.Forge.AttrNameCampareCommon.shanbi then
							if cfg and next(cfg) then cur_value = cfg.shanbi end
							diff_value = next_cfg.shanbi - cur_value
						elseif k == Language.Forge.AttrNameCampareCommon.baoji then
							if cfg and next(cfg) then cur_value = cfg.baoji end
							diff_value = next_cfg.baoji - cur_value
						elseif k == Language.Forge.AttrNameCampareCommon.kaobao then
							if cfg and next(cfg) then cur_value = cfg.jianren end
							diff_value = next_cfg.jianren - cur_value
						end
						data.up_value.text.text = diff_value
					end
				end
				count = count + 1
			end
		end
	end

	if next_attr_data then
		for k, v in pairs(next_attr_data) do
			if v > 0 and attr_data[k] <= 0 then
				local data = self.attr_list[count]
				data.is_show:SetActive(true)
				 	local diff_value = 0
				 	diff_value = next_attr_data[k]
					data.up_value.text.text = diff_value
				data.attr_value.text.text = k..'：'
				data.attr_valueNumber.text.text = v
				count = count + 1
			end
		end
	end
	if count <= #self.attr_list then
		for i=count,#self.attr_list do
			self.attr_list[i].is_show:SetActive(false)
		end
	end

	local item_name_index = ForgeData.Instance:GetQualityNameIndex(self.data)

	--设置神铸段位对应的特效
	if item_name_index > 0 then
	end

end

--下一级格子专用刷新
function ForgeBaseCell:NextCellFlush()
	--提升值和上箭头
	self.previous_data = TableCopy(self.data)
	local next_data = TableCopy(self.data)
	next_data.param[self.type] = next_data.param[self.type] + 1
	self.data = next_data
	local previous_attr = ForgeData.Instance:GetEquipAttrAndPower(self.previous_data)
	self:AttrFlush(previous_attr)

	self:FlushCallBack()
end

--不显示数据
function ForgeBaseCell:ShowEmpty()
	self.node_list["ObjGroup"]:SetActive(false)
	self:ShowEmptyCallBack()
end

--专用初始化函数2
function ForgeBaseCell:InitType2()
	if nil == self.data then
		return
	end
	local item_name_index = ForgeData.Instance:GetQualityNameIndex(self.data)
	if item_name_index > 0 then
		self.node_list["EquipNameTxt"]:SetActive(true)
		local bundle, asset = ResPath.GetForgeItemName(item_name_index)
		self.node_list["EquipNameTxt"].image:LoadSprite(bundle, asset .. ".png")
	else
		self.node_list["EquipNameTxt"]:SetActive(false)
	end

end

--专用刷新函数2
function ForgeBaseCell:FlushType2()
	--名字
	local item_name_index = ForgeData.Instance:GetQualityNameIndex(self.data)
	if item_name_index > 0 then
		self.node_list["EquipNameTxt"]:SetActive(true)
		local bundle, asset = ResPath.GetForgeItemName(item_name_index)
		self.node_list["EquipNameTxt"].image:LoadSprite(bundle, asset .. ".png")
	else
		self.node_list["EquipNameTxt"]:SetActive(false)
	end
end

--专用刷新函数2
function ForgeBaseCell:ShowEmptyType2()
	self.node_list["EquipNameTxt"].image:LoadSprite("", "")
end

--回调函数
function ForgeBaseCell:FlushCallBack()
end
function ForgeBaseCell:ShowEmptyCallBack()
end

------------------------锻造View的通用函数------------------------
ForgeBaseView = ForgeBaseView or BaseClass(BaseRender)

function ForgeBaseView:__init(instance, mother_view, index)
	self.index = index
	self.mother_view = mother_view
	self.node_list["Layout2"]:SetActive(true)
	self.node_list["BtnUpgrade"]:SetActive(true)
	--升级材料
	self.material = ItemCellReward.New()
	self.material:SetInstanceParent(self.node_list["Material"])
end

function ForgeBaseView:__delete()
	if nil ~= self.material then
		self.material:DeleteMe()
		self.material = nil
	end
end

function ForgeBaseView:CommonFlush()
	self.data = self.mother_view:GetSelectData()
	if self.data == nil or self.data.item_id == nil or self.data.item_id == 0 then
		self:ShowEmpty()
		self.current_effect:ShowEmpty()
		if nil ~= self.max_effect then
			self.max_effect:ShowEmpty()
		end
		if self.next_effect then
			self.next_effect:ShowEmpty()
		end
		self.material:SetData()
		self.node_list["MaterialNumTxt"].text.text = ""
		return
	end
	self:SetNextCfg()
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	self.current_effect:SetData(self.data)
	if nil ~= self.max_effect then
		self.max_effect:SetData(self.data)
	end
	if self.next_effect then
		self.next_effect:SetData(self.data)
	end
	--升级材料
	self:StuffCommonFlush()
end

function ForgeBaseView:StuffCommonFlush()
	--升级材料
	if self.next_cfg ~= nil then
		self.node_list["Layout2"]:SetActive(true)
		self.node_list["BtnUpgrade"]:SetActive(true)
		local item_id = self.next_cfg["stuff_id"]
		local data = {}
		data.item_id = item_id
		self.material:SetData(data)
		local need_item_num = self.next_cfg["stuff_count"]
		local need_item_text = ' / '..need_item_num
		local had_item_num = ItemData.Instance:GetItemNumInBagById(item_id)
		local had_item_text = ""
		if had_item_num < need_item_num then
			had_item_text = ToColorStr(had_item_num,COLOR.RED)
		else
			had_item_text = ToColorStr(had_item_num,TEXT_COLOR.GREEN_4)
		end
		need_item_text = ToColorStr(need_item_text,TEXT_COLOR.GREEN_4)
		self.node_list["MaterialNumTxt"].text.text = had_item_text..need_item_text
	else
		self.node_list["Layout2"]:SetActive(true)
		self.node_list["BtnUpgrade"]:SetActive(true)
		self.node_list["MaterialNumTxt"].text.text = ""
		self.material:SetData()
	end
end

function ForgeBaseView:MaterialClick()
	if self.data == nil or self.data.item_id == nil then
		return
	end
	local data = {}
	data.item_id = self.next_cfg["stuff_id"]
	TipsCtrl.Instance:OpenItem(data)
end

function ForgeBaseView:SetNextCfg()
end


BaobaoData = BaobaoData or BaseClass()
BaobaoData.Attr = {"gong_ji", "max_hp", "fang_yu", "ming_zhong",  "shan_bi",  "bao_ji", "jian_ren"}
BaobaoData.BabyModel = {10997001, 10998001, 10999001}
function BaobaoData:__init()
	if BaobaoData.Instance then
		print_error("[BaobaoData] Attemp to create a singleton twice !")
	end
	BaobaoData.Instance = self

	self.baby_other_cfg = ConfigManager.Instance:GetAutoConfig("baby_cfg_auto").other[1]
	self.baby_info_cfg = ConfigManager.Instance:GetAutoConfig("baby_cfg_auto").baby_info
	self.baby_upgrade_cfg = ConfigManager.Instance:GetAutoConfig("baby_cfg_auto").baby_upgrade
	self.baby_uplevel_cfg = ConfigManager.Instance:GetAutoConfig("baby_cfg_auto").baby_uplevel
	self.qifu_tree_cfg = ConfigManager.Instance:GetAutoConfig("baby_cfg_auto").qifu_tree
	self.baby_spirit_cfg = ConfigManager.Instance:GetAutoConfig("baby_cfg_auto").baby_spirit
	self.baby_chaosheng_cfg= ConfigManager.Instance:GetAutoConfig("baby_cfg_auto").baby_chaosheng
	self.baby_longfeng = ConfigManager.Instance:GetAutoConfig("baby_cfg_auto").special_baby

	self.baby_spirit_list_cfg = ListToMap(self.baby_spirit_cfg, "id", "level")

	self.baby_list = {}
	self.seq_select_index = 0
	self.spirit_index = 0
	self.all_baby_sprite_list = {}

	RemindManager.Instance:Register(RemindName.MarryBaoBaoAttr, BindTool.Bind(self.GetAttrPanelRedPoint, self))
	RemindManager.Instance:Register(RemindName.MarryBaoBaoZiZhi, BindTool.Bind(self.GetAptitudeRedPoint, self))
	RemindManager.Instance:Register(RemindName.MarryBaoBaoGuard, BindTool.Bind(self.GetGuradRedPointNew, self))
end

function BaobaoData:__delete()
	BaobaoData.Instance = nil
	RemindManager.Instance:UnRegister(RemindName.MarryBaoBaoAttr)
	RemindManager.Instance:UnRegister(RemindName.MarryBaoBaoZiZhi)
	RemindManager.Instance:UnRegister(RemindName.MarryBaoBaoGuard)
end

function BaobaoData:SetBabyInfo(protocol)
	self.baby_list[protocol.baby_info.baby_index + 1] = protocol.baby_info
	self.seq_select_index = protocol.baby_info.baby_index + 1
	self.all_baby_sprite_list[protocol.baby_info.baby_index] = protocol.baby_info.baby_spirit_list
	self:SetSelectedBabyDefaultIndex()
	self:FlushBaobaoCount()
end

function BaobaoData:SetBabyAllInfo(protocol)
	self.baby_list = protocol.baby_list or {}
	for k,v in pairs(self.baby_list) do
		self.all_baby_sprite_list[v.baby_index] = v.baby_spirit_list
	end
	self.baby_chaosheng_count = protocol.baby_chaosheng_count
	self:SetSelectedBabyDefaultIndex()

	self:FlushBaobaoCount()
end

function BaobaoData:FlushBaobaoCount()
	local num = 0
	for k, v in pairs(self.baby_list) do
		if v.baby_id >= 0 then
			num = num + 1
		end
	end
	if self.baby_num then
		if num > self.baby_num then
			if ViewManager.Instance:IsOpen(ViewName.MarryBaby) then
				ViewManager.Instance:FlushView(ViewName.MarryBaby, "flush_baobao")
			else
				ViewManager.Instance:Open(ViewName.MarryBaby, TabIndex.marriage_baobao_att)
			end
			self.baby_num = num
		else
			self.baby_num = num
		end 
	else
		self.baby_num = num
	end
end

function BaobaoData:GetBabyChaoShengCount()
	return self.baby_chaosheng_count
end

function BaobaoData:GetBabyInfo(baby_index)
	if nil == self.baby_list[baby_index] then return end
	return self.baby_list[baby_index]
end

function BaobaoData:GetBabyLevelCfg(baby_id, level)
	if nil == baby_id or nil == level then return end

	local max_level = self:GetMaxBabyUpleveCfgLength()
	return self.baby_uplevel_cfg[baby_id * (max_level + 1) + level + 1]
end

function BaobaoData:GetBabyUpgradeCfg(grade)
	if nil == grade then return end

	return self.baby_upgrade_cfg[grade + 1]
end

-- 只需要三个属性显示，别的属于隐藏属性
function BaobaoData:GetBabyInfoCfgList()
	local baby_cfg = {}
	for k,v in pairs(self.baby_info_cfg) do
		baby_cfg.maxhp = v.maxhp
		baby_cfg.gongji = v.gongji
		baby_cfg.fangyu = v.fangyu
	end
	return baby_cfg
end

function BaobaoData:GetBabyInfoCfg(id)
	return self.baby_info_cfg[id]
end

function BaobaoData:GetBabyQiFuTreeCfg()
	return self.qifu_tree_cfg
end

-- 宝宝属性-----------------------------------
function BaobaoData:SetSelectedBabyIndex(index)
	self.selected_baby_index = index
end
function BaobaoData:SetSelectedBabyDefaultIndex()
	local list = self:GetListBabyData()
	if self.selected_baby_index == nil then    
	   if list[1] then
			self.selected_baby_index = list[1].baby_index + 1
	   end
   else
		local is_del = true
		for k,v in pairs(list) do
		   if v.baby_index + 1 == self.selected_baby_index then
				is_del = false
		   end
		end

		if is_del then
			self.selected_baby_index = nil
			self:SetSelectedBabyDefaultIndex()
		end
	end 
end

function BaobaoData:GetSelectedBabyIndex()
	if self.selected_baby_index == nil then
	   local list = self:GetListBabyData()
	   if list[1] then
			self.selected_baby_index = list[1].baby_index + 1
	   end
	end 
	return self.selected_baby_index or 1
end

function BaobaoData:GetSelectedBabyInfo()
	if nil == self.selected_baby_index then return end
	local baby_data = self:GetListBabyData()
	if baby_data and #baby_data > 0 then
		for k,v in pairs(self:GetListBabyData()) do
			if v.baby_index + 1 == self.selected_baby_index then
				return v
			end
		end
	end
	return nil
end

function BaobaoData:GetBabyInfoByIndex(index)
	if nil == self.selected_baby_index then return end
	local baby_data = self:GetListBabyData()
	if baby_data and #baby_data > 0 then
		for k,v in pairs(self:GetListBabyData()) do
			if v.baby_index + 1 == index then
				return v
			end
		end
	end
	return nil
end

function BaobaoData:GetAptitudeCfg(id,level)
	local common_attr = CommonStruct.Attribute()
	common_attr = CommonDataManager.GetOrderAttributte(common_attr)

	local cur_cfg = self:GetBabyLevelAttribute(id,level)
	local next_cfg = self:GetBabyLevelAttribute(id,level+1)
	local cur_attr = CommonDataManager.GetAttributteByClass(cur_cfg)
	local next_attr = CommonDataManager.GetAttributteByClass(next_cfg)
	local lerp_attr = CommonDataManager.LerpAttributeAttr(cur_attr, next_attr)    -- 属性差

	local data = {}
	for k,v in pairs(common_attr) do
		if lerp_attr[v.key] and lerp_attr[v.key] > 0 then
			local attr_data = {name = v.key,cur_value = cur_attr[v.key],next_value = lerp_attr[v.key]}
			table.insert(data,attr_data)
		end
		if cur_attr[v.key] and lerp_attr[v.key] and cur_attr[v.key] > 0 and lerp_attr[v.key] <= 0 then
			local attr_data = {name = v.key,cur_value = cur_attr[v.key],next_value = lerp_attr[v.key]}
			table.insert(data,attr_data)
		end
	end

	return data
end

function BaobaoData:GetListBabyData()
	local data_list = {}
	local data_index = 1
	for i = 1, GameEnum.BABY_MAX_COUNT do
		local data = self:GetBabyInfo(i)
		if nil == data then return {} end
		data.sort = 1
		if data.baby_id ~= -1 then       -- W2时的id是-1，X现在的id是0
			local love_name = self:GetLoveID()
			if love_name == data.lover_name then
				data.sort = 0
			end
			data_list[data_index] = data
			table.sort(data_list, SortTools.KeyLowerSorters("sort","baby_index"))
			data_index = data_index + 1
		end
	end
	return data_list
end

function BaobaoData:GetBestBabyData()
	local data = self:GetListBabyData()
	return data[#data]
end

function BaobaoData:GetGridUpgradeStuffDataList()
	if nil == self.selected_baby_index then return end

	local data_list = {}
	local baby_info = self:GetBabyInfo(self.selected_baby_index)
	if nil == baby_info then return end

	local level_cfg = self:GetBabyLevelCfg(baby_info.baby_id, baby_info.level)
	if nil == level_cfg then return end

	for i = 0, 3 do
		local data = {}
		data.item_id = level_cfg["uplevel_consume_item_" .. i + 1]
		data.nedd_stuff_num = level_cfg["uplevel_consume_num_" .. i + 1]
		data.is_bind = 0
		data_list[i] = data
	end

	return data_list
end

function BaobaoData:GetBabyLevelAttribute(baby_id, level)
	local baby_cfg_list = BaobaoData.Instance:GetBabyInfoCfgList()
	local base_attr = CommonDataManager.GetAttributteByClass(baby_cfg_list[baby_id])
	local level_attr = CommonDataManager.GetAttributteByClass(self:GetBabyLevelCfg(baby_id, level))
	return CommonDataManager.AddAttributeAttr(base_attr, level_attr)
end

function BaobaoData:GetBabyJieAttribute(grade)
	return CommonDataManager.GetAttributteByClass(self:GetBabyUpgradeCfg(grade))
end

function BaobaoData:GetBabyAllAttribute(baby_id, level, grade)
	local level_attr = self:GetBabyLevelAttribute(baby_id, level)
	local grade_attr = CommonDataManager.GetAttributteByClass(self:GetBabyUpgradeCfg(grade))
	return CommonDataManager.AddAttributeAttr(level_attr, grade_attr)
end

function BaobaoData:GetBaoBaoRemind()
	local falg_1 = self:GetAttrRedPoint()
	if falg_1 then
		return 1
	end
	return 0

end

function BaobaoData:GetAttrPanelRedPoint()
	local attr_red_point = self:GetAttrRedPoint()
	local longfen_remind = self:LongFenRemind()
	return attr_red_point + longfen_remind
end

function BaobaoData:GetZiZhiPanelRedPoint()
	local aptitude_red_point = self:GetAptitudeRedPoint()
	return aptitude_red_point
end

function BaobaoData:GetAttrRedPoint()
	local value = 0
	local baby_list = self:GetListBabyData() or {}
	local upgrade_cfg = {}
	local item_num = 0
	local index = 0
	local lover_name = self:GetLoveID()
	local baby_can_upgrade = {}
	local max_level = self:GetBabyUpgradeCfgMaxGrade()
	for k,v in pairs(baby_list) do 
		if tonumber(v.grade) < max_level and lover_name == v.lover_name then        
			upgrade_cfg = self:GetBabyUpgradeCfg(v.grade)
			if nil == upgrade_cfg then return 0 end
			item_num = ItemData.Instance:GetItemNumInBagById(upgrade_cfg.consume_stuff_id)
			if upgrade_cfg.consume_stuff_num <= item_num then
			   value = 1
			   baby_can_upgrade[index] = 1
			else
			   baby_can_upgrade[index] = 0
			end
		else
			baby_can_upgrade[index] = 0
		end
		index = index + 1
	end
	self.can_up_grade = baby_can_upgrade
	return value
end

function BaobaoData:GetAptitudeRedPoint()
	local baby_list = self:GetListBabyData() or {}
	local max_length = self:GetMaxBabyUpleveCfgLength()
	local index = 0
	local redpoint_xount = 0
	local redpoint_list = {}
	local lover_name = self:GetLoveID()
	if #baby_list <= 0 then
		return 0
	end

	for k,v in pairs(baby_list) do
		if v.level < max_length and lover_name == v.lover_name  then
			local up_level_config = self:GetBabyLevelCfg(v.baby_id, v.level)
			if nil == up_level_config then return end

			local item_list = {}
			local count = 0
			for i = 1 , 4 do
				item_list[i] = ItemData.Instance:GetItemNumInBagById(up_level_config["uplevel_consume_item_"..i])
				if up_level_config["uplevel_consume_num_"..i] <= item_list[i] then
				   count = count + 1
				   redpoint_xount = redpoint_xount + 1
				end
			end
			if count >= 4 then
				redpoint_list[index] = 1
				break
			else
				redpoint_list[index] = 0
			end
		else
			redpoint_list[index] = 0
		end
		index = index + 1
	end

	for k,v in pairs(redpoint_list) do
		if v == 1 then
			return 1
		end
	end

	return 0
end

function BaobaoData:GetGuradRedPointNew()
	local hava_baobao_data = self:GetHaveBaoBaoData()
	local red_point_list = {}
	local flag = 0
	local lover_name = self:GetLoveID()

	for k,v in pairs(hava_baobao_data) do
		if lover_name == v.lover_name then
			local value = self:GetBaobaoRedPointForSpirit(k)
			red_point_list[k-1] = value
			flag = flag + value
		end
	end
	self.gurad_red_point_list = red_point_list
	return flag
end

function BaobaoData:GetGuradRedPointList()
	return self.gurad_red_point_list
end

-- 宝宝list红点（守护精灵用）
function BaobaoData:SetBaobaoRedPoint(index)
	local red_t = {}
	local hava_baobao_data = self:GetHaveBaoBaoData()
	local lover_name = self:GetLoveID()
	if hava_baobao_data[index] then
		if hava_baobao_data[index].lover_name == lover_name then
			local spirit_list = hava_baobao_data[index].baby_spirit_list or {}    
			for k,v in pairs(spirit_list) do
				local spirt_cfg = self:GetBabySpiritCfg(k, v.spirit_level + 1)
				if spirt_cfg and spirt_cfg.id < 2 then
					local item_num = ItemData.Instance:GetItemNumInBagById(spirt_cfg.consume_item)
					if item_num >= spirt_cfg.train_val - v.spirit_train then
						red_t[k] = true
					end
				end
			end
		end
	end
	local num = next(red_t) == nil  and 0 or 1
	return num, red_t
end

function BaobaoData:GetBaobaoRedPointForSpirit(index)
	local hava_baobao_data = self:GetHaveBaoBaoData()
	local spirit_list = hava_baobao_data[index].baby_spirit_list
	local cur_attr = {}
	local train_val = 0
	local spirit_train = 0
	local spirit_has_count = 0
	local consume_item_id = 0
	local level = 0
	local max_level = self:GetBabySpiritMaxLevel() 
	local value = 0

	for k,v in pairs(spirit_list) do

		if v.spirit_level < max_level then   
			level = v.spirit_level == 0 and 1 or v.spirit_level + 1
			cur_attr = self:GetBabySpiritAttrCfg(k,level)

			if cur_attr and cur_attr.id and cur_attr.id < 2 then
				train_val = cur_attr.train_val or train_val
				spirit_train = v.spirit_train
				spirit_has_count = train_val - spirit_train
				consume_item_id = cur_attr.consume_item
				local item_num = ItemData.Instance:GetItemNumInBagById(consume_item_id)

				if item_num >= spirit_has_count then
					return 1
				end
			end
		end
	end
	return 0
end

--获取拥有的宝宝
function BaobaoData:GetHaveBaoBaoData()
	local data = {}
	for k,v in pairs(self.baby_list) do
		if v.baby_id >= 0 then
			table.insert(data,v)
		end
	end
	return data
end

function BaobaoData:GetBabyTotalAttr()
	local baby_list = self:GetListBabyData() or {}
	local total_attr = CommonStruct.Attribute()
	for k,v in pairs(baby_list) do
		local baby_info = self:GetBabyInfo(v.baby_index + 1)
		if nil == baby_info then return total_attr end

		local level_attr = self:GetBabyLevelAttribute(v.baby_id, baby_info.level)
		local jie_attr = self:GetBabyJieAttribute(baby_info.grade)
		local attr = CommonDataManager.AddAttributeAttr(level_attr, jie_attr)
		total_attr = CommonDataManager.AddAttributeAttr(total_attr, attr)
	end

	return total_attr
end

function BaobaoData:GetCapabilityLerp(cur_attr, next_attr)
	return CommonDataManager.GetCapability(CommonDataManager.LerpAttributeAttr(cur_attr, next_attr), true)
end

function BaobaoData:GetBabyUpgradeCfgLength()
	return #self.baby_upgrade_cfg
end

function BaobaoData:GetBabyUpgradeCfgMaxGrade()
	return self.baby_upgrade_cfg[#self.baby_upgrade_cfg].grade
end

----------宝宝守护精灵-------------
function BaobaoData:GetBabySpiritAttrCfg(id, level)
	local cfg = CommonStruct.Attribute()
	if self.baby_spirit_cfg == nil then return cfg end
	for k,v in pairs(self.baby_spirit_cfg) do
		if v.id == id and v.level == level then
			cfg = CommonDataManager.GetAttributteByClass(v)
			cfg.consume_item = v.consume_item
			cfg.train_val = v.train_val
			cfg.level = v.level
			cfg.name = v.name
			cfg.pack_num = v.pack_num
			cfg.title = v.title
			cfg.order = v.order
			cfg.id = v.id
			break
		end
	end
	if level == 0 then
		if id == 0 then
			cfg.title = self.baby_spirit_list_cfg[0][1].title
			cfg.order = self.baby_spirit_list_cfg[0][1].order
			cfg.name = self.baby_spirit_list_cfg[0][1].name
		elseif id == 1 then
			cfg.title = self.baby_spirit_list_cfg[1][1].title
			cfg.order = self.baby_spirit_list_cfg[1][1].order
			cfg.name = self.baby_spirit_list_cfg[1][1].name
		end

	end
	return cfg
end

function BaobaoData:GetBabySpiritCfg(id, level)
	for k,v in pairs(self.baby_spirit_cfg) do
		if v.id == id and v.level == level then
			return v
		end
	end
	return nil
end

function BaobaoData:GetMaxBabyUpleveCfgLength()
	local data_list = self.baby_uplevel_cfg
	local max_length = 0

	for k,v in pairs(data_list) do
		if v.id == 0 then
			max_length = max_length + 1
		end
	end

	return max_length - 1
end

function BaobaoData:GetBabySpiritAttr(id,level)
	local common_attr = CommonStruct.Attribute()
	common_attr = CommonDataManager.GetOrderAttributte(common_attr)

	local cur_cfg = self:GetBabySpiritAttrCfg(id,level)
	local next_cfg = self:GetBabySpiritAttrCfg(id,level +1)
	local cur_attr = CommonDataManager.GetAttributteByClass(cur_cfg)
	local next_attr = CommonDataManager.GetAttributteByClass(next_cfg)
	local lerp_attr = CommonDataManager.LerpAttributeAttr(cur_attr, next_attr)    -- 属性差

	local data = {}
	for k,v in pairs(common_attr) do
		if lerp_attr[v.key] and lerp_attr[v.key] > 0 then
			local attr_data = {name = v.key, cur_value = cur_attr[v.key], next_value = lerp_attr[v.key]}
			table.insert(data,attr_data)
		end
		if cur_attr[v.key] and lerp_attr[v.key] and cur_attr[v.key] > 0 and lerp_attr[v.key] <= 0 then
			local attr_data = {name = v.key, cur_value = cur_attr[v.key], next_value = lerp_attr[v.key]}
			table.insert(data,attr_data)
		end
	end
	return data
end

function BaobaoData:SetBabySpiritInfo(protocol)
	self.baby_index = protocol.baby_index
	self.baby_spirit_list = protocol.baby_spirit_list
	if self.baby_index ~= nil and self.baby_spirit_list ~= nil then
		self.all_baby_sprite_list[self.baby_index] = self.baby_spirit_list
		self.baby_list[self.baby_index+1].baby_spirit_list = self.baby_spirit_list
	end
 end

 function  BaobaoData:GetAllBabySpiritInfo()
	return self.all_baby_sprite_list
 end

 function BaobaoData:GetBabyTotalSpriteAttr()
	local total_attr = CommonStruct.Attribute()
	local baby_list = self:GetListBabyData()
	for k,v in pairs(baby_list) do
		for i = 0, 3 do
			local temp_attr = self:GetBabySpiritAttrCfg(i, v.baby_spirit_list[i].spirit_level)
			total_attr = CommonDataManager.AddAttributeAttr(total_attr, temp_attr)
		end
	end
	return total_attr
 end

 function BaobaoData:GetBabyChaoShengCount()
	return self.baby_chaosheng_count
 end

 function BaobaoData:GetBabyChaoShengCfg()
	return self.baby_chaosheng_cfg
 end

 function BaobaoData:GetCurSpiritLevel()
	local baby_select_index = self:GetSelectedBabyIndex()
	local all_baby_sprite_list = self:GetAllBabySpiritInfo()
	local spirit_level = all_baby_sprite_list[baby_select_index-1][self.spirit_index].spirit_level
	return spirit_level
end

function BaobaoData:SetCurSpiritIndex(index)
	self.spirit_index = index or 0
end

 function BaobaoData:GetBabyChaoShengGold()
	local chaosheng_count = self:GetBabyChaoShengCount()
	if nil == chaosheng_count then 
		return nil 
	end
	local chaosheng_cfg = self:GetBabyChaoShengCfg()
	for k,v in pairs(chaosheng_cfg) do
		if v.chaosheng_num == chaosheng_count + 1 then
			return v.need_gold
		end
	end
	return nil
 end

 function BaobaoData:GetBabyCfgAttr(attr)

 end

 -- 获取是否可继续生娃
function BaobaoData:GetCanBirthBaby()
	for k,v in pairs(self.baby_list) do
		if -1 ~= v.baby_id and v.grade < 4 then
			return false
		end
	end
	return true
end

function BaobaoData:GetBabySpiritMaxLevel()
	local max_level = 0
	for k,v in pairs(self.baby_spirit_cfg) do
		if v.id == 0 then
			max_level = max_level +1
		end
	end
	return max_level
end

function BaobaoData:GetLoveID()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	return main_role_vo.lover_name 
end

function BaobaoData:SetCurTabIndex(index)
	self.tab_index = index or 0
end

-- 获取当前的标签页
function BaobaoData:GetCurTabIndex()
	return self.tab_index
end

-- 宝宝信息配置
function BaobaoData:GetBaoBaoInfoCfg()
	return self.baby_info_cfg
end

function BaobaoData:GetBabyOtherCfg()
	return self.baby_other_cfg
end

function BaobaoData:GetbabyspiritMaxLevel()
	return #self.baby_spirit_list_cfg[0]
end
function BaobaoData:SetLongFenBabyInfo(special_baby_type)
	local data_list =  ConfigManager.Instance:GetAutoConfig("baby_cfg_auto").special_baby
	local item_list = {}
	local quilis_list = {}
	local lonfenitem_list = {}
	for k,v in pairs(data_list) do 
		if v.special_baby_type == special_baby_type then
			table.insert(lonfenitem_list, v.active_item_id)
		end
	end
	for k,v in pairs(lonfenitem_list) do
		if ItemData.Instance:GetItemIndex(v) ~= -1 then
			local color = BaobaoData.Instance:GetLongFenBabyColor(v)
			table.insert(quilis_list, color)
		end
	end
	table.sort(quilis_list, function (a, b)
		return a > b
	end)
	return quilis_list 

end

function BaobaoData:LongFenRemind()
	local my_sex = GameVoManager.Instance:GetMainRoleVo().sex > 0 and 0 or 1
	local my_info = GameVoManager.Instance:GetMainRoleVo().sex > 0 and 1 or 2
	local data_1  = self:SetLongFenBabyInfo(my_sex)
	local data_list = BaobaoData.Instance:GetEquipLongInfo(my_info)
	if data_list then
		if data_list.special_baby_level == 0 and data_list.quality == 0 then
			if data_1[1] then 
				return 1
			end
		end
	end
	return 0
end

function BaobaoData:GetLongFenBabyColor(active_item_id)
	local data_list =  ConfigManager.Instance:GetAutoConfig("baby_cfg_auto").special_baby
	for k,v in pairs(data_list) do
		if v.active_item_id == active_item_id then
			return v.speical_baby_quality
		end
	end
end


function BaobaoData:GetLongFenCfg()
	return 	self.baby_longfeng 
end

function BaobaoData:GetEquipBaoBaoLongFen(special_baby_type,speical_baby_quality)
	local data_list =  ConfigManager.Instance:GetAutoConfig("baby_cfg_auto").special_baby
	for k,v in pairs(data_list) do
		if v.special_baby_type == special_baby_type and v.speical_baby_quality == speical_baby_quality then
			return v.showmight 
		end
	end
	return 0
end

function BaobaoData:GetEquipLongInfo(index)
	local data_list = MarryEquipData.Instance:GetLongInfo()
	for k,v in pairs(data_list) do
		if k == index then
			return v
		end
	end
end

function BaobaoData:GetEquipFengInfo(index)
	local data_list = MarryEquipData.Instance:GetFengInfo()
	for k,v in pairs(data_list) do
		if k == index then
			return v
		end
	end
end

function BaobaoData:GetMaxQualityNum(index)
	local data_list = ConfigManager.Instance:GetAutoConfig("baby_cfg_auto").special_baby
	local data_index = 0
	for k, v in pairs(data_list) do
		if v.special_baby_type == index then
			data_index = data_index + 1 
		end
	end
	return data_index
end

function BaobaoData:GetMaxLongFenBaoBaoCfg(special_baby_type,speical_baby_quality)
	local data_list = ConfigManager.Instance:GetAutoConfig("baby_cfg_auto").special_baby
	for k,v in pairs(data_list) do
		if v.special_baby_type + 1 == special_baby_type and v.speical_baby_quality == speical_baby_quality then
			return v.modleID, v.scale
		end
	end
end
function BaobaoData:ShowLongFengTab()
	local baby_list = self:GetListBabyData() or {}
	local count = #baby_list
	if count > 0 then 
		return true
	end
	return false
end

--是否请求协议
function BaobaoData:IsRequirePetWalkPro()
	local is_require = false
	local baby_count = #self:GetListBabyData()
	local is_open = OpenFunData.Instance:CheckIsHide("MarryBaby")
	local fb_scene_cfg = Scene.Instance:GetCurFbSceneCfg()

	if is_open and baby_count > 0 and fb_scene_cfg.pb_pet and fb_scene_cfg.pb_pet ~= 1 then 
		is_require = true 
	end

	return is_require
end

-- 随机取宝宝对话
function BaobaoData:GetBaoBaoDialog()
	local dialog_tab = {
		[1] = {baby_first_talk = true, dialog_cfg = {
				[1] = {dialog = 1, time = 5},
				[2] = {dialog = 2, time = 4},
			}
		},
		[2] = {baby_first_talk = true, dialog_cfg = {
				[1] = {dialog = 1, time = 5},
				[2] = {dialog = 2, time = 4},
			}
		},
		[3] = {baby_first_talk = false, dialog_cfg = {
				[1] = {dialog = 1, time = 3},
				[2] = {dialog = 2, time = 4},
			}
		},
	}

	local random_index = math.random(1, #dialog_tab)
	local dialog_cfg = dialog_tab[random_index] or dialog_tab[1]

	return random_index, dialog_cfg
end
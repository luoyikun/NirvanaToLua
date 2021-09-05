HeadFrameData = HeadFrameData or BaseClass()

function HeadFrameData:__init()
	HeadFrameData.Instance = self

	self.data_list = {}

	self.head_frame_list_data = ConfigManager.Instance:GetAutoConfig("personalize_window_auto").avatar_rim
	local head_frame_level_info_data = ConfigManager.Instance:GetAutoConfig("personalize_window_auto").avatar_rim_level
	self.head_frame_level_info_data = ListToMap(head_frame_level_info_data, "avatar_type", "avatar_level")
	self:InitListData()
end

function HeadFrameData:__delete()
	HeadFrameData.Instance = nil
	self.data_list = {}
end

function HeadFrameData:GetHeadFrameRedPoint()
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local is_can_up = false
	for k,v in pairs(self.head_frame_list) do
		v.cur_num = ItemData.Instance:GetItemNumInBagById(v.item1.item_id)
		v.is_can_up = false
		if v.cur_num >= v.need_num and v.open_day <= cur_day then
			if self.head_frame_level_info_data[v.seq][v.level + 1] then
				v.is_can_up = true
				is_can_up = true
			end
		end
	end
	return is_can_up
end

function HeadFrameData:InitListData()
	self.head_frame_list = {}
	for i,v in ipairs(self.head_frame_list_data) do
		local data = self:InitData(v)
		table.insert(self.head_frame_list, data)
	end
end

function HeadFrameData:InitData(value)
	if self.head_frame_level_info_data[value.seq] == nil then
		return {}
	end
	local data = {}
	data.seq = value.seq
	data.item1 = self.head_frame_level_info_data[value.seq][0].common_item
	data.name = value.name
	data.image = value.image
	data.maxhp = value.maxhp
	data.gongji = value.gongji
	data.fangyu = value.fangyu
	data.open_day = value.open_day
	data.max_level = #self.head_frame_level_info_data[value.seq]
	data.cur_num = 0
	data.need_num = data.item1.num
	data.level = 0
	data.is_active = false
	data.is_can_up = false
	return data
end

function HeadFrameData:SetListDataInfo(protocol)
	self.user_frame = protocol.cur_use_avatar_type
	for i = 1, #self.head_frame_list do
		local data = self.head_frame_list[i]
		data.level = protocol.avatar_level[i]
		local attrs = self:GetAttrs(data.level, data.seq)
		for k,v in pairs(GameEnum.AttrList) do
			data[v] = attrs[k]
		end
		data.is_active = data.level > 0
		data.item1 = self.head_frame_level_info_data[data.seq][data.level].common_item
		data.need_num = data.item1.num
	end
end

function HeadFrameData:GetListData()
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	self.data_list = {}
	local head_frame_list = {}
	for k,v in pairs(self.head_frame_list) do
		if v.open_day <= cur_day then
			head_frame_list[k] = v
		end
	end

	for k,v in pairs(head_frame_list) do
		table.insert(self.data_list, v)
	end
	return self.data_list
end

function HeadFrameData:GetIndexDataByItemId(item_id)
	local data_list = self:GetListData()
	for k, v in pairs(data_list) do
		if v.item1 and v.item1.item_id and v.item1.item_id == item_id then
			return v.seq, k
		end
	end
end

function HeadFrameData:GetMaxNum()
	return #self.data_list
end

function HeadFrameData:GetChooseData(index)
	for k,v in pairs(self.data_list) do
		if v.seq == index then
			return v
		end
	end
	return self.data_list[1]
end


function HeadFrameData:GetChooseAllData(index)
	for k,v in pairs(self.head_frame_list) do
		if v.seq == index then
			return v
		end
	end
	return self.head_frame_list[1]
end




function HeadFrameData:GetAttrData(level, id)
	if level == nil or id == nil or self.head_frame_level_info_data[id] == nil then
		return nil
	end
	local data = {}
	data.level = level
	data.power = self:GetPowerByLevel(level, id)
	data.attrs = self:GetAttrs(level, id)
	return data
end

function HeadFrameData:GetPowerByLevel(level, id)
	local data = self.head_frame_level_info_data[id][level]
	if data == nil then
		return -1
	end
	local power = CommonDataManager.GetCapabilityCalculation(data)
	return power
end

function HeadFrameData:GetAttrs(level, id)
	local data = self.head_frame_level_info_data[id][level]
	if data == nil then
		return {0, 0, 0}
	end
	return {[1] = data.maxhp, [2] = data.gongji, [3] = data.fangyu}
end

function HeadFrameData:GetHeadFrameAttribute()
	-- local data = CommonStruct.AttributeNoUnderline()
	local data = {
		maxhp = 0,									-- 血量上限
		gongji = 0,									-- 攻击
		fangyu = 0,									-- 防御
	}
	for k,v in pairs(self.head_frame_list) do
		data.maxhp = data.maxhp + v.maxhp
		data.gongji = data.gongji + v.gongji
		data.fangyu = data.fangyu + v.fangyu
	end
	return data
end

function HeadFrameData:GetUseFrame()
	return self.user_frame
end

function HeadFrameData:GetPrefabByItemId(item_id)
	for k,v in pairs(self.head_frame_list) do
		if v.item1.item_id == item_id then
			return v.seq
		end
	end
	return -1
end
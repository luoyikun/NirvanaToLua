SendGiftData = SendGiftData or BaseClass()

local FRIEND_TYPE = 1
local GUILD_TYPE = 2

function SendGiftData:__init()
	if SendGiftData.Instance then
		print_error("[SendGiftData] Attemp to create a singleton twice !")
	end
	SendGiftData.Instance = self
	self.select_toggle = 2
	self.select_index = 1 
	self.open_type = 1
	self.record_list = {}
	self.record_list.record_list = {}
	self.record_list.is_give = 0
	self.all_record_list = {}
end

function SendGiftData:__delete()
	SendGiftData.Instance = nil
	self.record_list = nil
end

function SendGiftData:SetGiveItemRecord(protocol)
	self.record_list.record_list = {}
	self.record_list.is_give = protocol.is_give
	self.record_list.record_list = protocol.record_list
	self.all_record_list[protocol.is_give] = {}
	self.all_record_list[protocol.is_give] = protocol.record_list
end

function SendGiftData:GetAllRecordList()
	return self.all_record_list
end

function SendGiftData:GetGiveItemRecord()
	return self.record_list.record_list
end

function SendGiftData:GetIsGiveRecord()
	return self.record_list.is_give or 0
end

function SendGiftData:GetNameById(id)
	local friend_info = ScoietyData.Instance:GetFriendInfoById(id)
	if friend_info and friend_info.gamename and friend_info.sex then
		return friend_info.sex
	end
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	if guild_id > 0 then
		local guild_menber_list = GuildDataConst.GUILD_MEMBER_LIST.list
		for k,v in pairs(guild_menber_list) do
			if v and v.uid == id then
				return v.sex
			end
		end
	end
	return false
end

function SendGiftData:SetSelectToggle(num)
	self.select_toggle = num
end

function SendGiftData:GetSelectToggleNum()
	return self.select_toggle
end

function SendGiftData:GetHaoGanList()
	if self.all_record_list then
		local list = {}
		for i = 0, 1 do
			if self.all_record_list[i] then
				for k,v in pairs(self.all_record_list[i]) do
					list[v.uid] = list[v.uid] or 0
					list[v.uid] = list[v.uid] + 1
				end
			end
		end
		return list
	end
	return false
end

function SendGiftData:GetListDataByType(open_type)
	local scroller_data = {}
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	if open_type == GUILD_TYPE then
		scroller_data = TableCopy(GuildDataConst.GUILD_MEMBER_LIST.list) or {}
		if #scroller_data > 0 then
			for i = #scroller_data, 1, -1 do
				if scroller_data[i].uid == role_id then
					table.remove(scroller_data, i)
				end
			end
		end
	else
		scroller_data = TableCopy(ScoietyData.Instance:GetFriendInfo())
	end

	if scroller_data then
		local hao_gan_list = self:GetHaoGanList()
		for k,v in pairs(scroller_data) do
			if hao_gan_list and open_type == GUILD_TYPE then
				v.haogan_num = 0
				if v and v.uid and hao_gan_list[v.uid] then
					v.haogan_num = hao_gan_list[v.uid]
				end
			else
				v.haogan_num = 0
				if v and v.user_id and hao_gan_list[v.user_id] then
					v.haogan_num = hao_gan_list[v.user_id]
				end
			end
		end
	end
	table.sort(scroller_data, SortTools.KeyUpperSorters("is_online", "haogan_num"))
	return scroller_data
end

function SendGiftData:GetRoleindexByUid(uid)
	local scroller_list1 = self:GetListDataByType(FRIEND_TYPE)
	if scroller_list1 then
		for k,v in pairs(scroller_list1) do
			if v.user_id == uid then
				return k, FRIEND_TYPE
			end
		end
	end

	local scroller_list2 = self:GetListDataByType(GUILD_TYPE)
	if scroller_list2 then
		for k,v in pairs(scroller_list2) do
			if v.uid == uid then
				return k, GUILD_TYPE
			end
		end
	end
	return -1, -1
end

function SendGiftData:SetSelectIndexAndType(index, open_type)
	self.select_index = index
	self.open_type = open_type
end

function SendGiftData:GetJumpIndexAndType()
	return self.select_index, self.open_type
end
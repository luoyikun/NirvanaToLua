GuildMazeChatCell = GuildMazeChatCell or BaseClass(ChatCell)

function GuildMazeChatCell:__init()

end

function GuildMazeChatCell:__delete()
	if self.content_obj then
		ResPoolMgr:Release(self.content_obj.gameObject)
		self.content_obj = nil
	end
end

function GuildMazeChatCell:OnFlush()
	ChatCell.OnFlush(self)
	self.time = ""
end

--加载聊天框
function GuildMazeChatCell:LoadWindow(main_role_id)
	local assetbundle = ""
	local prefab_name = ""
	local left = true
	local bubble_type = self.data.channel_window_bubble_type
	bubble_type = bubble_type or -1
	bubble_type = bubble_type + 1
	if bubble_type == -1 then bubble_type = 0 end
	if main_role_id == self.role_id then
		left = false
	end

	self.is_special_bubble = false
	if self.data.channel_type and self.data.channel_type == CHANNEL_TYPE.SCENE then
		assetbundle = "uis/views/miscpreload_prefab"
		prefab_name = left and "ContentLeft" or "ContentRight"
	elseif not bubble_type or bubble_type == 0 then
		assetbundle = "uis/views/miscpreload_prefab"
		prefab_name = left and "ContentLeft" or "ContentRight"
	else  -- 特殊气泡框只加载容器
		assetbundle = "uis/views/miscpreload_prefab"
		prefab_name = left and "BubbleSlotLeft" or "BubbleSlotRight"
		self.is_special_bubble = true
	end
	-- 公会迷宫特殊处理
	if self.data.channel_type and self.data.channel_type == CHANNEL_TYPE.GUILD then
		if not bubble_type or bubble_type == 0 then
			assetbundle = "uis/views/miscpreload_prefab"
			prefab_name = left and "GuildMazeContentLeft" or "GuildMazeContentRight"
		else
			assetbundle = "uis/views/miscpreload_prefab"
			prefab_name = left and "GuildMazeBubbleSlotLeft" or "GuildMazeBubbleSlotRight"
		end
	end

	if self.content_obj then
		ResPoolMgr:Release(self.content_obj.gameObject)
		self.content_obj = nil
	end

	local gameobj = ResPoolMgr:TryGetGameObject(assetbundle, prefab_name)
	local obj = U3DObject(gameobj, gameobj.transform, self)

	self.content_obj = obj

	local parent_obj = left and self.left_view or self.right_view
	self.content_obj.transform:SetParent(parent_obj.transform, false)
	self:SetContent(self.content_obj.rich_text, left, TEXT_COLOR.LOWBLUE)

	if self.is_easy then
		return
	end
	if self.is_special_bubble then
		assetbundle = "uis/chatres_prefab"
		prefab_name = left and string.format("BubbleLeft%s", bubble_type) or string.format("BubbleRight%s", bubble_type)

		self.async_loader = self.async_loader or AllocAsyncLoader(self, "bubble")
		self.async_loader:Load(assetbundle, prefab_name, function(obj)
			if IsNil(obj) then
				return
			end
			
			if not self.is_special_bubble then
				return
			end

			obj.transform:SetParent(self.content_obj.transform, false)
			obj.transform:SetSiblingIndex(0)
		end)
	end
end

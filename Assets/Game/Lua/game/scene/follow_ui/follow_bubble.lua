FollowBubble = FollowBubble or BaseClass(BaseRender)
FollowBubble.BUBBLE_VIS = false

function FollowBubble:__init()
	self.bubble_text_dec = nil
	self.obj_type = nil
	self.follow_parent = nil
	self.async_loader = nil
	self.bubble_text_str = nil
end

function FollowBubble:__delete()
	self.bubble_text_str = nil
	self.follow_parent = nil
	self:RemoveDelayTime()

	if self.bubble_vis then
		FollowBubble.BUBBLE_VIS = false
	end
end

function FollowBubble:SetFollowParent(obj_type, follow_parent)
	self.obj_type = obj_type
	self.follow_parent = follow_parent
	self:UpdateBubble()
end

function FollowBubble:CreateBubble(text, time)
	FollowBubble.BUBBLE_VIS = true
	self.bubble_vis = true

	self.async_loader = AllocAsyncLoader(self, "root_loader")
	self.async_loader:SetIsUseObjPool(true)
	self.async_loader:SetIsInQueueLoad(true)

	self.async_loader:Load("uis/views/miscpreload_prefab", "LeisureBubble", 
		function (gameobj)
			if IsNil(self.follow_parent) then
				DelGameObjLoader(self, "root_loader")
				return
			end

			if not self.bubble_vis or not FollowBubble.BUBBLE_VIS then
				DelGameObjLoader(self, "root_loader")
				return
			end

			self:SetInstance(gameobj)
			self:SetInstanceParent(self.follow_parent, false)
			
			self.root_node:SetLocalPosition(0, 80, 0)
			if nil ~= time and time > 0 then
				self:RemoveDelayTime()
				self.delay_time = GlobalTimerQuest:AddDelayTimer(function() self:HideBubble() end, time)
			end

			self.root_node:SetActive(true)
			RichTextUtil.ParseRichText(self.root_node.rich_text, text)
		end)
end

function FollowBubble:ChangeBubble(text, time)
	if "" == text or nil == text then
		return
	end
	
	self.bubble_text_str = text
	self.bubble_time = time
	self:UpdateBubble()
end

function FollowBubble:ShowBubble()
	if FollowBubble.BUBBLE_VIS then
		return
	end

	FollowBubble.BUBBLE_VIS = true
	self.bubble_vis = true
	self:UpdateBubble()
end

function FollowBubble:HideBubble()
	FollowBubble.BUBBLE_VIS = false
	self.bubble_vis = false

	if nil ~= self.async_loader then
		DelGameObjLoader(self, "root_loader")
	end
end

function FollowBubble:UpdateBubble()
	if nil ~= self.follow_parent and nil ~= self.bubble_text_str then
		self:CreateBubble(self.bubble_text_str, self.bubble_time)
	end
end

function FollowBubble:RemoveDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end
GuildYunBiao = GuildYunBiao or BaseClass(BaseRender)

function GuildYunBiao:__init()
	
end

function GuildYunBiao:__delete()
	self:CancelTimer()
end

function GuildYunBiao:LoadCallBack()
	self.node_list["BtnGo"].button:AddClickListener(BindTool.Bind(self.OnClickGoToBiaoChe, self))
	self.node_list["BtnZhaoJi"].button:AddClickListener(BindTool.Bind(self.OnClickZhaoJi, self))
	self:Flush()
end

function GuildYunBiao:OnFlush()
	local post = GuildData.Instance:GetGuildPost()
	local flag = post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG
	if self.node_list and self.node_list["BtnZhaoJi"] and not IsNil(self.node_list["BtnZhaoJi"].gameObject) then
		self.node_list["BtnZhaoJi"].gameObject:SetActive(flag)
	end
end

function GuildYunBiao:OnClickGoToBiaoChe()
	self.not_auto_follow = false
	self:OnGoToBiaoChe()
	if nil == self.time_quest then
		self.time_quest = GlobalTimerQuest:AddRunQuest(function()
			if not GuildCtrl.Instance.has_yunbiao then
				self:CancelTimer()
			end
			self:OnGoToBiaoChe()
		end, 3)
	end
end

function GuildYunBiao:OnGoToBiaoChe()
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	if self.not_auto_follow ~= nil and not self.not_auto_follow then
		GuildCtrl.Instance:SendGuildYunBiaoReq(BIAOCHE_OPERA_TYPE.BIAOCHE_OPERA_TYPE_BIAOCHE_POS, guild_id)
	end
end

function GuildYunBiao:OnClickZhaoJi()
	local dec = Language.Guild.GuildHuSongStart
	ChatCtrl.SendChannelChat(CHANNEL_TYPE.GUILD, dec, CHAT_CONTENT_TYPE.TEXT)
	ViewManager.Instance:Open(ViewName.ChatGuild)
end

function GuildYunBiao:CancelTimer()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function GuildYunBiao:StopFollow(enable)
	self.not_auto_follow = enable
	if enable then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
end

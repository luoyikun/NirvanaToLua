require("game/guild/guild_totem_view")
require("game/guild/guild_altar_view")

GuildSkillContentView = GuildSkillContentView or BaseClass(BaseRender)

function GuildSkillContentView:__init(instance, mother_view)
	self.tab_index = TabIndex.guild_altar
	self.node_list["TotemContent"].uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.totem_view = GuildTotemView.New(obj)
		self:Flush()
	end)

	self.node_list["AltarContent"].uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.altar_view = GuildAltarView.New(obj)
		self:Flush()
	end)
	self.node_list["SkillButton"].toggle:AddClickListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.guild_altar))
	self.node_list["QiZhiButton"].toggle:AddClickListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.guild_totem))
end

function GuildSkillContentView:__delete()
	if self.totem_view then
		self.totem_view:DeleteMe()
		self.totem_view = nil
	end

	if self.altar_view then
		self.altar_view:DeleteMe()
		self.altar_view = nil
	end
end

function GuildSkillContentView:ShowOrHideTab()

end

function GuildSkillContentView:OnToggleChange(index, is_on)
	if is_on then
		self.tab_index = index
		if self.tab_index == TabIndex.guild_altar and self.altar_view then
			GuildCtrl.Instance:SendGuildInfoReq()
			self.altar_view:Flush()
		elseif self.tab_index == TabIndex.guild_totem and self.totem_view then
			GuildCtrl.Instance:SendAllGuildMemberInfoReq()
			self.totem_view:Flush()
		end
	end
end

-- function GuildSkillContentView:OpenCallBack()
-- 	MarryEquipCtrl.SendActiveLoverEquipInfo()
-- 	if self.tab_index == TabIndex.guild_altar and self.altar_view then
-- 		self.altar_view:OpenCallBack()
-- 	elseif self.tab_index == TabIndex.guild_totem and self.totem_view then
-- 		self.totem_view:OpenCallBack()
-- 	elseif self.tab_index == TabIndex.guild_list and self.list_view then
-- 		self.list_view:OpenCallBack()
-- 	end
-- 	self:UpdateRemind()
-- end

function GuildSkillContentView:OnFlush(param_t)
	self:UpdateRemind()
	if self.tab_index == TabIndex.guild_altar and self.altar_view then
		self.altar_view:Flush()
	elseif self.tab_index == TabIndex.guild_totem and self.totem_view then
		self.totem_view:Flush()
	end
end

function GuildSkillContentView:UpdateRemind()
	-- local remind_m = RemindManager.Instance
	-- self.node_list["RedPoint1"]:SetActive(remind_m:GetRemind(RemindName.MarryEquip) > 0)
	-- self.node_list["RedPoint2"]:SetActive(remind_m:GetRemind(RemindName.MarrySuit) > 0)
end

function GuildSkillContentView:CloseAllWindow()
	if self.totem_view then
		self.totem_view:CloseAllWindow()
	end
end
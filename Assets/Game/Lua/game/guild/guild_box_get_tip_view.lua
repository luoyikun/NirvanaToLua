GuildBoxGetTips = GuildBoxGetTips or BaseClass(BaseView)

function GuildBoxGetTips:__init()
	self.ui_config = {
		{"uis/views/guildview_prefab", "BoxGetTips"},
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.item = nil
	self.data = {nil}
end

function GuildBoxGetTips:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))

	self.node_list["BtnCancel"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnGet"].button:AddClickListener(BindTool.Bind(self.ClickGet, self))

end

function GuildBoxGetTips:OpenCallBack()
	-- GuildCtrl.Instance:GuildFlushView("guild_box")
	-- GuildCtrl.Instance:SetOpenBoxTips(true)
	if self.item == nil then
		self.item = ItemCell.New()
		self.item:SetInstanceParent(self.node_list["Item"])
	end
	self.item:SetData(self.reward)
	self:Flush()
end

function GuildBoxGetTips:OnFlush()
	-- self.item:SetData(self.data)
end

function GuildBoxGetTips:CloseCallBack()
	-- GuildCtrl.Instance:SetOpenBoxTips(false)
	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end
end

function GuildBoxGetTips:ClickGet()
	if self.callback then
		self.callback(self.data)
	end
	self:Close()
end

function GuildBoxGetTips:SetGetCallBack(data, callback)
	local config = GuildData.Instance:GetBoxConfigByLevel(data.box_level)
	if config then
		local reward = {config.show}
		self.reward = reward[1]
	end
	self.data = data
	self.callback = callback
end
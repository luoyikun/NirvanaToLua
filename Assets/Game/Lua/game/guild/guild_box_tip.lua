GuildBoxTips = GuildBoxTips or BaseClass(BaseView)

function GuildBoxTips:__init()
	self.ui_config = {
		{"uis/views/guildview_prefab", "BoxTips"},
	}
	self.is_modal = true
	self.is_any_click_close = true
end

function GuildBoxTips:SetLevelUpFree(click)
	self.level_free_click = click
end

function GuildBoxTips:SetWaBao(click)
	self.wabao_click = click
end

function GuildBoxTips:SetLevelUp(click)
	self.level_click = click
end

function GuildBoxTips:LoadCallBack()
	self.node_list["ButtonCloseTips"].button:AddClickListener(BindTool.Bind(self.Close, self))
	if self.level_free_click then
		self.node_list["LevelUpFree"].button:AddClickListener(BindTool.Bind(self.level_free_click, self))
	end
	if self.wabao_click then
		self.node_list["ButtonTipsDig"].button:AddClickListener(BindTool.Bind(self.wabao_click, self))
	end
	if self.level_click then
		self.node_list["ButtonLevelUp"].button:AddClickListener(BindTool.Bind(self.level_click, self))
	end

	self.other_config = GuildData.Instance:GetOtherConfig()

	if self.other_config then
		local price = self.other_config.box_up_gold or 0
		self.node_list["Price"].text.text = price
	end
end

function GuildBoxTips:OpenCallBack()
	GuildCtrl.Instance:GuildFlushView("guild_box")
	GuildCtrl.Instance:SetOpenBoxTips(true)
end

function GuildBoxTips:OnFlush()
	local is_free, free_count, up_count = GuildData.Instance:GetBoxTipsData()
	if is_free then
		self.node_list["LevelUpText"]:SetActive(false)
		self.node_list["LevelUpFree"]:SetActive(true)
		self.node_list["ButtonLevelUp"]:SetActive(false)
		self.node_list["LevelUpCount2"]:SetActive(true)
	else
		self.node_list["LevelUpText"]:SetActive(true)
		self.node_list["LevelUpFree"]:SetActive(false)
		self.node_list["ButtonLevelUp"]:SetActive(true)
		self.node_list["LevelUpCount2"]:SetActive(false)
	end
	self.node_list["FreeCount"].text.text = free_count
	self.node_list["LevelUpCount2"].text.text = up_count
	self.node_list["BoxColor"].text.text = GuildData.Instance:GetBoxTipsColor()
end

function GuildBoxTips:CloseCallBack()
	GuildCtrl.Instance:SetOpenBoxTips(false)
end
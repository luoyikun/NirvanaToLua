TipsGuildTransferView = TipsGuildTransferView or BaseClass(BaseView)

function TipsGuildTransferView:__init()
	self.ui_config = {{"uis/views/guildview_prefab", "TipsTransferView"}}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.is_modal = true
	self.is_open_list = false
end

function TipsGuildTransferView:__delete()
end

-- 创建完调用
function TipsGuildTransferView:LoadCallBack()
	for i = 1, 5 do
		self.node_list["BtnTransfer" .. i].button:AddClickListener(function() self:ClickTransfer(i) end)
	end
	self.node_list["ButtonYes"].button:AddClickListener(BindTool.Bind(self.ClickOK, self))
	self.node_list["ButtonNo"].button:AddClickListener(BindTool.Bind(self.ClosenView, self))
	self.node_list["ClosenBtn"].button:AddClickListener(BindTool.Bind(self.ClosenView, self))
	self.node_list["BtnGet"].button:AddClickListener(BindTool.Bind(self.OpenList, self))
end

function TipsGuildTransferView:ReleaseCallBack()
end

function TipsGuildTransferView:OpenCallBack()
	self.select_post = 1
	self:OnClickChangePost()
end

function TipsGuildTransferView:OpenList()
	self.is_open_list = not self.is_open_list
	self.node_list["List"]:SetActive(self.is_open_list)
end

function TipsGuildTransferView:ClickTransfer(index)
	if index == 1 then
		self.select_post = 3
		self.node_list["PostName"].text.text = Language.Guild.FuMengZhu
	elseif index == 2 then
		self.select_post = 2
		self.node_list["PostName"].text.text = Language.Guild.ZhangLao
	elseif index == 3 then
		self.select_post = 6
		self.node_list["PostName"].text.text = Language.Guild.HuFa
	elseif index == 4 then
		self.select_post = 5
		self.node_list["PostName"].text.text = Language.Guild.JingYing
	elseif index == 5 then
		self.select_post = 1
		self.node_list["PostName"].text.text = Language.Guild.PuTong
	end
	self.is_open_list = false
	self.node_list["List"]:SetActive(self.is_open_list)
end

function TipsGuildTransferView:ClickOK()
	self:Close()
	GuildCtrl.Instance:SendGuildAppointReq(GuildDataConst.GUILDVO.guild_id, self.uid, self.select_post)
end

function TipsGuildTransferView:ClosenView()
	self:Close()
end

function TipsGuildTransferView:OnClickChangePost()
	local post = GuildData.Instance:GetGuildPost()
	if post == GuildDataConst.GUILD_POST.TUANGZHANG then
		self.node_list["BtnTransfer1"]:SetActive(true)
		self.node_list["BtnTransfer2"]:SetActive(true)
		self.node_list["BtnTransfer3"]:SetActive(true)
		self.node_list["BtnTransfer4"]:SetActive(true)
		self.node_list["BtnTransfer5"]:SetActive(true)
	elseif post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
		self.node_list["BtnTransfer1"]:SetActive(false)
		self.node_list["BtnTransfer2"]:SetActive(true)
		self.node_list["BtnTransfer3"]:SetActive(true)
		self.node_list["BtnTransfer4"]:SetActive(true)
		self.node_list["BtnTransfer5"]:SetActive(true)
	elseif post == GuildDataConst.GUILD_POST.ZHANG_LAO then
		self.node_list["BtnTransfer1"]:SetActive(false)
		self.node_list["BtnTransfer2"]:SetActive(false)
		self.node_list["BtnTransfer3"]:SetActive(true)
		self.node_list["BtnTransfer4"]:SetActive(true)
		self.node_list["BtnTransfer5"]:SetActive(true)
	else
		self.node_list["BtnTransfer1"]:SetActive(false)
		self.node_list["BtnTransfer2"]:SetActive(false)
		self.node_list["BtnTransfer3"]:SetActive(false)
		self.node_list["BtnTransfer4"]:SetActive(false)
		self.node_list["BtnTransfer5"]:SetActive(false)
	end
	self.node_list["Name"].text.text = self.role_name
	self.select_post = 1
	self.node_list["PostName"].text.text = Language.Guild.PuTong
end

function TipsGuildTransferView:SetData(uid,role_name)
	self.uid = uid or 0
	self.role_name = role_name or ""
end
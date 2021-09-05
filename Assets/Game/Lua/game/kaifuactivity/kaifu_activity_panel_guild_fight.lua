KfGuildFightView = KfGuildFightView or BaseClass(BaseRender)

function KfGuildFightView:__init()
	self.cell_list = {}
end

function KfGuildFightView:__delete()
end

function KfGuildFightView:OpenCallBack()
	local cfg = KaifuActivityData.Instance:GetKfGuildFightCfg()
	for i = 1, 4 do
		self.cell_list[i] = {}
		local data = cfg[i].reward_item
		for i1 = 1, 2 do
			self.cell_list[i][i1] = ItemCell.New()
			self.cell_list[i][i1]:SetInstanceParent(self.node_list["Item".. i .. "_".. i1])
			self.cell_list[i][i1]:SetData(data[i1 - 1])
		end
	end
	for i = 1, 4 do
		self.node_list["Btn" .. i].button:AddClickListener(BindTool.Bind(self.OnClickGet, self))
		UI:SetButtonEnabled(self.node_list["Btn" .. i], false)
	end
	local str = string.format(Language.OpenServer.GuildFTOpen, cfg[1].opengame_day) .. string.format(Language.OpenServer.GuildFTOpen1, TimeCtrl.Instance:GetCurOpenServerDay())
	RichTextUtil.ParseRichText(self.node_list["TxtTime"].rich_text, str)
	-- self.node_list["TxtTime"].text.text = ToColorStr(str, TEXT_COLOR.GREEN)
end

function KfGuildFightView:CloseCallBack()
	for _,v in ipairs(self.cell_list) do
		for _,v1 in ipairs(v) do
			v1:DeleteMe()
		end
	end
	self.cell_list = {}	
end

function KfGuildFightView:OnFlush()
	local info = KaifuActivityData.Instance:GetOpenGameActivityInfo()
	if not info then return end

	local index = info.oga_guild_battle_reward_type
	if index <= 0 then
		for i = 1, 4 do
			UI:SetButtonEnabled(self.node_list["Btn" .. i], false)
		end
	else
		if info.oga_guild_battle_reward_flag == 0 then
			UI:SetButtonEnabled(self.node_list["Btn" .. index], true)
		else
			self.node_list["TxtBtn" .. index].text.text = Language.Common.YiLingQu
			UI:SetButtonEnabled(self.node_list["Btn" .. index], false)
		end
	end
end
function KfGuildFightView:OnClickGet()
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GUILD_FIGHT, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_FETCH)
end
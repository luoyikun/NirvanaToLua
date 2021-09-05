GuildRedPacketTips = GuildRedPacketTips or BaseClass(BaseView)

function GuildRedPacketTips:__init()
	self.ui_config = {{"uis/views/guildview_prefab", "GuildHongBaoDetailView"}}
	self.red_pocket_num = 10
	self.is_modal = true
	self.is_any_click_close = true
end

function GuildRedPacketTips:__delete()

end

function GuildRedPacketTips:ReleaseCallBack()
	if next(self.cell_list) then
		for _,v in pairs(self.cell_list) do
			if v then
				v:DeleteMe()
			end
		end
		self.cell_list = {}
	end
	self.red_pocket_num = 10
	self.red_pocket_max_num = 0
end

function GuildRedPacketTips:LoadCallBack()

	self.node_list["RedCount"].text.text = self.red_pocket_num

	self.cell_list = {}
	local list_delegate = self.node_list["Panel4List"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.node_list["ButtonOk"].button:AddClickListener(BindTool.Bind(self.OnClickSend, self))
	self.node_list["ButtonConfirm"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["TextBg"].button:AddClickListener(BindTool.Bind(self.OnInputClickHandler, self))
	self.node_list["NextButton"].button:AddClickListener(BindTool.Bind(self.OnClickNext, self))
end


function GuildRedPacketTips:GetNumberOfCells()
	local fetch_info_list = GuildData.Instance:GetRedPocketDistributeInfo()
	return #fetch_info_list
end

function GuildRedPacketTips:RefreshCell(cell, data_index)
	local decs_item = self.cell_list[cell]
	if decs_item == nil then
		decs_item = RedPocketListItemRender.New(cell.gameObject)
		self.cell_list[cell] = decs_item
	end
	local fetch_info_list = GuildData.Instance:GetRedPocketDistributeInfo()
	decs_item:SetData(fetch_info_list[data_index + 1])
end

function GuildRedPacketTips:ShowIndexCallBack()
	self:Flush()
end

function GuildRedPacketTips:OnFlush()
	local info = GuildData.Instance:GetSaveRedPocketInfo()
	if nil ~= info then
		local cfg = GuildData.Instance:GetRedPocketListDesc(info.red_paper_seq)
		self.red_pocket_max_num = cfg.bind_gold
		if info.status == GUILD_RED_POCKET_STATUS.DISTRIBUTED or info.status == GUILD_RED_POCKET_STATUS.DISTRIBUTE_OUT then --显示列表
			self.node_list["Panle2"]:SetActive(false)
			self.node_list["Panle4"]:SetActive(true)
			self.node_list["FrontName"].text.text = string.format(Language.RedEnvelopes.HuoDe, info.owner_role_name)
			
			AvatarManager.Instance:SetAvatarKey(info.owner_role_id, info.avatar_key_big, info.avatar_key_small)
			AvatarManager.Instance:SetAvatar(info.owner_role_id, self.node_list["raw_image_obj"], self.node_list["image_obj"], info.sex, info.prof, false)

			self.node_list["Panel4List"].scroller:ReloadData(0)
			local own_red = GuildData.Instance:GetOwnRedPocket()
			if own_red then
				self.node_list["FrontName"]:SetActive(true)
				self.node_list["MoneyText"]:SetActive(true)
				self.node_list["TextGold"]:SetActive(true)
				self.node_list["TextDesc"]:SetActive(false)
				self.node_list["MoneyText"].text.text = own_red.gold_num
			else
				self.node_list["FrontName"]:SetActive(false)
				self.node_list["MoneyText"]:SetActive(false)
				self.node_list["TextGold"]:SetActive(false)
				self.node_list["TextDesc"]:SetActive(true)
			end 
			local next_id = GuildData.Instance:GetNextRedId()
			if next_id ~= -1 then
				self.node_list["ButtonConfirm"]:SetActive(false)
				self.node_list["NextButton"]:SetActive(true)
			else
				self.node_list["ButtonConfirm"]:SetActive(true)
				self.node_list["NextButton"]:SetActive(false)
			end

		else
			self.node_list["Panle2"]:SetActive(true)
			self.node_list["Panle4"]:SetActive(false)
			self.node_list["MyGold"].text.text = self.red_pocket_max_num
		end
	end
end

function GuildRedPacketTips:OnInputClickHandler()
	local guildvo = GuildDataConst.GUILDVO
	local red_num = math.min(self.red_pocket_max_num, guildvo.max_member_count)
	TipsCtrl.Instance:OpenCommonInputView(0, BindTool.Bind(self.CountValueChange, self), nil, red_num)
end

function GuildRedPacketTips:CountValueChange(str)
	if str == "" then
		return
	end
	local num = tonumber(str)
	if num < 10 then num = 10 end
	self.red_pocket_num = num
	self.node_list["RedCount"].text.text = self.red_pocket_num
end

function GuildRedPacketTips:OnClickSend()
	local info = GuildData.Instance:GetSaveRedPocketInfo()
	if info and next(info) then
		GuildCtrl.Instance:SendCreateGuildRedPaperReq(info.red_paper_seq, self.red_pocket_num, info.red_paper_index)
		self:Close()
	end
end

function GuildRedPacketTips:OnClickNext()
	local next_id = GuildData.Instance:GetNextRedId()
	HongBaoCtrl.Instance:SendRedPaperFetchReq(next_id)
	HongBaoCtrl.Instance:SendRedPaperQueryDetailReq(next_id)
end

function GuildRedPacketTips:OnClickClose()
	self:Close()
end

-----------------------------------------------------------
RedPocketListItemRender = RedPocketListItemRender or BaseClass(BaseCell)

function RedPocketListItemRender:__init()

end

function RedPocketListItemRender:__delete()

end

function RedPocketListItemRender:OnFlush()
	if not self.data then return end
	self.node_list["Name"].text.text = self.data.name
	self.node_list["Score"].text.text = self.data.gold_num .. Language.RedEnvelopes.moneyBang
	local zuijia_id = GuildData.Instance:GetRedPocketZuiJia()
	self.node_list["Icon"]:SetActive(zuijia_id == self.data.uid)
end
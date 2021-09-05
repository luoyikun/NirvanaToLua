HongBaoKoulingView = HongBaoKoulingView or BaseClass(BaseView)

function HongBaoKoulingView:__init()
	self.ui_config = {{"uis/views/tips/hongbaotips_prefab", "PasswordHongBaoDetailView"}}
	self.play_audio = true
	self.data = nil
	self.is_open_view = false
	self.data_list = {}
	self.is_modal = true
end

function HongBaoKoulingView:__delete()

end

function HongBaoKoulingView:ReleaseCallBack()
	if next(self.cell_list) then
		for _,v in pairs(self.cell_list) do
			if v then
				v:DeleteMe()
			end
		end
		self.cell_list = {}
	end
	self.red_pocket_list = nil
end

function HongBaoKoulingView:LoadCallBack()

	self.cell_list = {}
	self.red_pocket_list = self.node_list["PanelList"]
	local list_delegate = self.red_pocket_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.node_list["BtnOpen"].button:AddClickListener(BindTool.Bind(self.OnClickSend, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
end


function HongBaoKoulingView:GetNumberOfCells()
	return #self.data_list
end

function HongBaoKoulingView:RefreshCell(cell, data_index)
	local decs_item = self.cell_list[cell]
	if decs_item == nil then
		decs_item = RedPocketListItemRender.New(cell.gameObject)
		self.cell_list[cell] = decs_item
	end
	local fetch_info_list = self.data_list
	decs_item:SetData(fetch_info_list[data_index + 1])
end

function HongBaoKoulingView:ShowIndexCallBack()

end

function HongBaoKoulingView:OpenCallBack()
	self.data = HongBaoData.Instance:GetKoulingRedPaperInfo()
	self:Flush()
end


function HongBaoKoulingView:OnFlush(param_t)
	if nil == self.data then
		return
	end
	for k,v in pairs(param_t) do
		if k == "all" then
			self.node_list["TxtFromtName"]:SetActive(true)
			self.node_list["TxtNotGetHongBao"]:SetActive(false)
			self.node_list["TxtName"]:SetActive(true)
			self.node_list["TxtYuanBao"]:SetActive(true)
			self.node_list["TxtMoneyText"]:SetActive(true)
			self.node_list["TxtName"].text.text = string.format(Language.ActHongBao.KouLing, self.data.creater_name)
			self.node_list["TxtFromtName"].text.text = string.format(Language.ActHongBao.GetKouLing, self.data.creater_name)
			self.node_list["TxtKouLing"].text.text = self.data.kouling_msg
			self.node_list["NodeOpen"]:SetActive(true)
			self.node_list["NodeResult"]:SetActive(false)
			local cfg = ConfigManager.Instance:GetAutoConfig("commandspeaker_auto").other[1]
			self.node_list["TxtMoneyText"].text.text = cfg.reward_role_limit * cfg.bind_gold_num
			AvatarManager.Instance:SetAvatarKey(self.data.creater_uid, self.data.avatar_key_big, self.data.avatar_key_small)
			AvatarManager.Instance:SetAvatar(self.data.creater_uid, self.node_list["raw_image_obj"], self.node_list["image_obj"], self.data.sex, self.data.prof, false)
		elseif k == "detail" then
			self.is_open_view = true
			self.node_list["NodeOpen"]:SetActive(false)
			self.node_list["NodeResult"]:SetActive(true)

			local info = HongBaoData.Instance:GetOneKoulingRedPaper(self.data.id)
			if info then
				self.data_list = info.log_list
				local has_mine = false
				local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
			    for k,v in pairs(self.data_list) do
			        if role_id == v.uid then
			            has_mine = true
			            self.node_list["TxtMoneyText"].text.text = v.gold_num
			        end
			    end
			    self.node_list["TxtFromtName"]:SetActive(has_mine)
			    self.node_list["TxtNotGetHongBao"]:SetActive(not has_mine)
			    self.node_list["TxtName"]:SetActive(has_mine)
			    self.node_list["TxtYuanBao"]:SetActive(has_mine)
			    self.node_list["TxtMoneyText"]:SetActive(has_mine)

			end
		end
	end
end


function HongBaoKoulingView:OnClickSend()
	if nil == self.data then return end
	HongBaoCtrl.Instance:SendFetchCommandRedPaper(self.data.id)
end

function HongBaoKoulingView:OnClickClose()
	self:Close()
end

function HongBaoKoulingView:CloseCallBack()
	if self.data then
		HongBaoData.Instance:RemoveKoulingRedPaper(self.data.id)
	end
	self.data = nil
	self.is_open_view = false
	self.data_list = {}
end

-----------------------------------------------------------
RedPocketListItemRender = RedPocketListItemRender or BaseClass(BaseCell)

function RedPocketListItemRender:__init()

end

function RedPocketListItemRender:__delete()

end

function RedPocketListItemRender:OnFlush()
	if not self.data then return end
	self.node_list["TxtName"].text.text = self.data.name
	self.node_list["TxtScore"].text.text = self.data.gold_num
	local zuijia_id = GuildData.Instance:GetRedPocketZuiJia()
	self.node_list["ImgLuck"]:SetActive(zuijia_id == self.data.uid) 
end
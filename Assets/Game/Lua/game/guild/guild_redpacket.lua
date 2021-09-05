GuildRedPacketView = GuildRedPacketView or BaseClass(BaseView)
local COLUMN = 3
function GuildRedPacketView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel"},
		{"uis/views/guildview_prefab", "GuildRedPackerView"}
	}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

-- 仙盟红包
function GuildRedPacketView:LoadCallBack()
	self.jilu_cell_list = {}

	local list_delegate = self.node_list["JiLuList"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfJiLuCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshJiLuCell, self)

	self.red_pocket_cell_list = {}

	local list_delegate = self.node_list["RedPacketList"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.node_list["ButtonHelp"].button:AddClickListener(BindTool.Bind(self.OnClickRedPocketTips, self))
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.OnClickCloseHandler, self))
	self.node_list["TitleText"].text.text = Language.Title.XiangMengHongBao
end

function GuildRedPacketView:OpenCallBack()
	GuildCtrl.Instance:SendGuildRedPocketOperate()
end

function GuildRedPacketView:GetNumberOfJiLuCells()
	local red_pocket_info = GuildData.Instance:GetRedPocketListInfo()
	return #red_pocket_info
end

function GuildRedPacketView:RefreshJiLuCell(cell, data_index)
	local record_item = self.jilu_cell_list[cell]
	if record_item == nil then
		record_item = RedPocketJiLuItemRender.New(cell.gameObject)
		self.jilu_cell_list[cell] = record_item
	end
	local red_pocket_info = GuildData.Instance:GetJiluList()
	record_item:SetData(red_pocket_info[data_index + 1])
end

function GuildRedPacketView:GetNumberOfCells()
	local new_data = GuildData.Instance:GetRedPocketListInfoPrune()
	return math.ceil(#new_data/COLUMN)
end

function GuildRedPacketView:RefreshCell(cell, data_index)
	local group_cell = self.red_pocket_cell_list[cell]
	if not group_cell then
		group_cell = RedPacketGroupCell.New(cell.gameObject)
		self.red_pocket_cell_list[cell] = group_cell
	end

	local new_data = GuildData.Instance:GetRedPocketListInfoPrune()
	for i = 1, COLUMN do
		local index = (data_index)*COLUMN + i
		local data = new_data[index]
		group_cell:SetActive(i, data ~= nil)
		group_cell:SetData(i, data)
		group_cell:SetClickCallBack(i, BindTool.Bind(self.ItemCellClick, self))
	end
end

function GuildRedPacketView:ItemCellClick(cell)
	local data = cell:GetData()
	if not data or not next(data) then
		return
	end
	GuildData.Instance:SetSaveRedPocketInfo(data)
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	if data.status == GUILD_RED_POCKET_STATUS.UN_DISTRIBUTED and role_id ~= data.owner_role_id then
		GuildCtrl.Instance:SendChatRedPaperReq(data.red_paper_index)
	
		return
	elseif data.status == GUILD_RED_POCKET_STATUS.DISTRIBUTED then    -- 获取红包
		if data.is_fetch < 1 then
			HongBaoCtrl.Instance:SendRedPaperFetchReq(data.id)
		end
		HongBaoCtrl.Instance:SendRedPaperQueryDetailReq(data.id)
	elseif data.status == GUILD_RED_POCKET_STATUS.DISTRIBUTE_OUT then   -- 查看红包状态
		HongBaoCtrl.Instance:SendRedPaperQueryDetailReq(data.id)
	end
	GuildCtrl.Instance:OpenGuildRedPacketView()
end

function GuildRedPacketView:ReleaseCallBack()

	for k,v in pairs(self.red_pocket_cell_list) do
		if v then
			v:DeleteMe()
			v = nil
		end
	end
	self.red_pocket_cell_list = {}
	for k,v in pairs(self.jilu_cell_list) do
		if v then
			v:DeleteMe()
			v = nil
		end
	end
	self.jilu_cell_list = {}
end

function GuildRedPacketView:OnFlush()
	self.node_list["JiLuList"].scroller:ReloadData(0)
	
	self.node_list["RedPacketList"].scroller:RefreshActiveCellViews()
end

function GuildRedPacketView:OnClickCloseHandler()
	self:Close()
end

function GuildRedPacketView:OnClickRedPocketTips()
	TipsCtrl.Instance:ShowHelpTipView(180)
end

-------------------RedPacketGroupCell-----------------------
RedPacketGroupCell = RedPacketGroupCell or BaseClass(BaseCell)
function RedPacketGroupCell:__init()
	self.item_list = {}
	for i = 1, COLUMN do
		local bag_item = RedPocketGridItemRender.New(self.node_list["Item" .. i])
		table.insert(self.item_list, bag_item)
	end
end

function RedPacketGroupCell:__delete()
	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function RedPacketGroupCell:SetActive(i, state)
	self.item_list[i]:SetActive(state)
end

function RedPacketGroupCell:SetData(i, data)
	self.item_list[i]:SetData(data)
end

function RedPacketGroupCell:SetClickCallBack(i, callback)
	self.item_list[i]:SetClickCallBack(callback)
end


--RedPocketGridItemRender
----------------------------------------------------------------------------
RedPocketGridItemRender = RedPocketGridItemRender or BaseClass(BaseCell)
function RedPocketGridItemRender:__init()

	self.node_list["BagItem"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
	
end

function RedPocketGridItemRender:__delete()
	
end

function RedPocketGridItemRender:OnFlush()
	if not self.data or not next(self.data) then return end

	self.node_list["name"].text.text = self.data.owner_role_name
	AvatarManager.Instance:SetAvatarKey(self.data.owner_role_id, self.data.avatar_key_big, self.data.avatar_key_small)
	
	AvatarManager.Instance:SetAvatar(self.data.owner_role_id, self.node_list["RawImage"], self.node_list["RoleImage"], self.data.sex, self.data.prof, false)

	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local red_pocket_cfg = GuildData.Instance:GetRedPocketListDesc(self.data.red_paper_seq)
	if red_pocket_cfg then
		self.node_list["Desc"].text.text = red_pocket_cfg.descript
	end

	self.node_list["Desc11"]:SetActive(false)
	self.node_list["Desc12"]:SetActive(false)
	self.node_list["Desc1"].text.text = ""
	if self.data.status == GUILD_RED_POCKET_STATUS.UN_DISTRIBUTED and role_id ~= self.data.owner_role_id then -- 别人未发放

		self.node_list["Image"].image:LoadSprite(ResPath.GetGuildImg("img_red_nosend"))

		self.node_list["Desc1"].text.text = Language.Guild.GuildHongBaoTip
		self.node_list["Desc12"]:SetActive(true)
	elseif self.data.status == GUILD_RED_POCKET_STATUS.UN_DISTRIBUTED and role_id == self.data.owner_role_id then
	-- 自己发
		self.node_list["Image"].image:LoadSprite(ResPath.GetGuildImg("img_red_send"))
		-- 发红包啦！
		self.node_list["Desc1"].text.text = Language.Guild.GuildHongBaoTip2
	elseif self.data.status == GUILD_RED_POCKET_STATUS.DISTRIBUTED and self.data.is_fetch == 0 then --领取

		self.node_list["Image"].image:LoadSprite(ResPath.GetGuildImg("img_red_open"))
		-- 金额随机，试试手气
		self.node_list["Desc1"].text.text = Language.Guild.GuildHongBaoTip3
	elseif self.data.is_fetch > 0 then  --已领取

		self.node_list["Image"].image:LoadSprite(ResPath.GetGuildImg("img_red_sendout"))
		-- 查看其他人手气
		self.node_list["Desc1"].text.text = Language.Guild.GuildHongBaoTip4

		self.node_list["Desc11"]:SetActive(true)
	elseif self.data.status == GUILD_RED_POCKET_STATUS.DISTRIBUTE_OUT then--已抢的红包
		--
		self.node_list["Image"].image:LoadSprite(ResPath.GetGuildImg("img_red_noopen"))
		-- 查看其他人手气
		self.node_list["Desc1"].text.text = Language.Guild.GuildHongBaoTip4

		self.node_list["Desc11"]:SetActive(true)
	end

	if self.data.status == GUILD_RED_POCKET_STATUS.UN_DISTRIBUTED and role_id == self.data.owner_role_id then

	end
end

--RedPocketJiLuItemRender
----------------------------------------------------------------------------
RedPocketJiLuItemRender = RedPocketJiLuItemRender or BaseClass(BaseCell)
function RedPocketJiLuItemRender:__init()

end

function RedPocketJiLuItemRender:__delete()

end

function RedPocketJiLuItemRender:OnFlush()
	if not self.data then return end

	local history_params = os.date("*t", self.data.create_timestamp - 86400)
	mount = string.format(Language.Common.XXMXXD, history_params.month, history_params.day)
	day = string.format(Language.Common.XXHXXM, history_params.hour, history_params.min)

	local time = "【" .. mount.. day .. "】"
	local red_pocket_cfg = GuildData.Instance:GetRedPocketListDesc(self.data.red_paper_seq)
	if red_pocket_cfg then
		local red_desc = string.format(Language.Guild.RenPocketListTips, time, self.data.owner_role_name, red_pocket_cfg.name, red_pocket_cfg.bind_gold)
		self.node_list["open_condition"].text.text = red_desc
	end
end
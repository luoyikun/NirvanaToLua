TipsGuildEnemyView = TipsGuildEnemyView or BaseClass(BaseView)

function TipsGuildEnemyView:__init()
	self.ui_config = {{"uis/views/chatview_prefab", "GuildEnemyView"}}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.scroller_data = {}
	self.is_modal = true
	self.is_any_click_close = true
end

function TipsGuildEnemyView:__delete()
end

function TipsGuildEnemyView:ReleaseCallBack()
	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}
end

function TipsGuildEnemyView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))

		-- 生成滚动条
	self.cell_list = {}
	self.scroller_data = {}
	self.scroller_data = ChatData.Instance:GetGuildEnemyList()
	local scroller_delegate = self.node_list["GuildEnemyList"].list_simple_delegate

	--生成数量
	scroller_delegate.NumberOfCellsDel = function()
		return #self.scroller_data or 0
	end

	--刷新函数
	scroller_delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local enemy_cell = self.cell_list[cell]
		if enemy_cell == nil then
			enemy_cell = ScrollerGuildEnemyCell.New(cell.gameObject)
			self.cell_list[cell] = enemy_cell
		end

		enemy_cell:SetIndex(data_index)
		enemy_cell:SetData(self.scroller_data[data_index])
	end
end

function TipsGuildEnemyView:OpenCallBack()
	ChatCtrl.Instance:SendGuildEnemyRankList()
end

function TipsGuildEnemyView:OnFlush()
	self.scroller_data = ChatData.Instance:GetGuildEnemyList()
	self.node_list["GuildEnemyList"].scroller:RefreshAndReloadActiveCellViews(true)
end

function TipsGuildEnemyView:CloseWindow()
	self:Close()
end

----------------------------------------------------------------------------
--ScrollerEnemyCell 		帮派仇人滚动条格子
----------------------------------------------------------------------------

ScrollerGuildEnemyCell = ScrollerGuildEnemyCell or BaseClass(BaseCell)

function ScrollerGuildEnemyCell:__init()
	self.avatar_key = 0
	self.node_list["Btn"].button:AddClickListener(BindTool.Bind(self.ClickItem, self))


end

function ScrollerGuildEnemyCell:__delete()

end

function ScrollerGuildEnemyCell:OnFlush()
	if nil == self.data then return end

	self.node_list["Rank"].text.text = self.index
	self.node_list["NameTxt"].text.text = self.data.enemy_name
	self.node_list["num"].text.text = self.data.kill_score

	if self.index <= 3 and self.node_list["RankImage"] then
		self.node_list["RankImage"]:SetActive(true)
		local bundle, asset = ResPath.GetChatRes("rank_" .. self.index)
		self.node_list["RankImage"].image:LoadSpriteAsync(bundle,asset, function()
			self.node_list["RankImage"].image:SetNativeSize()
		end)
	else
		self.node_list["RankImage"]:SetActive(false)
	end
end

function ScrollerGuildEnemyCell:ClickItem()
	local main_role = Scene.Instance.main_role
	local msg = ""
	if nil ~= main_role then
		local x, y = main_role:GetLogicPos()
		if AStarFindWay:IsBlock(x, y) then
			SysMsgCtrl.Instance:ErrorRemind(Language.Chat.PositionInValid)
			return
		end
		local scene_key = PlayerData.Instance:GetAttr("scene_key") or 0
		local open_line = PlayerData.Instance:GetAttr("open_line") or 0
		-- 如果此场景不能分线
		if open_line <= 0 then
			scene_key = -1
		end
		--直接发出去
		local scene_id = Scene.Instance:GetSceneId()
		msg = "{point;" ..  Scene.Instance:GetSceneName() .. ";" .. x .. ";" .. y .. ";" .. scene_id .. ";" .. scene_key .. "}"
	end
	if msg == "" then
		return
	end
	
	ChatCtrl.SendChannelChat(CHANNEL_TYPE.GUILD, string.format(Language.Guild.GuildEnemyPos, msg, self.data.enemy_name), CHAT_CONTENT_TYPE.TEXT)
	ChatCtrl.Instance:CloseGuildEnemyView()
end
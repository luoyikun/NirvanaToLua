ScoietyFriendView = ScoietyFriendView or BaseClass(BaseRender)
function ScoietyFriendView:__init()
	self.node_list["BtnAdd"].button:AddClickListener(BindTool.Bind(self.ClickAddFriend, self))
	self.node_list["FriendLotAdd"].button:AddClickListener(BindTool.Bind(self.ClickLotAdd, self))
	self.node_list["BtnLotDel"].button:AddClickListener(BindTool.Bind(self.ClickLotDel, self))
	self.node_list["FriendList"].button:AddClickListener(BindTool.Bind(self.ClickEmpty, self))
	self.node_list["ButtonQuery"].button:AddClickListener(BindTool.Bind(self.ClickQuery, self))

	self.node_list["InputText"].input_field.text = ""

		-- 生成滚动条
	self.cell_list = {}
	self.scroller_data = {}
	local scroller_delegate = self.node_list["FriendList"].list_simple_delegate

	--生成数量
	scroller_delegate.NumberOfCellsDel = function()
		return #self.scroller_data or 0
	end
	--刷新函数
	scroller_delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1

		local friend_cell = self.cell_list[cell]

		if friend_cell == nil then
			friend_cell = ScrollerFriendCell.New(cell.gameObject)
			friend_cell.root_node.toggle.group = self.node_list["FriendList"].toggle_group
			friend_cell.friend_view = self
			friend_cell:SetClickCallBack(BindTool.Bind(self.GiftOnClick, self))
			self.cell_list[cell] = friend_cell
		end

		friend_cell:SetIndex(data_index)

		friend_cell:SetData(self.scroller_data[data_index])

	end

	self.node_list["FriendList"].scroller.scrollerScrollingChanged = function ()
		ScoietyCtrl.Instance:CloseOperaList()
	end

	--引导用按钮
	-- --引导用按钮
end

function ScoietyFriendView:__delete()
	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}
end

function ScoietyFriendView:GiftOnClick(cell)
	if nil == cell then
		return
	end

	--查看后送礼红点消失
	if RemindManager.Instance:GetRemind(RemindName.ScoietyOtherFriend) > 0 and not ScoietyData.Instance:GetIsCheckGift() then
		ScoietyData.Instance:SetIsCheckGift(true)
		RemindManager.Instance:Fire(RemindName.ScoietyOtherFriend)
	end

	local data = cell:GetData()
	data.user_name = data.gamename
	FlowersCtrl.Instance:SetFriendInfo(data)
	ViewManager.Instance:Open(ViewName.Flowers)

	for _, v in pairs(self.cell_list) do
		v:SetRedPoint(false)
	end
end

function ScoietyFriendView:CloseFriendView()
	self.select_index = nil
end


--打开收礼记录面板
function ScoietyFriendView:OpenGiftRecord()
	ScoietyCtrl.Instance:ShowFriendRecordView()
end

function ScoietyFriendView:ClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(4)
end

function ScoietyFriendView:ClickAddFriend()
	TipsCtrl.Instance:ShowAddFriendView()
end
-- 批量添加
function ScoietyFriendView:ClickLotAdd()
	self.node_list["RedPoint"]:SetActive(false)
	ScoietyData.Instance:SetShowOneKeyRemind(false)
	RemindManager.Instance:Fire(RemindName.ScoietyOneKeyFriend)
	ScoietyCtrl.Instance:ShowFriendRecView()
end
-- 批量删除
function ScoietyFriendView:ClickLotDel()
	ScoietyCtrl.Instance:ShowDeleteView()
end
-- 黑名单
function ScoietyFriendView:ClickBlackList()
	ScoietyCtrl.Instance:ShowBlackListView()
end

function ScoietyFriendView:ClickEmpty()
	ScoietyCtrl.Instance:CloseOperaList()
end

function ScoietyFriendView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function ScoietyFriendView:GetSelectIndex()
	return self.select_index or 0
end

function ScoietyFriendView:FlushFriendView()
	if RemindManager.Instance:GetRemind(RemindName.ScoietyOneKeyFriend) > 0 then
		self.node_list["RedPoint"]:SetActive(true)
	else
		self.node_list["RedPoint"]:SetActive(false)
	end

	self.scroller_data = ScoietyData.Instance:GetFriendInfo()
	self.node_list["FriendList"].scroller:RefreshAndReloadActiveCellViews(true)
end

function ScoietyFriendView:ClickQuery()
	local text = self.node_list["InputText"].input_field.text
	if text == "" then
		self.scroller_data = ScoietyData.Instance:GetFriendInfo()
		self.node_list["FriendList"].scroller:RefreshAndReloadActiveCellViews(true)
	else
		self.scroller_data = ScoietyData.Instance:GetFriendInfoByFindName(text)
		self.node_list["FriendList"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

----------------------------------------------------------------------------
--ScrollerFriendCell 		好友滚动条格子
----------------------------------------------------------------------------

ScrollerFriendCell = ScrollerFriendCell or BaseClass(BaseCell)

function ScrollerFriendCell:__init()
	self.avatar_key = 0
	self.node_list["FriendItem"].toggle:AddClickListener(BindTool.Bind(self.ClickItem, self))
	self.node_list["SendFlower"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
	self.node_list["Btnhaogandu"].button:AddClickListener(BindTool.Bind(self.OnClickHaoGanDu, self))
	self.node_list["BtnGuildOpen"].button:AddClickListener(BindTool.Bind(self.OnClickHaoGanDuTxt, self))
	self.gift_animator = self.root_node:GetComponent(typeof(UnityEngine.Animator))
	self.is_show = false

end

function ScrollerFriendCell:__delete()
	self.is_show = false
end

function ScrollerFriendCell:SetRedPoint(state)
	self.node_list["Remind"]:SetActive(state)
end

function ScrollerFriendCell:OnClickHaoGanDu()
	 if self.is_show == false then
	 	 self.is_show = true
		 self.node_list["HaoGanDuOpenTips"]:SetActive(self.is_show)
	else
		self.is_show = false
		 self.node_list["HaoGanDuOpenTips"]:SetActive(self.is_show)
	end
end
function ScrollerFriendCell:OnClickHaoGanDuTxt()
	if self.is_show == true then
		 self.is_show = false
		 self.node_list["HaoGanDuOpenTips"]:SetActive(self.is_show)
	end
end

function ScrollerFriendCell:LoadUserCallBack(user_id, path)
	if self:IsNil() then
		return
	end

	if user_id ~= self.data.user_id then
		self.node_list["IconImage"]:SetActive(true)
		self.node_list["RawImage"]:SetActive(false)
		return
	end

	if path == nil then
		path = AvatarManager.GetFilePath(user_id, false)
	end
	self.node_list["IconImage"]:SetActive(false)
	self.node_list["RawImage"]:SetActive(true)
	--GlobalTimerQuest:AddDelayTimer(function()
		self.node_list["RawImage"].raw_image:LoadSprite(path, function ()
				end)
	--end, 0)
end

function ScrollerFriendCell:OnFlush()
	if not self.data or not next(self.data) then return end

	if self.data.is_online == 1 and RemindManager.Instance:GetRemind(RemindName.ScoietyOtherFriend) > 0 then
		self.node_list["Remind"]:SetActive(true)
	else
		self.node_list["Remind"]:SetActive(false)
	end
	self.node_list["NameTxt"].text.text = self.data.gamename

	AvatarManager.Instance:SetAvatar(self.data.user_id, self.node_list["RawImage"], self.node_list["IconImage"], self.data.sex, self.data.prof, false)

	-- local lv, zhuan = PlayerData.GetLevelAndRebirth(self.data.level)
	-- local level_des = string.format(Language.Common.LevelFormat, lv, zhuan)
	self.node_list["LevelTxt"].text.text = PlayerData.GetLevelString(self.data.level)
	self.node_list["ProfTxt"].text.text = PlayerData.GetProfNameByType(self.data.prof, self.data.is_online ~= 1)
	self.node_list["ZhanLiTxt"].text.text = self.data.capability

	local intimacy_list = ScoietyData.Instance:GetIntimacyCfg()
	local intimacy_lev = 0
	for k, v in ipairs(intimacy_list) do
		if self.data.intimacy >= v.need_intimacy then
			intimacy_lev = v.level
		end
	end
	self.node_list["IntimacyTxt"].text.text = self.data.intimacy
	self.node_list["IntimacyLevTxt"].text.text = string.format("Lv.%s", intimacy_lev)

	--好感度
	local good_opinion = ScoietyData.Instance:GetFriendGoodOpinion(self.data.user_id)
	local level, favorable_impression_show, need_favorable_impression,next_level = ScoietyData.Instance:GetFriendHaoGanDu(good_opinion)
	local star_num = ScoietyData.Instance:GetFriendStarNum(level)
	for i = 1, 3 do
		local bundle, asset = ResPath.GetscoietyView("img_haodandu".. favorable_impression_show)
		local bundle1, asset1 =  ResPath.GetscoietyView("img_prohaogandu".. favorable_impression_show)
		self.node_list["GoodfeelImage" .. i].image:LoadSprite(bundle, asset, function()
					self.node_list["GoodfeelImage" .. i].image:SetNativeSize()
				end)
		self.node_list["pro_fill" .. i].image:LoadSprite(bundle1, asset1, function()
					-- self.node_list["pro_fill" .. i].image:SetNativeSize()
				end)
	end
	self.node_list["TxtHaoGanDu"].text.text = string.format(Language.Society.HaoGanDuTip, good_opinion,next_level)
	if star_num == 1 then
		self.node_list["GoodSlider1"].slider.value = ((good_opinion - need_favorable_impression) / (next_level - need_favorable_impression))
		self.node_list["GoodSlider2"].slider.value = 0
		self.node_list["GoodSlider3"].slider.value = 0
	elseif star_num == 2  then
		self.node_list["GoodSlider1"].slider.value = 1
		self.node_list["GoodSlider2"].slider.value = ((good_opinion - need_favorable_impression )/(next_level- need_favorable_impression))
		self.node_list["GoodSlider3"].slider.value = 0
	elseif star_num ==  3 then
		self.node_list["GoodSlider1"].slider.value = 1
		self.node_list["GoodSlider2"].slider.value = 1
		self.node_list["GoodSlider3"].slider.value = ((good_opinion - need_favorable_impression )/(next_level- need_favorable_impression))
	elseif star_num == 4 then
		self.node_list["GoodSlider1"].slider.value = 1
		self.node_list["GoodSlider2"].slider.value = 1
		self.node_list["GoodSlider3"].slider.value = 1
	end

	if self.data.is_online ~= 1 then
		UI:SetGraphicGrey(self.node_list["IconImage"], true)
		UI:SetGraphicGrey(self.node_list["RawImage"], true)
		UI:SetGraphicGrey(self.node_list["NameTxt"], true)
		UI:SetGraphicGrey(self.node_list["ProfTxt"], true)
		UI:SetGraphicGrey(self.node_list["LevelTxt"], true)
		UI:SetGraphicGrey(self.node_list["ZhanLiTxt"], true)
		UI:SetGraphicGrey(self.node_list["IntimacyLevTxt"], true)
		UI:SetGraphicGrey(self.node_list["IntimacyTxt"], true)
		UI:SetButtonEnabled(self.node_list["SendFlower"], false)
	else
		UI:SetGraphicGrey(self.node_list["IconImage"], false)
		UI:SetGraphicGrey(self.node_list["RawImage"], false)
		UI:SetGraphicGrey(self.node_list["NameTxt"], false)
		UI:SetGraphicGrey(self.node_list["ProfTxt"], false)
		UI:SetGraphicGrey(self.node_list["LevelTxt"], false)
		UI:SetGraphicGrey(self.node_list["ZhanLiTxt"], false)
		UI:SetGraphicGrey(self.node_list["IntimacyLevTxt"], false)
		UI:SetGraphicGrey(self.node_list["IntimacyTxt"], false)
		UI:SetButtonEnabled(self.node_list["SendFlower"], true)
	end
	-- 刷新选中特效
	local select_index = self.friend_view:GetSelectIndex()
	if self.root_node.toggle.isOn and select_index ~= self.index then
		self.root_node.toggle.isOn = false
	elseif self.root_node.toggle.isOn == false and select_index == self.index then
		self.root_node.toggle.isOn = true
	end
end

function ScrollerFriendCell:ClickItem()
	self.root_node.toggle.isOn = true
	self.friend_view:SetSelectIndex(self.index)

	local function canel_callback()
		self.friend_view:SetSelectIndex(0)
		if self.root_node then
			self.root_node.toggle.isOn = false
		end
	end

	local click_obj = self.friend_view.scroller
	ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.Default, self.data.gamename, click_obj, canel_callback)
end
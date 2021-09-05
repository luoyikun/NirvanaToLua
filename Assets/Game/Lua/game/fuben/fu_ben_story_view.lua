FuBenStoryView = FuBenStoryView or BaseClass(BaseRender)

function FuBenStoryView:__init(instance)

	self.node_list["ListView"].scroll_rect.onValueChanged:AddListener(BindTool.Bind(self.OnValueChanged, self))
	self.node_list["SaodangBtn"].button:AddClickListener(BindTool.Bind(self.OnClickClean, self))
	self.node_list["LeftButton"].button:AddClickListener(BindTool.Bind(self.OnClickLeftButton, self))
	self.node_list["RightButton"].button:AddClickListener(BindTool.Bind(self.OnClickRightButton, self))

	self.item_cells = {}
	self.item_cells[1] = ItemCell.New()
	self.item_cells[1]:SetInstanceParent(self.node_list["Item1"])
	self.item_cells[2] = ItemCell.New()
	self.item_cells[2]:SetInstanceParent(self.node_list["Item2"])
	self.item_cells[3] = ItemCell.New()
	self.item_cells[3]:SetInstanceParent(self.node_list["Item3"])

	self.cur_index = nil
	self.list = {}
	self.cur_page = 1
end

function FuBenStoryView:__delete()
	for k, v in pairs(self.list) do
		if v then
			v:DeleteMe()
		end
	end
	self.list = {}
	self.cur_index = nil
	self.cur_page = nil

	for k, v in pairs(self.item_cells) do
		v:DeleteMe()
	end
	self.item_cells = {}
end

function FuBenStoryView:OnValueChanged(normalizedPosition)
	local page = self.node_list["ListView"].page_view.ActiveCellsMiddleIndex + 1
	if self.cur_page ~= page then
		self.cur_page = page
		self:SetLeftAndRightButtonState(self.cur_page)
	end
end

function FuBenStoryView:GetNumberOfCells()
	return FuBenData.Instance:MaxStoryFB() / 3
end

function FuBenStoryView:RefreshStoryCell(data_index, cell)
	local fuben_list = self.list[cell]
	if fuben_list == nil then
		fuben_list = StoryFuBenListView.New(cell.gameObject)
		self.list[cell] = fuben_list
	end
	local fuben_cfg = FuBenData.Instance:GetStoryFBLevelCfg()
	local fuben_info = FuBenData.Instance:GetStoryFBInfo()

	self.cur_page = math.floor(self.node_list["ListView"].scroll_rect.normalizedPosition.x / (1 / FuBenData.Instance:MaxStoryFB() * 3)) + 1
	if self.cur_page > 0 then
		self.cur_page = self.cur_page > 4 and 4 or self.cur_page
	else
		self.cur_page = 1
	end
	self:SetLeftAndRightButtonState(self.cur_page)
	fuben_list:SetIndex(data_index + 1)
	if next(fuben_info) and fuben_cfg then
		for i = 1, 3 do
			local story_index = data_index * 3 + i
			local data = {}
			fuben_list:ListenClick(i, BindTool.Bind(self.OnClickChallenge, self, story_index - 1))
			local scene_config = ConfigManager.Instance:GetSceneConfig(fuben_cfg[story_index].scene_id)
			data.fb_name = scene_config and scene_config.name
			data.open_level = fuben_cfg[story_index].role_level
			data.is_show_btn = fuben_cfg[story_index].role_level <= PlayerData.Instance:GetRoleLevel()
			data.is_first = 1 ~= fuben_info[story_index - 1].is_pass
			data.btn_text = 1 ~= fuben_info[story_index - 1].is_pass and "挑战" or "扫荡"
			data.show_red_point = ((fuben_cfg[story_index].free_times - fuben_info[story_index - 1].today_times) > 0)
			data.storyindex = story_index
			fuben_list:SetData(i, data)
			for n = 0, 2 do
				local item_data = {}
				if fuben_info[story_index - 1].is_pass == 0 then
					item_data = fuben_cfg[story_index].first_reward[n]
				else
					if fuben_cfg[story_index].normal_reward[n] then
						item_data = fuben_cfg[story_index].normal_reward[n]
					else
						item_data.item_id = FuBenDataExpItemId.ItemId
					end
				end
				fuben_list:SetItemCellData(i, n + 1, item_data)
			end
		end
	end
end

function FuBenStoryView:OnClickClean()

	FuBenCtrl.Instance:SendAutoFBReq(GameEnum.FB_CHECK_TYPE.FBCT_STORY_FB, -1)
end

function FuBenStoryView:OnClickLeftButton()
	if self.cur_page <= 1 then return end
	self.cur_page = self.cur_page - 1
	self.node_list["ListView"].page_view:JumpToIndex(self.cur_page - 1, 0, 1)
	self:SetLeftAndRightButtonState(self.cur_page)
end

function FuBenStoryView:OnClickRightButton()
	if self.cur_page >= (FuBenData.Instance:MaxStoryFB() / 3) then return end
	self.cur_page = self.cur_page + 1
	self.node_list["ListView"].page_view:JumpToIndex(self.cur_page - 1, 0, 1)
	self:SetLeftAndRightButtonState(self.cur_page)
end

function FuBenStoryView:SetLeftAndRightButtonState(cur_page)
	self.node_list["LeftButton"]:SetActive(cur_page > 1)
	self.node_list["RightButton"]:SetActive(cur_page < (FuBenData.Instance:MaxStoryFB() / 3))
	local page_cfg = FuBenData.Instance:GetStoryFBPageCfg()[cur_page]
	self.node_list["TextCurPage" ].text.text = page_cfg and page_cfg.section_name or ""
	for k, v in pairs(self.item_cells) do
		v:SetData((page_cfg and page_cfg.reset_reward[k - 1]) and page_cfg.reset_reward[k - 1] or {})
	end
end

function FuBenStoryView:OnClickChallenge(data_index)
	local fuben_info = FuBenData.Instance:GetStoryFBInfo()
	if fuben_info[data_index] and fuben_info[data_index].today_times >= 1 then
		return
	end
	if fuben_info[data_index].is_pass == 1 then
		FuBenCtrl.Instance:SendAutoFBReq(GameEnum.FB_CHECK_TYPE.FBCT_STORY_FB, data_index)
		return
	end
	local pass_count = -1
	for k, v in pairs(fuben_info) do
		if v.is_pass == 1 or v.today_times >= 1 then
			pass_count = k
		end
	end
	if data_index - pass_count > 1 then
		TipsCtrl.Instance:ShowSystemMsg(Language.FB.CanNotChallegeCurLevel)
		return
	end
	self.cur_index = data_index
	PlayerPrefsUtil.SetInt("storyindex", data_index + 1)
	FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_STORY_FB, data_index)
	ViewManager.Instance:Close(ViewName.FuBen)
end

function FuBenStoryView:FlushView()
	self.node_list["ListView"].page_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.node_list["ListView"].page_simple_delegate.CellRefreshDel = BindTool.Bind(self.RefreshStoryCell, self)
	if self.node_list["ListView"] and self.node_list["ListView"].page_view.isActiveAndEnabled then
		self.node_list["ListView"].page_view:Reload()
		local fuben_info = FuBenData.Instance:GetStoryFBInfo()
		local fuben_cfg = FuBenData.Instance:GetStoryFBLevelCfg()
		local index = -1
		local page = -1
		local had_pass = false
		for k, v in pairs(fuben_info) do
			if v.is_pass == 1 and v.today_times == 0 then
				index = k
			end
			if v.today_times == 0 then
				if page <= -1 then
					page = k
				end
			end
			if v.is_pass == 1 then
				had_pass = true
			end
		end
		page = math.floor(page / 3) <= 3 and math.floor(page / 3) or 3
		self:SetLeftAndRightButtonState(page)
		self.cur_page = page
		local str = Language.FB.NoAutoTimes
		if fuben_cfg and (index >= 0) then
			local scene_config = ConfigManager.Instance:GetSceneConfig(fuben_cfg[index + 1].scene_id)
			str = string.format(Language.FB.AutoLevelText, scene_config and scene_config.name or "")
		end
		self.node_list["Des" ].text.text = str
		UI:SetButtonEnabled(self.node_list["SaodangBtn" ], index >= 0)
		self.node_list["ImageArrow"]:SetActive(index >= 0)
		self.node_list["TextOneKey" ].text.text = (index >= 0 or not had_pass) and Language.Common.OneKeySaoDang or Language.Common.HadSaoDang
		local func = function()
			self.node_list["ListView"].page_view:JumpToIndex(page)
		end
		GlobalTimerQuest:AddDelayTimer(func, 0.1)
	end
end

function FuBenStoryView:JumpToIndex()
	self.node_list["ListView"].page_view:JumpToIndex(self.cur_index)
end

function FuBenStoryView:OnClickItem(index, item_data)
	TipsCtrl.Instance:OpenItem(item_data, nil, nil)
end


-- 生成的列表
StoryFuBenListView = StoryFuBenListView or BaseClass(BaseRender)

function StoryFuBenListView:__init(instance)
	--引导需要用到的按钮
	self.one_challenge = self.node_list["OneChallenge"]

	self.item_cells_one = {}
	self.item_cells_one[1] = ItemCell.New()
	self.item_cells_one[1]:SetInstanceParent(self.node_list["Item11"])
	self.item_cells_one[2] = ItemCell.New()
	self.item_cells_one[2]:SetInstanceParent(self.node_list["Item12"])
	self.item_cells_one[3] = ItemCell.New()
	self.item_cells_one[3]:SetInstanceParent(self.node_list["Item13"])


	self.item_cells_two = {}
	self.item_cells_two[1] = ItemCell.New()
	self.item_cells_two[1]:SetInstanceParent(self.node_list["Item21"])
	self.item_cells_two[2] = ItemCell.New()
	self.item_cells_two[2]:SetInstanceParent(self.node_list["Item22"])
	self.item_cells_two[3] = ItemCell.New()
	self.item_cells_two[3]:SetInstanceParent(self.node_list["Item23"])

	self.item_cells_three = {}
	self.item_cells_three[1] = ItemCell.New()
	self.item_cells_three[1]:SetInstanceParent(self.node_list["Item31"])
	self.item_cells_three[2] = ItemCell.New()
	self.item_cells_three[2]:SetInstanceParent(self.node_list["Item32"])
	self.item_cells_three[3] = ItemCell.New()
	self.item_cells_three[3]:SetInstanceParent(self.node_list["Item33"])
end

function StoryFuBenListView:__delete()
	for k, v in pairs(self.item_cells_one) do
		v:DeleteMe()
	end
	self.item_cells_one = {}

	for k, v in pairs(self.item_cells_two) do
		v:DeleteMe()
	end
	self.item_cells_two = {}

	for k, v in pairs(self.item_cells_three) do
		v:DeleteMe()
	end
	self.item_cells_three = {}
end

function StoryFuBenListView:SetIndex(index)
	self.index = index
end

function StoryFuBenListView:GetIndex()
	return self.index or 0
end

function StoryFuBenListView:ListenClick(i, handler)
	--self:ClearEvent("OnClickChallenge"..i)
	self.node_list["ShowChallenge" .. i].toggle:AddClickListener(BindTool.Bind(self.OnClickChallenge, self))

end

function StoryFuBenListView:SetItemCellData(story_index, i, data)
	if 1 == story_index then
		self.item_cells_one[i]:SetData(data)
	end
	if 2 == story_index then
		self.item_cells_two[i]:SetData(data)
	end
	if 3 == story_index then
		self.item_cells_three[i]:SetData(data)
	end
end

function StoryFuBenListView:SetData(story_index, data)
	if not story_index or not data then return end
	self.node_list["TextFbName" .. story_index].text.text = data.fb_name
	-- local level_befor = math.floor(data.open_level % 100) ~= 0 and math.floor(data.open_level % 100) or 100
	-- local level_behind = math.floor(data.open_level % 100) ~= 0 and math.floor(data.open_level / 100) or math.floor(data.open_level / 100) - 1
	-- local level_zhuan = string.format(Language.Common.Zhuan_Level, level_befor, level_behind)
	self.node_list["OpenLevel" .. story_index].text.text = PlayerData.GetLevelString(data.open_level)
	self.node_list["ShowChallenge" .. story_index]:SetActive(data.is_show_btn and data.show_red_point)
	self.node_list["ShowButton" .. story_index]:SetActive(data.is_show_btn and data.show_red_point)
	self.node_list["First" .. story_index]:SetActive(data.is_first)
	self.node_list["NoFirst" .. story_index]:SetActive(not data.is_first)
	self.node_list["ButtonText" .. story_index].text.text = data.btn_text
	self.node_list["Lock" .. story_index]:SetActive(not data.is_show_btn )
	local bundle, asset = ResPath.GetStoryFubenRawImage(data.storyindex)
	self.node_list["RawImgStory" .. story_index].raw_image:LoadSprite(bundle, asset)
	self.node_list["HadChallenge" .. story_index]:SetActive(not data.show_red_point)
end

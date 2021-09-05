MolongMibaoChapterView = MolongMibaoChapterView or BaseClass(BaseRender)

local CUR_ITEM_ID = 0
local first_reward = 0
local second_reward = 1
function MolongMibaoChapterView:__init()
	self.chapter_id = 0
	self.reward_items = {}
	for i = 1, 2 do
		local reward_item = ItemCell.New()
		reward_item:SetInstanceParent(self.node_list["Item" .. i])
		reward_item:IsDestoryActivityEffect(false)
		reward_item:SetActivityEffect()
		self.reward_items[i] = reward_item
	end

	self.tab_list = {}
	self:InitScrollerTab()
	self.cell_list = {}
	self.disply_cell_list = {}
	self:InitScroller()
	self:ChangeScroller()

	self.node_list["RechargeBtn"].button:AddClickListener(BindTool.Bind(self.OnClickRewardButton, self))
end

function MolongMibaoChapterView:__delete()
	if self.reward_items then
		for k,v in pairs(self.reward_items) do
			v:DeleteMe()
		end
		self.reward_items = {}
	end
	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = {}
	end	
	if self.disply_cell_list then
		for k,v in pairs(self.disply_cell_list) do
			v:DeleteMe()
		end
		self.disply_cell_list = {}
	end
	if self.tab_list then
		for k,v in pairs(self.tab_list) do
			v:DeleteMe()
		end
		self.tab_list = {}
	end
	CUR_ITEM_ID = 0
end

function MolongMibaoChapterView:ScrollerScrolledDelegate(go, param1, param2, param3)
	if not self.is_scroll_create then
		if self.is_cell_active and self.node_list["TabView"] and self.node_list["TabView"].scroller.isActiveAndEnabled then
			self.is_scroll_create = true
			if self.is_cell_active and self.is_scroll_create and self.is_first_jump ~= false and self.node_list["TabView"] and self.node_list["TabView"].scroller.isActiveAndEnabled then
				self.node_list["TabView"].scroller:JumpToDataIndex(self:GetJumpIndex(self.chapter_id))
				self.is_first_jump = false
			end				
		end
	end
end

function MolongMibaoChapterView:InitScrollerTab()
	local delegate = self.node_list["TabView"].list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		local cur_chapter = MolongMibaoData.Instance:GetCurChapter()
		if cur_chapter < 7 then
			-- 第7天前只显示前7天的数据
			return 7
		else
			-- 第8天后把前7天已领取的标签干掉，然后把8-14的加载出来
			return MolongMibaoData.Chapter - self:GetHasRewardNum()
		end
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local target_cell = self.tab_list[cell]

		if nil == target_cell then
			self.tab_list[cell] =  MolongMibaoTabCell.New(cell.gameObject)
			target_cell = self.tab_list[cell]
			target_cell:SetToggleGroup(self.node_list["TabView"].toggle_group)
			target_cell.mother_view = self
		end
		local cur_chapter = MolongMibaoData.Instance:GetCurChapter()
		if cur_chapter < 7 then
			-- 第7天前只显示前7天的数据
			target_cell:SetData(data_index)
		else
			-- 第8天后把前7天已领取的标签干掉，然后把8-14的加载出来
			target_cell:SetData(self:GetRealTable(data_index))
		end
		self.is_cell_active = true
	end
	self.node_list["TabView"].scroller.scrollerScrolled = BindTool.Bind(self.ScrollerScrolledDelegate, self)
	self.node_list["TabView"].scroller:ReloadData(0)
end

-- 前7天领完的数量
function MolongMibaoChapterView:GetHasRewardNum()
	local has_reward_num = 0
	for i = 0, 6 do
		if MolongMibaoData.Instance:GetMibaoBigChapterHasReward(i) then
			has_reward_num = has_reward_num + 1
		end
	end
	return has_reward_num
end

function MolongMibaoChapterView:GetRealTable(index)
	local original_list = {}
	local original_length = MolongMibaoData.Chapter
	for i = 1, original_length do
		original_list[i] = i
	end
	for i = #original_list, 1, -1 do
		if MolongMibaoData.Instance:GetMibaoBigChapterHasReward(original_list[i] - 1) then
			if i >= 1 and i <= 7 then
				table.remove(original_list, i)
			end
		end
	end
	return original_list[index] or index
end

function MolongMibaoChapterView:GetJumpIndex(chapter_id)
	local original_list = {}
	local real_list = {}
	local original_length = MolongMibaoData.Chapter
	local real_length = MolongMibaoData.Chapter - self:GetHasRewardNum()
	for i = 1, original_length do
		original_list[i] = i
	end
	for i = #original_list, 1, -1 do
		if MolongMibaoData.Instance:GetMibaoBigChapterHasReward(original_list[i] - 1) then
			if i >= 1 and i <= 7 then
				table.remove(original_list, i)
			end
		end
	end

	for i = #original_list, 1, -1 do
		if original_list[i] and chapter_id == original_list[i] - 1 then
			if i - 1 >= 0 and i - 1 <= 13 then
				return i - 1
			end
		end
	end
	return chapter_id - 1
end

function MolongMibaoChapterView:InitScroller()
	self.data = MolongMibaoData.Instance:GetMibaoChapterDataList(self.chapter_id) or {}
	local delegate = self.node_list["ListView"].list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		return #self.data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local target_cell = self.cell_list[cell]

		if nil == target_cell then
			self.cell_list[cell] =  MolongMibaoChapterCell.New(cell.gameObject)
			target_cell = self.cell_list[cell]
			target_cell.mother_view = self
			target_cell.node_list["NameBg"].toggle.group = self.node_list["ListView"].toggle_group
		end
		local cell_data = self.data[data_index]
		target_cell:SetData(cell_data)
	end
end

function MolongMibaoChapterView:OnClickRewardButton()
	local cur_jifen = MolongMibaoData.Instance:GetMibaoBigChapterScore(self.chapter_id) or 0
	local one_max_score = MolongMibaoData.Instance:GetMibaoFinishChapterLevelScore(self.chapter_id, 0)
	local two_max_score = MolongMibaoData.Instance:GetMibaoFinishChapterLevelScore(self.chapter_id, 1)
	local title_name =  MolongMibaoData.Instance:GetMibaoChapterTitleName(self.chapter_id)
	if cur_jifen >= one_max_score and cur_jifen < two_max_score then
		-- print_error(self.chapter_id)
		-- local ok_fun = function ()
		-- 	MolongMibaoCtrl.SendMagicalPreciousChapterRewardReq(self.chapter_id, first_reward)
		-- end
		MolongMibaoCtrl.Instance:Setid(self.chapter_id)
		ViewManager.Instance:Open(ViewName.MolongMibaoTips)
		-- local cancelfunc = function ()
		-- 	TipsCtrl.Instance:CloseCommonAutoView()
		-- end
		-- local des = string.format(Language.MoLongMiBao.LingQuDes, two_max_score, title_name) 
		-- local ok_des = Language.MoLongMiBao.LingQu
		-- local no_des = Language.MoLongMiBao.ChongCi
		-- TipsCtrl.Instance:ShowCommonAutoView("", des, nil, cancelfunc, nil, no_des, ok_des, nil, nil, nil, ok_fun)
	else
		MolongMibaoCtrl.SendMagicalPreciousChapterRewardReq(self.chapter_id, second_reward)
	end
	
end


function MolongMibaoChapterView:CloseFire()
	local num = 0
	for i = 0, MolongMibaoData.Chapter - 1 do
		if i > MolongMibaoData.Instance:GetCurChapter() or MolongMibaoData.Instance:GetMibaoChapterFinish(i) then
		
		else
			local data = MolongMibaoData.Instance:GetMibaoChapterDataList(i) or {}
			for k, v in pairs(data) do
				if v.reward_index then
					local state = MolongMibaoData.Instance:GetMibaoChapterRewardState(i, v.reward_index)
					if state == RewardFlag.CanReward then
						local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
						if cur_day > -1 then
							local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
							PlayerPrefsUtil.SetInt(i .. v.reward_index .. "ChapterIDRewardIndex" .. main_role_id, cur_day)
							num = num + 1
						end				
					end
				end
			end
			local cur_jifen = MolongMibaoData.Instance:GetMibaoBigChapterScore(i) or 0
			local has_reward = MolongMibaoData.Instance:GetMibaoBigChapterHasReward(i)
			local one_max_score = MolongMibaoData.Instance:GetMibaoFinishChapterLevelScore(i, 0)
			if cur_jifen >= one_max_score then
				if not has_reward then
					local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
					if cur_day > -1 then
						local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
						PlayerPrefsUtil.SetInt(i .. "ChapterID" .. main_role_id, cur_day)
						num = num + 1
					end
				end
			end
		end				
	end
	if num > 0 then
		RemindManager.Instance:Fire(RemindName.MoLongMiBao)
	end
end

function MolongMibaoChapterView:OpenCallBack()
	-- 仙女获取那边跳转过来要显示第一天
	local day_index = MolongMibaoData.Instance:GetShowDay()
	if day_index ~= -1 then
		self:ChapterChange(day_index)
		MolongMibaoData.Instance:SetShowDay(-1)
		return
	end

	local cur_chapter = MolongMibaoData.Instance:GetCurChapter()
	for i = MolongMibaoData.Chapter, 1, -1 do
		if i <= cur_chapter + 1 and not MolongMibaoData.Instance:GetMibaoBigChapterHasReward(i - 1) then
			self:ChapterChange(i)
			return
		end
	end

	local cur_chapter = MolongMibaoData.Instance:GetCurChapter()
	if cur_chapter < 7 then
		self:ChapterChange(1)
	else
		self:ChapterChange(8)
	end
end

function MolongMibaoChapterView:ChapterChange(index)
	self.chapter_id = index - 1
	local cur_chapter = MolongMibaoData.Instance:GetCurChapter()
	local is_open = cur_chapter >= self.chapter_id
	self.node_list["List"]:SetActive(is_open)
	self.node_list["LockTips"]:SetActive(not is_open)
	local finish_reward = MolongMibaoData.Instance:GetMibaoFinishChapterReward(self.chapter_id) or {}

	for k,v in pairs(self.reward_items) do
		if finish_reward[k] then
			v:SetData(finish_reward[k])
		end
		v.root_node:SetActive(finish_reward[k] ~= nil)
	end

	self:Flush()
end

function MolongMibaoChapterView:ChangeScroller()
	self.model_cfg = MolongMibaoData.Instance:GetMibaoFinishChapterModelCfg(self.chapter_id) or {}
	local delegate = self.node_list["DisplayListView"].list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		return 2
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local target_cell = self.disply_cell_list[cell]
		if nil == target_cell then
			self.disply_cell_list[cell] = MolongMibaoDisPlayCell.New(cell.gameObject)
			target_cell = self.disply_cell_list[cell]
			target_cell:SetIndex(self.chapter_id)
		end
		local cell_data = self.model_cfg[data_index]
		target_cell:SetData(cell_data)
	end
end

function MolongMibaoChapterView:OnFlush()
	self.data = MolongMibaoData.Instance:GetMibaoChapterDataList(self.chapter_id) or {}
	if self.node_list["ListView"].scroller.isActiveAndEnabled then
		self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
	end
	if self.node_list["TabView"].scroller.isActiveAndEnabled then
		--self.node_list["TabView"].scroller:RefreshActiveCellViews()
		self.node_list["TabView"].scroller:RefreshAndReloadActiveCellViews(true)
		if self.is_cell_active and self.is_scroll_create and self.is_first_jump ~= false and self.node_list["TabView"] and self.node_list["TabView"].scroller.isActiveAndEnabled then
			self.node_list["TabView"].scroller:JumpToDataIndex(self:GetJumpIndex(self.chapter_id))
			self.is_first_jump = false
		end		
	end
	self.model_cfg = MolongMibaoData.Instance:GetMibaoFinishChapterModelCfg(self.chapter_id) or {}

	self.node_list["DisplayListView"].scroller:RefreshActiveCellViews()
	self.node_list["ListView"].scroller:ReloadData(0)

	local cur_jifen = MolongMibaoData.Instance:GetMibaoBigChapterScore(self.chapter_id) or 0
	local has_reward = MolongMibaoData.Instance:GetMibaoBigChapterHasReward(self.chapter_id)
	local one_max_score = MolongMibaoData.Instance:GetMibaoFinishChapterLevelScore(self.chapter_id, 0)
	local two_max_score = MolongMibaoData.Instance:GetMibaoFinishChapterLevelScore(self.chapter_id, 1)
	local is_show_info = MolongMibaoData.Instance:GetShowScore()
	local cur_chapter = MolongMibaoData.Instance:GetCurChapter()
	if is_show_info and self.chapter_id > cur_chapter then
		UI:SetButtonEnabled(self.node_list["RechargeBtn"], false)
		self.node_list["BtnEffect"]:SetActive(false)
		self.node_list["NumText1"].text.text = 0
		self.node_list["NumText2"].text.text = string.format(Language.Exchange.Expend, 0, one_max_score)
		self.node_list["NumText3"].text.text = string.format(Language.Exchange.Expend, 0, two_max_score)
		self.node_list["ValueSlider"].slider.value = 0
	else
		if cur_jifen >= one_max_score then
			UI:SetButtonEnabled(self.node_list["RechargeBtn"], not has_reward)
			self.node_list["BtnEffect"]:SetActive(not has_reward)
		else
			UI:SetButtonEnabled(self.node_list["RechargeBtn"], false)
			self.node_list["BtnEffect"]:SetActive(false)
		end
		local cur_jifen_one = cur_jifen >= one_max_score and ToColorStr(one_max_score, TEXT_COLOR.GREEN) or ToColorStr(cur_jifen, TEXT_COLOR.RED)
		local cur_jifen_two = cur_jifen >= two_max_score and ToColorStr(two_max_score, TEXT_COLOR.GREEN) or ToColorStr(cur_jifen, TEXT_COLOR.RED)
		self.node_list["NumText1"].text.text = cur_jifen
		self.node_list["NumText2"].text.text = string.format(Language.Exchange.Expend, cur_jifen_one, one_max_score)
		self.node_list["NumText3"].text.text = string.format(Language.Exchange.Expend, cur_jifen_two, two_max_score)
		self.node_list["ValueSlider"].slider.value = cur_jifen / two_max_score
	end
	if has_reward then
		self.node_list["RechargeBtnTxt"].text.text = Language.Common.YiLingQu
	else
		self.node_list["RechargeBtnTxt"].text.text = Language.Common.LingQuJiangLi
	end
	
	self.node_list["Effect"]:SetActive(cur_jifen >= one_max_score and (not has_reward))
	self.node_list["Effect2"]:SetActive(cur_jifen >= two_max_score and (not has_reward))
end


---------------------------------------------------------------
--滚动条格子

MolongMibaoTabCell = MolongMibaoTabCell or BaseClass(BaseCell)

function MolongMibaoTabCell:__init()
	self.node_list["MolongTab"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function MolongMibaoTabCell:__delete()
	self.mother_view = nil
end

function MolongMibaoTabCell:OnFlush()
	self.root_node.toggle.isOn = self.data == self.mother_view.chapter_id + 1
	local cur_chapter = MolongMibaoData.Instance:GetCurChapter()
	self.node_list["Lock"]:SetActive(self.data > cur_chapter + 1)
	MolongMibaoData.Instance:SetShowScore(self.data > cur_chapter + 1)
	self.node_list["RedPoint"]:SetActive(MolongMibaoData.Instance:GetMibaoChapterRemind(self.data - 1) > 0)
	self.node_list["Finish"]:SetActive(MolongMibaoData.Instance:GetMibaoBigChapterHasReward(self.data - 1))
	self.node_list["LightText"].text.text = string.format(Language.MoLongMiBao.TabName, CommonDataManager.GetDaXie(self.data))
	self.node_list["Text"].text.text = string.format(Language.MoLongMiBao.TabName, CommonDataManager.GetDaXie(self.data))
end

function MolongMibaoTabCell:OnClick()
	self.mother_view:ChapterChange(self.data or 1)
	self.mother_view.node_list["PageToggle1"].toggle.isOn = true
end

function MolongMibaoTabCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

---------------------------------------------------------------
--滚动条格子

MolongMibaoChapterCell = MolongMibaoChapterCell or BaseClass(BaseCell)

function MolongMibaoChapterCell:__init()
	self.node_list["ButtonOpenTeam"].button:AddClickListener(BindTool.Bind(self.ClickReward, self))
end

function MolongMibaoChapterCell:__delete()
	self.mother_view = nil
end

function MolongMibaoChapterCell:ClickReward()
	if self.data == nil then return end
	local state = MolongMibaoData.Instance:GetMibaoChapterRewardState(self.data.chapter_id, self.data.reward_index)
	if state == nil then
		return  
	end
	if state < RewardFlag.CanReward then
		self:ClickGoto()
	else
		MolongMibaoCtrl.SendMagicalPreciousRewardReq(self.data.reward_index, self.data.chapter_id)
	end
end

function MolongMibaoChapterCell:ClickGoto()
	if self.data == nil then return end
	if self.data.open_panel == "jingyantask" then
		local task_id = TaskData.Instance:GetRandomTaskIdByType(TASK_TYPE.RI)
		if task_id == nil or task_id == 0 then
			TipsCtrl.Instance:ShowSystemMsg(Language.MoLongMiBao.NotDailyTask)
			return
		end
		TaskCtrl.Instance:DoTask(task_id)

	elseif self.data.open_panel == "guildtask" then
		local task_id = TaskData.Instance:GetRandomTaskIdByType(TASK_TYPE.GUILD)
		if task_id == nil or task_id == 0 then
			if PlayerData.Instance.role_vo.guild_id > 0 then
				TipsCtrl.Instance:ShowSystemMsg(Language.MoLongMiBao.NotGuildTask)
			else
				ViewManager.Instance:Open(ViewName.Guild)
			end
			return
		end
		TaskCtrl.Instance:DoTask(task_id)
	end
	if self.data.open_panel == "YewaiGuajiView" then
		local guaiwuIndex = YewaiGuajiData.Instance:GetGuaiwuIndex()
		local guaji_pos = YewaiGuajiData.Instance:GetGuajiPos(guaiwuIndex)
		YewaiGuajiCtrl.Instance:GoGuaji(guaji_pos[1],guaji_pos[2],guaji_pos[3])
	elseif self.data.open_panel == "ArenaActivityView" then
		ViewManager.Instance:OpenByCfg(self.data.open_panel)
	elseif self.data.open_panel == "ShenShou#shenshou_shengqi" then
		local role_vo = GameVoManager.Instance:GetMainRoleVo()
		local open_level = OpenFunData.Instance:GetOpenLevel("shenshou_shengqi")
		if open_level > role_vo.level then
			local str = string.format(Language.Common.FunOpenRoleLevelLimit, open_level)
			SysMsgCtrl.Instance:ErrorRemind(str)
		else
			ViewManager.Instance:OpenByCfg(self.data.open_panel)
		end		
	else
		ViewManager.Instance:OpenByCfg(self.data.open_panel)
	end
	
	ViewManager.Instance:Close(ViewName.MolongMibaoView)
end

function MolongMibaoChapterCell:OnFlush()
	self:OnFlushView()
end

function MolongMibaoChapterCell:RewardItem()
	local reward_item = {}
	for k,v in pairs(self.data.client_reward) do
		local cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if cfg and (cfg.limit_prof == 5 or cfg.limit_prof == PlayerData.Instance.role_vo.prof) then
			table.insert(reward_item, v)
		end
	end
	return reward_item
end

function MolongMibaoChapterCell:OnFlushView()
	local state = MolongMibaoData.Instance:GetMibaoChapterRewardState(self.data.chapter_id, self.data.reward_index)
	local t = Split(self.data.icon_show, ",")
	local bundle = t[1]
	local asset = t[2]

	self.node_list["TaskImg"].image:LoadSprite(bundle, asset, function ()
		self.node_list["TaskImg"].image:SetNativeSize()
	end)

	self.node_list["ButtonOpenTeam"].image:LoadSprite("uis/images_atlas", "btn_short_blue", function()
		self.node_list["ButtonOpenTeam"]:SetActive(true)
		self.node_list["qw"]:SetActive(true)
		self.node_list["lq"]:SetActive(false)
	end)	
	self.node_list["Image"]:SetActive(false)
	self.node_list["Effect"]:SetActive(false)
	if state == RewardFlag.CanReward then
		self.node_list["ButtonOpenTeam"].image:LoadSprite("uis/images_atlas", "btn_short_yellow", function()
			self.node_list["ButtonOpenTeam"]:SetActive(true)
			self.node_list["qw"]:SetActive(false)
			self.node_list["lq"]:SetActive(true)
		end)			
		self.node_list["Image"]:SetActive(false)
		self.node_list["Effect"]:SetActive(true)
	elseif state == RewardFlag.HasReward then
		self.node_list["qw"]:SetActive(false)
		self.node_list["lq"]:SetActive(false)
		self.node_list["ButtonOpenTeam"]:SetActive(false)
		self.node_list["Image"]:SetActive(true)
	end

	self.node_list["Dec"].text.text = self.data.desc
	self.node_list["NumText"].text.text = self.data.get_score
	self.node_list["Name"].text.text = self.data.target_name
end

-- 模型展示
MolongMibaoDisPlayCell = MolongMibaoDisPlayCell or BaseClass(BaseCell)

function MolongMibaoDisPlayCell:__init()
	self.item_id = 0
	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["Count"])
end

function MolongMibaoDisPlayCell:__delete()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	self.fight_text = nil
	self.item_id = nil
	TitleData.Instance:ReleaseTitleEff(self.node_list["TitleShow"])
end

function MolongMibaoDisPlayCell:OnFlush()
	if self.data == nil then return end
	if self.data and self.data.item_id then
		self.node_list["ChapterName"].text.text = MolongMibaoData.Instance:GetMibaoChapterName(self.data.c_id)
		CUR_ITEM_ID = self.data.item_id
		self.node_list["NameNode"]:SetActive(true)
		if self.item_id ~= self.data.item_id then
			self.item_id = self.data.item_id
			--ItemData.ChangeModel(self.model, CUR_ITEM_ID)
			self.model:ClearFoot()
			self.model:SetInteger(ANIMATOR_PARAM.STATUS, 0)			
			self.model:ChangeModelByItemId(self.data.item_id)
			self.model:SetScale(Vector3(1, 1, 1))
			local cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
			if cfg and next(cfg) then
				if cfg.is_display_role == DISPLAY_TYPE.WEIYAN then
					self.model:SetScale(Vector3(0.8, 0.8, 0.8))
					local transform = {position = Vector3(0, 1.9, 8), rotation = Quaternion.Euler(0, -179, 0)}
					self.model:SetCameraSetting(transform)
				elseif cfg.is_display_role == DISPLAY_TYPE.LINGQI then
					local transform = {position = Vector3(0, 1.9, 8), rotation = Quaternion.Euler(0, -177, 0)}
					self.model:SetCameraSetting(transform)
				end
			end
		end
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = ItemData.GetFightPower(CUR_ITEM_ID)
		end
	end
	
	if self.data.title then
		local title_id_cfg = TitleData.Instance:GetTitleCfg(self.data.title)
		local Capability = CommonDataManager.GetCapabilityCalculation(title_id_cfg)
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = Capability
		end
		local bundle, name = ResPath.GetTitleIcon(self.data.title)
		self.node_list["TitleShow"].image:LoadSprite(bundle, name)
		self.node_list["NameNode"]:SetActive(false)
		TitleData.Instance:LoadTitleEff(self.node_list["TitleShow"], self.data.title, true)
	end

	self.node_list["Display"]:SetActive(self.data.item_id and self.data.item_id > 0)
	self.node_list["TitleShow"]:SetActive(self.data.title ~= nil)
	self.node_list["ChapterName"]:SetActive(self.data.item_id and self.data.item_id > 0)
end

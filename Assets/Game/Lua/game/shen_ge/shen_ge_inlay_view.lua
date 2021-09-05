ShenGeInlayView = ShenGeInlayView or BaseClass(BaseRender)

local MAX_BAG_GRID_NUM = 200 --总共个数
local COLUMN_NUM = 4	--列数
local ROW_NUM = 5		--行数
local BAG_PAGE_COUNT = 20 	 --每页个数
local MOVE_TIME = 0.6
local MAX_NUM = 2
SHENGE_PAGE = {
	INLAY = 1,
	LEVEL = 2,
}
local FenJieTiShiCount = 20		-- 星辉大于20提示红点
local MaxLevel = 100			-- 星辉最大等级100
function ShenGeInlayView:UIsMove()
	UITween.MoveShowPanel(self.node_list["DownMove"] , Vector3(62 , 600 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["Right1"] , Vector3(0 , 300 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["Right2"] , Vector3(550 , 0 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["Right"] , Vector3(350 , -25 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["TopBtn"] , Vector3(-178 , 80 , 0 ) , MOVE_TIME )
	--UITween.MoveShowPanel(self.node_list["MiddleCenter"] , Vector3(0 , -50 , 0 ) , 0.4 )
	UITween.AlpahShowPanel(self.node_list["MiddleCenter"] , true , MOVE_TIME , DG.Tweening.Ease.InExpo)
	--UITween.ScaleShowPanel(self.node_list["Inlay"] ,Vector3(0.7 , 0.7 , 0.7 ) , 0.4 )
	UITween.AlpahShowPanel(self.node_list["NodeGoal"], true, 0.5 , DG.Tweening.Ease.InExpo)

	self:Flush()
end

function ShenGeInlayView:__init(instance)
	self.cell_list = {}
	self.goal_data = {}
	self.is_auto_level = false
	if self.is_auto_level then 
		self.node_list["OnKeyTxt"].text.text = Language.ShenGe.QuXiaoZhuLing
	else
		self.node_list["OnKeyTxt"].text.text = Language.ShenGe.ZiDongZhuLing
	end
	self.node_list["BtnCompose"].button:AddClickListener(BindTool.Bind(self.OnClickCompose, self))
	self.node_list["BtnPreview"].button:AddClickListener(BindTool.Bind(self.OnClickPreview, self))
	self.node_list["BtnStart"].button:AddClickListener(BindTool.Bind(self.OnClickClean, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["BtnOverView"].button:AddClickListener(BindTool.Bind(self.OpenOverView, self))
	self.node_list["BtnFenJie"].button:AddClickListener(BindTool.Bind(self.OnClickFenJie, self))
	self.node_list["ButtonUp"].button:AddClickListener(BindTool.Bind(self.OnClickUp, self))
	self.node_list["ButtonOneKey"].button:AddClickListener(BindTool.Bind(self.OnClickUpOneKey, self))
	self.node_list["ToggleTotalInlay"].toggle.onValueChanged:AddListener(BindTool.Bind(self.OnToggleChange, self , SHENGE_PAGE.INLAY))
	self.node_list["ToggleUpLevel"].toggle.onValueChanged:AddListener(BindTool.Bind(self.OnToggleChange, self , SHENGE_PAGE.LEVEL))
	self.node_list["Img_chenghao"].button:AddClickListener(BindTool.Bind(self.OpenTipsTitleLimit, self, false))
	self.node_list["Node_big_goal"].button:AddClickListener(BindTool.Bind(self.OpenTipsTitleLimit, self, false, true))


	self.slot_cell_list = {}
	for i = 1, ShenGeEnum.SHENGE_SYSTEM_CUR_MAX_SHENGE_GRID do
		self.slot_cell_list[i] = ShenGeCell.New(self.node_list["SlotCell" .. i])
		self.slot_cell_list[i]:ListenClick(BindTool.Bind(self.OnClickShenGeCell, self, i - 1))
		self.slot_cell_list[i]:SetIndex(i - 1)
	end
	local list_delegate = self.node_list["ListView"].page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.node_list["ListView"].list_view:Reload()
	self.node_list["ListView"].list_page_scroll2:JumpToPageImmidate(0)

	self.next_open_page = ""
	self.total_history_level = ""
	self.open_page_level = ""
	self.click_index = -1
	self.is_click_bag_cell = false
	self.level_item = ItemCell.New()
	self.level_item:SetInstanceParent(self.node_list["ItemPos"])
	ShenGeData.Instance:SetCurPage(1)
	self:Flush()

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightNumber"])
	self.fight_text_two = CommonDataManager.FightPower(self, self.node_list["FPbyLevel"])
end

function ShenGeInlayView:__delete()
	self.fight_text = nil
	self.fight_text_two = nil
	if self.level_item then 
		self.level_item:DeleteMe()
		self.level_item = nil 
	end
	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	for _, v in pairs(self.slot_cell_list) do
		v:DeleteMe()
	end
	self.slot_cell_list = {}
	if self.time_qianghua then 
		GlobalTimerQuest:CancelQuest(self.time_qianghua)
		self.time_qianghua = nil
	end

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	TitleData.Instance:ReleaseTitleEff(self.node_list["Img_chenghao"])
end

function ShenGeInlayView:CloseCallBack()
	if self.time_qianghua then 
		GlobalTimerQuest:CancelQuest(self.time_qianghua)
		self.time_qianghua = nil
	end
	
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function ShenGeInlayView:LoadCallBack()
	self.now_index = nil
end

function ShenGeInlayView:OpenCallBack()
	self:SelectCell()
	--self:ChangeChoose()
end

function ShenGeInlayView:CloseCallBack()
	self:ShowDontHaveCount()
end

function ShenGeInlayView:FlshGoalContent()
	self.goal_info = ShenGeData.Instance:GetGoalInfo()
	if self.goal_info then
		local sever_time = TimeCtrl.Instance:GetServerTime()
		local diff_time = self.goal_info.open_system_timestamp - sever_time
		if self.goal_info.fetch_flag[0] == 0 then
			local is_show_little_goal = RuneData.Instance:IsShowJGoalRewardIcon(0, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENGE)
			if is_show_little_goal then
				self.node_list["Node_little_goal"]:SetActive(true)
				local goal_cfg_info = RuneData.Instance:GetItemGoalInfo(0, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENGE)
				if goal_cfg_info then
					local title_id = goal_cfg_info.reward_show
					local item_id = goal_cfg_info.reward_item[0].item_id
					self.goal_data.item_id = item_id
					self.goal_data.cost = goal_cfg_info.cost
					self.goal_data.can_fetch = self.goal_info.active_flag[0] == 1
					diff_time = diff_time + goal_cfg_info.free_time_since_open * 3600
					local cfg = TitleData.Instance:GetTitleCfg(title_id)
					if nil == cfg then
						return
					end
					local zhanli = CommonDataManager.GetCapabilityCalculation(cfg)
					local bundle, asset = ResPath.GetTitleIcon(title_id)
					self.node_list["Img_chenghao"].image:LoadSprite(bundle, asset, function() 
						TitleData.Instance:LoadTitleEff(self.node_list["Img_chenghao"], title_id, true)
						UI:SetGraphicGrey(self.node_list["Img_chenghao"], self.goal_info.active_flag[0] == 0)
						end)
					self.node_list["Txt_fightpower"].text.text = Language.Goal.PowerUp .. zhanli
					self.node_list["NodeGoal"].animator:SetBool("IsShake" , self.goal_data.can_fetch)
					self.node_list["little_goal_redpoint"]:SetActive(self.goal_data.can_fetch)
				end
			else
				self.node_list["Txt_lefttime"]:SetActive(false)
				self.node_list["Node_little_goal"]:SetActive(false)
			end
		else
			local is_show_big_goal = RuneData.Instance:IsShowJGoalRewardIcon(1, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENGE)
			if is_show_big_goal then
				self.node_list["Node_little_goal"]:SetActive(false)
				self.node_list["Node_big_goal"]:SetActive(true)
				self.node_list["Txt_shuxing"]:SetActive(true)
				UI:SetGraphicGrey(self.node_list["Img_touxiang_frame"], not(self.goal_info.active_special_attr_flag == 1 and self.goal_info.fetch_flag[1] == 1))
				self.node_list["Effect"]:SetActive(self.goal_info.fetch_flag[1] == 0)
				local goal_cfg_info = RuneData.Instance:GetItemGoalInfo(1, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENGE)
				if goal_cfg_info then
					local attr_percent = RuneData.Instance:GetGoalAttr(ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENGE)
					local item_id = goal_cfg_info.reward_item[0].item_id
					local item_cfg = ItemData.Instance:GetItemConfig(item_id)
					if item_cfg == nil then
						return
					end
					local item_bundle, item_asset = ResPath.GetItemIcon(item_cfg.icon_id)
					self.node_list["Img_touxiang"].image:LoadSprite(item_bundle, item_asset)
					self.goal_data.item_id = item_id
					self.goal_data.cost = goal_cfg_info.cost
					self.goal_data.can_fetch = self.goal_info.active_flag[1] == 1
					diff_time = diff_time + goal_cfg_info.free_time_since_open * 3600
					self.node_list["Txt_shuxing"].text.text = string.format(Language.Goal.AttrAdd, attr_percent/100) .. "%"
					self.node_list["NodeGoal"].animator:SetBool("IsShake" , self.goal_data.can_fetch and self.goal_info.fetch_flag[1] ~= 1)
					self.node_list["big_goal_redpoint"]:SetActive(self.goal_data.can_fetch and self.goal_info.fetch_flag[1] ~= 1)
				end
			else
				self.node_list["Node_little_goal"]:SetActive(false)
				self.node_list["Node_big_goal"]:SetActive(false)
				self.node_list["Txt_shuxing"]:SetActive(false)
			end
		end

		self.goal_data.left_time = diff_time
		if self.count_down == nil then
			function diff_time_func(elapse_time, total_time)
				local left_time = math.floor(diff_time - elapse_time + 0.5)
				if left_time <= 0 then
					if self.count_down ~= nil then
						self.node_list["Txt_lefttime"]:SetActive(false)
						CountDown.Instance:RemoveCountDown(self.count_down)
						self.count_down = nil
					end
					return
				end
				if left_time > 0 then
					self.node_list["Txt_lefttime"]:SetActive(true)
					self.node_list["Txt_lefttime"].text.text = Language.Goal.FreeTime .. TimeUtil.FormatSecond(left_time, 10)
				else
					self.node_list["Txt_lefttime"]:SetActive(false)
				end
				if self.goal_info.fetch_flag[0] == 1 and self.goal_info.fetch_flag[1] == 1 then
					self.node_list["Txt_lefttime"]:SetActive(false)
				end
			end

			diff_time_func(0, diff_time)
			self.count_down = CountDown.Instance:AddCountDown(
				diff_time, 0.5, diff_time_func)
		end
	end
end

function ShenGeInlayView:OpenTipsTitleLimit(is_model, is_other_item)
	local fun = function(click_type)
		RuneCtrl.Instance:SendBigSmallGoalOper(ROLE_BIG_SMALL_GOAL_OPERA_TYPE.ROLE_BIG_SMALL_GOAL_OPERA_FETCH, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENGE, click_type)
	end

	self.goal_data.from_panel = ""
	self.goal_data.call_back = fun
	TipsCtrl.Instance:ShowGoalTimeLimitTitleView(self.goal_data, is_model, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENGE, is_other_item)
end

function ShenGeInlayView:OnToggleChange(page, bool)
	if bool then  
		self.now_page = page
		ShenGeData.Instance:SetCurPage(page)
	end
	self:Flush()
end
function ShenGeInlayView:OnClickUp()
	local cur_page = ShenGeData.Instance:GetCurPageIndex()
	ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_UPLEVEL, 1 ,cur_page, self.now_index)
end

function ShenGeInlayView:OnClickUpOneKey()
	----- 一键升级 -------------
	--local cur_page = ShenGeData.Instance:GetCurPageIndex()
	--ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_UPLEVEL,2 ,cur_page ,self.now_index)
	-----------------------------
	--------自动升级-------------------------
	self.is_auto_level = not self.is_auto_level
	if self.is_auto_level then 
		if self.time_qianghua then 
			GlobalTimerQuest:CancelQuest(self.time_qianghua)
			self.time_qianghua = nil
		end
		self.time_qianghua = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.ChangeChoose , self), 0.2)
	else
		if self.time_qianghua then 
			GlobalTimerQuest:CancelQuest(self.time_qianghua)
			self.time_qianghua = nil
		end
	end 
	if self.is_auto_level then 
		self.node_list["OnKeyTxt"].text.text = Language.ShenGe.QuXiaoZhuLing
	else
		self.node_list["OnKeyTxt"].text.text = Language.ShenGe.ZiDongZhuLing
	end
	self:SetButton()
	--------------------------------------------------------------
end

function ShenGeInlayView:SetButton()
	UI:SetButtonEnabled(self.node_list["ButtonUp"], not self.is_auto_level)
end

function ShenGeInlayView:ChangeChoose()
	local cur_page = ShenGeData.Instance:GetCurPageIndex()
	local level_index = ShenGeData.Instance:GetLowestXingHui(cur_page)
	if nil == level_index then
		self:ShowDontHaveCount()
		return
	end

	local data = ShenGeData.Instance:GetInlayData(cur_page, level_index)
	local attr_cfg = ShenGeData.Instance:GetShenGeAttributeCfg(data.shen_ge_data.type, data.shen_ge_data.quality, data.shen_ge_data.level)
	local next_attr_cfg = ShenGeData.Instance:GetShenGeAttributeCfg(data.shen_ge_data.type, data.shen_ge_data.quality, data.shen_ge_data.level + 1)
	if not next_attr_cfg then
		self.node_list["OnKeyTxt"].text.text = Language.ShenGe.ZiDongZhuLing
		self.is_auto_level = false
		if self.time_qianghua then 
			GlobalTimerQuest:CancelQuest(self.time_qianghua)
			self.time_qianghua = nil
			self:SetButton()
		end
		TipsCtrl.Instance:ShowSystemMsg(Language.ShenGe.YiManJi)
		return
	end
	local need_count = attr_cfg.next_level_need_marrow_score
	local have_count = ShenGeData.Instance:GetJiFenCount()
	if need_count <= have_count then
		local index = level_index + 1
		self.node_list["SlotCell" .. index].toggle.isOn = true
		self:OnClickShenGeCell(level_index)
		self:OnClickUp()
	else
		level_index = ShenGeData.Instance:GetLowestXingHuiSecond(cur_page)
		data = ShenGeData.Instance:GetInlayData(cur_page, level_index)
		attr_cfg = ShenGeData.Instance:GetShenGeAttributeCfg(data.shen_ge_data.type, data.shen_ge_data.quality, data.shen_ge_data.level)
		need_count = attr_cfg.next_level_need_marrow_score
		have_count = ShenGeData.Instance:GetJiFenCount()
		if need_count <= have_count then
			local index = level_index + 1
			self.node_list["SlotCell" .. index].toggle.isOn = true
			self:OnClickShenGeCell(level_index)
			self:OnClickUp()
		else
			self:ShowDontHaveCount()
			TipsCtrl.Instance:ShowSystemMsg(Language.ShenGe.JingHuaBuZhu)
		end
	end
	self:Flush()
end

function ShenGeInlayView:ShowDontHaveCount()
	self.is_auto_level = false
	self.node_list["OnKeyTxt"].text.text = Language.ShenGe.ZiDongZhuLing
	if self.time_qianghua then 
		GlobalTimerQuest:CancelQuest(self.time_qianghua)
		self.time_qianghua = nil
	end
	self:SetButton()
end

-- 打开合成
function ShenGeInlayView:OnClickCompose()
	ViewManager.Instance:Open(ViewName.ShenGeComposeView)
end

--打开符文总览界面
function ShenGeInlayView:OpenOverView()
	ViewManager.Instance:Open(ViewName.ShenGePreview)
end

function ShenGeInlayView:OnClickFenJie()
	ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_SORT_BAG)
	ViewManager.Instance:Open(ViewName.ShenGeFenJie)
end

function ShenGeInlayView:OnClickPreview()
	ViewManager.Instance:Open(ViewName.ShenGeAttrView)
end

-- 点击整理背包
function ShenGeInlayView:OnClickClean()
	ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_SORT_BAG)
end

-- 一键分解
-- function ShenGeInlayView:OnClickDecompose()
-- 	ViewManager.Instance:Open(ViewName.ShenGeDecomposeView)
-- end

function ShenGeInlayView:OnClickHelp()
	local tips_id = 167
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function ShenGeInlayView:SelectCell()
	if self.now_index == nil or self.slot_cell_list[self.now_index + 1]:GetData() == nil then
		local index = 1
		for k,v in pairs(self.slot_cell_list) do
			local data = v:GetData()
			if data ~= nil then
				index = k
			end
		end
		self.node_list["SlotCell" .. index].toggle.isOn = true
		--self:OnClickShenGeCell(index - 1)
		self.now_index = index - 1
	end
end

function ShenGeInlayView:OnClickShenGeCell(index)
	self.now_index = index
	self:FlushLevelInfo()
	-- if self.now_page == SHENGE_PAGE.LEVEL then 
	-- 	return
	-- end
	if self.slot_cell_list[self.now_index + 1]:GetData() ~= nil and self.now_page == SHENGE_PAGE.LEVEL then
		return
	end
	local list = ShenGeData.Instance:GetSlotStateList()
	local flag = list[index]
	if nil == flag then
		flag = false
	end
	if not flag then
		TipsCtrl.Instance:ShowSystemMsg(Language.ShenGe.TotalLevelNoEnough)
		return
	end
	local cell_data = self.slot_cell_list[index + 1]:GetData()
	if nil ~= cell_data and nil ~= cell_data.item_id and cell_data.item_id > 0 then
		ShenGeCtrl.Instance:ShowUpgradeView(cell_data, false)
		return
	end

	local quyu = math.floor(index / 4) + 1

	if #ShenGeData.Instance:GetSameQuYuDataList(quyu) <= 0 then
		TipsCtrl.Instance:ShowSystemMsg(Language.ShenGe.NoShenGeTakeOn)
		return
	end

	local call_back = function(data)
		if nil == data then
			return
		end
		local cur_page = ShenGeData.Instance:GetCurPageIndex()
		ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_SET_RUAN, data.shen_ge_data.index, cur_page, index)
	end
	ShenGeCtrl.Instance:ShowSelectView(call_back, {[1] = quyu}, "from_inlay", SHENGE_HAVE_DATA.NO_HAVE)
end

function ShenGeInlayView:FlushLevelInfo()
	local is_show_up_red = ShenGeData.Instance:CalcShenGeRedPointByJiFen()
	self.node_list["ImgUpRedPoint"]:SetActive(is_show_up_red)
	local is_show_lay_red = ShenGeData.Instance:CalcShenGeInLayRedPoint()
	-- self.node_list["ImgInLayRedPoint"]:SetActive(is_show_lay_red)

	local have_count = ShenGeData.Instance:GetJiFenCount()
	if nil == self.now_index then
		local nil_data = {}
		self.level_item:SetData(nil_data)
		self.node_list["AttrTypeDes"].text.text = ""
		if self.fight_text_two and self.fight_text_two.text then
			self.fight_text_two.text.text = 0
		end
		self.node_list["NextAttr"].text.text = have_count .. " / " .. ToColorStr(0,TEXT_COLOR.RED)
		self.node_list["UpContent1"]:SetActive(false)
		self.node_list["UpContent2"]:SetActive(false)
		self.node_list["item1"]:SetActive(false)
		self.node_list["item2"]:SetActive(true)
		return 
	end 
	local attr_list = {}
	--local cur_page = ShenGeData.Instance:GetCurPageIndex()
	local cell_info = self.slot_cell_list[self.now_index + 1]:GetData()
	if nil == cell_info or nil == cell_info.item_id or cell_info.item_id <= 0 then 
		local nil_data = {}
		self.level_item:SetData(nil_data)
		self.node_list["AttrTypeDes"].text.text = ""
		if self.fight_text_two and self.fight_text_two.text then
			self.fight_text_two.text.text = 0
		end
		self.node_list["NextAttr"].text.text = have_count .. " / " .. ToColorStr(0,TEXT_COLOR.RED)
		self.node_list["UpContent1"]:SetActive(false)
		self.node_list["UpContent2"]:SetActive(false)
		self.node_list["item1"]:SetActive(false)
		self.node_list["item2"]:SetActive(true)
		return
	end
	self.node_list["item1"]:SetActive(true)
	self.node_list["item2"]:SetActive(false)
	local cell_data = cell_info.shen_ge_data
	
	self.level_item:SetData(cell_info)
	local attr_cfg = ShenGeData.Instance:GetShenGeAttributeCfg(cell_data.type, cell_data.quality, cell_data.level)
	local attr_cfg_next = ShenGeData.Instance:GetShenGeAttributeCfg(cell_data.type, cell_data.quality, cell_data.level + 1)
	local is_max = false
	if nil == attr_cfg_next then 
		attr_cfg_next = attr_cfg
		is_max = true
	end
	self.node_list["AttrTypeDes"].text.text = attr_cfg and (attr_cfg.name .. " Lv." .. cell_data.level) or ""
	if attr_cfg and attr_cfg_next then
		for i=1, MAX_NUM do
			local attr_value = 0
			local attr_type = 0
			attr_value = attr_cfg["add_attributes_"..(i - 1)]
			attr_type = attr_cfg["attr_type_"..(i - 1)]
			local attr_key = Language.ShenGe.AttrType[attr_type]
			local attr_value_next = attr_cfg_next["add_attributes_"..(i - 1)]
			local attr_type_next = attr_cfg_next["attr_type_"..(i - 1)]
			if not is_max then
				-- self.node_list["IsMax"]:SetActive(false)
				-- self.node_list["CostContent"]:SetActive(true)
				self.node_list["Attradd" .. i]:SetActive(true)
				-- UI:SetButtonEnabled(self.node_list["ButtonUp"], true)
				self:SetButton()
				self.node_list["ButtonUpText"].text.text = Language.Common.UpGrade
			end
			if attr_value > 0 then
				self.node_list["UpContent" .. i]:SetActive(true)
				if attr_type == 8 or attr_type == 9 then
					self.node_list["Attr" .. i].text.text = Language.ShenGe.AttrTypeName[attr_type].."  +"..(attr_value / 100).."%"
					self.node_list["Attradd" .. i].text.text = "  +" .. ((attr_value_next - attr_value) / 100).."%"
				else
					attr_list[attr_key] = attr_value
					local attr_value_text=Language.ShenGe.AttrTypeName[attr_type].."<color=#ffffff>  +</color>"..ToColorStr(attr_value,TEXT_COLOR_WHITE)
					local attr_value_text_next= " +" .. (attr_value_next - attr_value)
					self.node_list["Attr" .. i].text.text = attr_value_text
					self.node_list["Attradd" .. i].text.text = attr_value_text_next
				end
			else
				self.node_list["Attr" .. i].text.text = ""
				self.node_list["Attradd" .. i].text.text = ""
				self.node_list["UpContent" .. i]:SetActive(false)
			end
		end
	end

	local power = CommonDataManager.GetCapabilityCalculation(attr_list)
	local need_count = attr_cfg and (attr_cfg.next_level_need_marrow_score) or 0
	if self.fight_text_two and self.fight_text_two.text then
		self.fight_text_two.text.text = power
	end
	if have_count >= need_count then
		self.node_list["NextAttr"].text.text = have_count.. " / " .. need_count
	else
		self.node_list["NextAttr"].text.text =  have_count .. " / " .. ToColorStr(need_count,TEXT_COLOR.RED)
	end
	if is_max then
		self.node_list["NextAttr"].text.text = Language.Common.MaxLevelDesc
		self.node_list["ButtonUpText"].text.text = Language.Common.YiManJi
		self.node_list["Attradd1"]:SetActive(false)
		self.node_list["Attradd2"]:SetActive(false)
		UI:SetButtonEnabled(self.node_list["ButtonUp"], false)
	end
end
-- -- 点击符文页
-- function ShenGeInlayView:OnClickPage(index)
-- 	local open_num = ShenGeData.Instance:GetShenGeOpenPageNum()
-- 	if open_num < index then
-- 		return
-- 	end
-- 	ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_CHANGE_RUNA_PAGE, index - 1)
-- end

-- function ShenGeInlayView:OnClickPageMask(index)
-- 	local open_level = ShenGeData.Instance:GetShenGePageOpenLevel(index - 1)
-- 	local str = string.format(Language.ShenGe.PageOpenTip, open_level, index)
-- 	TipsCtrl.Instance:ShowSystemMsg(str)
-- end

function ShenGeInlayView:ClickBagCell(inde, data, cell)
	if nil == data then return end
	self.click_index = inde
	local close_call_back = function()
		self.click_index = -1
		cell:SetHighLight(false)
		self.is_click_bag_cell = false
	end
	ShenGeCtrl.Instance:ShowUpgradeView(data, true, close_call_back)
	self.is_click_bag_cell = true
end

function ShenGeInlayView:GetNumberOfCells()
	return MAX_BAG_GRID_NUM
end

function ShenGeInlayView:RefreshCell(index, cellObj)
	-- 构造Cell对象.
	local cell = self.cell_list[cellObj]
	if nil == cell then
		cell = ItemCell.New(cellObj)
		--cell:SetInstance(cellObj)
		cell:SetToggleGroup(self.node_list["ListView"].toggle_group)
		self.cell_list[cellObj] = cell
	end

	local page = math.floor(index / BAG_PAGE_COUNT)
	
	local cur_colunm = math.floor(index / ROW_NUM) + 1 - page * COLUMN_NUM
	local cur_row = math.floor(index % ROW_NUM) + 1
	local grid_index = (cur_row - 1) * COLUMN_NUM - 1 + cur_colunm  + page * ROW_NUM * COLUMN_NUM

	local data = ShenGeData.Instance:GetShenGeItemData(grid_index)
	cell:ListenClick(BindTool.Bind(self.ClickBagCell, self, grid_index, data, cell))
	cell:SetInteractable(nil ~= data)
	cell:SetHighLight(self.click_index == grid_index)
	cell:SetIndex(grid_index)
	cell:SetData(data)
	cell:ShowQuality(nil ~= data)
	cell:ShowStrengthLable(nil ~= data)
	if data and data["shen_ge_data"] then
		cell:SetStrength(data["shen_ge_data"].level)
	end
	cell.node_list["Icon"].image.preserveAspect = true
end

function ShenGeInlayView:OnDataChange(info_type, param1, param2, param3, bag_list)
	if info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_COMPOSE_SHENGE_INFO
		or info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_SIGLE_CHANGE
		or info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ALL_BAG_INFO
		or info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ALL_CHOUJIANG_INFO then

		self:Flush()

	elseif info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_USING_PAGE_INDEX then
		self:Flush()

	elseif info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ALL_SHENGE_INFO
		or info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_SHENGE_INFO then

		self:Flush()

	elseif info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ALL_MARROW_SCORE_INFO then
		-- self.node_list["TxtBagTitle"].text.text = string.format(Language.ShenGe.XingHuiJingHua, ShenGeData.Instance:GetFragments())
	end
end

function ShenGeInlayView:SetSlotState()
	local cur_page = ShenGeData.Instance:GetCurPageIndex()
	for k, v in pairs(self.slot_cell_list) do
		v:SetSlotData(ShenGeData.Instance:GetInlayData(cur_page, k - 1))
	end
end

-- function ShenGeInlayView:SetOpenPageInfo()
-- 	local open_num = ShenGeData.Instance:GetShenGeOpenPageNum()
-- 	local open_level = ShenGeData.Instance:GetShenGePageOpenLevel(open_num)
-- 	self.total_history_level = (ShenGeData.Instance:GetInlayHistoryTotalLevel())
-- 	self.node_list["TxtOpenPageLevel"].text.text = string.format(Language.ShenGe.XingHuiOpen, 
-- 		self.next_open_page, 
-- 		self.total_history_level, 
-- 		self.open_page_level)
-- 	if open_level <= 0 then
-- 		self.node_list["TxtOpenPageLevel"]:SetActive(false)
-- 		return
-- 	end
-- 	self.node_list["TxtOpenPageLevel"]:SetActive(true)
-- 	self.next_open_page = CommonDataManager.GetDaXie(open_num + 1)
-- 	self.total_history_level = ShenGeData.Instance:GetInlayHistoryTotalLevel()
-- 	self.open_page_level = open_level
-- 	self.node_list["TxtOpenPageLevel"].text.text = string.format(Language.ShenGe.XingHuiOpen, 
-- 		self.next_open_page, 
-- 		self.total_history_level, 
-- 		self.open_page_level)
-- end

-- -- 设置页面按钮上的红点
-- function ShenGeInlayView:SetPageRemind()
-- 	local open_page_num = ShenGeData.Instance:GetShenGeOpenPageNum()

-- 	for k = 1, ShenGeEnum.SHENGE_SYSTEM_CUR_SHENGE_PAGE do
-- 		if k <= (open_page_num) then
-- 			self.node_list["ImgRedmind" .. k]:SetActive(ShenGeData.Instance:CalcShenRedPointByPageNum(k - 1))

-- 		else
-- 			self.node_list["ImgRedmind" .. k]:SetActive(false)
-- 		end
-- 	end
-- end

function ShenGeInlayView:OnFlush(param_list)
	-- self.node_list["fenjieRedPoint"]:SetActive(ShenGeData.Instance:GetShenGeCount() >= FenJieTiShiCount)
	-- local open_num = ShenGeData.Instance:GetShenGeOpenPageNum()
	local cur_page = ShenGeData.Instance:GetCurPageIndex()

	-- for k = 1, ShenGeEnum.SHENGE_SYSTEM_CUR_SHENGE_PAGE do
		-- if k == 2 then
		-- 	-- self.node_list["NodeMid"]:SetActive(k > open_num)
		-- end
		-- if k == 3 then
		-- 	self.node_list["NodeRightMask"]:SetActive(k > open_num)
		-- end
		-- self.node_list["TogglePage" .. k].toggle.isOn = (k == (cur_page + 1))
		-- UI:SetButtonEnabled(self.node_list["TogglePage" .. k], k <= open_num)
	-- end

	-- self.node_list["TxtCurLevel"].text.text = string.format(Language.ShenGe.XingHuiLevel, ShenGeData.Instance:GetInlayLevel(cur_page))
	self:SetSlotState()

	local attr_list, other_capability = ShenGeData.Instance:GetInlayAttrListAndOtherFightPower(cur_page)
	local power = CommonDataManager.GetCapabilityCalculation(attr_list)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = power + other_capability
	end

	-- self:SetOpenPageInfo()

	-- self:SetPageRemind()

	if self.node_list["ListView"].list_view.isActiveAndEnabled then
		if self.is_click_bag_cell then
			for _, v in pairs(self.cell_list) do
				if v:GetIndex() == self.click_index then
					local data = ShenGeData.Instance:GetShenGeItemData(self.click_index)
					v:SetData(data)
				end
			end
		else
			self.node_list["ListView"].list_view:Reload()
		end
	end
	self:FlushLevelInfo()
	self:FlshGoalContent()

	local suit_attr = ShenGeData.Instance:GetTaoZhuangAttr()
	local cap = CommonDataManager.GetCapability(suit_attr)
	if cap > 0 then
		self.node_list["SuitCapBg"]:SetActive(true)
		self.node_list["SuitCap"].text.text = string.format(Language.Common.GaoZhanLi, cap)
		self.node_list["GaoPer"]:SetActive(false)
	else
		self.node_list["SuitCapBg"]:SetActive(false)
		self.node_list["SuitCap"].text.text = ""
		self.node_list["GaoPer"]:SetActive(true)
	end
end


------------------- 神格槽 -----------------------------
ShenGeCell = ShenGeCell or BaseClass(BaseRender)

function ShenGeCell:__init(instance)
	self.show_lock = false
	self.show_level = false
	self.show_quality = false
	self.index = 0
end

function ShenGeCell:ListenClick(handler)
	self.node_list["Cell"].toggle:AddClickListener(handler)
end

function ShenGeCell:SetIndex(index)
	self.index = index
end

function ShenGeCell:GetData()
	return self.data
end

function ShenGeCell:SetSlotData(data)
	self.data = data
	local list = ShenGeData.Instance:GetSlotStateList()
	local flag = list[self.index]
	if nil == flag then
		flag = false
	end
	self.show_lock = not flag
	self:JudgeState(self.show_lock, self.show_level, self.show_quality)
	local groove_index, next_open_level = ShenGeData.Instance:GetNextGrooveIndexAndNextGroove()

	--self.show_level = (groove_index == (self.index) and next_open_level > 0)

	self:JudgeState(self.show_lock, self.show_level, self.show_quality)
	if next_open_level > 0 then
		--self.node_list["TxtLevel"].text.text = string.format(Language.ShenGe.OpenGroove, next_open_level)
	end

	self.show_quality = false
	self.node_list["ImgRedmind"]:SetActive(false)
	local same_quyu_list = ShenGeData.Instance:GetSameQuYuDataList(math.floor(self.index / 4) + 1)
	local is_can_inlay = false
	-- if nil ~= data then
	-- 	if nil ~= data.shen_ge_data then 
	-- 		for k,v in pairs(same_quyu_list) do
	-- 			while true do 
	-- 				if nil == v.shen_ge_data then 
	-- 					break
	-- 				end
	-- 				if nil == data.shen_ge_data.quality or nil == v.shen_ge_data.quality then 
	-- 					break
	-- 				end
	-- 				if data.shen_ge_data.quality < v.shen_ge_data.quality then 

	-- 					is_can_inlay = true
	-- 				end
	-- 				break
	-- 			end
	-- 			if is_can_inlay == true then 
	-- 				break
	-- 			end
	-- 		end
	-- 	end
	-- end
	local page = ShenGeData.Instance:GetCurPage()
	if nil ~= data and nil ~= data.shen_ge_data then
		for k,v in pairs(same_quyu_list) do
			if nil ~= v.shen_ge_data and nil ~= data.shen_ge_data.quality and nil ~= v.shen_ge_data.quality and
				data.shen_ge_data.quality < v.shen_ge_data.quality then
				if ShenGeData.Instance:GetCanChangeShenGe(data.shen_ge_data.type , v.shen_ge_data.type , math.floor(self.index / 4) + 1) 
					and page == SHENGE_PAGE.INLAY then 
				-- local max_count = 0
				-- if SHENGE_TYPE_MAX_COUNT[v.shen_ge_data.type] == "ultimate" then 
				-- 	max_count = 2
				-- else
				-- 	max_count = 4
				-- end

					is_can_inlay = true
					break
				end
			end
		end

		
	end

	if not is_can_inlay and nil ~= data then
		local cfg = ShenGeData.Instance:GetShenGepreviewCfg(data.shen_ge_data.type, data.shen_ge_data.quality, data.shen_ge_data.level)
		if cfg and cfg.next_level_need_marrow_score <= ShenGeData.Instance:GetJiFenCount() and page == SHENGE_PAGE.LEVEL then
			is_can_inlay = true
		end
	end

	if nil ~= data and nil ~= data.shen_ge_data then
		if nil ~= data.shen_ge_data.level and data.shen_ge_data.level >= MaxLevel then
			is_can_inlay = false
		end
	end

	self.node_list["ImgRedmind"]:SetActive(is_can_inlay)
	if nil == data or nil == data.item_id or data.item_id <= 0 then
		local slot_state_list = ShenGeData.Instance:GetSlotStateList()
		if slot_state_list[self.index] and (nil == data or data.item_id <= 0) and #ShenGeData.Instance:GetSameQuYuDataList(math.floor(self.index / 4) + 1) > 0 then
			if ShenGeData.Instance:GetCanAddShengGe(math.floor(self.index / 4) + 1) then 
				is_can_inlay = true
			end
		end

		self.node_list["ImgIcon"]:SetActive(false)
		self.node_list["TxtLevel"]:SetActive(false)
		self.node_list["ImgRedmind"]:SetActive(is_can_inlay)
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if nil == item_cfg then 
		return 
	end
	self.node_list["lv"].text.text = data.shen_ge_data.level
	self.node_list["ImgIcon"].image:LoadSprite(ResPath.GetItemIcon(item_cfg.icon_id))
	self.node_list["ImgIcon"]:SetActive(true)
	self.node_list["TxtLevel"]:SetActive(true)
	-- self.node_list["TxtLevelTxt"].text.text = data.shen_ge_data.level
	--self.node_list["ImgQuality"].image:LoadSprite(ResPath.GetRomeNumImage(data.shen_ge_data.quality))
	self.show_quality = true
	self:JudgeState(self.show_lock, self.show_level, self.show_quality)

	-- local cur_page = ShenGeData.Instance:GetCurPageIndex()
	-- self.node_list["ImgRedmind"]:SetActive(ShenGeData.Instance:GetShenGeInlayCellCanUpLevel(cur_page, data.shen_ge_data.index))
end

function ShenGeCell:JudgeState(ShowLock, ShowLevel, ShowQuality)
	--self.node_list["TxtLevel"]:SetActive(ShowLevel)
	self.node_list["ImgLock"]:SetActive(ShowLock and (not ShowLevel))
	self.node_list["ImgPlus"]:SetActive((not ShowLock) and (not ShowLevel) and (not ShowQuality))
	-- self.node_list["ImgLevel"]:SetActive((not ShowLock) and (not ShowLevel) and ShowQuality)
	--self.node_list["ImgQuality"]:SetActive((not ShowLevel) and (not ShowLock) and ShowQuality)
end
 --------------------------------------------------------------------------
--PlayerTitleView 	称号面板视图
--------------------------------------------------------------------------
PlayerTitleView = PlayerTitleView or BaseClass(BaseRender)

function PlayerTitleView:__init(instance)
	self.node_list["BntAdron"].button:AddClickListener(BindTool.Bind(self.OnAdronClick, self))
	self.node_list["NodeTitleContents"].button:AddClickListener(BindTool.Bind(self.OnCloseTipsClick, self))
	self.node_list["NoteAttributeContent"].button:AddClickListener(BindTool.Bind(self.OnCloseTipsClick, self))
	self.node_list["NoteRoleContent"].button:AddClickListener(BindTool.Bind(self.OnCloseTipsClick, self))
	self.node_list["BtnJinJie"].button:AddClickListener(BindTool.Bind(self.OnClickJinjie, self))
	self.node_list["BtnUnwield"].button:AddClickListener(BindTool.Bind(self.OnUnwieldClick, self))
	self.node_list["ToggleTotalInlay"].toggle:AddClickListener(BindTool.Bind(self.OnClickTotalInlay,self))
	self.node_list["ToggleUpLevel"].toggle:AddClickListener(BindTool.Bind(self.OnClickLingshuUpdate, self))
	--self.node_list["attr_btn"].button:AddClickListener(BindTool.Bind(self.AllAttriBtnOnClick, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFightPowerNumber"])
	self.is_teshu = 0
	local title_data = TitleData.Instance
	self.current_title_id = title_data:GetCurTitleId()
	self.title_contain_list = {}
	self:FlushTitle()
	self:UpdateAttribute()
	self.title_id_list = TitleData.Instance:ResortTitleIdListByIsTeShu(self.is_teshu)
	self.all_title_id_cfg = TitleData.Instance:GetAllTitle()

	local list_delegate = self.node_list["list_view"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.TitleGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.TitleRefreshCell, self)
end

function PlayerTitleView:__delete()
	RemindManager.Instance:UnBind(self.remind_change)
	for k, v in pairs(self.title_contain_list) do
		v:DeleteMe()
	end
	self.title_contain_list = {}
	self.current_title_id = 0

	if self.title_count_down then
		CountDown.Instance:RemoveCountDown(self.title_count_down)
		self.title_count_down = nil
	end
	self.fight_text = nil
	if TitleData and TitleData.Instance then
		TitleData.Instance:ReleaseTitleEff(self.node_list["TxtTitle"])
	end
end

function PlayerTitleView:OnClickTotalInlay()
	self.is_teshu = 0
	self.title_id_list = TitleData.Instance:ResortTitleIdListByIsTeShu(self.is_teshu)
	self.node_list["list_view"].scroller:ReloadData(0)
end

function PlayerTitleView:OnClickLingshuUpdate()
	self.is_teshu = 1
	self.title_id_list = TitleData.Instance:ResortTitleIdListByIsTeShu(self.is_teshu)
	self.node_list["list_view"].scroller:ReloadData(0)
end

function PlayerTitleView:CloseCallBack()
	if self.title_count_down then
		CountDown.Instance:RemoveCountDown(self.title_count_down)
		self.title_count_down = nil
	end
end

function PlayerTitleView:SetCurrentId(title_id)
	self.current_title_id = title_id
	self:Flush()
end

function PlayerTitleView:GetCurrentId()
	return self.current_title_id
end

----------点击事件------------
function PlayerTitleView:OnClickJinjie()
	ViewManager.Instance:Open(ViewName.PlayerTitleHuanhua)
end

function PlayerTitleView:OnCloseTipsClick()
	self.node_list["all_attribute_contain"]:SetActive(true)
end

function PlayerTitleView:AllAttriBtnOnClick()
	local attr = TitleData.Instance:GetShowAttrList()
	self.node_list["TxtHPValue"].text.text = attr.hp
	self.node_list["TxtFangYuValue"].text.text = attr.defense
	self.node_list["TxtGongJiValue"].text.text = attr.attack
end

function PlayerTitleView:OnUnwieldClick()
	TitleCtrl.Instance:SendCSUseTitle({0,0,0})
end

function PlayerTitleView:OnAdronClick()
	if not TitleData.Instance:GetIsUsed(self.current_title_id) then
		local used_title_list = {self.current_title_id, 0, 0}
		TitleCtrl.Instance:SendCSUseTitle(used_title_list)
	end
end
----------点击事件END------------

function PlayerTitleView:TitleGetNumberOfCells()
	return math.ceil(#self.title_id_list)
end

function PlayerTitleView:TitleRefreshCell(contain,cell_index)
	local title_contain = self.title_contain_list[contain]
	if title_contain == nil then
		title_contain = TitleContain.New(contain.gameObject, self)
		self.title_contain_list[contain] = title_contain
		title_contain:SetToggleGroup(self.node_list["list_view"].toggle_group)
	end
	local data = {self.title_id_list[cell_index + 1]}
	title_contain:SetData(data)
end

--更新属性面板
function PlayerTitleView:UpdateAttribute()
	if self.title_count_down then
		CountDown.Instance:RemoveCountDown(self.title_count_down)
		self.title_count_down = nil
	end
	self:AllAttriBtnOnClick()
	local title_cfg = TitleData.Instance:GetTitleCfg(self.current_title_id)
	if nil == title_cfg or nil == next(title_cfg) then return end
	self.node_list["TxtAttackContentValue"].text.text = title_cfg.gongji
	self.node_list["TxtDefenseContentValue"].text.text = title_cfg.fangyu
	self.node_list["TxtHpContentValue"].text.text = title_cfg.maxhp

	local title_info = TitleData.Instance:GetTitleInfoByTitleId(self.current_title_id)
	local desc = title_cfg.desc or ""
	local name = title_cfg.name or ""
	self.node_list["TxtDescribe"].text.text = desc
	self.node_list["TxtTitleName"].text.text = name
	self.node_list["TxtTimeLimite"].text.text = title_cfg.time_show or ""

	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = CommonDataManager.GetCapabilityCalculation(title_cfg)
	end
	self.node_list["TxtFightPowerNumber2"].text.text = CommonDataManager.GetCapabilityCalculation(title_cfg)
end

function PlayerTitleView:UpdateTitleTimeLimite(activity_id)
	local activity_info = ActivityData.Instance:GetClockActivityByID(activity_id)
	if activity_info == nil or next(activity_info) == nil or activity_info.open_day == nil then return end
	local open_day_list = Split(activity_info.open_day, ":")

	local time_str = ""
	local str = Language.Common.Week
	for i = 1, #open_day_list do
		local day = tonumber(open_day_list[i])
		day = Language.Common.DayToChs[day] or ""
		str = str .. day
		if i ~= #open_day_list then
			str = str .. "、"
		end
	end
	
	time_str = str .. Language.Role.TitleRecycle
	self.node_list["TxtTimeLimite"].text.text = time_str
end

function PlayerTitleView:TitleCountDown(elapse_time, total_time)
	if elapse_time < total_time then
		self.node_list["TxtTimeLimite"].text.text = TimeUtil.FormatSecond2DHMS(total_time - elapse_time, 1)
	end
end

function PlayerTitleView:TitleComplereFun()
	self:UpdateAttribute()
end

function PlayerTitleView:SetUiTitle(ui_title_res)
	self.ui_title_res = ui_title_res
	self:FlushTitle()
end

function PlayerTitleView:FlushTitle()
	local bundle, asset = ResPath.GetTitleIcon(self.current_title_id)
	self.node_list["TxtTitle"].image:LoadSprite(bundle, asset .. ".png")
	self.node_list["TxtTitle"]:SetActive(false)

	TitleData.Instance:LoadTitleEff(self.node_list["TxtTitle"], self.current_title_id, true)

	self.node_list["RedPoint"]:SetActive(TitleData.Instance:IsShowJinjieRedPoint())
end

function PlayerTitleView:SetAllAttributeFalse()
	self.node_list["all_attribute_contain"]:SetActive(true)
end

function PlayerTitleView:ChangeBtnState()
	local title_data = TitleData.Instance
	local cur_adron_id = title_data:GetUsedTitle()
	self.node_list["BntAdron"]:SetActive(self.current_title_id ~= cur_adron_id)
	self.node_list["BtnUnwield"]:SetActive(self.current_title_id == cur_adron_id)
	-- UI:SetGraphicGrey(self.node_list["BntAdron"], not (title_data:GetTitleActiveState(self.current_title_id)))
	UI:SetButtonEnabled(self.node_list["BntAdron"], title_data:GetTitleActiveState(self.current_title_id))
end

function PlayerTitleView:OnFlush()
	self.title_id_list = TitleData.Instance:ResortTitleIdListByIsTeShu(self.is_teshu)
	self:ChangeBtnState()
	self:FlushTitle()
	self:FlushAllHL()
	self:UpdateAttribute()
	if self.node_list["list_view"].scroller.isActiveAndEnabled then
		self.node_list["list_view"].scroller:RefreshActiveCellViews()
	end
	local buff_cfg_list = TitleData.Instance:GetTitleAddBuffList(self.current_title_id)
	for i = 1, 3 do
		self.node_list["TxtBuffContent" .. i] = string.format("+%s%%",  buff_cfg_list[i] / 100)
		self.node_list["BuffContent" .. i]:SetActive(buff_cfg_list[i] ~= 0)
	end
end

function PlayerTitleView:FlushAllHL()
	for k,v in pairs(self.title_contain_list) do
		v:FlushHL()
	end
end

function PlayerTitleView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["LeftView"], PlayerData.TweenPosition.Left , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["BtnJinJie"], PlayerData.TweenPosition.Up , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["RightContent"], PlayerData.TweenPosition.Right , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end

--------------------------------------------------------------------------
--TitleContain 		称号容器
--------------------------------------------------------------------------

TitleContain = TitleContain  or BaseClass(BaseCell)

function TitleContain:__init()

	self.title_cell_list = {}
	for i = 1, 1 do
		self.title_cell_list[i] = TitleCell.New(self.node_list["TitleContent" .. i])
	end

end

function TitleContain:__delete()
	for i = 1, 1 do
		self.title_cell_list[i]:DeleteMe()
	end
	self.title_cell_list = {}
end

function TitleContain:OnFlush()
	for i = 1, 1 do
		self.title_cell_list[i]:SetData(self.data[i])
	end
end

function TitleContain:SetToggleGroup(toggle_group)
	for i = 1, 1 do
		self.title_cell_list[i]:SetToggleGroup(toggle_group)
	end
end

function TitleContain:FlushHL()
	for i = 1, 1 do
		self.title_cell_list[i]:FlushHL()
	end
end
----------------------------------------------------------------------------
--TitleCell 		称号滚动条格子
----------------------------------------------------------------------------

TitleCell = TitleCell or BaseClass(BaseCell)

function TitleCell:__init()
	self.cell_toggle = self.root_node.toggle
	self.cell_toggle:AddValueChangedListener(BindTool.Bind(self.TitleOnClick, self))
	self.adorn_go = self.node_list["adorn_go"]

end

function TitleCell:__delete()
	TitleData.Instance:ReleaseTitleEff(self.node_list["ImgTitleIcon"])
end

function TitleCell:OnFlush()
	self.root_node:SetActive(true)
	local title_cfg = TitleData.Instance:GetTitleCfg(self.data)
	if nil == self.data then
		self.root_node:SetActive(false)
		return
	end
	self.adorn_go:SetActive(TitleData.Instance:GetIsUsed(self.data))
	self:FlushHL()
	local bundle, asset = ResPath.GetTitleIcon(self.data)
	self.node_list["ImgTitleIcon"].image:LoadSprite(bundle, asset .. ".png")
	local is_active = TitleData.Instance:GetTitleActiveState(self.data)
	local title_info = TitleData.Instance:GetTitleInfo()

	TitleData.Instance:LoadTitleEff(self.node_list["ImgTitleIcon"], self.data, is_active)

	self.node_list["TxtRemianTime"].text.text = ""
	UI:SetGraphicGrey(self.node_list["ImgTitleIcon"],not is_active)
	self.expired_time = 0
end

function TitleCell:TitleOnClick(is_click)
	-- if is_click then
		local title_view = PlayerCtrl.Instance:GetTitleView()
		if title_view and title_view:GetCurrentId() ~= self.data then
			title_view:SetCurrentId(self.data)
		end
	-- end
end

function TitleCell:FlushHL()
	local title_view = PlayerCtrl.Instance:GetTitleView()
	if title_view then
		self.node_list["ImgHighLight"]:SetActive(self.data == title_view:GetCurrentId())
	end
end

function TitleCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end
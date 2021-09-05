PefectLoverView = PefectLoverView or BaseClass(BaseView)

function PefectLoverView:__init()
	self.ui_config = {{"uis/views/marryme_prefab", "PerfectLoverView"}}
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.is_modal = true
end

function PefectLoverView:__delete()

end

function PefectLoverView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["BtnJiHuan"].button:AddClickListener(BindTool.Bind(self.GoToMarryClick, self))
	self.node_list["BtnImage"].button:AddClickListener(BindTool.Bind(self.OnClickSanShenSanShi, self))
	self.cell_list = {}
	self:InitScroller()
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtCount"])
	local item_id = PefectLoverData.Instance:GetTitleItemId()[0].item_id
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg then
		local title_id = item_cfg.param1
		self.node_list["TxtTitle"].image:LoadSprite(ResPath.GetTitleHightIcon(title_id))
		local title_cfg = TitleData.Instance:GetTitleCfg(title_id) or {}
		local title_fp = CommonDataManager.GetCapability(title_cfg) or 0
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = title_fp
		end
	end
end

function PefectLoverView:ReleaseCallBack()
	self.fight_text = nil
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function PefectLoverView:OnClickSanShenSanShi()
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SAN_SHENG_SAN_SHI) then
		ViewManager.Instance:Open(ViewName.KaifuActivityView, 47)
	end
end

function PefectLoverView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SAN_SHENG_SAN_SHI, RA_PERFECT_OPERA_TYPE.RA_MARRYME_REQ_INFO)
	self:FlushRestTime()
	self:RemoveCountDown()
	self.count_down = CountDown.Instance:AddCountDown(99999999, 1, BindTool.Bind(self.FlushRestTime, self))

	-- local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	-- if cur_day > -1 then
	-- 	PlayerPrefsUtil.SetInt("marryme_remind_day", cur_day)
	-- 	RemindManager.Instance:Fire(RemindName.MarryMe)
	-- end
end

function PefectLoverView:CloseCallBack()
	self:RemoveCountDown()
end

function PefectLoverView:RemoveCountDown()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function PefectLoverView:OnClickClose()
	self:Close()
end

--是否已婚
function PefectLoverView:CheckIsMarry()
	return MarriageData.Instance:CheckIsMarry()
end

--前往结婚
function PefectLoverView:GoToMarryClick()
	local is_open, tips = OpenFunData.Instance:CheckIsHide("marriage")
	if not is_open then
		if tips then
			SysMsgCtrl.Instance:ErrorRemind(tips)
			return
		end
	end
	self:Close()
	TipsCtrl.Instance:ShowCommonTip(BindTool.Bind(self.GoToMarryNpc, self), nil, Language.Marriage.GoToMarryTip[1])

end

--前往月老
function PefectLoverView:GoToMarryNpc()
	local cfg = MarriageData.Instance:GetMarriageConditions()
	if nil == cfg then return end
	local npc_info = MarryMeData.Instance:GetNpcInfo(cfg.marry_npc_scene_id, cfg.marry_npc_id)
	if npc_info then
		local callback = function()
			MoveCache.end_type = MoveEndType.NpcTask
			MoveCache.param1 = cfg.marry_npc_id
			GuajiCtrl.Instance:MoveToPos(cfg.marry_npc_scene_id, npc_info.x, npc_info.y, 1, 1, false)
		end
		callback()
		GuajiCtrl.Instance:SetMoveToPosCallBack(callback)
	end
	ViewManager.Instance:Close(ViewName.Marriage)
end



function PefectLoverView:OnFlush()
	local my_rank = PefectLoverData.Instance:GetMyRankInfo()
	local lover_name = PefectLoverData.Instance:GetLoverNameInfo()
	if self:CheckIsMarry() then
		self.node_list["MyLoveName"].text.text = GameVoManager.Instance:GetMainRoleVo().lover_name or ""
	else
		self.node_list["MyLoveName"].text.text = Language.Common.No
	end
	if my_rank > 0 then
		self.node_list["Myrank"].text.text = my_rank
			else
		self.node_list["Myrank"].text.text = Language.Common.No
	end
	local primary_maryy = PefectLoverData.Instance:GetSelfActiveCfg(0)
	local midlevel_maryy = PefectLoverData.Instance:GetSelfActiveCfg(1)
	local advanced_maryy = PefectLoverData.Instance:GetSelfActiveCfg(2)
	self.node_list['Yes0']:SetActive(primary_maryy)
	self.node_list['Yes1']:SetActive(midlevel_maryy)
	self.node_list['Yes2']:SetActive(advanced_maryy)
	self.node_list["Scroller"].scroller:RefreshAndReloadActiveCellViews(false)
	-- if primary_maryy and midlevel_maryy and advanced_maryy then
	-- 	UI:SetButtonEnabled(self.node_list["BtnJiHuan"], false)
	-- 	self.node_list["GotoText"].text.text = Language.Common.YiHuoDe
	-- else
	-- 	UI:SetButtonEnabled(self.node_list["BtnJiHuan"], true)
	-- 	self.node_list["GotoText"].text.text = Language.Marriage.Go_To_Marry
	-- end
end

function PefectLoverView:FlushRestTime()
	local rest_time = 0
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SAN_SHENG_SAN_SHI) then
		rest_time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SAN_SHENG_SAN_SHI) or 0
	end
	if rest_time <= 0 then
		self.node_list["TxtTime"].text.text = string.format(Language.MarryMe.ActPerfectLoveTime, 0, 0, 0)
		self:RemoveCountDown()
		return
	end
	local time_tab = TimeUtil.Format2TableDHM(rest_time)
	if time_tab then
		self.node_list["TxtTime"].text.text = string.format(Language.MarryMe.ActPerfectLoveTime, time_tab.day, time_tab.hour, time_tab.min)
	end
end

function PefectLoverView:InitScroller()
	local scroller_delegate = self.node_list["Scroller"].list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetMaxCellNum, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCellList, self)
end

function PefectLoverView:GetMaxCellNum()
	return #PefectLoverData.Instance:GetRankInfo()
end

function PefectLoverView:RefreshCellList(cell,data_index,cell_index)
	local info_cell = self.cell_list[cell]
	if info_cell == nil then
		info_cell = PerfectInfoCell.New(cell.gameObject)
		-- info_cell:SetClickCallBack(BindTool.Bind(self.OnClickItemCallBack, self))
		self.cell_list[cell] = info_cell
	end
	local data_list = PefectLoverData.Instance:GetRankInfo()
	if data_list then
		info_cell:SetData(data_list[data_index + 1])
		info_cell:SetIndex(cell_index)
		info_cell:SetRank(cell_index)
	end
end

function PefectLoverView:OnClickItemCallBack(cell, select_index)
	if cell == nil or cell.data == nil then return end
	local select_data = cell.index
	PefectLoverData.Instance:SetPecfectLoveSeq(select_data)
	for k, v in pairs(self.cell_list) do
		v:ChangeHightLight()
	end
end

-----------------------------PerfectInfoCell---------------------------------------------
PerfectInfoCell = PerfectInfoCell or BaseClass(BaseCell)
function PerfectInfoCell:__init()
	self.rank = 0
	-- self.node_list["PerfectloveItem"].toggle:AddClickListener(BindTool.Bind(self.OnClickItemCallBack, self))
end

function PerfectInfoCell:__delete()

end

-- function PerfectInfoCell:OnClickItemCallBack()
-- 	if nil ~= self.click_callback then
-- 		self.click_callback(self)
-- 	end
-- end

function PerfectInfoCell:SetRank(rank)
	self.rank = rank + 1 
	if self.rank > 3 then
		self.node_list["RankText"].text.text = self.rank
		self.node_list["RankImage"]:SetActive(false)
	else
		self.node_list["RankImage"]:SetActive(true)
		local bundle, asset = ResPath.GetNewRankIcon(self.rank)
		self.node_list["RankImage"].image:LoadSprite(bundle, asset, function()
			self.node_list["RankImage"].image:SetNativeSize()
		end)
	end
	local my_rank = PefectLoverData.Instance:GetMyRankInfo()
	if self.rank == my_rank then
		self.node_list["HightLight"]:SetActive(true)
	else
		self.node_list["HightLight"]:SetActive(false)
	end
end

function PerfectInfoCell:OnFlush()
	if self.data then
			self.node_list["TxtMaleName"].text.text = self.data.accept_proposal_name
			self.node_list["TxtFemaleName"].text.text = self.data.propose_name
	end
	-- self:ChangeHightLight()
end

-- function PerfectInfoCell:ChangeHightLight()
-- 	self.node_list["HightLight"]:SetActive(self.index == PefectLoverData.Instance:GetPecfectLoveSeq())
-- end
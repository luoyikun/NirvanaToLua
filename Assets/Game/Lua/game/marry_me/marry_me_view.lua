MarryMeView = MarryMeView or BaseClass(BaseView)


-- 最大
local MAX_NUM = 3

function MarryMeView:__init()
	self.ui_config = {{"uis/views/marryme_prefab", "MarryMeView"}}
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.is_modal = true
end

function MarryMeView:__delete()

end

function MarryMeView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["BtnJiHuan"].button:AddClickListener(BindTool.Bind(self.GoToMarryClick, self))
	self.node_list["BtnImage"].button:AddClickListener(BindTool.Bind(self.OnClickSanShenSanShi, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtCount"])
	local config = KaifuActivityData.Instance:GetMarryMeCfg()[1]
	if config then
		self.node_list["TxtNumber"].text.text = config.couple_count
		local title_id = config.title_id
		self.node_list["TxtTitle"].image:LoadSprite(ResPath.GetTitleHightIcon(title_id))
		--TitleData.Instance:LoadTitleEff(self.node_list["TxtTitle"], title_id, true)
		local title_cfg = TitleData.Instance:GetTitleCfg(title_id) or {}
		local title_fp = CommonDataManager.GetCapability(title_cfg) or 0
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = title_fp
		end
	end

	local open_cfg = KaifuActivityData.Instance:GetKaifuActivityOpenCfg()
	if open_cfg then
		for k,v in pairs(open_cfg) do
			if v.activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MARRY_ME then
				self.cfg = v
				break
			end
		end
	end
end

function MarryMeView:ReleaseCallBack()
	self.fight_text = nil
end

function MarryMeView:OnClickSanShenSanShi()
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SAN_SHENG_SAN_SHI) then
		ViewManager.Instance:Open(ViewName.KaifuActivityView, 47)
	end
end

function MarryMeView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MARRY_ME, RA_MARRYME_OPERA_TYPE.RA_MARRYME_REQ_INFO)
	self:FlushRestTime()
	self:RemoveCountDown()
	self.count_down = CountDown.Instance:AddCountDown(99999999, 1, BindTool.Bind(self.FlushRestTime, self))

	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if cur_day > -1 then
		PlayerPrefsUtil.SetInt("marryme_remind_day", cur_day)
		RemindManager.Instance:Fire(RemindName.MarryMe)
	end
end

function MarryMeView:CloseCallBack()
	self:RemoveCountDown()
end

function MarryMeView:RemoveCountDown()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function MarryMeView:OnClickClose()
	self:Close()
end

-- function MarryMeView:OnClickMarry()
-- 	local is_open, tips = OpenFunData.Instance:CheckIsHide("marriage")
-- 	if is_open then
-- 		self:Close()
-- 		ViewManager.Instance:Open(ViewName.Wedding)
-- 	else
-- 		if tips then
-- 			SysMsgCtrl.Instance:ErrorRemind(tips)
-- 		end
-- 	end
-- end

--是否已婚
function MarryMeView:CheckIsMarry()
	return MarriageData.Instance:CheckIsMarry()
end

--前往结婚
function MarryMeView:GoToMarryClick()
	local is_open, tips = OpenFunData.Instance:CheckIsHide("marriage")
	if not is_open then
		if tips then
			SysMsgCtrl.Instance:ErrorRemind(tips)
			return
		end
	end

	if self:CheckIsMarry() then
		if not ScoietyData.Instance:GetTeamState() then
			local param_t = {}
			param_t.must_check = 0
			param_t.assign_mode = 1
			ScoietyCtrl.Instance:CreateTeamReq(param_t)
		end
		ScoietyCtrl.Instance:InviteUserReq(GameVoManager.Instance:GetMainRoleVo().lover_uid)
	else
		-- ViewManager.Instance:Open(ViewName.Wedding)
		self:Close()
		TipsCtrl.Instance:ShowCommonTip(BindTool.Bind(self.GoToMarryNpc, self), nil, Language.Marriage.GoToMarryTip[1])
	end
end

--前往月老
function MarryMeView:GoToMarryNpc()
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



function MarryMeView:OnFlush()
	local now_pro = self:GetTheProgress()
	self.node_list["JinDuTxt"].text.text = string.format(Language.Activity.NowProgress, now_pro, MAX_NUM)
end


function MarryMeView:GetTheProgress()
	local info = KaifuActivityData.Instance:GetPerfectLoverInfo()
	local count = 0
	if info then
		local bit_list = bit:d2b(info.perfect_lover_type_record_flag)
		for i = 1 , MAX_NUM do
			local is_reach = bit_list[32 - (i - 1)] == 1
			if is_reach then
				count = count + 1
			end
		end
	end
	return count
end

function MarryMeView:FlushRestTime()
	local rest_time = 0
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.MARRY_ME) then
		rest_time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.MARRY_ME) or 0
	end
	if rest_time <= 0 then
		self.node_list["TxtTime"].text.text = string.format(Language.MarryMe.ActivityTime, 0, 0, 0)
		self:RemoveCountDown()
		return
	end
	local time_tab = TimeUtil.Format2TableDHM(rest_time)
	if time_tab then
		self.node_list["TxtTime"].text.text = string.format(Language.MarryMe.ActivityTime, time_tab.day, time_tab.hour, time_tab.min)
	end
end

function MarryMeView:InitScroller()
	local scroller_delegate = self.scroller.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetMaxCellNum, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCellList, self)
end

function MarryMeView:GetMaxCellNum()
	local num = 0
	local info = MarryMeData.Instance:GetInfo()
	if info then
		num = #info.couple_list
	end
	return num
end

function MarryMeView:RefreshCellList(cell, data_index)
	local info_cell = self.cell_list[cell]
	if info_cell == nil then
		info_cell = MarryMeInfoCell.New(cell.gameObject)
		self.cell_list[cell] = info_cell
	end
	local info = MarryMeData.Instance:GetInfo()
	if info then
		local couple_list = info.couple_list or {}
		info_cell:SetData(couple_list[data_index + 1])
	end
end

-----------------------------MarryMeInfoCell---------------------------------------------
MarryMeInfoCell = MarryMeInfoCell or BaseClass(BaseCell)
function MarryMeInfoCell:__init()

end

function MarryMeInfoCell:__delete()

end

function MarryMeInfoCell:OnFlush()
	if self.data then
		if self.data.proposer_sex == GameEnum.MALE then
			self.node_list["TxtMaleName"].text.text = self.data.propose_name
			self.node_list["TxtFemaleName"].text.text = self.data.accept_proposal_name
		else
			self.node_list["TxtMaleName"].text.text = self.data.accept_proposal_name
			self.node_list["TxtFemaleName"].text.text = self.data.propose_name
		end
	end
end
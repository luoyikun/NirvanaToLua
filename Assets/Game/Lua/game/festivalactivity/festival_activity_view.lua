require("game/festivalactivity/festival_activity_rank/festival_activity_chuiqiqiu_rank")
require("game/festivalactivity/festival_activity_rank/festival_activity_fangfeiqiqiu_rank")
require("game/festivalactivity/festival_activity_sanbao/festivity_activity_sanbao_view")
require("game/festivalactivity/festival_single_party/festival_single_party_view")
require("game/festivalactivity/festival_activity_taozhuang_view")
require("game/festivalactivity/festival_activity_extreme_challenge/extreme_challenge_view")
require("game/festivalactivity/festival_activity_leichong/festival_activity_leichong_view")
require("game/festivalactivity/festival_activity_crazy_hi_celebration/crazy_hi_celebration_view")
require("game/festivalactivity/christmagift/christmagift_view")

local FST_NODE_NAME_LIST = {
	[1] = "LianXuChongZhi",
	[2] = "MakeMoonCakeContent",
	[3] = "AutumnHappyErnieContent",
	[4] = "DailyGiftView",
	[5] = "HappyDanBiChongZhi",
	[6] = "LoginRewardContent",
	-- [7] = "DailyDanBi",
	[8] = "ChuiQiQiuRankContent",
	[9] = "FangFeiQiQiuRankContent",
	[10] = "FesThreePirceView",
	[11] = "FestivalSinglePartyContent",
	[12] = "Festivalequipment",
	[13] = "ExtremeChallengeView",
	[14] = "FestivalLeiChongView",
	[15] = "DayBianShenRank",
	[16] = "DayBeiBianShenRank",
	[17] = "CrazyHiCelebrationView",
	[18] = "ChristmaGiftView"
}

local FESTIVAL_NAME_LIST = {
	[1] = LianXuChongZhi,
	[2] = MakeMoonCakeView,
	[3] = AutumnHappyErnieView,
	[4] = DailyGiftView,
	[5] = DanBiChongZhiView,
	[6] = ActivityPanelLogicRewardView,
	-- [7] = OpenActDailyDanBi,
	[8] = ChuiQiQiuRank,
	[9] = FangFeiQiQiuRank,
	[10] = VersionThreePieceView,
	[11] = FestivalSinglePartyView,
	[12] = FestivalequipmentView,
	[13] = ExtremeChallengeView,
	[14] = FestivalLeiChongView,
	[15] = BianShenRank,
	[16] = BeiBianShenRank,
	[17] = CrazyHiCelebrationView,
	[18] = ChristmaGiftView,
}

FestivalActivityView = FestivalActivityView or BaseClass(BaseView)
-- 现在开服活动跟合服活动公用这个面板
function FestivalActivityView:__init()
	self.ui_config = {
		{"uis/views/festivalactivity/childpanel_prefab", "KaiFuAcitivityPanel_1"},

		{"uis/views/festivalactivity/childpanel_prefab", "NodeBackground1"},
		{"uis/views/festivalactivity/childpanel_prefab", "LeftToggleGroup1"},

		
		{"uis/views/kaifuactivity/childpanel_prefab", FST_NODE_NAME_LIST[1], {1}},
		{"uis/views/kaifuactivity/childpanel_prefab", FST_NODE_NAME_LIST[2], {2}},
		{"uis/views/kaifuactivity/childpanel_prefab", FST_NODE_NAME_LIST[3], {3}},
		{"uis/views/kaifuactivity/childpanel_prefab", FST_NODE_NAME_LIST[4], {4}},
		{"uis/views/kaifuactivity/childpanel_prefab", FST_NODE_NAME_LIST[5], {5}},
		{"uis/views/kaifuactivity/childpanel_prefab", FST_NODE_NAME_LIST[6], {6}},
		-- {"uis/views/kaifuactivity/childpanel_prefab", FST_NODE_NAME_LIST[7], {7}},
		{"uis/views/festivalactivity/childpanel_prefab", FST_NODE_NAME_LIST[8], {8}},
		{"uis/views/festivalactivity/childpanel_prefab", FST_NODE_NAME_LIST[9], {9}},	
		{"uis/views/festivalactivity/childpanel_prefab", FST_NODE_NAME_LIST[10], {10}},
		{"uis/views/festivalactivity/childpanel_prefab", FST_NODE_NAME_LIST[11], {11}},
		{"uis/views/festivalactivity/childpanel_prefab", FST_NODE_NAME_LIST[12], {12}},
		{"uis/views/festivalactivity/childpanel_prefab", FST_NODE_NAME_LIST[13], {13}},
		{"uis/views/festivalactivity/childpanel_prefab", FST_NODE_NAME_LIST[14], {14}},
		{"uis/views/kaifuactivity/childpanel_prefab", FST_NODE_NAME_LIST[15], {15}},
		{"uis/views/kaifuactivity/childpanel_prefab", FST_NODE_NAME_LIST[16], {16}},
		{"uis/views/kaifuactivity/childpanel_prefab", FST_NODE_NAME_LIST[17], {17}},
		{"uis/views/kaifuactivity/childpanel_prefab", FST_NODE_NAME_LIST[18], {18}},

		-- {"uis/views/festivalactivity/childpanel_prefab", "KaiFuAcitivityPanel_2"},
	}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp

	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.cur_index = 1
	self.cell_list = {}
	self.panel_list = {}
	self.panel_obj_list = {}
end

function FestivalActivityView:__delete()
	
end

function FestivalActivityView:ReleaseCallBack()
	for k, v in pairs(self.panel_list) do
		v:DeleteMe()
	end
	self.panel_list = {}
	self.cur_index = 1
	self.cur_type = 0
	self.panel_obj_list = {}
end

function FestivalActivityView:LoadCallBack()
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.cur_type = 0
	self.last_type = 0

	local list_delegate = self.node_list["ScrollerToggleGroup"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	local list = FestivalActivityData.Instance:GetOpenActivityList()
	-- if list and  next(list) then
	-- 	self.cur_type = list[1].activity_type
	-- end
	self.cur_type = - 1
	self:Flush()

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.FestivalActivityView, BindTool.Bind(self.GetUiCallBack, self))

end

function FestivalActivityView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
end
function FestivalActivityView:GetNumberOfCells()
	self.cur_tab_list_length = #FestivalActivityData.Instance:GetOpenActivityList()
	return self.cur_tab_list_length
end

function FestivalActivityView:RefreshCell(cell, data_index)
	local list = FestivalActivityData.Instance:GetOpenActivityList()
	if not list or not next(list) then return end
	local activity_type = list[data_index + 1] and list[data_index + 1].activity_type or list[data_index + 1].sub_type or 0
	local activity_name = list[data_index + 1].name
	local data = {}
	data.activity_type = activity_type
	data.name = activity_name
	local tab_btn = self.cell_list[cell]
	if tab_btn == nil then
		tab_btn = LeftTableButton.New(cell.gameObject)
		self.cell_list[cell] = tab_btn
	end
	tab_btn:SetToggleGroup(self.node_list["ScrollerToggleGroup"].toggle_group)
	tab_btn:SetHighLight(self.cur_type == activity_type)

	tab_btn:AddClickCallback(BindTool.Bind(self.OnClickTabButton, self, activity_type, data_index + 1))

	data.is_show = false
	data.is_show_effect = false
	data.is_show_btn_eff = false
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EVERYDAY_NICE_GIFT then				-- 每日好礼
		data.is_show = KaifuActivityData.Instance:DailyGiftRedPoint() > 0
	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVEIY_TYPE_LIANXUCHONGZHI then				-- 连续充值
		data.is_show = KaifuActivityData.Instance:IsShowRedPoint() > 0
	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAKE_MOONCAKE then					--集月饼活动(单身伴侣)
		data.is_show = KaifuActivityData.Instance:IsMakeMoonCakeRemind() > 0
	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_YAOJIANG2 then				-- 疯狂摇奖
		data.is_show = KaifuActivityData.Instance:GetHappyErnieRemind() > 0
	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOGIN_GIFT then					-- 登录豪礼
		data.is_show = ActivityPanelLoginRewardData.Instance:GetLoginGiftRemind0() > 0
	-- elseif activity_type == ACTIVITY_TYPE.RAND_DAY_DANBI_CHONGZHI then							-- 充值返利
	-- 	data.is_show = KaifuActivityData.Instance:IsDailyDanBiRedPoint()
	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXTREME_CHALLENGE then				-- 极限挑战
		data.is_show = FestivalActivityData.Instance:IsShowExtremeChallengeRemind() > 0
	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_VERSIONS_GRAND_TOTAL_CHARGE then	-- 累计充值
		data.is_show = FestivalActivityData.Instance:IsShowVesLeiChongRedPoint() > 0
	-- elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SPECIAL_APPEARANCE_RANK then
	-- 	data.is_show = FestivalActivityData.Instance:IsShowVesLeiChongRedPoint() > 0
	-- elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SPECIAL_APPEARANCE_PASSIVE_RANK then
	-- 	data.is_show = FestivalActivityData.Instance:IsShowVesLeiChongRedPoint() > 0
	elseif activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_KUANG_HAI_QING_DIAN then			-- 狂嗨庆典
		data.is_show = CrazyHiCelebrationData.Instance:CrazyHiCelebrationRedPoint() > 0
	end

	tab_btn:SetData(data)
end

function FestivalActivityView:OnClickTabButton(activity_type, index)
	if self.cur_type == activity_type then
		return
	end
	self.last_type = self.cur_type
	self.cur_type = activity_type
	self.cur_index = index
	FestivalActivityData.Instance:SetSelect(self.cur_index)

	self:ChangeToIndex(FestivalActivityData.Instance:GetActivityTypeToIndex(self.cur_type))
	-- self:OpenPanel()
	--self:CloseChildPanel()
	self:Flush()
end

function FestivalActivityView:ShowIndexCallBack(index, index_nodes)
	self.node_list["Decorate"]:SetActive(true)
	self.cur_type = FestivalActivityData.Instance:GetActivityTypeByIndex(index)
	
	-- 打开界面时发送请求当前页面信息
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_VERSIONS_CONTINUE_CHARGE) then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_VERSIONS_CONTINUE_CHARGE, RA_VERSION_CONTINUE_CHONGZHI_OPERA_TYPE.RA_VERSION_CONTINUE_CHONGZHI_OPERA_TYPE_QUERY_INFO)
	end
	
	-- if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_DAY_DANBI_CHONGZHI) then
	-- 	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_DAY_DANBI_CHONGZHI, RA_DANBI_CHONGZHI_OPERA_TYPE.RA_DANBI_CHONGZHI_OPERA_TYPE_QUERY_INFO)
	-- end

	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_VERSIONS_GRAND_TOTAL_CHARGE) then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_VERSIONS_GRAND_TOTAL_CHARGE, RA_VERSION_TOTAL_CHARGE_OPERA_TYPE.RA_VERSION_TOTAL_CHARGE_OPERA_TYPE_QUERY_INFO)
	end

	--吉祥三宝
	if ActivityData.Instance:GetActivityIsOpen(FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_TOTAL_CHARGE_FIVE) then
		FestivalActivityCtrl.Instance:SendGetSanBaoActivityInfo(FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_VERSIONS_GRAND_TOTAL_CHARGE, 
		RA_VERSION_TOTAL_CHARGE_OPERA_TYPE.RA_VERSION_TOTAL_CHARGE_OPERA_TYPE_QUERY_INFO)
	end
	


	if index_nodes then
		local prefab_name = FST_NODE_NAME_LIST[index]
		self.panel_obj_list[index] = index_nodes[prefab_name]
		self.panel_list[index] = FESTIVAL_NAME_LIST[index].New(self.panel_obj_list[index])
	end
		
	if self.panel_list[index] and self.panel_list[index].OpenCallBack then
		self.panel_list[index]:OpenCallBack()
	end
	local list = FestivalActivityData.Instance:GetOpenActivityList()
	for k,v in pairs(list) do
		if v.activity_type == self.cur_type then
			self.cur_index = k
		end
	end
	if self.cur_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_VERSIONS_GRAND_TOTAL_CHARGE or self.cur_type == FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_TOTAL_CHARGE_FIVE then
		self.node_list["Decorate"]:SetActive(false)
	end
	self:Flush()
end

function FestivalActivityView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SPECIAL_APPEARANCE_RANK, 0)
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SPECIAL_APPEARANCE_PASSIVE_RANK, 0)
	self.node_list["ScrollerToggleGroup"].scroller:ReloadData(0)
end

function FestivalActivityView:CloseCallBack()
	self.last_type = self.cur_type
	self.cur_day = nil
	self.cur_index = 1
	self.cur_tab_list_length = 0
end

function FestivalActivityView:RemindChangeCallBack(remind_name, num)
	self:Flush()
end


function FestivalActivityView:OnFlush(param_t)
	local list = FestivalActivityData.Instance:GetOpenActivityList()
	if list and next(list) then
		--RemindManager.Instance:Fire(RemindName.Festival_Act)
		self:FlushLeftTabListView(list, param_t)
		self:FlushRightPanel(list, param_t)
	end
end

function FestivalActivityView:FlushRightPanel(list, param_t)
	local panel_index = self:ShowWhichPanelByType(self.cur_type) or 0
	if self.panel_list[panel_index] then
		self.panel_list[panel_index]:Flush(self.cur_type)
		if self.panel_list[panel_index].FlushView then
			self.panel_list[panel_index]:FlushView()
		end
	end
end
function FestivalActivityView:ShowWhichPanelByType(activity_type)
	if activity_type == nil then return nil end
	return FestivalActivityData.Instance:GetActivityTypeToIndex(activity_type)
end


function FestivalActivityView:FlushLeftTabListView(list, param_t)
	if list == nil or next(list) == nil then return end
	if self.node_list["ScrollerToggleGroup"].scroller.isActiveAndEnabled then
		if not list[self.cur_index] or (self.cur_type ~= list[self.cur_index].activity_type) then
			self.cur_index = 1
			self.cur_type = list[1] and list[1].activity_type or list[1].sub_type or 0
		end
		self.node_list["ScrollerToggleGroup"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end


--连续充值
function FestivalActivityView:FlushLianXuChongZhi()
	if self.panel_list[1] then
		self.panel_list[1]:Flush()
	end
end

function FestivalActivityView:FlushMakeMoonCake()
	if self.panel_list[2] then
		self.panel_list[2]:Flush()
	end
end

function FestivalActivityView:FlushFengKuangYaoJiang()
	if self.panel_list[3] then
		self.panel_list[3]:Flush()
	end
end

function FestivalActivityView:FlushDailyGiftView()
	if self.panel_list[4] then
		self.panel_list[4]:Flush()
	end
end

function FestivalActivityView:FlushHappyDanBiChongZhi()
	if self.panel_list[5] then
		self.panel_list[5]:Flush()
	end
end

--登录豪礼
function FestivalActivityView:FlushLoginReward()
	if self.panel_list[6] then
		self.panel_list[6]:Flush()
	end
end

function FestivalActivityView:FlushDailyDanBi()
	-- if self.panel_list[7] then
	-- 	self.panel_list[7]:Flush()
	-- end
end

function FestivalActivityView:FlushChuiQiQiuRank()
	if self.panel_list[8] then
		self.panel_list[8]:Flush()
	end
end

function FestivalActivityView:FlushFangFeiQiQiuRank()
	if self.panel_list[9] then
		self.panel_list[9]:Flush()
	end
end


function FestivalActivityView:FlushVersionThreePiece()
	if self.panel_list[10] then
		self.panel_list[10]:Flush()
	end
end

function FestivalActivityView:FlushFestivalSingleParty()
	if self.panel_list[11] then
		self.panel_list[11]:Flush()
	end
end

function FestivalActivityView:FlushExtremeChallenge()
	if self.panel_list[13] then
		self.panel_list[13]:Flush()
	end
end

function FestivalActivityView:FlushBanBenLeiChong()
	if self.panel_list[14] then
		self.panel_list[14]:Flush()
	end
end

-- 刷新狂嗨庆典
function FestivalActivityView:FlushCrazyHiCelebrationView()
	if self.panel_list[17] then
		self.panel_list[17]:Flush()
	end
end

-- 刷新礼物收割
function FestivalActivityView:FlushChristmaGiftView()
	if self.panel_list[18] then
		self.panel_list[18]:Flush()
	end
end

function FestivalActivityView:CloseChildPanel()
	if self.cur_type == self.last_type then
		return
	end

	local panel = self.combine_panel_list[self.last_type]

	if nil == panel then
		return
	end
	if panel.CloseCallBack then
		panel:CloseCallBack()
	end
end

LeftTableButton = LeftTableButton or BaseClass(BaseRender)

function LeftTableButton:__init(instance)

end

function LeftTableButton:SetData(data)
	if data == nil then return end
	self.data = data
	self.node_list["TxtLight"].text.text = data.name
	self.node_list["TxtHighLight"].text.text = data.name
	self.node_list["ImgRedPoint"]:SetActive(data.is_show)
	self.node_list["EffectInBtn"]:SetActive(data.is_show_btn_eff or false)
	self.node_list["ImgFlag"]:SetActive(data.is_show_effect or false)

end

function LeftTableButton:GetData()
	return self.data
end

function LeftTableButton:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function LeftTableButton:SetHighLight(enable)
	self.root_node.toggle.isOn = enable
end

function LeftTableButton:AddClickCallback(click_callback)
	self.node_list["TabButton"].toggle:AddClickListener(click_callback)
end



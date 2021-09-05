require("game/kuafu_1v1/kuafu1v1_view_main")
require("game/kuafu_1v1/kuafu1v1_view_season")
require("game/kuafu_1v1/kuafu1v1_view_rank")
require("game/kuafu_1v1/kuafu1v1_view_gongxun")


Kuafu1V1View = Kuafu1V1View or BaseClass(BaseView)

function Kuafu1V1View:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel"},
		{"uis/views/kuafu1v1_prefab", "MainPanel", {TabIndex.kuafu1v1_pipei}},
		{"uis/views/kuafu1v1_prefab", "GongXunView", {TabIndex.kuafu1v1_gongxun}},
		{"uis/views/kuafu1v1_prefab", "SeasonPanel", {TabIndex.kuafu1v1_reward}},
		{"uis/views/kuafu1v1_prefab", "RankPanel", {TabIndex.kuafu1v1_rank}},
	}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.def_index = TabIndex.kuafu1v1_pipei
end

function Kuafu1V1View:LoadCallBack()
	local tab_cfg = {
		{name =	Language.Kuafu1V1.TabbarName.PiPei, tab_index = TabIndex.kuafu1v1_pipei, func = "kf1v1_pipei"},
		{name = Language.Kuafu1V1.TabbarName.GongXun, tab_index = TabIndex.kuafu1v1_gongxun, remind_id = RemindName.GongXunRed},
		{name = Language.Kuafu1V1.TabbarName.Reward, tab_index = TabIndex.kuafu1v1_reward, },
		{name = Language.Kuafu1V1.TabbarName.Rank, tab_index = TabIndex.kuafu1v1_rank,},
	}
	self.tabbar = TabBarTwo.New()
	self.tabbar:Init(self, self.node_list["TabPanel"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ChangeToIndex, self))

	self.node_list["TitleText"].text.text = Language.Kuafu1V1.MainTitle
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.KuaFu1v1, BindTool.Bind(self.GetUiCallBack, self))
end

function Kuafu1V1View:CloseCallBack()

end

function Kuafu1V1View:OnClickClose()
	KuaFu1v1Ctrl.Instance:SendCross1v1MatchQueryReq(CROSS_1V1_MATCH_REQ_TYPE.CROSS_1V1_MATCH_REQ_CANCEL)
	self:Close()
end


--游戏中被删除时,退出游戏时也会调用
function Kuafu1V1View:ReleaseCallBack()
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.KuaFu1v1)
	end

	if self.pipei_view then
		self.pipei_view:DeleteMe()
		self.pipei_view = nil
	end

	if self.gongxun_view then
		self.gongxun_view:DeleteMe()
		self.gongxun_view = nil
	end

	if self.reward_view then
		self.reward_view:DeleteMe()
		self.reward_view = nil
	end

	if self.rank_view then
		self.rank_view:DeleteMe()
		self.rank_view = nil
	end

	self.tabbar:DeleteMe()
	self.tabbar = nil
end

--决定显示那个界面
function Kuafu1V1View:ShowIndexCallBack(index, index_nodes)
	self.tabbar:ChangeToIndex(index)
	if nil ~= index_nodes then
		if index == TabIndex.kuafu1v1_pipei then
			self.pipei_view = KuaFu1v1ViewMain.New(index_nodes["MainPanel"])
		elseif index == TabIndex.kuafu1v1_gongxun then
			self.gongxun_view = KuaFu1v1ViewGongXun.New(index_nodes["GongXunView"])
		elseif index == TabIndex.kuafu1v1_reward then
			self.reward_view = KuaFu1v1ViewSeason.New(index_nodes["SeasonPanel"])
		elseif index == TabIndex.kuafu1v1_rank then
			self.rank_view = KuaFu1v1ViewRank.New(index_nodes["RankPanel"])
		end
	end

	if index == TabIndex.kuafu1v1_pipei then
		self.pipei_view:OpenCallBack()
	elseif index == TabIndex.kuafu1v1_gongxun then
		self.gongxun_view:OpenCallBack()
	elseif index == TabIndex.kuafu1v1_reward then
		self.reward_view:OpenCallBack()
	elseif index == TabIndex.kuafu1v1_rank then
		self.rank_view:OpenCallBack()
	end

end

function Kuafu1V1View:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if ui_name == GuideUIName.Tab then
		local index = TabIndex[ui_param]
		if index == self.show_index then
			return NextGuideStepFlag
		end
		return self.tabbar:GetTabButton(index), BindTool.Bind(self.ChangeToIndex, self, index)
	elseif self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
end

function Kuafu1V1View:OnFlush(params_t)
	for k, v in pairs(params_t) do
		if k == "MainPanel" and self.pipei_view ~= nil then
			self.pipei_view:Flush()
		elseif k == "GongXunView" and self.gongxun_view ~= nil then
			self.gongxun_view:Flush()
		elseif k == "RankPanel" and self.rank_view ~= nil then
			self.rank_view:Flush()
		elseif k == "SeasonPanel"  and self.reward_view ~= nil then
			self.reward_view:Flush()
		end
	end
end

function Kuafu1V1View:ShowEnemyInfo()
	if self.pipei_view and self.show_index == TabIndex.kuafu1v1_pipei then
		self.pipei_view:ShowEnemyInfo()
	end
end

require("game/kuafu_pvp/kf_pvp_view_main")
require("game/kuafu_pvp/kf_pvp_view_season")
require("game/kuafu_pvp/kf_pvp_view_rank")
require("game/kuafu_pvp/kf_pvp_view_gongxun")


KFPVPView = KFPVPView or BaseClass(BaseView)

function KFPVPView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel"},
		{"uis/views/kuafu3v3_prefab", "MainPanel", {TabIndex.kuafu3v3_pipei}},
		{"uis/views/kuafu3v3_prefab", "GongXunView", {TabIndex.kuafu3v3_gongxun}},
		{"uis/views/kuafu3v3_prefab", "SeasonPanel", {TabIndex.kuafu3v3_reward}},
		{"uis/views/kuafu3v3_prefab", "RankPanel", {TabIndex.kuafu3v3_rank}},
	}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.def_index = TabIndex.kuafu3v3_pipei
end

function KFPVPView:LoadCallBack()
	local tab_cfg = {
		{name =	Language.Kuafu3V3.TabbarName.PiPei, tab_index = TabIndex.kuafu3v3_pipei, func = "kf3v3_pipei"},
		{name = Language.Kuafu3V3.TabbarName.GongXun, tab_index = TabIndex.kuafu3v3_gongxun, remind_id = RemindName.Cross3v3GongXunRed},
		{name = Language.Kuafu3V3.TabbarName.Reward, tab_index = TabIndex.kuafu3v3_reward, },
		{name = Language.Kuafu3V3.TabbarName.Rank, tab_index = TabIndex.kuafu3v3_rank,},
	}
	self.tabbar = TabBarTwo.New()
	self.tabbar:Init(self,self.node_list["TabPanel"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ChangeToIndex, self))

	self.node_list["TitleText"].text.text = Language.Kuafu3V3.MainTitle
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	--FunctionGuide.Instance:RegisteGetGuideUi(ViewName.Kuafu3V3, BindTool.Bind(self.GetUiCallBack, self))
end

function KFPVPView:CloseCallBack()
	KuafuPVPCtrl.Instance:SendCrossMultiuerChallengeCancelMatching()
end

function KFPVPView:OnClickClose()
	KuafuPVPCtrl.Instance:SendCrossMultiuerChallengeCancelMatching()
	self:Close()
end


--游戏中被删除时,退出游戏时也会调用
function KFPVPView:ReleaseCallBack()
	-- if FunctionGuide.Instance then
	-- 	FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.Kuafu3V3)
	-- end

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
function KFPVPView:ShowIndexCallBack(index, index_nodes)
	self.tabbar:ChangeToIndex(index)
	if nil ~= index_nodes then
		if index == TabIndex.kuafu3v3_pipei then
			self.pipei_view = KFPVPViewMain.New(index_nodes["MainPanel"])
			KuafuPVPCtrl.Instance:SendGetCross3V3RankListReq(1)
		elseif index == TabIndex.kuafu3v3_gongxun then
			self.gongxun_view = KFPVPViewGongXun.New(index_nodes["GongXunView"])
		elseif index == TabIndex.kuafu3v3_reward then
			self.reward_view = KFPVPViewSeason.New(index_nodes["SeasonPanel"])
		elseif index == TabIndex.kuafu3v3_rank then
			self.rank_view = KFPVPViewRank.New(index_nodes["RankPanel"])
		end
	end

	if index == TabIndex.kuafu3v3_pipei then
		self.pipei_view:OpenCallBack()
	elseif index == TabIndex.kuafu3v3_gongxun then
		self.gongxun_view:OpenCallBack()
	elseif index == TabIndex.kuafu3v3_reward then
		self.reward_view:OpenCallBack()
	elseif index == TabIndex.kuafu3v3_rank then
		self.rank_view:OpenCallBack()
	end

end

-- function KFPVPView:GetUiCallBack(ui_name, ui_param)
-- 	if not self:IsOpen() or not self:IsLoaded() then
-- 		return
-- 	end
-- 	if ui_name == GuideUIName.Tab then
-- 		local index = TabIndex[ui_param]
-- 		if index == self.show_index then
-- 			return NextGuideStepFlag
-- 		end
-- 		return self.tabbar:GetTabButton(index), BindTool.Bind(self.ChangeToIndex, self, index)
-- 	elseif self[ui_name] then
-- 		if self[ui_name].gameObject.activeInHierarchy then
-- 			return self[ui_name]
-- 		end
-- 	end
-- end

function KFPVPView:OnFlush(params_t)
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

-- function KFPVPView:ShowEnemyInfo()
-- 	if self.pipei_view and self.show_index == TabIndex.kuafu3v3_pipei then
-- 		self.pipei_view:ShowEnemyInfo()
-- 	end
-- end

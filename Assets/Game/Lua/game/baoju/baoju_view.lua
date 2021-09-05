require("game/baoju/medal/medal_view")
require("game/baoju/jingjie/jingjie_view")
-- require("game/baoju/zhibao/activedegree_view")
require("game/baoju/zhibao/zhibao_upgrade")
require("game/baoju/zhibao/zhibao_activedegree")
require("game/baoju/jingjie/hunyuupgradeshow_tips")




BaoJuView = BaoJuView or BaseClass(BaseView)

function BaoJuView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel"},
		{"uis/views/baoju_prefab", "ActiveDegree", {TabIndex.baoju_zhibao_active}},
		{"uis/views/baoju_prefab", "Upgrade", {TabIndex.baoju_zhibao_upgrade}},
		{"uis/views/baoju_prefab", "MedalView", {TabIndex.baoju_medal}},
		{"uis/views/baoju_prefab", "JingJieView", {TabIndex.baoju_jingjie}},
	}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.def_index = TabIndex.baoju_zhibao_active
end

function BaoJuView:LoadCallBack()
	local tab_cfg = {
		{name =	Language.BaoJu.TabbarName.BiZuo, tab_index = TabIndex.baoju_zhibao_active, func = "baoju", remind_id = RemindName.ZhiBao_Active,},
		{name = Language.BaoJu.TabbarName.XianLing, tab_index = TabIndex.baoju_zhibao_upgrade, func = "baoju_zhibao_upgrade", remind_id = RemindName.ZhiBao_Upgrade,},
		-- {name = Language.BaoJu.TabbarName.LingYin, tab_index = TabIndex.baoju_medal, func = "baoju_medal", remind_id = RemindName.Medal,},
		{name = Language.BaoJu.TabbarName.JingJie, tab_index = TabIndex.baoju_jingjie, remind_id = RemindName.ZhiBao_jingjie, func = "baoju_jingjie"},
	}
	self.tabbar = TabBarTwo.New()
	self.tabbar:Init(self, self.node_list["TabPanel"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ChangeToIndex, self))

	self.node_list["TitleText"].text.text = Language.BaoJu.TitleName
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.Close, self))
	ZhiBaoCtrl.Instance:SetView(self)
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.BaoJu, BindTool.Bind(self.GetUiCallBack, self))
end

function BaoJuView:CloseCallBack()
	--关闭特效界面
	TipsCtrl.Instance:DestroyFlyEffectByViewName(ViewName.BaoJu)
	ZhiBaoData.Instance:SetStartFlyObj(nil)

	if self.medal_view then
		self.medal_view:CloseCallBack()
	end
end

--游戏中被删除时,退出游戏时也会调用
function BaoJuView:ReleaseCallBack()
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.BaoJu)
	end

	if self.medal_view then
		self.medal_view:DeleteMe()
		self.medal_view = nil
	end

	if self.activedegree_view then
		self.activedegree_view:DeleteMe()
		self.activedegree_view = nil
	end

	if self.upgrade_view then
		self.upgrade_view:DeleteMe()
		self.upgrade_view = nil
	end

	if self.jingjie_view then
		self.jingjie_view:DeleteMe()
		self.jingjie_view = nil
	end

	self.tabbar:DeleteMe()
	self.tabbar = nil
end

--决定显示那个界面
function BaoJuView:ShowIndexCallBack(index, index_nodes)
	self.tabbar:ChangeToIndex(index)
	if nil ~= index_nodes then
		if index == TabIndex.baoju_zhibao_active then
			self.activedegree_view = ZhiBaoActiveDegreeView.New(index_nodes["ActiveDegree"])
		elseif index == TabIndex.baoju_zhibao_upgrade then
			self.upgrade_view = ZhiBaoUpgradeView.New(index_nodes["Upgrade"])
		elseif index == TabIndex.baoju_medal then
			self.medal_view = MedalView.New(index_nodes["MedalView"])
			self.medal_view:SelectIcon()
		elseif index == TabIndex.baoju_jingjie then
			self.jingjie_view = JingJieView.New(index_nodes["JingJieView"])
		end
	end
	if index == TabIndex.baoju_zhibao_active then
		self.activedegree_view:OpenCallBack()
	elseif index == TabIndex.baoju_zhibao_upgrade then
		self.upgrade_view:OpenCallBack()
	elseif index == TabIndex.baoju_medal then
		TipsCtrl.Instance:DestroyFlyEffectByViewName(ViewName.BaoJu)
		ZhiBaoData.Instance:SetStartFlyObj(nil)
		self.medal_view:OpenCallBack()
		self.medal_view:SelectIcon()
	elseif index == TabIndex.baoju_jingjie then
		self.jingjie_view:OpenCallBack()
	end
end

function BaoJuView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if ui_name == GuideUIName.Tab then
		local index = TabIndex[ui_param]
		if index == self.show_index then
			return NextGuideStepFlag
		end
		return self.tabbar:GetTabButton(index), BindTool.Bind(self.ChangeToIndex, self, index)
	elseif ui_name == "baoju_goto_daily" then
		return self.activedegree_view:GetGoToPanel()
	elseif self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
end

function BaoJuView:OnFlush(data)
	
end

function BaoJuView:GetUpGradeView()
	if self.upgrade_view then
		return self.upgrade_view
	end
end

function BaoJuView:UpGradeFlush()
	if self.upgrade_view and self.upgrade_view:IsOpen() then
		self.upgrade_view:UpGradeFlush()
	end
end

function BaoJuView:ZhiBaoInfoChange()
	if self.upgrade_view then
		self.upgrade_view:Flush()
	end
end

function BaoJuView:FlushActive()
	if self.activedegree_view then
		self.activedegree_view:OnProtocolChange()
	end
end
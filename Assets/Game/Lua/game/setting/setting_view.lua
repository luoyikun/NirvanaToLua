require("game/setting/setting_content_view")
require("game/setting/reward_content_view")
-- require("game/setting/setting_custom_view")

SettingView = SettingView or BaseClass(BaseView)

function SettingView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel"},
		{"uis/views/settingview_prefab", "SettingContent", {TabIndex.setting_xianshi, TabIndex.setting_system}},
		{"uis/views/settingview_prefab", "RewardContent", {TabIndex.setting_notice}},
		-- {"uis/views/settingview_prefab", "GMContent", {TabIndex.setting_custom}},		-- 屏蔽掉GM反馈
	}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.full_screen = false
	self.play_audio = true
	self.def_index = TabIndex.setting_notice
end

function SettingView:LoadCallBack()
	local tab_cfg = {
		{name =	Language.Setting.TabbarName.XianShi, tab_index = TabIndex.setting_xianshi},
		{name = Language.Setting.TabbarName.XiTong, tab_index = TabIndex.setting_system},
		{name = Language.Setting.TabbarName.GongGao, tab_index = TabIndex.setting_notice},
		-- {name = Language.Setting.TabbarName.KeFu, tab_index = TabIndex.setting_custom},		-- 屏蔽掉GM反馈
	}
	self.tabbar = TabBarTwo.New()
	self.tabbar:Init(self, self.node_list["TabPanel"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ChangeToIndex, self))


	SettingCtrl.Instance:SendHotkeyInfoReq()
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self:SetRedPoint()
end

function SettingView:ReleaseCallBack()
	if self.setting_content_view ~= nil then
		self.setting_content_view:DeleteMe()
		self.setting_content_view = nil
	end

	-- if self.setting_custom_view ~= nil then
	-- 	self.setting_custom_view:DeleteMe()
	-- 	self.setting_custom_view = nil
	-- end

	if self.reward_content_view ~= nil then
		self.reward_content_view:DeleteMe()
		self.reward_content_view = nil
	end

	self.tabbar:DeleteMe()
	self.tabbar = nil
end

function SettingView:OpenCallBack()
	self:Flush()
end

function SettingView:CloseCallBack()
	if self.setting_content_view then
		self.setting_content_view:CloseCallBack()
	end
end

function SettingView:SetRedPoint()
	local state = SettingData.Instance:GetRedPointState()
	local button = self.tabbar:GetTabButton(TabIndex.setting_notice)
	button:ShowRemind(state)
end

function SettingView:OnFlush()
	if self.show_index == TabIndex.setting_notice and self.reward_content_view then
		self.reward_content_view:OnFlush()
	end
	self:SetRedPoint()
end

function SettingView:ShowIndexCallBack(index, index_nodes)
	self.tabbar:ChangeToIndex(index)

	if index_nodes then
		if index == TabIndex.setting_xianshi or index == TabIndex.setting_system then
			self.setting_content_view = SettingContentView.New(index_nodes["SettingContent"])
		elseif index == TabIndex.setting_notice then
			self.reward_content_view = RewardContentView.New(index_nodes["RewardContent"])
		-- elseif index == TabIndex.setting_custom then
		-- 	self.setting_custom_view = SettingCustomView.New(index_nodes["GMContent"])
		end
	end

	if self.setting_content_view and index == TabIndex.setting_xianshi then
		self.setting_content_view:FlushClick1()
		self.setting_content_view:CloseCallBack()
		self.node_list["TitleText"].text.text = Language.Setting.Tab1
	elseif self.setting_content_view and index == TabIndex.setting_system then
		self.setting_content_view:FlushClick2()
		self.setting_content_view:CloseCallBack()
		self.node_list["TitleText"].text.text = Language.Setting.Tab1
	-- elseif self.setting_custom_view and index == TabIndex.setting_custom then
	-- 	self.setting_custom_view:OpenCustom()
	-- 	if self.setting_content_view then
	-- 		self.setting_content_view:CloseCallBack()
	-- 	end
	-- 	self.node_list["TitleText"].text.text = Language.Setting.Tab1
	elseif self.reward_content_view and index == TabIndex.setting_notice then
		self.reward_content_view:Flush()
		if self.setting_content_view then
			self.setting_content_view:CloseCallBack()
		end
		self.node_list["TitleText"].text.text = Language.Setting.Tab1
	end
end

function SettingView:FlushAutoUseSkill()
	if self.setting_content_view then
		self.setting_content_view:FlushAutoUseSkill()
	end
end

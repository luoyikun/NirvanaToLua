require("game/yule/fishing/fishing_view")
require("game/yule/go_pawn/go_pawn_content_view")

YuLeView = YuLeView or BaseClass(BaseView)
function YuLeView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel"},
		{"uis/views/yuleview_prefab", "FishContent", {TabIndex.yule_fishing}},
	}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.def_index = TabIndex.yule_fishing
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function YuLeView:ReleaseCallBack()
	if self.fishing_view then
		self.fishing_view:DeleteMe()
		self.fishing_view = nil
	end

	if self.go_pawn_view then
		self.go_pawn_view:DeleteMe()
		self.go_pawn_view = nil
	end

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end
	self.tabbar = nil
	self.red_point_list = nil
end

function YuLeView:LoadCallBack()
	local tab_cfg = {
		{name = Language.Fishpond.ChuiDiao,tab_index = TabIndex.yule_fishing},
	}
	self.tabbar = TabBarTwo.New()
	self.tabbar:Init(self, self.node_list["TabPanel"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ChangeToIndex, self))
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))

	RemindManager.Instance:Bind(self.remind_change, RemindName.YuLe_Fishing)
	self.tabbar:GetTabButton(TabIndex.yule_fishing):ShowRemind(RemindManager.Instance:GetRemind(RemindName.YuLe_Fishing) > 0)
end

function YuLeView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.tabbar:GetTabButton(TabIndex.yule_fishing) then
		self.tabbar:GetTabButton(TabIndex.yule_fishing):ShowRemind(num > 0)
	end
end

function YuLeView:CloseWindow()
	self:Close()
end

function YuLeView:OpenCallBack()
	self:Flush()
end

function YuLeView:CloseCallBack()
	if self.fishing_view then
		self.fishing_view:CloseCallBack()
	end
end

function YuLeView:ShowIndexCallBack(index, index_nodes)
	self.tabbar:ChangeToIndex(index)
	if index_nodes then
		if index == TabIndex.yule_fishing then
			self.fishing_view = FishingView.New(index_nodes["FishContent"])
		end
	end

	if index == TabIndex.yule_fishing then
		self.fishing_view:InitView()
		self.node_list["TitleText"].text.text = Language.Fishpond.YuLe
	end
end

function YuLeView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "fish" then
			if self.fishing_view then
				self.fishing_view:FlushFish()
			end
		elseif k == "info" then
			if self.fishing_view then
				self.fishing_view:FlushInfo()
			end
		elseif k == "fish_num_change" then
			if self.fishing_view then
				self.fishing_view:FishNumChange(v[1])
			end
		elseif k == "enter_other" then
			if self.fishing_view then
				self.fishing_view:RefreshView(v[1])
			end
		elseif k == "fish_reward" then
			if self.fishing_view then
				self.fishing_view:PlayRewardEffect()
			end
		end
	end
	if self.show_index == TabIndex.yule_fishing and nil ~= self.fishing_view then
		self.fishing_view:OnFlush()
	end
end
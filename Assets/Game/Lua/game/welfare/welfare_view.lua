require("game/welfare/welfare_sign_in_view")
require("game/welfare/welfare_find_view")
require("game/welfare/welfare_exchange_view")
require("game/welfare/welfare_happy_tree_view")
require("game/welfare/welfare_level_reward_view")
require("game/welfare/welfare_gold_turntable_view")

WelfareView = WelfareView or BaseClass(BaseView)

WelfareView.TabIndex = {
	sign = 1,
	level = 2,
	turntable = 3,
}

function WelfareView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel"},
		{"uis/views/welfare_prefab", "WelfareView"}
	}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
end

--游戏中被删除时,退出游戏时也会调用
function WelfareView:ReleaseCallBack()
	if self.sign_in_view then
		self.sign_in_view:DeleteMe()
		self.sign_in_view = nil
	end

	if self.find_view then
		self.find_view:DeleteMe()
		self.find_view = nil
	end

	if self.exchange_view then
		self.exchange_view:DeleteMe()
		self.exchange_view = nil
	end

	if self.happy_tree_view then
		self.happy_tree_view:DeleteMe()
		self.happy_tree_view = nil
	end

	if self.level_reward_view then
		self.level_reward_view:DeleteMe()
		self.level_reward_view = nil
	end

	if self.goldturn_table_content then
		self.goldturn_table_content:DeleteMe()
		self.goldturn_table_content = nil
	end

	-- 清理变量和对象
	self.red_point_list = nil
	self.tab_sign = nil
	self.tab_level = nil
	self.tab_turntable = nil
end

function WelfareView:LoadCallBack()
	--签到
	local sign_content = self.node_list["SingIn"]
	sign_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.sign_in_view = SignInView.New(obj)
		self.sign_in_view:ChangeSignIndex()
		self.sign_in_view:Flush()
	end)

	--等级豪礼
	local level_reward_content = self.node_list["LevelReward"]
	level_reward_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.level_reward_view = LevelRewardView.New(obj)
		self.level_reward_view:Flush()
	end)

	--找回
	local find_content = self.node_list["Find"]
	find_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.find_view = FindView.New(obj)
		self:FlushFind()
	end)

	--兑换
	local exchange_content = self.node_list["Exchange"]
	exchange_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.exchange_view = WelfareExchangeView.New(obj)
	end)

	--欢乐果树
	local happytree_content = self.node_list["HappyTree"]
	happytree_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.happy_tree_view = HappyTreeView.New(obj, self)
		self.happy_tree_view:Flush()
		self.happy_tree_view:SetHappyTreeExchangeRedPoint()
	end)

	--钻石转盘
	local goldturn_table_content = self.node_list["GoldTurntableContent"]
	goldturn_table_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.goldturn_table_content = GoldTurntableView.New(obj)
	end)
	--红点
	self.red_point_list = {
		["Sign"] = self.node_list["ImgSignRedPoint"],
		["FindReward"] = self.node_list["ImgFindRewardRedPoint"],
		["HappyTree"] = self.node_list["ImgHappyTreeRedPoint"],
		["GoldTurntable"] = self.node_list["ImgGoldTurntableRedPoint"]
	}

	self.tab_sign = self.node_list["TabSign"]
	self.tab_level = self.node_list["TabLevel"]
	self.tab_turntable = self.node_list["Tabturntable"]
	self.node_list["TitleText"].text.text = Language.Common.FuLi
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.HandleClose, self))

	local is_active_reward = OpenFunData.Instance:CheckIsHide("welfare_exchange")
	-- local is_active_rotary = OpenFunData.Instance:CheckIsHide("welfare_goldturn")
	self.node_list["Toggle"]:SetActive(is_active_reward)
	-- self.node_list["Tabturntable"]:SetActive(is_active_rotary)

	self.tab_sign.toggle:AddValueChangedListener(BindTool.Bind(self.ToggleChange, self, WelfareView.TabIndex.sign))
	self.tab_level.toggle:AddValueChangedListener(BindTool.Bind(self.ToggleChange, self, WelfareView.TabIndex.level))
	self.tab_turntable.toggle:AddValueChangedListener(BindTool.Bind(self.ToggleChange, self, WelfareView.TabIndex.turntable))	
end

function WelfareView:SetRedPoint()
	if not self:IsLoaded() then
		return
	end
	local red_point_info_list = WelfareData.Instance:GetAllRedPoint()
	if red_point_info_list then
		for k,v in pairs(self.red_point_list) do
			local state = red_point_info_list[k] or false
			v:SetActive(state)
		end
	end
	if self.happy_tree_view then
		self.happy_tree_view:SetHappyTreeExchangeRedPoint()
	end
end

function WelfareView:OpenCallBack()
	self:SetRedPoint()
	if self.tab_sign.toggle.isOn and self.sign_in_view then
		self.sign_in_view:ChangeSignIndex()
	end

end

function WelfareView:CloseCallBack()
	ViewManager.Instance:FlushView(ViewName.FuBen)
	ViewManager.Instance:FlushView(ViewName.Boss)
	ViewManager.Instance:FlushView(ViewName.YunbiaoView)
	ViewManager.Instance:FlushView(ViewName.MarryMe)

	if nil ~= self.goldturn_table_content then
		self.goldturn_table_content:CloseCallBack()
	end
end

function WelfareView:ShowIndexCallBack(index)
	if index == TabIndex.welfare_sign_in then
		self.tab_sign.toggle.isOn = true
	elseif index == TabIndex.welfare_level then
		self.tab_level.toggle.isOn = true
	elseif index == TabIndex.welfare_goldturn then
		self.tab_turntable.toggle.isOn = true
	end
end

function WelfareView:ToggleChange(index, isOn)
	if not isOn then
		return
	end		
	if index == WelfareView.TabIndex.level then
		if self.level_reward_view then
			self.level_reward_view:Flush()
		end
	elseif index == WelfareView.TabIndex.turntable then
		WelfareCtrl.Instance:SendTurntableReward(Yuan_Bao_Zhuanpan_OPERATE_TYPE.SET_JC_ZhUANSHI_NUM)
	end
end

function WelfareView:FlushFind()
	if self.find_view then
		self.find_view:FlushScroller()
		self.find_view:Flush()
	end
end

function WelfareView:OnSeverDataChange()
	if not self:IsLoaded() then
		return
	end
	self:SetRedPoint()
	self:FlushFind()
	if self.happy_tree_view then
		self.happy_tree_view:Flush()
	end
	if self.level_reward_view then
		self.level_reward_view:Flush()
	end
end

function WelfareView:HandleClose()
	self:Close()
end

function WelfareView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "sign_in" and self.sign_in_view then
			self.sign_in_view:Flush()
		elseif k == "yuan_baonum" then
			if self.goldturn_table_content then
				self.goldturn_table_content:SetYuanbaoNum(v[1],v[2])
			end
			self:SetRedPoint()
		elseif k == "startturn" then
			if self.goldturn_table_content then
				self.goldturn_table_content:StartTurn(v[1],2.7)
			end
		end
	end


	local is_active_reward = OpenFunData.Instance:CheckIsHide("welfare_exchange")
	-- local is_active_rotary = OpenFunData.Instance:CheckIsHide("welfare_goldturn")
	self.node_list["Toggle"]:SetActive(is_active_reward)
	-- self.node_list["Tabturntable"]:SetActive(is_active_rotary)
end
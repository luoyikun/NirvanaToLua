require("game/compose/compose_content_view")

local COMPOSE_TAB_INDEX =
{
	TabIndex.compose_jinjie,
	TabIndex.compose_other,
	TabIndex.compose_stone,
}
ComposeView = ComposeView or BaseClass(BaseView)

function ComposeView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel"},
		{"uis/views/composeview_prefab", "ComposeContentView",{TabIndex.compose_stone, TabIndex.compose_jinjie, TabIndex.compose_other, TabIndex.compose_shengqi, TabIndex.compose_shenmo}},
	}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.full_screen = false
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.def_index = TabIndex.compose_stone
end

function ComposeView:__delete()

end

function ComposeView:ReleaseCallBack()
	if self.compose_content_view then
		self.compose_content_view:DeleteMe()
		self.compose_content_view = nil
	end
	self.tabbar:DeleteMe()
	self.tabbar = nil
end

function ComposeView:LoadCallBack()
	local tab_cfg = {
		{name = Language.Compose.TabbarName.BaoShi, func = "compose_stone", tab_index = TabIndex.compose_stone},
		{name =	Language.Compose.TabbarName.DuanZao, func = "compose_jinjie", tab_index = TabIndex.compose_jinjie},
		{name = Language.Compose.TabbarName.ShengQi, func = "compose_shengqi",tab_index = TabIndex.compose_shengqi, remind_id = RemindName.ComposeShengqi},
		{name = Language.Compose.TabbarName.ShenMo, func = "compose_shenmo",tab_index = TabIndex.compose_shenmo, remind_id = RemindName.ComposeShenmo},
		{name = Language.Compose.TabbarName.Other, func = "compose_other",tab_index = TabIndex.compose_other},
	}
	self.tabbar = TabBarTwo.New()
	self.tabbar:Init(self, self.node_list["TabPanel"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ChangeToIndex, self))
	self.node_list["TitleText"].text.text = Language.Compose.ComposeName
	self.node_list["TitleText"].text.lineSpacing = 1
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.Close, self))

	self:Flush()
end

function ComposeView:OpenCallBack()
	if ShengXiaoCtrl.Instance:GetBagView():IsOpen() then
		ShengXiaoCtrl.Instance:GetBagView():Close()
	end
	if self.compose_content_view then
		self.compose_content_view:FlushBuyNum()
	end

	--监听物品变化
	self.item_change = BindTool.Bind(self.ItemChange, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_change)

	RemindManager.Instance:Fire(RemindName.Compose, true)
end

function ComposeView:CloseCallBack()
	if self.item_change then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change)
		self.item_change = nil
	end
end

function ComposeView:ItemChange(item_id)
	self:Flush(nil, {item_id})
end
function ComposeView:ShowIndexCallBack(index, index_nodes)
	self.tabbar:ChangeToIndex(index)
	if index_nodes then
		if not self.compose_content_view then
			self.compose_content_view = ComposeContentView.New(index_nodes["ComposeContentView"])
		end
	end
	if index == TabIndex.compose_jinjie then
		self.compose_content_view:OnJinJie()
	elseif index == TabIndex.compose_other then
		self.compose_content_view:OnQiTa()
	elseif index == TabIndex.compose_stone then
		self.compose_content_view:OnBaoShi()
	elseif index == TabIndex.compose_shengqi then
		self.compose_content_view:OnShengQi()
	elseif index == TabIndex.compose_shenmo then
		self.compose_content_view:OnShenMo()
	end
end

function ComposeView:OnFlush(param_t)
	if self.compose_content_view then
		local item_id = param_t["all"][1]
		self.compose_content_view:ItemDataChangeCallback(item_id)
	end
end
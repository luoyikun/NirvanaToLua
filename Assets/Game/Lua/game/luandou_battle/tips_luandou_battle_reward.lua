LuanDouRewardView = LuanDouRewardView or BaseClass(BaseView)

function LuanDouRewardView:__init()
	self.ui_config = {
		{"uis/views/luandoubattleview_prefab", "LuanDouRewardTips"}
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.data_list = {}
end

function LuanDouRewardView:__delete()

end

function LuanDouRewardView:ReleaseCallBack()
	if self.item_list then
		for k,v in pairs(self.item_list) do
			v:DeleteMe()
		end
	end
	self.item_list = nil
	self.data_list = nil
end

function LuanDouRewardView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	self.node_list["BtnSure"].button:AddClickListener(BindTool.Bind(self.CloseView, self))

	self.item_list = {}
	for i = 1, 5 do
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["Items"])
		item:SetData(nil)
		table.insert(self.item_list, item)
	end
end

function LuanDouRewardView:CloseView()
	self:Close()
end

function LuanDouRewardView:OnFlush()
	for k,v in pairs(self.item_list) do
		if self.data_list[k-1]then
			v:SetData(self.data_list[k - 1])
			v:SetActive(true)
		else
			v:SetActive(false)
		end
	end
end

function LuanDouRewardView:SetData(data)
	self.data_list = data
end

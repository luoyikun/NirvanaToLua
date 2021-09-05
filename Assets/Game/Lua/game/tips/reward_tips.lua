RewardTipView = RewardTipView or BaseClass(BaseView)

function RewardTipView:__init()
	self.ui_config = {
		{"uis/views/tips/rewardtips_prefab", "RewardTipsView"}
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.data = {}
end


function RewardTipView:ReleaseCallBack()
	if self.item_list then
		for k,v in pairs(self.item_list) do
			v:DeleteMe()
		end
	end

	self.item_list = nil
	self.data = {}
end

function RewardTipView:CloseCallBack()
	self.node_list["Title"].text.text = ""
end

function RewardTipView:SetTittle(tittle)
	tittle = tittle or Language.Tip.RewardTitle
	self.node_list["Title"].text.text = tittle
end

function RewardTipView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	self.node_list["BtnSure"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	self.node_list["Title"].text.text = Language.Tip.RewardTitle

	self.item_list = {}
	for i = 0, 10 do
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["Items"])
		item:SetData(nil)
		table.insert(self.item_list, item)
	end
end

function RewardTipView:CloseView()
	self:Close()
end

function RewardTipView:OnFlush()
	for k, v in pairs(self.item_list) do
		if self.data and self.data[k - 1] then
			v:SetData(self.data[k - 1])
			v:SetActive(true)
		else
			v:SetActive(false)
		end
	end
end

function RewardTipView:SetData(data)
	self.data = data
	self:Flush()
end


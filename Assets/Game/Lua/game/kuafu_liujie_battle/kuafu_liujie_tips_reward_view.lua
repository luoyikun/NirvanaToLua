KfLiujieRewardTip = KfLiujieRewardTip or BaseClass(BaseView)

local Max_Reward_Num = 3

function KfLiujieRewardTip:__init()
	self.ui_config = {{"uis/views/kuafuliujie_prefab", "KuafuLiujieRewardTips"}}
	
	self.item_list = {}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self.title_id = 0
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function KfLiujieRewardTip:__delete()
	self.data_list = nil
	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	TitleData.Instance:ReleaseTitleEff(self.node_list["TitleImg"])
end

function KfLiujieRewardTip:SetData(items,show_gray,ok_callback,show_button, title_id)
	self.data_list = items
	self.show_gray_data = show_gray
	self.ok_callback = ok_callback
	self.show_button_value = show_button
	self.title_id = title_id
end

function KfLiujieRewardTip:LoadCallBack()
	self.node_list["ClickOKBtn"].button:AddClickListener(BindTool.Bind(self.ClickOK, self))

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["CapTxt"])
	self.item_list = {}
	for i = 1, Max_Reward_Num do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self.node_list["CellItem"..i])
		self.item_list[i - 1] = {item_obj = self.node_list["CellItem"..i], item_cell = item_cell}
	end
end

function KfLiujieRewardTip:CloseView()
	self:Close()
end

function KfLiujieRewardTip:ClickOK()
	if self.ok_callback then
		self.ok_callback()
	end
	self:Close()
end

function KfLiujieRewardTip:OpenCallBack()
	self:Flush()
end
function KfLiujieRewardTip:OnFlush()
	if self.data_list ~= nil then
		for k, v in pairs(self.item_list) do
			if self.data_list[k] then
				v.item_cell:SetData(self.data_list[k])
				v.item_obj:SetActive(true)
			else
				v.item_obj:SetActive(false)
			end
		end
		UI:SetButtonEnabled(self.node_list["ClickOKBtn"], not ShowGray)
		if self.show_button_value == nil then
			self.node_list["ClickOKBtn"]:SetActive(true)
		else
			self.node_list["ClickOKBtn"]:SetActive(self.show_button_value)
		end
	end
	if self.title_id then
		local bundle, asset = ResPath.GetTitleIcon(self.title_id)
		self.node_list["TitleImg"].image:LoadSprite(bundle, asset .. ".png")
		TitleData.Instance:LoadTitleEff(self.node_list["TitleImg"], self.title_id, true)
		local title_cfg = TitleData.Instance:GetTitleCfg(self.title_id)
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = CommonDataManager.GetCapability(title_cfg)
		end
	end
end

function KfLiujieRewardTip:ReleaseCallBack()
	self.data_list = nil
	for k,v in pairs(self.item_list) do
		if v.item_cell then
			v.item_cell:DeleteMe()
		end
	end
	self.item_list = {}
	self.fight_text = nil
end

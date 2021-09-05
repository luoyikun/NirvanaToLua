WeddingTipsOne = WeddingTipsOne or BaseClass(BaseView)

function WeddingTipsOne:__init()
	self.ui_config = {
		{"uis/views/marriageview_prefab","WeddingTips1"},
	}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.is_any_click_close = true
end

function WeddingTipsOne:__delete()

end

function WeddingTipsOne:LoadCallBack()
	self.item_list = {}
	self.fight_text = {}
	for i=1, 2 do
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["Item_" .. i])
		self.item_list[i] = item
		-- self.item_list[i].power = self.node_list["fight_power_" .. i]
		self.fight_text[i] = CommonDataManager.FightPower(self, self.node_list["fight_power_" .. i])
	end
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
end

function WeddingTipsOne:ReleaseCallBack()
	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	for i = 1, 2 do
		if self.fight_text[i] then
			self.fight_text[i] = nil
		end
	end
	self.fight_text = nil
end

function WeddingTipsOne:OpenCallBack()
	self:Flush()
end

function WeddingTipsOne:OnFlush()
	local hunli_type = MARRIAGE_SELECT_TYPE.MARRIAGE_SELECT_TYPE_SWEET.index - 1 or 0
	local hunli_data = MarriageData.Instance:GetHunliInfoByType(hunli_type)
	if nil ~= hunli_data then
		for k,v in pairs(self.item_list) do
			v:SetData(hunli_data.reward_type[0])
			if self.fight_text[k] and self.fight_text[k].text then
				self.fight_text[k].text.text = MarriageData.Instance:GetMarriageTipPower(hunli_type, WEDDING_TIPS_POWER_TYPE.RING)
			end
		end	
	end
end

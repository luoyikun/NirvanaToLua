TipsGetGoodsView = TipsGetGoodsView or BaseClass(BaseView)
function TipsGetGoodsView:__init()
	self.ui_config = {{"uis/views/packageview_prefab", "GetGoodsTips"}}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self.item_list = {}
	self.pos = Vector3(600, 180, 0)
end

function TipsGetGoodsView:__delete()

end

function TipsGetGoodsView:ReleaseCallBack()
	if self.item_cell ~= nil then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	self.tween = nil
end

function TipsGetGoodsView:LoadCallBack()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["Item"])
	self.item_cell:ListenClick(BindTool.Bind(self.OnClickItem, self))

	self.pos = self.node_list["ItemBg"].transform.anchoredPosition
end

function TipsGetGoodsView:OnClickItem()

end

function TipsGetGoodsView:SetItemId(item_id, color)
	self.item_data = {}
	self.item_data.item_id = item_id
	self.item_data.color = color

	if #self.item_list <= 5 then
		table.insert(self.item_list, self.item_data)
	end
	if not self:IsOpen() then
		self:Open()
		self:Flush()
	end
end

function TipsGetGoodsView:OnFlush()
	if self.tween then
		self.tween:Kill()
		self.tween = nil
	end
	self.node_list["ItemBg"].transform.anchoredPosition = self.pos
	if self.item_list[1] then
		self.item_cell:SetData(self.item_list[1])
		
		local name = ItemData.Instance:GetItemName(self.item_list[1].item_id)
		self.node_list["Name"].text.text = string.format(Language.Common.ToColor, ORDER_COLOR[self.item_list[1].color], name)
		table.remove(self.item_list, 1)
		self:SetItemBgHide(false)
		self.node_list["ItemBg"].canvas_group.alpha = 1
		self:MoveIcon()
	end
end


function TipsGetGoodsView:MoveIcon()
	self.tween = self.node_list["ItemBg"].rect:DOAnchorPos(self.node_list["Target"].transform.localPosition, 1.3)
	self.tween:SetEase(DG.Tweening.Ease.OutCirc)
	self.tween:OnComplete(function()
		self:SetItemBgHide(true)
		self.delay_time = GlobalTimerQuest:AddDelayTimer(function()
			if self.item_list[1] ~= nil then
				self:Flush()
			else
				self:Close()
			end
		end, 1)
	end)
end

function TipsGetGoodsView:SetItemBgHide(bool)
	local item_animator = self.node_list["ItemBg"]:GetComponent(typeof(UnityEngine.Animator))
	if item_animator then
		item_animator.enabled = bool
	end
end
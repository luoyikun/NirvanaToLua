FuBenGetView = FuBenGetView or BaseClass(BaseView)
local COLUMN = 2
local ITEM_NUM = 8
function FuBenGetView:__init(  )
	self.ui_config = {
		{"uis/views/fubenview_prefab", "FuBenGetView"},
	}
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function FuBenGetView:__delete()

end

function FuBenGetView:LoadCallBack()
	self.node_list["BtnSure"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.data = {}
	self.item_list = {}
	for i = 1, ITEM_NUM do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self.node_list["Item" .. i])
		table.insert(self.item_list, item_cell)
	end
end

function FuBenGetView:ReleaseCallBack()
	self.data = nil
end

function FuBenGetView:CloseWindow()
	self:Close()
end

function FuBenGetView:OpenCallBack()
	self:Flush()
end

function FuBenGetView:SetData(data)
	if nil == data then
		return
	end
	self.data = data
end

function FuBenGetView:OnFlush()
	for i = 1,ITEM_NUM do
		if self.data and self.data[i] then
			self.item_list[i]:SetData(self.data[i])
			self.item_list[i]:SetParentActive(true)
		else
			self.item_list[i]:SetParentActive(false)
		end
	end
end

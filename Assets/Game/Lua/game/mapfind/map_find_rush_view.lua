MapfindRushView = MapfindRushView or BaseClass(BaseView)

function MapfindRushView:__init()
	self.full_screen = false-- 是否是全屏界面
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/mapfind_prefab", "MapRushFlushView"}
	}
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function MapfindRushView:__delete()
	
end

function MapfindRushView:LoadCallBack()
	self.rush_item = {}
	for i = 1, 8 do
		self.rush_item[i] = MapfindRushItem.New(self.node_list["item" .. i])
		self.rush_item[i]:SetData(i)
	end
	self.node_list["Bg"].rect.sizeDelta = Vector3(695, 545, 0)
	self.node_list["Txt"].text.text = Language.RareZhuanLun.TipTitle
	-- self.node_list["BtnBg"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnCancel"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnStart"].button:AddClickListener(BindTool.Bind(self.ClickStart, self))
	MapFindData.Instance:ClearSelect()
end

function MapfindRushView:ReleaseCallBack()
	self.item = nil
	for k,v in pairs(self.rush_item) do
		v:DeleteMe()
	end
	self.rush_item = nil
end

function MapfindRushView:CloseWindow()
	self:Close()
end

function MapfindRushView:ClickStart()
	local nam_tab = MapFindData.Instance:GetSelect()
	if next(nam_tab) then
	    local player_had_gold = PlayerData.Instance:GetRoleVo().gold
	    if player_had_gold > MapFindData.Instance:GetMapFlushSpend() then
	    	MapFindCtrl.Instance:BeginRush()
			MapFindCtrl.Instance:ClickIsStart()
			self:Close()
	    else
	    	MapFindCtrl.Instance:EndRush()
	    	TipsCtrl.Instance:ShowLackDiamondView()
	 --       ViewManager.Instance:Open(ViewName.VipView)
	    end
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.MapFind.SelectCell)
		return
	end
end


MapfindRushItem = MapfindRushItem or BaseClass(BaseRender)
function MapfindRushItem:__init()
	self.node_list["Img"].toggle.onValueChanged:AddListener(BindTool.Bind(self.OnClick, self))
	self.cell = ItemCell.New()
	self.cell:SetInstanceParent(self.node_list["ItemCell"])
end

function MapfindRushItem:LoadCallBack()

end
function MapfindRushItem:__delete()
	if self.cell then
		self.cell:DeleteMe()
	end
end

function MapfindRushItem:SetData(data)
	self.index = data
	local name = MapFindData.Instance:GetNameById(data)
	local temp = MapFindData.Instance:GetMapRewardData(self.index)
	self.node_list["Txt"].text.text = name
	self.node_list["TextName"].text.text = name
	self.cell:SetData(temp ~= nil and temp.base_reward_item or temp)
end

function MapfindRushItem:OnClick(isOn)
	MapFindData.Instance:SetSelect(self.index, isOn)
end

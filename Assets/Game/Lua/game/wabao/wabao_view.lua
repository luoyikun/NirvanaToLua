WaBaoView = WaBaoView or BaseClass(BaseView)

function WaBaoView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel_1"},
		{"uis/views/wabao_prefab", "WaBaoContent"},
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel_3"},}
	self.full_screen = false
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
end

function WaBaoView:LoadCallBack()

	self.node_list["TitleText"].text.text = Language.Title.WaBao

	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.OnCloseClick, self))
	self.node_list["BtnGo"].button:AddClickListener(BindTool.Bind(self.XunBaoClick, self))
	self.node_list["BtnFask"].button:AddClickListener(BindTool.Bind(self.OnQuickClick, self))
	self.node_list["ImgTip"].button:AddClickListener(BindTool.Bind(self.OnTipClick, self))
	self.node_list["Btn"].button:AddClickListener(BindTool.Bind(self.OnGoClick, self))

	self.item_cell_list = {}
	for i = 1, 3 do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self.node_list["item" .. i])
	end

	local cfg = WaBaoData.Instance:GetShowItems()
	for i = 1, 3 do
		self.item_cell_list[i]:SetData(cfg[i])
	end
end

function WaBaoView:ReleaseCallBack()
	for i = 1, 3 do
		self.item_cell_list[i]:DeleteMe()
		self.item_cell_list[i] = nil
	end
	self.item_cell_list = {}

	self.daoju_display = nil
end

function WaBaoView:OpenCallBack()
	local pos_cfg = WaBaoData.Instance:GetWaBaoInfo()
	if pos_cfg and next(pos_cfg) and pos_cfg.baotu_count ~= 0 and pos_cfg.baozang_scene_id == 0 then
		WaBaoCtrl.SendWabaoOperaReq(WA_BAO_OPERA_TYPE.OPERA_TYPE_START, 0)
	end
	self:Flush()
end

function WaBaoView:OnCloseClick()
	self:Close()
end

function WaBaoView:CloseCallBack()

end

function WaBaoView:OnFlush()
	local pos_cfg = WaBaoData.Instance:GetWaBaoInfo()
	if pos_cfg and next(pos_cfg) and pos_cfg.baozang_scene_id and pos_cfg.baozang_scene_id ~= 0 then
		local bundle, asset = ResPath.GetWaBaoPic(pos_cfg.baozang_scene_id)
		self.node_list["RawImg"].raw_image:LoadSprite(bundle, asset)
		local scene_cfg = ConfigManager.Instance:GetSceneConfig(pos_cfg.baozang_scene_id)
		self.node_list["TxtBg"].text.text = string.format(Language.WaBao.TipsLocation, scene_cfg.name)
	end
	self.node_list["Txtum"].text.text = pos_cfg.baotu_count

	local now_total_degree = WaBaoData.Instance:GetActiveDegree()
	local max_total_degree = WaBaoData.Instance:GetMaxActiveDegree()
	self.node_list["TxtNowActive"].text.text = string.format(Language.WaBao.NowTotalDegree, now_total_degree, max_total_degree)
	self.node_list["SliderProgress02"].slider.value = now_total_degree / max_total_degree
end

function WaBaoView:XunBaoClick()
	local wabao_data = WaBaoData.Instance
	local info = wabao_data:GetWaBaoInfo()
	if info.baozang_scene_id == 0 then
		if info.baotu_count > 0 then
			wabao_data:SetWaBaoFlag(true)
			WaBaoCtrl.SendWabaoOperaReq(WA_BAO_OPERA_TYPE.OPERA_TYPE_START, 0)
			self:Close()
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.Common.WaBaoLimit)
		end
	elseif info.baozang_scene_id and info.wabao_reward_type == 0 then
		local callback = function()
			MoveCache.cant_fly = true
			GuajiCtrl.Instance:MoveToPos(info.baozang_scene_id, info.baozang_pos_x, info.baozang_pos_y, 0, 0)
		end
		callback()
		GuajiCtrl.Instance:SetMoveToPosCallBack(callback)
		self:Close()
	end
end

function WaBaoView:OnQuickClick()
	local info = WaBaoData.Instance:GetWaBaoInfo()
	local cfg = WaBaoData.Instance:GetOtherCfg()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local my_money = vo.gold + vo.bind_gold
	local pos_cfg = WaBaoData.Instance:GetWaBaoInfo()

	local left_complete_times = pos_cfg.baotu_count or 0
	local describe = string.format(Language.Daily.WaBaoRenWu, ToColorStr(cfg.quick_complete_cost * left_complete_times, TEXT_COLOR.YELLOW))
	local call_back = function ()
		if my_money >= cfg.quick_complete_cost then
			GuajiCtrl.Instance:StopGuaji()
			WaBaoCtrl.SendWabaoOperaReq(WA_BAO_OPERA_TYPE.OPERA_TYPE_QUICK_COMPLETE, 0)
			WaBaoData.Instance:SetFastWaBaoFlag(true)
		else
			TipsCtrl.Instance:ShowLackDiamondView()
		end
	end

	TipsCtrl.Instance:ShowCommonAutoView("advance_index", describe, call_back, nil, nil)
	
	self:Flush()
end

function WaBaoView:OnTipClick()
	TipsCtrl.Instance:ShowHelpTipView(170)
end

function WaBaoView:OnGoClick()
	self:Close()
	ViewManager.Instance:Open(ViewName.BaoJu)
end
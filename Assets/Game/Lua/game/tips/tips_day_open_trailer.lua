TipsDayOpenTrailerView = TipsDayOpenTrailerView or BaseClass(BaseView)
function TipsDayOpenTrailerView:__init()
	self.ui_config = {{"uis/views/tips/funtrailer_prefab", "FunTrailerTips"}}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
end

function TipsDayOpenTrailerView:__delete()
end

function TipsDayOpenTrailerView:LoadCallBack()

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnCloseClick, self))
	self.node_list["BtnAutomatic"].button:AddClickListener(BindTool.Bind(self.OnClickReward, self))

	self.item_list = {}
	for i = 1, 3 do
		self.item_list[i] = {}
		self.item_list[i].root = self.node_list["Item" .. i]
		self.item_list[i].item = ItemCell.New()
		self.item_list[i].item:SetInstanceParent(self.item_list[i].root)
	end
end

function TipsDayOpenTrailerView:ReleaseCallBack()
	-- 清理变量和对象
	for k,v in pairs(self.item_list) do
		v.item:DeleteMe()
	end
	self.item_list = {}
end

function TipsDayOpenTrailerView:SetData(cfg)
	self.cfg = cfg
	self:Open()
end

function TipsDayOpenTrailerView:OpenCallBack()
	self:Flush()
end

function TipsDayOpenTrailerView:OnFlush()
	if self.cfg then
		local bundle, asset = ResPath.GetMainIcon(self.cfg.res_icon)
		self.node_list["ImgIcon"].image:LoadSprite(bundle, asset)
		if self.node_list["IconName"] then
			self.node_list["IconName"].image:LoadSprite(bundle, asset .. "Name", function()
				self.node_list["IconName"].image:SetNativeSize()
				self.node_list["IconName"].transform:SetLocalScale(1.2, 1.2, 1.2)
			end)
		end
		self.node_list["TxtDesc"].text.text = self.cfg.fun_dec
		if self.cfg.open_name then
			self.node_list["TxtName"].text.text = self.cfg.open_name
		end
		self.node_list["TxtOpenDesc"].text.text = self.cfg.open_dec or ""
		for k,v in pairs(self.item_list) do
			if self.cfg.reward_item[k -1] then
				v.item:SetData(self.cfg.reward_item[k -1])
			end
			v.root:SetActive(self.cfg.reward_item[k -1] ~= nil)
		end
		local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
		local level = GameVoManager.Instance:GetMainRoleVo().level
		local is_receive = OpenFunData.Instance:GetDayTrailerLastRewardId(self.cfg.id)
		UI:SetButtonEnabled(self.node_list["BtnAutomatic"], (self.cfg.open_day <= open_server_day and level >= self.cfg.level_limit and is_receive == 0))
		self.node_list["Txt"].text.text = self.cfg.open_panel_name ~= "" and Language.Mainui.TrailerBtnText[1] or Language.Mainui.TrailerBtnText[2]
	end
end

function TipsDayOpenTrailerView:OnCloseClick()
	self:Close()
end

function TipsDayOpenTrailerView:OnClickReward()
	OpenFunCtrl.Instance:SendAdvanceNoitceOperate(ADVANCE_NOTICE_OPERATE_TYPE.ADVANCE_NOTICE_DAY_FETCH_REWARD, self.cfg.id)
	local level = GameVoManager.Instance:GetMainRoleVo().level
	if self.cfg then
		local is_receive = OpenFunData.Instance:GetDayTrailerLastRewardId(self.cfg.id)
		if level >= self.cfg.level_limit and is_receive == 0 then
			self:Close()
			if self.cfg.fun_name ~= "" then
				ViewManager.Instance:OpenByCfg(self.cfg.fun_name)
			end
		end
	end
	
end

XianMengWarView = XianMengWarView or BaseClass(BaseView)

function XianMengWarView:__init()
	self.ui_config = {{"uis/views/citycombatview_prefab","XianMengWarView"}}
	self.play_audio = true

	self.act_id = ACTIVITY_TYPE.GUILDBATTLE
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function XianMengWarView:__delete()

end

function XianMengWarView:ReleaseCallBack()
	if self.cz_item_cell_list then
		for k,v in pairs(self.cz_item_cell_list) do
			v:DeleteMe()
		end
	end

	self.cz_item_cell_list = nil

	if self.cy_item_cell_list then
		for k,v in pairs(self.cy_item_cell_list) do
			v:DeleteMe()
		end
	end

	self.cy_item_cell_list = nil

	if self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end
	TitleData.Instance:ReleaseTitleEff(self.node_list["Title"])
end

function XianMengWarView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.ClickHelp, self))
	self.node_list["BtnGo"].button:AddClickListener(BindTool.Bind(self.ClickEnter, self))

	self.cz_item_cell_list = {}
	for i = 1, 4 do
		self.cz_item_cell_list[i] = ItemCell.New()
		self.cz_item_cell_list[i]:SetInstanceParent(self.node_list["ItemChengZhu" .. i])
		self.cz_item_cell_list[i]:SetActive(false)
	end

	self.cy_item_cell_list = {}
	for i = 1, 3 do
		self.cy_item_cell_list[i] = ItemCell.New()
		self.cy_item_cell_list[i]:SetInstanceParent(self.node_list["ItemNormal" .. i])
		self.cy_item_cell_list[i]:SetActive(false)
	end
	local title_id = TitleData.Instance:GetActivityTitleByType(ACTIVITY_TYPE.GUILDBATTLE)
	if title_id then
		self.node_list["Title"].image:LoadSprite(ResPath.GetTitleIcon(title_id))
		TitleData.Instance:LoadTitleEff(self.node_list["Title"], title_id, true)
	end	
end

function XianMengWarView:OpenCallBack()
	self:FlushTuanZhangModel()
	self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)
	self:Flush()
end

function XianMengWarView:CloseCallBack()
	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end
end

function XianMengWarView:CloseWindow()
	self:Close()
end

function XianMengWarView:FlushReward()
	local cfg = CityCombatData.Instance:GetHefuCfg()
	if nil == cfg then
		return
	end

	local other_config = cfg.other[1]
	local libao_list = {}
	local all_list = {}
	for k, v in pairs(other_config.xmz_mengzhu_reward) do
		local item_cfg, big_type = ItemData.Instance:GetItemConfig(v.item_id)
		if big_type ~= GameEnum.ITEM_BIGTYPE_GIF then
			table.insert(all_list, v)
		else
			libao_list = ItemData.Instance:GetGiftItemList(v.item_id)	
			for i,v1 in ipairs(libao_list) do
				table.insert(all_list, v1)
			end
		end
	end
	
	for k, v in pairs(self.cz_item_cell_list) do
		self.cz_item_cell_list[k]:SetActive(all_list[k] ~= nil)
		self.cz_item_cell_list[k]:SetData(all_list[k])
	end

	for k, v in pairs(other_config.xmz_camp_reward) do
		if v.item_id > 0 and self.cy_item_cell_list[k + 1] then
			self.cy_item_cell_list[k + 1]:SetActive(true)
			self.cy_item_cell_list[k + 1]:SetData(v)
		end
	end
end

function XianMengWarView:ClickHelp()
	local act_info = ActivityData.Instance:GetClockActivityByID(self.act_id)
	if not next(act_info) then return end
	TipsCtrl.Instance:ShowHelpTipView(act_info.play_introduction)
end

function XianMengWarView:FlushTuanZhangModel(uid, info)
	info = GameVoManager.Instance:GetMainRoleVo()
	if not self.role_model then
		self.role_model = RoleModel.New()
		self.role_model:SetDisplay(self.node_list["RoleDisplay"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	end
	if self.role_model then
		self.role_model:SetModelResInfo(info, false, true, true)
	end
end

function XianMengWarView:OnFlush()
	local act_info = ActivityData.Instance:GetActivityInfoById(self.act_id)
	if not next(act_info) then return end

	self:FlushReward()
end

function XianMengWarView:ActivityCallBack(activity_type)
	if activity_type == self.act_id then
		self:Flush()
	end
end

function XianMengWarView:ClickEnter()
	self:Close()
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	if guild_id > 0 then
		ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_war)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.PleaseJoinGuild)
		ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_request)
	end
end
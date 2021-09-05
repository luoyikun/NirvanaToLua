BaoBaoLongFengTipsView = BaoBaoLongFengTipsView or BaseClass(BaseView)

function BaoBaoLongFengTipsView:__init()
	self.ui_config = {{"uis/views/marriageview/baobao_prefab", "LongFengBaoBaoFengView"}}
	-- self.view_layer = UiLayer.Pop
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function BaoBaoLongFengTipsView:LoadCallBack()
	self.node_list["ButtonLong"].button:AddClickListener(BindTool.Bind(self.OnClickLong, self))
	self.node_list["ButtonFeng"].button:AddClickListener(BindTool.Bind(self.OnClickFeng, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnCloseView, self))


	self.display_long = RoleModel.New()
	self.display_long:SetDisplay(self.node_list["DisplayLong"].ui3d_display, MODEL_CAMERA_TYPE.BASE)

	self.display_feng = RoleModel.New()
	self.display_feng:SetDisplay(self.node_list["DisplayFeng"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	local event_trigger = self.node_list["ModelEventTrigerLong"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDragSelfLong, self))
	local event_trigger = self.node_list["ModelEventTrigerFeng"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDragSelfFeng, self))
end


function BaoBaoLongFengTipsView:OnRoleDragSelfLong(data)
	if self.display_long then
		self.display_long:Rotate(0, -data.delta.x * 0.25, 0)
	end
end
function BaoBaoLongFengTipsView:OnRoleDragSelfFeng(data)
	if self.display_feng then
		self.display_feng:Rotate(0, -data.delta.x * 0.25, 0)
	end
end


function BaoBaoLongFengTipsView:ReleaseCallBack()
	if self.display_long then
		self.display_long:DeleteMe()
		self.display_long = nil
	end
	if self.display_feng then
		self.display_feng:DeleteMe()
		self.display_feng = nil
	end
end

function BaoBaoLongFengTipsView:CloseCallBack()

end

function BaoBaoLongFengTipsView:OnCloseView()
	self:Close()
end

function BaoBaoLongFengTipsView:OnClickLong()
	local quilis_list = BaobaoData.Instance:SetLongFenBabyInfo(0)
	if quilis_list[1] then
		MarryEquipCtrl.SendQingyuanEquipOperate(QINGYUAN_EQUIP_REQ_TYPE.QINGYUAN_EQUIP_REQ_ACTIVE_SPECIAL_BABY, 0 ,quilis_list[1])
	else
		 BiaoBaiQiangCtrl.Instance:OpenNanShenRank()
		-- SysMsgCtrl.Instance:ErrorRemind(Language.Exchange.NotEnoughItem)
	end
end

function BaoBaoLongFengTipsView:OnClickFeng()
	local quilis_list = BaobaoData.Instance:SetLongFenBabyInfo(1)
	if quilis_list[1]  then
		MarryEquipCtrl.SendQingyuanEquipOperate(QINGYUAN_EQUIP_REQ_TYPE.QINGYUAN_EQUIP_REQ_ACTIVE_SPECIAL_BABY, 1 ,quilis_list[1])
	else
		 BiaoBaiQiangCtrl.Instance:OpenNvShenRank()
		-- SysMsgCtrl.Instance:ErrorRemind(Language.Exchange.NotEnoughItem)
	end
end

function BaoBaoLongFengTipsView:OpenCallBack()
	MarryEquipCtrl.SendQingyuanEquipOperate(QINGYUAN_EQUIP_REQ_TYPE.SELF_EQUIP_INFO)
	MarryEquipCtrl.SendActiveLoverEquipInfo()
	self:Flush()
end

function BaoBaoLongFengTipsView:OnFlush()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local sex = main_role_vo.sex
	local data_list = {}
	local data_list1 = {}
	local longbaby_index = 1
	local fenbaby_index = 2
	if sex == 1 then
		data_list = BaobaoData.Instance:GetEquipLongInfo(longbaby_index)
		data_list1 = BaobaoData.Instance:GetEquipFengInfo(fenbaby_index)
	else
		data_list1 = BaobaoData.Instance:GetEquipLongInfo(fenbaby_index)
		data_list = BaobaoData.Instance:GetEquipFengInfo(longbaby_index)
	end
	local data_index = 0
	local data_index2 = 0
	if data_list then
		if data_list.special_baby_level ~= 0 and data_list.quality ~= 0 then
			data_index = data_list.quality
			self.node_list["ButtonLong"]:SetActive(false)
			self.node_list["LongImage"]:SetActive(true)
		else
			data_index = BaobaoData.Instance:GetMaxQualityNum(longbaby_index - 1)
			self.node_list["ButtonLong"]:SetActive(true)
			self.node_list["LongImage"]:SetActive(false)
		end
	end
	if  data_list1 then
		if data_list1.special_baby_level ~= 0 and data_list1.quality ~= 0 then
			data_index2 = data_list1.quality
			self.node_list["ButtonFeng"]:SetActive(false)
			self.node_list["FengImage"]:SetActive(true)
		else
			data_index2 = BaobaoData.Instance:GetMaxQualityNum(fenbaby_index - 1)
			self.node_list["ButtonFeng"]:SetActive(true)
			self.node_list["FengImage"]:SetActive(false)
		end
	end
	local attr_cfg = BaobaoData.Instance:GetEquipBaoBaoLongFen(0,data_index)
	local attr_cfg1 = BaobaoData.Instance:GetEquipBaoBaoLongFen(1,data_index2)
	self.node_list["LongNumber"].text.text = attr_cfg
	self.node_list["FenNumber"].text.text = attr_cfg1
	local data_1  = BaobaoData.Instance:SetLongFenBabyInfo(0)
	local data_2  = BaobaoData.Instance:SetLongFenBabyInfo(1)
	if data_1[1] then
		self.node_list["RewardText"].text.text = Language.MarryBaoBao.LongFenTip 
	else
		self.node_list["RewardText"].text.text = Language.MarryBaoBao.LongFenBabyTip 
	end
	if data_2[1] then
		self.node_list["RewardText1"].text.text = Language.MarryBaoBao.LongFenTip 
	else
		self.node_list["RewardText1"].text.text = Language.MarryBaoBao.LongFenBabyTip 
	end
	local long_image = longbaby_index > 0 and longbaby_index or 10
	local fen_image = fenbaby_index > 0 and fenbaby_index or 10
	local long_id, long_scale = BaobaoData.Instance:GetMaxLongFenBaoBaoCfg(longbaby_index,long_image)
	local feng_id, feng_scale = BaobaoData.Instance:GetMaxLongFenBaoBaoCfg(fenbaby_index,fen_image)
	self:FlsuhLongModel(long_id,long_scale)
	self:FlushFengModel(feng_id,feng_scale)
end

function BaoBaoLongFengTipsView:FlsuhLongModel(index, scale)
	self.display_long:SetMainAsset(ResPath.GetSpiritModel(index))
	self.display_long:ResetRotation()
	self.display_long:SetRotation(Vector3(0, 0, 0))
	self.display_long:SetScale(Vector3(scale, scale, scale))
end

function BaoBaoLongFengTipsView:FlushFengModel(index, scale)
	self.display_feng:SetMainAsset(ResPath.GetSpiritModel(index))
	self.display_feng:ResetRotation()
	self.display_feng:SetRotation(Vector3(0, 0, 0))
	self.display_feng:SetScale(Vector3(scale, scale, scale))
end

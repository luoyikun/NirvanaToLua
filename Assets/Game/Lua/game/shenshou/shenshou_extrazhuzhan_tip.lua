ShenShouExtraZhuZhanTip = ShenShouExtraZhuZhanTip or BaseClass(BaseView)

function ShenShouExtraZhuZhanTip:__init()
	self.ui_config = {{"uis/views/shenshouview_prefab", "ShenShouExtraZhuZhanTip"}}
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function ShenShouExtraZhuZhanTip:__delete()

end

function ShenShouExtraZhuZhanTip:ReleaseCallBack()
	if self.stuff_cell then
		self.stuff_cell:DeleteMe()
		self.stuff_cell = nil
	end
end

function ShenShouExtraZhuZhanTip:LoadCallBack()
	self.stuff_cell = ItemCell.New()
	self.stuff_cell:SetInstanceParent(self.node_list["Item"])

	self.node_list["BtnYes"].button:AddClickListener(BindTool.Bind(self.OnClinkOkHandler, self))
	self.node_list["BtnNo"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	--self.node_list["BtnBg"].button:AddClickListener(BindTool.Bind(self.Close, self))
end

function ShenShouExtraZhuZhanTip:ShowIndexCallBack()
	self:Flush()
end

function ShenShouExtraZhuZhanTip:OnFlush()
	local extra_num_cfg = ConfigManager.Instance:GetAutoConfig("shenshou_cfg_auto").extra_num_cfg
	local extra_zhuzhan_count = ShenShouData.Instance:GetExtraZhuZhanCount()
	local next_count = extra_zhuzhan_count + 1 < #extra_num_cfg and extra_zhuzhan_count + 1 or #extra_num_cfg
	local num_cfg = ShenShouData.Instance:GetExtraNumCfg(next_count)
	self.stuff_cell:SetData({item_id = num_cfg.stuff_id, is_bind = 1})

	local item_num = ItemData.Instance:GetItemNumInBagById(num_cfg.stuff_id)
	local color = item_num >= num_cfg.stuff_num and "#89F201"or "#f9463b"
	local str = "<color=%s>%s</color><color=#89F201> / %s</color>"
	self.node_list["TxtTips3"].text.text = string.format(str, color, item_num, num_cfg.stuff_num)
	local stuff_name = ItemData.Instance:GetItemName(num_cfg.stuff_id)
	local item_cfg = ItemData.Instance:GetItemConfig(num_cfg.stuff_id)
	self.node_list["TxtTips1"].text.text = string.format(Language.ShenShou.RichDes1, SOUL_NAME_COLOR[item_cfg.color], stuff_name)
	self.node_list["TxtTips2"].text.text = ""
end

function ShenShouExtraZhuZhanTip:OnClinkOkHandler()
	local extra_zhuzhan_count = ShenShouData.Instance:GetExtraZhuZhanCount()
	local extra_num_cfg = ConfigManager.Instance:GetAutoConfig("shenshou_cfg_auto").extra_num_cfg
	if extra_zhuzhan_count == #extra_num_cfg then
		SysMsgCtrl.Instance:ErrorRemind(Language.ShenShou.ExtraZhuZhanError)
		return
	end
	ShenShouCtrl.Instance:SendShenshouOperaReq(SHENSHOU_REQ_TYPE.SHENSHOU_REQ_TYPE_ADD_ZHUZHAN)
	self:Close()
end
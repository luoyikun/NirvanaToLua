-- 仙宠-仙阵-已屏蔽
XianZhenUpGradeView = XianZhenUpGradeView or BaseClass(BaseRender)

function XianZhenUpGradeView:__init(instance)
	self.node_list["AutoBuyToggle"].toggle.onValueChanged:AddListener(BindTool.Bind(self.OnAutoBuyClick, self))
	self.node_list["BtnPromote"].button:AddClickListener(BindTool.Bind(self.OnClickUpGarde, self))

	self.node_list["AutoBuyToggle"].toggle.isOn = false
	self.exp = nil
	self.assetRes = 0
end

function XianZhenUpGradeView:__delete()
	self.exp = nil
end

function XianZhenUpGradeView:OnFlush()
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	local zhenfa_level = spirit_info.xianzhen_level
	local zhenfa_exp = spirit_info.xianzhen_exp
	local xianzhen_up_count = spirit_info.xianzhen_up_count
	local cur_zhenfa_cfg = SpiritData.Instance:GetZhenfaCfgByLevel(zhenfa_level)
	if nil == cur_zhenfa_cfg then 
		print_error("cur_zhenfa_cfg is nil !!!")
		return
	end
	local zhenfa_effect_res = cur_zhenfa_cfg.effect
	self:SetZhenFaLevelEffect(zhenfa_effect_res)
	if zhenfa_level == SpiritData.Instance:GetZhenfaMaxLevel() then
		self.node_list["lingzhen_lv"].text.text = "LV." .. zhenfa_level
		self.node_list["ImgStar"]:SetActive(false)
		self.node_list["ImgExp"]:SetActive(false)
		self.node_list["TxtComsumeTips"]:SetActive(false)
		self.node_list["BtnPromote"]:SetActive(false)
		self.node_list["Txtmaxlevel"]:SetActive(true)
	end

	self.node_list["AutoBuyContent"]:SetActive(not (zhenfa_level == SpiritData.Instance:GetZhenfaMaxLevel()))

	local zhenfa_max_hp = cur_zhenfa_cfg.maxhp
	local common_rate = cur_zhenfa_cfg.convert_rate

	local next_zhenfa_cfg = SpiritData.Instance:GetZhenfaCfgByLevel(zhenfa_level + 1)
	if nil == next_zhenfa_cfg then
		next_zhenfa_cfg = cur_zhenfa_cfg
	end
	local leveup_need_exp = cur_zhenfa_cfg.need_exp

	self.node_list["lingzhen_lv"].text.text = "LV." .. zhenfa_level
	if nil == self.exp then
		self.exp = zhenfa_exp
	else
		if zhenfa_exp > self.exp then
			if zhenfa_exp - self.exp > 10 * cur_zhenfa_cfg.stuff_num then
				local value = zhenfa_exp - self.exp
				self:ShowFlyText(self.node_list["fly_word_pos"],value,true)
				self.node_list["baoji_lizi"]:GetComponent(typeof(UnityEngine.ParticleSystem)):Play()
				self.node_list["baoji_lizi"]:SetActive(true)

			else
				local value = zhenfa_exp - self.exp

				self:ShowFlyText(self.node_list["fly_word_pos"],value,false)
			end
		end

		self.exp = zhenfa_exp
	end

	self.node_list["TxtExp"].text.text = zhenfa_exp .. "/" .. leveup_need_exp
	self.node_list["exp_slider"].slider.value = zhenfa_exp / leveup_need_exp

	local activate_bundle, activate_asset = ResPath.GetSpiritIcon("full_star")
	local gray_bundle, gray_asset = ResPath.GetSpiritIcon("empty_star")

	for i = 1, 4 do
		if zhenfa_level == SpiritData.Instance:GetZhenfaMaxLevel() then
			self.node_list["Star" .. i].image:LoadSprite(gray_bundle, gray_asset)
		else
			if i <= xianzhen_up_count then
				self.node_list["Star" .. i].image:LoadSprite(activate_bundle, activate_asset)
			else
				self.node_list["Star" .. i].image:LoadSprite(gray_bundle, gray_asset)
			end
		end
	end 

	self.node_list["Txtpercent1"].text.text = common_rate / 100 .. "%"
	self.node_list["Txtpercent2"].text.text = zhenfa_max_hp
	self.node_list["Txtpercent3"].text.text = next_zhenfa_cfg.convert_rate / 100 .. "%"
	self.node_list["Txtpercent4"].text.text = next_zhenfa_cfg.maxhp

	local item_id = SpiritData.Instance:GetSpiritOtherCfg().xianzhen_stuff_id or 0
	local item_cfg = ItemData.Instance:GetItemConfig(item_id) or {}
	local item_num = ItemData.Instance:GetItemNumInBagById(item_id)
	if item_num >= cur_zhenfa_cfg.stuff_num then
	 	local str = string.format(Language.JingLing.ZhenFaCostDesc, item_cfg.name or "", item_num,cur_zhenfa_cfg.stuff_num)
	 	self.node_list["TxtComsumeTips"].text.text = str
	else
	 	local str = string.format(Language.JingLing.ZhenFaLessCostDesc, item_cfg.name or "", item_num,cur_zhenfa_cfg.stuff_num)
	 	self.node_list["TxtComsumeTips"].text.text = str
	end
	local name_color = ITEM_COLOR[cur_zhenfa_cfg.xianzhen_color or 0] or TEXT_COLOR.WHITE
	local xianzhen_name = ToColorStr(cur_zhenfa_cfg.xianzhen_name, name_color)
	self.node_list["TxtZhenfaName"].text.text = xianzhen_name

end

function XianZhenUpGradeView:OnClickUpGarde()
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	local zhenfa_level = spirit_info.xianzhen_level
	local cur_zhenfa_cfg = SpiritData.Instance:GetZhenfaCfgByLevel(zhenfa_level)
	local item_id = SpiritData.Instance:GetSpiritOtherCfg().xianzhen_stuff_id or 0
	local item_num = ItemData.Instance:GetItemNumInBagById(item_id)
	if item_num >= cur_zhenfa_cfg.stuff_num then
		SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_UPLEVEL_XIANZHEN, 0)
	else
		if self.node_list["AutoBuyToggle"].toggle.isOn then
			SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_UPLEVEL_XIANZHEN, 1)
		else
			--打开购买物品界面
			local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
				MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
				self.node_list["AutoBuyToggle"].toggle.isOn = is_buy_quick
				self:Flush()
			end
			local nofunc = function()
			end

			TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nofunc, 1)
		end
	end
end

function XianZhenUpGradeView:OnAutoBuyClick(is_auto_buy)
	self.node_list["AutoBuyToggle"].toggle.isOn = is_auto_buy
end

function XianZhenUpGradeView:ShowFlyText(begin_obj, value,isbaoji)
	ResPoolMgr:GetDynamicObjAsync("uis/views/spiritview_prefab", "exp_up_fly_word", function(obj)
			local node_list = U3DNodeList(obj:GetComponent(typeof(UINameTable)))
			local Text = obj:GetComponent(typeof(UnityEngine.UI.Text))
			if isbaoji and variable_table then
				Text.fontSize = 26
				local str = string.format(Language.JingLing.ZhenFaBaojiFlyWord,value)
				node_list["exp_up_fly_word"].text.text = str
			else
				Text.fontSize = 24
				local str = string.format(Language.JingLing.ZhenFaFlyWord,value)
				node_list["exp_up_fly_word"].text.text = str
			end
			obj.transform:SetParent(begin_obj.transform, false)
			local tween = obj.transform:DOLocalMoveY(80, 0.5)
			tween:SetEase(DG.Tweening.Ease.Linear)
			tween:OnComplete(BindTool.Bind(self.OnMoveEnd, self, obj))
		end)
end

function XianZhenUpGradeView:OnMoveEnd(obj)
	if not IsNil(obj) then
		ResMgr:Destroy(obj)
	end
end

function XianZhenUpGradeView:SetZhenFaLevelEffect(assetRes)
	if self.assetRes ~= assetRes then
		local bundle, asset = ResPath.GetZhenfaEffect(assetRes)
		self.assetRes = assetRes

		local async_loader = AllocAsyncLoader(self, "effect_loader")
		async_loader:Load(bundle, asset, function(obj)
			if not IsNil(obj) then
				if self.zhenfa_effect_obj  ~= nil then
					ResMgr:Destroy(self.zhenfa_effect_obj)
					self.zhenfa_effect_obj = nil
				end

				local transform = obj.transform
				transform:SetParent(self.node_list["zhentuPos"].transform, false)
				self.zhenfa_effect_obj = obj.gameObject
			end
		end)
	end
end

function XianZhenUpGradeView:CloseCallBack()
	self.node_list["AutoBuyToggle"].toggle.isOn = false
end

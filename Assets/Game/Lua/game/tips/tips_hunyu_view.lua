TipsHunyuView = TipsHunyuView or BaseClass(BaseView)
local EFFECT = {
	-- [4] = "uieffect_sjcz_dc",
	[5] = "zhuangbei_redbiaomian",
	[6] = "zhuangbei_fenbiaomian",
}

local EFFECT2 = {
	[5] = "zhuangbei_red",
	[6] = "zhuangbei_fen",
}
function TipsHunyuView:__init()
	self.ui_config = {{"uis/views/baoju_prefab", "RoleHunyuTip"}}
	self.view_layer = UiLayer.Pop
	
	self.data = nil
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
end

function TipsHunyuView:ReleaseCallBack()
	if self.item_effect then
		ResPoolMgr:Release(self.item_effect)
		self.item_effect = nil
	end
	if self.item_effect2 then
		ResPoolMgr:Release(self.item_effect2)
		self.item_effect2 = nil
	end

	if self.other_frame_view then
		self.other_frame_view:DeleteMe()
		self.other_frame_view = nil
	end
	self.fight_text = nil
end

function TipsHunyuView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close,self))

	self.other_frame_view = OtherHunyuView.New(self.node_list["OtherFrame"])

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["Fight"])
end

function TipsHunyuView:CloseCallBack()
	self.compare_data = nil
end

function TipsHunyuView:SetData(data, is_compare)
	if not data then return end
	if is_compare then
		local cur_jingjie_level = JingJieData.Instance:GetjingjieLevel()
		local cfg = JingJieData.Instance:GetjingjieCfg(cur_jingjie_level)
		self.compare_data = cfg
	else
		self.compare_data = nil
	end
	self.data = data
end

function TipsHunyuView:OpenCallBack()
	self:Flush()
end

function TipsHunyuView:OnFlush()
	if nil == self.data then return end

	self.node_list["GongJi"].text.text = ToColorStr(Language.Player.AttrNameShengYin.gongji, TEXT_COLOR.WHITE) .. ToColorStr(self.data.gongji, TEXT_COLOR.GREEN)
	self.node_list["FangYu"].text.text = ToColorStr(Language.Player.AttrNameShengYin.fangyu, TEXT_COLOR.WHITE) .. ToColorStr(self.data.fangyu, TEXT_COLOR.GREEN)
	self.node_list["Hp"].text.text = ToColorStr(Language.Player.AttrNameShengYin.maxhp, TEXT_COLOR.WHITE) .. ToColorStr(self.data.maxhp, TEXT_COLOR.GREEN)
	self.node_list["Name"].text.text = self.data.name_hunyu
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = CommonDataManager.GetCapabilityCalculation(self.data)
	end
	self.node_list["ItemImage"].image:LoadSprite(ResPath.GetHunyuIcon(self.data.pic_hunyu))
	self.node_list["Bg"].image:LoadSprite(ResPath.GetQualityIcon(self.data.color))
	self.node_list["ItemBg"].raw_image:LoadSprite(ResPath.GetQualityRawBgIcon(self.data.color))
	-- self.node_list["Line"].image:LoadSprite(ResPath.GetQualityLineBgIcon(self.data.color))

	if self.item_effect then
		ResPoolMgr:Release(self.item_effect)
		self.item_effect = nil
	end
	if self.item_effect2 then
		ResPoolMgr:Release(self.item_effect2)
		self.item_effect2 = nil
	end
	if EFFECT[self.data.color] then
		local effect_bundle, effect_asset = ResPath.GetUiXEffect(EFFECT[self.data.color])
			ResPoolMgr:GetEffectAsync(effect_bundle, effect_asset, function(obj)
			if nil == obj then
				return
			end
			self.item_effect = obj
			obj.transform:SetParent(self.node_list["Bg"].transform)
			obj.transform.localScale = Vector3(1, 1, 1)
			obj.transform.localPosition = Vector3(0, 0, 0)
		end)
	end

	if EFFECT2[self.data.color] then
		local effect_bundle, effect_asset = ResPath.GetUiXEffect(EFFECT2[self.data.color])
			ResPoolMgr:GetEffectAsync(effect_bundle, effect_asset, function(obj)
			if nil == obj then
				return
			end
			self.item_effect2 = obj
			obj.transform:SetParent(self.node_list["EffectDi"].transform)
			obj.transform.localScale = Vector3(1, 1, 1)
			obj.transform.localPosition = Vector3(0, 0, 0)
		end)
	end

	if self.compare_data and next(self.compare_data) then
		self.node_list["Frame"].rect.anchoredPosition = Vector3(205, 0, 0)
		self.node_list["OtherFrame"]:SetActive(true)
		-- UITween.AlpahShowPanel(self.node_list["OtherFrame"] , true, 0.3, DG.Tweening.Ease.Linear)
		self.other_frame_view:SetData(self.compare_data)
		-- self.node_list["BtnClose"]:SetActive(false)
	else
		self.node_list["Frame"].rect.anchoredPosition = Vector3(0, 0, 0)
		self.node_list["OtherFrame"]:SetActive(false)
		-- self.node_list["BtnClose"]:SetActive(true)
	end
end



------------------------------------------
--------OtherHunyuView 其他角色
OtherHunyuView = OtherHunyuView or BaseClass(BaseCell)
function OtherHunyuView:__init()
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["Fight"])
end

function OtherHunyuView:__delete()
	if self.item_effect then
		ResPoolMgr:Release(self.item_effect)
		self.item_effect = nil
	end
	if self.item_effect2 then
		ResPoolMgr:Release(self.item_effect2)
		self.item_effect2 = nil
	end
	self.fight_text = nil
end

function OtherHunyuView:OnFlush()
	if nil == self.data then return end

	self.node_list["GongJi"].text.text = ToColorStr(Language.Player.AttrNameShengYin.gongji, TEXT_COLOR.WHITE) .. ToColorStr(self.data.gongji, TEXT_COLOR.GREEN)
	self.node_list["FangYu"].text.text = ToColorStr(Language.Player.AttrNameShengYin.fangyu, TEXT_COLOR.WHITE) .. ToColorStr(self.data.fangyu, TEXT_COLOR.GREEN)
	self.node_list["Hp"].text.text = ToColorStr(Language.Player.AttrNameShengYin.maxhp, TEXT_COLOR.WHITE) .. ToColorStr(self.data.maxhp, TEXT_COLOR.GREEN)
	self.node_list["Name"].text.text = self.data.name_hunyu
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = CommonDataManager.GetCapabilityCalculation(self.data)
	end
	self.node_list["ItemImage"].image:LoadSprite(ResPath.GetHunyuIcon(self.data.pic_hunyu))
	self.node_list["Bg"].image:LoadSprite(ResPath.GetQualityIcon(self.data.color))
	self.node_list["ItemBg"].raw_image:LoadSprite(ResPath.GetQualityRawBgIcon(self.data.color))

	if self.item_effect then
		ResPoolMgr:Release(self.item_effect)
		self.item_effect = nil
	end
	if self.item_effect2 then
		ResPoolMgr:Release(self.item_effect2)
		self.item_effect2 = nil
	end
	if EFFECT[self.data.color] then
		local effect_bundle, effect_asset = ResPath.GetUiXEffect(EFFECT[self.data.color])
			ResPoolMgr:GetEffectAsync(effect_bundle, effect_asset, function(obj)
			if nil == obj then
				return
			end
			self.item_effect = obj
			obj.transform:SetParent(self.node_list["Bg"].transform)
			obj.transform.localScale = Vector3(1, 1, 1)
			obj.transform.localPosition = Vector3(0, 0, 0)
		end)
	end

	if EFFECT2[self.data.color] then
		local effect_bundle, effect_asset = ResPath.GetUiXEffect(EFFECT2[self.data.color])
			ResPoolMgr:GetEffectAsync(effect_bundle, effect_asset, function(obj)
			if nil == obj then
				return
			end
			self.item_effect2 = obj
			obj.transform:SetParent(self.node_list["EffectDi"].transform)
			obj.transform.localScale = Vector3(1, 1, 1)
			obj.transform.localPosition = Vector3(0, 0, 0)
		end)
	end
end

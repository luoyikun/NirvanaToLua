JingJieView = JingJieView or BaseClass(BaseRender)

local PASSIVE_TYPE = 73
local EFFECT = {
	-- [4] = "uieffect_sjcz_dc",
	[5] = "zhuangbei_redbiaomian",
	[6] = "zhuangbei_fenbiaomian",
}

local EFFECT2 = {
	[5] = "zhuangbei_red",
	[6] = "zhuangbei_fen",
}

local EFFECT_CD = 1
function JingJieView:__init()
	self.ui_config = {"uis/views/jingjie_prefab","JingJieView"}
	JingJieCtrl.Instance:RegisterView(self)

	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["NeedItem"])
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["NextNumber"])
	self.fight_text1 = CommonDataManager.FightPower(self, self.node_list["Number"])

	self.cap_is_enough = true
	self.effect_cd = 0
end

function JingJieView:__delete()
	if JingJieCtrl.Instance ~= nil then
		JingJieCtrl.Instance:UnRegisterView()
	end

	if self.item ~= nil then
		self.item:DeleteMe()
		self.item = nil
	end

	if self.item_effect then
		ResPoolMgr:Release(self.item_effect)
		self.item_effect = nil
	end

	if self.item_effect2 then
		ResPoolMgr:Release(self.item_effect2)
		self.item_effect2 = nil
	end

	if self.effect1 then
		ResPoolMgr:Release(self.effect1)
		self.effect1 = nil
	end

	if self.effect2 then
		ResPoolMgr:Release(self.effect2)
		self.effect2 = nil
	end
	self.fight_text = nil
	self.fight_text1 = nil
end

function JingJieView:ReleaseCallBack()
	RemindManager.Instance:UnBind(self.remind_change)
end

function JingJieView:LoadCallBack()
	self.node_list["ButtonLaba"].button:AddClickListener(BindTool.Bind(self.OnClickBuy, self))
	self.node_list["BtnRecycle"].button:AddClickListener(BindTool.Bind(self.OnUpGrade, self))
	self.node_list["BtnToForge"].button:AddClickListener(BindTool.Bind(self.OnBtnToForge, self))
	self.node_list["HunYuBg"].button:AddClickListener(BindTool.Bind(self.OnBtnHunYu, self))
	-- self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	-- RemindManager.Instance:Bind(self.remind_change, RemindName.jingjie)
	self.num = 0
	self.need_num = 0
end


function JingJieView:OpenCallBack()
	self:Flush()
	-- 监听系统事件
	RemindManager.Instance:Fire(RemindName.ZhiBao_jingjie)
	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
end


function JingJieView:CloseCallBack()
	if self.item_data_event ~= nil and ItemData.Instance then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end
function JingJieView:ItemDataChangeCallback()
	self:Flush()
end

function JingJieView:OnBtnHunYu()
	local cur_jingjie_level = JingJieData.Instance:GetjingjieLevel()
	local cfg = JingJieData.Instance:GetjingjieCfg(cur_jingjie_level + 5)
	if cfg == nil then
		cfg = JingJieData.Instance:GetjingjieCfg(cur_jingjie_level)
	end
	TipsCtrl.Instance:ShowHunyuTips(cfg)
end

function JingJieView:OnFlush(param_list)
	local other_cfg = ConfigManager.Instance:GetAutoConfig("rolejingjie_auto").other[1]
	local hurt_per = (other_cfg.yazhi_add_hurt_per / 100)
	local yun_per = (other_cfg.yazhi_xuanyun_trigger_rate / 100)
	local yun_time = (other_cfg.yazhi_xuanyun_durations / 1000)
	self.node_list["Dec"].text.text = (string.format(Language.BaoJu.JingJieDec, hurt_per, yun_per, yun_time))

	local cur_jingjie_level = JingJieData.Instance:GetjingjieLevel()
	local cur_jingjie_cfg = JingJieData.Instance:GetjingjieCfg(cur_jingjie_level)
	self.node_list["LeftInfo"]:SetActive(cur_jingjie_cfg ~= nil)
	-- self.node_list["Arrow"]:SetActive(cur_jingjie_cfg ~= nil)

	if cur_jingjie_cfg then
		self.node_list["HP"].text.text = (cur_jingjie_cfg.maxhp)
		self.node_list["GongJi"].text.text = (cur_jingjie_cfg.gongji)
		self.node_list["FangYu"].text.text = (cur_jingjie_cfg.fangyu or 0)
		self.node_list["CurJingJie"].text.text = cur_jingjie_cfg.name
		-- self.node_list["CurJingJie"].outline.effectColor = JingJieData.GetjingjieColor(cur_jingjie_level)
		if self.fight_text1 and self.fight_text1.text then
			self.fight_text1.text.text = (CommonDataManager.GetCapabilityCalculation(cur_jingjie_cfg))
		end
		local bundle, asset = ResPath.GetJingJieLevelIcon(JingJieData.GetjingjieIcon(cur_jingjie_level))
		self.node_list["LevelImage"].image:LoadSprite(bundle,asset)
		self.node_list["LevelImage"]:SetActive(cur_jingjie_level > 0)
		self.node_list["Wu"]:SetActive(cur_jingjie_level == 0)
		self.node_list["LongXingRank"].text.text = (JingJieData.GetjingjieNum(cur_jingjie_level))
		local next_cfg = JingJieData.Instance:GetjingjieCfg(cur_jingjie_level + 5)
		if next_cfg then
			self.node_list["HunYuImage"].image:LoadSprite(ResPath.GetHunyuIcon(next_cfg.pic_hunyu))
			self.node_list["HunYuBg"].image:LoadSprite(ResPath.GetQualityIcon(next_cfg.color))
			if self.fight_text and self.fight_text.text then
				self.fight_text.text.text = (CommonDataManager.GetCapabilityCalculation(next_cfg))
			end
			self.node_list["NextGold"]:SetActive(true)
			self.node_list["MaxGold"]:SetActive(false)
		else
			self.node_list["HunYuImage"].image:LoadSprite(ResPath.GetHunyuIcon(cur_jingjie_cfg.pic_hunyu))
			self.node_list["HunYuBg"].image:LoadSprite(ResPath.GetQualityIcon(cur_jingjie_cfg.color))
			if self.fight_text and self.fight_text.text then
				self.fight_text.text.text = (CommonDataManager.GetCapabilityCalculation(cur_jingjie_cfg))
			end
			self.node_list["NextGold"]:SetActive(false)
			self.node_list["MaxGold"]:SetActive(true)
		end
		local effect = next_cfg and EFFECT[next_cfg.color] or EFFECT[cur_jingjie_cfg.color]
		local effect2 = next_cfg and EFFECT2[next_cfg.color] or EFFECT2[cur_jingjie_cfg.color]
		if self.item_effect then
			ResPoolMgr:Release(self.item_effect)
			self.item_effect = nil
		end
		if self.item_effect2 then
			ResPoolMgr:Release(self.item_effect2)
			self.item_effect2 = nil
		end		
		if effect then
			local effect_bundle, effect_asset = ResPath.GetUiXEffect(effect)
			ResPoolMgr:GetEffectAsync(effect_bundle, effect_asset, function(obj)
				if IsNil(obj) then
					return
				end
				self.item_effect = obj
				obj.transform:SetParent(self.node_list["HunYuBg"].transform)
				obj.transform.localScale = Vector3(1, 1, 1)
				obj.transform.localPosition = Vector3(0, 0, 0)
			end)
		end

		if effect2 then
			local effect_bundle, effect_asset = ResPath.GetUiXEffect(effect2)
				ResPoolMgr:GetEffectAsync(effect_bundle, effect_asset, function(obj)
				if IsNil(obj) then
					return
				end
				self.item_effect2 = obj
				obj.transform:SetParent(self.node_list["EffectDi"].transform)
				obj.transform.localScale = Vector3(1, 1, 1)
				obj.transform.localPosition = Vector3(0, 0, 0)
			end)
		end

		self.item:SetData({item_id = cur_jingjie_cfg.stuff_id, num = 1})
		if self.effect1 then
			ResPoolMgr:Release(self.effect1)
			self.effect1 = nil
		end
		local effect_bundle, effect_asset = ResPath.GetUiXEffect("jinjie_" .. string.format("%02d",(cur_jingjie_cfg.pic_hunyu + 1)))
			ResPoolMgr:GetEffectAsync(effect_bundle, effect_asset, function(obj)
				if IsNil(obj) or nil == self.node_list or nil == self.node_list["Effect1"] then
					return
				end
				obj.transform:SetParent(self.node_list["Effect1"].transform)
				self.effect1 = obj
				obj.transform.localScale = Vector3(60, 60, 60)
				obj.transform.localPosition = Vector3(0, 0, 0)
				if cur_jingjie_level ~= 50 then
					obj.transform.localRotation = Quaternion.Euler(0, -15, 0)
				end
			end)
	end
	local n_jingjie_cfg = JingJieData.Instance:GetjingjieCfg(cur_jingjie_level + 1)
	UI:SetButtonEnabled(self.node_list["BtnRecycle"], n_jingjie_cfg ~= nil) 
	if n_jingjie_cfg then
		self.node_list["NextHP"].text.text = (n_jingjie_cfg.maxhp)
		self.node_list["NextGongJi"].text.text = (n_jingjie_cfg.gongji)
		self.node_list["NextFangYu"].text.text = (n_jingjie_cfg.fangyu or 0)
		self.node_list["NextJingJie"].text.text = n_jingjie_cfg.name
		-- self.node_list["Nextjingjie"].outline.effectColor = JingJieData.GetjingjieColor(cur_jingjie_level + 1)
		local role_cap = GameVoManager.Instance:GetMainRoleVo().capability
		local str = "%d/%d"
		if role_cap < n_jingjie_cfg.cap_limit then
			str = "<color=#F9463BFF>%s</color> / %s"
			self.cap_is_enough = false
		else
			str = "<color=#89F201FF>%s</color> / %s"
			self.cap_is_enough = true
		end
		role_cap = CommonDataManager.ConverMoney(GameVoManager.Instance:GetMainRoleVo().capability)
		local need_cap = CommonDataManager.ConverMoney(n_jingjie_cfg.cap_limit)
		self.node_list["NeedCap"]:SetActive(true)
		self.node_list["RightInfo"]:SetActive(true)
		self.node_list["Arrow"]:SetActive(true)
		self.node_list["NeedCap1"]:SetActive(true)
		self.node_list["NeedCap"].text.text = (string.format(str, role_cap, need_cap))
		str = "%d / %d"
		self.num = ItemData.Instance:GetItemNumInBagById(n_jingjie_cfg.stuff_id)
		self.need_num = n_jingjie_cfg.stuff_num
		if self.num < self.need_num then
			str = "<color=#fe3030>%d</color> / <color=#89F201FF>%d</color>"
		else
			str = "<color=#89F201FF>%d</color> / <color=#89F201FF>%d</color>"
		end
		self.node_list["StuffNum"].text.text = (string.format(str, self.num, self.need_num))
		self.item:SetData({item_id = n_jingjie_cfg.stuff_id, num = 1})
		local bundle, asset = ResPath.GetJingJieLevelIcon(JingJieData.GetjingjieIcon(n_jingjie_cfg.jingjie_level))
		self.node_list["NextLevelImage"].image:LoadSprite(bundle,asset)
		self.node_list["NextLongXingRank"].text.text = (JingJieData.GetjingjieNum(n_jingjie_cfg.jingjie_level))
		self.node_list["BtnRecycleText"].text.text = Language.Common.TiSheng
		-- self.node_list["HunYuImage"].image:LoadSprite(ResPath.GetHunyuIcon(n_jingjie_cfg.pic_hunyu + 1))
		-- self.node_list["HunYuBg"].image:LoadSprite(ResPath.GetQualityIcon(n_jingjie_cfg.color + 1))
		if self.effect2 then
			ResPoolMgr:Release(self.effect2)
			self.effect2 = nil
		end
		local effect_bundle, effect_asset = ResPath.GetUiXEffect("jinjie_" .. string.format("%02d",(n_jingjie_cfg.pic_hunyu + 1)))
			ResPoolMgr:GetEffectAsync(effect_bundle, effect_asset, function(obj)
				if IsNil(obj) then
					return
				end
				if self.node_list then
					obj.transform:SetParent(self.node_list["Effect2"].transform)
				end
				self.effect2 = obj
				obj.transform.localScale = Vector3(60, 60, 60)
				obj.transform.localPosition = Vector3(0, 0, 0)
				obj.transform.localRotation = Quaternion.Euler(0, 15, 0)
			end)
	else
		self.node_list["StuffNum"].text.text = Language.Common.MaxLevelDesc
		self.node_list["NeedCap"].text.text = Language.Common.YiManJi
		self.node_list["BtnRecycleText"].text.text = Language.Common.YiManJi
		self.node_list["Arrow"]:SetActive(false)
		self.node_list["RightInfo"]:SetActive(false)
	end
end

function JingJieView:OnClickBuy()
	local cur_jingjie_level = JingJieData.Instance:GetjingjieLevel() or 0
	local n_jingjie_cfg = JingJieData.Instance:GetjingjieCfg(cur_jingjie_level + 1)
	if not n_jingjie_cfg then
	    return
	end
  
	-- local time = JingJieData.Instance:GetTime()
	-- if time <= 0 then
	-- 	local text = string.format(Language.WantBuy[math.random(1, #Language.WantBuy)], n_jingjie_cfg.stuff_id)
	-- 	ChatCtrl.SendChannelChat(CHANNEL_TYPE.WORLD, text, content_type)
	-- 	TipsCtrl.Instance:ShowSystemMsg(Language.GetBuyChat.Send)
	-- 	JingJieData.Instance:SetTime(Status.NowTime)
	-- else
	-- 	if Status.NowTime - time >= 30 then 
	-- 		local text = string.format(Language.WantBuy[math.random(1, #Language.WantBuy)], n_jingjie_cfg.stuff_id)
	-- 		ChatCtrl.SendChannelChat(CHANNEL_TYPE.WORLD, text, content_type)
	-- 		TipsCtrl.Instance:ShowSystemMsg(Language.GetBuyChat.Send)
	-- 		JingJieData.Instance:SetTime(Status.NowTime)
	-- 	else
	-- 		TipsCtrl.Instance:ShowSystemMsg(Language.GetBuyChat.Cold)
	--     end
	-- end

	
	-- local text = string.format(Language.WantBuy[math.random(1, #Language.WantBuy)], n_jingjie_cfg.stuff_id)
	-- ChatData.Instance:SetChannelCdEndTime(CHANNEL_TYPE.WORLD)
	-- ChatCtrl.SendChannelChat(CHANNEL_TYPE.WORLD, text, content_type)
	JingJieData.Instance:SetTime(Status.NowTime)	
	MarketData.Instance:SetPurchaseItemId(11)
	ViewManager.Instance:Open(ViewName.Market, TabIndex.market_purchase, "select_purchase", {select_index == 11})
end

function JingJieView:OnUpGrade()
	local level = JingJieData.Instance:GetjingjieLevel()
	if self.cap_is_enough then
		if self.num >= self.need_num then
			JingJieCtrl.Instance:SendUpJingJie()
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.BaoJu.UpLvTerm)
			return
		end
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.BaoJu.CapDontEnough)
		return
	end
	if level % 5 == 0 then
		-- SysMsgCtrl.Instance:ErrorRemind(Language.Common.HunyuSucc)
		local data = JingJieData.Instance:GetjingjieCfg(level)
		local next_data = JingJieData.Instance:GetjingjieCfg(level + 5)
		TipsCtrl.Instance:ShowHunyuUpGradeTip(data, next_data)
	else
		-- SysMsgCtrl.Instance:ErrorRemind(Language.Common.JingjieSucc)
		self:UpGradeFlush()
	end
end

function JingJieView:UpGradeFlush()
	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
		local bundle_name, asset_name = ResPath.GetUiXEffect("UI_jinjietishengchenggong")
		EffectManager.Instance:PlayAtTransformCenter(
			bundle_name,
			asset_name,
			self.node_list["EffectRoot"].transform,
			1.0)
		self.effect_cd = Status.NowTime + EFFECT_CD
	end
end

function JingJieView:OnBtnToForge()
	if not ViewManager.Instance:IsOpen(ViewName.Forge) then
		ViewManager.Instance:Open(ViewName.Forge, TabIndex.forge_yongheng)
	else
		ViewManager.Instance:Close(ViewName.BaoJu)
	end
end

function JingJieView:RemindChangeCallBack(remind_name, num)
	-- if remind_name == RemindName.jingjie then
	-- 	self.node_list["Red"]:SetActive(RemindManager.Instance:GetRemind(RemindName.jingjie) > 0)
	-- end
end
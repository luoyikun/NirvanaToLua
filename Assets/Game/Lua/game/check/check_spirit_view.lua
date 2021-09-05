CheckSpiritView = CheckSpiritView or BaseClass(BaseRender)

local FIX_SHOW_TIME = 8
function CheckSpiritView:__init(instance)
	self.item_index = 1
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtZhanli"])
	self.item_list = {}
	for i = 1, 4 do
		self.item_list[i] = {}
		local handler = function()
			local item_id = self.item_list[i].item_cell:GetData().item_id
			if item_id ~= 0 then
				self.item_index = i
				self:SetShowId(self.item_list[i].item_cell:GetData().item_id)
			end
			self:FlushItemHl()
		end
		self.item_list[i].item_cell = ItemCell.New()
		self.item_list[i].item_cell:SetInstanceParent(self.node_list["item_" .. i])
		self.item_list[i].show_chuzhan = self.node_list["ImgFightOut" .. i]
		self.item_list[i].item_cell:ListenClick(handler)
	end
	self.show_spirit_id = 0
end

function CheckSpiritView:__delete()
	for k, v in pairs(self.item_list) do
		if v.item_cell then
			v.item_cell:DeleteMe()
		end
	end
	self.item_list = {}
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
	end
	self.spirit_attr = nil
	self.item_index = 1
	self.fight_text = nil
end

function CheckSpiritView:FlushItemHl()
	for i = 1, 4 do
		self.item_list[i].item_cell:ShowHighLight(self.item_index == i and self.spirit_attr.jingling_item_list[i].jingling_id ~= 0)
	end
end

function CheckSpiritView:SetAttr()
	local check_attr = CheckData.Instance:UpdateAttrView()
	if check_attr and check_attr.spirit_attr then
		self.spirit_attr = check_attr.spirit_attr
		self:Flush()
	end
end

function CheckSpiritView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["RightFrame"], CheckData.TweenPosition.RightFrame , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end

function CheckSpiritView:OnFlush()
	if self.spirit_attr then
		if self.spirit_attr.use_jingling_id == 0 then
			for k,v in pairs(self.spirit_attr.jingling_item_list) do
				if v.jingling_id ~= 0 then

					self.show_spirit_id = v.jingling_id
					self.show_spirit_level = v.jingling_level
					break
				end
			end
		else

			self.show_spirit_id = self.spirit_attr.use_jingling_id
			for k,v in pairs(self.spirit_attr.jingling_item_list) do
				if v.jingling_id == self.show_spirit_id then
					self.show_spirit_level = v.jingling_level
					break
				end
			end
		end
		local spirit_cfg = SpiritData.Instance:GetSpiritLevelCfgById(self.show_spirit_id, self.show_spirit_level)
		local gongji = 0
		local fangyu = 0
		local shengming = 0
		local kangbao = 0
		if self.show_spirit_id ~= 0 and spirit_cfg ~= nil then
			local item_cfg = {}
			item_cfg = ItemData.Instance:GetItemConfig(self.show_spirit_id)
			if item_cfg ~= nil then
				self.node_list["TxtName"].text.text = item_cfg.name
			end
			
			gongji = spirit_cfg.gongji
			fangyu = spirit_cfg.fangyu
			shengming = spirit_cfg.maxhp
			kangbao = spirit_cfg.jianren
		end
		self.node_list["TxtValue1"].text.text = gongji
		self.node_list["TxtValue2"].text.text = fangyu
		self.node_list["TxtValue3"].text.text = shengming
		self.node_list["TxtValue4"].text.text = kangbao

		local the_list = SpiritData.Instance:GetShowTalentList(self.show_spirit_id, self.spirit_attr)
		for i = 1, 3 do
			if the_list[i].value == 0 then
				self.node_list["Obj" .. i]:SetActive(false)
			else
				self.node_list["Obj" .. i]:SetActive(true)
				self.node_list["TxtLabel" .. i].text.text = the_list[i].name
				self.node_list["TxtValue1" .. i].text.text = string.format(Language.CheckViewTips.Percent, the_list[i].value)
			end
		end
		local jingling_item = CheckData.Instance:GetShowJingLingAttr()
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = RankData.Instance:GetJingLingPower(jingling_item.jingling_id, jingling_item.jingling_level)
		end
		for i = 1, 4 do
			local data = {}
			if self.spirit_attr.jingling_item_list[i].jingling_id ~= 0 then
				data.item_id = self.spirit_attr.jingling_item_list[i].jingling_id
			else
				data.item_id = 0
			end
			self.item_list[i].item_cell:SetData(data)
		end
		self:SetModle()
		self.item_index = 1
		self:FlushItemHl()
	end
end

function CheckSpiritView:SetShowId(item_id)
	if item_id == self.show_spirit_id then return end
	self.show_spirit_id = item_id
	local gongji = 0
	local fangyu = 0
	local shengming = 0
	local kangbao = 0
	if self.show_spirit_id ~= 0 then
		for k,v in pairs(self.spirit_attr.jingling_item_list) do
			if v.jingling_id == item_id then
				self.show_spirit_level = v.jingling_level
				break
			end
		end
		local item_cfg = {}
		local spirit_cfg = SpiritData.Instance:GetSpiritLevelCfgById(self.show_spirit_id, self.show_spirit_level)
		item_cfg = ItemData.Instance:GetItemConfig(self.show_spirit_id)
		if item_cfg ~= nil then
			self.node_list["TxtName"].text.text = item_cfg.name
		end
		
		gongji = spirit_cfg.gongji
		fangyu = spirit_cfg.fangyu
		shengming = spirit_cfg.maxhp
		kangbao = spirit_cfg.jianren

		self.node_list["TxtValue1"].text.text = gongji
		self.node_list["TxtValue2"].text.text = fangyu
		self.node_list["TxtValue3"].text.text = shengming
		self.node_list["TxtValue4"].text.text = kangbao
		local the_list = SpiritData.Instance:GetShowTalentList(self.show_spirit_id, self.spirit_attr)
		for i = 1, 3 do
			if the_list[i].value == 0 then
				self.node_list["Obj" .. i]:SetActive(false)
			else
				self.node_list["Obj" .. i]:SetActive(true)
				self.node_list["TxtLabel" .. i].text.text = the_list[i].name
				self.node_list["TxtValue1" .. i].text.text = string.format(Language.CheckViewTips.Percent, the_list[i].value)
			end
		end
		self:SetModle()
	end
end

function CheckSpiritView:SetModle()
	UIScene:SetActionEnable(false)
	if self.show_spirit_id == 0 then return end
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
	end
	local spirit_cfg = SpiritData.Instance:GetSpiritResIdByItemId(self.show_spirit_id)
	if spirit_cfg ~= nil then

		local bundle, asset = ResPath.GetSpiritModel(spirit_cfg.res_id)
		local bundle_list = {[SceneObjPart.Main] = bundle}
		local asset_list = {[SceneObjPart.Main] = asset}
		UIScene:ModelBundle(bundle_list, asset_list)

		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "spirit")
		transform.rotation = Quaternion.Euler(0, -168, 0)
		UIScene:SetCameraTransform(transform)

		self:CalToShowAnim()
	end
end

function CheckSpiritView:CalToShowAnim()
	self.timer = FIX_SHOW_TIME
	local part = nil
	if UIScene.role_model then
		part = UIScene.role_model.draw_obj:GetPart(SceneObjPart.Main)
	end
	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
		self.timer = self.timer - UnityEngine.Time.deltaTime
		if self.timer <= 0 then
			if part then
				part:SetTrigger(ANIMATOR_PARAM.REST)
			end
			self.timer = FIX_SHOW_TIME
		end
	end, 0)
end

function CheckSpiritView:CancelTheQuest()
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
	end
end

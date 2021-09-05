YewaiGuajiView = YewaiGuajiView or BaseClass(BaseView)

local MAX_CHOSEN_NUM = 3

function YewaiGuajiView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/yewaiguaji_prefab", "YeWaiGuaJiContent"},
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
end

function YewaiGuajiView:__delete()

end

function YewaiGuajiView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	self.node_list["Txt"].text.text = Language.GuaJiTips.GuaJiTitle
	self.node_list["Bg"].rect.sizeDelta = Vector3(870, 520, 0)
	self.map_chosen_item_list = {}
	for i = 1, MAX_CHOSEN_NUM do
		local item = self.node_list["MapChosenItem_" .. i]
		self.map_chosen_item_list[i] = MapChosenItem.New(item)
		self.map_chosen_item_list[i]:SetIndex(i)
	end
end

function YewaiGuajiView:ReleaseCallBack()
	for i = 1, MAX_CHOSEN_NUM do
		if self.map_chosen_item_list[i] ~= nil then
			self.map_chosen_item_list[i]:DeleteMe()
			self.map_chosen_item_list[i] = nil
		end
	end
end

function YewaiGuajiView:OpenCallBack()
	local map_chosen_info = YewaiGuajiData.Instance:GetGuaJiPosList()
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	local command_index = 0
	
	for i = 1, MAX_CHOSEN_NUM do
		-- 获取等级范围
		local  map_level_list = {}
		local min_zhuangsheng = math.floor(map_chosen_info[i].min_level / 100)
		local max_zhuangsheng = math.floor(map_chosen_info[i].max_level / 100)
		table.insert(map_level_list, min_zhuangsheng)
		table.insert(map_level_list, max_zhuangsheng)

		-- 赋值
		self.map_chosen_item_list[i]:SetIsban(i)
		local is_not_ban = self.map_chosen_item_list[i]:GetIsban()
		if is_not_ban then
			self.map_chosen_item_list[i]:SetMapLevel(map_level_list)
			self.map_chosen_item_list[i]:SetTitle()
			self.map_chosen_item_list[i]:SetStandardExp()
			self.map_chosen_item_list[i]:SetBlueNum()
			self.map_chosen_item_list[i]:SetPurpleNum()
			self.map_chosen_item_list[i]:SetMapImage()
--			self.map_chosen_item_list[i]:SetEquipmentLevel()

			if my_level >= map_chosen_info[i].level_limit then 	
				command_index = i 
			end
		end
	end

	if command_index ~= 0 then
		self.map_chosen_item_list[command_index]:SetIsRecommend(true)
	end
end

function YewaiGuajiView:CloseView()
	self:Close()
end
------------------------------------------------------------------------
MapChosenItem = MapChosenItem or BaseClass(BaseCell)
function MapChosenItem:__init()
	self.is_not_ban = true
	self.node_list["BtnGuaJi"].button:AddClickListener(BindTool.Bind(self.GoGuaji, self))
end

function MapChosenItem:__delete()
	self.map_level = nil
	self.index = nil
end

function MapChosenItem:SetTitle()
	local scene_name = YewaiGuajiData.Instance:GetGuaJiSceneName(self.index, self.guaiwuIndex)
	self.node_list["TxtTitle"].text.text = scene_name
end

function MapChosenItem:SetIndex(index)
	self.index = index
	self.guaiwuIndex = YewaiGuajiData.Instance:GetGuaiwuIndex()
end

function MapChosenItem:SetMapLevel(value)
	self.node_list["TxtMapLevel"].text.text = string.format(Language.GuaJiTips.GoToMapLevel, value[1], value[2])
end

function MapChosenItem:SetLevelLimit()
	local level_limit = YewaiGuajiData.Instance:GetMapLevelLimit(self.index)
	self.node_list["TxtLevelLimit"].text.text = level_limit .. Language.Common.Ji .. Language.Common.Open
end

function MapChosenItem:SetStandardExp()
	local exp = YewaiGuajiData.Instance:GetStanderdExp(self.index, self.guaiwuIndex)
	self.node_list["TxtBaseExperient"].text.text = string.format(Language.GuaJiTips.StandExp, math.floor(exp / 10000 + 0.5))
end

function MapChosenItem:SetBlueNum()
	local value = YewaiGuajiData.Instance:GetEquipmentLevel(self.index, self.guaiwuIndex)
	local num = YewaiGuajiData.Instance:GetEquipNum(self.index, self.guaiwuIndex)
	self.node_list["TxtBlueNum"].text.text = string.format(Language.GuaJiTips.BuleEquip, value, num)
end

function MapChosenItem:SetPurpleNum()
	local value = YewaiGuajiData.Instance:GetEquipmentLevel(self.index, self.guaiwuIndex)
	local temp, num = YewaiGuajiData.Instance:GetEquipNum(self.index, self.guaiwuIndex)
	self.node_list["Txtzizhuangnum"].text.text = string.format(Language.GuaJiTips.PurpleEquip, value, num)
end

function MapChosenItem:SetMapImage()
	local value = YewaiGuajiData.Instance:GetMap(self.index)
	local bundle, asset =  ResPath.GetYewaiGuajiMap(value)
	self.node_list["ImgMapImage"].image:LoadSprite(bundle, asset .. ".png")
end

function MapChosenItem:SetIsban()
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	local map_level_limit = YewaiGuajiData.Instance:GetMapLevelLimit(self.index)

	if my_level < map_level_limit then
		self.is_not_ban = false
		self.node_list["NodeNotBan"]:SetActive(self.is_not_ban)
		self.node_list["BtnGuaJi"]:SetActive(self.is_not_ban)
		self.node_list["ImgBan"]:SetActive(not self.is_not_ban)

		self:SetLevelLimit()
	end
end	

function MapChosenItem:GetIsban()
	return self.is_not_ban
end

-- 点击挂机按钮
function MapChosenItem:GoGuaji()
	local guaji_pos = YewaiGuajiData.Instance:GetGuajiPos(self.guaiwuIndex)
	YewaiGuajiCtrl.Instance:GoGuaji(guaji_pos[1],guaji_pos[2],guaji_pos[3])
end

function MapChosenItem:SetIsRecommend(value)
	self.node_list["ImgTuiJian"]:SetActive(value)
end

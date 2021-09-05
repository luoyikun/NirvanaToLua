GiftEffectView = GiftEffectView or BaseClass(BaseView)

function GiftEffectView:__init()
	self.ui_config = {{"uis/views/marriageview_prefab", "GiftEffectView"}}
	self.play_audio = false
	self.view_layer = UiLayer.PopTop
end

function GiftEffectView:__delete()

end

function GiftEffectView:ReleaseCallBack()
	self.path = nil
	self.objname = nil
	self.async_name = nil
end

function GiftEffectView:LoadCallBack()

end

function GiftEffectView:CloseCallBack()
	self.path = nil
	self.objname = nil
	self.async_name = nil
end

function GiftEffectView:OpenCallBack()
	self:PlayerEffectAddtion()
end

function GiftEffectView:SetData(path, objname, async_name)
	self.path = path
	self.objname = objname
	self.async_name = async_name
end


function GiftEffectView:PlayerEffectAddtion()
	self.is_hideeffect = SettingData.Instance:GetSettingData(SETTING_TYPE.FLOWER_EFFECT)
	if self.is_hideeffect then
		return
	end

	if self.path == nil or self.objname == nil then
		return
	end
	self.async_name = self.async_name or "songhua_effect_add_loader"
	local async_loader = AllocAsyncLoader(self, self.async_name)
	async_loader:Load(self.path, self.objname, function (obj)
		if not IsNil(obj) then
			FlowersData.Instance:SetFlowerPlay(true)

			local transform = obj.transform
			transform:SetParent(self.node_list["Node_Effect"].transform, false)
			local time = 8
			if self.objname == "UI_huojian" then
				time = 4
			elseif self.objname == "UI_chuan" then
				time = 4
			elseif self.objname == "UI_xiangbing" then
				time = 2
			end
			

			GlobalTimerQuest:AddDelayTimer(function()
				ResMgr:Destroy(obj)
				self:Close()
			end, time)
		end
	end)
end
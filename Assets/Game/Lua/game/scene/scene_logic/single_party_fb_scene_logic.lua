SinglePartyFbSceneLogic = SinglePartyFbSceneLogic or BaseClass(BaseFbLogic)

function SinglePartyFbSceneLogic:__init()

end

function SinglePartyFbSceneLogic:__delete()

end

function SinglePartyFbSceneLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(false)
	ViewManager.Instance:Open(ViewName.SinglePartyInfoView)
	ViewManager.Instance:Close(ViewName.FestivalView)
	FuBenData.Instance:SetTowerIsWarning(false)
end

function SinglePartyFbSceneLogic:Update(now_time, elapse_time)
	BaseFbLogic.Update(self, now_time, elapse_time)
end

function SinglePartyFbSceneLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	GuajiCtrl.Instance:StopGuaji()
	ViewManager.Instance:Close(ViewName.SinglePartyInfoView)
end

function SinglePartyFbSceneLogic:DelayOut(old_scene_type, new_scene_type)
	BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
end

function SinglePartyFbSceneLogic:GetGuajiPos()
	local pos = FestivalSinglePartyData.Instance:GetSinglePartyGuajiPos(1)
	return pos.x, pos.y
end

function SinglePartyFbSceneLogic:GetSpecialGuajiPos()
	local function start_call_back()
		FuBenData.Instance:SetTowerIsWarning(false)
	end
	if FuBenData.Instance:GetTowerIsWarning() then
		local pos_x, pos_y = self:GetGuajiPos()
		return pos_x, pos_y, start_call_back
	end
	return nil, nil, nil
end
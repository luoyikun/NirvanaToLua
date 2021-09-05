TipsEneterCommonSceneView = TipsEneterCommonSceneView or BaseClass(BaseView)

function TipsEneterCommonSceneView:__init()
	self.ui_config = {{"uis/views/tips/entercommonscenetip_prefab", "EnterCommonSceneView"}}
	self.play_audio = true
	local config = ConfigManager.Instance:GetAutoConfig("fb_scene_config_auto").enterscene_view
	self.enter_cfg = ListToMap(config, "scene_id")
	self.view_layer = UiLayer.MainUIHigh
end

function TipsEneterCommonSceneView:__delete()
end

function TipsEneterCommonSceneView:ReleaseCallBack()
	-- 清理变量和对象
	self:RemoveDelay()
end

function TipsEneterCommonSceneView:LoadCallBack()
	self:RemoveDelay()
	self.timer_quest = GlobalTimerQuest:AddDelayTimer(function ()
		self:Close()
	end, 5)
end

function TipsEneterCommonSceneView:OpenCallBack()
	self:Flush()
end

function TipsEneterCommonSceneView:CloseCallBack()

end

function TipsEneterCommonSceneView:SetSceneId(scene_id)
	self.scene_id = scene_id or 0

	local cfg = self.enter_cfg[scene_id]
	if nil == cfg then
		return
	end
	self:Open()
end

function TipsEneterCommonSceneView:OnFlush()
	local cfg = self.enter_cfg[self.scene_id]
	if nil == cfg then
		return
	end
	local asset, bundle = "uis/views/tips/entercommonscenetip/images_atlas", "image_" .. cfg.show_ui
	self.node_list["ImgName03"].image:LoadSprite(asset, bundle)
	-- for i = 1, 3 do
	-- 	self.node_list["ImgName0" .. i].image:LoadSprite(asset, bundle)
	-- end

	for i = 1, 9 do
		if cfg.show_ui == i then
			self.node_list["TxtDec" .. i]:SetActive(true)
			self.node_list["TxtSDec" .. i]:SetActive(true)
		else
			self.node_list["TxtDec" .. i]:SetActive(false)
			self.node_list["TxtSDec" .. i]:SetActive(false)
		end
	end
	self:RemoveDelay()
	self.timer_quest = GlobalTimerQuest:AddDelayTimer(function ()
		self:Close()
	end, 5)
end

function TipsEneterCommonSceneView:RemoveDelay()
	if nil ~= self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end
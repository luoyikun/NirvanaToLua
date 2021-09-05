require("game/scene/loading/scene_preload")
SceneLoading = SceneLoading or BaseClass(BaseView)

local UICamera = GameObject.Find("GameRoot/UICamera")
-- local post_effects = UICamera:GetComponent(typeof(PostEffects))

function SceneLoading:__init()
	self.ui_config = {{"uis/views/loading_prefab", "SceneLoadingView"}}
	self.loading_data = require("init/init_loading_data")
	self.view_layer = UiLayer.SceneLoading
	self.view_name = ViewName.SceneLoading

	self.notice_str_list = {}
	self.main_complete_callback = nil
	self.complete_callback = nil
	self.complete_callback_end = nil		-- 进度加载结束关掉面板回调
	self.preload_complete = false
	self.cur_precent = 0
	self.delay_close_timer = nil
	self.is_scene_loading = false
	self.is_wait_load = false
	self.full_screen = true

	self.start_loading_callback = nil
	self.scene_preload = nil
	self.show_loading = true
	self.delay_check_start_timer = nil
	self.bg_is_loaded = false
	self.request_proiority_id = nil
end

function SceneLoading:ReleaseCallBack()
	if nil ~= self.delay_check_start_timer then
		GlobalTimerQuest:CancelQuest(self.delay_check_start_timer)
		self.delay_check_start_timer = nil
	end

	self:StopTimer()
	self:StopScenePreload()

	-- 清理变量和对象
	self.percent = nil
	self.progress = nil
	self.fade = nil
end

function SceneLoading:SetStartLoadingCallback(start_loading_callback)
	self.start_loading_callback = start_loading_callback
end

local TypeUnityTexture = typeof(UnityEngine.Texture)

function SceneLoading:OpenCallBack()
	if self.show_loading then
		self.node_list["NodeLoading"]:SetActive(true)
		if ResMgr.ExistedInStreaming("AgentAssets/loading_bg.png") then
			local url = ResUtil.GetAgentAssetPath("AgentAssets/loading_bg.png")
			if self.node_list["ImgBgURL"] and self.node_list["ImgBg"] then
				self.node_list["ImgBgURL"].raw_image:LoadSprite(url, function ()
					end)
				self.node_list["ImgBg"]:SetActive(false)
			end
		else
			if self.node_list["ImgBg"] then
				self.node_list["ImgBg"]:SetActive(true)
			end
			local day = 1
			day = TimeCtrl.Instance:GetCurOpenServerDay()
			if day and day ~= -1 then
				if day > 7 then
					day = 8
				end
				self.bundle_name, self.asset_name = self:GetRandomAsset(day)
				day = nil
			else
				self.bundle_name, self.asset_name = self:GetRandomAsset()
			end
			self.node_list["ImgBg"].raw_image:LoadSprite(self.bundle_name, self.asset_name)
		end
		
		self.node_list["TxtNotice"].text.text = self:GetRandomNoticeStr()
		self.node_list["TxtPercent"].text.text = ""
		self.node_list["Slider"].slider.value = 0

		if nil == self.delay_check_start_timer then
			self.delay_check_start_timer = GlobalTimerQuest:AddDelayTimer(function ()
				self.bg_is_loaded = true
				self.delay_check_start_timer = nil
				self:CheckStart()
			end, 0.2)
		end

	else
		self.node_list["NodeLoading"]:SetActive(false)
		-- self.node_list["Fade"].image.color = Color.New(0, 0, 0, 0)
		-- post_effects.EnableBlur = true
		-- post_effects.BlurSpread = 0.0
		-- post_effects.WaveStrength = 0.0
		-- post_effects:DoBlurSpread(2.5, 1.5)
		-- post_effects:DoWave(1.0, 1.5)
		
		if nil == self.delay_check_start_timer then
			self.delay_check_start_timer = GlobalTimerQuest:AddDelayTimer(function()
				self.bg_is_loaded = true
				self.delay_check_start_timer = nil
				self:CheckStart()
			end, 1.5)
		end
	end

	self.node_list["Slider"]:SetActive(not IS_AUDIT_VERSION)
end

function SceneLoading:CloseCallBack()
	GlobalEventSystem:Fire(SceneEventType.CLOSE_LOADING_VIEW, true)
end

function SceneLoading:Start(scene_id, main_complete_callback, complete_callback, complete_callback_end)
	if self.scene_id == scene_id and self.is_scene_loading then
		GlobalEventSystem:Fire(SceneEventType.CLOSE_LOADING_VIEW, false)
		return
	end

	self:StopTimer()
	local last_scene_loading = self.is_scene_loading
	self.is_scene_loading = true
	local old_scene_id = self.scene_id
	self.scene_id = scene_id
	self.main_complete_callback = main_complete_callback
	self.complete_callback = complete_callback
	self.complete_callback_end = complete_callback_end
	self.is_wait_load = true

	self.load_list, self.download_scene_id = ScenePreload.GetLoadList(scene_id)
	
	LoadingPriorityManager.Instance:CancelRequest(self.request_proiority_id)
	self.request_proiority_id = LoadingPriorityManager.Instance:RequestPriority(LoadingPriority.High)

	-- -- 如果上个场景触发了水纹效果，但是在场景没加载完之前，又切换了新的场景，则会导致水纹效果没有还原
	-- if not self.show_loading then
	-- 	self:ResetPostEffects()
	-- end
	local old_scene_type = self.scene_type
	local old_scene_bundle_name = self.scene_bundle_name
	local old_scene_asset_name = self.scene_asset_name
	local scene_cfg = ConfigManager.Instance:GetSceneConfig(scene_id)
	-- 屏蔽地图编辑器上勾选去掉加载页功能
	-- self.show_loading = scene_cfg.skip_loading == nil or scene_cfg.skip_loading == 0

	-- 同样场景类型就不做加载页
	self.scene_type = scene_cfg.scene_type or 0
	self.scene_bundle_name = scene_cfg.bundle_name or ""
	self.scene_asset_name = scene_cfg.asset_name or ""
	if old_scene_type == self.scene_type and 0 ~= self.scene_type and SceneTypeSameLoading[self.scene_type] and self.scene_bundle_name ~= old_scene_bundle_name and self.scene_asset_name ~= old_scene_asset_name then
		self.show_loading = true
	elseif old_scene_type == self.scene_type and 0 ~= self.scene_type and not SceneTypeLoading[self.scene_type] then
		self.show_loading = false
	else
		self.show_loading = true
	end
	if self.download_scene_id > 0 or nil == old_scene_id then
		self.show_loading = true
	end

	self.full_screen = self.show_loading

	self:Open()
	if self.show_loading or last_scene_loading then
		self:CheckStart()
	end
end

function SceneLoading:CheckStart()
	if self.bg_is_loaded and self.is_wait_load then
		self.is_wait_load = false
		self:DoStart()
	end
end

function SceneLoading:DoStart()
	if nil ~= self.start_loading_callback then
		self.start_loading_callback(self.scene_id)
		self.start_loading_callback = nil
	end

	self:StopTimer()
	self:StopScenePreload()

	-- 把音效音量降为0
	AudioService.Instance:SetSFXVolume(0)

	self.scene_preload = ScenePreload.New(self.show_loading)
	self.scene_preload:StartLoad(self.scene_id,
		self.load_list,
		self.download_scene_id,
		BindTool.Bind(self.OnSceneLoadProgress, self),
		BindTool.Bind(self.OnMainSceneLoadComplete, self),
		BindTool.Bind(self.OnSceneLoadComplete, self))
end

function SceneLoading:OnSceneLoadProgress(per_value, tip)
	if nil == self.node_list or per_value < self.cur_precent then
		return
	end

	self.cur_precent = per_value

	if nil ~= self.node_list["TxtPercent"] and not IS_AUDIT_VERSION then
		local content = string.format("%s 【%d%%】", tip, per_value)
		self.node_list["TxtPercent"].text.text = content
	elseif IS_AUDIT_VERSION then
		local auditldtext = GLOBAL_CONFIG.param_list.auditldtext
		self.node_list["TxtPercent"].text.text = auditldtext ~= "" and auditldtext or Language.Common.Msging
	end

	if nil ~= self.node_list["Slider"] then
		self.node_list["Slider"].slider.value = per_value / 100
	end
end

function SceneLoading:IsSceneLoading()
	return self.is_scene_loading
end

function SceneLoading:OnMainSceneLoadComplete()
	self.is_scene_loading = false
	-- if not self.show_loading then
	-- 	self:ResetPostEffects()
	-- end

	if nil ~= self.main_complete_callback then
		self.main_complete_callback(self.scene_id)
		self.main_complete_callback = nil
	end

	self.cur_precent = 0
end

function SceneLoading:OnSceneLoadComplete()
	if nil ~= self.complete_callback then
		self.complete_callback(self.scene_id)
		self.complete_callback = nil
	end
	local complete_scene_id = self.scene_id
	self.scene_id = 0

	-- 为了效果，特意延迟关闭（因为在场景加载完成处可能会在下一帧才创建对象，比如从对象池中取cg）
	-- 关闭加载界面后，是一个较完整的画面
	self:StopTimer()
	self.delay_close_timer = GlobalTimerQuest:AddRunQuest(function ()
		LoadingPriorityManager.Instance:CancelRequest(self.request_proiority_id)
		-- 还原音效音量
		local volume = 1
		if SettingData.Instance:GetSettingData(SETTING_TYPE.CLOSE_SOUND_EFFECT) then
			volume = 0
		end
		AudioService.Instance:SetSFXVolume(volume)

		local main_role = Scene.Instance:GetMainRole()
		if main_role:IsEnterScene() then
			self:StopTimer()
			if nil ~= self.complete_callback_end then
				self.complete_callback_end(complete_scene_id)
				self.complete_callback_end = nil
			end
			self:Close()
		end
	end, 0.5)
end
--[[
function SceneLoading:CloseCallBack()
	--摄像机水波纹特效
	if not IsNil(MainCameraFollow) then
		local post_effects = MainCameraFollow.gameObject:GetComponentInChildren(typeof(PostEffects))
		if nil ~= post_effects then
			post_effects.EnableBlur = true
			post_effects.enabled = true
			post_effects.WaveStrength = 0

			if self.post_effect_timer_quest then
				GlobalTimerQuest:CancelQuest(self.post_effect_timer_quest)
			end
			self.post_effect_timer_quest = GlobalTimerQuest:AddRunQuest(function()
				if not IsNil(post_effects) then
					post_effects.WaveStrength = post_effects.WaveStrength + 0.1
					if post_effects.WaveStrength >= 1 then
						post_effects.EnableBlur = false
						post_effects.enabled = false
						post_effects.WaveStrength = 0
						if self.post_effect_timer_quest then
							GlobalTimerQuest:CancelQuest(self.post_effect_timer_quest)
							self.post_effect_timer_quest = nil
						end
					end
				end
			end, 
			0.05)
		end
	end
end
]]
function SceneLoading:StopTimer()
	if nil ~= self.delay_close_timer then
		GlobalTimerQuest:CancelQuest(self.delay_close_timer)
		self.delay_close_timer = nil
	end
end

function SceneLoading:StopScenePreload()
	if nil ~= self.scene_preload then
		self.scene_preload:DeleteMe()
		self.scene_preload = nil
	end
end

function SceneLoading:GetRandomNoticeStr()
	if #self.notice_str_list < 1 then
		local temp_list = {}
		for k,v in pairs(self.loading_data.Reminding) do
			table.insert(temp_list, v)
		end
		self.notice_str_list = temp_list
	end
	local index = math.random(1, #self.notice_str_list)
	local str = self.notice_str_list[index]
	table.remove(self.notice_str_list, index)

	return str
end

function SceneLoading:GetRandomAsset(day)
	if day then
		local temp_list = self.loading_data.SceneDayImages[day]
		if temp_list then
			local index = math.random(1, #temp_list)
			local asset = temp_list[index] or {}
			return asset[1], asset[2]
		end
	end
	local temp_list = self.loading_data.SceneImages
	local index = math.random(1, #temp_list)
	local asset = temp_list[index] or {}
	return asset[1], asset[2]
end

function SceneLoading:ResetPostEffects()
	if nil ~= self.node_list then 
		-- if nil ~= self.node_list["Fade"] then
		-- 	self.fade.image:DOFade(0.0, 0.5)
		-- 	post_effects.BlurSpread = 0.0
		-- 	post_effects.WaveStrength = 0.0
		-- 	post_effects.EnableBlur = false
		-- end
	end
end

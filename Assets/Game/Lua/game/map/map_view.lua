require("game/map/map_local_view")
require("game/map/map_global_view")

MapView = MapView or BaseClass(BaseView)

function MapView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel_1"},
		{"uis/views/map_prefab", "LocalMap", {TabIndex.map_local}},
		{"uis/views/map_prefab", "GlobalMap", {TabIndex.map_world}},
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel_3"},
	}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.def_index = TabIndex.map_local
	self.play_audio = true
end

function MapView:__delete()

end

function MapView:LoadCallBack()
	self.node_list["TitleText"].text.text = Language.Title.DiTu

	local tab_cfg = {
		{name =	Language.Map.TabbarName.Local, tab_index = TabIndex.map_local},
		{name = Language.Map.TabbarName.World, tab_index = TabIndex.map_world},

	}
	self.tabbar = TabBarTwo.New()
	self.tabbar:Init(self, self.node_list["TabPanel"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ChangeToIndex, self))

	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.HandleClose, self))

	-- self.eh_load_quit = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_QUIT, BindTool.Bind1(self.OnSceneLoadingQuite, self))
end

function MapView:ReleaseCallBack()
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
	
	if self.local_view then
		self.local_view:DeleteMe()
		self.local_view = nil
	end
	if self.global_view then
		self.global_view:DeleteMe()
		self.global_view = nil
	end
	if self.eh_load_quit then
		GlobalEventSystem:UnBind(self.eh_load_quit)
		self.eh_load_quit = nil
	end
end

function MapView:CloseCallBack()
	if self.global_view then
		self.global_view:CloseCallBack()
	end
end

function MapView:OpenCallBack()
	self:SendRandYunyouBossInfo()

	KuaFuBorderlandCtrl.Instance:SendCSCrossBianJingZhiDiBossInfoReq()
end

function MapView:HandleClose()
	self:Close()
end

function MapView:OnFlushYunYouBossNum()
	if self.global_view and self.global_view:IsOpen() then
		self.global_view:Flush()
	end
end

function MapView:SendRandYunyouBossInfo()
	local scene_id = Scene.Instance:GetSceneId()
	MapCtrl.Instance:SendRandYunyouBossInfo(YUNYOU_OPERATE_TYPE.TYPE_BOSS_INFO_REQ, scene_id)
	MapCtrl.Instance:SendRandYunyouBossInfo(YUNYOU_OPERATE_TYPE.TYPE_BOSS_COUNT_ALL_SCENE)
end

function MapView:OnSceneLoadingQuite()
	-- if self.local_view then
	-- 	self.local_view:OpenCallBack()
	-- end
end

function MapView:ShowIndexCallBack(index, index_nodes)
	self:SendRandYunyouBossInfo()
	self:OnFlushYunYouBossNum()
	self.tabbar:ChangeToIndex(index)
	self:OnFlushYunYouBoss()
	if index_nodes then
		if index == TabIndex.map_local then
			self.local_view = MapLocalView.New(index_nodes["LocalMap"])
		elseif index == TabIndex.map_world then
			self.global_view = MapGlobalView.New(index_nodes["GlobalMap"])
		end
	end
end
function MapView:OnFlushYunYouBoss()
	if self.local_view and self.local_view:IsOpen() then
		self.local_view:Flush()
	end
end

function MapView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "global_map" and self.global_view then
			self.global_view:Flush()
		end
	end
end

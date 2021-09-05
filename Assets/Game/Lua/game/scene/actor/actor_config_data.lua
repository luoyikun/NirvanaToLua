require("game/scene/actor/actor_ctrl")
require("game/scene/actor/actor_trigger")
require("game/scene/actor/actor_trigger_base")
require("game/scene/actor/actor_trigger_effect")
require("game/scene/actor/actor_trigger_halts")
require("game/scene/actor/actor_trigger_sound")
require("game/scene/actor/actor_trigger_camera_shake")

ActorConfigData = ActorConfigData or BaseClass()

function ActorConfigData:__init()
	self.prefab_data = nil
end

function ActorConfigData:__delete()
	self.prefab_data = nil
end

function ActorConfigData:SetPrefabData(data)
	self.prefab_data = data
end

function ActorConfigData:GetPrefabData()
	return self.prefab_data
end



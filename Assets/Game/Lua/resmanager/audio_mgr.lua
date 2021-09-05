
local ResUtil = require "resmanager/res_util"

local TypeAudioItem = typeof(AudioItem)
local ZeroPosition = Vector3(0, 0, 0)

local MaxCacheFreeTime = 1
local _tinsert = table.insert

local M = {}

function M.init()
	local audio_manager_obj = ResMgr:CreateEmptyGameObj("AudioManager", true)
	local source_pool_obj = ResMgr:CreateEmptyGameObj("Audio Source Pool", true)
	source_pool_obj.transform:SetParent(audio_manager_obj.transform, false)

	M.v_audio_manager_obj = audio_manager_obj
	M.v_source_pool = AudioSourcePool(audio_manager_obj.transform, source_pool_obj.transform)

	M.v_ctrl_stop_times = {}
	M.v_ctrl_stop_callback = {}
	M.v_ctrl_audio_items = {}

	M.v_need_update_ctrls = {}

end

function M.Update()
	for ctrl, stop_time in pairs(M.v_ctrl_stop_times) do
		local now_time = 0
		if nil ~= Status then
			now_time = Status.NowTime
		end
		if stop_time <= now_time then
			M.StopAudio(ctrl)
		elseif M.v_need_update_ctrls[ctrl] then
			ctrl:Update()
		end
	end
end

function M.Play(bundle_name, asset_name, position, transform, callback, stop_callback, loop, forget)
	ResPoolMgr:GetAudio(bundle_name, asset_name, function(obj)
		if IsNil(obj) then
			return
		end

		local ctrl = obj:Play(M.v_source_pool)
		local left_time = ctrl.LeftTime
		if not loop and left_time <= 0 then
			ResPoolMgr:Release(obj)
			return
		end

		M.v_ctrl_audio_items[ctrl] = obj

		position = position or ZeroPosition
		ctrl:SetPosition(position)
		ctrl:Play()

		if transform then
			ctrl:SetTransform(transform)
		end

		if not loop then
			local now_time = 0
			if nil ~= Status then
				now_time = Status.NowTime
			end
			M.v_ctrl_stop_times[ctrl] = now_time + left_time
		end

		if not forget then
			M.v_need_update_ctrls[ctrl] = true
		end

		if callback then
			callback(ctrl, asset_name)
		end

		if stop_callback then
			M.v_ctrl_stop_callback[ctrl] = {callback = stop_callback, asset_name = asset_name}
		end
end, true)
end

function M.PlayAndForget(bundle_name, asset_name, position, transform, callback, stop_callback, loop)
	M.Play(bundle_name, asset_name, position, transform, callback, stop_callback, loop, true)
end

function M.StopAudio(ctrl)
	local audio_item = M.v_ctrl_audio_items[ctrl]
	if not audio_item then
		return
	end
	local audio_stop_callback = M.v_ctrl_stop_callback[ctrl]
	if audio_stop_callback then
		local callback = audio_stop_callback["callback"]
		local asset_name = audio_stop_callback["asset_name"]
		callback(ctrl, asset_name)
	end

	M.v_ctrl_stop_times[ctrl] = nil
	M.v_ctrl_stop_callback[ctrl] = nil
	M.v_ctrl_audio_items[ctrl] = nil
	M.v_need_update_ctrls[ctrl] = nil
	ctrl:FinshAudio()
	ResPoolMgr:Release(audio_item)
end

function M.OnGameStop()
	ResMgr:Destroy(M.v_audio_manager_obj)
end

return M


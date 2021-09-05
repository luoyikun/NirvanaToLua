IosAuditReceiver = IosAuditReceiver or {}
IosAuditReceiver.is_audit = false
local self = IosAuditReceiver

function IosAuditReceiver:ReceiveMsg(data)
	if data.msg_type == "PlayEffect" then
		self:PlayEffect()
	elseif data.msg_type == "OperateTask" then
		self:OnClickTask(data.task_id)
	elseif data.msg_type == "OperateSkill" then
		self:OnClickSkill(data.skill_index)
	elseif data.msg_type == "OperateJoystick" then
		self:OnClickJoystick(data.fx, data.fy, data.is_touch_move)
	elseif data.msg_type == "ChongZhiData" then
		RechargeCtrl.Instance:Recharge(data.money)
	end
end

function IosAuditReceiver:PlayEffect()
	
end

function IosAuditReceiver:OnClickTask(task_id)
	task_id = task_id or 0
	local task_status = TaskData.Instance:GetTaskStatus(task_id)
	local progress_num 
	local task_info = TaskData.Instance:GetTaskInfo(task_id)
	if task_info then
		progress_num = task_info.progress_num
	end
	local task_data = MainUIViewTask.TaskCellInfo(task_id, task_status, progress_num)
	MainUICtrl.Instance:FlushView("audit_task", {task_data})
end

function IosAuditReceiver:OnClickSkill(skill_index)
	if skill_index then
		MainUICtrl.Instance:FlushView("audit_use_skill", {skill_index})
	end
end

function IosAuditReceiver:OnClickJoystick(fx, fy, is_touch_move)
	if nil ~= fx and nil ~= fy then
		MainUICtrl.Instance:FlushView("audit_click_joystick", {fx, fy, is_touch_move})
	end
end
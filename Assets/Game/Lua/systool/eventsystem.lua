require("systool/event")

EventSystem = EventSystem or BaseClass()
function EventSystem:__init()
	self.is_deleted = false
	self.event_list = {}							-- 事件列表
	self.need_fire_events = {}						-- 需要激发的事件(延后调用方式)
end

function EventSystem:__delete()
	self.is_deleted = true
end

--调用已经处于派发队列中的Event
function EventSystem:Update()
	if #self.need_fire_events > 0 then
		local events = self.need_fire_events
		self.need_fire_events = {}

		for k, v in pairs(events) do
			v.event:Fire(v.arg_list)
		end
	end
end

function EventSystem:GetEventNum(t)
	for k, v in pairs(self.event_list) do
		t["global_event : " .. k] = v.bind_num
	end
end

function EventSystem:Bind(event_id, event_func)
	if event_id == nil then
		error("Try to bind to a nil event_id")
		return nil
	end

	if self.is_deleted then
		return nil
	end

	local tmp_event = self.event_list[event_id]
	if tmp_event == nil then
		tmp_event = Event.New(event_id)
		self.event_list[event_id] = tmp_event
	end

	return tmp_event:Bind(event_func)
end

function EventSystem:UnBind(event_handle)
	if event_handle == nil or event_handle.event_id == nil then
		error("Try to unbind a nil event_id")
		return
	end

	if self.is_deleted then
		return
	end

	local tmp_event = self.event_list[event_handle.event_id]
	if tmp_event ~= nil then
		tmp_event:UnBind(event_handle)
	end
end

--立即触发
function EventSystem:Fire(event_id, ...)
	if event_id == nil then
		error("Try to call EventSystem:Fire() with a nil event_id")
		return
	end

	if self.is_deleted then
		return
	end

	local tmp_event = self.event_list[event_id]
	if tmp_event ~= nil then
		tmp_event:Fire({...})
	end
end

--下一帧触发
function EventSystem:FireNextFrame(event_id, ...)
	if event_id == nil then
		error("Try to call EventSystem:FireNextFrame() with a nil event_id")
		return
	end

	if self.is_deleted then
		return
	end

	local tmp_event = self.event_list[event_id]
	if tmp_event ~= nil then
		table.insert(self.need_fire_events, {event = tmp_event, arg_list = {...}})
	end
end

function EventSystem:GetDebugEventCount(t)
	t.event_count = 0
	for k, v in pairs(self.event_list) do
		t.event_count = t.event_count + v.bind_num
	end
end
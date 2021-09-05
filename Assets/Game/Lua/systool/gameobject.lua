GameObject = {}
-- 重写GameObject.Instantiate接口项目统一用ResMgr:Instantiate
function GameObject.Instantiate(prefab)
	print_error("你哪来的这代码?不认真看?想请喝水吗?赶紧给我改了")
end

function GameObject.Destroy(obj)
	print_error("你哪来的这代码?不认真看?想请喝水吗?赶紧给我改了")
end

local mt = {}
mt.__index = function (tbl, key)
	return UnityEngine.GameObject[key]
end

setmetatable(GameObject, mt)

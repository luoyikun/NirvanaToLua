local M = {}

local UnityMaterial = typeof(UnityEngine.Material)
local ActorQingGongObject = typeof(ActorQingGongObject)

function M.init()
	local loader = AllocResAsyncLoader(M, "RoleOcclusion")
	loader:Load("misc/material", "RoleOcclusion", UnityMaterial,
		function(obj)
			M["role_occlusion"] = obj
		end)

	local loader = AllocResAsyncLoader(M, "RoleGhost_1")
	loader:Load("misc/material", "RoleGhost_1", UnityMaterial,
		function(obj)
			M["role_ghost_1"] = obj
		end)

	
	local loader = AllocResAsyncLoader(M, "RoleGhost_2")
	loader:Load("misc/material", "RoleGhost_2", UnityMaterial,
		function(obj)
			M["role_ghost_2"] = obj
		end)

	
	local loader = AllocResAsyncLoader(M, "RoleGhost_3")
	loader:Load("misc/material", "RoleGhost_3", UnityMaterial,
		function(obj)
			M["role_ghost_3"] = obj
		end)
	
	local loader = AllocResAsyncLoader(M, "RoleGhost_4")
	loader:Load("misc/material", "RoleGhost_4", UnityMaterial,
		function(obj)
			M["role_ghost_4"] = obj
		end)

	for i = 1, 4 do
		for j = 1, 4 do
			local loader = AllocResAsyncLoader(M, string.format("QingGongObject%s_%s", i, j))
			loader:Load("misc/qinggong", string.format("QingGongObject%s_%s", i, j), ActorQingGongObject,
				function(obj)
					M[string.format("QingGongObject%s_%s", i, j)] = obj
				end)
		end
	end

	local loader = AllocResAsyncLoader(M, "QingGongObject_back")
	loader:Load("misc/qinggong", "QingGongObject_back", ActorQingGongObject,
		function(obj)
			M["QingGongObject_back"] = obj
		end)
end

return M
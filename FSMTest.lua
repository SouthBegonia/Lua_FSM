require("BaseFSMState")
require("BaseFSM")

local SceneFSMStateDefine = {
    Login = "Login",
    Home = "Home",
    Battle = "Battle",
}

---@type BaseFSMState
local sceneLoginFSMState = BaseFSMState.New(SceneFSMStateDefine.Login);
sceneLoginFSMState.OnEnter = function()
    print("进入 Login状态");
end
sceneLoginFSMState.OnLeave = function()
    print("退出 Login状态");
end

---@type BaseFSMState
local sceneHomeFSMState = BaseFSMState.New(SceneFSMStateDefine.Home);
sceneHomeFSMState.OnEnter = function()
    print("进入 Home状态");
end
sceneHomeFSMState.OnLeave = function()
    print("退出 Home状态");
end

---@type BaseFSMState
local sceneBattleFSMState = BaseFSMState.New(SceneFSMStateDefine.Battle);
sceneBattleFSMState.OnEnter = function()
    print("进入 Battle状态");
end
sceneBattleFSMState.OnLeave = function()
    print("退出 Battle状态");
end


print("---------- 构造 FSM ----------");
local sceneFSM = BaseFSM.New();
sceneFSM:AddState(sceneLoginFSMState);
sceneFSM:AddState(sceneHomeFSMState);
sceneBattleFSMState:SetEntryCondition(function()
    --设置Battle状态的切换条件
    return sceneFSM:GetCurrentState() == sceneHomeFSMState;
end)
sceneFSM:AddState(sceneBattleFSMState);

print("---------- 设定 FSM初始状态为 Login ----------");
sceneFSM:SetStartState(SceneFSMStateDefine.Login);

print("---------- 切换 FSM状态为 Battle ----------");
sceneFSM:ChangeState(SceneFSMStateDefine.Battle);

print("---------- 切换 FSM状态为 Home ----------");
sceneFSM:ChangeState(SceneFSMStateDefine.Home);

print("---------- 切换 FSM状态为 Battle ----------");
sceneFSM:ChangeState(SceneFSMStateDefine.Battle);

--[[
    OUTPUT:
    ---------- 构造 FSM ----------
    ---------- 设定 FSM初始状态为 Login ----------
    进入 Login状态
    ---------- 切换 FSM状态为 Battle ----------
    ---------- 切换 FSM状态为 Home ----------
    退出 Login状态
    进入 Home状态
    ---------- 切换 FSM状态为 Battle ----------
    退出 Home状态
    进入 Battle状态
--]]



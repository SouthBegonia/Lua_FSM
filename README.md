# Lua_FSM
lua实现的 FSM(finite-state machine)

# 代码实现

为方便阅读，只粘了核心代码。完整版可移步Github：[Lua_FSM - SouthBegonia](https://github.com/SouthBegonia/Lua_FSM)


状态基类  BaseFSMState.lua

```lua
---@class BaseFSMState FSM状态基类
---@field public stateName string @状态名
---@field private entryCondition function @进入此状态的条件
BaseFSMState = {}

BaseFSMState.__index = BaseFSMState;

---实例化状态
---@public
---@param stateName string
function BaseFSMState.New(stateName)
    ---@type BaseFSMState
    local fsmState = setmetatable({}, BaseFSMState);

    fsmState.stateName = stateName;
    fsmState.entryCondition = nil;

    return fsmState;
end

---设置 进入此状态的条件
---@public
---@param condition function
function BaseFSMState:SetEntryCondition(condition)
    self.entryCondition = condition;
end

---判断 是否满足进入此状态的条件
---@public
---@return boolean
function BaseFSMState:CheckEntryCondition()
    if (self.entryCondition ~= nil) then
        return self.entryCondition();
    end

    return true;
end

---进入状态
---@public
function BaseFSMState:OnEnter()
end

---更新状态
---@public
function BaseFSMState:OnUpdate()
end

---离开状态
---@public
function BaseFSMState:OnLeave()
end
```



状态机基类  BaseFSM.lua

```lua
---@class BaseFSM FSM基类
---@field private states table<string, BaseFSMState> @持有的状态 的表（key=BaseFSM.stateName  value=BaseFSMState）
---@field private previousState BaseFSMState @先前状态
---@field private currentState BaseFSMState @当前状态
BaseFSM = {};

BaseFSM.__index = BaseFSM;

---构造 状态机实例
---@public
---@return BaseFSM
function BaseFSM.New()
    ---@type BaseFSM
    local fsm = setmetatable({}, BaseFSM);

    fsm.states = {};
    fsm.previousState = nil;
    fsm.currentState = nil;

    return fsm;
end

---添加 状态
---@param fsmState BaseFSMState
---@return boolean @是否 成功添加状态
function BaseFSM:AddState(fsmState)
    if (fsmState == nil) then
        --Error
        return false;
    end

    if (self.states[fsmState.stateName] ~= nil) then
        --Error
        return false;
    end

    self.states[fsmState.stateName] = fsmState;
    return true;
end

---设置 初始状态
---@param fsmStateName string
function BaseFSM:SetStartState(fsmStateName)
    local startFSMState = self.states[fsmStateName];
    if (startFSMState == nil) then
        --Error
        return false;
    end

    self.previousState = nil;
    self.currentState = startFSMState;
    self.currentState:OnEnter();

    return true;
end

---获取 当前状态
---@public
---@return BaseFSMState
function BaseFSM:GetCurrentState()
    return self.currentState;
end

---切换到 目标状态
---@public
---@param fsmStateName string
---@return boolean
function BaseFSM:ChangeState(fsmStateName)
    ---@type BaseFSMState
    local targetFSMState = self.states[fsmStateName];
    if (targetFSMState == nil) then
        --Error
        return false;
    end

    if (self.currentState == targetFSMState) then
        --Error
        return false;
    end

    if (not targetFSMState:CheckEntryCondition()) then
        --Log
        return false;
    end

    self.currentState:OnLeave();

    self.previousState = self.currentState;
    self.currentState = targetFSMState;

    self.currentState:OnEnter();

    return true;
end

---@public
function BaseFSM:Update()
    if (self.currentState ~= nil) then
        self.currentState:OnUpdate();
    end
end
```

测试：

```lua
---------- 添加 场景状态枚举 ----------
local SceneFSMStateDefine = {
    Login = "Login",
    Home = "Home",
    Battle = "Battle",
}

---------- 实例化 各场景状态 ----------
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

---------- 实例化 场景状态机 ----------
print("---------- 构造 FSM ----------");
local sceneFSM = BaseFSM.New();
sceneFSM:AddState(sceneLoginFSMState);
sceneFSM:AddState(sceneHomeFSMState);
sceneBattleFSMState:SetEntryCondition(function()
    --设置Battle状态的切换条件:仅当在Home状态时才可切换至Battle
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
```

# 参考文章

- [有限状态机 - 魂淡1994](https://blog.csdn.net/u013528298/article/details/88948525)
- [在Lua中实现面向对象特性——模拟类、继承、多态 - 马三小伙儿](https://www.cnblogs.com/msxh/p/8469340.html)
- [FSMKit - QFramework](https://github.com/liangxiegame/QFramework/blob/56fbf8287b0bf0686c383eb6151c1a3b444789f7/QFramework.Unity2018%2B/Assets/QFramework/Toolkits/_CoreKit/FSMKit/IState.cs)
- [Fsm - GameFramework](https://github.com/EllanJiang/GameFramework/tree/master/GameFramework/Fsm)
- [Lua中使用状态机FSM简单例子 - Kevin_绿豆芽](https://www.cnblogs.com/tangyongle/p/8135722.html)

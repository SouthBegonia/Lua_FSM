--[[
    - BaseFSM FSM状态机

    - 基本用法：
        1. 实例化状态机：local fsm = BaseFSM.New()
        2. 向状态机添加各状态实例：fsm:AddState(newState) ...
        3. 设定状态机的初始状态：fsm:SetStartState(startState)
        4. 切换状态机的状态：fsm:ChangeState(fsmStateName)
        5. 销毁状态机：fsm:Dispose()

--]]

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

---销毁 状态实例
---@public
function BaseFSM:Dispose()
    for key, _ in pairs(self.states) do
        self.states[key] = nil;
    end
    self.states = nil;
    self.previousState = nil;
    self.currentState = nil;
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


---获取 当前状态
---@public
---@return BaseFSMState
function BaseFSM:GetCurrentState()
    return self.currentState;
end

---判断 此状态机是否持有 目标状态
---@public
---@param fsmStateName string
---@return boolean
function BaseFSM:IsContainState(fsmStateName)
    return self.states[fsmStateName] ~= nil;
end

---获取 目标stateName的 状态
---@public
---@param fsmStateName string
---@return BaseFSMState
function BaseFSM:GetStateByName(fsmStateName)
    return self.states[fsmStateName];
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
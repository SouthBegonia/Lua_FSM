--[[
    - BaseFSMState FSM状态基类

    - 基本用法：
        1. 实例化状态：local fsmState = BaseFSMState.New(stateName)
        2. 向状态机添加状态实例

    - 额外用法：
        - 设定此状态的切换(进入)条件：fsmState:SetEntryCondition(condition)

--]]

---@class BaseFSMState FSM状态基类
---@field public stateName string @状态名
---@field private entryCondition function @进入此状态的条件
BaseFSMState = {}

BaseFSMState.__index = BaseFSMState;

--[[
---@param thisFSMState BaseFSMState
---@param targetFSMState BaseFSMState
BaseFSMState.__eq = function(thisFSMState, targetFSMState)
    return thisFSMState.stateName == targetFSMState.stateName;
end
--]]

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

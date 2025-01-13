-----------------------------------
--This file contains utility functions for working with async operations
-----------------------------------

local M = {}

--- Waits for the specified number of seconds before resolving the promise.
--- @param seconds number The number of seconds to wait before resolving the promise.
--- @return promise A promise that resolves after the specified number of seconds.
function M.wait_for(seconds)
    return async.run(function()
        local start = time.getCurrentTime();
        while (time.getCurrentTime() - start):getSeconds() < seconds do
            async.await(async.yield())
        end
        -- The specified time has elapsed, let the promise resolve now
    end, async.OnFrameExecutor)
end

--- Waits for a condition to be true
--- @param condition function The condition to wait for. Must return a truthy value
--- @param interval number? The interval in seconds to wait between checks. Defaults to 1 second.
--- @return promise A promise that resolves when the condition is met.
function M.wait_until(condition, interval)
    return async.run(function()
        -- Default interval to 0.01 seconds if not provided
        interval = interval or 0.01
        while not condition() do
            -- Wait for the specified interval
            M.wait_for(interval)
            async.await(async.yield())
        end
        -- The condition has been met, let the promise resolve now
    end, async.OnFrameExecutor)
end

return M

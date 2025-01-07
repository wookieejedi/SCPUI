-----------------------------------
--This file sets up the UI Topics system, allowing a sort of hook-like structure for scripts to interact with
-----------------------------------

local class = require('class')

--- A simple message bus.
-- Messages can be sent to a topic, and are automatically received by any
-- listeners registered with the topic. Listeners are executed in priority
-- order, with listeners at a lower priority executed before those with a
-- higher priority.
-- Every message is sent along with a context, which allows listeners to
-- communicate with each other. The context carries a value, which any listener
-- may read or right, and provides a means to stop processing the message. When
-- a message is sent, its value, if any, is returned to the sender. To
-- facilitate collaborative calculation, a topic may be given an "initial value
-- factory", a function which accepts a message and returns the value to seed
-- the context with. For convenience, if something other than a function is
-- given as the initial value factory, it is replaced with a function that
-- always returns the value. For example, Topic(function(message) return 2 end)
-- may be written as Topic(2).
local Topic = class(function(self, initial)
  self._subscriptions = {}
  if type(initial) == 'function' then
    self._initial = initial
  else
    self._initial = function() return initial end
  end
end)

--- Send a message to everything subscribed to the topic.
--- This first creates a context, passing the message to the topic's initial
--- value factory to create its value. The message and context are then given to
--- each subscription in priority order. Finally, the context's value is
--- returned. If any of the listeners cancel the message, then no further
--- listeners receive the message, but the context's value is still returned.
--- @param message any The message to send.
--- @return any The message's context's value after all listeners have processed it.
Topic.send = function(self, message)
  local value = self._initial(message)
  local context = { value = value, done = false }
  for _, subscription in ipairs(self._subscriptions) do
    local callback = subscription[2]
    callback(message, context)
    if context.done then break end
  end
  return context.value
end

--- Register a listener with this topic.
--- The given callback will be called with two arguments: the message and its
--- context. The listener may set the context's `value` field to pass a value
--- back to the sender, or set its `done` field to cancel further processing.
--- @param priority integer The listener's priority.
--- @param callback function The function to invoke when the listener receives a message.
--- @return any topic This topic.
Topic.bind = function(self, priority, callback)
  local subscriptions = self._subscriptions
  local subscription = { priority, callback, #subscriptions }
  table.insert(subscriptions, subscription)
  table.sort(subscriptions, function(a, b)
    if a[1] ~= b[1] then
      return a[1] < b[1] -- Lower priority comes first
    else
      return a[3] < b[3] -- With the same priority, retain insertion order
    end
  end)
end

return Topic


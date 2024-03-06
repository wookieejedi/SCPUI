--[[
A "term" is either a non-empty sequence characters such that each character the
sequence is a word character or ' character, or no character in the sequence is
any of those. For example, "the Intrepid's battlegroup" contains the terms
"the", " ", "Intrepid's", " ", and "battlegroup".

Keywords are broken up into terms and arranged in a tree structure. Each node
in the tree can have a color, but doesn't need to. For example, suppose
"Admiral Po" is defined as blue, "Admiral Glaive" is defined as red, and
"Admiral" is defined as white for some reason. We'd get the following tree:

  keywords['Admiral']                (white)
  keywords['Admiral'][' ']           (no color)
  keywords['Admiral'][' ']['Po']     (blue)
  keywords['Admiral'][' ']['Glaive'] (red)

When it comes time to apply colorization, we start with a term and see if it
is a key into the keywords table. If it is, we repeatedly check the next
term and descend further into the tree. Once we find a term that isn't a
match, we stop and check if our match has a color. If not, we backtrack
until we find one that is.

For example, given the input 'Admiral Po', we'd see that 'Admiral' is a
valid key, ' ' is a valid sub-key, and 'Po' is a valid sub-sub-key, and
color it blue. Given 'Admiral Poopypants', we'd see that 'Admiral' is a
valid key and ' ' is a valid sub-key, but since 'Poopypants' isn't a valid
sub-sub-key, we stop there. However, keywords['Admiral'][' '] has no color, 
so we backtrack to keywords['Admiral'], which does, and ultimately settle
on white.

There is one more caveat, which is that we only want to process keywords
which are not inside a valid HTML tag. This is supported further below.
]]

-- Some arbitrary key which is not a legal term
local COLOR = '<{@[ COLOR ]@}>'

local function getTerms(s)
  -- Lua patterns don't support alternation, so we need to get creative.
  -- First, we'll find pairs of sequences such that the first sequence contains
  -- only word and ' characters, and the second contains only other characters,
  -- allowing empty sequences...
  local matches = s:gmatch("([%w']*)([^%w']*)")
  -- ...then, we flatten the result, removing empty sequences.
  local terms = {}
  for word, rest in matches do
    if word ~= '' then table.insert(terms, word) end
    if rest ~= '' then table.insert(terms, rest) end
  end
  return terms
end

-- The tree of keywords described at the top of this file.
local keywords = {}

local function registerKeyword(keyword, color)
  local node = keywords
  for _, term in ipairs(getTerms(keyword)) do
    local nextNode = node[term]
    if not nextNode then
      nextNode = {}
      node[term] = nextNode
    end
    node = nextNode
  end
  if node[COLOR] then
    -- Unless we're registering the same color twice, this is a conflict.
    return node[COLOR] == color
  else
    node[COLOR] = color
    return true
  end
end

local function getColor(terms, index, node)
  -- This would probably perform better as an iterative function.
  -- Refactor if the recursion proves to be a performance issue.
  local term = terms[index]
  local nextNode = node[term]
  if nextNode then
    local nextIndex, nextColor = getColor(terms, index + 1, nextNode)
    if nextColor then
     return nextIndex, nextColor
    else
     return index, nextNode[COLOR]
    end
  else
    return nil, nil
  end
end

local function colorizeFragment(s)
  -- Take a fragment of literal text (i.e. text without any HTML tags in it),
  -- break it up into terms, and scan for keywords within those terms using the
  -- algorithm described at the top of this file.
  local i = 1
  local result = ''
  local terms = getTerms(s)
  local count = #terms
  while i <= count do
    local j, color = getColor(terms, i, keywords)
    if j and color then
      -- We found a keyword! Color it and skip ahead if it spans multiple terms.
      result = result .. "<span class='" .. color .. "'>"
      for x = i, j do
        result = result .. terms[x]
      end
      result = result .. '</span>'
      i = j + 1
    else
      -- We couldn't find any keywords, so return this term literally.
      result = result .. terms[i]
      i = i + 1
    end
  end
  return result
end

local function colorize(s)
  -- This depth variable keeps track of whether we're nested inside a tag.
  local depth = 0
  -- A "fragment" is an HTML start tag (e.g. <span>), end tag (e.g. </span>),
  -- or self-closing tag (e.g. <br/>), or text that contains no tags. This
  -- pattern matches fragments, assuming that we're given valid HTML; it will
  -- technically behave incorrectly on invalid HTML, but libRocket won't handle
  -- that anyway, so whatever.
  return s:gsub('[<]?[^<>]*[>]?', function(x)
    if x:sub(1, 1) == '<' then
      if (x:sub(2, 2) == '/') then
        -- This is a start tag (e.g. <span>). Increase the nesting depth.
        depth = depth + 1
        return x
      elseif x:find('/>$') then
        -- This is a self-closing tag (e.g. <br/>). It has no effect on the
        -- nesting depth, but doesn't make sense to colorize.
        return x
      else
        -- This is a end tag (e.g. </span>). Decrease the nesting depth.
        depth = depth - 1
        return x
      end
    elseif depth == 0 then
      -- A depth of 0 means this fragment isn't nested. Colorize away!
      return colorizeFragment(x)
    else
      -- This fragment is nested, so don't colorize it.
      return x
    end
  end):gsub('> <', '>&nbsp;<')
end

return { colorize = colorize, registerKeyword = registerKeyword }


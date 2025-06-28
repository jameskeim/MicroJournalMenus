-- Pandoc Lua filter for accurate word counting in Markdown
-- Based on official Pandoc documentation

words = 0

wordcount = {
  Str = function(el)
    -- Count words that aren't purely punctuation
    if el.text:match("%P") then
        words = words + 1
    end
  end,

  Code = function(el)
    -- Count words in inline code
    _,n = el.text:gsub("%S+","")
    words = words + n
  end,

  CodeBlock = function(el)
    -- Count words in code blocks
    _,n = el.text:gsub("%S+","")
    words = words + n
  end
}

function Pandoc(el)
    -- Skip metadata, only count document body
    el.blocks:walk(wordcount)
    print(words)
    os.exit(0)
end
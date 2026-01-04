--- @class gemini_cleaner
local M = {}

--- Cleans Gemini citation markers and fixes markdown formatting.
--- @param text string The raw buffer content as a single string.
--- @return string The cleaned text.
function M.clean(text)
  if not text then
    return ""
  end

  local clean_text = text

  -- 1. Remove all citation patterns globally
  -- Matches [cite...] including [cite_start], [cite_end], and specific citations
  clean_text = clean_text:gsub("%[cite[^%]]*%]", "")

  -- 2. Fix markdown formatting issue: convert bullet * to - when followed by bold **
  -- This prevents misinterpretation of * **... as italic.
  -- Note: Corrected `^*` to `^%*` to match literal asterisk
  clean_text = clean_text:gsub("^%* (%(%*%*))", "- %1")
  clean_text = clean_text:gsub("\n%* (%(%*%*))", "\n- %1")

  -- 3. Only clean up multiple horizontal spaces (preserve line breaks)
  clean_text = clean_text:gsub("[ \t]+", " ")

  -- 4. Clean up any trailing spaces at end of lines
  clean_text = clean_text:gsub(" +(\n)", "%1")
  clean_text = clean_text:gsub(" +$", "")

  -- 5. Clean up leading spaces that might be left after citation removal
  clean_text = clean_text:gsub("^[ \t]+", "") -- At start of file
  clean_text = clean_text:gsub("\n[ \t]+", "\n") -- At start of subsequent lines

  return clean_text
end

return M

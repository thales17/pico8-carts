pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

size = 4
screenSize = flr(128 / size)
cellBuffer = {}
frame = 0
resetFrames = 100

function initCells()
  cellBuffer = {}
  for i = 0,(screenSize * screenSize) do
    local dice = flr(rnd(10))
    if (dice < 1) then
      add(cellBuffer, 1)
    else
      add(cellBuffer, 0)
    end
  end
end

function drawCells()
  local i = 1
  for cell in all(cellBuffer) do
    local color = 0
    if (cell == 1) then
      color = 3
    end
    local x = i % screenSize
    local y = flr(i / screenSize)
    rectfill((x*size),(y*size),(x*size)+size,(y*size)+size,color)
    i += 1
  end
end

function scoreForCell(idx)
  local x = (idx-1) % screenSize
  local y = flr((idx-1) / screenSize)

  local nw = (x-1) + ((y-1)*screenSize)
  local n = (x) + ((y-1)*screenSize)
  local ne = (x+1) + ((y-1)*screenSize)
  local w = (x-1) + ((y) * screenSize)
  local e = (x+1) + ((y) * screenSize)
  local sw = (x-1) + ((y+1) * screenSize)
  local s = (x) + ((y+1) * screenSize)
  local se = (x+1) + ((y+1) * screenSize)
  
  local max = screenSize * screenSize

  local score = 0
  if (nw > 0 and nw < max) then
    score += cellBuffer[nw+1]
  end
  if (n > 0 and n < max) then
    score += cellBuffer[n+1]
  end
  if (ne > 0 and ne < max) then
    score += cellBuffer[ne+1]
  end
  if (w > 0 and w < max) then
    score += cellBuffer[w+1]
  end
  if (e > 0 and e < max) then
    score += cellBuffer[e+1]
  end
  if (sw > 0 and sw < max) then
    score += cellBuffer[sw+1]
  end
  if (s > 0 and s < max) then
    score += cellBuffer[s+1]
  end
  if (se > 0 and se < max) then
    score += cellBuffer[se+1]
  end

  return score
end

function updateCells()
  -- Any live cell with fewer than two live neighbors dies, as if by underpopulation.
  -- Any live cell with two or three live neighbors lives on to the next generation.
  -- Any live cell with more than three live neighbors dies, as if by overpopulation.
  -- Any dead cell with exactly three live neighbors becomes a live cell, as if by reproduction.
  local i = 1
  for cell in all(cellBuffer) do
    local score = scoreForCell(i)
    if (cell == 1) then
      if (score < 2) then
        cellBuffer[i] = 0
      end
      if (score > 3) then
        cellBuffer[i] = 0
      end
    else
      if (score == 3) then
        cellBuffer[i] = 1
      end
    end
    i += 1
  end
end

function _init()
  initCells()
end

function _update60()
  updateCells()
  frame += 1
  if (frame > resetFrames) then
    initCells()
    frame = 0
  end
end

function _draw()
  cls()
  drawCells()
end
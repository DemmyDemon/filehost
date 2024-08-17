local prefix = GetResourcePath(GetCurrentResourceName()) .. '/files/'
local open = io.open
local bufferSize = 2^13

MIME = {
    png  = 'image/png',
    jpg  = 'image/jpeg',
    jpeg = 'image/jpeg',
    json = 'application/json',
    mp3  = 'audio/mpeg',
    mp4  = 'video/mp4',
    mpeg = 'video/mpeg',
    mpg  = 'video/mpeg',
}

local function splitFilename(strFilename)
    return string.match(strFilename, "(.-)([^/]-([^/%.]+))$")
end

local function sendFileData(mimeType, path, response)
    local file = open(path, "rb")
    if not file then return false end

    response.writeHead(200, {["Content-Type"] = mimeType})

    while true do
        local data = file:read(bufferSize)
        if not data then break end
        response.write(data)
    end
    file:close()
    response.send()
    return true
end

local function log(peer, status, filename)
    print( ("FILEHOST: %s %d %s"):format(peer, status, filename) )
end

local function handler(request, response)
    local _, filename, ext = splitFilename(request.path)
    local fullpath = prefix .. filename

    local useMimeType = "text/plain"
    if MIME[ext] then
        useMimeType = MIME[ext]
    end

    local found = sendFileData(useMimeType, fullpath, response)

    if not found then
        response.writeHead(404, {["Content-Type"] = "text/plain"})
        response.send("No such file")
        log(request.address, 404, filename)
        return
    end

    log(request.address, 200, filename)
end


SetHttpHandler(handler)

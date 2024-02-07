
function printDebug(msg, debug)
    if debug then
        if type(msg) == "table" then
            printTable(msg)
        else
            print(msg)
        end
    end
end





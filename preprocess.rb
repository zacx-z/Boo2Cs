def getTab line
    return line.chars.take_while { |c| c == ' ' or c == "\t" }.join
end

def isEmpty line
    return (line.strip.start_with?('#', '//') or line.chars.all? { |c| c == ' ' or c == "\t" or c == "\n"})
end

File.open(ARGV[0], "r") do |file|
    tabStack = [""]
    emptyLines = []
    while not file.eof? do
        line = file.readline
        line.slice! /\ufeff+/
        if isEmpty line then
            emptyLines << line
        else
            currentTab = getTab line

            if currentTab.length > tabStack.last.length then
                puts tabStack.last + '{'
                tabStack << currentTab
            elsif currentTab.length < tabStack.last.length then
                while tabStack.last.length > currentTab.length do
                    tabStack.pop
                    puts tabStack.last + '}'
                end
            end

            emptyLines.each do |line| puts line end
            emptyLines = []

            puts line
        end
    end
    currentTab = ""
    if tabStack.length > 0 then
        while tabStack.last.length > currentTab.length do
            tabStack.pop
            puts tabStack.last + '}'
        end
    end

emptyLines.each do |line| puts line end
    emptyLines = 0
end


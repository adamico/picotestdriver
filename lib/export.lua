-- Export test results to various formats
local export = {}

-- Export to JSON format
function export.to_json(test_results)
    local json = "{"
    json = json .. '"passed":' .. test_results.passed .. ','
    json = json .. '"failed":' .. test_results.failed .. ','
    json = json .. '"total":' .. test_results.total .. ','
    json = json .. '"failures":['
    
    for i, failure in ipairs(test_results.failures) do
        if i > 1 then json = json .. ',' end
        json = json .. '{'
        json = json .. '"test":"' .. (failure.test or "") .. '",'
        json = json .. '"message":"' .. (failure.message or "") .. '"'
        json = json .. '}'
    end
    
    json = json .. ']}'
    return json
end

-- Export to CSV format
function export.to_csv(test_results)
    local csv = "passed,failed,total\n"
    csv = csv .. test_results.passed .. "," .. test_results.failed .. "," .. test_results.total .. "\n"
    
    if #test_results.failures > 0 then
        csv = csv .. "\ntest,message\n"
        for _, failure in ipairs(test_results.failures) do
            csv = csv .. (failure.test or "") .. "," .. (failure.message or "") .. "\n"
        end
    end
    
    return csv
end

-- Export to Markdown format
function export.to_markdown(test_results)
    local md = "# Test Results\n\n"
    md = md .. "Passed: " .. test_results.passed .. "\n"
    md = md .. "Failed: " .. test_results.failed .. "\n"
    md = md .. "Total: " .. test_results.total .. "\n"
    
    if #test_results.failures > 0 then
        md = md .. "\n## Failures\n\n"
        for _, failure in ipairs(test_results.failures) do
            md = md .. "- **" .. (failure.test or "unknown") .. "**: " .. (failure.message or "no message") .. "\n"
        end
    end
    
    return md
end

return export

-- Test export functionality
describe("Export functionality", function()
    local export
    
    before_each(function()
        -- Load the export module
        export = require("lib.export")
    end)
    
    describe("JSON export", function()
        it("should export test results to JSON format", function()
            local test_results = {
                passed = 5,
                failed = 2,
                total = 7,
                failures = {
                    {test = "test1", message = "assertion failed"},
                    {test = "test2", message = "expected 5, got 3"}
                }
            }
            
            local json = export.to_json(test_results)
            
            assert.is_string(json)
            assert.is_truthy(json:find('"passed":5'))
            assert.is_truthy(json:find('"failed":2'))
            assert.is_truthy(json:find('"total":7'))
        end)
        
        it("should handle empty results", function()
            local test_results = {
                passed = 0,
                failed = 0,
                total = 0,
                failures = {}
            }
            
            local json = export.to_json(test_results)
            
            assert.is_string(json)
            assert.is_truthy(json:find('"total":0'))
        end)
    end)
    
    describe("CSV export", function()
        it("should export test results to CSV format", function()
            local test_results = {
                passed = 5,
                failed = 2,
                total = 7,
                failures = {
                    {test = "test1", message = "assertion failed"},
                    {test = "test2", message = "expected 5, got 3"}
                }
            }
            
            local csv = export.to_csv(test_results)
            
            assert.is_string(csv)
            assert.is_truthy(csv:find("passed,failed,total"))
            assert.is_truthy(csv:find("5,2,7"))
        end)
        
        it("should include failure details", function()
            local test_results = {
                passed = 1,
                failed = 1,
                total = 2,
                failures = {
                    {test = "failing_test", message = "error message"}
                }
            }
            
            local csv = export.to_csv(test_results)
            
            assert.is_truthy(csv:find("failing_test"))
            assert.is_truthy(csv:find("error message"))
        end)
    end)
    
    describe("Markdown export", function()
        it("should export test results to Markdown format", function()
            local test_results = {
                passed = 5,
                failed = 2,
                total = 7,
                failures = {
                    {test = "test1", message = "assertion failed"}
                }
            }
            
            local md = export.to_markdown(test_results)
            
            assert.is_string(md)
            assert.is_truthy(md:find("# Test Results"))
            assert.is_truthy(md:find("Passed: 5"))
            assert.is_truthy(md:find("Failed: 2"))
        end)
        
        it("should format failures as list", function()
            local test_results = {
                passed = 0,
                failed = 2,
                total = 2,
                failures = {
                    {test = "test1", message = "error1"},
                    {test = "test2", message = "error2"}
                }
            }
            
            local md = export.to_markdown(test_results)
            
            assert.is_truthy(md:find("test1"))
            assert.is_truthy(md:find("test2"))
            assert.is_truthy(md:find("error1"))
            assert.is_truthy(md:find("error2"))
        end)
    end)
end)

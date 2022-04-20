local CollectionService = game:GetService("CollectionService")
local function createInst()
	local folder = Instance.new("Folder")
	folder.Parent = workspace
	game:GetService("Debris"):AddItem(folder, 10)
	return folder
end

function creatInstances(amount)
	local list = {}
	for i=1, amount do
		table.insert(list, createInst())
	end
	return list
end

return function()
	-- Query.new(...)
	-- Query:Destroy()

	-- Query.subtract(...) --adds tables, instead of keys
	-- Query.add(...) --adds tables, instead of keys

	-- Query.addKVTag(inst, key, value)
	-- Query.hasKTag(inst, key)
	-- Query.getValueFromKey(inst, key)
	-- Query.removeKVTag(inst, key)
	
	-- Query.getKVTagged(key, value)
	-- Query.getKTagged(key)
	-- Query.getAllKVTags(key, value): {[number]: string}

	-- Query:Subtract(...)
	-- Query:Get(key)
	-- Query:Add(...)
	-- Query:RunSeries(constraints)
	-- Query:Run(key, func)
	-- Query:GetSmallestTagCollection(): {[number]: Instance}
	-- Query:SetWhitelist(whitelist)

	
	describe("Query utilities", function()
		it("should boot", function()
			local Query = require(script.Parent.Query)
			expect(Query).to.be.ok()
		end)
		it("should subtract", function()
			local Query = require(script.Parent.Query)
			local inst1 = createInst()
			local inst2 = createInst()
			local inst3 = createInst()
			local list = {inst1,inst2,inst3}
			local list2 = {inst2}
			local final = Query.subtract(list, list2)
			expect(#final).to.equal(2)
		end)
		it("should add", function()
			local Query = require(script.Parent.Query)
			local inst1 = createInst()
			local inst2 = createInst()
			local inst3 = createInst()
			local list = {inst1,inst3}
			local list2 = {inst2,inst1}
			local final = Query.add(list, list2)
			expect(#final).to.equal(3)
		end)
		it("should add and retrieve KV Tag", function()
			local Query = require(script.Parent.Query)
			local inst = createInst()
		
			Query.addKVTag(inst, "test", 123)
			expect(Query.hasKTag(inst, "test")).to.equal(true)
			expect(Query.getValueFromKey(inst, "test")).to.equal("123")
		end)
		it("should add and remove KV Tag", function()
			local Query = require(script.Parent.Query)
			local inst = createInst()
		
			Query.addKVTag(inst, "test", true)
			expect(Query.getValueFromKey(inst, "test")).to.equal("true")
			Query.removeKVTag(inst, "test")
			expect(Query.getValueFromKey(inst, "test")).to.equal(nil)
		end)
		it("should add and retrieve KV Tag", function()
			local Query = require(script.Parent.Query)

			local inst1 = createInst()
			local inst2 = createInst()
			local inst3 = createInst()

			Query.addKVTag(inst1, "KeyTest9", 123)
			Query.addKVTag(inst2, "KeyTest9", 123)
			Query.addKVTag(inst3, "KeyTest9", 456)

			local tagInstances = Query.getKVTagged("KeyTest9", "123")
			expect(#tagInstances).to.equal(2)
		end)
		it("should add and retrieve K Tag", function()
			local Query = require(script.Parent.Query)

			local inst1 = createInst()
			local inst2 = createInst()

			Query.addKVTag(inst1, "KeyTest8", 123)
			Query.addKVTag(inst2, "KeyTest8", 456)

			local tagInstances = Query.getKTagged("KeyTest8")
			expect(#tagInstances).to.equal(2)
		end)
		it("should retrieve all of the tags", function()
			local Query = require(script.Parent.Query)

			local inst = createInst()

			Query.addKVTag(inst, "Tag1a", 123)
			Query.addKVTag(inst, "Tag2a", 456)

			local tagInstances = CollectionService:GetTags(inst)

			local found1 = false
			local found2 = false
			for i, tag in ipairs(tagInstances) do
				if tag == "Tag1a" then
					found1 = true
				elseif tag == "Tag2a" then
					found2 = true
				end
			end

			expect(found1).to.equal(true)
			expect(found2).to.equal(true)
		end)
	end)

	describe("Query object", function()
		it("should construct and clean query", function()
			local Query = require(script.Parent.Query)
			local query = Query.new("Tag1", "Tag2")
			expect(query).to.be.ok()
			query:Destroy()
		end)
		it("should set and get a whitelist", function()
			local Query = require(script.Parent.Query)
			local inst1 = createInst()
			local inst2 = createInst()
			local inst3 = createInst()
			
			Query.addKVTag(inst1, "Tag1", 123)
			Query.addKVTag(inst1, "Tag2", 456)
			Query.addKVTag(inst2, "Tag1", 789)

			local query = Query.new("Tag1", "Tag2")
			query:SetWhitelist({inst1, inst2, inst3})
			expect(query).to.be.ok()

			query:Destroy()
		end)
		it("should Subtract", function()
			local Query = require(script.Parent.Query)
			local inst1 = createInst()
			local inst2 = createInst()
			local inst3 = createInst()
			
			Query.addKVTag(inst1, "Tag1", 123)
			Query.addKVTag(inst1, "Tag2", 456)
			Query.addKVTag(inst2, "Tag1", 789)

			local query = Query.new("Tag1", "Tag2")
			query:SetWhitelist({inst1, inst2, inst3})

			local list = query:Subtract("Tag1", "Tag2")
			expect(#list).to.equal(1)
			
			query:Destroy()
		end)
		it("should Get", function()
			local Query = require(script.Parent.Query)
			local inst1 = createInst()
			local inst2 = createInst()
			local inst3 = createInst()
			
			Query.addKVTag(inst1, "Tag1", 123)
			Query.addKVTag(inst1, "Tag2", 456)
			Query.addKVTag(inst2, "Tag1", 789)

			local query = Query.new("Tag1", "Tag2")
			query:SetWhitelist({inst1, inst2, inst3})

			local list = query:Get("Tag2")
			expect(#list).to.equal(1)

			query:Destroy()
		end)
		it("should Add", function()
			local Query = require(script.Parent.Query)
			local inst1 = createInst()
			local inst2 = createInst()
			local inst3 = createInst()
			
			Query.addKVTag(inst1, "aTag1", 123)
			Query.addKVTag(inst2, "aTag2", 456)
			Query.addKVTag(inst3, "aTag3", 456)

			local query = Query.new("aTag1", "aTag2")
			query:SetWhitelist({inst1, inst2, inst3})

			local list = query:Add("aTag2", "aTag1")
			expect(#list).to.equal(2)
			
			query:Destroy()
		end)
		it("should Run", function()
			local Query = require(script.Parent.Query)
			local inst1 = createInst()
			local inst2 = createInst()
			local inst3 = createInst()
			
			Query.addKVTag(inst1, "Tag1", 123)
			Query.addKVTag(inst2, "Tag1", 56)
			Query.addKVTag(inst3, "Tag1", 256)

			local query = Query.new("Tag1", "Tag2")
			query:SetWhitelist({inst1, inst2, inst3})

			local list = query:Run("Tag1", function(v)
				return tonumber(v) > 100
			end)
			expect(#list).to.equal(2)
			
			query:Destroy()
		end)
		it("should Run Series", function()
			local Query = require(script.Parent.Query)
			local inst1 = createInst()
			local inst2 = createInst()
			local inst3 = createInst()
			
			Query.addKVTag(inst1, "Row", 123)
			Query.addKVTag(inst2, "Row", 56)
			Query.addKVTag(inst3, "Row", 256)

			Query.addKVTag(inst1, "Column", 159)
			Query.addKVTag(inst2, "Column", 23)
			Query.addKVTag(inst3, "Column", 57)

			local query = Query.new("Row", "Column")
			query:SetWhitelist({inst1, inst2, inst3})

			local list = query:RunSeries({
				Row = function(v)
					return tonumber(v) > 100
				end,
				Column = function(v)
					return tonumber(v) > 100
				end,
			})
			expect(#list).to.equal(1)
			
			query:Destroy()
		end)
		it("should get smallest list", function()
			local Query = require(script.Parent.Query)
			local inst1 = createInst()
			local inst2 = createInst()
			local inst3 = createInst()
			
			Query.addKVTag(inst1, "Tag1", 123)
			Query.addKVTag(inst2, "Tag1", 56)
			Query.addKVTag(inst3, "Tag2", 256)

			local query = Query.new("Tag1", "Tag2")
			query:SetWhitelist({inst1, inst2, inst3})

			local list = query:GetSmallestTagCollection()
			expect(#list).to.equal(1)
			
			query:Destroy()
		end)
	end)
 end
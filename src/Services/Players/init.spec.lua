
return function ()
	describe("Players", function()

		it("should boot", function()
			local Players = require(script.Parent)
			expect(Players).to.be.ok()
		end)
		it("should be empty prior to testing", function()
			local Players = game:GetService("Players")
			expect(#Players:GetChildren()).to.equal(0)
		end)
		it("should index correctly", function()
			local Players = require(script.Parent)
			Players:GetPlayer(1)
			local maid = Players._Maid
			local respawnTime = Players.RespawnTime
		end)
		it("should add player", function()
			local id = 3
			local Players = require(script.Parent)
			Players:CreatePseudoPlayer(id, nil)
			local fakePlayer = Players:GetPlayer(id)
			expect(fakePlayer).never.to.equal(nil)
			fakePlayer:Destroy()
		end)
		it("should remove player", function()
			local id = 4
			local Players = require(script.Parent)
			Players:CreatePseudoPlayer(id, nil)
			Players:RemoveFakePlayer(id)
		end)
	end)
end
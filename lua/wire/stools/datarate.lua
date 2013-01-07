WireToolSetup.setCategory( "Advanced" )
WireToolSetup.open( "datarate", "Data - Transfer Bus", "gmod_wire_datarate", nil, "Transfer Buses" )

if ( CLIENT ) then
	language.Add( "Tool.wire_datarate.name", "Data transfer bus tool (Wire)" )
	language.Add( "Tool.wire_datarate.desc", "Spawns a data transferrer. Data transferrer acts like identity gate for hi-speed and regular links" )
	language.Add( "Tool.wire_datarate.0", "Primary: Create/Update data trasnferrer" )
	language.Add( "sboxlimit_wire_datarates", "You've hit data trasnferrers limit!" )
	language.Add( "undone_wiredatarate", "Undone Data Transferrer" )
end

if (SERVER) then
	CreateConVar('sbox_maxwire_datarates', 20)
end

TOOL.ClientConVar[ "model" ] = "models/jaanus/wiretool/wiretool_gate.mdl"

cleanup.Register( "wire_datarates" )

function TOOL:LeftClick( trace )
	if trace.Entity:IsPlayer() then return false end
	if (CLIENT) then return true end
	if not util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) then return false end

	local ply = self:GetOwner()

	if ( trace.Entity:IsValid() && trace.Entity:GetClass() == "gmod_wire_datarate" ) then
		return true
	end

	if ( !self:GetSWEP():CheckLimit( "wire_datarates" ) ) then return false end

	if (not util.IsValidModel(self:GetClientInfo( "model" ))) then return false end
	if (not util.IsValidProp(self:GetClientInfo( "model" ))) then return false end

	local ply = self:GetOwner()
	local Ang = trace.HitNormal:Angle()
	local model = self:GetClientInfo( "model" )
	Ang.pitch = Ang.pitch + 90

	wire_datarate = MakeWiredatarate( ply, trace.HitPos, Ang, model )
	local min = wire_datarate:OBBMins()
	wire_datarate:SetPos( trace.HitPos - trace.HitNormal * min.z )

	local const = WireLib.Weld(wire_datarate, trace.Entity, trace.PhysicsBone, true)

	undo.Create("Wiredatarate")
		undo.AddEntity( wire_datarate )
		undo.SetPlayer( ply )
	undo.Finish()

	ply:AddCleanup( "wire_datarates", wire_datarate )

	return true
end

if (SERVER) then

	function MakeWiredatarate( pl, Pos, Ang, model )

		if ( !pl:CheckLimit( "wire_datarates" ) ) then return false end

		local wire_datarate = ents.Create( "gmod_wire_datarate" )
		if (!wire_datarate:IsValid()) then return false end
		wire_datarate:SetModel(model)

		wire_datarate:SetAngles( Ang )
		wire_datarate:SetPos( Pos )
		wire_datarate:Spawn()

		wire_datarate:SetPlayer(pl)

		local ttable = {
			pl = pl,
		}
		table.Merge(wire_datarate:GetTable(), ttable ) -- TODO: remove?

		pl:AddCount( "wire_datarates", wire_datarate )

		return wire_datarate

	end

	duplicator.RegisterEntityClass("gmod_wire_datarate", MakeWiredatarate, "Pos", "Ang", "Model")

end

function TOOL.BuildCPanel(panel)
	panel:AddControl("Header", { Text = "#Tool.wire_datarate.name", Description = "#Tool.wire_datarate.desc" })
end

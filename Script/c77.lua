--Tidal Blast
local s,id=GetID()
function s.initial_effect(c)
	--Treated as Bonding card
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_ADD_CODE)
	e0:SetRange(LOCATION_ALL)
	e0:SetValue(0x100)
	c:RegisterEffect(e0)
	
	--Check number of different WIND/WATER Dinosaur monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_DINOSAUR) and (c:IsAttribute(ATTRIBUTE_WATER) or c:IsAttribute(ATTRIBUTE_WIND))
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	e:SetLabel(ct)
end

function s.waterfilter(c)
	return c:IsFaceup() and c:IsCode(85066822)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	
	--Effect 1+: Unaffected by Trap effects
	if ct>=1 then
		local g=Duel.GetMatchingGroup(s.waterfilter,tp,LOCATION_MZONE,0,nil)
		g:ForEach(function(tc)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,1))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e1:SetCode(EFFECT_IMMUNE_EFFECT)
			e1:SetRange(LOCATION_MZONE)
			e1:SetValue(s.efilter1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end)
	end
	
	--Effect 2+: Unaffected by Spell effects
	if ct>=2 then
		local g=Duel.GetMatchingGroup(s.waterfilter,tp,LOCATION_MZONE,0,nil)
		g:ForEach(function(tc)
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetDescription(aux.Stringid(id,2))
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e2:SetCode(EFFECT_IMMUNE_EFFECT)
			e2:SetRange(LOCATION_MZONE)
			e2:SetValue(s.efilter2)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		end)
	end
	
	--Effect 3+: Cannot be destroyed by battle or card effects
	if ct>=3 then
		local g=Duel.GetMatchingGroup(s.waterfilter,tp,LOCATION_MZONE,0,nil)
		g:ForEach(function(tc)
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetDescription(aux.Stringid(id,3))
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e3:SetValue(1)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
			local e4=e3:Clone()
			e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			tc:RegisterEffect(e4)
		end)
	end
	
	--Effect 4+: Destroy FIRE and Pyro monsters, damage
	if ct>=4 then
		local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		local des=dg:Filter(Card.IsAttribute,nil,ATTRIBUTE_FIRE)
		local pyro=dg:Filter(Card.IsRace,nil,ATTRIBUTE_PYRO)
		des:Merge(pyro)
		local ct2=Duel.Destroy(des,REASON_EFFECT)
		if ct2>0 then
			Duel.Damage(tp,ct2*500,REASON_EFFECT)
			Duel.Damage(1-tp,ct2*500,REASON_EFFECT)
		end
	end
end

function s.efilter1(e,re)
	return re:IsActiveType(TYPE_TRAP) and re:GetHandlerPlayer()~=e:GetHandlerPlayer()
end

function s.efilter2(e,re)
	return re:IsActiveType(TYPE_SPELL) and re:GetHandlerPlayer()~=e:GetHandlerPlayer()
end
--[[
Kitsune Goddess Of Chaos
LIGHT / Fairy / Effect
Level 8 / ATK 2500 / DEF 2000

Effect:
Cannot be Normal Summoned/Set. Must first be Special Summoned (from your hand) by banishing 1 LIGHT and 1 DARK monster from your GY.
"Kitsune Goddess Of Chaos" gains 100 ATK for each LIGHT monster in your banished zone.
Your opponent's monsters lose 100 ATK for each DARK monster in your banished zone.
If this card would be destroyed by battle: You can banish 1 card from your GY; it is not destroyed.
--]]

local s,id=GetID()
function s.initial_effect(c)
	-- Cannot be Normal Summoned/Set
	c:EnableReviveLimit()
	
	-- Special Summon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	
	-- Special Summon procedure
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	
	-- ATK gain effect (LIGHT banished)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	
	-- ATK reduction effect (DARK banished)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetValue(s.atkval2)
	c:RegisterEffect(e4)
	
	-- Battle destruction protection
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTarget(s.reptg)
	e5:SetValue(s.repval)
	e5:SetOperation(s.repop)
	c:RegisterEffect(e5)
end

-- Special Summon condition
function s.spfilter(c,att)
	return c:IsAttribute(att) and c:IsAbleToRemove()
end

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,ATTRIBUTE_LIGHT)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,ATTRIBUTE_DARK)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local g1=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,ATTRIBUTE_LIGHT)
	local g2=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,ATTRIBUTE_DARK)
	g1:Merge(g2)
	
	local g=Group.CreateGroup()
	local tc1=g1:FilterSelect(tp,Card.IsAttribute,1,1,nil,ATTRIBUTE_LIGHT):GetFirst()
	g:AddCard(tc1)
	g1:Remove(Card.IsCode,nil,tc1:GetCode())
	
	local tc2=g1:FilterSelect(tp,Card.IsAttribute,1,1,nil,ATTRIBUTE_DARK):GetFirst()
	g:AddCard(tc2)
	
	if #g==2 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end

function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	g:DeleteGroup()
end

-- ATK gain (LIGHT banished)
function s.atkfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT)
end

function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(s.atkfilter,c:GetControler(),LOCATION_REMOVED,0,nil)*100
end

-- ATK reduction (DARK banished)
function s.atkfilter2(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK)
end

function s.atkval2(e,c)
	return Duel.GetMatchingGroupCount(s.atkfilter2,e:GetHandlerPlayer(),LOCATION_REMOVED,0,nil)*-100
end

-- Battle destruction replacement
function s.repfilter(c,tp)
	return c:IsAbleToRemove() and c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp)
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE) 
		and Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,s.repfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
		e:SetLabelObject(g:GetFirst())
		return true
	end
	return false
end

function s.repval(e,c)
	return c==e:GetHandler()
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end

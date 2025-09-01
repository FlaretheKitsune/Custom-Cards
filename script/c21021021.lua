--[[
Destined HERO - Destined Golem
Fusion/Effect
EARTH/Warrior/Level 6/ATK 2000/DEF 3000
"Elemental HERO Burstinatrix" + "Elemental HERO Clayman"
You can Special Summon this card (from your Extra Deck) by shuffling the above cards you control into the Deck. This card can attack while in face-up Defense Position. If it does, apply its ATK for damage calculation. This card can attack your opponent directly, but if it does using this effect, any battle damage it inflicts to your opponent is halved.
--]]

local s,id=GetID()
function s.initial_effect(c)
	-- Fusion monster
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsCode,58932615,84327329),2)
	
	-- Special Summon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	
	-- Special Summon procedure
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	
	-- Can attack in Defense Position
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DEFENSE_ATTACK)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	
	-- Use ATK for damage calculation when attacking in Defense Position
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DEFENSE_ATTACK)
	e4:SetValue(1)
	e4:SetCondition(s.dacon)
	c:RegisterEffect(e4)
	
	-- Can attack directly, but with halved damage
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_DIRECT_ATTACK)
	e5:SetCondition(s.dacon)
	c:RegisterEffect(e5)
	
	-- Halve battle damage when attacking directly
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e6:SetCondition(s.rdcon)
	e6:SetOperation(s.rdop)
	c:RegisterEffect(e6)
end

-- Check for the correct materials on the field
function s.spfilter(c,tp,fc)
	return c:IsFaceup() and (c:IsCode(58932615) or c:IsCode(84327329)) and c:IsAbleToDeckOrExtraAsCost()
end

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE,0,nil)
	local mat1=g:Filter(Card.IsCode,nil,58932615)
	local mat2=g:Filter(Card.IsCode,nil,84327329)
	return #mat1>0 and #mat2>0 and Duel.GetLocationCountFromEx(tp,tp,g,c)>0
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE,0,nil)
	if #g<2 then return false end
	local mat1=g:Filter(Card.IsCode,nil,58932615)
	local mat2=g:Filter(Card.IsCode,nil,84327329)
	if #mat1==0 or #mat2==0 then return false end
	
	local sg=Group.CreateGroup()
	sg:AddCard(mat1:GetFirst())
	sg:AddCard(mat2:GetFirst())
	
	if #sg>0 then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	end
	return false
end

function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
	g:DeleteGroup()
end

-- Condition for effects that should only apply when attacking in Defense Position
function s.dacon(e)
	return e:GetHandler():IsDefensePos()
end

-- Condition for halving direct attack damage
function s.rdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return ep~=tp and Duel.GetAttackTarget()==nil and c:IsDefensePos()
end

-- Set fixed damage for direct attack
function s.rdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(ep,1200)
end

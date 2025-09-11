--[[
Elemental Tyrant of Inferno – Magma Colossus
FIRE / Rock / Effect
Level 11 / ATK 3800 / DEF 2000

Effect:
Cannot be Normal Summoned/Set. Must be Special Summoned (from your hand) by sending 3 FIRE monsters from your hand/field to the GY. 
Once per turn: You can target 1 face-up monster on the field; equip it to this card (max 3). 
This card gains ATK equal to the combined original ATK of monsters equipped this way.
Once per turn: When this card battles, you can negate the attack and make both players take damage equal to half this card's ATK.
When this card destroys a monster by battle: You can destroy 1 Spell/Trap on the field.
--]]

local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon condition
	c:EnableReviveLimit()
	
	-- Special Summon procedure
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	
	-- Equip effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
	
	-- ATK gain
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	
	-- Battle effect: Negate attack and deal damage
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.negcon)
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4)
	
	-- Destroy Spell/Trap on battle destruction
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_BATTLE_DESTROYING)
	e5:SetCondition(aux.bdocon)
	e5:SetTarget(s.destg)
	e5:SetOperation(s.desop)
	c:RegisterEffect(e5)
end

function s.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToGraveAsCost()
end

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	
	-- Need 3 FIRE monsters
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-3 and #g>=3
end

function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	
	-- Select and send 3 FIRE monsters to GY
	local sg=g:Select(tp,3,3,nil)
	Duel.SendtoGrave(sg,REASON_COST)
end

-- Equip effect functions
function s.eqfilter(c,tp)
	return c:IsFaceup() and c:IsAbleToChangeControler() and not c:IsForbidden()
end

function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.eqfilter(chkc,tp) and chkc~=e:GetHandler() end
	if chk==0 then 
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and
			   Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler(),tp) and
			   e:GetHandler():GetEquipCount() < 3
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler(),tp)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end

function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not (tc and tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	
	if not Duel.Equip(tp,tc,c,false) then return end
	
	-- Equip limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(s.eqlimit)
	tc:RegisterEffect(e1)
end

function s.eqlimit(e,c)
	return e:GetOwner()==c
end

-- ATK gain calculation
function s.atkval(e,c)
	local g=c:GetEquipGroup()
	local atk=0
	for tc in aux.Next(g) do
		local tatk=tc:GetBaseAttack()
		if tatk>0 then atk=atk+tatk end
	end
	return atk
end

-- Battle effect: Negate attack and deal damage
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (Duel.GetAttacker()==c or Duel.GetAttackTarget()==c) and c:GetAttack()>0
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.NegateAttack() then
		local atk=math.ceil(c:GetAttack()/2)
		if atk>0 then
			Duel.Damage(tp,atk,REASON_EFFECT,true)
			Duel.Damage(1-tp,atk,REASON_EFFECT,true)
			Duel.RDComplete()
		end
	end
end

-- Destroy Spell/Trap
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP)
	if #g>0 then
		Duel.HintSelection(g,true)
		Duel.Destroy(g,REASON_EFFECT)
	end
end

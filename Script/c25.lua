--[[
Destined HERO Violent Storm
DARK / Warrior / Fusion / Effect
Level 8 / ATK 2500 / DEF 2000

1 "HERO" monster + 1 DARK monster
Must be Fusion Summoned.
Your opponent's monsters lose 100 ATK for each DARK monster in your GY.
Once per turn, when this card battles an opponent's monster: You can switch the current ATK and DEF of this card and the monster it is battling until the end of the Damage Step.
If this card leaves the field: You can target 1 "HERO" monster and 1 Fusion Spell in your GY; add them to your hand.
--]]

local s,id=GetID()
function s.initial_effect(c)
	-- Fusion Summon requirement
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0x8),aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_DARK))
	
	-- Must be Fusion Summoned
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	
	-- ATK reduction effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	
	-- Switch ATK/DEF during battle
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.switchcon)
	e3:SetOperation(s.switchop)
	c:RegisterEffect(e3)
	
	-- Add HERO and Fusion Spell from GY when leaves field
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_DESTROYED+EVENT_REMOVE)
	e4:SetCondition(s.thcon)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end

-- ATK reduction calculation
function s.atkval(e)
	return Duel.GetMatchingGroupCount(Card.IsAttribute,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil,ATTRIBUTE_DARK)*-100
end

-- Switch ATK/DEF effect
function s.switchcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsControler(1-tp)
end

function s.switchop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if c:IsRelateToBattle() and c:IsFaceup() and bc and bc:IsRelateToBattle() and bc:IsFaceup() then
		-- Switch this card's ATK/DEF
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SWAP_BASE_AD)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		c:RegisterEffect(e1)
		
		-- Switch opponent's monster's ATK/DEF
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SWAP_BASE_AD)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		bc:RegisterEffect(e2)
	end
end

-- Add HERO and Fusion Spell from GY
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_ONFIELD)
end

function s.herofilter(c)
	return c:IsSetCard(0x8) and c:IsMonster() and c:IsAbleToHand(0x46)
end

function s.fusionfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToHand(0x46) and c:ListsArchetypeAsMaterial(0x8)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		return Duel.IsExistingTarget(s.herofilter,tp,LOCATION_GRAVE,0,1,nil)
			and Duel.IsExistingTarget(s.fusionfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g1=Duel.SelectTarget(tp,s.herofilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g2=Duel.SelectTarget(tp,s.fusionfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,2,0,0)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end

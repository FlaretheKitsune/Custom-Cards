--[[
Mokey Mokey Duo
LIGHT / Fairy / Fusion / Level 2 / ATK 600 / DEF 2400
Fusion: 2 "Mokey Mokey" monsters
If this card is Fusion Summoned: You can target 1 "Mokey Mokey" card in your GY, add it to your hand. 
While this card is face-up on the field, your opponent cannot target other "Mokey Mokey" monsters you control with attacks or card effects.
--]]

local s,id=GetID()
function s.initial_effect(c)
	-- Fusion monster
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0x184),2)
	
	-- Add 1 "Mokey Mokey" card from GY to hand when Fusion Summoned
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	
	-- Protection effect for other "Mokey Mokey" monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.tglimit)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end

-- Check if the summon was a Fusion Summon
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

-- Filter for "Mokey Mokey" cards in GY
function s.thfilter(c)
	return (c:IsCode(12482652) or c:IsSetCard(0x184)) and c:IsAbleToHand()
end

-- Target 1 "Mokey Mokey" card in GY to add to hand
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end

-- Add the targeted card to hand
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end

-- Limit protection to other "Mokey Mokey" monsters
function s.tglimit(e,c)
	return c~=e:GetHandler() and (c:IsCode(12482652) or c:IsSetCard(0x184))
end

--Destin HERO – Clay Sentinel
local s,id=GetID()
function s.initial_effect(c)
	--Name is treated as "Elemental HERO Clayman" while on field or in GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetValue(84327329) --Elemental HERO Clayman
	c:RegisterEffect(e1)
	
	--Change to Defense Position and protect Destin HEROes from battle destruction
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.poscon)
	e2:SetCost(s.poscost)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
	
	--Add 1 "Destin HERO" monster from GY to hand when sent to GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end

--Defense Position and protection effect
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and e:GetHandler():IsAttackPos()
end
function s.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanChangePosition() end
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsCanChangePosition() then
		if Duel.ChangePosition(c,POS_FACEUP_DEFENSE)>0 then
			--Monsters with "Destin HERO" or "Destiny HERO" in name cannot be destroyed by battle this turn
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e1:SetTargetRange(LOCATION_MZONE,0)
			e1:SetTarget(s.indtg)
			e1:SetValue(1)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.indtg(e,c)
	if not c:IsFaceup() then return false end
	-- Check if it's a Destiny HERO or Destin HERO by set card
	if c:IsSetCard(0x8) or c:IsSetCard(0xc008) then return true end
	-- Check specific Destin HERO codes
	local name=c:GetCode()
	if name==23232323 or name==24242424 or name==26262626 or name==27272727 then return true end
	-- Check if name contains "Destin HERO" or "Destiny HERO" (for treated names)
	local cardname=c:GetOriginalCode()
	if cardname==20721928 or cardname==21844576 or cardname==58932615 or cardname==84327329 then
		return true
	end
	return false
end

--Add to hand effect
function s.thfilter(c)
	if not (c:IsMonster() and c:IsAbleToHand()) then return false end
	-- Check if it's a Destiny HERO or Destin HERO by set card
	if c:IsSetCard(0x8) or c:IsSetCard(0xc008) then return true end
	-- Check specific Destin HERO codes
	local name=c:GetCode()
	if name==23232323 or name==24242424 or name==26262626 or name==27272727 then return true end
	-- Check if name contains "Destin HERO" or "Destiny HERO" (for treated names)
	local cardname=c:GetOriginalCode()
	if cardname==20721928 or cardname==21844576 or cardname==58932615 or cardname==84327329 then
		return true
	end
	return false
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

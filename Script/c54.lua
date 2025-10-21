--Alpha-Cyber Midnight Dominator
-- Set file name to c<ID>.lua matching the card's ID in your .cdb
local s,id=GetID()
local SET_ALPHACYBER=0x2323
s.listed_series={SET_ALPHACYBER}
s.listed_names={id}

function s.initial_effect(c)
  -- Synchro Summon: 1 "Alpha-Cyber" Tuner + 1+ non-Tuner Machine monsters
  Synchro.AddProcedure(c,s.tuner,1,1,s.nontuner,1,99)
  c:EnableReviveLimit()

  -- Opponent cannot target your non-Synchro "Alpha-Cyber" monsters with card effects
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
  e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
  e1:SetRange(LOCATION_MZONE)
  e1:SetTargetRange(LOCATION_MZONE,0)
  e1:SetTarget(s.prottg)
  e1:SetValue(aux.tgoval)
  c:RegisterEffect(e1)

  -- Tribute 1 "Alpha-Cyber"; gain one of two effects until the end of this turn
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,0))
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetRange(LOCATION_MZONE)
  e2:SetCost(s.gncost)
  e2:SetTarget(s.gntg)
  e2:SetOperation(s.gnop)
  c:RegisterEffect(e2)

  -- If this card leaves the field by your opponent's card effect: SS 1 "Alpha-Cyber" Synchro from GY (except this card)
  local e3=Effect.CreateEffect(c)
  e3:SetDescription(aux.Stringid(id,3))
  e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e3:SetProperty(EFFECT_FLAG_DELAY)
  e3:SetCode(EVENT_LEAVE_FIELD)
  e3:SetCondition(s.spcon)
  e3:SetTarget(s.sptg)
  e3:SetOperation(s.spop)
  c:RegisterEffect(e3)
end

-- Material filters
function s.tuner(c,scard,sumtype,tp)
  return c:IsSetCard(SET_ALPHACYBER,scard,sumtype,tp) and c:IsType(TYPE_TUNER,scard,sumtype,tp)
end
function s.nontuner(c,scard,sumtype,tp)
  return c:IsRace(RACE_MACHINE,scard,sumtype,tp)
end

-- Target protection
function s.prottg(e,c)
  return c:IsSetCard(SET_ALPHACYBER) and not c:IsType(TYPE_SYNCHRO)
end

-- Cost: Tribute 1 "Alpha-Cyber" monster
function s.cfilter(c)
  return c:IsSetCard(SET_ALPHACYBER) and c:IsMonster() and c:IsReleasable()
end
function s.gncost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.CheckReleaseGroup(tp,s.cfilter,1,nil) end
  local g=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil)
  Duel.Release(g,REASON_COST)
end
function s.gntg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
end

-- Gain one chosen effect until the End Phase
function s.gnop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
  Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
  local op=Duel.SelectOption(tp,
	aux.Stringid(id,1), -- Option A
	aux.Stringid(id,2)  -- Option B
  )
  if op==0 then
	-- Option A: At start of the battle, if this card battles an opponent's DARK monster: Banish that monster.
	local eA=Effect.CreateEffect(c)
	eA:SetDescription(aux.Stringid(id,1))
	eA:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	eA:SetCode(EVENT_BATTLE_START) -- more reliable than DAMAGE_STEP_START
	eA:SetRange(LOCATION_MZONE)
	eA:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
	  local c=e:GetHandler()
	  local bc=c:GetBattleTarget()
	  return bc and bc:IsControler(1-tp) and bc:IsAttribute(ATTRIBUTE_DARK)
	end)
	eA:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
	  local c=e:GetHandler()
	  local bc=c:GetBattleTarget()
	  if bc and bc:IsRelateToBattle() then
		Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)
	  end
	end)
	eA:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
	c:RegisterEffect(eA)
  else
	-- Option B: This card cannot be destroyed by Trap effects (until End Phase)
	local eB=Effect.CreateEffect(c)
	eB:SetDescription(aux.Stringid(id,2))
	eB:SetType(EFFECT_TYPE_SINGLE)
	eB:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	eB:SetValue(function(e,re,rp) return re:IsActiveType(TYPE_TRAP) end)
	eB:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
	c:RegisterEffect(eB)
  end
end

-- Leave-field trigger (opponent's card effect)
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  return c:IsPreviousLocation(LOCATION_ONFIELD) and (r&REASON_EFFECT)~=0 and rp==1-tp
end
function s.spfilter(c,e,tp)
  return c:IsSetCard(SET_ALPHACYBER) and c:IsType(TYPE_SYNCHRO) and not c:IsCode(id)
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	  and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
  end
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
  if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
  local tc=g:GetFirst()
  if tc then
	Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
  end
end
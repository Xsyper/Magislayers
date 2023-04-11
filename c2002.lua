--Magislayer Sorceress - Ren Koumei
--Created and Scripted by Xsyper
local s,id=GetID()
function s.initial_effect(c)
	--fusion summon
c:EnableReviveLimit()
Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0x0309),2)
c:SetSPSummonOnce(id)
--must fusion summon
local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	--Special Summon by S/T
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
  --Switch with the extra
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.spcost1)
	e3:SetTarget(s.sptg1)
	e3:SetOperation(s.spop1)
	c:RegisterEffect(e3)
  --set
local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
--	e4:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	--e4:SetCost(s.retcost) 
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetTarget(s.target)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)
end
--fusion
s.listed_series={0x0309}
s.material_setcode=0x0309
function s.sfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x0309)
end
--uncompleted
function s.spfilter(c)
	return c:IsSpell() or c:IsTrap() and c:IsAbleToGraveAsCost()
end
function s.exfilter(c)
	return s.spfilter(c) or (c:IsFacedown() and c:IsSpell() or c:IsTrap() and c:IsAbleToGraveAsCost())
end
function s.spcon(e,c)
	if c==nil then return true end
local tp=c:GetControler()
	local g=nil
	if Duel.IsPlayerAffectedByEffect(tp,54828837) then
		g=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_ONFIELD,0,nil)
	else
		g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_ONFIELD,0,nil)
	end
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2 and #g>1 and aux.SelectUnselectGroup(g,e,tp,2,2,aux.ChkfMMZ(1),0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local g=nil
	if Duel.IsPlayerAffectedByEffect(tp,54828837) then
		g=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_ONFIELD,0,nil)
	else
		g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_ONFIELD,0,nil)
	end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.ChkfMMZ(1),1,tp,HINTMSG_TOGRAVE,nil,nil,true)
	local dg=sg:Filter(Card.IsFacedown,nil)
	if #dg>0 then
		Duel.ConfirmCards(1-tp,dg)
	end
	if #sg==2 then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoGrave(g,REASON_COST)
	g:DeleteGroup()
end
--Switch
  s.listed_series={0x0309}
function s.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtraAsCost() end
	Duel.Sendto(c,LOCATION_EXTRA,REASON_COST,POS_FACEDOWN,0,0)
end
function s.spfilter1(c,e,tp)
	return c:IsSetCard(0x0309) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and not c:IsType(TYPE_FUSION)
		and Duel.GetLocationCountFromEx(tp,tp,e:GetHandler(),c,c:IsType(TYPE_LINK),0x0309)>0--0x0309 was 0x60
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)--0x0309 was 0x60
	end
end
--set
--function s.tgfilter(c,tp)
	--return c:IsSetCard(0x03db) or c:IsSetCard(0x0381) and c:IsAbleToGrave() and c:IsSpellTrap()
--end
function s.setfilter(c,tp)
	return c:IsSetCard(0x03db) or c:IsSetCard(0x0381) and c:IsSpellTrap() and c:IsSSetable()
end
--function s.costfilter(c,tp)
	--return c:IsSetCard(0x0381) or c:SetCard(0x03db) and c:IsSpellTrap() and c:IsAbleToGraveAsCost()
--end
--function s.retcost(e,tp,eg,ep,ev,re,r,rp,chk)
--	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,2,nil) end
	---Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	--local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
--	Duel.SendtoGrave(g,REASON_COST)
--end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
        --Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetTargetPlayer(tp)
    --Duel.SetTargetParam(1)
    --Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp,chk)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,2,nil)
    if #g>0 then
        Duel.SSet(tp,g)
        Duel.ShuffleDeck(tp)
        --Duel.Draw(p,d,REASON_EFFECT)
    end
end
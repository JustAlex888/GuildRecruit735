-- Actual private control callbacks against explicit WoW API test doubles.
return function(A,frames,ok)
    local U=A.ui
    ok(U.list.resizable==true and U.candidateResize~=nil,"candidate window has real resize affordance")
    A.scan.records=nil
    local saved=A.candidates
    local function fill(count)
        A.candidates={}
        for i=1,count do
            A.candidates[i]={name="Candidate"..i,level=40,race="Human",class="Warrior",classFile="WARRIOR",hc="UNKNOWN"}
        end
        A:UpdateCandidates()
    end
    fill(30);U.list:Show()
    ok(U.candidateScrollMax>0,"long candidate list overflows viewport")
    ok(U.candidateUp.disabled and not U.candidateDown.disabled,"initial arrow states reflect top of overflow")
    local function click(b) if not b.disabled then b.scripts.OnClick(b,"LeftButton") end end
    click(U.candidateDown)
    ok(U.scroll:GetVerticalScroll()==36 and U.candidateBar:GetValue()==36,"actual down arrow moves viewport and thumb together")
    click(U.candidateUp)
    ok(U.scroll:GetVerticalScroll()==0 and U.candidateUp.disabled,"up arrow returns to top")
    U.scroll.scripts.OnMouseWheel(U.scroll,-1)
    ok(U.scroll:GetVerticalScroll()==36,"wheel over viewport scrolls down")
    U.rows[2].scripts.OnMouseWheel(U.rows[2],-1)
    ok(U.scroll:GetVerticalScroll()==72,"wheel over clickable candidate row scrolls")
    U.rowsParent.scripts.OnMouseWheel(U.rowsParent,1)
    ok(U.scroll:GetVerticalScroll()==36,"wheel over list content scrolls up")
    U.list.scripts.OnMouseWheel(U.list,-1)
    ok(U.scroll:GetVerticalScroll()==72,"wheel over window also scrolls")
    U.candidateBar:SetValue(U.candidateScrollMax)
    ok(U.scroll:GetVerticalScroll()==U.candidateScrollMax,"dragging thumb reaches bottom")
    ok(U.candidateDown.disabled and not U.candidateUp.disabled,"bottom arrow state is correct")
    local last=U.rows[30]
    local lastBottom=-(last.point[5] or 0)+last:GetHeight()
    ok(lastBottom<=U.scroll:GetVerticalScroll()+U.scroll:GetHeight(),"last displayed candidate is reachable")
    for i=1,100 do A:ScrollCandidatesBy(1) end
    ok(U.scroll:GetVerticalScroll()==U.candidateScrollMax,"repeated down clamps at bottom")
    for i=1,100 do A:ScrollCandidatesBy(-1) end
    ok(U.scroll:GetVerticalScroll()==0,"repeated up clamps at top")
    U.candidateBar:SetValue(80)
    local offset=U.scroll:GetVerticalScroll()
    A:RefreshUI()
    ok(U.scroll:GetVerticalScroll()==offset,"scanner refresh keeps valid scroll position")
    local w,h=U.list:GetWidth(),U.list:GetHeight()
    U.candidateResize.scripts.OnMouseDown(U.candidateResize,"LeftButton")
    ok(U.list.sizing=="BOTTOMRIGHT" and U.candidateResizing,"grip starts native bottom-right resize")
    U.list:SetSize(w+120,h+90)
    U.candidateResize.scripts.OnMouseUp(U.candidateResize,"LeftButton")
    ok(not U.candidateResizing and not U.list.sizing,"grip release ends resize")
    ok(U.list:GetWidth()==w+120 and U.list:GetHeight()==h+90,"user-selected window dimensions retained")
    ok(U.scroll:GetWidth()==U.list:GetWidth()-62,"viewport grows with window")
    ok(U.rows[1]:GetWidth()==U.scroll:GetWidth()-10,"candidate rows follow viewport width")
    A:RefreshUI()
    ok(U.list:GetWidth()==w+120 and U.list:GetHeight()==h+90,"normal refresh does not replace user dimensions")
    U.list:Hide();U.list:Show();A:UpdateCandidates()
    ok(U.list:GetWidth()==w+120 and U.list:GetHeight()==h+90,"hide/reopen does not reset size")
    U.candidateResize.scripts.OnMouseDown(U.candidateResize,"LeftButton")
    U.list:Hide()
    ok(not U.candidateResizing and not U.list.sizing,"closing during resize releases mouse operation")
    U.list:Show()
    U.list:SetSize(420,240);fill(30)
    ok(U.candidateScrollMax>0 and U.scroll:GetHeight()>=40,"minimum window preserves scrolling")
    U.candidateBar:SetValue(U.candidateScrollMax)
    ok(U.rows[30].person==A.candidates[30],"scroll does not change manual action identity")
    local beforeScan,profile=A.scan,A:Profile()
    fill(1)
    ok(U.scroll:GetVerticalScroll()==0 and U.candidateUp.disabled and U.candidateDown.disabled,"shorter content clamps old bottom and disables arrows")
    fill(0)
    ok(U.candidateScrollMax==0 and U.candidateBar.disabled,"empty list has no bogus scroll range")
    ok(A.scan==beforeScan and A:Profile()==profile,"view operations preserve scanner and profile identity")
    U.list:SetSize(608,420);A.candidates=saved;A:UpdateCandidates()
    print("GR735 candidate controls PASS")
end

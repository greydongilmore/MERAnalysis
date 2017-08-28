D = New;
DD = NewFirst;
cnt = 1;

for isubj = length(DD)+1:length(DD)+1+length(D)
    DD(isubj) = D(cell2mat({D.SN})==D(cnt).SN);
    cnt = cnt+1;
end
New = [];
New = DD;
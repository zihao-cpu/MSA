function plotSV (Bset, calib, fdr_flag, large_only_flag, alpha, RegionNames)

[SV, SVci0, SVci, pval, Z, aver] = StatInference(Bset,calib);
SVsd_pos = SVci - SV;
SVsd_neg = SV - SVci0;    
AsteriskFact = 1.2;
Nreg = length(SV);

hiLim = SVci;
loLim = SVci0;
for j=1:Nreg
    if loLim(j) > -0.5
        loLim(j) = -0.5; 
    end
end

Nreg = length(SV);
LW = 1;
xvec = 1:Nreg;
ast_hi = ones(1,Nreg).*NaN;  
ast_lo = ones(1,Nreg).*NaN;
bigsv = ones(1,Nreg).*NaN;
smallsv = ones(1,Nreg).*NaN;
FDRpval = mafdr(pval,'BHFDR',true);


use_pv2 = ones(1,Nreg);
switch fdr_flag
    case 1 %FDR-corredted p-value
        use_pv = FDRpval;
    case 0 %uncorrected p-value
        use_pv = pval;
    case 2 %show both corrected and un-corrected
        use_pv = FDRpval;
        use_pv2 = pval;
end
ast_hi(use_pv<alpha)=(hiLim(use_pv<alpha))*AsteriskFact;
ast_lo(use_pv<alpha)=(loLim(use_pv<alpha))*AsteriskFact*1.5;
bigsv(Z>0) = 1;
smallsv(Z<0) = 1;
circles = ones(1,Nreg)*NaN;
circles(use_pv2<alpha & bigsv == 1)= (hiLim(use_pv2<alpha & bigsv == 1))*AsteriskFact; %circles are used to denote uncorrected p < 0.05
circles(use_pv<alpha & bigsv ==1) = NaN; %avoid showing dobule marking on the same region
circles = circles .* bigsv;
if ~large_only_flag
   ast_lo = ast_lo.*smallsv;
   ast_hi = ast_hi.*bigsv;
else
    ast_hi = ast_hi.*bigsv;
    ast_lo = ones(1,Nreg)*NaN;
end


h=line([0 Nreg+1],[0 0],'LineStyle',':','Color',[0.5 0.5 0.5],'LineWidth',LW);
aa = h.Parent;
hold on
%bar (SV,'FaceColor',[68/256, 114/256, 196/256],'LineWidth',LW);
plot (SV,'Color',[68/256, 114/256, 196/256],'LineWidth',LW);
errorbar (xvec,SV,SVsd_pos,SVsd_neg,'k','LineWidth',LW,'LineStyle','none');               
%a = h.Parent;        
plot (xvec,ast_hi,'LineStyle','none','Marker','*','MarkerSize',12,'MarkerEdgeColor','k'); 
plot (xvec,ast_lo,'LineStyle','none','Marker','*','MarkerSize',12,'MarkerEdgeColor','r');
plot (xvec,circles,'LineStyle','none','Marker','o','MarkerSize',10,'MarkerEdgeColor','k');
yvec = aver.*ones(1,Nreg);
plot ([-1, Nreg+1],ones(1,2).* yvec(1),'k','LineWidth',LW,'LineStyle','--');
%disp (sprintf('Calibrated mean SV=%1.3f',yvec(1)));
aa.LineWidth = LW * 1.25;
aa.XLim= [0 Nreg+1];  
aa.XTick = 1:26;
aa.XTickLabel = RegionNames;
aa.XTickLabelRotation = 90;
end

function [SV, SVci0, SVci1, pval, Z, aver] = StatInference (BLset,calib)

    x = BLset{end};
    if isfield(x,'LOO')
        %Leave-one-out
        if calib
            SVci0 = x.CIcalib(:,1);
            SVci1 = x.CIcalib(:,3);
            SV = x.CIcalib(:,2);
        else
            SVci0 = x.CI(:,1);
            SVci1 = x.CI(:,3);
            SV = x.CI(:,2);
        end
        pval = x.pvalest;
        Z = x.Zscoreest;
    else
        %Bootstrap
        if calib
            SVci0 = x.CIcalibmixSHAPL(:,1);
            SVci1 = x.CIcalibmixSHAPL(:,3);
            SV = x.CIcalibmixSHAPL(:,2);
        else
            SVci0 = x.CImix(:,1);
            SVci1 = x.CImix(:,3);
            SV = x.CImix(:,2);
        end   
        pval = x.pvalestmix;
        Z = x.Zscoreestmix;
    end
    
    %The calibrated SVs are normalized by default, but the raw are not.
    %Here we normlize the raw SVs to 100.
    if ~calib
        sumSV = sum(SV);
        SV = 100 * SV ./ sumSV;
        SVci0 = 100 * SVci0 ./ sumSV;
        SVci1 = 100 * SVci1 ./ sumSV;
    end
    aver = sum(SV)/length(SV); 
end
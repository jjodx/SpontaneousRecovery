function Sresults = stat2text(x,y)
% function that translates statistical results into text
% parametric test
[~,p,~,stat] = ttest2(x,y,"Vartype","unequal");
effect = meanEffectSize(x,y,Paired=false,Effect="robustcohen",VarianceType="unequal",ConfidenceIntervalType="bootstrap",BootstrapOptions=statset(UseParallel=true),NumBootstraps=5000);
txtstat_param=['t(' num2str(stat.df, '%.2f') ')= ' num2str(stat.tstat, '%.3f') ', p=' num2str(p, '%.4f')];
txtstat_param = [txtstat_param,[', d_robust = ' num2str(effect.Effect, '%.3f') ' CI=[ ' num2str(effect.ConfidenceIntervals(1), '%.2f') ',' num2str(effect.ConfidenceIntervals(2), '%.2f') ']' ]];
% non-parametric test
[pz,~,statz] = ranksum(x,y); 
txtstat_nonparam=['Z= ' num2str(statz.zval, '%.3f') ', p=' num2str(pz, '%.4f')];
Sresults = {txtstat_param;txtstat_nonparam};

function BarPlotJJ(x1,x2,strtitle,strsubtitle,stry,ylimval)
Colors = [[86,180,233] ; [230,159,0]]./255;
G(1).var=x1;
G(2).var=x2;
hold on
for sk=1:length(G)
    data = G(sk).var(:);
    bar(sk,mean(data,"omitnan"),'BarWidth',0.8,'FaceColor',[1 1 1],'EdgeColor',[0 0 0])
    SEM = std(data,"omitnan")/sqrt(length(data));
    plot(sk.*ones(length(data))+(-0.1+(0.3+0.1).*rand(length(data),1)),data,'o','MarkerFaceColor',Colors(sk,:),'MarkerEdgeColor','none')
    errorbar(sk-0.2,(mean(data,"omitnan")),SEM,'k')   
end
ylabel(stry);
xticks([1 2])
xticklabels({'Young','Older'})
ylim(ylimval)
title({strtitle;strsubtitle})
subtitle(stat2text(G(1).var,G(2).var))

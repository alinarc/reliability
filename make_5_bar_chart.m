function f = make_5_bar_chart(X, P, mus, bal_type)

X1 = X{1}; P1 = P{1};
X2 = X{2}; P2 = P{2};
X3 = X{3}; P3 = P{3};
X4 = X{4}; P4 = P{4};
X5 = X{5}; P5 = P{5};


switch bal_type
    case 1
        figTitle = "Available capacity PMFs for layouts with passive balancing";
        fileName = 'PBhistos.png';
    case 2
        figTitle = "Available capacity PMFs for layouts with active balancing, half bridges";
        fileName = 'HBhistos.png';
    case 3
        figTitle = "Available capacity PMFs for layouts with active balancing, full bridges";
        fileName = 'FBhistos.png';
end

f = figure;
f.Position = [1633 127 872 833];
subplot(3,4,[1 2])
bar(X1, P1)
ylim([0 0.35])
title('ESS layout #1: conventional pack, AC-coupled, LF xfmr');
xline(mus(1), 'Color','#A2142F', 'Label',sprintf(' μ = %0.2f kWh', mus(1)),'LineWidth', 1.5, 'LabelOrientation', 'horizontal','LabelHorizontalAlignment', 'left')
xlabel('System available capacity (kWh)')

subplot(3,4,[3 4])
bar(X2, P2)
ylim([0 0.35])
title('ESS layout #2: conventional pack, AC-coupled, HF xfmr');
xline(mus(2), 'Color','#A2142F', 'Label',sprintf('μ = %0.2f kWh', mus(2)),'LineWidth', 1.5, 'LabelOrientation', 'horizontal','LabelHorizontalAlignment', 'left')
xlabel('System available capacity (kWh)')

subplot(3,4,[5 6])
bar(X3, P3)
ylim([0 max(P3)+max(P3)/10])
title('ESS layout #3: conventional pack, DC-coupled');
xline(mus(3), 'Color','#A2142F', 'Label',sprintf('μ = %0.2f kWh', mus(3)),'LineWidth', 1.5, 'LabelOrientation', 'horizontal', 'LabelHorizontalAlignment', 'left')
xlabel('System available capacity (kWh)')

subplot(3,4,[7 8])
bar(X4, P4)
ylim([0 max(P4)+max(P4)/10])
title('ESS layout #4: modular pack, AC-coupled');
xline(mus(4), 'Color','#A2142F', 'Label',sprintf('μ = %0.2f kWh', mus(4)),'LineWidth', 1.5, 'LabelOrientation', 'horizontal', 'LabelHorizontalAlignment', 'left')
xlabel('System available capacity (kWh)')

subplot(3,4,[10 11])
bar(X5, P5)
% xlim([min(X5(P5>1e-10)) inf])
title('ESS layout #5: modular pack, DC-coupled');
xline(mus(5), 'Color','#A2142F', 'Label',sprintf('μ = %0.2f kWh', mus(5)),'LineWidth', 1.5, 'LabelOrientation', 'horizontal', 'LabelHorizontalAlignment', 'left')
xlabel('System available capacity (kWh)')

sgtitle(figTitle)
saveas(f, fileName)


end
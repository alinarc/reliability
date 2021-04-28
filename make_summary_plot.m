function f = make_summary_plot(mus, sigmas, type, balType)
% Summarize 5 layouts with 3 variations each based on their mean and std
% devs. Type indicates what we're comparing: 1 = balancing type, 2 = cell
% chemistry.
f = figure;
b = bar(mus);
grid on
hold on
[ngroups, nbars] = size(mus);
x = nan(nbars, ngroups);
for i = 1:nbars
    x(i,:) = b(i).XEndPoints;
end

errorbar(x', mus, sigmas, 'k', 'linestyle', 'none')

ylim([0 max(mus+sigmas,[],'all')+max(mus+sigmas,[],'all')/50]);
ylabel('Expected Output (kWh)')

switch type
    case 1
        set(gca, 'xticklabel', {'Layout 1'; 'Layout 2'; 'Layout 3'; 'Layout 4'; 'Layout 5'})
        title('Expected available capacity for 5 layouts, considering balancing type')
        legend('PB', 'AB-HB', 'AB-FB', 'Location', 'southoutside', 'orientation', 'horizontal')
        saveas(f, 'compare_all_bal.png')
    case 2
        set(gca, 'xticklabel', {'Layout 1'; 'Layout 2'; 'Layout 3'; 'Layout 4'; 'Layout 5'})
        legend('K2 LFP/Graphite', 'LMO/LTO', 'LFP/LTO', 'Location', 'southoutside', 'orientation', 'horizontal')
        switch balType
            case 1
                title('Expected available capacity for 5 layouts, considering cell chemistry (Passive balancing)')
                saveas(f, 'compare_all_chem_PB.png')
            case 2
                title('Expected available capacity for 5 layouts, considering cell chemistry (Active balancing-half bridge)')
                saveas(f, 'compare_all_chem_HB.png')
            case 3
                title('Expected available capacity for 5 layouts, considering cell chemistry (Active balancing-full bridges)')
                 saveas(f, 'compare_all_chem_FB.png')
        end
    case 3 
        set(gca, 'xticklabel', {'Layout 1 (ref)'; 'Layout 3: 1S'; 'Layout 3: 2S'; 'Layout 3: 3S'; 'Layout 3: 15S'})
        title('Expected available capacity considering modules in series strings')
        legend('PB', 'AB-HB', 'AB-FB', 'Location', 'southoutside', 'orientation', 'horizontal')
        saveas(f, 'compare_all_modules_series.png')
end
% 
% mus = reshape(mus', [ngroups*nbars 1]);
% x = reshape(x, size(mus));
%  for j = 1:numel(mus)
%      text(x(j), mus(j), num2str(mus(j), '%0.0f'), 'HorizontalAlignment', 'left', ...
%          'VerticalAlignment', 'bottom');
%  end
 end


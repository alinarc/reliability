function f = make_summary_plot(mus, sigmas)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

f = figure;
b = bar(mus)
hold on
[ngroups, nbars] = size(mus);
x = nan(nbars, ngroups);
for i = 1:nbars
    x(i,:) = b(i).XEndPoints;
end

errorbar(x', mus, sigmas, 'k', 'linestyle', 'none')
set(gca, 'xticklabel', {'Layout 1'; 'Layout 2'; 'Layout 3'; 'Layout 4'; 'Layout 5'})
ylim([0 max(mus+sigmas,[],'all')+10]);
ylabel('Expected Output (kWh)')
legend('PB', 'AB-HB', 'AB-FB', 'Location', 'southoutside', 'orientation', 'horizontal')
saveas(f, 'compare_all.png')
% 
% mus = reshape(mus', [ngroups*nbars 1]);
% x = reshape(x, size(mus));
%  for j = 1:numel(mus)
%      text(x(j), mus(j), num2str(mus(j), '%0.0f'), 'HorizontalAlignment', 'left', ...
%          'VerticalAlignment', 'bottom');
%  end
 end


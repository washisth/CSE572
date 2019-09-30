% files = dir('./DataFolder/*.csv'); 
% n=length(files);
%cgmData=[];
%cgmTime=[];
%cgmDataPrefix='CGMSeriesLunchPat';
%cgmTimePrefix='CGMDatenumLunchPat';
opts = detectImportOptions(strcat('./DataFolder/CGMSeriesLunchPat2.csv'));
opts.SelectedVariableNames = (1:30);
lunch=fliplr(readmatrix(strcat('./DataFolder/CGMSeriesLunchPat2.csv'),opts));


opts = detectImportOptions(strcat('./DataFolder/CGMDatenumLunchPat2.csv'));
opts.SelectedVariableNames = (1:30);
date=fliplr(readmatrix(strcat('./DataFolder/CGMDatenumLunchPat2.csv'),opts));

date(sum(isnan(lunch), 2) == 30, :) = [];
lunch(sum(isnan(lunch), 2) == 30, :) = [];
lunch=fillmissing(lunch,'movmedian',3);

lunch=transpose(lunch);
date=transpose(date);

%cgmData = [cgmData, lunch];
%cgmTime = [cgmTime, date];

m = [mean(lunch); var(lunch); std(lunch); max(lunch); fft(lunch)];
m = transpose(m);
[V,U] = pca(m);
r=V(:,1:5);
d_r=m*r;
%d_r=d_r(:,1:5);

arr = zeros(37,1); % to initialize array
count = 1;  
for i=1:37  
    arr(i) = count;  
    count = count+1;    
end
plot(arr,d_r);
%for i=1:5
%    figure(i)
%    plot(arr,d_r(:,i));
%end


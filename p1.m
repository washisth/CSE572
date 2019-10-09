path = "./DataFolder/";
csv = '4.csv';
%Read CGM Data
opts = detectImportOptions(strcat(path,'CGMSeriesLunchPat',csv));
opts.SelectedVariableNames = (1:30);
cgm_y_matrix=fliplr(readmatrix(strcat(path,'CGMSeriesLunchPat',csv),opts));

%Read CGM Time
opts = detectImportOptions(strcat(path,'CGMDatenumLunchPat',csv));
opts.SelectedVariableNames = (1:30);
cgm_x_matrix=fliplr(readmatrix(strcat(path,'CGMDatenumLunchPat',csv),opts));

%Read Insulin Data
opts = detectImportOptions(strcat(path,'InsulinBolusLunchPat',csv));
opts.SelectedVariableNames = (1:30);
insulin_matrix=fliplr(readmatrix(strcat(path,'InsulinBolusLunchPat',csv),opts)); 

%Read Insulin Time
opts = detectImportOptions(strcat(path,'InsulinDatenumLunchPat',csv));
opts.SelectedVariableNames = (1:30);
insulin_datenum_matrix=fliplr(readmatrix(strcat(path,'InsulinDatenumLunchPat',csv),opts));

%Discard rows with no values
insulin_datenum_matrix(sum(isnan(cgm_y_matrix), 2) == 30, :) = [];
insulin_matrix(sum(isnan(cgm_y_matrix), 2) == 30, :) = [];
cgm_x_matrix(sum(isnan(cgm_y_matrix), 2) == 30, :) = [];
cgm_y_matrix(sum(isnan(cgm_y_matrix), 2) == 30, :) = [];

%Replace empty cells with 0s
insulin_matrix(isnan(insulin_matrix))=0;

%Fill missing data
cgm_x_matrix = transpose(cgm_x_matrix);
cgm_y_matrix = transpose(cgm_y_matrix);
insulin_datenum_matrix = transpose(insulin_datenum_matrix);

cgm_x_matrix = fillmissing(cgm_x_matrix,'linear');
cgm_y_matrix = fillmissing(cgm_y_matrix,'linear');
insulin_datenum_matrix = fillmissing(insulin_datenum_matrix,'linear');

cgm_x_matrix = transpose(cgm_x_matrix);
cgm_y_matrix = transpose(cgm_y_matrix);
insulin_datenum_matrix = transpose(insulin_datenum_matrix);

%Initializations
final = double.empty();
no_of_rows = size(cgm_y_matrix, 1);

%Loop through all days
 for i = 1:no_of_rows
    % Extract each row
    rv_x = cgm_x_matrix(i,:);
    rv_y = cgm_y_matrix(i,:);
    insulin_row = insulin_matrix(i,:);
    insulin_datenum_row = insulin_datenum_matrix(i,:);
    
    %Feature 1
    window = 3;
    diff_val = 0;
    arr_length = length(rv_y);
    plot_x = (arr_length:-1:1);
    distance = double.empty();
    for pos = 2:arr_length
        diff_val = diff_val + abs(rv_y(pos)-rv_y(pos-1));
        if mod(pos,window)==0
            if pos == window
                distance = diff_val;
            else
                distance = horzcat(distance, diff_val);
            end
            diff_val = 0;
        end
    end
    
    %Feature 2
    cov1 = std(rv_y(:,1:3))/mean(rv_y(:,1:3));
    cov2 = std(rv_y(:,3:6))/mean(rv_y(:,3:6));
    cov3 = std(rv_y(:,6:9))/mean(rv_y(:,6:9));
    cov4 = std(rv_y(:,9:12))/mean(rv_y(:,9:12));
    cov5 = std(rv_y(:,12:15))/mean(rv_y(:,12:15));
    cov6 = std(rv_y(:,15:18))/mean(rv_y(:,15:18));
    cov7 = std(rv_y(:,18:21))/mean(rv_y(:,18:21));
    cov8 = std(rv_y(:,21:24))/mean(rv_y(:,21:24));
    cov9 = std(rv_y(:,24:27))/mean(rv_y(:,24:27));
    cov10 = std(rv_y(:,27:30))/mean(rv_y(:,27:30));
    cov = [ cov1, cov2, cov3, cov4, cov5, cov6, cov7, cov8, cov9, cov10];
    
    %Feature 3
    polycoeff = polyfit(0.0035*(1:1:size(rv_y,2)),rv_y,5);
    
    %Feature 4
    [val, col] = max(rv_y);
    timeCGM = rv_x(col);
    [val, col] = max(insulin_row);
    timeMeal = insulin_datenum_row(col);
    timeMaxExc = timeCGM - timeMeal;
    
    %Create feature matrix
    row_final = horzcat(distance, cov, polycoeff, timeMaxExc);
    tempt = isempty(final);
    if tempt == 1
        final = row_final;
    else
        final = vertcat(final,row_final);
    end 
    
 end
 
 %Normalize features
 z_score_matrix = [zscore(final);];
 
 %PCA
 [coeff,score,latent,~,explained] = pca(z_score_matrix);
 dataInPrincipalComponentSpace = z_score_matrix*coeff;
 
 %Best 5 features
 days = (1:no_of_rows);
 result_5_matrix = dataInPrincipalComponentSpace(:,1:5);
 plot(days,result_5_matrix);


output_folder = '~/.gazebo/gazebo_models/hammering_nail/';
output_file = 'output_calibration.txt';
output_path = [output_folder output_file];
n_dims = 1;
n_samples = 10;
plot_fig = 1;
sampling = 'star';
save_results = 1;


% defines how close one real number needs to be from another to declare them "equal"
mode_epsilon = 0.0001; % in meters

% Open files
fid_output = fopen(output_path);
if fid_output == -1
    error(['Could not open file ' output_path]);
end

% n_trials = 0;
% while ~feof(fid_output)
%     line = fgetl(fid_output);
%     if strcmp(line,'end_trial')
%         n_trials = n_trials + 1;
%     end
% end

% read number of trials from the first line in the output file
n_trials = str2num(fgetl(fid_output));

pancake_min_score = 0.05;
output = [];
all_nums = [];
all_sums_nums = [];
while ~feof(fid_output)
    line = fgetl(fid_output);
    if strcmp(line,'start_trial')
        line = fgetl(fid_output);
        curr_trial = 0;
        while ~strcmp(line,'end_trial') && ~feof(fid_output)   
            line_split = strsplit(line);
            if size(line_split,2) > 1  
                sum_nums = 0;
                line_num = 1;
                for j=1:size(line_split,2)
                    %str2double(line_split{j});
                    curr_line_num = str2double(line_split{j});
                    if curr_line_num < pancake_min_score
                        line_num = line_num + 1;
                    end

%                     line_num = line_num + str2double(line_num);
%                       all_nums = [all_nums; line_num];
%                       sum_nums = sum_nums + line_num;
                end
                all_sums_nums = [all_sums_nums; sum_nums];
            else
                line_num = str2double(line);
            end            
            if ~isempty(line_num) || line_num < 0
                curr_trial = curr_trial + 1;
                output(end+1) = line_num;
            end
            line = fgetl(fid_output);
        end
        while curr_trial < n_trials
            output(end+1) = NaN;
            curr_trial = curr_trial +1;
        end
    end 
end

output = output';
n_failed_simulations = size(output(output<-.99),1);
perc_failed_simulations = n_failed_simulations/size(output,1);
if n_failed_simulations > 0
    [~,b] = min(output);
    disp([num2str(n_failed_simulations) ' (' num2str(perc_failed_simulations*100) ' %) simulations failed (e.g. simulation #' num2str(b) ')']);
else
    disp('No failed simulations');
end

if mod(size(output,1),n_trials)
    error('Number of outputs is not a multiple of the number of trials');
end

output = reshape(output,n_trials,size(output,1)/n_trials)';
sum_ = sum(output,2);

medians = zeros(size(output,1),1);
for i=1:size(output,1)
    medians(i) = median(output(i,~isnan(output(i,:))));
end

tryouts = {};
for i=1:size(output,1)
    tryouts{end+1} = [ output(i,1) 1];
    for j=2:n_trials
        found_tryout = 0;
        for k=1:size(tryouts{i},1)
            if abs(output(i,j) - tryouts{i}(k,1)) < mode_epsilon 
                tryouts{i}(k,1) = (output(i,j) + tryouts{i}(k,1))/2;
                tryouts{i}(k,2) = tryouts{i} (k,2) + 1;
                found_tryout = 1;
                break
            end
        end
        if ~found_tryout
            tryouts{i} (end+1,1) = output(i,j);
            tryouts{i} (end,2) = 1;
        end
    end    
end

modes = zeros(size(output,1),1);
for i=1:size(tryouts,2)
    [~,ixs_mode] = sort(tryouts{i}(:,1),'descend');
    tryouts{i} = tryouts{i}(ixs_mode,:);
    [~,ixs_mode] = sort(tryouts{i}(:,2),'descend');
    modes(i) = tryouts{i}(ixs_mode(1),1);
end

modes(modes<0) = 0;
medians(medians<0) = 0;

modes(isnan(modes)) = 0;
medians(isnan(medians)) = 0;

output(isnan(output)) = 0;
output(output<0) = 0;

if plot_fig
    switch sampling
        case 'star'
            elems_per_dim = size(output,1)/n_dims;
            for i=0:n_dims-1
                stds=[];    
                range_curr = (i*elems_per_dim)+1:(i+1)*elems_per_dim;
                stds = zeros(elems_per_dim,1);
                ix=1;
                for j = range_curr
                    stds(ix) = std(output(j,:));
                    ix=ix+1;
                end
                medians_curr = medians(range_curr);
                modes_curr = modes(range_curr);
                errors=stds/2;
                figure; hold on; title(strcat('Medians | Dim: ',num2str(i+1)));
                shadedErrorBar(1:elems_per_dim,medians_curr,errors,'-b',1);
                hold on; axis([1,size(medians_curr,1),0,0.05]); hold off;
                % figure; hold on; title(strcat('Modes | Dim: ',num2str(i+1)));
                %shadedErrorBar(1:elems_per_dim,modes_curr,errors,'-r',1);
                %hold on; axis([1,size(modes_curr,1),0,0.05]); hold off;
            end
        case 'cross'
            elems_per_dim = nthroot(size(output,1),n_dims);
            if elems_per_dim ~= round(elems_per_dim)
                for i=size(output,1)+1:n_samples
                   medians(end+1) = 0;
                end
                elems_per_dim = nthroot(n_samples,n_dims);
            end
            surf(0:9,0:9,reshape(medians,elems_per_dim,elems_per_dim));
            X=zeros(n_samples,1);
            for i=1:size(X,1)
               X(i) = ceil(i/10)-1;
            end
            Y = repmat(0:9,1,10)';
%             figure; scatter3(X,Y,medians,1000,'.k'); 
    end
end

if save_results
    %aux = [X Y];
    %save(strcat(output_path,'medians_input.dat'),'aux','-ascii');
    save(strcat(output_folder,'medians_output.dat'),'medians','-ascii');    
    %save(strcat(output_path,'modes_input.dat'),'aux','-ascii');
    save(strcat(output_folder,'modes_output.dat'),'modes','-ascii'); 
    %save(strcat(output_path,'std_devs.dat'),'stds','-ascii');
end

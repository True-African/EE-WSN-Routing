function out_dir = create_results_folder(run_label)
%CREATE_RESULTS_FOLDER Create a timestamped subfolder under results.

if ~exist('results', 'dir')
    mkdir('results');
end

stamp = char(datetime('now', 'Format', 'yyyyMMdd_HHmmss'));
safe_label = regexprep(run_label, '[^A-Za-z0-9_~-]', '_');
out_dir = fullfile('results', sprintf('%s_%s', safe_label, stamp));

suffix = 1;
base_dir = out_dir;
while exist(out_dir, 'dir')
    out_dir = sprintf('%s_%02d', base_dir, suffix);
    suffix = suffix + 1;
end

mkdir(out_dir);
end

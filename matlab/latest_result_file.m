function file_path = latest_result_file(folder_pattern, file_name)
%LATEST_RESULT_FILE Find newest matching result file under results.

files = dir(fullfile('results', folder_pattern, file_name));
if isempty(files)
    error('No result file found for pattern results/%s/%s', folder_pattern, file_name);
end

[~, idx] = max([files.datenum]);
file_path = fullfile(files(idx).folder, files(idx).name);
end

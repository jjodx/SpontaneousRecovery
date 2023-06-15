function STRUCT_AT=CSV2STRUCT(filename)
if nargin==0
    mat_files = dir('*.zip');
else
    mat_files.name=filename;
    mat_files.folder=cd;
end

for file_idx = 1:numel(mat_files)
    zip_filename = mat_files(file_idx).name;
    zip_filepath = mat_files(file_idx).folder;
    
    % Extract the zip file
    unzip(zip_filename, zip_filepath);
    
    % Get the CSV directory name
    csv_dirname = strrep(zip_filename, '.zip', '_csv');
    
    % Create an empty structure called ANA
    STRUCT_AT = struct();
    
    % List the CSV files within the directory
    csv_files = dir(fullfile(zip_filepath, csv_dirname, '*.csv'));
    
    % Iterate over the CSV files and read the data into the ANA structure
    for csv_idx = 1:numel(csv_files)
        csv_filename = csv_files(csv_idx).name;
        
        % Split the CSV filename to extract the field name
        [~, field_name, ~] = fileparts(csv_filename);
        
        % Split the field name to remove the filename prefix
        underscore_idx = strfind(field_name, '_');
        field_name = field_name(underscore_idx(end)+1:end);
        
        % Read the data from the CSV file using readmatrix
        csv_filepath = fullfile(zip_filepath, csv_dirname, csv_filename);
        data = readmatrix(csv_filepath);
        
        % Assign the data to the corresponding field in the ANA structure
        STRUCT_AT.(field_name) = data;
    end
    
    % Delete the temporary CSV directory
    rmdir(fullfile(zip_filepath, csv_dirname), 's');
end
end
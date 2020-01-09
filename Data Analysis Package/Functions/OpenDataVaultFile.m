function [ the_data, names, data_struct ] = OpenDataVaultFile( file_number )
% Opens a data vault file by specifying the file number rather than the
% file name

%Keep track of the original folder to return to after the function is run
curr_folder = cd;

%Read the text file that contains the path to datavault 
cd ..
path_id = fopen('Data_Vault_Path.txt');
data_vault_path = fgetl(path_id);

%Change directory to the data vault path 
cd(data_vault_path);
dir_info = dir;

the_data = [];

for i = 1:length(dir_info)
    try
        number = str2num(dir_info(i).name(1:6));
    catch
        continue
    end
    
    if file_number == number
        file = dir_info(i).name;
        break
    end
end

try
    struct = h5read(file, '/DataVault');
    fields = fieldnames(struct);
    the_data = [];
    for i = 1:numel(fields)
        the_data = [the_data struct.(fields{i})];
    end
catch
    
end

meta = hdf5info(file); 

names = {}; 

name_index = 1; 

for i = 1:length(meta.GroupHierarchy.Datasets.Attributes) 
    
    short_name = meta.GroupHierarchy.Datasets.Attributes(i).Shortname;  
    
    if short_name(end-4:end) == 'label'
        
        names{name_index} = meta.GroupHierarchy.Datasets.Attributes(i).Value.data; 
        
        name_index = name_index + 1; 
        
    end
end

[~,n] = size(the_data); 

if length(names) ~= n
    error('You messed it all up')
end

for i = 1:n
    this_name = names{i}; 
    this_name = this_name(~isspace(this_name)); 
    this_name = strrep(this_name,'.','');
    this_name = ['field_',this_name];
    data_struct.(this_name) = the_data(:,i); 
end

cd(curr_folder);

end

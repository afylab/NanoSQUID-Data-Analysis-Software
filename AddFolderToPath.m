path_id = fopen('Folder_Path.txt');
Folder_path = fgetl(path_id);
addpath(genpath(Folder_path))
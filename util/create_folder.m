function create_folder(folder_path)
    %function that allows to create a folder
    [~,~,ext] = fileparts(folder_path);
    if not(isempty(ext))
        warning('Can not create folders with extension');
    end

    if not(exist(folder_path,'dir'))
        %only create the folder in case it is not created
        mkdir(folder_path);
    end

end
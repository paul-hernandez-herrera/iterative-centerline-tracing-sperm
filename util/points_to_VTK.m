function points_to_VTK(points, file_output)
    %function to convert points to VTK format

    %Input:
    %file_output: the path name where the file will be saved
    %points: points to be save in vtk format with consecutive connections
    
    %creating a file with extension vtk
    [file_path, file_name, ~] = fileparts(file_output);
    file_output = fullfile(file_path, [file_name '.vtk']);
    
    %Getting the line connections. Every point is connected with its
    %consecutive point
    id = (1:(size(points,1)-1))';
    parent = id-1;
    connections = [id parent];
    
    %removing points without connections
    I = connections(:,2) == -1;
    connections(I,:) = [];
    
    %Adding the required value of the number of conection 
    connections = [2*ones(size(connections,1),1) connections];
    
    fid = fopen(file_output,'w');
    
    fprintf(fid,'# vtk DataFile Version 2.0\n');
    fprintf(fid,'# points to vtk file format https://vtk.org/wp-content/uploads/2015/04/file-formats.pdf\n');
    fprintf(fid,'ASCII\n');
    fprintf(fid,'DATASET POLYDATA\n');
    fprintf(fid,'POINTS %i float\n',size(points,1));
    fprintf(fid,'%2.3f\t %2.3f\t %2.3f\n',points');
    fprintf(fid,'LINES %i %i\n',size(connections,1),3*size(connections,1));
    fprintf(fid,'%i\t %i\t %i\n',connections');
    fclose(fid);

end
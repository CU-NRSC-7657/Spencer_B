%% Add Meta Data

% This function will add metadata for your mice to your dataframe based on
% MouseID. The file containing the metadata must be an .xlsx or .csv with
% the first column labeled "MouseID" and containing your mouse names. All
% other columns can be labeled as you like.

function [metaBIGdf]=Add_mouse_meta(your_dataframe,your_meta_filepath)

arguments
    your_dataframe table
    your_meta_filepath string
end

% read in the meta data
meta_table=readtable(your_meta_filepath);

% find dataframe width
old_width=width(your_dataframe);

% add n columns to dataframe for new meta
tempCells=cell(height(your_dataframe),width(meta_table)-1);
tempTable=cell2table(tempCells,'VariableNames',meta_table.Properties.VariableNames(2:end));
your_dataframe=[your_dataframe, tempTable];

% add meta data to each row of the dataframe
for i=1:height(meta_table)
    your_dataframe(your_dataframe.MouseID==meta_table.MouseID(i),old_width+1:end)=...
        repmat(meta_table(i,2:end),sum(your_dataframe.MouseID==meta_table.MouseID(i)),1);
end

% this exists becuase movevars is built dumb
new_width=width(your_dataframe);

% move meta data to start(left) of dataframe for easy reading
metaBIGdf=movevars(your_dataframe,[old_width+1:new_width],'After','MouseID');

end

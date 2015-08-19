function [in_ch,memory]=load_data(in_ch_enable)

  mask = in_ch_enable;
  for i=1:10
    if mod(mask,2)==1
      in_ch{i} = csvread(['in_ch_data_' num2str(i) '.dat']);
    end
    mask = floor(mask/2);
  end

  memory = csvread('stored_custom_data.dat');


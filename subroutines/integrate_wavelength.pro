function integrate_wavelength,min_x,max_x,data
  
  emis = fltarr(data.frames)
   
  for i=0,data.frames-1 do begin
    where_emis = where(data.wavelength gt min_x and data.wavelength lt max_x)
    n_emis = n_elements(where_emis)
    wave_i_emis = findgen(n_emis) 
    emis[i] =  INT_TABULATED(data.wavelength[where_emis],data.data[where_emis,i]-wave_i_emis*(min(data.data[where_emis[n_emis-10:n_emis-1],i])-min(data.data[where_emis[0:5],i]))/n_emis-min(data.data[where_emis[0:5],i]))  
  endfor
  
  return, emis
  
end
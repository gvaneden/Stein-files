pro fill_emis_line,color_fill,cap_flag,tot_intensity,data,wavelength,max_cap,min_x,max_x

  wave_range = where(data.wavelength gt min_x and data.wavelength lt max_x)
  n_wave_range =  n_elements(wave_range)
  PXVAL = [wavelength[wave_range[0]],wavelength[wave_range],wavelength[wave_range[n_wave_range-1]]]
  MINVAL1 = min(tot_intensity[wave_range[0:10]])
  MINVAL2 = min(tot_intensity[wave_range[n_wave_range-10:n_wave_range-1]])  ; !Y.CRANGE[0]')
  if cap_flag eq 1 then begin
  cap_intensity = tot_intensity[wave_range]
  for k=0,n_elements(wave_range)-1 do if tot_intensity[wave_range[k]] le max_cap then cap_intensity[k] = tot_intensity[wave_range[k]] else cap_intensity[k] = max_cap
  POLYFILL, PXVAL, [MINVAL1, cap_intensity, MINVAL2], COL = cgcolor("red")
  endif else begin
  POLYFILL, PXVAL, [MINVAL1, tot_intensity[wave_range], MINVAL2], COL = cgcolor(color_fill)
  endelse  
        
end        
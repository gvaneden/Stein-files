pro save_channel_data,channel,data,num_ch,file_pic,date,shot,filestore,tot_intensity

    void = EXECUTE('int_intensity'+num_ch+' = fltarr(data.frames)')
    void = EXECUTE('wavelength'+num_ch+' = data.wavelength')
    
    for i=0,data.frames-1 do begin
    void = EXECUTE('int_intensity'+num_ch+'[i] =  INT_TABULATED(data.wavelength,data.data[*,i])')
    endfor
    
    cd, file_pic
    FILE_MKDIR, date+'-'+shot
    
    ; *****   plot wavelength integrated intensity as function of time  *****
    
    mydevice = !D.NAME
    set_plot,'ps'
    device,/encaps,file=file_pic+date+'-'+shot+'/intensity_time_'+channel+'_'+date+'_exp'+shot+'.eps',/col,bits=8
          
    void = EXECUTE('plot,data.time-data.time[0],int_intensity'+num_ch+',xtitle="time [s]",ytitle="intensity [a.u.]"')
    
    device,/close
    set_plot,mydevice
    
    void = EXECUTE('tot_intensity'+num_ch+' = fltarr(n_elements(data.wavelength))')
    for i=0,n_elements(data.wavelength)-1 do begin
    void = EXECUTE('tot_intensity'+num_ch+'[i] = total(data.data[i,*])')
    endfor

    ; *****   plot time integrated intensity as function of wavelength  *****
    ;     
    mydevice = !D.NAME
    set_plot,'ps'
    device,/encaps,file=file_pic+date+'-'+shot+'/intensity_tot_'+channel+'_'+date+'_exp'+shot+'.eps',/col,bits=8
          
    void = EXECUTE('plot,data.wavelength,tot_intensity'+num_ch+',xtitle="wavelength [nm]",ytitle="intensity [a.u.]"')
    
    device,/close
    set_plot,mydevice
    
    cd, filestore
    
    void = EXECUTE('data'+num_ch+'=data')
    undefine,data
    SAVE, /VARIABLES, FILENAME = 'spectro_ch_'+channel+'_'+date+'_exp'+shot+'.sav'
    
    print,'Files saved - channel '+channel
    
end
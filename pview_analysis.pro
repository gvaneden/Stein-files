pro pview_analysis,date,num,num2,plot_type,time_corr,time_corr2,gas

; time_corr = time delay for IR-camera 
; time_corr2 = time delay for spectrometer

; *****************************************************************          
; This program combines the data of several diagnotics and creates 
; a time evolution of the related quantities. The following diagnostics 
; are included in the program:
;  - arc data (B-field, cathode potential, source current, gas flow, etc.)                   
;  - IR data (surface temperature)
;  - pryo data (surface temperature) 
;  - spectrometer (emission lines)
;  
; The program searches for data (.SAV files) of the diagnostics in the 
; storage folder.   
; 
; How to convert the diagnostics data in the .SAV data format and store it 
; in the storage folder? -->
;  
; arc data      --> use 'run_arc_data.pro'
; pyro data     --> use 'run_pyro_data.pro'
; IR data       --> use 'temp_conversion_smallIR.pro'; 
; spectral data --> use 'run_spectro_data.pro'
; TS data       --> use Hennie's TS program: \\rijnh\shares\Projects\Pilot\Programs\IDL 7.0\Thomson Scattering\[USE THESE FILES]\2011-11-17 - Make_TS_profile.pro
;  
; Created by:
; D.U.B. Aussems - 10-11-2014
; 
; Modified by:
; D.U.B. Aussems - 12-11-2014 : included TS data
;                                                                 
; *****************************************************************   

print,''
print,'------------------ Date '+date+' Shot '+num+'------------------'
print,''

filestore = '/Rijnh/Shares/Projects/Pilot/Projects/Damien Aussems/Experiment Campaign 1/storage/'
cd, filestore


; -------------------------------------------------
; Create window or PS (post-script/PDF) environment 
; -------------------------------------------------

if plot_type eq 'ps' then begin
cgPS_Open, 'output/data_'+date+'_shot'+num+'.eps', xsize=6, ysize=10, /inches, portrait=1,/encapsulated
ch_sz=2
endif else begin
cgWindow, title='Data',WXSize=600,WYSize=800
ch_sz=2
endelse

; -------------------------------------------------
; set graphic options
; -------------------------------------------------

cgLoadCT, 34
!p.multi=[0,1,5]


; **************************************************************************************
; Start with cascaded arc data
; **************************************************************************************

restore, 'cascaded-arc_'+date+'_exp'+num+'.sav'

; -------------------------------------------------
; get timing values from B-field data 
; -------------------------------------------------

timing_B = data.time
where_time = where(data.mag_field ge 0.6*max(data.mag_field))
B_correct_time = timing_B[where_time]
n_B_correct_time = n_elements(B_correct_time)
last_time_B = B_correct_time[n_B_correct_time-1]
total_time_B = last_time_B - B_correct_time[0]

; set timing values for plotting 
time_plot = last_time_B + 2*alog(total_time_B) ; last (corrected) time value for plotting 
time_corr_ex = B_correct_time[0] - alog(total_time_B) ; first (corrected) time value for plotting 


; -------------------------------------------------
; Plot B-field as function of time
; -------------------------------------------------

; plot time = time 
cgplot,data.time, data.mag_field, xtitle = 'time (s)',xrange=[time_corr_ex,time_plot],ytitle='B [T]',/addcmd, charsize=ch_sz,color=cgcolor('black')
xyouts, 0.1*(time_plot-time_corr_ex)+time_corr_ex,1.3*max(data.mag_field),  date+' Exp '+num2+' Shot '+num,color=cgcolor('black')

; -------------------------------------------------
; Print average bias and pressure value
; -------------------------------------------------

avg_bias = mean(data.V_TARGET[where_time])
avg_pres = mean(data.PRES_VES[where_time])
;avg_cur  = mean(data.CAT_CUR[where_time])

xyouts, 1.1*(time_plot-time_corr_ex)+time_corr_ex,0.8 *max(data.mag_field),'other parameters:', charsize=1 ,color=cgcolor('black')
xyouts, 1.1*(time_plot-time_corr_ex)+time_corr_ex,0.55 *max(data.mag_field),'V_bias = '+string(avg_bias,format='(I0.1)')+' V', charsize=1 ,color=cgcolor('black')
xyouts, 1.1*(time_plot-time_corr_ex)+time_corr_ex,0.3 *max(data.mag_field),'p = '+string(avg_pres,format='(F0.3)')+' Pa', charsize=1  ,color=cgcolor('black')


; **************************************************************************************
; Continue with TS data
; **************************************************************************************

import_TS, date, num, n_e, T_e , flux, gas

if n_elements(n_e) ne 0 then begin 
n_e = n_e*1e20
flux = flux*1e20

xyouts, 1.1*(time_plot-time_corr_ex)+time_corr_ex,0.05 *max(data.mag_field),'n_e = '+string(n_e,format='(E0.2)')+textoidl(' m^{-3}'), charsize=1  ,color=cgcolor('black')
xyouts, 1.1*(time_plot-time_corr_ex)+time_corr_ex,-0.20 *max(data.mag_field),'T_e = '+string(T_e,format='(F0.2)')+' eV', charsize=1  ,color=cgcolor('black')
xyouts, 1.1*(time_plot-time_corr_ex)+time_corr_ex,-0.45 *max(data.mag_field),'ion_flux = '+string(flux,format='(E0.2)')+textoidl(' m^{-2}s^{-1}'), charsize=1  ,color=cgcolor('black')

endif

undefine,data

; **************************************************************************************
; Continue with IR and pyrometer data
; **************************************************************************************

IR_case = file_search('IR_'+date+'_exp'+num2+'.sav',/fold_case)
IR_flag = n_elements(IR_case)

pyro_case = file_search('pyro_'+date+'_exp'+num+'.sav',/fold_case)
pyro_flag = n_elements(pyro_case)
  
if (pyro_flag eq 1 and pyro_case ne '') and (IR_flag eq 1 and IR_case ne '') then case_temp = 1 else begin
if (pyro_flag eq 1 and pyro_case ne '') then case_temp = 2 else if (IR_flag eq 1 and IR_case ne '') then case_temp = 3
endelse   
            
CASE case_temp OF

;**********************************************************************************************************************************************************************

  1: begin
    
    PRINT,'>>> Both pyro and IR data <<<' 
   
    restore, 'pyro_'+date+'_exp'+num+'.sav'
    restore, 'IR_'+date+'_exp'+num2+'.sav'
    
    ; -------------------------------------------------
    ; get timing of the pyrometer from the IR data and B-field data (more accurate than only from B-field)
    ; -------------------------------------------------
    
    n_data_pyro_time = n_elements(data_pyro.time)
    delta_pyro_time = data_pyro.time[n_data_pyro_time-1]-data_pyro.time[0]
    
    timing_IR = ir_time
    where_time_IR = where(ir_temp2 ge 0.4*max(ir_temp2))
    IR_correct_time = timing_IR[where_time_IR]
    n_IR_correct_time = n_elements(IR_correct_time)
    last_time_IR = IR_correct_time[n_IR_correct_time-1]
    total_time_IR = last_time_IR - IR_correct_time[0]
      
    
    pyro_time = data_pyro.time-data_pyro.time[0]+B_correct_time[0]

             
  ; -------------------------------------------------
  ; plot IR and pyro data 
  ; -------------------------------------------------
    
    ; plot time = time + offset for IR data
    cgplot,ir_time+time_corr,ir_temp2,xrange=[time_corr_ex,time_plot],ytitle='T_s [C]',/addcmd, charsize=2, YStyle=4, /nodata,yrange=[0,1.05*max([ir_temp2,data_pyro.temp])]
    cgAxis, YAxis=0.0, /Save, ytitle='T_s [C]',/window, charsize=ch_sz
    cgOplot,ir_time+time_corr,ir_temp2,/addcmd,color='blue'
    cgOplot,pyro_time,data_pyro.temp,/addcmd,color='green'
    cgAxis, YAxis=1.0,color='red',ytitle='Signal [a.u.]',/Save,/window, charsize=ch_sz,yrange=[0,1.05*max(data_pyro.signal)]
    cgOplot,pyro_time,data_pyro.signal,xrange=[time_corr_ex,time_plot],color='red',/addcmd
    cglegend,titles=['IR camera', 'Pyrometer'],$; /BACKGROUND, bg_color='white', $; /Box        $
             color=['blue','green'], linestyle=[0,0], Location=[0.75, 0.76],/addcmd, charsize=0.7,VSpace=0.8, Length=0.05
     
   end
   
;**********************************************************************************************************************************************************************   
   
 2: begin
  
    print, '!!! No IR data !!!!'
    
    restore, 'pyro_'+date+'_exp'+num+'.sav'
     
    ; get timing from B-field time
    n_data_pyro_time = n_elements(data_pyro.time)
    delta_pyro_time = data_pyro.time[n_data_pyro_time-1]-data_pyro.time[0]
  
    pyro_time = last_time_B-delta_pyro_time+data_pyro.time-data_pyro.time[0]
    
    restore, 'pyro_'+date+'_exp'+num+'.sav'
    
    ; plot time = time + offset for IR data 
    cgplot,pyro_time,data_pyro.temp,xrange=[time_corr_ex,time_plot],ytitle='T_s [C]',/addcmd, charsize=2, YStyle=4, /nodata
    cgAxis, YAxis=0.0, /Save, ytitle='T_s [C]',/window, charsize=ch_sz
    cgOplot,pyro_time,data_pyro.temp,/addcmd
    cgAxis, YAxis=1.0,color='red',ytitle='Signal [a.u.]',/Save,/window, charsize=ch_sz,yrange=[0,1.05*max(data_pyro.signal)]
    cgOplot,pyro_time,data_pyro.signal,xrange=[time_corr_ex,time_plot],color='red',/addcmd
    
   end
   
;**********************************************************************************************************************************************************************
   
 3: begin
  
    print, '!!! No pyro data !!!!'
    
    restore, 'IR_'+date+'_exp'+num2+'.sav'
    
    ; plot time = time + offset for IR data
    cgplot,ir_time+time_corr,ir_temp2,xrange=[time_corr_ex,time_plot],ytitle='T_s [C]',/addcmd, charsize=ch_sz, yrange=[0,1.05*max(ir_temp2)]  
    cglegend,titles=['IR camera'],$; /BACKGROUND, $;bg_color='white', $; /Box        $
             color=['black'], linestyle=[0], Location=[0.75, 0.76],/addcmd, charsize=0.7,VSpace=0.8, Length=0.05
   
   end
             
             
   ELSE: print, '!!! No pyro and IR data !!!!'  
   
ENDCASE

  
undefine,data

; **************************************************************************************
; Continue with spectrometer data
; **************************************************************************************

; search all .SAV files (more channels is an option)
list_spec = file_search(filestore,'spectro*'+date+'_exp'+num+'.sav')
n_list_spec = n_elements(list_spec)


if uint(n_list_spec) gt 0 and list_spec[0] ne '' then begin ; check if there is spectro data at all.

; --------------------------------------------
; Determine cases 
; --------------------------------------------

if STRMATCH(list_spec[0], '*0605006U4*', /FOLD_CASE) EQ 1 then case_spectro = 3 else begin
 if n_elements(list_spec) gt 1 then case_spectro = 2 else if n_elements(list_spec) eq 1 then case_spectro = 1 
endelse 




CASE case_spectro OF

;**********************************************************************************************************************************************************************

   1: begin 
    
    restore,list_spec[0]
    
    if data1.frames ge 10 and data1.time[n_elements(data1.time)-1]-data1.time[0] gt 4 then begin  ; only analyse spectrum if the timing is long enough 
  
    PRINT, '>>> Channel 1012077U2 <<<'
   
    ; ----------------------------------------------------
    ; Define wavelength ranges for peaks you want to plot 
    ; ----------------------------------------------------
    
    CH_min = 420
    CH_max = 432

    ; ----------------------------------------------------
    ; Integrate emission 
    ; ----------------------------------------------------
    
     
    CH_emis = integrate_wavelength(CH_min,CH_max,data1)
  

    ; ----------------------------------------------------
    ; Plot emission as function of time
    ; ----------------------------------------------------
    
    ; plot time = time + time off set for spectrometer
    cgplot,data1.time-data1.time[0]+time_corr2,CH_emis,xtitle='time [s]',ytitle='intensity [a.u.]',Color='black',/addcmd,BACKGROUND='white', charsize=ch_sz, Aspect=1.0,xrange=[time_corr_ex,time_plot]
    cglegend,titles=['CH emission'], $;/Box, /BACKGROUND, bg_color='white',        $
           color='black', Location=[0.75, 0.36],/addcmd, charsize=0.7,VSpace=0.8, Length=0.05
    
    ; ----------------------------------------------------
    ; Plot emission as function of wavelength
    ; ----------------------------------------------------
    
    cgplot,wavelength1,tot_intensity1,xtitle='wavelength [nm]',ytitle='intensity [a.u.]',Color='black',/addcmd,BACKGROUND='white', charsize=ch_sz, Aspect=1.0
    
    
    fill_emis_line,'black',0,tot_intensity1,data1,wavelength1,max_cap,CH_min,CH_max ;wavelength show ch
    
    endif
    
   end 
    
;**********************************************************************************************************************************************************************
   
   2: begin
    
 
    
    PRINT, '>>> Channel 1012077U2 + 1012078U2 <<<'

    ; ----------------------------------------------------
    ; Define wavelength ranges for peaks you want to plot 
    ; ----------------------------------------------------
    
    CH_min = 420
    CH_max = 432
    
    H_min = [433.0,407.7]
    H_max = [435.0,412.7]
       
    Swan_min = [460,500,535]
    Swan_max = [476,519,564]   
    
    ; ----------------------------------------------------
    ; Integrate emission 
    ; ----------------------------------------------------

    restore,list_spec[0]
    restore,list_spec[1]

    if data1.frames ge 10 and data1.time[n_elements(data1.time)-1]-data1.time[0] gt 4 then begin  ; only analyse spectrum if the timing is long enough           
   
    CH_emis = integrate_wavelength(CH_min,CH_max,data1)
    H_peak1 = integrate_wavelength(H_min[0],H_max[0],data1)
    H_peak2 = integrate_wavelength(H_min[1],H_max[1],data1)
    Swan_peak1 = integrate_wavelength(Swan_min[0],Swan_max[0],data2)
    Swan_peak2 = integrate_wavelength(Swan_min[1],Swan_max[1],data2)
    Swan_peak3 = integrate_wavelength(Swan_min[2],Swan_max[2],data2)

    ; -------------------------------------------        
    ; Plot emission lines as function of time 
    ; -------------------------------------------
    
    ; Exception:
    if date eq '2014-08-28' and num eq '24' then correct_time[0] = 5
    
    ; The time interval in which the maximum of the plot is computed is etiher equal to the time interval of the 
    ; IR data or the B-field data - 2 seconds at the start. If the time is less than 5 seconds, the seconds are 
    ; not discounted.
    if n_elements(IR_correct_time) ne 0 then begin
      when_spec_i = where(data1.time-data1.time[0]+time_corr2 gt IR_correct_time[0]+time_corr+2 and data1.time-data1.time[0]+time_corr2 lt last_time_IR+time_corr)
      if total_time_IR lt 5 then when_spec_i = where(data1.time-data1.time[0]+time_corr2 gt IR_correct_time[0]+time_corr and data1.time-data1.time[0]+time_corr2 lt last_time_IR+time_corr)
    endif else begin
      when_spec_i = where(data1.time-data.time1[0]+time_corr2 gt B_correct_time[0]+time_corr+2 and data1.time-data1.time[0]+time_corr2 lt last_time_B+time_corr)
      if total_time_B lt 5 then when_spec_i = where(data1.time-data1.time[0]+time_corr2 gt B_correct_time[0]+time_corr and data1.time-data1.time[0]+time_corr2 lt last_time_B+time_corr)
    endelse
    max_plot = 1.2*max([CH_emis[when_spec_i],Swan_peak1[when_spec_i],Swan_peak2[when_spec_i],Swan_peak3[when_spec_i],H_peak1[when_spec_i],H_peak2[when_spec_i]])
    
    ; plot time = time + time off set for spectrometer
    cgplot,data1.time-data1.time[0]+time_corr2,CH_emis,xtitle='time [s]',ytitle='intensity [a.u.]',Color='black',/addcmd,yrange=[0,max_plot], charsize=ch_sz, Aspect=1.0,xrange=[time_corr_ex,time_plot]
    cgplot,data1.time-data1.time[0]+time_corr2,Swan_peak1,xtitle='time [s]',ytitle='intensity [a.u.]',/overplot,Color='dodger blue',/addcmd,linestyle=5, charsize=ch_sz
    cgplot,data1.time-data1.time[0]+time_corr2,Swan_peak2,xtitle='time [s]',ytitle='intensity [a.u.]',/overplot,Color='magenta',/addcmd,linestyle=5, charsize=ch_sz
    cgplot,data1.time-data1.time[0]+time_corr2,Swan_peak3,xtitle='time [s]',ytitle='intensity [a.u.]',/overplot,Color='green',/addcmd,linestyle=5, charsize=ch_sz
    cgplot,data1.time-data1.time[0]+time_corr2,H_peak1,xtitle='time [s]',ytitle='intensity [a.u.]',/overplot,Color='dark red',/addcmd,linestyle=3, charsize=ch_sz
    cgplot,data1.time-data1.time[0]+time_corr2,H_peak2,xtitle='time [s]',ytitle='intensity [a.u.]',/overplot,Color='red',/addcmd,linestyle=3, charsize=ch_sz
    cglegend,titles=['CH emis', 'H 434.0 nm','H 410.2 nm','Swan 1','Swan 2','Swan 3'], $;/Box, /BACKGROUND, bg_color='white',        $
         color=['black','dark red','red','dodger blue','magenta','green'], linestyle=[0,3,3,5,5,5], Location=[0.75, 0.56],/addcmd, charsize=0.7,$
         VSpace=0.8, Length=0.05; VSpace=1, Length=0.05                             

    
    ; -------------------------------------------        
    ; Plot fraction of lines as function of time
    ; -------------------------------------------
     
    ; determine timing depending on whether IR data is available (else use B-field data). This procedure skips the first 0.5 seconds, because there is too much fluctuation.
    if n_elements(IR_correct_time) ne 0 then begin
    when_spec = where(data1.time-data1.time[0]+time_corr2 gt IR_correct_time[0]+time_corr+0.5 and data1.time-data1.time[0]+time_corr2 lt last_time_IR+time_corr)
    endif else begin
    when_spec = where(data1.time-data1.time[0]+time_corr2 gt B_correct_time[0]+time_corr+0.5 and data1.time-data1.time[0]+time_corr2 lt last_time_B+time_corr)
    endelse

    ; Determine fractions
    int_frac_SwanH = (Swan_peak1-mean(Swan_peak1[0:3])+Swan_peak2-mean(Swan_peak2[0:3])+Swan_peak3-mean(Swan_peak3[0:3]))/(H_peak1-mean(H_peak1[0:3]))
    int_frac_CHH = (CH_emis-mean(CH_emis[0:3]))/(H_peak1-mean(H_peak1[0:3]))

    
    max_plot = 1.5*max([int_frac_SwanH[when_spec_i],int_frac_SwanH[when_spec_i]])                
    cgplot,data1.time[when_spec]-data1.time[0]+time_corr2,int_frac_SwanH[when_spec],xtitle='time [s]',ytitle='intensity [a.u.]',Color='blue',/addcmd,linestyle=3, charsize=ch_sz,xrange=[time_corr_ex,time_plot],yrange=[min([int_frac_SwanH[when_spec],int_frac_CHH[when_spec]]),max([int_frac_SwanH[when_spec],int_frac_CHH[when_spec]])]
    cgplot,data1.time[when_spec]-data1.time[0]+time_corr2,int_frac_CHH[when_spec],xtitle='time [s]',ytitle='intensity [a.u.]',/overplot,Color='red',/addcmd,linestyle=3, charsize=ch_sz
    cglegend,titles=[textoidl('Swan / H_\gamma'),textoidl('CH / H_\gamma')],$; /Box, /BACKGROUND, bg_color='white',        $
         linestyle=[0,0],color=['blue','red'], Location=[0.75, 0.36],/addcmd, charsize=0.7,VSpace=0.8, Length=0.05         
              
  
    ; -------------------------------------------        
    ; wavelength plot
    ; -------------------------------------------
    
    ; Define range 
    wave_range_Swan3 = where(wavelength2 gt Swan_min[2] and wavelength2 lt Swan_max[2])
    wave_range_CH = where(data1.wavelength gt CH_min and data1.wavelength lt CH_max)
    
    cgplot,wavelength1,tot_intensity1,xtitle='wavelength [nm]',ytitle='intensity [a.u.]',xrange=[min(wavelength1),max(wavelength2)],Color='black',/addcmd,BACKGROUND='white', charsize=ch_sz, Aspect=1.0 ,yrange=[0,max([1.3*tot_intensity1[wave_range_CH],1.3*tot_intensity2[wave_range_Swan3]])],/nodata
    cgoplot,wavelength1,tot_intensity1
  
    
    ; Fill lines
    max_cap = max([1.3*tot_intensity1[wave_range_CH],1.3*tot_intensity2[wave_range_Swan3]]) ; check border of graph
  
    
    fill_emis_line,'black',0,tot_intensity1,data1,wavelength1,max_cap,CH_min,CH_max ;wavelength show ch
    fill_emis_line,'dark red',1,tot_intensity1,data1,wavelength1,max_cap,H_min[0],H_max[0] ;wavelength show H peak 1
    fill_emis_line,'red',1,tot_intensity1,data1,wavelength1,max_cap,H_min[1],H_max[1] ;wavelength show H peak 1
    
    cgOplot,wavelength2,tot_intensity2

    fill_emis_line,'dodger blue',0,tot_intensity2,data2,wavelength2,max_cap,Swan_min[0],Swan_max[0] ;wavelength show Swan 1
    fill_emis_line,'magenta',0,tot_intensity2,data2,wavelength2,max_cap,Swan_min[1],Swan_max[1]  ;wavelength show Swan 2
    fill_emis_line,'green',0,tot_intensity2,data2,wavelength2,max_cap,Swan_min[2],Swan_max[2] ;wavelength show Swan 3
     
    endif
   end
   
;**********************************************************************************************************************************************************************
   
   3: begin

    if data3.frames ge 10 and data3.time[n_elements(data3.time)-1]-data3.time[0] gt 4 then begin  ; only analyse spectrum if the timing is long enough 
    restore,list_spec[0]
        
    PRINT, '>>> Channel 0605006U4 <<<'

    ; ----------------------------------------------------
    ; Define wavelength ranges for peaks you want to plot 
    ; ----------------------------------------------------
    
    CH_min = 420
    CH_max = 432
    
 
    ; ----------------------------------------------------
    ; Integrate emission 
    ; ----------------------------------------------------
    
     
    CH_emis = integrate_wavelength(CH_min,CH_max,data1)

    ; ----------------------------------------------------
    ; Plot emission as function of time
    ; ----------------------------------------------------

    cgplot,data.time-data.time[0]+time_corr2,CH_emis,xtitle='time [s]',ytitle='intensity [a.u.]',Color='black',/addcmd , charsize=ch_sz, Aspect=1.0,xrange=[time_corr_ex,time_plot]
    cglegend,titles=['CH emission'],$; /Box, /BACKGROUND, bg_color='white',        $
           color='black', Location=[0.75, 0.56],/addcmd, charsize=0.7,VSpace=0.8, Length=0.05 
    
    ; ----------------------------------------------------
    ; Plot emission as function of wavelength
    ; ----------------------------------------------------
    
    cgplot,wavelength3,tot_intensity3,xtitle='wavelength [nm]',ytitle='intensity [a.u.]',Color='black',/addcmd,BACKGROUND='white', charsize=ch_sz, Aspect=1.0       
 
    fill_emis_line,'blue',0,tot_intensity3,data3,wavelength3,0,CH_min,CH_max ;wavelength show ch 
    
    
    endif
   end
   
   ELSE: PRINT, '!!! No Spectral data !!!'
   
ENDCASE

endif


undefine,data1,data2,data3

; end PS environement
if plot_type eq 'ps' then cgPS_Close, WIDTH=600,/PDF


close

end












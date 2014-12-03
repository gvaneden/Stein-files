pro run_spectro_data

; *****************************************************************          
; This program imports all spectral data of a specific folder              
; and saves them in the path specified. The program also makes 
; images of the spectrum and saves them in specific folder.            
; 
; Created by:                                
; D..U.B. Aussems - 10-11-2014                                                                 
; *****************************************************************     


; ------------------
; set paths and date ;
; ------------------

date = '2014-08-26'
file_path = '/Rijnh/Shares/Projects/Pilot/Projects/... '
filestore = '/Rijnh/Shares/Projects/Pilot/Projects/...'
file_pic = filestore+'spectro/' ; this is the folder

; ------------------
; set other variable
; ------------------

frames   = 0

; ------------------
; Loop through all files of the folder specified
; ------------------

for j = 0,50 do begin ; 50 is a random heigh number, if you have more folders hence did more experiments that day, please increase this number
  
  ; ------------------
  ; set filedir (this dir contains a list of .ROH/spectrum files of a specific shot)
  ; ------------------
  shot = string(j,format='(i0.0)')
  filedir = file_path+shot+ '/'
  result = FILE_TEST(filedir, /DIRECTORY) ; test if this directory is real 
  
  
  
  if result eq 1 then begin ; continue if this directory is real 
  
  ; The remainder of this program goes through all the channels and saves the data (if there is data) 
  
  ;----------------------------------
  ; Channel  '1012077U2' 
  ;----------------------------------
  
  channel  = '1012077U2'
  data1 = import_roh4(filedir, channel,frames)
  num_ch = '1'   ; this is how the data is saved
  
  
  if n_tags(data1) ne 0 then begin
  tot_intensity1 = fltarr(data1.frames)  
  save_channel_data,channel,data1,num_ch,file_pic,date,shot,filestore,tot_intensity1 
  endif
  
  ;----------------------------------
  ; Channel  '1012078U2'                  
  ;----------------------------------
  ;  
  channel =  '1012078U2'
  data2 = import_roh4(filedir, channel,frames)
  num_ch = '2'  
  
  
  if n_tags(data2) ne 0 then begin
  tot_intensity2 = fltarr(data2.frames)
  save_channel_data,channel,data2,num_ch,file_pic,date,shot,filestore,tot_intensity2
  endif

  ;----------------------------------
  ; Channel  '0605006U4'          
  ;----------------------------------
  
  channel =  '0605006U4'
  data3 = import_roh4(filedir, channel,frames)
  num_ch = '3'  
  
  
  if n_tags(data3) ne 0 then begin
  tot_intensity3 = fltarr(data3.frames)
  save_channel_data,channel,data,num_ch,file_pic,date,shot,filestore,tot_intensity3 
  endif 
  
  ;----------------------------------
  ; Channel  '1012077U2' and '1012078U2' together          
  ;----------------------------------
  
  if (n_tags(data1) ne 0 and n_tags(data2)) ne 0 then begin ; check whether the both channels were used
    
    ; open PS enviroment and save file in the picture folder of the current shot
    mydevice = !D.NAME
    set_plot,'ps'
    device,/encaps,file=file_pic+date+'-'+shot+'/intensity_tot_2-channel_'+date+'_exp'+shot+'.eps',/col,bits=8
    
    ; plot spectrum      
    plot,data1.wavelength,tot_intensity1,xtitle='wavelength [nm]',ytitle='intensity [a.u.]',xrange=[min(data1.wavelength),max(data2.wavelength)]
    oplot,data2.wavelength,tot_intensity2
    
    device,/close
    set_plot,mydevice
  
  endif
  
  
  endif


endfor

end
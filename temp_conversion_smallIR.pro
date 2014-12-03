; *****************************************************************
; Calculates surface temperature from output date (.SEQ files) from small FLIR IR camera (A645 sc).
; Data is extracted from the binary using import_seq.pro then converted to temperature from raw counts 
; using the same methodology as temperature_conversion_fastFLIR.pro
; Emissivity data is currently only available for W and Sn. 
; To successfully use this program ensure that you record some time before the shot where the temperature is at a (known) background

; Created by:
; D. van den Bekerom - ??-??-???? 
;                                 
; Modified by:
; T. Morgan - ??-??-2014
; D.U.B. Aussems - 11-11-2014                                                                 
; *****************************************************************    

pro temp_conversion_smallIR


cgdelete,/all
; INPUTS *********************************************************************************************************************************************
path        = unix_or_win('\\Rijnh\Data\Pilot\FLIR\Small IR camera\...');'\\Rijnh\Shares\Projects\Pilot\Measurement Data\IR Camera\2013\2013-06-26\'
filestore = '/Rijnh/Shares/Projects/Pilot/Projects/...' ; indicate where to store the .SAV files
file        = 'KB0008.SEQ'    
border     = 1                                                      ; boolean, if set, imports the data inside the frame border of the camera, otherwise if zero then imports entire image
savename    = path+(strsplit(file,'.',/extract))[0]+'.sav'          ; data read in from the .SEQ is subsequently saved as a '.sav'file in the same folder, which is quicker to read in IDL than the original binary
bgframes    = [0,5]                                                 ; frames used to calculate the background signal at the start of the shot for each pixel
bgtemp      = 25                                                    ; bgtemp in C.
emiss       = 'W'                                                   ; Set to 'W'or 'Sn' to use known temperature dependent emissivities. Set to a number to use a constant emissivity
trans       = 0.35                                                ; transmission of window (ZnSe is 0.6-0.7). CaF2 and BaF2 have bad transmission at upper end of 7.5-14 um range so should not be used.
temp_select = 2                                                     ; Position where data is outputted as a 1D array (in plots and output),
                                                                    ; set as 1 (defined as positions where xframeplot and yframeplot cross),
                                                                    ; 2 (position selected by clicking on picture), 3(selected by typing in using 'read')
xframeplot  = 5                                                     ; which position to plot the cut through the data at maximum intensity in x-direction (not used for temp_select = 2 or 3)                   
yframeplot  = 5                                                     ; which position to plot the cut through the data at maximum intensity in x-direction (not used for temp_select = 2 or 3)              
display     = 1                                                     ; boolean, if set, will plot the profiles in x and y direction at each displaytime
displaytime = [15]                                                  ; array of times to be plotted in x and y direction
pixelrangeh = [60,85]                                               ; if set selects only those horizontal pixels to be plotted in display
pixelrangev = [25,55]                                               ; if set selects only those vertical pixels to be plotted in display
; ****************************************************************************************************************************************************



; IMPORT DATA ****************************************************************************************************************************************

fname       = path+file


if file_test(savename) then begin 
  print, 'Restoring saved file '+savename
  restore, savename 
endif else begin
  print, 'Importing .SEQ data '+fname
   ;Import the seq-file, 1 means to use the frame border of the recording (instead of 0 for whole frame)
  ir  = import_seq(fname,border)
  save, ir, filename = savename
endelse

; ****************************************************************************************************************************************************


; SELECT X AND Y ARRAYS TO CONVERT *******************************************************************************************************************
ir_time = ir.time - (ir.time)(0)               ;set t0 to 0s 

bgdata = total(ir.data[*,*,bgframes[0]:bgframes[1]],3)/(bgframes[1]-bgframes[0]+1) ; average background over bgframes to reduce noise


; plot background
  cgLoadCT, 34, NColorS=12, Bottom=1
  cg_newwindow, title = 'Background (t=0)'
  cgcontour, bgdata,/fill,/addcmd,NLevels=12, Position=[0.125,0.125,0.9,0.75], C_Colors=Indgen(12), xtit = 'x direction (pixels)', ytit = 'y direction (pixels)',/iso
  cgColorbar, Range=[Min(bgdata), Max(bgdata)], Divisions=12, NColors=12, Bottom=1, $
                    Position=[0.125, 0.87, 0.9, 0.94], /Discrete,/addcmd,title = 'raw digital level'

maxi             = max(ir.data,maxsub)
maxframe      = long(maxsub/(ir.width*ir.height))

; plot maxframe
  cgLoadCT, 34, NColorS=12, Bottom=1
  cg_newwindow, title = 'Maximum intensity frame (raw) t = '+strtrim(string(ir_time[maxframe]))+' s'
  cgcontour,ir.data[*,*,maxframe],/fill,/addcmd,NLevels=12, Position=[0.125,0.125,0.9,0.75], C_Colors=Indgen(12)  
  cgColorbar, Range=[Min(ir.data[*,*,maxframe]),Max(ir.data[*,*,maxframe])], Divisions=12, NColors=12, Bottom=1, $
  Position=[0.125, 0.87, 0.9, 0.94], /Discrete,/addcmd,title = 'raw digital level'





print, 'Max raw digital level: ',maxi
    case temp_select of
    1:  begin
          xframeplot = xframeplot
          yframeplot = yframeplot
        end
    
    
    2:  begin
          selected_point = point_select(reform(ir.data[*,*,maxframe]))
          xframeplot  = selected_point.x
          yframeplot  = selected_point.y
        end
        
    3:  begin
          read, xframeplot, prompt = 'Input value of x point to be determined: '
          read, yframeplot, prompt = 'Input value of y point to be determined: '
        end
        
    endcase
; ****************************************************************************************************************************************************


; CONVERT COUNTS TO TEMPERATURE **********************************************************************************************************************

; import calibration of IR camera (relationship between counts and temperature)
cal = import_calibration(ir.filter)

case ir.filter of
  1: temprangeplot = [-40.,150.]
  2: temprangeplot = [100.,650.]
  3: temprangeplot = [300.,2000.]
endcase

cal_temp  = findgen(2000)
cal_dl = interpol(cal.dl,cal.temp-273.15,cal_temp)



cg_newwindow, title = 'calibration'
cgplot, cal_temp, cal_dl,/add;, xr = temprangeplot
cgplot, cal.temp-273.15, cal.dl,/add,/over,col='red',line = 2

cal_bg = interpol(cal.dl, cal.temp-273.15,bgtemp) 



ir_trace_t = reform(ir.data[xframeplot,yframeplot,*])
ir_trace_pv = reform(ir.data[xframeplot,*,maxframe])
ir_trace_ph = reform(ir.data[*,yframeplot,maxframe])
bgtrace    = bgdata[xframeplot,yframeplot]
bgtrace_pv = bgdata[xframeplot,*]
bgtrace_ph = bgdata[*,yframeplot]

; import emissivity data
if size(emiss,/type) eq 7 then begin
  case emiss of 
    'Sn'  : begin
              ;e_var   = sn_e_var(cal)
              e_var  = sn_e_var2(cal_temp)
            end
    'W'   : e_var = w_e_var2(cal_temp)
  endcase
endif else begin
  e_var = replicate(emiss,n_elements(cal.temp-273.15))
endelse

cg_newwindow,title = 'Temperature dependent emissivity'
cgplot, cal_temp, e_var,/add

reference_dl = (cal_dl - cal_bg)*e_var*trans

ir_temp2 = interpol(cal_temp, reference_dl,ir_trace_t-bgtrace)
ir_prof_v2 = interpol(cal_temp, reference_dl,ir_trace_pv-bgtrace_pv)
ir_prof_h2 = interpol(cal_temp, reference_dl,ir_trace_ph-bgtrace_ph)
; **************************************************************************************************************************************************



; PRINT AND DISPLAY DATA ***************************************************************************************************************************
print,transpose([[ir_time],[reform([ir_temp2])]])


cg_newwindow,title = 'Time trace T (C) at [xframeplot,yframeplot]'
cgplot,ir_time,ir_temp2,/add

cg_newwindow, tit = 'Horizontal T (C) at max frame'
cgplot,ir_prof_h2,/add

cg_newwindow, tit = 'Vertical T (C) at max frame'
cgplot,ir_prof_v2,/add

cg_newwindow, tit = 'Raw time trace at [xframeplot,yframeplot]'
cgplot, ir_time, ir_trace_t,/add

if display then begin
  for i = 0, n_elements(displaytime)-1 do begin
    frameplotindex = where(abs(displaytime[i]-ir_time) eq min(abs(displaytime[i]-ir_time)))
    ir_trace_displayh = reform(ir.data[xframeplot,*,frameplotindex])
    ir_trace_displayv = reform(ir.data[*,yframeplot,frameplotindex])
    ir_prof_displayv  = interpol(cal_temp, reference_dl,ir_trace_displayh-bgtrace_ph)
    ir_prof_displayh  = interpol(cal_temp, reference_dl,ir_trace_displayv-bgtrace_pv)
    cg_newwindow, tit = 'Horizontal T (C) at time '+strtrim(string(displaytime[i]),2)+' s'
    cgplot,ir_prof_displayh,/add, xrange=pixelrangeh
    cg_newwindow, tit = 'Vertical T (C) at time '+strtrim(string(displaytime[i]),2)+' s'
    cgplot,ir_prof_displayv,/add, xrange=pixelrangev
  endfor
endif
    
; SAVE DATA ***************************************************************************************************************************

cd, filestore

tmp_file = strsplit(path, '/', /extract)
n_tmp_file = n_elements(tmp_file)
folder = tmp_file[n_tmp_file-1]
date = strmid(folder,0,10)

print, 'Saving IR_'+date+'_exp'+file+'.sav ..'
save, /VARIABLES,file = 'IR_'+date+'_exp'+file+'.sav'
print,''
print,'>>> File saved <<<'    


end

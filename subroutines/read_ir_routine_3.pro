
pro read_ir_routine_2

;Check for the newest file (for during experiments) Only works for unix systems at the moment..
;path = unix_or_win('//Rijnh/Shares/Projects/Pilot/Measurement Data/IR Camera/2013/2013-12/2013-12-10-Tom_Sn_erosion_Ne_He/*.SEQ')
;list_files = strsplit(file_search(path),/extract)
;fname = strjoin(list_files(size(list_files,/n_elements)-1),' ')

;path  = unix_to_win('/Rijnh/Shares/Projects/Pilot/Measurement Data/IR Camera/2013/2013-09-06 Tom Sn penetration depths/')
;path  = '/Rijnh/Data/Magnum/IR-CAM/2013-09-13 multiprobe/'
;file  = 'probe0018.SEQ'
;fname = path+file
;
;filestart = strsplit(file,'.',/extract)
;savename  = path+filestart[0]+'.sav'
cgdelete,/all

path      = unix_or_win('//Rijnh/Shares/Projects/Pilot/Measurement Data/IR Camera/2014/2014-04/2014-04-23/')
file      = 'W0001.SEQ'
fname     = path+file
savename  = path+(strsplit(file,'.',/extract))[0]+'.sav'
bgframes  = [0,5]
bgtemp    = 25                ; bgtemp in C
material  = 'W' 
trans     = 0.7
temp_select = 2                      ; method of selecting point to be calculated
xframeplot = 80
yframeplot = 40 


if file_test(savename) then begin 
  print, 'Restoring saved file '+savename
  restore, savename 
endif else begin
  print, 'Importing .SEQ data '+fname
   ;Import the seq-file, 1 means to use the frame border of the recording (instead of 0 for whole frame)
  ir  = import_seq(fname,1)
  save, ir, filename = savename
endelse




ir_time = ir.time - (ir.time)(0)               ;set t0 to 0s 

bgdata = total(ir.data[*,*,bgframes[0]:bgframes[1]],3)/(bgframes[1]-bgframes[0]+1)

cgLoadCT, 34, NColorS=12, Bottom=1
        cg_newwindow, title = 'Background (t=0)'
        cgcontour, bgdata,/fill,/addcmd,NLevels=12, Position=[0.125,0.125,0.9,0.75], C_Colors=Indgen(12)+1, xtit = 'x direction (pixels)', ytit = 'y direction (pixels)',/iso
        cgColorbar, Range=[Min(bgdata), Max(bgdata)], Divisions=12, NColors=12, Bottom=1, $
                    Position=[0.125, 0.87, 0.9, 0.94], /Discrete,/addcmd,title = 'raw digital level'

maxi             = max(ir.data,maxsub)
maxframe      = long(maxsub/(ir.width*ir.height))


      cgLoadCT, 34, NColorS=12, Bottom=1
      cg_newwindow, title = 'Maximum intensity frame (raw) t = '+strtrim(string(ir_time[maxframe]))+' s'
      cgcontour,ir.data[*,*,maxframe],/fill,/addcmd,NLevels=12, Position=[0.125,0.125,0.9,0.75], C_Colors=Indgen(8)+1  
      cgColorbar, Range=[Min(ir.data[*,*,maxframe]),Max(ir.data[*,*,maxframe])], Divisions=12, NColors=12, Bottom=1, $
      Position=[0.125, 0.87, 0.9, 0.94], /Discrete,/addcmd,title = 'raw digital level'



cal = import_calibration(ir.filter)

cal_temp  = findgen(2000)
cal_dl = interpol(cal.dl,cal.temp-273.15,cal_temp)

cg_newwindow, title = 'calibration'
cgplot, cal_temp, cal_dl,/add, xr = [0,400]
cgplot, cal.temp-273.15, cal.dl,/add,/over,col='red',line = 2

cal_bg = interpol(cal.dl, cal.temp-273.15,bgtemp) 


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
        
;    4:  begin
;          max_x   = fltarr(coordinates[1]-coordinates[0]+1)
;          max_y   = fltarr(coordinates[3]-coordinates[2]+1)
;          for i = 0, coordinates[1]-coordinates[0] do max_x[i] = ( reform(data[i,*,maxsub/(coordinates[1]-coordinates[0]+1)/(coordinates[3]-coordinates[2]+1)]))
;          for i = 0, coordinates[3]-coordinates[2] do max_y[i] = max( reform(data[*,i,maxsub/(coordinates[1]-coordinates[0]+1)/(coordinates[3]-coordinates[2]+1)]))
;          xframeplot  = max(max_x)
;          yframeplot  = max(max_y)
;        end
    endcase


ir_trace_t = reform(ir.data[xframeplot,yframeplot,*])
ir_trace_pv = reform(ir.data[xframeplot,*,maxframe])
ir_trace_ph = reform(ir.data[*,yframeplot,maxframe])
bgtrace    = bgdata[xframeplot,yframeplot]
bgtrace_pv = bgdata[xframeplot,*]
bgtrace_ph = bgdata[*,yframeplot]

case material of 
  'Sn'  : begin
            ;e_var   = sn_e_var(cal)
            e_var  = sn_e_var2(cal_temp)
          end
  'W'   : e_var = w_e_var(cal)
endcase
            
;e_var = sn_e_var(cal) ; one can use sn_e_var(cal) for sn
;;e_var = w_e_var(cal) ; one can use w_e_var(cal) for tungsten
;e_var2 = sn_e_var2(cal_temp)
;cg_newwindow,title = 'calibration_comparison'
;cgplot, cal.temp-273.15, e_var,/add
;cgplot, cal_temp, e_var2,/add,/over, col='red',line = 2

reference_dl = (cal_dl - cal_bg)*e_var*trans

ir_temp2 = interpol(cal_temp, reference_dl,ir_trace_t-bgtrace)
ir_prof_v2 = interpol(cal_temp, reference_dl,ir_trace_pv-bgtrace_pv)
ir_prof_h2 = interpol(cal_temp, reference_dl,ir_trace_ph-bgtrace_ph)


lcal = local_cal_init(cal,e_var,ir_trace_t(0),25,trans)

ir_temp = local_cal(lcal,ir_trace_t)
ir_prof_v = local_cal(lcal,ir_trace_pv)
ir_prof_h = local_cal(lcal,ir_trace_ph)


print,transpose([[ir_time],[reform([ir_temp])],[reform([ir_temp2])]])

;more, transpose([[ir_time],[reform([ir_temp])]])
temp_centre = transpose([[ir_time],[reform([ir_temp])]])


cg_newwindow,title = 'Time trace T (C) at [xframeplot,yframeplot]'
cgplot,ir_time,ir_temp2,/add
cgplot,ir_time,ir_temp,/over,/add,col='red',line = 2
;Long's mark: Exchange of colors and sequence for Tom's and Dirk's output, for a good scaling of the figure 

cg_newwindow, tit = 'Horizontal T (C) at max frame'
cgplot,ir_time,ir_prof_h2,/add
cgplot,ir_time,ir_prof_h,/over,/add,col='red',line = 2

cg_newwindow, tit = 'Vertical T (C) at max frame'
cgplot,ir_time,ir_prof_v2,/add
cgplot,ir_time,ir_prof_v,/over,/add,col='red',line = 2

cg_newwindow, tit = 'Raw time trace at [xframeplot,yframeplot]'
cgplot, ir_time, ir_trace_t,/add



;print, 'saving '+path+strtrim((strsplit(file,'.',/extract))[0],2)+'_time_evol_centre.sav'
;;openw, lun, path+strtrim((strsplit(file,'.',/extract))[0],2)+'time_evol_centre.sav',/get_lun
;;printf, lun, transpose([[ir_time],[reform([ir_temp])]])
;;close, lun
;;free_lun, lun
;save, temp_centre,file = path+strtrim((strsplit(file,'.',/extract))[0],2)+'_time_evol_centre.sav'
;
print, 'Done!'
;
;




end

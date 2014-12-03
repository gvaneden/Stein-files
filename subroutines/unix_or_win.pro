function unix_or_win, string

if !version.os_family eq 'unix' then string = strjoin(strsplit(string,'\',/extract,/preserve_null),'/',/single) 
if !version.os_family eq 'Windows' then string = strjoin(strsplit(string,'/',/extract,/preserve_null),'\',/single) 

return, string

end
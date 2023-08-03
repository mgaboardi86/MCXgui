% [data] = MCX_LoadData(filename,checkbox1,checkbox2)
% checkbox1 = 1 or 0 (invert y, ey columns in .dat files) -- not used anymore
% checkbox2 = 1 or 0 (reflectivity or diffraction) -- 
function [data,type] = MCX_LoadData(filename,checkbox2,colx,coly)
switch filename(end-2:end)
    case('csv')
      type='Rietveld';
      fid = fopen(filename,'r');            
      dd = textscan(fid, '%f,%f,%f,%f,%f,%f', 'CommentStyle','"');
      fclose(fid);
      data=[dd{1} dd{2} dd{3} dd{4} dd{5} dd{6}];
      
    case('dat')
      if checkbox2==0 % normal data
        try     
            fid = fopen(filename,'r');            
%             dd = textscan(fid, '%f%f%f%f%f%f%f%f%f%f', 'CommentStyle',{'#','X'});
            dd = textscan(fid,'%f %f %f %f','CommentStyle','#');
            tth = dd{colx}; 
            I = dd{coly}; 
            if coly==2
                TotCountsCol=3; 
            elseif coly==3
                TotCountsCol=2; 
            
            elseif coly==4 % when standard reflectivity data are saved as #Q, th, tth, I, I0, I1, mm-Al, scale, I1/I0 
                TotCountsCol=5; 
            end
            try                        
                Iion = dd{TotCountsCol};
            catch e
                disp([e.message ' Try using ''reflectivity'' checkbox option'])
            end
            fclose(fid);
        catch e
            disp(e.message);
        end        
        try
            data = [tth'; I'; Iion']';
        catch e
            data = [tth'; I'; 1e4*ones(length(I),1)]';
            disp(e.message)
        end
      elseif checkbox2==1 % reflectivity
        try
        	fid = fopen(filename,'r');            
                dd = textscan(fid, '%f%f%f%f%f%f%f%f%f%f', 'CommentStyle','#');
                data(:,1) = dd{colx}; 
                data(:,2) = dd{coly}; 
                data(:,3) = dd{coly}*std(dd{coly}) ./ sqrt( length( dd{coly} ));
            fclose(fid);
            
        catch e
            disp(e.message)
            data = importdata(filename);
        end
        
      end
        
            
    case({'xye'; 'ras'})
        fid = fopen(filename,'r');
        filepos = 0;
        tline = fgetl(fid);
        try
            while ~isempty(tline) && any(strcmpi(tline(1),{'#','%','<','/','*','\'}))
                filepos = ftell(fid);
                tline = fgetl(fid);
            end
        catch e
            disp(e.message)
        end
        dd = textscan(fid, '%f%f%f', 'CommentStyle','#');
            tth = dd{1}; 
            I = dd{2}; 
            Iesd = dd{3};
        fclose(fid);
        data = [tth'; I'; Iesd']';
        type = 'diff';
    
    case('.xy')
    
        fid = fopen(filename,'r');
        dd = textscan(fid, '%f%f', 'CommentStyle','#');
        tth = dd{1}; I = dd{2};
        fclose(fid);

        Iesd = I*std(I) ./ sqrt( length( I ));

        data = [tth'; I'; Iesd']';
        
    case('gss')
        fid = fopen(filename,'r');
        for k=1:10
            head = fgetl(fid); 
        end
        dd=textscan(fid,'%f%f%f','CommentStyle',{'#'});        
        tth=dd{1}; I=dd{2}; Iesd=dd{3};
        fclose(fid);
        data = [tth'; I'; Iesd']';
        type = 'diff';   
        
end
if checkbox2==0
    type = 'diff';
elseif checkbox2==1
    type = 'reflectivity';
end

if filename(end-2:end)=='csv'
    type = 'Rietveld';
end



% switch filename(end-2:end)
% case('dat')
%     if checkbox1 == 0 && checkbox2 == 0     % equally stepped, PXRD data
%         type = 'diff';
%         try     
%             fid = fopen(filename,'r');
%             dd = textscan(fid, '%f%f%f%f%f', 'CommentStyle','#');
%             tth = dd{colx}; I = dd{coly}; Iesd = sqrt(dd{colx})./dd{coly};
%             fclose(fid);
%         catch e
%             disp(e.message);
%         end
%         
%     elseif checkbox1 == 0 && checkbox2 == 1 % equally stepped, Reflectivity data
%         type = 'reflectivity'; 
%         a = importdata(filename,' ',3);
%         try
%             tth = a.data(:,1);  I = a.data(:,4);  Iesd = min(I)*1e-3*(ones(length(I),1)); 
%         catch e
%             e.message
%             msgbox('Invalid format: try to check/uncheck some options (Invert Columns/Reflectivity?)!')
%         end
%         
%     elseif checkbox1 == 1 && checkbox2 == 0 % continuously stepped, PXRD data
%         
%         type = 'diff';
%         try
%             fid = fopen(filename,'r');
%             dd = textscan(fid, '%f%f%f%f%f', 'CommentStyle','#');
%             tth = dd{1}; I = dd{3}; Iesd = sqrt(dd{3})./dd{2};
%             fclose(fid);
%         catch e
%             e.message
%             msgbox('Invalid format: try to check/uncheck some options (Invert Columns/Reflectivity?)!')
%         end
%     elseif checkbox1 == 1 && checkbox2 == 1 % unknown format
%         type = 'unknown';
%             msgbox('Invalid format: try to check/uncheck some options (Invert Columns/Reflectivity?)!')
%         return
%     end
%     
%         
%     data = [tth'; I'; Iesd']';
% 
% case('xye')
%     fid = fopen(filename,'r');
%     filepos = 0;
%     tline = fgetl(fid);
%     try
%     	while ~isempty(tline) && any(strcmpi(tline(1),{'#','%','<','/','*','\'}))
%             filepos = ftell(fid);
%             tline = fgetl(fid);
%         end
%     catch e
%         disp(e.message)
%     end
%     dd = textscan(fid, '%f%f%f', 'CommentStyle','#');
%     tth = dd{1}; I = dd{2}; Iesd = dd{3};
%     fclose(fid);
%     data = [tth'; I'; Iesd']';
%     type = 'diff';
%     
% case('.xy')
%     
%     fid = fopen(filename,'r');
%     dd = textscan(fid, '%f%f', 'CommentStyle','#');
%     tth = dd{1}; I = dd{2};
%     fclose(fid);
%     
%     Iesd = I*std(I) ./ sqrt( length( I ));
%     
%     data = [tth'; I'; Iesd']';
%     
%     type = 'diff';
% end


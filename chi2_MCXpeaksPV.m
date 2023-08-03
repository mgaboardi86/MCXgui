function chi2 = chi2_MCXpeaksPV(guess,data)

par=guess;
n = length(par(1,4:end-3));  % number of peaks

    par0{1} = par(1);        % lambda
    par0{2} = par(2) ;       % eta
    par0{3} = par(3) ;       % zero
    par0{4} = par(4 : n+3) ; % Intensities
    par0{5} = par(end-2:end);  % FWHMs [U,V,W]

x = data(:,1);      
y_exp = data(:,2);     

yth = MCX_multiPV_Caglioti(x,par0)'; % uses par0=[A,x0,eta,U,V,W] as unique FWHM pars for both G and L

%%(((1))) Method standard %%%%%%%%%
   % chi2 = sum((y_exp - yth).^2);    % standard chi2 (best fit)

   
   
%%(((2))) method Rwp %%%%%%%
for i=1:length(y_exp)
   if y_exp(i) == 0
       y_exp(i) = 1e-6*max(y_exp);
   end
end
wi = real(1./sqrt(y_exp));
chi2 =  real(   sqrt( sum(wi.*(y_exp-yth).^2)/sum(wi.*(y_exp.^2)) )     )  ;    % Rwp

end





% function chi2 = chi2_MCXpeaksPV(guess,data)
% par=guess;
% n = length(par(1,4:end-3));    % number of peaks
% 
%     par0{1} = par(1);          % lambda
%     par0{2} = par(2) ;         % eta
%     par0{3} = par(3) ;         % zero
%     par0{4} = par(4 : n+3) ;   % Intensities
%     par0{5} = par(end-2:end);  % FWHMs [U,V,W]
%     %par0{6} = par(end);       % extra zero correction (not used)
% 
% x = data(:,1);      
% y_exp = data(:,2);     
% 
% yth = MCX_multiPV_Caglioti(x,par0)'; % uses par0=[A,x0,eta,U,V,W] as unique FWHM pars for both G and L
% 
% %%(((1))) Method standard %%%%%%%%%
%    % chi2 = sum((y_exp - yth).^2);    % standard chi2 (best fit)
% 
%    
%    
% %%(((2))) method Rwp %%%%%%%
% for i=1:length(y_exp)
%    if y_exp(i) == 0
%        y_exp(i) = 1e-6*max(y_exp);
%    end
% end
% wi = real(1./sqrt(y_exp));
% chi2 =  real(   sqrt( sum(wi.*(y_exp-yth).^2)/sum(wi.*(y_exp.^2)) )     )  ;    % Rwp
% 
% end
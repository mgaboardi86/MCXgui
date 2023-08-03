function [FitParam, ErrParam, a] = MCX_Silicon(Energy,zero,filename,Method,hInvertCols)
% Do stuff that takes a long time.....
SiliconHKL; 
BarMsg = waitbar(0,'Please wait Until fit is completed...'); 
waitbar(0.1,BarMsg)
clear globals
lambda = 12.39842/Energy;
waitbar(0.15,BarMsg)
[a,~] = MCX_LoadData(filename,hInvertCols,0);
tthMax = max(a(:,1)); dMIN = lambda/(2*sind(tthMax/2)); Npeaks=1;
if dMIN > dhkl_Si(end) 
    while dhkl_Si(Npeaks)>= dMIN
        Npeaks = Npeaks+1; 
    end
    Npeaks = Npeaks-1;
else
        Npeaks = length(dhkl_Si);
end
disp(['First ' int2str(Npeaks) ' peaks selected'])

switch Method
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       Modified Caglioti Pseudo Voigt
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case('Caglioti')
        
I = max(0.4*a(:,2))*ones(1,Npeaks);
%I = 0.001*max(a(:,2))*Int_Si(1:Npeaks,1)';

disp(['Starting fit of the first ' int2str(length(I)) ' peaks:'])
tth0 = d2theta(dhkl_Si(1:Npeaks),lambda); tth0 = tth0'; I = I.*exp(-0.025*tth0);

figure; hold on; plot(a(:,1),a(:,2),'ko'); movegui(gcf,'northeast')

par{1} = lambda; par{2} = 0.5; par{3} = zero; par{4} = I;  par{5} = [1e-6 -1e-7 0.001]; % [U, V, W]
disp([ 'I = [' num2str(par{4}) ']' ])
disp(par{4})
waitbar(0.25,BarMsg)

guess=[par{:}];

global stepbounds; 
for i=1:(3+length(I)+3)
    stepbounds(i,1:4) = [i 1 0 0]; %init stepbounds     
end
    stepbounds(1,:) = [1 1 0.98*guess(1) 1.02*guess(1)];        % lambda restraint
    stepbounds(2,:) = [2 1 0.01 0.99];                          % Lor-Gauss mixing restraint
    stepbounds(3,:) = [3 1 guess(3)-0.15 guess(3)+0.15];        % zero restraint
for i=1:length(I)
    stepbounds(3+i,2:4) = [1  1e-3 1e6];              % intensities restraints
end
    stepbounds(3+length(I)+1,1:4) = [3+length(I)+1 0 1e-6 2];   % U
    stepbounds(3+length(I)+2,1:4) = [3+length(I)+2 0 -1 -1e-6]; % V
    stepbounds(3+length(I)+3,1:4) = [3+length(I)+3 1 1e-6 2];   % W
disp(stepbounds)
pp = plot(a(:,1),MCX_multiPV_Caglioti(a(:,1),par) ,'-','Color',[0.35 0.13 0.73],'linewidth',1.2); hold on; box on; xlabel('2\theta (deg)'); ylabel('Intensity (a.u.)')

l1 = legend(filename,'guess');
set(l1,'Interpreter','none');

 for i=1:length(par{5})
     plot([d2theta(dhkl_Si(1:Npeaks),lambda) d2theta(dhkl_Si(1:Npeaks),lambda)],[-max(a(:,2))*(0.1) -max(a(:,2))*0.12],'k-','linewidth',2); hold on
 end
 l1 = legend(filename,'guess');
waitbar(0.35,BarMsg)
% call to MINUIT

[FitParam, ErrParam, ~] = fminuit('chi2_MCXpeaksPV',guess,a,'-b');
waitbar(1,BarMsg)
delete(BarMsg);
delete(pp)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       GSAS function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case('GSAS')
I = .5*max(a(:,2))*ones(1,Npeaks);
%I = 0.005*max(a(:,2))*Int_Si(1:Npeaks,1)';
disp(['Starting fit of the first ' int2str(Npeaks) ' peaks:'])
tth0 = d2theta(dhkl_Si(1:Npeaks),lambda); tth0 = tth0'; %I = I.*exp(-0.02*tth0);

figure; hold on;plot(a(:,1),a(:,2),'ko'); movegui(gcf,'northeast')
par = {lambda, zero, [5*Int_Si(1:Npeaks)'],[0.0, 0, 0.00001, 0.05, 0.1]};
%par{1} = lambda; par{2} = zero; par{3} = I;  par{4} = [0.1 -0.01 .001 0.1 0.0]; % [U, V, W, X, Y];
disp([ 'I = [' num2str(par{3}) ']' ])

waitbar(0.25,BarMsg)

guess=[par{:}];

global stepbounds; 
for i=1:(2+Npeaks+5)
    stepbounds(i,1:4) = [i 1 0 0]; % init stepbounds     
end
    stepbounds(1,:) = [1 1 0.95*guess(1) 1.05*guess(1)];        % lambda restraint
    stepbounds(2,:) = [2 1 -0.25 0.25];        % zero restraint
for i=1:Npeaks
    stepbounds(2+i,2:4) = [1  1e-6*par{3}(i) 1e6*par{3}(i)];              % intensities restraints
end
    stepbounds(2+Npeaks+1,1:4) = [2+length(par{3})+1 1 0.0 1];  % U
    stepbounds(2+Npeaks+2,1:4) = [2+length(par{3})+2 0 -1 0]; % V
    stepbounds(2+Npeaks+3,1:4) = [2+length(par{3})+3 1 0 1]; % W
    stepbounds(2+Npeaks+4,1:4) = [2+length(par{3})+4 1 0.0 1];    % X
    stepbounds(2+Npeaks+5,1:4) = [2+length(par{3})+5 1 0.0 1.5];    % Y     

pp = plot(a(:,1),MCX_multiPV_GSAS(a(:,1),par) ,'-','Color',[0.35 0.13 0.73],'linewidth',1.2); hold on; box on; xlabel('2\theta (deg)'); ylabel('Intensity (a.u.)')

l1 = legend(filename,'guess');
set(l1,'Interpreter','none');

 for i=1:length(par{4})
     plot([d2theta(dhkl_Si(1:Npeaks),lambda) d2theta(dhkl_Si(1:Npeaks),lambda)],[-max(a(:,2))*(0.1) -max(a(:,2))*0.12],'k-','linewidth',2); hold on
 end
legend(filename,'guess');
waitbar(0.35,BarMsg)
% call to MINUIT

[FitParam, ErrParam, ~] = fminuit('chi2_multiPV_GSAS',guess,[a(:,1),a(:,2)],'-b');
waitbar(1,BarMsg)
delete(BarMsg);
delete(pp)        
end

end
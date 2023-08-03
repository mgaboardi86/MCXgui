% y = multiPseudoVoigt(2theta,par) = multiPseudoVoigt(2theta,{[I], lambda, eta, [FWHM]})
% where:
% par{1} = lambda (Å)
% par{2} = eta (0-1)     
% par{3} = zero
% par{4} = I [... Intensities(i) ...]
% par{5} = 0.03*ones(1,length(par{1})) [...FWHM(i)...]
function y = MCXpeaksPV(tth,par)
SiliconHKL; %H,K,L indexes
a_Si = 5.43119; % Silicon standard lattice parameter RT
tth_c = zeros(1,length(par{4})); % init "calculated 2theta's array"
lambda = par{1};

for i=1:length(par{4}) %for every peak
    dhkl = a_Si / sqrt(h(i)^2 + k(i)^2 + l(i)^2);
    tth_c(i) = real(2*asind( lambda./(2*dhkl)  )) + par{3};
    %tth_c(i) = real( 2*asin( (lambda/(4*a_Si))*(h(i)+k(i)+l(i))^2 ) );
    %par{i} = [100 tth_c(i) 0.5 .1]; %A(i) w(i) eta(i) FWHM(i)
end

M = ones(length(par{4}),length(tth));    % a PV for each row
for i = 1:length(par{4})  % PV index
    M(i,:) =  pseudoVoigt(tth,[par{4}(i) tth_c(i) par{2} par{5}(i)]); 
end

y = sum(M);
end
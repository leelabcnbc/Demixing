function [A,C] = update_spatial_lasso(Y, A, C, IND, sn, q, maxIter, options)

%% update spatial components using constrained non-negative lasso with warm started HALS 

% input: 
%       Y:    d x T,  fluorescence data
%       A:    d x K,  spatial components + background
%       C:    K x T,  temporal components + background
%     IND:    K x T,  spatial extent for each component
%      sn:    d x 1,  noise std for each pixel
%       q:    scalar, control probability for FDR (default: 0.975)
% maxIter:    maximum HALS iteration (default: 40)
% options:    options structure

% output: 
%   A: d*K, updated spatial components 

% Author: Eftychios A. Pnevmatikakis

%% options for HALS

memmaped = isobject(Y);

norm_C_flag = false;
tol = 1e-3;
repeat = 1;
defoptions = CNMFSetParms;
if nargin < 8; options = defoptions; end
if nargin < 7 || isempty(maxIter); maxIter = 40; end
if nargin < 6 || isempty(q); q = 0.975; end
if   nargin<5 || isempty(sn); sn = get_noise_fft(Y,options);  end;
if   nargin<4 || isempty(IND); IND = determine_search_location(A,options.search_method,options); end 
if nargin < 2 || isempty(A); 
    A = max(Y*C'/(C*C'),0);
end

if norm_C_flag
    nC = sqrt(sum(C.^2,2));
    A = bsxfun(@times,A,nC);
    C = bsxfun(@times,C,1./nC(:));
end

[d,K] = size(A);

nr = K - options.nb;
IND(:,nr+1:K) = true;
T = size(C,2);

if memmaped
    %d = size(A,1);
    step_size = 2e4;
    YC = zeros([d,K]);    
    for t = 1:step_size:d
        YC(t:min(t+step_size-1,d),:) = double(Y.Yr(t:min(t+step_size-1,d),:))*C';
    end
else
    YC = Y*C';
end

%% initialization 
A(~IND) = 0; 
U = YC; 
V = C*C'; 
cc = diag(V);   % squares of l2 norm for all components 

%% updating (neuron by neuron)
miter = 0;
while repeat && miter < maxIter
    A_ = A;
    for k=1:K        
        tmp_ind = IND(:, k);
        if k <= nr
            lam = sqrt(cc(k)); %max(sqrt(cc(tmp_ind)));
        else
            lam = 0;
        end
        LAM = norminv(q)*sn*lam;
        ak = max(0, A(tmp_ind, k)+(U(tmp_ind, k) - LAM(tmp_ind) - A(tmp_ind,:)*V(:, k))/cc(k)); 
        A(tmp_ind, k) = ak; 
    end
    miter = miter + 1;
    repeat = (sqrt(sum((A(:)-A_(:)).^2)/sum(A_(:).^2)) > tol);    
end

f = C(nr+1:end,:);
Yf = YC(:,nr+1:end); %Y*f';
b = double(max((double(Yf) - A(:,1:nr)*double(C(1:nr,:)*f'))/(f*f'),0));
A(:,nr+1:end) = b;
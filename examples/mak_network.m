%% ZAT 2019, ICL, example form Papachristodoulou et al. 2007 (ACC)

%%
Y = [1 0 1 0 0;
    0 2 0 0 1;
    0 0 1 0 0;
    0 0 0 1 0;
    0 0 0 0 1];

Ak = zeros(size(Y,2)) ;

Ak(2,1) = 0.3386;
Ak(3,1) = 0.8244;
Ak(1,5) = 0.8496;
Ak(2,5) = 0.4290;
Ak(5,3) = 0.7364;
Ak(3,4) = 0.563;

% normalize Ak
Ak = Ak-diag(sum(Ak));

M = Y*Ak;

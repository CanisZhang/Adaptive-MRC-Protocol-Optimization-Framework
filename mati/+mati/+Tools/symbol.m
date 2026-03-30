function output = symbol(input)
%% This function outputs ASCII symbols that could be used in scripts, legends, etc. without the need of latex interpreter. 
% 
% --------------------------------------------------------------------------------------------------------------------------------------------------
% The following symbols are supported so far
% Greeks
% Α α, Β β, Γ γ, Δ δ, Ε ε, Ζ ζ, Η η, Θ θ, Ι ι, Κ κ, Λ λ, Μ μ, Ν ν, Ξ ξ, Ο ο, Π π, Ρ ρ, Σ σ/ς, Τ τ, Υ υ, Φ φ, Χ χ, Ψ ψ, Ω ω
% symbols
% degree: º (used in temperature: ºC or angles)
% 
% --------------------------------------------------------------------------------------------------------------------------------------------------
% Author: Junzhong "JZ" Xu
% 
% --------------------------------------------------------------------------------------------------------------------------------------------------


    switch input
        % Greeks
        case 'Alpha',                  output = 'A' ;               % latex: A
        case 'alpha',                  output = 'α' ;                % latex: \alpha
        case 'Beta',                    output = 'Β' ;               % latex: B
        case 'beta',                    output = 'β' ;                % latex: \beta
        case 'Gamma',               output = 'Γ' ;               % latex: \Gamma 
        case 'gamma',                output = 'γ' ;               % latex: \gamma
        case 'Delta',                   output = 'Δ' ;               % latex: \Delta
        case 'delta' ,                   output = 'δ' ;               % latex: \delta 
        case 'Epsilon' ,               output = 'Ε' ;               % latex: E
        case 'epsilon' ,               output = 'ε' ;                % latex: \epsilon 
        case 'Zeta' ,                    output = 'Ζ' ;               % latex: Z 
        case 'zeta' ,                    output = 'ζ' ;                % latex: \zeta 
        case 'Eta' ,                      output = 'Η' ;              % latex: H 
        case 'eta' ,                     output = 'η' ;                % latex: \eta 
        case 'Theta' ,                 output = 'Θ' ;               % latex: \Theta 
        case 'theta' ,                  output = 'θ' ;                % latex: \theta 
        case 'Iota' ,                    output = 'Ι' ;                 % latex: I 
        case 'iota' ,                     output = 'ι' ;                % latex: \iota 
        case 'Kappa' ,                output = 'Κ' ;               % latex: K 
        case 'kappa' ,                 output = 'κ' ;               % latex: \kappa 
        case 'Lambda' ,             output = 'Λ' ;               % latex: \Lambda  
        case 'lambda' ,              output = 'λ' ;                % latex: \lambda  
        case 'Mu' ,                     output = 'Μ' ;               % latex: M 
        case 'mu' ,                     output = 'μ' ;               % latex: \mu 
        case 'Nu' ,                      output = 'Ν' ;               % latex: N 
        case 'nu' ,                      output = 'ν' ;                % latex: \nu 
        case 'Xi' ,                       output = 'Ξ' ;               % latex: \Xi 
        case 'xi' ,                        output = 'ξ' ;               % latex: \xi 
        case 'Omicron' ,             output = 'Ο' ;              % latex: O 
        case 'omicron' ,             output = 'ο' ;                % latex: o 
        case 'Pi' ,                       output = 'Π' ;               % latex: \Pi 
        case 'pi' ,                       output = 'π' ;               % latex: \pi 
        case 'Rho' ,                   output = 'Ρ' ;               % latex: P 
        case 'rho' ,                     output = 'ρ' ;               % latex: \rho 
        case 'Sigma' ,                output = 'Σ' ;               % latex: \Sigma 
        case 'sigma' ,                output = 'σ' ;                % latex: \sigma 
        case 'varsigma' ,           output = 'ς' ;                 % latex: \varsigma 
        case 'Tau' ,                    output = 'Τ' ;                % latex: T 
        case 'tau' ,                     output = 'τ' ;                % latex: \tau  
        case 'Upsilon' ,              output = 'Υ' ;                % latex: \Upsilon  
        case 'upsilon' ,              output = 'υ' ;                 % latex: \upsilon  
        case 'Phi' ,                    output = 'Φ' ;                % latex: \Phi 
        case 'phi' ,                    output = 'φ' ;                 % latex: \phi 
        case 'Chi' ,                   output = 'Χ' ;                 % latex: X 
        case 'chi' ,                    output = 'χ' ;                 % latex: \chi 
        case 'Psi' ,                    output = 'Ψ' ;                % latex: \Psi 
        case 'psi' ,                    output = 'ψ' ;                 % latex: \psi 
        case 'Omega' ,             output = 'Ω' ;                 % latex: \Omega 
        case 'omega' ,              output = 'ω' ;                 % latex: \omega 

        % other symbols
        case 'degree' ,             output = 'º' ;                   % latex: \degree 
    end









end

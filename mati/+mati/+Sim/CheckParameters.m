function [status, msg] = CheckParameters(structure, pulse)
%% check simulation parameters
%

    %% preliminary
    status = 0 ; msg = 'All parameters seem ok.' ; 

    %% ********************* test the consistancy of parameters ***************
    % CFL condition, for explicit discretization scheme
    if max(max(structure.D).*pulse.dt./structure.dr.^2) > 0.5/structure.Ndim
        status = 1 ; 
        msg = ['D*dt/dx^2=',num2str(structure.D*pulse.dt/max(structure.dr)^2),' too large! This is a violation of the CFL condition. '] ; 
    end
    
    % q_dx effect
    if max(pulse.gamma.*max(pulse.gShapeIntegral).*pulse.G.*structure.dr ./pi) > 0.101
        status = 2 ; 
        msg = ['q*dx/pi=', num2str(pulse.gamma * max(pulse.gShapeIntegral) *pulse.G* max(structure.dr)/pi),'. The spatial step is too large!'] ; 
    end
    
    % OGSE gradient 
    if strcmp(pulse.shape, 'sin') || strcmp(pulse.shape, 'cos') || strcmp(pulse.shape, 'tcos') || strcmp(pulse.shape, 'tsin')
        % OGSE period cannot be too short (less than 20*dt)
        if pulse.T < 20*pulse.dt
            status = 3 ; 
            msg = ['T=', num2str(pulse.T/pulse.dt),' dt. The temporal step is too small! '] ; 
        end
        
        if pulse.delta < pulse.T
            status = 4 ; 
            msg = 'The wavform period T should be smaller to equal to the gradient duration δ. ' ; 
        end
    end
    
    % check pulse.grad
    if sum(pulse.gShape) > 1
        status = 5 ; 
        msg = 'The pulse.grad error! The pulse sequence does not have two identical gradients on both side of the 180 RF pulse so the spins can not rephase completely. ' ; 
    end




end


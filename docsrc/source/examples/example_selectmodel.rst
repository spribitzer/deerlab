.. highlight:: matlab
.. _example_selectmodel:

*************************************
Example - Parametric model selection
*************************************


.. code-block:: matlab

    %===========================================================
    % DeerAnalyis2
    % Example: Optimal parametric model selection
    % Optimize the choice of parametric model for a given signal.
    %===========================================================

    clear,clc

    %Parameters
    %-------------------------
    N = 300;
    dt = 0.008;
    param0 = [3 0.3 5 0.3 0.5];
    NGauss = 6;
    Models = {@onerice,@tworice,@threerice,...
              @onegaussian,@twogaussian,@threegaussian};

    %Preparation
    %-------------------------
    t = linspace(0,dt*N,N);
    r = time2dist(t);
    P = twogaussian(r,param0);
    K = dipolarkernel(t,r);
    %Generate dipolar signal with noise
    S = dipolarsignal(t,r,P,'NoiseLevel',0.1);

    %Run parametric model selection
    %-------------------------------
    [optIdx,metric] = selectmodel(Models,S,r,K,'aic');

    %Fit distance distribution with optimal model
    Pfit = fitparamodel(S,K,r,Models{optIdx});

    %Plot results
    %-------------------------
    figure(8),clf

    subplot(131),hold on
    plot(t,S,'k','LineWidth',1)
    plot(t,K*Pfit,'b','LineWidth',1.5)
    grid on, box on, axis tight
    xlabel('Time [\mus]'), ylabel('S(t)')
    legend('Truth','Fit')

    subplot(132),hold on
    plot(r,P,'k','LineWidth',1.5)
    plot(r,Pfit,'b','LineWidth',1.5)
    grid on, box on, axis tight
    xlabel('Distance [nm]'), ylabel('P(r)')
    legend('Truth','Fit')

    subplot(133),hold on
    plot(metric,'b-o','LineWidth',1.5)
    legend('AIC')
    grid on, box on,axis tight
    ylabel('Metric')
    for i=1:length(Models)
    tags{i} = func2str(Models{i});
    end
    set(gca,'xtick',1:length(Models),'xticklabel',tags)
    xtickangle(45)

.. figure:: ../images/example_selectmodel1.svg
    :align: center
m1 = [-1 -1]';


var1 = 0.75;
var2 = 0.25;
R1 = rotmat2d(pi/6);
C1 = R1*[var1 0;0 var2]*R1';


m2 = [1 1]';
 
var1b = 0.75;
var2b = 0.25;
R2 = rotmat2d(-pi/6);
C2 = R2*[var1b 0;0 var2b]*R2';
%m2 = m1;
%C2 = C1;



g1 = gk( C1, m1 );
g1 = g1.cpdf;
g2 = gk( C2, m2 );
g2 = g2.cpdf;

sampsize = 5000;

samp1 = g1.gensamples(sampsize);

p1 = particles('states', samp1, 'weights', ones( size(samp1,2) ,1 )/sampsize ,'labels', 1);
p1.subblabels( ones(1,sampsize) );
p1.blmap(2) = 2;
p1.blabels = [p1.blabels;p1.blabels];
p1.updatekdebwsblabh('nonsparse');

phd1 = phd;
phd1.mu = 0.9;
phd1.s.particles = p1;


samp2 = g2.gensamples(sampsize);

p2 = particles('states', samp2, 'weights', ones( size(samp2,2),1 )/sampsize ,'labels', 1);
p2.subblabels( ones(1,sampsize) );
p2.blmap(2) = 2;
p2.blabels = [p2.blabels;p2.blabels];
p2.updatekdebwsblabh('nonsparse');


phd2 = phd;
phd2.mu = 0.9;
phd2.s.particles = p2;

card1 = [0.1 0.9 0 0 0]';
card2 = card1;

fusionobj = mcmoemd;

fusionobj.setcards( card1, card2 );
fusionobj.setinputs( phd1, phd2 );

fusionobj.fusewemd;


omegaval = fusionobj.optomega;

z = zomegagauss( m1, C1, m2, C2, omegaval );

disp(sprintf('Z_omega : Exact value vs. MC Estimate = %g vs. %g', z, fusionobj.zest))

% Find the Gaussian EMD
S_omega = (1-omegaval)*(C1)^(-1) + omegaval*(C2)^(-1);
Sigma_omega = S_omega^(-1);
m_omega = Sigma_omega*( (1-omegaval)*(C1)^(-1)*m1 + omegaval*(C2)^(-1)*m2 );

figure
hold on
plotset( m1, 'axis', gca ,'options','''Color'',[0 0 0]');
plotcov( m1, {C1}, 'axis', gca ,'options','''Color'',[0 0 0]');

plotset( m2, 'axis', gca ,'options','''Color'',[0 0 1]');
plotcov( m2, {C2}, 'axis', gca ,'options','''Color'',[0 0 1]');


plotset( m_omega, 'axis', gca ,'options','''Color'',[1 0 1]');
plotcov( m_omega, {Sigma_omega}, 'axis', gca ,'options','''Color'',[1 0 1]');

fusionobj.outp.scplot( 'axis', gca,'options','''Color'',[1 1 0],''linestyle'',''none'',''marker'',''.''','scale', -2)

zz = fusionobj.outp.s.particles.evaluate;
figure
hold on
grid on
plot3( fusionobj.outp.s.particles.states(1,:), fusionobj.outp.s.particles.states(2,:), zz, '.b')
xlabel('x')
ylabel('y')

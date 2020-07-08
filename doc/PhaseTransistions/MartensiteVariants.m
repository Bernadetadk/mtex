%% Martensite Variants
%
%%
% In this section we discuss the Austenite to Ferrite phase transition. We
% do so at hand of an EBSD data set of the famous Emsland metereoid. 

plotx2east

% import the ebsd data
mtexdata emsland

% extract crystal symmetries
cs_bcc = ebsd('Fe').CS;
cs_aus = ebsd('Aus').CS;

% recover grains
ebsd = ebsd('indexed');

[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd,'angle',5*degree);
ebsd(grains(grains.grainSize<=2)) = [];
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd,'angle',5*degree);

grains = smooth(grains,4);

%%
% The following lines plots the Martensite phase colorized according to its
% orientation and the Austenite phase in blue.

plot(ebsd('Fe'),ebsd('Fe').orientations)
hold on
plot(grains.boundary,'lineWidth',2,'lineColor','gray')
plot(grains('Aus'),'FaceColor','blue','edgeColor','b','lineWidth',1,'DisplayName','Austenite')
hold off

%%
% We observe quite many small austenite grains surrounding the ferrite
% grains. Considering only the parent austenite phase and plotting the
% orientations into an axis angle plot

plot(ebsd('Aus').orientations,'axisAngle')

%%
% we observe that they concentrated around one single orientations, i.e.,
% the all measurements most likely originates from a single austenite
% crystal. We can find this parent austenite orientation by taking the
% <orientation.mean.html |mean|> and compute the fit by the command
% <orientation.std.html |std|>

parenOri = mean(ebsd('Aus').orientations)

fit = std(ebsd('Aus').orientations) ./ degree

%%
% Next we plot the martensite orientations into pole figures and plot on
% top of them the parent austenite orientation.

childOri = grains('Fe').meanOrientation;

h_bcc = Miller({1,0,0},{1,1,0},{1,1,1},cs_bcc);
h_fcc = Miller({1,0,0},{1,1,0},{1,1,1},cs_aus);

plotPDF(childOri,h_bcc,'MarkerSize',5);

nextAxis(1)
hold on
plot(parenOri * h_fcc(1).symmetrise ,'MarkerFaceColor','r')
xlabel('$(100)$','Color','red','Interpreter','latex')

nextAxis(2)
plot(parenOri * h_fcc(3).symmetrise ,'MarkerFaceColor','r')
xlabel('$(111)$','Color','red','Interpreter','latex')

nextAxis(3)
plot(parenOri * h_fcc(2).symmetrise ,'MarkerFaceColor','r')
xlabel('$(110)$','Color','red','Interpreter','latex')
hold off

drawNow(gcm)

%%
% Here we marked in red the parent austenite orientation and in blue the
% child martensite orientations. As the superposition of the martensite
% (111) pole figure and the (110) austenite pole figure sugest there seems
% to be a orientation relation ship with respect to these two
% crystallographic axes. In fact, the Kurdjumov Sachs orientation
% relationship is exactly defined by alligning the (111) axis of the
% austenite phase with the (100) axes of the martensite phase and vice
% versa. Lets define it the explicite way. We could have used also the
% command |orientation.KurdjumovSachs(cs_aus,cs_bcc)|.

KS = orientation.map(Miller(1,1,1,cs_aus),Miller(0,1,1,cs_bcc),...
      Miller(-1,0,1,cs_aus),Miller(-1,-1,1,cs_bcc));


plotPDF(variants(KS,parenOri),'add2all','MarkerFaceColor','none','MarkerEdgeColor','k','linewidth',2)

%%
% In order to quantify the fit between the Kurdjumov Sachs orientation
% relationship and the actual orientation relation ship in the data we
% compute the mean angular deviation between all parent to child
% misorientaitons and the Kurdjumov Sachs orientation relationship

% all parent to child misorientations
mori = inv(childOri) * parenOri;

% mean angular deviation in degree
mean(angle(mori, KS)) ./ degree

%fit = sqrt(mean(min(angle_outer(childOri,variants(KS,parenOri)),[],2).^2))./degree


%% Estimating the parent to child orientation relationship
%
% We may have asked ourselfs whether there is an orientation relationship
% that better fits the measured misorientations than Kurdjumov Sachs. A
% canocial candidate would be the <orientation.mean.html |mean|> of all
% misorientations

% the mean of all measured parent to child misorientations
p2cMean = mean(mori,'robust')

plotPDF(childOri,h_bcc,'MarkerSize',5);
hold on
plotPDF(variants(p2cMean,parenOri),'add2all','MarkerFaceColor','none','MarkerEdgeColor','k','linewidth',2)
hold off

% mean angular deviation in degree
mean(angle(mori, p2cMean)) ./ degree

%%
% Here we have made use of our comfortable situation to know the parent
% orientation. If the parent orientation is unknown we may still estimate
% the parent to child orientation relationship soleley from the child to
% child misorientations by the algorithm by Tuomo Nyyssönen and implemented
% in the function <calcParent2Child.html |calcParent2Child|>. This
% iterative algorithms needs as a starting point some orientation relation
% ship no too far from the actual one. Here we use the Nishiyama Wassermann
% orientation relation ship. 

% define Nishiyama Wassermann
NW = orientation.NishiyamaWassermann(cs_aus,cs_bcc);

% extract all child to child misorientations 
grainPairs = neighbors(grains('Fe'));
ori = grains(grainPairs).meanOrientation;

% estimate a parent to child orientation relationship
p2cIter = calcParent2Child(ori,NW)

% the mean angular deviation
mean(angle(mori,p2cIter)) ./degree

%%
% We observe that the parent to child orientation relationship computed
% solely from the child to child misorientations fits the actual
% orientation relationship equaly well. 
%
%% Classification of child variants
%
% Once we have determined parent orientations and a parent to child
% orientation relationship we may proceed further by classifying the child
% orientations into different variants. This is computed by the command
% <calcChildVariant.html |calcChildVariant|>.

% compute for each child orientation a variantId
[variantId, packetId] = calcChildVariant(parenOri,childOri,p2cIter);

% colorize the orientations according to the variantID
color = ind2color(variantId);
plotPDF(childOri,color,h_bcc,'MarkerSize',5);

%%
% While it is very hard to distinguish the different variants in the pole
% figure plots it becomes more clear in an axis angle plot

plot(childOri,color,'axisAngle')

%%
% A more important classification is the seperation of the
% variants into packets. 

color = ind2color(packetId);
plotPDF(childOri,color,h_bcc,'MarkerSize',5,'points',1000);

nextAxis(1)
hold on
opt = {'MarkerFaceColor','none','MarkerEdgeColor','k','linewidth',3};
plot(parenOri * h_fcc(1).symmetrise ,opt{:})
xlabel('$(100)$','Color','red','Interpreter','latex')

nextAxis(2)
plot(parenOri * h_fcc(3).symmetrise ,opt{:})
xlabel('$(111)$','Color','red','Interpreter','latex')

nextAxis(3)
plot(parenOri * h_fcc(2).symmetrise ,opt{:})
xlabel('$(110)$','Color','red','Interpreter','latex')
hold off

drawNow(gcm)

%%
% As we can see from the above pole figures the red, blue, orange and green
% orientations are distinguished by which of the symmetrically equivalent
% (111) austenite axes is aligned to the (110) martensite axis.
%%
% We may also use the packet color to distinguish different Martensite
% packets in the EBSD map.

plot(grains('Fe'),color)


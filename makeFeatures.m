%   Rx          = R*
%   D           = upside-down 
%   U           = upright
%   L           = left rotated
%   R           = right rotated
%   mu          = ? 
%   sigma       = ?
%   mu_hor      = ?_hor
%   mu_ver      = ?_ver
%   O           = O(m,n)
%   Ox          = O*
function FEAT = makeFeatures(Irgb)
%% Pre-processing
    scale = 512;    
    R = Irgb(:,:,1); 
    if size(R,1) ~= scale || size(R,2) ~= scale
        Rx  = imresize(R,[scale scale]);               
    else
        Rx = R;
    end
	[m,n] = size(Rx); % size of m = n 		
	
    t = floor(m*.2);  
  
    %figure; subplot(241); imshow(Rx); xlabel('R*');
    
%% X(1) feature	(1 THE BEST) 
    Rx_ver = Rx(:, t*2:t*3);
    Rx_hor = Rx(t*2:t*3, :);
	mu_ver = mean(mean(Rx_ver,1));
    mu_hor = mean(mean(Rx_hor,2));
    
    FEAT(:,1) = mu_ver > mu_hor;        
    
    %subplot(242);  imshow([ ones(m,t*2)*255, Rx(:, t*2:t*3), ones(m,t*2)*255]); xlabel('R*´s vertical slice');
    %subplot(243);  imshow([ ones(t*2,n)*255; Rx(t*2:t*3, :);ones(t*2,n)*255,]); xlabel('R*´s horizontal slice');
    
%%  build kernel by Santosh et al.
    sigma = 1;  mu = 0;    len = 9; theta = 30;
    X     = -sigma: ((2.*sigma)/(len-1)) : sigma;
    f     = normpdf(X,mu,sigma);
    line  = strel('line',len,0).getnhood; 
    g     = line .* f;
    g     = [zeros(floor(len/2),len); g; zeros(floor(len/2),len) ]; %adjust g to len x len size      
    g     = imrotate(g,theta,'crop');                     
    
%     subplot(244);  imshow(g); xlabel('kernel g');
    
    tam     = 25;  
    edg_hor     = double(edge(Rx_hor,'canny',.05));    
    edg_ver     = double(edge(Rx_ver,'canny',.05));    
    
%     subplot(245);  imshow(edg); xlabel('edg');

 %% X(2) feature (2 BETTER) 
 %  If 1 upright otherwise upside-down
    O_hor       = conv2( edg_hor, g, 'same' );     
    E_hor      = bwskel(bwareaopen(imbinarize(O_hor,.99),tam)); %opening and skeleton
    
    O_ver       = conv2( edg_ver, g, 'same' );     
    E_ver      = bwskel(bwareaopen(imbinarize(O_ver,.99),tam)); %opening and skeleton    

    E_left_hor  = sum(sum(E_hor(:,1:ceil(size(E_hor,2)/2)))); 
    E_right_hor = sum(sum(E_hor(:,ceil(size(E_hor,2)/2):end)));   
    

    FEAT(:,2) = E_left_hor > E_right_hor; 
    
%     subplot(246);  imshow([ ones(t,n); E; ones(t,n)]); xlabel('E');
    
%% X(3) feature  (3 BETTER) 
%  If 1 right-rotated otherwise right-rotated
    gr     = imrotate(g,90);
    Or_ver     = conv2( edg_ver, gr, 'same' );     
    Er_ver    = bwskel(bwareaopen(imbinarize(Or_ver,.99),tam));
    
    E_up_ver   = sum(sum(Er_ver(1:ceil(size(E_ver,1)/2),:))); 
    E_down_ver = sum(sum(Er_ver(ceil(size(E_ver,1)/2):end,:))); 
   
    
    Or_hor    = conv2( edg_hor, gr, 'same' );     
    Er_hor    = bwskel(bwareaopen(imbinarize(Or_hor,.99),tam));
    
 
%     subplot(247);  imshow(gr); xlabel('kernel gr');
    
    FEAT(:,3) = E_up_ver > E_down_ver; 
    

%     subplot(248);  imshow([ones(m,t) Er ones(m,t) ]); xlabel('Er');


    Rx_ver = Rx(:, t*2:t*3);
    [mv, nv] = size(Rx_ver);
    Rx_hor = Rx(t*2:t*3, :);
    [mh, nh] =  size(Rx_hor);
    
  
    FEAT(:,4) = std2(Rx_ver(1:floor(mv/2),:)) > std2(Rx_ver(floor(mv/2)+1:end,:));
    FEAT(:,5) = std2(Rx_hor(:,1:floor(nh/2))) > std2(Rx_hor(:,floor(nh/2)+1:end));
   
    
    

end
    

   
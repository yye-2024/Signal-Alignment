%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3D view of collision-free areas with different
% packet lengths in two-sender-one-receiver setup
%
% underwater space: 300 m x 300 m x 300 m
% packet length: 100 bits, 300 bits, 500 bits, 700 bits
% reference:
% Yun Ye. 2024. A Security Measure for Signal Alignment 
% based Packet Scheduling in Underwater Acoustic 
% Communications. In The 18th ACM International Conference 
% on Underwater Networks & Systems (WUWNET ’24),
% October 28–31, 2024, Sibenik, Croatia.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

interval=10; %sampling interval (m)
xrange=300; %underwater space: 300 m x 300 m x 300 m
yrange=300;
zrange=300;
x=[0:interval:xrange];
y=[0:interval:yrange];
z=[0:interval:zrange];
test_x=xrange/interval+1;
test_y=yrange/interval+1;
test_z=zrange/interval+1;

l=1000;     % communication range (m)

v=10000; % transmission data rate (bps)
c=1500; %wave velocity (m/s)


index=zeros(test_x,test_y,test_z ); %collision free: 1, collision: 0
recv_loc=[xrange/2,yrange/2,zrange/2];%legitimate receiver in the center
cluster_num=2; %number of senders
node_cluster=zeros(cluster_num,3); %locations of the senders
dist_set=zeros(cluster_num, 1); %distance between each sender and the receiving spot
recv_dist=zeros(cluster_num,1); %distance between each sender and the legitimate receiver
  

%two sender scenario, fixed location
node_cluster(1,:)=[238,75,196];
node_cluster(2,:)=[97,115,198];
for i=1:cluster_num
    dist=norm(node_cluster(i,:)-recv_loc, 2);
    recv_dist(i)=dist; %distance between each sender and the receiver
end
%set the closer sender as the 1st 
if recv_dist(1)>dist
    recv_dist(2)=recv_dist(1);
    recv_dist(1)=dist;
    dist=node_cluster(1,:);
    node_cluster(1,:)=node_cluster(2,:);
    node_cluster(2,:)=dist;
end
    

for packet_len=100:200:700 %plot figures with different packet length
    packet_mtime=packet_len/v ; %transmission time 
    packet_stime=recv_dist(1)/c+packet_mtime-recv_dist(2)/c; %transmission delay of 2nd sender
 
    figure

    axis([0 xrange 0 yrange 0 zrange]);
    ax = gca;

    grid(ax,'minor')
    grid on
    set(ax, 'YMinorTick','on', 'YMinorGrid','on','ZMinorGrid','on')

    hold on
    p1=plot3(recv_loc(1),recv_loc(2),recv_loc(3),'mo','MarkerFaceColor','g','MarkerSize',12); % receiver location
    p2=plot3(node_cluster(1,1),node_cluster(1,2),node_cluster(1,3),'mo','MarkerFaceColor','m','MarkerSize',12); % sender 1 location
    p3=plot3(node_cluster(2,1),node_cluster(2,2),node_cluster(2,3),'mo','MarkerFaceColor','y','MarkerSize',12); % sender 2 location

    xlabel('x coordinate(m)');
    ylabel('y coordinate(m)');
    zlabel('z coordinate(m)');



    count_1=0; %number of spots receive packets 1 and 2, no collision
    count_2=0; %number of spots receive packets 2 and 1, no collision
    for i=0:interval:xrange
        for j=0:interval:yrange
            for m=0:interval:zrange
                test_loc=[i, j, m]; %test different receiving spots in the entire water area
                for h=1:cluster_num
                    dist_set(h)=norm(node_cluster(h,:)-test_loc, 2); %calculate the distance from each sender to the receiving spot
                end

                    d1=dist_set(1);
                    d2=dist_set(2);

                    delay=(d1-d2)/c-packet_stime;
                    if delay<= -packet_mtime %packet 2 arrives after packet 1
                        r=0;
                    elseif delay>=packet_mtime %packet 2 arrives before packet 1
                        r=1;
                    else %collision
                        r=2;
                    end
                    if d1<l && d2<l %within communication rage
                        if r == 0 %packet 2 arrives after packet 1
                            index(test_loc+1)=1; %collision free
                            count_1=count_1+1;
                            plot3(test_loc(1),test_loc(2),test_loc(3),'b.');
                        end


                        if r == 1 %packet 2 arrives before packet 1
                            index(test_loc+1)=1; %collision free
                            count_2=count_2+1;
                            plot3(test_loc(1),test_loc(2),test_loc(3),'k.');
                        end
                    end
            end
        end
    end
    text1=['receiver (' num2str(recv_loc(1)) ',' num2str(recv_loc(2)) ',' num2str(recv_loc(3)) ')' ];
    text2=['sender1 (' num2str(node_cluster(1,1)) ',' num2str(node_cluster(1,2)) ',' num2str(node_cluster(1,3)) ')' ];
    text3=['sender2 (' num2str(node_cluster(2,1)) ',' num2str(node_cluster(2,2)) ',' num2str(node_cluster(2,3)) ')' ];
    legend([p1 p2 p3],{text1,text2,text3}); %annotate locations of senders and receiver
    hold off
    out=[count_1, count_2] %display total number of spots of each type
    out/test_x/test_y/test_z %display the percentage of spots in the water area
    
    
end


clear all;
%�������ݸ�ʽ
format long;
%��������Ⱥ�㷨����
max_iteration=30;         %����������
swarm_size=10;             %��Ⱥ��ģ������������
particle_size=101;            %����ά��(100���˿ͺ�1���ֿ⣩

%�洢�˿����Եľ���,���ԅ���d.xls�ļ�
customers=zeros(particle_size,6);
%����Ⱥλ��
particle=zeros(max_iteration,swarm_size,particle_size,particle_size);
%����Ⱥ�ٶȾ���
velocity=zeros(max_iteration,swarm_size,particle_size,particle_size,1);
%ȫ���ٶȾ��
eset=zeros(particle_size,particle_size);
%�ֲ���������λ�ü���Ӧ�Ⱦ���
pbest=zeros(max_iteration,swarm_size,particle_size,particle_size);
%ȫ����������λ�ü���Ӧ�Ⱦ���
gbest=zeros(max_iteration,particle_size,particle_size);

%����˿���Ϣ
% NUM = xlsread('data.xls');
NUM=importdata('data.txt');

customers=NUM(:,2:7);
%sortMatrix=AdaMatrix(customers);

% for x=1:102
%        fprintf('%d ',sortMatrix(102,x));
% end


%����Eset
for x=1:particle_size
    for y=1:particle_size
        if(x~=y&&y~=1)    %Ĭ�J��ǰ���ֿ���Լ�λ��
            eset(x,y)=1;
        end
    end
end


%��ʼ������Ⱥ������swarm���Ӳֿ������β������·��ͼ
for x=1:swarm_size
    cus=randperm(particle_size-1)+1; %2-101�����˳��
    cus=[1,cus]; %�Ӳֿ����
    for y=1:particle_size-1
        particle(1,x,cus(y),cus(y+1))=1;
    end
    particle(1,x,cus(particle_size),1)=1; %���ص��ֿ�
end

%��ʼ���ٶ�
for x=1:swarm_size
    for y=1:particle_size
        for z=1:particle_size
            num=rand();
            if(num<0.6&&y~=z&&z~=1)
                velocity(1,x,y,z,1)=rand();
            end
        end
    end
end

%
%��ʼ��pbest��gbest,gbest���õ�һ������
for x=1:swarm_size
    for y=1:particle_size
        for z=1:particle_size
            pbest(1,x,y,z)= particle(1,x,y,z);
        end
    end
end
for x=1:particle_size
    for y=1:particle_size
        gbest(1,x,y)= particle(1,1,x,y);
    end
end

for iteration=1:100
    for index=1:swarm_size
        clock=0;;
        quality=1000;

        yi=zeros(particle_size);
        velocity=UpdateVelocity(particle,index,velocity,pbest,iteration);

        %    cut�ٶ�
        for x=1:particle_size
            for y=1:particle_size
                if(velocity(iteration,index,x,y,1)<0.5)
                    velocity(iteration,index,x,y,1)=0;
                end;
            end
        end

        %       update Xi*
        particle_new=zeros(particle_size,particle_size);

        serve_num=0;
        j=1; %�Ӳֿ����
        while(serve_num<100)

            flag = false ;
            result=0;
            %��v�Y����
            v=[];
            for x=1:particle_size
                if(velocity(iteration,index,j,x,1)>0)
                    v=[x,v];
                end
            end
            v= v(randperm(length(v))); %���ٶȴ��ң������ٶȶ�����

            num=rand();%�������ӵ�ѡȡ
            if(num>0.5)
                heru=99999;
                nextCus = 0;
                r_clock = 0;
                r_quality = 0;
                for x=1:length(v)
                    [ryi,rquality,rclock,result]=isValid(j,v(x),clock,yi,quality,customers,result);
                    if(result==1)
                        bkm = max(now+ sqrt((customers(v(x),1) - customers(j,1))^2+ (customers(v(x),2) - customers(j,2))^2), customers(v(x),4))-now;
                        rkm = customers(v(x),5)- ( now+ sqrt((customers(v(x),1) - customers(j,1))^2+ (customers(v(x),2) - customers(j,2))^2));
                        if(bkm+rkm<heru)
                            heru = bkm+rkm;
                            nextCus = v(x);
                            r_clock = rclock;
                            r_quality = rquality;
                        end
                    end
                end

                if(nextCus>0)
                    fprintf('vset %d %d\n',j,nextCus)
                    yi(nextCus)=1;
                    quality=rquality;
                    clock=rclock;
                    particle_new(j,nextCus)=1;
                    j=nextCus;
                    serve_num=serve_num+1;
                    if(serve_num==100)
                        particle_new(j,1)=1; %���������һ���˿ͺ󷵻زֿ�
                    end
                    flag=true;
                end


            else
                for l=1:length(v)
                    x=v(l);
                    %                 if(velocity(iteration,index,j,x,1)>0)
                    %               for x=2:particle_size
                    %                 if(velocity(iteration,index,j,x,1)>0)
                    [ryi,rquality,rclock,result]=isValid(j,x,clock,yi,quality,customers,result);
                    if(result==1)
                        fprintf('heru method vset %d %d\n',j,x)
                        yi(x)=1;
                        quality=rquality;
                        clock=rclock;
                        particle_new(j,x)=1;
                        j=x;
                        serve_num=serve_num+1;
                        if(serve_num==100)
                            particle_new(j,1)=1; %���������һ���˿ͺ󷵻زֿ�
                        end
                        flag=true;
                        break;
                    end
                    %                 end
                end
            end
            %��x��
            if(flag==false)
                for x=2:particle_size
                    if(particle(iteration,index,j,x)==1)
                        [ryi,rquality,rclock,result]=isValid(j,x,clock,yi,quality,customers,result);
                        if(result==1)
                            fprintf('xset %d %d\n',j,x)
                            yi(x)=1;
                            quality=rquality;
                            clock=rclock;
                            particle_new(j,x)=1;
                            j=x;
                            serve_num=serve_num+1;
                            if(serve_num==100)
                                particle_new(j,1)=1; %���������һ���˿ͺ󷵻زֿ�
                            end
                            flag=true;
                            break;
                        end
                    end
                end
            end
            %��eset������
            if(flag==false)
                heru=99999;
                nextCus = 0;
                r_clock = 0;
                r_quality = 0;
                for x=2:101
                    [ryi,rquality,rclock,result]=isValid(j,x,clock,yi,quality,customers,result);
                    if(result==1)
                        bkm = max(now+ sqrt((customers(x,1) - customers(j,1))^2+ (customers(x,2) - customers(j,2))^2), customers(x,4))-now;
                        rkm = customers(x,5)- ( now+ sqrt((customers(x,1) - customers(j,1))^2+ (customers(x,2) - customers(j,2))^2));

                        if(bkm+rkm<heru)
                            heru = bkm+rkm;
                            nextCus = x;
                            r_clock = rclock;
                            r_quality = rquality;
                        end
                    end
                end

                if(nextCus>0)
                    fprintf('eset %d %d\n',j,nextCus)
                    yi(nextCus)=1;
                    quality=rquality;
                    clock=rclock;
                    particle_new(j,nextCus)=1;
                    j=nextCus;
                    serve_num=serve_num+1;
                    if(serve_num==100)
                        particle_new(j,1)=1; %���������һ���˿ͺ󷵻زֿ�
                    end
                    flag=true;
                end
            end

            %��û�ҵ����زֿ⣬���Õr�g��؛����^�m������һ���
            if(flag==false)
                clock=0;
                quality=1000;
                particle_new(j,1)=1;
                j=1;
                disp('�ص��ֿ�');

            end
        end

        %���¶�Ӧλ���ϵ�����
        particle(iteration+1,index,:,:)= particle_new(:,:);
%         GetCost(particle_new,customers);
    end

    %����pbest��gbest
    for par=1:swarm_size
        m=zeros(101,101);
        n=zeros(101,101);
        m(:,:)=pbest(iteration,par,:,:);
        n(:,:)=particle(iteration+1,par,:,:);
        if(iteration==1)
            cost1 = 999;  %����ǵ�һ�ε����t�O�Þ�ܴ���춸���
        else
            cost1 = GetCost(m,customers);
        end
        cost2 = GetCost(n,customers);
        if(cost1>cost2)
            pbest(iteration+1,par,:,:)=particle(iteration+1,par,:,:);
%             n(:,:)=particle(iteration+1,par,:,:);
%             cost2=GetCost(n,customers);
        else
            pbest(iteration+1,par,:,:)=pbest(iteration,par,:,:);
        end
    end
    %����gbest
    temp=zeros(101,101);
    temp(:,:)=gbest(iteration,:,:);
    for par=1:swarm_size
        m=zeros(101,101);
        n=zeros(101,101);
        n(:,:)=pbest(iteration+1,par,:,:);
        cost2=GetCost(n,customers);
        if(iteration==1&&par==1)
            cost1 = 999;
        else
            cost1 = GetCost(temp,customers);
        end
        if(cost1>cost2)
            disp(iteration);
            disp(cost2);
            cost1=cost2;
            temp(:,:)=n(:,:);
        end
    end
    gbest(iteration+1,:,:)=temp(:,:);
end

%��ӡ����ĽY��
for x=1:101
    for y=1:101
        if(gbest(101,x,y))==1
            fprintf('%d %d\n',x-1,y-1);
           
        end
    end
end

 temp2=zeros(101,101);
 temp2(:,:)=gbest(101,:,:);
 fprintf('%d \n',GetCost(temp2,customers));
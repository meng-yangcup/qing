%project1:
%analysis
%Q1:容器艇和操作手的匹配关系1:4
%工作时间为一周；必须取出保养；
%新容器艇需要一周测试后才能使用；操作手需要学习一周才能使用；每周开始到货开始测试和学习
%多余的容器艇需要保养，继续工作的不需要保养
%学习指导比例1:10
%满足需求成本最低：
%假设目前已有容器艇和操作手为X，Y，每周增加的量为x，y。矩阵存储。计划需求量为：req
%利用req作为判断需求的边界条件
%制作一个成本函数Z=购买成本+保养费用+训练费用
%设X，Y为目前库存的量，X1，Y1为能利用的量，x,y为本周新增的量；x表示容器艇,y表示操作手
req = [11	5	4	7	16	6	5	7];
X = zeros(numel(req),1);Y = zeros(numel(req),1);X1 = zeros(numel(req),1);Y1 = zeros(numel(req),1);
x = zeros(numel(req),1);y = zeros(numel(req),1);
X(1) = 13; Y(1) = 50;X1(1) = X(1); Y1(1) = Y(1);x(1) = 0; y(1) = 0;
for i = 1:size(req)
    X1(i) = X(i) - req(i);
    Y1(i) = Y(i) - 4*req(i);
    if X1(i) < 0
        x(i) = req(i) - X1(i);
        X1(i)=req(i);
    end
    if Y1(i) < 0 
        y(i) = 4*(req(i) - X1(i));
        Y1(i)=4*req(i);
    end
    purchase = x(i)*200+y(i)*100;
    maintain = (X(i)-X1(i))*10 + (Y(i)-Y1(i))*5;
    if y(i) > 0 && 10*Y1(i) > y(i)
        training = 10 * (4*y(i));
    else
        training = 0;
    end
    Z = purchase + maintain + training;
    
end
%%
clear
clc
%由于后?周的采集量受到下?周需求量和当期存量的影响，不知道后?周的参数范围 %因此不能当作寻常的优化问题来看，因此只能做仿真模拟实验 %这样也能很?程度提?寻优效率，最后的结果只能是尽可能最优，很难达到真正的最优
T=100; %初始化温度值
T_min=1; %设置温度下界
alpha=0.95; %温度的下降率
num=1000; %颗粒总数
XQ=[11,5,4,7,16,6,5,7,13,6];%各周需求
p=4;%容器艇配备的机械?数
L=10;%?个指导机械?可训练新操作?的数?
Y=zeros(9,length(XQ));%记录过程数据
Y(:,1)=[0
 13
 50
 0
 0
 0
 0
 0
 0];%第?周使?的机器?\剩余容器艇\剩余操作?\保养容器艇\保养操作?\指导操作?\训练操作?\购买容器艇数\购买操作?数
G=[200
 100
 5
 10
 10];%容器艇\操作?\操作?保养\容器艇保养\操作?训练成本
X1=[];
F1=[];
for i=1:num
 [X1{i,1},F1(i,1)]=fun_A1(XQ,p,L,Y,G);
end
[bestf,b]=min(F1);
besty=X1{b,1};
trace=[];
trace=bestf;
while(T>T_min)
 XX1=[];
 FF1=[];
 for i=1:num
 [XX1{i,1},FF1(i,1)]=fun_A1(XQ,p,L,Y,G);
 end
 %是否更新最优
 for j=1:num
 delta=FF1(j,1)-F1(j,1);
 if delta<0
 F1(j,1)=FF1(j,1);
 X{j,:}=XX1{j,:};
 else
 pp=exp(-delta/T);
 if pp>rand
 F1(j,1)=FF1(j,1);
 X1{j,:}=XX1{j,:};
 end
 end
 end
 if min(F1)<bestf
 [bestf,b]=min(F1);
 besty=X1{b,1};
 end
 trace=[trace;bestf];
 T=T*alpha;
end
figure
plot(trace)
xlabel('退?次数')
ylabel('总成本')
%
function [X1,F1]=fun_A1(XQ,p,L,Y,G)
%YY矩阵每?：第?周使?的机器?\剩余容器艇\剩余操作?\保养容器艇\保养操作?\
%指导操作?\训练操作?\购买容器艇数\购买操作?数
 flag=0;
 while flag==0
    YY=Y;
    for j=1:length(YY)-2
        xq=XQ(j);%本周周机器?需求量
        YY(1,j)=xq;
        YY(2,j)=YY(2,j)-xq;
        YY(3,j)=YY(3,j)-xq*p;
        %未?的操作?需要做保养
        YY(5,j)=YY(3,j);
        %?管机器?在患者?管中?作时间是?周，取出后操作?拆卸下来需要进??周的保养才能再次开展?作
        %使?结束后容器艇并不必须要保养，下?周可?容器艇数
        YY(2,j+1)=YY(1,j)+YY(2,j);
        YY(2,j+2)=YY(1,j)+YY(2,j);
        %使?结束后操作?需要保养，保养时间?周
        YY(5,j+1)=YY(5,j+1)+YY(1,j)*p;
        %在下下周可使?
        YY(3,j+2)=YY(3,j+2)+YY(1,j)*p;
        xq1=XQ(j+1);%下?周机器?需求量
        xq2=XQ(j+2);%下下?周机器?需求量
        %如果
        k1=max(xq1-YY(2,j+1),xq2-YY(2,j+2));
        if k1<0
            k1=0;
        end
        %剩余未?来训练的机械?+?于指导的机械?+培养的机械?应当满?下?周需求,同理也应满?第三周需求量
        k2=xq1*p-YY(5,j);
        if k2<0
            k2=0;
        end
         %下下周是否需要更多的机械?
        kk2=xq2*p-YY(3,j+2);
        if kk2<0
            kk2=0;
        else
            kk2=ceil(kk2/L);
        end
        %确定当周?少要购买的机械?数
        k2=k2+kk2;
        %最?采购则是上?周剩余的机械?数*L
        k3=min(k2+10,YY(5,j)*L);%但是也不能过?
        if k3<k2
            k3=k2;
        end
        %也不能就k2，因为可能后?会有突发的需求，采购当期最?训练数也满?不了
        %购买容器艇数
        gm1=k1;
        %购买机械?数
        gm2=randi([fix(k2),fix(k3)]);
        %训练和保养
        YY(4,j)=YY(4,j)+gm1;
        YY(2,j+1)=YY(2,j+1)+gm1;
        YY(5,j)=YY(5,j)-ceil(gm2/L);
        YY(6,j)=YY(6,j)+ceil(gm2/L);
        YY(7,j)=YY(7,j)+gm2;
        %下?周剩余操作?
        YY(3,j+1)=YY(3,j+1)+YY(7,j)+YY(8,j);
        %记录购买数量
        YY(8,j)=gm1;
        YY(9,j)=gm2;
        end
     if isempty(find(YY<0, 1))
        flag=1;
     end
     end
     X1=YY;%储存过程数据
     %计算成本
     F1=sum(sum(YY([8,9,5,4,7],1:8).*G));
end
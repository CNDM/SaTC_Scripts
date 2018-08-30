function [Benefit, Question]=SaTC3_FindRate(s)
%%% Subject number as input, returns a matrix of the Attractiveness and
%%% Intrusiveness Ratings for the Decision task of the SaTC Project. Called
%%% for the Model Building Scripts.

BehaviorDataDir = '/Users/CNDM/Dropbox/SaTCPrivacyGrant/SaTC3/Data/';

Bene=read_table_DMRate([BehaviorDataDir num2str(s) '/Benefit.2.' num2str(s) '.out.txt']);
Quest=read_table_DMRate([BehaviorDataDir num2str(s) '/Question.1.' num2str(s) '.out.txt']);

QuestionIndex = read_table_DM1('/Users/CNDM/Dropbox/SaTCPrivacyGrant/SaTC3/Lists/Question.1.txt');

for qidx = 1:60
    index = 1;
    while ~strcmp(Quest.col9{qidx,1}{1,1}, QuestionIndex.col4{index,1}{1,1})
        index = index + 1;
    end
    Quest.col4(qidx,1) = index;
end

for r=1:2
    Dec(r)=read_table_DMDec([BehaviorDataDir num2str(s) '/Dec.' num2str(r) '.' num2str(s) '.out.txt']);
end

A.cols_names=Dec(1).cols_names;
A.col1=cat(1,Dec(1).col1,Dec(2).col1);
A.col2=cat(1,Dec(1).col2,Dec(2).col2);
A.col3=cat(1,Dec(1).col3,Dec(2).col3);
A.col4=cat(1,Dec(1).col4,Dec(2).col4);
A.col5=cat(1,Dec(1).col5,Dec(2).col5);
A.col6=cat(1,Dec(1).col6,Dec(2).col6);
A.col7=cat(1,Dec(1).col7,Dec(2).col7);
A.col8=cat(1,Dec(1).col8,Dec(2).col8);
A.col9=cat(1,Dec(1).col9,Dec(2).col9);
%Convert response column to num
for c=1:length(Bene.col1)
    N=strmatch('n',Bene.col6{c});
    C=strmatch('c',Bene.col6{c});
    if N==1
        Bene.col6{c}=NaN;
        z(c)=cell2mat(Bene.col6(c));
    elseif C==1
        Bene.col6{c}=NaN;
        z(c)=cell2mat(Bene.col6(c));
    else
        z(c)=str2num(cell2mat(Bene.col6(c)));
    end
end
Bene.col6=z';
%Quest
for c=1:length(Quest.col1)
    N=strmatch('n',Quest.col6{c});
    C=strmatch('c',Quest.col6{c});
    if N==1
        Quest.col6{c}=NaN;
        z(c)=cell2mat(Quest.col6(c));
    elseif C==1
        Quest.col6{c}=NaN;
        z(c)=cell2mat(Quest.col6(c));
    else
        z(c)=str2num(cell2mat(Quest.col6(c)));
    end
end
Quest.col6=z';
%Convert resp to NAN
index=1;
for c=1:length(A.col1)
    %if A.col2(c)==0 %Cue line
    %Drop
    
    B.trial(index)=A.col1(c);
    %B.mode(index)=A.col2(c);
    B.type(index)=A.col3(c);
    B.quest(index)=A.col4(c);
    B.benefit(index)=A.col5(c);
    B.onset(index)=A.col6(c);
    B.rt(index)=A.col8(c);
    B.iti(index)=A.col9(c);
    N=strmatch('n',A.col7{c});
    C=strmatch('c',A.col7{c});
    if N==1
        A.col7{c}=NaN;
        B.resp(index)=cell2mat(A.col7(c));
    elseif C==1
        A.col7{c}=NaN;
        B.resp(index)=cell2mat(A.col7(c));
    else
        B.resp(index)=str2num(cell2mat(A.col7(c)));
    end
    %% Change - Anthony Resnick
    % Making instead of sure/unsure, make 1-2, 3-4, willing/unwilling.
    if B.resp(index)==1
        B.resprecode(index)=0;
    elseif B.resp(index)==2
        B.resprecode(index)=0;
    elseif B.resp(index)==3
        B.resprecode(index)=1;
    elseif B.resp(index)==4
        B.resprecode(index)=1;
    elseif isnan(B.resp(index))
        B.resprecode(index)=0;
    end
    index=index+1;
end

%Linear Regression - 4 pt scale for acceptability
%Build regressors - used for all regressions; NAN for any value excluded
index=1;
for a=1:length(B.trial)
    if isnan(B.resp(a))
        %Skip this trial
    elseif isnan(Bene.col6(find(Bene.col4==B.benefit(a))));
    elseif isnan(Bene.col6(find(Bene.col4==B.quest(a))));
    elseif isnan(Quest.col6(find(Quest.col4==B.quest(a))));
    elseif isnan(Quest.col6(find(Quest.col4==B.benefit(a))));
    else
    %Pull data 
    Benefit(index)=Bene.col6(find(Bene.col4==B.benefit(a)));
    Question(index)=Quest.col6(find(Quest.col4==B.quest(a)));
    Rate(index)=B.resp(a);
    RecodeRate(index)=B.resprecode(a);
    RT(index)=B.rt(a);
    index=index+1;
    end
end

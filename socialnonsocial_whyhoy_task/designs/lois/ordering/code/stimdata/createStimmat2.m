count = 0;
im = {};
data = [];
basedir = pwd;
tmp = folders('de*');



for i = 1:length(tmp)
    
    cd([basedir filesep tmp{i}]);
    q = folders('Is*');

    for b = 1:length(q)
        
        fprintf('\n%s', q{b})
        
             
        cd([basedir filesep tmp{i} filesep q{b} filesep 'YES']);

        tt = files('*.jpg');
        if isempty(tt)
            fprintf('\n\n%\n\n', q{b});
        end
        for p = 1:length(tt)
            count = count + 1;
            data(count,1) = i;
            data(count,2) = 1;
            tmpname = regexprep(q{b},'_',' ');
            im(count,1) = cellstr(tmpname);
            im(count,2) = tt(p);
        end
        
        cd([basedir filesep tmp{i} filesep q{b} filesep 'NO']);

        tt = files('*.jpg');
                if isempty(tt)
            fprintf('\n\n%\n\n', q{b});
        end
        for p = 1:length(tt)
            count = count + 1;
            data(count,1) = i;
            data(count,2) = 2;
            tmpname = regexprep(q{b},'_',' ');
            im(count,1) = cellstr(tmpname);
            im(count,2) = tt(p);
        end
        

    end

end
qdata = data;
qim = im;
cd(basedir)
save demo_all_question_data.mat qdata qim
        

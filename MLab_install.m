%MLab Installation script
%
%   This script installs MLab on your computer.
%
%   --- PRE-REQUISITES
%
%   - Matlab (R2014b or higher)
%   - Internet connection
%   - git is installed
%
%   --- FOOTPRINT
%   During the installation process only one folder called "MLab" is
%   created. It contains all MLab programs, and also all the plugins you
%   install afterwards.
%   Note that after successful install, MLab is automaticaally started and
%   a configuration file called "MLab.mat" is created in Matlab's prefdir.
%   A configuration file called "MLab.[Plugin name].mat" may also be
%   created each time you install a plugin.
%
%   NB: This installation file will self-destruct after installation is
%   complete.
%
%   See also ML.uninstall, prefdir

% === Parameters ==========================================================

repo = 'https://github.com/MLab-admin/MLab.git';
root = [pwd filesep 'MLab' filesep];

dpt = 0.1;

% =========================================================================

% --- Check Matlab version
if verLessThan('matlab', '8.5.0')
    warning('MLab:Version', 'Your version of Matlab is too old. R2014b or higher is requested for MLab.');
    return;
end

% --- Preparation

% Default installation folder
root = [pwd filesep 'MLab' filesep];

% --- Get user input
while true
    
    clc
    Notes = {};
    
    cws = get(0,'CommandWindowSize');
    
    fprintf('\n--- [\b<strong>MLab installation</strong>]\b %s\n\n', repmat('-', [1 cws(1)-23]));
    fprintf('You are about to install [\bMLab]\b on this computer.\n\n');
    fprintf('Install location:\n\t<strong>%s</strong>\n\n', root);
    
    % Check for MLab folder existence
    if exist(root, 'dir')
        fprintf('[\b<strong>WARNING !</strong>]\b This folder already exists.\n');
        fprintf('\t<strong>Installation will totally erase existing content !</strong>\n\n');
    else
        Notes{end+1} = '* The [\bMLab]\b folder will be created automatically.';
    end
    
    % Check for MLab configuration files
    cfiles = dir([prefdir filesep 'MLab*.mat']);
    if numel(cfiles)
        s = '* The following configuration files have been found:\n';
        for i = 1:numel(cfiles)
            s = [s '\t' cfiles(i).name '\n'];
        end
        s = [s '  They will be updated during installation.\n'];
        Notes{end+1} = s;
    end
    
    % Display notes
    if numel(Notes)
        fprintf('<strong>Notes</strong>\n');
        for i = 1:numel(Notes)
            fprintf([Notes{i} '\n']);
        end
    end
    fprintf('Please choose an action:\n\n');
    
    fprintf('\t[[\b<strong>i</strong>]\b]- Install MLab\n');
    fprintf('\t[[\b<strong>c</strong>]\b]- Change install location\n');
    fprintf('\t[[\b<strong>q</strong>]\b]- Quit\n\n');
    
    switch lower(input('?> ', 's'))
        
        case 'q'
            fprintf('\n[\bInstallation aborted.]\b\n\n');
            return
            
        case 'c'
            fprintf('\nPlease enter the installation location\n');
            tmp = input('?> ', 's');
            if ~isempty(tmp)
                root = tmp;
                if ~strcmp(root(end), filesep), root(end+1) = filesep; end
                [~, ld] = fileparts(root(1:end-1));
                if ~strcmp(ld, 'MLab')
                    root = [root 'MLab'];
                end
            end
            
        case 'i'
            break;
    end
end

% --- Check for the existence of a MLab folder
if exist(root, 'dir')
    
    fprintf('\n[\b<strong>Warning !</strong>]\b This folder already exists:\n\t<strong>%s</strong>\n\n', root);
    fprintf('Are you sure you want to remove all its content and perform\na fresh install ? [Y/n]\n');
    
    while true
        
        tmp = lower(input('?> ', 's'));
        switch tmp
            case 'n'
                fprintf('\n[\bInstallation aborted.]\b\n\n');
                return
            case {'', 'y'}
                break;
            otherwise
                fprintf('%s', repmat(char(8), [1 numel(tmp)+4]));
        end
    end
    
end

% --- Installation procedure

clc
fprintf('\n--- [\b<strong>MLab installation</strong>]\b %s\n\n', repmat('-', [1 cws(1)-23]));

% Remove MLab folder
if exist(root, 'dir')
    fprintf('Removing existing MLab ...'); tic
    rmdir(root, 's');
    fprintf(' %.2f sec\n', toc);
    pause(dpt);
end

% Modify configuration file
cfname = [prefdir filesep 'MLab.mat'];
if exist(cfname, 'file')
    fprintf('Modifying MLab configuration file ...'); tic
    tmp = load(cfname);
    tmp.config.path = root;
    config = tmp.config;
    save(cfname, 'config');
    fprintf(' %.2f sec\n', toc);
    pause(dpt);
end

% Create MLab folder
fprintf('Creating MLab folder ...'); tic
mkdir(root);
fprintf(' %.2f sec\n', toc);
pause(dpt);

% Clone repo
fprintf('Cloning repository ...'); tic
cloneCMD = org.eclipse.jgit.api.Git.cloneRepository;
cloneCMD.setDirectory(java.io.File(root));
cloneCMD.setURI(repo);
cloneCMD.call;
fprintf(' %.2f sec\n', toc);
pause(dpt);

% Create Plugins folder
fprintf('Creating MLab plugins folder ...'); tic
mkdir([root 'Plugins']);
fprintf(' %.2f sec\n', toc);
pause(dpt);

% --- Installation file self-destruction

% Definition
fname = [mfilename('fullpath') '.m'];

% % % % Close installation file in the editor
% % % if matlab.desktop.editor.isEditorAvailable
% % %     tmp = matlab.desktop.editor.getActive;
% % %     if strcmp(fname, tmp.Filename), tmp.close; end
% % % end
% % % 
% % % % Remove installation file
% % % delete(fname);

fprintf('\n<strong>Your </strong>[\b<strong>MLab</strong>]\b<strong> install is successful !</strong>\n\n');

fprintf('You can start [\bMLab]\b by running the following program (clickable link):\n');

fprintf('\t<a href="matlab:cd(''%s''); ML.start;">%s</a>\n\n', ...
    root, [root '+ML' filesep 'start.m']);

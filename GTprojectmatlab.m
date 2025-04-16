function visualizeGraph(paths, startWord, targetWord)
    % Create a directed graph (digraph) instead of undirected graph
    G = digraph(); 

    % Add nodes and edges to the graph based on the paths
    for i = 1:length(paths)
        path = paths{i};
        for j = 1:length(path)-1
            % Add directed edges from path{j} to path{j+1}
            G = addedge(G, path{j}, path{j+1});
        end
    end

    % Plot the graph with directed edges
    figure;
    h = plot(G, 'Layout', 'force', 'NodeLabel', G.Nodes.Name, 'ArrowSize', 10);

    % Color the start and target nodes differently
    highlightStart = findnode(G, startWord);
    highlightTarget = findnode(G, targetWord);
    h.NodeColor = repmat([0.7 0.7 0.7], size(G.Nodes, 1), 1); % Default node color
    h.NodeColor(highlightStart, :) = [0.1 0.8 0.1]; % Start node in green
    h.NodeColor(highlightTarget, :) = [0.8 0.1 0.1]; % Target node in red
end



% Function to find the longest chain length and paths
function [longestLength, longestPaths] = longestChainLenAndPath(startWord, targetWord, D)
    longestLength = 0;
    longestPaths = {};  % Initialize to avoid unused variable warning

    if strcmp(startWord, targetWord)
        longestLength = 0;
        longestPaths = {startWord};
        return;
    end

    if ~ismember(targetWord, D)
        longestLength = 0;
        longestPaths = {};
        return;
    end

    wordLength = length(startWord);
    D = unique(D); % Ensure dictionary is unique

    % Queue to store paths (currentWord, pathSoFar)
    Q = {startWord, {startWord}};
    longestPaths = {};

    while ~isempty(Q)
        [currentWord, path] = Q{1, :}; % Dequeue the first element
        Q(1, :) = [];

        for pos = 1:wordLength
            originalChar = currentWord(pos);
            
            % Try changing the character at each position to every letter 'a' to 'z'
            for c = 'a':'z'
                newWord = currentWord;
                newWord(pos) = c;

                if strcmp(newWord, targetWord)
                    candidatePath = [path, newWord];
                    if length(candidatePath) > longestLength
                        longestLength = length(candidatePath);
                        longestPaths = {candidatePath};
                    end
                elseif ismember(newWord, D) && ~ismember(newWord, path)
                    Q = [Q; {newWord, [path, newWord]}];
                end
            end
        end
    end
end

% Function to find the shortest chain length and paths
function [shortestLength, shortestPaths] = shortestChainLenAndPath(startWord, targetWord, D)
    shortestLength = inf;  % Initialize to avoid unused variable warning
    shortestPaths = {};    % Initialize to avoid unused variable warning

    if strcmp(startWord, targetWord)
        shortestLength = 0;
        shortestPaths = {startWord};
        return;
    end

    if ~ismember(targetWord, D)
        shortestLength = 0;
        shortestPaths = {};
        return;
    end

    wordLength = length(startWord);
    Q = {startWord, {startWord}};
    visited = containers.Map();

    while ~isempty(Q)
        level = size(Q, 1);

        for i = 1:level
            [currentWord, path] = Q{1, :};
            Q(1, :) = []; % Dequeue the first element

            for pos = 1:wordLength
                originalChar = currentWord(pos);

                % Try changing the character to every letter 'a' to 'z'
                for c = 'a':'z'
                    newWord = currentWord;
                    newWord(pos) = c;

                    if strcmp(newWord, targetWord)
                        candidatePath = [path, newWord];
                        if length(candidatePath) < shortestLength
                            shortestLength = length(candidatePath);
                            shortestPaths = {candidatePath};  % Wrap in a cell
                        elseif length(candidatePath) == shortestLength
                            shortestPaths{end+1} = candidatePath;  % Append to cell array
                        end
                    elseif ismember(newWord, D) && ~isKey(visited, newWord)
                        visited(newWord) = true;
                        Q = [Q; {newWord, [path, newWord]}];
                    end
                end
            end
        end
    end
end

% Main function to run the example and compare shortest/longest paths
function wordTransformationComparison()
    % Dictionary of words
    D = {'hit', 'hot', 'dot', 'dog', 'cog', 'lot', 'log', 'hip', 'hop', 'top', 'lop', 'bot', 'pot', 'cop', 'cot'};
    startWord = 'hit';
    targetWord = 'cog';

    % Measure time for longest chain calculation
    tic; % Start timer
    [longestLength, longestPaths] = longestChainLenAndPath(startWord, targetWord, D);
    longestTime = toc; % Stop timer
    
    % Measure time for shortest chain calculation
    tic; % Start timer
    [shortestLength, shortestPaths] = shortestChainLenAndPath(startWord, targetWord, D);
    shortestTime = toc; % Stop timer

    % Display Results
    fprintf('\n--- Comparative Analysis ---\n');
    fprintf('\nExecution Time (MATLAB):\n');
    fprintf('Time for finding longest chain: %.6f seconds\n', longestTime);
    fprintf('Time for finding shortest chain: %.6f seconds\n', shortestTime);

    % Visualize the graph for the shortest paths
    if ~isempty(shortestPaths)
        disp('Visualizing the shortest paths graph...');
        visualizeGraph(shortestPaths, startWord, targetWord);
    end

    % Print results for shortest and longest chains
    fprintf('\nLength of shortest chain is: %d\n', shortestLength);
    if isempty(shortestPaths)
        disp('No shortest path found');
    else
        disp('Shortest paths are:');
        for i = 1:length(shortestPaths)
            disp(strjoin(shortestPaths{i}, ' -> '));
        end
    end

    fprintf('\nLength of longest chain is: %d\n', longestLength);
    if isempty(longestPaths)
        disp('No longest path found');
    else
        disp('Longest paths are:');
        for i = 1:length(longestPaths)
            disp(strjoin(longestPaths{i}, ' -> '));
        end
    end
end

% Call the main function to run the transformation and perform comparative analysis
wordTransformationComparison();

:- use_module(library(clpfd)).


% дължина(X, N) - N е дължината на списъка X.
% УСЛОВИЕ! Известно е ограничение отгоре за дължината на X
%          или максимална стойност за N.
дължина([], N) :- N #= 0.
дължина([_|X], N) :- N #>= 1, дължина(X, N-1).

% сума(X, N) - N е сумата на елементите на списъка X.
% УСЛОВИЕ! Известно е ограничение отгоре за дължината на X.
сума([], N) :- N #= 0.
сума([A|X], N) :- сума(X, N-A).

% nth(X, N, A) - N-тият елемент на списъка X е A.
% УСЛОВИЕ! Известно е ограничение отгоре за дължината на X
%          или максимална стойност за N.
nth([A|_], N, A) :- N #= 1.
nth([_|X], N, A) :- N #> 1, nth(X, N-1, A).


:- discontiguous(връх/2).
:- discontiguous(ребро/3).

връх(g1, a).   връх(g1, b).   връх(g1, c).   връх(g1, d).
връх(g1, e).   връх(g1, f).   връх(g1, g).   връх(g1, h).

ребро(g1, a, b).   ребро(g1, a, c).   ребро(g1, b, d).
ребро(g1, c, d).   ребро(g1, c, e).   ребро(g1, d, f).
ребро(g1, e, f).   ребро(g1, e, g).   ребро(g1, f, h).
ребро(g1, g, h).

връх(g2, a).   връх(g2, b).   връх(g2, c).   връх(g2, d).
връх(g2, e).   връх(g2, f).   връх(g2, g).   връх(g2, h).

ребро(g2, a, a).   ребро(g2, a, e).   ребро(g2, a, b).
ребро(g2, b, d).   ребро(g2, c, b).   ребро(g2, d, c).
ребро(g2, d, e).   ребро(g2, e, f).   ребро(g2, f, d).
ребро(g2, g, h).   ребро(g2, g, e).   ребро(g2, h, g).
ребро(g2, h, f).

% върхове(G, VV) - VV е списък от върховете в G.
% УСЛОВИЕ! G е напълно известен краен граф.
върхове(G, VV) :- findall(V, връх(G, V), X),
    sort(X, VV). % Махаме повтарящите се елементи в X,
%                  резултатът е във VV.

% ребра(G, EE) - EE е списък от ребрата в G.
% УСЛОВИЕ! G е напълно известен краен граф.
ребра(G, EE) :- findall((V, W), ребро(G, V, W), X),
    sort(X, EE). % Махаме повтарящите се елементи в X,
%                  резултатът е във EE.


% извадка(X, Y, N, Z) - Z е списък от онези елементи X[i], за които Y[i] = N.
% УСЛОВИЕ! Известно е ограничение отгоре за дължината на
%          първия или на втория аргумент.
извадка([], [], _, []).
извадка([A|X], [B|Y], N, [A|Z]) :- N #= B,
    извадка(X, Y, N, Z).
извадка([_|X], [B|Y], N, Z) :- N #\= B,
    извадка(X, Y, N, Z).

generate_partition(G, A, S, B) :-
    върхове(G, VV),
    дължина(VV, N),
    дължина(Цветове, N),
    Цветове ins 0..2,
    label(Цветове),
    извадка(VV, Цветове, 1, A),
    извадка(VV, Цветове, 2, B),
    извадка(VV, Цветове, 0, S).

% отделени(VV, EE, Цветове) - За всеки елемент (V1,V2) на EE, където V1 = VV[K1] и V2 = VV[K2], е вярно
%                             Цветове[K1] = Цветове[K2] или Цветове[K1] = 0 или Цветове[K2] = 0.
% УСЛОВИЕ! G е напълно известен краен граф.
отделени(_, [], _).
отделени(VV, [(V1, V2)|EE], Цветове) :-
    Ц1 #= Ц2 #\/ Ц1 #= 0 #\/ Ц2 #= 0,
    nth(VV, K1, V1),
    nth(VV, K2, V2),
    nth(Цветове, K1, Ц1),
    nth(Цветове, K2, Ц2),
    отделени(VV, EE, Цветове).

generate_separators(G, A, S, B) :-
    върхове(G, VV),
    ребра(G, EE),
    дължина(VV, N),
    дължина(Цветове, N),
    Цветове ins 0..2,
    отделени(VV, EE, Цветове),
    label(Цветове),
    извадка(VV, Цветове, 1, A),
    извадка(VV, Цветове, 2, B),
    извадка(VV, Цветове, 0, S).

generate_k_separators(G, K, A, S, B) :-
    върхове(G, VV),
    ребра(G, EE),
    дължина(VV, N),
    дължина(Цветове, N),
    Цветове ins 0..2,
    отделени(VV, EE, Цветове),
    global_cardinality(Цветове, [0-_, 1-NA, 2-NB]),
    NA #>= K, NB #>= K,
    label(Цветове),
    извадка(VV, Цветове, 1, A),
    извадка(VV, Цветове, 2, B),
    извадка(VV, Цветове, 0, S).

generate_k_min_separators(G, K, A, S, B) :-
    generate_k_separators(G, K, A, S, B),
    дължина(S, N),
    not(( % няма множество S с по- малко елементи
        N #< M,
        generate_k_separators(G, K, _, R, _),
        дължина(R, M)
    )).
    
